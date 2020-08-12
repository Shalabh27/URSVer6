Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)
lcProg    = ""
cNote     = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gcHelp
gcHelp = "Problems Identified Summary Report by Program Screen"
cDate = DATE()
cTime = TIME()
LCProg = ALLTRIM(LCProg)

=openfile("program","prog_id")

Local cWhere
cWhere = ''
cWhere = IIF(EMPTY(lcProg),""," AND ai_enc.program  = lcProg")

SELECT ;
	ai_PRENC.PROBLEM,ai_enc.program,ai_enc.serv_cat,;
	ai_enc.enc_id,;
	program.descript AS progdesc,PROBLEMS.descript AS PROBdesc,;
	serv_cat.descript AS catdesc,enc_list.description AS encdesc ;
FROM ;
	ai_PRENC, ai_enc, serv_cat, PROBLEMS, enc_list, program ;
WHERE ;
	ai_PRENC.act_id = ai_enc.act_id ;
	AND BETWEEN(ai_enc.act_dt, date_from,date_to);
	AND ai_enc.program  = program.prog_id;
	AND ai_enc.serv_cat = serv_cat.code;
   AND ai_enc.enc_id = enc_list.enc_id;
	AND ai_PRENC.problem = PROBLEMS.code;
   &cWhere ;
INTO CURSOR ;
	ENC_PRENC

SELECT 0
USE (DBF('Enc_Prenc')) ALIAS Prenc AGAIN EXCLUSIVE

If Used('Enc_Prenc')
   Use in Enc_Prenc
EndIf
   
DIMENSION aProgarr[1,1]

SELECT DISTINCT ;
	Prenc.program,Prenc.progdesc;
FROM Prenc;
INTO ARRAY ;
	aProgarr


IF ALEN(aProgarr,1) > 12
	cNote = cNote + chr(13) + ;
		"WARNING: Please select the following programs exclusively for detailed information" + ;
		" as lack of space prevented reporting on these programs:"+CHR(13)
	FOR z = 13 TO ALEN(aProgarr,1)
		cNote = cNote+ALLTRIM(aProgarr[z,2])+IIF(z = ALEN(aProgarr,1)," ."," ,")
	ENDFOR
ENDIF

* create a program legend
cLegOneA = ''
cLegOneB = ''
cLegTwoA = ''
cLegTwoB = ''
cLegThrA = ''
cLegThrB = ''

nUpTo = _tally/3 + iif(MOD(_tally,3)=0,0,1)

FOR i= 1 TO nUpTo

	cLegOneA = cLegOneA + padr(aProgarr[(3*i)-2,1],7) + chr(13)
	cLegOneB = cLegOneB + '-' + aProgarr[(3*i)-2,2] + chr(13)

	IF (3*i) -1 <= _tally
		cLegTwoA = cLegTwoA + padr(aProgarr[(3*i)-1,1],7) + chr(13)
		cLegTwoB = cLegTwoB + '-' + aProgarr[(3*i)-1,2] + chr(13)
	ENDIF

	IF (3*i) <= _tally
		cLegThrA = cLegThrA + padr(aProgarr[(3*i),1],7) + chr(13)
		cLegThrB = cLegThrB + '-' + aProgarr[(3*i),2] + chr(13)
	ENDIF
ENDFOR

* remove last chr(13)
cLegOneA = LEFT(cLegOneA, LEN(cLegOneA) - 1)
cLegOneB = LEFT(cLegOneB, LEN(cLegOneB) - 1)
cLegTwoA = LEFT(cLegTwoA, LEN(cLegTwoA) - 1)
cLegTwoB = LEFT(cLegTwoB, LEN(cLegTwoB) - 1)
cLegThrA = LEFT(cLegThrA, LEN(cLegThrA) - 1)
cLegThrB = LEFT(cLegThrB, LEN(cLegThrB) - 1)

*
SELECT DISTINCT ;
	Prenc.serv_cat, Prenc.enc_id, Prenc.problem,;
	Prenc.probdesc, Prenc.catdesc, Prenc.encdesc,;
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
	000000 AS prog12, ;
   cNote as cNote, ;
   cLegOneA as cLegOneA, ;
   cLegOneB as cLegOneB, ;
   cLegTwoA as cLegTwoA, ;
   cLegTwoB as cLegTwoB, ;
   cLegThrA as cLegThrA, ;
   cLegThrB as  cLegThrB, ;
   GetProg(1) as prgcode1,;
   GetProg(2) as prgcode2,;
   GetProg(3) as prgcode3,;
   GetProg(4) as prgcode4,;
   GetProg(5)  as prgcode5,;
   GetProg(6)  as prgcode6,;
   GetProg(7)  as prgcode7,;
   GetProg(8) as prgcode8,;
   GetProg(9) as prgcode9,;
   GetProg(10) as prgcode10,;
   GetProg(11) as prgcode11,;
   GetProg(12) as prgcode12, ;
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
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;  
FROM ;
	Prenc;
INTO CURSOR ;
	Cur_count

If Used('Mycount')
   Use in Mycount
EndIf

SELECT 0
USE (DBF('Cur_count')) ALIAS Mycount AGAIN EXCLUSIVE

If Used('Cur_count')
   Use in Cur_count
EndIf
   
SELECT Mycount
GO TOP
SCAN
	FOR i= 1 TO MIN(ALEN(aProgarr,1), 12)
		IF !EMPTY(aProgarr[i,1])
			SELECT Prenc
			STORE 0 TO COUNT
			COUNT FOR ;
				Prenc.serv_cat = Mycount.serv_cat AND ;
				Prenc.enc_id = Mycount.enc_id AND ;
				Prenc.problem  = Mycount.problem  AND ;
				Prenc.program  = aProgarr[i,1] ;
			TO m.count

			SELECT Mycount
			REPL ("Mycount.prog"+ALLTRIM(STR(i))) WITH m.count
		ENDIF
	ENDFOR
	SELECT Mycount
ENDSCAN

oApp.Msg2User('OFF')

SELECT Mycount

DO CASE
CASE nOrder = 1
	cOrd = "Mycount.serv_cat"
CASE nOrder = 2
	cOrd = "Mycount.serv_cat+Str(Mycount.enc_id)"
CASE nOrder = 3
	cOrd = "Mycount.serv_cat+Str(Mycount.enc_id)+Mycount.problem"
EndCase

INDEX ON &cOrd TAG repord

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
            gcRptName = 'rpt_problem' 
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_problem  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.   
                     oApp.rpt_print(5, .t., 1, 'rpt_problem', 1, 2)
            ENDCASE
EndIf

SET CENT ON

IF USED("Enc_Prenc")
	USE IN ("Enc_Prenc")
ENDIF
IF USED("Prenc")
	USE IN ("Prenc")
ENDIF
IF USED("Cur_count")
	USE IN ("Cur_count")
ENDIF

*****************************************************************
FUNCTION GetProg
PARAMETER nprog

IF nprog > ALEN(aProgarr,1) OR EMPTY(aProgarr[nprog,1])
	RETURN("")
ELSE

	RETURN ALLTRIM(PADR(aProgarr[nProg,1],5))
ENDIF

*****************************************************************
FUNCTION Getcat
PARAMETER ccat
SELECT Serv_cat
SET ORDER TO Code
IF SEEK(ccat)
	RETURN(Serv_cat.descript)
ELSE
	RETURN("")
ENDIF

RETURN
