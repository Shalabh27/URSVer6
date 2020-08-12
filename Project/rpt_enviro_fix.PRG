Clear

Clear All
Create Cursor xxx (report_name C(50))

nDir=ADir(areports,'C:\URSVer6\Project\reports\*.frx')
For i = 1 to ndir
   Select 0
   Use ('C:\URSVer6\Project\reports\'+areports[i,1])
   Go Top
   Scan
      If Atcline('DEVICE',expr) > 0
         Insert Into xxx (report_name) Values (areports[i,1])
         
         ? areports[i,1]
      EndIf
   EndScan
   Use
EndFor

* When finished search for...
* Browse last for Atcline('\ursver6\data\urs.dbc',properties) > 0
* ..\..\data\urs.dbc