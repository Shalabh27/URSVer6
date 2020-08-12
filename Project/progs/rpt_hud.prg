Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

cAgency_ID   = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CAGENCY_ID"
      cAgency_ID = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()
****************************************************
* Program: 	Hud40118.prg
* Author:	jss 
* Date:		10/6/04
* Summary: 	Creates HUD report 40118 for Connecticut
****************************************************
PRIVATE gchelp
gchelp = "Generating HUD 40118 Report"
* default dates are 1st of year to current date
cTitle="HUD 40118 Report"
If Used('hud_tmp')
   Use in hud_tmp
EndIf
   
Create Cursor hud_tmp (part N(1), question N(2), detailline M, headerline M)

*!*   IF CreatRpt()
*!*   	Select Hud_tmp
*!*   	DO PrintDoc WITH "HU"
*!*   ELSE
*!*      =msg2user('INFORM', 'Unable to Create HUD40118 Report...Exiting')
*!*      RETURN
*!*   ENDIF	
*!*   RETURN
*!*   ******************
*!*   PROCEDURE CreatRpt
******************
***VT 11/11/2011 AIRS-183 
oldgcTC_id=gcTC_id
gcTC_id =''
=OpenView("lv_verification_filtered", "urs")
Requery('lv_verification_filtered')
gcTC_id=oldgcTC_id
**VT End					
					
Store 0 to m.snif_1a, m.nadif_1a, m.cif_1a, m.nfam_1a
m.part=1
*******************************************************************************************************
m.question=1
m.detailline=''
m.headerline='1. Projected Level of Persons to be served at a given point in time.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.headerline='                                       Number of        Number of    Number of     Number '
Insert Into hud_tmp From Memvar
m.headerline='                                       Singles Not in   Adults in    Children in   of'
Insert Into hud_tmp From Memvar
m.headerline='                                       Families         Families     Families      Families'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='a. Persons to be served at a               ' && we are just going to give the headers, let them fill in rest ...+ STR(m.snif_1a,6,0) + SPACE(10) + STR(m.nadif_1a,6,0) + SPACE(10) + STR(m.cif_1a,6,0) + SPACE(10) + STR(m.nfam_1a,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='        given point in time.'
Insert Into hud_tmp From Memvar
 
*******************************************************************************************************
m.question=2

Store 0 to m.snif_2a, m.nadif_2a, m.cif_2a, m.nfam_2a
Store 0 to m.snif_2b, m.nadif_2b, m.cif_2b, m.nfam_2b
Store 0 to m.snif_2c, m.nadif_2c, m.cif_2c, m.nfam_2c
Store 0 to m.snif_2d, m.nadif_2d, m.cif_2d, m.nfam_2d

***********************************************
* first, let's determine the HUD/HOPWA programs
If Used('tProg')
   Use in tProg
EndIf
   
Select ;
		prog_id ;
From ;
		program ;
Where ;
		fund_type='09' ;
	Or fund_type='10' ;
Into Cursor ;
		tProg
		
********************************************************************************************************
* now, let's get all tc_id's, client_id's, gender's, and dob's of clients associated with these programs		
If Used('tProgCli') 
   Use in tProgCli 
EndIf
   
Select ;
		ai_prog.tc_id, ;
		ai_clien.client_id, ;
		ai_clien.hudchronic, ;
		ai_clien.housing, ;
		ai_clien.hhead, ;
		ai_prog.start_dt, ;
		ai_prog.end_dt, ;
		ai_prog.reason, ;
		ai_prog.destinat, ;
		client.gender, ;
		client.hispanic, ;
		client.white, ;
		client.blafrican, ;
		client.asian, ;
		client.hawaisland, ;
		client.indialaska, ;
		client.someother, ;
		client.dob ;
From ;
		tProg, ;
		ai_prog, ;
		ai_clien, ;
		client ;	
Where ;
		ai_prog.program=tprog.prog_id ;
  And ai_prog.tc_id = ai_clien.tc_id ;		
  And ai_clien.client_id = client.client_id ;
Into Cursor ;
		tProgCli  

*******************************************************************************************
* now, let's see who is ENROLLED in a HUD/HOPWA program AS OF the operating year start date
If Used('EnrStart') 
   Use in EnrStart
EndIf

Select Distinct ;
		tc_id, ;
		client_id, ;
		start_dt, ;
		end_dt, ;
		hudchronic, ;
		housing, ;
		hhead, ;
		gender, ;
		hispanic, ;
		white, ;
		blafrican, ;
		asian, ;
		hawaisland, ;
		indialaska, ;
		someother, ;
		dob ;
From ;
		tProgCli ;
Where ;
		start_dt < date_from ;
  And	(Empty(end_dt) Or end_dt > date_from) ;
Into Cursor ;
		EnrStart				
****************************************************************************************
* next, let's see who is NEWLY ENROLLED in a HUD/HOPWA program DURING the operating year
If Used('EnrDuring') 
   Use in EnrDuring
EndIf

Select Distinct ;
		tc_id, ;
		client_id, ;
		start_dt, ;
		end_dt, ;
		hudchronic, ;
		housing, ;
		hhead, ;
		gender, ;
		hispanic, ;
		white, ;
		blafrican, ;
		asian, ;
		hawaisland, ;
		indialaska, ;
		someother, ;
		dob ;
From ;
		tProgCli ;
Where ;
		start_dt >= date_from ;
  And start_dt <= date_to ;
Into Cursor ;
		EnrDuring
		
*****************************************************************************
* next, get those who have LEFT a HUD/HOPWA program DURING the operating year
If Used('LeftDuring') 
   Use in LeftDuring
EndIf

Select Distinct ;
		tc_id, ;
		client_id, ;
		start_dt, ;
		end_dt, ;
		reason, ;
		destinat, ;
		hudchronic, ;
		housing, ;
		hhead, ;
		gender, ;
		hispanic, ;
		white, ;
		blafrican, ;
		asian, ;
		hawaisland, ;
		indialaska, ;
		someother, ;
		dob ;
From ;
		tProgCli ;
Where ;
		!EMPTY(end_dt) ;
  And end_dt >= date_from ; 		
  And end_dt <= date_to ; 		
Into Cursor ;
		LeftDuring

************************************************************************************************
* now, get first column of item 2a, adult singles not in families on first day of operating year
Select ;
		Count(tc_id) as snif_2a ;
From ;
		EnrStart ;
Where ;
		tc_id NOT IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array aSnif_2a
m.snif_2a=IIF(_tally=0,0,aSnif_2a(1))
Release aSnif_2a

******************************************************************************************	
* now, get first column of item 2b, singles not in families enrolled during operating year
Select ;
		Count(tc_id) as snif_2b ;
From ;
		EnrDuring ;
Where ;
		tc_id NOT IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array aSnif_2b
m.snif_2b=IIF(_tally=0,0,aSnif_2b(1))
Release aSnif_2b
	
**************************************************************************************************
* now, get first column of item 2c, singles not in families who left program during operating year
Select ;
		Count(tc_id) as snif_2c ;
From ;
		LeftDuring ;
Where ;
		tc_id NOT IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array aSnif_2c
m.snif_2c=IIF(_tally=0,0,aSnif_2c(1))
Release aSnif_2c
	
* now, calculate number of singles not in families on the last day of the operating year
m.snif_2d =	IIF(m.snif_2a + m.snif_2b < m.snif_2c, 0, m.snif_2a + m.snif_2b - m.snif_2c)

**************************************************************************************
* now, get second column of item 2a, adults in families on first day of operating year

Select ;
		Count(tc_id) as nadif_2a ;
From ;
		EnrStart ;
Where ;
		tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array aNadif_2a

m.nadif_2a=IIF(_tally=0,0,aNadif_2a(1))
Release aNadif_2a

****************************************************************************************	
* now, get second column of item 2b, adults in families enrolled during operating year
Select ;
		Count(tc_id) as nadif_2b ;
From ;
		EnrDuring ;
Where ;
		tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array aNadif_2b

m.nadif_2b=IIF(_tally=0,0,aNadif_2b(1))
Release aNadif_2b

****************************************************************************************
* now, get second column of item 2c, adults in families who left program during operating year
Select ;				
		Count(tc_id) as nadif_2c ;
From ;
		LeftDuring ;		
Where ;
		tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array aNadif_2c 
m.nadif_2c=IIF(_tally=0,0,aNadif_2c(1))
Release aNadif_2c

**************************************************************************************
* now, calculate number of adults in families on the last day of the operating year
m.nadif_2d  =	IIF(m.nadif_2a + m.nadif_2b < m.nadif_2c, 0, m.nadif_2a + m.nadif_2b - m.nadif_2c)

************************************************************************************************************
* get third column of item 2a, children in families of clients enrolled prior to first day of operating year

Select ;
		Count(ai_famil.client_id) as Cif_2a ;
From ;
		ai_famil, client ;
Where ;
		ai_famil.tc_id in (Select tc_id From EnrStart) ; 		
  And	ai_famil.member and ai_famil.wherelives=1 ;
  And !adult(client.dob, date_to) ;		
  And ai_famil.client_id=client.client_id ;
Into Array aCif_2a
m.Cif_2a=IIF(_tally=0,0,aCif_2a(1))
Release aCif_2a

*************************************************************************************************
* get third column of item 2b, children in families of clients who enrolled during operating year

Select ;
		Count(ai_famil.client_id) as Cif_2b ;
From ;
		ai_famil, client ;
Where ;
		ai_famil.tc_id in (Select tc_id From EnrDuring) ; 		
  And	ai_famil.member and ai_famil.wherelives=1 ;
  And !adult(client.dob, date_to) ;		
  And ai_famil.client_id=client.client_id ;
Into Array aCif_2b
m.Cif_2b=IIF(_tally=0,0,aCif_2b(1))
Release aCif_2b

*****************************************************************************************************
* get third column of item 2c, children in families of clients who left program during operating year

* now, count the CHILD collaterals related to any client enrolled AT START OF period
Select ;
		Count(ai_famil.client_id) as Cif_2c ;
From ;
		ai_famil, client ;
Where ;
		ai_famil.tc_id in (Select tc_id From LeftDuring) ; 		
  And	ai_famil.member and ai_famil.wherelives=1 ;
  And !adult(client.dob, date_to) ;		
  And ai_famil.client_id=client.client_id ;
Into Array aCif_2c
m.Cif_2c=IIF(_tally=0,0,aCif_2c(1))
Release aCif_2c

***************************************************************************************
* now, calculate number of children in families on the last day of the operating year
m.cif_2d  =	IIF(m.cif_2a + m.cif_2b < m.cif_2c, 0, m.cif_2a + m.cif_2b - m.cif_2c)

***************************************************************************************
* now, get fourth column of item 2a, number of families on first day of operating year
* define families as adult clients with family members
Select ;
		Count(tc_id) as nfam_2a ;
From ;
		EnrStart ;
Where ;
		hhead='Yes' ;
  And	tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array anfam_2a
m.nfam_2a=IIF(_tally=0,0,anfam_2a(1))
Release anfam_2a

* get fourth column of item 2b, number of families entering program during operating year
Select ;
		Count(tc_id) as nfam_2b ;
From ;
		EnrDuring ;
Where ;
		hhead='Yes' ;
  And	tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array anfam_2b
m.nfam_2b=IIF(_tally=0,0,anfam_2b(1))
Release anfam_2b	
	
* get fourth column of item 2c, number of families who left program during operating year
Select ;
		Count(tc_id) as nfam_2c ;
From ;
		LeftDuring ;
Where ;
		hhead='Yes' ;
  And	tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Array anfam_2c
m.nfam_2c=IIF(_tally=0,0,anfam_2c(1))
Release anfam_2c

*******************************************************************************************	
* calculate fourth column of item 2c, number of families on the last day of operating year
m.nfam_2d  =	IIF(m.nfam_2a + m.nfam_2b < m.nfam_2c, 0, m.nfam_2a + m.nfam_2b - m.nfam_2c)
*******************************************************************************************	

m.detailline=''
m.headerline='2. Persons Served during the operating year.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.headerline='                                       Number of        Number of    Number of     Number '
Insert Into hud_tmp From Memvar
m.headerline='                                       Singles Not in   Adults in    Children in   of'
Insert Into hud_tmp From Memvar
m.headerline='                                       Families         Families     Families      Families'
Insert Into hud_tmp From Memvar

m.headerline=''
m.detailline='a. Number on the first day of the          ' + STR(m.snif_2a,6,0) + SPACE(14) + STR(m.nadif_2a,6,0) + SPACE(11) + STR(m.cif_2a,6,0) + SPACE(11) + STR(m.nfam_2a,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='   operating year.'
Insert Into hud_tmp From Memvar

m.detailline='b. Number entering program during          ' + STR(m.snif_2b,6,0) + SPACE(14) + STR(m.nadif_2b,6,0) + SPACE(11) + STR(m.cif_2b,6,0) + SPACE(11) + STR(m.nfam_2b,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='   the operating year.'
Insert Into hud_tmp From Memvar

m.detailline='c. Number who left the program             ' + STR(m.snif_2c,6,0) + SPACE(14) + STR(m.nadif_2c,6,0) + SPACE(11) + STR(m.cif_2c,6,0) + SPACE(11) + STR(m.nfam_2c,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='   during the operating year.'
Insert Into hud_tmp From Memvar

m.detailline='d. Number in the program on the last       ' + STR(m.snif_2d,6,0) + SPACE(14) + STR(m.nadif_2d,6,0) + SPACE(11) + STR(m.cif_2d,6,0) + SPACE(11) + STR(m.nfam_2d,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='   day of the operating year. (2a+2b-2c=2d)'
Insert Into hud_tmp From Memvar

m.question=3
m.detailline=''
m.headerline='3. Project Capacity.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.headerline='                                       Number of        Number of    Number of     Number '
Insert Into hud_tmp From Memvar
m.headerline='                                       Singles Not in   Adults in    Children in   of'
Insert Into hud_tmp From Memvar
m.headerline='                                       Families         Families     Families      Families'
Insert Into hud_tmp From Memvar

m.headerline=''
m.snif_3a=m.snif_2d
m.nfam_3a=m.nfam_2d
m.detailline='a. Number on last day (from 2d,            ' + STR(m.snif_3a,6,0) + SPACE(46) + STR(m.nfam_3a,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='   columns 1 and 4)'
Insert Into hud_tmp From Memvar
m.detailline='b. Number proposed in application (from    ' 
Insert Into hud_tmp From Memvar
m.detailline='   1a, columns 1 and 4)'
Insert Into hud_tmp From Memvar
m.detailline='c. Capacity Rate (divide a by b) = %       ' 
Insert Into hud_tmp From Memvar

m.question=4

m.detailline=''
m.headerline='4. Non-homeless persons. (Sec. 8 SRO projects only)'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='How many income-eligible non-homeless persons were housed by the SRO program during the    '
Insert Into hud_tmp From Memvar
m.detailline='operating year?'
Insert Into hud_tmp From Memvar
************************************************************************************************************
* now, determine the counts by GENDER AND AGE FOR SINGLES NOT IN FAMILIES enrolled during the operating year
* calculate ages based on end of operating period
m.question=5

Store 0 to m.spf_5a,m.spm_5a,m.spo_5a,m.spf_5b,m.spm_5b,m.spo_5b,m.spf_5c,m.spm_5c,m.spo_5c
Store 0 to m.spf_5d,m.spm_5d,m.spo_5d,m.spf_5e,m.spm_5e,m.spo_5e,m.spf_5ng,m.spm_5ng,m.spo_5ng
Store 0 to m.piff_5f,m.pifm_5f,m.pifo_5f,m.piff_5g,m.pifm_5g,m.pifo_5g,m.piff_5h,m.pifm_5h,m.pifo_5h
Store 0 to m.piff_5i,m.pifm_5i,m.pifo_5i,m.piff_5j,m.pifm_5j,m.pifo_5j,m.piff_5k,m.pifm_5k,m.pifo_5k
Store 0 to m.piff_5l,m.pifm_5l,m.pifo_5l,m.piff_5m,m.pifm_5m,m.pifo_5m,m.piff_5ng,m.pifm_5ng,m.pifo_5ng
				
*Select ;
*		'X' as Grouper, ;
*		tc_id, ;
*		gender, ;
*		IIF(!EMPTY(dob),GetAge(date_to, dob),999) as age;
*From ;
*		EnrDuring ;
*Where ;
*		tc_id NOT IN (Select tc_id From ai_famil Where member and wherelives=1)	;
*Into Cursor ;
*		SnifAgeGen

If Used('SnifAgeGn1') 
   Use in SnifAgeGn1
EndIf

If Used('SnifAgeGen') 
   Use in SnifAgeGen
EndIf

Select 'X' as Grouper, ;
		tc_id, ;
		gender, ;
		dob, ;
		000 as Age ;
From ;
		EnrDuring ;
Where ;
		tc_id NOT IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Cursor ;
		SnifAgeGn1
		
oApp.ReOpenCur('SnifAgeGn1','SnifAgeGen')
Replace All Age with IIF(!EMPTY(dob),GetAge(date_to, dob),999)		
				
Select ;
		Grouper, ;
		Sum(IIF(age >=62 and age <> 999 and gender='10', 1, 0)) As spf_5a, ;		
		Sum(IIF(age >=62 and age <> 999 and gender='11', 1, 0)) As spm_5a, ;		
		Sum(IIF(age >=62 and age <> 999 and gender<>'10' and gender<>'11', 1, 0)) As spo_5a, ;		
		Sum(IIF(age >=51 and age <  62  and gender='10', 1, 0)) As spf_5b, ;		
		Sum(IIF(age >=51 and age <  62  and gender='11', 1, 0)) As spm_5b, ;		
		Sum(IIF(age >=51 and age <  62  and gender<>'10' and gender<>'11', 1, 0)) As spo_5b, ;		
		Sum(IIF(age >=31 and age <  51  and gender='10', 1, 0)) As spf_5c, ;		
		Sum(IIF(age >=31 and age <  51  and gender='11', 1, 0)) As spm_5c, ;		
		Sum(IIF(age >=31 and age <  51  and gender<>'10' and gender<>'11', 1, 0)) As spo_5c  ;		
From ;
		SnifAgeGen ;
Group by ;
		Grouper ;
Into Array ;
		aSpGen5a		
		
If _tally>0
	m.spf_5a =aSpGen5a(2)
	m.spm_5a =aSpGen5a(3)
	m.spo_5a =aSpGen5a(4)
	m.spf_5b =aSpGen5a(5)
	m.spm_5b =aSpGen5a(6)
	m.spo_5b =aSpGen5a(7)
	m.spf_5c =aSpGen5a(8)
	m.spm_5c =aSpGen5a(9)
	m.spo_5c =aSpGen5a(10)
Endif
Release aSpGen5a

Select ;
		Grouper, ;
		Sum(IIF(age >=18 and age <  31  and gender='10', 1, 0)) As spf_5d, ;		
		Sum(IIF(age >=18 and age <  31  and gender='11', 1, 0)) As spm_5d, ;		
		Sum(IIF(age >=18 and age <  31  and gender<>'10' and gender<>'11', 1, 0)) As spo_5d, ;		
		Sum(IIF(age < 18 and gender='10', 1, 0)) As spf_5e, ;		
		Sum(IIF(age < 18 and gender='11', 1, 0)) As spm_5e, ;		
		Sum(IIF(age < 18 and gender<>'10' and gender<>'11', 1, 0)) As spo_5e, ;		
		Sum(IIF(age =999 and gender='10', 1, 0)) As spf_5ng, ;		
		Sum(IIF(age =999 and gender='11', 1, 0)) As spm_5ng, ;		
		Sum(IIF(age =999 and gender<>'10' and gender<>'11', 1, 0)) As spo_5ng ;				
From ;
		SnifAgeGen ;
Group by ;
		Grouper ;
Into Array ;
		aSpGen5b		
		
If _tally>0
	m.spf_5d =aSpGen5b(2)
	m.spm_5d =aSpGen5b(3)
	m.spo_5d =aSpGen5b(4)
	m.spf_5e =aSpGen5b(5)
	m.spm_5e =aSpGen5b(6)
	m.spo_5e =aSpGen5b(7)
	m.spf_5ng=aSpGen5b(8)
	m.spm_5ng=aSpGen5b(9)
	m.spo_5ng=aSpGen5b(10)
Endif	
Release aSpGen5b

************************************************************************************************************
* now, determine the counts by GENDER AND AGE FOR PERSONS IN FAMILIES enrolled during the operating year
* this gets the enrollees that have families
If Used('EnrDurFam') 
   Use in EnrDurFam
EndIf

Select ;
		tc_id, ;
		client_id, ;
		gender, ;
		dob ;		
From ;
		EnrDuring ;
Where ;
		tc_id IN (Select tc_id From ai_famil Where member and wherelives=1)	;
Into Cursor ;
		EnrDurFam

* combine the enrollees with families with their collateral children
If Used('AllEnrFam') 
   Use in AllEnrFam 
EndIf

Select ;
		client_id, ;
		gender, ;
		dob ;		
From ;
		EnrDurFam ;				
Union ;
Select ;
		ai_famil.client_id, ;
		client.gender, ;
		client.dob ;
From ;
	 	ai_famil, ;
	 	client ;
Where ;
		ai_famil.client_id = client.client_id ;
  And	ai_famil.tc_id IN (Select tc_id From EnrDurFam) ;
  And ai_famil.member ;
  And ai_famil.wherelives=1 ;
  And !adult(client.dob, date_to) ;		
Into Cursor ;
		AllEnrFam  

If Used('PifAgeGn1') 
   Use in PifAgeGn1
EndIf

If Used('PifAgeGen') 
   Use in PifAgeGen
EndIf

Select ;
		'X' as Grouper, ;
		client_id, ;
		gender, ;
		dob, ;
		000 as age ;
From ;
		AllEnrFam ;
Into Cursor ;
		PifAgeGn1
		
oApp.ReOpenCur('PifAgeGn1','PifAgeGen')
Replace All Age with IIF(!EMPTY(dob),GetAge(date_to, dob),999)		
								
* now, count them by gender and age group
Select ;
		Grouper, ;
		Sum(IIF(age >=62 and age <> 999 and gender='10', 1, 0)) As piff_5f, ;		
		Sum(IIF(age >=62 and age <> 999 and gender='11', 1, 0)) As pifm_5f, ;		
		Sum(IIF(age >=62 and age <> 999 and gender<>'10' and gender<>'11', 1, 0)) As pifo_5f, ;		
		Sum(IIF(age >=51 and age <  62  and gender='10', 1, 0)) As piff_5g, ;		
		Sum(IIF(age >=51 and age <  62  and gender='11', 1, 0)) As pifm_5g, ;		
		Sum(IIF(age >=51 and age <  62  and gender<>'10' and gender<>'11', 1, 0)) As pifo_5g, ;		
		Sum(IIF(age >=31 and age <  51  and gender='10', 1, 0)) As piff_5h, ;		
		Sum(IIF(age >=31 and age <  51  and gender='11', 1, 0)) As pifm_5h, ;		
		Sum(IIF(age >=31 and age <  51  and gender<>'10' and gender<>'11', 1, 0)) As pifo_5h  ;		
From ;
		PifAgeGen ;
Group by ;
		Grouper ;
Into Array ;
		aPifGen5a		

If _tally>0
	m.piff_5f=aPifGen5a(2)
	m.pifm_5f=aPifGen5a(3)
	m.pifo_5f=aPifGen5a(4)
	m.piff_5g=aPifGen5a(5)
	m.pifm_5g=aPifGen5a(6)
	m.pifo_5g=aPifGen5a(7)
	m.piff_5h=aPifGen5a(8)
	m.pifm_5h=aPifGen5a(9)
	m.pifo_5h=aPifGen5a(10)
Endif	
Release aPifGen5a

Select ;
		Grouper, ;
		Sum(IIF(age >=18 and age <  31  and gender='10', 1, 0)) As piff_5i, ;		
		Sum(IIF(age >=18 and age <  31  and gender='11', 1, 0)) As pifm_5i, ;		
		Sum(IIF(age >=18 and age <  31  and gender<>'10' and gender<>'11', 1, 0)) As pifo_5i, ;		
		Sum(IIF(age >=13 and age <  18  and gender='10', 1, 0)) As piff_5j, ;		
		Sum(IIF(age >=13 and age <  18  and gender='11', 1, 0)) As pifm_5j, ;		
		Sum(IIF(age >=13 and age <  18  and gender<>'10' and gender<>'11', 1, 0)) As pifo_5j, ;		
		Sum(IIF(age >=6  and age <  13  and gender='10', 1, 0)) As piff_5k, ;		
		Sum(IIF(age >=6  and age <  13  and gender='11', 1, 0)) As pifm_5k, ;		
		Sum(IIF(age >=6  and age <  13  and gender<>'10' and gender<>'11', 1, 0)) As pifo_5k  ;		
From ;
		PifAgeGen ;
Group by ;
		Grouper ;
Into Array ;
		aPifGen5b		

If _tally>0
	m.piff_5i=aPifGen5b(2)
	m.pifm_5i=aPifGen5b(3)
	m.pifo_5i=aPifGen5b(4)
	m.piff_5j=aPifGen5b(5)
	m.pifm_5j=aPifGen5b(6)
	m.pifo_5j=aPifGen5b(7)
	m.piff_5k=aPifGen5b(8)
	m.pifm_5k=aPifGen5b(9)
	m.pifo_5k=aPifGen5b(10)
Endif
Release aPifGen5b

Select ;
		Grouper, ;
		Sum(IIF(age >=1  and age <  6   and gender='10', 1, 0)) As piff_5l, ;		
		Sum(IIF(age >=1  and age <  6   and gender='11', 1, 0)) As pifm_5l, ;		
		Sum(IIF(age >=1  and age <  6   and gender<>'10' and gender<>'11', 1, 0)) As pifo_5l, ;		
		Sum(IIF(age < 1  and gender='10', 1, 0)) As piff_5m, ;		
		Sum(IIF(age < 1  and gender='11', 1, 0)) As pifm_5m, ;		
		Sum(IIF(age < 1  and gender<>'10' and gender<>'11', 1, 0)) As pifo_5m, ;		
		Sum(IIF(age =999 and gender='10', 1, 0)) As piff_5ng, ;		
		Sum(IIF(age =999 and gender='11', 1, 0)) As pifm_5ng, ;		
		Sum(IIF(age =999 and gender<>'10' and gender<>'11', 1, 0)) As pifo_5ng ;				
From ;
		PifAgeGen ;
Group by ;
		Grouper ;
Into Array ;
		aPifGen5c		

If _tally>0
	m.piff_5l=aPifGen5c(2)
	m.pifm_5l=aPifGen5c(3)
	m.pifo_5l=aPifGen5c(4)
	m.piff_5m=aPifGen5c(5)
	m.pifm_5m=aPifGen5c(6)
	m.pifo_5m=aPifGen5c(7)
	m.piff_5ng=aPifGen5c(8)
	m.pifm_5ng=aPifGen5c(9)
	m.pifo_5ng=aPifGen5c(10)
Endif	
Release aPifGen5c

m.detailline=''
m.headerline='5. Age and Gender.                         Age                 Male    Female    Other/'
Insert Into hud_tmp From Memvar
m.headerline='                                                                                 Not Given'
Insert Into hud_tmp From Memvar
m.headerline='Single Persons (from 2b, column 1)' 
m.detailline=''
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='                                                 a. 62 and over       '+ STR(m.spm_5a,6,0) + SPACE(4) +  STR(m.spf_5a,6,0) + SPACE(4) +  STR(m.spo_5a,6,0)  
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='                                                 b. 51-61             '+ STR(m.spm_5b,6,0) + SPACE(4) +  STR(m.spf_5b,6,0) + SPACE(4) +  STR(m.spo_5b,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 c. 31-50             '+ STR(m.spm_5c,6,0) + SPACE(4) +  STR(m.spf_5c,6,0) + SPACE(4) +  STR(m.spo_5c,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 d. 18-30             '+ STR(m.spm_5d,6,0) + SPACE(4) +  STR(m.spf_5d,6,0) + SPACE(4) +  STR(m.spo_5d,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 e. 17 and under      '+ STR(m.spm_5e,6,0) + SPACE(4) +  STR(m.spf_5e,6,0) + SPACE(4) +  STR(m.spo_5e,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 Not given            '+ STR(m.spm_5ng,6,0) + SPACE(4) +  STR(m.spf_5ng,6,0) + SPACE(4) +  STR(m.spo_5ng,6,0)  
Insert Into hud_tmp From Memvar
m.headerline='Persons in Families (from 2b, column 2 & 3)'
m.detailline=''
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='                                                 f. 62 and over       '+ STR(m.pifm_5f,6,0) + SPACE(4) +  STR(m.piff_5f,6,0) + SPACE(4) +  STR(m.pifo_5f,6,0)  
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='                                                 g. 51-61             '+ STR(m.pifm_5g,6,0) + SPACE(4) +  STR(m.piff_5g,6,0) + SPACE(4) +  STR(m.pifo_5g,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 h. 31-50             '+ STR(m.pifm_5h,6,0) + SPACE(4) +  STR(m.piff_5h,6,0) + SPACE(4) +  STR(m.pifo_5h,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 i. 18-30             '+ STR(m.pifm_5i,6,0) + SPACE(4) +  STR(m.piff_5i,6,0) + SPACE(4) +  STR(m.pifo_5i,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 j. 13-17             '+ STR(m.pifm_5j,6,0) + SPACE(4) +  STR(m.piff_5j,6,0) + SPACE(4) +  STR(m.pifo_5j,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 k. 6-12              '+ STR(m.pifm_5k,6,0) + SPACE(4) +  STR(m.piff_5k,6,0) + SPACE(4) +  STR(m.pifo_5k,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 l. 1-5               '+ STR(m.pifm_5l,6,0) + SPACE(4) +  STR(m.piff_5l,6,0) + SPACE(4) +  STR(m.pifo_5l,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 m. Under 1           '+ STR(m.pifm_5m,6,0) + SPACE(4) +  STR(m.piff_5m,6,0) + SPACE(4) +  STR(m.pifo_5m,6,0)  
Insert Into hud_tmp From Memvar
m.detailline='                                                 Not given            '+ STR(m.pifm_5ng,6,0) + SPACE(4) +  STR(m.piff_5ng,6,0) + SPACE(4) +  STR(m.pifo_5ng,6,0)  
Insert Into hud_tmp From Memvar

m.detailline=''
Insert Into hud_tmp From Memvar

m.detailline=''
Insert Into hud_tmp From Memvar

***********************************************************************************

m.question=6

* determine number of veterans using the special populations table (veteran code='09')
Select ;
	Count(tc_id) As vet_6a ;
From ;
	EnrDuring ;
Where ;
	tc_id IN (Select tc_id From ai_spclp Where Code='09') ;
Into Array aVet_6a
m.Vet_6a = IIF(_tally=0,0,aVet_6a(1))
Release aVet_6a

* determine number of chronically homeless participants using new field hudchronic in client table
Select ;
	Count(tc_id) As chronic_6b ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
Into Array aChronic6b		
m.Chronic_6b = IIF(_tally=0,0,aChronic6b(1))
Release aChronic6b

m.detailline=''
m.headerline='6a. Veterans Status.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='How many participants were veterans?' + SPACE(34) + STR(m.vet_6a,6,0)
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar
m.headerline='6b. Chronically homeless person.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='How many participants were chronically homeless individuals?' + SPACE(10) + STR(m.chronic_6b,6,0)
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.question=7

* determine the number of hispanic, non-hispanic
Select ;
	Count(tc_id) As hisp_7a ;
From ;
	EnrDuring ;
Where ;
	hispanic = 2 ;
Into Array aHisp_7a		
m.hisp_7a=IIF(_tally=0,0,aHisp_7a(1))
Release aHisp_7a		

Select ;
	Count(tc_id) As hisp_7b ;
From ;
	EnrDuring ;
Where ;
	hispanic <> 2 ;
Into Array aNonHisp7b		
m.nonhisp_7b=IIF(_tally=0,0,aNonHisp7b(1))
Release aNonHisp7b

m.detailline=''
m.headerline='7. Ethnicity.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='7a. Hispanic or Latino' + SPACE(48) + STR(m.hisp_7a,6,0)
Insert Into hud_tmp From Memvar
m.detailline='7b. Non-Hispanic and Non-Latino' + SPACE(39) + STR(m.nonhisp_7b,6,0)
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar
************************************************************************************

m.question=8

Store 0 to m.race_8a,m.race_8b,m.race_8c,m.race_8d,m.race_8e,m.race_8f,m.race_8g,m.race_8h,m.race_8i

Select ;
	'X' as Grouper , ;
	Sum(IIF(indialaska=1 And (white + blafrican + asian + hawaisland + someother = 0), 1, 0)) As race_8a, ;
	Sum(IIF(asian=1 And (white + blafrican + hawaisland + indialaska + someother = 0), 1, 0)) As race_8b, ;
	Sum(IIF(blafrican=1 And (white + asian + hawaisland + indialaska + someother = 0), 1, 0)) As race_8c, ;
	Sum(IIF(hawaisland=1 And (white + blafrican + asian + indialaska + someother = 0), 1, 0)) As race_8d, ;
	Sum(IIF(white=1 And (blafrican + asian + hawaisland + indialaska + someother = 0), 1, 0)) As race_8e, ;
	Sum(IIF(white=1 And indialaska=1 And (blafrican + asian + hawaisland + someother = 0), 1, 0)) As race_8f, ;
	Sum(IIF(white=1 And blafrican=1 And (asian + hawaisland + indialaska + someother = 0), 1, 0)) As race_8g, ;
	Sum(IIF(white=1 And hawaisland=1 And (blafrican + asian + indialaska + someother = 0), 1, 0)) As race_8h, ;
	Sum(IIF(blafrican=1 And indialaska=1 And (white + asian + hawaisland + someother = 0), 1, 0)) As race_8i ;
From ;
	EnrDuring ;	
Group by ;
	Grouper ;
Into Array aRace_8

If _tally>0
	m.race_8a=aRace_8(2)	
	m.race_8b=aRace_8(3)	
	m.race_8c=aRace_8(4)	
	m.race_8d=aRace_8(5)	
	m.race_8e=aRace_8(6)	
	m.race_8f=aRace_8(7)	
	m.race_8g=aRace_8(8)	
	m.race_8h=aRace_8(9)	
	m.race_8i=aRace_8(10)	
Endif	
Release aRace_8

* american indian/alaskan native & white
If Used('Cursor8f') 
   Use in Cursor8f
EndIf

Select * ;
From ;
	EnrDuring ;
Where ;
	white=1 And indialaska=1 And (blafrican + asian + hawaisland + someother = 0) ;
Into Cursor Cursor8f

* black/african american & white
If Used('Cursor8g') 
   Use in Cursor8g
EndIf

Select * ;
From ;
	EnrDuring ;
Where ;
	white=1 And blafrican=1 And (asian + hawaisland + indialaska + someother = 0) ;
Into Cursor Cursor8g

* native hawaiian/other pacific islander & white
If Used('Cursor8h') 
   Use in Cursor8h
EndIf

Select * ;
From ;
	EnrDuring ;
Where ;
	white=1 And hawaisland=1 And (blafrican + asian + indialaska + someother = 0) ;
Into Cursor Cursor8h

* american indian/alaskan native & black
If Used('Cursor8i') 
   Use in Cursor8i
EndIf

Select * ;
From ;
	EnrDuring ;
Where ;
	blafrican=1 And indialaska=1 And (white + asian + hawaisland + someother = 0) ;
Into Cursor Cursor8i

* combine the multiracial cursors so far
If Used('CurMulti') 
   Use in CurMulti
EndIf

Select * From Cursor8f ;
Union ;
Select * From Cursor8g ;
Union ;
Select * From Cursor8h ;
Union ;
Select * From Cursor8i ;
Into Cursor ;
	CurMulti
	
* close out the multiracial cursors to free up work areas
Use in Cursor8f
Use in Cursor8g
Use in Cursor8h
Use in Cursor8i

* other multiracial
Select ;
	Count(tc_id) As race_8j ;
From ;
	EnrDuring ;
Where ;
	(white + blafrican + asian + hawaisland + indialaska + someother) > 1 ;
And ;
	tc_id NOT IN (Select tc_id From CurMulti) ;	
Into Array aRace_8j
m.race_8j=IIF(_tally=0,0,aRace_8j(1))
Release aRace_8j
Use in CurMulti

m.detailline=''
m.headerline='8. Race.'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. American Indian/Alaskan Native' + SPACE(37) + STR(m.race_8a,6,0)
Insert Into hud_tmp From Memvar
m.detailline='b. Asian                         ' + SPACE(37) + STR(m.race_8b,6,0)
Insert Into hud_tmp From Memvar
m.detailline='c. Black/African American        ' + SPACE(37) + STR(m.race_8c,6,0)
Insert Into hud_tmp From Memvar
m.detailline='d. Native Hawaiian/Other Pacific Islander' + SPACE(29) + STR(m.race_8d,6,0)
Insert Into hud_tmp From Memvar
m.detailline='e. White                         ' + SPACE(37) + STR(m.race_8e,6,0)
Insert Into hud_tmp From Memvar
m.detailline='f. American Indian/Alaskan Native & White' + SPACE(29) + STR(m.race_8f,6,0)
Insert Into hud_tmp From Memvar
m.detailline='g. Black/African American & White' + SPACE(37) + STR(m.race_8g,6,0)
Insert Into hud_tmp From Memvar
m.detailline='h. Native Hawaiian/Other Pacific Islander & White' + SPACE(21) + STR(m.race_8h,6,0)
Insert Into hud_tmp From Memvar
m.detailline='i. American Indian/Alaskan Native & Black' + SPACE(29) + STR(m.race_8i,6,0)
Insert Into hud_tmp From Memvar
m.detailline='j. Other Multi-Racial            ' + SPACE(37) + STR(m.race_8j,6,0)
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar
***************************************************************************************

m.question=9
store 0 to m.spec_9aa, m.spec_9ab, m.spec_9ac, m.spec_9ad, m.spec_9ae, m.spec_9af, m.spec_9ag, m.spec_9ah 
store 0 to m.spec_9ca, m.spec_9cb, m.spec_9cc, m.spec_9cd, m.spec_9ce, m.spec_9cf, m.spec_9cg, m.spec_9ch, m.spec_9b 

* metal illness (speclpop code='23')
Select ;
	Count(tc_id) As spec_9aa ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '23') ;
Into Array aSpec_9aa
m.spec_9aa=IIF(_tally=0,0,aSpec_9aa(1))
Release aSpec_9aa

Select ;
	Count(tc_id) As spec_9ac ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '23') ;
Into Array aSpec_9ac
m.spec_9ac=IIF(_tally=0,0,aSpec_9ac(1))
Release aSpec_9ac

* alcohol abuse ('29')
Select ;
	Count(tc_id) As spec_9ab ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '29') ;
Into Array aSpec_9ab
m.spec_9ab=IIF(_tally=0,0,aSpec_9ab(1))
Release aSpec_9ab

Select ;
	Count(tc_id) As spec_9cb ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '29') ;
Into Array aSpec_9cb
m.spec_9cb=IIF(_tally=0,0,aSpec_9cb(1))
Release aSpec_9cb

* drug abuse ('30')
Select ;
	Count(tc_id) As spec_9ac ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '30') ;
Into Array aSpec_9ac
m.spec_9ac=IIF(_tally=0,0,aSpec_9ac(1))
Release aSpec_9ac

Select ;
	Count(tc_id) As spec_9cc ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '30') ;
Into Array aSpec_9cc
m.spec_9cc=IIF(_tally=0,0,aSpec_9cc(1))
Release aSpec_9cc

* HIV/AIDS and related diseases (with a CDC-defined diagnosis of AIDS or tests indicating AIDS)
Select ;
	Count(tc_id) As spec_9ad ;
From ;
	EnrDuring ;
Where ;
	CDC_AIDS(tc_id) ;
Into Array aSpec_9ad
m.spec_9ad=IIF(_tally=0,0,aSpec_9ad(1))
Release aSpec_9ad

Select ;
	Count(tc_id) As spec_9cd ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	CDC_AIDS(tc_id) ;
Into Array aSpec_9cd
m.spec_9cd=IIF(_tally=0,0,aSpec_9cd(1))
Release aSpec_9cd

* developmental disability ('25')
Select ;
	Count(tc_id) As spec_9ae ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '25') ;
Into Array aSpec_9ae
m.spec_9ae=IIF(_tally=0,0,aSpec_9ae(1))
Release aSpec_9ae

Select ;
	Count(tc_id) As spec_9ce ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '25') ;
Into Array aSpec_9ce
m.spec_9ce=IIF(_tally=0,0,aSpec_9ce(1))
Release aSpec_9ce

* physical disability ('26')
Select ;
	Count(tc_id) As spec_9af ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '26') ;
Into Array aSpec_9af
m.spec_9af=IIF(_tally=0,0,aSpec_9af(1))
Release aSpec_9af

Select ;
	Count(tc_id) As spec_9cf ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '26') ;
Into Array aSpec_9cf
m.spec_9cf=IIF(_tally=0,0,aSpec_9cf(1))
Release aSpec_9cf

* domestic violence ('31')
Select ;
	Count(tc_id) As spec_9ag ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '31') ;
Into Array aSpec_9ag
m.spec_9ag=IIF(_tally=0,0,aSpec_9ag(1))
Release aSpec_9ag

Select ;
	Count(tc_id) As spec_9cg ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '31') ;
Into Array aSpec_9cg
m.spec_9cg=IIF(_tally=0,0,aSpec_9cg(1))
Release aSpec_9cg

* other ('08')
Select ;
	Count(tc_id) As spec_9ah ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '08') ;
Into Array aSpec_9ah
m.spec_9ah=IIF(_tally=0,0,aSpec_9ah(1))
Release aSpec_9ah

Select ;
	Count(tc_id) As spec_9ch ;
From ;
	EnrDuring ;
Where ;
	hudchronic=1 ;
And ;	
	tc_id In (Select tc_id From ai_spclp Where code = '08') ;
Into Array aSpec_9ch
m.spec_9ch=IIF(_tally=0,0,aSpec_9ch(1))
Release aSpec_9ch

* disability ('25','26')
Select ;
	Count(tc_id) As spec_9b ;
From ;
	EnrDuring ;
Where ;
	tc_id In (Select tc_id From ai_spclp Where code = '25' or code = '26') ;
Into Array aSpec_9b
m.spec_9b=IIF(_tally=0,0,aSpec_9b(1))
Release aSpec_9b

m.detailline=''
m.headerline='9a. Special Needs.                                               All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Mental Illness               ' + SPACE(40) + STR(m.spec_9aa,6,0) + SPACE(4) + STR(m.spec_9ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Alcohol Abuse                ' + SPACE(40) + STR(m.spec_9ab,6,0) + SPACE(4) + STR(m.spec_9cb,6,0)
Insert Into hud_tmp From Memvar
m.detailline='c. Drug Abuse                   ' + SPACE(40) + STR(m.spec_9ac,6,0) + SPACE(4) + STR(m.spec_9cc,6,0)
Insert Into hud_tmp From Memvar
m.detailline='d. HIV/AIDS and related diseases' + SPACE(40) + STR(m.spec_9ad,6,0) + SPACE(4) + STR(m.spec_9cd,6,0)
Insert Into hud_tmp From Memvar
m.detailline='e. Developmental disability     ' + SPACE(40) + STR(m.spec_9ae,6,0) + SPACE(4) + STR(m.spec_9ce,6,0)
Insert Into hud_tmp From Memvar
m.detailline='f. Physical disability          ' + SPACE(40) + STR(m.spec_9af,6,0) + SPACE(4) + STR(m.spec_9cf,6,0)
Insert Into hud_tmp From Memvar
m.detailline='g. Domestic violence            ' + SPACE(40) + STR(m.spec_9ag,6,0) + SPACE(4) + STR(m.spec_9cg,6,0)
Insert Into hud_tmp From Memvar
m.detailline='h. Other                        ' + SPACE(40) + STR(m.spec_9ah,6,0) + SPACE(4) + STR(m.spec_9ch,6,0)
Insert Into hud_tmp From Memvar

m.detailline=''
Insert Into hud_tmp From Memvar
m.headerline='9b. Disabled.'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline=''
Insert Into hud_tmp From Memvar
m.detailline='How many of the participants are disabled?' + SPACE(30) + STR(m.spec_9b,6,0)
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar
*******************************************************************************************

m.question=10
store 0 to m.pls_10aa, m.pls_10ab, m.pls_10ac, m.pls_10ad, m.pls_10ae, m.pls_10af, m.pls_10ag, m.pls_10ah, m.pls_10ai, m.pls_10aj, m.pls_10ak 
store 0 to m.pls_10ca, m.pls_10cb

					***VT 11/11/2011 AIRS-183 
					** Create cursor
							
					 If Used('all_hous')
						   Use In all_hous
					 EndIf
						
		           Select tc_id, ;
		           		   housing;
				    from ai_housing ;
				    into cursor all_hous ;
				    where 1=2 ;
				    readwrite
 					
 					 **Fiind most recent verified date
					 Select Max(lvf.verified_datetime) as verified_datetime, ;
									lvf.tc_id ;
					 from lv_verification_filtered lvf ;
								inner join EnrDuring on;
									    	   EnrDuring.tc_id = lvf.tc_id ;
							          and lvf.vn_category="K" ;
							          and Between(lvf.verified_datetime, date_from, date_to) ;
							   inner join ai_housing ah on ;
							     		    EnrDuring.tc_id = ah.tc_id ;
					 Group by lvf.tc_id ;
					 into cursor tmp_dt
						
					If _Tally > 0
										Insert into all_hous ;
									     					( tc_id, ;
															 housing ) ;	 	
						     	        Select distinct ;
								       		  			ai_housing.tc_id, ;
															ai_housing.housing ;
									    from lv_verification_filtered lvf ;
										      inner join tmp_dt td on ;
										      	 lvf.tc_id = td.tc_id ;
										      and lvf.verified_datetime = td.verified_datetime ;
										      inner join ai_housing on ;
										          ai_housing.housing_id =lvf.table_id 
					 Endif

					 Use in tmp_dt
					 
   			   *If date verified not entered  -> most recent record from ai_housing.effective_dt
   			     Select Max(af.effective_dt) as effective_dt, ;
					        af.tc_id ;
						 FROM EnrDuring ;
						 		inner join ai_housing af on ;
					        		EnrDuring.tc_id = af.tc_id  ;
					 		  and Between(af.effective_dt, Date_from, Date_to) ;
					 	where EnrDuring.tc_id not in (Select tc_id from all_hous)	  ;
						Group by af.tc_id ;
					   into cursor tmp_dt
		   
				      If _Tally > 0
						     Insert into all_hous ;
						     					( tc_id, ;
												 housing) ;	 
					     	        Select distinct ;
					     	        			af.tc_id, ;
										   	af.housing ;          
								from ai_housing af ;
								      inner join tmp_dt td on ;
								      	 af.tc_id = td.tc_id ;
								      and af.effective_dt = td.effective_dt
			         EndIf

			        Use in tmp_dt
			        **VT End

***VT 11/11/2011 AIRS-183  							
*!*	Select ;
*!*		'X' as Grouper , ;
*!*		Sum(IIF(housing='01', 1, 0)) As pls_10aa, ;
*!*		Sum(IIF(housing='01' And hudchronic=1, 1, 0)) As pls_10ca, ;
*!*		Sum(IIF(housing='02', 1, 0)) As pls_10ab, ;
*!*		Sum(IIF(housing='02' And hudchronic=1, 1, 0)) As pls_10cb, ;
*!*		Sum(IIF(housing='03', 1, 0)) As pls_10ac, ;
*!*		Sum(IIF(housing='04', 1, 0)) As pls_10ad, ;
*!*		Sum(IIF(housing='06', 1, 0)) As pls_10ae, ;
*!*		Sum(IIF(housing='08', 1, 0)) As pls_10af, ;
*!*		Sum(IIF(housing='09', 1, 0)) As pls_10ag, ;
*!*		Sum(IIF(housing='13', 1, 0)) As pls_10ah, ;
*!*		Sum(IIF(housing='12', 1, 0)) As pls_10ai, ;
*!*		Sum(IIF(housing='10', 1, 0)) As pls_10aj, ;
*!*		Sum(IIF(housing $ '05 07 11', 1, 0)) As pls_10ak  ;
*!*	From ;
*!*		EnrDuring ;
*!*	Group by ;
*!*		Grouper ;
*!*	Into Array apls_10

Select ;
	'X' as Grouper , ;
	Sum(IIF(ah.housing='01', 1, 0)) As pls_10aa, ;
	Sum(IIF(ah.housing='01' And hudchronic=1, 1, 0)) As pls_10ca, ;
	Sum(IIF(ah.housing='02', 1, 0)) As pls_10ab, ;
	Sum(IIF(ah.housing='02' And hudchronic=1, 1, 0)) As pls_10cb, ;
	Sum(IIF(ah.housing='03', 1, 0)) As pls_10ac, ;
	Sum(IIF(ah.housing='04', 1, 0)) As pls_10ad, ;
	Sum(IIF(ah.housing='06', 1, 0)) As pls_10ae, ;
	Sum(IIF(ah.housing='08', 1, 0)) As pls_10af, ;
	Sum(IIF(ah.housing='09', 1, 0)) As pls_10ag, ;
	Sum(IIF(ah.housing='13', 1, 0)) As pls_10ah, ;
	Sum(IIF(ah.housing='12', 1, 0)) As pls_10ai, ;
	Sum(IIF(ah.housing='10', 1, 0)) As pls_10aj, ;
	Sum(IIF(ah.housing $ '05 07 11', 1, 0)) As pls_10ak  ;
From ;
	EnrDuring ;
	inner join all_hous ah on ;
	  EnrDuring.tc_id=ah.tc_id ;
Group by ;
	Grouper ;
Into Array apls_10

If _tally>0
	m.pls_10aa=apls_10(2)
	m.pls_10ca=apls_10(3)
	m.pls_10ab=apls_10(4)
	m.pls_10cb=apls_10(5)
	m.pls_10ac=apls_10(6)
	m.pls_10ad=apls_10(7)
	m.pls_10ae=apls_10(8)
	m.pls_10af=apls_10(9)
	m.pls_10ag=apls_10(10)
	m.pls_10ah=apls_10(11)
	m.pls_10ai=apls_10(12)
	m.pls_10aj=apls_10(13)
	m.pls_10ak=apls_10(14)
Endif
Release aPls_10

m.detailline=''
m.headerline='10. Prior Living Situation                                       All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Non-housing (street, park, bus station, etc.)' + SPACE(24) + STR(m.pls_10aa,6,0) + SPACE(4) + STR(m.pls_10ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Emergency shelter                            ' + SPACE(24) + STR(m.pls_10ab,6,0) + SPACE(4) + STR(m.pls_10cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. Transitional housing for homeless persons    ' + SPACE(24) + STR(m.pls_10ac,6,0)
Insert Into hud_tmp From Memvar
m.detailline='d. Psychiatric facility                         ' + SPACE(24) + STR(m.pls_10ad,6,0)
Insert Into hud_tmp From Memvar
m.detailline='e. Substance abuse treatment facility           ' + SPACE(24) + STR(m.pls_10ae,6,0)
Insert Into hud_tmp From Memvar
m.detailline='f. Hospital                                     ' + SPACE(24) + STR(m.pls_10af,6,0)
Insert Into hud_tmp From Memvar
m.detailline='g. Jail/prison                                  ' + SPACE(24) + STR(m.pls_10ag,6,0)
Insert Into hud_tmp From Memvar
m.detailline='h. Domestic violence situation                  ' + SPACE(24) + STR(m.pls_10ah,6,0)
Insert Into hud_tmp From Memvar
m.detailline='i. Living with relatives/friends                ' + SPACE(24) + STR(m.pls_10ai,6,0)
Insert Into hud_tmp From Memvar
m.detailline='j. Rental housing                               ' + SPACE(24) + STR(m.pls_10aj,6,0)
Insert Into hud_tmp From Memvar
m.detailline='k. Other                                        ' + SPACE(24) + STR(m.pls_10ak,6,0)
Insert Into hud_tmp From Memvar
*************************************************************************************************

m.question=11
store 0 to m.incen_11aa, m.incen_11ab, m.incen_11ac, m.incen_11ad, m.incen_11ae, m.incen_11af, m.incen_11ag, m.incen_11ah 
store 0 to m.incen_11ca, m.incen_11cb, m.incen_11cc, m.incen_11cd, m.incen_11ce, m.incen_11cf, m.incen_11cg, m.incen_11ch 
store 0 to m.incex_11aa, m.incex_11ab, m.incex_11ac, m.incex_11ad, m.incex_11ae, m.incex_11af, m.incex_11ag, m.incex_11ah 
store 0 to m.incex_11ca, m.incex_11cb, m.incex_11cc, m.incex_11cd, m.incex_11ce, m.incex_11cf, m.incex_11cg, m.incex_11ch 
store 0 to m.srcen_11aa, m.srcen_11ab, m.srcen_11ac, m.srcen_11ad, m.srcen_11ae, m.srcen_11af, m.srcen_11ag, m.srcen_11ah, m.srcen_11ai, m.srcen_11aj, m.srcen_11ak, m.srcen_11al, m.srcen_11am, m.srcen_11an
store 0 to m.srcen_11ca, m.srcen_11cb, m.srcen_11cc, m.srcen_11cd, m.srcen_11ce, m.srcen_11cf, m.srcen_11cg, m.srcen_11ch, m.srcen_11ci, m.srcen_11cj, m.srcen_11ck, m.srcen_11cl, m.srcen_11cm, m.srcen_11cn
store 0 to m.srcex_11aa, m.srcex_11ab, m.srcex_11ac, m.srcex_11ad, m.srcex_11ae, m.srcex_11af, m.srcex_11ag, m.srcex_11ah, m.srcex_11ai, m.srcex_11aj, m.srcex_11ak, m.srcex_11al, m.srcex_11am, m.srcex_11an
store 0 to m.srcex_11ca, m.srcex_11cb, m.srcex_11cc, m.srcex_11cd, m.srcex_11ce, m.srcex_11cf, m.srcex_11cg, m.srcex_11ch, m.srcex_11ci, m.srcex_11cj, m.srcex_11ck, m.srcex_11cl, m.srcex_11cm, m.srcex_11cn

* create cursor of all participants leaving program during operating year 

* now, get the monthly income at entry
If Used('IncSrcSt') 
   Use in IncSrcSt
EndIf

Select ;
		'X' AS Grouper, ;
		LeftDuring.*, ;
		ai_incom.amount, ;
		ai_incom.code As source ;
From ;
		LeftDuring, ai_incom ;
Where ;
		LeftDuring.tc_id = ai_incom.tc_id ;
And ;	
		ai_incom.tc_id + DTOS(ai_incom.act_dt) IN ;
			(Select tc_id + Dtos(Max(act_dt)) ;
				From ai_incom ;
				Where !empty(act_dt) and act_dt <= date_from ;
				Group by tc_id) ;
Into Cursor ;
	IncSrcSt
	
* count by monthly amount (divide yearly by 12)

* no income: no entry in the ai_incom table for client
Select ;
	Count(tc_id) as Incen_11aa ;
From ;
	LeftDuring ;
Where ;
	tc_id NOT IN ;
		(Select tc_id From IncSrcSt) ;
Into Array ;
	aIncen11aa		  
m.Incen_11aa=IIF(_tally=0,0,aIncen11aa(1))
Release aIncen11aa					

Select ;
	Count(tc_id) as Incen_11ca ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id NOT IN ;
		(Select tc_id From IncSrcSt) ;
Into Array ;
	aIncen11ca		  
m.Incen_11ca=IIF(_tally=0,0,aIncen11ca(1))
Release aIncen11ca					

Select ;
	Grouper, ;
	Sum(IIF(amount/12 > 0 And amount/12 <= 150,1,0)) as Incen_11ab, ;
	Sum(IIF(amount/12 > 0 And amount/12 <= 150 and hudchronic=1,1,0)) as Incen_11cb, ;
	Sum(IIF(amount/12 > 150 And amount/12 <= 250,1,0)) as Incen_11ac, ;
	Sum(IIF(amount/12 > 150 And amount/12 <= 250 and hudchronic=1,1,0)) as Incen_11cc, ;
	Sum(IIF(amount/12 > 250 And amount/12 <= 500,1,0)) as Incen_11ad, ;
	Sum(IIF(amount/12 > 250 And amount/12 <= 500 and hudchronic=1,1,0)) as Incen_11cd, ;
	Sum(IIF(amount/12 > 500 And amount/12 <= 1000,1,0)) as Incen_11ae, ;
	Sum(IIF(amount/12 > 500 And amount/12 <= 1000 and hudchronic=1,1,0)) as Incen_11ce ;
From ;
	IncSrcSt ;
Group by ;
	Grouper ;
Into Array ;
	aIncen11a

If _tally>0
	m.Incen_11ab=aIncen11a(2)
	m.Incen_11cb=aIncen11a(3)
	m.Incen_11ac=aIncen11a(4)
	m.Incen_11cc=aIncen11a(5)
	m.Incen_11ad=aIncen11a(6)
	m.Incen_11cd=aIncen11a(7)
	m.Incen_11ae=aIncen11a(8)
	m.Incen_11ce=aIncen11a(9)
Endif	
Release aIncen11a					

Select ;
	Grouper, ;
	Sum(IIF(amount/12 > 1000 And amount/12 <= 1500,1,0)) as Incen_11af, ;
	Sum(IIF(amount/12 > 1000 And amount/12 <= 1500 and hudchronic=1,1,0)) as Incen_11cf, ;
	Sum(IIF(amount/12 > 1500 And amount/12,1,0)) as Incen_11ag, ;
	Sum(IIF(amount/12 > 1500 And amount/12 and hudchronic=1,1,0)) as Incen_11cg, ;
	Sum(IIF(amount/12 > 2000,1,0)) as Incen_11ah, ;
	Sum(IIF(amount/12 > 2000 and hudchronic=1,1,0)) as Incen_11ch ;
From ;
	IncSrcSt ;
Group by ;
	Grouper ;
Into Array ;
	aIncen11b

If _tally>0
	m.Incen_11af=aIncen11b(2)
	m.Incen_11cf=aIncen11b(3)
	m.Incen_11ag=aIncen11b(4)
	m.Incen_11cg=aIncen11b(5)
	m.Incen_11ah=aIncen11b(6)
	m.Incen_11ch=aIncen11b(7)
Endif	
Release aIncen11b					

m.detailline=''
m.headerline='11. Amount and Source of Monthly Income at Entry and Exit'
Insert Into hud_tmp From Memvar
m.headerline='     (participants who LEFT during operating year)'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.headerline='A. Monthly Income at Entry                                       All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. No Income                                    ' + SPACE(24) + STR(m.incen_11aa,6,0) + SPACE(4) + STR(m.incen_11ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. $1-$150                                      ' + SPACE(24) + STR(m.incen_11ab,6,0) + SPACE(4) + STR(m.incen_11cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. $151-$250                                    ' + SPACE(24) + STR(m.incen_11ac,6,0) + SPACE(4) + STR(m.incen_11cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. $251-$500                                    ' + SPACE(24) + STR(m.incen_11ad,6,0) + SPACE(4) + STR(m.incen_11cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. $501-$1000                                   ' + SPACE(24) + STR(m.incen_11ae,6,0) + SPACE(4) + STR(m.incen_11ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. $1001-$1500                                  ' + SPACE(24) + STR(m.incen_11af,6,0) + SPACE(4) + STR(m.incen_11cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. $1501-$2000                                  ' + SPACE(24) + STR(m.incen_11ag,6,0) + SPACE(4) + STR(m.incen_11cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. $2001+                                       ' + SPACE(24) + STR(m.incen_11ah,6,0) + SPACE(4) + STR(m.incen_11ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

* now, get the monthly income at exit
If Used('IncSrcEnd') 
   Use in IncSrcEnd
EndIf

Select ;
		'X' AS Grouper, ;
		LeftDuring.*, ;
		ai_incom.amount, ;
		ai_incom.code As source ;
From ;
		LeftDuring, ai_incom ;
Where ;
		LeftDuring.tc_id = ai_incom.tc_id ;
And ;	
		ai_incom.tc_id + DTOS(ai_incom.act_dt) IN ;
			(Select tc_id + Dtos(Max(act_dt)) ;
				From ai_incom ;
				Where !empty(act_dt) and act_dt <= date_to ;
				Group by tc_id) ;
Into Cursor ;
	IncSrcEnd
	
* no income: no entry in the ai_incom table for client
Select ;
	Count(tc_id) as Incex_11aa ;
From ;
	LeftDuring ;
Where ;
	tc_id NOT IN ;
		(Select tc_id From IncSrcEnd) ;
Into Array ;
	aIncex11aa		  
m.Incex_11aa=IIF(_tally=0,0,aIncex11aa(1))
Release aIncex11aa					

Select ;
	Count(tc_id) as Incex_11ca ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id NOT IN ;
		(Select tc_id From IncSrcEnd) ;
Into Array ;
	aIncex11ca		  
m.Incex_11ca=IIF(_tally=0,0,aIncex11ca(1))
Release aIncex11ca					

* now, get count clients at each monthly income level upon exit
Select ;
	Grouper, ;
	Sum(IIF(amount/12 > 0 And amount/12 <= 150,1,0)) as Incex_11ab, ;
	Sum(IIF(amount/12 > 0 And amount/12 <= 150 and hudchronic=1,1,0)) as Incex_11cb, ;
	Sum(IIF(amount/12 > 150 And amount/12 <= 250,1,0)) as Incex_11ac, ;
	Sum(IIF(amount/12 > 150 And amount/12 <= 250 and hudchronic=1,1,0)) as Incex_11cc, ;
	Sum(IIF(amount/12 > 250 And amount/12 <= 500,1,0)) as Incex_11ad, ;
	Sum(IIF(amount/12 > 250 And amount/12 <= 500 and hudchronic=1,1,0)) as Incex_11cd, ;
	Sum(IIF(amount/12 > 500 And amount/12 <= 1000,1,0)) as Incex_11ae, ;
	Sum(IIF(amount/12 > 500 And amount/12 <= 1000 and hudchronic=1,1,0)) as Incex_11ce ;
From ;
	IncSrcEnd ;
Group by ;
	Grouper ;
Into Array ;
	aIncex11a

If _tally>0
	m.Incex_11ab=aIncex11a(2)
	m.Incex_11cb=aIncex11a(3)
	m.Incex_11ac=aIncex11a(4)
	m.Incex_11cc=aIncex11a(5)
	m.Incex_11ad=aIncex11a(6)
	m.Incex_11cd=aIncex11a(7)
	m.Incex_11ae=aIncex11a(8)
	m.Incex_11ce=aIncex11a(9)
Endif
Release aIncex11a					

Select ;
	Grouper, ;
	Sum(IIF(amount/12 > 1000 And amount/12 <= 1500,1,0)) as Incex_11af, ;
	Sum(IIF(amount/12 > 1000 And amount/12 <= 1500 and hudchronic=1,1,0)) as Incex_11cf, ;
	Sum(IIF(amount/12 > 1500 And amount/12,1,0)) as Incex_11ag, ;
	Sum(IIF(amount/12 > 1500 And amount/12 and hudchronic=1,1,0)) as Incex_11cg, ;
	Sum(IIF(amount/12 > 2000,1,0)) as Incex_11ah, ;
	Sum(IIF(amount/12 > 2000 and hudchronic=1,1,0)) as Incex_11ch ;
From ;
	IncSrcEnd ;
Group by ;
	Grouper ;
Into Array ;
	aIncex11b

If _tally>0
	m.Incex_11af=aIncex11b(2)
	m.Incex_11cf=aIncex11b(3)
	m.Incex_11ag=aIncex11b(4)
	m.Incex_11cg=aIncex11b(5)
	m.Incex_11ah=aIncex11b(6)
	m.Incex_11ch=aIncex11b(7)
Endif	
Release aIncex11b					

m.headerline='B. Monthly Income at Exit                                        All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. No Income                                    ' + SPACE(24) + STR(m.incex_11aa,6,0) + SPACE(4) + STR(m.incex_11ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. $1-$150                                      ' + SPACE(24) + STR(m.incex_11ab,6,0) + SPACE(4) + STR(m.incex_11cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. $151-$250                                    ' + SPACE(24) + STR(m.incex_11ac,6,0) + SPACE(4) + STR(m.incex_11cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. $251-$500                                    ' + SPACE(24) + STR(m.incex_11ad,6,0) + SPACE(4) + STR(m.incex_11cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. $501-$1000                                   ' + SPACE(24) + STR(m.incex_11ae,6,0) + SPACE(4) + STR(m.incex_11ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. $1001-$1500                                  ' + SPACE(24) + STR(m.incex_11af,6,0) + SPACE(4) + STR(m.incex_11cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. $1501-$2000                                  ' + SPACE(24) + STR(m.incex_11ag,6,0) + SPACE(4) + STR(m.incex_11cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. $2001+                                       ' + SPACE(24) + STR(m.incex_11ah,6,0) + SPACE(4) + STR(m.incex_11ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

* count income sources at entry

Select ;
	Grouper, ;
	Sum(IIF(source = '15 ',1,0)) as srcen_11aa, ;
	Sum(IIF(source = '15 ' and hudchronic=1,1,0)) as srcen_11ca, ;
	Sum(IIF(source = '16 ',1,0)) as srcen_11ab, ;
	Sum(IIF(source = '16 ' and hudchronic=1,1,0)) as srcen_11cb, ;
	Sum(IIF(source = '03 ',1,0)) as srcen_11ac, ;
	Sum(IIF(source = '03 ' and hudchronic=1,1,0)) as srcen_11cc, ;
	Sum(IIF(source = '05 ',1,0)) as srcen_11ad, ;
	Sum(IIF(source = '05 ' and hudchronic=1,1,0)) as srcen_11cd ;
From ;
	IncSrcSt ;
Group by ;
	Grouper ;
Into Array ;
	asrcen11a

If _tally>0
	m.srcen_11aa=asrcen11a(2)
	m.srcen_11ca=asrcen11a(3)
	m.srcen_11ab=asrcen11a(4)
	m.srcen_11cb=asrcen11a(5)
	m.srcen_11ac=asrcen11a(6)
	m.srcen_11cc=asrcen11a(7)
	m.srcen_11ad=asrcen11a(8)
	m.srcen_11cd=asrcen11a(9)
Endif
Release asrcen11a					

Select ;
	Grouper, ;
	Sum(IIF(source = '30 ',1,0)) as srcen_11ae, ;
	Sum(IIF(source = '30 ' and hudchronic=1,1,0)) as srcen_11ce, ;
	Sum(IIF(source = '31 ',1,0)) as srcen_11af, ;
	Sum(IIF(source = '31 ' and hudchronic=1,1,0)) as srcen_11cf, ;
	Sum(IIF(source = '22 ',1,0)) as srcen_11ag, ;
	Sum(IIF(source = '22 ' and hudchronic=1,1,0)) as srcen_11cg, ;
	Sum(IIF(source = '01 ',1,0)) as srcen_11ah, ;
	Sum(IIF(source = '01 ' and hudchronic=1,1,0)) as srcen_11ch ;
From ;
	IncSrcSt ;
Group by ;
	Grouper ;
Into Array ;
	asrcen11b

If _tally>0
	m.srcen_11ae=asrcen11b(2)
	m.srcen_11ce=asrcen11b(3)
	m.srcen_11af=asrcen11b(4)
	m.srcen_11cf=asrcen11b(5)
	m.srcen_11ag=asrcen11b(6)
	m.srcen_11cg=asrcen11b(7)
	m.srcen_11ah=asrcen11b(8)
	m.srcen_11ch=asrcen11b(9)
Endif	
Release asrcen11b					

Select ;
	Grouper, ;
	Sum(IIF(source = '11 ',1,0)) as srcen_11ai, ;
	Sum(IIF(source = '11 ' and hudchronic=1,1,0)) as srcen_11ci, ;
	Sum(IIF(source = '32 ',1,0)) as srcen_11aj, ;
	Sum(IIF(source = '32 ' and hudchronic=1,1,0)) as srcen_11cj, ;
	Sum(IIF(source = '02 ',1,0)) as srcen_11ak, ;
	Sum(IIF(source = '02 ' and hudchronic=1,1,0)) as srcen_11ck, ;
	Sum(IIF(source = '09 ',1,0)) as srcen_11al, ;
	Sum(IIF(source = '09 ' and hudchronic=1,1,0)) as srcen_11cl ;
From ;
	IncSrcSt ;
Group by ;
	Grouper ;
Into Array ;
	asrcen11c

If _tally>0
	m.srcen_11ai=asrcen11c(2)
	m.srcen_11ci=asrcen11c(3)
	m.srcen_11aj=asrcen11c(4)
	m.srcen_11cj=asrcen11c(5)
	m.srcen_11ak=asrcen11c(6)
	m.srcen_11ck=asrcen11c(7)
	m.srcen_11al=asrcen11c(8)
	m.srcen_11cl=asrcen11c(9)
Endif
Release asrcen11c					

* other
Select ;
	Count(tc_id) as SrcEn_11am ;
From ;
	IncSrcSt ;
Where ;
	!(source $ '01 02 03 05 09 11 15 16 22 30 31 32 ') ;
Into Array aSrcen11am
m.SrcEn_11am=IIF(_tally=0,0,aSrcen11am(1))
Release aSrcen11am

Select ;
	Count(tc_id) as SrcEn_11cm ;
From ;
	IncSrcSt ;
Where ;
	!(source $ '01 02 03 05 09 11 15 16 22 30 31 32 ') AND hudchronic=1 ;
Into Array aSrcen11cm
m.SrcEn_11cm=IIF(_tally=0,0,aSrcen11cm(1))
Release aSrcen11cm

* set "No Financial Resources" number equal to number with no income
m.Srcen_11an=m.Incen_11aa
m.Srcen_11cn=m.Incen_11ca

m.headerline='C. Income Sources at Entry                                       All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Supplemental Security Income (SSI)           ' + SPACE(24) + STR(m.srcen_11aa,6,0) + SPACE(4) + STR(m.srcen_11ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Social Security Disability Income (SSDI)     ' + SPACE(24) + STR(m.srcen_11ab,6,0) + SPACE(4) + STR(m.srcen_11cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. Social Security                              ' + SPACE(24) + STR(m.srcen_11ac,6,0) + SPACE(4) + STR(m.srcen_11cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. General Public Assistance                    ' + SPACE(24) + STR(m.srcen_11ad,6,0) + SPACE(4) + STR(m.srcen_11cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. Temporary Aid to Needy Families (TANF)       ' + SPACE(24) + STR(m.srcen_11ae,6,0) + SPACE(4) + STR(m.srcen_11ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. State Childrens Health Insurance Program (SCHIP)' + SPACE(21) + STR(m.srcen_11af,6,0) + SPACE(4) + STR(m.srcen_11cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. Veterans Benefits                            ' + SPACE(24) + STR(m.srcen_11ag,6,0) + SPACE(4) + STR(m.srcen_11cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. Employment Income                            ' + SPACE(24) + STR(m.srcen_11ah,6,0) + SPACE(4) + STR(m.srcen_11ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='i. Unemployment benefits                        ' + SPACE(24) + STR(m.srcen_11ai,6,0) + SPACE(4) + STR(m.srcen_11ci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Veterans Health Care                         ' + SPACE(24) + STR(m.srcen_11aj,6,0) + SPACE(4) + STR(m.srcen_11cj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='k. Medicaid                                     ' + SPACE(24) + STR(m.srcen_11ak,6,0) + SPACE(4) + STR(m.srcen_11ck,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='l. Food Stamps                                  ' + SPACE(24) + STR(m.srcen_11al,6,0) + SPACE(4) + STR(m.srcen_11cl,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='m. Other                                        ' + SPACE(24) + STR(m.srcen_11am,6,0) + SPACE(4) + STR(m.srcen_11cm,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='n. No Financial Resources                       ' + SPACE(24) + STR(m.srcen_11an,6,0) + SPACE(4) + STR(m.srcen_11cn,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

* count income sources at exit

Select ;
	Grouper, ;
	Sum(IIF(source = '15 ',1,0)) as srcex_11aa, ;
	Sum(IIF(source = '15 ' and hudchronic=1,1,0)) as srcex_11ca, ;
	Sum(IIF(source = '16 ',1,0)) as srcex_11ab, ;
	Sum(IIF(source = '16 ' and hudchronic=1,1,0)) as srcex_11cb, ;
	Sum(IIF(source = '03 ',1,0)) as srcex_11ac, ;
	Sum(IIF(source = '03 ' and hudchronic=1,1,0)) as srcex_11cc, ;
	Sum(IIF(source = '05 ',1,0)) as srcex_11ad, ;
	Sum(IIF(source = '05 ' and hudchronic=1,1,0)) as srcex_11cd ;
From ;
	IncSrcEnd ;
Group by ;
	Grouper ;
Into Array ;
	asrcex11a

If _tally>0
	m.srcex_11aa=asrcex11a(2)
	m.srcex_11ca=asrcex11a(3)
	m.srcex_11ab=asrcex11a(4)
	m.srcex_11cb=asrcex11a(5)
	m.srcex_11ac=asrcex11a(6)
	m.srcex_11cc=asrcex11a(7)
	m.srcex_11ad=asrcex11a(8)
	m.srcex_11cd=asrcex11a(9)
Endif
Release asrcex11a					

Select ;
	Grouper, ;
	Sum(IIF(source = '30 ',1,0)) as srcex_11ae, ;
	Sum(IIF(source = '30 ' and hudchronic=1,1,0)) as srcex_11ce, ;
	Sum(IIF(source = '31 ',1,0)) as srcex_11af, ;
	Sum(IIF(source = '31 ' and hudchronic=1,1,0)) as srcex_11cf, ;
	Sum(IIF(source = '22 ',1,0)) as srcex_11ag, ;
	Sum(IIF(source = '22 ' and hudchronic=1,1,0)) as srcex_11cg, ;
	Sum(IIF(source = '01 ',1,0)) as srcex_11ah, ;
	Sum(IIF(source = '01 ' and hudchronic=1,1,0)) as srcex_11ch ;
From ;
	IncSrcEnd ;
Group by ;
	Grouper ;
Into Array ;
	asrcex11b

If _tally>0
	m.srcex_11ae=asrcex11b(2)
	m.srcex_11ce=asrcex11b(3)
	m.srcex_11af=asrcex11b(4)
	m.srcex_11cf=asrcex11b(5)
	m.srcex_11ag=asrcex11b(6)
	m.srcex_11cg=asrcex11b(7)
	m.srcex_11ah=asrcex11b(8)
	m.srcex_11ch=asrcex11b(9)
Endif
Release asrcex11b					

Select ;
	Grouper, ;
	Sum(IIF(source = '11 ',1,0)) as srcex_11ai, ;
	Sum(IIF(source = '11 ' and hudchronic=1,1,0)) as srcex_11ci, ;
	Sum(IIF(source = '32 ',1,0)) as srcex_11aj, ;
	Sum(IIF(source = '32 ' and hudchronic=1,1,0)) as srcex_11cj, ;
	Sum(IIF(source = '02 ',1,0)) as srcex_11ak, ;
	Sum(IIF(source = '02 ' and hudchronic=1,1,0)) as srcex_11ck, ;
	Sum(IIF(source = '09 ',1,0)) as srcex_11al, ;
	Sum(IIF(source = '09 ' and hudchronic=1,1,0)) as srcex_11cl ;
From ;
	IncSrcEnd ;
Group by ;
	Grouper ;
Into Array ;
	asrcex11c

If _tally>0
	m.srcex_11ai=asrcex11c(2)
	m.srcex_11ci=asrcex11c(3)
	m.srcex_11aj=asrcex11c(4)
	m.srcex_11cj=asrcex11c(5)
	m.srcex_11ak=asrcex11c(6)
	m.srcex_11ck=asrcex11c(7)
	m.srcex_11al=asrcex11c(8)
	m.srcex_11cl=asrcex11c(9)
Endif	
Release asrcex11c					

* other
Select ;
	Count(tc_id) as Srcex_11am ;
From ;
	IncSrcEnd ;
Where ;
	!(source $ '01 02 03 05 09 11 15 16 22 30 31 32 ') ;
Into Array aSrcex11am
m.Srcex_11am=IIF(_tally=0,0,aSrcex11am(1))
Release aSrcex11am

Select ;
	Count(tc_id) as Srcex_11cm ;
From ;
	IncSrcEnd ;
Where ;
	!(source $ '01 02 03 05 09 11 15 16 22 30 31 32 ') AND hudchronic=1 ;
Into Array aSrcex11cm
m.Srcex_11cm=IIF(_tally=0,0,aSrcex11cm(1))
Release aSrcex11cm

* set "No Financial Resources" number equal to number with no income
m.Srcex_11an=m.Incex_11aa
m.Srcex_11cn=m.Incex_11ca

m.headerline='D. Income Sources at Exit                                        All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Supplemental Security Income (SSI)           ' + SPACE(24) + STR(m.srcex_11aa,6,0) + SPACE(4) + STR(m.srcex_11ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Social Security Disability Income (SSDI)     ' + SPACE(24) + STR(m.srcex_11ab,6,0) + SPACE(4) + STR(m.srcex_11cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. Social Security                              ' + SPACE(24) + STR(m.srcex_11ac,6,0) + SPACE(4) + STR(m.srcex_11cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. General Public Assistance                    ' + SPACE(24) + STR(m.srcex_11ad,6,0) + SPACE(4) + STR(m.srcex_11cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. Temporary Aid to Needy Families (TANF)       ' + SPACE(24) + STR(m.srcex_11ae,6,0) + SPACE(4) + STR(m.srcex_11ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. State Childrens Health Insurance Program (SCHIP)' + SPACE(21) + STR(m.srcex_11af,6,0) + SPACE(4) + STR(m.srcex_11cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. Veterans Benefits                            ' + SPACE(24) + STR(m.srcex_11ag,6,0) + SPACE(4) + STR(m.srcex_11cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. Employment Income                            ' + SPACE(24) + STR(m.srcex_11ah,6,0) + SPACE(4) + STR(m.srcex_11ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='i. Unemployment benefits                        ' + SPACE(24) + STR(m.srcex_11ai,6,0) + SPACE(4) + STR(m.srcex_11ci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Veterans Health Care                         ' + SPACE(24) + STR(m.srcex_11aj,6,0) + SPACE(4) + STR(m.srcex_11cj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='k. Medicaid                                     ' + SPACE(24) + STR(m.srcex_11ak,6,0) + SPACE(4) + STR(m.srcex_11ck,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='l. Food Stamps                                  ' + SPACE(24) + STR(m.srcex_11al,6,0) + SPACE(4) + STR(m.srcex_11cl,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='m. Other                                        ' + SPACE(24) + STR(m.srcex_11am,6,0) + SPACE(4) + STR(m.srcex_11cm,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='n. No Financial Resources                       ' + SPACE(24) + STR(m.srcex_11an,6,0) + SPACE(4) + STR(m.srcex_11cn,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.question=12
store 0 to m.los_12aaa, m.los_12aab, m.los_12aac, m.los_12aad, m.los_12aae, m.los_12aaf, m.los_12aag, m.los_12aah, m.los_12aai, m.los_12aaj
store 0 to m.los_12aca, m.los_12acb, m.los_12acc, m.los_12acd, m.los_12ace, m.los_12acf, m.los_12acg, m.los_12ach, m.los_12aci, m.los_12acj
store 0 to m.los_12baa, m.los_12bab, m.los_12bac, m.los_12bad, m.los_12bae, m.los_12baf, m.los_12bag, m.los_12bah, m.los_12bai, m.los_12baj
store 0 to m.los_12bca, m.los_12bcb, m.los_12bcc, m.los_12bcd, m.los_12bce, m.los_12bcf, m.los_12bcg, m.los_12bch, m.los_12bci, m.los_12bcj

* get length-of-stay durations for clients who left program during report period
Select ;
	'X' as Grouper, ;
	Sum(IIF(end_dt-start_dt <= 30, 1, 0)) 																As los_12aaa, ;
	Sum(IIF(end_dt-start_dt <= 30 and hudchronic=1, 1, 0))										As los_12aca, ;
	Sum(IIF(end_dt-start_dt > 30   and end_dt-start_dt <= 60,   1, 0))						As los_12aab, ;
	Sum(IIF(end_dt-start_dt > 30   and end_dt-start_dt <= 60 and hudchronic=1,   1, 0)) As los_12acb, ;
	Sum(IIF(end_dt-start_dt > 60   and end_dt-start_dt <= 182,  1, 0)) 						As los_12aac, ;
	Sum(IIF(end_dt-start_dt > 60   and end_dt-start_dt <= 182 and hudchronic=1,  1, 0)) As los_12acc  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12a
	
If _tally>0
	m.los_12aaa=aLos_12a(2)
	m.los_12aca=aLos_12a(3)
	m.los_12aab=aLos_12a(4)
	m.los_12acb=aLos_12a(5)
	m.los_12aac=aLos_12a(6)
	m.los_12acc=aLos_12a(7)
Endif
Release aLos_12a
	
Select ;
	'X' as Grouper, ;
	Sum(IIF(end_dt-start_dt > 182  and end_dt-start_dt <= 365,  1, 0)) 						As los_12aad, ;
	Sum(IIF(end_dt-start_dt > 182  and end_dt-start_dt <= 365 and hudchronic=1,  1, 0)) As los_12acd, ;
	Sum(IIF(end_dt-start_dt > 365  and end_dt-start_dt <= 730,  1, 0)) 						As los_12aae, ;
	Sum(IIF(end_dt-start_dt > 365  and end_dt-start_dt <= 730 and hudchronic=1,  1, 0)) As los_12ace ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12a1
	
If _tally>0
	m.los_12aad=aLos_12a1(2)
	m.los_12acd=aLos_12a1(3)
	m.los_12aae=aLos_12a1(4)
	m.los_12ace=aLos_12a1(5)
Endif
Release aLos_12a1
	
Select ;
	'X' as Grouper, ;
	Sum(IIF(end_dt-start_dt > 730  and end_dt-start_dt <= 1095, 1, 0)) 						As los_12aaf, ;
	Sum(IIF(end_dt-start_dt > 730  and end_dt-start_dt <= 1095 and hudchronic=1, 1, 0)) As los_12acf, ;
	Sum(IIF(end_dt-start_dt > 1095 and end_dt-start_dt <= 1825, 1, 0)) 						As los_12aag, ;
	Sum(IIF(end_dt-start_dt > 1095 and end_dt-start_dt <= 1825 and hudchronic=1, 1, 0)) As los_12acg, ;
	Sum(IIF(end_dt-start_dt > 1825 and end_dt-start_dt <= 2555, 1, 0)) 						As los_12aah, ;
	Sum(IIF(end_dt-start_dt > 1825 and end_dt-start_dt <= 2555 and hudchronic=1, 1, 0)) As los_12ach  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12a2
	
If _tally>0
	m.los_12aaf=aLos_12a2(2)
	m.los_12acf=aLos_12a2(3)
	m.los_12aag=aLos_12a2(4)
	m.los_12acg=aLos_12a2(5)
	m.los_12aah=aLos_12a2(6)
	m.los_12ach=aLos_12a2(7)
Endif
Release aLos_12a2
	
Select ;
	'X' as Grouper, ;
	Sum(IIF(end_dt-start_dt > 2555 and end_dt-start_dt <= 3650, 1, 0)) 						As los_12aai, ;
	Sum(IIF(end_dt-start_dt > 2555 and end_dt-start_dt <= 3650 and hudchronic=1, 1, 0)) As los_12aci, ;
	Sum(IIF(end_dt-start_dt > 3650, 1, 0)) 															As los_12aaj, ;
	Sum(IIF(end_dt-start_dt > 3650 and hudchronic=1, 1, 0))										As los_12acj  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12a3
	
If _tally>0
	m.los_12aai=aLos_12a3(2)
	m.los_12aci=aLos_12a3(3)
	m.los_12aaj=aLos_12a3(4)
	m.los_12acj=aLos_12a3(5)
Endif
Release aLos_12a3
	
m.headerline='12a. Length of Stay in Program'
Insert Into hud_tmp From Memvar
m.headerline='     (participants who LEFT during operating year)               All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Less than 1 month                            ' + SPACE(24) + STR(m.los_12aaa,6,0) + SPACE(4) + STR(m.los_12aca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. 1 to 2 months                                ' + SPACE(24) + STR(m.los_12aab,6,0) + SPACE(4) + STR(m.los_12acb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. 3 - 6 months                                 ' + SPACE(24) + STR(m.los_12aac,6,0) + SPACE(4) + STR(m.los_12acc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. 7 months - 12 months                         ' + SPACE(24) + STR(m.los_12aad,6,0) + SPACE(4) + STR(m.los_12acd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. 13 months - 24 months                        ' + SPACE(24) + STR(m.los_12aae,6,0) + SPACE(4) + STR(m.los_12ace,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. 25 months - 3 years                          ' + SPACE(24) + STR(m.los_12aaf,6,0) + SPACE(4) + STR(m.los_12acf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. 4 years - 5 years                            ' + SPACE(24) + STR(m.los_12aag,6,0) + SPACE(4) + STR(m.los_12acg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. 6 years - 7 years                            ' + SPACE(24) + STR(m.los_12aah,6,0) + SPACE(4) + STR(m.los_12ach,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='i. 8 years - 10 years                           ' + SPACE(24) + STR(m.los_12aai,6,0) + SPACE(4) + STR(m.los_12aci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Over 10 years                                ' + SPACE(24) + STR(m.los_12aaj,6,0) + SPACE(4) + STR(m.los_12acj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

* now, let's see who is ENROLLED in a HUD/HOPWA program AS OF the operating year end date
If Used('AllEnrEnd') 
   Use in AllEnrEnd
EndIf

Select Distinct ;
		tc_id, ;
		client_id, ;
		start_dt, ;
		end_dt, ;
		hudchronic ;
From ;
		tProgCli ;
Where ;
		start_dt < date_to ;
  And	(Empty(end_dt) Or end_dt > date_to) ;
Into Cursor ;
		AllEnrEnd

Select ;
	'X' as Grouper, ;
	Sum(IIF(date_to-start_dt <= 30, 1, 0))                                               As los_12baa, ;
	Sum(IIF(date_to-start_dt <= 30 and hudchronic=1, 1, 0))                              As los_12bca, ;
	Sum(IIF(date_to-start_dt > 30   and date_to-start_dt <= 60 , 1, 0))                  As los_12bab, ;
	Sum(IIF(date_to-start_dt > 30   and date_to-start_dt <= 60 and hudchronic=1, 1, 0))  As los_12bcb, ;
	Sum(IIF(date_to-start_dt > 60   and date_to-start_dt <= 182, 1, 0))                  As los_12bac, ;
	Sum(IIF(date_to-start_dt > 60   and date_to-start_dt <= 182 and hudchronic=1, 1, 0)) As los_12bcc  ;
From ;
	AllEnrEnd ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12b
	
If _tally>0
	m.los_12baa=aLos_12b(2) 
	m.los_12bca=aLos_12b(3)
	m.los_12bab=aLos_12b(4)
	m.los_12bcb=aLos_12b(5)
	m.los_12bac=aLos_12b(6)
	m.los_12bcc=aLos_12b(7)
Endif	
Release aLos_12b
	
Select ;
	'X' as Grouper, ;
	Sum(IIF(date_to-start_dt > 182  and date_to-start_dt <= 365, 1, 0))                  As los_12bad, ;
	Sum(IIF(date_to-start_dt > 182  and date_to-start_dt <= 365 and hudchronic=1, 1, 0)) As los_12bcd, ;
	Sum(IIF(date_to-start_dt > 365  and date_to-start_dt <= 730, 1, 0))                  As los_12bae, ;
	Sum(IIF(date_to-start_dt > 365  and date_to-start_dt <= 730 and hudchronic=1, 1, 0)) As los_12bce  ;
From ;
	AllEnrEnd ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12b1
	
If _tally>0
	m.los_12bad=aLos_12b1(2) 
	m.los_12bcd=aLos_12b1(3)
	m.los_12bae=aLos_12b1(4)
	m.los_12bce=aLos_12b1(5)
Endif
Release aLos_12b1
	
Select ;
	'X' as Grouper, ;
	Sum(IIF(date_to-start_dt > 730  and date_to-start_dt <= 1095, 1, 0))                  As los_12baf, ;
	Sum(IIF(date_to-start_dt > 730  and date_to-start_dt <= 1095 and hudchronic=1, 1, 0)) As los_12bcf, ;
	Sum(IIF(date_to-start_dt > 1095 and date_to-start_dt <= 1825, 1, 0))                  As los_12bag, ;
	Sum(IIF(date_to-start_dt > 1095 and date_to-start_dt <= 1825 and hudchronic=1, 1, 0)) As los_12bcg, ;
	Sum(IIF(date_to-start_dt > 1825 and date_to-start_dt <= 2555, 1, 0))                  As los_12bah, ;
	Sum(IIF(date_to-start_dt > 1825 and date_to-start_dt <= 2555 and hudchronic=1, 1, 0)) As los_12bch ;
From ;
	AllEnrEnd ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12b2
	
If _tally>0
	m.los_12baf=aLos_12b2(2)
	m.los_12bcf=aLos_12b2(3)
	m.los_12bag=aLos_12b2(4)
	m.los_12bcg=aLos_12b2(5)
	m.los_12bah=aLos_12b2(6)
	m.los_12bch=aLos_12b2(7)
Endif	
Release aLos_12b2
	
Select ;
	'X' as Grouper, ;
	Sum(IIF(date_to-start_dt > 2555 and date_to-start_dt <= 3650, 1, 0))                  As los_12bai, ;
	Sum(IIF(date_to-start_dt > 2555 and date_to-start_dt <= 3650 and hudchronic=1, 1, 0)) As los_12bci, ;
	Sum(IIF(date_to-start_dt > 3650, 1, 0))                                               As los_12baj, ;
	Sum(IIF(date_to-start_dt > 3650 and hudchronic=1, 1, 0))                              As los_12bcj  ;
From ;
	AllEnrEnd ;
Group by ;
	Grouper ;
Into Array ;
	aLos_12b3
	
If _tally>0
	m.los_12bai=aLos_12b3(2)
	m.los_12bci=aLos_12b3(3)
	m.los_12baj=aLos_12b3(4)
	m.los_12bcj=aLos_12b3(5)
Endif	
Release aLos_12b3
	
m.headerline='12b. Length of Stay in Program'
Insert Into hud_tmp From Memvar
m.headerline='     (participants who DID NOT LEAVE during operating year)      All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Less than 1 month                            ' + SPACE(24) + STR(m.los_12baa,6,0) + SPACE(4) + STR(m.los_12bca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. 1 to 2 months                                ' + SPACE(24) + STR(m.los_12bab,6,0) + SPACE(4) + STR(m.los_12bcb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. 3 - 6 months                                 ' + SPACE(24) + STR(m.los_12bac,6,0) + SPACE(4) + STR(m.los_12bcc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. 7 months - 12 months                         ' + SPACE(24) + STR(m.los_12bad,6,0) + SPACE(4) + STR(m.los_12bcd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. 13 months - 24 months                        ' + SPACE(24) + STR(m.los_12bae,6,0) + SPACE(4) + STR(m.los_12bce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. 25 months - 3 years                          ' + SPACE(24) + STR(m.los_12baf,6,0) + SPACE(4) + STR(m.los_12bcf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. 4 years - 5 years                            ' + SPACE(24) + STR(m.los_12bag,6,0) + SPACE(4) + STR(m.los_12bcg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. 6 years - 7 years                            ' + SPACE(24) + STR(m.los_12bah,6,0) + SPACE(4) + STR(m.los_12bch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='i. 8 years - 10 years                           ' + SPACE(24) + STR(m.los_12bai,6,0) + SPACE(4) + STR(m.los_12bci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Over 10 years                                ' + SPACE(24) + STR(m.los_12baj,6,0) + SPACE(4) + STR(m.los_12bcj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

********************************************************
m.question=13
store 0 to m.rfl_13aa, m.rfl_13ab, m.rfl_13ac, m.rfl_13ad, m.rfl_13ae, m.rfl_13af, m.rfl_13ag, m.rfl_13ah, m.rfl_13ai, m.rfl_13aj, m.rfl_13ak 
store 0 to m.rfl_13ca, m.rfl_13cb, m.rfl_13cc, m.rfl_13cd, m.rfl_13ce, m.rfl_13cf, m.rfl_13cg, m.rfl_13ch, m.rfl_13ci, m.rfl_13cj, m.rfl_13ck 

Select ;
	'X' as Grouper, ;
	Sum(IIF(reason='25',1, 0))                  As rfl_13aa, ;
	Sum(IIF(reason='25' and hudchronic=1,1, 0)) As rfl_13ca, ;
	Sum(IIF(reason='14',1, 0))                  As rfl_13ab, ;
	Sum(IIF(reason='14' and hudchronic=1,1, 0)) As rfl_13cb, ;
	Sum(IIF(reason='26',1, 0))                  As rfl_13ac, ;
	Sum(IIF(reason='26' and hudchronic=1,1, 0)) As rfl_13cc, ;
	Sum(IIF(reason='16',1, 0))                  As rfl_13ad, ;
	Sum(IIF(reason='16' and hudchronic=1,1, 0)) As rfl_13cd  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aRfl_13a
	
If _tally>0
	m.rfl_13aa=aRfl_13a(2)
	m.rfl_13ca=aRfl_13a(3)
	m.rfl_13ab=aRfl_13a(4)
	m.rfl_13cb=aRfl_13a(5)
	m.rfl_13ac=aRfl_13a(6)
	m.rfl_13cc=aRfl_13a(7)
	m.rfl_13ad=aRfl_13a(8)
	m.rfl_13cd=aRfl_13a(9)
Endif
Release aRfl_13a

Select ;
	'X' as Grouper, ;
	Sum(IIF(reason='30',1, 0))                  As rfl_13ae, ;
	Sum(IIF(reason='30' and hudchronic=1,1, 0)) As rfl_13ce, ;
	Sum(IIF(reason='27',1, 0))                  As rfl_13af, ;
	Sum(IIF(reason='27' and hudchronic=1,1, 0)) As rfl_13cf, ;
	Sum(IIF(reason='28',1, 0))                  As rfl_13ag, ;
	Sum(IIF(reason='28' and hudchronic=1,1, 0)) As rfl_13cg, ;
	Sum(IIF(reason='29',1, 0))                  As rfl_13ah, ;
	Sum(IIF(reason='29' and hudchronic=1,1, 0)) As rfl_13ch  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aRfl_13b
	
If _tally>0
	m.rfl_13ae=aRfl_13b(2)
	m.rfl_13ce=aRfl_13b(3)
	m.rfl_13af=aRfl_13b(4)
	m.rfl_13cf=aRfl_13b(5)
	m.rfl_13ag=aRfl_13b(6)
	m.rfl_13cg=aRfl_13b(7)
	m.rfl_13ah=aRfl_13b(8)
	m.rfl_13ch=aRfl_13b(9)
Endif
Release aRfl_13b

Select ;
	'X' as Grouper, ;
	Sum(IIF(reason='10',1, 0))                 																	As rfl_13ai, ;
	Sum(IIF(reason='10' and hudchronic=1,1, 0))  																As rfl_13ci, ;
	Sum(IIF(!Empty(reason) and !(reason $ '10 14 16 25 26 27 28 29 30'),1, 0)) 						As rfl_13aj, ;
	Sum(IIF(!Empty(reason) and !(reason $ '10 14 16 25 26 27 28 29 30') and hudchronic=1,1, 0)) 	As rfl_13cj, ;
	Sum(IIF(Empty(reason),1, 0)) 																						As rfl_13ak, ;
	Sum(IIF(Empty(reason) and hudchronic=1,1,0)) 																As rfl_13ck ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	aRfl_13c
	
If _tally>0
	m.rfl_13ai=aRfl_13c(2)
	m.rfl_13ci=aRfl_13c(3)
	m.rfl_13aj=aRfl_13c(4)
	m.rfl_13cj=aRfl_13c(5)
	m.rfl_13ak=aRfl_13c(6)
	m.rfl_13ck=aRfl_13c(7)
Endif	
Release aRfl_13c

m.detailline=''
m.headerline='13. Reasons for Leaving'
Insert Into hud_tmp From Memvar
m.headerline='     (participants who LEFT during operating year)               All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.detailline='a. Left for a housing opportunity before completing program' + SPACE(13) + STR(m.rfl_13aa,6,0) + SPACE(4) + STR(m.rfl_13ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Completed program                                      ' + SPACE(14) + STR(m.rfl_13ab,6,0) + SPACE(4) + STR(m.rfl_13cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. Non-payment of rent/occupancy charge                   ' + SPACE(14) + STR(m.rfl_13ac,6,0) + SPACE(4) + STR(m.rfl_13cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. Non-compliance with project                            ' + SPACE(14) + STR(m.rfl_13ad,6,0) + SPACE(4) + STR(m.rfl_13cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. Criminal activity/destruction of property/violence     ' + SPACE(14) + STR(m.rfl_13ae,6,0) + SPACE(4) + STR(m.rfl_13ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. Reached maximum time allowed in project                ' + SPACE(14) + STR(m.rfl_13af,6,0) + SPACE(4) + STR(m.rfl_13cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. Needs could not be met by project                      ' + SPACE(14) + STR(m.rfl_13ag,6,0) + SPACE(4) + STR(m.rfl_13cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. Disagreement with rules/persons                        ' + SPACE(14) + STR(m.rfl_13ah,6,0) + SPACE(4) + STR(m.rfl_13ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='i. Death                                                  ' + SPACE(14) + STR(m.rfl_13ai,6,0) + SPACE(4) + STR(m.rfl_13ci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Other                                                  ' + SPACE(14) + STR(m.rfl_13aj,6,0) + SPACE(4) + STR(m.rfl_13cj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='k. Unknown/disappeared                                    ' + SPACE(14) + STR(m.rfl_13ak,6,0) + SPACE(4) + STR(m.rfl_13ck,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.question=14
store 0 to m.des_14aa, m.des_14ab, m.des_14ac, m.des_14ad, m.des_14ae, m.des_14af, m.des_14ag, m.des_14ah, m.des_14ai, m.des_14aj, m.des_14ak, m.des_14al, m.des_14am, m.des_14an, m.des_14ao, m.des_14ap, m.des_14aq, m.des_14ar 
store 0 to m.des_14ca, m.des_14cb, m.des_14cc, m.des_14cd, m.des_14ce, m.des_14cf, m.des_14cg, m.des_14ch, m.des_14ci, m.des_14cj, m.des_14ck, m.des_14cl, m.des_14cm, m.des_14cn, m.des_14co, m.des_14cp, m.des_14cq, m.des_14cr 

Select ;
	'X' as Grouper, ;
	Sum(IIF(destinat='01',1, 0))                  As des_14aa, ;
	Sum(IIF(destinat='01' and hudchronic=1,1, 0)) As des_14ca, ;
	Sum(IIF(destinat='02',1, 0))                  As des_14ab, ;
	Sum(IIF(destinat='02' and hudchronic=1,1, 0)) As des_14cb, ;
	Sum(IIF(destinat='03',1, 0))                  As des_14ac, ;
	Sum(IIF(destinat='03' and hudchronic=1,1, 0)) As des_14cc  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	ades_14a

If _tally>0
	m.des_14aa=ades_14a(2)
	m.des_14ca=ades_14a(3)
	m.des_14ab=ades_14a(4)
	m.des_14cb=ades_14a(5)
	m.des_14ac=ades_14a(6)
	m.des_14cc=ades_14a(7)
Endif
Release ades_14a

Select ;
	'X' as Grouper, ;
	Sum(IIF(destinat='04',1, 0))                  As des_14ad, ;
	Sum(IIF(destinat='04' and hudchronic=1,1, 0)) As des_14cd, ;
	Sum(IIF(destinat='05',1, 0))                  As des_14ae, ;
	Sum(IIF(destinat='05' and hudchronic=1,1, 0)) As des_14ce, ;
	Sum(IIF(destinat='06',1, 0))                  As des_14af, ;
	Sum(IIF(destinat='06' and hudchronic=1,1, 0)) As des_14cf  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	ades_14b

If _tally>0
	m.des_14ad=ades_14b(2)
	m.des_14cd=ades_14b(3)
	m.des_14ae=ades_14b(4)
	m.des_14ce=ades_14b(5)
	m.des_14af=ades_14b(6)
	m.des_14cf=ades_14b(7)
Endif
Release ades_14b

Select ;
	'X' as Grouper, ;
	Sum(IIF(destinat='07',1, 0))                  As des_14ag, ;
	Sum(IIF(destinat='07' and hudchronic=1,1, 0)) As des_14cg, ;
	Sum(IIF(destinat='08',1, 0))                  As des_14ah, ;
	Sum(IIF(destinat='08' and hudchronic=1,1, 0)) As des_14ch, ;
	Sum(IIF(destinat='09',1, 0))                  As des_14ai, ;
	Sum(IIF(destinat='09' and hudchronic=1,1, 0)) As des_14ci  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	ades_14c

If _tally>0
	m.des_14ag=ades_14c(2)
	m.des_14cg=ades_14c(3)
	m.des_14ah=ades_14c(4)
	m.des_14ch=ades_14c(5)
	m.des_14ai=ades_14c(6)
	m.des_14ci=ades_14c(7)
Endif
Release ades_14c

Select ;
	'X' as Grouper, ;
	Sum(IIF(destinat='10',1, 0))                  As des_14aj, ;
	Sum(IIF(destinat='10' and hudchronic=1,1, 0)) As des_14cj, ;
	Sum(IIF(destinat='11',1, 0))                  As des_14ak, ;
	Sum(IIF(destinat='11' and hudchronic=1,1, 0)) As des_14ck, ;
	Sum(IIF(destinat='12',1, 0))                  As des_14al, ;
	Sum(IIF(destinat='12' and hudchronic=1,1, 0)) As des_14cl  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	ades_14d

If _tally>0
	m.des_14aj=ades_14d(2)
	m.des_14cj=ades_14d(3)
	m.des_14ak=ades_14d(4)
	m.des_14ck=ades_14d(5)
	m.des_14al=ades_14d(6)
	m.des_14cl=ades_14d(7)
Endif	
Release ades_14d

Select ;
	'X' as Grouper, ;
	Sum(IIF(destinat='13',1, 0))                  As des_14am, ;
	Sum(IIF(destinat='13' and hudchronic=1,1, 0)) As des_14cm, ;
	Sum(IIF(destinat='14',1, 0))                  As des_14an, ;
	Sum(IIF(destinat='14' and hudchronic=1,1, 0)) As des_14cn, ;
	Sum(IIF(destinat='15',1, 0))                  As des_14ao, ;
	Sum(IIF(destinat='15' and hudchronic=1,1, 0)) As des_14co  ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	ades_14e

If _tally>0
	m.des_14am=ades_14e(2)
	m.des_14cm=ades_14e(3)
	m.des_14an=ades_14e(4)
	m.des_14cn=ades_14e(5)
	m.des_14ao=ades_14e(6)
	m.des_14co=ades_14e(7)
Endif	
Release ades_14e

Select ;
	'X' as Grouper, ;
	Sum(IIF(destinat='16',1, 0))                  							As des_14ap, ;
	Sum(IIF(destinat='16' and hudchronic=1,1, 0)) 							As des_14cp, ;
	Sum(IIF(destinat='17',1, 0))                  							As des_14aq, ;
	Sum(IIF(destinat='17' and hudchronic=1,1, 0)) 							As des_14cq, ;
	Sum(IIF(Empty(destinat) or destinat='18',1, 0))    					As des_14ar, ;
	Sum(IIF((Empty(destinat) or destinat='18') and hudchronic=1,1,0)) As des_14cr ;
From ;
	LeftDuring ;
Group by ;
	Grouper ;
Into Array ;
	ades_14f

If _tally>0
	m.des_14ap=ades_14f(2)
	m.des_14cp=ades_14f(3)
	m.des_14aq=ades_14f(4)
	m.des_14cq=ades_14f(5)
	m.des_14ar=ades_14f(6)
	m.des_14cr=ades_14f(7)
Endif
Release ades_14f

m.detailline=''
m.headerline='14. Destination'
Insert Into hud_tmp From Memvar
m.headerline='     (participants who LEFT during operating year)'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar
m.headerline='PERMANENT (a-h)                                                  All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='a. Rental house or apartment (no subsidy)                 ' + SPACE(14) + STR(m.des_14aa,6,0) + SPACE(4) + STR(m.des_14ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Public Housing                                         ' + SPACE(14) + STR(m.des_14ab,6,0) + SPACE(4) + STR(m.des_14cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. Section 8                                              ' + SPACE(14) + STR(m.des_14ac,6,0) + SPACE(4) + STR(m.des_14cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. Shelter Plus Care                                      ' + SPACE(14) + STR(m.des_14ad,6,0) + SPACE(4) + STR(m.des_14cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. HOME subsidized house or apartment                     ' + SPACE(14) + STR(m.des_14ae,6,0) + SPACE(4) + STR(m.des_14ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. Other subsidized house or apartment                    ' + SPACE(14) + STR(m.des_14af,6,0) + SPACE(4) + STR(m.des_14cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. Homeownership                                          ' + SPACE(14) + STR(m.des_14ag,6,0) + SPACE(4) + STR(m.des_14cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. Moved in with family or friends                        ' + SPACE(14) + STR(m.des_14ah,6,0) + SPACE(4) + STR(m.des_14ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.headerline='TRANSITIONAL (i-j)                                               All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='i. Transitional housing for homeless persons              ' + SPACE(14) + STR(m.des_14ai,6,0) + SPACE(4) + STR(m.des_14ci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Moved in with family or friends                        ' + SPACE(14) + STR(m.des_14aj,6,0) + SPACE(4) + STR(m.des_14cj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.headerline='INSTITUTION (k-m)                                                All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='k. Psychiatric hospital                                   ' + SPACE(14) + STR(m.des_14ak,6,0) + SPACE(4) + STR(m.des_14ck,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='l. Inpatient alcohol or other drug treatment facility     ' + SPACE(14) + STR(m.des_14al,6,0) + SPACE(4) + STR(m.des_14cl,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='m. Jail/prison                                            ' + SPACE(14) + STR(m.des_14am,6,0) + SPACE(4) + STR(m.des_14cm,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.headerline='EMERGENCY SHELTER (n)                                            All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='n. Emergency Shelter                                      ' + SPACE(14) + STR(m.des_14an,6,0) + SPACE(4) + STR(m.des_14cn,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.headerline='OTHER (o-q)                                                      All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='o. Other supportive housing                               ' + SPACE(14) + STR(m.des_14ao,6,0) + SPACE(4) + STR(m.des_14co,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='p. Places not meant for human habitation (e.g., street)   ' + SPACE(14) + STR(m.des_14ap,6,0) + SPACE(4) + STR(m.des_14cp,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='q. Other                                                  ' + SPACE(14) + STR(m.des_14aq,6,0) + SPACE(4) + STR(m.des_14cq,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar

m.headerline='UNKNOWN (r)                                                      All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
m.detailline='r. Unknown                                                ' + SPACE(14) + STR(m.des_14ar,6,0) + SPACE(4) + STR(m.des_14cr,6,0) 
Insert Into hud_tmp From Memvar
m.detailline=''
Insert Into hud_tmp From Memvar


* count clients who've left program during period that have had hud/hopwa services
m.question=15
store 0 to m.ss_15aa, m.ss_15ab, m.ss_15ac, m.ss_15ad, m.ss_15ae, m.ss_15af, m.ss_15ag, m.ss_15ah, m.ss_15ai, m.ss_15aj, m.ss_15ak, m.ss_15al, m.ss_15am, m.ss_15an
store 0 to m.ss_15ca, m.ss_15cb, m.ss_15cc, m.ss_15cd, m.ss_15ce, m.ss_15cf, m.ss_15cg, m.ss_15ch, m.ss_15ci, m.ss_15cj, m.ss_15ck, m.ss_15cl, m.ss_15cm, m.ss_15cn

* outreach
Select ;
	Count(tc_id) as ss_15aa ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                           join lv_enc_type on ;
                              ai_enc.enc_id = lv_enc_type.enc_id and ;
                              ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                              ai_enc.serv_cat='00022' and lv_enc_type.code ='01') ;
Into Array ;
	ass_15aa
m.ss_15aa=IIF(_tally=0,0,ass_15aa(1))
Release ass_15aa

Select ;
	Count(tc_id) as ss_15ca ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                          join lv_enc_type on ;
                              ai_enc.enc_id = lv_enc_type.enc_id and ;
                              ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                              ai_enc.serv_cat='00022' and lv_enc_type.code ='01') ;
Into Array ;
	ass_15ca
m.ss_15ca=IIF(_tally=0,0,ass_15ca(1))
Release ass_15ca

* case management
Select ;
	Count(tc_id) as ss_15ab ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                              join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='02') ;
Into Array ;
	ass_15ab
m.ss_15ab=IIF(_tally=0,0,ass_15ab(1))
Release ass_15ab

Select ;
	Count(tc_id) as ss_15cb ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                            join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='02') ;
Into Array ;
	ass_15cb
m.ss_15cb=IIF(_tally=0,0,ass_15cb(1))
Release ass_15cb

* life skills
Select ;
	Count(tc_id) as ss_15ac ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                            join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='03') ;
Into Array ;
	ass_15ac
m.ss_15ac=IIF(_tally=0,0,ass_15ac(1))
Release ass_15ac

Select ;
	Count(tc_id) as ss_15cc ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                          join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='03') ;
Into Array ;
	ass_15cc
m.ss_15cc=IIF(_tally=0,0,ass_15cc(1))
Release ass_15cc

* alcohol or drug abuse services
Select ;
	Count(tc_id) as ss_15ad ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                            join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='04') ;
Into Array ;
	ass_15ad
m.ss_15ad=IIF(_tally=0,0,ass_15ad(1))
Release ass_15ad

Select ;
	Count(tc_id) as ss_15cd ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                           join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='04') ;
Into Array ;
	ass_15cd
m.ss_15cd=IIF(_tally=0,0,ass_15cd(1))
Release ass_15cd

* mental health services
Select ;
	Count(tc_id) as ss_15ae ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                 join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='05') ;
Into Array ;
	ass_15ae
m.ss_15ae=IIF(_tally=0,0,ass_15ae(1))
Release ass_15ae

Select ;
	Count(tc_id) as ss_15ce ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                       join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='05') ;
Into Array ;
	ass_15ce
m.ss_15ce=IIF(_tally=0,0,ass_15ce(1))
Release ass_15ce

* HIV/AIDS-related services
Select ;
	Count(tc_id) as ss_15af ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                    join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='06') ;
Into Array ;
	ass_15af
m.ss_15af=IIF(_tally=0,0,ass_15af(1))
Release ass_15af

Select ;
	Count(tc_id) as ss_15cf ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                             join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='06') ;
Into Array ;
	ass_15cf
m.ss_15cf=IIF(_tally=0,0,ass_15cf(1))
Release ass_15cf

* other health care services
Select ;
	Count(tc_id) as ss_15ag ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                             join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='07') ;
Into Array ;
	ass_15ag
m.ss_15ag=IIF(_tally=0,0,ass_15ag(1))
Release ass_15ag

Select ;
	Count(tc_id) as ss_15cg ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                                join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='07') ;
Into Array ;
	ass_15cg
m.ss_15cg=IIF(_tally=0,0,ass_15cg(1))
Release ass_15cg

* education
Select ;
	Count(tc_id) as ss_15ah ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                       join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='08') ;
Into Array ;
	ass_15ah
m.ss_15ah=IIF(_tally=0,0,ass_15ah(1))
Release ass_15ah

Select ;
	Count(tc_id) as ss_15ch ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                          join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='08') ;
Into Array ;
	ass_15ch
m.ss_15ch=IIF(_tally=0,0,ass_15ch(1))
Release ass_15ch

* housing placment
Select ;
	Count(tc_id) as ss_15ai ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                        join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='09') ;
Into Array ;
	ass_15ai
m.ss_15ai=IIF(_tally=0,0,ass_15ai(1))
Release ass_15ai

Select ;
	Count(tc_id) as ss_15ci ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                           join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='09') ;
Into Array ;
	ass_15ci
m.ss_15ci=IIF(_tally=0,0,ass_15ci(1))
Release ass_15ci

* employment assistance
Select ;
	Count(tc_id) as ss_15aj ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc;
                              join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='10') ;
Into Array ;
	ass_15aj
m.ss_15aj=IIF(_tally=0,0,ass_15aj(1))
Release ass_15aj

Select ;
	Count(tc_id) as ss_15cj ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc;
                        join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='10') ;
Into Array ;
	ass_15cj
m.ss_15cj=IIF(_tally=0,0,ass_15cj(1))
Release ass_15cj

* child care
Select ;
	Count(tc_id) as ss_15ak ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc;
                           join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='11') ;
Into Array ;
	ass_15ak
m.ss_15ak=IIF(_tally=0,0,ass_15ak(1))
Release ass_15ak

Select ;
	Count(tc_id) as ss_15ck ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc;
                              join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='11') ;
Into Array ;
	ass_15ck
m.ss_15ck=IIF(_tally=0,0,ass_15ck(1))
Release ass_15ck

* transportation
Select ;
	Count(tc_id) as ss_15al ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc;
                             join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='12') ; 
Into Array ;
	ass_15al
m.ss_15al=IIF(_tally=0,0,ass_15al(1))
Release ass_15al

Select ;
	Count(tc_id) as ss_15cl ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                     join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='12') ;
Into Array ;
	ass_15cl
m.ss_15cl=IIF(_tally=0,0,ass_15cl(1))
Release ass_15cl

* legal
Select ;
	Count(tc_id) as ss_15am ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                   join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='13') ;
Into Array ;
	ass_15am
m.ss_15am=IIF(_tally=0,0,ass_15am(1))
Release ass_15am

Select ;
	Count(tc_id) as ss_15cm ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                            join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='13') ;
Into Array ;
	ass_15cm
m.ss_15cm=IIF(_tally=0,0,ass_15cm(1))
Release ass_15cm

* other
Select ;
	Count(tc_id) as ss_15an ;
From ;
	LeftDuring ;
Where ;
	tc_id In (Select tc_id From ai_enc ;
                            join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='14') ;
Into Array ;
	ass_15an
m.ss_15an=IIF(_tally=0,0,ass_15an(1))
Release ass_15an

Select ;
	Count(tc_id) as ss_15cn ;
From ;
	LeftDuring ;
Where ;
	hudchronic=1 ;
  And ;
	tc_id In (Select tc_id From ai_enc ;
                         join lv_enc_type on ;
                                 ai_enc.enc_id = lv_enc_type.enc_id and ;
                                 ai_enc.serv_cat = lv_enc_type.serv_cat and ;
                                 ai_enc.serv_cat='00022' and lv_enc_type.code ='14') ;
Into Array ;
	ass_15cn
m.ss_15cn=IIF(_tally=0,0,ass_15cn(1))
Release ass_15cn

m.detailline=''
m.headerline=''
Insert Into hud_tmp From Memvar
Insert Into hud_tmp From Memvar
m.headerline='15. Supportive Services'
Insert Into hud_tmp From Memvar
m.headerline='     (participants who LEFT during operating year)               All    Chronic'
Insert Into hud_tmp From Memvar
m.headerline=''
Insert Into hud_tmp From Memvar 
m.detailline='a. Outreach                                               ' + SPACE(14) + STR(m.ss_15aa,6,0) + SPACE(4) + STR(m.ss_15ca,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='b. Case Management                                        ' + SPACE(14) + STR(m.ss_15ab,6,0) + SPACE(4) + STR(m.ss_15cb,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='c. Life skills (outside of case managment)                ' + SPACE(14) + STR(m.ss_15ac,6,0) + SPACE(4) + STR(m.ss_15cc,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='d. Alcohol or drug abuse services                         ' + SPACE(14) + STR(m.ss_15ad,6,0) + SPACE(4) + STR(m.ss_15cd,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='e. Mental health services                                 ' + SPACE(14) + STR(m.ss_15ae,6,0) + SPACE(4) + STR(m.ss_15ce,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='f. HIV/AIDS-related services                              ' + SPACE(14) + STR(m.ss_15af,6,0) + SPACE(4) + STR(m.ss_15cf,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='g. Other health care services                             ' + SPACE(14) + STR(m.ss_15ag,6,0) + SPACE(4) + STR(m.ss_15cg,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='h. Education                                              ' + SPACE(14) + STR(m.ss_15ah,6,0) + SPACE(4) + STR(m.ss_15ch,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='i. Housing placement                                      ' + SPACE(14) + STR(m.ss_15ai,6,0) + SPACE(4) + STR(m.ss_15ci,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='j. Employment assistance                                  ' + SPACE(14) + STR(m.ss_15aj,6,0) + SPACE(4) + STR(m.ss_15cj,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='k. Child care                                             ' + SPACE(14) + STR(m.ss_15ak,6,0) + SPACE(4) + STR(m.ss_15ck,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='l. Transportation                                         ' + SPACE(14) + STR(m.ss_15al,6,0) + SPACE(4) + STR(m.ss_15cl,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='m. Legal                                                  ' + SPACE(14) + STR(m.ss_15am,6,0) + SPACE(4) + STR(m.ss_15cm,6,0) 
Insert Into hud_tmp From Memvar
m.detailline='n. Other                                                  ' + SPACE(14) + STR(m.ss_15an,6,0) + SPACE(4) + STR(m.ss_15cn,6,0) 
Insert Into hud_tmp From Memvar

If Used('hud')
   Use in hud
EndIf

gcRptName = 'rpt_hud'

Select hud_tmp.* , ;
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from as Date_from, ;
       date_to as date_to; 
From hud_tmp ;
Into Cursor hud


oApp.msg2user('OFF')
            
GO TOP
IF EOF()
     oApp.msg2user('NOTFOUNDG')
Else
     DO CASE
         CASE lPrev = .f.
              Report Form rpt_hud To Printer Prompt Noconsole NODIALOG 
          CASE lPrev = .t.     &&Preview
              oApp.rpt_print(5, .t., 1, 'rpt_hud', 1, 2)
     ENDCASE   
EndIf

RETURN

**************
FUNCTION Adult
**************
* 10/27/04, assume 18 years old (18*12=216 months)...also, if no date entered (anonymous, assume adult)
PARAMETER mdob, mdate_to

lAdult=IIF(EMPTY(mdob),.t., mdate_to>=GOMONTH(mdob,216)) 

RETURN lAdult

***************
FUNCTION GetAge
***************
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
*  Function.........: CDC_AIDS
*  Created..........: 04/24/1998   09:54:33
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
m.CDCAge=IIF(!EMPTY(m.CDCDob), oApp.Age(DATE(),m.CDCDob), 0)
   
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

FUNCTION HIV_Pos
**********************************************************
*  Function.........: HIV_Pos
*  Created..........: 02/19/98   10:24:58
*) Description......: Detects if client is HIV positive
**********************************************************
PARAMETERS cTC_ID
PRIVATE lHIV_Pos
lHIV_Pos = .f.

***VT 11/11/2011 AIRS-183
 Dimension _aVNInfo(1)
           _aVNInfo[1]=''
            
      Select Top 1 table_id, verified_datetime ;
      From lv_verification_filtered ;
            Where vn_category='B' ;
            and Between(verified_datetime, Date_from, Date_to) ;
            and   tc_id = cTc_id ;
     Order by 2 desc Into Array _aVNInfo
     
    If !Empty(_aVNInfo[1,1])
               If Seek(_aVNInfo[1,1],'hivstat','status_id')
                   lHIV_Pos = hstat.hiv_pos
    				EndIf
    				
    Else     
             
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
							ENDIF      
   EndIf
   
RETURN lHIV_Pos

