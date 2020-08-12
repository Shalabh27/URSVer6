Clear All
Close Databases all

Open Database i:\ursver6\data\urs

Use files Order tag file
Go top

lTableFailure=.f.

nTables=ADBObjects(_atables,"TABLE")
=Asort(_atables)

For i = 1 to nTables
   If Seek(_atables[i],'files')=(.f.)
      ? _atables[i]
      lTableFailure=.t.
   EndIf 

EndFor 

If lTableFailure=(.t.)
   If MessageBox('The disk-file / files comparison failed'+Chr(13)+'Do you want to continue anyway?',36,'Table Verification')=(7)
      Return
   EndIf
EndIf 

i=0
nFieldCount=0
nIndex=0

Select files
Go Top
Replace has_tc_id With .f., has_client_id With .f., has_last_updated_dttm With .f. All
Go Top

For i = 1 to nTables
    Select Files
    If Seek(_atables[i],'files')=(.t.)
       =dbcOpenTable(_atables[i])
      
        nFieldCount=AFields(_aFields)
        If _atables[i] <> 'FILES'
           Use
        EndIf 
        Select Files
        
        For nIndex = 1 To nFieldCount
            If Upper(_aFields[nIndex,1])='TC_ID'
               Replace has_tc_id With .t.
            EndIf 
            
            If Upper(_aFields[nIndex,1])='CLIENT_ID'
               Replace has_client_id With .t.
            EndIf 
            
            If Upper(_aFields[nIndex,1])='LAST_UPDATED_DTTM'
               Replace has_last_updated_dttm With .t.
            EndIf 
            
        EndFor 
    Endif
EndFor 


