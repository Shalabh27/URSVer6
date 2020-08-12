Parameters ;
   lPrev,;     && Preview
   aSelvar1,;  && select parameters from selection list
   nOrder,;    && order by
   nGroup,;    && report selection
   lcTitle,;   && report selection
   Date_from,; && from date
   Date_to,;   && to date
   ParamN,;    && name of param
   lnStat,;    && selection(Output)  page 2
   cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)

lcProgx   = ""
&& Search For Parameters
For i = 1 To Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   Endif
Endfor

cDate = Date()
cTime = Time()
* jss, 4/22/04, legal services module: case summary report
* jss, 9/22/04, make changes based on new enc_type mappings (01-46)
Private gchelp
gchelp = "Legal Services Case Summary Report Screen"
cTitle = 'Legal Services Case Summary Report'

= clean_data()
* clients with active cases at the start of the period
If Used('ActBeg')
   Use In ActBeg
Endif

Select Distinct tc_id ;
From ai_enc ;
Where ;
   serv_cat = '00021' And ;
   Program = lcProgx  And ;
   act_dt < Date_from And ;
   (caseclosdt >= Date_from Or Empty(caseclosdt)) ;
Group By tc_id ;
Into Cursor ActBeg

* clients enrolled in a case this period
If Used('EnrInPer')
   Use In EnrInPer
Endif

Select Distinct tc_id ;
From ai_enc ;
Where ;
   serv_cat = '00021' And ;
   Program = lcProgx  And ;
   act_dt >= Date_from And ;
   act_dt <= Date_to ;
Group By tc_id ;
Into Cursor EnrInPer

* clients NEWLY enrolled in a case in period
If Used('NewEnr')
   Use In NewEnr
Endif

Select Distinct tc_id ;
From EnrInPer ;
Where tc_id Not In (Select tc_id From ActBeg) ;
Into Cursor NewEnr

* now, let's get the top 4 referral sources
If Used('NewEnr1')
   Use In NewEnr1
Endif

Select Distinct ne.tc_id, ;
    aicl.ref_src2 ;
From NewEnr ne, ;
     Ai_Clien aicl ;
Where ne.tc_id = aicl.tc_id ;
Into Cursor NewEnr1

* now, count them by ref_source
If Used('NewEnrCnt')
   Use In NewEnrCnt
Endif

Select ref_src2, ;
   Count(*) As refsrccnt ;
From NewEnr1 ;
Into Cursor NewEnrCnt ;
Group By ref_src2

* now, add the description field (blank)   
If Used('NewEnrCnt2')
   Use In NewEnrCnt2
Endif

If Used('NewEnrCnt3')
   Use In NewEnrCnt3
Endif

Select ref_src2, ;
   refsrccnt, ;
   Space(50) As Name ;
From NewEnrCnt ;
Into Cursor NewEnrCnt2

* load the referral source name
oApp.ReopenCur('NewEnrCnt2', 'NewEnrCnt3')
= OPENFILE('REF_IN', 'CODE')

Select NewEnrCnt3
Set Relation To ref_src2 Into ref_in
Go Top
Replace All Name With ref_in.Descript

* now, we only report the top 4
Store 0 To m.refsrce1ct, m.refsrce2ct, m.refsrce3ct, m.refsrce4ct
Store Space(40) To m.refsrce1, m.refsrce2, m.refsrce3, m.refsrce4

Go Top
SRC_CNT = 1
Scan While SRC_CNT < 5 And Not Eof()
   Do Case
      Case SRC_CNT = 1
         m.refsrce1ct = refsrccnt
         m.refsrce1 = Name
         
      Case SRC_CNT = 2
         m.refsrce2ct = refsrccnt
         m.refsrce2 = Name
         
      Case SRC_CNT = 3
         m.refsrce3ct = refsrccnt
         m.refsrce3 = Name
         
      Case SRC_CNT = 4
         m.refsrce4ct = refsrccnt
         m.refsrce4 = Name
         
   Endcase
   SRC_CNT = SRC_CNT + 1
Endscan

* next, determine the case summary info
* get total active cases at start of period
If Used('CsActBeg')
   Use In CsActBeg
Endif

Select act_id, ;
      .T. As DUMMY ;
From ai_enc ;
Where ;
   serv_cat = '00021' And ;
   Program = lcProgx  And ;
   act_dt < Date_from And ;
   (caseclosdt >= Date_from Or Empty(caseclosdt)) ;
Into Cursor CsActBeg

m.caseactbeg = _Tally

* cases opened this period
If Used('CsNewOp')
   Use In CsNewOp
Endif

Select act_id, ;
       .T. As DUMMY ;
From ai_enc ;
Where ;
   serv_cat = '00021' And ;
   Program = lcProgx  And ;
   act_dt >= Date_from And ;
   act_dt <= Date_to ;
Into Cursor CsNewOp

m.casenewop = _Tally

* active cases reported this period
If Used('CsActDur')
   Use In CsActDur
Endif

Select act_id ;
From CsActBeg ;
Union ;
Select act_id ;
From CsNewOp ;
Into Cursor CsActDur

m.caseactdur = _Tally

* cases closed during period
If Used('CsCloDur')
   Use In CsCloDur
Endif

Select ;
        act_id ;
   From ;
      ai_enc ;
   Where ;
      serv_cat = '00021' And ;
      Program = lcProgx  And ;
      (caseclosdt >= Date_from And ;
        caseclosdt <= Date_to) ;
   Into Cursor CsCloDur

m.caseclodur = _Tally

If Used('CsActEnd')
   Use In CsActEnd
Endif

Select act_id ;
From ai_enc ;
Where ;
   serv_cat = '00021' And ;
   Program = lcProgx  And ;
   act_dt <= Date_to  And ;
   (caseclosdt > Date_to Or Empty(caseclosdt)) ;
Into Cursor CsActEnd

m.caseactend = _Tally

* next, we will total by case type (enc_type)
If Used('CsProfile')
   Use In CsProfile
Endif

Select ai_enc.category, ;
     lv_enc_type.Code As case_type, ;
     Count(*) As casetypecnt ;
From ai_enc ;
Join lv_enc_type On ;
   ai_enc.enc_id = lv_enc_type.enc_id And ;
   ai_enc.category = lv_enc_type.category ;
Where act_id In (Select act_id From CsNewOp) ;
Into Cursor CsProfile ;
Group By 1, 2

* now, initialize the new case type count variables
Store 0 To ;
   m.bankrupt, ;
   m.collection, ;
   m.utilities, ;
   m.otherconfi, ;
   m.suspension, ;
   m.specialed, ;
   m.specserv, ;
   m.othered, ;
   m.discrimjob, ;
   m.wrongful, ;
   m.empbenefit

Store 0 To ;
   m.otheremp, ;
   m.adoption, ;
   m.custody, ;
   m.childabuse, ;
   m.divorce, ;
   m.domestic, ;
   m.fostercare, ;
   m.guardian, ;
   m.standby, ;
   m.parighterm, ;
   m.support, ;
   m.otherfam

Store 0 To ;
   m.medicaid, ;
   m.medicare, ;
   m.otherhelth, ;
   m.subhous, ;
   m.landlord, ;
   m.othpubhous, ;
   m.otherhous, ;
   m.afdc, ;
   m.foodstamps, ;
   m.ssi, ;
   m.unemploy, ;
   m.otherincom

Store 0 To ;
   m.immigrate, ;
   m.incarcerat, ;
   m.confident, ;
   m.discrimination ,;
   m.otherindiv, ;
   m.chiprotect, ;
   m.emancipate, ;
   m.otherjuven, ;
   m.will, ;
   m.proxy, ;
   m.advdirect, ;
   m.powerOfAttorney, ;
   m.othermisc

* now, load the case type counts into the variables
Select CsProfile
* jss, 9/22/04, use new case_types below
Scan
   Do Case
      Case category = '001'
         Do Case
            Case case_type = '01'
               m.bankrupt = casetypecnt
            Case case_type = '02'
               m.collection = casetypecnt
            Case case_type = '03'
               m.utilities = casetypecnt
            Case case_type = '04'
               m.otherconfi = casetypecnt
         Endcase
      Case category = '002'
         Do Case
            Case case_type = '05'
               m.suspension = casetypecnt
            Case case_type = '06'
               m.specialed = casetypecnt
            Case case_type = '07'
               m.specserv = casetypecnt
            Case case_type = '08'
               m.othered = casetypecnt
         Endcase
      Case category = '003'
         Do Case
            Case case_type = '09'
               m.discrimjob = casetypecnt
            Case case_type = '10'
               m.wrongful = casetypecnt
            Case case_type = '11'
               m.empbenefit = casetypecnt
            Case case_type = '12'
               m.otheremp = casetypecnt
         Endcase
      Case category = '004'
         Do Case
            Case case_type = '13'
               m.adoption = casetypecnt
            Case case_type = '14'
               m.custody = casetypecnt
            Case case_type = '15'
               m.childabuse = casetypecnt
            Case case_type = '16'
               m.divorce = casetypecnt
            Case case_type = '17'
               m.domestic = casetypecnt
            Case case_type = '18'
               m.fostercare = casetypecnt
            Case case_type = '19'
               m.guardian = casetypecnt
            Case case_type = '20'
               m.standby = casetypecnt
            Case case_type = '21'
               m.parighterm = casetypecnt
            Case case_type = '22'
               m.support = casetypecnt
            Case case_type = '23'
               m.otherfam = casetypecnt
         Endcase
      Case category = '005'
         Do Case
            Case case_type = '24'
               m.medicaid = casetypecnt
            Case case_type = '25'
               m.medicare = casetypecnt
            Case case_type = '26'
               m.otherhelth = casetypecnt
         Endcase
      Case category = '006'
         Do Case
            Case case_type = '27'
               m.subhous = casetypecnt
            Case case_type = '28'
               m.landlord = casetypecnt
            Case case_type = '29'
               m.othpubhous = casetypecnt
            Case case_type = '30'
               m.otherhous = casetypecnt
         Endcase
      Case category = '007'
         Do Case
            Case case_type = '31'
               m.afdc = casetypecnt
            Case case_type = '32'
               m.foodstamps = casetypecnt
            Case case_type = '33'
               m.ssi = casetypecnt
            Case case_type = '34'
               m.unemploy = casetypecnt
            Case case_type = '35'
               m.otherincom = casetypecnt
         Endcase
      Case category = '008'
         Do Case
            Case case_type = '36'
               m.immigrate = casetypecnt
            Case case_type = '37'
               m.incarcerat = casetypecnt
            Case case_type = '38'
               m.confident = casetypecnt
            Case case_type = '39'
               m.otherindiv = casetypecnt
            Case case_type =('48')
               m.discrimination=casetypecnt
         Endcase
      Case category = '009'
         Do Case
            Case case_type = '40'
               m.chiprotect = casetypecnt
            Case case_type = '41'
               m.emancipate = casetypecnt
            Case case_type = '42'
               m.otherjuven = casetypecnt
         Endcase
      Case category = '010'
         Do Case
            Case case_type = '43'
               m.will = casetypecnt
            Case case_type = '44'
               m.proxy = casetypecnt
            Case case_type = '45'
               m.advdirect = casetypecnt
            Case case_type = '46'
               m.othermisc = casetypecnt
            Case case_type =('47')
               m.powerOfAttorney = casetypecnt
         Endcase
   Endcase
Endscan

* now, initialize the case closure reason counts
Store 0 To   m.counseladv, ;
   m.briefserv, ;
   m.referafter, ;
   m.clientwd, ;
   m.negotnolit, ;
   m.negotlit, ;
   m.aadecision, ;
   m.aawon, ;
   m.aalost, ;
   m.courtdecis, ;
   m.courtwon, ;
   m.courtlost, ;
   m.nonlitmatt, ;
   m.otherclose

* now, total closures by case closure reason
* next, we will total by case type (enc_type)
If Used('CsCloReas')
   Use In CsCloReas
Endif

Select ;
        reason, ;
        Count(*) As reasoncnt ;
   From ;
      ai_enc ;
   Where ;
      act_id In (Select  act_id ;
                    From CsCloDur) ;
   Into Cursor ;
      CsCloReas ;
   Group By ;
          1

Select CsCloReas

Scan
   Do Case
      Case reason = '01'
         m.counseladv = reasoncnt
      Case reason = '02'
         m.briefserv = reasoncnt
      Case reason = '03'
         m.referafter = reasoncnt
      Case reason = '04'
         m.clientwd = reasoncnt
      Case reason = '05'
         m.negotnolit = reasoncnt
      Case reason = '06'
         m.negotlit = reasoncnt
      Case reason = '07'
         m.aalost = reasoncnt
      Case reason = '08'
         m.aawon = reasoncnt
      Case reason = '09'
         m.courtlost = reasoncnt
      Case reason = '10'
         m.courtwon = reasoncnt
      Case reason = '11'
         m.nonlitmatt = reasoncnt
      Otherwise
         m.otherclose = reasoncnt
   Endcase
Endscan

* now, the derived fields
m.aadecision = m.aawon + m.aalost
m.courtdecis = m.courtwon + m.courtlost

* must only have one record report cursor
If Used('leg_case')
   Use In leg_case
Endif

Select  Distinct system_id, ;
        m.refsrce1 As refsrce1, ;
        m.refsrce2 As refsrce2, ;
        m.refsrce3 As refsrce3, ;
        m.refsrce4 As refsrce4, ;
        m.refsrce1ct As refsrce1ct, ;
        m.refsrce2ct As refsrce2ct, ;
        m.refsrce3ct As refsrce3ct, ;
        m.refsrce4ct As refsrce4ct, ;
        m.caseactbeg As caseactbeg, ;
        m.casenewop As casenewop, ;
        m.caseactdur As caseactdur, ;
        m.caseclodur As caseclodur, ;
        m.caseactend As caseactend, ;
        m.bankrupt As bankrupt, ;
        m.collection As Collection, ;
        m.utilities As utilities, ;
        m.otherconfi As otherconfi, ;
        m.suspension As suspension, ;
        m.specialed As specialed, ;
        m.specserv As specserv, ;
        m.othered As othered, ;
        m.discrimjob As discrimjob, ;
        m.wrongful As wrongful, ;
        m.empbenefit As empbenefit, ;
        m.otheremp As otheremp, ;
        m.adoption As adoption, ;
        m.custody As custody, ;
        m.childabuse As childabuse, ;
        m.divorce As divorce, ;
        m.domestic As domestic, ;
        m.fostercare As fostercare, ;
        m.guardian As guardian, ;
        m.standby As standby, ;
        m.parighterm As parighterm, ;
        m.support As Support, ;
        m.otherfam As otherfam, ;
        m.medicaid As medicaid, ;
        m.medicare As medicare, ;
        m.otherhelth As otherhelth, ;
        m.subhous As subhous, ;
        m.landlord As landlord, ;
        m.othpubhous As othpubhous, ;
        m.otherhous As otherhous, ;
        m.afdc As afdc, ;
        m.foodstamps As foodstamps, ;
        m.unemploy As unemploy, ;
        m.otherincom As otherincom, ;
        m.immigrate As immigrate, ;
        m.incarcerat As incarcerat, ;
        m.confident As confident, ;
        m.ssi As ssi, ;
        m.otherindiv As otherindiv, ;
        m.chiprotect As chiprotect, ;
        m.emancipate As emancipate, ;
        m.otherjuven As otherjuven, ;
        m.will As will, ;
        m.proxy As proxy, ;
        m.advdirect As advdirect, ;
        m.othermisc As othermisc, ;
        m.counseladv As counseladv, ;
        m.briefserv As briefserv, ;
        m.referafter As referafter, ;
        m.clientwd As clientwd, ;
        m.negotnolit As negotnolit, ;
        m.negotlit As negotlit, ;
        m.aadecision As aadecision, ;
        m.aawon As aawon, ;
        m.aalost As aalost, ;
        m.courtdecis As courtdecis, ;
        m.courtwon As courtwon, ;
        m.courtlost As courtlost, ;
        m.nonlitmatt As nonlitmatt, ;
        m.otherclose As otherclose, ;
        m.discrimination As discrimination, ;
        m.powerOfAttorney As powerOfAttorney, ;
        ParamN As  Crit, ;
        cDate As cDate, ;
        cTime As cTime, ;
        Date_from As Date_from, ;
        Date_to As Date_to ;
   From System ;
   Where system_id = gcSys_Prefix ;
   Into Cursor leg_case

oApp.msg2user('OFF')
gcRptName = 'rpt_leg_case'
Go Top
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   Do Case
      Case lPrev = .F.
         Report Form rpt_leg_case To Printer Prompt Noconsole Nodialog
      Case lPrev = .T.     &&Preview
         oApp.rpt_print(5, .T., 1, 'rpt_leg_case', 1, 2)
   Endcase
Endif

**************************************************************************
Function clean_data

If Used('AI_ENC')
   Use In ai_enc
Endif
If Used('ACTBEG')
   Use In ActBeg
Endif
If Used('ENRINPER')
   Use In EnrInPer
Endif
If Used('NEWENR')
   Use In NewEnr
Endif
If Used('NEWENR1')
   Use In NewEnr1
Endif
If Used('NEWENRCNT')
   Use In NewEnrCnt
Endif
If Used('NEWENRCNT2')
   Use In NewEnrCnt2
Endif
If Used('NEWENRCNT3')
   Use In NewEnrCnt3
Endif
If Used('REF_IN')
   Use In ref_in
Endif
If Used('CSACTBEG')
   Use In CsActBeg
Endif
If Used('CSACTDUR')
   Use In CsActDur
Endif
If Used('CSACTEND')
   Use In CsActEnd
Endif
If Used('CSCLODUR')
   Use In CsCloDur
Endif
If Used('CSACTEND')
   Use In CsActEnd
Endif
If Used('CSPROFILE')
   Use In CsProfile
Endif
If Used('CSCLOREAS')
   Use In CsCloReas
Endif
If Used('DUMMY')
   Use In DUMMY
Endif
Return

