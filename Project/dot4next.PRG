Close Tables All
Use system Exclusive

If Fsize('net4','system') = (0)
   Alter Table System Add Column net4 N(1,0) Default 0
   Alter Table System Add Column Password4 N(1,0) Default 0
EndIf  
Replace net4 With 1

