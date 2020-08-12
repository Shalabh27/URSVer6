Create Cursor _curXXX (filename C(50), next_id I, reccount_id I, difference1 I)
Select next_id 
Set Order to file
Go Top

Scan
   If !Empty(next_id.file)
      Select 0
      Try
        Use (Alltrim(next_id.file))
        n=Reccount()
        Use
      Catch
        n=-1
      EndTry 
      Select next_id
      Insert Into _curXXX (filename, next_id, reccount_id) Values (Alltrim(next_id.File), next_id.last_id, n)
   EndIf 
EndScan 