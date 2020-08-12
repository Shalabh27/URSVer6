Parameters ;   
   lPrev, ;      && Preview
   aSelvar1, ;   && select parameters from selection list
   nOrder, ;     && order by
   nGroup, ;     && report selection
   lcTitle, ;    && report selection
   Date_from, ;  && from date
   Date_to, ;    && to date
   ParamC, ;     && name of param
   lnStat, ;     && selection(Output)  page 2
   cOrderBy      && order by description

Acopy(aSelvar1, aSelvar2)

lcProgx = ""
&& Search For Parameters
For i = 1 To Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   Endif
Endfor

cDate=Date()
cTime=Time()
* jss, 4/28/04, legal services module: case outcome report
Private gchelp
gchelp = "Legal Services Case Outcome Report Screen"
cTitle = 'Legal Services Case Outcome Report'

= clean_data()
* first, get cases closed during period
If Used('CsCloDur')
   Use In CsCloDur
Endif

Select act_id ;
From ;
    ai_enc ;
Where ;
    serv_cat = '00021' And ;
     Program = lcProgx  And ;
     (caseclosdt >= Date_from And caseclosdt <= Date_to) ;
Into Cursor CsCloDur

* next, total by case outcome 
If Used('CsOutCome')
   Use In CsOutCome
Endif

Select ai_enc.category, ;
     lv_enc_type.Code As case_type, ;
     outcome, ;
     Count(*) As outcomecnt ;
From ai_enc ;
Join lv_enc_type On ;
   ai_enc.enc_id = lv_enc_type.enc_id And ;
   ai_enc.category = lv_enc_type.category ;
Where act_id In (Select act_id From CsCloDur) ;
Into Cursor CsOutCome ;
Group By 1, 2, 3

* now, initialize the new case type count variables
Store 0 To ;
   m.bankrupt, ;
   m.collection, ;
   m.utilities, ;
   m.warranties, ;
   m.creditdisc, ;
   m.illdefjudg, ;
   m.smallclaim, ;
   m.discrim, ;
   m.oabr_confi, ;
   m.clfu_confi, ;
   m.cc_confi, ;
   m.suspension, ;
   m.specialed, ;
   m.oabr_ed, ;
   m.clfu_ed, ;
   m.cc_ed, ;
   m.discrimjob, ;
   m.wrongful, ;
   m.wages, ;
   m.empbenefit, ;
   m.oabr_emp, ;
   m.clfu_emp, ;
   m.cc_emp

Store 0 To ;
   m.adoption, ;
   m.custody, ;
   m.visit, ;
   m.domestic, ;
   m.divorce, ;
   m.fostercare, ;
   m.guardian, ;
   m.standby, ;
   m.guarddesig, ;
   m.guardjudic, ;
   m.parighterm, ;
   m.support, ;
   m.oabr_fam, ;
   m.clfu_fam, ;
   m.cc_fam, ;
   m.accessprov, ;
   m.benefits, ;
   m.premature, ;
   m.disability, ;
   m.harmful, ;
   m.oabr_helth, ;
   m.clfu_helth, ;
   m.cc_helth

Store 0 To ;
   m.eviction, ;
   m.accesshous, ;
   m.landlord, ;
   m.tenant, ;
   m.dwelling, ;
   m.oabr_hous, ;
   m.clfu_hous, ;
   m.cc_hous, ;
   m.incbenefit, ;
   m.oabr_incom, ;
   m.clfu_incom, ;
   m.cc_incom, ;
   m.deport, ;
   m.legalstat, ;
   m.indrights, ;
   m.incarright, ;
   m.oabr_ind, ;
   m.clfu_ind, ;
   m.cc_ind, ;
   m.chiprotect, ;
   m.emancipate, ;
   m.oabr_juv, ;
   m.clfu_juv, ;
   m.cc_juv, ;
   m.will, ;
   m.oabr_misc, ;
   m.clfu_misc, ;
   m.cc_misc

Store 0 To ;
   m.debtRelief, ;
   m.taxReleif, ;
   m.abuseRelief, ;
   m.returnedFC, ;
   m.deedTransfer, ;
   m.agreementLanlord, ;
   m.improvedHousing, ;
   m.moreTime, ;
   m.housingSubsity, ;
   m.obtainedCitizenship, ;
   m.obtainedWorkAuth, ;
   m.obtainedPOA, ;
   m.revokedPOA

* now, load the case outcome counts into the variables
Select CsOutCome
* jss, 9/22/04, comment out old case_type case statements (enc_type table has changed) and replace with new, unique values
Scan
   Do Case
      Case category = '001' && consumer/finance
         Do Case
            Case case_type = '01' && bankruptcy
                Do Case
                  Case outcome = '01'
                     m.bankrupt = m.bankrupt + outcomecnt
                  Case outcome = '02'
                     m.oabr_confi = m.oabr_confi + outcomecnt
                  Case outcome = '03'
                     m.clfu_confi = m.clfu_confi + outcomecnt
                  Case outcome = '04'
                     m.cc_confi = m.cc_confi + outcomecnt
               EndCase 

            Case case_type = '02' && collections
               Do Case
                  Case outcome = '01'
                     m.collection = m.collection+ outcomecnt
                  Case outcome = '02'
                     m.oabr_confi = m.oabr_confi + outcomecnt
                  Case outcome = '03'
                     m.clfu_confi = m.clfu_confi + outcomecnt
                  Case outcome = '04'
                     m.cc_confi = m.cc_confi + outcomecnt
                  Case outcome = '05'  && Obtained Relief from Debt
                     m.debtRelief = m.debtRelief + outcomecnt
                  Case outcome = '06'  && Obtained Relief from Tax Collection
                     m.taxReleif = m.taxReleif + outcomecnt
               EndCase 

            Case case_type = '03' && public utilities
               Do Case
                  Case outcome = '01'
                     m.utilities = m.utilities + outcomecnt
                  Case outcome = '02'
                     m.oabr_confi = m.oabr_confi + outcomecnt
                  Case outcome = '03'
                     m.clfu_confi = m.clfu_confi + outcomecnt
                  Case outcome = '04'
                     m.cc_confi = m.cc_confi + outcomecnt
               EndCase 

            Case case_type = '04' && other consumer/finance
               Do Case
                  Case outcome = '01'
                     m.warranties = outcomecnt
                  Case outcome = '02'
                     m.creditdisc = outcomecnt
                  Case outcome = '03'
                     m.illdefjudg = outcomecnt
                  Case outcome = '04'
                     m.smallclaim = outcomecnt
                  Case outcome = '05'
                     m.oabr_confi = m.oabr_confi + outcomecnt
                  Case outcome = '06'
                     m.clfu_confi = m.clfu_confi + outcomecnt
                  Case outcome = '07'
                     m.cc_confi = m.cc_confi + outcomecnt
               EndCase
         EndCase 

      Case category = '002' && education
         Do Case
            Case case_type = '05' && suspension/expulsion

               Do Case
                  Case outcome = '01'
                     m.suspension = outcomecnt
                  Case outcome = '02'
                     m.oabr_ed = m.oabr_ed + outcomecnt
                  Case outcome = '03'
                     m.clfu_ed = m.clfu_ed + outcomecnt
                  Case outcome = '04'
                     m.cc_ed = m.cc_ed + outcomecnt
               Endcase

            Case case_type = '06' && special education
               Do Case
                  Case outcome = '01'
                     m.specialed = m.specialed + outcomecnt
                  Case outcome = '02'
                     m.oabr_ed = m.oabr_ed + outcomecnt
                  Case outcome = '03'
                     m.clfu_ed = m.clfu_ed + outcomecnt
                  Case outcome = '04'
                     m.cc_ed = m.cc_ed + outcomecnt
               Endcase

            Case case_type = '07' && special services
               Do Case
                  Case outcome = '01'
                     m.specialed = m.specialed + outcomecnt
                  Case outcome = '02'
                     m.oabr_ed = m.oabr_ed + outcomecnt
                  Case outcome = '03'
                     m.clfu_ed = m.clfu_ed + outcomecnt
                  Case outcome = '04'
                     m.cc_ed = m.cc_ed + outcomecnt
               Endcase

            Case case_type = '08' && other education
               Do Case
                  Case outcome = '01'
                     m.oabr_ed = m.oabr_ed + outcomecnt
                  Case outcome = '02'
                     m.clfu_ed = m.clfu_ed + outcomecnt
                  Case outcome = '03'
                     m.cc_ed = m.cc_ed + outcomecnt
               Endcase
         Endcase

      Case category = '003' && employment
         Do Case
            Case case_type = '09' && job discrimination
               Do Case
                  Case outcome = '01'
                     m.discrimjob = outcomecnt
                  Case outcome = '02'
                     m.oabr_emp = m.oabr_emp + outcomecnt
                  Case outcome = '03'
                     m.clfu_emp = m.clfu_emp + outcomecnt
                  Case outcome = '04'
                     m.cc_emp = m.cc_emp + outcomecnt
               Endcase

            Case case_type = '10' && wrongful discharge
               Do Case
                  Case outcome = '01'
                     m.wrongful = outcomecnt
                  Case outcome = '02'
                     m.wages = outcomecnt
                  Case outcome = '03'
                     m.oabr_emp = m.oabr_emp + outcomecnt
                  Case outcome = '04'
                     m.clfu_emp = m.clfu_emp + outcomecnt
                  Case outcome = '05'
                     m.cc_emp = m.cc_emp + outcomecnt
               Endcase

            Case case_type = '11' && employee benefits
               Do Case
                  Case outcome = '01'
                     m.empbenefit = outcomecnt
                  Case outcome = '02'
                     m.oabr_emp = m.oabr_emp + outcomecnt
                  Case outcome = '03'
                     m.clfu_emp = m.clfu_emp + outcomecnt
                  Case outcome = '04'
                     m.cc_emp = m.cc_emp + outcomecnt
               Endcase

            Case case_type = '12' && other employment
               Do Case
                  Case outcome = '01'
                     m.oabr_emp = m.oabr_emp + outcomecnt
                  Case outcome = '02'
                     m.clfu_emp = m.clfu_emp + outcomecnt
                  Case outcome = '03'
                     m.cc_emp = m.cc_emp + outcomecnt
               Endcase
         Endcase

      Case category = '004' && family
         Do Case
            Case case_type = '13' && adoption
               Do Case
                  Case outcome = '01'
                     m.adoption = outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '14' && custody/visitation
               Do Case
                  Case outcome = '01'
                     m.custody = outcomecnt
                  Case outcome = '02'
                     m.visit = outcomecnt
                  Case outcome = '03'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '04'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '05'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '15' && child abuse/neglect
               Do Case
                  Case outcome = '01'
                     m.domestic = m.domestic + outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
                  Case outcome = '05'  && Obtained Reliefe from abuse/neglect
                     m.abuseRelief = m.abuseRelief + outcomecnt
               Endcase

            Case case_type = '16' && divorce/separation
               Do Case
                  Case outcome = '01'
                     m.divorce = outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '17' && domestic violence
               Do Case
                  Case outcome = '01'
                     m.domestic = m.domestic + outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '18' && fostercare
               Do Case
                  Case outcome = '01'
                     m.fostercare = outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
                  Case outcome = '05'  && Return from Foster Care
                     m.returnedFC = m.returnedFC + outcomecnt

               Endcase

            Case case_type = '19' && guardianship/conservatorship
               Do Case
                  Case outcome = '01'
                     m.guardian = outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '20' && standby guardianship
               Do Case
                  Case outcome = '01'
                     m.guarddesig = outcomecnt
                  Case outcome = '02'
                     m.guardjudic = outcomecnt
                  Case outcome = '03'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '04'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '05'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '21' && parental rights termination
               Do Case
                  Case outcome = '01'
                     m.parighterm = outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '22' && support
               Do Case
                  Case outcome = '01'
                     m.support = outcomecnt
                  Case outcome = '02'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '03'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '04'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase

            Case case_type = '23' && other family
               Do Case
                  Case outcome = '01'
                     m.oabr_fam = m.oabr_fam + outcomecnt
                  Case outcome = '02'
                     m.clfu_fam = m.clfu_fam + outcomecnt
                  Case outcome = '03'
                     m.cc_fam = m.cc_fam + outcomecnt
               Endcase
         Endcase

      Case category = '005' && health care
         Do Case
            Case case_type = '24' && medicaid
               Do Case
                  Case outcome = '01'
                     m.accessprov = m.accessprov + outcomecnt
                  Case outcome = '02'
                     m.benefits = m.benefits + outcomecnt
                  Case outcome = '03'
                     m.premature = m.premature + outcomecnt
                  Case outcome = '04'
                     m.disability = m.disability + outcomecnt
                  Case outcome = '05'
                     m.harmful = m.harmful + outcomecnt
                  Case outcome = '06'
                     m.oabr_helth = m.oabr_helth + outcomecnt
                  Case outcome = '07'
                     m.clfu_helth = m.clfu_helth + outcomecnt
                  Case outcome = '08'
                     m.cc_helth = m.cc_helth + outcomecnt
               Endcase

            Case case_type = '25' && medicare
               Do Case
                  Case outcome = '01'
                     m.accessprov = m.accessprov + outcomecnt
                  Case outcome = '02'
                     m.benefits = m.benefits + outcomecnt
                  Case outcome = '03'
                     m.premature = m.premature + outcomecnt
                  Case outcome = '04'
                     m.disability = m.disability + outcomecnt
                  Case outcome = '05'
                     m.harmful = m.harmful + outcomecnt
                  Case outcome = '06'
                     m.oabr_helth = m.oabr_helth + outcomecnt
                  Case outcome = '07'
                     m.clfu_helth = m.clfu_helth + outcomecnt
                  Case outcome = '08'
                     m.cc_helth = m.cc_helth + outcomecnt
               Endcase

            Case case_type = '26' && other health care
               Do Case
                  Case outcome = '01'
                     m.oabr_helth = m.oabr_helth + outcomecnt
                  Case outcome = '02'
                     m.clfu_helth = m.clfu_helth + outcomecnt
                  Case outcome = '03'
                     m.cc_helth = m.cc_helth + outcomecnt
               Endcase
         Endcase

      Case category = '006' && housing
         Do Case
            Case case_type = '27' && subsidized housing rights
               Do Case
                  Case outcome = '01'
                     m.eviction = m.eviction + outcomecnt
                  Case outcome = '02'
                     m.accesshous = m.accesshous + outcomecnt
                  Case outcome = '03'
                     m.oabr_hous = m.oabr_hous + outcomecnt
                  Case outcome = '04'
                     m.clfu_hous = m.clfu_hous + outcomecnt
                  Case outcome = '05'
                     m.cc_hous = m.cc_hous + outcomecnt
                  Case outcome =('06') && Came to a Revised Rental Agreement with Landlord 
                     m.agreementLanlord = m.agreementLanlord + outcomecnt
                  Case outcome =('07') && Improved Housing Conditions
                     m.improvedHousing = m.improvedHousing + outcomecnt
                  Case outcome =('08') && Obtained More Time to Pay/Move
                     m.moreTime = m.moreTime + outcomecnt
                  Case outcome =('09') && Preserved Housing Subsidy
                      m.housingSubsity =  m.housingSubsity + outcomecnt
                  Case outcome=('10') && Prevented Eviction, Foreclosure or Other Loss of Home
                     m.eviction = m.eviction + outcomecnt      
               Endcase

            Case case_type = '28' && landlord tenant
               Do Case
                  Case outcome = '01'
                     m.landlord = m.landlord+outcomecnt
                  Case outcome = '02'
                     m.tenant = m.tenant+outcomecnt
                  Case outcome = '03'
                     m.oabr_hous = m.oabr_hous + outcomecnt
                  Case outcome = '04'
                     m.clfu_hous = m.clfu_hous + outcomecnt
                  Case outcome = '05'
                     m.cc_hous = m.cc_hous + outcomecnt
                  Case outcome =('06') && Came to a Revised Rental Agreement with Landlord 
                     m.agreementLanlord = m.agreementLanlord + outcomecnt
                  Case outcome =('07') && Improved Housing Conditions
                     m.improvedHousing = m.improvedHousing + outcomecnt
                  Case outcome =('08') && Obtained More Time to Pay/Move
                     m.moreTime = m.moreTime + outcomecnt
                  Case outcome =('09') && Preserved Housing Subsidy
                      m.housingSubsity =  m.housingSubsity + outcomecnt
                  Case outcome=('10') && Prevented Eviction, Foreclosure or Other Loss of Home
                     m.eviction = m.eviction + outcomecnt      
               Endcase

            Case case_type = '29' && other public housing
               Do Case
                  Case outcome = '01'
                     m.oabr_hous = m.oabr_hous + outcomecnt
                  Case outcome = '02'
                     m.clfu_hous = m.clfu_hous + outcomecnt
                  Case outcome = '03'
                     m.cc_hous = m.cc_hous + outcomecnt
                  Case outcome =('06') && Came to a Revised Rental Agreement with Landlord 
                     m.agreementLanlord = m.agreementLanlord + outcomecnt
                  Case outcome =('07') && Improved Housing Conditions
                     m.improvedHousing = m.improvedHousing + outcomecnt
                  Case outcome =('08') && Obtained More Time to Pay/Move
                     m.moreTime = m.moreTime + outcomecnt
                  Case outcome =('09') && Preserved Housing Subsidy
                      m.housingSubsity =  m.housingSubsity + outcomecnt
                  Case outcome=('10') && Prevented Eviction, Foreclosure or Other Loss of Home
                     m.eviction = m.eviction + outcomecnt  
               Endcase
               * m.othpubhous = outcomecnt

            Case case_type='30' && other housing
               Do Case
                  Case outcome='01'
                     m.dwelling = m.dwelling+ outcomecnt && AIRS-2750
                  Case outcome='02'
                     m.oabr_hous = m.oabr_hous + outcomecnt
                  Case outcome='03'
                     m.clfu_hous = m.clfu_hous + outcomecnt
                  Case outcome='04'
                     m.cc_hous= m.cc_hous + outcomecnt
                  Case outcome=('05')  && Deed Transfer
                     m.deedTransfer = m.deedTransfer + outcomecnt
                  Case outcome=('06')  && Came to a Revised Rental Agreement with Landlord 
                     m.agreementLanlord = m.agreementLanlord + outcomecnt
                  Case outcome=('07')  && Improved Housing Conditions
                     m.improvedHousing = m.improvedHousing + outcomecnt
                  Case outcome=('08')  && Obtained More Time to Pay/Move
                     m.moreTime = m.moreTime + outcomecnt
                  Case outcome=('09')  && Preserved Housing Subsidy
                      m.housingSubsity =  m.housingSubsity + outcomecnt
                  Case outcome=('10') && Prevented Eviction, Foreclosure or Other Loss of Home
                     m.eviction = m.eviction + outcomecnt      
               Endcase
         Endcase
  
      Case category = '007' && income maintenance
         Do Case
            Case outcome = '01'
               m.incbenefit = m.incbenefit + outcomecnt
            Case outcome = '02'
               m.oabr_incom = m.oabr_incom + outcomecnt
            Case outcome = '03'
               m.clfu_incom = m.clfu_incom + outcomecnt
            Case outcome = '04'
               m.cc_incom = m.cc_incom + outcomecnt
         Endcase

      Case category = '008' && individual rights
         Do Case
            Case case_type = '36' && immigration
               Do Case
                  Case outcome = '01'
                     m.deport = m.deport + outcomecnt &&  AIRS-2750
                  Case outcome = '02'
                     m.legalstat = m.legalstat+ outcomecnt &&  AIRS-2750
                  Case outcome = '03'
                     m.indrights = m.indrights + outcomecnt
                  Case outcome = '04'
                     m.oabr_ind = m.oabr_ind + outcomecnt
                  Case outcome = '05'
                     m.clfu_ind = m.clfu_ind + outcomecnt
                  Case outcome = '06'
                     m.cc_ind = m.cc_ind + outcomecnt
                  Case outcome =('07')  && Obtained Citizenship
                     m.obtainedCitizenship = m.obtainedCitizenship + outcomecnt
                  Case outcome =('08')  && Obtained Employment Authorization
                     m.obtainedWorkAuth = m.obtainedWorkAuth + outcomecnt
               Endcase

            Case case_type = '37' && incarcerated individual's rights
               Do Case
                  Case outcome = '01'
                     m.incarright = m.incarright + outcomecnt
                  Case outcome = '02'
                     m.oabr_ind = m.oabr_ind + outcomecnt
                  Case outcome = '03'
                     m.clfu_ind = m.clfu_ind + outcomecnt
                  Case outcome = '04'
                     m.cc_ind = m.cc_ind + outcomecnt
               Endcase

            Case case_type = '48' && Discrimination
               Do Case
                  Case outcome = '01'
                     m.oabr_ind = m.oabr_ind + outcomecnt
                  Case outcome = '02'
                     m.indrights = m.indrights + outcomecnt
                  Case outcome = '03'
                     m.clfu_ind = m.clfu_ind + outcomecnt
                  Case outcome = '04'
                     m.cc_ind = m.cc_ind + outcomecnt
               Endcase

            Otherwise && confidentiality, other
               Do Case
                  Case outcome = '01'
                     m.indrights = m.indrights + outcomecnt
                  Case outcome = '02'
                     m.oabr_ind = m.oabr_ind + outcomecnt
                  Case outcome = '03'
                     m.clfu_ind = m.clfu_ind + outcomecnt
                  Case outcome = '04'
                     m.cc_ind = m.cc_ind + outcomecnt
               Endcase
         Endcase

      Case category = '009' && juvenile
         Do Case
            Case case_type = '40' && child protective order
               Do Case
                  Case outcome = '01'
                     m.chiprotect = outcomecnt
                  Case outcome = '02'
                     m.oabr_juv = m.oabr_juv + outcomecnt
                  Case outcome = '03'
                     m.clfu_juv = m.clfu_juv + outcomecnt
                  Case outcome = '04'
                     m.cc_juv = m.cc_juv + outcomecnt
               Endcase

            Case case_type = '41' && emancipation
               Do Case
                  Case outcome = '01'
                     m.emancipate = outcomecnt
                  Case outcome = '02'
                     m.oabr_juv = m.oabr_juv + outcomecnt
                  Case outcome = '03'
                     m.clfu_juv = m.clfu_juv + outcomecnt
                  Case outcome = '04'
                     m.cc_juv = m.cc_juv + outcomecnt
               Endcase

            Case case_type = '42' && other juvenile
               Do Case
                  Case outcome = '01'
                     m.oabr_juv = m.oabr_juv + outcomecnt
                  Case outcome = '02'
                     m.clfu_juv = m.clfu_juv + outcomecnt
                  Case outcome = '03'
                     m.cc_juv = m.cc_juv + outcomecnt
               Endcase
         Endcase

      Case category='010'   && Miscellaneous
         Do Case
            Case case_type='46' && other miscellaneous
               Do Case
                  Case outcome=('01')
                     m.oabr_misc=m.oabr_misc + outcomecnt
                  Case outcome=('02')
                     m.clfu_misc=m.clfu_misc + outcomecnt
                  Case outcome=('03')
                     m.cc_misc=m.cc_misc + outcomecnt
               EndCase
               
            Case case_type=('47')  && Power of attorney
               Do Case
                  Case outcome=('02')
                     m.obtainedPOA=m.obtainedPOA + outcomecnt
                  Case outcome=('05')
                     m.revokedPOA=m.revokedPOA + outcomecnt
                  Case outcome=('01')
                     m.oabr_misc=m.oabr_misc + outcomecnt
                  Case outcome =('03')
                     m.clfu_misc=m.clfu_misc + outcomecnt
                  Case outcome=('04')
                     m.cc_misc=m.cc_misc + outcomecnt
               EndCase
            
            Otherwise && will, health care proxy, advanced directive
               Do Case
                  Case outcome=('01')
                     m.will=m.will + outcomecnt
                  Case outcome=('02')
                     m.oabr_misc=m.oabr_misc + outcomecnt
                  Case outcome =('03')
                     m.clfu_misc=m.clfu_misc + outcomecnt
                  Case outcome=('04')
                     m.cc_misc=m.cc_misc + outcomecnt
               Endcase
         EndCase
   EndCase
EndScan


* total the two types of standby guardianship
m.standby = m.guarddesig + m.guardjudic

* must only have one record report cursor
If Used('leg_out')
   Use In leg_out
Endif

Select  Distinct;
     system_id, ;
     m.bankrupt As bankrupt, ;
     m.collection As Collection, ;
     m.utilities As utilities, ;
     m.warranties As warranties, ;
     m.creditdisc As creditdisc, ;
     m.illdefjudg As illdefjudg, ;
     m.smallclaim As smallclaim, ;
     m.oabr_confi As oabr_confi, ;
     m.clfu_confi As clfu_confi, ;
     m.cc_confi As cc_confi, ;
     m.suspension As suspension, ;
     m.specialed As specialed, ;
     m.oabr_ed As oabr_ed, ;
     m.clfu_ed As clfu_ed, ;
     m.cc_ed As cc_ed, ;
     m.discrimjob As discrimjob, ;
     m.wrongful As wrongful, ;
     m.wages As wages, ;
     m.empbenefit As empbenefit, ;
     m.oabr_emp As oabr_emp, ;
     m.clfu_emp As clfu_emp, ;
     m.cc_emp As cc_emp, ;
     m.adoption As adoption, ;
     m.custody As custody, ;
     m.visit As visit, ;
     m.domestic As domestic, ;
     m.divorce As divorce, ;
     m.fostercare As fostercare, ;
     m.guardian As guardian, ;
     m.standby As standby, ;
     m.guarddesig As guarddesig, ;
     m.guardjudic As guardjudic, ;
     m.parighterm As parighterm, ;
     m.support As Support, ;
     m.oabr_fam As oabr_fam, ;
     m.clfu_fam As clfu_fam, ;
     m.cc_fam As cc_fam, ;
     m.accessprov As accessprov, ;
     m.benefits As benefits, ;
     m.premature As premature, ;
     m.disability As disability, ;
     m.harmful As harmful, ;
     m.oabr_helth As oabr_helth, ;
     m.clfu_helth As clfu_helth, ;
     m.cc_helth As cc_helth, ;
     m.eviction As eviction, ;
     m.accesshous As accesshous, ;
     m.landlord As landlord, ;
     m.tenant As tenant, ;
     m.dwelling As dwelling, ;
     m.oabr_hous As oabr_hous, ;
     m.clfu_hous As clfu_hous, ;
     m.cc_hous As cc_hous, ;
     m.incbenefit As incbenefit, ;
     m.oabr_incom As oabr_incom, ;
     m.clfu_incom As clfu_incom, ;
     m.cc_incom As cc_incom, ;
     m.deport As deport, ;
     m.legalstat As legalstat, ;
     m.indrights As indrights, ;
     m.incarright As incarright, ;
     m.oabr_ind As oabr_ind, ;
     m.clfu_ind As clfu_ind, ;
     m.cc_ind As cc_ind, ;
     m.chiprotect As chiprotect, ;
     m.emancipate As emancipate, ;
     m.oabr_juv As oabr_juv, ;
     m.clfu_juv As clfu_juv, ;
     m.cc_juv As cc_juv, ;
     m.will As will, ;
     m.oabr_misc As oabr_misc, ;
     m.clfu_misc As clfu_misc, ;
     m.cc_misc As cc_misc, ;
     m.debtRelief As debtRelief,;
     m.taxReleif As taxReleif,;
     m.abuseRelief As abuseRelief,;
     m.returnedFC As returnedFC,;
     m.deedTransfer As deedTransfer,;
     m.agreementLanlord As agreementLanlord,;
     m.improvedHousing As improvedHousing,;
     m.moreTime As moreTime,;
     m.housingSubsity As housingSubsity,;
     m.obtainedCitizenship As obtainedCitizenship,;
     m.obtainedWorkAuth As obtainedWorkAuth,;
     m.obtainedPOA As obtainedPOA,;
     m.revokedPOA As revokedPOA,;
     ParamC As  Crit, ;
     cDate As cDate, ;
     cTime As cTime, ;
     Date_from As Date_from, ;
     Date_to As Date_to ;
From System ;
Where system_id = gcSys_Prefix ;
Into Cursor leg_out

oApp.msg2user('OFF')
gcRptName = 'rpt_leg_out'
Go Top
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   Do Case
      Case lPrev = .F.
         Report Form rpt_leg_out To Printer Prompt Noconsole Nodialog
      Case lPrev = .T.     &&Preview
         oApp.rpt_print(5, .T., 1, 'rpt_leg_out', 1, 2)
   Endcase
Endif

*********************************************************
Function clean_data

If Used('AI_ENC')
   Use In ai_enc
Endif
If Used('CSCLODUR')
   Use In CsCloDur
Endif
If Used('CSOUTCOME')
   Use In CsOutCome
Endif
If Used('DUMMY')
   Use In DUMMY
Endif
Return


