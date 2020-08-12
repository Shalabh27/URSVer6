Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              start_date , ;         && from date
              end_date, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)
lcProg    = ""
lcServ    = ""
cEncType  = ""

            

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcServ = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CENCTYPE"
      cEncType = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg= aSelvar2(i, 2)
   EndIf
EndFor

If !Empty(cEncType)
   SET DECIMALS TO 0
   cEncType = Val(cEncType)
   SET DECIMALS to
EndIf

PRIVATE gcHelp
gcHelp = "Program / Staff Summary Report of Services Provided Screen"
cDate = DATE()
cTime = TIME()
********************************************************
If Used('Cli_ser')
   Use in Cli_ser
EndIf

Local cWhere
cWhere = ''
cWhere = IIF(EMPTY(cEncType),""," AND ai_enc.enc_id = cEncType")


SELECT ;
	ai_serv.serv_id, ai_enc.program, ai_enc.serv_cat,;
	ai_enc.enc_id, ai_enc.worker_id AS enc_work, ;
	ai_serv.service, ai_serv.worker_id,;
	Padr(oApp.FormatName(staff.last,staff.first, staff.mi), 30) as workname,;
	program.descript as progdesc, serv_list.description as servdesc,;
	serv_cat.descript as catdesc, enc_list.description as encdesc ;
FROM ;
	ai_serv, ai_enc, serv_cat, serv_list, enc_list, program, userprof, staff ;
WHERE ;
	ai_serv.act_id = ai_enc.act_id ;
	AND BETWEEN(ai_enc.act_dt, start_date, end_date);
	AND ai_enc.program  = program.prog_id;
	AND ai_enc.program  = Trim(lcProg) ;
	AND ai_enc.serv_cat = Trim(lcServ) ;
	AND ai_enc.serv_cat = serv_cat.code;
	AND ai_enc.enc_id = enc_list.enc_id;
  	AND ai_serv.service_id = serv_list.service_id;
   AND ai_serv.worker_id = userprof.worker_id;
	AND userprof.staff_id = staff.staff_id;
   &cWhere ;
INTO CURSOR ;
	Cli_Ser

IF _TALLY = 0
	oApp.msg2user("NOTFOUNDG")
   oApp.Msg2User('OFF')
	=RESTAREA()
   RETURN .f.
ENDIF

**VT 08/23/2010 Dev Tick 5619
*!*	SELECT DISTINCT worker_id, workname;
*!*	FROM cli_ser ;
*!*	ORDER BY 2 ;
*!*	INTO ARRAY aWorkarr

*!*	nTot_Work = _TALLY

SELECT 000 as group_del, program, progdesc, serv_cat, catdesc, ;
   enc_id, encdesc,;
	service, servdesc,;
	SPACE(30) AS Worker1, ;
	00000    AS Count1,;
	SPACE(30) AS Worker2, ;
	00000    AS Count2,;
	SPACE(30) AS Worker3, ;
	00000    AS Count3,;
	SPACE(30) AS Worker4, ;
	00000    AS Count4,;
	SPACE(30) AS Worker5, ;
	00000    AS Count5, ;
	00000    AS Total,  ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   start_date as Date_from, ;
   end_date as date_to;      
FROM cli_ser ;
WHERE .F. ;
INTO CURSOR Servcur


INDEX ON str(group_del,3)+program+serv_cat+str(enc_id, 4)+service TAG Mixed


IF USED("myserv")
	USE IN myserv
ENDIF
SELECT 0
USE (DBF('Servcur')) ALIAS Myserv AGAIN EXCLUSIVE

If Used('Servcur')
   Use in Servcur
EndIf

**VT 08/23/2010 Dev Tick 5619 add scan, cursor t_prg and where  program = cProgram;

If Used('t_prg')
   Use in t_prg
EndIf

cProgram= ''

SELECT DISTINCT program;
FROM cli_ser ;
ORDER BY 1 ;
INTO cursor t_prg

Scan
	cProgram = t_prg.program
	
		SELECT DISTINCT worker_id, workname;
		FROM cli_ser ;
		where cli_ser.program= cProgram ;
		ORDER BY 2 ;
		INTO ARRAY aWorkarr

		nTot_Work = _TALLY
		   
		FOR n = 1 TO nTot_Work STEP 5

			Select  ; 
		      n as group_del, ;
		      program, ;
		      progdesc, ;
		      serv_cat, ;
		      catdesc, ;
		      enc_id, ;
		      encdesc,;
				service, ;
		      servdesc,;
				aWorkarr[n,2] AS Worker1, ;
				SUM(IIF(worker_id = aWorkarr[n,1], 1, 0)) AS Count1,;
				IIF(n + 1 <= nTot_Work, aWorkarr[n + 1, 2], SPACE(5)) AS Worker2, ;
				SUM(IIF(n + 1 <= nTot_Work AND worker_id = aWorkarr[n + 1,1], 1, 0)) AS Count2,;
				IIF(n + 2 <= nTot_Work, aWorkarr[n + 2, 2], SPACE(5)) AS Worker3, ;
				SUM(IIF(n + 2 <= nTot_Work AND worker_id = aWorkarr[n + 2,1], 1, 0)) AS Count3,;
				IIF(n + 3 <= nTot_Work, aWorkarr[n + 3, 2], SPACE(5)) AS Worker4, ;
				SUM(IIF(n + 3 <= nTot_Work AND worker_id = aWorkarr[n + 3,1], 1, 0)) AS Count4,;
				IIF(n + 4 <= nTot_Work, aWorkarr[n + 4, 2], SPACE(5)) AS Worker5, ;
				SUM(IIF(n + 4 <= nTot_Work AND worker_id = aWorkarr[n + 4,1], 1, 0)) AS Count5, ;
		      Crit as  Crit, ;   
		      cDate as cDate, ;
		      cTime as cTime, ;
		      start_date as Date_from, ;
		      end_date as date_to;   
			FROM cli_ser ;
			where program = cProgram;
			GROUP BY  ;
		            program, ;
		            progdesc, ;
		            serv_cat, ;
		            catdesc, ;
		            enc_id, ;
		            encdesc,;
		            service, ;
		            servdesc,;
		            group_del, ;
		            Worker1 ,;
		            Crit , ;   
		            cDate, ;
		            cTime, ;
		            date_from, ;
		            date_to ;     
			INTO CURSOR Serv_det

			SELECT Myserv
			APPEND FROM (DBF("serv_det"))
		EndFor
EndScan

=restarea()

SELECT Myserv
REPLACE total WITH count1+count2+count3+count4+count5 ALL
SET ORDER TO Mixed
GO TOP

oApp.Msg2User('OFF')

IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
           gcRptName = 'rpt_ser_work'
           DO CASE
               CASE lPrev = .f.
                  Report Form rpt_ser_work To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     
                     oApp.rpt_print(5, .t., 1, 'rpt_ser_work', 1, 2)
            ENDCASE
EndIf
******************************************************8
FUNCTION RESTAREA
set cent on

IF USED("Cli_ser")
	USE IN ("Cli_ser")
ENDIF
IF USED("Mycliprog")
	USE IN ("Mycliprog")
ENDIF

If Used('Serv_det')
   Use in Serv_det
Endif   