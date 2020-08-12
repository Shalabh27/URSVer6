Clear

Clear All
Create Cursor xxx (form_name C(50))

nDir=ADir(aforms,'C:\URSVer6\Project\forms\*.scx')
For i = 1 to ndir
   Select 0
   Use (aforms[i,1])
   Go Top
   Scan
      n=Atcline('\ursver6\data\urs.dbc',properties)
      If n>0
         Insert Into xxx (form_name) Values (aforms[i,1])
         
         ? aforms[i,1]
      EndIf
   EndScan
   Use
EndFor

* When finished search for...
* Browse last for Atcline('\ursver6\data\urs.dbc',properties) > 0
* ..\..\data\urs.dbc