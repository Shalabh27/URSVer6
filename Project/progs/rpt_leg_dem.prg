Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              ParamCrit, ;          && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

lcProgx   = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

=clean_data()
* jss, 4/20/04, legal services module: client demographics report
PRIVATE gchelp
gchelp = "Legal Services Client Demographics Report Screen"


* clients with active cases at the start of the period
If Used('ActBeg')
   Use in ActBeg
Endif   

SELECT DISTINCT;
	tc_id  ;
FROM ;
	ai_enc ;
WHERE ;
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	act_dt < date_from AND ;
	(caseclosdt >= date_from OR ;
	 EMPTY(caseclosdt)) ;	
GROUP BY ;
	tc_id ;
INTO CURSOR ActBeg

If Used('EnrInPer')
   Use in EnrInPer
Endif   
* clients enrolled in a case this period
SELECT DISTINCT;
	tc_id  ;
FROM ;
	ai_enc ;
WHERE ;
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	act_dt >= date_from AND ;
	act_dt <= date_to	;
GROUP BY ;
	tc_id ;
INTO CURSOR EnrInPer

* clients NEWLY enrolled in a case in period
If Used('NewEnr')
   Use in NewEnr
Endif   

SELECT DISTINCT;
	tc_id ;
FROM ;
	EnrInPer ;
WHERE ;
	tc_id NOT IN (SELECT tc_id FROM ActBeg) ;
INTO CURSOR ;
	NewEnr1    &&**VT 11/05/2009 Dev Tick 5577 changed from NewEnr to NewEnr1


**VT 07/27/2011 AIRS-133
**VT 11/05/2009 Dev Tick 5577 Check if client is newly enrolled in the program
*!*	SELECT ;
*!*	   distinct ai_enc.tc_id  ;
*!*	FROM ;
*!*	ai_enc ;
*!*	      Inner Join NewEnr1 On ;
*!*	         ai_enc.tc_id = NewEnr1.tc_id ;
*!*	      Inner Join ai_prog on;
*!*	       ai_prog.tc_id = ai_enc.tc_id ;
*!*	   And ai_enc.program = ai_prog.program ;     
*!*	WHERE ;
*!*	ai_enc.serv_cat = '00021' AND ;
*!*	ai_enc.program = lcprogx  AND ;
*!*	ai_enc.act_dt >= date_from AND ;
*!*	ai_enc.act_dt <= date_to   ;
*!*	 and ai_enc.tc_id + ai_enc.program Not In ;
*!*	               (SELECT ai_prog.tc_id + ai_prog.program ;
*!*	                  FROM ai_prog ;
*!*	                  WHERE ;
*!*	                     ai_prog.start_dt < date_from ;
*!*	                  GROUP BY ;
*!*	                     ai_prog.tc_id, ai_prog.program) ;
*!*	GROUP BY ;
*!*	ai_enc.tc_id ;
*!*	INTO CURSOR ;
*!*	NewEnr
   
** GOxford 03/28/2012 AIRS-133
** Removed WHERE condition:
**  and (caseclosdt < from_dt OR ;
**	 EMPTY(caseclosdt)) ;
** (It was causing the SELECT to miss any new clients whose case(s) ended within the time period)

*!*	 SELECT ;
*!*	      Distinct ai_enc.tc_id  ;
*!*	FROM ;
*!*	   ai_enc ;
*!*	      Inner Join NewEnr1 On ;
*!*	         ai_enc.tc_id = NewEnr1.tc_id ;
*!*	WHERE ;
*!*	  ai_enc.serv_cat = '00021' AND ;
*!*	  ai_enc.program = lcprogx  AND ;
*!*	  ai_enc.act_dt >= Date_from AND ;
*!*	  ai_enc.act_dt <= Date_to   ;
*!*	  and (caseclosdt < Date_from OR ;
*!*		 EMPTY(caseclosdt)) ;
*!*	GROUP BY ;
*!*	   ai_enc.tc_id ;
*!*	INTO CURSOR ;
*!*	   NewEnr

 SELECT ;
      Distinct ai_enc.tc_id  ;
FROM ;
   ai_enc ;
      Inner Join NewEnr1 On ;
         ai_enc.tc_id = NewEnr1.tc_id ;
WHERE ;
  ai_enc.serv_cat = '00021' AND ;
  ai_enc.program = lcprogx  AND ;
  ai_enc.act_dt >= Date_from AND ;
  ai_enc.act_dt <= Date_to   ;
GROUP BY ;
   ai_enc.tc_id ;
INTO CURSOR ;
   NewEnr
**VT END     
** GOxford END
   
* if no new clients, get out
IF EOF('NewEnr')
	oApp.MSG2USER('NOTFOUNDG')
   oApp.msg2user('OFF')
	IF USED('AI_ENC')
		USE IN AI_ENC
	ENDIF
	IF USED('ACTBEG')
		USE IN ACTBEG
	ENDIF
	IF USED('ENRINPER')
		USE IN ENRINPER
	ENDIF
	IF USED('NEWENR')
		USE IN NEWENR
	ENDIF
	
   **VT 11/95/2009 Dev Tick 5577
   IF USED('NEWENR1')
      USE IN NEWENR1
   Endif
   
	RETURN
ENDIF

* now, we will count the new clients by their age, sex, ethnicity, so get dob, gender, race info

If Used('tNewCli')
   Use in tNewCli
Endif   

If Used('NewCli')
   Use in NewCli
Endif 

*!*   SELECT DISTINCT ;
*!*   	aicl.Tc_id, ;
*!*   	Space(18) as Race, ;
*!*      Space(45) as RaceDesc, ;
*!*   	cl.gender, ;
*!*   	Space(18) as GenderDesc, ;
*!*   	cl.White, ;
*!*   	cl.Blafrican, ;
*!*   	cl.Asian, ;
*!*   	cl.Hawaisland, ;
*!*   	cl.Indialaska, ;
*!*   	cl.Unknowrep, ;
*!*   	cl.Someother, ;
*!*   	cl.Hispanic, ;
*!*   	cl.Dob ;
*!*   FROM ;
*!*   	client cl, ai_clien aicl;
*!*   WHERE ;
*!*   	aicl.tc_id IN (SELECT tc_id FROM NewEnr) AND ;
*!*   	aicl.client_id = cl.client_id ;
*!*   INTO CURSOR ;
*!*   	tNewCli
*!*   oApp.ReopenCur("tNewCli","NewCli")

SELECT DISTINCT ;
   aicl.Tc_id, ;
   Space(18) as Race, ;
   Space(45) as RaceDesc, ;
   ICase(cl.gender='10','10',;
         cl.gender='11','11', ;
         InList(cl.gender,'12','13','15','16'),'12',;
         InList(cl.gender,'14','17','18','19'),'14',;
         '14') As gender,;
   ICase(cl.gender='10','Woman/Girl ',;
         cl.gender='11','Man/Boy    ', ;
         InList(cl.gender,'12','13','15','16'),'Transgender',;
         InList(cl.gender,'14','17','18','19'),'Unknown    ',;
         'Unknown    ') As GenderDesc ,;
   cl.White, ;
   cl.Blafrican, ;
   cl.Asian, ;
   cl.Hawaisland, ;
   cl.Indialaska, ;
   cl.Unknowrep, ;
   cl.Someother, ;
   cl.Hispanic, ;
   cl.Dob ;
FROM ;
   client cl, ai_clien aicl;
WHERE ;
   aicl.tc_id IN (SELECT tc_id FROM NewEnr) AND ;
   aicl.client_id = cl.client_id ;
INTO CURSOR NewCli ReadWrite

   
SELECT NewCli
Go top
REPLACE race WITH GetRace() all	
*!*   Go top
*!*   REPLACE genderdesc WITH GetGenDesc() all
Go top
Replace racedesc with IIF(!Empty(NewCli.race),GETDESC('RACE','LEFT(NewCli.race,2)','CODE','DESCRIPT'), "NOT Entered") all

If Used('Hispanic')
   Use in Hispanic
Endif   

* hispanic
SELECT ;
	"Hispanic    " as Hispanic, ;
	Race, ;
	Genderdesc, ;
   racedesc, ;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND oApp.Age(date_to,dob) >= 70,1,0)) 				AS Age70plus ,;
	SUM(IIF(Empty(dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS total ;
FROM ;
	NewCli ;
WHERE ;
	hispanic = 2 ;
GROUP BY ;
	1, 2, 3, 4 ;
INTO CURSOR ;
	Hispanic

* non-hispanic
If Used('NonHisp')
   Use in NonHisp
Endif 

SELECT ;
	"Non-Hispanic" as Hispanic, ;
	Race, ;
	Genderdesc, ;
   racedesc, ;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND oApp.Age(date_to,dob) >= 70,1,0)) 				AS Age70plus ,;
	SUM(IIF(Empty(dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS total ;
FROM ;
	NewCli ;
WHERE ;
	hispanic = 1 ;
GROUP BY ;
	1, 2, 3, 4 ;
INTO CURSOR ;
	NonHisp

If Used('NotEnter')
   Use in NotEnter
Endif 

SELECT "Not Entered " as hispanic, ;
	Race, ;
	Genderdesc, ;
   racedesc, ;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(!Empty(dob) AND BETWEEN(oApp.Age(date_to,dob),60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND oApp.Age(date_to,dob) >= 70,1,0)) 				AS Age70plus ,;
	SUM(IIF(Empty(dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS total ;
FROM ;
	NewCli ;
WHERE ;
	hispanic <> 1 and hispanic <> 2 ;
GROUP BY ;
	1, 2, 3, 4 ;
INTO CURSOR ;
	NotEnter

* now, combine them all into the final report cursor
If Used('Age_Race')
   Use in Age_Race
Endif 

Select hispanic.* , ;
       ParamCrit as  Crit, ;   
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from as Date_from, ;
       date_to as date_to;       
from hispanic ;
Union ;
Select nonhisp.*, ; 
       ParamCrit as  Crit, ;   
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from as Date_from, ;
       date_to as date_to;        
from nonhisp ;
Union ;
Select notenter.*, ;
       ParamCrit as  Crit, ;   
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from as Date_from, ;
       date_to as date_to;      
from notenter ;
Order by ;
	1, 2, 3 ;
Into cursor ;
	Age_Race

oApp.msg2user('OFF')
gcRptName = 'rpt_leg_dem'            
GO TOP
IF EOF()
     oApp.msg2user('NOTFOUNDG')
Else
     DO CASE
         CASE lPrev = .f.
              Report Form rpt_leg_dem To Printer Prompt Noconsole NODIALOG 
          CASE lPrev = .t.     &&Preview
              oApp.rpt_print(5, .t., 1, 'rpt_leg_dem', 1, 2)
     ENDCASE   
EndIf
*********************************************************
Function clean_data
* close files, get out
IF USED('AI_ENC')
	USE IN AI_ENC
ENDIF
IF USED('AI_SERV')
	USE IN AI_SERV
ENDIF
IF USED('ACTBEG')
	USE IN ACTBEG
ENDIF
IF USED('ENRINPER')
	USE IN ENRINPER
ENDIF
IF USED('NEWENR')
	USE IN NEWENR
ENDIF
IF USED('tNEWCLI')
	USE IN tNEWCLI
ENDIF
IF USED('NEWCLI')
	USE IN NEWCLI
ENDIF
IF USED('HISPANIC')
	USE IN HISPANIC
ENDIF
IF USED('NONHISP')
	USE IN NONHISP
ENDIF
IF USED('NOTENTER')
	USE IN NOTENTER
ENDIF
IF USED('AGE_RACE')
	USE IN AGE_RACE
ENDIF
RETURN
****************
FUNCTION GetRace
****************
tRace=SPACE(2)
DO CASE
	CASE (white + blafrican + asian + hawaisland + indialaska + someother) > 1 
		tRace='60'
	CASE white=1 
		tRace='10'
	CASE blafrican=1 
		tRace='20'
	CASE asian=1 
		tRace='30'
	CASE hawaisland=1 
		tRace='40'
	CASE indialaska=1 
		tRace='50'
	CASE  someother=1 
		tRace='70'	
	CASE unknowrep=1 
		tRace='90'
	OTHERWISE
		tRace='90'	
ENDCASE

RETURN tRace	

*******************
FUNCTION GetGenDesc
*******************
tGendesc=SPACE(15)

DO CASE
	CASE gender='10'
		tGendesc='Female'
	CASE gender='11'
		tGendesc='Male'
	CASE gender='12'
		tGendesc='TG-ID as Female'
	CASE gender='13'
		tGendesc='TG-ID as Male'
	Otherwise
		tGendesc='Gender Not Entered'	
ENDCASE

RETURN tGendesc		
*********************************************************
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
		
	