Clear All

Select 0
Use change2airs Exclu
Zap

nxTimes=ADir(afrx,'i:\ursver6\project\reports\*.frx')

For i = 1 To nxTimes
   cFileName='i:\ursver6\project\reports\'+afrx[i,1]
   Select 0
   Use (cFileName)
   Locate For 'URS' $ Upper(expr)
   If Found()
*     Replace all expr With 'AIRS - Reporting System' For 'UNIFORM' $ Upper(expr)
      Insert Into change2airs (frx_file) Values (afrx[i,1])
   EndIf
   Use

EndFor


