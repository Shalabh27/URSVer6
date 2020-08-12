Parameters;
  lPrev,;     && Preview 
  aSelvar1,;  && select parameters from selection list
  nOrder,;    && order by
  nGroup,;    && report selection
  lcTitle,;   && report selection
  Date_from,; && from date
  Date_to,;   && to date
  cCrit,;     && name of param
  lnStat,;    && selection(Output)  page 2
  cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)
clHistory=' '
clVerStatus=' '
cProg_id=' '

For i = 1 to Alen(aSelvar2, 1)
  If Rtrim(aSelvar2(i, 1)) = "LCHISTORY"
     clHistory=Alltrim(Upper(aSelvar2(i, 2)))
  EndIf

  If Rtrim(aSelvar2(i, 1)) = "LCVSTATUS"
     clVerStatus=Alltrim(Upper(aSelvar2(i, 2)))
  EndIf
  
  If Rtrim(aSelvar2(i, 1)) = "LCPROG"
     cProg_id=Alltrim(Upper(aSelvar2(i, 2)))
  EndIf
EndFor

Private gchelp
gchelp= ""

cTitle="Update Verification Status" 
Private cSaveTC_ID
*
oVProcesses=NewObject('processes','verification')
lcloseProg=.t.
cWhere=''

oWait.lbl_message.caption='Setup Data Environment'
oWait.Refresh()
oWait.Show()

=dbcOpenTable('vn_header','')
=dbcOpenTable('vn_details','')
=dbcOpenTable('vn_rules','')
=dbcOpenTable('lv_ai_hepatitis_status_all','')

Select vn_rules
Go Top
Scan
   =dbcOpenTable(Alltrim(table_name),Alltrim(search_tag))
   Select vn_rules
EndScan 

Select 0
*!*   Create Cursor _curVerify ;
*!*      (clName C(40), ;
*!*       arv_therapy C(09), ;
*!*       next_arv_therapy D,;
*!*       pep_therapy C(09), ;
*!*       next_pep_therapy D,;
*!*       prep_therapy C(09), ;
*!*       next_prep_therapy D,;
*!*       financial C(09), ;
*!*       next_financial D,;
*!*       HCV_RISK C(09), ;
*!*       next_hcv_risk D,;
*!*       HCV_treatment C(09), ;
*!*       next_hcv_treatment D,;
*!*       HIV_provider C(09), ;
*!*       next_hiv_provider D,;
*!*       HIV_Status C(09), ;
*!*       next_hiv_status D,;
*!*       HIV_risk C(09), ;
*!*       next_hiv_risk D,;
*!*       hepatitis_a C(09), ;
*!*       next_hepatitis_a D,;
*!*       hepatitis_b C(09), ;
*!*       next_hepatitis_b D,;
*!*       hepatitis_c C(09), ;
*!*       next_hepatitis_c D,;
*!*       housing C(09), ;
*!*       next_housing D,;
*!*       insurance C(09), ;
*!*       next_insurance D,;
*!*       substance_use C(09),;
*!*       next_substance_use D,;
*!*       Crit C(150),;
*!*       cTime C(20),;
*!*       ddate_from D,;
*!*       ddate_to D)


Create Cursor _curVerify ;
   (clName C(40), ;
    id_no C(20),;
    tc_id C(10),;
    arv_therapy C(09), ;
    next_arv_therapy D,;
    financial C(09), ;
    next_financial D,;
    HCV_RISK C(09), ;
    next_hcv_risk D,;
    HIV_provider C(09), ;
    next_hiv_provider D,;
    HIV_Status C(09), ;
    next_hiv_status D,;
    HIV_CD4_status C(09),;
    next_HIV_CD4_status D,;
    HIV_Viral_load_status C(09),;
    next_HIV_Viral_load_status D,;
    HIV_risk C(09), ;
    next_hiv_risk D,;
    hepatitis_a C(09), ;
    next_hepatitis_a D,;
    hepatitis_b C(09), ;
    next_hepatitis_b D,;
    hepatitis_c C(09), ;
    next_hepatitis_c D,;
    housing C(09), ;
    next_housing D,;
    insurance C(09), ;
    next_insurance D,;
    lab_chlamydia_status C(09),;
    next_lab_chlamydia D,;
    lab_gonorrhea_status C(09),;
    next_lab_gonorrhea D,;
    lab_syphilis_status C(09),;
    next_lab_syphilis D,;
    substance_use C(09),;
    next_substance_use D,;
    Crit C(150),;
    cTime C(20),;
    ddate_from D,;
    ddate_to D)
Index On Upper(clName) Tag clName Addit
Set Order To

=oVProcesses.create_curVerificationView()
Select _curVerificationView
Index On tc_id Tag tc_id

cWhere='!Empty(cli_cur.tc_id)'

If !Empty(cProg_id)
   oWait.lbl_message.caption='Selecting Clients (2)'
   oWait.Refresh()
      
   =dbcOpenTable('lv_ai_prog','',@lcloseProg)
      
   Select Distinct tc_id ;
   From Lv_ai_prog ;
   Where program=cProg_id And ;
      ((lv_ai_prog.Start_dt <= Date_to And Empty(lv_ai_prog.End_dt)) Or;
         (!Empty(lv_ai_prog.End_dt) And (lv_ai_prog.End_dt > Date_from And lv_ai_prog.End_dt <= Date_to))) And; 
      !Empty(lv_ai_prog.tc_id);
   Into cursor _curTCID ;
   Order By 1
   
   cWhere=cWhere+' And cli_cur.tc_id In (Select tc_id From _curTCID)'
     
   If _Tally = 0
      oApp.msg2user('NOTFOUNDG')
      Use In _curTCID
      Return 
   EndIf 

EndIf

oWait.lbl_message.caption='Selecting Clients (3)'
oWait.Refresh()

Select Padr(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi),100,' ') AS cFull_name, ;
       id_no,;
		 client_id, ;
		 tc_id,;
       dob,;
       in_care;
From cli_cur ;
Where ((placed_dt <= Date_to And in_care=(.t.)) or (In_care=(.f.) And placed_dt <= Date_to And status_date >=Date_to)) And &cWhere;
Into Cursor cClient Readwrite
Index on Upper(cFull_name) Tag cFullName

* Where ((placed_dt <= Date_to And in_care=(.t.)) or (placed_dt <= Date_to And In_care=(.f.) And Between(status_date, Date_from,Date_to))) And &cWhere;

Select cClient
Go Top

oWait.lbl_message.caption='Gathering Verifications (1)'
oWait.Refresh()

Scan
   oVProcesses.tickler(.t., cClient.tc_id, cClient.dob, cClient.client_id,.t.)

   Select _curVerificationView
   If Seek(cClient.tc_id)
      Replace _curVerificationView.cFull_name With cClient.cfull_name, id_no With cClient.id_no For _curVerificationView.tc_id=cClient.tc_id
       
   Endif
  
   Select cClient
EndScan

oWait.lbl_message.caption='Gathering Verifications (2)'
oWait.Refresh()

#Define OK 'a'   && 0 
#Define PAST 'r' && 1
#Define DUE 'ê'  && 2
#Define NO ' '   && 3
#Define ATTN '¥' && 4
#Define OK1 'Ok' && 0 
#Define PAST1 'PastDue' && 1
#Define DUE1 'DueSoon'  && 2
#Define NO1 'NoInfo'    && 3
#Define ATTN1 'Attention' && 4

Set Seconds Off
ccTime=Ttoc(DateTime(),2)
Set Seconds On

Select _curVerify
Scatter Name oCurVerify Blank Additive

Select _curVerificationView
Go Top
oCurVerify.clName=_curVerificationView.cFull_name
oCurVerify.id_no=_curVerificationView.id_no
oCurVerify.tc_id=_curVerificationView.tc_id
m.tc_id=_curVerificationView.tc_id

Scan
   cReplacementChar=''
   *!* User selected a status to report on
   If !Empty(clVerStatus)
      Do Case
         Case clVerStatus='A' And _curVerificationView.nNoteFlag=(0)
            cReplacementChar=Iif(lnStat=(1),OK,OK1)
            
         Case clVerStatus='B' And _curVerificationView.nNoteFlag=(2)
            cReplacementChar=Iif(lnStat=(1),DUE,DUE1)
            
         Case clVerStatus='C' And _curVerificationView.nNoteFlag=(3)
            cReplacementChar=Iif(lnStat=(1),NO,NO1)
            
         Case clVerStatus='D' And _curVerificationView.nNoteFlag=(4)
            cReplacementChar=Iif(lnStat=(1),ATTN,ATTN1)
            
         Case clVerStatus='E' And _curVerificationView.nNoteFlag=(1)
            cReplacementChar=Iif(lnStat=(1),PAST,PAST1)
            
      EndCase 
   Else
      Do Case
         Case _curVerificationView.nNoteFlag=(0)
            cReplacementChar=Iif(lnStat=(1),OK,OK1)
            
         Case _curVerificationView.nNoteFlag=(2)
            cReplacementChar=Iif(lnStat=(1),DUE,DUE1)
            
         Case _curVerificationView.nNoteFlag=(3)
            cReplacementChar=Iif(lnStat=(1),NO,NO1)
            
         Case _curVerificationView.nNoteFlag=(4)
            cReplacementChar=Iif(lnStat=(1),ATTN,ATTN1)
            
         Case _curVerificationView.nNoteFlag=(1)
            cReplacementChar=Iif(lnStat=(1),PAST,PAST1)
            
      EndCase 
   EndIf
   
   If m.tc_id <> tc_id
      Insert Into _curVerify From Name oCurVerify
   
      Select _curVerify
      Scatter Name oCurVerify Blank
      Select _curVerificationView
      m.tc_id=_curVerificationView.tc_id
      oCurVerify.clName=_curVerificationView.cFull_name
      oCurVerify.id_no=_curVerificationView.id_no
      oCurVerify.tc_id=_curVerificationView.tc_id
   EndIf 

   Do Case
      Case (cVnCategory='M' And Empty(clHistory)) Or (cVnCategory='M' And clHistory='M')
         oCurVerify.ARV_Therapy=cReplacementChar
         oCurVerify.next_arv_therapy=_curVerificationView.dTarget
                  
      Case (cVnCategory='N' And Empty(clHistory)) Or (cVnCategory='N' And clHistory='N')
         oCurVerify.PREP_Therapy=cReplacementChar
         oCurVerify.next_PREP_therapy=_curVerificationView.dTarget

      Case (cVnCategory='O' And Empty(clHistory)) Or (cVnCategory='O' And clHistory='O')
         oCurVerify.PEP_Therapy=cReplacementChar
         oCurVerify.next_pep_therapy=_curVerificationView.dTarget

      Case (cVnCategory='G' And Empty(clHistory)) Or (cVnCategory='G' And clHistory='G')
         oCurVerify.financial=cReplacementChar
         oCurVerify.next_financial=_curVerificationView.dTarget
         
      Case (cVnCategory='C' And Empty(clHistory)) Or (cVnCategory='C' And clHistory='C')
         oCurVerify.HIV_risk=cReplacementChar
         oCurVerify.next_hiv_risk=_curVerificationView.dTarget
         
*!*         Case (cVnCategory='F' And Empty(clHistory)) Or (cVnCategory='F' And clHistory='F')
*!*            oCurVerify.HCV_treatment=cReplacementChar
*!*            oCurVerify.next_hcv_treatment=_curVerificationView.dTarget
         
      Case (cVnCategory ='I' And Empty(clHistory)) Or (cVnCategory='I' And clHistory='I')
         oCurVerify.HIV_provider=cReplacementChar
         oCurVerify.next_hiv_provider=_curVerificationView.dTarget

      Case (cVnCategory='B' And Empty(clHistory)) Or (cVnCategory='B' And clHistory='B')
         oCurVerify.HIV_Status=cReplacementChar
         oCurVerify.next_hiv_status=_curVerificationView.dTarget
         
      Case (cVnCategory='E' And Empty(clHistory)) Or (cVnCategory='E' And clHistory='E')
         oCurVerify.HCV_RISK=cReplacementChar
         oCurVerify.next_hcv_risk=_curVerificationView.dTarget

      Case (cVnCategory='D' And Empty(clHistory)) Or (cVnCategory='D' And clHistory='D')
         Do Case
            Case Right(Alltrim(chistory),1)='A'
               oCurVerify.hepatitis_a=cReplacementChar
               oCurVerify.next_hepatitis_a=_curVerificationView.dTarget
               
            Case Right(Alltrim(chistory),1)='B'
               oCurVerify.hepatitis_b=cReplacementChar
               oCurVerify.next_hepatitis_b=_curVerificationView.dTarget
               
            Case Right(Alltrim(chistory),1)='C'
               oCurVerify.hepatitis_c=cReplacementChar
               oCurVerify.next_hepatitis_c=_curVerificationView.dTarget
               
         EndCase 
         
      Case (cVnCategory='K' And Empty(clHistory)) Or (cVnCategory='K' And clHistory='K')
         oCurVerify.housing=cReplacementChar
         oCurVerify.next_housing=_curVerificationView.dTarget

      Case (cVnCategory='H' And Empty(clHistory)) Or (cVnCategory='H' And clHistory='H')
         oCurVerify.insurance=cReplacementChar
         oCurVerify.next_insurance=_curVerificationView.dTarget

      Case (cVnCategory='U' And Empty(clHistory)) Or (cVnCategory='U' And clHistory='U')
         oCurVerify.substance_use=cReplacementChar
         oCurVerify.next_substance_use=_curVerificationView.dTarget

      Case (cVnCategory='P' And Empty(clHistory)) Or (cVnCategory='P' And clHistory='P')
         oCurVerify.HIV_CD4_status=cReplacementChar
         oCurVerify.next_HIV_CD4_status=_curVerificationView.dTarget

      Case (cVnCategory='Q' And Empty(clHistory)) Or (cVnCategory='Q' And clHistory='Q')
         oCurVerify.HIV_Viral_load_status=cReplacementChar
         oCurVerify.next_HIV_Viral_load_status=_curVerificationView.dTarget

      Case (cVnCategory='R' And Empty(clHistory)) Or (cVnCategory='R' And clHistory='R')
         oCurVerify.lab_chlamydia_status=cReplacementChar
         oCurVerify.next_lab_chlamydia=_curVerificationView.dTarget

      Case (cVnCategory='S' And Empty(clHistory)) Or (cVnCategory='S' And clHistory='S')
         oCurVerify.lab_gonorrhea_status=cReplacementChar
         oCurVerify.next_lab_gonorrhea=_curVerificationView.dTarget

      Case (cVnCategory='T' And Empty(clHistory)) Or (cVnCategory='T' And clHistory='T')
         oCurVerify.lab_syphilis_status=cReplacementChar
         oCurVerify.next_lab_syphilis=_curVerificationView.dTarget
   EndCase
    
EndScan 
Insert Into _curVerify From Name oCurVerify

Select _curVerify
Go Top 
If !Empty(clHistory) Or !Empty(clVerStatus)
*!*      Delete For ;
*!*          Empty(arv_therapy) And ;
*!*          Empty(financial) And ;
*!*          Empty(HCV_RISK) And ;
*!*          Empty(HCV_treatment) And ;
*!*          Empty(HIV_provider) And ;
*!*          Empty(HIV_Status) And ;
*!*          Empty(HIV_risk) And ;
*!*          Empty(hepatitis_a) And ;
*!*          Empty(hepatitis_b) And ;
*!*          Empty(hepatitis_c) And ;
*!*          Empty(housing) And ;
*!*          Empty(insurance) And ;
*!*          Empty(substance_use) And ;
*!*          Empty(HIV_CD4_status) And ;
*!*          Empty(HIV_Viral_load_status) And ;
*!*          Empty(lab_chlamydia_status) And ;
*!*          Empty(lab_gonorrhea_status) And ;
*!*          Empty(lab_syphilis_status)

   Delete For ;
       Empty(arv_therapy) And ;
       Empty(financial) And ;
       Empty(HCV_RISK) And ;
       Empty(HIV_provider) And ;
       Empty(HIV_Status) And ;
       Empty(HIV_risk) And ;
       Empty(hepatitis_a) And ;
       Empty(hepatitis_b) And ;
       Empty(hepatitis_c) And ;
       Empty(housing) And ;
       Empty(insurance) And ;
       Empty(substance_use) And ;
       Empty(HIV_CD4_status) And ;
       Empty(HIV_Viral_load_status) And ;
       Empty(lab_chlamydia_status) And ;
       Empty(lab_gonorrhea_status) And ;
       Empty(lab_syphilis_status)
   Go Top
EndIf 

Update _curVerify;
   Set ddate_from=date_from,;
       ddate_to=date_to,;
       crit=ccrit,;
       cTime=ccTime
      
Use In _curVerificationView
Use In cClient

oWait.Hide

oApp.msg2user("OFF")
gcRptName = 'rpt_verification_status'

Select _curVerify
Set Order To clName
Go Top 

If Eof()
   oApp.msg2user('NOTFOUNDG')
Else 
   Do Case
      Case lnStat=2
         Select _curVerify
         Copy To extracts\ClientVerificationStatus.csv CSV Fields Except Crit, cTime, ddate_from, ddate_to
*        Copy To extracts\ClientVerificationStatus.csv CSV Fields Except Crit, cTime, ddate_from, ddate_to, substance_use, next_substance_use
         oApp.msg2user("INFORM",'The file "ClientVerificationStatus.csv" was copied to the extracts folder.')
         
      Case lPrev = .f.
           Report Form rpt_verification_status To Printer Prompt Noconsole NODIALOG 

      Case lPrev = .t.     &&Preview
           oApp.rpt_print(5, .t., 1, 'rpt_verification_status', 1, 2)
   EndCase 
EndIf