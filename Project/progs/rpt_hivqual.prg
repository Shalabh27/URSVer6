Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

lcProg   = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
EndFor

If lcProg='All' or Empty(lcProg)
   oApp.msg2user('INFORM','Please Select a Program')
   Return
Endif

cTitle = 'Quality Sample Patient Listing'
gcHelp = 'Quality Sample Patient Listing Screen'
lcontinue=.t.
Do Case
   Case Empty(date_from) or Empty(date_to)
      lcontinue=.f.
   Case Year(date_from) <> Year(date_to)
      lcontinue=.f.
   Case Year(date_from) > Year(Date())
      lcontinue=.f.   
   Case Year(date_from) < 2000
      lcontinue=.f.   
   Case Right(Dtos(date_from),4) <> '0101' or Right(Dtos(date_to),4) <> '1231'
      lcontinue=.f.   
EndCase

If lcontinue=.f.
   oApp.msg2user('INFORM','Start and End Dates must be first and last Day of Report Year between 2000 and last year')
   Return
Endif
   
oWait.lbl_message.Caption='Please wait...loading data'
oWait.center_form_on_top()
oWait.Refresh()
oWait.Show()


*gcserv_cat='00002'
* jss, 5/1/07, we are now using a list of service categories because 00032, 00036, and 00037 were broken out of 00002
gcserv_cat_list='00002 00032 00036 00037'
If !Used('lv_program_filtered')
   Use lv_program_filtered In 0
EndIf

If !Used('lv_hivq_serv')   
   **VT 03/31/2008 Dev Tick 4162
   **   Use lv_hivq_serv in 0
   ldStart = Date_from
   ldEnd = Date_to
   =OpenView('lv_hivq_serv')
Endif   


oWait.lbl_message.ResetToDefault('caption')
oWait.Hide()

* grab the program descript
Select descript from program where prog_id=lcprog into array aprog
cprogdesc=aprog(1)

* get a list of all clients who have had 2 or more ambulatory care visits (cadr_map='33A') in selected program

* first, get only one row per date per client
Select tc_id, act_dt ;
  from lv_hivq_serv ;
 where Between(act_dt,date_from,date_to) ;
   and program=lcProg ;
 Group by 1, 2 ;
  Into Cursor FullYear1

* now, find out how many clients have 2 or more visits
Select tc_id ;
  from FullYear1 ;
Group by tc_id ;
Having Count(*) > 1 ;
  Into Cursor FullYear

* which of these have at least one visit in last half of year? this is our report pool
dhalf1end  =Ctod('06/30/'+Alltrim(Str(Year(date_to))))
dhalf2start=Ctod('07/01/'+Alltrim(Str(Year(date_to))))

Select Distinct tc_id, client_id, id_no, client_mf ;
  from lv_hivq_serv ;
 where Between(act_dt,dhalf2start,date_to) ;
   and tc_id in (Select tc_id from FullYear) ;
  Into Cursor HalfYear

If _tally=0
   oApp.Msg2User("INFORM","No clients found for entered criteria")
   Return
Endif

* grab all visits in year for clients
Select Distinct ;
   lv_hivq_serv.id_no   as id_no, ;
   lv_hivq_serv.act_dt  as visitdate ;
From ;
   halfyear ;
     Join lv_hivq_serv on halfyear.tc_id=lv_hivq_serv.tc_id ;
Where ;
      Year(lv_hivq_serv.act_dt)=Year(date_to) ;  
  and lv_hivq_serv.program=lcProg ;
Into Cursor ;
   curVis ;
Order by ;
   1,2 

* get first and second half year visits for each client
Select   id_no as id_no, ;
         Sum(Iif(Between(visitdate, date_from, dhalf1end) ,1,0)) As Visits_1, ;
         Sum(Iif(Between(visitdate, dhalf2start,date_to) ,1,0)) As Visits_2 ;
From  curvis ;
Group By 1 ;
Into Cursor t_visits

cdate=Dtoc(Date())
cTime=Time()

* get client info
Select ;
   halfyear.tc_id               as tc_id, ;
   halfyear.client_id           as client_id, ;
   halfyear.id_no               as id_no, ;
   lcprog                       as cprogram, ;
   cprogdesc                    as cprogdesc, ;
   client.last_name             as last_name, ;
   client.first_name            as first_name, ;
   client.mi                    as mi, ;
   halfyear.client_mf           as gender, ;
   client.dob                   as dob, ;
   00                           as payor, ;
   client.ssn                   as ssn ;
From ;
   halfyear ;
 Join ;
   client on halfyear.client_id=client.client_id ;
Into Cursor ;
   temppat Readwrite

* decrypt encrypted fields, if necessary   
If oApp.gldataencrypted
   =oApp.d_encrypt_table_data('temppat',.t.)   
EndIf

Select temppat

Scan
   =getpayor()
EndScan

Select ;
   Name(temppat.last_name, temppat.first_name, temppat.mi) as Name, ;   
   temppat.id_no  as id_no, ;
   temppat.gender as gender, ;
   temppat.dob    as dob, ;
   temppat.ssn    as ssn, ;
   Padr(ICase(temppat.payor=1,'ADAP',temppat.payor=2,'Commercial',temppat.payor=3,'Corrections',temppat.payor=4,'Government', ;
              temppat.payor=5,'HMO', temppat.payor=6,'Medicaid',temppat.payor=7,'Medicaid Managed Care',temppat.payor=8,'Medicare', ;
              temppat.payor=9,'Self-Pay',temppat.payor=10,'Unknown','Unknown'),21) as payor, ;  
   temppat.cprogram  as cprogram, ;
   temppat.cprogdesc as cprogdesc, ;
   t_visits.visits_1 as visits_1, ;
   t_visits.visits_2 as visits_2, ;
   ctitle            as ctitle, ;
   cDate             as cDate, ;
   cTime             as cTime, ;
   dHalf1end         as date_1end, ;
   dhalf2start       as date_2start, ;
   Date_from         as date_from,;
   Date_to           as date_to ;
From ;
   temppat ;
  Join ;
     t_visits on temppat.id_no = t_visits.id_no ; 
Into cursor ;
   rpt_hivqual ;
Order by 3, 1
  
gcRptName = 'rpt_hivqual'
gcRptAlias = 'rpt_hivqual'

Select rpt_hivqual
Go top

oApp.msg2user('OFF')

IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   DO CASE 
      Case lPrev = .f.
         Report Form rpt_hivqual To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.     
         oApp.rpt_print(5, .t., 1, 'rpt_hivqual', 1, 2)
   EndCase 
Endif

RETURN

* determine the client's payor
*****************
Function GetPayor
*****************

* these are the payor codes for HIVQ and their AIRS counterparts in InsType:
* 1: Adap                        '07' (ADAP)
* 2: Commercial                  '04'(Private), '11'(Blue Shield), '12'(Blue Cross)
* 3: Corrections                  none
* 4: Government                  '08' (Military/VA)
* 5: HMO                         '05' (HMO Managed Care)
* 6: Medicaid                    '01' (Medicaid) 
* 7: Medicaid Managed Care       '02' (Medicaid Managed Care)
* 8: Medicare                    '03' (Medicare)
* 9: Self-Pay                    '06' (Self-pay)  
* 10: Unknown                    '09' (Medicaid Pending), '10' (Workers Comp), '99' (Other)




* grab the payor from insstat/medprov
cClient_id=temppat.client_id

* grab the latest insstat record
Select InsStat.prov_id  as prov_id, ;
       med_prov.instype as instype ;
  From InsStat ;
     Join Med_Prov on InsStat.prov_id=Med_prov.prov_id ;
 Where InsStat.client_id=cClient_id ;
   and InsStat.Prim_sec=1 ;
   and (Empty(InsStat.Exp_dt) or InsStat.Exp_dt > date_to) ;
   and InsStat.client_id + Dtos(InsStat.Effect_dt) + InsStat.InsStat_id in ;
       (Select Inss.client_id + Max(Dtos(inss.Effect_dt) + inss.insstat_id) ;
          From InsStat Inss ;
         Where Inss.client_id = cClient_id ;
           and Inss.Prim_sec=1 ;
           and (Empty(Inss.Exp_dt) or Inss.Exp_dt > date_to) ;
           and Inss.Effect_dt <= date_to ;
         Group by Inss.client_id) ;
  Into Array ;
     atemprov

* translate the instype into HIVQual
cPayor=10
cprov_id='     '         
If _Tally>0
   cprov_id=atemprov(1)
   cInsType=atemprov(2)
   Do Case
      Case cInstype='01'
         cPayor=6
      Case cInstype='02'
         cPayor=7
      Case cInstype='03'
         cPayor=8
      Case cInstype='04' OR cInstype='11' OR cInstype='12'
         cPayor=2
      Case cInstype='05'
         cPayor=5
      Case cInstype='06'
         cPayor=9
      Case cInstype='07'
         cPayor=1
      Case cInstype='08'
         cPayor=4
      Case cInstype='09' OR cInstype='10' OR cInstype='99'
         cPayor=10
   EndCase
Endif
Release aTempprov
Select temppat
Replace Payor with cPayor
   