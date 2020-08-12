Parameters lPrev,;     && Preview
           aSelvar1,;  && select parameters from selection list
           nOrder,;    && order by
           nGroup,;    && report selection
           lcTitle,;   && report selection
           Date_from,; && from date
           Date_to,;   && to date
           Crit,;      && name of param
           lnStat,;    && selection(Output)  page 2
           cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)
LCWORKER = ''
lcProg = ''
LCREFTO = ''
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "LCWORKER"
      lcWorker = aSelvar2(i, 2)
   EndIf
    If Rtrim(aSelvar2(i, 1)) = "LCREFTO"
      lcRefTo = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE gchelp
gchelp = "Agency Referral Report Screen"
cDate = Date()
cTime = Time()
cTitle = 'Agency Referral Report'

If Used('RefAgcy')
   Use in RefAgcy
EndIf

If Used('temp')
   Use in temp
EndIf

** VT 09/25/2008 Dev Tick  4647 Change Select
* Put date limitation in SQL

**1. Ai_enc 
cWhere = ''
cWhere = cWhere + IIF(EMPTY(lcWorker),""," and ai_enc.worker_id = lcWorker ")
cWhere = cWhere + IIF(Empty(lcprog),""," and ai_enc.program = lcprog ")
cWhere = cWhere + IIF(Empty(lcrefto),""," AND ai_ref.ref_to = lcrefto ")

**2. Needlx
cWhereNX = ''
cWhereNX = cWhereNX + IIF(EMPTY(lcWorker),""," and needlx.worker_id = lcWorker ")
cWhereNX = cWhereNX + IIF(Empty(lcprog),""," and needlx.program = lcprog ")
cWhereNX = cWhereNX + IIF(Empty(lcrefto),""," AND ai_ref.ref_to = lcrefto ")

**3. CTR 
cWhereCTR = ''                  
cWhereCTR = cWhereCTR + IIF(EMPTY(lcWorker),""," and staffcur.worker_id = lcWorker ")
cWhereCTR = cWhereCTR + IIF(Empty(lcprog),""," and Iif(!Empty(ctr_test.program_id), ctr_test.program_id =lcprog,ai_ctr.program = lcprog) ")
cWhereCTR = cWhereCTR + IIF(Empty(lcrefto),""," AND ai_ref.ref_to = lcrefto ")

*!*4. HCV RIsk
cWhereHCV = ''           
cWhereHCV = cWhereHCV + IIF(EMPTY(lcWorker),""," and staffcur.worker_id = lcWorker ")
cWhereHCV = cWhereHCV + IIF(Empty(lcprog),""," and Ai_hcv_rapid_testing.prog_id=lcprog ")
cWhereHCV = cWhereHCV + IIF(Empty(lcrefto),""," AND ai_ref.ref_to = lcrefto ")

*!*    jss, 12/5/07, added code for new field "appt_dt"   
*!*    SELECT ;
*!*    	A.TC_ID, ;
*!*    	C.CLIENT_ID, ;
*!*    	Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(D.last_name)), D.last_name) as last_name, ;
*!*      Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(D.first_name)), D.first_name) as first_name, ;
*!*      D.mi, ; 
*!*    	A.ACT_ID,;
*!*    	B.ACT_DT,;
*!*    	B.WORKER_ID,;
*!*    	F.LAST,F.FIRST,F.MI as w_mi,;
*!*    	A.REF_TO,;
*!*      A.REF_DT,;
*!*    	A.VERIF_DT,;
*!*      A.APPT_DT,;
*!*    	A.REF_CAT,;
*!*    	G.DESCRIPT AS REFCAT,;
*!*    	A.STATUS, ;
*!*    	E.NAME AS REFTO_AGCY, ;
*!*      Crit as  Crit, ;   
*!*      cDate as cDate, ;
*!*      cTime as cTime, ;
*!*      Date_from as Date_from, ;
*!*      date_to as date_to;     
*!*    FROM ;
*!*    	AI_REF A, ;
*!*    	AI_ENC B, ;
*!*    	AI_CLIEN C, ;
*!*    	CLIENT D, ;
*!*    	REF_SRCE E, ;
*!*    	STAFFCUR F, ;
*!*    	REF_CAT G ;
*!*    WHERE ;
*!*    	B.ACT_ID = A.ACT_ID AND ;
*!*    	C.TC_ID = B.TC_ID AND ;
*!*    	D.CLIENT_ID = C.CLIENT_ID AND ;
*!*    	F.WORKER_ID = B.WORKER_ID AND ;
*!*    	E.CODE = A.REF_TO AND ;
*!*    	G.CODE = A.REF_CAT AND ;
*!*    	B.PROGRAM = LCPROG AND ;
*!*    	A.REF_TO = LCREFTO AND ;
*!*    	B.WORKER_ID = LCWORKER AND ;
*!*    	BETWEEN(A.REF_DT,DATE_FROM,DATE_TO) ;
*!*    UNION ;
*!*     SELECT ;
*!*    	A.TC_ID, ;
*!*    	C.CLIENT_ID, ;
*!*    	D.last_name, D.first_name, D.mi, ; 
*!*    	A.ACT_ID,;
*!*    	B.DATE AS ACT_DT,;
*!*    	B.WORKER_ID,;
*!*    	F.LAST,F.FIRST,F.MI as w_mi,;
*!*    	A.REF_TO,;
*!*    	A.REF_DT,;
*!*    	A.VERIF_DT,;
*!*      A.APPT_DT,;
*!*    	A.REF_CAT,;
*!*    	G.DESCRIPT AS REFCAT,;
*!*    	A.STATUS, ;
*!*    	E.NAME AS REFTO_AGCY, ;
*!*      Crit as  Crit, ;   
*!*      cDate as cDate, ;
*!*      cTime as cTime, ;
*!*      Date_from as Date_from, ;
*!*      date_to as date_to;
*!*    FROM ;
*!*    	AI_REF A, ;
*!*    	NEEDLX B, ;
*!*    	AI_CLIEN C, ;
*!*    	CLIENT D, ;
*!*    	REF_SRCE E, ;
*!*    	STAFFCUR F, ;
*!*    	REF_CAT G ;
*!*    WHERE ;
*!*    	B.NEED_ID = A.NEED_ID AND ;
*!*    	C.TC_ID = B.TC_ID AND ;
*!*    	D.CLIENT_ID = C.CLIENT_ID AND ;
*!*    	F.WORKER_ID = B.WORKER_ID AND ;
*!*    	E.CODE = A.REF_TO AND ;
*!*    	G.CODE = A.REF_CAT AND ;
*!*    	B.PROGRAM = LCPROG AND ;
*!*    	A.REF_TO = LCREFTO AND ;
*!*    	B.WORKER_ID = LCWORKER AND ;
*!*    	BETWEEN(A.REF_DT,DATE_FROM,DATE_TO) ;	
*!*    INTO CURSOR ;
*!*          temp
 
Select;
   ai_ref.tc_id, ;
   cli_cur.client_id, ;
   oApp.FormatName(cli_cur.last_name,cli_cur.first_name, cli_cur.mi) as full_name, ;
   ai_enc.worker_id,;
   staffcur.last,;
   staffcur.first,;
   staffcur.mi as w_mi,;
   ai_ref.ref_to, ;
   ai_ref.ref_dt,;
   ai_ref.verif_dt,;
   ai_ref.appt_dt,;
   ai_ref.ref_cat,;
   ref_cat.descript as refcat,;
   ai_ref.status, ;
   ref_stat.descript as status_d, ;
   ref_srce.name as refto_agcy, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;     
From ai_ref ;
   Inner Join ai_enc On ;
        ai_ref.act_id=ai_enc.act_id;
   Inner join cli_cur On ;
        ai_enc.tc_id = cli_cur.tc_id;
   Inner Join staffcur On ;
        ai_enc.worker_id = staffcur.worker_id;
   Inner join ref_cat On ;
        ai_ref.ref_cat = ref_cat.code ;
   Left Outer Join ref_srce On ;
        ai_ref.ref_to = ref_srce.code ;
   left outer join ref_stat on ;
       ai_ref.status = ref_stat.code ;    
Where !Empty(ai_enc.act_id) And between(ai_ref.ref_dt, Date_from,Date_to) ;
      &cWhere ;
Union All;
Select  ;
   ai_ref.tc_id, ;
   cli_cur.client_id, ;
   oApp.FormatName(cli_cur.last_name,cli_cur.first_name, cli_cur.mi) as full_name, ;
   needlx.worker_id,;
   staffcur.last,;
   staffcur.first,;
   staffcur.mi as w_mi,;
   ai_ref.ref_to, ;
   ai_ref.ref_dt,;
   ai_ref.verif_dt,;
   ai_ref.appt_dt,;
   ai_ref.ref_cat,;
   ref_cat.descript as refcat,;
   ai_ref.status, ;
   ref_stat.descript as status_d, ;
   ref_srce.name as refto_agcy, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;   
From ai_ref ;
   Inner Join needlx On ;
        ai_ref.need_id=needlx.need_id ;
   Inner join cli_cur On ;
        needlx.tc_id = cli_cur.tc_id ;
   Inner Join staffcur On ;
        needlx.worker_id = staffcur.worker_id ;
   Inner join ref_cat On ;
        ai_ref.ref_cat = ref_cat.code ;
   Left Outer Join ref_srce On ;
        ai_ref.ref_to = ref_srce.code ;
   Left outer join ref_stat on ;
        ai_ref.status = ref_stat.code ;    
Where !Empty(needlx.need_id) And between(ai_ref.ref_dt, Date_from,Date_to) ;
     &cWhereNX ;
Union All;
Select;
   ai_ref.tc_id, ;
   cli_cur.client_id, ;
   oApp.FormatName(cli_cur.last_name,cli_cur.first_name, cli_cur.mi) as full_name, ;
   staffcur.worker_id,;
   staffcur.last,;
   staffcur.first,;
   staffcur.mi as w_mi,;
   ai_ref.ref_to, ;
   ai_ref.ref_dt,;
   ai_ref.verif_dt,;
   ai_ref.appt_dt,;
   ai_ref.ref_cat,;
   ref_cat.descript as refcat,;
   ai_ref.status, ;
   ref_stat.descript as status_d, ;
   ref_srce.name as refto_agcy, ;
   Crit as  Crit, ;
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;
From ai_ref ;
   Inner Join ctr_test On ;
        ai_ref.ctrtest_id=ctr_test.ctrtest_id  ;
          And Empty(ai_ref.act_id) ;
   Inner join ai_ctr on ;
        ai_ctr.ctr_id = ctr_test.ctr_id ;
   Inner join cli_cur On ;
        ai_ctr.tc_id = cli_cur.tc_id ;
   Inner Join staffcur On ;
        ctr_test.worker_id = staffcur.pworker_id ;
   inner join ref_cat On ;
        ai_ref.ref_cat = ref_cat.code ;
   Left Outer Join ref_srce On ;
        ai_ref.ref_to = ref_srce.code ;
   left outer join ref_stat on ;
       ai_ref.status = ref_stat.code ;
Where !Empty(ctr_test.ctrtest_id) And between(ai_ref.ref_dt, Date_from,Date_to) ;
      &cWhereCTR ;
Union All;
Select;
   ai_ref.tc_id, ;
   cli_cur.client_id, ;
   oApp.FormatName(cli_cur.last_name,cli_cur.first_name, cli_cur.mi) as full_name, ;
   staffcur.worker_id,;
   staffcur.last,;
   staffcur.first,;
   staffcur.mi as w_mi,;
   ai_ref.ref_to, ;
   ai_ref.ref_dt,;
   ai_ref.verif_dt,;
   ai_ref.appt_dt,;
   ai_ref.ref_cat,;
   ref_cat.descript as refcat,;
   ai_ref.status, ;
   ref_stat.descript as status_d, ;
   ref_srce.name as refto_agcy, ;
   Crit as  Crit, ;
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;
From ai_ref ;
   Inner Join Ai_hcv_rapid_testing On ;
        ai_ref.hcv_rapidid=Ai_hcv_rapid_testing.Hcv_rapidid ;
   Inner join cli_cur On ;
        Ai_hcv_rapid_testing.tc_id = cli_cur.tc_id ;
   Inner Join staffcur On ;
        Ai_hcv_rapid_testing.Staff_id = staffcur.worker_id ;
   inner join ref_cat On ;
        ai_ref.ref_cat = ref_cat.code ;
   Left Outer Join ref_srce On ;
        ai_ref.ref_to = ref_srce.code ;
   left outer join ref_stat on ;
       ai_ref.status = ref_stat.code ;
Where !Empty(Ai_hcv_rapid_testing.Hcv_rapidid) And between(ai_ref.ref_dt, Date_from,Date_to) ;
      &cWhereHCV ;
Order By 3, 9 desc, 11, 12 ;
Into Cursor REFAGCY
 
Index On Upper(full_name) Tag full_name    
SELECT RefAgcy
Set Order to full_name
       
oApp.Msg2User('OFF')

Select RefAgcy
Go Top
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   gcRptName = 'rpt_ref_agcy'
   Do Case
      Case lPrev = .f.
         Report Form rpt_ref_agcy  To Printer Prompt Noconsole NODIALOG 
         
      Case lPrev = .t.     &&Preview
         oApp.rpt_print(5, .t., 1, 'rpt_ref_agcy', 1, 2)
   EndCase 
EndIf
Return






       