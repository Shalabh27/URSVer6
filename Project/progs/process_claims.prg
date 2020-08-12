************************************************************************************
*** Create claims for all billings depending on Paramters and procpara.dbf record **
************************************************************************************
PARAMETER ;
			cBill_ID, cProv_ID, cProv2_ID, cOver_90, ;
			dStartDate, dEndDate, ;
			lRebill, lNewBill, lReBillAll, ;
			nPrim_sec

PUBLIC m.bill_ID, m.IsMedicaid, m.dt, m.tm, lReProcess, cClaimType, ;
	lNon_R, nMaxClaims, lHome_Site, nSum_time, cClaimCode, cProv_Num

m.bill_id    = space(10) 	&& Re-assigned in Startlog function
m.IsMedicaid = .F.			&& Re-assigned in ProvList function


cAxis2Use    = '1'
cClaimCode   = ""
cClaimType   = ""
cDef_Phys    = ""
cPrLicense   = ""
cPr_Tax_id   = ""
cPr_Type     = ""
cProv_Num    = ""
lBreakByDay  = .F.
lNon_R       = .f.
lReProcess   = !EMPTY(cBill_ID)
nLate_Days   = 0
nMaxClaims   = 0
nSuccess     = 0
lMental      = .f.

PRIVATE n1, n2, n3, n4, n5, n6, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15
PRIVATE iicond, cOldBill_ID, ncount, lFound

nCount			= 0
cOldBill_ID 	= SPACE(10)

PRIVATE lAddManual, lBackFill, lAdjVoid, lAddRebill
lAddManual		= .F.
lBackFill		= .F.
lAdjVoid			= .F.
lAddRebill		= .F.

Private cMess1, cMess2
cMess1 = "Creating Medicaid Claims."
cMess2 = ""
oThermo = createobject('thermobox', cMess1, cMess2)

************************************************************************************
*** Start Claim Creating Functions *************************************************
IF !CheckPars()		&& Check Parameters and Assign starting values to variables ****
	RETURN .F.
ENDIF

*** Open needed files, locks claim files, Starts thermometer ***********************
IF !OpenAll(0, "Open files ...")
	RETURN .F.
ENDIF

*** Create Provider Cursor *********************************************************
IF !ProvList(2,"Creating provider cursor ...")
	RETURN .F.
ENDIF

Set Step On 

*** Making cursor for Rates and TimeTables *****************************************
IF !RateList(4,"Creating Rates & TimeTable cursor ...")
	RETURN .F.
ENDIF

*** Select all clients' names in cursor but don't use cli_cur since clients being **
*** billed may not be in security scope, be closed, or ? ***************************
IF !InsureList(8,"Select all clients' names and insurance info...")
	RETURN .F.
ENDIF

*** Pre-select all combinations of encs for current Billing Type (COBRA,ADHC,Etc.) *
*** also get site assignments & program assignments ********************************

IF !PreSelEncs(12,"Pre-select All Combinations Of Encs - Site Assignments...", ;
		lNewBill, lReBill)
	RETURN .F.
ENDIF

*** Find most recent site assignment preceding each encounter **********************
IF !RecentSite(16,"Find Most Recent Site Preceding Each Enc...")
	RETURN .F.
ENDIF

*** unmark encounters as billed so they can be billed again ************************
IF !MatchInsur(20,"Find Insurance History Record Matching Enc Date...")
	RETURN .F.
ENDIF
*** See comments in MatchInsur to see what information we have at this time

*** Delete allready billed recs if recreating - !EMPTY(cBillID) ********************
IF !ClearIDs(24,"Deleting existing records in ES_Bill")
	RETURN .F.
ENDIF

*** Delete existing claim recs if recreating - !EMPTY(cBillID) *********************
IF !ClearClaim(28,"Delete old claims for same period...")
	RETURN .F.
ENDIF

*** ********************************************************************************
IF !ComboThem(32,"Combining Encounters and service_id Records...")
	RETURN .F.
ENDIF


*** Getting Rate Codes, Procedure codes, then rates ********************************
IF !GetDetail(36,"Geting Rates and Procedures...")
	RETURN .F.
ENDIF


*** Calculate all ******************************************************************
IF !theRules(40,"Preparing Claims to be billed...")
	RETURN .F.
ENDIF

*** Get new Bill ID. Leave if No Good **********************************************
IF !StartLog(44,"Inserting into ClaimLog...")
	RETURN .F.
ENDIF

*** ********************************************************************************
IF !DiagCurs(45, "Prepare Default Diagnoses..")
	RETURN .F.
ENDIF

*** ********************************************************************************
IF !GenClaims(46, "Generate Claims Information..")
	RETURN .F.
ENDIF

*** Mark Billed - act_id, Serv_id, Invoice, etc. ***********************************
IF !MarkBilled(50, "Mark Claims Billed..")
	RETURN .F.
ENDIF

************************************************************************************
*** Start Claim Reprocessing, Rebilling, Etc Functions *****************************

IF lNewBill
	*** Create claim_hd & claim_dt recs for manually typed claims **********************
	lAddManual = Manual()
	
	*** Fills Medicaid # for claims where client did NOT have CINN# AND has one now ****
	lBackFill = BackFill(m.bill_id, cOver_90)
	
	*** Create adjust/void claims only for previously sent claims (NOT REBILLING)*******
	lAdjVoid = Claim_AV(m.bill_id, cOldBill_ID)
ENDIF

*** Close the thermometer **********************************************************
lCleanThermo = .f.
lCleanThermo = WEXIST('thermometer')

   IF lCleanThermo
      oThermo.Release
   ENDIF

*** Stamp log record COMPLETED and Print Report ************************************
SELECT claimlog

IF nCount > 0 OR lAddManual OR lBackFill OR lAdjVoid OR lAddRebill
	REPLACE COMPLETED  WITH .T.

Dimension aSelvar[1,1]

aSelvar[1,1] = ''

Do rpt_claims with  ;
   cClaimType, ;
   claimlog.log_id, ;
   claimlog.prov_id, ;
   claimlog.prov2_id, '', ;
   claimlog.from_date, ;
   claimlog.thru_date, ;
   .t., ;            && Preview     
   aSelvar, ;        && select parameters from selection list
   1, ;
  'All Claims', ;
  'All'
Else 
  Delete 
  oApp.msg2user('NOTFOUNDG')
EndIf 

RETURN	&& End CLAIMS3.PRG


*** ********************************************************************************
*** The following are the functions for billing ************************************
*** ********************************************************************************
FUNCTION CheckPars
	*** cBill_ID empty only when billing claims for the first time *****************
	*** If filled then we are recreating claims that were billed but no disk sent **

	IF TYPE("cBill_ID") <> "C" OR EMPTY(cBill_ID)
		cBill_ID = SPACE(10)
	ENDIF

	*************** If Recreating **************************************************
	IF !EMPTY(cBill_ID)
		=OpenFile("claimlog", "log_id")
		IF SEEK(cBill_ID)
			dStartDate	= claimlog.from_date
			dEndDate	= claimlog.thru_date
			cProv_ID	= claimlog.prov_id
			cProv2_ID	= claimlog.prov2_id
			lNewBill    = !claimlog.rebillonly
			lRebill		= claimlog.make_rebil
			lRebillAll  = claimlog.rebill_all
			nPrim_sec	= claimlog.prim_sec
		ELSE
			WAIT WINDOW "You'd better check it - something's wrong - NOT FOUND cBill_ID"
		ENDIF
	*************** If New Billing *************************************************
	ELSE
		IF TYPE("lNewBill") <> "L"
			lNewBill = .T.
		ENDIF

		IF TYPE("lReBill") <> "L"
			lReBill	= .T.
		ENDIF

		IF TYPE("lReBillAll") <> "L"
			lReBillAll = .F.
		ENDIF

		IF TYPE("dStartDate") <> "D"
			dStartDate = {}
		ENDIF

		IF TYPE("dEndDate") <> "D"
			dEndDate = DATE() - DAY(DATE())
		ENDIF

		IF TYPE("cProv_ID") <> "C"
			cProv_ID = SPACE(LEN(claimlog.prov_id))
		ENDIF

		IF TYPE("cProv2_ID") <> "C"
			cProv2_ID = SPACE(LEN(claimlog.prov2_id))
		ENDIF

		IF TYPE("cOver_90") <> "C"
			cOver_90 = '5'
		ENDIF

		IF TYPE("nPrim_sec") <> "N"
			nPrim_sec = 1		&& Default to PRIMARY Insurance Billing ****
		ENDIF

	ENDIF

	=OpenFile("med_pro2","prov2_id")
	=SEEK(cProv2_ID,"MED_PRO2")
	IF FOUND()
		cClaimCode = MED_PRO2.claimtype
		lMental = MED_PRO2.mental
	ELSE
		RETURN FAIL("Provider number does not exist in Provider file?")
	ENDIF

	=OpenFile("procpara")	&& Table will hold more parms, be user changed in future ***
	LOCATE FOR CODE = cClaimCode
	lFound = FOUND()
	IF lFound
		cCLaimType	= procpara.claimtype
		nMaxClaims	= procpara.max_num
		lNon_R		= procpara.Non_r_line
		lHome_Site	= procpara.home_site
		nSum_time	= procpara.sum_time
		nLate_Days	= procpara.late_days
		IF nLate_Days = 0
			nLate_Days = 90
		ENDIF
		use in procpara
	ELSE
		RETURN FAIL("Maximum number of Claims per Invoice does not Exist.")
	ENDIF

RETURN && End CheckPars

************************************************************************************
FUNCTION OpenAll						
PARAMETER nPercent, cMessage

	oThermo.show
	oThermo.refresh(cMessage, nPercent)


	=OpenFile("claim_hd") 				&& claims header ***************************
	=OpenFile("claim_dt") 				&& claims details **************************
	=OpenFile("Es_bill","Enc_Ser")	 	&& Serv_id of Billed Encounters & service_ids *

	IF !(FLOCK("claim_hd") AND FLOCK("claim_dt") AND FLOCK("Es_bill"))
		oApp.Msg2User("NOLOCK2")
		oThermo.Release
		RETURN .F.						&& leave failed billing ********************
	ELSE
		SELECT claim_hd
		UNLOCK
		SELECT claim_dt 
		UNLOCK
		SELECT Es_bill
		UNLOCK
	ENDIF

	* BK 1/17/2007 - make sure close enc_serv as is the name of cursor in encounters and services report
	IF USED('enc_serv')
		USE IN enc_serv
	ENDIF
	
	=OpenFile("InsStat") 				&& client's insurance status ***************
	=OpenFile("diagnos") 				&& diagnosis *******************************
	=OpenFile("med_proc") 				&& medicaid procedure codes ****************
	=OpenFile("rate_grp") 				&& rating group assignments ****************
	=OpenFile("enc_serv")				&& encs/service_ids procs & rates assignments *
      										*** serv_cat & prog & site & rate_grp *
      										*** & code & serv **************************
   
	SELECT staffcur
	SET ORDER TO worker_id
	
	=OpenFile("serv_loc", "code") 	&& service_id locations
	=OpenFile("ref_prov", "code") 	&& referring providers

	=OpenFile("ai_enc", .F., "the_enc") 	&& encounters ******************************
	=OpenFile("ai_serv", .F., "the_serv") && service_ids ********************************

	*** ****************************************************************************
	=OpenFile(gcSiteFile, .F., "the_site") && site assignments ************************

	*** ****************************************************************************

	* Create a cursor of default procedure codes for service_ids where one was not entered
**   Serv_Cat, Prog, Site, Rate_Grp, code, proc_code, modifier, location ;

	IF USED('def_proc')
	   USE IN def_proc
	ENDIF

	SELECT ;
		Serv_Cat, Prog, Site, Rate_Grp, enc_id, proc_code, modifier, location ;
	FROM ;
		enc_serv ;
	WHERE ;
		EMPTY(serv) AND ;
		can_bill AND ;
		!EMPTY(proc_code) ;
	INTO CURSOR ;
		def_proc

	*INDEX ON Serv_Cat + Prog + Site + Rate_Grp + code TAG spsrc
   *   INDEX ON Serv_Cat + Prog + Site + Rate_Grp + Str(enc_id, 4, 0) TAG spsrc
   
*!*	BK 12/14/2005 - use new enc code
*!*		INDEX ON Serv_Cat + Prog + Site + Rate_Grp + code TAG spsrc
	INDEX ON Serv_Cat + Prog + Site + Rate_Grp + STR(enc_id, 4, 0) TAG spsrc
   
RETURN	&& End OpenAll


************************************************************************************
FUNCTION ProvList
PARAMETER nPercent, cMessage

oThermo.refresh(cMessage, nPercent)

	*** Files not opened in openall function - close at end of ProvList ************
	=OpenFile("med_prov") 				&& Provider header assignments *************
	=OpenFile("med_pro2") 				&& Provider middle assignments *************
	=OpenFile("med_pro3") 				&& Provider lower  assignments *************
	=OpenFile("Site") 					&& Site ************************************
	=OpenFile("Program") 				&& Program *********************************

	*************** Creating Provider Table *************************************
	SELECT ;
		med_prov.prov_id,    med_pro2.prov2_id,   med_pro3.prov3_id, ;
		med_prov.name,       med_prov.IsMedicaid, med_prov.InsType, ;
		med_prov.Def_period, med_prov.Signature,  med_prov.Auth_by, ;
		med_prov.processprg, ;
		med_pro2.prov_num,   med_pro2.descript,   med_pro2.claimtype, ;
		med_pro2.tax_id,     med_pro2.def_phys, ;
		med_pro2.street1,    med_pro2.street2, ;
		med_pro2.city,       med_pro2.st,         med_pro2.zip, ;
		med_pro2.phone,		med_pro2.contact,    med_pro2.mag_input, ;
		med_pro3.site,       med_pro3.prog,       med_pro3.rate_grp, ;
		med_pro3.cat_serv,   med_pro3.clin_spec,  med_pro3.def_loc, ;
		med_pro3.plan_code,  med_pro3.hosp_code ;
	FROM ;
		med_prov, med_pro2, med_pro3 ;
	WHERE ;
		med_prov.prov_id  = med_pro2.prov_id AND ;
		med_pro2.prov2_id = med_pro3.prov2_id AND ;
		med_prov.prov_id  = cProv_ID AND ;
		med_pro2.prov2_id = cProv2_ID ;
	INTO CURSOR ;
		Prov_cur

	*** ****************************************************************************
	*** Check for unique Site+program combo for specific Provider # ****************
	INDEX ON site + PROG TAG SITE_PROG UNIQUE
	IF RECCO('Prov_cur') <> _TALLY
		RETURN FAIL("Check Provider Setup files. Site & Programs for" ;
			+ " Provider Num " + cProv2_ID + " are NOT all unique.")
	ENDIF

	SELECT Prov_cur
	GO TOP
	SCATTER MEMVAR FIELD cat_serv, IsMedicaid
	cDef_Phys = prov_cur.def_phys
	cProv_Num = prov_cur.prov_num

	*** ****************************************************************************
	*** This may be NY specific???
	*** These 3 fields must hold = values in each rec. of the setup files **********
	SCAN
		DO CASE
		CASE m.cat_serv <> Prov_cur.cat_serv AND Prov_cur.IsMedicaid
			RETURN FAIL("Check Provider Setup files. Category of " ;
				+ "service_id are NOT all same for Provider# " + cProv_Num )
		CASE m.IsMedicaid <> Prov_cur.IsMedicaid
			RETURN FAIL("Is Medicaid field NOT all same" ;
				+ " for Provider Num " + cProv2_ID )
		ENDCASE
	ENDSCAN

	*** Close unneeded files to save resources *************************************
**	use in med_prov
**	use in med_pro2
**	use in med_pro3
**	use in site
**	use in program

RETURN	&& End ProvList


************************************************************************************
FUNCTION RateList
PARAMETER nPercent, cMessage

oThermo.refresh(cMessage, nPercent)

	=OpenFile("rate_hd") 				&& rate header assignments  ****************
*	=OpenFile("rate_md") 				&& rate middle assignments  ****************
*	=OpenFile("rate_dt") 				&& rate lower  assignments  ****************
	=OpenFile("rate_history") 			&& rate details  ****************
	=OpenFile("time_md") 				&& time middle assignments  ****************
	=OpenFile("time_dt") 				&& time lower  assignments  ****************

	*** Get blank rate code for Rushmore optimization instead of Empty() ***********
	cBlankRateCode = SPACE(LEN(rate_hd.rate_code))

	*** Creating Rate History Table ************************************************
	** BK 12/23/2005 - replaced using rate_md and rate_dt with single rate_history
*!*		SELECT ;
*!*			rate_hd.rate_hd_id, rate_md.rate_md_id, rate_dt.rate_dt_id, ;
*!*			rate_hd.rate_code, rate_hd.descript, rate_hd.by_time, ;
*!*			rate_hd.IsMedicaid, rate_hd.Bill_type, ;
*!*			rate_md.rate_grp, ;
*!*			rate_dt.rate, rate_dt.reimb_rate, rate_dt.eff_date ;
*!*		FROM ;
*!*			rate_hd, rate_md, rate_dt ;
*!*		WHERE ;
*!*			rate_hd.rate_hd_id	= rate_md.rate_hd_id AND ;
*!*			rate_md.rate_md_id	= rate_dt.rate_md_id ;
*!*		ORDER BY ;
*!*			rate_hd.rate_code, rate_md.rate_grp, rate_dt.eff_date DESC ;
*!*		INTO CURSOR ;
*!*			Rates_cur

	SELECT ;
		rate_hd.rate_hd_id, ;
		rate_history.rate_md_id, ;
		rate_history.rate_dt_id, ;
		rate_hd.rate_code, ;
		rate_hd.descript, ;
		rate_hd.by_time, ;
		rate_hd.IsMedicaid, ;
		rate_hd.Bill_type, ;
		rate_history.rate_grp, ;
		rate_history.rate, ;
		rate_history.reimb_rate, ;
		rate_history.eff_date ;
	FROM ;
		rate_hd ;
		JOIN rate_history ON ;
			rate_hd.rate_hd_id = rate_history.rate_hd_id ;
	ORDER BY ;
		rate_hd.rate_code, ;
		rate_history.rate_grp, ;
		rate_history.eff_date DESC ;
	INTO CURSOR ;
		Rates_cur

	IF _TALLY = 0
		RETURN FAIL("Check Rate Code Setup files. There are No records")
	ENDIF

	*** The SAME Rate_grp + Eff. Date combo should NOT EXIST in more than 1 record *
	*** for a specific Rate Code in the rate curs - USE LOCATE FOR WHEN SEARCHING **
	INDEX ON Rate_code + Rate_grp + DTOS(Eff_Date) DESC TAG RaGrEf UNIQUE
	IF RECCO('Rates_cur') <> _TALLY
		RETURN FAIL("Check Rate Code Setup files. Rate Code & Rate Group" ;
					+ " & Effective Date is NOT all unique.")
	ENDIF

	*** ****************************************************************************
	SELECT ;
		rate_hd.rate_hd_id, ;
		time_md.time_md_id, ;
		time_md.eff_date, ;
		time_md.time_inc, ;
		time_md.unit_inc ;
	FROM ;
		rate_hd, time_md ;
	WHERE ;
		rate_hd.rate_hd_id	= time_md.rate_hd_id ;
	ORDER BY ;
		rate_hd.rate_hd_id, time_md.eff_date DESC ;
	INTO CURSOR ;
		EffTimes

	*** Creating a time unit table *************************************************
	SELECT ;
		rate_hd.rate_hd_id, time_md.time_md_id, time_dt.time_dt_id, ;
		rate_hd.rate_code, rate_hd.descript, rate_hd.IsMedicaid, ;
		time_md.eff_date, time_md.descript as time_desc, time_md.time_inc, ;
		time_dt.min_time, time_dt.increment, ;
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

	*** Close unneeded files to save resources *************************************
**	use in rate_hd
**	use in rate_md
**	use in rate_dt
	use in time_md
	use in time_dt

RETURN	&& End RateList


************************************************************************************
FUNCTION InsureList
PARAMETER nPercent, cMessage

   oThermo.refresh(cMessage, nPercent)
   
	*** Get list of all client's Primary{Prim_Sec} Insurance History ***************
	*** Filter just the Insurance we want to use. There are no overlaps ************
	*** in start date & end date of an insurance record. ***************************
	*** client.client_id is also in InsStat so do not try to query it again ********
	*** Keep this out so we can get Medicaid (or other) Pending Claims and Clients *
	*** !EMPTY(pol_num) AND - We do filter this out until creating diskette, etc ***

	IF used('THE_CLIEN')
		USE IN the_Clien
	ENDIF

	=OpenFile("ai_clien", "client_id", "the_clien")

	*** ****************************************************************************

	*** *** Previously had client.med_dob & client.med_sex *************************
	*** Creating client list with insurance information ****************************
	
	**VT 08/17/2011 AIRS-141 Added ma_pending for exclude clients services from billing
	SELECT ;
		UPPER(PADR(LTRIM(oApp.FormatName(client.last_name, client.first_name, ;
			client.mi)),40)) AS name, ;
		client.dob as cli_dob, ;
		client.sex as cli_sex, ;
		IIF(InsStat.ins_sex = 1, "M", IIF(InsStat.ins_sex = 2, "F", " ")) as med_sex, ;
		InsStat.ins_dob as med_dob, ;
		InsStat.*, ;
		the_clien.tc_id, ;
		IIF(EMPTY(InsStat.effect_dt), {01/01/1901}, InsStat.effect_dt) ;
			AS start_dt, ;
		IIF(EMPTY(InsStat.exp_dt), DATE()-1, InsStat.exp_dt) AS end_dt ;
	FROM ;
		client, the_clien, InsStat ;
	WHERE ;
		client.client_id = the_clien.client_id AND ;
		client.client_id = InsStat.client_id AND ;
		InsStat.Prov_id  = cProv_ID AND ;
		InsStat.effect_dt <> {} ;
	 and 	InsStat.ma_pending = 0;
	ORDER BY ;
		InsStat.client_id, InsStat.effect_dt DESC ;
	INTO CURSOR ;
		cli_insure readwrite
		
*		InsStat.prim_sec = nPrim_sec AND ;

	IF _TALLY = 0
		RETURN FAIL("There are No Insurance records for Provider Num " + cProv2_ID )
	ENDIF
	
*!*		If oApp.gldataencrypted
*!*	      Replace cli_insure.pol_num With ;
*!*	            Iif(!Empty(cli_insure.pol_num), osecurity.decipher(Alltrim(cli_insure.pol_num)), '') All
*!*	    Endif

	INDEX ON TC_ID TAG TC_ID	&& Add Others for Rushmore needs *******************

	*** Close unneeded files to save resources *************************************
**	USE in INSSTAT
**	USE in CLIENT
	USE in THE_CLIEN

RETURN	&& End InsureList


************************************************************************************
FUNCTION PreSelEncs
PARAMETER nPercent, cMessage, lNewBill, lReBill
PRIVATE iicond

	oThermo.refresh(cMessage, nPercent)

	*** NOT EXIST ( SELECT * FROM es_bill WHERE	es_bill.act_id = the_enc.act_id AND *
	*** 			!es_bill.ReBilled ) 										****
	*** Get list of act_id & serv_id of claims that were billed but not rebilled. **
	*** Invoices previously rebilled have newer matching record	not marked rebilled*
	*** When New billing we do not want to process all these billed encs & servs ***
	*** so we will exempt them from PreSelect cursor *******************************
	*** If rec does exist in this query, it can still be overriden by next 2 Q's ***

	*** Get list of act_id & serv_id of claims that were denied & order to rebill **
	*** Filter out invoices previously rebilled. They have newer matching record ***
	*** not marked rebilled. When rebilling, to reprocess all these encs & servs as
	*** if they never billed we will add them to PreSelect cursor ******************
	*** Eventually these es_bill records will be marked as rebilled ??? and new ****
	*** es_bill records with new invoice numbers will be added *********************

	*** ****************************************************************************
*		claim_dt.proc_code as rate_code, ;

	SELECT ;
		es_bill.*, ;
		claim_dt.rate_code, ;
		claim_hd.tc_id, ;
		claim_dt.orig_inv ;
	FROM ;
		claim_dt, claim_hd, es_bill ;
	WHERE ;
		lRebill AND ;
		claim_dt.invoice	= claim_hd.invoice AND ;
		claim_hd.prov_id	= cProv_ID AND ;
		claim_hd.prov2_id	= cProv2_ID AND ;
		claim_dt.R_line AND ;
		(claim_dt.action = 1 OR ;
		  (lRebillAll AND claim_dt.status = 2 AND claim_dt.action = 0)) AND ;
		(EMPTY(claim_dt.actbill_id) OR claim_dt.actbill_id = cOldBill_ID) AND ;
		!es_bill.Rebilled AND ;
		es_bill.invoice=claim_hd.invoice AND ;
		es_bill.r_line=claim_dt.line_no ;
	INTO CURSOR ;
		do_rebill

   *** ****************************************************************************
	*** Get all es_bill records that were already billed but not rebilled and also *
	*** match the old batch num (Bill ID) for Reprocessing. ************************
	*** ****************************************************************************

*  claim_dt.proc_code as rate_code, ;

	SELECT ;
		es_bill.*, ;
		claim_dt.rate_code, ;
		claim_hd.tc_id, ;
		claim_dt.orig_inv ;
	FROM ;
		claim_dt, claim_hd, es_bill ;
	WHERE ;
		lReprocess AND ;
		claim_dt.invoice=claim_hd.invoice AND ;
		claim_hd.prov_id=cProv_ID AND ;
		claim_hd.prov2_id=cProv2_ID AND ;
		claim_dt.R_line AND ;
		!es_bill.Rebilled AND ;
		es_bill.invoice=claim_hd.invoice AND ;
		es_bill.r_line=claim_dt.line_no AND ;
		es_bill.Bill_ID=cBill_ID ;
	INTO CURSOR ;
		do_reproc

	*** ****************************************************************************
	*** Creating Pre-select combo cursor *******************************************
	*** Only Encounters up to the Billing End date, Start Date is not important ****
	*** Encounters before start date that were billed previously, but not sent *****
	*** will be picked up in later functions, after billing cursor is created ******
	*** Checking encounters that were previously billed also lessens cursor ********
	*** FINAL STEP FOR THIS PROCEDURE **********************************************
	*** ****************************************************************************
	Select ;
		the_enc.act_dt, ;
		the_enc.act_id, ;
		the_enc.beg_tm, ;
		the_enc.beg_am, ;
		IIF(!EMPTY(the_enc.bill_phys), the_enc.bill_phys, cDef_Phys) AS bill_phys, ;
		the_enc.ref_prov, ;
		the_enc.date_compl, ;
		the_enc.end_tm, ;
		the_enc.end_am, ;
		the_enc.enc_id, ;
		the_enc.modifier as enc_modif, ;
		the_enc.program AS enc_prog, ;
		the_enc.serv_cat, ;
		the_enc.site AS enc_site, ;
		the_enc.tc_id, ;
		the_enc.rate_grp, ;
		the_enc.rate_code as enc_rate, ;
		the_enc.proc_code as enc_proc, ;
		the_enc.prov_id as enc_prov, ;
		the_enc.act_loc, ;
		the_enc.bill_place, ;
		the_enc.diagnos1, ;
		the_enc.diagnos2, ;
		the_site.site AS home_site, ;
		the_site.effect_dt as effsite_dt ;
	FROM ;
		the_enc, the_site ;
	WHERE ;
		NOT (lRebill AND NOT lNewBill) AND ;
		the_enc.tc_id = the_site.tc_id AND ;
		the_enc.act_dt <> {} AND ;
		the_enc.act_dt <= dEndDate AND ;
		(the_enc.prov_id = cProv_ID OR EMPTY(the_enc.prov_id)) AND ;
		!the_enc.not_bill AND ;
		NOT EXIST (SELECT * ;
						FROM es_bill ;
					WHERE ;
						es_bill.act_id = the_enc.act_id AND ;
						!es_bill.ReBilled ) ;
   into cursor t_site1
                  
	 SELECT ;
		the_enc.act_dt, ;
		the_enc.act_id, ;
		the_enc.beg_tm, ;
		the_enc.beg_am, ;
		IIF(!EMPTY(the_enc.bill_phys), the_enc.bill_phys, cDef_Phys) AS bill_phys, ;
		the_enc.ref_prov, ;
		the_enc.date_compl, ;
		the_enc.end_tm, ;
		the_enc.end_am, ;
		the_enc.enc_id, ;
		the_enc.modifier as enc_modif, ;
		the_enc.program AS enc_prog, ;
		the_enc.serv_cat, ;
		the_enc.site AS enc_site, ;
		the_enc.tc_id, ;
		the_enc.rate_grp, ;
		the_enc.rate_code as enc_rate, ;
		the_enc.proc_code as enc_proc, ;
		the_enc.prov_id as enc_prov, ;
		the_enc.act_loc, ;
		the_enc.bill_place, ;
		the_enc.diagnos1, ;
		the_enc.diagnos2, ;
		the_site.site AS home_site, ;
		the_site.effect_dt as effsite_dt ;
	FROM ;
		the_enc, the_site ;
	WHERE ;
		the_enc.tc_id = the_site.tc_id AND ;
		the_enc.act_dt <> {} AND ;
		the_enc.act_dt <= dEndDate AND ;
		(the_enc.prov_id = cProv_ID OR EMPTY(the_enc.prov_id)) AND ;
		!the_enc.not_bill AND ;
			(EXIST (SELECT * FROM do_rebill WHERE do_rebill.act_id = the_enc.act_id) OR ;
			 EXIST (SELECT * FROM do_reproc WHERE do_reproc.act_id = the_enc.act_id) ) ;
	INTO CURSOR ;
		t_site2 ;
	HAVING ;
		the_enc.act_dt >= the_site.effect_dt

   Select * ;
   from ;
      t_site1 ;
   Union ;
   Select * ;
   from ;
      t_site2 ;
   Into Cursor ;
       enc_site1 

	IF _TALLY = 0
      Use in t_site1
      Use in t_site2
		RETURN FAIL("Check Encounters. There are No records.")
 	ENDIF

   Use in t_site1
   Use in t_site2
RETURN	&& End PreSelEncs


************************************************************************************
FUNCTION RecentSite
PARAMETER nPercent, cMessage

	oThermo.refresh(cMessage, nPercent)

	*** Only for COBRA. Site of Encounter MUST be same as client's assigned Site ***
	iicond = IIF(lHome_site, [HAVING enc_site1.enc_site = enc_site1.home_site ], [] )

	*** Slimming down encounter cursor to include only records with recent site ****
	*** Type of Care already specified in PreSelEnc function. **********************
   
	SELECT * ;
	FROM ;
		enc_site1 ;
	WHERE ;
		enc_site1.effsite_dt = ;
			(SELECT ;
				MAX(enc_site.effsite_dt) ;
			FROM						 ;
				enc_site1 enc_site ;
			WHERE ;
				enc_site.act_id = enc_site1.act_id) ;
	&iicond ;
	INTO CURSOR ;
		enc_site2

RETURN	&& End RecentSite

************************************************************************************
FUNCTION MatchInsur
PARAMETER nPercent, cMessage

	oThermo.refresh(cMessage, nPercent)

	*** Creating Pre-select combo cursor *******************************************
	*** enc_site2 variables were put in original enc_site query to pass them down **
	*** to this one ****************************************************************

	SELECT ;
		cli_insure.*, ;
		cli_insure.rate_grp as cli_grp, ;
		enc_site2.act_id, ;
		enc_site2.act_dt, ;
		enc_site2.beg_tm as enc_beg_tm, ;
		enc_site2.beg_am as enc_beg_am, ;
		enc_site2.bill_phys, ;
		enc_site2.ref_prov, ;
		enc_site2.date_compl, ;
		enc_site2.effsite_dt, ;
		enc_site2.end_tm as enc_end_tm, ;
		enc_site2.end_am as enc_end_am, ;
		enc_site2.enc_prog, ;
		enc_site2.enc_site, ;
		enc_site2.enc_id, ;
		enc_site2.serv_cat, ;
		enc_site2.enc_modif, ;
		enc_site2.enc_rate, ;
		enc_site2.enc_proc, ;
		enc_site2.home_site, ;
		enc_site2.rate_grp as enc_grp, ;
		enc_site2.act_loc, ;
		enc_site2.bill_place, ;
		enc_site2.diagnos1, ;
		enc_site2.diagnos2, ;
		enc_site2.act_dt - DOW(enc_site2.act_dt) AS enc_wk_beg, ;
		BEG_MONTH(enc_site2.act_dt) AS enc_mn_beg, ;
		TimeSpent(enc_site2.beg_tm, enc_site2.beg_am, enc_site2.end_tm, ;
				enc_site2.end_am) AS enc_tot_tm, ;
		prov_cur.rate_grp as prov_grp, ;
		prov_cur.clin_spec, ;
		prov_cur.plan_code, ;
		prov_cur.hosp_code, ;
		prov_cur.cat_serv, ;
		prov_cur.def_loc, ;
		IIF(EMPTY(enc_site2.rate_grp), ;
			IIF(EMPTY(cli_insure.rate_grp), ;
				prov_cur.rate_grp, cli_insure.rate_grp), ;
				enc_site2.rate_grp) as RG, ;
		IIF(!EMPTY(rate_grp.loc_code), ;
			rate_grp.loc_code, prov_cur.def_loc) as loc_code ;
	FROM ;
		enc_site2, cli_insure, prov_cur, rate_grp ;
	WHERE ;
		enc_site2.tc_id				= cli_insure.tc_id ;
		AND BETWEEN(enc_site2.act_dt, cli_insure.start_dt, cli_insure.end_dt) ;
		AND enc_site2.enc_prog		= prov_cur.prog ;
		AND enc_site2.enc_site		= prov_cur.site ;
		AND IIF(EMPTY(enc_site2.enc_prov), ;
				cli_insure.prim_sec = nPrim_sec, ;
				cli_insure.prov_id = enc_site2.enc_prov) ;
		AND IIF(EMPTY(enc_site2.rate_grp), ;
				IIF(EMPTY(cli_insure.rate_grp), ;
					prov_cur.rate_grp = rate_grp.code, ;
					cli_insure.rate_grp = rate_grp.code), ;
				enc_site2.rate_grp = rate_grp.code) ;
	INTO CURSOR ;
		enc_site3

*-*		IIF(EMPTY(enc_site2.enc_prov), ;
*-*			cli_insure.prov_id, enc_site2.enc_prov) as PID, ;

*	ORDER BY ;
*		cli_insure.name, ;
*		cli_insure.cli_dob, ;
*		enc_site2.act_dt

	IF _TALLY = 0
		RETURN FAIL("There are No matching records for Encounters & Insurance.")
	ENDIF

	*** Close unneeded files to save resources *************************************
	use in Enc_site1
	use in Enc_site2


RETURN	&& End MatchInsur

************************************************************************************
FUNCTION DiagCurs
PARAMETER nPercent, cMessage

	oThermo.refresh(cMessage, nPercent)
	
	=openfile('ai_diag')
	
	SELECT ;
		tc_id, diag_code, diagnos.icd9code, diagnos.hiv_icd9, diagdate ;
	FROM ;
		ai_diag, diagnos ;
	WHERE ;
		ai_diag.diag_code = diagnos.code AND ;
		IIF(lMental, !EMPTY(diagnos.dsm4code), .t.) ;
	INTO CURSOR ;
		diag_cur 

	INDEX ON tc_id + DTOS(diagdate) TAG tc_id DESC

*-*		* if cannot bill mental diag to non-mental provider, 
*-*		* replace line above with this
*-*		IIF(lMental, !EMPTY(diagnos.dsm4code), EMPTY(diagnos.dsm4code)) ;

*-*		tc_id + DTOS(diagdate) IN ;
*-*						(SELECT MAX(tc_id + DTOS(diagdate)) ;
*-*							FROM ai_diag aid ;
*-*							GROUP BY tc_id) AND ;

*-*	INDEX ON tc_id TAG tc_id 
	
RETURN	&& End DiagCurs


************************************************************************************
FUNCTION BEG_MONTH						&& This is NOT TC Specific	****************
PARAMETER dDate
PRIVATE d
	d = DTOC(dDate)
RETURN	CTOD(substr(d,1,3) + '01' + substr(d,6,5))


************************************************************************************
*** Enc_site3 now at this point contains the following (in Approx 50 fields)...
*** ... All encounters of a specific provider number that were ...
*** ...	... only encounters with (site + program) recs that were assigned
*** ...	...	... and queried into prov_cur (originally from med_pro3.dbf)
*** ...	... ...	Other Site+Program records are not considered billable
*** ... ...	billed and unbilled encounters,
*** ... ...	clients that have an unempty insurance policy number,
*** ... ...	the encounter's date less than Billing end date,
*** ... ...	If COBRA then off-site encounters have been omitted
*** ... ...	... (PreSelEncs & RecentSite) does this job but they could be merged
*** ... ...	... if assigned site isn't need for billing
*** ...
*** ... CLient's Client_ID
*** ... Client's TC_ID
*** ... Client's Insurance History record (Based on Encounter Date and Prim_Sec)
*** ... CLient's InsStat_ID (ID of History record for this Encounter's needs)
*** ... Client's DOB
*** ... Client's Sex
*** ... Client's Medicaid DOB
*** ... Client's Medicaid Sex
*** ...
*** ... Insured's Sex
*** ... Insured's DOB
*** ... Insured's Co-Payment type - leads to amount, percentage, or service_id amount
*** ... Insured's Co-Payment amount if applicable
*** ... Insured's Co-payent percetage if applicable
*** ... Insured's Rate_grp
*** ...	... Rate_grp from Insurance	- CLI_GRP
*** ...	... Rate_grp from Provider	- PROV_GRP
*** ...	... The rate_grp we use		- RG
*** ... Insured's Bill_to (*******FUTURE*******)
*** ...
*** ... Site for COBRA (Last Site client is Assigned base on Encounter Date)
*** ...
*** ... Client's Rate Group (from Insurance Information above)
*** ... Provider that is being billed (Prov_ID field in Client's Insurance)
*** ... Provider Number that is being Billed. (Sent as Parameter into this PRG)
*** ...
*** ... Encounter's act_id that can link to Encounter's service_ids
*** ... Encounter's service_id Category
*** ... Encounter's Billing Physician
*** ... Encounter's Date
*** ... Encounter's Site (different from Assigned Site COBRA)
*** ... Encounter's Program
*** ... Encounter's starting & ending times
*** ... Encounter's amount of time spent (Not to be confused with service_ids TS)
*** ... Encounter's week starting date (Date of Sunday before encounter)
*** ...
*** ... Provider's Locator code for Encounter and all service_ids below it
*** ...	...	based on site.
*** ... Provider's Number
*** ... Provider's Category of service_id (medicaid)
*** ... Provider's Specialty Code (medicaid)
*** ... Provider's Plan Code (non-medicaid)
*** ... Provider's Hospital Code (non-medicaid)
*** ... ClaimType that was added into Prov_cur
*** ...

*** We now need to do the following ...
*** ... Delete matching Bill_ID records from Es_bill (if not new billing) ******
*** ... ...	Same for ServBill & ENC_Bill (No Trace of original billing left) ***
*** ... Combine all the encounters & service_ids so we can get ...
*** ... ...	the rate code & procedure code from enc_serv
*** ... ...	the bill type - from the rate code
*** ... ... the amount per unit - from rate code
*** ... ... is claim billed by time - from rate code
*** ... If Recreating Claims then delete original records in
*** ... ...	claim_hd (Unless it's (M) manually entered rec, just clear vars)
*** ... ...	claim_dt

************************************************************************************
FUNCTION ClearIDs	
PARAMETER nPercent, cMessage
PRIVATE cTag

	oThermo.refresh(cMessage, nPercent)

	IF !EMPTY(cBill_ID)			&& If this billing is a reprocess ******************

		*** Eliminate existing es_bill recs of this batch to start fresh ***********
		*** cBill_ID is old batch number
		SELECT es_bill
		cTag = TAG()
		SET ORDER TO
		SCAN FOR ;
			es_bill.bill_id = cBill_ID ;
			AND NOT ReBilled

			REPLACE ;
				user_id WITH gcWorker, ;
				dt      WITH DATE(), ;
				tm      WITH TIME()
			DELETE
		ENDSCAN

		*** Unmark Rebilled for original es_bill recs that were REBILLED in batch **
		SCAN FOR es_bill.ActBill_ID = cBill_ID
			REPLACE ;
				Rebilled with .F., ;
				ActBill_ID with SPACE(10), ;
				user_id WITH gcWorker, ;
				dt      WITH DATE(), ;
				tm      WITH TIME()
		ENDSCAN
		SET ORDER TO (cTag)		&& replace old tag   *******************************
	ENDIF

RETURN	&& ClearIDs

************************************************************************************
FUNCTION ClearClaim
PARAMETER nPercent, cMessage

	IF !EMPTY(cBill_ID)					&& If Recreating Claims ********************
		oThermo.refresh(cMessage, nPercent)

		*** Claim_hd and Claim_dt are both locked. *********************************
		*** Eliminate traces of rebilling in original claim_dt recs that were ******
		*** linking to claims that were rebills in the Batch we are reprocessing ***
		SELECT claim_dt
		SCAN FOR claim_dt.ActBill_id = cBill_ID
			REPLACE ;
				ActBill_ID	WITH SPACE(10), ;
				user_id 	WITH gcWorker, ;
				dt      	WITH DATE(), ;
				tm      	WITH TIME()
		ENDSCAN

		*** Delete old batch of claim recs from Claim_hd & Claim_dt files **********
		*** EXCEPTION - Only remove bill_id from the claims marked Manual **********
		SELECT claim_hd
		SCAN FOR bill_id = cBill_ID
			IF man_auto <> "M"
				SELECT claim_dt
				SCAN FOR invoice = claim_hd.invoice
					REPLACE ;
						user_id WITH gcWorker, ;
						dt WITH DATE(), ;
						tm WITH TIME()
					DELETE
				ENDSCAN
				SELECT claim_hd
				REPLACE ;
					user_id WITH gcWorker, ;
					dt WITH DATE(), ;
					tm WITH TIME()
				DELETE
			ELSE
				REPLACE ;
					claim_hd.bill_id WITH "", ;
					claim_hd.user_id WITH gcWorker, ;
					claim_hd.dt WITH DATE(), ;
					claim_hd.tm WITH TIME()
			ENDIF
		ENDSCAN

		SELECT claimlog
		IF oApp.RecLock('claimlog')
			REPLACE ;
				recreated  WITH .T., ;
				user_id    WITH gcWorker, ;
				dt         WITH DATE(), ;
				tm         WITH TIME()
		ELSE
			RETURN FAIL("Couldn't Lock Claimlog File. Claims were NOT created.")
		ENDIF

		cOldBill_ID = cBill_ID
	ENDIF

RETURN	&& End ClearClaim


************************************************************************************
FUNCTION ComboThem
PARAMETER nPercent, cMessage

	oThermo.refresh(cMessage, nPercent)

	*** Combine Encounter(Header) and service_ids(Detail) records *********************
	*** Encounters with no service_ids will have empty detail fields ******************
	*** From this cursor we will be able to link to all the billing needs & info ***
	*** Enc_Site3 cursor holds most of the vital & already calculated info *********
	SELECT ;
		enc_site3.*, ;
		the_serv.serv_id, ;
		the_serv.service_id, ;
		the_serv.date as serv_date, ;
		TimeSpent(the_serv.s_beg_tm, the_serv.s_beg_am, the_serv.s_end_tm, ;
											the_serv.s_end_am) AS ser_tot_tm, ;
		the_serv.s_location, ;
		SPACE(5) as rate_code, ;
		SPACE(5) as proc_code, ;
		SPACE(2) as modifier, ;
		SPACE(2) as location, ;
		0000.00	as copay_ser, ;
		SPACE(5) as rate_hd_id, ;
		SPACE(5) as rate_md_id, ;
		SPACE(5) as rate_dt_id, ;
		SPACE(5) as bill_type, ;
		0000.00 as rate, ;
		0000.00 as reimb_rate, ;
		.F. as By_time, ;
		.F. as Billed, ;
		.F. as CanBeBill ;
	FROM ;
		enc_site3, the_serv ;
	WHERE ;
		enc_site3.act_id = the_serv.act_id ;
	UNION ALL ;
	SELECT ;
		enc_site3.*, ;
		SPACE(10) as serv_id, ;
		0 as service_id, ;
		{} as serv_date, ;
		0 AS ser_tot_tm, ;
		SPACE(2) as s_location, ;
		SPACE(5) as rate_code, ;
		SPACE(5) as proc_code, ;
		SPACE(2) as modifier, ;
		SPACE(2) as location, ;
		0000.00	as copay_ser, ;
		SPACE(5) as rate_hd_id, ;
		SPACE(5) as rate_md_id, ;
		SPACE(5) as rate_dt_id, ;
		SPACE(5) as bill_type, ;
		0000.00 as rate, ;
		0000.00 as reimb_rate, ;
		.F. as By_time, ;
		.F. as Billed, ;
		.F. as CanBeBill ;
	FROM ;
		enc_site3 ;
	WHERE ;
		!EXIST (SELECT * ;
				FROM ;
					the_serv ;
				WHERE ;
					enc_site3.act_id = the_serv.act_id ) ;
	INTO CURSOR ;
		temp_serv

	SELECT 0
**	USE (dbf('temp_serv')) AGAIN ALIAS all_serv

   oApp.ReopenCur("temp_serv","all_serv")

	INDEX on TC_ID + act_id + DTOS(act_dt) tag TAD
	INDEX on TC_ID + BILL_TYPE + act_id + DTOS(act_dt) tag TBAD ADDITIVE
	SET ORDER TO
	*** Index the table for speed but do not keep an order for Rushmore ************

RETURN	&& End ComboThem

************************************************************************************
FUNCTION GetDetail
PARAMETER nPercent, cMessage
PRIVATE fFlagFile, lFound

	oThermo.refresh(cMessage, nPercent)

	SELECT All_Serv
	SCAN
		IF SEEK(All_Serv.act_id + All_Serv.Serv_ID,'es_bill')
			REPLACE All_Serv.Billed WITH .T.
		ENDIF


		IF !EMPTY(All_Serv.enc_modif)
			REPLACE All_Serv.modifier WITH All_Serv.enc_modif
		ENDIF

		IF !EMPTY(All_Serv.bill_place)
			REPLACE All_Serv.Location WITH All_Serv.bill_place
		ELSE
			IF SEEK(All_Serv.s_location, "serv_loc") AND !EMPTY(serv_loc.bill_place)
				REPLACE All_Serv.Location WITH serv_loc.bill_place
			ELSE
				IF SEEK(All_Serv.act_loc, "serv_loc") AND !EMPTY(serv_loc.bill_place)
					REPLACE All_Serv.Location WITH serv_loc.bill_place
				ENDIF
			ENDIF
		ENDIF
				
		IF !EMPTY(all_serv.Enc_Proc)
			REPLACE All_Serv.Proc_code with all_serv.Enc_Proc
		ENDIF

		*** Get the rate code etc *****************************************
		IF EMPTY(all_serv.enc_rate)

 *!*            IF SEEK(   All_Serv.Serv_Cat + ;
*!*                     All_Serv.Enc_Prog + ;
*!*                     All_Serv.Enc_Site + ;
*!*                     All_Serv.RG       + ;
*!*                     All_Serv.enc_id + ;
*!*                     All_Serv.service_id, 'enc_serv')

         Select enc_serv
         Locate for enc_serv.serv_cat = All_Serv.Serv_Cat And ;
                    enc_serv.prog =  All_Serv.Enc_Prog And;
                    enc_serv.site = All_Serv.Enc_Site And ;
                    enc_serv.rate_grp = All_Serv.RG   And ;
                    enc_serv.enc_id = All_Serv.enc_id And ;
                    enc_serv.service_id = All_Serv.service_id
                  
         If Found()         
            Select All_serv
				REPLACE ;
					All_Serv.Rate_Code with Enc_serv.Rate_Code, ;
					All_Serv.Copay_ser with Enc_serv.CoPay, ;
					All_Serv.CanBeBill with Enc_serv.Can_Bill
					
				IF EMPTY(All_Serv.Modifier)
					REPLACE All_Serv.Modifier  with Enc_serv.Modifier
				ENDIF
	
				IF EMPTY(All_Serv.Location)
					REPLACE All_Serv.Location  with Enc_serv.Location
				ENDIF
	
				* If procedure code was not entered  - get the default
				IF EMPTY(all_serv.Proc_code)
					REPLACE All_Serv.Proc_code with Enc_serv.Proc_code
				ENDIF
			ENDIF
		ELSE
			REPLACE ;
				All_Serv.Rate_Code with all_serv.enc_rate, ;
				All_Serv.CanBeBill with .t.
		ENDIF
		
		IF EMPTY(all_serv.Proc_code) 
			SELECT def_proc
			LOCATE FOR all_serv.Serv_Cat = def_proc.serv_cat  And ;
			         all_serv.Enc_Prog = def_proc.prog  And ;
			         all_serv.Enc_Site = def_proc.site  And ;
			         all_serv.RG =def_proc.Rate_Grp And ;
			         all_serv.enc_id = def_proc.enc_id 
			         
			IF FOUND()  
				SELECT all_serv          
	  			REPLACE All_Serv.Proc_code with def_proc.Proc_code

	  			IF EMPTY(All_Serv.Modifier)
	  				REPLACE All_Serv.Modifier with def_proc.Modifier
	  			ENDIF

	  			IF EMPTY(All_Serv.Location)
	  				REPLACE All_Serv.Location with def_proc.location
	  			ENDIF
			ENDIF 
			SELECT all_serv        
		ENDIF

		IF All_Serv.CanBeBill	&& Continue if Enc/service_id is possibly billable
			m.Rate_code = All_serv.Rate_code
			m.Rate_grp  = All_serv.RG

			SELECT Rates_cur
			GO TOP
			LOCATE FOR ;
				m.Rate_code = Rates_cur.Rate_code AND ;
				m.Rate_Grp  = Rates_cur.Rate_grp AND ;
				All_Serv.act_dt >= Rates_cur.eff_date

			lFound = Found()
			REPLACE ;
				All_Serv.rate        WITH IIF(lFOUND, Rates_cur.rate, 0 ), ;
				All_Serv.reimb_rate  WITH IIF(lFOUND, Rates_cur.reimb_rate, 0 ), ;
				All_Serv.rate_hd_id	WITH IIF(lFOUND, Rates_cur.rate_hd_id, SPACE(5)), ;
				All_Serv.rate_md_id	WITH IIF(lFOUND, Rates_cur.rate_md_id, SPACE(5)), ;
				All_Serv.rate_dt_id	WITH IIF(lFOUND, Rates_cur.rate_dt_id, SPACE(5)), ;
				All_Serv.bill_type	WITH IIF(lFOUND, Rates_cur.bill_type,  SPACE(5)), ;
				All_Serv.by_time	   WITH IIF(lFOUND, Rates_cur.by_time,	.F.)
			SELECT All_Serv
		ENDIF

	ENDSCAN

RETURN	&& End GetDetail

************************************************************************************
************************************************************************************
*** These are rules that could be put in billtype.dbf and used as parameters *******
*** Next already in recentsite() function

*** iicond = IIF(.F., [HAVING enc_site1.enc_site = enc_site1.home_site ], [] )
*** All_Serv.date_compl <> {} AND
*** !EMPTY(All_Serv.Bill_Phys) AND
*** iicond = iif(.f.,[HAVING time_spent >= 180 ],[])
*** COUNT(*) as NUM_SER	or 1 as NUM_SER
*** SUM(SER_TOT_TM) as SUM_SER_TM,

*** If units are calculate by_time
*** SCAN FOR by_time
*** nunits = CalcUnit(ToBill_cur.rate_hd_id, ToBill_cur.sum_ser_tm, ToBill_cur.act_dt)
*** 	replace units with nunits
*** ENDSCAN

*** ToBill_cur.enc_tot_tm is total time of encounter time **************************
*** SUM_SER_TM is total time of service_ids *******************************************
*** *** usually this total is not group with act_id ********************************
*** whTM = iif(.t., [ToBill_cur.Enc_Tot_TM], [ToBill_cur.Sum_Ser_TM] )
************************************************************************************
************************************************************************************

************************************************************************************
FUNCTION theRules
PARAMETER nPercent, cMessage
PRIVATE theProg

	oThermo.refresh(cMessage, nPercent)

	*** Make cursor that will hold all possible claims -- called ToBill_cur
	*** Get List of All Billing Rules needed for this session
	*** Bill_type was assigned in GetDetails()

	*** Mult records for only encounters with service_ids and only for clinic ** ??? **
	*** This query may have to be adjusted - How will weekly and monthly rules work?
	*** All act_id marked, but claim has only info(procs) from 1 act_id not all. ***
	*** REMOVED - All_Serv.act_dt as Date
	*** REMOVED - cCLaimType != '01'		lNon_R will serv same purpose **********

   Set Step On 
	*** Will get a list of all procedure codes for Non R_lines
	SELECT DISTINCT ;
		All_Serv.act_id, ;
		All_Serv.Proc_Code ;
	FROM ;
		All_Serv ;
	WHERE ;
		All_Serv.CanBeBill AND ;
		!EMPTY(All_Serv.service_id) AND ;
		!EMPTY(All_Serv.Proc_Code) AND ;
		lNon_R ;
	INTO CURSOR ;
		proc_data
	INDEX ON act_id TAG act_id

	=MakeToBill()

	*** List of All Billing Templates that we need for current set of records (All_Serv)
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
		theProg = ALLTRIM(BillWhat.template)
		IF !EMPTY(theProg)
			DO (theProg) with BILL_TYPE
			IF _TALLY > 0
				SELECT ToBill_cur
				APPEND FROM DBF('temp_rec')
				USE in temp_rec
			ENDIF
			SELECT BillWhat		&& Go Back to BillWhat cursor to continue loop *****
		ENDIF
	ENDSCAN

	*** Time Chart - Calculates units for claims that are billed by time ***********
	SELECT ToBill_cur

	SCAN FOR by_time
		nUnits = CalcUnit(ToBill_cur.rate_hd_id, ToBill_cur.sum_ser_tm, ToBill_cur.act_dt)
		IF nUnits !=0
			replace units with nUnits
		ELSE
			DELETE
		ENDIF
	ENDSCAN

	*** Here we will automatically generate default co-payment amounts ??? *********

RETURN	&& End theRules


************************************************************************************
FUNCTION MakeToBill
*** Temp_cla is dbf that we will use to create an empty cursor. Turn cursor into ***
*** a dbf and then close up temp_cla. **********************************************
*** We do not want to use temp_cla as the actual file because during power downs ***
*** and other crashes, the file will become corrupt and have to be replaced ********
*** REMEMBER, any structure changes to other dbfs must also be done in temp_cla ****

		SELECT 0
		SELECT * FROM temp_cla INTO CURSOR tempit

		SELECT 0
**		USE (DBF('tempit')) AGAIN ALIAS ToBill_Cur

      oApp.ReopenCur("tempit","ToBill_Cur")
      
		INDEX ON Cat_Serv + ;
				Clin_spec + ;
				Loc_code + ;
				Name + ;
				DTOS(cli_dob) + ;
				DTOS(act_dt) + ;
				DTOS(date_compl) TAG CSLNDAC
		USE IN temp_cla

RETURN	&& MakeToBill


************************************************************************************
FUNCTION StartLog
PARAMETER nPercent, cMessage

	oThermo.refresh(cMessage, nPercent)

	m.bill_id = GetNextID("CLAIMLOGID")
	IF TYPE("m.bill_id") <> "C" OR EMPTY(m.bill_id)
		RETURN FAIL("Could Not Find new Bill ID. Claims were NOT created.")
	ENDIF

	*** Insert an entry in log now. Should anything go wrong, we will be able to use
	*** it to recreate claims. AFTER all claims are created, stamp it COMPLETED ****
	INSERT INTO claimlog ;
		(LOG_ID, ;
		TYPE, ;
		PROV_ID, ;
		PROV2_ID, ;
		PROV_NUM, ;
		LAST_RUN, ;
		FROM_DATE, ;
		THRU_DATE,  ;
		MAKE_REBIL, ;
		REBILLONLY, ;
		REBILL_ALL, ;
		OVER90CODE, ;
		PRIM_SEC, ;
		USER_ID, DT, ;
		TM)				 ;
	VALUES ;
		(m.bill_id, ;
		cClaimType, ;
		cProv_ID, ;
		cProv2_ID, ;
		cProv_Num, ;
		DATE(), ;
		IIF(lNewBill, dStartDate, {} ), ;
		IIF(lNewBill, dEndDate, DATE()), ;
		lRebill, ;
		lRebill AND NOT lNewBill, ;
		lRebillAll, ;
		cOver_90, ;
		nPrim_sec, ;
		gcWorker, DATE(), ;
		TIME() )

RETURN	&& End StartLog


************************************************************************************
FUNCTION GenClaims
PARAMETER nPercent, cMessage

	oThermo.refresh(cMessage, nPercent)

	SELECT ToBill_cur
	SET RELATION TO bill_phys INTO staffcur
	SET RELATION TO tc_id INTO diag_cur ADDITIVE
	GO TOP

	m.dt = DATE()
	m.tm = TIME()

	nCount = 0
	DO WHILE !EOF("ToBill_cur")
		m.tc_id   = ToBill_cur.tc_id
		m.rate_dt_id = ToBill_cur.rate_dt_id
		m.invoice = GetNextID("CLAIM_ID") + "0"
		nLine_No  = 0
		lHeader   = .F.

		SCAN WHILE ;
					ToBill_cur.tc_id = m.tc_id AND ;
					ToBill_cur.rate_dt_id = m.rate_dt_id
					
			IF !lHeader						&& If no header record created yet *****
				lHeader = .T.
				=INS_CL_HD(m.invoice)		&& Create header record in claim_hd ****
			ENDIF

			IF IncLine(nLine_No, .F.)
				SELECT ToBill_cur
				EXIT
			ENDIF

			=INS_CL_DT(m.Invoice, TRANSFORM(nLine_No,"@L 99"))

			*** IF Non R_line Exist (Would not exist if !lNon_r) *******************
				*** When Actual service_ids entered create non-R-Line (has proc code) *
				*** service_id lines in claim_dt, lNon_r does while !lNon_r does not **
				*** FORMA is actually !lNon_r **************************************
			*** *** Add Non R_lines ************************************************
			*** ELSE Non R_line does not actually Exist ****************************
				*** No actual service_ids entered - so no recs with proc_data.proc_code
				*** put default proc code from ToBill_cur if it exist **************
			*** *** IF Non R_line allowed then make a default Non R_line record ****
			*** *** ENDIF **********************************************************
			*** ENDIF **************************************************************

			IF SEEK(ToBill_cur.act_id,'proc_data')
				nServCount = 1
				SELECT Proc_Data

				DO WHILE ;
					proc_data.act_id = ToBill_cur.act_id AND ;
					nServCount <= 3	AND ;
					NOT EOF()

					IF IncLine(nLine_No, .F.)
						SELECT ToBill_cur
						EXIT
					ENDIF

					=MakeServLine(m.invoice, TRANSFORM(nLine_No,"@L 99"), ;
									proc_data.proc_code)
					SKIP	&& IN proc_data

					nServCount = nServCount + 1
				ENDDO
				SELECT ToBill_cur
			ELSE
 				IF !EMPTY(ToBill_cur.Proc_code) AND lNon_R
					=IncLine(nLine_No, .F.)
					=MakeServLine(m.invoice, TRANSFORM(nLine_No,"@L 99"), ;
									ToBill_cur.Proc_code)
				ENDIF
			ENDIF

	         oThermo.refresh(cMessage, 50 + nCount/RECCOUNT("ToBill_cur") * 50)

			nCount = nCount + 1

		ENDSCAN
		SELECT ToBill_cur
	ENDDO

RETURN	&& End GenClaims

************************************************************************************
FUNCTION Ins_CL_HD
PARAMETER cInvoice

	INSERT INTO claim_hd ;
		(BILLING, ;
		CLAIM_TYPE, ;
		PRIM_SEC, ;
		BILL_ID, ;
		PROV_ID, ;
		prov2_id, ;
		PROV_NUM, ;
		CLIENT_ID, ;
		TC_ID, ;
		INVOICE, ;
		CINN, ;
		INSSTAT_ID, ;
		BILL_DATE, ;
		OVER_90, ;
		OVER90_RES, ;
		LOC_CODE, ;
		CATEGORY, ;
		CLIN_SPEC, ;
		MAN_AUTO, ;
		DOB, SEX, ;
		DIAGNOS1, ICD9CODE1, ;
		DIAGNOS2, ICD9CODE2, ;
		PLACE, ;
		BILL_PHYS, ;
		PR_LICENSE, ;
		PR_TYPE, ;
		PR_TAX_ID, ;
		REF_PROV, ;
		REFPHYS_ID, ;
		ACC_CODE, ;
		PAT_STATUS, ;
		PAT_STAT2, ;
		USER_ID, DT, TM ) ;
	VALUES ;
		(2, ;
		cClaimType, ;
		nPrim_sec, ;
		m.bill_id, ;
		cProv_ID, ;
		cProv2_ID, ;
		cProv_Num, ;
		ToBill_cur.client_id, ;
		ToBill_cur.tc_id, ;
		cInvoice, ;
		ToBill_cur.pol_num, ;
		ToBill_cur.insstat_id, ;
		DATE(), (DATE() - ToBill_cur.act_dt) > nLate_Days, ;
		IIF((DATE() - ToBill_cur.act_dt) > nLate_Days, cOver_90, ''), ;
		ToBill_cur.loc_code, ;
		ToBill_cur.cat_serv, ;
		ToBill_cur.clin_spec, ;
		"A", ;
		IIF(!EMPTY(ToBill_cur.med_dob) and m.IsMedicaid, ;
				ToBill_cur.med_dob, ToBill_cur.cli_dob), ;
		IIF(!EMPTY(ToBill_cur.med_sex) and m.IsMedicaid, ;
				ToBill_cur.med_sex, ToBill_cur.cli_sex), ;
		IIF(!EMPTY(ToBill_cur.diagnos1), ToBill_cur.diagnos1, diag_cur.diag_code), ;
		IIF(!EMPTY(ToBill_cur.diagnos1), ;
				MyLookup("diagnos", "icd9code",ToBill_cur.diagnos1,"code","code"), ;
				diag_cur.icd9code), ;
		ToBill_cur.diagnos2, ;
				MyLookup("diagnos","icd9code",ToBill_cur.diagnos2,	"code","code"), ;
		ToBill_cur.location, ;
		ToBill_cur.Bill_Phys, ;
		staffcur.license, ;
		staffcur.pr_type, ;
		staffcur.tax_id, ;
		ToBill_cur.ref_prov, ;
		MyLookup("ref_prov", "id_no", ToBill_cur.ref_prov, "code", "code"), ;
		"0", "0", "30", ;
		gcWorker, m.dt, m.tm)

		*** Put this back after we figure out how to add to staff file

RETURN	&& Ins_CL_HD

************************************************************************************
FUNCTION Ins_CL_DT
PARAMETER cInvoice, cLine_No
*** Create an R-Line record in claims_dt (this rec has rate code) ******************
*** ToBill_cur.enc_tot_tm is total time of encounter time **************************
*** SUM_SER_TM is total time of service_ids *******************************************
*** *** usually this total is not group with act_id ********************************

	INSERT INTO claim_dt ;
		(INVOICE, ;
		LINE_NO, ;
		PROGRAM, ;
		RATE_HD_ID, ;
		RATE_MD_ID, ;
		RATE_DT_ID, ;
		RATE_CODE, ;
		PROC_CODE, ;
		MODIFIER, ;
		RATE, ;
		REIMB_RATE, ;
		NUMBER, ;
		COPAY_TYPE, ;
		COPAY_AMT, ;
		DATE, ;
		TIME, ;
		AMOUNT, ;
		REIMB_AMT, ;
		R_LINE, ;
		ENC_SITE, ;
		RATE_GRP, ;
		USER_ID, ;
		DT, ;
		TM) ;
	VALUES ;
		(cInvoice, ;
		cLine_No, ;
		ToBill_cur.enc_prog, ;
		ToBill_cur.rate_hd_id, ;
		ToBill_cur.rate_md_id, ;
		ToBill_cur.rate_dt_id, ;
		ToBill_cur.rate_code, ;
		ToBill_cur.proc_code, ;
		ToBill_cur.modifier, ;
		ToBill_cur.rate, ;
		ToBill_cur.reimb_rate, ;
		ToBill_cur.units, ;
		ToBill_cur.copay_type, ;
		ToBill_cur.copay_amt, ;
		ToBill_cur.act_dt, ;
		iif(nSum_Time=1, ToBill_cur.Sum_Ser_TM, ToBill_cur.Enc_Tot_TM), ;
		ToBill_cur.rate * ToBill_cur.units, ;
		ToBill_cur.reimb_rate * ToBill_cur.units, ;
		.T., ;
		ToBill_cur.Enc_site, ;
		ToBill_cur.RG, ;
		gcWorker, ;
		m.dt, ;
		m.tm)

RETURN	&& Ins_CL_DT

************************************************************************************
FUNCTION MakeServLine
PARAMETERS cInvoice, cLine_No, cProc_Code

	INSERT INTO claim_dt ;
		(INVOICE, ;
		LINE_NO, ;
		RATE_HD_ID, ;
		RATE_MD_ID, ;
		RATE_DT_ID, ;
		PROC_CODE, ;
		RATE, ;
		REIMB_RATE, ;
		NUMBER, ;
		DATE, ;
		TIME, ;
		AMOUNT, ;
		R_LINE, ;
		USER_ID, ;
		DT, ;
		TM) ;
	VALUES ;
		(cInvoice, ;
		cLine_No, ;
		"", ;
		"", ;
		"", ;
		cProc_Code, ;
		0, ;
		0, ;
		0, ;
		ToBill_cur.act_dt, ;
		0, ;
		0, ;
		.F., ;
		gcWorker, ;
		m.dt, ;
		m.tm)

 RETURN	&& MakeServLine

************************************************************************************
FUNCTION MarkBilled
PARAMETER nPercent, cMessage
PRIVATE cOldInv, cFirstInv

	oThermo.refresh(cMessage, nPercent)

	* If rebilling all denied claims, mark the denied claims with 
	* no action specified as action "rebill"
	IF lReBillAll
		SELECT ;
			invoice, line_no ;
		FROM ;
			claim_dt ;
		WHERE ;
			claim_dt.invoice + claim_dt.line_no IN (SELECT invoice + r_line FROM do_rebill) AND ;
			claim_dt.action = 0 ;
		INTO CURSOR ;
			no_action
		
		IF _TALLY > 0
			=OpenFile("claim_dt", "inv_line")
			SELECT no_action
			SCAN
				IF SEEK(invoice + line_no, "claim_dt")
					REPLACE claim_dt.action WITH 1
				ENDIF
			ENDSCAN
		ENDIF
	ENDIF

	*** This will produce a list of act_id & Serv_id which will be added ***********
	*** to Es_bill if the encounter/service_ids is actually billed out ****************
	*** This will only work for daily claim records. *******************************
	*** What about weekly/monthly claim records ************************************
	*** REPLACE act_dt with ENC_WK_BEG or ENC_MN_BEG ??? ***************************

	SELECT ;
		All_serv.act_id, ;
		all_serv.serv_id, ;
		claim_hd.invoice, ;
		claim_dt.line_no, ;
		claim_dt.line_no as R_Line, ;
		ToBill_cur.ToBIll, ;
		ToBill_cur.bill_type, ;
		ToBill_cur.Flag_dt as Flag, ;
		.F. as ReBilled, ;
		m.Bill_ID as Bill_ID, ;
		SPACE(10) as ActBill_ID, ;
		m.dt as DT, ;
		m.tm as TM, ;
		gcworker as USER_ID ;
	FROM ;
		ToBill_cur, all_serv, claim_hd, claim_dt ;
	WHERE ;
		ToBill_cur.ToBill AND ;
		ToBill_cur.TC_ID     = All_serv.TC_id AND ;
		ToBill_cur.act_dt  = All_serv.act_dt AND ;
		ToBill_cur.rate_code = All_serv.rate_code AND ;
		ToBill_cur.proc_code = All_serv.proc_code AND ;
		!EMPTY(All_serv.rate) AND ;
		claim_hd.bill_id     = m.Bill_ID AND ;
		claim_hd.invoice     = claim_dt.invoice AND ;
		claim_hd.tc_id       = All_serv.tc_id AND ;
		claim_dt.date        = All_serv.act_dt AND ;
		claim_dt.rate_code   = All_serv.rate_code AND ;
		claim_dt.proc_code   = All_serv.proc_code AND ;
		claim_dt.action      = 0 AND ;
		EMPTY(claim_dt.ActBill_ID) AND ;
		claim_dt.r_line ;
	UNION ;
	SELECT ;
		All_serv.act_id, ;
		all_serv.serv_id, ;
		SPACE(10) as invoice, ;
		SPACE(2) as line_no, ;
		SPACE(2) as R_line, ;
		ToBill_cur.ToBIll, ;
		ToBill_cur.bill_type, ;
		ToBill_cur.Flag_dt as Flag, ;
		.F. as ReBilled, ;
		m.Bill_ID as Bill_ID, ;
		SPACE(10) as ActBill_ID, ;
		m.dt as DT, ;
		m.tm as TM, ;
		gcworker as USER_ID ;
	FROM ;
		ToBill_cur, all_serv ;
	WHERE ;
		!ToBill_cur.ToBill  AND ;
		ToBill_cur.TC_ID	   = All_serv.TC_id AND ;
		ToBill_cur.act_dt	= All_serv.act_dt AND ;
		ToBill_cur.rate_code = All_serv.rate_code AND ;
		ToBill_cur.proc_code = All_serv.proc_code AND ;
		!EMPTY(All_serv.rate) ;
	INTO CURSOR ;
		temp_es ;
	ORDER BY 3, 4, 1, 2

	*** Get List of all Distinct Act/Serv recs that have been considered billed above
	SELECT DISTINCT ;
		temp_es.act_id, ;
		temp_es.serv_id ;
	FROM ;
		temp_es ;
	INTO CURSOR ;
		check_es
	INDEX on act_id + SERV_ID TAG Act_Serv

	*** Wonder if setting relation and REPLACE FOR ... would be faster *************
	*** IMPORTANT - BEFORE WE ADD THE NEW ES_BILL RECS DO THIS SCAN ****************
	*** If Act/Serv rec exist in ES tell ES it's rebilled and the batch(Bill_ID) ***
	*** Only records that not rebilled are considered - Other recs keep history ****
	=OpenFile("Es_bill")
	SCAN FOR NOT REBILLED
		IF SEEK(Es_Bill.act_id + Es_Bill.Serv_ID, "Check_es")
			REPLACE ;
				Es_Bill.ActBill_ID with m.bill_ID, ;
				Es_Bill.ReBilled with .T.
		ENDIF
	ENDSCAN

	SELECT Es_Bill
	APPEND FROM DBF('Temp_ES')

	*** List of Old Invoice/Lines/Act/Serv id rebills for this batch ***************
	*** Rebill Recs where the ActBill_ID were replaced above with this batch id ****
	SELECT DISTINCT ;
		es_bill.invoice as old_inv, ;
		es_bill.r_line  as old_rline, ;
		es_bill.act_id, ;
		es_bill.serv_id ;
	FROM ;
		es_bill ;
	WHERE ;
		es_bill.ActBill_ID = m.Bill_ID ;
	ORDER BY ;
		1, 2, 3, 4 ;
	INTO CURSOR ;
		old_invs

	*** List of New Invoice/Lines/Act/Serv id for this batch ***********************
	SELECT DISTINCT ;
		es_bill.invoice as new_inv, ;
		es_bill.r_line  as new_rline, ;
		es_bill.act_id, ;
		es_bill.serv_id ;
	FROM ;
		es_bill ;
	WHERE ;
		es_bill.Bill_ID = m.Bill_ID ;
	ORDER BY ;
		1, 2, 3, 4 ;
	INTO CURSOR ;
		new_invs

	*** Set order of claim_dt, the get list of new invs with their orig invs *******
	*** Put Batch in old rebilled claim_dt recs, orig Inv/line in new rebill recs **
	=OpenFile("Claim_dt","inv_line", "claim_dt2")
	=OpenFile("Claim_dt","inv_line")
	SELECT DISTINCT ;
		new_invs.new_inv, ;
		new_invs.new_rline, ;
		old_invs.old_inv, ;
		old_invs.old_rline ;
	FROM ;
		new_invs, old_invs ;
	WHERE ;
		new_invs.act_id	= old_invs.act_id AND ;
		new_invs.serv_id = old_invs.serv_id ;
	INTO CURSOR ;
		fix_det


	SCAN
		* Mark the new invoice with the invoice# and line of originating invoice
		IF SEEK(new_inv + new_rline,"claim_dt")
			REPLACE ;
					Claim_dt.orig_inv with fix_det.old_inv, ;
					Claim_dt.orig_line with fix_det.old_rline
			
			* Get the first invoice
			IF SEEK(old_inv + old_rline,"claim_dt2")
				IF EMPTY(claim_dt2.first_inv)
					* this one is the first rebill invoice - 
					* make first_inv and orig_inv the same
					REPLACE ;
							Claim_dt.first_inv with fix_det.old_inv, ;
							Claim_dt.first_line with fix_det.old_rline
				ELSE
					* Continue the chain of invoices
					REPLACE ;
							Claim_dt.first_inv with claim_dt2.first_inv, ;
							Claim_dt.first_line with claim_dt2.first_line
				ENDIF
			ENDIF
		ELSE
			oApp.Msg2User("MESSAGE","Can not find new claim. Call MIS Director.")
		ENDIF

		* Mark originating invoice as "action performed" with current bill_id
		IF SEEK(old_inv + old_rline,"claim_dt")
			REPL Claim_dt.ActBill_ID with m.Bill_ID
		ELSE
			oApp.Msg2User("MESSAGE","Can not find old claim. Call MIS Director.")
		ENDIF
	ENDSCAN


RETURN	&& MarkBilled

************************************************************************************
FUNCTION Manual
PRIVATE lFound
*** Put the batch number (bill_id) into manual claims ******************************
*** m.bill_id was created in StartLog - Set it to Empty Public Var at beginning ****

	SELECT claim_hd
	LOCATE FOR ;
		EMPTY(claim_hd.bill_id) AND ;
		claim_hd.claim_type = "A" AND ;
		claim_hd.prov_id    = cProv_ID AND ;
		claim_hd.prov2_id   = cProv2_ID

	lFound = FOUND()
	IF lFound
		REPLACE ;
			claim_hd.bill_id WITH m.bill_id, ;
			claim_hd.user_id WITH gcWorker, ;
			claim_hd.dt      WITH DATE(), ;
			claim_hd.tm      WITH TIME() ;
		FOR ;
			EMPTY(claim_hd.bill_id) AND ;
			claim_hd.claim_type = "A" AND ;
			claim_hd.prov_id    = cProv_ID AND ;
			claim_hd.prov2_id   = cProv2_ID
	ENDIF

RETURN lFound	&& Manual


************************************************************************************
FUNCTION BackFill
PARAMETERS cBill_ID, cOver_90
PRIVATE lResult

*** Do the "back-filling" of Medicaid numbers **************************************
*** Will fill claim_hd records with Medicaid(poli_num) for those who are pending ***
*** Pending are those records billed but not sent, but the rest of the batch was ***
*** This records will be grabbed reguardless of date range *************************

	lResult = .F.

	*** We are assuming that a policy number (medicaid number) is only going to be
	*** held back for all unsent but created claims. When number arrives, all the
	*** numberless claims will be filled. GROUP BY does not get last sorted rec but
	*** according the assumption, this should work fine.

	*** List previous unsent claims that were held back for EMPTY(pol num) *********
	SELECT	DISTINCT ;
		claim_dt.invoice, ;
		cli_insure.pol_num as cinn ;
	FROM ;
		claim_hd, cli_insure, claim_dt ;
	WHERE ;
		claim_hd.prov_id = cProv_ID AND ;
		claim_hd.prov2_id= cProv2_ID AND ;
		claim_hd.invoice = claim_dt.invoice AND ;
		claim_hd.tc_id = cli_insure.tc_id AND ;
		!EMPTY(cli_insure.pol_num) AND ;
		BETWEEN(claim_dt.date, cli_insure.start_dt, cli_insure.end_dt) AND ;
		EMPTY(claim_hd.cinn) AND ;
		Cli_insure.prim_sec = nPrim_sec ;
	GROUP BY ;
		1, 2 ;
	INTO CURSOR ;
		to_fill

	IF _TALLY > 0
		lResult = .T.

		=OpenFile("Es_bill","Invoice")
		SET FILTER TO !REBILLED

		=OpenFile("Claim_hd","Invoice")

		=OpenFile("Claim_dt","Invoice")
		SELECT to_fill
		SET RELATION TO invoice INTO claim_hd, ;
						invoice INTO claim_dt ADDITIVE

		SCAN
			REPLACE ;
				claim_hd.bill_id	WITH cBill_ID, ;
				claim_hd.claim_type WITH cCLaimType, ;
				claim_hd.cinn		WITH to_fill.cinn, ;
				claim_hd.over_90	WITH (DATE() - claim_dt.date) > nLate_Days, ;
				claim_hd.over90_res WITH ;
					IIF((DATE()-claim_dt.date) > nLate_Days, cOver_90, ''), ;
				claim_hd.user_id	WITH gcWorker, ;
				claim_hd.dt			WITH m.dt, ;
				claim_hd.tm			WITH m.tm

			*** Scan list & assign new bill_id for current billing batch ***********
			*** In the future we must keep history file of pre-replaced records ****
			SELECT es_bill
			IF SEEK(to_fill.invoice)
				SCAN WHILE es_bill.invoice = to_fill.invoice
					REPLACE es_bill.bill_id WITH cBill_ID
				ENDSCAN
			ENDIF
			SELECT to_fill
		ENDSCAN
	ENDIF

	SELECT es_bill
	SET FILTER TO
	USE IN to_fill
RETURN lResult	&& BackFill


************************************************************************************
*** Increment Line number and if necessary - Invoice number ************************
************************************************************************************
FUNCTION IncLine
PARAMETER nLineNum, lRLine

	IF lRLine	&& Nice, but not needed
		nLineNum = (INT(nLineNum/10) + 1) * 10 + 1
	ELSE
		nLineNum = nLineNum + 1
	ENDIF

	*** nMaxClaims is global variable in Claims3.prg
	*** CLINIC	 - Type 01 - > 99, start new invoice
	*** COBRA	 - Type 02 - >  9, start new invoice
	*** HCFA 	 - Type 03 - >  6, start new invoice

RETURN (nLineNum > nMaxClaims)


************************************************************************************
*** When we want to leave Billing we show message and close thermometer ************
************************************************************************************
FUNCTION Fail
Para cMessage
	oApp.Msg2User("INFORM",cmessage)
	oThermo.Release
RETURN .F.


************************************************************************************
* Create adjust/void claims ********************************************************
************************************************************************************
*** We need some changes here in the near future.
*** *** We are not involving service_id lines here, (we may not have to)
*** *** We do recalculate the rate
*** *** We do not recalculate the number of units here (Especially in COBRA)
*** *** User must do these things themselves before creating diskette
FUNCTION Claim_AV
PARAMETER cBill_ID, cOldBill_ID
PRIVATE nCount, nTotal, lCleanThermo
PRIVATE m.amt_paid, m.status, m.action, m.actbill_id, m.claim_ref, m.den_code

	IF Type("cOldBill_ID") <> "C" OR Empty(cOldBill_ID)
		cOldBill_ID = SPACE(10)
	ENDIF

	lCleanThermo = WEXIST('thermometer')

	IF lCleanThermo
      oThermo.Release
   ENDIF

   oThermo = createobject('thermobox', "Creating Adjust/Void Claims.", "Open files...")
   othermo.show


	=OpenFile("claim_hd", "invoice")
	=OpenFile("claim_dt", "inv_line")
	=OpenFile("claim_dt", "inv_line", "claim_dt2")

	*** List all rebillable claim recs if new batch, or rebilled if old batch ******
*-*	SELECT ;
*-*		claim_dt.* ;
*-*	FROM ;
*-*		claim_dt ;
*-*	WHERE ;
*-*		BETWEEN(claim_dt.action,3,4) AND ;
*-*		(Empty(claim_dt.actbill_id) OR claim_dt.actbill_id = cOldBill_ID) ;
*-*	INTO CURSOR ;
*-*		temp_det


	SELECT ;
		claim_dt.* ;
	FROM ;
		claim_dt, claim_hd ;
	WHERE ;
		claim_hd.invoice = claim_dt.invoice AND ;
		claim_hd.prov_id	= cProv_ID AND ;
		claim_hd.prov2_id	= cProv2_ID AND ;
		BETWEEN(claim_dt.action,3,4) AND ;
		(Empty(claim_dt.actbill_id) OR claim_dt.actbill_id = cOldBill_ID) ;
	INTO CURSOR ;
		temp_det

*-*		claim_hd.claim_type = cClaimType AND ;

	nTotal = _TALLY
	nCount = 0
   
   oThermo.refresh("Generate Adjust/Void Claims...", 10)
   
	SET RELATION TO invoice INTO claim_hd, ;
					invoice+line_no INTO claim_dt ADDITIVE

	*** Common variable values to be inserted into new claim records ***************
	m.bill_id	= cBill_ID
	m.bill_date	= Date()
	m.user_id	= gcWorker
	m.dt			= Date()
	m.tm			= Time()
	m.claim_type = cClaimType 
	
	SCAN
		SCATTER MEMVAR FIELD EXCEPT ;
			invoice, line_no, amt_paid, status, action, actbill_id, ;
			claim_ref, den_code, user_id, dt, tm

		m.invoice = GetNextID("CLAIM_ID") + "0"
		m.line_no = "01"

		IF Empty(m.orig_inv)
			m.orig_inv = temp_det.invoice
		ENDIF

		SELECT claim_hd
		SCATTER MEMVAR FIELD EXCEPT ;
			bill_id, claim_type, invoice, bill_date, user_id, dt, tm
			
		m.orig_ref = temp_det.claim_ref
		m.adj_void = IIF(temp_det.action = 3, "A", "V")

		*** In original claim_dt rec put new batch (bill_id) for reference *********
		SELECT claim_dt
		IF oApp.RecLock('claim_dt')
      	REPLACE claim_dt.actbill_id WITH cBill_ID
		ENDIF

		INSERT INTO claim_hd FROM MEMVAR
		INSERT INTO claim_dt FROM MEMVAR
		
		** Get the procedure line following the rate line if there was one
		select claim_dt2
		IF Seek(temp_det.invoice + temp_det.line_no)
			SKIP
			IF !EOF() AND claim_dt2.invoice = temp_det.invoice AND !claim_dt2.r_line
				SCATTER MEMVAR FIELD EXCEPT ;
					invoice, line_no, amt_paid, status, action, actbill_id, ;
					claim_ref, den_code, user_id, dt, tm
				m.line_no = "02"
				
				INSERT INTO claim_dt FROM MEMVAR
			ENDIF
		ENDIF
		select temp_det
		
      oThermo.refresh("Generate Adjust/Void Claims...", 10 + nCount/nTotal * 90)
         
		nCount = nCount + 1
	ENDSCAN
	
	USE IN claim_dt2
	
	IF lCleanThermo
		oThermo.Release
	ENDIF

RETURN nCount > 0	&& Claim_AV

*** ********************************************************************************
*** Billing Function Library - *****************************************************
*** Function names are store in BillType.DBF ***************************************
*** Rate codes table is linked to BillType.DBF through SCHEMES *********************
*** ********************************************************************************
FUNCTION COBBill
PARAMETER cBillType
PRIVATE nunits
*** Grouping is to get sum of service_id time of all COBRA service_ids in ****************
*** same (service_id DATE NOT ENC_DATE) day, same client, and same rate code. *********
*** User SHOULD NOT be able to type in different serv_date than enc_date ***********
*** RATE_CODE must be same for all records (At least for the same client) **********

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(SER_TOT_TM) as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			000 as Units, ;
			SERV_DATE as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, RG, act_dt ;
		HAVING ;
			sum_ser_tm > 0 ;
		INTO CURSOR ;
			temp_rec
   
        

RETURN	&& COBRABill

************************************************************************************
FUNCTION EncBill
PARAMETER cBillType
*** Bill For encounter time.

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			ENC_TOT_TM as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			001.00 as units, ;
			act_dt as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			act_id ;
		HAVING ;
			sum_ser_tm > 0 ;
		INTO CURSOR ;
			temp_rec

RETURN	&& End EncBill

************************************************************************************
FUNCTION ServBill
PARAMETER cBillType
PRIVATE nunits
*** All Individual service_ids of a client on any date will be set up to be billed by time **

		SELECT ;
			iif(billed,1,0) as EncBilled, ;
			SER_TOT_TM as SUM_SER_TM, ;
			1 as NUM_SER, ;
			000 as Units, ;
			SERV_DATE as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		HAVING ;
			sum_ser_tm > 0 ;
		INTO CURSOR ;
			temp_rec

RETURN	&& ServBill


************************************************************************************
FUNCTION HIVBill
PARAMETER cBillType
*** Grouping is to get all HIV PC service_ids of same encounter of a client ***********
*** RATE_CODE must be same for all recs of an encounter. ***************************
*** However, they can be different for each encounter ******************************
*** HAVING EncBilled = 0 (This means that Encounter was not billed) ****************

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(SER_TOT_TM) as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			1 as units, ;
			act_dt as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			All_Serv.date_compl <> {} AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, act_dt ;
		INTO CURSOR ;
			temp_rec

RETURN	&& End HIVBill


************************************************************************************
FUNCTION ADHCBill
PARAMETER cBillType
*** Check For encounter time to be >= 180 mins. What about service_id time?

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(ENC_TOT_TM) as TOT_ENC_TM, ;
			COUNT(*) as NUM_SER, ;
			1 as units, ;
			act_dt as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, act_dt ;
		HAVING ;
			TOT_Enc_TM >= 180 ;
		INTO CURSOR ;
			temp_rec

RETURN	&& End ADHCBill


************************************************************************************
FUNCTION DayBill
PARAMETER cBillType
*** One Encounter of a client on any date will be set up to be billed **************

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(SER_TOT_TM) as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			1 as units, ;
			act_dt as Claim_dt, ;
			'D' as Flag_dt, ;
			.F. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, act_dt ;
		INTO CURSOR ;
			temp_rec

		*** Make cursor updatable and mark highest rate actually billed ************
		*** Other recs same client, same day are not billable but want in es_bill **
		SELECT 0
		*USE (dbf('temp_rec')) AGAIN ALIAS temp2_rec
      
      oApp.ReopenCur("temp_rec","temp2_rec")
      
		INDEX ON TC_ID + DTOS(act_dt) + TRANS(RATE,'99999.99') DESC TAG TAR

		SCAN
			m.TC_ID	 = temp2_rec.TC_ID
			m.act_dt = temp2_rec.act_dt
			REPLACE Temp2_rec.ToBill with .T.
				DO WHILE ;
					Temp_rec.TC_ID = m.TC_ID AND ;
					Temp_rec.act_dt = m.act_dt AND ;
					NOT EOF()
						SKIP
				ENDDO
		ENDSCAN

RETURN	&& End DayBill


************************************************************************************
FUNCTION WeekBill
PARAMETER cBillType
*** One Encounter of a client on any week will be set up to be billed **************

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(SER_TOT_TM) as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			1 as units, ;
			ENC_WK_BEG as Claim_dt, ;
			'W' as Flag_dt, ;
			.F. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, ENC_WK_BEG ;
		INTO CURSOR ;
			temp_rec

		*** Make cursor updatable and mark highest rate actually billed ************
		*** Other recs same client, same day are not billable but want in es_bill **
		SELECT 0
		**USE (dbf('temp_rec')) AGAIN ALIAS temp2_rec
      
      oApp.ReopenCur("temp_rec","temp2_rec")
      
		INDEX ON TC_ID + DTOS(ENC_WK_BEG) + TRANS(RATE,'99999.99') DESC TAG TWR

		SCAN
			m.TC_ID	 = temp2_rec.TC_ID
			m.ENC_WK_BEG = temp2_rec.ENC_WK_BEG
			REPLACE Temp2_rec.ToBill with .T.
				DO WHILE ;
					Temp_rec.TC_ID = m.TC_ID AND ;
					Temp_rec.ENC_WK_BEG = m.ENC_WK_BEG AND ;
					NOT EOF()
						SKIP
				ENDDO
		ENDSCAN

RETURN	&& End WeekBill


************************************************************************************
FUNCTION MonBill
PARAMETER cBillType
*** One Encounter of a client on any week will be set up to be billed **************

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(SER_TOT_TM) as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			1 as units, ;
			ENC_MN_BEG as Claim_dt, ;
			'M' as Flag_dt, ;
			.F. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, ENC_MN_BEG ;
		INTO CURSOR ;
			temp_rec

		*** Make cursor updatable and mark highest rate actually billed ************
		*** Other recs same client, same day are not billable but want in es_bill **
		SELECT 0
		**USE (dbf('temp_rec')) AGAIN ALIAS temp2_rec
      
      oApp.ReopenCur("temp_rec","temp2_rec")
      
		INDEX ON TC_ID + DTOS(ENC_MN_BEG) + TRANS(RATE,'99999.99') DESC TAG TMR

		SCAN
			m.TC_ID	 = temp2_rec.TC_ID
			m.ENC_MN_BEG = temp2_rec.ENC_MN_BEG
			REPLACE Temp2_rec.ToBill with .T.
				DO WHILE ;
					Temp_rec.TC_ID = m.TC_ID AND ;
					Temp_rec.ENC_MN_BEG = m.ENC_MN_BEG AND ;
					NOT EOF()
						SKIP
				ENDDO
		ENDSCAN

RETURN	&& End MonBill


************************************************************************************
FUNCTION AllBill
PARAMETER cBillType
*** All Individual Encounters of a client on any date will be set up to be billed **

		SELECT ;
			SUM(iif(billed,1,0)) as EncBilled, ;
			SUM(SER_TOT_TM) as SUM_SER_TM, ;
			COUNT(*) as NUM_SER, ;
			1 as units, ;
			act_dt as Claim_dt, ;
			'D' as Flag_dt, ;
			.T. as ToBill, ;
			 ALL_SERV.* ;
		FROM ;
			ALL_SERV ;
		WHERE ;
			All_Serv.CanBeBill AND ;
			Bill_Type = cBillType AND ;
			!EMPTY(All_Serv.Rate_Code) AND ;
			!EMPTY(All_Serv.Proc_Code) AND ;
			!EMPTY(All_Serv.Rate) ;
		GROUP BY ;
			TC_ID, RATE_CODE, act_id ;
		INTO CURSOR ;
			temp_rec

RETURN	&& End AllBill

************************************************************************************
*** Calculate Number of Units of service_id *******************************************
*** =CalcUnit(ToBill_cur.rate_hd_id, ToBill_cur.sum_ser_tm, ToBill_cur.act_dt) *****
FUNCTION CalcUnit
PARAMETER cRate_HD_ID, nTime, dDate
PRIVATE cTime_MD_ID, nTime_Inc, nCount, nMaxTime, nSaveArea

	nCount    = 0
	nMaxTime  = 0
	nSaveArea = SELECT()

	*** Get Time_Md_Id of time period we are using for this rate code (Rate_Hd_ID) **
	SELECT EffTimes
	GO TOP
	LOCATE FOR ;
		cRate_HD_ID = EffTimes.Rate_Hd_id AND ;
		dDate >= EffTimes.eff_date

	IF FOUND()
		cTime_MD_ID = EffTimes.Time_MD_ID
		nTime_Inc	= EffTimes.Time_Inc
		nUnit_Inc   = IIF(EffTimes.Unit_Inc = 0, 1.0, EffTimes.Unit_Inc)

		*** With current Rate code & time period, locate first record on chart **********
		SELECT TimeUnits
		GO TOP
		LOCATE FOR ;
			cRate_HD_ID = TimeUnits.Rate_Hd_id AND ;
			cTime_MD_ID = TimeUnits.Time_MD_ID

		IF FOUND()
			*** Count units while each period is passed *************************************
			SCAN WHILE ;
				TimeUnits.rate_hd_id = cRate_HD_ID AND ;
				TimeUnits.time_md_id = cTime_MD_ID AND ;
		 		nTime >= TimeUnits.min_time AND ;
		 		!EOF()

				nCount = nCount + IIF(TimeUnits.increment = 0, 1.0, TimeUnits.increment)
				nMaxTime = MIN_TIME
			ENDSCAN

			*** If all periods are passed calc rest of units to be added to current total ***
			IF TimeUnits.rate_hd_id = cRate_HD_ID OR ;
					TimeUnits.time_md_id = cTime_MD_ID OR ;
					dDate >= TimeUnits.eff_date OR !EOF()
				nCount = nCount + INT((nTime - nMaxTime) / nTime_Inc) * nUnit_Inc
			ENDIF

		ENDIF

	ENDIF

	SELECT (nSaveArea)
RETURN nCount	&& CalcUnit
