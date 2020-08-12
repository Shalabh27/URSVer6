*************************************
* Program:		IMP_271
* Function:		Medicaid Status Report from 271: Compare most recent status found in EMEVS with URS
*************************************
* first, grab most recent data from imp_271.dbf
Parameters lPrev

If Used("mastat1")
   Use In mastat1
Endif

**VT 07/06/2011 AIRS-29  add msg and is_health_plus and take out Distinct
SELECT ;
	imp_271.pol_num, ;
	imp_271.serv_date, ;
	imp_271.elig_date, ;
	imp_271.resp_code, ;
	resp271.descript, ;
	imp_271.dob, ;
	imp_271.sex, ;
	cli_cur.last_name	AS urs_last		, ;
	cli_cur.first_name	AS urs_first	, ;
	IIF(InsStat.ins_sex = 1, "M", IIF(InsStat.ins_sex = 2, "F", cli_cur.sex)) as urs_sex, ;
	IIF(!EMPTY(InsStat.ins_dob), InsStat.ins_dob, cli_cur.dob)                as urs_dob, ;
	.f.					AS diffstat		, ;
	insstat.effect_dt	AS effect_dt	, ;
	insstat.exp_dt		AS exp_dt, 		  ;
	imp_271.msg,        ;
	Iif(imp_271.is_health_plus = .t., "Yes", "No ") as is_health_plus, ;
   Date() as cDate, ;
   Time() as cTime ;
FROM ;
	imp_271, cli_cur, insstat, resp271 ;
WHERE ;
	imp_271.tc_id 	= cli_cur.tc_id 				    AND ;
	insstat.prim_sec 	= 1								AND ;
	insstat.client_id 	= cli_cur.client_id				AND ;
	imp_271.resp_code = resp271.code					AND ;
	insstat.effect_dt = (SELECT MAX(is2.effect_dt) ;
							FROM insstat is2 ;
							WHERE is2.client_id = insstat.client_id AND ;
							is2.prov_id = insstat.prov_id)  ;
INTO CURSOR 												;
	mastat1				;
ORDER BY ;
	imp_271.resp_code, ;
	cli_cur.last_name, ;
	cli_cur.first_name

*-*	BETWEEN(imp_271.serv_date, m.date_from, m.date_to)  AND	;

oApp.ReopenCur('MaStat1','MaStat')
USE IN MaStat1	
* are statuses the same (both active? both expired?) or different
REPLACE ALL diffstat WITH IIF(RTRIM(resp_code)='1',IIF(!EMPTY(Exp_Dt), .t., .f.),IIF(EMPTY(Exp_Dt), .t., .f.))

Go top
If oApp.gldataencrypted
      replace pol_num with osecurity.decipher(Alltrim(pol_num)) All
Endif
  
gcRptAlias = 'MaStat'
gcRptName = 'rep_271' 

Select MaStat
GO TOP

IF NOT EOF()
	 DO CASE
           CASE lPrev = .f.
                 Report Form rep_271 To Printer Prompt Noconsole NODIALOG 
            CASE lPrev = .t.   
                 oApp.rpt_print(5, .t., 1, 'rep_271', 1, 2)
     EndCase
ELSE
	oApp.msg2user('NOTFOUNDG')
ENDIF

RETURN