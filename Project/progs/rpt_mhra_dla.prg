**********************************
*  Program...........: (MHRA Direct Legal Advocacy (DLA) Hours Report)
Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              Dd_from , ;            && from date
              Dd_to, ;               && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

cContract = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCONTRACT"
      cContract = aSelvar2(i, 2)
   EndIf
Endfor

***VT 11/06/2007
**dTempDate = CTOD(Str(Month(d_from),2,0)+"/01/"+Str(Year(d_from),4,0))
**Date_From = dTempDate
**Date_To   = GoMonth(dTempDate, + 1) - 1


cDate = DATE()
cTime = Time()
**cMonthYear = Cmonth(Dd_from) + ", " + RIGHT(DTOC(Dd_from),4)

If Used("tmp_data")
   Use In tmp_data
Endif
   

   
Select iif(!Empty(ai_serv.s_beg_tm) ;
          and !Empty(ai_serv.s_beg_am) ;
          and !Empty(ai_serv.s_end_tm) ;
          and !Empty(ai_serv.s_end_am) , 1, 2) as part_number, ;
       ai_enc.tc_id, ;
       id_no as agency_id, ; 
       ai_enc.casenumber, ;   
       ai_enc.enc_id, ;
       enc_list.description as case_type, ;  
       ai_serv.s_beg_tm, ;
       ai_serv.s_beg_am, ;
       ai_serv.s_end_tm, ;
       ai_serv.s_end_am ;
From contract ;
   inner join contrinf on ;
         contract.Con_ID = contrInf.Cid ;
     and contract.Start_dt <= Dd_from ;
     and contract.End_dt   >= Dd_to ;
     and contrInf.Cid = cContract ;
   inner join consd on ;
         consd.contract = contract.Cid ;
   inner join ai_enc on ;      
         consd.Enc_id = ai_Enc.Enc_id ;
     and consd.serv_cat = ai_enc.serv_cat ;
     and ai_enc.serv_cat =  "00021"  ;
     and ai_enc.program = contract.program ;
   inner join ai_serv on ;
         consd.service_id = ai_serv.service_id;
     and ai_enc.act_id = ai_serv.act_id ;
     And Between(ai_serv.date, Dd_from, Dd_to) ;
   inner join enc_list on ;
         ai_enc.enc_id = enc_list.enc_id ;
   inner join ai_clien on ;
         ai_enc.tc_id = ai_clien.tc_id ;      
Into Cursor tmp_data ;
Order by 1

If Used("tmp_client")
   Use In tmp_client
Endif

Select Count(distinct tc_id) as cl_num ;
From tmp_data ;
Where part_number = 1 ;
Into Cursor tmp_client 

If Used("tmp_hours")
   Use In tmp_hours
Endif

Set Decimals To 2

Select Round((Sum(timespent(s_beg_tm, s_beg_am, s_end_tm, s_end_am)))/60, 2) as enc_hours, ;
       enc_id ; 
From tmp_data ;
Where part_number = 1 ;
Into Cursor tmp_hours ;
Group By enc_id

If Used("tmp_tot_hours")
   Use In tmp_tot_hours
Endif

Select Round((Sum(timespent(s_beg_tm, s_beg_am, s_end_tm, s_end_am)))/60,2) as total_hours ;
From tmp_data ;
Where part_number = 1 ;
Into Cursor tmp_tot_hours ;

Set Decimals To

If Used("mhra_dla")
   Use In mhra_dla 
Endif


Select distinct ;
          part_number,   ;
          tmp_data.enc_id, ;
          Space(10) as tc_id, ;
          Space(20) as agency_id, ; 
          Space(10) as casenumber, ;   
          Alltrim(Str(tmp_data.enc_id)) + ' - ' + Rtrim(case_type) as case_type, ; 
          tmp_client.cl_num, ;
          tmp_hours.enc_hours, ;
          tmp_tot_hours.total_hours, ;
          cDate as cDate, ;
          cTime as cTime, ;
          Crit as Crit, ;
          Dd_from as Date_from, ;
          Dd_to as Date_to ;
From    tmp_data, ;
        tmp_tot_hours, ;
        tmp_client, ;
        tmp_hours;
Where   tmp_data.enc_id = tmp_hours.enc_id ;
     and tmp_data.part_number = 1 ;
Union All;
Select distinct ;
          part_number,   ;
          tmp_data.enc_id, ;
          tc_id, ;
          agency_id, ; 
          casenumber, ;   
          Alltrim(Str(tmp_data.enc_id))  + ' - ' + Rtrim(case_type) as case_type, ; 
          tmp_client.cl_num, ;
          0.00 as enc_hours, ;
          tmp_tot_hours.total_hours, ;
          cDate as cDate, ;
          cTime as cTime, ;
          Crit as Crit, ;
          Dd_from as Date_from, ;
          Dd_to as Date_to ;
From     tmp_data, ; 
         tmp_tot_hours, ;
         tmp_client ;
Where    tmp_data.part_number = 2 ;          
Into Cursor mhra_dla ;
Order By part_number

         
Use In tmp_data
Use in tmp_tot_hours
Use in tmp_client
Use in tmp_hours

oApp.msg2user("OFF")

gcRptName = 'rpt_mhra_dla'

Select mhra_dla

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
     DO CASE
        CASE lPrev = .f.
               Report Form rpt_mhra_dla To Printer Prompt Noconsole NODIALOG 
        CASE lPrev = .t.     
               oApp.rpt_print(5, .t., 1, 'rpt_mhra_dla', 1, 2)
    ENDCASE
Endif



