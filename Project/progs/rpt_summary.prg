Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

lcProgx   = ""
lcState   = ""
lcCounty  = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "LCSTATE"
      lcState = aSelvar2(i, 2)
   EndIf
    If Rtrim(aSelvar2(i, 1)) = "LCCOUNTY"
      lcCounty = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()
**PARAMETER pserv_cat
PRIVATE gchelp
gchelp = "Outreach Summary Report Screen"
cTitle = "Outreach Summary Report"

*PUBLIC pcall_rpt
*pcall_rpt=SPACE(2)
DO CASE
   Case lnStat = 6
         cTitle = "Education, Training and Outreach Summary Report"
         cCategory = "00006"
         **pcall_rpt='OS'
   CASE lnStat = 15
   	**pcall_rpt='OQ'
   	   cTitle = "Outreach Summary Report"
         cCategory = "00015"
   CASE lnStat = 16
   	**pcall_rpt='QT'
   	   cTitle = "Training Summary Report"
         cCategory = "00016"
   CASE lnStat = 17
   	**pcall_rpt='QE'
   	   cTitle = "HCPI Education Summary Report"
         cCategory = "00017"
   CASE lnStat = 18
   	**pcall_rpt='QH'
   	   cTitle = "HCPI Summary Report"
         cCategory = "00018"
   CASE lnStat = 19
   	**pcall_rpt='QO'
   	   cTitle = "Other Interventions Summary Report"
         cCategory = "00019"
ENDCASE

PRIVATE cOldArea, cWhere
cOldArea = ALIAS()

=OpenFile("ai_outr", "act_id")
=OpenFile("ai_outzp", "act_id")

*!*   IF !USED("staffcur")
*!*   	=All_Staff()
*!*   ENDIF

cWhere = IIF(EMPTY(lcProgx)	, "", "program = lcProgx")
cWhere = cWhere + IIF(EMPTY(lcState), "", IIF(!Empty(cWhere),".and.","") + "st = lcState")
** VT 08/05/2008 Dev Tick 4541 
**cWhere = cWhere + IIF(EMPTY(lcCounty), "", IIF(!Empty(cWhere),".and.","") + "cnty_resid = lcCounty")
cWhere = cWhere + IIF(EMPTY(lcCounty), "", IIF(!Empty(cWhere),".and.","") + "county_code = lcCounty .and. st=lcState")

cWhere = cWhere + IIF(EMPTY(Date_from), "", IIF(!Empty(cWhere),".and.","") + " act_dt >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),   "", IIF(!Empty(cWhere),".and.","") + " act_dt <= Date_to")
cWhere = cWhere + IIF(!Empty(cWhere),".and.","") + "ai_outr.serv_cat = cCategory "

** VT 08/05/2008 Dev Tick 4541 
If Used('tmp_st')
   Use in tmp_st
Endif

Select *,;
      Space(3) as county_code,;
      Space(25) as county_desc ;
from ai_outr ;
Into Cursor tmp_st Readwrite

Update  tmp_st;
   Set county_desc =zipcode.countyname, ;
       county_code = county.code ;
from tmp_st ;
      inner join zipcode on ;
         tmp_st.fips_code= zipcode.countyfips ;
      inner join county on ;
            Upper(zipcode.countyname) = Upper(county.descript) and ;
            tmp_st.st = county.state   
  

Update  tmp_st ;
   Set county_desc =zipcode.countyname, ;
        county_code = county.code  ; 
from tmp_st ;
   inner join zipcode on ;
         Left(tmp_st.zip, 5) = zipcode.zipcode ;
       and tmp_st.st = zipcode.statecode ;
       and Empty(tmp_st.fips_code)  ;
    inner join county on ;
            Upper(zipcode.countyname) = Upper(county.descript) and ;
            tmp_st.st = county.state   

* prepare totals
* total demographics
If Used('demo_tot')
   Use in demo_tot
EndIf
   
SELECT ;
	COUNT(*) AS tot_sess,;
	SUM(total     ) AS sum_total  , ;
	SUM(n_males   ) AS sum_males  , ;
	SUM(n_females ) AS sum_female , ;
	SUM(n_transmf ) AS sum_tgmf   , ;
	SUM(n_transfm ) AS sum_tgfm   , ;
	SUM(n_children) AS sum_childr , ;
	SUM(n_adolesc ) AS sum_adoles , ;
	SUM(n_adults  ) AS sum_adults , ;
	SUM(n_white   ) AS sum_white  , ;
	SUM(n_black   ) AS sum_black  , ;
	SUM(n_hispanic) AS sum_hispan , ;
	SUM(n_asian   ) AS sum_asian  , ;
	SUM(n_native  ) AS sum_native , ;
	SUM(n_other   ) AS sum_other  , ;
	SUM(total_unkn) AS sum_unkn,    ;
	SUM(n_20_29) as sum_20_29,    ;
	SUM(n_30_49) as sum_30_49,    ;
	SUM(n_50plus) as sum_50plus,    ;
	Sum(n_hawaisle) as sum_hawaisle, ;
	Sum(n_morthan1) as sum_morthan1, ;
	Sum(n_raceunkn) as sum_raceunkn ;
FROM ;
	tmp_st ai_outr;
WHERE ;
	&cWhere  ;
INTO CURSOR demo_tot

* total materials
If Used('mat_tot')
   Use in mat_tot
EndIf
   
SELECT ;
	PADR(material.descript, 40)     AS col1, ;
	STR(SUM(ai_outmt.quantity),6,0) AS col2, ;
	"01"                            AS LIST,;
	PADR(material.code, 5)          AS order ;
FROM ;
	tmp_st ai_outr, Ai_outmt, material;
WHERE ;
	&cWhere AND ;
	ai_outmt.act_id = ai_outr.act_id AND ;
	ai_outmt.material = material.code;
GROUP BY ;
	1, 3, 4 ;
UNION ALL ;
SELECT ;
	PADR(material.descript, 40)     AS col1, ;
	STR(0,6,0)                      AS col2, ;
	"01"                            AS LIST,;
	PADR(material.code, 5)          AS order ;
FROM ;
	material;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM ;
						tmp_st ai_outr, Ai_outmt ;
					WHERE ;
						&cWhere AND ;
						ai_outmt.act_id = ai_outr.act_id AND ;
						ai_outmt.material = material.code) ;
ORDER BY 4 ;
INTO CURSOR mat_tot

* total services
If Used('serv_tot')
   Use in serv_tot
EndIf
   
SELECT ;
	PADR(outrserv.descript,40) AS col1, ;
	STR(COUNT(*), 6,0)         AS col2, ;
	"02"                       AS LIST,;
	PADR(outrserv.code,5)      AS ORDER ;
FROM ;
	tmp_st ai_outr, Ai_outsp, outrserv;
WHERE ;
	&cWhere AND ;
	Ai_outsp.act_id = ai_outr.act_id AND ;
	ai_outsp.outrserv = outrserv.code AND ;
	outrserv.serv_cat = cCategory ; 
GROUP BY ;
	1, 3, 4 ;
UNION ALL ;
SELECT ;
	PADR(outrserv.descript,40) AS col1, ;
	STR(0, 6,0)                AS col2, ;
	"02"                       AS LIST,;
	PADR(outrserv.code,5)      AS ORDER ;
FROM ;
	outrserv;
WHERE ;
	outrserv.serv_cat = cCategory AND ;	
	PADR(outrserv.descript,40) ;
	  NOT IN (SELECT PADR(outrserv.descript,40) AS col ;
					FROM ;
						tmp_st ai_outr, Ai_outsp, outrserv ;
					WHERE ;
						&cWhere AND ;
						Ai_outsp.act_id = ai_outr.act_id AND ;
						ai_outsp.outrserv = outrserv.code AND ;
						outrserv.serv_cat = cCategory) ;
ORDER BY 4 ;
INTO CURSOR serv_tot

* Special populuations
If Used("out_foc")
   Use in out_foc
EndIf
   
SELECT ;
	PADR(focus.descript,40) AS col1,;
	STR(SUM(ai_outfc.n_part),6,0) AS col2, ;
	"04" AS LIST, ;
	PADR(focus.code, 5)      AS ORDER ;
FROM ;
	tmp_st ai_outr, Ai_outfc, focus;
WHERE ;
	&cWhere AND ;
	Ai_outfc.act_id = ai_outr.act_id AND ;
	ai_outfc.focus = focus.code ;
GROUP BY ;
	1, 3, 4 ;
UNION ALL ;
SELECT ;
	PADR(focus.descript, 40)        AS col1, ;
	STR(0,6,0)                      AS col2, ;
	"04"                            AS LIST,;
	PADR(focus.code, 5)         AS order ;
FROM ;
		focus;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM ;
						tmp_st ai_outr, Ai_outfc;
					WHERE ;
						&cWhere AND ;
						Ai_outfc.act_id = ai_outr.act_id AND ;
						ai_outfc.focus = focus.code ) ;
ORDER BY 1 ;
INTO CURSOR out_foc

* jss, 12/1/03, methods of delivery selection must be modified to only include those associated with serv_cat
dWhere = ''
DO CASE
	CASE cCategory='00015'
		dwhere = 'delivery.eto_flag AND '
	CASE cCategory='00017'
		dwhere = 'delivery.hced_flag AND '
	CASE cCategory='00018'
		dwhere = '(delivery.elect_flag OR delivery.inter_flag OR delivery.print_flag) AND '
ENDCASE

* methods of delivery
If Used("out_md")
   Use in out_md
EndIf
   

*!*   SELECT ;
*!*   	PADR(delivery.descript,40) AS col1,;
*!*   	STR(COUNT(*), 6,0)         AS col2, ;
*!*   	"03" AS LIST, ;
*!*   	PADR(delivery.code,5)         AS ORDER ;
*!*   FROM ;
*!*   	ai_outr, ai_outmd, delivery;
*!*   WHERE ;
*!*   	&cWhere AND ;
*!*   	Ai_outmd.act_id = ai_outr.act_id AND ;
*!*   	ai_outmd.code = delivery.code ;
*!*   GROUP BY ;
*!*   	1, 3, 4 ;
*!*   UNION ALL ;
*!*   SELECT ;
*!*   	PADR(delivery.descript, 40)     AS col1, ;
*!*   	STR(0,6,0)                      AS col2, ;
*!*   	"03"                            AS LIST,;
*!*   	PADR(delivery.code, 5)          AS order ;
*!*   FROM ;
*!*   		delivery;
*!*   WHERE ;
*!*   	&dWhere ;
*!*   	NOT EXIST (SELECT * ;
*!*   					FROM ;
*!*   						ai_outr, Ai_outmd;
*!*   					WHERE ;
*!*   						&cWhere AND ;
*!*   						Ai_outmd.act_id = ai_outr.act_id AND ;
*!*   						ai_outmd.code = delivery.code ) ;
*!*   ORDER BY 4 ;
*!*   INTO CURSOR out_md

**03/07/2006 Larry devel ticket# 1571  
SELECT ;
   PADR(delivery.descript,40) AS col1,;
   STR(COUNT(*), 6,0)         AS col2, ;
   "03" AS LIST, ;
   PADR(delivery.code,5)         AS ORDER ;
FROM ;
   tmp_st ai_outr, ai_outmd, delivery;
WHERE ;
   &cWhere AND ;
   Ai_outmd.act_id = ai_outr.act_id AND ;
   ai_outmd.code = delivery.code ;
GROUP BY ;
   1, 3, 4 ;
ORDER BY 4 ;
INTO CURSOR out_md

* target groups
If Used("out_tar")
   Use in out_tar
EndIf
   
SELECT ;
	PADR(target.descript,40) AS col1,;
	STR(COUNT(*), 6,0)         AS col2, ;
	"07" AS LIST, ;
	PADR(target.code,5)         AS ORDER ;
FROM ;
	tmp_st ai_outr, target;
WHERE ;
	&cWhere AND ;
	ai_outr.target_grp = target.code ;
GROUP BY ;
	1, 3, 4 ;
UNION ALL ;
SELECT ;
	PADR(target.descript, 40)     AS col1, ;
	STR(0,6,0)                    AS col2, ;
	"07"                          AS LIST, ;
	PADR(target.code, 5)          AS order ;
FROM ;
		target;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM ;
						tmp_st ai_outr ;
					WHERE ;
						&cWhere AND ;
							ai_outr.target_grp = target.code ) ;
ORDER BY 1 ;
INTO CURSOR out_tar

** CDC Risk Focus
If Used("out_risk")
   Use in out_risk
EndIf
   
SELECT ;
	PADR(cdc_risk.descript,40) AS col1,;
	STR(COUNT(*), 6,0)         AS col2, ;
	"08" AS LIST, ;
	PADR(cdc_risk.code,5)         AS ORDER ;
FROM ;
	tmp_st ai_outr, cdc_risk;
WHERE ;
	&cWhere AND ;
	ai_outr.cdcriskfoc = cdc_risk.code ;
GROUP BY ;
	1, 3, 4 ;
UNION ALL ;
SELECT ;
	PADR(cdc_risk.descript, 40)     AS col1, ;
	STR(0,6,0)                    AS col2, ;
	"08"                          AS LIST, ;
	PADR(cdc_risk.code, 5)          AS order ;
FROM ;
		cdc_risk;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM ;
						tmp_st ai_outr ;
					WHERE ;
						&cWhere AND ;
							ai_outr.cdcriskfoc = cdc_risk.code ) ;
ORDER BY 4 ;
INTO CURSOR out_risk
	
** CDC Location
If Used("out_cdcl")
   Use in out_cdcl
EndIf
   
SELECT ;
	PADR(settings.descript,40) AS col1,;
	STR(COUNT(*), 6,0)         AS col2, ;
	"09" AS LIST, ;
	PADR(settings.code,5)         AS ORDER ;
FROM ;
	tmp_st ai_outr, settings;
WHERE ;
	&cWhere AND ;
	ai_outr.cdcloctype = settings.code ;
GROUP BY ;
	1, 3, 4 ;
UNION ALL ;
SELECT ;
	PADR(settings.descript, 40)     AS col1, ;
	STR(0,6,0)                    AS col2, ;
	"09"                          AS LIST, ;
	PADR(settings.code, 5)          AS order ;
FROM ;
		settings;
WHERE ;
	NOT EXIST (SELECT * ;
					FROM ;
						tmp_st ai_outr ;
					WHERE ;
						&cWhere AND ;
							ai_outr.cdcloctype = settings.code ) ;
ORDER BY 4 ;
INTO CURSOR out_cdcl
	
** The count is not put into string format yet, this is done in next query
** This is a prequery in order to add the same zipcode existing in ai_outr & ai_outzp
** jss, 10/27/03, add case statement to handle "HCPI" (00018) which has no required zip but does have additional zips
If Used("out_zip1")
   Use in out_zip1
EndIf
   
DO CASE
 CASE cCategory='00018'
      	SELECT ;
      		PADR( subs(ai_outzp.zip,1,5) ,40)		AS col1,;
      		COUNT(*)								AS col2, ;
      		"10" 									AS LIST, ;
      		PADR(ai_outzp.zip, 5)					AS ORDER ;
      	FROM ;
      		tmp_st ai_outr, ai_outzp ;
      	WHERE ;
      		&cWhere ;
      		and Ai_outzp.act_id = ai_outr.act_id ;
      	GROUP BY ;
      		1, 3, 4 ;
      	INTO CURSOR out_zip1
         
 OTHERWISE	
 
      	SELECT ;
      		PADR( subs(ai_outzp.zip,1,5) ,40)		AS col1,;
      		COUNT(*)								AS col2, ;
      		"10" 									AS LIST, ;
      		PADR(ai_outzp.zip, 5)					AS ORDER ;
      	FROM ;
      		tmp_st ai_outr, ai_outzp ;
      	WHERE ;
      		&cWhere ;
      		and Ai_outzp.act_id = ai_outr.act_id ;
      	GROUP BY ;
      		1, 3, 4 ;
      	UNION ALL ;
      	SELECT ;
      		PADR( subs(ai_outr.zip,1,5) ,40)		AS col1, ;
      		COUNT(*)								AS col2, ;
      		"10" AS LIST, ;
      		PADR(ai_outr.zip, 5)					AS ORDER ;
      	FROM tmp_st ai_outr ;
      	WHERE ;
      		&cWhere ;
      	GROUP BY ;
      		1, 3, 4 ;
      	INTO CURSOR out_zip1
ENDCASE

** This will do final sum of zipcodes, most will remain the same from the above query,
** but zip codes existing in both ai_outr & ai_outzp will create 2 recs. (They need to be added)
If Used("out_zip")
   Use in out_zip
EndIf
   
SELECT ;
	IIF(!EMPTY(col1), col1, PADR("ZIP Code not entered",40)) AS col1, ;
	STR(SUM(col2), 6,0) AS col2, ;
	list, ;
	order ;
FROM out_zip1 ;
GROUP BY 1, 3, 4 ;
ORDER BY 4 ;
INTO CURSOR out_zip

* jss, 10/24/03, add case statement to handle training (00016, no methods of delivery) and hcpi education (00017, no services, targets)
If Used('t_temp')
   Use in t_temp
EndIf
   
DO CASE
   Case cCategory='00006' &&Education, Training and Outreach 
            SELECT *;
            FROM mat_tot ;
            UNION ALL;
            SELECT *;
            FROM out_md ;
            UNION ALL;
            SELECT *;
            FROM out_foc;
            UNION ALL;
            SELECT *;
            FROM serv_tot ;
            UNION ALL;
            SELECT *;
            FROM out_tar ;
            UNION ALL;
            SELECT *;
            FROM out_risk ;
            UNION ALL;
            SELECT *;
            FROM out_cdcl ;
            UNION ALL;
            SELECT *;
            FROM out_zip ;
            INTO CURSOR t_temp
   
CASE cCategory='00015'		&& outreach
         	SELECT *;
         	FROM mat_tot ;
         	UNION ALL;
         	SELECT *;
         	FROM out_md ;
         	UNION ALL;
         	SELECT *;
         	FROM out_foc;
         	UNION ALL;
         	SELECT *;
         	FROM serv_tot ;
         	UNION ALL;
         	SELECT *;
         	FROM out_tar ;
         	UNION ALL;
         	SELECT *;
         	FROM out_risk ;
         	UNION ALL;
         	SELECT *;
         	FROM out_cdcl ;
         	UNION ALL;
         	SELECT *;
         	FROM out_zip ;
           	INTO CURSOR t_temp
              
         CASE cCategory='00016'		&& training
         	SELECT * ;
         	FROM ;
         		mat_tot ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_foc;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		serv_tot ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_tar ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_risk ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_cdcl ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_zip ;
           	INTO CURSOR t_temp
CASE cCategory='00017' 		&& hcpi education
         	SELECT *;
         	FROM ;
         		mat_tot ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_md ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_foc;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_risk ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_cdcl ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_zip ;
           	INTO CURSOR t_temp
CASE cCategory='00018' 			&& hcpi
         	SELECT *;
         	FROM ;
         		mat_tot ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_md ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_risk ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_cdcl ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_zip ;
         	INTO CURSOR t_temp
CASE cCategory='00019' 			&& other interventions
         	SELECT *;
         	FROM ;
         		out_foc;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_risk ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_cdcl ;
         	UNION ALL;
         	SELECT *;
         	FROM ;
         		out_zip ;
         	INTO CURSOR ;
         		t_temp
ENDCASE

If Used("temp")
   Use in temp
EndIf
   
Select *, ;
      GetHeader(list) as header_desc,;
      GetTitle(list) as title_desc, ;
      cTitle as cTitle, ;
      Crit as  Crit, ;   
      cDate as cDate, ;
      cTime as cTime, ;
      Date_from as Date_from, ;
      date_to as date_to;   
from t_temp ;
Order by 3 ;
Into Cursor temp

oApp.Msg2User('OFF')

IF RECCOUNT("demo_tot") = 0
	oApp.msg2user('NOTFOUNDG')
ELSE
   
	DO CASE
      Case InList(cCategory , '00006', '00015', '00016', '00017') 
           gcRptName = 'rpt_summary'      
           DO CASE
              CASE lPrev = .f.
                  Report Form rpt_summary  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_summary', 1, 2)
            ENDCASE
   	
    	CASE InList(cCategory, '00018', '00019')
          gcRptName = 'rpt_sum_hcot'
   		 DO CASE
              CASE lPrev = .f.
                  Report Form rpt_sum_hcot  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_sum_hcot', 1, 2)
          ENDCASE
	ENDCASE
ENDIF

*******************************************************************
FUNCTION GetHeader
Parameters cList
DO CASE
CASE cList = "01"
	RETURN(PADR("MATERIALS PROVIDED",50))
CASE cList = "02"
* jss, 10/24/03, add code here to handle training (has 'TOPICS', not 'SERVICES')
	DO CASE
	CASE cCategory='00016'
		RETURN(PADR("TOPICS",50))
	OTHERWISE
		RETURN(PADR("SERVICES PROVIDED",50))
	ENDCASE	
CASE cList = "03"
	RETURN "METHOD(S) OF DELIVERY"
CASE cList = "04"
	RETURN(PADR("OTHER TARGETED POPULATION(S)",50))
CASE cList = "07"
	RETURN (PADR("TARGET GROUPS", 50))
CASE cList = "08"
	RETURN (PADR("RISK FOCUS", 50))
CASE cList = "09"
	RETURN (PADR("CDC LOCATION", 50))
CASE cList = "10"
	RETURN (PADR("ZIP CODES", 50))
OTHERWISE
	RETURN(SPACE(50))
ENDCASE

*******************************************************************
FUNCTION GetTitle
Parameters tList
DO CASE
CASE tList = "01"
	RETURN "MATERIAL                                                               QUANTITY"
CASE tList = "02"
* jss, 10/24/03, add code here to handle training (has 'TOPICS', not 'SERVICES')
	DO CASE
	CASE cCategory='00016'
		RETURN "TOPIC                                                               QUANTITY"	
	OTHERWISE
		RETURN "SERVICE                                                             QUANTITY"
	ENDCASE
CASE tList = "04"
	RETURN "TYPE                                               APPROX # OF PARTICIPANTS"
CASE tList = "07"
	RETURN "TARGET                                                                 QUANTITY"
CASE tList = "08"
	RETURN "CDC RISK FOCUS                                                         QUANTITY"
CASE tList = "09"
	RETURN "TYPE                                                                   QUANTITY"
CASE tList = "10"
	RETURN "ZIP CODE                                                               QUANTITY"
OTHERWISE
	RETURN(SPACE(100))
ENDCASE

