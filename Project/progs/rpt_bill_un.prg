Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              dDate_from , ;         && from date
              dDate_to, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

cCSite = ""
cTeam = ""
LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CTEAM"
      cTeam = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor
************************************************************************************
*** Create claims for all billings depending on Paramters and procpara.dbf record **
************************************************************************************
dStartDate=ddate_from
dEndDate=ddate_to
cprog=lcprog
csite=ccsite

PUBLIC m.bill_ID, m.IsMedicaid, m.dt, m.tm, lReProcess
m.bill_id		= space(10) 		&& Re-assigned in Startlog function
m.IsMedicaid	= .F.				&& Re-assigned in ProvList function

cClaimType ='01'
nPrim_Sec  = 1		&& Default to PRIMARY Insurance Billing ****

cTitle = "Billable Units by Date Range Report"
cDate = DATE()
cTime = TIME()
PRIVATE iicond, lFound

iidate = {}

* Open all needed files
IF !OpenAll()
	RETURN .F.
ENDIF

* Create Provider Cursor **************************************
IF !ProvList()
	RETURN .F.
ENDIF

* Making cursor for Rates and TimeTables **********************
IF !RateList()
	RETURN .F.
ENDIF

***	Select all clients' names in cursor but don't use cli_cur since clients being **
*** billed may not be in security scope, be closed, or ? ********
IF !InsureList()
	RETURN .F.
ENDIF

*** Pre-select all combinations of encs for current Billing Type (COBRA,ADHC,Etc.) *
*** also get site assignments & program assignments *************
IF !PreSelEncs()
	RETURN .F.
ENDIF

*** Find Insurance History Record Matching Enc Date *****
IF !MatchInsur()
	RETURN .F.
ENDIF
***	See comments in MatchInsur to see what information we have at this time

*** Combining Encounters and Service Records ***
IF !ComboThem()
	RETURN .F.
ENDIF

*** Getting Rate Codes, Procedure codes, then rates *************
IF !GetDetail()
	RETURN .F.
ENDIF

*** Calculate all 
IF !theRules()
	RETURN .F.
ENDIF

*** Calculate billable units per worker per team ****************
IF !WORKERTM()
   oApp.msg2user('OFF')
   oApp.msg2user('NOTFOUNDG')  
ELSE
   oApp.msg2user('OFF')
   gcRptName = 'rpt_bill_un'
   SELECT units_cur
   GO TOP
     DO CASE
         CASE lPrev = .f.
              Report Form rpt_bill_un  To Printer Prompt Noconsole NODIALOG 
         CASE lPrev = .t.     &&Preview
               oApp.rpt_print(5, .t., 1, 'rpt_bill_un', 1, 2)
     ENDCASE
   
ENDIF

RETURN

************************************************************************************
FUNCTION OpenAll

	SELECT staffcur
	SET ORDER TO worker_id
	
	=OpenFile("InsStat") 				&& client's insurance status ***************
	=OpenFile("ai_enc") 					&& encounters ******************************
	=OpenFile("ai_serv") 				&& services ********************************
	=OpenFile("ai_site") 				&& site assignments ************************
	=OpenFile("rate_grp") 				&& rate group ******************************
	=OpenFile("enc_serv","spsrcs")	&& encs/services procs & rates assignments *
												** serv_cat & prog & site & rate_grp *******
												** & code & serv ***************************
										
	* Create a cursor of default procedure codes for services where one was not entered
    If Used('def_proc')
      Use in def_proc
   EndIf

  **VT 02/27/2008 Dev Tick 4090  V 8.1
     
*!*   	SELECT ;
*!*   		Serv_Cat, Prog, Site, Rate_Grp, code, proc_code ;
*!*   	FROM ;
*!*   		enc_serv ;
*!*   	WHERE ;
*!*   		EMPTY(serv) AND ;
*!*   		can_bill AND ;
*!*   		!EMPTY(proc_code) ;
*!*   	INTO CURSOR ;
*!*   		def_proc

*!*   	INDEX ON Serv_Cat + Prog + Site + Rate_Grp + code TAG spsrc

   SELECT ;
      Serv_Cat, Prog, Site, Rate_Grp, enc_id, proc_code ;
   FROM ;
      enc_serv ;
   WHERE ;
      service_id = 0 AND ;
      can_bill AND ;
      !EMPTY(proc_code) ;
   INTO CURSOR ;
      def_proc
      
	  INDEX ON  serv_cat+prog+site+rate_grp+STR(enc_id,4,0) Tag spsrc

RETURN	&& End OpenAll

************************************************************************************
FUNCTION ProvList

	=OpenFile("med_prov") 				&& Provider header assignments *************
	=OpenFile("med_pro2") 				&& Provider middle assignments *************
	=OpenFile("med_pro3") 				&& Provider lower  assignments *************

	***************	Creating Provider Table ****************************************
     If Used('Prov_cur')
      Use in Prov_cur
   EndIf
   
	SELECT ;
		med_prov.prov_id, med_pro2.prov2_id, med_pro3.prov3_id, ;
		name, IsMedicaid, InsType, med_pro2.Def_Phys, Def_period, Signature, Auth_by, processprg, ;
		prov_num, descript, med_pro2.claimtype, ;
		street1, street2, city, st, zip, phone, contact, ;
		site, PROG, def_loc, rate_grp, cat_serv, clin_spec, mag_input, ;
		plan_code, hosp_code ;
	FROM ;
		med_prov, med_pro2, med_pro3 ;
	WHERE ;
		med_prov.prov_id  = med_pro2.prov_id AND ;
		med_pro2.prov2_id = med_pro3.prov2_id ;
	INTO CURSOR ;
		Prov_cur
	
*-*	AND med_pro2.claimtype = '01'
			
	INDEX ON site + PROG TAG SITE_PROG UNIQUE
	GO TOP
	SCATTER MEMVAR FIELD cat_serv, IsMedicaid
	cDef_Phys = prov_cur.def_phys

RETURN	&& End ProvList

************************************************************************************
FUNCTION RateList
	=OpenFile("rate_history")
   
	=OpenFile("rate_hd") 				&& rate header assignments  ****************
**	=OpenFile("rate_md") 				&& rate middle assignments  ****************
**	=OpenFile("rate_dt") 				&& rate lower  assignments  ****************
	=OpenFile("time_md") 				&& time middle assignments  ****************
	=OpenFile("time_dt") 				&& time lower  assignments  ****************
	
	*** Get blank rate code for Rushmore optimization instead of Empty() ***********
	cBlankRateCode = SPACE(LEN(rate_hd.rate_code))
	
	***	Creating Rate History Table ************************************************
   If Used('Rates_cur')
      Use in Rates_cur
   EndIf
   
*!*   	SELECT ;
*!*   		rate_hd.rate_hd_id, rate_md.rate_md_id, rate_dt.rate_dt_id, ;
*!*   		rate_hd.rate_code, rate_hd.descript, rate_hd.by_time, ;
*!*   		rate_hd.IsMedicaid, rate_hd.Bill_type, ;
*!*   		rate_md.rate_grp, ;
*!*   		rate_dt.rate, rate_dt.eff_date ;
*!*   	FROM ;
*!*   		rate_hd, rate_md, rate_dt ;
*!*   	WHERE ;
*!*   		rate_hd.rate_hd_id	= rate_md.rate_hd_id AND ;
*!*   		rate_md.rate_md_id	= rate_dt.rate_md_id ;
*!*   	ORDER BY ;
*!*   		rate_hd.rate_code, rate_md.rate_grp, rate_dt.eff_date DESC ;
*!*   	INTO CURSOR ;
*!*   		Rates_cur

**VT 04/10/2007
   SELECT ;
      rate_hd.rate_hd_id, rate_history.rate_md_id, rate_history.rate_dt_id, ;
      rate_hd.rate_code, rate_hd.descript, rate_hd.by_time, ;
      rate_hd.IsMedicaid, rate_hd.Bill_type, ;
      rate_history.rate_grp, ;
      rate_history.rate, rate_history.eff_date ;
   FROM ;
      rate_hd, rate_history ;
   WHERE ;
      rate_hd.rate_hd_id   = rate_history.rate_hd_id ;
   ORDER BY ;
      rate_hd.rate_code, rate_history.rate_grp, rate_history.eff_date DESC ;
   INTO CURSOR ;
      Rates_cur
      
      
	IF _TALLY = 0 
		RETURN FAIL("Check Rate Code Setup files. There are No records")
	ENDIF
	
	***	The SAME Rate_grp + Eff. Date combo should NOT EXIST in more than 1 record *
	*** for a specific Rate Code in the rate curs - USE LOCATE FOR WHEN SEARCHING **
	INDEX ON Rate_code + Rate_grp + DTOS(Eff_Date) DESC TAG RaGrEf UNIQUE
	IF RECCO('Rates_cur') <> _TALLY
		RETURN FAIL("Check Rate Code Setup files. Rate Code & Rate Group" ;
					+ " & Effective Date is NOT all unique.")
	ENDIF

   If Used('EffTimes')
      Use in EffTimes
   EndIf
   
	SELECT ;
		rate_hd.rate_hd_id, ;
		time_md.time_md_id, ;
		time_md.eff_date, ;
		time_md.time_inc ;
	FROM ;
		rate_hd, time_md ;
	WHERE ;
		rate_hd.rate_hd_id	= time_md.rate_hd_id ;
	ORDER BY ;
		rate_hd.rate_hd_id, time_md.eff_date DESC ;
	INTO CURSOR ;
		EffTimes

   If Used('TimeUnits')
      Use in TimeUnits
   EndIf
   
	SELECT ;
		rate_hd.rate_hd_id, time_md.time_md_id, time_dt.time_dt_id, ;
		rate_hd.rate_code, rate_hd.descript, rate_hd.IsMedicaid, ;
		time_md.eff_date, time_md.descript as time_desc, time_md.time_inc, ;
		time_dt.min_time, ;
		.F. as last ;
	FROM ;
		rate_hd, time_md, time_dt ;
	WHERE ;
		rate_hd.rate_hd_id	= time_md.rate_hd_id AND ;
		time_md.time_md_id	= time_dt.time_md_id AND ;
		rate_hd.by_time ;
	ORDER BY ;
		rate_hd.rate_hd_id, ;
		time_md.eff_date, ;
		time_dt.min_time ;
	INTO CURSOR ;
		TimeUnits

	***	Close unneeded files to save resources
	use in rate_hd
	**use in rate_md
	**use in rate_dt
	use in time_md
	use in time_dt

RETURN	&& End RateList

************************************************************************************
FUNCTION InsureList

	*** Get list of all client's Primary{Prim_Sec} Insurance History ***************
	*** Filter just the Insurance we want to use. Assume there are no overlaps *****
	*** in start date & end date of an insurance record. ***************************
	***	client.client_id is also in InsStat so do not try to query it again ********
	***	Keep this out so we can get Medicaid (or other) Pending Claims and Clients *
	***	!EMPTY(pol_num) AND - We do filter this out until creating diskette, etc ***
   If Used('cli_insure') 
      Use in cli_insure
   EndIf
   
	SELECT DISTINCT ;
		InsStat.group_num,  ;
		insstat.rate_grp, ;
		ai_clien.tc_id, ;
		IIF(EMPTY(InsStat.effect_dt), {01/01/1901}, InsStat.effect_dt) ;
			AS start_dt, ;
		IIF(EMPTY(InsStat.exp_dt), DATE()-1, InsStat.exp_dt) AS end_dt ;
	FROM ;
		ai_clien, InsStat , med_pro2;
	WHERE ;
		ai_clien.client_id = InsStat.client_id AND ;
		InsStat.prim_sec = nPrim_Sec AND ;
		InsStat.Prov_id	 = med_pro2.Prov_ID AND ;
		InsStat.effect_dt <> {} ;
	ORDER BY ;
		3, 4 DESC ;
	INTO CURSOR ;
		cli_insure	

*-*		med_pro2.claimtype = '01' AND;

	IF _TALLY = 0 
		RETURN FAIL("There are No Insurance records for Provider Num "  )
	ENDIF

	INDEX ON TC_ID TAG TC_ID	&& Add Others for Rushmore needs *******************

RETURN	&& End InsureList

***	Previous functions were Utility setup cursors, Now comes the fun part **********
************************************************************************************
FUNCTION PreSelEncs
PRIVATE iicond

	*** Creating Pre-select combo cursor *******************************************
	iicond = IIF(EMPTY(cprog), "", " AND ai_enc.program = cProg" ) + ;                      
			IIF(EMPTY(cSite), "", " AND ai_enc.site = cSite" ) + ;                      
			IIF(EMPTY(cTeam), "", " AND ai_enc.team = cTeam" )
			
	iidate=dStartDate
   
   If Used('enc_cur1') 
      Use in enc_cur1
   EndIf
   
	SELECT ;
		ai_enc.act_dt, ;
		ai_enc.act_id, ;
		ai_enc.beg_tm, ;
		ai_enc.beg_am, ;
		ai_enc.date_compl, ;
		ai_enc.end_tm, ;
		ai_enc.end_am, ;
		ai_enc.enc_id, ;
		ai_enc.program AS enc_prog, ;
		ai_enc.serv_cat, ;
		ai_enc.site AS enc_site, ;
		ai_enc.tc_id, ;
		ai_enc.worker_id, ;
		ai_enc.team ;
	FROM ;
		ai_enc;
	WHERE ;
		ai_enc.act_dt >= iidate  AND ;
		ai_enc.act_dt <= dEndDate  ;
		&iicond ;
	INTO CURSOR ;
		enc_cur1 

	IF _TALLY = 0 
		RETURN FAIL("Check Encounters. There are No records.")
	ENDIF

RETURN	&& End PreSelEncs

************************************************************************************
FUNCTION MatchInsur

	*** Creating Pre-select combo cursor *******************************************
	*** enc_cur1 variables were put in original enc_site query to pass them down **
	*** to this one ****************************************************************
	*** The two rate_grp DO NOT HAVE TO BE in this query ***************************
	If Used('enc_cur2') 
      Use in enc_cur2
   EndIf
   
	SELECT DISTINCT ;
		cli_insure.*, ;
		cli_insure.rate_grp as cli_grp, ;
		enc_cur1.worker_id, ;
		enc_cur1.team , ;
		enc_cur1.act_id, ;
		enc_cur1.act_dt, ;
		enc_cur1.beg_tm as enc_beg_tm, ;
		enc_cur1.beg_am as enc_beg_am, ;
		enc_cur1.date_compl, ;
		enc_cur1.end_tm as enc_end_tm, ;
		enc_cur1.end_am as enc_end_am, ;
		enc_cur1.enc_prog, ;
		enc_cur1.enc_site, ;
		enc_cur1.enc_id, ;
		enc_cur1.serv_cat, ;
		enc_cur1.act_dt - DOW(enc_cur1.act_dt) AS enc_wk_beg, ;
		TimeSpent(enc_cur1.beg_tm, enc_cur1.beg_am, enc_cur1.end_tm, ;
				enc_cur1.end_am) AS enc_tot_tm, ;
		prov_cur.rate_grp as prov_grp, ;
		prov_cur.cat_serv, ;
		prov_cur.def_loc, ;
		IIF(EMPTY(cli_insure.rate_grp), ;
			prov_cur.rate_grp, cli_insure.rate_grp) as RG ;
	FROM ;
		enc_cur1, cli_insure, prov_cur, rate_grp ;
	WHERE ;
		enc_cur1.tc_id				= cli_insure.tc_id ;
		AND BETWEEN(enc_cur1.act_dt, cli_insure.start_dt, cli_insure.end_dt) ;
		AND enc_cur1.enc_prog		= prov_cur.prog ;
		AND enc_cur1.enc_site		= prov_cur.site ;
		AND IIF(EMPTY(cli_insure.rate_grp), ;
				prov_cur.rate_grp	= rate_grp.code, ;
				cli_insure.rate_grp	= rate_grp.code) ;
	INTO CURSOR ;
		enc_cur2

* jss, 10/23/2000, remove these 2 line from creation of enc_cur2 cursor, since effsite_dt and 
*                  cob_site do not exist in enc_cur1 cursor
***		enc_cur1.effsite_dt, ;
***		enc_cur1.cob_site,  ;


	IF _TALLY = 0 
		RETURN FAIL("There are No matching records for Encounters & Insurance.")
	ENDIF

	***	Close unneeded files to save resources
	use in enc_cur1
	use in InsStat

RETURN	&& End MatchInsur

************************************************************************************
*** enc_cur2 now at this point contains the following (in Approx 50 fields)...
*** ... All encounters of a specific provider number that were ...
***	...	... only encounters with (site + program) recs that were assigned
***	...	...	... and queried into prov_cur (originally from med_pro3.dbf)
***	...	... ...	Other Site+Program records are not considered billable
***	... ...	billed and unbilled encounters,
***	... ...	clients that have an unempty insurance policy number,
***	... ...	the encounter's date less than Billing end date,
***	...
*** ... CLient's Client_ID
*** ... Client's TC_ID
*** ... Client's Insurance History record (Based on Encounter Date and Prim_Sec)
*** ... CLient's InsStat_ID (ID of History record for this Encounter's needs)

*** ... Insured's Rate_grp
***	...	... Rate_grp from Insurance	- CLI_GRP
***	...	... Rate_grp from Provider	- PROV_GRP
***	...	... The rate_grp we use		- RG
*** ... Insured's Bill_to (******* FUTURE *******)
*** ... 
*** ... Site for COBRA (Last Site client is Assigned base on Encounter Date)
*** ... 
*** ... Client's Rate Group (from Insurance Information above)
*** ... Provider that is being billed (Prov_ID field in Client's Insurance)
*** ... Provider Number that is being Billed. (Sent as Parameter into this PRG)
*** ... 
*** ... Encounter's ACT_ID that can link to Encounter's Services
*** ... Encounter's Service Category 
*** ... Encounter's Billing Physician
*** ... Encounter's Date
*** ... Encounter's Site (different from Assigned Site COBRA)
*** ... Encounter's Program
*** ... Encounter's starting & ending times
*** ... Encounter's amount of time spent (Not to be confused with Services TS)
*** ... Encounter's week starting date (Date of Sunday before encounter)
*** ... 
*** ... Provider's Locator code for Encounter and all Services below it
***	...	...	based on site.
*** ... Provider's Number
*** ... Provider's Category of Service (medicaid)
*** ... Provider's Specialty Code (medicaid)
*** ... Provider's Plan Code (non-medicaid)
*** ... Provider's Hospital Code (non-medicaid)
*** ... ClaimType that was added into Prov_cur
*** ... 

*** We now need to do the following ...
*** ... Delete matching Bill_ID records from Es_bill (if not new billing) ******
*** ... ...	Same for ServBill & ENC_Bill (No Trace of original billing left) ***
*** ... Combine all the encounters & services so we can get ...
*** ... ...	the rate code & procedure code from enc_serv
*** ... ...	the bill type - from the rate code
*** ... ... the amount per unit - from rate code
*** ... ... is claim billed by time - from rate code
*** ... If Recreating Claims then delete original records in 
*** ... ...	claim_hd (Unless it's (M) manually entered rec, just clear vars)
*** ... ...	claim_dt

************************************************************************************
************************************************************************************
************************************************************************************
FUNCTION ComboThem

	*** Combine Encounter(Header) and Services(Detail) records *********************
	*** Encounters with no services will have empty detail fields ******************
	*** From this cursor we will be able to link to all the billing needs & info ***
	***	enc_cur2 cursor holds most of the vital & already calculated info *********

* jss, 10/24/00, fix problem in which encounter's worker id was being used; must be service's 
	If Used('temp_serv') 
      Use in temp_serv
   EndIf
   
   If Used('all_serv') 
      Use in all_serv
   Endif
   
   **VT 02/27/2008 Dev Tick 4090  V 8.1 add ai_serv.service_id and take out ai_serv.serv_id, ;
*      ai_serv.service, ;
   
	SELECT ;
		enc_cur2.*, ;
		ai_serv.worker_id AS servworker, ;
		ai_serv.date as serv_date, ;
		TimeSpent(ai_serv.s_beg_tm, ai_serv.s_beg_am, ai_serv.s_end_tm, ;
											ai_serv.s_end_am) AS ser_tot_tm, ;
		SPACE(5) as rate_code, ;
		SPACE(5) as proc_code, ;
		0000	 as copay_ser, ;
		SPACE(5) as rate_hd_id, ;
		SPACE(5) as rate_md_id, ;
		SPACE(5) as rate_dt_id, ;
		SPACE(5) as bill_type, ;
		0000 as rate, ;
		.F. as By_time, ;
		.F. as Billed, ;
		.F. as CanBeBill, ;
      ai_serv.service_id ;
	FROM ;
		enc_cur2, ai_serv ;
	WHERE ;
		enc_cur2.act_id = ai_serv.act_id ;
	UNION ALL ;
	SELECT ;
		enc_cur2.*, ;
		SPACE(5) as SERVWORKER, ;
		{} as serv_date, ;
		0 AS ser_tot_tm, ;
		SPACE(5) as rate_code, ;
		SPACE(5) as proc_code, ;
		0000	 as copay_ser, ;
		SPACE(5) as rate_hd_id, ;
		SPACE(5) as rate_md_id, ;
		SPACE(5) as rate_dt_id, ;
		SPACE(5) as bill_type, ;
		0000 as rate, ;
		.F. as By_time, ;
		.F. as Billed, ;
		.F. as CanBeBill, ;
      0 as service_id ;
	FROM ;
		enc_cur2 ;
	WHERE ;
		!EXIST (SELECT * ;
				FROM ;
					ai_serv ;
				WHERE ;
					enc_cur2.act_id = ai_serv.act_id ) ;
	INTO CURSOR ;
		temp_serv

	INDEX on TC_ID + ACT_ID + DTOS(ACT_DT) tag TAD

	oApp.ReopenCur('temp_serv', 'all_serv')
	INDEX on TC_ID + BILL_TYPE + ACT_ID + DTOS(ACT_DT) tag TBAD ADDITIVE
	SET ORDER TO
	***	Index the table for speed but do not keep an order for Rushmore **********

RETURN	&& End ComboThem

************************************************************************************
FUNCTION GetDetail
PRIVATE fFlagFile

	SELECT All_Serv
	SCAN
		***	ALL vars assumed from All_Serv *****************************************
      ****VT 02/27/2008 Dev Tick 4090  V 8.1    All_Serv.Service = enc_serv.serv
      
	   Select enc_serv
      Go top
      LOCATE FOR ;
            All_Serv.Serv_Cat = enc_serv.serv_cat AND ;
            All_Serv.Enc_Prog   = enc_serv.prog AND ;
            All_Serv.Enc_Site = enc_serv.site And ;
            All_Serv.RG = enc_serv.rate_grp and ;
            All_Serv.Enc_id = enc_serv.enc_id and ;
            All_Serv.Service_id = enc_serv.service_id
     If Found() 
        Select all_serv  
        REPLACE ;
            All_Serv.Rate_Code with Enc_serv.Rate_Code, ;
            All_Serv.CanBeBill with Enc_serv.Can_Bill    
     EndIf
     
      Select all_serv
 		IF All_Serv.CanBeBill	&& Continue if Enc/Service is possibly billable
			m.Rate_code = All_serv.Rate_code
			m.Rate_grp	= All_serv.RG
				
			SELECT Rates_cur
			GO TOP
			LOCATE FOR ;
				m.Rate_code = Rates_cur.Rate_code AND ;
				m.Rate_Grp	= Rates_cur.Rate_grp AND ;
				All_Serv.act_dt > Rates_cur.eff_date
			
			lFound = Found()
			REPLACE ;
				All_Serv.rate WITH IIF(lFOUND, Rates_cur.rate, 0 ), ;
				All_Serv.rate_hd_id	WITH IIF(lFOUND, Rates_cur.rate_hd_id, SPACE(5)), ;
				All_Serv.rate_md_id	WITH IIF(lFOUND, Rates_cur.rate_md_id, SPACE(5)), ;
				All_Serv.rate_dt_id	WITH IIF(lFOUND, Rates_cur.rate_dt_id, SPACE(5)), ;
				All_Serv.bill_type	WITH IIF(lFOUND, Rates_cur.bill_type,  SPACE(5)), ;
				All_Serv.by_time	WITH IIF(lFOUND, Rates_cur.by_time,	.F.)
			SELECT All_Serv
		ENDIF
	
	ENDSCAN

RETURN	&& End GetDetail

************************************************************************************
FUNCTION theRules
PRIVATE theProg

	***	Make cursor that will hold all possible claims -- called ToBill_cur
	*** Get List of All Billing Rules needed for this session
	***	Bill_type was assigned in GetDetails()
	
	***	Mult records for only encounters with services and only for clinic ** ??? **
	***	This query may have to be adjusted - How will weekly and monthly rules work?
	***	All act_id marked, but claim has only info(procs) from 1 act_id not all. ***
	***	REMOVED - All_Serv.act_dt as Date

	=MakeToBill()
	
	*** List of All Billing Templates that we need for current set of records (All_Serv)
   If Used('BillWhat') 
      Use in BillWhat
   EndIf
   
	SELECT DISTINCT ;
		All_serv.bill_type, ;
		BillType.template ;
	FROM ;
		All_serv, BillType ;
	WHERE ;
		All_Serv.CanBeBill AND ;
		All_serv.bill_type = BillType.Code AND ;
		!EMPTY(All_serv.bill_type) ;
	INTO CURSOR ;
		BillWhat
	
	SCAN
*		theProg = ALLTRIM(BillWhat.template)
*		IF !EMPTY(theProg)
			DO COBBILL with BILL_TYPE
			IF _TALLY > 0
				SELECT ToBill_cur
				APPEND FROM DBF('temp_rec') 
				USE in temp_rec
			ENDIF
			SELECT BillWhat		&& Go Back to BillWhat cursor to continue loop *****
*		ENDIF
	ENDSCAN

	***	Time Chart - Calculates units for claims that are billed by time *********** 
	SELECT ToBill_cur

	SCAN FOR by_time
		nunits = CalcUnit(ToBill_cur.rate_hd_id, ToBill_cur.sum_ser_tm, ToBill_cur.act_dt)
		IF nUnits !=0
			replace units with nunits
		ELSE
			DELETE
		ENDIF
	ENDSCAN

	***	Here we will automatically generate default co-payment amounts ??? *********

RETURN	&& End theRules
	
************************************************************************************
FUNCTION MakeToBill
		SELECT 0
      If Used('tempit') 
         Use in tempit
      EndIf
      If Used('ToBill_Cur') 
         Use in ToBill_Cur
      EndIf
    
      SELECT ALL_SERV 
      
		SELECT ;
			ALL_SERV.* ,;
			000000 as EncBilled, ;
			000000 as SUM_SER_TM, ;
			000000 as NUM_SER, ;
			000 as Units, ;
			SERV_DATE as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill ;
		FROM ;
			ALL_SERV ;
		WHERE .F.;
		INTO CURSOR tempit
		
		INDEX ON Cat_Serv + ;
				DTOS(act_dt) + ;
				DTOS(date_compl) TAG CSLNDAC

		oApp.ReOpenCur('tempit', 'ToBill_Cur')
		SET ORDER TO TAG CSLNDAC
			
RETURN	&& MakeToBill

************************************************************************************
FUNCTION COBBill
PARAMETER cBillType
PRIVATE nunits
*** Grouping is to get sum of service time of all COBRA services in ****************
***	same (SERVICE DATE NOT ENC_DATE) day, same client, and same rate code. *********
***	User SHOULD NOT be able to type in different serv_date than enc_date ***********
*** RATE_CODE must be same for all records (At least for the same client) **********

      If Used('t_rec') 
         Use in t_rec
      EndIf
      
      SELECT ;
         SUM(iif(billed,1,0)) as EncBilled, ;
         SUM(SER_TOT_TM) as SUM_SER_TM, ;
         COUNT(*) as NUM_SER, ;
         TC_ID, RATE_CODE, ACT_DT ;
      FROM ;
         ALL_SERV ;
      WHERE ;
         All_Serv.CanBeBill AND ;
         Bill_Type = cBillType AND ;
         !EMPTY(All_Serv.Rate_Code) AND ;
         !EMPTY(All_Serv.Rate) ;
      GROUP BY ;
         TC_ID, RATE_CODE, ACT_DT ;
      HAVING ;
         sum_ser_tm > 0 ;
      INTO CURSOR ;
         t_rec
         
             
      If Used('temp_rec') 
         Use in temp_rec
      EndIf
      
      SELECT distinct ;
         t_rec.EncBilled, ;
         t_rec.SUM_SER_TM, ;
         t_rec.NUM_SER, ;
         000 as Units, ;
         SERV_DATE as Claim_dt, ;
         'D' as Flag_dt, ;
         .T. as ToBill, ;
          ALL_SERV.tc_id, ;
          all_serv.RATE_CODE,;
          all_serv.ACT_DT, ;
          all_serv.serv_date, ;
          all_serv.rate_hd_id ,;
          all_serv.bill_type, ;
          all_serv.By_time, ;
          all_serv.CanBeBill ;
      FROM ;
         ALL_SERV, ;
         t_rec ;
      WHERE ;
         all_serv.tc_id = t_rec.tc_id and ;
         all_serv.RATE_CODE = t_rec.rate_code and;
         all_serv.ACT_DT =t_rec.act_dt and;
         All_Serv.CanBeBill AND ;
         Bill_Type = cBillType AND ;
         !EMPTY(All_Serv.Rate_Code) AND ;
         !EMPTY(All_Serv.Rate) ;
      INTO CURSOR ;
         temp_rec
         
Use in t_rec

***	This used to be a check, but now it is not
***	!EMPTY(All_Serv.Proc_Code) AND

RETURN	&& COBRABill

************************************************************************************
***	When we want to leave Billing we show message 
************************************************************************************
FUNCTION Fail
Para cMessage
	 If !Used('UNITS_CUR')
      Create Cursor units_cur (tc_id char(10))
   EndIf
      
   oApp.Msg2User("OFF")
   oApp.Msg2User("MESSAGE",cmessage)
RETURN .F.

*************************************************************************************
*** Now calculate billable units per worker per team ********************************
*************************************************************************************
FUNCTION WORKERTM
* get the combined time each worker spent with each billable client, 
* combined time for each client and calculated amount for units 
* for each client

* jss, 10/24/00, use servworker, not the encounter's worker
If Used('work_tm') 
    Use in work_tm
EndIf

If Used('temp_units') 
    Use in temp_units
EndIf

If Used('work_units') 
    Use in work_units
EndIf

If Used('ytd_units') 
   Use in ytd_units
EndIf

If Used('units_t') 
   Use in units_t
EndIf

If Used('units_cur') 
   Use in units_cur
EndIf

SELECT ;
	all_serv.servworker AS worker_id , ;
	all_serv.tc_id , ;
	all_serv.team      , ;
	all_serv.serv_date , ;
	SUM(all_serv.ser_tot_tm) AS work_tm, ;
	tobill_cur.sum_ser_tm, ;
	tobill_cur.units ;
FROM ;
	all_serv, tobill_cur ;
WHERE ;
	all_serv.tc_id = tobill_cur.tc_id AND ;
	all_serv.serv_date = tobill_cur.serv_date AND ;
	all_serv.CanBeBill AND ;
	tobill_cur.CanBeBill ;
GROUP BY ;
	all_serv.team, all_serv.servworker, all_serv.tc_id, all_serv.serv_date ,;
   tobill_cur.sum_ser_tm,  tobill_cur.units ;
ORDER BY ;
	all_serv.serv_date, all_serv.team, all_serv.servworker, all_serv.tc_id ;
INTO CURSOR ;
	work_tm

* calculate the fraction of total time each worker spent 
* with each client from total for a client a day.
* summarise by worker

* jss, 10/24/00: for work_units, use CALCUNIT() with work_tm
SELECT ;
	work_tm.team, ;
	work_tm.worker_id, ;
	work_tm.serv_date, ;
	ToBill_cur.rate_hd_id, ;
	ToBill_cur.act_dt , ;
   work_tm.work_tm ;
FROM ;
	work_tm, tobill_cur ;
WHERE ;
	work_tm.tc_id = tobill_cur.tc_id AND ;
	work_tm.serv_date = tobill_cur.serv_date ;
INTO CURSOR ;
	temp_units

SELECT ;
	team, ;
	worker_id, ;
	serv_date, ;
	SUM(CalcUnit(rate_hd_id, work_tm, act_dt)) as work_units, ;
	SUM(work_tm) AS work_tm ;
FROM ;
	temp_units ;
GROUP BY ;
	team, worker_id, serv_date;
INTO CURSOR ;
	work_units
	
* summarise by team by year to date
SELECT ;
	team      , ;
	SUM(work_units) AS ytd_units ;
FROM ;
	work_units ;
WHERE ;
	BETWEEN(serv_date, iidate, dEndDate) ;
GROUP BY ;
	team ;
INTO CURSOR ;
	ytd_units

INDEX ON team TAG team

* prepare final reporting cursor
SELECT ;
	team, ;
	worker_id, ;
	SUM(work_units) as udtot ;
FROM ;
	work_units ;
WHERE ;
	BETWEEN(serv_date, dStartDate, dEndDate) ;
GROUP BY ;
	team, worker_id;
INTO CURSOR ;
	units_t
	
Select ;
      IIF(!EMPTY(units_t.team), UPPER(teams.descript), "* No Team Entered") as team_desc, ;
      Padr(oApp.FormatNAME(Staffcur.last , Staffcur.first), 45, " ") as staff_name, ; 
      units_t.*, ;
      ytd_units.ytd_units, ;
      cTitle as cTitle, ;
      Crit as Crit, ;   
      cDate as cDate, ;
      cTime as cTime, ;
      dDate_from as Date_from, ;
      dDate_to as Date_to ;
   from units_t;
      inner join staffcur on ;
         units_t.worker_id = staffcur.worker_id ;
      left outer join ytd_units on ;
         units_t.team = ytd_units.team ;   
      left outer join teams on ;
         units_t.team = teams.code ;
   Into cursor units_cur ;
   order by 1, 2

SELECT units_cur

RETURN IIF(RecCount("units_cur") = 0, .F., .T.)
*********************************************************
FUNCTION TimeSpent
PARAMETER cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
PRIVATE nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
            0, VAL(LEFT(cEnd_tm,2))) + ;
            IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
            0, VAL(LEFT(cBeg_tm,2))) + ;
            IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes =    (nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
         (nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes)
************************************************************************************
*** Calculate Number of Units of Service *******************************************
***   =CalcUnit(ToBill_cur.rate_hd_id, ToBill_cur.sum_ser_tm, ToBill_cur.act_dt) *****
************************************************************************************
FUNCTION CalcUnit
PARAMETER cRate_HD_ID, nTime, dDate1
PRIVATE cTime_MD_ID, nTime_Inc, nCount, nMaxTime, nSaveArea

   nCount      = 0
   nMaxTime   = 0
   nSaveArea   = SELECT()

   ***   Get Time_Md_Id of time period we are using for this rate code (Rate_Hd_ID) **
   SELECT EffTimes
   GO TOP
   LOCATE FOR ;
      cRate_HD_ID = EffTimes.Rate_Hd_id AND ;
      dDate1 >= EffTimes.eff_date

   IF FOUND()
      cTime_MD_ID = EffTimes.Time_MD_ID
      nTime_Inc   = EffTimes.Time_Inc

      ***   With current Rate code & time period, locate first record on chart **********
      SELECT TimeUnits
      GO TOP
      LOCATE FOR ;
         cRate_HD_ID = EffTimes.Rate_Hd_id AND ;
         cTime_MD_ID = EffTimes.Time_MD_ID

      IF FOUND()
         ***   Count units while each period is passed *************************************
         SCAN WHILE ;
            TimeUnits.rate_hd_id = cRate_HD_ID AND ;
            TimeUnits.time_md_id = cTime_MD_ID AND ;
             nTime >= TimeUnits.min_time AND ;
             !EOF()

            nCount = nCount + 1
            nMaxTime = MIN_TIME
         ENDSCAN

         *** If all periods are passed calc rest of units to be added to current total ***
         IF TimeUnits.rate_hd_id = cRate_HD_ID OR ;
               TimeUnits.time_md_id = cTime_MD_ID OR ;
               dDate1 >= TimeUnits.eff_date OR !EOF()
            nCount = nCount + INT((nTime - nMaxTime) / nTime_Inc)
         ENDIF

      ENDIF

   ENDIF

   SELECT (nSaveArea)
RETURN nCount   && CalcUnit
