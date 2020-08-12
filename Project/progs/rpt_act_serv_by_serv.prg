Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by number
              nGroup, ;             && report selection number   
              lcTitle1, ;            && report selection description   
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description
              
Acopy(aSelvar1, aSelvar2)

lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)

=close_data()
cCSite = ""
cCWork = ""
LCProg = "" 
lcserv  = ""
cEncType = 0


&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      cCWork = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcserv = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CENCTYPE"
      cEncType  = aSelvar2(i, 2)
   EndIf

EndFor

PRIVATE gchelp
gchelp = "Activities and Services Report (by Service) Screen"
ccTitle = "Activities And Services Report (by Service)"

cDate = DATE()
cTime = TIME()

If !Empty(cEncType)
   SET DECIMALS TO 0
   cEncType = Val(cEncType)
   SET DECIMALS to
EndIf

=OpenView("lv_enc_type", "urs")

SELECT lv_enc_type
IF !Empty(cEncType) And !Empty(lcserv)
      Locate for lv_enc_type.enc_id = cEncType And  lv_enc_type.serv_cat = lcserv
      If !Found()
      	 	oApp.msg2user("INFORM","The selected Encounter "+CHR(13);
                  	      +"does not belong to the Service Category"+CHR(13);
                  			+"Please pick the combination again.")
            oApp.Msg2User('OFF')
        	RETURN .f.
      EndIf
ENDIF

lcserv   = TRIM(lcserv)
lcprog   = TRIM(lcprog)
 
ccsite   = TRIM(ccsite)
ccwork   = TRIM(ccwork)

 
* Put date limitation in SQL
cWhere = IIF(EMPTY(Date_from),""," AND ai_serv.date >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),""," AND ai_serv.date <= Date_to")
cWhere = cWhere + IIF(Empty(ccwork),""," AND ai_serv.worker_id  = ccwork")
cWhere = cWhere + IIF(Empty(cEncType),""," AND ai_enc.enc_id = cEncType")
cWhere = cWhere + IIF(Empty(lcprog),""," AND Inlist(ai_enc.program, "  + lcprog + ")" )

**Select distinct act_id
SELECT  ;
	distinct ai_enc.act_id, ;
				serv_cat.descript,;
				enc_list.description    AS ENCNAME;
FROM ;
	cli_cur, ai_enc, enc_list, serv_cat, ai_serv ;
WHERE ;
	cli_cur.tc_id = ai_enc.tc_id;
	AND ai_enc.enc_id  = enc_list.enc_id;
	AND Iif(!Empty(lcserv), ai_enc.serv_cat  = lcserv, .t.);
	AND ai_enc.site      = ccsite ;
	AND ai_enc.serv_cat  = serv_cat.code ;
	And ai_serv.act_id = ai_enc.act_id ;
	&cWhere ;
INTO CURSOR ;
	tmp_act


SELECT  ;
	cli_cur.*, ;
	ai_enc.act_id, ai_enc.program, ai_enc.serv_cat, ai_enc.category, Space(50) as case_cat,;
	ai_enc.enc_id, ai_enc.bill_to, ai_enc.act_dt, ;
	ai_enc.beg_tm,ai_enc.beg_am, ai_enc.end_tm, ai_enc.end_am, ;
	ai_enc.worker_id, ai_enc.site, ai_enc.enc_note, ;
	tmp_act.descript,;
   Iif(!EMPTY(ai_enc.beg_tm), (Substr(ai_enc.beg_tm,1,2)+":"+Substr(ai_enc.beg_tm,3,2))+ ai_enc.beg_am, '') AS start_time,;   
	PADR(" None",30)  AS Sitename ,;
   Space(90) as client_name, ;
 	SPACE(50) AS sexdesc,;
	SPACE(5)  AS WORKER    ,;
	SPACE(35) AS WORKNAME  ,;
	SPACE(7)  AS CaseOpen ,;
	tmp_act.ENCNAME,;
	SPACE(25) AS ENCWORK, ;
   lcTitle1 as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to, ;
   cOrderBy as sort_order ;
FROM ;
	cli_cur, ai_enc, tmp_act ;
WHERE ;
	    cli_cur.tc_id = ai_enc.tc_id;
	And tmp_act.act_id = ai_enc.act_id ;
INTO CURSOR ;
	EncCli


INDEX ON tc_id TAG tc_id

If Used('MyEnc') 
   Use in MyEnc
EndIf

If Used('tmp_act') 
   Use in tmp_act
EndIf
   
SELECT 0
USE (DBF('EncCli')) ALIAS MyEnc AGAIN EXCLUSIVE

If Used('EncCli')
   Use in EncCli
Endif   

Select distinct tc_id ;
from MyEnc ;
Into Cursor t_id

SELECT ;
	ai_activ.tc_id, ai_activ.effect_dt, statvalu.incare ;
FROM ;
	t_id, ai_activ, statvalu;
WHERE ;
   t_id.tc_id = ai_activ.tc_id And ;
	(gcTc+"ACTIV"+ai_activ.status) = (statvalu.tc+statvalu.type+statvalu.code) ;
	AND ai_activ.tc_id + DTOS(effect_dt) IN ;
				(SELECT MAX(a2.tc_id + DTOS(a2.effect_dt)) ;
					FROM ai_activ a2 ;
                    WHERE a2.effect_dt <= Date_To ;
                    GROUP BY a2.tc_id);
INTO CURSOR ;
	t_Stat
   
INDEX ON tc_id TAG tc_id

Select t_id.*, ;
      cli_cur.last_name, ;
      cli_cur.first_name,;
      Space(90) as full_name ;
from t_id ;
   inner join cli_cur on ;
         t_id.tc_id = cli_cur.tc_id ;
into cursor t_name readwrite

replace full_name With oApp.FormatName(upper(last_name),upper(first_name)) All

INDEX ON tc_id TAG tc_id
           
Use in t_id
************************  Opening Tables ************************************
=OPENFILE("staff"		,"staff_id")
=OPENFILE("userprof"	,"worker_id")
SET RELATION TO staff_id INTO staff

=OPENFILE("SITE"  ,"SITE_ID")
=OPENFILE("GENDER","CODE")
=OPENFILE("AI_WORK")
Set Order To TC_ID2  desc
=openfile("program","prog_id")

SELE MyEnc
GO TOP
SCAN
   *Client Name
   If Seek(MyEnc.tc_id,   "t_name")
         Replace client_name With t_name.full_name
   Endif      
   * Client's gender
   IF !Empty(myenc.gender) .AND. Seek(myenc.gender, "gender")
      REPL myenc.sexdesc WITH gender.descript
   ENDIF
   

   *****   SITE   ******
   IF SEEK(MyEnc.site,   "SITE")
      REPL Sitename WITH site.descript1
   ENDIF

   *****   WORKER  ******

   * Worker assigned to a client in the program that provided encounter/service
   IF SEEK(MyEnc.TC_ID + MyEnc.program, "Ai_WORK")
      REPL WORKER WITH Ai_WORK.WORKER_ID
      IF SEEK(MyEnc.WORKER,   "userprof")
         REPL Workname WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first))
      ENDIF
   ENDIF

   * Worker providing encounter/service
   IF SEEK(MyEnc.worker_id, "userprof")
      REPL encwork WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first))
   ENDIF

   *****   CASEOPEN  ******

   IF !SEEK(MyEnc.TC_ID, "t_stat")
      REPL MyEnc.caseopen WITH "Unknown"
   ELSE
      REPL MyEnc.caseopen WITH IIF( !t_stat.incare ,"Closed " ,"Open   " )
   ENDIF

   SELECT MyEnc
EndScan

Use in t_name
Use in t_stat
***************************************************************************
	
SELECT ;
	Ai_colen.act_id AS act_id,SPACE(4) AS service,;
	SPACE(5) AS worker_id,;
	Cast('' as memo) as servnote, ;
 	SPACE(4) AS s_beg_tm,SPACE(2) AS s_beg_am,;
	SPACE(4) AS s_end_tm,SPACE(2) AS s_end_am,;
	Space(10) as serv_date, ;
	SPACE(55) AS serv,;
	SPACE(10) AS start,;
	SPACE(10) AS END,;
	SPACE(10)  AS  tottime, ;
	PADR(oApp.FormatName(cli_cur.last_name,cli_cur.first_name),40) AS colname,;
	SPACE(35)  AS  WORK,;
	"01"      AS LIST, ;
	000 as numitems, ;
	0000000.00 as value, ; 
	SPACE(10) AS att_id, ;
	SPACE(10) AS serv_id, ;
   0000 as service_id ;
FROM  ;
	Myenc, Ai_colen, cli_cur;
WHERE ;
	Myenc.act_id = Ai_colen.act_id;
	AND Ai_colen.client_id = cli_cur.client_id;
INTO CURSOR COLLAT

SELE MyEnc
INDEX ON act_id TAG ACT_ID ADDITIVE

* jss, 3/6/03, add ai_serv.att_id and ai_serv.serv_id so we can grab topic info later
If Used('Cli_ser')
   Use in Cli_ser
EndIf


SELECT ;
	ai_serv.act_id,ai_serv.service,  ;
	ai_serv.worker_id,ai_serv.servnote AS servnote,;
	ai_serv.s_beg_tm,ai_serv.s_beg_am,ai_serv.s_end_tm,;
	ai_serv.s_end_am,;
	Dtoc(ai_serv.date) as serv_date, ;
	SPACE(55)  AS  serv, ;
	Space(10) as start, ;
	Space(10) as END,;
	SPACE(10)  AS  tottime,;
	SPACE(40) AS colname,;
	SPACE(35)  AS  WORK ,;
	"02"      AS LIST,;
	ai_serv.numitems, ;
	ai_serv.s_value as value, ;
	ai_serv.att_id, ;
   ai_serv.serv_id, ;
	ai_serv.service_id ;
FROM ;
	ai_serv, Myenc ;
WHERE ;
   	Myenc.act_id = ai_serv.act_id ;
  AND ai_serv.worker_id = ccwork ;
INTO CURSOR ;
	Cli_Ser
   

  
SELECT 0
USE (DBF('Cli_Ser')) ALIAS MyServ AGAIN EXCLUSIVE

If Used('Cli_Ser')
   Use in Cli_ser
EndIf

=openfile("serv_list")

SELE MyServ
GO TOP
SCAN
   ******************serv***********************************
   IF SEEK(MyServ.act_id,"MyEnc")

      SELECT serv_list
      LOCATE FOR serv_list.service_id = MyServ.service_id
      
         IF FOUND()
            REPL MyServ.serv WITH serv_list.description
         ENDIF


   EndIf
   
   ************************start*******************************
   IF !EMPTY(MyServ.s_beg_tm)
      REPL MyServ.start WITH SHowTime(MyServ.s_beg_tm)+MyServ.s_beg_am
   ENDIF
   ***********************end******************************
   IF !EMPTY(MyServ.s_end_tm)
      REPL MyServ.end WITH SHowTime(MyServ.s_end_tm)+ MyServ.s_end_am
   ENDIF
   **********************tottime*****************************************
   IF (!EMPTY(MyServ.s_beg_tm) AND !EMPTY( MyServ.s_end_tm))
      REPL MyServ.tottime WITH FormHours(TimeSpent(MyServ.s_beg_tm,;
         MyServ.s_beg_am,MyServ.s_end_tm,;
         MyServ.s_end_am))
   ENDIF
   ******************work***********************************
   IF !EMPTY(MyServ.worker_id)
      IF SEEK(MyServ.worker_id,"userprof")
         IF SEEK(userprof.staff_id,"staff")
            REPL MyServ.work WITH PADR(oApp.Formatname(Staff.last,Staff.first),35)
         ENDIF
      ENDIF
   ENDIF
   ******************servnote***********************************
  SELE MyServ
ENDSCAN

* jss, 3/7/03, next select grabs any associated topics based on serv_id
SELECT ;
	MyServ.* , ;
	topics.descript AS topic ;
FROM ;
	MyServ, ;
	ai_topic, ;
	topics ;
WHERE ;
	MyServ.serv_id    = ai_topic.serv_id ;
AND ai_topic.serv_cat = topics.serv_cat ;
AND ai_topic.code     = topics.code ;
INTO CURSOR ;
	MyServ1 

oApp.ReOpenCur("MyServ1", "MyServ1a")
REPLACE ALL serv WITH SPACE(48) + "Topic: "

* jss, 3/7/03, next select grabs any associated topics based on att_id
SELECT ;
	MyServ.* , ;
	topics.descript AS topic ;
FROM ;
	MyServ, ;
	ai_topic, ;
	topics ;
WHERE ;
	!EMPTY(MyServ.att_id) ;
AND	MyServ.att_id = ai_topic.att_id ;
AND ai_topic.serv_cat = topics.serv_cat ;
AND ai_topic.code     = topics.code ;
AND MyServ.serv_id NOT IN (SELECT distinct serv_id FROM MyServ1) ;
INTO CURSOR ;
	MyServ2

oApp.ReOpenCur("MyServ2", "MyServ2a")
REPLACE ALL serv WITH SPACE(48) + "Topic: "

SELECT * FROM MyServ1a ;
UNION ALL ;
SELECT * FROM MyServ2a ;
INTO CURSOR MyServ3

Use in MyServ1a
Use in MyServ2a
Use in Myserv1
Use in Myserv2

If Used('temp')	
   Use in temp
EndIf
   
SELECT ;
	collat.*, ;
	SPACE(50) AS topic ;
FROM ;
	collat ;
UNION ALL ;
SELECT ;
	MyServ.*, ;
	SPACE(50) AS topic ;
FROM ;
	MyServ ;
UNION ALL ;
SELECT * ; 
FROM ;
	MyServ3 ;		
INTO CURSOR ;
	temp 


Select temp.*, ;
       Iif(list = "01", "Collaterals Involved", Iif(list = "02", "Services Provided","")) as cheader ;
from temp ;
into Cursor t_col  
    
SELECT 0
USE (DBF('t_col')) ALIAS COLLSERV AGAIN EXCLUSIVE
SELE COLLSERV
INDEX ON act_id TAG ACT_ID

Use in temp

If Used('t_col')
   Use in t_col
EndIf


SELECT 	COUNT(DIST tc_id) AS clitot ;
FROM     MyEnc ;
WHERE    caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR repcli

SELECT 	COUNT(DIST act_id) AS enctot ;
FROM     MyEnc ;
WHERE    caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR repenc

SELECT 	COUNT(*) AS servtot ;
FROM     MyEnc, MyServ ;
WHERE    MyEnc.act_id=MyServ.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR repserv

SELECT  SUM(MyServ.value) AS totval ;
FROM    MyServ,MyEnc ;
Where   MyEnc.act_id = MyServ.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR repval 

SELECT  SUM(MyServ.numitems) AS totitems ;
FROM    MyServ,MyEnc ;
Where   MyEnc.act_id = MyServ.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR repitm 


SELECT 	COUNT(*) AS toptot ;
FROM     MyEnc, MyServ3 ;
WHERE    MyEnc.act_id=MyServ3.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
  AND	 ALLTRIM(MyServ3.serv) = "Topic:" ;
INTO CURSOR reptop


SELECT 	program ,;
			COUNT(DIST tc_id) AS clitot ;
FROM     MyEnc ;
WHERE    caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR clitot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	program ,;
			COUNT(DIST act_id) AS enctot ;
FROM     MyEnc ;
WHERE    caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR enctot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	MyEnc.program ,;
			COUNT(*) AS servtot ;
FROM     MyEnc, MyServ ;
WHERE    MyEnc.act_id=MyServ.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR servtot ;
GROUP BY 1

INDEX ON program TAG program


SELECT 	MyEnc.program ,;
       	COUNT(*) AS toptot ;
FROM     MyEnc, MyServ3 ;
WHERE    MyEnc.act_id=MyServ3.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
  AND	 ALLTRIM(MyServ3.serv) = "Topic:" ;
INTO CURSOR toptot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	MyEnc.program,sum(MyServ.numitems) AS totitems ;
FROM    MyServ,MyEnc ;
Where   MyEnc.act_id = MyServ.act_id ;
  AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
INTO CURSOR itmtot ;
GROUP BY 1

INDEX ON program TAG program

SELE MyEnc
SET RELATION TO act_id INTO COLLSERV
SET SKIP TO COLLSERV

SET RELATION TO program INTO program ADDITIVE
SET RELATION TO program INTO itmtot  ADDITIVE
SET RELATION TO program INTO servtot ADDITIVE
SET RELATION TO program INTO enctot  ADDITIVE
SET RELATION TO program INTO clitot  ADDITIVE
SET RELATION TO program INTO toptot  ADDITIVE

**VT 09/02/2010 Dev Tick 7386
Update MyEnc ;
		Set case_cat = category.descript ;
from MyEnc	;
	inner join category on ;
		 MyEnc.serv_cat = category.serv_cat ;
	and MyEnc.category = category.code	

SELE MyEnc
GO TOP


IF nGroup = 2             &&  aGroup(2) = "Active"
  SET FILTER TO caseopen ="Open   "
ENDIF

oApp.msg2user('OFF')
  
Do Case
   Case lnStat = 1    &&Activities and Services
         SELECT MyEnc
         Go Top
         if EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
               
                DO CASE
                  CASE nOrder = 1
                      cOrd = "program+Upper(Alltrim(last_name)+Alltrim(first_name))+serv_cat+DTOS(act_dt)"
                      
                  CASE nOrder = 2
                       cOrd = "program+ENCWORK+Upper(Alltrim(last_name)+Alltrim(first_name))+serv_cat+DTOS(act_dt)"
                  CASE nOrder = 3
                       cOrd = "program+ENCNAME+Upper(Alltrim(last_name)+Alltrim(first_name))+serv_cat+DTOS(act_dt)"
                ENDCASE   
                
               SELECT MyEnc 
               INDEX ON &cOrd TAG repord
                gcRptName = 'rpt_act_serv_serv'
                Do Case
                    CASE lPrev = .f.
                          Report Form rpt_act_serv To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                           oApp.rpt_print(5, .t., 1, 'rpt_act_serv_serv', 1, 2)
                EndCase
         Endif        
    Case lnStat = 2   &&Activities and Services by Site
         SELECT MyEnc
         Go Top
         if EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
         		
                 DO CASE
                     CASE nOrder = 1
                          cOrd = "sitename+program+Upper(Alltrim(last_name)+Alltrim(first_name))+serv_cat+DTOS(act_dt)"
                     CASE nOrder = 2
                          cOrd = "sitename+program+ENCWORK+Upper(Alltrim(last_name)+Alltrim(first_name))+serv_cat+DTOS(act_dt)"
                     CASE nOrder = 3
                          cOrd = "sitename+program+ENCNAME+Upper(Alltrim(last_name)+Alltrim(first_name))+serv_cat+DTOS(act_dt)"
                 ENDCASE   
         
                 SELECT MyEnc 
                 INDEX ON &cOrd TAG repord
                 Go top
                 gcRptName = 'rpt_act_site_serv'
                 Do Case
                     CASE lPrev = .f.
                          Report Form rpt_act_site To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_act_site_serv', 1, 2)
                EndCase
         Endif 
     Case lnStat = 3   &&Activities and Services -Summury
         SELECT MyEnc
         Go Top
         if EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
     
                  SELECT    MyEnc.program ,;
                           Program.descript AS prog_desc ,;
                           MyEnc.serv_cat ,;
                           MyEnc.descript   AS serv_desc ,;
                           COUNT(DIST tc_id) AS cli ,;
                           COUNT(*) AS enc ;
                  FROM     MyEnc, Program ;
                  WHERE    caseopen =IIF(nGroup=2,"Open   ","") ;
                    AND    MyEnc.program = Program.prog_id ;  
                  GROUP BY 1, 3, 2, 4 ;
                  UNION ;
                  SELECT    MyEnc.program ,;
                           'None'+SPACE(26) AS prog_desc ,;
                           MyEnc.serv_cat ,;
                           MyEnc.descript   AS serv_desc ,;
                           COUNT(DIST tc_id) AS cli ,;
                           COUNT(*) AS enc ;
                  FROM     MyEnc ;
                  WHERE    caseopen =IIF(nGroup=2,"Open   ","") ;
                    AND    MyEnc.program NOT IN (SELECT prog_id FROM program) ;  
                  GROUP BY 1, 3, 2, 4;
                  INTO CURSOR sc0 ;
                  ORDER BY 2,4 
                  
                  Select sc0.*, ;               
                        lcTitle1 as lcTitle, ;
                        Crit as Crit, ;   
                        cDate as cDate, ;
                        cTime as cTime, ;
                        Date_from as Date_from, ;
                        date_to as date_to, ;
                        cOrderBy as sort_order ;
                   from sc0;
                   into cursor sc    
                        
                   If Used('sc0') 
                      use in sc0    
                   EndIf
                     
                  * next select gives program+serv_cat totals for services

                  SELECT    MyEnc.program ,;
                           MyEnc.serv_cat ,;
                           COUNT(*) AS serv ;
                  FROM     MyEnc, MyServ ;
                  WHERE    MyEnc.act_id=MyServ.act_id ;
                    AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
                  GROUP BY 1,2 ;
                  INTO CURSOR sc1 

                  INDEX ON program+serv_cat tag progserv

                  * next select gives program+serv_cat totals for # of items
                  SELECT    MyEnc.program,MyEnc.serv_cat,sum(MyServ.numitems) AS totitems ;
                  FROM    MyServ,MyEnc ;
                  Where   MyEnc.act_id = MyServ.act_id ;
                    AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
                  INTO CURSOR sc2 ;
                  GROUP BY 1,2

                  INDEX ON program+serv_cat tag progserv

                  * next select gives program+serv_cat totals for value
                  SELECT    MyEnc.program,MyEnc.serv_cat,sum(MyServ.value) AS totval ;
                  FROM    MyServ,MyEnc ;
                  Where   MyEnc.act_id = MyServ.act_id ;
                    AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
                  INTO CURSOR sc3 ;
                  GROUP BY 1,2

                  INDEX ON program+serv_cat tag progserv

     
                  SELECT    MyEnc.program ,;
                           MyEnc.serv_cat ,;
                           COUNT(*) AS top ;
                  FROM     MyEnc, MyServ3 ;
                  WHERE    MyEnc.act_id=MyServ3.act_id ;
                    AND    MyEnc.caseopen =IIF(nGroup=2,"Open   ","") ;
                    AND    ALLTRIM(MyServ3.serv) = "Topic:" ;
                  GROUP BY 1,2 ;
                  INTO CURSOR sc4

                  INDEX ON program+serv_cat tag progserv

                  SELECT sc
                  * relate the two detail cursors
                  SET RELATION TO program + serv_cat INTO sc1 ADDITIVE
                  SET RELATION TO program + serv_cat INTO sc2 ADDITIVE
                  SET RELATION TO program + serv_cat INTO sc3 ADDITIVE
                  SET RELATION TO program + serv_cat INTO sc4 ADDITIVE
                  * also relate to program level totals cursors created in PR_ENC.prg (calling program)
                  SET RELATION TO program INTO itmtot  ADDITIVE
                  SET RELATION TO program INTO servtot ADDITIVE
                  SET RELATION TO program INTO enctot  ADDITIVE
                  SET RELATION TO program INTO clitot  ADDITIVE
                  SET RELATION TO program INTO toptot  ADDITIVE
                 gcRptName = 'rpt_act_summ_serv'  
                 Do Case
                     CASE lPrev = .f.
                          Report Form rpt_act_summ To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_act_summ_serv', 1, 2)
                 EndCase
         Endif 
      
EndCase


SET CENT ON
**********************************************************
Function close_data

If Used('')
   Use in collat
EndIf

If Used('Myserv')
   Use in Myserv
EndIf

If Used('MyEnc')
   SELE MyEnc
   Set Relation to
   Use
EndIf

If Used('Myserv3')
   Use in Myserv3
EndIf

If Used('temp')
   Use in temp
EndIf

If Used('collserv')
   Use in collserv
EndIf

If Used('repcli')
   Use in repcli
EndIf

If Used('repenc')
   Use in repenc
EndIf

If Used('repserv')
   Use in repserv
EndIf

If Used('reptot')
   Use in reptot
EndIf

If Used('repitm')
   Use in repitm
EndIf

If Used('repval')
   Use in repval
EndIf

If Used('clitot')
   Use in clitot
EndIf

If Used('enctot')
   Use in enctot
EndIf

If Used('servtot')
   Use in servtot
EndIf

If Used('toptot')
   Use in toptot
EndIf

If Used('itmtot')
   Use in itmtot
EndIf


If Used('sc')
   Select sc
   Set RELATION to
   Use
EndIf

If Used('sc1')
   Use in sc1
EndIf

If Used('sc2')
   Use in sc2
EndIf

If Used('sc3')
   Use in sc3
EndIf

If Used('sc4')
   Use in sc4
EndIf

If Used("group") 
   Use in ("group") 
Endif   
      
Return
******************************************************
FUNCTION GetHeader
DO CASE
CASE collserv.list = "01"
	RETURN ("Collaterals Involved")
CASE collserv.list = "02"
	RETURN ("Services Provided")
OTHERWISE
	RETURN("")
ENDCASE

********************************************************************
**** Returns Time spent in minutes
********************************************************************
****Datetime(Year(act_dt),Month(act_dt), Day(act_dt), Val(Left(end_tm, 2)),Val(right(end_tm, 2))) - Datetime(Year(act_dt),Month(act_dt), Day(act_dt), Val(Left(beg_tm, 2)),Val(right(beg_tm, 2)))

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

********************************************************************
**** Display time (numeric) in HH:MM format
********************************************************************
FUNCTION FormHours
PARAMETER nTime
Return StrTran(Str(INT(nTime/60),2)+":"+Str(nTime%60,2),' ','0')
******************************************************************
FUNCTION SHowTime
PARAMETER ctime1
RETURN (SUBSTR(ctime1,1,2)+":"+SUBSTR(ctime1,3,2)+" ")
