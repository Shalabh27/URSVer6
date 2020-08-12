Parameters ;
   lprev, ;        && Preview
   aselvar1, ;     && select parameters from selection list
   norder, ;       && order by
   ngroup, ;       && report selection
   lctitle, ;      && report selection
   ddate_from , ;  && from date
   ddate_to, ;     && to date
   crit , ;        && name of param
   lnstat, ;       && selection(Output)  page 2
   corderby        && order by description

owait.Hide()

coldgctc_id=gctc_id
cclientidhold=gcclient_id

If Used('curServPool')
   Use In curservpool
Endif

Acopy(aselvar1, aselvar2)
ctc_id = ""
cfundtypeselected = ""
&& Search For Parameters
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "CTC_ID"
      ctc_id = aselvar2(i, 2)
   Endif
   If Rtrim(aselvar2(i, 1)) = "CFUNDTYPE"
      cfundtypeselected = aselvar2(i, 2)
   Endif
Endfor

Local lkillfundt

If Used('fundtype')
   lkillfundt=.F.
Else
   lkillfundt=.F.
   =openfile('fundtype','code')

Endif

If Empty(cfundtypeselected)
   oapp.vgenprop='All Funding Types'

Else
   oapp.vgenprop=Iif(Seek(cfundtypeselected,'fundtype','code')=(.T.),fundtype.Descript,'n/a')

Endif

If lkillfundt=(.T.)
   Use In fundtype
Endif

orsrmethods=Newobject('_rsr','rsr')

*!* PB: 01/2010 - This process is used in many places.
=orsrmethods.create_period_cursor(.F.,.F.,.T.)

onewrsrform=Newobject('rsr_starting','rsr',.Null.,.T.)
onewrsrform.center_form_on_top()
onewrsrform.Show()

Select curqh
Go Top
Locate For is_selected =(.T.)
If Found()
   curqh_qh_id=curqh.qh_id
   curqh_q_begin=curqh.q_begin
   curqh_h_end=curqh.h_end
   m.curqh_note=curqh.Note
Else
   Use In curqh
   Return
Endif

owait.Show()
orsrmethods.dstart=curqh_q_begin
orsrmethods.dend=curqh_h_end
orsrmethods.cfundingtype=cfundtypeselected

If !Used('hivstat')
   =openfile('hivstat')
Endif
orsrmethods.create_curprograms()
orsrmethods.create_curcp1()

If orsrmethods.select_clients_with_service() = (.T.)
   Set Seconds Off
   m.ctime=Ttoc(Datetime(),2)
   Set Seconds On

   Select curservpool
   Replace All curqh_note With m.curqh_note, ctime With m.ctime

   Go Top
   Locate For !Deleted()

   If !Found()
      Use In curservpool
      owait.Hide()
      oapp.msg2user('NOTFOUNDG')
      Return
   Endif

   =openfile('rsr_description')
   If !Empty(ctc_id)
      Select curservpool
      Locate For tc_id=ctc_id
      If !Found()
         Use In curservpool
         owait.Hide()
         oapp.msg2user('NOTFOUNDG')
         Return
      Endif
   Endif

   *!* Questions 1-15 lnStat = 2 and 1
   If Inlist(lnstat,2,1)
      If Used('q_1_15')
         Use In q_1_15
      Endif

      Select curservpool.* ,;
         crit As crit, ;
         Strtran(orsrmethods.id1(curservpool.placed_dt) ,',','/') As q1,;
         Space(80) As q2, ;
         orsrmethods.id3() As q3,;
         Transform(Year(cl.dob),'9999') As q4,;
         Space(25) As q5, ;
         Space(100) As q6, ;
         Space(15) As q7, ;
         Iif(curservpool.gender='12', 'Male to Female',;
         Iif(curservpool.gender='13', 'Female to Male', Space(14))) As q8, ;
         Space(80) As q9,;
         Space(25) As q10, ;
         orsrmethods.id11(curservpool.zip) As q11,;
         Space(35) As q12,;
         Space(4) As q13, ;
         Space(200) As q14, ;
         Space(100) As q15 ;
      From curservpool ;
         inner Join client cl On ;
         curservpool.client_id = cl.client_id;
      Where tc_id=ctc_id ;
      Into Cursor q_1_15 Readwrite

      *!* Question 2
       Update  q_1_15 ;
           Set q2 = rsd.Description;
       From q_1_15,  ;
            rsr_description rsd ;
       Where rsd.question_number = 2  ;
         And rsd.rsr_code = orsrmethods.id2(q_1_15.tc_id)

      *!* Question 5
       Update  q_1_15 ;
           Set q5 = rsd.Description;
       From q_1_15, ;
            rsr_description rsd ;
       Where rsd.question_number = 5  ;
         And rsd.rsr_code = orsrmethods.id5(q_1_15.hispanic)

       *!*Question 6
        =q_6()

       *!* Question 7
        Update  q_1_15 ;
            Set q7 = rsd.Description;
        From q_1_15, ;
             rsr_description rsd ;
        Where rsd.question_number = 7  ;
          And rsd.rsr_code = orsrmethods.id7(q_1_15.gender)
     
       *!* Question 9
        =openfile('poverty')
        Update  q_1_15 ;
            Set q9 = rsd.Description;
        From q_1_15, ;
             rsr_description rsd ;
        Where rsd.question_number = 9  ;
          And rsd.rsr_code = orsrmethods.id9(q_1_15.hshld_incm, q_1_15.hshld_size, q_1_15.is_refus)

        Use In poverty

      *!*Question 10
       Update  q_1_15 ;
           Set q10 = rsd.Description;
       From q_1_15,  ;
            rsr_description rsd ;
       Where rsd.question_number = 10  ;
         And rsd.rsr_code = orsrmethods.id10(q_1_15.tc_id)

      *!* Question 12
       Update  q_1_15 ;
           Set q12 = rsd.Description;
       From q_1_15,  ;
            rsr_description rsd ;
       Where rsd.question_number = 12  ;
         And rsd.rsr_code = q_1_15.hivstatid

      *!*Question 13
       Update  q_1_15 ;
           Set q13 = q_13(tc_id, hivstatid, hiv_status_date);
       From q_1_15

      *!*Question 14
       =q_14()

      *!*Question 15
       =q_15()
   Endif
   *!* END Questions 1-15 lnStat = 2 and 1

   *!* Create Services
   If Inlist(lnstat,1,3)
      =create_curservices(curqh_q_begin, curqh_h_end, ctc_id)
   Endif

   *!* Questions 16-45 lnStat=1
   If lnstat=1
      If Used('q_16_45')
         Use In q_16_45
      Endif

      Select q_1_15.tc_id, ;
         000 As q16_1, 000 As q16_2, 000 As q16_3, 000 As q16_4, ;
         000 As q17_1, 000 As q17_2, 000 As q17_3, 000 As q17_4, ;
         000 As q18_1, 000 As q18_2, 000 As q18_3, 000 As q18_4, ;
         000 As q19_1, 000 As q19_2, 000 As q19_3, 000 As q19_4, ;
         000 As q20_1, 000 As q20_2, 000 As q20_3, 000 As q20_4, ;
         000 As q21_1, 000 As q21_2, 000 As q21_3, 000 As q21_4, ;
         000 As q22_1, 000 As q22_2, 000 As q22_3, 000 As q22_4, ;
         000 As q23_1, 000 As q23_2, 000 As q23_3, 000 As q23_4, ;
         000 As q24_1, 000 As q24_2, 000 As q24_3, 000 As q24_4, ;
         000 As q25_1, 000 As q25_2, 000 As q25_3, 000 As q25_4, ;
         Space(3) As q26_1, Space(3) As q26_2,Space(3) As q26_3,Space(3) As q26_4,;
         Space(3) As q27_1, Space(3) As q27_2,Space(3) As q27_3,Space(3) As q27_4,;
         Space(3) As q28_1, Space(3) As q28_2,Space(3) As q28_3,Space(3) As q28_4,;
         Space(3) As q29_1, Space(3) As q29_2,Space(3) As q29_3,Space(3) As q29_4,;
         Space(3) As q30_1, Space(3) As q30_2,Space(3) As q30_3,Space(3) As q30_4,;
         Space(3) As q31_1, Space(3) As q31_2,Space(3) As q31_3,Space(3) As q31_4,;
         Space(3) As q32_1, Space(3) As q32_2,Space(3) As q32_3,Space(3) As q32_4,;
         Space(3) As q33_1, Space(3) As q33_2,Space(3) As q33_3,Space(3) As q33_4,;
         Space(3) As q34_1, Space(3) As q34_2,Space(3) As q34_3,Space(3) As q34_4,;
         Space(3) As q35_1, Space(3) As q35_2,Space(3) As q35_3,Space(3) As q35_4,;
         Space(3) As q36_1, Space(3) As q36_2,Space(3) As q36_3,Space(3) As q36_4,;
         Space(3) As q37_1, Space(3) As q37_2,Space(3) As q37_3,Space(3) As q37_4,;
         Space(3) As q38_1, Space(3) As q38_2,Space(3) As q38_3,Space(3) As q38_4,;
         Space(3) As q39_1, Space(3) As q39_2,Space(3) As q39_3,Space(3) As q39_4,;
         Space(3) As q40_1, Space(3) As q40_2,Space(3) As q40_3,Space(3) As q40_4,;
         Space(3) As q41_1, Space(3) As q41_2,Space(3) As q41_3,Space(3) As q41_4,;
         Space(3) As q42_1, Space(3) As q42_2,Space(3) As q42_3,Space(3) As q42_4,;
         Space(3) As q43_1, Space(3) As q43_2,Space(3) As q43_3,Space(3) As q43_4,;
         Space(3) As q44_1, Space(3) As q44_2,Space(3) As q44_3,Space(3) As q44_4,;
         Space(3) As q45_1, Space(3) As q45_2,Space(3) As q45_3,Space(3) As q45_4 ;
      From q_1_15 ;
      Into Cursor q_16_45 Readwrite

     *!* Questions 16-25
      =q16_25()

     *!* Questions 26 -45
      =q26_45()
   Endif
   *!* END Questions 16-45 lnStat =1

   *!* Questions 46-66 lnStat=1 or 3
   If Inlist(lnstat,1,3)
      Select   curservpool.* ,;
         crit As crit, ;
         .F. As lqhhere;
      From curservpool ;
      Where curservpool.tc_id=ctc_id ;
      Into Cursor t_46_66  Readwrite

      Update t_46_66 ;
         Set lqhhere = .T.;
      From t_46_66   ;
      Inner Join rsr_details Rd On t_46_66.tc_id = Rd.tc_id ;
                              And Rd.qh_id= curqh_qh_id
      If Used('q_46_66')
         Use In q_46_66
      Endif

      Select curservpool.* ,;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 3, rsr_details.hiv_risk_screened <> 1, 3, 1), 9) As q46_code, ;
         Space(007) As q46,;
         Space(010) As q47, ;
         Space(200) As q48, ;
         Space(250) As q49, ;
         Space(250) As q50, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 5,;
                                               rsr_details.pcp_prescribed=1,1, ;
                                               rsr_details.pcp_prescribed=2,3, ;
                                               rsr_details.pcp_prescribed=3,4, 5), 9) As q51_code, ;
         Space(50) As q51,;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 8,;
                                               rsr_details.haart_prescribed=0,8,;
                                               rsr_details.haart_prescribed=1,1,;  &&Was7
                                               rsr_details.haart_prescribed=2,2,;
                                               rsr_details.haart_prescribed=3,3,;
                                               rsr_details.haart_prescribed=4,4,;
                                               rsr_details.haart_prescribed=5,5,;
                                               rsr_details.haart_prescribed=6,6,;
                                               rsr_details.haart_prescribed=7,7,8), 99) As q52_code, ;
         Space(50) As q52, ;
         0 As is_q52_code, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4,;
                                               rsr_details.tb_screened=1, 1,;
                                               rsr_details.tb_screened=2, 3, 4), 9) As q53_code, ;
         Space(30) As q53, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4,;
                                               rsr_details.no_tb_screening=0,4, ;
                                               rsr_details.no_tb_screening), 9) As q54_code, ;
         Space(30) As q54, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4,;
         rsr_details.syphilis_screened=1,1,;
         rsr_details.syphilis_screened=2,3,4),9) As q55_code, ;
         Space(30) As q55, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4, ;
         rsr_details.hep_b_screened=1,1,;
         rsr_details.hep_b_screened=2,3,4),9) As q56_code, ;
         Space(30) As q56, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4, ;
         rsr_details.no_hep_b_screening=0,4,;
         rsr_details.no_hep_b_screening),9) As q57_code, ;
         Space(30) As q57, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4, ;
         rsr_details.hep_b_vaccine=0,4, ;
         rsr_details.hep_b_vaccine), 9) As q58_code, ;
         Space(30) As q58, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4,;
         rsr_details.hep_c_screened=1,1,;
         rsr_details.hep_c_screened=2,3,4), 9) As q59_code, ;
         Space(30) As q59, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4, ;
         rsr_details.no_hep_c_screening=0,4,;
         rsr_details.no_hep_c_screening),9) As q60_code, ;
         Space(30) As q60, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4,;
         rsr_details.sub_use_screen=1,1,;
         rsr_details.sub_use_screen=2,3,4), 9) As q61_code, ;
         Space(30) As q61, ;
         Iif(curservpool.is_medical=.T., Icase(lqhhere=(.F.), 4,;
         rsr_details.mental_health_screen=1,1,;
         rsr_details.mental_health_screen=2,3,4), 9) As q62_code, ;
         Space(30) As q62, ;
         Iif((curservpool.is_medical=.T. And curservpool.sex='F'), ;
                  ICase(lqhhere=(.F.), 5,;
                        rsr_details.pap_smear=1,1,;
                        rsr_details.pap_smear=2,3,5), 5) As q63_code, ;
         Space(30) As q63,  ;
         Iif((curservpool.is_medical=.T. And curservpool.sex='F' And Between(curservpool.age,11,50)=(.T.)) ,;
                 ICase(lqhhere=(.F.), 4, rsr_details.pregnant=0,4, rsr_details.pregnant=1,1,4), 4) As q64_code, ;
         Space(30) As q64,  ;
         Space(10) As preg_status_id,;
         0 As q65_code, ;
         Space(30) As q65,  ;
         0 As q66_code, ;
         Space(30) As q66  ;
      From t_46_66 curservpool ;
      Left Outer Join rsr_details On ;
         curservpool.tc_id = rsr_details.tc_id ;
         And rsr_details.qh_id= curqh_qh_id;
      Where curservpool.tc_id=ctc_id ;
      Into Cursor q_46_66 Readwrite

      Use In t_46_66

**Question 46
      =q_46()

**Question q47
      =q_47()

**Question q48
      =q_48()

**Question q49
      =q_49(curqh_q_begin, curqh_h_end)

**Question q50
      =q_50(curqh_q_begin, curqh_h_end)

**Question 51
      =q_51()

**Question 52
      =q_52(curqh_q_begin, curqh_h_end)

**Question 53
      =q_53(curqh_q_begin, curqh_h_end)

**Question 54
      Update q_46_66 ;
         Set q54 = Iif(is_medical=.T. And (q53_code =1 Or q53_code=3 Or q53_code=4) And hivstatid <> 5, ;
         Iif(q_46_66.q54_code=0, '', rsd.Description), '') ;
         from q_46_66, ;
         rsr_description rsd ;
         where rsd.question_number = 53  ;    &&53 because 53 and 54 the same answers
      And rsd.rsr_code = q_46_66.q54_code

**Question 55
      =q_55(curqh_q_begin, curqh_h_end)
**Question 56
      =q_56(curqh_q_begin, curqh_h_end)

**Question 57
      Update q_46_66 ;
         Set q57 = Iif(is_medical=.T. And (q56_code =1 Or q56_code=3 Or q56_code=4) And hivstatid <> 5, ;
         Iif(q_46_66.q57_code=0, ' ',rsd.Description), '' ) ;
         from q_46_66, ;
         rsr_description rsd ;
         where rsd.question_number = 53  ;    &&53 because 53 and 57 the same answers
      And rsd.rsr_code = q_46_66.q57_code

**Question 58
      =q_58()
**Question 59
      =q_59(curqh_q_begin, curqh_h_end)

**Question 60
      Update q_46_66 ;
         Set q60 = Iif(is_medical=.T. And (q59_code =1 Or q59_code=3 Or q59_code=4) And hivstatid <> 5, ;
         Iif( q_46_66.q60_code=0, '',rsd.Description), '' ) ;
         from q_46_66, ;
         rsr_description rsd ;
         where rsd.question_number = 53  ;    &&53 because 53 and 60 the same answers
      And rsd.rsr_code = q_46_66.q60_code

**Question 61
      =q_61()
**Question 62
      =q_62()
**Question 63
      =q_63(curqh_q_begin, curqh_h_end)
**Question 64
      =q_64(curqh_q_begin, curqh_h_end, q_46_66.q64_code)
**Question 65
      =q_65()
**Question 66
      =q_66()
   Endif

   Use In rsr_description
   owait.Hide()

   gctc_id = coldgctc_id
   Do Case
   Case lnstat = 1  && RSR Client Detail  (All Questions 1-66)
      Select Distinct ;
         q_1_15.*, ;
         q_16_45.q16_1, q_16_45.q16_2, q_16_45.q16_3, q_16_45.q16_4, ;
         q_16_45.q17_1, q_16_45.q17_2, q_16_45.q17_3, q_16_45.q17_4, ;
         q_16_45.q18_1, q_16_45.q18_2, q_16_45.q18_3, q_16_45.q18_4, ;
         q_16_45.q19_1, q_16_45.q19_2, q_16_45.q19_3, q_16_45.q19_4, ;
         q_16_45.q20_1, q_16_45.q20_2, q_16_45.q20_3, q_16_45.q20_4, ;
         q_16_45.q21_1, q_16_45.q21_2, q_16_45.q21_3, q_16_45.q21_4, ;
         q_16_45.q22_1, q_16_45.q22_2, q_16_45.q22_3, q_16_45.q22_4, ;
         q_16_45.q23_1, q_16_45.q23_2, q_16_45.q23_3, q_16_45.q23_4, ;
         q_16_45.q24_1, q_16_45.q24_2, q_16_45.q24_3, q_16_45.q24_4, ;
         q_16_45.q25_1, q_16_45.q25_2, q_16_45.q25_3, q_16_45.q25_4, ;
         q_16_45.q26_1, q_16_45.q26_2, q_16_45.q26_3, q_16_45.q26_4, ;
         q_16_45.q27_1, q_16_45.q27_2, q_16_45.q27_3, q_16_45.q27_4, ;
         q_16_45.q28_1, q_16_45.q28_2, q_16_45.q28_3, q_16_45.q28_4, ;
         q_16_45.q29_1, q_16_45.q29_2, q_16_45.q29_3, q_16_45.q29_4, ;
         q_16_45.q30_1, q_16_45.q30_2, q_16_45.q30_3, q_16_45.q30_4, ;
         q_16_45.q31_1, q_16_45.q31_2, q_16_45.q31_3, q_16_45.q31_4, ;
         q_16_45.q32_1, q_16_45.q32_2, q_16_45.q32_3, q_16_45.q32_4, ;
         q_16_45.q33_1, q_16_45.q33_2, q_16_45.q33_3, q_16_45.q33_4, ;
         q_16_45.q34_1, q_16_45.q34_2, q_16_45.q34_3, q_16_45.q34_4, ;
         q_16_45.q35_1, q_16_45.q35_2, q_16_45.q35_3, q_16_45.q35_4, ;
         q_16_45.q36_1, q_16_45.q36_2, q_16_45.q36_3, q_16_45.q36_4, ;
         q_16_45.q37_1, q_16_45.q37_2, q_16_45.q37_3, q_16_45.q37_4, ;
         q_16_45.q38_1, q_16_45.q38_2, q_16_45.q38_3, q_16_45.q38_4, ;
         q_16_45.q39_1, q_16_45.q39_2, q_16_45.q39_3, q_16_45.q39_4, ;
         q_16_45.q40_1, q_16_45.q40_2, q_16_45.q40_3, q_16_45.q40_4, ;
         q_16_45.q41_1, q_16_45.q41_2, q_16_45.q41_3, q_16_45.q41_4, ;
         q_16_45.q42_1, q_16_45.q42_2, q_16_45.q42_3, q_16_45.q42_4, ;
         q_16_45.q43_1, q_16_45.q43_2, q_16_45.q43_3, q_16_45.q43_4, ;
         q_16_45.q44_1, q_16_45.q44_2, q_16_45.q44_3, q_16_45.q44_4, ;
         q_16_45.q45_1, q_16_45.q45_2, q_16_45.q45_3, q_16_45.q45_4, ;
         q_46_66.q46, q_46_66.q47, q_46_66.q48, ;
         q_46_66.q49, q_46_66.q50, q_46_66.q51, ;
         q_46_66.q52, q_46_66.q53, q_46_66.q54, ;
         q_46_66.q55, q_46_66.q56, q_46_66.q57, ;
         q_46_66.q58, q_46_66.q59, q_46_66.q60, ;
         q_46_66.q61, q_46_66.q62, q_46_66.q63, ;
         q_46_66.q64, q_46_66.q65, q_46_66.q66 , ;
         curqh_qh_id As qh_id;
         From q_1_15 ;
         Left Outer Join q_16_45 On ;
         q_1_15.tc_id = q_16_45.tc_id ;
         Left Outer Join q_46_66 On;
         q_1_15.tc_id = q_46_66.tc_id ;
         Into Cursor cl_detail

      If norder=1
         Index On Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
      Else
         Index On Upper(Padl(id_no,10,'0')) Tag col1
      Endif

      Set Order To col1
      Go Top

      gcrptname = 'rpt_rsr_client_detail'
      Do Case
      Case lprev=(.F.)
         Report Form rpt_rsr_client_detail.frx To Printer Prompt Noconsole Nodialog

      Case lprev=(.T.)
         oapp.rpt_print(5, .T., 1, 'rpt_rsr_client_detail', 1, 2)
      Endcase

   Case lnstat = 2  && RSR Client Demographics  (Questions 1-15)
      Select * ;
         From q_1_15 ;
         Into Cursor cl_detail

      If norder=1
         Index On Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
      Else
         Index On Upper(Padl(id_no,10,'0')) Tag col1
      Endif

      Set Order To col1
      Go Top

      gcrptname = 'rpt_rsr_client_demogr'
      Do Case
      Case lprev=(.F.)
         Report Form rpt_rsr_client_demogr.frx To Printer Prompt Noconsole Nodialog

      Case lprev=(.T.)
         oapp.rpt_print(5, .T., 1, 'rpt_rsr_client_demogr', 1, 2)
      Endcase
   Case lnstat = 3  && RSR Client Clinical information (Questions 46-66)
      Select * ;
         From q_46_66 ;
         Into Cursor cl_detail

      If norder=1
         Index On Upper(Alltrim(last_name)+Alltrim(first_name)) Tag col1
      Else
         Index On Upper(Padl(id_no,10,'0')) Tag col1
      Endif

      Set Order To col1
      Go Top

      gcrptname = 'rpt_rsr_client_clinic'
      Do Case
      Case lprev=(.F.)
         Report Form rpt_rsr_client_clinic.frx To Printer Prompt Noconsole Nodialog

      Case lprev=(.T.)
         oapp.rpt_print(5, .T., 1, 'rpt_rsr_client_clinic', 1, 2)
      Endcase

   Endcase

Else
   oapp.msg2user('NOTFOUNDG')

Endif

gctc_id=coldgctc_id
gcclient_id=cclientidhold

Return
****Create Services********************************************************************
Function create_curservices
Parameters dstart, dending, ctc_id

Local noldarea
noldarea=Select()

If Used('fundtype')=(.F.)
   Use fundtype In 0 Order Tag Code
   lkillfundtype=.T.
Else
   lkillfundtype=.F.
Endif

Create Cursor curallservices ;
   (service_id i,;
   service_date d,;
   act_id c(10), ;
   enc_id i,;
   serv_cat c(05),;
   rsr_flag l,;
   tc_id c(10) )

Local ;
   iservice_id,;
   dservice_date,;
   iact_id,;
   ienc_id,;
   cserv_cat

iservice_id=0
dservice_date={}
iact_id=0
ienc_id=0
cserv_cat=''
lrsr_flag=.F.

Select ai_enc
Set Order To act_id

Select ai_serv
Set Order To rsr_tag

Select curservpool.* ;
   From curservpool ;
   Into Cursor t_serv ;
   Order By tc_id


Select t_serv
Scan
   lctc_id = t_serv.tc_id
   Select ai_serv
   If Seek(lctc_id)
      Locate For tc_id=lctc_id And Between(Date, dstart, dending)
      If Found()
         Scan While tc_id=lctc_id And Between(Date, dstart, dending)
            If Seek(ai_serv.act_id,'ai_enc','act_id')
               Dimension _arsrflag(1,2)
               _arsrflag[1,1]=''
               _arsrflag[1,2]=.F.

               lrsr_flag=.F.
               luserec=.T.
               If Seek(ai_enc.Program,'program','prog_id')=(.T.)
*!* Since the _curcp1 cursor only containes RW Funded programs no need to do all the checking

                  Select fundtype, ;
                     rsr_flag ;
                     From _curcp1 ;
                     Where prog_id=ai_enc.Program ;
                     Into Array _arsrflag

                  If _Tally > 0
                     lrsr_flag=.T.
                     luserec=.T.
                     If !Empty(cfundtypeselected)
                        If _arsrflag[1,1] <> cfundtypeselected
                           luserec=.F.
                        Endif
                     Endif
                  Else
                     If Seek(ai_enc.Program,'program','prog_id')
                        cfundingtype=Program.fund_type
                        lrsr_flag=Iif(Seek(cfundingtype,'fundtype','code'),fundtype.rsr_flag,.F.)
                        If !Empty(cfundtypeselected)
                           If Program.fund_type <> cfundtypeselected
                              luserec=.F.
                           Endif
                        Endif
                     Else
                        luserec=.F.
                     Endif
                  Endif
               Else
                  luserec=.F.
               Endif
            Else
               luserec=.F.
            Endif

            If luserec=(.T.) And lrsr_flag=(.T.)
               If Seek(ai_enc.Program,'_curPrograms','prog_id')=(.F.)
                  Insert Into _curprograms (prog_id) Values (ai_enc.Program)
               Endif

               iservice_id=ai_serv.service_id
               dservice_date=ai_serv.Date
               iact_id=ai_serv.act_id
               ienc_id=ai_enc.enc_id
               cserv_cat=ai_enc.serv_cat
               Insert Into curallservices ;
                  (service_id, ;
                  service_date, ;
                  act_id, ;
                  enc_id, ;
                  serv_cat, ;
                  rsr_flag, tc_id) ;
                  Values ;
                  (iservice_id, ;
                  dservice_date, ;
                  iact_id, ;
                  ienc_id, ;
                  cserv_cat, ;
                  lrsr_flag, lctc_id)
            Endif

            iservice_id=0
            dservice_date={}
            iact_id=0
            ienc_id=0
            cserv_cat=''
            lrsr_flag=.F.

            Select ai_serv
         Endscan
      Endif
   Endif
   Select t_serv

Endscan

If lkillfundtype=(.T.)
   Use In fundtype
Endif

Use In t_serv

*!* #7923
Select curallservices
Delete From curallservices Where rsr_flag=.F.
Go Top

Index On service_id Tag serv_id AddIt

*!* When mapping are used as filters.
Select b.service_date, ;
   a.rsr_type,;
   a.service_id, ;
   a.srv_description, ;
   a.rsr_description, ;
   a.mapping_code, ;
   b.rsr_flag, ;
   b.tc_id, ;
   a.rsr_serviceid;
   From lv_rsr_services a;
   Join curallservices b ;
   On a.service_id=b.service_id ;
   And a.serv_cat=b.serv_cat ;
   And a.enc_id=b.enc_id;
   Into Cursor curservices;
   Order By a.display_order, a.srv_description

Select(noldarea)

Return Reccount('curServices')


********Service Delivered******
Function fill_servicedelivered
Parameters  lctc_id, dending

Select Distinct ;
   service_date, ;
   mapping_code, ;
   0 As quarterid, ;
   00 As rsr_serviceid,;
   2 As provided;
   From curservices ;
   Into Cursor _cursupportive Readwrite ;
   Where rsr_type='S';
   And tc_id = lctc_id;
   Order By 1, 2

Update _cursupportive ;
   Set rsr_serviceid =rsr_service_definitions.rsr_serviceid,;
   quarterid = Icase(Between(Month(service_date),1,3),1,;
   Between(Month(service_date),4,6),2,;
   Between(Month(service_date),7,9),3,;
   4);
   From _cursupportive , rsr_service_definitions ;
   Where rsr_service_definitions.mapping_code=_cursupportive.mapping_code ;
   and rsr_service_definitions.rsr_type='S'

Select _cursupportive
Delete  For quarterid = 0

If Month(dending)=6
   Delete For quarterid > 2
Endif

*!*   Use In cuXXX
Return

*************Test Risk**********
Function test_risk_reduction_screening
Parameters lctc_id
ncode=0

gctc_id=q_46_66.tc_id
ncode=orsrmethods.test_risk_reduction_screening()

Return ncode

*****QUESTION 6
*******************************************************************************
Function q_6
Select  q_1_15
Scan
   orsrmethods.id6(q_1_15.client_id)
   Select currace
   Go Top
   crace =''
   Scan
      crace = crace + Iif(Empty(crace), '', ', ') + ;
         Iif(currace.raceid=1,  'White' ,;
         Iif(currace.raceid=2,  'Black or African American', ;
         Iif(currace.raceid=3,  'Asian', ;
         Iif(currace.raceid=4,  'Native Hawaiian/Pacific Islander',;
         Iif(currace.raceid=5,  'American Indian or Alaskan Native', ;
         'Unknown')))))
   Endscan
   Select  q_1_15
   Replace q6 With crace
   crace=''
Endscan

Use In currace
Return

*********QUESTION 13******************
Function q_13
Lparameters cltc_id, chivstatid, hiv_status_date
Local lcreturncode As Character, cyear1 As Character, cyear2 As Character
lcreturncode=''
cyear1='9999'
cyear2='9999'

vlhiv_status_date=Iif(Empty(Nvl(hiv_status_date,'')),'9999',Transform(Year(hiv_status_date),'9999'))

If chivstatid=4
   Dimension adiagdate1(1)
   Dimension adiagdate2(1)

   adiagdate1[1]={}
   adiagdate2[1]={}

   Select Min(diagdate) From ai_diag Where tc_id=cltc_id And !Empty(hiv_icd9) Into Array adiagdate1
   cyear1=Iif(Empty(Nvl(adiagdate1[1],'')),'9999',Transform(Year(adiagdate1[1]),'9999'))

   Select Min(testdate) From testres Where tc_id=cltc_id And Count < 200 And testtype='06' Into Array adiagdate2
   cyear2=Iif(Empty(Nvl(adiagdate2[1],'')),'9999',Transform(Year(adiagdate2[1]),'9999'))

Else
   cyear1=''
   cyear2=''
   vlhiv_status_date=''

Endif

lcreturncode=Min(vlhiv_status_date, cyear1, cyear2)

Return Iif(lcreturncode='9999','',lcreturncode)

*******************QUESTION 14
Function q_14

Select  q_1_15
Scan
   orsrmethods.id14(q_1_15.tc_id,'_curRisk')
   Select Distinct hivriskfct From _currisk Into Cursor t_risk
   Go Top
   cdesc =''
   Scan
      cdesc = cdesc + Iif(Empty(cdesc), '', ', ') + ;
         Iif(t_risk.hivriskfct=1,  'Male who has sex with male(s) (MSM)' ,;
         Iif(t_risk.hivriskfct=2,  'Injecting drug use (IDU)', ;
         Iif(t_risk.hivriskfct=3,  'Hemophilia/coagulation disorder', ;
         Iif(t_risk.hivriskfct=4,  'Heterosexual contact',;
         Iif(t_risk.hivriskfct=5,  'Receipt of blood transfusion, blood components, or tissue', ;
         Iif(t_risk.hivriskfct=6,  'Mother w/at risk for HIV infection (perinatal transmission)' ,;
         Iif(t_risk.hivriskfct=7,  'Other', 'Unknown')))))))
   Endscan

   Select  q_1_15
   Replace q14 With cdesc
   cdesc = ''
   Use In t_risk
   Use In _currisk

Endscan


Return

************QUESTION 15
Function q_15
Select  q_1_15
Scan
   If orsrmethods.id15(q_1_15.client_id, '_curMedIns')=0
      cmeddesc ='Unknown'
   Else
      Select Distinct medicalins From _curmedins Into Cursor t_medins
      Go Top
      cmeddesc =''
      Scan
         cmeddesc = cmeddesc +  Iif(Empty(cmeddesc), '', ', ') + ;
            Iif(t_medins.medicalins=1,  'Private' ,;
            Iif(t_medins.medicalins=2,  'Medicare', ;
            Iif(t_medins.medicalins=3,  'Medicaid', ;
            Iif(t_medins.medicalins=4,  'Other Public',;
            Iif(t_medins.medicalins=5,  'No Insurance', 'Other')))))
      Endscan
   Endif

   Select  q_1_15
   Replace q15 With cmeddesc
   cmeddesc = ''
Endscan

If Used('t_MedIns')
   Use In t_medins
Endif

Use In _curmedins
Return
***************************
*!* Core Services  ID's 16 - 25
Function q16_25

Select Distinct ;
   tc_id,;
   service_date, ;
   rsr_serviceid As serviceid;
   From curservices ;
   Into Cursor _curtempx;
   Where rsr_type='C';
   Order By 1, 2

*!* Group them up by quarter & mapping code
Select ;
   tc_id,;
   Quarter(service_date) As quarterid, ;
   serviceid,;
   Count(*) As visits;
From _curtempx ;
Group By 1,2,3  ;
Into Cursor serv_vis;
Order By 1,2,3

**Q 16 - Service 16
Update q_16_45 ;
   Set q16_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 8  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q16_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 8  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q16_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 8  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q16_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 8  ;
   And serv_vis.quarterid=4

**Q 17 - Service 17
Update q_16_45 ;
   Set q17_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 10  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q17_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 10  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q17_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 10  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q17_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 10  ;
   And serv_vis.quarterid=4

**Q 18 - Service 18
Update q_16_45 ;
   Set q18_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 11  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q18_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 11  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q18_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 11  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q18_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 11  ;
   And serv_vis.quarterid=4

**Q 19 - Service 19
Update q_16_45 ;
   Set q19_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 13  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q19_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 13  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q19_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 13  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q19_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 13  ;
   And serv_vis.quarterid=4

**Q 20 - Service 20
Update q_16_45 ;
   Set q20_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 14  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q20_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 14  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q20_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 14  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q20_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 14  ;
   And serv_vis.quarterid=4

**Q 21 - Service 21
Update q_16_45 ;
   Set q21_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 15  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q21_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 15  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q21_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 15  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q21_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 15  ;
   And serv_vis.quarterid=4

**Q 22 - Service 22
Update q_16_45 ;
   Set q22_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 16  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q22_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 16  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q22_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 16  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q22_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 16  ;
   And serv_vis.quarterid=4

**Q 23 - Service 23
Update q_16_45 ;
   Set q23_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 17  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q23_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 17  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q23_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 17  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q23_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 17  ;
   And serv_vis.quarterid=4

**Q 24 - Service 24
Update q_16_45 ;
   Set q24_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 18  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q24_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 18  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q24_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 18  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q24_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 18  ;
   And serv_vis.quarterid=4

**Q 25 - Service 25
Update q_16_45 ;
   Set q25_1 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 19  ;
   And serv_vis.quarterid=1

Update q_16_45 ;
   Set q25_2 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 19  ;
   And serv_vis.quarterid=2

Update q_16_45 ;
   Set q25_3 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 19  ;
   And serv_vis.quarterid=3

Update q_16_45 ;
   Set q25_4 = serv_vis.visits;
   from  q_16_45;
   inner Join serv_vis On ;
   serv_vis.tc_id = q_16_45.tc_id ;
   And serv_vis.serviceid = 19  ;
   And serv_vis.quarterid=4
Use In serv_vis
Return
*******************
Function q26_45
*!* Supportive Services  ID's 26 -45

Select q_16_45
Scan
   =fill_servicedelivered(q_16_45.tc_id, curqh_h_end)
   Store ' ' To  cprovdesc

   Select _cursupportive
   Go Top
   Scan
      cprovdesc = Iif(_cursupportive.provided=1, 'No', ;
         Iif(_cursupportive.provided=2, 'Yes', '   ' ) )

      nserv_id = _cursupportive.rsr_serviceid
      nq_id = _cursupportive.quarterid
**VT 12/11/2009 Changed serv_id according to Dev Tick 6348 ( Example old id 2 - new 9)
      Select q_16_45
      Do Case
      Case nserv_id = 9    &&2      &&Q26
         Do Case
         Case nq_id=1
            Replace q26_1 With  cprovdesc
         Case nq_id=2
            Replace q26_2 With  cprovdesc
         Case nq_id=3
            Replace q26_3 With  cprovdesc
         Case nq_id=4
            Replace q26_4 With  cprovdesc
         Endcase

      Case nserv_id = 12  &&5     &&Q27
         Do Case
         Case nq_id=1
            Replace q27_1 With  cprovdesc
         Case nq_id=2
            Replace q27_2 With  cprovdesc
         Case nq_id=3
            Replace q27_3 With  cprovdesc
         Case nq_id=4
            Replace q27_4 With  cprovdesc
         Endcase
      Case nserv_id = 20  &&13     &&Q28
         Do Case
         Case nq_id=1
            Replace q28_1 With  cprovdesc
         Case nq_id=2
            Replace q28_2 With  cprovdesc
         Case nq_id=3
            Replace q28_3 With  cprovdesc
         Case nq_id=4
            Replace q28_4 With  cprovdesc
         Endcase
      Case nserv_id = 21  &&14     &&Q29
         Do Case
         Case nq_id=1
            Replace q29_1 With  cprovdesc
         Case nq_id=2
            Replace q29_2 With  cprovdesc
         Case nq_id=3
            Replace q29_3 With  cprovdesc
         Case nq_id=4
            Replace q29_4 With  cprovdesc
         Endcase
      Case nserv_id = 22  &&15     &&Q30
         Do Case
         Case nq_id=1
            Replace q30_1 With  cprovdesc
         Case nq_id=2
            Replace q30_2 With  cprovdesc
         Case nq_id=3
            Replace q30_3 With  cprovdesc
         Case nq_id=4
            Replace q30_4 With  cprovdesc
         Endcase
      Case nserv_id = 23   &&16     &&Q31
         Do Case
         Case nq_id=1
            Replace q31_1 With  cprovdesc
         Case nq_id=2
            Replace q31_2 With  cprovdesc
         Case nq_id=3
            Replace q31_3 With  cprovdesc
         Case nq_id=4
            Replace q31_4 With  cprovdesc
         Endcase
      Case nserv_id = 24      &&17     &&Q32
         Do Case
         Case nq_id=1
            Replace q32_1 With  cprovdesc
         Case nq_id=2
            Replace q32_2 With  cprovdesc
         Case nq_id=3
            Replace q32_3 With  cprovdesc
         Case nq_id=4
            Replace q32_4 With  cprovdesc
         Endcase
      Case nserv_id = 25      &&18     &&Q33
         Do Case
         Case nq_id=1
            Replace q33_1 With  cprovdesc
         Case nq_id=2
            Replace q33_2 With  cprovdesc
         Case nq_id=3
            Replace q33_3 With  cprovdesc
         Case nq_id=4
            Replace q33_4 With  cprovdesc
         Endcase
      Case nserv_id = 26     &&19     &&Q34
         Do Case
         Case nq_id=1
            Replace q34_1 With  cprovdesc
         Case nq_id=2
            Replace q34_2 With  cprovdesc
         Case nq_id=3
            Replace q34_3 With  cprovdesc
         Case nq_id=4
            Replace q34_4 With  cprovdesc
         Endcase
      Case nserv_id = 27     &&20     &&Q35
         Do Case
         Case nq_id=1
            Replace q35_1 With  cprovdesc
         Case nq_id=2
            Replace q35_2 With  cprovdesc
         Case nq_id=3
            Replace q35_3 With  cprovdesc
         Case nq_id=4
            Replace q35_4 With  cprovdesc
         Endcase
      Case nserv_id = 28   &&21     &&Q36
         Do Case
         Case nq_id=1
            Replace q36_1 With  cprovdesc
         Case nq_id=2
            Replace q36_2 With  cprovdesc
         Case nq_id=3
            Replace q36_3 With  cprovdesc
         Case nq_id=4
            Replace q36_4 With  cprovdesc
         Endcase
      Case nserv_id = 29    &&22     &&Q37
         Do Case
         Case nq_id=1
            Replace q37_1 With  cprovdesc
         Case nq_id=2
            Replace q37_2 With  cprovdesc
         Case nq_id=3
            Replace q37_3 With  cprovdesc
         Case nq_id=4
            Replace q37_4 With  cprovdesc
         Endcase
      Case nserv_id = 30    &&23     &&Q38
         Do Case
         Case nq_id=1
            Replace q38_1 With  cprovdesc
         Case nq_id=2
            Replace q38_2 With  cprovdesc
         Case nq_id=3
            Replace q38_3 With  cprovdesc
         Case nq_id=4
            Replace q38_4 With  cprovdesc
         Endcase
      Case nserv_id = 31    &&24     &&Q39
         Do Case
         Case nq_id=1
            Replace q39_1 With  cprovdesc
         Case nq_id=2
            Replace q39_2 With  cprovdesc
         Case nq_id=3
            Replace q39_3 With  cprovdesc
         Case nq_id=4
            Replace q39_4 With  cprovdesc
         Endcase
      Case nserv_id = 32      &&25     &&Q40
         Do Case
         Case nq_id=1
            Replace q40_1 With  cprovdesc
         Case nq_id=2
            Replace q40_2 With  cprovdesc
         Case nq_id=3
            Replace q40_3 With  cprovdesc
         Case nq_id=4
            Replace q40_4 With  cprovdesc
         Endcase
      Case nserv_id = 33   &&26     &&Q41
         Do Case
         Case nq_id=1
            Replace q41_1 With  cprovdesc
         Case nq_id=2
            Replace q41_2 With  cprovdesc
         Case nq_id=3
            Replace q41_3 With  cprovdesc
         Case nq_id=4
            Replace q41_4 With  cprovdesc
         Endcase
      Case nserv_id = 34   &&27     &&Q42
         Do Case
         Case nq_id=1
            Replace q42_1 With  cprovdesc
         Case nq_id=2
            Replace q42_2 With  cprovdesc
         Case nq_id=3
            Replace q42_3 With  cprovdesc
         Case nq_id=4
            Replace q42_4 With  cprovdesc
         Endcase
      Case nserv_id = 35  &&28     &&Q43
         Do Case
         Case nq_id=1
            Replace q43_1 With  cprovdesc
         Case nq_id=2
            Replace q43_2 With  cprovdesc
         Case nq_id=3
            Replace q43_3 With  cprovdesc
         Case nq_id=4
            Replace q43_4 With  cprovdesc
         Endcase
      Case nserv_id = 36  &&29     &&Q44
         Do Case
         Case nq_id=1
            Replace q44_1 With  cprovdesc
         Case nq_id=2
            Replace q44_2 With  cprovdesc
         Case nq_id=3
            Replace q44_3 With  cprovdesc
         Case nq_id=4
            Replace q44_4 With  cprovdesc
         Endcase
      Case nserv_id = 37    &&30     &&Q45
         Do Case
         Case nq_id=1
            Replace q45_1 With  cprovdesc
         Case nq_id=2
            Replace q45_2 With  cprovdesc
         Case nq_id=3
            Replace q45_3 With  cprovdesc
         Case nq_id=4
            Replace q45_4 With  cprovdesc
         Endcase
      Endcase
      Select _cursupportive
   Endscan
   Use In _cursupportive

   Select q_16_45
   Store ' ' To  cprovdesc
Endscan
Return
****Question 46  **********************************************
Function q_46
Select q_46_66
Scan
   If is_medical =.T. And hivstatid <> 5
      lctc_id = q_46_66.tc_id
      Replace q46_code With Iif(test_risk_reduction_screening(lctc_id) > 0, 2, q46_code)
      Replace q46 With Iif(q46_code = 2 , 'Yes', Iif(q46_code = 3,'Unknown', 'No'))
   Else
      If is_medical =(.T.)
         Replace q46 With 'Unknown'
      Else
         Replace q46 With ''
      EndIf 
   Endif
Endscan
Return
***Question q_47 ********************************
Function q_47
Select q_46_66
Scan
   If q_46_66.is_medical = .T. And hivstatid <> 5
      gctc_id = q_46_66.tc_id
      Replace q47 With Strtran(orsrmethods.q47(.T.) ,',','/')
   Else
      If is_medical =(.T.)
         Replace q46 With 'Unknown'
      Else
         Replace q46 With ''
      EndIf 
   Endif
Endscan

Return
***Question q_48
Function q_48
Select q_46_66
Scan
   If q_46_66.is_medical = .T. And hivstatid <> 5
      cdate48 = ''
      lctc_id=q_46_66.tc_id
      Select service_date, ;
         rsr_description ;
         From curservices ;
         Where Alltrim(mapping_code)=='33A';
         And tc_id = lctc_id ;
         Group By rsr_description, service_date;
         Into Cursor t_48;
         Order By 1

      Scan
         cdate48 = cdate48 + Iif(Empty(cdate48), '', '  ') + Dtoc(t_48.service_date)
      Endscan
      Use In t_48
      Select q_46_66
      Replace q48 With  cdate48
   Endif
Endscan

Return
***Question q_49 ********************************************************
Function q_49
Parameters dstart, dend

Select q_46_66
Scan
   If q_46_66.is_medical = .T. And hivstatid <> 5
      cdate49 = ''
      lctc_id = q_46_66.tc_id
      Select Count As cd4count,;
         testdate ;
         From testres ;
         Where tc_id=lctc_id ;
         And testtype='06' ;
         And Between(testdate, dstart, dend);
         And Count > 0 ;
         Into Cursor t_49;
         Order By 1

      Scan
         cdate49 = cdate49 + Iif(Empty(cdate49), '', '  ') + 'CD4 Count=' + Alltrim(Str(t_49.cd4count)) + '  ' + Dtoc(t_49.testdate)
      Endscan
      Use In t_49
      Select q_46_66
      Replace q49 With  cdate49
   Endif
Endscan
Return
***Question q_50 ***********************************************************
Function q_50
Parameters dstart, dend

Select q_46_66
Scan
   If is_medical=(.T.) And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q50('t_50')
      cdate50 = ''

      Select t_50
      Go Top

      Scan
         cdate50 = cdate50 + Iif(Empty(cdate50), '', '  ') + 'Viral Load Count=' + Iif(t_50.cd4count>-1,Alltrim(Str(t_50.cd4count)),'Undetectable') + '  ' + Dtoc(t_50.testdate)
      Endscan

      Use In t_50
      Select q_46_66
      Replace q50 With  cdate50

   Endif
Endscan

Return
***Question q_51 ********************************************
Function q_51
Dimension ajunk(1)
ajunk[1]=0

Select q_46_66
Scan
   If is_medical =.T. And hivstatid <> 5
      lctc_id = q_46_66.tc_id
      Select Count(*) ;
         From curallservices ;
         Where service_id=1037 ;
         And rsr_flag=(.T.) ;
         And tc_id =lctc_id ;
         Into Array ajunk

      Replace q51_code With Iif(ajunk[1] > 0, 2, q51_code)

   Else
      If is_medical =.T.
         Replace q51 With 'Unknown'
      Else
         Replace q51 With ''
      Endif
   Endif
   ajunk[1]=0
Endscan

Update  q_46_66 ;
   Set q51 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 51  ;
   and rsd.rsr_code = q_46_66.q51_code

Return
***Question q_52 ******************************************
Function q_52
Parameters dstart, dend

Dimension apres_his(1)
apres_his[1]=0

Select q_46_66
Scan
   If is_medical=(.T.) And hivstatid <> 5
      gcclient_id = q_46_66.client_id
      ncode=orsrmethods.q52()
                            
      Replace q52_code With Iif(ncode<>0, ncode, q52_code)
   Else
      If is_medical =.T.
         Replace q52 With 'Unknown'
      Else
         Replace q52 with ''
      EndIf 
   Endif
Endscan

gcclient_id= ' '

Update  q_46_66 ;
   Set q52 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 52  ;
   and rsd.rsr_code = q_46_66.q52_code

Return

***Question q_53 ******************************************
Function q_53
Parameters dstart, dend

Select q_46_66
Scan
   If is_medical=(.T.) And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q53()
      Replace q53_code With Iif(ncode > 0, ncode, q53_code)

   Else
      If is_medical =.T.
         Replace q53 With 'Unknown'
      Else
         Replace q53 With ''
      EndIf 
   Endif
Endscan

Update  q_46_66 ;
   Set q53 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 53  ;
   and rsd.rsr_code = q_46_66.q53_code

Return
***Question q_55 ******************************************
Function q_55
Parameters dstart, dend

Select q_46_66
Scan
   If is_medical=(.T.) And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q55()
      Replace q55_code With Iif(ncode > 0, ncode, q55_code)

   Else
      If is_medical =.T.
         Replace q55 With 'Unknown'
      Else
         Replace q55 With ''
      EndIf 
   Endif
Endscan

Update  q_46_66 ;
   Set q55 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 53  ;       && 53 becase 53 has the same value as 55
And rsd.rsr_code = q_46_66.q55_code

Return
***Question q_56 ******************************************
Function q_56
Parameters dstart, dend

Scan
   If is_medical=(.T.) And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q56()
      Replace q56_code With Iif(ncode > 0, ncode, q56_code)

   Else
      If is_medical =.T.
         Replace q56 With 'Unknown'
      Else
         REplace q56 With ''
      EndIf 
      
   Endif
Endscan

Update  q_46_66 ;
   Set q56 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 53  ;       && 53 becase 53 has the same value as 56
And rsd.rsr_code = q_46_66.q56_code

Return
***Question q_58 ******************************************
Function q_58

Select q_46_66
Scan
   If is_medical=(.T.) And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q58()
      Replace q58_code With Iif(ncode > 0, ncode, q58_code)

   Else
      If is_medical =.T.
         Replace q58 With 'Unknown'
      Else
         Replace q58 With ''
      EndIf 
   Endif
Endscan

Update  q_46_66 ;
   Set q58 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 53  ;       && 53 becase 53 has the same value as 58
And rsd.rsr_code = q_46_66.q58_code

Return
***Question q_59 ******************************************
Function q_59
Parameters dstart, dend

Select q_46_66
Scan
   If is_medical=(.T.) And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q59()
      Replace q59_code With Iif(ncode > 0, ncode, q59_code)

   Else
      If is_medical =.T.
         Replace q59 With 'Unknown'
      Else
         Replace q59 With ''
      EndIf 
   Endif
Endscan

Update  q_46_66 ;
   Set q59 = rsd.Description;
from q_46_66,  ;
   rsr_description rsd ;
where rsd.question_number = 53  ;   && 53 becase 53 has the same value as 59
      And rsd.rsr_code = q_46_66.q59_code

Return
***Question q_61 ******************************************
Function q_61
Dimension ajunk(1)
ajunk[1]=0

Select q_46_66
Scan
   If is_medical =.T. And hivstatid <> 5
      gctc_id=q_46_66.tc_id
      ncode=orsrmethods.q61()
      Replace q61_code With Iif(ncode > 0, 2, q61_code)
   Else
      If is_medical =.T.
         Replace q61 With 'Unknown'
      Else
         Replace q61 With ''
      EndIf 
   Endif
   ajunk[1]=0
Endscan

Update  q_46_66 ;
   Set q61 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 53  ;       && 53 becase 53 has the same value as 61
And rsd.rsr_code = q_46_66.q61_code

Return
***Question q_62 ******************************************
Function q_62
Dimension ajunk(1)
ajunk[1]=0

Select q_46_66
Scan
   If is_medical =.T. And hivstatid <> 5
      lctc_id = q_46_66.tc_id

      Select Count(*) ;
         From curallservices ;
         Where Inlist(service_id,693,694,698,1189);
         And rsr_flag=(.T.) ;
         And tc_id=lctc_id ;
         Into Array ajunk

      Replace q62_code With Iif(ajunk[1] > 0, 2, q62_code)

   Else
      If is_medical =.T.
         Replace q62 With 'Unknown'
      Else
         Replace q62 With ''
      EndIf 
   Endif
   ajunk[1]=0
Endscan

Update  q_46_66 ;
   Set q62 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 53  ;       && 53 becase 53 has the same value as 62
And rsd.rsr_code = q_46_66.q62_code

Return

***Question q_63 ******************************************
Function q_63 (dstart, dend)

Select q_46_66
Scan
   gctc_id=q_46_66.tc_id
   =orsrmethods.determine_hiv_status(dstart, dend)
   If is_medical=(.T.) And sex='F' And !Inlist(orsrmethods.hivstatid,1,5,6)
      nq63code=orsrmethods.q63()
      If nq63code > 0
         Replace q63_code With nq63code
      Endif
   Else
      Replace q63 With '', q63_code With 0
   Endif
Endscan

Update  q_46_66 ;
   Set q63 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 63  ;
   and rsd.rsr_code = q_46_66.q63_code ;
   and Empty(q63) ;
   and is_medical =.T. And sex ='F'

Return
***Question q_64 ******************************************
Function q_64
Parameters dstartdate, denddate, nlq64_code

Select q_46_66
Scan
   If sex='F'
      gctc_id = q_46_66.tc_id
      =orsrmethods.determine_hiv_status(dstartdate, denddate)
      If is_medical =(.T.) And orsrmethods.hiv_status_code <> '07'
         If Between(age,11,50)=(.T.) && pregnancy range
            lnowaschecked=.F.
            cpregnantid = orsrmethods.q64(@lnowaschecked)
            nlpstauscode = Icase(lnowaschecked=(.T.),1, !Empty(cpregnantid), 2, 4)
            Replace q64_code With nlpstauscode, preg_status_id With cpregnantid

         Else
            *!* Per ticket 37451 - Set to 0 & Empty
            Replace q64 With 'Not Applicable', q64_code With 3, preg_status_id With ''
         Endif
      Else
         Replace q64 With ' ', q64_code With 0, preg_status_id With ''
      Endif
   Else
      Replace q64 With ' ', q64_code With 0, preg_status_id With ''
   Endif
Endscan

Update  q_46_66 ;
   Set q64 = rsd.Description;
From q_46_66,  ;
   rsr_description rsd ;
Where rsd.question_number = 64  ;
   and rsd.rsr_code = q_46_66.q64_code ;
   and Empty(q64) ;
   and is_medical =.T. And sex ='F'

Return

***Question q_65 ******************************************
Function q_65
ntrimester=0
Select q_46_66
Scan
   gctc_id = q_46_66.tc_id
   =orsrmethods.determine_hiv_status(orsrmethods.dstart, orsrmethods.dend)
   If is_medical =.T. And !Inlist(orsrmethods.hivstatid,1,5,6)
      If sex='F'
         If Between(age,11,50)=(.T.) && pregnancy range
            If !Empty(q_46_66.preg_status_id)
               =Seek(q_46_66.preg_status_id,'pregnant','status_id')
               If pregnant.preg_type=3 Or pregnant.preg_type=0
                  ntrimester=Icase(Between(pregnant.care_start,1,3),1,Between(pregnant.care_start,4,6),2,Between(pregnant.care_start,7,9),3,-1)
               Else
                  ntrimester=99
               Endif

               Replace q65_code With Icase(ntrimester=99, 5, ntrimester=-1, 6, ntrimester)
            Else
               Replace q65 With ' ', q65_code With 0
            Endif
         Else
*!* Per Ticket #37451: Set to empty
            Replace q65 With ' ', q65_code With 0
         Endif
      Endif
   Else
      Replace q65 With ' ', q65_code With 0
   Endif
Endscan

Update  q_46_66 ;
   Set q65 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   Where rsd.question_number = 65  ;
   and rsd.rsr_code = q_46_66.q65_code ;
   and Empty(q65) ;
   and is_medical =.T. And sex ='F'

Return

***Question q_66 ******************************************
Function q_66
nlreturncode=0

Select q_46_66
Scan
   gctc_id = q_46_66.tc_id
   =orsrmethods.determine_hiv_status(orsrmethods.dstart, orsrmethods.dend)

   If is_medical =.T. And !Inlist(orsrmethods.hivstatid,1,5,6)
      If sex='F'
         If Between(age,11,50)=(.T.) && pregnancy range
            If !Empty(q_46_66.preg_status_id)
               =Seek(q_46_66.preg_status_id,'pregnant','status_id')
               Do Case
               Case pregnant.preg_type=1 Or pregnant.preg_type=2
                  nlreturncode=99

               Case pregnant.azt_preg=1 Or pregnant.azt_del=1
                  nlreturncode=2

               Case pregnant.azt_preg=2 Or pregnant.azt_del=2
                  nlreturncode=1

               Otherwise
                  nlreturncode=4

               Endcase
               Replace q66_code With Iif(nlreturncode=99, 3, nlreturncode)

            Else
               Replace q66 With ' ', q66_code With 0
            Endif
         Else
            Replace q66 With ' ', q66_code With 0

         Endif
      Endif
   Else
      Replace q66 With ' ', q66_code With 0

   Endif
Endscan

Update  q_46_66 ;
   Set q66 = rsd.Description;
   from q_46_66,  ;
   rsr_description rsd ;
   where rsd.question_number = 64  ;    && 64  the same description as  66
And rsd.rsr_code = q_46_66.q66_code ;
   and Empty(q66) ;
   and is_medical =.T. And sex ='F'

Return
