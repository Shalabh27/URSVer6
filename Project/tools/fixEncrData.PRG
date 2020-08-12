Set DELETED off

Open Database E:\AIRSLastGood\data\urs.dbc
Close Tables

Use address In 0
Select addr_id, street1, home_ph, work_ph From address Where !Empty(addr_id) Into Cursor _curAddress ReadWrite Order By 1
Use In address

Use insstat In 0
Select insstat_id, pol_num From insstat Where !Empty(insstat_id) Into Cursor _curInsstat ReadWrite Order By 1 
Use In insstat

Use client In 0
Select client_id, last_name, first_name, ssn, ssi_no, cinn, phhome, phwork From Client Where !Empty(client_id) Into Cursor _curClient Readwrite Order by 1 
Use In client

Use claim_hd In 0
Select Invoice, cinn From Claim_hd Where !Empty(invoice) order by 1 Into cursor _cueClaimHD ReadWrite
Use in claim_hd

Use imp_271 In 0
Select tc_id, pol_num, last_name, first_name From imp_271 Where !Empty(tc_id) Order by 1 Into Cursor _imp271 Readwrite 
Use In imp_271

Close Databases

Open Database E:\AIRS2Fix\data\urs.dbc
Select 0
Use address Order Tag addr_id

Update Address ;
From _curAddress ;
Set street1=_curAddress.street1, ;
    home_ph=_curAddress.home_ph, ;
    work_ph=_curAddress.work_ph ;
Where _curAddress.addr_id=address.addr_id And ;
!Empty(address.addr_id)

Select 0
Use insstat Order Tag insstat_id

Update insstat ;
From _curInsstat;
set pol_num=_curInsstat.pol_num;
Where insstat.insstat_id=_curInsstat.insstat_id And;
      !Empty(insstat.insstat_id)
     
Select 0
Use client Order tag client_id
Update client;
From _curClient;
Set last_name=_curClient.last_name,;
    first_name=_curClient.first_name,;
    ssn=_curClient.ssn, ;
    ssi_no=_curClient.ssi_no, ;
    cinn=_curClient.cinn, ;
    phhome=_curClient.phhome, ;
    phwork=_curClient.phwork;
Where client.client_id=_curClient.client_id

Select 0
Use claim_hd Order tag invoice
Update claim_hd;
From _cueClaimHD;
Set cinn=_cueClaimHD.cinn;
Where claim_hd.invoice=_cueClaimHD.invoice And;
      !Empty(_cueClaimHD.invoice)

***********************************************
***********************************************

Select client
Go Top
Set Filter To Len(Alltrim(Left(last_name,2)))=2 And ;
              Substr(last_name,2,1)<>"'" And ;
              (!Between(Upper(Left(last_name,1)),'A','Z') OR !Between(Upper(Substr(last_name,2,1)),'A','Z'))

Scan
   mString = Alltrim(last_name)
   mNewString=decrypt2(mString)
   Replace last_name with mNewString

EndScan 
*

Go Top
Set Filter To Len(Alltrim(Left(first_name,2)))=2 And ;
              Substr(first_name,2,1)<>"'" And ;
              (!Between(Upper(Left(first_name,1)),'A','Z') OR !Between(Upper(Substr(first_name,2,1)),'A','Z'))


Scan
   mString = Alltrim(first_name)
   mNewString=decrypt2(mString)
   Replace first_name with mNewString

EndScan 
* ssn, ssi_no, cinn, phhome, phwork

Go Top
Set Filter To !Empty(ssn) And ;
              Len(Alltrim(Left(ssn,3)))=3 And ;
              Substr(ssn,2,1)<>"'" And ;
              (!Between(Upper(Left(ssn,1)),'0','9') OR !Between(Upper(Substr(ssn,2,1)),'0','9'))
Go Top

Scan
   mString = Alltrim(ssn)
   mNewString=decrypt2(mString)
   Replace ssn with mNewString

EndScan 
Set Filter To

Go Top
Set Filter To !Empty(phhome) And ;
              Len(Alltrim(Left(phhome,3)))=3 And ;
              Substr(phhome,2,1)<>"'" And ;
              (!Between(Upper(Left(phhome,1)),'0','9') OR !Between(Upper(Substr(phhome,2,1)),'0','9'))
Go Top

Scan
   mString = Alltrim(phhome)
   mNewString=decrypt2(mString)
   Replace phhome with mNewString

EndScan 

Set Filter To

Go Top
Set Filter To !Empty(phwork) And ;
              Len(Alltrim(Left(phwork,3)))=3 And ;
              Substr(phwork,2,1)<>"'" And ;
              (!Between(Upper(Left(phwork,1)),'0','9') OR !Between(Upper(Substr(phwork,2,1)),'0','9'))
Go Top

Scan
   mString = Alltrim(phwork)
   mNewString=decrypt2(mString)
   Replace phwork with mNewString

EndScan 
Set Filter To 
Go Top
Replace all cinn with ''
Go Top

Select address
Set Filter To !Empty(street1) And (!Between(Asc(Left(street1,1)),32,122) Or !Between(Asc(Substr(street1,2,1)),32,122))
Go Top

Scan
   mString = Alltrim(street1)
   mNewString=decrypt2(mString)
   Replace street1 with mNewString

EndScan 
Set Filter To 
*

Select insstat
Set Filter To !Empty(pol_num) And (!Between(Asc(Left(pol_num,1)),32,122) Or !Between(Asc(Substr(pol_num,2,1)),32,122))
Go Top

Scan
   mString = Alltrim(pol_num)
   mNewString=decrypt2(mString)
   Replace pol_num with mNewString

EndScan 
Set Filter To
*************************
*************************
*************************
Function decrypt2
Parameter clstring

Local ccReturnValue
ccReturnValue=''


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

Return ccReturnValue