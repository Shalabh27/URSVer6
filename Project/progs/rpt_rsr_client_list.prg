Parameters lPrev, ;        && Preview     
           aSelvar1, ;     && select parameters from selection list
           nOrder, ;       && order by
           nGroup, ;       && report selection    
           lcTitle, ;      && report selection    
           dDate_from , ;  && from date
           dDate_to, ;     && to date   
           Crit , ;        && name of param
           lnStat, ;       && selection(Output)  page 2
           cOrderBy        && order by description
Do Case
 Case lnStat=(1)
    Do client_list

 Case lnStat=(2)
    Do client_not_list

 Case lnStat=(3)
    Do client_list_combined

EndCase 

Return 
*

Procedure client_list 
oWait.Hide()

If Used('curServPool')
   Use In curServPool
EndIf

If Used('_cur1Row')
   Use In _cur1Row
Endif

nServiceID=0
Acopy(aSelvar1, aSelvar2)
nServiceID=Iif(Empty(aSelvar2[1,2]),0,Int(Val(aSelvar2[1,2])))

Local lCloseServiceCategory

lCloseServiceCategory=.f.
If !Empty(nServiceID)
   =dbcOpenTable('rsr_service_definitions','serviceid',@lCloseServiceCategory)
EndIf 

If Empty(nServiceID)
   oApp.vGenprop='All RSR Service Categories'
Else
   oApp.vGenprop=Iif(Seek(nServiceID,'rsr_service_definitions','serviceid')=(.t.),rsr_service_definitions.description,'n/a')
EndIf

If lCloseServiceCategory=(.t.)
   Use in rsr_service_definitions
EndIf 

oRSRMethods=NewObject('_rsr','rsr')
oRSRMethods.create_period_cursor(.f.,.f.,.f.) 

If Reccount('curqh')=(1)
   Select curQH
   Replace is_selected With .t.
Else
   oNewRSRForm=NewObject('rsr_starting','rsr',.null.,.t.)
   oNewRSRForm.center_form_on_top()
   oNewRSRForm.Show()
EndIf

Select curQH
Go Top
Locate for is_selected =(.t.)
If Found()
   curQH_qh_id=curQH.qh_id
   curQH_q_begin=curQH.q_begin
   curQH_h_end=curQH.h_end
   m.curQH_note=curQH.note
Else
   Use In curQH
   Return
EndIf

oWait.Show()

Local cOldTC_ID
cOldTC_ID=gcTc_id

With oRSRMethods
 .dstart=curQH_q_begin
 .dend=curQH_h_end
 .Qh_id=curQH.qh_id
 .lFromReporting=.t.
 .lFromClientList=.t.
 If .test_service_definitions()=(-1)
    Return
 Endif

 .nServiceID=Iif(Empty(Nvl(nServiceID,0)),0,nServiceID)
 .create_curPrograms()
 .create_curCP1(.t.)
 nFundedRows=.create_curRSRServices(.t.)
 .cReportYear=Str(Year(.dend),4,0)
 If nFundedRows=(-2)
    oApp.msg2user('RSR_SC2',.cReportYear)
    Return
 EndIf 
Endwith

*!* Get a list of client (tc_id's) with enc/services in date range and funding.
If oRSRMethods.select_clients_with_service() = (.t.)
   Set Seconds Off
   m.cTime=Ttoc(Datetime(),2)
   Set Seconds On
   
   Select curServPool
   Replace all curQH_note With m.curQH_note, cTime With m.cTime
   Update curServPool Set lRSRonFile=.t. Where is_medical=(.t.) And tc_id In (Select tc_id From Rsr_details Where qh_id==curQH_qh_id)
   
   Go Top
   Locate for !Deleted()

   If !Found()
      Use In curServPool
      gcTc_id=cOldTC_ID
      oWait.Hide()   
      oApp.msg2user('NOTFOUNDG')      
   
      Return
   EndIf 
    
   *!* 12/2011; AIRS-162 display programs used in report
   Select _curPrograms
   Delete For luse=(.f.)
   Go Top 
   
   Update _curPrograms Set prog_descript=program.descript From program Where _curPrograms.prog_id=program.prog_id
      
   Select Distinct Padr(prog_id,6,' ') +'- '+ prog_descript as pn1,;
          prog_descript as pd;
   From _curPrograms Into Cursor _curPrograms2 Order By 2

   Create Cursor _cur1Row (programs_in_report M) 
       
   Select _curPrograms2
   Go Top
   m.ProgramList=''
   Scan
      m.ProgramList=m.ProgramList+pn1+Chr(13)
      
   EndScan
   If Empty(m.ProgramList)
      m.ProgramList='n/a'
   EndIf
   
   Insert Into _cur1Row (programs_in_report) Values (m.ProgramList)
   
   Use In _curPrograms
   Use In _curPrograms2
   
   Select curServPool
   Go Top 
   
   If nOrder=1
      Index On Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
   Else
      Index On Upper(Padl(id_no,10,'0')) Tag col1
      
   EndIf

   Set Order To col1
   Go Top
   
   gcRptName = 'rpt_rsr_client_listing'

   If nGroup <> (1)
      oWait.lbl_message.caption='Copying Table...'
      Go Top
      Copy Fields ;
         last_name,;
         first_name,;
         id_no,;
         tc_id, ;
         sex,;
         dob,;
         hiv_status,;
         hiv_stat_desc,;
         is_medical To rsr_extracts\rsr_client_listing.csv CSV 
      Go Top
      
      oWait.Hide()   
      oApp.msg2user("IMPORTANT",'The RSR Client Listing CSV export was copied to...'+Chr(13)+;
                                'rsr_extracts\rsr_client_listing.csv'+Chr(13)+' ')
   EndIf 
   
   **! Print the report
   oWait.lbl_message.caption='Creating Client Listing Report...'

   Do Case
      Case lPrev=(.f.) And nGroup <> (3)
         Report Form rpt_rsr_client_listing.frx To Printer Prompt Noconsole NoDialog
         
      Case lPrev=(.t.) And nGroup <> (3)
         oApp.rpt_print(5, .t., 1, 'rpt_rsr_client_listing', 1, 2)
         
   EndCase
   gcTc_id=cOldTC_ID
   
Else
   gcTc_id=cOldTC_ID
   oApp.msg2user('NOTFOUNDG')
   
EndIf

If Used('_curCP1')
   Use in _curCP1
EndIf 

Return
*


Procedure client_not_list
oWait.Hide()

If Used('_curServPool')
   Use In _curServPool
EndIf

If Used('_cur1Row')
   Use In _cur1Row
Endif

If Used('_curTC_IDs')
   Use In _curTC_IDs
EndIf 

nServiceID=0
Acopy(aSelvar1, aSelvar2)
nServiceID=Iif(Empty(aSelvar2[1,2]),'',aSelvar2[1,2])

Local lCloseServiceCategory, cOldTC_ID
cOldTC_ID=gcTc_id

lCloseServiceCategory=.f.
If !Empty(nServiceID)
   =dbcOpenTable('rsr_service_definitions','serviceid',@lCloseServiceCategory)
EndIf 

oApp.vGenprop=''

If lCloseServiceCategory=(.t.)
   Use in rsr_service_definitions
EndIf 

oRSRMethods=NewObject('_rsr','rsr')
oRSRMethods.create_period_cursor(.f.,.f.,.f.) 

If Reccount('curqh')=(1)
   Select curQH
   Replace is_selected With .t.
Else
   oNewRSRForm=NewObject('rsr_starting','rsr',.null.,.t.)
   oNewRSRForm.center_form_on_top()
   oNewRSRForm.Show()
EndIf

Select curQH
Go Top
Locate for is_selected=(.t.)

If Found()
   curQH_qh_id=curQH.qh_id
   curQH_q_begin=curQH.q_begin
   curQH_h_end=curQH.h_end
   m.curQH_note=curQH.note
Else
   Use In curQH
   Return
EndIf

If !Empty(nServiceID)
   oApp.msg2user("RSR_CL2")
EndIf 

With oRSRMethods
 .dstart=curQH_q_begin
 .dend=curQH_h_end
 .Qh_id=curQH.qh_id
 .nServiceID=0
 .cReportYear=Str(Year(.dend),4,0)
 .create_curPrograms()
 .create_curCP1(.t.)
 nFundedRows=.create_curRSRServices(.t.)

 If .test_service_definitions()=(-1)
    Return
 Endif

 If nFundedRows=(-2)
    oApp.msg2user('RSR_SC2',.cReportYear)
    Return
 EndIf 

 oWait.Show()
 .create_curTC_IDs()
EndWith

Select _curTC_IDs
If Reccount()=(0)
   oWait.Hide()
   oApp.msg2user('NOTFOUNDG')
Else 
   Select Distinct ;
      Space(40) AS curQH_note,;
      Space(05) As cTime,;
      cli_cur.last_name,;
      cli_cur.first_name,;
      cli_cur.id_no,;
      cli_cur.case_no,;
      cli_cur.tc_id,;
      _curTC_IDs.use_client As use_client, ;
      _curTC_IDs.f_poverty As f_poverty, ;
      _curTC_IDs.f_hivstatus As f_hivstatus,;
      Space(40) As failure_reason;
   From _curTC_IDs ;
   Join cli_cur;
      On cli_cur.tc_id=_curTC_IDs.tc_id; 
   Where _curTC_IDs.use_client=(.f.);
   Order by 3,4;
   Into Cursor _curServPool ReadWrite
   Go Top In _curServPool

   If Reccount('_curServPool')=(0)
      Use In _curServPool
      gcTc_id=cOldTC_ID
      oWait.Hide()   
      oApp.msg2user('NOTFOUNDG')      
      Return
      
   EndIf 
   
   Select _curServPool
   Scan
      m.failure_reason=''
      If _curServPool.f_poverty=(2) Or _curServPool.f_poverty=(3)
         m.failure_reason=m.failure_reason+'* Financial Information '
      EndIf 
      
      If _curServPool.f_hivstatus=(2) Or _curServPool.f_hivstatus=(3)
         m.failure_reason=m.failure_reason+'* HIV Status '
      EndIf 
      
      Replace _curServPool.failure_reason With m.failure_reason
      
   EndScan
   
   Set Seconds Off
   m.cTime=Ttoc(Datetime(),2)
   Set Seconds On
      
   Select _curServPool
   Replace all curQH_note With m.curQH_note, cTime With m.cTime

   If nOrder=1
      Index On Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
   Else
      Index On Upper(Padl(id_no,10,'0')) Tag col1
   EndIf

   Set Order To col1
   Go Top
   gcRptName='rpt_rsr_client_not_listing'

   If nGroup <> (1)
      oWait.lbl_message.caption='Copying Tables...'
      Go Top
      Copy Fields;
         last_name,;
         first_name,;
         id_no,;
         tc_id,;
         failure_reason To rsr_extracts\rsr_clients_not_eligible.csv CSV 
      
      Go Top
      
      oWait.Hide()   
      oApp.msg2user("IMPORTANT",'Clients who received reportable Services but are not reportable'+Chr(13)+;
                                'rsr_clients_not_eligible.csv'+Chr(13)+' ')      
   EndIf 
   
   **! Print the report
   oWait.Hide()   
   Do Case
      Case lPrev=(.f.) And nGroup <> (3)
         Report Form rpt_rsr_client_not_listing.frx To Printer Prompt Noconsole NoDialog
         
      Case lPrev=(.t.) And nGroup <> (3)
         oApp.rpt_print(5, .t., 1, 'rpt_rsr_client_not_listing', 1, 2)
         
   EndCase
EndIf

gcTc_id=cOldTC_ID

If Used('_curCP1')
   Use in _curCP1
EndIf 
Return 
*

Procedure client_list_combined
oWait.Hide()
=dbcCloseTable('curServPool')
=dbcCloseTable('_cur1Row')
=dbcCloseTable('_curPrograms')
=dbcCloseTable('_curServPool')
=dbcCloseTable('_curTC_IDs')
=dbcCloseTable('_curCP1')
=dbcOpenTable('gender')

nServiceID=0
Acopy(aSelvar1, aSelvar2)
nServiceID=Iif(Empty(aSelvar2[1,2]),0,Int(Val(aSelvar2[1,2])))

Local lCloseServiceCategory

lCloseServiceCategory=.f.
If !Empty(nServiceID)
   =dbcOpenTable('rsr_service_definitions','serviceid',@lCloseServiceCategory)
EndIf 

If Empty(nServiceID)
   oApp.vGenprop='All RSR Service Categories'
Else
   oApp.vGenprop=Iif(Seek(nServiceID,'rsr_service_definitions','serviceid')=(.t.),rsr_service_definitions.description,'n/a')
EndIf

If lCloseServiceCategory=(.t.)
   Use in rsr_service_definitions
EndIf 

oRSRMethods=NewObject('_rsr','rsr')
oRSRMethods.create_period_cursor(.f.,.f.,.f.) 

If Reccount('curqh')=(1)
   Select curQH
   Replace is_selected With .t.
Else
   oNewRSRForm=NewObject('rsr_starting','rsr',.null.,.t.)
   oNewRSRForm.center_form_on_top()
   oNewRSRForm.Show()
EndIf

Select curQH
Go Top
Locate for is_selected =(.t.)
If Found()
   oRSRMethods.cService_Definition_Group=curqh.service_definition_group
   curQH_qh_id=curQH.qh_id
   curQH_q_begin=curQH.q_begin
   curQH_h_end=curQH.h_end
   m.curQH_note=curQH.note
Else
   Use In curQH
   Return
EndIf

oWait.Show()

Local cOldTC_ID
cOldTC_ID=gcTc_id

With oRSRMethods
 .dstart=curQH_q_begin
 .dend=curQH_h_end
 .Qh_id=curQH.qh_id
 .lFromReporting=.t.
 .lFromClientList=.t.
 If .test_service_definitions()=(-1)
    Return 
 Endif

 .nServiceID=Iif(Empty(Nvl(nServiceID,0)),0,nServiceID)
 .create_curPrograms()
 .create_curCP1(.t.)
 nFundedRows=.create_curRSRServices(.t.)
 .cReportYear=Str(Year(.dend),4,0)
 If nFundedRows=(-2)
    oApp.msg2user('RSR_SC2',.cReportYear)
    Return
 EndIf 
EndWith

Create Cursor _curClientListFinal;
  (rowtype C(01),;
   included C(03),;
   curqh_note C(40),;
   ctime C(05),;
   tc_id C(10),;
   last_name C(45),;
   first_name C(45),;
   id_no C(20),;
   sex C(01),;
   dob d,;
   gender_des C(30),;
   hiv_status C(02),;
   hiv_stat_des C(35),;
   is_medical L,;
   medical_yn C(01),;
   failure_reason C(50))

Create Cursor _cur1Row (programs_in_report M, cTotalCount C(08))

*!* Get a list of client (tc_id's) with enc/services in date range and funding.
If oRSRMethods.select_clients_with_service() = (.t.)
   Go Top
   Locate for !Deleted()
   
   If Found()
      *!* 12/2011; AIRS-162 display programs used in report
      Select _curPrograms
      Delete For luse=(.f.)
      Go Top 
      
      Update _curPrograms Set prog_descript=program.descript From program Where _curPrograms.prog_id=program.prog_id
         
      Select Distinct Padr(prog_id,6,' ') +'- '+ prog_descript as pn1,;
             prog_descript as pd;
      From _curPrograms Into Cursor _curPrograms2 Order By 2

      Select _curPrograms2
      Go Top
      m.ProgramList=''
      nCount=0
      Scan
         m.ProgramList=m.ProgramList+pn1+Chr(13)
      EndScan
      If Empty(m.ProgramList)
         m.ProgramList='n/a'
      EndIf
      
      Insert Into _curClientListFinal;
              (rowtype,;
               included,;
               tc_id,;
               last_name,;
               first_name,;
               id_no,;
               sex,;
               dob,;
               gender_des,;
               hiv_status,;
               hiv_stat_des,;
               is_medical,;
               medical_yn); 
            Select;    
              '2',;
              'Yes',;
               tc_id,;
               last_name,;
               first_name,;
               id_no,;
               sex,;
               dob,;   
               gender_descript,;
               hiv_status,;
               hiv_stat_desc,;
               is_medical ,;
               Iif(is_medical=(.t.),'Y','N') From curServPool Where !Deleted()

      Insert Into _cur1Row (programs_in_report,cTotalCount) Values (m.ProgramList, Alltrim(Transform(_Tally, '@r 999,999')))
   EndIf 
EndIf
 
Local lCloseServiceCategory, cOldTC_ID
cOldTC_ID=gcTc_id
lCloseServiceCategory=.f.

If !Empty(nServiceID)
   =dbcOpenTable('rsr_service_definitions','serviceid',@lCloseServiceCategory)
EndIf 
=dbcOpenTable('hivstat','tc_id')

oRSRMethods.create_curTC_IDs()
Select _curTC_IDs

**Recall for InList(hivstatid,2,3) And lUseHisClient=(.t.)
Recall for hivstatid=(0)
Set Deleted On
Go Top

If Reccount() > (0)
   Select Distinct ;
      cli_cur.last_name,;
      cli_cur.first_name,;
      cli_cur.id_no,;
      cli_cur.case_no,;
      cli_cur.tc_id,;
      cli_cur.dob,;
      cli_cur.sex,;
      cli_cur.gender,;
      Space(30) As gender_descript,;
      _curTC_IDs.hivstat As hiv_status,;
      Nvl(hstat.descript,Padr('n/a',35,' ')) As hiv_stat_des,;
      _curTC_IDs.hivstatid,;
      _curTC_IDs.use_client As use_client, ;
      _curTC_IDs.f_poverty As f_poverty, ;
      _curTC_IDs.f_hivstatus As f_hivstatus,;
      Space(40) As failure_reason;
   From _curTC_IDs ;
   Join cli_cur;
      On cli_cur.tc_id=_curTC_IDs.tc_id; 
   Left Outer Join hStat on _curTC_IDs.hivstat=hstat.code;
   Where _curTC_IDs.use_client=(.f.);
   Order by 3,4;
   Into Cursor _curServPool ReadWrite
   Go Top In _curServPool

   If Reccount('_curServPool')>(0)
      Select _curServPool
      Go Top
      Scan
         m.gender_descript=''
         If Seek(_curServPool.gender,'gender','code')
            m.gender_descript=Alltrim(gender.descript)
         Else
            m.gender_descript='n/a'
         EndIf
         
         m.failure_reason=''
         If _curServPool.f_poverty=(2) Or _curServPool.f_poverty=(3)
            m.failure_reason=m.failure_reason+'* Financial Information '
         EndIf 
         
         If f_hivstatus <> (0)
            m.failure_reason=m.failure_reason+'* HIV Status '
         EndIf 
*!*             If hivstatid=(0)
*!*               If Seek(tc_id,'hivstat')
*!*                  Replace hivstatid With 9
*!*               Else
*!*                  m.failure_reason=m.failure_reason+'* HIV Status '
*!*               Endif
*!*             EndIf 
         
         Replace _curServPool.failure_reason With m.failure_reason, _curServPool.gender_descript With m.gender_descript
      EndScan
   
      Insert Into _curClientListFinal;
        (rowtype,;
         included,;
         tc_id,;
         last_name,;
         first_name,;
         id_no,;
         sex,;
         dob,;
         gender_des,;
         hiv_status,;
         hiv_stat_des,;
         is_medical,;
         medical_yn,; 
         failure_reason); 
      Select;    
        '1',;
        'No ',;
         tc_id,;
         last_name,;
         first_name,;
         id_no,;
         sex,;
         dob,;   
         gender_descript,;
         hiv_status,;
         hiv_stat_des,;
         .f.,;
         ' ',;
         failure_reason From _curServPool
   EndIf
EndIf    
* failure_reason From _curServPool Where hivstatid <> (9)
If Reccount('_curClientListFinal') > (0)
   Set Seconds Off
   m.cTime=Ttoc(Datetime(),2)
   Set Seconds On

   Select _curClientListFinal
   Replace all curQH_note With m.curQH_note, cTime With m.cTime

   If nOrder=1
      Index On rowtype+Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
   Else
      Index On rowtype+Upper(Padl(id_no,10,'0')) Tag col1
   EndIf

   Set Order To col1
   Go Top
   gcRptName='rpt_rsr_client_combined'

   If nGroup <> (1)
     oWait.lbl_message.caption='Copying Tables...'
     Go Top
     Copy Fields;
        included,;
        last_name,;
        first_name,;
        id_no,;
        tc_id,;
        sex,;
        dob,;
        gender_des,;
        hiv_stat_des,;
        medical_yn,;
        failure_reason To rsr_extracts\rsr_clients_combined.csv CSV 
     
     Go Top
     
     oWait.Hide()   
     oApp.msg2user("IMPORTANT",'List of clients who are or are not included'+Chr(13)+;
                               'Clients received reportable Services but are not reportable'+Chr(13)+;
                               'rsr_clients_not_eligible.csv'+Chr(13)+' ')      
   EndIf 
   Go Top In _cur1Row
   Select _curClientListFinal
   Go Top
      
   oWait.Hide()   
   Do Case
      Case lPrev=(.f.) And nGroup <> (3)
         Report Form rpt_rsr_client_listing_combined.frx To Printer Prompt Noconsole NoDialog
          
      Case lPrev=(.t.) And nGroup <> (3)
         oApp.rpt_print(5, .t., 1, 'rpt_rsr_client_listing_combined', 1, 2)
            
   EndCase
Else
   oWait.Hide()   
   oApp.msg2user('NOTFOUNDG')      
      
EndIf
   
Select _curClientListFinal
Go Top
Go Top In _cur1Row
      
gcTc_id=cOldTC_ID

If Used('_curCP1')
   Use in _curCP1
EndIf 