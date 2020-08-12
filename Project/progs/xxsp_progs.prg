**************************************
* Stored Procedures for URS database *
**************************************

Procedure getnextid
Parameter lcid, lFast

Local mnext_id, nArea, nLength

nArea=Select(0)
=openfile("next_id","next_id1")

*Dimension aTableStru[1]
mnext_id=''
*lUsePrefix=.f.
*lAlphanum=.f.
nLength=0

If Seek(lcid)
   If !Rlock()
      mnext_id = -1
   Else
      lAlphanum=next_id.alphanum

      nLength=Iif(next_id.use_prefix, next_id.length - 2, next_id.length)

      mnext_id=Padl(Iif(next_id.alphanum, Num2Char(next_id.last_id), ;
               next_id.last_id), nLength, Iif(next_id.alphanum,"A","0"))

      If next_id.use_prefix
         If VARTYPE(gcSys_Prefix) <> 'C' OR EMPTY(gcSys_Prefix)
         	=openfile("system")
         	PUBLIC gcSys_Prefix
         	gcSys_Prefix = system.system_id
         ENDIF
         
         mnext_id = gcSys_Prefix + mnext_id
      Endif

      Replace next_id.last_id With next_id.last_id + 1
      UNLOCK
      IF !lFast
         Flush In next_id FORCE
      ENDIF 
      
   Endif

Else
   mnext_id = -1
Endif

*!*	IF !lFast
*!*	   Use in next_id
*!*	ENDIF

*!*	Use In System

Select (nArea)
Return mnext_id
EndProc
*

*****************************************************************************
Procedure num2char
Parameter nNum

Local cRetVal, ;
      nFirstChar, ;
      aBaseChars, ;
      ix

ix=1
nFirstChar = Asc('A')

Dimension aBaseChars[36]

For ix = 1 To 26
   aBaseChars[ix] = Chr(ix + nFirstChar - 1)
Endfor

* Add digits from "0" to "9"
For ix = 27 To 36
   aBaseChars[ix] = Str(ix-27,1,0)
Endfor

cRetVal = ''
Do While .t.
   cRetVal = aBaseChars[1+nNum % 36] + cRetVal
   nNum = Int(nNum / 36)
   If nNum = 0
      Exit
   Endif
Enddo

Return cRetVal
EndProc

*
*****************************************************************************
Procedure baseinit
*!* Open some standard tables
=dbcOpenTable('baseinit','BASENAME')
Go Top
Scan
   Set Message To 'Opening Table: '+Trim(basename)
   If Indbc(Trim(basename), 'table')
      =dbcOpenTable(basename, initkey)
   EndIf 
   Select baseinit
EndScan

Set Message To 'Finished'

EndProc
*****************************************************************************
*

Procedure close_all
Local nlAreas As Number, ;
      i As Number,;
      afilesinuse As Character

i=0
nlAreas=0

Dimension afilesinuse[1,2]
afilesinuse=''
nlAreas=AUsed(afilesinuse)

For i=1 To nlAreas 
    If afilesinuse[i,1]<>'SYSTEM'
       Use In (afilesinuse[i,1])
   EndIf
EndFor
EndProc
*

*****************************************************************************
Procedure base_close
Local nlAreas As Number, ;
      i As Number,;
      afilesinuse As Character

i=0
nlAreas=0

Dimension afilesinuse[1,2]
afilesinuse=''
nlAreas=AUsed(afilesinuse)

=Openfile('baseinit','basename')

For i=1 To nlAreas 
   If !Seek(afilesinuse[i,1],'baseinit')
      If !InList(afilesinuse[i,1],'CLI_CUR','STAFFCUR')
         If Used(afilesinuse[i,1])
            Use In (afilesinuse[i,1])
         EndIf 

      EndIf
   EndIf
EndFor
EndProc
*

*****************************************************************************
Procedure OpenFile
Parameters clFileName, clTagName, cAlias ,clDatabase, clExclusive, lWasOpen
Private nArea, cOpenString

nArea=0
cOpenString=''
clFileName = ALLTRIM(clFileName)
lWasOpen=.f.

If Isnull(cAlias) .Or. Empty(cAlias)
* BK 4/5/06
*   cAlias=''
   cAlias = clFileName
EndIf

If IsNull(clFileName) .Or. Empty(clFileName)
   Return 0
EndIf

If IsNull(clDatabase) .Or. Empty(clDatabase)
   clDatabase=Dbc()
EndIf

* BK 4/5/06
*If Used(clFileName)
If Used(cAlias)
   Try
* BK 4/5/06
*      Select (clFileName)
      Select (cAlias)
      nArea=Select()
      If !Empty(clTagName)
         * BK 1/18/2006 - make sure tag exists before trying to set order
         clTagName = ALLTRIM(clTagName)
         IF ' ' $ clTagName 
	         cPureTagName = LEFT(clTagName, AT(' ', clTagName) - 1)
	     ELSE 
	         cPureTagName = clTagName 
	     ENDIF 
	     
         =ATAGINFO(aTags)
         IF ASCAN(aTags, UPPER(cPureTagName), 1, ALEN(aTags, 1), 1) > 0
         	Set Order To Tag &clTagName
         ENDIF
      EndIf
      lWasOpen=.t.
   Catch
      =MESSAGEBOX('Failed to select ' + cAlias + ' with order ' + clTagName)
      nArea=0
   EndTry
Else
   && PB: 03/2007 - Surround string in " " to account for spaces in folder name.
   cOpenString='Use "'+ IIF(!EMPTY(clDatabase), clDatabase+'!', '') + clFileName +'"'+ ;
            Iif(!Empty(cAlias),' Again Alias '+cAlias,'')+;
            Iif(!IsNull(clTagName) .And. !Empty(clTagName),' Order Tag '+clTagName,'')+;
            Iif(IsNull(clExclusive) .Or. Empty(clExclusive),' Shared',' Exclusive')

   Try
      Select 0
      ExecScript(cOpenString)
      nArea=Select()
   Catch
      =MESSAGEBOX('Failed to Execute: ' + CHR(13) + cOpenString,16,'AIRS - Open File')
      nArea=0
   EndTry
   
EndIf

Return nArea
EndProc
*

******************************************************************
** FUNCTION OPENEXCL                                            **
** Takes same parameters as OPENFILE but opens the file in      **
** exclusive mode. Gives the user a chance to retry opening.    **
** Returns .T. if file was opened , .F. if wasn't               **
******************************************************************
FUNCTION OPENEXCL
LPARAMETERS cFile, cTag, cAlias
LOCAL lOpened, lResult
cOldError = ON("ERROR")
cFile = AllTrim(cFile)

IF TYPE("cTag") <> "C"
	cTag = ""
ENDIF

IF TYPE("cAlias") <> "C" .OR. EMPTY(cAlias)
	cAlias = cFile
ENDIF

IF USED(cAlias)
	SELECT (cAlias)
ELSE
	SELECT 0
ENDIF

Do While .T.
	lResult = .T.
	lOpened = .T.
	Try 
		Use (LOCFILE(cFile+".dbf","DBF","Where is "+UPPER(cFile)+"?"));
			AGAIN ALIAS (cAlias) EXCLUSIVE 
	Catch  
		lResult = .f.
	EndTry 
	
	If !lResult
		lOpened = .F.
		If MessageBox("Couldn't open " + cFile + " exclusively: it may be in use by another user.", 5,'AIRS Data Access')=4
			Loop 
		EndIf 
	EndIf 
	Exit 
EndDo 

If lOpened AND !Empty(cTag)
   Set Order To Tag &cTag
EndIf 
Return lOpened

*****************************************************************************
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
* =close_all()
n1=Seconds()

If Used('cli_cur')
   Use In cli_cur
EndIf

* Build a cursor of valid clients' tc_ids for user
Set Message To 'Building List of Clients: 1) Opening tables...'
=DbcOpenTable('address','hshld_id')
=DbcOpenTable('ai_activ','tc_id')
=DbcOpenTable('ai_clien')
=DbcOpenTable('ai_famil','client_id')
=DbcOpenTable('client')
=DbcOpenTable('insstat')
=DbcOpenTable('lv_all_addresses')
=DbcOpenTable('staffcur')
=DbcOpenTable('statvalu','scrnval1')
* =DbcOpenTable('tb_encrypt')

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
* n1=Seconds()
limessage= 'Setting Stage:'+Transform(Seconds()-n1, '@999999999.99999')
n1=Seconds()

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
   b.last_name,;
   b.first_name,;
   b.mi, ;
   b.client_id, ;
   b.dob, ;
   b.sex, ;
   b.gender, ;
   Nvl(d.descript,'(Not Entered)          ') As gender_description,;
   b.ethnic, ;
   b.ssn,;
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

* n1=Seconds()
limessage=limessage+Chr(13)+'Selected your clients:'+Transform(Seconds()-n1, '@999999999.99999')
n1=Seconds()


*!* Unencrypt the client information
If oapp.gldataencrypted=(.t.)
   If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
      oWelcome.txt_plain3.Value='Decrypting Client Data...'
   EndIf 
   
   Select cli_cur
   Go Top

*   Do Case
*      Case oApp.gnencryption_source=(1)
         Set Message to 'Building List of Clients: 4) Decrypting client information(1)...'
         Scan
            If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
               nRowCountOut=nRowCountOut+1
               oWelcome.ProgressBar.ChangeProgress(Int((nRowCountOut/nRowCountIn)*100))
            EndIf 
            If !Empty(Nvl(last_name,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(last_name)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)
               Replace last_name With lcDecryptedStream
            EndIf
            
            If !Empty(Nvl(first_name,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(first_name)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)

               Replace first_name With lcDecryptedStream
            EndIf

            If !Empty(Nvl(ssn,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(ssn)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)

               Replace ssn With lcDecryptedStream
            EndIf

            If !Empty(Nvl(ssi_no,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(ssi_no)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)

               Replace ssi_no With lcDecryptedStream
            EndIf

            If !Empty(Nvl(cinn,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(cinn)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)

               Replace cinn With lcDecryptedStream
            EndIf
            
            If !Empty(Nvl(phhome,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(phhome)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)

               Replace phhome With lcDecryptedStream
            EndIf
            
            If !Empty(Nvl(phwork,''))
               lcDecryptedStream=''
               lcEncryptedStream=Alltrim(phwork)
               lcDecryptedStream=goEncryptDecrypt.decrypt(lcEncryptedStream,'AIRSed',2)

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
* n1=Seconds()
limessage=limessage+Chr(13)+'Unencrypted Client PHI:'+Transform(Seconds()-n1, '@999999999.99999')
n1=Seconds()

* Pre-select all clients' addresses
Select lv_all_addresses
Go Top
nRowCountIn=Reccount('lv_all_addresses')
nRowCountOut=0

If oapp.gldataencrypted=(.t.)
   If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
      oWelcome.txt_plain3.Value='Decrypting Address Data'
   EndIf 
   
*   Do Case 
*     Case oApp.gnencryption_source=(1)
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
If lRunFromMain=(.f.) And lSupressAllMessages=(.f.)
   oWelcome.ProgressBar.visible=.f.
EndIf 
* n1=Seconds()
limessage=limessage+Chr(13)+'Unencrypted Address PHI:'+Transform(Seconds()-n1, '@999999999.99999')
n1=Seconds()

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

* prepare staffcur - listing of all staff
* =base_close()
* =baseinit()

limessage=limessage+Chr(13)+'All other tasks:'+Transform(Seconds()-n1, '@999999999.99999')
StrToFile(limessage, 'stats.txt')
Select ai_activ
Set Relation to

Set Message To ' '

Return
*

*****************************************************************************
Procedure SkipFor
 Parameters cScreen_ID, lAvail_Edit, lArchAvail
 Local lResult, cOldExact
 
 cOldExact=Set("Exact")
 Set Exact On
 
 If (glArchive .And. !lArchAvail) .Or. (!lAvail_Edit .And. m.glEditing)
    lResult=.t.
 Else
   If !lAvail_Edit .And. !glMenuAvail 
      lResult=.t.
   Else
      If !glSysAdmin
         lResult=!Seek(gcScheme_id+Trim(cScreen_ID),"skipbar")
      Else
         lResult=.f.
      Endif
   Endif
 Endif
 Set Exact &cOldExact 
 
 Return lResult
EndProc 

***************************************************************
FUNCTION OpenView
LPARAMETERS cViewName, cDBC, cAlias, lRefresh, lNoData
LOCAL lWasOpen, cFullName

IF !Empty(cDBC) AND !DBUsed(cDBC)
	OPEN DATA (cDBC) SHARED
ENDIF

IF VARTYPE(cAlias) <> "C" .OR. EMPTY(cAlias)
	cAlias = cViewName
ENDIF

IF USED(cAlias) 
	SELECT (cAlias)
	IF lRefresh
		REQUERY()
	ENDIF
	lWasOpen = .t.
ELSE
	cFullname = IIF(!Empty(cDBC), cDBC + "!", "") + cViewname
	SELECT 0
	IF lNoData
		USE (cFullname) ALIAS (cAlias) NODATA
	ELSE
		USE (cFullname) ALIAS (cAlias)
	ENDIF
	lWasOpen = .f.
ENDIF
RETURN lWasOpen

*****************************************************************
* Check if id number is not duplicate
**
* jss, 2/10/04, use "==" instead of "=" to ensure true duplicates
FUNCTION ID_NO_DUPL
LPARAMETERS cID_NO, cClient_ID
LOCAL lOk, aTemp

select ;
	id_no, client_id ;
from ;
	ai_clien ;
where ;
	id_no == cID_NO and client_id <> cClient_ID ;
into ;
	array aTemp

lOk = (_TALLY = 0)

Return lOk

*****************************************************************
* CIN_CHK : check digit routine for 8 DIGIT CIN
* DATE    : 9/18/88
* AUTHOR  : F.G.L.
**
FUNCTION CIN_CHK
LPARAMETERS mcin
LOCAL mok, nOldArea

IF Len(Trim(mcin)) = 11
	Return .t.
ENDIF

nOldArea = Select()

mcin = upper(mcin)
mweight1 = 128
mweight2 = 64
mweight3 = 32
mweight4 = 16
mweight5 = 8
mweight6 = 4
mweight7 = 2

msum = 0

mpos1 = substr(mcin,1,1)
mpos2 = substr(mcin,2,1)
mpos3 = substr(mcin,3,1)
mpos4 = substr(mcin,4,1)
mpos5 = substr(mcin,5,1)
mpos6 = substr(mcin,6,1)
mpos7 = substr(mcin,7,1)
mpos8 = substr(mcin,8,1)

=openfile('cin_tbl')

locate for character = mpos1
mval1 = value

locate for character = mpos2
mval2 = value

mval3 = val(mpos3)
mval4 = val(mpos4)
mval5 = val(mpos5)
mval6 = val(mpos6)
mval7 = val(mpos7)

msum = (mval1 * mweight1) + (mval2 * mweight2) + (mval3 * mweight3) + ;
       (mval4 * mweight4) + (mval5 * mweight5) + (mval6 * mweight6) + ;
       (mval7 * mweight7)

mval8 = 23 - mod(msum, 23)

locate for value = mval8

mchk_digit = character

if mpos8 = mchk_digit
     select (nOldArea)
     return .t.
endif

if .not. 'L' $ left(mcin,7)
     select (nOldArea)
     return .f.
endif
**
** 8 character cin is always 2 characters followed by 5 digits followed
** by 1 character
** there are two possible values for the letter 'L'
** recalculate check digit with second value
**
if mpos1 = 'L'
    locate for character = mpos1
    skip
    mval1 = value
endif
if mpos2 = 'L'
    locate for character = mpos2
    skip
    mval2 = value
endif

msum = (mval1 * mweight1) + (mval2 * mweight2) + (mval3 * mweight3) + ;
       (mval4 * mweight4) + (mval5 * mweight5) + (mval6 * mweight6) + ;
       (mval7 * mweight7)

mval8 = 23 - mod(msum, 23)

locate for value = mval8

mchk_digit = character

if mpos8 = mchk_digit
     mok = .t.
else
     mok = .f.
endif

select (nOldArea)
return mok

*****************************************************************
* Check if Cin number is not duplicate
**
FUNCTION CIN_DUPL
LPARAMETERS cCinn, cClient_ID
LOCAL lOk, aTemp

select ;
	cinn, client_id ;
from ;
	client ;
where ;
	cinn = cCinn and client_id <> cClient_ID ;
into ;
	array aTemp

lOk = (_TALLY = 0)

Return lOk

*****************************************************************
* Converts string of type YYYY-MM-DD into date
FUNCTION AI_CTOD
LPARAMETERS cDate
cDate = LEFT(cDate, 10)
RETURN CTOD(SUBSTR(cDate, 6, 2) + '/' + RIGHT(cDate, 2) + '/' + LEFT(cDate, 4))

********************************************************************
**** Returns Time spent in minutes
********************************************************************
FUNCTION TimeSpent
LPARAMETERS cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
LOCAL nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
				0, VAL(LEFT(cEnd_tm,2))) + ;
				IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
				0, VAL(LEFT(cBeg_tm,2))) + ;
				IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes = 	(nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
			(nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes)

********************************************************************
**** Returns Time spent in decimal hours
********************************************************************
FUNCTION TimeSpentD
LPARAMETERS cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
LOCAL nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
				0, VAL(LEFT(cEnd_tm,2))) + ;
				IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
				0, VAL(LEFT(cBeg_tm,2))) + ;
				IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes = 	(nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
			(nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return Round((IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes) / 60), 4)

********************************************************************
**** Display time (numeric) in HH:MM format
********************************************************************
FUNCTION FormHours
LPARAMETERS nTime
Return StrTran(Str(INT(nTime/60),2)+":"+Str(nTime%60,2),' ','0')

********************************************************************
**** Display time in HH:MM format
**** For entries where time is entered in char fields as HHMM AM/PM
********************************************************************
FUNCTION FormatTime
LPARAMETERS cTime, cAM_PM
Return PADR(IIF(!EMPTY(cTime), TRANSFORM(cTime, '@R 99:99') + LOWER(cAM_PM), ''), 7)

************************************************************************
**** Formats a name in a form "Last,First M." or "Last,First Middle",
**** and allows display length to be specified
************************************************************************
FUNCTION FormatNameSP
LPARAMETERS cLast, cFirst, cMI, nDisplen
LOCAL cName, cMiddle

cLast=Iif(Empty(Nvl(cLast,''))=(.t.),'',ALLTRIM(cLast))
cFirst=Iif(Empty(Nvl(cFirst,''))=(.t.),'',ALLTRIM(cFirst))
cMI=Iif(Empty(Nvl(cMI,''))=(.t.),'',ALLTRIM(cMI))

cName = cLast + ", " + cFirst +     ;
	IIF(!EMPTY(cMiddle)," "+IIF(LEN(cMiddle) = 1, UPPER(cMiddle) + ".", cMiddle),"")

IF RIGHT(TRIM(cName),1) = ","
	cName = LEFT(cName,AT(",",cName)-1)
ENDIF

IF Type("nDisplen") = "N"
	cName = padr(alltrim(cName), nDisplen)
ENDIF

RETURN cName

*************************************************************************
FUNCTION UNICDIAG
************************************************************************
Local m.diag_id, m.icd9code, m.diagdate 

m.diag_id = lv_ai_diag_filtered.diag_id
m.icd9code = lv_ai_diag_filtered.icd9code
m.diagdate = lv_ai_diag_filtered.diagdate

SELECT * ;
FROM  Ai_Diag ;
WHERE diag_id <> m.diag_id  AND ;
   icd9code = m.icd9code AND ;
   diagdate = m.diagdate AND ;
   tc_id = gcTc_ID ;
INTO ARRAY aTemp

RETURN _TALLY = 0

*************************************************************************
FUNCTION UNICTEST
************************************************************************
Local m.labt_id, m.testtype, m.testcode, m.testdate 

m.labt_id = lv_testres_filtered.labt_id
m.testtype = lv_testres_filtered.testtype
m.testcode = lv_testres_filtered.testcode
m.testdate  = lv_testres_filtered.testdate 

SELECT * ;
   FROM  Testres ;
   WHERE labt_id <> m.labt_id ;
       AND testtype = m.testtype ;
       AND testcode = m.testcode ;
       AND testdate = m.testdate ;
       AND tc_id = gcTc_id ;
   INTO ARRAY aTemp
RETURN _TALLY = 0

*************************************************************************
FUNCTION CHKRANGE
************************************************************************
Local m.Range, m.count, m.testtype, m.testcode
m.Range = lv_testres_filtered.Range
m.count = lv_testres_filtered.count
m.testtype = lv_testres_filtered.testtype
m.testcode = lv_testres_filtered.testcode

IF !EMPTY(m.Range) AND !EMPTY(m.count)
   lcAlias = ALIAS()
   Select TSTRANGE
   LOCATE FOR BETWEEN(m.count, Tstrange.from, Tstrange.to) ;
            AND Tstrange.testname = "TEST" + m.testtype + m.testcode
   SELECT &lcAlias
   RETURN m.range = Tstrange.code
ELSE
   RETURN .T.
ENDIF

*************************************************************************
FUNCTION CHKTEST
************************************************************************
Local m.testcode, m.testtype

m.testcode = lv_testres_filtered.testcode
m.testtype = lv_testres_filtered.testtype

IF EMPTY(m.testcode)
   lcAlias = Alias()
   Select TESTTYPE
   SEEK m.testtype
   SELECT &lcAlias
   RETURN Testtype.test
ENDIF
********************
FUNCTION CHKCHKBOXS
********************
IF lv_relhist_filtered.riskunknow=1
   RETURN
ENDIF

PRIVATE numfields, ChkField, mChecked

mChecked=.F.
HOLDSEL=SELECT()
SELECT relhist
numfields=AFIELDS(ChkBoxArr)
FOR n=1 TO numfields
   IF ChkBoxArr(n,2)='N'
      ChkField = "lv_relhist_filtered." + ALLTRIM(ChkBoxArr(n,1))
      IF UPPER(ChkField) <> 'lv_relhist_filtered.COAG' AND UPPER(ChkField) <> 'lv_relhist_filtered.BIMALE' AND UPPER(ChkField) <> 'lv_relhist_filtered.BIFEMALE' AND UPPER(ChkField) <> 'lv_relhist_filtered.MOTHERRISK'
         IF Type(ChkField) = "N" AND &ChkField = 1
            mChecked=.T.
            EXIT
         ENDIF
      ENDIF   
   ENDIF   
ENDFOR

SELECT (HOLDSEL)

RETURN mChecked
*******************************************************************
Function ChkDate
LPARAMETER cID, nType, dDate
Local cAlias, lReturn
*** nType 4 is not for Medical billing and dates can overlap
cAlias = Alias()

If Used('t_chk')
   Use in t_chk
EndIf

Select * ;
from lv_insstat_filtered ;
where client_id = gcClient_id and;
      lv_insstat_filtered.prim_sec = nType and ;
      nType <= 3  and ;
      !Empty(lv_insstat_filtered.insstat_id) and ;
      lv_insstat_filtered.insstat_id != cId and ;
      BETWEEN(dDate, lv_insstat_filtered.effect_dt,   ;
              iif(Empty(lv_insstat_filtered.exp_dt), DATE(), lv_insstat_filtered.exp_dt) ) ;
Into cursor t_chk

If _Tally = 0
    lReturn = .t.
Else 
    lReturn = .f.
Endif       
Use in t_chk             

Select &cAlias
Return lreturn
*********************************************************************************
* CIN_CHK : check digit routine for 8 DIGIT CIN
**
FUNCTION CIN_CHK
Lparameters mcin
Local mok, nOldArea


IF Len(Trim(mcin)) = 11
   Return .t.
ENDIF

nOldArea = Select()

mcin = upper(mcin)
mweight1 = 128
mweight2 = 64
mweight3 = 32
mweight4 = 16
mweight5 = 8
mweight6 = 4
mweight7 = 2

msum = 0

mpos1 = substr(mcin,1,1)
mpos2 = substr(mcin,2,1)
mpos3 = substr(mcin,3,1)
mpos4 = substr(mcin,4,1)
mpos5 = substr(mcin,5,1)
mpos6 = substr(mcin,6,1)
mpos7 = substr(mcin,7,1)
mpos8 = substr(mcin,8,1)

=openfile('cin_tbl')

locate for character = mpos1
mval1 = value

locate for character = mpos2
mval2 = value

mval3 = val(mpos3)
mval4 = val(mpos4)
mval5 = val(mpos5)
mval6 = val(mpos6)
mval7 = val(mpos7)

msum = (mval1 * mweight1) + (mval2 * mweight2) + (mval3 * mweight3) + ;
       (mval4 * mweight4) + (mval5 * mweight5) + (mval6 * mweight6) + ;
       (mval7 * mweight7)

mval8 = 23 - mod(msum, 23)

locate for value = mval8

mchk_digit = character

if mpos8 = mchk_digit
     select (nOldArea)
     return .t.
endif

if .not. 'L' $ left(mcin,7)
     select (nOldArea)
     return .f.
endif
**
** 8 character cin is always 2 characters followed by 5 digits followed
** by 1 character
** there are two possible values for the letter 'L'
** recalculate check digit with second value
**
if mpos1 = 'L'
    locate for character = mpos1
    skip
    mval1 = value
endif
if mpos2 = 'L'
    locate for character = mpos2
    skip
    mval2 = value
endif

msum = (mval1 * mweight1) + (mval2 * mweight2) + (mval3 * mweight3) + ;
       (mval4 * mweight4) + (mval5 * mweight5) + (mval6 * mweight6) + ;
       (mval7 * mweight7)

mval8 = 23 - mod(msum, 23)

locate for value = mval8

mchk_digit = character

if mpos8 = mchk_digit
     mok = .t.
else
     mok = .f.
endif

select (nOldArea)
return mok

******************
FUNCTION Pnum_DUPL
******************
Lparameters cPol_num, cClient_ID
Local lOk, cAlias 

cAlias = Alias()

IF TYPE("cpol_num") <> 'C' OR TYPE("cclient_id") <> 'C'
   RETURN .t.
ENDIF

if oApp.gldataencrypted
   cPol_num = osecurity.encrypt(Alltrim(cPol_num))
EndIf

select ;
   pol_num, client_id ;
from ;
   insstat ;
where !Empty(pol_num) and ;
   cPol_num = pol_num and client_id <> cClient_ID ;
into cursor Pnum_DUPL

lOk = (_TALLY = 0)

Use in Pnum_DUPL

Select &cAlias

Return lOk

******************
FUNCTION chknumpos
******************
* jss, 12/01, add this routine to check that number born hiv+ doesn't exceed number born
Local lReturn
lReturn=.T.

DO CASE
   CASE lv_pregnant_filtered.birth_type=1       && single birth, numhivpos can't exceed 1
      IF lv_pregnant_filtered.numhivpos > 1
         lReturn=.F.
      ENDIF
   CASE lv_pregnant_filtered.birth_type=2       && twin birth, numhivpos can't exceed 2
      IF lv_pregnant_filtered.numhivpos > 2
         lReturn=.F.
      ENDIF
   CASE lv_pregnant_filtered.numhivpos > 7      && don't permit more than 7 in any case
      lReturn=.F.
ENDCASE
RETURN lReturn

**************************************************************
FUNCTION getdesc
PARAMETER cfilename, tcVarName, cfieldname, cDescName, cfilter
PRIVATE nsavearea, cDesc, cSearchStr
nsavearea = SELECT()

IF TYPE("cFieldName") <> "C"
   cfieldname = "code"
ENDIF

IF TYPE("cDescName") <> "C"
   cDescName= "descript"
ENDIF

IF TYPE("cFilter") <> "C"
   cFilter= ""
ENDIF

=openfile(cfilename)
m.cSearchStr = '&cfieldname = "'+EVAL(m.tcVarName)+'"'
IF !Empty(cFilter)
   cSearchStr = "("+cSearchStr + ") .and. ("+cFilter + ")"
ENDIF

* the table is supposed to have matching indexes on all fields involved
LOCATE FOR &cSearchStr
IF FOUND()
   cDesc = EVAL(cDescName)
ELSE
   cDesc = SPACE(LEN(EVAL(cDescName)))
ENDIF

SELECT (nsavearea)
RETURN cDesc

**********************************************************
FUNCTION Increment
**********************************************************
*  Function.........: Increment
*) Description......: Increment a variable if condition is met
*  Parameters.......: lCondition, nVar
**********************************************************
PARAMETERS lCondition, nVar
IF Type("nVar") <> "N"
   nVar = 0
ENDIF

IF lCondition
   nVar = nVar + 1
ENDIF

RETURN ""

****************************************************************************
FUNCTION Name
PARAMETER cLast, cFirst, cMI, nDisplen
PRIVATE cName, cMiddle

IF Type("cMI") <> "C"
   cMiddle = ""
ELSE
   cMiddle = ALLTRIM(cMI)
ENDIF

cname = ALLTRIM(cLast) + ", " + ALLTRIM(cFirst) +     ;
   IIF(!EMPTY(cMiddle)," "+IIF(LEN(cMiddle) = 1, UPPER(cMiddle) + ".", cMiddle),"")

IF RIGHT(TRIM(cName),1) = ","
   cname = LEFT(cName,AT(",",cName)-1)
ENDIF

IF Type("nDisplen") = "N"
   cname = padr(alltrim(cname), nDisplen)
ENDIF

RETURN cName
******************************************************************************
FUNCTION age
PARAMETERS tdDate, tdDOB
PRIVATE ALL LIKE j*
m.jcOldDate=SET("date")
SET DATE AMERICAN
m.jnAge=YEAR(m.tdDate)-YEAR(m.tddob)-;
        IIF(CTOD(LEFT(DTOC(m.tdDOB),6)+STR(YEAR(m.tdDate)))>m.tdDate,1,0)
SET DATE &jcOldDate
return m.jnAge

**********************************************************
FUNCTION CDC_AIDS
**********************************************************
*) Description......: Checks if client has CDC defined AIDS
**********************************************************
PARAMETER cTC_ID, dCDCDate
PRIVATE lResult
lResult = .F.
dCDCDate = {}
DIMENSION aCDCDob(2)

* jss, 1/10/04, as per V. Behn/B. Blake, must only consider clients 13 and older when using cd4 count criteria
Select ;
   dob ;
From ;
   client, ai_clien ;
Where ;
   ai_clien.tc_id=ctc_id ;
  and ;
   ai_clien.client_id=client.client_id ;
Into Array ;
   aCDCDob

m.CDCDob=aCDCDob(1)
m.CDCAge=IIF(!EMPTY(m.CDCDob), Age(DATE(),m.CDCDob), 0)
   
* If the client is HIV positive,
* create a cursor AIDSCase of all records pointing that a client is an AIDS patient:
* select the last of CD4 tests and check that CD4 count < 200 or CD4 percent < 14, 
* and a list of diagnoses that are AIDS indicator deseases and combine.
* Use the earliest of dates as CDC date

IF HIV_Pos(cTC_ID)

   SELECT ;
      testres.tc_id , ;
      testres.testdate AS DATE ;
   FROM ;
      testres ;
   WHERE ;
      testtype = '06' ;
      AND testres.tc_id = cTC_ID ;
      AND ((!EMPTY(COUNT) AND COUNT < 200) OR (!EMPTY(percent) AND percent < 14)) ;
      AND (EMPTY(m.CDCAge) OR (m.CDCAge>12)) ;
   UNION ;
   SELECT ;
      ai_diag.tc_id , ;
      ai_diag.diagdate AS DATE ;
   FROM ;
      ai_diag ;
   WHERE ;
      !EMPTY(hiv_icd9) ;
      AND ai_diag.tc_id = cTC_ID ;
   INTO ARRAY ;
      aCDC_AIDS ;
   ORDER BY 2 

   IF _TALLY <> 0
      lResult = .T.
      dCDCDate = aCDC_AIDS[1, 2]
   ENDIF
ENDIF

RETURN lResult

**********************************************************
FUNCTION HIV_Pos
**********************************************************
*) Description......: Detects if client is HIV positive
**********************************************************
PARAMETERS cTC_ID
PRIVATE lHIV_Pos

SELECT ;
   hstat.hiv_pos;
FROM ;
   hivstat, ;
   hstat ;
WHERE ;
   hivstat.tc_id = cTc_id ;
   AND hivstat.hivstatus = hstat.code ;
   AND hivstat.effect_dt = (SELECT MAX(effect_dt) ;
                              FROM ;
                                 hivstat f2 ;
                              WHERE ;
                                 f2.tc_id = cTc_id ) ;
INTO ARRAY ;
   aHivPos

IF _TALLY > 0      
   lHIV_Pos = aHivPos(1)
ELSE
   lHIV_Pos = .f.
ENDIF      

RETURN lHIV_Pos

****************************************************************************
FUNCTION mylookup
PARAMETER clookupfile, creturnfld,clookupval,clookupfld,clookuptag
PRIVATE nsavearea, creturnval

nsavearea = SELECT()
SELECT (clookupfile)
creturnval = LOOKUP(&creturnfld,clookupval,&clookupfld,clookuptag)
SELECT (nsavearea)

RETURN creturnval

**********************************************************
FUNCTION ShowStat
**********************************************************
* Displays Medicaid claim line status
* Statuses :
*  0 = "Unknown"
*  1 = "Pending"
*  2 = "Denied"
*  3 = "Paid"
*  4 = "Voided"
********************************************************************
PARAMETER nStatus

DIMENSION aOptions[5]
aOptions[1] = "Unknown"
aOptions[2] = "Pending"
aOptions[3] = "Denied"
aOptions[4] = "Paid"
aOptions[5] = "Voided"

RETURN PADR(aOptions[nStatus + 1],10)

**********************************************************
FUNCTION ShowAction
**********************************************************
*  FUNCTION.........: ShowAction
*) Description......: Displays what action is to be performed
*                     on Medicaid claims
*  0 = "None"
*  1 = "Rebill"
*  2 = "Never Rebill"
*  3 = "Adjust"
*  4 = "Void"
*  5 = "Confirmed" Void
**********************************************************
PARAMETER nAction

DIMENSION aAction[6]
aAction[1] = "None        "
aAction[2] = "Rebill      "
aAction[3] = "Never Rebill"
aAction[4] = "Adjust      "
aAction[5] = "Void        "
aAction[6] = "Confirmed   "

IF BETWEEN(claim_dt.action, 0, 4)
   RETURN aAction[nAction+1]
ELSE
      RETURN "            "
EndIf

*********************************************************
Procedure un_mark_disk

Select claimlog
Locate for claimlog.log_id = lv_claimlog_tmp.log_id
If Found()
      Replace ;
               claimlog.disk_sent With .f., ;
               claimlog.user_id   With gcWorker, ;
               claimlog.dt        With DATE(), ;
               claimlog.tm        With TIME()
               

      Select lv_claimlog_tmp
      Replace ;
               lv_claimlog_tmp.disk_sent With 'No ', ;
               lv_claimlog_tmp.ldisk_sent With .f., ;
               lv_claimlog_tmp.user_id   With gcWorker, ;
               lv_claimlog_tmp.dt        With DATE(), ;
               lv_claimlog_tmp.tm        With TIME()
               
    
EndIf      

Return 

*********************************************************
Procedure mark_disk
Select claimlog
Locate for claimlog.log_id = lv_claimlog_tmp.log_id
If Found()
      Replace ;
               claimlog.disk_sent With  .t.,;
               claimlog.user_id   With gcWorker, ;
               claimlog.dt        With DATE(), ;
               claimlog.tm        With TIME()
  
      Select lv_claimlog_tmp
      Replace ;
               lv_claimlog_tmp.disk_sent With 'Yes ', ;
               lv_claimlog_tmp.ldisk_sent With .t.,;
               lv_claimlog_tmp.user_id   With gcWorker, ;
               lv_claimlog_tmp.dt        With DATE(), ;
               lv_claimlog_tmp.tm        With TIME()
               
    
EndIf      

Return 
************************************************************
FUNCTION LFGETDIR
************************************************************
PARAMETERS lcDisk, lcExp, lcStartIn
PRIVATE lcDisk, lcExp
PRIVATE ALL LIKE j*

If Empty(Nvl(lcStartIn,''))
   lcStartIn=''
EndIf

lcOldErr   = ON("ERROR")
ON ERROR DO LFERR WITH ERROR(), lcDisk, lcExp
lcDisk = GETDIR(lcStartIn,lcDisk, lcExp)
ON ERROR &lcOldErr

RETURN lcDisk

************************************************************
FUNCTION LFERR
************************************************************
PARAMETER lnErrorNum, lcDisk, lcExp
PRIVATE lnErrorNum, lcDisk, lcExp
IF lnErrorNum = 1002
   lcDisk=GETDIR("C:\",lcExp)
ENDIF

RETURN lcDisk

************************************************************
FUNCTION diskstat
PARAMETER cLog_ID, cProcessed, lDiskSent
Local cAlias
PRIVATE cdiskstat

ldisksent = .F.

cAlias = Alias()

Select claimlog
Locate for claimlog.log_id = clog_id
If Found()
   DO CASE
   CASE claimlog.disk_sent and cProcessed = "D"
      cdiskstat = "Sent to Medicaid"
      ldisksent = .T.
   CASE claimlog.disk_sent and cProcessed <> "D"
      cdiskstat = "Sent, Claim Held"
   CASE claimlog.disk_made .AND. !claimlog.disk_sent
      cdiskstat = "Created, Not Sent"
   OTHERWISE
      cdiskstat = "Not Created"
   ENDCASE
ELSE
   IF EMPTY(clog_id)
      cdiskstat = "Not Created"
   ELSE
      cdiskstat = "*Log Not Found*"
   ENDIF
ENDIF

If !Empty(cAlias)
   Select &cAlias
EndIf
   
RETURN PADR(cdiskstat, 17)


*************************************************************************
**** Function Address
**** Returns a character string formatted as address based on a current
**** record position in the table where address is stored and common names
**** for address fields
**** C/O John Smith, 1234 First Street Apt. 1A, Smithtown, NY 12345
*************************************************************************
FUNCTION address
PARAMETER cAlias
PRIVATE cAddress, cCRLF, nSaveArea, lAreaChanged
cCRLF = CHR(13)+CHR(10)
nSaveArea = Select()

IF Type("cAlias") = "C" .and. !Empty(cAlias) .and. Alias() <> Upper(cAlias)
   select (cAlias)
   lAreaChanged = .t.
ELSE
   lAreaChanged = .f.
ENDIF

cAddress = ;
   IIF(Type("co_name") = "C" .and. !EMPTY(co_name), ;
         "C/O "+TRIM(co_name) + cCRLF,"") + ;
   IIF(!EMPTY(street1), TRIM(street1) + cCRLF, "") + ;
   IIF(!EMPTY(street2), TRIM(street2) + cCRLF, "") + ;
   TRIM(city) + IIF(!Empty(st) And !Empty(city) ,", ","") + st + "  " + ;
   IIF(LEN(TRIM(zip))<=5, zip, TRANSFORM(zip, "@R 99999-9999"))

IF LEFT(cAddress ,1) == ','
   cAddress = ''
ENDIF   

IF lAreaChanged
   Select (nSaveArea)
ENDIF

RETURN IIF(Trim(cAddress)=cCRLF+",","",cAddress)
   
****************************************************************
Procedure markit
PARAMETERS nAction, nRecord
LOCAL nRecno

SELECT lv_claims_tmp
nRecNo = RECNO()

   DO CASE
         * mark/unmark single
         * Statuses :
         *  0 = "Unknown"
         *  1 = "Pending"
         *  2 = "Denied"
         *  3 = "Paid"            && can be a payment for an adjusted claim
         *  4 = "Voided"
         *  5 = "Confirmed"         && claim_dt.status never =5, only for claims_cur cursor



   CASE nAction = 1            && MARK SINGLE
         GO nRecord
         
         DO CASE
         CASE lv_claims_tmp.STATUS = 0                                    && Unknown
               REPLACE lv_claims_tmp.STATUS WITH IIF(lv_claims_tmp.adj_void != 'V', 3, 4), ;
                      lv_claims_tmp.amt_paid WITH lv_claims_tmp.amount - lv_claims_tmp.copay_amt, ;
                      lv_claims_tmp.modified WITH .T.                        && Make Paid
                      
               Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                          lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)       
            
         CASE lv_claims_tmp.STATUS = 1                                    && Pending
               REPLACE lv_claims_tmp.STATUS WITH 0, ;
                      lv_claims_tmp.amt_paid WITH 0, ;
                      lv_claims_tmp.modified WITH .T.                        && Make Unkown
               
               Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                          lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)       
                                          
         CASE lv_claims_tmp.STATUS = 2                                    && Denied
               REPLACE lv_claims_tmp.STATUS WITH IIF(adj_void != 'V', 1, 1), ;
                      lv_claims_tmp.amt_paid WITH 0, ;
                      lv_claims_tmp.modified WITH .T.                        && Make Pend
               
               Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                          lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)              

         CASE lv_claims_tmp.STATUS = 3                                          && Paid
               REPLACE lv_claims_tmp.STATUS WITH IIF(lv_claims_tmp.adj_void != 'V', 2, 2), ;
                     lv_claims_tmp.amt_paid WITH 0, ;
                     lv_claims_tmp.modified WITH .T.                        && Make Denied
               
                  Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                          lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)       
                                                

         CASE lv_claims_tmp.STATUS = 4   AND lv_claims_tmp.adj_void = 'V'                           && Confirmed
               REPLACE lv_claims_tmp.STATUS WITH lv_claims_tmp.OrigStat, ;
                     lv_claims_tmp.modified WITH .T.
               
               Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                          lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)                
               *-* Mark claim as confirmed & amt_paid stays the same         && Make Original
         ENDCASE

   CASE nAction = 2            && MARK ALL
      REPLACE lv_claims_tmp.STATUS WITH IIF(lv_claims_tmp.adj_void != 'V', 3, 4), ;
            lv_claims_tmp.amt_paid WITH lv_claims_tmp.amount - lv_claims_tmp.copay_amt, ;
            lv_claims_tmp.modified WITH .T.    ;
            FOR lv_claims_tmp.STATUS = 0 All

       Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                    lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt) All
                                                 
   CASE nAction = 3            && UNMARK SINGLE
      GO nRecord
      REPLACE lv_claims_tmp.STATUS WITH lv_claims_tmp.OrigStat, ;
               lv_claims_tmp.amt_paid WITH lv_claims_tmp.OrigPaid, ;
               lv_claims_tmp.copay_amt WITH lv_claims_tmp.OrigCoPay, ;
               lv_claims_tmp.modified WITH .T.   
               
      Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                     lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)       
                                                   
   CASE nAction = 4            &&    UNMARK ALL
      **      The status is not always zero, it could be have been 1, This should only
      **      replace status with 1 or 0 since that is the allowed status in makecursor query
      REPLACE lv_claims_tmp.STATUS WITH lv_claims_tmp.OrigStat, ;
            lv_claims_tmp.amt_paid WITH lv_claims_tmp.OrigPaid, ;
            lv_claims_tmp.copay_amt WITH lv_claims_tmp.OrigCoPay, ;
            lv_claims_tmp.modified WITH .T.    ALL
            
      Replace lv_claims_tmp.adj_amt WITH iif(lv_claims_tmp.status!=3, 0.00, ;
                                     lv_claims_tmp.amount - lv_claims_tmp.amt_paid - lv_claims_tmp.copay_amt)       
                                                

   ENDCASE
   
   Replace lv_claims_tmp.status_descr WITH IIF(lv_claims_tmp.status=1,"Pending",IIF(lv_claims_tmp.status=2,"Denied ", ;
                       IIF(lv_claims_tmp.status=3,"Paid   ",IIF(lv_claims_tmp.status=4,"Voided ", ;
                       "Unknown")))) All
   
   nNowPaid =0.00
   
   SELECT lv_claims_tmp
   SUM(lv_claims_tmp.amt_paid) to nNowPaid for lv_claims_tmp.status = 3
                       
                       
   IF BETWEEN(nRecNo, 1, RECCOUNT())
      GO nRecNo
   ENDIF
RETURN 

******************************
PROCEDURE encserv
PARAMETERS nAction
LOCAL cCode, nEnc_sc_id, nEnc_id
cCode=''

DO CASE
******************* Encounters  Grid
   CASE nAction = 1   && Rate Code from grid Encounters       
           oApp.Pop_up("CODINGW1","CRATEC",cCode)
           
           IF !EMPTY(cCode)
                SELECT lv_enc_tmp
                IF ALLTRIM(lv_enc_tmp.rate_code) <> ALLTRIM(cCode)
                   Replace lv_enc_tmp.rate_code WITH cCode, ;
                           rec_modified WITH .t.
                           
                   nEnc_sc_id = lv_enc_tmp.Enc_sc_id
                   nEnc_id = lv_enc_tmp.Enc_id
                            
                   Select  lv_serv_tmp
                   Replace lv_serv_tmp.rate_code WITH cCode, ;
                           rec_modified WITH .t. FOR lv_serv_tmp.Enc_sc_id =nEnc_sc_id AND ;
                           lv_serv_tmp.enc_id = nEnc_id
                ENDIF
           ELSE
                SELECT ratecur
                LOCATE FOR ratecur.rate_code = lv_enc_tmp.rate_code
                IF !FOUND()
                     SELECT lv_enc_tmp
                     Replace lv_enc_tmp.rate_code WITH '', ;
                                             rec_modified WITH .t.
                                 
                     nEnc_sc_id = lv_enc_tmp.Enc_sc_id
                     nEnc_id = lv_enc_tmp.Enc_id
                               
                     Select  lv_serv_tmp
                     Replace lv_serv_tmp.rate_code WITH '', ;
                             rec_modified WITH .t. ;
                                        FOR lv_serv_tmp.Enc_sc_id =nEnc_sc_id AND ;
                                                lv_serv_tmp.enc_id = nEnc_id  
               Endif       
           ENDIF
            
           SELECT lv_enc_tmp                  
          
   CASE nAction = 2 &&Procedure code from grid Encounters
           oApp.Pop_up("CODINGW1","CPROCC",cCode)   
           IF !EMPTY(cCode)
                SELECT lv_enc_tmp
                IF ALLTRIM(lv_enc_tmp.proc_code) <> ALLTRIM(cCode)
                   Replace lv_enc_tmp.proc_code WITH cCode, ;
                           rec_modified WITH .t.
                ENDIF
           ELSE
                SELECT med_proc
                LOCATE FOR med_proc.code = lv_enc_tmp.proc_code
                IF !FOUND()
                     SELECT lv_enc_tmp
                     Replace lv_enc_tmp.proc_code WITH '', ;
                             lv_enc_tmp.rec_modified WITH .t.
                Endif       
           ENDIF
          
           SELECT lv_enc_tmp
            
   CASE nAction = 3 &&Modifier code from grid Encounters
           oApp.Pop_up("CODINGW1","CMODICODE",cCode)
                       
           IF !EMPTY(cCode)
                SELECT lv_enc_tmp
                IF ALLTRIM(lv_enc_tmp.modifier) <> ALLTRIM(cCode)
                   Replace lv_enc_tmp.modifier WITH cCode, ;
                           rec_modified WITH .t.
                           
                   nEnc_sc_id = lv_enc_tmp.Enc_sc_id
                   nEnc_id = lv_enc_tmp.Enc_id
                            
                   Select  lv_serv_tmp
                   Replace lv_serv_tmp.modifier WITH cCode, ;
                           rec_modified WITH .t. ;
                                        FOR lv_serv_tmp.Enc_sc_id =nEnc_sc_id AND ;
                                            lv_serv_tmp.enc_id = nEnc_id
                ENDIF
           ELSE
                SELECT modifier
                LOCATE FOR modifier.code = lv_enc_tmp.modifier
                IF !FOUND()
                     SELECT lv_enc_tmp
                     Replace lv_enc_tmp.modifier WITH '', ;
                                             rec_modified WITH .t.
                                 
                     nEnc_sc_id = lv_enc_tmp.Enc_sc_id
                     nEnc_id = lv_enc_tmp.Enc_id
                               
                     Select  lv_serv_tmp
                     Replace lv_serv_tmp.modifier WITH '', ;
                             rec_modified WITH .t. ;
                                        FOR lv_serv_tmp.Enc_sc_id =nEnc_sc_id AND ;
                                                lv_serv_tmp.enc_id = nEnc_id  
               Endif                                          
          ENDIF
          
          SELECT lv_enc_tmp
          
   CASE nAction = 4 &&Place of service from grid Encounters
           oApp.Pop_up("CODINGW1","CLOCATION",cCode)
                       
           IF !EMPTY(cCode)
                SELECT lv_enc_tmp
                IF ALLTRIM(lv_enc_tmp.location) <> ALLTRIM(cCode)
                   Replace lv_enc_tmp.location WITH cCode, ;
                           lv_enc_tmp.rec_modified WITH .t.
                           
                   nEnc_sc_id = lv_enc_tmp.Enc_sc_id
                   nEnc_id = lv_enc_tmp.Enc_id
                            
                   Select  lv_serv_tmp
                   Replace lv_serv_tmp.location WITH cCode, ;
                           lv_serv_tmp.rec_modified WITH .t. ;
                                        FOR lv_serv_tmp.Enc_sc_id =nEnc_sc_id AND ;
                                            lv_serv_tmp.enc_id = nEnc_id
                ENDIF
           ELSE
                SELECT med_plac
                LOCATE FOR med_plac.code = lv_enc_tmp.location
                IF !FOUND()
                     SELECT lv_enc_tmp
                     Replace lv_enc_tmp.location WITH '', ;
                             lv_enc_tmp.rec_modified WITH .f.
                                 
                     nEnc_sc_id = lv_enc_tmp.Enc_sc_id
                     nEnc_id = lv_enc_tmp.Enc_id
                               
                     Select  lv_serv_tmp
                     Replace lv_serv_tmp.location WITH '', ;
                             lv_serv_tmp.rec_modified WITH .t. ;
                                        FOR lv_serv_tmp.Enc_sc_id =nEnc_sc_id AND ;
                                                lv_serv_tmp.enc_id = nEnc_id  
               Endif                                          
          ENDIF
          SELECT lv_enc_tmp  
          
******************* Service Grid     
   CASE nAction = 5 &&Procedure code from grid Service
           oApp.Pop_up("CODINGW1","CPROCC",cCode)   
           IF !EMPTY(cCode)
                SELECT lv_serv_tmp
                IF ALLTRIM(lv_serv_tmp.proc_code) <> ALLTRIM(cCode)
                   Replace lv_serv_tmp.proc_code WITH cCode, ;
                           lv_serv_tmp.rec_modified WITH .t.
                ENDIF
           ELSE
                SELECT med_proc
                LOCATE FOR med_proc.code = lv_serv_tmp.proc_code
                IF !FOUND()
                     SELECT lv_serv_tmp
                     Replace lv_serv_tmp.proc_code WITH '', ;
                             lv_serv_tmp.rec_modified WITH .t.
                Endif       
           ENDIF      
           SELECT lv_serv_tmp 
     
      CASE nAction = 6   && Rate Code from grid Service       
           oApp.Pop_up("CODINGW1","CRATEC",cCode)
           
           IF !EMPTY(cCode)
                SELECT lv_serv_tmp
                IF ALLTRIM(lv_serv_tmp.rate_code) <> ALLTRIM(cCode)
                   Select  lv_serv_tmp
                   Replace lv_serv_tmp.rate_code WITH cCode, ;
                           rec_modified WITH .t. 
                ENDIF
           ELSE
                SELECT ratecur
                LOCATE FOR ratecur.rate_code = lv_serv_tmp.rate_code
                IF !FOUND()
                     Select  lv_serv_tmp
                     Replace lv_serv_tmp.rate_code WITH '', ;
                             rec_modified WITH .t.
               Endif       
           ENDIF
            
           SELECT lv_serv_tmp          
   
   CASE nAction = 7 &&Modifier code from grid Service
           oApp.Pop_up("CODINGW1","CMODICODE",cCode)
                       
           IF !EMPTY(cCode)
                SELECT lv_serv_tmp
                IF ALLTRIM(lv_serv_tmp.modifier) <> ALLTRIM(cCode)
                   Replace lv_serv_tmp.modifier WITH cCode, ;
                           lv_serv_tmp.rec_modified WITH .t.
                           
                ENDIF
           ELSE
                SELECT modifier
                LOCATE FOR modifier.code = lv_serv_tmp.modifier
                IF !FOUND()
                     SELECT lv_serv_tmp
                     Replace lv_serv_tmp.modifier WITH '', ;
                             lv_serv_tmp.rec_modified WITH .t.
                Endif                                          
          ENDIF
          SELECT lv_serv_tmp 
          
   CASE nAction = 8 &&Place of service from grid Service
           oApp.Pop_up("CODINGW1","CLOCATION",cCode)
                       
           IF !EMPTY(cCode)
                SELECT lv_serv_tmp
                IF ALLTRIM(lv_serv_tmp.location) <> ALLTRIM(cCode)
                   Replace lv_serv_tmp.location WITH cCode, ;
                           rec_modified WITH .t.
                ENDIF
           ELSE
                SELECT med_plac
                LOCATE FOR med_plac.code = lv_serv_tmp.location
                IF !FOUND()
                    Select  lv_serv_tmp
                    Replace lv_serv_tmp.location WITH '', ;
                            rec_modified WITH .t.
               Endif                                          
          ENDIF    
          SELECT lv_serv_tmp
                              
ENDCASE
   
Return

