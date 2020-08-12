Parameters lPrev,  ;
            cContract, ;
            cCsite, ;
            date_from, ;
            date_to 

PRIVATE gcHelp
cDate = DATE()
cTime = TIME()
cAgency_id = " "
cAgc_Name = " "

IF !GetCliLst()
   oApp.msg2user('Off')
   oApp.msg2user('NOTFOUNDG')
   Return
EndIf
*  Program...........: Summary of Client Enrollment and Caseload
nyear= YEAR(date_from)
nmon = MONTH(date_from)
cMonthYear = Cmonth(date_from) + ", " + RIGHT(DTOC(date_from),4)

ddate_from = CTOD(STR(nmon)+ "/01/" + STR(nyear))
dDate_To = GOMONTH(ddate_from,1)-1

=clean_data()

SELECT ;
		start_dt AS ytd_from, ;
		program ;
FROM  ;
		contract ;
WHERE ;
		contract.con_id = cContract ;
INTO CURSOR ;
		ytdfrom		

m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(dDate_from),4)),ytdfrom.ytd_from)
* jss, 6/26/01, define cprog
cprog=ytdfrom.program

FOR i = 1 TO 2
* use contract start date for YTD numbers
	dDate_From = IIF(i = 1, dDate_from, m.ytd_from)

*  code to grab only the Prev contract's program (cprog)
	SELECT a.*, ;
   		.T. AS New, ;
   		.F. AS Reopened, ;
   		.F. AS Returned ;
 	FROM ;
 		Ai_Prog A, ;
 		Program B ;
	WHERE a.Program = cprog ;
	AND a.Program = b.Prog_ID ;
	AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
	AND !EXISTS (SELECT * FROM Ai_Prog ;
				WHERE Ai_Prog.Program = A.Program ;
				AND !EMPTY(Ai_Prog.End_Dt) ;
				AND AI_Prog.End_Dt <= a.Start_Dt ;
				AND AI_Prog.Tc_ID = a.TC_ID) ;
	INTO CURSOR tNew		 							

	SELECT a.*, ;
   		.F. AS New, ;
   		.T. AS Reopened, ;
   		.F. AS Returned ;
 	FROM ;
 		Ai_Prog A, ;
 		Program B ;
	WHERE  a.Program = cprog ;
	AND a.Program = b.Prog_ID ;
	AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
	AND EXISTS (SELECT * FROM Ai_Prog ;
				WHERE Ai_PROG.Program = A.Program ;
				AND !EMPTY(Ai_Prog.End_Dt) ;		 						
				AND AI_PROG.End_Dt <= a.Start_Dt ;
				AND AI_PROG.Tc_ID = a.TC_ID) ;
    INTO CURSOR tReop
   		 							
	SELECT a.*, ;
   		.F. AS New, ;
   		.F. AS Reopened, ;
   		.T. AS Returned ;
 	FROM ;
 		Ai_Prog A, ;
 		Program B ;
	WHERE  a.Program = cprog ;
	AND a.Program = b.Prog_ID ;
	AND a.Start_Dt < dDate_From ;
	AND (EMPTY(a.End_Dt) ;
			OR (!EMPTY(a.End_Dt) AND a.End_Dt >= dDate_From)) ;
	INTO CURSOR tRetu


* tAi_Prog will necessarily contain duplicate tc_ids, since reopens have a start date in the period
* and there exists a closed record for the tc_id prior to the reopened start date
* therefore, we may use tai_prog cursor only for gross counts, not unduplicated counts
	SELECT * ;
	FROM ;
		tNew ;
	UNION ;
	SELECT * ;
	FROM ;
		tReop ;
	UNION ;
	SELECT * ;
	FROM ;
		tRetu ;
	INTO CURSOR ;
		tAi_Prog
	
	SELECT ;
		DIST a.Program, f.Client_ID, ;
		a.Tc_ID, a.Start_Dt, a.End_Dt, a.New, a.Reopened, a.Returned, a.reason ;
	FROM ;
		tAi_Prog A, ;
		Ai_Site D, ;
		Site E, ;
		Ai_Clien F, ;
		Client G ;
	WHERE ;
		a.Program = cprog ;
	AND a.Tc_ID = d.Tc_ID ;
	AND e.Site_ID = d.Site ;
	AND e.Site_ID = cCSite ;
	AND e.Agency_ID = cAgency_ID ;
	AND a.Tc_ID = f.Tc_ID ;
	AND f.Client_ID = g.Client_ID ;
	INTO CURSOR ;
		tTemp1 

* tai_prog1a cursor will contain distinct tc_ids only (ignores reopens, dealt with just below)
	SELECT * ;
	FROM ;
		tNew ;
	UNION ;
	SELECT * ;
	FROM ;
		tRetu ;
	INTO CURSOR ;
		tAi_Prog1a
	
* jss, 7/12/99, add next select to include reopens that were closed at period start (i.e., not a subset of returns)
  	SELECT * FROM tAi_Prog1a	;
  	UNION ;
  	SELECT * FROM tReop ;
  		WHERE tReop.tc_id+tReop.Program ;
  			NOT IN (SELECT tc_id+program FROM tAi_Prog1a) ;
   	INTO CURSOR tAi_Prog1b 			
	
	SELECT DIST a.Program, f.Client_ID, ;
			a.Tc_ID, a.New  ;
	FROM tAi_Prog1b A, ;
			Ai_Site D, ;
			Site E, ;
			Ai_Clien F, ;
			Client G ;
	WHERE  a.Program = cprog ;
	AND a.Tc_ID = d.Tc_ID ;
	AND e.Site_ID = d.Site ;
	AND e.Site_ID = cCSite ;
	AND e.Agency_ID = cAgency_ID ;
	AND a.Tc_ID = f.Tc_ID ;
	AND f.Client_ID = g.Client_ID ;
	INTO CURSOR tTemp1a 

* jss, 6/99, add if statement below to handle UNDUPLICATED YTD client enrollment (defined as
*            all distinct clients who are active at some point in period)	
	IF i=2
		 SELECT ;
		 	COUNT(DIST tc_id) AS ytd_undup ;
		 FROM ;
		 	ttemp1a ;
		 INTO CURSOR ytdundup 
    ENDIF

* Statistics
* jss, 6/26/01, use program, not contract, in all following cursors
	cCursName = "tStatist" + STR(i,1) 			
	SELECT ;
		tTemp1.program, ;
		SUM(IIF(Returned, 1, 0)) AS BeginCnt, ;
		SUM(IIF(New, 1, 0)) 		 AS NewCnt, ;
		SUM(IIF(Reopened, 1, 0)) AS ReopCnt, ;
		SUM(IIF(Returned, 1, 0)) AS ReturCnt, ;		
		SUM(IIF(BETWEEN(End_Dt, dDate_From, dDate_To), 1, 0)) AS CloseInPer ;		
	FROM tTemp1 ;
	INTO CURSOR &cCursName ;
	GROUP BY 1

	IF i = 1
		* Clients Served this month
	 	SELECT ;
			DIST tTemp1.Program, tTemp1.Tc_ID, ;
			tTemp1.New, tTemp1.Reopened, tTemp1.Returned ;
	 	FROM ;
	 		tTemp1, ;
		 	Ai_Enc, ;
   		Ai_Serv ;
	 	WHERE ;
	 		tTemp1.Program = Ai_Enc.Program ;
	 		AND tTemp1.Tc_ID = Ai_Enc.Tc_ID ; 
	 		AND Ai_Enc.Act_ID = Ai_Serv.Act_ID ;
	    	AND Ai_Enc.Act_Dt BETWEEN dDate_From AND dDate_To ;
 		INTO CURSOR tServed	
 		
	 	SELECT ;
			Program, ;
			SUM(IIF(New, 1, 0))      AS NewCnt, ;
			SUM(IIF(Reopened, 1, 0)) AS ReopCnt, ;
			SUM(IIF(Returned, 1, 0)) AS ReturCnt ;		
	 	FROM tServed ;
	 	INTO CURSOR tServed1 ;
	 	GROUP BY 1

* jss, 6/26/01, modify code below (determining reasons and their counts) as follows: look up 
*               program enrollment closed reasons first in prg_clos.dbf (can only do this if 
*               a reason is specified in ai_prog). then, go to agency closure reasons (closcode.dbf)
* first, grab all the closed records found in ttemp1
	 	SELECT ;
	    	program, ;
			tc_id, ;
			end_dt, ;
			reason  ;
		FROM ;
			ttemp1 ;
		WHERE ;
			BETWEEN(tTemp1.End_Dt, dDate_From, dDate_To) ;
		INTO CURSOR ;
			closinper	
	EndIf	
NEXT	

* should be selecting ytd version of ttemp1 here to ensure production of report to show ytd #'s 
* even if no current month numbers in system
SELECT ;
   	cProg	 AS program, ;
	   Descript AS ContrDes, ;
      cMonthYear as cMonthYear, ;
      cDate  as cDate, ;
      cTime  as cTime, ;
      cAgc_Name as cAgc_Name ;  
FROM ;
	   ContrInf ;
WHERE ;
	   cContract = ContrInf.Cid ;
INTO CURSOR Final

SELECT tServed1
INDEX ON Program TAG Program
SELECT tStatist1
INDEX ON Program TAG Program
SELECT tStatist2
INDEX ON Program TAG Program

SELECT Final
SET RELATION TO Program INTO tServed1
SET RELATION TO Program INTO tStatist1 ADDITIVE
SET RELATION TO Program INTO tStatist2 ADDITIVE
* make sure there are clients to report on
oApp.Msg2User('OFF')
GO TOP
IF EOF()
       oApp.Msg2user('NOTFOUNDG')
       If Used('final')
           Use in final
       Endif   
       Select ;
                 ContrInf.Descript   AS ContrDes   ,;
                 'Section IV: Monthly Program Report' as nulrptname ,;
                 'IV - A1: Summary of Client Enrollment and Caseload' as nulrptnam1 ,;
                 '' as nulrptnam2 ,;
                 '' as nulrptnam3 ,;
                 '' as nulrptnam4,  ;
                 'Multi-Module HIV Prev. Services Program' as cType, ;
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
          ENDCASE
Else
          gcRptName = 'rpt_prev_cl'
          
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_prev_cl  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_prev_cl', 1, 2)
          ENDCASE
ENDIF

**************************
Function clean_data

If Used('ytdfrom')
   Use in ytdfrom
EndIf
IF USED("tNew")
   USE IN ("tNew")
EndIf

IF USED("tReop")
   USE IN ("tReop")
EndIf

IF USED("tRetu")
   USE IN ("tRetu")
EndIf

IF USED("closinper")
   USE IN ("closinper")
EndIf

IF USED("ytdundup")
   USE IN ("ytdundup")
EndIf

IF USED("tAi_Prog")
   USE IN ("tAi_Prog")
EndIf
  
IF USED("tAi_Prog1a")
   USE IN ("tAi_Prog1a")
EndIf

IF USED("tAi_Prog1b")
   USE IN ("tAi_Prog1b")
EndIf

IF USED("tTemp1a")
   USE IN ("tTemp1a")
EndIf

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("tStatist1")
	USE IN ("tStatist1")
ENDIF

IF USED("tStatist2")
	USE IN ("tStatist2")
ENDIF

IF USED("tServed")
	USE IN ("tServed")
ENDIF

IF USED("tServed1")
	USE IN ("tServed1")
ENDIF

IF USED("tReasons")
	USE IN ("tReasons")
ENDIF

IF USED("tReasons1")
	USE IN ("tReasons1")
ENDIF

IF USED("Final")
   USE IN ("Final")
EndIf
RETURN
**********************************************************************
PROCEDURE GetCliLst
**********************************************************************
*** Get the site and agency assignments, apply user selections if any
cOldArea = ALIAS()
=OPENFILE("Agency","Agency")
cAgency_ID = AllTrim(Agency.agency)
cAgc_Name = Agency.descript1

IF !EMPTY(cOldArea)
   SELECT (cOldArea)
ENDIF
RETURN .t.

