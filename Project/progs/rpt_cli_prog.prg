Parameters lPrev,;     && Preview     
           aSelvar1,;  && select parameters from selection list
           nOrder,;    && order by
           nGroup,;    && report selection    
           lcTitle,;   && report selection    
           Date_from,; && from date
           Date_to,;   && to date   
           Crit,;      && name of param
           lnStat,;    && selection(Output)  page 2
           cOrderBy    && order by description 

Acopy(aSelvar1, aSelvar2)

noldarea57=Select()

cCWork = ""
LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      cCWork = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gchelp
gchelp = "Client Listing by Program Screen"
cDate = DATE()
cTime = TIME()
cTitle = "Client Listing by Program"
As_Of_D = Date_from

*!*   SELECT cli_cur.*  ,;
*!*   	SPACE(5)   AS WORKER   ,;
*!*   	SPACE(5)   AS SITE     ,;
*!*   	SPACE(30)  AS Sitename ,;
*!*   	SPACE(30)  AS Workname ,;
*!*   	{}         AS SERDT    ,;
*!*   	SPACE(7)   AS CaseOpen ,;
*!*   	.F.        AS firstrec, ;
*!*      lcTitle as lcTitle, ;
*!*      Crit as Crit, ;   
*!*      cDate as cDate, ;
*!*      cTime as cTime, ;
*!*      Date_from as as_of_D ;
*!*   FROM ;
*!*   	cli_cur,ai_clien;
*!*   WHERE ;
*!*   	cli_cur.client_id = ai_clien.client_id AND ;
*!*   	ai_clien.placed_dt <= As_Of_D  ;
*!*   INTO CURSOR ;
*!*   	ClAlfaR

*!* No need to go to ai_clien for palced_dt, its now in cli_cur
SELECT cli_cur.*,;
   SPACE(05) AS WORKER,;
   SPACE(05) AS SITE,;
   SPACE(30) AS Sitename,;
   SPACE(30) AS Workname,;
   {} AS SERDT,;
   SPACE(07) AS CaseOpen,;
   .F. AS firstrec,;
   lcTitle As lcTitle,;
   Crit As Crit,;   
   cDate As cDate,;
   cTime As cTime,;
   Date_from As as_of_D,;
   Padr(Upper(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)),25) AS name4sorting,;
   Padr(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi),25) AS name4showing,;
   Space(250) As address2show;
FROM ;
   cli_cur;
WHERE ;
   placed_dt <= As_Of_D  ;
INTO CURSOR ClAlfaR Readwrite 

Select ClAlfaR
Scan 
   If !Empty(ClAlfaR.addr_id)
      m.cmAddress=oapp.format_address(ClAlfaR.addr_id)
      Replace address2show With m.cmAddress
   EndIf
EndScan 

Go Top 

************************  Opening Tables ************************************
*!*   If Used("ai_site")   
*!*      Use in ai_site
*!*   Endif 

*!*   If Used("ai_clien")   
*!*      Use in ai_clien
*!*   Endif 

=OPENFILE("staff"	,"staff_id")
=OPENFILE("userprof"	,"worker_id")
Set Relation To
SET RELATION To staff_id INTO staff

***=OPENFILE("Site",		"site_id")
=OPENFILE("Address","client_id")

*=OPENFILE("Cli_hous","Client_id")
*SET FILTER TO lives_in
*SET RELATION TO hshld_id INTO ADDRESS

=OPENFILE("AI_enc","Tc_id_act")
Set relation to
SET FILTER TO !EMPTY(AI_enc.act_dt)

=OPENFILE("Ai_clien","TC_ID")
Set Relation to
SET RELATION TO tc_id INTO AI_enc ADDITIVE

=OPENFILE("SITE"  ,"SITE_ID")

**VT 03/26/2008 Dev Tick 4186
**=OPENFILE("AI_SITE"  ,"TC_ID")
=OPENFILE("AI_SITE"  ,"TC_ID DESC")
Set Relation to
SET RELATION TO SITE INTO SITE

=OPENFILE("AI_PROG"  ,"TC_ID2 DESC")
=OPENFILE("AI_WORK"  ,"TC_ID2 DESC")

* grab enrollments
* jss, 9/4/01, now, just get everybody enrolled in program as of As_Of_D

**VT 08/26/2010 DEv Tick 5136 add ps_id 
SELECT DIST ;
	ai_prog.ps_id,;
	ai_prog.program,;
	program.descript,;
	program.enr_req,;
	ai_prog.start_dt,;
	ai_prog.end_dt,;
	ClAlfaR.*;
FROM;
	ClAlfaR,;
	ai_prog,;
	program;
WHERE;
	lcprog = ai_prog.program AND ;
	ClAlfaR.tc_id = ai_prog.tc_id AND ;
	ai_prog.program = program.prog_id AND	;
	ai_prog.start_dt <= As_Of_D AND	;
	(EMPTY(ai_prog.end_dt) OR ai_prog.end_dt >= As_Of_D) ;
INTO CURSOR ;
	ClProg1

*!*   If Used("ai_prog")
*!*      Use in ("ai_prog")
*!*   Endif 

**VT 08/26/2010 DEv Tick 5136 add ps_id
* grab intakes (for programs with no enrollment required)

SELECT ;
	Space(10) as ps_id,;
	ai_clien.int_prog	AS program,;
	program.descript,;
	program.enr_req,;
	ai_clien.placed_dt AS start_dt,;
	{}	AS end_dt,;
	ClAlfaR.*;
FROM;
	ClAlfaR,;
	ai_clien,;
	program;
WHERE;
	ai_clien.int_prog = lcprog AND ;
	ClAlfaR.tc_id = ai_clien.tc_id AND ;
	ai_clien.int_prog = program.prog_id AND	;
	ai_clien.int_compl AND ;
	ai_clien.placed_dt <= As_Of_D AND ;
	!program.enr_req;
INTO CURSOR;
	ClProg2

Use in ClAlfaR
** here, we must combine the enrolled clients with the clients intaken into programs that don't require enrollment
If Used("ClProg")
   Use in ("ClProg")
EndIf

SELECT * ;
FROM ;
	ClProg1 ;
UNION ;
SELECT * ;
FROM ;
	ClProg2 ;
WHERE ;
	(ClProg2.program + ClProg2.tc_id) ;
		NOT IN 	(SELECT program + tc_id FROM ClProg1) ;		
INTO CURSOR ;
	ClProg
	
If Used('MyClient')
   Use in MyClient
EndIf

SELECT 0
USE (DBF('ClProg')) ALIAS MyClient AGAIN EXCLUSIVE

If Used("ClProg")
   Use in ("ClProg")
EndIf

If Used("ClProg1")
   Use in ("ClProg1")
EndIf

If Used("ClProg2")
   Use in ("ClProg2")
EndIf

SELE MyClient

*****   CASEOPEN  ******
***REPL MyClient.caseopen WITH IIF(oApp.IsItOpe2(MyClient.TC_ID, As_Of_D),"Open   ","Closed ") all
*****   CASEOPEN  ******
If Used('ClOpenStat')
   Use in ClOpenStat
EndIf

If Used('t_id')
   Use in t_id
EndIf

Select Distinct tc_id ;
from MyClient ;
Into Cursor t_id

SELECT Distinct ;
   t_id.Tc_id, ;
   Iif(statvalu.incare, "Open   ","Closed ") as caseopen;
FROM ;
   t_id, ai_activ, statvalu ;
WHERE ;
   t_id.Tc_id = ai_activ.tc_id AND ;
   ai_activ.status = statvalu.code AND ;
   statvalu.tc = gcTC AND ;
   statvalu.type = 'ACTIV' AND ;
   ai_activ.tc_id + DTOS(ai_activ.effect_dt) + oapp.time24(ai_activ.time,ai_activ.am_pm)  ;
               IN (SELECT ;
                     T1.tc_id + MAX(DTOS(T1.effect_dt)+oapp.time24(T1.time, T1.am_pm)) ;
                  FROM ;
                     ai_activ T1 ;
                  WHERE ;
                     T1.effect_dt <= As_Of_D ;
                  GROUP BY ;
                     T1.tc_id)      ;
INTO CURSOR ;
   ClOpenStat

Use in t_id

Update MyClient ;
      Set caseopen = ClOpenStat.caseopen ;
From  MyClient ;
      inner join  ClOpenStat on ;
         ClOpenStat.tc_id = MyClient.tc_id   

If Used('ClOpenStat')
   Use in ClOpenStat
EndIf

Select Myclient
Go Top

Scan
*****   SITE   ******
   IF SEEK(MyClient.TC_ID,   "AI_SITE")
      REPL SITE WITH Ai_SITE.SITE
      REPL Sitename WITH site.descript1
   ENDIF

***** WORKER ******
**VT 08/26/2010 DEv Tick 5136 add ps_id  
*!*	   IF SEEK(MyClient.TC_ID+Myclient.program,   "Ai_WORK")
*!*	      REPL WORKER WITH Ai_WORK.WORKER_ID
*!*	      IF SEEK(MyClient.WORKER,   "userprof")
*!*	         REPL Workname WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first))
*!*	      ENDIF
*!*	   ENDIF

	   cPs_ID = myClient.ps_id
		
   SELECT top 1 worker_id;
	   FROM ai_work t1;
	WHERE ps_id = cPs_ID and;
	      t1.effect_dt <= As_Of_D;
	into cursor t_work;
	order by effect_dt desc
				         
   If _tally >0				         
	   Select Myclient			         
	   REPL WORKER WITH t_work.WORKER_ID  
	 
	   IF SEEK(MyClient.WORKER,   "userprof")
          REPL Workname WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first))
      ENDIF			
	Endif
  
   Select Myclient
   
	*****   LAST DATE SERVICES PROVIDED  ******
	If SEEK(MyClient.TC_ID,	"Ai_ENC")
      SELE Ai_Enc
      LOCATE FOR Ai_Enc.Program = MyClient.program WHILE Ai_Enc.Tc_ID = MyClient.Tc_ID AND NOT EOF()
	   SELE MyClient
		IF FOUND('AI_ENC')
			REPL MyClient.SERDT WITH Ai_ENC.ACT_DT
		EndIf 
	EndIf 
EndScan

MyFilt = "CASEOPEN = 'Open'"
MyFilt = MyFilt + IIF(EMPTY(cCWork)	,""," and WORKER=cCWork")

If Used('temp')
   Use In temp
EndIf

DO CASE
CASE nGroup = 1 							&& No grouping
	SELECT ;
		MyClient.* , ;
		SPACE(30) AS column1 , ;
		MyClient.workname AS column2 ;
	FROM ;
		MyClient ;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
		 temp
	
	*lcTitle = " "
CASE nGroup = 2 							&& Site Name group
	SELECT ;
		MyClient.*, ;
		MyClient.sitename AS column1, ;
		MyClient.workname AS column2 ;
	FROM ;
		MyClient ;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
		 temp
	
	*lcTitle = "Site = "
CASE nGroup = 3								&& Worker Name group
	SELECT ;
		MyClient.*,;
		MyClient.workname AS column1,;
		MyClient.sitename AS column2;
	FROM ;
		MyClient;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
   temp

	*lcTitle = "Worker = "
ENDCASE

**VT 10/23/2009 Dev Tick 5142
*!*   DO CASE
*!*   CASE nOrder = 1
*!*   	SELECT * FROM tempt INTO CURSOR temp ORDER BY descript, column1, LAST_NAME, FIRST_NAME
*!*      
*!*   CASE nOrder = 2
*!*   	SELECT * FROM tempt INTO CURSOR temp ORDER BY descript, column1, ID_NO
*!*        
*!*   CASE nOrder = 3	
*!*   	SELECT * FROM tempt INTO CURSOR temp ORDER BY descript, column1, zip, LAST_NAME, FIRST_NAME
*!*       
*!*   ENDCASE

****=OPENFILE("AI_Clien","TC_ID")
****=OPENFILE("userprof","worker_id")
SELECT MyClient
USE
USE (DBF('TEMP')) ALIAS MyClient AGAIN EXCLUSIVE

If Used("temp")
     Use in ("temp")
EndIf

If Used('tprg_tot')
   Use in tprg_tot
EndIf
   
SELE MyClient

**VT 10/23/2009 Dev Tick 5142
Do Case
   Case nOrder = 1
        Index On descript+column1+name4sorting Tag col1
        Set Order To col1
   Case nOrder = 2
      Index On descript+column1+id_no Tag col1
      Set Order To col1
   Case nOrder = 3   
     Index On descript+column1+zip+name4sorting Tag col1
      Set Order To col1
EndCase

Set Relation To TC_ID Into Ai_CLIEN ADDITIVE
Set Relation To worker Into userprof ADDITIVE

Select program, ;
	count(*) as tot ;
From myclient;
Into Cursor	tprg_tot	;
Group By program

Index on program tag program

oApp.reopencur('tprg_tot', 'prg_tot', .t.)
Set Order to tag program

If Used("tprg_tot")
   Use in ("tprg_tot")
EndIf

Select count(*) as tot_cl ;
From myclient;
Into Cursor	total

Select MyClient
Set Rela to program into prg_tot Additive
GO TOP
*** scan will assign first record of each person 
cSaveTC_ID = Space(10)
Scan 
	If tc_id <> cSaveTC_ID
		Replace firstrec With .T.
		cSaveTC_ID = tc_id
	EndIf
EndScan

oApp.msg2user("OFF")
gcRptName = 'rpt_cli_prog'

Select MyClient
Go Top

If Eof()
   oApp.msg2user('NOTFOUNDG')
Else 
   Do Case
      Case lPrev = .f.
         Report Form rpt_cli_prog  To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.    
         oApp.rpt_print(5, .t., 1, 'rpt_cli_prog', 1, 2)
  EndCase 
EndIf 

**Use in MyClient

Select userprof
Set Relation to

Select ai_clien
Set Relation to

Select AI_SITE
Set Relation to

Select(noldarea57)