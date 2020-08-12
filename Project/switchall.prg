Parameters lSaveNote
 
*!* Switch cleints
*!* If the reccount is an even number proceed ok otherwise skipt the first record.

If Empty(Nvl(lSaveNote,''))
   lSaveNote=.f.
EndIf

Close Tables
Use client In 0
Use ai_clien In 0
Use insstat In 0
Use address In 0
Use claim_hd In 0
Use agency In 0
use ai_enc In 0
Use ai_serv In 0
Use system In 0

Select client
Set Deleted Off
Replace All cinn with ''

Go top
*****Replace all last_name with Strtran(Alltrim(last_name),'12',Right(first_name,2))

Scan
   m.last_name=Upper(Alltrim(last_name))
   m.first_name=Upper(Alltrim(first_name))
   m.ssn=Alltrim(ssn)
   m.oldcinn=Alltrim(cinn)
   m.cinn=Alltrim(cinn)
   m.dob=dob
   m.phhome='2129999900'
   m.phwork='7189999900'
   
   Do Case
      Case Between(Len(Alltrim(last_name)),2,3)
*        m.first_name='SHORTNAME'
      Case Len(Alltrim(last_name)) > 3
         m.last_name=Substr(last_name,1,Len(Alltrim(last_name))-2)+Right(Alltrim(last_name),1)+Left(Alltrim(last_name),1)
         m.last_name=Substr(m.last_name,1,Len(Alltrim(m.last_name))-2)+Right(Alltrim(m.last_name),1)+Left(Alltrim(m.last_name),1)
   EndCase 

   m.first_name=Iif(sex='M',"Christopher","Madeline")

   =Rand(-1)
   If !Empty(ssn)
      m.ssn=''
      For i = 1 To 9
          m.ssn=m.ssn+Str(Round(Rand()*10,0),1,0)
          m.ssn=Strtran(m.ssn,'*','9')
      EndFor 
   EndIf
   
   =Rand(-1)
   If !Empty(cinn)
      m.oldcinn=Alltrim(cinn)
      m.cinn=Alltrim(cinn)
      
      For i = 1 To Len(Alltrim(cinn))
         If IsDigit(Substr(m.cinn,i,1))
            m.digit=Str(Round(Rand()*10,0),1,0)
            If m.digit <> Substr(m.cinn,i,1)
               m.cinn=Stuff(m.cinn,i,1,digit)
               Update insstat Set pol_num=m.cinn Where Alltrim(pol_num)=m.oldcinn
               Exit
            Endif
         EndIf
      EndFor 
   EndIf 
   
   If !Empty(dob)
      If Day(dob) > 29
         m.dob=dob-1
      Else
         m.dob=dob+1
      EndIf
   EndIf 

   Replace last_name With m.last_name,;
           first_name With m.first_name,;
           ssn With m.ssn,;
           cinn With m.cinn,;
           dob With m.dob,; 
           phhome With m.phhome,;
           phwork With m.phwork
EndScan
Go Top

Do While !Eof()
   Replace last_name with Upper(last_name),;
           first_name With Upper(first_name)
   Skip
   Replace last_name with Proper(last_name),;
           first_name With Proper(first_name)
   Skip
EndDo

Select insstat
Go Top
Replace all pol_num with insstat_id

*!*   Scan
*!*      =Rand(-1)
*!*      If !Empty(pol_num)
*!*         nLen=Len(Alltrim(pol_num))
*!*         cNewPolNum=''
*!*         For i = 1 To nLen
*!*            =Rand(-1)   
*!*            m.digit=Str(Round(Rand()*10,0),1,0)
*!*            cNewPolNum=cNewPolNum+m.digit
*!*         EndFor 
*!*         Replace pol_num with 'PO'+cNewPolNum
*!*      EndIf 
*!*   EndScan 

Select ai_clien
Replace id_no With Padr(alltrim(Transform(Recno(),'99999999')),18,'0')+'ID' All

If lSaveNote=(.f.)
   Select ai_enc
   Replace enc_note With '' All

   Select ai_serv
   Replace servnote With '' All
EndIf 

Select client
Go Top
Replace ;
     ssn With '',;
     cinn With '',;
     phhome With '',;
     phwork With '';
For Deleted()=(.t.)

Select address
Update address Set street1='9999 SOME STREET IN A CITY XXX',;
                   street2='PRIVATE BOX:'+addr_id

Update claim_hd;
 From insstat;
   Set claim_hd.cinn=insstat.pol_num;
Where claim_hd.insstat_id=insstat.insstat_id

Select agency
Replace descript1 With 'Defran Systems, Inc.',;
        descript2 With 'NYSDOH - AI',;
        street1 With '5 E.16th Street',;
        street2 With '6th Floor',;
        city With 'New York',;
        st with 'NY',;
        zip With '10003',;
        contact With 'Peter Baldino Jr.',;
        title With 'Lead',;
        c_phone With '6462301059',;
        c_fax With '2127278639',;
        phone With '6462301059', ;
        fax With '2127278639',;
        princzip With '10003'

Select system
Replace licensee With 'Defran Systems, Inc.',;
        user_name With 'Peter Baldino Jr.',;
        user_phone With'6462301059'

oApp=CreateObject('custom')
=AddProperty(oApp,'gnEncryption_source',1)
osecurity=NewObject('security','I:\ursver6\libs\security.vcx')

Use staff
Go Top

Replace last With 'LastNm_'+Alltrim(Transform(Recno(),'9999')), ;
        first With 'FirstNm_'+Alltrim(Transform(Recno(),'9999')),;
        last_client_list With '', ;
        last_group_list With '', ;
        last_client_id With '' All
Go Top

Scan For !Empty(Login_name) And staff_id <> 'AAAAA'
   cLoginName='STAFF_'+Alltrim(Str(Recno()))
   cPw=osecurity.encrypt(Lower(cLoginName))
   Replace Login_name With cLoginName, password With cPW, last With 'Ln_'+cLoginName, first With 'Fn_'+cLoginName
EndScan

Go top
Locate for staff_id='AAAAA'
If Found()
 Replace password With osecurity.encrypt('defran')
EndIf

Use program
Scan
   Replace descript WIth 'Program_'+Alltrim(Str(Recno()))
EndScan

Use ref_srce
Scan
 Replace name with 'Site_'+Alltrim(Str(Recno())), addr1 with 'Street1'++Alltrim(Str(Recno())), addr2 With 'Street2'+Alltrim(Str(Recno())), telephone With '9999999999' 

EndScan

Use site
Replace all contact with '', title with ''
Replace All descript1 WIth 'Site_'+Alltrim(Str(Recno())), Street1 with 'Street_'+Alltrim(Transform(Recno(),'9999')), phone with '9999999999', phone2 with '9999999999'

Use group
Replace descript with Iif(Left(descript,1)='Z','Z ','')+'Group_'+Alltrim(Transform(Recno(),'9999')) All

Use epi_data
Replace fname With '',lname With '', address With '', telephone With '', ssn With '', medicaidno With '' All

Use epi_data
Update epi_data From client Set epi_data.fname=client.first_name, epi_data.lname=client.last_name, epi_data.ssn=client.ssn where epi_data.client_id=client.client_id
Update epi_data From insstat Set epi_data.medicaidno=insstat.pol_num where epi_data.client_id=client.client_id