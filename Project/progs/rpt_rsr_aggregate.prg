Parameters nTopOfForm, nLeftOfForm

oRSRProcess=NewObject('_rsr','RSR')
oNewRSRForm=NewObject('rsr_aggregate_report','rsr')

With oNewRSRForm
 .center_form_on_top()
 oNewRSRForm.Top=320+nTopOfForm
 oNewRSRForm.Left=oNewRSRForm.Left+30
 .rsr_processes.create_period_cursor('',.f.,.f.)

 Go Top in curQH

 If Eof('curQH')
    oApp.msg2user('INFORM','There are no periods to report on.')
    Return
 EndIf 
 .List_box1.rowsource='curQH'
 .List_box1.rowsourcetype=2
 .Show()
EndWith 
