Declare gaSysColors(19)
Store 0 To gaSysColors

Declare Integer GetSysColor In win32api Integer
For i = 1 To 19
   gaSysColors[i]=GetSysColor(i-1)
EndFor
Clear Dlls

Set Procedure To \ursver6\project\progs\servlib
Set Classlib To \ursver6\libs\standard

othermo=CreateObject('thermobox')
oThermo.lblTextStatic.Caption='This is the static line'
oThermo.Refresh('This Line will change',0)

X=0
x2=10
oThermo.Show

For i = 1 to 10000000
   x=x+1
   If x = 1000000
      oThermo.Refresh('This Line will changez',x2)
      x=1
      x2=X2+10
   Endif

EndFor
oThermo.Refresh('This Line will changex',100)
=Inkey(2,'H')
