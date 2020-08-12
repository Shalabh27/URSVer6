*  Program...........: SUMMANON.PRG (Anonnymous Services and Client Demographics)
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

* Check the layout of the tables H-1 and H-2
* table H-1. Target Neighborhoods Served
SELECT  c.Con_ID AS Contract, a.Category, a.Act_ID, ;
		a.cdcLocType, d.Descript AS LocTypeDes, a.Total, a.Total_Unkn, ;
      LEFT(ALLTRIM(a.Zip),5) AS Zip, ;
      e.descript AS EncDesc  ;
	FROM Ai_Outr A, ;
		Program B, ;
		Contract C, ;
		Settings D, ;
		lv_Enc_type E ;
	WHERE a.Program = b.Prog_ID ;
		AND b.Prog_ID = c.Program ;
		AND a.Serv_Cat = '00006' ;
		AND BETWEEN(a.Act_Dt, m.Date_From, m.Date_To) ;
		AND c.con_id = cContract ;
		AND c.Start_Dt <= m.Date_From ;
		AND c.End_Dt   >= m.Date_To ;
		AND a.cdcLocType = d.Code ;
		AND b.Agency_ID = cAgency_ID ;
		AND e.Serv_Cat = '00006' ;
		AND a.enc_id  = e.enc_id;
	INTO CURSOR tTemp1 

* jss, 2/14/02, removed this line from above select, because field no longer used: " AND b.aar_report ; "

* now we're going to get the total number of events and participants for each category
SELECT Contract, Category, COUNT(Act_ID) AS NumbofEnc, ;
		SUM(Total+Total_Unkn) AS NumbofPart, 1 AS LineNo ;
	FROM tTemp1 ;
	INTO CURSOR tCalcReslt ;
	GROUP BY 1, 2 	 

* now we should select all methods 
SELECT a.*, b.Code AS Method, c.Descript AS MethodDesc;
	FROM tTemp1 A, ;
		 Ai_Outmd B, ;
		 Delivery C ;
	WHERE a.Act_ID = b.Act_ID ;
		AND b.Code = c.Code ;
	INTO CURSOR tTemp2 

* may be I shouldn't run the next select, 'cause I, probably, wouldn't need the empty methods.	
* but probably I need the loc_type

SELECT * ;
	FROM tTemp2 ;
UNION ;
SELECT *, SPACE(2) AS Method, SPACE(50) AS MethodDesc ;
	FROM tTemp1 ;
	WHERE Act_ID NOT IN (SELECT Act_ID FROM tTemp2) ;
	INTO CURSOR tTemp3 ;
	ORDER BY 1, 2, 4
	
SELECT *, RECNO() AS nRecno ;
	FROM tTemp3 ;
	INTO CURSOR tRecno
	
SELECT Contract, Category, MIN(nRecno) AS nMinRecno ;
	FROM tRecno ;
	GROUP BY 1,2 ;
	INTO CURSOR tMinRecno

SELECT a.*, a.nRecno - b.nMinRecno + 1 AS LineNo ;
	FROM tRecno A, tMinRecno B ;
	WHERE a.Contract + a.Category = b.Contract + b.Category ;
	INTO CURSOR tMethods
						
SELECT Contract, Category, Zip ;
	FROM tTemp1 ;
	WHERE NOT EMPTY(Zip) ;
UNION ;
SELECT a.Contract, a.Category, LEFT(ALLTRIM(b.Zip),5) AS Zip ;
	FROM tTemp1 A, Ai_Outzp B ;
	WHERE a.Act_ID = b.Act_ID ;	
		AND NOT EMPTY(b.Zip) ;
	INTO CURSOR tZip  ;
	ORDER BY 1, 2, 3
	
	* ZipList and nColumnWidth should have the same width
	
	CREATE CURSOR tZipFilled (Contract C(10), Category C(3), ZipList C(20), LineNo N(2))
	nColumnWidth = 22
	
	SELECT tZip
	GO TOP
	
	* I should do something about empty Zip code.
	nLineNo = 1
	DO WHILE NOT EOF()
		cZipStr = ""
		SCATTER MEMVAR
		DO WHILE .T.
			IF LEN(cZipStr + ALLTRIM(tZip.Zip) + ", ") > nColumnWidth ;
			 OR m.Contract + m.Category <> tZip.Contract + tZip.Category
				IF m.Contract + m.Category <> tZip.Contract + tZip.Category
					cZipStr = LEFT(cZipStr,LEN(cZipStr)-2)
				ENDIF		 
				INSERT INTO tZipFilled VALUES (m.Contract, m.Category, cZipStr, nLineNo)
				IF m.Contract + m.Category <> tZip.Contract + tZip.Category
					nLineNo = 1
				ELSE
					nLineNo = nLineNo + 1
				ENDIF	
				EXIT
			ELSE	
				cZipStr = cZipStr + ALLTRIM(tZip.Zip) + ", "
			ENDIF	
			SELECT tZip
			SKIP
		ENDDO	
	ENDDO

SELECT a.Contract, a.Category, a.cdcLocType, a.LocTypeDes, ;
		a.Method, a.MethodDesc, b.NumbofEnc, b.NumbofPart, a.LineNo, a.EncDesc ;
	FROM tMethods A, tCalcReslt B ;
	WHERE a.Contract + a.Category + STR(a.LineNo) = b.Contract + b.Category + STR(b.LineNo) ;
UNION ;
SELECT Contract, Category, cdcLocType, LocTypeDes, ;
		Method, MethodDesc, 0 AS NumbofEnc, 0 AS NumbofPart, LineNo, EncDesc ;
	FROM tMethods ;
	WHERE Contract + Category + STR(LineNo) NOT IN ;
			(SELECT Contract + Category + STR(LineNo) FROM tCalcReslt) ;
	INTO CURSOR tInterim 		
	
SELECT a.Contract, a.Category, a.cdcLocType, a.LocTypeDes, ;
		a.Method, a.MethodDesc, a.NumbofEnc, a.NumbofPart, ;
		b.ZipList, B.LineNo, a.EncDesc ;
	FROM tInterim A, tZipFilled B ;
	WHERE a.Contract + a.Category + STR(a.LineNo) = b.Contract + b.Category + STR(b.LineNo) ;
UNION ;
SELECT Contract, Category, cdcLocType, LocTypeDes, ;
		Method, MethodDesc, NumbofEnc, NumbofPart, ;
		SPACE(20) AS ZipList, VAL(STR(LineNo)), EncDesc ;
	FROM tInterim ;
	WHERE Contract + Category + STR(LineNo) NOT IN ;
		(SELECT Contract + Category + STR(LineNo) FROM tZipFilled) ;
UNION ;
SELECT Contract, Category, SPACE(2) AS cdcLocType, SPACE(30) AS LocTypeDes, ;
		SPACE(2) AS Method, SPACE(50) AS MethodDesc, ;
		0 AS NumbofEnc, 0 AS NumbofPart, ZipList, LineNo, SPACE(50) AS EncDesc ;
	FROM tZipFilled ;
	WHERE Contract + Category + STR(LineNo) NOT IN ;
		(SELECT Contract + Category + STR(LineNo) FROM tInterim) ;
	INTO CURSOR tPreFinal 
	
SELECT a.*, b.Descript AS CategDesc, c.Descript AS ContrDes ;
	FROM tPreFinal A, Category B, ContrInf C ;
	INTO CURSOR tFinal ;
	WHERE b.Serv_Cat = '00006' ;
		AND a.Category = b.Code ;	
		AND a.Contract = c.Cid ; 
	ORDER BY 1, 2, 10	

* table H-2. Anonymous Client Demographics
* jss, 8/4/04, add transgender fields
SELECT c.Con_ID AS Contract, SUM(a.n_white) AS n_white, SUM(a.n_black) AS n_black, SUM(a.n_hispanic) AS n_hispanic, ;
	   SUM(a.n_asian) AS n_asian, SUM(a.n_native) AS n_native, SUM(a.n_other) AS n_other, ;
	   SUM(a.n_children) AS n_children, SUM(a.n_adolesc) AS n_adolesc, SUM(a.n_adults) AS n_adults, ;
	   SUM(a.n_males) AS n_males, SUM(a.n_females) AS n_females, SUM(a.n_transfm) AS n_transfm, SUM(a.n_transmf) AS n_transmf, ;
	   SUM(a.total) AS total_know, COUNT(dist a.act_id) AS total_enc, ;
	   SUM(a.total_unkn) AS total_unkn, SUM(a.total+a.total_unkn) AS total_cli, ;
	   SUM(a.n_hawaisle) AS n_hawaisle, SUM(a.n_morthan1) AS n_morthan1, SUM(a.n_raceunkn) AS n_raceunkn, ;
	   SUM(a.n_20_29) AS n_20_29, SUM(a.n_30_49) AS n_30_49, SUM(a.n_50plus) AS n_50plus ;
	FROM Ai_Outr A, ;
		Program B, ;
		Contract C;
	WHERE a.Program = b.Prog_ID ;
		AND b.Prog_ID = c.Program ;
		AND a.Serv_Cat = '00006' ;
		AND BETWEEN(a.Act_Dt, m.Date_From, m.Date_To) ;
		AND c.Con_id = cContract ;
		AND b.Agency_ID = cAgency_ID ;
		GROUP BY 1 ;
	INTO CURSOR AnonCliDem

* jss, 2/14/02, removed this line from above select, because field no longer used: " AND b.aar_report ; "

INDEX ON CONTRACT TAG CONTRACT

Select tFinal.*, ;
       cMonthYear as cMonthYear, ;
       cDate  as cDate, ;
       cTime  as cTime, ;
       cAgc_Name as cAgc_Name ;      
From tFinal;
Into cursor Final

SET RELATION TO CONTRACT INTO ANONCLIDEM

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
                    'Table H-1. Target Neighborhoods Served' as nulrptnam1 ,;
                    'Table H-2. Anonymous Client Demographics' as nulrptnam2 ,;
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
          gcRptName = 'rpt_mhra_ano'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_ano  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                   oApp.rpt_print(5, .t., 1, 'rpt_mhra_ano', 1, 2)
          Endcase
  Endif        
EndIf
****************************
Function clean_data

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("tTemp3")
	USE IN ("tTemp3")
ENDIF

IF USED("tRecno")
	USE IN ("tRecno")
ENDIF

IF USED("tMinRecno")
	USE IN ("tMinRecno")
ENDIF

IF USED("tCalcReslt")
	USE IN ("tCalcReslt")
ENDIF

IF USED("tMethods")
	USE IN ("tMethods")
ENDIF

IF USED("tZip")
	USE IN ("tZip")
ENDIF

IF USED("tZipFilled")
	USE IN ("tZipFilled")
ENDIF

IF USED("tInterim")
	USE IN ("tInterim")
ENDIF

IF USED("tPrefinal")
	USE IN ("tPrefinal")
ENDIF

IF USED("tFinal")
	USE IN ("tFinal")
ENDIF

IF USED("AnonCliDem")
	USE IN ("AnonCliDem")
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

*******************
FUNCTION Electronic
*******************
* jss, 5/12/04, add code here to write to electronic mpr table (mprivh1, mprivh2)
m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

SELECT 0
USE mprivh1 EXCL
ZAP
	
SELECT tFinal
SCAN
	INSERT INTO mprivh1 	(agency, contract, date_from, date_to, categdesc, encdesc, loctypedes, numbofenc, numbofpart, ziplist, user_id, dt, tm ) ;
				VALUES	(m.Agency, m.contract, m.date_from, m.date_to, tFinal.categdesc, tFinal.encdesc, tFinal.loctypedes, tFinal.numbofenc, tFinal.numbofpart, tFinal.ziplist, m.user_id, m.dt, m.tm)
	SELECT tFinal	
ENDSCAN
USE IN mprivh1

SELECT tFinal
GO TOP

SELECT 0
USE mprivh2 EXCL
ZAP

SELECT anonclidem
SCATTER MEMVAR

SELECT mprivh2
APPEND BLANK
GATHER MEMVAR
				
USE IN mprivh2

SELECT tFinal
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
USE mprivh1 EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mprivh1

SELECT 0
USE mprivh2 EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mprivh2
RETURN
