*!*
*!* copied from rpt_agser.prg
*!* 05/28/2009 
*!* reason to include stmts for crystal reports conversion
*!* jim power
*!*


Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by number
              nGroup, ;             && report selection number   
              lcTitle1, ;           && report selection description   
              Dt_from_a , ;         && from date
              Dt_to_a, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy,;            && order by description
              wreport               && Report type


Acopy(aSelvar1, aSelvar2)

* set Data Engine Compatibility to handle Foxpro version 7.0 or earlier (lets old SQL work)
mDataEngine=Sys(3099,70)
lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)
lcServA=''


&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcServA = aSelvar2(i, 2)
   Endif
Endfor

PRIVATE gchelp
gchelp = "Generating Service Category Aggregate Reports"
*Crit = ""
*cReportSelection = ""
nMon = 0
nDat  = 0

m.Date_from = Dt_from_a
m.Date_to = Dt_to_a

IF Empty(m.Date_to)
   oApp.msg2user('INFORM', 'Please Enter "To" Date')
   RETURN
ENDIF

cDate = DATE()
cTime = TIME()

**IF (Used("Hold1s") and Reccount("Hold1s")>0) or GetCliLst()=.t.

IF GetCliLst()=.t.

   If Used('Hold1')
      Use in Hold1
   EndIf
   
   Select * From Hold1s into Cursor Hold1 nofilter

   Do Case
   Case lnStat=1
  * Age by Sex by Ethnicity/Race - Active Clients 

      Do Rpt_AgeSer 

   Case lnStat=2
  * Client Demographics

      Do Rpt_AggSer with 1

   Case lnStat=3
  * Client Demographics (Condensed)

      Do Rpt_AggSer with 2
   
   Case lnStat=4
  * Encounters by Service Category
      Do Rpt_EncSer
      
   Case lnStat=5
  * Encounters by Service Category (Condensed)
      Do Rpt_EncSr1
      
   EndCase

ELSE
   IF USED('hold')
      IF EOF('hold')
         oApp.msg2user('NOTFOUNDG')
      ENDIF   
   ENDIF   
ENDIF

If Used('Hold1')
   Use in Hold1
Endif
* reset Data Engine compatibility back to Visual 9.0
mDataEngine=Sys(3099,90)

Return

**********************************************************************
PROCEDURE GetCliLst
**********************************************************************
CREATE CURSOR aiaggdet (column0 C(2), column1 C(50), column2 C(60), column3 N(10), column4 C(75), column5 C(20), column6 D, column7 C(5), column8 D)

INDEX ON column1 + column0 + column4 TAG col104

IF USED('Hold')
	USE IN Hold
EndIf

IF USED('Hold1s')
   USE IN Hold1s
ENDIF

IF USED('Hold1')
   USE IN Hold1
ENDIF
	
*!*oApp.Msg2User("WAITRUN", "Preparing Report Data.   ", "")


* cursor of current clients
*** VT 08/12/2008 Dev Tick 4623  Address works now in different way

*!*   SELECT ;
*!*   	t1.tc_id,;
*!*   	t1.client_id, ;
*!*   	t1.urn_no, ;
*!*   	t3.last_name,;
*!*   	t3.first_name,;
*!*   	t1.anonymous,;
*!*   	t1.id_no, ;
*!*   	t1.hhead,;
*!*   	t1.dchild,;
*!*   	t1.placed_dt,;
*!*   	t1.hiv_exp1,;
*!*   	t1.inaddhouse,;
*!*   	subs(address.zip,1,5) + '-' + subs(address.zip,6,4) as zip, ;
*!*   	t3.dob,;
*!*   	t3.hispanic, ;
*!*   	t3.white,;
*!*   	t3.asian,;
*!*   	t3.hawaisland,;
*!*   	t3.indialaska ,;
*!*   	t3.blafrican,;
*!*   	t3.someother, ;
*!*   	t3.unknowrep,;
*!*   	IIF(!EMPTY(ethnic), LEFT(t3.ethnic,1)+"0", "  ") AS ethnic, ;
*!*   	t1.housing ,;
*!*   	PADR(ALLTRIM(ref_in.descript)+           ;
*!*   		IIF(t1.nrefnote=1,' (Int)',              ;
*!*   		IIF(t1.nrefnote=2,' (Ext)','')),55,' ')  AS referalsrc ,;
*!*   	t3.sex        ,;
*!*   	address.st        AS state      ,;
*!*       address.county    AS code       ,;
*!*       SPACE(25)         AS county     ,;
*!*   	.F. AS hiv_pos                  ,;
*!*   	SPACE(40) AS hivstatus ,;
*!*   	.F. AS ppd_pos ,;
*!*   	.F. AS anergic ,;
*!*   	.F. AS newagency,;
*!*   	.F. AS ActivAgen,;
*!*   	{} AS end_dt,    ;
*!*   	t3.insurance, ;
*!*   	t3.is_refus, ;
*!*   	t3.hshld_incm, ;
*!*   	t3.hshld_size ;
*!*   FROM ;
*!*   	ai_clien  t1   ,;
*!*   	cli_cur   t3   ,;
*!*   	address        ,;
*!*   	cli_hous       ,;
*!*   	ref_in         ;
*!*   WHERE ;
*!*   	t3.client_id           = t1.client_id              ;
*!*   	AND cli_hous.client_id = t3.client_id              ;
*!*   	AND address.hshld_id   = cli_hous.hshld_id         ;
*!*   	AND ref_in.code        = t1.ref_src2               ;
*!*   	AND cli_hous.lives_in  = .T.                       ;
*!*   	AND t1.int_compl 												;
*!*   GROUP BY ;
*!*   	t1.tc_id ;	
*!*   INTO CURSOR ;
*!*   	hold
 
 SELECT ;
   t1.tc_id,;
   t1.client_id, ;
   t1.urn_no, ;
   t3.last_name,;
   t3.first_name,;
   t1.anonymous,;
   t1.id_no, ;
   t1.hhead,;
   t1.dchild,;
   t1.placed_dt,;
   t1.hiv_exp1,;
   t1.inaddhouse,;
   subs(address.zip,1,5) + '-' + subs(address.zip,6,4) as zip, ;
   t3.dob,;
   t3.hispanic, ;
   t3.white,;
   t3.asian,;
   t3.hawaisland,;
   t3.indialaska ,;
   t3.blafrican,;
   t3.someother, ;
   t3.unknowrep,;
   IIF(!EMPTY(ethnic), LEFT(t3.ethnic,1)+"0", "  ") AS ethnic, ;
   t1.housing ,;
   PADR(ALLTRIM(ref_in.descript)+           ;
      IIF(t1.nrefnote=1,' (Int)',              ;
      IIF(t1.nrefnote=2,' (Ext)','')),55,' ')  AS referalsrc ,;
   t3.sex        ,;
   address.st        AS state      ,;
    address.fips_code  as fips_code, ;
    SPACE(25)         AS county     ,;
   .F. AS hiv_pos                  ,;
   SPACE(40) AS hivstatus ,;
   .F. AS ppd_pos ,;
   .F. AS anergic ,;
   .F. AS newagency,;
   .F. AS ActivAgen,;
   {} AS end_dt,    ;
   t3.insurance, ;
   t3.is_refus, ;
   t3.hshld_incm, ;
   t3.hshld_size ;
FROM ;
   ai_clien  t1  ;
   Inner Join  cli_cur   t3  On ;
         t3.client_id = t1.client_id  ;
     AND t1.int_compl               ;   
   Inner Join address On ;
         address.client_id = t1.client_id  ;
   Inner Join ref_in   on    ;
         ref_in.code  = t1.ref_src2      ;
INTO CURSOR ;
   hold
    
lcServA  = ALLTRIM(lcServA)
&&VT 10/26/2009 Dev Tick 4987
** address.county    AS code       ,;

* Hold1 Cursor contains clients who had at least one encounter during period for selected serv_cat(s)
SELECT DISTINCT ;
	hold.*, ;
	ai_enc.serv_cat ;
FROM ;
 	hold, ;
	ai_enc ;
WHERE 	hold.tc_id = ai_enc.tc_id ;
  AND 	ai_enc.act_dt >= m.Date_from ;
  AND 	ai_enc.act_dt <= m.Date_to ;
  AND 	ai_enc.serv_cat=lcServA ;
INTO CURSOR ;
	hold1 

Go top
	
USE IN hold

* make sure there are clients to report on
IF _TALLY = 0
	oApp.Msg2User("NOTFOUNDG")
	RETURN .f.
ENDIF

* Hold1 Clients Open/Active in Agency at Start of Period
SELECT ;
	hold1.tc_id,;
	ai_activ.effect_dt, ;
	hold1.anonymous AS anonymous ;
FROM ;
	hold1, ai_activ, statvalu ;
WHERE ;
	hold1.tc_id = ai_activ.tc_id    AND ;
	ai_activ.status = statvalu.code AND ;
	statvalu.tc = gcTC              AND ;
	statvalu.type = 'ACTIV'         AND ;
	statvalu.incare                 AND ;
	ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
					IN	(SELECT ;
							T1.tc_id + MAX(DTOS(t1.effect_dt)+oApp.Time24(t1.time, t1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt < m.Date_From ;
						GROUP BY ;
							T1.tc_id)  ;
INTO CURSOR ;
	OpBegPer

* Hold1 Clients Closed in Agency During Period
SELECT ;
	hold1.tc_id,;
	ai_activ.effect_dt, ;
	hold1.anonymous AS anonymous ;
FROM ;
	hold1, ai_activ, statvalu ;
WHERE ;
	hold1.tc_id = ai_activ.tc_id    AND ;
	ai_activ.status = statvalu.code AND ;
	statvalu.tc = gcTC              AND ;
	statvalu.type = 'ACTIV'         AND ;
	!statvalu.incare                AND ;
	ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm)  ;
					IN (SELECT ;
							T1.tc_id + MAX(DTOS(T1.effect_dt)+oApp.Time24(T1.time,T1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt >= m.Date_From AND ;
							T1.effect_dt <= m.Date_To ;
						GROUP BY ;
							T1.tc_id)      ;
INTO CURSOR ;
	ClDurPer
	
* Hold1 Clients Open in Agency at End of Period 
SELECT ;
	hold1.tc_id,;
	ai_activ.effect_dt, ;
	hold1.anonymous AS anonymous ;
FROM ;
	hold1, ai_activ, statvalu ;
WHERE ;
	hold1.tc_id = ai_activ.tc_id    AND ;
	ai_activ.status = statvalu.code AND ;
	statvalu.tc = gcTC              AND ;
	statvalu.type = 'ACTIV'         AND ;
	statvalu.incare                 AND ;
	ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time,ai_activ.am_pm)  ;
					IN (SELECT ;
							T1.tc_id + MAX(DTOS(T1.effect_dt)+oApp.Time24(T1.time, T1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt <= m.Date_To    ;
						GROUP BY ;
							T1.tc_id)      ;
INTO CURSOR ;
	OpEndPer

* Hold1 Clients Closed in Agency at End of Period
SELECT ;
	hold1.tc_id,;
	ai_activ.effect_dt, ;
	hold1.anonymous AS anonymous ;
FROM ;
	hold1, ai_activ, statvalu ;
WHERE ;
	hold1.tc_id = ai_activ.tc_id    AND ;
	ai_activ.status = statvalu.code AND ;
	statvalu.tc = gcTC              AND ;
	statvalu.type = 'ACTIV'         AND ;
	!statvalu.incare                AND ;
	ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
					IN (SELECT ;
							T1.tc_id + MAX(DTOS(T1.effect_dt)+oApp.Time24(T1.time, T1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt <= m.Date_To    ;
						GROUP BY ;
							T1.tc_id)      ;
INTO CURSOR ;
	ClEndPer


* add start_dt; hold1 becomes hold2, essentially
* jss, 10/4/05, change * to hold1.* to correct problem with all counties being reported as "Albany" 
*               (hold1 ended up with 2 fields named "code", because we were grabbing entire serv_cat.*)

SELECT ;
	hold1.*, ;
	hold1.placed_dt AS start_dt , ;
	serv_cat.descript as servcatdes ;
FROM ;
	hold1, serv_cat ;
WHERE ;
	hold1.serv_cat = serv_cat.code ;	
INTO CURSOR ;
	hold2

USE IN hold1
USE IN serv_cat

* Here get all clients closed at the end of a period
SELECT ;
	hold2.tc_id,;
	ai_activ.effect_dt, ;
	hold2.anonymous AS anonymous ;
FROM ;
	hold2, ai_activ, statvalu ;
WHERE ;
	hold2.tc_id = ai_activ.tc_id    AND ;
	ai_activ.status = statvalu.code AND ;
	statvalu.tc = gcTC              AND ;
	statvalu.type = 'ACTIV'         AND ;
	!statvalu.incare                AND ;
	ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
					IN (SELECT ;
							T1.tc_id + MAX(DTOS(T1.effect_dt)+oApp.Time24(T1.time, T1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt <= m.Date_To ;
						GROUP BY ;
							T1.tc_id)      ;
INTO CURSOR ;
	cliclosed
	
INDEX ON tc_id TAG tc_id
SET ORDER TO TAG tc_id

* first, get those tc_ids that exist prior to start of period (the active ones here are the beginning active count)
SELECT ;
		ai_activ.tc_id, ;
		statvalu.incare as active, ;
		hold2.anonymous ;
	FROM ;
		ai_activ, ;
		statvalu,  ;
		hold2 ;
	WHERE ;
		ai_activ.status    = statvalu.code ;
	AND ;
		ai_activ.tc_id = hold2.tc_id ;
	AND ;
		ai_activ.effect_dt < m.date_from     ;
	AND ;
		ai_activ.tc_id + DTOS(ai_activ.effect_dt) + oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
						IN (SELECT aia.tc_id + MAX(DTOS(aia.effect_dt)+oApp.Time24(aia.time, aia.am_pm)) ;
							FROM ai_activ aia ;
							WHERE ;
								aia.effect_dt < m.date_from ;
							GROUP BY ;
								tc_id) ;
	INTO CURSOR ;
		tcurs1

* next, get all tc_ids that exist prior to end of period
SELECT ;
		ai_activ.tc_id, ;
		statvalu.incare as active, ;
		hold2.anonymous ;
	FROM ;
		ai_activ, ;
		statvalu, ;
		hold2 ;
	WHERE ;
		ai_activ.status    = statvalu.code ;
	AND ;
		ai_activ.tc_id = hold2.tc_id ;
	AND ;
		ai_activ.effect_dt <= m.date_to     ;
	AND ;
		ai_activ.tc_id + DTOS(ai_activ.effect_dt) + oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
						IN (SELECT aia.tc_id + MAX(DTOS(aia.effect_dt)+oApp.Time24(aia.time, aia.am_pm)) ;
							FROM ai_activ aia ;
							WHERE ;
								aia.effect_dt <= m.date_to ;
							GROUP BY ;
								aia.tc_id) ;
	INTO CURSOR ;
		tcurs2

* find any client that became active during this period (need this for reopens)
SELECT ;
		ai_activ.tc_id, ;
		hold2.anonymous ;
	FROM ;
		ai_activ, ;
		statvalu, ;
		hold2     ;
	WHERE ;
		ai_activ.status    = statvalu.code ;
	AND ;
		ai_activ.tc_id = hold2.tc_id ;
	AND statvalu.incare ;
	AND ;
		ai_activ.effect_dt BETWEEN m.date_from AND m.date_to     ;
	GROUP BY ;
		ai_activ.tc_id ;
	INTO CURSOR ;
		tcurs3

* now, let's get new clients for this period
SELECT * ;
FROM ;
	hold2 ;
WHERE ;
	Start_dt BETWEEN m.date_from AND m.date_to ;
AND ;
	tc_id + DTOS(Start_dt) IN ;
	(SELECT tc_id + MIN(DTOS(Start_dt)) ;
							FROM hold2;
							WHERE Start_dt BETWEEN m.date_from AND m.date_to ;
							GROUP BY ;
								tc_id) ;
GROUP BY tc_id ;								
INTO CURSOR CliNew

INDEX ON tc_id TAG tc_id
SET ORDER TO TAG tc_id

* total new clients
SELECT ;
	COUNT(*)         			           AS tot, ;
	SUM(IIF(anonymous,1,0))            AS totanon, ;
	SUM(IIF(UPPER(hhead)='Y',1,0))     AS tothhead, ;
	SUM(IIF(UPPER(dchild)='Y',1,0))    AS totdchild ;
FROM ;
	CliNew ;
INTO CURSOR ;
	CliNewTo

* those that were active at beginning of period
SELECT;
	tc_id ,;
	anonymous ;
FROM ;
	tcurs1 ;
WHERE ;
	active ;
GROUP BY ;
	tc_id ;	
INTO CURSOR ;
	BegActiv
	
* total active beginners
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	BegActiv ;
INTO CURSOR ;
	BegActTo 

* those that were active at end of period
SELECT ;
	tc_id ,;
	anonymous ;
FROM ;
	tcurs2 ;
WHERE ;
	active ;
GROUP BY ;
	tc_id ;	
INTO CURSOR ;
	EndActiv

SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	EndActiv ;
INTO CURSOR ;
	EndActTo 

* those that were inactive, and became active during period are REOPENS 
SELECT ;
   tcurs1.tc_id, ;
  	hold2.anonymous AS anonymous ;
FROM ;
	tcurs1, ;
	tcurs3, ;
	hold2   ;
WHERE ;
	!tcurs1.active              AND ;
	tcurs1.tc_id = tcurs3.tc_id AND ;
	tcurs1.tc_id = hold2.tc_id ;
UNION ;		
SELECT ;
	tcurs1.tc_id, ;
   hold2.anonymous AS anonymous ;
FROM ;
	tcurs1, ;
	hold2   ;
WHERE ;
	tcurs1.tc_id=hold2.tc_id AND ;
 	!tcurs1.active AND ;
 	tcurs1.tc_id IN ;
		(SELECT tc_id FROM cldurper) ;	
INTO CURSOR ;
	Reopened
	
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	reopened ;
INTO CURSOR ;
	ReopTota 

SELECT ;
	tc_id ;
FROM ;
	CliNew ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	BegActiv ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	Reopened ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	EndActiv ;
INTO CURSOR ;
	AllActiv	

INDEX ON tc_id TAG tc_id

* all tc_id's closed in period
SELECT ;
	tc_id, anonymous ;
FROM ;
	cliclosed ;
WHERE ;
	effect_dt BETWEEN m.date_from AND m.date_to ;
GROUP BY ;
	tc_id ;	
INTO CURSOR ;
	ClosPer
	
* total closed in period
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	ClosPer ;
INTO CURSOR ;
	ClosPeTo


* jss, now, grab anybody who is newly activ, but not in the other buckets because they 
*      have become enrolled in the program this period, but were already activ in the agency
*      at period start (thus, they are not new in agency)

* create a union of begactiv,clinew,reopened for check below
SELECT tc_id FROM Begactiv ;
UNION ;
SELECT tc_id FROM CliNew ;
UNION ;
SELECT tc_id FROM Reopened ;
INTO CURSOR ;
	ChkActiv

SELECT DISTINCT;
	tc_id, anonymous ;
FROM ;
	EndActiv ;
WHERE ;
	tc_id NOT IN (SELECT tc_id FROM ChkActiv) ;
INTO CURSOR ;
	NewActiv		
	
* total active beginners
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	NewActiv ;
INTO CURSOR ;
	NewActTo 

* break down closes (beginning active)
SELECT ;
	BegActiv.tc_id ,;
	BegActiv.anonymous ;
FROM ;
	BegActiv, ClosPer ;
WHERE ;		
	BegActiv.tc_id=ClosPer.tc_id ;
GROUP BY ;
	BegActiv.tc_id ;
INTO CURSOR ;
	BaClose

* total of closes of beginning actives
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	BaClose ;
INTO CURSOR ;
	BaClosTo
	 
* break down closes (reopens)
SELECT ;
	Reopened.tc_id ,;
	Reopened.anonymous ;
FROM ;
	Reopened, ClosPer ;
WHERE ;		
	Reopened.tc_id=ClosPer.tc_id ;
GROUP BY ;
	Reopened.tc_id ;
INTO CURSOR ;
	ReClose

* total of closes of reopens
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	ReClose ;
INTO CURSOR ;
	ReClosTo
	 
* break down closes (starts)
SELECT ;
	CliNew.tc_id ,;
	CliNew.anonymous ;
FROM ;
	CliNew, ClosPer ;
WHERE ;		
	CliNew.tc_id=ClosPer.tc_id ;
GROUP BY ;
	CliNew.tc_id ;
INTO CURSOR ;
	CnClose

* total of closes of new starts
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	CnClose ;
INTO CURSOR ;
	CnClosTo

IF USED("hold1")
  USE IN hold1
ENDIF

USE DBF("hold2") IN 0 AGAIN ALIAS hold1s
SELECT hold1s
INDEX ON tc_id TAG tc_id
INDEX ON anonymous TAG anonymous
USE IN hold2

*- setup for adding tb status to hold1
=OpenFile("test_res", "code")
=OpenFile("tbstatus", "tc_id")
SET FILTER TO tbstatus.effect_dt <= m.Date_To
SET RELATION TO ppdres INTO test_res

*- setup for adding hiv status to hold1
=OpenFile("hstat", "code")
=OpenFile("hivstat", "tc_id")
SET FILTER TO hivstat.effect_dt <= m.Date_To
SET RELATION TO hivstatus INTO hstat

**VT 10/26/2009 Dev Tick 4987
*=OpenFile("county", "statecode")
=OpenFile("zipcode", "countyfips")

*- set relations for hivstatus and tbstatus, et al.
SELECT hold1s
SET RELATION TO tc_id         INTO tbstatus           ,;
                tc_id         INTO hivstat            ,;
                tc_id         INTO clinew             ,;
                tc_id         INTO AllActiv           ,;
                tc_id         INTO cliclosed          ,;
                fips_code     INTO zipcode ADDITIVE
                
            **VT 10/26/2009 Dev Tick 4987     
            ** state+code    INTO county    ADDITIVE        
                

REPL ALL ppd_pos    WITH test_res.ppd_pos        ,;
         hiv_pos    WITH hstat.hiv_pos           ,;
         hivstatus  WITH hstat.descript          ,;
         anergic    WITH (tbstatus.panergic=1)   ,;
         county     WITH Left(PROPER(zipcode.countyname),25) ,;  && VT 10/26/2009 Dev Tick 4987 
         End_dt     WITH cliclosed.effect_dt     ,;
         ActivAgen  WITH FOUND('AllActiv')       ,;
         NewAgency  WITH FOUND('CliNew')         

**VT 10/26/2009 Dev Tick 4987     
** county     WITH PROPER(county.descript) ,;

* (county table has '999' plus BLANK state, actual data has actual state code)

**VT 10/26/2009 Dev Tick 4987 
**REPL ALL county WITH 'Other' FOR code = '999'  
REPL ALL county WITH Padr('Other',25) FOR fips_code = '99999'

*- cleanup
USE IN hstat
USE IN hivstat
USE IN test_res
USE IN tbstatus
USE IN cliclosed 
&& VT 10/26/2009 Dev Tick 4987 
**USE IN county

* service category-specific counts follow

*!*oApp.Msg2User("OFF")

RETURN .t.

**********************************************************************
PROCEDURE Rpt_AggSer

PARAMETER nRep
**********************************************************************
* this is the main AIDS Institute aggregate report
* the different aggregates for the clients are done and reported here
**********************************************************************
*DIMENSION aFiles_Open[1]
*DO Save_Env2 WITH aFiles_Open

*- create cursor for reporting
CREATE CURSOR aiaggser (serv_cat C(5), servcatdes C(30), group c(60), label c(80), count n(10,0), header l(1), notcount L(1))

Store 0 to nTotCli, nTotCliAn
* jss, 8/30/04, if nRep=2 (condensed form of report), calculate total clients and total anonymous clients
IF nRep=2
	SELECT COUNT(DISTINCT tc_id) FROM hold1 INTO ARRAY aTotCli
	nTotCli=aTotCli(1)
	SELECT COUNT(DISTINCT tc_id) FROM hold1 WHERE anonymous INTO ARRAY aTotCliAn
	nTotCliAn=aTotCliAn(1)
ENDIF

SELECT 	serv_cat, ;
			SUM(IIF(hiv_pos AND ppd_pos,1,0))                   AS TOTHIVPPD ,;
			SUM(IIF(newagency and hiv_pos AND ppd_pos,1,0))     AS NewHIVPPD ,;
			SUM(IIF(anergic,1,0))                               AS ppdanergic ;
FROM ;
	hold1 ;
GROUP BY serv_cat ;	
INTO CURSOR ;
	hold3 readwrite

INDEX ON serv_cat TAG serv_cat

*=ReOpenCur("holdsc", "hold3")
*SET ORDER TO serv_cat
*USE IN holdsc

*********************************************
* Family-Centered/Collateral Case Management:

IF Used("FamCollSum")
	USE IN FamCollSum
ENDIF

CREATE CURSOR FamCollSum (Serv_cat C(5), ServCatDes C(30), Descript C(60), Count N(5), NotCount L(1))

* this cursor holds all collaterals receiving services of clients receiving services this period
SELECT DISTINCT;
		Hold1.serv_cat, ;
		Hold1.ServCatDes, ;
		Hold1.tc_id    , ;
		ClientFam.Client_id ,;
      	ClientFam.Dob, ;
		ClientFam.Age, ;
		Ai_Famil.Relation ;
FROM ;
		Hold1, Ai_Enc, Ai_Colen, client ClientFam, Ai_Famil ;
WHERE ;
  		BETW(Ai_Enc.act_dt,m.Date_from,m.Date_to) ;
  AND	Hold1.tc_id      = Ai_Enc.tc_id ;
  AND Hold1.tc_id        = Ai_Famil.tc_id ;
  AND Ai_Enc.Act_id      = Ai_Colen.Act_id ;
  AND Ai_Colen.Client_id = ClientFam.Client_id ;
  AND Ai_Colen.Client_id = Ai_Famil.Client_id ;
INTO CURSOR ;
		tTemp1 

Use in ai_enc
Use in ai_colen

* next cursor sums by category for collaterals receiving services in period
SELECT ;
		ttemp1.serv_cat, ;
		ttemp1.ServCatDes, ;
		SUM(IIF(!EMPTY(tTemp1.dob) AND BETWEEN(tTemp1.Age,0,12),1,0)) 						   AS Age0_12  ,;
		SUM(IIF(!EMPTY(tTemp1.dob) AND BETWEEN(tTemp1.Age,13,19),1,0)) 						   AS Age13_19 ,;
		SUM(IIF(Relat.Mate                      AND (EMPTY(tTemp1.dob) OR tTemp1.Age>19),1,0)) AS Mates    ,;
		SUM(IIF(Relat.fam_memb  AND !Relat.Mate AND (EMPTY(tTemp1.dob) OR tTemp1.Age>19),1,0)) AS FamMemb  ,;
		SUM(IIF(!Relat.fam_memb AND !Relat.Mate AND (EMPTY(tTemp1.dob) OR tTemp1.Age>19),1,0)) AS Other     ;
FROM ;
		tTemp1, Relat ;
WHERE ;
		tTemp1.Relation = Relat.Code ;
INTO CURSOR ;
		tTemp ;
GROUP BY 1 	  

* now, get all possible distinct collaterals by serv_cat
SELECT DISTINCT ;
		Hold1.serv_cat, ;
		Hold1.ServCatDes, ;
		ai_famil.client_id  ,;
		client.dob          ,;
		client.age          ,;
		ai_famil.relation    ;
FROM ;
		hold1, ai_famil, client ;
WHERE ;
		hold1.tc_id=ai_famil.tc_id ;
  AND ;
		ai_famil.client_id=client.client_id ;
INTO CURSOR ;
		CollTemp 

Use in ai_famil

* count the different categories of all possible collaterals by serv_cat
SELECT ;
		CollTemp.serv_cat, ;
		SUM(IIF(!EMPTY(CollTemp.dob) AND BETWEEN(CollTemp.Age,0,12),1,0)) 													AS Age0_12 ,;
		SUM(IIF(!EMPTY(CollTemp.dob) AND BETWEEN(CollTemp.Age,13,19),1,0)) 												AS Age13_19,;
		SUM(IIF(Relat.Mate                      AND (EMPTY(CollTemp.dob) OR CollTemp.Age>19),1,0)) AS Mates   ,;
		SUM(IIF(Relat.fam_memb  AND !Relat.Mate AND (EMPTY(CollTemp.dob) OR CollTemp.Age>19),1,0)) AS FamMemb ,;
		SUM(IIF(!Relat.fam_memb AND !Relat.Mate AND (EMPTY(CollTemp.dob) OR CollTemp.Age>19),1,0)) AS Other    ;
FROM ;
		CollTemp, Relat ;
WHERE ;
		CollTemp.Relation = Relat.Code ;
INTO CURSOR CollTem2 ;
GROUP BY 1 	  

INDE ON serv_cat TAG serv_cat

SELECT tTemp
* relate to the total collateral cursor on program
SET RELA TO serv_cat INTO CollTem2

SCAN
	SCATTER MEMVAR
	FOR i = 3 TO FCOUNT()
		DO CASE 
			CASE FIELD(i) = "AGE0_12"
				cDescript = PADR("Children (0-12)",35)          + "(of " + TRANSFORM(Colltem2.Age0_12,'99999') + ")"
				lNotCount = .F.
			CASE FIELD(i) = "AGE13_19"
				cDescript = PADR("Adolescents (13-19)",35)      + "(of " + TRANSFORM(Colltem2.Age13_19,'99999') + ")"
				lNotCount = .F.				
			CASE FIELD(i) = "MATES"
				cDescript = PADR("Significant Others/Mates",35) + "(of " + TRANSFORM(Colltem2.mates,'99999') + ")"
				lNotCount = .F.				
			CASE FIELD(i) = "FAMMEMB"             
				cDescript = PADR("Other Family Members",35)     + "(of " + TRANSFORM(Colltem2.FamMemb,'99999') + ")"
				lNotCount = .F.				
			CASE FIELD(i) = "OTHER"				
				cDescript = PADR("Other Collaterals",35)        + "(of " + TRANSFORM(Colltem2.Other,'99999') + ")"
				lNotCount = .F.				
		ENDCASE
		nCount = EVAL(FIELD(i))
		INSERT INTO FamCollSum VALUES (m.serv_cat, m.servcatdes, cDescript, nCount, lNotCount)
	NEXT	
ENDSCAN	
IF USED('tTemp')
	USE IN tTemp
ENDIF	
IF USED('CollTemp')
	USE IN CollTemp
ENDIF	

*************************************************************

SELECT DIST serv_cat, servcatdes ;
	FROM Hold1 ;
	INTO CURSOR tServCat ;
	ORDER BY 1

SELECT ;
		serv_cat, ;
		COUNT(tc_id) AS cdcaidscnt;
FROM ;
		hold1 ;
WHERE ;
		CDC_AID1(tc_id) ;
GROUP BY ;
		serv_cat ;
INTO CURSOR ;
		CDC_AIDS		
		
INDEX ON serv_cat TAG cdc_aids

SELECT tServCat
SCAN ALL 	
	SCATTER MEMVAR		

	********************************************
	*- Aggregate by housing type ***************
	********************************************

	m.group = "Clients Housing Status*"
	m.header = .t.
   =OpenFile("Housing", "code")
* scan gives us the counts for each code in the housing file for this serv_cat
	SCAN
		m.label = descript
		SELECT hold1
		COUNT TO m.count FOR hold1.housing=housing.code AND hold1.serv_cat=m.serv_cat
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		Select Housing
	ENDSCAN

* this code handles "Not Entered" scenario (blank hold1.housing field)

	m.label = 'Not Entered'
	SELECT hold1
	SET RELA TO housing INTO housing ADDITIVE
	COUNT TO m.count FOR hold1.serv_cat=m.serv_cat AND EOF('housing')
	INSERT INTO aiaggser FROM MEMVAR

	******************************************************************
	*- Aggregate By risk exposure ************************************
	******************************************************************
	******************************************************************
	*- Aggregate By CDC Risk Categories *******************************
	******************************************************************
	m.group = "Clients by CDC Risk Category"
	m.header = .t.
	cCode = "  "
	
   	=OpenFile("cdc_risk", "code")

	=OpenFile("relhist", "tc_id")
	
	Select * ;
	From relhist ;
	Where date <= m.Date_To ;
	Into Cursor t_relh readwrite
	
	Index On tc_id+STR({01/01/2100}-date) TAG tc_id
*	=ReOpenCur("t_relh1", "t_relh")
*	Set Order to tc_id
		
	Select hold1
	Set Relation To tc_id INTO t_relh
	
	Select cdc_risk
	
	SCAN 
		m.label = cdc_risk.descript
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						t_relh.cdc_code = cdc_risk.code
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		Select cdc_risk
	ENDSCAN
	
	
	******************************************************************
	*- Aggregate By RW Risk Categories *******************************
	******************************************************************
	
	m.group = "Clients by RW Risk Category"
	m.header = .t.
	cCode = "  "
   	=OpenFile("rw_risk", "code")
	
	Select hold1
	Set Relation To tc_id INTO t_relh
	
	Select rw_risk
	
	SCAN 
		m.label = rw_risk.descript
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						t_relh.rw_code = rw_risk.code
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		Select rw_risk
	ENDSCAN
	
	Use in t_relh
	******************************************************************
	*- Aggregate By Insurance Statuses From Intake
	******************************************************************
	
	m.group = "Clients by Insurance Status (From Intake)"
	m.header = .t.
	cCode = "  "

	 	m.label = "Known" + Space(31)
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						hold1.insurance = 1
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.

		m.label = "No Insurance" + Space(23)
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						hold1.insurance = 3
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.

		m.label = "Unknown/Unreported" + Space(18)
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						hold1.insurance = 2
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.

		m.label = "Not Entered" + Space(18)
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						(hold1.insurance <> 1 and hold1.insurance <> 2 and hold1.insurance <> 3)

		If m.count > 0					
			INSERT INTO aiaggser FROM MEMVAR
			m.header = .f.
		Endif	

	******************************************************************
	*- Aggregate by Primary insurance type ***************************
	******************************************************************
* get clients in hold1 with a primary insurance status entered in system

	SELECT ;
		instype.descript as instype, ;
   	COUNT(*) AS ins_count ;
	FROM ;
		hold1, insstat, med_prov, instype ;
	WHERE ;
        hold1.serv_cat = m.serv_cat AND ;
		hold1.client_id = insstat.client_id AND ;
		Iif(!Empty(insstat.exp_dt), ;
					insstat.exp_dt >= m.Date_to and insstat.effect_dt <= m.Date_to, ;
					insstat.effect_dt <= m.Date_To) And ; 	
		insstat.prim_sec = 1 					AND ;
		insstat.prov_id = med_prov.prov_id 	AND ;
		instype.code = med_prov.instype 		AND ;
		insstat.client_id + DTOS(insstat.effect_dt)  ;
								IN (SELECT is.client_id + MAX(DTOS(effect_dt)) ;
									FROM insstat is ;
									WHERE ;
										is.prim_sec = 1 and ;
										Iif(!Empty(is.exp_dt), ;
										is.exp_dt >= m.Date_to and is.effect_dt <= m.Date_to, ;
										is.effect_dt <= m.Date_To) ;
									GROUP BY ;
										is.client_id)      ;
   GROUP BY ;
   	1 ;
   INTO CURSOR ;
   	ins_temp		
   	
	INDEX ON instype TAG instype

	=OpenFile("instype", "code")
	
	m.group  = 'Clients by Primary Insurance Type'
	m.header = .t.
	SCAN
		m.label = instype.descript
		IF Seek(instype.descript, 'ins_temp')
			m.count = ins_temp.ins_count 
		ELSE
			m.count = 0
		ENDIF
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
	ENDSCAN

* next select grabs all client_ids entered into insstat; we'll use this result in the next select
	SELECT ;
		client_id ;
	FROM ;
	   insstat ;
	WHERE ;
		Iif(!Empty(insstat.exp_dt), ;
			insstat.exp_dt >= m.Date_to and insstat.effect_dt <= m.Date_to, ;
			insstat.effect_dt <= m.Date_To) And ; 	
	  	insstat.prim_sec  = 1 				AND ;
	  	insstat.client_id + DTOS(insstat.effect_dt) ;
	  									IN (SELECT is.client_id + MAX(DTOS(effect_dt)) ;
	  										FROM insstat is ;
			  								WHERE is.prim_sec = 1 and ;
					 							Iif(!Empty(is.exp_dt), ;
												is.exp_dt >= m.Date_to and is.effect_dt <= m.Date_to, ;
												is.effect_dt <= m.Date_To) ;
										   GROUP BY ;
										   	is.client_id) ;
	INTO CURSOR newclien															
	
* now, create a select counting everything in hold1 that lacks current (active in this period) insurance status data
	SELECT ;
		'Not Entered or Expired'+SPACE(3) AS instype,  ;
		COUNT(*)                AS ins_count ;
	FROM ;
		hold1 ;
	WHERE ;
        hold1.serv_cat = m.serv_cat AND ;
		hold1.client_id NOT IN (SELECT client_id FROM newclien) ;
	INTO CURSOR ;
		ins_tem2 ;
	GROUP BY 	;
		1
		
* add next 3 lines to insert "Not Entered" record into report cursor
	If _tally > 0
		m.label = ins_tem2.instype
		m.count = ins_tem2.ins_count
		INSERT INTO aiaggser FROM MEMVAR
	Endif	
	
* close up cursors now
	USE IN ins_temp
	USE IN newclien
	USE IN ins_tem2
	**************************************************************
	******************************************************************
	*- Aggregate by Income, Household Size, and Poverty Status
	******************************************************************

	SELECT 	Hold1.client_id, ;
			Hold1.is_refus, ;
			Hold1.hshld_incm, ;
			Hold1.hshld_size ;
	FROM ;
		Hold1;
	WHERE ;
        hold1.serv_cat = m.serv_cat ;
	INTO CURSOR tmp_h1

* jss, 3/21/05, pov_level field has been increased to 6 digits
*!*   	Select Distinct tmp_h1.*, ;
*!*   			poverty.pov_level;
*!*   	From tmp_h1, poverty, cli_hous, address ;
*!*   	Where tmp_h1.client_id = cli_hous.client_id and ;
*!*   			cli_hous.hshld_id = address.hshld_id and ;
*!*   			Iif((address.st <> "AK" AND address.st <> "HI"), poverty.st = "US", address.st = poverty.st) and ;
*!*   			poverty.pov_year = Right(Dtoc(m.date_to),4) and ;
*!*   			poverty.hshld_size = tmp_h1.hshld_size and ;
*!*   			tmp_h1.is_refus = .f. ;
*!*   	Union ;
*!*   	Select Distinct tmp_h1.*, ;
*!*   			000000 as pov_level ;
*!*   	From tmp_h1 ;
*!*   	Where tmp_h1.hshld_size = 0 or tmp_h1.is_refus = .t. ;
*!*   	Into Cursor t_hous

 Select Distinct tmp_h1.*, ;
         poverty.pov_level;
   From tmp_h1, poverty, address ;
   Where tmp_h1.client_id = address.client_id and ;
         Iif((address.st <> "AK" AND address.st <> "HI"), poverty.st = "US", address.st = poverty.st) and ;
         poverty.pov_year = Right(Dtoc(m.date_to),4) and ;
         poverty.hshld_size = tmp_h1.hshld_size and ;
         tmp_h1.is_refus = .f. ;
   Union ;
   Select Distinct tmp_h1.*, ;
         000000 as pov_level ;
   From tmp_h1 ;
   Where tmp_h1.hshld_size = 0 or tmp_h1.is_refus = .t. ;
   Into Cursor t_hous
   	
	**USE IN poverty
	**Use in cli_hous 
	**Use in address 
	USE IN tmp_h1
	
* jss, 3/21/05, pov_level field has been increased to 6 digits
	Select DISTINCT * , ;
			Iif(pov_level = 0 , 000000, (hshld_incm * 100/pov_level)) as t_incm ; 
	From t_hous ;
	Into Cursor all_hous

	Use in t_hous
	
	m.group  = 'Clients by Income, Household Size, and Poverty Status'
	m.header = .t.

* jss, 10/25/04, include clients with household size > 0 and household income=0 in this group
		m.label = "At or below 100% of Poverty Level"
		SELECT all_hous
**		COUNT TO m.count FOR t_incm <= 100 and t_incm <> 0  and is_refus=.f. and hshld_size <> 0
		COUNT TO m.count FOR t_incm <= 100 and t_incm >= 0  and is_refus=.f. and hshld_size <> 0
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.

	***
		m.label = "At 101% to 200% of Poverty Level" 
		SELECT all_hous
		COUNT TO m.count FOR ;
						Between(t_incm, 101, 200)
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
	***
		m.label = "At 201% to 300% of Poverty Level"
		SELECT all_hous
		COUNT TO m.count FOR ;
						Between(t_incm, 201, 300)
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.

	***
		m.label = "Above 300% of Poverty Level"
		SELECT all_hous
		COUNT TO m.count FOR ;
						t_incm > 300
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.

	***
		m.label = "Refusing to report"
		SELECT all_hous
		COUNT TO m.count FOR ;
						is_refus
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		
	***
**		m.label = "Unknown"
		m.label = "Household Size Not Entered"
		SELECT all_hous
		COUNT TO m.count FOR ;
						hshld_size = 0 and is_refus =.f.
						
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		
	Use in all_hous
	
	******************************************************************
	*- Aggregate by HIV status
   * first, get clients' hivstatus

	******************************************************************
	*- Aggregate by HIV status
	=OpenFile("hivstat", "tc_id")
	Select * ;
	From hivstat ;
	Where hivstat.effect_dt <= m.Date_To ;
	Into Cursor t_hiv readwrite
	
	Index On tc_id+STR({01/01/2100}-effect_dt) TAG tc_id
*	=ReOpenCur("t_hiv1", "t_hiv")
*	Set Order to tc_id
	
	SELECT hold1
	SET RELATION TO tc_id INTO t_hiv

	=OpenFile("hstat", "code")
	m.group = 'Adult Clients by HIV Status*'
	m.header = .t.
	SCAN FOR hstat.adult
		m.label = hstat.descript
		SELECT hold1
		COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
						t_hiv.hivstatus = hstat.code
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		Select hstat
	ENDSCAN
	
	* jss, 10/26/00, add new section detailing case of CDC-defined AIDS
	******************************************************************
	*- Aggregate by CDC-Defined AIDS
	******************************************************************

	STORE 'Clients with CDC-Defined AIDS' TO m.group, m.label
	m.header = .t.
	
	IF SEEK(m.serv_cat,'CDC_AIDS')
		m.count = CDC_AIDS.cdcaidscnt
	ELSE
		m.count = 0
	ENDIF
	
	INSERT INTO aiaggser FROM MEMVAR
	m.header = .f.
	
	******************************************************************
	*- Aggregate Pediatric Clients by HIV status/Symptoms
	******************************************************************
	=OpenFile("hivstat", "tc_id")
	SELECT hold1
	SET RELATION TO tc_id INTO t_hiv
	
	* Prepare a list of HIV status/symptom combinations
	* jss, 12/98, only should have symptoms for hiv infected '05', hiv vertical (perinatal) exposure '06'
	SELECT ;
		hstat.code , symptom.code AS symptom, ;
		hstat.descript AS HIVStat, ;
		symptom.descript AS symptoms ;
	FROM ;
		hstat, symptom ;
	WHERE ;
		!hstat.adult AND INLIST(hstat.code,'05','06') ;
	UNION ALL ;
	SELECT ;
		hstat.code , "  " AS symptom, ;
		hstat.descript AS HIVStat, ;
		"Not entered" AS symptoms ;
	FROM ;
		hstat;
	WHERE ;
		!hstat.adult AND INLIST(hstat.code,'05','06') ;
	ORDER BY ;
		1, 2 ;
	INTO CURSOR ;
		hiv_sympt1

* here, add on the 2 symptomless codes (07,09)
   SELECT	* ;
   FROM ;
   	hiv_sympt1 ;
   UNION ;
   SELECT ;
   	hstat.code AS code, "  " AS symptom, ;
   	hstat.descript AS HIVStat, ;
   	SPACE(11) AS symptoms ;
   FROM ;
   	hstat ;	
   WHERE ;
   			Inlist(hstat.code, '07', '09', '11', '12') ;		
   INTO CURSOR ;
   	hiv_sympt  	


	m.group = 'Pediatric Clients by HIV Status/Symptoms*'
	m.header = .t.
	m.code = ""
	m.symptom= "" 
	SCAN 
		m.code = hiv_sympt.code
		m.symptom = symptom 
      IF INLIST(hiv_sympt.code,'05','06')
    		m.label = Trim(hiv_sympt.hivstat) +  ", Symptoms: "+hiv_sympt.symptoms
    		
	   	SELECT hold1
		   COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat ;
						AND ;
							t_hiv.hivstatus = m.code ;
						AND ;
							t_hiv.symptoms = m.symptom 
							
		   INSERT INTO aiaggser FROM MEMVAR
		   
		ELSE   
   		m.label = Trim(hiv_sympt.hivstat) 
	   	SELECT hold1
		   COUNT TO m.count FOR ;
                  hold1.serv_cat = m.serv_cat AND ;
					 t_hiv.hivstatus = m.code 
					 
		   INSERT INTO aiaggser FROM MEMVAR
		   
		ENDIF		   
		SELE hiv_sympt
		m.header = .f.
	ENDSCAN
	
	USE IN hiv_sympt
	Use in t_hiv
	
   ****************************
   * Clients HIV+ and PPD+
   ****************************
	=Seek(m.serv_cat, "hold3")
	
	tot_hiv = hold3.TotHIVPPD

	INSERT INTO aiaggser VALUES ;
	           (m.serv_cat, ;
	           	m.servcatdes,;
	           	"Clients HIV+ and PPD+ *", ;
	           	"Clients HIV+ AND PPD+", ;
	           	tot_hiv, ;
	           	.t., ;
	           	.f.)
	
	**************************************
	* TB therapy descriptions
	**************************************
	=OpenFile("tbstatus", "tc_id")

	Select * ;
	From tbstatus ;
	Where tbstatus.effect_dt <= m.Date_To ;
	Into Cursor t_tb1
			
	=OpenFile("treatmen", "code")
	m.group = 'Clients by TB Treatment*'
	m.header = .t.
	SCAN
		m.label = treatmen.descript
		cCode = treatmen.code
		

		Select Count(*) as tot ;
		From hold1, t_tb1 ;
		Where   hold1.serv_cat = m.serv_cat AND ;
				hold1.tc_id = t_tb1.tc_id and ;
				t_tb1.treatment = cCode ;
		Into Cursor t_tot1		
		
		m.count = t_tot1.tot
		INSERT INTO aiaggser FROM MEMVAR
		m.header = .f.
		Use in t_tot1
		
		Select treatmen
	ENDSCAN
	Use in t_tb1
	
	******************************************************************
	SELECT Hold1.serv_cat, Hold1.servcatdes, ;
		'Clients In Special Populations*' AS group, ;
	    Speclpop.descript AS label, ;
	        COUNT(*) AS count, ;
	       .f. AS header ;
	 FROM Hold1, ;
	      Ai_spclp, ;
	      Speclpop;
	WHERE Ai_spclp.tc_id = Hold1.tc_id;
	  AND Speclpop.code = Ai_spclp.code;
	  AND Hold1.serv_cat = m.serv_cat ;
	GROUP BY 2,4 ;
	ORDER BY 2,4 ;
	 INTO ARRAY aTemp
	
	IF _TALLY > 0
		aTemp[1,6] = .t.
		INSERT INTO aiaggser FROM ARRAY aTemp
	ENDIF
	
	******************************************************************
	*- Aggregate By county
	SELECT Hold1.serv_cat, Hold1.servcatdes, ;
	       'Clients by County' AS group    ,;
          IIF(EMPTY(County), Padr('Not Entered',25), County) AS label  ,;
	       COUNT(*) AS count, ;
	       .f. AS header ;
	  FROM hold1 ;
	  WHERE Hold1.serv_cat = m.serv_cat ;
	  GROUP BY 2,4 ;
	  ORDER BY 2,4 ;
	  INTO ARRAY aTemp
	
	IF _TALLY > 0
		aTemp[1,6] = .t.
		INSERT INTO aiaggser FROM ARRAY aTemp
	ENDIF
	
	
	******************************************************************
	*- Aggregate By zip code
	SELECT serv_cat, 																		 ;
		   servcatdes,															          ;
		   'Clients by ZIP code'									 AS group   ,;
	       IIF(zip='     -    ','Not Entered', zip+SPACE(10)) AS label   ,;
	       COUNT(*) 														 AS count   ,;
	       .f. AS header                          								 ;
	  FROM hold1                                  								 ;
	  WHERE serv_cat = m.serv_cat 														 ;
     GROUP BY 2,4   		                               						 ;
	  ORDER BY 2,4                                  							 ;
	  INTO ARRAY aTemp
	
	IF _TALLY > 0
		aTemp[1,6] = .t.
		INSERT INTO aiaggser FROM ARRAY aTemp
	ENDIF
	
	******************************************************************
	*- Aggregate by referral source
	SELECT Hold1.serv_cat, Hold1.servcatdes, ;
		'Clients by Referral Source' AS group    ,;
	       referalsrc AS label  ,;
	       COUNT(*) AS count ,;
	       .f. AS header ;
	  FROM hold1 ;
	  WHERE Hold1.serv_cat = m.serv_cat ;
	  GROUP BY 2,4 ;
	  ORDER BY 2,4 ;
	  INTO ARRAY aTemp
	
	IF _TALLY > 0
		aTemp[1,6] = .t.
		INSERT INTO aiaggser FROM ARRAY aTemp
	ENDIF
	
	******************************************************************
	*- Family-Centered/Collateral Case Management:
	SELECT serv_cat, servcatdes, ;
	       'Family-Centered/Collateral Case Mgmt (of Total Possible)' AS Group, ;
	       Descript AS Label,  Count, .F. AS Header, NotCount ;
	  FROM FamCollSum ;
	  WHERE serv_cat = m.serv_cat ;
	  INTO ARRAY aTemp
	
	IF _TALLY > 0
		aTemp[1,6] = .t.
		INSERT INTO aiaggser FROM ARRAY aTemp
	ENDIF
	
   ********************************************************************	
	
*!*	oApp.Msg2User('OFF')
	
	SELECT tServCat
ENDSCAN

cReportSelection = .aGroup(nGroup)

*SELECT aiaggser
Select aiaggser.*, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   lcServA as lcServ, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Dt_from_a as Date_from, ;
   Dt_to_a as date_to, ;
   '' as lcprog, ;
   nTotCli as nTotCli, ;
   nTotCliAn as nTotCliAn, ;
   cOrderBy as sort_order ;   
From aiaggser ;
Into Cursor aiaggser2

m.BegActTot=BegActTo.tot
m.CliNewTot=CliNewTo.tot
m.NewActTot=NewActTo.tot
m.ReopTotot=ReopTota.tot
m.ClosPeTot=ClosPeTo.tot
m.BaClosTot=BaClosTo.tot
m.CnClosTot=CnClosTo.tot
m.ReClosTot=ReClosTo.tot
m.EndActTot=EndActTo.tot
m.TotDChild=CliNewTo.totdchild
m.TotHHead =CliNewTo.tothhead

m.BegActTotanon=BegActTo.totanon
m.CliNewTotanon=CliNewTo.totanon
m.NewActTotanon=NewActTo.totanon
m.ReopTototanon=ReopTota.totanon
m.ClosPeTotanon=ClosPeTo.totanon
m.BaClosTotanon=BaClosTo.totanon
m.CnClosTotanon=CnClosTo.totanon
m.ReClosTotanon=ReClosTo.totanon
m.EndActTotanon=EndActTo.totanon



*!*        m.BegActTotanon as BegActTotanon, ;
*!*         m.CliNewTotanon as CliNewTotanon, ;
*!*         m.NewActTotanon as NewActTotanon, ;
*!*         m.ReopTototanon as ReopTototanon, ;
*!*         m.ClosPeTotanon as ClosPeTotanon, ;
*!*         m.BaClosTotanon as BaClosTotanon, ;
*!*         m.CnClosTotanon as CnClosTotanon, ;
*!*         m.ReClosTotanon as ReClosTotanon, ;
*!*         m.EndActTotanon as EndActTotanon, ;
*!*         m.TotDChild as TotDChild, ;
*!*         m.TotHHead  as TotHHead,  ;

if nrep = 2
   select a.*, m.BegActTot as BegActTot, ;
      m.CliNewTot as CliNewTot, ;
      m.NewActTot as NewActTot, ;
      m.ReopTotot as ReopTotot, ;
      m.ClosPeTot as ClosPeTot, ;
      m.BaClosTot as BaClosTot, ;
      m.CnClosTot as CnClosTot, ;
      m.ReClosTot as ReClosTot, ;
      m.EndActTot as EndActTot, ;
      m.TotDChild as TotDChild, ;
      m.TotHHead  as TotHHead,  ;
      m.BegActTotanon as BegActTotanon, ;
      m.CliNewTotanon as CliNewTotanon, ;
      m.NewActTotanon as NewActTotanon, ;
      m.ReopTototanon as ReopTototanon, ;
      m.ClosPeTotanon as ClosPeTotanon, ;
      m.BaClosTotanon as BaClosTotanon, ;
      m.CnClosTotanon as CnClosTotanon, ;
      m.ReClosTotanon as ReClosTotanon, ;
      m.EndActTotanon as EndActTotanon, ;
      "C" as rpt_type, ;
      gcagencyname as agencyname, oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate ;
      from aiaggser2 as a ;
      WHERE a.count > 0 ;
      into cursor tmp 
ELSE
   select a.*, m.BegActTot as BegActTot, ;
      m.CliNewTot as CliNewTot, ;
      m.NewActTot as NewActTot, ;
      m.ReopTotot as ReopTotot, ;
      m.ClosPeTot as ClosPeTot, ;
      m.BaClosTot as BaClosTot, ;
      m.CnClosTot as CnClosTot, ;
      m.ReClosTot as ReClosTot, ;
      m.EndActTot as EndActTot, ;
      m.TotDChild as TotDChild, ;
      m.TotHHead  as TotHHead,  ;
      m.BegActTotanon as BegActTotanon, ;
      m.CliNewTotanon as CliNewTotanon, ;
      m.NewActTotanon as NewActTotanon, ;
      m.ReopTototanon as ReopTototanon, ;
      m.ClosPeTotanon as ClosPeTotanon, ;
      m.BaClosTotanon as BaClosTotanon, ;
      m.CnClosTotanon as CnClosTotanon, ;
      m.ReClosTotanon as ReClosTotanon, ;
      m.EndActTotanon as EndActTotanon, ;
      "A" as rpt_type, ;
      gcagencyname as agencyname, oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate ;
      from aiaggser2 as a ;
      into cursor tmp 
endif

*!*   * jss, 8/30/04, exclude zero counts for condensed version of report
*!*   IF nRep=2
*!*   	SET FILTER TO count>0
*!*   ENDIF

* make sure there are clients to report on
* jss, 8/10/04, fix problem, was claiming nothing found when data was actually there
GO TOP
IF EOF()
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF
*!*
*!* added the following 05/28/2009
*!* for crystal reports...
*!* jim power


SELECT tmp
COPY to crRptpath+"client_demographics.dbf"
               
DECLARE INTEGER ShellExecute IN shell32.dll ; 
        INTEGER hndWin, ; 
        STRING caction, ; 
        STRING cFilename, ; 
        STRING cParms, ;  
        STRING cDir, ; 
        INTEGER nShowWin



IF wreport = 'D'
   Lcparms = "client_demographics.rpt"
ELSE
   Lcparms = "client_demographics_summary.rpt"
endif
  
LcFileName = "i:\ursver6\project\libs\display_reports.exe" 
LcAction = "open" 
Lcdir = "i:\ursver6\airs_crreports\"
ShellExecute(0,LcAction,Lcfilename,lcparms,lcdir,1)

* jss, 8/30/04, add code here to print either aiaggser or aiaggsr1, depending on variable nrep
*!*   DO CASE
*!*   CASE nRep=1

*!*         gcRptName = 'rpt_aggser'
*!*         Do Case
*!*         CASE lPrev = .f.
*!*            Report Form rpt_aggser To Printer Prompt Noconsole NODIALOG 
*!*         CASE lPrev = .t.     &&Preview
*!*            oApp.rpt_print(5, .t., 1, 'rpt_aggser', 1, 2)
*!*         EndCase
*!*         
*!*   CASE nRep=2

*!*         gcRptName = 'rpt_aggsr1'
*!*         Do Case
*!*         CASE lPrev = .f.
*!*            Report Form rpt_aggsr1 To Printer Prompt Noconsole NODIALOG 
*!*         CASE lPrev = .t.     &&Preview
*!*            oApp.rpt_print(5, .t., 1, 'rpt_aggsr1', 1, 2)
*!*         EndCase

*!*   ENDCASE	

USE IN hold3
*USE IN aiaggser
*DO Rest_Env2 WITH aFiles_Open	
Return

*************************************************************************
PROCEDURE Rpt_AgeSer
*PARAMETER nClick,nTimes
**********************************************************************
* this is the age by sex by race crosstabs report
* the different aggregates for the clients are done and reported here
**********************************************************************
rep_title1='Age by Sex by Ethnicity/Race for Clients with Services this Period'

* Summary Information
*- cross tabs - age by race by gender

* "RaAgeHold1" cursor holds distinct clients + program 
SELECT DIST Tc_ID, Serv_Cat, ServCatDes, SPACE(18) AS Race, ;
		White, Blafrican, Asian, Hawaisland, ;
		Indialaska, Unknowrep, someother , Hispanic, ;
		IIF(sex="M","Male    ", "Female  ") AS Gender, ;
		Dob, NewAgency, ActivAgen, CalcAge(m.date_to, Dob) AS Client_Age ;
	FROM Hold1 ;
	INTO CURSOR RaAgeHold1 readwrite
	
*=ReopenCur("RaAgeHold0","RaAgeHold1")

SELECT RaAgeHold1
REPLACE ALL race WITH GetRace()	

* "RaAgeSumm" cursor holds distinct clients (no dups for multi program enrollments)
SELECT DIST Tc_ID, Race, Gender, Hispanic, Dob, Client_Age, NewAgency, ActivAgen ;
	FROM RaAgeHold1 ;
	INTO CURSOR RaAgeSumm

* "hold3" cursor holds summed age group counts for those new in agency by type+race+gender

SELECT "Hispanic             " as hispanic, race, Gender, ;
	SUM(IIF(BETWEEN(Client_Age,0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(BETWEEN(Client_Age,60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 70,1,0)) AS Age70Plus ,;
	SUM(IIF(Empty(dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeSumm ;
WHERE ;
	hispanic = 2 ;	
GROUP BY ;
	1, 2, 3 ;
INTO CURSOR ;
	t_hisp

SELECT "Non-Hispanic         " as hispanic, race, Gender, ;
	SUM(IIF(BETWEEN(Client_Age,0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(BETWEEN(Client_Age,60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 70,1,0)) AS Age70Plus ,;
	SUM(IIF(Empty(dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeSumm ;
WHERE ;
	hispanic = 1 ;	
GROUP BY ;
	1, 2, 3 ;
INTO CURSOR ;
	t_nhisp
	
	nUsed = 0
	
SELECT "Ethnicity Not Entered" as hispanic, race, Gender, ;
	SUM(IIF(BETWEEN(Client_Age,0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(BETWEEN(Client_Age,60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 70,1,0)) AS Age70Plus ,;
	SUM(IIF(Empty(dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeSumm ;
WHERE ;
	hispanic <> 1 and hispanic <> 2 ;	
GROUP BY ;
	1, 2, 3 ;
INTO CURSOR ;
	t_eth
	
IF _tally <> 0
			SELECT * ;
				FROM t_hisp ;
			UNION ALL ;
			SELECT * ;
				FROM t_nhisp ;
			UNION all;
			Select * ;
				FROM t_eth ;
			INTO CURSOR Hold3
		nUsed = 1	
Else

			SELECT * ;
				FROM t_hisp ;
			UNION ALL ;
			SELECT * ;
				FROM t_nhisp ;
			INTO CURSOR Hold3
Endif

use in t_hisp
use in t_nhisp

If used('t_eth')
	Use in t_eth
Endif	

sum_tally=_TALLY

* Pick up all unused race descriptions - males hispanic
SELECT ;
	"Hispanic             " as hispanic, race.code AS race, 'Male  ' as gender ;
FROM ;
	race ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM RaAgeSumm ;
					WHERE 	race.code = RaAgeSumm.race AND ;
							RaAgeSumm.gender = 'Male'  AND ;
							RaAgeSumm.hispanic = 2) ;
INTO CURSOR temp1 

* Pick up all unused ethnicities - females hispanic
SELECT ;
	"Hispanic             " as hispanic, race.code AS race, 'Female' as gender ;
FROM ;
	race ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM RaAgeSumm ;
					WHERE 	race.code = RaAgeSumm.race  AND ;
							RaAgeSumm.gender = 'Female' AND ;
							RaAgeSumm.hispanic = 2) ;
INTO CURSOR temp2

* Pick up all unused race descriptions - males non-hispanic
SELECT ;
	"Non-Hispanic         " as hispanic, race.code AS race, 'Male  ' as gender ;
FROM ;
	race ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM RaAgeSumm ;
					WHERE 	race.code = RaAgeSumm.race AND ;
							RaAgeSumm.gender = 'Male'  AND ;
							RaAgeSumm.hispanic = 1) ;
INTO CURSOR temp3 

* Pick up all unused ethnicities - females non-hispanic
SELECT ;
	"Non-Hispanic         " as hispanic, race.code AS race, 'Female' as gender ;
FROM ;
	race ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM RaAgeSumm ;
					WHERE 	race.code = RaAgeSumm.race  AND ;
							RaAgeSumm.gender = 'Female' AND ;
							RaAgeSumm.hispanic = 1) ;
INTO CURSOR temp4

If nUsed = 1

	SELECT "Ethnicity Not Entered" as hispanic, code AS race, 'Male' AS Gender ;
	FROM ;
		race ;
	WHERE ;
		NOT EXIST (SELECT * ;
					FROM RaAgeSumm ;
					WHERE 	race.code = RaAgeSumm.race  AND ;
							RaAgeSumm.gender = 'Male' AND ;
							RaAgeSumm.hispanic <> 1 and ;
							RaAgeSumm.hispanic <> 2) ;
		INTO CURSOR t_eth1

	* Pick up all unused race - females ethnicity not entered
	SELECT "Ethnicity Not Entered" as hispanic,code AS race, 'Female' AS Gender ;
	FROM ;
		race ;
	WHERE ;
		NOT EXIST (SELECT * ;
					FROM RaAgeSumm ;
					WHERE 	race.code = RaAgeSumm.race  AND ;
							RaAgeSumm.gender = 'Female' AND ;
							RaAgeSumm.hispanic <> 1 and ;
							RaAgeSumm.hispanic <> 2) ;	
	INTO CURSOR t_eth2
EndIf


IF Used("AgeRaceSum")
	USE IN AgeRaceSum
ENDIF

SELECT 0
USE (DBF("hold3")) AGAIN ALIAS AgeRaceSum EXCLUSIVE

APPEND FROM (DBF("temp1"))
APPEND FROM (DBF("temp2"))
APPEND FROM (DBF("temp3"))
APPEND FROM (DBF("temp4"))

IF USED("t_eth1")
	APPEND FROM (DBF("t_eth1"))
	USE IN t_eth1
ENDIF

IF USED("t_eth2")
	APPEND FROM (DBF("t_eth2"))
	USE IN t_eth2
ENDIF

* now, "AgeRaceSum" cursor holds all races for male and female, including those that are empty (appended from temp1 and temp2)
USE IN hold3
USE IN temp1
USE IN temp2
USE IN temp3
USE IN temp4



*- Detail Information (service category level)
*- cross tabs - age by race by sex

SELECT "Hispanic             " as hispanic, Serv_Cat, ServCatDes, Race, Gender, ;
	SUM(IIF(BETWEEN(Client_Age,0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(BETWEEN(Client_Age,60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 70,1,0)) AS Age70Plus ,;
	SUM(IIF(Empty(Dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeHold1 ;
WHERE ;
	hispanic = 2;
GROUP BY ;
	1,2,4,5 ;
ORDER BY ;
	1,2,4,5 ;	
INTO CURSOR ;
	t_hisp

SELECT "Non-Hispanic         " as hispanic, Serv_Cat, ServCatDes, Race, Gender, ;
	SUM(IIF(BETWEEN(Client_Age,0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(BETWEEN(Client_Age,60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 70,1,0)) AS Age70Plus ,;
	SUM(IIF(Empty(Dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeHold1 ;
WHERE ;
	hispanic = 1;
GROUP BY ;
	1,2,4,5 ;
ORDER BY ;
	1,2,4,5 ;	
INTO CURSOR ;
	t_nhisp
	
	nUsed = 0
	
SELECT "Ethnicity Not Entered" as hispanic, Serv_Cat, ServCatDes, Race, Gender, ;
	SUM(IIF(BETWEEN(Client_Age,0,12),1,0))   AS Age0_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(BETWEEN(Client_Age,60,69),1,0))  AS Age60_69  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 70,1,0)) AS Age70Plus ,;
	SUM(IIF(Empty(Dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeHold1 ;
WHERE ;
	hispanic <> 1 and hispanic <> 2;
GROUP BY ;
	1,2,4,5 ;
ORDER BY ;
	1,2,4,5 ;	
INTO CURSOR ;
	t_det
	
	IF _tally <> 0
		SELECT * ;
			FROM t_hisp ;
		UNION ALL ;	
		Select * ;
			FROM t_nhisp ;	
		UNION ALL ;
		Select * ;
			FROM t_det;	
		INTO CURSOR Hold3
	 	nUsed =1	
	Else
		SELECT * ;
			FROM t_hisp ;
		UNION ALL ;	
		Select * ;
			FROM t_nhisp ;	
		INTO CURSOR Hold3
	Endif	

USE IN t_hisp
USE IN t_nhisp


det_tally=_TALLY

* jss, 4/25/2000, now, check to see if there is info at agency OR program level before reporting
*                      no info found

* make sure there are clients to report on

IF (sum_tally+det_tally)=0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF

* get all the program id's found so far
SELECT DIST Serv_Cat, ServCatDes ;
	FROM Hold3 ;
	INTO CURSOR tHold1

* this cursor will contain one record for each program and race for male gender
SELECT DIST ;
	thold1.Serv_Cat, thold1.ServCatDes, Race.code as Race, 'Male' as gender ;	
FROM ;
	thold1, race ;
INTO CURSOR ;
	tHoldm
	
* Pick up all unused ethnicities - males
SELECT ;
	tholdm.Serv_Cat, tholdm.ServCatDes, "Hispanic             " as hispanic, tHoldm.Race, tHoldm.Gender ;
FROM ;
	tHoldm ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM Hold3 ;
					WHERE   Hold3.Serv_Cat = tHoldm.Serv_Cat AND ;
							hold3.race    = tHoldm.race AND ;
							Hold3.gender = 'Male' and ;
							Rtrim(hold3.hispanic) ='Hispanic') ;
INTO CURSOR temp1 

* this cursor will contain one record for each program and race for female gender
SELECT DIST ;
	thold1.Serv_Cat, thold1.ServCatDes, Race.code as Race, 'Female' as gender ;	
FROM ;
	thold1, race ;
INTO CURSOR ;
	tHoldf
	
* Pick up all unused ethnicities - females hispan

*					WHERE   Hold3.Serv_Cat = tHoldf.ServCatDes AND 
* jss, 8/17/04, correct problem in where clause d/t improper comparison of serv_cat and servcatdes
SELECT ;				   	
	tholdf.Serv_Cat, tholdf.ServCatDes, "Hispanic             " as hispanic, tholdf.Race, tholdf.Gender ;
FROM ;
	tHoldf ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM Hold3 ;
					WHERE   Hold3.Serv_Cat = tHoldf.Serv_Cat AND ;
							hold3.race    = tHoldf.race AND ;
							Hold3.gender = 'Female' and ;
							Rtrim(hold3.hispanic) ='Hispanic') ;
INTO CURSOR temp2
 
**Male Non-Hispan

*					WHERE   Hold3.Serv_Cat = tHoldm.ServCatDes AND 
* jss, 8/17/04, correct problem in where clause d/t improper comparison of serv_cat and servcatdes
SELECT ;
	tholdm.Serv_Cat, tholdm.ServCatDes, "Non-Hispanic         " as hispanic, tHoldm.Race, tHoldm.Gender ;
FROM ;
	tHoldm ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM Hold3 ;
					WHERE   Hold3.Serv_Cat = tHoldm.Serv_Cat AND ;
							hold3.race    = tHoldm.race AND ;
							Hold3.gender = 'Male' and ;
							Rtrim(hold3.hispanic) ='Non-Hispanic') ;
INTO CURSOR temp3 

**Female non-hisp

*					WHERE   Hold3.Serv_Cat = tHoldf.ServCatDes AND 
* jss, 8/17/04, correct problem in where clause d/t improper comparison of serv_cat and servcatdes
SELECT ;
	tholdf.Serv_Cat, tholdf.ServCatDes, "Non-Hispanic         " as hispanic, tHoldf.Race, tHoldf.Gender ;
FROM ;
	tHoldf ;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM Hold3 ;
					WHERE   Hold3.Serv_Cat = tHoldf.Serv_Cat AND ;
							hold3.race    = tHoldf.race AND ;
							Hold3.gender = 'Female' and ;
							Rtrim(hold3.hispanic) ='Non-Hispanic') ;
INTO CURSOR temp4

If nUsed = 1
	**Male Not entered
	SELECT ;
		tholdm.Serv_Cat, tholdm.ServCatDes, "Ethnicity Not Entered" as hispanic, tHoldm.Race, tHoldm.Gender ;
	FROM ;
		tHoldm ;
	WHERE ;
		NOT EXIST (SELECT * ;
						FROM Hold3 ;
						WHERE   Hold3.Serv_Cat = tHoldm.Serv_Cat AND ;
								hold3.race    = tHoldm.race AND ;
								Hold3.gender = 'Male' and ;
								Rtrim(hold3.hispanic) ='Ethnicity Not Entered') ;
	INTO CURSOR t_det1

	**Female not entered
	SELECT ;
		tholdf.Serv_Cat, tholdf.ServCatDes, "Ethnicity Not Entered" as hispanic, tHoldf.Race, tHoldf.Gender ;
	FROM ;
		tHoldf ;
	WHERE ;
		NOT EXIST (SELECT * ;
						FROM Hold3 ;
						WHERE   Hold3.Serv_Cat = tHoldf.Serv_Cat AND ;
								hold3.race    = tHoldf.race AND ;
								Hold3.gender = 'Female' and ;
								Rtrim(hold3.hispanic) ='Ethnicity Not Entered') ;
	INTO CURSOR t_det2
Endif


IF USED('race')
	USE IN race
ENDIF

Use in tHoldf
Use in tHoldm

SELECT 0
USE (DBF("hold3")) AGAIN ALIAS Age_Race0 EXCLUSIVE
INDEX ON Serv_Cat + hispanic+ race + gender TAG typeprog

APPEND FROM (DBF("temp1"))
APPEND FROM (DBF("temp2"))
APPEND FROM (DBF("temp3"))
APPEND FROM (DBF("temp4"))

IF USED("t_det1")
	APPEND FROM (DBF("t_det1"))
	USE IN t_det1
ENDIF

IF USED("t_det2")
	APPEND FROM (DBF("t_det2"))
	USE IN t_det2
ENDIF


* we now have race detail info in Age_Race0, append race summary, and hispanic detail and summary
* Append Summary Race Information
APPEND FROM (DBF("AgeRaceSum"))

IF USED('temp1')
	USE IN temp1
ENDIF

IF USED('temp2')
	USE IN temp2
ENDIF

IF USED('tHold1')
	USE IN tHold1
ENDIF

IF USED('AgeRaceSum')
	USE IN AgeRaceSum
ENDIF

*!*oApp.Msg2User('OFF')

*cReportSelection = ""
cReportSelection = .aGroup(nGroup)

SELECT ;
	Age_Race0.*, ;
	.f. AS Enr_Req, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   lcServA as lcServ, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Dt_from_a as Date_from, ;
   Dt_to_a as date_to, ;
   cOrderBy as sort_order ;      
FROM ;
	Age_Race0 ;
INTO CURSOR ;
	Age_Race readwrite

*=ReopenCur("Age_Race1","Age_Race")	
SELECT Age_Race
GO TOP

*!*
*!* added the following 05/29/2009
*!* for crystal report processing
*!* jim power
       
SELECT a.*, r.descript,oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate, gcagencyname as agencyname ;
     FROM age_race as a ;
     LEFT OUTER JOIN race as r ON r.code = a.race ;
     INTO CURSOR temp
     INDEX ON Serv_cat + hispanic +race + gender TAG typesc   
coPY to crRptpath+"age_race_encounters.dbf"
              
DECLARE INTEGER ShellExecute IN shell32.dll ; 
        INTEGER hndWin, ; 
        STRING caction, ; 
        STRING cFilename, ; 
        STRING cParms, ;  
        STRING cDir, ; 
        INTEGER nShowWin
  
LcFileName = "i:\ursver6\project\libs\display_reports.exe" 
LcAction = "open" 
Lcparms = "service_age_ethnicity.rpt"
Lcdir = "i:\ursver6\airs_crreports\"
ShellExecute(0,LcAction,Lcfilename,lcparms,lcdir,1)
       
       
*!*          
*!*   gcRptName = 'rpt_ageser'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*      Report Form rpt_ageser To Printer Prompt Noconsole NODIALOG 
*!*   CASE lPrev = .t.     &&Preview
*!*      oApp.rpt_print(5, .t., 1, 'rpt_ageser', 1, 2)
*!*   EndCase
      
USE IN RaAgeHold1
USE IN RaAgeSumm
USE IN hold3
*USE IN age_race
USE IN age_race0
*USE IN age_race1

RETURN

****************
FUNCTION GetRace
****************
tRace=SPACE(2)
DO CASE

**	CASE white=1 AND ( blafrican=1 OR  asian=1 OR  hawaisland=1 OR  indialaska=1)
**		tRace='60'
**	CASE blafrican=1 AND ( asian=1 OR  hawaisland=1 OR  indialaska=1)
**		tRace='60'
**	CASE  asian=1 AND ( hawaisland=1 OR  indialaska=1)
**		tRace='60'
**	CASE  hawaisland=1 AND  indialaska=1
**		tRace='60'

* jss, 4/22/03, add "someother" to logic for determining multiple race designation of "60"
* jss, 6/5/03, account for situation where no race has been entered at all; count it as unknown/unreported
	CASE white=1 AND (blafrican=1 OR  asian=1 OR  hawaisland=1 OR  indialaska=1 OR someother=1)
		tRace='60'
	CASE blafrican=1 AND (asian=1 OR  hawaisland=1 OR  indialaska=1 OR someother=1)
		tRace='60'
	CASE asian=1 AND (hawaisland=1 OR  indialaska=1 OR someother=1)
		tRace='60'
	CASE hawaisland=1 AND (indialaska=1 OR someother=1)
		tRace='60'
	CASE indialaska=1 AND someother=1
		tRace='60'
	CASE white=1 
		tRace='10'
	CASE blafrican=1 
		tRace='20'
	CASE asian=1 
		tRace='30'
	CASE hawaisland=1 
		tRace='40'
	CASE indialaska=1 
		tRace='50'
	CASE  someother=1 
		tRace='70'	
	CASE unknowrep=1 
		tRace='90'
	OTHERWISE
		tRace='90'	
ENDCASE

RETURN tRace	


**********************************************************************
FUNCTION CalcAge
PARAMETERS tdDt2Calc2, tdDOB
PRIVATE ALL LIKE j*
m.jcOldDate=SET("date")
SET DATE AMERICAN
m.jnAge=YEAR(m.tdDt2Calc2)-YEAR(m.tdDOB)-;
        IIF(CTOD(LEFT(DTOC(m.tdDOB),6)+STR(YEAR(m.tdDt2Calc2)))>m.tdDt2Calc2,1,0)
SET DATE &jcOldDate
RETURN m.jnAge

**********************************************************
FUNCTION CDC_AID1
**********************************************************
PARAMETER cTC_ID, dCDCDate
PRIVATE lResult
lResult = .F.
dCDCDate = {}

IF HIV_Pos(cTC_ID)

	SELECT ;
		testres.tc_id , ;
		testres.testdate AS DATE ;
	FROM ;
		testres ;
	WHERE ;
		testtype = '06' ;
		AND testres.tc_id = cTC_ID ;
		AND ((!EMPTY(COUNT) AND COUNT < 200) OR (!EMPTY(percent) AND percent < 14)) and ;
		testres.testdate <= m.date_to ;
	UNION ;
	SELECT ;
		ai_diag.tc_id , ;
		ai_diag.diagdate AS DATE ;
	FROM ;
		ai_diag ;
	WHERE ;
		!EMPTY(hiv_icd9) ;
		AND ai_diag.tc_id = cTC_ID  and ;
		ai_diag.diagdate <= m.date_to ;
	INTO ARRAY ;
		aCDC_AIDS ;
	ORDER BY 2 

	IF _TALLY <> 0
		lResult = .T.
		dCDCDate = aCDC_AIDS[1, 2]
	ENDIF
ENDIF

RETURN lResult

**********************************************************
FUNCTION HIV_Pos
**********************************************************
*  Function.........: HIV_Pos
*  Created..........: 02/19/98   10:24:58
*) Description......: Detects if client is HIV positive
**********************************************************
PARAMETERS cTC_ID
PRIVATE lHIV_Pos

SELECT ;
   hstat.hiv_pos;
FROM ;
   hivstat, ;
   hstat ;
WHERE ;
   hivstat.tc_id = cTc_id ;
   AND hivstat.hivstatus = hstat.code  and ;
   hivstat.effect_dt <= m.date_to ;
   AND Dtos(hivstat.effect_dt) + hivstat.status_id + hivstat.hivstatus  = (SELECT MAX(Dtos(effect_dt) + status_id + hivstatus) ;
                              FROM ;
                                 hivstat f2 ;
                              WHERE ;
                                 f2.tc_id = cTc_id and ;
                                     f2.effect_dt <= m.date_to) ;
INTO ARRAY ;
   aHivPos



IF _TALLY > 0      
   lHIV_Pos = aHivPos(1)
ELSE
   lHIV_Pos = .f.
ENDIF      

RETURN lHIV_Pos

********************
Procedure Rpt_EncSer
********************

=OpenFile('Serv_list')
=OpenFile('Enc_list')
=OpenFile('Ai_enc')
*=OpenFile('Enc_type')
=OpenFile('Serv_cat')

* select all encounter data within date range 
*!*   SELECT DISTINCT Ai_Enc.Tc_ID, ;
*!*          Ai_Enc.Act_ID, ;
*!*         Ai_Enc.Enc_type   AS Enc_Code, ;
*!*         Ai_Enc.Serv_Cat   AS Serv_CCode, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          cli_cur.Anonymous , ;
*!*          Ai_Enc.Act_dt     AS Act_dt ;
*!*     FROM cli_cur, ;
*!*          Ai_Enc, ;
*!*          Serv_Cat, ;
*!*          Enc_Type ;
*!*    WHERE Ai_Enc.Tc_ID    = cli_cur.Tc_ID ;
*!*      AND Ai_Enc.Serv_Cat = lcServA ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Act_dt  >= m.Date_From ;
*!*      AND Ai_Enc.Act_dt  <= m.Date_To ;
*!*    INTO CURSOR tEncCur1

*!*   SELECT    * ;
*!*   FROM    tEncCur1 ;
*!*   INTO CURSOR ;
*!*         EncSer_Cur

** VT 08/12/2008 Dev Tick 4623  add Hold1 

SELECT DISTINCT Ai_Enc.Tc_ID, ;
       Ai_Enc.Act_ID, ;
      Serv_Cat.Descript AS Serv_Cat, ;
      Enc_list.Description AS Enc_type, ;
       cli_cur.Anonymous , ;
       Ai_Enc.Act_dt     AS Act_dt ;
  FROM cli_cur, ;
       Ai_Enc, ;
       Serv_Cat, ;
       Enc_list, ;
       hold1 ; 
 WHERE Ai_Enc.Tc_ID    = cli_cur.Tc_ID ;
   And ai_enc.tc_id = hold1.tc_id ; 
   AND Ai_Enc.Serv_Cat = lcServA ;
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Ai_Enc.Act_dt  >= m.Date_From ;
   AND Ai_Enc.Act_dt  <= m.Date_To ;
 INTO CURSOR tEncCur1

SELECT    * ;
FROM    tEncCur1 ;
INTO CURSOR ;
      EncSer_Cur

***************************************************************

* calculate number of services and clients within a service
* for anonymous clients

*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*         Service.Code AS ServCode, ;
*!*          COUNT(*) AS NumbServAn, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
*!*         SUM(Ai_Serv.s_value) AS NumValueAn, ;
*!*         SUM(Ai_Serv.NumItems) AS NumbItemAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3 ;
*!*   UNION ALL ;
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*          "No Services Recorded" AS Service, ;
*!*         "ZZZZ" AS ServCode, ;
*!*          0 AS NumbServAn, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
*!*         0 AS NumValueAn, ;
*!*          0 AS NumbItemAn ;
*!*     FROM EncSer_Cur ;
*!*    WHERE EncSer_Cur.Anonymous=.T. ;
*!*      AND EncSer_Cur.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3 ;
*!*    INTO CURSOR EncServAn

*!*   * adding the alias changes what doesn't match
*!*   INDEX ON Serv_Cat + Enc_Type + ServCode TAG ServEnc

* jss, 12/6/06, use serv_list to get service
SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       COUNT(*) AS NumbServAn, ;
       COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
      SUM(Ai_Serv.s_value) AS NumValueAn, ;
      SUM(Ai_Serv.NumItems) AS NumbItemAn ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.Service_id ;
   AND EncSer_Cur.Anonymous = .T. ;
 GROUP BY 1, 2, 3 ;
UNION ALL ;
SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
       Padr("Z - No Services Recorded",80) AS Service, ;
       0 AS NumbServAn, ;
       COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
      0 AS NumValueAn, ;
       0 AS NumbItemAn ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Anonymous=.T. ;
   AND EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3 ;
 INTO CURSOR EncServAn

* adding the alias changes what doesn't match
INDEX ON Serv_Cat + Enc_Type + Service TAG ServEnc
SET ORDER TO ServEnc

***************************************************************
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript AS Service, ;
*!*         Service.Code AS ServCode, ;
*!*          COUNT(*) AS NumbServ, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumClients, ;
*!*         SUM(Ai_Serv.s_Value) AS NumValue, ;
*!*         SUM(Ai_Serv.NumItems) AS NumbItem ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*    GROUP BY 1, 2, 3 ;
*!*   UNION ALL ;
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*          "No Services Recorded" AS Service, ;
*!*         "ZZZZ" AS ServCode, ;
*!*          0 AS NumbServ, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumClients, ;
*!*         0 AS NumValue, ;
*!*         0 AS NumbItem ;
*!*     FROM EncSer_Cur ;
*!*    WHERE EncSer_Cur.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3 ;
*!*    INTO CURSOR EncServ

*!*   INDEX ON Serv_Cat + Enc_Type + ServCode TAG ServEnc
*!*   SET ORDER TO ServEnc
*!*   SET RELATION TO Serv_Cat + Enc_Type + ServCode INTO EncServAn

SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description AS Service, ;
       COUNT(*) AS NumbServ, ;
       COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumClients, ;
      SUM(Ai_Serv.s_Value) AS NumValue, ;
      SUM(Ai_Serv.NumItems) AS NumbItem ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list ;
 WHERE EncSer_Cur.Act_ID  = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.service_id ;
 GROUP BY 1, 2, 3 ;
UNION ALL ;
SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
       Padr("Z - No Services Recorded",80) AS Service, ;
       0 AS NumbServ, ;
       COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumClients, ;
      0 AS NumValue, ;
      0 AS NumbItem ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3 ;
 INTO CURSOR EncServ

INDEX ON Serv_Cat + Enc_Type + Service TAG ServEnc
SET ORDER TO ServEnc
SET RELATION TO Serv_Cat + Enc_Type + Service INTO EncServAn

*************************
* calculate counts for topics associated with services
*************************
* this select grabs topic count for anonymous for Serv_Cat+Enc_type+Service where serv_id OR att_id is link to topic
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*         Service.Code AS ServCode, ;
*!*          COUNT(*) AS NumbTopAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          Ai_topic, ;
*!*          Topics ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*      AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
*!*      AND Ai_Topic.code     = Topics.Code ;
*!*      AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
*!*            OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
*!*    GROUP BY 1, 2, 3 ;
*!*    INTO CURSOR ;
*!*       tTopAn1

*!*   * next 2 selects will create a zero count record for anonymous for all Serv_Cat+Enc_type+Service combos with no associated topics
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*         Service.Code AS ServCode, ;
*!*          0000000000 AS NumbTopAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3 ; 
*!*    INTO CURSOR tTopAn1a

SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       COUNT(*) AS NumbTopAn ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list, ;
       Ai_topic, ;
       Topics ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.service_id ;
   AND EncSer_Cur.Anonymous = .T. ;
   AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
   AND Ai_Topic.code     = Topics.Code ;
   AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
         OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
 GROUP BY 1, 2, 3 ;
 INTO CURSOR ;
    tTopAn1

* next 2 selects will create a zero count record for anonymous for all Serv_Cat+Enc_type+Service combos with no associated topics
SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       0000000000 AS NumbTopAn ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.Service_id ;
   AND EncSer_Cur.Anonymous = .T. ;
 GROUP BY 1, 2, 3 ; 
 INTO CURSOR tTopAn1a

SELECT * ;
FROM tTopAn1a ;
WHERE Serv_Cat+Enc_type+Service ;
   NOT IN (SELECT Serv_Cat+Enc_type+Service FROM tTopAn1) ;
INTO CURSOR tTopAn2

* next cursor sets topic count to zero for anonymous for Serv_Cat+Enc_type+Service combos for "no services recorded"
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*          PADR("No Services Recorded",55) AS Service, ;
*!*         "ZZZZ" AS ServCode, ;
*!*          0000000000 AS NumbTopAn ;
*!*     FROM EncSer_Cur ;
*!*    WHERE EncSer_Cur.Anonymous=.T. ;
*!*      AND EncSer_Cur.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3 ;
*!*    INTO CURSOR tTopAn3

SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
       PADR("No Services Recorded",80) AS Service, ;
       0000000000 AS NumbTopAn ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Anonymous=.T. ;
   AND EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3 ;
 INTO CURSOR tTopAn3

* next cursor is merge of the three topic count cursors above (for anonymous)
SELECT    * ;
FROM   tTopAn1 ;
UNION All ;
SELECT    * ;
FROM   tTopAn2 ;
UNION ALL ;
SELECT    * ;
FROM   tTopAn3 ;
INTO CURSOR ;
      ServTopAn         

* relate EncServAn into ServTopAn
*!*   INDEX ON Serv_Cat + Enc_Type + ServCode TAG ServEnc
*!*   SET ORDER TO ServEnc
*!*   SELECT EncServAn
*!*   SET RELATION TO Serv_Cat + Enc_Type + ServCode INTO ServTopAn ADDI

INDEX ON Serv_Cat + Enc_Type + Service TAG ServEnc
SET ORDER TO ServEnc
SELECT EncServAn
SET RELATION TO Serv_Cat + Enc_Type + Service INTO ServTopAn ADDI

* this select grabs topic count for Serv_Cat+Enc_type+Service where serv_id OR att_id is link to topic
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*         Service.Code AS ServCode, ;
*!*          COUNT(*) AS NumbTop ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          Ai_topic, ;
*!*          Topics ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
*!*      AND Ai_Topic.code     = Topics.Code ;
*!*      AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
*!*            OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
*!*    GROUP BY 1, 2, 3 ;
*!*    INTO CURSOR ;
*!*       tTop1

*!*   * next 2 selects set topic count to zero for Serv_Cat+Enc_type+Service combos with no associated topics
*!*    SELECT EncSer_Cur.Serv_Cat, ;
*!*          EncSer_Cur.Enc_type, ;
*!*          Service.Descript  AS Service, ;
*!*          Service.Code AS ServCode, ;
*!*           0000000000 AS NumbTop ;
*!*     FROM  EncSer_Cur, ;
*!*           Ai_Serv, ;
*!*           Service ;
*!*     WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*       AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*       AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*       AND Ai_Serv.Service = Service.code ;
*!*    GROUP BY 1, 2, 3 ; 
*!*    INTO CURSOR tTop1a

SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       COUNT(*) AS NumbTop ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list, ;
       Ai_topic, ;
       Topics ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.service_id ;
   AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
   AND Ai_Topic.code     = Topics.Code ;
   AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
         OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
 GROUP BY 1, 2, 3 ;
 INTO CURSOR ;
    tTop1

* next 2 selects set topic count to zero for Serv_Cat+Enc_type+Service combos with no associated topics
 SELECT EncSer_Cur.Serv_Cat, ;
       EncSer_Cur.Enc_type, ;
       Serv_list.Description  AS Service, ;
        0000000000 AS NumbTop ;
  FROM  EncSer_Cur, ;
        Ai_Serv, ;
        Serv_list ;
  WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
    AND Ai_Serv.Service_id = Serv_list.service_id ;
 GROUP BY 1, 2, 3 ; 
 INTO CURSOR tTop1a

SELECT * ;
FROM tTop1a ;
WHERE Serv_Cat+Enc_type+Service ;
   NOT IN (SELECT Serv_Cat+Enc_type+Service FROM tTop1) ;
INTO CURSOR tTop2

* next cursor sets topic count to zero for Serv_Cat+Enc_type+Service combos for "no services recorded"
*!*   SELECT EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*          PADR("No Services Recorded",55) AS Service, ;
*!*         "ZZZZ" AS ServCode, ;
*!*          0000000000 AS NumbTop ;
*!*     FROM EncSer_Cur ;
*!*    WHERE EncSer_Cur.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3 ;
*!*    INTO CURSOR tTop3

SELECT EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
       PADR("Z - No Services Recorded",80) AS Service, ;
       0000000000 AS NumbTop ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3 ;
 INTO CURSOR tTop3

* next cursor is merge of the three topic count cursors above (for all clients)
SELECT    * ;
FROM   tTop1 ;
UNION All ;
SELECT    * ;
FROM   tTop2 ;
UNION ALL ;
SELECT    * ;
FROM   tTop3 ;
INTO CURSOR ;
      ServTop         

* relate EncServ into ServTop
*!*   INDEX ON Serv_Cat + Enc_Type + ServCode TAG ServEnc
*!*   SET ORDER TO ServEnc
*!*   SELECT EncServ
*!*   SET RELATION TO Serv_Cat + Enc_Type + ServCode INTO ServTop ADDI

INDEX ON Serv_Cat + Enc_Type + Service TAG ServEnc
SET ORDER TO ServEnc
SELECT EncServ
SET RELATION TO Serv_Cat + Enc_Type + Service INTO ServTop ADDI

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for anonymous clients

SELECT Serv_Cat, ;   
      Enc_type, ;
       COUNT(act_id) AS AnonEnctrs, ;
      COUNT(DISTINCT tc_id) AS AnonCliSvd ;
  FROM EncSer_Cur ;
 WHERE Anonymous = .T. ;
 GROUP BY 1, 2 ;
 INTO CURSOR ServEncAn

INDEX ON Serv_Cat + Enc_type TAG ServEnc
SET ORDER TO ServEnc

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for all clients

SELECT Serv_Cat, ;   
      Enc_type, ;
       COUNT(act_id)         AS NumbEnctrs, ;
       COUNT(DISTINCT tc_id) AS EncCliSvd ;
  FROM EncSer_Cur ;
 GROUP BY 1, 2 ;
 ORDER BY 1, 2 ;
 INTO CURSOR ServEnc

***************************************************************
* calculate number of encounters and
* number of clients served within service category for all clients

SELECT Serv_Cat, ;   
       COUNT(act_id) AS Sum_SrvEnc, ;
       COUNT(DISTINCT tc_id) AS Sum_SrvCli ;
  FROM EncSer_Cur ;
 GROUP BY 1 ;
 INTO CURSOR ServCTot

INDEX ON Serv_Cat TAG Serv_Cat

***************************************************************
* calculate number of encounters and
* number of clients served within service category for anonymous clients

SELECT Serv_Cat, ;   
       COUNT(act_id) AS SumSrvEncA, ;
      COUNT(DISTINCT tc_id) AS SumSrvCliA ;
  FROM EncSer_Cur ;
 WHERE Anonymous = .T. ;
 GROUP BY 1 ;
 ORDER BY 1 ;
 INTO CURSOR ServCTotAn

INDEX ON Serv_Cat TAG Serv_Cat

***************************************************************
***************************************************************

*****   
cReportSelection = .aGroup(nGroup)

SELECT ServEnc.*, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Dt_from_a as Date_from, ;
   Dt_to_a as date_to, ;
   cOrderBy as sort_order ;   
From ServEnc ;
ORDER BY 1, 2 ;
Into Cursor ServEnc2 
*!*
*!* added the following 05/29/2009
*!* fro Crystal report processing
*!* jim power
*!*

SELECT s.*, e.service,e.numbserv, e.numclients, e.numvalue, e.numbitem, se.anonenctrs, se.anonclisvd, ;
       st.sum_srvenc, st.sum_srvcli,sn.sumsrvenca, sn.sumsrvclia,  sv.numbtop ,;
       en.numbservan, en.numclian, en.numvaluean, en.numbiteman , sp.numbtopan, ;
       "A" as rpt_type, gcagencyname as agencyname, oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate ;
       FROM servenc2 as s;
       LEFT OUTER JOIN encserv as e ON e.serv_cat+e.enc_type = s.Serv_Cat + s.Enc_Type ;
       LEFT OUTER JOIN encservan as en ON en.serv_cat+en.enc_type = s.Serv_Cat + s.Enc_Type ;     
       LEFT OUTER JOIN servCTot as st ON st.serv_cat = s.serv_cat ;
       LEFT OUTER JOIN servencan as se ON se.serv_cat+se.enc_type =  s.Serv_Cat + s.Enc_Type ;
       LEFT OUTER JOIN servCTotan as sn ON sn.serv_cat = s.serv_cat ;
       LEFT OUTER JOIN servtopan as sp ON sp.Serv_Cat + sp.Enc_Type + sp.Service = e.Serv_Cat + e.Enc_Type + e.Service ;
       LEFT OUTER JOIN servtop as sv ON sv.Serv_Cat + sv.Enc_Type + sv.Service = e.Serv_Cat + e.Enc_Type + e.Service ;
       into cursor temp

*******************************************
*!*   SET RELATION TO Serv_Cat + Enc_Type INTO EncServ, ;
*!*                   Serv_Cat + Enc_Type INTO ServEncAn, ;
*!*                   Serv_Cat INTO ServCTot, ;
*!*                   Serv_Cat INTO ServCTotAn          
*!*                   
*!*   SET SKIP TO EncServ

*!*oApp.Msg2User('OFF')
Go top

IF EOF('servenc2')
   oApp.Msg2User('NOTFOUNDG')
   RETURN .f.
ENDIF   
*!*
*!* added the following 05/28/2009
*!* for crystal reports...
*!* jim power

SELECT * FROM temp GROUP BY  serv_cat, enc_type,service  ;
INTO CURSOR tmp

SELECT tmp
COPY to crRptpath+"summary_of_services_by_encounter_type.dbf"
               
DECLARE INTEGER ShellExecute IN shell32.dll ; 
        INTEGER hndWin, ; 
        STRING caction, ; 
        STRING cFilename, ; 
        STRING cParms, ;  
        STRING cDir, ; 
        INTEGER nShowWin
  
LcFileName = "ic:\ursver6\project\libs\display_reports.exe" 
LcAction = "open" 
Lcparms = "encounters_by_service_type.rpt"
Lcdir = "i:\ursver6\airs_crreports\"
ShellExecute(0,LcAction,Lcfilename,lcparms,lcdir,1)


*!*   gcRptName = 'rpt_encser'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*       Report Form rpt_encser To Printer Prompt Noconsole NODIALOG 
*!*   CASE lPrev = .t.     &&Preview
*!*       oApp.rpt_print(5, .t., 1, 'rpt_encser', 1, 2)
*!*   EndCase


Return

********************
Procedure Rpt_EncSr1
********************
* select all encounter data within date range 

=OpenFile('Ai_enc')
*=OpenFile('Enc_type')

* jss, 12/6/06, use enc_list instead of enc_type
=OpenFile('Enc_list')
=OpenFile('Serv_cat')

*!*   SELECT DISTINCT Ai_Enc.Tc_ID, ;
*!*          Ai_Enc.Act_ID, ;
*!*         Ai_Enc.Enc_type   AS Enc_Code, ;
*!*         Ai_Enc.Serv_Cat   AS Serv_CCode, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          cli_cur.Anonymous , ;
*!*          Ai_Enc.Act_dt     AS Act_dt ;
*!*     FROM cli_cur, ;
*!*          Ai_Enc, ;
*!*          Serv_Cat, ;
*!*          Enc_Type ;
*!*    WHERE Ai_Enc.Tc_ID    = cli_cur.Tc_ID ;
*!*      AND Ai_Enc.Serv_Cat = lcServA ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Act_dt  >= m.Date_From ;
*!*      AND Ai_Enc.Act_dt  <= m.Date_To ;
*!*    INTO CURSOR Enc_Cur

* VT 08/12/2008 Dev Tick 4623  add Hold1 

SELECT DISTINCT Ai_Enc.Tc_ID, ;
       Ai_Enc.Act_ID, ;
      Ai_Enc.Enc_type   AS Enc_Code, ;
      Ai_Enc.Serv_Cat   AS Serv_CCode, ;
      Serv_Cat.Descript AS Serv_Cat, ;
      Enc_list.Description AS Enc_type, ;
       cli_cur.Anonymous , ;
       Ai_Enc.Act_dt     AS Act_dt ;
  FROM cli_cur, ;
       Ai_Enc, ;
       Serv_Cat, ;
       Enc_list, ;
       hold1 ;
 WHERE Ai_Enc.Tc_ID    = cli_cur.Tc_ID ;
   And ai_enc.tc_id = hold1.tc_id ;
   AND Ai_Enc.Serv_Cat = lcServA ;
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.enc_id ;
   AND Ai_Enc.Act_dt  >= m.Date_From ;
   AND Ai_Enc.Act_dt  <= m.Date_To ;
 INTO CURSOR Enc_Cur

***************************************************************
* calculate number of encounters and clients for serv_cat+enc_type for ANONYMOUS clients

SELECT Enc_Cur.Serv_Cat, ;
      Enc_Cur.Enc_type, ;
       COUNT(act_id) AS EncCnt, ;
       COUNT(DISTINCT Enc_Cur.Tc_ID) AS CliCnt ;
  FROM Enc_Cur ;
 WHERE Enc_Cur.Anonymous = .T. ;
 GROUP BY 1, 2 ;
 INTO CURSOR EncAn

INDEX ON Serv_Cat + Enc_Type TAG EncAn
SET ORDER TO EncAn

***************************************************************
* calculate number of distinct clients within a serv_cat for ANONYMOUS clients

SELECT Enc_Cur.Serv_Cat, ;
       COUNT(DISTINCT Enc_Cur.Tc_ID) AS CliCnt ;
  FROM Enc_Cur ;
 WHERE Enc_Cur.Anonymous = .T. ;
 GROUP BY 1 ;
 INTO CURSOR ServCatAn

INDEX ON Serv_Cat TAG ServCatAn
SET ORDER TO ServCatAn

***************************************************************
* calculate number of encounters and clients within serv_cat+enc_type
* for all clients

SELECT Enc_Cur.Serv_Cat, ;
      Enc_Cur.Enc_type, ;
       COUNT(act_id) AS EncCnt, ;
       COUNT(DISTINCT Enc_Cur.Tc_ID) AS CliCnt ;
  FROM Enc_Cur ;
 GROUP BY 1, 2 ;
 INTO CURSOR Enc

INDEX ON Serv_Cat + Enc_Type TAG Enc
SET ORDER TO Enc

***************************************************************
* calculate number of distinct clients within a serv_cat (encounters are simply summed on the report to serv_cat level)
* for all clients

SELECT Enc_Cur.Serv_Cat, ;
       COUNT(DISTINCT Enc_Cur.Tc_ID) AS CliCnt ;
  FROM Enc_Cur ;
 GROUP BY 1 ;
 INTO CURSOR ServCat

INDEX ON Serv_Cat TAG ServCat
SET ORDER TO ServCat

***************************************************************
* now, use the "enc" cursor as main report driver and relate it to the other cursors
cReportSelection = .aGroup(nGroup)

SELECT Enc.*, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Dt_from_a as Date_from, ;
   Dt_to_a as date_to, ;
   cOrderBy as sort_order ; 
From Enc ;  
ORDER BY 1, 2 ;
Into Cursor Enc2 

*!*   SET RELATION TO Serv_Cat + Enc_Type INTO EncAn, ;
*!*                   Serv_Cat INTO ServCat, ;
*!*                   Serv_Cat INTO ServCatAn          
GO TOP                

*!*oApp.Msg2User('OFF')

* jss, 4/28/2000, add 'Info Not Found' message
IF EOF('enc2')
   oApp.Msg2User('NOTFOUNDG')
   RETURN .f.
ENDIF   
*!*
*!* added the following 05/29/2009
*!* from crystal report processing
*!* jim power
*!*

SELECT e.*, en.enccnt, en.clicnt, sc.clicnt, st.clicnt, ;
       gcagencyname as agencyname,oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate ;
   FROM enc2 as e ;
   LEFT OUTER JOIN encan as en ON en.serv_cat+en.enc_type  = e.serv_cat+e.enc_type ;
   LEFT OUTER JOIN servcat as sc ON sc.serv_cat = e.serv_cat ;
   LEFT OUTER JOIN servcatan as st ON st.serv_cat = e.serv_cat ;
   INTO CURSOR temp
 
    COPY to crRptpath+"summary_of_services_by_encounter_type_condensed.dbf"
 
   DECLARE INTEGER ShellExecute IN shell32.dll ; 
           INTEGER hndWin, ; 
           STRING caction, ; 
           STRING cFilename, ; 
           STRING cParms, ;  
           STRING cDir, ; 
           INTEGER nShowWin

LcFileName = "i:\ursver6\project\libs\display_reports.exe" 
LcAction = "open" 
Lcparms = "encounters_by_service_type_condensed.rpt"
Lcdir = "i:\ursver6\airs_crreports\"
ShellExecute(0,LcAction,Lcfilename,lcparms,lcdir,1)

*!*   gcRptName = 'rpt_encsr1'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*       Report Form rpt_encsr1 To Printer Prompt Noconsole NODIALOG 
*!*   CASE lPrev = .t.     &&Preview
*!*       oApp.rpt_print(5, .t., 1, 'rpt_encsr1', 1, 2)
*!*   EndCase

Return






