*  Program...........: SUMMRFIN.PRG (Summary of Referrals IN for the Reporting Month)
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

=clean_data()

m.ContrDes = ''
=OPENFILE("Contrinf")

SELECT Contrinf
Locate For Contrinf.Cid = cContract
m.ContrDes =Contrinf.Descript

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

dDate_to = date_to
m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(m.date_from),4)),ytdfrom.ytd_from)

FOR i = 1 TO 2
*	dDate_From = IIF(i = 1, m.date_from, CTOD('01/01/' + STR(YEAR(m.date_from),4)))
* use contract start date for YTD numbers
	dDate_From = IIF(i = 1, m.date_from, m.ytd_from)

	SELECT DIST ;
	      c.Con_ID   AS Contract, ;
	      h.Descript AS ContrDes, ;
		   a.Program  AS Program,  ;
		   a.Tc_ID, ;
		   f.ref_src2 AS Ref_In,   ;
		   g.Descript AS Ref_InDesc,;
		   IIF(f.nRefNote=1,'Internal','External') AS nRefNote;
		FROM ;
		   Ai_Prog  A, ;
			Program  B, ;
			Contract C, ;
			Ai_Site  D, ;
			Site     E, ;
			Ai_Clien F, ;
			Ref_In   G, ;
			ContrInf H  ;
		WHERE  c.Con_ID    = cContract ;
			AND c.Start_dt <= m.Date_from ;
			AND c.End_dt   >= m.Date_to ;
		   AND h.CID       = c.Con_id ;
			AND a.Program   = b.Prog_ID ;
			AND b.Aar_Report ;	
			AND b.Prog_ID   = c.Program ;
			AND a.Tc_ID     = d.Tc_ID ;
			AND e.Site_ID   = d.Site ;
			AND e.Site_ID   = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND a.Tc_ID     = f.Tc_ID ;
			AND f.Placed_dt BETWEEN dDate_From AND dDate_To ;
			AND f.ref_src2  = g.code;
		INTO CURSOR tTemp

   cCursName = "tTemp" + STR(i,1) 
	SELECT ;
	       Contract,  ;
      	 ContrDes,  ;
	       COUNT(DIST Tc_ID) AS NumbofCli, ;
	       Ref_in,    ;
   	    Ref_inDesc,;
   	    nRefNote;
		FROM tTemp ;
		INTO CURSOR &cCursName ;
		GROUP BY 1, 5, 6, 2, 4 
NEXT	

* now, we have a monthly table (tTemp1) and a YTD table (tTemp2)
* everything represented in the monthly table is necessarily found in the YTD table, but not vice versa,
* so we must create a zero monthly count for the YTD records not in this month

SELECT ;
       b.Contract, ;
       b.ContrDes, ;
       a.NumbofCli AS NumbofCliM, ;
       b.NumbofCli AS NumbofCliT, ;
       b.Ref_In,   ;
       b.Ref_InDesc,;
       b.nRefNote ;
  FROM ;
       tTemp1 a, ;
       tTemp2 b  ;
 WHERE ;
       a.Contract=b.Contract ;
   AND a.Ref_In  =b.Ref_In ;
   AND a.nRefNote=b.nRefNote;
 INTO CURSOR ;
       tTemp3
  
SELECT tTemp3.*, ;
         cMonthYear as cMonthYear, ;
         cDate  as cDate, ;
         cTime  as cTime, ;
         cAgc_Name as cAgc_Name ;  
FROM tTemp3;
UNION ;
SELECT;
       Contract,  ;
       ContrDes,  ;
       0000        AS NumbofCliM, ;
       NumbofCli   AS NumbofCliT, ;
       Ref_In,    ;
       Ref_InDesc,;
       nRefNote,   ;
       cMonthYear as cMonthYear, ;
       cDate  as cDate, ;
       cTime  as cTime, ;
       cAgc_Name as cAgc_Name ;  
  FROM;
       tTemp2;
 WHERE;
       Contract+Ref_In+nRefNote ;
  NOT IN ;
       (SELECT Contract+Ref_In+nRefNote FROM tTemp3);
 INTO CURSOR;       
       Final;
 ORDER BY;
       1, 6, 7

                
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
                       'Table III - E: Summary of Referrals for the Month' as nulrptnam1 ,;
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

          gcRptName = 'rpt_mhra_rpr' 
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_rpr  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_rpr', 1, 2)
          Endcase
   Endif       
EndIf
**********************
Function clean_data

IF USED("tTemp")
   USE IN ("tTemp")
ENDIF

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
EndIf

IF USED("tTemp3")
   USE IN ("tTemp3")
EndIf

IF USED("Final")
	USE IN ("Final")
ENDIF

RETURN	

*******************
FUNCTION Electronic
*******************
* jss, 5/14/04, add code here to write to electronic mpr table (mpriiid.dbf)

SELECT 0
USE mpriiid EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

STORE 0 TO tNumbCliM, tNumbCliT

* now, roll thru tfinal, writing 1 Electronic MPR record per Final record
SELECT Final
GO TOP

SCAN
	SCATTER MEMVAR	

* write a detail line to electronic mpr dbf
	SELECT mpriiid
	APPEND BLANK
	GATHER MEMVAR
	
	tNumbCliM=tNumbCliM + m.NumbofCliM
	tNumbCliT=tNumbCliT + m.NumbofCliT
	
	SELECT Final
ENDSCAN

* write report total line

m.Ref_InDesc='Report Totals'
m.nRefNote=SPACE(8)
m.NumbofCliM=tNumbCliM
m.NumbofCliT=tNumbCliT

SELECT mpriiid
APPEND BLANK
GATHER MEMVAR

USE IN mpriiid

SELECT Final
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
USE mpriiid EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mpriiid
RETURN
