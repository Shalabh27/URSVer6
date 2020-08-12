PARAMETER dStartDate, dEndDate, nScope, lPreview, oExtrForm

*** jss, 11/27/07: Make changes to reflect 2007 specs: Title1,2,3,4 now called Part A,B,C,D (Q10), RW Care Act now RW HIV/AIDS Program, etc.

* Makes CARE Act Data Report (Section 1-5, Q1-55, (Q35-separ. program))
otimer.Interval=0

PRIVATE gchelp
gchelp='CADR Reporting Screen'
 
m.sect2posin=0
m.sect61posi=0
m.sect2all=0
m.sect62all=0

=clos_em()

m.Cdate = Date()
m.Ctime = Time()
m.Start_dt = dStartDate
m.End_dt = dEndDate

Select cadr.* ;
From ;
	cadr, Agency;
Where ;
	Agency.agency = cadr.agency ;
	AND cadr.start_dt = dStartDate  ;
	AND cadr.end_dt = dEndDate ;
Into Cursor ;
	t_cadr

* jss, 11/28/07, add page_ej L, used to force page eject when .t.
m.page_ej=9
*Create Cursor cadr_tmp (agency C(05), section M, part C(50), info N(2), group M, ;
*                        cDate D, cTime C(10), Start_dt D, End_dt D)
Create Cursor cadr_tmp (agency C(05), section M, part C(50), page_ej N(1), info N(2), group M, ;
                        cDate D, cTime C(10), Start_dt D, End_dt D)

If lpreview
    =prep_cadr()
Else
    oApp.msg2user('OFF')
    Do cadrextr With dStartDate, dEndDate, oExtrForm
EndIf

otimer.Interval=oapp.gnsystimeout
   
Return


************************
Procedure prep_cadr                       

* StrtoFile('Sect1: '+Ttoc(Datetime()),'C:\4Peter\cadr_stats.txt',1)
=sect1()

* StrtoFile('Sect23: '+Ttoc(Datetime())+Chr(13),'C:\4Peter\cadr_stats.txt',1)
=sect23prep()

* StrtoFile('Sect2: '+Ttoc(Datetime())+Chr(13),'C:\4Peter\cadr_stats.txt',1)
=sect2()

* StrtoFile('Sect3: '+Ttoc(Datetime())+Chr(13),'C:\4Peter\cadr_stats.txt',1)
=sect3()

* StrtoFile('Sect4: '+Ttoc(Datetime())+Chr(13),'C:\4Peter\cadr_stats.txt',1)
=sect4()

* StrtoFile('Sect5: '+Ttoc(Datetime())+Chr(13),'C:\4Peter\cadr_stats.txt',1)
=sect5()

* StrtoFile('Sect6: '+Ttoc(Datetime())+Chr(13),'C:\4Peter\cadr_stats.txt',1)
=sect6()

* StrtoFile('Ended: '+Ttoc(Datetime()),'C:\4Peter\cadr_stats.txt',1)

gcRptName = 'rpt_cadr'
gcRptAlias = 'cadr_tmp'

SELECT cadr_tmp
Go top

IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   oApp.msg2user('OFF')
   oApp.rpt_print(5, .t., 1, 'rpt_cadr', 1, 2)
Endif

Return
***************
PROCEDURE sect1
***************
*** Section 1
Select cadr_tmp
=OpenFile("ai_serv")
=OpenFile("ai_enc",)
=OpenFile("cadrserv","cadrs_id")
=OpenFile("ownstat","code")
=OpenFile("provtype","code")
=OpenFile("agency","agency")

GO TOP
If !Eof()
	m.agency = agency.agency
	m.section = Space(40) + "SECTION 1.  SERVICE PROVIDER INFORMATION"
	m.part    = "Part 1.1. Provider and Agency Contact Information"
	m.group   = "1.   Provider Name: " + Space(28) + agency.descript1

	m.info = 1
	Insert Into cadr_tmp From Memvar

	If !Empty(agency.descript2)
		m.group   = Space(48) + agency.descript2
		Insert Into cadr_tmp From Memvar
	Endif	
	
	m.group   = "2.   Provider Address: " + Space(15) + "Street: " + Space(2) + ;
               Iif(Isnull(agency.street1), '', agency.street1)
	m.info = 2
	Insert Into cadr_tmp From Memvar
	
	If !Empty(agency.street2)
		m.group = Space(48) + Iif(Isnull(agency.street2), '', agency.street2) 
		Insert Into cadr_tmp From Memvar
	Endif
	
	m.group = Space(28) + "City, State, Zip: " + Space(2) + Rtrim(agency.city) + ;
								Iif(!Empty(agency.st), ", ", "") + agency.st + ;
								Iif(!Empty(agency.zip), ", ", "") + ;
								Iif(Empty(agency.zip), Space(9), Transform(agency.zip, "@R 99999-9999"))
	Insert Into cadr_tmp From Memvar

	m.group = Space(31) + "Taxpayer Id #: " + Space(2) + Iif(Empty(agency.fed_id), Space(10), Transform(agency.fed_id, "@R 99-9999999"))
	Insert Into cadr_tmp From Memvar
		
	m.group   = "3.   Contact Information: " + Space(12) + "  Name: " + Space(2) + ;
               Iif(Isnull(agency.contact), '', agency.contact)
	m.info =3
	Insert Into cadr_tmp From Memvar
	
	m.group = Space(39) + "Title: " + Space(2) + Iif(Isnull(agency.title), '', agency.title)
	Insert Into cadr_tmp From Memvar
		
	m.group = Space(37) + "Phone #: " + Space(2) + Iif(Empty(agency.c_phone),Space(14),Transform(agency.c_phone,"@R (999) 999-9999"))
	Insert Into cadr_tmp From Memvar
		
	m.group = Space(39) + "Fax #: " + Space(2) + Iif(Empty(agency.c_fax),Space(14),Transform(agency.c_fax,"@R (999) 999-9999"))
	Insert Into cadr_tmp From Memvar
	
	m.group = Space(39) + "Email: " + Space(2) + Iif(Isnull(agency.c_email), '', Rtrim(agency.c_email))
	Insert Into cadr_tmp From Memvar
		
	If Seek(agency.prov_typ, "provtype")
			m.pr_desc = provtype.descript
	Else
			m.pr_desc = " "
	Endif

	m.faithbased='   '
	If Seek(agency.own_stat, "ownstat")
			DO CASE
			CASE agency.own_stat='04'
				m.own_desc='Private, nonprofit'
				m.faithbased='No '
			CASE agency.own_stat='07'
				m.own_desc='Private, nonprofit'
				m.faithbased='Yes'
			OTHERWISE
				m.own_desc = ownstat.descript
			ENDCASE	
	Else
			m.own_desc = ""
	EndIf
* define memvars for extract's section 1
	m.prvid      = agency.aar_id
	m.prvname1   = TRIM(agency.descript1)+' '+TRIM(agency.descript2)
	m.prvaddr1   = TRIM(agency.street1)  +' '+TRIM(agency.street2)
	m.prvcity    = TRIM(agency.city)
	m.state      = agency.st
	m.zip        = LEFT(agency.zip,5)
	m.zip4       = RIGHT(agency.zip,4)
	m.contname   = TRIM(agency.contact)
	m.conttitle  = TRIM(agency.title)
	m.phone      = agency.c_phone
	m.fax        = agency.c_fax
	m.email      = TRIM(agency.c_email)
	m.compname   = TRIM(t_cadr.name)
	m.compphone  = t_cadr.phone
	m.compemail  = t_cadr.e_mail
	m.prystart   = RIGHT(DTOS(dStartDate),4) + LEFT(DTOS(dStartDate),4)
	m.pryend     = RIGHT(DTOS(dEndDate),4) + LEFT(DTOS(dEndDate),4)
	m.scope      = nScope
	m.taxid      = agency.fed_id
	m.zipmain    = agency.princzip
	m.numbsite   = TRAN(agency.totsites,'999')
	m.paidstaf   = TRAN(t_cadr.an_staff,'999.9')
	m.volstaf    = TRAN(t_cadr.an_volun,'999.9')
	m.section_33 = IIF(t_cadr.pubhealth = 1, "Yes", IIF(t_cadr.pubhealth = 2, "No", IIF(t_cadr.pubhealth = 3, "Don't Know/Unsure","")))
	m.maifunding = IIF(t_cadr.maifunding= 1, "Yes", IIF(t_cadr.maifunding = 2, "No", IIF(t_cadr.maifunding = 3, "Don't Know/Unsure","")))
	m.title1_fun = IIF(t_cadr.title1,'1','0')
	m.titl1code1 = IIF(t_cadr.title1 AND !EMPTY(t_cadr.titl1code1),t_cadr.titl1code1,SPACE(2))
	m.titl1name1 = IIF(t_cadr.title1 AND !EMPTY(t_cadr.titl1name1),t_cadr.titl1name1,SPACE(50)) 
	m.titl1code2 = IIF(t_cadr.title1 AND !EMPTY(t_cadr.titl1code2),t_cadr.titl1code2,SPACE(2))
	m.titl1name2 = IIF(t_cadr.title1 AND !EMPTY(t_cadr.titl1name2),t_cadr.titl1name2,SPACE(50)) 
	m.titl1name3 = IIF(t_cadr.title1 AND !EMPTY(t_cadr.titl1name3),t_cadr.titl1name3,SPACE(50)) 
	m.title2_fun = IIF(t_cadr.title2,'1','0')
	m.titl2code1 = IIF(t_cadr.title2 AND !EMPTY(t_cadr.titl2code1),t_cadr.titl2code1,SPACE(2))
	m.titl2name1 = IIF(t_cadr.title2 AND !EMPTY(t_cadr.titl2name1),t_cadr.titl2name1,SPACE(50)) 
	m.titl2name2 = IIF(t_cadr.title2 AND !EMPTY(t_cadr.titl2name2),t_cadr.titl2name2,SPACE(50)) 
	m.titl2name3 = IIF(t_cadr.title2 AND !EMPTY(t_cadr.titl2name3),t_cadr.titl2name3,SPACE(50)) 
	m.title3_fun = IIF(t_cadr.title3,'1','0')
	m.titl3name1 = IIF(t_cadr.title3 AND !EMPTY(t_cadr.titl3name1),t_cadr.titl3name1,SPACE(50)) 
	m.titl3name2 = IIF(t_cadr.title3 AND !EMPTY(t_cadr.titl3name2),t_cadr.titl3name2,SPACE(50)) 
	m.titl3name3 = IIF(t_cadr.title3 AND !EMPTY(t_cadr.titl3name3),t_cadr.titl3name3,SPACE(50)) 
	m.title4_fun = IIF(t_cadr.title4,'1','0')
	m.titl4name1 = IIF(t_cadr.title4 AND !EMPTY(t_cadr.titl4name1),t_cadr.titl4name1,SPACE(50)) 
	m.titl4name2 = IIF(t_cadr.title4 AND !EMPTY(t_cadr.titl4name2),t_cadr.titl4name2,SPACE(50)) 
	m.titl4name3 = IIF(t_cadr.title4 AND !EMPTY(t_cadr.titl4name3),t_cadr.titl4name3,SPACE(50)) 
	m.title4_ado = IIF(t_cadr.title4ad,'1','0')
	m.titadname1 = IIF(t_cadr.title4ad AND !EMPTY(t_cadr.titadname1),t_cadr.titadname1,SPACE(50)) 
	m.titadname2 = IIF(t_cadr.title4ad AND !EMPTY(t_cadr.titadname2),t_cadr.titadname2,SPACE(50)) 
	m.titadname3 = IIF(t_cadr.title4ad AND !EMPTY(t_cadr.titadname3),t_cadr.titadname3,SPACE(50)) 
	m.plan_eval  = IIF(t_cadr.planning=1,'1','0')
	m.administra = IIF(t_cadr.admin=1,'1','0')
	m.fiscal     = IIF(t_cadr.fiscal=1,'1','0')
	m.technical  = IIF(t_cadr.technic=1,'1','0')
	m.capacity   = IIF(t_cadr.capacity=1,'1','0')
	m.quality    = IIF(t_cadr.quality=1,'1','0')
	m.onlyserv   = IIF(t_cadr.onlyserv=1,'1','0')
	m.migrant    = IIF(t_cadr.migrant,'1','0')
	m.rural      = IIF(t_cadr.rural,'1','0')
	m.children   = IIF(t_cadr.children,'1','0')
	m.minorities = IIF(t_cadr.race_eth,'1','0')
	m.homeless   = IIF(t_cadr.homeless,'1','0')
	m.women      = IIF(t_cadr.women,'1','0')
	m.gay_youth  = IIF(t_cadr.l_youth,'1','0')
	m.gay_adults = IIF(t_cadr.l_adults,'1','0')
	m.incarcerat = IIF(t_cadr.incarper,'1','0')
	m.adolescent = IIF(t_cadr.all_adol,'1','0')
	m.runaway    = IIF(t_cadr.runaway,'1','0')
	m.injection  = IIF(t_cadr.inject,'1','0')
	m.non_inject = IIF(t_cadr.n_inject,'1','0')
	m.parolees   = IIF(t_cadr.parolees,'1','0')
	m.other      = IIF(t_cadr.other,'1','0')
	m.otherspeci = t_cadr.otherspec
   m.title1recd = TRAN(t_cadr.act1_amt,'999999999')
   m.title2recd = TRAN(t_cadr.act2_amt,'999999999')
   m.title3recd = TRAN(t_cadr.act3_amt,'999999999')
   m.title4recd = TRAN(t_cadr.act4_amt,'999999999')
   m.mai1recd   = TRAN(t_cadr.mai1_amt,'999999999')
   m.mai2recd   = TRAN(t_cadr.mai2_amt,'999999999')
   m.mai3recd   = TRAN(t_cadr.mai3_amt,'999999999')
   m.mai4recd   = TRAN(t_cadr.mai4_amt,'999999999')
   m.oralrecd   = TRAN(t_cadr.totalexp,'999999999')
	m.am_board   = IIF(agency.mg_board,'1','0')
	m.am_staff   = IIF(agency.mg_staff,'1','0')
	m.am_clinic  = IIF(agency.mg_solo,'1','0')
	m.am_served  = IIF(agency.mg_trad,'1','0')
	m.am_other   = IIF(agency.mg_other,'1','0')
	STORE 'No' TO  m.c12, m.c14
	STORE ' '  TO  m.c13, m.title3prov, m.title4prov, m.apa_prov, m.hip_prov, ;
						m.fromdate, m.thrudate, m.regcode
	m.prvtype=agency.prov_typ

	STORE agency.own_stat TO m.owner, m.agtype 

	m.RecId= LEFT(DTOS(dEndDate),6) + m.PrvID

	Store " " to m.a_d1, m.a_d2, m.a_d3, m.a_d4, m.a_d5 
	
	If agency.mg_board
		m.a_d1 = "Minority group members > 50% of the board"
	Endif
	
	If agency.mg_staff
		m.a_d2 = "Minor. grp. memb.> 50% than staff memb. in HIV dir.svc."
	Endif	

	If agency.mg_solo
		m.a_d3 = "Solo or grp. priv. HC practice > 50% of the clinicians"
	Endif
		
	If agency.mg_trad
		m.a_d4 = "Trad. provider served minor. clients but not meet crit."
	Endif
	
	If agency.mg_other
		m.a_d5 = "Other type or facility"
	Endif

Else
	oApp.msg2user('NOTFOUNDG')
	Return
Endif
	Select t_cadr
*--Q5
	m.group   = "4.   Person Completing this form: " + Space(4) + "  Name: " + Space(2) + ;
               Iif(Isnull(t_cadr.name), '', t_cadr.name)
	m.info =4
	Insert Into cadr_tmp From Memvar
					  

	m.group = Space(37) + "Phone #: " + Space(2) + Iif(Empty(t_cadr.phone),Space(14),Transform(t_cadr.phone,"@R (999) 999-9999"))
	Insert Into cadr_tmp From Memvar
		
	m.group = Space(39) + "Email: " + Space(2) + Iif(Isnull(t_cadr.e_mail),'',Rtrim(t_cadr.e_mail))
	Insert Into cadr_tmp From Memvar
	
	m.part    = "Part 1.2. Reporting and Program Information"

*--Q5
	m.group   = "5.   Reporting Period: " + Space(11) + "Start Date: " + Space(2) + Dtoc(dStartDate)
	m.info = 5
	Insert Into cadr_tmp From Memvar

	m.group = Space(36) + "End Date: " + Space(2) + Dtoc(dEndDate)
	Insert Into cadr_tmp From Memvar

*--Q6
* jss, 11/27/07:   m.group   = "6.   Reporting Scope: " + Space(26) + Iif(nScope =1, "Eligible for Title I, II, III or IV Funding", "Funded by Title I, II, III or IV")
* PB: 06/2010:  m.group   = "6.   Reporting Scope: " + Space(26) + Iif(nScope =1, "Eligible for Part A, B, C or D Funding", "Funded by Part A, B, C or D")
   m.group   = "6.   Reporting Scope: " + Space(26) + Iif(nScope =1, "Eligible for Part A,B,C,D, State or AIDS Institute - RF Funding", "Funded by Part A, B, C or D")
   
	m.info = 6
	Insert Into cadr_tmp From Memvar
	
*--Q7
 	m.group   = "7a.  Provider Type: " + Space(28) + Iif(Isnull(m.pr_desc),'',m.pr_desc) 
	m.info = 7
	Insert Into cadr_tmp From Memvar
	
	m.group   = " b.  Sec. 330 of Public Health Svc. Act Funds: " +  Space(1) + ;
					Iif(t_cadr.pubhealth = 1, "Yes", Iif(t_cadr.pubhealth = 2, "No", Iif(t_cadr.pubhealth = 3, "Don't Know/Unsure", "")))
	Insert Into cadr_tmp From Memvar

*--Q8
 	m.group   = "8a.  Ownership Status: " + Space(25) + Iif(Isnull(m.own_desc),'',m.own_desc)
	m.info = 8
	Insert Into cadr_tmp From Memvar
	m.group   = " b.  Faith-based organization: " + Space(17) + Iif(Isnull(m.faithbased), '',m.faithbased)
	Insert Into cadr_tmp From Memvar
*--Q9
 	m.group   = "9.   Minority AIDS Initiative (MAI) Funding: " + Space(3) + Iif(Isnull(m.maifunding),'',m.maifunding)
	m.info = 9
	Insert Into cadr_tmp From Memvar
			
*!*   *--Q10
*!*      m.group   = "10.  Source of Ryan White CARE Act Funding:"+SPACE(5)+"Grantee Name" 
*!*      m.info = 10
*!*      Insert Into cadr_tmp From Memvar

*!*      If t_cadr.title1
*!*         IF !EMPTY(t_cadr.titl1name1)
*!*            m.group   = Space(34) + "Title I:" + SPACE(6) + "1: " + Iif(Isnull(t_cadr.titl1name1), '',t_cadr.titl1name1)
*!*         ELSE
*!*            m.group   = Space(34) + "Title I:"           
*!*         ENDIF   
*!*         Insert Into cadr_tmp From Memvar

*!*         IF !EMPTY(t_cadr.titl1name2)
*!*            m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl1name2), '', t_cadr.titl1name2)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   

*!*         IF !EMPTY(t_cadr.titl1name3)
*!*            m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl1name3), '', t_cadr.titl1name3)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   
*!*      Endif   
*!*      
*!*      If t_cadr.title2
*!*         IF !EMPTY(t_cadr.titl2name1)
*!*            m.group   = Space(33) + "Title II:" + SPACE(6) + "1: " +Iif(Isnull(t_cadr.titl2name1), '', t_cadr.titl2name1)
*!*         ELSE
*!*            m.group   = Space(33) + "Title II:"          
*!*         ENDIF   
*!*         Insert Into cadr_tmp From Memvar

*!*         IF !EMPTY(t_cadr.titl2name2)
*!*            m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl2name2), '',t_cadr.titl2name2)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   

*!*         IF !EMPTY(t_cadr.titl2name3)
*!*            m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl2name3), '', t_cadr.titl2name3)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   
*!*      Endif   
*!*      
*!*      If t_cadr.title3
*!*         IF !EMPTY(t_cadr.titl3name1)
*!*            m.group   = Space(32) + "Title III:" + SPACE(6) + "1: " +Iif(Isnull(t_cadr.titl3name1), '', t_cadr.titl3name1)
*!*         ELSE
*!*            m.group   = Space(32) + "Title III:"                
*!*         ENDIF   
*!*         Insert Into cadr_tmp From Memvar

*!*         IF !EMPTY(t_cadr.titl3name2)
*!*            m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl3name2),'', t_cadr.titl3name2)      
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   

*!*         IF !EMPTY(t_cadr.titl3name3)
*!*            m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl3name3), '', t_cadr.titl3name3)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   
*!*      Endif
*!*      
*!*      If t_cadr.title4
*!*         IF !EMPTY(t_cadr.titl4name1)
*!*            m.group   = Space(33) + "Title IV:" + SPACE(6) + "1: " + Iif(Isnull(t_cadr.titl4name1), '', t_cadr.titl4name1)
*!*         ELSE
*!*            m.group   = Space(33) + "Title IV:"                
*!*         ENDIF   
*!*         Insert Into cadr_tmp From Memvar

*!*         IF !EMPTY(t_cadr.titl4name2)
*!*            m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl4name2), '', t_cadr.titl4name2)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   

*!*         IF !EMPTY(t_cadr.titl4name3)
*!*            m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl4name3), '', t_cadr.titl4name3)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   
*!*      Endif
*!*      
*!*      If t_cadr.title4ad
*!*         IF !EMPTY(t_cadr.titadname1)
*!*            m.group   = Space(11) + "Title IV Adolescent Initiative:" + SPACE(6) + "1: " +;
*!*                        Iif(Isnull(t_cadr.titadname1), '', t_cadr.titadname1)                
*!*         ELSE
*!*            m.group   = Space(11) + "Title IV Adolescent Initiative:"                
*!*         ENDIF   
*!*         Insert Into cadr_tmp From Memvar

*!*         IF !EMPTY(t_cadr.titadname2)
*!*            m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titadname2), '', t_cadr.titadname2)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   

*!*         IF !EMPTY(t_cadr.titadname3)
*!*            m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titadname3), '', t_cadr.titadname3)         
*!*            Insert Into cadr_tmp From Memvar
*!*         ENDIF   
*!*      Endif

*!*   *--Q11
*!*      m.group   = "11a. Amount of Title I funding:" + Space(17) +  Iif(t_cadr.act1_amt <> 0 or t_cadr.act1 <> 0, "$"+ Alltrim(Str(t_cadr.act1_amt, 9 ,0)) + Space(10)  +;
*!*                     Iif(t_cadr.act1_amt = 0, Iif(t_cadr.act1 = 1 , "Unknown",  ;
*!*                     Iif(t_cadr.act1 = 2, "N/A" , " ")), ""), "") 
*!*      m.info = 11
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   * mai title I received
*!*      m.group   = "  b. Amount of MAI Title I funding:" + Space(13) + "$" + ;
*!*                  Iif(Isnull(t_cadr.mai1_amt),  Space(8)+'0',  Alltrim(Str(t_cadr.mai1_amt, 9 ,0))) 
*!*      Insert Into cadr_tmp From Memvar

*!*   *--Q12
*!*      m.group   = "12a. Amount of Title II funding:" + Space(16) + Iif(t_cadr.act2_amt <> 0 or t_cadr.act2 <> 0, "$" + Alltrim(Str(t_cadr.act2_amt, 9 ,0)) + Space(10) + ;
*!*                     Iif(t_cadr.act2_amt = 0, Iif(t_cadr.act2 = 1 , "Unknown", ;
*!*                     Iif(t_cadr.act2 = 2, "N/A" , " ")), ""), "")
*!*      m.info = 12
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   * mai title II received
*!*      m.group   = "  b. Amount of MAI Title II funding:" + Space(12) + "$"+ ;
*!*                     Iif(Isnull(t_cadr.mai2_amt), Space(8)+'0', Alltrim(Str(t_cadr.mai2_amt, 9 ,0))) 
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   *--Q13
*!*      m.group   = "13a. Amount of Title III funding:" + Space(15) +  Iif(t_cadr.act3_amt <> 0 or t_cadr.act3 <> 0, "$" + Alltrim(Str(t_cadr.act3_amt, 9 ,0)) + Space(10) + ;
*!*                     Iif(t_cadr.act3_amt = 0, Iif(t_cadr.act3 = 1 , "Unknown", ;
*!*                     Iif(t_cadr.act3 = 2, "N/A" , " ")), ""), "")
*!*      m.info = 13
*!*      Insert Into cadr_tmp From Memvar

*!*   * mai title III received
*!*      m.group   = "  b. Amount of MAI Title III funding:" + Space(11) +  "$"+;
*!*                  Iif(Isnull(t_cadr.mai3_amt), Space(8)+'0', Alltrim(Str(t_cadr.mai3_amt, 9 ,0))) 
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   *--Q14
*!*      m.group   = "14a. Amount of Title IV funding:" + Space(16) +  Iif(t_cadr.act4_amt <> 0 or t_cadr.act4 <> 0, "$" + Alltrim(Str(t_cadr.act4_amt, 9 ,0)) + Space(10) + ;
*!*                     Iif(t_cadr.act4_amt = 0, Iif(t_cadr.act4 = 1 , "Unknown", ;
*!*                     Iif(t_cadr.act4 = 2, "N/A" , " ")), ""), "")
*!*      m.info = 14
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   * mai title IV received
*!*      m.group   = "  b. Amount of MAI Title IV funding:" + Space(12) +  "$"+ ;
*!*                  Iif(Isnull(t_cadr.mai4_amt), Space(8)+'0', Alltrim(Str(t_cadr.mai4_amt, 9 ,0))) 
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   *--Q15
*!*       *** For transfer to  next page
*!*      m.group   = " " + CHR(13) +" " + CHR(13) 
*!*      m.info = 15
*!*      Insert Into cadr_tmp From Memvar
*!*      m.group   = "15.  Amount of RW CARE Act Expended on      " + CHR(13) + ;
*!*                  "     Oral HC during this period:            " + Space(4) +  "$" + ;
*!*                  Iif(Isnull(t_cadr.totalexp), Space(8)+'0', Alltrim(Str(t_cadr.totalexp, 9 ,0))) 
*!*      Insert Into cadr_tmp From Memvar
* jss, 11/27/07, modify 10 thru 15 for 2007 PDR 
*--Q10
   m.group   = "10.  Source of Ryan White HIV/AIDS Funding:"+SPACE(5)+"Grantee Name" 
   m.info = 10
   Insert Into cadr_tmp From Memvar

   If t_cadr.title1
      IF !EMPTY(t_cadr.titl1name1)
         m.group   = Space(35) + "Part A:" + SPACE(6) + "1: " + Iif(Isnull(t_cadr.titl1name1), '',t_cadr.titl1name1)
      ELSE
         m.group   = Space(35) + "Part A:"           
      ENDIF   
      Insert Into cadr_tmp From Memvar

      IF !EMPTY(t_cadr.titl1name2)
         m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl1name2), '', t_cadr.titl1name2)         
         Insert Into cadr_tmp From Memvar
      ENDIF   

      IF !EMPTY(t_cadr.titl1name3)
         m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl1name3), '', t_cadr.titl1name3)         
         Insert Into cadr_tmp From Memvar
      ENDIF   
   Endif   
   
   If t_cadr.title2
      IF !EMPTY(t_cadr.titl2name1)
         m.group   = Space(35) + "Part B:" + SPACE(6) + "1: " +Iif(Isnull(t_cadr.titl2name1), '', t_cadr.titl2name1)
      ELSE
         m.group   = Space(35) + "Part B:"          
      ENDIF   
      Insert Into cadr_tmp From Memvar

      IF !EMPTY(t_cadr.titl2name2)
         m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl2name2), '',t_cadr.titl2name2)         
         Insert Into cadr_tmp From Memvar
      ENDIF   

      IF !EMPTY(t_cadr.titl2name3)
         m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl2name3), '', t_cadr.titl2name3)         
         Insert Into cadr_tmp From Memvar
      ENDIF   
   Endif   
   
   If t_cadr.title3
      IF !EMPTY(t_cadr.titl3name1)
         m.group   = Space(35) + "Part C:" + SPACE(6) + "1: " +Iif(Isnull(t_cadr.titl3name1), '', t_cadr.titl3name1)
      ELSE
         m.group   = Space(35) + "Part C:"                
      ENDIF   
      Insert Into cadr_tmp From Memvar

      IF !EMPTY(t_cadr.titl3name2)
         m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl3name2),'', t_cadr.titl3name2)      
         Insert Into cadr_tmp From Memvar
      ENDIF   

      IF !EMPTY(t_cadr.titl3name3)
         m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl3name3), '', t_cadr.titl3name3)         
         Insert Into cadr_tmp From Memvar
      ENDIF   
   Endif
   
   If t_cadr.title4
      IF !EMPTY(t_cadr.titl4name1)
         m.group   = Space(35) + "Part D:" + SPACE(6) + "1: " + Iif(Isnull(t_cadr.titl4name1), '', t_cadr.titl4name1)
      ELSE
         m.group   = Space(35) + "Part D:"                
      ENDIF   
      Insert Into cadr_tmp From Memvar

      IF !EMPTY(t_cadr.titl4name2)
         m.group = Space(48) + '2: ' + Iif(Isnull(t_cadr.titl4name2), '', t_cadr.titl4name2)         
         Insert Into cadr_tmp From Memvar
      ENDIF   

      IF !EMPTY(t_cadr.titl4name3)
         m.group = Space(48) + '3: ' + Iif(Isnull(t_cadr.titl4name3), '', t_cadr.titl4name3)         
         Insert Into cadr_tmp From Memvar
      ENDIF   
   Endif
   
*--Q11
   m.group   = "11a. Amount of Part A funding:" + Space(18) +  Iif(t_cadr.act1_amt <> 0 or t_cadr.act1 <> 0, "$"+ Alltrim(Str(t_cadr.act1_amt, 9 ,0)) + Space(10)  +;
                  Iif(t_cadr.act1_amt = 0, Iif(t_cadr.act1 = 1 , "Unknown",  ;
                  Iif(t_cadr.act1 = 2, "N/A" , " ")), ""), "") 
   m.info = 11
   Insert Into cadr_tmp From Memvar
   
* mai title I received
   m.group   = "  b. Amount of MAI Part A funding:" + Space(14) + "$" + ;
               Iif(Isnull(t_cadr.mai1_amt),  Space(8)+'0',  Alltrim(Str(t_cadr.mai1_amt, 9 ,0))) 
   Insert Into cadr_tmp From Memvar

*--Q12
   m.group   = "12a. Amount of Part B funding:" + Space(18) + Iif(t_cadr.act2_amt <> 0 or t_cadr.act2 <> 0, "$" + Alltrim(Str(t_cadr.act2_amt, 9 ,0)) + Space(10) + ;
                  Iif(t_cadr.act2_amt = 0, Iif(t_cadr.act2 = 1 , "Unknown", ;
                  Iif(t_cadr.act2 = 2, "N/A" , " ")), ""), "")
   m.info = 12
   Insert Into cadr_tmp From Memvar
   
* mai title II received
   m.group   = "  b. Amount of MAI Part B funding:" + Space(14) + "$"+ ;
                  Iif(Isnull(t_cadr.mai2_amt), Space(8)+'0', Alltrim(Str(t_cadr.mai2_amt, 9 ,0))) 
   Insert Into cadr_tmp From Memvar
   
*--Q13
   m.group   = "13a. Amount of Part C funding:" + Space(18) +  Iif(t_cadr.act3_amt <> 0 or t_cadr.act3 <> 0, "$" + Alltrim(Str(t_cadr.act3_amt, 9 ,0)) + Space(10) + ;
                  Iif(t_cadr.act3_amt = 0, Iif(t_cadr.act3 = 1 , "Unknown", ;
                  Iif(t_cadr.act3 = 2, "N/A" , " ")), ""), "")
   m.info = 13
   Insert Into cadr_tmp From Memvar

* mai title III received
   m.group   = "  b. Amount of MAI Part C funding:" + Space(14) +  "$"+;
               Iif(Isnull(t_cadr.mai3_amt), Space(8)+'0', Alltrim(Str(t_cadr.mai3_amt, 9 ,0))) 
   Insert Into cadr_tmp From Memvar
   
*--Q14
   m.group   = "14a. Amount of Part D funding:" + Space(18) +  Iif(t_cadr.act4_amt <> 0 or t_cadr.act4 <> 0, "$" + Alltrim(Str(t_cadr.act4_amt, 9 ,0)) + Space(10) + ;
                  Iif(t_cadr.act4_amt = 0, Iif(t_cadr.act4 = 1 , "Unknown", ;
                  Iif(t_cadr.act4 = 2, "N/A" , " ")), ""), "")
   m.info = 14
   Insert Into cadr_tmp From Memvar
   
* mai title IV received
   m.group   = "  b. Amount of MAI Part D funding:" + Space(14) +  "$"+ ;
               Iif(Isnull(t_cadr.mai4_amt), Space(8)+'0', Alltrim(Str(t_cadr.mai4_amt, 9 ,0))) 
   Insert Into cadr_tmp From Memvar
   
*--Q15
    *** For transfer to  next page
   m.group   = " " + CHR(13) +" " + CHR(13) 
   m.info = 15
   Insert Into cadr_tmp From Memvar
   m.group   = "15.  Amount of RW HIV/AIDS Expended on      " + CHR(13) + ;
               "     Oral HC during this period:            " + Space(4) +  "$" + ;
               Iif(Isnull(t_cadr.totalexp), Space(8)+'0', Alltrim(Str(t_cadr.totalexp, 9 ,0))) 
   Insert Into cadr_tmp From Memvar
* jss, end of 11/27/07 change   

*--Q16
	m.group   = "16.  During this reporting period, did you  " + Chr(13) + ;
		      	"     provide Grantee Support In... ?:       " 
	m.info = 16
	Insert Into cadr_tmp From Memvar
	
	If t_cadr.planning <> 0
		m.group   = Space(48) + "Planning or evaluation" + Space(16) + Iif(t_cadr.planning = 1, "Yes", "No")  
		Insert Into cadr_tmp From Memvar
	Endif
	
	If t_cadr.admin <> 0
		m.group   = Space(48) + "Administrative or technical support" + Space(3) + Iif(t_cadr.admin = 1, "Yes", "No")  
		Insert Into cadr_tmp From Memvar
	Endif

	If t_cadr.fiscal <> 0
		m.group   = Space(48) + "Fiscal intermediary services" + Space(10) + Iif(t_cadr.fiscal = 1, "Yes", "No")  
		Insert Into cadr_tmp From Memvar
	Endif
	
	If t_cadr.technic <> 0
		m.group   = Space(48) + "Technical assistance" + Space(18) + Iif(t_cadr.technic = 1, "Yes", "No")  
		Insert Into cadr_tmp From Memvar
	Endif

	If t_cadr.capacity <> 0
		m.group   = Space(48) + "Capacity development" + Space(18) + Iif(t_cadr.capacity = 1, "Yes", "No")  
		Insert Into cadr_tmp From Memvar
	Endif
	
	If t_cadr.quality <> 0
		m.group   = Space(48) + "Quality management" + Space(20) + Iif(t_cadr.quality = 1, "Yes", "No")  
		Insert Into cadr_tmp From Memvar
	Endif

*--Q17
	m.group   = "17a. ADAP or local pharm. assistance?: " + Space(9) + "No"
	m.info = 17
	Insert Into cadr_tmp From Memvar

	m.group   = "  b. Type of program administered: " 
	Insert Into cadr_tmp From Memvar
	
*--Q18
	m.group   = "18.  Provided a Health Insurance Program?: " + Space(5) + "No" 
	m.info = 18
	Insert Into cadr_tmp From Memvar

*--Q19
	m.group   = "19.  Populations targeted for Outreach or Svc.: " 
	m.info = 19
	Insert Into cadr_tmp From Memvar
	
	If t_cadr.migrant
		m.group   = Space(48) + "Migrant or seasonal workers"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.rural
		m.group   = Space(48) + "Rural popul. other than migrant or seasonal workers"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.women
		m.group   = Space(48) + "Women"
		Insert Into cadr_tmp From Memvar
	Endif			  
	
	If t_cadr.children
		m.group   = Space(48) + "Children"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.race_eth
		m.group   = Space(48) + "Racial/ethnic minorities/communities of color"
		Insert Into cadr_tmp From Memvar
	Endif
	
	If t_cadr.homeless
		m.group   = Space(48) + "Homeless"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.l_youth
		m.group   = Space(48) + "Gay, lesbian and bisexual youth"
		Insert Into cadr_tmp From Memvar
	Endif	

	If t_cadr.l_adults
		m.group   = Space(48) + "Gay, lesbian and bisexual adults"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.incarper
		m.group   = Space(48) + "Incarcerated persons"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.all_adol
		m.group   = Space(48) + "All adolescents"
		Insert Into cadr_tmp From Memvar
	Endif	

	If t_cadr.runaway
		m.group   = Space(48) + "Runaway or street youth"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.inject
		m.group   = Space(48) + "Injection drug users"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.n_inject
		m.group   = Space(48) + "Non-injection drug users"
		Insert Into cadr_tmp From Memvar
	Endif	

	If t_cadr.parolees
		m.group   = Space(48) + "Parolees"
		Insert Into cadr_tmp From Memvar
	Endif	
	
	If t_cadr.other
		m.group   = Space(48) + "Other:"
		Insert Into cadr_tmp From Memvar
		m.group = SPACE(53) + Iif(Isnull(t_cadr.otherspec), '', ALLTRIM(t_cadr.otherspec))
		Insert Into cadr_tmp From Memvar
	Endif	

*--Q20
	m.group   = "20.  Agency Description: " 
	m.info = 20
	Insert Into cadr_tmp From Memvar
	
	If !Empty(m.a_d1)
		m.group   = Space(48) + m.a_d1
		Insert Into cadr_tmp From Memvar
	Endif
	
	If !Empty(m.a_d2)
		m.group   = Space(48) + m.a_d2
		Insert Into cadr_tmp From Memvar
	Endif	

	If !Empty(m.a_d3)
		m.group   = Space(48) + m.a_d3
		Insert Into cadr_tmp From Memvar
	Endif	

	If !Empty(m.a_d4)
		m.group   = Space(48) + m.a_d4
		Insert Into cadr_tmp From Memvar
	Endif	

	If !Empty(m.a_d5)
		m.group   = Space(48) + m.a_d5
		Insert Into cadr_tmp From Memvar
	Endif	
	
*--Q21
* jss, 11/27/07
*   m.group   = "21.  Total Paid RW-Title Staff in FTEs:"  + Space(9) + 
   m.group   = "21.  Total Paid RW-Part Staff in FTEs: "  + Space(9) + ;
               Iif(Isnull(t_cadr.an_staff), Space(4)+'0', Alltrim(Str(t_cadr.an_staff, 5, 1)))
	m.info = 21
	Insert Into cadr_tmp From Memvar

*--Q22	
	m.group   = "22.  Total Volunteer Staff in FTEs:    " + Space(9) + ;
               Iif(Isnull(t_cadr.an_volun), Space(4)+'0', Alltrim(Str(t_cadr.an_volun, 5 ,1)))
	m.info = 22
	Insert Into cadr_tmp From Memvar
   
RETURN
********************
PROCEDURE sect23prep 	
********************
*-Prepar. Data For Section 2 and 3 ------------
If Used('t_prog')
   Use In t_prog
Endif
      *!* Support Ticket #27218/#6671
		If nScope = 2 && RW Funded
				Select program.prog_id, program.fund_type, program.elig_type, program.enr_req ;
				From program ;
				Where (program.elig_type = "01";
                    And program.fund_type <> "07" ;
                    And program.fund_type <> "18";
                    And program.fund_type <> "19") ;
                  Or	(program.elig_type = "02" and program.fund_type = "05") ;
				Into Cursor t_prog		
		Endif		

		If nScope = 1  && RW Eligible
				Select program.prog_id, program.fund_type, program.elig_type, program.enr_req ;
				From program ;
				Where program.elig_type <> "03"  ;
				  and program.elig_type <> "04";
				Into Cursor t_prog		
		Endif		

*** Select All encounters durin report. period
If Used('tEncAll')   
   Use In tEncAll
Endif

=OpenView("lv_enc_type", "urs")
=OpenView("lv_service", "urs")

		Select ai_enc.tc_id, ;
				ai_enc.act_id, ;
				ai_enc.serv_cat, ;
				ai_enc.enc_id, ;
				ai_enc.act_dt, ;
				lv_enc_type.cadr_map, ;
				t_prog.fund_type, ;
				t_prog.elig_type, ;
				t_prog.enr_req, ;
				t_prog.prog_id ;
		From ai_enc, lv_enc_type, t_prog ;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			ai_enc.program = t_prog.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate);
		Into Cursor tEncAll

If Used('t_serv')
   Use In t_serv
Endif
   
	Select	ai_serv.tc_id, ;
				ai_serv.act_id, ;
				tEncAll.serv_cat, ;
				tEncAll.enc_id, ;
				ai_serv.date as act_dt, ;
				lv_service.cadr_map, ;
				tEncAll.fund_type, ;
				tEncAll.elig_type, ;
				tEncAll.enr_req, ;
				tEncAll.prog_id ;
		From ai_serv, tEncAll, lv_service ;
		Where ;
				ai_serv.act_id = tEncAll.act_id and ;
				tEncAll.serv_cat = lv_service.serv_cat and ;
				(tEncAll.enc_id = lv_service.enc_id OR EMPTY(lv_service.enc_id)) and  ;
				ai_serv.service_id = lv_service.service_id and ;
				!Empty(lv_service.cadr_map) and ;
				Left(lv_service.cadr_map,2) = "33" and ;
				between(ai_serv.date, dStartDate, dEndDate);
		Into Cursor t_serv

If Used('prior_enc')
   Use In prior_enc
Endif
   
		Select ai_enc.tc_id, ;
				ai_enc.act_id, ;
				ai_enc.serv_cat, ;
				ai_enc.enc_id, ;
				ai_enc.act_dt, ;
				lv_enc_type.cadr_map, ;
				t_prog.fund_type, ;
				t_prog.elig_type, ;
				t_prog.enr_req, ;
				t_prog.prog_id ;
		From ai_enc, lv_enc_type, t_prog ;
		Where (lv_enc_type.serv_cat='00021' or lv_enc_type.serv_cat='00002') and ;
			ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			ai_enc.program = t_prog.prog_id and ;
			ai_enc.act_dt < dStartDate ;
		Into Cursor prior_enc
      
If Used('prior_serv')
   Use In prior_serv
Endif
   
	Select	ai_serv.tc_id, ;
				ai_serv.act_id, ;
				prior_enc.serv_cat, ;
				prior_enc.enc_id, ;
				ai_serv.date as act_dt, ;
				lv_service.cadr_map, ;
				prior_enc.fund_type, ;
				prior_enc.elig_type, ;
				prior_enc.enr_req, ;
				prior_enc.prog_id ;
		From ai_serv, prior_enc, lv_service ;
		Where ;
				ai_serv.act_id = prior_enc.act_id and ;
				prior_enc.serv_cat = lv_service.serv_cat and ;
				(prior_enc.enc_id = lv_service.enc_id OR EMPTY(lv_service.enc_id)) and  ;
				ai_serv.service_id = lv_service.service_id and ;
				!Empty(lv_service.cadr_map) and ;
				Left(lv_service.cadr_map,2) = "33" and ;
				between(ai_serv.date, dStartDate, dEndDate);
		Into Cursor prior_serv
	
Use in prior_enc

If Used('all_serv')
   Use In all_serv
Endif
   
		Select * ;
		From t_serv ; 		
		Union ;
		Select * ;
		From prior_serv ; 		
		Union ;
		Select tEncAll.tc_id, ;
				tEncAll.act_id, ;
				tEncAll.serv_cat, ;
				tEncAll.enc_id, ;
				tEncAll.act_dt, ;
				tEncAll.cadr_map, ;
				tEncAll.fund_type, ;
				tEncAll.elig_type, ;
				tEncAll.enr_req, ;
				tEncAll.prog_id ;
		From tEncAll ;
		Where Left(tEncAll.cadr_map,2) = "33" and ;
				tEncAll.act_id Not in (Select act_id ;
										From t_serv ) ;
		Into Cursor ;
			all_serv
			
Use in t_serv
Use in tEncAll
Use in prior_serv

*** All HIV
If Used('all_h')
   Use In all_h
Endif

	Select all_serv.*, hstat.hiv_pos, hivstat.hivstatus, client.gender, ;
				client.dob, 000 as cl_age, client.hispanic, ;
				client.white, client.blafrican, client.asian, ;
				client.hawaisland, client.indialaska, client.unknowrep, client.someother, ;
				client.client_id, client.is_refus, client.hshld_size, client.hshld_incm,;
				ai_clien.housing, client.insurance ;
	From all_serv, hivstat, hstat, client, ai_clien ;
	Where all_serv.tc_id = hivstat.tc_id and ;
			all_serv.tc_id    = ai_clien.tc_id and ;
			client.client_id  = ai_clien.client_id and ;
		hivstat.tc_id + Dtos(hivstat.effect_dt) + hivstat.status_id ;
									In (Select f2.tc_id + Max(Dtos(f2.effect_dt) + f2.status_id) ;
										From ;
											hivstat f2 ;
										Where ;
											f2.effect_dt <= dEndDate Group by f2.tc_id)  and ;
		hivstat.hivstatus = hstat.code ;
	Into Cursor	all_h

		oApp.reOpencur('all_h', 'all_hiv', .t.)
		
	Replace ALL cl_age With Iif(!EMPTY(Dob),oApp.AGE(dEndDate,Dob),000) 
	Use in all_serv

  	
*** HIV+ total # of undupl. clients by service cat (cadr_map)
** Total # of undupl. HIV indeterminate clients
If Used('t_indet')
   Use In t_indet
Endif
   
		Select Distinct tc_id, hispanic ;
		From all_hiv ;
		Where !Empty(dob) ;
		and	cl_age < 2 ;
		and	(hivstatus='06' or hivstatus='07') ;
		Into Cursor t_indet

* jss, 4/5/05, index t_indet on tc_id (to be used in Q71,72,73)		
		Select t_indet
		Index on tc_id tag tc_id 
         
* jss, 3/25/05, must also include HIV indeterminates in HIV Positive totals
If Used('t_hivc')
   Use In t_hivc
Endif
   
     Select Count(Distinct all_hiv.tc_id) as tot_hivc, ;
            cadr_map ;
      From all_hiv ;
      Where all_hiv.hiv_pos = .t. ;
      or all_hiv.tc_id in (Select tc_id From t_indet) ;
      Group by cadr_map ;
      Into Cursor t_hivc 

***HIV + total of visits by servic cat (cadr_map). 1 per day for each serv cat
* jss, 3/25/05, must also include HIV indeterminates in HIV Positive totals
If Used('t_hiv1')
   Use In t_hiv1
Endif
   
		Select Count(Distinct all_hiv.act_dt) as tot_hivs, ;
				cadr_map ;
		From all_hiv ;
		Where all_hiv.hiv_pos = .t. ;
		or all_hiv.tc_id in (Select tc_id From t_indet) ;
		Group by cadr_map, tc_id ;
		Into Cursor t_hiv1

If Used('t_hivs')
   Use In t_hivs 
Endif
   		
		Select sum(tot_hivs) as tot_hivs, cadr_map ;
		From t_hiv1 ;
		Group by cadr_map ; 
		Into Cursor t_hivs 
		
		Use in t_hiv1
		
*** Combine to 1 cursor		
If Used('t_h1')
   Use In t_h1
Endif

If Used('t_h')
   Use In t_h
Endif

   	Select Str(t_hivc.tot_hivc,6, 0) as tot_hivc , Str(t_hivs.tot_hivs, 6,0) as tot_hivs, ;
				t_hivs.cadr_map ;
		From t_hivc, t_hivs ;
		Where t_hivc.cadr_map = t_hivs.cadr_map ;
		Into cursor t_h1
		
		Select Str(tot_hivc, 6,0) as tot_hivc, ;
				'000000' as tot_hivs, ; 
				cadr_map ;
		From t_hivc ;
		Where cadr_map Not in (Select cadr_map from t_h1) ;
		Union ;
		Select '000000' as tot_hivc, ;
				Str(tot_hivs, 6,0) as tot_hivs, ; 
				cadr_map ;
		From t_hivs ;
		Where cadr_map Not in (Select cadr_map from t_h1) ;
		Union ;
		Select * ;
		From t_h1 ;
		Into cursor t_h

		Index on cadr_map tag cadr_map

		oApp.reOpencur('t_h', 'tot_hiv', .t.)
		
		Set Order to tag cadr_map
		
Use in t_h1		
use in t_hivc		
Use in t_hivs

*** Affected total # of undupl. clients by servic cat (cadr_map)
If Used('t_affc')
   Use In t_affc
Endif
	
		Select Count(Distinct all_hiv.tc_id) as tot_affc, ;
				cadr_map ;
		From all_hiv ;
		Where (all_hiv.hivstatus = "04" or ;
				all_hiv.hivstatus = "06" or ;
				all_hiv.hivstatus = "07" or ;
				all_hiv.hivstatus = "08" or ;
				all_hiv.hivstatus = "09" or ;
				all_hiv.hivstatus = "12") ;
		and tc_id Not in (Select tc_id From t_indet) ;		
		Group by cadr_map ;
		Into Cursor t_affc 

*!*   ***Affected total of visits by servic cat (cadr_map). 1 per day for each serv cat
If Used('t_aff1')
   Use In t_aff1
Endif

		Select Count(Distinct all_hiv.act_dt) as tot_affs, ;
				cadr_map ;
		From all_hiv ;
		Where (all_hiv.hivstatus = "04" or ;
				all_hiv.hivstatus = "06" or ;
				all_hiv.hivstatus = "07" or ;
				all_hiv.hivstatus = "08" or ;
				all_hiv.hivstatus = "09" or ;
				all_hiv.hivstatus = "12") ;
		and tc_id Not in (Select tc_id From t_indet) ;		
		Group by cadr_map, tc_id ;
		Into Cursor t_aff1 


If Used('t_affs')
   Use In t_affs
Endif

		Select sum(tot_affs) as tot_affs, cadr_map ;
		From t_aff1 ;
		Group by cadr_map ; 
		Into Cursor t_affs 
		
		Use in t_aff1
		
*** Combine to 1 cursor		

If Used('t_h1')
   Use In t_h1
Endif

If Used('t_h')
   Use In t_h
Endif

		Select Str(t_affc.tot_affc,6, 0) as tot_affc , Str(t_affs.tot_affs, 6,0) as tot_affs, ;
				t_affs.cadr_map ;
		From t_affc, t_affs ;
		Where t_affc.cadr_map = t_affs.cadr_map ;
		Into cursor t_h1
		
		
		Select Str(tot_affc, 6,0) as tot_affc, ;
				'000000' as tot_affs, ; 
				cadr_map ;
		From t_affc ;
		Where cadr_map Not in (Select cadr_map from t_h1) ;
		Union ;
		Select '000000' as tot_affc, ;
				Str(tot_affs, 6,0) as tot_affs, ; 
				cadr_map ;
		From t_affs ;
		Where cadr_map Not in (Select cadr_map from t_h1) ;
		Union ;
		Select * ;
		From t_h1 ;
		Into cursor t_h
	
		Index on cadr_map tag cadr_map

		oApp.reOpencur('t_h', 'tot_aff', .t.)
	
		Set Order to tag cadr_map
		
Use in t_h1
Use in t_affc
Use in t_affs		
Return
***************
PROCEDURE sect2
***************
*** Section 2
	m.prvid      = agency.aar_id
	m.regcode    = SPACE(5)
	m.prvname1   = TRIM(agency.descript1)+' '+TRIM(agency.descript2)
	m.RecId= LEFT(DTOS(dEndDate),6) + m.PrvID
	m.section = Space(40) + "SECTION 2.  CLIENT INFORMATION"
	m.part = ""

*---Q23
	m.group   = "23.  Total Number of unduplicated clients: " 
	m.info = 23
	Insert Into cadr_tmp From Memvar

** Total # of undupl. clients HIV+ only
If Used('t_hivc')
   Use in t_hivc
Endif
   
		Select Count(Distinct all_hiv.tc_id) as tot_hivc ;
		From all_hiv ;
		Where all_hiv.hiv_pos = .t. ;
		and all_hiv.tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_hivc 

		Select t_hivc
		Sum tot_hivc to m.tot_hiv1 

		m.group   = Space(48) + Iif(Isnull(m.tot_hiv1), Space(5)+'0',Str(m.tot_hiv1, 6, 0)) + "   HIV-positive only " 
		Insert Into cadr_tmp From Memvar
Use in t_hivc

If Used('t_indet2')
   Use in t_indet2
Endif

		Select Count(*) as tot_hivc ;
		From t_indet ;
		Into Cursor t_indet2 

		Select t_indet2
		Sum tot_hivc to m.tot_indet 

		m.group   = Space(48) + Iif(Isnull(m.tot_indet), Space(5)+'0', Str(m.tot_indet, 6, 0)) + "   HIV indeterminate (under age 2) " 
		Insert Into cadr_tmp From Memvar

Use in t_indet2

		m.sect2posin=m.tot_hiv1+m.tot_indet

** Total # of undupl. clients HIV-negative
		Select Count(Distinct all_hiv.tc_id) as tot_hivc ;
		From all_hiv ;
		Where (all_hiv.hivstatus = "06" or ;
			all_hiv.hivstatus = "07" or ;
			all_hiv.hivstatus = "08" or ;
			all_hiv.hivstatus = "09") ;
		and all_hiv.tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_hivc 
		
		Select t_hivc
		Sum tot_hivc to m.tot_hiv2 
		
		m.group   = Space(48) + Iif(Isnull(m.tot_hiv2), Space(5)+'0',Str(m.tot_hiv2, 6, 0)) + "   HIV-negative (affected)" 
		Insert Into cadr_tmp From Memvar
Use in t_hivc

** Total # of undupl. clients Unknown
		Select Count(Distinct all_hiv.tc_id) as tot_hivc ;
		From all_hiv ;
		Where (all_hiv.hivstatus = "12" or ;
			all_hiv.hivstatus = "04") ;
		and all_hiv.tc_id Not In (Select tc_id From t_indet) ; 
		Into Cursor t_hivc 

		Select t_hivc
		Sum tot_hivc to m.tot_hiv3 
		
		m.group   = Space(48) + Iif(Isnull(m.tot_hiv3),Space(5)+'0',Str(m.tot_hiv3, 6, 0)) + "   Unknown/Unreported (affected)" 
		Insert Into cadr_tmp From Memvar
Use in t_hivc

** Total # of undupl. clients 
		m.total = m.tot_hiv1 + m.tot_hiv2 + m.tot_hiv3 + m.tot_indet
		m.group   = Space(48) + Iif(Isnull(m.total), Space(5)+'0',Str(m.total, 6, 0)) + "   Total" 
		Insert Into cadr_tmp From Memvar
      
		m.tothivpos=TRAN(m.tot_hiv1,'999999')
		m.tothivneg=TRAN(m.tot_hiv2,'999999')
		m.tothivunk=TRAN(m.tot_hiv3,'999999')
		m.tothivtot=TRAN(m.total,'999999')
		m.tothivind=TRAN(m.tot_indet,'999999')		
		m.sect2all=m.total
Release m.total, m.tot_hiv1, m.tot_hiv2, m.tot_hiv3, m.tot_indet

*---Q24 
*** Clients do not require enrollment - new
If Used('t_newin')
   Use In t_newin
Endif
   
	Select Distinct all_hiv.tc_id,  ;
					all_hiv.hivstatus, ;
					all_hiv.hiv_pos;
	From 	all_hiv, ;
		  	ai_clien ;
	Where all_hiv.enr_req = .f. and ;
			all_hiv.tc_id = ai_clien.tc_id and ;
			between(ai_clien.placed_dt, dStartDate, dEndDate);
	Into Cursor	t_newin

*** Client's do not require enrollment - contin
If Used('t_cont')
   Use In t_cont
Endif

	Select Distinct all_hiv.tc_id  ;
	From 	all_hiv, ;
			ai_clien ;
	Where all_hiv.enr_req = .f. and ;
			all_hiv.tc_id = ai_clien.tc_id and ;
			ai_clien.placed_dt < dStartDate ;
	Into Cursor	t_cont

*** Client's require enrollment - contin
If Used('t_contpr')
   Use In t_contpr
Endif

	Select Distinct all_hiv.tc_id  ;
	From all_hiv, ;
		ai_prog ;
	Where all_hiv.enr_req = .t. and ;
			ai_prog.tc_id = all_hiv.tc_id and ;
			ai_prog.program = all_hiv.prog_id and ;
			(ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			ai_prog.start_dt < dStartDate and ;
			all_hiv.tc_id Not In (Select tc_id From t_cont)    ; 
	Into Cursor	t_contpr	
   
*** Client's require enrollment - new
If Used('t_temp')
   Use In t_temp
Endif

	Select Distinct all_hiv.tc_id,  ;
					all_hiv.hivstatus, ;
					all_hiv.hiv_pos;
	From all_hiv, ;
		ai_prog ;
	Where all_hiv.enr_req = .t. and ;
			ai_prog.tc_id = all_hiv.tc_id and ;
			ai_prog.program = all_hiv.prog_id and ;
			(ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			between(ai_prog.start_dt, dStartDate, dEndDate) ;
	Into Cursor t_temp

If Used('t_newpr')
   Use In t_newpr
Endif
	
	Select * ;
	From t_temp ;
	Where ; 		
			t_temp.tc_id Not In (Select tc_id From t_cont) and ;
			t_temp.tc_id Not In (Select tc_id From t_contpr) ;
	Into Cursor	t_newpr	
	
	Use in t_temp
	Use in t_cont
	Use in t_contpr
   
*** Combine to one
If Used('t_new')
   Use In t_new
Endif

	Select * ;
	From t_newin ;
	Union ;
	Select * ;
	From t_newpr ;
	Into Cursor t_new

	Use in t_newin
	Use in t_newpr
	
	m.part = ""
	m.group   = "24.  Total Number of new clients: " 
	m.info = 24
	Insert Into cadr_tmp From Memvar

If Used('t_newindet')
   Use In t_newindet
Endif

	Select tc_id ;
	From t_new ;
	Where tc_id ;
		In (Select tc_id From t_indet) ;
	Into Cursor ;
		t_newindet

** Total # of new clients HIV+ only
		Select Count(Distinct tc_id) as tot_hivc ;
		From t_new ;
		Where hiv_pos = .t. ;
		and tc_id Not In (Select tc_id From t_newindet) ;
		Into Cursor t_hivc 

		Select t_hivc
		Sum tot_hivc to m.tot_hiv1 
		
	m.group   = Space(48) + Iif(Isnull(m.tot_hiv1), Space(5)+'0', Str(m.tot_hiv1, 6, 0)) + "   HIV-positive only " 
	Insert Into cadr_tmp From Memvar
	Use in t_hivc

		Select Count(Distinct tc_id) as tot_hivc ;
		From t_new ;
		Where tc_id In (Select tc_id From t_newindet) ;
		Into Cursor t_hivc 

		Select t_hivc
		Sum tot_hivc to m.tot_indet
		
	m.group   = Space(48) + Iif(Isnull(m.tot_indet), Space(5)+'0',Str(m.tot_indet, 6, 0)) + "   HIV indeterminate (under age 2)" 
	Insert Into cadr_tmp From Memvar
	Use in t_hivc

** Total # of new clients HIV-negative
		Select Count(Distinct tc_id) as tot_hivc ;
		From t_new ;
		Where (hivstatus = "06" or ;
			hivstatus = "07" or ;
			hivstatus = "08" or ;
			hivstatus = "09") ;
		and tc_id Not In (Select tc_id From t_newindet) ;
		Into Cursor t_hivc 

		Select t_hivc
		Sum tot_hivc to m.tot_hiv2 
				
	m.group   = Space(48) + Iif(Isnull(m.tot_hiv2), Space(5)+'0',Str(m.tot_hiv2, 6, 0)) + "   HIV-negative (affected)" 
	Insert Into cadr_tmp From Memvar
	Use in t_hivc

** Total # of new clients Unknown
		Select Count(Distinct tc_id) as tot_hivc ;
		From t_new ;
		Where (hivstatus = "12" or ;
			hivstatus = "04") ;
		and tc_id Not In (Select tc_id From t_newindet) ;	
		Into Cursor t_hivc 

		Select t_hivc
		Sum tot_hivc to m.tot_hiv3 
		
	m.group   = Space(48) + Iif(Isnull(m.tot_hiv3), Space(5)+'0',Str(m.tot_hiv3, 6, 0)) + "   Unknown/Unreported (affected)" 
	Insert Into cadr_tmp From Memvar
	Use in t_hivc

	m.total = m.tot_hiv1 + m.tot_hiv2 + m.tot_hiv3 + m.tot_indet
	m.group   = Space(48) + Iif(Isnull(m.total), Space(5)+'0',Str(m.total, 6, 0)) + "   Total" 
	Insert Into cadr_tmp From Memvar
	
		m.newhivpos=TRAN(m.tot_hiv1,'999999')
		m.newhivneg=TRAN(m.tot_hiv2,'999999')
		m.newhivunk=TRAN(m.tot_hiv3,'999999')
		m.newhivtot=TRAN(m.total,'999999')
		m.newhivind=TRAN(m.tot_indet,'999999')
Release m.total, m.tot_hiv1, m.tot_hiv2, m.tot_hiv3, m.tot_indet

*---Q25 Gender
	m.part = ""
	m.group   = "25.  Gender:                      " 
	m.info = 25	
	Insert Into cadr_tmp From Memvar
   m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

If Used('all_gen')
   Use In all_gen
Endif

	Select Distinct tc_id, hiv_pos, gender, hivstatus ;
	From all_hiv ;
	Into Cursor all_gen
	
**	HIV+  
If Used('t_gen')
   Use In t_gen
Endif

		Select  ;
				Sum(Iif(gender='11',1, 0)) as tot_mal1, ;
				Sum(Iif(gender='10',1, 0)) as tot_fem1, ;
				Sum(Iif((gender = '12' or gender = '13'),1,0)) as tot_tr1, ;				
				Sum(iif(Empty(gender), 1, 0)) as tot_un1, ;
				Count(*) as total1 ;
		From all_gen ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_gen

**	HIV affected 
If Used('t_gena')
   Use In t_gena
Endif
 
		Select  ;
				Sum(Iif(gender='11',1, 0)) as tot_mal2, ;
				Sum(Iif(gender='10',1, 0)) as tot_fem2, ;
				Sum(Iif((gender = '12' or gender = '13'),1,0)) as tot_tr2, ;				
				Sum(iif(Empty(gender), 1, 0)) as tot_un2, ;
				Count(*) as total2 ;
		From all_gen ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;		
		Into Cursor t_gena

		m.group   = Space(16) + "Male" + Space(36) + ;
                  Iif(Isnull(t_gen.tot_mal1),Space(5)+'0',Str(t_gen.tot_mal1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_gena.tot_mal2), Space(5)+'0',Str(t_gena.tot_mal2, 6, 0))
		Insert Into cadr_tmp From Memvar
					
		m.group   = Space(16) + "Female" + Space(34) + ;
                  Iif(Isnull(t_gen.tot_fem1), Space(5)+'0',Str(t_gen.tot_fem1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_gena.tot_fem2),Space(5)+'0',Str(t_gena.tot_fem2, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Transgender" + Space(29) + ;
                  Iif(Isnull(t_gen.tot_tr1), Space(5)+'0',Str(t_gen.tot_tr1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_gena.tot_tr2), Space(5)+'0', Str(t_gena.tot_tr2, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
                  Iif(Isnull(t_gen.tot_un1), Space(5)+'0',Str(t_gen.tot_un1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_gena.tot_un2), Space(5)+'0',Str(t_gena.tot_un2, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Total" + Space(35) + ;
                  Iif(Isnull(t_gen.total1), Space(5)+'0',Str(t_gen.total1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_gena.total2), Space(5)+'0',Str(t_gena.total2, 6, 0))
		Insert Into cadr_tmp From Memvar
		m.malepos  =TRAN(t_gen.tot_mal1 ,'999999')
		m.femalepos=TRAN(t_gen.tot_fem1 ,'999999')
		m.transpos =TRAN(t_gen.tot_tr1 ,'999999')
		m.genunkpos=TRAN(t_gen.tot_un1 ,'999999')
		m.gentotpos=TRAN(t_gen.total1 ,'999999')
		m.maleaff  =TRAN(t_gena.tot_mal2 ,'999999')
		m.femaleaff=TRAN(t_gena.tot_fem2 ,'999999')
		m.transaff =TRAN(t_gena.tot_tr2 ,'999999')
		m.genunkaff=TRAN(t_gena.tot_un2 ,'999999')
		m.gentotaff=TRAN(t_gena.total2 ,'999999')

Use in t_gen
Use in t_gena
Use in all_gen

*----Q26  Age
	m.part = ""
	m.group   = "26.  Age (at the end of reporting period):" 
	m.info = 26	
	Insert Into cadr_tmp From Memvar
	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

If Used('all_age')
   Use In all_age
Endif

	Select Distinct tc_id, hiv_pos, cl_age, dob, hivstatus ;
	From all_hiv ;
	Into Cursor all_age
	
**	HIV+  
If Used('t_agep')
   Use In t_agep
Endif

		Select  ;
				Sum(Iif((cl_age < 2 and !Empty(dob)), 1, 0)) as tot_y1, ;
				Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_y3, ;
				Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_y5, ;
				Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_y7, ;
				Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_y9, ;
				Sum(iif(cl_age >= 65, 1, 0)) as tot_y11, ;
				Sum(iif(Empty(dob), 1, 0)) as tot_y13, ;
				Count(*) as total1 ;
		From all_age ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_agep

**	HIV affected  
If Used('t_agea')
   Use In t_agea
Endif

		Select  ;
				Sum(Iif((cl_age < 2 and !Empty(dob)), 1, 0)) as tot_y2, ;
				Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_y4, ;
				Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_y6, ;
				Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_y8, ;
				Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_y10, ;
				Sum(iif(cl_age >= 65, 1, 0)) as tot_y12, ;
				Sum(iif(Empty(dob), 1, 0)) as tot_y14, ;
				Count(*) as total2 ;
		From all_age ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_agea

		m.group   = Space(16) + "Less than 2 years" + Space(23) + ;
                  Iif(Isnull(t_agep.tot_y1), Space(5)+'0',Str(t_agep.tot_y1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.tot_y2), Space(5)+'0',Str(t_agea.tot_y2, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "2 - 12 years     " + Space(23) + ;
                  Iif(Isnull(t_agep.tot_y3), Space(5)+'0',Str(t_agep.tot_y3, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.tot_y4), Space(5)+'0',Str(t_agea.tot_y4, 6, 0))
		Insert Into cadr_tmp From Memvar
					
		m.group   = Space(16) + "13 - 24 years    " + Space(23) + ;
                  Iif(Isnull(t_agep.tot_y5), Space(5)+'0', Str(t_agep.tot_y5, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.tot_y6), Space(5)+'0',Str(t_agea.tot_y6, 6, 0))
		Insert Into cadr_tmp From Memvar
					
		m.group   = Space(16) + "25 - 44 years    " + Space(23) + ;
                  Iif(Isnull(t_agep.tot_y7), Space(5)+'0',Str(t_agep.tot_y7, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.tot_y8), Space(5)+'0',Str(t_agea.tot_y8, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "45 - 64 years    " + Space(23) + ;
                  Iif(Isnull(t_agep.tot_y9), Space(5)+'0',Str(t_agep.tot_y9, 6, 0)) + Space(22) + ; 
                  Iif(Isnull(t_agea.tot_y10), Space(5)+'0',Str(t_agea.tot_y10, 6, 0))
		Insert Into cadr_tmp From Memvar
					
		m.group   = Space(16) + "65 years or older" + Space(23) + ;
                  Iif(Isnull(t_agep.tot_y11), Space(5)+'0',Str(t_agep.tot_y11, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.tot_y12), Space(5)+'0',Str(t_agea.tot_y12, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
                  Iif(Isnull(t_agep.tot_y13), Space(5)+'0',Str(t_agep.tot_y13, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.tot_y14), Space(5)+'0',Str(t_agea.tot_y14, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Total" + Space(35) + ;
                  Iif(Isnull(t_agep.total1), Space(5)+'0',Str(t_agep.total1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_agea.total2), Space(5)+'0',Str(t_agea.total2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.aless2pos =TRAN(t_agep.tot_y1 ,'999999')
		m.a212pos   =TRAN(t_agep.tot_y3 ,'999999')
		m.a1324pos  =TRAN(t_agep.tot_y5 ,'999999')
		m.a2544pos  =TRAN(t_agep.tot_y7 ,'999999')
		m.a4564pos  =TRAN(t_agep.tot_y9 ,'999999')
		m.a65pluspos=TRAN(t_agep.tot_y11,'999999')
		m.aunkpos   =TRAN(t_agep.tot_y13,'999999')
		m.atotpos   =TRAN(t_agep.total1 ,'999999')
		m.aless2aff =TRAN(t_agea.tot_y2 ,'999999')
		m.a212aff   =TRAN(t_agea.tot_y4 ,'999999')
		m.a1324aff  =TRAN(t_agea.tot_y6 ,'999999')
		m.a2544aff  =TRAN(t_agea.tot_y8 ,'999999')
		m.a4564aff  =TRAN(t_agea.tot_y10,'999999')
		m.a65plusaff=TRAN(t_agea.tot_y12,'999999')
		m.aunkaff   =TRAN(t_agea.tot_y14,'999999')
		m.atotaff   =TRAN(t_agea.total2 ,'999999')

Use in t_agep
Use in t_agea
Use in all_age

*---Q27 Race/Ethnicity
*!*   	m.part = ""
*!*   	m.group   = "27.  Race/Ethnicity:" 
*!*   	m.info = 27	
*!*   	Insert Into cadr_tmp From Memvar

*!*   	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
*!*   					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
*!*      				"                ------------------                   -------------           -----------------"

*!*   	Insert Into cadr_tmp From Memvar

If Used('all_race')
   Use In all_race
Endif
	
	Select Distinct tc_id, hiv_pos, ;
			white, blafrican, hispanic, asian, ;
			hawaisland, indialaska, unknowrep, someother, hivstatus ;
	From all_hiv ;
	Into Cursor all_race

*!*  HIV+/Indterm for Hispanic | Non-Hispanic
*!*  2008 RDR PB: 
**	HIV+  
If Used('t_raceph')
   Use In t_raceph
Endif
   *!* Hispanic
	Select  ;
			Sum(Iif(hispanic=2 and white = 1      and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r1, ;
			Sum(Iif(hispanic=2 and blafrican = 1  and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r3, ;
			Sum(Iif(hispanic=2 and asian = 1      and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r5, ;
			Sum(Iif(hispanic=2 and hawaisland = 1 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r7, ;
			Sum(Iif(hispanic=2 and indialaska = 1 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r9, ;
			Sum(Iif(hispanic=2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r11, ;
			Sum(Iif(hispanic=2 and (((unknowrep = 1 or someother = 1) and white + blafrican + asian + hawaisland + indialaska = 0)  ;
											or (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska = 0)), 1, 0)) as tot_r13,;
			Count(*) as total1 ;
	From all_race ;
	Where hispanic=2 ;
      And (hiv_pos = .t. Or tc_id In (Select tc_id From t_indet Where hispanic=2)) ;
	Into Cursor t_raceph


If Used('t_racep')
   Use In t_racep
Endif
   *!* Non-Hispanic
   Select  ;
         Sum(Iif(hispanic<>2 and white = 1      and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r1, ;
         Sum(Iif(hispanic<>2 and blafrican = 1  and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r3, ;
         Sum(Iif(hispanic<>2 and asian = 1      and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r5, ;
         Sum(Iif(hispanic<>2 and hawaisland = 1 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r7, ;
         Sum(Iif(hispanic<>2 and indialaska = 1 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r9, ;
         Sum(Iif(hispanic<>2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r11, ;
         Sum(Iif(hispanic<>2 and (((unknowrep = 1 or someother = 1) and white + blafrican + asian + hawaisland + indialaska = 0)  ;
                                 or (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska = 0)), 1, 0)) as tot_r13, ;            
         Count(*) as total1 ;
   From all_race ;
   Where hispanic<>2 ;
         And (hiv_pos = .t. Or tc_id In (Select tc_id From t_indet Where hispanic <> 2));
   Into Cursor t_racep

   m.part = ""
   m.info = 27

   m.group = "27.  Race/Ethnicity:" +Chr(13)+ ;
             " a. HIV-positive/indeterminate"
   Insert Into cadr_tmp From Memvar

   m.group = "                Number of clients:                   Hispanic                Non-Hispanic     " +CHR(13)+ ;
             "                ------------------                   -------------           -----------------"
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "American Indian or Alaskan Native" + Space(7) + ;
               Iif(Isnull(t_raceph.tot_r9), Space(5)+'0',Str(t_raceph.tot_r9, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racep.tot_r9), Space(5)+'0',Str(t_racep.tot_r9, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Asian" + Space(35) + ;
               Iif(Isnull(t_raceph.tot_r5), Space(5)+'0',Str(t_raceph.tot_r5, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racep.tot_r5), Space(5)+'0',Str(t_racep.tot_r5, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Black or African American         " + Space(6) + ;
               Iif(Isnull(t_raceph.tot_r3), Space(5)+'0',Str(t_raceph.tot_r3, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racep.tot_r3), Space(5)+'0',Str(t_racep.tot_r3, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Native Hawaiian/Pacific Islander" + Space(8) + ;
               Iif(Isnull(t_raceph.tot_r7), Space(5)+'0',Str(t_raceph.tot_r7, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racep.tot_r7), Space(5)+'0',Str(t_racep.tot_r7, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "White               " + Space(20) + ;
               Iif(Isnull(t_raceph.tot_r1), Space(5)+'0',Str(t_raceph.tot_r1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racep.tot_r1), Space(5)+'0',Str(t_racep.tot_r1, 6, 0))
   Insert Into cadr_tmp From Memvar
   
   m.group   = Space(16) + "More than one race" + Space(22) + ;
               Iif(Isnull(t_raceph.tot_r11), Space(5)+'0',Str(t_raceph.tot_r11, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racep.tot_r11), Space(5)+'0',Str(t_racep.tot_r11, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.tot_r13=0
   m.tot_r14=0

   *!* Not reported Hispanic
   If (t_raceph.tot_r1 + t_raceph.tot_r3 + t_raceph.tot_r5 + t_raceph.tot_r7 + t_raceph.tot_r9 + t_raceph.tot_r11 + t_raceph.tot_r13) <> t_raceph.total1
       m.tot_r13 = t_raceph.total1 - (t_raceph.tot_r1 + t_raceph.tot_r3 + t_raceph.tot_r5 + t_raceph.tot_r7 + t_raceph.tot_r9 + t_raceph.tot_r11)
   Else
       m.tot_r13 = t_raceph.tot_r13
   Endif

   *!* Not reported Non-Hispanic
   If (t_racep.tot_r1 + t_racep.tot_r3 + t_racep.tot_r5 + t_racep.tot_r7 + t_racep.tot_r9 + t_racep.tot_r11 + t_racep.tot_r13) <> t_racep.total1
       m.tot_r14 = t_racep.total1 - (t_racep.tot_r1 + t_racep.tot_r3 + t_racep.tot_r5 + t_racep.tot_r7 + t_racep.tot_r9 + t_racep.tot_r11)
   Else
       m.tot_r14 = t_racep.tot_r13
   Endif
   
*!*   If (t_racea.tot_r2 + t_racea.tot_r4 + t_racea.tot_r6 + t_racea.tot_r8 + t_racea.tot_r10 + t_racea.tot_r12 + t_racea.tot_r14 + t_racea.tot_r16) <> t_racea.total2
*!*      m.tot_r14 = t_racea.total2 - (t_racea.tot_r2 + t_racea.tot_r4 + t_racea.tot_r6 + t_racea.tot_r8 + t_racea.tot_r10 + t_racea.tot_r12 + t_racea.totr16)
*!*   Else
*!*      m.tot_r14 = t_racea.tot_r14
*!*   Endif
   
   m.group = Space(16) + "Not reported      " + Space(22) + ;
             Iif(Isnull(m.tot_r13), Space(5)+'0',Str(m.tot_r13, 6, 0)) + Space(22) + ;
             Iif(Isnull(m.tot_r14), Space(5)+'0',Str(m.tot_r14, 6, 0))
   Insert Into cadr_tmp From Memvar
   
   m.group = Space(16) + "Total" + Space(35) + ;
             Iif(Isnull(t_raceph.total1), Space(5)+'0',Str(t_raceph.total1, 6, 0)) + Space(22) + ;
             Iif(Isnull(t_racep.total1), Space(5)+'0',Str(t_racep.total1, 6, 0))
   Insert Into cadr_tmp From Memvar
   
*!* HIV affected
If Used('t_racea')
   Use In t_racea
EndIf

   *!* Hispanic
   Select  ;
         Sum(Iif(hispanic=2 and white = 1      and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r2, ;
         Sum(Iif(hispanic=2 and blafrican = 1  and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r4, ;
         Sum(Iif(hispanic=2 and asian = 1      and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r6, ;
         Sum(Iif(hispanic=2 and hawaisland = 1 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r8, ;
         Sum(Iif(hispanic=2 and indialaska = 1 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r10, ;
         Sum(Iif(hispanic=2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r12, ;
         Sum(Iif(hispanic=2 and (((unknowrep = 1 or someother = 1) and white + blafrican + asian + hawaisland + indialaska = 0)  ;
                                 or (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska = 0)), 1, 0)) as tot_r14, ;            
         Count(*) as total2 ;
   From all_race ;
   Where hispanic=2 ;
      And (hivstatus = "06" or ;
           hivstatus = "07" or ;
           hivstatus = "08" or ;
           hivstatus = "09" or ;
           hivstatus = "04" or ;
           hivstatus = "12") ;
      And tc_id Not In (Select tc_id From t_indet Where hispanic=2) ;
   Into Cursor t_raceah

If Used('t_racea')
   Use In t_racea
Endif

   *!* Non-Hispanic
   Select  ;
         Sum(Iif(hispanic<>2 and white = 1      and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r2, ;
         Sum(Iif(hispanic<>2 and blafrican = 1  and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r4, ;
         Sum(Iif(hispanic<>2 and asian = 1      and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r6, ;
         Sum(Iif(hispanic<>2 and hawaisland = 1 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r8, ;
         Sum(Iif(hispanic<>2 and indialaska = 1 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r10, ;
         Sum(Iif(hispanic<>2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r12, ;
         Sum(Iif(hispanic<>2 and (((unknowrep = 1 or someother = 1) and white + blafrican + asian + hawaisland + indialaska = 0)  ;
                                 or (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska = 0)), 1, 0)) as tot_r14, ;
         Count(*) as total2 ;
   From all_race ;
   Where hispanic<>2 ;
      And(hivstatus = "06" or ;
         hivstatus = "07" or ;
         hivstatus = "08" or ;
         hivstatus = "09" or ;
         hivstatus = "04" or ;
         hivstatus = "12") ;
      And tc_id Not In (Select tc_id From t_indet Where hispanic <>2) ;       
   Into Cursor t_racea

   m.page_ej=10
   m.group = " b. HIV-affected"
   Insert Into cadr_tmp From Memvar

   m.group = "                Number of clients:                   Hispanic                Non-Hispanic     " +CHR(13)+ ;
             "                ------------------                   -------------           -----------------"
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "American Indian or Alaskan Native" + Space(7) + ;
               Iif(Isnull(t_raceah.tot_r10), Space(5)+'0',Str(t_raceah.tot_r10, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.tot_r10), Space(5)+'0',Str(t_racea.tot_r10, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Asian" + Space(35) + ;
               Iif(Isnull(t_raceah.tot_r6), Space(5)+'0',Str(t_raceah.tot_r6, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.tot_r6), Space(5)+'0',Str(t_racea.tot_r6, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Black or African American         " + Space(6) + ;
               Iif(Isnull(t_raceah.tot_r4), Space(5)+'0',Str(t_raceah.tot_r4, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.tot_r4), Space(5)+'0',Str(t_racea.tot_r4, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Native Hawaiian/Pacific Islander" + Space(8) + ;
               Iif(Isnull(t_raceah.tot_r8), Space(5)+'0',Str(t_raceah.tot_r8, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.tot_r8), Space(5)+'0',Str(t_racea.tot_r8, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "White               " + Space(20) + ;
               Iif(Isnull(t_raceah.tot_r2), Space(5)+'0',Str(t_raceah.tot_r2, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.tot_r2), Space(5)+'0',Str(t_racea.tot_r2, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "More than one race" + Space(22) + ;
               Iif(Isnull(t_raceah.tot_r12), Space(5)+'0',Str(t_raceah.tot_r12, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.tot_r12), Space(5)+'0',Str(t_racea.tot_r12, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.tot_r15 = 0
   m.tot_r16 = 0

   *!* Not Reported Hispanic
   If (t_raceah.tot_r2 + t_raceah.tot_r4 + t_raceah.tot_r6 + t_raceah.tot_r8 + t_raceah.tot_r10 + t_raceah.tot_r12 + t_raceah.tot_r14) <> t_raceah.total2
       m.tot_r15 = t_raceah.total2 - (t_raceah.tot_r2 + t_raceah.tot_r4 + t_raceah.tot_r6 + t_raceah.tot_r8 + t_raceah.tot_r10 + t_raceah.tot_r12)
   Else
       m.tot_r15 = t_raceah.tot_r14
   Endif

   *!* Not Reported Non-Hispanic
   If (t_racea.tot_r2 + t_racea.tot_r4 + t_racea.tot_r6 + t_racea.tot_r8 + t_racea.tot_r10 + t_racea.tot_r12 + t_racea.tot_r14) <> t_racea.total2
       m.tot_r16 = t_racea.total2 - (t_racea.tot_r2 + t_racea.tot_r4 + t_racea.tot_r6 + t_racea.tot_r8 + t_racea.tot_r10 + t_racea.tot_r12)
   Else
       m.tot_r16 = t_racea.tot_r14
   Endif

   m.group   = Space(16) + "Not reported      " + Space(22) + ;
               Iif(Isnull(m.tot_r15), Space(5)+'0',Str(m.tot_r15, 6, 0)) + Space(22) + ;
               Iif(Isnull(m.tot_r16), Space(5)+'0',Str(m.tot_r16, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Total" + Space(35) + ;
               Iif(Isnull(t_raceah.total2), Space(5)+'0',Str(t_raceah.total2, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_racea.total2), Space(5)+'0',Str(t_racea.total2, 6, 0))
   Insert Into cadr_tmp From Memvar

   *!* Non Hispanic
   *!*  m.whitepos   =TRAN(t_racep.tot_r1 ,'999999')
   *!*  m.blackpos   =TRAN(t_racep.tot_r3 ,'999999')
   *!*  m.asianpos   =TRAN(t_racep.tot_r5 ,'999999')
   *!*  m.nativepos  =TRAN(t_racep.tot_r7 ,'999999')
   *!*  m.indianpos  =TRAN(t_racep.tot_r9 ,'999999')
   *!*  m.multipos   =TRAN(t_racep.tot_r11,'999999')
   *!*  m.unkracpos  =TRAN(m.tot_r14,'999999')
   *!*  m.racetotpos =TRAN(t_racep.total1 ,'999999')

   *!*  m.whiteaff   =TRAN(t_racea.tot_r2 ,'999999')
   *!*  m.blackaff   =TRAN(t_racea.tot_r4 ,'999999')
   *!*  m.asianaff   =TRAN(t_racea.tot_r6 ,'999999')
   *!*  m.nativeaff  =TRAN(t_racea.tot_r8 ,'999999')
   *!*  m.indianaff  =TRAN(t_racea.tot_r10,'999999')
   *!*  m.multiaff   =TRAN(t_racea.tot_r12,'999999')
   *!*  m.unkracaff  =TRAN(m.tot_r16,'999999')
   *!*  m.racetotaff =TRAN(t_racea.total2 ,'999999')

   *!*  PB: 12/17/2008 Changed formatting per request
   m.whitepos=Transform(Iif(Empty(Nvl(t_racep.tot_r1,0)),0,t_racep.tot_r1),'999999')
   m.blackpos=Transform(Iif(Empty(Nvl(t_racep.tot_r3,0)),0,t_racep.tot_r3),'999999')
   m.asianpos=Transform(Iif(Empty(Nvl(t_racep.tot_r5,0)),0,t_racep.tot_r5),'999999')
   m.nativepos=Transform(Iif(Empty(Nvl(t_racep.tot_r7,0)),0,t_racep.tot_r7),'999999')
   m.indianpos=Transform(Iif(Empty(Nvl(t_racep.tot_r9,0)),0,t_racep.tot_r9),'999999')
   m.multipos=Transform(Iif(Empty(Nvl(t_racep.tot_r11,0)),0,t_racep.tot_r11),'999999')
   m.unkracpos=Transform(Iif(Empty(Nvl(m.tot_r14,0)),0,m.tot_r14),'999999')
   m.racetotpos=Transform(Iif(Empty(Nvl(t_racep.total1,0)),0,t_racep.total1),'999999')
   
   m.whiteaff=Transform(Iif(Empty(Nvl(t_racea.tot_r2,0)),0,t_racea.tot_r2),'999999')
   m.blackaff=Transform(Iif(Empty(Nvl(t_racea.tot_r4,0)),0,t_racea.tot_r4),'999999')
   m.asianaff=Transform(Iif(Empty(Nvl(t_racea.tot_r6,0)),0,t_racea.tot_r6),'999999')
   m.nativeaff=Transform(Iif(Empty(Nvl(t_racea.tot_r8,0)),0,t_racea.tot_r8),'999999')
   m.indianaff=Transform(Iif(Empty(Nvl(t_racea.tot_r10,0)),0,t_racea.tot_r10),'999999')
   m.multiaff=Transform(Iif(Empty(Nvl(t_racea.tot_r12,0)),0,t_racea.tot_r12),'999999')
   m.unkracaff=Transform(Iif(Empty(Nvl(m.tot_r16,0)),0,m.tot_r16),'999999')
   m.racetotaff=Transform(Iif(Empty(Nvl(t_racea.total2,0)),0,t_racea.total2),'999999')

   *!* Send spaces; not collected in 2008
   m.hisppos=Space(06)
   m.hispaff=Space(06)
   
   *!* Hispanic
   *!*  m.HWHITEPS=Transform(t_raceph.tot_r1 ,'999999')  
   *!*  m.HBLACKPS=Transform(t_raceph.tot_r3 ,'999999')
   *!*  m.HASIANPS=Transform(t_raceph.tot_r5 ,'999999')  
   *!*  m.HNATIVEPS=Transform(t_raceph.tot_r7 ,'999999') 
   *!*  m.HINDIANPS=Transform(t_raceph.tot_r9 ,'999999') 
   *!*  m.HMULTIPS=Transform(t_raceph.tot_r11 ,'999999') 
   *!*  m.HUNKRACPS=Transform(m.tot_r13,'999999')
   *!*  m.HRACETOTPS=Transform(t_raceph.total1 ,'999999') 

   *!*  m.HWHITEAF=Transform(t_raceah.tot_r2 ,'999999')
   *!*  m.HBLACKAF=Transform(t_raceah.tot_r4 ,'999999')
   *!*  m.HASIANAF=Transform(t_raceah.tot_r6 ,'999999')
   *!*  m.HNATIVEAF=Transform(t_raceah.tot_r8 ,'999999')
   *!*  m.HINDIANAF=Transform(t_raceah.tot_r10 ,'999999')
   *!*  m.HMULTIAF=Transform(t_raceah.tot_r12 ,'999999')
   *!*  m.HUNKRACAF=Transform(m.tot_r15,'999999')
   *!*  m.HRACETOTAF=Transform(t_raceah.total2 ,'999999')

   *!*  PB: 12/16/2008 Changed formatting per request
   m.HWHITEPS= Transform(Iif(Empty(Nvl(t_raceph.tot_r1,0)),0,t_raceph.tot_r1),'999999')
   m.HBLACKPS= Transform(Iif(Empty(Nvl(t_raceph.tot_r3,0)),0,t_raceph.tot_r3),'999999')
   m.HASIANPS= Transform(Iif(Empty(Nvl(t_raceph.tot_r5,0)),0,t_raceph.tot_r5),'999999')
   m.HNATIVEPS=Transform(Iif(Empty(Nvl(t_raceph.tot_r7,0)),0,t_raceph.tot_r7),'999999')
   m.HINDIANPS=Transform(Iif(Empty(Nvl(t_raceph.tot_r9,0)),0,t_raceph.tot_r9),'999999')
   m.HMULTIPS= Transform(Iif(Empty(Nvl(t_raceph.tot_r11,0)),0,t_raceph.tot_r11),'999999')
   m.HUNKRACPS=Transform(Iif(Empty(Nvl(m.tot_r13,0)),0,m.tot_r13),'999999')
   m.HRACETOTPS=Transform(Iif(Empty(Nvl(t_raceph.total1,0)),0,t_raceph.total1),'999999')

   m.HWHITEAF=Transform(Iif(Empty(Nvl(t_raceah.tot_r2,0)),0,t_raceah.tot_r2),'999999')
   m.HBLACKAF=Transform(Iif(Empty(Nvl(t_raceah.tot_r4,0)),0,t_raceah.tot_r4),'999999')
   m.HASIANAF=Transform(Iif(Empty(Nvl(t_raceah.tot_r6,0)),0,t_raceah.tot_r6),'999999')
   m.HNATIVEAF=Transform(Iif(Empty(Nvl(t_raceah.tot_r8,0)),0,t_raceah.tot_r8),'999999')
   m.HINDIANAF=Transform(Iif(Empty(Nvl(t_raceah.tot_r10,0)),0,t_raceah.tot_r10),'999999')
   m.HMULTIAF=Transform(Iif(Empty(Nvl(t_raceah.tot_r12,0)),0,t_raceah.tot_r12),'999999')
   m.HUNKRACAF=Transform(Iif(Empty(Nvl(m.tot_r15,0)),0,m.tot_r15),'999999')
   m.HRACETOTAF=Transform(Iif(Empty(Nvl(t_raceah.total2,0)),0,t_raceah.total2),'999999')

Use in t_racep
Use in t_raceph
Use In t_racea
Use In t_raceah
Use in all_race

*---Q28 Household Income
    *** For transfer to  next page
*   m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) 
   m.group   = " " + CHR(13) + " " + CHR(13) 
	m.info = 28
	Insert Into cadr_tmp From Memvar
		
	m.part = ""
	m.group   = "28.  Household income (at the end of reporting period):" 
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

If Used('t_housx')
   Use In t_housx
Endif


	Select Distinct all_hiv.tc_id, all_hiv.hiv_pos, all_hiv.hivstatus, ;
			all_hiv.is_refus, all_hiv.hshld_incm, all_hiv.hshld_size, ;
			poverty.pov_level;
	From all_hiv, poverty, address ;
	Where  all_hiv.client_id = address.client_id and ;
			Iif((address.st <> "AK" or address.st <> "HI"), poverty.st = "US", address.st = poverty.st) and ;
			poverty.pov_year = LEFT(DTOS(dEndDate),4) and ;
			poverty.hshld_size = all_hiv.hshld_size and ;
			all_hiv.is_refus = .f. ;
	Union ;
	Select Distinct all_hiv.tc_id, all_hiv.hiv_pos, all_hiv.hivstatus, ;
			all_hiv.is_refus, all_hiv.hshld_incm, all_hiv.hshld_size, ;
			000000 as pov_level ;
	From all_hiv ;
	Where all_hiv.hshld_size = 0 or all_hiv.is_refus = .t. ;
	Into Cursor t_housx
	
If Used('t_housrest')
   Use In t_housrest
Endif


	Select Distinct all_hiv.tc_id, all_hiv.hiv_pos, all_hiv.hivstatus, ;
			all_hiv.is_refus, 00000000 as hshld_incm, 00 as hshld_size, ;
			000000 as pov_level ;
	From all_hiv ;
	Where all_hiv.tc_id Not in (Select tc_id from t_housx) ;
	Into Cursor ;
		t_housrest	

     

If Used('t_hous')
   Use In t_hous
Endif
	
	Select * From t_housx ;
	Union ;
	Select * From t_housrest ;
	Into Cursor ;
		t_hous	
		
	Use in t_housx
	Use in t_housrest	
	
If Used('all_hous')
   Use In all_hous
Endif

	Select * , ;
			Iif(pov_level = 0 , 000000, (hshld_incm * 100/pov_level)) as t_incm ; 
	From t_hous ;
	Into Cursor all_hous
	
	Use in t_hous

**	HIV+  
If Used('t_housp')
   Use In t_housp
Endif

		Select  ;
				Sum(Iif((t_incm <= 100 and is_refus =.f. and hshld_size > 0), 1, 0)) as tot_i1, ;
				Sum(Iif(Between(t_incm, 101, 200), 1, 0)) as tot_i3, ;
				Sum(Iif(Between(t_incm, 201, 300), 1, 0)) as tot_i5, ;
				Sum(Iif(t_incm > 300, 1, 0)) as tot_i7, ;
				Sum(Iif((is_refus or hshld_size = 0), 1, 0)) as tot_i9, ;
				Count(*) as total1 ;
		From all_hous ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_housp
		
**	HIV affected  
If Used('t_housa')
   Use In t_housa
Endif

		Select  ;
				Sum(Iif((t_incm <= 100 and is_refus =.f. and hshld_size > 0), 1, 0)) as tot_i2, ;
				Sum(Iif(Between(t_incm, 101, 200), 1, 0)) as tot_i4, ;
				Sum(Iif(Between(t_incm, 201, 300), 1, 0)) as tot_i6, ;
				Sum(Iif(t_incm > 300, 1, 0)) as tot_i8, ;
				Sum(Iif((is_refus or hshld_size = 0), 1, 0)) as tot_i10, ;
				Count(*) as total2 ;
		From all_hous ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_housa
	
		m.group   = Space(16) + "= or below the Fed. poverty line" + Space(8) + ;
                  Iif(Isnull(t_housp.tot_i1), Space(5)+'0',Str(t_housp.tot_i1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_i2), Space(5)+'0',Str(t_housa.tot_i2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "101-200% of Federal poverty line" + Space(8) + ;
                  Iif(Isnull(t_housp.tot_i3), Space(5)+'0',Str(t_housp.tot_i3, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_i4), Space(5)+'0',Str(t_housa.tot_i4, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "201-300% of Federal poverty line" + Space(8) + ;
                  Iif(Isnull(t_housp.tot_i5), Space(5)+'0',Str(t_housp.tot_i5, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_i6), Space(5)+'0',Str(t_housa.tot_i6, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "> 300% of Federal poverty line" + Space(10) + ;
                  Iif(Isnull(t_housp.tot_i7), Space(5)+'0',Str(t_housp.tot_i7, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_i8), Space(5)+'0',Str(t_housa.tot_i8, 6, 0)) 
		Insert Into cadr_tmp From Memvar
		
		If (t_housp.tot_i1 + t_housp.tot_i3 + t_housp.tot_i5 + t_housp.tot_i7 + t_housp.tot_i9) <> t_housp.total1
		
				m.tot_i9 = t_housp.total1 - (t_housp.tot_i1 + t_housp.tot_i3 + t_housp.tot_i5 + t_housp.tot_i7)
		Else
				m.tot_i9 = t_housp.tot_i9
		Endif

		If (t_housa.tot_i2 + t_housa.tot_i4 + t_housa.tot_i6 + t_housa.tot_i8 + t_housa.tot_i10) <> t_housa.total2
		
				m.tot_i10 = t_housa.total2 - (t_housa.tot_i2 + t_housa.tot_i4 + t_housa.tot_i6 + t_housa.tot_i8)
		Else
				m.tot_i10 = t_housa.tot_i10
		Endif
		
		m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
                  Iif(Isnull(m.tot_i9), Space(5)+'0',Str(m.tot_i9, 6, 0)) + Space(22) + ;
                  Iif(Isnull(m.tot_i10), Space(5)+'0',Str(m.tot_i10, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Total" + Space(35) + ;
                  Iif(Isnull(t_housp.total1), Space(5)+'0',Str(t_housp.total1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.total2), Space(5)+'0',Str(t_housa.total2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.inceqpos   =TRAN(t_housp.tot_i1 ,'999999')
		m.inc101pos  =TRAN(t_housp.tot_i3 ,'999999')
		m.inc201pos  =TRAN(t_housp.tot_i5 ,'999999')
		m.inc301pos  =TRAN(t_housp.tot_i7 ,'999999')
		m.incunkpos  =TRAN(m.tot_i9 ,'999999')
		m.inctotpos  =TRAN(t_housp.total1 ,'999999')
		m.inceqaff   =TRAN(t_housa.tot_i2 ,'999999')
		m.inc101aff  =TRAN(t_housa.tot_i4 ,'999999')
		m.inc201aff  =TRAN(t_housa.tot_i6 ,'999999')
		m.inc301aff  =TRAN(t_housa.tot_i8 ,'999999')
		m.incunkaff  =TRAN(m.tot_i10,'999999')
		m.inctotaff  =TRAN(t_housa.total2 ,'999999')

Use in t_housa
Use in t_housp		
Use in all_hous		

*---Q29 Housing
	m.part = ""
	m.group   = "29.  Housing/living arrangement (at the end of reporting period):" 
	m.info = 29	
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar
   
If Used('all_hous')
   Use In all_hous
Endif
   
	Select Distinct tc_id, hiv_pos, housing, hivstatus ;
	From all_hiv ;
	Into Cursor all_hous
	
**	HIV+  
If Used('t_housp')
   Use In t_housp
Endif
		Select  ;
				Sum(Iif((housing = "10" or housing = "11"), 1, 0)) as tot_h1, ;
				Sum(Iif((housing = "01" or housing = "02" or housing = "03" or housing = "12"), 1, 0)) as tot_h3, ;
				Sum(Iif((housing = "04" or housing = "05" or housing = "06" or housing = "07" or ;
						housing = "08" or housing = "09"),1, 0)) as tot_h5, ;
				Sum(Iif(Empty(housing) or ;
						(housing <> "10" and housing <> "11" and ;
						housing <> "01" and housing <> "02" and  ;
						housing <> "03" and housing <> "12" and ;
						housing <> "04" and housing <> "05" and ;
						housing <> "06" and housing <> "07" and ;
						housing <> "08" and housing <> "09"), 1, 0)) as tot_h9, ;
				Count(*) as total1 ;
		From all_hous ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_housp

**	HIV affected  
If Used('t_housa')
   Use In t_housa
Endif
		Select  ;
				Sum(Iif((housing = "10" or housing = "11"), 1, 0)) as tot_h2, ;
				Sum(Iif((housing = "01" or housing = "02" or housing = "03" or housing = "12"), 1, 0)) as tot_h4, ;
				Sum(Iif((housing = "04" or housing = "05" or housing = "06" or housing = "07" or ;
						housing = "08" or housing = "09"),1, 0)) as tot_h6, ;
				Sum(Iif(Empty(housing) or ;
						(housing <> "10" and housing <> "11" and ;
						housing <> "01" and housing <> "02" and  ;
						housing <> "03" and housing <> "12" and ;
						housing <> "04" and housing <> "05" and ;
						housing <> "06" and housing <> "07" and ;
						housing <> "08" and housing <> "09"), 1, 0)) as tot_h10, ;
				Count(*) as total2 ;
		From all_hous ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_housa

		m.group   = Space(16) + "Permanently housed" + Space(22) + ;
                  Iif(Isnull(t_housp.tot_h1), Space(5)+'0',Str(t_housp.tot_h1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_h2), Space(5)+'0',Str(t_housa.tot_h2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "Non-permanently housed" + Space(18) + ;
                  Iif(Isnull(t_housp.tot_h3), Space(5)+'0',Str(t_housp.tot_h3, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_h4), Space(5)+'0',Str(t_housa.tot_h4, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "Institution" + Space(29) + ;
                  Iif(Isnull(t_housp.tot_h5), Space(5)+'0',Str(t_housp.tot_h5, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_h6), Space(5)+'0',Str(t_housa.tot_h6, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "Other" + Space(40) + "0" + Space(27) + "0"
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
                  Iif(Isnull(t_housp.tot_h9), Space(5)+'0',Str(t_housp.tot_h9, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.tot_h10), Space(5)+'0',Str(t_housa.tot_h10, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Total" + Space(35) + ;
                  Iif(Isnull(t_housp.total1), Space(5)+'0',Str(t_housp.total1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_housa.total2), Space(5)+'0',Str(t_housa.total2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.permpos   =TRAN(t_housp.tot_h1 ,'999999')
		m.nonpermpos=TRAN(t_housp.tot_h3 ,'999999')
		m.instpos   =TRAN(t_housp.tot_h5 ,'999999')
		m.housothpos=TRAN(0 ,'999999')
		m.housunkpos=TRAN(t_housp.tot_h9 ,'999999')
		m.houstotpos=TRAN(t_housp.total1 ,'999999')
		m.permaff   =TRAN(t_housa.tot_h2 ,'999999')
		m.nonpermaff=TRAN(t_housa.tot_h4 ,'999999')
		m.instaff   =TRAN(t_housa.tot_h6 ,'999999')
		m.housothaff=TRAN(0 ,'999999')
		m.housunkaff=TRAN(t_housa.tot_h10,'999999')
		m.houstotaff=TRAN(t_housa.total2 ,'999999')

Use in t_housp
Use in t_housa
Use in all_hous

*----Q30  Medical
	m.part = ""
	m.group   = "30.  Medical Insurance (at the end of reporting period):" 
	m.info = 30	
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar
	
If Used('all_m1')
   Use In all_m1
Endif

	Select  Distinct all_hiv.tc_id, all_hiv.hiv_pos, med_prov.instype, all_hiv.insurance, all_hiv.hivstatus ;
	From all_hiv, insstat, med_prov ;
	Where all_hiv.client_id = insstat.client_id and ;
			insstat.prim_sec = 1 and ;
			Dtos(insstat.effect_dt) + insstat.insstat_id + insstat.client_id  In ;
										(Select Max(Dtos(f2.effect_dt) + f2.insstat_id) + f2.client_id ;
										From ;
											insstat f2 ;
										Where ;
											f2.prim_sec = 1 and ;
											f2.effect_dt <= dEndDate and (f2.exp_dt >= dStartDate or EMPTY(f2.exp_dt)) ;
											Group by f2.client_id) and ;
			insstat.prov_id = med_prov.prov_id ;
	Into Cursor all_m1
	
If Used('all_med')
   Use In all_med
Endif

	Select * ;
	From all_m1 ;
	Union ;
	Select tc_id, hiv_pos, Space(2) as instype, insurance, hivstatus ;
	From all_hiv ;
	Where all_hiv.tc_id Not in (Select Distinct tc_id From all_m1) ; 
	Into Cursor all_med										
	
*** Hiv + 
If Used('t_medp')
   Use In t_medp
Endif
		Select Sum(Iif((instype = "04" or instype = "05" or instype = "11" or instype = "12"), 1, 0)) as tot_m1, ;
		       Sum(Iif(instype = "03", 1, 0)) as tot_m3, ;
				 Sum(Iif((instype = "01" or instype = "02"),1, 0)) as tot_m5, ;
				 Sum(Iif((instype = "08" or instype = "07" or instype = "10"), 1, 0)) as tot_m7, ;
				 Sum(Iif((instype = "06" or instype = "09" or (EMPTY(instype) and insurance = 3)) , 1, 0)) as tot_m9, ;
				 Sum(Iif(instype = "99", 1, 0)) as tot_m11, ;
				 Sum(Iif((Empty(instype) and insurance = 2) or ;
				  		 (Empty(instype) and insurance = 0) or ;
					 	 (Empty(instype) and insurance = 1) or ;
						 !Empty(instype) and !Inlist(instype, "01", "02", "03", "04", "05",  ;
										"06", "07", "08", "09", "10",  ; 
										"11", "12", "99"), 1, 0)) as tot_m13, ;
				Count(*) as total1 ;
		From all_med ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_medp

**	HIV affected  
If Used('t_meda')
   Use In t_meda
Endif
		Select  ;
				Sum(Iif((instype = "04" or instype = "05" or instype = "11" or instype = "12"), 1, 0)) as tot_m2, ;
				Sum(Iif(instype = "03", 1, 0)) as tot_m4, ;
				Sum(Iif((instype = "01" or instype = "02"),1, 0)) as tot_m6, ;
				Sum(Iif((instype = "08" or instype = "07" or instype = "10"), 1, 0)) as tot_m8,;
				Sum(Iif((instype = "06" or instype = "09" or (Empty(instype) and insurance = 3)), 1, 0)) as tot_m10, ;
				Sum(Iif(instype = "99", 1, 0)) as tot_m12, ;
				Sum(Iif((Empty(instype) and insurance = 2) or ;
						(Empty(instype) and insurance = 0) or ;
						(Empty(instype) and insurance = 1) or ;
						!Empty(instype) and !Inlist(instype, "01", "02", "03", "04", "05",  ;
										"06", "07", "08", "09", "10",  ; 
										"11", "12", "99"), 1, 0)) as tot_m14, ;
				Count(*) as total2 ;
		From all_med ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_meda
												
		m.group   = Space(16) + "Private" + Space(33) + ;
                  Iif(Isnull(t_medp.tot_m1), Space(5)+'0',Str(t_medp.tot_m1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.tot_m2), Space(5)+'0',Str(t_meda.tot_m2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "Medicare" + Space(32) + ;
                  Iif(Isnull(t_medp.tot_m3), Space(5)+'0',Str(t_medp.tot_m3, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.tot_m4), Space(5)+'0',Str(t_meda.tot_m4, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Medicaid" + Space(32) + ;
                  Iif(Isnull(t_medp.tot_m5), Space(5)+'0',Str(t_medp.tot_m5, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.tot_m6), Space(5)+'0',Str(t_meda.tot_m6, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Other public" + Space(28) + ;
                  Iif(Isnull(t_medp.tot_m7), Space(5)+'0',Str(t_medp.tot_m7, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.tot_m8), Space(5)+'0',Str(t_meda.tot_m8, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "No insurance" + Space(28) + ;
                  Iif(Isnull(t_medp.tot_m9), Space(5)+'0',Str(t_medp.tot_m9, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.tot_m10), Space(5)+'0',Str(t_meda.tot_m10, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "Other" + Space(35) + ;
                  Iif(Isnull(t_medp.tot_m11), Space(5)+'0', Str(t_medp.tot_m11, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.tot_m12), Space(5)+'0',Str(t_meda.tot_m12, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		If (t_medp.tot_m1 + t_medp.tot_m3 + t_medp.tot_m5 + t_medp.tot_m7 + t_medp.tot_m9 + t_medp.tot_m11 + t_medp.tot_m13) <> t_medp.total1
			m.tot_m13 = t_medp.total1 - (t_medp.tot_m1 + t_medp.tot_m3 + t_medp.tot_m5 + t_medp.tot_m7 + t_medp.tot_m9 + t_medp.tot_m11)
			IF m.tot_m13 < 0
				m.tot_m13 = 0
			ENDIF
		Else
			m.tot_m13 = t_medp.tot_m13
		Endif
		
		If (t_meda.tot_m2 + t_meda.tot_m4 + t_meda.tot_m6 + t_meda.tot_m8 + t_meda.tot_m10 + t_meda.tot_m12 + t_meda.tot_m14) <> t_meda.total2
			m.tot_m14 = t_meda.total2 - (t_meda.tot_m2 + t_meda.tot_m4 + t_meda.tot_m6 + t_meda.tot_m8 + t_meda.tot_m10 + t_meda.tot_m12)
			IF m.tot_m14 < 0
				m.tot_m14 = 0
			ENDIF
		Else
			m.tot_m14 = t_meda.tot_m14
		Endif
		
		m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
                  Iif(Isnull(m.tot_m13), Space(5)+'0', Str(m.tot_m13, 6, 0)) + Space(22) + ;
                  Iif(Isnull(m.tot_m14), Space(5)+'0', Str(m.tot_m14, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Total" + Space(35) + ;
                  Iif(Isnull(t_medp.total1), Space(5)+'0',Str(t_medp.total1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_meda.total2), Space(5)+'0',Str(t_meda.total2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.privpos   =TRAN(t_medp.tot_m1 ,'999999')
		m.mcarepos  =TRAN(t_medp.tot_m3 ,'999999')
		m.mcaidpos  =TRAN(t_medp.tot_m5 ,'999999')
		m.pubpos    =TRAN(t_medp.tot_m7 ,'999999')
		m.nonepos   =TRAN(t_medp.tot_m9 ,'999999')
		m.insothpos =TRAN(t_medp.tot_m11,'999999')
		m.insunkpos =TRAN(t_medp.tot_m13,'999999')
		m.instotpos =TRAN(t_medp.total1 ,'999999')
		m.privaff   =TRAN(t_meda.tot_m2 ,'999999')
		m.mcareaff  =TRAN(t_meda.tot_m4 ,'999999')
		m.mcaidaff  =TRAN(t_meda.tot_m6 ,'999999')
		m.pubaff    =TRAN(t_meda.tot_m8 ,'999999')
		m.noneaff   =TRAN(t_meda.tot_m10,'999999')
		m.insothaff =TRAN(t_meda.tot_m12,'999999')
		m.insunkaff =TRAN(t_meda.tot_m14,'999999')
		m.instotaff =TRAN(t_meda.total2 ,'999999')

Use in t_medp
Use in t_meda
Use in all_m1											
Use in all_med

*----Q31 HIV/AIDS Status
	m.part = ""
	m.group   = "31.  HIV/AIDS status (at the end of reporting period):" 
	m.info = 31	
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

If Used('all_stat')
   Use In all_stat
Endif
	Select  Distinct tc_id, hiv_pos, hivstatus;
	From all_hiv ;
	Into Cursor all_stat
	
If Used('all_stat1')
   Use In all_stat1
Endif
	Select  Distinct tc_id, hiv_pos, hivstatus;
	From all_hiv ;
	Where tc_id NOT IN (Select tc_id From t_indet) ;
	Into Cursor all_stat1
	
If Used('all_stat2')
   Use In all_stat2
Endif
	Select  Distinct tc_id, hiv_pos, hivstatus;
	From all_hiv ;
	Where tc_id IN (Select tc_id From t_indet) ;
	Into Cursor all_stat2
   
If Used('all_stat3')
   Use In all_stat3
Endif
	Select  Distinct tc_id, hiv_pos, hivstatus;
	From all_hiv ;
	Where hiv_pos=.t. ;
	or tc_id IN (Select tc_id From t_indet) ;
	Into Cursor all_stat3
	
*** Hiv + 
If Used('t_statp')
   Use In t_statp
Endif
		Select Sum(Iif(hivstatus = "01", 1, 0)) as tot_s1, ;
				Sum(Iif(hivstatus = "02" or hivstatus = "05", 1, 0)) as tot_s3, ;
				Sum(Iif(hivstatus = "10", 1, 0)) as tot_s5, ;
				Sum(Iif(hivstatus = "06" or hivstatus = "07" or hivstatus = "08" or hivstatus = "09", 1, 0)) as tot_s7, ;
				Sum(Iif((hivstatus = "04" or hivstatus = "12"), 1, 0)) as tot_s9, ;
				Count(*) as total1 ;
		From all_stat1 ;
		Where hiv_pos = .t. ;
		Into Cursor t_statp
		
If Used('t_posind')
   Use In t_posind
Endif

   	Select Count(*) as total1 ;
		From all_stat3 ;
		Into Cursor t_posind

If Used('t_statind')
   Use In t_statind
Endif

		Select Count(*) as totalind ;
		From all_stat2 ;
		Into Cursor t_statind
		
If Used('t_stata')
   Use In t_stata
Endif
**	HIV affected  
		Select  ;
				Sum(Iif(hivstatus = "01", 1, 0)) as tot_s2, ;
				Sum(Iif(hivstatus = "02" or hivstatus = "05", 1, 0)) as tot_s4, ;
				Sum(Iif(hivstatus = "10", 1, 0)) as tot_s6, ;
				Sum(Iif(hivstatus = "06" or hivstatus = "07" or hivstatus = "08" or hivstatus = "09", 1, 0)) as tot_s8, ;
				Sum(Iif((hivstatus = "04" or hivstatus = "12"), 1, 0)) as tot_s10, ;
				Count(*) as total2 ;
		From all_stat1 ;
		Where hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12" ;
		Into Cursor t_stata

		m.group   = Space(16) + "HIV-positive, not AIDS" + Space(18) + ;
                  Iif(Isnull(t_statp.tot_s1), Space(5)+'0',Str(t_statp.tot_s1, 6, 0)) + Space(22) + Repl('±', 6)
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "HIV-pos., AIDS status unknown" + Space(11) + ;
                  Iif(Isnull(t_statp.tot_s3), Space(5)+'0',Str(t_statp.tot_s3, 6, 0)) + Space(22) + Repl('±', 6)
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "CDC-defined AIDS" + Space(24) + ;
                  Iif(Isnull(t_statp.tot_s5), Space(5)+'0',Str(t_statp.tot_s5, 6, 0)) + Space(22) + Repl('±', 6)
		Insert Into cadr_tmp From Memvar

		m.group   = Space(16) + "HIV indeterminate" + Space(23) + ;
                  Iif(Isnull(t_statind.totalind), Space(5)+'0',Str(t_statind.totalind, 6, 0)) + Space(22) + Repl('±', 6)
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "HIV-neg. (affected clients only)" + Space(8) + Repl('±', 6) + Space(22) + ;
                  Iif(Isnull(t_stata.tot_s8), Space(5)+'0',Str(t_stata.tot_s8, 6, 0)) 		
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Unknown/Unreported" + Space(22) + Repl('±', 6) + Space(22) + ;
                  Iif(Isnull(t_stata.tot_s10), Space(5)+'0',Str(t_stata.tot_s10, 6, 0))
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(16) + "Total" + Space(35) + ;
                  Iif(Isnull(t_posind.total1), Space(5)+'0',Str(t_posind.total1, 6, 0)) + Space(22) + ;
                  Iif(Isnull(t_stata.total2), Space(5)+'0',Str(t_stata.total2, 6, 0))
		Insert Into cadr_tmp From Memvar

		m.hposnotaid =TRAN(t_statp.tot_s1 ,'999999')
		m.hposunk    =TRAN(t_statp.tot_s3 ,'999999')
		m.aids       =TRAN(t_statp.tot_s5 ,'999999')
		m.hnegaff    =TRAN(t_stata.tot_s8 ,'999999')
		m.statunk    =TRAN(t_stata.tot_s10,'999999')
		m.stattotpos =TRAN(t_posind.total1 ,'999999')
		m.stattotaff =TRAN(t_stata.total2 ,'999999')
		m.hivindet	 =TRAN(t_statind.totalind, '999999')		

Use in t_statp
Use in t_stata
Use in all_stat 

*----Q32  Client Enrollment Status
    *** For transfer to  next page
*!*      m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) 
**   m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) 

	m.info = 32
*	Insert Into cadr_tmp From Memvar
	m.part = ""
	m.group   = "32.  Client's vital/enroll. status (at the end of reporting period):" 
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

*-------------Deceased at the end of rep. per.
If Used('all_dec')
   Use In all_dec
Endif

	Select  Distinct all_hiv.tc_id, hiv_pos, hivstatus;
	From all_hiv,  ;
		ai_activ ;
	Where all_hiv.tc_id = ai_activ.tc_id and ;
			ai_activ.close_code = '10' and ;
			Iif(!Empty(ai_activ.death_dt), ai_activ.death_dt <= dEndDate, ai_activ.effect_dt <= dEndDate and ;
			ai_activ.tc_id + Dtos(ai_activ.effect_dt) in ;
					(Select tc_id + Max(Dtos(effect_dt)) ;
						From ai_activ ;
						Where ;	
							effect_dt <= dEndDate ;
						Group By ;
								tc_id)) ;  	
	Into Cursor all_dec
	
*-------Inactive at the end of rep. per. in Agency
If Used('all_clos')
   Use In all_clos
Endif

	Select  Distinct all_hiv.tc_id, hiv_pos, hivstatus;
	From all_hiv,  ;
		ai_activ ;
	Where all_hiv.tc_id = ai_activ.tc_id and ;
			ai_activ.close_code <> '10' and ;
			trim(ai_activ.status) = "C" and ;
			ai_activ.effect_dt <= dEndDate and ;
			ai_activ.tc_id + Dtos(ai_activ.effect_dt) in ;
					(Select tc_id + Max(Dtos(effect_dt)) ;
						From ai_activ ;
						Where ;	
							effect_dt <= dEndDate ;
						Group By ;
								tc_id)  and ;
			all_hiv.tc_id not in (Select tc_id From all_dec) ;					 
	Into Cursor all_clos

*---All Active clients 
If Used('all_act')
   Use In all_act
Endif

	Select Distinct all_hiv.tc_id,  ;
					all_hiv.hivstatus, ;
					all_hiv.hiv_pos, ;
					all_hiv.enr_req, ;
					all_hiv.prog_id ;
	From all_hiv ;
	Where 	all_hiv.tc_id Not In (Select tc_id From all_dec) and ;
			all_hiv.tc_id Not In (Select tc_id From all_clos) ; 
	Into Cursor	all_act

*-- Active Client's (Continuing) do not require enrollment	
If Used('all_ac1')
   Use In all_ac1
Endif

	Select Distinct all_act.tc_id,  ;
			all_act.hivstatus, ;
			all_act.hiv_pos ;
	From all_act, ;
			ai_clien ; 
	Where all_act.enr_req = .f. and ;
			all_act.tc_id = ai_clien.tc_id and ;
			ai_clien.placed_dt < dStartDate ;
	Into Cursor all_ac1		

*-- Active Client's (New) do not require enrollment	
If Used('all_an1')
   Use In all_an1
Endif

	Select Distinct all_act.tc_id,  ;
			all_act.hivstatus, ;
			all_act.hiv_pos ;
	From all_act, ;
			ai_clien ; 
	Where all_act.enr_req = .f. and ;
			all_act.tc_id = ai_clien.tc_id and ;
			between(ai_clien.placed_dt, dStartDate, dEndDate);
	Into Cursor all_an1				
	
*----- Active in Program enroll req (excl from not req enr)
If Used('prg_min')
   Use In prg_min
Endif

	Select tc_id, program, Min(start_dt) as start_dt ;
	From ai_prog ;
	Group by tc_id, program ;
	Into Cursor prg_min
	
If Used('prg_old')
   Use In prg_old
Endif

	Select all_hiv.tc_id ;
	From all_hiv, ;
			prg_min, ;
			program ;
	Where program.prog_id=prg_min.program ;
	  and program.enr_req ;
	  and prg_min.program=all_hiv.prog_id ;
	  and prg_min.tc_id=all_hiv.tc_id ;
	  and prg_min.start_dt<dStartDate ;
	Into Cursor prg_old  

If Used('activepr')
   Use In activepr
Endif
	
	Select  Distinct all_act.tc_id, ;
			all_act.prog_id, ;
			prg_min.start_dt, ;
			ai_prog.end_dt, ;
			all_act.hivstatus, ;
			all_act.hiv_pos ;
	From all_act,  ;
		ai_prog, ;
		prg_min ;
	Where all_act.tc_id = ai_prog.tc_id and ;
			all_act.prog_id = ai_prog.program and ;
			all_act.enr_req = .t. and ;
			(Empty(ai_prog.end_dt) or ai_prog.end_dt > dEndDate) and ;
			prg_min.tc_id = ai_prog.tc_id and ;
			prg_min.program = ai_prog.program and ;
			prg_min.start_dt < dEndDate and ;
			all_act.tc_id Not In (Select tc_id From all_ac1) and ;
			all_act.tc_id Not In (Select tc_id From all_an1)  ; 
	Into Cursor activepr
	
	Use in prg_min
   
*-- Active in Program (Contin) require enrollment (before report period)	
If Used('prg_con')
   Use In prg_con
Endif	

	Select Distinct tc_id,  ;
			hivstatus, ;
			hiv_pos ;
	From activepr ;
	Where ((Empty(end_dt) or end_dt > dEndDate) and ;
			(tc_id + prog_id + Dtos(start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt))  ;
									From ai_prog ;
									Group by tc_id, program) and ;
			start_dt < dStartDate) ;
	      or (tc_id IN (Select tc_id From prg_old)) ;		
		Into Cursor prg_con

	Use in prg_old
				
*-- Active Client's (New) require enrollment	
If Used('prg_new')
   Use In prg_new
Endif

	Select Distinct tc_id,  ;
					hivstatus, ;
					hiv_pos ;
	From activepr ;
	Where (tc_id + prog_id + Dtos(start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			between(start_dt, dStartDate, dEndDate) and ;
			(Empty(end_dt) or end_dt > dEndDate) and ;
			tc_id Not In (Select tc_id From prg_con) ;
	Into Cursor prg_new
	
*------Inactive in program 
If Used('prg_in1')
   Use In prg_in1
Endif

	Select  Distinct all_act.tc_id, all_act.hiv_pos, all_act.hivstatus;
	From all_act, ;
		ai_prog ;
	Where all_act.tc_id = ai_prog.tc_id and ;
			all_act.prog_id = ai_prog.program and ;
			all_act.enr_req = .t. and ;
			!Empty(ai_prog.end_dt) and ;
			ai_prog.end_dt <= dEndDate and ;
			ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt) IN ;
						(Select prog.tc_id + prog.program + Max(Dtos(prog.start_dt)) ;
							From ai_prog prog;
							Where ;
								prog.start_dt <= dEndDate ;
							Group By ;
								prog.tc_id, prog.program)  ;
	Into Cursor prg_in1
								
	*-- Excl not req enrol from inactive 
If Used('prg_in2')
   Use In prg_in2
Endif

	Select * ;
	From prg_in1 ;
	Where tc_id Not In (Select tc_id From all_ac1) and ;
			tc_id Not In (Select tc_id From all_an1)  ;
	Into Cursor prg_in2
	
	Use in prg_in1
	* --Excl from active enr req
If Used('prg_inac')
   Use In prg_inac
Endif
	
	Select * ;
	From prg_in2 ;
	Where tc_id Not In (Select tc_id From activepr) ;
	Into Cursor prg_inac
	
	Use in prg_in2
	
*---Combine all inactive	
If Used('all_ina')
   Use In all_ina
Endif

	Select * ;
	From all_clos ;
	Union ;
	Select * ;
	From prg_inac ;
	Into Cursor all_ina
	
	Use in prg_inac
	Use in all_clos

*-- Combine active new to program
If Used('act_n2pr')
   Use In act_n2pr
Endif

	Select * ;
	From prg_new ;
	Union ;
	Select * ;
	From all_an1 ;
	Into Cursor act_n2pr
	
	Use in prg_new
	Use in all_an1

*-- Combine active contin in program
If Used('act_cnpr')
   Use In act_cnpr
Endif

	Select * ;
	From all_ac1;
	Union ;
	Select * ;
	From prg_con ;
	Into Cursor act_cnpr
	
	Use in prg_con
	USe in all_ac1

*--Active new to program HIV positive only	
If Used('t_actp')
   Use In t_actp
Endif
		Select	Count(*) as total ;
		From act_n2pr ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_actp
		
*--Active new to program HIV affected  
If Used('t_acta')
   Use In t_acta
Endif

		Select Count(*) as total ;
		From act_n2pr ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_acta

	m.group   = Space(16) + "Active, client new to program" + Space(11) + ;
               Iif(Isnull(t_actp.total), Space(5)+'0',Str(t_actp.total, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_acta.total), Space(5)+'0',Str(t_acta.total, 6, 0))
	Insert Into cadr_tmp From Memvar

*--Active cont. in program HIV positive only	
If Used('t_conp')
   Use In t_conp
Endif

		Select	Count(*) as total ;
		From act_cnpr ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_conp
		
*--Active cont. in program HIV affected  
If Used('t_cona')
   Use In t_cona
Endif

		Select Count(*) as total ;
		From act_cnpr ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_cona
		
	m.group   = Space(16) + "Active, client cont. in program" + Space(9) + ;
               Iif(Isnull(t_conp.total), Space(5)+'0',Str(t_conp.total, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_cona.total), Space(5)+'0',Str(t_cona.total, 6, 0))
	Insert Into cadr_tmp From Memvar
  	
*--Deceased HIV positive only	
If Used('t_decp')
   Use In t_decp
Endif

		Select	Count(*) as total ;
		From all_dec ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_decp
		
*--Deceased HIV affected  
If Used('t_deca')
   Use In t_deca
Endif

		Select Count(*) as total ;
		From all_dec ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_deca
	
	m.group   = Space(16) + "Deceased" + Space(32) + ;
               Iif(Isnull(t_decp.total), Space(5)+'0', Str(t_decp.total, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_deca.total), Space(5)+'0', Str(t_deca.total, 6, 0))
	Insert Into cadr_tmp From Memvar
	
*--Inactive HIV positive only	
If Used('t_inap')
   Use In t_inap
Endif

		Select	Count(*) as total ;
		From all_ina ;
		Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet) ;
		Into Cursor t_inap
		
*--Inactive	HIV affected  
If Used('t_inaa')
   Use In t_inaa
Endif

		Select Count(*) as total ;
		From all_ina ;
		Where (hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
		and tc_id Not In (Select tc_id From t_indet) ;
		Into Cursor t_inaa
	
	m.group   = Space(16) + "Inactive" + Space(32) + ;
               Iif(Isnull(t_inap.total), Space(5)+'0',Str(t_inap.total, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_inaa.total), Space(5)+'0',Str(t_inaa.total, 6, 0))
	Insert Into cadr_tmp From Memvar
	
*--Combine to one
If Used('t_all')
   Use In t_all
Endif

	Select distinct tc_id, hiv_pos, hivstatus ;
	From act_n2pr ;
	Union ;
	Select distinct tc_id, hiv_pos, hivstatus ;
	From act_cnpr ;
	Union ;
	Select distinct tc_id, hiv_pos, hivstatus ;
	From all_dec ;
	Union ;
	Select distinct tc_id, hiv_pos, hivstatus ;
	From all_ina ;
	Into Cursor t_all
   
If Used('t_allp')
   Use In t_allp
Endif

	Select * ;
	From t_all ;
	Where hiv_pos = .t. ;
	or tc_id in (Select tc_id From t_indet) ;
	Into Cursor t_allp

If Used('t_hiv')
   Use In t_hiv
Endif
	 
	Select distinct tc_id, hiv_pos, hivstatus ;
	From all_hiv ;
	Into Cursor t_hiv

If Used('t_hivp')
   Use In t_hivp
Endif

	Select * ;
	From t_hiv ;
	Where hiv_pos = .t. ;
	or tc_id in (Select tc_id From t_indet) ;
	Into Cursor t_hivp
	
*--Unknown/Unreported HIV positive
If Used('t_unkp')
   Use In t_unkp
Endif

	Select Count(*) as total;
	From t_hivp ;
	Where tc_id not in (select tc_id from t_allp) ;
	Into Cursor t_unkp		
	
*--Unknown/Unreported HIV affected
If Used('t_all1')
   Use In t_all1
Endif

	Select distinct tc_id ;
	From t_all ;
	Where (hivstatus = "06" or ;
		hivstatus = "07" or ;
		hivstatus = "08" or ;
		hivstatus = "09" or ;
		hivstatus = "04" or ;
		hivstatus = "12")  ;
	and tc_id Not In (Select tc_id From t_indet) ;	
	Into Cursor t_all1
		
If Used('t_hiv1')
   Use In t_hiv1
Endif

	Select distinct tc_id ;
	From t_hiv ;
 	Where 	(hivstatus = "06" or ;
				hivstatus = "07" or ;
				hivstatus = "08" or ;
				hivstatus = "09" or ;
				hivstatus = "04" or ;
				hivstatus = "12") ;
	and tc_id Not In (Select tc_id From t_indet) ;	
	Into Cursor t_hiv1	

If Used('t_allunk')
   Use In t_allunk
Endif
	
	Select tc_id ;
	From t_hiv1 ;
	Where tc_id not in (select tc_id from t_all1) ;
	Into cursor t_allunk

If Used('t_unka')
   Use In t_unka
Endif
	
	Select Count(*) as total;
	From t_allunk ;
	Into Cursor t_unka		
	
	m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
               Iif(Isnull(t_unkp.total), Space(5)+'0',Str(t_unkp.total, 6, 0)) + Space(22) + ;
               Iif(Isnull(t_unka.total), Space(5)+'0',Str(t_unka.total, 6, 0))
	Insert Into cadr_tmp From Memvar
			
	m.totalp = t_decp.total + t_inap.total + t_actp.total + t_conp.total + t_unkp.total
	m.totala = t_deca.total + t_inaa.total + t_acta.total + t_cona.total + t_unka.total
	m.group   = Space(16) + "Total" + Space(35) + ;
               Iif(Isnull(m.totalp), Space(5)+'0',Str(m.totalp, 6, 0)) + Space(22) + ;
               Iif(Isnull(m.totala), Space(5)+'0',Str(m.totala, 6, 0))
	Insert Into cadr_tmp From Memvar
	
		m.actnewpos =TRAN(t_actp.total ,'999999')
		m.actnewaff =TRAN(t_acta.total ,'999999')
		m.actconpos =TRAN(t_conp.total ,'999999')
		m.actconaff =TRAN(t_cona.total ,'999999')
		m.actdecpos =TRAN(t_decp.total ,'999999')
		m.actdecaff =TRAN(t_deca.total ,'999999')
		m.inactpos  =TRAN(t_inap.total ,'999999')
		m.inactaff  =TRAN(t_inaa.total ,'999999')
		m.enrunkpos =TRAN(t_unkp.total ,'999999')
		m.enrunkaff =TRAN(t_unka.total ,'999999')
		m.enrtotpos =TRAN(m.totalp     ,'999999')
		m.enrtotaff =TRAN(m.totala     ,'999999')
		m.totexpadh =SPACE(1)

	Release m.totalp, m.totala	
	Use in t_decp
	Use in t_deca
	Use in all_dec
	Use in t_inap
	Use in t_inaa
	Use in all_ina
	Use in t_actp
	Use in t_acta
	Use in t_conp
	Use in t_cona
	Use in act_cnpr
	Use in act_n2pr
	Use in t_unkp
	Use in t_unka
	Use in t_all
	Use in t_hiv
	Use in t_allp
	Use in t_hivp
	Use in t_hiv1
	Use in t_all1
	Use in t_allunk
return
***************
PROCEDURE sect3
***************
	m.prvid      = agency.aar_id
	m.regcode    = SPACE(5)
	m.prvname1   = TRIM(agency.descript1)+' '+TRIM(agency.descript2)
	m.RecId= LEFT(DTOS(dEndDate),6) + m.PrvID
   Do rpt_cadr_33n
return
***************
PROCEDURE sect4
***************
	m.prvid      = agency.aar_id
	m.regcode    = SPACE(5)
	m.prvname1   = TRIM(agency.descript1)+' '+TRIM(agency.descript2)
   m.RecId= LEFT(DTOS(dEndDate),6) + m.PrvID

If Used('t_prog1')
   Use In t_prog1
Endif
   
	If nScope = 1  && RW Eligible
			Select program.prog_id, program.fund_type, program.elig_type, program.enr_req ;
			From program ;
			Where program.elig_type = "01"  ;
			   or program.elig_type = "02"  ;
			   or (program.elig_type = "03" and ProgExists());
			Into Cursor t_prog1
	Else
		Select * From t_prog Into Cursor t_prog1  && only includes elig_type '01' and '02' as created in Procedure Sect23Prep
	Endif		
   
*** Section 4
* jss, 3/28/05, Q36(2004) becomes Q34(2005)
*--Q34
* jss, 1/9/04, change original question 36 to 36a, add question 36b
	m.section = Space(40) + "SECTION 4.  HIV COUNSELING AND TESTING"
	m.part = ""
   m.group = "34a. Was HIV Counseling and Testing Provided?" +  Space(47) + Iif(cadrserv.hiv_prov = 1, "Yes", " No")  

	m.info = 34
	Insert Into cadr_tmp From Memvar

* jss, 3/28/05, Q34b, change 36b to 34b in cursor names and references below
*                     also, CADR mapping changes from '39' to '37'
* jss, 1/9/04, for 34b (2005), count number of infants (<2 years old)
If Used('tEncAll34b')
   Use In tEncAll34b
Endif
   
	Select Distinct ai_enc.tc_id, client.dob, ai_enc.act_dt ;
		From ai_enc, lv_enc_type, t_prog1, ai_clien, client ;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			Left(lv_enc_type.cadr_map,2) = "37" and ;
			ai_enc.program = t_prog1.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate) and;
			ai_enc.tc_id = ai_clien.tc_id and ;
			ai_clien.client_id = client.client_id ;
		Into Cursor tEncAll34b

If Used('cnt34b')
   Use In cnt34b
Endif
		
	Select Count(*) AS nInfant ;
		From tEncAll34b ;
		Where !EMPTY(dob) AND oApp.AGE(act_dt,Dob) < 2 ;
		Into Cursor cnt34b
		
   m.group = "  b. Total number of infants tested:" +  Space(51) + ;
             Iif(Isnull(cnt34b.nInfant), Space(5)+'0', Str(cnt34b.nInfant, 6, 0))

	Insert Into cadr_tmp From Memvar
	
* define memvar for extract now	
	m.ctnoinfant=TRAN(cnt34b.nInfant,'999999')

	Use in tEncAll34b	
	Use in cnt34b
* jss, 3/28/05, Q37(2004) becomes Q35(2005)
*--Q35
*!*       m.group = "35.  Were RW CARE Act funds used for HIV Counseling and Testing?" + Space(28) + Iif(cadrserv.rw_used = 1, "Yes", " No")
* jss, 11/27/07
    m.group = "35.  Were RW HIV/AIDS Program funds used for HIV Counseling and Testing?" + Space(20) + Iif(cadrserv.rw_used = 1, "Yes", " No")
    m.info = 35
	Insert Into cadr_tmp From Memvar
	
* jss, 3/28/05, Q38(2004) becomes Q36(2005)
*--Q36	
    m.group = "36.  How many individuals received HIV pretest counseling?" + Space(11) + "Confidential" + Space(5) + "Anonymous" + CHR(13) +;
             																Space(69) + "------------" + Space(5) + "---------"
    m.info = 36
	Insert Into cadr_tmp From Memvar	
		
	*** Select All encounters with CADR Map ="38" or "39" (up thru 2004)
	*** jss, 3/28/05, Select All encounters with CADR Map ="36" or "37" (2005)

If Used('tEncAll8')
   Use In tEncAll8
Endif
	
		Select Distinct ai_enc.tc_id, ai_clien.anonymous ;
		From ai_enc, lv_enc_type, t_prog1, ai_clien;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			(Left(lv_enc_type.cadr_map,2) = "36" OR Left(lv_enc_type.cadr_map,2) = "37") and ;
			ai_enc.program = t_prog1.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate) and;
			ai_enc.tc_id = ai_clien.tc_id ;
		Into Cursor tEncAll8

If Used('t_pret')
   Use In t_pret
Endif
		
		Select  ;
				Sum(Iif(anonymous, 1, 0)) as t_a, ;
				Sum(Iif(anonymous = .f., 1, 0)) as t_c ;
		From tEncAll8 ;
		Into Cursor t_pret
      
	If _tally=0 
       m.group   = Space(72) + '0' + Space(14) + '0'
   Else
      m.group   = Space(72) + Iif(Isnull(t_pret.t_c), Space(5)+'0',Str(t_pret.t_c, 6, 0)) + Space(9) + ;
                  Iif(Isnull(t_pret.t_a), Space(5)+'0',Str(t_pret.t_a, 6, 0))
   Endif
      
	Insert Into cadr_tmp From Memvar

	m.ctprov    = IIF(cadrserv.hiv_prov=1, 'Yes', 'No')
	m.rwfundused= IIF(cadrserv.rw_used=1, 'Yes', 'No')
	m.preconf   = TRAN(t_pret.t_c,'999999')
	m.preanon   = TRAN(t_pret.t_a,'999999')

	Use in tEncAll8
	Use in t_pret 

* jss, 3/28/05, Q39(2004) becomes Q37(2005)
*--Q37
	m.group = "37.  How many individuals were tested for HIV antibodies? " + Space(11) + "Confidential" + Space(5) + "Anonymous" + CHR(13) +;
             																Space(69) + "------------" + Space(5) + "---------"
    m.info = 37
	Insert Into cadr_tmp From Memvar	
		
	*** Select All encounters with CADR Map ="39" (thru 2004)
	*** jss, 3/28/05, Select All encounters with CADR Map ="37" (2005)
If Used('tEncAll9')
   Use In tEncAll9
Endif	
	
		Select Distinct ai_enc.tc_id, ai_clien.anonymous ;
		From ai_enc, lv_enc_type, t_prog1, ai_clien;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			Left(lv_enc_type.cadr_map,2) = "37" and ;
			ai_enc.program = t_prog1.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate) and;
			ai_enc.tc_id = ai_clien.tc_id ;
		Into Cursor tEncAll9

If Used('t_ant')
   Use In t_ant
Endif
  		
		Select  ;
				Sum(Iif(anonymous, 1, 0)) as t_a, ;
				Sum(Iif(anonymous = .f., 1, 0)) as t_c ;
		From tEncAll9 ;
		Into Cursor t_ant		
      
	If _tally = 0	
      m.group   = Space(72) + '0' + Space(14) + '0'
   else
	   m.group   = Space(72) + Iif(Isnull(t_ant.t_c), Space(5)+'0',Str(t_ant.t_c, 6, 0)) + Space(9) + ;
                  Iif(Isnull(t_ant.t_a), Space(5)+'0',Str(t_ant.t_a, 6, 0))
   Endif
      
	Insert Into cadr_tmp From Memvar

	m.hivtstconf = TRAN(t_ant.t_c,'999999')
	m.hivtstanon = TRAN(t_ant.t_a,'999999')	
		
	Use in t_ant 

* jss, 3/28/05, Q40(2004) becomes Q38(2005)
*-- Q38
If Used('tEncAll')
   Use In tEncAll
Endif

		Select Distinct ai_enc.act_id, ai_enc.tc_id, ai_clien.anonymous ;
		From ai_enc, lv_enc_type, t_prog1, ai_clien ;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			Left(lv_enc_type.cadr_map,2) = "38" and ;
			ai_enc.program = t_prog1.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate) and ;
			ai_enc.tc_id = ai_clien.tc_id  and ;
			ai_enc.tc_id in (Select tc_id ;
								From tEncAll9) ;
		Into Cursor tEncAll
	
*!*   * jss, 3/28/05, Q42(2004) becomes Q40(2005)
If Used('all_serv')
   Use In all_serv
Endif

		Select	Distinct ai_serv.act_id, ai_serv.tc_id, ai_clien.anonymous ;
		From ai_serv, lv_service, ai_clien ;
		Where ;
				ai_serv.service_id = lv_service.service_id and ;
				!Empty(lv_service.cadr_map) and ;
				Left(lv_service.cadr_map,2) = "40" and ;
				between(ai_serv.date, dStartDate, dEndDate) and;
				ai_serv.tc_id = ai_clien.tc_id and ;
				ai_serv.tc_id in (Select tc_id ;
								From tEncAll9) ;
		Into Cursor all_serv
			
*** Combine Encounters + Services where services with same CADR weren't found				
If Used('t_38')
   Use In t_38
Endif

		Select Distinct tc_id ;
		From all_serv ;
		Union ;
		Select Distinct tc_id ;
		From tEncAll ;
		Where ;
			 Not Exists ;
				(Select * From all_serv ;
				 Where ;
					all_serv.act_id = tEncAll.act_id) ;
		Into Cursor	t_38

If Used('t_3840')
   Use In t_3840
Endif

	Select Count(distinct tc_id) as tot_ind;
	From t_38 ;
	Into cursor t_3840

* jss, 2/28/05, this is now number 38 (2005), was 40 (2004)
	m.group = "38.  How many individuals had a positive test result?"+ Space(34) + ;
             Iif(Isnull(t_3840.tot_ind), Space(5)+'0',Str(t_3840.tot_ind, 6, 0)) 
   m.info = 38
	Insert Into cadr_tmp From Memvar	
	
	m.hiv_pos=TRAN(t_3840.tot_ind,'999999')

	Use in tEncAll
	Use in t_38	
	Use in t_3840
	
* jss, 3/28/05, Q41(2004) becomes Q39(2005)
*--Q39
	m.group = "39.  How many individuals received HIV posttest counseling, " + Space(9) + "Confidential" + Space(5) + "Anonymous" + CHR(13) +;
             "     regardless of test results?                            " + Space(9) + "------------" + Space(5) + "---------"
    m.info = 39 
    Insert Into cadr_tmp From Memvar	
		
*** jss, 3/28/05, Select All encounters with CADR Map ="38" or "39"
If Used('tEncAll39')
   Use In tEncAll39
Endif
	
		Select Distinct ai_enc.tc_id, ai_clien.anonymous ;
		From ai_enc, lv_enc_type, t_prog1, ai_clien;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			(Left(lv_enc_type.cadr_map,2) = "38" or Left(lv_enc_type.cadr_map,2) = "39") and ;
			ai_enc.program = t_prog1.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate) and;
			ai_enc.tc_id = ai_clien.tc_id and ;
			ai_enc.tc_id in (Select tc_id ;
								From tEncAll9) ;
		Into Cursor tEncAll39
      
If Used('t_ant')
   Use In t_ant
Endif
		
		Select  ;
				Sum(Iif(anonymous, 1, 0)) as t_a, ;
				Sum(Iif(anonymous = .f., 1, 0)) as t_c ;
		From tEncAll39 ;
		Into Cursor t_ant	
      	
	If _tally = 0   
      m.group   = Space(72) +'0' + Space(14) + '0'
   else	
	   m.group   = Space(72) + Iif(Isnull(t_ant.t_c), Space(5)+'0',Str(t_ant.t_c, 6, 0)) + Space(9) + ;
                  Iif(Isnull(t_ant.t_a), Space(5)+'0',Str(t_ant.t_a, 6, 0))
   Endif
      
	Insert Into cadr_tmp From Memvar
	
	m.postconf = TRAN(t_ant.t_c,'999999')
	m.postanon = TRAN(t_ant.t_a,'999999')	

	Use in tEncAll39
	Use in t_ant 

* jss, 3/28/05, Q42(2004) becomes Q40(2005)
*--Q40	
If Used('t_40')
   Use In t_40
Endif

	Select Count(distinct tc_id) as tot_ind;
	From all_serv ;
	Into cursor t_40
	
	m.group = "40.  Of those individuals testing HIV positive, how many" + Space(31) + ;
             Iif(Isnull(t_40.tot_ind), Space(5)+'0', Str(t_40.tot_ind, 6, 0))
   m.info = 40
	Insert Into cadr_tmp From Memvar
	m.group = "     did NOT return for HIV posttest counseling?"
	Insert Into cadr_tmp From Memvar

	m.postnoretu = TRAN(t_40.tot_ind,'999999')
	
Use in all_serv	
Use in t_40

* jss, 3/28/05, Q43(2004) becomes Q41a(2005)
*--Q41a
	m.group = "41a. Were Partner Notification Services Offered?" + Space(44) + Iif(cadrserv.serv_off = 1, "Yes", " No")
   m.info = 41
	Insert Into cadr_tmp From Memvar

* jss, 6/2/03, define memvars for extract's section4
	m.pnotifserv = IIF(cadrserv.serv_off=1, 'Yes', 'No')

* jss, 3/28/05, Q44(2004) becomes Q41b(2005)
*--Q41b
If Used('all_serv')
   Use In all_serv
Endif

		Select	Distinct ai_serv.numitems, ai_serv.serv_id  ;
		From ai_serv, lv_service, ai_enc, t_prog1;
		Where ;
				ai_serv.service_id = lv_service.service_id and ;
				!Empty(lv_service.cadr_map) and ;
				Left(lv_service.cadr_map,2) = "41" and ;
				between(ai_serv.date, dStartDate, dEndDate) and ;
				ai_serv.act_id = ai_enc.act_id and ;
				ai_enc.enc_id = lv_service.enc_id and ;
				ai_enc.serv_cat = lv_service.serv_cat and ;
				ai_enc.program = t_prog1.prog_id ;
		Into Cursor ;
			all_serv	
         
If Used('t_41')
   Use In t_41
Endif
				
		Select SUM(IIf(numitems = 0, 1, numitems)) as numitems ;
		From all_serv ;
		Into Cursor t_41
      
   If _tally = 0
      m.group = "  b. How many at-risk partners were notified?" + Space(47)+ '0'
   Else
      m.group = "  b. How many at-risk partners were notified?" + Space(42)+ ;
                  Iif(Isnull(t_41.numitems), Space(5) + '0', Str(t_41.numitems, 6, 0))
   Endif
      
	Insert Into cadr_tmp From Memvar

	m.partsnotif = TRAN(t_41.numitems,'999999')

Use in all_serv
Use in t_41
Use in tEncAll9
*------------------------------------------------------------------
return
***************
PROCEDURE sect5
***************
	m.prvid      = agency.aar_id
	m.regcode    = SPACE(5)
	m.prvname1   = TRIM(agency.descript1)+' '+TRIM(agency.descript2)
	m.RecId= LEFT(DTOS(dEndDate),6) + m.PrvID
*** Section 5
	m.section = Space(40) + "SECTION 5.  MEDICAL INFORMATION  (HIV-Positive Clients Only)"
	m.part = ""

* jss, 3/28/05, for 2005, "35A" becomes "33A"
If Used('all_serv5')
   Use In all_serv5
Endif
   
		Select	ai_serv.tc_id, ;
				ai_serv.act_id, ;
				ai_serv.serv_cat, ;
				ai_enc.enc_id, ;
				ai_serv.date as act_dt, ;
				lv_service.cadr_map ;
		From ai_serv, ai_enc, lv_service, t_prog ;
		Where ;
				ai_serv.act_id = ai_enc.act_id and ;
				ai_enc.program = t_prog.prog_id and ;
				ai_serv.serv_cat = lv_service.serv_cat and ;
				(ai_enc.enc_id = lv_service.enc_id OR EMPTY(lv_service.enc_id)) and  ;
				ai_serv.service_id = lv_service.service_id and ;
				!Empty(lv_service.cadr_map) and ;
				Alltrim(lv_service.cadr_map) == "33A" and ;
				between(ai_serv.date, dStartDate, dEndDate);
		Into Cursor ;
			all_serv5
		
*** Select All encounters with CADR Map ="35A" and no services
* jss, 3/28/05, for 2005, "35A" becomes "33A"

If Used('tEncAll5')
   Use In tEncAll5
Endif

		Select ai_enc.tc_id, ;
				ai_enc.act_id, ;
				ai_enc.serv_cat, ;
				ai_enc.enc_id, ;
				ai_enc.act_dt, ;
				lv_enc_type.cadr_map ;
		From ai_enc, lv_enc_type, t_prog ;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			Alltrim(lv_enc_type.cadr_map) == "33A" and ;
			ai_enc.program = t_prog.prog_id and ;
			between(ai_enc.act_dt, dStartDate, dEndDate);
			and ai_enc.act_id NOT IN (Select Act_id from ai_serv) ;
		Into Cursor tEncAll5

* jss, 9/17/04, only include encounters with NO service (as is done in q35)
If Used('t_med')
   Use In t_med
Endif

		Select * ;
		From all_serv5 ;
		Union All ;
		Select * ;
		From tEncAll5 ;
		Into Cursor	t_med

Use in tEncAll5
Use in all_serv5

* jss, 1/6/05, because of unpredicatable results d/t 2 subselects in select, make this into 2 selects
If Used('all_medx')
   Use In all_medx
Endif

	Select Distinct t_med.tc_id, ai_clien.client_id, client.gender, hstat.hiv_pos ;
	From t_med, hivstat, hstat, ai_clien, client ;
	Where t_med.tc_id = hivstat.tc_id and ;
			t_med.tc_id   = ai_clien.tc_id and ;
			client.client_id  = ai_clien.client_id and ;
			Dtoc(hivstat.effect_dt) + hivstat.tc_id  In (Select Dtoc(Max(f2.effect_dt)) + f2.tc_id ;
										From ;
											hivstat f2 ;
										Where ;
											f2.effect_dt <= dEndDate Group by f2.tc_id)  and ;
			hivstat.hivstatus = hstat.code ;
	Into Cursor all_medx		

If Used('all_med')
   Use In all_med
Endif
			
	Select * from all_medx ;
	Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet);
	Into Cursor	all_med
	
Use in all_medx
* jss, 1/6/05, because of unpredicatable results d/t 2 subselects in select, make this into 2 selects
If Used('all_med1x')
   Use In all_med1x
Endif

	Select t_med.*, ai_clien.client_id, client.gender, hstat.hiv_pos ;
	From t_med, hivstat, hstat, ai_clien, client ;
	Where t_med.tc_id = hivstat.tc_id and ;
			t_med.tc_id   = ai_clien.tc_id and ;
			client.client_id  = ai_clien.client_id and ;
			Dtoc(hivstat.effect_dt) + hivstat.tc_id  In (Select Dtoc(Max(f2.effect_dt)) + f2.tc_id ;
										From ;
											hivstat f2 ;
										Where ;
											f2.effect_dt <= dEndDate Group by f2.tc_id)  and ;
			hivstat.hivstatus = hstat.code  ;
	Into Cursor all_med1x

If Used('all_med1')
   Use In all_med1
Endif
	
	Select * from all_med1x ;		
	Where hiv_pos = .t. ;
		or tc_id In (Select tc_id From t_indet);
	Into Cursor	all_med1

Use in all_med1x	
Use in t_med

* jss, 3/28/05, Q45(2004) becomes Q42(2005)
*--Q42
   m.group = "42.  Total number of unduplicated clients reporting" +  Space(43) 
	m.info = 42
	Insert Into cadr_tmp From Memvar

If Used('t_gen')
   Use In t_gen
Endif
	
		Select  ;
				Sum(Iif(gender='11',1, 0)) as tot_mal, ;
				Sum(Iif(gender='10',1, 0)) as tot_fem, ;
				Sum(Iif((gender = '12' or gender = '13'),1,0)) as tot_tr, ;				
				Sum(iif(Empty(gender), 1, 0)) as tot_un, ;
				Count(*) as total ;
		From all_med ;
		Into Cursor t_gen
		
		m.group   = "     on in this section by gender:" + Space(19) + ;
                  Iif(Isnull(t_gen.tot_mal), Space(5) + '0', Str(t_gen.tot_mal, 6, 0)) + "   Male" 
         
		Insert Into cadr_tmp From Memvar

		m.group   = Space(53) + ;
                  Iif(Isnull(t_gen.tot_fem), Space(5)+ '0', Str(t_gen.tot_fem, 6, 0)) + "   Female" 
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(53) + ;
                  Iif(Isnull(t_gen.tot_tr), Space(5)+'0', Str(t_gen.tot_tr, 6, 0)) + "   Transgender" 
 		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(53) + ;
                  Iif(Isnull(t_gen.tot_un), Space(5)+'0', Str(t_gen.tot_un, 6, 0)) + "   Unknown/Unreported" 
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(53) + ;
                  Iif(Isnull(t_gen.total), Space(5)+'0', Str(t_gen.total, 6, 0)) + "   Total" 
		Insert Into cadr_tmp From Memvar

* jss, 11/29/07, if values are null, must force a zero into field
		m.n_male 	= Iif(IsNull(t_gen.tot_mal), '     0',TRAN(t_gen.tot_mal,'999999'))
		m.n_female 	= Iif(IsNull(t_gen.tot_fem), '     0',TRAN(t_gen.tot_fem,'999999'))
		m.n_trans 	= Iif(IsNull(t_gen.tot_tr) , '     0',TRAN(t_gen.tot_tr,'999999'))
		m.n_unknown	= Iif(IsNull(t_gen.tot_un) , '     0',TRAN(t_gen.tot_un,'999999'))
		m.n_total 	= Iif(IsNull(t_gen.total)  , '     0',TRAN(t_gen.total,'999999'))

		savetot=t_gen.total		

Use in t_gen

*--Q43
   m.group = "43.  Total # of clients with ambulatory medical visits:"
   m.info = 43
	Insert Into cadr_tmp From Memvar

If Used('t_visits')
   Use In t_visits
Endif

	Select tc_id, Count(Dist act_dt) as Visits ;
	From all_med1 ;
	Group by tc_id ;
	Into Cursor ;
		t_visits

Use in all_med1

If Used('allvisits')
   Use In allvisits
Endif

	Select 	Sum(Iif(visits=1,1,0)) As visit1, ;
				Sum(Iif(visits=2,1,0)) As visit2, ;
				Sum(Iif(visits=3 or visits=4,1,0)) As visit34, ;
				Sum(Iif(visits>=5,1,0)) As visit5plus ;
	From t_visits ;
	Into Cursor ;
		allvisits
		
Use in t_visits					
				
	m.visitcli= allvisits.visit1 + allvisits.visit2 + allvisits.visit34 + allvisits.visit5plus
		
	m.group   = Space(53) + ;
               Iif(Isnull(allvisits.visit1), Space(5)+'0',Str(allvisits.visit1, 6, 0)) + "   Clients with 1 Visit" 
	Insert Into cadr_tmp From Memvar
   
	m.group   = Space(53) + ;
               Iif(Isnull(allvisits.visit2), Space(5)+'0',Str(allvisits.visit2, 6, 0)) + "   Clients with 2 Visits" 
	Insert Into cadr_tmp From Memvar
   
	m.group   = Space(53) + ;
               Iif(Isnull(allvisits.visit34), Space(5)+'0',Str(allvisits.visit34, 6, 0)) + "   Clients with 3-4 Visits" 
	Insert Into cadr_tmp From Memvar
   
	m.group   = Space(53) + ;
               Iif(Isnull(allvisits.visit5plus), Space(5)+'0',Str(allvisits.visit5plus, 6, 0)) + "   Clients with 5 or more Visits" 
	Insert Into cadr_tmp From Memvar
   
	m.group   = Space(58) + "0" + "   Number for whom visit count is unknown" 
	Insert Into cadr_tmp From Memvar

	m.group   = Space(53) + ;
               Iif(Isnull(m.visitcli), Space(5)+'0',Str(m.visitcli, 6, 0)) + "   Total" 
	Insert Into cadr_tmp From Memvar

* jss, 11/29/07, if values are null, must force a zero into field
	m.visit1 	= Iif(IsNull(allvisits.visit1),    '     0',TRAN(allvisits.visit1,'999999'))
	m.visit2 	= Iif(IsNull(allvisits.visit2),    '     0',TRAN(allvisits.visit2,'999999'))
	m.visit34 	= Iif(IsNull(allvisits.visit34),   '     0',TRAN(allvisits.visit34,'999999'))
	m.visit5plus= Iif(IsNull(allvisits.visit5plus),'     0',TRAN(allvisits.visit5plus,'999999'))
	m.visitunk 	= '     0'
	m.visittot  = Iif(IsNull(m.visitcli),  '     0',TRAN(m.visitcli,'999999'))

Use in allvisits
		
* jss, 3/28/05, Q46(2004) becomes Q44(2005)
*--Q44
   m.group = "44.  Total # of clients who are HIV positive with each   "
   m.info = 44
	Insert Into cadr_tmp From Memvar

* jss, 1/9/04, modify code to count a client only once per report period, in the following hierarchy:
* 1) msm and idu 2) msm 3) idu 4) hemophilia 5) hetero 6) blood recipient 7) perinatal 8) other 9) undetermined/unknown

If Used('all_rw')
   Use In all_rw 
Endif

		Select	Distinct relhist.tc_id, relhist.rw_code;
		From relhist, all_med ;
		Where ;
				relhist.tc_id = all_med.tc_id and ;
				relhist.date <= dEndDate ;
		Into Cursor all_rw 
     
* msm and idu
If Used('rw_msmidu')
   Use In rw_msmidu
Endif

		Select * ;
		From all_rw ;
		Where rw_code="01" ;
		Into Cursor rw_msmidu
* msm
If Used('rw_msm')
   Use In rw_msm
Endif

		Select * ;
		From all_rw ;
		Where rw_code="02" ;
		Into Cursor rw_msm
* idu
If Used('rw_idu')
   Use In rw_idu
Endif

		Select * ;
		From all_rw ;
		Where rw_code="03" ;
		Into Cursor rw_idu
* hemophilia
If Used('rw_hemo')
   Use In rw_hemo
Endif

		Select * ;
		From all_rw ;
		Where rw_code="04" ;
		Into Cursor rw_hemo
* hetero
If Used('rw_hetero')
   Use In rw_hetero
Endif

		Select * ;
		From all_rw ;
		Where rw_code="05" ;
		Into Cursor rw_hetero
* blood
If Used('rw_blood')
   Use In rw_blood
Endif

		Select * ;
		From all_rw ;
		Where rw_code="06" ;
		Into Cursor rw_blood
* perinatal
If Used('rw_perin')
   Use In rw_perin
Endif

		Select * ;
		From all_rw ;
		Where rw_code="07" ;
		Into Cursor rw_perin
* unknown
If Used('rw_unknown')
   Use In rw_unknown
Endif

		Select * ;
		From all_rw ;
		Where rw_code="08" ;
		Into Cursor rw_unknown
* other
If Used('rw_other')
   Use In rw_other
Endif

		Select * ;
		From all_rw ;
		Where rw_code="09" ;
		Into Cursor rw_other

If Used('t_44')
   Use In t_44
Endif

		Select Count(Dist tc_id) as t_1 ;
		From rw_msm ;
		Where tc_id NOT IN (Select tc_id FROM rw_msmidu) ;
		Into cursor	t_44

		m.group   = "     of the listed risk factors for HIV infection:" + Space(3) + ;
                  Iif(Isnull(t_44.t_1), Space(5)+'0', Str(t_44.t_1, 6, 0)) + ;
                  "   Men who have sex with men (MSM)" 
		Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
		m.r_msm 		= TRAN(t_44.t_1,'999999')
		totrisk = t_44.t_1 

If Used('t_44')
   Use In t_44
Endif

		Select Count(Dist tc_id) as t_2 ;
		From rw_idu ;
		Where tc_id NOT IN (Select tc_id FROM rw_msmidu) and ;
				tc_id NOT IN (Select tc_id FROM rw_msm) ;
		Into cursor	t_44
		
		m.group   = Space(53) + ;
                  Iif(Isnull(t_44.t_2), Space(5)+'0', Str(t_44.t_2, 6, 0)) + "   Injection drug user (IDU)" 
		Insert Into cadr_tmp From Memvar
		
* jss, 6/2, define memvars for extract's section 5
		m.r_idu 		= TRAN(t_44.t_2,'999999')
		totrisk = totrisk + t_44.t_2 

If Used('t_44')
   Use In t_44
Endif

		Select Count(Dist tc_id) as t_3 ;
		From rw_msmidu ;
		Into cursor	t_44

		m.group   = Space(53) + ;
                  Iif(Isnull(t_44.t_3), Space(5) +'0',Str(t_44.t_3, 6, 0)) + "   Men who have sex with men and injection"
		Insert Into cadr_tmp From Memvar
		
* jss, 6/2, define memvars for extract's section 5
		m.r_msmidu 	= TRAN(t_44.t_3,'999999')
		totrisk = totrisk + t_44.t_3 

		m.group   = Space(62) + "drug user (MSM and IDU)" 
		Insert Into cadr_tmp From Memvar

* combine msmidu, msm, idu into one cursor called allmsmidu
If Used('allmsmidu')
   Use In allmsmidu
Endif

		Select * FROM rw_msmidu ;
		Union all ;
		Select * FROM rw_msm ;
		Union all ;
		Select * FROM rw_idu ;
		Into cursor allmsmidu
			
		Use in rw_msmidu
		Use in rw_msm
		Use in rw_idu

If Used('t_44')
   Use In t_44
Endif
		
		Select Count(Dist tc_id) as t_4 ;
		From rw_hemo ;
		Where tc_id NOT IN (Select tc_id FROM allmsmidu) ;
		Into cursor	t_44

		m.group   = Space(53) + ;
                  Iif(Isnull(t_44.t_4), Space(5)+'0', Str(t_44.t_4, 6, 0)) + "   Hemophilia/Coagulation disorder" 
		Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
		m.r_hemophil= TRAN(t_44.t_4,'999999')
		totrisk = totrisk + t_44.t_4 

* combine allmsmidu and rw_hemo into one cursor called msmiduhemo
If Used('msmiduhemo')
   Use In msmiduhemo
Endif

		Select * FROM allmsmidu ;
		Union all ;
		Select * FROM rw_hemo ;
		Into cursor msmiduhemo
			
		Use in allmsmidu
		Use in rw_hemo

If Used('t_44')
   Use In t_44
Endif

		Select Count(Dist tc_id) as t_5 ;
		From rw_hetero ;
		Where tc_id NOT IN (Select tc_id FROM msmiduhemo) ;
		Into cursor	t_44

		m.group   = Space(53) + ;
                  Iif(Isnull(t_44.t_5), Space(5)+'0',Str(t_44.t_5, 6, 0)) + "   Heterosexual contact" 
		Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
		m.r_hetero	= TRAN(t_44.t_5,'999999')
		totrisk = totrisk + t_44.t_5

* combine msmiduhemo and rw_hetero into one cursor called mihh
If Used('mihh')
   Use In mihh
Endif

		Select * FROM msmiduhemo ;
		Union all ;
		Select * FROM rw_hetero ;
		Into cursor mihh
			
		Use in msmiduhemo
		Use in rw_hetero

If Used('t_44')
   Use In t_44
Endif

		Select Count(Dist tc_id) as t_6 ;
		From rw_blood ;
		Where tc_id NOT IN (Select tc_id FROM mihh) ;
		Into cursor	t_44

		m.group   = Space(53) + ;
                  Iif(Isnull(t_44.t_6), Space(5)+'0',Str(t_44.t_6, 6, 0)) + "   Receipt of transfusion of blood, blood"
		Insert Into cadr_tmp From Memvar
			 
* jss, 6/2, define memvars for extract's section 5
		m.r_transfus= TRAN(t_44.t_6,'999999')
		totrisk = totrisk + t_44.t_6 

 		m.group   = Space(62) + "components, or tissue" 
		Insert Into cadr_tmp From Memvar

* combine mihh and rw_blood into one cursor called mihhb
If Used('mihhb')
   Use In mihhb
Endif
		Select * FROM mihh ;
		Union all ;
		Select * FROM rw_blood ;
		Into cursor mihhb
			
		Use in mihh
		Use in rw_blood

If Used('t_44')
   Use In t_44
Endif

		Select Count(Dist tc_id) as t_7 ;
		From rw_perin ;
		Where tc_id NOT IN (Select tc_id FROM mihhb) ;
		Into cursor	t_44

		m.group   = Space(53) + Iif(Isnull(t_44.t_7),Space(5)+'0',Str(t_44.t_7, 6, 0)) + "   Perinatal transmission" 
		Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
		m.r_perinata= TRAN(t_44.t_7,'999999')
		totrisk = totrisk + t_44.t_7

* combine mihhb and rw_perin into one cursor called mihhbp
If Used('mihhbp')
   Use In mihhbp
Endif
		Select * FROM mihhb ;
		Union all ;
		Select * FROM rw_perin ;
		Into cursor mihhbp
			
		Use in mihhb
		Use in rw_perin

If Used('t_44')
   Use In t_44
Endif
		
		Select Count(Dist tc_id) as t_8 ;
		From rw_other ;
		Where tc_id NOT IN (Select tc_id FROM mihhbp) ;
		Into cursor	t_44

		m.group   = Space(53) + Iif(Isnull(t_44.t_8),Space(5)+'0',Str(t_44.t_8, 6, 0)) + "   Other" 
		Insert Into cadr_tmp From Memvar
		
* jss, 6/2, define memvars for extract's section 5
		m.r_other	= TRAN(t_44.t_8,'999999')
		totrisk = totrisk + t_44.t_8

* combine mihhbp and rw_other into one cursor called mihhbpo
If Used('mihhbpo')
   Use In mihhbpo
Endif

		Select * FROM mihhbp ;
		Union all ;
		Select * FROM rw_other ;
		Into cursor mihhbpo
			
		Use in mihhbp
		Use in rw_other

If Used('t_44')
   Use In t_44
Endif
		
		Select Count(Dist tc_id) as t_9 ;
		From rw_unknown ;
		Where tc_id NOT IN (Select tc_id FROM mihhbpo) ;
		Into cursor	t_44

		Use in mihhbpo
		Use in rw_unknown
		
		totrisk = totrisk + t_44.t_9
		
		t9risk=t_44.t_9
		IF totrisk<>savetot  
			riskadj=savetot-totrisk
			t9risk=t9risk+riskadj
			totrisk=savetot
		ENDIF

		m.group   = Space(53) + Iif(Isnull(t9risk), Space(5)+'0',Str(t9risk, 6, 0)) + "   Undetermined/Unknown/Risk not reported"
		Insert Into cadr_tmp From Memvar

       m.group   = Space(62) + "or identified" 
      Insert Into cadr_tmp From Memvar

      m.group  = Space(53) + Iif(Isnull(totrisk), Space(5)+'0',Str(totrisk, 6, 0)) + "   Total"
      Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
		m.r_undeterm= TRAN(t9risk,'999999')
		m.r_total = TRAN(totrisk,'999999')
Use in t_44		

*--Q45
* first, grab clients who have had a service or encounter with cadr_map=="33A" prior to this period
If Used('old_serv33')
   Use In old_serv33
Endif

		Select	ai_serv.tc_id ;
		From ai_serv, ai_enc, lv_service, t_prog ;
		Where ;
				ai_serv.act_id = ai_enc.act_id and ;
				ai_enc.program = t_prog.prog_id and ;
				ai_serv.serv_cat = lv_service.serv_cat and ;
				(ai_enc.enc_id = lv_service.enc_id OR EMPTY(lv_service.enc_id)) and  ;
				ai_serv.service_id = lv_service.service_id and ;
				!Empty(lv_service.cadr_map) and ;
				Alltrim(lv_service.cadr_map) == "33A" and ;
				ai_serv.date < dStartDate;
		Into Cursor ;
			old_serv33

If Used('old_enc33')
   Use In old_enc33
Endif

		Select ai_enc.tc_id ;
		From ai_enc, lv_enc_type, t_prog ;
		Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
			ai_enc.enc_id = lv_enc_type.enc_id and ; 
			!Empty(lv_enc_type.cadr_map) and ;
			Alltrim(lv_enc_type.cadr_map) == "33A" and ;
			ai_enc.program = t_prog.prog_id and ;
			ai_enc.act_dt < dStartDate ;
			and ai_enc.act_id NOT IN (Select Act_id from ai_serv) ;
		Into Cursor old_enc33

* now, count number of tc_id's in all_med who are NOT in cursors of encounters/services prior to period
If Used('New33a')
   Use In New33a
Endif
		Select Distinct tc_id ;
		From all_med ;
		Where ;
		tc_id Not In (Select tc_id From old_serv33) and;
		tc_id Not in (Select tc_id From old_enc33) ;
		Into Cursor New33a

If Used('New33')
   Use In New33
Endif
			
		Select Count(*) as NewCnt ;
		From New33a ;
		Into Cursor New33	
			
		m.group = "45.  New HIV+ clients receiving medical services:" + SPACE(4) + ;
                 Iif(Isnull(New33.NewCnt), Space(5)+'0',Str(New33.NewCnt,6,0))
		m.info = 45
		Insert Into cadr_tmp From Memvar
* now define memvar for Section5 extract		
		m.newhivcli	= TRAN(New33.NewCnt,'999999')
Use in New33

*--Q46
If Used('CD4Curs1')
   Use In CD4Curs1
Endif
		
		Select Distinct tc_id ;
		From testres ; 
		Where testtype='06' ;
		  and Between(testdate,dStartDate,dEndDate) ;
		  and tc_id In (Select tc_id From New33a) ;
		Union ;
		Select Distinct ai_serv.tc_id ;
		From ai_serv, lv_service, ai_enc, t_prog ;
		Where ai_serv.service_id = lv_service.service_id ;
		  and	!Empty(lv_service.cadrmap2) ;
		  and	Left(lv_service.cadrmap2,3) = "46A" ;
		  and	between(ai_serv.date, dStartDate, dEndDate) ;
		  and	ai_enc.act_id = ai_serv.act_id ;
		  and	ai_enc.program = t_prog.prog_id ;
		  and	ai_enc.enc_id = lv_service.enc_id ;
		  and	ai_enc.serv_cat = lv_service.serv_cat ;		
		  and ai_serv.tc_id In (Select tc_id From New33a) ;
		Into Cursor CD4Curs1

If Used('CD4Curs')
   Use In CD4Curs
Endif		
		Select Count(Dist tc_id) as CD4Cnt ;
		From CD4Curs1 ;
		Into Cursor CD4Curs

Use in CD4Curs1

If Used('ViralCurs1')
   Use In ViralCurs1
Endif

		Select Distinct tc_id ;
		From testres ; 
		Where testtype='05' ;
		  and Between(testdate,dStartDate,dEndDate) ;
		  and tc_id In (Select tc_id From New33a) ;
		Union;
		Select Distinct ai_serv.tc_id ;
		From ai_serv, lv_service, ai_enc, t_prog ;
		Where ai_serv.service_id = lv_service.service_id ;
		  and	!Empty(lv_service.cadrmap2) ;
		  and	Left(lv_service.cadrmap2,3) = "46B" ;
		  and	between(ai_serv.date, dStartDate, dEndDate) ;
		  and	ai_enc.act_id = ai_serv.act_id ;
		  and	ai_enc.program = t_prog.prog_id ;
		  and	ai_enc.enc_id = lv_service.enc_id ;
		  and	ai_enc.serv_cat = lv_service.serv_cat ;		
		  and ai_serv.tc_id In (Select tc_id From New33a) ;
		Into Cursor ViralCurs1

If Used('ViralCurs')
   Use In ViralCurs
Endif

		Select Count(Dist tc_id) as ViralCnt ;
		From ViralCurs1 ;
		Into Cursor ViralCurs

Use in ViralCurs1		
Use in New33a

		m.group = "46.  Of New HIV+ clients, number receiving following tests at least once in reporting period:" 
		m.info = 46
		Insert Into cadr_tmp From Memvar

		m.group   = Space(53) + Iif(Isnull(CD4Curs.cd4cnt), Space(5)+'0',Str(CD4Curs.cd4cnt, 6, 0)) + ;
                  "   receiving CD4 Count Test"
		Insert Into cadr_tmp From Memvar

		m.group   = Space(53) + Iif(Isnull(ViralCurs.Viralcnt), Space(5)+'0',Str(ViralCurs.Viralcnt, 6, 0)) + ;
                  "   receiving Viral Load Test"
		Insert Into cadr_tmp From Memvar

* now define memvar for Section5 extract		
		m.CD4Cnt		= TRAN(CD4Curs.cd4cnt,'999999')
		m.ViralCnt	= TRAN(ViralCurs.Viralcnt,'999999')

Use in Cd4curs
Use in Viralcurs

*--Q47
* jss, 1/6/06, because of unpredictable results with too many subselects, break up above union select into multiple selects, then union
If Used('all_47ax1')
   Use In all_47ax1
Endif

*!*   --------------------------------------------------- 
*!*   v8.6 #7428 
*!*   
*!*   Select ai_serv.tc_id ;
*!*   From ai_serv, lv_service, ai_enc, t_prog ;
*!*   Where ;
*!*   		ai_serv.service_id = lv_service.service_id and ;
*!*   		!Empty(lv_service.cadrmap2) and ;
*!*   		Left(lv_service.cadrmap2,2) = "47" and ;
*!*   		between(ai_serv.date, dStartDate, dEndDate) and ;
*!*   		ai_enc.act_id = ai_serv.act_id and ;
*!*   		ai_enc.program = t_prog.prog_id and ;
*!*   		ai_enc.enc_id = lv_service.enc_id and ;
*!*   		ai_enc.serv_cat = lv_service.serv_cat ;
*!*   Into Cursor ;
*!*   	all_47ax1
*!*      
*!*   --------------------------------------------------- 
*!*   Dev #7428 v8.6
*!*   A) Q47A (# Clients where TB Test is Indicated):
*!*   --------------------------------------------------- 
*!*   When QF has a "Test Date" within the Reporting Period, the client should be counted here.
*!*   The tc_id's of 'clients' that qualify for reporting will be used later to weed-out those
*!*   that do not qualify.
*!*   

Select Distinct ai_serv.tc_id ;
From ai_serv, lv_service, ai_enc, t_prog ;
Where ;
      ai_serv.service_id = lv_service.service_id and ;
      !Empty(lv_service.cadrmap2) and ;
      Left(lv_service.cadrmap2,2) = "47" and ;
      between(ai_serv.date, dStartDate, dEndDate) and ;
      ai_enc.act_id = ai_serv.act_id and ;
      ai_enc.program = t_prog.prog_id and ;
      ai_enc.enc_id = lv_service.enc_id and ;
      ai_enc.serv_cat = lv_service.serv_cat ;
Union;
Select Distinct testres.tc_id;
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
    And testtype='QF';
    And tc_id in (Select tc_id From all_med);
Into Cursor ;
   all_47ax1

If Used('all_47ax2')
   Use In all_47ax2
Endif

Select tc_id ;
From tbstatus ;
Where ppddone=1 ;
    And !Empty(ppddate) ;
    And between(ppddate, dStartDate, dEndDate) ;
    And tc_id+DTOS(ppddate) In (Select tb.tc_id+Max(DTOS(tb.ppddate)) ;
                                From tbstatus tb ;
                                Where ppddate <= dEndDate ;
                                Group by tb.tc_id);
Into Cursor ;
all_47ax2

If Used('all_47aa')
   Use In all_47aa
Endif

Select * from all_47ax1 ;
Union ;
Select * from all_47ax2 ;												
Into Cursor ;
	all_47aa
			
Use in all_47ax1
Use in all_47ax2

* jss, 1/6/06, because of unpredictable results with too many subselects, break up above union select into multiple selects
If Used('all_47ax')
   Use In all_47ax
Endif

*!* Get the most recent HIV Status
Select DISTINCT all_47aa.tc_id, hstat.hiv_pos ;
From all_47aa, hivstat, hstat ;
Where all_47aa.tc_id=hivstat.tc_id ;
   And Dtoc(hivstat.effect_dt) + hivstat.tc_id  In (Select Dtoc(Max(f2.effect_dt)) + f2.tc_id ;
                     										 From hivstat f2 ;
                     										 Where f2.effect_dt <= dEndDate Group by f2.tc_id);
   And hivstat.hivstatus = hstat.code ;
Into Cursor	;
	all_47ax

Use in all_47aa

If Used('all_47a')
   Use In all_47a
Endif

*!* Select only this HIV+ Clients
Select Distinct tc_id ;
From all_47ax ;
Where hiv_pos = .t. ;
		 or tc_id In (Select tc_id from t_indet);
Into Cursor ;
   all_47a
         
Use in all_47ax

If Used('t_47a')
   Use In t_47a
Endif

Select Count(*) as t_a ;
From all_47a ;
Into Cursor t_47a      

* now, find everyone from 47a who received a ppd test
If Used('all_47ba')
   Use In all_47ba
Endif

*!*   Code prior to v8.6 - Keep for a while
*!*   Select ai_serv.tc_id, ;
*!*   		lv_service.cadrmap2 ;
*!*   From ai_serv, lv_service, ai_enc, t_prog ;
*!*   Where ;
*!*   		ai_serv.service_id = lv_service.service_id and ;
*!*   		!Empty(lv_service.cadrmap2) and ;
*!*   		Left(lv_service.cadrmap2,3) = "47B" and ;
*!*   		between(ai_serv.date, dStartDate, dEndDate) and ;
*!*   		ai_enc.act_id = ai_serv.act_id and ;
*!*   		ai_enc.program = t_prog.prog_id and ;
*!*   		ai_enc.enc_id = lv_service.enc_id and ;
*!*   		ai_enc.serv_cat = lv_service.serv_cat ;
*!*   		and ai_serv.tc_id in (Select tc_id from all_47a) ;
*!*   Into Cursor ;
*!*   	all_47ba

*!*   Dev #7428 v8.6 09/2010
*!*   B) Q47B (# Client who Received TB Skin Test):
*!*   -------------------------------------------------
*!*   When QF has a "Test Date" within the Reporting Period, the client should be counted here.

Select Distinct ai_serv.tc_id, ;
      lv_service.cadrmap2 ;
From ai_serv, lv_service, ai_enc, t_prog ;
Where ;
      ai_serv.service_id = lv_service.service_id and ;
      !Empty(lv_service.cadrmap2) and ;
      Left(lv_service.cadrmap2,3) = "47B" and ;
      between(ai_serv.date, dStartDate, dEndDate) and ;
      ai_enc.act_id = ai_serv.act_id and ;
      ai_enc.program = t_prog.prog_id and ;
      ai_enc.enc_id = lv_service.enc_id and ;
      ai_enc.serv_cat = lv_service.serv_cat ;
      and ai_serv.tc_id in (Select tc_id from all_47a) ;
Union;
Select Distinct testres.tc_id, "47B";
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
    And testtype='QF';
    And tc_id in (Select tc_id from all_47a);
Into Cursor ;
   all_47ba

*;
*    And tc_id in (Select tc_id From all_med);

If Used('all_47bpos')
   Use In all_47bpos
Endif

*!* 7428 - Q 47: Include "QuantiFeron TB (QF) Lab Test (TB Testing)
*!* To add tests to the mix I decided to keep the original code and add
*!* the tests to the list, since the TB status containes more reportable 
*!* data 


Select ;
   tc_id, ;
   ppddate, ;
   ppdres, ;
   treatment, ;
   datestart, ;
   datecomp, ;
   1 As testsource;
From tbstatus;
Where ppddone=1 ;
  and !Empty(ppddate) ;
  and tbstatus.tc_id in (Select tc_id From all_47a) ;      
  and Between(ppddate, dStartDate, dEndDate) ;
Union ;
Select;
   tc_id,;
   testdate As ppddate, ;
   result As ppdres, ;
   '  ' As treatment, ;
   {} As datestart, ;
   {} As datecomp, ;
   2 As testsource;
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
   And testres.tc_id in (Select tc_id From all_47a) ;      
   And testtype='QF';
Order by 1, 2 Desc;
Into Cursor _curAllTBTests

Select * ;
From _curAllTBTests ;
Where tc_id+Dtos(ppddate) In;
      (Select tb.tc_id+Max(DTOS(tb.ppddate)) ;
       From _curAllTBTests tb ;
       Group by tb.tc_id);
Order By 1;
Into cursor _curSource

Use In _curAllTBTests

If Used('all_47bpos')
   Use In all_47bpos
Endif

Select tc_id, ;
		ppdres, ;
		treatment, ;
		datestart, ;
		datecomp ;
From _curSource ;
Where ppdres='2';
Into Cursor all_47bpos

If Used('all_47bneg')
   Use In all_47bneg
Endif

Select ;
   tc_id, ;
	ppdres, ;
	treatment, ;
	datestart, ;
	datecomp ;
From _curSource ;
Where ppdres='1';
Into Cursor all_47bneg


*PB:12/2008 New item for 47c Indeterminate ppdres=3
If Used('all_47binc')
   Use In all_47binc
Endif

Select tc_id, ;
      ppdres, ;
      treatment, ;
      datestart, ;
      datecomp ;
From _curSource ;
Where ppdres='3';
Into Cursor all_47binc

If Used('all_47bunk')
   Use In all_47bunk
Endif

Select ;
   tc_id, ;
	ppdres, ;
	treatment, ;
	datestart, ;
	datecomp ;
From _curSource ;
Where !InList(ppdres,'1','2','3');
Into Cursor all_47bunk

* now, combine these 3 cursor selectively (positive>negative>unknown) into cursor all_47bb
If Used('all_47bpn')
   Use In all_47bpn
Endif

		Select * From all_47bpos ;
		Union ;
		Select * From all_47bneg Where tc_id Not in (Select tc_id From all_47bpos) ;
		Into Cursor ;
			all_47bpn

* PB: 12/2008 Added to account for Indeterminate
If Used('all_47bpi')
   Use In all_47bpi
Endif

 Select * From all_47binc;
 Union ;
 Select * From all_47bpn ;
   Where tc_id Not in (Select tc_id From all_47binc) ; 
   Into Cursor all_47bpi
*

If Used('all_47bb')
   Use In all_47bb
Endif
			
		Select * From all_47bpi ;
		Union ;
		Select * From all_47bunk Where tc_id Not in (Select tc_id From all_47bpi) ;
		Into Cursor ;
			all_47bb	

Use In _curSource
Use in all_47bpos
Use in all_47bneg
Use In all_47binc
Use in all_47bunk

If Used('all_47b')
   Use In all_47b
Endif
			
Select Distinct tc_id From all_47ba ;
Union ;
Select Distinct tc_id From all_47bb ;
Into Cursor all_47b
			
If Used('t_47b')
   Use In t_47b
Endif

		Select Count(*) as t_b ;
		From all_47b ;
		Into Cursor t_47b		

Use in all_47b		

   m.group = "47.  Latent tuberculosis (TB) testing:"
	m.info = 47
	Insert Into cadr_tmp From Memvar
   m.group = " a.  Clients for whom PPD test was indicated"+ Space(9) + ;
             Iif(Isnull(t_47a.t_a), Space(5)+'0', Str(t_47a.t_a, 6, 0))
	Insert Into cadr_tmp From Memvar
   m.group = " b.  Clients for whom PPD test was performed"+ Space(9) + ;
             Iif(Isnull(t_47b.t_b), Space(5)+'0',Str(t_47b.t_b, 6, 0))
	Insert Into cadr_tmp From Memvar

* jss, 3/29/05, define vars for extract section 5 for "ppd test indicated" (new) and "ppd test performed" (old)
	m.ppdind		= TRAN(t_47a.t_a,'999999')
	m.ppd			= TRAN(t_47b.t_b,'999999')

Use in all_47a
Use in t_47a
 
If Used('t_47c')
   Use In t_47c
Endif

	Select Sum(IIF(ppdres='1',1,0)) as tbneg, ;
			 Sum(IIF(ppdres='2',1,0)) as tbpos, ;
          Sum(Iif(ppdres='3',1,0)) as tbinc  ;
	From all_47bb ;
	Into Cursor ;
		t_47c

   * 2008 RDR
   tbunk=Iif(t_47b.t_b > (t_47c.tbneg+t_47c.tbpos+t_47c.tbinc), t_47b.t_b - (t_47c.tbneg+t_47c.tbpos+t_47c.tbinc),0)
  
   * Old Way 
*	tbunk=Max(0, t_47b.t_b-(t_47c.tbneg+t_47c.tbpos+t_47c.tbinc))

Use in t_47b

   m.group = " c.  Of clients in 47b, how many were:"
	Insert Into cadr_tmp From Memvar
   
   m.group = Space(53) + Iif(Isnull(t_47c.tbneg), Space(5)+'0',Str(t_47c.tbneg, 6, 0)) + "   Negative"
	Insert Into cadr_tmp From Memvar
   
   m.group = Space(53) + Iif(Isnull(t_47c.tbpos), Space(5)+'0',Str(t_47c.tbpos, 6, 0)) + "   Positive"
   Insert Into cadr_tmp From Memvar
   
   m.group = Space(53) + Iif(Isnull(t_47c.tbinc), Space(5)+'0',Str(t_47c.tbinc, 6, 0)) + "   Indeterminate"
   Insert Into cadr_tmp From Memvar
   
   m.group = Space(53) + Iif(Isnull(tbunk), Space(5)+'0',Str(tbunk, 6, 0)) + "   Unknown (did not return lost to follow-up)"
	Insert Into cadr_tmp From Memvar
				 
* jss, 3/30/05, define new vars for extract section 5 for "ppd test results"
* jss, 11/29/07, if values are null, must force a zero into field
* PB 12/2008: Added the indeterminate field.

	m.ppdneg		= Iif(IsNull(t_47c.tbneg), '     0', TRAN(t_47c.tbneg,'999999'))
	m.ppdpos		= Iif(IsNull(t_47c.tbpos), '     0', TRAN(t_47c.tbpos,'999999'))
	m.PPDIndrmt = Iif(IsNull(t_47c.tbinc), '     0', TRAN(t_47c.tbinc,'999999'))
   m.ppdunk		= Iif(IsNull(tbunk),      '     0', TRAN(tbunk,'999999'))

Use in t_47c

If Used('t_47d')
   Use In t_47d
Endif

	Select Sum(IIF(treatment='01' or treatment='02',1,0)) as prophtreat, ;
			 Sum(IIF(treatment='03' or treatment='04',1,0)) as activtreat, ;
			 Sum(IIF(treatment<>'01' and treatment<>'02' and treatment<>'03' and treatment<>'04',1,0)) as unktreat ;
	From all_47bb ;
	Where ppdres='2' ;
	Into Cursor ;
		t_47d		

   m.group = " d.  Of clients in 47c who tested positive, how many received:"
	Insert Into cadr_tmp From Memvar
   m.group = Space(53) + Iif(Isnull(t_47d.prophtreat),Space(5)+'0',Str(t_47d.prophtreat, 6, 0)) + "   Prophylaxis for latent TB infection"
	Insert Into cadr_tmp From Memvar
   m.group = Space(53) + Iif(Isnull(t_47d.prophtreat), Space(5)+'0',Str(t_47d.activtreat, 6, 0)) + "   Treatment for active TB infection"
	Insert Into cadr_tmp From Memvar
   m.group = Space(53) + Iif(Isnull(t_47d.unktreat),Space(5)+'0',Str(t_47d.unktreat, 6, 0)) + "   Unknown/Lost to follow-up"
	Insert Into cadr_tmp From Memvar

* jss, 3/30/05, define new vars for extract section 5 for "ppd treatment"
* jss, 11/29/07, if values are null, must force a zero into field
	m.prophtreat= Iif(IsNull(t_47d.prophtreat), '     0', TRAN(t_47d.prophtreat,'999999'))
	m.activtreat= Iif(IsNull(t_47d.activtreat), '     0', TRAN(t_47d.activtreat,'999999'))
	m.unktreat	= Iif(IsNull(t_47d.unktreat),   '     0', TRAN(t_47d.unktreat,'999999'))
Use in t_47d

If Used('t_47e')
   Use In t_47e
Endif

	Select Sum(IIF((treatment='01' or treatment='02') and !Empty(datecomp) and datecomp<=dEndDate,1,0)) as prophcomp, ;
			 Sum(IIF((treatment='03' or treatment='04') and !Empty(datecomp) and datecomp<=dEndDate,1,0)) as activcomp, ;
			 Sum(IIF(Empty(datecomp) or datecomp>dEndDate,1,0)) as currenttx, ;
			 Sum(0)                                   as unkcomp ;
	From all_47bb ;
	Where ppdres='2' ;
	and (treatment='01' or treatment='02' or treatment='03' or treatment='04') ;
	Into Cursor ;
		t_47e
		
Use in all_47bb

   m.group = " e.  Of clients in 47d who started treatment, how many:"
	Insert Into cadr_tmp From Memvar

   m.group = Space(53) + Iif(Isnull(t_47e.prophcomp), Space(5)+'0',Str(t_47e.prophcomp, 6, 0)) + "   Completed treatment for LTBI"
	Insert Into cadr_tmp From Memvar

   m.group = Space(53) + Iif(Isnull(t_47e.activcomp),Space(5)+'0',Str(t_47e.activcomp, 6, 0)) + "   Completed treatment for Active TB disease"
	Insert Into cadr_tmp From Memvar

   m.group = Space(53) + Iif(Isnull(t_47e.currenttx), Space(5)+'0',Str(t_47e.currenttx, 6, 0)) + "   Are currently undergoing treatment"
	Insert Into cadr_tmp From Memvar
   
   m.group = Space(62) + "for either LTBI or active TB disease"
	Insert Into cadr_tmp From Memvar

   m.group = Space(53) + Iif(Isnull(t_47e.unkcomp), Space(5)+'0',Str(t_47e.unkcomp, 6, 0))   + "   Are unknown, lost to follow-up, or"
	Insert Into cadr_tmp From Memvar
   m.group = Space(62) + "did not complete treatment"
	Insert Into cadr_tmp From Memvar

* jss, 3/30/05, define new vars for extract section 5 for "ppd treatment"
* jss, 11/29/07, if values are null, must force a zero into field
	m.prophcomp = Iif(IsNull(t_47e.prophcomp), '     0', TRAN(t_47e.prophcomp,'999999'))
	m.activcomp = Iif(IsNull(t_47e.activcomp), '     0', TRAN(t_47e.activcomp,'999999'))
	m.currtreat	= Iif(IsNull(t_47e.currenttx), '     0', TRAN(t_47e.currenttx, '999999'))
	m.unkcomp	= Iif(IsNull(t_47e.unkcomp),   '     0', TRAN(t_47e.unkcomp,'999999'))
Use in t_47e

*--Q48
If Used('all_48za')
   Use In all_48za
Endif

 
*!* Dev #'s 7426 & 7427 v8.6 09/2010
*!* 7426: RDR Update Q 48C: Include STI Screening (SX) Lab Test [CADRMAP2=48C]
*!* 7427: RDR Update Q 48A: Include Syphilis Screening (SY) Lab Test [CADRMAP2=48A]

Select ai_serv.tc_id, ;
		lv_service.cadrmap2 ;
From ai_serv, lv_service, ai_enc, t_prog ;
Where ;
		ai_serv.service_id = lv_service.service_id and ;
		!Empty(lv_service.cadrmap2) and ;
		Left(lv_service.cadrmap2,2) = "48" and ;
		between(ai_serv.date, dStartDate, dEndDate) and ;
		ai_enc.act_id = ai_serv.act_id and ;
		ai_enc.program = t_prog.prog_id and ;
		ai_enc.enc_id = lv_service.enc_id and ;
		ai_enc.serv_cat = lv_service.serv_cat ;
Union;
Select testres.tc_id, '48C ' ;
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
    And testtype='SX';
    And tc_id in (Select tc_id From all_med Where hiv_pos=(.t.));
Union;
Select testres.tc_id, '48A ' ;
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
    And testtype='SY';
    And tc_id in (Select tc_id From all_med Where hiv_pos =(.t.));
Union;
Select testres.tc_id, '48E ' ;
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
    And testtype='HC';
    And tc_id in (Select tc_id From all_med Where hiv_pos =(.t.));
Into Cursor ;
	all_48za

*!*   Pre v8.6 Code
*!*   Select ai_serv.tc_id, ;
*!*         lv_service.cadrmap2 ;
*!*   From ai_serv, lv_service, ai_enc, t_prog ;
*!*   Where ;
*!*         ai_serv.service_id = lv_service.service_id and ;
*!*         !Empty(lv_service.cadrmap2) and ;
*!*         Left(lv_service.cadrmap2,2) = "48" and ;
*!*         between(ai_serv.date, dStartDate, dEndDate) and ;
*!*         ai_enc.act_id = ai_serv.act_id and ;
*!*         ai_enc.program = t_prog.prog_id and ;
*!*         ai_enc.enc_id = lv_service.enc_id and ;
*!*         ai_enc.serv_cat = lv_service.serv_cat ;
*!*   Into Cursor ;
*!*      all_48za

If Used('all_48')
   Use In all_48
Endif

Select DISTINCT all_48za.tc_id, ;
		all_48za.cadrmap2 ;
From all_48za, hivstat, hstat ;
Where all_48za.tc_id=hivstat.tc_id AND ;
		Dtoc(hivstat.effect_dt) + hivstat.tc_id  ;
        In (Select Dtoc(Max(f2.effect_dt)) + f2.tc_id ;
				From ;
					hivstat f2 ;
				Where ;
					f2.effect_dt <= dEndDate Group by f2.tc_id)  and ;
		hivstat.hivstatus = hstat.code and ;
		(hstat.hiv_pos = .t. ;
		 or all_48za.tc_id In (Select tc_id from t_indet));
Into Cursor all_48

If Used('t_48')
   Use In t_48
Endif
							
Select Sum(Iif(alltrim(cadrmap2) ="48A", 1, 0)) as t_a, ;
		Sum(Iif(alltrim(cadrmap2) ="48B", 1, 0)) as t_b, ;
		Sum(Iif(alltrim(cadrmap2) ="48C", 1, 0)) as t_c, ;
		Sum(Iif(alltrim(cadrmap2) ="48D", 1, 0)) as t_d, ;
		Sum(Iif(alltrim(cadrmap2) ="48E", 1, 0)) as t_e, ;
		Sum(Iif(alltrim(cadrmap2) ="48F", 1, 0)) as t_f  ;
From all_48 ;
Into Cursor t_48
   
   *** For transfer to next page
*	m.group   = " " + CHR(13) 
	m.info = 48
*	Insert Into cadr_tmp From Memvar
   m.section = Space(40) + "SECTION 5.  MEDICAL INFORMATION  (HIV-Positive Clients Only)"
   m.part = ""
   m.group = "48.  Number of clients who received each of the following"
	Insert Into cadr_tmp From Memvar

	m.group  = "     at any time during this reporting period:" + Space(7) + ;
              Iif(Isnull(t_48.t_a), Space(5)+'0', Str(t_48.t_a, 6, 0)) + "   Screening/testing for syphilis" 
	Insert Into cadr_tmp From Memvar
	
	m.group   = Space(53) + Iif(Isnull(t_48.t_b), Space(5)+'0',Str(t_48.t_b, 6, 0)) + "   Treatment for syphilis" 
	Insert Into cadr_tmp From Memvar

	m.group   = Space(53) + Iif(Isnull(t_48.t_c), Space(5)+'0',Str(t_48.t_c, 6, 0)) + "   Screening/testing for any treatable " 
	Insert Into cadr_tmp From Memvar

	m.group   = Space(62) + "sexually transmitted infection (STI)" 
	Insert Into cadr_tmp From Memvar

	m.group   = Space(62) + "other than syphilis and HIV" 
	Insert Into cadr_tmp From Memvar

	m.group   = Space(53) + Iif(Isnull(t_48.t_d), Space(5)+'0',Str(t_48.t_d, 6, 0)) + "   Treatment for an STI (other than syphilis" 
	Insert Into cadr_tmp From Memvar
	
	m.group   = Space(62) + "and HIV)" 
	Insert Into cadr_tmp From Memvar
	
	m.group   = Space(53) + Iif(Isnull(t_48.t_e), Space(5)+'0',Str(t_48.t_e, 6, 0)) + "   Screening/testing for hepatitis C"
	Insert Into cadr_tmp From Memvar

	m.group   = Space(53) + Iif(Isnull(t_48.t_f), Space(5)+'0',Str(t_48.t_f, 6, 0)) + "   Treatment for hepatitis C"
	Insert Into cadr_tmp From Memvar

* jss, 11/29/07, if values are null, must force a zero into field
	m.syphtest	= Iif(IsNull(t_48.t_a), '     0', TRAN(t_48.t_a,'999999'))
	m.syphtreat	= Iif(IsNull(t_48.t_b), '     0', TRAN(t_48.t_b,'999999'))
	m.othstitest= Iif(IsNull(t_48.t_c), '     0', TRAN(t_48.t_c,'999999'))
	m.othstitrea= Iif(IsNull(t_48.t_d), '     0', TRAN(t_48.t_d,'999999'))
	m.hepctest	= Iif(IsNull(t_48.t_e), '     0', TRAN(t_48.t_e,'999999'))
	m.hepctreat	= Iif(IsNull(t_48.t_f), '     0', TRAN(t_48.t_f,'999999'))

Use in all_48
Use in t_48

*--Q49
If Used('all_49')
   Use In all_49
Endif
   
	Select tc_id ;
	From ai_diag ;
	Where !Empty(hiv_icd9) ;
	and Between(diagdate,dStartDate, dEndDate) ;
	and tc_id+DTOS(diagdate) in (Select diag.tc_id+Min(DTOS(diag.diagdate)) ;
											From ai_diag diag ;
											Where !Empty(diag.hiv_icd9) ;
											Group by diag.tc_id) ;
	and tc_id in (Select tc_id From all_med) ;
	Union ;
	Select tc_id ;
	From hivstat ;
	Where hivstatus='10' ;
	and Between(effect_dt, dStartDate, dEndDate) ;
	and tc_id + status_id in (Select h.tc_id + Min(h.Status_id) ;
										From hivstat h ;
										Where h.hivstatus='10' ;
										Group by h.tc_id) ;
	and tc_id in (Select tc_id From all_med) ;
	Into Cursor ;
		all_49

If Used('t_49')
   Use In t_49
Endif
	
	Select Count(*) as total ;
	From all_49 ;
	Into Cursor t_49

Use in all_49		

	m.group = "49.  Number of clients newly diagnosed with AIDS:    " + ;
              Iif(Isnull(t_49.total), Space(5)+'0',Str(t_49.total, 6, 0))
	m.info = 49	
	Insert Into cadr_tmp From Memvar
		
* jss, define memvars for extract's section 5
	m.newaids= TRAN(t_49.total,'999999')
Use in t_49

*--Q50		
If Used('all_50a')
   Use In all_50a
Endif

	Select tc_id From ai_activ ;
	Where close_code='10' ;
	and !Empty(death_dt) ;
	and Between(death_dt,dStartDate, dEndDate) ;
	and tc_id in (Select tc_id From all_med) ;
	Into Cursor ;
		all_50a

If Used('all_50b')
   Use In all_50b
Endif

	Select tc_id From ai_activ ;
	Where close_code='10' ;
	and Empty(death_dt) ;
	and Between(effect_dt,dStartDate, dEndDate) ;
	and tc_id in (Select tc_id From all_med) ;
	Into Cursor ;
		all_50b

If Used('all_50')
   Use In all_50
Endif
		
	Select tc_id from all_50a ;
	Union;
	Select tc_id from all_50b ;
	Into cursor ;
		all_50
		
Use in all_50a	
Use in all_50b	

If Used('t_50')
   Use In t_50
Endif

	Select Count(dist tc_id) as total ;
	From all_50 ;
	Into Cursor t_50
	
	m.group = "50.  Number of Hiv+ clients who died this period:    " + ;
            Iif(Isnull(t_50.total), Space(5)+'0', Str(t_50.total, 6, 0))
	m.info = 50	
	Insert Into cadr_tmp From Memvar
		
* jss, define memvars for extract's section 5
	m.hivdied= TRAN(t_50.total,'999999')
Use in t_50
			
* jss, 3/30/05, Q49(2004) becomes Q51(2005): also, salvage removed in 2005
*--Q51
   m.group = "51.  Number of clients on the following antiretroviral   "
	m.info = 51
	Insert Into cadr_tmp From Memvar

If Used('t_arv')
   Use In t_arv
Endif

*!*   		Select	;
*!*   			pres_his.client_id, pres_his.arv_ther ;
*!*   		From ;
*!*   			pres_his, all_med ;
*!*   		Where ;
*!*   			pres_his.client_id = all_med.client_id ;
*!*   		and ;
*!*   			Iif(!Empty(pres_his.dis_date), ;
*!*   				pres_his.dis_date >= dEndDate and pres_his.pres_date <= dEndDate, ;
*!*   				pres_his.pres_date <= dEndDate) ;
*!*   		and ;
*!*   			!Empty(pres_his.arv_ther) ;
*!*   		and ;
*!*   			pres_his.client_id + dtos(pres_his.pres_date) + pres_his.presh_id ;
*!*   						In (Select p2.client_id + Max(Dtos(p2.pres_date) + p2.presh_id) ;
*!*   							 From ;
*!*   							 	pres_his p2 ;
*!*   							 Where ;
*!*   							 		IIF(!Empty(p2.dis_date), ;
*!*   							 			p2.dis_date >= dEndDate and p2.pres_date <= dEndDate, ;
*!*   							 			p2.pres_date <= dEndDate) ;
*!*   								and ;
*!*   									!Empty(p2.arv_ther) ;
*!*   							 Group by p2.client_id) ;			
*!*   		Into Cursor t_arv

*!* ----------------------------------------------------------
*!*  PRE V8.6 CODE - THIS DOES NOT HAVE THE CONTINUATION FLAG
*!* ----------------------------------------------------------
*!*        Select;
*!*            pres_his.client_id, pres_his.arv_ther ;
*!*         From ;
*!*            pres_his, all_med ;
*!*         Where ;
*!*            pres_his.client_id = all_med.client_id ;
*!*         and ;
*!*            Iif(!Empty(pres_his.arv_end), ;
*!*               pres_his.arv_end >= dEndDate and pres_his.arv_start <= dEndDate, ;
*!*               pres_his.arv_start <= dEndDate) ;
*!*         and ;
*!*            !Empty(pres_his.arv_ther) ;
*!*         and ;
*!*            pres_his.client_id + dtos(pres_his.arv_start) + pres_his.presh_id ;
*!*                     In (Select p2.client_id + Max(Dtos(p2.arv_start) + p2.presh_id) ;
*!*                         From ;
*!*                            pres_his p2 ;
*!*                         Where ;
*!*                               IIF(!Empty(p2.arv_end), ;
*!*                                  p2.arv_end >= dEndDate and p2.arv_start <= dEndDate, ;
*!*                                  p2.arv_start <= dEndDate) ;
*!*                           and ;
*!*                              !Empty(p2.arv_ther) ;
*!*                         Group by p2.client_id) ;         
*!*         Into Cursor t_arv
*!* ----------------------------------------------------------


Select;
   pres_his.client_id, ;
   pres_his.arv_ther ;
From ;
   pres_his, all_med ;
Where ;
   pres_his.client_id = all_med.client_id ;
and ;
   Iif(!Empty(pres_his.arv_end), ;
      pres_his.arv_end >= dEndDate and pres_his.arv_start <= dEndDate, ;
      pres_his.arv_start <= dEndDate) ;
and ;
   !Empty(pres_his.arv_ther) ;
and ;
   pres_his.client_id + dtos(pres_his.arv_start) + pres_his.presh_id ;
            In (Select p2.client_id + Max(Dtos(p2.arv_start) + p2.presh_id) ;
                From ;
                   pres_his p2 ;
                Where ;
                      IIF(!Empty(p2.arv_end), ;
                         p2.arv_end >= dEndDate and p2.arv_start <= dEndDate, ;
                         p2.arv_start <= dEndDate) ;
                  and ;
                     !Empty(p2.arv_ther) ;
                Group by p2.client_id) ;         
Into Cursor t_arv
      
If Used('all_pres')
   Use In all_pres
Endif

Select * ;
From t_arv ;
Union ;
Select client_id, ; 
      Space(2) as arv_ther ;
From all_med ;
Where all_med.client_id Not in (Select client_id From t_arv) ;
Into Cursor ;
   all_pres   
         
Use in t_arv

If Used('t_51')
   Use In t_51
Endif

		Select Sum(Iif(arv_ther = "01", 1, 0)) as t_1, ;
				Sum(Iif(arv_ther = "02", 1, 0)) as t_2, ;
				Sum(Iif(arv_ther = "03" or arv_ther = "04" or arv_ther = "05", 1, 0)) as t_4, ;
				Sum(Iif(arv_ther = "06" or Empty(arv_ther), 1, 0)) as t_5, ;
				Count(*) as t_6 ;
		From all_pres ;
		Into Cursor t_51		
      
		m.group   = "     therapies at the end of reporting period:  " + Space(5) + ;
                  Iif(Isnull(t_51.t_1), Space(5)+'0', Str(t_51.t_1, 6, 0)) + "   None" 
		Insert Into cadr_tmp From Memvar

		m.group   = Space(53) + Iif(Isnull(t_51.t_2), Space(5)+'0',Str(t_51.t_2, 6, 0)) + "   HAART" 
		Insert Into cadr_tmp From Memvar

		m.group   = Space(53) + Iif(Isnull(t_51.t_4), Space(5)+'0',Str(t_51.t_4, 6, 0)) + "   Other (mono or dual therapy)" 
		Insert Into cadr_tmp From Memvar
		
		m.group   = Space(53) + Iif(Isnull(t_51.t_5), Space(5)+'0',Str(t_51.t_5, 6, 0)) + "   Unknown/Unreported" 
		Insert Into cadr_tmp From Memvar

		totart = t_51.t_1 + t_51.t_2 + t_51.t_4 + t_51.t_5  
		m.art_total	= Iif(IsNull(totart), '     0', TRAN(totart,'999999'))

		m.group   = Space(53) + Iif(Isnull(totart), Space(5)+'0',Str(totart, 6, 0)) + "   Total" 
		Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
* jss, 11/29/07, if values are null, must force a zero into field
		m.art_none	= Iif(IsNull(t_51.t_1), '     0', TRAN(t_51.t_1,'999999'))
		m.art_haart	= Iif(IsNull(t_51.t_2), '     0', TRAN(t_51.t_2,'999999'))
		m.art_other	= Iif(IsNull(t_51.t_4), '     0', TRAN(t_51.t_4,'999999'))
		m.art_unkn	= Iif(IsNull(t_51.t_5), '     0', TRAN(t_51.t_5,'999999'))

Use in all_pres
Use in t_51	

* jss, 3/30/05, Q50(2004) becomes Q52(2005)
*--Q52
If Used('tm_52')
   Use In tm_52
Endif

*!* #7425 v8.6 09/2010; Add PS to the 
Select ai_serv.tc_id ;
From ai_serv, ;
     lv_service, ;
     ai_enc, ;
     t_prog ;
Where ai_serv.service_id = lv_service.service_id;
  And !Empty(lv_service.cadrmap2) ;
  And Alltrim(lv_service.cadrmap2) = "52" ;
  And ai_serv.act_id = ai_enc.act_id ;
  And ai_enc.program = t_prog.prog_id ;
  And ai_enc.enc_id = lv_service.enc_id ;
  And ai_enc.serv_cat = lv_service.serv_cat ;
  And Between(ai_serv.date, dStartDate, dEndDate);
Union;
Select testres.tc_id ;
From testres ;
Where Between(testres.testdate,dStartDate, dEndDate) ;
    And testtype='PS';
    And tc_id in (Select tc_id From all_med Where hiv_pos =(.t.));
Into Cursor ;
   tm_52

*!*         Pre v8.6 code 
*!*   		Select ai_serv.tc_id ;
*!*   		From ai_serv, lv_service, ai_enc, t_prog ;
*!*   		Where ;
*!*   				ai_serv.service_id = lv_service.service_id and ;
*!*   				!Empty(lv_service.cadrmap2) and ;
*!*   				Alltrim(lv_service.cadrmap2) = "52" and ;
*!*   				ai_serv.act_id = ai_enc.act_id and ;
*!*   				ai_enc.program = t_prog.prog_id and ;
*!*   				ai_enc.enc_id = lv_service.enc_id and ;
*!*   				ai_enc.serv_cat = lv_service.serv_cat and ;
*!*   				between(ai_serv.date, dStartDate, dEndDate);
*!*   		Into Cursor ;
*!*   			tm_52

*** All HIV positive only
If Used('all_med5')
   Use In all_med5
Endif

	Select Count(Distinct tm_52.tc_id) as total ;
	From tm_52, hivstat, hstat ;
	Where tm_52.tc_id = hivstat.tc_id and ;
			Dtoc(hivstat.effect_dt) + hivstat.tc_id  In (Select Dtoc(Max(f2.effect_dt)) + f2.tc_id ;
										From ;
											hivstat f2 ;
										Where ;
											f2.effect_dt <= dEndDate Group by f2.tc_id)  and ;
			hivstat.hivstatus = hstat.code and ;
			hstat.hiv_pos = .t. ;
	Into Cursor	all_med5

Use in tm_52
* jss, 11/20/07
*   m.group = "52.  Number of clients who received a Pelvic exam and "
   m.group =  "52.  Number clients receiving Pelvic exam & cervical "
	m.info = 52
	Insert Into cadr_tmp From Memvar
	
*	m.group   = "     Pap smear during this reporting period:   " + Space(6) + 
   m.group   = "     Pap test during this reporting period:    " + Space(6) + ;
                  Iif(Isnull(all_med5.total), Space(5)+'0',Str(all_med5.total, 6,0)) 
	Insert Into cadr_tmp From Memvar
	
* jss, 6/2, define memvars for extract's section 5
	m.pap	= TRAN(all_med5.total,'999999')

Use in all_med5	

* jss, 3/30/05, Q51-Q55 (2004) becomes Q53a-e (2005). Also, add HIV indeterminate and HIV negative to children born to HIV+ mothers (now Q53e) 
*--Q53
   m.group = "53.  Pregnant Women:"
	m.info = 53
	Insert Into cadr_tmp From Memvar
   m.group = " a.  Number of clients who are HIV positive who were     "
	Insert Into cadr_tmp From Memvar

If Used('all_preg')	
   Use In all_preg   
Endif

	Select	Distinct pregnant.tc_id, ;
					pregnant.azt_preg, ;
					pregnant.azt_del, ;
					pregnant.birth_type, ;
					pregnant.numhivpos, ;
					pregnant.care_start, ;
					pregnant.conf_dt, ;
					pregnant.del_dt, ;
					pregnant.proj_dt ;
			From pregnant, all_med  ;
			Where ;
				pregnant.tc_id = all_med.tc_id and ;
				Iif(Between(pregnant.conf_dt, dStartDate, dEndDate), .t., ;
				Iif(!Empty(pregnant.del_dt) and Between(pregnant.del_dt, dStartDate, dEndDate), .t., ;
				Iif(!Empty(pregnant.del_dt) and pregnant.del_dt < dStartDate,.f., ;
				Iif(!Empty(pregnant.del_dt) and pregnant.del_dt > dEndDate and pregnant.del_dt <= (dEndDate+270),.t., ;
				Iif(!Empty(pregnant.proj_dt) and Between(pregnant.proj_dt, dStartDate, dEndDate), .t., ;
				Iif(!Empty(pregnant.proj_dt) and pregnant.proj_dt < dStartDate,.f., ;
				Iif(!Empty(pregnant.proj_dt) and pregnant.proj_dt > dEndDate and pregnant.proj_dt <= (dEndDate+270),.t., .f.)))))));
			Into Cursor ;
				all_preg	

If Used('t_51')   
   Use In t_51   
Endif

			Select Count(Distinct tc_id+dtoc(proj_dt)) as total ; 
			From all_preg ;
			Into Cursor t_51

		m.group   = "     pregnant during this reporting period:  " + Space(8) + ;
                  Iif(Isnull(t_51.total), Space(5)+'0',Str(t_51.total, 6, 0))
		Insert Into cadr_tmp From Memvar
* jss, 6/2, define memvars for extract's section 5
		m.hivpospreg = TRAN(t_51.total,'999999')

Use in t_51
   m.group = " b.  Of the number of pregnant clients who are "
	Insert Into cadr_tmp From Memvar

	savdecimal=SET('DECIMALS')
	SET DECIMALS TO 0

If Used('t_start')
   Use In t_start
Endif
   
	Select Iif(care_start > 0, VAL(TRAN(care_start,'999')), ;
		    Iif(!Empty(del_dt) and del_dt = conf_dt, 300, ;
		    Iif(!Empty(del_dt), (270-(del_dt - conf_dt)), ;
		    Iif(!Empty(proj_dt), (270-(proj_dt - conf_dt)), 400)))) as cr_start, care_start ;
	From all_preg ;
	Into Cursor t_start

	SET DECIMALS TO (SAVDECIMAL)

If Used('t_52')
   Use In t_52
Endif
   
	Select Sum(Iif(care_start > 0, Iif(Between(care_start, 1, 3), 1, 0), Iif(Between(cr_start, 0, 90), 1, 0))) as t1, ;
			Sum(Iif(care_start > 0, Iif(Between(care_start, 4, 6), 1, 0), Iif(Between(cr_start, 91, 180),1,0))) as t2, ;
			Sum(Iif(care_start > 0, Iif(Between(care_start, 7, 9), 1, 0), Iif(Between(cr_start, 181, 270),1,0))) as t3, ;
			Sum(Iif(cr_start >= 300, 1, 0)) as t4 ;
	From t_start ;
	Into Cursor t_52
	
	m.group   = "     HIV positive, number entering care in the: " + Space(5) + ;
               Iif(Isnull(t_52.t1), Space(5)+'0', Str(t_52.t1, 6, 0)) + "   First trimester" 
	Insert Into cadr_tmp From Memvar	
	
	m.group   = Space(53) + Iif(Isnull(t_52.t2), Space(5)+'0', Str(t_52.t2, 6, 0)) + "   Second trimester" 
	Insert Into cadr_tmp From Memvar

	m.group   = Space(53) + Iif(Isnull(t_52.t3), Space(5)+'0', Str(t_52.t3, 6, 0)) + "   Third trimester" 
	Insert Into cadr_tmp From Memvar
	
	m.group   = Space(53) + Iif(Isnull(t_52.t4), Space(5)+'0', Str(t_52.t4, 6, 0)) + "   At time of delivery" 
	Insert Into cadr_tmp From Memvar

   * This is a required field and will never be 0
   m.group   = Space(59) + "   Unknown" 
   Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
* jss, 11/29/07, if values are null, must force a zero into field
	m.stage_1st = Iif(IsNull(t_52.t1), '     0', TRAN(t_52.t1,'999999'))
	m.stage_2nd = Iif(IsNull(t_52.t2), '     0', TRAN(t_52.t2,'999999'))
	m.stage_3rd = Iif(IsNull(t_52.t3), '     0', TRAN(t_52.t3,'999999'))
	m.stage_del = Iif(IsNull(t_52.t4), '     0', TRAN(t_52.t4,'999999'))
	totstage    = t_52.t1 + t_52.t2 + t_52.t3 + t_52.t4

	m.group   = Space(53) + Iif(Isnull(totstage), Space(5)+'0', Str(totstage, 6, 0)) + "   Total" 
	Insert Into cadr_tmp From Memvar

	m.stage_tot = Iif(IsNull(totstage), '     0', TRAN(totstage,'999999'))

Use in t_52	
Use in t_start

    m.group = " c.  Number of pregnant clients who received"
	Insert Into cadr_tmp From Memvar

If Used('t_53')	
   Use In t_53
Endif
   
	Select Count(distinct tc_id)  as total ;
	From all_preg;
	Where azt_del = 1 or ;
		azt_preg = 1 ;
	Into cursor t_53
	
	m.group   = "     antiretroviral meds to prevent the HIV " 
	Insert Into cadr_tmp From Memvar		
	
	m.group   = "     transmission to their children:" + Space(17) + ;
               Iif(Isnull(t_53.total), Space(5)+'0', Str(t_53.total, 6, 0))
	Insert Into cadr_tmp From Memvar		

* jss, 6/2, define memvars for extract's section 5
	m.pregonart = TRAN(t_53.total,'999999')

Use in t_53	
   m.group = " d.  Number of children delivered to clients who"
	Insert Into cadr_tmp From Memvar

If Used('t_54')	
   Use In t_54
Endif
   
   Select (Sum(Iif(birth_type = 1, 1, 0)) + Sum(Iif(birth_type = 2, 2, 0)) + ; 
			Sum(Iif(birth_type = 3, 3, 0)) + Sum(Iif(birth_type = 4, 1, 0))) as total ;
	From all_preg;
	Into cursor t_54
	
	m.group   = "     are HIV positive:" + Space(31) + ;
               Iif(Isnull(t_54.total), Space(5)+'0', Str(t_54.total, 6, 0))
	Insert Into cadr_tmp From Memvar		

* jss, 6/2, define memvars for extract's section 5
* jss, 11/29/07, if values are null, must force a zero into field
	m.childdeliv = Iif(IsNull(t_54.total), '     0', TRAN(t_54.total,'999999'))

If Used('t_55')
   Use In t_55
Endif
   
	Select Sum(numhivpos) as total ;
	From all_preg;
	Into cursor t_55

* jss, 12/7/07, now 3 categories, hiv-positive, confirmed; hiv-indeterminate; hiv_negative, confirmed
   m.group = " e.  HIV Status of Infants reported in Item 53d:" 
*   m.group = " e.  Number of children delivered HIV positive:" + Space(6) + ;
             Iif(Isnull(t_55.total), Space(5)+'0', Str(t_55.total, 6, 0))
   Insert Into cadr_tmp From Memvar
   m.group   = Space(53) + Iif(Isnull(t_55.total), Space(5)+'0', Str(t_55.total, 6, 0)) + "   HIV-positive, confirmed" 
   Insert Into cadr_tmp From Memvar

	t55btotal=IIF(t_54.total>t_55.total, t_54.total-t_55.total,0)
   m.group   = Space(53) + Iif(Isnull(t55btotal), Space(5)+'0', Str(t55btotal, 6, 0)) + "   HIV-indeterminate" 
   Insert Into cadr_tmp From Memvar

   m.group   = Space(53) + Space(5)+'0' + "   HIV-negative, confirmed" 
   Insert Into cadr_tmp From Memvar

* jss, 6/2, define memvars for extract's section 5
* jss, 11/29/07, if values are null, must force a zero into field
   m.childpos = Iif(IsNull(t_55.total), '     0', TRAN(t_55.total,'999999'))
	m.childind = TRAN(t55btotal,'999999')
	m.childneg = '     0'

*--Q54		
	m.group = "54.  Type of Quality Management Program for Assessment of Medical Providers:"
	m.info = 54	
	Insert Into cadr_tmp From Memvar

* jss, 4/14/05, define m.mgmtqual for extract's section 5 as well as m.dispmq to be used for print report
	Do Case
	Case cadrserv.qualmgmt=1
		m.mgmtqual='1'
		m.dispmq= 'None'
	Case cadrserv.qualmgmt=2
		m.mgmtqual='2'
		m.dispmq= 'New Quality Management Program'
	Case cadrserv.qualmgmt=3
		m.mgmtqual='3'
		m.dispmq= 'Established Quality Management Program'
	Case cadrserv.qualmgmt=4
		m.mgmtqual='4'
		m.dispmq= 'Established QM Program w/ Additional Quality Standards'
	Otherwise
		m.mgmtqual=' '	
		m.dispmq=' '
	Endcase	

	m.group = ''
	Insert Into cadr_tmp From Memvar
	m.group = Space(40) + Iif(Isnull(m.dispmq), '', m.dispmq)
	Insert Into cadr_tmp From Memvar
		
Use in t_54	
Use in t_55	
Use in all_preg
Use in all_med
return
***************
PROCEDURE sect6
***************
* jss, 6/2, define memvars for extract's section 6
	m.prvid  = agency.aar_id
	m.regcode = SPACE(5)
	m.prvname1 = TRIM(agency.descript1)+' '+TRIM(agency.descript2)
	m.RecId = LEFT(DTOS(dEndDate),6) + m.PrvID

* jss, 3/30/05, new Q55-58 for 2005
*--Q55: Title III client counts
If Used('all_h35a') 
   Use In all_h35a
Endif

	SELECT * ;
	FROM all_hiv ;
	WHERE cadr_map == "33A " ;
	INTO CURSOR all_h35a

* jss, 11/27/07, replace titles iii and iv with Part c and d:   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
*   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
*   m.part    = "Part 6.1. Title III Information"
   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/PART-SPECIFIC DATA FOR PARTS C AND D"
   m.part    = "Part 6.1. Part C Information"
   m.group = "55.  Total # of unduplicated clients during reporting period who were:"
	m.info = 55
	Insert Into cadr_tmp From Memvar

If Used('all_t3pos') 
   Use In all_t3pos
Endif

	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother, enr_req, prog_id ;
	From all_h35a ;
	Where elig_type = "01" and ;
			(fund_type ="03" or fund_type="13") and ;
		  	hiv_pos = .t. ; 
	Into Cursor all_t3pos

* now, count the number of hiv positive 
If Used('t_55aa') 
   Use In t_55aa
Endif

	Select Count(Dist tc_id) as Total ;
	From all_t3pos ;
	Into Cursor t_55aa

   m.group = " a."+Space(50)+  Iif(Isnull(t_55aa.total), Space(5)+'0', Str(t_55aa.total, 6, 0)) + "   HIV Positive"
	Insert Into cadr_tmp From Memvar

If Used('all_t3ind') 
   Use In all_t3ind
Endif

	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother, enr_req, prog_id  ;
	From all_h35a ;
	Where elig_type = "01" and ;
			(fund_type ="03" or fund_type="13") and ;
			tc_id In (Select tc_id From t_indet) ;
	  and tc_id Not In (Select tc_id from all_t3pos) ;		
	Into Cursor all_t3ind

* now, count the number of hiv indeterminate
If Used('t_55ab') 
   Use In t_55ab
Endif

	Select Count(Dist tc_id) as Total ;
	From all_t3ind ;
	Into Cursor t_55ab

   m.group = Space(53)+  Iif(Isnull(t_55ab.total), Space(5)+ '0', Str(t_55ab.total, 6, 0)) + "   HIV Indeterminate"
	Insert Into cadr_tmp From Memvar

	m.sect61posi=t_55aa.total+t_55ab.total
	m.skip_55_58=IIF(m.sect61posi=m.sect2posin, '1', '0')

* define memvars for extract section 6 (for Q55a)
	m.t3_pos = TRAN(t_55aa.total,'999999')
	m.t3_ind = TRAN(t_55ab.total,'999999')

Use in t_55aa
Use in t_55ab

* join the Title III HIV+ w/ the Title III HIV Indeterminates
If Used('all_t3') 
   Use In all_t3
Endif

	Select * From all_t3pos ;
	Union ;
	Select * From all_t3ind ;
	Into Cursor all_t3
	
&&&&&&&& next bit of code taken from Section 2
*** Clients are new intakes for title3
If Used('t_newin') 
   Use In t_newin
Endif

	Select Distinct all_t3.tc_id  ;
	From 	all_t3, ;
		  	ai_clien ;
	Where all_t3.enr_req = .f. and ;
			all_t3.tc_id = ai_clien.tc_id and ;
			between(ai_clien.placed_dt, dStartDate, dEndDate);
	Into Cursor	t_newin

*** Clients do not require enrollment - continuing
If Used('t_cont') 
   Use In t_cont
Endif

	Select Distinct all_t3.tc_id  ;
	From 	all_t3, ;
			ai_clien ;
	Where all_t3.enr_req = .f. and ;
			all_t3.tc_id = ai_clien.tc_id and ;
			ai_clien.placed_dt < dStartDate ;
	Into Cursor	t_cont

*** Clients require enrollment - continuing
If Used('t_contpr') 
   Use In t_contpr
Endif

	Select Distinct all_t3.tc_id  ;
	From all_t3, ;
		ai_prog ;
	Where all_t3.enr_req = .t. and ;
			ai_prog.tc_id = all_t3.tc_id and ;
			ai_prog.program = all_t3.prog_id and ;
			(ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			ai_prog.start_dt < dStartDate and ;
			all_t3.tc_id Not In (Select tc_id From t_cont)    ; 
	Into Cursor	t_contpr	
	
*** Client's require enrollment - new
If Used('t_temp') 
   Use In t_temp
Endif

	Select Distinct all_t3.tc_id  ;
	From all_t3, ;
		ai_prog ;
	Where all_t3.enr_req = .t. and ;
			ai_prog.tc_id = all_t3.tc_id and ;
			ai_prog.program = all_t3.prog_id and ;
			(ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			between(ai_prog.start_dt, dStartDate, dEndDate) ;
	Into Cursor t_temp

If Used('t_newpr') 
   Use In t_newpr
Endif
	
	Select * ;
	From t_temp ;
	Where ; 		
			t_temp.tc_id Not In (Select tc_id From t_cont) and ;
			t_temp.tc_id Not In (Select tc_id From t_contpr) ;
	Into Cursor	t_newpr	
	
	Use in t_temp
	Use in t_cont
	Use in t_contpr

*** Combine to one new client cursor
If Used('t_new') 
   Use In t_new
Endif

	Select * ;
	From t_newin ;
	Union ;
	Select * ;
	From t_newpr ;
	Into Cursor t_new

	Use in t_newin
	Use in t_newpr
	
&&&&&&&& end of new client code taken from section 2
If Used('t_55b') 
   Use In t_55b
Endif

	Select Count(Dist tc_id) as total ;
	From t_new ;
	Into Cursor t_55b
   
Use in t_new
   m.group = " b. Total number of New HIV+/Indeterminate Clients:" + Space(2)+  ;
             Iif(Isnull(t_55b.total), Space(5)+'0', Str(t_55b.total, 6, 0))
	Insert Into cadr_tmp From Memvar

* define memvars for extract section 6 (for Q55b)
	m.t3_posind = TRAN(t_55b.total,'999999')

Use in t_55b

*--Q56: Gender of Title III HIV+/indeterminate clients
   m.group = "56.  Gender of HIV+/indeterminate clients reported in #55a:"
	m.info = 56
	Insert Into cadr_tmp From Memvar

If Used('all_t3gen') 
   Use In all_t3gen
Endif

	Select Distinct tc_id, gender From all_t3 Into Cursor all_t3gen

If Used('t3_gen') 
   Use In t3_gen
Endif

	Select 	Sum(Iif(gender='11',1, 0)) as tot_mal1, ;
				Sum(Iif(gender='10',1, 0)) as tot_fem1, ;
				Sum(Iif((gender = '12' or gender = '13'),1,0)) as tot_tr1, ;				
				Sum(iif(Empty(gender), 1, 0)) as tot_un1, ;
				Count(*) as total1 ;
		From all_t3gen ;
		Into Cursor t3_gen

Use in all_t3gen
	
   m.group = SPACE(53) + Iif(Isnull(t3_gen.tot_mal1), Space(5)+'0', Str(t3_gen.tot_mal1, 6, 0)) + "   Male"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_gen.tot_fem1), Space(5)+'0', Str(t3_gen.tot_fem1, 6, 0)) + "   Female"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_gen.tot_tr1), Space(5)+'0', Str(t3_gen.tot_tr1, 6, 0))  + "   Transgender"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_gen.tot_un1), Space(5)+'0', Str(t3_gen.tot_un1, 6, 0))  + "   Unknown/Unreported"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_gen.total1), Space(5)+'0', Str(t3_gen.total1, 6, 0))   + "   Total"
	Insert Into cadr_tmp From Memvar

* define memvars for extract section 6 (for Q56)
* jss, 11/29/07, if values are null, must force a zero into field
	m.t3_male   = Iif(IsNull(t3_gen.tot_mal1), '     0', TRAN(t3_gen.tot_mal1,'999999'))
	m.t3_female = Iif(IsNull(t3_gen.tot_fem1), '     0', TRAN(t3_gen.tot_fem1,'999999'))
	m.t3_trans  = Iif(IsNull(t3_gen.tot_tr1),  '     0', TRAN(t3_gen.tot_tr1,'999999'))
	m.t3_unkgen = Iif(IsNull(t3_gen.tot_un1),  '     0', TRAN(t3_gen.tot_un1,'999999'))
	m.t3_totgen = Iif(IsNull(t3_gen.total1),   '     0', TRAN(t3_gen.total1,'999999'))

Use in t3_gen
	
*--Q57 Gender of Title III HIV+/indeterminate clients
   m.group = "57.  Age of HIV+/indeterminate clients reported in #55a:"
	m.info = 57
	Insert Into cadr_tmp From Memvar

If Used('all_t3age')
   Use In all_t3age
Endif
   
	Select Distinct tc_id, dob, cl_age From all_t3 Into Cursor all_t3age

If Used('t3_age')
   Use In t3_age
Endif

	Select  ;
			Sum(Iif((cl_age < 2 and !Empty(dob)), 1, 0)) as tot1, ;
			Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot2, ;
			Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot3, ;
			Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot4, ;
			Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot5, ;
			Sum(iif(cl_age >= 65, 1, 0)) as tot6, ;
			Sum(iif(Empty(dob), 1, 0)) as tot7, ;
			Count(*) as total ;
	From all_t3age ;
	Into Cursor t3_age

Use in all_t3age

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot1), Space(5)+'0',Str(t3_age.tot1, 6, 0)) + "   Less than 2 years"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot2), Space(5)+'0', Str(t3_age.tot2, 6, 0)) + "   2-12 years"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot3), Space(5)+'0', Str(t3_age.tot3, 6, 0)) + "   13-24 years"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot4), Space(5)+'0', Str(t3_age.tot4, 6, 0)) + "   25-44 years"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot5), Space(5)+'0', Str(t3_age.tot5, 6, 0)) + "   45-64 years"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot6), Space(5)+'0', Str(t3_age.tot6, 6, 0)) + "   65 years or older"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.tot7), Space(5)+'0', Str(t3_age.tot7, 6, 0)) + "   Unknown/unreported"
	Insert Into cadr_tmp From Memvar

   m.group = SPACE(53) + Iif(Isnull(t3_age.total), Space(5)+'0', Str(t3_age.total, 6, 0)) + "   Total"
	Insert Into cadr_tmp From Memvar

* define memvars for extract section 6 (for Q57)
* jss, 11/29/07, if values are null, must force a zero into field
	m.t3_0_1    = Iif(IsNull(t3_age.tot1),  '     0', TRAN(t3_age.tot1,'999999'))
	m.t3_2_12   = Iif(IsNull(t3_age.tot2),  '     0', TRAN(t3_age.tot2,'999999'))
	m.t3_13_24  = Iif(IsNull(t3_age.tot3),  '     0', TRAN(t3_age.tot3,'999999'))
	m.t3_25_44  = Iif(IsNull(t3_age.tot4),  '     0', TRAN(t3_age.tot4,'999999'))
	m.t3_45_64  = Iif(IsNull(t3_age.tot5),  '     0', TRAN(t3_age.tot5,'999999'))
	m.t3_65plus = Iif(IsNull(t3_age.tot6),  '     0', TRAN(t3_age.tot6,'999999'))
	m.t3_unkage = Iif(IsNull(t3_age.tot7),  '     0', TRAN(t3_age.tot7,'999999'))
	m.t3_totage = Iif(IsNull(t3_age.total), '     0', TRAN(t3_age.total,'999999'))

Use in t3_age

*--Q58 Race/Ethnicity of Title III HIV+/indeterminate clients
*!*   	m.group   = "58.  Race/Ethnicity of HIV+/indeterminate clients reported in #55a:"
*!*   	m.info = 58	
*!*   	Insert Into cadr_tmp From Memvar

If Used('all_t3race')
   Use In all_t3race
Endif
   
	Select Distinct tc_id, ;
			white, blafrican, hispanic, asian, ;
			hawaisland, indialaska, unknowrep, someother ;
	From all_t3 ;
	Into Cursor all_t3race

** PB 12/2008 Hispanic
If Used('t3_race')
   Use In t3_race
Endif
   ** Hispanic
   Select  ;
         Sum(Iif(white = 1 and hispanic = 2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot1, ;
         Sum(Iif(blafrican = 1 and hispanic = 2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot2, ;
         Sum(Iif(asian = 1 and hispanic = 2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot3, ;
         Sum(Iif(hawaisland = 1 and hispanic = 2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot4, ;
         Sum(Iif(indialaska = 1 and hispanic=2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot5, ;
         Sum(Iif((white + blafrican + asian + hawaisland + indialaska + someother) > 1 and hispanic=2, 1, 0)) as tot6, ;
         Sum(Iif(((unknowrep = 1 or someother = 1) and hispanic = 2 and ;
            (white + blafrican + asian + hawaisland + indialaska) = 0) or ;
            (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot7, ;
         Count(*) as total ;
   From all_t3race ;
   Where hispanic = 2; 
   Into Cursor t3_race
   

** PB 12/2008 Q58 Non-hispanic
If Used('t3_race1')
   Use In t3_race1
Endif
   ** Non-hispanic
   Select  ;
     Sum(Iif(white = 1 and hispanic<>2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot1, ;
     Sum(Iif(blafrican = 1 and hispanic<>2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot2, ;
     Sum(Iif(asian = 1 and hispanic<>2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot3, ;
     Sum(Iif(hawaisland = 1 and hispanic<>2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot4, ;
     Sum(Iif(indialaska = 1 and hispanic<>2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot5, ;
     Sum(Iif((white + blafrican + asian + hawaisland + indialaska + someother) > 1 and hispanic<>2, 1, 0)) as tot6, ;
     Sum(Iif(((unknowrep = 1 or someother = 1) and hispanic <> 2 and ;
              (white + blafrican + asian + hawaisland + indialaska) = 0) Or ;
                 (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot7, ;
         Count(*) as total ;
   From all_t3race ;
   Where hispanic <> 2; 
   Into Cursor t3_race1

   m.group = "58.  Race/Ethnicity of HIV+/indeterminate clients reported in #55a:"+Chr(13)+;
             "Number of Clients                          Hispanic    Non-Hispanic"
   m.info = 58
   Insert Into cadr_tmp From Memvar

   m.group = "American Indian or Alaska Native             "+Transform(Nvl(t3_race.tot5,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot5,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "Asian                                        "+Transform(Nvl(t3_race.tot3,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot3,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "Black or African/American                    "+Transform(Nvl(t3_race.tot2,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot2,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "Native Hawaiian / Other Pacific Islander     "+Transform(Nvl(t3_race.tot4,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot4,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "White                                        "+Transform(Nvl(t3_race.tot1,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot1,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "More than one race                           "+Transform(Nvl(t3_race.tot6,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot6,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "Not Reported                                 "+Transform(Nvl(t3_race.tot7,0),'999999')+Space(15)+Transform(Nvl(t3_race1.tot7,0),'999999')
   Insert Into cadr_tmp From Memvar

   m.group = "Total                                        "+Transform(Nvl(t3_race.total,0),'999999')+Space(15)+Transform(Nvl(t3_race1.total,0),'999999')
   Insert Into cadr_tmp From Memvar

*!*  Hispanic
   m.t3_hwhite = Iif(IsNull(t3_race.tot1),   '     0', TRAN(t3_race.tot1,'999999'))
   m.t3_hblack = Iif(IsNull(t3_race.tot2),   '     0', TRAN(t3_race.tot2,'999999'))
   m.t3_hasian = Iif(IsNull(t3_race.tot3),   '     0', TRAN(t3_race.tot3,'999999'))
   m.t3_hhawaii = Iif(IsNull(t3_race.tot4),   '     0', TRAN(t3_race.tot4,'999999'))
   m.t3_hnative = Iif(IsNull(t3_race.tot5),   '     0', TRAN(t3_race.tot5,'999999'))
   m.t3_hmorth1 = Iif(IsNull(t3_race.tot6),   '     0', TRAN(t3_race.tot6,'999999'))
   m.t3_hunkrac = Iif(IsNull(t3_race.tot7),   '     0', TRAN(t3_race.tot7,'999999'))
   m.t3_htotrac = Iif(IsNull(t3_race.total),  '     0', TRAN(t3_race.total,'999999'))

*!* Non-hispanic
   m.t3_white = Iif(IsNull(t3_race1.tot1),   '     0', TRAN(t3_race1.tot1,'999999'))
   m.t3_black = Iif(IsNull(t3_race1.tot2),   '     0', TRAN(t3_race1.tot2,'999999'))
   m.t3_asian = Iif(IsNull(t3_race1.tot3),   '     0', TRAN(t3_race1.tot3,'999999'))
   m.t3_hawaii  = Iif(IsNull(t3_race1.tot4),   '     0', TRAN(t3_race1.tot4,'999999'))
   m.t3_native  = Iif(IsNull(t3_race1.tot5),   '     0', TRAN(t3_race1.tot5,'999999'))
   m.t3_moreth1 = Iif(IsNull(t3_race1.tot6),   '     0', TRAN(t3_race1.tot6,'999999'))
   m.t3_unkrace = Iif(IsNull(t3_race1.tot7),   '     0', TRAN(t3_race1.tot7,'999999'))
   m.t3_totrace = Iif(IsNull(t3_race1.total),  '     0', TRAN(t3_race1.total,'999999'))

Use In t3_race
Use In t3_race1

*** For transfer to  next page
* jss, 11/28/07, force page_ej
*!*   m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) 

         

*** Section 6 Q59 - 61
DO rpt_cadr_59n 
*!*   * jss, 4/1/05, for 2005 (part 6.1 and part 6.2, Q62-Q70)
DO rpt_cadr_62n
* jss, 4/4/05, Cadr_71n new for 2005, Part 6.2, Q71-Q73 (replace Q65, 67, 68 from 2005, Q66 (ethnicity) 2004 is completely removed in 2005)
DO rpt_cadr_71n
Return

********************
PROCEDURE ProgExists
********************
* jss, 10/20/04, this procedure determines if either a ryan white eligible(elig_type='01') 
*                or ryan white funded(fund_type='05') program exists
Select * ;
From 	Program ;
Where Active=1 ;
  and	(Elig_type='01' or Fund_Type='05') ;
Into Array ;
	GetExists
	
RETURN (_tally>0)	
*****************
PROCEDURE clos_em
*****************
IF USED('all_hiv')
   Use in all_hiv
ENDIF   
IF USED('cadr_tmp')
   Use in cadr_tmp
ENDIF   
IF USED('t_cadr')
   Use in t_cadr
ENDIF   
IF USED('t_prog')
   Use in t_prog
ENDIF   
IF USED('t_new')
   Use in t_new
ENDIF  
If Used('t_prog') 
   Use In t_prog
Endif
If Used('tEncAll')   
   Use In tEncAll
Endif
   
Return