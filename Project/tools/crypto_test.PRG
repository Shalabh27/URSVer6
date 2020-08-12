Clear

Set Deleted On
Set Strictdate To 0
Clear

Set Classlib To ..\libs\_crypt Addit
Set Classlib To ..\libs\urs Addit

Try
   oEncrypt=CreateObject('_cryptapi')
Catch
   Wait WINDOW 'Encryption not installed'

EndTry

oApp=CreateObject('app')

Open Database ..\data\urs Shared
Use client In 0

Local lcEncryptedStream, lcDecryptedStream, lcPassword, lcKey

lcEncryptedStream = ''
lcDecryptedStream = ''
lcPassWord = m.last_name
lcKey = 'Sedona'

oencrypt.EncryptSessionStreamString(lcPassWord, lcKey, @lcEncryptedStream)
? lcPassWord
? lcEncryptedStream
? '---------------------'
oencrypt.DecryptSessionStreamString(lcEncryptedStream, lcKey, @lcDecryptedStream)
? lcDecryptedStream

Release All
Clear All
