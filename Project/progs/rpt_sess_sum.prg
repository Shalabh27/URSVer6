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
lcState   = ""
lcCounty  = ""
cServCat = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "SERV_CAT"
      cServCat = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "LCSTATE"
      lcState = aSelvar2(i, 2)
   EndIf
    If Rtrim(aSelvar2(i, 1)) = "LCCOUNTY"
      lcCounty = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

PRIVATE cOldArea, cWhere
cOldArea = ALIAS()

=OpenFile('ai_outzp')

=OpenView('lv_ai_outr_all', 'urs', 'lv_ai_outr_all', .t., .f.)
=OpenView('lv_ai_outpb_filtered', 'urs', 'lv_ai_outpb_filtered', .t., .f.)
=OpenView('lv_ai_outst_filtered', 'urs', 'lv_ai_outst_filtered', .t., .f.)
=OpenView('lv_ai_outmd_filterd', 'urs', 'lv_ai_outmd_filterd', .t., .f.)
=OpenView('lv_ai_outfc_filtered', 'urs', 'lv_ai_outfc_filtered', .t., .f.)
=OpenView('lv_ai_outsp_filtered', 'urs', 'lv_ai_outsp_filtered', .t., .f.)
=OpenView('lv_ai_outmt_filtered', 'urs', 'lv_ai_outmt_filtered', .t., .f.)
=OpenView('lv_service_outr_filtered', 'urs', 'lv_service_outr_filtered', .t., .f.)


cWhere = IIF(EMPTY(lcProgx)	, "", "program = lcProgx")
cWhere = cWhere + IIF(EMPTY(lcState), "", IIF(!Empty(cWhere),".and.","") + "st = lcState")
** VT 08/05/2008 Dev Tick 4541 
**cWhere = cWhere + IIF(EMPTY(lcCounty), "", IIF(!Empty(cWhere),".and.","") + "cnty_resid = lcCounty")
cWhere = cWhere + IIF(EMPTY(lcCounty), "", IIF(!Empty(cWhere),".and.","") + "county_code = lcCounty and st=lcState")

cWhere = cWhere + IIF(EMPTY(Date_from), "", IIF(!Empty(cWhere),".and.","") + " act_dt >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),   "", IIF(!Empty(cWhere),".and.","") + " act_dt <= Date_to")
cWhere = cWhere + IIF(!Empty(cWhere),".and.","") + " serv_cat = cServCat "

If Used('tmp_id')
   Use in tmp_id
EndIf

** VT 08/05/2008 Dev Tick 4541  need to be done like this, because county_desc in lv_ai_outr_all
** was done  in a way, which not working now 

Select lv_ai_outr_all.* ,;
      Space(3) as county_code ;
from lv_ai_outr_all ;
Into Cursor t_all1 Readwrite

Update  t_all1;
   Set county_desc =zipcode.countyname, ;
       county_code = county.code ;
from t_all1 ;
      inner join zipcode on ;
         t_all1.fips_code= zipcode.countyfips ;
      inner join county on ;
            Upper(zipcode.countyname) = Upper(county.descript) and ;
            t_all1.st = county.state   
  

Update  t_all1 ;
   Set county_desc =zipcode.countyname, ;
        county_code = county.code  ; 
from t_all1 ;
   inner join zipcode on ;
         Left(t_all1.zip, 5) = zipcode.zipcode ;
       and t_all1.st = zipcode.statecode ;
       and Empty(t_all1.fips_code)  ;
    inner join county on ;
            Upper(zipcode.countyname) = Upper(county.descript) and ;
            t_all1.st = county.state   
      

Select distinct act_id, ;
        serv_cat ;                   
from t_all1 ;
where &cWhere ;
into cursor tmp_id

Use In t_all1


If Used('tmp_cat')
   Use in tmp_cat
EndIf

Select distinct serv_cat ;                   
from tmp_id;
into cursor tmp_cat

* prepare totals  total demographics
If Used('demo_tot')
   Use in demo_tot
EndIf

  
SELECT lv_ai_outr_all.serv_cat, ;
   lv_ai_outr_all.serv_cat_name, ;
	COUNT(*) AS tot_sess,;
	SUM(total     ) AS sum_total  , ;
   SUM(total_unkn) AS sum_unkn,    ;
	SUM(n_males   ) AS sum_males  , ;
	SUM(n_females ) AS sum_female , ;
	SUM(n_transmf ) AS sum_tgmf   , ;
	SUM(n_transfm ) AS sum_tgfm   , ;
	SUM(n_children) AS sum_childr , ;
   SUM(n_13_18) as sum_13_18,    ;
   SUM(n_19_24) as sum_19_24,    ;
   SUM(n_25_34) as sum_25_34,    ;
   SUM(n_35_44) as sum_35_44,    ;
   SUM(n_45plus) as sum_45plus,    ;
   SUM(n_hispanic) AS sum_hispan , ;
  	SUM(n_white   ) AS sum_white  , ;
	SUM(n_black   ) AS sum_black  , ;
	SUM(n_asian   ) AS sum_asian  , ;
   Sum(n_hawaisle) as sum_hawaisle, ;
	SUM(n_native  ) AS sum_native , ;
   Sum(n_morthan1) as sum_morthan1, ;
	SUM(n_other   ) AS sum_other  , ;
	Sum(n_raceunkn) as sum_raceunkn, ;
   Sum(risk_idu) as sum_idu, ;
   Sum(risk_msm) as sum_msm, ;
   Sum(risk_msmidu) as sum_msmidu, ;
   Sum(risk_sextrans) as sum_sextrans, ;
   Sum(risk_heterosex) as sum_heterosex,;
   Sum(risk_other) as sum_riskother ;
From lv_ai_outr_all ;
      inner join tmp_id on ;
            lv_ai_outr_all.act_id = tmp_id.act_id ;
group by 1, 2 ;        
Into Cursor demo_tot

***Create tmp cursor                                  
If Used('tmp_outr')
   Use in tmp_outr
EndIf

Create Cursor tmp_outr (col1 char(40), col2 Int(6), list char(2), Order char(5),;
                        header_desc char(50), title_desc char(150), serv_cat Char(5)) 
cCat = ''                        
Select tmp_cat
Scan    
   cCat =  tmp_cat.serv_cat                
                     *** total materials
                     Insert into tmp_outr ; 
                     Select Padr(mt.descript, 40)     AS col1, ;
                            Str(Sum(mt.quantity),6,0) AS col2, ;
                            "01"                            AS LIST,;
                            Padr(mt.material, 5)          AS order, ;
                            Padr("Materials Provided",50) as header_desc, ;
                            "Material                                                                         Quantity" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From lv_ai_outmt_filtered mt ;
                               inner join tmp_id on ;
                                          mt.act_id = tmp_id.act_id and ;
                                          tmp_id.serv_cat = cCat ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Union All ;
                     Select distinct ;
                        	Padr(material.descript, 40)     AS col1, ;
                        	'     0'                     AS col2, ;
                        	"01"                            AS LIST,;
                        	Padr(material.code, 5)          AS order, ;
                           Padr("Materials Provided",50) as header_desc, ;
                           "Material                                                                          Quantity" as title_desc, ; 
                           cCat ;  
                     From material;
                     Where Not Exist (Select * ;
                        				  From lv_ai_outmt_filtered mt ;
                                             inner join tmp_id on ;
                                                      mt.act_id = tmp_id.act_id and ;
                                                      tmp_id.serv_cat = cCat ;
                     					 Where mt.material = material.code) ;
                     Order by 4 
                             
               *** total services
                     *** VT 06/25/2008 Dev Tick 4448 Take out Union All
                     Insert into tmp_outr ; 
                     Select Padr(sp.service,40) AS col1, ;
                            Str(Count(*), 6,0)         AS col2, ;
                            "02"                       AS LIST,;
                            Str(sp.service_id, 5, 0)      AS ORDER, ;
                            Padr("Services/Activities Provided",50) as header_desc, ;
                            "Service/Activity                                                                 Quantity" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From lv_ai_outsp_filtered sp ;
                              inner join tmp_id on ;
                                          sp.act_id = tmp_id.act_id and ;
                                          tmp_id.serv_cat = cCat ;
                     Group by  1, 3, 4, 5, 6, 7 ;
                     Union  ;
                     Select Padr(serv_list.service,40) AS col1, ;
                            '     0'               AS col2, ;
                            "02"                       AS LIST,;
                            Str(serv_list.service_id, 5, 0)      AS ORDER, ;
                            Padr("Services/Activities Provided",50) as header_desc, ;
                            "Service/Activity                                                                 Quantity" as title_desc, ;
                            cCat ;  
                     From lv_service_outr_filtered serv_list;
                     Where serv_list.code = cCat and ;
                           Padr(serv_list.service,40) ;
                           Not IN (Select Padr(sp.service,40) AS col ;
                                   From lv_ai_outsp_filtered sp ;
                                          inner join tmp_id on ;
                                                 sp.act_id = tmp_id.act_id and ;
                                                tmp_id.serv_cat = cCat;
                                  Where sp.service_id= serv_list.service_id ) ;
                     Order by 4 
                     
                 *** Special populuations
                     Insert into tmp_outr ; 
                     Select Padr(fc.descript, 40)     AS col1, ;
                            Str(Sum(fc.n_part),6,0) AS col2, ;
                            "04"                            AS LIST,;
                            Padr(fc.focus, 5)          AS order, ;
                            Padr("Other Targeted Population(s)",50) as header_desc, ;
                            "Type                                                             Approx # of Participants" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From lv_ai_outfc_filtered fc ;
                               inner join tmp_id on ;
                                       fc.act_id = tmp_id.act_id and ;
                                       tmp_id.serv_cat = cCat ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Union All ;
                     Select Padr(focus.descript, 40)        AS col1, ;
                            '     0'                     AS col2, ;
                            "04"                            AS LIST,;
                            Padr(focus.code, 5)         AS order, ;
                            Padr("Other Targeted Population(s)",50) as header_desc, ;
                            "Type                                                             Approx # of Participants" as title_desc, ;
                            cCat ;  
                     From  focus;
                     Where Not Exist (Select * ;
                                      From lv_ai_outfc_filtered fc ;
                                           inner join tmp_id on ;
                                                      fc.act_id = tmp_id.act_id and ;
                                                      tmp_id.serv_cat = cCat;
                                      Where  fc.focus= focus.code) ;
                     Order by 1 
                                       
                   *** methods of delivery
                     Insert into tmp_outr ; 
                     Select Padr(md.descript, 40)     AS col1, ;
                            Str(Count(*), 6,0) AS col2, ;
                            "03"                            AS LIST,;
                            Padr(md.code, 5)          AS order, ;
                            Padr("Method(s) of Delivery",50) as header_desc, ;
                            Space(150) as title_desc, ;
                            tmp_id.serv_cat ;  
                     From lv_ai_outmd_filterd md ;
                               inner join tmp_id on ;
                                       md.act_id = tmp_id.act_id and ;
                                       tmp_id.serv_cat = cCat ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Order by 4 
                     
                     *** target groups
                     Insert into tmp_outr ; 
                     Select Padr(target.descript,40) AS col1,;
                            Str(Count(*), 6,0)         AS col2, ;
                            "07" AS LIST, ;
                            Padr(target.code,5)         AS Order, ;
                            Padr("Target Groups",50) as header_desc, ;
                            "Target                                                                           Quantity" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From lv_ai_outr_all outr;
                               inner join tmp_id on ;
                                       outr.act_id = tmp_id.act_id and ;
                                       tmp_id.serv_cat = cCat ;
                               inner join target on ;
                                       outr.target_grp = target.code ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Union All ;
                     Select Padr(target.descript, 40)     AS col1, ;
                            '     0'                     AS col2, ;
                            "07"                          AS List, ;
                            Padr(target.code, 5)          AS order, ;
                            Padr("Target Groups",50) as header_desc, ;
                            "Target                                                                           Quantity" as title_desc, ;
                            cCat ;  
                     From target;
                     Where Not Exist (Select * ;
                                      From lv_ai_outr_all outr;
                                              inner join tmp_id on ;
                                                   outr.act_id = tmp_id.act_id and ;
                                                   tmp_id.serv_cat = cCat ;
                                     Where outr.target_grp = target.code ) ;
                     Order by 1 
                     
                     *** CDC Location
                     Insert into tmp_outr ; 
                     Select Padr(settings.descript,40) AS col1,;
                            Str(Count(*), 6,0)         AS col2, ;
                            "08" AS list, ;
                            Padr(settings.code,5)         AS order, ;
                            Padr("Location",50) as header_desc, ;
                            "Type                                                                             Quantity" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From lv_ai_outr_all outr;
                               inner join tmp_id on ;
                                       outr.act_id = tmp_id.act_id and ;
                                       tmp_id.serv_cat = cCat ;
                               inner join settings on ;
                                      outr.cdcloctype = settings.code ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Union All ;
                     Select Padr(settings.descript, 40)     AS col1, ;
                            '     0'                AS col2, ;
                            "08"                          AS list, ;
                            Padr(settings.code, 5)          AS order, ;
                            Padr("Location",50) as header_desc, ;
                            "Type                                                                             Quantity" as title_desc, ;
                            cCat ;  
                     From  settings;
                     Where Not Exist (Select * ;
                                      From lv_ai_outr_all outr;
                                              inner join tmp_id on ;
                                                   outr.act_id = tmp_id.act_id and ;
                                                   tmp_id.serv_cat = cCat ;
                                     Where outr.cdcloctype = settings.code) ;
                     Order by 4
                      
                     *** Zip Codes
                     If Used("out_zip")
                        Use in out_zip
                     EndIf

                     Select Padr( left(ai_outzp.zip,5) ,40)      as col1,;
                            Count(*)                        as col2, ;
                            "09"                            as list, ;
                            Padr(Left(ai_outzp.zip, 5), 5)               as order ,;
                            Padr("Zip Codes",50) as header_desc, ;
                            "Zip Code                                                                         Quantity" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From  lv_ai_outr_all outr;
                               inner join tmp_id on ;
                                       outr.act_id = tmp_id.act_id and ;
                                       tmp_id.serv_cat = cCat ;
                               inner join ai_outzp on ;
                                      outr.act_id = ai_outzp.act_id;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Union All ;
                     Select Padr(left(outr.zip,5) ,40)      AS col1, ;
                            Count(*)                        AS col2, ;
                            "09" AS list, ;
                            Padr(outr.zip, 5)               AS order, ;
                            Padr("Zip Codes",50) as header_desc, ;
                            "Zip Code                                                                         Quantity" as title_desc, ;
                            tmp_id.serv_cat ;  
                     From  lv_ai_outr_all outr;
                               inner join tmp_id on ;
                                       outr.act_id = tmp_id.act_id and ;
                                       tmp_id.serv_cat = cCat ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Into Cursor out_zip
                     
                     Insert into tmp_outr ; 
                     Select Iif(!Empty(col1), col1, Padr("ZIP Code not entered",40)) AS col1, ;
                            Str(Sum(col2), 6,0) AS col2, ;
                            list, ;
                            order, ;
                            header_desc, ;
                            title_desc, ;
                            serv_cat ;
                     From out_zip ;
                     Group by 1, 3, 4, 5, 6, 7 ;
                     Order by 4 

EndScan  &&End of serv_cat

*!*   Select   demo_tot.*, ;
*!*            tmp_outr.col1, ;
*!*            tmp_outr.col2, ;
*!*            tmp_outr.list, ;
*!*            tmp_outr.order, ;
*!*            tmp_outr.header_desc, ;
*!*            tmp_outr.title_desc, ;
*!*            Iif(!Empty(cServCat), Iif(demo_tot.serv_cat = "00006", "Education, Training and Outreach Summary Report", ;
*!*            Iif(demo_tot.serv_cat = "00015", "Outreach Summary Report                        ", ;
*!*            Iif(demo_tot.serv_cat = "00016", "Training Summary Report                        ", ;
*!*            Iif(demo_tot.serv_cat = "00017", "HCPI Education Summary Report                  ",;
*!*            Iif(demo_tot.serv_cat = "00018", "HCPI Summary Report                            ", ;
*!*            Iif(demo_tot.serv_cat = "00019", "Other Interventions Summary Report             ", "")))))),;
*!*            "Session Encounters Summary Report              ") as cTitle, ;
*!*            Crit as  Crit, ;   
*!*            cDate as cDate, ;
*!*            cTime as cTime, ;
*!*            Date_from as Date_from, ;
*!*            date_to as date_to;  
*!*   from demo_tot;
*!*      inner join tmp_outr on;
*!*            demo_tot.serv_cat = tmp_outr.serv_cat ;
*!*   into cursor sess_sum ;         
*!*   Order by demo_tot.serv_cat_name, list, order

* jss, 2/21/07, because of new service categories for session-based, use serv_cat_name in title when specific category is selected
Select   demo_tot.*, ;
         tmp_outr.col1, ;
         tmp_outr.col2, ;
         tmp_outr.list, ;
         tmp_outr.order, ;
         tmp_outr.header_desc, ;
         tmp_outr.title_desc, ;
         Iif(!Empty(cServCat), Padr(Alltrim(demo_tot.serv_cat_name)+ ' Summary Report',60), ;
                               Padr("Session Encounters Summary Report",60)) as cTitle, ;
         Crit as  Crit, ;   
         cDate as cDate, ;
         cTime as cTime, ;
         Date_from as Date_from, ;
         date_to as date_to;  
from demo_tot;
   inner join tmp_outr on;
         demo_tot.serv_cat = tmp_outr.serv_cat ;
into cursor sess_sum ;         
Order by demo_tot.serv_cat_name, list, order

Select sess_sum
Go top
oApp.Msg2User('OFF')

IF RECCOUNT("demo_tot") = 0
	oApp.msg2user('NOTFOUNDG')
ELSE
  gcRptName = 'rpt_sess_sum'      
  DO CASE
     CASE lPrev = .f.
          Report Form rpt_sess_sum  To Printer Prompt Noconsole NODIALOG 
     CASE lPrev = .t.     &&Preview
           oApp.rpt_print(5, .t., 1, 'rpt_sess_sum', 1, 2)
  ENDCASE
ENDIF
