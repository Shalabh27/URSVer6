Close Databases
Clear All
Set Classlib To ..\libs\_encryption
oEncrypt=Createobject('encryption')

Local cEncrypted1 As String, ;
      cEncrypted2 As String, ;
      cDecrypted1 As String, ;
      cDecrypted2 As String, ;
      cKey As String

cEncrypted1=''
cDecrypted1=''
cEncrypted2=''
cDecrypted2=''

*cKey=oEncrypt.urs_key

Use xxx
Go Top
? '------------------------------------------------------'
? Datetime()
Scan
   cEncrypted1=Alltrim(last_name)
   cDecrypted1=oEncrypt._engine.decryptString(cEncrypted1)

   cEncrypted2=Alltrim(first_name)
   cDecrypted2=oEncrypt._engine.decryptString(cEncrypted2)
   Replace last_name2 With cDecrypted1, first_nam2 With cDecrypted2

EndScan
? Datetime()