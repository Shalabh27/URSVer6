Parameters ;
  lPrev, ;       && Preview     
  aSelvar1, ;    && select parameters from selection list
  nOrder, ;      && order by
  nGroup, ;      && report selection    
  lcTitle, ;     && report selection    
  dDate_from , ; && from date
  dDate_to, ;    && to date   
  Crit , ;       && name of param
  lnStat, ;      && selection(Output)  page 2
  cOrderBy       && order by description

Acopy(aSelvar1, aSelvar2)

cCSite = ""
cCWork = ""
LCProg = "" 
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
EndFor

PRIVATE gchelp
gchelp = "Client Listing by Date Range Screen"
cDate = DATE()
cTime = TIME()
cTitle = "Client Listings by Intake Date Range"

PRIVATE cSaveTC_ID

If Used('ClAlfaR')
   Use in ClAlfaR
EndIf

SELECT cli_cur.*  ,;
   PADR(Upper(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)),25) AS name, ;
   SPACE(05) AS worker, ;
   SPACE(05) AS site, ;
   SPACE(30) AS sitename, ;
   SPACE(30) AS workname, ;
   {} AS SERDT, ;
   SPACE(07) AS CaseOpen, ;
   SPACE(30) AS intwrkname, ;
   SPACE(30) AS intprgdesc, ;
   .F. AS firstrec, ;
   lcTitle as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   dDate_from as Date_from, ;
   dDate_to as Date_to, ;
   Space(50) as addr ;
From ;
   cli_cur;
Join ai_clien On cli_cur.client_id = ai_clien.client_id;
Where;
   ai_clien.placed_dt>=dDate_from AND ;
   ai_clien.placed_dt<=dDate_to ;
 INTO CURSOR ;
   ClAlfaR readwrite

Go top
Scan
   If Seek(ClAlfaR.client_id,'address','client_id')
      Replace ClAlfaR.addr With oApp.address('address')
   EndIf
   Select ClAlfaR
EndScan

If Used("ai_site")   
   Use in ai_site
EndIf

If Used("ai_clien")   
   Use in ai_clien
Endif 

=OPENFILE("staff", "staff_id")
=OPENFILE("userprof", "worker_id")
Select userprof   
Set Relation To
SET RELATION TO staff_id INTO staff

=OPENFILE("AI_ENC","Tc_id_act")
Select ai_enc  
Set Relation to
SET FILTER TO !EMPTY(AI_enc.act_dt)

=OPENFILE("Ai_clien","TC_ID")
Select Ai_clien
Set Relation To   
SET RELATION TO tc_id INTO AI_enc ADDITIVE
SET RELATION TO Client_id INTO Cli_hous ADDITIVE

=OPENFILE("SITE","SITE_ID")
=OPENFILE("AI_SITE","TC_ID desc")
Set Relation To
SET RELATION TO SITE INTO SITE

=OPENFILE("AI_WORK","TC_ID2 DESC")
=OPENFILE("AI_PROG","TC_ID2 DESC")
=OPENFILE("PROGRAM","PROG_ID")

If Used('MyClient')
   Use in MyClient
EndIf
   
Select DIST ;
   ai_prog.program, program.descript, ;
   {} as start_dt, {} as end_dt, ;
   ClAlfaR.* ;
From;
   ClAlfaR;
Join ai_prog On ;
   ClAlfaR.tc_id = ai_prog.tc_id;
Join PROGRAM On ;
   ai_prog.program = program.prog_id;
UNION ALL ;
Select; 
   SPACE(5) AS program , PADR("No program enrollments", 30) AS descript, ;
   {} AS start_dt, {} AS end_dt, ;
   ClAlfaR.* ;
FROM ;
   ClAlfaR ;
WHERE ;
   NOT EXIST (SELECT * FROM ai_prog WHERE ;
               ClAlfaR.tc_id = ai_prog.tc_id) ;
INTO CURSOR MyClient ReadWrite 

Use in ClAlfaR

*****   program assigned WORKER  ******
Select Myclient
Set Relation to tc_id+program into ai_work
replace worker WITH ai_work.worker_id all 
Set Relation to        

Select Myclient
Go Top
Set Relation to worker into userprof
replace workname WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first)) all
Set Relation to     
  
**** intake worker name ***   
Update Myclient ;
       Set IntWrkName = oApp.FormatName(UPPER(staff.last),UPPER(staff.first)) ;
From Myclient;
        inner join userprof on ;
              Myclient.int_worker = userprof.worker_id ;
        inner join staff on ;      
               userprof.staff_id = staff.staff_id      

**** intake program description ***
Select Myclient
Set Relation to int_prog into program
replace IntPrgDesc WITH Program.Descript all 
Set Relation to        

*****   CASEOPEN  ******
If Used('ClOpenStat')
   Use in ClOpenStat
EndIf

If Used('t_id')
   Use in t_id
EndIf

Select distinct tc_id ;
from MyClient ;
into cursor t_id


SELECT Distinct ;
   t_id.Tc_id, ;
   Iif(statvalu.incare, "Open   ","Closed ") as caseopen;
FROM ;
   t_id, ai_activ, statvalu ;
WHERE ;
   t_id.Tc_id = ai_activ.tc_id AND ;
   ai_activ.status = statvalu.code AND ;
   statvalu.tc = gcTC AND ;
   statvalu.type = 'ACTIV' AND ;
   ai_activ.tc_id + DTOS(ai_activ.effect_dt) + oapp.time24(ai_activ.time,ai_activ.am_pm)  ;
               IN (SELECT ;
                     T1.tc_id + MAX(DTOS(T1.effect_dt)+oapp.time24(T1.time, T1.am_pm)) ;
                  FROM ;
                     ai_activ T1 ;
                  WHERE ;
                     T1.effect_dt <= dDate_to ;
                  GROUP BY ;
                     T1.tc_id)      ;
INTO CURSOR ;
   ClOpenStat

Use in t_id

Update MyClient ;
      Set caseopen = ClOpenStat.caseopen ;
From  MyClient ;
      inner join  ClOpenStat on ;
         ClOpenStat.tc_id = MyClient.tc_id   

If Used('ClOpenStat')
   Use in ClOpenStat
EndIf

Select ai_activ
Set Relation to

Select userprof 
Set Relation to

*****   LAST CURRENT PROGRAM  ******
Select Myclient
Set Relation to tc_id+program into ai_prog
replace Start_dt with ai_prog.start_dt all 
replace end_dt with ai_prog.end_dt all
Set Relation to        

SELE MyClient
cSaveTC_ID = Space(10)
Scan
   *****   LAST DATE SERVICES PROVIDED  ******
   IF SEEK(MyClient.TC_ID,   "Ai_ENC")
      IF EMPTY(MyClient.program)
         REPL MyClient.SERDT WITH Ai_ENC.ACT_DT
      ELSE
         SELE Ai_Enc
         LOCATE FOR Ai_Enc.Program = MyClient.program WHILE Ai_Enc.Tc_ID = MyClient.Tc_ID AND NOT EOF()
         SELE MyClient
         IF FOUND('AI_ENC')
            REPL MyClient.SERDT WITH Ai_ENC.ACT_DT
         ENDIF
      ENDIF   
   ENDIF
   *****************Site
   IF SEEK(MyClient.TC_ID,   "AI_SITE")
      REPL SITE WITH Ai_SITE.SITE
      REPL Sitename WITH site.descript1
   ENDIF
EndScan

MyFilt = ".T."
MyFilt = MyFilt + IIF(EMPTY(cCSite)   ,""," and SITE=cCSite")
MyFilt = MyFilt + IIF(EMPTY(cCWork)   ,""," and INT_WORKER=cCWork")
MyFilt = MyFilt + IIF(EMPTY(LCProg)   ,""," and INT_PROG=LCProg")

If Used('temp')
   Use in temp
Endif

DO CASE
CASE nGroup = 1                      && No grouping
   SELECT ;
      MyClient.* , ;
      SPACE(30) AS column1 , ;
      MyClient.workname AS column2 ;
   FROM ;
      MyClient ;
   WHERE ;
      &MyFilt ;
   INTO CURSOR ;
      temp
   *lcTitle = " "
CASE nGroup = 2                      && Site Name group
   SELECT ;
      MyClient.* , ;
      MyClient.sitename AS column1 , ;
      MyClient.workname AS column2 ;
   FROM ;
      MyClient ;
   WHERE ;
      &MyFilt ;
   INTO CURSOR ;
      temp
  * lcTitle = "Site Assignment = "
CASE nGroup = 3                        && Intake Worker Name group
   SELECT ;
      MyClient.* , ;
      MyClient.intwrkname AS column1 , ;
      MyClient.sitename AS column2 ;
   FROM ;
      MyClient;
   WHERE ;
      &MyFilt ;
   INTO CURSOR ;
      temp
   *lcTitle = "Worker Completing Intake = "
CASE nGroup = 4                        && Intake Program group
   SELECT ;
      MyClient.* , ;
      MyClient.IntPrgDesc AS column1 , ;
      MyClient.workname AS column2 ;
   FROM ;
      MyClient;
   WHERE ;
      &MyFilt ;
   INTO CURSOR ;
      temp
  * lcTitle = "Intake Program = "
EndCase

SELECT MyClient
USE
USE (DBF('TEMP')) ALIAS MyClient AGAIN EXCLUSIVE

If Used('temp')
   Use in temp
endif   

If Used('tmp_tot')
   Use in tmp_tot
endif   
If Used('tmp_t')
   Use in tmp_t
EndIf

SELE MyClient
SET RELATION TO TC_ID    INTO Ai_CLIEN ADDITIVE
SET RELATION TO worker   INTO userprof ADDITIVE

PRIVATE lc_alia , lcCrit
lc_alia = ALIA()
lcCrit =ALLTRIM(Crit )
 
     DO CASE
         CASE  lnStat = 0
               Select Count(distinct tc_id) as nTotal ;
               From MyClient ;
               Into Cursor tmp_tot

               Select MyClient.*, ;
                     tmp_tot.nTotal ;
               From MyClient, tmp_tot ;
               Into Cursor t
               
               oApp.ReOpenCur("t", "MyClient") 
                      
         CASE  lnStat = 1
               Select Count(distinct tc_id) as nTotal ;
               From MyClient ;
               Where Rtrim(caseopen) = "Open" ;
               Into Cursor tmp_tot 
               
               Select MyClient.*, ;
                     tmp_tot.nTotal ;
               From MyClient, tmp_tot ;
               Where Rtrim(caseopen) = "Open" ;
               Into Cursor t
               
               oApp.ReOpenCur("t", "MyClient") 
                 
         CASE  lnStat = 2
               
               Select Count(Distinct tc_id) as nTotal ;
               From MyClient ;
               Where Rtrim(caseopen) = "Open" AND EMPTY(end_dt) ;
               Into Cursor tmp_tot 
               
               Select MyClient.*, ;
                     tmp_tot.nTotal ;
               From MyClient, tmp_tot ;
               Where Rtrim(caseopen) = "Open" AND EMPTY(end_dt) ;
               Into Cursor t
              
               oApp.ReOpenCur("t", "MyClient") 
               
         CASE  lnStat = 3
               Select Count(distinct tc_id) as nTotal ;
               From MyClient ;
               Where !int_compl  AND  Rtrim(caseopen) = "Open" ;
               Into Cursor tmp_tot 
               
               Select MyClient.*, ;
                     tmp_tot.nTotal ;
               From MyClient, tmp_tot ;
               Where !int_compl  AND  Rtrim(caseopen) = "Open" ;
               Into Cursor t
               
               oApp.ReOpenCur("t", "MyClient") 
                  
         CASE  lnStat = 6

               Select Count(Dist tc_id) as nTotal ;
               From MyClient ;
               Where caseopen = "Closed " ;
               Into Cursor tmp_tot
               
               Select MyClient.*, ;
                     tmp_tot.nTotal ;
               From MyClient, tmp_tot ;
               Where caseopen = "Closed " ;
               Into Cursor t
               
               oApp.ReOpenCur("t", "MyClient") 
         CASE  lnStat = 7
               Select Coun(Dist tc_id) as nTotal;
               From MyClient ;
               Where EMPTY(cinn) ;
               Into Cursor tmp_tot

                Select MyClient.*, ;
                     tmp_tot.nTotal ;
               From MyClient, tmp_tot ;
               Where EMPTY(cinn) ;
               Into Cursor t
               
               oApp.ReOpenCur("t", "MyClient") 
         Otherwise
              DO CASE
                 CASE     lnStat = 4
                    Select Dist a.tc_id ;
                     From &lc_alia a, ;
                        hivstat b;
                     Where b.tc_id = a.tc_id And ;
                        a.caseopen = "Open   " And ;
                        Empty(b.hivstatus) ;
                     Union ;
                     Select dist a.tc_id;
                     From &lc_alia a ;
                     Where a.caseopen = "Open   " And ;
                        a.tc_id not in (Select hivstat.tc_id From hivstat) ;
                     Into Cursor tmp_t

                     
                     Select Count(tc_id) as nTotal ;
                     From tmp_t ;
                     Into Cursor tmp_tot 
                     
                      Select MyClient.*, ;
                           tmp_tot.nTotal ;
                     From MyClient, tmp_tot, tmp_t ;
                      Where Myclient.tc_id=tmp_t.tc_id ;
                     Into Cursor t
                                       
                     oApp.ReOpenCur("t", "MyClient") 
                     
                     SELECT (lc_alia)
                  
              CASE     lnStat = 5

                       Select Dist a.tc_id ;
                     From &lc_alia a, ;
                        hivstat b;
                     Where b.tc_id = a.tc_id And ;
                        a.caseopen = "Open   "  And ;
                        (b.hivstatus = "04" or b.hivstatus = "12") ;
                      and b.tc_id+DTOS(b.effect_dt)+b.status_id in (Select c.tc_id + max(DTOS(c.effect_dt)+c.status_id) ;
                                                          from hivstat c ;
                                                          group by c.tc_id) ;
                     Into Cursor tmp_t
                  
                     Select Count(tc_id) as nTotal ;
                     From tmp_t ;
                     Into Cursor tmp_tot 
                     
                      Select MyClient.*, ;
                           tmp_tot.nTotal ;
                     From MyClient, tmp_tot, tmp_t ;
                      Where Myclient.tc_id=tmp_t.tc_id  ;
                     Into Cursor t
                     
                     oApp.ReOpenCur("t", "MyClient") 
                   
                     SELECT (lc_alia)
              ENDCASE
       ENDCASE

        cSaveTC_ID = Space(10)
         SELECT (lc_alia)
         SCAN
            IF tc_id <> cSaveTC_ID
               REPL firstrec WITH .T.
               cSaveTC_ID = tc_id
            ENDIF
         EndScan

If Used("t") 
     Use in "t"
EndIf

Select ai_clien
Set Relation to

If Used("tmp_tot") 
     Use in "tmp_tot"
EndIf

oApp.msg2user("OFF") 
gcRptName = 'rpt_cli_int'                
Select MyClient
Go Top 

**VT 12/17/2009 Dev Tick 5142
DO CASE
CASE nOrder=1
     Index On column1+Upper(Alltrim(last_name)+Alltrim(first_name))+PROGRAM Tag col1
     Set Order To col1
   
CASE nOrder=2
   Index On Alltrim(ID_NO)+column1+PROGRAM Tag col1
   *!*Index On column1+Alltrim(ID_NO)+PROGRAM Tag col1
   Set Order To col1
   
CASE nOrder=3   
   Index On Alltrim(zip)+Upper(Alltrim(last_name)+Alltrim(first_name))+column1+PROGRAM Tag col1
   Set Order To col1
   
Endcase
**VT End

Go Top
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else 
   Do Case
      Case lPrev = .f.
         Report Form rpt_cli_int To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.   
         oApp.rpt_print(5, .t., 1, 'rpt_cli_int', 1, 2)
   EndCase 
EndIf