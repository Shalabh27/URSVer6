Parameters;
      lPrev, ;    && Preview
      aSelvar1, ; && select parameters from selection list
      nOrder, ;   && order by
      nGroup, ;   && report selection
      lcTitle, ;  && report selection
      dDate_from , ; && from date
      dDate_to, ; && to date
      cCrit , ;   && name of param
      lnStat, ;   && selection(Output)  page 2
      cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)

lcProg   = ""

&& Search For Parameters
For i = 1 To Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   Endif
Endfor

If lcProg='All' Or Empty(lcProg)
   oApp.msg2user('INFORM','Please Select a Program')
   Return
Endif

cTitle = 'PCP Status Review'
gcHelp = 'PCP Status Review Screen'

lclose_max=.f.
If !Used('lv_max_pcp_visits')
   =OpenFIle('lv_max_pcp_visits')
   lclose_max=.t.
EndIf

=OpenFIle('client_pcp')
Select client_pcp
Replace date_visited With {} All
Update client_pcp From lv_max_pcp_visits Set client_pcp.date_visited=lv_max_pcp_visits.visit_date Where client_pcp.pcp_id=lv_max_pcp_visits.client_pcp_id

If lclose_max=(.t.)
   Use In lv_max_pcp_visits
EndIf 


lcontinue=.T.
Do Case
   Case Empty(dDate_from)
      lcontinue=.F.
   Case dDate_from > Date()
      lcontinue=.F.
   Case dDate_from < {01/01/2000}
      lcontinue=.F.
Endcase

If lcontinue=.F.
   oApp.msg2user('INFORM','Please enter date between 1/1/2000 and today')
   Return
Endif

* run form to allow user to enter number of days since last PCP history
nDays=0
Do Form pcp_select2 To nDays


***VT 11/14/2011 AIRS-183
oldgcTC_id=gcTC_id
gcTC_id =''
=OpenView("lv_verification_filtered", "urs")
Requery('lv_verification_filtered')
gcTC_id=oldgcTC_id

** Create cursor
If Used('all_pcp')
   Use In all_pcp
Endif

Create Cursor all_pcp (tc_id C(10), date_asked D, date_visited D)

**Fiind most recent verified date

** GOxford 3/28/12 Query using parameter dDate_to which is no longer part of the report interface
** Because of blank parameter, query always returned no records

*|* Select Max(lvf.verified_datetime) as verified_datetime, ;
*|*       lvf.tc_id ;
*|* from lv_verification_filtered lvf ;
*|*     inner join client_pcp af on ;
*|*                lvf.tc_id = af.tc_id ;
*|*             and lvf.vn_category="I" ;
*|*           and Between(lvf.verified_datetime, dDate_from, dDate_to) ;
*|*           and af.have_pcp=1 ;
*|* Group by lvf.tc_id ;
*|* into cursor tmp_dt

Select Max(lvf.verified_datetime) As verified_datetime, ;
   lvf.tc_id ;
from lv_verification_filtered lvf ;
inner Join client_pcp af On ;
   lvf.tc_id = af.tc_id ;
   and lvf.vn_category="I" ;
   and Between(lvf.verified_datetime, dDate_from, Date()) ;
   and af.have_pcp=1 ;
Group By lvf.tc_id ;
into Cursor tmp_dt

** GOxford END 3/28/12

If _Tally > 0

*!*      Insert Into all_pcp ;
*!*         ( tc_id, ;
*!*         date_asked,;
*!*         date_visited) ;
*!*         Select Distinct ;
*!*         client_pcp.tc_id, ;
*!*         client_pcp.date_asked, ;
*!*         client_pcp.date_visited ;
*!*      from lv_verification_filtered lvf ;
*!*      inner Join tmp_dt td On ;
*!*         lvf.tc_id = td.tc_id ;
*!*         and lvf.verified_datetime = td.verified_datetime ;
*!*      inner Join client_pcp On ;
*!*         client_pcp.pcp_id =lvf.table_id ;
*!*         and have_pcp=1

   Insert Into all_pcp ;
     (tc_id, ;
      date_asked,;
      date_visited) ;
      Select Distinct ;
      client_pcp.tc_id, ;
      client_pcp.date_asked, ;
      {} ;
   from lv_verification_filtered lvf ;
   inner Join tmp_dt td On ;
      lvf.tc_id = td.tc_id ;
      and lvf.verified_datetime = td.verified_datetime ;
   inner Join client_pcp On ;
      client_pcp.pcp_id =lvf.table_id ;
      and have_pcp=1;
   Where lvf.vn_category="I" ;
   
Endif

Use In tmp_dt
** GOxford 3/28/12 Query using parameter dDate_to which is no longer part of the report interface

*|*                 Select    tc_id, ;
*|*                           Max(date_asked) as date_asked ;
*|*                 FROM  client_pcp ;
*|*                  where client_pcp.tc_id not in (Select tc_id from all_pcp)     ;
*|*                        and  Between(date_asked, dDate_from, dDate_to) ;
*|*                        and have_pcp=1 ;
*|*                 Group by tc_id ;
*|*                into cursor tmp_dt

Select tc_id, ;
   Max(date_asked) As date_asked ;
FROM  client_pcp ;
where client_pcp.tc_id Not In (Select tc_id From all_pcp)     ;
   and  Between(date_asked, dDate_from, Date()) ;
   and have_pcp=1 ;
Group By tc_id ;
into Cursor tmp_dt

** GOxford END 3/28/12

If _Tally > 0

** GOxford 3/28/12 Typo in table name: client_pc --> client_pcp
** Missing table specifiers for tc_id, date_asked, date_visited

*|*               Insert into all_pcp ;
*|*                              ( tc_id, ;
*|*                             date_asked,;
*|*                             date_visited) ;
*|*                       Select distinct ;
*|*                                tc_id, ;
*|*                             date_asked,;
*|*                             date_visited ;
*|*                from client_pc af ;
*|*                      inner join tmp_dt td on ;
*|*                          af.tc_id = td.tc_id ;
*|*                      and af.date_asked = td.date_asked

   Insert Into all_pcp ;
      ( tc_id, ;
      date_asked,;
      date_visited) ;
   Select Distinct ;
      af.tc_id, ;
      af.date_asked,;
      af.date_visited ;
   from client_pcp af ;
   inner Join tmp_dt td On ;
      af.tc_id = td.tc_id ;
      and af.date_asked = td.date_asked
** GOxford END 3/28/12

Endif

Use In tmp_dt


***VT 11/14/2011 AIRS-183
* maxpcp gives us a cursor of client's latest "client_pcp" record
*!*   Select ;
*!*      tc_id, ;
*!*      Max(date_asked) as date_asked ;
*!*   From ;
*!*      client_pcp ;
*!*   Group by ;
*!*      tc_id ;
*!*   Into cursor ;
*!*        maxpcp

* find out which client's latest client_pcp record has a "Yes" answer for "Do you have a PCP?"
*!*   Select * ;
*!*   From client_pcp ;
*!*   Where have_pcp=1 ;
*!*     and tc_id+Dtos(date_asked) in ;
*!*        (Select tc_id + Dtos(date_asked) from maxpcp) ;
*!*   Into Cursor ;
*!*      havepcp

* select client's with pcp's which have had services in selected program since date_from
*!*   Select Distinct ;
*!*      tc_id ;
*!*   From ;
*!*      ai_enc ;
*!*   Where ;
*!*         ai_enc.program = lcprog ;
*!*     and ai_enc.act_dt >= ddate_from ;
*!*     and ;
*!*      ai_enc.tc_id in ;
*!*         (Select tc_id from havepcp);
*!*   Into Cursor ;
*!*     cliwserv

Select Distinct ;
   tc_id ;
From ai_enc ;
Where ;
   ai_enc.Program = lcProg ;
   and ai_enc.act_dt >= dDate_from ;
   and ;
   ai_enc.tc_id In (Select tc_id From all_pcp);
Into Cursor ;
cliwserv

***VT 11/14/2011 AIRS-183 changed havepcp on cliwserv.tc_id = havepcp.tc_id ;  to  all_pcp  havepcp on cliwserv.tc_id = havepcp.tc_id ;

* get client's id and name
Select ;
   cliwserv.tc_id As tc_id, ;
   ai_clien.id_no As id_no, ;
   client.last_name As last_name, ;
   client.first_name As first_name, ;
   client.mi As mi, ;
   havepcp.date_asked As date_asked, ;
   havepcp.date_visited As date_visited, ;
   Date()-havepcp.date_asked As numdayshis, ;
   Date()-havepcp.date_visited As numdaysvis ;
From cliwserv ;
  join all_pcp  havepcp On cliwserv.tc_id = havepcp.tc_id ;
  join ai_clien On cliwserv.tc_id = ai_clien.tc_id ;
  join client On ai_clien.client_id=client.client_id ;
Into Cursor cliwserv1 Readwrite

***VT 11/14/2011 AIRS-183
Use In all_pcp

* decrypt encrypted fields, if necessary
If oApp.gldataencrypted
   =oApp.d_encrypt_table_data('cliwserv1',.T.)
Endif

cdate=Dtoc(Date())
cTime=Time()

**VT 08/31/2010 Dev Tick 4807 add sort_name
Select ;
   id_no As id_no, ;
   Upper(Alltrim(last_name+first_name+mi)) As sort_name, ;
   date_asked As date_asked, ;
   numdayshis As numdayshis, ;
   date_visited As date_visited, ;
   numdaysvis As numdaysvis, ;
   oApp.FormatName(last_name,first_name,mi) As Name, ;
   cdate As cdate, ;
   cTime As cTime, ;
   dDate_from As date_from, ;
   Alltrim(cCrit) As crit ;
From cliwserv1 ;
Where numdayshis >= nDays ;
Into Cursor rpt_pcprev ;
Order By 3 Desc, 2

gcRptName = 'rpt_pcprev'
gcRptAlias = 'rpt_pcprev'

Select rpt_pcprev
Go Top

oApp.msg2user('OFF')

If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   Do Case
   Case lPrev = .F.
      Report Form rpt_pcprev To Printer Prompt Noconsole Nodialog
   Case lPrev = .T.
      oApp.rpt_print(5, .T., 1, 'rpt_pcprev', 1, 2)
   Endcase
Endif

Return

