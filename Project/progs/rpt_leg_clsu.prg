Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              from_dt , ;         && from date
              to_dt, ;            && to date   
              ParamName , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

lcProgx   = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

  
* jss, 4/5/04, legal services module: client summary report
PRIVATE gchelp
gchelp = "Legal Services Client Summary Report Screen"
*cDescProg=""
cTitle='Legal Services Client Summary Report'
*LglTypDesc=cDescProg

=clear_data()

* clients with active cases at the start of the period
If Used('ActBeg')
   Use in ActBeg
EndIf

*!* Create a list of encounters and their collaterals
*!* The client_id is the ID of the index client

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query
   
*!* SELECT DISTINCT;
*!* 	tc_id  ;
*!* FROM ;
*!* 	ai_enc ;
*!* WHERE ;
*!* 	serv_cat = '00021' AND ;
*!* 	program = lcprogx  AND ;
*!* 	act_dt < from_dt AND ;
*!* 	(caseclosdt >= from_dt OR ;
*!* 	 EMPTY(caseclosdt)) ;	
*!* GROUP BY ;
*!* 	tc_id ;
*!* INTO CURSOR ActBeg
   
SELECT DISTINCT;
	ai_enc.tc_id  ;
FROM ;
	ai_enc ;
      Inner Join ai_clien On ;
      	 ai_clien.tc_id = ai_enc.tc_id ;
      Inner Join client On ;
         client.client_id = ai_clien.client_id ;
WHERE ;
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	act_dt < from_dt AND ;
	(caseclosdt >= from_dt OR ;
	 EMPTY(caseclosdt)) ;	
GROUP BY ;
	ai_enc.tc_id ;
INTO CURSOR ActBeg

** GOxford END 3/28/12

m.CliActBeg = _tally

* clients enrolled in a case this period

If Used('EnrInPer')
   Use in EnrInPer
EndIf

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query
   
*|* SELECT DISTINCT;
*|* 	tc_id  ;
*|* FROM ;
*|* 	ai_enc ;
*|* WHERE ;
*|* 	serv_cat = '00021';
*|* 	And program = lcprogx ;
*|* 	And Between(act_dt, from_dt, to_dt)	;
*|* GROUP BY ;
*|* 	tc_id ;
*|* INTO CURSOR EnrInPer

SELECT DISTINCT;
	ai_enc.tc_id  ;
FROM ;
	ai_enc ;
      Inner Join ai_clien On ;
      	 ai_clien.tc_id = ai_enc.tc_id ;
      Inner Join client On ;
         client.client_id = ai_clien.client_id ;
WHERE ;
	serv_cat = '00021';
	And program = lcprogx ;
	And Between(act_dt, from_dt, to_dt)	;
GROUP BY ;
	ai_enc.tc_id ;
INTO CURSOR EnrInPer

** GOxford END 3/28/12

* all clients enrolled at some point in period

**VT 07/27/2011 AIRS-133
*!*	If Used('AllEnr')
*!*	   Use in AllEnr
*!*	EndIf
*!*	   
*!*	SELECT * FROM ActBeg ;
*!*	UNION ;
*!*	SELECT * FROM EnrInPer ;
*!*	INTO CURSOR ;
*!*		AllEnr
	
* clients NEWLY enrolled in a case in period
If Used('NewEnr1')
   Use in NewEnr1
EndIf
   
SELECT DISTINCT;
	tc_id ;
FROM ;
	EnrInPer ;
WHERE ;
	tc_id NOT IN (SELECT tc_id FROM ActBeg) ;
INTO CURSOR ;
	NewEnr1    &&**VT 11/05/2009 Dev Tick 5577 changed from NewEnr to NewEnr1
   
**VT 11/05/2009 Dev Tick 5577 Check if client is newly enrolled in the program
If Used('NewEnr')
   Use in NewEnr
Endif

**VT 07/27/2011 AIRS-133

*!*	SELECT ;
*!*	      Distinct ai_enc.tc_id  ;
*!*	FROM ;
*!*	   ai_enc ;
*!*	      Inner Join NewEnr1 On ;
*!*	         ai_enc.tc_id = NewEnr1.tc_id ;
*!*	WHERE ;
*!*	  ai_enc.serv_cat = '00021' AND ;
*!*	  ai_enc.program = lcprogx  AND ;
*!*	  ai_enc.act_dt >= from_dt AND ;
*!*	  ai_enc.act_dt <= to_dt   ;
*!*	  and ai_enc.tc_id + ai_enc.program Not In ;
*!*	                  (SELECT ai_prog.tc_id + ai_prog.program ;
*!*	                     FROM ai_prog ;
*!*	                     WHERE ;
*!*	                        ai_prog.start_dt < from_dt ;
*!*	                     GROUP BY ;
*!*	                        ai_prog.tc_id, ai_prog.program) ;
*!*	GROUP BY ;
*!*	   ai_enc.tc_id ;
*!*	INTO CURSOR ;
*!*	   NewEnr

** GOxford 03/24/2012 AIRS-133
** Removed WHERE condition:
**  and (caseclosdt < from_dt OR ;
**	 EMPTY(caseclosdt)) ;
** (It was causing the SELECT to miss any new clients whose case(s) ended within the time period)

*!* SELECT ;
*!*       Distinct ai_enc.tc_id  ;
*!* FROM ;
*!*    ai_enc ;
*!*       Inner Join NewEnr1 On ;
*!*          ai_enc.tc_id = NewEnr1.tc_id ;
*!* WHERE ;
*!*   ai_enc.serv_cat = '00021' AND ;
*!*   ai_enc.program = lcprogx  AND ;
*!*   ai_enc.act_dt >= from_dt AND ;
*!*   ai_enc.act_dt <= to_dt   ;
*!*   and (caseclosdt < from_dt OR ;
*!* 	 EMPTY(caseclosdt)) ;
*!* GROUP BY ;
*!*    ai_enc.tc_id ;
*!* INTO CURSOR ;
*!*    NewEnr
*!* **VT END

SELECT ;
      Distinct ai_enc.tc_id  ;
FROM ;
   ai_enc ;
      Inner Join NewEnr1 On ;
         ai_enc.tc_id = NewEnr1.tc_id ;
WHERE ;
  ai_enc.serv_cat = '00021' AND ;
  ai_enc.program = lcprogx  AND ;
  ai_enc.act_dt >= from_dt AND ;
  ai_enc.act_dt <= to_dt   ;
GROUP BY ;
   ai_enc.tc_id ;
INTO CURSOR ;
   NewEnr
** GOxford END 3/24/12

m.CliNewEnr = _tally

* ALL clients with an active case at some point in period
m.CliActDur = m.cliactbeg + m.clinewenr

* clients with active case in program at end of period + 1
If Used('ActEnd')
   Use in ActEnd
EndIf

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query
   
*|* SELECT DISTINCT;
*|* 	tc_id ;
*|* FROM ;
*|* 	ai_enc ;
*|* WHERE ;
*|* 	act_dt <= to_dt AND ;
*|* 	serv_cat = '00021' AND ;
*|* 	program = lcprogx  AND ;
*|* 	(EMPTY(caseclosdt) OR caseclosdt > to_dt) ;
*|* GROUP BY ;
*|* 	tc_id ;	
*|* INTO CURSOR ;
*|* 	ActEnd	
   
SELECT DISTINCT;
	ai_enc.tc_id ;
FROM ;
	ai_enc ;
      Inner Join ai_clien On ;
      	 ai_clien.tc_id = ai_enc.tc_id ;
      Inner Join client On ;
         client.client_id = ai_clien.client_id ;
WHERE ;
	act_dt <= to_dt AND ;
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	(EMPTY(caseclosdt) OR caseclosdt > to_dt) ;
GROUP BY ;
	ai_enc.tc_id ;	
INTO CURSOR ;
	ActEnd	
** GOxford END 3/24/12

m.CliActEnd=_tally

* clients with ALL cases closed during period (clients with no active cases as of period end who appeared in ActBeg and/or EnrInPer)
If Used('ClosInPer')
   Use in ClosInPer
EndIf

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query
   
*|* SELECT DISTINCT;
*|* 	tc_id ;
*|* FROM ;
*|* 	ai_enc ;
*|* WHERE ;
*|* 	serv_cat = '00021' AND ;
*|* 	program = lcprogx  AND ;
*|* 	caseclosdt >= from_dt AND ;
*|* 	caseclosdt <= to_dt AND ;
*|* 	tc_id NOT IN ;
*|* 		(SELECT tc_id FROM ActEnd) ;
*|* GROUP BY ;
*|* 	tc_id ;
*|* INTO CURSOR ClosInPer
   
SELECT DISTINCT;
	ai_enc.tc_id ;
FROM ;
	ai_enc ;
      Inner Join ai_clien On ;
      	 ai_clien.tc_id = ai_enc.tc_id ;
      Inner Join client On ;
         client.client_id = ai_clien.client_id ;
WHERE ;
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	caseclosdt >= from_dt AND ;
	caseclosdt <= to_dt AND ;
	ai_enc.tc_id NOT IN ;
		(SELECT tc_id FROM ActEnd) ;
GROUP BY ;
	ai_enc.tc_id ;
INTO CURSOR ClosInPer

** GOxford END 3/28/12
	
m.CliCloDur = _tally

* get clients provided services in period
If Used('ServInPer')
   Use in ServInPer
EndIf

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query
   
*|* SELECT DISTINCT;
*|* 	tc_id ;
*|* FROM ;
*|* 	ai_enc ;
*|* WHERE ;
*|* 	serv_cat = '00021' AND ;
*|* 	program = lcprogx  AND ;
*|* 	act_id IN (SELECT act_id FROM ai_serv WHERE date >= from_dt and date <= to_dt) ;
*|* GROUP BY ;
*|* 	tc_id ;
*|* INTO CURSOR ServInPer
   
SELECT DISTINCT;
	ai_enc.tc_id ;
FROM ;
	ai_enc ;
      Inner Join ai_clien On ;
      	 ai_clien.tc_id = ai_enc.tc_id ;
      Inner Join client On ;
         client.client_id = ai_clien.client_id ;
WHERE ;
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	act_id IN (SELECT act_id FROM ai_serv WHERE date >= from_dt and date <= to_dt) ;
GROUP BY ;
	ai_enc.tc_id ;
INTO CURSOR ServInPer

** GOxford END 3/28/12

***	(caseclosdt >= to_dt  or EMPTY(caseclosdt)) AND 

m.CliSrvDur = _tally

* now, let's get new clients HIV+ (not AIDS)
* jss, 9/22/04, use DTOS, not DTOC, for routine below to grab true latest status record
If Used('NewCliHiv')
   Use in NewCliHiv
EndIf
   
SELECT DISTINCT;
	a.tc_id ;
FROM ;
	NewEnr a, ;
	HivStat b, ;
	Hstat c ;
WHERE ;
	a.tc_id = b.tc_id AND ;
	b.hivstatus = c.code AND ;
	c.hiv_pos AND ;
	c.code <> '10' AND ;
	b.tc_id+DTOS(b.effect_dt) IN (SELECT d.tc_id + MAX(DTOS(d.effect_dt)) FROM HivStat d ;
						WHERE d.effect_dt <= to_dt ;
						GROUP BY d.tc_id) ;						
GROUP BY ;
	a.tc_id ;						
INTO CURSOR ;
	NewCliHiv
	
m.CliHiv = _tally

* now, get new client w/ AIDS
* jss, 9/22/04, use DTOS, not DTOC, for routine below to grab true latest status record
If Used('NewCliAIDS')   
   Use in NewCliAIDS
EndIf
   
SELECT DISTINCT;
	a.tc_id ;
FROM ;
	NewEnr a, ;
	HivStat b;
WHERE ;
	a.tc_id = b.tc_id AND ;
	b.hivstatus = '10' AND ;
	b.tc_id+DTOS(b.effect_dt) IN (SELECT c.tc_id + MAX(DTOS(c.effect_dt)) FROM HivStat c ;
						WHERE c.effect_dt <= to_dt ;
						GROUP BY c.tc_id) ;
GROUP BY ;
	a.tc_id ;
INTO CURSOR ;
	NewCliAIDS

m.CliAIDS = _tally

*!*   Pre 8.6 code 
*!*   * create a cursor of children under 13 years old
*!*   If Used('Child12')
*!*      Use in Child12
*!*   EndIf
*!*      
*!*   SELECT DISTINCT;
*!*   	a.tc_id, ;
*!*   	a.client_id ;
*!*   FROM ;
*!*   	ai_famil a,  ;
*!*   	client b ;	 
*!*   WHERE a.client_id=b.client_id ;
*!*   	AND !EMPTY(b.dob) ;
*!*   	AND oApp.Age(to_dt,b.dob) < 13 ;
*!*   INTO CURSOR ;
*!*   	Child12

*!*   * create a cursor of children between 13 and 21 years old
*!*   If Used('Child13')
*!*      Use in Child13
*!*   EndIf

*!*   SELECT DISTINCT;
*!*   	a.tc_id, ;
*!*   	a.client_id ;
*!*   FROM ;
*!*   	ai_famil a,  ;
*!*   	client b ;	 
*!*   WHERE a.client_id=b.client_id ;
*!*   	AND !EMPTY(b.dob) ;
*!*   	AND oApp.Age(to_dt,b.dob) >=13 AND oApp.Age(to_dt,b.dob) <=21 ;
*!*   INTO CURSOR ;
*!*   	Child13

*!* Changes for 8.6 #6480
*!* Create a list of new client w/Collaterals Involved (in encounter).
*!* Don't worry about the relationship - select by 'Family Member' = .t.
*!* Group by age bands.

Select Distinct;
   ai_enc.tc_id,;
   ai_enc.act_id,;
   ai_colen.client_id,;
   Cast(Age(to_dt,client.dob) AS Int) As currentAge;
From ai_enc ;
Join ai_colen On ai_colen.act_id=ai_enc.act_id;
Join ai_famil On ai_colen.client_id=ai_famil.client_id ;
   And ai_famil.tc_id= ai_enc.tc_id;
Join client On ai_famil.client_id=client.client_id;
Where ai_famil.member=(.t.);
   And ai_enc.serv_cat = '00021';
   And ai_enc.act_dt >= from_dt;
   And ai_enc.act_dt <= to_dt ;
   And ai_enc.tc_id In (Select tc_id From NewEnr);
Into Cursor _curCollats


Select _curCollats
Declare _aJunk(1) 

**VT 12/19/2011
*!*	Select Distinct tc_id From _curCollats Into Array _aJunk
*!*	m.CliChild=_Tally

Select Distinct tc_id From _curCollats Where currentAge < 13 Into Array _aJunk
m.CliChild12=_Tally

Select Distinct tc_id From _curCollats Where Between(currentAge,12,21) Into Array _aJunk
m.CliChild13=_Tally

**VT 12/19/2011
m.CliChild=m.CliChild12 + m.CliChild13

Select Distinct tc_id From _curCollats Where currentAge>21 Into Array _aJunk
m.CliAdult=_Tally

Release _aJunk

*!*   If Used('ChildUnd22')
*!*      Use in ChildUnd22
*!*   EndIf
*!*   	
*!*   SELECT * FROM Child12 ;
*!*   UNION ;
*!*   SELECT * FROM Child13 ;
*!*   INTO CURSOR ;
*!*   	ChildUnd22
*!*   		
*!*   * now, find new clients with children
*!*   If Used('CliChild')
*!*      Use in CliChild
*!*   EndIf
*!*      
*!*   SELECT DISTINCT;
*!*   	tc_id ;
*!*   FROM ;
*!*   	NewEnr ;
*!*   WHERE tc_id IN ;
*!*   		(SELECT tc_id ;
*!*   		FROM ai_famil ;
*!*   		WHERE relation $ '03 04 14 16') ;
*!*   AND tc_id IN ;
*!*   		(SELECT tc_id FROM ChildUnd22) ; 	
*!*   INTO CURSOR ;
*!*   	CliChild
*!*   	
*!*   m.CliChild=_tally

*!*   * now, count clients with children under 13
*!*   If Used('CliChild12')
*!*      Use in CliChild12
*!*   EndIf

*!*   SELECT DISTINCT;
*!*   	tc_id ;
*!*   FROM ;
*!*   	CliChild ;
*!*   WHERE ;
*!*   	tc_id IN (SELECT tc_id FROM Child12) ;
*!*   INTO CURSOR ;
*!*   	CliChild12
*!*   	
*!*   m.CliChild12 = _tally

*!*   * now, count clients with children between 13 and 21
*!*   If Used('CliChild13')
*!*      Use in CliChild13
*!*   EndIf

*!*   SELECT DISTINCT;
*!*   	tc_id ;
*!*   FROM ;
*!*   	CliChild ;
*!*   WHERE ;
*!*   	tc_id IN (SELECT tc_id FROM Child13) ;
*!*   INTO CURSOR ;
*!*   	CliChild13
*!*   	
*!*   m.CliChild13 = _tally

*!*   * jss, 4/23/04, add adult collateral count
*!*   * jss, 6/2/04, make sure collateral actually over 21

*!*   * create a cursor of adults over 21
*!*   If Used('adultcur')
*!*      Use in adultcur
*!*   Endif

*!*   SELECT DISTINCT;
*!*   	a.tc_id, ;
*!*   	a.client_id ;
*!*   FROM ;
*!*   	ai_famil a,  ;
*!*   	client b ;	 
*!*   WHERE a.client_id=b.client_id ;
*!*   	AND !EMPTY(b.dob) ;
*!*   	AND oApp.Age(to_dt,b.dob) > 21 ;
*!*   INTO CURSOR ;
*!*   	adultcur

*!*   If Used('CliAdult')
*!*      Use in CliAdult
*!*   EndIf

*!*   **VT 12/17/2009 Dev Tick 5577 add codes '03 04 14 16' for included Adult Son or daut 
*!*   SELECT DISTINCT;
*!*      tc_id ;
*!*   FROM ;
*!*      NewEnr ;
*!*   WHERE tc_id IN ;
*!*         (SELECT tc_id ;
*!*         FROM ai_famil ;
*!*         WHERE relation $ '01 02 05 06 09 11 12 13 15 38 03 04 14 16 ') ;
*!*     AND tc_id IN  ;
*!*           (SELECT tc_id FROM adultcur) ;
*!*   INTO CURSOR ;
*!*      CliAdult
*!*    
*!*   m.CliAdult=_tally

* must only have one record report cursor

If used('leg_cl')
   Use in leg_cl
EndIf

Select Distinct ;
       system_id, ;
       m.cliactbeg as cliactbeg, ;
       m.clinewenr as clinewenr, ;
       m.cliactdur as cliactdur, ;
       m.cliclodur as cliclodur, ;
       m.cliactend as cliactend, ;
       m.clisrvdur as clisrvdur, ;
       m.cliaids as cliaids, ;
       m.clihiv as clihiv, ;
       m.clichild as clichild, ;
       m.clichild12 as clichild12, ;
       m.clichild13 as clichild13, ;
       m.cliadult as cliadult, ;
       cTitle as cTitle, ;
       ParamName as  Crit, ;   
       cDate as cDate, ;
       cTime as cTime, ;
       from_dt as date_from, ;
       to_dt as date_to;      
FROM system  ;
WHERE system_id = gcSys_Prefix  ;
Into Cursor leg_cl

oApp.msg2user('OFF')
gcRptName = 'rpt_leg_clsu'            
GO TOP
IF EOF()
     oApp.msg2user('NOTFOUNDG')
Else
     DO CASE
         CASE lPrev = .f.
              Report Form rpt_leg_clsu To Printer Prompt Noconsole NODIALOG 
          CASE lPrev = .t.     &&Preview
              oApp.rpt_print(5, .t., 1, 'rpt_leg_clsu', 1, 2)
     ENDCASE   
EndIf

********************************************************************************
Function clear_data

IF USED('AI_ENC')
	USE IN AI_ENC
ENDIF
IF USED('AI_SERV')
	USE IN AI_SERV
ENDIF
IF USED('ACTBEG')
	USE IN ACTBEG
ENDIF
IF USED('ENRINPER')
	USE IN ENRINPER
EndIf

**VT 07/27/2011 AIRS-133
*!*	IF USED('ALLENR')
*!*		USE IN ALLENR
*!*	ENDIF
IF USED('NEWENR')
	USE IN NEWENR
ENDIF
IF USED('CLOSINPER')
	USE IN CLOSINPER
ENDIF
IF USED('ACTEND')
	USE IN ACTEND
ENDIF
IF USED('SERVINPER')
	USE IN SERVINPER
ENDIF
IF USED('NEWCLIHIV')
	USE IN NEWCLIHIV
ENDIF
IF USED('NEWCLIAIDS')
	USE IN NEWCLIAIDS
ENDIF
IF USED('CHILD12')
	USE IN CHILD12
ENDIF
IF USED('CHILD13')
	USE IN CHILD13
ENDIF
IF USED('CHILDUND22')
	USE IN CHILDUND22
ENDIF
IF USED('CLICHILD12')
	USE IN CLICHILD12
ENDIF
IF USED('CLICHILD13')
	USE IN CLICHILD13
ENDIF
IF USED('CLIADULT')
	USE IN CLIADULT
ENDIF
IF USED('ADULTCUR')
	USE IN ADULTCUR
ENDIF
IF USED('DUMMY')
	USE IN DUMMY
ENDIF

Return

