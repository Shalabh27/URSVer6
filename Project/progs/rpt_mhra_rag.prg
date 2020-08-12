*  Program...........: SUMMREFT.PRG (Summary of Referrals for the Reporting Month)
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
m.Date_from = Date_from
m.Date_to = Date_to

m.ContrDes = ''
=OPENFILE("Contrinf")

SELECT Contrinf
Locate For Contrinf.Cid = cContract
m.ContrDes =Contrinf.Descript

* MHRA decided that the agency would be responsible for establishing an MHRA program,
* that would be included only in one contract.

SELECT DIST Contract.Con_ID AS Contract, Ai_Ref.Tc_ID, Ai_Ref.Act_ID, ;
			Ai_Ref.Ref_ID, Ai_Enc.Program, ;
			ContrInf.Descript AS ContrDes, ;
			Ai_Ref.Ref_Cat, Ai_Ref.Ref_For, Ai_Ref.Ref_To ;
	FROM Ai_Ref, ;
		Ai_Enc, ;
		Program, ;
		Contract, ;
		ContrInf, ;
		Ai_Site, ;
		Site ;
	WHERE Contract.Con_ID = cContract ;
			AND Contract.Start_dt <= m.Date_from ;
			AND Contract.End_dt   >= m.Date_to ;
			AND Ai_Ref.Act_ID = Ai_Enc.Act_ID ;
			AND Ai_Ref.Tc_ID = Ai_Enc.Tc_ID ;
   		AND Ai_Enc.Program = Program.Prog_ID ;
   		AND Ai_Enc.Program = Contract.Program ;
   		AND Program.Aar_Report ;
   		AND Ai_Ref.Ref_Dt BETWEEN m.Date_From AND m.Date_To ;
		AND Ai_Enc.Tc_ID = Ai_Site.Tc_ID ;
	    AND Site.Site_ID = Ai_Site.Site ;
	    AND Site.Site_ID = cCSite ;
		AND Site.Agency_ID = cAgency_ID ;
		AND Contract.Con_ID = Contrinf.Cid ;
  INTO CURSOR tTemp1

SELECT Contract, Ref_To, Ref_Cat, Ref_For, ;
			ContrDes, COUNT(DIST Tc_ID) AS NumbofCli, COUNT(Ref_ID) AS NumbofRef ;
	FROM tTemp1 ;		
	INTO CURSOR tTemp2 ;
	GROUP BY 1, 2, 3, 4 , 5

SELECT  a.ContrDes, d.Name, ;
		b.Descript AS RefCatDesc, c.Descript AS RefForDesc, ;
		a.Contract, a.Ref_To, a.Ref_Cat, a.Ref_For, ;
		a.NumbofCli, a.NumbofRef ;
	FROM tTemp2 A, ;		
		 Ref_Cat B, ;
		 Ref_For C, ;
		 Ref_Srce D ;
	WHERE a.Ref_Cat = b.Code ;
		AND a.Ref_Cat = c.Category ;
		AND a.Ref_For = c.Code ;
		AND a.Ref_To = d.Code ;
	INTO CURSOR tTemp3
   
SELECT tTemp3.*, ;
         cMonthYear as cMonthYear, ;
         cDate  as cDate, ;
         cTime  as cTime, ;
         cAgc_Name as cAgc_Name ;  
	FROM tTemp3 ;		
UNION ;		
SELECT  a.ContrDes, PADR('',30,'z') AS Name, ;
      	b.Descript AS RefCatDesc, c.Descript AS RefForDesc, ;
		   a.Contract, SPACE(5) AS Ref_To, a.Ref_Cat, a.Ref_For, ;
		   a.NumbofCli, a.NumbofRef, ;
         cMonthYear as cMonthYear, ;
         cDate  as cDate, ;
         cTime  as cTime, ;
         cAgc_Name as cAgc_Name ;  
	FROM tTemp2 A, ;		
		 Ref_Cat B, ;
		 Ref_For C ;
	WHERE a.Ref_Cat = b.Code ;
		AND a.Ref_Cat = c.Category ;
		AND a.Ref_For = c.Code ;
		AND a.Ref_To NOT IN (SELECT Ref_To FROM tTemp3) ;
	INTO CURSOR Final ; 
	ORDER BY 1, 2, 3, 4		


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
                    'Table III - E: Summary of Referrals for the Month by Agency' as nulrptnam1 ,;
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

          gcRptName = 'rpt_mhra_rag'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_rag  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_rag', 1, 2)
          Endcase
   Endif       
EndIf
*******************
Function clean_data

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

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
* jss, 5/14/04, add code here to write to electronic mpr table (mpriiie.dbf)

SELECT 0
USE mpriiie EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

STORE 0 TO tNumbofCli, tNumbofRef, bNumbofCli, bNumbofRef

* now, roll thru tfinal, writing 1 Electronic MPR record per tfinal record
SELECT Final
GO TOP
bref_to=Final.ref_to

SCAN
	SCATTER MEMVAR	
	
	IF m.ref_to<>bref_to
		=BreakRef()
	ENDIF

* define another memvar
	m.name=IIF(m.Name<>PADR('',30,'z'),m.Name, 'Unknown')

* add to "break on ref_to" counters
	bNumbofCli=bNumbofCli + m.NumbofCli
	bNumbofRef=bNumbofRef + m.NumbofRef

	tNumbofCli=tNumbofCli + m.NumbofCli
	tNumbofRef=tNumbofRef + m.NumbofRef
	
	SELECT Final
ENDSCAN

* write final break line
=BreakRef()

* write report total line

m.name='Report Totals'
m.NumbofCli=tNumbofCli
m.NumbofRef=tNumbofRef

SELECT mpriiie
APPEND BLANK
GATHER MEMVAR

USE IN mpriiie

SELECT Final
GO TOP
RETURN

*****************
FUNCTION BreakRef
*****************
* write a detail line to electronic mpr dbf
m.NumbofCli=bNumbofCli
m.NumbofRef=bNumbofRef

SELECT mpriiie
APPEND BLANK
GATHER MEMVAR
		
* reset vars and break counters
m.NumbofCli=Final.NumbofCli
m.NumbofRef=Final.NumbofRef

STORE 0 TO bNumbofCli, bNumbofRef

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
USE mpriiie EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mpriiie
RETURN
