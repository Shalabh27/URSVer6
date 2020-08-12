*  Program...........: SUMMFUPA.PRG (Follow-Up Activities Provided during the Reporting Month)
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

* we're selecting services provided during the reporting month.
* MHRA decided that the agency would be responsible for establishing an MHRA program,
* that would be included only in one contract.
* MHRA wants to count encounters, so I should pick up just the first service in a physical order
* and roll it up to the service category for service type follow-up flag equal to true.
  
SELECT Contract.Con_id AS Contract, ConSD.Ser_Type, ;
 		Ai_Enc.Tc_ID, Ai_Enc.Act_ID, Ai_Enc.Act_Dt, Ai_Enc.Act_Loc, ;
 		Ai_Enc.Serv_Cat, Ai_Enc.Enc_id, Ai_Serv.Service, Ai_Serv.service_id ;
 	FROM ConSd, ;
		 Ai_Enc, ;
		 Ai_Serv, ;
		 Program, ;
		 Contract, ;
		 Ai_Site, ;
		 Site, ;
		 SerType ;
  	WHERE Contract.Con_ID = cContract ;
			AND Contract.Start_dt <= m.Date_from ;
			AND Contract.End_dt   >= m.Date_to ;
  		AND ConSD.Contract = Contract.Cid ;
   		AND ConSD.Enc_id = Ai_Enc.Enc_id ;
   		AND ConSD.Serv_Cat = Ai_Enc.Serv_Cat ;
   		AND ConSD.Service_id = Ai_Serv.Service_id ;
   		AND Ai_Enc.Act_ID = Ai_Serv.Act_ID ;
   		AND Ai_Enc.Program = Program.Prog_ID ;
   		AND Ai_Enc.Program = Contract.Program ;
   		AND Program.Aar_Report ;
   		AND Ai_Enc.Act_Dt BETWEEN m.Date_From AND m.Date_To ;
		AND Ai_Enc.Tc_ID = Ai_Site.Tc_ID ;
	    AND Site.Site_ID = Ai_Site.Site ;
	    AND Site.Site_ID = cCSite ;
		AND Site.Agency_ID = cAgency_ID ;
		AND ConSD.Ser_Type = SerType.Code ;
 		AND SerType.Followup ;
  	INTO CURSOR tTemp1	;
  	ORDER BY 4
  
SELECT RECNO() AS nRecNo, * ;
	FROM tTemp1 ;
	INTO CURSOR tTemp2
 
Use In tTemp1
  	
SELECT Act_ID, MIN(nRecNo) AS nMinRecNo ;
 	FROM tTemp2 ;
 	INTO CURSOR tMinRecno ;
 	GROUP BY Act_ID
  	
SELECT tTemp2.* ;
  	FROM tTemp2, tMinRecno ;
 	WHERE tTemp2.nRecno = tMinRecno.nMinRecno ;
 	INTO CURSOR tTemp3

Use In tTemp2
Use In tMinRecno

SELECT Contract, Serv_Cat, Enc_id, Service_id, Act_Loc, COUNT(Act_ID) AS NumbofAct;
	FROM tTemp3 ;
	GROUP BY 1, 2, 3, 4, 5 ;
	INTO CURSOR tTemp4 
	
Use In tTemp3

SELECT tTemp4.Contract, tTemp4.Serv_Cat, ;
         tTemp4.Enc_id, tTemp4.Service_id, ;
          ContrInf.Descript AS ContrDesc, ;
         Serv_Cat.Descript AS CatDesc, ;
         lv_Enc_Type.Descript AS EncDesc, ;
         lv_Service.service AS ServDesc, ;
         Serv_Loc.Descript AS LocDesc, ;
         NumbofAct, ;
         cMonthYear as cMonthYear, ;
         cDate  as cDate, ;
         cTime  as cTime, ;
         cAgc_Name as cAgc_Name ;
   FROM tTemp4, ;
          ContrInf, ;   
         Serv_Cat, ;
         lv_Enc_Type, ;
         lv_Service, ;
         Serv_Loc ; 
   WHERE tTemp4.Contract = ContrInf.Cid ;
      AND tTemp4.Serv_Cat = Serv_Cat.Code ;
      AND tTemp4.Serv_Cat = lv_Enc_Type.Serv_Cat ;
      AND tTemp4.Enc_id = lv_Enc_Type.enc_id ;
      AND tTemp4.Serv_Cat = lv_Service.Serv_Cat ;
      AND tTemp4.Enc_id = lv_Service.Enc_id ;
      AND tTemp4.Service_id = lv_Service.service_id ;
      AND (NOT EMPTY(tTemp4.Act_Loc) AND tTemp4.Serv_Cat = Serv_Loc.Serv_Cat AND tTemp4.Act_Loc = Serv_Loc.Code) ;
UNION ;
SELECT tTemp4.Contract, tTemp4.Serv_Cat, ;
         tTemp4.Enc_id, tTemp4.Service_id, ;
         ContrInf.Descript AS ContrDesc, ;
         Serv_Cat.Descript AS CatDesc, ;
         lv_Enc_Type.Descript AS EncDesc, ;
         lv_Service.service AS ServDesc, ;
         PADR('Location Not Entered',30) AS LocDesc, ;
         NumbofAct, ;
         cMonthYear as cMonthYear, ;
         cDate  as cDate, ;
         cTime  as cTime, ;
         cAgc_Name as cAgc_Name ;         
   FROM tTemp4, ;
          ContrInf, ;
         Serv_Cat, ;
         lv_Enc_Type, ;
         lv_Service ;
   WHERE tTemp4.Contract = ContrInf.Cid ;
   AND tTemp4.Serv_Cat = Serv_Cat.Code ;
      AND tTemp4.Serv_Cat = lv_Enc_Type.Serv_Cat ;
      AND tTemp4.Enc_id = lv_Enc_Type.enc_id ;
      AND tTemp4.Serv_Cat = lv_Service.Serv_Cat ;
      AND tTemp4.Enc_id = lv_Service.Enc_id ;
      AND tTemp4.Service_id = lv_Service.service_id ;
      AND EMPTY(tTemp4.Act_Loc) ;
   INTO CURSOR Final ;
   ORDER BY 1, 2, 3, 4   
 
Use In tTemp4 
   
oApp.Msg2User('OFF')

Select Final
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
                    'Table III - C: Follow-Up Activities' as nulrptnam1 ,;
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
          gcRptName = 'rpt_mhra_act'  
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_act  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_act', 1, 2)
          Endcase
   Endif       
EndIf
*******************************
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
IF USED("Final")
	USE IN ("Final")
ENDIF

RETURN

*******************
FUNCTION Electronic
*******************
SELECT 0
USE mpriiic EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

* now, roll thru final, writing 1 Electronic MPR record per final record, plus a totals record on each break
SELECT Final
GO TOP

sav_cat=catdesc

* initialize totals counters
STORE 0 TO tNumbofAct, gNumbofAct

SCAN
	IF sav_cat <> Final.catdesc
		=BreakCat()
	ENDIF

	SCATTER MEMVAR	
	SELECT mpriiic
	APPEND BLANK
	GATHER MEMVAR
	
* add to totals
	tNumbofAct = tNumbofAct + Final.NumbofAct
	gNumbofAct = gNumbofAct + Final.NumbofAct
	
	SELECT Final
ENDSCAN

=BreakCat()
=BreakEof()

USE IN mpriiic

SELECT Final
GO TOP
RETURN

******************
FUNCTION breakcat
******************
* when service category changes, create a total line, then reinitialize counter, hold area

m.catdesc=sav_cat
m.encdesc='Totals'
m.servdesc=SPACE(55)
m.locdesc=SPACE(30)
m.NumbofAct=tNumbofAct

SELECT mpriiic
APPEND BLANK
GATHER MEMVAR

STORE 0 TO tNumbofAct
sav_cat=Final.catdesc

RETURN

******************
FUNCTION breakeof
******************
* when report ends, create a grand total line

m.catdesc='Report'
m.encdesc='Totals'
m.servdesc=SPACE(55)
m.locdesc=SPACE(30)
m.NumbofAct=gNumbofAct

SELECT mpriiic
APPEND BLANK
GATHER MEMVAR

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
USE mpriiic EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mpriiic
RETURN
