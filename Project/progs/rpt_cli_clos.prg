Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              From_date , ;         && from date
              to_date, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description
              
Acopy(aSelvar1, aSelvar2)

cCSite = ""
cCWork = ""
LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      cCWork = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor


PRIVATE gchelp
gchelp = "Clients Closed in Agency Screen"
cDate = DATE()
cTime = TIME()

dfrom_date = from_date
dto_date = to_date
cTitle = "Clients Closed in Agency"


PRIVATE cSaveTC_ID

*!*   SELECT cli_cur.*  ,;
*!*   	SPACE(5)   AS WORKER    , ;
*!*   	SPACE(5)   AS SITE      , ;
*!*   	SPACE(30)  AS Sitename  , ;
*!*   	SPACE(30)  AS Workname  , ;
*!*   	{}         AS SERDT     , ;
*!*   	SPACE(7)   AS CaseOpen  , ;
*!*   	{}		   AS Effect_dt , ;
*!*   	SPACE(30)  AS intwrkname, ;
*!*   	SPACE(30)  AS intprgdesc, ;
*!*   	.F.        AS firstrec ,  ;
*!*      lcTitle as lcTitle,;   
*!*      Crit as Crit, ;   
*!*      cDate as cDate, ;
*!*      cTime as cTime, ;
*!*      from_date as from_date, ;
*!*      to_date as to_date ;
*!*   FROM ;
*!*   	cli_cur ;
*!*   INTO CURSOR ;
*!*   	ClAlfaR

************************  Opening Tables ************************************
If Used("ai_site")   
   Use in ai_site
Endif  
If Used("ai_clien")   
   Use in ai_clien
Endif 

=OPENFILE("staff"		,"staff_id")
=OPENFILE("userprof"	,"worker_id")
SET RELATION TO staff_id INTO staff

=OPENFILE("Site",		"site_id")
=OPENFILE("Address","client_id")
**=OPENFILE("Cli_hous","Client_id")
**SET FILTER TO lives_in
**SET RELATION TO hshld_id INTO ADDRESS

=OPENFILE("AI_enc","Tc_id_act")
SET FILTER TO !EMPTY(AI_enc.act_dt)
=OPENFILE("Ai_clien","TC_ID")
SET RELATION TO tc_id INTO AI_enc 
SET RELATION TO Client_id INTO address ADDITIVE

=OPENFILE("AI_SITE"  ,"TC_ID")
SET RELATION TO SITE INTO SITE

=OPENFILE("CLOSCODE", "CODE")
=OPENFILE("PROGRAM", "PROG_ID")

* jss, 9/21/01, add new field clos_reas
If Used('clprog')
   Use in clprog
EndIf
  
**VT 09/15/2010 Dev Tick 6425 add death_dt  
SELECT DIST ;
   PADR(Upper(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)),25) AS name, ;
   SPACE(50) as clos_reas, ;
   cli_cur.*  ,;
   SPACE(5)   AS WORKER    , ;
   SPACE(5)   AS SITE      , ;
   SPACE(30)  AS Sitename  , ;
   SPACE(30)  AS Workname  , ;
   {}         AS SERDT     , ;
   SPACE(7)   AS CaseOpen  , ;
   {}         AS Effect_dt , ;
   {}         AS death_dt ,  ;
   SPACE(30)  AS intwrkname, ;
   SPACE(30)  AS intprgdesc, ;
   .F.        AS firstrec ,  ;
   lcTitle as lcTitle,;   
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   from_date as date_from, ;
   to_date as date_to ;
FROM ;
   cli_cur ;
ORDER BY ;
	1 ;
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

*!*   If Used("ClAlfaR")
*!*       Use in ("ClAlfaR")
*!*   EndIf

SELE MyClient

cSaveTC_ID = Space(10)

*****   SITE   ******
Select Myclient
Go top
Set Relation to tc_id into ai_site
replace site with ai_site.site all 
replace sitename with site.descript1 all
Set Relation to 

**** intake worker name ***   
Select Myclient
Go top
Set Relation to int_worker into userprof
replace IntWrkName WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first)) all 
Set Relation to  

**** intake program description ***
Select Myclient
Go top
Set Relation to int_prog into program
replace IntPrgDesc WITH Program.Descript all 
Set Relation to  

*****   LAST DATE SERVICES PROVIDED  ******
Update MyClient ;
      set SERDT = Ai_ENC.ACT_DT ;
From  MyClient ;
      inner join ai_enc on;
            MyClient.tc_id = ai_enc.tc_id 
       

*****   CASEOPEN  ******
If Used('ClOpenStat')
   Use in ClOpenStat
EndIf


**VT 09/15/2010 Dev Tick 6425 add death_dt
SELECT Distinct ;
   ai_activ.effect_dt, ;
   ai_activ.close_code, ;
   MyClient.Tc_id, ;
   Iif(statvalu.incare, "Open   ","Closed ") as caseopen,;
   ai_activ.death_dt ;
FROM ;
   MyClient, ai_activ, statvalu ;
WHERE ;
   MyClient.Tc_id = ai_activ.tc_id       AND ;
   ai_activ.status = statvalu.code AND ;
   statvalu.tc = gcTC              AND ;
   statvalu.type = 'ACTIV'         AND ;
   ai_activ.tc_id + DTOS(ai_activ.effect_dt) + oapp.time24(ai_activ.time,ai_activ.am_pm)  ;
               IN (SELECT ;
                     T1.tc_id + MAX(DTOS(T1.effect_dt)+oapp.time24(T1.time, T1.am_pm)) ;
                  FROM ;
                     ai_activ T1 ;
                  WHERE ;
                     T1.effect_dt <= to_date ;
                  GROUP BY ;
                     T1.tc_id)      ;
INTO CURSOR ;
   ClOpenStat


**VT 09/15/2010 Dev Tick 6425 add death_dt
Update MyClient ;
      Set caseopen = ClOpenStat.caseopen ,;
         MyClient.effect_dt = ClOpenStat.Effect_dt, ;
         MyClient.death_dt = ClOpenStat.death_dt ;
From  MyClient ;
      inner join  ClOpenStat on ;
         ClOpenStat.tc_id = MyClient.tc_id  ; 

Update MyClient ;
      Set  MyClient.clos_reas = closcode.descript ;
From  MyClient ;
      inner join  ClOpenStat on ;
         ClOpenStat.tc_id = MyClient.tc_id  ; 
      inner join  closcode  on ;
         ClOpenStat.close_code = closcode.code   
                  

If Used('ClOpenStat')
   Use in ClOpenStat
EndIf
            
*!*   Select Myclient
*!*   Go top
*!*   SCAN
*!*   	*****   LAST DATE SERVICES PROVIDED  ******
*!*   	IF SEEK(MyClient.TC_ID,	"Ai_ENC")
*!*   		REPL MyClient.SERDT WITH Ai_ENC.ACT_DT
*!*   	EndIf

*!*      *****   CASEOPEN  ******
*!*      REPL MyClient.caseopen WITH IIF(oApp.IsItOpe2(MyClient.TC_ID, to_date),"Open   ","Closed ") 

*!*      **** CLOPENSTAT is a cursor defined in procedure isitope2...   
*!*      REPL MyClient.effect_dt WITH ClOpenStat.Effect_dt   
*!*     
*!*   * jss, 9/21/01, load in closure reason
*!*   	IF SEEK(ClOpenStat.close_code,"CLOSCODE")
*!*   		REPL MyClient.clos_reas WITH closcode.descript
*!*   	ENDIF	

*!*   EndScan

If Used("closcode")
   Use in ("closcode") 
Endif  


MyFilt = "CaseOpen = 'Closed' AND !EMPTY(Effect_dt)"
MyFilt = MyFilt + IIF(EMPTY(cCSite)	,""," and SITE=cCSite")
MyFilt = MyFilt + IIF(EMPTY(cCWork)	,""," and INT_WORKER=cCWork")
MyFilt = MyFilt + IIF(EMPTY(LCProg)	,""," and INT_PROG=LCProg")
MyFilt = MyFilt + " and Between(effect_dt, dfrom_date, dto_date) "

If Used('tempt')
   Use in tempt
EndIf
   
DO CASE
CASE nGroup = 1 							&& No grouping
	SELECT ;
		MyClient.* , ;
		SPACE(30) AS column1  ;
	FROM ;
		MyClient ;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
		tempt
	
	**lcTitle = " "
CASE nGroup = 2 							&& Site Name group
	SELECT ;
		MyClient.* , ;
		MyClient.sitename AS column1  ;
	FROM ;
		MyClient ;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
		tempt
	
	lcTitle = "Site Assignment = "
CASE nGroup = 3								&& Intake Worker Name group
	SELECT ;
		MyClient.* , ;
		MyClient.intwrkname AS column1  ;
	FROM ;
		MyClient;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
		tempt

	**lcTitle = "Worker Completing Intake = "
CASE nGroup = 4								&& Intake Program group
	SELECT ;
		MyClient.* , ;
		MyClient.IntPrgDesc AS column1  ;
	FROM ;
		MyClient;
	WHERE ;
		&MyFilt ;
	INTO CURSOR ;
		tempt

	**lcTitle = "Intake Program = "
ENDCASE

**VT 08/26/2010 Dev Tick 4807 
*!*	DO CASE
*!*	CASE nOrder = 1
*!*		SELECT * FROM tempt INTO CURSOR temp ORDER BY column1, LAST_NAME, FIRST_NAME
*!*	CASE nOrder = 2
*!*		SELECT * FROM tempt INTO CURSOR temp ORDER BY column1, ID_NO
*!*	ENDCASE


SELECT MyClient
USE
*!*	USE (DBF('TEMP')) ALIAS MyClient AGAIN EXCLUSIVE

*!*	If Used("temp")
*!*	    Use in ("temp")
*!*	EndIf

Do Case
Case nOrder = 1
	SELECT * FROM tempt INTO CURSOR MyClient readwrite
	
	Index On column1+Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
   Set Order To col1

Case nOrder = 2
	SELECT * FROM tempt INTO CURSOR MyClient readwrite
	
	Index On column1+ID_NO Tag col1
   Set Order To col1

EndCase
**VT End

If Used("tempt")
	Use in ("tempt")
EndIf

SELE MyClient
SET RELATION TO TC_ID	 INTO Ai_CLIEN ADDITIVE
SET RELATION TO worker   INTO userprof ADDITIVE

SELE MyClient
GO TOP
cSaveTC_ID = Space(10)
SCAN
	IF tc_id <> cSaveTC_ID
		REPL firstrec WITH .T.
		cSaveTC_ID = tc_id
	ENDIF
ENDSCAN

oApp.msg2user("OFF")

gcRptName = 'rpt_cli_clos'
Select MyClient
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
     DO CASE
        CASE lPrev = .f.
               Report Form rpt_cli_clos To Printer Prompt Noconsole NODIALOG 
        CASE lPrev = .t.     
               oApp.rpt_print(5, .t., 1, 'rpt_cli_clos', 1, 2)
    ENDCASE
Endif
