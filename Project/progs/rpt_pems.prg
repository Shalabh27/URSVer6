**************************************************
*** PEMS Planning Data Report
*** display just active contracts as of today
**************************************************
Parameters ;
   lPrev,;       && Preview     
   aSelvar1,;    && select parameters from selection list
   nOrder,;      && order by
   nGroup,;      && report selection    
   lcTitle,;     && report selection    
   Date_from1,;  && from date
   Date_to,;     && to date   
   Crit,;        && name of param
   lnStat,;      && selection(Output)  page 2
   cOrderBy      && order by description

If lnStat=(2) And (Date_from1 <> Date())
   oApp.msg2user("IMPORTANT",'This version of the report is not historical.'+Chr(13)+;
                             "The 'As Of Date' has been changed to today's date.")
   Date_from1=Date()
EndIf 

Acopy(aSelvar1, aSelvar2)

Local cWhere, lcProg

As_Of_D = Date_from1

lcProg = ''
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gchelp
gchelp='PEMS Planning Data'
lcTitle = Iif(lnStat=1,'Planning Data Report','Planning Data Report - Active Services Only')
cDate = DATE()
cTime = TIME()

**VT 03/27/2009 Dev Tick 5270
*=OpenView("lv_pems2urs", "urs")
*SELECT lv_pems2urs

cWhere = ''
*cWhere = IIF(EMPTY(lcProg),""," lv_pems2urs.prog_id = lcProg")

cWhere = IIF(EMPTY(lcProg),""," and  Pems2urs.prog_id = lcProg")

*!*   cWhere = Iif(!Empty(cWhere), cWhere  +  ;
*!*             " And lv_pems2urs.start_date <= As_Of_D and (Empty(lv_pems2urs.end_date) Or lv_pems2urs.end_date >= As_Of_D) ", ;
*!*             " lv_pems2urs.start_date <= As_Of_D and (Empty(lv_pems2urs.end_date) Or lv_pems2urs.end_date >= As_Of_D) ") 
     
cWhere = Iif(!Empty(cWhere), cWhere  +  ;
          " And Ai_contract.start_date <= As_Of_D and (Empty(Ai_contract.end_date) Or Ai_contract.end_date >= As_Of_D) ", ;
          " And Ai_contract.start_date <= As_Of_D and (Empty(Ai_contract.end_date) Or Ai_contract.end_date >= As_Of_D) ") 

If Used('pems_data')
   use in pems_data
EndIf 
 
** VT 07/29/2009 add is_active and  pems2urs.startdate, pems2urs.enddate 
Select Pems2urs.pems2urs_id, Pems2urs.agency_id, Ai_contract.conno,;
       Pems2urs.prog_id, Pems2urs.model_id, Pems2urs.intervention_id,;
       Pems2urs.serv_cat, Pems2urs.enc_id, Pems2urs.service_id,;
       Pems2urs.user_id, Pems2urs.dt, Pems2urs.tm,;
       Intervention.name AS intervention, Model.modelname,;
       Serv_cat.descript AS service_category,;
       Program.descript AS program_name,;
       Serv_list.description AS service_decs,;
       Enc_list.description AS enc_desc, Ai_contract.start_date,;
       Ai_contract.end_date,;
       lcTitle as lcTitle, ;
       Crit as  Crit, ;    
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from1 as as_of_D, ;
       pems2urs.startdate as service_start, ;
       pems2urs.enddate as service_end, ;
       Iif(pems2urs.is_active=1, 'Y', 'N') as service_active;  
 From ;
      pems2urs ;
    INNER JOIN serv_cat ;
   ON  Pems2urs.serv_cat = Serv_cat.code ;
    INNER JOIN enc_list ;
   ON  Pems2urs.enc_id = Enc_list.enc_id ;
    INNER JOIN model ;
   ON  Pems2urs.model_id = Model.model_id ;
    INNER JOIN intervention ;
   ON  Pems2urs.intervention_id = Intervention.intervention_id ;
    INNER JOIN ai_contract ;
   ON  Pems2urs.contract_id = Ai_contract.ai_contract_id ;
    LEFT OUTER JOIN serv_list ;
   ON  Pems2urs.service_id = Serv_list.service_id ;
    LEFT OUTER JOIN program ;
   ON  Pems2urs.prog_id = Program.prog_id;
 WHERE  Pems2urs.agency_id = gcagency ;
        &cWhere ;
ORDER BY ;
   Program.descript, Serv_cat.descript, Ai_contract.conno, ;
   Pems2urs.model_id,Model.modelname, Pems2urs.intervention_id, Intervention.name,  ;
   Pems2urs.enc_id, Enc_list.description, Pems2urs.service_id, Serv_list.description, ;
   pems2urs.startdate ; 
INTO CURSOR ;
   pems_data 

Select pems_data 
If lnStat=2
   Set Filter To Between(As_Of_D,service_start,service_end) And service_active=='Y'
EndIf 
Go Top

oApp.Msg2User("OFF")

If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   gcRptName = 'rpt_pems'
   Do Case
      Case lPrev = .f.
          Report Form rpt_pems  To Printer Prompt Noconsole NODIALOG
          
      Case lPrev = .t.     &&Preview
          oApp.rpt_print(5, .t., 1, 'rpt_pems', 1, 2)
          
   EndCase
EndIf
Return 