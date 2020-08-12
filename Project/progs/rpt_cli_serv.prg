Parameters            ;
              lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              from_d , ;         && from date
              to_d, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)


LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor


PRIVATE gcHelp
gcHelp = "Clients Served by Program Report Screen"
cDate = DATE()
cTime = TIME()
cTitle = "Clients Served By Program"


PRIVATE nTotProg
nTotProg = 12

* jss, 7/20/04, make following UNION a "UNION ALL", otherwise never counts more than 1 encounter without a service d/t blank serv_id
If Used('Cli_ser')
   Use in Cli_ser
EndIf
If Used('t_serv1')
   Use in t_serv1
EndIf
If Used('t_serv2')
   Use in t_serv2
EndIf

SELECT ;
	cli_cur.tc_id, ;
	Space(35) as full_name, ; 
	cli_cur.id_no, ;
	ai_serv.serv_id, ;
	ai_enc.program, ;
	program.descript, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   from_d as Date_from, ;
   to_d as date_to;
FROM ;
   ai_serv ;
      Inner join cli_cur on ;
         ai_serv.tc_id = cli_cur.tc_id ;
      inner join  ai_enc on ;
        ai_serv.act_id = ai_enc.act_id ;
      AND ai_enc.act_dt >= from_d AND ai_enc.act_dt <= to_d;
      inner join program on ;
         ai_enc.program = program.prog_id ;
WHERE ;
       Iif(!Empty(LCProg), ai_enc.program = TRIM(LCProg), .t.) ;
Into Cursor t_serv1
   
*!*   FROM ;
*!*   	ai_serv, ai_enc, cli_cur, program ;
*!*   WHERE ;
*!*   	ai_serv.tc_id = cli_cur.tc_id ;
*!*   	AND ai_serv.act_id = ai_enc.act_id ;
*!*   	AND ai_enc.act_dt >= from_d AND ai_enc.act_dt <= to_d;
*!*   	AND ai_enc.program = program.prog_id ;
*!*   	AND Iif(!Empty(LCProg), ai_enc.program = TRIM(LCProg), .t.) ;
*!*   Into Cursor t_serv1
   
   
***UNION ALL;

SELECT ;
	cli_cur.tc_id, ;
	Space(35) as full_name,;
	cli_cur.id_no, ;
	SPACE(10) as serv_id, ;
	ai_enc.program, ;
	program.descript, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   from_d as Date_from, ;
   to_d as date_to;
FROM ;
	ai_enc, cli_cur, program ;
WHERE ;
	ai_enc.tc_id = cli_cur.tc_id ;
	AND ai_enc.program = program.prog_id ;
	AND ai_enc.act_dt >= from_d AND ai_enc.act_dt <= to_d;
	AND ai_enc.act_id NOT IN (SELECT distinct act_id FROM ai_serv) ;
   AND Iif(!Empty(LCProg), ai_enc.program = TRIM(LCProg), .t.) ;
Into Cursor t_serv2

*   AND ai_enc.program = TRIM(LCProg) ;

Select * ;
from t_serv1;
union all ;
Select * ;
from t_serv2;
INTO CURSOR ;
	cli_ser
	
INDEX ON tc_id TAG tc_id

Use in t_serv1
Use in t_serv2

If Used("Mycliprog")
   Use in Mycliprog
EndIf

oApp.ReopenCur('Cli_ser', 'Mycliprog')

If Used('t_name')
   Use in t_name
EndIf

If Used('t_id')
   Use in t_id
EndIf
   
Select distinct ;
        Mycliprog.tc_id ;
from Mycliprog ;
into cursor t_id
 
      
Select t_id.*, ;        
      oApp.FormatName(cli_cur.last_name,cli_cur.first_name) as full_name;
From t_id ;      
  inner join cli_cur on ;
         t_id.tc_id = cli_cur.tc_id ;   
Into Cursor t_name
      
 
 **VT 10/24/2008 Dev Tick 4622 Add Upper
         
Update Mycliprog ;
   Set full_name = Upper(t_name.full_name)  ;
from Mycliprog ;
      inner join t_name on ;
         Mycliprog.tc_id = t_name.tc_id ;
   
Select Mycliprog   
Go top        
INDEX ON program TAG program ADDITIVE
SET ORDER TO

Use in t_name
Use in t_id

If Used("Cli_ser")
   Use in Cli_ser
EndIf


SELECT ;
	program, descript, ;
	COUNT(DIST tc_id) as counter;
FROM Mycliprog;
GROUP BY 1, 2  ;
INTO CURSOR Myprog1

If Used('Myprog')
      Use in Myprog
EndIf
      
SELECT ;
   Myprog1.*, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   from_d as Date_from, ;
   to_d as date_to;
FROM Myprog1;
INTO CURSOR Myprog

INDEX ON PROGRAM TAG PROGRAM
SET ORDER TO

Use in ("Myprog1")

DIMENSION aProgarr[1,2]

SELECT DISTINCT ;
	Myprog.program, Myprog.descript;
FROM ;
	Myprog;
INTO ARRAY aProgarr

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

m.cnote = ""

IF ALEN(aProgarr,1) > nTotProg
   m.cnote = "NOTE: Please select the following programs exclusively for detailed information ";
	+ "as lack of space prevented reporting on them:"+CHR(13)
   FOR z = 12 TO ALEN(aProgarr,1)
		m.cnote = m.cnote + ALLTRIM(aProgarr[z,1]) + ' - ' + ;
					ALLTRIM(aProgarr[z,2]) + IIF(z = ALEN(aProgarr,1), ".", ", ")
   ENDFOR
ENDIF

If Used('t_prg')
   Use in t_prg
EndIf

On Error
   
Select DISTINCT ;
        full_name, ;
        tc_id, ;
        id_no ;
from Mycliprog ;
Into Cursor t_prg

If _Tally = 0
    oApp.msg2user('NOTFOUNDG')
    Return
Endif    
 
If Used('Cur_count')
   Use in Cur_count
EndIf 

*!* 06/25/2006 PB Entered Cast() for description fields             
Select t_prg.*, ;
	000000 as prog1,;
	000000 as prog2,;
	000000 as prog3,;
	000000 as prog4,;
	000000 as prog5,;
	000000 as prog6,;
	000000 as prog7,;
	000000 as prog8,;
	000000 as prog9,;
	000000 as prog10,;
	000000 as prog11,;
	000000 as prog12,;
   Cast(cLegOneA As Memo) as cLegOneA, ;
   Cast(cLegOneB As Memo) as cLegOneB, ;
   Cast(cLegTwoA As Memo) as cLegTwoA, ;
   Cast(cLegTwoB As Memo) as cLegTwoB, ;
   Cast(cLegThrA As Memo) as cLegThrA, ;
   Cast(cLegThrB As Memo) as cLegThrB, ;
   Iif(ALEN(aProgarr,1) >= 1, aProgarr[1,1], '') as lcprg1, ;
   Iif(ALEN(aProgarr,1) >= 2, aProgarr[2,1], '') as lcprg2, ;
   Iif(ALEN(aProgarr,1) >= 3, aProgarr[3,1], '') as lcprg3, ;
   Iif(ALEN(aProgarr,1) >= 4, aProgarr[4,1], '') as lcprg4, ;
   Iif(ALEN(aProgarr,1) >= 5, aProgarr[5,1], '') as lcprg5, ;
   Iif(ALEN(aProgarr,1) >= 6, aProgarr[6,1], '') as lcprg6, ;
   Iif(ALEN(aProgarr,1) >= 7, aProgarr[7,1], '') as lcprg7, ;
   Iif(ALEN(aProgarr,1) >= 8, aProgarr[8,1], '') as lcprg8, ;
   Iif(ALEN(aProgarr,1) >= 9, aProgarr[9,1], '') as lcprg9, ;
   Iif(ALEN(aProgarr,1) >= 10, aProgarr[10,1], '') as lcprg10, ;
   Iif(ALEN(aProgarr,1) >= 11, aProgarr[11,1], '') as lcprg11, ;
   Iif(ALEN(aProgarr,1) >= 12, aProgarr[12,1], '') as lcprg12, ;
   Iif(ALEN(aProgarr,1) >= 1, ALLTRIM(PADR(aProgarr[1,1],5)), '') as lcprgcode1,;
   Iif(ALEN(aProgarr,1) >= 2, ALLTRIM(PADR(aProgarr[2,1],5)), '') as lcprgcode2,;
   Iif(ALEN(aProgarr,1) >= 3, ALLTRIM(PADR(aProgarr[3,1],5)), '') as lcprgcode3,;
   Iif(ALEN(aProgarr,1) >= 4, ALLTRIM(PADR(aProgarr[4,1],5)), '') as lcprgcode4,;
   Iif(ALEN(aProgarr,1) >= 5, ALLTRIM(PADR(aProgarr[5,1],5)), '') as lcprgcode5,;
   Iif(ALEN(aProgarr,1) >= 6, ALLTRIM(PADR(aProgarr[6,1],5)), '') as lcprgcode6,;
   Iif(ALEN(aProgarr,1) >= 7, ALLTRIM(PADR(aProgarr[7,1],5)), '') as lcprgcode7,;
   Iif(ALEN(aProgarr,1) >= 8, ALLTRIM(PADR(aProgarr[8,1],5)), '') as lcprgcode8,;
   Iif(ALEN(aProgarr,1) >= 9, ALLTRIM(PADR(aProgarr[9,1],5)), '') as lcprgcode9,;
   Iif(ALEN(aProgarr,1) >= 10, ALLTRIM(PADR(aProgarr[10,1],5)), '') as lcprgcode10,;
   Iif(ALEN(aProgarr,1) >= 11, ALLTRIM(PADR(aProgarr[11,1],5)), '') as lcprgcode11,;
   Iif(ALEN(aProgarr,1) >= 12, ALLTRIM(PADR(aProgarr[12,1],5)), '') as lcprgcode12, ;
   000000 as lncount, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   from_d as Date_from, ;
   to_d as date_to ,;
   Cast(cnote as Memo) as cnote ;
FROM t_prg;
INTO CURSOR Cur_count READWRITE

REPLACE Cur_count.cNote WITH m.cNote ALL
GO TOP

 **VT 10/24/2008 Dev Tick 4622 Add Upper
INDEX ON Upper(full_name) TAG full_name

**   cnote as cnote, ;

Use in t_prg


If Used('Mycount')
   Use in Mycount
EndIf
   
SELECT 0
USE (DBF('Cur_count')) ALIAS Mycount AGAIN EXCLUSIVE

If Used('Cur_count')
   Use in Cur_count
EndIf
   
SELECT Mycount
 **VT 10/24/2008 Dev Tick 4622 
Set Order to full_name

GO TOP
SCAN
	FOR i= 1 TO MIN(ALEN(aProgarr,1), nTotProg)
		IF !EMPTY(aProgarr[i,1])
			SELECT Mycliprog
			STORE 0 TO COUNT
			COUNT FOR Mycliprog.tc_id = Mycount.tc_id and ;
				Mycliprog.program = aProgarr[i,1] TO m.count

			SELECT Mycount
			REPL ("Mycount.prog"+ALLTRIM(STR(i))) WITH m.count
		ENDIF
	EndFor
   ncount = GetCount()
   Replace lncount with ncount
   SELECT Mycount
ENDSCAN

If Used("Mycliprog")
   Use in ("Mycliprog")
EndIf


oApp.msg2user('OFF')

Do Case
   Case lnStat = 1
     gcRptName = 'rpt_cli_ser'
     Select MyProg
     Go Top

     If Eof()
        oApp.msg2user('NOTFOUNDG')
     
     Else
        Do Case
           Case lPrev = .f.
              Report Form rpt_cli_ser To Printer Prompt Noconsole NODIALOG
              
           Case lPrev = .t.     
              oApp.rpt_print(5, .t., 1, 'rpt_cli_ser', 1, 2)
              
        EndCase
      EndIf
        
   Case lnStat = 2   &&Detail
         gcRptName = 'rpt_cli_serd'
         SELECT Mycount
         Go Top
         if EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
                 Do Case
                     CASE lPrev = .f.
                          Report Form rpt_cli_serd To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_cli_serd', 1, 2)
                 EndCase
         Endif 
 EndCase

*****************************************************
FUNCTION GetCount
PRIVATE ncount,cfield
cfield = ""
ncount = 0
FOR i = 1 TO nTotProg
	cfield="Mycount.prog"+ALLTRIM(STR(i))
	IF !EMPTY(&cfield)
		ncount = ncount+1
	ENDIF
EndFor
RETURN(ncount)


