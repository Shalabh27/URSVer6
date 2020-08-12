Close Databases All
Close Tables all
Release All

Open Database ..\data\urs
=dbcOpenTable('system')
oApp=NewObject('app')
oSecurity=NewObject('security')

oApp.gnencryption_source=system.encryption_source
oApp.gldataencrypted=system.encrypted
oApp.set_os_version()
Use in system
gcTc='00002'

If oApp.gnencryption_source=(2) And oApp.gldataencrypted=(.T.)
   lcError=Space(1000)
   lnSize=1000
   vrsion="v4.0.30319"
   nVerson=0
   lnDispHandle=0

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
     Return
   EndTry
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
      =MessageBox('"Declare Integer ClrCreateInstanceFrom In ClrHost.dll... Failed [2]."',48,'eUCI Generator')
      Return
   EndIf
   Release loUCIFailed, lnHandle, lnSize, lcError
EndIf 

=dbcOpenTable('next_id')
=dbcOpenTable('log_hist')

nSec1=Seconds()
=mkclicur()
nSec2=Seconds()
nSecClicur=nSec2-nSec1

cHistory_id=''
=dbcGetNextID('HIST_ID',@cHistory_id)
Insert Into log_hist(hist_id,login_date,ws_platform, clicur_duration) Values(cHistory_id,Datetime(),oApp.os_version, nSecClicur)

Use In tb_encrypt
Use In status
Use In address
Use In ai_famil
Use In statvalu
Use In ai_activ
Use In ai_clien
Use In client
Use In staffcur
Use In lv_all_addresses
Use In insstat
Use In Gender
Use In jobtype
Use In staff
Use In userprof
Use In cli_addr

Select cli_cur

? nSecClicur

Return


*****************************************************************************
Procedure mkclicur
Local lnoldarea As Number,;
      cOldTag As Character,;
      nOldRec As Number,;
      lcDecryptedStream As Character

lnoldarea=Select(0)
lcDecryptedStream=''

If Used('cli_cur')
   Use In cli_cur
EndIf

* Build a cursor of valid clients' tc_ids for user
=dbcOpentable('tb_encrypt')
=dbcOpentable('status')
=dbcOpentable('address','hshld_id')
=dbcOpentable('ai_famil','client_id')
=dbcOpentable('statvalu','scrnval1')
=dbcOpentable('ai_activ','tc_id')
=dbcOpentable('ai_clien')
=dbcOpentable('client')
=dbcOpentable('staffcur')
=dbcOpentable('lv_all_addresses')
=dbcOpentable('insstat')

Select Distinct insstat.client_id,;
  insstat.pol_num ;
From Insstat ;
Where !Empty(insstat.insstat_id) And ;
      !Empty(insstat.client_id) And ;
      insstat.prim_sec=(1) And ;
      insstat.client_id+Dtos(insstat.effect_dt) In ;
            (Select i2.client_id+Dtos(Max(i2.effect_dt)) ;
               From insstat i2;
               Where !Empty(i2.insstat_id) And ;
                     !Empty(i2.client_id) And ;
                     i2.prim_sec=(1) ;
               Group By i2.client_id);
Order by insstat.client_id;
Into Cursor _curPolNum Readwrite

Select Count(client_id) as cntr, ;
       client_id ;
From _curPolnum ;
Group By client_id ;
Into Cursor _cruCheck;
Order By 1 desc

Select _cruCheck
Go Top 
Scan
   If cntr > 1
      m.client_id=_cruCheck.client_id
      Select _curPolNum
      Delete For client_id=m.client_id
      Select _cruCheck
   Else
      Exit
   Endif
EndScan

Use In _cruCheck
Select _curPolNum

Select distinct tc_id ;
 From status ;
 Into Cursor id_list ReadWrite
   
Select ;
   a.tc_id, ;
   a.placed_dt, ;
   a.id_no, ;
   a.case_no,;
   a.registry, ;
   a.int_compl, ;
   a.int_prog, ;
   a.int_worker, ;
   a.anonymous, ;
   b.last_name, ;
   b.first_name, ;
   b.mi, ;
   b.client_id, ;
   b.dob, ;
   b.sex, ;
   b.gender, ;
   Nvl(d.descript_short,'(Not Entered)          ') As gender_description,;
   b.ethnic, ;
   b.ssn, ;
   Nvl(_curPolNum.pol_num,Space(45)) As cinn,;
   b.cinn As cinn2,;
   b.ssi_no,;
   Cast(Space(10) As Varchar(10)) As addr_id, ;
   Cast(Space(50) As Varchar(50)) As address, ;
   Space(02) As state,;
   Cast(Space(09) As Varchar(09)) As zip, ;
   Cast(Space(02) As Varchar(02)) As stat_code, ;
   Cast(Space(20) As Varchar(20)) AS casestat, ;
   Cast({} As DateTime) As status_date,;
   .t. As in_care, ;
   b.hispanic, ;
   b.white, ;
   b.blafrican, ;
   b.asian, ;
   b.hawaisland, ;
   b.indialaska, ;
   b.unknowrep, ;
   b.someother, ;
   b.age, ;
   b.phhome,;
   b.phwork,;
   b.birth_lbs,;
   b.birth_oz, ;
   b.insurance, ;
   b.is_refus, ;
   b.hshld_incm, ;
   b.hshld_size, ;
   a.discrete,;
   a.mail_cont,;
   a.phone_cont, ;
   a.home_cont, ;
   .f. As collat_only;
From id_list c;
Join ai_clien a On a.tc_id = c.tc_id ;
Join client b On a.client_id = b.client_id ;
Left Outer Join gender d On b.gender = d.code;
Left Outer Join _curPolNum On b.client_id=_curPolNum.client_id;
Into Cursor cli_cur ReadWrite

Use In id_list
Use In _curPolNum
nRowCountIn=Reccount('cli_cur')
nRowCountOut=0

*!* Unencrypt the client information
If oapp.gldataencrypted=(.t.)
   Select cli_cur
   Go Top
     Set Message to 'Building List of Clients: 4) Decrypting client information(1)...'
      Scan
         If !Empty(Nvl(last_name,''))
            lcDecryptedStream=''
            lcEncryptedStream=last_name
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)
            Replace last_name With lcDecryptedStream
         EndIf
         
         If !Empty(Nvl(first_name,''))
            lcDecryptedStream=''
            lcEncryptedStream=first_name
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace first_name With lcDecryptedStream
         EndIf

         If !Empty(Nvl(ssn,''))
            lcDecryptedStream=''
            lcEncryptedStream=Alltrim(ssn)
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace ssn With lcDecryptedStream
         EndIf

         If !Empty(Nvl(ssi_no,''))
            lcDecryptedStream=''
            lcEncryptedStream=Alltrim(ssi_no)
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace ssi_no With lcDecryptedStream
         EndIf

         If !Empty(Nvl(cinn,''))
            lcDecryptedStream=''
            lcEncryptedStream=Alltrim(cinn)
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace cinn With lcDecryptedStream
         EndIf
         
         If !Empty(Nvl(phhome,''))
            lcDecryptedStream=''
            lcEncryptedStream=Alltrim(phhome)
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace phhome With lcDecryptedStream
         EndIf
         
         If !Empty(Nvl(phwork,''))
            lcDecryptedStream=''
            lcEncryptedStream=Alltrim(phwork)
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace phwork With lcDecryptedStream
         EndIf
         
      EndScan
   
*!*         Case oApp.gnencryption_source=(2)
*!*            Local Array _aCollection[7]
*!*            Store '' To _aCollection
*!*            
*!*            Local Array _aCollection2[7]
*!*            Store '' To _aCollection2
*!*            Set Message to 'Building List of Clients: 4) Decrypting client information(2)...'
*!*            nRowCountOut=0
*!*            Scan 
*!*               If lRunFromMain=(.f.)
*!*                  nRowCountOut=nRowCountOut+1
*!*                  oWelcome.ProgressBar.ChangeProgress(Int((nRowCountOut/nRowCountIn)*100))
*!*               EndIf 
*!*               _aCollection[1]=Iif(IsNull(last_name),'',Alltrim(Last_name))
*!*               _aCollection[2]=Iif(IsNull(first_name),'',Alltrim(first_name))
*!*               _aCollection[3]=Iif(IsNull(ssn),'',Alltrim(ssn))
*!*               _aCollection[4]=Iif(IsNull(ssi_no),'',Alltrim(ssi_no))
*!*               _aCollection[5]=Iif(IsNull(cinn),'',Alltrim(cinn))
*!*               _aCollection[6]=Iif(IsNull(phhome),'',Alltrim(phhome))
*!*               _aCollection[7]=Iif(IsNull(phwork),'',Alltrim(phwork))
*!*               _aCollection2=goEncryptDecrypt.Decrypt(@_aCollection,'AIRSed',1)
*!*               Replace last_name With _aCollection2[1],;
*!*                       first_name With _aCollection2[2],;
*!*                       ssn With _aCollection2[3],;
*!*                       ssi_no With _aCollection2[4],;
*!*                       cinn With _aCollection2[5],;
*!*                       phhome With _aCollection2[6],;
*!*                       phwork With _aCollection2[7]
*!*               Store '' To _aCollection
*!*               Store '' To _aCollection2
*!*            EndScan 
*!*            Release _aCollection, _aCollection2
*!*      EndCase    
Endif

Select cli_cur
Index On Upper(last_name+first_name+mi) Tag Name
Index On id_no Tag id_no Additive
Index On registry Tag registry Additive
Index On case_no Tag case_no Additive
Index On ssn Tag ssn Additive
Index On cinn Tag cinn Additive
Index On int_compl Tag int_compl Additive
Index On client_id Tag client_id Additive
Index On tc_id Tag tc_id Additive

* Pre-select all clients' addresses
Select lv_all_addresses
Go Top
nRowCountIn=Reccount('lv_all_addresses')
nRowCountOut=0

If oapp.gldataencrypted=(.t.)
   Scan
      If !Empty(Nvl(street1,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(street1)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace street1 With lcDecryptedStream
      EndIf
      
      If !Empty(Nvl(home_ph,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(home_ph)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace home_ph With lcDecryptedStream
      EndIf

      If !Empty(Nvl(work_ph,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(work_ph)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace work_ph With lcDecryptedStream
      EndIf

   EndScan
         
*!*         Case oApp.gnencryption_source=(2)
*!*            Local Array _aCollection[3]
*!*            Store '' To _aCollection
*!*            
*!*            Local Array _aCollection2[3]
*!*            Store '' To _aCollection2
*!*         
*!*            Set Message to 'Building List of Clients: 6) Decrypting Address Data(2)...'
*!*            Scan 
*!*               If lRunFromMain=(.f.)
*!*                  nRowCountOut=nRowCountOut+1
*!*                  oWelcome.ProgressBar.ChangeProgress(Int((nRowCountOut/nRowCountIn)*100))
*!*               EndIf 

*!*               _aCollection[1]=Iif(IsNull(street1),'',Alltrim(street1))
*!*               _aCollection[2]=Iif(IsNull(home_ph),'',Alltrim(home_ph))
*!*               _aCollection[3]=Iif(IsNull(work_ph),'',Alltrim(work_ph))
*!*               
*!*               _aCollection2=goEncryptDecrypt.Decrypt(@_aCollection,'AIRSed')

*!*               Replace street1 With _aCollection2[1],;
*!*                       home_ph With _aCollection2[2],;
*!*                       work_ph With _aCollection2[3]

*!*               Store '' To _aCollection
*!*               Store '' To _aCollection2
*!*            EndScan 

*   EndCase
EndIf

Select;
   client_id As client_id, ;
   addr_id As addr_id, ;
   date As date, ;
   st As state,;
   Padr(Iif(!Empty(street1), Alltrim(street1) + ",", "") + ;
    Iif(!Empty(street2), Alltrim(street2) + ",", "") + ;
    Iif(!Empty(city), Alltrim(city) + ",", "") + st + " " + ;
    Iif(Len(Alltrim(zip))<=5, zip, Transform(Alltrim(zip), "@R 99999-9999")),50) As address, ;
   zip ;
From lv_all_addresses;
Into Cursor cli_addr ReadWrite

Select cli_addr
Index On client_id + Dtos(date) Tag client_dt Addit

Select ai_activ
Set Order To tag tc_id DESCENDING In ai_activ
Set Relation To gcTc+"ACTIV"+status Into statvalu

Select cli_cur
Set Order To Tag name
Set Relation To client_id Into cli_addr
Set Relation To tc_id Into ai_activ Addit

* Fill in some shortcuts to information for use in pick lists
Set Message To 'Building List of Clients: 7) Updating address information...'
Replace ;
   addr_id With cli_addr.addr_id, ;
   address With cli_addr.address, ;
   state With cli_addr.state,;
   zip With cli_addr.zip, ;
   stat_code With ai_activ.status, ;
   status_date With ai_activ.effective_dttm,;
   casestat With statvalu.descript, ;
   in_care With statvalu.incare All

Set Relation to
Go Top

* Update the collateral only flag
* If a person is incomplete and a collateral And not present in status.dbf 
* then set the collateral only flag to .t.

Select cli_cur
Go Top
Scan for Empty(placed_dt)
   If Seek(client_id,'ai_famil','client_id')=(.t.) And ;
      Seek(client_id,'ai_clien','client_id') =(.t.) And;
      Empty(ai_clien.entered)

      Replace ;
         collat_only With .t.,; 
         casestat With '* Collateral Only *'
   EndIf
EndScan
Set Order To tag tc_id ascending In ai_activ

Select ai_activ
Set Relation to

Set Message To ' '

Return
*

Define Class App As Custom
 gnencryption_source=0
 gldataencrypted=.f.
 os_version=''
 
 Procedure set_os_version
  Local cWinVer, cWinProdType, cServicePack, cVersionDef, lDisplayWarning
  cServicePack=Os(7)
  cVersionDef=' '
  cWinVer=' '
  cWinProdType=''
  Try
    Local loWSH As wscript.shell
    loWSH=CreateObject("wscript.shell")
    cVersionDef=loWSH.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\MICROSOFT\WINDOWS NT\CURRENTVERSION\ProductName")
    cWinVer=loWSH.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\MICROSOFT\WINDOWS NT\CURRENTVERSION\CurrentVersion")
    Release loWSH
    This.os_version=Alltrim(cVersionDef)+Iif(!Empty(cServicePack),'-'+cServicePack,'')
  Catch
    This.os_version=' '
  EndTry 
 EndProc 

EndDefine 
*

Define Class Security As Custom
 Procedure decipher(clstring, lForceOld)
    Local ccReturnValue
    ccReturnValue=''
    If lForceOld=(.t.) Or oApp.gnencryption_source = (1)
       Local ctemp, ;
             nlxtimes, ;
             nllength

       If Empty(clstring)
          Return clstring
       Endif

       nllength=Len(NVL(clstring, ''))
       ctemp=''

       For nlxtimes=1 To nllength
          ctemp=Mod(Asc(Substr(clstring,nlxtimes,1))+Mod(nlxtimes*179+11,255),255)
          ccReturnValue=ccReturnValue+Chr(ctemp)
       Endfor
    EndIf 

    If lForceOld=(.f.) And oApp.gnencryption_source = (2)
       ccReturnValue=goEncryptDecrypt.decrypt(Alltrim(clstring),'AIRSed',2)
    EndIf
    Return ccReturnValue
   EndProc 

EndDefine 