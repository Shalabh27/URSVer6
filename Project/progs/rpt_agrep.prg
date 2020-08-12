Parameters lPrev,;     && Preview     
           aSelvar1,;  && select parameters from selection list
           nOrder,;    && order by number
           nGroup,;    && report selection number   
           lcTitle1,;  && report selection description   
           Date_from,; && from date
           Date_to,;   && to date   
           Crit,;      && name of param
           lnStat,;    && selection(Output)  page 2
           cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)

* set Data Engine Compatibility to handle Foxpro version 7.0 or earlier (lets old SQL work)
mDataEngine=Sys(3099,70)
lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)

***VT 07/18/2007
cCSite = ""
cContract = ""
LCProg = ""
cAgency_id = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CCONTRACT"
      cContract = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CAGENCY_ID"
      cAgency_id = aSelvar2(i, 2)
   EndIf   
EndFor

Private gchelp
gchelp = "Generating Monthly Aggregate Reports"

**VT 01/02/2008
***Crit = ""
**End

cReportSelection = ""
nMon = 0
nDat  = 0

Set Step On 

* jss, 5/7/03, add code to handle CT here
If gcState='NY'
	cTitle = "AIDS Institute Aggregate Reports"
EndIf 
If gcState='CT'
	cTitle = "Connecticut Aggregate Reports"
EndIf 

If Empty(m.Date_to)
   oApp.msg2user('INFORM', 'Please Enter "To" Date')
   Return 
EndIf 

cDate = DATE()
cTime = TIME()

* if we have already created the "Hold1" cursor created by GetCliLst(), don't run it again
  
***VT 07/18/2007
**IF (Used("Hold1") and Reccount("Hold1")>0) or GetCliLst()=.t.
IF GetCliLst()=.t.

   Do Case
   Case lnStat=1
  * Age by Sex by Ethnicity/Race - Active Clients 
      Do AgeSxx_Rpt with .t.

   Case lnStat=2
  * Age by Sex by Ethnicity/Race - New Clients 
      Do AgeSxx_Rpt with .f.
   
   Case lnStat=3
  * Encounters by Contr., Service Type - Total and Anon
      Do Rpt_CnEnc
      
   Case lnStat=4
  * Encounters by Service Type- Total + Anonymous
      Do Rpt_AiEnc
   
   Case lnStat=5
  * List Clients in Main Aggregate - DO NOT SEND 

      Do MainAggDet
      
   Case lnStat=6
  * Main Aggregate Report - Active Clients  

      If Used("aiaggrpt2")
         Use In aiaggrpt2
      Endif   

      Do MainAggRpt with .t.

      SELECT aiaggrpt2

      gcRptName = 'rpt_aggrpt'
      Do Case
      CASE lPrev = .f.
         Report Form rpt_aggrpt To Printer Prompt Noconsole NODIALOG 
      CASE lPrev = .t.     &&Preview
         oApp.rpt_print(5, .t., 1, 'rpt_aggrpt', 1, 2)
      EndCase

   Case lnStat=7
  * Main Aggregate Report - New Clients 

      If Used("aiaggrpt2")
         Use In aiaggrpt2
      Endif   

      Do MainAggRpt with .f.
   
      SELECT aiaggrpt2

      gcRptName = 'rpt_aggrpt'
      Do Case
      CASE lPrev = .f.
         Report Form rpt_aggrpt To Printer Prompt Noconsole NODIALOG 
      CASE lPrev = .t.     &&Preview
         oApp.rpt_print(5, .t., 1, 'rpt_aggrpt', 1, 2)
      EndCase

   Case lnStat=8
  * Revenue Detail Report 
      Do Rpt_RevDet
   
   Case lnStat=9
  * Revenue Summary Report 
      Do Rpt_RevSumm
   
   Case lnStat=10
  * Summary of Referrals 
      Do Rpt_AiRef
      
   EndCase

ELSE
   IF USED('hold')
		IF EOF('hold')
	      oApp.msg2user('NOTFOUNDG')
	   ENDIF   
   ENDIF   
ENDIF

* reset Data Engine compatibility back to Visual 9.0
mDataEngine=Sys(3099,90)

*!*   If Used("allintak")
*!*   	use in allintak
*!*   Endif	
*!*   If Used("allprog")
*!*   	use in allprog
*!*   Endif	
*!*   If Used("allenrol")
*!*   	use in allenrol
*!*   Endif	
*!*   If Used("allactiv")
*!*   	use in allactiv
*!*   Endif
*!*   	
*!*   If Used("baclose")
*!*   	use in baclose
*!*   Endif	
*!*   If Used("begactiv")
*!*   	use in begactiv
*!*   Endif	
*!*   If Used("begactto")	
*!*   	use in begactto
*!*   Endif	
*!*   If Used("begenrol")	
*!*   	use in begenrol
*!*   Endif	
*!*   If Used("begintto")
*!*   	use in begintto
*!*   Endif	
*!*   If Used("begintak")
*!*   	use in begintak
*!*   Endif	
*!*   If Used("begclose")
*!*   	use in begclose
*!*   Endif	
*!*   If Used("begenrto")
*!*   	use in begenrto
*!*   Endif	
*!*   If Used("baclosto")
*!*   	use in baclosto
*!*   Endif

*!*   If Used("cnclose")
*!*   	use in cnclose
*!*   Endif	
*!*   If Used("cnclosto")
*!*   	use in cnclosto
*!*   Endif	
*!*   If Used("chkactiv")
*!*   	use in chkactiv
*!*   Endif	
*!*   If Used("clospeto")
*!*   	use in clospeto
*!*   Endif
*!*   If Used("closper")	
*!*   	use in closper
*!*   Endif
*!*   If Used("clbegint")
*!*   	use in clbegint
*!*   Endif
*!*   If Used("closento")
*!*   	use in closento
*!*   Endif
*!*   If Used("closenr1")
*!*   	use in closenr1
*!*   Endif
*!*   If Used("closenr2")
*!*   	use in closenr2
*!*   Endif
*!*   If Used("closenro")
*!*   	use in closenro
*!*   Endif
*!*   If Used("closint")
*!*   	use in closint
*!*   Endif
*!*   If Used("closinto")
*!*   	use in closinto
*!*   Endif

*!*   If Used("endactto")
*!*   	use in endactto
*!*   Endif
*!*   If Used("endenrto")
*!*   	use in endenrto
*!*   Endif
*!*   If Used("endclose")
*!*   	use in endclose
*!*   Endif
*!*   If Used("endactiv")
*!*   	use in endactiv
*!*   Endif
*!*   If Used("endenrol")
*!*   	use in endenrol
*!*   Endif
*!*   If Used("endintto")
*!*   	use in endintto
*!*   Endif
*!*   If Used("endintak")
*!*   	use in endintak
*!*   Endif

*!*   If used('hold3hd') 
*!*   	Use in hold3hd
*!*   EndIf

*!*   If Used("hold3h")
*!*   	Use in hold3h
*!*   Endif
*!*   If Used("newactiv")
*!*   	use in newactiv
*!*   Endif
*!*   If Used("newactto")
*!*   	use in newactto
*!*   Endif
*!*   If Used("newenrto")
*!*   	use in newenrto
*!*   Endif
*!*   If Used("newenrol")
*!*   	use in newenrol
*!*   Endif
*!*   If Used("newprog")
*!*   	use in newprog
*!*   Endif
*!*   If Used("newintak")
*!*   	use in newintak
*!*   Endif

*!*   If Used("temp2hdf")
*!*   	Use in temp2hdf
*!*   Endif
*!*   If Used("temp1hdf")
*!*   	Use in temp1hdf
*!*   Endif
*!*   If Used("temp2hdm")
*!*   	Use in temp2hdm
*!*   Endif
*!*   If Used("temp1hdm")
*!*   	Use in temp1hdm
*!*   Endif
*!*   If Used("tclosper")
*!*   	use in tclosper
*!*   Endif
*!*   If Used("treopened")
*!*   	use in treopened
*!*   Endif
*!*   If Used("tbegintak")
*!*   	use in tbegintak
*!*   Endif
*!*   If Used("tnewenrol")
*!*   	use in tnewenrol
*!*   Endif
*!*   If Used("tendintak")
*!*   	use in tendintak
*!*   Endif
*!*   If Used("tcurs3")
*!*   	use in tcurs3
*!*   Endif
*!*   If Used("tcurs1")
*!*   	use in tcurs1
*!*   Endif
*!*   If Used("tcurs2")
*!*   	use in tcurs2
*!*   Endif
*!*   If Used("tnewint")
*!*   	use in tnewint
*!*   Endif
*!*   If Used("tbegactiv")
*!*   	use in tbegactiv
*!*   Endif
*!*   If Used("tendactiv")
*!*   	use in tendactiv
*!*   Endif
*!*   If Used("tnewenr2")
*!*   	use in tnewenr2
*!*   Endif
*!*   If Used("tadjust")
*!*   	use in tadjust
*!*   Endif
*!*   If Used("tadjust1")
*!*   	use in tadjust1
*!*   Endif


*!*   If Used("raagehold0")
*!*   	use in raagehold0
*!*   Endif
*!*   If Used("reclose")
*!*   	use in reclose
*!*   Endif
*!*   If Used("reclosto")
*!*   	use in reclosto
*!*   Endif
*!*   If Used("reoptota")
*!*   	use in reoptota
*!*   Endif
*!*   If Used("reopento")
*!*   	use in reopento
*!*   Endif
*!*   If Used("reopen")
*!*   	use in reopen
*!*   Endif
*!*   If Used("reopinto")
*!*   	use in reopinto
*!*   Endif
*!*   If Used("reopinta")
*!*   	use in reopinta
*!*   Endif
*!*   If Used("reopened")
*!*   	use in reopened
*!*   Endif


*!*   If Used("tvoid1")
*!*   	use in tvoid1
*!*   Endif
*!*   If Used("tvoided")
*!*   	use in tvoided
*!*   Endif

Return 
**********************************************************************
PROCEDURE GetCliLst
**********************************************************************
* this is the procedure that gathers the base list of clients to be
* reported on. It must allways be run
* the different aggregates for the clients are done and reported here
* The base list is held in a cursor "hold1"
**********************************************************************
* jss, 3/2000, create cursor aiaggdet for new client demographic detail report
CREATE CURSOR aiaggdet (column0 C(2), column1 C(50), column2 C(60), column3 N(10), column4 C(75), column5 C(20), column6 D, column7 C(5), column8 D)

INDEX ON column1 + column0 + column4 TAG col104

* DG 01/23/97
IF USED('Hold1')
	USE IN Hold1
ENDIF
	
oApp.msg2user("WAITRUN", "Preparing Report Data.   ", "")

SELECT ;
	t1.tc_id,;
	t1.client_id, ;
	t1.urn_no, ;
	t3.last_name,;
	t3.first_name,;
	.F. AS openincm,;
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
	PADR(ALLTRIM(ref_in.descript),55,' ')  AS referalsrc ,;
	t1.nrefnote, ;	
	t3.sex        ,;
	address.st        AS state      ,;
   address.fips_code  as fips_code, ;
   SPACE(25)         AS county     ,;
	.F. AS hiv_pos                  ,;
	SPACE(40) AS hivstatus ,;
	.F. AS ppd_pos ,;
	.F. AS anergic ,;
	.F. AS newprog ,;
	.F. AS newagency,;
	.F. AS ActivProg,;
	.F. AS ActivAgen,;
	{} AS end_dt,    ;
	t3.insurance, ;
	t3.is_refus, ;
	t3.hshld_incm, ;
	t3.hshld_size ;
FROM ;
	ai_clien  t1   ,;
	cli_cur   t3   ,;
	address        ,;
	ref_in         ;
WHERE ;
	t1.client_id           = t3.client_id              ;
	AND t1.client_id       = address.client_id         ;
	AND ref_in.code        = t1.ref_src2               ;
	AND t1.int_compl 												;
GROUP BY ;
   t1.tc_id ;
INTO CURSOR ;
	hold

* jss, 10/6/06, remove county code, use fips_code instead
*   address.county    AS code       ,;

* jss, 9/12/06, remove for VFP from "FROM" AND "WHERE", respectively, because of no more cli_hous
*   AND address.hshld_id   = cli_hous.hshld_id         ;
*   cli_hous       ,;


DIME cProbArray(1)
STORE ' ' to cProbArray(1)

*** NOTE: must add next bit of code back after making sure reports are working

* let's check the data before continuing
*IF !CHKDATA("HOLD","Aggregate Reports",cProbArray)
*   ParmToPass=''
*   DO getprob WITH ParmtoPass
*   IF 2=oApp.msg2user('OK2PRINT1',ParmToPass) 
*	   DO deactthermo IN thermo
*    	RETURN .f.
*   ELSE
*      oApp.msg2user("WAITRUN", "Continuing to Prepare Report Data.   ", "")
*   ENDIF
*ENDIF
  
*** Get the site and agency assignments, apply user selections if any
cCSite     = ALLTRIM(cCSite)
cAgency_ID = ALLTRIM(cAgency_ID)
lcProg     = ALLTRIM(lcProg)

* jss, 9/11/00, add time24 expression
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
SELECT Distinct hold.*,;
       ai_site.site, ;
       site.agency_id ;
FROM hold, ;
     ai_site, ;
     site ;
WHERE hold.tc_id= ai_site.tc_id ;
   AND site.site_id= ai_site.site ;
   AND site.site_id= cCSite;
   AND site.agency_id= cAgency_ID    ;
   AND ai_site.tc_id + DTOS(ai_site.effect_dt) + oApp.Time24(ai_site.time,ai_site.am_pm) ;
    								IN (SELECT ai_site2.tc_id + MAX(DTOS(ai_site2.effect_dt)+ oApp.Time24(ai_site2.time, ai_site2.am_pm)) ;
										 FROM ai_site ai_site2 ;
									    WHERE ai_site2.effect_dt <= m.Date_To ;
										 GROUP BY ai_site2.tc_id) ;
GROUP BY hold.tc_id ;
INTO CURSOR thold1 


* jss, 7/13/2000, add code here to limit client list (when specific program is specified)
*                 to those clients enrolled or intaken in program prior to period end
* jss, 4/6/01, as per AIDS Institute: do not grab INTAKES for programs requiring enrollment
IF EMPTY(lcprog)
	SELECT * FROM thold1 INTO CURSOR hold1 
Else
   cWherePrg1 = IIF(Empty(lcprog),"", " And Inlist(ai_prog.program, "  + lcprog + ")" )
   cWherePrg2 = IIF(Empty(lcprog),"", " Inlist(ai_clien.Int_Prog, "  + lcprog + ") And Inlist(program.Prog_id, "  + lcprog + ") ")
      
	SELECT ;
		Tc_ID ;
	FROM ;
		Ai_Prog ;
	WHERE ;
      Start_Dt  <= m.Date_To ;
		AND (Empty(End_Dt) OR End_Dt >= m.Date_from) ;
      &cWherePrg1 ;
	UNION ALL;
	SELECT ;
		Tc_ID ;
	FROM ;
		Ai_Clien, Program ;
	WHERE ;
		&cWherePrg2 ;
		AND NOT Program.Enr_Req AND Placed_Dt <= m.Date_To ;
		AND NOT EXISTS ;
   			(SELECT aip.* FROM Ai_Prog AIP ;
             WHERE aip.tc_id = ai_clien.tc_id AND ;
                   aip.program = ai_clien.Int_Prog AND ;
                   aip.Start_Dt <= m.Date_To) ;
	INTO CURSOR tEnrInt				
	
   **VT 01/08/2008
   cWherePrg1 = ''
   cWherePrg2 = ''
  
	SELECT * ;
	FROM ;
		thold1 ;
	WHERE ;
		tc_id IN (SELECT tc_id FROM tEnrInt) ;	
	INTO CURSOR hold1 
ENDIF						

USE IN hold

* make sure there are clients to report on
IF _TALLY = 0
* jss, 6/28/01, change the msg2user from "OFF" to "NOTFOUNDG": this corrects problem of return with no message
	oApp.msg2user("NOTFOUNDG")
	RETURN .f.
ENDIF

* DG 01/23/97

DO CASE
 CASE nGroup = 1 && All Clients
    lcExpr = ".T."   
 CASE nGroup = 2 && Ryan White Eligible
 	lcExpr = "Aar_Report"
 CASE nGroup = 3 && HIV Counseling/Prevention Eligible
 	lcExpr = "Ctp_Elig" 	
 CASE nGroup = 4 && Ryan White and HIV Counseling/Prevention Eligible
 	lcExpr = "(Aar_Report OR Ctp_Elig)" 	
Endcase


* in order for us to break the aggregate data down by program
* we need to get the program info (Aar_Report & Ctp_Elig)

************************************************************************
* Here get all clients from hold1 OPEN IN AGENCY AT START OF PERIOD

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
	effect_dt < m.Date_From         And;
	ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
					IN	(SELECT ;
							T1.tc_id + MAX(DTOS(t1.effect_dt)+oApp.Time24(t1.time, t1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						where effect_dt < m.Date_From    ;	
						GROUP BY ;
							T1.tc_id)  ;
INTO CURSOR ;
	OpBegPer	

* Here get all clients from hold1 CLOSED IN AGENCY DURING PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
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
	
* Here get all clients from hold1 OPEN IN AGENCY AT END OF PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
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

* Here get all clients from hold1 CLOSED IN AGENCY AT END OF PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
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

* active enrollments before period start (total is BEGINNING ENROLLMENT count) (must be OPEN IN AGENCY AT START, too)

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig, b.reason ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND b.Start_Dt < m.Date_from ;
	AND (b.end_dt >= m.Date_from OR EMPTY(b.end_dt)) ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
		b.tc_id + b.program + DTOS(b.start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MAX(DTOS(prog.start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.start_dt < m.date_from ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
	AND ;
		b.tc_id  IN (SELECT tc_id FROM OpBegPer) ;								
GROUP BY ;
	c.prog_id, a.tc_id ;		
INTO CURSOR ;
	BegEnrol

**VT 01/08/2008
cWherePrg =''

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	BegEnrol ;
INTO CURSOR ;
	BegEnrTo	;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 

IF RECC()>0
	SELECT ;
		'02'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Active Clients at Period Start as Enrollments',60)		 		AS column2, ;
		BegEnrTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		BegEnrol, BegEnrTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		BegEnrol.Prog_ID = Program.Prog_ID ;
	  AND ;
   	BegEnrol.Prog_ID = BegEnrTo.Prog_ID ;	
	  AND ;	
		BegEnrol.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* now, active enrollments at period end (total is ENDING ENROLLMENT count)
**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And  Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;


SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND b.Start_Dt <= m.Date_to ;
	AND (b.end_dt  > m.Date_to OR EMPTY(b.end_dt)) ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
		b.tc_id + b.program + DTOS(b.start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MAX(DTOS(prog.start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.start_dt <= m.date_to ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
	AND ;
		b.tc_id  IN (SELECT tc_id FROM OpEndPer) ;								
GROUP BY ;
	c.prog_id, a.tc_id ;		
INTO CURSOR ;
	EndEnrol

**VT 01/08/2008
cWherePrg=''

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	EndEnrol ;
INTO CURSOR ;
	EndEnrTo	;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'11'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Enrollments at Period End in this Program',60)				 	AS column2, ;
		EndEnrTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		EndEnrol, EndEnrTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		EndEnrol.Prog_ID = Program.Prog_ID ;
	  AND ;
   	EndEnrol.Prog_ID = EndEnrTo.Prog_ID ;	
	  AND ;	
		EndEnrol.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* who was CLOSED IN PROGRAM BEFORE PERIOD started? (need this to determine reopens and starts)
**VT 01/08/2007
cWhere = IIF(Empty(lcprog),"", " And  Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

**VT 09/01/2010 Dev Tick 4679
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(c.prog_id, "  + lcprog + ")" )

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND NOT EMPTY(b.End_dt) AND b.End_Dt < m.Date_from ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
		b.tc_id + b.program + DTOS(b.start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MAX(DTOS(prog.start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.start_dt < m.date_from ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
INTO CURSOR ;
	BegClose

* who was CLOSED IN PROGRAM AT PERIOD END? 

**VT 01/08/2007
*AND c.Prog_ID = lcProg  changed to &cWherePrg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND NOT EMPTY(b.End_dt) AND b.End_Dt <= m.Date_to ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
		b.tc_id + b.program + DTOS(b.start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MAX(DTOS(prog.start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.start_dt <= m.date_to ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
INTO CURSOR ;
	EndClose

* clients closed in program who have opened during period are REOPENs

**VT 01/08/2007
*AND c.Prog_ID = lcProg  changed to &cWherePrg 

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig , b.reason;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND b.Start_Dt BETWEEN m.Date_from AND m.Date_to ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
		b.tc_id + b.program + DTOS(b.Start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MIN(DTOS(prog.Start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.Start_dt BETWEEN m.date_from AND m.date_to ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
	AND b.tc_id + b.program IN (SELECT tc_id + prog_id FROM BegClose) ;
INTO CURSOR ;
	ReOpen
	
SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	Reopen ;
INTO CURSOR ;
	ReopenTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'06'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Reopened Cases this Period of Enrollments',60)				 	AS column2, ;
		ReopenTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		ReOpen, ReopenTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		ReOpen.Prog_ID = Program.Prog_ID ;
	  AND ;
   	ReOpen.Prog_ID = ReopenTo.Prog_ID ;	
	  AND ;	
		ReOpen.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF	

* active intakes prior to period (not enrolled prior to period) this is the BEGINNING INTAKE count		
* 4/6/01, jss, only count intakes for programs that do not require enrollment
*	AND NOT c.Enr_Req 

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig, SPACE(2) as Reason ;
FROM ;
	hold1 A, Ai_Clien B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Int_Prog = c.Prog_ID ;
	AND NOT c.Enr_Req ;
	AND a.Placed_Dt < m.Date_from ;
	AND &lcExpr ;		
	&cWherePrg ;
	AND b.tc_id + b.int_prog NOT IN (SELECT tc_id + prog_id FROM BegEnrol) ;
	AND b.tc_id + b.int_prog NOT IN (SELECT tc_id + prog_id FROM BegClose) ;
INTO CURSOR ;
	tBegIntak

**VT01/08/2008
cWherePrg =''
	
* make sure they are open in the agency
SELECT * ;
FROM ;
	tBegIntak ;
WHERE ;
	tc_id IN ;
		(SELECT tc_id FROM OpBegPer) ;
GROUP BY ;
	prog_id, tc_id ;		
INTO CURSOR ;
	BegIntak	

* what about those that are closed in agency at start? need this to determine REOPEN INTAKES
SELECT * ;
FROM ;
	tBegIntak ;
WHERE ;
	tc_id NOT IN ;
		(SELECT tc_id FROM OpBegPer) ;
INTO CURSOR ;
	ClBegInt	

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	BegIntak ;
INTO CURSOR ;
	BegIntTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'01'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Active Clients at Period Start as Intakes',60)	   		 	AS column2, ;
		BegIntTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		BegIntak, BegIntTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		BegIntak.Prog_ID = Program.Prog_ID ;
	  AND ;
   	BegIntak.Prog_ID = BegIntTo.Prog_ID ;	
	  AND ;	
		BegIntak.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* now, find out who has NEWly ENROLLed during period (total is new enrollments)
* too many subselects, so must do this in three select statements
**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig, b.reason ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND b.Start_Dt BETWEEN m.date_from AND m.Date_to ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
		b.tc_id + b.program + DTOS(b.Start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MIN(DTOS(prog.Start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.Start_dt BETWEEN m.date_from AND m.date_to ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
INTO CURSOR ;
	tNewEnrol

**VT 01/08/2008
cWherePrg = ''

* above, grab earliest start date within period
* next, exclude any that were already enrolled or previously enrolled at start of period

SELECT * ;
FROM tNewEnrol ;
WHERE;
		tNewEnrol.tc_id + tNewEnrol.prog_id NOT IN (SELECT tc_id + prog_id FROM BegEnrol) ;
AND 	tNewEnrol.tc_id + tNewEnrol.prog_id NOT IN (SELECT tc_id + prog_id FROM BegClose) ;
INTO CURSOR tNewEnr2

* now, exclude those that were previously intaken in program at start of period
SELECT * ;
FROM 	tNewEnr2 ;
WHERE ;
		tNewEnr2.tc_id + tNewEnr2.prog_id NOT IN (SELECT tc_id + prog_id FROM BegIntak) ;
GROUP BY ;
	prog_id, tc_id ;		
INTO CURSOR NewEnrol 

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	NewEnrol ;
INTO CURSOR ;
	NewEnrTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'04'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total New Clients this Period as Enrollments',60)					 	AS column2, ;
		NewEnrTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		NewEnrol, NewEnrTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		NewEnrol.Prog_ID = Program.Prog_ID ;
	  AND ;
   	NewEnrol.Prog_ID = NewEnrTo.Prog_ID ;	
	  AND ;	
		NewEnrol.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* get intakes CONVERTed to program enrollment; (tNewEnr2) contains newly enrolled clients
SELECT * ;
FROM ;
	BegIntak ;
WHERE ;
	begintak.tc_id + begintak.prog_id IN (SELECT tc_id + prog_id FROM tNewEnr2);
INTO CURSOR ;
	Convert

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	Convert ;
INTO CURSOR ;
	ConverTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'09'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Intakes Converted to Enrollments this Period',60)			 	AS column2, ;
		ConverTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		Convert, ConverTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		Convert.Prog_ID = Program.Prog_ID ;
	  AND ;
   	Convert.Prog_ID = ConverTo.Prog_ID ;	
	  AND ;	
		Convert.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* if client closed in agency, also necessarily closed in each program they were enrolled in at start
SELECT * ;
FROM ;
	BegEnrol ;
UNION	 ;
SELECT 	* ;
FROM ;
	NewEnrol ;
UNION ;
SELECT * ;
FROM ;
	Convert ;
UNION ;
SELECT 	* ;
FROM ;
	Reopen ;		
INTO CURSOR ;
	AllEnrol

INDEX ON prog_id+tc_id TAG progtcid

* now, find out which ENROLLed clients have CLOSED during period (total is closed of enrollments)
**VT 01/08/2007
cWherePrg =IIF(Empty(lcprog),"", " And  Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig, b.reason ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND &lcExpr ;
	&cWherePrg ;
	AND ;
			b.End_Dt BETWEEN m.Date_from AND m.Date_to ;
		AND;
			b.tc_id + b.program + DTOS(b.start_dt) IN ;
						(SELECT prog.tc_id + prog.program + MAX(DTOS(prog.start_dt)) ;
							FROM ai_prog prog;
							WHERE ;
								prog.start_dt <= m.date_to ;
							GROUP BY ;
								prog.tc_id, prog.program) ;
		AND ;
			b.tc_id + b.program IN (SELECT tc_id + prog_id FROM allenrol) ;								
INTO CURSOR ;
	ClosEnr1

**VT 01/08/2007
cWherePrg = ''

* now, get those that have closed in agency	
SELECT * ;
FROM ;
	AllEnrol ;
WHERE ;
	tc_id IN (SELECT tc_id FROM ClEndPer) ;
INTO CURSOR ;
	ClosEnr2

* combine the two for all closed enrollments	
SELECT * ;
FROM ;
	ClosEnr1 ;
UNION ;
SELECT * ;
FROM ;
	ClosEnr2 ;
INTO CURSOR ;
	ClosEnro	

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	ClosEnro ;
INTO CURSOR ;
	ClosEnTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'08'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Cases Closed of Program Enrollments',60)       				 	AS column2, ;
		ClosEnTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		ClosEnro, ClosEnTo, Ai_Clien, Cli_cur, Program ;
	WHERE ;
		ClosEnro.Prog_ID = Program.Prog_ID ;
	  AND ;
   	ClosEnro.Prog_ID = ClosEnTo.Prog_ID ;	
	  AND ;	
		ClosEnro.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = Cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* get new intakes
* 4/6/01, jss, only count intakes for programs that do not require enrollment
*	AND NOT c.Enr_Req 

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And  Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig, SPACE(2) as Reason ;
FROM ;
	hold1 A, Ai_Clien B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Int_Prog = c.Prog_ID ;
	AND NOT c.Enr_Req ;
	AND a.Placed_Dt BETWEEN m.Date_from AND m.Date_to ;
	AND &lcExpr ;		
	&cWherePrg ;
	AND b.tc_id + b.int_prog NOT IN (SELECT tc_id + prog_id FROM NewEnrol) ;
INTO CURSOR ;
	tNewInt

**VT 01/08/2007
cWherePrg = ''


* above, we exclude situation in which the client is intaken and enrolled in same period
* below, we make certain that the clients are in fact new (never existed in program before)	
* jss, 9/1/00, add additional filter: no clients previously intaken (open and closed in agency)
*                                     before period start (clbegint)
SELECT * ;
FROM tNewInt ;
WHERE;
		tNewInt.tc_id + tNewInt.prog_id NOT IN (SELECT tc_id + prog_id FROM BegEnrol) ;
AND 	tNewInt.tc_id + tNewInt.prog_id NOT IN (SELECT tc_id + prog_id FROM BegClose) ;
GROUP BY ;
	prog_id, tc_id ;		
INTO CURSOR tNewInt01

SELECT * ;
FROM tNewInt01 ;
WHERE;
 		tNewInt01.tc_id + tNewInt01.prog_id NOT IN (SELECT tc_id + prog_id FROM ClBegInt) ;
GROUP BY ;
	prog_id, tc_id ;		
INTO CURSOR NewIntak

SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	NewIntak ;
INTO CURSOR ;
	NewIntTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'03'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total New Clients this Period as Intakes',60)						 	AS column2, ;
		NewIntTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		NewIntak, NewIntTo, Ai_Clien, cli_cur, Program ;
	WHERE ;
		NewIntak.Prog_ID = Program.Prog_ID ;
	  AND ;
   	NewIntak.Prog_ID = NewIntTo.Prog_ID ;	
	  AND ;	
		NewIntak.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* create a cursor called newprog that has all new tc_id+prog_id for intakes AND enrollments
SELECT DISTINCT prog_id, tc_id ;
FROM		NewEnrol ;
UNION ;
SELECT DISTINCT prog_id, tc_id ;
FROM     NewIntak ;
INTO CURSOR ;
			NewProg
			
INDEX ON prog_id+tc_id TAG progtcid

* active intakes at end of period (not enrolled prior to period end) this is the ENDING INTAKE count		
* 4/6/01, jss, only count intakes for programs that do not require enrollment
*	AND NOT c.Enr_Req 

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And  Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig, SPACE(2) as Reason  ;
FROM ;
	hold1 A, Ai_Clien B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Int_Prog = c.Prog_ID ;
	AND NOT c.Enr_Req ;
	AND a.Placed_Dt <= m.Date_to ;
	AND &lcExpr ;		
	&cWherePrg ;
	AND b.tc_id + b.int_prog NOT IN (SELECT tc_id + prog_id FROM EndEnrol) ;
	AND b.tc_id + b.int_prog NOT IN (SELECT tc_id + prog_id FROM EndClose) ;
INTO CURSOR ;
	tEndIntak

**VT 01/08/2008
cWherePrg= ''
 
SELECT * ;
FROM ;
	tEndIntak ;
WHERE ;
	tc_id IN ;
		(SELECT tc_id FROM OpEndPer) ;
GROUP BY ;
	prog_id, tc_id ;		
INTO CURSOR ;
	EndIntak	
	
SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	EndIntak ;
INTO CURSOR ;
	EndIntTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'10'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Intakes at Period End in this Program',60)					 	AS column2, ;
		EndIntTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		EndIntak, EndIntTo, Ai_Clien, cli_cur, Program ;
	WHERE ;
		EndIntak.Prog_ID = Program.Prog_ID ;
	  AND ;
   	EndIntak.Prog_ID = EndIntTo.Prog_ID ;	
	  AND ;	
		EndIntak.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* grab REOPEN INTAKES (the ending intakes that were closed at period start)
SELECT * ;
FROM ;
		EndIntak ;
WHERE ;
		tc_id+prog_id IN (SELECT tc_id+prog_id FROM ClBegInt) ;
INTO CURSOR ;
		ReopInta
		
SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	ReopInta ;
INTO CURSOR ;
	ReopInTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'05'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Reopened Cases this Period of Intakes',60)					 	AS column2, ;
		ReopInTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		ReopInta, ReopInTo, Ai_Clien, cli_cur, Program ;
	WHERE ;
		ReopInta.Prog_ID = Program.Prog_ID ;
	  AND ;
   	ReopInta.Prog_ID = ReopInTo.Prog_ID ;	
	  AND ;	
		ReopInta.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* jss, 11/98, add new cursor to account for CLOSED INTAKES
* because of too many subselects, must do this in 2 steps:
* first, get all intakes 
* then, make sure none of them were converted to enrollments during period,
*       and grab the ones that closed in agency
* jss, 8/31/2000, add select for reopen intakes to creation of allintak below
SELECT * ;
FROM ;
	BegIntak ;
UNION ;
SELECT * ;
FROM ;
	NewIntak ;
UNION ;	
SELECT * ;
FROM ;
	ReopInta ;
INTO CURSOR ;
	AllIntak	

* 12/99, jss, create new cursor AllProg, which combines intakes/enrollments
SELECT * ;
FROM ;
	AllIntak ;
UNION ;
SELECT * ;
FROM ;
	AllEnrol ;
INTO CURSOR ;
	AllProg		

INDEX ON prog_id+tc_id TAG progtcid

SELECT * ;
FROM ;
		AllIntak ;
WHERE ;
		tc_id + prog_id NOT IN (SELECT tc_id + prog_id FROM Convert)  ;
  AND tc_id               IN (SELECT tc_id           FROM ClEndPer) ;
INTO CURSOR ;
	ClosInt
	
SELECT ;
	Prog_id, ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	ClosInt ;
INTO CURSOR ;
	ClosInTo ;
GROUP BY ;
	Prog_id			

INDEX ON Prog_ID TAG Prog_ID

* jss, 3/2000, for detail report, add following cursor 
IF RECC()>0
	SELECT ;
		'07'																							AS column0, ;
		PADR('Program: ' + Program.Descript,50)											AS column1, ;
		PADR('Total Cases Closed of Program Intakes',60)         				 	AS column2, ;
		ClosInTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		ClosInt, ClosInTo, Ai_Clien, cli_cur, Program ;
	WHERE ;
		ClosInt.Prog_ID = Program.Prog_ID ;
	  AND ;
   	ClosInt.Prog_ID = ClosInTo.Prog_ID ;	
	  AND ;	
		ClosInt.tc_id = Ai_Clien.tc_id ;
	  AND ;
  		Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ;
   	column1, ;
	   column0, ;
   	column4  ;
	INTO CURSOR  ;
		tempcols

	SELECT aiaggdet
	APPE FROM (DBF("tempcols"))
	USE IN tempcols

ENDIF

* the next select pre-dates 8/98 changes, and is used for counts within programs
**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And  Inlist(c.prog_id, "  + lcprog + ")" )
*AND c.Prog_ID = lcProg ;

SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
	hold1 A, Ai_Prog B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Program = c.Prog_ID ;
	AND b.Start_Dt <= m.Date_To ;
	AND &lcExpr ;
	&cWherePrg ;
UNION ;
SELECT ;
	a.*, ;
	c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
	hold1 A, Ai_Clien B, Program C ;
WHERE ;
	a.Tc_ID = b.Tc_ID ;
	AND b.Int_Prog = c.Prog_ID ;
	AND a.Placed_Dt <= m.Date_To ;
	AND &lcExpr ;		
	&cWherePrg ;
INTO CURSOR ;
	hold2

* make sure there are clients to report on

IF _TALLY = 0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF

USE IN hold1
USE DBF("hold2") IN 0 AGAIN ALIAS hold1
USE IN hold2

* jss, 8/98, use placed_dt as Start_dt instead of (ai_activ.effect_dt where ai_activ.initial)
SELECT *, ;
	placed_dt AS start_dt;
FROM ;
	hold1 ;
INTO CURSOR ;
	hold2

USE IN hold1


* Here get all clients closed at the end of a period
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
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

* jss, 8/98, add new select here that will grab all tc_id's that have been reopened anytime during period

* first, get those tc_ids that exist prior to start of period (the active ones here are the beginning active count)
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
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

* jss, 3/2000, for detail report, add following cursor 
IF _tally=0
	SELECT ;
		'02'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total New Clients this Period',60)			 								AS column2, ;
		0000																	         			AS column3, ;
		PADR('None',75)																			AS column4, ;
		PADR('None',20)																			AS column5, ;
		{}																								AS column6, ;
		SPACE(5)																						AS column7, ;
		{}																								AS column8  ;
	FROM ;
		ai_clien ;
	GROUP BY column0 ;	
	INTO CURSOR  ;
		tempcols

ELSE
	SELECT ;
		'02'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total New Clients this Period',60)			 								AS column2, ;
		CliNewTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		CliNew, CliNewTo, Ai_Clien, cli_cur ;
	WHERE ;
		CliNew.tc_id = Ai_Clien.tc_id ;
	  AND ;
   	Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ; 
		ai_clien.id_no ;   			
	INTO CURSOR  ;
		tempcols

ENDIF

SELECT aiaggdet
APPE FROM (DBF("tempcols"))
USE IN tempcols

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
	tBegActiv
	
* jss, 4/25/2000, if client is not found in either begintak or begenrol, exclude from agency level
*                 beginning active total
* jss, 7/13/2000, if running for all programs/clients, use tbegactiv as begactiv, else filter with begintak,begenrol

IF EMPTY(lcprog)
	SELECT * FROM tBegActiv INTO CURSOR BegActiv 
ELSE
	SELECT * ;
	FROM ;
		tBegActiv ;
	WHERE ;
		tc_id IN (SELECT tc_id FROM BegIntak) OR ;
		tc_id IN (SELECT tc_id FROM BegEnrol) ;
	INTO CURSOR ;
		BegActiv		
ENDIF		
	
* total active beginners
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	BegActiv ;
INTO CURSOR ;
	BegActTo 

* jss, 3/2000, for detail report, add following cursor 
IF _tally=0
	SELECT ;
		'01'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Active Clients at Period Start',60)	 								AS column2, ;
		0000																	         			AS column3, ;
		PADR('None',75)																			AS column4, ;
		PADR('None',20)																			AS column5, ;
		{}																								AS column6, ;
		SPACE(5)																						AS column7, ;
		{}																								AS column8  ;
	FROM ;
		ai_clien ;
	GROUP BY column0 ;	
	INTO CURSOR  ;
		tempcols

ELSE
	SELECT ;
		'01'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Active Clients at Period Start',60) 								AS column2, ;
		BegActTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		BegActiv, BegActTo, Ai_Clien, cli_cur ;
	WHERE ;
		BegActiv.tc_id = Ai_Clien.tc_id ;
	  AND ;
   	Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ; 
		ai_clien.id_no ;   			
	INTO CURSOR  ;
		tempcols

ENDIF

SELECT aiaggdet
APPE FROM (DBF("tempcols"))
USE IN tempcols

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
	tEndActiv

* jss, 7/13/2000, if all, no further filter; if by program or report group, filter by begintak,begenrol	
IF Empty(lcprog)
	SELECT * FROM tEndActiv INTO CURSOR EndActiv 
ELSE
	SELECT * ;
	FROM ;
		tEndActiv ;
	WHERE ;
		tc_id IN (SELECT tc_id FROM EndIntak) OR ;
		tc_id IN (SELECT tc_id FROM EndEnrol) ;	
	INTO CURSOR ;
		EndActiv 
ENDIF

SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	EndActiv ;
INTO CURSOR ;
	EndActTo 

* jss, 3/2000, for detail report, add following cursor 
IF _tally=0
	SELECT ;
		'06'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Active Clients at Period End',60)			 						AS column2, ;
		0000																	         			AS column3, ;
		PADR('None',75)																			AS column4, ;
		PADR('None',20)																			AS column5, ;
		{}																								AS column6, ;
		SPACE(5)																						AS column7, ;
		{}																								AS column8  ;
	FROM ;
		ai_clien ;
	GROUP BY column0 ;	
	INTO CURSOR  ;
		tempcols

ELSE
	SELECT ;
		'06'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Active Clients at Period End',60)	 								AS column2, ;
		EndActTo.tot   													         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		EndActiv, EndActTo, Ai_Clien, cli_cur ;
	WHERE ;
		EndActiv.tc_id = Ai_Clien.tc_id ;
	  AND ;
   	Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ; 
		ai_clien.id_no ;   			
	INTO CURSOR  ;
		tempcols

ENDIF

SELECT aiaggdet
APPE FROM (DBF("tempcols"))
USE IN tempcols

* those that were inactive, and became active during period are REOPENS
* jss, 10/11/00: add UNION code to catch this situation: client closed at period start, reopened, then
*               closed during period...
 
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
	tcurs1.tc_id=hold2.tc_id ;
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
	tReopened
	
* 7/13/2000, jss, if program selected, include program reopens in agency reopen count
IF Empty(lcprog)
	SELECT * FROM tReopened INTO CURSOR Reopened 
ELSE
	SELECT DISTINCT ;
		tc_id, anonymous ;
	FROM ;
		Reopen ;
	WHERE ;
		tc_id IN (SELECT tc_id FROM EndActiv) ;	
	INTO CURSOR ;
		Reopened 
ENDIF	

SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	reopened ;
INTO CURSOR ;
	ReopTota 

* jss, 3/2000, for detail report, add following cursor 
IF _tally=0
	SELECT ;
		'04'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Reopened Cases this Period',60)		 								AS column2, ;
		0000																	         			AS column3, ;
		PADR('None',75)																			AS column4, ;
		PADR('None',20)																			AS column5, ;
		{}																								AS column6, ;
		SPACE(5)																						AS column7, ;
		{}																								AS column8  ;
	FROM ;
		ai_clien ;
	GROUP BY column0 ;	
	INTO CURSOR  ;
		tempcols

ELSE
	SELECT ;
		'04'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Reopened Cases this Period',60)		 								AS column2, ;
		ReopTota.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		Reopened, ReopTota, Ai_Clien, cli_cur ;
	WHERE ;
		Reopened.tc_id = Ai_Clien.tc_id ;
	  AND ;
   	Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ; 
		ai_clien.id_no ;   			
	INTO CURSOR  ;
		tempcols

ENDIF

SELECT aiaggdet
APPE FROM (DBF("tempcols"))
USE IN tempcols

* 12/99, jss, add new cursor, allactiv, that represents anybody activ at some point in period
* 4/00, jss, add another cursor into union: EndActiv, which will account for clients already in agency, newly enrolled in program
* 8/31/00, jss, add in reopened clients, as they could be closed before period end, effectively excluding them from group of active sometime in period
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
	tClosPer
	
* jss, 7/13/2000, if all, no further filter; if by program, closed are those lost from begactiv to endactiv
IF Empty(lcprog)
	SELECT * FROM  tClosPer INTO CURSOR ClosPer 
ELSE
	SELECT * ;
	FROM ;
		BegActiv ;
	WHERE ;
		tc_id NOT IN (SELECT tc_id FROM EndActiv) ;
	INTO CURSOR ;
		ClosPer
ENDIF

* total closed in period
SELECT ;
	COUNT(*)         			AS tot, ;
	SUM(IIF(anonymous,1,0)) AS totanon ;
FROM ;
	ClosPer ;
INTO CURSOR ;
	ClosPeTo

* jss, 3/2000, for detail report, add following cursor 
IF _tally=0
	SELECT ;
		'05'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Cases Closed this Period',60)			 								AS column2, ;
		0000																	         			AS column3, ;
		PADR('None',75)																			AS column4, ;
		PADR('None',20)																			AS column5, ;
		{}																								AS column6, ;
		SPACE(5)																						AS column7, ;
		{}																								AS column8  ;
	FROM ;
		ai_clien ;
	GROUP BY column0 ;	
	INTO CURSOR  ;
		tempcols

ELSE
	SELECT ;
		'05'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Cases Closed this Period',60) 		 								AS column2, ;
		ClosPeTo.tot	  													         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		ClosPer, ClosPeTo, Ai_Clien, cli_cur ;
	WHERE ;
		ClosPer.tc_id = Ai_Clien.tc_id ;
	  AND ;
   	Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ; 
		ai_clien.id_no ;   			
	INTO CURSOR  ;
		tempcols

ENDIF		

SELECT aiaggdet
APPE FROM (DBF("tempcols"))
USE IN tempcols

* 4/25/2000, jss, now, grab anybody who is newly activ, but not in the other buckets because they 
*            have become enrolled in the program this period, but were already activ in the agency
*            at period start (thus, they are not new in agency)
* 7/13/2000, jss, add reopened check

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

* jss, 3/2000, for detail report, add following cursor 
IF _tally=0
	SELECT ;
		'03'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Newly Enrolled Active Clients this Period',60)					AS column2, ;
		0000																	         			AS column3, ;
		PADR('None',75)																			AS column4, ;
		PADR('None',20)																			AS column5, ;
		{}																								AS column6, ;
		SPACE(5)																						AS column7, ;
		{}																								AS column8  ;
	FROM ;
		ai_clien ;
	GROUP BY column0 ;	
	INTO CURSOR  ;
		tempcols

ELSE
	SELECT ;
		'03'																							AS column0, ;
		PADR('Agency Level Summary Information',50)										AS column1, ;
		PADR('Total Newly Enrolled Active Clients this Period',60)					AS column2, ;
		NewActTo.tot														         			AS column3, ;
		PADR(ALLTRIM(cli_cur.last_name) + ', ' + ALLTRIM(cli_cur.first_name),75)	AS column4, ;
		ai_clien.id_no																				AS column5, ;
		DTOC(cli_cur.dob)																			AS column6, ;
		ai_clien.int_prog																			AS column7, ;
		DTOC(ai_clien.placed_dt)																AS column8  ;
	FROM ;
		NewActiv, NewActTo, Ai_Clien, cli_cur ;
	WHERE ;
		NewActiv.tc_id = Ai_Clien.tc_id ;
	  AND ;
   	Ai_clien.Client_ID = cli_cur.Client_ID ;
	GROUP BY ; 
		ai_clien.id_no ;   			
	INTO CURSOR  ;
		tempcols

ENDIF

SELECT aiaggdet
APPE FROM (DBF("tempcols"))
USE IN tempcols

	
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

* total of beginning active closes
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

* total of beginning active closes
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

* total of beginning active closes
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
USE DBF("hold2") IN 0 AGAIN ALIAS hold1
SELECT hold1
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

*=OpenFile("county", "statecode")
=OpenFile("zipcode", "countyfips")
*- set relations for hivstatus and tbstatus, et al.
SELECT hold1
SET RELATION TO tc_id         INTO tbstatus           ,;
                tc_id         INTO hivstat            ,;
                prog_id+tc_id INTO newprog            ,;
                prog_id+tc_id INTO AllProg            ,;
                tc_id         INTO clinew             ,;
                tc_id         INTO AllActiv           ,;
                tc_id         INTO cliclosed          ,;
                fips_code     INTO zipcode ADDITIVE
*                state+code    INTO county    ADDITIVE         
                

REPL ALL ppd_pos    WITH test_res.ppd_pos        ,;
         hiv_pos    WITH hstat.hiv_pos           ,;
         hivstatus  WITH hstat.descript          ,;
         anergic    WITH (tbstatus.panergic=1)   ,;
         county     WITH Left(PROPER(zipcode.countyname),25) ,;
         End_dt     WITH cliclosed.effect_dt     ,;
         ActivProg  WITH FOUND('AllProg')        ,;
         ActivAgen  WITH FOUND('AllActiv')       ,;
         NewAgency  WITH FOUND('CliNew')         ,;
         newprog    WITH FOUND('NewProg')

*         county     WITH PROPER(county.descript) 

* jss, 1/15/02, add code to handle problem with county='999' (county table has '999' plus BLANK state, actual data has actual state code)
*REPL ALL county WITH Padr('Other',25) FOR code = '999'
REPL ALL county WITH Padr('Other',25) FOR fips_code = '99999'

*- cleanup
USE IN hstat
USE IN hivstat
USE IN test_res
USE IN tbstatus
USE IN cliclosed 
*USE IN county

**VT 04/08/2008 Dev Tick 4222
*Use IN Zipcode
 
=OpenFile("prog2sc", "prog_id")
=OpenFile("ai_prog", "tc_id")
SET RELATION TO program INTO prog2sc

SELECT hold1
SCAN
	SELECT ai_prog
	LOCATE FOR ai_prog.tc_id = hold1.tc_id AND;
	           prog2sc.serv_cat = "00001" AND ;
	           ai_prog.start_dt <= m.Date_To  AND;
	           (EMPTY(ai_prog.end_dt) OR (ai_prog.end_dt > m.Date_To)) 

	REPL hold1.OpenInCM WITH Found()
ENDSCAN

oApp.msg2user("OFF")

Use in ai_prog

* add for vfp version with all vars we need
**VT 08/12/2008 Dev Tick 4622 Add Upper
Select aiaggdet.*, ;
   Upper(aiaggdet.column4) as sort_name, ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
From aiaggdet ;
Into Cursor aiaggdet2 ;
order by 2,1, 10

*Order by aiaggdet.column1, aiaggdet.column0, aiaggdet.column4 
   
Select hold1

RETURN .t.

**********************************************************************
PROCEDURE MainAggDet
*PARAMETER nClick, nTimes
**********************************************************************
* this is the client detail of the Totals categories from the main AIDS Institute aggregate report
**********************************************************************
*DIMENSION aFiles_Open[1]
*DO Save_Env2 WITH aFiles_Open

SELECT aiaggdet2

gcRptName = 'rpt_aggdet'
Do Case
CASE lPrev = .f.
   Report Form rpt_aggdet To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_aggdet', 1, 2)
EndCase

*DO Rest_Env2 WITH aFiles_Open	
RETURN
**********************************************************************
PROCEDURE MainAggRpt

PARAMETER cActivNew
**********************************************************************
* this is the main AIDS Institute aggregate report
* the different aggregates for the clients are done and reported here
**********************************************************************

cDemoTitle='Main Aggregate Report - '
IF cActivNew
	cCumTitle='Active Clients Demographics'
	cWhereCli='Hold1.ActivProg'
	cWCDesc='Active'
ELSE
	cCumTitle='New Clients Demographics'
	cWhereCli='Hold1.NewProg'
	cWCDesc='New'
ENDIF

n1=Seconds()

* jss, 4/20/05, define m.label2 here
m.label2=SPACE(20)
* jss, 4/27/05, define m.label3 here
m.label3=SPACE(25)
* jss, 4/21/05, define counter m.rec_no
m.rec_no=0

* in order for us to get the unduplicated number of clients we should use 
* the DISTINCT clause and get rid of Prog_ID and ProgrDesc columns.

SELECT ;
	DIST tc_id, openincm, anonymous, ;
	hhead, dchild, hiv_pos, ppd_pos, ;
	anergic, newprog, newagency, end_dt, start_dt ;
FROM Hold1 ;
INTO CURSOR Hold10

* get inital counts
* these are the counts that appear in the summary section of the report
* 8/98, jss, add CloseAnon, reopencnt, reopenanon
* 9/98, and reopInAnon

SELECT ;
	SUM(IIF(OpenInCM,1,0))                                            AS NewCMcnt  ,;
	SUM(IIF(hiv_pos AND ppd_pos,1,0))                                 AS TOTHIVPPD ,;
	SUM(IIF(newprog and hiv_pos AND ppd_pos,1,0))                     AS NewHIVPPD ,;
	SUM(IIF(anergic,1,0))                                             AS ppdanergic,;
	SUM(IIF(newprog and UPPER(hhead)="Y",1,0))                        AS NewHHcnt  ,;
	SUM(IIF(newprog and UPPER(dchild)="Y",1,0))                       AS NewDccnt   ;
FROM ;
	hold10 ;
INTO CURSOR ;
	hold2

*- create cursor for reporting
* jss, 4/20/05, add new column label2 to aiaggrpt cursor
* jss, 4/27/05, add new column label3 to aiaggrpt cursor
* jss, 4/21/05, add new column rec_no to aiaggrpt cursor
CREATE CURSOR aiaggrpt (prog_id C(5), progrdesc C(30), group c(60), label c(80), label2 c(20), label3 c(25), count n(10,0), header l(1), notcount L(1), rec_no N(6), count2 N(10,0))

* these are the counts that appear in the summary section of the report
SELECT 	Prog_ID, ;
			00000 AS BegIntake , ;
			00000 AS BegEnroll , ;
			00000 AS BegCnt	   , ;
			00000 AS NewIntake , ;
			00000 AS NewEnroll , ;
			00000 AS NewCnt	   , ;
			00000 AS ReopenCnt , ;
			00000 AS ReopInCnt , ;
			00000 AS CloseEnrol, ;
			00000 AS CloseIntak, ;
			00000 AS CloseInPer, ;
			00000 AS ConvIntake, ;
			00000 AS EndIntake , ;
			00000 AS EndEnroll , ;
			00000 AS EndCnt    , ;
			00000 AS BegIntAnon, ;
			00000 AS BegEnrAnon, ;
			00000 AS BegCntAnon, ;
			00000 AS NewIntAnon, ;
			00000 AS NewEnrAnon, ;
			00000 AS NewCntAnon, ;
			00000 AS ReopenAnon, ;
			00000 AS ReopInAnon, ;
			00000 AS ClosEnrAn , ;
			00000 AS ClosIntAn , ;
			00000 AS CloseAnon , ;
			00000 AS ConvAnon  , ;
			00000 AS EndIntAnon, ;
			00000 AS EndEnrAnon, ;
			00000 AS EndCntAnon, ;
			SUM(IIF(OpenInCM,1,0))                              AS NewCMcnt  ,;
			SUM(IIF(hiv_pos AND ppd_pos,1,0))                   AS TOTHIVPPD ,;
			SUM(IIF(newprog and hiv_pos AND ppd_pos,1,0))       AS NewHIVPPD ,;
			SUM(IIF(anergic,1,0))                               AS ppdanergic,;
			SUM(IIF(newprog and UPPER(hhead)="Y",1,0))          AS NewHHcnt  ,;
			SUM(IIF(newprog and UPPER(dchild)="Y",1,0))         AS NewDccnt  ;
FROM ;
	hold1 ;
GROUP BY Prog_ID ;	
INTO CURSOR ;
   hold3 readwrite

*	holdprog

INDEX ON Prog_ID TAG Prog_ID

*=ReOpenCur("holdprog", "hold3")
*SET ORDER TO Prog_ID

* total the counting cursors
SELE hold3
SET RELA TO prog_id INTO BegEnrTo, ;
            prog_id INTO BegIntTo, ;
            prog_id INTO NewIntTo, ;
            prog_id INTO NewEnrTo, ;
            prog_id INTO ReopenTo, ;
            prog_id INTO ReopInTo, ;
            prog_id INTO closento, ;
            prog_id INTO ClosInTo, ;
            prog_id INTO EndEnrTo, ;
            prog_id INTO EndIntTo, ;
            prog_id INTO ConverTo  ;
            
REPLACE ALL ;
			BegIntake 	WITH begintto.tot, ;
			BegEnroll 	WITH begenrto.tot, ;
			BegCnt      WITH (begintto.tot + begenrto.tot), ;
			NewIntake   WITH newintto.tot, ;
			NewEnroll   WITH newenrto.tot, ;
			NewCnt	   WITH (newintto.tot + newenrto.tot), ; 
			ReopenCnt   WITH reopento.tot, ;
			ReopInCnt   WITH reopinto.tot, ;
			CloseEnrol  WITH closento.tot, ;
			CloseIntak  WITH closinto.tot, ;
			CloseInPer  WITH (closento.tot + closinto.tot), ;
			ConvIntake  WITH converto.tot, ;
			EndIntake   WITH endintto.tot, ;
			EndEnroll   WITH endenrto.tot, ;
			EndCnt      WITH (endintto.tot + endenrto.tot), ;
			BegIntAnon  WITH begintto.totanon, ;
			BegEnrAnon  WITH begenrto.totanon, ;
			BegCntAnon  WITH (begintto.totanon + begenrto.totanon), ;
			NewIntAnon  WITH newintto.totanon, ;
			NewEnrAnon  WITH newenrto.totanon, ;
			NewCntAnon  WITH (newintto.totanon + newenrto.totanon), ;
			ReopenAnon  WITH reopento.totanon, ;
			ReopInAnon  WITH reopinto.totanon, ;
			ClosEnrAn   WITH closento.totanon, ;
			ClosIntAn   WITH closinto.totanon, ;
			CloseAnon   WITH (closento.totanon + closinto.totanon), ;
			ConvAnon    WITH converto.totanon, ;
			EndIntAnon  WITH endintto.totanon, ;
			EndEnrAnon  WITH endenrto.totanon, ;
			EndCntAnon  WITH (endintto.totanon + endenrto.totanon)

*********************************************
* Family-Centered/Collateral Case Management:

IF Used("FamCollSum")
	USE IN FamCollSum
ENDIF

CREATE CURSOR FamCollSum (Prog_ID C(5), ProgrDesc C(30), Descript C(60), Count N(5), NotCount L(1))

* 12/98, make the counts go in this unduplicated order (each of the 5 categories included in GROUP total):
*			1) and 2) kids and adolescents 3) mates 4) other family members 5) other collaterals

* this cursor holds all collaterals receiving services of clients receiving services this period
SELECT DISTINCT;
		Hold1.Prog_ID, ;
		Hold1.ProgrDesc, ;
		Hold1.tc_id    , ;
		ClientFam.Client_id ,;
      	ClientFam.Dob, ;
		ClientFam.Age, ;
		Ai_Famil.Relation ;
FROM ;
		Hold1, Ai_Enc, Ai_Colen, client ClientFam, Ai_Famil ;
WHERE ;
  		BETW(Ai_Enc.act_dt,m.Date_from,m.Date_to) ;
  AND	Hold1.tc_id        = Ai_Enc.tc_id ;
  AND Hold1.tc_id        = Ai_Famil.tc_id ;
  AND Ai_Enc.Act_id      = Ai_Colen.Act_id ;
  AND Ai_Colen.Client_id = ClientFam.Client_id ;
  AND Ai_Colen.Client_id = Ai_Famil.Client_id ;
INTO CURSOR ;
		tTemp1 

***VT 10/25/2002 Collat can't works with cli_cur !!!!!!!!!!!!!!!!!!!
*cli_cur ClientFam

Use in ai_enc
Use in ai_colen

* next cursor sums by category for collaterals receiving services in period
SELECT ;
		ttemp1.Prog_ID, ;
		ttemp1.ProgrDesc, ;
		SUM(IIF(!EMPTY(tTemp1.dob) AND BETWEEN(tTemp1.Age,0,12),1,0)) 								 	AS Age0_12  ,;
		SUM(IIF(!EMPTY(tTemp1.dob) AND BETWEEN(tTemp1.Age,13,19),1,0)) 								AS Age13_19 ,;
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

* now, get all possible distinct collaterals by program
SELECT DISTINCT ;
		hold1.prog_id       ,;
      hold1.tc_id         ,;
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

* count the different categories of all possible collaterals by program
SELECT ;
		CollTemp.prog_id, ;
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

INDE ON prog_id TAG prog_id


***VT 08/10/2011 AIRS-91 
oldgcTC_id=gcTC_id
gcTC_id =''
=OpenView("lv_verification_filtered", "urs")
Requery('lv_verification_filtered')

gcTC_id=oldgcTC_id

SELECT tTemp
* relate to the total collateral cursor on program
SET RELA TO prog_id INTO CollTem2

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
		INSERT INTO FamCollSum VALUES (m.Prog_ID, m.ProgrDesc, cDescript, nCount, lNotCount)
	NEXT	
ENDSCAN	
IF USED('tTemp')
	USE IN tTemp
ENDIF	
IF USED('CollTemp')
	USE IN CollTemp
ENDIF	

*************************************************************

** DG 01/23/97 Start of the Loop
SELECT DIST Prog_ID, ProgrDesc ;
	FROM Hold1 ;
	INTO CURSOR tProgram ;
	ORDER BY 1

&&&  jss, 10/8/2000, moved code from inside scan out here to save time

**VT 02/12/2009 Dev Tick 4829 Changed prg_clos to new look up table closcode
   SELECT ;
      ClosEnro.Prog_id      AS Prog_ID, ;
      Prg_Clos.descript     AS label,   ;
      COUNT(ClosEnro.tc_id) AS count    ;
   FROM ;
      closcode Prg_Clos, ClosEnro ;
   WHERE ;
      ClosEnro.reason  = Prg_Clos.code     ;
   GROUP BY ;
      ClosEnro.Prog_id, ;
      Prg_Clos.code ;
   INTO CURSOR ;
      tCodeEnro
      
		
* now, look in ai_activ for those tc_ids in this program with no reason code in ai_prog
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
	SELECT ;
		ClosEnro.Prog_id      AS Prog_ID, ;
		ClosCode.descript     AS label,   ;
		COUNT(ClosEnro.tc_id) AS count    ;
	FROM ;
		ClosCode, ClosEnro, Ai_Activ, StatValu ;
	WHERE ;
		EMPTY(ClosEnro.reason)						AND ;
   	ClosEnro.tc_id  = ai_activ.tc_id    	AND ;
		ai_activ.status = statvalu.code 			AND ;
		statvalu.tc 	 = gcTC              	AND ;
		statvalu.type   = 'ACTIV'           	AND ;
	   !statvalu.incare                    	AND ;
		ai_activ.tc_id + DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm) ;
					IN (SELECT ;
							T1.tc_id + MAX(DTOS(T1.effect_dt)+oApp.Time24(T1.time, T1.am_pm)) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt <= m.Date_to ;
						GROUP BY ;
							T1.tc_id)      ;
		AND ;
      ClosCode.code   = ai_activ.close_code 			 ;
	GROUP BY ;
		ClosEnro.Prog_id, ;
		ClosCode.code ;
	INTO CURSOR ;
		tCodeEnro1

* now, get same info for closed intakes for this program
	SELECT ;
		ClosInt.Prog_id, ;
		ClosCode.descript     AS label,   ;
		COUNT(ClosInt.tc_id)  AS count    ;
	FROM ;
		ClosCode, ClosInt, Ai_Activ, StatValu ;
	WHERE ;
   	ClosInt.tc_id   = ai_activ.tc_id    	AND ;
		ai_activ.status = statvalu.code 			AND ;
		statvalu.tc 	 = gcTC              	AND ;
		statvalu.type   = 'ACTIV'           	AND ;
	   !statvalu.incare                    	AND ;
		ai_activ.tc_id + DTOS(ai_activ.effect_dt)+am_pm +time ;
					IN (SELECT ;
							T1.tc_id + MAX(DTOS(effect_dt)+am_pm+time) ;
						FROM ;
							ai_activ T1 ;
						WHERE ;
							T1.effect_dt <= m.Date_to ;
						GROUP BY ;
							T1.tc_id)      ;
	 AND ;
      ClosCode.code   = ai_activ.close_code 			 ;
	GROUP BY ;
		ClosInt.Prog_id, ;
		ClosCode.code ;
	INTO CURSOR ;
		tCodeInt

Use in ai_activ
Use in statvalu

* combine them all
	SELECT * FROM tCodeEnro 	;
	UNION ALL ;
	SELECT * FROM tCodeEnro1 	;
	UNION ALL ;
	SELECT * FROM tCodeInt 		;
	INTO CURSOR tCodeAll


	SELECT * ;
	FROM ;
		tCodeAll ;
	INTO CURSOR ;
		tCodeAll1
		      
*** jss, 10/26/00, new code added for CDC-defined AIDS

SELECT ;
		prog_id, ;
		COUNT(tc_id) AS cdcaidscnt;
FROM ;
		hold1 ;
WHERE ;
		&cWhereCli AND CDC_AID1(tc_id) ;
GROUP BY ;
		prog_id ;
INTO CURSOR ;
		CDC_AIDS		
		
INDEX ON prog_id TAG cdc_aids

store ' ' to m.label2,m.label3
SELECT tProgram
SCAN ALL 	
	SCATTER MEMVAR		
	**************************************************
	*- Aggregate by Case closure reasons *************
	**************************************************
		      
* sum them
	SELECT ;
		label, ;
		SUM(count) AS count ;
	FROM ;
		tCodeAll1 ;
	WHERE m.Prog_Id = tCodeAll1.Prog_Id ;	
	GROUP BY ;
		label ;
	INTO CURSOR ;
		CodeAll

	m.group = 'Closed Clients by Reason*'
	m.header = .t.
   mclosreas=0
	SCAN
    	SCATTER MEMVAR
    	mclosreas=mclosreas+m.count
		store ' ' to m.label2,m.label3
		m.count2=0
    	m.rec_no=m.rec_no+1
		INSERT INTO aiaggrpt FROM MEMVAR
		m.header = .f.
	ENDSCAN
	
* now, add in "Not Entered" when no reason is present
	mclenrtot=IIF(SEEK(m.prog_id,'closento'),closento.tot,0)
	mclinttot=IIF(SEEK(m.prog_id,'closinto'),closinto.tot,0)
	m.count = (mclenrtot + mclinttot) - mclosreas
* jss, 4/20/05, only print this line if it is non-zero
	If m.count>0
		m.label = "Not Entered"
		store ' ' to m.label2,m.label3
		m.count2=0
    	m.rec_no=m.rec_no+1   		
		INSERT INTO aiaggrpt FROM MEMVAR
	Endif	

	********************************************
	*- Aggregate by housing type ***************
	********************************************

* 12/98, jss, eliminate makesection routine
	m.group = cWCDesc + " Clients Housing Status*"
	m.header = .t.
	
	**VT 11/02/2011 AIRS-180
	Select ah.housing,;
	      ah.tc_id ;
	from hold1 ;
		inner join ai_housing ah on ;
			hold1.tc_id =ah.tc_id ;
	where &cWhereCli ;
			AND hold1.prog_id=m.prog_id;
			and Between(ah.effective_dt, m.date_from, m.date_to) ;
  into cursor t_hold1			
  
   =OpenFile("Housing", "code")
* scan gives us the counts for each code in the housing file for this program
	store ' ' to m.label2,m.label3
	m.count2=0
					
			
	SCAN
		m.label = descript
		**VT 11/02/2011 AIRS-180
		**SELECT hold1
		Select t_hold1
		**COUNT TO m.count FOR &cWhereCli AND hold1.housing=housing.code AND hold1.prog_id=m.prog_id
		COUNT TO m.count FOR t_hold1.housing=housing.code 
		If m.count>0
* jss, 4/20/05, only print this line if it is non-zero
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		Endif	
		Select Housing
	ENDSCAN

* this code handles "Not Entered" scenario (blank hold1.housing field)

	m.label = 'Not Entered'
	**VT 11/02/2011 AIRS-180
	**SELECT hold1
	SELECT t_hold1
	SET RELA TO housing INTO housing ADDITIVE
	**COUNT TO m.count FOR hold1.prog_id=m.prog_id AND &cWhereCli AND EOF('housing')
	
	COUNT TO m.count FOR EOF('housing')
	
* jss, 4/20/05, only print this line if it is non-zero
	IF m.count>0
    	m.rec_no=m.rec_no+1
		INSERT INTO aiaggrpt FROM MEMVAR
	ENDIF	
	
**VT 11/02/2011 AIRS-180
Use in t_hold1

* jss, 4/21/05, combine CDC and RW Risk section into one section
* jss, 5/17/05, add in new field "orderfield"
	Create Cursor combrisk (descript c(40), rw_code c(2), rw_flag L, cdc_code c(2), cdc_flag L, orderfield c(2))
	Index on ALLTRIM(descript) tag descript
	
  	=OpenFile("rw_risk", "code")
  	=OpenFile("cdc_risk", "code")

* load in all the cdc_risks
	SCAN
		INSERT INTO combrisk (descript, rw_code, rw_flag, cdc_code, cdc_flag, orderfield) values(cdc_risk.descript, '  ', .f., cdc_risk.code, .t., '  ')
	ENDSCAN	
	USE IN cdc_risk

* now, load in the rw_risks
	SELECT rw_risk
	SCAN
		IF SEEK(ALLTRIM(rw_risk.descript),'combrisk')
			SELECT combrisk
			REPLACE rw_code WITH rw_risk.code, rw_flag WITH .t.
		ELSE
			INSERT INTO combrisk (descript, rw_code, rw_flag, cdc_code, cdc_flag, orderfield) values(rw_risk.descript, rw_risk.code, .t., '  ', .f., '  ')
		ENDIF			
		SELECT rw_risk
	ENDSCAN			
	USE IN rw_risk

* jss, 5/17/05, now, load in the orderfield
	SELECT combrisk
	SCAN
		DO CASE
		CASE TRIM(descript)='MSM and IDU'
			Replace orderfield with '01'
		CASE TRIM(descript)='MSM'
			Replace orderfield with '02'
		CASE TRIM(descript)='IDU'
			Replace orderfield with '03'
		CASE TRIM(descript)='Heterosexual Contact'
			Replace orderfield with '04'
		CASE TRIM(descript)='Hemophilia/Coagulation Disorder'
			Replace orderfield with '05'
		CASE TRIM(descript)='Blood Product Recipient'
			Replace orderfield with '06'
		CASE TRIM(descript)='Mother with or at risk for HIV Infection'
			Replace orderfield with '07'
		CASE TRIM(descript)='Perinatal Transmission'
			Replace orderfield with '08'
		CASE TRIM(descript)='General Population'
			Replace orderfield with '09'
		CASE TRIM(descript)='Undetermined/Unknown'
			Replace orderfield with '10'
		CASE TRIM(descript)='Other'
			Replace orderfield with '11'	
		ENDCASE
	ENDSCAN
	
	Index on orderfield tag orderfield
	GO TOP

* now, use combrisk to drive report	

	Select * ;
	From relhist ;
	Where date <= m.Date_To ;
   Into Cursor t_relh readwrite
*	Into Cursor t_relh1
	
	Index On tc_id+STR({01/01/2100}-date) TAG tc_id
*	=ReOpenCur("t_relh1", "t_relh")
*	Set Order to tc_id
		
	Select hold1
	Set Relation To tc_id INTO t_relh
	
	m.group = cWCDesc + " Clients by Risk Category"
	m.header = .t.
	store ' ' to m.label2,m.label3

	Select combrisk
	SCAN 
		m.label = combrisk.descript
		SELECT hold1
		IF combrisk.cdc_flag
			COUNT TO m.count2 FOR ;
						&cWhereCli .AND. ;
                  		hold1.prog_id = m.prog_id AND ;
   						t_relh.cdc_code = combrisk.cdc_code
		ELSE
			m.count2=0
		ENDIF	
		IF combrisk.rw_flag
			COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
                  		hold1.prog_id = m.prog_id AND ;
   						t_relh.rw_code = combrisk.rw_code
		ELSE
			m.count=0
		ENDIF	
		IF m.count + m.count2 > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
		SELECT combrisk
	ENDSCAN
	
	USE IN combrisk
	
	******************************************************************
	*- Aggregate By Insurance Statuses From Intake
	******************************************************************
	
	m.group = cWCDesc + " Clients by Insurance Status (From Intake)"
	m.header = .t.
	cCode = "  "
***   	
		m.count2=0
	 	m.label = "Known" + Space(31)
		SELECT hold1
		COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
                  hold1.prog_id = m.prog_id AND ;
						hold1.insurance = 1
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
***
		m.label = "No Insurance" + Space(23)
		SELECT hold1
		COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
       	          hold1.prog_id = m.prog_id AND ;
						hold1.insurance = 3
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
***
		m.label = "Unknown/Unreported" + Space(18)
		SELECT hold1
		COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
                  hold1.prog_id = m.prog_id AND ;
						hold1.insurance = 2
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	

***
		m.label = "Not Entered" + Space(18)
		SELECT hold1
		COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
                  hold1.prog_id = m.prog_id AND ;
						(hold1.insurance <> 1 and hold1.insurance <> 2 and hold1.insurance <> 3)
		If m.count > 0					
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
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
	   hold1.prog_id   = m.prog_id         AND ;
		hold1.client_id = insstat.client_id AND ;
		&cWhereCli 								AND ;
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
	
	m.group  = cWCDesc + ' Clients by Primary Insurance Type'
	m.header = .t.
	store ' ' to m.label2,m.label3
	m.count2=0
	m.countknown=0
	SCAN
		m.label = instype.descript
		IF Seek(instype.descript, 'ins_temp')
			m.count = ins_temp.ins_count 
			m.countknown=m.countknown+m.count
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ELSE
			m.count = 0
		ENDIF
* jss, 4/20/05, only print non-zero lineitems, move insert up
*		INSERT INTO aiaggrpt FROM MEMVAR
*		m.header = .f.
	ENDSCAN
	
* jss, 4/17/05, add	a line for 'known insurance sub-total'
	m.header=.f.
	m.label=' '
	m.label3='Known Insurance Sub-Total'
	m.count=0
	m.count2=m.countknown
	m.rec_no=m.rec_no+1
	INSERT INTO aiaggrpt FROM MEMVAR

	m.label3=' '
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
* jss, 4/27/05, change 'Not Entered or Expired   ' to 'No or Unknown Insurance  '
	SELECT ;
		'No/Unknown Insurance     ' AS instype,  ;
		COUNT(*)                AS ins_count ;
	FROM ;
		hold1 ;
	WHERE ;
		hold1.prog_id   = m.prog_id			AND ;
		&cWhereCli                       AND ;
		hold1.client_id NOT IN (SELECT client_id FROM newclien) ;
	INTO CURSOR ;
		ins_tem2 ;
	GROUP BY 	;
		1
		
* add next 3 lines to insert "Not Entered" record into report cursor
	If _tally > 0
		m.label = ins_tem2.instype
		m.count = ins_tem2.ins_count
    	m.rec_no=m.rec_no+1
		INSERT INTO aiaggrpt FROM MEMVAR
	Endif	
	
* close up cursors now
	USE IN ins_temp
	USE IN newclien
	USE IN ins_tem2
	**************************************************************
	******************************************************************
	*- Aggregate by Income, Household Size, and Poverty Status
	******************************************************************

***VT 08/10/2011 AIRS-91 

*!*		SELECT 	Hold1.client_id, ;
*!*				Hold1.is_refus, ;
*!*				Hold1.hshld_incm, ;
*!*				Hold1.hshld_size ;
*!*		FROM ;
*!*			Hold1;
*!*		WHERE ;
*!*			hold1.prog_id  = m.prog_id  AND ;
*!*			&cWhereCli ;
*!*		INTO CURSOR tmp_h1

** Create cursor
			 If Used('all_hous')
				   Use In all_hous
			 EndIf
				
           Select ai_fin.tc_id, ;
				   	ai_fin.is_refus, ;
					   ai_fin.hshld_incm, ;
					   ai_fin.hshld_size, ;
					   ai_fin.pov_level ,;
					   ai_fin.pov_cat ;          
		    from ai_fin ;
		    into cursor all_hous ;
		    where 1=2 ;
		    readwrite
		      
**Fiind most recent verified date
Select Max(lvf.verified_datetime) as verified_datetime, ;
		lvf.tc_id ;
from lv_verification_filtered lvf ;
		inner join hold1 on;
		    	   hold1.tc_id = lvf.tc_id ;
          and lvf.vn_category="K" ;
          and Between(lvf.verified_datetime, m.date_from, m.date_to) ;
          and hold1.prog_id  = m.prog_id ;
     inner join ai_fin af on ;
     		     hold1.tc_id = af.tc_id ;
where &cWhereCli ;     		     
Group by lvf.tc_id ;
into cursor tmp_dt

If _Tally > 0
				Insert into all_hous ;
			     					( tc_id, ;
									 is_refus, ;
								    hshld_incm, ;
								    hshld_size, ;
								    pov_level ,;
								    pov_cat) ;	 	
     	        Select distinct ;
       		  			ai_fin.tc_id, ;
					   	ai_fin.is_refus, ;
						   ai_fin.hshld_incm, ;
						   ai_fin.hshld_size, ;
						   ai_fin.pov_level ,;
						   ai_fin.pov_cat ;          
			    from lv_verification_filtered lvf ;
				      inner join tmp_dt td on ;
				      	 lvf.tc_id = td.tc_id ;
				      and lvf.verified_datetime = td.verified_datetime ;
				      inner join ai_fin on ;
				          ai_fin.fin_id =lvf.table_id 
Else
	 **Find most recent record from ai_fin
		    Use in tmp_dt
		 
			 Select Max(af.ass_dt) as ass_dt, ;
					  af.tc_id ;
			 FROM Hold1 ;
			 		inner join ai_fin af on ;
		        		hold1.tc_id = af.tc_id  ;
				  and hold1.prog_id  = m.prog_id  ;
		 		  and Between(af.ass_dt,m.date_from, m.date_to) ;
			where &cWhereCli ;     		     
			Group by af.tc_id ;
		   into cursor tmp_dt
		   
	      If _Tally > 0
			     Insert into all_hous ;
			     					( tc_id, ;
									 is_refus, ;
								    hshld_incm, ;
								    hshld_size, ;
								    pov_level ,;
								    pov_cat) ;	 
		     	        Select distinct ;
		     	        			af.tc_id, ;
							   	af.is_refus, ;
								   af.hshld_incm, ;
								   af.hshld_size, ;
								   af.pov_level ,;
								   af.pov_cat ;          
					from ai_fin af ;
					      inner join tmp_dt td on ;
					      	 af.tc_id = td.tc_id ;
					      and af.ass_dt = td.ass_dt 
         EndIf
             
Endif

Use in tmp_dt


***VT 08/11/2011 AIRS-91 
*!*	   Select Distinct tmp_h1.*, ;
*!*	         poverty.pov_level;
*!*	   From tmp_h1, poverty, address ;
*!*	   Where tmp_h1.client_id = address.client_id and ;
*!*	         Iif((address.st <> "AK" AND address.st <> "HI"), poverty.st = "US", address.st = poverty.st) and ;
*!*	         poverty.pov_year = Right(Dtoc(m.date_to),4) and ;
*!*	         poverty.hshld_size = tmp_h1.hshld_size and ;
*!*	         tmp_h1.is_refus = .f. ;
*!*	   Union ;
*!*	   Select Distinct tmp_h1.*, ;
*!*	         000000 as pov_level ;
*!*	   From tmp_h1 ;
*!*	   Where tmp_h1.hshld_size = 0 or tmp_h1.is_refus = .t. ;
*!*	   Into Cursor t_hous
   
   
	**USE IN poverty
	**Use in address 
	**USE IN tmp_h1

	
***VT 08/11/2011 AIRS-91 
*!*		Select DISTINCT * , ;
*!*				Iif(pov_level = 0 , 000000, (hshld_incm * 100/pov_level)) as t_incm ; 
*!*		From t_hous ;
*!*		Into Cursor all_hous

*!*		Use in t_hous
*!*		
	m.group  = cWCDesc + ' Clients by Income, Household Size, and Poverty Status'
	m.header = .t.
	***

* jss, 10/25/04, include clients with household size > 0 and household income=0 in this group
		m.label = "At or below 100% of Poverty Level"
		SELECT all_hous
 	 ***VT 08/11/2011 AIRS-91 
		*COUNT TO m.count FOR t_incm <= 100 and t_incm >= 0  and is_refus=.f. and hshld_size <> 0
		COUNT TO m.count FOR pov_cat = 1
								
    	m.rec_no=m.rec_no+1
		INSERT INTO aiaggrpt FROM MEMVAR
		m.header = .f.

	***
		m.label = "At 101% to 200% of Poverty Level" 
		SELECT all_hous
		 ***VT 08/11/2011 AIRS-91 
*!*	COUNT TO m.count FOR	Between(t_incm, 101, 200)
		COUNT TO m.count FOR pov_cat = 2
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
	***
		m.label = "At 201% to 300% of Poverty Level"
		SELECT all_hous
		 ***VT 08/11/2011 AIRS-91 
*!*	COUNT TO m.count FOR Between(t_incm, 201, 300)
		COUNT TO m.count FOR pov_cat = 3
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	

	***
		m.label = "Above 300% of Poverty Level"
		SELECT all_hous
		***VT 08/11/2011 AIRS-91 
		**COUNT TO m.count FOR t_incm > 300
		COUNT TO m.count FOR pov_cat = 4
								
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	

	***
		m.label = "Refusing to report"
		SELECT all_hous
		COUNT TO m.count FOR ;
						is_refus
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
			
	***
		m.label = "Household Size Not Entered"
		SELECT all_hous
		COUNT TO m.count FOR ;
						hshld_size = 0 and is_refus =.f.
						
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
		
	Use in all_hous
	
	******************************************************************
	*- Aggregate by HIV status
   * first, get clients hivstatus

	******************************************************************
	*- Aggregate by HIV status
	=OpenFile("hivstat", "tc_id")
	Select * ;
	From hivstat ;
	Where hivstat.effect_dt <= m.Date_To ;
   Into Cursor t_hiv readwrite
*	Into Cursor t_hiv1
	
	Index On tc_id+STR({01/01/2100}-effect_dt) TAG tc_id
*	=ReOpenCur("t_hiv1", "t_hiv")
*	Set Order to tc_id
	
	SELECT hold1
	SET RELATION TO tc_id INTO t_hiv

* jss, 4/27/05, add code to count sub-total of HIV+ and subtotal of HIV-
	store ' ' to m.label2,m.label3
	m.count2=0

	=OpenFile("hstat", "code")
	m.group = cWCDesc + ' Adult Clients by HIV Status*'
	m.header = .t.
* jss, 4/20/05, in order to group adults first by HIV positive then by HIV negative, must scan hstat file 2x, once for HIV_Pos once for !HIV_Pos

	m.countpos=0
	SCAN FOR hstat.adult AND Hiv_Pos
		m.label = hstat.descript
		SELECT hold1
		COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
                  hold1.prog_id = m.prog_id AND ;
						t_hiv.hivstatus = hstat.code
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
			m.countpos=m.countpos+m.count
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
		Select hstat
	ENDSCAN
	
* jss, 4/27/05, add line for HIV+ subtotal
	m.label=' '
	m.label3='HIV-Positive Sub-Total'
	m.count=0
	m.count2=m.countpos	
   	m.rec_no=m.rec_no+1
	INSERT INTO aiaggrpt FROM MEMVAR
	m.header = .f.
	m.label3=' '	

	m.countneg=0
	select hstat
	set orde to descript
	SCAN FOR hstat.adult AND !Hiv_Pos
		m.label = hstat.descript
		SELECT hold1
		COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
                  hold1.prog_id = m.prog_id AND ;
						t_hiv.hivstatus = hstat.code
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
	    	m.countneg=m.countneg+m.count
			INSERT INTO aiaggrpt FROM MEMVAR
			Select hstat
		ENDIF	
	ENDSCAN
	
* jss, 4/27/05, add line for HIV- subtotal
	m.label=' '
	m.label3='HIV-Negative Sub-Total'
	m.count=0	
	m.count2=m.countneg
   	m.rec_no=m.rec_no+1
	INSERT INTO aiaggrpt FROM MEMVAR
	m.label3=' '	
	
* jss, 5/2/05, add new section detailing HIV+ Adults by CD4 range (and AIDS-defining DX)	
	******************************************************************
	*- Aggregate by CD4 Range (and AIDS-Defining Diagnoses)
	******************************************************************
* first, get all adult positive clients
	Select ;
		hivstat.tc_id ;
	From ;
		hivstat, hstat ;
	Where ;
		hivstat.hivstatus=hstat.code ;
		and hstat.hiv_pos and hstat.adult ;
		and hivstat.effect_dt <= m.date_to ;
		and hivstat.tc_id + hivstat.status_id in ;
			(Select tc_id + Max(status_id)  ;
			From hivstat ;
			Where effect_dt<=m.date_to ;
			Group by tc_id) ;
	Into Cursor ;
		adultpos

* next, get adult positives from hold1
	Select ;
		tc_id ;
	from ;
		Hold1 ;
	Where ;
		&cWhereCli ;
		and prog_id = m.prog_id ;
		and tc_id in ;
			(Select tc_id From adultpos) ;
	Into Cursor ;
		hold1adpos

	Use in adultpos
		
* now, grab all CD4 labtests
	Select 	tc_id, ;
			count ;
	From testres ;
	Where tc_id + labt_id in ;
		(Select t2.tc_id + Max(t2.labt_id) From testres t2 ;
			  Where t2.testtype = '06' ;
				and !Empty(t2.count) ;
				and t2.testdate <= m.date_to ;
			Group by t2.tc_id) ;
	Into Cursor ;
		Cd4Test

* now, find adult positive clients with CD4 test results and those with none
	Select 	tc_id, ;
			count, ; 
			.f. as AidsDefDx ;
	From Cd4Test ;
	Where tc_id In ;
		(Select tc_id From Hold1adpos) ;
	Union ;
	Select	tc_id, ;
			000000 as Count, ;
			.f. as AidsDefDx ;
	From hold1adpos ;
	Where tc_id Not In ;
		(Select tc_id From Cd4Test) ;
	Into Cursor ;
      Cd4Hold1 readwrite
*		Cd4Hold
		
	Use in hold1adpos	
	Use in Cd4Test

*	=ReopenCur("Cd4Hold","Cd4Hold1")
*	Use in Cd4Hold	
				
* now, get aids-defining diagnoses
	Select * ;
	From ai_diag ;
	Where diagdate <= m.Date_To and !Empty(hiv_icd9) ;
   Into Cursor t_diag readwrite
*   Into Cursor t_diag1
	
	Index On tc_id+STR({01/01/2100}-diagdate) TAG tc_id
*!*   	=ReOpenCur("t_diag1", "t_diag")
*!*   	Set Order to tc_id
*!*   	Use in t_diag1
		
	Select Cd4hold1
	Set Relation To tc_id INTO t_diag
	Go top
	Replace All AidsDefDx with Found('t_diag')
	Use in t_diag
			
* now, count the CD4 counts and aids-defining diagnoses within each
	Select * From Cd4Hold1 Where count=0				 	Into Cursor Cd_None
	Select * From Cd4Hold1 Where count>0 and count<100 		Into Cursor Cd_1_99
	Select * From Cd4Hold1 Where count>=100 and count<200 	Into Cursor Cd_100_199
	Select * From Cd4Hold1 Where count>=200				 	Into Cursor Cd_200plus
	Use in Cd4Hold1
	
	m.group = cWCDesc + ' Adult HIV+ Clients by CD4 Count and AIDS-Defining Dx*' 
	m.label='No CD4 Test Results'
	m.label2=' '
	m.label3=' '
	m.header=.t.	
	Store 0 to m.count, m.count2

	Select CD_none
	Count to m.count 
	Count to m.count2 For AidsDefDx
	m.rec_no=m.rec_no+1		 			
	INSERT INTO aiaggrpt FROM MEMVAR
	m.header = .f.

	m.label='CD4 Count 0-99'
	Store 0 to m.count, m.count2

	Select CD_1_99
	Count to m.count 
	Count to m.count2 For AidsDefDx
	m.rec_no=m.rec_no+1		 			
	INSERT INTO aiaggrpt FROM MEMVAR

	m.label='CD4 Count 100-199'
	Store 0 to m.count, m.count2

	Select CD_100_199
	Count to m.count 
	Count to m.count2 For AidsDefDx
	m.rec_no=m.rec_no+1		 			
	INSERT INTO aiaggrpt FROM MEMVAR

	m.label='CD4 Count 200 and above'
	Store 0 to m.count, m.count2

	Select CD_200plus
	Count to m.count 
	Count to m.count2 For AidsDefDx
	m.rec_no=m.rec_no+1		 			
	INSERT INTO aiaggrpt FROM MEMVAR
			 	
	Use in cd_none
	Use in cd_1_99
	Use in cd_100_199
	Use in cd_200plus
	Store 0 to m.count, m.count2
						
	* jss, 10/26/00, add new section detailing case of CDC-defined AIDS
	******************************************************************
	*- Aggregate by CDC-Defined AIDS
	******************************************************************

	STORE cWCDesc + ' Clients with CDC-Defined AIDS' TO m.group, m.label
	m.header = .t.
	
	IF SEEK(m.prog_id,'CDC_AIDS')
		m.count = CDC_AIDS.cdcaidscnt
	ELSE
		m.count = 0
	ENDIF
	
   	m.rec_no=m.rec_no+1
	INSERT INTO aiaggrpt FROM MEMVAR
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
   SELECT * ;
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


	m.group = cWCDesc + ' Pediatric Clients by HIV Status/Symptoms*'
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
							&cWhereCli ;
					  	AND ;
					      hold1.prog_id=m.prog_id  ;
						AND ;
							t_hiv.hivstatus = m.code ;
						AND ;
							t_hiv.symptoms = m.symptom 
							
* jss, 4/20/05, only print if non-zero number
			IF m.count > 0
		    	m.rec_no=m.rec_no+1
			   	INSERT INTO aiaggrpt FROM MEMVAR
				m.header = .f.
			ENDIF
		   
		ELSE   
   			m.label = Trim(hiv_sympt.hivstat) 
	   		SELECT hold1
		   	COUNT TO m.count FOR ;
						&cWhereCli .AND. ;
				      hold1.prog_id = m.prog_id .AND. ;
					 t_hiv.hivstatus = m.code 
					 
* jss, 4/20/05, only print if non-zero number
			IF m.count > 0
		    	m.rec_no=m.rec_no+1
				INSERT INTO aiaggrpt FROM MEMVAR
				m.header = .f.
			ENDIF   
		ENDIF		   
		SELE hiv_sympt
	ENDSCAN
	
	USE IN hiv_sympt
	Use in t_hiv
	
   ****************************
   * Clients HIV+ and PPD+
   ****************************
	=Seek(m.Prog_ID, "hold3")
	
	store ' ' to m.label2,m.label3
	m.count2=0
	
	IF cActivNew
		tot_hiv = hold3.TotHIVPPD
	ELSE
		tot_hiv = hold3.NewHIVPPD
	ENDIF

* jss, 4/20, add blank fifth position (used for Referral Source Type: "Internal" or "External")
* jss, 4/20, add blank sixth position (used for label3)
   	m.rec_no=m.rec_no+1
	INSERT INTO aiaggrpt VALUES ;
	           (m.Prog_ID, ;
	           	m.ProgrDesc,;
	           	cWCDesc + " Clients HIV+ and PPD+ *", ;
	           	cWCDesc + " Clients HIV+ AND PPD+", ;
	           	" ", ;
	           	" ", ;
	           	tot_hiv, ;
	           	.t., ;
	           	.f., m.rec_no, m.count2)
	
	**************************************
	* TB therapy descriptions
	**************************************
	=OpenFile("tbstatus", "tc_id")

	Select * ;
	From tbstatus ;
	Where tbstatus.effect_dt <= m.Date_To ;
	Into Cursor t_tb1
		
	=OpenFile("treatmen", "code")
	m.group = cWCDesc + ' Clients by TB Treatment*'
	m.header = .t.
	store ' ' to m.label2,m.label3
	m.count2=0
	SCAN
		m.label = treatmen.descript
		cCode = treatmen.code
		
		Select Count(*) as tot ;
		From hold1, t_tb1 ;
		Where &cWhereCli and ;
		      	hold1.prog_id = m.prog_id .AND. ;
				hold1.tc_id = t_tb1.tc_id and ;
				t_tb1.treatment = cCode ;
		Into Cursor t_tot1		
		
		m.count = t_tot1.tot
* jss, 4/20/05, only print if non-zero number
		IF m.count > 0
	    	m.rec_no=m.rec_no+1
			INSERT INTO aiaggrpt FROM MEMVAR
			m.header = .f.
		ENDIF	
		Use in t_tot1
		
		Select treatmen
	ENDSCAN
	Use in t_tb1
	
	******************************************************************
	SELECT Hold1.Prog_ID, Hold1.ProgrDesc, ;
		cWCDesc + ' Clients In Special Populations*' AS group, ;
	    Speclpop.descript AS label, ;
	    ' ' AS label2, ;
	    ' ' AS label3, ;
	        COUNT(*) AS count, ;
	       .f. AS header ;
	 FROM Hold1, ;
	      Ai_spclp, ;
	      Speclpop;
	WHERE &cWhereCli ;
	  AND Ai_spclp.tc_id = Hold1.tc_id;
	  AND Speclpop.code = Ai_spclp.code;
	  AND Hold1.Prog_ID = m.Prog_ID ;
	GROUP BY 2,4 ;
	ORDER BY 2,4 ;
	 INTO CURSOR tspcl1

* jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt  	 
	recsave=m.rec_no
	SCAN
    	m.rec_no=m.rec_no+1
    	SCATTER MEMVAR
    	m.header=IIF(m.rec_no=recsave+1,.t.,.f.)    		
    	SELECT aiaggrpt
    	APPEND BLANK
    	GATHER MEMVAR
    	SELECT tspcl1
	ENDSCAN
	USE IN tspcl1

	******************************************************************
	*- Aggregate By county
	SELECT Hold1.Prog_ID, Hold1.ProgrDesc, ;
	       cWCDesc + ' Clients by County' AS group    ,;
	       IIF(EMPTY(County), Padr('Not Entered',25), County) AS label  ,;
		    ' ' AS label2, ;
		    ' ' AS label3, ;
	       COUNT(*) AS count, ;
	       .f. AS header ;
	  FROM hold1 ;
	  WHERE &cWhereCli ;
	  		  AND Hold1.Prog_ID = m.Prog_ID ;
	  GROUP BY 2,4 ;
	  ORDER BY 2,4 ;
		INTO CURSOR tcounty

* jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt  	 
	recsave=m.rec_no
	SCAN
    	m.rec_no=m.rec_no+1
    	SCATTER MEMVAR
    	m.header=IIF(m.rec_no=recsave+1,.t.,.f.)    		
    	SELECT aiaggrpt
    	APPEND BLANK
    	GATHER MEMVAR
    	SELECT tcounty
	ENDSCAN
	USE IN tcounty
	
	******************************************************************
	*- Aggregate By zip code
	SELECT 	Prog_ID, ;
			ProgrDesc, ;
		    cWCDesc + ' Clients by ZIP code' AS group   ,;
	       	IIF(zip='     -    ','Not Entered', zip+SPACE(10)) AS label   ,;
		    ' ' AS label2, ;
		    ' ' AS label3, ;
	       	COUNT(*)  AS count   ,;
	       .f. AS header ;
	FROM hold1 ;
	WHERE &cWhereCli ;
   	AND Prog_ID = m.Prog_ID ;
     GROUP BY 2,4 ;
	  ORDER BY 2,4 ;
		INTO CURSOR tZipcode
	
* jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt  	 
	recsave=m.rec_no
	SCAN
    	m.rec_no=m.rec_no+1
    	SCATTER MEMVAR
    	m.header=IIF(m.rec_no=recsave+1,.t.,.f.)    		
    	SELECT aiaggrpt
    	APPEND BLANK
    	GATHER MEMVAR
    	SELECT tZipcode
	ENDSCAN
	USE IN tZipcode

	******************************************************************
* jss, 4/20/05, place 'Internal' and 'External' in their own column, label2
	*- Aggregate by referral source
	SELECT Hold1.Prog_ID, Hold1.ProgrDesc, ;
		cWCDesc + ' Clients by Referral Source' AS group    ,;
	       referalsrc AS label  ,;
	       IIF(nrefnote=1, 'Internal', IIF(nrefnote=2, 'External',' ')) AS label2 , ;
		   ' ' AS label3, ;
	       COUNT(*) AS count ,;
	       .f. AS header ;
	  FROM hold1 ;
	  WHERE &cWhereCli ;
   		  AND Hold1.Prog_ID = m.Prog_ID ;
	  GROUP BY 2,4 ;
	  ORDER BY 2,4 ;
		INTO CURSOR trefsrce
	
* jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt  	 
	recsave=m.rec_no
	SCAN
    	m.rec_no=m.rec_no+1
    	SCATTER MEMVAR
    	m.header=IIF(m.rec_no=recsave+1,.t.,.f.)    		
    	SELECT aiaggrpt
    	APPEND BLANK
    	GATHER MEMVAR
    	SELECT trefsrce
	ENDSCAN
	USE IN trefsrce

	******************************************************************
	*- Family-Centered/Collateral Case Management:
	SELECT Prog_ID, ProgrDesc, ;
	       'Family-Centered/Collateral Case Mgmt (of Total Possible)' AS Group, ;
	       Descript AS Label, ' ' AS label2, ' ' AS label3, Count, .F. AS Header, NotCount ;
	  FROM FamCollSum ;
	  WHERE Prog_ID = m.Prog_ID ;
		INTO CURSOR tfam
	
* jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt  	 
	recsave=m.rec_no
	SCAN
    	m.rec_no=m.rec_no+1
    	SCATTER MEMVAR
    	m.header=IIF(m.rec_no=recsave+1,.t.,.f.)    		
    	SELECT aiaggrpt
    	APPEND BLANK
    	GATHER MEMVAR
    	SELECT tfam
	ENDSCAN
	USE IN tfam

   ********************************************************************	
	n2=Seconds()
	*WAIT WINDOW "Elapsed Time: " + Str(n2-n1,10,2)
	
	oApp.msg2user('OFF')
	
	** DG 01/23/97 End of the Loop
	SELECT tProgram
ENDSCAN

cReportSelection = .agroup(nGroup)
* jss, 4/20/05, add label2 to aiaggrptj
* jss, 4/27/05, add label2 to aiaggrptj
* jss, 9/13/2006: for VFP, add the Agency totals now
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


SELECT ;
		aiaggrpt.progrdesc, ;
		aiaggrpt.group, ;
		aiaggrpt.label, ;
		aiaggrpt.label2, ;
		aiaggrpt.label3, ;
		aiaggrpt.count, ;
		aiaggrpt.header, ;
		aiaggrpt.notcount, ;
		aiaggrpt.rec_no, ;
		aiaggrpt.count2, ;
		hold3.*, 		;
      m.BegActTot as BegActTot, ;
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
      lcprog      as lcprog ;
FROM ;
		aiaggrpt,   ;
		hold3       ;
WHERE ;
		aiaggrpt.prog_id=hold3.prog_id ;
INTO CURSOR ;
		aiaggrptj

* make sure there are clients to report on

IF _TALLY = 0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF

USE IN aiaggrpt

* jss, 4/17/01, add flag enr_req to report cursor
SELECT ;
	aiaggrptj.*, ;
	aiaggrptj.rec_no, ;
	Program.Enr_Req, ;   
   cTitle as cTitle, ;
   cDemoTitle as cDemoTitle, ;
   cCumTitle as cCumTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
FROM ;
	aiaggrptj, Program ;
WHERE ;
	aiaggrptj.prog_id = program.prog_id ;
INTO CURSOR;
	aiaggrpt2 ;
ORDER BY rec_no

USE IN Program
USE IN AiAggRptj
USE IN hold10
USE IN hold2
USE IN hold3

*DO Rest_Env2 WITH aFiles_Open	
RETURN

********************
PROCEDURE AgeSxx_Rpt
********************
PARAMETER cActivNew
**********************************************************************
* jss, 4/19/05, age by sex by race crosstabs report, with modified age categories (Age 0-1, Age 2-12 replace Age 0-12, 
* 				age 70+ combined with Age 60_69 yielding Age 60+)
**********************************************************************

IF cActivNew
	rep_title1='Age by Sex by Ethnicity/Race - Active Clients'
	cWhereAgen = 'ActivAgen'
	cWhereProg = 'ActivProg'
ELSE
	rep_title1='Age by Sex by Ethnicity/Race - New Clients'
	cWhereAgen = 'NewAgency'
	cWhereProg = 'NewProg'
ENDIF	

*- cross tabs - age by race by gender

* "RaAgeHold1" cursor holds distinct clients + program 
Select DIST ;
   Tc_ID, ;
   Prog_ID, ;
   ProgrDesc, ;
   SPACE(18) AS Race, ;
	White, ;
   Blafrican, ;
   Asian, ;
   Hawaisland, ;
	indialaska, ;
   Unknowrep, ;
   someother, ;
   Hispanic, ;
	IIF(sex="M","Male    ", "Female  ") AS Gender, ;
	Dob, ;
   NewAgency, ;
   NewProg, ;
   ActivAgen, ;
   ActivProg, ;
   CalcAge(m.date_to, Dob) AS Client_Age ;
From Hold1 ;
Into Cursor RaAgeHold1 ReadWrite
	
*=ReopenCur("RaAgeHold0","RaAgeHold1")

SELECT RaAgeHold1
REPLACE ALL race WITH GetRace()	

*- Detail Information (program level)
*- cross tabs - age by race by sex
SELECT "Hispanic             " as hispanic, Prog_ID, ProgrDesc, Race, Gender, ;
	SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,1),1,0))    AS Age0_1   ,;
	SUM(IIF(BETWEEN(Client_Age,2,12),1,0))   AS Age2_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 60,1,0)) AS Age60Plus ,;
	SUM(IIF(Empty(Dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeHold1 ;
WHERE ;
	&cWhereProg and hispanic=2;
GROUP BY ;
	1,2,4,5 ;
INTO CURSOR ;
	t_hisp

SELECT "Non-Hispanic         " as hispanic, Prog_ID, ProgrDesc, Race, Gender, ;
	SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,1),1,0))    AS Age0_1   ,;
	SUM(IIF(BETWEEN(Client_Age,2,12),1,0))   AS Age2_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 60,1,0)) AS Age60Plus ,;
	SUM(IIF(Empty(Dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeHold1 ;
WHERE ;
	&cWhereProg and hispanic = 1;
GROUP BY ;
	1,2,4,5 ;
INTO CURSOR ;
	t_nhisp
	
	nUsed = 0
	
SELECT "Ethnicity Not Entered" as hispanic, Prog_ID, ProgrDesc, Race, Gender, ;
	SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,1),1,0))    AS Age0_1   ,;
	SUM(IIF(BETWEEN(Client_Age,2,12),1,0))   AS Age2_12   ,;
	SUM(IIF(BETWEEN(Client_Age,13,19),1,0))  AS Age13_19  ,;
	SUM(IIF(BETWEEN(Client_Age,20,29),1,0))  AS Age20_29  ,;
	SUM(IIF(BETWEEN(Client_Age,30,39),1,0))  AS Age30_39  ,;
	SUM(IIF(BETWEEN(Client_Age,40,49),1,0))  AS Age40_49  ,;
	SUM(IIF(BETWEEN(Client_Age,50,59),1,0))  AS Age50_59  ,;
	SUM(IIF(!Empty(dob) AND Client_Age >= 60,1,0)) AS Age60Plus ,;
	SUM(IIF(Empty(Dob),1,0)) AS AgeUnknown ,;
	COUNT(*) AS TOTAL ;
FROM ;
	RaAgeHold1 ;
WHERE ;
	&cWhereProg and hispanic <> 1 and hispanic <> 2;
GROUP BY ;
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

* make sure there are clients to report on
IF det_tally=0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF


*** jss, 4/27/05, no longer want zeros on report, so remove code filling out all unused gender/race combos with zeros

IF USED('race')
	USE IN race
ENDIF

SELECT 0
USE (DBF("hold3")) AGAIN ALIAS Age_Race0 EXCLUSIVE
INDEX ON Prog_ID + hispanic+ race + gender TAG typeprog


oApp.msg2user('OFF')

cReportSelection = "All Programs"

   
* jss, 9/14/06, add vars to select for VFP report
SELECT ;
	Age_Race0.*, ;
	.f. AS Enr_Req, ;
   cTitle as cTitle, ;
   Rep_title1 as Rep_title1, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
FROM ;
	Age_Race0 ;
INTO CURSOR ;
   Age_Race readwrite
*   Age_Race1 

*=ReopenCur("Age_Race1","Age_Race")   
=OpenFile("Program","Prog_Id")
SELECT Age_Race

SET RELATION TO prog_id INTO Program
GO TOP
REPLACE ALL Enr_Req WITH IIF(!EOF("Program"),Program.Enr_Req, .f.)

INDEX ON Prog_ID + hispanic +race + gender TAG typeprog
GO TOP

gcRptName = 'rpt_agesxx'
Do Case
CASE lPrev = .f.
   Report Form rpt_agesxx To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_agesxx', 1, 2)
EndCase

USE IN RaAgeHold1
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
****************
PARAMETERS tdDt2Calc2, tdDOB
PRIVATE ALL LIKE j*
m.jcOldDate=SET("date")
SET DATE AMERICAN
m.jnAge=YEAR(m.tdDt2Calc2)-YEAR(m.tdDOB)-;
        IIF(CTOD(LEFT(DTOC(m.tdDOB),6)+STR(YEAR(m.tdDt2Calc2)))>m.tdDt2Calc2,1,0)
SET DATE &jcOldDate
RETURN m.jnAge

**********************************************************
FUNCTION MakeSection
**********************************************************
*  Function.........: MakeSection
*) Description......: Creates a section in a file
**********************************************************
PARAMETERS cGrpName, cTable, cField, lNewOnly, cAddCond

PRIVATE cSearchStr
cSearchStr = IIF(lNewOnly, "hold1.newprog .AND. ", "") + ;
					IIF(!Empty(cAddCond), cAddCond + " .AND. ", "") + ;
					"hold1." + cField + " = " + cTable + ".code"

=OpenFile(cTable, "code")
m.group = cGrpName
m.header = .t.
SCAN
	m.label = &cTable..descript
	SELECT newprog
	COUNT TO m.count FOR &cSearchStr
	INSERT INTO aiaggrpt FROM MEMVAR
	m.header = .f.
ENDSCAN

* jss, 11/98, add this code to handle "Not Entered" scenario

m.label = 'Not Entered'
SELECT hold1
SET RELA TO &cField INTO &cTable ADDITIVE
COUNT TO m.count FOR newprog AND EOF(cTable)
INSERT INTO aiaggrpt FROM MEMVAR

RETURN
*-EOF MakeSection

**********************************************************************
PROCEDURE Rpt_RevSumm
*PARAMETER nClick,nTimes
*************************************************************************
* jss, 10/2000, completely re-written with new specs
* this is the report that gives the amount newly billed, rebilled, pended, denied, adjusted and paid

IF USED('tBilled')
	USE IN tBilled
ENDIF	

IF USED('tReBilled')
	USE IN tReBilled
ENDIF	

IF USED('tPended')
	USE IN tPended
ENDIF	

IF USED('tDenied')
	USE IN tDenied
ENDIF	

IF USED('tDenyReb')
	USE IN tDenyReb
ENDIF	

IF USED('tDenyNev')
	USE IN tDenyNev
ENDIF	

IF USED('tDenyNA')
	USE IN tDenyNA
ENDIF	

IF USED('tPaid')
	USE IN tPaid
ENDIF	

IF USED('tVoided')
	USE IN tVoided
ENDIF	

IF USED('tAdjusted')
	USE IN tAdjusted
ENDIF	

IF USED('Billed')
	USE IN Billed
ENDIF	

IF USED('ReBilled')
	USE IN ReBilled
ENDIF	

IF USED('Pended')
	USE IN Pended
ENDIF	

IF USED('Denied')
	USE IN Denied
ENDIF	

IF USED('DenyReb')
	USE IN DenyReb
ENDIF	

IF USED('DenyNev')
	USE IN DenyNev
ENDIF	

IF USED('DenyNA')
	USE IN DenyNA
ENDIF	

IF USED('Paid')
	USE IN Paid
ENDIF	

IF USED('Voided')
	USE IN Voided
ENDIF	

IF USED('Adjusted')
	USE IN Adjusted
ENDIF	

IF USED('AllProgs')
	USE IN AllProgs
ENDIF	

IF USED('tFinal')
	USE IN tFinal
ENDIF	

IF USED('tSumm')
	USE IN tSumm
ENDIF	

IF USED("RevenueSum")
	USE IN RevenueSum
ENDIF

IF USED("tHold")   
   USE IN tHold
ENDIF

CREATE CURSOR RevenueSum (Prog_ID C(5), ProgrDesc C(30), Descript C(25), Amount N(8,2))
PRIVATE cBlankInv
cBlankInv = SPACE(9)

* first, grab the newly billed
**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And  Inlist(claim_dt.program, "  + lcprog + ")" )
*AND claim_dt.program = lcProg ;


SELECT 																;
		Claim_Dt.Program 			AS Prog_Id,   				;
		Program.Descript			AS ProgrDesc, 				;
      SUM(Claim_Dt.Amount) 	As Billed 					;
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = "D" 							;
	  AND	EMPTY(Claim_Hd.adj_void) 							;
	  AND Claim_Dt.first_inv = cBlankInv 					;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg                   							;
     AND Claim_Dt.Enc_site= cCSite 							;
  INTO CURSOR tBilled 											;
	  GROUP BY 1

**VT 01/08/2008
**AND Claim_Dt.Program = lcProg	  changed to cWhereprg

* now, grab re-billed (most recent)

SELECT 																								;
		Claim_Dt.Program 		  AS Prog_Id,   												;
		Program.Descript		  AS ProgrDesc, 												;
      SUM(Claim_Dt.Amount)	  As ReBilled 													;
	FROM 																								;
	   Claim_Hd, 																					;
	   Claim_Dt, 																					;
	   Program   																					;
	WHERE 																							;
	  BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) 									; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 											;
	  AND Claim_Hd.Processed = "D" 															;
	  AND	EMPTY(Claim_Hd.adj_void) 															;		
	  AND Claim_Dt.first_inv <> cBlankInv 													;
	  AND Claim_Dt.r_line 																		;
	  AND Claim_Dt.Program = Program.Prog_Id												;
     &cWherePrg    							               								;
     AND Claim_Dt.Enc_site= cCSite 															;
     AND Claim_Dt.First_Inv + DTOS(Claim_Dt.Status_dt)  								;
     									IN (SELECT 	ClDt.First_Inv + MAX(DTOS(ClDt.Status_dt)) ;
     										FROM 	Claim_Dt ClDt 									;
     									   WHERE ClDt.Status_dt <= m.Date_To			 	;
     									   GROUP BY ClDt.First_Inv)							;
  INTO CURSOR tReBilled 																		;
	  GROUP BY 1

** VT 01/08/2008
**And claim_dt.program = lcprog changed to cWhere Prg	  

* now, grab the pended info (Status = 1)

SELECT ;
		Claim_Dt.Program       AS Prog_Id,   				;
		Program.Descript       AS ProgrDesc, 				;
		SUM(Claim_Dt.Amount)   AS Paid       				;			
	FROM 																;
		Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To)	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = 'D' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Status  = 1 								;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg                          					;
     AND Claim_dt.Enc_site=cCSite 							;
  INTO CURSOR tPended 											;
	  GROUP BY 1

**VT 01/08/2008
** And claim_dt.program=lcProg changed to cWherePrg
	  
* now, grab the denied info (Status = 2)

SELECT 																;
		Claim_Dt.Program       AS Prog_Id,   				;
		Program.Descript       AS ProgrDesc, 				;
		SUM(Claim_Dt.Amount)   AS Paid       				;		
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = 'D' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Status  = 2 								;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg						;
     AND Claim_dt.Enc_site=cCSite 							;
  INTO CURSOR tDenied 											;
	  GROUP BY 1

**VT 01/08/2008
**And claim_dt.program=lcprog changed to cwhereprg	  
* now, grab the denied info that's been rebilled (Status = 2, action = 1)

SELECT 																;
		Claim_Dt.Program       AS Prog_Id,   				;
		Program.Descript       AS ProgrDesc, 				;
		SUM(Claim_Dt.Amount)   AS Paid       				;		
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = 'D' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Status  = 2 								;
	  AND Claim_Dt.Action  = 1 								;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg 							;
     AND Claim_dt.Enc_site=cCSite 							;
  INTO CURSOR tDenyReb 											;
	  GROUP BY 1

**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg
 
* now, grab the denied info that's never to be rebilled (Status = 2, action = 2)

SELECT 																;
		Claim_Dt.Program       AS Prog_Id,   				;
		Program.Descript       AS ProgrDesc, 				;
		SUM(Claim_Dt.Amount)   AS Paid       				;		
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = 'D' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Status  = 2 								;
	  AND Claim_Dt.Action  = 2 								;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg							;
     AND Claim_dt.Enc_site=cCSite 							;
  INTO CURSOR tDenyNev 											;
	  GROUP BY 1

**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg
	  
* now, grab the denied info that has no action taken yet (Status = 2, action = 0)
SELECT 																;
		Claim_Dt.Program       AS Prog_Id,   				;
		Program.Descript       AS ProgrDesc, 				;
		SUM(Claim_Dt.Amount)   AS Paid       				;		
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = 'D' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Status  = 2 								;
	  AND Claim_Dt.Action  = 0 								;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg							;
     AND Claim_dt.Enc_site=cCSite 							;
  INTO CURSOR tDenyNA 											;
	  GROUP BY 1

* now, handle adjustments: first, just get raw adjustment amounts
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

SELECT 																;
		Claim_Dt.Program 				AS Prog_Id,  			;
		Program.Descript				AS ProgrDesc,			;
      Claim_Dt.Amount 				As Adjust_Amt, 		;
      Claim_Hd.Orig_ref											;
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = "D" 							;
	  AND	Claim_Hd.adj_void = 'A' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg							;
     AND Claim_Dt.Enc_site= cCSite 							;
  INTO CURSOR tAdjAmt 											
	  
* next, sum the difference between the adjustment amount and the original amount
SELECT 																		;
		tAdjAmt.Prog_id, 													;
		tAdjAmt.ProgrDesc, 												;
		SUM(tAdjAmt.Adjust_Amt - Claim_Dt.Amount) AS Adjusted	;
	FROM 																		;
		tAdjAmt, 															;	
		Claim_Dt 															;
	WHERE 																	;
		tAdjAmt.Orig_Ref	= Claim_Dt.Claim_Ref 					;
	INTO CURSOR tAdjusted												;
	GROUP BY 1

* now, grab the voids
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

SELECT 																;
		Claim_Dt.Program 				AS Prog_Id,  			;
		Program.Descript				AS ProgrDesc,			;
      SUM(Claim_Dt.Amount * -1) 	As Voided 				;
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = "D" 							;
	  AND	Claim_Hd.adj_void = 'V' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg 							;
     AND Claim_Dt.Enc_site= cCSite 							;
  INTO CURSOR tVoided 											;
	  GROUP BY 1	  
	  
* next, grab the Paid info (status = 3)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

SELECT 																;
		Claim_Dt.Program       AS Prog_Id,   				;
		Program.Descript       AS ProgrDesc, 				;
		SUM(Claim_Dt.Amt_Paid) AS Paid       				;		
	FROM 																;
	   Claim_Hd, 													;
	   Claim_Dt, 													;
	   Program   													;
	WHERE 															;
	  BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) 	; 	
	  AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
	  AND Claim_Hd.Processed = 'D' 							;
	  AND Claim_Dt.r_line 										;
	  AND Claim_Dt.Status  = 3 								;
	  AND Claim_Dt.Program = Program.Prog_Id				;
     &cWherePrg 							;
     AND Claim_dt.Enc_site=cCSite 							;
  INTO CURSOR tPaid 												;
	  GROUP BY 1

**VT 01/08/2008
cWherePrg = ''
			
* now, determine all programs represented in the above cursors

SELECT Prog_id, ProgrDesc FROM tBilled ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tReBilled ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tPended ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tDenied ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tDenyReb ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tDenyNev ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tDenyNA ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tAdjusted ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tVoided ;
UNION ;
SELECT Prog_id, ProgrDesc FROM tPaid ;
INTO CURSOR ;
	AllProgs 
	
* now, fill in the gaps for each cursor

SELECT * FROM tBilled ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  Billed  ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tBilled) ;
	INTO CURSOR ;
		Billed				
	  
SELECT * FROM tReBilled ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  ReBilled   ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tReBilled) ;
	INTO CURSOR ;
		ReBilled				

* now, combine billed and rebilled for total billed

SELECT ;
		Billed.Prog_id, ;
		Billed.ProgrDesc, ;
		(Billed.Billed + ReBilled.ReBilled) AS TotBilled ;
	FROM ;
		Billed, ReBilled ;
	WHERE ;
		Billed.Prog_id = ReBilled.Prog_id ;
	INTO CURSOR ;
		TotBilled		
	  
SELECT * FROM tPended ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  Pended     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tPended) ;
	INTO CURSOR ;
		Pended				
	  
SELECT * FROM tDenied ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  Denied     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tDenied) ;
	INTO CURSOR ;
		Denied

SELECT * FROM tDenyReb ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  DenyReb     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tDenyReb) ;
	INTO CURSOR ;
		DenyReb

SELECT * FROM tDenyNev ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  DenyNev     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tDenyNev) ;
	INTO CURSOR ;
		DenyNev

SELECT * FROM tDenyNA ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  DenyNA     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tDenyNA) ;
	INTO CURSOR ;
		DenyNA

SELECT * FROM tAdjusted ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  Adjusted   ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tAdjusted) ;
	INTO CURSOR ;
		Adjusted

SELECT * FROM tVoided ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  Voided     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tVoided) ;
	INTO CURSOR ;
		Voided

SELECT * FROM tPaid ;
UNION ;
SELECT ;
		AllProgs.Prog_Id,   ;
		AllProgs.ProgrDesc, ;
      0.00 AS  Paid     ;
	FROM ;
		AllProgs ;
	WHERE ;
		Prog_Id NOT IN ;
			(SELECT Prog_Id FROM tPaid) ;
	INTO CURSOR ;
		Paid

* now, combine the cursors
SELECT ;
		a.Prog_Id, 		;
		a.ProgrDesc, 	;
		c.TotBilled, 	;
		a.Billed, 		;
		b.ReBilled, 	;
		d.Pended, 		;
		e.Denied, 		;
		i.DenyReb,     ;
		j.DenyNev,     ;
		k.DenyNa,      ;
		f.Adjusted,    ;
		g.Voided,		;
		h.Paid 			;
FROM 						;			
		Billed   a,		;
		ReBilled b, 	;
		TotBilled c, 	;
		Pended   d,		;
		Denied	e,		;
		Adjusted	f,		;
		Voided	g,		;
		Paid		h,		;
		DenyReb	i,		;
		DenyNev	j,		;
		DenyNA	k		;		
WHERE ;
		a.Prog_Id = b.Prog_Id	AND ;
		a.Prog_Id = c.Prog_Id	AND ;
		a.Prog_Id = d.Prog_Id	AND ;
		a.Prog_Id = e.Prog_Id	AND ;
		a.Prog_Id = f.Prog_Id	AND ;
		a.Prog_Id = g.Prog_Id	AND ;
		a.Prog_Id = h.Prog_Id	AND ;
		a.Prog_Id = i.Prog_Id	AND ;
		a.Prog_Id = j.Prog_Id	AND ;
		a.Prog_Id = k.Prog_Id	    ;
INTO CURSOR ;
		tFinal		
		
* create detail lines for report	in cursor revenuesum
SELECT tFinal
SCAN
	SCATTER MEMVAR
	FOR i = 3 TO FCOUNT()
		DO CASE 
			CASE FIELD(i) = "TOTBILLED"
				cDescript = "Total Billed Claims"
			CASE FIELD(i) = "BILLED"
				cDescript = "     Newly Billed Claims"
			CASE FIELD(i) = "REBILLED"
				cDescript = "     Re-Billed Claims"
			CASE FIELD(i) = "PENDED"
				cDescript = "Claims Pended"			
			CASE FIELD(i) = "DENIED"
				cDescript = "Total Claims Denied"			
			CASE FIELD(i) = "DENYREB"
				cDescript = "     Denied-Rebill"			
			CASE FIELD(i) = "DENYNEV"
				cDescript = "     Denied-Never Rebill"			
			CASE FIELD(i) = "DENYNA"
				cDescript = "     Denied-No Action"			
			CASE FIELD(i) = "ADJUSTED"
				cDescript = "Revenues Adjusted"						
			CASE FIELD(i) = "VOIDED"
				cDescript = "Revenues Voided"			
			CASE FIELD(i) = "PAID"
				cDescript = "Revenues Received"						
		ENDCASE
		nAmount = EVAL(FIELD(i))
		INSERT INTO RevenueSum VALUES (m.Prog_ID, m.ProgrDesc, cDescript, nAmount)
	NEXT	
ENDSCAN	

* close some cursors
USE IN tBilled			
USE IN tReBilled
USE IN tPended
USE IN tDenied
USE IN tDenyReb
USE IN tDenyNev
USE IN tDenyNA
USE IN tAdjusted
USE IN tVoided
USE IN tPaid

USE IN Billed			
USE IN ReBilled
USE IN TotBilled
USE IN Pended
USE IN Denied
USE IN DenyReb
USE IN DenyNev
USE IN DenyNA
USE IN Adjusted
USE IN Voided
USE IN Paid

* Summary Info, just sum the revenuesum cursor
SELECT ;
		SUM(IIF(Descript = "Total Billed Claims", Amount, 0.00)) 	AS TotBilled, ;
		SUM(IIF(Descript = "     Newly Billed Claims",Amount, 0.00)) 	   AS Billed,   ;
		SUM(IIF(Descript = "     Re-Billed Claims", Amount, 0.00)) 		AS ReBilled, ;
		SUM(IIF(Descript = "Claims Pended"    ,Amount, 0.00)) 		AS Pended,   ;
		SUM(IIF(Descript = "Total Claims Denied"    ,Amount, 0.00)) 		AS Denied,   ;
		SUM(IIF(Descript = "     Denied-Rebill"    ,Amount, 0.00)) 		AS DenyReb,   ;
		SUM(IIF(Descript = "     Denied-Never Rebill"    ,Amount, 0.00)) 		AS DenyNev,   ;
		SUM(IIF(Descript = "     Denied-No Action"    ,Amount, 0.00)) 		AS DenyNA,   ;
		SUM(IIF(Descript = "Revenues Adjusted",Amount, 0.00)) 		AS Adjusted, ;
		SUM(IIF(Descript = "Revenues Voided"  ,Amount, 0.00)) 		AS Voided,   ;
		SUM(IIF(Descript = "Revenues Received",Amount, 0.00)) 		AS Paid      ;
	FROM ;
		RevenueSum ;
   INTO CURSOR ;
   	tSumm

* now, add a record to revenuesum cursor for the summary info
cProg_ID = 'ZZZZZ'
cProgrDesc = 'Summary Information'
SELECT tSumm
FOR i = 1 TO FCOUNT()
	DO CASE 
		CASE FIELD(i) = "TOTBILLED"
			cDescript = "Total Billed Claims"
		CASE FIELD(i) = "BILLED"
			cDescript = "     Newly Billed Claims"
		CASE FIELD(i) = "REBILLED"
			cDescript = "     Re-Billed Claims"
		CASE FIELD(i) = "PENDED"
			cDescript = "Claims Pended"			
		CASE FIELD(i) = "DENIED"
			cDescript = "Total Claims Denied"			
		CASE FIELD(i) = "DENYREB"
			cDescript = "     Denied-Rebill"			
		CASE FIELD(i) = "DENYNEV"
			cDescript = "     Denied-Never Rebill"			
		CASE FIELD(i) = "DENYNA"
			cDescript = "     Denied-No Action"			
		CASE FIELD(i) = "ADJUSTED"
			cDescript = "Revenues Adjusted"						
		CASE FIELD(i) = "VOIDED"
			cDescript = "Revenues Voided"			
		CASE FIELD(i) = "PAID"
			cDescript = "Revenues Received"						
	ENDCASE
	nAmount = EVAL(FIELD(i))
	INSERT INTO RevenueSum VALUES (cProg_ID, cProgrDesc, cDescript, nAmount)
NEXT	

USE IN tSumm

IF _TALLY = 0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF

oApp.msg2user('OFF')

cReportSelection = .agroup(nGroup)

SELECT *, ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
	FROM RevenueSum ;
	INTO CURSOR tHold ;
	ORDER BY 1
	 

gcRptName = 'rpt_revsumm'
Do Case
CASE lPrev = .f.
   Report Form rpt_revsumm To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_revsumm', 1, 2)
EndCase

USE IN RevenueSum
*USE IN tHold
RETURN

**********************************************************************
PROCEDURE Rpt_RevDet
*PARAMETER nClick,nTimes
*************************************************************************
* jss, 2/2001, give a detail of revsummrpt
* this is the report that gives the details of amount newly billed, rebilled, pended, denied, adjusted and paid

IF USED('tBilled')
	USE IN tBilled
ENDIF	

IF USED('tReBilled')
	USE IN tReBilled
ENDIF	

IF USED('tPended')
	USE IN tPended
ENDIF	

IF USED('tDenyReb')
	USE IN tDenyReb
ENDIF	

IF USED('tDenyNev')
	USE IN tDenyNev
ENDIF	

IF USED('tDenyNA')
	USE IN tDenyNA
ENDIF	

IF USED('tPaid')
	USE IN tPaid
ENDIF	

IF USED('tVoided')
	USE IN tVoided
ENDIF	

IF USED('tAdjust')
	USE IN tAdjust
ENDIF	

IF USED('tFinal')
   USE IN tFinal
ENDIF   

IF USED('tFinal2')
   USE IN tFinal2
ENDIF   

* first, grab the newly billed
**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And  Inlist(claim_dt.program, "  + lcprog + ")" )
*AND claim_dt.program = lcProg ;


SELECT 												;
	Claim_Dt.Program 			AS Prog_Id,   		;
	Program.Descript			AS ProgrDesc, 		;
	'01'						AS ClaimType, 		;
	PADR('Newly Billed Claims',30) AS ClaimDesc, 	;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
    SUM(Claim_Dt.Amount)		AS ClaimAmt 		;
FROM 												;
   	Claim_Hd, 										;
   	Claim_Dt, 										;
   	Program   										;
WHERE 												;
	BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = "D" 						;
AND	EMPTY(Claim_Hd.adj_void) 						;
AND Claim_Dt.first_inv = SPACE(9) 					;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg  						;
AND Claim_Dt.Enc_site= cCSite 						;
AND Claim_dt.Amount <> 0							;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tBilled 									

* these tables needed because of inconsistencies in numeric field length for cursors produced in select 
*COPY STRU TO tAdjust
*COPY STRU TO tVoided
*USE tAdjust IN 0
*USE tVoided IN 0

* now, grab re-billed (most recent)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT 																								;
	Claim_Dt.Program 	  		AS Prog_Id,   		;
	Program.Descript	  		AS ProgrDesc, 		;
	'02'						AS ClaimType, 		;
	PADR('Re-Billed Claims',30) AS ClaimDesc, 		;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
    SUM(Claim_Dt.Amount)		AS ClaimAmt 		;
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Hd.bill_date, Date_From, Date_to)	; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = "D" 						;
AND	EMPTY(Claim_Hd.adj_void) 						;		
AND Claim_Dt.first_inv <> SPACE(9)  				;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_Dt.Enc_site= cCSite 						;
AND Claim_dt.Amount <> 0							;
AND Claim_Dt.First_Inv + DTOS(Claim_Dt.Status_dt)  	;
	IN (SELECT 	ClDt.First_Inv + MAX(DTOS(ClDt.Status_dt)) ;
    	FROM 	Claim_Dt ClDt 						;
    	WHERE ClDt.Status_dt <= m.Date_To			;
    	GROUP BY ClDt.First_Inv)					;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tReBilled 																		
	  
* now, grab the pended info (Status = 1)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT ;
	Claim_Dt.Program       		AS Prog_Id,   		;
	Program.Descript       		AS ProgrDesc, 		;
	'03'						AS ClaimType, 		;
	PADR('Claims Pended',30) 	AS ClaimDesc, 		;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
	SUM(Claim_Dt.Amount)		AS ClaimAmt    		;			
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To)	; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = 'D' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Status  = 1 							;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_dt.Enc_site=cCSite 						;
AND Claim_dt.Amount <> 0							;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tPended 											
	  
* now, grab the denied info that's been rebilled (Status = 2, action = 1)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT 												;
	Claim_Dt.Program       		AS Prog_Id,   		;
	Program.Descript       		AS ProgrDesc, 		;
	'04'						AS ClaimType, 		;
	PADR('Claims Denied-Rebill',30) 	AS ClaimDesc, 		;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
	SUM(Claim_Dt.Amount)		AS ClaimAmt       	;		
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = 'D' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Status  = 2 							;
AND Claim_Dt.Action  = 1 							;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_dt.Enc_site=cCSite 						;
AND Claim_dt.Amount <> 0							;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tDenyReb 										
	  
* now, grab the denied info that's never to be rebilled (Status = 2, action = 2)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT 												;
	Claim_Dt.Program       		AS Prog_Id,  		;
	Program.Descript       		AS ProgrDesc,		;
	'05'						AS ClaimType, 		;
	PADR('Claims Denied-Never Rebill',30) 	AS ClaimDesc, 	;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
	SUM(Claim_Dt.Amount)   		AS ClaimAmt  		;		
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = 'D' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Status  = 2 							;
AND Claim_Dt.Action  = 2 							;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_dt.Enc_site=cCSite 						;
AND Claim_dt.Amount <> 0							;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tDenyNev 											
	  
* now, grab the denied info that has no action taken yet (Status = 2, action = 0)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT 												;
	Claim_Dt.Program       		AS Prog_Id,   		;
	Program.Descript       		AS ProgrDesc, 		;
	'06'						AS ClaimType, 		;
	PADR('Claims Denied-No Action',30) 	AS ClaimDesc, 		;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
	SUM(Claim_Dt.Amount)		AS ClaimAmt       	;		
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = 'D' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Status  = 2 							;
AND Claim_Dt.Action  = 0 							;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_dt.Enc_site=cCSite 						;
AND Claim_dt.Amount <> 0							;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tDenyNA 											

* now, handle adjustments: first, just get raw adjustment amounts
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT 												;
	Claim_Dt.Program 			AS Prog_Id,  		;
	Program.Descript			AS ProgrDesc,		;
	'07'						AS ClaimType, 		;
	PADR('Revenues Adjusted',30) AS ClaimDesc, 		;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
	Claim_Dt.Amount				AS ClaimAmt,       	;		
    Claim_Hd.Orig_ref								;
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = "D" 						;
AND	Claim_Hd.adj_void = 'A' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg 						;
AND Claim_Dt.Enc_site= cCSite 						;
AND Claim_dt.Amount <> 0							;
INTO CURSOR tAdjAmt 											
	  
* now, find the difference between the adjustment amount and the original amount: report this amount
SELECT 												;
	tAdjAmt.Prog_id, 								;
	tAdjAmt.ProgrDesc, 								;
	tAdjAmt.ClaimType, 								;
	tAdjAmt.ClaimDesc, 								;
	tAdjAmt.InvoiceNum, 							;
	tAdjAmt.ClaimDate, 								;
	(tAdjAmt.ClaimAmt - Claim_Dt.Amount) AS ClaimAmt	;
FROM 												;
	tAdjAmt, 										;	
	Claim_Dt 										;
WHERE 												;
	tAdjAmt.Orig_Ref = Claim_Dt.Claim_Ref 			;
Into Cursor tAdjust   
*INTO TABLE tAdjust1

* note: we did this because tAdjust1 creation above produced field ClaimAmt with length 8
*      (including 2 decimals), while the amount field is length 7 with 2 dec
*IF _Tally > 0
*	SELECT tAdjust
*	APPEND FROM tAdjust1
*ENDIF

* now, grab the voids	
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg
		
SELECT 												;
	Claim_Dt.Program 			AS Prog_Id,  		;
	Program.Descript			AS ProgrDesc,		;
	'08'						AS ClaimType, 		;
	PADR('Revenues Voided',30) 	AS ClaimDesc, 		;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
    (Claim_Dt.Amount * -1) 		As ClaimAmt			;
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Hd.bill_date, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = "D" 						;
AND Claim_Hd.adj_void = 'V' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_Dt.Enc_site= cCSite 						;
AND Claim_dt.Amount <> 0							;
Into Cursor tVoided
*INTO TABLE tVoid1

*IF _Tally > 0
*	SELECT tVoided
*	APPEND FROM tVoid1
*ENDIF
	  
* next, grab the Paid info (status = 3)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

SELECT 												;
	Claim_Dt.Program       		AS Prog_Id,   		;
	Program.Descript       		AS ProgrDesc, 		;
	'09'						AS ClaimType, 		;
	PADR('Revenues Received',30) 	AS ClaimDesc, 	;
	Claim_Hd.Invoice			AS InvoiceNum, 		;
	Claim_Hd.bill_date          AS ClaimDate, 		;
	SUM(Claim_Dt.Amt_Paid)		AS ClaimAmt       	;		
FROM 												;
	Claim_Hd, 										;
	Claim_Dt, 										;
	Program   										;
WHERE 												;
	BETWEEN(Claim_Dt.Status_Dt, Date_From, Date_To) ; 	
AND Claim_Hd.Invoice   = Claim_Dt.Invoice 			;
AND Claim_Hd.Processed = 'D' 						;
AND Claim_Dt.r_line 								;
AND Claim_Dt.Status  = 3 							;
AND Claim_Dt.Program = Program.Prog_Id				;
&cWherePrg						;
AND Claim_dt.Enc_site=cCSite 						;
AND Claim_dt.Amt_Paid <> 0							;
GROUP BY ;
	3, 5, 6 ;
INTO CURSOR tPaid 												

If Used('Program')
	Use in program
Endif
	
* now, combine all selects into one detail cursor, order by program description and claim type			
SELECT * FROM tBilled ;
UNION ALL ;
SELECT * FROM tReBilled ;
UNION ALL ;
SELECT * FROM tPended ;
UNION ALL ;
SELECT * FROM tDenyReb ;
UNION ALL ;
SELECT * FROM tDenyNev ;
UNION ALL ;
SELECT * FROM tDenyNA ;
UNION ALL ;
SELECT * FROM tAdjust ;
UNION ALL ;
SELECT * FROM tVoided ;
UNION ALL ;
SELECT * FROM tPaid  ;
INTO CURSOR ;
	tFinal ;
ORDER BY ;
	2, 3, 6 DESC		&& Program Description, Claim Type (defined herein), claim date

Select ;
   tFinal.*, ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
From tFinal ;
Into Cursor ;
   tFinal2 ;
ORDER BY ;
   2, 3, 6 DESC      && Program Description, Claim Type (defined herein), claim date
   
* close some cursors
IF USED('tBilled')
	USE IN tBilled
ENDIF	

IF USED('tReBilled')
	USE IN tReBilled
ENDIF	

IF USED('tPended')
	USE IN tPended
ENDIF	

IF USED('tDenyReb')
	USE IN tDenyReb
ENDIF	

IF USED('tDenyNev')
	USE IN tDenyNev
ENDIF	

IF USED('tDenyNA')
	USE IN tDenyNA
ENDIF	

IF USED('tPaid')
	USE IN tPaid
ENDIF	

IF USED('tVoided')
	USE IN tVoided
ENDIF	

IF USED('tAdjust')
	USE IN tAdjust
ENDIF	

IF _TALLY = 0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF

oApp.msg2user('OFF')

cReportSelection = .agroup(nGroup)

gcRptName = 'rpt_revdet'
Do Case
CASE lPrev = .f.
   Report Form rpt_revdet To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_revdet', 1, 2)
EndCase

USE IN tFinal
RETURN

*****************
PROCEDURE getprob
*****************
PARAMETER parmtopass
IF ASCAN(cProbArray,'HOLDSITE') <> 0 OR ;
   ASCAN(cProbArray,'HOLDACTI') <> 0 OR ;
   ASCAN(cProbArray,'HOLDPROG') <> 0 OR ;
   ASCAN(cProbArray,'AI_ACTDT') <> 0 OR ;
   ASCAN(cProbArray,'AI_SITED') <> 0 OR ;
   ASCAN(cProbArray,'HIVDATE')  <> 0 OR ;
   ASCAN(cProbArray,'TBDATE')   <> 0 
	ParmToPass= ParmtoPass + CHR(13) + ' - Main AI Aggregate' + CHR(13) + ' - Age by Sex by Ethnicity'
ELSE
 * to avoid duplicating "Age by Sex...", only check this if above stuff OK
   IF ASCAN(cProbArray,'DOBDATE') <> 0 
	   ParmToPass= ParmToPass + CHR(13) + ' - Age by Sex by Ethnicity'
   ENDIF
ENDIF
IF ASCAN(cProbArray,'REFDATE') <> 0 OR ;
   ASCAN(cProbArray,'REFSRC3') <> 0 OR ;
   ASCAN(cProbArray,'REFSRC4') <> 0 
	ParmToPass= ParmtoPass + CHR(13) + ' - Summary of Referrals'
ENDIF
IF ASCAN(cProbArray,'ENCDATE') <> 0 OR ;
   ASCAN(cProbArray,'SRVDATE') <> 0 
	ParmToPass= ParmtoPass + CHR(13) + ' - Encounters by Service Type-Total/Anonymous' + CHR(13) + ' - Encounters by Contract, Service Type-Total/Anonymous'
ELSE
 * to avoid duplicating "Encounters by Contract...", only check this if above stuff OK
   IF ASCAN(cProbArray,'ENCWORK1') <> 0 OR ;
      ASCAN(cProbArray,'ENCWORK2') <> 0 OR ;
      ASCAN(cProbArray,'SRVWORK1') <> 0 OR ;
      ASCAN(cProbArray,'SRVWORK2') <> 0 
	   ParmToPass= ParmToPass + CHR(13) + ' - Encounters by Contract, Service Type-Total/Anonymous'
   ENDIF
ENDIF
	
RETURN  
***
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


*******************
Procedure Rpt_AiRef
*******************
IF gcState='CT'
   DO rpt_refct
   RETURN
ENDIF

**VT 03/05/2007
*!*   IF USED('ref_cur')
*!*      USE IN ref_cur
*!*   ENDIF   

IF USED('tHold1')
   USE IN tHold1
ENDIF

SELECT DIST ;
   tc_id, Anonymous ;
FROM ; 
   Hold1 ;
INTO CURSOR ;
   tHold1 

***VT 03/05/2007
IF _tally = 0
   oApp.msg2user("NOTFOUNDG")
   USE IN tHold1
   return .f.
ENDIF
****************************************************

* jss, 10/13/00, add code to filter on lcprog

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(ai_enc.program, "  + lcprog + ")" )
*ai_enc.program = lcprog ;

SELECT ;
   program.descript AS program,;
   SPACE(50) AS Category,;
   SPACE(45) AS Service,;
   SPACE(30) AS refstatus,;
   0000 AS SrvStatCnt,;
   0000 AS CliCount,;
   ai_enc.program AS prog_id,;
   ai_ref.tc_id,;
   ai_ref.ref_cat,;
   ai_ref.status,; 
   ai_ref.ref_for;   
FROM ;
   tHold1, ai_ref, ai_enc, program ;
WHERE ;
   !Empty(ai_enc.act_id) And ;
   tHold1.tc_id = ai_ref.tc_id AND ;
   ai_ref.ref_dt BETWEEN m.Date_From AND m.Date_To AND ;
   ai_enc.act_id = ai_ref.act_id AND ;
   ai_enc.program = program.prog_id ;
   &cWherePrg ;
INTO CURSOR tAllRef1a   

* jss, 7/8/04, add next select to handle referrals made from syringe exchange screen [no encounter (ai_enc) recs here]
* jss, 7/9/04, use need_id to get unique recs from ai_ref for syringe exchange referrals

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(needlx.program, "  + lcprog + ")" )
* needlx.program = lcprog ;

SELECT ;
   program.descript AS program,;
   SPACE(50) AS Category,;
   SPACE(45) AS Service,;
   SPACE(30) AS refstatus,;
   0000 AS SrvStatCnt,;
   0000 AS CliCount,;
   needlx.program AS prog_id,;
   ai_ref.tc_id,;
   ai_ref.ref_cat,; 
   ai_ref.status,;   
   ai_ref.ref_for;   
FROM ;
   tHold1, ai_ref, needlx, program ;
WHERE ;
   tHold1.tc_id   = ai_ref.tc_id AND ;
   ai_ref.ref_dt BETWEEN m.Date_From AND m.Date_To AND ;
   EMPTY(ai_ref.act_id) AND ;
   needlx.need_id = ai_ref.need_id AND ;
   needlx.tc_id = ai_ref.tc_id AND ;
   needlx.program = program.prog_id  ;
   &cWherePrg ;
INTO CURSOR tAllRef1b

**VT 03/21/2008  Dev Tick 4096 Program from CTR Part B when  no act _id
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(ai_ctr.program, "  + lcprog + ")" )

*!* PB 05/2013 
*!*   SELECT ;
*!*      program.descript AS program,;
*!*      SPACE(50) AS Category,;
*!*      SPACE(45) AS Service,;
*!*      SPACE(30) AS refstatus,;
*!*      0000 AS SrvStatCnt,;
*!*      0000 AS CliCount,;
*!*      ai_ctr.program AS prog_id,;
*!*      ai_ref.tc_id,;
*!*      ai_ref.ref_cat,; 
*!*      ai_ref.status,;   
*!*      ai_ref.ref_for;   
*!*   FROM ;
*!*      tHold1, ai_ref, ctr_test, ai_ctr, program ;
*!*   WHERE ;
*!*      tHold1.tc_id = ai_ref.tc_id AND ;
*!*      Between(ai_ref.ref_dt,m.Date_From,m.Date_To) AND ;
*!*      EMPTY(ai_ref.act_id) AND ;
*!*      EMPTY(ctr_test.act_id) AND ;
*!*      EMPTY(ctr_test.program_id) AND ;
*!*      ctr_test.ctr_id = ai_ctr.ctr_id And ;
*!*      ctr_test.ctrtest_id = ai_ref.ctrtest_id AND ;
*!*      ai_ctr.tc_id = ai_ref.tc_id AND ;
*!*      ai_ctr.program = program.prog_id  ;
*!*      &cWherePrg ;
*!*   INTO CURSOR tAllRefCTR

SELECT ;
   program.descript AS program,;
   SPACE(50) AS Category,;
   SPACE(45) AS Service,;
   SPACE(30) AS refstatus,;
   0000 AS SrvStatCnt,;
   0000 AS CliCount,;
   ai_ctr.program AS prog_id,;
   ai_ref.tc_id,;
   ai_ref.ref_cat,;
   ai_ref.status,;
   ai_ref.ref_for;
FROM ;
   tHold1, ai_ref, ctr_test, ai_ctr, program ;
WHERE ;
   tHold1.tc_id = ai_ref.tc_id And;
   Between(ai_ref.ref_dt,m.Date_From,m.Date_To) And;
   EMPTY(ai_ref.act_id) And;
   EMPTY(ctr_test.act_id) And;
   ctr_test.ctr_id = ai_ctr.ctr_id And;
   ctr_test.ctrtest_id = ai_ref.ctrtest_id And;
   ai_ctr.tc_id = ai_ref.tc_id And;
   ai_ctr.program = program.prog_id;
   &cWherePrg ;
INTO CURSOR tAllRefCTR

*!* Add HCV Rapid testing
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(ai_hcv_rapid_testing.prog_id, "  + lcprog + ")" )

Select Nvl(program.descript,Padr('†Program Unknown',30,' ')) As program,;
       Space(50) As Category,;
       Space(45) As Service,;
       Space(30) As refstatus,;
       0000 As SrvStatCnt,;
       0000 As CliCount,;
       ai_hcv_rapid_testing.prog_id,;
       ai_ref.tc_id,;
       ai_ref.ref_cat,;
       ai_ref.status,;
       ai_ref.ref_for;
From ai_ref;
Join ai_hcv_rapid_testing On ai_hcv_rapid_testing.hcv_rapidid= ai_ref.hcv_rapidid;
Left Join program On ai_hcv_rapid_testing.prog_id = Program.prog_id;
Join tHold1 On tHold1.tc_id=ai_ref.tc_id;
Where !Empty(ai_ref.hcv_rapidid) And;
      Between(ai_ref.ref_dt, m.Date_From, m.Date_To) And;
      Empty(ai_ref.act_id);
      &cWherePrg;
Into Cursor _curHCV

**VT 01/08/2008
cWherePrg=''

* jss, 7/8/04, combine them
**VT 03/21/2008  Dev Tick 4096 add tAllRefCTR

SELECT * FROM tAllRef1a ;
UNION ALL ;
SELECT * FROM tAllRef1b ;
Union All ;
Select * From tAllRefCTR ;
Union All ;
Select * From _curHCV ;
INTO CURSOR tAllRef1


**VT 03/21/2008
Use In tAllRef1a
Use In tAllRef1b
Use In tAllRefCTR  
Use In _curHCV

* jss, 7/8/04, add 'AND Empty(ai_ref.need_id)' into query below to handle referrals from syringe exchange screen

**VT 03/21/2008 add  And  Empty(ctr_id) And Empty(ctrtest_id)  Dev Tick 4096

IF EMPTY(lcprog)
   SELECT * FROM tAllRef1   ;
   UNION ALL  ;
   SELECT ;
      "†Program Unknown" AS program,;
      SPACE(50) AS Category,;
      SPACE(45) AS Service,;
      SPACE(30) AS refstatus,;
      0000 AS SrvStatCnt,;
      0000 AS CliCount,;
      SPACE(5) AS prog_id,;
      ai_ref.tc_id,;
      ai_ref.ref_cat,; 
      ai_ref.status,;   
      ai_ref.ref_for;   
   FROM ;
      tHold1, ai_ref ;
   WHERE ;
      tHold1.tc_id   = ai_ref.tc_id AND ;
      ai_ref.ref_dt BETWEEN m.Date_From AND m.Date_To AND ;
      Empty(ai_ref.act_id) ;
      AND Empty(ai_ref.need_id) ;
      And Empty(ctr_id) ;
      And Empty(ctrtest_id) ;
      And Empty(hcv_rapidid) ;
   INTO CURSOR ;
      tRef readwrite
ELSE
   SELECT * FROM tAllRef1 INTO CURSOR tRef readwrite
ENDIF

***VT 03/05/2007
*!*   IF _tally = 0
*!*      oApp.msg2user("NOTFOUNDG")
*!*      USE IN tHold1
*!*      return .f.
*!*   ENDIF

* open lookup tables and set appropriate relationships
SELE 0
=OpenFile('ref_cat','code')
SELE 0
=OpenFile('ref_stat','code')
SELE 0
=OpenFile('ref_for','catcode')
*=ReOpenCur("tAllRef", "tRef")
Select tRef
SET RELAT TO ref_cat INTO ref_cat
SET RELAT TO status INTO ref_stat addi
SET RELAT TO ref_cat+ref_for INTO ref_for  addi
REPLACE ALL category WITH IIF(FOUND('ref_cat'),  ref_cat.descript,  '~Category Not Reported'), ;
            refstatus WITH IIF(FOUND('ref_stat'), ref_stat.descript, '~Status Not Reported'), ;
            service WITH IIF(FOUND('ref_for'),  ref_for.descript,  '~Service Not Reported')


* count referrals by program+category+service+refstatus: this yields detail info of report
IF USED('ref_cur')
   USE IN ref_cur
Endif

SELECT ;
   program    ,;
   Category   ,;
   Service    ,;
   refstatus  ,;
   prog_id    ,;
   COUNT(*)          AS SrvStatCnt ,;
   COUNT(DIST tc_id) AS CliCount,    ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
FROM ;
   tRef ;
GROUP BY ;
   1, 2, 3, 4 ;
INTO CURSOR ;
   Ref_Cur
   
****************************************************

* count distinct tc_ids by program+category
SELECT ;
   prog_id ,;
   category ,;
   COUNT(DISTINCT tc_id) AS CliCount;
FROM ;
   tRef ;
GROUP BY ;
   1, 2 ;
INTO CURSOR ;
   cattotal
   
INDEX ON prog_id+category TAG progcat

SELECT ref_cur
SET RELATION TO prog_id + category INTO cattotal
   
SELECT ;
   prog_id ,;
   COUNT(DISTINCT tc_id) AS CliCount;
FROM ;
   tRef ;
GROUP BY ;
   1;
INTO CURSOR ;
   prgtotal
   
INDEX ON prog_id TAG prog

SELECT ref_cur
SET RELATION TO prog_id INTO prgtotal ADDI
   
oApp.Msg2User('OFF')

cReportSelection = .agroup(nGroup)

gcRptName = 'rpt_airef'
oApp.msg2user("OFF")

**VT 03/05/2007
Select ref_cur
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else

      Do Case
      CASE lPrev = .f.
         Report Form rpt_airef To Printer Prompt Noconsole NODIALOG 
      CASE lPrev = .t.     &&Preview
         oApp.rpt_print(5, .t., 1, 'rpt_airef', 1, 2)
      EndCase
Endif

* close cursors
*USE IN ref_cur
*USE IN cattotal
*USE IN prgtotal
IF USED('tAllRef1a')
   USE IN tAllRef1a
ENDIF
IF USED('tAllRef1b')
   USE IN tAllRef1b
ENDIF
IF USED('tAllRef1')
   USE IN tAllRef1
ENDIF
IF USED('tAllRef')
   USE IN tAllRef
ENDIF
IF USED('tRef')
   USE IN tRef
ENDIF

* close dbfs 
USE IN ai_ref
USE IN ref_cat
USE IN ref_for
USE IN ref_stat
USE IN ai_enc
USE IN program
IF USED('needlx')
   USE IN needlx
ENDIF

*******************
Procedure Rpt_AiEnc
*******************
*** VT 06/05 2007

*!*   DO CASE
*!*    CASE nGroup = 1 && Ryan White Eligible
*!*       lcExpr = " AND Aar_Report"
*!*    CASE nGroup = 2 && HIV Counseling/Prevention Eligible
*!*       lcExpr = " AND Ctp_Elig"    
*!*    CASE nGroup = 3 && Ryan White and HIV Counseling/Prevention Eligible
*!*       lcExpr = " AND (Aar_Report OR Ctp_Elig)"    
*!*    CASE nGroup = 4 && All Clients
*!*       lcExpr = ""   
*!*   ENDCASE

DO CASE
    CASE nGroup = 1 && All Clients
       lcExpr = ""   
    CASE nGroup = 2 && Ryan White Eligible
       lcExpr = " AND Aar_Report"
    CASE nGroup = 3 && HIV Counseling/Prevention Eligible
       lcExpr = " AND Ctp_Elig"    
    CASE nGroup = 4 && Ryan White and HIV Counseling/Prevention Eligible
       lcExpr = " AND (Aar_Report OR Ctp_Elig)"    
Endcase

***VT End

* jss, add next line so we can relate into program file to get field enr_req
SELECT descript AS program, enr_req FROM program INTO CURSOR progdesc
INDEX ON Program TAG Program

* create a list of clients that correspond to report selection
*!*   SELECT ;
*!*      a.*, ;
*!*      c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
*!*   FROM ;
*!*      ai_clien A, Ai_Prog B, Program C ;
*!*   WHERE ;
*!*      a.Tc_ID = b.Tc_ID ;
*!*      AND b.Program = c.Prog_ID ;
*!*      AND b.Start_Dt <= m.Date_To ;
*!*      &lcExpr ;
*!*   UNION ;
*!*   SELECT ;
*!*      a.*, ;
*!*      c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
*!*   FROM ;
*!*      ai_clien A, Program C ;
*!*   WHERE ;
*!*      a.Int_Prog = c.Prog_ID ;
*!*      AND a.Placed_Dt <= m.Date_To ;
*!*      &lcExpr ;      
*!*   INTO CURSOR ;
*!*      enc_client

* jss, 12/5/06, only grab tc_id and anonymous columns from ai_clien (can't union memo fields)
SELECT ;
   a.tc_id, a.anonymous, ;
   c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
   ai_clien A, Ai_Prog B, Program C ;
WHERE ;
   a.Tc_ID = b.Tc_ID ;
   AND b.Program = c.Prog_ID ;
   AND b.Start_Dt <= m.Date_To ;
   &lcExpr ;
UNION ;
SELECT ;
   a.tc_id, a.anonymous, ;
   c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
FROM ;
   ai_clien A, Program C ;
WHERE ;
   a.Int_Prog = c.Prog_ID ;
   AND a.Placed_Dt <= m.Date_To ;
   &lcExpr ;      
INTO CURSOR ;
   enc_client

* select all encounter data within date range 
*!*   SELECT DISTINCT Ai_Enc.Tc_ID, ;
*!*          Ai_Enc.Act_ID, ;
*!*         Ai_Enc.Enc_type   AS Enc_Code, ;
*!*         Ai_Enc.Serv_Cat   AS Serv_CCode, ;
*!*          Ai_Enc.Program    AS Prog_Id, ;
*!*          Program.Descript  AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          enc_client.Anonymous , ;
*!*          Ai_Enc.Act_dt     AS Act_dt ;
*!*     FROM enc_client, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_Type ;
*!*    WHERE Ai_Enc.Tc_ID    = enc_client.Tc_ID ;
*!*      AND Ai_Enc.Program  = lcProg ;
*!*      AND Ai_Enc.site     = cCSite ;
*!*      AND Ai_Enc.Program  = Program.Prog_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    INTO CURSOR tEncCur1

***VT 06/04/2007 change ai_enc.enc_type to enc_id

* 12/5/06, lookup encounter description in enc_list using ai_enc.enc_id
*!*   SELECT DISTINCT Ai_Enc.Tc_ID, ;
*!*          Ai_Enc.Act_ID, ;
*!*         Ai_Enc.Enc_type   AS Enc_Code, ;
*!*         Ai_Enc.Serv_Cat   AS Serv_CCode, ;
*!*          Ai_Enc.Program    AS Prog_Id, ;
*!*          Program.Descript  AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*          Enc_list.Description AS Enc_type, ;
*!*          enc_client.Anonymous , ;
*!*          Ai_Enc.Act_dt     AS Act_dt ;
*!*     FROM enc_client, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_list ;
*!*    WHERE Ai_Enc.Tc_ID    = enc_client.Tc_ID ;
*!*      AND Ai_Enc.Program  = lcProg ;
*!*      AND Ai_Enc.site     = cCSite ;
*!*      AND Ai_Enc.Program  = Program.Prog_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.enc_id = enc_list.enc_id ;
*!*      AND Ai_Enc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    INTO CURSOR tEncCur1

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " and Inlist(ai_enc.program, "  + lcprog + ")" )
* And ai_enc.program = lcprog ;

SELECT DISTINCT Ai_Enc.Tc_ID, ;
       Ai_Enc.Act_ID, ;
       Ai_Enc.Enc_id AS Enc_Code, ;
       Ai_Enc.Serv_Cat AS Serv_CCode, ;
       Ai_Enc.Program AS Prog_Id, ;
       Program.Descript AS Program, ;
       Padr(Serv_Cat.Descript,40,' ') AS Serv_Cat, ;
       Serv_Cat.Descript As scDescript,;
       Enc_list.Description AS Enc_type, ;
       enc_client.Anonymous , ;
       Ai_Enc.Act_dt AS Act_dt ;
  FROM enc_client, ;
       Ai_Enc, ;
       Program, ;
       Serv_Cat, ;
       Enc_list ;
 WHERE Ai_Enc.Tc_ID = enc_client.Tc_ID ;
   &cWherePrg ;
   AND Ai_Enc.site=cCSite ;
   AND Ai_Enc.Program=Program.Prog_ID ;
   AND Ai_Enc.Serv_Cat=Serv_Cat.Code ;
   AND Ai_Enc.enc_id=enc_list.enc_id ;
   AND Ai_Enc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
 INTO CURSOR tEncCur1
 
 cWherePrg =''
 
 ***VT End
******************************************************************
* jss, 9/98, must count enrolled vs. not enrolled in program, too
******************************************************************
* first, get those that were enrolled at time of service
SELECT tEncCur1.*, ;
       .t. AS Enrolled ;
FROM tEncCur1, Ai_Prog ;
WHERE tEncCur1.tc_id = Ai_prog.tc_id ;
  AND tEncCur1.prog_id = Ai_prog.program ;
  AND tEncCur1.act_dt  >= Ai_prog.start_dt ;
  AND (tEncCur1.act_dt <= Ai_prog.end_dt OR EMPTY(Ai_Prog.end_dt));
INTO CURSOR tEncCur2

* jss, 9/6/2000, next cursor grabs any encounter where client was not enrolled at time of
*                service, but this client already had at least one enrolled encounter this period,
*                so we also count these encounters as enrolled

SELECT tEncCur1.* ,;
       .t. AS Enrolled ;
FROM tEncCur1 ;
WHERE act_id NOT IN(SELECT act_id FROM tEncCur2) ;
  AND tc_id + prog_id IN (SELECT tc_id + prog_id  FROM tEncCur2) ;
INTO CURSOR;
      tEncCur3

* everything else is considered not enrolled
SELECT tEncCur1.*, ;
      .f. AS Enrolled ;
FROM tEncCur1 ;
WHERE tc_id + act_id NOT IN (SELECT tc_id + act_id FROM tEncCur2) ;
  AND tc_id + act_id NOT IN (SELECT tc_id + act_id FROM tEncCur3) ;
INTO CURSOR ;
      tEncCur4

* now combine those that    1) are currently enrolled (tEncCur2) 
*                     2) were enrolled at some time in period (tEncCur3)
*                     3) were never enrolled in program during this period (tEncCur4) 

SELECT * ;
FROM tEncCur2 ;
UNION ;
SELECT * ;
FROM tEncCur3 ;
UNION ;
SELECT * ;
FROM tEncCur4 ;
INTO CURSOR ;
     EncSer_Cur

* jss, 9/98 create next cursor to count distinct enrolled and unenrolled clients at low level (Program+Serv_cat+enc_type)
SELECT DISTINCT ;
     Program  ,;
     Serv_cat ,;
     Enc_type ,;
     Tc_id    ,;
     Enrolled ,;
     Anonymous, ;
     scDescript;
FROM EncSer_cur ;
INTO CURSOR tProSerEnc

* now count the enrolled/not enrolled for program+serv_cat+enc_type
SELECT Program  ,;
      Serv_cat ,;
      Enc_type ,;
      SUM(IIF(enrolled,1,0))                   AS PSE_Enr   ,;
      SUM(IIF(enrolled,0,1))                   AS PSE_NEnr  ,;
      SUM(IIF(anonymous AND enrolled,1,0))     AS PSE_AnEnr ,;
      SUM(IIF(anonymous AND NOT enrolled,1,0)) AS PSE_AnNEnr, ;
      scDescript;
FROM tProSerEnc ;
INTO CURSOR ProSerEnc ;
GROUP BY 1, 2, 3

INDEX ON Program + Serv_Cat + Enc_Type TAG ProSerEnc
SET ORDER TO ProSerEnc

* jss, 9/98 create next cursor to count distinct enrolled and unenrolled clients at next higher level (Program+Serv_cat)
SELECT DISTINCT ;
     Program,;
     Serv_cat,;
     Tc_id,;
     Enrolled,;
     Anonymous,;
     scDescript;
FROM EncSer_cur ;
INTO CURSOR tProgServ
* now count the enrolled/not enrolled for program+serv_cat

SELECT ;
     Program  ,;
     Serv_cat ,;
     SUM(IIF(enrolled,1,0))                   AS PS_Enr   ,;
     SUM(IIF(enrolled,0,1))                   AS PS_NEnr  ,;
     SUM(IIF(anonymous AND enrolled,1,0))     AS PS_AnEnr ,;
     SUM(IIF(anonymous AND NOT enrolled,1,0)) AS PS_AnNEnr,;
     scDescript;
FROM tProgServ     ;      
INTO CURSOR ProgServ ;
GROUP BY 1, 2

INDEX ON Program + Serv_Cat TAG ProgServ
SET ORDER TO ProgServ

* jss, 9/98 create next cursor to count distinct enrolled and unenrolled clients at highest level (Program)
SELECT DISTINCT    ;
      Program   ,;
      Tc_id     ,;
      Enrolled  ,;
      Anonymous  ;
FROM EncSer_cur ;
INTO CURSOR tProg
* now count the enrolled/not enrolled for program
SELECT ;
      Program,;
      SUM(IIF(enrolled,1,0))                   AS P_Enr  , ;
      SUM(IIF(enrolled,0,1))                   AS P_NEnr , ;
      SUM(IIF(anonymous AND enrolled,1,0))     AS P_AnEnr, ;
      SUM(IIF(anonymous AND NOT enrolled,1,0)) AS P_AnNEnr ;
FROM tProg     ;      
INTO CURSOR Prog ;
GROUP BY 1

INDEX ON Program TAG Prog
SET ORDER TO Prog

***************************************************************

* calculate number of services and clients within a service
* for anonymous clients
* jss, 9/1/2000: for "No Services Recorded", do not count the record as a service; make it zero
* jss, 4/10/03: sum ai_serv value for report
* jss, 9/15/06, ai_serv.value is now ai_serv.s_value

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
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
*!*    GROUP BY 1, 2, 3, 4 ;
*!*   UNION ALL ;
*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*          "No Services Recorded" AS Service, ;
*!*         "ZZZZ" AS ServCode, ;
*!*          0 AS NumbServAn, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
*!*          0.00 AS NumValueAn, ;
*!*          0 AS NumbItemAn ;
*!*     FROM EncSer_Cur ;
*!*    WHERE EncSer_Cur.Anonymous=.T. ;
*!*      AND EncSer_Cur.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR EncServAn

* jss, 12/5/06, use ai_serv.service_id to lookup service description in serv_list
*               also, remove servcode line from top of union:       Service.Code AS ServCode
*               also, remove servcode line from bottom of union:       "ZZZZ" AS ServCode

SELECT EncSer_Cur.Program, ;
   EncSer_Cur.Serv_Cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description  AS Service, ;
   COUNT(*) AS NumbServAn, ;
   COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
   SUM(Ai_Serv.s_value) AS NumValueAn, ;
   SUM(Ai_Serv.NumItems) AS NumbItemAn;
FROM EncSer_Cur, ;
     Ai_Serv, ;
     Serv_list ;
WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   And ai_serv.service_id = serv_list.service_id ;
   AND EncSer_Cur.Anonymous = .T. ;
 GROUP BY 1, 2, 3, 4 ;
UNION ALL ;
SELECT EncSer_Cur.Program, ;
    EncSer_Cur.Serv_Cat, ;
    EncSer_Cur.Enc_type, ;
    Padr("Z - No Services Recorded",80) AS Service, ;
    0 AS NumbServAn, ;
    COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
    0.00 AS NumValueAn, ;
    0 AS NumbItemAn ;
FROM EncSer_Cur ;
WHERE EncSer_Cur.Anonymous=.T. ;
   AND EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3, 4 ;
 INTO CURSOR EncServAn

* adding the alias changes what doesn't match
*INDEX ON Program + Serv_Cat + Enc_Type + ServCode TAG ProgEnc
* jss, 12/5/06, use service instead of servcode for index
INDEX ON Program + Serv_Cat + Enc_Type + Service TAG ProgEnc
SET ORDER TO ProgEnc

***************************************************************
* 12/99, jss, calculate number of items within a service
* for all clients
* jss, 9/1/2000: for "No Services Recorded", do not count the record as a service; make it zero
* jss, 4/10/03: sum ai_serv value for report

**VT 11/01/2006
**Cast(SUM(Ai_Serv.s_Value) as N(10.2)) AS NumValue, ;
***Cast(0 As N(10.2)) AS NumValue, ;

Set Decimals to 2

** jss, 12/5/06, remove servcode lines below:      Service.Code AS ServCode....      "ZZZZ" AS ServCode

SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description AS Service, ;
      COUNT(*) AS NumbServ, ;
      COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumClients, ;
      SUM(Ai_Serv.s_Value)  AS NumValue, ;
      SUM(Ai_Serv.NumItems) AS NumbItem ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   and ai_serv.service_id = serv_list.service_id ;
 GROUP BY 1, 2, 3, 4 ;
UNION ALL ;
SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Padr("Z - No Services Recorded",80) AS Service, ;
      0 AS NumbServ, ;
      COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumClients, ;
      0.00 AS NumValue, ;
      0 AS NumbItem ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3, 4 ;
 INTO CURSOR EncServ

*INDEX ON Program + Serv_Cat + Enc_Type + ServCode TAG ProgEnc
* jss, 12/5/06, use service instead of servcode for index
INDEX ON Program + Serv_Cat + Enc_Type + Service TAG ProgEnc
SET ORDER TO ProgEnc
SET RELATION TO Program + Serv_Cat + Enc_Type + Service INTO EncServAn

**VT 11/01/2006
Set Decimals to

*************************
* jss, 3/10/03, add selects below to calculate counts for topics associated with services
*************************
* this select grabs topic count for anonymous for Program+Serv_Cat+Enc_type+Service where serv_id OR att_id is link to topic
* jss, 12/5/06, remove servcode lines below:      Service.Code AS ServCode

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
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
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ;
*!*       tTopAn1

* jss, 12/5/06, use serv_list.description
SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       COUNT(*) AS NumbTopAn ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list, ;
       Ai_topic, ;
       Topics ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.Service_id ;
   AND EncSer_Cur.Anonymous = .T. ;
   AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
   AND Ai_Topic.code     = Topics.Code ;
   AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
         OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
 GROUP BY 1, 2, 3, 4 ;
 INTO CURSOR ;
    tTopAn1

* next 2 selects will create a zero count record for anonymous for all Program+Serv_Cat+Enc_type+Service combos with no associated topics
* jss, 12/5/06, remove servcode lines below:      Service.Code AS ServCode

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          0000000000 AS NumbTopAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4 ; 
*!*    INTO CURSOR tTopAn1a

SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       0000000000 AS NumbTopAn ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.service_id ;
   AND EncSer_Cur.Anonymous = .T. ;
 GROUP BY 1, 2, 3, 4 ; 
 INTO CURSOR tTopAn1a

SELECT * ;
FROM tTopAn1a ;
WHERE Program+Serv_Cat+Enc_type+Service ;
   NOT IN (SELECT Program+Serv_Cat+Enc_type+Service FROM tTopAn1) ;
INTO CURSOR tTopAn2

* next cursor sets topic count to zero for anonymous for Program+Serv_Cat+Enc_type+Service combos for "no services recorded"
* jss, 12/5/06, remove servcode lines below:      "ZZZZ" AS ServCode

SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
       PADR("Z - No Services Recorded",80) AS Service, ;
       0000000000 AS NumbTopAn ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Anonymous=.T. ;
   AND EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3, 4 ;
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
INDEX ON Program + Serv_Cat + Enc_Type + Service TAG ProgEnc
SET ORDER TO ProgEnc

SELECT EncServAn
SET RELATION TO Program + Serv_Cat + Enc_Type + Service INTO ServTopAn ADDI

* this select grabs topic count for Program+Serv_Cat+Enc_type+Service where serv_id OR att_id is link to topic
*       Service.Code AS ServCode

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
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
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ;
*!*       tTop1

SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
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
 GROUP BY 1, 2, 3, 4 ;
 INTO CURSOR ;
    tTop1

* next 2 selects set topic count to zero for Program+Serv_Cat+Enc_type+Service combos with no associated topics
*       Service.Code AS ServCode

*!*    SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          0000000000 AS NumbTop ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*    GROUP BY 1, 2, 3, 4 ; 
*!*    INTO CURSOR tTop1a

 SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
      Serv_list.Description  AS Service, ;
       0000000000 AS NumbTop ;
  FROM EncSer_Cur, ;
       Ai_Serv, ;
       Serv_list ;
 WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
   AND Ai_Serv.Service_id = Serv_list.service_id ;
 GROUP BY 1, 2, 3, 4 ; 
 INTO CURSOR tTop1a

SELECT * ;
FROM tTop1a ;
WHERE Program+Serv_Cat+Enc_type+Service ;
   NOT IN (SELECT Program+Serv_Cat+Enc_type+Service FROM tTop1) ;
INTO CURSOR tTop2

* next cursor sets topic count to zero for Program+Serv_Cat+Enc_type+Service combos for "no services recorded"
*       "ZZZZ" AS ServCode
SELECT EncSer_Cur.Program, ;
      EncSer_Cur.Serv_Cat, ;
      EncSer_Cur.Enc_type, ;
       PADR("Z - No Services Recorded",80) AS Service, ;
       0000000000 AS NumbTop ;
  FROM EncSer_Cur ;
 WHERE EncSer_Cur.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3, 4 ;
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
INDEX ON Program + Serv_Cat + Enc_Type + Service TAG ProgEnc
SET ORDER TO ProgEnc

SELECT EncServ
SET RELATION TO Program + Serv_Cat + Enc_Type + Service INTO ServTop ADDI
***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for anonymous clients

SELECT Program, ;
    Serv_Cat, ;   
    Enc_type, ;
    COUNT(act_id) AS AnonEnctrs, ;
    COUNT(DISTINCT tc_id) AS AnonCliSvd ;
FROM EncSer_Cur ;
WHERE Anonymous = .T. ;
GROUP BY 1, 2, 3 ;
INTO CURSOR ProgEncAn

INDEX ON Program + Serv_Cat + Enc_type TAG ProgEnc
SET ORDER TO ProgEnc

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for all clients

SELECT ;
  Program, ;
  Serv_Cat, ;   
  Enc_type, ;
  scDescript,;
  COUNT(act_id) AS NumbEnctrs, ;
  COUNT(DISTINCT tc_id) AS EncCliSvd ;
FROM EncSer_Cur ;
GROUP BY 1, 2, 3, 4 ;
ORDER BY 1, 2, 3 ;
INTO CURSOR ProgEnc1

cReportSelection=.aGroup(nGroup)

Select ProgEnc1.* , ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
From ProgEnc1 ;
Into Cursor ProgEnc


***************************************************************
* calculate number of encounters and
* number of clients served within service category for all clients

SELECT Program, ;
      Serv_Cat, ;   
      COUNT(act_id) AS Sum_SrvEnc, ;
      COUNT(DISTINCT tc_id) AS Sum_SrvCli ;
FROM EncSer_Cur ;
GROUP BY 1, 2 ;
INTO CURSOR ServCTot

INDEX ON Program + Serv_Cat TAG Serv_Cat

***************************************************************
* calculate number of encounters and
* number of clients served within service category for anonymous clients

SELECT Program, ;
      Serv_Cat, ;   
      COUNT(act_id) AS SumSrvEncA, ;
      COUNT(DISTINCT tc_id) AS SumSrvCliA ;
FROM EncSer_Cur ;
WHERE Anonymous = .T. ;
GROUP BY 1, 2 ;
ORDER BY 1, 2 ;
INTO CURSOR ServCTotAn

INDEX ON Program + Serv_Cat TAG Serv_Cat

***************************************************************
* calculate number of encounters and
* number of clients served within program for all clients

SELECT Program, ;
       COUNT(act_id)         AS Sum_Enc, ;
       COUNT(DISTINCT tc_id) AS Sum_Cli ;
  FROM EncSer_Cur ;
 GROUP BY 1 ;
 INTO CURSOR Prog_Tot
   
INDEX ON Program TAG Program

***************************************************************
* calculate number of encounters and
* number of clients served within program for anonymous clients

SELECT Program, ;
      COUNT(act_id) AS Sum_Enc, ;
      COUNT(DISTINCT tc_id) AS Sum_Cli ;
  FROM EncSer_Cur ;
 WHERE Anonymous = .T. ;
 GROUP BY 1 ;
  INTO CURSOR Prog_TotAn
   
INDEX ON Program TAG program

* jss, 7/12/01, add cursor progdesc to set relation below
*****   
SELECT Progenc
SET RELATION TO Program + Serv_Cat + Enc_Type INTO EncServ, ;
                Program + Serv_Cat + Enc_Type INTO ProgEncAn, ;
                Program + Serv_Cat + Enc_Type INTO ProSerEnc, ;
                Program + Serv_Cat INTO ServCTot, ;
                Program + Serv_Cat INTO ServCTotAn, ;          
                Program + Serv_Cat INTO ProgServ, ;
                Program INTO Prog_Tot, ;
                Program INTO Prog_TotAn, ;
                Program INTO Prog, ;
                Program INTO ProgDesc

                
SET SKIP TO EncServ

oApp.Msg2User('OFF')

* jss, 4/28/2000, add 'Info Not Found' message
IF EOF('PROGENC')
   oApp.Msg2User('NOTFOUNDG')
   RETURN .f.
ENDIF   

gcRptName = 'rpt_aienc'
Do Case
CASE lPrev = .f.
   Report Form rpt_aienc To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_aienc', 1, 2)
EndCase

Return

*******************
Procedure Rpt_CnEnc
*******************

* jss, 12/5/06, as in Rpt_AiEnc above, we will now use enc_list.description for enc_type and serv_list.description for service
IF USED('tHold1')
   USE IN tHold1
ENDIF   

SELECT DIST tc_id, Anonymous ;
   FROM Hold1 ;
   INTO CURSOR tHold1 
 
***************************************************************
* calculate number of services and clients within a service
* for anonymous clients

*!*   SELECT Conenc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          COUNT(*) AS NumbServAn, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumCliAn ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_Type, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          ConEnc ;
*!*      WHERE ConEnc.Tc_ID = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND ConEnc.Act_ID   = Ai_Serv.Act_ID ;   
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Serv_Cat = Service.Serv_Cat ;
*!*      AND (Ai_Enc.Enc_Type = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND tHold1.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*   UNION ALL ;
*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program , ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*          Enc_Type.Descript AS Enc_Type, ;
*!*          "Z - No Services Recorded" AS Service, ;
*!*          0 AS NumbServAn, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumCliAn ;
*!*     FROM tHold1, ;
*!*          Ai_enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_type, ;
*!*          ConEnc ;
*!*      WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;   
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND ConEnc.Act_Dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND tHold1.Anonymous=.T. ;
*!*      AND ConEnc.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR EncServAn

* jss, to prevent the key from being 240 characters (too long), only use first 75 of service description (longest in table currently is only 55)
SELECT Conenc.AllCont, ;
      Program.Descript AS Program, ;
      Serv_Cat.Descript AS Serv_Cat, ;
      Enc_list.Description AS Enc_type, ;
      Left(Serv_list.Description,75)  AS Service, ;
       COUNT(*) AS NumbServAn, ;
       COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumCliAn ;
  FROM tHold1, ;
       Ai_Enc, ;
       Program, ;
       Serv_Cat, ;
       Enc_list, ;
       Ai_Serv, ;
       Serv_list, ;
       ConEnc ;
   WHERE ConEnc.Tc_ID = tHold1.Tc_ID ;
   AND ConEnc.Program  = Program.Prog_ID ;
   AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
   AND ConEnc.Act_ID   = Ai_Serv.Act_ID ;   
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Ai_Serv.Service_id = Serv_list.service_id ;
   AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
   AND tHold1.Anonymous = .T. ;
 GROUP BY 1, 2, 3, 4, 5 ;
UNION ALL ;
SELECT ConEnc.AllCont, ;
      Program.Descript AS Program , ;
      Serv_Cat.Descript AS Serv_Cat, ;
       Enc_list.Description AS Enc_Type, ;
       Padr("Z - No Services Recorded",75) AS Service, ;
       0 AS NumbServAn, ;
       COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumCliAn ;
  FROM tHold1, ;
       Ai_enc, ;
       Program, ;
       Serv_Cat, ;
       Enc_list, ;
       ConEnc ;
   WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
   AND ConEnc.Program  = Program.Prog_ID ;
   AND ConEnc.Act_ID = Ai_Enc.Act_ID ;   
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.enc_id ;
   AND ConEnc.Act_Dt BETWEEN m.Date_From AND m.Date_To ;
   AND tHold1.Anonymous=.T. ;
   AND ConEnc.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3, 4, 5 ;
 ORDER BY 1, 2, 3, 4 ;
 INTO CURSOR EncServAn

* adding the alias changes what doesn't match
INDEX ON AllCont + Program + Left(Serv_Cat,40) + Enc_Type + Service TAG ProgEnc
SET ORDER TO ProgEnc

***************************************************************
* calculate number of services and clients within a service
* for all clients
*!*   SELECT Conenc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;   
*!*         Enc_type.Descript AS Enc_type, ;
*!*          Service.Descript  AS Service, ;
*!*          COUNT(*) AS NumbServ, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumClients ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ; 
*!*          Enc_Type, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          ConEnc ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND ConEnc.Act_ID   = Ai_Serv.Act_ID ;   
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ; 
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Serv_Cat = Service.Serv_Cat ;
*!*      AND (Ai_Enc.Enc_Type = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*   UNION ALL ;
*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program , ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;   
*!*          Enc_Type.Descript AS Enc_Type, ;
*!*          Padr("Z - No Services Recorded",80) AS Service, ;
*!*          0 AS Numbserv, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumClients ;
*!*     FROM tHold1, ;
*!*          Ai_enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;        
*!*          Enc_type, ;
*!*          ConEnc ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ; 
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND ConEnc.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR EncServ
*!*    

* jss, to prevent the key from being 240 characters (too long), only use first 75 of service description (longest in table currently is only 55)

SELECT Conenc.AllCont, ;
      Program.Descript AS Program, ;
      Serv_Cat.Descript AS Serv_Cat, ;   
      Enc_list.Description AS Enc_type, ;
       Left(Serv_list.Description,75)  AS Service, ;
       COUNT(*) AS NumbServ, ;
       COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumClients ;
  FROM tHold1, ;
       Ai_Enc, ;
       Program, ;
       Serv_Cat, ; 
       Enc_list, ;
       Ai_Serv, ;
       Serv_list, ;
       ConEnc ;
 WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
   AND ConEnc.Program  = Program.Prog_ID ;
   AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
   AND ConEnc.Act_ID   = Ai_Serv.Act_ID ;   
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Ai_Serv.Service_id = Serv_list.Service_id ;
   AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
 GROUP BY 1, 2, 3, 4, 5 ;
UNION ALL ;
SELECT ConEnc.AllCont, ;
      Program.Descript AS Program , ;
      Serv_Cat.Descript AS Serv_Cat, ;   
       Enc_list.Description AS Enc_Type, ;
       Padr("Z - No Services Recorded",75) AS Service, ;
       0 AS Numbserv, ;
       COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumClients ;
  FROM tHold1, ;
       Ai_enc, ;
       Program, ;
       Serv_Cat, ;        
       Enc_list, ;
       ConEnc ;
 WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
   AND ConEnc.Program  = Program.Prog_ID ;
   AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
   AND ConEnc.Act_ID NOT IN ;
       (SELECT Act_ID FROM Ai_Serv) ;
 GROUP BY 1, 2, 3, 4, 5 ;
 ORDER BY 1, 2, 3, 4 ;
 INTO CURSOR EncServ
 
* adding the alias changes what doesn't match
INDEX ON AllCont + Program + Left(Serv_Cat,40) + Enc_Type + Service TAG ProgEnc
SET ORDER TO ProgEnc
SET RELATION TO AllCont + Program + Left(Serv_Cat,40) + Enc_Type + Service INTO EncServAn

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for anonymous clients

*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;   
*!*         Enc_type.Descript AS Enc_type, ;
*!*          COUNT(Conenc.Act_ID) AS AnonEnctrs, ;
*!*         COUNT(DIST tHold1.tc_id) AS AnonCliSvd, ;
*!*         ContrInf.Descript, ;
*!*         PADR(ALLTRIM(a.Descript),40) AS Program1, ;
*!*         Contract.Start_Dt, Contract.End_Dt, ConType.Descript AS ConType ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Program A, ;
*!*          Serv_Cat, ; 
*!*          Enc_Type, ;
*!*          ConEnc, ;
*!*          Contract, ;
*!*          ContrInf, ;
*!*          ConType ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;   
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ; 
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Contract.Cid = ConEnc.AllCont ;
*!*      AND Contract.Con_ID = ContrInf.Cid ;
*!*      AND ContrInf.ConType = ConType.Code ;
*!*      AND ConEnc.AllProg = a.Prog_ID ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND tHold1.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ProgEncAn

SELECT ConEnc.AllCont, ;
      Program.Descript AS Program, ;
      Serv_Cat.Descript AS Serv_Cat, ;   
      Enc_list.Description AS Enc_type, ;
       COUNT(Conenc.Act_ID) AS AnonEnctrs, ;
      COUNT(DIST tHold1.tc_id) AS AnonCliSvd, ;
      ContrInf.Descript, ;
      PADR(ALLTRIM(a.Descript),40) AS Program1, ;
      Contract.Start_Dt, Contract.End_Dt, ConType.Descript AS ConType ;
  FROM tHold1, ;
       Ai_Enc, ;
       Program, ;
       Program A, ;
       Serv_Cat, ; 
       Enc_list, ;
       ConEnc, ;
       Contract, ;
       ContrInf, ;
       ConType ;
 WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
   AND ConEnc.Program  = Program.Prog_ID ;
   AND ConEnc.Act_ID = Ai_Enc.Act_ID ;   
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Contract.Cid = ConEnc.AllCont ;
   AND Contract.Con_ID = ContrInf.Cid ;
   AND ContrInf.ConType = ConType.Code ;
   AND ConEnc.AllProg = a.Prog_ID ;
   AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
   AND tHold1.Anonymous = .T. ;
 GROUP BY 1, 2, 3, 4 ;
 ORDER BY 1, 2, 3, 4 ;
 INTO CURSOR ProgEncAn

INDEX ON AllCont + Program + Left(Serv_Cat,40) + Enc_type TAG ProgEnc
SET ORDER TO ProgEnc

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for all clients

*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          COUNT(Conenc.Act_ID) AS NumbEnctrs, ;
*!*         COUNT(DIST tHold1.tc_id) AS EncCliSvd, ;
*!*         ContrInf.Descript, ;
*!*         PADR(ALLTRIM(a.Descript),40) AS Program1, ;
*!*         Contract.Start_Dt, Contract.End_Dt, ConType.Descript AS ConType ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Program A, ;
*!*          Serv_Cat, ;
*!*          Enc_Type, ;
*!*          ConEnc, ;
*!*          Contract, ;
*!*          ContrInf, ;
*!*          ConType ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Contract.Cid = ConEnc.AllCont ;
*!*      AND Contract.Con_ID = ContrInf.Cid ;
*!*      AND ContrInf.ConType = ConType.Code ;
*!*      AND ConEnc.AllProg = a.Prog_ID ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ProgEnc1
 
SELECT ConEnc.AllCont, ;
      Program.Descript AS Program, ;
      Serv_Cat.Descript AS Serv_Cat, ;
      Enc_list.Description AS Enc_type, ;
      COUNT(Conenc.Act_ID) AS NumbEnctrs, ;
      COUNT(DIST tHold1.tc_id) AS EncCliSvd, ;
      ContrInf.Descript, ;
      PADR(ALLTRIM(a.Descript),40) AS Program1, ;
      Contract.Start_Dt, Contract.End_Dt, ConType.Descript AS ConType ;
  FROM tHold1, ;
       Ai_Enc, ;
       Program, ;
       Program A, ;
       Serv_Cat, ;
       Enc_list, ;
       ConEnc, ;
       Contract, ;
       ContrInf, ;
       ConType ;
 WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
   AND ConEnc.Program  = Program.Prog_ID ;
   AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
   AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Contract.Cid = ConEnc.AllCont ;
   AND Contract.Con_ID = ContrInf.Cid ;
   AND ContrInf.ConType = ConType.Code ;
   AND ConEnc.AllProg = a.Prog_ID ;
   AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
 GROUP BY 1, 2, 3, 4 ;
 ORDER BY 1, 2, 3, 4 ;
 INTO CURSOR ProgEnc1
 
Select ProgEnc1.* , ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;   
From ProgEnc1 ;
Into Cursor ;
      ProgEnc

************AllCont*****************
SELECT AllCont, ;
   SUM(NumbEnctrs) AS Sum_Enc, ;
   SUM(EncCliSvd) AS Sum_Cli ;
FROM ProgEnc ;
GROUP BY 1 ;
INTO CURSOR Con_Tot 

INDEX ON AllCont TAG AllCont

SELECT AllCont, ;
   SUM(AnonEnctrs) AS Sum_Enc, ;
   SUM(AnonCliSvd) AS Sum_Cli ;
FROM ProgEncAn ;
GROUP BY 1 ;
INTO CURSOR Con_TotAn 

INDEX ON AllCont TAG AllCont

************Program*****************

SELECT AllCont, Program, ;
   SUM(NumbEnctrs) AS Sum_Enc, ;
   SUM(EncCliSvd)  AS Sum_Cli ;
FROM ProgEnc ;
GROUP BY 1, 2 ;
INTO CURSOR Prog_Tot

INDEX ON AllCont + Program TAG Program

SELECT AllCont, Program, ;
   SUM(AnonEnctrs) AS Sum_Enc, ;
   SUM(AnonCliSvd) AS Sum_Cli ;
FROM ProgEncAn ;
GROUP BY 1, 2 ;
INTO CURSOR Prog_TotAn

INDEX ON AllCont + Program TAG Program

************Serv_Cat*****************


SELECT AllCont, Program, Serv_Cat, ;
   SUM(NumbEnctrs) AS Sum_Enc, ;
   SUM(EncCliSvd)  AS Sum_Cli ;
FROM ProgEnc ;
GROUP BY 1, 2, 3 ;
INTO CURSOR Sc_Tot

INDEX ON AllCont + Program + Left(Serv_Cat,40) TAG Serv_Cat

SELECT AllCont, Program, Serv_Cat, ;
   SUM(AnonEnctrs) AS Sum_Enc, ;
   SUM(AnonCliSvd) AS Sum_Cli ;
FROM ProgEncAn ;
GROUP BY 1, 2, 3 ;
INTO CURSOR Sc_TotAn

INDEX ON AllCont + Program + Left(Serv_Cat,40) TAG Serv_Cat

SELECT Progenc
SET RELATION TO AllCont + Program + Serv_Cat + Enc_Type INTO EncServ, ;
                AllCont + Program + Serv_Cat + Enc_Type INTO ProgEncAn, ;
                AllCont INTO Con_Tot, ;
                AllCont INTO Con_TotAn, ;
                AllCont + Program INTO Prog_Tot, ;
                AllCont + Program INTO Prog_TotAn, ;                
                AllCont + Program + Serv_Cat INTO Sc_Tot, ;
                AllCont + Program + Serv_Cat INTO Sc_TotAn          
SET SKIP TO EncServ

oApp.Msg2User('OFF')

cReportSelection = .aGroup(nGroup)

IF RECC() = 0
  oApp.msg2user('NOTFOUNDG')
  RETURN .T.
ENDIF

gcRptName = 'rpt_cnenc'
Do Case
CASE lPrev = .f.
   Report Form rpt_cnenc To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_cnenc', 1, 2)
EndCase

USE IN tHold1 

Return

*******************
Procedure Rpt_Refct
*******************
IF USED('tHold1')
   USE IN tHold1
ENDIF   

SELECT DIST ;
   tc_id, Anonymous ;
FROM ;
   Hold1 ;
INTO CURSOR ;
   tHold1 

IF _tally = 0
   oApp.msg2user("NOTFOUNDG")
   USE IN tHold1
   return .f.
ENDIF
****************************************************

**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(ai_enc.program, "  + lcprog + ")" )
*ai_enc.program = lcprog ;


SELECT ;
   program.descript  AS program    ,;
   serv_cat.descript AS servcatdes ,;
   enc_type.descript AS enctypedes ,;
   SPACE(50)           AS Category   ,;
   SPACE(45)           AS Service    ,;
   SPACE(30)           AS refstatus  ,;
   0000                 AS SrvStatCnt ,;
   0000                 AS CliCount   ,;
   ai_enc.program    AS prog_id    ,;
   ai_enc.serv_cat, ;
   ai_enc.enc_type, ;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,; 
   ai_ref.status                ,;   
   ai_ref.ref_for                ;   
FROM ;
   tHold1, ai_ref, ai_enc, program, serv_cat, enc_type ;
WHERE ;
   tHold1.tc_id   = ai_ref.tc_id AND ;
   ai_ref.ref_dt BETWEEN m.Date_From AND m.Date_To AND ;
   ai_enc.act_id = ai_ref.act_id AND ;
   ai_enc.serv_cat = serv_cat.code AND ;
   ai_enc.serv_cat = enc_type.serv_cat AND ;
   ai_enc.enc_type = enc_type.code AND ;
   ai_enc.program = program.prog_id ;
  &cWherePrg ;
INTO CURSOR tAllRef1a   

* jss, 7/9/04, use need_id to get unique recs from ai_ref for syringe exchange referrals
**VT 01/08/2007
cWherePrg = IIF(Empty(lcprog),"", " And Inlist(needlx.program, "  + lcprog + ")" )
*needlx.program = lcprog ;

SELECT ;
   program.descript  AS program    ,;
   PADR('Needle Exchange',30) AS servcatdes ,;
   PADR('Exhange',50)           AS enctypedes ,;
   SPACE(50)           AS Category   ,;
   SPACE(45)           AS Service    ,;
   SPACE(30)           AS refstatus  ,;
   0000                 AS SrvStatCnt ,;
   0000                 AS CliCount   ,;
   needlx.program    AS prog_id    ,;
   'ZZZZZ'            AS serv_cat , ;
   'ZZZ'               AS enc_type ,;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,; 
   ai_ref.status                ,;   
   ai_ref.ref_for                ;   
FROM ;
   tHold1, ai_ref, needlx, program ;
WHERE ;
   tHold1.tc_id   = ai_ref.tc_id AND ;
   ai_ref.ref_dt BETWEEN m.Date_From AND m.Date_To AND ;
   EMPTY(ai_ref.act_id) AND ;
   needlx.need_id = ai_ref.need_id AND ;
   needlx.tc_id = ai_ref.tc_id AND ;
   needlx.program = program.prog_id ;
   &cWherePrg ;
INTO CURSOR tAllRef1b

* jss, 7/8/04, combine them
SELECT * FROM tAllRef1a ;
UNION ALL ;
SELECT * FROM tAllRef1b ;
INTO CURSOR ;
tAllRef1

**VT 01/08/2008 
cWherePrg = ''
   
* jss, 7/8/04, add 'AND Empty(ai_ref.need_id)' into query below to handle referrals from syringe exchange screen
* jss, 7/28/04, add serv_cat and enc_type to select below for CT
IF EMPTY(lcprog)
   SELECT * FROM tAllRef1   ;
   UNION ALL  ;
   SELECT ;
      "†Program Unknown"    AS program    ,;
      SPACE(30)         AS servcatdes,;
      SPACE(50)         AS enctypedes,;
      SPACE(50)           AS Category   ,;
      SPACE(45)           AS Service    ,;
      SPACE(30)           AS refstatus  ,;
      0000              AS SrvStatCnt ,;
      0000              AS CliCount   ,;
      SPACE(5)            AS prog_id    ,;
      SPACE(5)            AS serv_cat   ,;
      SPACE(3)            AS enc_type   ,;
      ai_ref.tc_id                      ,;
      ai_ref.ref_cat                    ,; 
      ai_ref.status                  ,;   
      ai_ref.ref_for                  ;   
   FROM ;
      tHold1, ai_ref ;
   WHERE ;
      tHold1.tc_id   = ai_ref.tc_id AND ;
      ai_ref.ref_dt BETWEEN m.Date_From AND m.Date_To AND ;
      Empty(ai_ref.act_id) ;
      AND Empty(ai_ref.need_id) ;
   INTO CURSOR ;
      tRef readwrite
ELSE
   SELECT * FROM tAllRef1 INTO CURSOR tRef readwrite
ENDIF

IF _tally = 0
   oApp.msg2user("NOTFOUNDG")
   USE IN tHold1
   return .f.
ENDIF
* open lookup tables and set appropriate relationships
SELE 0
=OpenFile('ref_cat','code')
SELE 0
=OpenFile('ref_stat','code')
SELE 0
=OpenFile('ref_for','catcode')
*=ReOpenCur("tAllRef", "tRef")
Select tRef
SET RELAT TO ref_cat          INTO ref_cat
SET RELAT TO status           INTO ref_stat addi
SET RELAT TO ref_cat+ref_for     INTO ref_for  addi
REPLACE ALL category WITH IIF(FOUND('ref_cat'),  ref_cat.descript,  '~Category Not Reported'), ;
         refstatus   WITH IIF(FOUND('ref_stat'), ref_stat.descript, '~Status Not Reported'), ;
         service     WITH IIF(FOUND('ref_for'),  ref_for.descript,  '~Service Not Reported')


* count referrals by program+servcatdes+enctypedes+category+service+refstatus: this yields detail info of report
SELECT ;
   program    ,;
   servcatdes ,;
   enctypedes ,;
   Category   ,;
   Service    ,;
   refstatus  ,;
   prog_id    ,;
   serv_cat   ,;
   enc_type   ,;
   COUNT(*)          AS SrvStatCnt ,;
   COUNT(DIST tc_id) AS CliCount,   ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.Date_from as Date_from, ;
   m.date_to as date_to, ;
   cOrderBy as sort_order ;      
FROM ;
   tRef ;
GROUP BY ;
   1, 2, 3, 4, 5, 6 ;
INTO CURSOR ;
   Ref_Cur
   
****************************************************

* count distinct tc_ids by program+serv_cat+enc_type+category
SELECT ;
   prog_id ,;
   serv_cat,;
   enc_type,;
   category ,;
   COUNT(DISTINCT tc_id) AS CliCount;
FROM ;
   tRef ;
GROUP BY ;
   1, 2, 3, 4 ;
INTO CURSOR ;
   cattotal
   
INDEX ON prog_id+Left(Serv_Cat,40)+enc_type+category TAG prgscetcat

SELECT ref_cur
SET RELATION TO prog_id + Left(Serv_Cat,40) + enc_type+category INTO cattotal
   
* count distinct tc_ids by program+serv_cat+enc_type
SELECT ;
   prog_id ,;
   serv_cat,;
   enc_type,;
   COUNT(DISTINCT tc_id) AS CliCount;
FROM ;
   tRef ;
GROUP BY ;
   1, 2, 3 ;
INTO CURSOR ;
   ettotal
   
INDEX ON prog_id+serv_cat+enc_type TAG prgscet

SELECT ref_cur
SET RELATION TO prog_id + serv_cat INTO ettotal ADDI
   
* count distinct tc_ids by program+serv_cat
SELECT ;
   prog_id ,;
   serv_cat,;
   COUNT(DISTINCT tc_id) AS CliCount;
FROM ;
   tRef ;
GROUP BY ;
   1, 2 ;
INTO CURSOR ;
   sctotal
   
INDEX ON prog_id+serv_cat TAG prgsc

SELECT ref_cur
SET RELATION TO prog_id + serv_cat INTO sctotal ADDI
   
* count distinct tc_ids by program
SELECT ;
   prog_id ,;
   COUNT(DISTINCT tc_id) AS CliCount;
FROM ;
   tRef ;
GROUP BY ;
   1;
INTO CURSOR ;
   prgtotal
   
INDEX ON prog_id TAG prog

SELECT ref_cur
SET RELATION TO prog_id INTO prgtotal ADDI
   
oApp.Msg2User('OFF')


cReportSelection = .aGroup(nGroup)

gcRptName = 'rpt_refct'
Do Case
CASE lPrev = .f.
   Report Form rpt_refct To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_refct', 1, 2)
EndCase

* close cursors
*USE IN ref_cur
*USE IN cattotal
*USE IN ettotal
*USE IN sctotal
*USE IN prgtotal
IF USED('tAllRef1a')
   USE IN tAllRef1a
ENDIF
IF USED('tAllRef1b')
   USE IN tAllRef1b
ENDIF
IF USED('tAllRef1')
   USE IN tAllRef1
ENDIF
*IF USED('tAllRef')
*   USE IN tAllRef
*ENDIF
IF USED('tRef')
   USE IN tRef
ENDIF

* close dbfs 
USE IN ai_ref
USE IN ref_cat
USE IN ref_for
USE IN ref_stat
USE IN ai_enc
USE IN program
IF USED('needlx')
   USE IN needlx
ENDIF

Return