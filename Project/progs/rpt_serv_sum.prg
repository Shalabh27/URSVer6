Parameters lPrev,;     && Preview     
           aSelvar1,;  && select parameters from selection list
           nOrder,;    && order by
           nGroup,;    && report selection    
           lcTitle,;   && report selection    
           Date_from,; && from date
           Date_to,;   && to date   
           PrN,;       && name of param
           lnStat,;    && selection(Output)  page 2
           cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)
lcProg    = ""
m.cNote    = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gcHelp
gcHelp = "Client Encounter Summary by Program Report Screen"
cTitle = "Services Summary Report By Program"
cDate = DATE()
cTime = TIME()
LCProg = ALLTRIM(LCProg)

If Used('Cli_ser')
   Use in Cli_ser
EndIf


* jss, 10/1/04, in order to prevent orphaned enc/serv recs from being selected, must reference ai_clien table...
*!*   SELECT DISTINCT;
*!*   	ai_serv.tc_id,ai_serv.serv_id,ai_enc.program,ai_enc.serv_cat,;
*!*   	ai_enc.enc_type,ai_serv.service,;
*!*   	program.descript AS progdesc,service.descript AS servdesc,;
*!*   	serv_cat.descript AS catdesc,enc_list.description AS encdesc ;
*!*   FROM ;
*!*   	ai_serv, ai_enc, serv_cat, service, enc_list, program ;
*!*   WHERE ;
*!*   	ai_serv.act_id = ai_enc.act_id ;
*!*   	AND BETWEEN(ai_enc.act_dt, date_from,date_to);
*!*   	AND ai_enc.program  = lcProg;
*!*   	AND ai_enc.program  = program.prog_id;
*!*   	AND ai_enc.serv_cat = serv_cat.code;
*!*      AND ai_enc.enc_id = enc_list.enc_id;
*!*   	AND ai_enc.serv_cat = service.serv_cat;
*!*   	AND (ai_enc.enc_type = service.enc_type OR EMPTY(service.enc_type)) ;
*!*   	AND ai_serv.service = service.code;
*!*   	AND ai_enc.tc_id IN (SELECT tc_id FROM ai_clien) ;
*!*   INTO CURSOR ;
*!*   	Cli_Ser
=openfile("program","prog_id")

Local cWhere
cWhere = ''
cWhere = IIF(EMPTY(lcProg),""," AND ai_enc.program  = lcProg")

SELECT DISTINCT;
   ai_serv.tc_id,ai_serv.serv_id,ai_enc.program,ai_enc.serv_cat,;
   ai_enc.enc_id,ai_serv.service_id,;
   program.descript AS progdesc, serv_list.description AS servdesc,;
   serv_cat.descript AS catdesc,enc_list.description AS encdesc ;
FROM ;
   ai_serv, ai_enc, serv_cat, serv_list, enc_list, program ;
WHERE ;
   ai_serv.act_id = ai_enc.act_id ;
   AND BETWEEN(ai_enc.act_dt, date_from,date_to);
   AND ai_enc.program  = program.prog_id;
   AND ai_enc.serv_cat = serv_cat.code;
   AND ai_enc.enc_id = enc_list.enc_id;
   AND ai_serv.service_id = serv_list.service_id;
   AND ai_enc.tc_id IN (SELECT tc_id FROM ai_clien) ;
   &cWhere ;
INTO CURSOR ;
   Cli_Ser
   

If Used('Mycliprog')
   Use in Mycliprog
EndIf


SELECT 0
USE (DBF('Cli_ser')) ALIAS Mycliprog AGAIN EXCLUSIVE

If Used('Cli_ser')
   Use in Cli_ser
EndIf
   
DIMENSION aProgarr[1,1]


SELECT DISTINCT ;
	Mycliprog.program,Mycliprog.progdesc;
FROM Mycliprog;
INTO ARRAY ;
	aProgarr

m.cNote = "NOTE: Encounters Without Services are NOT included in this report."
IF ALEN(aProgarr,1) > 12
	m.cNote = m.cNote + chr(13) + ;
		"WARNING: Please select the following programs exclusively for detailed information" + ;
		" as lack of space prevented reporting on these programs:"+CHR(13)
	FOR z = 13 TO ALEN(aProgarr,1)
		m.cNote = m.cNote+ALLTRIM(aProgarr[z,2])+IIF(z = ALEN(aProgarr,1)," ."," ,")
	ENDFOR
ENDIF

* create a program legend
m.cLegOneA = ''
m.cLegOneB = ''
m.cLegTwoA = ''
m.cLegTwoB = ''
m.cLegThrA = ''
m.cLegThrB = ''

nUpTo = _tally/3 + iif(MOD(_tally,3)=0,0,1)

FOR i= 1 TO nUpTo

	m.cLegOneA = m.cLegOneA + padr(aProgarr[(3*i)-2,1],7) + chr(13)
	m.cLegOneB = m.cLegOneB + '-' + aProgarr[(3*i)-2,2] + chr(13)

	IF (3*i) -1 <= _tally
		m.cLegTwoA = m.cLegTwoA + padr(aProgarr[(3*i)-1,1],7) + chr(13)
		m.cLegTwoB = m.cLegTwoB + '-' + aProgarr[(3*i)-1,2] + chr(13)
	ENDIF

	IF (3*i) <= _tally
		m.cLegThrA = m.cLegThrA + padr(aProgarr[(3*i),1],7) + chr(13)
		m.cLegThrB = m.cLegThrB + '-' + aProgarr[(3*i),2] + chr(13)
	ENDIF
ENDFOR

* remove last chr(13)
m.cLegOneA = LEFT(m.cLegOneA, LEN(m.cLegOneA) - 1)
m.cLegOneB = LEFT(m.cLegOneB, LEN(m.cLegOneB) - 1)
m.cLegTwoA = LEFT(m.cLegTwoA, LEN(m.cLegTwoA) - 1)
m.cLegTwoB = LEFT(m.cLegTwoB, LEN(m.cLegTwoB) - 1)
m.cLegThrA = LEFT(m.cLegThrA, LEN(m.cLegThrA) - 1)
m.cLegThrB = LEFT(m.cLegThrB, LEN(m.cLegThrB) - 1)


SELECT DISTINCT ;
	Mycliprog.serv_cat, Mycliprog.enc_id, Mycliprog.service_id,;
	Mycliprog.servdesc, Mycliprog.catdesc, Mycliprog.encdesc,;
	000000 AS prog1,  ;
	000000 AS prog2,  ;
	000000 AS prog3,  ;
	000000 AS prog4,  ;
	000000 AS prog5,  ;
	000000 AS prog6,  ;
	000000 AS prog7,  ;
	000000 AS prog8,  ;
	000000 AS prog9,  ;
	000000 AS prog10, ;
	000000 AS prog11, ;
	000000 AS prog12,  ;
   Iif(ALEN(aProgarr,1) >= 1, aProgarr[1,1], '') as prg1, ;
   Iif(ALEN(aProgarr,1) >= 2, aProgarr[2,1], '') as prg2, ;
   Iif(ALEN(aProgarr,1) >= 3, aProgarr[3,1], '') as prg3, ;
   Iif(ALEN(aProgarr,1) >= 4, aProgarr[4,1], '') as prg4, ;
   Iif(ALEN(aProgarr,1) >= 5, aProgarr[5,1], '') as prg5, ;
   Iif(ALEN(aProgarr,1) >= 6, aProgarr[6,1], '') as prg6, ;
   Iif(ALEN(aProgarr,1) >= 7, aProgarr[7,1], '') as prg7, ;
   Iif(ALEN(aProgarr,1) >= 8, aProgarr[8,1], '') as prg8, ;
   Iif(ALEN(aProgarr,1) >= 9, aProgarr[9,1], '') as prg9, ;
   Iif(ALEN(aProgarr,1) >= 10, aProgarr[10,1], '') as prg10, ;
   Iif(ALEN(aProgarr,1) >= 11, aProgarr[11,1], '') as prg11, ;
   Iif(ALEN(aProgarr,1) >= 12, aProgarr[12,1], '') as prg12, ;
   lcTitle as lcTitle, ;
   PrN as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;   
FROM ;
	Mycliprog;
INTO CURSOR ;
	Cur_count READWRITE

  
* BK 10/18/2006
*   cNote as cNote, ;

ALTER TABLE Cur_count ADD COLUMN cNote M
REPLACE Cur_count.cNote WITH m.cNote ALL
GO TOP

**VT 03/03/2008 Dev Tick 4028
*!*      m.cLegOneA as cLegOneA, ;
*!*      m.cLegOneB as cLegOneB, ;
*!*      m.cLegTwoA as cLegTwoA, ;
*!*      m.cLegTwoB as cLegTwoB, ;
*!*      m.cLegThrA as cLegThrA, ;
*!*      m.cLegThrB as  cLegThrB, ;


ALTER TABLE Cur_count ADD COLUMN cLegOneA M
REPLACE Cur_count.cLegOneA WITH m.cLegOneA All
GO TOP

ALTER TABLE Cur_count ADD COLUMN cLegOneB M
REPLACE Cur_count.cLegOneB WITH m.cLegOneB All
GO TOP

ALTER TABLE Cur_count ADD COLUMN cLegTwoA M
REPLACE Cur_count.cLegTwoA WITH m.cLegTwoA All
GO TOP

ALTER TABLE Cur_count ADD COLUMN cLegTwoB M
REPLACE Cur_count.cLegTwoB WITH m.cLegTwoB All
GO TOP

ALTER TABLE Cur_count ADD COLUMN cLegThrA M
REPLACE Cur_count.cLegThrA WITH m.cLegThrA All
GO TOP

ALTER TABLE Cur_count ADD COLUMN cLegThrB M
REPLACE Cur_count.cLegThrB WITH m.cLegThrB All


If Used('Mycount')
   Use in Mycount
EndIf


SELECT 0
USE (DBF('Cur_count')) ALIAS Mycount AGAIN EXCLUSIVE

If Used('Cur_count')
   Use in Cur_count
Endif   
   
SELECT Mycount
GO TOP
SCAN
	FOR i= 1 TO MIN(ALEN(aProgarr,1), 12)
		IF !EMPTY(aProgarr[i,1])
			SELECT Mycliprog
			STORE 0 TO COUNT
			COUNT FOR ;
				Mycliprog.serv_cat = Mycount.serv_cat AND ;
				Mycliprog.enc_id = Mycount.enc_id AND ;
				Mycliprog.service_id  = Mycount.service_id  AND ;
				Mycliprog.program  = aProgarr[i,1] ;
			TO m.count

			SELECT Mycount
			REPL ("Mycount.prog"+ALLTRIM(STR(i))) WITH m.count
		ENDIF
	ENDFOR
	SELECT Mycount
     
ENDSCAN

oApp.Msg2User('OFF')

* 09/24/2007 PB: fixed bug in index expression
Select MyCount 
Do Case
   Case nOrder = 1
   	cOrd = "Mycount.serv_cat"
   Case nOrder = 2
   	cOrd = "Mycount.serv_cat+Cast(Mycount.enc_id As Char(10))"
   Case nOrder = 3
   	cOrd = "Mycount.serv_cat+Cast(Mycount.enc_id As Char(10))+Cast(Mycount.service_id As Char(10))"
EndCase 
Index On &cOrd TAG repord


GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   gcRptName = 'rpt_serv_sum'
   DO CASE
      CASE lPrev = .f.
         Report Form rpt_serv_sum  To Printer Prompt Noconsole NODIALOG 
      CASE lPrev = .t.   
            oApp.rpt_print(5, .t., 1, 'rpt_serv_sum', 1, 2)
   ENDCASE
EndIf
SET CENT ON

IF USED("Mycliprog")
	USE IN ("Mycliprog")
ENDIF
IF USED("Cur_count")
	USE IN ("Cur_count")
ENDIF

