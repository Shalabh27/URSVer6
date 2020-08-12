Parameters;
   lprev, ;       && Preview
   aselvar1, ;    && select parameters from selection list
   norder, ;      && order by
   ngroup, ;      && report selection
   lctitle, ;     && report selection
   d_from , ;     && from date
   d_to, ;        && to date
   crit , ;       && name of param
   lnstat, ;      && selection(Output)  page 2
   corderby       && order by description

Acopy(aselvar1, aselvar2)
lcprogx  = ""
ccsite = ""

*!* Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "LCPROGX"
      lcprogx = aselvar2(i, 2)
   EndIf
   
   If Rtrim(aselvar2(i, 1)) = "CCSITE"
      ccsite = aselvar2(i, 2)
   Endif
Endfor

Private gchelp
gchelp = "Syringe Exchange ID Number Report Screen"
ctitle = "Syringe Exchange ID Number Report"
cdate = Date()
ctime = Time()

cfiltexpr = Iif(Empty(ccsite), "", "AND needlx.site = cCSite")

If Used('NeedleID')
   Use In needleid
Endif

Select ;
   ai_clien.id_no, ;
   crit As crit, ;
   cdate As cdate, ;
   ctime As ctime ;
FROM ;
   needlx ;
Join ai_clien On ai_clien.tc_id=needlx.tc_id;
Into Cursor ;
   needleid ;
Where ;
   needlx.Program=lcprogx ;
   AND needlx.Program In (Select prog_id From prog_cur) ;
   &cfiltexpr ;
ORDER By 1 ;
GROUP By 1

oapp.msg2user('OFF')

Select needleid
Go Top
If Eof()
   oapp.msg2user('NOTFOUNDG')
Else
   gcrptname = 'rpt_syr_id'
   Do Case
      Case lprev = .F.
         Report Form rpt_syr_id  To Printer Prompt Noconsole Nodialog
         
      Case lprev = .T.
         oapp.rpt_print(5, .T., 1, 'rpt_syr_id', 1, 2)
   Endcase
Endif

Return