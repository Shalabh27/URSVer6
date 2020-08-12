Set Exclusive Off
Set Deleted On

*!*   Close Databases All
*!*   Clear All

*!*   Open Database i:\ursver6\data\urs Shared
Use next_id 
Go Top
cIdString=''

Scan For !Empty(file)
   cFileName=Alltrim(next_id.file)
   cid_name=Alltrim(next_id.id_name)
   nLen=Iif(next_id.use_prefix=(.t.),next_id.length-2,next_id.length)
   nNext_idVal=next_id.last_id
   cIdString=cIdString+Padr(cFileName,35)+Padr(cid_name,15)
   
   If Indbc(cFileName,"TABLE")
      Select 0
      Use (cFileName)
      
      If Fsize(cid_name)>0
         Release aNext_id
         Select Max(Evaluate(cid_name)) As max_id From (cFileName) Into Array aNext_id
       
         If _Tally > 0 And !Empty(Nvl(aNext_id[1],''))
            cIdString=cIdString+Padr('TBL:'+aNext_id[1],20)+Padr('FYL:'+Str(nNext_idVal,10,0),20)+Chr(13)
         Else
            cIdString=cIdString+'N/A;  N/A'+Chr(13)
         EndIf
      Else
         cIdString=cIdString+'Field Not Found'+Chr(13)
      EndIf
      Use
      
   Else
      cIdString=cIdString+'Not In DBC'+Chr(13)
   EndIf
EndScan

=StrToFile(cIdString,'c:\4peter\next_id_ana.txt')
