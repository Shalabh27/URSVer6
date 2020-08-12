Parameters;
   lPrev,;     && Preview     
   aSelvar1,;  && select parameters from selection list
   nOrder,;    && order by number
   nGroup,;    && report selection number   
   lcTitle1,;  && report selection description   
   Date_from,; && from date
   Date_to,;   && to date   
   Crit,;      && name of param
   lnStat,;    && selection(Output)  page 2
   cOrderBy    && order by description
              
Acopy(aSelvar1, aSelvar2)

* set Data Engine Compatibility to handle Foxpro version 7.0 or earlier (lets old SQL work)
mDataEngine=Sys(3099,70)
lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)

ccSite=''
cstattype=''
lcprog=''

**VT 09/15/2008 Dev Tick 4600
m.Crit = Crit
m.lcTitle1 = lcTitle1

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif
    
   If Rtrim(aSelvar2(i, 1)) = "CSTATTYPE"
      cStatType = aSelvar2(i, 2)
   Endif
    
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
   
EndFor

cDate = DATE()
cTime = TIME()
Set delete on
Set safe off
gctc='00002'

Private gchelp
gchelp = "AIRS Data Extract Screen"

Select Min(act_dt) From ai_enc Into Array aMinDate
If _Tally=0
   Dimension aMinDate(1)
   aMinDate[1]={01/01/1980}
EndIf

* m.as_of_d = Date()
m.as_of_d= Date_from
dlStartDt=GoMonth(m.as_of_d,-12)
dlEndingDt=date_from

If lnStat<>(2)
   Do Form enter_start_end_dt With 'Enter the Start and End Dates to limit the selection of encounters and services (default 1yr).' Name oST_END_Form NoShow
   oST_END_Form.enter_date.dmindate=aMinDate[1]
   oST_END_Form.enter_date.ddate_value.Value=dlStartDt
   oST_END_Form.enter_date.ddate_value.ControlSource='dlStartDt'
   oST_END_Form.enter_date1.ddate_value.Value=dlEndingDt
   oST_END_Form.enter_date1.ddate_value.ControlSource='dlEndingDt'
   oST_END_Form.Show()

   Release aMinDate
EndIf 

If Empty(dlStartDt)
   oApp.msg2user('MESSAGE','Data Extract processing canceled.')
   Return
   
EndIf

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

Private m.cdcriskcat
Private m.rwriskcat
Private m.sex
Store '' To m.cdcriskcat, m.rwriskcat, m.sex

If Directory('extracts\xml\')=(.f.)
   MkDir 'extracts\xml\'
EndIf 

cTitle = "URS Data Extracts"

oApp.Msg2User("WAITRUN", "Preparing Extract.", "")

cReportSelection = .aGroup[nGroup]

* open extract data files exclusively
If !OpenExcl("ursdata")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

If !OpenExcl("ursprog")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

If !OpenExcl("ursserv")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

If !OpenExcl("ursevent")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

*!*   If !OpenExcl("ursmeds")
*!*   	oApp.Msg2User("OFF")
*!*   	Return .t.
*!*   EndIf 

If !OpenExcl("urslabs")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

If !OpenExcl("ursplace")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

If !OpenExcl("ursrisk")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

**VT 08/09/2011 AIRS-91
If !OpenExcl("urshousehold")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

**VT 11/02/2011 AIRS-181
If !OpenExcl("urshousing")
	oApp.Msg2User("OFF")
	Return .t.
EndIf 

Do Case
	Case nGroup = 1 && All Clients
		lcExpr = ".t."
      
	Case nGroup = 2 && Ryan White Eligible
		lcExpr = "Aar_Report"
      
	Case nGroup = 3 && HIV Counseling/Prevention Eligible
		lcExpr = "ctp_elig"
      
	Case nGroup = 4 && Ryan White and HIV Counseling/Prevention Eligible
		lcExpr = "(Aar_Report OR Ctp_Elig)"
      
EndCase 

* jss, 5/6/03, add case status effective date (casestatdt)
* jss, 10/20/06, add field hudchronic
Select ;
	Client.*, ;
   client.sex_at_birth As sexbrth_cd,;
   Space(30) As sexbrth_ds,;
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
	Ai_clien.inaddhouse, ;
	Ai_clien.HIV_EXP1, ;
	Ai_clien.HIV_EXP2, ;
	Ai_clien.HOUSING, ;
	Ai_clien.REF_SRC2, ;
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
	Iif(statvalu.incare, "A", "C") as stattype, ;
	ai_activ.close_code, ;
	statvalu.incare AS ACTIVE, ;
	statvalu.descript AS casestat, ;
	ai_activ.effect_dt AS casestatdt, ;
	Iif(client.hispanic = 1, "Non-Hispanic",Iif(client.hispanic = 2, "Hispanic    ", Space(12))) as hisp_ds, ;
	Space(35) AS hispdetds, ;
	Space(35) AS whitedetds, ;
	Space(35) AS blackdetds, ;
	Space(35) AS asiandetds, ;
   Space(35) AS hawiidetds, ;
   client.hawaislanddet As hawiidet,;
	Ai_clien.hudchronic, ;
   ICase(client.sexual_orientation=1 Or client.sexual_orientation=0,'                         ',;
         client.sexual_orientation=2,'Gay                      ',;
         client.sexual_orientation=3,'Lesbian                  ',;
         client.sexual_orientation=4,'Straight or heterosexual ',;
         client.sexual_orientation=5,'Bisexual                 ',;
         client.sexual_orientation=6,'Something else           ',;
         client.sexual_orientation=7,'Dont Know                ',;
         client.sexual_orientation=8,'Chose not to respond     ',;
         Space(25)) As SEX_ORIENT;
From ;
	client, ai_clien, ai_activ, statvalu, userprof, staff ;
Where ;
	client.client_id 	= ai_clien.client_id ;
	AND ai_clien.tc_id = ai_activ.tc_id ;
	AND (Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.time, ai_activ.am_pm)) IN ;
								(Select Max(Dtos(effect_dt)+oApp.Time24(aa.time, aa.am_pm)) ;
									From ai_activ aa ;
									Where ;
										aa.tc_id = ai_activ.tc_id ;
										And aa.effect_dt <= m.as_of_d ) ;
	AND statvalu.tc + statvalu.type + statvalu.code = gcTC + 'ACTIV' + ai_activ.status and ;
	ai_clien.int_worker = userprof.worker_id and ;
	userprof.staff_id = staff.staff_id ;
Having ;
	stattype = cStatType;
INTO CURSOR ;
	temp READWRITE 

***************************************************************
*** PB 08/2010 Re: Ticket #7311
*** Because of the nature of the encrypted last & Frist name fields
*** Decript them now before they are append into a free standing table.
***************************************************************

If oapp.gldataencrypted
   Select temp
   Go Top
   Scan 
      If !Empty(last_name) And !IsNull(last_name)
         lcDecryptedStream=''
         lcEncryptedStream=last_name
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace last_name With lcDecryptedStream
      EndIf
      
      If !Empty(first_name) And !IsNull(first_name)
         lcDecryptedStream=''
         lcEncryptedStream=first_name
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace first_name With lcDecryptedStream
      EndIf
   EndScan 
Endif
**************************************************************

If cStatType = "A"
	cPrgEndXpr = "AND (EMPTY(ai_prog.end_dt) OR ai_prog.end_dt > m.as_of_d) "
Else 
	cPrgEndXpr = ""
EndIf 

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
							(SELECT ;
									MAX(tc_id + program + DTOS(start_dt) ) ;
								FROM ;
									ai_prog aip ;
								WHERE ;
									aip.start_dt <= m.as_of_d ;
								GROUP BY ;
									aip.tc_id, aip.program) ;
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
		Space(50) AS reas_desc, ;
       ai_prog.ref_srce As ref_srce,;
       Nvl(ref_srce.name, Space(40)) As ref_srce_desc,;
       ai_prog.nrefnote As ref_type,;
       ICase(ai_prog.nrefnote=(1),'In House',ai_prog.nrefnote=(2),'External ',Space(08)) As ref_type_desc;
FROM temp2a, ai_prog ;
Left Outer Join ref_srce On ai_prog.ref_srce=ref_srce.code;
WHERE temp2a.tc_id = ai_prog.tc_id ;
  AND temp2a.program = ai_prog.program ;
  AND temp2a.prog_date = ai_prog.start_dt ;
  AND temp2a.prog_end = ai_prog.end_dt  ;
UNION ;
SELECT temp2a.*, ;
		Space(2) AS reason, ;
		Space(50) AS reas_desc, ;
       ai_prog.ref_srce As ref_srce,;
       Nvl(ref_srce.name, Space(40)) As ref_srce_desc,;
       ai_prog.nrefnote As ref_type,;
       ICase(ai_prog.nrefnote=(1),'In House',ai_prog.nrefnote=(2),'External ',Space(08)) As ref_type_desc;
FROM temp2a ;
Left Outer Join ref_srce On ai_prog.ref_srce=ref_srce.code;
WHERE tc_id + program + DTOS(prog_date) + DTOS(prog_end)	NOT IN ;
	(SELECT p2.tc_id + p2.program + DTOS(p2.start_dt) + DTOS(p2.end_dt) FROM ai_prog	p2) ;
INTO CURSOR ;
	temp2 readwrite	

* jss, 1/19/04, must make cursor writable to add reason description
=OpenFile("closcode","code")
SELECT temp2
SET RELATION TO reason INTO closcode
GO TOP
REPLACE ALL reas_desc WITH closcode.descript FOR NOT EOF('closcode')

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
      Space(5) as site, ;
      {} as site_date, ;
      "Site Unknown" as site_ds ;
   FROM ;
      temp ;
   WHERE ;
      temp.tc_id NOT IN (SELECT tc_id FROM ai_site) ;
      AND temp.tc_id IN (select tc_id from temp2) ;
   INTO CURSOR ;
      temp3 readwrite;
   Order By client_id
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
      temp3 readwrite;
   Order by client_id
EndIf 

=OpenFile("racedet","code")

SELECT temp3
SET RELATION TO hispdet INTO racedet

GO TOP
REPLACE ALL hispdetds WITH IIF(EOF('racedet'), Space(35), racedet.descript)
SET RELATION TO

SET RELATION TO whitedet INTO racedet
GO TOP
REPLACE ALL whitedetds WITH IIF(EOF('racedet'), Space(35), racedet.descript)
SET RELATION TO

SET RELATION TO blackdet INTO racedet
GO TOP
REPLACE ALL blackdetds WITH IIF(EOF('racedet'), Space(35), racedet.descript)
SET RELATION TO

SET RELATION TO asiandet INTO racedet
GO TOP
REPLACE ALL asiandetds WITH IIF(EOF('racedet'), Space(35), racedet.descript)
SET RELATION TO

SET RELATION TO hawaislanddet INTO racedet
GO TOP
REPLACE ALL hawiidetds WITH IIF(EOF('racedet'), Space(35), racedet.descript)
SET RELATION TO

SELECT ursdata
ZAP

APPEND FROM (DBF("temp3"))

SELECT ursprog
ZAP

APPEND FROM (DBF("temp2"))

USE IN temp2
USE IN temp2a
USE IN temp3

=OpenFile("ZIPCODE","ZIPCOUNTY")
=OpenFile("COUNTY", "STATECODE")
=OpenFile("EXPOSURE", "CODE", "EXPOSURE1")
=OpenFile("EXPOSURE", "CODE", "EXPOSURE2")
=OpenFile("HOUSING", "CODE")
=OpenFile("REF_IN", "CODE")
=OpenFile("REF_SRCE", "CODE")
=OpenFile("REF_CNTC", "CODE")
=OpenFile("TBDESC", "CODE")
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

Select ;
  address.client_id,;
  address.addr_id,;
  address.county,;
  address.fips_code,;
  Padr(county.descript,50) As county_ds;
From address ;
Join county On address.county = county.code;
 And address.st=county.state;
Where !Empty(address.county) And Empty(address.fips_code);
Union;
Select ;
  address.client_id,;
  address.addr_id,;
  address.county,;
  address.fips_code,;
  Padr(zipcode.countyname,50) As county_ds;
From address;
Join zipcode on address.fips_code=zipcode.countyfips;
Where !Empty(zipcode.countyfips);
Order By client_id Into Cursor curZIPS ReadWrite

Select curZIPS
Index On client_id Tag client_id

*!*   =OpenFile("AAR_TAB", "AAR_INFO", "AAR_TAB1")
*!*   SET FILTER TO !EMPTY(AAR_INFO)

*!*   =OpenFile("AAR_TAB", "AAR_INFO", "AAR_TAB2")
*!*   SET FILTER TO !EMPTY(AAR_INFO)

GO TOP

* get all workers
Select staffcur
SET ORDER TO worker_id

* worker assignments
=OpenFile('ai_work', 'tc_id2 desc')
SET RELATION TO worker_id INTO staffcur
SET FILTER TO effect_dt <= m.as_of_d
GO TOP

* HIV statuses
=OpenFile('hivstat', 'tc_id')
*!*   SET RELATION TO hivstatus INTO hstat
*!*   SET FILTER TO effect_dt <= m.as_of_d
*!*   GO TOP
* 1. Get the most recent record for the client based on effect_dt
Select ;
   Space(10) As OrigRowID,;
   tc_id, ;
   effect_dt, ;
   Count(effect_dt) as Row_Count, ;
   0 As row2use;
From hivstat ;
Where hivstat.effect_dt <= m.as_of_d;
Group By tc_id, effect_dt ;
Order By 1, 2 Desc;
Into Cursor _x1 ReadWrite

Select _x1
Go Top
mltc_id='x'

Scan 
   If tc_id <> mltc_id
      mltc_id=tc_id
      Replace row2use with 1
      If row_count=(1)
         If Seek(mltc_id,'hivstat','tc_id4')
            Replace OrigRowId with hivstat.status_id
         EndIf
      EndIf 
   Endif
EndScan 
Set Filter To row2use = (1)
Go Top

Scan For Empty(OrigRowId)
   If Empty(OrigRowId)
      mltc_id=tc_id
      Select Top 1 ;
         status_id, ;
         GetMaxDate({01/01/1900},entered_dttm,last_updated_dttm,effect_dt) As maxdate;
       From hivstat;
       Where tc_id=mltc_id;
          And hivstat.effect_dt <= m.as_of_d;
       Order by 2 Desc;
       Into Array _aStatusId

       Replace OrigRowId With _aStatusId
   EndIf 
EndScan 

Select ;
   hivstat.tc_id, ;
   hivstat.status_id, ;
   hivstat.effect_dt, ;
   hivstat.hivstatus, ;
   hstat.hiv_pos,;
   hstat.descript;
From hivstat;
Join _x1 On _x1.origrowid=hivstat.status_id;
Join hstat On hstat.code=hivstat.hivstatus;
Order by 1;
Into Cursor _xxx ReadWrite

Use in _x1

Select _xxx
Index on tc_id tag tc_id addit
Go Top

* Substance Use
=OpenFile('ai_subs', 'tc_id')
SET FILTER TO infodate <= m.as_of_d
GO TOP

*!* AIRS-760 - Add insurance plan info to insurance 

m.as_of_d=Date()
Select ;
   insstat.client_id, ;
   insstat.prov_id as pprov_id, ;
   insstat.effect_dt as pstart_dt, ;
   insstat.exp_dt as pexp_dt, ;
   insstat.pol_num as ppol_num, ;
   insstat.insured as pinsure, ;
   insstat.plan_id as pplan_id,;
   Nvl(insurance_plans.description,Space(50)) as pplan_desc,;
   med_prov.name as pprov_name, ;
   med_prov.instype as ptype, ;
   instype.descript as ptype_ds, ;
   insstat.ma_pending as pma_pendin, ;
   insstat.nys_marketplace as pnys_market ;
From ;
   insstat ;
   Join med_prov On insstat.prov_id = med_prov.prov_id;
   Join instype On instype.code = med_prov.instype;
   Left Outer Join insurance_plans On insurance_plans.plan_id=insstat.plan_id;
Where ;
   insstat.prim_sec = 1 And ;
   insstat.effect_dt <= m.as_of_d And ;
   insstat.client_id + Dtos(insstat.effect_dt) In (SELECT is2.client_id+ Dtos(MAX(is2.effect_dt)) ;
                                                   From insstat is2 ;
                                                   Where is2.prim_sec = 1 And;
                                                         is2.effect_dt <= m.as_of_d ;
                                                   Group By is2.client_id);
Order By 1 Into Cursor prim_ins readwrite
Index On client_id TAG client_id

*!*   Select ;
*!*      insstat.client_id, ;
*!*      insstat.prov_id as sprov_id, ;
*!*      insstat.effect_dt as sstart_dt, ;
*!*      insstat.exp_dt as sexp_dt, ;
*!*      insstat.pol_num as spol_num, ;
*!*      insstat.insured as sinsure, ;
*!*      insstat.plan_id as splan_id,;
*!*      Nvl(insurance_plans.description,Space(50)) as splan_desc,;
*!*      med_prov.name as sprov_name, ;
*!*      med_prov.instype as stype, ;
*!*      instype.descript as stype_ds, ;
*!*      insstat.ma_pending as sma_pendin, ;
*!*      insstat.nys_marketplace as snys_market ;
*!*   From ;
*!*      insstat ;
*!*      Join med_prov On insstat.prov_id = med_prov.prov_id;
*!*      Join instype On instype.code = med_prov.instype;
*!*      Left Outer Join insurance_plans On insurance_plans.plan_id=insstat.plan_id;
*!*   Where ;
*!*      insstat.prim_sec = 2 And ;
*!*      insstat.effect_dt <= m.as_of_d And ;
*!*      insstat.client_id + Dtos(insstat.effect_dt) In (SELECT is2.client_id+ Dtos(MAX(is2.effect_dt)) ;
*!*                                                      From insstat is2 ;
*!*                                                      Where is2.prim_sec = 2 And;
*!*                                                            is2.effect_dt <= m.as_of_d ;
*!*                                                      Group By is2.client_id);
*!*   Order By 1 Into Cursor sec_ins ReadWrite

*!*   Select ;
*!*      insstat.client_id, ;
*!*      insstat.prov_id as sprov_id, ;
*!*      insstat.effect_dt as sstart_dt, ;
*!*      insstat.exp_dt as sexp_dt, ;
*!*      insstat.pol_num as spol_num, ;
*!*      insstat.insured as sinsure, ;
*!*      insstat.plan_id as splan_id,;
*!*      Nvl(insurance_plans.description,Space(50)) as splan_desc,;
*!*      med_prov.name as sprov_name, ;
*!*      med_prov.instype as stype, ;
*!*      instype.descript as stype_ds, ;
*!*      insstat.ma_pending as sma_pendin, ;
*!*      insstat.nys_marketplace as snys_market ;
*!*   From ;
*!*      insstat ;
*!*      Join med_prov On insstat.prov_id = med_prov.prov_id;
*!*      Join instype On instype.code = med_prov.instype;
*!*      Left Outer Join insurance_plans On insurance_plans.plan_id=insstat.plan_id;
*!*   Where ;
*!*      insstat.prim_sec=(9) And ;
*!*      insstat.effect_dt <= m.as_of_d;
*!*   Order By insstat.effect_dt Into Cursor sec_ins ReadWrite
*!*   Index On client_id Tag client_id


Select insstat.insstat_id, ;
      insstat.effect_dt, ;
      insstat.client_id ;
From insstat ;
where insstat.prim_sec=(9) And ;
      insstat.effect_dt <= m.as_of_d;
Order by insstat.client_id, insstat.effect_dt desc, insstat.exp_dt;
Into cursor _curList1 readwrite
Go Top

mClientHold=''
Scan
   If mClientHold <> _curList1.client_id
      mClientHold=_curList1.client_id
   Else
      Delete
   EndIf
   
EndScan
Go Top
Release mClientHold

Select ;
   status.tc_id,;
   insstat.client_id, ;
   insstat.prov_id as sprov_id, ;
   insstat.effect_dt as sstart_dt, ;
   insstat.exp_dt as sexp_dt, ;
   insstat.pol_num as spol_num, ;
   insstat.insured as sinsure, ;
   insstat.plan_id as splan_id,;
   Nvl(insurance_plans.description,Space(50)) as splan_desc,;
   med_prov.name as sprov_name, ;
   med_prov.instype as stype, ;
   instype.descript as stype_ds, ;
   insstat.ma_pending as sma_pendin, ;
   insstat.nys_marketplace as snys_market ;
From insstat ;
   Join _curList1 On _curList1.insstat_id = insstat.insstat_id;
   Join med_prov On insstat.prov_id = med_prov.prov_id;
   Join instype On instype.code = med_prov.instype;
   Left Outer Join insurance_plans On insurance_plans.plan_id=insstat.plan_id;
Order By insstat.effect_dt Desc;
Into Cursor sec_ins ReadWrite
Index On client_id Tag client_id

Use In _curList1

Select ursdata
Set Relation To client_id Into address
Set Relation To tc_id Into _xxx Additive
* Set Relation To tc_id Into hivstat ADDITIVE
Set Relation To tc_id Into ai_subs ADDITIVE
Set Relation To gender Into gender ADDITIVE
Set Relation To prim_lang Into language1 ADDITIVE
Set Relation To sec_lang Into language2 ADDITIVE
Set Relation To read_lang1 Into language3 ADDITIVE
Set Relation To read_lang2 Into language4 ADDITIVE
Set Relation To marital Into marital ADDITIVE
Set Relation To relig Into relig ADDITIVE
Set Relation To housing Into housing ADDITIVE
Set Relation To ref_src2 Into ref_in ADDITIVE
Set Relation To close_code Into closcode ADDITIVE
Set Relation To client_id Into prim_ins ADDITIVE
Set Relation To client_id Into sec_ins ADDITIVE
Set Relation To ref_source Into ref_srce ADDITIVE
Set Relation To ref_cntc Into ref_cntc ADDITIVE

Update ursdata From gender Set sexbrth_ds=gender.descript Where !Empty(ursdata.sexbrth_cd) And ursdata.sexbrth_cd=gender.code
Set exact off
Go Top 

REPLACE ALL ;
   gender_ds  WITH gender.descript, ;
   pr_lang_ds WITH language1.descript, ;
   sec_l_ds   WITH language2.descript, ;
   read_l1_ds WITH language3.descript, ;
   read_l2_ds WITH language4.descript, ;
   marit_ds   WITH marital.descript, ;
   relig_ds   WITH relig.descript, ;
   housing_ds WITH housing.descript, ;
   ref_s2_ds  WITH ref_in.descript, ;
   hivstatus  WITH _xxx.hivstatus, ;
   hivstat_dt WITH _xxx.effect_dt, ;
   hiv_pos    WITH _xxx.hiv_pos, ;
   hivstat_ds WITH _xxx.descript, ;
   closcod_ds WITH closcode.descript, ;
   pprov_id   WITH prim_ins.pprov_id, ;
   pstart_dt  WITH prim_ins.pstart_dt, ;
   pexp_dt    WITH prim_ins.pexp_dt, ;
   ppol_num   WITH prim_ins.ppol_num, ;
   pinsure    WITH prim_ins.pinsure, ;
   pprov_name WITH prim_ins.pprov_name, ;
   pplan_id   WITH prim_ins.pplan_id,;
   pplan_desc WITH prim_ins.pplan_desc,;
   pma_pendin With prim_ins.pma_pendin, ;
   ptype      WITH prim_ins.ptype, ;
   ptype_ds   WITH prim_ins.ptype_ds, ;
   pnys_marke With prim_ins.pnys_market, ;
   sprov_id   WITH sec_ins.sprov_id, ;
   sstart_dt  WITH sec_ins.sstart_dt, ;
   sexp_dt    WITH sec_ins.sexp_dt, ;
   spol_num   WITH sec_ins.spol_num, ;
   sinsure    WITH sec_ins.sinsure, ;
   sprov_name WITH sec_ins.sprov_name, ;
   splan_id   WITH sec_ins.splan_id,;
   splan_desc WITH sec_ins.splan_desc,;
   sma_pendin With sec_ins.sma_pendin, ;
   stype      WITH sec_ins.stype, ;
   stype_ds   WITH sec_ins.stype_ds, ;
   snys_marke With sec_ins.snys_market, ;
   ref_src_ds WITH ref_srce.name, ;
   ref_cnt_ds WITH PADR(TRIM(ref_cntc.first_name) + ' ' + TRIM(ref_cntc.last_name),36), ;
   insurdesc  WITH IIF(insurance=1, 'Known/Specify', IIF(insurance=2, 'Unknown/Unreported', IIF(insurance=3,'No Insurance',Space(18)))), ;
   age with   Iif(Empty(dob)=(.t.), age, (Year(Date())-Year(dob))-Iif(Date(Year(Date()),Month(dob),Day(dob))>Date(),1,0))
   
=OpenFile('udf_lut','namecode')
=OpenFile('udf_intake')
Select udf_intake

Dimension aUDFLables(1,2)
Store '' To aUDFLables
naUDFLablesLen=0
ix1=0

Copy Fields udf_category, udf_label, udf_category ,udf_category, is_lookup To Array aUDFLabels For is_inuse=(.t.)

If _Tally > 0
   naUDFLablesLen=Alen(aUDFLabels,1)
   For ix1 = 1 To naUDFLablesLen
      If aUDFLabels[ix1,5]=(.t.)
         aUDFLabels[ix1,4]=aUDFLabels[ix1,4]+'_DS'
      EndIf
      aUDFLabels[ix1,3]=aUDFLabels[ix1,3]+'_CP'
      
   EndFor
   ix1=0
EndIf

**VT 11/16/2011 AIRS-184
If !Used("vn_header")	
	=openFile("vn_header")
EndIf

Select vn_header
cOldTag=Tag()
Set Order To vn_max
Go Top 
Select ursdata
Scan
   **Household Income
   If Seek(Alltrim(ursdata.tc_id)+'G','vn_header','vn_max')
	    Replace dt_verif_i With Ttod(vn_header.last_vn_date)
   EndIf
   
   **Housing
   If Seek(Alltrim(ursdata.tc_id)+'K','vn_header','vn_max')
	    Replace dt_verif_h With Ttod(vn_header.last_vn_date)
   EndIf

   **HIV Status
   If Seek(Alltrim(ursdata.tc_id)+'B','vn_header','vn_max')
	    Replace dt_verif_s With Ttod(vn_header.last_vn_date)
   EndIf
   **VT End
   
   If Seek(ursdata.client_id,'address','client_id')
      If oapp.gldataencrypted=(.t.)
         If !Empty(address.street1) And !IsNull(address.street1)
            lcDecryptedStream=''
            lcEncryptedStream=Alltrim(address.street1)
            lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

            Replace street With lcDecryptedStream
         EndIf 
      Else
         Replace street With address.street1
      EndIf

      Replace;
        street2 With address.street2,;
        city With address.city, ;
        st With address.st, ;
        zip With address.zip, ;
        county With address.county, ;
        fipscounty With address.fips_code ;

   Endif
   
   If Seek(ursdata.client_id,'curZIPS')
      Replace ursdata.county_ds With curZIPS.county_ds
   EndIf
   
   dCDCDate = {}
   If CDC_AIDS(ursdata.tc_id, dCDCDate)
      Replace ursdata.cdc_aids WITH .t., cdcaids_dt WITH dCDCDate
   EndIf
   
   For ix1=1 To naUDFLablesLen
      If Fsize(aUDFLabels[ix1,1]) > 0 And !Empty(Evaluate(aUDFLabels[ix1,1]))
         Replace (aUDFLabels[ix1,3]) With aUDFLabels[ix1,2]
         If aUDFLabels[ix1,5]=(.t.)
            If Seek(Padr(aUDFLabels[ix1,1],10)+Evaluate(aUDFLabels[ix1,1]),'udf_lut')
               Replace (aUDFLabels[ix1,4]) With udf_lut.descript
            EndIf
         EndIf
      EndIf
   EndFor
   
   If oapp.gldataencrypted
      If !Empty(ssn) And !IsNull(ssn)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(ssn)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)
         Replace ssn With lcDecryptedStream

      EndIf

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
   EndIf
   
EndScan
Set Relation To
Use In curZIPS

**VT 11/16/2011 AIRS-184
Select vn_header
Set Order To (cOldTag)

Select ursdata

Copy To extracts\ursdata.dbf Type FOX2X
=CursorToXML('ursdata','extracts\xml\ursdata.xml',1,512)

REINDEX

***********************************************************************
** Get the combination of all URS services and encounters
***********************************************************************

* jss, 5/2/07, use enc_id instead of enc_type   
Select ;
   ai_enc.tc_id,ai_enc.act_id, ;
   ai_enc.serv_cat,;
   serv_cat.descript AS servcatdes,;
   ai_enc.enc_id,;
   ai_enc.category As categorycd,;   && PB:#7377
   Space(50) As categoryds,;   && PB:#7377
   ai_enc.program,;
   ai_enc.site, ;
   ai_enc.act_dt,;
   ai_enc.act_loc,;
   Space(30) AS enclocdesc,;
   ai_enc.beg_am,;
   ai_enc.beg_tm, ;
   ai_enc.end_am,;
   ai_enc.end_tm,;
   ai_enc.date_compl, ;
   ai_enc.enc_with,Space(40) as enc_withds,;
   ai_enc.ref_cont_w,;
   Space(40) as invlvagdes,;
   ai_enc.ref_cont_2, ;
   Space(40) as invlvag2ds,;
   ai_enc.worker_id, ;
   ai_enc.team,;
   ai_enc.diagnos1,;
   ai_enc.diagnos2, ;
   program.descript as prog_descr, ;
   program.Aar_Report, program.Ctp_Elig, ;
   site.descript1 as site_descr, ;
   ai_enc.conno, ;            && VT 11/03/2009 dev Tick 6326
   ai_enc.model_id, ;         && VT 11/03/2009 dev Tick 6326
   ai_enc.intervention_id, ;  && VT 11/03/2009 dev Tick 6326
   ai_enc.session_number, ;   && VT 11/03/2009 dev Tick 6326
   ai_enc.inc_provided, ;     && VT 11/03/2009 dev Tick 6326
   ai_enc.unit_delivery, ;    && VT 11/03/2009 dev Tick 6326
   ai_enc.mcondoms,;          && PB 03/2013 AIRS-628
   ai_enc.fcondoms,;          && PB 03/2013 AIRS-628
   ai_enc.user_id,;
   ai_enc.dt;
FROM ;
   ai_enc,program,site,ursdata,serv_cat ;
WHERE ;
   ai_enc.tc_id=ursdata.tc_id;
   AND Between(ai_enc.act_dt,dlStartDt,dlEndingDt) ;
   AND ai_enc.site=site.site_id ;
   AND ai_enc.program=program.prog_id ;
   AND &lcExpr ; 
   AND ai_enc.serv_cat=serv_cat.code ;
INTO CURSOR enc_curt1
*   AND ai_enc.act_dt<=m.as_of_d ;


* jss, 5/2/07, grab cadr_map, mai_map and description from the new AIRS encounter tables
SELECT ;
   enc_curt1.*, ;
   enc_list.description AS enc_descr,;
   enc_sc_link.cadr_map AS enc_cadr,;
   enc_sc_link.mai_map  AS enc_mai, ;
   0000 AS duration ;
FROM enc_curt1 ;
   Join enc_list on enc_curt1.enc_id   = enc_list.enc_id ;
   Join enc_sc_link on enc_curt1.enc_id   = enc_sc_link.enc_id ;
                   and enc_curt1.serv_cat = enc_sc_link.serv_cat ;
INTO CURSOR ;
   enc_cur readwrite

USE IN enc_curt1
*=ReOpenCur("enc_curt", "enc_cur")

* now, let's fill in descriptions
=OpenFile("enc_with", "progcode") && serv_cat + code
=OpenFile("serv_loc", "progcode") && serv_cat + code
=OpenFile("ref_srce", "code") && code
=OpenFile("category","progcode")

Select enc_cur
SET RELATION TO serv_cat+enc_with INTO enc_with 
SET RELATION TO serv_cat+act_loc INTO serv_loc 	ADDITIVE 
SET RELATION TO ref_cont_w INTO ref_srce 	ADDITIVE 
Set Relation To serv_cat+categorycd Into category Additive

GO TOP

REPLACE ALL enc_withds WITH enc_with.descript, ;
				enclocdesc WITH serv_loc.descript, ; 
				invlvagdes WITH ref_srce.name,;
            categoryds With category.descript
Set Relation To 

SET RELATION TO ref_cont_2 into ref_srce	
GO TOP
REPLACE ALL invlvag2ds WITH ref_srce.name

Use In enc_with
Use In serv_loc
Use In ref_srce

Select ;
   enc_cur.*, ;
   ai_serv.date as s_date,;
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
   ai_serv.service_value,;
   Nvl((Select description From service_values WHere service_values.code=ai_serv.service_value), Space(45)) as sv_descript,;
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
   ai_serv.date as s_date,;
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
   ai_serv.service_value,;
   Nvl((Select description From service_values WHere service_values.code=ai_serv.service_value), Space(45)) as sv_descript,;
   ai_serv.user_id as s_user_id, ;
   ai_serv.dt      as s_dt ;
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

Select * ;
from ;
	tenc0 ;
UNION ALL ;
SELECT ;
	enc_cur.*, ;
   {} as s_date,;
	space (4) as s_beg_tm, ;
   Space(2) as s_beg_am, ;
	space (4) as s_end_tm, ;
   Space(2) as s_end_am, ;
	0000 as service_id, ;
   "No services provided" AS serv_descr, ;
	Space(4) AS serv_cadr, ;
   0 AS s_value, ;
   0 AS numitems, ;
   Space(4) AS  sercadr2, ;
   Space(2) as serv_mai, ;
	Space(30) as how_provd, ;
	Space(3) as outcome, ;
	Space(50) as proc_serv, ;
	Space(5) as s_work_id , ;
	Space(2) as s_location, ;
	Space(10) AS serv_id, ;
	Space(10) AS att_id, ;
   0 As service_value,;
   Space(45) as sv_descript,;
	Space(5) as s_user_id, ;
	{}		 as s_dt ;
FROM ;
	enc_cur ;
WHERE ;
	NOT EXIST (SELECT * FROM ai_serv WHERE ai_serv.act_id = enc_cur.act_id) ;
INTO CURSOR ;
	tenc1	

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
   tenc2.s_date,;	
   tenc2.categorycd,;
   tenc2.categoryds,;
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
	Space(30) AS s_workname, ;
	tenc2.s_user_id, ;
	USERNAME(tenc2.s_user_id) as s_username, ;
	tenc2.s_dt, ;
	tenc2.loc_descr, ;
	outcome.descript as out_descr, ;
	tenc2.att_id, ;
   tenc2.service_value,;
   tenc2.sv_descript,;
   Space(5) as Grp_id, ;
   tenc2.conno, ;            && VT 11/03/2009 dev Tick 6326
   tenc2.model_id, ;         && VT 11/03/2009 dev Tick 6326
   tenc2.intervention_id, ;  && VT 11/03/2009 dev Tick 6326
   tenc2.session_number, ;   && VT 11/03/2009 dev Tick 6326
   tenc2.inc_provided, ;     && VT 11/03/2009 dev Tick 6326
   tenc2.unit_delivery, ;    && VT 11/03/2009 dev Tick 6326
   tenc2.mcondoms,;          && PB 03/2013 AIRS-628
   tenc2.fcondoms,;          && PB 03/2013 AIRS-628
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
   tenc2.s_date,;   
   tenc2.categorycd,;
   tenc2.categoryds,;
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
   Space(30) AS s_workname, ;
   tenc2.s_user_id, ;
   USERNAME(tenc2.s_user_id) as s_username, ;
   tenc2.s_dt, ;
   tenc2.loc_descr, ;
   Space(30) out_descr, ;
   tenc2.att_id, ;
   tenc2.service_value,;
   tenc2.sv_descript,;
   Space(5) as Grp_id, ;
   tenc2.conno, ;              && VT 11/03/2009 dev Tick 6326
   tenc2.model_id, ;           && VT 11/03/2009 dev Tick 6326
   tenc2.intervention_id, ;    && VT 11/03/2009 dev Tick 6326
   tenc2.session_number, ;      && VT 11/03/2009 dev Tick 6326
   tenc2.inc_provided, ;        && VT 11/03/2009 dev Tick 6326
   tenc2.unit_delivery, ;       && VT 11/03/2009 dev Tick 6326
   tenc2.mcondoms,;          && PB 03/2013 AIRS-628
   tenc2.fcondoms,;          && PB 03/2013 AIRS-628
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
Copy To extracts\ursprog.dbf Type FOX2X
=CursorToXML('ursprog','extracts\xml\ursprog.xml',1,512)

=OpenFile('diagnos','code')
SELECT * FROM diagnos INTO CURSOR diag2
INDEX ON code TAG diag2
=OpenFile('teams','code')
=OpenFile('grpatt','att_id')


SELECT ursserv
ZAP
APPEND FROM DBF("encserv")
USE IN encserv

SET RELATION TO worker_id INTO staffcur
* jss, 5/6/03, relate to new lookups
SET RELATION TO diagnos1	INTO diagnos ADDI
SET RELATION TO diagnos2  	INTO diag2   ADDI
SET RELATION TO team 		INTO teams   ADDI
* jss, 11/24/03, relate to grpatt
SET RELATION TO att_id		INTO grpatt	 ADDI
GO TOP
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
* =MakeMeds()
=MakeLabs()
=MakeDrugs()

** jss, 8/16/01, add new routine, makeplac(), to create new extract dbf ursplace (placement history)
=MakePlac()
** jss, 1/12/02, add new routine, makerisk(), to create new extract dbf ursrisk (hiv risk history)
=MakeRisk()
** jss, 11/26/03, add new routine, makeevnt(), to create new extract dbf ursevent (eto, outreach, prevention modules)
=MakeEvnt()

**VT 08/09/2011 AIRS-91
=MakeHousehold()

**VT 11/02/2011 AIRS-181
=MakeHousing()

*!* AIRS-34 add diagnosis information
=MakeDiagnosis()

USE IN temp
SELECT ursdata

=OpenFile('ai_ctr')
=OpenFile('ctr_test')
=OpenFile('ctr_partd')

=OpenFile('ctr_datax_mask')
Set Order To column_ord

Select ctr_datax_mask
Go Top

*!* Build a cursor to hold the CTR Part A & B & D information.
cStru ='Create Cursor ctrdata ('+Trim(field_name)+' '+Trim(field_type)+ICase(field_type='C','('+Transform(field_len,'@l 999')+')',field_type='N', '('+Transform(field_len,'@l 999')+','+Transform(field_dec,'@l 999')+')')
Skip

Scan rest 
   cStru=cStru+','+Trim(field_name)+' '+Trim(field_type)+;
      ICase(field_type='C','('+Transform(field_len,'@l 999')+')',field_type='N', '('+Transform(field_len,'@l 999')+','+Transform(field_dec,'@l 999')+')','')
   
EndScan
cStru=cStru+')'
ExecScript(cStru)

*!* Start filling the currsor
Select ai_ctr
m.no_partb_a=.t.

Go Top
Scan
   m.no_partb_a=.t.
   Scatter Name oai_ctr
   
   Select * From ctr_test Where ctr_id = oai_ctr.ctr_id Into Cursor octr_test
   If _Tally > 0
      m.no_partb_a=.f.
   EndIf
  
   If m.no_partb_a=(.t.)
      Select ctrdata
      Append Blank

      Select ctr_datax_mask
      Go Top
      Scan For Trim(Upper(table_name)) = 'AI_CTR'
         Select ctrdata
         If !Empty(Nvl(Field(Trim(ctr_datax_mask.field_name)),''))
             Replace (ctr_datax_mask.field_name) With ;
                  (Iif(Empty(ctr_datax_mask.obj_name), ExecScript(ctr_datax_mask.table_cmt), Evaluate(ctr_datax_mask.obj_name)))
         EndIf
         Select ctr_datax_mask
      EndScan
      Select ctrdata

   Else
      Select octr_test
      Go Top
      Scan
         Select ctrdata
         Append Blank

         Select ctr_datax_mask
         Scan For Trim(Upper(table_name)) <> 'CTR_PARTD'  &&**VT 05/26/2010 Dev Tick 7011 add for
            Select ctrdata
            If !Empty(Nvl(Field(Trim(ctr_datax_mask.field_name)),''))
                Replace (ctr_datax_mask.field_name) With ;
                      (Iif(Empty(ctr_datax_mask.obj_name), ExecScript(ctr_datax_mask.table_cmt), Evaluate(ctr_datax_mask.obj_name)))

            EndIf
            Select ctr_datax_mask

         EndScan

         Select * From ctr_partd Where ctrtest_id = octr_test.ctrtest_id Into Cursor octr_partd
         Select octr_partd
         Go Top
         Scan
            Select ctr_datax_mask
            Scan For Trim(Upper(table_name)) = 'CTR_PARTD'  &&**VT 05/26/2010 Dev Tick 7011 add for
               Select ctrdata
               
               Locate for ctrdata.ctrtstid_b=octr_partd.ctrtest_id   &&**VT 08/10/2010
               If Found() 
                  If !Empty(Nvl(Field(Trim(ctr_datax_mask.field_name)),''))
                     Replace (ctr_datax_mask.field_name) With ;
                           (Iif(Empty(ctr_datax_mask.obj_name), ExecScript(ctr_datax_mask.table_cmt), Evaluate(ctr_datax_mask.obj_name)))
                  EndIf
               EndIf
               Select ctr_datax_mask

            EndScan
            Select octr_partd

         EndScan
         Select octr_test

      EndScan
    EndIf
    Select ai_ctr   
EndScan

Use In ctr_datax_mask
Select ctrdata

Update ctrdata ;
   Set PROGA_DESC = program.descript ;
From program;
Where program.prog_id = ctrdata.PROGRAM_A ;
      And !Empty(ctrdata.PROGRAM_A)

Update ctrdata ;
   Set PRG_B_DESC = program.descript ;
From program;
Where program.prog_id = ctrdata.PROGRID_B;
      And !Empty(ctrdata.PROGRID_B)

Update ctrdata ;
   Set SITEB_DESC = site.descript1 ;
From site;
Where site.psite_id=ctrdata.SITE_ID_B ;
      And !Empty(ctrdata.SITE_ID_B)

Update ctrdata ;
   Set SITEA_DESC = site.descript1 ;
From site ;
Where site.psite_id=ctrdata.PSITE_ID_A;
      And !Empty(ctrdata.PSITE_ID_A)

Update ctrdata ;
   Set SITED_DESC = site.descript1 ;
From site;
Where site.psite_id=ctrdata.PSITEIDD_D;
      And !Empty(ctrdata.PSITEIDD_D)

Update ctrdata ;
   Set WORKA_NAME = PADR(oApp.FormatName(staffcur.last,staffcur.first,staffcur.mi), 50) ;
From staffcur ;
Where staffcur.pworker_id=ctrdata.PWORK_ID_A;
      And !Empty(ctrdata.PWORK_ID_A)

Update ctrdata ;
   Set WORKB_NAME = PADR(oApp.FormatName(staffcur.last,staffcur.first,staffcur.mi), 50) ;
From staffcur ;
Where staffcur.pworker_id=ctrdata.WORKID_B;
      And !Empty(ctrdata.WORKID_B)

Update ctrdata ;
   Set WORKD_NAME = PADR(oApp.FormatName(staffcur.last,staffcur.first,staffcur.mi), 50) ;
From staffcur;
Where staffcur.pworker_id=ctrdata.WORKERD_D;
      And !Empty(ctrdata.WORKERD_D)
 
Update ctrdata ;
   Set CONNO_A = ai_enc.conno, ;
       CNTRCTID_A = ai_enc.contract_id, ;
       MODLID_A = ai_enc.model_id, ;
       INTVID_A = ai_enc.intervention_id, ;
       ENC_ID_A = ai_enc.enc_id ;
From ai_enc ;
Where ai_enc.act_id=ctrdata.ACT_ID_A ;
      And !Empty(ctrdata.ACT_ID_A)
 
Update ctrdata ;
   Set MODLA_DSC = model.modelname ;
From model;
Where ctrdata.MODLID_A = model.model_id;
      And !Empty(ctrdata.MODLID_A)
        
Update ctrdata ;
   Set INTVA_DESC = intervention.name ;
From intervention;
Where ctrdata.INTVID_A = intervention.intervention_id;
      And !Empty(ctrdata.INTVID_A)
 
Update ctrdata ;
   Set ENC_A_DESC = enc_list.description ;
From enc_list;
Where enc_list.enc_id = ctrdata.ENC_ID_A;
      And !Empty(ctrdata.ENC_ID_A)

*!* Copy to fox2x free table.             
Select ctrdata
Copy To extracts\ursctr.dbf Type FOX2X
=CursorToXML('ctrdata','extracts\xml\ursctr.xml',1,512)
Use In ctrdata

*!* Referral History ai_ref
=OpenFile('ai_ref')
=OpenFile('ref_cat')
=OpenFile('ref_stat')
=OpenFile('ref_for')
=OpenFile('Priority')
**VT 10/22/2009 DEv Tick 5502
=OpenFile('ref_srce')

Select ;
       ai_ref.tc_id,;
       ai_ref.act_id, ;
       ai_ref.ctr_id, ;
       ai_ref.ctrtest_id, ;
       ai_ref.serv_id, ;
       ai_ref.ref_id, ;
       ai_ref.ref_cat,;
       Nvl(ref_cat.descript,Space(50)) As ref_desc,;
       ai_ref.ref_for, ;
       Nvl(ref_for.descript,Space(50)) As ref4desc,;
       ai_ref.ref_to, ;
       Nvl(PADR(Alltrim(ref_srce.NAME)+" "+ ;
          oapp.address2(ref_srce.ADDR1,"" ,ref_srce.CITY,ref_srce.STATE,ref_srce.ZIPCODE) ,75),Space(75)) As ref2desc, ;  
       ai_ref.priority, ;
       Nvl(priority.descript,Space(50)) As prity_desc,;
       ai_ref.status, ;         
       Nvl(ref_stat.descript, Space(50)) As stat_desc,;
       ai_ref.on_site, ;
       ai_ref.need_dt, ;
       ai_ref.ref_dt, ;
       ai_ref.verif_dt, ;
       ai_ref.appt_num,;
       ai_ref.apt_kept, ;
       ai_ref.need_id, ;
       ai_ref.followup, ;
       ICase(followup=1, Padr('Active referral',36),;
             followup=2,'Passive referral-agency verification',;
             followup=3,'Passive referral-client verification',;
             followup=4, Padr('None',36),'') As followdesc, ;
       ai_ref.appt_dt, ;
       ai_ref.user_id,;
       ai_ref.dt ;
From ai_ref;
 Left Outer Join ref_cat On ai_ref.ref_cat=ref_cat.code;
 Left Outer Join ref_for On ai_ref.ref_cat=ref_for.category And ai_ref.ref_for=ref_for.code;
 Left Outer Join ref_stat On ai_ref.status=ref_stat.code;
 Left Outer Join priority On ai_ref.priority=priority.code;
 Left Outer Join ref_srce On ai_ref.ref_to = ref_srce.code ;    
Order By tc_id;
Into cursor refldata

**VT 10/22/2009 DEv Tick 5502
**Copy Fields Except refnote, dt, tm To extracts\ursref.dbf Type FOX2X
Copy To extracts\ursref.dbf Type FOX2X

Use In refldata

Select 0
Use extracts\ursref.dbf

=CursorToXML('ursref','extracts\xml\ursref.xml',1,512)
Use In ursref
*

*!* NeedleX
=OpenFile('needlx')
=OpenFile('program')
=OpenFile('site')
=OpenFile('ccreason')
***VT 10/22/2009 DEv Tick 5503
=OpenFile('staff')

Select needlx.need_id, ;
       needlx.tc_id, ;
       ai_clien.id_no,;
       needlx.date, ;
       needlx.program, ;
       Nvl(program.descript,Space(50)) As prog_desc,;
       needlx.site, ;
       Nvl(site.descript1,Space(50)) As site_desc,;
       needlx.worker_id, ;
       Nvl(oApp.FormatName(staff.last, staff.first, staff.mi), Space(50)) as worker_name, ;
       needlx.n_in, ;
       needlx.n_out, ;
       needlx.beg_tm, ;
       needlx.beg_am, ;
       needlx.end_tm, ;
       needlx.end_am, ;
       needlx.ccreason, ;
       Nvl(ccreason.descript,Space(50)) As rsn_desc, ;
       needlx.user_id, ;
       needlx.dt ;
From needlx;
      Left outer Join program On program.prog_id=needlx.program;
      Left Outer Join site On site.site_id=needlx.site;
      Left Outer Join ccreason On ccreason.code=needlx.ccreason;
      Left Outer Join userprof On userprof.worker_id = needlx.worker_id ;
      Left Outer Join staff On staff.staff_id = userprof.staff_id ;
      Join ai_clien On ai_clien.tc_id=needlx.tc_id;
Order by needlx.tc_id;
Into Cursor ndlxdata

***VT 10/22/2009 DEv Tick 5503
**Copy Fields Except syr_note, user_id, dt To extracts\ursndlx.dbf Type FOX2X
Copy To extracts\ursndlx.dbf Type FOX2X
Use In ndlxdata

Select 0
Use extracts\ursndlx.dbf

=CursorToXML('ursndlx','extracts\xml\ursndlx.xml',1,512)
Use In ursndlx


**VT 10/22/2009 Dev Tick 4219
*!* Primary Care Physician 
ncl=0
npcpv=0
nr=0

If !Used('client_pcp')
   ncl=1
   =OpenFile('client_pcp')
Endif

If !Used('client_pcp_visits')
   npcpv=1
   =OpenFile('client_pcp_visits')
Endif

If !Used('pcp_reason')
   nr=1
   =OpenFile('pcp_reason')
Endif

*!* AIRS-448
Select cp.pcp_id, ;
       cp.tc_id, ;
       cp.have_pcp,;
       Nvl(icase(cp.have_pcp=1, 'Yes', cp.have_pcp=2, 'No '), Space(3)) as pcp_desc, ;
       cp.date_asked, ;
       Nvl(vn_header.last_vn_date,{}) As dt_verif, ;
       cp.pcp_name,;
       cp.street1, ;
       cp.street2,;
       cp.city, ;
       cp.state, ;
       cp.zip, ;
       cp.phwork, ;
       cp.phhome, ;
       cp.phcell, ;
       cp.visits_exist As visits_exist,;
       Nvl(ICase(cp.visits_exist=1, 'No ',cp.visits_exist=2, 'Yes', Space(03)), Space(03)) As v_exist_desc,;
       cp.changed_pcp, ;
       Nvl(icase(cp.changed_pcp=1, 'Yes', cp.changed_pcp=2, 'No ',Space(03)), Space(3)) as ch_pcp_desc, ;
       cp.pcp_reason, ;
       Nvl(pr.descript, Space(40)) as pcp_r_desc, ;
       cp.pcp_facility, ;
       Nvl(ref_srce.name, Space(40)) as fac_name, ;
       cp.user_id, ;
       cp.dt, ;
       cp.tm;
From client_pcp cp ;
      Left outer Join pcp_reason pr On pr.code=cp.pcp_reason;
      Left Outer Join ref_srce On ref_srce.code = cp.pcp_facility ;
      left outer join vn_header on ;
          cp.tc_id=vn_header.tc_id ;   
      and vn_header.table_category='I' ;    
      and cp.pcp_id = vn_header.table_id ;
Order by cp.tc_id;
Into Cursor pcpdata

*!* AIRS-819 Add client visits to extract process
Select client_pcp_visits.client_pcp_id As pcp_id,;
       client_pcp.tc_id As tc_id,;
       client_pcp_visits.visit_date As visit_date,;
       client_pcp_visits.dt As dt;
From client_pcp_visits;
Left Join client_pcp On client_pcp.pcp_id=client_pcp_visits.client_pcp_id;
Order by 1 ;
Into Cursor urspcpvisits readwrite 

**Close Tables
If ncl=1
   Use In client_pcp
Endif

If npcpv = 1
   Use In client_pcp_visits
EndIf 

If nr=1
   Use In pcp_reason
Endif

Select pcpdata
Copy To extracts\urspcp.dbf Type FOX2X
Use In pcpdata

Select 0
Use extracts\urspcp.dbf

=CursorToXML('urspcp','extracts\xml\urspcp.xml',1,512)
Use In urspcp

*!* AIRS-819 Add client visits to extract process
Select urspcpvisits
Copy To extracts\urspcpvisits.dbf Type FOX2X
Use In urspcpvisits

Select 0
Use extracts\urspcpvisits.dbf

=CursorToXML('urspcpvisits','extracts\xml\urspcpvisits.xml',1,512)
Use In urspcpvisits

*!*   **VT 11/06/2009 Dev Tick 5871 COBRA
*!*   SELECT ah.ai_outh_id, ad.ai_outd_id, ah.tc_id,;
*!*     ah.entered_date as entered_dt, ad.rec_type,;
*!*     ad.completed_date as compl_date, ;
*!*     ad.prog_id As prog_id,;
*!*     program.descript As prog_desc,;
*!*     ad.hiv_medical_provider As hiv_medprov,;
*!*     ad.last_hiv_visit As last_hiv_v,;
*!*     ad.next_due_date as n_due_dt,;
*!*     ad.client_has_provider as cl_has_pr, ad.ref_srce_id as ref_src_id,; 
*!*     PADR(Alltrim(ref_srce.name)+" "+oapp.address2(ref_srce.addr1,"" ,ref_srce.city,ref_srce.state,ref_srce.zipcode),60) as ref_name, ;               
*!*     ad.provider_name as prov_name,ad.med_agency_name as m_ag_name, ad.med_agency_street1 as m_ag_str1,;
*!*     ad.med_agency_street2 as m_ag_str2,ad.med_agency_city as m_ag_city , ad.med_agency_state as m_ag_state,;
*!*     ad.med_agency_zipcode as m_ag_zip, ad.med_agency_fips as m_ag_fips,;
*!*     ad.recent_hiv_care_visit as recent_hiv, ad.rec_hiv_care as rec_hivcar,;
*!*     ad.recent_viral_load_visit as vir_vis_dt, ad.rec_viral_load as r_vir_load,;
*!*     ad.viral_load_results as vl_r_test, ad.vir_load_res as vir_load_r,;
*!*     ad.recent_cd4_count as r_cd4_dt,ad.rec_cd4_count as r_cd4_cnt,;
*!*     ad.recent_cd4_result as r_cd4, ad.rec_cd4_res as r_cd4_res,;
*!*     ad.recent_pap_smear as pap_sm_dt,ad.rec_pap_smear as pap_smear,;
*!*     ad.positive_hep_c as pos_hep_c,ad.chronic_hep_c as chr_hep_c,;
*!*     ad.prescribed_arv_therapy as arv_ther,ad.hiv_therapy_adherence as hiv_ther,;
*!*     ad.alcohol_drug_user as alcoh_use,ad.help_alcohol_drug_use as help_alcoh,;
*!*     ad.alcohol_drug_treatment as alcoh_tr,ad.harm_reduction as harm_reduc,;
*!*     ad.treatment_type as tr_type,ad.alcohol_drug_consistent as alcoh_cons,;
*!*     ad.mental_health_services as mh_serv,ad.current_mental_health_care as mh_care,;
*!*     ad.mental_health_care_type as mh_c_type, ad.mental_health_outpatient_type as mh_o_type,;
*!*     ad.mental_health_attendance as mh_atten,ad.mental_health_meds as mh_meds,;
*!*     ad.taking_mental_health_meds as t_mh_meds,ad.current_housing_status as hous_stat,;
*!*     ad.user_id, ad.dt,ad.tm ;
*!*    From ai_cobra_outcome_header ah ;
*!*       Inner Join ai_cobra_outcome_details ad On ;
*!*           ah.ai_outh_id = ad.ai_outh_id;
*!*       Left Outer Join ref_srce On ;
*!*          ref_srce.code = ad.ref_srce_id ; 
*!*       Left Outer Join program On;
*!*          ad.prog_id=program.prog_id;
*!*   into Cursor cobradt
*!*    
*!*   Copy To extracts\urscobra.dbf Type FOX2X
*!*   Use In cobradt

*!*   Select 0
*!*   Use extracts\urscobra.dbf

*!*   =CursorToXML('urscobra','extracts\xml\urscobra.xml',1,512)
*!*   Use In urscobra
***********************************************************

*!* Hepatitis Status Extract
lCloseHfile=.f.
lCloseSfile=.f.
=dbcOpenTable('hepatitis_statuses','',@lCloseSfile)
=dbcOpenTable('ai_hepatitis_status','',@lCloseHfile)

Select ;
   hep_row_id As heprow_id,;
   tc_id, ;
   effective_date As eff_date, ;
   hep_type,;
   ICase(hep_type=1,'Hepatitis A',hep_type=2,'Hepatitis B',hep_type=3,'Hepatitis C','           ') As hep_info, ;
   hs_status_id As hstatus_id,;
   Padr(Nvl(hepatitis_statuses.description,' '),40,' ') As stat_info ;
From ai_hepatitis_status ;
Left Outer Join hepatitis_statuses On hepatitis_statuses.hs_id=ai_hepatitis_status.hs_status_id;
Order by 1, 2, 3;
Into Cursor _curHepStatus

Copy To extracts\urshepatitis.dbf Type FOX2X

Go Top
=CursorToXML('_curHepStatus','extracts\xml\urshepatitis.xml',1,512)

Use In _curHepStatus

If lCloseHfile=(.t.)
   Use In ai_hepatitis_status
EndIf

If lCloseSfile=(.t.)
   Use In hepatitis_statuses
EndIf 

*!* HCV Treatment 
lCloseHfile=.t.
lCloseSfile=.t.
lCloseH1file=.t.
lCloseS1file=.t.

=dbcOpenTable('ai_hcv_treatment','',@lCloseSfile)
=dbcOpenTable('ai_hcv_medications','',@lCloseHfile)
=dbcOpenTable('hcv_medications','',@lCloseS1file)
=dbcOpenTable('hcv_treatment_ended','',@lCloseH1file)

Select hcv_treatid,;
      tc_id,;
      asked_date,;
      Iif(eligible=(1),'Yes', 'No ') As eligible,;
      Icase(eligible=(2) And medical=(1),'Yes',;
            eligible=(2) And medical=(0),'No ', ;
            '   ') As medical,;
      Icase(eligible=(2) And uncontrolled_substance=(1),'Yes',;
            eligible=(2) And uncontrolled_substance=(0),'No ',;
            '   ') As uncsubst,;
      Icase(eligible=(2) And uncontrolled_mental=(1),'Yes',;
            eligible=(2) And uncontrolled_mental=(0), 'No ',;
            '   ') As uncmental,;
      Icase(eligible=(2) And advanced=(1),'Yes',;
            eligible=(2) And advanced=(0),'No ',;
            '   ') As advanced,;
      Icase(eligible=(2) And unstable=(1),'Yes',;
            eligible=(2) And unstable=(0),'No ',;
            '   ') As unstable,;
      Icase(eligible=(2) And other=(1),'Yes',;
            eligible=(2) And other=(0),'No ',;
            '   ') As other,;
      Icase(eligible=(1) And on_hcv=(1),'Yes',;
            eligible=(1) And on_hcv=(2),'No ', ;
            eligible=(1) And on_hcv=(3),'N/A', ;
            eligible=(2),'N/A',;
            '   ') As on_hcv,;
      Icase(eligible=(1) And on_hcv=(2) And noton_hcv=(1),'No: Client refused                ', ;
            eligible=(1) And on_hcv=(2) And noton_hcv=(2),'No: Client contemplating treatment', ;
            eligible=(1) And on_hcv=(2) And noton_hcv=(3),'No: Prior authorization denied    ', ;
            eligible=(2) And on_hcv=(3) And noton_hcv=(3),'N/A                               ', ;
            '                                  ') As noton_hcv,;
      Space(03) As hcv_drug1,;
      Space(30) As drugname1,;
      Space(03) As hcv_drug2,;
      Space(30) As drugname2,;
      Space(03) As hcv_drug3,;
      Space(30) As drugname3,;
      Space(03) As hcv_drug4,;
      Space(30) As drugname4,;
      Space(03) As hcv_drug5,;
      Space(30) As drugname5,;
      Treatment_started as started,;
      treatment_ended as ended,;
      ended_reason as rsn_ended,;
      Nvl(hcv_treatment_ended.description,Space(50)) as ended_descr,;
      Icase(depression_prior=(1),'Yes',;
            depression_prior=(2),'No ',;
            '   ') As dprior,;
      Icase(depression_during=(1),'Yes',;
            depression_during=(2),'No ',;
            '   ') As dduring;
From ai_hcv_treatment;
Left Outer Join hcv_treatment_ended On;
  ai_hcv_treatment.ended_reason=hcv_treatment_ended.hcv_endid;
Where !Empty(ai_hcv_treatment.hcv_treatid) And !Empty(ai_hcv_treatment.tc_id);
Order by tc_id;
Into Cursor _curHCV ReadWrite

Index on hcv_treatid tag treatid
Set Order To treatid

Select ai_hcv_medications.hcv_treatment_id, ;
       ai_hcv_medications.hcv_drug, ;
       hcv_medications.description;
From ai_hcv_medications;
Join hcv_medications On ai_hcv_medications.hcv_drug=hcv_medications.code;
Order by hcv_treatment_id;
Where !Empty(ai_hcv_medications.hcv_treatment_id);
into cursor _curMeds

Select _curMeds
Go Top
m.hcv_treatment_id=_curmeds.hcv_treatment_id
nCounter=1
Do While !Eof('_curMeds')
   Do While m.hcv_treatment_id=_curmeds.hcv_treatment_id
      m.dcode='hcv_drug'+Alltrim(Transform(nCounter, '9'))
      m.dcodevalue=_curMeds.hcv_drug
      m.drugname='drugname'+Alltrim(Transform(nCounter, '9'))
      m.description=_curMeds.description
            
      If Seek(m.hcv_treatment_id,'_curHCV')  
        Select _curHCV 
      
        Replace (m.dcode) With m.dcodevalue, (m.drugname) With m.description
        Select _curMeds
        nCounter=nCounter+1
      EndIf 
      Skip
   EndDo 
   If Eof('_curMeds')
      Exit
   Else
      nCounter=1
      m.hcv_treatment_id=_curmeds.hcv_treatment_id
   EndIf 
EndDo 

Use in _curMeds

Select _curHCV
Set Order To
Delete Tag treatid

Go top

Copy To extracts\urshcvtreatment.dbf Type FOX2X
=CursorToXML('_curHCV','extracts\xml\urshcvtreatment.xml',1,512)

Use In _curHCV

If lCloseSfile=(.t.)
   Use In ai_hcv_treatment
EndIf
   
If lCloseHfile=(.t.)
   Use In ai_hcv_medications
EndIf 

If lCloseS1file=(.t.)
   Use In hcv_medications
EndIf 

If lCloseH1file=(.t.)
   Use In hcv_treatment_ended
EndIf 


lCloseHfile=.t.
lCloseSfile=.t.
lCloseH1file=.t.
lCloseS1file=.t.

=dbcOpenTable('ai_substance_use_history','',@lCloseSfile)
=dbcOpenTable('subsfreq','',@lCloseHfile)
=dbcOpenTable('admtype','',@lCloseS1file)
=dbcOpenTable('vn_header','',@lCloseH1file)

Select ai_substance_use_history.subuse_id, ;
   ai_substance_use_history.tc_id, ;
   ai_substance_use_history.effective_date As effect_dt, ;
   Nvl(Ttod(vn_header.last_vn_date),{}) As Verify_dt,;
   alcohol, ;
   alcohol_route As alrte_cd,  ;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.alcohol_route), Space(25)) As alrte_dc,;
   alcohol_frequency As alfreq_cd, ;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.alcohol_frequency), Space(40)) As alfreq_dc,;
   amphetamine As amphet,;
   amphetamine_route As amrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.amphetamine_route), Space(25)) As amrte_dc,;
   amphetamine_frequency As amfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.amphetamine_frequency), Space(40)) As amfreq_dc,;
   cannabis As cannabis,;
   cannabis_route As canrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.cannabis_route), Space(25)) As canrte_dc,;
   cannabis_frequency As canfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.cannabis_frequency), Space(40)) As canfreq_dc,;
   cocaine As cocaine,;
   cocaine_route As cocrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.cocaine_route), Space(25)) As cocrte_dc,;
   cocaine_frequency As cocfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.cocaine_frequency), Space(40)) As cocfreq_dc,;
   hallucinogens As hallucinog,;
   hallucinogens_route As halrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.hallucinogens_route), Space(25)) As halrte_dc,;
   hallucinogens_frequency As halfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.hallucinogens_frequency), Space(40)) As halfreq_dc,;
   inhalants As inhalants,;
   inhalants_route As inhrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.inhalants_route), Space(25)) As inhrte_dc,;
   inhalants_frequency As inhfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.inhalants_frequency), Space(40)) As inhfreq_dc,;
   opioids As opioids,;
   opioids_route As opirte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.opioids_route), Space(25)) As opirte_dc,;
   opioids_frequency As opifreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.opioids_frequency), Space(40)) As opifreq_dc,;
   sedatives As sedatives,;
   sedatives_route As sedrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.sedatives_route), Space(25)) As sedrte_dc,;
   sedatives_frequency As sedfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.sedatives_frequency), Space(40)) As sedfreq_dc,;
   tobacco As tobacco,;
   tobacco_route As tobrte_cd,;
   Nvl((Select descript From admtype Where code=ai_substance_use_history.tobacco_route), Space(25)) As tobrte_dc,;
   tobacco_frequency As tobfreq_cd,;
   Nvl((Select descript From subsfreq Where code=ai_substance_use_history.tobacco_frequency), Space(40)) As tobfreq_dc,;
   Iif(abstaining=(1),'Yes','   ') As abstaining,;
   Iif(none=(1),'Yes','   ') As none;
From ai_substance_use_history ;
Left Outer Join vn_header On ai_substance_use_history.subuse_id=vn_header.table_id And vn_header.table_category='L' And ;
            vn_header.tc_id=ai_substance_use_history.tc_id;
Order By ai_substance_use_history.tc_id;
Into cursor _curSubsUse

Select _curSubsUse
Go Top

Copy To extracts\urssubstance.dbf Type FOX2X
=CursorToXML('_curSubsUse','extracts\xml\urssubstance.xml',1,512)

Use In _curSubsUse

If lCloseSfile=(.t.)
   Use In ai_substance_use_history
EndIf

If lCloseHfile=(.t.)
   Use In subsfreq
EndIf

If lCloseS1file=(.t.)
   Use In admtype
EndIf 

If lCloseH1file=(.t.)
   Use In vn_header
EndIf 

Select URSData

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
Set Relation To tc_id INTO ursprog
Set Skip To ursprog
Go Top 

oApp.Msg2User("OFF")
dtlEnded = Datetime()

IF Eof()
	oApp.msg2user('INFORM','No Clients Found, but Event/Session Information May Exist')
Else
   gcRptName = Iif(cSpecialOutput='L','rpt_dataextr','rpt_dataxcompleted')
   
   Do Case
      CASE lPrev = .f.
         If cSpecialOutput='L'
            Report Form rpt_dataextr To Printer Prompt Noconsole NODIALOG 
         Else
            **VT 09/15/2008 Dev Tick 4600
            ** Create Cursor curDummy (dtStarted T, dtEnded T)
            **Insert Into curDummy (dtStarted, dtEnded) Values (dtlStarted, dtlEnded)
            Create Cursor curDummy (dtStarted T, dtEnded T, ;
                                    cDate Date, ;
                                    cTime C(8), ;
                                    as_of_d Date,;
                                    Crit memo, ;
                                    cReportSelection memo)
                                    
            Insert Into curDummy (dtStarted, dtEnded, ;
                                 cDate,;
                                 cTime, ;
                                 as_of_d, ;
                                 Crit, ;
                                 cReportSelection ) ;
               Values (dtlStarted, dtlEnded, ;
                                Date(), ;
                                Time(), ;
                                Date_from, ;
                                m.Crit, ;
                                m.lcTitle1)
            
            Go Top
            Report Form rpt_dataxcompleted To Printer Prompt Noconsole NODIALOG 
         EndIf

      CASE lPrev = .t.     &&Preview
         If cSpecialOutput='L'
            oApp.rpt_print(5, .t., 1, 'rpt_dataextr', 1, 2)
         Else
             **VT 09/15/2008 Dev Tick 4600
            ** Create Cursor curDummy (dtStarted T, dtEnded T)
            **Insert Into curDummy (dtStarted, dtEnded) Values (dtlStarted, dtlEnded)
            Create Cursor curDummy (dtStarted T, dtEnded T, ;
                                    cDate Date, ;
                                    cTime C(8), ;
                                    as_of_d Date,;
                                    Crit memo, ;
                                    cReportSelection memo)
                                    
            Insert Into curDummy (dtStarted, dtEnded, ;
                                 cDate,;
                                 cTime, ;
                                 as_of_d, ;
                                 Crit, ;
                                 cReportSelection ) ;
               Values (dtlStarted, dtlEnded, ;
                                Date(), ;
                                Time(), ;
                                Date_from, ;
                                m.Crit, ;
                                m.lcTitle1)
            Go Top
            oApp.rpt_print(5, .t., 1, 'rpt_dataxcompleted', 1, 2)
           
         EndIf
   EndCase
EndIf

* Zap the tables we just filled (leave this empty for security purposes)
SELECT ursdata
Zap
SELECT ursserv
ZAP
*!*   SELECT ursmeds
*!*   ZAP
SELECT urslabs
ZAP
SELECT ursplace
ZAP
SELECT ursrisk
ZAP
SELECT ursevent
ZAP

Return 


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

Select DstrCurs
Go top

gcRptName = 'rpt_extr_str'
Do Case
   Case lPrev = .f.
      Report Form rpt_extr_str To Printer Prompt Noconsole NODIALOG
      
   Case lPrev = .t.     &&Preview
      oApp.rpt_print(5, .t., 1, 'rpt_extr_str', 1, 2)
EndCase
Return 
*-EOF Extr_Str

*!*   ******************
*!*   PROCEDURE MakeMeds
*!*   ******************
*!*   =OpenFile('arv_ther','code')

*!*   SELECT DISTINCT;
*!*      ai_clien.tc_id, ;
*!*      pres_his.drug, ;
*!*      Space(45) AS drug_name, ;
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
*!*      pres_his.arv_ther, ;
*!*      pres_his.arv_start, ;
*!*      pres_his.arv_end, ;
*!*      pres_his.is_arv, ;
*!*      vh.last_vn_date as dt_verif, ;
*!*      pres_his.date_prescr, ;
*!*      pres_his.contin_arv, ;   &&VT 11/04/2009 Dev Tick 6298
*!*      pres_his.arv_reason ;
*!*   FROM ;
*!*      pres_his ;
*!*         inner join ai_clien on ;
*!*   		      pres_his.client_id = ai_clien.client_id ;
*!*         left outer join vn_header vh on ;
*!*              ai_clien.tc_id = vh.tc_id ;
*!*          and vh.table_category='A' ;
*!*          and vh.table_id = pres_his.presh_id ;  
*!*   WHERE  ai_clien.tc_id IN (SELECT tc_id FROM temp) ;
*!*   INTO CURSOR ;
*!*      temp1
*!*      
*!*      
*!*   Select temp1.*,  ;
*!*   		arv_ther.descript as arv_desc ;
*!*   From temp1, ;
*!*   	arv_ther ;
*!*   Where temp1.arv_ther = arv_ther.code ;
*!*   Union ;
*!*   Select temp1.*,  ;
*!*   		Space(25) as arv_desc ;
*!*   From temp1 ;
*!*   Where Empty(temp1.arv_ther) ;
*!*   Into Cursor tempmed1a

*!*   Select tempmed1a.* ,;
*!*         arv_reason.descript as arv_reasds ;
*!*   From tempmed1a, arv_reason ;
*!*   Where tempmed1a.arv_reason = arv_reason.code ;     
*!*   Union;
*!*   Select tempmed1a.*, ;
*!*      Space(40) as arv_reasds ;   
*!*   From tempmed1a ;
*!*   Where Empty(tempmed1a.arv_reason) ;
*!*   Into Cursor tempmed1   

*!*   * inform user if nothing found
*!*   IF _tally = 0
*!*   *	=MSG2USER('INFORM','No medication history records extracted!')
*!*   	RETURN
*!*   ENDIF

*!*   * now, load in the prescribing physician's name
*!*   SELECT ;
*!*   	tempmed1.*, ;
*!*   	PADR(TRIM(staff.first) + ' ' + TRIM(staff.last),36) AS pres_phys ;
*!*   FROM ;
*!*   	tempmed1, userprof, staff ;
*!*   WHERE ;
*!*   	!EMPTY(tempmed1.worker_id) ;
*!*   AND ;	
*!*   	tempmed1.worker_id = userprof.worker_id ;
*!*   AND ;
*!*   	userprof.staff_id = staff.staff_id ;
*!*   UNION ;
*!*   SELECT ;
*!*   	tempmed1.*, ;
*!*   	Space(36) AS pres_phys ;
*!*   FROM ;
*!*   	tempmed1 ;
*!*   WHERE ;
*!*   	EMPTY(tempmed1.worker_id) ;
*!*   INTO CURSOR ;
*!*   	tempmeds ;
*!*   ORDER BY ;
*!*   	1, 4 		&& tc_id, pres_date		
*!*   	
*!*   * now, load in the drug names
*!*   =OpenFile('drug_id','drug_id')
*!*   =OpenFile('drug_nam','ndc_code')
*!*   SET RELATION TO drug_id INTO drug_id

*!*   SELECT ursmeds
*!*   ZAP
*!*   APPEND FROM (DBF("tempmeds"))
*!*   SET RELATION TO drug INTO drug_nam
*!*   GO TOP   
*!*   REPLACE   ALL drug_name    WITH IIF(EOF('drug_id'), Space(60), drug_id.drug_name)
*!*   SET RELATION TO
*!*   USE IN drug_nam

*!*   SELECT ursmeds
*!*   Copy To extracts\ursmeds.dbf Type FOX2X
*!*   =CursorToXML('ursmeds','extracts\xml\ursmeds.xml',1,512)

*!*   USE IN tempmeds

*!*   RETURN

******************
PROCEDURE MakeLabs
******************
* grab lab test history records
** VT 04/06/2011 Dev Tick 7942 added med_indic
** VT 04/07/2011 Dev Tick 5448 added unknown 

SELECT ;
	testres.tc_id, ;
	testres.testtype, ;
	Space(40) AS testtypeds, ;
	testres.testcode, ;
	Space(40) AS testcodeds, ;
	testres.result, ;
	Space(50) AS result_ds, ;
	testres.count, ;
	testres.range, ;
	Space(40) AS range_ds, ;
	testres.percent, ;
	testres.testdate, ;
	testres.resdate, ;
   Nvl(testres.results_provided, Space(03)) As rprovided, ;
   testres.dt_results_provided As dt_rprovid, ;
	testres.provided, ;
	Space(40) AS providedds, ;
   testres.act_id As act_id,;
   testres.med_indic, ;
   testres.unknown, ; 
   testres.prog_id As program,;
   Nvl(program.descript,Space(31)) As program_ds;
FROM ;
	testres ;
Left Join program On testres.prog_id=program.prog_id;
WHERE ;
	testres.tc_id IN (SELECT tc_id FROM temp) ;
INTO CURSOR ;
	templabs ;
ORDER BY ;
	1,12	&& tc_id, testdate

On Error

* inform user if nothing found
IF _tally = 0
*	=MSG2USER('INFORM','No Lab Test History records extracted!')
	RETURN
ENDIF	

* now, load in the descriptions for the test type, specific lab test, test result, test range, and 
=OpenFile('testtype','code')     	&& relates to (testres.testtype)
=OpenFile('labtest','ttcode')  	   && relates to (testres.testtype + testres.testcode)
=OpenFile('tstreslu','namecode') 	&& relates to ('TEST' + testres.testtype + testres.testcode + testres.result)
=OpenFile('tstrange','testcode') 	&& relates to ('TEST' + testres.testtype + testres.testcode + testres.range)
=OpenFile('ref_srce','code') 		   && relates to (testres.ref_source)

SELECT urslabs
ZAP
APPEND FROM (DBF("templabs"))
* jss, 7/23/07, move next 2 lines below, AFTER descriptions get filled
*!*   Copy To extracts\urslabs.dbf Type FOX2X
*!*   =CursorToXML('urslabs','extracts\xml\urslabs.xml',1,512)

USE IN templabs

SET RELATION TO testtype INTO testtype
SET RELATION TO testtype + testcode	INTO labtest ADDITIVE
SET RELATION TO 'TEST'+ testtype + testcode + result INTO tstreslu ADDITIVE
SET RELATION TO 'TEST'+ testtype + testcode + '  '  + range INTO tstrange ADDITIVE
SET RELATION TO provided INTO ref_srce	ADDITIVE

			
GO TOP
REPLACE ALL testtypeds 	WITH IIF(EOF('testtype'), Space(40), testtype.descript) , ;
			testcodeds 	WITH IIF(EOF('labtest'),  Space(40), labtest.descript) , ;
			result_ds  	WITH IIF(EOF('tstreslu'), Space(50), tstreslu.descript) , ;
			range_ds  	WITH IIF(EOF('tstrange'), Space(40), tstrange.descript) , ;
			providedds 	WITH IIF(EOF('ref_srce'), Space(30), ref_srce.name) 
	
SET RELATION TO

** VT 04/06/2011 Dev Tick 7942 added med_indic
SELECT urslabs
GO TOP
REPLACE ALL result_ds  	WITH Iif(med_indic=0, result_ds, 'Not Medically Indicated')
			
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
	Space(30)	AS placecatds, ;
	placehis.location, ;
	Space(30)	AS locationds, ;
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
=OpenFile('ref_srce','code') 		&& relates to (placehis.location)
=OpenFile('placecat','code') 		&& relates to (placehis.place_cat)


SELECT ursplace
ZAP
APPEND FROM (DBF("tempplac"))

USE IN tempplac

SET RELATION TO place_cat INTO placecat
SET RELATION TO location  INTO ref_srce	ADDITIVE

GO TOP
REPLACE	ALL placecatds  WITH IIF(EOF('placecat'), Space(30), placecat.descript), ;
			locationds 	WITH IIF(EOF('ref_srce'), Space(30), ref_srce.name)
			
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
**VT 11/17/2011 AIRS-184 add dt_verif and readwrite
* grab risk history records
SELECT ;
	relhist.*, client.sex, ;
	{} as dt_verif ;
FROM ;
	relhist, client ;
WHERE ;
	relhist.tc_id IN (SELECT tc_id FROM temp) ;
AND ;
	relhist.client_id = client.client_id ;	
INTO CURSOR ;
	temprisk ;
ORDER BY ;
	2,3	; && tc_id, date
readwrite
	
* inform user if nothing found
IF _tally = 0
*	=MSG2USER('INFORM','No HIV/AIDS Risk History records extracted!')
	RETURN
ENDIF	

SELECT ursrisk
ZAP
* roll thru the cursor, scattering memvars, appending a blank record to ursrisk for each, then gathering the memvars
**VT 11/17/2011 AIRS-184
Select vn_header
cOldTag=Tag()
Set Order To V_CURRENT
Go Top 
**VT End

SELECT temprisk
SCAN
	SCATTER MEMVAR
	**VT 11/17/2011 AIRS-184
	If Seek(Alltrim(temprisk.tc_id)+'C'+Alltrim(temprisk.risk_id),'vn_header','v_current')
	    m.dt_verif=Ttod(vn_header.last_vn_date)
   EndIf
   **VT End
   
* code to determine cdc and rw risk categories
   m.sharequipt=m.sharedequipt
   m.prevtst_my=m.prevtst_mmyyyy
	m.intl_expose=m.initial_exposure
   m.mwmultpart=m.mwithmultpart
   m.fwmultpart=m.fwithmultpart
   m.twmultpart=m.twithmultpart
   m.mwocondom=m.mwithoutcondom
   m.fwocondom=m.fwithoutcondom
   m.twocondom=m.twithoutcondom

   =RwCDCCat()

	SELECT ursrisk
	APPEND BLANK
	GATHER MEMVAR
	SELECT temprisk
EndScan

**VT 11/17/2011 AIRS-184
Select vn_header
Set Order To (cOldTag)
**VT End

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
SELECT ;
   ai_outr.*, ;
   ai_outr.unit_delivery   as unit_deliv, ;
   ai_outr.inc_provided    as inc_provid, ;
   ai_outr.risk_msmidu     as risk_msmid, ;
   ai_outr.risk_sextrans   as risk_sextr, ;
   ai_outr.risk_heterosex  as risk_heter, ;
   ai_outr.intervention_id as interv_id, ;
   ai_outr.session_number  as session_nu, ;
   Space(40)               AS username, ;
   serv_cat.descript       AS servcatdes, ;
   program.descript        AS prog_descr, ;
   enc_list.description    AS enc_descr, ; 
   Space(30) AS cdclocdesc, ;
   Space(40) AS speclocdes, ;
   Space(40) AS targrpdesc, ;
   Space(40) AS refcodedes, ;
   Space(40) AS contcodesc, ;
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
=OpenFile('settings','code')
=OpenFile('location','code')
=OpenFile('target','code')
=OpenFile('sp_tgt','code')
=OpenFile('cdc_risk','code')
=OpenFile('county','statecode')
=OpenFile('ref_srce','code')
=OpenFile('ref_cntc','code')
* jss, 7/23/07, add unit_del
=OpenFile('unit_del','code')
* jss, 8/2/07, add category
=OpenFile('category','progcode') &&serv_cat+code

SELECT outr_cur
SET RELATION TO cdcloctype 		INTO settings
SET RELATION TO spec_loc   		INTO location 	ADDITIVE
SET RELATION TO target_grp 		INTO target   	ADDITIVE
SET RELATION TO refcode				INTO ref_srce 	ADDITIVE
SET RELATION TO contcode         INTO ref_cntc  ADDITIVE
* jss, 7/23/07, add unit_del
SET RELATION TO unit_delivery    INTO unit_del    ADDITIVE
* jss, 8/2/07, add category
SET RELATION TO serv_cat + category  INTO category   ADDITIVE
GO TOP

REPLACE ALL ;
	cdclocdesc WITH IIF(EOF('settings'),'',settings.descript),;
	speclocdes WITH IIF(EOF('location'),'',location.descript),;
	targrpdesc WITH IIF(EOF('target')  ,'',target.descript),;
	refcodedes WITH IIF(EOF('ref_srce'),'',ref_srce.name),;
	contcodesc WITH IIF(EOF('ref_cntc'),'',NAME(ref_cntc.last_name, ref_cntc.first_name)),;
   unitdeldes WITH IIF(EOF('unit_del'),'',unit_del.descript)
				
SET RELATION TO 

SELECT ursevent
ZAP
APPEND FROM DBF("outr_cur")
Copy To extracts\ursevent.dbf Type FOX2X
=CursorToXML('ursevent','extracts\xml\ursevent.xml',1,512)

IF USED('outr_cur')
	USE IN outr_cur
ENDIF

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
****************************************
** End of code
****************************************

Function GetMaxDate(d1,d2,d3,d4)
Return Max(d1,d2,d3,d4)
*

Function UserName(xUserId)
If Seek(xUserId, 'userprof')
	Return IIF(!EOF('staff'),PADR(NAME(staff.last,staff.first,staff.mi),40),Space(40))
Else 
	Return Space(40)		
EndIf 
*

PROCEDURE MakeHousehold
SELECT ;
 ai_fin.tc_id, ;
 ai_fin.ass_dt, ;
 Nvl((Select last_vn_date From vn_header Where table_id=ai_fin.fin_id and table_category='G'),{}) As last_verified_dt,;
 ai_fin.is_refus, ;
 ai_fin.hshld_size, ;
 ai_fin.hshld_incm, ;
 ai_fin.pov_level, ;
 ai_fin.pov_cat, ;
 Iif(ai_fin.Incarcerated=(.t.),1,0) As Incarcerated;
From;
	ai_fin ;
WHERE ;
	ai_fin.tc_id IN (SELECT tc_id FROM temp) ;
INTO CURSOR ;
	tempfin ;
ORDER BY ;
	1,2	&& tc_id, ass_dt

On Error

* inform user if nothing found
IF _tally = 0
	RETURN
ENDIF	


SELECT urshousehold
ZAP
APPEND FROM (DBF("tempfin"))

USE IN tempfin

Copy To extracts\urshousehold.dbf Type FOX2X
=CursorToXML('urshousehold','extracts\xml\urshousehold.xml',1,512)

Return
*

PROCEDURE MakeHousing
SELECT ;
	ai_housing.tc_id, ;
	ai_housing.effective_dt, ;
	ai_housing.last_updated_dttm, ;
	ai_housing.hhead, ;
	ai_housing.dchild, ;
	ai_housing.inaddhouse, ;
	ai_housing.housing, ;
   housing.descript as housing_desc, ; 
   Cast(ai_housing.hudchronic As L) As hudchronic;
 FROM ;
	ai_housing ;
		inner join housing on ;
			ai_housing.housing=housing.code;
WHERE ;
	ai_housing.tc_id IN (SELECT tc_id FROM temp) ;
INTO CURSOR ;
	temphs ;
ORDER BY ;
	1,2	&& tc_id, effect_dt

On Error

* inform user if nothing found
IF _tally = 0
	RETURN
ENDIF	

SELECT urshousing
ZAP
APPEND FROM (DBF("temphs"))

USE IN temphs

Copy To extracts\urshousing.dbf Type FOX2X
=CursorToXML('urshousing','extracts\xml\urshousing.xml',1,512)

Return
*

Procedure MakeDiagnosis
nOldArea51=Select()
=OpenFile('ai_diag')
=OpenFile('diagnos')
=OpenFile('county')

Select ;
   ai_diag.diag_id AS diag_id, ;
   ai_diag.tc_id As tc_id, ;
   ai_diag.diagdate As diagdate,;
   ai_diag.diag_code As diag_code, ;
   diagnos.descript As diag_ds, ;
   ai_diag.icd9code As icd9code, ;
   ai_diag.hiv_icd9 As hiv_icd9, ;
   ai_diag.diagnosed As diagnosed, ;
   ai_diag.st As state, ;
   ai_diag.cnty_resid As cnty_resid, ;
   Nvl(county.descript,Space(25)) As cnty_ds,; 
   ai_diag.entered_dttm As entered_on, ;
   ai_diag.last_updated_dttm As updated_on ;
From ai_diag ;
Join diagnos On ai_diag.diag_code=diagnos.code;
Left Outer Join county On ai_diag.st+ai_diag.cnty_resid=county.state+county.code;
Into Cursor _curAIDiag;
Order by 2,3

Select _curAIDiag
Copy To extracts\ursdiagnosis.dbf Type FOX2X
=CursorToXML('_curAIDiag','extracts\xml\ursdiagnosis.xml',1,512)

Use in _curAIDiag
Select(nOldArea51)

Return 
*

Procedure MakeDrugs
nOldAreas=Select()

=OpenFile('ai_arv_therapy_header')
=OpenFile('ai_prep_therapy_header')
=OpenFile('ai_pep_therapy_header')
=OpenFile('drug_therapy_details')
=OpenFile('ctrmeds')

Select ;
   Ai_arv_therapy_header.tc_id As tc_id,;
   1 As therapy_cd,;
   'ARV  ' As therapy_ds,;
   Ai_arv_therapy_header.is_arv As indicator,;
   ICASE(Ai_arv_therapy_header.is_arv=1,"Yes",Ai_arv_therapy_header.is_arv=2,"No ","   ") AS drugstatus,;
   Ai_arv_therapy_header.date_asked As date_asked,;
   ICase(IsNull(Ai_arv_therapy_header.adherence),Space(03),Between(Ai_arv_therapy_header.adherence,0,100),Transform(Ai_arv_therapy_header.adherence,'999'),Space(03)) As adherence,;
   Nvl(vh.last_vn_date,{}) as dt_verif, ;
   Nvl(drug_therapy_details.drug_code,'   ') As drug_cd,;
   Nvl(ctrmeds.descript,Space(30)) As drug_ds;   
From ai_arv_therapy_header;
Left Outer Join vn_header vh on ;
     ai_arv_therapy_header.client_id = vh.client_id ;
 And vh.table_category='M' ;
 And vh.table_id = ai_arv_therapy_header.arv_id;
Left Outer Join drug_therapy_details On;
   drug_therapy_details.arv_id=ai_arv_therapy_header.arv_id;
Left Outer Join ctrmeds On drug_therapy_details.drug_code=ctrmeds.code;
Union;
Select ;
   Ai_prep_therapy_header.tc_id As tc_id,;
   2 As therapy_cd,;
   'PrEP ' As therapy_ds,;
   Ai_prep_therapy_header.is_prep As indicator,;
   ICASE(Ai_prep_therapy_header.is_prep=1,"Yes",Ai_prep_therapy_header.is_prep=2,"No ","   ") AS drugstatus,;
   Ai_prep_therapy_header.date_asked As date_asked,;
   ICase(IsNull(Ai_prep_therapy_header.adherence),Space(03),Between(Ai_prep_therapy_header.adherence,0,100),Transform(Ai_prep_therapy_header.adherence,'999'),Space(03)) As adherence,;
   Nvl(vh.last_vn_date,{}) as dt_verif, ;
   Nvl(drug_therapy_details.drug_code,'   ') As drug_cd,;
   Nvl(ctrmeds.descript,Space(30)) As drug_ds;   
From Ai_prep_therapy_header;
Left Outer Join vn_header vh on ;
     ai_prep_therapy_header.client_id = vh.client_id ;
 And vh.table_category='N' ;
 And vh.table_id = ai_prep_therapy_header.prep_id;
Left Outer Join drug_therapy_details On;
   drug_therapy_details.prep_id=ai_prep_therapy_header.prep_id;
Left Outer Join ctrmeds On drug_therapy_details.drug_code=ctrmeds.code;
Union;
Select ;
   Ai_pep_therapy_header.tc_id As tc_id,;
   3 As therapy_cd,;
   'PEP  ' As therapy_ds,;
   Ai_pep_therapy_header.is_pep As indicator,;
   ICASE(Ai_pep_therapy_header.is_pep=1,"Yes",Ai_pep_therapy_header.is_pep=2,"No ","   ") AS drugstatus,;
   Ai_pep_therapy_header.date_asked As date_asked,;
   ICase(IsNull(Ai_pep_therapy_header.adherence),Space(03),Between(Ai_pep_therapy_header.adherence,0,100),Transform(Ai_pep_therapy_header.adherence,'999'),Space(03)) As adherence,;
   Nvl(vh.last_vn_date,{}) as dt_verif, ;
   Nvl(drug_therapy_details.drug_code,'   ') As drug_cd,;
   Nvl(ctrmeds.descript,Space(30)) As drug_ds;   
From Ai_pep_therapy_header;
Left Outer Join vn_header vh on ;
     ai_pep_therapy_header.client_id = vh.client_id ;
 And vh.table_category='O' ;
 And vh.table_id = ai_pep_therapy_header.pep_id;
Left Outer Join drug_therapy_details On;
   drug_therapy_details.prep_id=ai_pep_therapy_header.pep_id;
Left Outer Join ctrmeds On drug_therapy_details.drug_code=ctrmeds.code;
Order by 1,2;
Into Cursor _URSDTHERAPY

Select _URSDTHERAPY
Copy To extracts\ursdrugregimen.dbf Type FOX2X
=CursorToXML('_URSDTHERAPY','extracts\xml\ursdrugregimen.xml',1,512)
Use In _URSDTHERAPY
Select(nOldAreas)

Return
