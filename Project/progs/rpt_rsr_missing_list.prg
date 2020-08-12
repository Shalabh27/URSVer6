Parameters ;
      lprev, ;        && Preview
      aselvar1, ;     && select parameters from selection list
      norder, ;       && order by
      ngroup, ;       && report selection
      lctitle, ;      && report selection
      ddate_from , ;  && from date
      ddate_to, ;     && to date
      crit , ;        && name of param
      lnstat, ;       && selection(Output)  page 2
      corderby        && order by description

oWait.Visible=.t.
 
Acopy(aselvar1, aselvar2)
cFundTypeSelected = ' '
cQuestionSelected = ' '
cFundProgSelected = ' '

cQFilter=''
oApp.vGenprop='All'

&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "CQUESTION"
      cQuestionSelected = aselvar2(i, 2)
   Endif
   If Rtrim(aselvar2(i, 1)) = "CFUNDTYPE"
      cFundTypeSelected = aselvar2(i, 2)
   EndIf

   If Rtrim(aselvar2(i, 1)) = "LCPROG"
      cFundProgSelected = aselvar2(i, 2)
   EndIf
   
EndFor

If !Empty(cFundTypeSelected) And !Empty(cFundProgSelected)
   oWait.Visible=.f.

   nProceed1=oApp.msg2user("MSG_YESNO",'Both Funding and Program were entered, only one can be used by this report.  You can select Funding or Program, but not both.',;
                           'The report will use Funding, do you want to proceed?')
   If nProceed1=2 Or nProceed1=0
      Return
   Else
      cFundProgSelected=' '
   EndIf 

   oWait.Visible=.t.
EndIf 

lKillFundt=.f.
lKillQuest=.f.

If !Used('fundtype')
   lKillFundt=.t.
   =OpenFile('fundtype','code')
EndIf 

If Empty(cFundTypeSelected)
   oApp.vGenprop='All Funding Types'
   
Else
   oApp.vGenprop=Iif(Seek(cFundTypeSelected,'fundtype','code')=(.t.),fundtype.descript,'n/a')
   
EndIf

If Empty(cFundProgSelected)
   oApp.vGenprop=oApp.vGenprop+' & All Programs'
   
Else
   oApp.vGenprop=oApp.vGenprop+' & '+Iif(Seek(cFundProgSelected,'program','prog_id')=(.t.),program.descript,'')
   
EndIf

If Empty(cQuestionSelected)
    oApp.vGenprop=oApp.vGenprop+' & All Questions'
Else
   lKillQuest=.t.
   =Openfile('rsr_xwalk','Q_NUMBER')
   If Seek(cQuestionSelected,'rsr_xwalk')
      oApp.vGenprop=oApp.vGenprop+' & '+Alltrim(rsr_xwalk.column_caption)+'.'+Alltrim(rsr_xwalk.column_display)
      cQFilter=rsr_xwalk.column_caption
   Endif
EndIf 

If Used('rsrmissingdata')
   Use In rsrmissingdata
EndIf 

oRSRMethods=Newobject('_rsr','rsr')
oRSRMethods.create_period_cursor(.F.,.F.,.f.)

If Reccount('curqh')=1
   Select curQH
   Replace is_selected With .t.
Else
   oWait.Visible=.f.
   oNewRSRForm=Newobject('rsr_starting','rsr',.Null.,.T.)
   onewRSRForm.center_form_on_top()
   onewRSRForm.Show()
   oWait.Visible=.t.
EndIf 

Select curQH
Go Top
Locate For is_selected =(.T.)
If Found()
   curqh_qh_id=curqh.qh_id
   curqh_q_begin=curqh.q_begin
   curqh_h_end=curqh.h_end
   m.curqh_note=curqh.Note
Else
   Use In curqh
   Return
Endif

With oRSRMethods
 .lFromMissingData=.t.
 .qh_id=curqh.qh_id
 .dstart=curqh_q_begin
 .dend=curqh_h_end
 .rsr_period=curqh.rsr_period
 .cfundingtype=''
 .cprogram_id=cFundProgSelected

 If .test_service_definitions()=(-1)
    Return
 EndIf
EndWith 

Use In curQH

nProcessReturnValue=0
nProcessReturnValue=oRSRMethods.doExtract()

If nProcessReturnValue=(0)
   oApp.msg2user("IMPORTANT","There is no information that can be used for this report"+Chr(13)+ "that match the time frame and/or options entered.")
   Return
   
EndIf 

*!* No funded services selected.
If nProcessReturnValue=(-2)
   Return
EndIf 

If Used('rsrmissingdata')=(.t.) And Reccount('rsrmissingdata')=0
   oApp.msg2user('MESSAGE','There were no clients found with missing data.')
   If File('rsr_extracts\RSRMissingData.csv')=(.t.)
      Delete File rsr_extracts\RSRMissingData.csv 
   EndIf
Else
   gcRptName = 'rpt_rsr_missing_data'
   Select rsrmissingdata
   Go Top
   
   Replace all md_note With m.curqh_note
   Go Top
   If !Empty(cQFilter)
      Set Filter To !Empty(&cQFilter)
      Go Top
      If Eof() = (.t.)
         oApp.msg2user('NOPRINTING')
         Set Filter To 
         Return
      EndIf 
   EndIf 
   
   oApp.clTime=Time()
   oWait.Hide()   

   Do Case
      Case lPrev=(.f.)
         Report Form rpt_rsr_missing_data.frx To Printer Prompt Noconsole NoDialog
         
      Case lPrev=(.t.)
         oApp.rpt_print(5, .t., 1, 'rpt_rsr_missing_data', 1, 2)
         
   EndCase

*  If File('rsr_extracts\RSRMissingData.csv')=(.t.)
*     Delete File rsr_extracts\RSRMissingData.csv 
*  EndIf

EndIf

*  Use In rsrmissingdata