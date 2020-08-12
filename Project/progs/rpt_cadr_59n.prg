* jss, 3/31/2005, code for 2005 CADR questions 59-61
* Makes CARE Act Data Report (Section 6 ...)( Q59-61)
*** Section 6
* jss, 3/31/2005, Q57(2004) becomes Q59(2005)...also, adding new "race" of hispanic
*---Q59

If Used('all_t3a') 
   Use In all_t3a
Endif
   
	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother  ;
	From all_t3 ;
	Into Cursor ;
	all_t3a
	
	Use in all_t3
	oApp.ReopenCur('all_t3a','all_t3')	

* PB 12/2008 Hispanic in section a
* jss, 11/29/07, add page_ej
   m.page_ej=1
	m.group = "59.  Number of patients who are HIV+/indeterminate for this reporting period by race, gender, & age"+Chr(13)+;
             "a.   Number of HISPANIC clients."
   
	m.info = 59
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('³',1) + "       Race     " + REPL('³',1) + "   Gender   " + REPL('³',1) + ;
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

If Used('t_gen') 
   Use In t_gen
Endif

	Create Cursor t_gen (desc C(11), gender C(2))
 
   Insert Into   t_gen (desc, gender) ;
         Values("Female", "10")
	Insert Into	t_gen (desc, gender) ;
			Values("Male", "11")
	Insert Into	t_gen (desc, gender) ;
			Values("Transgender", "12")
	Insert Into	t_gen (desc, gender) ;
			Values("Transgender", "13")
	Insert Into	t_gen (desc, gender) ;
			Values("Unknown/Unr", "  ")

** American Indian
If Used('t_ti1')
   Use In t_ti1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_i1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_i2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_i3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_i4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_i5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_i6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_i7, ;
      Count(*) AS totali ;
   From all_t3 , t_gen ;
   Where all_t3.indialaska = 1 and all_t3.hispanic = 2 and ;
         (all_t3.blafrican + all_t3.asian + all_t3.white + ;
          all_t3.hawaisland + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_ti1

If Used('t_ti')
   Use In t_ti
Endif
   
   Select * ;
   From t_ti1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_i1, 0 as tot_i2, 0 as tot_i3, ;
         0 as tot_i4, 0 as tot_i5, 0 as tot_i6, ;
         0 as tot_i7, 0 AS totali ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_ti1.desc From t_ti1) ;
   Group by 1 ;      
   Into Cursor t_ti Order by 1
   
   Select t_ti
   i = 1
   Scan
      mrow = Str(t_ti.tot_i1, 6, 0) + "," + Str(t_ti.tot_i2, 6, 0) + ;
       "," + Str(t_ti.tot_i3, 6, 0) + "," + Str(t_ti.tot_i4, 6, 0) + ;
       "," + Str(t_ti.tot_i5, 6, 0) + "," + Str(t_ti.tot_i6, 6, 0) + ;
       "," + Str(t_ti.tot_i7, 6, 0) + "," + Str(t_ti.totali, 6, 0)
    
      Do Case
         Case i = 1
            m.group =   " American      " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0)) 
      * jss, 6/3/03, define memvars for extract's section 6 
            m.RHINFEMALE=mrow
         Case i = 2            
            m.group =   " Indian/       " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHINMALE=mrow
         Case i = 3
            m.group =   " Alaskan       " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHINTRANS=mrow
         Otherwise   
            m.group =   " Native        " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHINUNK=mrow
      Endcase   
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_ti   
Use in t_ti1

** Asian
If Used('t_ta1')
   Use In t_ta1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_a1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_a2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_a3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_a4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_a5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_a6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_a7, ;
      Count(*) AS totala ;
   From all_t3 , t_gen ;
   Where all_t3.asian = 1 and all_t3.hispanic = 2 and ;
         (all_t3.white + all_t3.blafrican + all_t3.hawaisland + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_ta1
   
If Used('t_ta')
   Use In t_ta
Endif

   Select * ;
   From t_ta1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_a1, 0 as tot_a2, 0 as tot_a3, ;
         0 as tot_a4, 0 as tot_a5, 0 as tot_a6, ;
         0 as tot_a7, 0 AS totala ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_ta1.desc From t_ta1) ;
   Group by 1 ;      
   Into Cursor t_ta Order by 1
   
   Select t_ta
   i = 1
   Scan
      mrow = Str(t_ta.tot_a1, 6, 0) + "," + Str(t_ta.tot_a2, 6, 0) + ;
       "," + Str(t_ta.tot_a3, 6, 0) + "," + Str(t_ta.tot_a4, 6, 0) + ;
       "," + Str(t_ta.tot_a5, 6, 0) + "," + Str(t_ta.tot_a6, 6, 0) + ;
       "," + Str(t_ta.tot_a7, 6, 0) + "," + Str(t_ta.totala, 6, 0)
      If i = 2
            m.group =   " Asian          " + Space(2) + Iif(Isnull(t_ta.desc), '', t_ta.desc) + ;
                     Space(4) + Iif(Isnull(t_ta.tot_a1), Space(5)+'0', Str(t_ta.tot_a1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a2), Space(5)+'0', Str(t_ta.tot_a2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a3), Space(5)+'0', Str(t_ta.tot_a3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a4), Space(5)+'0', Str(t_ta.tot_a4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a5), Space(5)+'0', Str(t_ta.tot_a5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a6), Space(5)+'0', Str(t_ta.tot_a6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a7), Space(5)+'0', Str(t_ta.tot_a7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.totala), Space(5)+'0', Str(t_ta.totala, 6, 0)) 
      Else   
            m.group =   Space(18) + Iif(Isnull(t_ta.desc), '', t_ta.desc) + ;
                     Space(4) + Iif(Isnull(t_ta.tot_a1), Space(5)+'0', Str(t_ta.tot_a1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a2), Space(5)+'0', Str(t_ta.tot_a2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a3), Space(5)+'0', Str(t_ta.tot_a3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a4), Space(5)+'0', Str(t_ta.tot_a4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a5), Space(5)+'0', Str(t_ta.tot_a5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a6), Space(5)+'0', Str(t_ta.tot_a6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a7), Space(5)+'0', Str(t_ta.tot_a7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.totala), Space(5)+'0', Str(t_ta.totala, 6, 0)) 
      Endif               
      Insert Into cadr_tmp From Memvar 
      
      * jss, 6/3/03, define memvars for extract's section 6 
      IF i=1   
         m.RHASFEMALE=mrow
      ENDIF
      IF i=2   
         m.RHASMALE=mrow
      ENDIF
      IF i=3
         m.RHASTRANS=mrow
      ENDIF
      IF i=4
         m.RHASUNK=mrow
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_ta   
Use in t_ta1

***Black   
If Used('t_tb1')
   Use In t_tb1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_b1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_b2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_b3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_b4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_b5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_b6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_b7, ;
      Count(*) AS totalb ;
   From all_t3 , t_gen ;
   Where all_t3.blafrican = 1 and all_t3.hispanic = 2 and ;
         (all_t3.white + all_t3.asian + all_t3.hawaisland + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tb1

If Used('t_tb')
   Use In t_tb
Endif
   
   Select * ;
   From t_tb1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_b1, 0 as tot_b2, 0 as tot_b3, ;
         0 as tot_b4, 0 as tot_b5, 0 as tot_b6, ;
         0 as tot_b7, 0 AS totalb ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tb1.desc From t_tb1) ;
   Group by 1 ;      
   Into Cursor t_tb Order by 1
      
   Select t_tb
   i = 1
   Scan
      mrow = Str(t_tb.tot_b1, 6, 0) + "," + Str(t_tb.tot_b2, 6, 0) + ;
       "," + Str(t_tb.tot_b3, 6, 0) + "," + Str(t_tb.tot_b4, 6, 0) + ;
       "," + Str(t_tb.tot_b5, 6, 0) + "," + Str(t_tb.tot_b6, 6, 0) + ;
       "," + Str(t_tb.tot_b7, 6, 0) + "," + Str(t_tb.totalb, 6, 0)
      Do Case
         Case i = 1
            m.group =   " Black or        " + Space(1) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHBLFEMALE=mrow
         Case i = 2
            m.group =   " African        " + Space(2) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) +;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHBLMALE=mrow
         Case i = 3
            m.group =   " American       " + Space(2) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHBLTRANS =mrow
         Otherwise   
            m.group =   Space(18) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHBLUNK=mrow
      Endcase   
                  
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tb   
Use in t_tb1

***Native Hawaiian   
If Used('t_tn1')
   Use In t_tn1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_n1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_n2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_n3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_n4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_n5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_n6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_n7, ;
      Count(*) AS totaln ;
   From all_t3 , t_gen ;
   Where all_t3.hawaisland = 1 and all_t3.hispanic = 2 and ;
         (all_t3.blafrican + all_t3.asian + all_t3.white + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tn1

If Used('t_tn')
   Use In t_tn
Endif
   
   Select * ;
   From t_tn1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_n1, 0 as tot_n2, 0 as tot_n3, ;
         0 as tot_n4, 0 as tot_n5, 0 as tot_n6, ;
         0 as tot_n7, 0 AS totaln ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tn1.desc From t_tn1) ;
   Group by 1 ;      
   Into Cursor t_tn Order by 1
   
   Select t_tn
   i = 1
   Scan
      mrow = Str(t_tn.tot_n1, 6, 0) + "," + Str(t_tn.tot_n2, 6, 0) + ;
       "," + Str(t_tn.tot_n3, 6, 0) + "," + Str(t_tn.tot_n4, 6, 0) + ;
       "," + Str(t_tn.tot_n5, 6, 0) + "," + Str(t_tn.tot_n6, 6, 0) + ;
       "," + Str(t_tn.tot_n7, 6, 0) + "," + Str(t_tn.totaln, 6, 0)
      Do Case
         Case i = 1
            m.group =   " Native          " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHNAFEMALE =mrow   
         Case i = 2
            m.group =   " Hawaiian/       " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHNAMALE=mrow
         Case i = 3
            m.group =   " Pacific         " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHNATRANS=mrow
         Otherwise   
            m.group =   " Islander        " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.RHNAUNK=mrow
      Endcase   
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tn   
Use in t_tn1

***White	
If Used('t_tw1') 
   Use In t_tw1
Endif

	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_w1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_w2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_w3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_w4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_w5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_w6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_w7, ;
		Count(*) AS totalw ;
	From all_t3 , t_gen ;
	Where all_t3.white = 1 and all_t3.hispanic = 2 and ;
			(all_t3.blafrican + all_t3.asian + all_t3.hawaisland + ;
			 all_t3.indialaska + all_t3.someother) = 0 and ;
		all_t3.gender = t_gen.gender ;	
	Group by 1;
	Into Cursor t_tw1

If Used('t_tw') 
   Use In t_tw
Endif
	
	Select * ;
	From t_tw1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_w1, 0 as tot_w2, 0 as tot_w3, ;
			0 as tot_w4, 0 as tot_w5, 0 as tot_w6, ;
			0 as tot_w7, 0 AS totalw ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tw1.desc From t_tw1) ;
	Group by 1 ;		
	Into Cursor t_tw Order by 1

	Select t_tw
	i = 1
	Scan
		If i = 2
				m.group =   " White          " + Space(2) + Iif(Isnull(t_tw.desc),'',t_tw.desc) + ;
							Space(4) + Iif(Isnull(t_tw.tot_w1), Space(5)+'0', Str(t_tw.tot_w1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w2), Space(5)+'0', Str(t_tw.tot_w2, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tw.tot_w3), Space(5)+'0', Str(t_tw.tot_w3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w4), Space(5)+'0', Str(t_tw.tot_w4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tw.tot_w5), Space(5)+'0', Str(t_tw.tot_w5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w6), Space(5)+'0', Str(t_tw.tot_w6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tw.tot_w7), Space(5)+'0', Str(t_tw.tot_w7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.totalw), Space(5)+'0', Str(t_tw.totalw, 6, 0)) 

		Else	
				m.group =   Space(18) + Iif(Isnull(t_tw.desc),'',t_tw.desc) + ;
							Space(4) + Iif(Isnull(t_tw.tot_w1), Space(5)+'0', Str(t_tw.tot_w1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w2), Space(5)+'0', Str(t_tw.tot_w2, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tw.tot_w3), Space(5)+'0', Str(t_tw.tot_w3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w4), Space(5)+'0', Str(t_tw.tot_w4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tw.tot_w5), Space(5)+'0', Str(t_tw.tot_w5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w6), Space(5)+'0', Str(t_tw.tot_w6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tw.tot_w7), Space(5)+'0', Str(t_tw.tot_w7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.totalw), Space(5)+'0', Str(t_tw.totalw, 6, 0)) 
		Endif					

		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = 			Str(t_tw.tot_w1, 6, 0) + "," + Str(t_tw.tot_w2, 6, 0) + ;
					"," + Str(t_tw.tot_w3, 6, 0) + "," + Str(t_tw.tot_w4, 6, 0) + ;
					"," + Str(t_tw.tot_w5, 6, 0) + "," + Str(t_tw.tot_w6, 6, 0) + ;
					"," + Str(t_tw.tot_w7, 6, 0) + "," + Str(t_tw.totalw, 6, 0)
		IF i=1	
			m.RHWHFEMALE=mrow
		ENDIF
		IF i=2	
			m.RHWHMALE=mrow
		ENDIF
		IF i=3
			m.RHWHTRANS=mrow
		ENDIF
		IF i=4
			m.RHWHUNK=mrow	
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tw	
Use in t_tw1


***More Than 1 race
If Used('t_tm1')
   Use In t_tm1
Endif
   
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_m1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_m2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_m3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_m4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_m5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_m6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_m7, ;
		Count(*) AS totalm ;
	From all_t3 , t_gen ;
	Where (all_t3.indialaska + all_t3.blafrican + all_t3.asian + all_t3.white + ;
			 all_t3.hawaisland + all_t3.someother) > 1 and all_t3.hispanic = 2 and ;
			 all_t3.gender = t_gen.gender ;	
	Group by 1;
	Into Cursor t_tm1

If Used('t_tm')
   Use In t_tm
Endif
	
	Select * ;
	From t_tm1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_m1, 0 as tot_m2, 0 as tot_m3, ;
			0 as tot_m4, 0 as tot_m5, 0 as tot_m6, ;
			0 as tot_m7, 0 AS totalm ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tm1.desc From t_tm1) ;
	Group by 1 ;		
	Into Cursor t_tm Order by 1
	
	Select t_tm
	i = 1
	Scan
		Do Case
			Case i = 2
				m.group =   " More than one" + Space(4) + Iif(Isnull(t_tm.desc), '', t_tm.desc) + ;
							Space(4) + Iif(Isnull(t_tm.tot_m1), Space(5)+'0', Str(t_tm.tot_m1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m2), Space(5)+'0', Str(t_tm.tot_m2, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tm.tot_m3), Space(5)+'0', Str(t_tm.tot_m3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m4), Space(5)+'0', Str(t_tm.tot_m4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tm.tot_m5), Space(5)+'0', Str(t_tm.tot_m5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m6), Space(5)+'0', Str(t_tm.tot_m6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tm.tot_m7), Space(5)+'0', Str(t_tm.tot_m7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.totalm), Space(5)+'0', Str(t_tm.totalm, 6, 0)) 
			Case i = 3
				m.group =   " race          " + Space(3) + Iif(Isnull(t_tm.desc), '', t_tm.desc) + ;
							Space(4) + Iif(Isnull(t_tm.tot_m1), Space(5)+'0', Str(t_tm.tot_m1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m2), Space(5)+'0', Str(t_tm.tot_m2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m3), Space(5)+'0', Str(t_tm.tot_m3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m4), Space(5)+'0', Str(t_tm.tot_m4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m5), Space(5)+'0', Str(t_tm.tot_m5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m6), Space(5)+'0', Str(t_tm.tot_m6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m7), Space(5)+'0', Str(t_tm.tot_m7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.totalm), Space(5)+'0', Str(t_tm.totalm, 6, 0)) 
			Otherwise	
				m.group =   Space(18) + Iif(Isnull(t_tm.desc), '', t_tm.desc) + ;
							Space(4) + Iif(Isnull(t_tm.tot_m1), Space(5)+'0', Str(t_tm.tot_m1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m2), Space(5)+'0', Str(t_tm.tot_m2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m3), Space(5)+'0', Str(t_tm.tot_m3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m4), Space(5)+'0', Str(t_tm.tot_m4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m5), Space(5)+'0', Str(t_tm.tot_m5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m6), Space(5)+'0', Str(t_tm.tot_m6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m7), Space(5)+'0', Str(t_tm.tot_m7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.totalm), Space(5)+'0', Str(t_tm.totalm, 6, 0)) 
		Endcase	
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_tm.tot_m1, 6, 0) + "," + Str(t_tm.tot_m2, 6, 0) + ;
		 "," + Str(t_tm.tot_m3, 6, 0) + "," + Str(t_tm.tot_m4, 6, 0) + ;
		 "," + Str(t_tm.tot_m5, 6, 0) + "," + Str(t_tm.tot_m6, 6, 0) + ;
		 "," + Str(t_tm.tot_m7, 6, 0) + "," + Str(t_tm.totalm, 6, 0)
		IF i=1	
			m.RHMOFEMALE=mrow
		ENDIF
		IF i=2	
			m.RHMOMALE =mrow
		ENDIF
		IF i=3
			m.RHMOTRANS=mrow
		ENDIF
		IF i=4
			m.RHMOUNK=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tm	
Use in t_tm1

** Unknown/Unreported
If Used('t_tu1')
   Use In t_tu1
Endif
    
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_u1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_u2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_u3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_u4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_u5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_u6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_u7, ;
		Count(*) AS totalu ;
	From all_t3 , t_gen ;
	Where	all_t3.hispanic = 2 and (((all_t3.unknowrep = 1 or all_t3.someother = 1) and ;
			all_t3.white + all_t3.blafrican + all_t3.asian + all_t3.hawaisland + all_t3.indialaska = 0) ;
			or (all_t3.white + all_t3.blafrican + all_t3.asian + all_t3.hawaisland + all_t3.indialaska + all_t3.unknowrep + all_t3.someother = 0)) and ;
			 all_t3.gender = t_gen.gender ;	
	Group by 1;
	Into Cursor t_tu1
	
If Used('t_tu')
   Use In t_tu
Endif

	Select * ;
	From t_tu1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_u1, 0 as tot_u2, 0 as tot_u3, ;
			0 as tot_u4, 0 as tot_u5, 0 as tot_u6, ;
			0 as tot_u7, 0 AS totalu ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tu1.desc From t_tu1) ;
	Group by 1 ;		
	Into Cursor t_tu Order by 1
	
	Select t_tu
	i = 1
	Scan
		Do Case
			Case i = 2
				m.group =   " Not reported " + Space(4) + Iif(Isnull(t_tu.desc), '', t_tu.desc) + ; 
							Space(4) + Iif(Isnull(t_tu.tot_u1), Space(5)+'0', Str(t_tu.tot_u1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u2), Space(5)+'0', Str(t_tu.tot_u2, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tu.tot_u3), Space(5)+'0', Str(t_tu.tot_u3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u4), Space(5)+'0', Str(t_tu.tot_u4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tu.tot_u5), Space(5)+'0', Str(t_tu.tot_u5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u6), Space(5)+'0', Str(t_tu.tot_u6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tu.tot_u7), Space(5)+'0', Str(t_tu.tot_u7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.totalu), Space(5)+'0', Str(t_tu.totalu, 6, 0)) 
			Case i = 3
				m.group =   "               " + Space(3) + iif(Isnull(t_tu.desc), '', t_tu.desc) + ; 
							Space(4) + Iif(Isnull(t_tu.tot_u1), Space(5)+'0', Str(t_tu.tot_u1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u2), Space(5)+'0', Str(t_tu.tot_u2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u3), Space(5)+'0', Str(t_tu.tot_u3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u4), Space(5)+'0', Str(t_tu.tot_u4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u5), Space(5)+'0', Str(t_tu.tot_u5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u6), Space(5)+'0', Str(t_tu.tot_u6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u7), Space(5)+'0', Str(t_tu.tot_u7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.totalu), Space(5)+'0', Str(t_tu.totalu, 6, 0)) 
			Otherwise	
				m.group =   Space(18) + iif(Isnull(t_tu.desc), '', t_tu.desc) + ; 
							Space(4) + Iif(Isnull(t_tu.tot_u1), Space(5)+'0', Str(t_tu.tot_u1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u2), Space(5)+'0', Str(t_tu.tot_u2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u3), Space(5)+'0', Str(t_tu.tot_u3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u4), Space(5)+'0', Str(t_tu.tot_u4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u5), Space(5)+'0', Str(t_tu.tot_u5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u6), Space(5)+'0', Str(t_tu.tot_u6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u7), Space(5)+'0', Str(t_tu.tot_u7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.totalu), Space(5)+'0', Str(t_tu.totalu, 6, 0)) 
		Endcase	
		Insert Into cadr_tmp From Memvar 
* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_tu.tot_u1, 6, 0) + "," + Str(t_tu.tot_u2, 6, 0) + ;
							"," + Str(t_tu.tot_u3, 6, 0) + "," + Str(t_tu.tot_u4, 6, 0) + ;
							"," + Str(t_tu.tot_u5, 6, 0) + "," + Str(t_tu.tot_u6, 6, 0) + ;
							"," + Str(t_tu.tot_u7, 6, 0) + "," + Str(t_tu.totalu, 6, 0)
		IF i=1	
			m.RHUNFEMALE=mrow
		ENDIF
		IF i=2	
			m.RHUNMALE =mrow
		ENDIF
		IF i=3
			m.RHUNTRANS=mrow
		ENDIF
		IF i=4
			m.RHUNUNK=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tu	
Use in t_tu1

** Total
If Used('t_tt1') 
   Use In t_tt1
Endif
   
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_t1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_t2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_t3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_t4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_t5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_t6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_t7, ;
		Count(*) AS totalt ;
	From all_t3 , t_gen ;
	Where all_t3.gender = t_gen.gender ;
         And all_t3.hispanic = 2;
	Group by 1;
	Into Cursor t_tt1

If Used('t_tt') 
   Use In t_tt
Endif
	
	Select * ;
	From t_tt1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_t1, 0 as tot_t2, 0 as tot_t3, ;
			0 as tot_t4, 0 as tot_t5, 0 as tot_t6, ;
			0 as tot_t7, 0 AS totalt ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tt1.desc From t_tt1) ;
	Group by 1 ;		
	Into Cursor t_tt Order by 1
	
	Select t_tt
	i = 1
	Scan
		If i =2
				m.group =   " Total        " + Space(4) + iif(Isnull(t_tt.desc), '', t_tt.desc) + ; 
							Space(4) + Iif(Isnull(t_tt.tot_t1), Space(5)+'0', Str(t_tt.tot_t1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t2), Space(5)+'0', Str(t_tt.tot_t2, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tt.tot_t3), Space(5)+'0', Str(t_tt.tot_t3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t4), Space(5)+'0', Str(t_tt.tot_t4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tt.tot_t5), Space(5)+'0', Str(t_tt.tot_t5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t6), Space(5)+'0', Str(t_tt.tot_t6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_tt.tot_t7), Space(5)+'0', Str(t_tt.tot_t7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.totalt), Space(5)+'0', Str(t_tt.totalt, 6, 0)) 
		Else
				m.group =   Space(18) + iif(Isnull(t_tt.desc), '', t_tt.desc) + ; 
							Space(4) + Iif(Isnull(t_tt.tot_t1), Space(5)+'0', Str(t_tt.tot_t1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t2), Space(5)+'0', Str(t_tt.tot_t2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t3), Space(5)+'0', Str(t_tt.tot_t3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t4), Space(5)+'0', Str(t_tt.tot_t4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t5), Space(5)+'0', Str(t_tt.tot_t5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t6), Space(5)+'0', Str(t_tt.tot_t6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t7), Space(5)+'0', Str(t_tt.tot_t7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.totalt), Space(5)+'0', Str(t_tt.totalt, 6, 0)) 
		EndIf
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_tt.tot_t1, 6, 0) + "," + Str(t_tt.tot_t2, 6, 0) + ;
		 "," + Str(t_tt.tot_t3, 6, 0) + "," + Str(t_tt.tot_t4, 6, 0) + ;
		 "," + Str(t_tt.tot_t5, 6, 0) + "," + Str(t_tt.tot_t6, 6, 0) + ;
		 "," + Str(t_tt.tot_t7, 6, 0) + "," + Str(t_tt.totalt, 6, 0)
		IF i=1	
			m.RHTFEMALE=mrow
		ENDIF
		IF i=2	
			m.RHTMALE=mrow
		ENDIF
		IF i=3
			m.RHTTRANS=mrow
		ENDIF
		IF i=4
			m.RHTUNK=mrow
		ENDIF
		
		i= i+1
	EndScan
* 3 lines to get to next page 
*   m.group= " " + chr(13) + " " + chr(13) + " " + chr(13)
*   Insert Into cadr_tmp From Memvar   

   Use in t_tt	
   Use in t_tt1

*!*  q59 B.
* PB 12/2008 Hispanic in section a
* jss, 11/29/07, add page_ej
   m.page_ej=2
   m.group = "59.  Number of patients who are HIV+/indeterminate for this reporting period by race, gender, & age"+Chr(13)+;
             "b.   Number of NON-HISPANIC clients."
   
   m.info = 59
   Insert Into cadr_tmp From Memvar
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
   m.group = REPL('³',1) + "       Race     " + REPL('³',1) + "   Gender   " + REPL('³',1) + ;
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

If Used('t_gen') 
   Use In t_gen
Endif

Create Cursor t_gen (desc C(11), gender C(2))
Insert Into t_gen (desc, gender) Values("Female", "10")
Insert Into t_gen (desc, gender) Values("Male", "11")
Insert Into t_gen (desc, gender) Values("Transgender", "12")
Insert Into t_gen (desc, gender) Values("Transgender", "13")
Insert Into t_gen (desc, gender) Values("Unknown/Unr", "  ")

** American Indian
If Used('t_ti1')
   Use In t_ti1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_i1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_i2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_i3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_i4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_i5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_i6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_i7, ;
      Count(*) AS totali ;
   From all_t3 , t_gen ;
   Where all_t3.indialaska = 1 and all_t3.hispanic <> 2 and ;
         (all_t3.blafrican + all_t3.asian + all_t3.white + ;
          all_t3.hawaisland + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_ti1

If Used('t_ti')
   Use In t_ti
Endif
   
   Select * ;
   From t_ti1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_i1, 0 as tot_i2, 0 as tot_i3, ;
         0 as tot_i4, 0 as tot_i5, 0 as tot_i6, ;
         0 as tot_i7, 0 AS totali ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_ti1.desc From t_ti1) ;
   Group by 1 ;      
   Into Cursor t_ti Order by 1
   
   Select t_ti
   i = 1
   Scan
      mrow = Str(t_ti.tot_i1, 6, 0) + "," + Str(t_ti.tot_i2, 6, 0) + ;
       "," + Str(t_ti.tot_i3, 6, 0) + "," + Str(t_ti.tot_i4, 6, 0) + ;
       "," + Str(t_ti.tot_i5, 6, 0) + "," + Str(t_ti.tot_i6, 6, 0) + ;
       "," + Str(t_ti.tot_i7, 6, 0) + "," + Str(t_ti.totali, 6, 0)

      Do Case
         Case i = 1
            m.group =   " American      " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0)) 
      * jss, 6/3/03, define memvars for extract's section 6 
            m.rinfemale=mrow
         Case i = 2            
            m.group =   " Indian/       " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rinmale=mrow
         Case i = 3
            m.group =   " Alaskan       " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rintrans=mrow
         Otherwise   
            m.group =   " Native        " + Space(3) + Iif(Isnull(t_ti.desc), '', t_ti.desc) + ;
                     Space(4) + Iif(Isnull(t_ti.tot_i1), Space(5)+'0', Str(t_ti.tot_i1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i2), Space(5)+'0', Str(t_ti.tot_i2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i3), Space(5)+'0', Str(t_ti.tot_i3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i4), Space(5)+'0', Str(t_ti.tot_i4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i5), Space(5)+'0', Str(t_ti.tot_i5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i6), Space(5)+'0', Str(t_ti.tot_i6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.tot_i7), Space(5)+'0', Str(t_ti.tot_i7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ti.totali), Space(5)+'0', Str(t_ti.totali, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rinunk=mrow
      Endcase   
      Insert Into cadr_tmp From Memvar
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_ti   
Use in t_ti1

** Asian
If Used('t_ta1')
   Use In t_ta1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_a1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_a2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_a3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_a4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_a5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_a6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_a7, ;
      Count(*) AS totala ;
   From all_t3 , t_gen ;
   Where all_t3.asian = 1 and all_t3.hispanic <> 2 and ;
         (all_t3.white + all_t3.blafrican + all_t3.hawaisland + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_ta1
   
If Used('t_ta')
   Use In t_ta
Endif

   Select * ;
   From t_ta1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_a1, 0 as tot_a2, 0 as tot_a3, ;
         0 as tot_a4, 0 as tot_a5, 0 as tot_a6, ;
         0 as tot_a7, 0 AS totala ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_ta1.desc From t_ta1) ;
   Group by 1 ;      
   Into Cursor t_ta Order by 1
   
   Select t_ta
   i = 1
   Scan
      mrow = Str(t_ta.tot_a1, 6, 0) + "," + Str(t_ta.tot_a2, 6, 0) + ;
       "," + Str(t_ta.tot_a3, 6, 0) + "," + Str(t_ta.tot_a4, 6, 0) + ;
       "," + Str(t_ta.tot_a5, 6, 0) + "," + Str(t_ta.tot_a6, 6, 0) + ;
       "," + Str(t_ta.tot_a7, 6, 0) + "," + Str(t_ta.totala, 6, 0)
      If i = 2
            m.group =   " Asian          " + Space(2) + Iif(Isnull(t_ta.desc), '', t_ta.desc) + ;
                     Space(4) + Iif(Isnull(t_ta.tot_a1), Space(5)+'0', Str(t_ta.tot_a1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a2), Space(5)+'0', Str(t_ta.tot_a2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a3), Space(5)+'0', Str(t_ta.tot_a3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a4), Space(5)+'0', Str(t_ta.tot_a4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a5), Space(5)+'0', Str(t_ta.tot_a5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a6), Space(5)+'0', Str(t_ta.tot_a6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a7), Space(5)+'0', Str(t_ta.tot_a7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.totala), Space(5)+'0', Str(t_ta.totala, 6, 0)) 
      Else   
            m.group =   Space(18) + Iif(Isnull(t_ta.desc), '', t_ta.desc) + ;
                     Space(4) + Iif(Isnull(t_ta.tot_a1), Space(5)+'0', Str(t_ta.tot_a1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a2), Space(5)+'0', Str(t_ta.tot_a2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a3), Space(5)+'0', Str(t_ta.tot_a3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a4), Space(5)+'0', Str(t_ta.tot_a4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a5), Space(5)+'0', Str(t_ta.tot_a5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a6), Space(5)+'0', Str(t_ta.tot_a6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.tot_a7), Space(5)+'0', Str(t_ta.tot_a7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_ta.totala), Space(5)+'0', Str(t_ta.totala, 6, 0)) 
      Endif               
      Insert Into cadr_tmp From Memvar 
      
      * jss, 6/3/03, define memvars for extract's section 6 
      IF i=1   
         m.rasfemale=mrow
      ENDIF
      IF i=2   
         m.rasmale=mrow
      ENDIF
      IF i=3
         m.rastrans=mrow
      ENDIF
      IF i=4
         m.rasunk=mrow
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_ta   
Use in t_ta1

***Black   
If Used('t_tb1')
   Use In t_tb1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_b1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_b2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_b3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_b4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_b5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_b6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_b7, ;
      Count(*) AS totalb ;
   From all_t3 , t_gen ;
   Where all_t3.blafrican = 1 and all_t3.hispanic <> 2 and ;
         (all_t3.white + all_t3.asian + all_t3.hawaisland + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tb1

If Used('t_tb')
   Use In t_tb
Endif
   
   Select * ;
   From t_tb1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_b1, 0 as tot_b2, 0 as tot_b3, ;
         0 as tot_b4, 0 as tot_b5, 0 as tot_b6, ;
         0 as tot_b7, 0 AS totalb ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tb1.desc From t_tb1) ;
   Group by 1 ;      
   Into Cursor t_tb Order by 1
      
   Select t_tb
   i = 1
   Scan
      mrow = Str(t_tb.tot_b1, 6, 0) + "," + Str(t_tb.tot_b2, 6, 0) + ;
       "," + Str(t_tb.tot_b3, 6, 0) + "," + Str(t_tb.tot_b4, 6, 0) + ;
       "," + Str(t_tb.tot_b5, 6, 0) + "," + Str(t_tb.tot_b6, 6, 0) + ;
       "," + Str(t_tb.tot_b7, 6, 0) + "," + Str(t_tb.totalb, 6, 0)
      Do Case
         Case i = 1
            m.group =   " Black or        " + Space(1) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.rblfemale=mrow
         Case i = 2
            m.group =   " African        " + Space(2) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) +;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.rblmale=mrow
         Case i = 3
            m.group =   " American       " + Space(2) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.rbltrans=mrow
         Otherwise   
            m.group =   Space(18) + Iif(Isnull(t_tb.desc), '', t_tb.desc) + ;
                     Space(4) + Iif(Isnull(t_tb.tot_b1), Space(5)+'0', Str(t_tb.tot_b1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b2), Space(5)+'0', Str(t_tb.tot_b2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b3), Space(5)+'0', Str(t_tb.tot_b3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b4), Space(5)+'0', Str(t_tb.tot_b4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b5), Space(5)+'0', Str(t_tb.tot_b5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b6), Space(5)+'0', Str(t_tb.tot_b6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.tot_b7), Space(5)+'0', Str(t_tb.tot_b7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tb.totalb), Space(5)+'0', Str(t_tb.totalb, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.rblunk=mrow
      Endcase   
                  
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tb   
Use in t_tb1

***Native Hawaiian   
If Used('t_tn1')
   Use In t_tn1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_n1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_n2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_n3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_n4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_n5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_n6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_n7, ;
      Count(*) AS totaln ;
   From all_t3 , t_gen ;
   Where all_t3.hawaisland = 1 and all_t3.hispanic <> 2 and ;
         (all_t3.blafrican + all_t3.asian + all_t3.white + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tn1

If Used('t_tn')
   Use In t_tn
Endif
   
   Select * ;
   From t_tn1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_n1, 0 as tot_n2, 0 as tot_n3, ;
         0 as tot_n4, 0 as tot_n5, 0 as tot_n6, ;
         0 as tot_n7, 0 AS totaln ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tn1.desc From t_tn1) ;
   Group by 1 ;      
   Into Cursor t_tn Order by 1
   
   Select t_tn
   i = 1
   Scan
      mrow = Str(t_tn.tot_n1, 6, 0) + "," + Str(t_tn.tot_n2, 6, 0) + ;
       "," + Str(t_tn.tot_n3, 6, 0) + "," + Str(t_tn.tot_n4, 6, 0) + ;
       "," + Str(t_tn.tot_n5, 6, 0) + "," + Str(t_tn.tot_n6, 6, 0) + ;
       "," + Str(t_tn.tot_n7, 6, 0) + "," + Str(t_tn.totaln, 6, 0)
      Do Case
         Case i = 1
            m.group =   " Native          " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rnafemale=mrow   
         Case i = 2
            m.group =   " Hawaiian/       " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rnamale=mrow
         Case i = 3
            m.group =   " Pacific         " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rnatrans=mrow
         Otherwise   
            m.group =   " Islander        " + Space(1) + Iif(Isnull(t_tn.desc), '', t_tn.desc) + ;
                     Space(4) + Iif(Isnull(t_tn.tot_n1), Space(5)+'0', Str(t_tn.tot_n1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n2), Space(5)+'0', Str(t_tn.tot_n2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n3), Space(5)+'0', Str(t_tn.tot_n3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n4), Space(5)+'0', Str(t_tn.tot_n4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n5), Space(5)+'0', Str(t_tn.tot_n5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n6), Space(5)+'0', Str(t_tn.tot_n6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.tot_n7), Space(5)+'0', Str(t_tn.tot_n7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tn.totaln), Space(5)+'0', Str(t_tn.totaln, 6, 0))
* jss, 6/3/03, define memvars for extract's section 6 
            m.rnaunk=mrow
      Endcase   
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tn   
Use in t_tn1

***White   
If Used('t_tw1') 
   Use In t_tw1
Endif

   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_w1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_w2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_w3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_w4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_w5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_w6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_w7, ;
      Count(*) AS totalw ;
   From all_t3 , t_gen ;
   Where all_t3.white = 1 and all_t3.hispanic <> 2 and ;
         (all_t3.blafrican + all_t3.asian + all_t3.hawaisland + ;
          all_t3.indialaska + all_t3.someother) = 0 and ;
      all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tw1

If Used('t_tw') 
   Use In t_tw
Endif
   
   Select * ;
   From t_tw1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_w1, 0 as tot_w2, 0 as tot_w3, ;
         0 as tot_w4, 0 as tot_w5, 0 as tot_w6, ;
         0 as tot_w7, 0 AS totalw ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tw1.desc From t_tw1) ;
   Group by 1 ;      
   Into Cursor t_tw Order by 1

   Select t_tw
   i = 1
   Scan
      If i = 2
            m.group =   " White          " + Space(2) + Iif(Isnull(t_tw.desc),'',t_tw.desc) + ;
                     Space(4) + Iif(Isnull(t_tw.tot_w1), Space(5)+'0', Str(t_tw.tot_w1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w2), Space(5)+'0', Str(t_tw.tot_w2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w3), Space(5)+'0', Str(t_tw.tot_w3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w4), Space(5)+'0', Str(t_tw.tot_w4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w5), Space(5)+'0', Str(t_tw.tot_w5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w6), Space(5)+'0', Str(t_tw.tot_w6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w7), Space(5)+'0', Str(t_tw.tot_w7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.totalw), Space(5)+'0', Str(t_tw.totalw, 6, 0)) 

      Else   
            m.group =   Space(18) + Iif(Isnull(t_tw.desc),'',t_tw.desc) + ;
                     Space(4) + Iif(Isnull(t_tw.tot_w1), Space(5)+'0', Str(t_tw.tot_w1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w2), Space(5)+'0', Str(t_tw.tot_w2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w3), Space(5)+'0', Str(t_tw.tot_w3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w4), Space(5)+'0', Str(t_tw.tot_w4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w5), Space(5)+'0', Str(t_tw.tot_w5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w6), Space(5)+'0', Str(t_tw.tot_w6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.tot_w7), Space(5)+'0', Str(t_tw.tot_w7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tw.totalw), Space(5)+'0', Str(t_tw.totalw, 6, 0)) 
      Endif               

      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow =          Str(t_tw.tot_w1, 6, 0) + "," + Str(t_tw.tot_w2, 6, 0) + ;
               "," + Str(t_tw.tot_w3, 6, 0) + "," + Str(t_tw.tot_w4, 6, 0) + ;
               "," + Str(t_tw.tot_w5, 6, 0) + "," + Str(t_tw.tot_w6, 6, 0) + ;
               "," + Str(t_tw.tot_w7, 6, 0) + "," + Str(t_tw.totalw, 6, 0)
      IF i=1   
         m.rwhfemale=mrow
      ENDIF
      IF i=2   
         m.rwhmale=mrow
      ENDIF
      IF i=3
         m.rwhtrans=mrow
      ENDIF
      IF i=4
         m.rwhunk=mrow   
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tw   
Use in t_tw1

*!*   ***Hispanic
*!*   If Used('t_th1')
*!*      Use In t_th1
*!*   Endif
*!*      Select t_gen.desc, ; 
*!*         Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_b1, ;
*!*         Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_b2, ;
*!*         Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_b3, ;
*!*         Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_b4, ;
*!*         Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_b5, ;
*!*         Sum(Iif(cl_age >= 65, 1, 0)) as tot_b6, ;
*!*         Sum(Iif(Empty(dob), 1, 0)) as tot_b7, ;
*!*         Count(*) AS totalb ;
*!*      From all_t3 , t_gen ;
*!*      Where all_t3.hispanic = 2 and ;
*!*         all_t3.gender = t_gen.gender ;   
*!*      Group by 1;
*!*      Into Cursor t_th1
   
*!*   If Used('t_th')
*!*      Use In t_th
*!*   Endif
*!*      
*!*      Select * ;
*!*      From t_th1 ;    
*!*      Union ;
*!*      Select t_gen.desc, ; 
*!*            0 as tot_b1, 0 as tot_b2, 0 as tot_b3, ;
*!*            0 as tot_b4, 0 as tot_b5, 0 as tot_b6, ;
*!*            0 as tot_b7, 0 AS totalb ;
*!*      From  t_gen ;
*!*      Where t_gen.desc not in (Select distinct t_th1.desc From t_th1) ;
*!*      Group by 1 ;      
*!*      Into Cursor t_th Order by 1
*!*      
*!*      Select t_th
*!*      i = 1
*!*      Scan
*!*         mrow = Str(t_th.tot_b1, 6, 0) + "," + Str(t_th.tot_b2, 6, 0) + ;
*!*          "," + Str(t_th.tot_b3, 6, 0) + "," + Str(t_th.tot_b4, 6, 0) + ;
*!*          "," + Str(t_th.tot_b5, 6, 0) + "," + Str(t_th.tot_b6, 6, 0) + ;
*!*          "," + Str(t_th.tot_b7, 6, 0) + "," + Str(t_th.totalb, 6, 0)
*!*         Do Case
*!*            Case i = 1
*!*               m.group =   " Hispanic        " + Space(1) + Iif(Isnull(t_th.desc), '', t_th.desc) + ;
*!*                        Space(4) + Iif(Isnull(t_th.tot_b1), Space(5)+'0', Str(t_th.tot_b1, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b2), Space(5)+'0', Str(t_th.tot_b2, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b3), Space(5)+'0', Str(t_th.tot_b3, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b4), Space(5)+'0', Str(t_th.tot_b4, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b5), Space(5)+'0', Str(t_th.tot_b5, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b6), Space(5)+'0', Str(t_th.tot_b6, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b7), Space(5)+'0', Str(t_th.tot_b7, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.totalb), Space(5)+'0', Str(t_th.totalb, 6, 0)) 
*!*    * jss, 6/3/03, define memvars for extract's section 6 
*!*               m.rhfemale=mrow
*!*            Case i = 2
*!*               m.group =   "    or          " + Space(2) + Iif(Isnull(t_th.desc), '', t_th.desc) + ;
*!*                        Space(4) + Iif(Isnull(t_th.tot_b1), Space(5)+'0', Str(t_th.tot_b1, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b2), Space(5)+'0', Str(t_th.tot_b2, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b3), Space(5)+'0', Str(t_th.tot_b3, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b4), Space(5)+'0', Str(t_th.tot_b4, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b5), Space(5)+'0', Str(t_th.tot_b5, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b6), Space(5)+'0', Str(t_th.tot_b6, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b7), Space(5)+'0', Str(t_th.tot_b7, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.totalb), Space(5)+'0', Str(t_th.totalb, 6, 0)) 

*!*    jss, 6/3/03, define memvars for extract's section 6 
*!*            m.rhmale=mrow
*!*            Case i = 3
*!*               m.group =   " Latino(a)      " + Space(2) + Iif(Isnull(t_th.desc), '', t_th.desc) + ;
*!*                        Space(4) + Iif(Isnull(t_th.tot_b1), Space(5)+'0', Str(t_th.tot_b1, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b2), Space(5)+'0', Str(t_th.tot_b2, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b3), Space(5)+'0', Str(t_th.tot_b3, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b4), Space(5)+'0', Str(t_th.tot_b4, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b5), Space(5)+'0', Str(t_th.tot_b5, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b6), Space(5)+'0', Str(t_th.tot_b6, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b7), Space(5)+'0', Str(t_th.tot_b7, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.totalb), Space(5)+'0', Str(t_th.totalb, 6, 0)) 
*!*    * jss, 6/3/03, define memvars for extract's section 6 
*!*               m.rhtrans=mrow
*!*            Otherwise   
*!*               m.group =   Space(18) + Iif(Isnull(t_th.desc), '', t_th.desc) + ;
*!*                        Space(4) + Iif(Isnull(t_th.tot_b1), Space(5)+'0', Str(t_th.tot_b1, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b2), Space(5)+'0', Str(t_th.tot_b2, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b3), Space(5)+'0', Str(t_th.tot_b3, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b4), Space(5)+'0', Str(t_th.tot_b4, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b5), Space(5)+'0', Str(t_th.tot_b5, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b6), Space(5)+'0', Str(t_th.tot_b6, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.tot_b7), Space(5)+'0', Str(t_th.tot_b7, 6, 0)) + ;
*!*                        Space(3) + Iif(Isnull(t_th.totalb), Space(5)+'0', Str(t_th.totalb, 6, 0)) 
*!*   * jss, 6/3/03, define memvars for extract's section 6 
*!*               m.rhunk=mrow
*!*         Endcase   
*!*                     
*!*         Insert Into cadr_tmp From Memvar 
*!*         i= i+1
*!*      EndScan
*!*      
*!*      m.group = REPL('Ä',103)  
*!*      Insert Into cadr_tmp From Memvar
*!*      
*!*   Use in t_th
*!*   Use in t_th1

***More Than 1 race
If Used('t_tm1')
   Use In t_tm1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_m1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_m2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_m3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_m4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_m5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_m6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_m7, ;
      Count(*) AS totalm ;
   From all_t3 , t_gen ;
   Where (all_t3.indialaska + all_t3.blafrican + all_t3.asian + all_t3.white + ;
          all_t3.hawaisland + all_t3.someother) > 1 and all_t3.hispanic <> 2 and ;
          all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tm1

If Used('t_tm')
   Use In t_tm
Endif
   
   Select * ;
   From t_tm1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_m1, 0 as tot_m2, 0 as tot_m3, ;
         0 as tot_m4, 0 as tot_m5, 0 as tot_m6, ;
         0 as tot_m7, 0 AS totalm ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tm1.desc From t_tm1) ;
   Group by 1 ;      
   Into Cursor t_tm Order by 1
   
   Select t_tm
   i = 1
   Scan
      Do Case
         Case i = 2
            m.group =   " More than one" + Space(4) + Iif(Isnull(t_tm.desc), '', t_tm.desc) + ;
                     Space(4) + Iif(Isnull(t_tm.tot_m1), Space(5)+'0', Str(t_tm.tot_m1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m2), Space(5)+'0', Str(t_tm.tot_m2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m3), Space(5)+'0', Str(t_tm.tot_m3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m4), Space(5)+'0', Str(t_tm.tot_m4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m5), Space(5)+'0', Str(t_tm.tot_m5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m6), Space(5)+'0', Str(t_tm.tot_m6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m7), Space(5)+'0', Str(t_tm.tot_m7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.totalm), Space(5)+'0', Str(t_tm.totalm, 6, 0)) 
         Case i = 3
            m.group =   " race          " + Space(3) + Iif(Isnull(t_tm.desc), '', t_tm.desc) + ;
                     Space(4) + Iif(Isnull(t_tm.tot_m1), Space(5)+'0', Str(t_tm.tot_m1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m2), Space(5)+'0', Str(t_tm.tot_m2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m3), Space(5)+'0', Str(t_tm.tot_m3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m4), Space(5)+'0', Str(t_tm.tot_m4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m5), Space(5)+'0', Str(t_tm.tot_m5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m6), Space(5)+'0', Str(t_tm.tot_m6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m7), Space(5)+'0', Str(t_tm.tot_m7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.totalm), Space(5)+'0', Str(t_tm.totalm, 6, 0)) 
         Otherwise   
            m.group =   Space(18) + Iif(Isnull(t_tm.desc), '', t_tm.desc) + ;
                     Space(4) + Iif(Isnull(t_tm.tot_m1), Space(5)+'0', Str(t_tm.tot_m1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m2), Space(5)+'0', Str(t_tm.tot_m2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m3), Space(5)+'0', Str(t_tm.tot_m3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m4), Space(5)+'0', Str(t_tm.tot_m4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m5), Space(5)+'0', Str(t_tm.tot_m5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m6), Space(5)+'0', Str(t_tm.tot_m6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.tot_m7), Space(5)+'0', Str(t_tm.tot_m7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tm.totalm), Space(5)+'0', Str(t_tm.totalm, 6, 0)) 
      Endcase   
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_tm.tot_m1, 6, 0) + "," + Str(t_tm.tot_m2, 6, 0) + ;
       "," + Str(t_tm.tot_m3, 6, 0) + "," + Str(t_tm.tot_m4, 6, 0) + ;
       "," + Str(t_tm.tot_m5, 6, 0) + "," + Str(t_tm.tot_m6, 6, 0) + ;
       "," + Str(t_tm.tot_m7, 6, 0) + "," + Str(t_tm.totalm, 6, 0)
      IF i=1   
         m.rmofemale=mrow
      ENDIF
      IF i=2   
         m.rmomale=mrow
      ENDIF
      IF i=3
         m.rmotrans=mrow
      ENDIF
      IF i=4
         m.rmounk=mrow
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tm   
Use in t_tm1

***Unknown/Unreported
If Used('t_tu1')
   Use In t_tu1
Endif
    
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_u1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_u2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_u3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_u4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_u5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_u6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_u7, ;
      Count(*) AS totalu ;
   From all_t3 , t_gen ;
   Where   all_t3.hispanic <> 2 and (((all_t3.unknowrep = 1 or all_t3.someother = 1) and ;
         all_t3.white + all_t3.blafrican + all_t3.asian + all_t3.hawaisland + all_t3.indialaska = 0) ;
         or (all_t3.white + all_t3.blafrican + all_t3.asian + all_t3.hawaisland + all_t3.indialaska + all_t3.unknowrep + all_t3.someother = 0)) and ;
          all_t3.gender = t_gen.gender ;   
   Group by 1;
   Into Cursor t_tu1
   
If Used('t_tu')
   Use In t_tu
Endif

   Select * ;
   From t_tu1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_u1, 0 as tot_u2, 0 as tot_u3, ;
         0 as tot_u4, 0 as tot_u5, 0 as tot_u6, ;
         0 as tot_u7, 0 AS totalu ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tu1.desc From t_tu1) ;
   Group by 1 ;      
   Into Cursor t_tu Order by 1
   
   Select t_tu
   i = 1
   Scan
      Do Case
         Case i = 2
            m.group =   " Not reported " + Space(4) + Iif(Isnull(t_tu.desc), '', t_tu.desc) + ; 
                     Space(4) + Iif(Isnull(t_tu.tot_u1), Space(5)+'0', Str(t_tu.tot_u1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u2), Space(5)+'0', Str(t_tu.tot_u2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u3), Space(5)+'0', Str(t_tu.tot_u3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u4), Space(5)+'0', Str(t_tu.tot_u4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u5), Space(5)+'0', Str(t_tu.tot_u5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u6), Space(5)+'0', Str(t_tu.tot_u6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u7), Space(5)+'0', Str(t_tu.tot_u7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.totalu), Space(5)+'0', Str(t_tu.totalu, 6, 0)) 
         Case i = 3
            m.group =   "               " + Space(3) + iif(Isnull(t_tu.desc), '', t_tu.desc) + ; 
                     Space(4) + Iif(Isnull(t_tu.tot_u1), Space(5)+'0', Str(t_tu.tot_u1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u2), Space(5)+'0', Str(t_tu.tot_u2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u3), Space(5)+'0', Str(t_tu.tot_u3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u4), Space(5)+'0', Str(t_tu.tot_u4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u5), Space(5)+'0', Str(t_tu.tot_u5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u6), Space(5)+'0', Str(t_tu.tot_u6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u7), Space(5)+'0', Str(t_tu.tot_u7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.totalu), Space(5)+'0', Str(t_tu.totalu, 6, 0)) 
         Otherwise   
            m.group =   Space(18) + iif(Isnull(t_tu.desc), '', t_tu.desc) + ; 
                     Space(4) + Iif(Isnull(t_tu.tot_u1), Space(5)+'0', Str(t_tu.tot_u1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u2), Space(5)+'0', Str(t_tu.tot_u2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u3), Space(5)+'0', Str(t_tu.tot_u3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u4), Space(5)+'0', Str(t_tu.tot_u4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u5), Space(5)+'0', Str(t_tu.tot_u5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u6), Space(5)+'0', Str(t_tu.tot_u6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.tot_u7), Space(5)+'0', Str(t_tu.tot_u7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tu.totalu), Space(5)+'0', Str(t_tu.totalu, 6, 0)) 
      Endcase   
      Insert Into cadr_tmp From Memvar 
* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_tu.tot_u1, 6, 0) + "," + Str(t_tu.tot_u2, 6, 0) + ;
                     "," + Str(t_tu.tot_u3, 6, 0) + "," + Str(t_tu.tot_u4, 6, 0) + ;
                     "," + Str(t_tu.tot_u5, 6, 0) + "," + Str(t_tu.tot_u6, 6, 0) + ;
                     "," + Str(t_tu.tot_u7, 6, 0) + "," + Str(t_tu.totalu, 6, 0)
      IF i=1   
         m.runfemale=mrow
      ENDIF
      IF i=2   
         m.runmale=mrow
      ENDIF
      IF i=3
         m.runtrans=mrow
      ENDIF
      IF i=4
         m.rununk=mrow
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
* 3 lines to get to next page 
*   m.group= " " + chr(13) + " " + chr(13) + " " + chr(13)
*   Insert Into cadr_tmp From Memvar   

Use in t_tu   
Use in t_tu1

***Total
If Used('t_tt1') 
   Use In t_tt1
Endif
   
   Select t_gen.desc, ; 
      Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_t1, ;
      Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_t2, ;
      Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_t3, ;
      Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_t4, ;
      Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_t5, ;
      Sum(Iif(cl_age >= 65, 1, 0)) as tot_t6, ;
      Sum(Iif(Empty(dob), 1, 0)) as tot_t7, ;
      Count(*) AS totalt ;
   From all_t3 , t_gen ;
   Where all_t3.gender = t_gen.gender ;   
         And all_t3.hispanic <> 2;
   Group by 1;
   Into Cursor t_tt1

If Used('t_tt') 
   Use In t_tt
Endif
   
   Select * ;
   From t_tt1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_t1, 0 as tot_t2, 0 as tot_t3, ;
         0 as tot_t4, 0 as tot_t5, 0 as tot_t6, ;
         0 as tot_t7, 0 AS totalt ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tt1.desc From t_tt1) ;
   Group by 1 ;      
   Into Cursor t_tt Order by 1
   
   Select t_tt
   i = 1
   Scan
      If i =2
            m.group =   " Total        " + Space(4) + iif(Isnull(t_tt.desc), '', t_tt.desc) + ; 
                     Space(4) + Iif(Isnull(t_tt.tot_t1), Space(5)+'0', Str(t_tt.tot_t1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t2), Space(5)+'0', Str(t_tt.tot_t2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t3), Space(5)+'0', Str(t_tt.tot_t3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t4), Space(5)+'0', Str(t_tt.tot_t4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t5), Space(5)+'0', Str(t_tt.tot_t5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t6), Space(5)+'0', Str(t_tt.tot_t6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t7), Space(5)+'0', Str(t_tt.tot_t7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.totalt), Space(5)+'0', Str(t_tt.totalt, 6, 0)) 
      Else
            m.group =   Space(18) + iif(Isnull(t_tt.desc), '', t_tt.desc) + ; 
                     Space(4) + Iif(Isnull(t_tt.tot_t1), Space(5)+'0', Str(t_tt.tot_t1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t2), Space(5)+'0', Str(t_tt.tot_t2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t3), Space(5)+'0', Str(t_tt.tot_t3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t4), Space(5)+'0', Str(t_tt.tot_t4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t5), Space(5)+'0', Str(t_tt.tot_t5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t6), Space(5)+'0', Str(t_tt.tot_t6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.tot_t7), Space(5)+'0', Str(t_tt.tot_t7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_tt.totalt), Space(5)+'0', Str(t_tt.totalt, 6, 0)) 
      EndIf
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_tt.tot_t1, 6, 0) + "," + Str(t_tt.tot_t2, 6, 0) + ;
       "," + Str(t_tt.tot_t3, 6, 0) + "," + Str(t_tt.tot_t4, 6, 0) + ;
       "," + Str(t_tt.tot_t5, 6, 0) + "," + Str(t_tt.tot_t6, 6, 0) + ;
       "," + Str(t_tt.tot_t7, 6, 0) + "," + Str(t_tt.totalt, 6, 0)
      IF i=1   
         m.rtfemale=mrow
      ENDIF
      IF i=2   
         m.rtmale=mrow
      ENDIF
      IF i=3
         m.rttrans=mrow
      ENDIF
      IF i=4
         m.rtunk=mrow
      ENDIF
      
      i= i+1
   EndScan
Use in t_tt   
Use in t_tt1
Use in all_t3
***********************************


***********************************
*---Q60
*** For transfer to next page
*!*   	m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13)					
* jss, 11/29/07, add page_ej
   m.page_ej=3
	m.info = 60

* first, select everything up to the second subselect above, adding in the relhist fields we will need
   Select Distinct all_h35a.tc_id, all_h35a.gender, all_h35a.dob, all_h35a.cl_age, ;
               all_h35a.white, all_h35a.blafrican, all_h35a.asian, all_h35a.hawaisland, ;
               all_h35a.indialaska, all_h35a.unknowrep, all_h35a.someother, all_h35a.hispanic, ;
               relhist.rw_code, relhist.date, relhist.dt, relhist.tm ;
   From all_h35a, relhist ;
   Where all_h35a.elig_type = "01" and ;
         (all_h35a.fund_type ="03" Or all_h35a.fund_type="13") and ;
           (all_h35a.hiv_pos = .t. or all_h35a.tc_id in (Select tc_id from t_indet)) and ;
         relhist.tc_id = all_h35a.tc_id ;
   Into Cursor SubCurs1

If Used('SubCurs2')
   Use In SubCurs2
Endif

* next, create a cursor from the relhist subselect...
   Select tc_id + Max(Dtos(date) + Dtos(dt) + tm + rw_code) as max_exp;
                                       From ;
                                          relhist ;
                                       Where ;
                                          date <= m.end_dt Group by tc_id ;
   Into Cursor SubCurs2

If Used('all_hiv1')
   Use In all_hiv1
Endif

* next, grab everything from subcurs1 that is found in subcurs2
   Select tc_id, gender, dob, cl_age, ;
               white, blafrican, asian, hawaisland, ;
               indialaska, unknowrep, someother, hispanic, ;
               rw_code ;
   from SubCurs1 ;
   Where tc_id + Dtos(Date) + Dtos(Dt) + tm + rw_code ;
      In (Select max_exp From SubCurs2) ; 
   Into Cursor ;
      all_hiv1

Use in SubCurs1
Use in SubCurs2

If Used('all_hivp')
   Use In all_hivp
Endif

   Select * ;
   From all_hiv1 ;
   Union ;
   Select all_h35a.tc_id, all_h35a.gender, all_h35a.dob, all_h35a.cl_age, ;
               all_h35a.white, all_h35a.blafrican, all_h35a.asian, all_h35a.hawaisland, ;
               all_h35a.indialaska, all_h35a.unknowrep, all_h35a.someother, all_h35a.hispanic,;
               "08" as rw_code ;
   From all_h35a ;
   Where all_h35a.elig_type = "01" and ;
         (all_h35a.fund_type ="03" Or all_h35a.fund_type="13") and ;
           (all_h35a.hiv_pos = .t. or all_h35a.tc_id in (Select tc_id from t_indet)) and ;
           all_h35a.tc_id Not in (Select Distinct tc_id From relhist Where date <= m.end_dt) ;      
   Into Cursor all_hivp

Use in all_hiv1
*!* 12/2008 For 2008 RDR part a Hispanics.

   * jss, 11/22/07, Title III becomes Part C for 2007:   m.part    = "Part 6.1. Title III Information"
   m.part    = "Part 6.1. Part C Information"
   m.group = "60.  Number of patients who are HIV+/indeterminate during this reporting period by HIV exposure " + CHR(13) + ;
              "     category, gender, and race." +Chr(13)+;
             "a.   Number of HISPANIC clients."
             
   Insert Into cadr_tmp From Memvar
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
   m.group = REPL('³',1) + Space(13) + Repl('³',1) + Space(6) + REPL('³',1) + ;
            "        " + REPL('³',1) + "Black or" + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + ;
            " Native " + REPL('³',1) + "American" + REPL('³',1) + "  More  " + REPL('³',1) + ;
            "  Race  " + REPL('³',1) + "        "   + REPL('³',1)
   Insert Into cadr_tmp From Memvar
   
   m.group = REPL('³',1) + "HIV Exposure " + REPL('³',1) + "Gender" + REPL('³',1) + ;
            "  White " + REPL('³',1) + "African " + REPL('³',1) + "        " + REPL('³',1) + " Asian  " + REPL('³',1) + ;
            "Hawaiian" + REPL('³',1) + "Indian/ " + REPL('³',1) + "  than  " + REPL('³',1) + ;
            " Unknown" + REPL('³',1) + " Total  " + REPL('³',1)
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('³',1) + "  Category   " + REPL('³',1) + Space(6) + REPL('³',1) + ;
            "        " + REPL('³',1) + "American" + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + ;
            "/Pacific" + REPL('³',1) + "Alaskan " + REPL('³',1) + "  one   " + REPL('³',1) + ;
            "        " + REPL('³',1) + "        " + REPL('³',1)
   Insert Into cadr_tmp From Memvar 
   
   m.group = REPL('³',1) + Space(13) + REPL('³',1) + Space(6) + REPL('³',1) + ;
            "        " + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + ;
            "Islander" + REPL('³',1) + "Native  " + REPL('³',1) + "  race  " + REPL('³',1) + ;
            "        " + REPL('³',1) + "        " + REPL('³',1)
   Insert Into cadr_tmp From Memvar 
         
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar

   Use in t_gen
* jss, 3/31/05, use 6 char gender descriptions in order to squeeze hispanic into report
   Create Cursor t_gen (desc C(6), gender C(2))

   Insert Into   t_gen (desc, gender) ;
         Values("Male", "11")
   Insert Into   t_gen (desc, gender) ;
         Values("Female", "10")                                                   
   Insert Into   t_gen (desc, gender) ;
         Values("Transg", "12")            
   Insert Into   t_gen (desc, gender) ;
         Values("Transg", "13")            
   Insert Into   t_gen (desc, gender) ;
         Values("Unknwn", "  ")            

If Used('SubCurs1')
   Use In SubCurs1
Endif

***Men who have sex with men
If Used('t_tot1')
   Use In t_tot1
Endif

   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2 , 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "02" and ;
        all_hivp.hispanic = 2 And;
        all_hivp.gender = t_gen.gender and ;
        (t_gen.gender = "11" or t_gen.gender = "12" or t_gen.gender = "13") ;
   Group by 1;
   Into Cursor t_tot1

If Used('t_total')
   Use In t_total
Endif
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
   Scan
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)   

                    
      If alltrim(t_total.desc) = "Female"
            m.group =   "Men who have " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMSMFEMLE=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
                     
      EndIf
      If alltrim(t_total.desc) = "Male"
            m.group =   "sex with men " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMSMMALE=mrow   
                     
      Endif
      
      If alltrim(t_total.desc) = "Transg" 
            m.group =   "   (MSM)     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMSMTRANS=mrow
      Endif
      
      If alltrim(t_total.desc) = "Unknwn"
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)
* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMSMUNK=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)

      EndIf
                     
      Insert Into cadr_tmp From Memvar 
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Injection drug user (IDU)
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "03";
          And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic = 2;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
   i = 1
   Scan
      Do Case
         Case i = 1
            m.group =   "Injection    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

         Case i = 2
            m.group =   "Drug User(IDU)" + Space(1) +iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
      Otherwise
      
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
      EndCase
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
      IF i=1   
         m.EHIDUFEMLE=mrow
      ENDIF
      IF i=2   
         m.EHIDUMALE=mrow
      ENDIF
      IF i=3
         m.EHIDUTRANS=mrow
      ENDIF
      IF i=4
         m.EHIDUUNK=mrow
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***MSM and IDU
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "01" ;
         And all_hivp.gender = t_gen.gender;
         And all_hivp.hispanic = 2;
         And (t_gen.gender = "11" or t_gen.gender = "12" or t_gen.gender = "13") ;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total

   Scan
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)

      If alltrim(t_total.desc) = "Female"
            m.group =   Space(15)+ iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMIDFEMLE=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
                     
      EndIf
      If alltrim(t_total.desc) = "Male"
            m.group =   "MSM and IDU  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMIDMALE=mrow
                     
      Endif
      
      If alltrim(t_total.desc) = "Transg" 
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMIDTRANS=mrow
                     
      Endif
      
      If alltrim(t_total.desc) = "Unknwn"
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
                     Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)
* jss, 6/3/03, define memvars for extract's section 6 
            m.EHMIDUNK=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
                     
      EndIf
                     
      Insert Into cadr_tmp From Memvar 
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Hemophilia
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "04" ;
         And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic = 2;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
   i = 1
   Scan
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)

      Do Case
         Case i = 1
            m.group =   "Hemophilia/  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHHEMFEMLE=mrow
                     
         Case i=2
            m.group =   "coagulation  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHHEMMALE=mrow
                     
         Case i=3
            m.group =   "disorder     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHHEMTRANS=mrow
                     
         Otherwise
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
                  
* jss, 6/3/03, define memvars for extract's section 6 
            m.EHHEMUNK=mrow
                     
      EndCase
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Heterosexual contact
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "05" ;
         And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic = 2;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
    i = 1
   Scan
      Do Case
         Case i = 1
            m.group =   "Heterosexual " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Case i=2
            m.group =   "contact      " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Otherwise
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
      EndCase
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)   
      If i=1   
         m.EHHETFEMLE=mrow
      Endif
      
      If  i=2   
         m.EHHETMALE=mrow
      Endif
      
      If i=3
         m.EHHETTRANS=mrow
      Endif
      
      If i=4
         m.EHHETUNK=mrow
      Endif
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Receipt of transfusion of blood
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.hispanic = 2 and all_hivp.white = 1 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.hispanic = 2 and all_hivp.blafrican = 1 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.hispanic = 2 and all_hivp.asian = 1 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hispanic = 2 and all_hivp.hawaisland = 1 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.hispanic = 2 and all_hivp.indialaska = 1 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "06" ;
         And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic = 2;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
   i = 1
   Scan
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
   
      Do Case
         Case i = 1
            m.group =   "Recipient of " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHTRNFEMLE=mrow   

         Case i=2
            m.group =   "transfusion, " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHTRNMALE=mrow

         Case i=3
            m.group =   "blood product" + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0))       

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHTRNTRANS=mrow

         Otherwise
            m.group =   "or tissue    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
            m.EHTRNUNK=mrow

      EndCase
      Insert Into cadr_tmp From Memvar 
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Perinatal transmission
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2 , 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "07";
        And all_hivp.gender = t_gen.gender ;
        And all_hivp.hispanic = 2;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1

   Select t_total
    i = 1
   Scan
      Do Case
         Case i = 1
            m.group =   "Perinatal    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Case i=2
            m.group =   "transmission " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Otherwise
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
      EndCase
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
      IF i=1   
         m.EHPERFEMLE=mrow   
      Endif 
      
      IF i=2   
         m.EHPERMALE=mrow
      Endif 
      
      IF i=3
         m.EHPERTRANS=mrow
      Endif 
      
      IF i=4
         m.EHPERUNK=mrow
      Endif 
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Other
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2 , 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "09" ;
         And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic = 2;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1

   Select t_total
    i = 1
   Scan
      Do Case
         Case i=2
            m.group =   "Other        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Otherwise
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
      EndCase
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
      IF i=1   
         m.EHOTHFEMLE=mrow
      ENDIF
      IF i=2   
         m.EHOTHMALE=mrow
      ENDIF
      IF i=3
         m.EHOTHTRANS=mrow
      ENDIF
      IF i=4
         m.EHOTHUNK=mrow
      ENDIF
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Unknown/Unreported
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where all_hivp.rw_code = "08" ;
         And all_hivp.hispanic = 2;
         And all_hivp.gender = t_gen.gender ;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
    i = 1
   Scan
      Do Case
         Case i = 1
            m.group =   "Unknown/     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Case i=2
            m.group =   "Unreported   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Otherwise
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
      EndCase
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)   
      IF i=1   
         m.EHUNKFEMLE=mrow
      Endif 
      IF i=2   
         m.EHUNKMALE=mrow
      Endif 
      IF i=3
         m.EHUNKTRANS=mrow
      Endif 
      IF i=4
         m.EHUNKUNK=mrow
      Endif 
      
      i= i+1
   EndScan
   
   m.group = REPL('Ä',103)  
   Insert Into cadr_tmp From Memvar
   
Use in t_tot1   
Use in t_total

***Total
   Select t_gen.desc, ; 
      Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
      Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
      Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic = 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
      Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
      Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic = 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                           all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
      Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
                         all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic = 2, 1, 0)) as tot_cat6, ;
      Sum(Iif(all_hivp.hispanic = 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
                        all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska = 0) ;
                        or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
                        all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
      Count(*) AS total ;
   From all_hivp, t_gen ;
   Where  all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic = 2 And ;
         (all_hivp.rw_code = "02" or all_hivp.rw_code = "03" or ;
         all_hivp.rw_code = "01"  or all_hivp.rw_code = "04" or ;
         all_hivp.rw_code = "05"  or all_hivp.rw_code = "06" or ;
         all_hivp.rw_code = "07"  or all_hivp.rw_code = "09" or ;
         all_hivp.rw_code = "08") ;
   Group by 1;
   Into Cursor t_tot1
   
   Select * ;
   From t_tot1 ;    
   Union ;
   Select t_gen.desc, ; 
         0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
         0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
         0 as tot_cat7, 0 AS total ;
   From  t_gen ;
   Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
   Group by 1 ;      
   Into Cursor t_total Order by 1
   
   Select t_total
    i = 1
   Scan
      Do Case
         Case i=2
            m.group =   "Total        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
         Otherwise
            m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0))  
      EndCase
      Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
      mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
       "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
       "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
       "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)   
      If i=1   
         m.EHTFEMLE=mrow   
      Endif 
      
      If i=2   
         m.EHTMALE=mrow
      Endif 
      
      If  i=3
         m.EHTTRANS=mrow
      Endif 
      
      If i=4
         m.EHTUNK=mrow
      Endif 
      
      i= i+1
   EndScan
   
Use in t_tot1   
Use in t_total      

*!* 12/2008 For 2008 RDR part b Non-Hispanics.

   * jss, 11/22/07, Title III becomes Part C for 2007:   m.part    = "Part 6.1. Title III Information"
   m.page_ej=4

   m.part    = "Part 6.1. Part C Information"
	m.group = "60.  Number of patients who are HIV+/indeterminate during this reporting period by HIV exposure " + CHR(13) + ;
    		    "     category, gender, and race." +Chr(13)+;
             "b.   Number of NON-HISPANIC clients."
             
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('³',1) + Space(13) + Repl('³',1) + Space(6) + REPL('³',1) + ;
				"        " + REPL('³',1) + "Black or" + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + ;
				" Native " + REPL('³',1) + "American" + REPL('³',1) + "  More  " + REPL('³',1) + ;
				"  Race  " + REPL('³',1) + "        "	+ REPL('³',1)
	Insert Into cadr_tmp From Memvar
   
	m.group = REPL('³',1) + "HIV Exposure " + REPL('³',1) + "Gender" + REPL('³',1) + ;
				"  White " + REPL('³',1) + "African " + REPL('³',1) + "        " + REPL('³',1) + " Asian  " + REPL('³',1) + ;
				"Hawaiian" + REPL('³',1) + "Indian/ " + REPL('³',1) + "  than  " + REPL('³',1) + ;
				" Unknown" + REPL('³',1) + " Total  " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
   
	m.group = REPL('³',1) + "  Category   " + REPL('³',1) + Space(6) + REPL('³',1) + ;
				"        " + REPL('³',1) + "American" + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + ;
				"/Pacific" + REPL('³',1) + "Alaskan " + REPL('³',1) + "  one   " + REPL('³',1) + ;
				"        " + REPL('³',1) + "        " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
	
	m.group = REPL('³',1) + Space(13) + REPL('³',1) + Space(6) + REPL('³',1) + ;
				"        " + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + "        " + REPL('³',1) + ;
				"Islander" + REPL('³',1) + "Native  " + REPL('³',1) + "  race  " + REPL('³',1) + ;
				"        " + REPL('³',1) + "        " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
			
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

	Use in t_gen
* jss, 3/31/05, use 6 char gender descriptions in order to squeeze hispanic into report
	Create Cursor t_gen (desc C(6), gender C(2))

	Insert Into	t_gen (desc, gender) ;
			Values("Male", "11")
	Insert Into	t_gen (desc, gender) ;
			Values("Female", "10")																	
	Insert Into	t_gen (desc, gender) ;
			Values("Transg", "12")				
	Insert Into	t_gen (desc, gender) ;
			Values("Transg", "13")				
	Insert Into	t_gen (desc, gender) ;
			Values("Unknwn", "  ")				

If Used('SubCurs1')
   Use In SubCurs1
Endif

***Men who have sex with men
If Used('t_tot1')
   Use In t_tot1
Endif

	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2 , 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "02" and ;
        all_hivp.hispanic <> 2 And;
		  all_hivp.gender = t_gen.gender and ;
		  (t_gen.gender = "11" or t_gen.gender = "12" or t_gen.gender = "13") ;
	Group by 1;
	Into Cursor t_tot1

If Used('t_total')
   Use In t_total
Endif
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

                    
		If alltrim(t_total.desc) = "Female"
				m.group =   "Men who have " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
				m.emsmfemale=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
							
		EndIf
		If alltrim(t_total.desc) = "Male"
				m.group =   "sex with men " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.emsmmale=mrow	
							
		Endif
		
		If alltrim(t_total.desc) = "Transg" 
				m.group =   "   (MSM)     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
						   Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.emsmtrans=mrow
		Endif
		
		If alltrim(t_total.desc) = "Unknwn"
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)
* jss, 6/3/03, define memvars for extract's section 6 
				m.emsmunk=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)

		EndIf
							
		Insert Into cadr_tmp From Memvar 
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Injection drug user (IDU)
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "03";
    	   And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic <> 2;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
   i = 1
	Scan
		Do Case
			Case i = 1
				m.group =   "Injection    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

			Case i = 2
				m.group =   "Drug User(IDU)" + Space(1) +iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		Otherwise
		
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
	      				Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
		IF i=1	
			m.eidufemale=mrow
		ENDIF
		IF i=2	
			m.eidumale=mrow
		ENDIF
		IF i=3
			m.eidutrans=mrow
		ENDIF
		IF i=4
			m.eiduunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***MSM and IDU
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "01" ;
		   And all_hivp.gender = t_gen.gender;
         And all_hivp.hispanic <> 2;
		   And (t_gen.gender = "11" or t_gen.gender = "12" or t_gen.gender = "13") ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total

	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)

		If alltrim(t_total.desc) = "Female"
				m.group =   Space(15)+ iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
				m.emidfemale=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
							
		EndIf
		If alltrim(t_total.desc) = "Male"
				m.group =   "MSM and IDU  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Space(06) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.emidmale=mrow
							
		Endif
		
		If alltrim(t_total.desc) = "Transg" 
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							   Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.emidtrans=mrow
							
		Endif
		
		If alltrim(t_total.desc) = "Unknwn"
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)
* jss, 6/3/03, define memvars for extract's section 6 
				m.emidunk=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
							
		EndIf
							
		Insert Into cadr_tmp From Memvar 
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Hemophilia
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "04" ;
		   And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic <> 2;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
   i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)

		Do Case
			Case i = 1
				m.group =   "Hemophilia/  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.ehemfemale=mrow
							
			Case i=2
				m.group =   "coagulation  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.ehemmale=mrow
							
			Case i=3
				m.group =   "disorder     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.ehemtrans=mrow
							
			Otherwise
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
						
* jss, 6/3/03, define memvars for extract's section 6 
				m.ehemunk=mrow
							
		EndCase
		Insert Into cadr_tmp From Memvar 
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Heterosexual contact
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "05" ;
		   And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic <> 2;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		Do Case
			Case i = 1
				m.group =   "Heterosexual " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Case i=2
				m.group =   "contact      " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	
		IF i=1	
			m.ehetfemale=mrow
		ENDIF
		IF i=2	
			m.ehetmale=mrow
		ENDIF
		IF i=3
			m.ehettrans=mrow
		ENDIF
		IF i=4
			m.ehetunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Receipt of transfusion of blood
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.hispanic <> 2 and all_hivp.white = 1 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.hispanic <> 2 and all_hivp.blafrican = 1 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.hispanic <> 2 and all_hivp.asian = 1 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hispanic <> 2 and all_hivp.hawaisland = 1 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.hispanic <> 2 and all_hivp.indialaska = 1 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "06" ;
		   And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic <> 2;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
   i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
	
		Do Case
			Case i = 1
				m.group =   "Recipient of " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.etrnfemale=mrow	

			Case i=2
				m.group =   "transfusion, " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.etrnmale=mrow

			Case i=3
				m.group =   "blood product" + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 		

* jss, 6/3/03, define memvars for extract's section 6 
				m.etrntrans=mrow

			Otherwise
				m.group =   "or tissue    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.etrnunk=mrow

		EndCase
		Insert Into cadr_tmp From Memvar 
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Perinatal transmission
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2 , 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "07";
		  And all_hivp.gender = t_gen.gender ;
        And all_hivp.hispanic <> 2;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1

	Select t_total
    i = 1
	Scan
		Do Case
			Case i = 1
				m.group =   "Perinatal    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Case i=2
				m.group =   "transmission " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
		IF i=1	
			m.eperfemale=mrow	
		ENDIF
		IF i=2	
			m.epermale=mrow
		ENDIF
		IF i=3
			m.epertrans=mrow
		ENDIF
		IF i=4
			m.eperunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Other
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2 , 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "09" ;
		   And all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic <> 2;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1

	Select t_total
    i = 1
	Scan
		Do Case
			Case i=2
				m.group =   "Other        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)
		IF i=1	
			m.eothfemale=mrow
		ENDIF
		IF i=2	
			m.eothmale=mrow
		ENDIF
		IF i=3
			m.eothtrans=mrow
		ENDIF
		IF i=4
			m.eothunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Unknown/Unreported
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "08" ;
         And all_hivp.hispanic <> 2;
		   And all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		Do Case
			Case i = 1
				m.group =   "Unknown/     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Case i=2
				m.group =   "Unreported   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	
		IF i=1	
			m.eunkfemale=mrow	
		ENDIF
		IF i=2	
			m.eunkmale=mrow
		ENDIF
		IF i=3
			m.eunktrans=mrow
		ENDIF
		IF i=4
			m.eunkunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Total
	Select t_gen.desc, ; 
		Sum(Iif(all_hivp.white = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0, 1, 0)) as tot_cat1, ;
		Sum(Iif(all_hivp.blafrican = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.someother) = 0 ,1, 0)) as tot_cat2, ;
		Sum(Iif(all_hivp.asian = 1 and all_hivp.hispanic <> 2 and (all_hivp.white + all_hivp.blafrican + all_hivp.hawaisland + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat3, ;
		Sum(Iif(all_hivp.hawaisland = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.indialaska + all_hivp.someother) = 0,1, 0)) as tot_cat4, ;
		Sum(Iif(all_hivp.indialaska = 1 and all_hivp.hispanic <> 2 and (all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			      				all_hivp.hawaisland + all_hivp.someother) = 0,1, 0)) as tot_cat5, ;
		Sum(Iif((all_hivp.indialaska + all_hivp.blafrican + all_hivp.asian + all_hivp.white + ;
			 					all_hivp.hawaisland + all_hivp.someother) > 1 and all_hivp.hispanic <> 2, 1, 0)) as tot_cat6, ;
		Sum(Iif(all_hivp.hispanic <> 2 and (((all_hivp.unknowrep = 1 or all_hivp.someother = 1) and ;
								all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska = 0) ;
								or (all_hivp.white + all_hivp.blafrican + all_hivp.asian + all_hivp.hawaisland + ;
								all_hivp.indialaska + all_hivp.unknowrep + all_hivp.someother = 0)), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where  all_hivp.gender = t_gen.gender ;
         And all_hivp.hispanic <> 2 And ;
			(all_hivp.rw_code = "02" or all_hivp.rw_code = "03" or ;
			all_hivp.rw_code = "01"  or all_hivp.rw_code = "04" or ;
			all_hivp.rw_code = "05"  or all_hivp.rw_code = "06" or ;
			all_hivp.rw_code = "07"  or all_hivp.rw_code = "09" or ;
			all_hivp.rw_code = "08") ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		Do Case
			Case i=2
				m.group =   "Total        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(15) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                        Space(3) + Space(06) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                        Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0))  
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + "," + Space(06) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	
		IF i=1	
			m.etfemale=mrow	
		ENDIF
		IF i=2	
			m.etmale=mrow
		ENDIF
		IF i=3
			m.ettrans=mrow
		ENDIF
		IF i=4
			m.etunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
Use in t_tot1	
Use in t_total		

*---Q61: formerly question 59 (2004) 
*** For transfer to next page
* jss, 11/22/2007, change m.section and m.part: replace Title with Part, III with C, IV with D:   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
*   m.part    = "Part 6.1. Title III Information"
   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/PART-SPECIFIC DATA FOR PARTS C AND D"
   m.part    = "Part 6.1. Part C Information"
*!*   	m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   				" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ; 
*!*               " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*               " " + CHR(13) + " " + CHR(13)            

* jss, 11/29/07, add page_ej
   m.page_ej=5
	m.info = 61
	m.group = "61.  Number of patients who are HIV+/indeterminate during this reporting period by HIV exposure " + CHR(13) + ;
    		  "     category, gender, and age"
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
	m.group = REPL('³',1) + "  HIV Exposure  " + REPL('³',1) + "   Gender   " + REPL('³',1) + ;
				"  Under " + REPL('³',1) + "  2-12  " + REPL('³',1) + "  13-24 " + REPL('³',1) + ;
				"  25-44 " + REPL('³',1) + "  45-64 " + REPL('³',1) + "65 years" + REPL('³',1) + ;
				"   Age  " + REPL('³',1) + "  Total "	+ REPL('³',1)
	Insert Into cadr_tmp From Memvar 

	m.group = REPL('³',1) + "    Category    " + REPL('³',1) + Space(12) + REPL('³',1) + ;
				" 2 years" + REPL('³',1) + "  years " + REPL('³',1) + "  years " + REPL('³',1) + ;
				"  years " + REPL('³',1) + "  years " + REPL('³',1) + "& older " + REPL('³',1) + ;
				" Unknown" + REPL('³',1) + "        " + REPL('³',1)
	Insert Into cadr_tmp From Memvar 
			
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar

	Use in t_gen
	Create Cursor t_gen (desc C(11), gender C(2))
											
	Insert Into	t_gen (desc, gender) ;
			Values("Male", "11")
	Insert Into	t_gen (desc, gender) ;
			Values("Female", "10")																	
	Insert Into	t_gen (desc, gender) ;
			Values("Transgender", "12")				
	Insert Into	t_gen (desc, gender) ;
			Values("Transgender", "13")				
	Insert Into	t_gen (desc, gender) ;
			Values("Unknown/Unr", "  ")				

***Men who have sex with men
	Select t_gen.desc, ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "02" and ;
		  all_hivp.gender = t_gen.gender and ;
		  (t_gen.gender = "11" or ;
		  t_gen.gender = "12" or ;
		  t_gen.gender = "13") ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total

	Scan
		mrow = SPACE(6) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		If alltrim(t_total.desc) = "Female"
				m.group =   " Men who have   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)
* jss, 6/3/03, define memvars for extract's section 6 
				m.amsmfemale=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
		EndIf
		If alltrim(t_total.desc) = "Male"
				m.group =   " sex with men   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
							Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.amsmmale=mrow
		Endif
		
		If alltrim(t_total.desc) = "Transgender" 
				m.group =   "    (MSM)       " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.amsmtrans=mrow
		Endif
		
		If Left(t_total.desc, 7) = "Unknown"
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
				m.amsmunk=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
		EndIf
							
		Insert Into cadr_tmp From Memvar 
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Injection drug user (IDU)
	Select t_gen.desc, ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "03" and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		Do Case
			Case i = 1
				m.group =   " Injection drug " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

			Case i=2
				m.group =   " user (IDU)     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		Otherwise
		
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		mrow = SPACE(6) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		IF i=1	
			m.aidufemale=mrow
		ENDIF
		IF i=2	
			m.aidumale=mrow
		ENDIF
		IF i=3
			m.aidutrans=mrow
		ENDIF
		IF i=4
			m.aiduunk=mrow
		ENDIF

		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***MSM and IDU
	Select t_gen.desc, ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "01" and ;
		  all_hivp.gender = t_gen.gender and ;
		  (t_gen.gender = "11" or ;
		  t_gen.gender = "12" or ;
		  t_gen.gender = "13") ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total

	Scan
		mrow = SPACE(6) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		If alltrim(t_total.desc) = "Female"
				m.group =   Space(18)+ iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
				m.amidfemale=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
		EndIf
		If alltrim(t_total.desc) = "Male"
				m.group =   " MSM and IDU    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.amidmale=mrow	
		Endif
		
		If alltrim(t_total.desc) = "Transgender" 
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.amidtrans=mrow
		Endif
		
		If Left(t_total.desc, 7) = "Unknown"
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8) + ;
							Space(1) + Repl('±', 8) + Space(1) + Repl('±', 8)

* jss, 6/3/03, define memvars for extract's section 6 
				m.amidunk=SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)+','+SPACE(6)
		EndIf
							
		Insert Into cadr_tmp From Memvar 
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Hemophilia
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_cat1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "04" and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i = 1
				m.group =   " Hemophilia/    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.ahemfemale=mrow

			Case i=2
				m.group =   " coagulation    " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.ahemmale=mrow

			Case i=3
				m.group =   " disorder       " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.ahemtrans=mrow

			Otherwise
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.ahemunk=mrow

		EndCase
		Insert Into cadr_tmp From Memvar 
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Heterosexual contact
	Select t_gen.desc, ; 
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "05" and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = SPACE(6) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i = 1
				m.group =   " Heterosexual   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Case i=2
				m.group =   " contact        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(2) + Repl('±', 8) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		IF i=1	
			m.ahetfemale=mrow
		ENDIF
		IF i=2	
			m.ahetmale=mrow
		ENDIF
		IF i=3
			m.ahettrans=mrow
		ENDIF
		IF i=4
			m.ahetunk=mrow
		ENDIF

		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Receipt of transfusion of blood
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_cat1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "06" and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i = 1
				m.group =   " Recipient of   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.atrnfemale=mrow	

			Case i=2
				m.group =   " transfusion,   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.atrnmale=mrow

			Case i=3
				m.group =   " blood product  " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
						   Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
* jss, 6/3/03, define memvars for extract's section 6 
				m.atrntrans=mrow

			Otherwise
				m.group =   " or tissue      " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 

* jss, 6/3/03, define memvars for extract's section 6 
				m.atrnunk=mrow
		EndCase
		Insert Into cadr_tmp From Memvar 
		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Perinatal transmission
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_cat1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "07" and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i = 1
				m.group =   " Perinatal      " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Case i=2
				m.group =   " transmission   " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                     Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
                  	Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		IF i=1	
			m.aperfemale=mrow	
		ENDIF
		IF i=2	
			m.apermale=mrow
		ENDIF
		IF i=3
			m.apertrans=mrow
		ENDIF
		IF i=4
			m.aperunk=mrow
		ENDIF

		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Other
* jss, 3/9/05, fix less than 2 count by adding !empty(dob) to cl_age<2
	Select t_gen.desc, ; 
		Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_cat1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where all_hivp.rw_code = "09" and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i=2
				m.group =   "   Other        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		IF i=1	
			m.aothfemale=mrow
		ENDIF
		IF i=2	
			m.aothmale=mrow
		ENDIF
		IF i=3
			m.aothtrans=mrow
		ENDIF
		IF i=4
			m.aothunk=mrow
		ENDIF

		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
* next page:
	m.group= " " + chr(13) + " " + chr(13) 
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Unknown/Unreported
* jss, 3/9/05, fix less than 2 count by adding !empty(dob) to cl_age<2
	Select t_gen.desc, ; 
	Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_cat1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where (all_hivp.rw_code = "08") and ;
		  all_hivp.gender = t_gen.gender ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i = 1
				m.group =   " Unknown/       " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Case i=2
				m.group =   " Unreported     " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		IF i=1	
			m.aunkfemale=mrow
		ENDIF
		IF i=2	
			m.aunkmale=mrow
		ENDIF
		IF i=3
			m.aunktrans=mrow
		ENDIF
		IF i=4
			m.aunkunk=mrow
		ENDIF

		i= i+1
	EndScan
	
	m.group = REPL('Ä',103)  
	Insert Into cadr_tmp From Memvar
	
Use in t_tot1	
Use in t_total

***Total
	Select t_gen.desc, ; 
	Sum(Iif(!Empty(dob) and cl_age < 2, 1, 0)) as tot_cat1, ;
		Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_cat2, ;
		Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_cat3, ;
		Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_cat4, ;
		Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_cat5, ;
		Sum(Iif(cl_age >= 65, 1, 0)) as tot_cat6, ;
		Sum(Iif(Empty(dob), 1, 0)) as tot_cat7, ;
		Count(*) AS total ;
	From all_hivp, t_gen ;
	Where  all_hivp.gender = t_gen.gender and ;
			(all_hivp.rw_code = "02" or all_hivp.rw_code = "03" or ;
			all_hivp.rw_code = "01"  or all_hivp.rw_code = "04" or ;
			all_hivp.rw_code = "05"  or all_hivp.rw_code = "06" or ;
			all_hivp.rw_code = "07"  or all_hivp.rw_code = "09" or ;
			all_hivp.rw_code = "08") ;
	Group by 1;
	Into Cursor t_tot1
	
	Select * ;
	From t_tot1 ; 	
	Union ;
	Select t_gen.desc, ; 
			0 as tot_cat1, 0 as tot_cat2, 0 as tot_cat3, ;
			0 as tot_cat4, 0 as tot_cat5, 0 as tot_cat6, ;
			0 as tot_cat7, 0 AS total ;
	From  t_gen ;
	Where t_gen.desc not in (Select distinct t_tot1.desc From t_tot1) ;
	Group by 1 ;		
	Into Cursor t_total Order by 1
	
	Select t_total
    i = 1
	Scan
		mrow = Str(t_total.tot_cat1, 6, 0) + "," + Str(t_total.tot_cat2, 6, 0) + ;
		 "," + Str(t_total.tot_cat3, 6, 0) + "," + Str(t_total.tot_cat4, 6, 0) + ;
		 "," + Str(t_total.tot_cat5, 6, 0) + "," + Str(t_total.tot_cat6, 6, 0) + ;
		 "," + Str(t_total.tot_cat7, 6, 0) + "," + Str(t_total.total, 6, 0)	

		Do Case
			Case i=2
				m.group =   "   Total        " + Space(2) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
			Otherwise
				m.group =   Space(18) + iif(Isnull(t_total.desc), '', t_total.desc) + ;
							Space(4) + Iif(Isnull(t_total.tot_cat1), Space(5)+'0', Str(t_total.tot_cat1, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat2), Space(5)+'0', Str(t_total.tot_cat2, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat3), Space(5)+'0', Str(t_total.tot_cat3, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat4), Space(5)+'0', Str(t_total.tot_cat4, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat5), Space(5)+'0', Str(t_total.tot_cat5, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat6), Space(5)+'0', Str(t_total.tot_cat6, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.tot_cat7), Space(5)+'0', Str(t_total.tot_cat7, 6, 0)) + ;
                     Space(3) + Iif(Isnull(t_total.total), Space(5)+'0', Str(t_total.total, 6, 0)) 
		EndCase
		Insert Into cadr_tmp From Memvar 

* jss, 6/3/03, define memvars for extract's section 6 
		IF i=1	
			m.atfemale=mrow
		ENDIF
		IF i=2	
			m.atmale=mrow
		ENDIF
		IF i=3
			m.attrans=mrow
		ENDIF
		IF i=4
			m.atunk=mrow
		ENDIF
		
		i= i+1
	EndScan
	
Use in t_tot1	
Use in t_total	
Use in all_hivp
Return
