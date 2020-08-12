************************************************************************
**This program prints the education,training & outreach form
**It requires the act_id of the encounter selected in the ai_outr screen
*************************************************************************

**PARAMETER cAct_ID, cCategory
**IF Type("cAct_ID") <> "C" .OR. Empty(cAct_ID)
	**cAct_ID = ""
**ENDIF

**cCategory = "00006" &&ETO Detail
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
ccWork = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      ccWork = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

DO CASE
   Case lnStat = 6
      cTitle = "Education, Training and Outreach Detail Report"
      cCategory = "00006"
   CASE lnStat = 15
	   cTitle = "Outreach Detail Report"
      cCategory = "00015"
   CASE lnStat = 16
	   cTitle = "Training Detail Report"
      cCategory = "00016"
   CASE lnStat = 17
	   cTitle = "HCPI Education Detail Report"
      cCategory = "00017"
   CASE lnStat = 18
   	cTitle = "HCPI Detail Report"
      cCategory = "00018"
   CASE lnStat = 19
   	cTitle = "Other Interventions Detail Report"
      cCategory = "00019"
ENDCASE

*!*   IF Empty(cAct_ID)
*!*   	DO CASE
*!*   	   CASE cCategory = "00015"
*!*   		DO genprint.prg WITH "OP", aOrder, aGroup, cTitle, .T., .F., 2
*!*   	   CASE cCategory = "00016"
*!*   		DO genprint.prg WITH "OT", aOrder, aGroup, cTitle, .T., .F., 2
*!*   	   CASE cCategory = "00017"
*!*   		DO genprint.prg WITH "OE", aOrder, aGroup, cTitle, .T., .F., 2
*!*   	   CASE cCategory = "00018"
*!*   		DO genprint.prg WITH "OH", aOrder, aGroup, cTitle, .T., .F., 2
*!*   	   CASE cCategory = "00019"
*!*   		DO genprint.prg WITH "OO", aOrder, aGroup, cTitle, .T., .F., 2
*!*   	   OTHERWISE
*!*   		DO genprint.prg WITH "OU", aOrder, aGroup, cTitle, .T., .F., 2
*!*   	ENDCASE	
*!*   ELSE
*!*   	=PRINTREP()
*!*   ENDIF

PRIVATE cOldArea, cWhere
* jss, 6/11/01, add code for user defined fields here
cUserdef2id = "001"
=OPENFILE("userdef2","userdef2id")
IF SEEK(cUserdef2id)
	**SCATTER MEMVAR
   If Used('t_user')
      Use in t_user
   EndIf
      
   Select * ;
   from userdef2 ;
   where userdef2id = "001" ;
   into cursor t_user
ELSE
	oApp.msg2user("SEEKERROR")
	RETURN
ENDIF

=OpenFile("ai_outr", "act_id")
=OpenFile("ai_outzp", "act_id")

*!*   IF !USED("staffcur")
*!*   	=All_Staff()
*!*   ENDIF

*!*   IF !Empty(cAct_ID)
*!*   	cWhere = "ai_outr.act_id = cAct_ID"
*!*   ELSE
cWhere = IIF(EMPTY(lcProgx)	, "", "program = lcProgx")
cWhere = cWhere + IIF(EMPTY(Date_from), "", IIF(!Empty(cWhere),".and.","") + " act_dt >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),   "", IIF(!Empty(cWhere),".and.","") + " act_dt <= Date_to")
*!*   ENDIF
If Used('out_pb')
   Use in out_pb
EndIf
  
SELECT ;
	ai_outpb.act_id           AS col1,;
	PADR(pres_by.descript,40) AS col2,;
	Space(5)                  AS col3,;
	"01" AS LIST;
FROM ;
	ai_outr, ai_outpb, pres_by;
WHERE ;
	&cWhere AND ;
	Ai_outpb.act_id = ai_outr.act_id AND ;
	ai_outpb.code = pres_by.code and ;
   ai_outr.serv_cat =  cCategory  ;
INTO CURSOR out_pb

If Used('out_staff')
   Use in out_staff
EndIf
   
SELECT ;
	ai_outst.act_id                              AS col1,;
	PADR(oApp.FormatName(staffcur.last, staffcur.first),40) AS col2,;
	STR(ai_outst.prep_time,5)                    AS col3,;
	"02" AS LIST;
FROM ;
	ai_outr, Ai_outst, staffcur;
WHERE ;
	&cWhere AND ;
	Ai_outst.act_id = ai_outr.act_id AND ;
	ai_outst.worker_id = staffcur.worker_id and ;
   ai_outr.serv_cat =  cCategory  ;
INTO CURSOR ;
	out_staff

If Used('out_md')
   Use in out_md
EndIf
   
SELECT ;
	ai_outmd.act_id            AS col1,;
	PADR(delivery.descript,40) AS col2,;
	Space(5)                   AS col3,;
	"03" AS LIST;
FROM ;
	ai_outr, ai_outmd, delivery;
WHERE ;
	&cWhere AND ;
	Ai_outmd.act_id = ai_outr.act_id AND ;
	ai_outmd.code = delivery.code and ;
   ai_outr.serv_cat =  cCategory  ;
INTO CURSOR ;
	out_md
   
If Used('out_foc')
   Use in out_foc
EndIf
   
SELECT ;
	ai_outfc.act_id         AS col1,;
	PADR(focus.descript,40) AS col2,;
	STR(ai_outfc.n_part,5)  AS col3,;
	"04" AS LIST;
FROM ;
	ai_outr, Ai_outfc, focus;
WHERE ;
	&cWhere AND ;
	Ai_outfc.act_id = ai_outr.act_id AND ;
	ai_outfc.focus = focus.code and ;
   ai_outr.serv_cat =  cCategory  ;
INTO CURSOR ;
	out_foc ;
order by 2
   

If Used('out_serv')
   Use in out_serv
EndIf
   
* jss, 6/10/03, update for new field serv_cat in outrserv by selecting distinct (eliminates dup codes from outrserv)
SELECT DISTINCT;
	ai_outsp.act_id            AS col1,;
	PADR(outrserv.descript,40) AS col2,;
	SPACE(5)                   AS col3,;
	"05" AS LIST;
FROM ;
	ai_outr, Ai_outsp, outrserv;
WHERE ;
	&cWhere AND ;
	Ai_outsp.act_id = ai_outr.act_id AND ;
	ai_outsp.outrserv = outrserv.code and ;
   ai_outr.serv_cat =  cCategory  ;
INTO CURSOR ;
	out_serv

If Used('out_mat')
   Use in out_mat
EndIf
   
SELECT ;
	ai_outmt.act_id            AS col1,;
	PADR(material.descript,40) AS col2,;
	STR(ai_outmt.quantity,5)   AS col3,;
	"06" AS LIST;
FROM ;
	ai_outr, Ai_outmt, material;
WHERE ;
	&cWhere AND ;
	ai_outmt.act_id = ai_outr.act_id AND ;
	ai_outmt.material = material.code and ;
   ai_outr.serv_cat =  cCategory  ;
INTO CURSOR ;
	out_mat ;
order by material.code   

* jss, 4/2/01, define "cworkwhere" to be used in later select
cWorkWhere='.t.'
* jss, 2/23/01, to filter on worker, must have act_id matching those of selected worker
IF !EMPTY(ccWork)
   If Used('tWork')
      Use in tWork
   EndIf
      
	SELECT act_id AS col1 ;
	FROM ai_outst ;
	WHERE ;
		worker_id=ccWork ;
	INTO CURSOR tWork
	
   cWorkWhere= 'col1 IN (SELECT col1 FROM tWork)'
ENDIF		

If Used('temp1')
   Use in temp1
EndIf

   
SELECT * ;
FROM ;
	out_pb ;
UNION ALL;
SELECT * ;
FROM ;
	out_staff ;
UNION ALL;
SELECT * ;
FROM ;
	out_md ;
UNION ALL;
SELECT * ;
FROM ;
	out_foc;
UNION ALL;
SELECT * ;
FROM ;
	out_serv;
UNION ALL ;
SELECT * ;
FROM ;
	out_mat;
ORDER BY 4 ;
INTO CURSOR ;
	temp1

If Used('temp')
   Use in temp
EndIf
   
SELECT *, ;
     GetHeader(list) as header_desc, ; 
     GetTitle(list) as title_desc;
FROM temp1 ;
WHERE ;
	&cWorkWhere ;	
INTO CURSOR ;
	temp

INDEX ON col1 + list TAG col1

If Used('tOutr1') 
   Use in tOutr1
EndIf

If Used('tOutr2')
   Use in tOutr2   
EndIf

   
* jss, 2/23/01, filter ai_outr.dbf by Worker Id 

SELECT ai_outr.*, ;
	act_id as col1, ;
   Space(50) as category_desc,;
   Space(50) as type_desc, ;
   Space(50) as program_desc, ;
   Space(50) as loctype_d, ;
   Space(50) as organiz_desc,;
   Space(35) as county_desc, ;
   Space(50) as contact_name, ;
   Space(100) as zip_desc, ;
   Space(50) as target_group, ;
   Space(50)  as cdc_risk, ;
   Space(50) as spec_desc1, ;
   Space(50) as spec_desc2, ;
   Space(50) as spec_desc3,;
   Space(80) as  header_desc,;
   lv_enc_type.code ;
FROM ;
	ai_outr ;
      inner join lv_enc_type on;
            lv_enc_type.enc_id = ai_outr.enc_id and; 
            lv_enc_type.serv_cat = ai_outr.serv_cat ;
WHERE ;
   ai_outr.serv_cat = cCategory and ;
	&cWhere ;
INTO CURSOR ;
	tOutr2

*** AND &cWorkWhere && remove this line from above select

* jss, 5/21/01, fix problem in which col1 was not yet defined, rendering expression &cWorkWhere useless
*               now, col1 is available for select
If Used('tOutr')
   Use in tOutr   
EndIf

oApp.ReOpenCur("tOutr2", "tOutr1")

Select tOutr1
Go top
replace category_desc With GETDESC('CATEGORY','tOutr1.category','CODE','DESCRIPT','category.serv_cat=ccategory')  all
***replace type_desc With GETDESC('ENC_TYPE','tOutr1.enc_type','CODE','DESCRIPT','category = tOutr1.category and serv_cat=cCategory')  all

replace type_desc With GETDESC('LV_ENC_TYPE','tOutr1.code','CODE','DESCRIPT','category = tOutr1.category and serv_cat=cCategory')  all

replace program_desc With GETDESC('PROGRAM','tOutr1.program','PROG_ID','DESCRIPT') all
replace loctype_d With GETDESC('SETTINGS','tOutr1.cdcloctype','CODE','DESCRIPT') all
replace organiz_desc With GETDESC('ref_srce','tOutr1.refcode','CODE','NAME') all

** VT 08/05/2008 Dev Tick 4541  
*replace county_desc With GETDESC('COUNTY','tOutr1.cnty_resid','CODE','DESCRIPT',' county.state = tOutr1.st ') all

Update  tOutr1 ;
   Set county_desc =oApp.get_fips(tOutr1.fips_code) ;
from tOutr1 ;
Where !Empty(fips_code)   

Update  tOutr1 ;
   Set county_desc =zipcode.countyname ;
from tOutr1 ;
   inner join zipcode on ;
         Left(tOutr1.zip, 5) = zipcode.zipcode ;
       and tOutr1.st = zipcode.statecode ;
       and Empty(tOutr1.fips_code)  
** VT End

replace contact_name With GETDESC('REF_CNTC','tOutr1.contcode','CODE','UPPER(oApp.FormatName(LAST_NAME,FIRST_NAME)) ',  ' ref_cntc.code = tOutr1.contcode ' ) all
replace zip_desc with GetZips(tOutr1.act_id) all
replace target_group with GETDESC('TARGET','tOutr1.target_grp','CODE','DESCRIPT') all
replace cdc_risk with GETDESC('CDC_RISK','tOutr1.cdcriskfoc','CODE','DESCRIPT') all
replace spec_desc1 With GETDESC('SP_TGT','tOutr1.spec_aud1','CODE','DESCRIPT') all
replace spec_desc2 With GETDESC('SP_TGT','tOutr1.spec_aud2','CODE','DESCRIPT') all
replace spec_desc3 With GETDESC('SP_TGT','tOutr1.spec_aud3','CODE','DESCRIPT') all

SELECT *, ;
      FormHours(TimeSpent(tOutr1.beg_tm, tOutr1.beg_am, tOutr1.end_tm, tOutr1.end_am)) as hours_sp, ;
      cTitle as cTitle, ;
      Crit as  Crit, ;   
      cDate as cDate, ;
      cTime as cTime, ;
      Date_from as Date_from, ;
      date_to as date_to;   
FROM ;
	tOutr1 ;
WHERE ;
	&cWorkWhere ;
INTO CURSOR ;
	tOutr	

If Used('t_outr')
   Use in t_outr
EndIf
   
oApp.ReOpenCur("toutr", "t_outr")

SELECT t_outr
Go top

SET RELATION TO col1   INTO temp
SET RELATION TO act_id INTO ai_outzp ADDITIVE
SET SKIP TO temp

GO TOP
oApp.msg2user('OFF')

IF EOF()
	oApp.msg2user('NOTFOUNDG')
ELSE
	DO CASE
       Case cCategory = "00006"   
           gcRptName = 'rpt_detail'  
           DO CASE
              CASE lPrev = .f.
                  Report Form rpt_detail  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_detail', 1, 2)
            ENDCASE
      CASE cCategory = "00015"
            gcRptName = 'rpt_detail'  
		      DO CASE
              CASE lPrev = .f.
                  Report Form rpt_detail  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_detail', 1, 2)
            ENDCASE
	   CASE cCategory = "00016"
            gcRptName = 'rpt_detail_t'  
		      DO CASE
               CASE lPrev = .f.
                      Report Form rpt_detail_t  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                           oApp.rpt_print(5, .t., 1, 'rpt_detail_t', 1, 2)
            EndCase 
	   CASE cCategory = "00017"
            gcRptName = 'rpt_det_he' 
		      DO CASE
              CASE lPrev = .f.
                  Report Form rpt_det_he  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_det_he', 1, 2)
            ENDCASE 
	   CASE cCategory = "00018"
            gcRptName = 'rpt_det_hc'
		      DO CASE
              CASE lPrev = .f.
                  Report Form rpt_det_hc  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_det_hc', 1, 2)
            ENDCASE   
	   CASE cCategory = "00019"
             gcRptName = 'rpt_det_oi' 
		       DO CASE
              CASE lPrev = .f.
                  Report Form rpt_det_oi To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_det_oi', 1, 2)
            ENDCASE   
    ENDCASE
		
ENDIF
*******************************************************************
FUNCTION GetHeader
Parameters cList
DO CASE
CASE cList = "01"
	   RETURN (PADR("SESSION PRESENTED BY", 50))
CASE cList = "02"
	   RETURN (PADR("SESSION STAFFED BY", 50))
CASE cList = "03"
     RETURN (PADR("METHOD(S) OF DELIVERY", 50))
CASE cList = "04"
* jss, 1/10/02, modify to match RWCADR/CDC URS core changes
	RETURN(PADR("OTHER TARGETED POPULATION(S)",50))
CASE cList = "05"
	IF cCategory = '00016'
		RETURN(PADR("TOPICS",50))
	ELSE
		RETURN(PADR("SERVICES PROVIDED",50))
	ENDIF	
CASE cList = "06"
	RETURN(PADR("MATERIALS PROVIDED",50))
OTHERWISE
	RETURN(SPACE(50))
ENDCASE

*******************************************************************
FUNCTION GetTitle
Parameters tList
DO CASE
CASE tlist = "02"
	RETURN "WORKER                                                PREPARATION TIME(MIN)"
CASE tlist = "04"
	RETURN "TYPE                                                 APPROX # OF PARTICIPANTS"
CASE TLIST = "06"
	RETURN "MATERIAL                                                     QUANTITY"
OTHERWISE
	RETURN(SPACE(80))
ENDCASE

*******************************************************************
FUNCTION GetZips
PARAMETER cAct_ID
PRIVATE nOldArea, cRetString
nOldArea = Select()
cRetString = ""
SELECT ai_outzp
SCAN FOR ai_outzp.act_id = cAct_ID

	cRetString = cRetString + Iif(!Empty(cRetString), ", ", "") + IIF(Len(Trim(ai_outzp.zip)) > 5, ;
										TRANSFORM(ai_outzp.zip, "@R 99999-9999"), ;
										Trim(ai_outzp.zip)) 
ENDSCAN

Select (nOldArea)

Return cRetString
*********************************************************
FUNCTION getdesc
PARAMETER cfilename, tcVarName, cfieldname, cDescName, cfilter
PRIVATE nsavearea, cDesc, cSearchStr
nsavearea = SELECT()

IF TYPE("cFieldName") <> "C"
   cfieldname = "code"
ENDIF

IF TYPE("cDescName") <> "C"
   cDescName= "descript"
ENDIF

IF TYPE("cFilter") <> "C"
   cFilter= ""
ENDIF

=openfile(cfilename)
   m.cSearchStr = '&cfieldname = "'+EVAL(m.tcVarName)+'"'
  
    IF !Empty(cFilter)
         cSearchStr = "("+cSearchStr + ") .and. ("+cFilter + ")"
    ENDIF


* the table is supposed to have matching indexes on all fields involved
LOCATE FOR &cSearchStr
IF FOUND()
   cDesc = EVAL(cDescName)
ELSE
   cDesc = SPACE(LEN(EVAL(cDescName)))
ENDIF

SELECT (nsavearea)
RETURN cDesc
********************************************************************
FUNCTION FormHours
PARAMETER nTime
Return StrTran(Str(INT(nTime/60),2)+":"+Str(nTime%60,2),' ','0')
********************************************************************
FUNCTION TimeSpent
PARAMETER cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
PRIVATE nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
            0, VAL(LEFT(cEnd_tm,2))) + ;
            IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
            0, VAL(LEFT(cBeg_tm,2))) + ;
            IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes =    (nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
         (nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes)
