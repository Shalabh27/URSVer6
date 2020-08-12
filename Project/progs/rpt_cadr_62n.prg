* Cadr_62.prg: Q62 thru Q70
* jss, 4/1/05, Q60(2004) becomes Q62(2005)
*---Q62
*!*   	m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*                  " " + CHR(13) + " " + CHR(13) 
* jss, 11/29/07, add m.page_ej
   m.page_ej=4               
	m.info = 62
	m.group = "62.  Cost and revenue of primary care and other programs:"
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                        Primary care   Other program   Pharmaceuticals" +CHR(13) +;
   				"                                                        ------------   -------------   ---------------"
	Insert Into cadr_tmp From Memvar
	
 	Select t_cadr
 		  
	m.group   = "     a. Total cost of providing service:" + Space(18) + "$" + ;
                                                            Iif(Isnull(t_cadr.totprim), Space(8) + '0', Str(t_cadr.totprim, 9, 0)) + Space(6) + "$" + ;
																			   Iif(Isnull(t_cadr.totother), Space(8) + '0', Str(t_cadr.totother, 9, 0)) + Space(9)  + ;
																			   Repl('±', 9)
	Insert Into cadr_tmp From Memvar

* jss, 11/22/07, replace title iii with part c
*   m.group   = "     b. Title III grant funds expended: " + Space(18) + "$" + 
   m.group   = "     b. Part C grant funds expended:    " + Space(18) + "$" + ;
                                                            Iif(Isnull(t_cadr.grprim), Space(8) + '0', Str(t_cadr.grprim, 9, 0)) + Space(6) + "$" + ;
																			   Iif(Isnull(t_cadr.grother), Space(8) + '0', Str(t_cadr.grother, 9, 0)) + Space(8) + "$" + ;
																			   Iif(Isnull(t_cadr.totprim), Space(8) + '0', Str(t_cadr.grpharm, 9, 0))
	Insert Into cadr_tmp From Memvar

	m.group   = "     c. Direct collections from patients:" + Space(17) + "$" + ;
                                                             Iif(Isnull(t_cadr.colprim), Space(8) + '0', Str(t_cadr.colprim, 9, 0)) + Space(6) + "$" + ;
																			    Iif(Isnull(t_cadr.colother), Space(8) + '0', Str(t_cadr.colother, 9, 0)) + Space(9)  + ;
																			    Repl('±', 9)	
	Insert Into cadr_tmp From Memvar
	
	m.group   = "     d. Reimbursements from 3rd party payer:" + Space(14) + "$" + ;
                                                                Iif(Isnull(t_cadr.rprim), Space(8) + '0', Str(t_cadr.rprim, 9, 0)) + Space(6) + "$" + ;
																			   	 Iif(Isnull(t_cadr.rother), Space(8) + '0', Str(t_cadr.rother, 9, 0)) + Space(9)  + ;
																			       Repl('±', 9)
	Insert Into cadr_tmp From Memvar

	m.group   = "     e. All other sources of income:    " + Space(18) + "$" + ;
                                                            Iif(Isnull(t_cadr.allprim), Space(8) + '0', Str(t_cadr.allprim, 9, 0)) + Space(6) + "$" + ;
																			   Iif(Isnull(t_cadr.allother), Space(8) + '0', Str(t_cadr.allother, 9, 0)) + Space(9)  + ;
																			   Repl('±', 9)		             
	Insert Into cadr_tmp From Memvar
	
* jss, 6/3/03, define memvars for extract's section 6 
	m.t_prim   = TRAN(t_cadr.totprim,'999999999')
	m.t_oth    = TRAN(t_cadr.totother,'999999999')
	m.t3_prim  = TRAN(t_cadr.grprim,'999999999')
	m.t3_oth   = TRAN(t_cadr.grother,'999999999')
	m.t3_pharm = TRAN(t_cadr.grpharm,'999999999')
	m.pt_prim  = TRAN(t_cadr.colprim,'999999999')
	m.pt_oth   = TRAN(t_cadr.colother,'999999999')
	m.th_prim  = TRAN(t_cadr.rprim,'999999999')
	m.th_oth   = TRAN(t_cadr.rother,'999999999')
	m.oth_prim = TRAN(t_cadr.allprim,'999999999')
	m.oth_oth  = TRAN(t_cadr.allother,'999999999')

* jss, 4/1/05, Q61(2004) becomes Q63(2005)
*--Q63
	Select cadrserv
	m.part  = ""
	m.group = "63a. Were services available through your Early " + CHR(13) +;
			  "     Intervention Services (EIS) program provided" + CHR(13) +;
			  "     at more than one site during report. period?" + Space(16) + Iif(cadrserv.servprov = 1, "Yes", "No ")
	m.info = 63
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eis = IIF(cadrserv.servprov = 1, "Yes", "No ")
	
* jss, 4/1/05, Q62(2004) becomes Q63b(2005)
	m.part  = ""
	m.group = "  b. Number of sites at which EIS services provided:" + Space(7) + ;
                                                                     Iif(Isnull(cadrserv.numsite), Space(8) + '0', Str(cadrserv.numsite, 9, 0))
	Insert Into cadr_tmp From Memvar
	
* jss, 6/3/03, define memvars for extract's section 6 
	m.eis_sites  = TRAN(cadrserv.numsite,'999999')
	
* jss, 4/1/05, Q63(2004) becomes Q64(2005)
*--Q64	
*!*   	m.part  = ""
*!*   	m.group = "64.  Indication of primary care services available  "	+ CHR(13) +;
*!*   			  "     to your clients who are HIV positive:"   
*!*   	m.info = 64
*!*   	Insert Into cadr_tmp From Memvar
*!*   	
*!*   	m.group   = "                                                 Yes, within EIS program    Yes, through referral   No" +CHR(13) +;
*!*   				   "                                                 -----------------------    ---------------------   --"
*!*   	Insert Into cadr_tmp From Memvar

*!*   	m.group   = "     a. Ambulatory/outpatient medical care "+ Space(17) + Iif(cadrserv.indamb, REPL('û', 1), " ") + ;
*!*   																			Space(25) + Repl('±', 2) + Space(12) + Repl('±', 2)
*!*   	Insert Into cadr_tmp From Memvar

*!*   	m.group   = "     b. Dermatology                        "+ Space(17) + Iif(cadrserv.indderm1 = 1, REPL('û', 1),' ') + ;
*!*   																				+ Space(26) + Iif(cadrserv.indderm2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	+ Space(13) + Iif(cadrserv.indderm3 = 1, REPL('û', 1),' ')

*!*   	Insert Into cadr_tmp From Memvar
*!*   	
*!*   	m.group   = "     c. Dispensing of pharmaceuticals      " + Space(17) + Iif(cadrserv.inddisp1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.inddisp2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.inddisp3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar

*!*   	m.group   = "     d. Gastroenterology                   " + Space(17) + Iif(cadrserv.indgast1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indgast2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indgast3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   	
*!*   	m.group   = "     e. Mental health services             " + Space(17) + Iif(cadrserv.indment1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indment2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indment3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   	
*!*   	m.group   = "     f. Neurology                          " + Space(17) + Iif(cadrserv.indneur1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indneur2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indneur3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   	
*!*   	m.group   = "     g. Nutritional counseling             " + Space(17) + Iif(cadrserv.indnutr1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indnutr2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indnutr3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   		
*!*   	m.group   = "     h. Obstetrics/gynecology              " + Space(17) + Iif(cadrserv.indobst1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indobst2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indobst3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   		
*!*   	m.group   = "     i. Optometry/ophthalmology            " + Space(17) + Iif(cadrserv.indopt1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indopt2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indopt3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   		
*!*   	m.group   = "     j. Oral health care                   " + Space(17) + Iif(cadrserv.indoral1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indoral2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indoral3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   		
*!*   	m.group   = "     k. Rehabilitation services            " + Space(17) + Iif(cadrserv.indreh1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indreh2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indreh3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   		
*!*   	m.group   = "     l. Substance abuse services           " + Space(17) + Iif(cadrserv.indsubs1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indsubs2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indsubs3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   		
*!*   	m.group   = "     m. Other services                     " + Space(17) + Iif(cadrserv.indother1 = 1, REPL('û', 1),' ') + ;
*!*   																				 + Space(26) + Iif(cadrserv.indother2 = 1, REPL('û', 1),' ') + ;
*!*   																	       	 + Space(13) + Iif(cadrserv.indother3 = 1, REPL('û', 1),' ')
*!*   	Insert Into cadr_tmp From Memvar
*!*   	
*!*   	m.group   = "     n. Not applicable                     " + Space(17) + Iif(cadrserv.indnapp, REPL('û', 1), " ") + ;
*!*   																			Space(25) + Repl('±', 2) + Space(12) + Repl('±', 2) 
*!*   	Insert Into cadr_tmp From Memvar
	
* jss, 11/20/07, modify Q64, order has changes for several services, also remove Not Applic and Rehabilitation, add Medical Case Management
   m.part  = ""
   m.group = "64.  Indication of primary care services available  "   + CHR(13) +;
           "     to your clients who are HIV positive:"   
   m.info = 64
   Insert Into cadr_tmp From Memvar
   
   m.group   = "                                                 Yes, within EIS program    Yes, through referral   No" +CHR(13) +;
               "                                                 -----------------------    ---------------------   --"
   Insert Into cadr_tmp From Memvar

   m.group   = "     a. Outpatient/ambulatory medical care "+ Space(17) + Iif(cadrserv.indamb, REPL('û', 1), " ") + ;
                                                         Space(25) + Repl('±', 2) + Space(12) + Repl('±', 2)
   Insert Into cadr_tmp From Memvar

   m.group   = "     b. Dermatology                        "+ Space(17) + Iif(cadrserv.indderm1 = 1, REPL('û', 1),' ') + ;
                                                            + Space(26) + Iif(cadrserv.indderm2 = 1, REPL('û', 1),' ') + ;
                                                             + Space(13) + Iif(cadrserv.indderm3 = 1, REPL('û', 1),' ')


   Insert Into cadr_tmp From Memvar
   
   m.group   = "     c. Dispensing of pharmaceuticals      " + Space(17) + Iif(cadrserv.inddisp1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.inddisp2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.inddisp3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar

   m.group   = "     d. Gastroenterology                   " + Space(17) + Iif(cadrserv.indgast1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indgast2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indgast3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
   
   m.group   = "     e. Medical case management            " + Space(17) + Iif(cadrserv.indmedcas1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indmedcas2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indmedcas3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar

   m.group   = "     f. Medical nutrition therapy          " + Space(17) + Iif(cadrserv.indnutr1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indnutr2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indnutr3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
      
   m.group   = "     g. Mental health services             " + Space(17) + Iif(cadrserv.indment1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indment2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indment3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
   
   m.group   = "     h. Neurology                          " + Space(17) + Iif(cadrserv.indneur1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indneur2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indneur3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
   
   m.group   = "     i. Obstetrics/gynecology              " + Space(17) + Iif(cadrserv.indobst1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indobst2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indobst3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
      
   m.group   = "     j. Optometry/ophthalmology            " + Space(17) + Iif(cadrserv.indopt1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indopt2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indopt3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
      
   m.group   = "     k. Oral health care                   " + Space(17) + Iif(cadrserv.indoral1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indoral2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indoral3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
      
      
   m.group   = "     l. Substance abuse services           " + Space(17) + Iif(cadrserv.indsubs1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indsubs2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indsubs3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
      
   m.group   = "     m. Other services                     " + Space(17) + Iif(cadrserv.indother1 = 1, REPL('û', 1),' ') + ;
                                                             + Space(26) + Iif(cadrserv.indother2 = 1, REPL('û', 1),' ') + ;
                                                              + Space(13) + Iif(cadrserv.indother3 = 1, REPL('û', 1),' ')
   Insert Into cadr_tmp From Memvar
   
* jss, 6/3/03, define memvars for extract's section 6 
	m.ambul 		= 	IIF(cadrserv.indamb, '1', '0')

* jss, 4/4/05, now have 3 vars for each section
	m.dermat1	=	IIF(cadrserv.indderm1=1,'1','0')
	m.dermat2	=	IIF(cadrserv.indderm2=1,'1','0')
	m.dermat3	=	IIF(cadrserv.indderm3=1,'1','0')
	m.pharm1		=	IIF(cadrserv.inddisp1=1,'1','0')
	m.pharm2		=	IIF(cadrserv.inddisp2=1,'1','0')
	m.pharm3		=	IIF(cadrserv.inddisp3=1,'1','0')
	m.gas1		=	IIF(cadrserv.indgast1=1,'1','0')
	m.gas2		=	IIF(cadrserv.indgast2=1,'1','0')
	m.gas3		=	IIF(cadrserv.indgast3=1,'1','0')
	m.mental1	=	IIF(cadrserv.indment1=1,'1','0')
	m.mental2	=	IIF(cadrserv.indment2=1,'1','0')
	m.mental3	=	IIF(cadrserv.indment3=1,'1','0')
	m.neuro1		=	IIF(cadrserv.indneur1=1,'1','0')
	m.neuro2		=	IIF(cadrserv.indneur2=1,'1','0')
	m.neuro3		=	IIF(cadrserv.indneur3=1,'1','0')
	m.nutrit1	=	IIF(cadrserv.indnutr1=1,'1','0')
	m.nutrit2	=	IIF(cadrserv.indnutr2=1,'1','0')
	m.nutrit3	=	IIF(cadrserv.indnutr3=1,'1','0')
	m.obstet1	=	IIF(cadrserv.indobst1=1,'1','0')
	m.obstet2	=	IIF(cadrserv.indobst2=1,'1','0')
	m.obstet3	=	IIF(cadrserv.indobst3=1,'1','0')
	m.optom1		=	IIF(cadrserv.indopt1=1,'1','0')
	m.optom2		=	IIF(cadrserv.indopt2=1,'1','0')
	m.optom3		=	IIF(cadrserv.indopt3=1,'1','0')
	m.oral1		=	IIF(cadrserv.indoral1=1,'1','0')
	m.oral2		=	IIF(cadrserv.indoral2=1,'1','0')
	m.oral3		=	IIF(cadrserv.indoral3=1,'1','0')
*!*   	m.rehab1		=	IIF(cadrserv.indreh1=1,'1','0')
*!*   	m.rehab2		=	IIF(cadrserv.indreh2=1,'1','0')
*!*   	m.rehab3		=	IIF(cadrserv.indreh3=1,'1','0')
	m.subst1		=	IIF(cadrserv.indsubs1=1,'1','0')
	m.subst2		=	IIF(cadrserv.indsubs2=1,'1','0')
	m.subst3		=	IIF(cadrserv.indsubs3=1,'1','0')
	m.othserv1	=	IIF(cadrserv.indother1=1,'1','0')
	m.othserv2	=	IIF(cadrserv.indother2=1,'1','0')
	m.othserv3	=	IIF(cadrserv.indother3=1,'1','0')
*!*   	m.notapplic	= 	IIF(cadrserv.indnapp, '1', '0')
* jss, 11/20/07, add new columns m.medcasmgt1, m.medcasmgt2, m.medcasmgt3
   m.medcasmgt1   =   IIF(cadrserv.indmedcas1=1,'1','0')
   m.medcasmgt2   =   IIF(cadrserv.indmedcas2=1,'1','0')
   m.medcasmgt3   =   IIF(cadrserv.indmedcas3=1,'1','0')

* jss, 4/1/05, Q64(2004) becomes Q65(2005); also, must include MAI Title III funding in addition to regular Title III funding
*---Q65
If Used('all_ref')
   Use In all_ref
Endif
   
	Select Distinct ai_ref.tc_id ;
	From all_h35a, ;
		ai_ref ; 
	Where (all_h35a.fund_type ="03" or all_h35a.fund_type ="13") and ;
		  all_h35a.hiv_pos = .t. and ;
		  all_h35a.tc_id = ai_ref.tc_id and ;
		  all_h35a.act_id = ai_ref.act_id and ;
		  (ai_ref.ref_cat = '100' or ai_ref.ref_cat = '110') ;
	Into Cursor all_ref

If Used('all_p3')
   Use In all_p3
Endif

	Select Count(Distinct tc_id) as total ;
	From all_ref ;
	Into Cursor all_p3
		
	m.part  = ""
	m.group = "65.  How many unduplicated patients who are HIV positive"	+ CHR(13) +;
			  "     were referred outside EIS program for any health "	+ CHR(13) +;  
			  "     service that was not available within EIS program? " + Space(2) + ;
           Iif(Isnull(all_p3.total), Space(5)+'0',Str(all_p3.total, 6, 0)) 	
	m.info = 65
	Insert Into cadr_tmp From Memvar

* jss, 6/3/03, define memvars for extract's section 6 
	m.eis_client  = TRAN(all_p3.total,'999999')

	Use in all_p3
	Use in all_ref

*!*   	m.group=""
*!*   	Insert Into cadr_tmp From Memvar
*!*       *** For transfer to  next page
*!*   	m.group   = " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + ;
*!*   					" " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) + " " + CHR(13) 

* jss, 11/29/07, add m.page_ej
   m.info = 66
   m.page_ej=5
               
*--Q66: Title IV client counts
* jss, 11/27/07, replace m.section and m.part using Part C and D for Title III and IV:
*!*      m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/TITLE-SPECIFIC DATA FOR TITLES III AND IV"
*!*      m.part  = "Part 6.2. Title IV Information"
   m.section = "      SECTION 6.  DEMOGRAPHIC TABLES/PART-SPECIFIC DATA FOR PART C AND D"
   m.part  = "Part 6.2. Part D Information"
   m.group = "66.  Total # of unduplicated clients during reporting period who were:"
	Insert Into cadr_tmp From Memvar

If Used('all_t4pos')
   Use In all_t4pos
Endif

	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother, enr_req, prog_id ;
	From all_hiv ;
	Where elig_type = "01" and ;
			(fund_type = "04" or fund_type = "14") and ;
		  	hiv_pos = .t. ; 
	Into Cursor all_t4pos

If Used('t_66a')
   Use In t_66a
Endif

* now, count the number of hiv positive 
	Select Count(Dist tc_id) as Total ;
	From all_t4pos ;
	Into Cursor t_66a

   m.group = Space(53)+  Iif(Isnull(t_66a.total), Space(5)+'0', Str(t_66a.total, 6, 0)) + "   HIV Positive"
	Insert Into cadr_tmp From Memvar

If Used('all_t4ind')
   Use In all_t4ind
Endif

	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother, enr_req, prog_id  ;
	From all_hiv ;
	Where elig_type = "01" and ;
			(fund_type = "04" or fund_type = "14") and ;
			tc_id In (Select tc_id From t_indet) ;
	  and tc_id Not In (Select tc_id from all_t4pos) ;		
	Into Cursor all_t4ind

* now, count the number of hiv indeterminate
If Used('t_66b')
   Use In t_66b
Endif

	Select Count(Dist tc_id) as Total ;
	From all_t4ind ;
	Into Cursor t_66b

   m.group = Space(53)+  Iif(Isnull(t_66b.total), Space(5)+'0', Str(t_66b.total, 6, 0)) + "   HIV Indeterminate"
	Insert Into cadr_tmp From Memvar
   
If Used('all_t4negu')
   Use In all_t4negu
Endif

	Select Distinct tc_id, gender, dob, cl_age, ;
					hispanic, white, blafrican, asian, ;
					hawaisland, indialaska, unknowrep, someother, enr_req, prog_id  ;
	From all_hiv ;
	Where elig_type = "01" ;
	  and	(fund_type = "04" or fund_type = "14") ;
	  and (hivstatus = "04" or ;
	  		 hivstatus = "06" or ;
			 hivstatus = "07" or ;
			 hivstatus = "08" or ;
			 hivstatus = "09" or ;
			 hivstatus = "12") ;
	  and	tc_id Not In (Select tc_id From all_t4ind) ;
	  and tc_id Not In (Select tc_id from all_t4pos) ;		
	Into Cursor all_t4negu

* now, count the number of hiv negative/affected
If Used('t_66c')
   Use In t_66c
Endif

	Select Count(Dist tc_id) as Total ;
	From all_t4negu ;
	Into Cursor t_66c

   m.group = Space(53)+  Iif(Isnull(t_66c.total), Space(5)+'0', Str(t_66c.total, 6, 0)) + "   HIV Negative/Unknown"
	Insert Into cadr_tmp From Memvar

	m.sect62all=t_66a.total+t_66b.total+t_66c.total
	m.skip_66_70=IIF(m.sect62all=m.sect2all, '1', '0')

* define memvars for extract section 6 (for Q66)
	m.t4_pos 	= TRAN(t_66a.total,'999999')
	m.t4_ind 	= TRAN(t_66b.total,'999999')
	m.t4_negunk = TRAN(t_66c.total,'999999')

Use in t_66a
Use in t_66b
Use in t_66c

* join the Title IV HIV positive, Indeterminates and negative/unknowns
If Used('all_t4')
   Use In all_t4
Endif

	Select * From all_t4pos ;
	Union ;
	Select * From all_t4ind ;
	Union ;
	Select * From all_t4negu ;
	Into Cursor all_t4

* join the Title IV HIV positive & Indeterminates 
If Used('t4_posind')
   Use In t4_posind
Endif

	Select * From all_t4pos ;
	Union ;
	Select * From all_t4ind ;
	Into Cursor t4_posind
	
*** Clients are new intakes for title4
If Used('t_newin')
   Use In t_newin
Endif

	Select Distinct all_t4.tc_id  ;
	From 	all_t4, ;
		  	ai_clien ;
	Where all_t4.enr_req = .f. and ;
			all_t4.tc_id = ai_clien.tc_id and ;
			between(ai_clien.placed_dt, m.start_dt, m.end_dt);
	Into Cursor	t_newin

*** Clients do not require enrollment - continuing
If Used('t_cont')
   Use In t_cont
Endif

	Select Distinct all_t4.tc_id  ;
	From 	all_t4, ;
			ai_clien ;
	Where all_t4.enr_req = .f. and ;
			all_t4.tc_id = ai_clien.tc_id and ;
			ai_clien.placed_dt < m.start_dt ;
	Into Cursor	t_cont

*** Clients require enrollment - continuing
If Used('t_contpr')
   Use In t_contpr
Endif

	Select Distinct all_t4.tc_id  ;
	From all_t4, ;
		ai_prog ;
	Where all_t4.enr_req = .t. and ;
			ai_prog.tc_id = all_t4.tc_id and ;
			ai_prog.program = all_t4.prog_id and ;
			(ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			ai_prog.start_dt < m.start_dt and ;
			all_t4.tc_id Not In (Select tc_id From t_cont)    ; 
	Into Cursor	t_contpr	
	
*** Client's require enrollment - new
If Used('t_temp')
   Use In t_temp
Endif

	Select Distinct all_t4.tc_id  ;
	From all_t4, ;
		ai_prog ;
	Where all_t4.enr_req = .t. and ;
			ai_prog.tc_id = all_t4.tc_id and ;
			ai_prog.program = all_t4.prog_id and ;
			(ai_prog.tc_id + ai_prog.program + Dtos(ai_prog.start_dt)) ;
					In (Select Min(tc_id + program + Dtos(start_dt)) ;
									From ai_prog ;
									Group by tc_id, program) and ;
			between(ai_prog.start_dt, m.start_dt, m.end_dt) ;
	Into Cursor t_temp

If Used('t_newpr')
   Use In t_newpr
Endif
	
	Select * ;
	From t_temp ;
	Where ; 		
			t_temp.tc_id Not In (Select tc_id From t_cont) and ;
			t_temp.tc_id Not In (Select tc_id From t_contpr) ;
	Into Cursor	t_newpr	
	
	Use in t_temp
	Use in t_cont
	Use in t_contpr

*** Combine to one new client cursor
If Used('t_new')
   Use In t_new
Endif

	Select * ;
	From t_newin ;
	Union ;
	Select * ;
	From t_newpr ;
	Into Cursor t_new

	Use in t_newin
	Use in t_newpr
	

*--Q67: Breakdown of NEW Title IV clients
If Used('t_67a')
   Use In t_67a
Endif

	Select Count(Dist tc_id) as total ;
	From t_new ;
	Where tc_id in (Select tc_id From all_t4pos) ;
	Into Cursor t_67a

If Used('t_67b')
   Use In t_67b
Endif
	
	Select Count(Dist tc_id) as total ;
	From t_new ;
	Where tc_id in (Select tc_id From all_t4ind) ;
	Into Cursor t_67b

If Used('t_67c')
   Use In t_67c
Endif
	
	Select Count(Dist tc_id) as total ;
	From t_new ;
	Where tc_id in (Select tc_id From all_t4negu) ;
	Into Cursor t_67c
	
Use in t_new

   m.group = "67.  Total # of NEW unduplicated clients during reporting period who were:"
	m.info = 67
	Insert Into cadr_tmp From Memvar

   m.group = Space(53)+  Iif(Isnull(t_67a.total), Space(5)+'0', Str(t_67a.total, 6, 0)) + "   HIV Positive"
	Insert Into cadr_tmp From Memvar

   m.group = Space(53)+  Iif(Isnull(t_67b.total), Space(5)+'0', Str(t_67b.total, 6, 0)) + "   HIV Indeterminate"
	Insert Into cadr_tmp From Memvar

   m.group = Space(53)+  Iif(Isnull(t_67c.total), Space(5)+'0', Str(t_67c.total, 6, 0)) + "   HIV Negative/Unknown"
	Insert Into cadr_tmp From Memvar

* define memvars for extract section 6 (for Q67)
	m.t4_newpos  = TRAN(t_67a.total,'999999')
	m.t4_newind  = TRAN(t_67b.total,'999999')
	m.t4_newnegu = TRAN(t_67c.total,'999999')

Use in t_67a
Use in t_67b
Use in t_67c

*--Q68: Gender of Title IV clients
   m.group = "68.  Gender of clients reported in #66:"
	m.info = 68
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

If Used('all_t4gen')
   Use In all_t4gen
Endif

	Select Distinct tc_id, gender From t4_posind Into Cursor all_t4gen

If Used('t4_gen')
   Use In t_4gen
Endif

	Select 	Sum(Iif(gender='11',1, 0)) as tot_mal1, ;
				Sum(Iif(gender='10',1, 0)) as tot_fem1, ;
				Sum(Iif((gender = '12' or gender = '13'),1,0)) as tot_tr1, ;				
				Sum(iif(Empty(gender), 1, 0)) as tot_un1, ;
				Count(*) as total1 ;
		From all_t4gen ;
		Into Cursor t4_gen

Use in all_t4gen

If Used('all_t4gena')
   Use In all_t4gena
Endif
	
  	Select Distinct tc_id, gender From all_t4negu Into Cursor all_t4gena

If Used('t4_gena')
   Use In t_4gena
Endif

	Select 	Sum(Iif(gender='11',1, 0)) as tot_mal2, ;
				Sum(Iif(gender='10',1, 0)) as tot_fem2, ;
				Sum(Iif((gender = '12' or gender = '13'),1,0)) as tot_tr2, ;				
				Sum(iif(Empty(gender), 1, 0)) as tot_un2, ;
				Count(*) as total2 ;
		From all_t4gena ;
		Into Cursor t4_gena

Use in all_t4gena
	
	m.group   = Space(16) + "Male" + Space(36) + ;
               Iif(Isnull(t4_gen.tot_mal1), Space(5) + '0', Str(t4_gen.tot_mal1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_gena.tot_mal2), Space(5) + '0', Str(t4_gena.tot_mal2, 6, 0))
	Insert Into cadr_tmp From Memvar
					
	m.group   = Space(16) + "Female" + Space(34) + ;
               Iif(Isnull(t4_gen.tot_fem1), Space(5) + '0', Str(t4_gen.tot_fem1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_gena.tot_fem2), Space(5) + '0', Str(t4_gena.tot_fem2, 6, 0))
	Insert Into cadr_tmp From Memvar
		
	m.group   = Space(16) + "Transgender" + Space(29) + ;
               Iif(Isnull(t4_gen.tot_tr1), Space(5) + '0', Str(t4_gen.tot_tr1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_gena.tot_tr2), Space(5) + '0', Str(t4_gena.tot_tr2, 6, 0))
	Insert Into cadr_tmp From Memvar
	
	m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
               Iif(Isnull(t4_gen.tot_un1), Space(5) + '0', Str(t4_gen.tot_un1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_gena.tot_un2), Space(5) + '0', Str(t4_gena.tot_un2, 6, 0))
	Insert Into cadr_tmp From Memvar
		
	m.group   = Space(16) + "Total" + Space(35) + ;
               Iif(Isnull(t4_gen.total1), Space(5) + '0', Str(t4_gen.total1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_gena.total2), Space(5) + '0', Str(t4_gena.total2, 6, 0))
	Insert Into cadr_tmp From Memvar

* define memvars for extract section 6 (for Q68)
* jss, 11/30/07, if values are null, must force a zero into field
   m.t4p_male   = Iif(IsNull(t4_gen.tot_mal1),  '     0', TRAN(t4_gen.tot_mal1,'999999'))
	m.t4p_female = Iif(IsNull(t4_gen.tot_fem1),  '     0', TRAN(t4_gen.tot_fem1,'999999'))
	m.t4p_trans  = Iif(IsNull(t4_gen.tot_tr1),   '     0', TRAN(t4_gen.tot_tr1,'999999'))
	m.t4p_unkgen = Iif(IsNull(t4_gen.tot_un1),   '     0', TRAN(t4_gen.tot_un1,'999999'))
	m.t4p_totgen = Iif(IsNull(t4_gen.total1),    '     0', TRAN(t4_gen.total1,'999999'))
	m.t4a_male   = Iif(IsNull(t4_gena.tot_mal2), '     0', TRAN(t4_gena.tot_mal2,'999999'))
	m.t4a_female = Iif(IsNull(t4_gena.tot_fem2), '     0', TRAN(t4_gena.tot_fem2,'999999'))
	m.t4a_trans  = Iif(IsNull(t4_gena.tot_tr2),  '     0', TRAN(t4_gena.tot_tr2,'999999'))
	m.t4a_unkgen = Iif(IsNull(t4_gena.tot_un2),  '     0', TRAN(t4_gena.tot_un2,'999999'))
	m.t4a_totgen = Iif(IsNull(t4_gena.total2),   '     0', TRAN(t4_gena.total2,'999999'))

Use in t4_gen
Use in t4_gena
	
*--Q69 Age of Title IV clients

   m.group = "69.  Age of clients reported in #66:"
	m.info = 69
	Insert Into cadr_tmp From Memvar

	m.group   = "                                                     HIV positive/                            " +CHR(13) +;
					"                Number of clients:                   Indeterminate           HIV affected only" +CHR(13) +;        
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

**	HIV+ and Indeterminates  
If Used('t4_ageposi')
   Use In t4_ageposi
Endif
   
	Select Distinct tc_id, cl_age, dob ;
	From t4_posind ;
	Into Cursor t4_ageposi

If Used('t4_agepi')
   Use In t4_agepi
Endif
	
	Select  ;
			Sum(Iif((cl_age < 2 and !Empty(dob)), 1, 0)) as tot_y1, ;
			Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_y3, ;
			Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_y5, ;
			Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_y7, ;
			Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_y9, ;
			Sum(iif(cl_age >= 65, 1, 0)) as tot_y11, ;
			Sum(iif(Empty(dob), 1, 0)) as tot_y13, ;
			Count(*) as total1 ;
	From t4_ageposi ;
	Into Cursor t4_agepi

Use in t4_ageposi

**	HIV negative/unknown   
If Used('t4_agenegu')
   Use In t4_agenegu
Endif

	Select Distinct tc_id, cl_age, dob  ;
	From all_t4negu ;
	Into Cursor t4_agenegu

If Used('t4_agea')
   Use In t4_agea
Endif

	Select  ;
			Sum(Iif((cl_age < 2 and !Empty(dob)), 1, 0)) as tot_y2, ;
			Sum(Iif(Between(cl_age, 2, 12),1, 0)) as tot_y4, ;
			Sum(Iif(Between(cl_age, 13, 24),1, 0)) as tot_y6, ;
			Sum(Iif(Between(cl_age, 25, 44),1, 0)) as tot_y8, ;
			Sum(Iif(Between(cl_age, 45, 64),1, 0)) as tot_y10, ;
			Sum(iif(cl_age >= 65, 1, 0)) as tot_y12, ;
			Sum(iif(Empty(dob), 1, 0)) as tot_y14, ;
			Count(*) as total2 ;
	From t4_agenegu ;
	Into Cursor t4_agea

Use in t4_agenegu

	m.group   = Space(16) + "Less than 2 years" + Space(23) + ;
               Iif(Isnull(t4_agepi.tot_y1), Space(5)+'0', Str(t4_agepi.tot_y1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y2), Space(5)+'0', Str(t4_agea.tot_y2, 6, 0))
	Insert Into cadr_tmp From Memvar
	
	m.group   = Space(16) + "2 - 12 years     " + Space(23) + ;
               Iif(Isnull(t4_agepi.tot_y3), Space(5)+'0', Str(t4_agepi.tot_y3, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y4), Space(5)+'0', Str(t4_agea.tot_y4, 6, 0))
	Insert Into cadr_tmp From Memvar
					
	m.group   = Space(16) + "13 - 24 years    " + Space(23) + ;
               Iif(Isnull(t4_agepi.tot_y5), Space(5)+'0',  Str(t4_agepi.tot_y5, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y6), Space(5)+'0', Str(t4_agea.tot_y6, 6, 0))
	Insert Into cadr_tmp From Memvar
					
	m.group   = Space(16) + "25 - 44 years    " + Space(23) + ;
               Iif(Isnull(t4_agepi.tot_y7), Space(5)+'0',  Str(t4_agepi.tot_y7, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y8), Space(5)+'0',Str(t4_agea.tot_y8, 6, 0))
	Insert Into cadr_tmp From Memvar
		
	m.group   = Space(16) + "45 - 64 years    " + Space(23) + ;
               Iif(Isnull(t4_agepi.tot_y9), Space(5)+'0',  Str(t4_agepi.tot_y9, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y10), Space(5)+'0', Str(t4_agea.tot_y10, 6, 0))
	Insert Into cadr_tmp From Memvar
					
	m.group   = Space(16) + "65 years or older" + Space(23) + ;
               Iif(Isnull(t4_agepi.tot_y11), Space(5)+'0', Str(t4_agepi.tot_y11, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y12), Space(5)+'0', Str(t4_agea.tot_y12, 6, 0))
	Insert Into cadr_tmp From Memvar
		
	m.group   = Space(16) + "Unknown/Unreported" + Space(22) + ;
               Iif(Isnull(t4_agepi.tot_y13), Space(5)+'0', Str(t4_agepi.tot_y13, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.tot_y14), Space(5)+'0', Str(t4_agea.tot_y14, 6, 0))
	Insert Into cadr_tmp From Memvar
		
	m.group   = Space(16) + "Total" + Space(35) + ;
               Iif(Isnull(t4_agepi.total1), Space(5)+'0', Str(t4_agepi.total1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_agea.total2), Space(5)+'0', Str(t4_agea.total2, 6, 0))
	Insert Into cadr_tmp From Memvar

* define memvars for extract section 6 (for Q69)
* jss, 11/30/07, if values are null, must force a zero into field
   m.t4p_0_1    = Iif(IsNull(t4_agepi.tot_y1), '     0', TRAN(t4_agepi.tot_y1,'999999'))
	m.t4p_2_12   = Iif(IsNull(t4_agepi.tot_y3), '     0', TRAN(t4_agepi.tot_y3,'999999'))
	m.t4p_13_24  = Iif(IsNull(t4_agepi.tot_y5), '     0', TRAN(t4_agepi.tot_y5,'999999'))
	m.t4p_25_44  = Iif(IsNull(t4_agepi.tot_y7), '     0', TRAN(t4_agepi.tot_y7,'999999'))
	m.t4p_45_64  = Iif(IsNull(t4_agepi.tot_y9), '     0', TRAN(t4_agepi.tot_y9,'999999'))
	m.t4p_65plus = Iif(IsNull(t4_agepi.tot_y11),'     0', TRAN(t4_agepi.tot_y11,'999999'))
	m.t4p_unkage = Iif(IsNull(t4_agepi.tot_y13),'     0', TRAN(t4_agepi.tot_y13,'999999'))
	m.t4p_totage = Iif(IsNull(t4_agepi.total1), '     0', TRAN(t4_agepi.total1,'999999'))
	m.t4a_0_1    = Iif(IsNull(t4_agea.tot_y2),  '     0', TRAN(t4_agea.tot_y2,'999999'))
	m.t4a_2_12   = Iif(IsNull(t4_agea.tot_y4),  '     0', TRAN(t4_agea.tot_y4,'999999'))
	m.t4a_13_24  = Iif(IsNull(t4_agea.tot_y6),  '     0', TRAN(t4_agea.tot_y6,'999999'))
	m.t4a_25_44  = Iif(IsNull(t4_agea.tot_y8),  '     0', TRAN(t4_agea.tot_y8,'999999'))
	m.t4a_45_64  = Iif(IsNull(t4_agea.tot_y10), '     0', TRAN(t4_agea.tot_y10,'999999'))
	m.t4a_65plus = Iif(IsNull(t4_agea.tot_y12), '     0', TRAN(t4_agea.tot_y12,'999999'))
	m.t4a_unkage = Iif(IsNull(t4_agea.tot_y14), '     0', TRAN(t4_agea.tot_y14,'999999'))
	m.t4a_totage = Iif(IsNull(t4_agea.total2),  '     0', TRAN(t4_agea.total2,'999999'))

Use in t4_agepi
Use in t4_agea

*--Q70 Race/Ethnicity of Title III clients

	m.group   = "70. Race/Ethnicity of clients reported in #66:"
	m.info = 70	
	Insert Into cadr_tmp From Memvar

	m.group   = "    a. HIV-Positive/indeterminate:                                                            " +CHR(13) +;
					"                Number of clients:                   Hispanic                Non-Hispanic     " +CHR(13) +;
   				"                ------------------                   -------------           -----------------"
	Insert Into cadr_tmp From Memvar

**	HIV+/Indeterminate  
*!*   If Used('t4_racepos')
*!*      Use In t4_racepos
*!*   Endif
*!*      
*!*   	Select Distinct tc_id, ;
*!*   			white, blafrican, hispanic, asian, ;
*!*   			hawaisland, indialaska, unknowrep, someother ;
*!*   	From t4_posind ;
*!*   	Into Cursor t4_racepos

*!*   Use in t4_posind

If Used('t4_racepi')
   Use In t4_racepi
Endif

*!*   	Select  ;
*!*   			Sum(Iif(white = 1 and hispanic <> 2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r1, ;
*!*   			Sum(Iif(blafrican = 1 and hispanic <> 2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r3, ;
*!*   			Sum(Iif(asian = 1 and hispanic <> 2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r5, ;
*!*   			Sum(Iif(hawaisland = 1 and hispanic<> 2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r7, ;
*!*   			Sum(Iif(indialaska = 1 and hispanic <> 2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r9, ;
*!*   			Sum(Iif(hispanic <> 2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r11, ;
*!*   			Sum(Iif(hispanic <> 2 and ((unknowrep = 1 or someother = 1) and ;
*!*   				(white + blafrican + asian + hawaisland + indialaska) = 0) or ;
*!*   				(unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot_r13, ;
*!*   			Sum(Iif(hispanic=2,1,0)) as tot_r15, ;	
*!*   			Count(*) as total1 ;
*!*   	From t4_racepos ;
*!*   	Into Cursor t4_racepi


** PB: for 2008 RDR Q70 now has columns hispand and Non-hispanic.  Plus HIV-Pos& Indeterm
** Note: using t4_posind instead of t4_racepos.  Alos we will summ for hispanic bu not use it.
   ** Make the Non-hisanic cursor
   Select  ;
         Sum(Iif(white = 1 and hispanic <> 2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r1, ;
         Sum(Iif(blafrican = 1 and hispanic <> 2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r3, ;
         Sum(Iif(asian = 1 and hispanic <> 2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r5, ;
         Sum(Iif(hawaisland = 1 and hispanic <> 2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r7, ;
         Sum(Iif(indialaska = 1 and hispanic <> 2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r9, ;
         Sum(Iif(hispanic <> 2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r11, ;
         Sum(Iif(hispanic <> 2 and ((unknowrep = 1 or someother = 1) and ;
            (white + blafrican + asian + hawaisland + indialaska) = 0) or ;
            (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot_r13, ;
         Sum(Iif(hispanic <> 2,1,0)) as tot_r15, ;   
         Count(*) as total1 ;
   From t4_posind ;
      Where hispanic <> 2;
   Into Cursor t4_racepi


If Used('t4_raceph')
   Use In t4_raceph
Endif

   ** Make the Hispanic cursor
   Select  ;
         Sum(Iif(white = 1 and hispanic = 2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r1, ;
         Sum(Iif(blafrican = 1 and hispanic = 2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r3, ;
         Sum(Iif(asian = 1 and hispanic = 2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r5, ;
         Sum(Iif(hawaisland = 1 and hispanic = 2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r7, ;
         Sum(Iif(indialaska = 1 and hispanic = 2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r9, ;
         Sum(Iif(hispanic = 2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1, 1, 0)) as tot_r11, ;
         Sum(Iif(hispanic = 2 and ((unknowrep = 1 or someother = 1) and ;
            (white + blafrican + asian + hawaisland + indialaska) = 0) or ;
            (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot_r13, ;
         Sum(Iif(hispanic=2,1,0)) as tot_r15, ;   
         Count(*) as total1 ;
   From t4_posind ;
      Where hispanic = 2;
   Into Cursor t4_raceph

Use in t4_posind
	
*!*   Use in t4_racepos

**	HIV affected  
If Used('t4_raceneg')
   Use In t4_raceneg
Endif

	Select Distinct tc_id, ;
			white, blafrican, hispanic, asian, ;
			hawaisland, indialaska, unknowrep, someother ;
	From all_t4negu ;
	Into Cursor t4_raceneg

Use in all_t4negu

If Used('t4_racea')
   Use In t4_racea
Endif
   ** PB 12/2008 
   ** Q70.b Non-Hispanic
	Select  ;
			Sum(Iif(white = 1 and hispanic <> 2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r2, ;
			Sum(Iif(blafrican = 1 and hispanic <>2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r4, ;
			Sum(Iif(asian = 1 and hispanic <>2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r6, ;
			Sum(Iif(hawaisland = 1 and hispanic <> 2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r8, ;
			Sum(Iif(indialaska = 1 and hispanic <> 2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r10, ;
			Sum(Iif(hispanic <> 2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1 , 1, 0)) as tot_r12, ;
			Sum(Iif(hispanic <> 2 and ((unknowrep = 1 or someother = 1) and ;
				(white + blafrican + asian + hawaisland + indialaska) = 0) or ;
				(unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot_r14, ;
			Sum(Iif(hispanic <> 2,1,0)) as tot_r16, ;	
			Count(*) as total2 ;
	From t4_raceneg ;
      Where hispanic <> 2;
	Into Cursor t4_racea

If Used('t4_raceah')
   Use In t4_raceah
Endif

   ** PB 12/2008 
   ** Q70.b Hispanic
   Select  ;
         Sum(Iif(white = 1 and hispanic = 2 and (blafrican + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r2, ;
         Sum(Iif(blafrican = 1 and hispanic=2 and (white + asian + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r4, ;
         Sum(Iif(asian = 1 and hispanic=2 and (white + blafrican + hawaisland + indialaska + someother) = 0, 1, 0)) as tot_r6, ;
         Sum(Iif(hawaisland = 1 and hispanic = 2 and (white + blafrican + asian + indialaska + someother) = 0, 1, 0)) as tot_r8, ;
         Sum(Iif(indialaska = 1 and hispanic = 2 and (white + blafrican + asian + hawaisland + someother) = 0, 1, 0)) as tot_r10, ;
         Sum(Iif(hispanic = 2 and (white + blafrican + asian + hawaisland + indialaska + someother) > 1 , 1, 0)) as tot_r12, ;
         Sum(Iif(hispanic = 2 and ((unknowrep = 1 or someother = 1) and ;
            (white + blafrican + asian + hawaisland + indialaska) = 0) or ;
            (unknowrep + someother + white + blafrican + asian + hawaisland + indialaska) = 0, 1, 0)) as tot_r14, ;
         Sum(Iif(hispanic=2,1,0)) as tot_r16, ;   
         Count(*) as total2 ;
   From t4_raceneg ;
      Where hispanic=2;
   Into Cursor t4_raceah

   Use in t4_raceneg

   * PB: 12/2008 RDR 2008
   * Fill the report for 70.a    Hispanic / Non-Hispanic
   m.group   = Space(16) + "American Indian or Alaskan Native" + Space(7) + ;
               Iif(Isnull(t4_raceph.tot_r9), Space(5)+'0', Str(t4_raceph.tot_r9, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r9), Space(5)+'0', Str(t4_racepi.tot_r9, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Asian" + Space(35) + ;
               Iif(Isnull(t4_raceph.tot_r5), Space(5)+'0', Str(t4_raceph.tot_r5, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r5), Space(5)+'0', Str(t4_racepi.tot_r5, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Black or African-American" + Space(15) + ;
               Iif(Isnull(t4_raceph.tot_r3), Space(5)+'0', Str(t4_raceph.tot_r3, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r3), Space(5)+'0', Str(t4_racepi.tot_r3, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Native Hawaiian/Pacific Islander" + Space(8) + ;
               Iif(Isnull(t4_raceph.tot_r7), Space(5)+'0', Str(t4_raceph.tot_r7, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r7), Space(5)+'0', Str(t4_racepi.tot_r7, 6, 0))
   Insert Into cadr_tmp From Memvar

	m.group   = Space(16) + "White" + Space(35) + ;
               Iif(Isnull(t4_raceph.tot_r1), Space(5)+'0', Str(t4_raceph.tot_r1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r1), Space(5)+'0', Str(t4_racepi.tot_r1, 6, 0))
	Insert Into cadr_tmp From Memvar
		

	m.group   = Space(16) + "More than one race" + Space(22) + ;
               Iif(Isnull(t4_raceph.tot_r11), Space(5)+'0', Str(t4_raceph.tot_r11, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r11), Space(5)+'0', Str(t4_racepi.tot_r11, 6, 0))
	Insert Into cadr_tmp From Memvar

	m.group   = Space(16) + "Not reported      " + Space(22) + ;
               Iif(Isnull(t4_raceph.tot_r13), Space(5)+'0', Str(t4_raceph.tot_r13, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.tot_r13), Space(5)+'0', Str(t4_racepi.tot_r13, 6, 0))
	Insert Into cadr_tmp From Memvar

	m.group   = Space(16) + "Total" + Space(35) + ;
               Iif(Isnull(t4_raceph.total1), Space(5)+'0', Str(t4_raceph.total1, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racepi.total1), Space(5)+'0', Str(t4_racepi.total1, 6, 0))
	Insert Into cadr_tmp From Memvar

   * Pb 12/2008 New category for 2008 RDR
   m.group   = "    b. HIV Affected:                                                                          " +CHR(13) +;
               "                Number of clients:                   Hispanic                Non-Hispanic     " +CHR(13) +;
               "                ------------------                   -------------           -----------------"
   Insert Into cadr_tmp From Memvar
   
   
   m.group   = Space(16) + "American Indian or Alaskan Native" + Space(7) + ;
               Iif(Isnull(t4_raceah.tot_r10), Space(5)+'0', Str(t4_raceah.tot_r10, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r10), Space(5)+'0', Str(t4_racea.tot_r10, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Asian" + Space(35) + ;
               Iif(Isnull(t4_raceah.tot_r6), Space(5)+'0', Str(t4_raceah.tot_r6, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r6), Space(5)+'0', Str(t4_racea.tot_r6, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Black or African-American" + Space(15) + ;
               Iif(Isnull(t4_raceah.tot_r4), Space(5)+'0', Str(t4_raceah.tot_r4, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r4), Space(5)+'0', Str(t4_racea.tot_r4, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Native Hawaiian/Pacific Islander" + Space(8) + ;
               Iif(Isnull(t4_raceah.tot_r8), Space(5)+'0', Str(t4_raceah.tot_r8, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r8), Space(5)+'0', Str(t4_racea.tot_r8, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "White" + Space(35) + ;
               Iif(Isnull(t4_raceah.tot_r2), Space(5)+'0', Str(t4_raceah.tot_r2, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r2), Space(5)+'0', Str(t4_racea.tot_r2, 6, 0))
   Insert Into cadr_tmp From Memvar
 
   m.group   = Space(16) + "More than one race" + Space(22) + ;
               Iif(Isnull(t4_raceah.tot_r12), Space(5)+'0', Str(t4_raceah.tot_r12, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r12), Space(5)+'0', Str(t4_racea.tot_r12, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Not reported      " + Space(22) + ;
               Iif(Isnull(t4_raceah.tot_r14), Space(5)+'0', Str(t4_raceah.tot_r14, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.tot_r14), Space(5)+'0', Str(t4_racea.tot_r14, 6, 0))
   Insert Into cadr_tmp From Memvar

   m.group   = Space(16) + "Total" + Space(35) + ;
               Iif(Isnull(t4_raceah.total2), Space(5)+'0', Str(t4_raceah.total2, 6, 0)) + Space(22) + ;
               Iif(Isnull(t4_racea.total2), Space(5)+'0', Str(t4_racea.total2, 6, 0))
   Insert Into cadr_tmp From Memvar
   
   * define memvars for extract section 6 (for Q70)
   * jss, 11/30/07, if values are null, must force a zero into field
   
   * PB: 12/2008; New fields for the 2008 RDR
   * Equates to 70a. Hispanic Column (t4_raceph)

   m.T4PHWHITE=Iif(IsNull(t4_raceph.tot_r1),   '     0', TRAN(t4_raceph.tot_r1,'999999'))
   m.T4PHBLACK=Iif(IsNull(t4_raceph.tot_r3),   '     0', TRAN(t4_raceph.tot_r3,'999999'))
   m.T4PHASIAN=Iif(IsNull(t4_raceph.tot_r5),   '     0', TRAN(t4_raceph.tot_r5,'999999'))
   m.T4PHHAWAII=Iif(IsNull(t4_raceph.tot_r7),  '     0', TRAN(t4_raceph.tot_r7,'999999'))
   m.T4PHNATIVE=Iif(IsNull(t4_raceph.tot_r9),  '     0', TRAN(t4_raceph.tot_r9,'999999'))
   m.T4PHMORTH1=Iif(IsNull(t4_raceph.tot_r11), '     0', TRAN(t4_raceph.tot_r11,'999999'))
   m.T4PHUNKRAC=Iif(IsNull(t4_raceph.tot_r13), '     0', TRAN(t4_raceph.tot_r13,'999999'))
   m.T4PHTOTRAC=Iif(IsNull(t4_raceph.total1),  '     0', TRAN(t4_raceph.total1,'999999'))

   * Equates to 70a.  Non-Hispanic Column (t4_racepi)
   m.t4pwhite    = Iif(IsNull(t4_racepi.tot_r1),  '     0', TRAN(t4_racepi.tot_r1,'999999'))
	m.t4pblack    = Iif(IsNull(t4_racepi.tot_r3),  '     0', TRAN(t4_racepi.tot_r3,'999999'))
	m.t4phisp = '      '  && Send spaces for 2008 RDR
	m.t4pasian    = Iif(IsNull(t4_racepi.tot_r5),  '     0', TRAN(t4_racepi.tot_r5,'999999'))
	m.t4phawaii   = Iif(IsNull(t4_racepi.tot_r7),  '     0', TRAN(t4_racepi.tot_r7,'999999'))
	m.t4pnative   = Iif(IsNull(t4_racepi.tot_r9),  '     0', TRAN(t4_racepi.tot_r9,'999999'))
	m.t4pmoreth1  = Iif(IsNull(t4_racepi.tot_r11), '     0', TRAN(t4_racepi.tot_r11,'999999'))
	m.t4punkrace  = Iif(IsNull(t4_racepi.tot_r13), '     0', TRAN(t4_racepi.tot_r13,'999999'))
	m.t4ptotrace  = Iif(IsNull(t4_racepi.total1),  '     0', TRAN(t4_racepi.total1,'999999'))

   * Equates to 70b. Hispanic Column (t4_raceph)
   m.T4AHWHITE=Iif(IsNull(t4_raceah.tot_r2),   '     0', TRAN(t4_raceah.tot_r2,'999999'))
   m.T4AHBLACK=Iif(IsNull(t4_raceah.tot_r4),   '     0', TRAN(t4_raceah.tot_r4,'999999'))
   m.T4AHASIAN=Iif(IsNull(t4_raceah.tot_r6),   '     0', TRAN(t4_raceah.tot_r6,'999999'))
   m.T4AHHAWAII=Iif(IsNull(t4_raceah.tot_r8),  '     0', TRAN(t4_raceah.tot_r8,'999999'))
   m.T4AHNATIVE=Iif(IsNull(t4_raceah.tot_r10), '     0', TRAN(t4_raceah.tot_r10,'999999'))
   m.T4AHMORTH1=Iif(IsNull(t4_raceah.tot_r12), '     0', TRAN(t4_raceah.tot_r12,'999999'))
   m.T4AHUNKRAC=Iif(IsNull(t4_raceah.tot_r14), '     0', TRAN(t4_raceah.tot_r14,'999999'))
   m.T4AHTOTRAC=Iif(IsNull(t4_raceah.total2),  '     0', TRAN(t4_raceah.total2,'999999'))

   * Equates to 70b. No-Hispanic Column - Affected (t4_raceah)
  	m.t4awhite    = Iif(IsNull(t4_racea.tot_r2),   '     0', TRAN(t4_racea.tot_r2,'999999'))
	m.t4ablack    = Iif(IsNull(t4_racea.tot_r4),   '     0', TRAN(t4_racea.tot_r4,'999999'))
   m.t4ahisp =  '      ' && Send spaces for 2008 RDR
	m.t4aasian    = Iif(IsNull(t4_racea.tot_r6),   '     0', TRAN(t4_racea.tot_r6,'999999'))
	m.t4ahawaii   = Iif(IsNull(t4_racea.tot_r8),   '     0', TRAN(t4_racea.tot_r8,'999999'))
	m.t4anative   = Iif(IsNull(t4_racea.tot_r10),  '     0', TRAN(t4_racea.tot_r10,'999999'))
	m.t4amoreth1  = Iif(IsNull(t4_racea.tot_r12),  '     0', TRAN(t4_racea.tot_r12,'999999'))
	m.t4aunkrace  = Iif(IsNull(t4_racea.tot_r14),  '     0', TRAN(t4_racea.tot_r14,'999999'))
	m.t4atotrace  = Iif(IsNull(t4_racea.total2),   '     0', TRAN(t4_racea.total2,'999999'))


Use in t4_racepi		
Use in t4_racea		


Return