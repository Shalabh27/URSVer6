Parameters ;
        lPrev, ;        && Preview     
        aSelvar1, ;     && select parameters from selection list
        nOrder, ;       && order by
        nGroup, ;       && report selection    
        lcTitle, ;      && report selection    
        Date_from , ;   && from date
        Date_to, ;      && to date   
        Crit , ;        && name of param
        lnStat, ;       && selection(Output)  page 2
        cOrderBy        && order by description
        

ACopy(aSelvar1, aSelvar2)

* Print out duplicate clients in the system
* jss, 9/5/03, because field "client.ethnic" no longer used, substitute "client.hispanic"
* jss, 12/22/04, add code to detect duplicate id_no's

PRIVATE gchelp
gchelp='Duplicate Clients Report Screen'
cDate = Date()
cTime = Time()

Select ;
	PADR(UPPER(ALLTRIM(last_name)),20) AS ln, ;
	PADR(UPPER(ALLTRIM(first_name)),15) AS fn, ;
	SOUNDEX(UPPER(ALLTRIM(last_name))) AS sln, ;
	SOUNDEX(UPPER(ALLTRIM(first_name))) AS sfn, ;
	ai_clien.tc_id, ;
	ai_clien.id_no, ;
	cli_cur.client_id, ;
	last_name, ;
	first_name, ;
	mi, ;
	ssn, ;
	cinn, ;
	ai_clien.urn_no, ;
	ai_clien.placed_dt, ;
	dob, ;
	IIF(EMPTY(dob), age, oApp.Age(DATE(), cli_cur.dob)) as age, ;   
	gender, ;
	sex, ;
	ALLTRIM(STR(HISPANIC)) AS ethnic ;
FROM ;
	cli_cur, ai_clien ;
WHERE ;
	cli_cur.client_id = ai_clien.client_id AND ;
	!ai_clien.anonymous;
  And cli_cur.collat_only  =.f. ;        && VT 08/07/2008 Dev Tick 4365 Exclude collaterals form report
INTO CURSOR ;
	cli_info

SELECT ;
	ssn, count(*) as cnt ;
FROM ;
	cli_info ;
WHERE ;
	!EMPTY(ssn) ;
GROUP BY ;
	1 ;
HAVING ;
	cnt > 1 ;
INTO CURSOR ;
	same_ssn

SELECT ;
	cinn, count(*) as cnt ;
FROM ;
	cli_info ;
WHERE ;
	!EMPTY(cinn) ;
GROUP BY ;
	1 ;
HAVING ;
	cnt > 1 ;
INTO CURSOR ;
	same_cinn

SELECT ;
	urn_no, count(*) as cnt ;
FROM ;
	cli_info ;
WHERE ;
	!EMPTY(urn_no) ;
GROUP BY ;
	1 ;
HAVING ;
	cnt > 1 ;
INTO CURSOR ;
	same_urn

SELECT ;
	ln, fn, age, sex, left(ethnic, 1) as ethnic, count(*) as cnt ;
FROM ;
	cli_info ;
WHERE ;
	!EMPTY(id_no) ;
GROUP BY ;
	1, 2, 3, 4, 5 ;
HAVING ;
	cnt > 1 ;
INTO CURSOR ;
	samename
	
SELECT ;
	sln, sfn, age, sex, left(ethnic, 1) as ethnic, count(*) as cnt ;
FROM ;
	cli_info ;
WHERE ;
	!EMPTY(id_no) AND ;
	ln+fn NOT IN (SELECT ln+fn FROM samename) ;
GROUP BY ;
	1, 2, 3, 4, 5 ;
HAVING ;
	cnt > 1 ;
INTO CURSOR ;
	samesound

* jss, 12/22/04, add check for dup id_no's
Select Upper(id_no) as id_no, count(*) as cnt ;
From cli_info ;
WHERE ;
   !EMPTY(id_no) ;
Group by 1 ;
Having cnt > 1 ;
Into cursor sameidno


SELECT ;
	cli_info.*, PADR("Same Name", 30) as problem, 3 as severety, ;
	PADR(cli_info.ln + cli_info.fn + STR(cli_info.age,3,0) + cli_info.sex + LEFT(cli_info.ethnic, 1), 40) as prob_fld ;
FROM ;
	cli_info, samename ;
WHERE ;
	cli_info.ln = samename.ln AND ;
	cli_info.fn = samename.fn AND ;
	cli_info.age = samename.age AND ;
	cli_info.sex = samename.sex AND ;
	LEFT(cli_info.ethnic, 1) = samename.ethnic ;
UNION ;
SELECT ;
	cli_info.*, PADR("Same Sounding Name",30) as problem, 4 as severety, ;
	PADR(cli_info.sln + cli_info.sfn + STR(cli_info.age,3,0) + cli_info.sex + LEFT(cli_info.ethnic, 1), 40) as prob_fld ;
FROM ;
	cli_info, samesound ;
WHERE ;
	cli_info.sln = samesound.sln AND ;
	cli_info.sfn = samesound.sfn AND ;
	cli_info.age = samesound.age AND ;
	cli_info.sex = samesound.sex AND ;
	LEFT(cli_info.ethnic, 1) = samesound.ethnic ;
UNION ;
SELECT ;
	cli_info.*, PADR("Same SSN",30) as problem, 1 as severety, ;
	PADR(cli_info.ssn, 40) as prob_fld  ;
FROM ;
	cli_info, same_ssn ;
WHERE ;
	cli_info.ssn = same_ssn.ssn ;
UNION ;
SELECT ;
	cli_info.*, PADR("Same Medicaid #",30) as problem, 1 as severety, ;
	PADR(cli_info.cinn, 40) as prob_fld  ;
FROM ;
	cli_info, same_cinn ;
WHERE ;
	cli_info.cinn = same_cinn.cinn ;
UNION ;
SELECT ;
	cli_info.*, PADR("Same URN #",30) as problem, 2 as severety, ;
	PADR(cli_info.urn_no, 40) as prob_fld  ;
FROM ;
	cli_info, same_urn ;
WHERE ;
	cli_info.urn_no = same_urn.urn_no ;
Union ;
Select cli_info.*, PADR("Same Client ID #",30) as problem, 1 as severety, ;
	PADR(UPPER(cli_info.id_no),40) as prob_fld ;
From cli_info, sameidno ;
Where UPPER(cli_info.id_no)=sameidno.id_no ;		
INTO CURSOR ;
	cli_probl 
	
INDEX on prob_fld + STR(severety, 1,0) TAG tc_id

If Used("sameidno")
    Use in ("sameidno")
EndIf

If Used("same_cinn")
    Use in ("same_cinn")
EndIf

If Used("same_ssn")
    Use in ("same_ssn")
EndIf

If Used("samesound")
    Use in ("samesound")
EndIf

If Used("samename")
    Use in ("samename")
EndIf

gcRptName = 'rpt_cli_dupl'

SELECT * ;
FROM ;
	cli_probl ;
WHERE ;
	severety IN (SELECT MIN(severety) ;
						FROM cli_probl cp ;
						WHERE cp.tc_id = cli_probl.tc_id) ;
ORDER BY ;
	severety, sln, sfn, ln, fn ;
INTO CURSOR ;
	cli_dupl

oApp.msg2user("OFF")
Go Top

If Eof()
   oApp.msg2user('NOTFOUNDG')
   
Else
   Do Case
      Case lPrev = .f.
           Report Form rpt_cli_dupl To Printer Prompt NoConsole NODIALOG 
           
      Case lPrev = .t.     &&Preview
           oApp.rpt_print(5, .t., 1, 'rpt_cli_dupl', 1, 2)
           
  EndCase
EndIf