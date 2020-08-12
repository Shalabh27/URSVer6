Parameters  ;  
   lprev, ;     && Preview
   aselvar1, ;  && select parameters from selection list
   norder, ;    && order by
   ngroup, ;    && report selection
   lctitle, ;   && report selection
   d_from , ;   && from date
   d_to, ;      && to date
   crit , ;     && name of param
   lnstat, ;    && selection(Output)  page 2
   corderby     && order by description

Acopy(aselvar1, aselvar2)
lcprogx = ""
ccsite = ""
ccwork  = ""
ctc_id2 = ""

&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Alltrim(aselvar2(i, 1)) = "LCPROGX"
      lcprogx = aselvar2(i, 2)
   Endif
   If Alltrim(aselvar2(i, 1)) = "CCSITE"
      ccsite = aselvar2(i, 2)
   Endif
   If Alltrim(aselvar2(i, 1)) = "CCWORK"
      ccwork = aselvar2(i, 2)
   Endif
   If Alltrim(aselvar2(i, 1)) = "CTC_ID3"
      ctc_id2 = aselvar2(i, 2)
   Endif

Endfor

Private gchelp
gchelp = "Syringe Exchange Report Screen"
ctitle = "Syringe Exchange by Participant Report"
cdate = Date()
ctime = Time()
************************  Opening Tables ************************************
* jss, 1/3/00, change lcprog to lcprogx to fix problem

cfiltexpr = Iif(Empty(ctc_id2)   , "", "a.tc_id = cTC_ID2")
cfiltexpr = cfiltexpr + Iif(Empty(ccwork)   ,   "", Iif(!Empty(cfiltexpr),".and.","") + " a.worker_id = cCWork")
cfiltexpr = cfiltexpr + Iif(Empty(lcprogx)   ,   "", Iif(!Empty(cfiltexpr),".and.","") + " a.program = lcProgx")
cfiltexpr = cfiltexpr + Iif(Empty(ccsite)   ,   "", Iif(!Empty(cfiltexpr),".and.","") + " a.site = cCSite")
cfiltexpr = cfiltexpr + Iif(Empty(d_from), "", Iif(!Empty(cfiltexpr),".and.","") + " a.date >= D_from")
cfiltexpr = cfiltexpr + Iif(Empty(d_to),   "", Iif(!Empty(cfiltexpr),".and.","") + " a.date <= D_to")

If !Empty(cfiltexpr)
   cfiltexpr = " AND " + cfiltexpr
Endif

* jss, 7/1/03, must account for "Unknown/Unreported" hispanic (anonymous clients)
If Used('temp1')
   Use In temp1
Endif
If Used('needl_cur')
   Use In needl_cur
Endif

Select ;
   a.*, ;
   ai_clien.id_no,;
   program.Descript As prog_descr, ;
   site.descript1 As site_descr, ;
   IIF(!Empty(c.dob),oapp.age(a.Date,c.dob),00)   As age , ;
   gender.Descript   As gender, ;
   Iif(c.hispanic=1, Padr("No",18),Iif(c.hispanic=2, Padr("Yes",18), "Unknown/Unreported"))  As ethnic,;
   Space(150) As race, ;
   staffcur.Last, staffcur.First, ;
   c.client_id, ;
   crit As crit, ;
   cdate As cdate, ;
   ctime As ctime, ;
   d_from As date_from, ;
   d_to As date_to ;
FROM ;
   needlx a, Program, site, staffcur, ai_clien, client c, gender ;
WHERE ;
   a.Program = Program.prog_id ;
   AND a.site = site.site_id ;
   AND a.worker_id = staffcur.worker_id ;
   AND a.tc_id = ai_clien.tc_id ;
   AND ai_clien.client_id= c.client_id ;
   AND c.gender = gender.Code ;
   &cfiltexpr ;
ORDER By ;
   site_descr, prog_descr, ai_clien.id_no, a.Date ;
INTO Cursor ;
   temp1

oapp.reopencur('temp1','needl_cur')

Select client
Set Order To Tag client_id

Select   needl_cur
Go Top
Scan

* jss, 7/1/03, account for "Unknown/Unreported" race (anonymous client)
   If Seek(needl_cur.client_id, 'client')
      If client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.someother + client.unknowrep = 0
         cdesc = "Unknown/Unreported"
      Else
         cdesc = ''
         cdesc = cdesc + Iif(client.white = 1, 'White', '')
         cdesc = cdesc + Iif(!Empty(cdesc), Iif(client.blafrican = 1, ', Black or African-American', ''), Iif(client.blafrican = 1, 'Black or African-American', ''))
         cdesc = cdesc + Iif(!Empty(cdesc), Iif(client.asian = 1, ', Asian', ''), Iif(client.asian = 1, 'Asian', ''))
         cdesc = cdesc + Iif(!Empty(cdesc), Iif(client.hawaisland= 1, ', Native Hawaiian/Pacific Islander', ''), Iif(client.hawaisland= 1, 'Native Hawaiian/Pacific Islander', ''))
         cdesc = cdesc + Iif(!Empty(cdesc), Iif(client.indialaska = 1, ', American Indian or Alaskan Native', ''), Iif(client.indialaska = 1, 'American Indian or Alaskan Native', ''))
         cdesc = cdesc + Iif(!Empty(cdesc), Iif(client.someother = 1, ', Some Other Race', ''), Iif(client.someother = 1, 'Some Other Race', ''))
         cdesc = cdesc + Iif(!Empty(cdesc), Iif(client.unknowrep = 1, ', Unknown due to Conversion', ''), Iif(client.unknowrep = 1, 'Unknown due to Conversion', ''))
      Endif
      Replace race With cdesc
   Endif
Endscan


oapp.msg2user('OFF')

Select needl_cur
Go Top
If Eof()
   oapp.msg2user('NOTFOUNDG')
Else
   gcrptname = 'rpt_syr_part'
   Do Case
   Case lprev = .F.
      Report Form rpt_syr_part  To Printer Prompt Noconsole Nodialog
   Case lprev = .T.
      oapp.rpt_print(5, .T., 1, 'rpt_syr_part', 1, 2)

   Endcase
Endif
