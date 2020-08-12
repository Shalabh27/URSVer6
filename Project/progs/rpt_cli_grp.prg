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
cGroup = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CGROUP"
      cGroup = aSelvar2(i, 2)
   Endif

EndFor

***** jss, 12/15/03, this program taken from pr_cli_p.prg, modified for group
PRIVATE gchelp
gchelp = "Client Listing by Group Screen"
cDate = DATE()
cTime = TIME()
AS_OF_D  = Date_from
cTitle = "Client Listing by Group"

SELECT cli_cur.*  ,;
	SPACE(5)   AS SITE     ,;
	SPACE(30)  AS Sitename ,;
	{}         AS SERDT    ,;
	SPACE(7)   AS CaseOpen ,;
	.F.        AS firstrec, ;
   lcTitle as lcTitle,;   
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as as_of_D ;
FROM ;
	cli_cur,ai_clien;
WHERE ;
	cli_cur.client_id = ai_clien.client_id AND ;
	ai_clien.placed_dt <= As_Of_D  ;
INTO CURSOR ;
	ClAlfaR

************************  Opening Tables ************************************
If Used("ai_site")   
   Use in ai_site
Endif 
If Used("ai_clien")   
   Use in ai_clien
Endif 

=OPENFILE("Site",		"site_id")
=OPENFILE("Address","client_id")

**=OPENFILE("Cli_hous","Client_id")
**SET FILTER TO lives_in
**SET RELATION TO hshld_id INTO ADDRESS

=OPENFILE("AI_enc","Tc_id_act")
SET FILTER TO !EMPTY(AI_enc.act_dt)

=OPENFILE("Ai_clien","TC_ID")
SET RELATION TO tc_id INTO AI_enc ADDITIVE
SET RELATION TO Client_id INTO address ADDITIVE

=OPENFILE("AI_SITE"  ,"TC_ID")
SET RELATION TO SITE INTO SITE

**VT 08/25/2010 Dev Tick 6472 add cWhere
**cgroup = ai_grp.group 		AND ;

cWhere = '.T.'
cWhere = cWhere + IIf(   Empty(cgroup)  ,""," and Rtrim(cgroup) == Rtrim(ai_grp.group)" )


* grab enrollments
SELECT DIST ;
	PADR(Upper(oApp.FormatName(clalfar.last_name, clalfar.first_name, clalfar.mi)),25) AS name, ;
	ai_grp.group as group1, ;
	group.descript, ;
	program.descript as progdesc, ;
	ai_grp.start_dt, 	;
	ai_grp.end_dt, 	;
	ClAlfaR.* 			;
FROM 					;
	ClAlfaR, 			;
	ai_grp, 			;
	group,  			;
	program			;
WHERE 					;
	ClAlfaR.tc_id 	= ai_grp.tc_id 		AND ;
	group.program  = program.prog_id		AND ;
	ai_grp.group   = group.grp_id 		AND	;
	ai_grp.start_dt <= As_Of_D   			AND	;
	(EMPTY(ai_grp.end_dt) OR ai_grp.end_dt > As_Of_D) ;
	and &cWhere ;
INTO CURSOR ;
	ClGroup

If Used('MyClient')	
   Use in MyClient
EndIf
   
SELECT 0
USE (DBF('ClGroup')) ALIAS MyClient AGAIN EXCLUSIVE

If Used("ClAlfaR")
    Use in ("ClAlfaR")
EndIf

If Used("ai_grp") 
   Use in ("ai_grp") 
Endif    

If Used("ClGroup")
    Use in ("ClGroup")
EndIf

SELE MyClient

*****   SITE   ******
Set Relation to tc_id into ai_site
replace site with ai_site.site all 
replace sitename with site.descript1 all
Set Relation to  

DO CASE
CASE nGroup = 1                      && No grouping
   SELECT ;
      MyClient.* , ;
      SPACE(30) AS column1  ;
   FROM ;
      MyClient ;
   INTO CURSOR ;
      tempt
     
CASE nGroup = 2                      && Site Name group
   SELECT ;
      MyClient.* , ;
      MyClient.sitename AS column1  ;
   FROM ;
      MyClient ;
   INTO CURSOR ;
      tempt

ENDCASE

**VT 08/26/2010 Dev Tick 4807 
*!*	DO CASE
*!*	CASE nOrder = 1
*!*		SELECT * FROM tempt INTO CURSOR temp ORDER BY descript, column1, LAST_NAME, FIRST_NAME
*!*	CASE nOrder = 2
*!*		SELECT * FROM tempt INTO CURSOR temp ORDER BY descript, column1, ID_NO
*!*	CASE nOrder = 3	
*!*		SELECT * FROM tempt INTO CURSOR temp ORDER BY descript, column1, zip, LAST_NAME, FIRST_NAME	
*!*	ENDCASE

*!*	SELECT MyClient
*!*	USE
*!*	USE (DBF('TEMP')) ALIAS MyClient AGAIN EXCLUSIVE

*!*	If Used("temp")
*!*	    Use in ("temp")
*!*	EndIf

SELECT MyClient
USE

Do Case
Case nOrder = 1
	SELECT * FROM tempt INTO CURSOR MyClient readwrite
	
	Index On descript + column1+Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
   Set Order To col1

Case nOrder = 2
	SELECT * FROM tempt INTO CURSOR MyClient readwrite
	
	Index On descript + column1+ID_NO Tag col1
   Set Order To col1
	
Case nOrder = 3	
	SELECT * FROM tempt INTO CURSOR MyClient readwrite 
	
	Index On descript + column1+ zip + Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
   Set Order To col1
EndCase

**VT End

If Used("tempt")
    Use in ("tempt")
EndIf

SELE MyClient
SET RELATION TO TC_ID	 INTO Ai_CLIEN ADDITIVE

Select 	group1, ;
			count(*) as tot ;
From 	myclient ;
Into Cursor	;
		tgrp_tot	;
Group By group1

Index on group1 tag group1

oApp.reopencur('tgrp_tot', 'grp_tot', .t.)
Set Order to tag group1

If Used("tgrp_tot")
    Use in ("tgrp_tot")
EndIf


Select 	count(*) as tot_cl ;
From myclient;
Into Cursor	total

Select MyClient
Set Rela to group1 into grp_tot Additive

*** scan will assign first record of each person 
cSaveTC_ID = Space(10)
SCAN
	IF tc_id <> cSaveTC_ID
		REPL firstrec WITH .T.
		cSaveTC_ID = tc_id
	ENDIF
EndScan

If Used("group") 
   Use in ("group") 
Endif   

Select ai_clien
Set Relation to

oApp.msg2user("OFF")
gcRptName = 'rpt_cli_grp'
Select MyClient
GO TOP 
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else 
   Do Case
      Case lPrev = .f.
           Report Form rpt_cli_grp To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.     
           oApp.rpt_print(5, .t., 1, 'rpt_cli_grp', 1, 2)
  EndCase 
Endif


