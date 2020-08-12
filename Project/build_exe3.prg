Clear
Close All

Clear All

? 'Build EXE, Copy to production folder ..\urs.exe'
? 'Packing Libs...'
? "--------------------------------------------------"

Try
   Use C:\URSVer6\libs\agency.vcx Exclusive
   Pack
   Use
   ? 'agency.vcx Packed'
Catch
   Wait WINDOW 'Agency in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\billing.vcx Exclusive
   Pack
   Use
   ? 'billing.vcx Packed'
Catch
   Wait WINDOW 'Billing in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\cadr.vcx Exclusive
   Pack
   Use
   ? 'cadr.vcx Pcked'
Catch
   Wait WINDOW 'CADR in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\client.vcx Exclusive
   Pack
   Use
   ? 'client.vcx Packed'
Catch
   Wait WINDOW 'Client in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\client_history.vcx Exclusive
   Pack
   Use
   ? 'client_history.vcx packed'
Catch
   Wait WINDOW 'Client_history in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\client_intake.vcx Exclusive
   Pack
   Use
   ? 'client_intake.vcx Packed'
Catch
   Wait WINDOW 'client_intake in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\ctr.vcx Exclusive
   Pack
   Use
   ? "ctr.vcx Packed"
Catch
   Wait WINDOW 'CTR in use'
   Return
EndTry

Try 
   Use C:\URSVer6\libs\euci.vcx Exclusive 
   Pack
   Use
   ? "euci.vcx Packed"
Catch
   Wait WINDOW 'eUCI in use'
   Return
EndTry

Use C:\URSVer6\libs\extracts.vcx Exclusive
Pack
Use
? "extracts.vcx Packed"

Try
   Use C:\URSVer6\libs\fast_track.vcx Exclusive
   Pack
   Use
   ? "fast_track.vcx Packed"
Catch
   Wait WINDOW 'Fast_Track in use'
   Return
EndTry

*!*   Use C:\URSVer6\libs\frxcontrols.vcx Exclusive
*!*   Pack
*!*   Use

*!*   Use C:\URSVer6\libs\frxpreview.vcx Exclusive
*!*   Pack
*!*   Use

Use C:\URSVer6\libs\grand_tracking.vcx Exclusive
Pack
Use
? "grand_tracking.vcx Packed"

Try
   Use C:\URSVer6\libs\group_activities.vcx Exclusive
   Pack
   Use
   ? "group_activities.vcx Packed"
   
Catch
   Wait WINDOW 'group_activities in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\hepatitis.vcx Exclusive
   Pack
   Use
   ? "hepatitis.vcx Packed"
Catch
   Wait WINDOW 'hepatitis in use'
   Return
EndTry

Use C:\URSVer6\libs\hiv_prevention.vcx Exclusive
Pack
Use
? "hiv_prevention.vcx Packed"

Use C:\URSVer6\libs\imports.vcx Exclusive
Pack
Use
? "imports.vcx Packed"

Try
   Use C:\URSVer6\libs\outreach.vcx Exclusive
   Pack
   Use
   ? "outreach.vcx Packed"
Catch
   Wait WINDOW 'outreach in use'
   Return
EndTry

Use C:\URSVer6\libs\pems2urs.vcx Exclusive
Pack
Use
? "pems2urs.vcx Packed"

Use C:\URSVer6\libs\reports.vcx Exclusive
Pack
Use
? "reports.vcx Packed"

Use C:\URSVer6\libs\rsr.vcx Exclusive
Pack
Use
? "rsr.vcx Packed"

Try
   Use C:\URSVer6\libs\security.vcx Exclusive
   Pack
   Use
   ? "security.vcx Packed"
   
Catch
   Wait WINDOW 'Security in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\services.vcx Exclusive
   Pack
   Use
   ? "services.vcx Packed"
Catch
   Wait WINDOW 'services in use'
   Return
EndTry

Try
   Use C:\URSVer6\libs\standard.vcx Exclusive
   Pack
   Use
   ? "standard.vcx Packed"
Catch
   Wait WINDOW 'Standard in use'
   Return
EndTry

Use C:\URSVer6\libs\syringe.vcx Exclusive
Pack
Use
? "syringe.vcx Packed"


Use C:\URSVer6\libs\treatment.vcx Exclusive
Pack
Use
? "treatment.vcx Packed"

Try
   Use C:\URSVer6\libs\urs.vcx Exclusive
   Pack
   Use
   ? "urs.vcx Packed"
   
Catch
   Wait WINDOW 'URS in use'
   Return
EndTry

Use C:\URSVer6\libs\verification.vcx Exclusive
Pack
Use
? "verification.vcx Packed"

Clear All
? "--------------------------------------------------"

? 'Building exe...'
Build Exe urs.exe From urs

AGetFileVersion(aVerName,'URS.EXE')
? 'Built Version:'+aVerName[4]

Try 
   ? 'Copying to production folder...'
   Copy File urs.exe To ..\urs.exe
   ? '*** Copied to production folder ***'
Catch
   ? '!!!! ..\urs.exe is in use, copy manually'

EndTry 

? "---- DONE ----"

Modify Project URS NoWait