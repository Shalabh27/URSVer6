Parameters;
  lPrev,;     && Preview 
  aSelvar1,;  && select parameters from selection list
  nOrder,;    && order by
  nGroup,;    && report selection
  lcTitle,;   && report selection
  Date_from,; && from date
  Date_to,;   && to date
  Crit,;      && name of param
  lnStat,;    && selection(Output)  page 2
  cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)
cTc_id = ""
cProg_id=''

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
  If Rtrim(aSelvar2[i,1])="CTC_ID"
     cTc_id=aSelvar2[i,2]
  EndIf

  If Rtrim(aSelvar2[i,1])="LCPROG"
     cProg_id=aSelvar2[i,2]
  EndIf
EndFor

Private gchelp
gchelp= ""
cDate=Date()
cTime=Time()
AS_OF_D={}

cTitle="History Verification Tickler" 
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
Set Filter To

Go Top
Scan
   =dbcOpenTable(Alltrim(table_name),Alltrim(search_tag))
   Select vn_rules
EndScan 

=oVProcesses.create_curVerificationView()
Select _curVerificationView
Index on tc_id Tag tc_id

oWait.lbl_message.caption='Selecting Clients (1)'
oWait.Refresh()

If Empty(cTc_id)
   cWhere='!Empty(cli_cur.tc_id)'
   cWhere2='!Empty(lv_ai_prog.tc_id)'
Else
   cWhere='cli_cur.tc_id="'+cTc_id+'"'
   cWhere2='lv_ai_prog.tc_id="'+cTc_id+'"'
EndIf 

If !Empty(cProg_id)
   oWait.lbl_message.caption='Selecting Clients (2)'
   oWait.Refresh()

   =dbcOpenTable('lv_ai_prog','',@lcloseProg)
   
   Select Distinct tc_id From Lv_ai_prog Where program=cProg_id And ;
      ((lv_ai_prog.Start_dt <= Date_to And Empty(lv_ai_prog.End_dt)) Or;
      (!Empty(lv_ai_prog.End_dt) And (lv_ai_prog.End_dt > Date_from And lv_ai_prog.End_dt <= Date_to))) And; 
       &cWhere2 Into cursor _curTCID Order By 1
      
      cWhere=cWhere+' And cli_cur.tc_id In (Select tc_id From _curTCID)'

   If _tally = 0
      oApp.msg2user('NOTFOUNDG')
      Use In _curTCID
      Return 
   EndIf 

EndIf

oWait.lbl_message.caption='Selecting Clients (3)'
oWait.Refresh()

Select oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi) +' - '+cli_cur.id_no AS cFull_name, ;
		 client_id, ;
		 tc_id,;
       dob;
From cli_cur ;
Where ((placed_dt <= Date_to And in_care=(.t.)) or (In_care=(.f.) And placed_dt <= Date_to And status_date >=Date_to)) And &cWhere;
Into Cursor cClient Readwrite
* Where ((placed_dt <= Date_to And in_care=(.t.)) or (placed_dt <= Date_to And In_care=(.f.) And Between(status_date, Date_from,Date_to))) And &cWhere;

Select cClient
Go Top

oWait.lbl_message.caption='Gathering Verifications (1)'
oWait.Refresh()

Scan
   oVProcesses.tickler(.t., cClient.tc_id, cClient.dob, cClient.client_id,.t.)

   Select _curVerificationView
   If Seek(cClient.tc_id)
      Replace _curVerificationView.cFull_name With cClient.cfull_name For _curVerificationView.tc_id=cClient.tc_id

   Endif
  
   Select cClient
EndScan

oWait.lbl_message.caption='Gathering Verifications (2)'
oWait.Refresh()

Select _curVerificationView
Set Order To 

Select ;
	_curVerificationView.* , ;
	Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as as_of_D, ;
   Date_to As date_to; 
From ;
   _curVerificationView ;
Where _curVerificationView.cVnCategory <> 'A';
Into Cursor hist_verif Readwrite;
Order By cfull_name

Index On Upper(cfull_name) Tag OrderName
Set order to OrderName

Use in _curVerificationView

oWait.Hide

oApp.msg2user("OFF")
gcRptName = 'rpt_hist_verif'

Select hist_verif
Go Top 
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else 
   Do Case
      Case lPrev = .f.
           Report Form rpt_hist_verif  To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.     &&Preview
           oApp.rpt_print(5, .t., 1, 'rpt_hist_verif', 1, 2)
   EndCase 
EndIf