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
cServCat = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
    If Rtrim(aSelvar2(i, 1)) = "SERV_CAT"
      cServCat = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

PRIVATE nSaveArea
nSaveArea = Select()

=OpenView('lv_ai_outr_all', 'urs', 'lv_ai_outr_all', .t., .f.)
=OpenView('lv_ai_outmd_filterd', 'urs', 'lv_ai_outmd_filterd', .t., .f.)
=OpenView('lv_ai_outpb_filtered', 'urs', 'lv_ai_outpb_filtered', .t., .f.)

cWhere = IIF(EMPTY(lcProgx)   , "", "program = lcProgx")
cWhere = cWhere + IIF(EMPTY(Date_from), "", IIF(!Empty(cWhere),".and.","") + " act_dt >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),   "", IIF(!Empty(cWhere),".and.","") + " act_dt <= Date_to")

IF !Empty(cServCat)
   cWhere = IIF(!EMPTY(cWhere), cWhere + ' And ' , '') + ;
         " serv_cat = '" + cServCat + "'"
ENDIF

If Empty(cWhere)
   cWhere = ' .t. '
EndIf

DO Case
   Case lnStat = 1  &&Demographic
         If Used('t_Info')
            Use in t_Info
         EndIf
            
         Select prog_name as  ProgrDesc,  ;
                serv_cat_name, ;
                serv_cat, ;
                Count(act_id) as SessTotal,  ;
                Sum(n_males   ) as MaleTotal  , ;
                Sum(n_females ) as FemaleTot , ;
                Sum(n_transmf ) as tgmfTotal   , ;
                Sum(n_transfm ) as tgfmtotal   , ;
                Sum(n_children) as ChildTotal, ;   
                Sum(n_13_18)  as TeenTotal,  ;  
                Sum(n_19_24) as n19total,    ;
                Sum(n_25_34) as n25total,    ;
                Sum(n_35_44) as n35total,    ;
                Sum(n_45plus) as plus45total,    ;
                Sum(n_white)    as WhiteTotal, ;   
                Sum(n_black)    as BlackTotal, ;   
                Sum(n_hispanic) as HispTotal,  ;   
                Sum(n_asian)    as AsianTotal, ;   
                Sum(n_native)   as NativTotal, ;   
                Sum(n_other)    as OtherTotal, ;   
                Sum(total_unkn) as UnknTotal,  ;   
                Sum(total + total_unkn)   AS DemoTotal,  ;
                Sum(n_morthan1)   as MoreTotal,   ;
                Sum(n_hawaisle)   as HawaisTotal ;
         From lv_ai_outr_all ;
         Where &cWhere ;
         Into Cursor t_Info ;
         Group by 1, 2, 3
         
         If Used('sess_dem')
            Use in sess_dem
         EndIf
           
         gcRptName = 'rpt_sess_dem'
            
*!*            Select *, ;   
*!*                  Iif(!Empty(cServCat), Iif(serv_cat = "00006", "Education, Training and Outreach Data Report", ;
*!*                  Iif(serv_cat = "00015", "Outreach Data Report                        ", ;
*!*                  Iif(serv_cat = "00016", "Training Data Report                        ", ;
*!*                  Iif(serv_cat = "00017", "HCPI Education Data Report                  ",;
*!*                  Iif(serv_cat = "00018", "HCPI Data Report                            ", ;
*!*                  Iif(serv_cat = "00019", "Other Interventions Data Report             ", ;
*!*                                          "                                            ")))))),;
*!*                  "Session Encounters Data Report              ") as cTitle, ;
*!*                  Crit as  Crit, ;   
*!*                  cDate as cDate, ;
*!*                  cTime as cTime, ;
*!*                  Date_from as Date_from, ;
*!*                  date_to as date_to;   
*!*            From t_info ;
*!*            Into Cursor sess_dem    ;
*!*            order by progrdesc, serv_cat_name 
      
* jss, 2/21/07, because of new service categories for session-based, use serv_cat_name in title when specific category is selected
         Select *, ;   
               Iif(!Empty(cServCat), Padr(Alltrim(t_info.serv_cat_name)+ ' Data Report',60), ;
                                     Padr("Session Encounters Data Report",60)) as cTitle, ;
               Crit as  Crit, ;   
               cDate as cDate, ;
               cTime as cTime, ;
               Date_from as Date_from, ;
               date_to as date_to;   
         From t_info ;
         Into Cursor sess_dem    ;
         order by progrdesc, serv_cat_name 
      
         oApp.msg2user('OFF')
            
         GO TOP
         IF EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_sess_dem  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                    oApp.rpt_print(5, .t., 1, 'rpt_sess_dem', 1, 2)
            ENDCASE   
                  
         EndIf
         
   Case lnStat = 2  &&Method of deliv
            If Used('t_Info')
               Use in t_Info
            EndIf
         
            Select prog_name as  ProgrDesc,  ;
                   serv_cat_name as CatDesc, ;
                   serv_cat, ;
                   mdel.descript  as MethodDesc, ;
                   Count(outr.act_id) as SessTotal  ;
            From lv_ai_outr_all outr ;
                  inner join lv_ai_outmd_filterd mdel on ;
                      outr.act_id   = mdel.act_id ;
            Where &cWhere ;
            Into Cursor t_Info ;
            Group By 1, 2, 3, 4       
   
            If Used('CatTot')
               Use in CatTot
            EndIf
          
            Select prog_name as  ProgrDesc,  ;
                   serv_cat_name as CatDesc, ;
                   serv_cat, ;
                   Count(outr.act_id)  as CatTotal  ;
            From lv_ai_outr_all outr ;
            Where &cWhere ;
            Into Cursor CatTot ;
            Group By 1, 2, 3   
         
            If Used('ProgTot') 
                  Use in ProgTot
            EndIf
               
            Select prog_name as  ProgrDesc,  ;
                   Count(outr.act_id)               AS ProgTotal  ;
            From lv_ai_outr_all outr ;
            Where &cWhere ;
            Into Cursor ProgTot ;
            Group By 1
      
            * total for agency
            If Used('AgenTot')
                  Use in AgenTot
            EndIf
                  
            Select '1'                               AS Agency_id, ;
                   Count(outr.act_id)               AS RepTotal ;
            From lv_ai_outr_all outr ;
            Where &cWhere ;
            Into Cursor AgenTot ;
            Group By 1
   
            If Used('sess_met')
               Use in sess_met
            EndIf
         
            gcRptName = 'rpt_sess_met'  
          
*!*               Select t_info.*, ;   
*!*                      ProgTot.ProgTotal, ;
*!*                      CatTot.CatTotal,;
*!*                      Iif(!Empty(cServCat), Iif(t_info.serv_cat = "00006", "Education, Training and Outreach Data Report", ;
*!*                      Iif(t_info.serv_cat = "00015", "Outreach Data Report                        ", ;
*!*                      Iif(t_info.serv_cat = "00016", "Training Data Report                        ", ;
*!*                      Iif(t_info.serv_cat = "00017", "HCPI Education Data Report                  ",;
*!*                      Iif(t_info.serv_cat = "00018", "HCPI Data Report                            ", ;
*!*                      Iif(t_info.serv_cat = "00019", "Other Interventions Data Report             ", ;
*!*                                                     "                                            ")))))),;
*!*                      "Session Encounters Data Report              ") as cTitle, ;
*!*                      Crit as  Crit, ;   
*!*                      cDate as cDate, ;
*!*                      cTime as cTime, ;
*!*                      Date_from as Date_from, ;
*!*                      date_to as date_to;   
*!*               From t_info ;
*!*                     inner join ProgTot on ;
*!*                        ProgTot.ProgrDesc = t_info.ProgrDesc ;
*!*                     inner join CatTot on ;
*!*                        CatTot.ProgrDesc = t_info.ProgrDesc and ;
*!*                        CatTot.CatDesc = t_info.CatDesc;      
*!*               Into Cursor sess_met      
      
* jss, 2/21/07, because of new service categories for session-based, use catdesc in title when specific category is selected
            Select t_info.*, ;   
                   ProgTot.ProgTotal, ;
                   CatTot.CatTotal,;
                   Iif(!Empty(cServCat), Padr(Alltrim(t_info.catdesc)+ ' Data Report',60), ;
                                         Padr("Session Encounters Data Report",60)) as cTitle, ;
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
            Into Cursor sess_met      
      
            oApp.msg2user('OFF')
            
            GO TOP
            IF EOF()
               oApp.msg2user('NOTFOUNDG')
            Else
               DO CASE
                  CASE lPrev = .f.
                       Report Form rpt_sess_met  To Printer Prompt Noconsole NODIALOG 
                  CASE lPrev = .t.     &&Preview
                       oApp.rpt_print(5, .t., 1, 'rpt_sess_met', 1, 2)
               ENDCASE   
                     
            EndIf

   Case lnStat = 3  &&Session Type by Presenter by Program 
             If Used('t_Info')
                Use in t_Info
             EndIf
         
             Select prog_name as  ProgrDesc,  ;
                    serv_cat_name as CatDesc, ;
                    serv_cat, ;
                    pb.descript  as PresByDesc , ;
                    outr.enc_name   as EncDesc, ;
                    Count(outr.enc_id) as EncTotal, ;
                    Sum(total + outr.total_unkn) as AttTotal ;   
             From lv_ai_outr_all outr ;
                     inner join lv_ai_outpb_filtered pb on ;
                         outr.act_id   = pb.act_id ;
             Where &cWhere ;
             Into Cursor t_Info ;
             Group By 1, 2, 3, 4, 5   
            
            * now, must grab program totals info
             If Used('ProgTot') 
                  Use in ProgTot
             EndIf
            
             Select prog_name as  ProgrDesc,  ;
                    serv_cat, ;
                    Count(outr.enc_id) as EncTotal, ;
                    Sum(outr.total + outr.total_unkn)   AS AttTotal ;   
            From lv_ai_outr_all outr ;
            Where &cWhere ;
            Into Cursor ProgTot ;
            Group by 1, 2
            
           * total for agency
            If Used('AgenTot') 
               Use in AgenTot
            EndIf
         
            Select '1'    as Agency_id, ;
                  Count(outr.enc_id) as EncTotal, ;
                  Sum(total + outr.total_unkn)   AS AttTotal ;   
            From lv_ai_outr_all outr ;
            Where &cWhere ;
            Into Cursor AgenTot ;
            Group by 1

            If Used('sess_prb')
               Use in sess_prb
            EndIf
         
            gcRptName = 'rpt_sess_prb'
      
*!*               Select t_info.*, ;   
*!*                      ProgTot.EncTotal as p_EncTotal, ;
*!*                      ProgTot.AttTotal as p_AttTotal, ;
*!*                      Iif(!Empty(cServCat), Iif(t_info.serv_cat = "00006", "Education, Training and Outreach Data Report", ;
*!*                      Iif(t_info.serv_cat = "00015", "Outreach Data Report                        ", ;
*!*                      Iif(t_info.serv_cat = "00016", "Training Data Report                        ", ;
*!*                      Iif(t_info.serv_cat = "00017", "HCPI Education Data Report                  ",;
*!*                      Iif(t_info.serv_cat = "00018", "HCPI Data Report                            ", ;
*!*                      Iif(t_info.serv_cat = "00019", "Other Interventions Data Report             ",  ;
*!*                                                     "                                            ")))))),;
*!*                      "Session Encounters Data Report              ") as cTitle, ;
*!*                      Crit as  Crit, ;   
*!*                      cDate as cDate, ;
*!*                      cTime as cTime, ;
*!*                      Date_from as Date_from, ;
*!*                      date_to as date_to;   
*!*               From t_info ;
*!*                     inner join ProgTot on ;
*!*                        ProgTot.ProgrDesc = t_info.ProgrDesc and ;
*!*                        ProgTot.serv_cat = t_info.serv_cat ;
*!*              Into Cursor sess_prb    
         
* jss, 2/21/07, because of new service categories for session-based, use catdesc in title when specific category is selected
            Select t_info.*, ;   
                   ProgTot.EncTotal as p_EncTotal, ;
                   ProgTot.AttTotal as p_AttTotal, ;
                   Iif(!Empty(cServCat), Padr(Alltrim(t_info.catdesc)+ ' Data Report',60), ;
                                         Padr("Session Encounters Data Report",60)) as cTitle, ;
                   Crit as  Crit, ;   
                   cDate as cDate, ;
                   cTime as cTime, ;
                   Date_from as Date_from, ;
                   date_to as date_to;   
            From t_info ;
                  inner join ProgTot on ;
                     ProgTot.ProgrDesc = t_info.ProgrDesc and ;
                     ProgTot.serv_cat = t_info.serv_cat ;
           Into Cursor sess_prb    
         
           oApp.msg2user('OFF')
            
           Go Top
           IF EOF()
               oApp.msg2user('NOTFOUNDG')
           Else
               DO CASE
                  CASE lPrev = .f.
                       Report Form rpt_sess_prb To Printer Prompt Noconsole NODIALOG 
                  CASE lPrev = .t.     &&Preview
                       oApp.rpt_print(5, .t., 1, 'rpt_sess_prb', 1, 2)
               ENDCASE   
           EndIf
   
   Case lnStat = 4  &&Session and Participant Count by Program 
           If Used('t_Info')
             Use in t_Info
           EndIf
    
          Select  prog_name as  ProgrDesc,  ;
                  serv_cat_name as CatDesc, ;
                  serv_cat, ;         
                  Left(Dtos(outr.act_dt),6)  as SortMnthYr, ;
                  Cmonth(outr.act_dt) + ", " + Alltrim(Str(Year(outr.act_dt))) as MonthYear, ;
                  Count(outr.act_id) as SessTotal, ;
                  Sum(outr.total)     as KnownTotal, ;
                  Sum(outr.total_unkn) as UnknoTotal ;   
            From lv_ai_outr_all outr;
            Where &cWhere ;
            Into Cursor t_Info ;
            Group By  1, 2 , 3 , 4, 5       
            
            If Used('sess_par')
               Use in sess_par
            EndIf
            
         gcRptName = 'rpt_sess_par'  
         
*!*            Select t_info.*, ;   
*!*                   Iif(!Empty(cServCat), Iif(t_info.serv_cat = "00006", "Education, Training and Outreach Data Report", ;
*!*                   Iif(t_info.serv_cat = "00015", "Outreach Data Report                        ", ;
*!*                   Iif(t_info.serv_cat = "00016", "Training Data Report                        ", ;
*!*                   Iif(t_info.serv_cat = "00017", "HCPI Education Data Report                  ",;
*!*                   Iif(t_info.serv_cat = "00018", "HCPI Data Report                            ", ;
*!*                   Iif(t_info.serv_cat = "00019", "Other Interventions Data Report             ",  ;
*!*                                                  "                                            ")))))),;
*!*                   "Session Encounters Data Report              ") as cTitle, ;
*!*                   Crit as  Crit, ;   
*!*                   cDate as cDate, ;
*!*                   cTime as cTime, ;
*!*                   Date_from as Date_from, ;
*!*                   date_to as date_to;   
*!*            From t_info ;
*!*            Into Cursor sess_par     
         
* jss, 2/21/07, because of new service categories for session-based, use catdesc in title when specific category is selected
         Select t_info.*, ;   
            Iif(!Empty(cServCat), Padr(Alltrim(catdesc)+ ' Data Report',60), ;
                                  Padr("Session Encounters Data Report",60)) as cTitle, ;
                Crit as  Crit, ;   
                cDate as cDate, ;
                cTime as cTime, ;
                Date_from as Date_from, ;
                date_to as date_to;   
         From t_info ;
         Into Cursor sess_par     
         
         oApp.msg2user('OFF')
            
         GO TOP
         IF EOF()
            oApp.msg2user('NOTFOUNDG')
         Else
            DO CASE
               CASE lPrev = .f.
                    Report Form rpt_sess_par To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     &&Preview
                    oApp.rpt_print(5, .t., 1, 'rpt_sess_par', 1, 2)
            ENDCASE   
         EndIf
EndCase
     
         
 