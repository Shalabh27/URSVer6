* Program:		CHKDATA.prg
* Author:		BK
* 
* jss, 7/2/01, add new checks for blank address.addr_id, blank insstat.insstat_id, invalid
*              insstat.prov_id, invalid insstat.effect_dt, invalid insstat.exp_dt, invalid
*              tbstatus.datecomp, orphaned contract.con_id (no matching contrinf.cid),
*              orphaned multcont.con_id (no matching contrinf.cid)
* jss, 1/5/04, change check for system administrator in 9 validation routines from 'AAAA' TO 'AAAA '
*              to prevent problem for agency Aids Interfaith Network which has a system id of 'AA'
*              The routines in question: OUTWORK4, SRVWORK3, ENCWORK4, CLIWORK2, GRPATT03, AI_GRP02, AI_CASE3, AI_CASE4, NEEDLX3

PARAMETER cCliCur, cExtrName, cProbArray
PRIVATE cCentury

SET CENTURY ON

DIMENSION aFiles_Open[1]
DO Save_Env2 WITH aFiles_Open

=OPENFILE('FIXLIST', 'MODULE')
SELECT FIXLIST
REPLACE ALL FIXED WITH 'NO'  && RESET EXECUTION FLAGS

IF TYPE("cCliCur") <> "C" OR EMPTY(cCliCur)
	=OpenFile("ai_clien", "tc_id", cCliCur)
ENDIF

IF TYPE("cExtrName") <> "C" OR EMPTY(cExtrName)
	cExtrName = ""
ENDIF

IF TYPE("cProbArray") <> "C" OR EMPTY(cProbArray)
	DIMENSION cProbArray[1]
	cProbArray[1] = ' '
ENDIF

cCentury = SET("CENTURY")
SET CENTURY ON

*added 3/10/99 by C.R.
********************************************
* CREATE CURSOR WITH ALL VALID STAFF MEMBERS.
* THOSE WITH AN ENTRY IN STAFF AND USERPROF
=ALL_STAFF2()     && CREATE STAFFCUR
********************************************

* list of all deleted referral sources
SET DELETED OFF
SELECT DIST * FROM ref_srce WHERE DELETED() INTO CURSOR delrefsrc
INDEX ON code TAG code
USE IN ref_srce

* list of all deleted referral contacts
SELECT DIST * FROM ref_cntc WHERE DELETED() INTO CURSOR delrefcnt
INDEX ON code TAG code
USE IN ref_cntc

SET DELETED OFF
* all not deleted staff
SELECT DIST * FROM staff WHERE !DELETED() INTO CURSOR notdelstaf
USE IN staff

* all deleted staff
SELECT DIST * FROM staff WHERE DELETED() INTO CURSOR delstaff
SET DELETED ON
USE IN staff

INDEX ON staff_id TAG staff_id

* jss, 11/99, detect problems with staff.date_start
SELECT ;
	"STAFFSDT" AS prob_type, REPL('Z',10) AS tc_id, PADR(staff_id,10) AS act_id, ;
	PADR(DTOC(date_start) ,10) AS problem, ;
	"STAFF   " AS sourcefile, "DATE_START" AS prob_field, "        " AS prob_file ;
FROM ;
	staff ;
WHERE ;
   !EMPTY(date_start) AND ;
	!BETWEEN(date_start, {01/01/1950}, DATE()) ;
INTO CURSOR ;
	prob_cur90
USE IN staff

* jss, 7/6/00, detect problems with ai_prog.start_dt
SELECT ;
	"AIPROG1 " AS prob_type, tc_id, PADR(program,10) AS act_id, ;
	PADR(DTOC(start_dt),10) AS problem, ;
	"AI_PROG " AS sourcefile, "START_DT  " AS prob_field, "AI_PROG " AS prob_file ;
FROM ;
	ai_prog ;
WHERE ;
   !EMPTY(start_dt) AND ;
	!BETWEEN(start_dt, {01/01/1950}, DATE()) ;
INTO CURSOR ;
	prob_cur80 
USE IN ai_prog

* jss, 7/6/00, detect problems with ai_clien.placed_dt
SELECT ;
	"AICLIEN2" AS prob_type, tc_id, tc_id AS act_id, ;
	PADR(DTOC(placed_dt),10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "PLACED_DT " AS prob_field, SPACE(8) AS prob_file ;
FROM ;
	ai_clien ;
WHERE ;
   !EMPTY(placed_dt) AND ;
	!BETWEEN(placed_dt, {01/01/1950}, DATE()) ;
INTO CURSOR ;
	prob_cur81
USE IN ai_clien

* user profiles exist for non-existent staff
SELECT ;
	userprof.* ;
FROM ;
	userprof ;
WHERE ;
	userprof.staff_id NOT IN (SELECT staff_id FROM notdelstaf) ;
INTO CURSOR ;
	deluprof2
USE IN userprof

* jss, 11/99, userprof.staff_id invalid
SELECT ;
	"USERPROF" AS prob_type, REPL('Z',10) AS tc_id, PADR(deluprof2.worker_id ,10)  AS act_id, ;
	PADR(deluprof2.staff_id ,10) AS problem, ;
	"USERPROF" AS sourcefile, "STAFF_ID  " AS prob_field, "        " AS prob_file ;
FROM ;
	deluprof2 ;
INTO CURSOR ;
	prob_cur91

* jss, 11/99, userprof.prog_id invalid
SELECT ;
	userprof.* ;
FROM ;
	userprof ;
WHERE ;
	NOT EMPTY(userprof.prog_id) AND ;
	userprof.prog_id NOT IN (SELECT prog_id FROM program) ;
INTO CURSOR ;
	uprofprog
USE IN userprof

* jss, 11/99, write a record to report cursor for invalid userprof.prog_id
SELECT ;
	"USERPRF2" AS prob_type, REPL('Z',10) AS tc_id, PADR(uprofprog.staff_id ,10)  AS act_id, ;
	PADR(uprofprog.prog_id ,10) AS problem, ;
	"USERPROF" AS sourcefile, "PROG_ID   " AS prob_field, "        " AS prob_file ;
FROM ;
	uprofprog ;
INTO CURSOR ;
	prob_cur92
	
* jss, 11/99, consd.ser_type invalid
SELECT ;
	* ;
FROM ;
	consd ;
WHERE ;
	EMPTY(ser_type) OR ;
	(NOT EMPTY(ser_type) AND ser_type NOT IN (SELECT code FROM sertype)) ;
INTO CURSOR ;
	badconsd
USE IN consd

* jss, 11/99, write a record to report cursor for invalid consd.ser_type
SELECT ;
	"CONSD   " AS prob_type, REPL('Z',10) AS tc_id, Contract  AS act_id, ;
	PADR(ser_type ,10) AS problem, ;
	"CONSD   " AS sourcefile, "SER_TYPE  " AS prob_field, "        " AS prob_file ;
FROM ;
	badconsd ;
INTO CURSOR ;
	prob_cur93

* jss, 11/99, Prog2sc.prog_id invalid
SELECT ;
	* ;
FROM ;
	Prog2sc ;
WHERE ;
	prog_id NOT IN (SELECT prog_id FROM program) ;
INTO CURSOR ;
	prog2prog
USE IN prog2sc

* jss, 11/99, write a record to report cursor for invalid Prog2prog.prog_id
SELECT ;
	"PROG2SC " AS prob_type, REPL('Z',10) AS tc_id, REPL('Z',10)  AS act_id, ;
	IIF(!EMPTY(prog_id),PADR(prog_id ,10),PADR('Empty',10)) AS problem, ;
	"PROG2SC " AS sourcefile, "PROG_ID   " AS prob_field, "PROGRAM " AS prob_file ;
FROM ;
	prog2prog ;
INTO CURSOR ;
	prob_cur94

* jss, 11/99, detect any duplicate id_no's in AI_CLIEN

SELECT id_no ;
FROM ai_clien ;
GROUP BY id_no ;
HAVING COUNT(id_no) > 1 ;
INTO CURSOR idnodups

SELECT ;
	"AICLIEN1" AS prob_type, tc_id, tc_id  AS act_id, ;
	LEFT(id_no,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "ID_NO     " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_clien ;
WHERE ;
	id_no IN (SELECT id_no FROM idnodups) ;
INTO CURSOR ;
	prob_cur95
USE IN ai_clien

* all deleted user profiles and user profiles for deleted staff
SELECT * ;
FROM ;
	userprof ;
WHERE ;
	DELETED() ;
UNION ALL ;
SELECT ;
	userprof.* ;
FROM ;
	userprof, delstaff ;
WHERE ;
	userprof.staff_id = delstaff.staff_id ;
INTO CURSOR ;
	deluprof

INDEX ON worker_id TAG worker_id

USE IN userprof

* list of all problems (deleted staff, referrals etc)
SELECT ;
	"USERPROF" AS prob_file, PADR(deluprof.worker_id ,10) AS problem, ;
	PADR(Name(staff.last, staff.first, staff.mi),50) AS name ;
FROM ;
	deluprof, staff ;
WHERE deluprof.staff_id = staff.staff_id ;
UNION ALL ;
SELECT ;
	"REF_SRCE" AS prob_file, PADR(delrefsrc.code ,10) AS problem, ;
	PADR(delrefsrc.name, 50) AS name ;
FROM ;
	delrefsrc ;
UNION ALL ;
SELECT ;
	"REF_CNTC" AS prob_file, PADR(delrefcnt.code ,10) AS problem, ;
	PADR(Name(delrefcnt.last_name, delrefcnt.first_name), 50) AS name ;
FROM ;
	delrefcnt ;
INTO CURSOR prob_desc

INDEX ON prob_file + problem TAG prob_code

USE in staff

SET DELETED ON

********************************************************************************
* ai_clien
********************************************************************************
SELECT ;
	"REFSRCE1" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.ref_source ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "REF_SOURCE" AS prob_field, "REF_SRCE" AS prob_file ;
FROM ;
	ai_clien, delrefsrc ;
WHERE ;
	ai_clien.ref_source = delrefsrc.code ;
UNION ALL ;
SELECT ;
	"REFCNTC1" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.ref_cntc ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "REF_CNTC  " AS prob_field, "REF_CNTC" AS prob_file  ;
FROM ;
	ai_clien, delrefcnt ;
WHERE ;
	ai_clien.ref_cntc = delrefcnt.code ;
UNION ALL ;
SELECT ;
	"REFSRCE2" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.ref_source ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "REF_SOURCE" AS prob_field, "REF_SRCE" AS prob_file  ;
FROM ;
	ai_clien ;
WHERE ;
	!EMPTY(ref_source) AND ;
	ai_clien.ref_source NOT IN ;
		(SELECT code FROM ref_srce) AND;
	ai_clien.ref_source NOT IN ;
		(SELECT code FROM delrefsrc) ;
UNION ALL ;
SELECT ;
	"REFCNTC2" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.ref_cntc ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "REF_CNTC  " AS prob_field, "REF_CNTC" AS prob_file  ;
FROM ;
	ai_clien;
WHERE ;
	!EMPTY(ref_cntc) AND ;
	ai_clien.ref_cntc NOT IN ;
		(SELECT code FROM ref_cntc) AND;
	ai_clien.ref_cntc NOT IN ;
		(SELECT code FROM delrefcnt) ;
UNION ALL ;
SELECT ;
	"INT_PROG" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.int_prog ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "INT_PROG  " AS prob_field, "PROGRAM " AS prob_file  ;
FROM ;
	ai_clien;
WHERE ;
	!EMPTY(int_prog) AND ;
	ai_clien.int_prog NOT IN ;
		(SELECT prog_id FROM PROGRAM) ;
INTO CURSOR ;
	prob_cur1

********************************************************************
* added 3/10/99 by C.R.
********************************************************************
SELECT ;
	"CLIWORK1" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.int_worker ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "INT_WORKER" AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_clien ;
WHERE ;
	!EMPTY(ai_clien.int_worker) AND ;
	ai_clien.int_worker NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"CLIWORK2" AS prob_type, ai_clien.tc_id, tc_id AS act_id, ;
	PADR(ai_clien.int_worker ,10) AS problem, ;
	"AI_CLIEN" AS sourcefile, "INT_WORKER" AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_clien ;
WHERE ;
	!EMPTY(ai_clien.int_worker) AND ;
	ai_clien.int_worker = 'AAAA ' ;
INTO CURSOR ;
	prob_cur1a
	
USE IN ai_clien
**********************************************************

********************************************************************************
* client, hivstat, tbstat, testres - date incorrect
********************************************************************************
&&& jss, 7/5/01, create combined cursor of tbstatus and client.dob, use in subsequent tbstatus date checks
SELECT DIST ;
	tbstatus.*, client.dob ;
FROM ;
	tbstatus, ai_clien, client ;
WHERE ;
	tbstatus.tc_id = ai_clien.tc_id ;
AND ai_clien.client_id = client.client_id ;
INTO CURSOR ;
	tbstat1

SELECT ;
	"TBDATEST" AS prob_type, tbstat1.tc_id, PADR(DTOC(tbstat1.effect_dt),10) AS act_id, ;
	PADR(DTOC(tbstat1.datestart) ,10) AS problem, ;
	"TBSTATUS" AS sourcefile, "DATESTART " AS prob_field, "        " AS prob_file ;
FROM ;
	tbstat1 ;
WHERE ;
	!EMPTY(tbstat1.datestart) ; 
AND	!BETWEEN(tbstat1.datestart, IIF(!EMPTY(tbstat1.dob), tbstat1.dob, {01/01/1940}), DATE()) ;
UNION ALL ;
SELECT ;
	"TBDATE  " AS prob_type, tbstat1.tc_id, PADR(DTOC(tbstat1.effect_dt),10) AS act_id, ;
	PADR(DTOC(tbstat1.effect_dt) ,10) AS problem, ;
	"TBSTATUS" AS sourcefile, "EFFECT_DT " AS prob_field, "        " AS prob_file ;
FROM ;
	tbstat1 ;
WHERE ;
	!BETWEEN(tbstat1.effect_dt, IIF(!EMPTY(tbstat1.dob), tbstat1.dob, {01/01/1940}), DATE()) ;
UNION ALL ;
SELECT ;
	"TBDATE2 " AS prob_type, tbstat1.tc_id, PADR(DTOC(tbstat1.effect_dt),10) AS act_id, ;
	PADR(DTOC(tbstat1.datecomp) ,10) AS problem, ;
	"TBSTATUS" AS sourcefile, "DATECOMP  " AS prob_field, "        " AS prob_file ;
FROM ;
	tbstat1 ;
WHERE ;
	!EMPTY(tbstat1.datecomp) ; 
AND	!BETWEEN(tbstat1.datecomp, IIF(!EMPTY(tbstat1.dob), tbstat1.dob, {01/01/1940}), DATE()) ;
UNION ALL ;
SELECT ;
	"PPDDATE " AS prob_type, tbstat1.tc_id, PADR(DTOC(tbstat1.effect_dt),10) AS act_id, ;
	PADR(DTOC(tbstat1.ppddate),10) AS problem, ;
	"TBSTATUS" AS sourcefile, "PPDDATE   " AS prob_field, "        " AS prob_file ;
FROM ;
	tbstat1 ;
WHERE ;
	!EMPTY(tbstat1.ppddate) ; 
AND	!BETWEEN(tbstat1.ppddate, IIF(!EMPTY(tbstat1.dob), tbstat1.dob, {01/01/1940}), DATE()) ;
UNION ALL ;
SELECT DISTINCT;
	"TBXRAYDT" AS prob_type, tbstat1.tc_id, PADR(DTOC(tbstat1.effect_dt),10) AS act_id, ;
	PADR(tbstat1.xraydate,10) AS problem, ;
	"TBSTATUS" AS sourcefile, "XRAYDATE  " AS prob_field, "        " AS prob_file ;
FROM ;
	tbstat1 ;
WHERE ;
	!EMPTY(tbstat1.xraydate) ; 
AND	!BETWEEN(tbstat1.xraydate, IIF(!EMPTY(tbstat1.dob), tbstat1.dob, {01/01/1940}), DATE()) ;
INTO CURSOR ;
	prob_cur2

USE IN client
USE IN ai_clien
USE IN tbstatus
USE IN tbstat1

SELECT ;
	"AICASEDT" AS prob_type, ai_case.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_case.ddateenter) ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "DDATEENTER" AS prob_field, "        " AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ddateenter) AND !BETWEEN(ddateenter, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"AI_ACTDT" AS prob_type, ai_activ.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_activ.effect_dt) ,10) AS problem, ;
	"AI_ACTIV" AS sourcefile, "EFFECT_DT " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_activ ;
WHERE ;
	!BETWEEN(effect_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"AI_SITED" AS prob_type, ai_site.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_site.effect_dt) ,10) AS problem, ;
	"AI_SITE " AS sourcefile, "EFFECT_DT " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_site ;
WHERE ;
	!BETWEEN(effect_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"AI_SITE4" AS prob_type, ai_site.tc_id, ai_site.sites_id AS act_id, ;
	PADR(ai_site.site,10) AS problem, ;
	"AI_SITE " AS sourcefile, "SITE      " AS prob_field, "SITE    " AS prob_file ;
FROM ;
	ai_site ;
WHERE ;
	!EMPTY(ai_site.site) AND ;
	ai_site.site NOT IN ;
		(SELECT site_id FROM site) ;
INTO CURSOR ;
	prob_cur21

USE IN ai_case
USE IN ai_activ
USE IN ai_site

********************************************************************************
* ai_enc
********************************************************************************
SELECT ;
	"ENCWORK1" AS prob_type, ai_enc.tc_id, ai_enc.act_id,  ;
	PADR(ai_enc.worker_id ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_enc, deluprof ;
WHERE ;
	ai_enc.worker_id = deluprof.worker_id ;
UNION ALL ;
SELECT ;
	"ENCWORK2" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.worker_id ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(worker_id) AND ;
	ai_enc.worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) AND ;
	ai_enc.worker_id NOT IN ;
		(SELECT worker_id FROM deluprof) ;
UNION ALL ;
SELECT ;
	"ENCPROG " AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.program ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "PROGRAM   " AS prob_field, "PROGRAM " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(PROGRAM) AND ;
	ai_enc.program  NOT IN ;
		(SELECT prog_id FROM PROGRAM) ;
UNION ALL ;
SELECT ;
	"ENCWORK4" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.worker_id ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(worker_id) AND ;
	ai_enc.worker_id = 'AAAA ' ;
INTO CURSOR ;
	prob_cur3

USE IN ai_enc

SELECT ;
	"ENCDATE " AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(DTOC(ai_enc.act_dt) ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "ACT_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(act_dt) AND ;
	!BETWEEN(act_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"ENCDDATE" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(DTOC(ai_enc.due_dt) ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "DUE_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(due_dt) AND ;
	due_dt < {01/01/1950} ;
UNION ALL ;
SELECT ;
	"COMPDATE" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(DTOC(ai_enc.date_compl) ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "DATE_COMPL" AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(date_compl) AND ;
	!BETWEEN(date_compl, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"ENCDIAG1" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.diagnos1 ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "DIAGNOS1  " AS prob_field, "DIAGNOS " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(diagnos1) AND ;
	ai_enc.diagnos1 NOT IN ;
		(SELECT code FROM diagnos) ;
UNION ALL ;
SELECT ;
	"ENCDIAG2" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.diagnos2 ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "DIAGNOS2  " AS prob_field, "DIAGNOS " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(diagnos2) AND ;
	ai_enc.diagnos2 NOT IN ;
		(SELECT code FROM diagnos) ;
UNION ALL ;
SELECT ;
	"AIPRENC1" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_prenc.act_id, ;
	PADR(ai_prenc.act_id ,10) AS problem, ;
	"AI_PRENC" AS sourcefile, "ACT_ID    " AS prob_field, "AI_ENC  " AS prob_file ;
FROM ;
	ai_prenc ;
WHERE ;
	!EMPTY(act_id) AND ;
	ai_prenc.act_id NOT IN ;
		(SELECT act_id FROM ai_enc) ;
INTO CURSOR ;
	prob_cur31

USE IN ai_enc
USE IN ai_prenc

********************************************************************************
* jss, 11/99, added check for invalid field "Problem"
********************************************************************************
SELECT ;
	"AIPRENC2" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_prenc.act_id, ;
	IIF(!EMPTY(problem), PADR(problem, 10), PADR('Empty', 10)) AS problem, ;
	"AI_PRENC" AS sourcefile, "PROBLEM   " AS prob_field, "PROBLEMS" AS prob_file ;
FROM ;
	ai_prenc ;
WHERE ;
	problem NOT IN (SELECT code FROM problems) ;
UNION ALL ;
SELECT ;
	"SRVWORK1" AS prob_type, ai_serv.tc_id, ai_serv.serv_id AS act_id,  ;
	PADR(ai_serv.worker_id ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_serv, deluprof ;
WHERE ;
	ai_serv.worker_id = deluprof.worker_id ;
UNION ALL ;
SELECT ;
	"SRVWORK2" AS prob_type, ai_serv.tc_id, ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.worker_id ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(worker_id) AND ;
	ai_serv.worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) AND ;
	ai_serv.worker_id NOT IN ;
		(SELECT worker_id FROM deluprof) ;
UNION ALL ;
SELECT ;
	"SRVDATE" AS prob_type, ai_serv.tc_id, ai_serv.serv_id AS act_id, ;
	PADR(DTOC(ai_serv.date) ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "DATE      " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(DATE) AND ;
	!BETWEEN(DATE, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"SRVWORK3" AS prob_type, ai_serv.tc_id, ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.worker_id ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(worker_id) AND ;
	ai_serv.worker_id = 'AAAA ';
INTO CURSOR ;
	prob_cur4

USE IN ai_prenc
USE IN ai_serv


********************************************************************************
* ai_ref
********************************************************************************
SELECT ;
	"REFSRCE3" AS prob_type, ai_ref.tc_id, SPACE(10) AS act_id, ;
	PADR(ai_ref.ref_to ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "REF_TO    " AS prob_field, "REF_SRCE" AS prob_file ;
FROM ;
	ai_ref, delrefsrc ;
WHERE ;
	ai_ref.ref_to = delrefsrc.code ;
UNION ALL ;
SELECT ;
	"REFSRCE4" AS prob_type, ai_ref.tc_id, SPACE(10) AS act_id, ;
	PADR(ai_ref.ref_to ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "REF_TO    " AS prob_field, "REF_SRCE" AS prob_file  ;
FROM ;
	ai_ref ;
WHERE ;
	!EMPTY(ref_to) AND ;
	ai_ref.ref_to NOT IN ;
		(SELECT code FROM ref_srce) AND ;
	ai_ref.ref_to NOT IN ;
		(SELECT code FROM delrefsrc) ;
UNION ALL ;
SELECT ;
	"REFDATE " AS prob_type, ai_ref.tc_id, ai_ref.ref_id AS act_id, ;
	PADR(DTOC(ai_ref.ref_dt) ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "REF_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_ref ;
WHERE ;
	!EMPTY(ref_dt) AND ;
	!BETWEEN(ref_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"ENCREF1 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_ref.act_id, ;
	PADR(ai_ref.act_id ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "ACT_ID    " AS prob_field, "AI_ENC  " AS prob_file  ;
FROM ;
	ai_ref ;
WHERE ;
	!EMPTY(act_id) AND ;
	ai_ref.act_id NOT IN ;
		(SELECT act_id FROM ai_enc) ;
INTO CURSOR ;
	prob_cur5
	
USE IN ai_ref
	
********************************************************************************
* ETO:
* ai_outr
* ai_outst
********************************************************************************
SELECT ;
	"OUTRDATE" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outr.act_id, ;
	PADR(DTOC(ai_outr.act_dt) ,10) AS problem, ;
	"AI_OUTR " AS sourcefile, "ACT_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	!EMPTY(act_dt) AND ;
	!BETWEEN(act_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"OUTRDDAT" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outr.act_id, ;
	PADR(DTOC(ai_outr.due_dt) ,10) AS problem, ;
	"AI_OUTR " AS sourcefile, "DUE_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	!EMPTY(due_dt) AND ;
	due_dt < {01/01/1950} ;
UNION ALL ;
SELECT ;
	"OUTWORK1" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outst.act_id,  ;
	PADR(ai_outst.worker_id ,10) AS problem, ;
	"AI_OUTST" AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_outst, deluprof ;
WHERE ;
	ai_outst.worker_id = deluprof.worker_id ;
UNION ALL ;
SELECT ;
	"OUTWORK2" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outst.act_id,  ;
	PADR(ai_outst.worker_id ,10) AS problem, ;
	"AI_OUTST" AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_outst ;
WHERE ;
	!EMPTY(worker_id) AND ;
	worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) AND ;
	worker_id NOT IN ;
		(SELECT worker_id FROM deluprof) ;
UNION ALL ;
SELECT ;
	"OUTWORK4" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outst.act_id,  ;
	PADR(ai_outst.worker_id ,10) AS problem, ;
	"AI_OUTST" AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_outst ;
WHERE ;
	!EMPTY(worker_id) AND worker_id = 'AAAA ';
INTO CURSOR ;
	prob_cur6

USE IN ai_outr
USE IN ai_outst

********************************************************************************
* AI_OUTR added 6/8/99 by C.R.
********************************************************************************
SELECT ;
	DISTINCT "AI_OUT1 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outr.act_id,  ;
	PADR(ai_outr.program ,10) AS problem, ;
	"AI_OUTR " AS sourcefile, "PROGRAM   " AS prob_field, "PROGRAM " AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	ai_outr.program NOT IN ;
		(SELECT prog_id FROM program) ;
UNION ALL ;
SELECT ;
	DISTINCT "AI_OUT2 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outpb.act_id,  ;
	PADR(ai_outpb.act_id ,10) AS problem, ;
	"AI_OUTPB" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outpb ;
WHERE ;
	ai_outpb.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
UNION ALL ;		
SELECT ;
	"AI_OUTFC" AS prob_type, REPLICATE('Z', 10) AS tc_id, act_id, ;
	IIF(!EMPTY(focus), PADR(focus, 10), PADR('Empty', 10)) AS problem, ;
	"AI_OUTFC" AS sourcefile, "FOCUS     " AS prob_field, "FOCUS   " AS prob_file ;
FROM ;
	ai_outfc ;
WHERE ;
	focus NOT IN (SELECT code FROM focus) ;
INTO CURSOR ;
	prob_cur20

USE IN ai_outr
USE IN ai_outpb
USE IN ai_outfc

*********************************************************************************

** jss, 9/98, some more error conditions: 	AI_CLIEN.PLACED_DT <> MIN(AI_SITE.EFFECT_DT)
**															AI_CLIEN.PLACED_DT >  AI_PROG.START_DT
**															AI_CLIEN.PLACED_DT <> AI_ACTIV.EFFECT_DT (for ai_activ.initial)
**
***************************************
* More ai_clien checks into prob_curs7
***************************************
SELECT ;
	"HOLDSITE" AS prob_type, cc.tc_id, cc.tc_id AS act_id, ;
	PADR(DTOC(ai_site.effect_dt),10) AS problem, ;
	"AI_SITE " AS sourcefile, "EFFECT_DT " AS prob_field, "AI_CLIEN" AS prob_file ;
FROM ;
	&cCliCur cc, ai_site ;
WHERE ;
	cc.tc_id = ai_site.tc_id ;
	AND ;
	cc.placed_dt <> ai_site.effect_dt ;
	AND ai_site.effect_dt = (SELECT MIN(ai_site2.effect_dt) ;
FROM ai_site ai_site2 ;
WHERE ai_site2.tc_id = ai_site.tc_id) ;
INTO CURSOR ;
	tprobcur

USE IN ai_site

SELECT * FROM tprobcur ;
UNION ALL ;
SELECT ;
	"HOLDACTI" AS prob_type, cc.tc_id, cc.tc_id AS act_id, ;
	PADR(DTOC(ai_activ.effect_dt),10) AS problem, ;
	"AI_ACTIV" AS sourcefile, "EFFECT_DT " AS prob_field, "AI_CLIEN" AS prob_file ;
FROM ;
	&cCliCur cc, ai_activ ;
WHERE ;
	cc.tc_id = ai_activ.tc_id ;
	AND ;
	cc.placed_dt <> ai_activ.effect_dt ;
	AND ;
	ai_activ.initial ;
UNION ALL ;
SELECT ;
	"HOLDPROG" AS prob_type, cc.tc_id, cc.tc_id AS act_id, ;
	PADR(DTOC(ai_prog.start_dt),10) AS problem, ;
	"AI_PROG " AS sourcefile, "START_DT  " AS prob_field, "AI_CLIEN" AS prob_file ;
FROM ;
	&cCliCur cc, ai_prog ;
WHERE ;
	cc.tc_id = ai_prog.tc_id ;
	AND ;
	cc.placed_dt > ai_prog.start_dt ;
INTO CURSOR ;
	prob_cur7

USE IN ai_activ
USE IN ai_prog

********************************************************************************
* ai_work added 3/10/99 by C.R.
********************************************************************************
SELECT ;
	"AI_WORK1" AS prob_type, ai_work.tc_id, PADR(ai_work.ws_id ,10) AS act_id,  ;
	PADR(ai_work.worker_id ,10) AS problem, ;
	"AI_WORK " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_work ;
WHERE ;
	!EMPTY(ai_work.worker_id) AND ;
	ai_work.worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"AI_WORK2" AS prob_type, ai_work.tc_id, PADR(ai_work.ws_id ,10) AS act_id,  ;
	PADR(ai_work.program ,10) AS problem, ;
	"AI_WORK " AS sourcefile, "PROGRAM   " AS prob_field, "AI_PROG " AS prob_file ;
FROM ;
	ai_work ;
WHERE ;
	!EMPTY(ai_work.ps_id) AND ;
	ai_work.ps_id NOT IN ;
		(SELECT ps_id FROM ai_prog) ;
INTO CURSOR ;
	prob_cur8

USE IN ai_work

*********************************************************************************
**************
******************************************************************
* GRPATT added 3/10/99 by C.R.
********************************************************************************
SELECT ;
	"GRPATT01" AS prob_type, REPLICATE('Z', 10) AS tc_id, grpatt.att_id AS act_id,  ;
	PADR(grpatt.worker_id ,10) AS problem, ;
	"GRPATT  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	grpatt ;
WHERE ;
	!EMPTY(grpatt.worker_id) AND ;
	grpatt.worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"GRPATT02" AS prob_type, REPLICATE('Z', 10) AS tc_id, PADR(TRIM(grpatt.grp_id),10) AS act_id,  ;
	PADR(DTOC(grpatt.act_dt) ,10) AS problem, ;
	"GRPATT  " AS sourcefile, "ACT_DT    " AS prob_field, "GRPATT  " AS prob_file ;
FROM ;
	grpatt ;
WHERE ;
	!BETWEEN(act_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"GRPATT03" AS prob_type, REPLICATE('Z', 10) AS tc_id, grpatt.att_id AS act_id,  ;
	PADR(grpatt.worker_id ,10) AS problem, ;
	"GRPATT  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	grpatt ;
WHERE ;
	!EMPTY(grpatt.worker_id) AND ;
	grpatt.worker_id = 'AAAA ' ;
INTO CURSOR ;
	prob_cur9

USE IN grpatt

*********************************************************************************

********************************************************************************
* ai_grp added 3/10/99 by C.R.
* group  added 11/99 by jss
********************************************************************************
SELECT ;
	"AI_GRP01" AS prob_type, ai_grp.tc_id, PADR(ai_grp.group,10) AS act_id,  ;
	PADR(ai_grp.worker_id ,10) AS problem, ;
	"AI_GRP  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_grp ;
WHERE ;
	!EMPTY(ai_grp.worker_id) AND ;
	ai_grp.worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"AI_GRP02" AS prob_type, ai_grp.tc_id, ai_grp.gs_id AS act_id,  ;
	PADR(ai_grp.worker_id ,10) AS problem, ;
	"AI_GRP  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_grp ;
WHERE ;
	!EMPTY(ai_grp.worker_id) AND ;
	ai_grp.worker_id = 'AAAA ' ;
UNION ALL ;
SELECT ;
	"GROUP01 " AS prob_type, REPL('Z',10) AS tc_id, PADR(group.grp_id,10) AS act_id,  ;
	PADR(group.program ,10) AS problem, ;
	"GROUP   " AS sourcefile, "PROGRAM   " AS prob_field, "        " AS prob_file ;
FROM ;
	group ;
WHERE ;
	!EMPTY(group.program) AND ;
	group.program NOT IN (SELECT prog_id FROM program);
INTO CURSOR ;
	prob_cur10

USE IN ai_grp
USE IN group

*********************************************************************************

********************************************************************************
* ai_case added 3/10/99 by C.R.
********************************************************************************
SELECT ;
	"AI_CASE1" AS prob_type, ai_case.tc_id, ai_case.ai_case_id AS act_id,  ;
	PADR(ai_case.int_work1 ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "INT_WORK1 " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ai_case.int_work1) AND ;
	ai_case.int_work1 NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"AI_CASE3" AS prob_type, ai_case.tc_id, ai_case.ai_case_id AS act_id,  ;
	PADR(ai_case.int_work1 ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "INT_WORK1 " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ai_case.int_work1) AND ;
	ai_case.int_work1 = 'AAAA ' ;
INTO CURSOR ;
	prob_cur11

SELECT ;
	"AI_CASE2" AS prob_type, ai_case.tc_id, ai_case.ai_case_id AS act_id,  ;
	PADR(ai_case.intwork2 ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "INT_WORK2 " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ai_case.intwork2) AND ;
	ai_case.intwork2 NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"AI_CASE4" AS prob_type, ai_case.tc_id, ai_case.ai_case_id AS act_id,  ;
	PADR(ai_case.intwork2 ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "INT_WORK2 " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ai_case.intwork2) AND ;
	ai_case.intwork2 = 'AAAA ' ;
INTO CURSOR ;
	prob_cur12

USE IN ai_case

********************************************************************************
* ai_enc added 3/10/99 by C.R.
********************************************************************************
SELECT ;
	"AI_ENC1 " AS prob_type, ai_enc.tc_id, ai_enc.act_id,  ;
	PADR(ai_enc.bill_phys ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "BILL_PHYS " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.bill_phys) AND ;
	ai_enc.bill_phys NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ;
SELECT ;
	"CONTPROG" AS prob_type, REPL('Z',10) AS tc_id, contract.con_id AS act_id,  ;
	PADR(contract.con_id ,10) AS problem, ;
	"CONTRACT" AS sourcefile, "CON_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	contract ;
WHERE ;
	contract.con_id NOT IN (SELECT cid FROM CONTRINF) ;			
UNION ;		
SELECT ;
	"MULTCONT" AS prob_type, REPL('Z',10) AS tc_id, multcont.con_id AS act_id,  ;
	PADR(multcont.con_id ,10) AS problem, ;
	"MULTCONT" AS sourcefile, "CON_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	multcont ;
WHERE ;
	multcont.con_id NOT IN (SELECT cid FROM CONTRINF) ;			
INTO CURSOR ;
	prob_cur13

USE IN ai_enc
USE IN contract
USE IN contrinf
USE IN multcont

********************************************************************************
* needlx added 3/10/99 by C.R.
********************************************************************************
SELECT ;
	"NEEDLX1 " AS prob_type, needlx.tc_id, needlx.need_id AS act_id,  ;
	PADR(needlx.worker_id ,10) AS problem, ;
	"NEEDLX  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!EMPTY(needlx.worker_id) AND ;
	needlx.worker_id NOT IN ;
		(SELECT worker_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"NEEDLX3 " AS prob_type, needlx.tc_id, needlx.need_id AS act_id,  ;
	PADR(needlx.worker_id ,10) AS problem, ;
	"NEEDLX  " AS sourcefile, "WORKER_ID " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!EMPTY(needlx.worker_id) AND ;
	needlx.worker_id = 'AAAA ' ;
INTO CURSOR ;
	prob_cur14

*************************************************************************************

********************************************************************************
* added 4/30/99 by C.R.
********************************************************************************
SELECT ;
	"NEEDLX2 " AS prob_type, needlx.tc_id, needlx.need_id AS act_id,  ;
	PADR(DTOC(needlx.date) ,10) AS problem, ;
	"NEEDLX  " AS sourcefile, "DATE      " AS prob_field, "NEEDLX  " AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!BETWEEN(needlx.date, {01/01/1950}, DATE()) ;
INTO CURSOR ;
	prob_cur23

USE IN needlx

*************************************************************************************

********************************************************************************
* ai_enc added 3/10/99 by C.R.
********************************************************************************
SELECT ;
	"REFCNTC3" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.ref_cont_w ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "REF_CONT_W" AS prob_field, "REF_SRCE" AS prob_file ;
FROM ;
	ai_enc, delrefsrc ;
WHERE ;
	ai_enc.ref_cont_w = delrefsrc.code ;
INTO CURSOR ;
	prob_cur15

USE IN ai_enc

SELECT ;
	"REFCNTC4" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.ref_cont_w ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "REF_CONT_W" AS prob_field, "REF_SRCE" AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.ref_cont_w) AND ;
	ai_enc.ref_cont_w NOT IN ;
		(SELECT code FROM ref_srce) AND ;
	ai_enc.ref_cont_w NOT IN ;
		(SELECT code FROM delrefsrc) ;
INTO CURSOR ;
	prob_cur16

USE IN ai_enc

********************************************************************************
* ref_cntc added 3/10/99 by C.R.
********************************************************************************

SELECT ;
	"REFCSRC1" AS prob_type, REPLICATE('Z', 10) AS tc_id, PADR(ref_cntc.refsource ,10) AS act_id, ;
	PADR(ref_cntc.refsource ,10) AS problem, ;
	"REF_CNTC" AS sourcefile, "REFSOURCE " AS prob_field, "REF_SRCE" AS prob_file  ;
FROM ;
	ref_cntc, delrefsrc ;
WHERE ;
	ref_cntc.refsource = delrefsrc.code ;
INTO CURSOR ;
	prob_cur17

USE IN ref_cntc

SELECT ;
	"REFCSRC2" AS prob_type, REPLICATE('Z', 10) AS tc_id, PADR(ref_cntc.refsource ,10) AS act_id, ;
	PADR(ref_cntc.refsource ,10) AS problem, ;
	"REF_CNTC" AS sourcefile, "REFSOURCE " AS prob_field, "REF_SRCE" AS prob_file  ;
FROM ;
	ref_cntc ;
WHERE ;
	!EMPTY(ref_cntc.refsource) AND ;
	ref_cntc.refsource NOT IN ;
		(SELECT code FROM ref_srce) AND ;
	ref_cntc.refsource NOT IN ;
		(SELECT code FROM delrefsrc) ;
INTO CURSOR ;
	prob_cur18

USE IN ref_cntc

**********************************************************************************

********************************************************************************
* AI_ENC added 6/8/99 by C.R.
********************************************************************************
SELECT ;
	"AI_ENC2 " AS prob_type, ai_enc.tc_id, ai_enc.act_id,  ;
	PADR(ai_enc.site ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "SITE      " AS prob_field, "SITE    " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	ai_enc.site NOT IN ;
		(SELECT site_id FROM site) ;
INTO CURSOR ;
	prob_cur19

USE IN ai_enc

********************************************************************************
* AI_CTEST added 6/30/99 by C.R.
********************************************************************************
SELECT ;
	"AICTEST1" AS prob_type, ai_ctest.tc_id, ai_ctest.cts_id AS act_id,  ;
	PADR(ai_ctest.acouns ,10) AS problem, ;
	"AI_CTEST" AS sourcefile, "ACOUNS    " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_ctest ;
WHERE ;
	!EMPTY(ai_ctest.acouns) AND ;
	ai_ctest.acouns NOT IN ;
		(SELECT c_t_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"AICTEST2" AS prob_type, ai_ctest.tc_id, ai_ctest.cts_id AS act_id,  ;
	PADR(ai_ctest.b1couns ,10) AS problem, ;
	"AI_CTEST" AS sourcefile, "B1COUNS   " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_ctest ;
WHERE ;
	!EMPTY(ai_ctest.b1couns) AND ;
	ai_ctest.b1couns NOT IN ;
		(SELECT c_t_id FROM staffcur) ;
UNION ALL ;
SELECT ;
	"AICTEST3" AS prob_type, ai_ctest.tc_id, ai_ctest.cts_id AS act_id,  ;
	PADR(ai_ctest.b2couns ,10) AS problem, ;
	"AI_CTEST" AS sourcefile, "B2COUNS   " AS prob_field, "USERPROF" AS prob_file ;
FROM ;
	ai_ctest ;
WHERE ;
	!EMPTY(ai_ctest.b2couns) AND ;
	ai_ctest.b2couns NOT IN ;
		(SELECT c_t_id FROM staffcur) ;
INTO CURSOR ;
	prob_cur32

USE IN ai_ctest

* jss, 9/2000, some more checks for ai_case.refdate,ai_case.dlasthosp
SELECT ;
	"AI_CASE5" AS prob_type, ai_case.tc_id, ai_case.ai_case_id AS act_id,  ;
	PADR(DTOC(ai_case.refdate) ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "REFDATE   " AS prob_field, "AI_CASE " AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ai_case.refdate) AND ;
	!BETWEEN(ai_case.refdate,{01/01/1950},DATE()) ;
UNION ALL ;
SELECT ;
	"AI_CASE6" AS prob_type, ai_case.tc_id, ai_case.ai_case_id AS act_id,  ;
	PADR(DTOC(ai_case.dlasthosp) ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "DLASTHOSP " AS prob_field, "AI_CASE " AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(ai_case.dlasthosp) AND ;
	!BETWEEN(ai_case.dlasthosp,{01/01/1900},DATE()) ;
INTO CURSOR ;
	prob_cur33

USE IN ai_case

* jss, 9/2000, add more checks for ai_ref.need_dt, client.dob (for collaterals), group.start_dt
SELECT ;
	"NEEDDATE" AS prob_type, ai_ref.tc_id, ai_ref.ref_id AS act_id, ;
	PADR(DTOC(ai_ref.need_dt) ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "NEED_DT   " AS prob_field, "AI_REF  " AS prob_file ;
FROM ;
	ai_ref ;
WHERE ;
	!EMPTY(need_dt) AND ;
	!BETWEEN(need_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"DOBDATE2" AS prob_type, REPL('Z',10) AS tc_id, ai_famil.client_id AS act_id, ;
	PADR(DTOC(dob) ,10) AS problem, ;
	"CLIENT  " AS sourcefile, "DOB       " AS prob_field, "        " AS prob_file ;
FROM ;
	client, ai_famil, ai_clien ;
WHERE ;
	client.client_id = ai_famil.client_id AND ;
	ai_famil.tc_id = ai_clien.tc_id AND ;
	!EMPTY(client.dob) AND ;
	!BETWEEN(client.dob, {01/01/1900}, DATE()) ;
UNION ALL ;
SELECT ;
	"GROUP02 " AS prob_type, REPL('Z',10) AS tc_id, PADR(group.grp_id,10) AS act_id,  ;
	PADR(DTOC(group.start_dt) ,10) AS problem, ;
	"GROUP   " AS sourcefile, "START_DT  " AS prob_field, "GROUP   " AS prob_file ;
FROM ;
	group ;
WHERE ;
	!BETWEEN(group.start_dt, {01/01/1950}, DATE()) ;
INTO CURSOR ;
	prob_cur34

USE IN ai_ref
USE IN ai_clien
USE IN client
USE IN group
USE IN ai_famil

* jss, 11/9/00, re-write duplicate record checks for ai_site, ai_activ (use tc_id+effect_dt+time+am_pm combo)

SELECT 	tc_id,     ;
		 	effect_dt, ;
		 	IIF(empty(time), '1200', time) AS Ttime, ;
		 	IIF(empty(am_pm), 'AM', am_pm) AS Tam_pm, ;
		 	count(*) ;
FROM 		ai_site ;
GROUP BY tc_id, effect_dt, Ttime, Tam_pm ;
HAVING COUNT(*) > 1;
INTO CURSOR sitetemp

SELECT 	tc_id,     ;
		 	effect_dt, ;
		 	IIF(empty(time), '1200', time) AS Ttime, ;
		 	IIF(empty(am_pm), 'AM', am_pm) AS Tam_pm, ;
		 	count(*) ;
FROM 		ai_activ ;
GROUP BY tc_id, effect_dt, Ttime, Tam_pm ;
HAVING COUNT(*) > 1;
INTO CURSOR activtmp

SELECT ;
	"SITEDUP " AS prob_type, sitetemp.tc_id, PADR(ai_site.sites_id ,10) AS act_id,  ;
	PADR(DTOC(sitetemp.effect_dt) ,10) AS problem, ;
	"AI_SITE " AS sourcefile, "EFFECT_DT " AS prob_field, SPACE(8) AS prob_file ;
FROM ;
	sitetemp, ai_site ;
WHERE ;
	sitetemp.tc_id     = ai_site.tc_id AND ;
	sitetemp.effect_dt = ai_site.effect_dt AND ;
	sitetemp.Ttime     = IIF(EMPTY(ai_site.time), '1200', ai_site.time) AND; 
	sitetemp.Tam_pm    = IIF(EMPTY(ai_site.am_pm), 'AM', ai_site.am_pm) ; 
UNION ALL ;
SELECT ;
	"ACTIVDUP " AS prob_type, activtmp.tc_id, PADR(ai_activ.as_id ,10) AS act_id,  ;
	PADR(DTOC(activtmp.effect_dt) ,10) AS problem, ;
	"AI_ACTIV" AS sourcefile, "EFFECT_DT " AS prob_field, SPACE(8) AS prob_file ;
FROM ;
	activtmp, ai_activ ;
WHERE ;
	activtmp.tc_id     = ai_activ.tc_id AND ;
	activtmp.effect_dt = ai_activ.effect_dt AND ;
	activtmp.Ttime     = IIF(EMPTY(ai_activ.time), '1200', ai_activ.time) AND; 
	activtmp.Tam_pm    = IIF(EMPTY(ai_activ.am_pm), 'AM', ai_activ.am_pm) ; 
INTO CURSOR ;
	prob_cur35

USE IN sitetemp
USE IN activtmp

* jss, 9/2000, add more checks for missing program record, program rec with overlapping start/end dates

*SELECT * FROM ai_prog INTO TABLE aip
Select * from ai_prog Where .t. Into cursor aip

SELECT ;
	"STARTDT " AS prob_type, ai_prog.tc_id, PADR(ai_prog.program,10) AS act_id, ;
	PADR(ai_prog.start_dt, 10) AS problem, ;
	"AI_PROG " AS sourcefile, "START_DT  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_prog, aip ;
WHERE ;
	ai_prog.tc_id   = aip.tc_id   AND ;
	ai_prog.program = aip.program AND ;
	ai_prog.ps_id  <> aip.ps_id   AND ;
	((aip.start_dt >= ai_prog.start_dt AND (aip.start_dt < ai_prog.end_dt OR EMPTY(ai_prog.end_dt))) OR ;
	(aip.start_dt < ai_prog.start_dt AND (EMPTY(aip.end_dt) OR aip.end_dt > ai_prog.start_dt))) ;
UNION ALL ;
SELECT ;
	"AIPROG2 " AS prob_type, ai_prog.tc_id, ai_prog.ps_id AS act_id, ;
	PADR(ai_prog.program ,10) AS problem, ;
	"AI_PROG " AS sourcefile, "PROGRAM   " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_prog ;
WHERE ;
	ai_prog.program  NOT IN ;
		(SELECT prog_id FROM program) ;
UNION ALL ;
SELECT ;
	"AI_WORK4" AS prob_type, ai_work.tc_id, ai_work.ws_id  AS act_id,  ;
	PADR(ai_work.program ,10) AS problem, ;
	"AI_WORK " AS sourcefile, "PROGRAM   " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_work ;
WHERE ;
	!EMPTY(ai_work.program) AND ;
	ai_work.program NOT IN ;
		(SELECT prog_id FROM program) ;
INTO CURSOR ;
	prob_cur36

USE IN aip
USE IN ai_work
USE IN ai_prog

* jss, 9/2000, add more checks for missing group 
* jss, 4/10/01, add check for grpatt.grp_id missing from group.dbf; bad testres.resdate
* 4/10/01, for testres.testdate, must use dob when available
SELECT ;
	"AI_GRP03" AS prob_type, ai_grp.tc_id, ai_grp.gs_id AS act_id, ;
	PADR(ai_grp.group ,10) AS problem, ;
	"AI_GRP  " AS sourcefile, "GROUP     " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_grp ;
WHERE ;
	ai_grp.group  NOT IN ;
		(SELECT grp_id FROM group) ;
UNION ALL ;
SELECT ;
	"GRPATT06" AS prob_type, REPLICATE('Z', 10) AS tc_id, grpatt.att_id AS act_id,  ;
	PADR(grpatt.grp_id ,10) AS problem, ;
	"GRPATT  " AS sourcefile, "GRP_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	grpatt ;
WHERE ;
	grpatt.grp_id  NOT IN ;
		(SELECT grp_id FROM group) ;
UNION ALL ;
SELECT ;
	"GRPATT04" AS prob_type, ai_enc.tc_id, ai_enc.act_id,  ;
	PADR(ai_enc.att_id ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "ATT_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.att_id) AND ;
	ai_enc.att_id NOT IN ;
		(SELECT att_id FROM grpatt) ;
UNION ALL ;
SELECT ;
	"RESDATE " AS prob_type, testres.tc_id, testres.labt_id AS act_id, ;
	PADR(DTOC(testres.resdate) ,10) AS problem, ;
	"TESTRES " AS sourcefile, "RESDATE   " AS prob_field, "        " AS prob_file ;
FROM ;
	testres, ai_clien, client ;
WHERE ;
	!EMPTY(testres.resdate) AND ;
	testres.tc_id      = ai_clien.tc_id AND ;
	ai_clien.client_id = client.client_id AND ;
	(testres.resdate < MAX(client.dob , {01/01/1950}) OR ; 
	testres.resdate > DATE()) ;
UNION ALL ;
SELECT ;
	"TESTDATE" AS prob_type, testres.tc_id, testres.labt_id AS act_id, ;
	PADR(DTOC(testres.testdate) ,10) AS problem, ;
	"TESTRES " AS sourcefile, "TESTDATE  " AS prob_field, "        " AS prob_file ;
FROM ;
	testres, ai_clien, client ;
WHERE ;
	testres.tc_id      = ai_clien.tc_id AND ;
	ai_clien.client_id = client.client_id AND ;
	(testres.testdate < MAX(client.dob , {01/01/1950}) OR ; 
	testres.testdate > DATE()) ;
INTO CURSOR ;
	prob_cur37

USE IN ai_clien
USE IN client
USE IN ai_grp
USE IN ai_enc
USE IN testres
USE IN grpatt

* jss, 9/2000, add more checks for missing client record
SELECT ;
	"FAMILCLI" AS prob_type, REPL('Z', 10) AS tc_id, ai_famil.client_id AS act_id, ;
	PADR(ai_famil.client_id ,10) AS problem, ;
	"AI_FAMIL" AS sourcefile, "CLIENT_ID " AS prob_field, "CLIENT  " AS prob_file ;
FROM ;
	ai_famil ;
WHERE ;
	ai_famil.client_id NOT IN ;
		(SELECT client_id FROM client) ;
UNION ALL ;
SELECT ;
	"COLENCLI" AS prob_type, REPL('Z', 10) AS tc_id, ai_colen.client_id AS act_id, ;
	PADR(ai_colen.client_id ,10) AS problem, ;
	"AI_COLEN" AS sourcefile, "CLIENT_ID " AS prob_field, "CLIENT  " AS prob_file ;
FROM ;
	ai_colen ;
WHERE ;
	ai_colen.client_id NOT IN ;
		(SELECT client_id FROM client) ;
UNION ALL ;
SELECT ;
	"CLIHOCLI" AS prob_type, REPL('Z', 10) AS tc_id, cli_hous.client_id AS act_id, ;
	PADR(cli_hous.client_id ,10) AS problem, ;
	"CLI_HOUS" AS sourcefile, "CLIENT_ID " AS prob_field, "CLIENT  " AS prob_file ;
FROM ;
	cli_hous ;
WHERE ;
	cli_hous.client_id NOT IN ;
		(SELECT client_id FROM client) ;
UNION ALL ;
SELECT ;
	"STATCLI " AS prob_type, status.tc_id, status.client_id AS act_id, ;
	PADR(status.client_id ,10) AS problem, ;
	"STATUS  " AS sourcefile, "CLIENT_ID " AS prob_field, "CLIENT  " AS prob_file ;
FROM ;
	status ;
WHERE ;
	status.client_id NOT IN ;
		(SELECT client_id FROM client) ;
INTO CURSOR ;
	prob_cur38

USE IN ai_famil
USE IN ai_colen
USE IN cli_hous
USE IN status

* jss, 11/6/00, create cursor of services that includes ai_enc.enc_type.
SELECT ai_serv.tc_id, ai_serv.serv_id, ai_serv.serv_cat, ai_enc.enc_type, ai_serv.service ;
	FROM ai_serv, ai_enc ;
	WHERE ai_serv.act_id = ai_enc.act_id ;
	INTO CURSOR encserv

* jss, 9/2000, add more checks for mismatched/invalid services and encounters
SELECT ;
	"SRVCAT  " AS prob_type, ai_enc.tc_id , ai_serv.serv_id as act_id, ;
	PADR(ai_serv.serv_cat ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "SERV_CAT  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc, ai_serv ;
WHERE ;
	ai_enc.act_id = ai_serv.act_id AND ;
	ai_enc.serv_cat  IN (SELECT code FROM serv_cat) AND ;
	ai_serv.serv_cat IN (SELECT code FROM serv_cat) AND ;
	ai_enc.serv_cat <> ai_serv.serv_cat ;
UNION ALL ;
SELECT ;
	"ENC_TYPE" AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.enc_type,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "ENC_TYPE  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	ai_enc.serv_cat IN (SELECT code FROM serv_cat) AND ;
	ai_enc.serv_cat + ai_enc.enc_type NOT IN ;
		(SELECT serv_cat + code FROM enc_type) ;
UNION ALL ;
SELECT ;
	"ENCSRVC " AS prob_type, ai_enc.tc_id, ai_enc.act_id, ;
	PADR(ai_enc.serv_cat,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "SERV_CAT" AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	ai_enc.serv_cat NOT IN (SELECT code FROM serv_cat) ;
UNION ALL ;
SELECT ;
	"SERVICE " AS prob_type, encserv.tc_id, encserv.serv_id as act_id, ;
	PADR(encserv.service,10) AS problem, ;
	"AI_SERV " AS sourcefile, "SERVICE   " AS prob_field, "        " AS prob_file ;
FROM ;
	encserv ;
WHERE ;
	encserv.serv_cat IN (SELECT code FROM serv_cat) AND ;
	encserv.serv_cat + encserv.enc_type + encserv.service NOT IN ;
		(SELECT serv_cat + enc_type + code FROM service) ;
UNION ALL ;
SELECT ;
	"SERVSRVC" AS prob_type, ai_serv.tc_id, ai_serv.serv_id as act_id, ;
	PADR(ai_serv.serv_cat,10) AS problem, ;
	"AI_SERV " AS sourcefile, "SERV_CAT  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	ai_serv.serv_cat NOT IN (SELECT code FROM serv_cat) ;
INTO CURSOR ;
	prob_cur39

USE IN ai_enc
USE IN ai_serv
USE IN encserv

************************************************
* jss, 11/10/00, add checks for ai_incom.act_dt (application date) and ai_incom.effect_dt (activation date)
SELECT DISTINCT ;
	ai_incom.tc_id, client.dob ;
FROM	;
	ai_incom, ai_clien, client ;
WHERE ;
	ai_incom.tc_id = ai_clien.tc_id AND ;
	ai_clien.client_id = client.client_id ;
INTO CURSOR incomcli

* jss, 4/10/01, add checks for status.start_dt, status.effect_dt
SELECT DISTINCT;
	"INCEXP  " AS prob_type, ai_incom.tc_id, ai_incom.incom_id as act_id, ;
	PADR(ai_incom.exp_dt,10) AS problem, ;
	"AI_INCOM" AS sourcefile, "EXP_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_incom, incomcli ;
WHERE ;
   !EMPTY(ai_incom.exp_dt) AND ; 
	ai_incom.tc_id = incomcli.tc_id AND ;
	(ai_incom.exp_dt > DATE() OR ;
	ai_incom.exp_dt < IIF(!EMPTY(incomcli.dob), incomcli.dob, {01/01/1980})) ;
UNION ;
SELECT DISTINCT;
	"INCACT  " AS prob_type, ai_incom.tc_id, ai_incom.incom_id as act_id, ;
	PADR(ai_incom.act_dt,10) AS problem, ;
	"AI_INCOM" AS sourcefile, "ACT_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_incom, incomcli ;
WHERE ;
   !EMPTY(ai_incom.act_dt) AND ; 
	ai_incom.tc_id = incomcli.tc_id AND ;
	(ai_incom.act_dt > DATE() OR ;
	ai_incom.act_dt < IIF(!EMPTY(incomcli.dob), incomcli.dob, {01/01/1980})) ;
UNION ALL ;
SELECT ;
	DISTINCT "AI_OUTZP" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outzp.act_id,  ;
	PADR(ai_outzp.zip ,10) AS problem, ;
	"AI_OUTZP" AS sourcefile, "ZIP       " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outzp ;
WHERE ;
	EMPTY(ai_outzp.zip) ;
UNION ALL ;
SELECT ;
	"STATSTRT" AS prob_type, status.tc_id, status.client_id AS act_id, ;
	PADR(DTOC(status.start_dt) ,10) AS problem, ;
	"STATUS  " AS sourcefile, "START_DT  " AS prob_field, "        " AS prob_file ;
FROM ;
	status, ai_clien ;
WHERE ;
	status.client_id = ai_clien.client_id AND ;
	status.start_dt <> ai_clien.placed_dt AND ;
	NOT EMPTY(ai_clien.placed_dt) ;
UNION ALL ;
SELECT ;
	"STATEFCT" AS prob_type, status.tc_id, status.client_id AS act_id, ;
	PADR(DTOC(status.effect_dt) ,10) AS problem, ;
	"STATUS  " AS sourcefile, "EFFECT_DT " AS prob_field, "        " AS prob_file ;
FROM ;
	status, ai_clien ;
WHERE ;
	status.client_id = ai_clien.client_id AND ;
	status.effect_dt <> ai_clien.placed_dt AND ;
	NOT EMPTY(ai_clien.placed_dt) ;
INTO CURSOR ;
	prob_cur40

USE IN ai_incom
USE IN incomcli
USE IN ai_clien
USE IN client
USE IN ai_outzp
USE IN status

* jss, 11/13/00, add code to check supporting eto tables

SELECT ;
	DISTINCT "AI_OUT3 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outfc.act_id,  ;
	PADR(ai_outfc.act_id ,10) AS problem, ;
	"AI_OUTFC" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outfc ;
WHERE ;
	ai_outfc.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
UNION ALL ;		
SELECT ;
	DISTINCT "AI_OUT4 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outmd.act_id,  ;
	PADR(ai_outmd.act_id ,10) AS problem, ;
	"AI_OUTMD" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outmd ;
WHERE ;
	ai_outmd.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
UNION ALL ;		
SELECT ;
	DISTINCT "AI_OUT5 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outmt.act_id,  ;
	PADR(ai_outmt.act_id ,10) AS problem, ;
	"AI_OUTMT" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outmt ;
WHERE ;
	ai_outmt.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
UNION ALL ;		
SELECT ;
	DISTINCT "AI_OUT6 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outsp.act_id,  ;
	PADR(ai_outsp.act_id ,10) AS problem, ;
	"AI_OUTSP" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outsp ;
WHERE ;
	ai_outsp.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
UNION ALL ;		
SELECT ;
	DISTINCT "AI_OUT7 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outst.act_id,  ;
	PADR(ai_outst.act_id ,10) AS problem, ;
	"AI_OUTST" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outst ;
WHERE ;
	ai_outst.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
UNION ALL ;		
SELECT ;
	DISTINCT "AI_OUT8 " AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outzp.act_id,  ;
	PADR(ai_outzp.act_id ,10) AS problem, ;
	"AI_OUTZP" AS sourcefile, "ACT_ID    " AS prob_field, "AI_OUTR " AS prob_file ;
FROM ;
	ai_outzp ;
WHERE ;
	ai_outzp.act_id NOT IN ;
		(SELECT act_id FROM ai_outr) ;
INTO CURSOR ;
	prob_cur41
	
* 11/16/00, jss, add code to check for invalid entries in supporting ETO tables AI_OUTPB, MT, MD, SP
SELECT ;
	DISTINCT "AI_OUTPB" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outpb.act_id,  ;
	PADR(ai_outpb.code ,10) AS problem, ;
	"AI_OUTPB" AS sourcefile, "CODE      " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outpb ;
WHERE ;
	ai_outpb.code NOT IN ;
		(SELECT code FROM pres_by) ;
UNION ALL ;	
SELECT ;
	DISTINCT "AI_OUTMT" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outmt.act_id,  ;
	PADR(ai_outmt.material ,10) AS problem, ;
	"AI_OUTMT" AS sourcefile, "MATERIAL  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outmt ;
WHERE ;
	ai_outmt.material NOT IN ;
		(SELECT code FROM material) ;
UNION ALL ;	
SELECT ;
	DISTINCT "AI_OUTMD" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outmd.act_id,  ;
	PADR(ai_outmd.code ,10) AS problem, ;
	"AI_OUTMD" AS sourcefile, "CODE      " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outmd ;
WHERE ;
	ai_outmd.code NOT IN ;
		(SELECT code FROM delivery) ;
UNION ALL ;	
SELECT ;
	DISTINCT "AI_OUTSP" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outsp.act_id,  ;
	PADR(ai_outsp.outrserv ,10) AS problem, ;
	"AI_OUTSP" AS sourcefile, "OUTRSERV  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outsp ;
WHERE ;
	ai_outsp.outrserv NOT IN ;
		(SELECT code FROM outrserv) ;
INTO CURSOR ;
	prob_cur42

USE IN ai_outr
USE IN ai_outfc
USE IN ai_outmd
USE IN ai_outmt
USE IN ai_outsp
USE IN ai_outst
USE IN ai_outzp
USE IN pres_by
USE IN material
USE IN delivery
USE IN outrserv

* jss, 12/17/00, add code to account for bad att_id in ai_serv. Also,  check for missing staff worker for group leaders
* jss, 1/22/01, use ai_serv.serv_id for act_id in order to produce correct "INFORMATION" on report
SELECT ;
	"GRPATT05" AS prob_type, ai_serv.tc_id, ai_serv.serv_id AS act_id,  ;
	PADR(ai_serv.att_id ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "ATT_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(ai_serv.att_id) AND ;
	ai_serv.att_id NOT IN ;
		(SELECT att_id FROM grpatt) ;
UNION ALL ;
SELECT ;
	"GRPLEAD1" AS prob_type, REPL('Z',10) AS tc_id, PADR(group.grp_id,10) AS act_id,  ;
	PADR(group.leader_id1 ,10) AS problem, ;
	"GROUP   " AS sourcefile, "LEADER_ID1" AS prob_field, "        " AS prob_file ;
FROM ;
	group ;
WHERE ;
	!EMPTY(leader_id1) AND ;
	leader_id1 NOT IN ;
		(SELECT worker_id FROM staffcur)  ;
UNION ALL ;
SELECT ;
	"GRPLEAD2" AS prob_type, REPL('Z',10) AS tc_id, PADR(group.grp_id,10) AS act_id,  ;
	PADR(group.leader_id2 ,10) AS problem, ;
	"GROUP   " AS sourcefile, "LEADER_ID2" AS prob_field, "        " AS prob_file ;
FROM ;
	group ;
WHERE ;
	!EMPTY(leader_id2) AND ;
	leader_id2 NOT IN ;
		(SELECT worker_id FROM staffcur)  ;
UNION ALL ;
SELECT ;
	"COLENACT" AS prob_type, REPL('Z', 10) AS tc_id, ai_colen.client_id AS act_id, ;
	PADR(ai_colen.act_id ,10) AS problem, ;
	"AI_COLEN" AS sourcefile, "ACT_ID    " AS prob_field, "AI_ENC  " AS prob_file ;
FROM ;
	ai_colen ;
WHERE ;
	ai_colen.act_id NOT IN ;
		(SELECT act_id FROM ai_enc) ;
INTO CURSOR ;
	prob_cur43

USE IN ai_colen
USE IN ai_serv
USE IN ai_enc
USE IN group
USE IN grpatt

* jss, 1/22/2001, add code to check for: invalid client_id in insstat, blank ref_id in ai_ref, 
*                                     invalid userprof start date, invalid date of last ob/gyn 
*                                     in ai_case, invalid xray date in tbstatus
* jss, 2/9/01, add code for ai_case.dlastprimv, same check as dlastobgyn
SELECT ;
	"INSSTATC" AS prob_type, REPLICATE('Z', 10) AS tc_id, insstat.client_id AS act_id,  ;
	PADR(insstat.client_id ,10) AS problem, ;
	"INSSTAT " AS sourcefile, "CLIENT_ID " AS prob_field, "        " AS prob_file ;
FROM ;
	insstat ;
WHERE ;
	insstat.client_id NOT IN ;
		(SELECT client_id FROM client) ;
UNION ;
SELECT ;
	"AIREFID " AS prob_type, tc_id, act_id, ;
	PADR(ref_id ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "REF_ID    " AS prob_field, "        " AS prob_file  ;
FROM ;
	ai_ref ;
WHERE ;
	EMPTY(ref_id) ;
UNION ;
SELECT ;
	"USERSTDT" AS prob_type, REPL('Z',10) AS tc_id, PADR(userprof.staff_id ,10)  AS act_id, ;
	PADR(userprof.date_start,10) AS problem, ;
	"USERPROF" AS sourcefile, "DATE_START" AS prob_field, "        " AS prob_file ;
FROM ;
	userprof ;
WHERE ;
   !EMPTY(date_start) AND ;
	!BETWEEN(date_start, {01/01/1950}, DATE()) ;
UNION ;
SELECT ;
	"CASPRIMV" AS prob_type, ai_case.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_case.dlastprimv) ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "DLASTPRIMV" AS prob_field, "        " AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(dlastprimv) AND !BETWEEN(dlastprimv, {01/01/1950}, DATE()) ;
UNION ;
SELECT ;
	"CASOBGYN" AS prob_type, ai_case.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_case.dlastobgyn) ,10) AS problem, ;
	"AI_CASE " AS sourcefile, "DLASTOBGYN" AS prob_field, "        " AS prob_file ;
FROM ;
	ai_case ;
WHERE ;
	!EMPTY(dlastobgyn) AND !BETWEEN(dlastobgyn, {01/01/1950}, DATE()) ;
INTO CURSOR ;
	prob_cur44

USE IN userprof
USE IN insstat
USE IN client
USE IN ai_ref
USE IN ai_case

* jss, 7/5/01, newly formed prob_cur45, using selects taken from other places and dumped here
*              in order to accomodate bunching the tbstatus date checks in PROB_CUR2
* jss, 6/30/03, move DIAGDATE below

SELECT ;
	"DOBDATE " AS prob_type, ai_clien.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(dob) ,10) AS problem, ;
	"CLIENT  " AS sourcefile, "DOB       " AS prob_field, "        " AS prob_file ;
FROM ;
	client, ai_clien ;
WHERE ;
	client.client_id = ai_clien.client_id AND ;
	!EMPTY(dob) AND ;
	!BETWEEN(dob, {01/01/1900}, DATE()) ;
UNION ALL ;
SELECT ;
	"HIVDATE " AS prob_type, hivstat.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(hivstat.effect_dt) ,10) AS problem, ;
	"HIVSTAT " AS sourcefile, "EFFECT_DT " AS prob_field, "        " AS prob_file ;
FROM ;
	hivstat ;
WHERE ;
	!BETWEEN(effect_dt, {01/01/1950}, DATE()) ;
UNION ALL ;
SELECT ;
	"AI_WORK3" AS prob_type, ai_work.tc_id, ai_work.ws_id AS act_id,  ;
	PADR(DTOC(ai_work.effect_dt) ,10) AS problem, ;
	"AI_WORK " AS sourcefile, "EFFECT_DT " AS prob_field, SPACE(8) AS prob_file ;
FROM ;
	ai_work ;
WHERE ;
	!BETWEEN(ai_work.effect_dt, {01/01/1950}, DATE()); 
UNION ALL ;
SELECT ;
	"INSSTAT5" AS prob_type, REPL('Z',10) AS tc_id, insstat.insstat_id AS act_id, ;
	PADR(insstat.prov_id,10) AS problem, ;
	"INSSTAT " AS sourcefile, "PROV_ID   " AS prob_field, "        " AS prob_file ;
FROM ;
	insstat ;
WHERE ;
	!EMPTY(insstat.prov_id) AND insstat.prov_id NOT IN (SELECT prov_id FROM med_prov) ;
INTO CURSOR ;
	prob_cur45
	
*--VT 09/11/2002 Overlapping Dates for Primary Insurance   

Select client_id, ;
	effect_dt, ;
	exp_dt, ;
	insstat_id ;
From ;
	insstat ;
Where ;
	prim_sec = 1 and ;
	!Empty(exp_dt) ;
Into Cursor t_ins

Select insstat.client_id, ;
	insstat.effect_dt, ;
	insstat.exp_dt, ;
	insstat.insstat_id ;
From ;
	insstat, ;
	t_ins ;
Where ;
	insstat.prim_sec = 1 and ;
	Empty(insstat.exp_dt)  and ;
	insstat.client_id = t_ins.client_id and ;
	insstat.effect_dt < t_ins.exp_dt ;
Into Cursor t_insemp

Select ;
	"INSSTAT6" AS prob_type, ;
	ai_clien.tc_id, ;
	t_insemp.insstat_id AS act_id, ;
	Padr(Dtoc(t_insemp.effect_dt), 10) AS problem, ;
	"INSSTAT " AS sourcefile, ;
	"EFFECT_DT " AS prob_field, ;
	"        " AS prob_file ;
From ;
	t_insemp,  ;
	ai_clien ;
Where ;
	t_insemp.client_id = ai_clien.client_id ;
Into Cursor ;
		prob_cur73

USE IN insstat
USE IN med_prov
USE IN client
USE IN ai_clien
USE IN hivstat
USE IN ai_work
Use in t_ins
*Use in t_ins1
Use in t_insemp

* jss, 3/12/01, add check for ai_colen.dbf records with no associated ai_famil.dbf record
* first, create a combined cursor of ai_colen and ai_enc
SELECT ;
	ai_colen.act_id, ;
	ai_colen.client_id, ;
	ai_enc.tc_id ;
FROM ;
	ai_colen, ai_enc ;
WHERE ;
	ai_colen.act_id = ai_enc.act_id ;
INTO CURSOR ;
	ColenEnc	

* jss, 3/13/01, add checks for cashlog.check_dt, ai_ref.verif_dt, blank act_id in AI_SERV, 
*               blank act_id in AI_ENC, blank SERV_ID in AI_SERV, blank hshld_id in CLI_HOUS

SELECT ;
	"AICOLEN1" AS prob_type, ColenEnc.tc_id, ColenEnc.act_id, ;
	PADR(ColenEnc.client_id,10) AS problem, ;
	"AI_COLEN" AS sourcefile, "CLIENT_ID " AS prob_field, "        " AS prob_file ;
FROM ;
	ColenEnc ;
WHERE ;
	tc_id + client_id NOT IN (SELECT tc_id + client_id FROM ai_famil) ;
UNION ALL ;
SELECT ;
	"CASHCKDT" AS prob_type, REPL('Z',10) AS tc_id, PADR(CashLog.Check_id,10)  AS act_id, ;
	PADR(CashLog.Check_dt,10) AS problem, ;
	"CASHLOG " AS sourcefile, "CHECK_DT  " AS prob_field, "        " AS prob_file ;
FROM ;
	CashLog ;
WHERE ;
	!EMPTY(check_dt) AND ;
	!BETWEEN(check_dt, {01/01/1980}, DATE()) ;
UNION ALL ;
SELECT ;
	"VERIFDT " AS prob_type, ai_ref.tc_id, ai_ref.ref_id AS act_id, ;
	PADR(DTOC(ai_ref.verif_dt) ,10) AS problem, ;
	"AI_REF  " AS sourcefile, "VERIF_DT  " AS prob_field, "AI_REF  " AS prob_file ;
FROM ;
	ai_ref ;
WHERE ;
	!EMPTY(verif_dt) AND ;
	!BETWEEN(verif_dt, IIF(!EMPTY(ref_dt),ref_dt,{01/01/1950}), DATE()) ;
UNION ALL ;
SELECT ;
	"SERVACTI" AS prob_type, ai_serv.tc_id, ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.act_id ,10) AS problem, ;
	"AI_SERV " AS sourcefile, "ACT_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	EMPTY(act_id) ;
UNION ALL ;
SELECT ;
	"ENCACTID" AS prob_type, ai_enc.tc_id, ai_enc.tc_id AS act_id, ;
	PADR(ai_enc.act_id ,10) AS problem, ;
	"AI_ENC  " AS sourcefile, "ACT_ID    " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	EMPTY(act_id) ;
INTO CURSOR ;
	prob_cur46

USE IN colenenc
USE IN ai_enc
USE IN ai_serv
USE IN ai_ref
USE IN cashlog

* jss, 6/28/01, add check for incomplete (< 5 digits) eto additional zip code
SELECT ;
	"SERVSRVI" AS prob_type, ai_serv.tc_id, ai_serv.act_id, ;
	PADR(ai_serv.serv_id,10) AS problem, ;
	"AI_SERV " AS sourcefile, "SERV_ID   " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	EMPTY(serv_id) ;
UNION ALL ;
SELECT ;
	"SITETIME" AS prob_type, ai_site.tc_id, SPACE(10) AS act_id, ;
	PADR(ai_site.time ,10) AS problem, ;
	"AI_SITE " AS sourcefile, "TIME      " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_site ;
WHERE ;
	EMPTY(time) ;
UNION ALL ;
SELECT ;
	"SITEAMPM" AS prob_type, ai_site.tc_id, SPACE(10) AS act_id, ;
	PADR(ai_site.am_pm ,10) AS problem, ;
	"AI_SITE " AS sourcefile, "AM_PM     " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_site ;
WHERE ;
	EMPTY(am_pm) ;
UNION ALL ;
SELECT ;
	DISTINCT "AI_OUTZ2" AS prob_type, REPLICATE('Z', 10) AS tc_id, ai_outzp.act_id,  ;
	PADR(ai_outzp.zip ,10) AS problem, ;
	"AI_OUTZP" AS sourcefile, "ZIP       " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_outzp ;
WHERE ;
	LEN(TRIM(ai_outzp.zip)) < 5 AND !EMPTY(ai_outzp.zip) ;
UNION ALL ;
SELECT ;
	"HSHLDID " AS prob_type, REPL('Z',10) AS tc_id, cli_hous.client_id AS act_id, ;
	PADR(cli_hous.hshld_id,10) AS problem, ;
	"CLI_HOUS" AS sourcefile, "HSHLD_ID  " AS prob_field, "        " AS prob_file ;
FROM ;
	cli_hous ;
WHERE ;
	EMPTY(hshld_id) ;
INTO CURSOR ;
	prob_cur47

USE IN ai_site
USE IN ai_serv
USE IN ai_outzp
USE IN cli_hous


* jss, 11/5/01, break out invalid from empty prov_id in insstat with code "INSSTAT5"

SELECT ;
	"ADDR_ID " AS prob_type, REPL('Z',10) AS tc_id, address.hshld_id AS act_id, ;
	PADR(address.addr_id,10) AS problem, ;
	"ADDRESS " AS sourcefile, "ADDR_ID   " AS prob_field, "        " AS prob_file ;
FROM ;
	address ;
WHERE ;
	EMPTY(addr_id) ;
UNION ;	
SELECT ;
	"INSSTAT1" AS prob_type, REPL('Z',10) AS tc_id, insstat.insstat_id AS act_id, ;
	PADR(insstat.insstat_id,10) AS problem, ;
	"INSSTAT " AS sourcefile, "INSSTAT_ID" AS prob_field, "        " AS prob_file ;
FROM ;
	insstat ;
WHERE ;
	EMPTY(insstat_id) ;
UNION ;	
SELECT ;
	"INSSTAT2" AS prob_type, REPL('Z',10) AS tc_id, insstat.insstat_id AS act_id, ;
	PADR(insstat.prov_id,10) AS problem, ;
	"INSSTAT " AS sourcefile, "PROV_ID   " AS prob_field, "        " AS prob_file ;
FROM ;
	insstat ;
WHERE ;
	EMPTY(insstat.prov_id) ;
UNION ;	
SELECT ;
	"INSSTAT3" AS prob_type, REPL('Z',10) AS tc_id, insstat.insstat_id AS act_id, ;
	PADR(DTOC(insstat.effect_dt),10) AS problem, ;
	"INSSTAT " AS sourcefile, "EFFECT_DT " AS prob_field, "        " AS prob_file ;
FROM ;
	insstat, client ;
WHERE ;
	insstat.client_id = client.client_id AND ;
	(EMPTY(insstat.effect_dt) OR ;
	insstat.effect_dt > DATE() OR insstat.effect_dt < IIF(!EMPTY(client.dob),client.dob,{01/01/1980})) ;
UNION ;
SELECT ;
	"INSSTAT4" AS prob_type, REPL('Z',10) AS tc_id, insstat.insstat_id AS act_id, ;
	PADR(DTOC(insstat.exp_dt),10) AS problem, ;
	"INSSTAT " AS sourcefile, "EXP_DT    " AS prob_field, "        " AS prob_file ;
FROM ;
	insstat ;
WHERE ;
	!EMPTY(insstat.exp_dt) AND ;
	(insstat.exp_dt < insstat.effect_dt OR insstat.exp_dt > {12/31/2030}) ;
INTO CURSOR ;
	prob_cur48

USE IN insstat
USE IN client
USE IN address

* jss, 1/26/02, add code to prevent empty program.elig_type, empty program.fund_type, empty site.typsetting
SELECT ;
	"ELIGTYPE" AS prob_type, REPL('Z',10) AS tc_id, PADR(program.prog_id,10) AS act_id, ;
	PADR(program.elig_type,10) AS problem, ;
	"PROGRAM " AS sourcefile, "ELIG_TYPE " AS prob_field, "        " AS prob_file ;
FROM ;
	program ;
WHERE ;
	EMPTY(program.elig_type) ;
UNION ;
SELECT ;
	"FUNDTYPE" AS prob_type, REPL('Z',10) AS tc_id, PADR(program.prog_id,10) AS act_id, ;
	PADR(program.fund_type,10) AS problem, ;
	"PROGRAM " AS sourcefile, "FUND_TYPE " AS prob_field, "        " AS prob_file ;
FROM ;
	program ;
WHERE ;
	EMPTY(program.fund_type) ;
UNION ;
SELECT ;
	"TYPSETTG" AS prob_type, REPL('Z',10) AS tc_id, PADR(site.site_id,10) AS act_id, ;
	PADR(site.typsetting,10) AS problem, ;
	"SITE    " AS sourcefile, "TYPSETTING" AS prob_field, "        " AS prob_file ;
FROM ;
	site ;
WHERE ;
	EMPTY(site.typsetting) ;
UNION ;
SELECT ;
	"SITEZIP1" AS prob_type, REPL('Z',10) AS tc_id, PADR(site.site_id,10) AS act_id, ;
	PADR(site.zip,10) AS problem, ;
	"SITE    " AS sourcefile, "ZIP       " AS prob_field, "        " AS prob_file ;
FROM ;
	site ;
WHERE ;
	EMPTY(site.zip) ;
UNION ;	
SELECT ;
	"SITEZIP2" AS prob_type, REPL('Z',10) AS tc_id, PADR(site.site_id,10) AS act_id, ;
	PADR(site.zip,10) AS problem, ;
	"SITE    " AS sourcefile, "ZIP       " AS prob_field, "        " AS prob_file ;
FROM ;
	site ;
WHERE ;
	!EMPTY(site.zip) AND LEN(TRIM(site.zip)) < 5;
INTO CURSOR ;
	prob_cur49

USE IN program
USE IN site

*** VT 05/03/2002  indentify clients whose case is closed in the agency but have encounters/services after the closed date

* jss, 8/18/04, correct code below which is yielding incorrect status field 

***Select tc_id, Max(effect_dt) as max_dt, status ;
***From ai_active  ;
***Into cursor temp1 ;
***Group by tc_id 

* jss, 8/18/04
SELECT ;
	act1.tc_id, ;
	act1.effect_dt as max_dt, ;
	act1.status ;
FROM ;
	ai_activ act1 ;
WHERE ;
	act1.effect_dt IN ;
		(SELECT MAX(act2.effect_dt) FROM ai_activ act2 WHERE act1.tc_id=act2.tc_id) ;
INTO CURSOR ;
	temp1 

Select ai_enc.tc_id, ai_enc.act_dt as date , ai_enc.act_id;
from ai_enc, temp1 ;
where ai_enc.tc_id = temp1.tc_id and ;
	ai_enc.act_dt > temp1.max_dt  And ;
	temp1.status = "C " ; 
Into cursor temp2 

Select "AI_ENC3 " as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_ENC  " AS sourcefile, ;
		"ACT_DT    " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur50 

Use in temp2
Use in ai_enc

Select ai_serv.tc_id, ai_serv.date as date , ai_serv.serv_id as act_id ;
from ai_serv, temp1 ;
where ai_serv.tc_id = temp1.tc_id and ;
	ai_serv.date > temp1.max_dt And ;
	temp1.status ="C " ;
Into cursor temp2 

Select "SRVDATE1" as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_SERV " AS sourcefile, ;
		"DATE      " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur51 

Use in temp2
Use in ai_serv


Select needlx.tc_id, needlx.date as date , needlx.need_id as act_id ;
from needlx, temp1 ;
where needlx.tc_id = temp1.tc_id and ;
	needlx.date > temp1.max_dt  And ;
	temp1.status ="C " ;
Into cursor temp2 

Select "NEEDLX4 " as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"NEEDLX  " AS sourcefile, ;
		"DATE      " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur52 

Use in temp2
Use in needlx

Select ai_ref.tc_id, ai_ref.ref_dt as date , ai_ref.ref_id as act_id ;
from ai_ref, temp1 ;
where ai_ref.tc_id = temp1.tc_id and ;
	ai_ref.ref_dt > temp1.max_dt  And ;
	temp1.status ="C " ;
Into cursor temp2 

Select "AI_REF1 " as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_REF  " AS sourcefile, ;
		"REF_DT    " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur53 

Use in temp2
Use in ai_ref

Select ai_prog.tc_id, ai_prog.end_dt as date , ai_prog.ps_id as act_id ;
from ai_prog, temp1 ;
where ai_prog.tc_id = temp1.tc_id and ;
		!Empty(ai_prog.end_dt) And ;
		ai_prog.end_dt > temp1.max_dt  And ;
		temp1.status ="C " ;
Into cursor temp2 


Select "AI_PROG1" as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_PROG " AS sourcefile, ;
		"END_DT    " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur54 

Use in temp2

Select ai_prog.tc_id, ai_prog.end_dt as date , PADR(ai_prog.program,10) as act_id ;
from ai_prog, temp1 ;
where ai_prog.tc_id = temp1.tc_id and ;
		Empty(ai_prog.end_dt) And ;
		temp1.status ="C " ;
Into cursor temp2 

Select "AI_PROG2" as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_PROG " AS sourcefile, ;
		"END_DT    " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur55 

Use in temp2
Use in ai_prog

Select ai_grp.tc_id, ai_grp.end_dt as date, PADR(ai_grp.group,10) as act_id ;
from ai_grp, temp1 ;
where ai_grp.tc_id = temp1.tc_id and ;
		!Empty(ai_grp.end_dt) And ;
		ai_grp.end_dt > temp1.max_dt And ;
		temp1.status ="C " ;
Into cursor temp2 

Select "AI_GRP04" as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_GRP  " AS sourcefile, ;
		"END_DT    " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur56 

Use in temp2

Select ai_grp.tc_id, ai_grp.end_dt as date, PADR(ai_grp.group,10) as act_id ;
from ai_grp, temp1 ;
where ai_grp.tc_id = temp1.tc_id and ;
		Empty(ai_grp.end_dt) And ;
		temp1.status ="C " ;
Into cursor temp2 


Select "AI_GRP05" as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_GRP  " AS sourcefile, ;
		"END_DT    " AS prob_field, ;
		"AI_ACTIV" AS prob_file ;
From temp2 ;
Into cursor prob_cur57 

Use in temp2
Use in ai_grp


***Program

Select tc_id, max(start_dt) as max_dt,  program, max(end_dt) as end_dt;
From ai_prog,   ;
	program ;
Where !Empty(end_dt) and ;
	ai_prog.program = program.prog_id and ;
	program.enr_req ;
Into cursor temp112 ;
Group by tc_id, program

Select tc_id, max(start_dt) as max_dt,  program, end_dt;
From ai_prog, ;
	program ; 
Where Empty(end_dt) and ;
	ai_prog.program = program.prog_id and ;
	program.enr_req ;
Into cursor temp111 ;
Group by tc_id, program


Select temp112.tc_id, temp112.max_dt, temp112.program, temp112.end_dt ;
From temp112  ; 
Where tc_id+program not in (select tc_id+program from temp111) ;
Into cursor temp11

Use in temp112
Use in temp111

	Select ai_enc.tc_id, ai_enc.act_dt as date , ai_enc.act_id, temp11.program, max_dt, end_dt;
	From ai_enc, temp11 ;
	Where ai_enc.tc_id = temp11.tc_id and ;
		ai_enc.program = temp11.program and ;
		!Empty(temp11.end_dt) and ;
		ai_enc.act_dt > temp11.end_dt ;
	Into cursor temp2 

Select "AI_ENC4 " as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_ENC  " AS sourcefile, ;
		"ACT_DT    " AS prob_field, ;
		"AI_PROG " AS prob_file ;
From temp2 ;
Into cursor prob_cur60 


Use in temp2
Use in ai_enc

*-*Select ai_serv.tc_id, ai_serv.date as date , ai_serv.serv_id as act_id ;
*-*from ai_serv, temp11, ai_enc ;
*-*where ai_serv.tc_id = temp11.tc_id and ;
*-*	ai_serv.act_id = ai_enc.act_id and ;
*-*	ai_enc.program = temp11.program and ;
*-*	!Empty(temp11.end_dt) and ;
*-*	ai_serv.date > temp11.end_dt  ;
*-*Into cursor temp2

Select ai_serv.tc_id, ai_serv.date as date , ai_serv.serv_id as act_id, ai_enc.program ;
from ai_serv, ai_enc ;
where ai_serv.act_id = ai_enc.act_id ;
Into Cursor temp22	
	
Select temp22.tc_id, date, act_id ;	
From temp22, temp11 ;
Where temp22.tc_id = temp11.tc_id and ; 
	temp22.program = temp11.program and ;
	!Empty(temp11.end_dt) and ;
	temp22.date > temp11.end_dt  ;
Into cursor temp2

* ;
*Group by ai_serv.tc_id

Select "SRVDATE2" as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"AI_SERV " AS sourcefile, ;
		"DATE      " AS prob_field, ;
		"AI_PROG " AS prob_file ;
From temp2 ;
Into cursor prob_cur61 

Use in temp22
Use in temp2
Use in ai_serv

Select needlx.tc_id, needlx.date as date , needlx.need_id as act_id ;
from needlx, temp11 ;
where needlx.tc_id = temp11.tc_id and ;
	needlx.program = temp11.program and ;
	!Empty(temp11.end_dt) and ;
	needlx.date > temp11.end_dt  ;
Into cursor temp2 

*;
*Group by needlx.tc_id

Select "NEEDLX5 " as prob_type, ;
		tc_id, ;
		act_id, ;
		Padr(Dtoc(date),10) AS problem, ;
		"NEEDLX  " AS sourcefile, ;
		"DATE      " AS prob_field, ;
		"AI_PROG " AS prob_file ;
From temp2 ;
Into cursor prob_cur62 

Use in temp2
Use in needlx

*** Group Activities
Select "GRPATT07" as prob_type, ;
		Repl('Z',10) AS tc_id, ;
		Padr(group.grp_id,10) AS act_id, ;
		Padr(Dtoc(grpatt.act_dt),10) AS problem, ;
		"GRPATT  " AS sourcefile, ;
		"ACT_DT    " AS prob_field, ;
		"GROUP   " AS prob_file ;
From group,  ;
	grpatt ;
Where group.grp_id = grpatt.grp_id And ;
		!Empty(group.end_dt) And ;
		grpatt.act_dt > group.end_dt ;	
Into cursor prob_cur70 

* jss, 7/9/03, add UNION to grab any group enrollments prior to group start date
*** Group Enrollments
Select	"AI_GRP06" AS prob_type, ;
		ai_grp.tc_id, ;
		Padr(ai_grp.group,10) AS act_id,  ;
		Padr(ai_grp.start_dt ,10) AS problem, ;
		"AI_GRP  " AS sourcefile, ;
		"START_DT  " AS prob_field, ;
		"GROUP   " AS prob_file ;
FROM ai_grp, group ;
Where ai_grp.group = group.grp_id And ;
		!Empty(group.end_dt) And ;
		ai_grp.start_dt > group.end_dt ;
UNION ;
Select	"AI_GRP06" AS prob_type, ;
		ai_grp.tc_id, ;
		Padr(ai_grp.group,10) AS act_id,  ;
		Padr(ai_grp.start_dt ,10) AS problem, ;
		"AI_GRP  " AS sourcefile, ;
		"START_DT  " AS prob_field, ;
		"GROUP   " AS prob_file ;
FROM ai_grp, group ;
Where ai_grp.group = group.grp_id AND;
		ai_grp.start_dt < group.start_dt ;
Into Cursor prob_cur71

*-- Last Closed Group
Select tc_id, max(start_dt) as max_dt,  max(end_dt) as end_dt,group, gs_id ;
From ai_grp ;
Where !Empty(end_dt) ;
Into cursor tmp_cl ;
Group by tc_id, group

*-- Last Open Group
Select tc_id, max(start_dt) as max_dt,  end_dt, group, gs_id;
From ai_grp ;
Where Empty(end_dt) ;
Into cursor tmp_op ;
Group by tc_id, group


Select tmp_cl.tc_id, tmp_cl.max_dt, tmp_cl.end_dt, group, gs_id ;
From tmp_cl  ; 
Where tc_id+group not in (select tc_id+group from tmp_op) ;
Into cursor tmp_grp

Use in tmp_cl
Use in tmp_op

Select	"AI_GRP07" AS prob_type, ;
		tmp_grp.tc_id, ;
		tmp_grp.gs_id AS act_id,  ;
		Padr(ai_enc.act_dt ,10) AS problem, ;
		"AI_ENC  " AS sourcefile, ;
		"ACT_DT    " AS prob_field, ;
		"AI_GRP  " AS prob_file ;
FROM tmp_grp, ai_enc, grpatt ;
Where tmp_grp.group = grpatt.grp_id And ;
		!Empty(tmp_grp.end_dt) And ;
		(grpatt.serv_cat <> '00013' or grpatt.serv_cat <> '00014') And ;
		grpatt.att_id = ai_enc.att_id And ;
		!Empty(tmp_grp.end_dt) and ;
		ai_enc.act_dt > tmp_grp.end_dt  And ;
		ai_enc.tc_id = tmp_grp.tc_id ;
Into Cursor prob_cur72 

Use in ai_enc
use in tmp_grp

* jss, 4/30/03, new check for active group enrollment, but associated required program enrollment is closed
* first, find clients with currently closed program enrollments
SELECT ;
	ap.tc_id, ;
	ap.program ;
FROM ;
	ai_prog ap;
WHERE ;
	!EMPTY(ap.end_dt) ;
AND ap.tc_id + ap.program + DTOS(ap.start_dt) ;
	IN (SELECT ap2.tc_id + ap2.program + MAX(DTOS(ap2.start_dt)) ;
		FROM ai_prog ap2 ;
		GROUP BY ap2.tc_id, ap2.program) ;		
INTO CURSOR ;
	progclos order by 1,2			

* now, find clients with currently open group enrollments for programs requiring enrollment
SELECT ;
	ag.*, group.program ;
FROM ;
	ai_grp ag, group, program ;
WHERE ;
	EMPTY(ag.end_dt) ;
AND ag.group = group.grp_id ;	
AND ag.tc_id + ag.group + DTOS(ag.start_dt) ;
		IN (SELECT ag2.tc_id + ag2.group + MAX(DTOS(ag2.start_dt)) ;
			FROM ai_grp ag2 ;
			GROUP BY ag2.tc_id, ag2.group) ;			
AND group.program = program.prog_id ;
AND program.enr_req ;			
INTO CURSOR ;
	grpopen	order by tc_id, program	

* now, find problem clients in which open group enrollment has closed program enrollment OR doesn't exist 
SELECT ;
	"AI_GRP08" 		AS prob_type, ;
	grpopen.tc_id	AS tc_id, ;
	grpopen.gs_id   AS act_id, ;
	PADR(DTOC(grpopen.end_dt),10) AS problem, ;
	"AI_GRP  " 		AS sourcefile, ;
	"END_DT    " 	AS prob_field, ;
	"AI_PROG " 		AS prob_file ;
FROM ;
	grpopen  ;
WHERE ;
	grpopen.tc_id + grpopen.program ;
		IN (SELECT progclos.tc_id + progclos.program FROM progclos) ;
OR	grpopen.tc_id + grpopen.program ;
		NOT IN (SELECT 	ai_prog.tc_id + ai_prog.program ;
				FROM 	ai_prog, program ;
				WHERE 	ai_prog.program = program.prog_id ;
				AND 	program.enr_req) ;
INTO CURSOR ;
	prob_cur74		

USE IN ai_prog
use in grpopen
use in progclos
Use in ai_grp
Use in grpatt
Use in group

* jss, 6/30/03, add code to handle invalid tm/am fields in ai_enc, ai_serv, ai_outr, needlx
SELECT ;
	"ENCBEGTM" 		AS prob_type, ;
	ai_enc.tc_id	AS tc_id, ;
	ai_enc.act_id   AS act_id, ;
	PADR(ai_enc.beg_tm,10) AS problem, ;
	"AI_ENC  " 		AS sourcefile, ;
	"BEG_TM    " 	AS prob_field, ;
	"AI_ENC  " 		AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.beg_tm) AND !BETWEEN(ai_enc.beg_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0a		 

SELECT ;
	"SRVBEGTM" 		AS prob_type, ;
	ai_serv.tc_id	AS tc_id, ;
	ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.s_beg_tm,10) AS problem, ;
	"AI_SERV " 		AS sourcefile, ;
	"S_BEG_TM  " 	AS prob_field, ;
	"AI_SERV " 		AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(ai_serv.s_beg_tm) AND !BETWEEN(ai_serv.s_beg_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0b		 

SELECT ;
	"OUTBEGTM" 		AS prob_type, ;
	REPLICATE('Z', 10) AS tc_id, ;
	ai_outr.act_id  AS act_id, ;
	PADR(ai_outr.beg_tm,10) AS problem, ;
	"AI_OUTR " 		AS sourcefile, ;
	"BEG_TM    " 	AS prob_field, ;
	"AI_OUTR " 		AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	!EMPTY(ai_outr.beg_tm) AND !BETWEEN(ai_outr.beg_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0c

SELECT ;
	"NDXBEGTM" 		AS prob_type, ;
	needlx.tc_id    AS tc_id, ;
	needlx.need_id  AS act_id, ;
	PADR(needlx.beg_tm,10) AS problem, ;
	"NEEDLX  " 		AS sourcefile, ;
	"BEG_TM    " 	AS prob_field, ;
	"NEEDLX  " 		AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!EMPTY(needlx.beg_tm) AND !BETWEEN(needlx.beg_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0d

SELECT ;
	"ENCBEGAM" 		AS prob_type, ;
	ai_enc.tc_id	AS tc_id, ;
	ai_enc.act_id   AS act_id, ;
	PADR(ai_enc.beg_am,10) AS problem, ;
	"AI_ENC  " 		AS sourcefile, ;
	"BEG_AM    " 	AS prob_field, ;
	"AI_ENC  " 		AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.beg_am) and ai_enc.beg_am <> 'AM' and ai_enc.beg_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0e		 

SELECT ;
	"SRVBEGAM" 		AS prob_type, ;
	ai_serv.tc_id	AS tc_id, ;
	ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.s_beg_am,10) AS problem, ;
	"AI_SERV " 		AS sourcefile, ;
	"BEG_AM    " 	AS prob_field, ;
	"AI_SERV " 		AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(ai_serv.s_beg_am) and ai_serv.s_beg_am <> 'AM' and ai_serv.s_beg_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0f

SELECT ;
	"OUTBEGAM" 		AS prob_type, ;
	REPLICATE('Z', 10) AS tc_id, ;
	ai_outr.act_id  AS act_id, ;
	PADR(ai_outr.beg_am,10) AS problem, ;
	"AI_OUTR " 		AS sourcefile, ;
	"BEG_AM    " 	AS prob_field, ;
	"AI_OUTR " 		AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	!EMPTY(ai_outr.beg_am) and ai_outr.beg_am <> 'AM' and ai_outr.beg_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0g

SELECT ;
	"NDXBEGAM" 		AS prob_type, ;
	needlx.tc_id    AS tc_id, ;
	needlx.need_id  AS act_id, ;
	PADR(needlx.beg_am,10) AS problem, ;
	"NEEDLX  " 		AS sourcefile, ;
	"BEG_AM    " 	AS prob_field, ;
	"NEEDLX  " 		AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!EMPTY(needlx.beg_am) and needlx.beg_am <> 'AM' and needlx.beg_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0h

SELECT ;
	"ENCENDTM" 		AS prob_type, ;
	ai_enc.tc_id	AS tc_id, ;
	ai_enc.act_id   AS act_id, ;
	PADR(ai_enc.end_tm,10) AS problem, ;
	"AI_ENC  " 		AS sourcefile, ;
	"END_TM    " 	AS prob_field, ;
	"AI_ENC  " 		AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.end_tm) AND !BETWEEN(ai_enc.end_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0i	 

SELECT ;
	"SRVENDTM" 		AS prob_type, ;
	ai_serv.tc_id	AS tc_id, ;
	ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.s_end_tm,10) AS problem, ;
	"AI_SERV " 		AS sourcefile, ;
	"S_END_TM  " 	AS prob_field, ;
	"AI_SERV " 		AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(ai_serv.s_end_tm) AND !BETWEEN(ai_serv.s_end_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0j	 

SELECT ;
	"OUTENDTM" 		AS prob_type, ;
	REPLICATE('Z', 10) AS tc_id, ;
	ai_outr.act_id  AS act_id, ;
	PADR(ai_outr.END_tm,10) AS problem, ;
	"AI_OUTR " 		AS sourcefile, ;
	"END_TM    " 	AS prob_field, ;
	"AI_OUTR " 		AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	!EMPTY(ai_outr.END_tm) AND !BETWEEN(ai_outr.END_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0k

SELECT ;
	"NDXENDTM" 		AS prob_type, ;
	needlx.tc_id    AS tc_id, ;
	needlx.need_id  AS act_id, ;
	PADR(needlx.END_tm,10) AS problem, ;
	"NEEDLX  " 		AS sourcefile, ;
	"END_TM    " 	AS prob_field, ;
	"NEEDLX  " 		AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!EMPTY(needlx.END_tm) AND !BETWEEN(needlx.END_tm,'0100','1259') ;
INTO CURSOR ;
	prob_cur0l

SELECT ;
	"ENCENDAM" 		AS prob_type, ;
	ai_enc.tc_id	AS tc_id, ;
	ai_enc.act_id   AS act_id, ;
	PADR(ai_enc.END_am,10) AS problem, ;
	"AI_ENC  " 		AS sourcefile, ;
	"END_AM    " 	AS prob_field, ;
	"AI_ENC  " 		AS prob_file ;
FROM ;
	ai_enc ;
WHERE ;
	!EMPTY(ai_enc.END_am) and ai_enc.END_am <> 'AM' and ai_enc.END_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0m	 

SELECT ;
	"SRVENDAM" 		AS prob_type, ;
	ai_serv.tc_id	AS tc_id, ;
	ai_serv.serv_id AS act_id, ;
	PADR(ai_serv.s_END_am,10) AS problem, ;
	"AI_SERV " 		AS sourcefile, ;
	"END_AM    " 	AS prob_field, ;
	"AI_SERV " 		AS prob_file ;
FROM ;
	ai_serv ;
WHERE ;
	!EMPTY(ai_serv.s_END_am) and ai_serv.s_END_am <> 'AM' and ai_serv.s_END_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0n

SELECT ;
	"OUTENDAM" 		AS prob_type, ;
	REPLICATE('Z', 10) AS tc_id, ;
	ai_outr.act_id  AS act_id, ;
	PADR(ai_outr.END_am,10) AS problem, ;
	"AI_OUTR " 		AS sourcefile, ;
	"END_AM    " 	AS prob_field, ;
	"AI_OUTR " 		AS prob_file ;
FROM ;
	ai_outr ;
WHERE ;
	!EMPTY(ai_outr.END_am) and ai_outr.END_am <> 'AM' and ai_outr.END_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0o

SELECT ;
	"NDXENDAM" 		AS prob_type, ;
	needlx.tc_id    AS tc_id, ;
	needlx.need_id  AS act_id, ;
	PADR(needlx.END_am,10) AS problem, ;
	"NEEDLX  " 		AS sourcefile, ;
	"END_AM    " 	AS prob_field, ;
	"NEEDLX  " 		AS prob_file ;
FROM ;
	needlx ;
WHERE ;
	!EMPTY(needlx.END_am) and needlx.END_am <> 'AM' and needlx.END_am <> 'PM' ;
INTO CURSOR ;
	prob_cur0p

* jss, 6/30/03, only use 1/1/50 if DOB is empty, else, use DOB
SELECT ;
	"DIAGDATE" AS prob_type, ai_diag.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_diag.diagdate) ,10) AS problem, ;
	"AI_DIAG " AS sourcefile, "DIAGDATE  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_diag, client, ai_clien ;
WHERE ;
	ai_diag.tc_id = ai_clien.tc_id AND ;
	ai_clien.client_id = client.client_id  AND ;
	EMPTY(client.dob) AND ;
	(ai_diag.diagdate < {01/01/1950} OR ai_diag.diagdate > DATE()) ;
UNION ;	
SELECT ;
	"DIAGDATE" AS prob_type, ai_diag.tc_id, SPACE(10) AS act_id, ;
	PADR(DTOC(ai_diag.diagdate) ,10) AS problem, ;
	"AI_DIAG " AS sourcefile, "DIAGDATE  " AS prob_field, "        " AS prob_file ;
FROM ;
	ai_diag, client, ai_clien ;
WHERE ;
	ai_diag.tc_id = ai_clien.tc_id AND ;
	ai_clien.client_id = client.client_id  AND ;
	!EMPTY(client.dob) AND ;
	(ai_diag.diagdate < client.dob or ai_diag.diagdate > DATE()) ;
INTO CURSOR ;
	prob_cur0q

USE IN ai_clien
USE IN client
USE IN ai_diag

* jss, 10/15/04, remove this check
* jss, 8/17/04, add check for blank enc_id in ai_ctest
*SELECT ;
*	"ENCID   " AS prob_type, ai_ctest.tc_id, ai_ctest.cts_id AS act_id,;
*	PADR(ai_ctest.enc_id ,10) AS problem, ;
*	"AI_CTEST" AS sourcefile, "ENC_ID    " AS prob_field, "        " AS prob_file ;
*FROM ;
*	ai_ctest ;
*WHERE ;
*	EMPTY(ai_ctest.enc_id) ;
*INTO CURSOR ;
*	prob_cur0r

*USE IN ai_ctest

* jss, 1/3/06, add check for blank fed_id (or fed_id<9 chars)
* jss, 1/3/06, add check for duns id (or duns_id<9 chars)
SELECT ;
	"FEDID   "					AS prob_type, ;
	REPL('Z',10) 				AS tc_id, ;
	PADR(agency,10) 			AS act_id, ;
	PADR(fed_id,10) 			AS problem, ;
	"AGENCY  " 					AS sourcefile, ;
	"FED ID    " 				AS prob_field, ;
	"AGENCY  " 					AS prob_file ;
FROM ;
	agency ;
WHERE ;
	Len(Alltrim(fed_id))<>9 ;                                                                                                     
UNION ;
SELECT ;
	"DUNSID  "					AS prob_type, ;
	REPL('Z',10) 				AS tc_id, ;
	PADR(agency,10) 			AS act_id, ;
	PADR(duns_id,10) 			AS problem, ;
	"AGENCY  " 					AS sourcefile, ;
	"DUNS ID   " 				AS prob_field, ;
	"AGENCY  " 					AS prob_file ;
FROM ;
	agency ;
WHERE ;
	Len(Alltrim(duns_id))<>9 ;                                                                                                     
UNION ;
SELECT ;
	"FOLLOWUP"					AS prob_type, ;
	tc_id, ;
	ref_id			 			AS act_id, ;
	PADR(TRIM(STR(followup)),10)	AS problem, ;
	"AI_REF  " 					AS sourcefile, ;
	"FOLLOWUP  " 				AS prob_field, ;
	"AI_REF  " 					AS prob_file ;
FROM ;
	ai_ref ;
WHERE ;
	ref_cat='950' and Empty(followup) ;                                                                                                     
INTO CURSOR ;
	prob_cur0r

* jss, 1/03/06, add checks for empty pems site type, site state, site county (fips)
SELECT DISTINCT;
	"SITETYPE"					AS prob_type, ;
	REPL('Z',10) 				AS tc_id, ;
	PADR(site_id,10) 			AS act_id, ;
	PADR(psite_type,10)			AS problem, ;
	"SITE    " 					AS sourcefile, ;
	"PSITE_TYPE" 				AS prob_field, ;
	"SITE    " 					AS prob_file ;
FROM ;
	site ;
WHERE ;
	Empty(psite_type) ;                                                                                                     
UNION ;	
SELECT DISTINCT;
	"SITEST  "					AS prob_type, ;
	REPL('Z',10) 				AS tc_id, ;
	PADR(site_id,10) 			AS act_id, ;
	PADR(psite_type,10)			AS problem, ;
	"SITE    " 					AS sourcefile, ;
	"ST        " 				AS prob_field, ;
	"SITE    " 					AS prob_file ;
FROM ;
	site ;
WHERE ;
	Empty(st) ;     
UNION ;                                                                                                
SELECT DISTINCT;
	"SITECNTY"					AS prob_type, ;
	REPL('Z',10) 				AS tc_id, ;
	PADR(site_id,10) 			AS act_id, ;
	PADR(psite_cnty,10)			AS problem, ;
	"SITE    " 					AS sourcefile, ;
	"PSITE_CNTY" 				AS prob_field, ;
	"SITE    " 					AS prob_file ;
FROM ;
	site ;
WHERE ;
	Empty(psite_cnty) ;                                                                                                     
INTO CURSOR ;
	prob_cur0s

Select * from Prob_cur0r ;
Union ;
Select * from Prob_cur0s ;
Into Cursor ;
Prob_cr0x

******************************
* Merge everything
SELECT * FROM prob_cur1 ;
UNION ALL ;
SELECT * FROM prob_cur1a ;
UNION ALL ;
SELECT * FROM prob_cur8 ;
UNION ALL ;
SELECT * FROM prob_cur9 ;
UNION ALL ;
SELECT * FROM prob_cur10 ;
UNION ALL ;
SELECT * FROM prob_cur11 ;
INTO CURSOR prob_cr1

USE IN prob_cur1
USE IN prob_cur1a
USE IN prob_cur8
USE IN prob_cur9
USE IN prob_cur10
USE IN prob_cur11

SELECT * FROM prob_cur14 ;
UNION ALL ;
SELECT * FROM prob_cur23 ;
UNION ALL ;
SELECT * FROM prob_cur17 ;
UNION ALL ;
SELECT * FROM prob_cur18 ;
UNION ALL ;
SELECT * FROM prob_cur19 ;
UNION ALL ;
SELECT * FROM prob_cur2 ;
UNION ALL ;
SELECT * FROM prob_cur21 ;
UNION ALL ;
SELECT * FROM prob_cur12 ;
INTO CURSOR prob_cr2

USE IN prob_cur14
USE IN prob_cur23
USE IN prob_cur17
USE IN prob_cur18
USE IN prob_cur19
USE IN prob_cur2
USE IN prob_cur21
USE IN prob_cur12

** ai_enc **
SELECT * FROM prob_cur3 ;
UNION ALL ;
SELECT * FROM prob_cur31 ;
UNION ALL ;
SELECT * FROM prob_cur32 ;
UNION ALL ;
SELECT * FROM prob_cur13 ;
UNION ALL ;
SELECT * FROM prob_cur15 ;
UNION ALL ;
SELECT * FROM prob_cur16 ;
UNION ALL ;
SELECT * FROM prob_cur48 ;
INTO CURSOR prob_cr3

USE IN prob_cur3
USE IN prob_cur31
USE IN prob_cur32
USE IN prob_cur13
USE IN prob_cur15
USE IN prob_cur16
USE IN prob_cur48

SELECT * FROM prob_cur4 ;
UNION ALL ;
SELECT * FROM prob_cur5 ;
UNION ALL ;
SELECT * FROM prob_cur7 ;
UNION ALL ;
SELECT * FROM prob_cur94 ;
UNION ALL ;
SELECT * FROM prob_cur90 ;
UNION ALL ;
SELECT * FROM prob_cur80 ;
UNION ALL ;
SELECT * FROM prob_cur81 ;
INTO CURSOR prob_cr4

USE IN prob_cur4
USE IN prob_cur5
USE IN prob_cur7
USE IN prob_cur94
USE IN prob_cur90
USE IN prob_cur80
USE IN prob_cur81

SELECT * FROM prob_cur6 ;
UNION ALL ;
SELECT * FROM prob_cur20 ;
UNION ALL ;
SELECT * FROM prob_cur91 ;
UNION ALL ;
SELECT * FROM prob_cur92 ;
UNION ALL ;
SELECT * FROM prob_cur93 ;
UNION ALL ;
SELECT * FROM prob_cur95 ;
INTO CURSOR prob_cr5

USE IN prob_cur6
USE IN prob_cur20
USE IN prob_cur91
USE IN prob_cur92
USE IN prob_cur93
USE IN prob_cur95

SELECT * FROM prob_cur33 ;
UNION ALL ;
SELECT * FROM prob_cur34 ;
UNION ALL ;
SELECT * FROM prob_cur35 ;
UNION ALL ;
SELECT * FROM prob_cur42 ;
UNION ALL ;
SELECT * FROM prob_cur43 ;
UNION ALL ;
SELECT * FROM prob_cur44 ;
UNION ALL ;
SELECT * FROM prob_cur45 ;
UNION ALL ;
SELECT * FROM prob_cur49 ;
Union all ;
Select * From prob_cur73 ;
INTO CURSOR prob_cr6

USE IN prob_cur33
USE IN prob_cur34
USE IN prob_cur35
USE IN prob_cur42
USE IN prob_cur43
USE IN prob_cur44
USE IN prob_cur45
USE IN prob_cur49
Use in prob_cur73

SELECT * FROM prob_cur36 ;
UNION ALL ;
SELECT * FROM prob_cur37 ;
UNION ALL ;
SELECT * FROM prob_cur38 ;
UNION ALL ;
SELECT * FROM prob_cur39 ;
UNION ALL ;
SELECT * FROM prob_cur40 ;
UNION ALL ;
SELECT * FROM prob_cur41 ;
UNION ALL ;
SELECT * FROM prob_cur46 ;
UNION ALL ;
SELECT * FROM prob_cur47 ;
INTO CURSOR prob_cr7

USE IN prob_cur36
USE IN prob_cur37
USE IN prob_cur38
USE IN prob_cur39
USE IN prob_cur40
USE IN prob_cur41
USE IN prob_cur46
USE IN prob_cur47

Select * from prob_cur50 ;
Union all ;
Select * from prob_cur51 ;
Union all ;
Select * from prob_cur52 ;
Union all ;
Select * from prob_cur53 ;
Union all ;
Select * from prob_cur54 ;
Union all ;
Select * from prob_cur55 ;
Union all ;
Select * from prob_cur56 ;
Union all ;
Select * from prob_cur57 ;
Into Cursor prob_cr8

Use in prob_cur50
Use in prob_cur51
Use in prob_cur52
Use in prob_cur53
Use in prob_cur54
Use in prob_cur55

Select * from prob_cur60 ;
Union all ;
Select * from prob_cur61 ;
Union all ;
Select * from prob_cur62 ;
Union all ;
Select * from prob_cur70 ;
Union all ;
Select * from prob_cur71 ;
Union all ;
Select * from prob_cur72 ;
Union all ;
Select * from prob_cur74 ;
Into Cursor prob_cr9

Use in prob_cur60
Use in prob_cur61
Use in prob_cur62
Use in prob_cur70
Use in prob_cur71
Use in prob_cur72
Use in prob_cur74

* jss, 6/30/03, consolidate 16 tm/am cursors
* jss, 8/17/04, add code for prob_cur0r (contains blank enc_id in ai_ctest error info)
* jss, 10/15/04, remove prob_cur0r (for "encid")
*Union all ;
*Select * from prob_cur0r 

Select * from prob_cur0a ;
Union all ;
Select * from prob_cur0b ;
Union all ;
Select * from prob_cur0c ;
Union all ;
Select * from prob_cur0d ;
Union all ;
Select * from prob_cur0e ;
Union all ;
Select * from prob_cur0f ;
Union all ;
Select * from prob_cur0g ;
Union all ;
Select * from prob_cur0h ;
INTO CURSOR ;
            prob_cr0y

Select * from prob_cur0i ;
Union all ;
Select * from prob_cur0j ;
Union all ;
Select * from prob_cur0k ;
Union all ;
Select * from prob_cur0l ;
Union all ;
Select * from prob_cur0m ;
Union all ;
Select * from prob_cur0n ;
Union all ;
Select * from prob_cur0o ;
Union all ;
Select * from prob_cur0p ;
Union all ;
Select * from prob_cur0q ;
Into Cursor prob_cr0z

* jss, 1/3/06, add new cursor prob_cr0x here
Select * from prob_cr0x ;
Union All ;
Select * from prob_cr0y ;
Union all ;
Select * from prob_cr0z ;
Into Cursor prob_cr0

USE IN prob_cur0a
USE IN prob_cur0b
USE IN prob_cur0c
USE IN prob_cur0d
USE IN prob_cur0e
USE IN prob_cur0f
USE IN prob_cur0g
USE IN prob_cur0h
USE IN prob_cur0i
USE IN prob_cur0j
USE IN prob_cur0k
USE IN prob_cur0l
USE IN prob_cur0m
USE IN prob_cur0n
USE IN prob_cur0o
USE IN prob_cur0p
USE IN prob_cur0q
USE IN prob_cr0y
USE IN prob_cr0z
**** end of 6/30 code addition

SELECT * FROM prob_cr1 ;
UNION ALL ;
SELECT * FROM prob_cr2 ;
UNION ALL ;
SELECT * FROM prob_cr3 ;
UNION ALL ;
SELECT * FROM prob_cr4 ;
UNION ALL ;
SELECT * FROM prob_cr5 ;
UNION ALL ;
SELECT * FROM prob_cr6 ;
UNION ALL ;
SELECT * FROM prob_cr7 ;
Union all ;
Select * from prob_cr8 ;
Union all ;
Select * from prob_cr9 ;
Union all ;
Select * from prob_cr0 ;
INTO CURSOR ;
	prob_cur 

USE IN prob_cr1
USE IN prob_cr2
USE IN prob_cr3
USE IN prob_cr4
USE IN prob_cr5
USE IN prob_cr6
USE IN prob_cr7
Use in prob_cr8
Use in prob_cr9
Use in prob_cr0

=DETECT_IT('PROB_CUR') && SET APPROPRIATE SWITCHES IN FIXLIST

* prepare cursor with names for report.
* Use only those clients we are going to create extract for
* or no client if doesn't apply

*	PADR(IIF(prob_type = 'NEEDLX2', TRIM(cc.id_no) + "*", ;
*		IIF(cc.anonymous, TRIM(cc.id_no) + "*", ;
*		UPPER(NAME(client.last_name, client.first_name, client.mi)))),30) AS name, ;

* jss, 8/12/04, for HIPAA compliance, use only id_no for client's identifier (continue using asterisk to denote anonymous)
SELECT DISTINCT ;
	PADR(IIF(cc.anonymous, TRIM(cc.id_no) + "*", TRIM(cc.id_no)),30) AS name, ;
	GetHeader(prob_cur.prob_type) AS prob_desc, ;
	prob_cur.* ;
FROM ;
	prob_cur, client, &cCliCur cc ;
WHERE ;
	prob_cur.tc_id = cc.tc_id AND ;
	cc.client_id = client.client_id ;
UNION ALL ;
SELECT ;
	SPACE(30) AS name, ;
	GetHeader(prob_cur.prob_type) AS prob_desc, ;
	prob_cur.* ;
FROM ;
	prob_cur;
WHERE ;
	prob_cur.tc_id = 'ZZZZZZZZZZ' ;
INTO CURSOR ;
	rep_cur ;
ORDER BY ;
	7,2,1, 6

Use in prob_cur
Use in client

*	sourcefile, prob_desc, name

SELECT rep_cur

IF _TALLY = 0
	DO Rest_Env2 WITH aFiles_Open
	SET CENTURY &cCentury
	=WriteTxt(.t.)
	RETURN .T.
Else
	=WriteTxt(.f.)	
ENDIF

* get site assignment detail
SELECT ;
	AI_SITE.SITES_ID, AI_SITE.TC_ID, AI_SITE.EFFECT_DT, AI_SITE.TIME, AI_SITE.AM_PM, AI_CLIEN.CLIENT_ID ;
FROM ;
	AI_SITE, AI_CLIEN ;
WHERE AI_CLIEN.TC_ID = AI_SITE.TC_ID ;
INTO CURSOR SITE_DET

INDEX ON SITES_ID TAG SITES_ID

* get syringe exchange detail
SELECT ;
	NEED_ID,TC_ID,ID_NO,PROGRAM.DESCRIPT AS PROGRAM,SITE.DESCRIPT1 AS SITE,WORKER_ID, program.prog_id ;
FROM ;
	NEEDLX,PROGRAM,SITE ;
WHERE ;
	PROGRAM.PROG_ID = NEEDLX.PROGRAM AND ;
	SITE.SITE_ID = NEEDLX.SITE ;
INTO CURSOR NEED_DET

INDEX ON NEED_ID TAG NEED_ID

* get ETO detail
* jss, 11/20/03, comment out this code, no longer needed
**SELECT ;
**		AI_OUTR.ACT_ID,ENC_TYPE.DESCRIPT AS ENC_TYPE, ;
**		AI_OUTR.BEG_TM,AI_OUTR.BEG_AM,AI_OUTR.ACT_DT ;
**	FROM ;
**		AI_OUTR, ENC_TYPE;
**	WHERE ;
**		ENC_TYPE.SERV_CAT = AI_OUTR.SERV_CAT AND ;
**		ENC_TYPE.CODE = AI_OUTR.ENC_TYPE ;
**	INTO CURSOR OUTR_DET
**
**INDEX ON ACT_ID TAG ACT_ID

* get group detail
SELECT GRP_ID,DESCRIPT AS GROUP ;
FROM GROUP ;
INTO CURSOR GRP_DET

INDEX ON PADR(TRIM(GRP_ID),10) TAG GRP_ID

* get worker assignment detail
SELECT ai_work.ws_id,ai_work.tc_id,ai_work.worker_id, ;
	TRIM(program.descript) AS PROGRAM, ;
	NAME(STAFFCUR.LAST,STAFFCUR.FIRST,STAFFCUR.MI) AS worker ;
FROM ai_work, PROGRAM, staffcur ;
WHERE program.prog_id = ai_work.program AND ;
	staffcur.worker_id = ai_work.worker_id ;
INTO CURSOR work_det

INDEX ON ws_id TAG ws_id

* get programm enrollment detail
SELECT ai_work.ws_id,ai_work.tc_id,ai_work.worker_id, ;
	TRIM(program.descript) AS PROGRAM ;
FROM ai_work, PROGRAM ;
WHERE program.prog_id = ai_work.program ;
INTO CURSOR enroll_det

INDEX ON ws_id TAG ws_id

* get info for CTS
SELECT ;
	rep_cur.act_id, ai_ctest.cts_id, ;
	ai_ctest.bloodsmpno, ai_ctest.enc_date, ;
	ai_ctest.b1pstcnsld, b2pstcnsld, ;
	site.descript1 as site, ;
	ctsfund.funddesc ; 
FROM ;
	rep_cur, ai_ctest, site, ctsfund ;
WHERE ;
	rep_cur.act_id = ai_ctest.cts_id and;
	ai_ctest.asite = site.site_id and ;
	ai_ctest.afund = ctsfund.fundid ;
INTO CURSOR ;
	ctest_det

INDEX ON cts_id TAG cts_id

use in site

* jss, 4/11/05, if there is an att_id attached, go and get the group name too
* get info for encounters
SELECT ;
	rep_cur.act_id, ai_enc.act_dt, ;
	serv_cat.descript AS serv_cat,ai_enc.beg_tm,ai_enc.beg_am, ;
	enc_type.descript AS enc_type, ;
	program.descript As program, ;
	ai_enc.tc_id, ;
	program.prog_id, ;
	group.descript as Groupdesc ;
FROM ;
	rep_cur, ai_enc, serv_cat, enc_type, program, grpatt, group ;
WHERE ;
	rep_cur.act_id = ai_enc.act_id AND ;
	ai_enc.serv_cat = serv_cat.code AND ;
	ai_enc.enc_type = enc_type.code AND ;
	ai_enc.serv_cat = enc_type.serv_cat And ;
	!EMPTY(ai_enc.att_id) And ;
	ai_enc.att_id=grpatt.att_id And ;
	grpatt.grp_id==group.grp_id And ;
	ai_enc.program = program.prog_id ;
UNION ;	
SELECT ;
	rep_cur.act_id, ai_enc.act_dt, ;
	serv_cat.descript AS serv_cat,ai_enc.beg_tm,ai_enc.beg_am, ;
	enc_type.descript AS enc_type, ;
	program.descript As program, ;
	ai_enc.tc_id, ;
	program.prog_id, ;
	SPACE(30) as Groupdesc ;
FROM ;
	rep_cur, ai_enc, serv_cat, enc_type, program ;
WHERE ;
	rep_cur.act_id = ai_enc.act_id AND ;
	ai_enc.serv_cat = serv_cat.code AND ;
	ai_enc.enc_type = enc_type.code AND ;
	ai_enc.serv_cat = enc_type.serv_cat And ;
	EMPTY(ai_enc.att_id) And ;
	ai_enc.program = program.prog_id ;
INTO CURSOR ;
	enc_det

INDEX ON act_id TAG act_id

* jss, 4/11/05, if there is an att_id attached, go and get the group name too
* get info for services
SELECT distinct ;
	rep_cur.act_id AS serv_id, ai_enc.act_dt, ;
	serv_cat.descript AS serv_cat, ;
	service.descript AS service, ;
	program.descript As program, ;
	ai_enc.tc_id, ;
	program.prog_id, ;
	group.descript as Groupdesc ;
FROM ;
	rep_cur, ai_serv, ai_enc, serv_cat, service, program, grpatt, group ;
WHERE ;
	rep_cur.act_id = ai_serv.serv_id AND ;
	ai_serv.act_id = ai_enc.act_id AND ;
	ai_enc.serv_cat = serv_cat.code AND ;
	ai_enc.serv_cat = service.serv_cat AND ;
	(ai_enc.enc_type = service.enc_type OR EMPTY(service.enc_type)) AND ;
	ai_serv.service = service.code And ;
	!EMPTY(ai_enc.att_id) And ;
	ai_enc.att_id=grpatt.att_id And ;
	grpatt.grp_id==group.grp_id And ;
	ai_enc.program = program.prog_id ;
UNION ;
SELECT distinct ;
	rep_cur.act_id AS serv_id, ai_enc.act_dt, ;
	serv_cat.descript AS serv_cat, ;
	service.descript AS service, ;
	program.descript As program, ;
	ai_enc.tc_id, ;
	program.prog_id, ;
	SPACE(30) as Groupdesc ;
FROM ;
	rep_cur, ai_serv, ai_enc, serv_cat, service, program ;
WHERE ;
	rep_cur.act_id = ai_serv.serv_id AND ;
	ai_serv.act_id = ai_enc.act_id AND ;
	ai_enc.serv_cat = serv_cat.code AND ;
	ai_enc.serv_cat = service.serv_cat AND ;
	(ai_enc.enc_type = service.enc_type OR EMPTY(service.enc_type)) AND ;
	ai_serv.service = service.code And ;
	EMPTY(ai_enc.att_id) And ;
	ai_enc.program = program.prog_id ;
INTO CURSOR ;
	serv_det

INDEX ON serv_id TAG serv_id

* get info for eto/prevention modules (session/event related stuff)
* jss, 11/20/03, outr_det will provide info for all errors related to table ai_outr (and it's children)

SELECT ;
	ai_outr.act_id, ;
	ai_outr.serv_cat, ;
	SPACE(30) AS servdesc, ;
	ai_outr.category, ;
	SPACE(50) AS catdesc, ;
	ai_outr.enc_type, ;
	SPACE(50) AS encdesc, ;
	ai_outr.program, ;
	SPACE(30) AS progdesc, ;
	ai_outr.act_dt, ;
	ai_outr.beg_tm, ;
	ai_outr.beg_am ;
FROM ;
	rep_cur, ai_outr ;
WHERE ;
	rep_cur.act_id   = ai_outr.act_id ;
INTO CURSOR ;
	outr_det1
	
=REOPENCUR("outr_det1","outr_det")	
	
=OPENFILE("serv_cat","code")	
=OPENFILE("category","progcode") && serv_cat + code	
=OPENFILE("enc_type","procacod") && serv_cat + category + code	
=OPENFILE("program","prog_id")	 

* load up descriptions now
SELECT outr_det
SET RELATION TO serv_cat INTO serv_cat
REPLACE ALL servdesc WITH IIF(EOF('serv_cat'), 'Not on file', serv_cat.descript)

SET RELATION TO serv_cat + category INTO category
REPLACE ALL catdesc WITH IIF(EOF('category'), 'Not on file', category.descript)

SET RELATION TO serv_cat + category + enc_type INTO enc_type
REPLACE ALL encdesc WITH IIF(EOF('enc_type'), 'Not on file', enc_type.descript)

SET RELATION TO program INTO program
REPLACE ALL progdesc WITH IIF(EOF('program'), 'Not on file', program.descript)

SET RELA TO

* jss, 11/20/03 eto_det no longer used
**SELECT ;
**	rep_cur.act_id, ai_outr.act_dt, ;
**	enc_type.descript AS enc_type ;
**FROM ;
**	rep_cur, ai_outr, enc_type ;
**WHERE ;
**	rep_cur.act_id = ai_outr.act_id AND ;
**	ai_outr.serv_cat = enc_type.serv_cat AND ;
**	ai_outr.category = enc_type.category AND ;
**	ai_outr.enc_type = enc_type.code ;
**INTO CURSOR ;
**	eto_det

INDEX ON act_id TAG act_id

* get info for referrals
SELECT ;
	ref_id, ref_dt, ;
	ref_for.descript AS ref_for, ;
	ai_ref.tc_id ;
FROM ;
	rep_cur, ai_ref, ref_for ;
WHERE ;
	rep_cur.act_id = ai_ref.ref_id AND ;
	ai_ref.ref_for = ref_for.code  AND ;
	ai_ref.ref_cat = ref_for.category ;
INTO CURSOR ;
	ref_det

INDEX ON ref_id TAG ref_id

do deactthermo in thermo

* announce the bad news
=Msg2User("CANTPROC2", cExtrName)

SELECT ai_clien
SET ORDE TO tc_id

SELECT rep_cur
SET RELATION TO prob_file + problem INTO prob_desc 

* Finally print report
DO printdoc WITH 'DV'

SELECT DISTINCT prob_type FROM rep_cur INTO ARRAY cProbArray

DO Rest_Env2 WITH aFiles_Open

SET CENTURY &cCentury

RETURN .F.

*****************
Function WriteTxt
*****************
* jss, 9/22/06, add this routine to write an output text file called 'dverun.txt', which will in turn be used by the URS VFP conversion program
Parameter nResult

outputfl=FCREATE('dverun.txt')
If nResult=.t.
	=FWRITE(outputfl, 'Y')
Else
	=FWRITE(outputfl, 'N')
Endif	
=FCLOSE(outputfl)

return
**********************************************************
FUNCTION GetHeader
**********************************************************
*  Function.........: GetHeader
*) Description......: Problem description
*  Returns..........:
**********************************************************
PARAMETERS cProblem
PRIVATE cProbDesc
cProbDesc = GETDESC('CHKDATA','cProblem','CODE','DESCRIPT')

* jss, 7/9/03, make this 100 characters long
*RETURN PADR(cProbDesc, 80)
RETURN PADR(cProbDesc, 100)

*-EOF GetHeader

**********************************************************
FUNCTION MoreInfo
**********************************************************
*  Function.........: MoreInfo
*  Author...........: Boris Kagan
*) Description......: Displays additional information about problem record
**********************************************************
PARAMETERS cProbFile, cPID, cProblem
PRIVATE cInfo,HOLDSEL,OLDORDER
HOLDSEL = SELECT()
cInfo = ""

DO CASE
CASE cProbFile = "AI_ENC  " 
	Do Case
		Case cProblem = "AI_ENC3 "
		
			Select enc_det.*, temp1.max_dt ; 
			From enc_det, temp1 ;
			Where enc_det.tc_id = temp1.tc_id  And;
					enc_det.act_id = cPID And ;
					temp1.status ="C " ;
			Into Cursor enc_det3
		
			If _Tally <> 0
				 cInfo = "Program: " + Rtrim(enc_det3.program) + ", Service Category: " + TRIM(enc_det3.serv_cat) ;
				 			+ ", Encounter Type: " + TRIM(enc_det3.enc_type) ;
			    			+ ", Case Closed: " +  DTOC(enc_det3.max_dt)
* jss, 4/12/05, include group description if it exists
			     cInfo = Iif(!Empty(enc_det3.groupdesc), cInfo + "; Group: "+enc_det3.groupdesc, cInfo)			
			Endif 		

			Use in enc_det3
			
		Case cProblem = "AI_ENC4 "	
			Select enc_det.*, temp11.max_dt as start_dt, temp11.end_dt ; 
			From enc_det, temp11 ;
			Where enc_det.tc_id = temp11.tc_id  And;
					enc_det.act_id = cPID And ;
					enc_det.prog_id = temp11.program  and ;
					!Empty(temp11.end_dt) ;
			Into Cursor enc_det3
		
			If _Tally <> 0
				 cInfo = "Service Category: " + TRIM(enc_det3.serv_cat) ;
				 			+ ", Encounter Type: " + TRIM(enc_det3.enc_type) ;
				 			+ ", Program: " + Rtrim(enc_det3.program) ; 
			    			+ ", Date: " +  DTOC(enc_det3.start_dt) + "-" + Dtoc(enc_det3.end_dt)
* jss, 4/12/05, include group description if it exists
			     cInfo = Iif(!Empty(enc_det3.groupdesc), cInfo + "; Group: "+enc_det3.groupdesc, cInfo)			
			Endif 		
			Use in enc_det3

		Otherwise	
			IF SEEK(ALLTRIM(cPID), "enc_det")
				cInfo = "Encounter Date: " + DTOC(enc_det.act_dt) + ", Service Category: " ;
						+ TRIM(enc_det.serv_cat) + ", Encounter Type: " + TRIM(enc_det.enc_type) ;
						+ ", Beginning time: " + 	TRANSFORM(enc_det.beg_tm + enc_det.beg_am, "@R 99:99!!") 
* jss, 4/12/05, include group description if it exists
		        cInfo = Iif(!Empty(enc_det.groupdesc), cInfo + "; Group: "+enc_det.groupdesc, cInfo)			
			ENDIF

	EndCase
	
	
CASE cProbFile = "AI_SERV"
	Do Case
		Case cProblem = 'SRVDATE1'
			Select serv_det.*, temp1.max_dt ; 
			From serv_det, temp1 ;
			Where serv_det.tc_id = temp1.tc_id  And;
					serv_det.serv_id = cPID And ;
					temp1.status ="C " ;
			Into Cursor serv_det1
		
			If _Tally <> 0
				 cInfo = "Program: " + Rtrim(serv_det1.program) + ", Encounter's Service Category: " ; 
							+ TRIM(serv_det1.serv_cat) + ", Service: " + TRIM(serv_det1.service) ;
			    			+ ", Case Closed: " +  DTOC(serv_det1.max_dt)
* jss, 4/12/05, include group description if it exists
		        cInfo = Iif(!Empty(serv_det1.groupdesc), cInfo + "; Group: "+serv_det1.groupdesc, cInfo)			
			Endif 		
			Use in serv_det1
		
		Case cProblem = 'SRVDATE2'

			Select serv_det.*, temp11.end_dt, temp11.max_dt as start_dt ; 
			From serv_det, temp11 ;
			Where serv_det.tc_id = temp11.tc_id  And;
					serv_det.serv_id = cPID And ;
					!Empty(temp11.end_dt) And ;
					serv_det.prog_id = temp11.program ;
			Into Cursor serv_det1
		
			If _Tally <> 0
				 cInfo = "Encounter's Service Category: " ; 
							+ TRIM(serv_det1.serv_cat) + ", Service: " + TRIM(serv_det1.service) ;
							+ ", Program: " + Rtrim(serv_det1.program) ; 
			    			+ ", Date: " +  DTOC(serv_det1.start_dt) + "-" + Dtoc(serv_det1.end_dt)
* jss, 4/12/05, include group description if it exists
		        cInfo = Iif(!Empty(serv_det1.groupdesc), cInfo + "; Group: "+serv_det1.groupdesc, cInfo)			
			Endif 		
			Use in serv_det1

		Otherwise
			IF SEEK(ALLTRIM(cPID), "serv_det")
				cInfo = 'Encounter Date: ' + DTOC(serv_det.act_dt) + ", Encounter's Service Category: " ; 
						+ TRIM(serv_det.serv_cat) + ", Service: " + TRIM(serv_det.service) 
* jss, 4/12/05, include group description if it exists
		        cInfo = Iif(!Empty(serv_det.groupdesc), cInfo + "; Group: "+serv_det.groupdesc, cInfo)			
			ENDIF
	EndCase
* expand this case to include the other supporting eto tables	
CASE cProbFile = "AI_OUTST" OR ;
		cProbFile = "AI_OUTPB" OR ;
		cProbFile = "AI_OUTFC" OR ;
		cProbFile = "AI_OUTMT" OR ;
		cProbFile = "AI_OUTMD" OR ;
		cProbFile = "AI_OUTSP" OR ;
		cProbFile = "AI_OUTZP" 

** jss, 11/20/03, use outr_det instead of eto_det to provide more info
**	IF SEEK(ALLTRIM(cPID), "eto_det")
**		cInfo = DTOC(eto_det.act_dt) + " - " + TRIM(eto_det.enc_type)
**	ENDIF

	IF SEEK(ALLTRIM(cPID), "outr_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ;
			'Service Category: '  + TRIM(outr_det.servdesc) + ;
			'; Category: '        + TRIM(outr_det.catdesc) + ;
			'; Type: '  		  + TRIM(outr_det.encdesc) + ;
			'; Program: '         + TRIM(outr_det.progdesc) + ;
			'; Date: '            + DTOC(outr_det.act_dt) + ;
			'; Start Time: '      + TRANSFORM(outr_det.beg_tm, "@R 99:99") + outr_det.beg_am
	ENDIF
CASE cProbFile = "AI_REF"
	If cProblem = 'AI_REF1 '
	
			Select ref_det.*, temp1.max_dt ; 
			From ref_det, temp1 ;
			Where ref_det.tc_id = temp1.tc_id  And;
					ref_det.ref_id = cPID And ;
					temp1.status ="C " ;
			Into Cursor ref_det1
			
			If _Tally <> 0
				cInfo = "Referral: " + Rtrim(ref_det1.ref_for) + ", Case Closed: " + Dtoc(ref_det1.max_dt)
			Endif
			Use in ref_det1
	Else
	
		IF SEEK(ALLTRIM(cPID), "ref_det")
			cInfo = DTOC(ref_det.ref_dt) + " - " + TRIM(ref_det.ref_for)
		ENDIF
	Endif	
CASE cProbFile = "AI_CLIEN"
	SELECT placed_dt FROM ai_clien WHERE tc_id = ALLTRIM(cPID) INTO CURSOR aic
	IF _tally <> 0
		cInfo = "Intake Date: " + DTOC(aic.placed_dt)
	ENDIF
	USE IN ai_clien
	USE IN aic
CASE cProbFile = "AI_PROG"
	If cProblem = 'AI_PROG1' or cProblem = 'AI_PROG2'
	
			Select program.descript, temp1.max_dt ; 
			From ai_prog, temp1, program ;
			Where ai_prog.tc_id = temp1.tc_id  And;
					ai_prog.ps_id = cPID And ;
					program.prog_id = ai_prog.program And ;
					temp1.status ="C " ;
			Into Cursor prog_det
			
			
			If _Tally <> 0
				cInfo = "Program: " + Rtrim(prog_det.descript) + ", Case Closed: " + Dtoc(prog_det.max_dt)
			Endif
			Use in prog_det
			Use in program
			Use in ai_prog
	Else

			SELECT descript FROM program WHERE prog_id = ALLTRIM(cPID) INTO CURSOR progcurs
			IF _tally <> 0
				cInfo = "Program: " + ALLTRIM(progcurs.descript)
			ENDIF
			USE IN program
			USE IN progcurs
	Endif		
CASE cProbFile = "AI_CTEST"
	IF SEEK(ALLTRIM(cPID), "ctest_det")
		cInfo = "Date of Encounter: " + Dtoc(ctest_det.enc_date) + ;
				", Service Site: " + Rtrim(ctest_det.site) + ;
				", Funding Program: " + Rtrim(ctest_det.funddesc) + ;
				", Blood Sample #: " + TRIM(ctest_det.bloodsmpno)
	ENDIF
ENDCASE

DO CASE
CASE cProblem = 'GRPATT01' OR cProblem = 'GRPATT04' OR cProblem = 'GRPATT06' 
	SELECT grpatt.act_dt, grpatt.grp_id FROM grpatt WHERE att_id = ALLTRIM(cPID) INTO CURSOR grpa
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Date: '+DTOC(grpa.act_dt)+SPACE(2)+'Group: '+grpa.grp_id 
	ENDIF
	USE IN grpatt
	USE IN grpa

* jss, 9/5/03, make comparison "==" instead of "="
CASE cProblem = 'GRPATT07'

	SELECT b.start_dt, b.end_dt, ;
			a.grp_id, ;
			b.descript ;
	FROM grpatt a, group b;
	WHERE a.grp_id == ALLTRIM(cPID) and a.grp_id = b.grp_id INTO CURSOR grpa
	
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Group: '+ Rtrim(grpa.descript) + '  ID: ' + grpa.grp_id + Space(2) + 'Date: '+DTOC(grpa.start_dt)+ "-" +DTOC(grpa.end_dt) 
	ENDIF
	USE IN grpatt
	USE IN grpa

CASE cProblem = 'REFSRCE4'
	SELECT last_name, first_name FROM ref_cntc WHERE refsource = ALLTRIM(cPID) INTO CURSOR refcntc
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ALLTRIM(refcntc.last_name)+','+ALLTRIM(refcntc.first_name)
	ENDIF
	USE IN ref_cntc
	USE IN refcntc

CASE cProblem = 'USERPRF1'
	SELECT last, first FROM staff WHERE staff_id = cPID INTO CURSOR stf
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ALLTRIM(stf.last)+', '+ALLTRIM(stf.first)
	ENDIF
	USE IN staff
	USE IN stf

CASE cProblem = 'USERPRF2'
	SELECT last, first FROM staff WHERE staff_id = cPID INTO CURSOR stf
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ALLTRIM(stf.last)+', '+ALLTRIM(stf.first)
	ENDIF
	SELECT worker_id FROM userprof WHERE staff_id = cPID INTO CURSOR upf
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Worker ID: ' + upf.worker_id
	ENDIF
	USE IN staff
	USE IN stf
	USE IN userprof
	USE IN upf

CASE (cProblem = 'USERPROF') OR (cProblem = 'USERDTST')
	cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Worker ID: ' + ALLTRIM(rep_cur.act_id)

CASE cProblem = 'CONSD   ' OR cProblem = 'CONTPROG' OR cProblem = 'MULTCONT'
	cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Contract: ' + ALLTRIM(rep_cur.act_id)

* jss, 9/5/03, make comparison "==" instead of "="
CASE cProblem = 'GROUP01 ' 
	SELECT descript FROM group WHERE grp_id == ALLTRIM(cPID) INTO CURSOR grp
   IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Group ID: ' + ALLTRIM(rep_cur.act_id)+ ': '+ grp.descript
	ENDIF	
	USE IN group
	USE IN grp

CASE cProblem = 'GROUP02 ' 
* jss, 5/30/03, define grp_det here instead of relying on it being here from body of program
* jss, 9/5/05, use left(cPID,5) for seek, as ALLTRIM(cPID) could lead to incorrect results
	SELECT GRP_ID,DESCRIPT AS GROUP ;
	FROM GROUP ;
	INTO CURSOR GRP_DET

	INDEX ON PADR(TRIM(GRP_ID),10) TAG GRP_ID
	
	IF SEEK(LEFT(cPID,5), "grp_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "GROUP: " + TRIM(grp_det.group)
	ENDIF
	use in group
	use in grp_det

* jss, 6/28/01, add code to display the tbstatus.effect_dt FOR 3 MORE TBSTATUS errors: 'TBDATE  ', 'TBDATE2 ', 'TBDATEST', 'TBXRAYDT'
CASE cProblem = 'PPDDATE ' OR cProblem = 'TBDATE' OR cProblem = 'TBXRAYDT'
	cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'TB Status Date: ' + ALLTRIM(rep_cur.act_id)

CASE cProblem = 'STAFFSDT' OR cProblem = 'USERSTDT'
	SELECT last, first FROM staff WHERE staff_id=ALLTRIM(cPID) INTO CURSOR stf
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ALLTRIM(stf.last)+', '+ALLTRIM(stf.first)
	ENDIF
	USE IN staff
	USE IN stf

CASE cProblem = 'AICLIEN1'
	SELECT id_no, client_id FROM ai_clien WHERE ai_clien.tc_id = ALLTRIM(cPID) INTO CURSOR aic1
	getcli=aic1.client_id
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'ID NO: ' + ALLTRIM(aic1.id_no)
	   SELECT last_name, first_name FROM client WHERE client_id = getcli INTO CURSOR cli
		IF _tally <> 0
			cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ALLTRIM(cli.last_name) + ', ' + ALLTRIM(cli.first_name)
		ENDIF
		USE IN cli
		USE IN client
	ENDIF	
	USE IN ai_clien
	USE IN aic1

* jss, 6/30/03, add 4 more cProblems: OUTBEGTM, OUTBEGAM, OUTENDTM, OUTENDAM
* jss, 11/20/03, expand cinfo
CASE cProblem $ 'AI_OUT1 OUTBEGTM OUTBEGAM OUTENDTM OUTENDAM' 
	IF SEEK(ALLTRIM(cPID), "outr_det")
**		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + TRIM(outr_det.enc_type) + "- Date: " + DTOC(outr_det.act_dt) + ;
**			' Start Time: ' + TRANSFORM(outr_det.beg_tm, "@R 99:99") + outr_det.beg_am
	
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ;
			'Service Category: '  + TRIM(outr_det.servdesc) + ;
			'; Category: '        + TRIM(outr_det.catdesc) + ;
			'; Type: '  		  + TRIM(outr_det.encdesc) + ;
			'; Program: '         + TRIM(outr_det.progdesc) + ;
			'; Date: '            + DTOC(outr_det.act_dt) + ;
			'; Start Time: '      + TRANSFORM(outr_det.beg_tm, "@R 99:99") + outr_det.beg_am
	ENDIF

CASE Left(cProblem,6) = 'AI_GRP' 
	Do Case	
* jss, 9/5/03, reverse comparison below from c.grp_id=a.act_id to a.act_id=c.grp_id, since grp_id only 5 chars, act_id is 10 (leads to incorrect comparisons)					
		Case cProblem = 'AI_GRP05' 
	
			Select c.descript, b.max_dt, b.tc_id ;
			From rep_cur a, temp1 b, group c ; 
			Where a.prob_type ='AI_GRP05' And ;
				  a.act_id = cPID and ;
				  a.tc_id = b.tc_id and ;
				  a.act_id = c.grp_id and ;
				  b.status ="C " ;
			Into Cursor grp_det
			
			Index on tc_id Tag tc_id
			
		    If _Tally <> 0
		    	If Seek(rep_cur.tc_id ,"grp_det")
					cInfo = "Group: " + Rtrim(grp_det.descript) + ", Case Closed: " + Dtoc(grp_det.max_dt)
				Endif
			Endif
			Use in grp_det
			Use in group
* jss, 9/5/03, reverse comparison below from c.grp_id=a.act_id to a.act_id=c.grp_id, since grp_id only 5 chars, act_id is 10 (leads to incorrect comparisons)					
		Case  cProblem = 'AI_GRP04'	
			Select c.descript, b.max_dt, b.tc_id;
			From rep_cur a, temp1 b, group c ; 
			Where a.prob_type ='AI_GRP04' And ;
				  a.act_id = cPID and ;
				  a.tc_id = b.tc_id and ;
				  a.act_id = c.grp_id and ;
				  b.status ="C " ;
			Into Cursor grp_det
			
			Index on tc_id Tag tc_id
			
			If _Tally <> 0
				If Seek(rep_cur.tc_id ,"grp_det")
					cInfo = "Group: " + Rtrim(grp_det.descript) + ", Case Closed: " + Dtoc(grp_det.max_dt)
				Endif	
			Endif
			Use in grp_det
			Use in group

* jss, 9/5/03, make comparison below "==" instead of just "=": could pick up incorrect information 
*			for this situation: Grp_id #1='1234 ', Grp_id #2='12345'. When Grp_id #2 is in error, following 
*			code would previously pick up info for grp_id #1

		Case  cProblem = 'AI_GRP06'
			Select descript, start_dt, end_dt ;
			From group ;
			Where grp_id == ALLTRIM(cPID) INTO CURSOR aigrp
				
		  	IF _tally <> 0
					cInfo = 'Group: ' + ALLTRIM(aigrp.descript) ;
							+ ', Date: ' + Dtoc(aigrp.start_dt) + '-' + Dtoc(aigrp.end_dt)
			ENDIF
		  	USE IN group
   		   	USE IN aigrp	
   		Case cProblem = 'AI_GRP07' 
   			Select a.start_dt, ;
   			 		a.end_dt , ;
   			 		b.descript ;
   			From ai_grp a, group b;
   			Where a.gs_id = cPID  And ;
   					a.group = b.grp_id ;
   			Into Cursor grp_det
   				
   			If _Tally <> 0
   					cInfo = 'Group: ' + ALLTRIM(grp_det.descript) ;
							+ ', Enrollment: ' + Dtoc(grp_det.start_dt) + '-' + Dtoc(grp_det.end_dt)
   			Endif		
		  	USE IN group
			USE IN ai_grp
			Use in grp_det

* jss, 5/1/03, add "ai_grp08" here
   		Case cProblem = 'AI_GRP08' 
			Select a.start_dt, ;
			 		a.end_dt , ;
			 		b.descript, ;
			 		b.program, ;
			 		c.descript AS progdesc ;
			From ai_grp a, group b, program c ;
			Where a.gs_id = cPID ;
			  And a.group = b.grp_id ;
			  AND b.program = c.prog_id ;
			Into Cursor grp_det
   				
			If _Tally <> 0
				cInfo = 'Group: ' + ALLTRIM(grp_det.descript) ;
						+ ', Enrollment: ' + Dtoc(grp_det.start_dt) ;
						+ ', Associated Program: ' + grp_det.program + ' ' + ALLTRIM(grp_det.progdesc) 
   			Endif		
		  	USE IN group
		  	USE IN ai_grp
			USE IN grp_det
   		   	USE IN program
   		  		   			
		Otherwise
		
			SELECT descript FROM group WHERE grp_id = ALLTRIM(cPID) INTO CURSOR aigrp
		  	IF _tally <> 0
					cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Group: ' + ALLTRIM(aigrp.descript)
			ENDIF
		  	USE IN group
   		   	USE IN aigrp
		EndCase
		
CASE cProblem = 'NEEDLX1' OR cProblem = 'NEEDLX3' 
	SELECT date FROM needlx WHERE need_id = cPID INTO CURSOR need
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Date: ' + DTOC(need.date)
	ENDIF
	USE IN needlx
	USE IN need

CASE cProblem = 'AI_WORK1'
	IF SEEK(ALLTRIM(cPID), "enroll_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "PROGRAM: " + TRIM(enroll_det.program)
	ENDIF

CASE cProblem = 'AI_WORK2' or cProblem = 'AI_WORK3'
	IF SEEK(ALLTRIM(cPID), "work_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "PROGRAM: " + TRIM(work_det.program) + "  " + "WORKER: " + TRIM(work_det.worker)
	ENDIF

CASE cProblem = 'GRPATT02'
* jss, 5/30/03, define grp_det here instead of relying on it being here from body of program
* jss, 9/5/03, use left(cPID,5) for seek, as ALLTRIM(cPID) could lead to incorrect results
	SELECT GRP_ID,DESCRIPT AS GROUP ;
	FROM GROUP ;
	INTO CURSOR GRP_DET

	INDEX ON PADR(TRIM(GRP_ID),10) TAG GRP_ID

	IF SEEK(LEFT(cPID,5), "grp_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "GROUP: " + TRIM(grp_det.group)
	ENDIF
	use in group
	use in grp_det

* jss, 11/20/03, expand cinfo
CASE cProblem = 'OUTRDATE' OR cProblem = 'OUTRDDAT'
	IF SEEK(ALLTRIM(cPID), "outr_det")
**		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + TRIM(outr_det.enc_type) + "- Date: " + DTOC(outr_det.act_dt) + ;
**			' Start Time: ' + TRANSFORM(outr_det.beg_tm, "@R 99:99") + outr_det.beg_am

		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + ;
			'Service Category: '  + TRIM(outr_det.servdesc) + ;
			'; Category: '        + TRIM(outr_det.catdesc) + ;
			'; Type: '  		  + TRIM(outr_det.encdesc) + ;
			'; Program: '         + TRIM(outr_det.progdesc) + ;
			'; Date: '            + DTOC(outr_det.act_dt) + ;
			'; Start Time: '      + TRANSFORM(outr_det.beg_tm, "@R 99:99") + outr_det.beg_am
	ENDIF

* jss, 6/30/03, add 4 more cproblems: NDXBEGTM, NDXENDTM, NDXBEGAM, NDXENDAM 
CASE cProblem $ 'NEEDLX2 NDXBEGTM NDXENDTM NDXBEGAM NDXENDAM'
	IF SEEK(ALLTRIM(cPID), "need_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'PROGRAM: ' + TRIM(need_det.program) + '   SITE: ' + TRIM(need_det.site)
	ENDIF

CASE cProblem = 'NEEDLX4' 

			Select need_det.*, temp1.max_dt ; 
			From need_det, temp1 ;
			Where need_det.tc_id = temp1.tc_id  And;
					need_det.need_id = cPID And ;
					temp1.status ="C " ;
			Into Cursor need_dt1
			
 			If _Tally <> 0
 				cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') ;
 					+ 'Program: ' + TRIM(need_dt1.program) + ', Site: ' + TRIM(need_det.site) ;
 					+ ', Case Closed: ' + Dtoc(need_dt1.max_dt) 
 			EndIf
			
			Use in need_dt1
			
Case cProblem = 'NEEDLX5'

		Select need_det.*, temp11.max_dt as start_dt, temp11.end_dt ; 
		From need_det, temp11 ;
		Where need_det.tc_id = temp11.tc_id  And;
			need_det.need_id = cPID And ;
			need_det.prog_id = temp11.program And ;
			!Empty(temp11.end_dt) ;
		Into Cursor need_dt1

		If _Tally <> 0
			cInfo = 'Program: ' + TRIM(need_dt1.program) ;
				+ ', Date: ' + Dtoc(need_dt1.start_dt) + "-" + Dtoc(need_dt1.end_dt) ; 
				+ ', Site: ' + TRIM(need_dt1.site)
		ENDIF
		Use In need_dt1
		
CASE INLIST(cProblem, 'HOLDSITE', 'HOLDACTI', 'HOLDPROG')
	SELECT placed_dt FROM ai_clien WHERE tc_id = cPID INTO CURSOR aic
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Intake Date: " + DTOC(aic.placed_dt)
	ENDIF
	USE IN ai_clien
	USE IN aic

CASE cProblem = 'AI_SITE4'
	IF SEEK(ALLTRIM(cPID), "site_det")
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'DATE: ' + DTOC(site_det.effect_dt) + '   TIME: ' + site_det.time+site_det.am_pm
	ENDIF

CASE cProblem = 'AIPRENC2'
	cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Act ID: ' + ALLTRIM(rep_cur.act_id)

* jss, 11/20/03, comment out code for ai_outfc, this is already handled above with code for cprobfile='AI_OUTFC'
**CASE cProblem = 'AI_OUTFC'
**	IF SEEK(ALLTRIM(cPID), "outr_det")
**		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + TRIM(outr_det.enc_type) + "- Date: " + DTOC(outr_det.act_dt) + ;
**			' Start Time: ' + TRANSFORM(outr_det.beg_tm, "@R 99:99") + outr_det.beg_am
**	ENDIF

CASE cProblem = 'DOBDATE2'
	SELECT last_name, first_name FROM client WHERE client_id=cPID INTO CURSOR cli
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'Collateral: ' + ALLTRIM(cli.last_name) + ', ' + ALLTRIM(cli.first_name)
	ENDIF

	SELECT client.last_name, client.first_name ;
	FROM 	 ai_clien, client, ai_famil ;
	WHERE  ai_famil.client_id = ALLTRIM(cPID) ;
	AND	 ai_famil.tc_id     = ai_clien.tc_id ;
	AND    ai_clien.client_id = client.client_id ;
	INTO CURSOR ;
			dobdate2
	IF _Tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + 'of Client: ' + ALLTRIM(dobdate2.last_name) + ', ' + ALLTRIM(dobdate2.first_name)
	ENDIF	
	USE IN cli
	USE IN ai_clien
	USE IN ai_famil
	USE IN dobdate2

CASE cProblem = 'SRVCAT'
	SELECT ai_serv.date, serv_cat.descript as serv_cat ;
	FROM ai_serv, serv_cat ;
	WHERE ai_serv.act_id = ALLTRIM(cPID) ;
	 INTO CURSOR sc

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Service Date: " + DTOC(sc.date) + ;
											", Service's Service Category: " + sc.serv_cat
	ENDIF
	USE IN ai_serv
	USE IN serv_cat
	USE IN sc

CASE cProblem = 'ENC_TYPE'
	SELECT ai_enc.act_dt, serv_cat.descript AS serv_cat ;
	FROM ai_enc, serv_cat ;
	WHERE act_id = ALLTRIM(cPID) ;
	  AND ai_enc.serv_cat = serv_cat.code ;
	 INTO CURSOR et

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Encounter Date: " + DTOC(et.act_dt) + ;
											" Service Category: " + et.serv_cat 
	ENDIF
	USE IN ai_enc
	USE IN serv_cat 
	USE IN et

* jss, 7/1/03, add enc_type.serv_cat to where clause to grab correct enc_type data
CASE cProblem = 'SERVICE'
* jss, 11/6/00, capture the service date, service category description and encounter type description
	SELECT ai_serv.date,serv_cat.descript AS serv_cat, enc_type.descript AS enc_type   ;
	FROM ai_serv, ai_enc, serv_cat, enc_type ;
	WHERE ai_serv.serv_id = ALLTRIM(cPID) ;
	AND 	ai_serv.act_id = ai_enc.act_id ;
	AND	ai_serv.serv_cat = serv_cat.code ;
	AND ai_serv.serv_cat = enc_type.serv_cat ;	
	AND	ai_enc.enc_type  = enc_type.code ;
	INTO CURSOR aiserv

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Service Date: " + DTOC(aiserv.date) ;
																		 + ", Service Category: " + ALLTRIM(aiserv.serv_cat) ; 
																		 + ", Encounter Type: " + ALLTRIM(aiserv.enc_type)
	ENDIF
	USE IN ai_serv
	USE IN ai_enc
	USE IN aiserv

CASE cProblem = 'ENCSRVC'
	SELECT act_dt, enc_type, beg_tm, beg_am ;
	FROM ai_enc ;
	WHERE act_id = ALLTRIM(cPID);
	 INTO CURSOR aienc
	
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Encounter Date: " + DTOC(aienc.act_dt) ;
									+ ", Encounter Type: " + aienc.enc_type + ", Beginning time: "  ;
									+ TRANSFORM(aienc.beg_tm + aienc.beg_am, "@R 99:99!!")
	ENDIF
	USE IN ai_enc
	USE IN aienc
	
CASE cProblem = 'SERVSRVC'
	SELECT date FROM ai_serv WHERE serv_id = ALLTRIM(cPID) INTO CURSOR aiserv

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + " Service Date: " + DTOC(aiserv.date) 
	ENDIF
	USE IN ai_serv
	USE IN aiserv

CASE cProblem = 'INCEXP' OR cProblem = 'INCACT'
	gettc = rep_cur.tc_id
	SELECT ;
		client.dob ;
	FROM	;
		ai_clien, client ;
	WHERE ;
		ai_clien.tc_id = gettc AND ;
		ai_clien.client_id = client.client_id ;
	INTO CURSOR getdob
	
	IF _tally <> 0
		IF EMPTY(getdob.dob)
			cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + " Date of Birth: Not Entered"	
		ELSE
			cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + " Date of Birth: " + DTOC(getdob.dob)	
		ENDIF
	ENDIF
	
	USE IN client
	USE IN ai_clien
	USE IN getdob

* jss, 4/11/01, add lookup for Status.dbf	

CASE cProblem = 'STATSTRT' OR cProblem = 'STATEFCT' 
	SELECT ;
		status.start_dt, ;
		status.effect_dt, ;
		ai_clien.placed_dt ;
	FROM ;
		status, ai_clien ;
	WHERE ;
		status.client_id = ALLTRIM(cPID) AND ;
		status.client_id = ai_clien.client_id ;
	INTO CURSOR ;
		stat	
	
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + " Start Date: "+DTOC(stat.start_dt) +" Effective Date: "	+ DTOC(stat.effect_dt) + " Intake Date: " + DTOC(stat.placed_dt)
	ENDIF
	
	USE IN stat
	USE IN ai_clien
	USE IN status

* 7/2/01, jss, add code below to display info for 4 new INSSTAT errors, "INSSTAT2,3,4"
CASE cProblem = 'INSSTAT' AND cProblem <> 'INSSTATC' AND cProblem <> 'INSSTAT6' 
	SELECT ;
		insstat.effect_dt, ;
		insstat.exp_dt, ;
		client.last_name, ;
		client.first_name ;
	FROM ;
		insstat, client ;
	WHERE ;
		insstat.insstat_id = ALLTRIM(cPID) AND ;
		insstat.client_id = client.client_id ;
	INTO CURSOR ;
		insst	
	
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Name: " + ALLTRIM(insst.last_name)+ ", "+ALLTRIM(insst.first_name)  + " Effective Date: "+DTOC(insst.effect_dt) +" Expiration Date: "	+ DTOC(insst.exp_dt)
	ENDIF
	
	USE IN insst
	USE IN client
	USE IN insstat
	
CASE cProblem = 'INSSTAT6'
	SELECT ;
		insstat.effect_dt, ;
		insstat.exp_dt, ;
		med_prov.name ;
	FROM ;
		insstat, med_prov ;
	WHERE ;
		insstat.insstat_id = ALLTRIM(cPID) AND ;
		insstat.prov_id   = med_prov.prov_id ;
	INTO CURSOR ;
		insst	
	
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Insurance Provider: " + ALLTRIM(insst.name)+ ", Effective Date: "+DTOC(insst.effect_dt) +", Expiration Date: "	+ DTOC(insst.exp_dt)
	ENDIF
	
	USE IN insst
	USE IN med_prov
	USE IN insstat	

* add lookup for Testres.dbf
CASE cProblem = 'TESTDATE' OR cProblem = 'RESDATE '
	SELECT ;
		testres.testdate, ;
		testres.resdate, ;
		ALLTRIM(testtype.descript) as testtypeds ;
	FROM ;
		testres, testtype ;
	WHERE ;
		testres.labt_id  = ALLTRIM(cPID) AND ;
		testres.testtype = testtype.code ;
	INTO CURSOR ;
		lab	
	
	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + " Test Date: "+DTOC(lab.testdate) +" Result Date: "	+ DTOC(lab.resdate) + " Test Type: " + lab.testtypeds
	ENDIF
	
	USE IN lab
	USE IN testtype
	USE IN testres

* 7/6/01, jss, add lookup for blank addr_id	
CASE cProblem = 'ADDR_ID'
	SELECT ;
		client.first_name, ;
		client.last_name ;
	FROM ;
		cli_hous, client ;
	WHERE ;
		cli_hous.hshld_id = ALLTRIM(cPID) AND ;
		cli_hous.client_id = client.client_id ;
	INTO CURSOR ;
		addrname		

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Name: " +ALLTRIM(AddrName.First_name) + ' ' + ALLTRIM(AddrName.Last_name)
	ENDIF

	USE IN addrname
	USE IN client
	USE IN cli_hous	

* 1/26/02, jss, add lookup for blank elig_type and fund_type	
CASE cProblem = 'ELIGTYPE' OR cProblem = 'FUNDTYPE'
	SELECT ;
		program.descript ;
	FROM ;
		program ;
	WHERE ;
		program.prog_id = ALLTRIM(cPID) ;
	INTO CURSOR ;
		progdesc		

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Program: " + ALLTRIM(progdesc.descript)
	ENDIF

	USE IN program
	USE IN progdesc

* 1/26/02, jss, add lookup for blank site.typsetting
* 2/13/02, jss, add lookup for blank/invalid site.zip
* 1/3/06, jss, add lookup for blank/invalid site.type, site.st, site.psite_cnty
CASE cProblem = 'TYPSETTG' OR cProblem = 'SITEZIP1' OR cProblem = 'SITEZIP2' OR cProblem='SITETYPE' or cProblem='SITEST' or cProblem='SITECNTY'
	SELECT ;
		site.descript1, ;
		site.descript2  ;
	FROM ;
		site ;
	WHERE ;
		site.site_id = ALLTRIM(cPID) ;
	INTO CURSOR ;
		sitedesc		

	IF _tally <> 0
		cInfo = IIF(EMPTY(cInfo),"",ALLTRIM(cInfo)+'; ') + "Site: " + ALLTRIM(sitedesc.descript1) + " " + ALLTRIM(sitedesc.descript2)
	ENDIF

	USE IN site
	USE IN sitedesc
ENDCASE

SELECT (HOLDSEL)
RELEASE HOLDSEL
RETURN cInfo
*-EOF MoreInfo

***************************************************************************
FUNCTION all_staff2

PRIVATE lSiteOpen, lUsPrOpen, lStafOpen, lJobTOpen
lSiteOpen = OpenFile("site", "site_id")
lUsPrOpen = OpenFile("userprof")
lStafOpen = OpenFile("staff")
lJobTOpen = OpenFile("jobtype")

* jss, 12/21/2005, add new field pworker_id
SELECT ;
	a.worker_id, a.site, a.prog_id, b.last, b.first, b.mi, b.date_fnsh,			;
	c.descript, c.caseload, UPPER(LEFT(b.first,1)+LEFT(b.last,1)) AS initals,	;
	b.license, b.pr_type, b.c_t_id, a.superid, c.can_superv AS superflag, 		;
	b.tax_id, b.team, b.system_sup,												;
	SPACE(2) AS ctsitetype ,													;
	SPACE(3) AS ctsitenum														,;
	b.staff_id , a.pworker_id ;
FROM										;
	userprof A, staff B, jobtype C			;
WHERE										;
	a.staff_id = b.staff_id AND				;
	a.jobtype = c.jobtype					;
INTO										;
	CURSOR tempstaff

*       empty(b.date_fnsh) and ;

INDEX ON worker_id TAG worker_id

IF USED("staffcur")
	USE IN STAFFCUR
ENDIF

SELECT 0
USE (DBF('tempstaff')) AGAIN ALIAS staffcur
INDEX ON site TAG site ADDITIVE
INDEX ON IIF(EMPTY(date_fnsh), "", "{") + UPPER(LAST+first) TAG name ADDITIVE
INDEX ON caseload TAG caseload ADDITIVE
INDEX ON worker_id TAG worker_id ADDITIVE
INDEX ON staff_id TAG staff_id ADDITIVE
* jss, 12/21/2005, add new index tag pworker_id
INDEX ON pworker_id TAG pworker_id ADDITIVE

SELE staffcur
IF TYPE("site.ctsitetype")#"U"
	SET RELA TO site INTO site
	REPL ALL ctsitetype WITH site.ctsitetype, ;
		ctsitenum  WITH site.ctsitenum
	SET RELA TO
ENDIF

USE IN tempstaff

IF !lSiteOpen
	USE IN site
ENDIF
IF !lUsPrOpen
	USE IN userprof
ENDIF
IF !lStafOpen
	USE IN staff
ENDIF
IF !lJobTOpen
	USE IN jobtype
ENDIF
RETURN

*************************************************************************************
FUNCTION DETECT_IT
PARAMETERS TC_CURSOR

PRIVATE HOLDSEL, cProblem
HOLDSEL = SELECT()

=OPENFILE('FIXLIST')
SELECT FIXLIST
REPLACE ALL FIXED WITH 'YES'
REPLACE ALL DOIT  WITH 'NO'

SELECT DISTINCT ;
	chkdata.module ;
FROM ;
	&tc_cursor c1, chkdata ;
WHERE ;
	c1.prob_type = chkdata.code AND ;
	!EMPTY(chkdata.module) ;
INTO CURSOR ;
	prob2fix

SCAN
	=MARK_IT(TRIM(prob2fix.module))	
ENDSCAN

SELECT (HOLDSEL)
RELEASE HOLDSEL,cProblem
RETURN

*****************************************************************
FUNCTION MARK_IT
PARAMETERS TCMODULE

IF SEEK(TRIM(TCMODULE), "FIXLIST") AND FIXLIST.FIXED <> 'NO'
	REPLACE FIXLIST.FIXED WITH 'NO'
ENDIF

RETURN

