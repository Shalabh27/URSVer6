Clear 
Close Databases all
Clear All
Open Database i:\ursver6\data\urs.DBC

Create Cursor _curVNViews (viewname C(30))

Dimension aVNTables(1)
aVNTables(1)=''
=ADBObjects(aVNTables,"VIEW")

For Each oTable In aVNTables
  If Upper(Right(otable,3))='_VN'
     Insert Into _curVNViews (viewname) Values (otable)
  EndIf 
EndFor
