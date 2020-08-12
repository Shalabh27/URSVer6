Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

lcProgx   = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

PRIVATE nSaveArea
nSaveArea = Select()
cCategory = ''

DO CASE
   Case InList(lnStat, 61, 62, 63, 64)
      cTitle = "Education, Training and Outreach Data Reports"
      cCategory = "00006"
   CASE InList(lnStat, 151, 152, 153, 154)
      cTitle = "Outreach Data Reports"
      cCategory = "00015"
   CASE InList(lnStat, 161, 162, 163, 164)
      cTitle = "Training Data Reports"
      cCategory = "00016"
   CASE InList(lnStat, 171, 172, 173, 174)
      cTitle = "HCPI Education Data Reports"
      cCategory = "00017"
   CASE InList(lnStat, 182, 183, 184)
      cTitle = "HCPI Data Reports"
      cCategory = "00018"
   CASE InList(lnStat, 192, 193, 194)
      cTitle = "Other Interventions Data Reports"
      cCategory = "00019"
EndCase


DO CASE
   CASE InList(lnStat, 61, 151, 161, 171)  &&Demographic
         
         If Used('t_Info')
            Use in t_Info
         EndIf
            
         SELECT ;
            program.descript                                        AS ProgrDesc,  ;
            category.descript                                       AS CatDesc,    ;
            COUNT(ai_outr.act_id)                                    AS SessTotal,  ;
            SUM(ai_outr.n_males)                                    AS MaleTotal,  ;   
            SUM(ai_outr.n_females)                                    AS FemaleTot,  ;   
            SUM(ai_outr.n_transmf)                                    AS tgmfTotal,  ;   
            SUM(ai_outr.n_transfm)                                    AS tgfmtotal,  ;   
            SUM(ai_outr.n_children)                                    AS ChildTotal, ;   
            SUM(ai_outr.n_adolesc)                                    AS TeenTotal,  ;   
            SUM(ai_outr.n_adults)                                    AS AdultTotal, ;   
            SUM(ai_outr.n_white)                                    AS WhiteTotal, ;   
            SUM(ai_outr.n_black)                                    AS BlackTotal, ;   
            SUM(ai_outr.n_hispanic)                                    AS HispTotal,  ;   
            SUM(ai_outr.n_asian)                                    AS AsianTotal, ;   
            SUM(ai_outr.n_native)                                    AS NativTotal, ;   
            SUM(ai_outr.n_other)                                    AS OtherTotal, ;   
            SUM(ai_outr.total_unkn)                                    AS UnknTotal,  ;   
            SUM(ai_outr.total + ai_outr.total_unkn)                        AS DemoTotal,  ;
            SUM(ai_outr.n_morthan1)   as MoreTotal,   ;
            SUM(ai_outr.n_hawaisle)   as HawaisTotal, ;
            SUM(ai_outr.n_50plus)   as plus50Total, ;
            SUM(ai_outr.n_30_49)   as n30Total, ;
            SUM(ai_outr.n_20_29)   as n20Total  ;
         FROM ;
            ai_outr, program, category ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, date_from, date_to) ;
         AND ai_outr.program = lcprogx ;
         AND ai_outr.program = Program.Prog_id ;
         AND ai_outr.category = category.code And ;
            ai_outr.serv_cat = cCategory And ;
            category.serv_cat = cCategory ;
         INTO CURSOR t_Info ;
         GROUP BY ;
            1, 2 
         
         If Used('EtoInfo')
            Use in EtoInfo
         EndIf
           
         gcRptName = 'rpt_data_dem'
            
         Select *, ;   
               cTitle as cTitle, ;
               Crit as  Crit, ;   
               cDate as cDate, ;
               cTime as cTime, ;
               Date_from as Date_from, ;
               date_to as date_to;   
         From t_info ;
         Into Cursor EtoInfo      
      
        oApp.msg2user('OFF')
            
         GO TOP
         IF EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_data_dem  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                    oApp.rpt_print(5, .t., 1, 'rpt_data_dem', 1, 2)
            ENDCASE   
                  
         EndIf
         
      CASE InList(lnStat, 62, 152, 172, 182)  &&Method of deliv
         
         If Used('t_Info')
            Use in t_Info
         EndIf
         
         SELECT ;
            program.descript                                        AS ProgrDesc, ;
            category.descript                                        AS CatDesc, ;
            delivery.descript                                        AS MethodDesc, ;
            COUNT(ai_outr.act_id)                                    AS SessTotal  ;
         FROM ;
            ai_outr, ai_outmd, category, delivery, program ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, date_from, date_to) ;
         AND ai_outr.program  = lcprogx ;
         AND ai_outr.program  = Program.Prog_id ;
         AND ai_outr.category = category.code ;
         AND ai_outr.act_id   = ai_outmd.act_id ;
         AND ai_outmd.code    = delivery.code  And;
            ai_outr.serv_cat = cCategory And ;
            category.serv_cat = cCategory ;
         INTO CURSOR ;
            t_Info ;
         GROUP BY ;
            1, 2, 3       
   
         If Used('CatTot')
            Use in CatTot
         EndIf
            
         SELECT ;
            program.descript                   AS ProgrDesc, ;
            category.descript                   AS CatDesc, ;
            COUNT(ai_outr.act_id)               AS CatTotal  ;
         FROM ;
            ai_outr, category, program ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, date_from, date_to) ;
         AND ai_outr.category = category.code ;
         AND ai_outr.program = lcprogx ;
         AND ai_outr.program = Program.Prog_id ;
         AND    ai_outr.serv_cat = cCategory And ;
            category.serv_cat = cCategory ;
         INTO CURSOR ;
            CatTot ;
         GROUP BY ;
            1, 2   
         
         If Used('ProgTot') 
               Use in ProgTot
         EndIf
               
         SELECT ;
            program.descript                   AS ProgrDesc, ;
            COUNT(ai_outr.act_id)               AS ProgTotal  ;
         FROM ;
            ai_outr, program ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, date_from, date_to) ;
         AND ai_outr.program = lcprogx ;
         AND ai_outr.program = Program.Prog_id ;
         AND ai_outr.serv_cat = cCategory ;
         INTO CURSOR ;
            ProgTot ;
         GROUP BY 1
      
         * total for agency
         If Used('AgenTot')
               Use in AgenTot
         EndIf
               
         SELECT ;
            '1'                               AS Agency_id, ;
            COUNT(ai_outr.act_id)               AS RepTotal ;
         FROM ;
            ai_outr, program ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, date_from, date_to) ;
         AND ai_outr.program = lcprogx ;
         AND ai_outr.program = Program.Prog_id ;
         AND ai_outr.serv_cat = cCategory ;
         INTO CURSOR ;
            AgenTot ;
         GROUP BY 1
   
         If Used('EtoInfo')
            Use in EtoInfo
         EndIf
         
         gcRptName = 'rpt_data_met'  
          
         Select t_info.*, ;   
               ProgTot.ProgTotal, ;
               CatTot.CatTotal,;
               cTitle as cTitle, ;
               Crit as  Crit, ;   
               cDate as cDate, ;
               cTime as cTime, ;
               Date_from as Date_from, ;
               date_to as date_to;   
         From t_info ;
               inner join ProgTot on ;
                  ProgTot.ProgrDesc = t_info.ProgrDesc ;
               inner join CatTot on ;
                  CatTot.ProgrDesc = t_info.ProgrDesc and ;
                  CatTot.CatDesc = t_info.CatDesc;      
         Into Cursor EtoInfo      
      
         oApp.msg2user('OFF')
            
         GO TOP
         IF EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_data_met  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                    oApp.rpt_print(5, .t., 1, 'rpt_data_met', 1, 2)
            ENDCASE   
                  
         EndIf

   CASE InList(lnStat, 63, 153, 163, 173, 193)  &&Session Type by Presenter by Program 
          If Used('t_Info')
            Use in t_Info
         EndIf
         
         SELECT ;
               program.descript                   AS ProgrDesc, ;
               Iif(Empty(pres_by.descript), PADR('Not Entered',30), pres_by.descript)  AS PresByDesc , ;
               enc_list.description                  AS EncDesc, ;
               COUNT(ai_outr.enc_id)               AS EncTotal, ;
               SUM(ai_outr.total + ai_outr.total_unkn)   AS AttTotal ;   
         FROM ai_outr ;
                    inner join enc_list on ;
                        ai_outr.serv_cat = cCategory ;
                     AND ai_outr.enc_id = enc_list.enc_id ;
                  inner join program on ;
                        ai_outr.program = Program.Prog_id ;
                  left outer join  ai_outpb on ;
                        ai_outr.act_id = ai_outpb.act_id ;
                  left outer join pres_by on ;
                        ai_outpb.code  = pres_by.code ;
         WHERE ;
               BETWEEN(ai_outr.act_dt, date_from, date_to) ;
               AND ai_outr.program = lcprogx ;
         INTO CURSOR t_Info ;
         GROUP BY  1, 2, 3
   
         * now, must grab program totals info
          If Used('ProgTot') 
               Use in ProgTot
         EndIf
         
         SELECT ;
            program.descript                   AS ProgrDesc, ;
            COUNT(ai_outr.enc_id)               AS EncTotal, ;
            SUM(ai_outr.total + ai_outr.total_unkn)   AS AttTotal ;   
         FROM ;
            ai_outr, program ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, m.date_from, m.date_to) ;
         AND ai_outr.program = lcprogx ;
         AND ai_outr.program = Program.Prog_id ;
         AND ai_outr.serv_cat = cCategory ;
         INTO CURSOR ;
            ProgTot ;
         GROUP BY 1

         * total for agency
          If Used('AgenTot') 
               Use in AgenTot
         EndIf
         
         SELECT ;
            '1'                               AS Agency_id, ;
            COUNT(ai_outr.enc_id)               AS EncTotal, ;
            SUM(ai_outr.total + ai_outr.total_unkn)   AS AttTotal ;   
         FROM ;
            ai_outr, program ;
         WHERE ;
            BETWEEN(ai_outr.act_dt, m.date_from, m.date_to) ;
         AND ai_outr.program = lcprogx ;
         AND ai_outr.program = Program.Prog_id ;
         AND ai_outr.serv_cat = cCategory ;
         INTO CURSOR ;
            AgenTot ;
         GROUP BY 1

         If Used('EtoInfo')
            Use in EtoInfo
         EndIf
         
         gcRptName = 'rpt_data_pre'
             
         Select t_info.*, ;   
               ProgTot.EncTotal as p_EncTotal, ;
               ProgTot.AttTotal as p_AttTotal, ;
               cTitle as cTitle, ;
               Crit as  Crit, ;   
               cDate as cDate, ;
               cTime as cTime, ;
               Date_from as Date_from, ;
               date_to as date_to;   
         From t_info ;
               inner join ProgTot on ;
                  ProgTot.ProgrDesc = t_info.ProgrDesc ;
        Into Cursor EtoInfo      
         
         oApp.msg2user('OFF')
            
         GO TOP
         IF EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_data_pre To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                    oApp.rpt_print(5, .t., 1, 'rpt_data_pre', 1, 2)
            ENDCASE   
                  
         EndIf
   
    CASE InList(lnStat, 64, 154, 164, 174, 184, 194)  &&Session and Participant Count by Program 
          If Used('t_Info')
            Use in t_Info
          EndIf
          
          SELECT ;
               program.descript                                        AS ProgrDesc, ;
               LEFT(DTOS(ai_outr.act_dt),6)                               AS SortMnthYr, ;
               CMONTH(ai_outr.act_dt) + ", " + ALLTRIM(STR(YEAR(ai_outr.act_dt)))    AS MonthYear, ;
               COUNT(ai_outr.act_id)                                    AS SessTotal, ;
               SUM(ai_outr.total)                                       AS KnownTotal, ;
               SUM(ai_outr.total_unkn)                                    AS UnknoTotal ;   
            FROM ;
               ai_outr, program ;
            WHERE ;
               BETWEEN(ai_outr.act_dt, date_from, date_to) ;
            AND ai_outr.program = lcprogx ;
            AND ai_outr.program = Program.Prog_id And ;
               ai_outr.serv_cat = cCategory ;
            INTO CURSOR ;
               t_Info ;
            GROUP BY  1, 2 , 3        
            
            If Used('EtoInfo')
               Use in EtoInfo
            EndIf
            
         gcRptName = 'rpt_data_par'  
         
         Select t_info.*, ;   
               cTitle as cTitle, ;
               Crit as  Crit, ;   
               cDate as cDate, ;
               cTime as cTime, ;
               Date_from as Date_from, ;
               date_to as date_to;   
         From t_info ;
         Into Cursor EtoInfo      
         
         oApp.msg2user('OFF')
            
         GO TOP
         IF EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_data_par To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                    oApp.rpt_print(5, .t., 1, 'rpt_data_par', 1, 2)
            ENDCASE   
                  
         EndIf
EndCase
     
         
 