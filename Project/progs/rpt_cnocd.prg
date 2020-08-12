Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              dDate_from , ;         && from date
              dDate_to, ;            && to date   
              cCrit , ;             && name of param
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

cTitle = 'Clients with NO CD4 or Viral Load Tests: Referral Status Review'
gcHelp = 'Clients with NO CD4 or Viral Load Tests: Referral Status Review Screen'

lcontinue=.t.
Do Case
   Case Empty(ddate_from)
      lcontinue=.f.
   Case ddate_from > Date()
      lcontinue=.f.
   Case ddate_from < {01/01/2000}
      lcontinue=.f.   
EndCase

If lcontinue=.f.
   oApp.msg2user('INFORM','Please enter date between 1/1/2000 and today')
   Return
Endif

* run form to allow user to enter number of days w/o confirmation to limit report   
nDays=0
Do Form pcp_select5 To nDays

* maxtest gives us a cursor of client's latest "testres" viral load or cd4 test
Select ;
   tc_id, ;
   Max(testdate) as testdate ;
From ;
   testres ;
Where testtype='05' or testtype='06' ;   
Group by ;
   tc_id ;
Into cursor ;
     maxtest

* select client's with NO viral load or CD4 tests which have had services in selected program since date_from
Select Distinct ;
   tc_id ;
From ;
   ai_enc ;
Where ;
      ai_enc.program = lcprog ;
  and ai_enc.act_dt >= ddate_from ;
  and ;
   ai_enc.tc_id NOT in ;
      (Select tc_id from maxtest); 
Into Cursor ;
  cliwserv
  
  
* get client's id and name
Select ;
   cliwserv.tc_id               as tc_id, ;
   ai_clien.id_no               as id_no, ;
   client.last_name             as last_name, ;
   client.first_name            as first_name, ;
   client.mi                    as mi, ;
   '   '                        as ref_made, ;
   '   '                        as ref_confirm, ;
   000                          as numdays, ;
   {}                           as ref_dt, ;
   {}                           as verif_dt ;
From ;
   cliwserv ;
  join ;
   ai_clien on cliwserv.tc_id = ai_clien.tc_id ;
  join ;
   client   on ai_clien.client_id=client.client_id ;
Into Cursor ;
  cliwserv1 Readwrite

* decrypt encrypted fields, if necessary   
If oApp.gldataencrypted
   =oApp.d_encrypt_table_data('cliwserv1',.t.)   
EndIf

Select cliwserv1

* roll through cursor, find out which have referrals, confirmed referrals, and days since referral
Scan
   ctc_id=tc_id
   =GetRef(ctc_id)
Endscan

cdate=Dtoc(Date())
cTime=Time()

* now, get 
*      1) clients with no referral
*      2) clients with referral and confirmation
*      3) clients with referrals, no confirmation for at least the entered days
Select ;
   id_no                         as id_no, ;
   oApp.FormatName(last_name,first_name,mi) as name, ;
   ref_made                      as ref_made, ;
   ref_confirm                   as ref_confirm, ;
   numdays                       as numdays, ;
   ref_dt                        as ref_dt, ;
   verif_dt                      as verif_dt ;
From cliwserv1 ;
Where ref_made='No ' ;
Union ;
Select ;
   id_no                         as id_no, ;
   oApp.FormatName(last_name,first_name,mi) as name, ;
   ref_made                      as ref_made, ;
   ref_confirm                   as ref_confirm, ;
   numdays                       as numdays, ;
   ref_dt                        as ref_dt, ;
   verif_dt                      as verif_dt ;
From cliwserv1 ;
Where ref_made   ='Yes' ;
  and ref_confirm='Yes' ;
Union ;
Select ;
   id_no                         as id_no, ;
   oApp.FormatName(last_name,first_name,mi) as name, ;
   ref_made                      as ref_made, ;
   ref_confirm                   as ref_confirm, ;
   numdays                       as numdays, ;
   ref_dt                        as ref_dt, ;
   verif_dt                      as verif_dt ;
From cliwserv1 ;
Where ref_made   ='Yes' ;
  and ref_confirm='No ' ;
  and numdays >= ndays ;
Into Cursor ;
   rpt_temp

 **VT 08/31/2010 Dev Tick 4807 add sort_name
Select ;
   id_no                         as id_no, ;
   Upper(name)                   as sort_name, ;
   ref_made                      as ref_made, ;
   ref_confirm                   as ref_confirm, ;
   numdays                       as numdays, ;
   ref_dt                        as ref_dt, ;
   verif_dt                      as verif_dt, ;
   name                          as name, ;
   cdate                         as cdate, ;
   ctime                         as ctime, ;
   ddate_from                    as date_from, ;
   Alltrim(ccrit)                as crit ;
From rpt_temp ;
Into Cursor ;
   rpt_cnocd ;
Order by ;
   3, 4, 5 desc, 2    
   
gcRptName = 'rpt_cnocd'
gcRptAlias = 'rpt_cnocd'

Select rpt_cnocd
Go top

oApp.msg2user('OFF')

If EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   Do Case
      Case lPrev = .f.
         Report Form rpt_cnocd To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.     
         oApp.rpt_print(5, .t., 1, 'rpt_cnocd', 1, 2)
   Endcase
Endif

Return

***************
Function GetRef
***************
Parameters xtc_id

dref_dt={}
dverif_dt={}
lref_made=.f.
lref_confirm=.f.
nnum_days=0

Select ref_dt, verif_dt ;
from ai_ref ;
Where tc_id = xtc_id ;
  and ref_cat='100' ;
  and (ref_for='012' or ref_for='020') ;
  and ref_dt >= ddate_from ;
Into Array aGetRef

If _tally > 0
  * referral found
   lref_made=.t.
   dref_dt=aGetRef(1)
   If !Empty(aGetRef(2))
  * referral confirmed
      lref_confirm=.t.
      dverif_dt=aGetRef(2)
   Else
  * calculate days since referral
      nnum_days=Date()-aGetRef(1)   
   Endif
EndIf
Release aGetRef

Select cliwserv1

Replace ref_made    with Iif(lref_made=.t.,    'Yes', 'No ')
Replace ref_confirm with Iif(lref_confirm=.t., 'Yes', 'No ')
Replace numdays     with nnum_days   
Replace ref_dt      with dref_dt
Replace verif_dt    with dverif_dt

Return
