Parameters lPrev, ;      && Preview     
           aSelvar1, ;   && select parameters from selection list
           nOrder, ;     && order by
           nGroup, ;     && report selection    
           lcTitle, ;    && report selection    
           Date_fr , ;   && from date
           Date_t, ;     && to date   
           Crit , ;      && name of param
           lnStat, ;     && selection(Output)  page 2
           cOrderBy      && order by description

Acopy(aSelvar1, aSelvar2)

cCSite = ""
ccwork = ""
lCProg = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lCProg = aSelvar2(i, 2)
   Endif
     
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      ccwork = aSelvar2(i, 2)
   Endif
   
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

PRIVATE gchelp
gchelp = "Syringe Exchanges Unit Referral"
************************************************************
cWhere = ""
cWhere = IIF(EMPTY(Date_fr), "", " ai_ref.ref_dt >= Date_fr")         
cWhere = cWhere + IIF(EMPTY(Date_t),  "", IIF(!Empty(cWhere),".and.","") + " ai_ref.ref_dt <= Date_t")

***VT 12/17/2008 Dev Tick 4993 V.U.8.3 
*!*   cWhere = cWhere + IIF(EMPTY(cCSite)	, "", IIF(!Empty(cWhere),".and.","") + " ai_enc.site = cCSite")
*!*   cWhere = cWhere + IIF(EMPTY(ccwork), "", IIF(!Empty(cWhere),".and.","") + " ai_enc.worker_id = ccwork")			
*!*   cWhere = cWhere + IIF(EMPTY(lCProg), "", IIF(!Empty(cWhere),".and.","") + " ai_enc.program = lCProg")

cWhere = cWhere + IIF(EMPTY(cCSite), "", IIF(!Empty(cWhere),".and.","") + " needlx.site = cCSite")
cWhere = cWhere + IIF(EMPTY(ccwork), "", IIF(!Empty(cWhere),".and.","") + " needlx.worker_id = ccwork")         
cWhere = cWhere + IIF(EMPTY(lCProg), "", IIF(!Empty(cWhere),".and.","") + " needlx.program = lCProg")

Select 0
Create Cursor ref_unit (header1 C(50), details1 C(50), units1 N(6), ;
                        header2 C(50), details2 C(50), units2 N(6), ;
                        Date_from D(8), Date_to D(8), Crit C(100), ;
                        cDate D(8), cTime C(8))

** Collect all data according to parameters
***VT 12/17/2008 Dev Tick 4993 V.U.8.3 

*!*   Select ;
*!*   	   ai_ref.ref_cat, ;
*!*         ai_ref.ref_for as ref_serv, ;
*!*         ai_ref.ref_id ; 
*!*   From  ai_ref ;
*!*         Left Outer Join ai_enc On ;
*!*               ai_ref.act_id = ai_enc.act_id ;
*!*   Where ;
*!*   	&cWhere ;
*!*   Into Cursor ;
*!*   	tmp_res


Select ;
      ai_ref.ref_cat, ;
      ai_ref.ref_for as ref_serv, ;
      ai_ref.ref_id ; 
From  ai_ref ;
      Inner join needlx On ;
            ai_ref.need_id = needlx.need_id ;
Where ;
   &cWhere ;
Into Cursor ;
   tmp_res

*!* Code 01 Substanse Use Treatment
Select ref_syr_cat.descript as header1, ;
       rcsl.descript as details1, ;
       Count(*) as units1 ; 
From tmp_res ;
     Inner Join ref_cat_serv_link rcsl On ;
                tmp_res.ref_cat = rcsl.ref_cat  And ;
                tmp_res.ref_serv= rcsl.ref_serv ;
     Inner join ref_syr_cat on ;
                ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='01' ; 
Group By ref_syr_cat.descript, rcsl.descript ;  
Into Cursor tmp_sub1 
                

Select  Distinct ;
        ref_syr_cat.descript as header1, ;
        rcsl.descript as details1, ;
        0 as units1 ;
from ref_cat_serv_link rcsl ;
        inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='01' And ;
      rcsl.descript Not in (Select details1 ;
                             From tmp_sub1 )  ;
Into Cursor tmp_sub2      

Select * ;
From  tmp_sub1 ;
Union ;
Select * ;
From  tmp_sub2 ;
Into Cursor tmp_un1  ;                            
Order by details1

nRecUnit1 = _Tally 
 
Use In tmp_sub1
Use In tmp_sub2
      
** Code 02 Medical
Select  ref_syr_cat.descript as header2, ;
        rcsl.descript as details2, ;
        Count(*) as units2 ; 
From tmp_res ;
      Inner Join ref_cat_serv_link rcsl On ;
                 tmp_res.ref_cat = rcsl.ref_cat  And ;
                 tmp_res.ref_serv= rcsl.ref_serv ;
      inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='02' ; 
Group By ref_syr_cat.descript, rcsl.descript ;  
Into Cursor tmp_med1

Select  Distinct ;
        ref_syr_cat.descript as header2, ;
        rcsl.descript as details2, ;
        0 as units2 ;
from ref_cat_serv_link rcsl ;
        inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='02' And ;
      rcsl.descript Not in (Select details2 ;
                             From tmp_med1 ) ;
Into Cursor tmp_med2      

Select * ;
From  tmp_med1 ;
Union ;
Select * ;
From  tmp_med2 ;
Into Cursor tmp_un2  ;                            
Order by details2

nRecUnit2 = _Tally
 
Use In tmp_med1
Use In tmp_med2   
 
** Fill cursor  For Substance Use Treatment and Medical          
If nRecUnit1 >= nRecUnit2
         Insert Into ref_unit ;
               ( header1, ;
                details1, ;
                units1, ;
                Date_from, ;
                Date_to, ;
                Crit,  ;
                cDate, ;
                cTime ) ;
         Select header1, ;
                details1, ;
                units1, ;
                Date_fr as Date_from, ;
                Date_t as Date_to, ;
                Crit as Crit, ;   
                cDate as cDate, ;
                cTime as cTime ;
          From tmp_un1 
          
          Select ref_unit
          Go top
          
          Select tmp_un2
          Scan
             Scatter Memvar
             
             Select ref_unit
             
             Do While .t.
                Gather Memvar
                
                If !Eof()
                   Skip
                Endif

                Exit
             Enddo
               Select tmp_un2
          Endscan
          
          Select ref_unit
          Replace ref_unit.header2 With m.header2 For empty(ref_unit.header2) All
          
Endif

If nRecUnit2 > nRecUnit1
         Insert Into ref_unit ;
               (header2, ;
                details2, ;
                units2, ;
                Date_from, ;
                Date_to, ;
                Crit,  ;
                cDate, ;
                cTime ) ;
         Select header2, ;
                details2, ;
                units2, ;
                Date_fr as Date_from, ;
                Date_t as Date_to, ;
                Crit as Crit, ;   
                cDate as cDate, ;
                cTime as cTime ;
         From tmp_un2 
         
          Select ref_unit
          Go top
          
          Select tmp_un1
          Scan
             Scatter Memvar
             
             Select ref_unit
             
             Do While .t.
                Gather Memvar
                If !Eof()
                   Skip
                Endif

                Exit
             Enddo
               Select tmp_un1
          Endscan
          
          Select ref_unit
          Replace ref_unit.header1 With m.header1 For empty(ref_unit.header1) All
Endif

Release m.header1, m.details1, m.units1, m.header2, m.details2, m.units2

Use In tmp_un1
Use In tmp_un2

** Code 03 Primary Health Care                               
Select  ref_syr_cat.descript as header1, ;
        rcsl.descript as details1, ;
        Count(*) as units1 ; 
From tmp_res ;
      Inner Join ref_cat_serv_link rcsl On ;
                 tmp_res.ref_cat = rcsl.ref_cat  And ;
                 tmp_res.ref_serv= rcsl.ref_serv ;
      inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='03' ; 
Group By ref_syr_cat.descript, rcsl.descript ;  
Into Cursor tmp_ph1 
                

Select  Distinct ;
        ref_syr_cat.descript as header1, ;
        rcsl.descript as details1, ;
        0 as units1 ;
from ref_cat_serv_link rcsl ;
        inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='03' And ;
      rcsl.descript Not in (Select details1 ;
                             From tmp_ph1 )  ;
Into Cursor tmp_ph2      

Select * ;
From  tmp_ph1 ;
Union ;
Select * ;
From  tmp_ph2 ;
Into Cursor tmp_un1  ;                            
Order by details1

nRecUnit1 = _Tally 
 
Use In tmp_ph1
Use In tmp_ph2
      
** Code 04 Miscellaneous    
Select  ref_syr_cat.descript as header2, ;
        rcsl.descript as details2, ;
        Count(*) as units2 ; 
From tmp_res ;
      Inner Join ref_cat_serv_link rcsl On ;
                 tmp_res.ref_cat = rcsl.ref_cat  And ;
                 tmp_res.ref_serv= rcsl.ref_serv ;
      inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='04' ; 
Group By ref_syr_cat.descript, rcsl.descript ;  
Into Cursor tmp_mis1 
                

Select  Distinct ;
        ref_syr_cat.descript as header2, ;
        rcsl.descript as details2, ;
        0 as units2 ;
from ref_cat_serv_link rcsl ;
        inner join ref_syr_cat on ;
                 ref_syr_cat.code = rcsl.ref_syr_cat ;
Where ref_syr_cat.code ='04' And ;
      rcsl.descript Not in (Select details2 ;
                             From tmp_mis1 )  ;
Into Cursor tmp_mis2      

Select * ;
From  tmp_mis1 ;
Union ;
Select * ;
From  tmp_mis2 ;
Into Cursor tmp_un2  ;                            
Order by details2

nRecUnit2 = _Tally
 
Use In tmp_mis1
Use In tmp_mis2   
 
Select ref_unit
nRefCount = Reccount() 

** Fill cursor  For Primary Health Care and Miscellaneous          
If nRecUnit1 >= nRecUnit2
         Insert Into ref_unit ;
               ( header1, ;
                details1, ;
                units1, ;
                Date_from, ;
                Date_to, ;
                Crit,  ;
                cDate, ;
                cTime ) ;
         Select header1, ;
                details1, ;
                units1, ;
                Date_fr as Date_from, ;
                Date_t as Date_to, ;
                Crit as Crit, ;   
                cDate as cDate, ;
                cTime as cTime ;
          From tmp_un1 
          
          nRec = nRefCount + 1
          Select ref_unit
          Go nRec
          
          Select tmp_un2
          Scan
             Scatter Memvar
             
             Select ref_unit
             
             Do While .t.
                Gather Memvar
                
                If !Eof()
                   Skip
                Endif

                Exit
             Enddo
               Select tmp_un2
          Endscan
          
          Select ref_unit
          Replace ref_unit.header2 With m.header2 For empty(ref_unit.header2) All
          
Endif

If nRecUnit2 > nRecUnit1
         Insert Into ref_unit ;
               (header2, ;
                details2, ;
                units2, ;
                Date_from, ;
                Date_to, ;
                Crit,  ;
                cDate, ;
                cTime ) ;
         Select header2, ;
                details2, ;
                units2, ;
                Date_fr as Date_from, ;
                Date_t as Date_to, ;
                Crit as Crit, ;   
                cDate as cDate, ;
                cTime as cTime ;
         From tmp_un2 
         
          nRec = nRefCount + 1
          Select ref_unit
          Go nRec
          
          Select tmp_un1
          Scan
             Scatter Memvar
             
             Select ref_unit
             
             Do While .t.
                Gather Memvar
                If !Eof()
                   Skip
                Endif

                Exit
             Enddo
               Select tmp_un1
          Endscan
          
          Select ref_unit
          Replace ref_unit.header1 With m.header1 For empty(ref_unit.header1) All
Endif

Release All
Use In tmp_un1
Use In tmp_un2
Use in tmp_res

   
oApp.msg2user('OFF')

Select ref_unit
Go top 
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   gcRptName = 'rpt_syr_ref'
   DO CASE
       CASE lPrev = .f.
         Report Form rpt_syr_ref  To Printer Prompt Noconsole NODIALOG
         
       CASE lPrev = .t.    
         oApp.rpt_print(5, .t., 1, 'rpt_syr_ref', 1, 2)
         
    ENDCASE
Endif
