Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              dDate_from , ;         && from date
              dDate_to, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)


cCWork = ""
LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      cCWork = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor


PRIVATE gchelp
gchelp = "COBRA Outcomes Missing Data/Quality Check"
cTitle = "COBRA Outcomes Missing Data/Quality Check"

cDate = DATE()
cTime = TIME()

cWhere = IIF(Empty(cCWork),"","  And  Inlist(ai_work.worker_id, "  + cCWork + ")" )

** 1. Pick up All Outcomes for selected Program (all program enrollments) and worker (if selected) 
**KEY 
** 1     Data Present
** 3     Unknown 
** 0     Data Missing 
** 4     N/A


** VT 06/23/2011 AIRS-42 
**  1. changed:
*!*	         Icase((acd.treatment_type=1 Or acd.treatment_type=2), 1, ;
*!*	               (acd.alcohol_drug_treatment=1 And acd.treatment_type=0) Or (acd.alcohol_drug_treatment=0 And acd.treatment_type=0) , 0, ;
*!*	               ((acd.alcohol_drug_treatment=2 Or acd.alcohol_drug_treatment=3) And acd.treatment_type=0),4, 3 ) as is_q17a,;
     ** to:
*!*	        Icase((acd.treatment_type=1 Or acd.treatment_type=2), 1, ;
*!*	             (((acd.alcohol_drug_treatment=2 Or acd.alcohol_drug_treatment=3) And acd.treatment_type=0) or (acd.help_alcohol_drug_use=2 Or acd.help_alcohol_drug_use=3)),4,;
*!*	              (acd.alcohol_drug_treatment=1 And acd.treatment_type=0) Or (acd.alcohol_drug_treatment=0 And acd.treatment_type=0) , 0,3) as is_q17a,;
 

 ** 2. changed
*!*	         Icase((acd.alcohol_drug_consistent=1 Or acd.alcohol_drug_consistent=2),1, ;
*!*	                (acd.treatment_type=2 And acd.alcohol_drug_consistent=0) Or (acd.treatment_type=0 And acd.alcohol_drug_consistent=0), 0,;
*!*	                (acd.treatment_type=1 Or acd.alcohol_drug_treatment=1) And acd.alcohol_drug_consistent=0,4,3) as is_q171, ;	  
      ** to:
*!*	         Icase((acd.alcohol_drug_consistent=1 Or acd.alcohol_drug_consistent=2),1, ;
*!*	              (((acd.treatment_type=1 Or acd.alcohol_drug_treatment=1) And acd.alcohol_drug_consistent=0)or (acd.help_alcohol_drug_use=2 Or acd.help_alcohol_drug_use=3)),4,;
*!*	              (acd.treatment_type=2 And acd.alcohol_drug_consistent=0) Or (acd.treatment_type=0 And acd.alcohol_drug_consistent=0),0,3) as is_q171, ;
                    

 ** 3. changed
*!*	         Icase((acd.mental_health_care_type=1 Or acd.mental_health_care_type=2),1,;
*!*	               (acd.current_mental_health_care=2 Or acd.current_mental_health_care=3) And acd.mental_health_care_type=0,4,;
*!*	                (acd.current_mental_health_care=1 And acd.mental_health_care_type=0) Or acd.mental_health_care_type=0,0,3) as is_q19a,;
     ** to:
*!*	       Icase((acd.mental_health_care_type=1 Or acd.mental_health_care_type=2),1,;
*!*	               (((acd.current_mental_health_care=2 Or acd.current_mental_health_care=3) And acd.mental_health_care_type=0) or (acd.mental_health_services=2 Or acd.mental_health_services=3)),4,;
*!*	                (acd.current_mental_health_care=1 And acd.mental_health_care_type=0) Or acd.mental_health_care_type=0,0,3) as is_q19a,;


 ** 4. changed
*!*	          Icase((acd.mental_health_care_type=2 And (acd.mental_health_attendance=2 Or acd.mental_health_attendance=1)), 1,;
*!*	                (acd.current_mental_health_care=2 Or acd.mental_health_care_type=1 Or acd.mental_health_care_type=3) And acd.mental_health_attendance=0, 4,;
*!*	                (acd.mental_health_care_type=2 And acd.mental_health_attendance=0) Or acd.mental_health_attendance=0,0,3) as is_q191,;
     ** to:
*!*	            Icase((acd.mental_health_care_type=2 And (acd.mental_health_attendance=2 Or acd.mental_health_attendance=1)), 1,;
*!*	                (((acd.current_mental_health_care=2 Or acd.current_mental_health_care=3 Or acd.mental_health_care_type=1 Or acd.mental_health_care_type=3) And acd.mental_health_attendance=0) or (acd.mental_health_services=2 Or acd.mental_health_services=3)), 4,;
*!*	                (acd.mental_health_care_type=2 And acd.mental_health_attendance=0) Or acd.mental_health_attendance=0,0,3) as is_q191,;
               
Select Distinct ;
         ach.tc_id, ;
         acd.completed_date, ;
         PADR(oApp.FormatName(cli_cur.last_name, cli_cur.first_name),50) AS client_name, ;
         Upper(Alltrim(cli_cur.last_name+cli_cur.first_name)) AS c_sort_name, ;
         ai_prog.start_dt as prg_start, ;
         ai_prog.end_dt as prg_end, ;
         ai_work.worker_id,;
         PADR(oApp.FormatName(staffcur.last, staffcur.first,staffcur.mi),50) AS worker_name, ;
         Upper(Alltrim(staffcur.last+staffcur.first+staffcur.mi)) AS w_sort_name, ;
         acd.client_has_provider, ;
         Icase((!Empty(acd.med_agency_name) And !Empty(acd.med_agency_zipcode)), 1, ;
               acd.client_has_provider=3, 3, 0 ) as is_provider, ;
         Icase(!Empty(acd.recent_hiv_care_visit), 1, acd.rec_hiv_care=1,3,0) as is_hiv_visit,;
         Icase(!Empty(acd.recent_viral_load_visit), 1, acd.rec_viral_load=1,3,0) as is_viral_visit, ;
         Icase(acd.viral_load_results<>0, 1, acd.vir_load_res=1, 3, 0) as is_viral_res,;
         Icase(!Empty(acd.recent_cd4_count), 1, acd.rec_cd4_count=1,3,0) as is_rec_cd4,;
         Icase(acd.recent_cd4_result<>0, 1,acd.rec_cd4_res=1,3,0) as is_rec_cd4_res,;
         Icase(!Empty(acd.recent_pap_smear),1,acd.rec_pap_smear=1 ,3, ;
                 (cli_cur.sex='F' And Empty(acd.recent_pap_smear) And acd.rec_pap_smear=0),0,4) as is_rec_pap_sm,;
         Icase((acd.positive_hep_c=1 Or acd.positive_hep_c=2),1,acd.positive_hep_c=3,3, 0) as is_pos_hep_c, ;
         Icase((acd.chronic_hep_c=1 Or acd.chronic_hep_c=2), 1, acd.chronic_hep_c=3, 3, ;
                 (acd.positive_hep_c=2 Or acd.positive_hep_c=3),4,0) as is_chr_hep_c,;
         Icase((acd.prescribed_arv_therapy=1 Or acd.prescribed_arv_therapy=2), 1, ;
                  acd.prescribed_arv_therapy=3,3,0) as is_pr_arv_ther, ;
         Icase((acd.hiv_therapy_adherence=1 Or acd.hiv_therapy_adherence=2),1, ;
                ((acd.prescribed_arv_therapy=1 And acd.hiv_therapy_adherence=0) Or ;
                 (acd.prescribed_arv_therapy=0 And acd.hiv_therapy_adherence=0)), 0, ;
                 (acd.prescribed_arv_therapy=2 Or acd.prescribed_arv_therapy=3), 4,3) as is_hiv_ther,;
         Icase((acd.alcohol_drug_user=1 Or acd.alcohol_drug_user=2), 1, acd.alcohol_drug_user=3,3, 0) as is_alc_use,;
         Icase((acd.help_alcohol_drug_use=1 Or acd.help_alcohol_drug_use=2), 1, acd.help_alcohol_drug_use=3,3,0) as is_help_acl, ;
         Icase((acd.alcohol_drug_treatment=1 Or acd.alcohol_drug_treatment=2) And ;
               (acd.harm_reduction=1 Or acd.harm_reduction=2), 1,  ;
               ((acd.help_alcohol_drug_use=2 Or acd.help_alcohol_drug_use=3) And acd.alcohol_drug_treatment=0), 4, ;
               (acd.alcohol_drug_treatment=0 Or acd.harm_reduction=0),0,3) as is_q17, ;
         Icase((acd.treatment_type=1 Or acd.treatment_type=2), 1, ;
             (((acd.alcohol_drug_treatment=2 Or acd.alcohol_drug_treatment=3) And acd.treatment_type=0) or (acd.help_alcohol_drug_use=2 Or acd.help_alcohol_drug_use=3)),4,;
              (acd.alcohol_drug_treatment=1 And acd.treatment_type=0) Or (acd.alcohol_drug_treatment=0 And acd.treatment_type=0),0,3) as is_q17a,;
         Icase((acd.alcohol_drug_consistent=1 Or acd.alcohol_drug_consistent=2),1, ;
              (((acd.treatment_type=1 Or acd.alcohol_drug_treatment=1) And acd.alcohol_drug_consistent=0)or (acd.help_alcohol_drug_use=2 Or acd.help_alcohol_drug_use=3)),4,;
              (acd.treatment_type=2 And acd.alcohol_drug_consistent=0) Or (acd.treatment_type=0 And acd.alcohol_drug_consistent=0),0,3) as is_q171, ;
         Icase((acd.mental_health_services=1 Or acd.mental_health_services=2),1, acd.mental_health_services=3,3,0) as is_q18, ;
         Icase((acd.current_mental_health_care=1 Or acd.current_mental_health_care=2), 1, ;
               (acd.mental_health_services=2 Or acd.mental_health_services=3) And acd.current_mental_health_care= 0, 4,;
               acd.current_mental_health_care= 0,0,3) as is_q19,;
         Icase((acd.mental_health_care_type=1 Or acd.mental_health_care_type=2),1,;
               (((acd.current_mental_health_care=2 Or acd.current_mental_health_care=3) And acd.mental_health_care_type=0) or (acd.mental_health_services=2 Or acd.mental_health_services=3)),4,;
                (acd.current_mental_health_care=1 And acd.mental_health_care_type=0) Or acd.mental_health_care_type=0,0,3) as is_q19a,;
         Icase((acd.mental_health_care_type=2 And (acd.mental_health_attendance=2 Or acd.mental_health_attendance=1)), 1,;
                (((acd.current_mental_health_care=2 Or acd.current_mental_health_care=3 Or acd.mental_health_care_type=1 Or acd.mental_health_care_type=3) And acd.mental_health_attendance=0) or (acd.mental_health_services=2 Or acd.mental_health_services=3)), 4,;
               (acd.mental_health_care_type=2 And acd.mental_health_attendance=0) Or acd.mental_health_attendance=0,0,3) as is_q191,;
         Icase((acd.mental_health_meds=1 Or acd.mental_health_meds=2),1, acd.mental_health_meds=3,3,0) as is_q20, ; 
         Icase((acd.taking_mental_health_meds=1 Or acd.taking_mental_health_meds=2), 1, ;
               (acd.mental_health_meds=2 And acd.taking_mental_health_meds=0),4, ;
               acd.taking_mental_health_meds=0,0,3) as is_q21,;   
         Icase((acd.current_housing_status<>0 And acd.current_housing_status<>4) , 1, acd.current_housing_status=4,3,0 ) as is_q22;               
from ai_prog ;
     inner join  ai_cobra_outcome_header ach on ;
          ai_prog.tc_id = ach.tc_id ; 
     inner join  ai_cobra_outcome_details acd on ;
          ach.ai_outh_id = acd.ai_outh_id ;  
     Inner Join ai_work On ;
          ai_prog.ps_id = ai_work.ps_id ;
      And ai_prog.tc_id = ai_work.tc_id ;
      And ai_prog.program = ai_work.program ;
     Inner Join staffcur On ;
          ai_work.worker_id = staffcur.worker_id ;   
     Inner join cli_cur on;
          cli_cur.tc_id = ach.tc_id ;     
Where ai_prog.program = LCProg ;
       And ai_work.effect_dt in (Select Max(effect_dt) ;
                                From ai_work aw ;
                                Where aw.ps_id = ai_work.ps_id ;
                                  And aw.tc_id = ai_work.tc_id;
                                  And aw.program =ai_work.program) ;  
      &cWhere ;
Into Cursor t_all      

*** Report Selection       
Do Case
      Case nGroup = 1               && Active
           Select * ;
           From t_all ;
           Where Empty(prg_end)  ;
           Into Cursor t_sel
           
           lcTitle = "Active"
      Case nGroup = 2               && Inactive
           Select * ;
           From t_all ;
           Where !Empty(prg_end)  ;
           Into Cursor t_sel
           
           lcTitle = "Inactive"
      Case nGroup = 3              && All
           Select * From t_all Into Cursor t_sel
           
           lcTitle = "All"
   EndCase

cTitle = ''
 
     Do Case
        Case lnStat = 1  &&& Most Recent Outcomes       
               Select * ;
               From t_sel ;
               Where completed_date  in (Select Max(completed_date) ;
                                         From t_sel tc ;
                                         Where tc.tc_id = t_sel.tc_id) ; 
               Into Cursor t_out
               cTitle = 'Most Recent Outcomes'
                 
         Case  lnStat = 2 &&& All Outcomes 
               Select * From t_sel Into Cursor t_out
               cTitle = 'All Outcomes'
     Endcase

***Order by  
cOrder = '' 
**VT 08/31/2010 Dev Tick 4807 add sort_name
Do Case
   Case nOrder = 1  
      **  cOrder = ' worker_name, client_name, completed_date desc'
         cOrder = ' w_sort_name, c_sort_name, completed_date desc'
   Case nOrder = 2
       ** cOrder = ' worker_name, completed_date desc, client_name'
        cOrder = ' w_sort_name, completed_date desc, c_sort_name'
Endcase

Use In t_all

Select *, ;
   cTitle as cTitle, ; 
   lcTitle as lcTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime ;
from t_out ;
Into Cursor cobra_miss  ;
Order By &cOrder

Use In t_out

oApp.msg2user("OFF") 
gcRptName = 'rpt_cobra_miss'    
            
Select cobra_miss   

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_cobra_miss To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.   
                    oApp.rpt_print(5, .t., 1, 'rpt_cobra_miss', 1, 2)
           ENDCASE
EndIf


