Parameters lPrev,;     && Preview
           aSelvar1,;  && select parameters from selection list
           nOrder,;    && order by number
           nGroup,;    && report selection number
           cTitle,;    && report selection description
           Date_from,; && from date
           Date_to,;   && to date
           Crit,;      && name of param
           lnStat,;    && selection(Output) page 2
           cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)

cTitle = Left(cTitle, Len(cTitle)-1)

cAgency_ID = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CAGENCY_ID"
      cAgency_id = aSelvar2(i, 2)
   Endif
EndFor

cDate=Date()
cTime=Time()

If Used('agencycur')
   Use in agencycur
EndIf
   
SELECT ;
	Agency AS agency_id, ;
	ALLTRIM(descript1) + ' ' + ALLTRIM(descript2) AS AgName, ;
   ALLTRIM(street1) + ' ' + ALLTRIM(street2) + chr(13) + ;
	ALLTRIM(city) + "," + st + ' ' + zip AS AgAddr, ;
	'('+ LEFT(phone,3) + ') ' + SUBSTR(phone,4,3) + '-' + RIGHT(phone,4)	AS AgPhone, ;
	ALLTRIM(contact) AS AgContact, ;
	ALLTRIM(title) AS AgTitle, ;
	'('+ LEFT(fax,3) + ') ' + SUBSTR(fax,4,3) + '-' + RIGHT(fax,4) AS AgFax, ;
   '('+ LEFT(c_phone,3) + ') ' + SUBSTR(c_phone,4,3) + '-' + RIGHT(c_phone,4) AS ContPhone, ;
   '('+ LEFT(c_fax,3) + ') ' + SUBSTR(c_fax,4,3) + '-' + RIGHT(c_fax,4) AS ContFax, ;
   c_email AS ContEmail, ;
   spag_id, ;
   fed_id, ;
   duns_id, ;
   aar_id;
FROM ;
	agency ;
WHERE agency=cAgency_id ;	
INTO CURSOR	agencycur
INDEX ON agency_id TAG agency_id
USE IN agency

CREATE CURSOR AgenSite (agency_id C(5), siteinfo M)
=OPENFILE('site','agency_id')
m.siteinfo=''
m.holdagency=site.agency_id
m.count=0
* create list of sites

Scan  
	If m.HoldAgency <> site.Agency_Id
		INSERT INTO AgenSite VALUES (m.HoldAgency, m.SiteInfo)
		m.HoldAgency = Agency_Id
		m.count = 0
	EndIf
	m.count=m.count + 1
	m.SiteInfo=m.SiteInfo + ;
            Iif(m.count>1, Chr(13), '')+site.site_id+' '+site.descript1+' '+site.descript2+Space(15)+site.ctsite+'       '+site.ctfacility
EndScan 

* final site here
Insert Into AgenSite VALUES (m.HoldAgency, m.SiteInfo)

Use In site

=OPENFILE('Eligtype','code')
=OPENFILE('FundType','code') 	
      
SELE AgenSite
INDEX ON agency_id TAG agency_id

* create detail of program and service info
SELECT 	;
	program.agency_id,;
	program.descript AS ProgDesc,;
	program.prog_id,;
	program.enr_req,;
	program.ctp_elig,;
	program.aar_report,;
	program.active,;
	prog2sc.serv_cat,;
	serv_cat.descript AS ServDesc,;
	program.elig_type,;
	program.fund_type,;
   agencycur.AgName,;
   agencycur.AgAddr,;
   AgencyCur.spag_id,;
   AgencyCur.fed_id,;
   AgencyCur.Aar_id,;
   AgencyCur.AgPhone,;
   AgencyCur.AgContact,;
   AgencyCur.AgTitle,;
   AgencyCur.AgFax,;
   AgencyCur.ContEmail,;
   AgencyCur.duns_id,;
   AgencyCur.ContPhone,;
   AgencyCur.ContFax,;
   AgenSite.SiteInfo,;
   Eligtype.descript as elig_des,;
   FundType.descript as fund_des,;
   cTitle as lcTitle,;
   Crit as Crit,;
   cDate as cDate,;
   cTime as cTime;
From;
	agencycur ;
	inner join program on  ;
         program.agency_id = agencycur.agency_id ;
   inner join  prog2sc on ;     
	         program.prog_id   = prog2sc.prog_id ;
   inner join serv_cat on ;         
	      prog2sc.serv_cat  = serv_cat.code ;
   inner join AgenSite on ;
         agencycur.agency_id =AgenSite.agency_id ;
   left outer join  Eligtype on ;
         program.elig_type = Eligtype.code ;
   left outer join FundType on ;     
         program.fund_type = FundType.code ;
ORDER BY ;
	program.descript, ;
   program.ctp_elig, ; 
   program.aar_report, ;
   serv_cat.descript ;
INTO CURSOR ;
	rep

oApp.msg2user("OFF")
Select Rep
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   gcRptName = 'rpt_agency'   
   Do Case
      CASE lPrev = .f.
         Report Form rpt_agency  To Printer Prompt Noconsole NODIALOG 
         
      CASE lPrev = .t.     &&Preview
         oApp.rpt_print(5, .t., 1, 'rpt_agency', 1, 2)
   EndCase 
EndIf

* close dbfs 
Use In program
Use In prog2sc
Use In serv_cat

Use in Eligtype
Use in FundType
Return 