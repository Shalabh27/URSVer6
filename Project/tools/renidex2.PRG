nxTimes = ADBObjects(aDataBaseOpbject,"TABLE")

For i = 1 To nxTimes
   Select 0
   Use (aDataBaseOpbject[i]) Exclusive
   ? aDataBaseOpbject[i]
   Reindex
   Use
EndFor
