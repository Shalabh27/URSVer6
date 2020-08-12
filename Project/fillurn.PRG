Local cProceed
vProceed=''

Try
  Open Database data\urs
  cProceed='Opened'
Catch
  cProceed=GetFile('dbc',"URS.DBC database","Select",0,"Locate the URS database")
  
EndTry 
If Empty(Nvl(cProceed,''))
   =MessageBox('Process cancelled by user request.',16,'Process Halted!')
   Return
EndIf

If cProceed<>'Opened'
   Try
      Open Database (cProceed)
   Catch
      cProceed=''
   EndTry
EndIf

If Empty(cProceed)
   =MessageBox('The selected file could not be opened.'+Chr(13)+'Try Again.',16,'Process Halted!')
   Return
EndIf

If !File('urn32.dll')
   =MessageBox('The URN.DLL file is not in the current folder.'+Chr(13)+'Please check the location.',16,'Process Halted!')
   Return
EndIf

Local lcUrn, lcBuildString, lcdob, lcSexCode
nSelection = MessageBox("Yes=Replace All URN's?"+Chr(13)+"No=Replace only those where the URS is empty)?",36,'URN Update')
*!* Yes = 6
*!* No =7

Use ai_clien


If !Empty(lcGender)
   lcSexCode=Iif(lcGender="M", "1", "2")

Else
   lcSexCode = "9"

EndIf

If Empty(lddob)
   lcdob=Space(06)
   
Else
   lcdob=Dtoc(lddob,1)
   If Len(lcdob)>6
      lcdob=Substr(lcdob,5,2)+Substr(lcdob,7,2)+Substr(lcdob,3,2)

   EndIf
EndIf

lcUrn=Left(lcFirstname,1)+;
      SubStr(lcFirstname,3,1)+;
      Left(lcLastname,1)+;
      SubStr(lcLastname,3,1)+;
      lcdob+;
      lcSexCode

Declare Long MDString In urn32.dll As geturn String
=geturn(@lcUrn)
lcUrn=Left(lcUrn,9)
Clear Dlls geturn

Return lcUrn