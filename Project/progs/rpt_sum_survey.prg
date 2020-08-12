Parameters lPrev, ;    && Preview
           aSelvar1, ; && select parameters from selection list
           nOrder, ;   && order by
           nGroup, ;   && report selection
           lcTitle, ;  && report selection
           start_date , ; && from date
           end_date, ;    && to date   
           Crit , ;    && name of param
           lnStat, ;   && selection(Output)  page 2
           cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)

cGroups = "" 
cCintType =""
&& Search For Parameters

For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CGROUP"
      cGroups = aSelvar2(i, 2)
   Endif
    If Rtrim(aSelvar2(i, 1)) = "CINTTYPE"
      cCintType = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gchelp
gchelp = "Summary of Survey Responses Report"

cDate = DATE()
cTime = TIME()

cWhereExp =""
cWhereExp = IIF(EMPTY(cGroups), "", " and ahh.group_id = cGroups")
cWhereExp = cWhereExp + IIF(EMPTY(cCintType), "", " and Alltrim(Str(ahh.intervention_type)) = cCintType")


If Used('t_sum')
   Use in t_sum
EndIf

**1. Pre-Select all information
**  A. Pick Up Pre-Survey
**VT 04/15/2010 Dev Tick 6664
** ahd.unprotected as pre_3, ;
** ahd.birth_control as pre_7, ;
** ahd.condom_used_3mos_others as pre_d2 ;
** ahd.condom_used_others as pre_d4 ;

  
select ahh.mon_hdr_id , ;
       ahh.tc_id, ;
	    ahh.group_id, ;
       Padr(Nvl(group.descript, Iif(ahh.intervention_type = 1,'N/A        ','Not Entered')), 50, ' ') as group_name, ;
       Padr(Nvl(model.modelname,'N/A'),50,' ') As modelname,;
       ahh.intervention_type, ;
       Iif(ahh.intervention_type = 1,'Multiple Session IDI','Multiple Session IDG') as interv_descr,;
       ahd.having_sti as pre_1, ;       && Section A
       ahd.being_drunk as pre_2, ;
       ahd.can_be_infected as pre_3, ;
       ahd.transmitted as pre_5, ;
       ahd.sti_cured as pre_6, ;
       ahd.sti_oral as pre_7, ;
       ahd.anonymous_tested as pre_8, ;
       ahd.health_care as pre_9, ;
       ahd.lubricant as pre_10, ;
       ahd.syringes as pre_11, ;
       ahd.tested_12months as pre_b1,;            && Section B
       ahd.get_results as pre_b2, ;
       ahd.receiving_health_care as pre_b3, ;
       ahd.tested_pos as pre_b4, ; 
       ahd.comfortable_behaviors as pre_c1,;      && Section C
       ahd.comfortable_talking as pre_c2, ;
       ahd.scared_test as pre_c3, ;
       ahd.cure_secret as pre_c4,;
       ahd.condom_use as pre_d1, ;                && Section D
       ahd.condom_used_lastime_partner as pre_d3 ;
From ai_hivmonitoring_header ahh ;
    Inner Join ai_hivmonitoring_details ahd on;
       ahh.mon_hdr_id = ahd.mon_hdr_id ;
     And ahd.survey_type=1 ;              && Pre_Survey
   Left Outer Join group On ;
        ahh.group_id = Group.grp_id;
   Left Outer Join model On ;
        ahh.model_id = model.model_id;
Where Between(ahd.survey_date, start_date, end_date ) ;
	   &cWhereExp ;
Into Cursor pre_survey 

**  B. Pick Up Post-Survey and link to pre-survey
**VT 04/15/2010 Dev Tick 6664
** ahd.unprotected as post_3, ;
**ahd.birth_control as post_7, ;
** ahd.condom_used_3mos_others as post_d2, ;
**  ahd.condom_used_others as post_d4 ;

 Select ps.*, ;
          ahd.having_sti as post_1, ;       && Section A
          ahd.being_drunk as post_2, ;
          ahd.can_be_infected as post_3, ;
          ahd.transmitted as post_5, ;
          ahd.sti_cured as post_6, ;
          ahd.sti_oral as post_7, ;
          ahd.anonymous_tested as post_8, ;
          ahd.health_care as post_9, ;
          ahd.lubricant as post_10, ;
          ahd.syringes as post_11, ;
          ahd.tested_12months as post_b1,;            && Section B
          ahd.get_results as post_b2, ;
          ahd.receiving_health_care as post_b3, ;
          ahd.tested_pos as post_b4, ; 
          ahd.comfortable_behaviors as post_c1,;      && Section C
          ahd.comfortable_talking as post_c2, ;
          ahd.scared_test as post_c3, ;
          ahd.cure_secret as post_c4,;
          ahd.condom_use as post_d1, ;                && Section D                        
          ahd.condom_used_lastime_partner as post_d3 ;
From pre_survey ps; 
  inner join ai_hivmonitoring_details ahd on;
          ps.mon_hdr_id = ahd.mon_hdr_id ;
      and ahd.survey_type=2 ;        && Post_Survey
Where Between(ahd.survey_date, start_date, end_date ) ;      
Into  Cursor t_sum

**2. Pick up Unduplicated clients
Select distinct ;
            ts.tc_id, ;
            ts.group_id,;
            ts.intervention_type, ;
            Iif(client.sex="M","Male    ", "Female  ")  as gender, ;
            client.blafrican, ;
            client.asian, ;
            client.white,;
            client.hawaisland,;
            client.Indialaska, ;
            client.someother, ;
            client.hispanic, ;
            oApp.Age(end_date, client.dob) AS Client_Age ;
From t_sum ts;
 Inner Join ai_clien ac on;
        ts.tc_id = ac.tc_id;
    Inner Join client on;
        ac.client_id = client.client_id ;
Into Cursor t_cl
  
             
**3. Page1 Demographic Characteristics of Clients
Select group_id, ;
       intervention_type, ;
       Count(*) as total_cl, ;
       Sum(Iif(Alltrim(gender)='Male',1,0)) as tot_male, ;
       Sum(Iif(Alltrim(gender)='Female',1,0)) as tot_female, ;
       Sum(Iif(blafrican=1,1,0)) as total_afam, ;
       Sum(Iif(white=1,1,0)) as total_white, ;
       Sum(Iif(asian=1,1,0)) as total_asian, ;
       Sum(Iif(hawaisland=1,1,0)) as total_hawa,;
       Sum(Iif(Indialaska=1,1,0)) as total_ind, ;
       Sum(Iif(someother=1,1,0)) as total_other, ;
       Sum(Iif(hispanic=2,1,0)) as total_hisp, ;
       Sum(Iif(hispanic=1,1,0)) as total_nhisp, ;
       Sum(Iif(Client_Age < 13,1,0))   as Age0_13,;
       Sum(Iif(Between(Client_Age,13,19),1,0))  as Age13_19  ,;
       Sum(Iif(Between(Client_Age,20,29),1,0))  as Age20_29  ,;
       Sum(Iif(Between(Client_Age,30,39),1,0))  as Age30_39  ,;
       Sum(Iif(Between(Client_Age,40,49),1,0))  as Age40_49  ,;
       Sum(Iif(Client_Age >= 50,1,0)) as Age50Plus ;
From t_cl ;
Group By group_id, intervention_type ;
Into Cursor t_total

** Page 2 Section A 
**    Calculate how many cases (column1), 
**        how namy pre-survey and post-survey,
**        how many correct pre-survey and post-survey

**VT 04/15/2010 Dev Tick 6664
**  Sum(Iif(pre_3 <> 0 And post_3 <> 0, 1,0)) as total_case_unp, ;  && Q3
** Sum(Iif(post_3 <> 0 and pre_3 = 1,1,0)) as c_pre_3, ;
** Sum(Iif(pre_3 <> 0 and post_3 = 1,1,0)) as c_post_3, ;

**  AIRS-207 reverse the logic of true PB 05/2012
**  Sum(Iif(post_7 <> 0 and pre_7 = 2,1,0)) as c_pre_7, ;
**  Sum(Iif(pre_7 <> 0 and post_7 = 2,1,0)) as c_post_7, ;


Select  group_id, ;
        intervention_type, ; 
        Sum(Iif(pre_1 <> 0 And post_1 <> 0, 1,0)) as total_case_hs, ;   && Q1 &&Total # of Cases
        Sum(Iif(post_1 <> 0 and pre_1 = 1, 1, 0)) as c_pre_1, ;         &&Total pre_survey correct answers 
        Sum(Iif(pre_1 <> 0 and post_1 = 1, 1, 0)) as c_post_1, ;        &&Total post_survey correct answers
        Sum(Iif(pre_2 <> 0 And post_2 <> 0, 1,0)) as total_case_bd, ;   && Q2
        Sum(Iif(post_2 <> 0 and pre_2 = 1,1,0)) as c_pre_2 , ;
        Sum(Iif(pre_2 <> 0 and post_2 = 1,1,0)) as c_post_2,  ;
        Sum(Iif(pre_3 <> 0 And post_3 <> 0, 1,0)) as total_case_cbi, ;  && Q3
        Sum(Iif(post_3 <> 0 and pre_3 = 1,1,0)) as c_pre_3, ;
        Sum(Iif(pre_3 <> 0 and post_3 = 1,1,0)) as c_post_3, ;
        Sum(Iif(pre_5 <> 0 And post_5 <> 0, 1,0)) as total_case_trans,; && Q4
        Sum(Iif(post_5 <> 0 and pre_5 = 2,1,0)) as c_pre_5, ;
        Sum(Iif(pre_5 <> 0 and post_5 = 2,1,0)) as c_post_5, ;
        Sum(Iif(pre_6 <> 0 And post_6 <> 0, 1,0)) as total_case_stic, ; && Q5
        Sum(Iif(post_6 <> 0 and pre_6 = 2,1,0)) as c_pre_6, ;
        Sum(Iif(pre_6 <> 0 and post_6 = 2,1,0)) as c_post_6, ;
        Sum(Iif(pre_7 <> 0 And post_7 <> 0, 1,0)) as total_case_bc, ;   && Q7
        Sum(Iif(post_7 <> 0 and pre_7 = 1,1,0)) as c_pre_7, ;
        Sum(Iif(pre_7 <> 0 and post_7 = 1,1,0)) as c_post_7, ;
        Sum(Iif(pre_8 <> 0 And post_8 <> 0, 1,0)) as total_case_at, ;   && Q6
        Sum(Iif(post_8 <> 0 and pre_8 = 1,1,0)) as c_pre_8, ;
        Sum(Iif(pre_8 <> 0 and post_8 = 1,1,0)) as c_post_8, ;
        Sum(Iif(pre_9 <> 0 And post_9 <> 0, 1,0)) as total_case_hc, ;   && Q8
        Sum(Iif(post_9 <> 0 and pre_9 = 2,1,0)) as c_pre_9, ;
        Sum(Iif(pre_9 <> 0 and post_9 = 2,1,0)) as c_post_9, ;
        Sum(Iif(pre_10 <> 0 And post_10 <> 0, 1,0)) as total_case_lub,; && Q9
        Sum(Iif(post_10 <> 0 and pre_10 = 2,1,0)) as c_pre_10, ;
        Sum(Iif(pre_10 <> 0 and post_10 = 2,1,0)) as c_post_10, ;
        Sum(Iif(pre_11 <> 0 And post_11 <> 0, 1,0)) as total_case_syr,; && Q10
        Sum(Iif(post_11 <> 0 and pre_11 = 1,1,0)) as c_pre_11, ;
        Sum(Iif(pre_11 <> 0 and post_11 = 1,1,0)) as c_post_11 ;
From t_sum ;
Group By group_id, intervention_type ;
Into Cursor t_sect_a

**Page 3 Section B
***VT 04/15/2010 Dev Tick 6664 add b4
Select group_id, ;
      intervention_type, ;
      Sum(Iif(pre_b1 <> 0 And post_b1 <> 0, 1,0)) as total_case_tst_12, ;
      Sum(Iif(post_b1 <> 0 And pre_b1 = 1, 1, 0)) as c_pre_b1, ;
      Sum(Iif(pre_b1 <> 0 And post_b1 = 1, 1, 0)) as c_post_b1, ;
      Sum(Iif(pre_b2 <> 0 And post_b2 <>0, 1,0)) as total_case_gr, ;
      Sum(Iif(post_b2 <>0 And pre_b2 = 1, 1, 0)) as c_pre_b2, ;
      Sum(Iif(pre_b2 <> 0 And post_b2 = 1, 1, 0)) as c_post_b2, ;
      Sum(Iif(pre_b3 <> 0 And post_b3 <>0, 1,0)) as total_case_rhc, ;
      Sum(Iif(post_b3 <>0 And pre_b3 = 1, 1, 0)) as c_pre_b3, ;
      Sum(Iif(pre_b3 <> 0 And post_b3 = 1, 1, 0)) as c_post_b3, ;
      Sum(Iif(pre_b4 <> 0 And post_b4 <>0, 1,0)) as total_case_pos, ;
      Sum(Iif(post_b4 <>0 And pre_b4 = 1, 1, 0)) as c_pre_b4, ;
      Sum(Iif(pre_b4 <> 0 And post_b4 = 1, 1, 0)) as c_post_b4 ;
From t_sum ;
Group By group_id, intervention_type ;
Into Cursor t_sect_b

**Page 3 Section C
Select group_id, ;
      intervention_type, ;
      Sum(Iif(pre_c1 <> 0 And post_c1 <>0, 1,0)) as total_case_com_beh, ;
      Sum(Iif(pre_c1 <> 0 And post_c1 <>0 And (pre_c1 = 1 Or pre_c1 = 2),1,0)) as c_pre_c1, ;
      Sum(Iif(pre_c1 <> 0 And post_c1 <>0 And (post_c1 = 1 Or post_c1 =2),1,0)) as c_post_c1, ;
      Sum(Iif(pre_c2 <> 0 And post_c2 <>0, 1,0)) as total_case_com_tal, ;
      Sum(Iif(pre_c2 <> 0 And post_c2 <>0 And (pre_c2 = 1 Or pre_c2 = 2),1,0)) as c_pre_c2, ;
      Sum(Iif(pre_c2 <> 0 And post_c2 <>0 And (post_c2 = 1 Or post_c2 = 2),1,0)) as c_post_c2,;
      Sum(Iif(pre_c3 <> 0 And post_c3 <> 0, 1,0)) as total_case_scared, ;
      Sum(Iif(pre_c3 <> 0 And post_c3 <> 0 And (pre_c3 = 3 Or pre_c3 = 4),1,0)) as c_pre_c3, ;
      Sum(Iif(pre_c3 <> 0 And post_c3 <> 0 And (post_c3 = 3 Or post_c3 = 4),1,0)) as c_post_c3, ;
      Sum(Iif(pre_c4 <> 0 And post_c4 <>0, 1,0)) as total_case_cure, ;
      Sum(Iif(pre_c4 <> 0 And post_c4 <>0 And (pre_c4 = 3 Or pre_c4 = 4),1,0)) as c_pre_c4, ;
      Sum(Iif(pre_c4 <> 0 And post_c4 <>0 And (post_c4 = 3 Or post_c4 = 4),1,0)) as c_post_c4 ;
From t_sum ;
Group By group_id,intervention_type ;
Into Cursor t_sect_c

**Page 4 Section D
***VT 04/16/2010 Dev Tick 6664
*!*	 Sum(Iif((pre_d2 <> 0 And post_d2 <>0 and pre_d2 <> 6 And post_d2 <> 6), 1,0)) as total_case_condom_use_oth, ;
*!*	      Sum(Iif(post_d2 <>0 And post_d2 <> 6 And pre_d2 =1,1,0)) as c_pre_d2, ;
*!*	      Sum(Iif(pre_d2 <> 0 and pre_d2 <> 6 And post_d2=1,1,0)) as c_post_d2 ;
*!*	      Sum(Iif(pre_d4 <> 0 And post_d4 <> 0 , 1,0)) as total_case_condom_use_lo, ;
*!*	      Sum(Iif(post_d4 <> 0 And pre_d4 =1,1,0)) as c_pre_d4, ;
*!*	      Sum(Iif(pre_d4 <> 0 And post_d4 =1,1,0)) as c_post_d4 ;
      
Select group_id, ;
      intervention_type, ;
      Sum(Iif((pre_d1 <> 0 And post_d1 <> 0 and pre_d1 <> 6 And post_d1 <> 6), 1,0)) as total_case_condom_use, ;
      Sum(Iif(post_d1 <> 0 And post_d1 <> 6 And pre_d1 =1,1,0)) as c_pre_d1, ;
      Sum(Iif(pre_d1 <> 0 and pre_d1 <> 6 And post_d1=1,1,0)) as c_post_d1, ;
      Sum(Iif(pre_d3 <> 0 And post_d3 <> 0, 1,0)) as total_case_condom_use_l, ;
      Sum(Iif(post_d3 <> 0 And pre_d3 =1,1,0)) as c_pre_d3, ;
      Sum(Iif(pre_d3 <> 0 And post_d3=1,1,0)) as c_post_d3 ;
From t_sum ;
Group By group_id, intervention_type;
Into Cursor t_sect_d
   
***VT 04/15/2010 Dev Tick 6664
*** Nvl(ta.total_case_cbi, 000000) as total_case_cbi,;
*** IIf(ta.total_case_cbi <> 0, Iif(ta.c_pre_4 <> 0, Round((ta.c_pre_4 * 100)/ta.total_case_cbi, 0), 000000), 000000) as pre_4, ;
*** IIf(ta.total_case_cbi <> 0, IIF(ta.c_post_4 <> 0, Round((ta.c_post_4 * 100)/ta.total_case_cbi, 0), 000000), 000000) as post_4, ;
            
**Final selection
Select distinct ;
      ts.group_id, ;
      ts.group_name,  ;
      ts.modelname,;
      ts.intervention_type, ;
      ts.interv_descr, ;
      tt.total_cl, ;        &&Page1
      Nvl(tt.tot_male, 000000) as total_male, ;
      Nvl(tt.tot_female, 000000) as total_female, ;
      Nvl(tt.total_afam, 000000) as total_afam,;
      Nvl(tt.total_white, 000000) as total_white,;
      Nvl(tt.total_asian, 000000) as total_asian,;
      Nvl(tt.total_hawa, 000000) as total_hawa,;
      Nvl(tt.total_ind, 000000) as total_ind, ;
      Nvl(tt.total_other, 000000) as total_other, ;
      Nvl(tt.total_hisp, 000000) as total_hisp, ;
      Nvl(tt.total_nhisp, 000000) as total_nhisp, ;
      Nvl(tt.Age0_13, 000000)   as Age0_13,;
      Nvl(tt.Age13_19, 000000)  as Age13_19  ,;
      Nvl(tt.Age20_29, 000000) as Age20_29  ,;
      Nvl(tt.Age30_39, 000000)  as Age30_39  ,;
      Nvl(tt.Age40_49, 000000)  as Age40_49  ,;
      Nvl(tt.Age50Plus, 000000) as Age50Plus, ;
      Nvl(ta.total_case_hs, 000000) as total_case_hs, ;     &&Page 2 Section A
      IIf(ta.total_case_hs <> 0, IIf(ta.c_pre_1 <> 0, Round((ta.c_pre_1 * 100)/ta.total_case_hs, 0), 000000), 000000) as pre_1, ;
      IIf(ta.total_case_hs <> 0, IIf(ta.c_post_1 <> 0, Round((ta.c_post_1 * 100)/ta.total_case_hs, 0), 000000), 000000) as post_1, ;
      Nvl(ta.total_case_bd, 000000) as total_case_bd,;
      IIf(ta.total_case_bd <> 0, Iif(ta.c_pre_2 <> 0, Round((ta.c_pre_2 * 100)/ta.total_case_bd, 0), 000000), 000000) as pre_2, ;
      IIf(ta.total_case_bd <> 0, IIF(ta.c_post_2 <> 0, Round((ta.c_post_2 * 100)/ta.total_case_bd, 0), 000000), 000000) as post_2, ;
    	Nvl(ta.total_case_cbi, 000000) as total_case_cbi,;
		IIf(ta.total_case_cbi <> 0, Iif(ta.c_pre_3 <> 0, Round((ta.c_pre_3 * 100)/ta.total_case_cbi, 0), 000000), 000000) as pre_3, ;
		IIf(ta.total_case_cbi <> 0, IIF(ta.c_post_3 <> 0, Round((ta.c_post_3 * 100)/ta.total_case_cbi, 0), 000000), 000000) as post_3, ;
      Nvl(ta.total_case_trans, 000000) as total_case_trans,;
      IIf(ta.total_case_trans <> 0, Iif(ta.c_pre_5 <> 0, Round((ta.c_pre_5 * 100)/ta.total_case_trans, 0), 000000), 000000) as pre_5, ;
      IIf(ta.total_case_trans <> 0, IIF(ta.c_post_5 <> 0, Round((ta.c_post_5 * 100)/ta.total_case_trans, 0), 000000), 000000) as post_5, ;
      Nvl(ta.total_case_stic,000000) as total_case_stic, ;
      IIf(ta.total_case_stic <> 0, Iif(ta.c_pre_6 <> 0, Round((ta.c_pre_6 * 100)/ta.total_case_stic, 0), 000000), 000000) as pre_6, ;
      IIf(ta.total_case_stic <> 0, IIF(ta.c_post_6 <> 0, Round((ta.c_post_6 * 100)/ta.total_case_stic, 0), 000000), 000000) as post_6, ;
      Nvl(ta.total_case_bc,000000) as total_case_bc, ;
      IIf(ta.total_case_bc <> 0, Iif(ta.c_pre_7 <> 0, Round((ta.c_pre_7 * 100)/ta.total_case_bc, 0), 000000), 000000) as pre_7, ;
      IIf(ta.total_case_bc <> 0, IIF(ta.c_post_7 <> 0, Round((ta.c_post_7 * 100)/ta.total_case_bc, 0), 000000), 000000) as post_7, ;
      Nvl(ta.total_case_at,000000) as total_case_at, ;
      IIf(ta.total_case_at <> 0, Iif(ta.c_pre_8 <> 0, Round((ta.c_pre_8 * 100)/ta.total_case_at, 0), 000000), 000000) as pre_8,;
      IIf(ta.total_case_at <> 0, IIF(ta.c_post_8 <> 0, Round((ta.c_post_8 * 100)/ta.total_case_at, 0), 000000), 000000) as post_8, ;
      Nvl(ta.total_case_hc,000000)  as total_case_hc, ;
      IIf(ta.total_case_hc <> 0, Iif(ta.c_pre_9 <> 0, Round((ta.c_pre_9 * 100)/ta.total_case_hc, 0), 000000), 000000) as pre_9, ;
      IIf(ta.total_case_hc <> 0, IIF(ta.c_post_9 <> 0, Round((ta.c_post_9 * 100)/ta.total_case_hc, 0), 000000), 000000) as post_9,;
      Nvl(ta.total_case_lub,000000) as total_case_lub, ;
      IIf(ta.total_case_lub <> 0, Iif(ta.c_pre_10 <> 0, Round((ta.c_pre_10 * 100)/ta.total_case_lub, 0), 000000), 000000) as pre_10, ;
      IIf(ta.total_case_lub <> 0, IIF(ta.c_post_10 <> 0, Round((ta.c_post_10 * 100)/ta.total_case_lub, 0), 000000), 000000) as post_10,;
      Nvl(ta.total_case_syr,000000) as total_case_syr, ;
      IIf(ta.total_case_syr <> 0, Iif(ta.c_pre_11 <> 0, Round((ta.c_pre_11 * 100)/ta.total_case_syr, 0), 000000), 000000) as pre_11, ;
      IIf(ta.total_case_syr <> 0, IIF(ta.c_post_11 <> 0, Round((ta.c_post_11 * 100)/ta.total_case_syr, 0), 000000), 000000) as post_11, ;
      Nvl(tb.total_case_tst_12, 000000) as total_case_tst_12,;                          &&Page 3 Section B
      IIf(tb.total_case_tst_12 <> 0, IIf(tb.c_pre_b1 <> 0, Round((tb.c_pre_b1 * 100)/tb.total_case_tst_12, 0), 000000), 000000) as pre_b1, ;
      IIf(tb.total_case_tst_12 <> 0, IIf(tb.c_post_b1 <> 0, Round((tb.c_post_b1 * 100)/tb.total_case_tst_12, 0), 000000), 000000) as post_b1, ;
      Nvl(tb.total_case_gr, 000000) as total_case_gr,;    
      IIf(tb.total_case_gr <> 0, IIf(tb.c_pre_b2 <> 0, Round((tb.c_pre_b2 * 100)/tb.total_case_gr, 0), 000000), 000000) as pre_b2, ;
      IIf(tb.total_case_gr <> 0, IIf(tb.c_post_b2 <> 0, Round((tb.c_post_b2 * 100)/tb.total_case_gr, 0), 000000), 000000) as post_b2, ;
      Nvl(tb.total_case_rhc, 000000) as total_case_rhc,;    
      IIf(tb.total_case_rhc <> 0, IIf(tb.c_pre_b3 <> 0, Round((tb.c_pre_b3 * 100)/tb.total_case_rhc, 0), 000000), 000000) as pre_b3, ;
      IIf(tb.total_case_rhc <> 0, IIf(tb.c_post_b3 <> 0, Round((tb.c_post_b3 * 100)/tb.total_case_rhc, 0), 000000), 000000) as post_b3, ;
      Nvl(tb.total_case_pos, 000000) as total_case_pos,;
		IIf(tb.total_case_pos <> 0, Iif(tb.c_pre_b4 <> 0, Round((tb.c_pre_b4 * 100)/tb.total_case_pos, 0), 000000), 000000) as pre_b4, ;
		IIf(tb.total_case_pos <> 0, IIF(tb.c_post_b4 <> 0, Round((tb.c_post_b4 * 100)/tb.total_case_pos, 0), 000000), 000000) as post_b4 ;
From t_sum ts;
      Left Outer Join t_total tt on;    && Page 1
            ts.group_id = tt.group_id ;
        and ts.intervention_type =tt.intervention_type ; 
      Left Outer Join t_sect_a ta on;   && Page 2 Section A
            ts.group_id = ta.group_id ;
        and ts.intervention_type =ta.intervention_type ;     
      Left Outer Join t_sect_b tb on;   && Page 3 Section B
            ts.group_id = tb.group_id ;   
        and ts.intervention_type =tb.intervention_type ;   
into Cursor t_sum_surv ;
order by group_name, interv_descr

***VT 04/16/2010 Dev Tick 6664
*!*	Nvl(td.total_case_condom_use_oth, 000000) as total_case_condom_use_oth,;    
*!*	      IIf(td.total_case_condom_use_oth <> 0, IIf(td.c_pre_d2 <> 0, Round((td.c_pre_d2 * 100)/td.total_case_condom_use_oth, 0), 000000), 000000) as pre_d2, ;
*!*	      IIf(td.total_case_condom_use_oth <> 0, IIf(td.c_post_d2 <> 0, Round((td.c_post_d2 * 100)/td.total_case_condom_use_oth, 0), 000000), 000000) as post_d2, ;
*!*	      Nvl(td.total_case_condom_use_lo, 000000) as total_case_condom_use_lo,;    
*!*	      IIf(td.total_case_condom_use_lo <> 0, IIf(td.c_pre_d4 <> 0, Round((td.c_pre_d4 * 100)/td.total_case_condom_use_lo, 0), 000000), 000000) as pre_d4, ;
*!*	      IIf(td.total_case_condom_use_lo <> 0, IIf(td.c_post_d4 <> 0, Round((td.c_post_d4 * 100)/td.total_case_condom_use_lo, 0), 000000), 000000) as post_d4, ;
               
Select ts.*, ;
      Nvl(tc.total_case_com_beh, 000000) as total_case_com_beh,;     &&Page 3 Section C
      IIf(tc.total_case_com_beh <> 0, IIf(tc.c_pre_c1 <> 0, Round((tc.c_pre_c1 * 100)/tc.total_case_com_beh, 0), 000000), 000000) as pre_c1, ;
      IIf(tc.total_case_com_beh <> 0, IIf(tc.c_post_c1 <> 0, Round((tc.c_post_c1 * 100)/tc.total_case_com_beh, 0), 000000), 000000) as post_c1, ;
      Nvl(tc.total_case_com_tal, 000000) as total_case_com_tal,;    
      IIf(tc.total_case_com_tal <> 0, IIf(tc.c_pre_c2 <> 0, Round((tc.c_pre_c2 * 100)/tc.total_case_com_tal, 0), 000000), 000000) as pre_c2, ;
      IIf(tc.total_case_com_tal <> 0, IIf(tc.c_post_c2 <> 0, Round((tc.c_post_c2 * 100)/tc.total_case_com_tal, 0), 000000), 000000) as post_c2, ;
      Nvl(tc.total_case_scared, 000000) as total_case_scared,;    
      IIf(tc.total_case_scared <> 0, IIf(tc.c_pre_c3 <> 0, Round((tc.c_pre_c3 * 100)/tc.total_case_scared, 0), 000000), 000000) as pre_c3, ;
      IIf(tc.total_case_scared <> 0, IIf(tc.c_post_c3 <> 0, Round((tc.c_post_c3 * 100)/tc.total_case_scared, 0), 000000), 000000) as post_c3, ;
      Nvl(tc.total_case_cure, 000000) as total_case_cure,;    
      IIf(tc.total_case_cure <> 0, IIf(tc.c_pre_c4 <> 0, Round((tc.c_pre_c4 * 100)/tc.total_case_cure, 0), 000000), 000000) as pre_c4, ;
      IIf(tc.total_case_cure <> 0, IIf(tc.c_post_c4 <> 0, Round((tc.c_post_c4 * 100)/tc.total_case_cure, 0), 000000), 000000) as post_c4, ;
      Nvl(td.total_case_condom_use, 000000) as total_case_condom_use,;     &&Page 4 Section D
      IIf(td.total_case_condom_use <> 0, IIf(td.c_pre_d1 <> 0, Round((td.c_pre_d1 * 100)/td.total_case_condom_use, 0),000000), 000000) as pre_d1, ;
      IIf(td.total_case_condom_use <> 0, IIf(td.c_post_d1 <> 0, Round((td.c_post_d1 * 100)/td.total_case_condom_use, 0), 000000), 000000) as post_d1, ;
      Nvl(td.total_case_condom_use_l, 000000) as total_case_condom_use_l,;    
      IIf(td.total_case_condom_use_l <> 0, IIf(td.c_pre_d3 <> 0, Round((td.c_pre_d3 * 100)/td.total_case_condom_use_l, 0), 000000), 000000) as pre_d3, ;
      IIf(td.total_case_condom_use_l <> 0, IIf(td.c_post_d3 <> 0, Round((td.c_post_d3 * 100)/td.total_case_condom_use_l, 0), 000000), 000000) as post_d3, ;
      Crit as  Crit, ;   
      cDate as cDate, ;
      cTime as cTime, ;
      start_date as Date_from, ;
      end_date as date_to;
From t_sum_surv ts ;
      Left Outer Join t_sect_c tc on;   && Page 3 Section C
            ts.group_id = tc.group_id ;    
        and ts.intervention_type =tc.intervention_type ;   
      Left Outer Join t_sect_d td on;   && Page 4 Section D
            ts.group_id = td.group_id ;
        and ts.intervention_type =td.intervention_type ;           
into Cursor sum_surv ;
order by group_name, interv_descr

**Close tmp 
Use In t_total
Use In t_cl
Use In t_sect_a
Use In t_sect_b
Use In t_sect_c
Use In t_sect_d
Use In t_sum_surv

oApp.msg2user("OFF")
gcRptName = 'rpt_sum_survey' 

Select sum_surv
GO TOP

IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
  oApp.glcan_save_reports=.f.
  DO CASE
      CASE lPrev = .f.
            Report Form rpt_sum_survey  To Printer Prompt Noconsole NODIALOG 
      CASE lPrev = .t.     
            oApp.rpt_print(5, .t., 1, 'rpt_sum_survey', 1, 2)
   ENDCASE
   oApp.glcan_save_reports=.t.
   
EndIf