Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

cScheme_id  = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CSCHEME_ID"
      cScheme_id = aSelvar2(i, 2)
   EndIf
EndFor

* jss, 8/10/04, modify this program to recognize difference between ny and ct schemes
PRIVATE gchelp
gchelp = "Security Rights Report Screen"
cTitle = "Security Rights"
cDate = DATE()
cTime = TIME()
=OpenFile("skipbar")
=MakeCursor()

If Used('temp_cur')  
   Use in temp_cur
EndIf
   
* jss, 8/17/01, exclude HARS from report, as this module no longer has any associated records in screens.dbf
* jss, 8/10/04, modify for Connecticut
IF gcState='CT'
	select ;
		upper(padr(a.descript,60)) as descript,;
		str(a.order,2,0)+"  " as number, module, space(10) as screen_id, ;
		.f. as has_add, .f. as has_edit, .f. as has_delete, ;
      Transform(a.order, '@l 999   ') As disp_number ;
	from ;
		modules a;
	where ;
		a.available and a.module <> 'HARS' ;
	union ;
	select ;
		padr("    "+a.descript1,60) as descript,;
		str(b.order,2,0)+str(a.order,2,0) as number, a.module, id as screen_id, ;
		a.has_add, a.has_edit, a.has_delete, ;
      Transform(b.order, '@l 999')+Transform(a.order, '@l 999') As disp_number ;
	from ;
		screens a, modules b;
	where ;
		a.module = b.module and ;
		b.available and ;
		a.available and ;
		!EMPTY(a.descript1) and ;
		a.active ;
	into cursor ;
		temp_cur
ELSE
	select ;
		upper(padr(a.descript,60)) as descript,;
		str(a.order,2,0)+"  " as number, module, space(10) as screen_id, ;
		.f. as has_add, .f. as has_edit, .f. as has_delete, ;
      Transform(a.order, '@l 999   ') As disp_number ;
  	from ;
		modules a;
	where ;
		a.available and a.module <> 'HARS' ;
	union ;
	select ;
		padr("    "+a.descript,60) as descript,;
		str(b.order,2,0)+str(a.order,2,0) as number, a.module, id as screen_id, ;
		a.has_add, a.has_edit, a.has_delete,;
      Transform(b.order, '@l 999')+Transform(a.order, '@l 999') As disp_number ;
	from ;
		screens a, modules b;
	where ;
		a.module = b.module and ;
		b.available and ;
		a.available and ;
		!EMPTY(a.descript) and ;
		a.active ;
	into cursor ;
		temp_cur
ENDIF
If Used('secur_cur') 
   Use in secur_cur
EndIf
   
select ;
	temp_cur.*, ;
	schemes.*, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime ;
from ;
	temp_cur, schemes ;
where ;
	schemes.scheme_id = Trim(cScheme_ID) ;
order by ;
	scheme_id, disp_number;
into cursor ;
	secur_cur

SET RELATION TO Secur_cur.scheme_id + Secur_cur.screen_id INTO skip_cur ADDITIVE

oApp.msg2user('OFF')

Go Top
 
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
            gcRptName = 'rpt_security'
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_security  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.   
                     oApp.rpt_print(5, .t., 1, 'rpt_security', 1, 2)
            ENDCASE
EndIf
Return

*******************************************************************
* make a cursor of security rights
FUNCTION MakeCursor
PRIVATE aTemp
select skipbar
=AFIELDS(aTemp)
If Used('secur_cur')
   Use in secur_cur
EndIf
   
select 0
create cursor skip_cur from array aTemp

If Used('temp')
   Use in temp
Endif   
   
* Pick up all changes to SCREENS not reflected in SKIPBAR
* jss, 8/10/04, modify for Connecticut
IF gcState='CT'
	SELECT ;
		schemes.scheme_id AS scheme_id, id AS screen_id, ;
		.T. AS has_access, has_add AS addenable, ;
		has_edit AS editenable, has_delete AS delenable ;
	FROM ;
		screens, schemes, modules ;
	WHERE ;
		screens.module = modules.module AND ;
		modules.available AND ;
		screens.available AND ;
		!EMPTY(screens.descript1) and ;
		screens.active ;
	INTO CURSOR ;
		temp
ELSE
	SELECT ;
		schemes.scheme_id AS scheme_id, id AS screen_id, ;
		.T. AS has_access, has_add AS addenable, ;
		has_edit AS editenable, has_delete AS delenable ;
	FROM ;
		screens, schemes, modules ;
	WHERE ;
		screens.module = modules.module AND ;
		modules.available AND ;
		screens.available AND ;
		!EMPTY(screens.descript) and ;
		screens.active ;
	INTO CURSOR ;
		temp
ENDIF


SELECT * ;
	FROM ;
		temp ;
	WHERE ;
		NOT exist (SELECT * ;
					FROM ;
						skipbar ;
					WHERE ;
						skipbar.screen_id = temp.screen_id ;
						AND skipbar.scheme_id = temp.scheme_id) ;
	INTO ARRAY ;
		aTemp

* fill up the cursor
SELECT skip_cur
APPEND FROM skipbar
APPEND FROM ARRAY aTemp

RELEASE aTemp
USE IN temp

index on scheme_id + screen_id tag schem_scr additive

