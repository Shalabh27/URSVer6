* print Referral Tracking
*************************************************************************
** This program prints Referral Tracking form
*************************************************************************
cTime = Time()
cDate = Date()

cAlias=Select()
 
Local cRef_id, cWorkID, cAct_id, cStaffName, cRef_to, cRefAgency, cRefAddr, cClientName, dClientDob,cclientSSN  


Select lv_ai_ref_filtered
If EMPTY(lv_ai_ref_filtered.ref_to)
   oApp.msg2user('INFORM', "Report may only be printed when 'Referred to' is specified")   
   Return
Endif

cRef_id = lv_ai_ref_filtered.ref_id
cAct_id =lv_ai_ref_filtered.act_id
cRef_to = lv_ai_ref_filtered.ref_to
cCtrtest_id = lv_ai_ref_filtered.ctrtest_id
***Worker
If !Empty(cAct_id)
      Select ai_enc

      Locate For ai_enc.act_id = cAct_id
      If Found() 
         cWorkID = ai_enc.worker_id
      Else
         cWorkID = ''
      Endif 
Else
      =OpenFile("ctr_test", "ctrtest_id")
      Select ctr_test
      Locate For ctr_test.ctrtest_id=cCtrtest_id
      If Found()
         ctrWorker = ctr_test.worker_id
         =OpenFile("userprof", "worker_id")
         Locate For userprof.pworker_id = ctrWorker
         If Found()
            cWorkID = userprof.worker_id
         Else
            cWorkID = ''
         Endif
      Else
         cWorkID = ''
      Endif
 Endif
      
***Worker Name
If !Empty(cWorkID)
   Select StaffCur
   Locate For StaffCur.worker_id = cWorkID
   If Found() 
      cStaffName = oApp.FormatName(StaffCur.last, StaffCur.first, StaffCur.mi)
   Else
      cStaffName = ''   
   Endif
Else
   cStaffName = ''
Endif

* next, get the referred to agency info
Select ref_srce 
Locate For ref_Srce.code = cRef_to

If Found()
   cRefAgency = ref_srce.name
   cRefAddr =  PADR(ALLTRIM(Addr1) + IIF(!EMPTY(Addr2),', ' + ALLTRIM(Addr2),''), 60) + CHR(13) + ;
               PADR(ALLTRIM(City) + ', '+ STATE + ' ' + ;
               Iif(Len(Alltrim(Zipcode))<=5, zipcode, Transform(Alltrim(Zipcode), "@R 99999-9999")), 60) 
Else
   cRefAgency = ''
   cRefAddr = ''
Endif

* define some other report variables
Select cli_cur
Locate For cli_cur.tc_id= gcTc_id
If Found()
   cClientName = oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)
   dClientDob = cli_cur.dob
   cclientSSN = cli_cur.ssn
Else
   cClientName = ''
   dClientDob = {}
   cclientSSN = ''
Endif

      
If Used('ref_tr')
   Use In ref_tr
Endif

Select agency.agency, ;
       PADR(TRIM(Agency.Descript1) + ' ' + TRIM(Agency.Descript2), 60)       AS AgencyName , ;
       PADR(TRIM(Agency.Street1)   + ' ' + TRIM(Agency.Street2), 60) + CHR(13) + ;      
       PADR(TRIM(Agency.City) + ', ' + Agency.St + ' ' + ;
       Iif(Len(Alltrim(Agency.Zip))<=5, zip, Transform(Alltrim(Agency.Zip), "@R 99999-9999")), 30)   AS AgencyAddr , ;
       Iif(!Empty(Agency.Phone),  Transform(Alltrim(Agency.Phone), "@R (999) 999-9999"), Agency.Phone )  AS AgencyPhon , ;
       Iif(!Empty(Agency.Fax),  Transform(Alltrim(Agency.Fax), "@R (999) 999-9999") ,Agency.Fax)  AS AgencyFax , ;
       cStaffName as agencystaf, ;
       cRefAgency as RefAgency, ;
       cRefAddr as RefAddr, ;
       lv_ai_ref_filtered.ref_dt as printdate, ;
       cClientName as ClientName, ; 
       dClientDob as ClientDob, ;
       cClientSSN  as clientSSN, ;
       lv_ai_ref_filtered.ref_cat_descript as SrvNeedCat, ;
       lv_ai_ref_filtered.ref_for_descript as SpecSrv, ;
       cDate as cDate ; 
from agency, ;
   lv_ai_ref_filtered ;
where lv_ai_ref_filtered.ref_id = cRef_id ;
Into Cursor ref_tr
    
Select ref_tr
Go top
Report Form rpt_ref_track To Printer Prompt Noconsole NODIALOG 
Return



