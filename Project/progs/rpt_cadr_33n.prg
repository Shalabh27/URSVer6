***CADR Report  Q 33
Select * from t_prog Where fund_type='04' or fund_type='14' Into Array aTitle4
funding4= (_Tally>0)

* jss, 11/27/07, delete buddy, childwel, clientad, ref_res, otherser,paracare,profcare,speccare
*                add pharmass, insprem, homecar, commcar, medcase, lingser,  re-order and re-org rest


*** following is the new order of the 33 services A-Z, AA-AE with Descriptions and Cadrserv column names

***33A: Outpatient/ambulatory : ambulat
***33B: AIDS Pharmaceutical Assistance : pharmass (new)
***33C: Oral health care : oral
***33D: Early Intervention Services (Parts A and B) : earlyser
***33E: Health Insurance Premium and Cost Sharing Assistance : ins_prem (new)
***33F: Home Health Care : home_care (new)
***33G: Home and community-based health services : comm_care (new)
***33H: Hospice Services : res_care
***33I: Mental health services : mental
***33J: Medical nutrition therapy : nutrit
***33K: Medical Case Management : med_case (new)
***33L: Substance Abuse Services - Outpatient : sub_outp
***33M: Case management (non-medical) : case_man
***33N: Child care services : childser
***33O: Pediatric development assessment/early intervention services : develser
***33P: Emergency financial assistance : emergen
***33Q: Food bank/home-delivered meals : foodbank
***33R: Health education/risk reduction : healthed
***33S: Housing services : housser
***33T: Legal services : legalser
***33U: Linguistics Services : ling_ser (new)
***33V: Medical tranportation services : transer
***33W: Outreach services : outreach
***33X: Permanency planning : perplan
***33Y: Psychosocial support services : psychser
***33Z: Referral for health care/supportive services : ref_care
***33AA: Rehabilitation services : rehabil
***33AB: Respite care : day_care
***33AC: Substance Abuse Services - Residential : sub_res
***33AD: Treatment adherence counseling : treatmen

   STORE '0' TO m.ambulat_3, m.ambulat_6, m.ambulat_9
   STORE TRAN(0,'999999') TO m.ambulat_4, m.ambulat_5, m.ambulat_7, m.ambulat_8
   STORE '0' TO m.pharmass_3, m.pharmass_6
   STORE TRAN(0,'999999') TO m.pharmass_4, m.pharmass_5
   STORE '0' TO m.oral_3, m.oral_6, m.oral_9
   STORE TRAN(0,'999999') TO m.oral_4, m.oral_5, m.oral_7, m.oral_8
   STORE '0' TO m.earlyser_3, m.earlyser_6, m.earlyser_9
   STORE TRAN(0,'999999') TO m.earlyser_4, m.earlyser_5, m.earlyser_7, m.earlyser_8
   STORE '0' TO m.insprem_3
   STORE '0' TO m.homecar_3, m.homecar_6, m.homecar_9
   STORE TRAN(0,'999999') TO m.homecar_4, m.homecar_5, m.homecar_7, m.homecar_8
   STORE '0' TO m.commcar_3, m.commcar_6, m.commcar_9
   STORE TRAN(0,'999999') TO m.commcar_4, m.commcar_5, m.commcar_7, m.commcar_8
   STORE '0' TO m.res_care_3, m.res_care_6, m.res_care_9
   STORE TRAN(0,'999999') TO m.res_care_4, m.res_care_5, m.res_care_7, m.res_care_8
   STORE '0' TO m.mental_3, m.mental_6, m.mental_9
   STORE TRAN(0,'999999') TO m.mental_4, m.mental_5, m.mental_7, m.mental_8
   STORE '0' TO m.nutrit_3, m.nutrit_6, m.nutrit_9
   STORE TRAN(0,'999999') TO m.nutrit_4, m.nutrit_5, m.nutrit_7, m.nutrit_8
   STORE '0' TO m.med_case_3, m.med_case_6, m.med_case_9
   STORE TRAN(0,'999999') TO m.med_case_4, m.med_case_5, m.med_case_7, m.med_case_8
   STORE '0' TO m.sub_out_3, m.sub_out_6, m.sub_out_9
   STORE TRAN(0,'999999') TO m.sub_out_4, m.sub_out_5, m.sub_out_7, m.sub_out_8
   STORE '0' TO m.case_man_3, m.case_man_6, m.case_man_9
   STORE TRAN(0,'999999') TO m.case_man_4, m.case_man_5, m.case_man_7, m.case_man_8
   STORE '0' TO m.childser_3, m.childser_6
   STORE TRAN(0,'999999') TO m.childser_4, m.childser_5
   STORE '0' TO m.develser_3, m.develser_6
   STORE TRAN(0,'999999') TO m.develser_4, m.develser_5
   STORE '0' TO m.emergen_3, m.emergen_6
   STORE TRAN(0,'999999') TO m.emergen_4, m.emergen_5
   STORE '0' TO m.foodbank_3, m.foodbank_6
   STORE TRAN(0,'999999') TO m.foodbank_4, m.foodbank_5
   STORE '0' TO m.healthed_3, m.healthed_6
   STORE TRAN(0,'999999') TO m.healthed_4, m.healthed_5
   STORE '0' TO m.housser_3, m.housser_6
   STORE TRAN(0,'999999') TO m.housser_4, m.housser_5
   STORE '0' TO m.legalser_3, m.legalser_6
   STORE TRAN(0,'999999') TO m.legalser_4, m.legalser_5
   STORE '0' TO m.lingser_3, m.lingser_6
   STORE TRAN(0,'999999') TO m.lingser_4, m.lingser_5
   STORE '0' TO m.transer_3, m.transer_6
   STORE TRAN(0,'999999') TO m.transer_4, m.transer_5
   STORE '0' TO m.outreach_3, m.outreach_6
   STORE TRAN(0,'999999') TO m.outreach_4, m.outreach_5
   STORE '0' TO m.perplan_3, m.perplan_6
   STORE TRAN(0,'999999') TO m.perplan_4, m.perplan_5
   STORE '0' TO m.psychser_3, m.psychser_6
   STORE TRAN(0,'999999') TO m.psychser_4, m.psychser_5
   STORE '0' TO m.ref_care_3, m.ref_care_6
   STORE TRAN(0,'999999') TO m.ref_care_4, m.ref_care_5
   STORE '0' TO m.rehabil_3, m.rehabil_6
   STORE TRAN(0,'999999') TO m.rehabil_4, m.rehabil_5
   STORE '0' TO m.day_care_3, m.day_care_6
   STORE TRAN(0,'999999') TO m.day_care_4, m.day_care_5
   STORE '0' TO m.sub_res_3, m.sub_res_6
   STORE TRAN(0,'999999') TO m.sub_res_4, m.sub_res_5
   STORE '0' TO m.treatmen_3, m.treatmen_6
   STORE TRAN(0,'999999') TO m.treatmen_4, m.treatmen_5

*-------------------------------------------------------------------
*** Section 3
* jss, Q35(2004) becomes Q33(2005) 
*---Q33

* jss, 11/27/07, modify code to follow new PDR mappings (see Cadrserv.dbf)
* jss, 11/29/07, no longer need to refer to cadrserv, as we only check off services if services found (for 2007 onward),
*                so remove cadrserv code below

	m.section = Space(40) + "SECTION 3.  SERVICE INFORMATION"
	m.part = ""
	m.group   = "33.  Services provided, # of clients served, and total # of visits during this reporting period: " 
	m.info = 33
	Insert Into cadr_tmp From Memvar

	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('³',1) + Space(17) + "(1)" + Space(18)  + REPL('³',1) + "   (2)  " + REPL('³',1) + ;
			Space(7) + "(3a)" + Space(6) + REPL('³',1) + ;
			"  (3b)  " + REPL('³',1) + Space(7) + "(4a)" + Space(6)	+ REPL('³',1) + "  (4b)  " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
	
	m.group = REPL('³',1) + Space(10)+ "Service Categories" + Space(10) + REPL('³',1) + "Check if" + REPL('³',1) + ;
			"    Total # of   " + REPL('³',1) + ;
			"Check if" + REPL('³',1) + "    Total # of   "	+ REPL('³',1) + "Check if" + REPL('³',1)
	
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('³',1) + Space(38) + REPL('³',1) + "service " + REPL('³',1) + ;
			"unduplic. clients" + REPL('³',1) + ;
			"  # of  " + REPL('³',1) + "      visits     "	+ REPL('³',1) + "  # of  " + REPL('³',1)
			
	Insert Into cadr_tmp From Memvar

	m.group = REPL('³',1) + Space(38) + REPL('³',1) + "   was  " + REPL('³',1) + Repl('Ä',17)  + REPL('³',1) + ;
			" clients" + REPL('³',1) + Repl('Ä',17)	+ REPL('³',1) + " visits " + REPL('³',1)
	Insert Into cadr_tmp From Memvar

	
	m.group = REPL('³',1) + Space(38) + REPL('³',1) + "provided" + REPL('³',1) + "  HIV+  " + REPL('³',1) + "Affected" + REPL('³',1) + ;
			" unknown" + REPL('³',1) + "  HIV+  " + REPL('³',1) + "Affected"	+ REPL('³',1) + " unknown" + REPL('³',1)
	Insert Into cadr_tmp From Memvar
   	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

   m.group = Space(11)+ "CORE SERVICES" 
   Insert Into cadr_tmp From Memvar
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   ***Outpatient/ambulatory 33A
   cNA1 = 'N/A'+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)
   cCk1 = Padc('û',3)+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)

   m.group = Padr(" a.  Outpatient/ambulatory medical care",43)
      
   If Not funding4 
      Select tot_hiv
      If Seek("33A", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33A"
            m.group = m.group +Padc('û',3)+'   '+Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)

            * define vars for section3.dbf
            m.ambulat_3='1'
            m.ambulat_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.ambulat_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
            m.group = m.group + cNA1
         Endif            
      Else
         m.group = m.group + cNA1
      Endif
* jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else
      m.cm = 0
      Select tot_hiv
      If Seek("33A ", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.ambulat_3='1'
         m.ambulat_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.ambulat_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1               
      Else
         m.group = m.group + cNA1
      EndIf
                    
*!*         If Seek("33A ", "tot_aff")
*!*               If m.cm = 1
*!*                  m.group = m.group+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
*!*                  m.ambulat_5=TRAN(tot_aff.tot_affc,'999999')
*!*                  m.ambulat_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                  m.ambulat_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                  m.group = m.group+' '+Replicate('±',9)+Replicate(' ',9)+Padl('0',8)+' '+Replicate('±',9)+Padl('0',8)
*!*                  m.ambulat_3='1'
*!*                  m.ambulat_5=TRAN(tot_aff.tot_affc,'999999')
*!*                  m.ambulat_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif   
*!*         Else
*!*               If m.cm = 1
*!*                     m.group = m.group + ' '+ Repl('±', 8) + Space(12) + tot_hiv.tot_hivs +' '+ Repl('±', 8)
*!*                     m.ambulat_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                  m.group = m.group + cNA2
*!*               Endif
*!*         Endif
 
   Endif
   
   Insert Into cadr_tmp From Memvar

   *** AIDS Pharmaceutical Assistance 33b
   cNA2='N/A'+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate('±',9)+Replicate('±',9)+Replicate('±',9)
   cCk2=Padc('û',3)+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate('±',9)+Replicate('±',9)+Replicate('±',9)
   
   c3a=Padl('0',8)+' '
   
   m.group = Padr(" b.  Lcl AIDS Pharm Assist/dispense pharm",43)
   m.cm = 0
   Select tot_hiv
   
   If Seek("33B", "tot_hiv")
      c3a=Padl(Ptot_hiv.tot_hivc,8)+' '
      
      m.group = m.group+Padc('û',3)+'   '+Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Replicate('±',9)+Replicate('±',9)+Replicate('±',9)
      m.pharmass_3='1'
      m.pharmass_4=TRAN(tot_hiv.tot_hivc,'999999')
      m.cm = 1
   Else
      m.group = m.group+'N/A'+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate('±',9)+Replicate('±',9)+Replicate('±',9)
   Endif

*!*      If Seek("33B", "tot_aff")
*!*         If m.cm = 1
*!*            m.group = m.group + Space(3) + Repl('±', 8) + Space(10) + Repl('±', 26)
*!*            m.pharmass_5=TRAN(tot_aff.tot_affc,'999999')
*!*         Else
*!*            m.group = m.group + Space(2) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + Space(10) + Repl('±', 26)
*!*            m.pharmass_3='1'
*!*            m.pharmass_5=TRAN(tot_aff.tot_affc,'999999')
*!*         Endif
*!*      Else
*!*         If m.cm = 1               
*!*             m.group = m.group + ' '+ Repl('±', 8) + Space(10) + Repl('±', 26)
*!*         Else
*!*             m.group = m.group + Space(2) + "N/A" + Space(30) +  Repl('±', 26)
*!*         Endif
*!*      Endif
                  
   Insert Into cadr_tmp From Memvar   

***Oral health care 33C
   m.group = padr(" c.  Oral health care",43)
   * jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv
      If Seek("33C", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33C"
            m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
            m.oral_3='1'
            m.oral_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.oral_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
            m.group = m.group + cNA1
         Endif               
      Else
         m.group = m.group + cNA1
      Endif
* jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else
      m.cm = 0
      Select tot_hiv

      If Seek("33C", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.oral_3='1'
         m.oral_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.oral_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1               
      Else
         m.group = m.group + cNA1
      Endif               
      
*!*         If Seek("33C", "tot_aff")
*!*            If m.cm = 1               
*!*               m.oral_5=TRAN(tot_aff.tot_affc,'999999')
*!*               m.oral_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               m.oral_8=TRAN(tot_aff.tot_affs,'999999')
*!*            Else
*!*               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(17) + "0" + Space(3) + tot_aff.tot_affs
*!*               m.oral_3='1'
*!*               m.oral_5=TRAN(tot_aff.tot_affc,'999999')
*!*               m.oral_8=TRAN(tot_aff.tot_affs,'999999')
*!*            Endif
*!*         Else
*!*            If m.cm = 1
*!*               m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + Space(8) + "0"
*!*               m.oral_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*            Else
*!*               m.group = m.group + Space(3) + "N/A"
*!*            Endif
*!*         Endif

   Endif

   Insert Into cadr_tmp From Memvar

*** Early Intervention Services (Parts A and B) 33D
   m.group = Padr(" d.  Early int. svc. for Parts A and B",43)
   
   * jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33D", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33D"
               m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
               m.earlyser_3='1'
               m.earlyser_4=TRAN(tot_hiv.tot_hivc,'999999')
               m.earlyser_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
               m.group = m.group + cNA1
         Endif                  
      Else
         m.group = m.group + cNA1
      Endif
* jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33D", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.earlyser_3='1'
         m.earlyser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.earlyser_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1
      Else
         m.group = m.group + cNA1

      Endif               

*!*         If Seek("33D", "tot_aff")
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(3) + tot_aff.tot_affs
*!*                     m.earlyser_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.earlyser_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                     m.earlyser_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                     m.group = m.group + Space(4) + REPL('û', 1) + '   '+ Repl('±', 8) + Space(3) + Repl('±', 8) + ;
*!*                         Space(10)+ Repl('±', 8) + Space(3) + tot_aff.tot_affs
*!*                     m.earlyser_3='1'
*!*                     m.earlyser_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.earlyser_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif         
*!*         Else
*!*               If m.cm = 1               
*!*                     m.group = m.group + ' '+ Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           ' '+ Repl('±', 8)
*!*                     m.earlyser_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                  m.group = m.group + Space(3) + "N/A"                 
*!*               Endif            
*!*         Endif               
                     
   Endif   
   
   Insert Into cadr_tmp From Memvar

***Health Insurance Premium and Cost Sharing Assistance 33E
   m.group = Padr(" e.  Health Ins. Prem. & Cost Share Asst",40)

   Select tot_hiv   
   If Seek("33E", "tot_hiv")
      m.group = m.group + Space(4) + REPL('û', 1) + Space(3) + Repl('±', 54)
      m.insprem_3='1'
   Else
      m.group = m.group + Space(3) + "N/A" + Space(2) +  Repl('±', 54)
   Endif

   Insert Into cadr_tmp From Memvar   

***Home Health Care 33F
   m.group = Padr(" f.  Home health care",43)

   * jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33F", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33F"
            m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
            m.homecar_3='1'
            m.homecar_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.homecar_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
            m.group = m.group + cNA1
         Endif               
      Else
         m.group = m.group + cNA1
      Endif
   
   * jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv

      If Seek("33F", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.homecar_3='1'
         m.homecar_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.homecar_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1
      Else
         m.group = m.group + cNA1
      Endif
   
*!*         If Seek("33F", "tot_aff")
*!*           If m.cm = 1               
*!*              m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + Space(3) + tot_aff.tot_affs
*!*              m.homecar_5=TRAN(tot_aff.tot_affc,'999999')
*!*              m.homecar_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*              m.homecar_8=TRAN(tot_aff.tot_affs,'999999')
*!*           Else
*!*              m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + Space(17) + "0" + Space(3) + Repl('±', 8)
*!*              m.homecar_3='1'
*!*              m.homecar_5=TRAN(tot_aff.tot_affc,'999999')
*!*              m.homecar_8=TRAN(tot_aff.tot_affs,'999999')
*!*           Endif         
*!*         Else
*!*           If m.cm = 1               
*!*              m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + Space(8) + "0"
*!*              m.homecar_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*            Else
*!*              m.group = m.group + Space(3) + "N/A"  
*!*            Endif            
*!*         Endif               
    Endif   
   
   Insert Into cadr_tmp From Memvar

***Home and community-based health services 33G
   m.group = Padr(" g.  Home & community-based health svc. ",43)

* jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33G", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33G"
            m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
            m.commcar_3='1'
            m.commcar_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.commcar_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
            m.group = m.group + cNA1
         Endif               
      Else
         m.group = m.group + cNA1
      Endif
   * jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33G", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.commcar_3='1'
         m.commcar_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.commcar_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1               
      Else
         m.group = m.group + cNA1

      Endif               
   
*!*         If Seek("33G", "tot_aff")
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(3) + Repl('±', 8)
*!*                     m.commcar_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.commcar_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                     m.commcar_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                     m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + ;
*!*                         Space(17) + "0" + Space(3) + Repl('±', 8)
*!*                     m.commcar_3='1'
*!*                     m.commcar_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.commcar_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif         
*!*         Else
*!*               If m.cm = 1
*!*                     m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(8) + "0"
*!*                     m.commcar_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                   m.group = m.group + Space(3) + "N/A"
*!*               Endif
*!*         Endif

    Endif   
   
   Insert Into cadr_tmp From Memvar

***Hospice Services 33H
   m.group = Padr(" h.  Hospice services",43)

   * jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33H", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.res_care_3='1'
         m.res_care_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.res_care_7=TRAN(tot_hiv.tot_hivs,'999999')
      Else
         m.group = m.group + cNA1
      Endif
   * jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33H", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.res_care_3='1'
         m.res_care_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.res_care_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1               
      Else
         m.group = m.group + cNA1

      Endif               
*!*         If Seek("33H", "tot_aff")
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(3) + Repl('±', 8)      
*!*                     m.res_care_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.res_care_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                     m.res_care_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                     m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + ;
*!*                         Space(17) + "0" + Space(3) + Repl('±', 8)
*!*                     m.res_care_3='1'
*!*                     m.res_care_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.res_care_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif         
*!*         Else
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(8) + "0"
*!*                     m.res_care_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                  m.group = m.group + Space(3) + "N/A"           
*!*               Endif            
*!*         Endif               
   Endif   
   
   Insert Into cadr_tmp From Memvar
   
***Mental health services 33I
   m.group = Padr(" i.  Mental health services",43)
   
   If Not funding4
      Select tot_hiv
      If Seek("33I", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33I"
            m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
            m.mental_3='1'
            m.mental_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.mental_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
               m.group = m.group + cNA1
         Endif            
      Else
         m.group = m.group + cNA1
      Endif
* jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33I", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.mental_3='1'
         m.mental_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.mental_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1               
       Else
         m.group = m.group + cNA1

      Endif               
   
*!*         If Seek("33I", "tot_aff")
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(3) + Repl('±', 8)
*!*                     m.mental_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.mental_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                     m.mental_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                     m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + ;
*!*                         Space(17) + "0" + Space(3) + Repl('±', 8)
*!*                     m.mental_3='1'
*!*                     m.mental_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.mental_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif         
*!*         Else
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(8) + "0"
*!*                     m.mental_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                  m.group = m.group + Space(3) + "N/A"           
*!*               Endif            
*!*         Endif               
                     
   Endif   

   Insert Into cadr_tmp From Memvar

***Medical nutrition therapy 33J
   m.group = Padr(" j.  Medical nutrition therapy",43)

* jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33J", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.nutrit_3='1'
         m.nutrit_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.nutrit_7=TRAN(tot_hiv.tot_hivs,'999999')
      Else
         m.group = m.group + cNA1
      EndIf
      
   * jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33J", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.nutrit_3='1'
         m.nutrit_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.nutrit_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1
      Else
         m.group = m.group + cNA1

      Endif               
*!*         If Seek("33J", "tot_aff")
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(3) + Repl('±', 8)      
*!*                     m.nutrit_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.nutrit_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                     m.nutrit_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                     m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + ;
*!*                         Space(17) + "0" + Space(3) + Repl('±', 8)
*!*                     m.nutrit_3='1'
*!*                     m.nutrit_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.nutrit_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif         
*!*         Else
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(8) + "0"
*!*                     m.nutrit_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                  m.group = m.group + Space(3) + "N/A"           
*!*               Endif            
*!*         Endif
                     
   Endif   
   
   Insert Into cadr_tmp From Memvar
   
***Medical Case Management 33K
   m.group = Padr(" k.  Medical Case Management",43)

* jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33K", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.med_case_3='1'
         m.med_case_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.med_case_7=TRAN(tot_hiv.tot_hivs,'999999')
      Else
         m.group = m.group + cNA1
      Endif
* jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33K", "tot_hiv")
         m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
         m.med_case_3='1'
         m.med_case_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.med_case_7=TRAN(tot_hiv.tot_hivs,'999999')
         m.cm = 1               
      Else
         m.group = m.group + cNA1
      Endif
   
*!*         If Seek("33K", "tot_aff")
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(3) + Repl('±', 8) + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(3) + Repl('±', 8)      
*!*                     m.med_case_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.med_case_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*                     m.med_case_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Else
*!*                     m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + Repl('±', 8) + ;
*!*                         Space(17) + "0" + Space(3) + Repl('±', 8)
*!*                     m.med_case_3='1'
*!*                     m.med_case_5=TRAN(tot_aff.tot_affc,'999999')
*!*                     m.med_case_8=TRAN(tot_aff.tot_affs,'999999')
*!*               Endif         
*!*         Else
*!*               If m.cm = 1               
*!*                     m.group = m.group + Space(8) + "0" + Space(12) + tot_hiv.tot_hivs + ;
*!*                           Space(8) + "0"
*!*                     m.med_case_7=TRAN(tot_hiv.tot_hivs,'999999')
*!*               Else
*!*                  m.group = m.group + cNA1
*!*               Endif            
*!*         Endif               
                     
   Endif   
   
   Insert Into cadr_tmp From Memvar
   
***Substance Abuse Services - Outpatient 33L
   m.group = Padr(" l.  Substance abuse svc. - outpatient",43)
   *  cNA1 = 'N/A'+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)
   *  cCk1 = Padc('û',3)+'   '+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)+Replicate(' ',9)+Replicate('±',9)+Replicate(' ',9)
   *  m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)

* jss, 3/25/05, add code to handle possibility of affected clients receiving this service (title IV only)
   If Not funding4
      Select tot_hiv   
      If Seek("33L", "tot_hiv")
         If Alltrim(tot_hiv.cadr_map) == "33L"
            m.group = m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
            m.sub_out_3='1'
            m.sub_out_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.sub_out_7=TRAN(tot_hiv.tot_hivs,'999999')
         Else
            m.group = m.group + cNA1
         Endif                  
      Else
         m.group = m.group + cNA1
      Endif
* jss, 3/25/05, next else handles Title IV funding situation, in which we display whatever count is found for affected clients
   Else 
      m.cm = 0
      Select tot_hiv
      If Seek("33L", "tot_hiv")
            m.group=m.group + Padc('û',3)+'   '+ Padl(tot_hiv.tot_hivc,8)+' '+Replicate('±',9)+Replicate(' ',9)+Padl(tot_hiv.tot_hivs,8)+' '+Replicate('±',9)+Replicate(' ',9)
            m.sub_out_3='1'
            m.sub_out_4=TRAN(tot_hiv.tot_hivc,'999999')
            m.sub_out_7=TRAN(tot_hiv.tot_hivs,'999999')
            m.cm = 1
      Else
         m.group = m.group + cNA1
      Endif               
   Endif   
   
   Insert Into cadr_tmp From Memvar

   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   m.group = Space(11)+ "SUPPORT SERVICES" 
   Insert Into cadr_tmp From Memvar

   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

***Case management (non-medical) 33M
   m.group = " m.  Case management (non-medical)      "
   m.cm = 0
   Select tot_hiv
   If Seek("33M", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.case_man_3='1'
         m.case_man_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33M", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.case_man_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.case_man_3='1'
               m.case_man_5=TRAN(tot_aff.tot_affc,'999999')
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)      
         Endif            
   Endif               
        
   Insert Into cadr_tmp From Memvar   

***Child care services 33N
   m.group = " n.  Child care services                "
   m.cm = 0
   Select tot_hiv
   If Seek("33N", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.childser_3='1'
         m.childser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33N", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.childser_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.childser_3='1'
               m.childser_5=TRAN(tot_aff.tot_affc,'999999')
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)      
         Endif            
   Endif               
        
   Insert Into cadr_tmp From Memvar   

***Pediatric development assessment/early intervention services 33O
   m.group = " o.  Pediatric development assessmnt/EIS"
   m.cm = 0
   Select tot_hiv
   If Seek("33O", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.develser_3='1'
         m.develser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33O", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.develser_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc
               m.develser_3='1'
               m.develser_5=TRAN(tot_aff.tot_affc,'999999')
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)      
         Endif            
   Endif               
      
   Insert Into cadr_tmp From Memvar   

***Emergency financial assistance 33P
   m.group = " p.  Emergency financial assistance     "
   m.cm = 0
   Select tot_hiv
   If Seek("33P", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.emergen_3='1'
         m.emergen_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33P", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.emergen_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.emergen_3='1'
               m.emergen_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else      
               m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
      
   Insert Into cadr_tmp From Memvar      

***Food bank/home-delivered meals 33Q
   m.group = " q.  Food bank/home-delivered meals     "
   m.cm = 0
   Select tot_hiv
   If Seek("33Q", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.foodbank_3='1'
         m.foodbank_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33Q", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.foodbank_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.foodbank_3='1'
               m.foodbank_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)      
         Endif            
   Endif               
                  
   Insert Into cadr_tmp From Memvar      

***Health education/risk reduction 33R
   m.group = " r.  Health education/risk reduction    "
   m.cm = 0
   Select tot_hiv   
   If Seek("33R", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.healthed_3='1'
         m.healthed_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33R", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.healthed_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.healthed_3='1'
               m.healthed_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
       
   Insert Into cadr_tmp From Memvar      

***Housing services 33S
   m.group = " s.  Housing services                   "
   m.cm = 0
   Select tot_hiv
   If Seek("33S", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.housser_3='1'
         m.housser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33S", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.housser_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.housser_3='1'
               m.housser_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
        
   Insert Into cadr_tmp From Memvar      

***Legal services 33T
   m.group = " t.  Legal services                     "
   m.cm = 0
   Select tot_hiv
   If Seek("33T", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.legalser_3='1'
         m.legalser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33T", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.legalser_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.legalser_3='1'
               m.legalser_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
      
   Insert Into cadr_tmp From Memvar      

***Linguistics Services 33U
   m.group = " u.  Linguistics services               "
   m.cm = 0
   Select tot_hiv
   If Seek("33U", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.lingser_3='1'
         m.lingser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33U", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.lingser_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.lingser_3='1'
               m.lingser_5=TRAN(tot_aff.tot_affc,'999999')
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                    
   Insert Into cadr_tmp From Memvar   

***Medical tranportation services 33V
   m.group = " v.  Medical transportation services    "
   m.cm = 0
   Select tot_hiv   
   If Seek("33V", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.transer_3='1'
         m.transer_4=TRAN(tot_hiv.tot_hivc,'999999')

         m.cm = 1               
   Endif               

   If Seek("33V", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.transer_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.transer_3='1'
               m.transer_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                    
   Insert Into cadr_tmp From Memvar   

***Outreach services 33W
   m.group = " w.  Outreach services                  "
   m.cm = 0
   Select tot_hiv
   If Seek("33W", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.outreach_3='1'
         m.outreach_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33W", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.outreach_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.outreach_3='1'
               m.outreach_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                  
   Insert Into cadr_tmp From Memvar
   
***Permanency planning 33X
   m.group = " x.  Permanency planning                "
   m.cm = 0
   Select tot_hiv   
   If Seek("33X", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.perplan_3='1'
         m.perplan_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33X", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.perplan_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.perplan_3='1'
               m.perplan_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
               m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
      
   Insert Into cadr_tmp From Memvar      

***Psychosocial support services 33Y
   m.group = " y.  Psychosocial support services      "
   m.cm = 0
   Select tot_hiv   
   If Seek("33Y", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.psychser_3='1'
         m.psychser_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33Y", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.psychser_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.psychser_3='1'
               m.psychser_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else      
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                  
   Insert Into cadr_tmp From Memvar      

***Referral for health care/supportive services 33Z
   m.group = " z.  Referral for health care/sup. svc. "
   m.cm = 0
   Select tot_hiv   
   If Seek("33Z", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.ref_care_3='1'
         m.ref_care_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33Z", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.ref_care_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.ref_care_3='1'
               m.ref_care_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else      
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
      
   Insert Into cadr_tmp From Memvar      

***Rehabilitation services 33AA
   m.group = " aa. Rehabilitation services            "
   m.cm = 0
   Select tot_hiv
   If Seek("33AA", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.rehabil_3='1'
         m.rehabil_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33AA", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.rehabil_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.rehabil_3='1'
               m.rehabil_5=TRAN(tot_aff.tot_affc,'999999')
         Endif         
    Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else      
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                  
   Insert Into cadr_tmp From Memvar   

***Respite care 33AB
   m.group = " ab. Respite care                       "
   m.cm = 0
   Select tot_hiv
   If Seek("33AB", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.day_care_3='1'
         m.day_care_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33AB", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.day_care_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.day_care_3='1'
               m.day_care_5=TRAN(tot_aff.tot_affc,'999999')
         Endif         
    Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else      
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                    
   Insert Into cadr_tmp From Memvar   

***Substance Abuse Services - Residential 33AC
   m.group = " ac. Substance abuse svc. - residential "
   m.cm = 0
   Select tot_hiv
   If Seek("33AC", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.sub_res_3='1'
         m.sub_res_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33AC", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.sub_res_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.sub_res_3='1'
               m.sub_res_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else      
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
                     
   Insert Into cadr_tmp From Memvar   

***Treatment adherence counseling 33AD
   m.group = " ad. Treatment adherence counseling     "
   m.cm = 0
   Select tot_hiv
   If Seek("33AD", "tot_hiv")
         m.group = m.group + Space(4) + REPL('û', 1) + Space(6) + tot_hiv.tot_hivc 
         m.treatmen_3='1'
         m.treatmen_4=TRAN(tot_hiv.tot_hivc,'999999')
         m.cm = 1               
   Endif               
   
   If Seek("33AD", "tot_aff")
         If m.cm = 1               
               m.group = m.group + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.treatmen_5=TRAN(tot_aff.tot_affc,'999999')
         Else
               m.group = m.group + Space(4) + REPL('û', 1) + Space(11) + "0" + Space(3) + tot_aff.tot_affc + Space(10) + Repl('±', 26)
               m.treatmen_3='1'
               m.treatmen_5=TRAN(tot_aff.tot_affc,'999999')         
         Endif         
   Else
         If m.cm = 1               
               m.group = m.group + Space(8) + "0" + Space(10) + Repl('±', 26)
         Else
            m.group = m.group + Space(3) + "N/A" + Space(30) +  Repl('±', 26)
         Endif            
   Endif               
        
   Insert Into cadr_tmp From Memvar
   

use in tot_hiv
use in tot_aff
