Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              From_Date , ;         && from date
              To_date, ;            && to date   
              CritNC , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)
cCSite    = ""
lcProg    = ""
lcserv    = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CENCTYPE"
      cEncType = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gchelp
gchelp    = "Connecticut Outcome Indicators Report Screen"
cTitle = "Connecticut Outcome Indicators Report"
cDate = DATE()
cTime = TIME()
**********************  Grab the Data to Report here ************************
* note: serv_cat may or may not be used in outcome table as a linking field, so link on it if its there, else simply rely on outcome.code
SELECT ;
		a.program,	; 	
		d.descript	AS ProgDesc, ;
		a.serv_cat, ;
		f.descript  AS ServCatDes, ;
		a.tc_id,	;
		b.service,	;
		b.outcome,	;
		c.descript  AS OutDesc;	
	FROM ;
		ai_enc	a,	;
		ai_serv b,	;
		outcome c,	;
		program d,	;
		serv_cat f ;
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
		a.serv_cat = f.code ;
	AND ;
		A.serv_cat = lcServ ;	
    INTO CURSOR ;
    	tTemp1 ;
    ORDER BY ;		
		1, 3, 5									

* now, count unduplicated clients per outcome
SELECT;
		program, 	;
		progdesc, 	;
		serv_cat,   ;
		servcatdes, ;
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
		serv_cat,   ;
		servcatdes, ;
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
		a.serv_cat,     ;
		a.servcatdes,   ;
		a.undupcli,		;
    	b.servcount,	;
		a.outcome,    	;
		a.outdesc     	;
	FROM ;
		tTemp2 A, tTemp3 B ;
    WHERE ;
    	a.serv_cat = b.serv_cat ;		
    AND ;	
    	a.program = b.program ;
    AND ;
        a.outcome = b.outcome ;
	INTO CURSOR ;
	    tTemp4 
       *;
*	GROUP BY ;
*		1, 3, 7 
		
*now, lets create a cursor with zeros for every prog+serv_cat+outcome combination
SELECT DISTINCT   ;
      a.program,  ;
      a.progdesc, ;
	  a.serv_cat, ;
	  a.servcatdes, ;
      0000000000  AS undupcli, ;
      0000000000  AS servcount, ; 
      b.code      AS outcome, ;
      b.Descript  AS outdesc ;
  FROM ;          
      tTemp4 a, outcome b ;
  INTO CURSOR;
      zerofill

* now, lets merge tTemp4 with rest of outcomes that have zero count
SELECT * ;
  FROM tTemp4 ;
UNION ;
SELECT * ;
  	FROM ;
       zerofill ;
  	WHERE ;
       program+serv_cat+outcome ;
    NOT IN ;
	    (SELECT program+serv_cat+outcome FROM tTemp4)	;
	INTO CURSOR ;
		tTemp15 ;
	ORDER BY ;
		1, 3, 7
   
If Used('tTemp5') 
   Use in tTemp5
Endif     
Select    *, ;
         lcTitle as lcTitle, ;
         CritNC as  Crit, ;   
         cDate as cDate, ;
         cTime as cTime, ;
         From_Date as Date_From, ;
         To_Date as Date_To;   
from tTemp15 ;
into cursor tTemp5 ;
ORDER BY ;
      1, 3, 7     
      
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
            gcRptName = 'rpt_outc_ct'
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_outc_ct  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_outc_ct', 1, 2)
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
IF USED('program')
   USE in program
ENDIF
IF USED('serv_cat')
   USE in serv_cat
ENDIF

RETURN