Procedure mkclicur
Parameter lRunFromMain, clworker_id, lSupressAllMessages

* This program will create / re-create the CLI_CUR file
* which is a list of valid clients for a user.
* Param: .t. - Run for the first time (at login)
*        .f. - Run after login to create a new updated list

Local lnoldarea As Number,;
      cOldTag As Character,;
      nOldRec As Number,;
      lcDecryptedStream As Character

lnoldarea=Select(0)
lcDecryptedStream=''

If lRunFromMain=(.t.) And lSupressAllMessages=(.f.)
   If MessageBox('Are you sure that you want to Recreate the Client List?',292,'Refresh',30000)=7
      Return
   Endif
EndIf

If Used('cli_cur')
   Use In cli_cur
EndIf

Set Message To 'Building List of Clients: 1) Opening tables...'
=dbcOpenTable('tb_encrypt')
=dbcOpenTable('address','hshld_id')
=dbcOpenTable('ai_famil','client_id')
=dbcOpenTable('statvalu','scrnval1')
=dbcOpenTable('ai_activ','tc_id')
=dbcOpenTable('ai_clien')
=dbcOpenTable('client')
=dbcOpenTable('staffcur')
=dbcOpenTable('lv_all_addresses')
=dbcOpenTable('insstat')

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

Set Message To 'Building List of Clients: 2) Applying Security...'
=osecurity.security(gcWorker,"id_list",.f.)
Select id_list
Index On tc_id Tag tc_id Addit

Set Message To 'Building List of Clients: 3) Selecting Clients...'
If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
   oWelcome.txt_plain3.Value='Selecting client you can accesss...'
EndIf 
   
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
   If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
      oWelcome.txt_plain3.Value='Decrypting Client Data...'
   EndIf 
   
   Select cli_cur
   Go Top
   Set Message to 'Building List of Clients: 4) Decrypting client information(1)...'
   Scan
    If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
       nRowCountOut=nRowCountOut+1
       oWelcome.ProgressBar.ChangeProgress(Int((nRowCountOut/nRowCountIn)*100))
    EndIf 
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
Endif

Set Message To 'Building List of Clients: 5) Indexing...'
If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
   oWelcome.ProgressBar.ChangeProgress(0)
EndIf 

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

Select lv_all_addresses
Go Top
nRowCountIn=Reccount('lv_all_addresses')
nRowCountOut=0

If oapp.gldataencrypted=(.t.)
   If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
      oWelcome.txt_plain3.Value='Decrypting Address Data'
   EndIf 
   Set Message to 'Building List of Clients: 6) Decrypting Address Data(1)...'
   Scan
    If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
       nRowCountOut=nRowCountOut+1
       oWelcome.ProgressBar.ChangeProgress(Int((nRowCountOut/nRowCountIn)*100))
    EndIf 
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
EndIf

If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
   oWelcome.ProgressBar.visible=.f.
EndIf 

Set Message To 'Building List of Clients: 7) Updating address information...'
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

Set Message To 'Building List of Clients: 7) Updating address information...'
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
