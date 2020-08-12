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


* jss, 12/26/06, uncomment code related to the 
*                1) ADHC Attendance Billing Report ('UE', serv_cat='00004') and the 
*                2) COBRA Services Billing Report  ('CB', serv_cat='00001')
*       also, make modifications to utilize property .crepid in uncommented code

cTC_ID   = ""
lcProg   = ""
cCSite   = ""
lcServ   = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "CTC_ID"
      cTc_id = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCsite = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcServ = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

nMon = 0
nDat  = 0

*!*   IF TYPE("cReport_ID") <> "C" OR EMPTY(cReport_ID)
*!*   	cReport_ID = "EB"
*!*   ENDIF

DO CASE
PRIVATE gchelp
CASE .cRepId = "CB"
	cTitle = "COBRA Services Billing Report"
   gchelp = "COBRA Services Billing Report Screen"
CASE .cRepId = "UE"
	cTitle = "ADHC Attendance Billing Report"
	gchelp = "ADHC Attendance Billing Report Screen"	
OTHERWISE
	cTitle = "Encounters and Services Billing Report"
	gcHelp = "Encounters and Services Billing Report Screen"
ENDCASE


*!*   IF EMPTY(Date_to)
*!*   	Date_to = {01/01/2100}
*!*   ENDIF

SELE staffcur
SET ORDER TO worker_id

* jss, 1/16/06, move this next if statement from above "sele staffcur" because
*               date_to was showing as falsely empty there but is ok here
IF EMPTY(Date_to)
   Date_to = {01/01/2100}
ENDIF

=OpenFile("es_bill", "act_serv")


DO CASE
CASE .cRepId = "CB"
	lcServ = "00001"
CASE .cRepId = "UE"
	lcServ = "00004"
ENDCASE

cWhere = ''

IF !EMPTY(cTC_ID)
	cWhere = "ai_enc.tc_id = cTC_ID"
ENDIF

IF !EMPTY(lcProg)
	cWhere = cWhere + IIF(!EMPTY(cWhere), " AND ","") + "ai_enc.program = lcProg"
ENDIF

IF !EMPTY(cCSite)
	cWhere = cWhere + IIF(!EMPTY(cWhere), " AND ","") + "ai_enc.site = cCSite"
ENDIF

IF !EMPTY(cWhere)
	cWhere = cWhere + " AND "
ENDIF

cTC_ID = TRIM(cTC_ID)
lcProg = TRIM(lcProg)
cCSite = TRIM(cCSite)

If Used('temp1')
   Use in temp1   
EndIf

LCTITLE = REPTITLE(.cRepId)

*!*      'Encounters / Services '  +Iif(nGroup = 2, "Not Billed to Medicaid",  ;
*!*               Iif(nGroup = 3, "Billed to Medicaid","Billing Report")) as lcTitle,;   

* jss, 3/9/07, add new field time24 using service start time to use for sort instead of act_id
SELECT ;
	ai_enc.serv_cat, ;
	ai_enc.program, ;
	ai_enc.site, ;
	UPPER(PADR(LTRIM(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)),40)) AS name, ;
	cli_cur.id_no, ;
	ai_enc.act_dt, ;
   oApp.Time24(ai_serv.s_beg_tm, ai_serv.s_beg_am) as Time24, ;
	ai_enc.act_id, ;
	ai_enc.enc_type, ;
	LOWER(TRANSFORM(ai_enc.beg_tm+ai_enc.beg_am,"@R 99:99XX") + ;
	"-" + TRANSFORM(ai_enc.end_tm+ai_enc.end_am,"@R 99:99XX")) AS e_time, ;
	FormHours(TimeSpent(ai_enc.beg_tm, ai_enc.beg_am, ;
	ai_enc.end_tm, ai_enc.end_am)) AS e_total, ;
	LOWER(TRANSFORM(ai_serv.s_beg_tm+ai_serv.s_beg_am,"@R 99:99XX") + ;
	"-" + TRANSFORM(ai_serv.s_end_tm+ai_serv.s_end_am,"@R 99:99XX")) AS s_time, ;
	FormHours(TimeSpent(ai_serv.s_beg_tm, ai_serv.s_beg_am, ;
	ai_serv.s_end_tm, ai_serv.s_end_am)) AS s_total, ;
	ai_serv.serv_id, ;
	ai_serv.service_id, ;
   serv_cat.descript as serv_cat_desc, ;   
   lcTitle as lcTitle,;   
   program.descript as prog_desc, ; 
   site.descript1 as site_desc, ;    
   enc_list.description as enc_desc, ;      
   serv_list.description as serv_desc, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as date_from,;
   Date_to as date_to ;
FROM ;
	ai_enc, ai_serv, cli_cur, serv_cat, program, site, enc_list, serv_list  ;
WHERE ;
	ai_enc.tc_id    = cTC_ID AND ;
	ai_enc.program  = lcProg AND ;
	ai_enc.site     = cCSite AND ;
	cli_cur.tc_id   = ai_enc.tc_id AND ;
	ai_enc.serv_cat = lcServ AND ;
	BETWEEN(act_dt, date_from, date_to) AND ;
	ai_enc.act_id	= ai_serv.act_id and;
   ai_enc.serv_cat = serv_cat.code and ;
   ai_enc.program = program.prog_id and;
   ai_enc.site = site.site_id and ;
   ai_enc.enc_id = enc_list.enc_id and ;
   ai_serv.service_id = serv_list.service_id ;
INTO CURSOR ;
	temp1

If Used('temp2')
   Use in temp2
EndIf

* jss, 3/9/07, add new field time24 using encounter start time to use for sort instead of act_id
SELECT ;
	ai_enc.serv_cat, ;
	ai_enc.program, ;
	ai_enc.site, ;
	UPPER(PADR(LTRIM(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)),40)) AS name, ;
	cli_cur.id_no, ;
	ai_enc.act_dt, ;
   oApp.Time24(ai_enc.beg_tm, ai_enc.beg_am) as Time24, ;
	ai_enc.act_id, ;
	ai_enc.enc_type, ;
	LOWER(TRANSFORM(ai_enc.beg_tm+ai_enc.beg_am,"@R 99:99XX") + ;
	"-" + TRANSFORM(ai_enc.end_tm+ai_enc.end_am,"@R 99:99XX")) AS e_time, ;
	FormHours(TimeSpent(ai_enc.beg_tm, ai_enc.beg_am, ;
	ai_enc.end_tm, ai_enc.end_am)) AS e_total, ;
	SPACE(15) AS s_time, ;
	SPACE(5)  AS s_total, ;
	SPACE(10) AS serv_id, ;
	0000  AS service_id, ;
   serv_cat.descript as serv_cat_desc, ;
   lcTitle as lcTitle,;   
   program.descript as prog_desc, ;  
   site.descript1 as site_desc, ;  
   enc_list.description as enc_desc, ; 
   Space(80) as serv_desc, ;           
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as date_from,;
   Date_to as date_to ; 
FROM ;
	ai_enc, cli_cur,serv_cat, program, site, enc_list ;
WHERE ;
	ai_enc.tc_id	= cTC_ID AND ;
	ai_enc.program	= lcProg AND ;
	ai_enc.site		= cCSite AND ;
	cli_cur.tc_id	= ai_enc.tc_id AND ;
	ai_enc.serv_cat = lcServ AND ;
	BETWEEN(act_dt, date_from, date_to) AND ;
   ai_enc.serv_cat = serv_cat.code and ;
   ai_enc.program = program.prog_id and ;
   ai_enc.site = site.site_id and ;
   ai_enc.enc_id = enc_list.enc_id and ;
	NOT EXISTS (SELECT * FROM ai_serv WHERE ai_enc.act_id = ai_serv.act_id) ;
INTO CURSOR ;
	temp2

If Used('es_tmp')
   Use in es_tmp
EndIf

Select * ;
From temp1 ;
Union All ;
Select * ;
From temp2 ;
Order By ;
   1, 2, 3, 4, 6, 7 ;
Into Cursor   es_tmp

SET RELATION TO act_id + serv_id INTO es_bill

cFiltExpr = ""
DO CASE
CASE nGroup = 2
	cFiltExpr = '!FOUND("es_bill")'
CASE nGroup = 3
	cFiltExpr = 'FOUND("es_bill")'
ENDCASE
SET FILTER TO &cFiltExpr

LOCATE

oApp.msg2user('OFF')

IF !FOUND()
   oApp.msg2user('NOTFOUNDG')
Else
* jss, 12/26/06, create case statement below: 
*                for 'ADHC Attendance', use 'rpt_adhcattr'
*                for 'Encounters / Services' or 'COBRA Services', use 'rpt_enc_bill'
   Do CASE    
   CASE .cRepID='UE'
      gcRptName = 'rpt_adhcattr'

      DO CASE
         CASE lPrev = .f.
                     Report Form rpt_adhcattr To Printer Prompt Noconsole NODIALOG 
         CASE lPrev = .t.     
                     oApp.rpt_print(5, .t., 1, 'rpt_adhcattr', 1, 2)
      ENDCASE

   OTHERWISE
      gcRptName = 'rpt_enc_bill'

      DO CASE
         CASE lPrev = .f.
                     Report Form rpt_enc_bill To Printer Prompt Noconsole NODIALOG 
         CASE lPrev = .t.     
                     oApp.rpt_print(5, .t., 1, 'rpt_enc_bill', 1, 2)
      ENDCASE
   ENDCASE   
Endif      

*!*   SET FILTER TO
*!*   SET RELATION TO

*!*   SELECT ai_enc
*!*   SET FILTER TO
*!*   SET RELATION TO


RETURN

* jss, 12/26/06, 1) rename lctitle to xlctitle to avoid confusion with lctitle used above
*                2) add case statement below for ADHC Attendance
FUNCTION REPTITLE
PARAMETERS TCREP_ID
PRIVATE xLCTITLE,LCJUNK
xLCTITLE = ' '
DO CASE
CASE TCREP_ID = 'CB'
	xLCTITLE = "COBRA Services "
	DO CASE
	CASE nGroup = 2
		LCJUNK = "Not Billed to Medicaid"
	CASE nGroup = 3
		LCJUNK = "Billed to Medicaid"
	OTHERWISE
		LCJUNK = "Billing Report"
	ENDCASE
	xLCTITLE = xLCTITLE + LCJUNK
CASE TCREP_ID = 'EB'
   xLCTITLE = "Encounters / Services "
   DO CASE
   CASE nGroup = 2
      LCJUNK = "Not Billed to Medicaid"
   CASE nGroup = 3
      LCJUNK = "Billed to Medicaid"
   OTHERWISE
      LCJUNK = "Billing Report"
   ENDCASE
   xLCTITLE = xLCTITLE + LCJUNK
CASE TCREP_ID = 'UE'
   xLCTITLE = "ADHC Attendance "
   DO CASE
   CASE nGroup = 2
      LCJUNK = "Not Billed to Medicaid"
   CASE nGroup = 3
      LCJUNK = "Billed to Medicaid"
   OTHERWISE
      LCJUNK = "Billing Report"
   ENDCASE
   xLCTITLE = xLCTITLE + LCJUNK
ENDCASE
RETURN xLCTITLE
