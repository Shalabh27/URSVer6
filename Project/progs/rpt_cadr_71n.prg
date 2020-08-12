****CADR Report Section 6, part6.2 (Q71-73) (replacing 2004 Q's 65,67,68; Q66[Hispanic ethnicity] was removed in 2005)
*---Q71
*!*   	m.group   = ""
*!*   	Insert Into cadr_tmp From Memvar
*!*       *** For transfer to  next page
*!*   	m.group   = " " + CHR(13) + " " + CHR(13) +" " + CHR(13) +" " + CHR(13)
   m.info = 71   
   m.page_ej=6

*   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
* jss, replace title iii and iv with part c and d:   m.part  = "Part 6.2. Title IV Information"
   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/PART-SPECIFIC DATA FOR PARTS C AND D"
   m.part  = "Part 6.2. Part D Information"
	m.group = "71.  Number of clients during this reporting period by gender, HIV status, and age"
	Insert Into cadr_tmp From Memvar

If Used('all_t4a')
   Use In all_t4a
Endif
   
	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother, hivstatus, hiv_pos, .f. as hiv_indet ;
	From all_hiv ;
	Where 	(fund_type = "04" or fund_type = '14') and ;
		  	(hivstatus <> "03" AND  hivstatus <> "11") ;
	Into Cursor all_t4a
	
	oApp.ReopenCur("all_t4a","all_t4")
   
	Select all_t4
	Set Relation to tc_id into t_indet
	Go Top
	Scan
		Replace hiv_indet With IIF(EOF("t_indet"),.f., .t.)
	Endscan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('³',1) + "    Gender      " + REPL('³',1) + " HIV status " + REPL('³',1) + ;
				"  Under " + REPL('³',1) + "  2-12  " + REPL('³',1) + "  13-24 " + REPL('³',1) + ;
				"  25-44 " + REPL('³',1) + "  45-64 " + REPL('³',1) + "65 years" + REPL('³',1) + ;
				"   Age  " + REPL('³',1) + "  Total "	+ REPL('³',1)
	Insert Into cadr_tmp From Memvar 

	m.group = REPL('³',1) + Space(16) + REPL('³',1) + Space(12) + REPL('³',1) + ;
				" 2 years" + REPL('³',1) + "  years " + REPL('³',1) + "  years " + REPL('³',1) + ;
				"  years " + REPL('³',1) + "  years " + REPL('³',1) + "& older " + REPL('³',1) + ;
				" Unknown" + REPL('³',1) + "        " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
			
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

***Female
If Used('t_stf')
   Use In t_stf
Endif
   
   Select ; 
		Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
	   Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
	   Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
		Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
		Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
	From all_t4 ;
	Where 	gender = "10";
	Into Cursor t_stf
	
		m.group =   " Female         " + Space(2) + "HIV+ /Indet." + ;
		 			Space(3) + Iif(Isnull(t_stf.tot_st1), Space(5)+'0', Str(t_stf.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stf.tot_st3), Space(5)+'0', Str(t_stf.tot_st3, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stf.tot_st5), Space(5)+'0', Str(t_stf.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stf.tot_st7), Space(5)+'0', Str(t_stf.tot_st7, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stf.tot_st9), Space(5)+'0', Str(t_stf.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stf.tot_st11), Space(5)+'0', Str(t_stf.tot_st11, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stf.tot_st13), Space(5)+'0', Str(t_stf.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stf.totalp), Space(5)+'0', Str(t_stf.totalp, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
				
		m.group =   Space(18) + "HIV-/Unknown" + ;
							Space(3) + Iif(Isnull(t_stf.tot_st2), Space(5)+'0', Str(t_stf.tot_st2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stf.tot_st4), Space(5)+'0', Str(t_stf.tot_st4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stf.tot_st6), Space(5)+'0', Str(t_stf.tot_st6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stf.tot_st8), Space(5)+'0', Str(t_stf.tot_st8, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stf.tot_st10), Space(5)+'0', Str(t_stf.tot_st10, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stf.tot_st12), Space(5)+'0', Str(t_stf.tot_st12, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stf.tot_st14), Space(5)+'0', Str(t_stf.tot_st14, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stf.totaln), Space(5)+'0', Str(t_stf.totaln, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.gfempos=			Iif(Isnull(t_stf.tot_st1), Space(5)+'0', Str(t_stf.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.tot_st3), Space(5)+'0', Str(t_stf.tot_st3, 6, 0)) + ;
					',' + Iif(Isnull(t_stf.tot_st5), Space(5)+'0', Str(t_stf.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.tot_st7), Space(5)+'0', Str(t_stf.tot_st7, 6, 0)) + ;
					',' + Iif(Isnull(t_stf.tot_st9), Space(5)+'0', Str(t_stf.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.tot_st11), Space(5)+'0', Str(t_stf.tot_st11, 6, 0)) + ;
					',' + Iif(Isnull(t_stf.tot_st13), Space(5)+'0', Str(t_stf.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.totalp), Space(5)+'0', Str(t_stf.totalp, 6, 0))
               
	m.gfemneg=			Iif(Isnull(t_stf.tot_st2), Space(5)+'0', Str(t_stf.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.tot_st4), Space(5)+'0', Str(t_stf.tot_st4, 6, 0)) + ;
					',' + Iif(Isnull(t_stf.tot_st6), Space(5)+'0', Str(t_stf.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.tot_st8), Space(5)+'0', Str(t_stf.tot_st8, 6, 0)) + ;
					',' + Iif(Isnull(t_stf.tot_st10), Space(5)+'0', Str(t_stf.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.tot_st12), Space(5)+'0', Str(t_stf.tot_st12, 6, 0)) + ;
					',' + Iif(Isnull(t_stf.tot_st14), Space(5)+'0', Str(t_stf.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stf.totaln), Space(5)+'0', Str(t_stf.totaln, 6, 0))
	
Use in t_stf	

***Male
If Used('t_stm')
   Use In t_stm
Endif
   
	Select ; 
		Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
	   Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
	   Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
		Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
		Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
	From all_t4 ;
	Where gender = "11" ;
	Into Cursor t_stm
	
		m.group =   " Male           " + Space(2) + "HIV+ /Indet." + ;
		 			Space(3) + Iif(Isnull(t_stm.tot_st1), Space(5)+'0', Str(t_stm.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st3), Space(5)+'0', Str(t_stm.tot_st3, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stm.tot_st5), Space(5)+'0', Str(t_stm.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st7), Space(5)+'0', Str(t_stm.tot_st7, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stm.tot_st9), Space(5)+'0', Str(t_stm.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st11), Space(5)+'0', Str(t_stm.tot_st11, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stm.tot_st13), Space(5)+'0', Str(t_stm.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.totalp), Space(5)+'0', Str(t_stm.totalp, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
				
		m.group =   Space(18) + "HIV-/Unknown" + ;
							Space(3) + Iif(Isnull(t_stm.tot_st2), Space(5)+'0', Str(t_stm.tot_st2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stm.tot_st4), Space(5)+'0', Str(t_stm.tot_st4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stm.tot_st6), Space(5)+'0', Str(t_stm.tot_st6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stm.tot_st8), Space(5)+'0', Str(t_stm.tot_st8, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stm.tot_st10), Space(5)+'0', Str(t_stm.tot_st10, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stm.tot_st12), Space(5)+'0', Str(t_stm.tot_st12, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stm.tot_st14), Space(5)+'0', Str(t_stm.tot_st14, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stm.totaln), Space(5)+'0', Str(t_stm.totaln, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.gmalepos=			Iif(Isnull(t_stm.tot_st1), Space(5)+'0', Str(t_stm.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st3), Space(5)+'0', Str(t_stm.tot_st3, 6, 0)) + ;
					',' + Iif(Isnull(t_stm.tot_st5), Space(5)+'0', Str(t_stm.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st7), Space(5)+'0', Str(t_stm.tot_st7, 6, 0)) + ;
					',' + Iif(Isnull(t_stm.tot_st9), Space(5)+'0', Str(t_stm.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st11), Space(5)+'0', Str(t_stm.tot_st11, 6, 0)) + ;
					',' + Iif(Isnull(t_stm.tot_st13), Space(5)+'0', Str(t_stm.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.totalp), Space(5)+'0', Str(t_stm.totalp, 6, 0))
               
	m.gmaleneg=			Iif(Isnull(t_stm.tot_st2), Space(5)+'0', Str(t_stm.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st4), Space(5)+'0', Str(t_stm.tot_st4, 6, 0)) + ;
					',' + Iif(Isnull(t_stm.tot_st6), Space(5)+'0', Str(t_stm.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st8), Space(5)+'0', Str(t_stm.tot_st8, 6, 0)) + ;
					',' + Iif(Isnull(t_stm.tot_st10), Space(5)+'0', Str(t_stm.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st12), Space(5)+'0', Str(t_stm.tot_st12, 6, 0)) + ;
					',' + Iif(Isnull(t_stm.tot_st14), Space(5)+'0', Str(t_stm.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.totaln), Space(5)+'0', Str(t_stm.totaln, 6, 0))
	
Use in t_stm	

***Transgender
If Used('t_stt')
   Use In t_stt
Endif
   
	Select ; 
		Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
	   Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
	   Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
		Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
		Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
	From all_t4 ;
	Where gender = "12" or gender = "13";
	Into Cursor t_stt
	
		m.group =   " Transgender    " + Space(2) + "HIV+ /Indet." + ;
		 			Space(3) + Iif(Isnull(t_stt.tot_st1), Space(5)+'0', Str(t_stt.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st3), Space(5)+'0', Str(t_stt.tot_st3, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stt.tot_st5), Space(5)+'0', Str(t_stt.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st7), Space(5)+'0', Str(t_stt.tot_st7, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stt.tot_st9), Space(5)+'0', Str(t_stt.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st11), Space(5)+'0', Str(t_stt.tot_st11, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stt.tot_st13), Space(5)+'0', Str(t_stt.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.totalp), Space(5)+'0', Str(t_stt.totalp, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
				
		m.group =   Space(18) + "HIV-/Unknown" + ;
							Space(3) + Iif(Isnull(t_stt.tot_st2), Space(5)+'0', Str(t_stt.tot_st2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.tot_st4), Space(5)+'0', Str(t_stt.tot_st4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stt.tot_st6), Space(5)+'0', Str(t_stt.tot_st6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.tot_st8), Space(5)+'0', Str(t_stt.tot_st8, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stt.tot_st10), Space(5)+'0', Str(t_stt.tot_st10, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.tot_st12), Space(5)+'0', Str(t_stt.tot_st12, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stt.tot_st14), Space(5)+'0', Str(t_stt.tot_st14, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.totaln), Space(5)+'0', Str(t_stt.totaln, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.gtrnpos=			Iif(Isnull(t_stt.tot_st1), Space(5)+'0', Str(t_stt.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st3), Space(5)+'0', Str(t_stt.tot_st3, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st5), Space(5)+'0', Str(t_stt.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st7), Space(5)+'0', Str(t_stt.tot_st7, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st9), Space(5)+'0', Str(t_stt.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st11), Space(5)+'0', Str(t_stt.tot_st11, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st13), Space(5)+'0', Str(t_stt.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totalp), Space(5)+'0', Str(t_stt.totalp, 6, 0))
               
	m.gtrnneg=			Iif(Isnull(t_stt.tot_st2), Space(5)+'0', Str(t_stt.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st4), Space(5)+'0', Str(t_stt.tot_st4, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st6), Space(5)+'0', Str(t_stt.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st8), Space(5)+'0', Str(t_stt.tot_st8, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st10), Space(5)+'0', Str(t_stt.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st12), Space(5)+'0', Str(t_stt.tot_st12, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st14), Space(5)+'0', Str(t_stt.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totaln), Space(5)+'0', Str(t_stt.totaln, 6, 0))
	
Use in t_stt	

***Unknown/Unreported
If Used('t_stu')
   Use In t_stu
Endif
   
	Select ; 
		Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
	   Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
	   Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
		Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
		Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
	From all_t4 ;
	Where Empty(gender);
	Into Cursor t_stu
	
		m.group =   " Unknown/       " + Space(2) + "HIV+ /Indet." + ;
		 			Space(3) + Iif(Isnull(t_stu.tot_st1), Space(5)+'0', Str(t_stu.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st3), Space(5)+'0', Str(t_stu.tot_st3, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stu.tot_st5), Space(5)+'0', Str(t_stu.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st7), Space(5)+'0', Str(t_stu.tot_st7, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stu.tot_st9), Space(5)+'0', Str(t_stu.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st11), Space(5)+'0', Str(t_stu.tot_st11, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stu.tot_st13), Space(5)+'0', Str(t_stu.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.totalp), Space(5)+'0', Str(t_stu.totalp, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
				
		m.group =   " Unreported     " + Space(2) + "HIV-/Unknown" + ;
					Space(3) + Iif(Isnull(t_stu.tot_st2), Space(5)+'0', Str(t_stu.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st4), Space(5)+'0', Str(t_stu.tot_st4, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stu.tot_st6), Space(5)+'0', Str(t_stu.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st8), Space(5)+'0', Str(t_stu.tot_st8, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stu.tot_st10), Space(5)+'0', Str(t_stu.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st12), Space(5)+'0', Str(t_stu.tot_st12, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stu.tot_st14), Space(5)+'0', Str(t_stu.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.totaln), Space(5)+'0', Str(t_stu.totaln, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.gunkpos=			Iif(Isnull(t_stu.tot_st1), Space(5)+'0', Str(t_stu.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st3), Space(5)+'0', Str(t_stu.tot_st3, 6, 0)) + ;
					',' + Iif(Isnull(t_stu.tot_st5), Space(5)+'0', Str(t_stu.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st7), Space(5)+'0', Str(t_stu.tot_st7, 6, 0)) + ;
					',' + Iif(Isnull(t_stu.tot_st9), Space(5)+'0', Str(t_stu.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st11), Space(5)+'0', Str(t_stu.tot_st11, 6, 0)) + ;
					',' + Iif(Isnull(t_stu.tot_st13), Space(5)+'0', Str(t_stu.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.totalp), Space(5)+'0', Str(t_stu.totalp, 6, 0))
               
	m.gunkneg=			Iif(Isnull(t_stu.tot_st2), Space(5)+'0', Str(t_stu.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st4), Space(5)+'0', Str(t_stu.tot_st4, 6, 0)) + ;
					',' + Iif(Isnull(t_stu.tot_st6), Space(5)+'0', Str(t_stu.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st8), Space(5)+'0', Str(t_stu.tot_st8, 6, 0)) + ;
					',' + Iif(Isnull(t_stu.tot_st10), Space(5)+'0', Str(t_stu.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st12), Space(5)+'0', Str(t_stu.tot_st12, 6, 0)) + ;
					',' + Iif(Isnull(t_stu.tot_st14), Space(5)+'0', Str(t_stu.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.totaln), Space(5)+'0', Str(t_stu.totaln, 6, 0))
	
Use in t_stu	

***Total
If Used('t_stt')
   Use In t_stt
Endif
   
	Select ; 
		Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
	   Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
	   Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
		Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
		Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
		Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
		Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
	From all_t4 ;
	Into Cursor t_stt
	
		m.group =   " Total          " + Space(2) + "HIV+ /Indet." + ;
		 			Space(3) + Iif(Isnull(t_stt.tot_st1), Space(5)+'0', Str(t_stt.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st3), Space(5)+'0', Str(t_stt.tot_st3, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stt.tot_st5), Space(5)+'0', Str(t_stt.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st7), Space(5)+'0', Str(t_stt.tot_st7, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stt.tot_st9), Space(5)+'0', Str(t_stt.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st11), Space(5)+'0', Str(t_stt.tot_st11, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_stt.tot_st13), Space(5)+'0', Str(t_stt.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.totalp), Space(5)+'0', Str(t_stt.totalp, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
				
		m.group =   Space(18) + "HIV-/Unknown" + ;
							Space(3) + Iif(Isnull(t_stt.tot_st2), Space(5)+'0', Str(t_stt.tot_st2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.tot_st4), Space(5)+'0', Str(t_stt.tot_st4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stt.tot_st6), Space(5)+'0', Str(t_stt.tot_st6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.tot_st8), Space(5)+'0', Str(t_stt.tot_st8, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stt.tot_st10), Space(5)+'0', Str(t_stt.tot_st10, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.tot_st12), Space(5)+'0', Str(t_stt.tot_st12, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_stt.tot_st14), Space(5)+'0', Str(t_stt.tot_st14, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_stt.totaln), Space(5)+'0', Str(t_stt.totaln, 6, 0)) 
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
	m.gtpos=				Iif(Isnull(t_stt.tot_st1), Space(5)+'0', Str(t_stt.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st3), Space(5)+'0', Str(t_stt.tot_st3, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st5), Space(5)+'0', Str(t_stt.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st7), Space(5)+'0', Str(t_stt.tot_st7, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st9), Space(5)+'0', Str(t_stt.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st11), Space(5)+'0', Str(t_stt.tot_st11, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st13), Space(5)+'0', Str(t_stt.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totalp), Space(5)+'0', Str(t_stt.totalp, 6, 0))
               
	m.gtneg=				Iif(Isnull(t_stt.tot_st2), Space(5)+'0', Str(t_stt.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st4), Space(5)+'0', Str(t_stt.tot_st4, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st6), Space(5)+'0', Str(t_stt.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st8), Space(5)+'0', Str(t_stt.tot_st8, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st10), Space(5)+'0', Str(t_stt.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st12), Space(5)+'0', Str(t_stt.tot_st12, 6, 0)) + ;
					',' + Iif(Isnull(t_stt.tot_st14), Space(5)+'0', Str(t_stt.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totaln), Space(5)+'0', Str(t_stt.totaln, 6, 0))
	
Use in t_stt	


*!*      m.group   = " " + CHR(13) + " " + CHR(13) + " "  + CHR(13) + " "  + CHR(13)+ " " + CHR(13) + " " + CHR(13) + ;
*!*      				" " + CHR(13) + " " + CHR(13) + " "  + CHR(13) + " "  + CHR(13)+ " " + CHR(13) + " " + CHR(13) + ;
*!*      				" " + CHR(13) + " " + CHR(13) + " "  + CHR(13) + " "  + CHR(13)+ " " + CHR(13) + " " + CHR(13) + ;
*!*      				" " + CHR(13) + " " + CHR(13) + " "  + CHR(13) + " "  + CHR(13)+ " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " "  + CHR(13) + " "  + CHR(13)+ " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13)   
* jss, 11/29/07, add m.page_ej

   m.info = 72
   m.page_ej=7
	
*---Q72
	
* m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
* jss, 11/22/07: replace title iii and iv with part c and d:   m.part  = "Part 6.2. Title IV Information"
   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/PART-SPECIFIC DATA FOR PARTS C AND D"
   m.part  = "Part 6.2. Part D Information"
	m.group = "72.  Number of clients during this reporting period by race, HIV status, and age"+Chr(13)+;
             "a.   Number of HISPANIC clients'" 
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

	m.group = REPL('³',1) + "       Race     " + REPL('³',1) + " HIV status " + REPL('³',1) + ;
				"  Under " + REPL('³',1) + "  2-12  " + REPL('³',1) + "  13-24 " + REPL('³',1) + ;
				"  25-44 " + REPL('³',1) + "  45-64 " + REPL('³',1) + "65 years" + REPL('³',1) + ;
				"   Age  " + REPL('³',1) + "  Total "	+ REPL('³',1)
	Insert Into cadr_tmp From Memvar 

	m.group = REPL('³',1) + Space(16) + REPL('³',1) + Space(12) + REPL('³',1) + ;
				" 2 years" + REPL('³',1) + "  years " + REPL('³',1) + "  years " + REPL('³',1) + ;
				"  years " + REPL('³',1) + "  years " + REPL('³',1) + "& older " + REPL('³',1) + ;
				" Unknown" + REPL('³',1) + "        " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
			
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* For 2008 RDR we have sections a & b.  Section a is HISPANIC; b NON-HISPANIC
* Section 72a HISPANIC
*** American indian
If Used('t_sta')
   Use In t_sta
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where indialaska = 1 and hispanic = 2 and ;
      (blafrican + asian + white + ;
      hawaisland + someother) = 0 ;
   Into Cursor t_sta
   
      m.group =   " American Indian" + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   " /Alaskan Native" + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
   m.HINPOS=         Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0))
   m.HINNEG=            Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
   
Use in t_sta

*** Asian
If Used('t_sta')
   Use In t_sta
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where asian = 1 and hispanic = 2 and ;
      (white + blafrican + hawaisland + ;
      indialaska + someother) = 0  ;
   Into Cursor t_sta
   
      m.group =   " Asian          " + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   m.HASPOS=         Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0)) 
               
   m.HASNEG=         Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
   
Use in t_sta

** Black or African
If Used('t_stb')
   Use In t_stb
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where blafrican = 1 and hispanic = 2 and ;
      (white + asian + hawaisland + ;
       indialaska + someother) = 0 ;
   Into Cursor t_stb
   
      m.group =   " Black or Afric." + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_stb.tot_st1), Space(5) + '0', Str(t_stb.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st3), Space(5) + '0', Str(t_stb.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st5), Space(5) + '0', Str(t_stb.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st7), Space(5) + '0', Str(t_stb.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st9), Space(5) + '0', Str(t_stb.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st11), Space(5) + '0', Str(t_stb.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st13), Space(5) + '0', Str(t_stb.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.totalp), Space(5) + '0', Str(t_stb.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   " American       " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stb.tot_st2), Space(5) + '0', Str(t_stb.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st4), Space(5) + '0', Str(t_stb.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st6), Space(5) + '0', Str(t_stb.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st8), Space(5) + '0', Str(t_stb.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st10), Space(5) + '0', Str(t_stb.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st12), Space(5) + '0', Str(t_stb.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st14), Space(5) + '0', Str(t_stb.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.totaln), Space(5) + '0', Str(t_stb.totaln, 6, 0)) 
 
               
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
   m.HBLPOS=         Iif(Isnull(t_stb.tot_st1), Space(5) + '0', Str(t_stb.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st3), Space(5) + '0', Str(t_stb.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st5), Space(5) + '0', Str(t_stb.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st7), Space(5) + '0', Str(t_stb.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st9), Space(5) + '0', Str(t_stb.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st11), Space(5) + '0', Str(t_stb.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st13), Space(5) + '0', Str(t_stb.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.totalp), Space(5) + '0', Str(t_stb.totalp, 6, 0))
               
   m.HBLNEG=         Iif(Isnull(t_stb.tot_st2), Space(5) + '0', Str(t_stb.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st4), Space(5) + '0', Str(t_stb.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st6), Space(5) + '0', Str(t_stb.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st8), Space(5) + '0', Str(t_stb.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st10), Space(5) + '0', Str(t_stb.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st12), Space(5) + '0', Str(t_stb.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st14), Space(5) + '0', Str(t_stb.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.totaln), Space(5) + '0', Str(t_stb.totaln, 6, 0))
   
Use in t_stb

** Native Hawaiian
If Used('t_stn')
   Use In t_stn
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where hawaisland = 1 and hispanic = 2 and ;
      (blafrican + asian + white + ;
       indialaska + someother) = 0 ;
   Into Cursor t_stn
   
      m.group =   " Native Hawaiian" + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_stn.tot_st1), Space(5) + '0', Str(t_stn.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st3), Space(5) + '0', Str(t_stn.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st5), Space(5) + '0', Str(t_stn.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st7), Space(5) + '0', Str(t_stn.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st9), Space(5) + '0', Str(t_stn.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st11), Space(5) + '0', Str(t_stn.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st13), Space(5) + '0', Str(t_stn.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.totalp), Space(5) + '0', Str(t_stn.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   "  /Pacific Isl. " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stn.tot_st2), Space(5) + '0', Str(t_stn.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st4), Space(5) + '0', Str(t_stn.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st6), Space(5) + '0', Str(t_stn.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st8), Space(5) + '0', Str(t_stn.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st10), Space(5) + '0', Str(t_stn.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st12), Space(5) + '0', Str(t_stn.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st14), Space(5) + '0', Str(t_stn.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.totaln), Space(5) + '0', Str(t_stn.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
   m.HNAPOS=         Iif(Isnull(t_stn.tot_st1), Space(5) + '0', Str(t_stn.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st3), Space(5) + '0', Str(t_stn.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st5), Space(5) + '0', Str(t_stn.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st7), Space(5) + '0', Str(t_stn.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st9), Space(5) + '0', Str(t_stn.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st11), Space(5) + '0', Str(t_stn.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st13), Space(5) + '0', Str(t_stn.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.totalp), Space(5) + '0', Str(t_stn.totalp, 6, 0)) 
               
   m.HNANEG=         Iif(Isnull(t_stn.tot_st2), Space(5) + '0', Str(t_stn.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st4), Space(5) + '0', Str(t_stn.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st6), Space(5) + '0', Str(t_stn.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st8), Space(5) + '0', Str(t_stn.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st10), Space(5) + '0', Str(t_stn.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st12), Space(5) + '0', Str(t_stn.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st14), Space(5) + '0', Str(t_stn.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.totaln), Space(5) + '0', Str(t_stn.totaln, 6, 0)) 
   
Use in t_stn

** White
If Used('t_stw')
   Use In t_stw
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where white = 1  and hispanic = 2 and ;
         (blafrican + asian + hawaisland + ;
         indialaska + someother) = 0 ;
   Into Cursor t_stw
   
      m.group =   " White          " + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_stw.tot_st1), Space(5) + '0', Str(t_stw.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st3), Space(5) + '0', Str(t_stw.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st5), Space(5) + '0', Str(t_stw.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st7), Space(5) + '0', Str(t_stw.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st9), Space(5) + '0', Str(t_stw.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st11), Space(5) + '0', Str(t_stw.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st13), Space(5) + '0', Str(t_stw.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.totalp), Space(5) + '0', Str(t_stw.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stw.tot_st2), Space(5) + '0', Str(t_stw.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st4), Space(5) + '0', Str(t_stw.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st6), Space(5) + '0', Str(t_stw.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st8), Space(5) + '0', Str(t_stw.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st10), Space(5) + '0', Str(t_stw.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st12), Space(5) + '0', Str(t_stw.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st14), Space(5) + '0', Str(t_stw.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.totaln), Space(5) + '0', Str(t_stw.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   m.HWHPOS=         Iif(Isnull(t_stw.tot_st1), Space(5) + '0', Str(t_stw.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st3), Space(5) + '0', Str(t_stw.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st5), Space(5) + '0', Str(t_stw.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st7), Space(5) + '0', Str(t_stw.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st9), Space(5) + '0', Str(t_stw.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st11), Space(5) + '0', Str(t_stw.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st13), Space(5) + '0', Str(t_stw.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.totalp), Space(5) + '0', Str(t_stw.totalp, 6, 0))
               
   m.HWHNEG=         Iif(Isnull(t_stw.tot_st2), Space(5) + '0', Str(t_stw.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st4), Space(5) + '0', Str(t_stw.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st6), Space(5) + '0', Str(t_stw.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st8), Space(5) + '0', Str(t_stw.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st10), Space(5) + '0', Str(t_stw.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st12), Space(5) + '0', Str(t_stw.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st14), Space(5) + '0', Str(t_stw.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.totaln), Space(5) + '0', Str(t_stw.totaln, 6, 0))
   
Use in t_stw   

** More Than 1 race
If Used('t_stm')
   Use In t_stm
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where (indialaska + blafrican + asian + white + ;
       hawaisland + someother) > 1 and hispanic = 2 ;
   Into Cursor t_stm
      
      m.group =   " More than one  " + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_stm.tot_st1), Space(5) + '0', Str(t_stm.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st3), Space(5) + '0', Str(t_stm.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st5), Space(5) + '0', Str(t_stm.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st7), Space(5) + '0', Str(t_stm.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st9), Space(5) + '0', Str(t_stm.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st11), Space(5) + '0', Str(t_stm.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st13), Space(5) + '0', Str(t_stm.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.totalp), Space(5) + '0', Str(t_stm.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   " race           " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stm.tot_st2), Space(5) + '0', Str(t_stm.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st4), Space(5) + '0', Str(t_stm.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st6), Space(5) + '0', Str(t_stm.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st8), Space(5) + '0', Str(t_stm.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st10), Space(5) + '0', Str(t_stm.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st12), Space(5) + '0', Str(t_stm.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st14), Space(5) + '0', Str(t_stm.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.totaln), Space(5) + '0', Str(t_stm.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   m.HMOREPOS=       Iif(Isnull(t_stm.tot_st1), Space(5) + '0', Str(t_stm.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st3), Space(5) + '0', Str(t_stm.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st5), Space(5) + '0', Str(t_stm.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st7), Space(5) + '0', Str(t_stm.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st9), Space(5) + '0', Str(t_stm.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st11), Space(5) + '0', Str(t_stm.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st13), Space(5) + '0', Str(t_stm.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.totalp), Space(5) + '0', Str(t_stm.totalp, 6, 0)) 
               
   m.HMORENEG=       Iif(Isnull(t_stm.tot_st2), Space(5) + '0', Str(t_stm.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st4), Space(5) + '0', Str(t_stm.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st6), Space(5) + '0', Str(t_stm.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st8), Space(5) + '0', Str(t_stm.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st10), Space(5) + '0', Str(t_stm.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st12), Space(5) + '0', Str(t_stm.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st14), Space(5) + '0', Str(t_stm.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.totaln), Space(5) + '0', Str(t_stm.totaln, 6, 0))
   
Use in t_stm   

** Unknown
If Used('t_stu')
   Use In t_stu
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where (unknowrep = 1 or someother = 1) and hispanic = 2 and ;
         (white + blafrican + asian + hawaisland + indialaska) = 0;
   Into Cursor t_stu
      
      m.group =   " Not reported   " + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_stu.tot_st1), Space(5) + '0', Str(t_stu.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st3), Space(5) + '0', Str(t_stu.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st5), Space(5) + '0', Str(t_stu.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st7), Space(5) + '0', Str(t_stu.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st9), Space(5) + '0', Str(t_stu.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st11), Space(5) + '0', Str(t_stu.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st13), Space(5) + '0', Str(t_stu.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.totalp), Space(5) + '0', Str(t_stu.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stu.tot_st2), Space(5) + '0', Str(t_stu.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st4), Space(5) + '0', Str(t_stu.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st6), Space(5) + '0', Str(t_stu.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st8), Space(5) + '0', Str(t_stu.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st10), Space(5) + '0', Str(t_stu.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st12), Space(5) + '0', Str(t_stu.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st14), Space(5) + '0', Str(t_stu.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.totaln), Space(5) + '0', Str(t_stu.totaln, 6, 0))
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   m.HUNKPOS=        Iif(Isnull(t_stu.tot_st1), Space(5) + '0', Str(t_stu.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st3), Space(5) + '0', Str(t_stu.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st5), Space(5) + '0', Str(t_stu.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st7), Space(5) + '0', Str(t_stu.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st9), Space(5) + '0', Str(t_stu.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st11), Space(5) + '0', Str(t_stu.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st13), Space(5) + '0', Str(t_stu.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.totalp), Space(5) + '0', Str(t_stu.totalp, 6, 0)) 
               
   m.HUNKNEG=        Iif(Isnull(t_stu.tot_st2), Space(5) + '0', Str(t_stu.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st4), Space(5) + '0', Str(t_stu.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st6), Space(5) + '0', Str(t_stu.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st8), Space(5) + '0', Str(t_stu.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st10), Space(5) + '0', Str(t_stu.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st12), Space(5) + '0', Str(t_stu.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st14), Space(5) + '0', Str(t_stu.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.totaln), Space(5) + '0', Str(t_stu.totaln, 6, 0))
  
Use in t_stu

** Total
If Used('t_stt')
   Use In t_stt
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where  hispanic = 2 ;
   Into Cursor t_stt
   
      m.group = " Total          " + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stt.tot_st1), Space(5) + '0', Str(t_stt.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st3), Space(5) + '0', Str(t_stt.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st5), Space(5) + '0', Str(t_stt.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st7), Space(5) + '0', Str(t_stt.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st9), Space(5) + '0', Str(t_stt.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st11), Space(5) + '0', Str(t_stt.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st13), Space(5) + '0', Str(t_stt.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.totalp), Space(5) + '0', Str(t_stt.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stt.tot_st2), Space(5) + '0', Str(t_stt.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st4), Space(5) + '0', Str(t_stt.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st6), Space(5) + '0', Str(t_stt.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st8), Space(5) + '0', Str(t_stt.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st10), Space(5) + '0', Str(t_stt.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st12), Space(5) + '0', Str(t_stt.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st14), Space(5) + '0', Str(t_stt.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.totaln), Space(5) + '0', Str(t_stt.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 

      m.HTOTPOS=     Iif(Isnull(t_stt.tot_st1), Space(5) + '0', Str(t_stt.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st3), Space(5) + '0', Str(t_stt.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st5), Space(5) + '0', Str(t_stt.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st7), Space(5) + '0', Str(t_stt.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st9), Space(5) + '0', Str(t_stt.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st11), Space(5) + '0', Str(t_stt.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st13), Space(5) + '0', Str(t_stt.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totalp), Space(5) + '0', Str(t_stt.totalp, 6, 0)) 
               
      m.HTOTNEG=     Iif(Isnull(t_stt.tot_st2), Space(5) + '0', Str(t_stt.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st4), Space(5) + '0', Str(t_stt.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st6), Space(5) + '0', Str(t_stt.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st8), Space(5) + '0', Str(t_stt.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st10), Space(5) + '0', Str(t_stt.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st12), Space(5) + '0', Str(t_stt.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st14), Space(5) + '0', Str(t_stt.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totaln), Space(5) + '0', Str(t_stt.totaln, 6, 0)) 
   
   Use in t_stt

** Section 72b Non-Hispanic
   m.page_ej=8
   m.group="b.   Number of NON-HISPANIC clients" 
   Insert Into cadr_tmp From Memvar
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   m.group = REPL('³',1) + "       Race     " + REPL('³',1) + " HIV status " + REPL('³',1) + ;
            "  Under " + REPL('³',1) + "  2-12  " + REPL('³',1) + "  13-24 " + REPL('³',1) + ;
            "  25-44 " + REPL('³',1) + "  45-64 " + REPL('³',1) + "65 years" + REPL('³',1) + ;
            "   Age  " + REPL('³',1) + "  Total "   + REPL('³',1)
   Insert Into cadr_tmp From Memvar 

   m.group = REPL('³',1) + Space(16) + REPL('³',1) + Space(12) + REPL('³',1) + ;
            " 2 years" + REPL('³',1) + "  years " + REPL('³',1) + "  years " + REPL('³',1) + ;
            "  years " + REPL('³',1) + "  years " + REPL('³',1) + "& older " + REPL('³',1) + ;
            " Unknown" + REPL('³',1) + "        " + REPL('³',1)
   Insert Into cadr_tmp From Memvar 
         
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar


** American indian
If Used('t_sta')
   Use In t_sta
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where indialaska = 1 ;
         and hispanic <> 2 ;
         and (blafrican + asian + white + hawaisland + someother) = 0 ;
   Into Cursor t_sta
   
      m.group =   " American Indian" + Space(2) + "HIV+ /Indet." + ;
                Space(3) + Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
            
      m.group =   " /Alaskan Native" + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
      Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.inpos=          Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0))
   m.inneg=          Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
   
Use in t_sta

** Asian
If Used('t_sta')
   Use In t_sta
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where asian = 1 ;
         and hispanic <> 2 ;
         and (white + blafrican + hawaisland + indialaska + someother) = 0  ;
   Into Cursor t_sta
   
   m.group =  " Asian          " + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
            
   m.group =  "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.aspos=          Iif(Isnull(t_sta.tot_st1), Space(5) + '0', Str(t_sta.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st3), Space(5) + '0', Str(t_sta.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st5), Space(5) + '0', Str(t_sta.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st7), Space(5) + '0', Str(t_sta.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st9), Space(5) + '0', Str(t_sta.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st11), Space(5) + '0', Str(t_sta.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st13), Space(5) + '0', Str(t_sta.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totalp), Space(5) + '0', Str(t_sta.totalp, 6, 0)) 
               
   m.asneg=          Iif(Isnull(t_sta.tot_st2), Space(5) + '0', Str(t_sta.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st4), Space(5) + '0', Str(t_sta.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st6), Space(5) + '0', Str(t_sta.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st8), Space(5) + '0', Str(t_sta.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st10), Space(5) + '0', Str(t_sta.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st12), Space(5) + '0', Str(t_sta.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.tot_st14), Space(5) + '0', Str(t_sta.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_sta.totaln), Space(5) + '0', Str(t_sta.totaln, 6, 0)) 
   
Use in t_sta

** Black or African
If Used('t_stb')
   Use In t_stb
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where blafrican = 1 ;
         and hispanic <> 2 ;
         and (white + asian + hawaisland + indialaska + someother) = 0 ;
   Into Cursor t_stb
   
   m.group =   " Black or Afric." + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stb.tot_st1), Space(5) + '0', Str(t_stb.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st3), Space(5) + '0', Str(t_stb.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st5), Space(5) + '0', Str(t_stb.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st7), Space(5) + '0', Str(t_stb.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st9), Space(5) + '0', Str(t_stb.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st11), Space(5) + '0', Str(t_stb.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st13), Space(5) + '0', Str(t_stb.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.totalp), Space(5) + '0', Str(t_stb.totalp, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
            
   m.group =   " American       " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stb.tot_st2), Space(5) + '0', Str(t_stb.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st4), Space(5) + '0', Str(t_stb.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st6), Space(5) + '0', Str(t_stb.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st8), Space(5) + '0', Str(t_stb.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st10), Space(5) + '0', Str(t_stb.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st12), Space(5) + '0', Str(t_stb.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.tot_st14), Space(5) + '0', Str(t_stb.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stb.totaln), Space(5) + '0', Str(t_stb.totaln, 6, 0)) 
 
               
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.blpos=          Iif(Isnull(t_stb.tot_st1), Space(5) + '0', Str(t_stb.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st3), Space(5) + '0', Str(t_stb.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st5), Space(5) + '0', Str(t_stb.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st7), Space(5) + '0', Str(t_stb.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st9), Space(5) + '0', Str(t_stb.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st11), Space(5) + '0', Str(t_stb.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st13), Space(5) + '0', Str(t_stb.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.totalp), Space(5) + '0', Str(t_stb.totalp, 6, 0))
               
   m.blneg=          Iif(Isnull(t_stb.tot_st2), Space(5) + '0', Str(t_stb.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st4), Space(5) + '0', Str(t_stb.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st6), Space(5) + '0', Str(t_stb.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st8), Space(5) + '0', Str(t_stb.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st10), Space(5) + '0', Str(t_stb.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st12), Space(5) + '0', Str(t_stb.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.tot_st14), Space(5) + '0', Str(t_stb.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stb.totaln), Space(5) + '0', Str(t_stb.totaln, 6, 0))
   
Use in t_stb

** Native Hawaiian
If Used('t_stn')
   Use In t_stn
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where hawaisland = 1 ;
         and hispanic <> 2 ;
         and (blafrican + asian + white + indialaska + someother) = 0 ;
   Into Cursor t_stn
   
   m.group =   " Native Hawaiian" + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stn.tot_st1), Space(5) + '0', Str(t_stn.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st3), Space(5) + '0', Str(t_stn.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st5), Space(5) + '0', Str(t_stn.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st7), Space(5) + '0', Str(t_stn.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st9), Space(5) + '0', Str(t_stn.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st11), Space(5) + '0', Str(t_stn.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st13), Space(5) + '0', Str(t_stn.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.totalp), Space(5) + '0', Str(t_stn.totalp, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
            
   m.group =   "  /Pacific Isl. " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stn.tot_st2), Space(5) + '0', Str(t_stn.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st4), Space(5) + '0', Str(t_stn.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st6), Space(5) + '0', Str(t_stn.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st8), Space(5) + '0', Str(t_stn.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st10), Space(5) + '0', Str(t_stn.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st12), Space(5) + '0', Str(t_stn.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.tot_st14), Space(5) + '0', Str(t_stn.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stn.totaln), Space(5) + '0', Str(t_stn.totaln, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.napos=          Iif(Isnull(t_stn.tot_st1), Space(5) + '0', Str(t_stn.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st3), Space(5) + '0', Str(t_stn.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st5), Space(5) + '0', Str(t_stn.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st7), Space(5) + '0', Str(t_stn.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st9), Space(5) + '0', Str(t_stn.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st11), Space(5) + '0', Str(t_stn.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st13), Space(5) + '0', Str(t_stn.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.totalp), Space(5) + '0', Str(t_stn.totalp, 6, 0)) 
               
   m.naneg=          Iif(Isnull(t_stn.tot_st2), Space(5) + '0', Str(t_stn.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st4), Space(5) + '0', Str(t_stn.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st6), Space(5) + '0', Str(t_stn.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st8), Space(5) + '0', Str(t_stn.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st10), Space(5) + '0', Str(t_stn.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st12), Space(5) + '0', Str(t_stn.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.tot_st14), Space(5) + '0', Str(t_stn.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stn.totaln), Space(5) + '0', Str(t_stn.totaln, 6, 0)) 
   
Use in t_stn

** White
If Used('t_stw')
   Use In t_stw
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where white = 1  ;
         and hispanic <> 2 ;
         and (blafrican + asian + hawaisland + indialaska + someother) = 0 ;
   Into Cursor t_stw
   
    m.group =  " White          " + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stw.tot_st1), Space(5) + '0', Str(t_stw.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st3), Space(5) + '0', Str(t_stw.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st5), Space(5) + '0', Str(t_stw.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st7), Space(5) + '0', Str(t_stw.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st9), Space(5) + '0', Str(t_stw.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st11), Space(5) + '0', Str(t_stw.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st13), Space(5) + '0', Str(t_stw.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.totalp), Space(5) + '0', Str(t_stw.totalp, 6, 0)) 
    Insert Into cadr_tmp From Memvar 
            
    m.group =  "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stw.tot_st2), Space(5) + '0', Str(t_stw.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st4), Space(5) + '0', Str(t_stw.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st6), Space(5) + '0', Str(t_stw.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st8), Space(5) + '0', Str(t_stw.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st10), Space(5) + '0', Str(t_stw.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st12), Space(5) + '0', Str(t_stw.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.tot_st14), Space(5) + '0', Str(t_stw.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stw.totaln), Space(5) + '0', Str(t_stw.totaln, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.whpos=          Iif(Isnull(t_stw.tot_st1), Space(5) + '0', Str(t_stw.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st3), Space(5) + '0', Str(t_stw.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st5), Space(5) + '0', Str(t_stw.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st7), Space(5) + '0', Str(t_stw.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st9), Space(5) + '0', Str(t_stw.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st11), Space(5) + '0', Str(t_stw.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st13), Space(5) + '0', Str(t_stw.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.totalp), Space(5) + '0', Str(t_stw.totalp, 6, 0))
               
   m.whneg=          Iif(Isnull(t_stw.tot_st2), Space(5) + '0', Str(t_stw.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st4), Space(5) + '0', Str(t_stw.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st6), Space(5) + '0', Str(t_stw.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st8), Space(5) + '0', Str(t_stw.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st10), Space(5) + '0', Str(t_stw.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st12), Space(5) + '0', Str(t_stw.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.tot_st14), Space(5) + '0', Str(t_stw.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stw.totaln), Space(5) + '0', Str(t_stw.totaln, 6, 0))
   
Use in t_stw   

*!*   PB 12/2008: No Hispanic line for 2008 RDR. We will send '' as a value.
*!*   ***Hispanic
*!*   If Used('t_sth')
*!*      Use In t_sth
*!*   Endif
   
*!*      Select ; 
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
*!*         Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
*!*         Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
*!*      From all_t4 ;
*!*      Where hispanic = 2 ;
*!*      Into Cursor t_sth
*!*      
*!*         m.group =   " Hispanic       " + Space(2) + "HIV+ /Indet." + ;
*!*                   Space(3) + Iif(Isnull(t_sth.tot_st1), Space(5)+'0', Str(t_sth.tot_st1, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st3), Space(5)+'0', Str(t_sth.tot_st3, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st5), Space(5)+'0', Str(t_sth.tot_st5, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st7), Space(5)+'0', Str(t_sth.tot_st7, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st9), Space(5)+'0', Str(t_sth.tot_st9, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st11), Space(5)+'0', Str(t_sth.tot_st11, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st13), Space(5)+'0', Str(t_sth.tot_st13, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.totalp), Space(5)+'0', Str(t_sth.totalp, 6, 0))
*!*         Insert Into cadr_tmp From Memvar 
*!*               
*!*         m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st2), Space(5)+'0', Str(t_sth.tot_st2, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st4), Space(5)+'0', Str(t_sth.tot_st4, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st6), Space(5)+'0', Str(t_sth.tot_st6, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st8), Space(5)+'0', Str(t_sth.tot_st8, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st10), Space(5)+'0', Str(t_sth.tot_st10, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st12), Space(5)+'0', Str(t_sth.tot_st12, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.tot_st14), Space(5)+'0', Str(t_sth.tot_st14, 6, 0)) + ;
*!*                  Space(3) + Iif(Isnull(t_sth.totaln), Space(5)+'0', Str(t_sth.totaln, 6, 0)) 
*!*         Insert Into cadr_tmp From Memvar 
*!*      
*!*      m.group = REPL('Ä',103)  
*!*      Insert Into cadr_tmp From Memvar

*!*   * jss, 6/3/03, define memvars for extract's section 6 
*!*      m.hisppos=            Iif(Isnull(t_sth.tot_st1), Space(5)+'0', Str(t_sth.tot_st1, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st3), Space(5)+'0', Str(t_sth.tot_st3, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st5), Space(5)+'0', Str(t_sth.tot_st5, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st7), Space(5)+'0', Str(t_sth.tot_st7, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st9), Space(5)+'0', Str(t_sth.tot_st9, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st11), Space(5)+'0', Str(t_sth.tot_st11, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st13), Space(5)+'0', Str(t_sth.tot_st13, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.totalp), Space(5)+'0', Str(t_sth.totalp, 6, 0))
*!*                  
*!*      m.hispneg=            Iif(Isnull(t_sth.tot_st2), Space(5)+'0', Str(t_sth.tot_st2, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st4), Space(5)+'0', Str(t_sth.tot_st4, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st6), Space(5)+'0', Str(t_sth.tot_st6, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st8), Space(5)+'0', Str(t_sth.tot_st8, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st10), Space(5)+'0', Str(t_sth.tot_st10, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st12), Space(5)+'0', Str(t_sth.tot_st12, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.tot_st14), Space(5)+'0', Str(t_sth.tot_st14, 6, 0)) + ;
*!*                  ',' + Iif(Isnull(t_sth.totaln), Space(5)+'0', Str(t_sth.totaln, 6, 0))
*!*      
*!*   Use in t_sth

** More Than 1 race
If Used('t_stm')
   Use In t_stm
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where (indialaska + blafrican + asian + white + hawaisland + someother) > 1 ;
         and hispanic <> 2 ;
   Into Cursor t_stm
      
   m.group =  " More than one  " + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stm.tot_st1), Space(5) + '0', Str(t_stm.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st3), Space(5) + '0', Str(t_stm.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st5), Space(5) + '0', Str(t_stm.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st7), Space(5) + '0', Str(t_stm.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st9), Space(5) + '0', Str(t_stm.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st11), Space(5) + '0', Str(t_stm.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st13), Space(5) + '0', Str(t_stm.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.totalp), Space(5) + '0', Str(t_stm.totalp, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
            
   m.group =   " race           " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stm.tot_st2), Space(5) + '0', Str(t_stm.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st4), Space(5) + '0', Str(t_stm.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st6), Space(5) + '0', Str(t_stm.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st8), Space(5) + '0', Str(t_stm.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st10), Space(5) + '0', Str(t_stm.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st12), Space(5) + '0', Str(t_stm.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.tot_st14), Space(5) + '0', Str(t_stm.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stm.totaln), Space(5) + '0', Str(t_stm.totaln, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.morepos=        Iif(Isnull(t_stm.tot_st1), Space(5) + '0', Str(t_stm.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st3), Space(5) + '0', Str(t_stm.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st5), Space(5) + '0', Str(t_stm.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st7), Space(5) + '0', Str(t_stm.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st9), Space(5) + '0', Str(t_stm.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st11), Space(5) + '0', Str(t_stm.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st13), Space(5) + '0', Str(t_stm.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.totalp), Space(5) + '0', Str(t_stm.totalp, 6, 0)) 
               
   m.moreneg=        Iif(Isnull(t_stm.tot_st2), Space(5) + '0', Str(t_stm.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st4), Space(5) + '0', Str(t_stm.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st6), Space(5) + '0', Str(t_stm.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st8), Space(5) + '0', Str(t_stm.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st10), Space(5) + '0', Str(t_stm.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st12), Space(5) + '0', Str(t_stm.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.tot_st14), Space(5) + '0', Str(t_stm.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stm.totaln), Space(5) + '0', Str(t_stm.totaln, 6, 0))
   
Use in t_stm   

** Unknown
If Used('t_stu')
   Use In t_stu
Endif
   
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where (unknowrep = 1 or someother = 1) ;
         and hispanic <> 2 ;
         and (white + blafrican + asian + hawaisland + indialaska) = 0;
   Into Cursor t_stu
      
   m.group =  " Not reported   " + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stu.tot_st1), Space(5) + '0', Str(t_stu.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st3), Space(5) + '0', Str(t_stu.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st5), Space(5) + '0', Str(t_stu.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st7), Space(5) + '0', Str(t_stu.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st9), Space(5) + '0', Str(t_stu.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st11), Space(5) + '0', Str(t_stu.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st13), Space(5) + '0', Str(t_stu.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.totalp), Space(5) + '0', Str(t_stu.totalp, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
            
   m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stu.tot_st2), Space(5) + '0', Str(t_stu.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st4), Space(5) + '0', Str(t_stu.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st6), Space(5) + '0', Str(t_stu.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st8), Space(5) + '0', Str(t_stu.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st10), Space(5) + '0', Str(t_stu.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st12), Space(5) + '0', Str(t_stu.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.tot_st14), Space(5) + '0', Str(t_stu.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stu.totaln), Space(5) + '0', Str(t_stu.totaln, 6, 0))
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   * jss, 6/3/03, define memvars for extract's section 6 
   m.unkpos=         Iif(Isnull(t_stu.tot_st1), Space(5) + '0', Str(t_stu.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st3), Space(5) + '0', Str(t_stu.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st5), Space(5) + '0', Str(t_stu.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st7), Space(5) + '0', Str(t_stu.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st9), Space(5) + '0', Str(t_stu.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st11), Space(5) + '0', Str(t_stu.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st13), Space(5) + '0', Str(t_stu.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.totalp), Space(5) + '0', Str(t_stu.totalp, 6, 0)) 
               
   m.unkneg=         Iif(Isnull(t_stu.tot_st2), Space(5) + '0', Str(t_stu.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st4), Space(5) + '0', Str(t_stu.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st6), Space(5) + '0', Str(t_stu.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st8), Space(5) + '0', Str(t_stu.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st10), Space(5) + '0', Str(t_stu.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st12), Space(5) + '0', Str(t_stu.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.tot_st14), Space(5) + '0', Str(t_stu.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stu.totaln), Space(5) + '0', Str(t_stu.totaln, 6, 0))
   
Use in t_stu

** Total
If Used('t_stt')
   Use In t_stt
Endif
   ** For 2008 RDR Remove Hispanic from mix.
   Select ; 
      Sum(Iif((hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st1, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif((cl_age< 2 and !Empty(Dob)), 1, 0), 0)) as tot_st2, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st3, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 2, 12),1, 0), 0)) as tot_st4, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st5, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 13, 24), 1, 0), 0)) as tot_st6, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st7, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 25, 44),1, 0), 0)) as tot_st8, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st9, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Between(cl_age, 45, 64),1, 0), 0)) as tot_st10, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st11, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(cl_age >= 65, 1, 0), 0)) as tot_st12, ;
      Sum(Iif((hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st13, ;
      Sum(Iif(!(hiv_pos or hiv_indet), Iif(Empty(dob), 1, 0), 0)) as tot_st14, ;
      Sum(Iif((hiv_pos or hiv_indet), 1, 0))  as totalp, ;
      Sum(Iif(!(hiv_pos or hiv_indet), 1, 0)) as totaln ;
   From all_t4 ;
   Where  hispanic <> 2 ;
   Into Cursor t_stt
   
   m.group =  " Total          " + Space(2) + "HIV+ /Indet." + ;
               Space(3) + Iif(Isnull(t_stt.tot_st1), Space(5) + '0', Str(t_stt.tot_st1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st3), Space(5) + '0', Str(t_stt.tot_st3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st5), Space(5) + '0', Str(t_stt.tot_st5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st7), Space(5) + '0', Str(t_stt.tot_st7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st9), Space(5) + '0', Str(t_stt.tot_st9, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st11), Space(5) + '0', Str(t_stt.tot_st11, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st13), Space(5) + '0', Str(t_stt.tot_st13, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.totalp), Space(5) + '0', Str(t_stt.totalp, 6, 0)) 
   Insert Into cadr_tmp From Memvar 
            
   m.group =   "                " + Space(2) + "HIV-/Unknown" + ;
               Space(3) + Iif(Isnull(t_stt.tot_st2), Space(5) + '0', Str(t_stt.tot_st2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st4), Space(5) + '0', Str(t_stt.tot_st4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st6), Space(5) + '0', Str(t_stt.tot_st6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st8), Space(5) + '0', Str(t_stt.tot_st8, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st10), Space(5) + '0', Str(t_stt.tot_st10, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st12), Space(5) + '0', Str(t_stt.tot_st12, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.tot_st14), Space(5) + '0', Str(t_stt.tot_st14, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_stt.totaln), Space(5) + '0', Str(t_stt.totaln, 6, 0)) 
   Insert Into cadr_tmp From Memvar 

   * jss, 6/3/03, define memvars for extract's section 6 
   m.totpos=         Iif(Isnull(t_stt.tot_st1), Space(5) + '0', Str(t_stt.tot_st1, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st3), Space(5) + '0', Str(t_stt.tot_st3, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st5), Space(5) + '0', Str(t_stt.tot_st5, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st7), Space(5) + '0', Str(t_stt.tot_st7, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st9), Space(5) + '0', Str(t_stt.tot_st9, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st11), Space(5) + '0', Str(t_stt.tot_st11, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st13), Space(5) + '0', Str(t_stt.tot_st13, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totalp), Space(5) + '0', Str(t_stt.totalp, 6, 0)) 
               
   m.totneg=         Iif(Isnull(t_stt.tot_st2), Space(5) + '0', Str(t_stt.tot_st2, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st4), Space(5) + '0', Str(t_stt.tot_st4, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st6), Space(5) + '0', Str(t_stt.tot_st6, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st8), Space(5) + '0', Str(t_stt.tot_st8, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st10), Space(5) + '0', Str(t_stt.tot_st10, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st12), Space(5) + '0', Str(t_stt.tot_st12, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.tot_st14), Space(5) + '0', Str(t_stt.tot_st14, 6, 0)) + ;
               ',' + Iif(Isnull(t_stt.totaln), Space(5) + '0', Str(t_stt.totaln, 6, 0)) 
   
Use in t_stt

*---Q73
*!*   	m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13)
* jss, 11/29/07, add m.page_ej
   m.page_ej=9
	m.info = 73	

*   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
* jss, 11/20/07, replace title iii and iv with part c and d:   m.part  = "Part 6.2. Title IV Information"
   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/PART-SPECIFIC DATA FOR PARTS C AND D"
   m.part  = "Part 6.2. Part D Information"
	m.group = "73. Number of clients who are HIV+/Indeterminate during this reporting period by HIV exposure" + Chr(13) + ;
			  "    category and age"
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar	
	
**Prepare data	
If Used('all_rw')
   Use In all_rw
Endif
   

		Select	Distinct relhist.tc_id, relhist.rw_code, all_t4.dob, all_t4.cl_age ;
		From relhist, all_t4 ;
		Where ;
				(all_t4.hiv_pos = .t. or all_t4.hiv_indet = .t.) and ;	
				relhist.tc_id = all_t4.tc_id and ;
				relhist.tc_id + DTOS(relhist.date) + DTOS(relhist.dt) + relhist.tm ;
									IN (SELECT rh2.tc_id + MAX(DTOS(rh2.date) + DTOS(rh2.dt) + rh2.tm) ;
										FROM ;
											relhist rh2 ;
										WHERE ;
											rh2.date <= m.end_dt GROUP BY rh2.tc_id) ;
		Union ;
		Select tc_id, Space(2) as rw_code, dob, cl_age ;
		From all_t4 ;
		Where  (hiv_pos =.t. or hiv_indet = .t.) and ;
				tc_id Not in (Select Distinct tc_id From relhist) ;		
		Into Cursor ;
			all_rw
			
	m.group = REPL('³',1) + "   HIV Exposure Category     " + REPL('³',1) + ;
				"  Under " + REPL('³',1) + "  2-12  " + REPL('³',1) + "  13-24 " + REPL('³',1) + ;
				"  25-44 " + REPL('³',1) + "  45-64 " + REPL('³',1) + "65 years" + REPL('³',1) + ;
				"   Age  " + REPL('³',1) + "  Total "	+ REPL('³',1)
	Insert Into cadr_tmp From Memvar 

	m.group = REPL('³',1) + Space(29) + REPL('³',1) + ;
				" 2 years" + REPL('³',1) + "  years " + REPL('³',1) + "  years " + REPL('³',1) + ;
				"  years " + REPL('³',1) + "  years " + REPL('³',1) + "& older " + REPL('³',1) + ;
				" Unknown" + REPL('³',1) + "        " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
			
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
***Men who have sex with Men
If Used('t_rw1') 
   Use In t_rw1
Endif
   
	Select ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "02";
	Into Cursor t_rw1
	
		m.group =   " Men who have sex with men   " + ;
	 				Space(2) + Repl('±', 8) + ;
               Space(3) + Iif(Isnull(t_rw1.tot_rw2), Space(5) +'0', Str(t_rw1.tot_rw2, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_rw1.tot_rw3), Space(5) +'0', Str(t_rw1.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw1.tot_rw4), Space(5) +'0', Str(t_rw1.tot_rw4, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_rw1.tot_rw5), Space(5) +'0', Str(t_rw1.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw1.tot_rw6), Space(5) +'0', Str(t_rw1.tot_rw6, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_rw1.tot_rw7), Space(5) +'0', Str(t_rw1.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw1.total), Space(5) +'0', Str(t_rw1.total, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
				
      m.group =   "           (MSM)             " 

**		m.group =   "           (MSM)             " + ;
	** 				Space(2) + Repl('±', 8) 
   
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eamsm=Space(6)+ ',' + Iif(Isnull(t_rw1.tot_rw2), Space(5) +'0', Str(t_rw1.tot_rw2, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw1.tot_rw3), Space(5) +'0', Str(t_rw1.tot_rw3, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw1.tot_rw4), Space(5) +'0', Str(t_rw1.tot_rw4, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw1.tot_rw5), Space(5) +'0', Str(t_rw1.tot_rw5, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw1.tot_rw6), Space(5) +'0', Str(t_rw1.tot_rw6, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw1.tot_rw7), Space(5) +'0', Str(t_rw1.tot_rw7, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw1.total), Space(5) +'0', Str(t_rw1.total, 6, 0)) 
   
Use in t_rw1
***Injection drug user (IDU)
If Used('t_rw2')
   Use In t_rw2
Endif
   
	Select ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "03";
	Into Cursor t_rw2
	
		m.group =   " Injection drug user IDU     " + ;
	 				Space(2) + Repl('±', 8) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
					Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eaidu=Space(6)+ ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
	
Use in t_rw2
***MSM and IDU
	Select ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "01";
	Into Cursor t_rw2
	
		m.group =   " MSM and IDU                 " + ;
	 				Space(2) + Repl('±', 8) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eamid=Space(6)+ ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
	
Use in t_rw2
***Hemophilia/coagulation
	Select ; 
		Sum(Iif((cl_age< 2 and !Empty(Dob)), 1, 0)) 					as tot_rw1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "04";
	Into Cursor t_rw2
	
		m.group =   " Hemophilia/coagulation      " + ;
               Space(4) + Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
	 				Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
		
		m.group =   " disorder                    " 
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eahem=				Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
	
Use in t_rw2
***Heterosexual contact
	Select ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "05";
	Into Cursor t_rw2
	
		m.group =   " Heterosexual contact        " + ;
	 				Space(2) + Repl('±', 8) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eahet=Space(6)+ ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
                     ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
	
Use in t_rw2
***Receipt of transfusion of blood
	Select ; 
		Sum(Iif((cl_age< 2 and !Empty(Dob)), 1, 0)) 					as tot_rw1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "06";
	Into Cursor t_rw2
	
		m.group =   " Receipt of trans. of blood, " + ;
               Space(4) + Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
	 				Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
		
		m.group =   " blood components, or tissue " 
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eatrn=				Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
	
Use in t_rw2
***Perinatal transmission
	Select ; 
		Sum(Iif((cl_age< 2 and !Empty(Dob)), 1, 0)) 					as tot_rw1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "07";
	Into Cursor t_rw2
	
		m.group =   " Perinatal transmission      " + ;
               Space(4) + Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
	 				Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eaper=				Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
	      
Use in t_rw2
***Other
	Select ; 
		Sum(Iif((cl_age< 2 and !Empty(Dob)), 1, 0)) 					as tot_rw1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "09";
	Into Cursor t_rw2
	
		m.group =   " Other                       " + ;
	 				Space(4) + Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eaoth=				Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 

Use in t_rw2
***Untermined/Unknown
	Select ; 
		Sum(Iif((cl_age< 2 and !Empty(Dob)), 1, 0)) 					as tot_rw1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where rw_code = "08";
	Into Cursor t_rw2
	
		m.group =   " Undetermined/Unknown        " + ;
	 				Space(4) + Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 
		
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eaunk=				Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0))  
	
Use in t_rw2
***Total
	Select ; 
		Sum(Iif((cl_age< 2 and !Empty(Dob)), 1, 0)) 					as tot_rw1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) 		as tot_rw2, ;
		Sum(Iif(Between(cl_age, 13, 24), 1, 0)) 	as tot_rw3, ;
	   Sum(Iif(Between(cl_age, 25, 44), 1, 0)) 	as tot_rw4, ;
   	Sum(Iif(Between(cl_age, 45, 64),1, 0)) 	as tot_rw5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) 					as tot_rw6, ;
		Sum(Iif(Empty(dob), 1, 0)) 					as tot_rw7, ;
		Count(*) as total ;
	From all_rw ;
	Where (rw_code = "02" or rw_code = "03" or ;
			rw_code = "01"  or rw_code = "04" or ;
			rw_code = "05"  or rw_code = "06" or ;
			rw_code = "07"  or rw_code = "09" or ;
			rw_code = "08") ;
	Into Cursor t_rw2
	
		m.group =   " Total                       " + ;
	 				Space(4) + Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               Space(3) + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0)) 
               
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
	m.eatot=				Iif(Isnull(t_rw2.tot_rw1), Space(5) +'0', Str(t_rw2.tot_rw1, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw2), Space(5) +'0', Str(t_rw2.tot_rw2, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw3), Space(5) +'0', Str(t_rw2.tot_rw3, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw4), Space(5) +'0', Str(t_rw2.tot_rw4, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw5), Space(5) +'0', Str(t_rw2.tot_rw5, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw6), Space(5) +'0', Str(t_rw2.tot_rw6, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.tot_rw7), Space(5) +'0', Str(t_rw2.tot_rw7, 6, 0)) + ;
               ',' + Iif(Isnull(t_rw2.total), Space(5) +'0', Str(t_rw2.total, 6, 0))
	
Use in t_rw2 		

Use in all_rw			
Use in all_t4

Return
