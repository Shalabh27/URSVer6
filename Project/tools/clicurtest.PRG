Close Databases All
Clear All
Release All

Open Database Q:\URSVers\data\urs.DBC

Set Classlib To ..\libs\security
osecurity=CreateObject('security')

Set Classlib To ..\libs\urs

oapp=CreateObject('app')

gctc='00002'
gcworker='VUAEP'
? Time()
=mkclicur(.f.,gcworker)
? Time()