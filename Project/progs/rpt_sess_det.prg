************************************************************************
**This program prints the education,training & outreach form
**It requires the act_id of the encounter selected in the ai_outr screen
*************************************************************************

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
ccWork = ""
cServCat = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROGX"
      lcProgx = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "SERV_CAT"
      cServCat = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      ccWork = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

PRIVATE cOldArea, cWhere
=OpenFile('ai_outzp')
=OpenFile('eto_labels')

=OpenView('lv_ai_outr_all', 'urs', 'lv_ai_outr_all', .t., .f.)
=OpenView('lv_ai_outpb_filtered', 'urs', 'lv_ai_outpb_filtered', .t., .f.)
=OpenView('lv_ai_outst_filtered', 'urs', 'lv_ai_outst_filtered', .t., .f.)
=OpenView('lv_ai_outmd_filterd', 'urs', 'lv_ai_outmd_filterd', .t., .f.)
=OpenView('lv_ai_outfc_filtered', 'urs', 'lv_ai_outfc_filtered', .t., .f.)
=OpenView('lv_ai_outsp_filtered', 'urs', 'lv_ai_outsp_filtered', .t., .f.)
=OpenView('lv_ai_outmt_filtered', 'urs', 'lv_ai_outmt_filtered', .t., .f.)

cWhere = IIF(EMPTY(lcProgx)	, "", "program = lcProgx")
cWhere = cWhere + IIF(EMPTY(Date_from), "", IIF(!Empty(cWhere),".and.","") + " act_dt >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),   "", IIF(!Empty(cWhere),".and.","") + " act_dt <= Date_to")

IF !Empty(cServCat)
   cWhere = IIF(!EMPTY(cWhere), cWhere + ' And ' , '') + ;
         " serv_cat = '" + cServCat + "'"
ENDIF

If Empty(cWhere)
   cWhere = ' .t. '
EndIf

If Used('tmp_id')
   Use in tmp_id
EndIf

If Used('tmp')
   Use in tmp
EndIf


Select distinct act_id, ;
       Space(100) as zip_desc,;
       Space(50) as label1, ; 
       Space(50) as label2, ; 
       Space(50) as label3, ;
       Space(50) as label4, ;
       Space(50) as label5, ;
       Space(50) as label6, ;
       Space(50) as label7, ;
       Space(50) as label8, ; 
       Space(50) as label9, ;
       Space(50) as label10, ;
       Space(50) as label11, ;
       Space(50) as label12, ;
       Space(50) as label13, ;
       Space(50) as label14 ;                             
from lv_ai_outr_all ;
where &cWhere ;
into cursor tmp

If Used('t_work')
   Use in t_work
EndIf


Select Distinct ;
       st.act_id                              AS col1,;
       PADR(oApp.FormatName(st.last, st.first),40) AS col2,;
       STR(st.prep_time,5)                    AS col3,;
       "02" AS LIST,;
       PADR("Session Staffed By", 50) as header_desc, ;
       "Worker                                                Preparation Time(min)" as title_desc ;
from tmp ;
   inner join lv_ai_outst_filtered st on ;
      st.act_id = tmp.act_id ;
where Iif(!Empty(ccWork) , st.worker_id = ccWork, .t.) ; 
into Cursor t_work

If _Tally = 0
	**VT 08/24/2010 Dev Tick 6171 add if and empty  cursor 
	If !Empty(ccWork)
		 	Select *;
         from tmp;
         where 1=2 ;
         into cursor tmp_id readwrite
	else
		   Select *;
		   from tmp;
		   into cursor tmp_id readwrite
   endif
Else
      If !Empty(ccWork)
          Select *;
           from tmp;
           where act_id in (select col1 from t_work) ;
           into cursor tmp_id readwrite 
      Else
           Select *;
           from tmp;
           into cursor tmp_id readwrite
      EndIf
EndIf

Go top
replace zip_desc with GetZips(tmp_id.act_id) all

Update tmp_id ;
   set label1 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user1' and ;
      eto_labels.is_inuse = .t. 
 
Update tmp_id ;
   set label2 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user2' and ;
      eto_labels.is_inuse = .t. 

Update tmp_id ;
   set label3 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user3' and ;
      eto_labels.is_inuse = .t. 
      
Update tmp_id ;
   set label4 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user4' and ;
      eto_labels.is_inuse = .t. 
            
Update tmp_id ;
   set label5 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user5' and ;
      eto_labels.is_inuse = .t.             

Update tmp_id ;
   set label6 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user6' and ;
      eto_labels.is_inuse = .t.   
  
Update tmp_id ;
   set label7 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user7' and ;
      eto_labels.is_inuse = .t.   
      
Update tmp_id ;
   set label8 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user8' and ;
      eto_labels.is_inuse = .t.   
      
Update tmp_id ;
   set label9 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user9' and ;
      eto_labels.is_inuse = .t.   

Update tmp_id ;
   set label10 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user10' and ;
      eto_labels.is_inuse = .t.   

Update tmp_id ;
   set label11 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) =='user11' and ;
      eto_labels.is_inuse = .t. 
                        
Update tmp_id ;
   set label12 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user12' and ;
      eto_labels.is_inuse = .t. 
                              
Update tmp_id ;
   set label13 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user13' and ;
      eto_labels.is_inuse = .t. 
                                   
Update tmp_id ;
   set label14 = eto_labels.eto_label ;
from tmp_id, ;
     eto_labels ;
where Rtrim(eto_labels.control_source) == 'user14' and ;
      eto_labels.is_inuse = .t. 

***Create tmp cursor                                  
If Used('tmp_outr')
   Use in tmp_outr
EndIf

Create Cursor tmp_outr (col1 char(10), col2 Char(40) null, col3 char(5) null, list char(2), ;
                        header_desc char(50), title_desc char(80)) 
                   
****Session Staffed By
Insert into tmp_outr ;
select * ;
from t_work

If Used('t_work')
   Use in t_work
EndIf

****Session Presented By
Insert into tmp_outr ;
Select distinct ;
       pb.act_id         AS col1,;
       PADR(descript,40) AS col2,;
       Space(5)          AS col3,;
       "01" AS LIST,;
       PADR("Session Presented By", 50) as header_desc, ;
       Space(80) as title_desc ;
from tmp_id od ;
   inner join lv_ai_outpb_filtered pb on ;
      pb.act_id = od.act_id  

****Method(s) of Delivery
Insert into tmp_outr ;
Select  Distinct ;
       mdf.act_id  AS col1,;
       PADR(mdf.descript,40) AS col2,;
       Space(5) AS col3,;
       "03" AS LIST,;
       PADR("Method(s) of Delivery", 50) as header_desc, ;
       Space(80) as title_desc ;
From tmp_id od ;
   inner join lv_ai_outmd_filterd mdf on ;
      mdf.act_id = od.act_id  

****Other Targeted Population(s)
Insert into tmp_outr ;  
Select ;
      fc.act_id         AS col1,;
      PADR(fc.descript,40) AS col2,;
      STR(fc.n_part,5)  AS col3,;
      "04" AS LIST,;
      PADR("Other Targeted Population(s)",50) as header_desc, ;
      "Type                                                 Approx # of Participants" as title_desc ;
From lv_ai_outfc_filtered fc ;
   inner join tmp_id on ;
      fc.act_id = tmp_id.act_id 

****Services/Activities Provided
Insert into tmp_outr ; 
Select ;
      sp.act_id            AS col1,;
      PADR(sp.service,40) AS col2,;
      SPACE(5)                   AS col3,;
      "05" AS LIST,;
      PADR("Services/Activities Provided",50) as header_desc, ;
      Space(80) as title_desc ; 
From lv_ai_outsp_filtered sp ;
   inner join tmp_id on ;
      sp.act_id = tmp_id.act_id      

****Materials Provided
Insert into tmp_outr ; 
Select ;
      mt.act_id            AS col1,;
      PADR(mt.descript,40) AS col2,;
      STR(mt.quantity,5)                 AS col3,;
      "05" AS LIST,;
      PADR("Materials Provided",50) as header_desc, ;
      "Material                                                             Quantity" as title_desc ; 
From lv_ai_outmt_filtered mt ;
   inner join tmp_id on ;
      mt.act_id = tmp_id.act_id 
            
If Used('sess_det')
   Use in sess_det
EndIf


*!*   Select outr.*, ;
*!*         outr.act_id as col1, ;
*!*         Iif(outr.inc_provided = .t., 'Yes', 'No ') as incen_provided, ;
*!*         oApp.FormatName(outr.ref_last,outr.ref_first, outr.ref_mi) as contact_name, ;
*!*         FormHours(TimeSpent(outr.beg_tm, outr.beg_am, outr.end_tm, outr.end_am)) as hours_sp, ;   
*!*         od.zip_desc, ;
*!*         od.label1, ; 
*!*         od.label2, ; 
*!*         od.label3, ;
*!*         od.label4, ;
*!*         od.label5, ;
*!*         od.label6, ;
*!*         od.label7, ;
*!*         od.label8, ; 
*!*         od.label9, ;
*!*         od.label10, ;
*!*         od.label11, ;
*!*         od.label12, ;
*!*         od.label13, ;
*!*         od.label14, ;  
*!*         tmp_outr.*, ;    
*!*         Iif(!Empty(cServCat), Iif(outr.serv_cat = "00006", "Education, Training and Outreach Detail Report", ;
*!*         Iif(outr.serv_cat = "00015", "Outreach Detail Report                        ", ;
*!*         Iif(outr.serv_cat = "00016", "Training Detail Report                        ", ;
*!*         Iif(outr.serv_cat = "00017", "HCPI Education Detail Report                  ",;
*!*         Iif(outr.serv_cat = "00018", "HCPI Detail Report                            ", ;
*!*         Iif(outr.serv_cat = "00019", "Other Interventions Detail Report             ", "")))))),;
*!*         "Session Encounters Detail Report              ") as cTitle, ;
*!*         Crit as  Crit, ;   
*!*         cDate as cDate, ;
*!*         cTime as cTime, ;
*!*         Date_from as Date_from, ;
*!*         date_to as date_to; 
*!*   From lv_ai_outr_all outr ;
*!*         inner join tmp_id od on;
*!*               od.act_id = outr.act_id ; 
*!*         left outer join tmp_outr on;
*!*               outr.act_id = tmp_outr.col1 ;
*!*   Into Cursor ;
*!*      sess_det ;
*!*   order by outr.serv_cat_name, outr.act_dt desc, outr.act_id, tmp_outr.list

  
* jss, 2/21/07, because of new service categories for session-based, use serv_cat_name in title when specific category is selected
Select outr.*, ;
      outr.act_id as col1, ;
      Iif(outr.inc_provided = .t., 'Yes', 'No ') as incen_provided, ;
      oApp.FormatName(outr.ref_last,outr.ref_first, outr.ref_mi) as contact_name, ;
      FormHours(TimeSpent(outr.beg_tm, outr.beg_am, outr.end_tm, outr.end_am)) as hours_sp, ;   
      od.zip_desc, ;
      od.label1, ; 
      od.label2, ; 
      od.label3, ;
      od.label4, ;
      od.label5, ;
      od.label6, ;
      od.label7, ;
      od.label8, ; 
      od.label9, ;
      od.label10, ;
      od.label11, ;
      od.label12, ;
      od.label13, ;
      od.label14, ;  
      tmp_outr.*, ;    
      Iif(!Empty(cServCat), Padr(Alltrim(outr.serv_cat_name)+ ' Detail Report',60), ;
                            Padr("Session Encounters Detail Report",60)) as cTitle, ;
      Crit as  Crit, ;   
      cDate as cDate, ;
      cTime as cTime, ;
      Date_from as Date_from, ;
      date_to as date_to; 
From lv_ai_outr_all outr ;
      inner join tmp_id od on;
            od.act_id = outr.act_id ; 
      left outer join tmp_outr on;
            outr.act_id = tmp_outr.col1 ;
Into Cursor ;
   sess_det Readwrite ;
order by outr.serv_cat_name, outr.act_dt desc, outr.act_id, tmp_outr.list

** VT 08/04/2008 Dev Tick 4541  need to be done like this, because county_desc in lv_ai_outr_all
** was done  in a way, which not working now 

Update  sess_det ;
   Set county_desc =Nvl(oApp.get_fips(sess_det.fips_code), 'n/a') ;
from sess_det ;
Where !Empty(fips_code)   

Update  sess_det ;
   Set county_desc =Nvl(zipcode.countyname, 'n/a') ;
from sess_det ;
   inner join zipcode on ;
         Left(sess_det.zip, 5) = zipcode.zipcode ;
       and sess_det.st = zipcode.statecode ;
       and Empty(sess_det.fips_code)  
** VT End


GO TOP
oApp.msg2user('OFF')

IF EOF()
	oApp.msg2user('NOTFOUNDG')
ELSE
   gcRptName = 'rpt_sess_det'  
   Do Case
      Case lPrev = .f.
           Report Form rpt_sess_det To Printer Prompt Noconsole NODIALOG 
      Case lPrev = .t.     &&Preview
           oApp.rpt_print(5, .t., 1, 'rpt_sess_det', 1, 2)
   EndCase
   		
ENDIF
*******************************************************************
FUNCTION GetZips
PARAMETER cAct_ID
PRIVATE nOldArea, cRetString
nOldArea = Select()
cRetString = ""
SELECT ai_outzp
SCAN FOR ai_outzp.act_id = cAct_ID

	cRetString = cRetString + Iif(!Empty(cRetString), ", ", "") + IIF(Len(Trim(ai_outzp.zip)) > 5, ;
										TRANSFORM(ai_outzp.zip, "@R 99999-9999"), ;
										Trim(ai_outzp.zip)) 
ENDSCAN

Select (nOldArea)

Return cRetString
********************************************************************
FUNCTION FormHours
PARAMETER nTime
Return StrTran(Str(INT(nTime/60),2)+":"+Str(nTime%60,2),' ','0')
********************************************************************
FUNCTION TimeSpent
PARAMETER cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
PRIVATE nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
            0, VAL(LEFT(cEnd_tm,2))) + ;
            IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
            0, VAL(LEFT(cBeg_tm,2))) + ;
            IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes =    (nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
         (nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes)
