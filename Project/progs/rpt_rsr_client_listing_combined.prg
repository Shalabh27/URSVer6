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

oWait.Hide()
=dbcCloseTable('curServPool')
=dbcCloseTable('_cur1Row')
=dbcCloseTable('_curPrograms')
=dbcCloseTable('_curServPool')
=dbcCloseTable('_cur1Row')
=dbcCloseTable('_curTC_IDs')
=dbcCloseTable('_curCP1')

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
EndWith

Create Cursor _curClientListFinal;
  (rowtype C(01),;
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
   hiv_stat_des C(30),;
   is_medical L,;
   medical_yn C(01),;
   reason_excl C(30))

Create Cursor _cur1Row (programs_in_report M) 

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
      Insert Into _curClientListFinal;
              (rowtype,;
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
               medical_yn; 
            Select;    
              '2',;
               tc_id,;
               last_name,;
               first_name,;
               id_no,;
               sex,;
               dob,;   
               gender_des,;
               hiv_status,;
               hiv_stat_desc,;
               is_medical From curServPool Where !Deleted()
   EndIf 
EndIf

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

oRSRMethods.create_curTC_IDs()
Select _curTC_IDs
If Reccount() > (0)
   Select Distinct ;
      cli_cur.last_name,;
      cli_cur.first_name,;
      cli_cur.id_no,;
      cli_cur.case_no,;
      cli_cur.tc_id,;
      cli_cur.dob,;
      cli_cur.sex,;
      Space(30) As gender_descript,;
      _curTC_IDs.hivstat,;
      _curTC_IDs.use_client As use_client, ;
      _curTC_IDs.f_poverty As f_poverty, ;
      _curTC_IDs.f_hivstatus As f_hivstatus,;
      Space(30) As hiv_stat_des,;
      Space(40) As failure_reason;
   From _curTC_IDs ;
   Join cli_cur;
      On cli_cur.tc_id=_curTC_IDs.tc_id; 
   Where _curTC_IDs.use_client=(.f.);
   Order by 3,4;
   Into Cursor _curServPool ReadWrite
   Go Top In _curServPool

   If Reccount('_curServPool')>(0)
      Select _curServPool
      Go Top
      Scan
         m.gender_descript='n/a'
         m.hivstat_desc='n/a'
         If Seek(_curServPool.gender,'gender','code')
            m.gender_descript=Alltrim(gender.descript)
         Else
            m.gender_descript='n/a'
         EndIf 
         If !Empty(_curServPool.hiv_status)
            If Seek(_curServPool.hiv_status,'hstat','code')
               m.hivstat_desc=Alltrim(hstat.descript)
               m.hivstat_desc='n/a'
            EndIf 
         EndIf 
         
         m.failure_reason=''
         If _curServPool.f_poverty=(2) Or _curServPool.f_poverty=(3)
            m.failure_reason=m.failure_reason+'* Financial Information '
         EndIf 
         
         If _curServPool.f_hivstatus=(2) Or _curServPool.f_hivstatus=(3)
            m.failure_reason=m.failure_reason+'* HIV Status '
         EndIf 
         
         Replace _curServPool.failure_reason With m.failure_reason, ;
                 _curServPool.hiv_stat_desc With m.hivstat_desc, ;
                 _curServPool.gender_descript With m.gender_descript
         
      EndScan
   
      Insert Into _curClientListFinal;
        (rowtype,;
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
         medical_yn; 
      Select;    
        '1',;
         tc_id,;
         last_name,;
         first_name,;
         id_no,;
         sex,;
         dob,;   
         gender_descript,;
         hivstat,;
         hiv_stat_desc From _curServPool

   Set Seconds Off
   m.cTime=Ttoc(Datetime(),2)
   Set Seconds On

   Use in _curServPool
   Select _curClientListFinal
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
