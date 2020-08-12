Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              From_Date , ;         && from date
              To_Date, ;            && to date   
              CritN , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)
cCSite    = ""
lcProg    = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gchelp
gchelp    = "Outcome Indicators Report Screen"
cTitle = "Outcome Indicators Report"
cDate = DATE()
cTime = TIME()
**********************  Grab the Data to Report here ************************
* note: serv_cat may or may not be used in outcome table as a linking field, so link on it if its there, else simply rely on outcome.code
SELECT ;
		a.program,	; 	
		d.descript	AS ProgDesc, ;
      a.site,		;
      e.descript1	AS SiteDesc, ;
		a.tc_id,	;
		b.service,	;
		b.outcome,	;
		c.descript  AS OutDesc;	
	FROM ;
		ai_enc	a,	;
		ai_serv b,	;
		outcome c,	;
		program d,	;
		site	e	;
	WHERE ;
        a.program  = lcProg		;
    AND ;
    	a.site     = cCSite    	;
	AND ;
		a.act_dt BETWEEN From_Date AND To_Date   	;
	AND ;
	    a.act_id   = b.act_id	;
	AND ;
	    b.outcome = c.code;
	AND ;
	    (b.serv_cat = c.serv_cat OR EMPTY(c.serv_cat)) ;
	AND ;
		a.program  = d.prog_id   ;
	AND ;
		a.site     = e.site_id	;
    INTO CURSOR ;
    	tTemp1 ;
    ORDER BY ;		
		1, 3									

* BK 07/22/99 - outcome field increased to 3 char
*-*	    b.outcome = LEFT(c.code,2);


* now, count unduplicated clients per outcome
SELECT;
		program, 	;
		progdesc, 	;
		site,		;
		sitedesc, 	;
    	COUNT(DIST tc_id) AS undupcli,	;
		outcome,    ;
		outdesc     ;
	FROM ;
		tTemp1 ;
	INTO CURSOR ;
	    tTemp2 ;
	GROUP BY ;
		1, 3, 6, 2, 4, 7 

* now, count services per outcome		
SELECT;
		program, 	;
		progdesc, 	;
		site,		;
		sitedesc, 	;
    	COUNT(*) AS servcount,	;
		outcome,    ;
		outdesc     ;
	FROM ;
		tTemp1 ;
	INTO CURSOR ;
	    tTemp3 ;
	GROUP BY ;
		1, 3, 6, 2, 4, 7

* combine tTemp2 and tTemp3 info
SELECT ;
		a.program, 		;
		a.progdesc, 	;
		a.site,			;
		a.sitedesc, 	;
		a.undupcli,		;
    	b.servcount,	;
		a.outcome,    	;
		a.outdesc     	;
	FROM ;
		tTemp2 A, tTemp3 B ;
    WHERE ;		
    	a.program = b.program ;
    AND ;	
        a.site    = b.site ;
    AND ;
        a.outcome = b.outcome ;
	INTO CURSOR ;
	    tTemp4 
       **;
**	GROUP BY ;
	**	1, 3, 7

* now, lets create a cursor with zeros for every prog+site+outcome combination
SELECT DISTINCT   ;
      a.program,  ;
      a.progdesc, ;
      a.site,     ;
      a.sitedesc, ;
      0000000000  AS undupcli, ;
      0000000000  AS servcount, ; 
      b.code      AS outcome, ;
      b.Descript  AS outdesc ;
  FROM ;          
      tTemp4 a, outcome b ;
  INTO CURSOR;
      zerofill

* BK 07/22/99 - outcome field increased to 3 char
*-*      LEFT(b.code,2) AS outcome,  ;

* now, lets merge tTemp4 with rest of outcomes that have zero count
SELECT * ;
  FROM tTemp4 ;
UNION ;
SELECT * ;
  	FROM ;
       zerofill ;
  	WHERE ;
       program+site+outcome ;
    NOT IN ;
	    (SELECT program+site+outcome FROM tTemp4)	;
	INTO CURSOR ;
		tTemp15 ;
	ORDER BY ;
		4, 2, 8		

If Used('tTemp5') 
   Use in tTemp5
EndIf
   
Select    *, ;
         lcTitle as lcTitle, ;
         CritN as  Crit, ;   
         cDate as cDate, ;
         cTime as cTime, ;
         From_Date as Date_From, ;
         To_Date as Date_To;   
from tTemp15 ;
into cursor tTemp5 ;
ORDER BY ;
      4, 2, 8      
      
Use in tTemp15
Use in zerofill
Use in tTemp4
Use in tTemp3
Use in tTemp2
Use in tTemp1
************************ Print the Report ***********************************
oApp.Msg2User('OFF')
Select tTemp5 

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
           gcRptName = 'rpt_outc_ny'
           DO CASE
               CASE lPrev = .f.
                  Report Form rpt_outc_ny  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_outc_ny', 1, 2)
           ENDCASE
EndIf
* close tables
IF USED('ai_enc')
   USE in ai_enc
ENDIF
IF USED('ai_serv')
   USE in ai_serv
ENDIF
IF USED('outcome')
   USE in outcome
ENDIF
IF USED('site')
   USE in site
ENDIF
IF USED('program')
   USE in program
ENDIF

RETURN