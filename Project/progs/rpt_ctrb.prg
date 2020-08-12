*Pr_ctrB.prg
* print Part B of form (tests/results)
*************************************************************************
** This program prints the CTR Part B form
** It requires the tc_id of the client selected in the intake screen
*************************************************************************
Parameter cTC_ID,tcCTR_ID, cTest_id
cTime = Time()
cDate = Date()

Select lv_ctr_test_filtered
Locate For lv_ctr_test_filtered.ctrtest_id = cTest_id

If !Found()
   oApp.msg2user('NOTFOUNDG')   
   Return
Endif

***Client Information
Select cli_cur
Locate For tc_id = cTC_ID
cClientId = cli_cur.id_no 
dDob = cli_cur.dob
***Gender
Select gender
Locate For gender.code = cli_cur.gender 
If Found()
   cGender = Left(gender.descript, 45)
Else
   cGender = Space(45)
Endif
***Ethnicity
If (cli_cur.white + cli_cur.blafrican + cli_cur.asian + cli_cur.hawaisland + cli_cur.indialaska +cli_cur.someother) > 1
               cEthnic = "More than One Race    "
Else
         Do Case
            Case cli_cur.white = 1
               cEthnic = "White, Not Hispanic   "
            Case cli_cur.blafrican = 1
               cEthnic = "Black, Not Hispanic   "
            Case cli_cur.asian = 1
               cEthnic = "Asian                 "
            Case cli_cur.hawaisland = 1
               cEthnic = "Hawaiian/Pacific Isl. "   
            Case cli_cur.indialaska = 1
               cEthnic = "Native American/Alaska"      
            Case cli_cur.someother = 1
               cEthnic = "Some Other Race       "      
            Otherwise
               cEthnic = "Unknown Race          "
         EndCase
Endif 
***Race
Do Case
    Case cli_cur.hispanic = 2 
            cRace = "Hispanic         "
     Case cli_cur.hispanic = 1
            cRace = "Non-Hispanic     "   
     Otherwise
            cRace = "Unknown Ethnicity"
Endcase
***ZIP
Select address
Locate For address.client_id = cli_cur.client_id
If Found()
   cZip = address.zip
Else
   cZip = ''
Endif

*** Client Origin (How Client Entered C&T) 
Select lv_ai_ctr_filtered
Locate For lv_ai_ctr_filtered.ctr_id = tcCTR_ID

Do Case 
   Case lv_ai_ctr_filtered.cli_source = 1
      cSource = 'Agency Referral'
   Case lv_ai_ctr_filtered.cli_source = 2   
      cSource = 'HC/PI          '
   Case lv_ai_ctr_filtered.cli_source = 3   
      cSource = 'Self           '
   Case lv_ai_ctr_filtered.cli_source = 4   
      cSource = 'Partner        ' 
   Case lv_ai_ctr_filtered.cli_source = 5   
      cSource = 'Friend/Family  '
   Case lv_ai_ctr_filtered.cli_source = 6   
      cSource = "Don't Know     "       
   Case lv_ai_ctr_filtered.cli_source = 7   
      cSource = 'Other          '
   Otherwise
      cSource = Space(15)
Endcase
**Type of Service
Do Case 
   Case lv_ai_ctr_filtered.agency_ref = 1
      cType = 'Counseling and Testing'
   Case lv_ai_ctr_filtered.agency_ref = 2   
      cType = 'Health Communication/Public Information'
   Case lv_ai_ctr_filtered.agency_ref = 3   
      cType = 'Comprehensive Risk Counseling and Services'
   Case lv_ai_ctr_filtered.agency_ref = 4   
      cType = 'Health Education/Risk Reduction' 
   Case lv_ai_ctr_filtered.agency_ref = 5   
      cType = 'Partner Counseling/Referral Services'
   Case lv_ai_ctr_filtered.agency_ref = 6   
      cType = "Intake/Screening"       
   Case lv_ai_ctr_filtered.agency_ref = 7   
      cType = 'Outreach'
   Case lv_ai_ctr_filtered.agency_ref = 8   
      cType = 'Other'   
   Case lv_ai_ctr_filtered.agency_ref = 9   
      cType = "Don't know"   
   Otherwise
      cType = 'N/A'
Endcase

*!*   If lv_ai_ctr_filtered.cli_source = 7 
*!*       cOther_spec = lv_ai_ctr_filtered.other_spec
*!*   Else
*!*      cOther_spec = ''
*!*   Endif

***  Link to Corresponding Encounter 
***Program
Select lv_prog2use_serv_cat
Locate For lv_prog2use_serv_cat.program = lv_ctr_test_filtered.program_id
If Found()
   cProg = Alltrim(lv_ctr_test_filtered.program_id) + '  ' + lv_prog2use_serv_cat.program_description
Else
   cProg = 'N/A'
Endif

***Contract
Select lv_contracts_combined2   
*Locate For lv_contracts_combined2.conno = lv_ctr_test_filtered.contract_id

* PB: 01/2008 
Locate For lv_contracts_combined2.contract_id = Transform(lv_ctr_test_filtered.contract_id, '@L 9999999999')

If Found() 
   cContract = Rtrim(lv_contracts_combined2.conno) + '  '  + ;
               DTOC(lv_contracts_combined2.start_date) + ' - ' + ;
               DTOC(lv_contracts_combined2.end_date)
Else
   cContract = 'N/A'
Endif

***Model
Select lv_model2  
Locate For lv_model2.model_id = lv_ctr_test_filtered.model_id
If Found()
   cModel = Alltrim(Str(lv_ctr_test_filtered.model_id)) + '  ' + lv_model2.modelname
Else
   cModel = 'N/A'
Endif

**Intervention
Select lv_intervention2   
Locate For lv_intervention2.intervention_id =  lv_ctr_test_filtered.intervention_id 
If Found()
   cInterv = Alltrim(Str(lv_ctr_test_filtered.intervention_id)) + '  ' + lv_intervention2.name
Else
   cInterv = 'N/A'
Endif

**Encounter
Select lv_enc_type_filtered    
Locate For lv_enc_type_filtered.enc_id =  lv_ctr_test_filtered.enc_id And ;
            pre_test = .f.
If Found()
   cEnc = Alltrim(Str(lv_ctr_test_filtered.enc_id)) + '  ' + lv_enc_type_filtered.descript
Else
   cEnc = 'N/A'
Endif

***Open Form
cForm = Space(100)
Select lv_ai_enc_ctr_filtered 
Locate For lv_ai_enc_ctr_filtered.act_id = lv_ctr_test_filtered.act_id
If Found()
   cFName = Iif(Nvl(lv_ai_enc_ctr_filtered.enc_name, 'm') = 'm', ;
            Space(100),' - ' + lv_ai_enc_ctr_filtered.enc_name)
   cForm = DTOC(lv_ai_enc_ctr_filtered.act_dt) + cFName  
Else
   cForm = 'N/A'
Endif

** cOther_spec as cOther, ;   

If Used('ctrb')
   Use In ctrb
Endif
   
Select    IIF(Empty(ai_ctr.OverRid_id), "Form ID #: " + ai_ctr.Form_Id + " ", ;
          "OverRide Form ID #: " + ai_ctr.OverRid_Id + " ") as form_id, ;
          ai_ctr.ctr_id, ;
          lv_ctr_test_filtered.ctrtest_id, ;
          cClientId as id_no, ; 
          dDob as dob, ;
          cGender as gender, ;
          cEthnic as ethnic, ;
          cRace as race, ;
          cZip as zip, ;
          ai_ctr.session_dt, ;
          Rtrim(ai_ctr.psite_id) + Space(1) + Rtrim(site.descript1) as pSiteDesc,; 
          Rtrim(ai_ctr.pworker_id)+Space(1)+ Upper(oApp.FormatName(staffcur.last, staffcur.first, staffcur.mi)) as pworkerdesc, ;
          Iif(!Empty(ai_ctr.aloccde), ai_ctr.aloccde, 'N/A')  as aloccde, ;
          ai_ctr.projwave, ;
          cSource as clisourdsc, ;
          cType as agenrefdsc, ;
          lv_ctr_test_filtered.sample_dt, ;
          lv_ctr_test_filtered.seq_id, ;
          lv_ctr_test_filtered.test_id, ;
          lv_ctr_test_filtered.samplenum, ;
          Rtrim(lv_ctr_test_filtered.site_id) + Space(1) + Rtrim(site_t.descript1) as SiteDesc,; 
          Rtrim(work_t.pworker_id)+Space(1)+ Upper(oApp.FormatName(work_t.last, work_t.first, work_t.mi)) as workerdesc, ;
          lv_ctr_test_filtered.election_desc, ;
          lv_ctr_test_filtered.technology_desc, ;
          lv_ctr_test_filtered.conftest_desc, ;
          lv_ctr_test_filtered.spec_type_desc, ;
          lv_ctr_test_filtered.result_desc, ;
          Iif(lv_ctr_test_filtered.sampprov=1, 'Yes          ', ;
          Iif(lv_ctr_test_filtered.sampprov=2, 'No - Refused ', ;
          Iif(lv_ctr_test_filtered.sampprov=3, 'No - Referred', 'N/A         ' ))) as samp_prov, ;
          Iif(lv_ctr_test_filtered.resltprov=1, 'Yes', ;
          Iif(lv_ctr_test_filtered.resltprov=2, 'No ', 'N/A')) as resltprov, ;
          lv_ctr_test_filtered.result_dt, ;
          ctrreas.descript as reason_no, ;
          Iif(lv_ctr_test_filtered.anonconf=1, 'Yes', 'No ')  as anonconf, ;
          cProg as cProg, ;
          Iif(Empty(lv_ctr_test_filtered.aloccde), 'N/A', lv_ctr_test_filtered.aloccde) as aloccdet , ;
          cContract as cContract, ;
          cModel as cModel, ;
          cInterv as cInterv, ;
          cEnc as cEnc, ;
          cForm as cForm, ;
          Nvl(lv_ctr_serv_filtered.service_id, 0) as service_id, ;
          Iif(Nvl(lv_ctr_serv_filtered.service_id, 0) <> 0, Str(lv_ctr_serv_filtered.service_id) + '  ' + lv_ctr_serv_filtered.service, 'Not Entered' + Space(80)) as service_desc, ;
          Space(100) as  ref_desc, ; 
          Space(10) as ref_id, ;
          cTime as cTime,   ;                                    
          cDate as cDate ;
from ai_ctr ;
      inner join lv_ctr_test_filtered on ;
                 lv_ctr_test_filtered.ctr_id = ai_ctr.ctr_id ;
             And lv_ctr_test_filtered.ctrtest_id = cTest_id ;
             And ai_ctr.ctr_id = tcCTR_ID ;
      Inner Join site on;
                 site.psite_id = ai_ctr.psite_id ;    
      inner join staffcur on ;
                staffcur.pworker_id = ai_ctr.pworker_id ;  
      Inner Join site site_t on;
                site_t.psite_id = lv_ctr_test_filtered.site_id ;   
      inner join staffcur work_t on ;
                work_t.pworker_id = lv_ctr_test_filtered.worker_id  ;  
      Left Outer Join ctrreas On ;
                lv_ctr_test_filtered.reason_no = ctrreas.code ;   
      left outer join lv_ctr_serv_filtered on ;
                 lv_ctr_serv_filtered.ctr_id = lv_ctr_test_filtered.ctr_id  ;
             And lv_ctr_serv_filtered.ctrtest_id =  lv_ctr_test_filtered.ctrtest_id  ;
             And lv_ctr_serv_filtered.tc_id = cTC_ID ;                                                      
 Into cursor ctrb Readwrite      

n = 0
Select lv_ai_ref_filtered
   Locate For   lv_ai_ref_filtered.ctrtest_id =  lv_ctr_test_filtered.ctrtest_id  ;
             And lv_ai_ref_filtered.tc_id = cTC_ID 
If Found()
   Scan For  lv_ai_ref_filtered.ctrtest_id =  cTest_id   ;
             And lv_ai_ref_filtered.tc_id = cTC_ID 
         n= n +1
         If n =1
               m.ref_desc = 'Referrals: ' + trim(lv_ai_ref_filtered.ref_cat_descript) + ' - ' + trim(lv_ai_ref_filtered.ref_for_descript) + ;
                             nvl(' to ' + lv_ai_ref_filtered.ref_to_name, '')

         else    
               m.ref_desc = Space(17) + trim(lv_ai_ref_filtered.ref_cat_descript) + ' - ' + trim(lv_ai_ref_filtered.ref_for_descript) + ;
                             nvl(' to ' + lv_ai_ref_filtered.ref_to_name, '')
         Endif
                                      
         m.ref_id = lv_ai_ref_filtered.ref_id
         m.ctr_id = tcCTR_ID
         m.ctrtest_id = cTest_id 
         Insert Into ctrb From memvar 
    Endscan     
Else
   m.ref_id = '0'
   m.ref_desc = 'Referrals:  Not Entered'
   m.ctr_id = tcCTR_ID
   m.ctrtest_id = cTest_id 
   Insert Into ctrb from memvar
Endif             

Select ctrb
Go top
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   Report Form rpt_ctrb To Printer Prompt Noconsole NODIALOG 
Endif
Return

