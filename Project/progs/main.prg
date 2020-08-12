Parameters cldata_dir

Clear
_Screen.LockScreen=.t.
_Screen.BorderStyle=3

If File('control.urs')
   nFileControl=-99
   nOldReprocess=Set("Reprocess")
   
   Set Reprocess To 5
   nFileControl=Fopen('control.urs',12)
   Set Reprocess To (nOldReprocess)
   
   If nFileControl > 0
      =Fclose(nFileControl)
      Release nFileControl
   Else
      =Messagebox('Msg4: The AIRS Utilities or other activities are currently active.'+Chr(13)+;
                  'Please contact your AIRS administrator or try again later.',16,'AIRS Access Problem',3000)
      Quit
   EndIf
Else
   =StrToFile('[CONTROL] -1'+Chr(13)+'* REQUIRED FOR AIRS - DO NOT DELETE *','control.urs')
EndIf
Try
   Open Database data\urs Shared		
   *Open Database C:\URSVER6\data\urs Shared		&& Added By Shalabh to current Data Folder Structure Mar-07-2020
Catch
   _Screen.LockScreen=.f.
   =Messagebox('Msg2: The AIRS database is unavailable for use.'+Chr(13)+'Try again later.',16,'AIRS Access Problem',3000)
   Quit
EndTry

=dbcOpenTable('system_notifications')
Dimension _Anotify(1,7)
_Anotify[1,1]=0
_Anotify[1,2]=''
_Anotify[1,3]=''
_Anotify[1,4]=''
_Anotify[1,5]=.f.
_Anotify[1,6]=.f.
_Anotify[1,7]=''

Select notify_id, ;
       notification_start,;
       notification_end,;
       lockout_start, ;
       can_supress, ;
       display_on_login,;
       messageshort;
From system_notifications ;
Where is_active=(.t.) And ;
      Between(Date(),notification_start, notification_end) ;
Into Array _Anotify

If !Empty(_Anotify[1,1])
   If !Empty(_Anotify[1,4]) And Between(Date(),_Anotify[1,4],_Anotify[1,3])
      Close Databases All
      Set Seconds Off
      =MessageBox('AIRS is unavailable until '+Ttoc(_Anotify[1,4]),16,'AIRS - Offline',4000)
      Quit
   EndIf
EndIf 
Use In system_notifications

Set Classlib To standard Additive
Set Classlib To security Additive
Set Classlib To urs Additive
Sys(3055,510) && Increases the complexity level

oWelcome=NewObject('welcome','urs')
With oWelcome
  .Autocenter=.t.
  .titlebar=0
  .txt_plain3.value='Loading System...'
  .lbl_general2.caption='Copyright '+Str(Year(Date()),4)
EndWith 

oApp=CreateObject('app')
oEmailer=NewObject('emailer','emailer')

If oApp.lSaveFormPosition=(.t.)
   nLeft=0
   nTop=0
   nHeight=0
   nWidth=0
   
   If oApp.restorePosition(@nLeft, @nTop, @nHeight, @nWidth)=(.t.)
      With Application
       .Left=nLeft
       .Top=nTop
       .Height=nHeight
       .Width=nWidth
      EndWith 
      
      _screen.AutoCenter=.f.
      With oWelcome
       .AutoCenter=.f.
       .Left=nLeft+((_Screen.Width/2)-245)
       .Top=nTop+((_Screen.Height/2)-125)
      EndWith 
   Else 
      _Screen.WindowState=2
   EndIf 
   Release nLeft, nTop, nHeight, nWidth
Else
   _Screen.WindowState=2
EndIf

oWelcome.Show()
oApp.lOutLookAvailable=.f.

SET PROCEDURE TO outlook_test Add						&& Added By Shalabh Mar-07-2020
Try
*!*	  If oApp.isAppRunning('OUTLOOK.EXE',0)=(.t.)		&& Commented By Shalabh Mar-07-2020
*!*	     oOutLook=NewObject("outlook.application")		&& Commented By Shalabh Mar-07-2020
*!*	     Release oOutlook								&& Commented By Shalabh Mar-07-2020
  IF check_outlook() = 0								&& Added By Shalabh Mar-07-2020   
     oEmailer.loadSupportInfo()				
     If !Empty(oEmailer.cSupportURL) And !Empty(oEmailer.cRuntimeErrorSubject)
        oApp.lOutLookAvailable=.t.
     EndIf
   Endif
Catch
  oApp.lOutLookAvailable=.f.
EndTry

_Screen.Icon='AIRSFormsIcon.ico'
_Screen.AlwaysOnBottom=.t.
_Screen.MinButton=.f.
_Screen.MaxButton=.f.
_Screen.ShowTips=.t.
_Screen.Closable=.f.
_Screen.MinHeight=300
_Screen.MinWidth=600

Public CrRptPath, gUserId
CrRptpath= ""
gUserId = ""

=Sys(2450,1)  && Set the search path to internal first
cPath=Set('PATH')
Set Path To (cPath + "; data; editable_files") Additive 

Set Procedure To sp_progs addit

oWait=CreateObject('wait_form')
oSecurity=CreateObject('security')

_ReportPreview="frxpreview.prg"
_ReportOutput ="frxoutput.prg"

Set EngineBehavior 90
Set Exact Off
Set Udfparms To Reference
Set Sysmenu Off
Set Cpdialog Off
Set Hours To 12
Set Strictdate To 0
Set NullDisplay To ' '
Set MultiLocks On
Set Safety Off
Set Status Bar On
Set Talk Off
Set Memowidth To 1000
Set Deleted On
Set Exclusive Off
Set Reprocess To 1
Set Clock Status
Set Message To 'Loading System...'
Set Century On
Set Century To 19 Rollover 30

* Create application object
oApp.SaveEnvironment()
oApp.Setcaption('AIRS from NYSDOH AIDS Institute')
 
*!* Check that the VFP runtime is the patched SP2; otherwise some index expressions will generate and error.

** Commented Started by Shalabh 
*!*	If Right(Version(4),4)<>'6303'
*!*	   _Screen.LockScreen=.f.
*!*	   _Screen.Visible=.t.
*!*	   Release oWelcome
*!*	   
*!*	   =Messagebox('Msg27: The System Runtime drivers used by AIRS must be updated.'+Chr(13)+;
*!*	               'Please refer to the system documentation for complete instructions.',16,'AIRS Runtime Update Required',300000)
*!*	   oApp.exit_sys()
*!*	   return
*!*	EndIf
** Commented Ended by Shalabh 

*!* 09/2008 PB: Added control.urs file to prevent any users from accessing the system while the
*!* AIRS Utilties application is active.
*!*   If File('control.urs')
*!*      nFileControl=-99
*!*      nOldReprocess=Set("Reprocess")
*!*      
*!*      Set Reprocess To 5
*!*      nFileControl=Fopen('control.urs',12)
*!*      Set Reprocess To (nOldReprocess)
*!*      
*!*      If nFileControl > 0
*!*         =Fclose(nFileControl)
*!*         Release nFileControl
*!*      Else
*!*         =Messagebox('Msg4: The AIRS Utilities or other activities are currently active.'+Chr(13)+'Please contact your AIRS administrator or try again later.',16,'AIRS Access Problem',300000)
*!*         oApp.exit_sys()
*!*      EndIf
*!*   Else
*!*      =StrToFile('[CONTROL] -1'+Chr(13)+'* REQUIRED FOR AIRS - DO NOT DELETE *','control.urs')
*!*   EndIf
     
*!*   If !Empty(cldata_dir)
*!*      Try
*!*         Open Database (cldata_dir)
*!*         Set Path To (JustPath(cldata_dir)) Additive
*!*         
*!*      Catch
*!*         _Screen.LockScreen=.f.
*!*         _Screen.Visible=.t.
*!*         Release oWelcome
*!*         
*!*         =Messagebox('Msg1: The AIRS database is unavailable for use.'+Chr(13)+'Try again later.',16,'AIRS Access Problem',300000)
*!*         oApp.exit_sys()
*!*      EndTry
*!*   Else
*!*      Try
*!*         Open Database urs Shared
*!*      Catch
*!*         _Screen.LockScreen=.f.
*!*         _Screen.Visible=.t.
*!*         Release oWelcome
*!*         =Messagebox('Msg2: The AIRS database is unavailable for use.'+Chr(13)+'Try again later.',16,'AIRS Access Problem',300000)
*!*         oApp.exit_sys()
*!*      EndTry
*!*   EndIf

Select 0
Use system
* Custom work for agency: VIP
oApp.lairs2aims=system.airs2aims
oApp.nShowAgencyName=system.show_agency_name

If Reccount('system')=0
   Dimension aLogXML(1)
   Store '' To aLogXML
               
   If ADir(aLogXML, 'logs\initialize.xml') > 0
      Use agency In 0
      Use version_info In 0

      Use staff In 0
      Use userprof In 0
      Use jobtype In 0
      Use schemes In 0
      Use skipbar In 0

      =XMLToCursor('logs\'+aLogXML[1],'curSetup',512)

      If Reccount('curSetup') = 0
         =MessageBox('Msg25: Setup (1st time use) could not be completed.'+Chr(13)+;
                     'Please contact software support for assistance.',16,'AIRS')
         On Shutdown
         On Error
         Close Databases All
         Quit
         
      Else
         If File('AIRSUla.txt')=.t.
            mAIRSUla=FileToStr('AIRSUla.txt')
         EndIf
         
         lConfirmed=.f.
         oWelcome.Hide()
         
         Do Form confirm_form
         Read Events
         
         If lConfirmed=(.f.)
            On Shutdown
            On Error
            Close Databases All
            Quit
            
         EndIf
         
         oWelcome.Show()   
         Release mAIRSUla
         
         Insert Into System ;
           (system_id,;
            state,;
            systemname,;
            licensee,;
            version,;
            version_dt,;
            inst_compl,;
            user_id,;
            dt,;
            tm,;
            changed_color,;
            version_major,;
            version_minor,;
            version_revision,;
            show_tips,;
            initial_setup,;
            confirmation_code);
         Values ;
           (curSetup.agency_id,;
            curSetup.state,;
            'AIRS - AIDS Institute Reporting System', ;
            curSetup.licensee,;
            version_info.version,;
            version_info.version_dt,;
            .t.,;
            'INIT',;
            Date(),;
            Time(),;
            16711680,;
            version_info.version_major,;
            version_info.version_minor,;
            version_info.version_revision,;
            .t.,;
            Datetime(),;
            curSetup.confcode)
            
         cAgencyId=getnextid('AGENCY_ID')
         gcSys_Prefix=curSetup.agency_id
         gcAgency=cAgencyId
         
         Insert Into agency;
           (agency,;
            systimeout,;
            pw_days,;
            multilogin,; 
            descript1,;
            descript2,;
            street1,;
            street2,;
            city,;
            st,;
            zip);
         Values;
           (cAgencyId,;
            0,; 
            0,; 
            .f.,;
            curSetup.agency_nm,;
            curSetup.agency_co,; 
            curSetup.street1,; 
            curSetup.street2,; 
            curSetup.city,; 
            curSetup.state,; 
            Cast(curSetup.zip_code As Char(09)))
                    
         oSecurity.new_install()
         oSecurity.create_support_profile()
         
         Release gcSys_Prefix, cAgencyId, gcAgency
      EndIf

      Use In agency
      Use In version_info
      Use In staff
      Use In userprof
      Use In jobtype
      Use In schemes
      Use In skipbar
   Else
      =MessageBox('The system Activation & Confirmation process could not locate the required file.'+Chr(13)+;
                  'There are several reasons this could happen...' +Chr(13)+;
                  'You may not have the appropriate network security rights to access the file.' +Chr(13)+;
                  'The setup program failed in an unexpected way.' +Chr(13)+;
                  'The file is missing from the expected location.' +Chr(13)+;
                  'You will need to contact the application support for assistance',16,'Problem')

      On Shutdown
      Close Databases All
      Quit

   EndIf
EndIf

With oSecurity
 .nPasswordHistoryCount=Iif(Nvl(system.npw_history,0)<(26),26,system.npw_history)
 .nMinimumPWLength=Iif(Nvl(system.npw_length,0)<(10),10,system.npw_length)
 .nRequireSpecialCharacters=Iif(Nvl(system.npw_characters,0)=(0),1,system.npw_characters)
 .nAttemps=Iif(Nvl(system.npw_times,0) <= (0),5,system.npw_times)
 .nLockOut=Iif(Nvl(system.npw_locking,0)=(0),1,system.npw_locking)
 .nLockOutDuration=Iif(Nvl(system.lot,0)=(0),15,system.lot)
EndWith 

Use In system
Select 0

*!* Test that the system table is open.  ALways keep it open.
*!* Exit the ssytem if it's being used byanother process.
If openfile('system') <=0
   _Screen.LockScreen=.f.
   _Screen.Visible=.t.
   Release oWelcome
   
   =Messagebox('Msg26: The AIRS System is currently unavailable for use.'+Chr(13)+;
               'Please check with the System Administrator.',16,'AIRS in use',300000)
   oApp.exit_sys()
   Return
EndIf


If GetEnv('DEV') <> 'ON'
	On Error oapp.error_trap(Program(), Message(), Lineno(), Error())
EndIf 

oValid=CreateObject('validations')
oRpt=CreateObject('rpt')
otimer=CreateObject('app_timer')

oapp.glencryptionavailable=.t.

Public ;
  gcagency As Character,;
  gccl_name As Character,;
  gccl_tcid As Character,;
  gccl_worker As Character,;
  gcclient_id As Character,;
  gcfamfile As Character,;
  gcfname2 As Character,;
  gcfunname As Character,;
  gchist_id As Character,;
  gcHUB_id As Character,;
  gcjobtype As Character,;
  gclicensenm As Character,;
  gcprogram As Character,;
  gcprogfile As Character,;
  gcstaff_id As Character,;
  gcsite As Character,;
  gcsitefile As Character,;
  gcstate As Character,;
  gcsys_prefix As Character,;
  gcsystemnm As Character,;
  gctc As Character,;
  gctc_clien As Character,;
  gctc_id As Character,;
  gcworker As Character,;
  gcWorkerName As Character,;
  gctranfile As Character,;
  gcworkfile As Character,;
  glhasar As Logical,;
  glnoover As Logical,;
  glnoservrem As Logical,;
  glnoupdt As Logical,;
  glpcare As Logical,;
  glsys_support As Logical,;
  glsysadmin As Logical, ;
  gcRptName As Character, ;
  cscheme_id As String, ;
  glArchive As logical, ;
  gcAppRoot As String, ;
  gdCurrentDate as date, ;
  gcServCat As Character, ; 
  gcGrp_ID As Character, ;
  gcAtt_ID As Character,;
  gnModelID as Integer, ;
  gnInterventionID as Integer, ;
  glFromPEMS as logical, ;
  gcConNo as Character, ;
  gnEnc_ID as Integer, ;
  gcCategory as Character, ;
  gnTimeTrack as N(20,4), ;
  cHshld_ID as Character, ;
  gcCTR_ID as Character, ;
  glLegal as logical, ;
  gcActId as Character, ;
  gdDateSyr as date, ;
  gcSiteSyr As Character,;
  gcProgramSyr As Character,;
  gcWorkerSyr As Character, ;
  gcContractType as Character, ;
  gnContractID As Integer,;
  gcSerType as Character, ;
  gcServCatDef as Character, ;
  gnEncIDDef as Integer, ;
  gcContract as Character, ;
  gcExtract_ID as Character, ;
  gcVersion as Character, ;
  gdVerDate as Date, ;
  glSSNRequired As Logical, ;
  glDOBRequired As Logical, ;
  glSEXRequired As Logical, ;
  gcPayerCode as Character, ;
  gcPayerName as Character, ;
  gcProviderCode as Character, ;
  gcLateCode as Character, ;
  gcInvoice as Character, ;
  gcProvNum as Character, ;
  gcRateGrp as Character, ;
  gcRptAlias as Character, ;
  gcServCatBill as Character, ;
  gcProgramBill as Character, ;
  gcsiteBill as Character, ;
  gcCadrVers as Character, ;
  gcAgencyName as Character, ;
  gcServCatRpt As Character, ;
  dGrp_date as Date , ;
  gcid_no as Character, ;
  gnContractIDRpt as Int, ;
  gc5yrConnoRpt as Character, ;
  gnCotractIDTargRpt as Int ;
  gc1yrConnoRpt as Character, ;
  gcProjPrgRpt as Character, ;
  gnModelIDRpt as Int, ;
  gnIntervIDRpt as Int , ;
  gcTc_idRpt as Character
*  gnpw_days As Number, ;
   
*!* This Array holds the Windows system colors used to set the 
*!* for & back colors on some controls
Public Array gaSysColors(19)
Declare gaSysColors(19)
Store 0 To gaSysColors
Declare Integer GetSysColor In win32api Integer

For i = 1 To 19
  gaSysColors[i]=GetSysColor(i-1)
EndFor 

glArchive=File("archive.txt") && Check if we are in the archive version
_Screen.Caption='AIRS from NYSDOH AIDS Institute'+Iif(glArchive,' - Archive Version','')

gcRptName='' 
gcRptAlias=''  
gccl_name="Client"
gccl_tcid="TC"
gccl_worker="Worker"
gcfamfile="ai_famil"
gcfname2=''
gcfunname=''
gctc_id=' '
gcclient_id=' '
gcid_no=' '
gcHUB_id=''
gcprogfile="ai_prog"
gcsitefile="ai_site"
gctc="00002"
gctc_clien="ai_clien"
gctranfile="ai_trans"
gcworkfile="ai_work"
glHasAr=.f.
glNoOver=.f.
glNoServRem=.f.
glNoUpdt=.f.
glpcare=.t.
glsysadmin=.f.
* gnpw_days=0
cscheme_id='ZZ'
gcAppRoot=Strtran(Dbc(), 'DATA\URS.DBC', '')
gdCurrentDate=Date()
gcServCat=''
gcProgram=''
gcGrp_ID=''
gcAtt_ID=''
gnModelID=0
gnInterventionID=0
glFromPEMS=.f.
gcConNo=''
gnEnc_ID =0
gcCategory=''
gnTimeTrack=0
cHshld_ID=' '
gcCTR_ID=' '
glLegal=.f.
gcActId=Space(5)
glSSNRequired=.f.
glDOBRequired=.f.
glSEXRequired=.f.
gcAgencyName=' '
gcServCatRpt=Space(5)
dGrp_date ={}
gdDateSyr={}
gcSiteSyr=Space(5)
gcProgramSyr=Space(5)
gcWorkerSyr=Space(5)
gcContractType=Space(3)
gcSerType=Space(3)
gcServCatDef=Space(5)
gnEncIDDef=0
gcContract=Space(10)
gnContractID=0
gcPayerCode=Space(5)
gcPayerName=Space(35)
gcProviderCode=Space(5)
gcLateCode=Space(1)
gcInvoice=Space(9)
gcProvNum=SPACE(12) 
gcRateGrp=SPACE(5)
gcServCatBill=SPACE(5)
gcProgramBill=SPACE(5)
gcsiteBill=SPACE(5)
gnContractIDRpt=0
gc5yrConnoRpt=Space(10)
gnCotractIDTargRpt=0
gc1yrConnoRpt=Space(10)
gcProjPrgRpt=Space(5)
gnModelIDRpt=0
gnIntervIDRpt =0
gcTc_idRpt=''
gcExtract_ID=' '
gcCadrVers=''

oApp.nMonthBack=goMonth(Date(), - 12)

*-* Set the version information form the ver_info table
=OpenFile('version_info')
Select version_info
gcVersion=Alltrim(version_info.version)
gdVerDate=version_info.version_dt
oApp.gcversion_info=version_info.version_major+'.'+version_info.version_minor+'.'+version_info.version_revision
oapp.gcVersion=version_info.version
oapp.gdVerDate=version_info.version_dt
oApp.set_default_hhSite()

Use In version_info
=OpenFile('log_hist','concurrent')

gcsys_prefix=system.system_id
gcstate=system.state
gcsystemnm=Alltrim(system.systemname)
gclicensenm=Alltrim(system.licensee)

oApp.PFSource=Iif(system.filesource='35','New York State','Other')
oApp.gldataencrypted=system.encrypted

oApp.nPassword4=0
oApp.nDotNet4=0
If Fsize('net4','system') > (0)
   If system.net4=(1)
      oApp.nDotNet4=1
   EndIf
EndIf

*
If Fsize('npassword4','system') > (0)
   If system.nPassword4=(1)
      oApp.nPassword4=1
   EndIf
EndIf

*!* Enhanced Encryption indicator
Try
 oApp.gnencryption_source=system.encryption_source
Catch
 oApp.gnencryption_source=1
EndTry 

*!*   Old Code 
*!*   If File('ClrHost.dll')=(.f.)
*!*      _Screen.LockScreen=.f.
*!*      _Screen.Visible=.t.

*!*      Release oWelcome
*!*      =Messagebox('Msg28b: The module used to access encryption was not found...'+Chr(13)+;
*!*                  'Clrhost.dll was not found.  The system will be unavailable'+Chr(13)+;
*!*                  'until the problem is resolved.',16,'Module Not Found...',300000)
*!*      oApp.exit_sys()
*!*      Return
*!*   EndIf 

*!*   If oApp.gnencryption_source=(2) And oApp.gldataencrypted=(.T.)
*!*      If File('AIRS_Encrypt_Decrypt.dll')=(.f.)
*!*         _Screen.LockScreen=.f.
*!*         _Screen.Visible=.t.

*!*         Release oWelcome
*!*         
*!*         =Messagebox('Msg28: The library used for encryption is not available..'+Chr(13)+;
*!*                     'Indcations are that the data is encrypted.  The system'+Chr(13)+;
*!*                     'will be unavailable until the problem is resolved.',16,'Encryption (256)',300000)      
*!*         
*!*         oApp.exit_sys()
*!*         Return
*!*      Else
*!*         lcError=Space(1000)
*!*         lnSize=0
*!*         oWelcome.txt_plain3.value='Enabling Encryption...'

*!*         Declare Integer ClrCreateInstanceFrom In clrHost.dll string, string, string@, integer@
*!*         oApp.gnEncryption_handle=ClrCreateInstanceFrom("AIRS_Encrypt_Decrypt.dll","AIRS_Encrypt_Decrypt.AIRS_AES256",@lcError,@lnSize)
*!*         goEncryptDecrypt=Sys(3096,oApp.gnEncryption_handle)
*!*         Release cError, lnSize,cencm
*!*      EndIf 
*!*   EndIf 

*!*   If File('UCI_Generator.dll')=(.f.)
*!*      _Screen.LockScreen=.f.
*!*      _Screen.Visible=.t.

*!*      Release oWelcome
*!*      =Messagebox('Msg28c: The module used to generate the UCI was not found...'+Chr(13)+;
*!*                  'UCI_Generator.dll was not found.  The system will be'+Chr(13)+;
*!*                  'unavailable until the problem is resolved.',16,'Module Not Found...',300000)
*!*      oApp.exit_sys()
*!*      Return
*!*   EndIf 

If oApp.nDotNet4=(1) Or (oApp.gnencryption_source=(2) And oApp.gldataencrypted=(.t.))
   If File("AIRSBridge.dll")=(.f.) Or ;
      File("AIRSEncryptDecrypt.dll")=(.f.) Or ;
      File("ClrHost4.dll") = (.f.) Or ;
      File("UCI_Generator.dll") = (.f.)
     
      _Screen.LockScreen=.f.
      _Screen.Visible=.t.
      Release oWelcome
      =Messagebox('Msg28a: One or more of the modules used to manage encryption were not found.'+Chr(13)+;
                  "These files are required to be in the AIRS folder..."+Chr(13)+;
                  ">> AIRSBridge.dll - "+Iif(File("AIRSBridge.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  ">> AIRSEncryptDecrypt.dll - "+Iif(File("AIRSEncryptDecrypt.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  ">> ClrHost4.dll - "+Iif(File("ClrHost4.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  ">> UCI_Generator.dll - "+Iif(File("UCI_Generator.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  'Indcations are that the data is encrypted. The system will be unavailable until the problem is resolved.',16,'Encryption (256) module',300000)

      oApp.exit_sys()
      Return
   Else
      lcError=Space(1000)
      lnSize=1000
      vrsion="v4.0.30319"
      nVerson=0
      lnDispHandle=0
    
      oWelcome.txt_plain3.value='Enabling Encryption...'

      Try
        Declare Integer ClrCreateInstanceFrom IN ClrHost4.dll string, string, string@, integer@
        Declare Integer SetClrVersion IN ClrHost4.dll string
        nVerson=SetClrVersion(@vrsion)
        lnDispHandle=ClrCreateInstanceFrom("AIRSBridge.dll","AIRSBridge.Connection.AIRSDotNetBridge",@lcError,@lnSize)

        oll=SYS(3096,lnDispHandle)
        =Sys(3097,oll)

        goEncryptDecrypt=oll.Createassemblyinstancefromfile("AIRSEncryptDecrypt.dll","AIRSEncryptDecrypt.AIRS_AES256")
        loUCI=oll.Createassemblyinstancefromfile("UCI_Generator.dll","UCI_Generator.GenerateUCI")
     
        Release loUCIFailed, lnDispHandle, lnSize, lcError, nVerson, vrsion

      Catch
        loUCIFailed=.t.
        _Screen.LockScreen=.f.
        _Screen.Visible=.t.
        Release oWelcome
        =Messagebox('Msg28b: Failed to register one or more of the modules used to manage encryption were not found.'+Chr(13)+;
                    "Error: "+lcError+Chr(13)+;
                    'The system will be unavailable until the problem is resolved.',16,'Encryption (256) module',300000)
        oApp.exit_sys()
        Return
      EndTry
   EndIf 
Else
   loUCIFailed=.f.
   lnHandle=0
   lnSize=0
   lcError=''
   
   Try
      Declare Integer ClrCreateInstanceFrom In ClrHost.dll string, string, string@, integer@
   Catch
      loUCIFailed=.t.
      =MessageBox('"Declare Integer ClrCreateInstanceFrom In ClrHost.dll Failed [1]."',48,'eUCI Generator')
   EndTry
      
   *!* Using the .Net eUCI Generator with the ClrHost.dll as a host.
   If loUCIFailed=(.f.)
      Try
         lnHandle=ClrCreateInstanceFrom("UCI_Generator.dll","UCI_Generator.GenerateUCI",@lcError,@lnSize)
         loUCI=Sys(3096,lnHandle)
      Catch
         loUCIFailed=.t.
      EndTry
   EndIf

   If loUCIFailed=(.t.)
      _Screen.LockScreen=.f.
      _Screen.Visible=.t.
      Release oWelcome
      
      =MessageBox('"Declare Integer ClrCreateInstanceFrom In ClrHost.dll... Failed [2]."',48,'eUCI Generator')
      oApp.exit_sys()
      Return

   EndIf
   Release loUCIFailed, lnHandle, lnSize, lcError
EndIf 

With oApp
 .cintake_udf_caption=Iif(Empty(System.intake_udf_caption),' Other Information ',' '+System.intake_udf_caption+' ')
 .gcHIVQual_foder=system.hivqual_folder
 .gcai_extract_folder=system.ai_extract_folder
 .gcairs_extract_folder=system.airs_extract_folder
 .gcmhra_folder=system.mhra_folder
 .gcmpr_folder=system.mpr_folder
 .gcrdr_folder=system.rdr_folder
 .gcrpt_save_folder=system.rpt_save_folder
 .gcsmtp_name=system.smtp_name
 .gdt_last_backup=System.last_backup
 .gdt_last_db_archive=System.last_archived
 .gdt_last_db_validation=System.last_db_validation
 .gdt_last_reindex=System.last_reindexed
 .gdt_last_upgrade=System.upgrade_dt
 .glautopop_site=system.autopop_site
 .glcan_reuse_pw=system.lcan_reuse_pw
 .glcan_save_reports=system.lcan_save_reports
 .glconfirm_autopop=system.confirm_autopop
 .glsend_email_allowed=system.lsend_email_allowed
 .glshowtips=system.show_tips
 .gnchangedcolor=system.changed_color
EndWith

gcCadrVers=Alltrim(system.cadr_xver)

With oWelcome
 .txt_plain2.value=Alltrim(gclicensenm)
 .txt_plain1.value='Database Version '+oApp.gcversion_info
 .txt_plain3.refresh
 .txt_plain1.refresh
EndWith

If oApp.gldataencrypted=(.T.) .And. oapp.glencryptionavailable=(.F.)
   _Screen.LockScreen=.f.
   _Screen.Visible=.t.
   Release oWelcome
   
   MessageBox('Indications are that client level data is encrypted.'+chr(13)+;
              'This workstation does not have the required encryption'+chr(13)+;
              'tool installed.'+Chr(13)+;
              'Please contact the system administrator.',16,;
              'This session cannot continue!',60000)
   oApp.exit_sys()
   Return
EndIf

=openfile('agency')
Go Top
If !Eof()
   oapp.gnsystimeout=agency.systimeout*60000
   otimer.Interval=oapp.gnsystimeout
   oSecurity.nDays2Expiration=Iif(Empty(Nvl(agency.pw_days,0)) Or agency.pw_days>(183),183,agency.pw_days)
   *gnpw_days=agency.pw_days
   *oapp.glmultilogin=agency.multilogin
   gcagency=agency.agency
   gcAgencyName=Alltrim(agency.descript1)
   oApp.agency_aarid=agency.aar_id
   oApp.agency_zip=agency.zip
Endif

Use In agency

If gcstate="NY"
   =OpenFile('sgenno')
   If Seek(gcsys_prefix,'sgenno','csysid')
      gcFunName=cfname
      glNoUpdt=lnoupdt
      glNoOver=lnoover
      gcFName2=cfname2
      glSSNRequired=lrequired_ssn
      glDOBRequired=lrequired_dob
      glSEXRequired=lrequired_sex

      If Type("no_servrem")<>"U"
         glNoServRem=no_servrem
      EndIf

      If Type("has_AR")<>"U"
         glHasAr=Has_AR
      EndIf
      
   EndIf
   Use In sgenno
Else
   gcFunName="CTIDNO"
   glNoUpdt=.t.
   glNoOver=.f.
   gcFName2=""
   glNoServRem=.f.
   glHasAr=.f.
Endif

On Shutdown oApp.exit_sys()

=openfile('staff')

oApp.Setcaption('AIRS from NYSDOH AIDS Institute [ver '+gcVersion+']'+Iif(oApp.nShowAgencyName=(1),' - '+gcAgencyName,''))

*!* Log into the system 
Set Message To 'Application Login'
Set Message To 'Application Login'
*ologin=CreateObject('login')
oLogin=CreateObject('xlogin')

If oApp.gnencryption_source=(2) And oApp.gldataencrypted=(.T.)
   ologin.cust_box2.SpecialEffect=1
EndIf 

_Screen.Visible=.t.

Set Message To 'Application Login'
oWelcome.visible=.f.
_Screen.LockScreen=.f.

Set Escape On
ologin.Show()
Release ologin
Set Escape Off

If Empty(oSecurity.cstaff_id)
   Set Message To 'Exiting System!'
   Close Databases
   On Shutdown
   oApp.exit_sys()
   Return
EndIf

Dimension aprofiles(1)
If osecurity.workprofs(osecurity.cstaff_id, @aprofiles)=0
   Set Message To 'Sorry, You do not have access to the system'
  =oApp.Msg2user('NOAIRS4YOU')
   Close Databases
   On Shutdown
   oApp.exit_sys()
   return
EndIf

oSecurity.pwExpireWarning()

*!* Keep the gcstaff_id and gcworker_id vars.  But objects are avavilable.
* gcagency=aprofiles(1,3) && PB 05/2008
gcsite=aprofiles(1,5)
gcprogram=aprofiles(1,4)
gcjobtype=aprofiles(1,6)
gcworker=aprofiles(1,7)
osecurity.cworker_id=gcworker
Release aprofiles

gcstaff_id=osecurity.cstaff_id
glsysadmin=osecurity.lsysadmin
gcWorkerName=osecurity.cworkername

If oapp.glmultilogin=(.f.)
   If Seek(gcstaff_id+Dtos(Date())+'1','log_hist','concurrent')
      If Empty(Nvl(log_hist.logout_date,''))
         oWelcome.visible=.f.
         =MessageBox('This system does not allow a user to be logged in more than once.'+Chr(13)+;
                     'Indications are that you have another session open.'+Chr(13)+;
                     'Contact your System Administrator for more information.',16,'Problem',60000)

         Set Message To 'Exiting System!'
         Close Databases
         On Shutdown
         oApp.exit_sys()
         Return
      EndIf
   Endif
EndIf

If staff.chng_pw .Or. (oSecurity.nDays2Expiration <> (0) .And. (Date()-staff.pw_date) >= oSecurity.nDays2Expiration)
   If oApp.Msg2user('PWMUSTCHNG') = (1)
      oSecurity.leave_sys=.t.
      oPWReset=NewObject('reset_password','security',.Null.,'RESET')
      oPWReset.Show()
      If oSecurity.leave_sys=(.t.)
         Set Message To 'Exiting System!'
         Close Databases
         On Shutdown
         oApp.exit_sys()
         Return
      EndIf
   Else
      Set Message To 'Exiting System!'
      Close Databases
      On Shutdown
      oApp.exit_sys()
      Return
   EndIf  
EndIf

Set Message to 'Setting-up Data Environment...'
With oWelcome
 .txt_plain3.value='Setting-up Data Environment' 
 .txt_plain3.Refresh()
 If .AutoCenter=.f.
    .Left=_Screen.Left+((_Screen.Width/2)-245)
    .Top=_Screen.Top+((_Screen.Height/2)-125) 
 EndIf 
 .Visible=.t.
EndWith 

lDisplayOSWarning=oapp.set_os_version()  && Sets the property This.os_version
If lDisplayOSWarning=(.t.)
   Release oWelcome
   oApp.msg2user("OSWARNING")
   Close Databases
   On Shutdown
   oApp.exit_sys()
   Return
   
EndIf
Release lDisplayOSWarning

oApp.dlast_login='n/a'
Set Order To concurrent DESCENDING in log_hist
If Seek(gcstaff_id,'log_hist')
   Set Seconds Off
   oApp.dlast_login=Iif(IsNull(log_hist.logout_date),'n/a',Ttoc(log_hist.logout_date))
   Set Seconds On
EndIf 

Try 
   loWinSock=CreateObject("MSWinsock.Winsock")
   mWSId=loWinSock.LocalIP
   Release loWinSock
Catch
   mWSId=Id()
EndTry

oapp.gchist_id=getnextid('HIST_ID')
oapp.gdt_sessionstart=Datetime()

*lDisplayOSWarning=oapp.set_os_version()  && Sets the property This.os_version

Insert Into log_hist (tc, hist_id, staff_id, user_name, ws_network_id, ws_platform, login_date, user_id, dt_tm) ;
              Values (gctc, oapp.gchist_id, gcstaff_id, gcWorkerName, mWSId, oapp.os_version, oapp.gdt_sessionstart, gcworker, DateTime())

*!* Apply security policy and create clicur.
Set Database To urs

oWelcome.txt_plain3.Value='Setting-up Data Environment'
oWelcome.txt_plain3.Refresh()
Set Message to 'Setting-up Data Environment...'
nSec1=0
nSec2=0
nSecBase=0
nSecClicur=0

nSec1=Seconds()
cFailedTable=''
If dbcBaseInit(@cFailedTable)=(.f.)
   Set Message to 'Failed to setup data environment!'
   oWelcome.Release()
   oApp.msg2user('GENERROR','*** LOGIN PROCESS HALTED ***'+Chr(13)+;
                         'There is a problem accessing the table "'+cFailedTable+'".'+Chr(13)+;
                         'Notify your AIRS Administrator about this serious problem.'+Chr(13)+;
                         'Press Ok to Exit')
   Set Message To 'Exiting System!'
   oApp.exit_sys()
   Quit
Endif

Release cFailedTable

nSec2=Seconds()
nSecBase=nSec2-nSec1

oWelcome.txt_plain3.Value='Applying Security Policies'

If oapp.gldataencrypted=(.t.) And oApp.gnencryption_source=(2)
   oWelcome.ProgressBar.ChangeProgress(0)
   oWelcome.ProgressBar.Visible=.t.
EndIf

oWelcome.txt_plain3.Refresh()

Set Message to 'Applying Security Policies...'

nSec1=Seconds()
=mkclicur(.f.,gcworker)
nSec2=Seconds()
nSecClicur=nSec2-nSec1

oWelcome.ProgressBar.Visible=.f.

Select log_hist
If hist_id <> oapp.gchist_id
   =Seek(oapp.gchist_id,'log_hist','hist_id')
EndIf 
Replace baseinit_duration with nSecBase, clicur_duration With nSecClicur 

Use In log_hist
Release nSec1, nSec2, nSecBase, nSecClicur

Set Message To 'AIRS - AIDS Institute Reporting System'
=Openfile('staff','staff_id')
If Seek(osecurity.cstaff_id)
   If !Empty(staff.last_client_id)
      oApp.clast_client_id=staff.last_client_id
      
   EndIf 
   If !Empty(last_client_list)
      oApp.build_client_list
   Else
      Dimension oapp.aclientlist(1,3)
      oapp.aclientlist=.Null.
   EndIf
EndIf

If Used('staffcur')
   Select staffcur
Else
   Select 0
   Use staffcur
EndIf

Index On worker_id Tag worker_id Addit
Index On Upper(last)+Upper(first) Tag descript Addit
Index On c_t_id Tag c_t_id Addit

Select cli_cur

Release oWelcome
*!*    If lDisplayOSWarning=(.t.)
*!*       oApp.msg2user("OSWARNING")
*!*       
*!*    EndIf
*!*    Release lDisplayOSWarning

If !Empty(_Anotify[1,1])  && We have a message
   oApp.cNotificationShort=_Anotify[1,7]
   If _Anotify[1,5]=.t.   && The message can be supressed
      =Seek(gcstaff_id,'staff','staff_id')
      If staff.last_message_id=_Anotify[1,1]  && User supressed the message
         _Anotify[1,1]=0                      && Hide the message 
      EndIf
   EndIf
   If !Empty(_Anotify[1,1]) And _Anotify[1,6]=(.t.)  && We have a notification and display at login
      lNotAgain=.f.
      Do form notifications Noshow Name oNotify
      oNotify.nlNotify_ID=_Anotify[1,1]
      oNotify.chk_supress.controlSource='lNotAgain'
      oNotify.chk_supress.Value=.f.
      oApp.cNotificationShort=oNotify.setupMessage()
      oNotify.Show()
      Select staff
      Replace last_message_id With Iif(lNotAgain=(.t.),_Anotify[1,1], 0)
      
   EndIf 
EndIf 
Release _Anotify

Select cli_cur
Go Top

_Screen.LockScreen=.t.
Do C:\URSVer6\Project\menu\urs_main.mpr

oActionbar=Createobject('action_toolbar')
oActionbar.Dock(0)
oActionbar.Refresh()
oActionbar.visible=.t.

=BindEvent(_Screen,'MouseMove',otimer,'mousetrap')
otimer.Enabled=.t.

Set Database To URS
_Screen.Closable=.t.
_Screen.LockScreen=.f.

If GetEnv('DEV') <> 'ON'
	If File('AIRSHELP.hlp')
	   Set Help To AIRSHELP.hlp
	   On Key Label F1 Help
	Else
	   Set Help Off
	Endif   
EndIf

_Screen.MinButton=.t.
_Screen.MaxButton=.t.

Read Events

Set Message To 'Exiting System'
