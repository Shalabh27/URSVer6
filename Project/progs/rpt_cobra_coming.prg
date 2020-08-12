Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              dDate_from , ;         && from date
              dDate_to, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)


cCWork = ""
LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      cCWork = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor


PRIVATE gchelp
gchelp = "COBRA Reassessment/Outcomes Coming Due"
cTitle = "COBRA Reassessment/Outcomes Coming Due"

cDate = DATE()
cTime = TIME()

cWhere = IIF(Empty(cCWork),"","  And  Inlist(ai_work.worker_id, "  + cCWork + ")" )

** 1. Pick up All Clients with most recent Outcomes, for selected Program (active program enrollments) and worker (if selected) 
 **VT 08/31/2010 Dev Tick 4807 add sort_name
Select Distinct ;
         ai_prog.tc_id, ;
         acd.completed_date, ;
         acd.next_due_date,;
         ICASE(acd.rec_type=1,"Comprehensive Assessment  ",;
               acd.rec_type=2,"Reassessment              ",;
                              "N/A                       ") AS out_type, ;
         PADR(oApp.FormatName(cli_cur.last_name, cli_cur.first_name),50) AS client_name, ;
         Upper(Alltrim(cli_cur.last_name+cli_cur.first_name)) AS c_sort_name, ;
         cli_cur.id_no, ;
         ai_prog.start_dt as prg_start, ;
         ai_work.worker_id,;
         PADR(oApp.FormatName(staffcur.last, staffcur.first, staffcur.mi),50) AS worker_name,;
         Upper(Alltrim(staffcur.last+staffcur.first+staffcur.mi)) AS w_sort_name, ;
         ai_prog.program, ;
         {  } as act_dt;
from ai_prog ;
   Inner join cli_cur on;
          cli_cur.tc_id = ai_prog.tc_id ;   
   Inner Join ai_work On ;
          ai_prog.tc_id = ai_work.tc_id ;
      And Empty(ai_prog.end_dt) ;    
      And ai_prog.program = ai_work.program ;
      And Between(ai_work.effect_dt, ai_prog.start_dt, Date());
   Inner Join staffcur On ;
          ai_work.worker_id = staffcur.worker_id ;       
   Inner join  ai_cobra_outcome_header ach on ;
          ai_prog.tc_id = ach.tc_id ; 
   Inner join  ai_cobra_outcome_details acd on ;
          ach.ai_outh_id = acd.ai_outh_id ; 
Where ai_prog.program = LCProg ;
      And Between(acd.next_due_date, dDate_from, dDate_to) ;
      And ai_work.effect_dt in (Select Max(aw.effect_dt);
                                 From ai_work aw;
                                      Inner Join ai_prog ap On ;
                                             ap.tc_id = aw.tc_id ;
                                         And ap.program = aw.program ;
                                         And Empty(ap.end_dt) ;
                                         And Between(aw.effect_dt, ap.start_dt, Date());
                               Where aw.tc_id=ai_work.tc_id;
                                 And aw.program=ai_work.program;
                              Group By aw.ps_id);
      &cWhere ;
Into Cursor t_out 

Select * ;
From t_out ;
Where completed_date  in (Select Max(completed_date) ;
                          From t_out tc ;
                          Where tc.tc_id = t_out.tc_id) ;
Into Cursor t_all Readwrite
               
Use In t_out
               
=openFile("AI_enc","Tc_id_act")
Set Filter To !Empty(AI_enc.act_dt)
   
Select t_all
Scan
*****   LAST DATE SERVICES PROVIDED  ******
   If Seek(t_all.tc_id,   "ai_enc")
        Select ai_enc
        Locate For ai_enc.program = t_all.program While ai_enc.tc_ID = t_all.tc_id And Not EOF()
        If Found('ai_enc')
           Select t_all 
           Replace t_all.act_dt With ai_enc.act_dt
        Endif
   Endif
Endscan
       
Select ai_enc
Set Filter To

***Order by  
cOrder = '' 
**VT 08/31/2010 Dev Tick 4807 add sort_name
Do Case
   Case nOrder = 1  
       ** cOrder = ' worker_name, client_name, next_due_date'
        cOrder = ' w_sort_name, c_sort_name, next_due_date desc'
   Case nOrder = 2
        **cOrder = ' worker_name, next_due_date, client_name'
        cOrder = ' w_sort_name, next_due_date desc, c_sort_name'
Endcase


Select *, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime ;
from t_all ;
Into Cursor cobra_com  ;
Order By &cOrder

Use In t_all

oApp.msg2user("OFF") 
gcRptName = 'rpt_cobra_coming'    
            
Select cobra_com  

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_cobra_coming To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.   
                    oApp.rpt_print(5, .t., 1, 'rpt_cobra_coming', 1, 2)
           ENDCASE
EndIf


