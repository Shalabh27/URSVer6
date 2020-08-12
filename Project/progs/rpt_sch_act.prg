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

lcprog = ""
lccat  = ""

lcserv = ""
ccwork = ""
cEncType = 0

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcserv = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      ccwork = aSelvar2(i, 2)
   EndIf

   If Rtrim(aSelvar2(i, 1)) = "CENCTYPE"
      cEncType = aSelvar2(i, 2)
   EndIf

EndFor
If !Empty(cEncType)
   SET DECIMALS TO 0
   cEncType = Val(cEncType)
   SET DECIMALS to
Endif   

=close_data()

PRIVATE gchelp
gchelp = "Scheduled Activities Report Screen"
cTitle = "Scheduled Activities Report"
cDate = DATE()
cTime = TIME()

If Empty(Date_To)
   Date_to = Date()
Endif   

*=OPENFILE("ENC_TYPE")
=OpenView("lv_enc_type", "urs")
SELECT lv_enc_type
IF !Empty(cEncType) 
   Locate for lv_enc_type.enc_id = cEncType
   If Found()
   	DO CASE
   		CASE EMPTY(lcserv)   && Only encounter picked
   			lccat  = lv_enc_type.category
   			lcserv  = lv_enc_type.serv_cat
   		CASE !(lcserv = lv_enc_type.serv_cat)
   			oApp.msg2user("INFORM","The selected Encounter "+CHR(13);
   			+"does not belong to the Service Category"+CHR(13);
   			+"Please pick the combination again.")
            oApp.msg2user("OFF")
   			RETURN .f.
   	EndCase
   EndIf
EndIf

MyFilt = ".T."

MyFilt = MyFilt  +  IIF(EMPTY(CCWORK)   , "", " and;
   ai_enc.worker_id=CCWORK")
MyFilt = MyFilt  +  IIF(EMPTY(Date_from), "", " and;
   (ai_enc.due_dt >= Date_from)")
MyFilt = MyFilt  +  IIF(EMPTY(Date_to), "", " and;
   (ai_enc.due_dt <= Date_to)")

MyFilt = MyFilt  + IIF(Empty(cEncType),""," AND ai_enc.enc_id = cEncType")

SELECT  ;
	cli_cur.*, ai_enc.act_id, ai_enc.program, ai_enc.category,ai_enc.serv_cat, ;
	ai_enc.enc_id, ai_enc.bill_to, ai_enc.due_dt, ai_enc.beg_tm, ;
	ai_enc.beg_am, ai_enc.end_tm, ai_enc.end_am, ai_enc.worker_id,serv_cat.descript, ;
	SPACE(5)   AS site     , ;
	PADR(" None", 30)  AS sitename , ;
	SPACE(50) AS sexdesc, ;
	SPACE(5)  AS worker    , ;
	SPACE(35) AS workname  , ;
	"Unknown"  AS caseopen  , ;
	enc_list.description    AS encname, ;
	SPACE(25) AS encwork, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;
FROM  ;
	cli_cur, ai_enc,enc_list,serv_cat;
WHERE ;
	cli_cur.tc_id = ai_enc.tc_id;
	AND !EMPTY(ai_enc.due_dt);
	AND ai_enc.enc_id = enc_list.enc_id;
	AND ai_enc.serv_cat = TRIM(lcserv);
	AND ai_enc.program  = TRIM(lcProg);
	AND ai_enc.category = TRIM(lcCat);
	AND ai_enc.serv_cat  = serv_cat.code;
   and &MyFilt ;
INTO CURSOR ;
	enccli

************************  Opening Tables ************************************
If Used("ai_site")   
   Use in ai_site
Endif 

=OPENFILE("staff"		, "staff_id")
=OPENFILE("userprof"	, "worker_id")
SET RELATION TO staff_id INTO staff
=OPENFILE("SITE"  , "SITE_ID")
=OPENFILE("AI_SITE"  , "TC_ID")
SET RELATION TO SITE INTO SITE

=OPENFILE("GENDER","CODE")
=OPENFILE("AI_WORK"  , "TC_ID")
**=OPENFILE("ENC_TYPE"  , "Procacod")

If Used('MyEnc') 
   Use in MyEnc
EndIf

SELECT 0
USE (DBF('EncCli')) ALIAS MyEnc AGAIN EXCLUSIVE
Use in EncCli

  
=OPENFILE("AI_activ","TC_ID2")

SELECT ;
   ai_activ.tc_id, ai_activ.effect_dt, statvalu.incare ;
FROM ;
   Myenc, ai_activ, statvalu;
WHERE ;
   Myenc.tc_id = ai_activ.tc_id and ;
   (gcTc+"ACTIV"+ai_activ.status) = (statvalu.tc+statvalu.type+statvalu.code) ;
   AND ai_activ.tc_id + DTOS(effect_dt) IN ;
            (SELECT MAX(a2.tc_id + DTOS(a2.effect_dt)) ;
               FROM ai_activ a2 ;
                    WHERE a2.effect_dt <= Date_To;
                    GROUP BY a2.tc_id);
INTO CURSOR ;
   t_stat
   
INDEX ON tc_id TAG tc_id

Update Myenc ;
      Set MyEnc.caseopen = IIF(!t_stat.incare ,"Closed " ,"Open   " );
from MyEnc ;
   inner join t_stat on ;
         Myenc.tc_id = t_stat.tc_id
 
         
=OPENFILE("AI_Clien", "TC_ID")

SELE MyEnc
Scan
    * Client's gender
   IF !Empty(myenc.gender) .AND. Seek(myenc.gender, "gender")
      REPL myenc.sexdesc WITH gender.descript
   ENDIF

   *****   SITE   ******
	IF SEEK(MyEnc.TC_ID, 	"AI_SITE")
		REPL SITE WITH Ai_SITE.SITE
		REPL Sitename WITH site.descript1
	ENDIF

	*****   WORKER  ******
* Worker assigned to a client

* jss, 2/16/02, change code here to get most recent	worker assigned in program
	PRIVATE nSelect
	nSELECT = SELECT()
	xProgram=myenc.program
	xtc_id=myenc.tc_id
	
	SELECT 	worker_id, effect_dt ;
	FROM 	ai_work ;
	WHERE 	tc_id = xtc_id ;
	AND		program = xprogram ;
	INTO CURSOR tWORK ;
	ORDER BY 2 DESC
	
	IF _TALLY > 0
		GO TOP
		SELECT (nSELECT)
		REPL WORKER WITH tWORK.WORKER_ID
		IF SEEK(MyEnc.WORKER, 	"userprof")
			REPL Workname WITH oApp.FormatName(UPPER(staff.last), UPPER(staff.first))
		ENDIF
	ELSE
		SELECT (nSELECT)
	ENDIF
   
   * Worker providing encounter/service
   IF SEEK(MyEnc.worker_id, "userprof")
      REPL encwork WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first))
   EndIf
   
EndScan

*!*   If Used("ai_work")   
*!*      Use in ("ai_work")       
*!*   Endif 

*!*   Use in gender

=openfile("Ai_enc", "Tc_id_act")

   SELECT Ai_colen.act_id , ;
	PADR(oApp.FormatName(CLIENT.last_name, CLIENT.first_name), 40) AS colname,;
   CLIENT.last_name, ;
   CLIENT.first_name ;
	FROM Myenc, Ai_colen, CLIENT;
   WHERE Myenc.act_id = Ai_colen.act_id;
      AND Ai_colen.client_id = CLIENT.client_id ;
	INTO CURSOR COLLAT readwrite
   
   If oApp.gldataencrypted
      replace last_name with osecurity.decipher(Alltrim(last_name)) All
      replace first_name with osecurity.decipher(Alltrim(first_name)) All
      replace colname With PADR(oApp.FormatName(last_name, first_name), 40) all
  Endif
      
SELE MyEnc
INDEX ON act_id TAG ACT_ID

SELECT 0
USE (DBF('Collat')) ALIAS COLL AGAIN EXCLUSIVE
Use in collat

SELE COLL
INDEX ON act_id TAG ACT_ID
=openfile("bill_to", "progcode")
=openfile("program", "prog_id")

SELE MyEnc
SET RELATION TO act_id INTO COLL
SET SKIP TO COLL
SET RELATION TO serv_cat + bill_to INTO BILL_TO ADDITIVE
SET RELATION TO PROGRAM INTO program ADDITIVE

oApp.msg2user('OFF')

SELE MyEnc
***SET FILTER TO &MyFilt
GO TOP
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
      Do Case
         Case lnStat = 1    &&Sched Activities 
         				**VT 08/27/2010 Dev Tick 4807 add Upper
                     Do Case
                        CASE nOrder = 1
                            ** cOrd = "MyEnc.program+MyEnc.last_name+MyEnc.first_name"
                             cOrd = "MyEnc.program+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                        CASE nOrder = 2
                             **cOrd = "MyEnc.program+MyEnc.ENCWORK+MyEnc.last_name+MyEnc.first_name"
                             cOrd = "MyEnc.program+MyEnc.ENCWORK+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                        CASE nOrder = 3
                             **cOrd = "MyEnc.program+MyEnc.ENCNAME+MyEnc.last_name+MyEnc.first_name"
                             cOrd = "MyEnc.program+MyEnc.ENCNAME+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                        CASE nOrder = 4
                             **cOrd = "MyEnc.program+MyEnc.last_name+MyEnc.first_name"
                             cOrd = "MyEnc.program+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                     ENDCASE   
                
                     SELECT MyEnc 
                     INDEX ON &cOrd TAG repord
                     
                     gcRptName = 'rpt_sch_act'
                     Do Case
                          CASE lPrev = .f.
                                Report Form rpt_sch_act To Printer Prompt Noconsole NODIALOG 
                           CASE lPrev = .t.    
                                oApp.rpt_print(5, .t., 1, 'rpt_sch_act', 1, 2)
                     EndCase

          Case lnStat = 2   &&Sched Activities by Site
                       **VT 08/27/2010 Dev Tick 4807 add Upper
                       DO CASE
                           CASE nOrder = 1
                                **cOrd = "MyEnc.sitename+MyEnc.program+MyEnc.last_name+MyEnc.first_name"
                                cOrd = "MyEnc.sitename+MyEnc.program+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                           CASE nOrder = 2
                                **cOrd = "MyEnc.sitename+MyEnc.program+MyEnc.ENCWORK+MyEnc.last_name+MyEnc.first_name"
                                cOrd = "MyEnc.sitename+MyEnc.program+MyEnc.ENCWORK+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                           CASE nOrder = 3
                                **cOrd = "MyEnc.sitename+MyEnc.program+MyEnc.ENCNAME+MyEnc.last_name+MyEnc.first_name"
                                cOrd = "MyEnc.sitename+MyEnc.program+MyEnc.ENCNAME+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                           CASE nOrder = 4
                                **cOrd = "MyEnc.sitename+MyEnc.program+MyEnc.last_name+MyEnc.first_name"
                                cOrd = "MyEnc.sitename+MyEnc.program+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))"
                         ENDCASE   
                        SELECT MyEnc 
                        INDEX ON &cOrd TAG repord
                        Set Order To repord
                       gcRptName = 'rpt_sch_site'
                       
                       Do Case
                           CASE lPrev = .f.
                                Report Form rpt_sch_site To Printer Prompt Noconsole NODIALOG 
                           CASE lPrev = .t.     
                                 oApp.rpt_print(5, .t., 1, 'rpt_sch_site', 1, 2)
                       EndCase
     EndCase
EndIf

SET CENT ON
**********************
Function close_data
If Used('Myenc')
    Use in Myenc
EndIf

If Used('coll')  
   Use in Coll
EndIf

If Used('twork')
   Use in twork
Endif   

Return
******************
Function ShowTime
Parameter cmtime
Return (Substr(cmtime,1,2)+":"+Substr(cmtime,3,2)+" ")


