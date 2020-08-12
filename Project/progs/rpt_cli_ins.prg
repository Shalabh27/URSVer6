Parameters;
      lprev, ;       && Preview
      aselvar1, ;    && select parameters from selection list
      norder, ;      && order by
      ngroup, ;      && report selection
      lctitle, ;     && report selection
      date_from , ;  && from date
      date_to, ;     && to date
      crit , ;       && name of param
      lnstat, ;      && selection(Output)  page 2
      corderby       && order by description

Acopy(aselvar1, aselvar2)

lcinstype=''
&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "LCINSTYPE"
      lcinstype = aselvar2(i, 2)
   Endif
Endfor

Private gchelp
gchelp = ""
cdate = Date()
ctime = Time()
as_of_d   = date_from
ctitle = "Client Listing by Primary Insurance Type"
Private csavetc_id

* get client list with insurance type
* jss, 7/10/01, make sure only primary insurance listed...
Select ;
   cli_cur.* , ;
   insstat.effect_dt, ;
   insstat.exp_dt, ;
   insstat.ma_pending, ;
   instype.Descript As insdesc, ;
   lctitle As lctitle,;
   crit As crit, ;
   cdate As cdate, ;
   ctime As ctime, ;
   date_from As as_of_d ;
 FROM ;
   cli_cur, insstat, med_prov, instype ;
 WHERE ;
   cli_cur.placed_dt <= as_of_d ;
   AND cli_cur.client_id = insstat.client_id  ;
   AND insstat.effect_dt <= as_of_d ;
   AND (Empty(insstat.exp_dt) Or insstat.exp_dt >= as_of_d) ;
   AND insstat.prim_sec = 1 ;
   AND insstat.client_id + Dtos(insstat.effect_dt) In ;
   (Select insst.client_id + Max(Dtos(insst.effect_dt));
     FROM insstat insst ;
     WHERE insst.effect_dt <= as_of_d ;
       AND (Empty(insst.exp_dt) Or insst.exp_dt >= as_of_d) ;
       AND insst.prim_sec = 1 ;
     GROUP By insst.client_id) ;
   AND insstat.prov_id  = med_prov.prov_id ;
   AND med_prov.instype = instype.Code ;
   AND instype.Code = lcinstype ;
 INTO Cursor ;
   cliins1

If Empty(lcinstype)
   Select * ;
   FROM ;
      cliins1 ;
   UNION ;
   SELECT ;
      cli_cur.* , ;
      {} As effect_dt, ;
      {} As exp_dt, ;
      0  As ma_pending, ;
      PADR('No Insurance Found',25) As insdesc, ;
      lctitle As lctitle,;
      crit As crit, ;
      cdate As cdate, ;
      ctime As ctime, ;
      date_from As as_of_d ;
   FROM ;
      cli_cur ;
   WHERE ;
      cli_cur.placed_dt <= as_of_d ;
      AND   cli_cur.client_id Not In (Select client_id From cliins1) ;
   INTO Cursor ;
      cliins
Else
   Select * ;
   FROM ;
      cliins1 ;
   INTO Cursor ;
      cliins
Endif


**VT 08/26/2010 Dev Tick 4807
**INDEX ON InsDesc + Last_name + First_name TAG ilf

Index On insdesc + Upper(Alltrim(last_name)+Alltrim(first_name)) Tag ilf
Set Order To ilf
**VT End

oapp.msg2user("OFF")
gcrptname = 'rpt_cli_ins'
Select cliins
Go Top
If Eof()
   oapp.msg2user('NOTFOUNDG')
Else
   Do Case
   Case lprev = .F.
      Report Form rpt_cli_ins  To Printer Prompt Noconsole Nodialog
   Case lprev = .T.     &&Preview
      oapp.rpt_print(5, .T., 1, 'rpt_cli_ins', 1, 2)
   Endcase
Endif