Clear All
Set Classlib To ..\libs\urs
oApp=Createobject('app')

nOldAlias=Select()
=openfile('staff','staff_id')

If Seek('00002')
   oApp.build_client_list

EndIf
otoolbar=Createobject('action_toolbar')
oToolbar.dock(1)
oToolbar.Show

Select(nOldAlias)
Read events

Set Message To 'Completed.'