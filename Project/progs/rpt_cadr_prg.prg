****************************************************
* Program:    Cliwoprg.prg
* Summary:    CADR Completeness Report: Female Clients w/o Pregnancy Data
****************************************************
Parameters;
   lprev,;      && Preview
   aselvar1,;   && select parameters from selection list
   norder,;     && order by
   ngroup,;     && report selection
   lctitle,;    && report selection
   ddate_from,; && from date
   ddate_to,;   && to date
   crit,;       && name of param
   lnstat,;     && selection(Output)  page 2
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
gchelp = "Generating Female Clients w/o Pregnancy Data Report"
ctitle="Female Clients w/o Pregnancy Data Report"


If norder=1
   orderby='2,3,4'
Else
   orderby='1'
Endif

cdate = Date()
ctime = Time()

* first, find all clients who have had an encounter in selected program this period; if no program was selected, get all RW-Eligible programs
If Used('enc_tmp')
   Use In enc_tmp
Endif

* first, find all clients who have had an encounter in selected program this period; if no program was selected, get all RW-Eligible programs
=OpenView("lv_enc_type", "urs")
=OpenView("lv_service", "urs")

If !Empty(lcprog)
   Select ai_enc.tc_id, ;
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
   Select ai_enc.tc_id, ;
      ai_enc.act_id, ;
      ai_enc.serv_cat, ;
      ai_enc.enc_id, ;
      lv_enc_type.cadr_map ;
   From ai_enc, lv_enc_type ;
   Where ai_enc.Program In (Select prog_id From Program  ;
                            Where elig_type <> "03"  ;
                              And elig_type <> "04") ;
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

* now, combine the clients with "33" services with those with "33" encounters w/o services
If Used('serv_tmp')
   Use In serv_tmp
Endif

Select tc_id ;
From  t_serv ;
Union ;
Select tc_id ;
From enc_tmp ;
Where Alltrim(cadr_map) == "33A" ;
  And act_id Not In (Select act_id From t_serv) ;
Into Cursor serv_tmp

Use In enc_tmp
Use In t_serv

* now, determine which of these clients is female and between 13 and 45 and has no pregnancy history
* jss, 9/13/05, add client's name to report, order by last name, first name, mi
If Used('ReportCur')
   Use In reportcur
Endif

Select Distinct ;
   ai_clien.id_no, ;
   Space(50) As cl_name, ;
   client.client_id, ;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime ;
From serv_tmp, ai_clien, client ;
Where serv_tmp.tc_id=ai_clien.tc_id ;
   and ai_clien.client_id=client.client_id ;
   and !Empty(client.dob) ;
   and Between(age(ddate_to, client.dob),13,45) ;
   and (client.gender='10' Or client.gender='13') ;
   and  serv_tmp.tc_id Not In (Select tc_id From pregnant Where conf_dt<=ddate_to) ;
Into Cursor reportcur Readwrite Order By &orderby

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

**VT 08/27/2010 Dev Tick 4807
   If norder=1
      Index On Upper(Alltrim(cl_name))+Alltrim(client_id) Tag fn
   Else
      Index On Upper(Padl(id_no,10,'0')) Tag fn
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
