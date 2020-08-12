Parameters    lPrev, ;                && Preview     
              gnContractIDRpt, ;      && ai_contract.ai_contract_id
				  gc5yrConnoRpt,  ;       && ai_contract.conno
				  gnCotractIDTargRpt, ;   && contract_targets.oneyrcontract_target_id
				  gc1yrConnoRpt, ;   	  && contract_targets.oneyrconno
				  gcProjPrgRpt, ;         && sessions.prog_id 
				  gnModelIDRpt,  ;        && Sessions.Model_Id
				  gnIntervIDRpt           && Sesswions.Intervention_id




PRIVATE gchelp
gchelp = "Aggregate Prevention Intervention Attendance Report"
ccTitle = "Aggregate Prevention Intervention Attendance Report"

cDate = DATE()
cTime = TIME()
Start_date ={  /  /    }
End_date ={  /  /    }

**Model and Intervention Parameters
cWhere = ".T."
cWhere = cWhere + IIF(gnModelIDRpt = 0 , "", " and sess.model_id=gnModelIDRpt")               && Model
cWhere = cWhere + IIF(gnIntervIDRpt = 0, "", " and sess.intervention_id=gnIntervIDRpt")       && Intervention


**Find 1 year Contarct Date Range
Select startdate, ;
       enddate ;
From contract_targets ;
where oneyrcontract_target_id = gnCotractIDTargRpt ;
into cursor t_dates
	     
Start_date = t_dates.startdate
End_date = t_dates.enddate
	     
If Used('t_dates')
	 Use in t_dates
EndIf



**Pick up Contract #, Data Range, Active Groups Info	and Attend Clients     
Select  gc5yrConnoRpt as contr_numb, ;
			gnContractIDRpt as contract_id, ;
         DTOC(ct.startdate) + ' - ' + DTOC(ct.enddate) as contr_date, ;
         ct.startdate, ;
         ct.enddate, ;
         program.prog_id, ;
         program.descript as program_name, ;
         sess.model_id, ;
         model.modelname, ;
         sess.intervention_id, ;
         intv.name as intervname, ;
         grpatt.grp_id, ;
         group.descript as group_name, ;
         group.numplanses as plan_sess, ;
         group.numplancyc as plan_cycles, ;
         grpatt.session_number, ;
         grpatt.cycle_number, ;
         ai_enc.tc_id, ;
         .t. as is_attend, ;
         0000 as num_att, ;
         0000 as num_exp, ;
         0000 as perc_att, ;
         0000 as tot_sess_cl, ;
         0000 as tot_cl, ;
         0000 as tot_compl, ;
         0000 as tot_cl_serv, ;
         0000 as tot_cl_att, ;
         0000 as tot_cl_enr, ;
         0000 as tot_idg, ;
         0000 as tot_idi, ;
         Padr(Iif(gnModelIDRpt <> 0 and gnIntervIDRpt= 0, 'Model - ' + rtrim(model.modelname) , ;
          Iif(gnIntervIDRpt<> 0 and gnModelIDRpt = 0 , 'Intervention - ' + rtrim(intv.name), ;
          Iif(gnModelIDRpt <> 0 and gnIntervIDRpt<> 0, 'Model - ' + Rtrim(model.modelname) + ', Intervention - ' + Rtrim(intv.name),'All'))), 150) as Crit ;
From contract_targets ct ;
	  inner join  sessions sess on ;
	         ct.oneyrcontract_target_id = sess.oneyrcontract_target_id ;
	     and ct.oneyrcontract_target_id = gnCotractIDTargRpt ;
	     and sess.prog_id =  gcProjPrgRpt ;
	   inner join program on ;
	  			sess.prog_id = program.prog_id ;   
	   inner join model on ;
	   		model.model_id = sess.model_id ; 
		inner join intervention intv on ;
		      intv.intervention_id = sess.intervention_id ;
		inner join grpatt on ;
		      grpatt.contract_id= ct.contract_id ;
		  and grpatt.model_id = sess.model_id;
		  and grpatt.intervention_id = sess.intervention_id;
		  and Between(act_dt, ct.startdate, ct.enddate) ;
		inner join ai_enc on;
				ai_enc.att_id = grpatt.att_id ;
		inner join group on ;
		     group.grp_id = grpatt.grp_id ;
		 and group.program = gcProjPrgRpt ;
		 and (group.start_dt <= ct.enddate ;
		 		and ;
		 		(Empty(group.end_dt) or group.end_dt >= ct.startdate);
		 		) ;
Where &cWhere ;	  			     
Into cursor temp_info readwrite ;
Order by  group.descript, grpatt.grp_id,  model.modelname, sess.model_id, intv.name, sess.intervention_id
   		    

If _tally = 0
 	oApp.msg2user('NOTFOUNDG')
	Return
EndIf


**FIND NOT ATTEND Client
* Insert all of the people enrolled (active enrollment during contract date range) in the group who did not attend 
Insert Into temp_info (;
				     		  contr_numb,;
							  contract_id, ;
				           contr_date, ;
				           startdate, ;
				           enddate, ;
				           prog_id, ;
				           program_name, ;
				           model_id, ;
				           modelname, ;
				           intervention_id, ;
				           intervname, ;
				           grp_id, ;
				           group_name, ;
				           plan_sess, ;
				           plan_cycles, ;
				           session_number, ;
				           cycle_number,;
				           is_attend,;
				           tc_id,;
				           num_att, ;
		         		  num_exp, ;
		                 perc_att, ;
		                 tot_sess_cl, ;
		                 tot_cl, ;
		                 tot_compl, ;
		                 tot_cl_serv, ;
		                 tot_cl_att, ;
		                 tot_cl_enr, ;
		                 tot_idg, ;
		                 tot_idi, ;
							  Crit );
   Select ;
					    	  contr_numb, ;
							  contract_id, ;
				           contr_date, ;
				           startdate, ;
				           enddate, ;
				           prog_id, ;
				           program_name, ;
				           model_id, ;
				           modelname, ;
				           intervention_id, ;
				           intervname, ;
				           grp_id, ;
				           group_name, ;
				           plan_sess, ;
				           plan_cycles, ;
				           session_number, ;
				           cycle_number,;
				           .f.,;
				           ai_grp.tc_id,;
				           0000, ;
		         		  0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
		                 0000, ;
							  Crit;
   From temp_info ;
   Join ai_grp On  Alltrim(ai_grp.group)==alltrim(temp_info.grp_id) ;
   Where ;
   		ai_grp.start_dt <= temp_info.enddate ;
		 and (Empty(ai_grp.end_dt) or ai_grp.end_dt >= temp_info.startdate)  ;
	    and ai_grp.tc_id Not In ;
     							(Select tc_id From temp_info)


**Calculate Distinct Number of Clients enrolled (Expected Attendance)
Select Count(Distinct tc_id) as num_exp, ;
	   		  grp_id ;
from temp_info ;
into cursor t_exp ;
group by 2		

**Update Number of Clients enrolled (Expected Attendance)
Update temp_info ;
		set num_exp = te.num_exp ;
from temp_info ;
		inner join t_exp te on ;
				temp_info.grp_id =te.grp_id

If Used('t_exp')
	   Use in t_exp
EndIf

**Calculate Clients attending (Group, Model, Intervention, Cycle)
Select Count(Distinct tc_id) as num_att, ;
	   		  grp_id, ;
	   		  model_id, ;
	   		  intervention_id, ;
	   		  cycle_number, ;
	   		  session_number;
from temp_info ;
where is_attend =.t. ;
into cursor t_att ;
group by 2,3,4,5, 6

Update temp_info ;
		set num_att = ta.num_att, ;
		    perc_att =(ta.num_att/temp_info.num_exp)*100 ;
from temp_info ;
		inner join t_att ta on ;
				temp_info.grp_id = ta.grp_id ;
		  and temp_info.model_id =ta.model_id ;
	     and	temp_info.intervention_id = ta.intervention_id ;
	     and	temp_info.cycle_number = ta.cycle_number;	
	     and	temp_info.session_number = ta.session_number;	
	     
If Used('t_att')
	   Use in t_att
EndIf


**Total number of Clients completing ALL SESSIONS
**1. Calculate Total Number of Sessions for selected group/model/intervention/cycle,client (How many session per cycles for each client)
Select count( distinct session_number) as tot_sess_cl, ;
	   		  grp_id, ;
	   		  model_id, ;
	   		  intervention_id, ;
	   		  cycle_number,;
	   		  tc_id ;
from temp_info ;
where is_attend =.t. ;
into cursor t_ss ;
group by 2,3,4,5,6

Update temp_info ;
		set tot_sess_cl = ts.tot_sess_cl ;
from temp_info ;
		inner join t_ss ts on ;
				temp_info.grp_id = ts.grp_id ;
		  and temp_info.model_id =ts.model_id ;
	     and	temp_info.intervention_id = ts.intervention_id ;
	     and	temp_info.cycle_number = ts.cycle_number;	
        and	temp_info.tc_id = ts.tc_id;	
         
If Used('t_ss')
	   Use in t_ss
EndIf

*** 2. Total number of Clients completing ALL SESSIONS
Select Count(Distinct tc_id) as tot_cl, ;
	   		  grp_id, ;
	   		  model_id, ;
	   		  intervention_id, ;
	   		  cycle_number;
from temp_info ;
where is_attend =.t. ;
  and tot_sess_cl = plan_sess ;
into cursor t_cl ;
group by 2,3,4,5

Update temp_info ;
		 set tot_cl = tc.tot_cl, ;
		     tot_compl = (tc.tot_cl/temp_info.num_exp)*100 ;
from temp_info ;
		inner join t_cl tc on ;
				temp_info.grp_id = tc.grp_id ;
		  and temp_info.model_id =tc.model_id ;
	     and	temp_info.intervention_id = tc.intervention_id ;
	     and	temp_info.cycle_number = tc.cycle_number;	
	     
       
If Used('t_cl')
	   Use in t_cl
EndIf

**Calculate Number of clients enrolled in group who also received ILI services for selected group
**Working with ai_enc because services required
Select Count(Distinct temp_info.tc_id) as tot_cl_serv, ;
	   		  temp_info.grp_id ;
from ai_enc ;
	   	inner join temp_info  on;
	   	   ai_enc.tc_id=temp_info.tc_id ;
        and ai_enc.serv_cat ='00014' ;	   		
        and ai_enc.conno = temp_info.contr_numb ;
        and ai_enc.program = temp_info.prog_id ;
        and Between(ai_enc.act_dt, temp_info.startdate, temp_info.enddate) ;
into cursor tot_serv ;
group by 2

**Update Number of ILI Services	
Update temp_info ;
		set tot_cl_serv= ts.tot_cl_serv ;
from temp_info;
		inner join tot_serv ts on ;
				temp_info.grp_id = ts.grp_id ;
  			
If Used('tot_serv')
	   Use in tot_serv
EndIf

**Calculate Total number of unduplicated clients served during this time period 
Select Count(Distinct tc_id) as tot_cl_att, ;
	   		  grp_id, ;
	   		  model_id, ;
	   		  intervention_id ;
from temp_info ;
where is_attend =.t. ;
into cursor t_cl_s ;
group by 2,3,4

Update temp_info ;
		 set tot_cl_att = tc.tot_cl_att ;
from temp_info ;
		inner join t_cl_s tc on ;
				temp_info.grp_id = tc.grp_id ;
		  and temp_info.model_id =tc.model_id ;
	     and	temp_info.intervention_id = tc.intervention_id ;
     
       
If Used('t_cl_s')
	   Use in t_cl_s
EndIf

***Calculate Total Clients Enrolled in Program
Select Count(distinct temp_info.tc_id) as tot_cl_enr ;
from temp_info ;
		inner join ai_prog on ;
	   	  ai_prog.tc_id= temp_info.tc_id ;
	   and ai_prog.program = gcProjPrgRpt ;
	   and ai_prog.start_dt <= temp_info.enddate ;
	   and (Empty(ai_prog.end_dt) or ai_prog.end_dt >= temp_info.startdate) ;
into cursor t_cl_enr


		 
Update temp_info ;	
	Set tot_cl_enr = te.tot_cl_enr ;
from temp_info, t_cl_enr te 


If Used('t_cl_enr')
	   Use in t_cl_enr
EndIf

***IDGs delivered
**VT 07/02/2010 Dev Tick 6594 (07/02/2010 10:31AM by omar )
*!*	Select Count(Distinct ai_serv.serv_id) as tot_idg, ;
*!*		   		  temp_info.grp_id ;
*!*	from ai_enc ;
*!*		   	inner join temp_info  on;
*!*			   	   ai_enc.tc_id=temp_info.tc_id ;
*!*		        and ai_enc.serv_cat ='00013' ;	   		
*!*		        and ai_enc.conno = temp_info.contr_numb ;
*!*		        and ai_enc.program = temp_info.prog_id ;
*!*		        and Between(ai_enc.act_dt, temp_info.startdate, temp_info.enddate) ;
*!*	        inner join ai_serv on ;
*!*	               ai_enc.act_id = ai_serv.act_id ;
*!*	into cursor tot_idg ;
*!*	group by 2

Select Count(Distinct ai_enc.act_id) as tot_idg, ;
	   		  temp_info.grp_id ;
from ai_enc ;
	   	inner join temp_info  on;
		   	   ai_enc.tc_id=temp_info.tc_id ;
	        and ai_enc.serv_cat ='00013' ;	   		
	        and ai_enc.conno = temp_info.contr_numb ;
	        and ai_enc.program = temp_info.prog_id ;
	        and Between(ai_enc.act_dt, temp_info.startdate, temp_info.enddate) ;
into cursor tot_idg ;
group by 2

**Update Number of IDGs Encounters delivered
Update temp_info ;
		set tot_idg= ts.tot_idg ;
from temp_info;
		inner join tot_idg ts on ;
				temp_info.grp_id = ts.grp_id ;
  			
If Used('tot_idg')
	   Use in tot_idg
EndIf
 

***IDIs delivered
**VT 07/02/2010 Dev Tick 6594 (07/02/2010 10:31AM by omar )
*!*	Select Count(Distinct ai_serv.serv_id) as tot_idi, ;
*!*		   		  temp_info.grp_id ;
*!*	from ai_enc ;
*!*		   	inner join temp_info  on;
*!*			   	   ai_enc.tc_id=temp_info.tc_id ;
*!*		        and ai_enc.serv_cat ='00014' ;	   		
*!*		        and ai_enc.conno = temp_info.contr_numb ;
*!*		        and ai_enc.program = temp_info.prog_id ;
*!*		        and Between(ai_enc.act_dt, temp_info.startdate, temp_info.enddate) ;
*!*	        inner join ai_serv on ;
*!*	               ai_enc.act_id = ai_serv.act_id ;
*!*	into cursor tot_idi ;
*!*	group by 2

Select Count(Distinct ai_enc.act_id) as tot_idi, ;
	   		  temp_info.grp_id ;
from ai_enc ;
	   	inner join temp_info  on;
		   	   ai_enc.tc_id=temp_info.tc_id ;
	        and ai_enc.serv_cat ='00014' ;	   		
	        and ai_enc.conno = temp_info.contr_numb ;
	        and ai_enc.program = temp_info.prog_id ;
	        and Between(ai_enc.act_dt, temp_info.startdate, temp_info.enddate) ;
into cursor tot_idi ;
group by 2

**Update Number of IDIs Encounters	delivered
Update temp_info ;
		set tot_idi= ts.tot_idi ;
from temp_info;
		inner join tot_idi ts on ;
				temp_info.grp_id = ts.grp_id ;
  			
If Used('tot_idi')
	   Use in tot_idi
EndIf


If Used('agg_prev')
	   Use in agg_prev
EndIf
		  
Select Distinct ;
							  contr_numb,;
							  contract_id, ;
				           contr_date, ;
				           prog_id, ;
				           program_name, ;
				           model_id, ;
				           modelname, ;
				           intervention_id, ;
				           intervname, ;
				           grp_id, ;
				           group_name, ;
				           plan_sess, ;
				           plan_cycles, ;
				           session_number, ;
				           cycle_number,;
				           num_att, ;
		         		  num_exp, ;
		                 perc_att, ;
		                 tot_cl, ;
		                 tot_compl, ;
		                 tot_cl_serv, ;
		                 tot_cl_att, ;
		                 tot_cl_enr, ;
		                 tot_idg, ;
		                 tot_idi, ;
							  Crit, ;
						     cDate as cDate, ;
							  cTime as cTime ;
from temp_info ;
into cursor agg_prev ;
order by group_name, modelname, intervname, cycle_number, session_number

Go top
		 
If _tally = 0
 	oApp.msg2user('NOTFOUNDG')
	Return
EndIf
	 
**Print Report
oApp.msg2user('OFF')

gcRptName = 'rpt_aggr_prev'

Do Case
   Case lPrev = .f.
	        Report Form rpt_aggr_prev To Printer Prompt Noconsole NODIALOG 
   Case lPrev = .t.     &&Preview
	         oApp.rpt_print(5, .t., 1, 'rpt_aggr_prev', 1, 2)
EndCase

	  




