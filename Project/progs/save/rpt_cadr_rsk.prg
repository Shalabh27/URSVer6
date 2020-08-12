Parameters;
   lprev, ;     && Preview
   aselvar1, ;  && select parameters from selection list
   norder, ;    && order by
   ngroup, ;    && report selection
   lctitle, ;   && report selection
   ddate_from ,;  && from date
   ddate_to, ;    && to date
   crit , ;     && name of param
   lnstat, ;    && selection(Output)  page 2
   corderby     && order by description

Acopy(aselvar1, aselvar2)

lcprog = ""
&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "LCPROG"
      lcprog = aselvar2(i, 2)
   Endif
Endfor

Private gchelp
gchelp = "Generating Clients w/o Risk History Data Report"
ctitle="Clients w/o Risk History Data Report"

cdate = Date()
ctime = Time()

* jss, 9/13/05, order by name (2,3,4) or id # (1)
If norder=1
   orderby='2,3,4'
Else
   orderby='1'
Endif
******************
* first, find all clients who have had an encounter in selected program this period; if no program was selected, get all RW-Eligible programs
If Used('enc_tmp')
   Use In enc_tmp
Endif

=OpenView('lv_relhist_vn')
=OpenView("lv_enc_type", "urs")
=OpenView("lv_service", "urs")

If !Empty(lcprog)
   Select;
      ai_enc.tc_id, ;
      ai_enc.act_id, ;
      ai_enc.serv_cat, ;
      ai_enc.enc_id, ;
      lv_enc_type.cadr_map ;
   From ai_enc, lv_enc_type ;
   Where ai_enc.Program = lcprog ;
      And ai_enc.serv_cat = lv_enc_type.serv_cat ;
      And ai_enc.enc_id = lv_enc_type.enc_id ;
      And Between(ai_enc.act_dt, ddate_from, ddate_to);
   Into Cursor enc_tmp
Else
   Select;
      ai_enc.tc_id, ;
      ai_enc.act_id, ;
      ai_enc.serv_cat, ;
      ai_enc.enc_id, ;
      lv_enc_type.cadr_map ;
   From ai_enc, ;
      lv_enc_type ;
   Where ai_enc.Program In (Select prog_id ;
                            From Program  ;
                            Where elig_type<>"03" ;
                               And elig_type<>"04") ;
      And ai_enc.serv_cat = lv_enc_type.serv_cat ;
      And ai_enc.enc_id = lv_enc_type.enc_id ;
      And Between(ai_enc.act_dt, ddate_from, ddate_to);
   Into Cursor enc_tmp
Endif

If Used('t_serv')
   Use In t_serv
Endif

* next, select all clients in the above encounters with services mapped to "33A"
Select;
   ai_serv.tc_id, ;
   ai_serv.act_id ;
From ai_serv, enc_tmp, lv_service ;
Where ai_serv.act_id = enc_tmp.act_id ;
   And enc_tmp.serv_cat = lv_service.serv_cat ;
   And (enc_tmp.enc_id = lv_service.enc_id Or Empty(lv_service.enc_id)) ;
   And ai_serv.service_id = lv_service.service_id ;
   And !Empty(lv_service.cadr_map) ;
   And Alltrim(lv_service.cadr_map) = "33A" ;
   And Between(ai_serv.Date, ddate_from, ddate_to);
Into Cursor t_serv

* now, combine the clients with "33A" services with those with "33A" encounters w/o services
If Used('serv_tmp')
   Use In serv_tmp
Endif

Select tc_id ;
From t_serv ;
Union ;
Select tc_id ;
From enc_tmp ;
Where Alltrim(cadr_map) == "33A" ;
   And act_id Not In (Select act_id From t_serv) ;
Into Cursor serv_tmp

Use In enc_tmp
Use In t_serv

** Create cursor
If Used('all_risk')
   Use In all_risk
Endif

Select 0
Create Cursor all_risk (tc_id C(10), riskunknow N(1,0))

**Find most recent verified date
Insert Into all_risk (tc_id, riskunknow) ;
Select Distinct ;
  relhist.tc_id, ;
  Iif(relhist.rw_code='08', 1, 0) As riskunknow;
From relhist;
Join lv_relhist_vn On lv_relhist_vn.tc_id=relhist.tc_id;
   And lv_relhist_vn.date=relhist.date;
Where (Between(lv_relhist_vn.date, ddate_from, ddate_to) ;
       Or Between(lv_relhist_vn.vn_date, ddate_from, ddate_to) ;
       Or Between(lv_relhist_vn.vn_date2, ddate_from, ddate_to))

**If date verified not entered  -> most recent record from relhist.date

*!*   Select Max(af.Date) As rel_date, ;
*!*      af.tc_id ;
*!*   From serv_tmp ;
*!*   Inner Join relhist af On serv_tmp.tc_id = af.tc_id  ;
*!*         And Not Between(af.Date, ddate_from, ddate_to) ;
*!*   Where serv_tmp.tc_id Not In (Select tc_id From all_risk);
*!*   Group By af.tc_id ;
*!*   Into Cursor tmp_dt

*!*   If _Tally > 0
*!*      Insert Into all_risk (tc_id, riskunknow) ;
*!*      Select Distinct ;
*!*         af.tc_id, ;
*!*         Iif(af.rw_code='08', 1, 0);
*!*      From relhist af ;
*!*      Inner Join tmp_dt td On af.tc_id = td.tc_id ;
*!*         And af.Date = td.rel_date
*!*   Endif

*!*   Use In tmp_dt

* now, create a cursor of the latest risk histories for all clients
***VT 11/03/2011 AIRS-183
*!*   If Used('allrisk')
*!*      Use In allrisk
*!*   Endif
*!*
*!*   Select * ;
*!*   From    relhist ;
*!*   Where date <= dDate_to ;
*!*     and tc_id+DTOS(date) IN ;
*!*                  (Select r2.tc_id+Max(DTOS(r2.date)) ;
*!*                  From relhist r2 ;
*!*                  Where r2.date <= dDate_to ;
*!*                  Group by r2.tc_id) ;
*!*   Into Cursor allrisk


* get any clients with NO risk history entered prior to report end date (N), AS WELL AS those clients with "Risk Exposure Unknown" entered (U)
* jss, 9/13/05, add client's name to report, order by last name, first name, mi
If Used('ReportCur')
   Use In reportcur
Endif

***VT 11/03/2011 AIRS-183  changed  allrisk)  to all_risk
Select '(N) ' + ai_clien.id_no As id_no, ;
   Space(50) As cl_name, ;
   ai_clien.client_id, ;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime, ;
   ai_clien.id_no As cl4sort;
From ai_clien, serv_tmp ;
Where ai_clien.tc_id = serv_tmp.tc_id ;
   And ai_clien.tc_id Not In (Select tc_id From all_risk) ;
Union ;
Select '(U) ' + ai_clien.id_no As id_no, ;
   Space(50) As cl_name, ;
   ai_clien.client_id, ;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime, ;
   ai_clien.id_no As cl4sort;
From ai_clien, serv_tmp ;
Where ai_clien.tc_id = serv_tmp.tc_id ;
   And ai_clien.tc_id In (Select tc_id From all_risk Where riskunknow=1);
Into Cursor reportcur Readwrite;
Order By 3

***VT 11/03/2011 AIRS-183
**Use in allrisk
Use In all_risk
Use In serv_tmp

oapp.msg2user("OFF")

gcrptname = 'rpt_cadr_cl'
Select reportcur
Go Top
If Eof()
   oapp.msg2user('INFORM', 'No Clients Found Meeting Selection Criteria')
Else
   Select reportcur
   Go Top
   Scan
      If Seek(reportcur.client_id,'cli_cur','client_id')
         Replace reportcur.cl_name With oapp.formatname(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)
      Endif
   Endscan

   *!* VT 08/27/2010 Dev Tick 4807
   If norder=1
      Index on Upper(cl_name)+Padl(Alltrim(cl4sort),20,' ') Tag fn
*     Index On Upper(Alltrim(cl_name))+Alltrim(client_id) Tag fn  && VT 08/27/2010 Dev Tick 4807
   Else
      Index on Padr(Alltrim(id_no),20,' ') Tag fn
*     Index On Upper(Padl(id_no,10,'0')) Tag fn  && VT 08/27/2010 Dev Tick 4807
   Endif

   Select reportcur
**VT 08/27/2010 Dev Tick 4807
   Set Order To fn
   Go Top

   Do Case
   Case lprev = .F.
      Report Form rpt_cadr_cl To Printer Prompt Noconsole Nodialog
   Case lprev = .T.
      oapp.rpt_print(5, .T., 1, 'rpt_cadr_cl', 1, 2)
   Endcase
Endif
