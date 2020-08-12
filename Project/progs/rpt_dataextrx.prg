Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by number
              nGroup, ;             && report selection number   
              lcTitle1, ;           && report selection description   
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description
              
Acopy(aSelvar1, aSelvar2)

* set Data Engine Compatibility to handle Foxpro version 7.0 or earlier (lets old SQL work)
mDataEngine=Sys(3099,70)
lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)

ccSite=''
cstattype=''
lcprog=''

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CSTATTYPE"
* jss, 8/2/07, should be cStatType here (will now filter on client's status type, 'A'ctive of 'C'losed)
*      cContract = aSelvar2(i, 2)
      cStatType = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
   
EndFor

cDate = DATE()
cTime = TIME()
set delete on
set safe off
gctc='00002'

PRIVATE gchelp
gchelp = "AIRS Data Extract Screen"

m.as_of_d = Date()

Do Case
Case lnStat=1
  * Data Extract and Client Listing Report
   Do MkDataExtr With 'L'

Case lnStat=2
  * Data Extract Structure Report
   Do Rpt_Extr_Str

Case lnStat=3
   * Display Complete Message Only
   Do MkDataExtr With 'C'
EndCase

mDataEngine=Sys(3099,90)

Return

*******************
Function MkDataExtr
*******************
Parameters cSpecialOutput
dtlStarted=Datetime()

PRIVATE m.cdcriskcat
PRIVATE m.rwriskcat
PRIVATE m.sex
STORE '' TO m.cdcriskcat, m.rwriskcat, m.sex

* jss, 7/31/07, Cli_Stat cursor is now created in rpt_form data environment
* Create the cursor with client status types
*=MkCli_Stat()

cTitle = "URS Data Extracts"

oApp.Msg2User("WAITRUN", "Preparing Extract.", "")

cReportSelection = .aGroup[nGroup]

* open extract data files exclusively
IF !OPENEXCL("ursdata")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

IF !OPENEXCL("ursprog")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

IF !OPENEXCL("ursserv")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

* jss, 8/17/07, remove references to urstopic, no longer used
*!*   * jss, 4/2/03, add open for new table urstopic here
*!*   IF !OPENEXCL("urstopic")
*!*   	oApp.Msg2User("OFF")
*!*   	Return .t.
*!*   ENDIF

* jss, 11/26/03, add open for new table ursevent here
IF !OPENEXCL("ursevent")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

IF !OPENEXCL("ursmeds")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

IF !OPENEXCL("urslabs")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

IF !OPENEXCL("ursplace")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

IF !OPENEXCL("ursrisk")
	oApp.Msg2User("OFF")
	Return .t.
ENDIF

* get the program limitation
DO CASE
	CASE nGroup = 1 && All Clients
		lcExpr = ".T."
	CASE nGroup = 2 && Ryan White Eligible
		lcExpr = "Aar_Report"
	CASE nGroup = 3 && HIV Counseling/Prevention Eligible
		lcExpr = "Ctp_Elig"
	CASE nGroup = 4 && Ryan White and HIV Counseling/Prevention Eligible
		lcExpr = "(Aar_Report OR Ctp_Elig)"
ENDCASE

* jss, 5/6/03, add case status effective date (casestatdt)
* jss, 10/20/06, add field hudchronic
SELECT ;
	Client.*, ;
	Ai_clien.tc_id, ;
	Ai_clien.anonymous, ;
	Ai_clien.id_no, ;
	Ai_clien.urn_no, ;
	Ai_clien.aka, ;
	Ai_clien.registry, ;
	Ai_clien.int_compl, ;
	Ai_clien.int_worker, ;
	Name(staff.last, staff.first, staff.mi) as workname, ;
	Ai_clien.int_prog, ;
	Ai_clien.entered, ;
	Ai_clien.placed_dt, ;
	Ai_clien.citizen, ;
	Ai_clien.other_cit, ;
	Ai_clien.alias, ;
	Ai_clien.ref_source, ;
	Ai_clien.ref_cntc, ;
	Ai_clien.discrete, ;
	Ai_clien.mail_cont, ;
	Ai_clien.phone_cont, ;
	Ai_clien.home_cont, ;
	Ai_clien.hhead, ;
	Ai_clien.dchild, ;
	Ai_clien.nrefnote, ;
	Ai_clien.getworks, ;
	Ai_clien.dispworks, ;
	Ai_clien.subshist, ;
	Ai_clien.startage, ;
	Ai_clien.inaddhouse, ;
	Ai_clien.HIV_EXP1, ;
	Ai_clien.HIV_EXP2, ;
	Ai_clien.HOUSING, ;
	Ai_clien.REF_SRC2, ;
	Ai_clien.HISTOFTB, ;
	Ai_clien.user1, ;
	Ai_clien.user2, ;
	Ai_clien.user3, ;
	Ai_clien.user4, ;
	Ai_clien.user5, ;
	Ai_clien.user6, ;
	Ai_clien.user7, ;
	Ai_clien.user8, ;
	Ai_clien.user9, ;
	Ai_clien.user10, ;
	Ai_clien.user11, ;
	Ai_clien.user12, ;
	Ai_clien.user13, ;
	Ai_clien.user14, ;
	Ai_clien.user15, ;
	ai_activ.status AS stat_code, ;
	IIF(statvalu.incare, "A", "C") as stattype, ;
	ai_activ.close_code, ;
	statvalu.incare AS ACTIVE, ;
	statvalu.descript AS casestat, ;
	ai_activ.effect_dt AS casestatdt, ;
	Iif(client.hispanic = 1, "Non-Hispanic",Iif(client.hispanic = 2, "Hispanic    ", Space(12))) as hisp_ds, ;
	SPACE(35) AS hispdetds, ;
	SPACE(35) AS whitedetds, ;
	SPACE(35) AS blackdetds, ;
	SPACE(35) AS asiandetds, ;
	Ai_clien.hudchronic ;
FROM ;
	client, ai_clien, ai_activ, statvalu, userprof, staff ;
WHERE ;
	client.client_id 	= ai_clien.client_id ;
	AND ai_clien.tc_id = ai_activ.tc_id ;
	AND (DTOS(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm)) IN ;
								(SELECT MAX(DTOS(effect_dt)+oApp.Time24(aa.time, aa.am_pm)) ;
									FROM ai_activ aa ;
									WHERE ;
										aa.tc_id = ai_activ.tc_id ;
										AND aa.effect_dt <= m.as_of_d ) ;
	AND statvalu.tc + statvalu.type + statvalu.code = gcTC + 'ACTIV' + ai_activ.status and ;
	ai_clien.int_worker = userprof.worker_id and ;
	userprof.staff_id = staff.staff_id ;
HAVING ;
	stattype = cStatType;
INTO CURSOR ;
	temp

IF cStatType = "A"
	cPrgEndXpr = "AND (EMPTY(ai_prog.end_dt) OR ai_prog.end_dt > m.as_of_d) "
ELSE
	cPrgEndXpr = ""
ENDIF

*** jss, 8/25/00: NOTE:	cPrgEndXpr filters on open in program when Active is selected.
***               temp2 is used for program-level extract, which is fine. But, it also 
***               filters temp into temp3, meaning that when we select 'A'ctive, we 
***               only get active in Agency AND open in program (see cPrgEndXpr just above)
*** How to correct: 1) probably, we need to remove the line 'AND temp.tc_id IN (select tc_id 
***                 from temp2)' in the Where clause creating temp3 below. This will give us all
***                 active clients in agency, regardless of their program enrollment status
***    Additionally, we should handle intakes as in the aggregate report; namely, consider
***                 the intake program (not just the tc_id) when determining an intake. currently,
***                 we just check for tc_id existing in ai_prog
***       Finally, it is possible that we add additional selection variable for 'Active/Closed in 
***                program, in order to handle the following permutations: Active in Agency/Closed
***                in program, Active in agency and program, closed in agency and program.


* jss, 1/19/04, add 2 new fields, reason, reas_desc
* Get the client's program
SELECT ;
	temp.tc_id, ;
	ai_prog.program, ;
	ai_prog.start_dt as prog_date, ;
	ai_prog.end_dt as prog_end, ;
	program.descript as program_ds, ;
	"Enrolled" as type ;
FROM ;
	temp, ai_prog, program ;
WHERE ;
	temp.tc_id = ai_prog.tc_id ;
	AND ai_prog.program = program.prog_id ;
	AND ai_prog.program = lcProg ;
	AND ai_prog.tc_id + ai_prog.program + DTOS(ai_prog.start_dt) IN ;
							(	SELECT ;
									MAX(tc_id + program + DTOS(start_dt) ) ;
								FROM ;
									ai_prog aip ;
								WHERE ;
									aip.start_dt <= m.as_of_d ;
								GROUP BY ;
									aip.tc_id, aip.program ) ;
	&cPrgEndXpr ;
	AND &lcExpr ;
UNION ;
SELECT ;
	temp.tc_id, ;
	program.prog_id as program, ;
	ai_clien.placed_dt as prog_date, ;
	{} as prog_end, ;
	program.descript as program_ds, ;
	"Intake" as type ;
FROM ;
	temp, Ai_Clien, Program ;
WHERE ;
	temp.Tc_ID = ai_clien.Tc_ID ;
	AND ai_clien.Int_Prog = program.Prog_ID ;
	AND temp.Placed_Dt <= m.as_of_d ;
	AND NOT EXISTS (SELECT * FROM Ai_Prog WHERE Ai_Prog.Tc_ID = temp.Tc_ID) ;
	AND &lcExpr ;
	AND program.Prog_ID = lcProg ;
INTO CURSOR ;
	temp2a

SELECT temp2a.*, ;
		ai_prog.reason, ;
		SPACE(50) AS reas_desc ;
FROM temp2a, ai_prog ;
WHERE temp2a.tc_id   = ai_prog.tc_id ;
  AND temp2a.program   = ai_prog.program ;
  AND temp2a.prog_date = ai_prog.start_dt ;
  AND temp2a.prog_end	= ai_prog.end_dt  ;
UNION ;
SELECT temp2a.*, ;
		SPACE(2) AS reason, ;
		SPACE(50) AS reas_desc ;
FROM temp2a ;
WHERE tc_id + program + DTOS(prog_date) + DTOS(prog_end)	NOT IN ;
	(SELECT p2.tc_id + p2.program + DTOS(p2.start_dt) + DTOS(p2.end_dt) FROM ai_prog	p2) ;
INTO CURSOR ;
	temp2 readwrite	

* jss, 1/19/04, must make cursor writable to add reason description

*=ReOpenCur("temp2b", "temp2")
* jss, 8/17/07, d/t consolidation of closure reasons (all found in closcode table now), comment and correct next several lines
**=OPENFILE("prg_clos","code")
=OPENFILE("closcode","code")
SELECT temp2
**SET RELATION TO reason INTO prg_clos
SET RELATION TO reason INTO closcode
GO TOP
REPLACE ALL reas_desc WITH closcode.descript FOR NOT EOF('closcode')
**REPLACE ALL reas_desc WITH prg_clos.descript FOR NOT EOF('prg_clos')
**USE IN prg_clos

* Get the client's site
*!* 07/05/2007 PB: Original cod below.
*!* PRoblem with performance and quality

IF EMPTY(cCSite)
   * no site selected - pick all clients with their sites and those without site
   SELECT ;
      temp.*, ;
      ai_site.site, ;
      ai_site.effect_dt as site_date, ;
      site.descript1 as site_ds ;
   FROM ;
      temp, ai_site, site ;
   WHERE ;
      temp.tc_id = ai_site.tc_id ;
      AND ai_site.tc_id + ttoc(effective_dttm,1) IN ;
                           (SELECT ;
                             MAX(tc_id + ttoc(effective_dttm,1)) ;
                            FROM ;
                             ai_site ais ;
                            WHERE ;
                             ais.effect_dt <= m.as_of_d ;
                            GROUP BY ;
                             ais.tc_id ) ;
      AND ai_site.site = site.site_id ;
      AND temp.tc_id IN (select tc_id from temp2) ;
   UNION ;
   SELECT ;
      temp.*, ;
      SPACE(5) as site, ;
      {} as site_date, ;
      "Site Unknown" as site_ds ;
   FROM ;
      temp ;
   WHERE ;
      temp.tc_id NOT IN (SELECT tc_id FROM ai_site) ;
      AND temp.tc_id IN (select tc_id from temp2) ;
   INTO CURSOR ;
      temp3 readwrite
ELSE
   * pick only clients of selected site
   SELECT ;
      temp.*, ;
      ai_site.site, ;
      ai_site.effect_dt as site_date, ;
      site.descript1 as site_ds ;
   FROM ;
      temp, ai_site, site ;
   WHERE ;
      temp.tc_id = ai_site.tc_id ;
      AND ai_site.site = cCSite ;
      AND ai_site.tc_id + ttoc(effective_dttm,1) IN ;
                           (   SELECT ;
                                 MAX(tc_id + ttoc(effective_dttm,1)) ;
                              FROM ;
                                 ai_site ais ;
                              WHERE ;
                                 ais.effect_dt <= m.as_of_d ;
                              GROUP BY ;
                                 ais.tc_id ) ;
      AND ai_site.site = site.site_id ;
      AND temp.tc_id IN (select tc_id from temp2) ;
   INTO CURSOR ;
      temp3 readwrite
ENDIF


*!*  07/05/2007 PB: This is the original code.  
*!*  Code above is for testing.

*!*   * Get the client's site
*!*   IF EMPTY(cCSite)
*!*   	* no site selected - pick all clients with their sites and those without site
*!*   	SELECT ;
*!*   		temp.*, ;
*!*   		ai_site.site, ;
*!*   		ai_site.effect_dt as site_date, ;
*!*   		site.descript1 as site_ds ;
*!*   	FROM ;
*!*   		temp, ai_site, site ;
*!*   	WHERE ;
*!*   		temp.tc_id = ai_site.tc_id ;
*!*   		AND ai_site.tc_id + DTOS(ai_site.effect_dt) + oApp.Time24(ai_site.time, ai_site.am_pm) IN ;
*!*   									(	SELECT ;
*!*   											MAX(tc_id + DTOS(effect_dt) + oApp.Time24(ais.time, ais.am_pm)) ;
*!*   										FROM ;
*!*   											ai_site ais ;
*!*   										WHERE ;
*!*   											ais.effect_dt <= m.as_of_d ;
*!*   										GROUP BY ;
*!*   											ais.tc_id ) ;
*!*   		AND ai_site.site = site.site_id ;
*!*   		AND temp.tc_id IN (select tc_id from temp2) ;
*!*   	UNION ;
*!*   	SELECT ;
*!*   		temp.*, ;
*!*   		SPACE(5) as site, ;
*!*   		{} as site_date, ;
*!*   		"Site Unknown" as site_ds ;
*!*   	FROM ;
*!*   		temp ;
*!*   	WHERE ;
*!*   		temp.tc_id NOT IN (SELECT tc_id FROM ai_site) ;
*!*   		AND temp.tc_id IN (select tc_id from temp2) ;
*!*   	INTO CURSOR ;
*!*   		temp3 readwrite
*!*   ELSE
*!*   	* pick only clients of selected site
*!*   	SELECT ;
*!*   		temp.*, ;
*!*   		ai_site.site, ;
*!*   		ai_site.effect_dt as site_date, ;
*!*   		site.descript1 as site_ds ;
*!*   	FROM ;
*!*   		temp, ai_site, site ;
*!*   	WHERE ;
*!*   		temp.tc_id = ai_site.tc_id ;
*!*   		AND ai_site.site = cCSite ;
*!*   		AND ai_site.tc_id + DTOS(ai_site.effect_dt) + oApp.Time24(ai_site.time, ai_site.am_pm) IN ;
*!*   									(	SELECT ;
*!*   											MAX(tc_id + DTOS(effect_dt) + oApp.Time24(ais.time, ais.am_pm)) ;
*!*   										FROM ;
*!*   											ai_site ais ;
*!*   										WHERE ;
*!*   											ais.effect_dt <= m.as_of_d ;
*!*   										GROUP BY ;
*!*   											ais.tc_id ) ;
*!*   		AND ai_site.site = site.site_id ;
*!*   		AND temp.tc_id IN (select tc_id from temp2) ;
*!*   	INTO CURSOR ;
*!*   		temp3 readwrite
*!*   ENDIF

* jss, 2/24/05, replace race detail descriptions now, make temp3 writable first, then fill in the descriptions
*=ReOpenCur("temp3", "temp3a")
=OpenFile("racedet","code")
*SELECT temp3a
SELECT temp3
SET RELATION TO hispdet INTO racedet
GO TOP
REPLACE ALL hispdetds WITH IIF(EOF('racedet'), SPACE(35), racedet.descript)
SET RELATION TO
SET RELATION TO whitedet INTO racedet
GO TOP
REPLACE ALL whitedetds WITH IIF(EOF('racedet'), SPACE(35), racedet.descript)
SET RELATION TO
SET RELATION TO blackdet INTO racedet
GO TOP
REPLACE ALL blackdetds WITH IIF(EOF('racedet'), SPACE(35), racedet.descript)
SET RELATION TO
SET RELATION TO asiandet INTO racedet
GO TOP
REPLACE ALL asiandetds WITH IIF(EOF('racedet'), SPACE(35), racedet.descript)
SET RELATION TO

SELECT ursdata
ZAP

APPEND FROM (DBF("temp3"))
* jss, 7/23/07, next block of code is being moved to end of URSDATA section, AFTER descriptions have been filled in
*!*   If oapp.gldataencrypted
*!*      Go Top
*!*      Scan

*!*         If !Empty(last_name) And !IsNull(last_name)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(last_name)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace last_name With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(first_name) And !IsNull(first_name)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(first_name)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace first_name With lcDecryptedStream
*!*         EndIf

*!*         If !Empty(ssn) And !IsNull(ssn)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(ssn)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace ssn With lcDecryptedStream
*!*         EndIf

*!*         If !Empty(ssi_no) And !IsNull(ssi_no)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(ssi_no)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace ssi_no With lcDecryptedStream
*!*         EndIf

*!*         If !Empty(cinn) And !IsNull(cinn)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(cinn)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace cinn With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(phhome) And !IsNull(phhome)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(phhome)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace phhome With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(phwork) And !IsNull(phwork)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(phwork)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace phwork With lcDecryptedStream
*!*         EndIf
*!*         
*!*      EndScan
*!*   Endif

*!*   Copy To extracts\ursdata.dbf Type FOX2X
*!*   =CursorToXML('ursdata','extracts\xml\ursdata.xml',1,512)

SELECT ursprog
ZAP

APPEND FROM (DBF("temp2"))
* jss, 7/23/07, move next 2 lines until AFTER all fields are loaded
*!*   Copy To extracts\ursprog.dbf Type FOX2X
*!*   =CursorToXML('ursprog','extracts\xml\ursprog.xml',1,512)

USE IN temp2
* jss, 1/19/04
USE IN temp2a
*USE IN temp2b

USE IN temp3
*USE IN temp3a

=OpenFile("COUNTY", "STATECODE")
=OpenFile("EXPOSURE", "CODE", "EXPOSURE1")
=OpenFile("EXPOSURE", "CODE", "EXPOSURE2")
=OpenFile("HOUSING", "CODE")
=OpenFile("REF_IN", "CODE")
* jss, 7/17/01, add 2 more files: ref_srce, ref_cntc for description lookups
=OpenFile("REF_SRCE", "CODE")
=OpenFile("REF_CNTC", "CODE")
=OpenFile("TBDESC", "CODE")
* jss, 8/17/07, remove all "ethnic" references, no longer in URSDATA
**=OpenFile("ETHNIC", "CODE")
=OpenFile("GENDER", "CODE")
=OpenFile("LANGUAGE", "CODE", "LANGUAGE1")
=OpenFile("LANGUAGE", "CODE", "LANGUAGE2")
=OpenFile("LANGUAGE", "CODE", "LANGUAGE3")
=OpenFile("LANGUAGE", "CODE", "LANGUAGE4")
=OpenFile("MARITAL", "CODE")
=OpenFile("RELIG", "CODE")
=OpenFile("HSTAT", "CODE")
=OpenFile("DRUGTYPE", "CODE")
=OpenFile("SUBSFREQ", "CODE")
=OpenFile("ADMTYPE", "CODE")
=OpenFile("CLOSCODE", "CODE")
=OpenFile("AAR_TAB", "AAR_INFO", "AAR_TAB1")
SET FILTER TO !EMPTY(AAR_INFO)
=OpenFile("AAR_TAB", "AAR_INFO", "AAR_TAB2")
SET FILTER TO !EMPTY(AAR_INFO)

* Pre-select all clients' addresses
*=OpenFile('address',  'hshld_id')
*=OpenFile('cli_hous', 'client_id')

*!*   SELECT ;
*!*   	cli_hous.client_id, address.addr_id, address.date, ;
*!*   	address.street1 as street, address.street2, ;
*!*   	address.city, address.st, address.zip, address.county ;
*!*   FROM ;
*!*   	cli_hous, address ;
*!*   WHERE ;
*!*   	cli_hous.hshld_id = address.hshld_id AND ;
*!*   	cli_hous.lives_in ;
*!*   INTO CURSOR ;
*!*   	cli_addr

Select Address
Set Order To CLIENT_ID   && CLIENT_ID
SET RELATION TO st + county INTO county
GO TOP

* get all workers
*=All_Staff()
* staffcur indexed in main program
Select staffcur
SET ORDER TO worker_id

* worker assignments
=OpenFile('ai_work', 'tc_id2 desc')
SET RELATION TO worker_id INTO staffcur
SET FILTER TO effect_dt <= m.as_of_d
GO TOP

* HIV statuses
=OpenFile('hivstat', 'tc_id')
SET RELATION TO hivstatus INTO hstat
SET FILTER TO effect_dt <= m.as_of_d
GO TOP

* Substance Use
=OpenFile('ai_subs', 'tc_id')
SET RELATION TO drugcode  INTO drugtype
SET RELATION TO howadmin  INTO admtype  ADDITIVE
SET RELATION TO freqofuse INTO subsfreq ADDITIVE
SET FILTER TO infodate <= m.as_of_d
GO TOP

SELECT ;
	is1.client_id, ;
   is1.prov_id as pprov_id, ;
   is1.effect_dt as pstart_dt, ;
	is1.exp_dt as pexp_dt, ;
   is1.pol_num as ppol_num, ;
   is1.insured as pinsure, ;
	med_prov.name as pprov_name, ;
   med_prov.instype as ptype, ;
	instype.descript as ptype_ds ;
FROM ;
	insstat is1, med_prov, instype ;
WHERE ;
	is1.prim_sec = 1 AND ;
	is1.effect_dt <= m.as_of_d AND ;
	is1.prov_id = med_prov.prov_id AND ;
	med_prov.instype = instype.code AND ;
	is1.client_id + Dtos(is1.effect_dt) IN (SELECT is2.client_id+ Dtos(MAX(is2.effect_dt)) ;
				   		FROM insstat is2 ;
					   	WHERE ;
							   is2.effect_dt <= m.as_of_d AND ;
   							is2.prim_sec = 1 ;
                     GROUP BY is2.client_id) ;
INTO CURSOR ;
	prim_ins

INDEX ON client_id TAG client_id
 
SELECT ;
	is1.client_id, ;
   is1.prov_id as sprov_id, ;
   is1.effect_dt as sstart_dt, ;
	is1.exp_dt as sexp_dt, ;
   is1.pol_num as spol_num, ;
   is1.insured as sinsure, ;
	med_prov.name as sprov_name, ;
   med_prov.instype as stype, ;
	instype.descript as stype_ds ;
FROM ;
	insstat is1, med_prov, instype ;
WHERE ;
	is1.prim_sec = 2 AND ;
	is1.effect_dt <= m.as_of_d AND ;
	is1.prov_id = med_prov.prov_id AND ;
	med_prov.instype = instype.code AND ;
   is1.client_id + Dtos(is1.effect_dt) IN (SELECT is2.client_id+ Dtos(MAX(is2.effect_dt)) ;
                     FROM insstat is2 ;
                     WHERE ;
                        is2.effect_dt <= m.as_of_d AND ;
                        is2.prim_sec = 2 ;
                     GROUP BY is2.client_id) ;
INTO CURSOR ;
	sec_ins

INDEX ON client_id TAG client_id

SELECT ursdata
SET RELATION TO client_id  INTO address
SET RELATION TO tc_id      INTO hivstat   ADDITIVE
SET RELATION TO tc_id      INTO ai_subs   ADDITIVE
*SET RELATION TO ethnic     INTO ethnic    ADDITIVE
SET RELATION TO gender     INTO gender    ADDITIVE
* jss, 6/2000, correct mapping problem for languages spoken/read: primary spoken: language1
*              secondary spoken: language2, primary read: language3, secondary read: language4
SET RELATION TO prim_lang  INTO language1 ADDITIVE
SET RELATION TO sec_lang   INTO language2 ADDITIVE
SET RELATION TO read_lang1 INTO language3 ADDITIVE
SET RELATION TO read_lang2 INTO language4 ADDITIVE
SET RELATION TO marital    INTO marital   ADDITIVE
SET RELATION TO relig      INTO relig     ADDITIVE
*SET RELATION TO hiv_exp1   INTO exposure1 ADDITIVE
*SET RELATION TO hiv_exp2   INTO exposure2 ADDITIVE
SET RELATION TO housing    INTO housing   ADDITIVE
SET RELATION TO ref_src2   INTO ref_in    ADDITIVE
SET RELATION TO histoftb   INTO tbdesc    ADDITIVE
SET RELATION TO close_code INTO closcode  ADDITIVE
SET RELATION TO client_id  INTO prim_ins  ADDITIVE
SET RELATION TO client_id  INTO sec_ins   ADDITIVE
* jss, 7/17/01, add next 2 lines
SET RELATION TO ref_source INTO ref_srce  ADDITIVE
SET RELATION TO ref_cntc   INTO ref_cntc  ADDITIVE

set exact off
GO TOP

* jss, 12/15/03, replace age with calculated age as of today if dob is there
* Fill in information

* jss, 9/2/04, remove next 2 lines
*	hiv_ex1_ds WITH exposure1.descript, ;
*	hiv_ex2_ds WITH exposure2.descript
 
**   ethnic_ds  WITH ALLTRIM(ethnic.descript), ;

REPLACE ALL ;
	street     WITH address.street1, ;
	street2    WITH address.street2, ;
	city       WITH address.city, ;
	st         WITH address.st, ;
	zip        WITH address.zip, ;
	county     WITH address.county, ;
	county_ds  WITH county.descript, ;
	gender_ds  WITH gender.descript, ;
	pr_lang_ds WITH language1.descript, ;
	sec_l_ds   WITH language2.descript, ;
	read_l1_ds WITH language3.descript, ;
	read_l2_ds WITH language4.descript, ;
	marit_ds   WITH marital.descript, ;
	relig_ds   WITH relig.descript, ;
	housing_ds WITH housing.descript, ;
	ref_s2_ds  WITH ref_in.descript, ;
	hist_tb_ds WITH tbdesc.descript, ;
	hivstatus  WITH hivstat.hivstatus, ;
	hivstat_dt WITH hivstat.effect_dt, ;
	hiv_pos    WITH hstat.hiv_pos, ;
	hivstat_ds WITH hstat.descript, ;
	drugcode   WITH ai_subs.drugcode, ;
	howadmin   WITH ai_subs.howadmin, ;
	freqofuse  WITH ai_subs.freqofuse, ;
	drug_ds    WITH drugtype.descript, ;
	admin_ds   WITH admtype.descript, ;
	freq_ds    WITH subsfreq.descript, ;
	closcod_ds WITH closcode.descript, ;
	pprov_id   WITH prim_ins.pprov_id, ;
	pstart_dt  WITH prim_ins.pstart_dt, ;
	pexp_dt    WITH prim_ins.pexp_dt, ;
	ppol_num   WITH prim_ins.ppol_num, ;
	pinsure    WITH prim_ins.pinsure, ;
	pprov_name WITH prim_ins.pprov_name, ;
	ptype      WITH prim_ins.ptype, ;
	ptype_ds   WITH prim_ins.ptype_ds, ;
	sprov_id   WITH sec_ins.sprov_id, ;
	sstart_dt  WITH sec_ins.sstart_dt, ;
	sexp_dt    WITH sec_ins.sexp_dt, ;
	spol_num   WITH sec_ins.spol_num, ;
	sinsure    WITH sec_ins.sinsure, ;
	sprov_name WITH sec_ins.sprov_name, ;
	stype      WITH sec_ins.stype, ;
	stype_ds   WITH sec_ins.stype_ds, ;
	ref_src_ds WITH ref_srce.name, ;
	ref_cnt_ds WITH PADR(TRIM(ref_cntc.first_name) + ' ' + TRIM(ref_cntc.last_name),36), ;
	insurdesc  WITH IIF(insurance=1, 'Known/Specify', IIF(insurance=2, 'Unknown/Unreported', IIF(insurance=3,'No Insurance',SPACE(18)))), ;
	age		  WITH IIF(EMPTY(dob),age,Age(Date(),dob))
	

* jss, 7/17/01, add routine to fill in the user-defined descriptions
=OPENFILE('UDF_LUT','NAMECODE')

SELE ursdata
SCAN
	FOR i=1 TO 10
		FldName='USER'+ALLTRIM(STR(i))
		IF !EMPTY(&FldName)
			SeekKey=PADR(FldName,10)+&FldName
			IF SEEK(SeekKey,'UDF_LUT')
				DsName=FldName + '_DS'
				REPLACE &DsName WITH udf_lut.descript					
			ENDIF
		ENDIF
	ENDFOR
ENDSCAN

SET RELATION TO

* fill in CDC defined AIDS
GO TOP
SCAN
	dCDCDate = {}
	IF CDC_AIDS(ursdata.tc_id, dCDCDate)
		REPLACE ursdata.cdc_aids WITH .t., cdcaids_dt WITH dCDCDate
	ENDIF
ENDSCAN

* jss, 7/27/07, moved decryption from above. Also, add street, ppol_num, and spol_num to decryption
If oapp.gldataencrypted
   Go Top
   Scan

      If !Empty(last_name) And !IsNull(last_name)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(last_name)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace last_name With lcDecryptedStream
      EndIf
      
      If !Empty(first_name) And !IsNull(first_name)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(first_name)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace first_name With lcDecryptedStream
      EndIf

      If !Empty(ssn) And !IsNull(ssn)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(ssn)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace ssn With lcDecryptedStream
      EndIf

* jss, 8/17/07, remove references to ssi_no, no longer in URSDATA
*!*         If !Empty(ssi_no) And !IsNull(ssi_no)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(ssi_no)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace ssi_no With lcDecryptedStream
*!*         EndIf

      If !Empty(cinn) And !IsNull(cinn)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(cinn)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace cinn With lcDecryptedStream
      EndIf
      
      If !Empty(phhome) And !IsNull(phhome)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(phhome)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace phhome With lcDecryptedStream
      EndIf
      
      If !Empty(phwork) And !IsNull(phwork)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(phwork)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace phwork With lcDecryptedStream
      EndIf
      
* jss, 7/23/07, add street, ppol_num, spol_num 
      If !Empty(street) And !IsNull(street)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(street)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace street With lcDecryptedStream
      EndIf
      
      If !Empty(ppol_num) And !IsNull(ppol_num)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(ppol_num)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace ppol_num With lcDecryptedStream
      EndIf
      
      If !Empty(spol_num) And !IsNull(spol_num)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(spol_num)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace spol_num With lcDecryptedStream
      EndIf
      
   EndScan
Endif

* jss, 7/23/07, this code moved from above to correct a problem with missing descriptions
Copy To extracts\ursdata.dbf Type FOX2X
=CursorToXML('ursdata','extracts\xml\ursdata.xml',1,512)

REINDEX

***********************************************************************
** Get the combination of all URS services and encounters
***********************************************************************
** Get all URS encounters
* jss, 5/6/03, add code here for date_compl, team, diagnos1, diagnos2
* jss, 6/30/03, add code here for servcatdes, enclocdesc, enc_withds, ref_cont_w, invlvagdes, ref_cont_2, invlvag2ds
* jss, 6/15/04, add user_id, dt
*!*   SELECT ;
*!*      ai_enc.tc_id,ai_enc.act_id, ;
*!*      ai_enc.serv_cat,serv_cat.descript AS servcatdes,ai_enc.enc_type,ai_enc.program,ai_enc.site, ;
*!*      ai_enc.act_dt,ai_enc.act_loc,SPACE(30) AS enclocdesc,ai_enc.beg_am,ai_enc.beg_tm, ;
*!*      ai_enc.end_am,ai_enc.end_tm,ai_enc.date_compl, ;
*!*      ai_enc.enc_with,SPACE(40) as enc_withds,ai_enc.ref_cont_w,SPACE(40) as invlvagdes,ai_enc.ref_cont_2, ;
*!*      SPACE(40) as invlvag2ds,ai_enc.worker_id, ;
*!*      ai_enc.team,ai_enc.diagnos1,ai_enc.diagnos2, ;
*!*      program.descript as prog_descr, ;
*!*      program.Aar_Report, program.Ctp_Elig, ;
*!*      site.descript1 as site_descr, ;
*!*      ai_enc.user_id,ai_enc.dt;
*!*   FROM ;
*!*      ai_enc,program,site,ursdata,serv_cat ;
*!*   WHERE ;
*!*      ai_enc.tc_id=ursdata.tc_id;
*!*      AND ai_enc.act_dt<=m.as_of_d ;
*!*      AND ai_enc.site=site.site_id ;
*!*      AND ai_enc.program=program.prog_id ;
*!*      AND &lcExpr ; 
*!*      AND ai_enc.serv_cat=serv_cat.code ;
*!*   INTO CURSOR  ;
*!*      enc_curt1

* jss, 5/2/07, use enc_id instead of enc_type   
SELECT ;
   ai_enc.tc_id,ai_enc.act_id, ;
   ai_enc.serv_cat,serv_cat.descript AS servcatdes,ai_enc.enc_id,ai_enc.program,ai_enc.site, ;
   ai_enc.act_dt,ai_enc.act_loc,SPACE(30) AS enclocdesc,ai_enc.beg_am,ai_enc.beg_tm, ;
   ai_enc.end_am,ai_enc.end_tm,ai_enc.date_compl, ;
   ai_enc.enc_with,SPACE(40) as enc_withds,ai_enc.ref_cont_w,SPACE(40) as invlvagdes,ai_enc.ref_cont_2, ;
   SPACE(40) as invlvag2ds,ai_enc.worker_id, ;
   ai_enc.team,ai_enc.diagnos1,ai_enc.diagnos2, ;
   program.descript as prog_descr, ;
   program.Aar_Report, program.Ctp_Elig, ;
   site.descript1 as site_descr, ;
   ai_enc.user_id,ai_enc.dt;
FROM ;
   ai_enc,program,site,ursdata,serv_cat ;
WHERE ;
   ai_enc.tc_id=ursdata.tc_id;
   AND ai_enc.act_dt<=m.as_of_d ;
   AND ai_enc.site=site.site_id ;
   AND ai_enc.program=program.prog_id ;
   AND &lcExpr ; 
   AND ai_enc.serv_cat=serv_cat.code ;
INTO CURSOR  ;
   enc_curt1
   
* jss, 8/12/04, add new field "duration"
* jss, 1/13/05, put
*!*   SELECT ;
*!*      enc_curt1.*, ;
*!*      enc_type.descript as enc_descr,;
*!*      enc_type.cadr_map AS enc_cadr,;
*!*      enc_type.mai_map As enc_mai, ;
*!*      0000 AS duration ;
*!*   FROM enc_curt1, enc_type ;
*!*   WHERE enc_curt1.enc_type  = enc_type.code ;
*!*      AND enc_curt1.serv_cat = enc_type.serv_cat ;
*!*   INTO CURSOR ;
*!*      enc_cur readwrite

* jss, 5/2/07, grab cadr_map, mai_map and description from the new AIRS encounter tables
SELECT ;
   enc_curt1.*, ;
   enc_list.description AS enc_descr,;
   enc_sc_link.cadr_map AS enc_cadr,;
   enc_sc_link.mai_map  AS enc_mai, ;
   0000 AS duration ;
FROM enc_curt1 ;
   Join enc_list    on enc_curt1.enc_id   = enc_list.enc_id ;
   Join enc_sc_link on enc_curt1.enc_id   = enc_sc_link.enc_id ;
                   and enc_curt1.serv_cat = enc_sc_link.serv_cat ;
INTO CURSOR ;
   enc_cur readwrite

USE IN enc_curt1
*=ReOpenCur("enc_curt", "enc_cur")

* now, let's fill in descriptions
=OPENFILE("enc_with", "progcode") && serv_cat + code
=OPENFILE("serv_loc", "progcode") && serv_cat + code
=OPENFILE("ref_srce", "code") && code


SELECT enc_cur

SET RELATION TO serv_cat+enc_with   INTO enc_with 
SET RELATION TO serv_cat+act_loc    INTO serv_loc 	ADDI
SET RELATION TO ref_cont_w 			INTO ref_srce 	ADDI
GO TOP

REPLACE ALL enc_withds WITH enc_with.descript, ;
				enclocdesc WITH serv_loc.descript, ; 
				invlvagdes WITH ref_srce.name

SET RELA TO
SET RELATION TO ref_cont_2 			INTO ref_srce	
GO TOP
REPLACE ALL invlvag2ds WITH ref_srce.name

*USE IN enc_curt
USE IN enc_with
USE IN serv_loc
USE IN ref_srce

** Combine encounters with services
* jss, 2/7/02, add code for numitems and value
* jss, 4/2/03, add serv_id and att_id to selects below so we can later look up topics
* jss, 6/30/03, add s_work_id, s_workname (service worker and worker name)
* jss, 8/11/04, add s_user_id, s_username, s_dt 
* jss, 9/20/05, add "All" to "Union" in order to include rows for agencies with multiple entries of the same kind of service on the same date for an encounter (Connecticut)
* jss, 4/21/06, sercadr2 should be filled with service.cadrmap2 (was being filled with cadr_map erroneously)...fix throughout program

*!*   SELECT ;
*!*      enc_cur.*, ;
*!*      ai_serv.s_beg_tm, ai_serv.s_beg_am, ai_serv.s_end_tm, ai_serv.s_end_am, ;
*!*      ai_serv.service, service.descript AS serv_descr, ;
*!*      service.cadr_map AS serv_cadr, ai_serv.s_value, ai_serv.numitems, service.cadrmap2 AS sercadr2, service.mai_map as serv_mai, ;
*!*      Space(30) as how_provd, ;
*!*      ai_serv.outcome, ;
*!*      ai_serv.proc_serv, ;
*!*      ai_serv.worker_id AS s_work_id, ;
*!*      ai_serv.s_location, ; 
*!*      ai_serv.serv_id, ;
*!*      ai_serv.att_id, ;
*!*      ai_serv.user_id as s_user_id, ;
*!*      ai_serv.dt       as s_dt ;
*!*   FROM ;
*!*      enc_cur, ai_serv, service ;
*!*   WHERE ;
*!*      ai_serv.act_id = enc_cur.act_id;
*!*      AND enc_cur.serv_cat = service.serv_cat;
*!*      AND (enc_cur.enc_type = service.enc_type OR EMPTY(service.enc_type)) ;
*!*      AND ai_serv.service = service.code and ;
*!*         Empty(ai_serv.how_prov);
*!*   UNION ALL;      
*!*   SELECT ;
*!*      enc_cur.*, ;
*!*      ai_serv.s_beg_tm, ai_serv.s_beg_am, ai_serv.s_end_tm, ai_serv.s_end_am, ;
*!*      ai_serv.service, service.descript AS serv_descr, ;
*!*      service.cadr_map AS serv_cadr, ai_serv.s_value, ai_serv.numitems, service.cadrmap2 AS sercadr2, service.mai_map as serv_mai,;
*!*      how_prov.descript as how_provd, ;
*!*      ai_serv.outcome, ;
*!*      ai_serv.proc_serv, ;
*!*      ai_serv.worker_id AS s_work_id, ;
*!*      ai_serv.s_location,  ; 
*!*      ai_serv.serv_id, ;
*!*      ai_serv.att_id, ;
*!*      ai_serv.user_id as s_user_id, ;
*!*      ai_serv.dt       as s_dt ;
*!*   FROM ;
*!*      enc_cur, ai_serv, service , how_prov;
*!*   WHERE ;
*!*      ai_serv.act_id = enc_cur.act_id;
*!*      AND enc_cur.serv_cat = service.serv_cat;
*!*      AND (enc_cur.enc_type = service.enc_type OR EMPTY(service.enc_type)) ;
*!*      AND ai_serv.service = service.code and ;
*!*         ai_serv.how_prov = how_prov.code and ;
*!*         ai_serv.serv_cat = how_prov.serv_cat ;
*!*   INTO CURSOR tenc0

* jss, 5/2/07, use ai_serv.service_id instead of ai_serv.service, grab data formerly found in service table from serv_list (description)
*              or serv_enc_link (mai_map, cadr_map, cadr_map2)
SELECT ;
   enc_cur.*, ;
   ai_serv.s_beg_tm, ;
   ai_serv.s_beg_am, ;
   ai_serv.s_end_tm, ;
   ai_serv.s_end_am, ;
   ai_serv.service_id, ;
   serv_list.description AS serv_descr, ;
   serv_enc_link.cadr_map AS serv_cadr, ;
   ai_serv.s_value, ;
   ai_serv.numitems, ;
   serv_enc_link.cadrmap2 AS sercadr2, ;
   serv_enc_link.mai_map as serv_mai, ;
   Space(30) as how_provd, ;
   ai_serv.outcome, ;
   ai_serv.proc_serv, ;
   ai_serv.worker_id AS s_work_id, ;
   ai_serv.s_location, ; 
   ai_serv.serv_id, ;
   ai_serv.att_id, ;
   ai_serv.user_id as s_user_id, ;
   ai_serv.dt       as s_dt ;
FROM ;
   enc_cur; 
 Join ai_serv       on enc_cur.act_id   = ai_serv.act_id ;
 Join enc_sc_link   on enc_cur.enc_id   = enc_sc_link.enc_id ;
                   and enc_cur.serv_cat = enc_sc_link.serv_cat ;
 Join serv_list     on ai_serv.service_id = serv_list.service_id ;
 Join serv_enc_link on serv_enc_link.enc_sc_id  = enc_sc_link.enc_sc_id ;
                   and serv_enc_link.service_id = serv_list.service_id ;
WHERE Empty(ai_serv.how_prov);
UNION ALL;      
SELECT ;
   enc_cur.*, ;
   ai_serv.s_beg_tm, ;
   ai_serv.s_beg_am, ;
   ai_serv.s_end_tm, ;
   ai_serv.s_end_am, ;
   ai_serv.service_id, ;
   serv_list.description AS serv_descr, ;
   serv_enc_link.cadr_map AS serv_cadr, ;
   ai_serv.s_value, ;
   ai_serv.numitems, ;
   serv_enc_link.cadrmap2 AS sercadr2, ;
   serv_enc_link.mai_map as serv_mai,;
   how_prov.descript as how_provd, ;
   ai_serv.outcome, ;
   ai_serv.proc_serv, ;
   ai_serv.worker_id AS s_work_id, ;
   ai_serv.s_location,  ; 
   ai_serv.serv_id, ;
   ai_serv.att_id, ;
   ai_serv.user_id as s_user_id, ;
   ai_serv.dt       as s_dt ;
FROM ;
   enc_cur ; 
 Join ai_serv       on enc_cur.act_id   = ai_serv.act_id ;
 Join enc_sc_link   on enc_cur.enc_id   = enc_sc_link.enc_id ;
                   and enc_cur.serv_cat = enc_sc_link.serv_cat ;
 Join serv_list     on ai_serv.service_id = serv_list.service_id ;
 Join serv_enc_link on serv_enc_link.enc_sc_id  = enc_sc_link.enc_sc_id ;
                   and serv_enc_link.service_id = serv_list.service_id ;
 Join how_prov      on ai_serv.how_prov = how_prov.code ;
                   and ai_serv.serv_cat = how_prov.serv_cat ;
WHERE !Empty(ai_serv.how_prov) ;
INTO CURSOR tenc0

* jss, 5/3/07, now using service_id, not service
Select * ;
from ;
	tenc0 ;
UNION ALL ;
SELECT ;
	enc_cur.*, ;
	space (4) as s_beg_tm, ;
   space(2) as s_beg_am, ;
	space (4) as s_end_tm, ;
   space(2) as s_end_am, ;
	0000 as service_id, ;
   "No services provided" AS serv_descr, ;
	space(4) AS serv_cadr, ;
   0 AS s_value, ;
   0 AS numitems, ;
   Space(4) AS  sercadr2, ;
   space(2) as serv_mai, ;
	Space(30) as how_provd, ;
	Space(3) as outcome, ;
	Space(50) as proc_serv, ;
	SPACE(5) as s_work_id , ;
	Space(2) as s_location, ;
	SPACE(10) AS serv_id, ;
	SPACE(10) AS att_id, ;
	SPACE(5) as s_user_id, ;
	{}		 as s_dt ;
FROM ;
	enc_cur ;
WHERE ;
	NOT EXIST (SELECT * FROM ai_serv WHERE ai_serv.act_id = enc_cur.act_id) ;
INTO CURSOR ;
	tenc1	

* jss, 8/17/07, comment code related to URSTOPIC: no longer loading this table	
*!*   *** jss, 4/2/03, new URSTOPIC creation logic follows: table contains client, encounter, service id's plus topic
*!*   * this select grabs topic based on non-blank serv_id
*!*   * jss, 5/3/07, now using service_id, not service
*!*   SELECT ;
*!*   	tenc1.tc_id, ;
*!*   	tenc1.act_id, ;
*!*   	tenc1.serv_cat, ;
*!*   	tenc1.enc_id, ;
*!*   	tenc1.enc_descr, ;
*!*   	tenc1.serv_id, ;
*!*   	tenc1.service_id, ;
*!*   	tenc1.serv_descr, ;
*!*   	topics.code as topic, ;
*!*   	topics.descript as topicdescr ;
*!*   FROM ;
*!*   	tenc1, ai_topic, topics ;
*!*   WHERE ;
*!*   	!EMPTY(tenc1.serv_id) ;
*!*   AND tenc1.serv_id = ai_topic.serv_id ;
*!*   AND ai_topic.serv_cat = topics.serv_cat ;
*!*   AND ai_topic.code = topics.code ;
*!*   INTO CURSOR ;
*!*   	tenc1a

*!*   * this select grabs topic based on non-blank att_id
*!*   * jss, 5/3/07, now using enc_id, not enc_type; service_id, not service
*!*   SELECT ;
*!*   	tenc1.tc_id, ;
*!*   	tenc1.act_id, ;
*!*   	tenc1.serv_cat, ;
*!*   	tenc1.enc_id, ;
*!*   	tenc1.enc_descr, ;
*!*   	tenc1.service_id, ;
*!*   	tenc1.serv_descr, ;
*!*   	topics.code as topic, ;
*!*   	topics.descript AS topicdescr ;
*!*   FROM ;
*!*   	tenc1, ;
*!*   	ai_topic, ;
*!*   	topics ;
*!*   WHERE ;
*!*   	!EMPTY(tenc1.att_id) ;
*!*   AND tenc1.serv_id NOT IN (SELECT serv_id FROM tenc1a) ;
*!*   AND tenc1.att_id = ai_topic.att_id ;
*!*   AND ai_topic.serv_cat = topics.serv_cat ;
*!*   AND ai_topic.code = topics.code ;
*!*   INTO CURSOR ;
*!*   	tenc1b
*!*   	
*!*   * merge tenc1a and tenc1b to get all URSTOPIC recs
*!*   * jss, 5/3/07, now using enc_id, not enc_type; service_id, not service
*!*   SELECT ;
*!*   	tc_id, ;
*!*   	act_id, ;
*!*   	serv_cat, ;
*!*   	enc_id, ;
*!*   	enc_descr, ;
*!*   	service_id, ;
*!*   	serv_descr, ;
*!*   	topic, ;
*!*   	topicdescr ;
*!*   FROM ;
*!*   	tenc1a ;
*!*   UNION  ;
*!*   SELECT * ;
*!*   FROM ;
*!*   	tenc1b ;
*!*   INTO CURSOR ;
*!*   	ttopic

*!*   SELECT urstopic
*!*   ZAP
*!*   APPEND FROM DBF("ttopic")
*!*   Copy To extracts\urstopic.dbf Type FOX2X
*!*   =CursorToXML('urstopic','extracts\xml\urstopic.xml',1,512)


*!*   USE IN ttopic
*!*   USE IN tenc1a
*!*   USE IN tenc1b
*!*   ***************************** jss, 4/2/03, end of new code for URSTOPIC creation

Select tenc1.*, ;
		serv_loc.descript as loc_descr ;
From tenc1, ;
		serv_loc;
Where tenc1.s_location = serv_loc.code and ;
		tenc1.serv_cat = serv_loc.serv_cat ;
Union all;
Select tenc1.*, ;
		Space(30) as loc_descr ;
From tenc1 ;
Where Empty(tenc1.s_location) ;
Into Cursor tenc2		

Use in tenc1

* jss, 6/15/04, add next code for routine UserName()
IF USED('userprof')
	SET ORDER TO worker_id IN userprof
ELSE
	USE userprof ORDER worker_id IN 0
ENDIF

IF USED('staff')
	SET ORDER TO staff_id IN staff
ELSE
	USE staff ORDER staff_id IN 0
ENDIF

SELECT userprof
SET RELATION TO staff_id INTO staff
GO TOP
*** end 6/15/04 add

* jss, 5/6/03, add code here for new fields date_compl, team, diagnos1, diagnos2
* jss, 6/30, add code to handle s_work_id, s_workname
* jss, 11/24/03, add fields att_id, grp_id to encserv
* jss, 8/11/04, useridname now username

* jss, 5/3/07, now using enc_id, not enc_type; service_id, not service
Select ;
	tenc2.tc_id, ;
   tenc2.act_id, ;
	tenc2.serv_cat, ;
   tenc2.enc_id, ;
   tenc2.program, ;
   tenc2.site, ;
	tenc2.act_dt, ;
   tenc2.beg_am, ;
   tenc2.beg_tm, ;
   tenc2.end_am, ;
   tenc2.end_tm, ;
   tenc2.duration, ;
	tenc2.date_compl, ;
	tenc2.worker_id, ;
	tenc2.team, ;
   tenc2.diagnos1, ;
   tenc2.diagnos2, ;
	tenc2.prog_descr, ;
	tenc2.Aar_Report, ;
   tenc2.Ctp_Elig, ;
	tenc2.site_descr, ;
	tenc2.enc_descr, ;
   tenc2.enc_cadr, ;
   tenc2.enc_mai, ;
	tenc2.s_beg_tm, ;
   tenc2.s_beg_am, ;
   tenc2.s_end_tm, ;
   tenc2.s_end_am, ;
	tenc2.service_id, ;
   tenc2.serv_descr, ;
	tenc2.serv_cadr, ;
   tenc2.s_value, ;
   tenc2.numitems, ;
   tenc2.sercadr2, ;
   tenc2.serv_mai, ;
	tenc2.how_provd, ;
	tenc2.outcome, ;
	tenc2.proc_serv, ;
	tenc2.servcatdes, ;
   tenc2.act_loc, ;
   tenc2.enclocdesc, ;
   tenc2.enc_with, ;
   tenc2.enc_withds, ;
   tenc2.ref_cont_w, ;
	tenc2.invlvagdes, ;
   tenc2.ref_cont_2, ;
   tenc2.invlvag2ds, ;
	tenc2.s_work_id, ;
	SPACE(30) AS s_workname, ;
	tenc2.s_user_id, ;
	USERNAME(tenc2.s_user_id) as s_username, ;
	tenc2.s_dt, ;
	tenc2.loc_descr, ;
	outcome.descript as out_descr, ;
	tenc2.att_id, ;
   SPACE(5) as Grp_id, ;
   tenc2.user_id, ;
   USERNAME(tenc2.user_id) as username, ;
   tenc2.dt ;
From tenc2, ;
		outcome;
Where tenc2.outcome = outcome.code ;
Union all;
Select ;
   tenc2.tc_id, ;
   tenc2.act_id, ;
   tenc2.serv_cat, ;
   tenc2.enc_id, ;
   tenc2.program, ;
   tenc2.site, ;
   tenc2.act_dt, ;
   tenc2.beg_am, ;
   tenc2.beg_tm, ;
   tenc2.end_am, ;
   tenc2.end_tm, ;
   tenc2.duration, ;
   tenc2.date_compl, ;
   tenc2.worker_id, ;
   tenc2.team, ;
   tenc2.diagnos1, ;
   tenc2.diagnos2, ;
   tenc2.prog_descr, ;
   tenc2.Aar_Report, ;
   tenc2.Ctp_Elig, ;
   tenc2.site_descr, ;
   tenc2.enc_descr, ;
   tenc2.enc_cadr, ;
   tenc2.enc_mai, ;
   tenc2.s_beg_tm, ;
   tenc2.s_beg_am, ;
   tenc2.s_end_tm, ;
   tenc2.s_end_am, ;
   tenc2.service_id, ;
   tenc2.serv_descr, ;
   tenc2.serv_cadr, ;
   tenc2.s_value, ;
   tenc2.numitems, ;
   tenc2.sercadr2, ;
   tenc2.serv_mai, ;
   tenc2.how_provd, ;
   tenc2.outcome, ;
   tenc2.proc_serv, ;
   tenc2.servcatdes, ;
   tenc2.act_loc, ;
   tenc2.enclocdesc, ;
   tenc2.enc_with, ;
   tenc2.enc_withds, ;
   tenc2.ref_cont_w, ;
   tenc2.invlvagdes, ;
   tenc2.ref_cont_2, ;
   tenc2.invlvag2ds, ;
   tenc2.s_work_id, ;
   SPACE(30) AS s_workname, ;
   tenc2.s_user_id, ;
   USERNAME(tenc2.s_user_id) as s_username, ;
   tenc2.s_dt, ;
   tenc2.loc_descr, ;
   Space(30) out_descr, ;
   tenc2.att_id, ;
   SPACE(5) as Grp_id, ;
   tenc2.user_id, ;
   USERNAME(tenc2.user_id) as username, ;
   tenc2.dt ;
From tenc2 ;
Where Empty(outcome) ;
Into Cursor encserv

Use in tenc2

* get the date and type of the first encounter provided in each program
SELECT DISTINCT ;
	encserv.tc_id, encserv.program, act_dt ;
FROM ;
	ursdata, encserv ;
WHERE ;
	ursdata.tc_id = encserv.tc_id AND ;
	DTOS(encserv.act_dt) + beg_am + beg_tm IN ;
			(SELECT MIN(DTOS(act_dt) + beg_am + beg_tm) ;
				FROM encserv ae ;
				WHERE ;
					ae.tc_id = encserv.tc_id AND ;
					ae.program = encserv.program AND ;
					!EMPTY(ae.act_dt)) ;
INTO CURSOR ;
	f_prog

INDEX ON tc_id + program tag tc_id_prog

* Select all programs client has been served by but has no enrollment
SELECT ;
	f_prog.tc_id, ;
	f_prog.program, ;
	f_prog.act_dt as prog_date, ;
	{} as prog_end, ;
	program.descript as program_ds, ;
	"Serviced" as type ;
FROM ;
	f_prog, Program ;
WHERE ;
	f_prog.Program = program.Prog_ID ;
	AND NOT EXISTS (SELECT * FROM ursprog WHERE ursprog.Tc_ID = f_prog.Tc_ID) ;
INTO CURSOR ;
	prog_serv

* Finish with program enrollment file.
* Add programs served.
* Put in the date first served, current worker
SELECT ursprog

APPEND FROM (DBF("prog_serv"))
USE IN prog_serv

SET RELATION TO ;
	tc_id + program INTO f_prog, ;
	tc_id + program INTO ai_work

GO TOP

REPLACE ;
	worker_id  WITH ai_work.worker_id, ;
	cur_worker WITH UPPER(NAME(staffcur.last, staffcur.first, staffcur.mi)), ;
	first_serv WITH f_prog.act_dt ;
ALL

SET RELATION TO

REINDEX
SET ORDER to tc_id_p
* jss, 7/23/07, next 2 lines moved from above to restore worker_id, cur_worker, first_serv columns
Copy To extracts\ursprog.dbf Type FOX2X
=CursorToXML('ursprog','extracts\xml\ursprog.xml',1,512)

* Services
* jss, 5/6/03, open up lookup tables here (need 2 copies of diagnosis for primary and secondary dx's)
=OPENFILE('diagnos','code')
SELECT * FROM diagnos INTO CURSOR diag2
*tempdiag nofilter readwrite
*=REOPENCUR('tempdiag', 'diag2')
INDEX ON code TAG diag2
=OPENFILE('teams','code')
* jss, 11/24/03, open grpatt table 
=OPENFILE('grpatt','att_id')

SELECT ursserv
ZAP
APPEND FROM DBF("encserv")
* jss, 7/23/07, move this code below, AFTER descriptions get loaded in
*!*   Copy To extracts\ursserv.dbf Type FOX2X
*!*   =CursorToXML('ursserv','extracts\xml\ursserv.xml',1,512)

USE IN encserv

SET RELATION TO worker_id INTO staffcur
* jss, 5/6/03, relate to new lookups
SET RELATION TO diagnos1	INTO diagnos ADDI
SET RELATION TO diagnos2  	INTO diag2   ADDI
SET RELATION TO team 		INTO teams   ADDI
* jss, 11/24/03, relate to grpatt
SET RELATION TO att_id		INTO grpatt	 ADDI
GO TOP
* jss, 11/24/03, load in grp_id
*!*   REPLACE ;
*!*      work_name  WITH UPPER(NAME(staffcur.last, staffcur.first, staffcur.mi)), ;
*!*      team_desc  WITH teams.descript, ;
*!*      diag1_desc WITH diagnos.descript, ;
*!*      diag2_desc WITH diag2.descript, ;
*!*      grp_id     WITH grpatt.grp_id ;
*!*   ALL
REPLACE ;
   work_name  WITH UPPER(NAME(staffcur.last, staffcur.first, staffcur.mi)), ;
   team_desc  WITH teams.descript, ;
   diag1_desc WITH diagnos.descript, ;
   diag2_desc WITH diag2.descript ;
ALL
* jss, 10/2/07, correct problem in which grpatt.att_id is empty, resulting in a grp_id being placed in all ursserv rows with a blank att_id
REPLACE grp_id WITH grpatt.grp_id for !Empty(att_id) 

* jss, 8/30/04, fill in new field "duration"
* jss, 9/3/04, add code to make duration zero when either time is empty
REPLACE ALL duration WITH IIF(EMPTY(s_beg_tm) OR EMPTY(s_end_tm), 0, TimeSpent(s_beg_tm, s_beg_am, s_end_tm, s_end_am))

SET RELATION TO
GO TOP

* jss, 6/30/03, get the s_workname description
SET RELATION TO s_work_id INTO staffcur
REPLACE ALL s_workname WITH UPPER(NAME(staffcur.last, staffcur.first, staffcur.mi))
SET RELATION TO	

* jss, 7/23/07, moved from above to bring back descriptions
Copy To extracts\ursserv.dbf Type FOX2X
=CursorToXML('ursserv','extracts\xml\ursserv.xml',1,512)

** jss, 7/20/01, add 2 new routines, makemeds() and makelabs() to create 2 more extract dbfs ursmeds (medication history), urslabs (labtest history)
=MakeMeds()
=MakeLabs()
** jss, 8/16/01, add new routine, makeplac(), to create new extract dbf ursplace (placement history)
=MakePlac()
** jss, 1/12/02, add new routine, makerisk(), to create new extract dbf ursrisk (hiv risk history)
=MakeRisk()
** jss, 11/26/03, add new routine, makeevnt(), to create new extract dbf ursevent (eto, outreach, prevention modules)
=MakeEvnt()

USE IN temp

SELECT ursdata

* jss, 3/7/07, data already decrypted above, no need for following code, so comment out
*!* Unencrypt the ursdata (client) information
*!*   If oapp.gldataencrypted
*!*      Go Top
*!*      Scan

*!*         If !Empty(last_name) And !IsNull(last_name)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(last_name)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace last_name With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(first_name) And !IsNull(first_name)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(first_name)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace first_name With lcDecryptedStream
*!*         EndIf

*!*         If !Empty(ssn) And !IsNull(ssn)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(ssn)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace ssn With lcDecryptedStream
*!*         EndIf

*!*         If !Empty(ssi_no) And !IsNull(ssi_no)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(ssi_no)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace ssi_no With lcDecryptedStream
*!*         EndIf

*!*         If !Empty(cinn) And !IsNull(cinn)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(cinn)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace cinn With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(phhome) And !IsNull(phhome)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(phhome)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace phhome With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(phwork) And !IsNull(phwork)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(phwork)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace phwork With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(ppol_num) And !IsNull(ppol_num)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(ppol_num)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace ppol_num With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(spol_num) And !IsNull(spol_num)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(spol_num)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace spol_num With lcDecryptedStream
*!*         EndIf
*!*         
*!*         If !Empty(street) And !IsNull(street)
*!*            lcDecryptedStream=''
*!*            lcEncryptedStream=Alltrim(street)
*!*            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

*!*            Replace street With lcDecryptedStream
*!*         EndIf
*!*         
*!*      EndScan
*!*   Endif

Select URSData.*, ;
   cTitle as cTitle, ;
   cReportSelection as cReportSelection, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   m.as_of_d as as_of_d ;
From URSData ;
Into Cursor ;
   URSDCurs readwrite 

Index on Upper(Last_name+First_name) tag Name
*SET ORDER TO name
SET RELATION TO tc_id INTO ursprog
SET SKIP TO ursprog
Go top 

oApp.Msg2User("OFF")

* jss, 6/18/04, instead of "The information you are requesting was not found", give new message "No clients found, but Event/Session Information may exist"
*               allow user to print extract tables structure listing even if no clients found

dtlEnded = Datetime()

*!* PB: 07/17/2007 - Added new report to produce only 1 page (completion).

IF EOF()
	oApp.msg2user('INFORM','No Clients Found, but Event/Session Information May Exist')
Else
      
   gcRptName = Iif(cSpecialOutput='L','rpt_dataextr','rpt_dataxcompleted')
   
   Do Case
      CASE lPrev = .f.
         If cSpecialOutput='L'
            Report Form rpt_dataextr To Printer Prompt Noconsole NODIALOG 
         Else
            Create Cursor curDummy (dtStarted T, dtEnded T)
            Insert Into curDummy (dtStarted, dtEnded) Values (dtlStarted, dtlEnded)
            Go Top
            Report Form rpt_dataxcompleted To Printer Prompt Noconsole NODIALOG 
         EndIf

      CASE lPrev = .t.     &&Preview
         If cSpecialOutput='L'
            oApp.rpt_print(5, .t., 1, 'rpt_dataextr', 1, 2)
         Else
            Create Cursor curDummy (dtStarted T, dtEnded T)
            Insert Into curDummy (dtStarted, dtEnded) Values (dtlStarted, dtlEnded)
            Go Top
            oApp.rpt_print(5, .t., 1, 'rpt_dataxcompleted', 1, 2)
           
         EndIf
   EndCase
EndIf

* Zap the tables we just filled (leave this empty for security purposes)
SELECT ursdata
Zap

**SELECT ursprog
**ZAP
*jss, 8/17/07
*!*   SELECT urstopic
*!*   ZAP
SELECT ursserv
ZAP
SELECT ursmeds
ZAP
SELECT urslabs
ZAP
SELECT ursplace
ZAP
SELECT ursrisk
ZAP
SELECT ursevent
ZAP

RETURN


**********************************************************
FUNCTION Rpt_Extr_Str
**********************************************************
*) Description......: Prints Extract Structure
**********************************************************
PRIVATE nSaveArea

nSaveArea = Select()

Select UrsDstr.*, ;
   Str(UrsDstr.Order) as StrOrder, ;
   Date() as cDate, ;
   Time() as cTime  ;
From UrsDstr ;
Into Cursor ;
   DstrCurs ;
Order by UrsDstr.File, StrOrder

*=OpenFile("ursdstr", "order")

Select DstrCurs
Go top

gcRptName = 'rpt_extr_str'
Do Case
CASE lPrev = .f.
   Report Form rpt_extr_str To Printer Prompt Noconsole NODIALOG 
CASE lPrev = .t.     &&Preview
   oApp.rpt_print(5, .t., 1, 'rpt_extr_str', 1, 2)
EndCase

**Select (nSaveArea)

RETURN
*-EOF Extr_Str

******************
PROCEDURE MakeMeds
******************
=OpenFile('arv_ther','code')

* grab all distinct prescription history records
*!*   SELECT DISTINCT;
*!*      ai_clien.tc_id, ;
*!*      pres_his.drug, ;
*!*      SPACE(45) AS drug_name, ;
*!*      pres_his.immune, ;
*!*      pres_his.pres_date, ;
*!*      pres_his.dis_date, ;
*!*      pres_his.admin, ;
*!*      pres_his.dur, ;
*!*      pres_his.freq, ;
*!*      pres_his.take, ;
*!*      pres_his.refill, ;
*!*      pres_his.daw, ;
*!*      pres_his.dispense, ;
*!*      pres_his.ref_source, ;
*!*      pres_his.phys_name as provider, ;
*!*      pres_his.worker_id, ;
*!*      pres_his.arv_ther ;
*!*   FROM ;
*!*      pres_his, ai_clien ;
*!*   WHERE ;
*!*      pres_his.client_id = ai_clien.client_id ;
*!*   AND ;
*!*      ai_clien.tc_id IN (SELECT tc_id FROM temp) ;
*!*   INTO CURSOR ;
*!*      temp1

* jss, 5/11/07, add recent ARV fields to extract
* grab all distinct prescription history records
SELECT DISTINCT;
   ai_clien.tc_id, ;
   pres_his.drug, ;
   SPACE(45) AS drug_name, ;
   pres_his.immune, ;
   pres_his.pres_date, ;
   pres_his.dis_date, ;
   pres_his.admin, ;
   pres_his.dur, ;
   pres_his.freq, ;
   pres_his.take, ;
   pres_his.refill, ;
   pres_his.daw, ;
   pres_his.dispense, ;
   pres_his.ref_source, ;
   pres_his.phys_name as provider, ;
   pres_his.worker_id, ;
   pres_his.arv_ther, ;
   pres_his.arv_start, ;
   pres_his.arv_end, ;
   pres_his.is_arv, ;
   pres_his.date_asked, ;
   pres_his.date_prescr, ;
   pres_his.arv_reason ;
FROM ;
   pres_his, ai_clien ;
WHERE ;
   pres_his.client_id = ai_clien.client_id ;
AND ;
   ai_clien.tc_id IN (SELECT tc_id FROM temp) ;
INTO CURSOR ;
   temp1

Select temp1.*,  ;
		arv_ther.descript as arv_desc ;
From temp1, ;
	arv_ther ;
Where temp1.arv_ther = arv_ther.code ;
Union ;
Select temp1.*,  ;
		Space(25) as arv_desc ;
From temp1 ;
Where Empty(temp1.arv_ther) ;
Into Cursor tempmed1a

Select tempmed1a.* ,;
      arv_reason.descript as arv_reasds ;
From tempmed1a, arv_reason ;
Where tempmed1a.arv_reason = arv_reason.code ;     
Union;
Select tempmed1a.*, ;
   Space(40) as arv_reasds ;   
From tempmed1a ;
Where Empty(tempmed1a.arv_reason) ;
Into Cursor tempmed1   

* inform user if nothing found
IF _tally = 0
*	=MSG2USER('INFORM','No medication history records extracted!')
	RETURN
ENDIF

* now, load in the prescribing physician's name
SELECT ;
	tempmed1.*, ;
	PADR(TRIM(staff.first) + ' ' + TRIM(staff.last),36) AS pres_phys ;
FROM ;
	tempmed1, userprof, staff ;
WHERE ;
	!EMPTY(tempmed1.worker_id) ;
AND ;	
	tempmed1.worker_id = userprof.worker_id ;
AND ;
	userprof.staff_id = staff.staff_id ;
UNION ;
SELECT ;
	tempmed1.*, ;
	SPACE(36) AS pres_phys ;
FROM ;
	tempmed1 ;
WHERE ;
	EMPTY(tempmed1.worker_id) ;
INTO CURSOR ;
	tempmeds ;
ORDER BY ;
	1, 4 		&& tc_id, pres_date		
	
* now, load in the drug names
=OPENFILE('drug_id','drug_id')
=OPENFILE('drug_nam','ndc_code')
SET RELATION TO drug_id INTO drug_id

SELECT ursmeds
ZAP
APPEND FROM (DBF("tempmeds"))
SET RELATION TO drug INTO drug_nam
GO TOP   
REPLACE   ALL drug_name    WITH IIF(EOF('drug_id'), SPACE(60), drug_id.drug_name)
SET RELATION TO
USE IN drug_nam

SELECT ursmeds
Copy To extracts\ursmeds.dbf Type FOX2X
=CursorToXML('ursmeds','extracts\xml\ursmeds.xml',1,512)

USE IN tempmeds

RETURN

******************
PROCEDURE MakeLabs
******************
* grab lab test history records
SELECT ;
	testres.tc_id, ;
	testres.testtype, ;
	SPACE(40)	AS testtypeds, ;
	testres.testcode, ;
	SPACE(40)	AS testcodeds, ;
	testres.result, ;
	SPACE(50)	AS result_ds, ;
	testres.count, ;
	testres.range, ;
	SPACE(40)	AS range_ds, ;
	testres.percent, ;
	testres.testdate, ;
	testres.resdate, ;
	testres.provided, ;
	SPACE(40)	AS providedds ;
FROM ;
	testres ;
WHERE ;
	testres.tc_id IN (SELECT tc_id FROM temp) ;
INTO CURSOR ;
	templabs ;
ORDER BY ;
	1,12	&& tc_id, testdate
	
* inform user if nothing found
IF _tally = 0
*	=MSG2USER('INFORM','No Lab Test History records extracted!')
	RETURN
ENDIF	

* now, load in the descriptions for the test type, specific lab test, test result, test range, and 
=OPENFILE('testtype','code')     	&& relates to (testres.testtype)
=OPENFILE('labtest','ttcode')  	   && relates to (testres.testtype + testres.testcode)
=OPENFILE('tstreslu','namecode') 	&& relates to ('TEST' + testres.testtype + testres.testcode + testres.result)
=OPENFILE('tstrange','testcode') 	&& relates to ('TEST' + testres.testtype + testres.testcode + testres.range)
=OPENFILE('ref_srce','code') 		   && relates to (testres.ref_source)

SELECT urslabs
ZAP
APPEND FROM (DBF("templabs"))
* jss, 7/23/07, move next 2 lines below, AFTER descriptions get filled
*!*   Copy To extracts\urslabs.dbf Type FOX2X
*!*   =CursorToXML('urslabs','extracts\xml\urslabs.xml',1,512)


USE IN templabs

SET RELATION TO testtype 									INTO testtype
SET RELATION TO testtype + testcode 						INTO labtest	ADDITIVE
SET RELATION TO 'TEST'+ testtype + testcode + result		INTO tstreslu	ADDITIVE
SET RELATION TO 'TEST'+ testtype + testcode + '  '  + range INTO tstrange	ADDITIVE
SET RELATION TO provided 									INTO ref_srce	ADDITIVE

GO TOP
REPLACE	ALL testtypeds 	WITH IIF(EOF('testtype'), SPACE(40), testtype.descript) , ;
			testcodeds 	WITH IIF(EOF('labtest'),  SPACE(40), labtest.descript) , ;
			result_ds  	WITH IIF(EOF('tstreslu'), SPACE(50), tstreslu.descript) , ;
			range_ds  	WITH IIF(EOF('tstrange'), SPACE(40), tstrange.descript) , ;
			providedds 	WITH IIF(EOF('ref_srce'), SPACE(30), ref_srce.name) 
	
SET RELATION TO

USE IN  testtype
USE IN  labtest
USE IN  tstreslu
USE IN  tstrange
USE IN  ref_srce

* jss, 7/23/07, moved from above to bring back descriptions
Copy To extracts\urslabs.dbf Type FOX2X
=CursorToXML('urslabs','extracts\xml\urslabs.xml',1,512)

RETURN

******************
PROCEDURE MakePlac
******************
* grab placement history records
SELECT ;
	ai_clien.tc_id, ;
	placehis.place_cat, ;
	SPACE(30)	AS placecatds, ;
	placehis.location, ;
	SPACE(30)	AS locationds, ;
	placehis.start_dt, ;
	placehis.end_dt ;
FROM ;
	placehis, ai_clien ;
WHERE ;
	placehis.client_id = ai_clien.client_id ;
AND ;
	ai_clien.tc_id IN (SELECT tc_id FROM temp) ;
INTO CURSOR ;
	tempplac ;
ORDER BY ;
	1,6	&& tc_id, start_dt
	
* inform user if nothing found
IF _tally = 0
*	=MSG2USER('INFORM','No Placement History records extracted!')
	RETURN
ENDIF	

* now, load in the descriptions for the placement category and location
=OPENFILE('ref_srce','code') 		&& relates to (placehis.location)
=OPENFILE('placecat','code') 		&& relates to (placehis.place_cat)


SELECT ursplace
ZAP
APPEND FROM (DBF("tempplac"))
* jss, 7/23/07, move this below, AFTER descriptions are filled in 
*!*   Copy To extracts\ursplace.dbf Type FOX2X
*!*   =CursorToXML('ursplace','extracts\xml\ursplace.xml',1,512)

USE IN tempplac

SET RELATION TO place_cat INTO placecat
SET RELATION TO location  INTO ref_srce	ADDITIVE

GO TOP
REPLACE	ALL placecatds  WITH IIF(EOF('placecat'), SPACE(30), placecat.descript), ;
			locationds 	WITH IIF(EOF('ref_srce'), SPACE(30), ref_srce.name)
			
SET RELATION TO

USE IN  ref_srce
USE IN  placecat

* jss, 7/23/07, moved from above to bring back descriptions
Copy To extracts\ursplace.dbf Type FOX2X
=CursorToXML('ursplace','extracts\xml\ursplace.xml',1,512)

RETURN

******************
PROCEDURE MakeRisk
******************
* grab risk history records
SELECT ;
	relhist.*, client.sex ;
FROM ;
	relhist, client ;
WHERE ;
	relhist.tc_id IN (SELECT tc_id FROM temp) ;
AND ;
	relhist.client_id = client.client_id ;	
INTO CURSOR ;
	temprisk ;
ORDER BY ;
	2,3	&& tc_id, date
	
* inform user if nothing found
IF _tally = 0
*	=MSG2USER('INFORM','No HIV/AIDS Risk History records extracted!')
	RETURN
ENDIF	

SELECT ursrisk
ZAP
* roll thru the cursor, scattering memvars, appending a blank record to ursrisk for each, then gathering the memvars
SELECT temprisk
SCAN
	SCATTER MEMVAR
* code to determine cdc and rw risk categories
	=RwCDCCat()
	
	SELECT ursrisk
	APPEND BLANK
	GATHER MEMVAR
	SELECT temprisk
EndScan
* jss, 7/31/07, must select URSRISK again: was copying the temprisk cursor instead
Select ursrisk
Copy To extracts\ursrisk.dbf Type FOX2X
=CursorToXML('ursrisk','extracts\xml\ursrisk.xml',1,512)

USE IN temprisk
*USE IN ursrisk
USE IN client

RETURN


* jss, 2/21/06, modify to handle the new version relhist.dbf for URS v4.3b
*****************
FUNCTION RwCDCCat
*****************
* routine checks risks, determines both rw and cdc risk category for display onscreen

m.rwriskcat=''
m.cdcriskcat=''
Show Gets
Store '  ' to m.cDc_cat, m.rW_cat

* if old version (4.3A) use old risk vars and routine, else use new risk vars and routine

IF m.version='4.3A'

* first, let's do the Ryan White risks (for Older Risk Data)
  DO CASE			
	CASE m.sex = 'M' AND (m.hetmale = 1 or m.msm = 1)
		IF m.needleidu = 1 OR m.sharedrug = 1 OR m.shareinjec = 1
			m.rwriskcat = 'MSM and IDU'
			m.rW_cat = '01'
		ELSE
			m.rwriskcat = 'MSM'
			m.rW_cat = '02'
		ENDIF	

	CASE m.needleidu = 1 OR m.sharedrug = 1 OR m.shareinjec = 1
		m.rwriskcat = 'IDU'
		m.rW_cat = '03'
	CASE m.factorviii = 1 OR m.factorix = 1 OR m.otherfact = 1 
		m.rwriskcat = 'Hemophilia/Coagulation Disorder'
		m.rW_cat = '04'
	CASE (m.sex = 'M' AND m.hetfemale = 1) OR (m.sex = 'F' and (m.hetmale = 1 OR m.msm = 1))
		m.rwriskcat = 'Heterosexual Contact'
		m.rW_cat = '05'
	CASE m.rectransfu = 1 OR m.rectranspl = 1
		m.rwriskcat = 'Blood Product Recipient'
		m.rW_cat = '06'
	CASE m.childborn = 1
		m.rwriskcat = 'Perinatal Transmission'
		m.rW_cat = '07'
	CASE m.riskunknow = 1
		m.rwriskcat = 'Undetermined/Unknown'
		m.rW_cat = '08'
	OTHERWISE
		m.rwriskcat = 'Other'
		m.rW_cat = '09'	
  ENDCASE

* now, let's do the CDC risks (for Older Risk Data)
  DO CASE
	CASE m.sex = 'M' AND (m.hetmale = 1 or m.msm = 1)
		IF m.needleidu = 1 OR m.sharedrug = 1 OR m.shareinjec = 1
			m.cdcriskcat = 'MSM and IDU'
			m.cDc_cat = '01'
		ELSE
			m.cdcriskcat = 'MSM'
			m.cDc_cat = '02'
		ENDIF	

	CASE m.needleidu = 1 OR m.sharedrug = 1 OR m.shareinjec = 1
		m.cdcriskcat = 'IDU'
		m.cDc_cat = '03'
	CASE m.motherrisk = 1
		m.cdcriskcat = 'Mother with or at Risk for HIV Infection'
		m.cDc_cat = '05'
	CASE (m.sex='M' AND m.hetfemale = 1) OR (m.sex = 'F' and (m.hetmale = 1 OR m.msm = 1))
		m.cdcriskcat = 'Heterosexual Contact'
		m.cDc_cat = '04'
	OTHERWISE
		m.cdcriskcat = 'General Population'
		m.cDc_cat = '06'
  ENDCASE

Else  && new routine for new PEMS relhist vars

* first, let's do the Ryan White risks (for Newer Risk Data)
	DO CASE			
	CASE m.sex = 'M' AND m.sexmale = 1
		IF m.idunew = 1 
			m.rwriskcat = 'MSM and IDU'
			m.rW_cat = '01'
		ELSE
			m.rwriskcat = 'MSM'
			m.rW_cat = '02'
		ENDIF	
	CASE m.idunew = 1 
		m.rwriskcat = 'IDU'
		m.rW_cat = '03'
	CASE m.hemocoag = 1
		m.rwriskcat = 'Hemophilia/Coagulation Disorder'
		m.rW_cat = '04'	
	CASE (m.sex = 'M' AND m.sexfemale = 1) OR (m.sex = 'F' and m.sexmale = 1)
		m.rwriskcat = 'Heterosexual Contact'
		m.rW_cat = '05'
	CASE m.rectrans = 1 
		m.rwriskcat = 'Blood Product Recipient'
		m.rW_cat = '06'
	CASE m.perinatal = 1
		m.rwriskcat = 'Perinatal Transmission'
		m.rW_cat = '07'
	CASE m.refused = 1 or m.notasked = 1 or m.noriskid = 1
		m.rwriskcat = 'Undetermined/Unknown'
		m.rW_cat = '08'
	OTHERWISE
		m.rwriskcat = 'Other'
		m.rW_cat = '09'	
	ENDCASE

* now, let's do the CDC risks
	DO CASE
	CASE m.sex = 'M' AND m.sexmale = 1
		IF m.idunew = 1 
			m.cdcriskcat = 'MSM and IDU'
			m.cDc_cat = '01'
		ELSE
			m.cdcriskcat = 'MSM'
			m.cDc_cat = '02'
		ENDIF	
	CASE m.idunew = 1
		m.cdcriskcat = 'IDU'
		m.cDc_cat = '03'
	CASE m.perinatal = 1
		m.cdcriskcat = 'Mother with or at Risk for HIV Infection'
		m.cDc_cat = '05'
	CASE (m.sex='M' AND m.sexfemale = 1) OR (m.sex = 'F' and m.sexmale = 1)
		m.cdcriskcat = 'Heterosexual Contact'
		m.cDc_cat = '04'
	OTHERWISE
		m.cdcriskcat = 'General Population'
		m.cDc_cat = '06'
	ENDCASE
ENDIF  

RETURN

******************
PROCEDURE MakeEvnt
******************
* grab ai_outr records and some descriptions
*!*   SELECT ;
*!*      ai_outr.*, ;
*!*      SPACE(40) AS username, ;
*!*      serv_cat.descript AS servcatdes, ;
*!*      program.descript AS prog_descr, ;
*!*      category.descript AS cat_descr, ;
*!*       enc_type.descript as enc_descr, ; 
*!*      SPACE(30) AS cdclocdesc, ;
*!*      SPACE(40) AS speclocdes, ;
*!*      SPACE(40) AS targrpdesc, ;
*!*      SPACE(40) AS spaud1desc, ;
*!*      SPACE(40) AS spaud2desc, ;
*!*      SPACE(40) AS spaud3desc, ;
*!*      SPACE(40) AS cdcrfdesc, ;
*!*      SPACE(25) AS cntyresdes, ;
*!*      SPACE(40) AS refcodedes, ;
*!*      SPACE(40) AS contcodesc, ;
*!*      SPACE(3)  AS popriskdes ;
*!*   FROM ;
*!*      ai_outr, serv_cat, program, category, enc_type ;
*!*   WHERE ;
*!*          ai_outr.act_dt  <= m.as_of_d ;
*!*      AND ai_outr.serv_cat = serv_cat.code ;
*!*      AND ai_outr.program  = program.prog_id ;
*!*      AND ai_outr.category = category.code ;
*!*      AND ai_outr.serv_cat = category.serv_cat ;
*!*      AND ai_outr.enc_type = enc_type.code ;
*!*      AND ai_outr.serv_cat = enc_type.serv_cat ;
*!*   INTO CURSOR ;
*!*      outr_cur readwrite

* jss, 5/3/07, now using enc_list.description for enc_descr
* jss, 7/23/07, add unitdeldes (unit delivery description)
* jss, 8/2/07, modify select below, removing join to category...now fill it via relation below
*!*   SELECT ;
*!*      ai_outr.*, ;
*!*      ai_outr.unit_delivery   as unit_deliv, ;
*!*      ai_outr.inc_provided    as inc_provid, ;
*!*      ai_outr.risk_msmidu     as risk_msmid, ;
*!*      ai_outr.risk_sextrans   as risk_sextr, ;
*!*      ai_outr.risk_heterosex  as risk_heter, ;
*!*      ai_outr.intervention_id as interv_id, ;
*!*      ai_outr.session_number  as session_nu, ;
*!*      SPACE(40)            AS username, ;
*!*      serv_cat.descript    AS servcatdes, ;
*!*      program.descript     AS prog_descr, ;
*!*      category.descript    AS cat_descr, ;
*!*      enc_list.description AS enc_descr, ; 
*!*      SPACE(30) AS cdclocdesc, ;
*!*      SPACE(40) AS speclocdes, ;
*!*      SPACE(40) AS targrpdesc, ;
*!*      SPACE(40) AS spaud1desc, ;
*!*      SPACE(40) AS spaud2desc, ;
*!*      SPACE(40) AS spaud3desc, ;
*!*      SPACE(40) AS cdcrfdesc, ;
*!*      SPACE(25) AS cntyresdes, ;
*!*      SPACE(40) AS refcodedes, ;
*!*      SPACE(40) AS contcodesc, ;
*!*      SPACE(3)  AS popriskdes, ;
*!*      Space(50) AS unitdeldes ;
*!*   FROM ;
*!*      ai_outr ;
*!*     Join serv_cat on ai_outr.serv_cat = serv_cat.code ;
*!*     Join program  on ai_outr.program  = program.prog_id ;
*!*     Join category on ai_outr.category = category.code ;
*!*                  and ai_outr.serv_cat = category.serv_cat ;
*!*     Join enc_list on ai_outr.enc_id = enc_list.enc_id ;
*!*   WHERE ;
*!*          ai_outr.act_dt  <= m.as_of_d ;
*!*   INTO CURSOR ;
*!*      outr_cur readwrite

SELECT ;
   ai_outr.*, ;
   ai_outr.unit_delivery   as unit_deliv, ;
   ai_outr.inc_provided    as inc_provid, ;
   ai_outr.risk_msmidu     as risk_msmid, ;
   ai_outr.risk_sextrans   as risk_sextr, ;
   ai_outr.risk_heterosex  as risk_heter, ;
   ai_outr.intervention_id as interv_id, ;
   ai_outr.session_number  as session_nu, ;
   SPACE(40)               AS username, ;
   serv_cat.descript       AS servcatdes, ;
   program.descript        AS prog_descr, ;
   Space(50)               AS cat_descr, ;
   enc_list.description    AS enc_descr, ; 
   SPACE(30) AS cdclocdesc, ;
   SPACE(40) AS speclocdes, ;
   SPACE(40) AS targrpdesc, ;
   SPACE(40) AS spaud1desc, ;
   SPACE(40) AS spaud2desc, ;
   SPACE(40) AS spaud3desc, ;
   SPACE(40) AS cdcrfdesc, ;
   SPACE(25) AS cntyresdes, ;
   SPACE(40) AS refcodedes, ;
   SPACE(40) AS contcodesc, ;
   SPACE(3)  AS popriskdes, ;
   Space(50) AS unitdeldes ;
FROM ;
   ai_outr ;
  Join serv_cat on ai_outr.serv_cat = serv_cat.code ;
  Join program  on ai_outr.program  = program.prog_id ;
  Join enc_list on ai_outr.enc_id = enc_list.enc_id ;
WHERE ;
       ai_outr.act_dt  <= m.as_of_d ;
INTO CURSOR ;
   outr_cur readwrite

*=ReopenCur("outr_curt","outr_cur")
SELECT outr_cur
REPLACE ALL username WITH USERNAME(user_id)

* load in the other descriptions
=OPENFILE('settings','code')
=OPENFILE('location','code')
=OPENFILE('target','code')
=OPENFILE('sp_tgt','code')
=OPENFILE('cdc_risk','code')
=OPENFILE('county','statecode')
=OPENFILE('ref_srce','code')
=OPENFILE('ref_cntc','code')
* jss, 7/23/07, add unit_del
=OPENFILE('unit_del','code')
* jss, 8/2/07, add category
=OPENFILE('category','progcode') &&serv_cat+code

SELECT outr_cur
SET RELATION TO cdcloctype 		INTO settings
SET RELATION TO spec_loc   		INTO location 	ADDITIVE
SET RELATION TO target_grp 		INTO target   	ADDITIVE
SET RELATION TO spec_aud1  		INTO sp_tgt   	ADDITIVE
SET RELATION TO cdcriskfoc 		INTO cdc_risk 	ADDITIVE
SET RELATION TO st + cnty_resid	INTO county 	ADDITIVE
SET RELATION TO refcode				INTO ref_srce 	ADDITIVE
SET RELATION TO contcode         INTO ref_cntc  ADDITIVE
* jss, 7/23/07, add unit_del
SET RELATION TO unit_delivery    INTO unit_del    ADDITIVE
* jss, 8/2/07, add category
SET RELATION TO serv_cat + category  INTO category   ADDITIVE
GO TOP

* jss, 7/23/07, add unitdeldes
* jss, 8/2/07, add cat_descr
REPLACE ALL ;
				cdclocdesc WITH IIF(EOF('settings'),'',settings.descript), ;
				speclocdes WITH IIF(EOF('location'),'',location.descript), ;
				targrpdesc WITH IIF(EOF('target')  ,'',target.descript)  , ;
				spaud1desc WITH IIF(EOF('sp_tgt')  ,'',LTRIM(sp_tgt.descript))  , ;
				cdcrfdesc  WITH IIF(EOF('cdc_risk'),'',cdc_risk.descript), ;
				cntyresdes WITH IIF(EOF('county')  ,'',county.descript)  , ;
				refcodedes WITH IIF(EOF('ref_srce'),'',ref_srce.name)  , ;
				contcodesc WITH IIF(EOF('ref_cntc'),'',NAME(ref_cntc.last_name, ref_cntc.first_name))  , ;
            unitdeldes WITH IIF(EOF('unit_del'),'',unit_del.descript)  , ;            
            cat_descr  WITH IIF(EOF('category'),'',category.descript)  , ;            
				popriskdes WITH IIF(poprisk=1, 'NO', IIF(poprisk=2,'YES',''))
				
SET RELATION TO spec_aud2  		INTO sp_tgt 
REPLACE ALL spaud2desc WITH IIF(EOF('sp_tgt')  ,'',LTRIM(sp_tgt.descript)) 
SET RELATION TO spec_aud3  		INTO sp_tgt 
REPLACE ALL spaud3desc WITH IIF(EOF('sp_tgt')  ,'',LTRIM(sp_tgt.descript)) 
SET RELATION TO 

SELECT ursevent
ZAP
APPEND FROM DBF("outr_cur")
Copy To extracts\ursevent.dbf Type FOX2X
=CursorToXML('ursevent','extracts\xml\ursevent.xml',1,512)

IF USED('outr_cur')
	USE IN outr_cur
ENDIF

*IF USED('ursevent')
*	USE IN ursevent
*ENDIF

IF USED('settings')
	USE IN settings
ENDIF

IF USED('location')
	USE IN location
ENDIF

IF USED('target')
	USE IN target
ENDIF

IF USED('sp_tgt')
	USE IN sp_tgt
ENDIF

IF USED('cdc_risk')
	USE IN cdc_risk
ENDIF

IF USED('county')
	USE IN county
ENDIF

IF USED('ref_srce')
   USE IN ref_srce
ENDIF

IF USED('ref_cntc')
   USE IN ref_cntc
ENDIF

IF USED('unit_del')
   USE IN unit_del
ENDIF

IF USED('category')
   USE IN category
ENDIF


RETURN

*****************
FUNCTION UserName
*****************
* jss, 6/15/04, get user id's name
PARAMETER xUserId

IF SEEK(xUserId, 'userprof')
	RETURN IIF(!EOF('staff'),PADR(NAME(staff.last,staff.first,staff.mi),40),SPACE(40))
ELSE
	RETURN SPACE(40)		
ENDIF

* jss, 7/31/07, this code to create the Cli_Stat cursor now in BeforeOpenTables method in Rpt_form data environment
*!*   **********************************************************
*!*   FUNCTION MkCli_Stat
*!*   **********************************************************
*!*   *  Function.........: MkCli_Stat
*!*   *) Description......: Create the cursor with client status types
*!*   **********************************************************

*!*   CREATE CURSOR cli_stat (code C(1), descript C(20))
*!*   INSERT INTO cli_stat VALUES ("A", "Active Only")
*!*   INSERT INTO cli_stat VALUES ("C", "Closed Only")
*!*   INDEX ON code TAG code
*!*   INDEX ON descript TAG descript ADDITIVE

*!*   RETURN
