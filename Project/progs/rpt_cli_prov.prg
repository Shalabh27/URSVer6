Parameters lprev, ;
           aselvar1, ;
           norder, ;
           ngroup, ;
           lctitle, ;
           date_from, ;
           date_to, ;
           crit, ;
           lnstat, ;
           corderby
      
Acopy(aselvar1, aselvar2)

lcprovider=''
&& Search For Parameters
For i = 1 To Alen(aselvar2,1)
   If Rtrim(aselvar2[i,1])="LCPROVIDER"
      lcprovider = aselvar2[i,2]
      Exit
   Endif
Endfor

Private gchelp
gchelp=""
cdate=Date()
ctime=Time()
as_of_d=date_from
ctitle="Client Listing by Primary Insurance Provider"
Private csavetc_id

Select ;
   cli_cur.* , ;
   insstat.effect_dt, ;
   insstat.exp_dt, ;
   ICase(Instype.code='09' And insstat.ma_pending=0,1,insstat.ma_pending) As ma_pending, ;
   instype.Descript As insdesc, ;
   med_prov.prov_id As prov_id, ;
   med_prov.name As prov_name, ;
   lctitle As lctitle, ;
   crit As crit, ;
   cdate As cdate, ;
   ctime As ctime, ;
   date_from As as_of_d ;
From cli_cur, ;
     insstat, ;
     med_prov, ;
     instype ;
Where ;
   cli_cur.placed_dt <= as_of_d ;
   And cli_cur.client_id = insstat.client_id ;
   And insstat.effect_dt <= as_of_d ;
   And (Empty(insstat.exp_dt) Or insstat.exp_dt >= as_of_d) ;
   And insstat.prim_sec=1 ;
   And insstat.client_id+Dtos(insstat.effect_dt) In ;
   (Select insst.client_id+Max(Dtos(insst.effect_dt)) ;
     From insstat insst ;
     Where insst.effect_dt <= as_of_d ;
       And (Empty(insst.exp_dt) Or insst.exp_dt >= as_of_d) ;
       And insst.prim_sec = 1 ;
     Group By insst.client_id) ;
   And insstat.prov_id=med_prov.prov_id ;
   And med_prov.instype=instype.Code ;
   And ICase(Empty(lcprovider),!Empty(med_prov.prov_id),med_prov.prov_id=lcprovider) ;
Into Cursor cliins
*!*  Into Cursor cliins1

*!*   Code from the rpt_cli_ins, which this program is based.
*!*   If Empty(lcprovider)
*!*      Select * ;
*!*      FROM ;
*!*         cliins1 ;
*!*      UNION ;
*!*      SELECT ;
*!*         cli_cur.* , ;
*!*         {} As effect_dt, ;
*!*         {} As exp_dt, ;
*!*         0  As ma_pending, ;
*!*         PADR('No Insurance Found',25) As insdesc, ;
*!*         lctitle As lctitle,;
*!*         crit As crit, ;
*!*         cdate As cdate, ;
*!*         ctime As ctime, ;
*!*         date_from As as_of_d ;
*!*      FROM ;
*!*         cli_cur ;
*!*      WHERE ;
*!*         cli_cur.placed_dt <= as_of_d ;
*!*         AND   cli_cur.client_id Not In (Select client_id From cliins1) ;
*!*      INTO Cursor ;
*!*         cliins
*!*   Else
*!*      Select * ;
*!*      FROM ;
*!*         cliins1 ;
*!*      INTO Cursor ;
*!*         cliins
*!*   Endif

Index On Upper(prov_name)+Upper(Alltrim(last_name)+Alltrim(first_name)) Tag ilf
Set Order To ilf

If lnstat=2   && Pending Only
   Set filter to ma_pending=1
   Go Top
   
EndIf 

oapp.msg2user("OFF")
gcrptname = 'rpt_cli_prov'
Select cliins
Go Top

If Eof()
   oapp.msg2user('NOTFOUNDG')
Else
   Do Case
   Case lprev = .F.
      Report Form rpt_cli_prov  To Printer Prompt Noconsole Nodialog
   
   Case lprev = .T.     &&Preview
      oapp.rpt_print(5, .T., 1, 'rpt_cli_prov', 1, 2)
   
   Endcase
Endif