*!*   Close Databases All
Set Exclusive Off
Set Deleted On
Close Tables

cFileName=''
ckey_expn=''
cIdString=''

Use next_id Order Tag next_id1 In 0
Use files Order Tag file In 0

Select file As FileName, ;
       act_tag, ;
       key, ;
       id_name ;
From files ;
Where type='DB' And ;
      action='R1' And ;
      !Empty(key) And ;
      Right(Alltrim(file),2) <> '_A' And ;
      Right(Alltrim(file),9) <> '_ARCHIVED' And ;
      !InList(Alltrim(file),'AI_ADHERENCE_BARRIERS','AGENCY','AUDIT','ARCH_LOG','MAIMPORT','MHRANARR','PROGTYPE','SKIPBAR','UDF_LUT','CLAIM_DT','CONNECT','ES_BILL','ENC_SERV','E2PXXXX');
Order By 1;
Into cursor _curFiles

*!* Create a list of tabale and the pk's
*!* get the lat id used from next_id
*!* get the maximum it from the table
*!* If the table ID is >= what is in the next_id table, report it 'PK Problem - TB:99999 NX:999999' Otherwise 'PK Ok - TB:99999 NX:999999'
*!* Next check for duplicates 

Select _curFiles
Go Top
Scan
   cFileName=Alltrim(_curFiles.filename)
   ckey_expn=Upper(Alltrim(_curFiles.key))
   cid_name=Upper(Alltrim(_curFiles.id_name))
   nNext_id=0
   cPkMessage="; PK's Not Checked"
   cBlanksMsg=''
   nPkProblem=0
   nDupProblem=0
   
   If Indbc(cFileName,"TABLE")
      
      Select 0
      Use (cFileName)
      Dimension _aCount(1)
      _aCount[1]=0

      Dimension _aMaxID(1)
      _aMaxID[1]=0
      
      If !Empty(cid_name)
         If Seek(cid_name,"next_id")
            If next_id.alphanum=(.f.)
               nNext_id=next_id.last_id
               *!* FIrst see if there are empty rows
               Select Count(ckey_expn) As col1 From (cFileName) Group By &ckey_expn Where Empty(&ckey_expn) Order by 1 Desc Into Array _aMaxID
               If _aMaxID[1] > 0
                   cBlanksMsg="; Empty Rows Found:"+Alltrim(Transform(_aMaxID,'9999999999'))
                   nPkProblem=1
               Else
                   cBlanksMsg='; No Empty Rows Identified.'
               EndIf
               _aMaxID[1]=0
               
               *!* Next sedd if there is a PK problem 
               Select Max(Val(Stuff(&ckey_expn,1,2,'00'))) From (cFileName) Where !Empty(ckey_expn) Into Array _aMaxID

               If nNext_id <= _aMaxID[1]
                  cPkMessage="; PK Problem - TB:"+Alltrim(Transform(Nvl(_aMaxID[1],0),'9999999999'))+" NX:"+Alltrim(Transform(nNext_id,'9999999999'))
                  nPkProblem=nPkProblem+1
               Else
                  cPkMessage="; PK's Ok - TB:"+Alltrim(Transform(Nvl(_aMaxID[1],0),'9999999999'))+" NX:"+Alltrim(Transform(nNext_id,'9999999999'))
                  
               EndIf 
               cPkMessage=cBlanksMsg+cPkMessage
               
            EndIf
         EndIf 
      EndIf 
      
      Dimension _aMaxDT(1)
      _aMaxDT[1]={}
      cDtString='; DT Column not found!'
      
      Try
        Select Max(dt) From (cFileName) Into Array _aMaxDT
        If IsNull(_aMaxDT[1])
           cDtString='; No Records to analyze'
           
        Else
        
           cDtString='; Maximum DT is '+Dtoc(_aMaxDT)
        EndIf 
      Catch
        cDtString='; DT Column not found!'
      EndTry 
      
      If Reccount(cFileName) > 0
         Select Top 1 Count(ckey_expn) As col1 From (cFileName) Where !Empty(ckey_expn) Group By &ckey_expn Order by 1 Desc Into Array _aCount
      EndIf
      
      If _aCount[1]=0 Or _aCount[1]=1
         cIdString=cIdString+Transform(nPkProblem+nDupProblem,'@r 9-')+cFileName+': No duplicates Found'+cPkMessage+cDtString+Chr(13)
      Else
         nDupProblem=2
         cIdString=cIdString+Transform(nPkProblem+nDupProblem,'@r 9-')+cFileName+': Duplicates Found > '+'Select Count('+ckey_expn+') As col1, '+ckey_expn+' From '+cFileName+' Group By '+ckey_expn+' Order by 1 Desc '+cPkMessage+cDtString+Chr(13)
         
      EndIf
      Use
   Else
      cIdString=cIdString+'Table Not Found in Database'+Chr(13)
   EndIf
   Select _curFiles
EndScan

=StrToFile(cIdString,'dup_pks_analysis.txt')