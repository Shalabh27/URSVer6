Parameters            ;
              lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              from_d , ;         && from date
              to_d, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)
cCSite    = ""
lcProgX   = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgX = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()
cFiltExpr = IIF(EMPTY(cCSite)   ,   "", "AND needlx.site = cCSite")

STORE 0 TO Grand_tot,T_Female_n,T_Male_n,T_TG_N,t_ne_n
 
If Used('temp')
   Use in temp
Endif


If InList(lnStat, 1, 2) 
     SELECT ;
            Needlx.Tc_Id as Tc_Id ,;
            Needlx.Program,;
            Space(2) as Ethnic     ,;
            Iif(client.hispanic = 2, "Hispanic" + Space(42), Iif(client.hispanic = 1, "Non-Hispanic" + Space(38), ;
            "Unknown/Unreported" + Space(32))) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Ethnicity' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date, from_d, To_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx  and ;
              (client.hispanic = 2 or client.hispanic = 1 or client.hispanic = 0) ;
      &cFiltExpr ;   
       INTO CURSOR ;
            temp 
       
      * White       
      If Used('Race1')
         Use in Race1
      EndIf
            
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program, ;
            '10' AS Ethnic     ,;
            'White' + SPACE(45) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.white = 1  and ;      
              (client.blafrican + client.asian + client.hawaisland + ;
                client.indialaska + client.someother) = 0 ;
      &cFiltExpr ;   
      INTO CURSOR ;
            Race1 
              
      If Used('Race2')
         Use in Race2
      EndIf
         
      * Black  or African
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program, ;
            '20' AS Ethnic     ,;
            'Black or African-American' + SPACE(25) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.blafrican = 1 and ;
              (client.white + client.asian + client.hawaisland + ;
                client.indialaska + client.someother) = 0    ;   
      &cFiltExpr ;   
      INTO CURSOR ;
            Race2   
      
      If Used('Race3')
         Use in Race3
      EndIf
      * Asian
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program, ;
            '30' AS Ethnic     ,;
            'Asian' + SPACE(45) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.asian = 1 and ;
                 (client.white + client.blafrican + client.hawaisland + ;
                client.indialaska + client.someother) = 0 ;      
      &cFiltExpr ;   
      INTO CURSOR ;
            Race3    

      If Used('Race4')
         Use in Race4
      EndIf
      * Native Hawaiian
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program AS Program      ,;
            '40' AS Ethnic     ,;
            'Native Hawaiian/Pacific Islander' + SPACE(18) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.hawaisland = 1 and ;
              (client.blafrican + client.asian + client.white + ;
             client.indialaska + client.someother) = 0 ;            
      &cFiltExpr ;   
      INTO CURSOR ;
            Race4

      If Used('Race5')
         Use in Race5
      EndIf
      * American Indian or Alaskan
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program AS Program      ,;
            '50' AS Ethnic     ,;
            'American Indian or Alaskan Native' + SPACE(17) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.indialaska = 1 and ;   
              (client.blafrican + client.asian + client.white + ;
            client.hawaisland + client.someother) = 0 ;
      &cFiltExpr ;   
      INTO CURSOR ;
            Race5 
         
      If Used('Race6')
         Use in Race6
      EndIf      
      * Unknown
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program AS Program      ,;
            '90' AS Ethnic     ,;
            'Unknown/unreported' + SPACE(32) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              (client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.unknowrep + client.someother = 0 ;
              or ;
              (client.unknowrep = 1 and ;
                 client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.someother = 0)) ;      
      &cFiltExpr ;   
      INTO CURSOR ;
            Race6 
            
      If Used('Race7')
         Use in Race7
      EndIf 
      * Some Other
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program AS Program      ,;
            '70' AS Ethnic     ,;
            'Some Other Race   ' + SPACE(32) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.someother = 1 and ;
              (client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska) = 0 ;      
      &cFiltExpr ;   
      INTO CURSOR ;
            Race7 
  
      If Used('temp1')
           Use in temp1
      EndIf
     
      Select * ;
         From race1 ;
      Union  ;          
      Select * ;
         From race2 ;
      Union  ;    
      Select * ;
         From race3 ;
      Union  ;    
      Select * ;
         From race4 ;
      Union  ;    
      Select * ;
         From race5 ;
      Union  ;    
      Select * ;
         From race6 ;
      Union  ;    
      Select * ;
         From race7 ;      
      Into Cursor temp1 
        
      =clean_race()   
      
      If Used('temp3')
           Use in temp3
      EndIf
      **More Than 1 race
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            Needlx.Program AS Program      ,;
            '60' AS Ethnic     ,;
            'More Than 1 Race  ' + SPACE(32) AS EthnicDesc ,;
            Client.Gender    AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              (client.indialaska + client.blafrican + client.asian + client.white + ;
                client.hawaisland + client.someother) > 1 ;      
      &cFiltExpr ;   
      INTO CURSOR ;
            temp3 
EndIf
      
Do Case
Case lnStat = 1 &&Syringe Clients by Age,Ethnicity,Gender - All
      rep_title1='Syringe Exchange - Summary of Participants Served'
      rep_title2='by Ethnicity/Race, Gender, and Age: All Participants'

      If Used('FirstCt1')
         Use in FirstCt1
      EndIf
         
      Select * ;
         From temp ;
      Union ;
      Select * ;
         From temp1 ;
      Union ;
      Select * ;
         From temp3 ;   
      INTO CURSOR ;
            FirstCt1 
        
      oApp.ReopenCur('FirstCt1','FirstCut')      
      =clean_temp()
   
      SELECT FirstCut
      REPLACE ALL Client_Age WITH IIF(!EMPTY(Dob),oApp.AGE(to_d,Dob),00) 
      REPLACE ALL gender WITH '12' for gender ='13'
      
 
     **VT 02/25/2009 Dev Tick 5156
     ** Select distinct value before summary
      SELECT Distinct ;
            tc_id, ;
            EthnicDesc,;
            GenderDesc, ;
            Gender    , ;
            dob,        ;
            Client_Age, ;
            type ;
         FROM ;
            FirstCut ;
        INTO CURSOR ;
             CutDis
             
      If Used('RepCurs2')
         Use in RepCurs2
      Endif
                  
     * summary info
       **VT 02/25/2009 Dev Tick 5156 change from FirstCut -> CutDis  
      SELECT ;
            EthnicDesc,;
            GenderDesc,;
            Gender,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,19), 1,0))         AS Age0_19_n   ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,20,29),1,0))        AS Age20_29_n  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,30,39),1,0))        AS Age30_39_n  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,40,49),1,0))        AS Age40_49_n  ,;
            SUM(IIF(!Empty(dob) AND Client_Age >= 50,1,0))                   AS Age50plusn  ,;
            SUM(IIF(Empty(dob),1,0))                                        AS AgeUnknown  ,;
            0000000                                                          AS T_Ethgen_n,  ;
               type ;
         FROM ;
            CutDis ;
         GROUP BY ;
              type, EthnicDesc, GenderDesc, gender ;
         INTO CURSOR ;
            RepCurs2
               
         oApp.ReopenCur('RepCurs2','RepCurs')      
         SELECT RepCurs
         * sum rows now for totals by ethnicity+gender
         REPLACE ALL T_Ethgen_n WITH Age0_19_n + Age20_29_n + Age30_39_n + Age40_49_n + Age50plusn + AgeUnknown 

         If Used('t_total')
            Use in t_total
         EndIf
      
         * grand total sums
         Select Sum(T_Ethgen_n) as Grand_tot, ;
               000000.00 as T_Female_n, ;
               000000.00 as T_Male_n, ;
               000000.00 as T_TG_N, ;
               000000.00 as T_ne_N, ;
               000000.00 as gr_f_19, ;
               000000.00 as gr_f_29, ;
               000000.00 as gr_f_39, ;
               000000.00 as gr_f_49, ;
               000000.00 as gr_f_50, ;
               000000.00 as gr_f_unk, ;
               000000.00 as gr_m_19, ;
               000000.00 as gr_m_29, ;
               000000.00 as gr_m_39, ;
               000000.00 as gr_m_49, ;
               000000.00 as gr_m_50, ;
               000000.00 as gr_m_unk, ;
               000000.00 as gr_n_19, ;
               000000.00 as gr_n_29, ;
               000000.00 as gr_n_39, ;
               000000.00 as gr_n_49, ;
               000000.00 as gr_n_50, ;
               000000.00 as gr_n_unk, ;
               000000.00 as gr_t_19, ;
               000000.00 as gr_t_29, ;
               000000.00 as gr_t_39, ;
               000000.00 as gr_t_49, ;
               000000.00 as gr_t_50, ;
               000000.00 as gr_t_unk, ;
               000000.00 as gr_all_19, ;
               000000.00 as gr_all_29, ;
               000000.00 as gr_all_39, ;
               000000.00 as gr_all_49, ;
               000000.00 as gr_all_50, ;
               000000.00 as gr_all_unk, ;
               type ;
         From RepCurs ;
         Group by type ;
         Into Cursor t_total

         Index on type tag type 

         oApp.ReopenCur('t_total','total')   
         Set Order to type   

         Store 0 to T_Female_1 , T_Male_1, T_TG_1, T_ne_1
         
         SELECT RepCurs
         Go top

         SUM T_Ethgen_n TO T_Female_1 FOR gender = '10' and type = 'Ethnicity'
         SUM T_Ethgen_n TO T_Male_1   FOR gender = '11' and type = 'Ethnicity'
         SUM T_Ethgen_n TO T_TG_1     FOR gender = '12' and type = 'Ethnicity'
         SUM T_Ethgen_n TO T_ne_1     FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'

      Select total
      Replace total.T_Female_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Female_1/total.Grand_tot), 2)) ,;
            total.T_Male_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Male_1/total.Grand_tot), 2)) ,;
            total.T_TG_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_TG_1/total.Grand_tot), 2)) ,;
            total.T_ne_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_ne_1/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'

      ***Female Ethnicity
      Store 0 to  gr_f1_19, gr_f1_29, gr_f1_39, gr_f1_49, gr_f1_50, gr_f1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_f1_19   FOR gender = '10' and type = 'Ethnicity'
      Sum Age20_29_n to gr_f1_29 FOR gender = '10' and type = 'Ethnicity'
      Sum Age30_39_n to gr_f1_39 FOR gender = '10' and type = 'Ethnicity'
      Sum Age40_49_n to gr_f1_49 FOR gender = '10' and type = 'Ethnicity'
      Sum Age50plusn to gr_f1_50 FOR gender = '10' and type = 'Ethnicity'
      Sum AgeUnknown to gr_f1_unk FOR gender = '10' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_f_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_19/total.Grand_tot), 2)) ,;
              total.gr_f_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_29/total.Grand_tot), 2)) ,;
              total.gr_f_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_39/total.Grand_tot), 2)) ,;
              total.gr_f_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_49/total.Grand_tot), 2)) ,;
              total.gr_f_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_50/total.Grand_tot), 2)) ,;
              total.gr_f_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'
             
      ***Male Ethnicity
      Store 0 to  gr_m1_19, gr_m1_29, gr_m1_39, gr_m1_49, gr_m1_50, gr_m1_unk   
      SELECT RepCurs
      Go top
        
      Sum Age0_19_n to gr_m1_19 FOR gender='11' and type='Ethnicity'
      Sum Age20_29_n to gr_m1_29 FOR gender='11' and type='Ethnicity'
      Sum Age30_39_n to gr_m1_39 FOR gender='11' and type='Ethnicity'
      Sum Age40_49_n to gr_m1_49 FOR gender='11' and type='Ethnicity'
      Sum Age50plusn to gr_m1_50 FOR gender='11' and type='Ethnicity'
      Sum AgeUnknown to gr_m1_unk FOR gender='11' and type='Ethnicity'
      
      Select total
      Replace ;
          total.gr_m_19 With Iif(total.Grand_tot=0, 0, Round(100*(gr_m1_19/total.Grand_tot), 2)) ,;
          total.gr_m_29 with Iif(total.Grand_tot=0, 0, Round(100*(gr_m1_29/total.Grand_tot), 2)) ,;
          total.gr_m_39 with Iif(total.Grand_tot=0, 0, Round(100*(gr_m1_39/total.Grand_tot), 2)) ,;
          total.gr_m_49 with Iif(total.Grand_tot=0, 0, Round(100*(gr_m1_49/total.Grand_tot), 2)) ,;
          total.gr_m_50 with Iif(total.Grand_tot=0, 0, Round(100*(gr_m1_50/total.Grand_tot), 2)) ,;
          total.gr_m_unk with Iif(total.Grand_tot=0, 0, Round(100*(gr_m1_unk/total.Grand_tot), 2)) ;
        For type = 'Ethnicity'
      
      ***Not Entered Ethnicity
      Store 0 to  gr_n1_19, gr_n1_29, gr_n1_39, gr_n1_49, gr_n1_50, gr_n1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_n1_19   FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age20_29_n to gr_n1_29 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age30_39_n to gr_n1_39 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age40_49_n to gr_n1_49 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age50plusn to gr_n1_50 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum AgeUnknown to gr_n1_unk FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_n_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_19/total.Grand_tot), 2)) ,;
              total.gr_n_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_29/total.Grand_tot), 2)) ,;
              total.gr_n_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_39/total.Grand_tot), 2)) ,;
              total.gr_n_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_49/total.Grand_tot), 2)) ,;
              total.gr_n_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_50/total.Grand_tot), 2)) ,;
              total.gr_n_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'           
                
     ***Transgender Ethnicity
      Store 0 to  gr_t1_19, gr_t1_29, gr_t1_39, gr_t1_49, gr_t1_50, gr_t1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_t1_19   FOR gender = '12' and type = 'Ethnicity'
      Sum Age20_29_n to gr_t1_29 FOR gender = '12' and type = 'Ethnicity'
      Sum Age30_39_n to gr_t1_39 FOR gender = '12' and type = 'Ethnicity'
      Sum Age40_49_n to gr_t1_49 FOR gender = '12' and type = 'Ethnicity'
      Sum Age50plusn to gr_t1_50 FOR gender = '12' and type = 'Ethnicity'
      Sum AgeUnknown to gr_t1_unk FOR gender = '12' and type = 'Ethnicity'
      
     
      Select total
      Replace total.gr_t_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_19/total.Grand_tot), 2)) ,;
              total.gr_t_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_29/total.Grand_tot), 2)) ,;
              total.gr_t_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_39/total.Grand_tot), 2)) ,;
              total.gr_t_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_49/total.Grand_tot), 2)) ,;
              total.gr_t_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_50/total.Grand_tot), 2)) ,;
              total.gr_t_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'           
     
      ***Grand Total Ethnicity   
      Store 0 to gr_all1_19, gr_all1_29, gr_all1_39, gr_all1_49, gr_all1_50, gr_all1_unk
      
      gr_all1_19 = gr_f1_19 + gr_m1_19 + gr_n1_19 + gr_t1_19
      gr_all1_29 = gr_f1_29 + gr_m1_29 + gr_n1_29 + gr_t1_29
      gr_all1_39 = gr_f1_39 + gr_m1_39 + gr_n1_39 + gr_t1_39
      gr_all1_49 = gr_f1_49 + gr_m1_49 + gr_n1_49 + gr_t1_49 
      gr_all1_50 = gr_f1_50 + gr_m1_50 + gr_n1_50 + gr_t1_50
      gr_all1_unk = gr_f1_unk + gr_m1_unk + gr_n1_unk + gr_t1_unk
      
      Select total
      Replace total.gr_all_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_19/total.Grand_tot), 2)) ,;
              total.gr_all_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_29/total.Grand_tot), 2)) ,;
              total.gr_all_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_39/total.Grand_tot), 2)) ,;
              total.gr_all_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_49/total.Grand_tot), 2)) ,;
              total.gr_all_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_50/total.Grand_tot), 2)) ,;
              total.gr_all_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'           
      
     **************RACE               
     Store 0 to T_Female_1 , T_Male_1, T_TG_1, T_ne_1
         
     SELECT RepCurs
     Go top

      SUM T_Ethgen_n TO T_Female_1 FOR gender = '10' and type = 'Race'
      SUM T_Ethgen_n TO T_Male_1   FOR gender = '11' and type = 'Race'
      SUM T_Ethgen_n TO T_TG_1     FOR gender = '12' and type = 'Race'
      SUM T_Ethgen_n TO T_ne_1     FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      
      Select total
      Replace total.T_Female_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Female_1/total.Grand_tot), 2)) ,;
            total.T_Male_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Male_1/total.Grand_tot), 2)) ,;
            total.T_TG_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_TG_1/total.Grand_tot), 2)) ,;
            total.T_ne_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_ne_1/total.Grand_tot), 2)) ; 
            for type = 'Race'
            
      **Female Race
      Store 0 to  gr_f1_19, gr_f1_29, gr_f1_39, gr_f1_49, gr_f1_50, gr_f1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_f1_19   FOR gender = '10' and type = 'Race'
      Sum Age20_29_n to gr_f1_29 FOR gender = '10' and type = 'Race'
      Sum Age30_39_n to gr_f1_39 FOR gender = '10' and type = 'Race'
      Sum Age40_49_n to gr_f1_49 FOR gender = '10' and type = 'Race'
      Sum Age50plusn to gr_f1_50 FOR gender = '10' and type = 'Race'
      Sum AgeUnknown to gr_f1_unk FOR gender = '10' and type = 'Race'
      
      Select total
      Replace total.gr_f_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_19/total.Grand_tot), 2)) ,;
              total.gr_f_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_29/total.Grand_tot), 2)) ,;
              total.gr_f_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_39/total.Grand_tot), 2)) ,;
              total.gr_f_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_49/total.Grand_tot), 2)) ,;
              total.gr_f_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_50/total.Grand_tot), 2)) ,;
              total.gr_f_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
      
      ***Male Race
      Store 0 to  gr_m1_19, gr_m1_29, gr_m1_39, gr_m1_49, gr_m1_50, gr_m1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_m1_19   FOR gender = '11' and type = 'Race'
      Sum Age20_29_n to gr_m1_29 FOR gender = '11' and type = 'Race'
      Sum Age30_39_n to gr_m1_39 FOR gender = '11' and type = 'Race'
      Sum Age40_49_n to gr_m1_49 FOR gender = '11' and type = 'Race'
      Sum Age50plusn to gr_m1_50 FOR gender = '11' and type = 'Race'
      Sum AgeUnknown to gr_m1_unk FOR gender = '11' and type = 'Race'
      
      Select total
      Replace total.gr_m_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_19/total.Grand_tot), 2)) ,;
              total.gr_m_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_29/total.Grand_tot), 2)) ,;
              total.gr_m_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_39/total.Grand_tot), 2)) ,;
              total.gr_m_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_49/total.Grand_tot), 2)) ,;
              total.gr_m_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_50/total.Grand_tot), 2)) ,;
              total.gr_m_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
                
      ***Not Entered Race
      Store 0 to  gr_n1_19, gr_n1_29, gr_n1_39, gr_n1_49, gr_n1_50, gr_n1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_n1_19   FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age20_29_n to gr_n1_29 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age30_39_n to gr_n1_39 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age40_49_n to gr_n1_49 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age50plusn to gr_n1_50 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum AgeUnknown to gr_n1_unk FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      
      Select total
      Replace total.gr_n_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_19/total.Grand_tot), 2)) ,;
              total.gr_n_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_29/total.Grand_tot), 2)) ,;
              total.gr_n_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_39/total.Grand_tot), 2)) ,;
              total.gr_n_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_49/total.Grand_tot), 2)) ,;
              total.gr_n_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_50/total.Grand_tot), 2)) ,;
              total.gr_n_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'        
                
     ***Transgender Race
      Store 0 to  gr_t1_19, gr_t1_29, gr_t1_39, gr_t1_49, gr_t1_50, gr_t1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_t1_19   FOR gender = '12' and type = 'Race'
      Sum Age20_29_n to gr_t1_29 FOR gender = '12' and type = 'Race'
      Sum Age30_39_n to gr_t1_39 FOR gender = '12' and type = 'Race'
      Sum Age40_49_n to gr_t1_49 FOR gender = '12' and type = 'Race'
      Sum Age50plusn to gr_t1_50 FOR gender = '12' and type = 'Race'
      Sum AgeUnknown to gr_t1_unk FOR gender = '12' and type = 'Race'
      
      Select total
      Replace total.gr_t_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_19/total.Grand_tot), 2)) ,;
              total.gr_t_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_29/total.Grand_tot), 2)) ,;
              total.gr_t_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_39/total.Grand_tot), 2)) ,;
              total.gr_t_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_49/total.Grand_tot), 2)) ,;
              total.gr_t_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_50/total.Grand_tot), 2)) ,;
              total.gr_t_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
      
     ***Grand Total Race   
      Store 0 to gr_all1_19, gr_all1_29, gr_all1_39, gr_all1_49, gr_all1_50, gr_all1_unk
      
      gr_all1_19 = gr_f1_19 + gr_m1_19 + gr_n1_19 + gr_t1_19
      gr_all1_29 = gr_f1_29 + gr_m1_29 + gr_n1_29 + gr_t1_29
      gr_all1_39 = gr_f1_39 + gr_m1_39 + gr_n1_39 + gr_t1_39
      gr_all1_49 = gr_f1_49 + gr_m1_49 + gr_n1_49 + gr_t1_49 
      gr_all1_50 = gr_f1_50 + gr_m1_50 + gr_n1_50 + gr_t1_50
      gr_all1_unk = gr_f1_unk + gr_m1_unk + gr_n1_unk + gr_t1_unk
      
      Select total
      Replace total.gr_all_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_19/total.Grand_tot), 2)) ,;
              total.gr_all_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_29/total.Grand_tot), 2)) ,;
              total.gr_all_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_39/total.Grand_tot), 2)) ,;
              total.gr_all_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_49/total.Grand_tot), 2)) ,;
              total.gr_all_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_50/total.Grand_tot), 2)) ,;
              total.gr_all_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'         
                        
      If Used('RepCursT')
         Use in RepCursT
      endif   
      
      
      oApp.msg2user('OFF')
      
      Select RepCurs.* ,;
            total.Grand_tot, ;
            total.T_Male_n, ;
            total.T_TG_N, ;
            total.T_ne_N, ;
            total.gr_f_19,;
            total.gr_f_29, ;
            total.gr_f_39, ;
            total.gr_f_49, ;
            total.gr_f_50, ;
            total.gr_f_unk, ;
            total.T_Female_n, ;
            total.gr_m_19, ;
            total.gr_m_29, ;
            total.gr_m_39, ;
            total.gr_m_49, ;
            total.gr_m_50, ;
            total.gr_m_unk, ;
            total.gr_n_19, ;
            total.gr_n_29, ;
            total.gr_n_39, ;
            total.gr_n_49, ;
            total.gr_n_50, ;
            total.gr_n_unk, ;
            total.gr_t_19, ;
            total.gr_t_29, ;
            total.gr_t_39, ;
            total.gr_t_49, ;
            total.gr_t_50, ;
            total.gr_t_unk, ;
            total.gr_all_19, ;
            total.gr_all_29, ;
            total.gr_all_39, ;
            total.gr_all_49, ;
            total.gr_all_50, ;
            total.gr_all_unk, ;
            rep_title1 as rep_title1, ;
            rep_title2 as rep_title2, ;
            Crit as Crit, ;   
            cDate as cDate, ;
            cTime as cTime, ;
            from_d as Date_from, ;
            to_d as date_to;      
      from RepCurs ;
            inner join total on ;
               RepCurs.type = total.type ;
      into cursor  RepCursT
   
      
      Go Top
      If EOF()
           oApp.msg2user('NOTFOUNDG')
      Else
                gcRptName = 'rpt_syr_tab2'
                Do Case
                     CASE lPrev = .f.
                          Report Form rpt_syr_tab2 To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_syr_tab2', 1, 2)
                 EndCase
       Endif 
         

Case lnStat = 2 &&Syringe Clients by Age,Ethnicity,Gender - New
      rep_title1='Syringe Exchange - Summary of Participants Served'
      rep_title2='by Ethnicity/Race, Gender, and Age: New Participants'

      If Used('FirstC1a')
           Use in  FirstC1a
      EndIf
      
      Select * ;
         From temp ;
      Union ;
      Select * ;
         From temp1 ;
      Union ;
      Select * ;
         From temp3 ;   
      INTO CURSOR ;
            FirstC1a 
   
      =clean_temp()
      
* jss, 12/07, modify method of determining "New" clients: no longer based on enrollment or intake dates.
*             Will now be based strictly on initial transaction
*!*         If Used('FirstC1b')
*!*              Use in  FirstC1b
*!*         EndIf
*!*         
*!*         SELECT   * ;
*!*         FROM ;
*!*            FirstC1a ;
*!*         WHERE ;
*!*            FirstC1a.tc_id IN ;
*!*               (SELECT Ai_Prog.tc_id ;
*!*                FROM    Ai_Prog ;
*!*                WHERE    Ai_Prog.Start_Dt >= from_d AND Ai_Prog.Start_Dt <= to_d ;
*!*                  AND   Ai_Prog.program = FirstC1a.Program) ;
*!*         INTO CURSOR FirstC1b
*!*          
*!*         If Used('FirstC1c')
*!*              Use in  FirstC1c
*!*         EndIf
*!*         
*!*         SELECT * ;
*!*         FROM ;
*!*            FirstC1a ;
*!*         WHERE ;
*!*            FirstC1a.tc_id IN ;
*!*               (SELECT Ai_Clien.tc_id ;
*!*                FROM    Ai_Clien ;
*!*                WHERE   Ai_Clien.Placed_Dt >= from_d AND Ai_Clien.Placed_Dt <= to_d) ;
*!*         INTO CURSOR ;
*!*            FirstC1c
*!*            
*!*         If Used('FirstCt1')
*!*              Use in  FirstCt1
*!*         EndIf
*!*      
*!*         SELECT * ;
*!*         FROM ;
*!*            FirstC1b ;
*!*         UNION ;
*!*         SELECT * ;
*!*         FROM ;
*!*            FirstC1c ;
*!*         INTO CURSOR ;
*!*            FirstCt1

*!*         If Used('FirstC1a')
*!*              Use in  FirstC1a
*!*         EndIf
*!*         If Used('FirstC1b')
*!*              Use in  FirstC1b
*!*         EndIf
*!*         If Used('FirstC1c')
*!*              Use in  FirstC1c
*!*         EndIf
*!*         
      If Used('FirstCut')
           Use in  FirstCut
      EndIf

* first, get all clients who have had a transaction prior to this start date
     ** Select Distinct tc_id from needlx where date < from_d Into Cursor curPrior  
      
      **03/05/2008 VT Find first transaction for selected clients
      Select Distinct needlx.tc_id, ;
             Min(needlx.date) as n_date ;
      from needlx ;
         Inner Join FirstC1a On ;
            FirstC1a.tc_id = needlx.tc_id ;
     Into Cursor curPrior  ;
     Group By needlx.tc_id
      
* now, of selected clients, which had no prior transactions? they are our new clients...
*!*         Select * from FirstC1a ;
*!*         Where FirstC1a.tc_id ;
*!*            Not in (Select curPrior.tc_id from curPrior) ;
*!*         Into Cursor FirstCt1 


      **03/05/2008 VT Select new clients in reporting period
      Select FirstC1a.* ;
      from FirstC1a ;
            Inner Join  curPrior On ;
               curPrior.tc_id = FirstC1a.tc_id And ;
               curPrior.n_date Between from_d And to_d ;
      Into Cursor FirstCt1 
      
      If Used('FirstC1a')
           Use in FirstC1a
      EndIf
      
      If Used('curPrior')
           Use in curPrior
      EndIf
      
      oApp.ReopenCur('FirstCt1','FirstCut')      
      SELECT FirstCut

      REPLACE ALL Client_Age WITH IIF(!EMPTY(Dob),oApp.AGE(to_d,Dob),00) 
      REPLACE ALL gender WITH '12' for gender ='13'

     **VT 04/03/2009 Dev Tick 5156
     ** Select distinct value before summary
      SELECT Distinct ;
            tc_id, ;
            EthnicDesc,;
            GenderDesc, ;
            Gender    , ;
            dob,        ;
            Client_Age, ;
            type ;
         FROM ;
            FirstCut ;
        INTO CURSOR ;
             CutDis
             
      If Used('RepCurs2')
         Use in RepCurs2
      Endif
                  
     * summary info
       **VT 04/03/2009 Dev Tick 5156 change from FirstCut -> CutDis  
      SELECT ;
            EthnicDesc             ,;
            GenderDesc             ,;
            Gender     ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,19), 1,0))         AS Age0_19_n   ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,20,29),1,0))        AS Age20_29_n  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,30,39),1,0))        AS Age30_39_n  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,40,49),1,0))        AS Age40_49_n  ,;
            SUM(IIF(!Empty(dob) AND Client_Age >= 50,1,0))                   AS Age50plusn  ,;
            SUM(IIF(Empty(dob),1,0))                                        AS AgeUnknown  ,;
            0000000                                                          AS T_Ethgen_n,  ;
               type ;
         FROM ;
            CutDis ;
         GROUP BY ;
              type, EthnicDesc, GenderDesc, gender ;
         INTO CURSOR ;
            RepCurs2
               
      If Used('RepCurs')
           Use in  RepCurs
      EndIf
   
      oApp.ReopenCur('RepCurs2','RepCurs')      
      SELECT RepCurs
      
      * sum rows now for totals by ethnicity+gender
      REPLACE ALL T_Ethgen_n WITH Age0_19_n + Age20_29_n + Age30_39_n + Age40_49_n + Age50plusn + AgeUnknown 
      
      If Used('t_total')
           Use in  t_total
      EndIf

      If Used('total')
           Use in  total
      EndIf
      
      * grand total sums
      Select Sum(T_Ethgen_n) as Grand_tot, ;
            000000.00 as T_Female_n, ;
            000000.00 as T_Male_n, ;
            000000.00 as T_TG_N, ;
            000000.00 as T_ne_N, ;
            000000.00 as gr_f_19, ;
            000000.00 as gr_f_29, ;
            000000.00 as gr_f_39, ;
            000000.00 as gr_f_49, ;
            000000.00 as gr_f_50, ;
            000000.00 as gr_f_unk, ;
            000000.00 as gr_m_19, ;
            000000.00 as gr_m_29, ;
            000000.00 as gr_m_39, ;
            000000.00 as gr_m_49, ;
            000000.00 as gr_m_50, ;
            000000.00 as gr_m_unk, ;
            000000.00 as gr_n_19, ;
            000000.00 as gr_n_29, ;
            000000.00 as gr_n_39, ;
            000000.00 as gr_n_49, ;
            000000.00 as gr_n_50, ;
            000000.00 as gr_n_unk, ;
            000000.00 as gr_t_19, ;
            000000.00 as gr_t_29, ;
            000000.00 as gr_t_39, ;
            000000.00 as gr_t_49, ;
            000000.00 as gr_t_50, ;
            000000.00 as gr_t_unk, ;
            000000.00 as gr_all_19, ;
            000000.00 as gr_all_29, ;
            000000.00 as gr_all_39, ;
            000000.00 as gr_all_49, ;
            000000.00 as gr_all_50, ;
            000000.00 as gr_all_unk, ;
            type ;
      From RepCurs ;
      Group by type ;
      Into Cursor t_total

      Index on type tag type 

      oApp.ReopenCur('t_total','total')   
      Set Order to type   

      Store 0 to T_Female_1, T_Male_1, T_TG_1, T_ne_1 ;

      SELECT RepCurs
      Go top
     
      SUM T_Ethgen_n TO T_Female_1 FOR gender = '10' and type = 'Ethnicity'
      SUM T_Ethgen_n TO T_Male_1   FOR gender = '11' and type = 'Ethnicity'
      SUM T_Ethgen_n TO T_TG_1     FOR gender = '12' and type = 'Ethnicity'
      SUM T_Ethgen_n TO T_ne_1     FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'

      Select total
      Replace total.T_Female_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Female_1/total.Grand_tot), 2)) ,;
            total.T_Male_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Male_1/total.Grand_tot), 2)) ,;
            total.T_TG_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_TG_1/total.Grand_tot), 2)) ,;
            total.T_ne_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_ne_1/total.Grand_tot), 2));
            for type = 'Ethnicity'
      
      **Female Ethnicity
      Store 0 to  gr_f1_19, gr_f1_29, gr_f1_39, gr_f1_49, gr_f1_50, gr_f1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_f1_19   FOR gender = '10' and type = 'Ethnicity'
      Sum Age20_29_n to gr_f1_29 FOR gender = '10' and type = 'Ethnicity'
      Sum Age30_39_n to gr_f1_39 FOR gender = '10' and type = 'Ethnicity'
      Sum Age40_49_n to gr_f1_49 FOR gender = '10' and type = 'Ethnicity'
      Sum Age50plusn to gr_f1_50 FOR gender = '10' and type = 'Ethnicity'
      Sum AgeUnknown to gr_f1_unk FOR gender = '10' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_f_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_19/total.Grand_tot), 2)) ,;
              total.gr_f_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_29/total.Grand_tot), 2)) ,;
              total.gr_f_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_39/total.Grand_tot), 2)) ,;
              total.gr_f_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_49/total.Grand_tot), 2)) ,;
              total.gr_f_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_50/total.Grand_tot), 2)) ,;
              total.gr_f_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'

      ***Male Ethnicity
      Store 0 to  gr_m1_19, gr_m1_29, gr_m1_39, gr_m1_49, gr_m1_50, gr_m1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_m1_19   FOR gender = '11' and type = 'Ethnicity'
      Sum Age20_29_n to gr_m1_29 FOR gender = '11' and type = 'Ethnicity'
      Sum Age30_39_n to gr_m1_39 FOR gender = '11' and type = 'Ethnicity'
      Sum Age40_49_n to gr_m1_49 FOR gender = '11' and type = 'Ethnicity'
      Sum Age50plusn to gr_m1_50 FOR gender = '11' and type = 'Ethnicity'
      Sum AgeUnknown to gr_m1_unk FOR gender = '11' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_m_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_19/total.Grand_tot), 2)) ,;
              total.gr_m_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_29/total.Grand_tot), 2)) ,;
              total.gr_m_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_39/total.Grand_tot), 2)) ,;
              total.gr_m_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_49/total.Grand_tot), 2)) ,;
              total.gr_m_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_50/total.Grand_tot), 2)) ,;
              total.gr_m_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'
                
      ***Not Entered Ethnicity
      Store 0 to  gr_n1_19, gr_n1_29, gr_n1_39, gr_n1_49, gr_n1_50, gr_n1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_n1_19   FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age20_29_n to gr_n1_29 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age30_39_n to gr_n1_39 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age40_49_n to gr_n1_49 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age50plusn to gr_n1_50 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum AgeUnknown to gr_n1_unk FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_n_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_19/total.Grand_tot), 2)) ,;
              total.gr_n_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_29/total.Grand_tot), 2)) ,;
              total.gr_n_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_39/total.Grand_tot), 2)) ,;
              total.gr_n_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_49/total.Grand_tot), 2)) ,;
              total.gr_n_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_50/total.Grand_tot), 2)) ,;
              total.gr_n_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'           
                
     ***Transgender Ethnicity
      Store 0 to  gr_t1_19, gr_t1_29, gr_t1_39, gr_t1_49, gr_t1_50, gr_t1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_t1_19   FOR gender = '12' and type = 'Ethnicity'
      Sum Age20_29_n to gr_t1_29 FOR gender = '12' and type = 'Ethnicity'
      Sum Age30_39_n to gr_t1_39 FOR gender = '12' and type = 'Ethnicity'
      Sum Age40_49_n to gr_t1_49 FOR gender = '12' and type = 'Ethnicity'
      Sum Age50plusn to gr_t1_50 FOR gender = '12' and type = 'Ethnicity'
      Sum AgeUnknown to gr_t1_unk FOR gender = '12' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_t_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_19/total.Grand_tot), 2)) ,;
              total.gr_t_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_29/total.Grand_tot), 2)) ,;
              total.gr_t_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_39/total.Grand_tot), 2)) ,;
              total.gr_t_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_49/total.Grand_tot), 2)) ,;
              total.gr_t_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_50/total.Grand_tot), 2)) ,;
              total.gr_t_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity' 
      
      ***Grand Total Ethnicity   
      Store 0 to gr_all1_19, gr_all1_29, gr_all1_39, gr_all1_49, gr_all1_50, gr_all1_unk
      
      gr_all1_19 = gr_f1_19 + gr_m1_19 + gr_n1_19 + gr_t1_19
      gr_all1_29 = gr_f1_29 + gr_m1_29 + gr_n1_29 + gr_t1_29
      gr_all1_39 = gr_f1_39 + gr_m1_39 + gr_n1_39 + gr_t1_39
      gr_all1_49 = gr_f1_49 + gr_m1_49 + gr_n1_49 + gr_t1_49 
      gr_all1_50 = gr_f1_50 + gr_m1_50 + gr_n1_50 + gr_t1_50
      gr_all1_unk = gr_f1_unk + gr_m1_unk + gr_n1_unk + gr_t1_unk
      
      Select total
      Replace total.gr_all_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_19/total.Grand_tot), 2)) ,;
              total.gr_all_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_29/total.Grand_tot), 2)) ,;
              total.gr_all_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_39/total.Grand_tot), 2)) ,;
              total.gr_all_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_49/total.Grand_tot), 2)) ,;
              total.gr_all_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_50/total.Grand_tot), 2)) ,;
              total.gr_all_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'         
                  
      *******RACE   
      Store 0 to T_Female_1, T_Male_1, T_TG_1, T_ne_1
         
      SELECT RepCurs
      Go top

      SUM T_Ethgen_n TO T_Female_1 FOR gender = '10' and type = 'Race'
      SUM T_Ethgen_n TO T_Male_1   FOR gender = '11' and type = 'Race'
      SUM T_Ethgen_n TO T_TG_1     FOR gender = '12' and type = 'Race'
      SUM T_Ethgen_n TO T_ne_1     FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'

      Select total
      Replace total.T_Female_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Female_1/total.Grand_tot), 2)) ,;
            total.T_Male_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Male_1/total.Grand_tot), 2)) ,;
            total.T_TG_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_TG_1/total.Grand_tot), 2)) ,;
            total.T_ne_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_ne_1/total.Grand_tot), 2)) ; 
            for type = 'Race'
      
      **Female Race
      Store 0 to  gr_f1_19, gr_f1_29, gr_f1_39, gr_f1_49, gr_f1_50, gr_f1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_f1_19   FOR gender = '10' and type = 'Race'
      Sum Age20_29_n to gr_f1_29 FOR gender = '10' and type = 'Race'
      Sum Age30_39_n to gr_f1_39 FOR gender = '10' and type = 'Race'
      Sum Age40_49_n to gr_f1_49 FOR gender = '10' and type = 'Race'
      Sum Age50plusn to gr_f1_50 FOR gender = '10' and type = 'Race'
      Sum AgeUnknown to gr_f1_unk FOR gender = '10' and type = 'Race'
      
      Select total
      Replace total.gr_f_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_19/total.Grand_tot), 2)) ,;
              total.gr_f_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_29/total.Grand_tot), 2)) ,;
              total.gr_f_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_39/total.Grand_tot), 2)) ,;
              total.gr_f_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_49/total.Grand_tot), 2)) ,;
              total.gr_f_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_50/total.Grand_tot), 2)) ,;
              total.gr_f_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
            
      ***Male Race
      Store 0 to  gr_m1_19, gr_m1_29, gr_m1_39, gr_m1_49, gr_m1_50, gr_m1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_m1_19   FOR gender = '11' and type = 'Race'
      Sum Age20_29_n to gr_m1_29 FOR gender = '11' and type = 'Race'
      Sum Age30_39_n to gr_m1_39 FOR gender = '11' and type = 'Race'
      Sum Age40_49_n to gr_m1_49 FOR gender = '11' and type = 'Race'
      Sum Age50plusn to gr_m1_50 FOR gender = '11' and type = 'Race'
      Sum AgeUnknown to gr_m1_unk FOR gender = '11' and type = 'Race'
      
      Select total
      Replace total.gr_m_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_19/total.Grand_tot), 2)) ,;
              total.gr_m_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_29/total.Grand_tot), 2)) ,;
              total.gr_m_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_39/total.Grand_tot), 2)) ,;
              total.gr_m_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_49/total.Grand_tot), 2)) ,;
              total.gr_m_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_50/total.Grand_tot), 2)) ,;
              total.gr_m_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
                
      ***Not Entered Race
      Store 0 to  gr_n1_19, gr_n1_29, gr_n1_39, gr_n1_49, gr_n1_50, gr_n1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_n1_19   FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age20_29_n to gr_n1_29 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age30_39_n to gr_n1_39 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age40_49_n to gr_n1_49 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age50plusn to gr_n1_50 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum AgeUnknown to gr_n1_unk FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      
      Select total
      Replace total.gr_n_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_19/total.Grand_tot), 2)) ,;
              total.gr_n_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_29/total.Grand_tot), 2)) ,;
              total.gr_n_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_39/total.Grand_tot), 2)) ,;
              total.gr_n_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_49/total.Grand_tot), 2)) ,;
              total.gr_n_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_50/total.Grand_tot), 2)) ,;
              total.gr_n_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'        
                
     ***Transgender Race
      Store 0 to  gr_t1_19, gr_t1_29, gr_t1_39, gr_t1_49, gr_t1_50, gr_t1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_t1_19   FOR gender = '12' and type = 'Race'
      Sum Age20_29_n to gr_t1_29 FOR gender = '12' and type = 'Race'
      Sum Age30_39_n to gr_t1_39 FOR gender = '12' and type = 'Race'
      Sum Age40_49_n to gr_t1_49 FOR gender = '12' and type = 'Race'
      Sum Age50plusn to gr_t1_50 FOR gender = '12' and type = 'Race'
      Sum AgeUnknown to gr_t1_unk FOR gender = '12' and type = 'Race'
      
      Select total
      Replace total.gr_t_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_19/total.Grand_tot), 2)) ,;
              total.gr_t_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_29/total.Grand_tot), 2)) ,;
              total.gr_t_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_39/total.Grand_tot), 2)) ,;
              total.gr_t_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_49/total.Grand_tot), 2)) ,;
              total.gr_t_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_50/total.Grand_tot), 2)) ,;
              total.gr_t_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
      
       ***Grand Total Race   
      Store 0 to gr_all1_19, gr_all1_29, gr_all1_39, gr_all1_49, gr_all1_50, gr_all1_unk
      
      gr_all1_19 = gr_f1_19 + gr_m1_19 + gr_n1_19 + gr_t1_19
      gr_all1_29 = gr_f1_29 + gr_m1_29 + gr_n1_29 + gr_t1_29
      gr_all1_39 = gr_f1_39 + gr_m1_39 + gr_n1_39 + gr_t1_39
      gr_all1_49 = gr_f1_49 + gr_m1_49 + gr_n1_49 + gr_t1_49 
      gr_all1_50 = gr_f1_50 + gr_m1_50 + gr_n1_50 + gr_t1_50
      gr_all1_unk = gr_f1_unk + gr_m1_unk + gr_n1_unk + gr_t1_unk
      
      Select total
      Replace total.gr_all_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_19/total.Grand_tot), 2)) ,;
              total.gr_all_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_29/total.Grand_tot), 2)) ,;
              total.gr_all_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_39/total.Grand_tot), 2)) ,;
              total.gr_all_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_49/total.Grand_tot), 2)) ,;
              total.gr_all_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_50/total.Grand_tot), 2)) ,;
              total.gr_all_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'         
                  
      If Used('RepCursT')
         Use in RepCursT
      endif   
      
      oApp.msg2user('OFF')

      Select RepCurs.* ,;
            total.Grand_tot, ;
            total.T_Male_n, ;
            total.T_TG_N, ;
            total.T_ne_N, ;
            total.gr_f_19,;
            total.gr_f_29, ;
            total.gr_f_39, ;
            total.gr_f_49, ;
            total.gr_f_50, ;
            total.gr_f_unk, ;
            total.T_Female_n, ;
            total.gr_m_19, ;
            total.gr_m_29, ;
            total.gr_m_39, ;
            total.gr_m_49, ;
            total.gr_m_50, ;
            total.gr_m_unk, ;
            total.gr_n_19, ;
            total.gr_n_29, ;
            total.gr_n_39, ;
            total.gr_n_49, ;
            total.gr_n_50, ;
            total.gr_n_unk, ;
            total.gr_t_19, ;
            total.gr_t_29, ;
            total.gr_t_39, ;
            total.gr_t_49, ;
            total.gr_t_50, ;
            total.gr_t_unk, ;
            total.gr_all_19, ;
            total.gr_all_29, ;
            total.gr_all_39, ;
            total.gr_all_49, ;
            total.gr_all_50, ;
            total.gr_all_unk, ;
            rep_title1 as rep_title1, ;
            rep_title2 as rep_title2, ;
            Crit as Crit, ;   
            cDate as cDate, ;
            cTime as cTime, ;
            from_d as Date_from, ;
            to_d as date_to;      
      from RepCurs ;
            inner join total on ;
               RepCurs.type = total.type ;
      into cursor  RepCursT

      Go Top
      If EOF()
            oApp.msg2user('NOTFOUNDG')
      Else
                 gcRptName = 'rpt_syr_tab2'
                 Do Case
                     CASE lPrev = .f.
                          Report Form rpt_syr_tab2 To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_syr_tab2', 1, 2)
                 EndCase
      Endif 
         
Case lnStat = 3 &&Syringe Encounters by Age,Ethnic,Gender - All
         rep_title1='Syringe Exchange - Summary of Encounters'
         rep_title2='by Ethnicity/Race, Gender, and Age: All Participants'
         
         If Used('Temp')
            Use in Temp
         Endif  
               
         SELECT ;
               Needlx.Tc_Id AS Tc_Id      ,;
               Space(2) as Ethnic     ,;
               Iif(client.hispanic = 2, "Hispanic" + Space(42), Iif(client.hispanic = 1, "Non-Hispanic" + Space(38), ;
               "Unknown/Unreported" + Space(32))) AS EthnicDesc ,;
               Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
                  IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
               Client.Dob AS Dob,;
               000 as Client_Age, ;
               'Ethnicity' as type, ;
               Sum(1) as total ;
         FROM ;
               Needlx    ,;
               Ai_Clien  ,;
               Client     ;
         WHERE ;
               BETWEEN(Needlx.Date, from_d,to_d) ;
           AND ;
               Needlx.tc_id       = Ai_Clien.Tc_Id        ;
           AND ;
               Ai_Clien.Client_id = Client.Client_Id      ;
           AND ;
                 Needlx.Program = lcprogx and ;
                 (client.hispanic = 2 or client.hispanic = 1 or client.hispanic = 0) ;
         &cFiltExpr ;   
         into cursor temp  group by 1, 2, 3, 4, 5, 6 , 7, 8
      
         If Used('Race1')
            Use in Race1
         Endif  
         * White       
         SELECT ;
               Needlx.Tc_Id as Tc_Id      ,;
               '10' AS Ethnic     ,;
               'White' + SPACE(45) AS EthnicDesc ,;
               Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
                  IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
                  IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
               Client.Dob   AS Dob,;
               000   AS Client_Age, ;
               'Race     ' as type, ;
               Sum(1) as total ;
         FROM ;
               Needlx    ,;
               Ai_Clien  ,;
               Client     ;
         WHERE ;
               BETWEEN(Needlx.Date,from_d,to_d) ;
           AND ;
               Needlx.tc_id       = Ai_Clien.Tc_Id        ;
           AND ;
               Ai_Clien.Client_id = Client.Client_Id      ;
           AND ;
                 Needlx.Program = lcprogx ;
           and ;
                 client.white = 1 and ;      
                 (client.blafrican + client.asian + client.hawaisland + ;
                   client.indialaska + client.someother) = 0 ;
         &cFiltExpr ;   
         INTO CURSOR ;
               Race1  Group by 1, 2, 3, 4, 5, 6, 7, 8
         
         If Used('Race2')
            Use in Race2
         Endif        
  
      * Black  or African
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '20' AS Ethnic     ,;
            'Black or African-American' + SPACE(25) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.blafrican = 1 and ;
              (client.white + client.asian + client.hawaisland + ;
                client.indialaska + client.someother) = 0    ;         
      &cFiltExpr ;   
      INTO CURSOR ;
            Race2  Group By 1, 2, 3, 4, 5, 6, 7, 8   
      
       If Used('Race3')
           Use in Race3
       Endif    
      * Asian
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '30' AS Ethnic     ,;
            'Asian' + SPACE(45) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.asian = 1 and ;
                 (client.white + client.blafrican + client.hawaisland + ;
                client.indialaska + client.someother) = 0 ;      
      &cFiltExpr ;   
      INTO CURSOR ;
            Race3 Group by 1, 2, 3, 4, 5, 6, 7, 8   

      If Used('Race4')
           Use in Race4
      Endif  
      * Native Hawaiian
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '40' AS Ethnic     ,;
            'Native Hawaiian/Pacific Islander' + SPACE(18) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.hawaisland = 1 and ;
             (client.blafrican + client.asian + client.white + ;
             client.indialaska + client.someother) = 0 ;         
      &cFiltExpr ;   
      INTO CURSOR ;
            Race4 Group By 1, 2, 3, 4, 5, 6, 7, 8

      If Used('Race5')
           Use in Race5
      Endif  
      * American Indian or Alaskan
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '50' AS Ethnic     ,;
            'American Indian or Alaskan Native' + SPACE(17) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.indialaska = 1 and ;      
              (client.blafrican + client.asian + client.white + ;
             client.hawaisland + client.someother) = 0 ;      
      &cFiltExpr ;   
      INTO CURSOR ;
            Race5  Group By 1, 2, 3, 4, 5, 6, 7, 8   

      If Used('Race6')
           Use in Race6
      Endif  
      * Unknown
      * jss, 05/30/03, add code to account for no race field entered
      * jss, 6/27/03, add client.someother to no race clause below
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '90' AS Ethnic     ,;
            'Unknown/unreported' + SPACE(32) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              (client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.unknowrep + client.someother = 0 ;
              or ;
              (client.unknowrep = 1 and ;
               client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.someother = 0)) ;         
      &cFiltExpr ;   
      INTO CURSOR ;
            Race6 Group By 1, 2, 3, 4, 5, 6, 7, 8

      If Used('Race7')
            Use in Race7
      Endif  
      * Some Other Race
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '70' AS Ethnic     ,;
            'Some Other Race   ' + SPACE(32) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.someother = 1 and ;
              (client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska) = 0 ;            
      &cFiltExpr ;   
      INTO CURSOR ;
            Race7 Group By 1, 2, 3, 4, 5, 6, 7, 8
 
      If Used('temp1')
            Use in Temp1
      Endif  
      
      Select * ;
      From race1 ;
      Union  ;          
      Select * ;
         From race2 ;
      Union  ;    
      Select * ;
         From race3 ;
      Union  ;    
      Select * ;
         From race4 ;
      Union  ;    
      Select * ;
         From race5 ;
      Union  ;    
      Select * ;
         From race6 ;
      Union  ;    
      Select * ;
         From race7 ;
      Into Cursor temp1 
   
       =clean_race()
       
       If Used('Temp3')
           Use in Temp3
       Endif  
      * More Than 1 Race
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '60' AS Ethnic     ,;
            'More Than 1 Race  ' + SPACE(32) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
               IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
               IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            'Race     ' as type, ;
            Sum(1) as total ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              (client.indialaska + client.blafrican + client.asian + client.white + ;
                client.hawaisland + client.someother) > 1 ;               
      &cFiltExpr ;   
      INTO CURSOR ;
            temp3  Group By 1, 2, 3, 4, 5, 6, 7, 8

      If Used('FirstCt1')
           Use in FirstCt1
      Endif 
      
      If Used('FirstCut')
           Use in FirstCut
      Endif 
       
      Select * ;
         From temp ;
      Union ;
      Select * ;
         From temp1 ;
      Union ;
      Select * ;
         From temp3 ;   
      INTO CURSOR ;
            FirstCt1 
            
      oApp.ReopenCur('FirstCt1','FirstCut')      
   
      =clean_temp()
      SELECT FirstCut
      * because of a problem using this IIF in SELECT statment above, determine client age here
      REPLACE ALL Client_Age WITH IIF(!EMPTY(Dob),oApp.AGE(to_d,Dob),00) 
      
      If Used('RepCurs2')
           Use in RepCurs2
      Endif 
      
      If Used('RepCurs')
           Use in RepCurs
      Endif 
      * summary info
      SELECT ;
            EthnicDesc             ,;
            GenderDesc             ,;
            Gender     ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,19), total,0))         AS Age0_19_n   ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,20,29),total,0))        AS Age20_29_n  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,30,39),total,0))        AS Age30_39_n  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,40,49),total,0))        AS Age40_49_n  ,;
            SUM(IIF(!Empty(dob) AND Client_Age >= 50,total,0))                   AS Age50plusn  ,;
            SUM(IIF(Empty(dob),total,0))                                        AS AgeUnknown  ,;
               0000000                                                          AS T_Ethgen_n,  ;
               type ;
         FROM ;
            FirstCut ;
         GROUP BY ;
              type, EthnicDesc, GenderDesc, gender ;
         INTO CURSOR ;
            RepCurs2 
      
         oApp.ReopenCur('RepCurs2','RepCurs')      
         SELECT RepCurs

         * sum rows now for totals by ethnicity+gender
         REPLACE ALL T_Ethgen_n WITH Age0_19_n + Age20_29_n + Age30_39_n + Age40_49_n + Age50plusn + AgeUnknown 

         If Used('t_total')
           Use in t_total
         Endif 

         If Used('total')
           Use in total
         Endif 
         * grand total sums
         Select Sum(T_Ethgen_n) as Grand_tot, ;
            000000.00 as T_Female_n, ;
            000000.00 as T_Male_n, ;
            000000.00 as T_TG_N, ;
            000000.00 as T_ne_N, ;
            000000.00 as gr_f_19, ;
            000000.00 as gr_f_29, ;
            000000.00 as gr_f_39, ;
            000000.00 as gr_f_49, ;
            000000.00 as gr_f_50, ;
            000000.00 as gr_f_unk, ;
            000000.00 as gr_m_19, ;
            000000.00 as gr_m_29, ;
            000000.00 as gr_m_39, ;
            000000.00 as gr_m_49, ;
            000000.00 as gr_m_50, ;
            000000.00 as gr_m_unk, ;
            000000.00 as gr_n_19, ;
            000000.00 as gr_n_29, ;
            000000.00 as gr_n_39, ;
            000000.00 as gr_n_49, ;
            000000.00 as gr_n_50, ;
            000000.00 as gr_n_unk, ;
            000000.00 as gr_t_19, ;
            000000.00 as gr_t_29, ;
            000000.00 as gr_t_39, ;
            000000.00 as gr_t_49, ;
            000000.00 as gr_t_50, ;
            000000.00 as gr_t_unk, ;
            000000.00 as gr_all_19, ;
            000000.00 as gr_all_29, ;
            000000.00 as gr_all_39, ;
            000000.00 as gr_all_49, ;
            000000.00 as gr_all_50, ;
            000000.00 as gr_all_unk, ;  
            type ;    
         From RepCurs ;
         Group by type ;
         Into Cursor t_total

         Index on type tag type 

         oApp.ReopenCur('t_total','total')   
         Set Order to type   

      Store 0 to T_Female_1, T_Male_1, T_TG_1, T_ne_1 ;
        
      SELECT RepCurs
      Go top

      SUM T_Ethgen_n TO T_Female_1 FOR gender = '10' and type = 'Ethnicity'
      SUM T_Ethgen_n TO T_Male_1   FOR gender = '11' and type = 'Ethnicity'
      SUM T_Ethgen_n TO T_TG_1     For gender = '12' and type = 'Ethnicity'
      SUM T_Ethgen_n TO T_ne_1     FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'

      Select total
      Replace total.T_Female_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Female_1/total.Grand_tot), 2)) ,;
            total.T_Male_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Male_1/total.Grand_tot), 2)) ,;
            total.T_TG_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_TG_1/total.Grand_tot), 2)) ,;
            total.T_ne_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_ne_1/total.Grand_tot), 2));
            for type = 'Ethnicity'
      
      **Female Ethnicity
      Store 0 to  gr_f1_19, gr_f1_29, gr_f1_39, gr_f1_49, gr_f1_50, gr_f1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_f1_19   FOR gender = '10' and type = 'Ethnicity'
      Sum Age20_29_n to gr_f1_29 FOR gender = '10' and type = 'Ethnicity'
      Sum Age30_39_n to gr_f1_39 FOR gender = '10' and type = 'Ethnicity'
      Sum Age40_49_n to gr_f1_49 FOR gender = '10' and type = 'Ethnicity'
      Sum Age50plusn to gr_f1_50 FOR gender = '10' and type = 'Ethnicity'
      Sum AgeUnknown to gr_f1_unk FOR gender = '10' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_f_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_19/total.Grand_tot), 2)) ,;
              total.gr_f_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_29/total.Grand_tot), 2)) ,;
              total.gr_f_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_39/total.Grand_tot), 2)) ,;
              total.gr_f_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_49/total.Grand_tot), 2)) ,;
              total.gr_f_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_50/total.Grand_tot), 2)) ,;
              total.gr_f_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'

      ***Male Ethnicity
      Store 0 to  gr_m1_19, gr_m1_29, gr_m1_39, gr_m1_49, gr_m1_50, gr_m1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_m1_19   FOR gender = '11' and type = 'Ethnicity'
      Sum Age20_29_n to gr_m1_29 FOR gender = '11' and type = 'Ethnicity'
      Sum Age30_39_n to gr_m1_39 FOR gender = '11' and type = 'Ethnicity'
      Sum Age40_49_n to gr_m1_49 FOR gender = '11' and type = 'Ethnicity'
      Sum Age50plusn to gr_m1_50 FOR gender = '11' and type = 'Ethnicity'
      Sum AgeUnknown to gr_m1_unk FOR gender = '11' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_m_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_19/total.Grand_tot), 2)) ,;
              total.gr_m_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_29/total.Grand_tot), 2)) ,;
              total.gr_m_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_39/total.Grand_tot), 2)) ,;
              total.gr_m_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_49/total.Grand_tot), 2)) ,;
              total.gr_m_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_50/total.Grand_tot), 2)) ,;
              total.gr_m_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'
                
      ***Not Entered Ethnicity
      Store 0 to  gr_n1_19, gr_n1_29, gr_n1_39, gr_n1_49, gr_n1_50, gr_n1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_n1_19   FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age20_29_n to gr_n1_29 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age30_39_n to gr_n1_39 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age40_49_n to gr_n1_49 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum Age50plusn to gr_n1_50 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      Sum AgeUnknown to gr_n1_unk FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_n_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_19/total.Grand_tot), 2)) ,;
              total.gr_n_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_29/total.Grand_tot), 2)) ,;
              total.gr_n_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_39/total.Grand_tot), 2)) ,;
              total.gr_n_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_49/total.Grand_tot), 2)) ,;
              total.gr_n_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_50/total.Grand_tot), 2)) ,;
              total.gr_n_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'           
                
     ***Transgender Ethnicity
      Store 0 to  gr_t1_19, gr_t1_29, gr_t1_39, gr_t1_49, gr_t1_50, gr_t1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_t1_19   FOR gender = '12' and type = 'Ethnicity'
      Sum Age20_29_n to gr_t1_29 FOR gender = '12' and type = 'Ethnicity'
      Sum Age30_39_n to gr_t1_39 FOR gender = '12' and type = 'Ethnicity'
      Sum Age40_49_n to gr_t1_49 FOR gender = '12' and type = 'Ethnicity'
      Sum Age50plusn to gr_t1_50 FOR gender = '12' and type = 'Ethnicity'
      Sum AgeUnknown to gr_t1_unk FOR gender = '12' and type = 'Ethnicity'
      
      Select total
      Replace total.gr_t_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_19/total.Grand_tot), 2)) ,;
              total.gr_t_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_29/total.Grand_tot), 2)) ,;
              total.gr_t_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_39/total.Grand_tot), 2)) ,;
              total.gr_t_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_49/total.Grand_tot), 2)) ,;
              total.gr_t_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_50/total.Grand_tot), 2)) ,;
              total.gr_t_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity' 
      
      ***Grand Total Ethnicity   
      Store 0 to gr_all1_19, gr_all1_29, gr_all1_39, gr_all1_49, gr_all1_50, gr_all1_unk
      
      gr_all1_19 = gr_f1_19 + gr_m1_19 + gr_n1_19 + gr_t1_19
      gr_all1_29 = gr_f1_29 + gr_m1_29 + gr_n1_29 + gr_t1_29
      gr_all1_39 = gr_f1_39 + gr_m1_39 + gr_n1_39 + gr_t1_39
      gr_all1_49 = gr_f1_49 + gr_m1_49 + gr_n1_49 + gr_t1_49 
      gr_all1_50 = gr_f1_50 + gr_m1_50 + gr_n1_50 + gr_t1_50
      gr_all1_unk = gr_f1_unk + gr_m1_unk + gr_n1_unk + gr_t1_unk
      
      Select total
      Replace total.gr_all_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_19/total.Grand_tot), 2)) ,;
              total.gr_all_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_29/total.Grand_tot), 2)) ,;
              total.gr_all_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_39/total.Grand_tot), 2)) ,;
              total.gr_all_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_49/total.Grand_tot), 2)) ,;
              total.gr_all_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_50/total.Grand_tot), 2)) ,;
              total.gr_all_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_unk/total.Grand_tot), 2)) ;
            for type = 'Ethnicity'         
                  
      *******RACE   
      Store 0 to T_Female_1, T_Male_1, T_TG_1, T_ne_1
         
      SELECT RepCurs
      Go top

      SUM T_Ethgen_n TO T_Female_1 FOR gender = '10' and type = 'Race'
      SUM T_Ethgen_n TO T_Male_1   FOR gender = '11' and type = 'Race'
      SUM T_Ethgen_n TO T_TG_1     FOR gender = '12' and type = 'Race'
      SUM T_Ethgen_n TO T_ne_1     FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'

      Select total
      Replace total.T_Female_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Female_1/total.Grand_tot), 2)) ,;
            total.T_Male_n With Iif(total.Grand_tot = 0, 0, Round(100*(T_Male_1/total.Grand_tot), 2)) ,;
            total.T_TG_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_TG_1/total.Grand_tot), 2)) ,;
            total.T_ne_N With Iif(total.Grand_tot = 0, 0, Round(100*(T_ne_1/total.Grand_tot), 2)) ; 
            for type = 'Race'
      
      **Female Race
      Store 0 to  gr_f1_19, gr_f1_29, gr_f1_39, gr_f1_49, gr_f1_50, gr_f1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_f1_19   FOR gender = '10' and type = 'Race'
      Sum Age20_29_n to gr_f1_29 FOR gender = '10' and type = 'Race'
      Sum Age30_39_n to gr_f1_39 FOR gender = '10' and type = 'Race'
      Sum Age40_49_n to gr_f1_49 FOR gender = '10' and type = 'Race'
      Sum Age50plusn to gr_f1_50 FOR gender = '10' and type = 'Race'
      Sum AgeUnknown to gr_f1_unk FOR gender = '10' and type = 'Race'
      
      Select total
      Replace total.gr_f_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_19/total.Grand_tot), 2)) ,;
              total.gr_f_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_29/total.Grand_tot), 2)) ,;
              total.gr_f_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_39/total.Grand_tot), 2)) ,;
              total.gr_f_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_49/total.Grand_tot), 2)) ,;
              total.gr_f_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_50/total.Grand_tot), 2)) ,;
              total.gr_f_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_f1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
            
      ***Male Race
      Store 0 to  gr_m1_19, gr_m1_29, gr_m1_39, gr_m1_49, gr_m1_50, gr_m1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_m1_19   FOR gender = '11' and type = 'Race'
      Sum Age20_29_n to gr_m1_29 FOR gender = '11' and type = 'Race'
      Sum Age30_39_n to gr_m1_39 FOR gender = '11' and type = 'Race'
      Sum Age40_49_n to gr_m1_49 FOR gender = '11' and type = 'Race'
      Sum Age50plusn to gr_m1_50 FOR gender = '11' and type = 'Race'
      Sum AgeUnknown to gr_m1_unk FOR gender = '11' and type = 'Race'
      
      Select total
      Replace total.gr_m_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_19/total.Grand_tot), 2)) ,;
              total.gr_m_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_29/total.Grand_tot), 2)) ,;
              total.gr_m_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_39/total.Grand_tot), 2)) ,;
              total.gr_m_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_49/total.Grand_tot), 2)) ,;
              total.gr_m_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_50/total.Grand_tot), 2)) ,;
              total.gr_m_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_m1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
                
      ***Not Entered Race
      Store 0 to  gr_n1_19, gr_n1_29, gr_n1_39, gr_n1_49, gr_n1_50, gr_n1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_n1_19   FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age20_29_n to gr_n1_29 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age30_39_n to gr_n1_39 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age40_49_n to gr_n1_49 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum Age50plusn to gr_n1_50 FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      Sum AgeUnknown to gr_n1_unk FOR gender <> '10' AND gender <> '11' and gender <> '12' and type = 'Race'
      
      Select total
      Replace total.gr_n_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_19/total.Grand_tot), 2)) ,;
              total.gr_n_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_29/total.Grand_tot), 2)) ,;
              total.gr_n_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_39/total.Grand_tot), 2)) ,;
              total.gr_n_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_49/total.Grand_tot), 2)) ,;
              total.gr_n_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_50/total.Grand_tot), 2)) ,;
              total.gr_n_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_n1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'        
                
     ***Transgender Race
      Store 0 to  gr_t1_19, gr_t1_29, gr_t1_39, gr_t1_49, gr_t1_50, gr_t1_unk   
      SELECT RepCurs
      Go top
        
      Sum  Age0_19_n to gr_t1_19   FOR gender = '12' and type = 'Race'
      Sum Age20_29_n to gr_t1_29 FOR gender = '12' and type = 'Race'
      Sum Age30_39_n to gr_t1_39 FOR gender = '12' and type = 'Race'
      Sum Age40_49_n to gr_t1_49 FOR gender = '12' and type = 'Race'
      Sum Age50plusn to gr_t1_50 FOR gender = '12' and type = 'Race'
      Sum AgeUnknown to gr_t1_unk FOR gender = '12' and type = 'Race'
      
      Select total
      Replace total.gr_t_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_19/total.Grand_tot), 2)) ,;
              total.gr_t_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_29/total.Grand_tot), 2)) ,;
              total.gr_t_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_39/total.Grand_tot), 2)) ,;
              total.gr_t_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_49/total.Grand_tot), 2)) ,;
              total.gr_t_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_50/total.Grand_tot), 2)) ,;
              total.gr_t_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_t1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'
      
       ***Grand Total Race   
      Store 0 to gr_all1_19, gr_all1_29, gr_all1_39, gr_all1_49, gr_all1_50, gr_all1_unk
      
      gr_all1_19 = gr_f1_19 + gr_m1_19 + gr_n1_19 + gr_t1_19
      gr_all1_29 = gr_f1_29 + gr_m1_29 + gr_n1_29 + gr_t1_29
      gr_all1_39 = gr_f1_39 + gr_m1_39 + gr_n1_39 + gr_t1_39
      gr_all1_49 = gr_f1_49 + gr_m1_49 + gr_n1_49 + gr_t1_49 
      gr_all1_50 = gr_f1_50 + gr_m1_50 + gr_n1_50 + gr_t1_50
      gr_all1_unk = gr_f1_unk + gr_m1_unk + gr_n1_unk + gr_t1_unk
      
      Select total
      Replace total.gr_all_19 With Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_19/total.Grand_tot), 2)) ,;
              total.gr_all_29 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_29/total.Grand_tot), 2)) ,;
              total.gr_all_39 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_39/total.Grand_tot), 2)) ,;
              total.gr_all_49 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_49/total.Grand_tot), 2)) ,;
              total.gr_all_50 with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_50/total.Grand_tot), 2)) ,;
              total.gr_all_unk with Iif(total.Grand_tot = 0, 0, Round(100*(gr_all1_unk/total.Grand_tot), 2)) ;
            for type = 'Race'   
      
         If Used('RepCursT')
            Use in RepCursT
         endif   
      
      oApp.msg2user('OFF')
      
      Select RepCurs.* ,;
            total.Grand_tot, ;
            total.T_Male_n, ;
            total.T_TG_N, ;
            total.T_ne_N, ;
            total.gr_f_19,;
            total.gr_f_29, ;
            total.gr_f_39, ;
            total.gr_f_49, ;
            total.gr_f_50, ;
            total.gr_f_unk, ;
            total.T_Female_n, ;
            total.gr_m_19, ;
            total.gr_m_29, ;
            total.gr_m_39, ;
            total.gr_m_49, ;
            total.gr_m_50, ;
            total.gr_m_unk, ;
            total.gr_n_19, ;
            total.gr_n_29, ;
            total.gr_n_39, ;
            total.gr_n_49, ;
            total.gr_n_50, ;
            total.gr_n_unk, ;
            total.gr_t_19, ;
            total.gr_t_29, ;
            total.gr_t_39, ;
            total.gr_t_49, ;
            total.gr_t_50, ;
            total.gr_t_unk, ;
            total.gr_all_19, ;
            total.gr_all_29, ;
            total.gr_all_39, ;
            total.gr_all_49, ;
            total.gr_all_50, ;
            total.gr_all_unk, ;
            rep_title1 as rep_title1, ;
            rep_title2 as rep_title2, ;
            Crit as Crit, ;   
            cDate as cDate, ;
            cTime as cTime, ;
            from_d as Date_from, ;
            to_d as date_to;      
      from RepCurs ;
            inner join total on ;
               RepCurs.type = total.type ;
      into cursor  RepCursT
      
      Go Top
      If EOF()
            oApp.msg2user('NOTFOUNDG')
      Else
                 gcRptName = 'rpt_syr_tab2'
                 Do Case
                     CASE lPrev = .f.
                          Report Form rpt_syr_tab2 To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_syr_tab2', 1, 2)
                 EndCase
      Endif 
            
Case lnStat = 4 &&Syringes Exchanged by Age, Ethnicity & Gender
      STORE 0 TO Grand_i, Grand_o, Grand_x, T_Female_i,T_Female_o,T_Female_x,T_Male_i,T_Male_o,T_Male_x,T_TG_i,T_TG_o,T_TG_x,T_ne_i,T_ne_o,T_ne_x
      If Used('temp')
          Use in temp
      Endif 
      * Ethnicity
      SELECT ;
            Needlx.Tc_Id AS Tc_Id,;
            Space(2) as Ethnic     ,;
            Iif(client.hispanic = 2, "Hispanic" + Space(42), Iif(client.hispanic = 1, "Non-Hispanic" + Space(38), ;
            "Unknown/Unreported" + Space(32))) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
            IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000 AS Client_Age ,;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Ethnicity' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date, from_d, to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx  and ;          
              (client.hispanic = 2 or client.hispanic = 1 or client.hispanic = 0) ;
      &cFiltExpr ;   
       INTO CURSOR temp ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11       
       
      If Used('Race1')
           Use in Race1
      Endif   
      * White       
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '10' AS Ethnic     ,;
            'White' + SPACE(45) AS EthnicDesc ,;
           Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date, from_d, to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
            client.white = 1  and ;      
              (client.blafrican + client.asian + client.hawaisland + ;
                client.indialaska + client.someother) = 0 ;
      &cFiltExpr ;   
      INTO CURSOR Race1 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11
  
      If Used('Race2')
           Use in Race2
      Endif 
      * Black  or African
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '20' AS Ethnic     ,;
            'Black or African-American' + SPACE(25) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;  
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date, from_d, to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
             client.blafrican = 1 and ;
              (client.white + client.asian + client.hawaisland + ;
              client.indialaska + client.someother) = 0    ;      
      &cFiltExpr ;   
      INTO CURSOR Race2 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11  
      
      If Used('Race3')
           Use in Race3
      Endif   
        
      * Asian
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '30' AS Ethnic     ,;
            'Asian' + SPACE(45) AS EthnicDesc ,;
           Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
                 client.asian = 1 and ;
                 (client.white + client.blafrican + client.hawaisland + ;
                client.indialaska + client.someother) = 0 ;      
      &cFiltExpr ;   
      INTO CURSOR Race3 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11    

      If Used('Race4')
           Use in Race4
      Endif 
      * Native Hawaiian
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '40' AS Ethnic     ,;
            'Native Hawaiian/Pacific Islander' + SPACE(18) AS EthnicDesc ,;
           Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
                 client.hawaisland = 1 and ;
             (client.blafrican + client.asian + client.white + ;
             client.indialaska + client.someother) = 0 ;   
      &cFiltExpr ;   
      INTO CURSOR Race4;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11 

      If Used('Race5')
           Use in Race5
      Endif 
      * American Indian or Alaskan
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '50' AS Ethnic     ,;
            'American Indian or Alaskan Native' + SPACE(17) AS EthnicDesc ,;
           Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
                 client.indialaska = 1 and ;      
              (client.blafrican + client.asian + client.white + ;
             client.hawaisland + client.someother) = 0 ;   
      &cFiltExpr ;   
      INTO CURSOR Race5 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11    

      If Used('Race6')
           Use in Race6
      Endif 
      * Unknown
      * jss, 5/30/03, add code to account for no race field entered
      * jss, 6/27/03, add client.someother to no race clause below
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '90' AS Ethnic     ,;
            'Unknown/unreported' + SPACE(32) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              (client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.someother + client.unknowrep=0 ;
            or ;
              (client.unknowrep = 1 and ;
              client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska + client.someother  = 0)) ;      
      &cFiltExpr ;   
      INTO CURSOR Race6 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11 
 
      If Used('Race7')
           Use in Race7
      Endif 
      * Some Other Race
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '70' AS Ethnic     ,;
            'Some Other Race   ' + SPACE(32) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              client.someother = 1 and ;
              (client.white + client.blafrican + client.asian + client.hawaisland + client.indialaska) = 0 ;            
      &cFiltExpr ;   
      INTO CURSOR Race7 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11         
      
      If Used('Temp1')
           Use in Temp1
      Endif   
      
      Select * ;
         From race1 ;
      Union  ;          
      Select * ;
         From race2 ;
      Union  ;    
      Select * ;
         From race3 ;
      Union  ;    
      Select * ;
         From race4 ;
      Union  ;    
      Select * ;
         From race5 ;
      Union  ;    
      Select * ;
         From race6 ;
      Union  ;    
      Select * ;
         From race7 ;
      Into Cursor temp1 

      =clean_race()

      If Used('Temp3')
           Use in Temp3
      Endif   
      * More Than Race
      SELECT ;
            Needlx.Tc_Id as Tc_Id      ,;
            '60' AS Ethnic     ,;
            'More Than 1 Race  ' + SPACE(32) AS EthnicDesc ,;
            Iif(Client.Gender='13', '12', Client.Gender) AS Gender     ,;
              IIF(Gender='10','Female     ',IIF(Gender='11','Male       ', ;
              IIF(Gender = '12' OR Gender = '13','Transgender','Not Entered')))    AS GenderDesc ,;
            Client.Dob   AS Dob,;
            000   AS Client_Age, ;
            SUM(Needlx.N_In) AS N_In       ,;
            SUM(Needlx.N_Out) AS N_Out      ,;  
            SUM(1) AS N_Exch,      ;
            'Race     ' as type ;
      FROM ;
            Needlx    ,;
            Ai_Clien  ,;
            Client     ;
      WHERE ;
            BETWEEN(Needlx.Date,from_d,to_d) ;
        AND ;
            Needlx.tc_id       = Ai_Clien.Tc_Id        ;
        AND ;
            Ai_Clien.Client_id = Client.Client_Id      ;
        AND ;
              Needlx.Program = lcprogx ;
        and ;
              (client.indialaska + client.blafrican + client.asian + client.white + ;
                client.hawaisland + client.someother) > 1 ;         
      &cFiltExpr ;   
      INTO CURSOR temp3 ;
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 11          
   
      If Used('FirstCt1')
           Use in FirstCt1
      Endif   
      If Used('FirstCut')
           Use in FirstCut
      EndIf
      
      Select * ;
         From temp ;
      Union ;
      Select * ;
         From temp1 ;
      Union ;
      Select * ;
         From temp3 ;   
      INTO CURSOR ;
            FirstCt1 
              
      oApp.ReopenCur('FirstCt1','FirstCut') 
      
      =clean_temp()     
   
      SELECT FirstCut
      * because of a problem using this IIF in SELECT statment above, determine client age here
      REPLACE ALL Client_Age WITH IIF(!EMPTY(Dob),oApp.AGE(to_d,Dob),00) 
      
      If Used('RepCurs')
           Use in RepCurs
      EndIf
      If Used('RepCurs2')
           Use in RepCurs2
      EndIf                      
      * summary info
      SELECT ;
            EthnicDesc             ,;
            GenderDesc             ,;
            Gender     ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,19), N_In,0))         AS Age0_19_i   ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,0,19), N_Out,0))         AS Age0_19_o   ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,20,29),N_In,0))        AS Age20_29_i  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,20,29),N_Out,0))        AS Age20_29_o  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,30,39),N_In,0))        AS Age30_39_i  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,30,39),N_Out,0))        AS Age30_39_o  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,40,49),N_In,0))        AS Age40_49_i  ,;
            SUM(IIF(!Empty(dob) AND BETWEEN(Client_Age,40,49),N_Out,0))        AS Age40_49_o  ,;
            SUM(IIF(!Empty(dob) AND Client_Age >= 50,N_In,0))                   AS Age50plusi  ,;
            SUM(IIF(!Empty(dob) AND Client_Age >= 50,N_Out,0))                AS Age50pluso  ,;
            SUM(IIF(Empty(dob),N_In,0))                                        AS AgeUnknowi  ,;
            SUM(IIF(Empty(dob),N_Out,0))                                        AS AgeUnknowo  ,;
            0000000                                                             AS T_Ethgen_i  ,;
            0000000                                                           AS T_Ethgen_o  ,;
            SUM(N_Exch)                                                         AS N_Exch,       ;
            type ; 
         FROM ;
            FirstCut ;
         GROUP BY ;
              type, EthnicDesc, GenderDesc, gender ;
         INTO CURSOR ;
            RepCurs2
      
         oApp.ReopenCur('RepCurs2','RepCurs')      
         SELECT RepCurs
         * sum rows now for totals by ethnicity+gender
         REPLACE ALL T_Ethgen_i WITH Age0_19_i + Age20_29_i + Age30_39_i + Age40_49_i + Age50plusi + AgeUnknowi 
         REPLACE ALL T_Ethgen_o WITH Age0_19_o + Age20_29_o + Age30_39_o + Age40_49_o + Age50pluso + AgeUnknowo
         
         If Used('total')
           Use in total
         EndIf 
         If Used('t_total')
           Use in t_total
         EndIf  
         * grand total sums
         Select Sum(T_Ethgen_i) as Grand_i, ;
               Sum(T_Ethgen_o) as Grand_o, ;
               Sum(N_Exch) as Grand_x, ;
               00000000 as T_Female_i, ;
               00000000 as T_Female_o, ;
               00000000 as T_Female_x, ;
               00000000 as T_Male_i, ;
               00000000 as T_Male_o, ;
               00000000 as T_Male_x, ;
               00000000 as T_TG_i, ;
               00000000 as T_TG_o, ;
               00000000 as T_TG_x, ;
               00000000 as T_ne_i, ;
               00000000 as T_ne_o, ;
               00000000 as T_ne_x, ;
               type ;
         From RepCurs ;
         Group by type ;
         Into Cursor t_total

         Index on type tag type 

         oApp.ReopenCur('t_total','total')   
         Set Order to type   

         * jss, 5/30/03, rename t_female_i1, t_female_o1, t_female_x1 to t_femal1_i, t_femal1_o, t_femal1_x to correct problem (was more than 10 chars)
         Store 0 to T_Femal1_i , T_Femal1_o, T_Femal1_x, T_Male_i1, T_Male_o1, T_Male_x1, ;
                  T_TG_i1, T_TG_o1, T_TG_x1, T_ne_i1, T_ne_o1, T_ne_x1

         SELECT RepCurs
         Go top

         * jss, 5/30/03, rename t_female_i1, t_female_o1, t_female_x1 to t_femal1_i, t_femal1_o, t_femal1_x to correct problem (was more than 10 chars)
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_Femal1_i, T_Femal1_o, T_Femal1_x    FOR gender = '10' and type = 'Ethnicity'
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_Male_i1,   T_Male_o1,   T_Male_x1   FOR gender = '11' and type = 'Ethnicity'
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_TG_i1,     T_TG_o1,     T_TG_x1     FOR gender = '12' and type = 'Ethnicity'
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_ne_i1,     T_ne_o1,     T_ne_x1     FOR gender <>'10' and gender <> '11' and gender <> '12' and type = 'Ethnicity'

         * jss, 5/30/03, rename t_female_i1, t_female_o1, t_female_x1 to t_femal1_i, t_femal1_o, t_femal1_x to correct problem (was more than 10 chars)
         Select total
         Replace total.T_Female_i With T_Femal1_i ,;
               total.T_Female_o With T_Femal1_o ,;
               total.T_Female_x With T_Femal1_x ,;
               total.T_Male_i With T_Male_i1, ;
               total.T_Male_o With T_Male_o1, ;
               total.T_Male_x With T_Male_x1, ;
               total.T_TG_i With T_TG_i1, ;
               total.T_TG_o With T_TG_o1, ;
               total.T_TG_x With T_TG_x1, ;
               total.T_ne_i With T_ne_i1, ;
               total.T_ne_o With T_ne_o1, ; 
               total.T_ne_x With T_ne_x1 for type = 'Ethnicity'

         * jss, 5/30/03, rename t_female_i1, t_female_o1, t_female_x1 to t_femal1_i, t_femal1_o, t_femal1_x to correct problem (was more than 10 chars)
         Store 0 to T_Femal1_i , T_Femal1_o, T_Femal1_x, T_Male_i1, T_Male_o1, T_Male_x1, ;
                  T_TG_i1, T_TG_o1, T_TG_x1, T_ne_i1, T_ne_o1, T_ne_x1
         
         SELECT RepCurs
         Go top

         * jss, 5/30/03, rename t_female_i1, t_female_o1, t_female_x1 to t_femal1_i, t_femal1_o, t_femal1_x to correct problem (was more than 10 chars)
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_Femal1_i, T_Femal1_o, T_Femal1_x FOR gender = '10' and type = 'Race'
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_Male_i1,   T_Male_o1,   T_Male_x1   FOR gender = '11' and type = 'Race'
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_TG_i1,     T_TG_o1,     T_TG_x1     FOR gender = '12' and type = 'Race'
         SUM T_Ethgen_i, T_Ethgen_o, N_Exch TO T_ne_i1,     T_ne_o1,     T_ne_x1     FOR gender <>'10' and gender <> '11' and gender <> '12' and type = 'Race'


         * jss, 5/30/03, rename t_female_i1, t_female_o1, t_female_x1 to t_femal1_i, t_femal1_o, t_femal1_x to correct problem (was more than 10 chars)
         Select total
         Replace total.T_Female_i With T_Femal1_i ,;
               total.T_Female_o With T_Femal1_o ,;
               total.T_Female_x With T_Femal1_x ,;
               total.T_Male_i With T_Male_i1, ;
               total.T_Male_o With T_Male_o1, ;
               total.T_Male_x With T_Male_x1, ;
               total.T_TG_i With T_TG_i1, ;
               total.T_TG_o With T_TG_o1, ;
               total.T_TG_x With T_TG_x1, ;
               total.T_ne_i With T_ne_i1, ;
               total.T_ne_o With T_ne_o1, ; 
               total.T_ne_x With T_ne_x1 for type = 'Race'
 
         If Used('RepCursT')
            Use in RepCursT
         Endif   
      
         oApp.msg2user('OFF')
      
         Select RepCurs.* ,;
               total.Grand_i, ;
               total.Grand_o, ;
               total.Grand_x, ;
               total.T_Female_i, ;
               total.T_Female_o, ;
               total.T_Female_x, ;
               total.T_Male_i, ;
               total.T_Male_o, ;
               total.T_Male_x, ;
               total.T_TG_i, ;
               total.T_TG_o, ;
               total.T_TG_x, ;
               total.T_ne_i, ;
               total.T_ne_o, ;
               total.T_ne_x, ;
               Crit as Crit, ;   
               cDate as cDate, ;
               cTime as cTime, ;
               from_d as Date_from, ;
               to_d as date_to;      
         from RepCurs ;
               inner join total on ;
                  RepCurs.type = total.type ;
         into cursor  RepCursT
           
         Go Top
         If EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
                 gcRptName = 'rpt_syr_tab1' 
                 Do Case
                     CASE lPrev = .f.
                          Report Form rpt_syr_tab1 To Printer Prompt Noconsole NODIALOG 
                     CASE lPrev = .t.     &&Preview
                          oApp.rpt_print(5, .t., 1, 'rpt_syr_tab1', 1, 2)
                 EndCase
         Endif 
EndCase   
**************************************
Function clean_race     
       If Used('race1')
         Use In race1
      Endif
      
      If Used('race2')
         Use In race2
      Endif
      
      If Used('race3')
         Use In race3
      Endif

      If Used('race4')
         Use In race4
      Endif

      If Used('race5')
         Use In race5
      Endif

      If Used('race6')
         Use In race6
      Endif

      If Used('race7')
         Use In race7
      EndIf
RETURN
**********************************
Function clean_temp
   If Used('temp')
      Use In temp
   Endif
   
   If Used('temp2')
      Use In temp2
   Endif
   
   If Used('temp3')
      Use In temp3
   Endif

   If Used('temp1')
      Use In temp1
   Endif
return   
   
