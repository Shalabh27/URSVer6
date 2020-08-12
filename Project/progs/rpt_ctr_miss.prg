Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by number
              nGroup, ;             && report selection number   
              cTitle, ;            && report selection description   
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description
              
Acopy(aSelvar1, aSelvar2)

cTitle = Left(cTitle, Len(cTitle)-1)

cTC_ID = ""
LCProg =""
cCWork =""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CTC_ID"
      cTc_id = aSelvar2(i, 2)
   Endif
   
   If Rtrim(aSelvar2(i, 1)) = "PWORKER"
      cCWork = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   Endif
   
EndFor

cDate = DATE()
cTime = TIME()

If Used('tmp_miss')
   Use In tmp_miss
Endif

CREATE CURSOR  tmp_miss(section n(1), section_caption C(50), ;
               ID_no C(20) , form_id C(10), acces_test_id C(11) null, ;
               testdate D null, test_seq C(2) null, test_type C(30) null, test_result C(30) null, ;
               program_name C(30) null, worker_name C(50) null )

If Used('tmp_ctr')
   Use In tmp_ctr
endif   


* Put date limitation in SQL
cWhere =""

cWhere = " Between(ai_ctr.session_dt, Date_from , Date_to)"
cWhere = cWhere + IIF(EMPTY(LCProg),""," AND ai_ctr.program = LCProg")
cWhere = cWhere + IIF(Empty(cCWork),""," AND ai_ctr.pworker_id = cCWork")
cWhere = cWhere + IIF(Empty(cTc_id),""," AND ai_ctr.tc_id= cTc_id")
** All ai_ctr records with parameters

   SELECT Distinct ;
   		 cli_cur.id_no, ;
          ai_ctr.form_id, ;
          Nvl(ctr_test.test_id, PADR('N/A',11)) as acces_test_id, ;
          Nvl(Ctr_test.ctr_id, PADR('N/A',10)) as ctr_id, ;
          Ctr_test.sample_dt as testdate, ;
          Nvl(Ctr_test.seq_id, '  ') as test_seq, ;
          Nvl(Ctr_test.result, 0) as result,;
          Nvl(Ctr_results.description, PADR('N/A',30)) AS result_desc,;
          Iif(ctr_test.testtech =1, 'Conventional', ;
          Iif(ctr_test.testtech =2, 'Rapid       ',;
          Iif(ctr_test.testtech =3,'Other       ','N/A         '))) as type_desc,;
          Nvl(ctr_test.testtech, 0) as testtech, ;
          Nvl(ctr_test.resltprov, 0) as resltprov,;
          program.descript as program_name, ;
          ai_ctr.pworker_id, ;
          oApp.FormatName(staffcur.last,staffcur.first,staffcur.mi) as worker_name, ;
          ctr_partd.survey_dt, ;
          ai_ctr.no_testing_provided, ;
          ai_enc.enc_id, ;
          Nvl(ctr_test.conftest, 0) as conftest ;
 From ai_ctr  ;
      Inner Join cli_cur On ;
           ai_ctr.tc_id =  cli_cur.tc_id ;
      Left Outer Join program On ;
          program.prog_id = ai_ctr.program  ;
      Left outer Join staffcur On ;
          staffcur.pworker_id = ai_ctr.pworker_id ;         
      Left outer join ctr_test On ;
           Ctr_test.ctr_id = Ai_ctr.ctr_id ;
      Left outer Join ctr_results On ;
           Ctr_test.result = Ctr_results.code ;
      left outer join ctr_partd on ;
      	  Ctr_test.ctrtest_id = ctr_partd.ctrtest_id  ;
      left outer join ai_enc on ;
      	  ai_enc.act_id = ai_ctr.act_id ;	  
 WHERE  &cWhere ;
Into Cursor tmp_ctr


*** 1. Client Not Provided Test Results 
   Insert into tmp_miss ; 
         Select 1  as section, ;
                'Client Not Provided Test Results' as section_caption, ;  
                id_no, ;
                form_id, ;
                acces_test_id, ;
                testdate, ;
                test_seq, ;
                type_desc, ;
                result_desc, ;
                program_name, ;
                worker_name;
       From tmp_ctr ;
       Where resltprov <> 1 ;
          And no_testing_provided =.f. ;
          And Rtrim(ctr_id) <> 'N/A' 
          
**VT 10/28/2008 Supp Tick 19973      
*!*          Where testtech <> 0 ;
*!*             and result <> 0 ;
*!*             and resltprov =0 
        
*** 2. Confirmatory Results Not Entered 
**** This Part works just for more than 1 ctr_id  or 1 ctr_id
  
   Select Count(*) as id_num , ctr_id ;
   From tmp_ctr ;
   Into Cursor t_id ;
   group by ctr_id 
   
 **VT 10/28/2008 Supp Tick 19973   
 **  having Count(*) > 1
   
 ** 2A Rapid positive or NAAT positive and Conventional with empty result, indeterminate, invalid or no result
 ** Show in report Conventional record
   Insert into tmp_miss; 
         Select Distinct ;
                 2  as section, ;
                'Confirmatory Results Not Entered' as section_caption, ;  
                tc2.id_no, ;
                tc2.form_id, ;
                tc2.acces_test_id, ;
                tc2.testdate, ;
                tc2.test_seq, ;
                tc2.type_desc, ;
                tc2.result_desc, ;
                tc2.program_name, ;
                tc2.worker_name; 
       From tmp_ctr tc1;
            inner join t_id on ;
                  tc1.ctr_id = t_id.ctr_id ; 
              And t_id.id_num > 1 ;
              And tc1.testtech = 2 ;
              And (tc1.result = 1 Or tc1.result = 2 Or tc1.result = 4 Or tc1.result = 5 Or tc1.result = 6);
            Inner Join tmp_ctr tc2  On ;
                  tc1.ctr_id = tc2.ctr_id ; 
              And (tc2.testtech = 1  And ;
                    (tc2.result = 0 Or tc2.result = 4 Or tc2.result = 5 Or tc2.result = 6)) ;
              And Val(tc2.test_seq) > Val(tc1.test_seq) ;
              And tc1.conftest <> 1
    
    **2B first test is Rapid - Positive or rapid NAAT positive and there is no second test            
       Insert into tmp_miss; 
         Select Distinct ;
                 2  as section, ;
                'Confirmatory Results Not Entered' as section_caption, ;  
                tc1.id_no, ;
                tc1.form_id, ;
                tc1.acces_test_id, ;
                tc1.testdate, ;
                tc1.test_seq, ;
                tc1.type_desc, ;
                tc1.result_desc, ;
                tc1.program_name, ;
                tc1.worker_name; 
       From tmp_ctr tc1;
            inner join t_id on ;
                  tc1.ctr_id = t_id.ctr_id ; 
              And t_id.id_num = 1 ;
              And tc1.testtech = 2 ;
              And (tc1.result = 1 Or tc1.result = 2) ;
              And tc1.conftest <> 1

    **2C If the first and second tests are both Rapid Positive (or Rapid NAAT pos), 
       ** and no third test with a Positve, NAAT Positive or Negative Result.   
    
       **If the first rapid test has a result of inderminant, invalid or no result and 
      **    the second test is rapid positive or rapid NAAT positive   and no third test

        Insert into tmp_miss; 
         Select Distinct ;
                 2  as section, ;
                'Confirmatory Results Not Entered' as section_caption, ;  
                tc1.id_no, ;
                tc1.form_id, ;
                tc1.acces_test_id, ;
                tc1.testdate, ;
                tc1.test_seq, ;
                tc1.type_desc, ;
                tc1.result_desc, ;
                tc1.program_name, ;
                tc1.worker_name; 
         From tmp_ctr tc1;
            inner join t_id on ;
                  tc1.ctr_id = t_id.ctr_id ; 
              And t_id.id_num = 2 ;
              And tc1.testtech = 2 ;
              And (tc1.result = 1 Or tc1.result = 2 Or tc1.result = 4 Or tc1.result = 5 Or tc1.result = 6);
              And tc1.conftest <> 1 ;
        Inner Join tmp_ctr tc2  On ;
                  tc1.ctr_id = tc2.ctr_id ; 
              And (tc2.testtech = 2  And ;
                    (tc2.result = 1 Or tc2.result = 2 Or tc2.result = 4 Or tc2.result = 5 Or tc2.result = 6)) ;
              And Val(tc2.test_seq) <> Val(tc1.test_seq)       
       
  **VT 04/06/2009 Dev Tick 5129                     
*!*          From tmp_ctr tc1;
*!*               inner join t_id on ;
*!*                     tc1.ctr_id = t_id.ctr_id ; 
*!*                 And t_id.id_num = 2 ;
*!*                 And tc1.testtech = 2 ;
*!*                 And (tc1.result = 1 Or tc1.result = 2 Or tc1.result = 4 Or tc1.result = 5 Or tc1.result = 6);
*!*                 And tc1.conftest <> 1
              
             
        **VT 10/28/2008 Supp Tick 19973     
*!*          From tmp_ctr ;
*!*               inner join t_id on ;
*!*                  tmp_ctr.ctr_id = t_id.ctr_id ; 
*!*          Where (testtech = 2 and (result = 1 Or result = 2) And test_seq = '01' And resltprov <> 1);
*!*             Or (testtech = 1 and (result = 1 Or result = 2) And test_seq <> '01' )
     
     
     Use In t_id
          
*** 3.  Test Results Not Entered
   Insert into tmp_miss ; 
         Select 3  as section, ;
                'Test Results Not Entered' as section_caption, ;  
                id_no, ;
                form_id, ;
                acces_test_id, ;
                testdate, ;
                test_seq, ;
                type_desc, ;
                result_desc, ;
                program_name, ;
                worker_name; 
       From tmp_ctr ;
       Where result = 0 ;
       And no_testing_provided =.f. ;
       And Rtrim(ctr_id) <> 'N/A' 

**VT 10/28/2008 Supp Tick 19973           
*!*          Where testtech <> 0 ;
*!*             and result = 0 
          

*** 4. Test Info Not Entered 
   Insert into tmp_miss ; 
         Select 4  as section, ;
                'Test Information Not Entered' as section_caption, ;  
                id_no, ;
                form_id, ;
                acces_test_id, ;
                testdate, ;
                test_seq, ;
                type_desc, ;
                result_desc, ;
                program_name, ;
                worker_name;  
       From tmp_ctr ;
       Where no_testing_provided =.f. ;
          And enc_id=214 ;
          And Rtrim(ctr_id) ='N/A' 

**VT 10/28/2008 Supp Tick 19973  
*!*     Where Rtrim(ctr_id) ='N/A' ;
*!*            And !Empty(pworker_id) ;
*!*            And !Empty(form_id)  
                  
 ***VT 03/05/2009 Dev Tick 5201     add   And resltprov = 1                 
 *** 5.  Missing Part D
   Insert into tmp_miss ; 
         Select 5  as section, ;
                'Missing Part D' as section_caption, ;  
                id_no, ;
                form_id, ;
                acces_test_id, ;
                testdate, ;
                test_seq, ;
                type_desc, ;
                result_desc, ;
                program_name, ;
                worker_name ; 
       From tmp_ctr ;
       Where Empty(survey_dt) ;
            And conftest =  1 ; 
            And (result = 1 Or result = 2) ;
            And resltprov = 1
            
 
 **VT 10/28/2008 Supp Tick 19973  
            
*!*      Where Empty(survey_dt) ;
*!*               And testtech =  1 ; 
*!*               And (result = 1 Or result = 2) ;
*!*               And resltprov = 1
*!*       

If Used('ctr_miss')
   Use In ctr_miss
endif 

Select tmp_miss.* ,;
      cDate as cDate, ;
      cTime as cTime ,;  
      Date_from as From_date, ; 
      Date_to as to_date, ;
      Crit as Crit ;
From tmp_miss ;
Into Cursor ctr_miss ;
Order by   section, ;
           id_no, ;
           testdate desc, ;  
           form_id, ;
           acces_test_id, ;
           test_seq 

oApp.msg2user("OFF")

Select ctr_miss
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
          gcRptName = 'rpt_ctr_miss'   
           DO CASE
                CASE lPrev = .f.
                     Report Form rpt_ctr_miss  To Printer Prompt Noconsole NODIALOG 
                CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_ctr_miss', 1, 2)
           ENDCASE
EndIf


RETURN