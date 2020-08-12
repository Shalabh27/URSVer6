***************************************************************
* Format medicaid file for HIPAA 837 Institutional billing
* URS
***************************************************************
PARAMETERS cBill_ID, cProv_ID, cProv2_ID, lReprocess, vDummy

PRIVATE ;
	i,			lcontproc,		nBatch_No,			cindicate,		cversion, ;
	cmulti,		cadmin,			csource,			cMedFile, 		cDisk, ;
	nlines,	;	
	nBatClaim,	nBatLines,		nBatRecs, 		nBatCharge,		nBatchCnt, ;
	nTotClaim,	nTotLines,		nTotRecs, 		nTotCharge, 	nTot;
	m.tot_bill,	nrecs, 			;
	nDone,		nPctHold,		nPct,				ndisk,			ntotamt, ;
	atotals,		aInvoices,		cbilltype,		cstate_id, ;
	cNPI, lNPI_Req

PRIVATE cDisk, cSub_ID, nDiskNum, dBill_Date, dThru_date, cPayorName, cProv_Name, cRec_Type, cEdit_Ind, cSaveClient, lPhaseII

cDisk      = " "

cSubm_Type = "CPU"
cClaimType = "XI"

cProv_Num = GetDesc('med_pro2','cProv2_ID','prov2_id','prov_num')

nDiskNum = 1

PRIVATE nNo_Invcs, nNo_Claims, nTot_Amt, cCur_Year, cDay1, nJul_Day

nNo_Invcs = 0
nNo_Claims = 0
nTot_Amt = 0
cCur_Year = Str(Year(Date()),4,0)
cDay1 = "01/01/" + cCur_year
nJul_Day = (Date() - CTOD(cDay1)) + 1

PRIVATE cPatStreet1, cPatStreet2, cPatCity, cPatState, cPatZip
STORE '' TO cPatStreet1, cPatStreet2, cPatCity, cPatState, cPatZip

PRIVATE cTax_ID, m.name

cTax_ID = ''
m.name = ''
cSaveClient = ' '

PRIVATE nCLSaveRec, cCLSaveTag, cDiskCond

DIMENSION atotals[1,2]
DIMENSION aInvoices[1]
lcontproc   = .T. 		&& Continue Process
nBatch_No  	= 1

*cIndicate	= IIF(GetAPref("LMEDPROD"), 'PROD', 'TEST')		&& System indicator TEST-Testing, PROD-Production
*cIndicate	= 'T'		&& System indicator T-Testing, P-Production
cIndicate	= 'P'		&& System indicator T-Testing, P-Production

cMedFile	= ''
cDisk		= ''

PRIVATE nHlCount, nSegmentCount, cTranDate, cTranTime

nHlCount = 0
nProviderHL = 0
nSegmentCount = 0

cTranDate = RIGHT(DTOS(Date()), 6)
cTranTime = STRTRAN(LEFT(Time(), 5), ':')


PRIVATE m.prov_id, m.prov2_id
m.prov_id	= cProv_ID
m.prov2_id  = cProv2_ID

IF TYPE("nTimeLimit") <> "N" OR EMPTY(nTimeLimit)
	nTimeLimit = 90
ENDIF

STORE 0 TO ;
	nlines,		nRec_C,		nRec_D,		nRec_E,		nRec_F, ;
	nBatClaim, 	nBatLines,	nBatRecs,	nBatCharge, 	;
	nTotClaim,	nTotLines,	nTotRecs, 	nTotCharge, ;
	nBatchCnt,	m.tot_bill,	nrecs,		nDone, ;
	nPctHold,	nPct,		ndisk,		ntotamt

oApp.msg2user('WAITRUN','Initialzation:','Medicaid claims disk processing')

***
* create cursor for totals report
CREATE CURSOR printdata ;
	(magnetic C(4), cur_year C(2), jul_day N(3,0), prov_id C(5), prov_num C(12), ;
		serial_num C(6), no_invcs N(6,0), no_claims N(6,0), ;
		no_records N(6,0), tot_amt N(10,2), cDate D, cTime c(5))

***
* Open databases
=OpenFile("claim_hd", "invoice")
=OpenFile("claim_dt", "inv_line")

IF !(FLock("claim_hd") .AND. FLock("claim_dt"))
	oApp.Msg2User("NOLOCK2")
	Return .f.
ENDIF

=openfile('relat')
=openfile('address', 'hshld_id')
=openfile('ref_prov', 'code')
=openfile('med_prov')
=openfile('MED_PRO2')
=openfile('over_90', 'code')
=openfile('AGENCY')
GO TOP

SELECT ;
	med_pro2.*, ;
	med_prov.name, ;
	med_prov.signature, ;
	instype.rec_type, ;
	instype.edit_ind ;
FROM ;
	instype, med_prov, med_pro2 ;
WHERE ;
	med_prov.instype = instype.code AND ;
	med_prov.prov_id = cProv_ID AND ;
	med_prov.prov_id = med_pro2.prov_id AND ;
	prov2_id = cProv2_ID ;
INTO CURSOR ;
	allprovcur

IF _TALLY = 0
	oApp.Msg2User("SEEKERROR", chr(13) + " - Provider not found on file!")
	RETURN
ENDIF
SCATTER MEMVAR

* Get the Provider name
cProv_Name = RTRIM(m.descript)

IF EMPTY(cProv_Name)
	cProv_Name = RTRIM(agency.descript1)
ENDIF

* submitter ID
cSub_ID = m.mag_input

* Get the tax_id
IF EMPTY(m.tax_id)
	cTax_ID	= PADL(onlynum(agency.tax_id),10,'0')
ELSE
	cTax_ID	= PADL(TRIM(m.tax_id), 10, '0')
ENDIF

cTax_ID = TRANS(cTax_ID, "@R 99-9999999")

* Get the Contact Phone
cContPhone = m.phone

IF EMPTY(cContPhone)
	cContPhone = IIF(!EMPTY(agency.c_phone), agency.c_phone, agency.phone)

	IF EMPTY(cContPhone)
		cContPhone = '9999999999'
	ENDIF
ENDIF

* Get the file name
cFileName  = TRIM(m.file_name)
IF EMPTY(cFileName)
*	cFileName = "M837" + TRAN(Month(Date()), "@L 99") + TRAN(Day(Date()), "@L 99") + "."
	cFileName = 'MEDHIPAA'
ENDIF

lPhaseII = m.phase2
*lPhaseII = .t.

cIntRecID = IIF(lPhaseII, 'EMEDNYBAT', 'MMISNYDOH')

* BK 1/10/2007
cNPI = m.npi
lNPI_Req = m.npi_req

=OpenFile("insstat", "insstat_id")
=OpenFile("client", "client_id")
=OpenFile(gcTc_Clien, "tc_id", "the_clien")
SET RELATION TO client_id INTO client

cBlankBillID = SPACE(LEN(claim_hd.bill_id))
cBlankCINN   = SPACE(LEN(claim_hd.cinn))

=openfile('CLAIMLOG')

nCLSaveRec = RecNo()
cCLSaveTag = Tag()

SET ORDER TO LOG_ID

dBill_Date = MyLookup('claimlog', 'last_run', cBill_ID, 'log_id', 'log_id')
dThru_date = MyLookup('claimlog', 'thru_date', cBill_ID, 'log_id', 'log_id')

*-*IF !lreprocess
*-*	cDiskCond = "(claim_hd.bill_id = cBill_ID OR " +;
*-*					"((claim_hd.bill_id	= cBlankBillID OR claim_hd.processed = ' ') AND " +;
*-*		 			"claim_hd.prov_id	= cProv_ID AND " +;
*-*		 			"claim_hd.prov2_id = cProv2_ID)) "
*-*ELSE
*-*	cDiskCond = "claim_hd.bill_id = cBill_ID "
*-*ENDIF

SELECT ;
	claim_hd.prov_id, ;
	claim_hd.prov_num, ;
	claim_hd.prov2_id, ;
	claim_hd.loc_code, ;
	claim_hd.client_id, ;
	claim_hd.tc_id, ;
	claim_hd.invoice, ;
	claim_dt.line_no, ;
	claim_hd.insstat_id, ;
	claim_hd.orig_ref,;
	claim_hd.treat_auth,;
	IIF(claim_hd.adj_void = 'A', '7', IIF(claim_hd.adj_void = 'V', '8', '1')) as claim_type, ;
	claim_hd.cinn,;
	claim_hd.dob,;
	claim_hd.sex,;
	strtran(claim_hd.icd9code1, '.') as icd9code1,;
	claim_hd.pat_stat2, ;
	claim_hd.bill_phys, ;
	claim_hd.pr_license, ;
	claim_hd.pr_type, ;
	claim_hd.pr_tax_id, ;
	claim_hd.over90_res, ;
	claim_hd.place, ;
	claim_dt.rate_code, ;
	claim_dt.proc_code, ;
	claim_dt.modifier, ;
	claim_dt.number, ;
	claim_dt.date, ;
	{} as from_date, ;
	{} as thru_date, ;
	claim_dt.prior_appr, ;
	claim_dt.amount, ;
	claim_dt.reimb_amt, ;
	claim_dt.amt_paid, ;
	claim_dt.copay_type, ;
	claim_dt.copay_paid, ;
	claim_dt.copay_amt  ;
FROM ;
	claim_hd, claim_dt;
WHERE ;
	(claim_hd.bill_id = cBill_ID OR ;
		(!lReprocess AND ;
		(claim_hd.bill_id	= cBlankBillID OR claim_hd.processed = ' ') AND ;
		claim_hd.prov_id	= cProv_ID AND ;
		claim_hd.prov2_id = cProv2_ID)) ;
	.AND. claim_hd.invoice = claim_dt.invoice ;
	.AND. claim_type = cClaimType ;
	.AND. !EMPTY(claim_hd.cinn);
INTO CURSOR ;
	claim_cur

*	.AND. claim_hd.cinn <> cBlankCINN ;

INDEX ON ;
	prov_id + ;
	prov2_id + ;
	loc_code + ;
	tc_id + ;
	invoice ;
TAG main

IF reccount('claim_cur') = 0
	oApp.msg2user('INFORM','No claims can be found for requested period')
	=CleanUp()
	RETURN
ENDIF

oApp.msg2user('OFF')

* Get the destination for the medicaid disk
IF !DiskDest() 
	=CleanUp()
	RETURN
ENDIF

IF EMPTY(cDisk)
	oApp.msg2user('INFORM','Could not create work file.')
	=CleanUp()
	RETURN
ELSE
	cSerial	= '1' + GetNextID("DISK_SER")
	cMedFile = GETENV("TEMP")
	cMedFile = IIF(EMPTY(cMedFile), "C:\", cMedFile+"\") + SYS(3) + ".TMP"
	
*-*	DO WHILE LEFT(cSerial, 1) = '0'
*-*		cSerial = RIGHT(cSerial, LEN(cSerial) - 1)
*-*	ENDDO
	
	ndisk = FCREATE(cMedFile)
	IF ndisk <= 0
		oApp.msg2user('INFORM','Could not create work file.')
		=CleanUp()
		RETURN
	ENDIF
ENDIF

oThermo = createobject('thermobox', "Creating Medicaid Disk ...", " ")
oThermo.show

nDone = 0

* prepare a list of clients demographics	
select distinct ;
	claim_cur.client_id, ;
	claim_cur.tc_id, ;
	claim_cur.loc_code, ;
	iif(insstat.prim_sec = 1, 'P', IIF(insstat.prim_sec = 2, 'S', 'T')) as priority, ;
	insstat.group_num, ;
	oApp.DecipherVar(client.last_name) as last_name, ;
	oApp.DecipherVar(client.first_name) as first_name, ;
	client.mi, ;
	oApp.DecipherVar(claim_cur.cinn) as pol_num, ;
	claim_cur.dob, ;
	claim_cur.sex, ;
	oApp.DecipherVar(client.ssn) as ssn ;
from ;
	claim_cur, insstat, client ;
where ;
	claim_cur.client_id = client.client_id and ;
	claim_cur.insstat_id = insstat.insstat_id ;
into cursor ;
	temp_cur

INDEX ON tc_id TAG tc_id

oApp.ReopenCur("temp_cur", "subs_cur", .t.)
INDEX ON client_id TAG client_id ADDI
INDEX ON loc_code + UPPER(last_name + first_name) + tc_id TAG work_order ADDI

SET ORDER TO work_order

* prepare addresses separately, to be on the safe side
SELECT distinct ;
	subs_cur.tc_id, ;
	subs_cur.client_id, ;
	strtran(strtran(oApp.DecipherVar(address.street1), ':', '.'), '*', '-') as street1, ;
	strtran(strtran(address.street2, ':', '.'), '*', '-') as street2, ;
	address.city, ;
	IIF(address.zip <> '99999', PADR(address.zip, 5, '0'), '10001') AS Zip, ;
	State.code AS state, ;
	client.phhome, ;
	client.phwork ;
FROM ;
	subs_cur, client, cli_hous, address, State ;
WHERE ;
	subs_cur.client_id = client.client_id and ;
	client.client_id = cli_hous.client_id and ;
	cli_hous.hshld_id = address.hshld_id and ;
	address.st = State.code and ;
	cli_hous.lives_in ;
INTO CURSOR addr_cur

INDEX ON tc_id TAG tc_id

SELECT subs_cur
SET RELA TO tc_id INTO addr_cur

* prepare staff list for billing physician info
SELECT distinct ;
	claim_cur.bill_phys, ;
	staff.last, ;
	staff.first, ;
	staff.mi, ;
	staff.medicaid, ;
	staff.npi ;
FROM ;
	claim_cur, userprof, staff ;
WHERE ;
	claim_cur.bill_phys = userprof.worker_id and ;
	userprof.staff_id = staff.staff_id ;
INTO CURSOR staff_cur

INDEX ON bill_phys TAG bill_phys

*-- Write out the header **********************************************************
=FileHeader(nDisk)

* Create a list of provider + Loc. Code combination. 
* Use for billing provider info
select distinct ;
	allprovcur.*, ;
	claim_cur.loc_code ;
from ;
	allprovcur, claim_cur ;
where ;
	allprovcur.prov2_id = claim_cur.prov2_id ;
order by ;
	loc_code ;
into cursor ;
	prov_cur

SCAN
	scatter fields loc_code memvar 

	*-- Write out the provider info (includes provider num and loc. code)
	=ProviderInfo(nDisk)
	
	SELECT subs_cur
	
	SCAN FOR loc_code = m.loc_code
	
		cSaveTC_ID = subs_cur.tc_id

		SELECT claim_cur

		LOCATE FOR claim_cur.loc_code = m.loc_code AND claim_cur.tc_id = subs_cur.tc_id	
		
		DO WHILE .t.
			*-- Write out the client (=subscriber=patient) info. Includes payer info
			=SubscriberInfo(nDisk)
			
			*-- scan through each claim *********************************************
			nCount = 0
			
			DO WHILE claim_cur.loc_code = m.loc_code AND claim_cur.tc_id = subs_cur.tc_id
			
				*-- Claim Information
				=ClaimInfo(nDisk)
	
				*-- Line Information
				=LineInfo(nDisk)
				
				* update claim - mark as "disk created"
				IF SEEK(claim_cur.invoice, 'CLAIM_HD')
					
					* Mark claim as processed
					REPLACE ;
						claim_hd.processed WITH "D", ;
						claim_hd.user_id   WITH gcWorker, ;
						claim_hd.dt        WITH Date(), ;
						claim_hd.tm        WITH Time()
		
					IF EMPTY(CLAIM_HD.BILL_ID)
						REPLACE	claim_hd.bill_id WITH cBill_ID
					ENDIF
	
				ENDIF
	
				*--update thermometer bar
				nDone = nDone + 1
				nPct = ROUND((nDone/RecCount("claim_cur")) * 100, 0)
	
				IF nPctHold <> nPct  && Update thermo every 1%
					***DO updtherm WITH nPct, 'Completed ' + STR(nPct,3) + '%' IN thermo
               oThermo.refresh('Completed ', nPct)
					nPctHold = nPct
				ENDIF
				
				SELECT claim_cur
				SKIP

				nCount = nCount + 1
				
				IF nCount >= 100
					EXIT
				ENDIF
			ENDDO
			
			IF cSaveTC_ID <> claim_cur.tc_id
				EXIT
			ENDIF
	
			SELECT subs_cur
		ENDDO
	ENDSCAN
	
	select prov_cur
ENDSCAN

*-- write out the file footer info (SE, GE, IAE) ******************************************
=FileFooter(nDisk)

=FCLOSE(ndisk)

* Copy the file onto the disk
IF lPhaseII
	Copy File (cMedFile) To (cDisk + cFileName)
ELSE
	=Block80File(cMedFile, cDisk + cFileName)
ENDIF

IF File(cDisk + cFileName)
	oApp.Msg2User("FILEOK", cFileName, cDisk)
ELSE
	oApp.Msg2User("FILENOTOK", cFileName, cDisk)
ENDIF

ERASE (cMedFile)

* clean up data environment
=CleanUp()

oApp.msg2user('OFF')
oThermo.Release

* Prepare data for report
INSERT INTO printdata	;
		(magnetic,	;
		cur_year,	;
		jul_day,	;
		prov_id,	;
		prov_num,	;
		serial_num, ;
		no_invcs,	;
		no_claims,	;
		no_records,	;
		tot_amt, ;
      cDate, ;
      cTime)	;
	VALUES ;
		(cSub_ID,	;
		Right(cCur_Year,2),	;
		nJul_Day,	;
		cProv_id,	;
		cProv_Num,	;
		cSerial,	;
		nNo_Invcs,	;
		nNo_Claims,	;
		nSegmentCount,	;
		nTot_Amt, ;
      Date(),;
      Time())

* Print Report
gcRptAlias = 'printdata'
SELECT printdata
nPrint = oApp.Msg2User('PRINTREP',"Medicaid Disk summary")
DO CASE
	CASE nPrint = 1
		REPORT FORM rpt_med_disk To Printer Prompt Noconsole NODIALOG 
	CASE nPrint = 2
		oApp.rpt_print(5, .t., 1, 'rpt_med_disk', 1, 2)
ENDCASE

*--If successful, mark that the disk was created in the log
IF lcontproc 
   
	Select claimlog
   Locate for claimlog.log_id = lv_claimlog_tmp.log_id
     
   IF !lreprocess
    	    REPLACE claimlog.disk_made WITH .T. ;
       			   claimlog.disk_date WITH DATE(), ;
       			   claimlog.user_id   WITH gcWorker, ;
       			   claimlog.dt        WITH DATE(), ;
       			   claimlog.tm        WITH TIME()
                
          Select lv_claimlog_tmp
          Replace ;
                  lv_claimlog_tmp.disk_made With 'Yes ', ;
                  lv_claimlog_tmp.ldisk_made With .t.,;
                  lv_claimlog_tmp.disk_date WITH DATE(), ;
                  lv_claimlog_tmp.user_id   With gcWorker, ;
                  lv_claimlog_tmp.dt        With DATE(), ;
                  lv_claimlog_tmp.tm        With TIME()  
                  
          Select claimlog
                          
   ELSE
   	    REPLACE claimlog.disk_date WITH DATE(), ;
   				   claimlog.user_id   WITH gcWorker, ;
   				   claimlog.dt        WITH DATE(), ;
   				   claimlog.tm        WITH TIME()
                  
          Select lv_claimlog_tmp        
          REPLACE lv_claimlog_tmp.disk_date WITH DATE(), ;
                  lv_claimlog_tmp.user_id   WITH gcWorker, ;
                  lv_claimlog_tmp.dt        WITH DATE(), ;
                  lv_claimlog_tmp.tm        WITH TIME()  
                  
           Select claimlog            
               
   EndIf  
ENDIF

RETURN


*************************************************************
FUNCTION CleanUp

SELECT claim_hd
SET RELATION TO

SELECT the_clien
SET RELATION TO

SELECT claimlog
IF Between(nCLSaveRec, 1, RecCount())
	GO nCLSaveRec
ENDIF

SET ORDER TO (cCLSaveTag)

RETURN

*****************************************************************************************************
FUNCTION FileHeader
PARAMETER nFile
PRIVATE cOutputStr
*----------------------------------------------------------------------------------------------------
*1.Interchange Control Header------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*ISA*00*          *00*          *ZZ*000000000002589*ZZ*            25B*021211*1045*U*00401*000000001*0*T*:
*----------------------------------------------------------------------------------------------------

cOutputStr = 'ISA*'
cOutputStr = cOutputStr + '00*'										&& ISA01 -- Auth. Info Qualif.
cOutputStr = cOutputStr + '          *'							&& ISA02 -- Author. Information
cOutputStr = cOutputStr + '00*'										&& ISA03 -- Security Info Qualifier
cOutputStr = cOutputStr + '          *'							&& ISA04 -- Security Information
cOutputStr = cOutputStr + 'ZZ*'										&& ISA05 -- Interchange ID qualifier
cOutputStr = cOutputStr + PADR(cSub_ID, 15) + '*'				&& ISA06 -- Interchange Sender ID
cOutputStr = cOutputStr + 'ZZ*'										&& ISA07 -- Interchange ID qualifier

*cOutputStr = cOutputStr + 'MMISNYDOH      *'						&& ISA08 -- Interchange Receiver ID
cOutputStr = cOutputStr + PADR(cIntRecID, 15) + '*'			&& ISA08 -- Interchange Receiver ID

cOutputStr = cOutputStr + cTranDate + '*'							&& ISA09 -- Interchange Date
cOutputStr = cOutputStr + cTranTime+ '*'							&& ISA10 -- Interchange Time
cOutputStr = cOutputStr + 'U*'										&& ISA11 -- Interchange Control Standards ID
cOutputStr = cOutputStr + '00401*'									&& ISA12 -- Interchange Control Version Number
cOutputStr = cOutputStr + PADL(cSerial, 9, '0') + '*'			&& ISA13 -- Interchange Control Number
cOutputStr = cOutputStr + '0*'										&& ISA14 -- Acknowledgement Requested
cOutputStr = cOutputStr + cIndicate + '*'							&& ISA15 -- Usage Indicator P/T - prod/test
cOutputStr = cOutputStr + ':'											&& ISA16 -- Component Element Separator

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*2.Functional Group Header------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*GS*HC*000000000002589*25B*20021211*1045*1*X*004010X096
*----------------------------------------------------------------------------------------------------

cOutputStr = 'GS*'
cOutputStr = cOutputStr + 'HC*'										&& GS01 -- Functional Identifier Code
cOutputStr = cOutputStr + Alltrim(cSub_ID) + '*'							&& GS02 -- Application Sender Code
*cOutputStr = cOutputStr + 'MMISNYDOH*'								&& GS03 -- Application Receiver Code
cOutputStr = cOutputStr + cIntRecID + '*'							&& GS03 -- Application Receiver Code

cOutputStr = cOutputStr + '20' + cTranDate + '*'				&& GS04 -- Date
cOutputStr = cOutputStr + cTranTime + '*'							&& GS05 -- Time
cOutputStr = cOutputStr + cSerial + '*'							&& GS06 -- Group Control Number
cOutputStr = cOutputStr + 'X*'										&& GS07 -- Responsible Agency Code
cOutputStr = cOutputStr + '004010X096A1'							&& GS08 -- Version Release Code

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*3.Transaction Set Header----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*ST*837*000000001
*----------------------------------------------------------------------------------------------------

cOutputStr = 'ST*'
cOutputStr = cOutputStr + '837*'										&& ST01 -- TS ID Code
cOutputStr = cOutputStr + cSerial + '*'							&& ST02 -- TS Control Number

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*4.Beginning of Hierarchical Transaction----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*BHT*0019*00*1*20021211*1045*CH
*----------------------------------------------------------------------------------------------------

cOutputStr = 'BHT*'
cOutputStr = cOutputStr + '0019*'									&& BHT01 -- Hierarchical Structure Code
cOutputStr = cOutputStr + '00*'										&& BHT02 -- Transaction Set Purpose Code
cOutputStr = cOutputStr + cSerial + '*'							&& BHT03 -- Reference Information
cOutputStr = cOutputStr + CCYYMMDD(dBill_Date) + '*'			&& BHT04 -- Date
cOutputStr = cOutputStr + cTranTime+ '*'							&& BHT05 -- Time
cOutputStr = cOutputStr + 'CH'										&& BHT06 -- Transaction Type Code

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*5.Transmition Set Identification--------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*REF*87*004010X096A1
*----------------------------------------------------------------------------------------------------

cOutputStr = 'REF*'
cOutputStr = cOutputStr + '87*'										&& REF01 -- Reference ID Qualifier
IF cIndicate = 'P'
	cOutputStr = cOutputStr + '004010X096A1'							&& REF02 -- Transmition Type Code - production
ELSE
	cOutputStr = cOutputStr + '004010X096DA1'							&& REF02 -- Transmition Type Code - test
ENDIF

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
* loop 1000A - submitter
*----------------------------------------------------------------------------------------------------
*6.Submitter Name -----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*NM1*41*2*NETCARE*****46*000000002589
*----------------------------------------------------------------------------------------------------

cOutputStr = 'NM1*'
cOutputStr = cOutputStr + '41*'                 && NM101 -- Entity ID code
cOutputStr = cOutputStr + '2*'                  && NM102 -- Entity Type Qualifier (2=non-person) 
cOutputStr = cOutputStr + cProv_Name + '*'      && NM103 -- Submitter Name
cOutputStr = cOutputStr + '*'                   && NM104 -- NA - name first
cOutputStr = cOutputStr + '*'                   && NM105 -- NA - name middle
cOutputStr = cOutputStr + '*'                   && NM106 -- NA - name prefix
cOutputStr = cOutputStr + '*'                   && NM107 -- NA - name suffix
cOutputStr = cOutputStr + '46*'                 && NM108 -- ID Code Qualifier
cOutputStr = cOutputStr + Alltrim(cSub_ID)   	&& NM109 -- ID code

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*7.Submitter EDI Contact Info -----------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*PER*IC*LAURA DANIELE*TE*6144661556
*----------------------------------------------------------------------------------------------------

cOutputStr = 'PER*'
cOutputStr = cOutputStr + 'IC*'										&& PER01 -- Entity ID code
cOutputStr = cOutputStr + RTRIM(m.contact) + '*'				&& PER02 -- Submitter Contact Name

cOutputStr = cOutputStr + 'TE*'										&& PER03 -- Commun. Number Qualifier
cOutputStr = cOutputStr + cContPhone								&& PER04 -- Commun. Number (Phone)

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
* loop 1000B - receiver
*----------------------------------------------------------------------------------------------------
*8.Receiver Name -----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*NM1*40*2*MACSIS*****46*25B
*----------------------------------------------------------------------------------------------------

cOutputStr = 'NM1*'
cOutputStr = cOutputStr + '40*'										&& NM101 -- Entity ID code
cOutputStr = cOutputStr + '2*'										&& NM102 -- Entity Type Qualifier (2=non-person) 
cOutputStr = cOutputStr + 'NYSDOH*'									&& NM103 -- Receiver Name
cOutputStr = cOutputStr + '*'											&& NM104 -- NA - name first
cOutputStr = cOutputStr + '*'											&& NM105 -- NA - name middle
cOutputStr = cOutputStr + '*'											&& NM106 -- NA - name prefix
cOutputStr = cOutputStr + '*'											&& NM107 -- NA - name suffix
cOutputStr = cOutputStr + '46*'										&& NM108 -- ID Code Qualifier
cOutputStr = cOutputStr + '141797357'								&& NM109 -- ID code

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

RETURN

*****************************************************************************************************
FUNCTION ProviderInfo
PARAMETER nFile
PRIVATE cOutputStr
*----------------------------------------------------------------------------------------------------
* loop 2000A - billing to/provider hierarchical level
*----------------------------------------------------------------------------------------------------
*9.hierarchical level -------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*HL*1**20*1
*----------------------------------------------------------------------------------------------------

nHlCount = nHlCount + 1

nProviderHL = nHlCount

cOutputStr = 'HL*'
cOutputStr = cOutputStr + LTrim(STR(nHlCount, 10,0)) + '*'	&& HL01 -- Hierarchical ID Number
cOutputStr = cOutputStr + '*'											&& HL02 -- Hierarchical Parent ID (N/A)
cOutputStr = cOutputStr + '20*'										&& HL03 -- Hierarchical Level code
cOutputStr = cOutputStr + '1'											&& HL04 -- Hierarchical child code

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*11.Provider Name -----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*NM1*85*2*NETCARE*****24*31-0814079
*----------------------------------------------------------------------------------------------------

cOutputStr = 'NM1*'
cOutputStr = cOutputStr + '85*'										&& NM101 -- Entity ID code
cOutputStr = cOutputStr + '2*'										&& NM102 -- Entity Type Qualifier (2=non-person) 
cOutputStr = cOutputStr + cProv_Name + '*'						&& NM103 -- Provider Name
cOutputStr = cOutputStr + '*'											&& NM104 -- NA - name first
cOutputStr = cOutputStr + '*'											&& NM105 -- NA - name middle
cOutputStr = cOutputStr + '*'											&& NM106 -- NA - name prefix
cOutputStr = cOutputStr + '*'											&& NM107 -- NA - name suffix

* BK 1/10/2007 - add NPI handling
IF !EMPTY(cNPI)
	cOutputStr = cOutputStr + 'XX*'										&& NM108 -- ID Code Qualifier
	cOutputStr = cOutputStr + cNPI										&& NM109 -- NPI
ELSE
	cOutputStr = cOutputStr + '24*'										&& NM108 -- ID Code Qualifier
	cOutputStr = cOutputStr + cTax_ID									&& NM109 -- Provider Tax ID
ENDIF
*-*OutputStr = cOutputStr + '24*'									&& NM108 -- ID Code Qualifier
*-*OutputStr = cOutputStr + cTax_ID									&& NM109 -- Provider Tax ID

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*12.Provider Address -----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*N3*199 S. CENTRAL ST
*----------------------------------------------------------------------------------------------------

cOutputStr = 'N3*'
cOutputStr = cOutputStr + RTRIM(m.street1) + '*'						&& N301 -- Address Line 1 
cOutputStr = cOutputStr + RTRIM(m.street2)								&& N302 -- Address Line 2

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*13.Provider Geographical Location ------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*N4*COLUMBUS*OH*43228
*----------------------------------------------------------------------------------------------------

cOutputStr = 'N4*'
cOutputStr = cOutputStr + RTRIM(m.city) + '*'							&& N401 -- City
cOutputStr = cOutputStr + RTRIM(m.st) + '*'								&& N402 -- State
cOutputStr = cOutputStr + RTRIM(m.zip)										&& N403 -- Zip

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*14.Provider Secondary Identification (Provider Number, UPIN) ---------------------------------------
*----------------------------------------------------------------------------------------------------
*REF*1G*000000002589
*----------------------------------------------------------------------------------------------------
* BK 1/10/2007 - add NPI handling
* Supply here the tax ID if NPI was supplied in the NM*85 record
IF !EMPTY(cNPI)
	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + 'EI*'										&& REF01 Reference ID Qualifier
	cOutputStr = cOutputStr + RTRIM(cTax_ID)							&& REF02 Provider Secondary ID
	
	nSegmentCount = nSegmentCount + 1
	
	=WriteOutput(nFile, cOutputStr)
ENDIF

* BK 1/10/2007 - add NPI handling
* When NPI is fully implemented - stop sending provider number and locator code
IF !lNPI_Req
	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + '1D*'										&& REF01 Reference ID Qualifier
	cOutputStr = cOutputStr + RTRIM(m.prov_num)						&& REF02 Provider Secondary ID
	
	nSegmentCount = nSegmentCount + 1
	
	=WriteOutput(nFile, cOutputStr)
	
	*----------------------------------------------------------------------------------------------------
	*14a.Provider Secondary Identification, continued (NY Loc Code) -------------------------------------
	*----------------------------------------------------------------------------------------------------
	*REF*LU*03
	*----------------------------------------------------------------------------------------------------
	
	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + 'LU*'										&& REF01 Reference ID Qualifier
	
	IF lPhaseII
		cOutputStr = cOutputStr + PADL(ALLTRIM(m.loc_code), 3, '0')			&& REF02 Provider Secondary ID
	ELSE
		cOutputStr = cOutputStr + m.loc_code
	ENDIF
	
	nSegmentCount = nSegmentCount + 1
	
	=WriteOutput(nFile, cOutputStr)
ENDIF

*----------------------------------------------------------------------------------------------------
*15.Provider Contact Info -----------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*PER*IC*NETCARE*TE*6144661556
*----------------------------------------------------------------------------------------------------

cOutputStr = 'PER*'
cOutputStr = cOutputStr + 'IC*'										&& PER01 -- Entity ID code
cOutputStr = cOutputStr + RTRIM(m.contact) + '*'				&& PER02 -- Provider Contact Name

cOutputStr = cOutputStr + 'TE*'										&& PER03 -- Commun. Number Qualifier
cOutputStr = cOutputStr + cContPhone								&& PER04 -- Commun. Number (Phone)

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

RETURN

*****************************************************************************************************
FUNCTION SubscriberInfo
PARAMETER nFile
PRIVATE cOutputStr
*----------------------------------------------------------------------------------------------------
* loop 2000B - subscriber hierarchical level
*----------------------------------------------------------------------------------------------------
*16.hierarchical level -------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*HL*2*1*22*0
*----------------------------------------------------------------------------------------------------

nHlCount = nHlCount + 1
subscriberHL = nHlCount

cOutputStr = 'HL*'
cOutputStr = cOutputStr + LTRIM(STR(nHlCount, 10, 0)) + '*'		&& HL01 -- Hierarchical ID Number
cOutputStr = cOutputStr + LTRIM(STR(nProviderHL, 10, 0)) + '*'	&& HL02 -- Hierarchical Parent ID (N/A)
cOutputStr = cOutputStr + '22*'											&& HL03 -- Hierarchical Level code
cOutputStr = cOutputStr + '0'												&& HL04 -- Hierarchical child code

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*17.Subscriber Info ---------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*SBR*P*18*******ZZ
*----------------------------------------------------------------------------------------------------

cOutputStr = 'SBR*'
cOutputStr = cOutputStr + subs_cur.priority + '*'					&& SBR01 -- Payer Resqp. Seq#/Code(P-S-T)
cOutputStr = cOutputStr + '18*'											&& SBR02 -- Relationship Code

*-*cOutputStr = cOutputStr + RTrim(subs_cur.group_num) + '*'		&& SBR03 -- Reference Id. (Group number)
*-*cOutputStr = cOutputStr + IIF(EMPTY(subs_cur.group_num), ;
*-*										'MEDICAID*', '*')						&& SBR04 -- Name. (Group name)

cOutputStr = cOutputStr + '*'												&& SBR03 -- Reference Id. (Group number)
cOutputStr = cOutputStr + 'MEDICAID*'									&& SBR04 -- Name. (Group name)

cOutputStr = cOutputStr + '*'												&& SBR05 -- Insurance Type Code
cOutputStr = cOutputStr + '*'												&& SBR06 -- N/A COB code
cOutputStr = cOutputStr + '*'												&& SBR07 -- N/A Y/N cond or resp. code
cOutputStr = cOutputStr + '*'												&& SBR08 -- N/A Empl. stat code
cOutputStr = cOutputStr + 'MC'											&& SBR09 -- Claim Filing Indicator

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*18. 2010BA Subscriber Name -------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*NM1*IL*1*MANDERLIN*JAMES*L***MI*1009971
*----------------------------------------------------------------------------------------------------

cOutputStr = 'NM1*'
cOutputStr = cOutputStr + 'IL*'											&& NM101 -- Entity ID code
cOutputStr = cOutputStr + '1*'											&& NM102 -- Entity Type Qualifier (1=person) 
cOutputStr = cOutputStr + RTrim(subs_cur.last_name) + '*'		&& NM103 -- Subscriber Last Name
cOutputStr = cOutputStr + RTrim(subs_cur.first_name) + '*'		&& NM104 -- Subscriber first name
cOutputStr = cOutputStr + RTrim(subs_cur.mi) + '*'					&& NM105 -- Subscriber middle name
cOutputStr = cOutputStr + '*'												&& NM106 -- NA - name prefix
cOutputStr = cOutputStr + '*'												&& NM107 -- NA - name suffix
cOutputStr = cOutputStr + 'MI*'											&& NM108 -- ID Code Qualifier
cOutputStr = cOutputStr + RTRIM(subs_cur.pol_num)					&& NM109 -- ID Code 

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*19.Subscriber Address -----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*N3*7143 SOUTH HIGH STREET
*----------------------------------------------------------------------------------------------------

cOutputStr = 'N3*'
cOutputStr = cOutputStr + RTrim(IIF(!EMPTY(addr_cur.street1), addr_cur.street1, m.street1)) + '*'	&& N301 -- Address Line 1 
cOutputStr = cOutputStr + RTrim(IIF(!EMPTY(addr_cur.street2), addr_cur.street2, m.street2))			&& N302 -- Address Line 2

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*20.Subscriber City/State/Zip -----------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*N4*COLUMBUS*OH*47714
*----------------------------------------------------------------------------------------------------

cOutputStr = 'N4*'
cOutputStr = cOutputStr + RTrim(IIF(!EMPTY(addr_cur.city), addr_cur.city, m.city)) + '*'			&& N401 -- City
cOutputStr = cOutputStr + RTrim(IIF(!EMPTY(addr_cur.state), addr_cur.state, m.st)) + '*'			&& N402 -- State
cOutputStr = cOutputStr + RTrim(IIF(!EMPTY(addr_cur.zip), addr_cur.zip, m.zip))						&& N403 -- Zip

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*21.Subscriber Demographics Info --------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DMG*D8*19610902*M
*----------------------------------------------------------------------------------------------------

cOutputStr = 'DMG*'
cOutputStr = cOutputStr + 'D8*'											&& DMG01 Date in CCYYMMDD format
cOutputStr = cOutputStr + CCYYMMDD(subs_cur.dob)  + '*'				&& DMG02 DOB
cOutputStr = cOutputStr + RTrim(subs_cur.sex)						&& DMG03 Gender

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

IF !EMPTY(subs_cur.ssn) AND Len(RTrim(subs_cur.ssn)) = 9
	*----------------------------------------------------------------------------------------------------
	*22.Subscriber Secondary Identification -------------------------------------------------------------
	*----------------------------------------------------------------------------------------------------
	*REF*SY*361455197
	*----------------------------------------------------------------------------------------------------

	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + 'SY*'										&& REF01 Reference ID Qualif.
	cOutputStr = cOutputStr + RTrim(subs_cur.ssn)					&& REF02 Reference ID (SSN)

	nSegmentCount = nSegmentCount + 1

	=WriteOutput(nFile, cOutputStr)
ENDIF

*----------------------------------------------------------------------------------------------------
* loop 2010BB - Payer Name
*----------------------------------------------------------------------------------------------------
*23.Payer Name -----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*NM1*PR*2*NYSDOH*****PI*141797357
*----------------------------------------------------------------------------------------------------

cOutputStr = 'NM1*'
cOutputStr = cOutputStr + 'PR*'											&& NM101 -- Entity ID code
cOutputStr = cOutputStr + '2*'											&& NM102 -- Entity Type Qualifier (2=non-person) 
cOutputStr = cOutputStr + 'NYSDOH*'										&& NM103 -- Payer Name
cOutputStr = cOutputStr + '*'												&& NM104 -- NA - name first
cOutputStr = cOutputStr + '*'												&& NM105 -- NA - name middle
cOutputStr = cOutputStr + '*'												&& NM106 -- NA - name prefix
cOutputStr = cOutputStr + '*'												&& NM107 -- NA - name suffix
cOutputStr = cOutputStr + 'PI*'											&& NM108 -- ID Code Qualifier
cOutputStr = cOutputStr + '141797357'									&& NM109 -- ID code

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

RETURN

*****************************************************************************************************
FUNCTION ClaimInfo
PARAMETER nFile
PRIVATE cOutputStr
*----------------------------------------------------------------------------------------------------
* loop 2300 - claim information
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*30.Claim Information ---------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*CLM*HEADERPATCONTNO*158.20***11:A:1*Y*A*Y*Y*C
*----------------------------------------------------------------------------------------------------

cPlace = RTRIM(claim_cur.place)

*	IIF(!EMPTY(claim_hd.place), claim_hd.place, '89') as place, ;

* convert old place of service codes to HIPAA
DO CASE
	CASE EMPTY(cPlace)
		cPlace = '89'
	CASE cPlace == '6'
		cPlace = '73'
	CASE cPlace == '11'
		cPlace = '13'
ENDCASE

cOutputStr = 'CLM*'
cOutputStr = cOutputStr + claim_cur.invoice + '*'								&& CLM01 -- Claim Submitter's Identifier
cOutputStr = cOutputStr + LTrim(STR(claim_cur.amount, 12, 2)) + '*'		&& CLM02 -- Monetary Amount -total charges
cOutputStr = cOutputStr + '*'															&& CLM03 -- N/A - Claim Filing Ind.
cOutputStr = cOutputStr + '*'															&& CLM04 -- N/A - Non-Inst. Claim Type Code
*CLM05 -- Health care service location
cOutputStr = cOutputStr + cPlace + ':'						&& CLM05-1 -- Facility Code Value
cOutputStr = cOutputStr + 'A:'														&& CLM05-2 -- Fac. Code Qualifier
cOutputStr = cOutputStr + claim_cur.claim_type + '*'							&& CLM05-3 -- Claim Freq. Type Code

cOutputStr = cOutputStr + 'Y*'														&& CLM06 -- Provider Signature on File
cOutputStr = cOutputStr + 'A*'														&& CLM07 -- Medicare Assignment Code
cOutputStr = cOutputStr + 'Y*'														&& CLM08 -- Assignment of Benefits Indicator
cOutputStr = cOutputStr + 'Y*'														&& CLM09 -- Release of Information Code
cOutputStr = cOutputStr + '*'															&& CLM10 -- Patient Signature Source
cOutputStr = cOutputStr + '*'															&& CLM11 -- Related Causes Information
cOutputStr = cOutputStr + '*'															&& CLM12 -- !! (come back) Special Program Code
cOutputStr = cOutputStr + '*'															&& CLM13 -- N/A Y/N cond. or resp. code
cOutputStr = cOutputStr + '*'															&& CLM14 -- N/A level of service code
cOutputStr = cOutputStr + '*'															&& CLM15 -- N/A Y/N cond. or resp. code
cOutputStr = cOutputStr + '*'															&& CLM16 -- Provider Agreement code (P if non-part prov )
cOutputStr = cOutputStr + '*'															&& CLM17 -- N/A Claim Status Code
cOutputStr = cOutputStr + 'Y*'														&& CLM18 -- Y/N cond. or resp. code - Explanation of Benefits Ind.
cOutputStr = cOutputStr + '*'															&& CLM19 -- N/A Claim Submission Reason Code
cOutputStr = cOutputStr + RTRIM(MyLookup('over_90', 'x12_code', ;
									claim_cur.over90_res, 'code', 'code'))			&& CLM20 -- Delay Reason Code

nNo_Invcs = nNo_Invcs + 1
nNo_Claims = nNo_Claims + 1
nTot_Amt = nTot_Amt + claim_cur.amount

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
* Statement Dates --------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DTP*434*D8*20030715
*----------------------------------------------------------------------------------------------------

cOutputStr = 'DTP*'
cOutputStr = cOutputStr + '434*'													&& DTP01 Date Time Qualifier

IF !EMPTY(claim_cur.from_date) 
	cOutputStr = cOutputStr + 'RD8*'												&& DTP02 Date in CCYYMMDD format
	cOutputStr = cOutputStr + CCYYMMDD(claim_cur.from_date) + '-' + ;
					CCYYMMDD(claim_cur.thru_date)									&& DTP03 Service Dates (Range)
ELSE 
	cOutputStr = cOutputStr + 'D8*'												&& DTP02 Date in CCYYMMDD format
	cOutputStr = cOutputStr + CCYYMMDD(claim_cur.date)						&& DTP03 Service Date
ENDIF

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

IF !EMPTY(claim_cur.orig_ref)
	*----------------------------------------------------------------------------------------------------
	*32.Original Reference Number ----------------------------------------------------------
	*----------------------------------------------------------------------------------------------------
	*REF*F8*123456789
	*----------------------------------------------------------------------------------------------------

	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + 'F8*'												&& REF01 -- Reference ID qualifier
	cOutputStr = cOutputStr + RTRIM(claim_cur.orig_ref)					&& REF02 -- Original Ref. Number

	nSegmentCount = nSegmentCount + 1

	=WriteOutput(nFile, cOutputStr)
ENDIF

IF !EMPTY(claim_cur.treat_auth) 
	*----------------------------------------------------------------------------------------------------
	*31.Prior Authorization or Referral Number ----------------------------------------------------------
	*----------------------------------------------------------------------------------------------------
	*REF*G1*12345
	*----------------------------------------------------------------------------------------------------

	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + 'G1*'												&& REF01 -- Reference ID qualifier
	cOutputStr = cOutputStr + RTRIM(claim_cur.treat_auth)					&& REF02 -- Prior Auth. or Referral Number

	nSegmentCount = nSegmentCount + 1

	=WriteOutput(nFile, cOutputStr)
ENDIF

*----------------------------------------------------------------------------------------------------
*Medical Record Number ----------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*REF*EA*123456789
*----------------------------------------------------------------------------------------------------

cOutputStr = 'REF*'
cOutputStr = cOutputStr + 'EA*'													&& REF01 -- Reference ID qualifier
*-*cOutputStr = cOutputStr + claim_cur.tc_id										&& REF02 -- Medical Record Number
cOutputStr = cOutputStr + claim_cur.invoice										&& REF02 -- Medical Record Number

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*Health Care Diagnosis Code ----------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*HI*BK:3050
*----------------------------------------------------------------------------------------------------

*-*sele billtype.*, count(*) from billtype, rate_hd, claim_dt ;
*-*where billtype.code=rate_hd.bill_type and ;
*-*rate_hd.rate_hd_id = claim_dt.rate_hd_id;
*-*group by billtype.code

IF claim_cur.rate_code <> '5223'
	cDiag = RTrim(claim_cur.ICD9Code1)
	
*-*cDiag = IIF(!Empty(cDiag) and cDiag <> '?' and Len(cDiag) >= 3, cDiag, '7999')
	cDiag = IIF(!Empty(cDiag) and cDiag <> '?' and Len(cDiag) >= 3, cDiag, '042')
ELSE
	cDiag = '042'
ENDIF

cOutputStr = 'HI*'
cOutputStr = cOutputStr + 'BK:'									&& HI01-1 -- Diagnosis Type Code (BK=primary)
cOutputStr = cOutputStr + cDiag 									&& HI01-2 -- Diagnosis code (Use HIV 042 for default in URS)

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*-*IF claim_cur.rate_code <> '5223' AND !EMPTY(claim_cur.proc_code)
*-*	*----------------------------------------------------------------------------------------------------
*-*	*Principal Procedure Information ----------------------------------------------------------
*-*	*----------------------------------------------------------------------------------------------------
*-*	*HI*BR:92795:D8:20030301~
*-*	*----------------------------------------------------------------------------------------------------
*-*
*-*	cOutputStr = 'HI*'
*-*	cOutputStr = cOutputStr + 'BR:'												&& HI01-1 -- Code List Qualifier Code (BR=ICD9 procedure)
*-*	cOutputStr = cOutputStr + PADR(RTrim(StrTran(claim_cur.proc_code, '.')), 4, '0') + ':'			&& HI01-2 -- Procedure code
*-*	cOutputStr = cOutputStr + 'D8:'												&& HI01-3 -- Code List Qualifier Code (BR=ICD9 procedure)
*-*	cOutputStr = cOutputStr + CCYYMMDD(claim_cur.date)						&& HI01-4 -- Principal Procedure Date
*-*
*-*	nSegmentCount = nSegmentCount + 1
*-*
*-*	=WriteOutput(nFile, cOutputStr)
*-*ENDIF

*----------------------------------------------------------------------------------------------------
*Value Information (Rate Code)----------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*HI*BE:24:::52230~
*----------------------------------------------------------------------------------------------------

cOutputStr = 'HI*'
cOutputStr = cOutputStr + 'BE:'												&& HI01-1 -- Value Code
cOutputStr = cOutputStr + '24:'												&& HI01-2 -- Industry Code (24 = NYSDOH rate code)
cOutputStr = cOutputStr + ':'												&& HI01-3 -- N/A
cOutputStr = cOutputStr + ':'												&& HI01-4 -- N/A
cOutputStr = cOutputStr + LEFT(claim_cur.rate_code, 4)						&& HI01-5 -- Value Code Associated Amount

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

IF claim_cur.rate_code <> '5223' AND !EMPTY(claim_cur.bill_phys) AND SEEK(claim_cur.bill_phys, 'staff_cur')
	*----------------------------------------------------------------------------------------------------
	* Attending Physician Name---------------------------------------------------------------------------
	* 2310A
	*----------------------------------------------------------------------------------------------------
	*NM1*71*1*JONES*JOHN****24*31-0814079
	*----------------------------------------------------------------------------------------------------
	
	cOutputStr = 'NM1*'
	cOutputStr = cOutputStr + '71*'											&& NM101 -- Entity ID code
	cOutputStr = cOutputStr + '1*'											&& NM102 -- Entity Type Qualifier (1=person) 
	cOutputStr = cOutputStr + RTRIM(staff_cur.last) + '*'				&& NM103 -- name last or Organization  Name
	cOutputStr = cOutputStr + RTRIM(staff_cur.first) + '*'			&& NM104 -- name first
	cOutputStr = cOutputStr + RTRIM(staff_cur.mi) + '*'				&& NM105 -- name middle
	cOutputStr = cOutputStr + '*'												&& NM106 -- name prefix
	cOutputStr = cOutputStr + '*'												&& NM107 -- name suffix
	
	* BK 1/11/2007 - add handling of NPI
	IF !EMPTY(staff_cur.npi)
		cOutputStr = cOutputStr + 'XX*'											&& NM108 -- ID Code Qualifier
		cOutputStr = cOutputStr + RTRIM(onlynum(staff_cur.npi))			&& NM109 -- Provider NPI
	ELSE
		cOutputStr = cOutputStr + '24*'											&& NM108 -- ID Code Qualifier
		cOutputStr = cOutputStr + RTRIM(onlynum(claim_cur.pr_tax_id))	&& NM109 -- Provider Tax ID
	ENDIF
	
	nSegmentCount = nSegmentCount + 1
	
	=WriteOutput(nFile, cOutputStr)
	
*-*	*----------------------------------------------------------------------------------------------------
*-*	* Attending Physician Specialty Code 
*-*	*----------------------------------------------------------------------------------------------------
*-*	*PRV*PE*ZZ*203BF01OOY
*-*	*----------------------------------------------------------------------------------------------------
*-*	cOutputStr = 'PRV*'
*-*	* just for test:
*-*	cOutputStr = cOutputStr + 'PE*ZZ*101Y00000X'
*-*	
*-*	nSegmentCount = nSegmentCount + 1
*-*	
*-*	=WriteOutput(nFile, cOutputStr)

	*----------------------------------------------------------------------------------------------------
	* Attending Physician Secondary Identification 
	*----------------------------------------------------------------------------------------------------
	*REF*0B*000000002589
	*----------------------------------------------------------------------------------------------------

	*** BK 1/11/2007 - add handling of NPI - output tax ID here if NPI was suppiled in NM1*71
	IF !EMPTY(staff_cur.npi)
		cOutputStr = 'REF*'
		cOutputStr = cOutputStr + 'EI*'															&& REF01 Reference ID Qualifier

		cOutputStr = cOutputStr + RTRIM(onlynum(claim_cur.pr_tax_id))					&& REF02  -- Provider Tax ID
	
		nSegmentCount = nSegmentCount + 1
	
		=WriteOutput(nFile, cOutputStr)
	ENDIF
	*** - end of 1/11/2007
	
	cOutputStr = 'REF*'
	cOutputStr = cOutputStr + IIF(staff_cur.medicaid, '1D', '0B') + '*'				&& REF01 Reference ID Qualifier

	cProvType = claim_cur.pr_type
	IF lPhaseII
		cProvType = GetDesc('pr_type','cProvType','code','prof_code')
	ENDIF
	
	cOutputStr = cOutputStr + IIF(!staff_cur.medicaid, cProvType, '') + ;
											RTRIM(claim_cur.pr_license)							&& REF02 Provider Secondary ID
	
	nSegmentCount = nSegmentCount + 1
	
	=WriteOutput(nFile, cOutputStr)
	
ENDIF

RETURN

*****************************************************************************************************
FUNCTION LineInfo
PARAMETER nFile
PRIVATE cOutputStr

*----------------------------------------------------------------------------------------------------
* loop 2400 - service line
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
* Line Counter ---------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*LX*1
*----------------------------------------------------------------------------------------------------

cOutputStr = 'LX*'
cOutputStr = cOutputStr + '1'											&& LX01 -- Assigned Number

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
* Institutional Service ---------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*SV2*300*HC:H0036:HE*158.20*UN*1~
*----------------------------------------------------------------------------------------------------

cOutputStr = 'SV2*'

cOutputStr = cOutputStr + '0500*'															&& SV201 -- Product-Service ID  (Revenue Code)

*SV202 -- Composite Medical Procedure Identifier
IF claim_cur.rate_code <> '5223' AND !EMPTY(claim_cur.proc_code)
	cOutputStr = cOutputStr + 'HC:'																&& SV202-1 -- Product-Service ID Qualifier
	cOutputStr = cOutputStr + STRTRAN(RTrim(claim_cur.proc_code), '.')				&& SV202-2 -- Product/Service ID

	IF !EMPTY(claim_cur.modifier)
		cOutputStr = cOutputStr + ':' + RTrim(claim_cur.modifier)						&& SV202-3 -- Procedure Modifier 1
	ENDIF
ENDIF
cOutputStr = cOutputStr + '*'

cOutputStr = cOutputStr + LTrim(STR(claim_cur.amount, 12, 2)) + '*'				&& SV203 -- Line Item Charge Amount
cOutputStr = cOutputStr + 'UN*'																&& SV204 -- Unit or Basis for Measurment Code
cOutputStr = cOutputStr + STRTRAN(LTrim(STR(claim_cur.number, 10,1)), '.0')	&& SV205 -- Quantity

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
* Service Line Date --------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DTP*472*D8*20030715
*----------------------------------------------------------------------------------------------------

cOutputStr = 'DTP*'
cOutputStr = cOutputStr + '472*'													&& DTP01 Date Time Qualifier

IF !EMPTY(claim_cur.from_date) 
	cOutputStr = cOutputStr + 'RD8*'												&& DTP02 Date in CCYYMMDD format
	cOutputStr = cOutputStr + CCYYMMDD(claim_cur.from_date) + '-' + ;
					CCYYMMDD(claim_cur.thru_date)									&& DTP03 Service Dates (Range)
ELSE 
	cOutputStr = cOutputStr + 'D8*'												&& DTP02 Date in CCYYMMDD format
	cOutputStr = cOutputStr + CCYYMMDD(claim_cur.date)						&& DTP03 Service Date
ENDIF

nSegmentCount = nSegmentCount + 1

=WriteOutput(nFile, cOutputStr)

RETURN
**

*****************************************************************************************************
FUNCTION FileFooter
PARAMETER nFile
PRIVATE cOutputStr
*----------------------------------------------------------------------------------------------------
*50.Transaction Set Trailer----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*SE*50*000000001
*----------------------------------------------------------------------------------------------------

nSegmentCount = nSegmentCount + 1

cOutputStr = 'SE*'
cOutputStr = cOutputStr + LTRIM(STR(nSegmentCount, 10, 0)) + '*'	&& SE01 -- Number of Included Segments
cOutputStr = cOutputStr + cSerial											&& SE02 -- TS Control Number

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*51.Functional Group Trailer------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*GE*1*1
*----------------------------------------------------------------------------------------------------

cOutputStr = 'GE*'
cOutputStr = cOutputStr + '1*'												&& GE01 -- Number of Transaction Sets Included
cOutputStr = cOutputStr + cSerial											&& GE02 -- Group Control Number

=WriteOutput(nFile, cOutputStr)

*----------------------------------------------------------------------------------------------------
*1.Interchange Control Header------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*IEA*1*000000001
*----------------------------------------------------------------------------------------------------

cOutputStr = 'IEA*'
cOutputStr = cOutputStr + '1*'												&& IEA01 -- Number of included functional groups
cOutputStr = cOutputStr + PADL(cSerial, 9, '0')							&& IEA02 -- Interchange Control Number

=WriteOutput(nFile, cOutputStr)

RETURN
**

********************FNum****************************
*	formats numbers to character format padded left with zeros
*******************************************************
FUNCTION FNum
PARAMETERS nvalue, nlength, ndecimal
PRIVATE cvalue
cvalue = ''
cvalue = PADL(STRTRAN(ALLTRIM(STR(nvalue, nlength + 1, ndecimal)),'.',''),nlength,'0')

RETURN cvalue

*******************************************************************
* Date in format CCYYMMDD from MM/DD/YY
FUNCTION CCYYMMDD
PARAMETER dDate

Return DTOS(dDate)

*******************f_date**************************
*	formats date to character and removes '/'
**************************************************

FUNCTION f_date
PARAMETERS dvalue, nlength
PRIVATE cvalue, coldcent

coldcent =SET('century')

IF nlength = 6
	SET CENTURY OFF
	cvalue = STRTRAN(DTOS(dvalue),'/','')
ELSE
	SET CENTURY ON
	cvalue = STRTRAN(DTOS(dvalue),'/','')
ENDIF

IF EMPTY(cvalue)
	cvalue = REPLICATE('0',nlength)
ENDIF

SET CENTURY &coldcent

RETURN cvalue


*******************onlynum***************************
* removes character values from a string
*****************************************************
FUNCTION onlynum
PARAMETER cchar
PRIVATE i

cnewchar = cchar

FOR i = 1 TO LEN(cchar)
	IF !BETWEEN(SUBSTR(cchar,i,1),CHR(48),CHR(57))
		cnewchar = STRTRAN(cchar,SUBSTR(cchar,i,1),'')
	ENDIF
ENDFOR

RETURN ALLTRIM(cnewchar)

***********************DiskDest***********************
*	get disk file destination from user
******************************************************
FUNCTION DiskDest

DO WHILE .t.
	cDisk = LFGETDIR(cDisk, "Create claims file on:", 'BillEmed')

	IF Empty(cDisk)
		Return .F.
	ENDIF

	nFiles = ADir(aTemp, cDisk + cFileName)

	IF nFiles > 0
		nRespond = oApp.Msg2User("FILEEXIST", cDisk, DTOC(aTemp[1,3]))
		DO CASE
			* Overwrite
			CASE nRespond = 1
				ERASE (cDisk + cFileName)
				EXIT
			* Another Location
			CASE nRespond = 2
				LOOP
			* Cancel
			OTHERWISE
				Return .f.
		ENDCASE
	ELSE
		EXIT
	ENDIF
ENDDO

RETURN .t.

*===========================================================================
* Write actual output to file. Uppercase all.
FUNCTION WriteOutput
PARAMETER nHandle, cLine
	DO WHILE Right(cLine, 1) = '*'
		cLine = Left(cLine, Len(cLine)-1)
	ENDDO
	=FWRITE(nHandle, UPPER(cLine) + '~')
RETURN

*******************************************************************
* Left padded with 0 numeric
FUNCTION LEFT0NUM
PARAMETER nVar, nLength
RETURN TransForm(nVar, "@L "+Replicate("9", nLength))

*******************************************************************
* Convert file to blocked 80 char
FUNCTION Block80File
parameter cFileIn, cFileOut

nInputFile = FOPEN(cFileIn)
IF nInputFile <= 0
	oApp.msg2user('INFORM','Could not open input file.')
	RETURN
ENDIF

nOutputFile = FCREATE(cFileOut)
IF nOutputFile <= 0
	oApp.msg2user('INFORM','Could not create output file.')
	RETURN
ENDIF

DO WHILE !FEOF(nInputFile)
	cLine = PADR(FREAD(nInputFile, 80), 80)
	= FPUTS(nOutputFile, cLine)
ENDDO

= FCLOSE(nInputFile)
= FCLOSE(nOutputFile)
