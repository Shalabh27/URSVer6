*  Program...........: SUMMZIP.PRG (Summary of New and Total Clients by Area ZIP Codes)
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

m.ContrDes = " "

=OPENFILE("Contrinf")

SELECT Contrinf
Locate For Contrinf.Cid = cContract
m.ContrDes =Contrinf.Descript


PRIVATE gcHelp
gcHelp = "" && it should be changed in a future to the Help Topic's Title

* MHRA decided that the agency would be responsible for establishing an MHRA program,
* that would be included only in one contract.
* select all clients enrolled in any MHRA Program in a given period of time.

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

* only get new clients for monthly counts (i=1)
* get all clients enrolled this year, including reopens (i=2)

   IF i=1
		SELECT c.Con_ID AS Contract, f.Descript AS ContrDes, a.Tc_ID ;
		FROM Ai_Prog A, ;
			Program B, ;
			Contract C, ;
			Ai_Site D, ;
			Site E, ;
			ContrInf F ;
		WHERE c.Con_ID = cContract ;
			AND a.Program = b.Prog_ID ;
			AND b.Aar_Report ;	
			AND b.Prog_ID = c.Program ;
			AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
			AND c.Start_Dt <= dDate_From ;
			AND c.End_Dt   >= dDate_To ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND c.Con_ID = f.Cid ;
		 	AND !EXISTS (SELECT * FROM Ai_Prog ;
		 						WHERE Ai_Prog.Program = A.Program ;
		 							AND !EMPTY(Ai_Prog.End_Dt) ;
	 								AND AI_Prog.End_Dt <= a.Start_Dt ;
	 								AND AI_Prog.Tc_ID = a.TC_ID) ;
		INTO CURSOR tTemp1
      
	ELSE
		SELECT c.Con_ID AS Contract, f.Descript AS ContrDes, a.Tc_ID ;
		FROM Ai_Prog A, ;
			Program B, ;
			Contract C, ;
			Ai_Site D, ;
			Site E, ;
			ContrInf F ;
		WHERE c.Con_ID = cContract ;
			AND a.Program = b.Prog_ID ;
			AND b.Aar_Report ;	
			AND b.Prog_ID = c.Program ;
			AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
			AND c.Start_Dt <= dDate_From ;
			AND c.End_Dt   >= dDate_To ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND c.Con_ID = f.Cid ;
		INTO CURSOR tTemp1 
   Endif


***VT 12/03/2007

*!*      SELECT a.Contract, a.ContrDes, a.Tc_ID, b.Client_ID, ;
*!*            d.County, d.St AS State, LEFT(d.Zip,5) AS Zip, e.Descript ;
*!*         FROM tTemp1 A, ;
*!*             Ai_Clien B, ;
*!*             Address D, ;
*!*             County E ;
*!*         WHERE a.Tc_ID = b.Tc_ID ;
*!*            AND b.Client_ID = d.Client_ID ;
*!*            AND d.County = e.Code ;
*!*            AND d.St = e.State ;
*!*         INTO CURSOR tTemp2


SELECT a.Contract, a.ContrDes, a.Tc_ID, b.Client_ID, ;
         Nvl(e.countyfips, 'Unknown') as County, d.St AS State, ;
         LEFT(d.Zip,5) AS Zip, Nvl(e.countyname, 'Unknown') as Descript  ;
FROM tTemp1 A ;
      Inner Join Ai_Clien B  On ;
               a.Tc_ID = b.Tc_ID ;
      Inner Join Address D on ;
               b.Client_ID = d.Client_ID ;
      Left outer Join zipcode e On ;
               d.fips_code = e.countyfips ;
           and d.st = e.statecode  ;
      INTO CURSOR tTemp2
    

* count number per contract+state+county+zip code
	SELECT Contract, State, County, Zip, COUNT(DIST Tc_ID) AS NumbCliZip ;
		FROM tTemp2 ;
		INTO CURSOR tZip ;
        GROUP BY Contract, State, County, Zip;
	
   cCursName = "tPart" + STR(i,1) 
	
   ***VT 12/03/2007
*!*   SELECT a.Contract, c.Descript AS ContrDes, a.State, a.County, b.Descript, a.Zip, a.NumbCliZip ;
*!*   	FROM tZip   A, ;
*!*   		County   B, ;
*!*   		ContrInf C ;
*!*   	INTO CURSOR &cCursName ;	
*!*   	WHERE  a.State    = b.State ;
*!*   		AND a.County   = b.Code ;
*!*   		AND a.Contract = c.Cid ;
*!*   		ORDER BY a.Contract, a.State, a.County, c.Descript

   SELECT a.Contract, c.Descript AS ContrDes, a.State, a.County, Nvl(e.countyname, 'Unknown') as Descript, a.Zip, a.NumbCliZip ;
      FROM tZip   A ;
            Inner Join  ContrInf C On ;
               a.Contract = c.Cid ;
             Left outer Join zipcode e On ;
               a.county = e.countyfips ;
           and a.state = e.statecode  ;
      INTO CURSOR &cCursName ;   
         ORDER BY a.Contract, a.State, a.County, e.countyname


NEXT							

SELECT b.Contract, b.ContrDes, b.State, b.County, b.Descript, ;
		 b.Zip AS ZipList, a.NumbCliZip AS NumbClizip, b.Zip AS ZipListTot, b.NumbCliZip AS NumbCliZT ;
	FROM tPart1 A, tPart2 B ;
	WHERE a.Contract = b.Contract ;
	  AND a.State    = b.State ;
	  AND a.County   = b.County ;
	  AND a.Zip      = b.Zip ;
	INTO CURSOR tInterim

SELECT A.* ;
	FROM tInterim A ;
UNION ;
SELECT b.Contract, b.ContrDes, b.State, b.County, b.Descript, ;
		b.Zip AS ZipList, 0 AS NumbCliZip, b.Zip AS ZipListTot, b.NumbCliZip AS NumbCliZT ; 
	FROM tPart2 B ;
	WHERE b.Contract + b.State + b.County + b.Zip NOT IN ;
		(SELECT c.Contract + c.State + c.County + c.ZipList FROM tInterim c) ;
	INTO CURSOR tFinal 
   
   Select tFinal.*, ;
          cMonthYear as cMonthYear, ;
          cDate  as cDate, ;
          cTime  as cTime, ;
          cAgc_Name as cAgc_Name ;      
   From tFinal ;
   Into Cursor Final ;
	ORDER BY 1, 3, 5, 6

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
                    'Table IV - G: Summary of New and Total Clients by Area Zip Codes'  as nulrptnam1 ,;
                    '' as nulrptnam2 ,;
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
          gcRptName = 'rpt_mhra_zip'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_zip  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                   oApp.rpt_print(5, .t., 1, 'rpt_mhra_zip', 1, 2)
          Endcase
   Endif       
EndIf
****************************
Function clean_data

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp1a")
	USE IN ("tTemp1a")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("tClients")
	USE IN ("tClients")
ENDIF

IF USED("tZip")
	USE IN ("tZip")
ENDIF

IF USED("tPart1")
	USE IN ("tPart1")
ENDIF

IF USED("tPart2")
	USE IN ("tPart2")
ENDIF

IF USED("tInterim")
	USE IN ("tInterim")
ENDIF

IF USED("tFinal")
	USE IN ("tFinal")
ENDIF

RETURN

*******************
FUNCTION Electronic
*******************
* jss, 5/17/04, add code here to write to electronic mpr table (mprivg.dbf)

SELECT 0
USE mprivg EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

STORE 0 TO cNumCliZip, cNumCliZT, tNumCliZip, tNumCliZT


* now, roll thru tfinal, writing 1 Electronic MPR record per tfinal record
SELECT tFinal
GO TOP

cbreak = tfinal.state + tfinal.county

SCAN
	
	IF tfinal.state + tfinal.county <> cbreak
		=CntyBreak()
	ENDIF

* write a detail line to electronic mpr dbf
	m.descript 	 = tfinal.descript
	m.ziplist    = tfinal.ziplist
	m.numbclizip = tfinal.numbclizip
	m.ziplisttot = tfinal.ziplisttot
	m.numbclizT  = tfinal.numbclizT

	SELECT mprivg
	APPEND BLANK
	GATHER MEMVAR

* add to county and report totals		
	cNumCliZip = cNumCliZip + m.NumbCliZip
	cNumCliZT  = cNumCliZT  + m.NumbCliZT

	tNumCliZip = tNumCliZip + m.NumbCliZip
	tNumCliZT  = tNumCliZT  + m.NumbCliZT
	
	SELECT tFinal
ENDSCAN

* write final county totals line
=CntyBreak()

* write report total line
m.descript  = 'Report Totals'
STORE SPACE(10) TO m.ziplist, m.ziplisttot
m.NumbCliZip = tNumCliZip
m.NumbCliZT  = tNumCliZT

SELECT mprivg
APPEND BLANK
GATHER MEMVAR

USE IN mprivg

SELECT tFinal
GO TOP
RETURN

******************
FUNCTION CntyBreak
******************

* write a break line
m.descript=Alltrim(m.descript) +' County Totals'
STORE SPACE(10) TO m.ziplist, m.ziplisttot
*m.NumCliZip = cNumCliZip
*m.NumCliZT  = cNumCliZT
* jss, 5/4/05, fix problem in which variables were misspelled above ("NumCliZip" instead of "NumbCliZip", "NumCliZT" instead of "NumbCliZT"), 
*              which resulted in county total being whatever last detail line value of numbclizip and numbclizt was
m.NumbCliZip = cNumCliZip
m.NumbCliZT  = cNumCliZT

* write a break line to electronic mpr dbf
SELECT mprivg
APPEND BLANK
GATHER MEMVAR

* re-initialize counters, break value

STORE 0 TO cNumCliZip, cNumCliZTt
STORE tfinal.state + tfinal.county to cBreak

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
USE mprivg EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mprivg
RETURN
