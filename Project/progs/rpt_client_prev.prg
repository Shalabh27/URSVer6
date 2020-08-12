Parameters    lPrev, ;                && Preview     
              gnContractIDRpt, ;      && ai_contract.ai_contract_id
				  gc5yrConnoRpt,  ;       && ai_contract.conno
				  gnCotractIDTargRpt, ;   && contract_targets.oneyrcontract_target_id
				  gc1yrConnoRpt, ;   	  && contract_targets.oneyrconno
				  gcProjPrgRpt, ;         && sessions.prog_id 
				  gcTc_idRpt,       ;        && Client Tc_id
				  gnModelIDRpt,  ;        && Sessions.Model_Id
				  gnIntervIDRpt           && Sesswions.Intervention_id


PRIVATE gchelp
gchelp = "Client Prevention Attendance Report"
ccTitle = "Client Prevention Attendance Report"

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


**Pick up Contract #, Data Range, Grops Info	     
**KEY  For rpt_order
** 1     Program Enrollment
** 2     Group Enrollment
** 3     Client Attendance
 
Select 	3 as rpt_order, ;
			gc5yrConnoRpt as contr_numb, ;
			gnContractIDRpt as contract_id, ;
         DTOC(ct.startdate) + ' - ' + DTOC(ct.enddate) as contr_date, ;
         ct.startdate, ;
         ct.enddate, ;
         gcTc_idRpt as tc_id,;
         PADR(oApp.FormatName(cli_cur.last_name, cli_cur.first_name),50) AS client_name, ;
         program.prog_id, ;
         program.descript as program_name, ;
         Space(21) as prg_start, ;
         Space(21) as prg_end, ;
         sess.model_id, ;
         model.modelname, ;
         sess.intervention_id, ;
         intv.name as intervname, ;
         grpatt.grp_id, ;
         group.descript as group_name, ;
         Space(21) as grp_start, ;
         Space(21) as grp_end, ;
         group.numplanses as plan_sess, ;
         group.numplancyc as plan_cycles, ;
         grpatt.att_id, ;
         grpatt.session_number, ;
         grpatt.cycle_number, ;
         grpatt.act_dt, ;
         0000 as total_sess, ;
         0000 as per_compl, ;
         0000 as total_serv, ;
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
		  and ai_enc.tc_id = gcTc_idRpt  ;		  
		inner join group on ;
		     group.grp_id = grpatt.grp_id ;
		 and group.program = gcProjPrgRpt ;
		inner join cli_cur on ;
			   ai_enc.tc_id = cli_cur.tc_id ;	 
Where &cWhere ;	  			     
Into cursor t_info ;
Order by  group.descript, grpatt.grp_id,  model.modelname, sess.model_id, intv.name, sess.intervention_id,  grpatt.cycle_number,grpatt.session_number 
         
        

If _tally = 0
 	oApp.msg2user('NOTFOUNDG')
	Return
EndIf

**Calculate Number of Individual Services for selected group/model/intervention
Select Count(*) as tot_serv, ;
	   		  t_info.grp_id, ;
	   		  t_info.model_id, ;
	   		  t_info.intervention_id ;
from ai_serv ;
	   	inner join t_info  on;
	   		ai_serv.att_id=t_info.att_id ;
	     and ai_serv.tc_id = gcTc_idRpt  ;	
into cursor tot_serv ;
group by 2,3,4 		

**Calculate Total Number of Sessions attended for cycle
Select Count(session_number) as tot_sess, ;
	   		  t_info.grp_id, ;
	   		  t_info.model_id, ;
	   		  t_info.intervention_id,;
	   		  t_info.cycle_number ;
from t_info ;
into cursor tot_sess ;
group by 2,3,4,5 		


**Create Distinct cursor	
If Used('t_prev')
	   Use in t_prev
EndIf
   
Select 	distinct ;
			   rpt_order, ;
				contr_numb, ;
				contract_id, ;
         	contr_date, ;
         	startdate, ;
        		enddate, ;
       		tc_id,;
         	client_name, ;
         	prog_id, ;
         	program_name, ;
         	prg_start, ;
         	prg_end, ;
         	model_id, ;
         	modelname, ;
         	intervention_id, ;
         	intervname, ;
         	grp_id, ;
         	group_name, ;
         	grp_start, ;
         	grp_end, ;
         	plan_sess, ;
        		plan_cycles, ;
         	cycle_number, ;
            total_sess, ;
            per_compl, ;
            total_serv,  ;
            Space(200) as date_attend,;
            Crit ;
From t_info ;
Into Cursor t_prev readwrite

**Update Total Number of sessions and Percent Completed
Update t_prev ;
		set total_sess = ts.tot_sess, ;
			  per_compl = (ts.tot_sess/plan_sess)*100 ;	
from t_prev ;
		inner join tot_sess ts on ;
				t_prev.grp_id = ts.grp_id ;
		  and t_prev.model_id = ts.model_id ;
		  and t_prev.intervention_id = ts.intervention_id ;
		  and t_prev.cycle_number = ts.cycle_number  			

If Used('tot_sess')
	   Use in tot_sess
EndIf

**Update Number of Individual Services	
Update t_prev ;
		set total_serv = ts.tot_serv ;
from t_prev ;
		inner join tot_serv ts on ;
				t_prev.grp_id = ts.grp_id ;
		  and t_prev.model_id = ts.model_id ;
		  and t_prev.intervention_id = ts.intervention_id 

If Used('tot_serv')
	   Use in tot_serv
EndIf


cGrpID = ''
nModID =0
nIntID = 0
nCycle = 0
cDt = ''


Select t_info
Scan
	
	If t_info.grp_id <> cGrpID or t_info.model_id <> nModID or ;
		t_info.intervention_id <> nIntID or t_info.cycle_number <> nCycle
	
			If !Empty(Rtrim(cGrpId))
		 	  		Update t_prev ;
			  			set date_attend = cDt ;
			  		from t_prev ;
			  		where grp_id = cGrpID ;
			  		  and model_id = nModID ;
			  		  and intervention_id = nIntID ;
			  		  and cycle_number = nCycle 
			  		  
			  		  cDt = ''
			EndIf
	EndIf
	   	cGrpID = t_info.grp_id
			nModID = t_info.model_id
			nIntID = t_info.intervention_id
			nCycle = t_info.cycle_number
			cDt = cDt + Iif(Empty(cDt), DTOC(t_info.act_dt), ', ' + DTOC(t_info.act_dt))
					
EndScan

**Update Last Record
Update t_prev ;
  			set date_attend = cDt ;
from t_prev ;
where grp_id = cGrpID ;
  and model_id = nModID ;
  and intervention_id = nIntID ;
  and cycle_number = nCycle 
			  		  
**Program Enrollment
Insert Into t_prev (rpt_order, ;
							client_name, ;
							contr_numb, ;
							contr_date, ;
							prg_start,;
							prg_end, ;
							program_name, ;
							Crit) 	;
Select distinct  ;
							1 as rpt_order,;
							t_prev.client_name, ;
							t_prev.contr_numb, ;
							t_prev.contr_date, ;
							Nvl(ai_prog.start_dt, {  /  /    }) as start_dt, ;
							Nvl(ai_prog.end_dt, {  /  /    }) as end_dt, ;
							t_prev.program_name, ;
							t_prev.Crit ;
from t_prev ;
		left outer join ai_prog on ;
	   	  ai_prog.tc_id= t_prev.tc_id ;
	   and ai_prog.program = gcProjPrgRpt ;
	   and ai_prog.start_dt <= t_prev.enddate ;
	   and (Empty(ai_prog.end_dt) or ai_prog.end_dt >= t_prev.startdate) 
		 

**Group Enrollment
Insert Into t_prev (rpt_order, ;
							client_name, ;
							contr_numb, ;
							contr_date, ;
							grp_start,;
							grp_end, ;
							group_name, ;
							Crit) 	;
Select distinct  ;
							2 as rpt_order,;
							t_prev.client_name, ;
							t_prev.contr_numb, ;
							t_prev.contr_date, ;
							ai_grp.start_dt, ;
							ai_grp.end_dt	, ;
							t_prev.group_name as group_name, ;
							t_prev.Crit ;
from t_prev ;
		inner join ai_grp on ;
		     ai_grp.group = t_prev.grp_id ;
		 and ai_grp.tc_id = t_prev.tc_id ;
		 and ai_grp.start_dt <= t_prev.enddate ;
		 and (Empty(ai_grp.end_dt) or ai_grp.end_dt >= t_prev.startdate)  ;
	   		 

If Used('t_info')
	   Use in t_info
EndIf

If Used('cli_prev')
	   Use in cli_prev
EndIf
		 
Select * , ;
      cDate as cDate, ;
		cTime as cTime ;
from t_prev ;
into cursor cli_prev ;
order by rpt_order, group_name, modelname, intervname

Go top
		 
If _tally = 0
 	oApp.msg2user('NOTFOUNDG')
	Return
EndIf
	 
**Print Report
oApp.msg2user('OFF')

gcRptName = 'rpt_client_prev'

Do Case
   Case lPrev = .f.
	        Report Form rpt_client_prev To Printer Prompt Noconsole NODIALOG 
   Case lPrev = .t.     &&Preview
	         oApp.rpt_print(5, .t., 1, 'rpt_client_prev', 1, 2)
EndCase

	  




