Parameters dbcLocation

NOTE: You can pass the full path to the database you want to use Or enter it below.
NOTE: "AIRSBridge.dll", "AIRSEncryptDecrypt.dll", "ClrHost4.dll" MUST be in the sam folder as this script!

Close Databases All
Close Tables All

Public gnencryption_source, gldataencrypted

gnencryption_source=1
gldataencrypted=.f.

*!* Enter full path to the database here
If !Empty(dbcLocation)
   If File(Addbs(dbcLocation)+'urs.dbc')=(.t.)
      Open Database (Addbs(dbcLocation)+'urs.dbc')
   EndIf
EndIf 

If Empty(Dbc())
  ? 'No Database in use'
  Return
EndIf 
Use system 

gnencryption_source=system.encryption_source
gldataencrypted=system.encrypted
Use in system 

If gnencryption_source=(2) And gldataencrypted=(.T.)
   If File("AIRSBridge.dll")=(.f.) Or ;
      File("AIRSEncryptDecrypt.dll")=(.f.) Or ;
      File("ClrHost4.dll") = (.f.) Or ;
      File("UCI_Generator.dll") = (.f.)
     
      Release oWelcome
      =Messagebox('Msg28a: One or more of the modules used to manage encryption were not found.'+Chr(13)+;
                  "These files are required to be in the AIRS folder..."+Chr(13)+;
                  ">> AIRSBridge.dll - "+Iif(File("AIRSBridge.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  ">> AIRSEncryptDecrypt.dll - "+Iif(File("AIRSEncryptDecrypt.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  ">> ClrHost4.dll - "+Iif(File("ClrHost4.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  ">> UCI_Generator.dll - "+Iif(File("UCI_Generator.dll")=(.f.),'Not Found!', 'Present.')+Chr(13)+;
                  'Indcations are that the data is encrypted. The system will be unavailable until the problem is resolved.',16,'Encryption (256) module',300000)

      Return
   Else
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
   EndIf 
Endif

Do mkclicur



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
=openfile('tb_encrypt')
=openfile('address','hshld_id')
=openfile('ai_famil','client_id')
=openfile('statvalu','scrnval1')
=openfile('ai_activ','tc_id')
=openfile('ai_clien')
=openfile('client')
=openfile('staffcur')
=openfile('lv_all_addresses')
=openfile('insstat')
=openfile('status')

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

Select id_list
Index On tc_id Tag tc_id Addit


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

Use In _curPolNum
nRowCountIn=Reccount('cli_cur')
nRowCountOut=0

*!* Unencrypt the client information
If oapp.gldataencrypted=(.t.)
   Select cli_cur
   Go Top
   Scan
      If !Empty(Nvl(last_name,''))
         lcDecryptedStream=''
         lcEncryptedStream=last_name
         lcDecryptedStream=decipher(lcEncryptedStream)
         Replace last_name With lcDecryptedStream
      EndIf
      
      If !Empty(Nvl(first_name,''))
         lcDecryptedStream=''
         lcEncryptedStream=first_name
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace first_name With lcDecryptedStream
      EndIf

      If !Empty(Nvl(ssn,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(ssn)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace ssn With lcDecryptedStream
      EndIf

      If !Empty(Nvl(ssi_no,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(ssi_no)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace ssi_no With lcDecryptedStream
      EndIf

      If !Empty(Nvl(cinn,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(cinn)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace cinn With lcDecryptedStream
      EndIf
      
      If !Empty(Nvl(phhome,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(phhome)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace phhome With lcDecryptedStream
      EndIf
      
      If !Empty(Nvl(phwork,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(phwork)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace phwork With lcDecryptedStream
      EndIf
      
   EndScan
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
If oapp.gldataencrypted=(.t.)
   Scan
      If !Empty(Nvl(street1,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(street1)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace street1 With lcDecryptedStream
      EndIf
      
      If !Empty(Nvl(home_ph,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(home_ph)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace home_ph With lcDecryptedStream
      EndIf

      If !Empty(Nvl(work_ph,''))
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(work_ph)
         lcDecryptedStream=decipher(lcEncryptedStream)

         Replace work_ph With lcDecryptedStream
      EndIf

   EndScan
EndIf
*

Function decipher(cTheString)
Local ccReturnValue
ccReturnValue=''

If gnencryption_source = (1)
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

If gnencryption_source = (2)
   ccReturnValue=goEncryptDecrypt.decrypt(Alltrim(clstring),'AIRSed',2)
EndIf

Return ccReturnValue
