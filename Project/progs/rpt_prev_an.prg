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
*  Program.......: (Summary of Anonymous Services Provided during the Reporting Month)
nyear= YEAR(date_from)
nmon = MONTH(date_from)

cMonthYear = Cmonth(date_from) + ", " + RIGHT(DTOC(date_from),4)

ddate_from = CTOD(STR(nmon)+ "/01/" + STR(nyear))
dDate_To = GOMONTH(ddate_from,1)-1

=clean_data()

SELECT ;
		start_dt AS ytd_from;
FROM  ;
		contract ;
WHERE ;
		contract.con_id = cContract ;
INTO CURSOR ;
		ytdfrom		
	
m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(ddate_from),4)),ytdfrom.ytd_from)

FOR i = 1 TO 2
   * use contract start date for YTD numbers
	dDate_From = IIF(i = 1, ddate_from, m.ytd_from)
  * Part I
  * we're selecting the projected info
  
	SELECT	a.Contract, ;
				a.SerT, ;
				b.Descript, ;
  				b.SerUnit, ;
  				b.NofCl, ;
  				STR(SUM(a.nc)) AS nc_proj, ;
  				STR(SUM(a.ns)) AS ns_proj  ;
	FROM 		SerTag   A, ;
				SerType  B, ;
				Contract C  ;
 	WHERE 	a.Contract = cContract ;
  	AND      a.Contract = c.Con_id ;
  	AND 		a.Sert = b.Code ;
  	AND      b.unit_type='4' ;
  	AND 		BETWEEN(CTOD(SUBSTR(a.cm,2,2) + "/01/" + IIF(VAL(RIGHT(a.cm,2))<90, '20', '19') + RIGHT(a.cm,2)), ;
  	  										dDate_from, dDate_to) ;
  	AND 		a.nc + a.ns > 0 ;			  
	AND    	c.Start_dt <= dDate_From ;
  	AND    	c.End_dt   >= dDate_To ;
  	INTO CURSOR ;	
  				tTemp1 ;
  	GROUP BY 1, 2, 3, 4, 5

	SELECT 	a.Cid AS Contract, ;
  				c.SerT, ;
  				b.Descript, ;
  				b.SerUnit, ;
  				b.NofCl, ;
  				STR(0) AS nc_proj, ;
  				STR(0) AS ns_proj  ;
  	FROM 		ContrInf A, ;
  				SerType  B, ;
  				ConSer   C, ;
            Contract D  ;
   WHERE 	a.Cid = cContract ;
  	AND      a.Cid = D.Con_id ;
  	AND 		a.ConType = c.ConT ;
  	AND      b.unit_type='4' ;
  	AND 		b.Code = c.SerT ;
  	AND 		BETWEEN(dDate_from, cnStart_Dt, cnEnd_Dt) ;
	AND    	D.Start_dt <= dDate_From ;
  	AND    	D.End_dt   >= dDate_To ;
  	INTO CURSOR ;
  				tTemp2
  	
  	SELECT 	a.*, ;
  				b.Descript AS ContrDes ;
  	FROM 		tTemp1 A, ;
  				ContrInf B ;
  	WHERE 	a.Contract = b.Cid ;
  	UNION ;		
  	SELECT 	a.*, ;
  				b.Descript AS ContrDes ;
  	FROM 		tTemp2 A, ;
  				ContrInf B ;
  	WHERE 	a.Contract = b.Cid ;
  	AND 		Contract + SerT NOT IN ;
  					(SELECT Contract + SerT FROM tTemp1) ;
  	INTO CURSOR ;
  				tTemp3 ;
  	ORDER BY 1, 2 			

  * Part II
  * get all Prevention transactions for period
* jss, 7/11/03, add the new serv_cat's for prevention: TRAINING (00016), HCPI EDUCATION (00017)
*																			HCPI (00018), OTHER INTERVENTIONS (00019)  

* jss, 6/21/05, to correct a problem that was causing unpredictable results in next select:
* change (ai_outr.serv_cat='00015' or ai_outr.serv_cat='00018' or ai_outr.serv_cat='00018' or ai_outr.serv_cat='00018' or ai_outr.serv_cat='00019') to Inlist('00015', '00016', etc.)
 
	SELECT 	Contract.Con_id AS Contract, ;
  				ConSD.Ser_Type, ;
     			Ai_outr.Act_ID, ;
   			Ai_outr.Act_Dt, ;
   			Ai_outr.Serv_Cat, ;
   			Ai_outr.Enc_id, ;
   			Ai_outr.Total, ;
   			Ai_outr.Total_unkn, ;
   			ContrInf.Descript AS ContrDes ;
	FROM 		ConSd,    ;
   			Ai_outr,  ;
   			Program,  ;
   			Contract, ;
   			ContrInf  ;
	WHERE		ContrInf.Cid = cContract ;
	AND 		ConSD.Contract = Contract.Cid ;
	AND 		Contract.Con_ID = ContrInf.Cid ;
	AND   	Contract.Start_dt <= dDate_From ;
	AND   	Contract.End_dt   >= dDate_To ;
	AND 		ConSD.Enc_id = Ai_outr.Enc_id ;
	AND 		ConSD.Serv_Cat = Ai_outr.Serv_Cat ;
	And 	   INLIST(ai_outr.serv_cat,'00015','00016','00017','00018','00019') ;	
	AND 		Ai_outr.Program = Program.Prog_ID ;
	AND 		Ai_outr.Program = Contract.Program ;
  	AND 		BETWEEN(Ai_outr.Act_Dt,dDate_From,dDate_To) ;
  	INTO CURSOR ;
  				tTemp4	
				
	* count them by contract+ser_type
	SELECT 	Contract, ;
  				Ser_Type, ;
   			COUNT(*)   AS ns, ;
            SUM(Total+Total_Unkn) AS nc, ;
   			ContrDes ;
	FROM 		tTemp4    ;
	INTO CURSOR ;
				tTemp5 ;
	GROUP BY ;
				1, 2, 5			

* must now create an outer join to grab info for services projected in ttemp3 but not found this period in ttemp5
	SELECT 	a.Contract, ;
         	a.SerT AS Ser_type, ;
          	0000000000 			AS ns, ;
  		   	0000000000000000  AS nc, ;
  				c.Descript 			AS ContrDes ;
  	FROM 		tTemp3   A, ;
  				SerType  B, ;
  				ContrInf C  ;
  	WHERE 	a.SerT     = b.Code ;
  	AND      a.Contract = c.Cid  ;
  	AND 		Contract + SerT NOT IN (SELECT Contract + Ser_Type FROM tTemp5) ;
  	INTO CURSOR ;
  				tTemp6
  				
* now, complete the outer join
	SELECT 	* ;
	FROM ;
				tTemp5 ;
	UNION ;
	SELECT 	* ;
	FROM ;
				tTemp6 ;
	INTO CURSOR ;
				tTemp7
		
* so,  tTemp7 has actual    counts for all contract+sertype combos
* and, tTemp3 has projected counts for all contract+sertype combos
* join them, and load into report cursor

	SELECT 	a.Contract , ;
				a.SerT 					AS Ser_type , ;
				a.Descript , ;	
				INT(VAL(a.ns_proj)) AS ns_proj , ;
				INT(VAL(a.nc_proj)) AS nc_proj , ;		
				b.ns , ;
				b.nc , ;
				a.ContrDes ;
	FROM		tTemp3 a, ;
				tTemp7 b  ;
	WHERE		a.Contract=b.Contract ;					
	AND		a.SerT = b.Ser_Type ;
	INTO CURSOR tTemp8

* jss, 7/11/03, remove DIST from sum to fix problem	Sum(DIST ns) 		AS NumbSess
****Summary
	SELECT 	Contract, ;
				Sum(ns) 		AS NumbSess, ;
				Sum(nc)		AS NumbEnc ;
	FROM 		tTemp8 ;
	GROUP BY ;	
				Contract ;
	INTO CURSOR ;
				tOutr
	
* jss, 7/16/03, add code here to create cursors for Outreach, Training, HCPI Education, HCPI, and 
*					Other Intervention for modified part III-D2 (Summary of Intervention Types Year-to-date)

	cCursName='tOutRch'+STR(i,1)
	SELECT 	Serv_cat, ;
   			COUNT(*)   AS NumbSess, ;
            SUM(Total+Total_Unkn) AS NumbEnc ;
	FROM 		tTemp4    ;
	WHERE		Serv_Cat = '00015' ;
	INTO CURSOR ;
				&cCursName;
	GROUP BY 1			

	cCursName='tTraining'+STR(i,1)
	SELECT 	Serv_cat, ;
   			COUNT(*)   AS NumbSess, ;
            SUM(Total+Total_Unkn) AS NumbEnc ;
	FROM 		tTemp4    ;
	WHERE		Serv_Cat = '00016' ;
	INTO CURSOR ;
				&cCursName;
	GROUP BY 1			

	cCursName='tHCPIEd'+STR(i,1)
	SELECT 	Serv_cat, ;
   			COUNT(*)   AS NumbSess, ;
            SUM(Total+Total_Unkn) AS NumbEnc ;
	FROM 		tTemp4    ;
	WHERE		Serv_Cat = '00017' ;
	INTO CURSOR ;
				&cCursName;
	GROUP BY 1			

	cCursName='tHCPI'+STR(i,1)
	SELECT 	Serv_cat, ;
   			COUNT(*)   AS NumbSess, ;
            SUM(Total+Total_Unkn) AS NumbEnc ;
	FROM 		tTemp4    ;
	WHERE		Serv_Cat = '00018' ;
	INTO CURSOR ;
				&cCursName;
	GROUP BY 1			

	cCursName='tOthin'+STR(i,1)
	SELECT 	Serv_cat, ;
   			COUNT(*)   AS NumbSess, ;
            SUM(Total+Total_Unkn) AS NumbEnc ;
	FROM 		tTemp4    ;
	WHERE		Serv_Cat = '00019' ;
	INTO CURSOR ;
				&cCursName;
	GROUP BY 1
   			
* jss, end of 7/16/03 change

* save in appropriate "Part" table (Part1 or Part2). The 2 are then combined to give the report
* cursor, with Part1 holding the monthly detail info, and Part2 holding the YTD info

	cCursName='tPart'+STR(i,1)

	SELECT 	STR(i,1)	AS PART, ;
				tTemp8.* ;
	FROM		tTemp8 ;
	INTO CURSOR  &cCursName

	cCursName='tOutr'+STR(i,1)

	SELECT 	STR(i,1)	AS PART, ;
				tOutr.* ;
	FROM		tOutr ;
	INTO CURSOR  &cCursName
NEXT  

SELECT tPart1.*, ;
        cMonthYear as cMonthYear, ;
        cDate  as cDate, ;
        cTime  as cTime, ;
        cAgc_Name as cAgc_Name ; 
   FROM tPart1 ;
UNION ;
SELECT tPart2.*, ;
        cMonthYear as cMonthYear, ;
        cDate  as cDate, ;
        cTime  as cTime, ;
        cAgc_Name as cAgc_Name ;  
	FROM tPart2 ;
INTO CURSOR Final	 ;
ORDER BY 1, 2, 4

IF USED("tOutr")
	USE IN tOutr
ENDIF

SELECT 0
USE (DBF("tOutr2")) AGAIN ALIAS tOutr

APPEND FROM DBF("tOutr1")
INDEX ON Contract+Part TAG Contract

oApp.Msg2User('OFF')


SELECT Final
SET RELATION TO Contract+Part INTO tOutr

GO TOP
IF EOF()
      oApp.Msg2user('NOTFOUNDG')
      If Used('final')
         Use in final
      Endif   
   
       Select ;
                 ContrInf.Descript   AS ContrDes   ,;
                 'Section III: Monthly Program Report' as nulrptname ,;
                 'III-C1: Summary of Anonymous Services Provided During the Reporting Month' as nulrptnam1 ,;
                 'III-D1: Summary of Anon. Services Provided Year to Date' as nulrptnam2 ,;
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
          EndCase
Else
          gcRptName = 'rpt_prev_an'  
	       DO CASE
             CASE lPrev = .f.
                  Report Form rpt_prev_an  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_prev_an', 1, 2)
          ENDCASE
ENDIF
********************
Function clean_data
If Used("ytdfrom")
   Use in ytdfrom
EndIf
   
IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("tTemp3")
	USE IN ("tTemp3")
ENDIF

IF USED("tTemp4")
	USE IN ("tTemp4")
ENDIF

IF USED("tTemp5")
	USE IN ("tTemp5")
ENDIF

IF USED("tTemp6")
	USE IN ("tTemp6")
ENDIF

IF USED("tTemp7")
	USE IN ("tTemp7")
ENDIF

IF USED("tTemp8")
	USE IN ("tTemp8")
ENDIF

IF USED("tTemp51")
	USE IN ("tTemp51")
ENDIF

IF USED("tPart1")
	USE IN ("tPart1")
ENDIF

IF USED("tPart2")
	USE IN ("tPart2")
ENDIF

IF USED("tFinal")
	USE IN ("tFinal")
ENDIF

IF USED("tOutr")
	USE IN ("tOutr")
ENDIF


IF USED("tOutr1")
   USE IN ("tOutr1")
ENDIF


IF USED("tOutRch1")
	USE IN ("tOutRch1")
ENDIF

IF USED("tOutRch2")
	USE IN ("tOutRch2")
ENDIF

IF USED("tTraining1")
	USE IN ("tTraining1")
ENDIF

IF USED("tTraining2")
	USE IN ("tTraining2")
ENDIF

IF USED("tHCPIEd1")
	USE IN ("tHCPIEd1")
ENDIF

IF USED("tHCPIEd2")
	USE IN ("tHCPIEd2")
ENDIF

IF USED("tHCPI1")
	USE IN ("tHCPI1")
ENDIF

IF USED("tHCPI2")
	USE IN ("tHCPI2")
ENDIF

IF USED("tOthin1")
	USE IN ("tOthin1")
ENDIF

IF USED("tOthin2")
	USE IN ("tOthin2")
ENDIF

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

