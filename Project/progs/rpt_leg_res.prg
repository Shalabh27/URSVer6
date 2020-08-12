Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              ParamCr , ;              && name of param
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
* jss, 4/22/04, legal services module: client's county of residence report
PRIVATE gchelp
gchelp = "Legal Services Client's County of Residence Report Screen"
cTitle="Legal Services Client's County of Residence Report"
* clients with active cases at the start of the period
=clean_data()
 
If Used('ActBeg')
   Use in ActBeg
Endif   

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query

*|* SELECT DISTINCT;
*|* 	tc_id  ;
*|* FROM ;
*|* 	ai_enc ;
*|* WHERE ;
*|* 	serv_cat = '00021' AND ;
*|* 	program = lcprogx  AND ;
*|* 	act_dt < date_from AND ;
*|* 	(caseclosdt >= date_from OR ;
*|* 	 EMPTY(caseclosdt)) ;	
*|* GROUP BY ;
*|* 	tc_id ;
*|* INTO CURSOR ActBeg

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
	act_dt < date_from AND ;
	(caseclosdt >= date_from OR ;
	 EMPTY(caseclosdt)) ;	
GROUP BY ;
	ai_enc.tc_id ;
INTO CURSOR ActBeg

** GOxford END 3/28/12

* clients enrolled in a case this period
If Used('EnrInPer')
   Use in EnrInPer
Endif   

** GOxford 03/28/2012 AIRS-133
** Added inner join to client via ai_clien to ensure that only valid client records are counted in this query

*|* SELECT DISTINCT;
*|* 	tc_id  ;
*|* FROM ;
*|* 	ai_enc ;
*|* WHERE ;
*|* 	serv_cat = '00021' AND ;
*|* 	program = lcprogx  AND ;
*|* 	act_dt >= date_from AND ;
*|* 	act_dt <= date_to	;
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
	serv_cat = '00021' AND ;
	program = lcprogx  AND ;
	act_dt >= date_from AND ;
	act_dt <= date_to	;
GROUP BY ;
	ai_enc.tc_id ;
INTO CURSOR EnrInPer

** GOxford END 3/28/12

* clients NEWLY enrolled in a case in period
If Used('NewEnr1')
   Use in NewEnr1
Endif  

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
*!*	      distinct ai_enc.tc_id  ;
*!*	FROM ;
*!*	   ai_enc ;
*!*	      Inner Join NewEnr1 On ;
*!*	         ai_enc.tc_id = NewEnr1.tc_id ;
*!*	WHERE ;
*!*	   ai_enc.serv_cat = '00021' AND ;
*!*	   ai_enc.program = lcprogx  AND ;
*!*	   ai_enc.act_dt >= date_from AND ;
*!*	   ai_enc.act_dt <= date_to   ;
*!*	  and ai_enc.tc_id + ai_enc.program Not In ;
*!*	                  (SELECT ai_prog.tc_id + ai_prog.program ;
*!*	                     FROM ai_prog ;
*!*	                     WHERE ;
*!*	                        ai_prog.start_dt < date_from ;
*!*	                     GROUP BY ;
*!*	                        ai_prog.tc_id, ai_prog.program) ;
*!*	GROUP BY ;
*!*	   ai_enc.tc_id ;
*!*	INTO CURSOR ;
*!*	   NewEnr

** GOxford 03/28/2012 AIRS-133
** Removed WHERE condition:
**  and (caseclosdt < Date_from OR ;
**	 EMPTY(caseclosdt)) ;
** (It was causing the SELECT to miss any new clients whose case(s) ended within the time period)

*!* SELECT ;
*!*      Distinct ai_enc.tc_id  ;
*!* FROM ;
*!*    ai_enc ;
*!*       Inner Join NewEnr1 On ;
*!*          ai_enc.tc_id = NewEnr1.tc_id ;
*!* WHERE ;
*!*   ai_enc.serv_cat = '00021' AND ;
*!*   ai_enc.program = lcprogx  AND ;
*!*   ai_enc.act_dt >= Date_from AND ;
*!*   ai_enc.act_dt <= Date_to   ;
*!*   and (caseclosdt < Date_from OR ;
*!* 	 EMPTY(caseclosdt)) ;
*!* GROUP BY ;
*!*    ai_enc.tc_id ;
*!* INTO CURSOR ;
*!*    NewEnr
**VT END 

 SELECT ;
      Distinct ai_enc.tc_id  ;
FROM ;
   ai_enc ;
      Inner Join NewEnr1 On ;
         ai_enc.tc_id = NewEnr1.tc_id ;
WHERE ;
  ai_enc.serv_cat = '00021' AND ;
  ai_enc.program = lcprogx  AND ;
  ai_enc.act_dt >= Date_from AND ;
  ai_enc.act_dt <= Date_to   ;
GROUP BY ;
   ai_enc.tc_id ;
INTO CURSOR ;
   NewEnr
   
** GOxford END 3/28/12

* now, we will count the new clients by their county
If Used('tNewCli')
   Use in tNewCli
Endif  

*!*   SELECT ;
*!*   	aicl.Tc_id,  ;
*!*   	addr.county, ;
*!*   	addr.st ;
*!*   FROM ;
*!*   	client 	cl,  ;
*!*   	ai_clien aicl,;
*!*   	cli_hous clih,;
*!*   	address 	addr ;
*!*   WHERE ;
*!*   	aicl.tc_id IN (SELECT tc_id FROM NewEnr) 	AND ;
*!*   	aicl.client_id = cl.client_id 				AND ;
*!*   	aicl.client_id = clih.client_id 				AND ;
*!*   	clih.lives_in 										AND ;
*!*   	clih.primary 										AND ;
*!*   	clih.hshld_id=addr.hshld_id 					AND ;
*!*   	addr.addr_id IN (SELECT MAX(addr2.addr_id) FROM address addr2 WHERE addr2.hshld_id=addr.hshld_id) ; 
*!*   INTO CURSOR ;	
*!*   	tNewCli

Select distinct ;
         aicl.Tc_id,  ;
         addr.county, ;
         addr.st, ;
         addr.zip, ;
         Iif(!Empty(addr.st) and !Empty(addr.zip), zipcode.countyname , ;
                             Iif((Empty(addr.st) or Empty(addr.zip)), 'County Not Entered',;
                             'Unknown/Out of Region') ) as countydesc, ;
          Iif(!Empty(addr.st) and !Empty(addr.zip), "A", ;
                             Iif((Empty(addr.st) or Empty(addr.zip)), 'C',;
                             'B') ) as sorter  ;                             
From   client    cl ;
      inner join  ai_clien aicl on ;
               aicl.client_id = cl.client_id ;
      inner join address    addr on  ;
            aicl.client_id=addr.client_id ;
      left outer join  zipcode  on ;
            addr.zip = zipcode.zipcode and ;
            addr.st = zipcode.statecode and ;
            addr.fips_code = zipcode.countyfips;
Where aicl.tc_id IN (SELECT tc_id FROM NewEnr) ;
into CURSOR tNewCli readwrite
   
Update tNewCli;
   set countydesc ='Unknown/Out of Region', ;
        sorter  = 'B' ;
from tnewcli ;
where Empty(countydesc) or countydesc is null

If Used('tNewCli2')
   Use in tNewCli2
Endif 

If Used('NewCli1')
   Use in NewCli1
Endif 
	
SELECT ;
	sorter, ;
	countydesc, ;
	COUNT(*) AS countytot ;
FROM ;
	tNewCli ;
GROUP BY ;
	1,2 ;
INTO CURSOR ;
	tNewCli2

oApp.ReopenCur('tNewCli2','NewCli1')
**=OpenFile("county","statecode")

**=GetCounty()

If Used('NewCli')
   Use in NewCli
EndIf

SELECT NewCli1.*, ;
       ParamCr as  Crit, ;   
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from as Date_from, ;
       date_to as date_to;      
from NewCli1 ;
into cursor NewCli ;
order by NewCli1.sorter, NewCli1.countydesc



oApp.msg2user('OFF')
gcRptName = 'rpt_leg_res'          
GO TOP
IF EOF()
     oApp.msg2user('NOTFOUNDG')
Else
     DO CASE
         CASE lPrev = .f.
              Report Form rpt_leg_res To Printer Prompt Noconsole NODIALOG 
          CASE lPrev = .t.     &&Preview
              oApp.rpt_print(5, .t., 1, 'rpt_leg_res', 1, 2)
     ENDCASE   
EndIf
***************************************
Function clean_data

IF USED('AI_ENC')
	USE IN AI_ENC
ENDIF
IF USED('ACTBEG')
	USE IN ACTBEG
ENDIF
IF USED('ENRINPER')
	USE IN ENRINPER
ENDIF
IF USED('NEWENR')
	USE IN NEWENR
ENDIF
IF USED('TNEWCLI')
	USE IN TNEWCLI
ENDIF
IF USED('NEWCLI')
	USE IN NEWCLI
ENDIF
IF USED('COUNTY')
	USE IN COUNTY
ENDIF

IF USED('ZIPCODE')
   USE IN zipcode
ENDIF
RETURN

******************
FUNCTION GetCounty
******************
SELECT newcli1

tCountyDsc=SPACE(25)
tSorter=SPACE(1)

Select NewCli1
SCAN
	IF !EMPTY(NewCli1.county)
		**IF SEEK(st+county, 'county')
      Select County
      Locate for NewCli1.county = county.code and NewCli1.st =county.state
      If Found()
			tCountyDsc = county.descript
			tSorter = 'A'
		ELSE
			tCountyDsc ='Unknown/Out of Region'	
			tSorter = 'B'
		ENDIF	
	ELSE
		tCountyDsc='County Not Entered'
		tSorter = 'C'
	EndIf
   Select NewCli1
	REPLACE 	NewCli1.countydesc 	WITH tCountyDsc, ;
				NewCli1.sorter		WITH tSorter
   
ENDSCAN

RETURN 

