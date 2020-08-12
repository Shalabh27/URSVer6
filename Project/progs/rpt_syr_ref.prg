Parameters ;
   lprev, ;      && Preview
   aselvar1, ;   && select parameters from selection list
   norder, ;     && order by
   ngroup, ;     && report selection
   lctitle, ;    && report selection
   date_fr , ;   && from date
   date_t, ;     && to date
   crit , ;      && name of param
   lnstat, ;     && selection(Output)  page 2
   corderby      && order by description

Acopy(aselvar1, aselvar2)

ccsite = ""
ccwork = ""
lcprog = ""

&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "LCPROG"
      lcprog = aselvar2(i, 2)
   Endif

   If Rtrim(aselvar2(i, 1)) = "CCWORK"
      ccwork = aselvar2(i, 2)
   Endif

   If Rtrim(aselvar2(i, 1)) = "CCSITE"
      ccsite = aselvar2(i, 2)
   Endif
Endfor

cdate = Date()
ctime = Time()
lctitle=''

Select Document
Locate For doc_catgry='NR' And Alltrim(prog_parms)=Str(lnstat,1,0)
If Found()
   lctitle=Alltrim(Document.Descript)
Else
   lctitle='Syringe Exchange Unit Referral Report...'
Endif

Private gchelp
gchelp = "Syringe Exchanges Unit Referral"
************************************************************
cwhere = ""

*!*   cWhere = IIF(EMPTY(Date_fr), "", " ai_ref.ref_dt >= Date_fr")
*!*   cWhere = cWhere + IIF(EMPTY(Date_t),  "", IIF(!Empty(cWhere),".and.","") + " ai_ref.ref_dt <= Date_t")
*!*   ***VT 12/17/2008 Dev Tick 4993 V.U.8.3
*!*   cWhere = cWhere + IIF(EMPTY(cCSite)   , "", IIF(!Empty(cWhere),".and.","") + " ai_enc.site = cCSite")
*!*   cWhere = cWhere + IIF(EMPTY(ccwork), "", IIF(!Empty(cWhere),".and.","") + " ai_enc.worker_id = ccwork")
*!*   cWhere = cWhere + IIF(EMPTY(lCProg), "", IIF(!Empty(cWhere),".and.","") + " ai_enc.program = lCProg")
*!*   cWhere = cWhere + IIF(EMPTY(Date_t),  "", IIF(!Empty(cWhere),".and.","") + " ai_ref.ref_dt <= Date_t")
*!*   cWhere = cWhere + IIF(EMPTY(cCSite), "", IIF(!Empty(cWhere),".and.","") + " needlx.site = cCSite")
*!*   cWhere = cWhere + IIF(EMPTY(ccwork), "", IIF(!Empty(cWhere),".and.","") + " needlx.worker_id = ccwork")
*!*   cWhere = cWhere + IIF(EMPTY(lCProg), "", IIF(!Empty(cWhere),".and.","") + " needlx.program = lCProg")

=OpenView('lv_sep_referrals_program', 'urs', 'lv_sep_referrals_program', .t., .t.)
Requery('lv_sep_referrals_program')

Select 0
Create Cursor ref_unit (header1 c(50), details1 c(50), units1 N(6), ;
   header2 c(50), details2 c(50), units2 N(6), ;
   date_from d(8), date_to d(8), crit c(100), ;
   cdate d(8), ctime c(8), ctitle c(100))

** Collect all data according to parameters
** VT-12/17/2008 Dev Tick 4993 V.U.8.3

*!*   Select ;
*!*         ai_ref.ref_cat, ;
*!*         ai_ref.ref_for as ref_serv, ;
*!*         ai_ref.ref_id ;
*!*   From  ai_ref ;
*!*         Left Outer Join ai_enc On ;
*!*               ai_ref.act_id = ai_enc.act_id ;
*!*   Where ;
*!*      &cWhere ;
*!*   Into Cursor ;
*!*      tmp_res

If lnstat=1
*  cwhere = "!Empty(lv_sep_referrals_program.site)"
   cwhere = "!Empty(needlx.site)"
   cwhere=cwhere + Iif(Empty(date_fr), "", " .and. ai_ref.ref_dt >= Date_fr")
   cwhere=cwhere + Iif(Empty(date_t),  "", Iif(!Empty(cwhere),".and.","") + " ai_ref.ref_dt <= Date_t")
   cwhere=cwhere + Iif(Empty(ccsite), "", Iif(!Empty(cwhere),".and.","") + " needlx.site = cCSite")
   cwhere=cwhere + Iif(Empty(ccwork), "", Iif(!Empty(cwhere),".and.","") + " needlx.worker_id = ccwork")
   cwhere=cwhere + Iif(Empty(lcprog), "", Iif(!Empty(cwhere),".and.","") + " needlx.program = lCProg")
   
   Select ;
      ai_ref.ref_cat, ;
      ai_ref.ref_for As ref_serv, ;
      ai_ref.ref_id ;
   From  ai_ref ;
   Inner Join needlx On ai_ref.need_id = needlx.need_id ;
   Inner Join program ON program.prog_id = needlx.program ;
   Where  &cwhere ;
          AND program.include_sep = .T. ;
   Into Cursor tmp_res
      
Else
   cwhere = Iif(Empty(date_fr), "", " lv_sep_referrals_program.ref_dt >= Date_fr")
   cwhere = cwhere + Iif(Empty(date_t),  "", Iif(!Empty(cwhere),".and.","") + " lv_sep_referrals_program.ref_dt <= Date_t")
   cwhere = cwhere + Iif(Empty(ccsite)   , "", Iif(!Empty(cwhere),".and.","") + " lv_sep_referrals_program.site = cCSite")
   cwhere = cwhere + Iif(Empty(ccwork), "", Iif(!Empty(cwhere),".and.","") + " lv_sep_referrals_program.worker_id = ccwork")
   cwhere = cwhere + Iif(Empty(lcprog), "", Iif(!Empty(cwhere),".and.","") + " lv_sep_referrals_program.program = lCProg")

   ** VT 06/02/2010 DEv Tick 6636
   ** Select 0
   ** Use lv_sep_referrals_program
  
   ** GOxford 03/30/12 JIRA 297 Added check for 'Include in SEP referrals reports' (program.include_sep)

   *!*     Select ;
   *!*        ref_cat, ;
   *!*        ref_for As ref_serv, ;
   *!*        ref_id ;
   *!*        From  lv_sep_referrals_program ;
   *!*        Where ;
   *!*        &cwhere ;
   *!*        Into Cursor ;
   *!*        tmp_res

   Select ;
      ref_cat, ;
      ref_for As ref_serv, ;
      ref_id ;
   From  lv_sep_referrals_program ;
   Inner Join program ON program.prog_id = lv_sep_referrals_program.program ;
   Where &cwhere ;
         AND program.include_sep =(.T.) ;
   Into Cursor tmp_res
         
   ** GOxford END 03/30/12
   ** Use In lv_sep_referrals_program
Endif
Use In lv_sep_referrals_program

*!* Code 01 Substanse Use Treatment
Select;
   ref_syr_cat.Descript As header1, ;
   rcsl.Descript As details1, ;
   Count(*) As units1 ;
From tmp_res ;
Inner Join ref_cat_serv_link rcsl On;
    tmp_res.ref_cat = rcsl.ref_cat  And ;
    tmp_res.ref_serv= rcsl.ref_serv ;
Inner Join ref_syr_cat On ;
    ref_syr_cat.Code = rcsl.ref_syr_cat ;
Where ref_syr_cat.Code ='01' ;
Group By ref_syr_cat.Descript, rcsl.Descript ;
Into Cursor tmp_sub1

Select  Distinct ;
   ref_syr_cat.Descript As header1, ;
   rcsl.Descript As details1, ;
   0 As units1 ;
From ref_cat_serv_link rcsl ;
Inner Join ref_syr_cat On ;
    ref_syr_cat.Code = rcsl.ref_syr_cat ;
Where ref_syr_cat.Code ='01' And ;
      rcsl.Descript Not In (Select details1 ;
From tmp_sub1 )  ;
Into Cursor tmp_sub2

Select * ;
From  tmp_sub1 ;
Union ;
Select * ;
From  tmp_sub2 ;
Into Cursor tmp_un1  ;
Order By details1

nrecunit1 = _Tally

Use In tmp_sub1
Use In tmp_sub2

** Code 02 Medical
Select  ;
   ref_syr_cat.Descript As header2, ;
   rcsl.Descript As details2, ;
   Count(*) As units2 ;
From tmp_res ;
Inner Join ref_cat_serv_link rcsl On ;
    tmp_res.ref_cat = rcsl.ref_cat  And ;
    tmp_res.ref_serv= rcsl.ref_serv ;
Inner Join ref_syr_cat On ;
    ref_syr_cat.Code = rcsl.ref_syr_cat ;
Where ref_syr_cat.Code ='02' ;
Group By ref_syr_cat.Descript, rcsl.Descript ;
Into Cursor tmp_med1

Select  Distinct ;
   ref_syr_cat.Descript As header2, ;
   rcsl.Descript As details2, ;
   0 As units2 ;
From ref_cat_serv_link rcsl ;
Inner Join ref_syr_cat On ;
    ref_syr_cat.Code = rcsl.ref_syr_cat ;
Where ref_syr_cat.Code ='02' And ;
      rcsl.Descript Not In (Select details2 ;
                              From tmp_med1 ) ;
Into Cursor tmp_med2

Select * ;
From  tmp_med1 ;
Union ;
Select * ;
From  tmp_med2 ;
Into Cursor tmp_un2  ;
Order By details2

nrecunit2 = _Tally

Use In tmp_med1
Use In tmp_med2

** Fill cursor  For Substance Use Treatment and Medical
If nrecunit1 >= nrecunit2
   Insert Into ref_unit ;
      ( header1, ;
      details1, ;
      units1, ;
      date_from, ;
      date_to, ;
      crit ) ;
      Select header1, ;
      details1, ;
      units1, ;
      date_fr As date_from, ;
      date_t As date_to, ;
      crit As crit ;
      From tmp_un1

   Select ref_unit
   Go Top

   Select tmp_un2
   Scan
      Scatter Memvar

      Select ref_unit

      Do While .T.
         Gather Memvar

         If !Eof()
            Skip
         Endif

         Exit
      Enddo
      Select tmp_un2
   Endscan

   Select ref_unit
   Replace ref_unit.header2 With m.header2 For Empty(ref_unit.header2) All

Endif

If nrecunit2 > nrecunit1
   Insert Into ref_unit ;
      (header2, ;
      details2, ;
      units2, ;
      date_from, ;
      date_to, ;
      crit ) ;
      Select header2, ;
      details2, ;
      units2, ;
      date_fr As date_from, ;
      date_t As date_to, ;
      crit As crit ;
      From tmp_un2

   Select ref_unit
   Go Top

   Select tmp_un1
   Scan
      Scatter Memvar

      Select ref_unit

      Do While .T.
         Gather Memvar
         If !Eof()
            Skip
         Endif

         Exit
      Enddo
      Select tmp_un1
   Endscan

   Select ref_unit
   Replace ref_unit.header1 With m.header1 For Empty(ref_unit.header1) All
Endif

Release m.header1, m.details1, m.units1, m.header2, m.details2, m.units2

Use In tmp_un1
Use In tmp_un2

** Code 03 Primary Health Care
Select  ref_syr_cat.Descript As header1, ;
   rcsl.Descript As details1, ;
   Count(*) As units1 ;
   From tmp_res ;
   inner Join ref_cat_serv_link rcsl On ;
   tmp_res.ref_cat = rcsl.ref_cat  And ;
   tmp_res.ref_serv= rcsl.ref_serv ;
   inner Join ref_syr_cat On ;
   ref_syr_cat.Code = rcsl.ref_syr_cat ;
   Where ref_syr_cat.Code ='03' ;
   Group By ref_syr_cat.Descript, rcsl.Descript ;
   Into Cursor tmp_ph1


Select  Distinct ;
   ref_syr_cat.Descript As header1, ;
   rcsl.Descript As details1, ;
   0 As units1 ;
   from ref_cat_serv_link rcsl ;
   inner Join ref_syr_cat On ;
   ref_syr_cat.Code = rcsl.ref_syr_cat ;
   Where ref_syr_cat.Code ='03' And ;
   rcsl.Descript Not In (Select details1 ;
   From tmp_ph1 )  ;
   Into Cursor tmp_ph2

Select * ;
   From  tmp_ph1 ;
   Union ;
   Select * ;
   From  tmp_ph2 ;
   Into Cursor tmp_un1  ;
   Order By details1

nrecunit1 = _Tally

Use In tmp_ph1
Use In tmp_ph2

** Code 04 Miscellaneous
Select  ref_syr_cat.Descript As header2, ;
   rcsl.Descript As details2, ;
   Count(*) As units2 ;
   From tmp_res ;
   inner Join ref_cat_serv_link rcsl On ;
   tmp_res.ref_cat = rcsl.ref_cat  And ;
   tmp_res.ref_serv= rcsl.ref_serv ;
   inner Join ref_syr_cat On ;
   ref_syr_cat.Code = rcsl.ref_syr_cat ;
   Where ref_syr_cat.Code ='04' ;
   Group By ref_syr_cat.Descript, rcsl.Descript ;
   Into Cursor tmp_mis1


Select  Distinct ;
   ref_syr_cat.Descript As header2, ;
   rcsl.Descript As details2, ;
   0 As units2 ;
   from ref_cat_serv_link rcsl ;
   inner Join ref_syr_cat On ;
   ref_syr_cat.Code = rcsl.ref_syr_cat ;
   Where ref_syr_cat.Code ='04' And ;
   rcsl.Descript Not In (Select details2 ;
   From tmp_mis1 )  ;
   Into Cursor tmp_mis2

Select * ;
   From  tmp_mis1 ;
   Union ;
   Select * ;
   From  tmp_mis2 ;
   Into Cursor tmp_un2  ;
   Order By details2

nrecunit2 = _Tally

Use In tmp_mis1
Use In tmp_mis2

Select ref_unit
nrefcount = Reccount()

** Fill cursor  For Primary Health Care and Miscellaneous
If nrecunit1 >= nrecunit2
   Insert Into ref_unit ;
      ( header1, ;
      details1, ;
      units1, ;
      date_from, ;
      date_to, ;
      crit ) ;
      Select header1, ;
      details1, ;
      units1, ;
      date_fr As date_from, ;
      date_t As date_to, ;
      crit As crit ;
      From tmp_un1

   nrec = nrefcount + 1
   Select ref_unit
   Go nrec

   Select tmp_un2
   Scan
      Scatter Memvar

      Select ref_unit

      Do While .T.
         Gather Memvar

         If !Eof()
            Skip
         Endif

         Exit
      Enddo
      Select tmp_un2
   Endscan

   Select ref_unit
   Replace ref_unit.header2 With m.header2 For Empty(ref_unit.header2) All

Endif

If nrecunit2 > nrecunit1
   Insert Into ref_unit ;
      (header2, ;
      details2, ;
      units2, ;
      date_from, ;
      date_to, ;
      crit ) ;
      Select header2, ;
      details2, ;
      units2, ;
      date_fr As date_from, ;
      date_t As date_to, ;
      crit As crit ;
      From tmp_un2

   nrec = nrefcount + 1
   Select ref_unit
   Go nrec

   Select tmp_un1
   Scan
      Scatter Memvar

      Select ref_unit

      Do While .T.
         Gather Memvar
         If !Eof()
            Skip
         Endif

         Exit
      Enddo
      Select tmp_un1
   Endscan

   Select ref_unit
   Replace ref_unit.header1 With m.header1 For Empty(ref_unit.header1) All
Endif

Select ref_unit
Replace ctitle With lctitle, cdate With cdate, ctime With ctime All

* Release All
Use In tmp_un1
Use In tmp_un2
Use In tmp_res

oapp.msg2user('OFF')

Select ref_unit
Go Top
If Eof()
   oapp.msg2user('NOTFOUNDG')
Else
   gcrptname = 'rpt_syr_ref'
   Do Case
   Case lprev = .F.
      Report Form rpt_syr_ref  To Printer Prompt Noconsole Nodialog

   Case lprev = .T.
      oapp.rpt_print(5, .T., 1, 'rpt_syr_ref', 1, 2)

   Endcase
Endif
