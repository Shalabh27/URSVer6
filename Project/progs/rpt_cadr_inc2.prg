* Summary:    CADR Completeness Report: Clients w/o Household Income Data
****************************************************
Parameters ;
   lprev, ;        && Preview
   aselvar1, ;     && select parameters from selection list
   norder, ;       && order by
   ngroup, ;       && report selection
   lctitle, ;      && report selection
   ddate_from, ;   && from date
   ddate_to, ;     && to date
   crit , ;        && name of param
   lnstat, ;       && selection(Output)  page 2
   corderby        && order by description

Acopy(aselvar1, aselvar2)

lcprog = ""
&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "LCPROG"
      lcprog = aselvar2(i, 2)
   Endif
Endfor

Private gchelp
gchelp = "Generating Clients w/o Income Data Report"
ctitle="Clients w/o Household Income Data Report"

cdate = Date()
ctime = Time()

* jss, 9/13/05, order by name (2,3,4) or id # (1)
If norder=1
   orderby='2,3,4'
Else
   orderby='1'
Endif

If Used('enc_tmp')
   Use In enc_tmp
Endif

***VT 08/10/2011 AIRS-91
=OpenView("lv_ai_fin_vn", "urs")
Requery('lv_ai_fin_vn')

Create Cursor all_hous (tc_id C(10), is_refus L, hshld_incm N(8,0), hshld_size N(2,0), pov_level N(8,0), pov_cat N(1,0))

Insert Into all_hous(tc_id, is_refus, hshld_incm, hshld_size, pov_level, pov_cat);
Select Distinct ;
  tc_id,;
  is_refus,;
  hshld_incm,;
  hshld_size,;
  pov_level,;
  pov_cat ;
From lv_ai_fin_vn;
Where (Between(lv_ai_fin_vn.ass_dt, ddate_from, ddate_to) ;
       Or Between(lv_ai_fin_vn.vn_date, ddate_from, ddate_to) ;
       Or Between(lv_ai_fin_vn.vn_date2, ddate_from, ddate_to))      

Select;
   Max(af.ass_dt) As ass_dt, af.tc_id ;
From serv_tmp ;
Inner Join ai_fin af On serv_tmp.tc_id = af.tc_id And Not Between(af.ass_dt, ddate_from, ddate_to) ;
Where serv_tmp.tc_id Not In (Select tc_id From all_hous);
Group By af.tc_id ;
Into Cursor tmp_dt

If _Tally > 0
   Insert Into all_hous (tc_id, is_refus, hshld_incm, hshld_size, pov_level, pov_cat) ;
   Select Distinct ;
      ai_fin.tc_id, ;
      ai_fin.is_refus, ;
      Nvl(ai_fin.hshld_incm,0), ;
      Nvl(ai_fin.hshld_size,0), ;
      Nvl(ai_fin.pov_level,0),;
      Nvl(ai_fin.pov_cat,0) ;
   From ai_fin ;
   Inner Join tmp_dt On ;
      ai_fin.tc_id = tmp_dt.tc_id ;
      And ai_fin.ass_dt = tmp_dt.ass_dt
Endif

Use In tmp_dt

* jss, 5/17/05, modify select below to become a union of 3 possibilities:
* client refused to answer (R)
* hh size > 0 but hh income = 0 (H)
* or both hh size and hh income are zero (Z)
* jss, 9/13/05, add client's name to report, order by last name, first name, mi

If Used('ReportCur')
   Use In reportcur
Endif

Select '(R) ' + ai_clien.id_no As id_no, ;
   Space(50) As cl_name, ;
   client.client_id, ;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime ;
From ai_clien, client, all_hous ah ;
Where ai_clien.tc_id = ah.tc_id ;
   And ai_clien.client_id = client.client_id ;
   And ah.is_refus ;
Union ;
Select '(H) ' + ai_clien.id_no As id_no, ;
   Space(50) As cl_name, ;
   client.client_id, ;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime ;
From ai_clien, client, all_hous ah ;
Where ai_clien.tc_id = ah.tc_id ;
   And ai_clien.client_id = client.client_id ;
   And !ah.is_refus ;
   And Empty(ah.hshld_incm) ;
   And !Empty(ah.hshld_size) ;
Union ;
Select '(Z) ' + ai_clien.id_no As id_no, ;
   Space(50) As cl_name, ;
   client.client_id,;
   ctitle As ctitle, ;
   crit As crit, ;
   ddate_from As date_from, ;
   ddate_to As date_to,;
   cdate As cdate, ;
   ctime As ctime ;
From ai_clien, client, all_hous ah ;
Where ai_clien.tc_id = ah.tc_id ;
   And ai_clien.client_id = client.client_id ;
   And !ah.is_refus ;
   And Empty(ah.hshld_incm) ;
   And Empty(ah.hshld_size) ;
Into Cursor reportcur Readwrite;
Order By &orderby

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
