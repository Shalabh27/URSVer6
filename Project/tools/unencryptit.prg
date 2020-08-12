Clear

Set Deleted On
Set Strictdate To 0
Clear

Set classlib to ..\libs\urs
oApp=CreateObject('app')

Set Classlib To ..\libs\_crypt Addit
Try
   oEncrypt=CreateObject('_cryptapi')
Catch
   Wait WINDOW 'Encryption not installed'

EndTry

Open Database ..\data\urs Shared
Use client

m.last_name=last_name

Local lcEncryptedStream, lcDecryptedStream, lcPassword, lcKey

lcEncryptedStream = Alltrim(client.last_name)
lcDecryptedStream = ''
lcKey = 'Sedona'

*oencrypt.EncryptSessionStreamString(lcPassWord, lcKey, @lcEncryptedStream)
*? lcPassWord
*? lcEncryptedStream
? '---------------------'
oencrypt.ldisplayhighlevelapierrors=.t.
oencrypt.ldisplaylowlevelapierrors=.t.

Go Top
Scan
  If !Empty(last_name) And !IsNull(last_name)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(last_name)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace last_name With lcDecryptedStream
   EndIf
   
   If !Empty(first_name) And !IsNull(first_name)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(first_name)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace first_name With lcDecryptedStream
   EndIf

   If !Empty(ssn) And !IsNull(ssn)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(ssn)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace ssn With lcDecryptedStream
   EndIf

   If !Empty(ssi_no) And !IsNull(ssi_no)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(ssi_no)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace ssi_no With lcDecryptedStream
   EndIf

   If !Empty(cinn) And !IsNull(cinn)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(cinn)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace cinn With lcDecryptedStream
   EndIf

EndScan

Use address
Scan
   If !Empty(street1) And !IsNull(street1)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(street1)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace street1 With lcDecryptedStream
   EndIf
   
   If !Empty(home_ph) And !IsNull(home_ph)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(home_ph)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace home_ph With lcDecryptedStream
   EndIf

   If !Empty(work_ph) And !IsNull(work_ph)
      lcDecryptedStream=''
      lcEncryptedStream=Alltrim(work_ph)
      oencrypt.DecryptSessionStreamString(lcEncryptedStream, oapp.gcencryptionkey, @lcDecryptedStream)

      Replace work_ph With lcDecryptedStream
   EndIf
   
EndScan

Release All
* Clear All

