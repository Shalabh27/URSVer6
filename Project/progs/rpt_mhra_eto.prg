*  Program...........: SUMMETO.PRG (Summary of Services Provided during the Reporting Month)
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

  * Part I
  * we're selecting the projected info
  * jss, 1/2000, add 'windowing' code (stuff in '19' or '20') to BETWEEN() in Where clause below

	SELECT	a.Contract, ;
				a.SerT, ;
				b.Descript, ;
  				b.SerUnit, ;
  				b.NofCl, ;
  				STR(SUM(a.nc)) AS nc_proj, ;
  				STR(SUM(a.ns)) AS ns_proj ;
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
  	INTO CURSOR tTemp1 ;
   Group By 1, 2, 3, 4, 5
 
  	SELECT 	a.Cid AS Contract, ;
  				c.SerT, ;
  				b.Descript, ;
  				b.SerUnit, ;
  				b.NofCl, ;
  				STR(0) AS nc_proj, ;
  				STR(0) AS ns_proj ;
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
  * get all ETO transactions for period

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
	AND 		Ai_outr.Program = Program.Prog_ID ;
	AND 		Ai_outr.Program = Contract.Program ;
	AND 		Program.Aar_Report ;
  	AND 		Ai_outr.Act_Dt BETWEEN dDate_From AND dDate_To ;
  	INTO CURSOR ;
  				tTemp4	;

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
	
* save in appropriate "Part" table (Part1 or Part2). The 2 are then combined to give the report
* cursor, with Part1 holding the monthly detail info, and Part2 holding the YTD info

	cCursName='tPart'+STR(i,1)

	SELECT 	STR(i,1)	AS PART, ;
				tTemp8.* ;
	FROM	tTemp8 ;
	INTO CURSOR  &cCursName

NEXT  

SELECT * ;
	FROM tPart1 ;
UNION ;
SELECT * ;
	FROM tPart2 ;
INTO CURSOR ;
	tFinal	 ;
    
Select tFinal.*, ;
       cMonthYear as cMonthYear, ;
       cDate  as cDate, ;
       cTime  as cTime, ;
       cAgc_Name as cAgc_Name ;      
From tFinal ;
Into Cursor Final ;
ORDER BY 1, 2, 4

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
                    'Table IV - I: Summary of ETO Events During the Reporting Month' as nulrptnam1 ,;
                    'Table IV - J: Summary of ETO Events Year to Date' as nulrptnam2 ,;
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
   Else

          gcRptName = 'rpt_mhra_eto' 
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_eto  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_eto', 1, 2)
          Endcase
   Endif       
EndIf
**************************
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
EndIf

IF USED("Final")
   USE IN ("Final")
ENDIF

RETURN	

*******************
FUNCTION Electronic
*******************
* jss, 5/14/04, add code here to write to electronic mpr table (mprivij.dbf)

SELECT 0
USE mprivij EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

* now, roll thru tfinal, writing 1 Electronic MPR record per tfinal record, plus a totals record on each break
SELECT tFinal
GO TOP

SCAN
	SCATTER MEMVAR
	
* define a few more memvars
	m.periodtype=IIF(m.part='1','Monthly','YTD')
	m.ns_pct=IIF(!EMPTY(m.ns_proj), TRAN((m.ns/m.ns_proj)*100, '999.99'),SPACE(6))
	m.nc_pct=IIF(!EMPTY(m.nc_proj), TRAN((m.nc/m.nc_proj)*100, '999.99'),SPACE(6))

	SELECT mprivij
	APPEND BLANK
	GATHER MEMVAR
	
	SELECT tFinal
ENDSCAN

USE IN mprivij

SELECT tFinal
GO TOP
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
USE mprivij EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mprivij
RETURN



