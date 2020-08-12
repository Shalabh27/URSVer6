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

If Used('curServPool')
   Use In curServPool
EndIf

If Used('_cur1Row')
   Use In _cur1Row
Endif

nServiceID=0
Acopy(aSelvar1, aSelvar2)
nServiceID=Iif(Empty(aSelvar2[1,2]),'',aSelvar2[1,2])
Local lCloseServiceCategory

lCloseServiceCategory=.f.
If !Empty(nServiceID)
   =dbcOpenTable('rsr_service_definitions','serviceid',@lCloseServiceCategory)
EndIf 

oApp.vGenprop=''

If lCloseServiceCategory=(.t.)
   Use in rsr_service_definitions
EndIf 

oRSRMethods=NewObject('_rsr','rsr')
=oRSRMethods.create_period_cursor(.f.,.f.,.f.) 
oNewRSRForm=NewObject('rsr_starting','rsr',.null.,.t.)
oNewRSRForm.center_form_on_top()
oNewRSRForm.Show()

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

If !Empty(nServiceID)
   oApp.msg2user("RSR_CL2")
EndIf 

With oRSRMethods
 .dstart=curQH_q_begin
 .dend=curQH_h_end
 .Qh_id=curQH.qh_id
 .nServiceID=Iif(Empty(Nvl(nServiceID,0)),0,nServiceID)
 .cReportYear=Str(Year(.dend),4,0)
 .create_curPrograms()
 .create_curCP1(.t.)
 .create_curRSRServices(.t.)

 If .test_service_definitions()=(-1)
    Return
 Endif

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
      _curTC_IDs.use_client, ;
      _curTC_IDs.f_poverty, ;
      _curTC_IDs.f_hivstatus,;
      Space(40) As failure_reason;
   From _curTC_IDs ;
   Join cli_cur;
      On cli_cur.tc_id=_curTC_IDs.tc_id; 
   Where _curTC_IDs.use_client=(.f.);
   Order by 3,4;
   Into Cursor _curServPool ReadWrite

   Use In _curTC_IDs

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
   gcRptName = 'rpt_rsr_client_not_listing'

   oWait.Hide()   
   Do Case
      Case lPrev=(.f.)
         Report Form rpt_rsr_client_not_listing.frx To Printer Prompt Noconsole NoDialog
         
      Case lPrev=(.t.)
         oApp.rpt_print(5, .t., 1, 'rpt_rsr_client_not_listing', 1, 2)
         
   EndCase
EndIf

Use In _curTC_IDs
If Used('_curCP1')
   Use in _curCP1
EndIf 
