*  Program...........: SUMMDEM.PRG (Demographics of New Clients by Age and Race/Ethnicity)
Parameters lPrev,  ;
            cContract, ;
            cCsite, ;
            date_from, ;
            date_to, ;
            eMPR  
            
PRIVATE gcHelp
gcHelp = "" 

cDate = DATE()
cTime = Time()
cAgency_id = " "
cAgc_Name = " "
cMonthYear = Cmonth(date_from) + ", " + RIGHT(DTOC(date_from),4)

=OPENFILE("Agency","Agency")
cAgency_ID = AllTrim(Agency.agency)
cAgc_Name = Agency.descript1
m.agencydesc = Agency.descript1
m.date_from = date_from
m.date_to = date_to

=clean_data()

m.ContrDes = ''
=OPENFILE("Contrinf")
SELECT Contrinf
Locate For Contrinf.Cid = cContract
m.ContrDes =Contrinf.Descript 

dDate_To = m.Date_To

* 1/99, jss, according to MHRA, should be using contract year for YTD totalling,
*            so better get that now:
SELECT ;
		start_dt AS ytd_from;
FROM  ;
		contract ;
WHERE ;
		contract.con_id = cContract ;
INTO CURSOR ;
		ytdfrom		

m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(m.date_from),4)),ytdfrom.ytd_from)

FOR i = 1 TO 2
* use contract start date for YTD numbers
	dDate_From = IIF(i = 1, m.date_from, m.ytd_from)
   IF i=1		
		SELECT DIST c.Con_ID AS Contract, a.Program, ;
			CalcAge(a.Start_Dt,g.Dob) AS Age, a.Tc_ID, a.Start_Dt, g.Dob, g.Sex, ;
			g.Gender, h.Gender AS TransSex, ;
			g.hispanic, g.white, g.blafrican, g.asian, g.hawaisland, g.indialaska, g.someother, g.unknowrep, ;
			SPACE(18) AS RACE ;
		FROM Ai_Prog A, ;
			Program B, ;
			Contract C, ;
			Ai_Site D, ;
			Site E, ;
			Ai_Clien F, ;
			Client G, ;
			Gender H ;
		WHERE c.Con_ID = cContract ;
			AND a.Program = b.Prog_ID ;
			AND b.Prog_ID = c.Program ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND a.Tc_ID = f.Tc_ID ;
			AND f.Client_ID = g.Client_ID ;
			AND g.Gender = h.Code ;
			AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
			AND !EXISTS (SELECT * FROM Ai_Prog ;
		 			WHERE Ai_Prog.Program = a.Program ;
		 				AND !EMPTY(Ai_Prog.End_Dt) ;
		 				AND AI_Prog.End_Dt <= a.Start_Dt ;
		 				AND AI_Prog.Tc_ID = a.TC_ID) ;
		INTO CURSOR tTemp1a
	ELSE
		SELECT DIST c.Con_ID AS Contract, ;
         a.Program, ;
			CalcAge(MIN(a.Start_Dt),g.Dob) AS Age, ;
         a.Tc_ID, ;
         MIN(a.Start_Dt) as Start_Dt, ;
         g.Dob, ;
         g.Sex, ;
			g.Gender, h.Gender AS TransSex, ;
			g.hispanic, g.white, g.blafrican, g.asian, g.hawaisland, g.indialaska, g.someother, g.unknowrep, ;
			SPACE(18) AS RACE ;
		FROM Ai_Prog A, ;
			Program B, ;
			Contract C, ;
			Ai_Site D, ;
			Site E, ;
			Ai_Clien F, ;
			Client G, ;
			Gender H ;
		WHERE c.Con_ID = cContract ;
			AND a.Program = b.Prog_ID ;
			AND b.Prog_ID = c.Program ;
			AND a.Start_Dt <= dDate_To ;
			AND (EMPTY(a.End_dt) OR a.End_dt>=dDate_From) ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND a.Tc_ID = f.Tc_ID ;
			AND f.Client_ID = g.Client_ID ;
			AND g.Gender = h.Code ;
		INTO CURSOR tTemp1a ;
      GROUP BY 4, 2, 1, 6,7,8,9,10,11,12,13,14,15,16,17,18
      *a.tc_id, a.program 
      
	ENDIF		

* ttemp1a now contains the basic cursor used to build both the race and the ethnicity cursors
* ttemp1b will be used for ethnicity
SELECT * FROM ttemp1a INTO cursor ttemp1b

**** race processing starts here
oApp.ReopenCur("ttemp1a", "ttemp1")
SELECT ttemp1
REPLACE ALL race WITH GetRace()

* 12/98, jss, as per MHRA, group by gender as follows: males and transgenders IDing as males, females and t.g.'s IDing as females
* Now, sum totals by contract and race 
SELECT Contract, Race, ;
		SUM(IIF(Age < 2 AND INLIST(Gender,'11','13'), 1, 0)) AS Age1m, ;
		SUM(IIF(Age < 2 AND INLIST(Gender,'10','12'), 1, 0)) AS Age1f, ;
		SUM(IIF(BETWEEN(Age,2,12)  AND INLIST(Gender,'11','13'), 1, 0)) AS Age2m, ;
		SUM(IIF(BETWEEN(Age,2,12)  AND INLIST(Gender,'10','12'), 1, 0)) AS Age2f, ;
		SUM(IIF(BETWEEN(Age,13,19) AND INLIST(Gender,'11','13'), 1, 0)) AS Age3m, ;
		SUM(IIF(BETWEEN(Age,13,19) AND INLIST(Gender,'10','12'), 1, 0)) AS Age3f, ;
		SUM(IIF(BETWEEN(Age,20,24) AND INLIST(Gender,'11','13'), 1, 0)) AS Age4m, ;
		SUM(IIF(BETWEEN(Age,20,24) AND INLIST(Gender,'10','12'), 1, 0)) AS Age4f, ;
		SUM(IIF(BETWEEN(Age,25,49) AND INLIST(Gender,'11','13'), 1, 0)) AS Age4am, ;
		SUM(IIF(BETWEEN(Age,25,49) AND INLIST(Gender,'10','12'), 1, 0)) AS Age4af, ;
		SUM(IIF(Age >= 50          AND INLIST(Gender,'11','13'), 1, 0)) AS Age5m, ;
		SUM(IIF(Age >= 50          AND INLIST(Gender,'10','12'), 1, 0)) AS Age5f, ;
		SUM(IIF(INLIST(Gender,'11','13'), 1, 0)) AS Age6m, ;
		SUM(IIF(INLIST(Gender,'10','12'), 1, 0)) AS Age6f, ;
		SUM(IIF(Gender='13', 1, 0)) AS Age7m, ;
		SUM(IIF(Gender='12', 1, 0)) AS Age7f ;
	FROM tTemp1 ;
	INTO CURSOR tTemp2 ;
	GROUP BY 1,2

* jss, 2/14/02, use race, not ethnic
SELECT DIST tTemp2.Contract, PADR(Race.code,18) AS race ;
	FROM tTemp2, Race ;
	INTO CURSOR tTemp3

cCursName = "tGrp" + STR(i,1) 	

* jss, 2/14/02, use race here
SELECT i AS nGroup, 'R' AS nType, tTemp2.*, PADR(Race.Descript,50) as descript ;
	FROM tTemp2, Race ;
	WHERE tTemp2.Race = Race.Code ;
UNION ;	
SELECT i AS nGroup,  'R' AS nType, Contract, Race, ;
		0 AS Age1m, 0 AS Age1f, ;
		0 AS Age2m, 0 AS Age2f, ;
		0 AS Age3m, 0 AS Age3f, ;
		0 AS Age4m, 0 AS Age4f, ;
		0 AS Age4am, 0 AS Age4af, ;
		0 AS Age5m, 0 AS Age5f, ;
		0 AS Age6m, 0 AS Age6f, ;
		0 AS Age7m, 0 AS Age7f, ;		
		PADR(Race.Descript,50) as descript ;
	FROM tTemp3, Race  ;
	WHERE tTemp3.Race = Race.Code ;
		AND NOT EXIST (SELECT * FROM tTemp2	;
				WHERE tTemp3.Contract = tTemp2.Contract ;
				AND tTemp3.Race = tTemp2.Race ) ;
INTO CURSOR &cCursName
**** race processing ends here 

**** ethnicity processing starts here
oApp.ReopenCur("ttemp1b", "ttemp1h")
SELECT ttemp1h
REPLACE ALL race WITH IIF(hispanic = 2, PADR('Hispanic',18),IIF(hispanic = 1, PADR('Non-Hispanic',18), 'Unknown'))

* Now, sum totals by contract and ethnicity (contained in field "race")
SELECT Contract, Race, ;
		SUM(IIF(Age=0 AND INLIST(Gender,'11','13'), 1, 0)) AS Age1m, ;
		SUM(IIF(Age=0 AND INLIST(Gender,'10','12'), 1, 0)) AS Age1f, ;
		SUM(IIF(BETWEEN(Age,1,12)  AND INLIST(Gender,'11','13'), 1, 0)) AS Age2m, ;
		SUM(IIF(BETWEEN(Age,1,12)  AND INLIST(Gender,'10','12'), 1, 0)) AS Age2f, ;
		SUM(IIF(BETWEEN(Age,13,19) AND INLIST(Gender,'11','13'), 1, 0)) AS Age3m, ;
		SUM(IIF(BETWEEN(Age,13,19) AND INLIST(Gender,'10','12'), 1, 0)) AS Age3f, ;
		SUM(IIF(BETWEEN(Age,20,24) AND INLIST(Gender,'11','13'), 1, 0)) AS Age4m, ;
		SUM(IIF(BETWEEN(Age,20,24) AND INLIST(Gender,'10','12'), 1, 0)) AS Age4f, ;
		SUM(IIF(BETWEEN(Age,25,49) AND INLIST(Gender,'11','13'), 1, 0)) AS Age4am, ;
		SUM(IIF(BETWEEN(Age,25,49) AND INLIST(Gender,'10','12'), 1, 0)) AS Age4af, ;
		SUM(IIF(Age >= 50          AND INLIST(Gender,'11','13'), 1, 0)) AS Age5m, ;
		SUM(IIF(Age >= 50          AND INLIST(Gender,'10','12'), 1, 0)) AS Age5f, ;
		SUM(IIF(INLIST(Gender,'11','13'), 1, 0)) AS Age6m, ;
		SUM(IIF(INLIST(Gender,'10','12'), 1, 0)) AS Age6f, ;
		SUM(IIF(Gender='13', 1, 0)) AS Age7m, ;
		SUM(IIF(Gender='12', 1, 0)) AS Age7f ;
	FROM tTemp1h ;
	INTO CURSOR tTemp2h ;
	GROUP BY 1,2

SELECT DIST tTemp2h.Contract, PADR('Hispanic',18) AS race ;
	FROM tTemp2h ;
UNION ;
SELECT DIST tTemp2h.Contract, PADR('Non-Hispanic',18) AS race ;
	FROM tTemp2h ;
UNION ;
SELECT DIST tTemp2h.Contract, PADR('Unknown',18) AS race ;
	FROM tTemp2h ;
INTO CURSOR tTemp3h

cCursName = "tGrph" + STR(i,1) 	

SELECT i AS nGroup, 'H' AS nType, tTemp2h.*, PADR(race,50)  AS descript ;
	FROM tTemp2h ;
UNION ;	
SELECT i AS nGroup,  'H' AS nType, Contract, Race, ;
		0 AS Age1m, 0 AS Age1f, ;
		0 AS Age2m, 0 AS Age2f, ;
		0 AS Age3m, 0 AS Age3f, ;
		0 AS Age4m, 0 AS Age4f, ;
		0 AS Age4am, 0 AS Age4af, ;
		0 AS Age5m, 0 AS Age5f, ;
		0 AS Age6m, 0 AS Age6f, ;
		0 AS Age7m, 0 AS Age7f, ;		
		PADR(Race,50) AS Descript ;
	FROM tTemp3h  ;
	WHERE NOT EXIST (SELECT * FROM tTemp2h	;
				WHERE tTemp3h.Contract = tTemp2h.Contract ;
				AND tTemp3h.Race = tTemp2h.Race ) ;
INTO CURSOR &cCursName
**** ethnicity processing ends here 

NEXT	

* if we don't have any information for the current month 
* we still should print the Table III -C: filled in with the zeroes

SELECT * ;
	FROM tGrp2 ;
	WHERE .F. ;
UNION ;
SELECT 1 AS nGroup, 'R' as nType, Contract, Race, ;
		0 AS Age1m, 0 AS Age1f, ;
		0 AS Age2m, 0 AS Age2f, ;
		0 AS Age3m, 0 AS Age3f, ;
		0 AS Age4m, 0 AS Age4f, ;
		0 AS Age4am, 0 AS Age4af, ;
		0 AS Age5m, 0 AS Age5f, ;
		0 AS Age6m, 0 AS Age6f, ;
		0 AS Age7m, 0 AS Age7f, ;
		Descript ;
	FROM tGrp2 ;
	WHERE NOT EXIST (SELECT * FROM tGrp1 WHERE tGrp2.Contract = tGrp1.Contract) ;	
	INTO CURSOR tMissed	

SELECT * ;
	FROM tGrph2 ;
	WHERE .F. ;
UNION ;
SELECT 1 AS nGroup, 'H' as nType, Contract, Race, ;
		0 AS Age1m, 0 AS Age1f, ;
		0 AS Age2m, 0 AS Age2f, ;
		0 AS Age3m, 0 AS Age3f, ;
		0 AS Age4m, 0 AS Age4f, ;
		0 AS Age4am, 0 AS Age4af, ;
		0 AS Age5m, 0 AS Age5f, ;
		0 AS Age6m, 0 AS Age6f, ;
		0 AS Age7m, 0 AS Age7f, ;
		Descript ;
	FROM tGrph2 ;
	WHERE NOT EXIST (SELECT * FROM tGrph1 WHERE tGrph2.Contract = tGrph1.Contract) ;	
	INTO CURSOR tMissedh	

SELECT tGrp2.*, ContrInf.Descript AS ContrDes ;
	FROM tGrp2, ContrInf ;
	WHERE tGrp2.Contract = ContrInf.Cid ;
UNION ;
SELECT tGrp1.*, ContrInf.Descript AS ContrDes ;
	FROM tGrp1, ContrInf ;
	WHERE tGrp1.Contract = ContrInf.Cid ;
UNION ;	
SELECT tMissed.*, Contrinf.Descript AS ContrDes ;
	FROM tMissed, ContrInf ;	
	WHERE tMissed.Contract = ContrInf.Cid ;	
UNION ;
SELECT tGrph2.*, ContrInf.Descript AS ContrDes ;
	FROM tGrph2, ContrInf ;
	WHERE tGrph2.Contract = ContrInf.Cid ;
UNION ;
SELECT tGrph1.*, ContrInf.Descript AS ContrDes ;
	FROM tGrph1, ContrInf ;
	WHERE tGrph1.Contract = ContrInf.Cid ;
UNION ;	
SELECT tMissedh.*, Contrinf.Descript AS ContrDes ;
	FROM tMissedh, ContrInf ;	
	WHERE tMissedh.Contract = ContrInf.Cid ;	
	INTO CURSOR tFinal 
     
   Select tFinal.*, ;
          cMonthYear as cMonthYear, ;
          cDate  as cDate, ;
          cTime  as cTime, ;
          cAgc_Name as cAgc_Name ;      
   From tFinal ;
   Into Cursor Final ;
	ORDER BY 3, 1, 2, 4
* make sure there are clients to report on
oApp.Msg2User('OFF')
GO TOP
IF EOF()
   IF eMPR
      =NullElec()
   ELSE   
          oApp.Msg2user('NOTFOUNDG')
          If Used('final')
              Use in final
          Endif   
          Select ;
                    ContrInf.Descript   AS ContrDes   ,;
                    'Section III: Monthly Program Report' as nulrptname ,;
                    'Table IV - F: Demographics of New Clients by Age and Race/Ethnicity' as nulrptnam1 ,;
                    'Table IV - F1: Demographics for Total YTD Enrollment by Age and Race/Ethnicity' as nulrptnam2 ,;
                    '' as nulrptnam3 ,;
                    '' as nulrptnam4,  ;
                    'Ryan White Comprehensive AIDS Resource Emergency Act, Title I' as cType, ;
                    cMonthYear as cMonthYear, ;
                    cDate  as cDate, ;
                    cTime  as cTime, ;
                    cAgc_Name as cAgc_Name ;
          From ContrInf ;
          Where ContrInf.Cid = cContract ;       
          Into Cursor final     
          
             gcRptName = 'rpt_null'
             DO CASE
                CASE lPrev = .f.
                     Report Form rpt_null  To Printer Prompt Noconsole NODIALOG 
                CASE lPrev = .t.    
                        oApp.rpt_print(5, .t., 1, 'rpt_null', 1, 2)
             Endcase
   Endif       
Else
   IF eMPR
      =Electronic()
   ELSE

          gcRptName = 'rpt_mhra_dem' 
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_dem  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_dem', 1, 2)
          Endcase
  Endif        
EndIf
****************************************
Function clean_data

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp1a")
	USE IN ("tTemp1a")
ENDIF

IF USED("tTemp1h")
	USE IN ("tTemp1h")
ENDIF

IF USED("tTemp1b")
	USE IN ("tTemp1b")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("tTemp3")
	USE IN ("tTemp3")
ENDIF

IF USED("tTemp2h")
	USE IN ("tTemp2h")
ENDIF

IF USED("tTemp3h")
	USE IN ("tTemp3h")
ENDIF

IF USED("tGrp1")
	USE IN ("tGrp1")
ENDIF

IF USED("tGrp2")
	USE IN ("tGrp2")
ENDIF

IF USED("tGrph1")
	USE IN ("tGrph1")
ENDIF

IF USED("tGrph2")
	USE IN ("tGrph2")
ENDIF

IF USED("tMissed")
	USE IN ("tMissed")
ENDIF

IF USED("tMissedh")
	USE IN ("tMissedh")
ENDIF

IF USED("tFinal")
	USE IN ("tFinal")
ENDIF

RETURN

****************
FUNCTION CalcAge
****************
PARAMETERS tdDt2Calc2, tdDOB
PRIVATE ALL LIKE j*
m.jcOldDate=SET("date")
SET DATE AMERICAN
m.jnAge=YEAR(m.tdDt2Calc2)-YEAR(m.tdDOB)-;
        IIF(CTOD(LEFT(DTOC(m.tdDOB),6)+STR(YEAR(m.tdDt2Calc2)))>m.tdDt2Calc2,1,0)
SET DATE &jcOldDate
RETURN m.jnAge

****************
FUNCTION GetRace
****************
tRace=SPACE(2)
DO CASE
	CASE white=1 AND ( blafrican=1 OR  asian=1 OR  hawaisland=1 OR  indialaska=1)
		tRace='60'
	CASE blafrican=1 AND ( asian=1 OR  hawaisland=1 OR  indialaska=1)
		tRace='60'
	CASE  asian=1 AND ( hawaisland=1 OR  indialaska=1)
		tRace='60'
	CASE  hawaisland=1 AND  indialaska=1
		tRace='60'
	CASE  white=1 
		tRace='10'
	CASE  blafrican=1 
		tRace='20'
	CASE  asian=1 
		tRace='30'
	CASE  hawaisland=1 
		tRace='40'
	CASE  indialaska=1 
		tRace='50'
	CASE  someother=1 
		tRace='70'	
	CASE  unknowrep=1 
		tRace='90'
ENDCASE

RETURN tRace	

*******************
FUNCTION Electronic
*******************
* jss, 5/13/04, add code here to write to electronic mpr table (mprivf12)

SELECT 0
USE mprivf12 EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

* now, roll thru tfinal, writing 1 Electronic MPR record per tfinal record, plus a totals record on each break
SELECT tFinal
GO TOP

sav_group=ngroup
sav_type =ntype

* initialize totals counters
STORE 0 TO tAge1m, tAge1f, tAge2m, tAge2f, tAge3m, tAge3f, tAge4m, tAge4f, tAge4am, tAge4af, tAge5m, tAge5f, tAge6m, tAge6f, tAge7m, tAge7f 

SCAN
	IF (sav_group <> tfinal.nGroup) OR (sav_type <> tfinal.ntype)
		=TypeBreak()
	ENDIF
	
* define memvars
	m.periodtype=IIF(tFinal.ngroup=1,'Monthly','YTD')
	m.detailtype=IIF(tFinal.ntype='H','Ethnicity','Race')
	m.detaildesc=tFinal.Descript
	m.Age1m=tFinal.Age1m
	m.Age1f=tFinal.Age1f
	m.Age2m=tFinal.Age2m
	m.Age2f=tFinal.Age2f
	m.Age3m=tFinal.Age3m
	m.Age3f=tFinal.Age3f
	m.Age4m=tFinal.Age4m
	m.Age4f=tFinal.Age4f
	m.Age4am=tFinal.Age4am
	m.Age4af=tFinal.Age4af
	m.Age5m=tFinal.Age5m
	m.Age5f=tFinal.Age5f
	m.Age6m=tFinal.Age6m
	m.Age6f=tFinal.Age6f
	m.Age7m=tFinal.Age7m
	m.Age7f=tFinal.Age7f

	SELECT mprivf12
	APPEND BLANK
	GATHER MEMVAR
	
* add to totals
	tAge1m = tAge1m + tFinal.Age1m
	tAge1f = tAge1f + tFinal.Age1f
	tAge2m = tAge2m + tFinal.Age2m
	tAge2f = tAge2f + tFinal.Age2f
	tAge3m = tAge3m + tFinal.Age3m
	tAge3f = tAge3f + tFinal.Age3f
	tAge4m = tAge4m + tFinal.Age4m
	tAge4f = tAge4f + tFinal.Age4f
	tAge4am = tAge4am + tFinal.Age4am
	tAge4af = tAge4af + tFinal.Age4af
	tAge5m = tAge5m + tFinal.Age5m
	tAge5f = tAge5f + tFinal.Age5f
	tAge6m = tAge6m + tFinal.Age6m
	tAge6f = tAge6f + tFinal.Age6f
	tAge7m = tAge7m + tFinal.Age7m
	tAge7f = tAge7f + tFinal.Age7f
	
	SELECT tFinal
ENDSCAN

=TypeBreak()

USE IN mprivf12

SELECT tFinal
GO TOP
RETURN

******************
FUNCTION typebreak
******************
* when type changes, create a total line, then reinitialize counters, hold area

m.periodtype=IIF(sav_group=1,'Monthly','YTD')
m.detailtype=IIF(sav_type='H','Ethnicity', 'Race')
m.detaildesc='Totals'
m.Age1m=tAge1m
m.Age1f=tAge1f
m.Age2m=tAge2m
m.Age2f=tAge2f
m.Age3m=tAge3m
m.Age3f=tAge3f
m.Age4m=tAge4m
m.Age4f=tAge4f
m.Age4am=tAge4am
m.Age4af=tAge4af
m.Age5m=tAge5m
m.Age5f=tAge5f
m.Age6m=tAge6m
m.Age6f=tAge6f
m.Age7m=tAge7m
m.Age7f=tAge7f

SELECT mprivf12
APPEND BLANK
GATHER MEMVAR

STORE 0 TO tAge1m, tAge1f, tAge2m, tAge2f, tAge3m, tAge3f, tAge4m, tAge4f, tAge4am, tAge4af, tAge5m, tAge5f, tAge6m, tAge6f, tAge7m, tAge7f 
sav_type=tfinal.ntype
sav_group=tfinal.ngroup

RETURN

*****************
FUNCTION NullElec
*****************
* jss, 8/6/04, no data found, still produce shell record
m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

SELECT 0
USE mprivf12 EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mprivf12
RETURN
