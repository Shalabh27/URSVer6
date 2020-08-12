****************************************************************************************
* Claims detail report & data extrct to Excel
****************************************************************************************
Parameters ;
   cclaimtype,;
   cbill_id,;
   cpayor_id,;
   cprov2_id,;
   cremitid,;
   m.date_from,;
   m.date_to,;
   lprev, ;
   aselvar1,;
   ngroup,;
   ctitle1,;
   crit,;
   lhhonly,;
   nOutPutType

Acopy(aselvar1, aselvar2)

If Vartype(nOutPutType)='L'
   nOutPutType=0
EndIf

Set enginebehavior 70

Private gchelp, crepval
gchelp = "Claims Detail Report Screen"

cdate=Date()
ctime=Time()
ctc_id = ''
crate_grp  = ''

***   
If (Empty(oapp.gcai_extract_folder) Or Directory(oapp.gcai_extract_folder) = (.f.)) And nOutPutType=(2)
   oApp.msg2user('IMPORTANT','The folder that is used to store Extracts was not found '+Chr(13)+;
                             'or is not accessible to you (because of security).'+Chr(13)+;
                             'Please have an administrator define this System Preference.')
   Return
EndIf

***   If Bill_id is passed then all other parameters are not needed or looked at
If lhhonly=(.f.)
   If Type("cClaimType") <> "C" .Or. Empty(cclaimtype)
      cclaimtype = "XI"
   Endif
Else
   cclaimtype = "XY"
EndIf

If Rtrim(aselvar2[1,1]) <> " "
   For i = 1 To Alen(aselvar2, 1)
      If Rtrim(aselvar2[i,1]) = "CTC_ID"
         ctc_id = aselvar2(i, 2)
      Endif

      If Rtrim(aselvar2[i,1]) = "CPAYOR_ID"
         cpayor_id = aselvar2[i,2]
      Endif

      If Rtrim(aselvar2[i,1]) = "CPROV2_ID"
         cprov2_id = aselvar2[i,2]
      Endif

      If Rtrim(aselvar2[i,1]) = "CCSITE"
         ccsite = aselvar2[i,2]
      Endif

      If Rtrim(aselvar2[i,1]) = "LCPROG"
         lcprog = aselvar2[i,2]
      Endif

      If Rtrim(aselvar2[i,1]) = "CCHECK_ID"
         ccheck_id = aselvar2[i,2]
      Endif

      If Rtrim(aselvar2[i,1]) = "CRATE_GRP"
         crate_grp = aselvar2[i,2]
      Endif

   Endfor
Endif

If Type("cBill_ID") <> "C" .Or. Empty(cbill_id)
   cbill_id = ""
Endif

If Type("cPayor_ID") <> "C" .Or. Empty(cpayor_id)
   cpayor_id = ""
Endif

If Type("cProv2_ID") <> "C" .Or. Empty(cprov2_id)
   cprov2_id = ""
Endif

If Type("ccSite") <> "C" .Or. Empty(ccsite)
   ccsite = ""
Endif

If Type("LCPROG") <> "C" .Or. Empty(lcprog)
   lcprog = ""
Endif

If Type("cRemitID") <> "C" .Or. Empty(cremitid)
   cremitid = ""
Endif

If Type("cCheck_ID") <> "C" .Or. Empty(ccheck_id)
   ccheck_id = ""
Endif

lnonrline = .F.

Set Decimals To 2

=openfile("procpara", "claimtype")
If Seek(cclaimtype)
   crep_id   = procpara.rep_id
   lnonrline = procpara.non_r_line
Else
   oapp.msg2user("SEEKERROR", Chr(13) + " - Claim type not found")
   Return
Endif

&& Search For Parameters
If aselvar2[1,1] <> ''
   For i = 1 To Alen(aselvar2, 1)
      If Rtrim(aselvar2[i,1]) = "CCLAIMTYPE"
         cclaimtype = aselvar2[i,2]
      Endif
   Endfor
Else
   cclaimtype=''
Endif

If !Empty(cbill_id)
   crepsel = "MM"   && Call Report with List of 1 dummy Spec
   crep_id = crepsel
Else
   oapp.msg2user("WAITRUN", "Preparing Report Data.", "")
   
   * BK 10/31/2005 - add handling for remittance report
   If !Empty(cremitid)
      = openfile("cashlog", "check_id")
      = Seek(cremitid)
      If cashlog.electronic And !cashlog.has_check
         crep_id = "RP"      && Special report for remitance pending claims (supplemental file)
      Else
         crep_id = "RR"      && Special report for remitance
      Endif
   Endif
   crepsel=crep_id
Endif

***   VS 9/25/97 - Here we will look up title from a database table soon
If Empty(cremitid)
   ctitle = "Claims Detail Report"
Else
   ctitle = "Remittance Report"
Endif

cdate = Date()
ctime = Time()

Private iicond1, iicond2, cfiltexpr1, cfiltexpr2, creasondesc, cremarkdesc

If Empty(m.date_to)
   m.date_to = {01/01/2100}
Endif

* BK 10/28/2005 - add adjustment reasons and remarks
=openfile("ADJ_REAS", "CODE")
=openfile("ADJ_REM", "CODE")
* BK 11/3/2005 - add remittance
=openfile("CASHLOG", "CHECK_ID")

=openfile("CLAIM_DT", "INV_LINE")
=openfile("CLAIM_HD", "INVOICE")

cfiltexpr1 = ""
cfiltexpr2 = ""
iicond1   = ''
iicond2 = ''
creasondesc = ''
cremarkdesc = ''

*!* Reset the calimtype if the extract is limited to health home only 
If lhhonly=(.t.)
   cclaimtype = "XY"
EndIf 

***   Get filter for specific Billing
If !Empty(cbill_id)
   iicond1 = "claim_hd.bill_id = cBill_ID"
   cfiltexpr1 = cfiltexpr1 + Iif(!Empty(iicond1)," AND ","") + iicond1

Else
   If !Empty(cclaimtype)
      iicond1 = " claim_hd.claim_type = cClaimType "
      cfiltexpr1 = cfiltexpr1 + Iif(!Empty(iicond1)," AND ","") + iicond1
   Endif

*** For a specific provider
   If !Empty(cpayor_id)
      iicond1 = " claim_hd.prov_id = cPayor_ID "
      cfiltexpr1 = cfiltexpr1 + Iif(!Empty(iicond1)," AND ","") + iicond1
   Endif

*** For a specific provider number
   If !Empty(cprov2_id)
      iicond1 = " claim_hd.prov2_id = cProv2_ID "
      cfiltexpr1 = cfiltexpr1 + Iif(!Empty(iicond1)," AND ","") + iicond1
   Endif

***   Grouping choices
*      IF INLIST(nGroup, 2, 3)
   If ngroup = 3
      iicond2 = "cd2.date <= m.Date_To"
   Else
      iicond2 = "BETWEEN(cd2.date, m.Date_From, m.Date_To)"
   Endif
   cfiltexpr2 = cfiltexpr2 + Iif(!Empty(iicond2)," AND ","") + iicond2

Endif


*** For a specific client
If !Empty(ctc_id)
   iicond1 = "claim_hd.tc_id = cTC_ID"
   cfiltexpr1 = cfiltexpr1 + Iif(!Empty(iicond1)," AND ","") + iicond1
Endif

*** For a specific site
If !Empty(ccsite)
   iicond2 = "cd2.enc_site = ccSite"
   cfiltexpr2 = cfiltexpr2 + Iif(!Empty(iicond2)," AND ","") + iicond2
Endif

*** For a specific program
If !Empty(lcprog)
   iicond2 = "cd2.program = lcProg"
   cfiltexpr2 = cfiltexpr2 + Iif(!Empty(iicond2)," AND ","") + iicond2
Endif

If !Empty(cremitid)
   ccheck_id = cremitid
Endif

*** For a specific check
If !Empty(ccheck_id)
   iicond2 = "cd2.check_id = cCheck_ID"
   cfiltexpr2 = cfiltexpr2 + Iif(!Empty(iicond2)," AND ","") + iicond2
Endif

*** For a specific rate_group
If !Empty(crate_grp)
   iicond2 = "cd2.rate_grp = cRate_Grp"
   cfiltexpr2 = cfiltexpr2 + Iif(!Empty(iicond2)," AND ","") + iicond2
Endif

***   Re-initialize and get filters according to group
iicond1 = ''
iicond2 = ''

Do Case
Case ngroup = 2      && Disk created
   iicond1 = "claim_hd.processed = 'D' "

Case ngroup = 3      && Disk not created
   iicond1 = "claim_hd.processed = ' ' "

Case ngroup = 4      && Denied / Pending
* jss, add iicond1 in order to ONLY list selected details
   iicond1 = "INLIST(claim_dt.status, 1, 2)"
   iicond2 = "INLIST(cd2.status, 1, 2)"

* jss, add new option for ONLY pending
Case ngroup = 5      && Pending
   iicond1 = "claim_dt.status = 1"
   iicond2 = "cd2.status = 1"

* jss, add new option for ONLY denied
Case ngroup = 6      && Denied
   iicond1 = "claim_dt.status = 2"
   iicond2 = "cd2.status = 2"

Case ngroup = 7      && Paid
* jss, add iicond1 in order to ONLY list selected details
   iicond1 = "claim_dt.status = 3"
   iicond2 = "cd2.status = 3"

Case ngroup = 8      && Manual claims
   iicond1 = "claim_hd.man_auto = 'M' "

Case ngroup = 9      && Rebills
* jss, add iicond1 in order to ONLY list selected details
   iicond1 = "!EMPTY(claim_dt.orig_inv)"
   iicond2 = "!EMPTY(cd2.orig_inv)"
Endcase

cfiltexpr1 = cfiltexpr1 + Iif(!Empty(iicond1)," AND ","") + iicond1
cfiltexpr2 = cfiltexpr2 + Iif(!Empty(iicond2)," AND ","") + iicond2

creasondesc = ''
cremarkdesc = ''
cpendreas = ''

***   Start Query
Select ;
   med_prov.Name As payor, ;
   claim_hd.*, ;
   claim_dt.line_no, ;
   claim_dt.rate_dt_id, ;
   claim_dt.rate_code, ;
   claim_dt.proc_code, ;
   claim_dt.modifier, ;
   claim_dt.rate, ;
   claim_dt.Number, ;
   claim_dt.Date, ;
   claim_dt.Time, ;
   claim_dt.amount, ;
   claim_dt.amt_paid, ;
   claim_dt.copay_amt, ;
   claim_dt.Status, ;
   claim_dt.action, ;
   claim_dt.actbill_id, ;
   claim_dt.claim_ref, ;
   claim_dt.orig_inv, ;
   claim_dt.orig_line, ;
   claim_dt.den_code, ;
   claim_dt.adj_reas, ;
   claim_dt.adj_rem, ;
   claim_dt.pend_reas1, ;
   claim_dt.pend_reas2, ;
   claim_dt.check_id, ;
   claim_dt.r_line, ;
   oapp.formatname(cli_cur.last_name, cli_cur.first_name, cli_cur.mi) As client_name, ;
   showstat(claim_dt.Status) As status_description, ;
   showaction(claim_dt.action) As action_description, ;
   cdate As cdate, ;
   ctime As ctime, ;
   ctitle As ctitle, ;
   ctitle1 As ctitle1, ;
   m.date_from As date_from, ;
   m.date_to  As date_to,;
   crit As crit, ;
   lnonrline As lnonrline,;
   Cast(creasondesc As Memo) As creasondesc, ;
   Cast(cremarkdesc As Memo) As cremarkdesc, ;
   Cast(cpendreas As Memo) As cpendreas, ;
   Space(15) As cycle_no;
From ;
   med_prov ;
      inner Join claim_hd On ;
   med_prov.prov_id = claim_hd.prov_id ;
      inner Join claim_dt On ;
   claim_hd.invoice = claim_dt.invoice ;
      left Outer Join cli_cur On ;
   claim_hd.tc_id = cli_cur.tc_id ;
Where;
   Exists (Select * ;
            From  ;
               claim_dt cd2 ;
            Where ;
               cd2.invoice = claim_hd.invoice ;
               &cfiltexpr2) ;
   &cfiltexpr1 ;
Order By ;
   claim_hd.prov_id, ;
   claim_hd.prov2_id, ;
   claim_hd.category, ;
   claim_hd.clin_spec, ;
   claim_hd.invoice, ;
   claim_dt.line_no ;
Into Cursor ;
   claim_data Readwrite

nRowsInClaimData=_Tally

* BK 3/12/2007
If oapp.gldataencrypted
   Replace claim_data.cinn With Iif(!Empty(claim_data.cinn), osecurity.decipher(Alltrim(claim_data.cinn)), '') All
   Go Top
Endif

Select claim_data
Go Top
Update claim_data From cashlog Set cycle_no=cashlog.cycle_no Where claim_dt.check_id=cashlog.check_id And !Empty(claim_dt.check_id)
Go Top In claim_data

* BK 10/28/2005 - add adjustment reasons and remarks
Set Relation To adj_reas Into adj_reas Additive
Set Relation To adj_rem Into adj_rem Additive

* BK 11/3/2005 - add remittance
Set Relation To check_id Into cashlog Additive

If !Empty(cremitid)
   Index On Str(Status, 1, 0) + prov_id + prov2_id + category + clin_spec + invoice + line_no Tag order1
Endif

If nRowsInClaimData=0
   oapp.msg2user('NOTFOUNDG')
Else
   * Calculate the totals
   Select ;
      claim_data.prov_id, ;
      claim_data.prov2_id, ;
      claim_data.category, ;
      claim_data.clin_spec, ;
      Count(Dist invoice) As num_inv, ;
      Sum(Iif(claim_data.r_line, 1, 0)) As num_claim, ;
      Sum(Iif(claim_data.Status=1, 1, 0)) As num_pend, ;
      Sum(Iif(claim_data.Status=2, 1, 0)) As num_denied, ;
      Sum(claim_data.amount) As amount, ;
      Sum(claim_data.amt_paid) As amt_paid ;
   From ;
      claim_data ;
   Group By ;
      1,2,3,4 ;
   Into Cursor ;
      claim_tot

*-*  Claim_data.loc_code, ;
*-*  INDEX ON prov_id + prov2_id + category + clin_spec + loc_code TAG grouptag

   Index On prov_id + prov2_id + category + clin_spec Tag grouptag

* BK 11/3/2005 - add totals by status
   Select ;
      claim_data.prov_id, ;
      claim_data.prov2_id, ;
      claim_data.category, ;
      claim_data.clin_spec, ;
      claim_data.Status, ;
      Count(Dist invoice) As num_inv, ;
      Sum(Iif(claim_data.r_line, 1, 0)) As num_claim, ;
      Sum(Iif(claim_data.Status = 1, 1, 0)) As num_pend, ;
      Sum(Iif(claim_data.Status = 2, 1, 0)) As num_denied, ;
      Sum(claim_data.amount) As amount ;
   From ;
      claim_data ;
   Group By ;
      1,2,3,4,5 ;
   Into Cursor ;
      totbystat

   Index On prov_id + prov2_id + category + clin_spec + Str(Status,1,0) Tag grouptag

   Select claim_data
   Set Relation To prov_id + prov2_id + category + clin_spec + Str(Status,1,0) Into totbystat Additive

   If !Empty(cremitid)
      If crep_id = "RR"
         * Regular remittance report - so prepare adjustments reasons and remittance remarks
         creasondesc = ''

         Select Distinct ;
            claim_data.adj_reas, ;
            IIF(Isdigit(Trim(Code)), Padl(Trim(Code), 3), Left(Code,1) + Padl(Trim(Right(Code, 2)),2)) As order_code, ;
            adj_reas.Descript ;
         from ;
            claim_data, adj_reas ;
         where ;
            claim_data.adj_reas = adj_reas.Code ;
         into Cursor reas_codes ;
         order By 2

         Scan
            m.creasondesc = m.creasondesc + Trim(adj_reas) + ' - ' + Descript + Chr(13) + Chr(13)
         Endscan

         Select claim_data
         Replace claim_data.creasondesc With m.creasondesc All
         Go Top

         cremarkdesc = ''

         Select Distinct ;
            claim_data.adj_rem, ;
            IIF(!Isdigit(Substr(Code,2)), Left(Code,2) + Padl(Trim(Right(Code, 3)),3), ;
            Left(Code,1) + Padl(Trim(Right(Code, 4)),4)), ;
            adj_rem.Descript ;
         from ;
            claim_data, adj_rem ;
         where ;
            claim_data.adj_rem = adj_rem.Code ;
         into Cursor rem_codes ;
         order By 2

         Scan
            m.cremarkdesc = m.cremarkdesc + Trim(adj_rem) + ' - ' + Descript + Chr(13) + Chr(13)
         Endscan

         Select claim_data
         Replace claim_data.cremarkdesc With m.cremarkdesc All
         Go Top

      Else
         * Supplemental remittance report - so pending reasons only
         cpendreas = ''
         Select ;
            pendreas.Code, ;
            pendreas.Descript ;
         From ;
            claim_data, pendreas ;
         Where ;
            claim_data.pend_reas1 = pendreas.Code ;
         Union ;
         Select ;
            pendreas.Code, ;
            pendreas.Descript ;
         From ;
            claim_data, pendreas ;
         Where ;
            claim_data.pend_reas2 = pendreas.Code ;
         Into Cursor reas_codes ;
         Order By 1

         Scan
            m.cpendreas = m.cpendreas + Trim(Code) + ' - ' + Descript + Chr(13) + Chr(13)
         Endscan

         Select claim_data
         Replace claim_data.cpendreas With m.cpendreas All
         Go Top

      Endif

   Endif


   oapp.msg2user("OFF")
   Set Decimals To
   Set enginebehavior 90

   gcrptalias = 'claim_data'

   Select claim_data
   If Eof()
      oapp.msg2user('NOTFOUNDG')
   Else
      Do Case
         Case nOutPutType=(2)
            cTempFileName=Addbs(Sys(2023))+'Billx'+Dtos(Date())+'.csv'
            cDestination=''
            cPassword='Ajx!217!'
            
*!*               If Empty(oApp.gcrpt_save_folder)
*!*                  cDestination='extracts\'
*!*                  
*!*               Else
*!*                  cDestination=Addbs(oApp.gcrpt_save_folder)
*!*                  
*!*               EndIf
            
            cDestination=Addbs(oapp.gcai_extract_folder)
            cDestination=cDestination+'Billx'+Dtos(Date())+'.zip'
            
            clPassword=''
            oPWForm=NewObject('set_password_form','security')
            oPWForm.vPasswordObject='clPassword'
            oPWForm.Show()
            
            If Empty(clPassword)
               oApp.msg2user('INFORM',"A password was not supplied, this process is cancelled.")
            Else
               
               If File(cDestination,1)=(.t.)
                  oApp.msg2user('MESSAGE',"The file: "+cDestination+Chr(13)+" is in the destination folder. It will be overwritten.")
               EndIf 
               
               Select;
                 payor As payer,;
                 prov_num,;
                 category,;
                 bill_date,;
                 cycle_no,;
                 client_name,;
                 cinn As medicaid_no,;
                 client_id,;
                 tc_id,;
                 dob,;
                 sex,;                  
                 invoice,;
                 date As date_of_service,;
                 rate_code,;
                 proc_code,;
                 loc_code,;
                 number As units,;
                 amount As amount_charged,;
                 amt_paid,;
                 status As stat_code,;
                 status_description,;
                 action_description,;
                 orig_inv As created_From_invoice,;
                 Space(15) As id_no,;
                 claim_ref,;
                 adj_reas As adj_resn,;
                 Space(200) As adj_descr,;
                 adj_rem As denial_code,;
                 Space(200) As denial_descr;
               From claim_data;
               Into Cursor _curTempCD ReadWrite;
               Order By 6
               
               Update _curTempCD ;
                From ai_clien ;
                  Set _curTempCD.id_no=ai_clien.id_no ;
                Where ai_clien.client_id=_curTempCD.client_id

               Update _curTempCD ;
                From adj_reas ;
                  Set _curTempCD.adj_descr=adj_reas.descript ;
                Where !Empty(_curTempCD.adj_resn) And ;
                      Alltrim(_curTempCD.adj_resn)==Alltrim(adj_reas.code)
               
               Update _curTempCD ;
                From adj_rem ;
                  Set _curTempCD.denial_descr= Substr(adj_rem.descript,1,At('.',adj_rem.descript,1));
                Where !Empty(_curTempCD.denial_code) And ;
                      Alltrim(_curTempCD.denial_code)==Alltrim(adj_rem.code)
               
               
               Select _curTempCD
               Copy To (cTempFileName) csv
               
               Use In _curTempCD
               Select claim_data
               
               nResult=oApp.Zip32(cTempFileName, cDestination, clPassword)
               
               If File(cDestination,1)=(.t.)
                  oApp.msg2user('MESSAGE',"The Extract file: "+cDestination+Chr(13)+" was successfully created.")
                  
               EndIf 
               
            EndIf 
            
            Try 
              Delete File (cTempFileName)
            EndTry 
            
         Case crep_id = 'MM' Or crep_id = 'MC'
            **VT 08/25/2008 Dev Tick 4686
            gcrptname = 'rpt_claims'

            Do Case
            Case lprev = .F.
               Report Form rpt_claims To Printer Prompt Noconsole Nodialog
            Case lprev = .T.
               oapp.rpt_print(5, .T., 1, 'rpt_claims', 1, 2)
            Endcase

         Case crep_id = 'RR'
            **VT 08/25/2008 Dev Tick 4686
            gcrptname = 'rpt_remitt'
            Do Case
            Case lprev = .F.
               Report Form rpt_remitt To Printer Prompt Noconsole Nodialog
            Case lprev = .T.
               oapp.rpt_print(5, .T., 1, 'rpt_remitt', 1, 2)
            EndCase
            
         Case crep_id = 'RP'
            **VT 08/25/2008 Dev Tick 4686
            gcrptname = 'rpt_remittp'

            Do Case
            Case lprev = .F.
               Report Form rpt_remittp To Printer Prompt Noconsole Nodialog
            Case lprev = .T.
               oapp.rpt_print(5, .T., 1, 'rpt_remittp', 1, 2)
            Endcase
      Endcase
   Endif
Endif

Return

**************************************************************
Function summ_data
* Creates cursor of summary data

Select ;
   payor, ;
   claim_type, ;
   bill_id, ;
   prov_id, ;
   prov2_id, ;
   client_id, ;
   tc_id, ;
   prim_sec, ;
   invoice, ;
   cinn, ;
   insstat_id, ;
   bill_date, ;
   loc_code, ;
   treat_auth, ;
   category, ;
   clin_spec, ;
   man_auto, ;
   adj_void, ;
   dob, ;
   sex, ;
   diagnos1, ;
   icd9code1, ;
   diagnos2, ;
   icd9code2, ;
   diagnos3, ;
   rate_code, ;
   proc_code, ;
   modifier, ;
   Sum(Number) As sum_number, ;
   Sum(amount) As sum_amt, ;
   Sum(amt_paid) As sum_paid, ;
   Sum(copay_amt) As sum_copay ;
From ;
   claim_data ;
Where ;
   r_line ;
Group By ;
   invoice ;
Into Cursor ;
   sum_data
*
Function showgroup
* for dummy foxpro which doesn't want to work with aGroup directly
Return
*
