Parameters    lPrev, ;                && Preview     
              gnContractIDRpt, ;      && ai_contract.ai_contract_id
				  gc5yrConnoRpt,  ;       && ai_contract.conno
				  gnCotractIDTargRpt, ;   && contract_targets.oneyrcontract_target_id
				  gc1yrConnoRpt, ;   	  && contract_targets.oneyrconno
				  gcProjPrgRpt            && projections_program.prog_id 


PRIVATE gchelp
gchelp = "Contract/Program Target Report"
ccTitle = "Contract/Program Target Report"

cDate = DATE()
cTime = TIME()
Start_date ={  /  /    }
End_date ={  /  /    }

**Program Parameter
cWhere = ".T."
cWhere = cWhere + IIF(EMPTY(gcProjPrgRpt)   ,""," and pr.prog_id=gcProjPrgRpt")

**Find 1 year Contarct Date Range
Select startdate, ;
       enddate ;
From contract_targets ;
where oneyrcontract_target_id = gnCotractIDTargRpt ;
into cursor t_dt
	     
Start_date = t_dt.startdate
End_date = t_dt.enddate
	     
If Used('t_dt')
	 Use in t_dt
EndIf


**Pick up Contract #, Data Range	     
If Used('cont_targ')
	   Use in cont_targ
EndIf

Select 	gc5yrConnoRpt as contr_numb, ;
			gnContractIDRpt as contract_id, ;
         DTOC(ct.startdate) + ' - ' + DTOC(ct.enddate) as contr_date, ;
         ct.startdate, ;
         ct.enddate, ;
         initiative.initiativename, ;
         program.prog_id, ;
         program.descript as program_name, ;
         ct.clients as cont_client_target, ;
         000000 as cont_client_served, ;
         pp.prog_num as prg_client_target, ;
         000000 as prg_client_served, ;
         pr.serv_cat, ;
         serv_cat.descript as serv_cat_name, ;
         pr.serv_clients, ;
         pr.serv_enc, ;
         000000 as serv_client_served, ;
         000000 as serv_enc_deliv, ;
         Iif(!Empty(gcProjPrgRpt), 'Program - ' + program.descript , 'All') as Crit, ;
         cDate as cDate, ;
			cTime as cTime ;
From contract_targets ct ;
	  inner join initiative on;
	         ct.initiative_id = initiative.initiative_id ;
	     and ct.oneyrcontract_target_id = gnCotractIDTargRpt ;
	  inner join  projections pr on ;
	         ct.oneyrcontract_target_id = pr.oneyrcontract_target_id ;
	  inner join projections_program pp on ;
	  			pp.oneyrcontract_target_id = pr.oneyrcontract_target_id ;
	  	  and pp.prog_id = pr.prog_id ;	        
	  inner join program on ;
	  			pr.prog_id = program.prog_id ;  
	  inner join serv_cat on ;
	  			pr.serv_cat = serv_cat.code ;		
	  	and 	serv_cat.use4outr =.f. ;		
Where &cWhere ;	  			     
Into cursor cont_targ readwrite	 ;
Order by  program.descript, serv_cat.descript 

If _tally = 0
 	oApp.msg2user('NOTFOUNDG')
	Return
EndIf
	 
**Parameter Program For ai_enc
cWherePrg = ".T."
cWherePrg = cWherePrg + IIF(EMPTY(gcProjPrgRpt)   ,""," and ai_enc.program=gcProjPrgRpt")

**Calculate Contract->Clients Served based on 5 years contract_id and 1 year date range 
Select 	contract_id ,;
			COUNT(DIST tc_id) AS cont_cl_serv ;
From     ai_enc ;
Where Between(act_dt,Start_date, End_date) ;
  and contract_id = gnContractIDRpt ;
  and &cWherePrg ;	 
Into Cursor conttot ;
Group By 1

Update cont_targ ;
	set cont_client_served = ct.cont_cl_serv ;
From	cont_targ ;
		inner join conttot ct on ;
			cont_targ.contract_id = ct.contract_id

If Used('conttot')
	   Use in conttot
EndIf

**Calculate Program Clients Served
Select 	program as prog_id ,;
			COUNT(DIST tc_id) AS prg_cl_serv ;
From     ai_enc ;
Where Between(act_dt,Start_date, End_date) ;
  and contract_id = gnContractIDRpt ;
  and &cWherePrg ;
Into Cursor prgtot ;
Group By 1

Update cont_targ ;
	set prg_client_served = pt.prg_cl_serv ;
From	cont_targ ;
		inner join prgtot pt on ;
			cont_targ.prog_id = pt.prog_id

If Used('prgtot')
	   Use in prgtot
EndIf

**Number of Clients Served (unduplicated)
Select 	program as prog_id ,;
			serv_cat, ;
			COUNT(DIST tc_id) AS sc_cl_serv ;
From     ai_enc ;
Where Between(act_dt,Start_date, End_date) ;
  and contract_id = gnContractIDRpt ;
  and &cWherePrg ;
Into Cursor scltot ;
Group By 1, 2

Update cont_targ ;
	set serv_client_served = st.sc_cl_serv ;
From	cont_targ ;
		inner join scltot st on ;
			 cont_targ.prog_id = st.prog_id ;
		and cont_targ.serv_cat = st.serv_cat
		
If Used('scltot')
	   Use in scltot
EndIf


**Number of Encounters Delivered -is a count of the AI_ENC records. If 12 clients showed up for a Group Activity encounter,
** the "Total Number of Encounters Delivered" equals 12
Select 	program as prog_id ,;
			serv_cat, ;
			COUNT(enc_id) AS sc_enc_del ;
From     ai_enc ;
Where Between(act_dt,Start_date, End_date) ;
  and contract_id = gnContractIDRpt ;
  and &cWherePrg ;
Into Cursor senctot ;
Group By 1, 2

Update cont_targ ;
	set serv_enc_deliv = st.sc_enc_del ;
From	cont_targ ;
		inner join senctot st on ;
			 cont_targ.prog_id = st.prog_id ;
		and cont_targ.serv_cat = st.serv_cat
		
If Used('senctot')
	   Use in senctot
EndIf

**Print Report
oApp.msg2user('OFF')
Select cont_targ
Go top
gcRptName = 'rpt_contprg_target'
Do Case
   Case lPrev = .f.
	        Report Form rpt_contprg_target To Printer Prompt Noconsole NODIALOG 
   Case lPrev = .t.     &&Preview
	         oApp.rpt_print(5, .t., 1, 'rpt_contprg_target', 1, 2)
EndCase

	  




