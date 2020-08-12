Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              dDate_from , ;        && from date
              dDate_to, ;           && to date   
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

cTitle = 'CD4/Viral Load Test Status Review'
gcHelp = 'CD4/Viral Load Test Status Review Screen'

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

* run form to allow user to enter number of days since last CD4/Viral Load Test
nDays=0
Do Form pcp_select6 To nDays

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

* select clients with CD4/Viral Load tests which have had services in selected program since date_from
Select Distinct ;
   tc_id ;
From ;
   ai_enc ;
Where ;
      ai_enc.program = lcprog ;
  and ai_enc.act_dt >= ddate_from ;
  and ;
   ai_enc.tc_id in ;
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
   maxtest.testdate             as testdate, ;
   Date()-maxtest.testdate      as numdays ;
From ;
   cliwserv ;
  join ;
   maxtest on cliwserv.tc_id = maxtest.tc_id ;
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

cdate=Dtoc(Date())
cTime=Time()

 **VT 08/31/2010 Dev Tick 4807 add sort_name
 
Select ;
   id_no                         as id_no, ;
   Upper(Alltrim(last_name+first_name+mi)) as sort_name, ;
   testdate                      as testdate, ;
   numdays                       as numdays, ;
   oApp.FormatName(last_name,first_name,mi) as name, ;
   cdate                         as cdate, ;
   ctime                         as ctime, ;
   ddate_from                    as date_from, ;
   Alltrim(ccrit)                as crit ;
From cliwserv1 ;
Where numdays >= ndays ;
Into Cursor ;
   rpt_cdrev ;
Order by ;
   3 desc, 2
   
gcRptName = 'rpt_cdrev'
gcRptAlias = 'rpt_cdrev'

Select rpt_cdrev
Go top

oApp.msg2user('OFF')

If EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   Do Case
      Case lPrev = .f.
         Report Form rpt_cdrev To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.     
         oApp.rpt_print(5, .t., 1, 'rpt_cdrev', 1, 2)
   Endcase
Endif

Return

