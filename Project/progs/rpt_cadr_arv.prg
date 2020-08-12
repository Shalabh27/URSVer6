****************************************************
* Program:    Cliwoarv.prg
* Summary:    CADR Completeness Report: Clients w/o ARV Therapy Data
****************************************************
Parameters;
   lprev, ;      && Preview
   aselvar1, ;   && select parameters from selection list
   norder, ;     && order by
   ngroup, ;     && report selection
   lctitle, ;    && report selection
   ddate_from, ; && from date
   ddate_to, ;   && to date
   crit, ;       && name of param
   lnstat, ;     && selection(Output)  page 2
   corderby      && order by description

Acopy(aselvar1, aselvar2)

lcprog = ""
&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "LCPROG"
      lcprog = aselvar2(i, 2)
   Endif
Endfor

Private gchelp
gchelp = "Generating Clients w/o ARV Therapy Report"
ctitle="Clients w/o ARV Therapy Data Report"

If norder=1
   orderby='2,3,4'
Else
   orderby='1'
Endif

cdate = Date()
ctime = Time()

If Used('enc_tmp')
   Use In enc_tmp
Endif

* first, find all clients who have had an encounter in selected program this period; if no program was selected, get all RW-Eligible programs
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
   From ai_enc, lv_enc_type ;
   Where ai_enc.Program In (Select prog_id ;
                            From Program  ;
                            Where elig_type <> "03" And elig_type <> "04");
      And ai_enc.serv_cat = lv_enc_type.serv_cat ;
      And ai_enc.enc_id = lv_enc_type.enc_id ;
      And Between(ai_enc.act_dt, ddate_from, ddate_to);
   Into Cursor enc_tmp
Endif

If Used('t_serv')
   Use In t_serv
Endif

*!* #7571 include 33K encounter & services
Select;
   ai_serv.tc_id, ;
   ai_serv.act_id ;
From ai_serv, enc_tmp, lv_service ;
Where ai_serv.act_id = enc_tmp.act_id ;
   And enc_tmp.serv_cat = lv_service.serv_cat ;
   And (enc_tmp.enc_id = lv_service.enc_id Or Empty(lv_service.enc_id)) ;
   And ai_serv.service_id = lv_service.service_id ;
   And !Empty(lv_service.cadr_map) ;
   And (Alltrim(lv_service.cadr_map) == "33A" Or Alltrim(lv_service.cadr_map) == "33K") ;
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
Where (Alltrim(lv_service.cadr_map) == "33A" Or Alltrim(lv_service.cadr_map) == "33K") ;
   And act_id Not In (Select act_id From t_serv) ;
Into Cursor serv_tmp

Use In enc_tmp
Use In t_serv

***VT 11/09/2011 AIRS-183
=OpenView("LV_PRES_HIS_VN", "urs")

** Create cursor
If Used('all_arv')
   Use In all_arv
Endif

Create Cursor all_arv (client_id C(10))

**Find most recent verified date
Select Max(lvf.verified_datetime) As verified_datetime, ;
   lvf.tc_id ;
From lv_verification_filtered lvf ;
   inner Join serv_tmp On;
   serv_tmp.tc_id = lvf.tc_id ;
   and lvf.vn_category="A" ;
   and Between(lvf.verified_datetime, ddate_from, ddate_to) ;
   Group By lvf.tc_id ;
   into Cursor tmp_dt

If _Tally > 0
   Insert Into all_arv ;
      ( client_id) ;
Select Distinct ;
      pres_his.client_id;
from lv_verification_filtered lvf ;
inner Join tmp_dt td On ;
      lvf.tc_id = td.tc_id ;
      and lvf.verified_datetime = td.verified_datetime ;
inner Join pres_his On ;
      pres_his.presh_id =lvf.table_id ;
      and !Empty(pres_his.arv_ther)

Endif

Insert Into all_arv (client_id);
Select Distinct ;
  client_id;
From lv_pres_his_vn;
Where !Empty(arv_ther) ;
   And (Between(pres_date, ddate_from, ddate_to) ;
        Or Between(vn_date, ddate_from, ddate_to) ;
        Or Between(vn_date2, ddate_from, ddate_to))

Use In tmp_dt

Insert Into all_arv ;
   (client_id) ;
Select client_id ;
From pres_his ;
Where Iif(!Empty(dis_date), ;
   dis_date >= ddate_to And pres_date <= ddate_to, ;
   pres_date <= ddate_to) ;
   and !Empty(arv_ther) ;
   and client_id Not In (Select client_id From all_arv) ;
   and client_id + Dtos(pres_date) + presh_id In;
      (Select p2.client_id + Max(Dtos(p2.pres_date) + p2.presh_id) ;
       From pres_his p2 ;
       Where Iif(!Empty(p2.dis_date), ;
                 p2.dis_date >= ddate_to And p2.pres_date <= ddate_to, ;
                 p2.pres_date <= ddate_to) ;
          And !Empty(p2.arv_ther) ;
       Group By p2.client_id)

* now, get any clients with NO active ARV Therapy prescription history as of report end date
If Used('ReportCur')
   Use In reportcur
Endif

***VT 11/09/2011 AIRS-183
** Changed (Select client_id From allpresarv) to (Select client_id From all_arv);

Select ai_clien.id_no, ;
   Space(50) As cl_name, ;
   ai_clien.client_id, ;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime ;
From ai_clien, ;
   serv_tmp ;
Where ai_clien.tc_id = serv_tmp.tc_id ;
   and ai_clien.client_id Not In ;
   (Select client_id From all_arv) ;
Into Cursor reportcur Readwrite;
Order By &orderby

***VT 11/09/2011 AIRS-183
**Use In allpresarv
Use In all_arv

oapp.msg2user("OFF")

gcrptname = 'rpt_cadr_cl'
Select reportcur
Go Top
If Eof()
   oapp.msg2user('INFORM', 'No Clients Found Meeting Selection Criteria')
Else
   Select reportcur
   Scan
      Select cli_cur
      Locate For cli_cur.client_id = reportcur.client_id
      If Found()
         Replace reportcur.cl_name With oapp.formatname(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)
      Endif
      Select reportcur
   Endscan

*!*  VT 08/27/2010 Dev Tick 4807
   If norder=1
      Index On Upper(Alltrim(cl_name))+Alltrim(client_id) Tag fn
   Else
      Index On Upper(Padl(id_no,10,'0')) Tag fn
   Endif

   Select reportcur
*!*  VT 08/27/2010 Dev Tick 4807
   Set Order To fn

   Go Top

   Do Case
   Case lprev = .F.
      Report Form rpt_cadr_cl To Printer Prompt Noconsole Nodialog

   Case lprev = .T.
      oapp.rpt_print(5, .T., 1, 'rpt_cadr_cl', 1, 2)

   Endcase
Endif