****************************************************
* Program: 	Mai_rep.prg
* Summary: 	Creates MAI Plan and Annual Report
****************************************************
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

cMai_title   = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CMAI_TITLE"
      cMai_title = aSelvar2(i, 2)
   EndIf
EndFor

cDate = DATE()
cTime = TIME()

PRIVATE gchelp
gchelp = "Generating MAI Report"
m.Date_From = Date_from
m.Date_To   = Date_to
cTitle="MAI Plan and Annual Report"

=OpenFile("Mai_head","TitleDates")
=OpenFile("Mai_det","m_head_id")

Select TRIM(descript) From fundtype Where code=cMai_title Into Array aTitleDsc
m.m_titledsc=aTitleDsc(1)
Release aTitleDsc

If Used ('mai_tmp')
   Use in mai_tmp
EndIf
   
Create Cursor mai_tmp (m_title C(2), activity C(2), ethnicrace C(2), question C(2), detailline M, headerline M)
Index on m_title+activity+ethnicrace+question tag mai_tmp

IF CreatRpt()
   If Used('mai_rpt')
      Use in mai_rpt
   EndIf
      
	Select Mai_tmp.*, ;
          Crit as  Crit, ;   
          cDate as cDate, ;
          cTime as cTime, ;
          Date_from as Date_from, ;
          date_to as date_to; 
   from Mai_tmp ;
   into cursor Mai_rpt;
   order by m_title, activity, ethnicrace, question
   
   Go top
   gcRptName = 'rpt_mai'  
   oApp.msg2user('OFF')
   DO CASE
         CASE lPrev = .f.
              Report Form rpt_mai To Printer Prompt Noconsole NODIALOG 
          CASE lPrev = .t.     &&Preview
              oApp.rpt_print(5, .t., 1, 'rpt_mai', 1, 2)
   ENDCASE   
     
Else
   oApp.msg2user('OFF')
   oApp.msg2user('INFORM', 'Unable to Create MAI Report...Exiting')
   RETURN
ENDIF	


RETURN
******************
PROCEDURE CreatRpt
******************
SELECT mai_head
mKey=cMai_title+DTOS(m.date_from)+DTOS(m.date_to)

IF SEEK(mKey)
	SCATTER MEMVAR
	SELECT mai_det
	IF SEEK(m.m_head_id)
		SCAN FOR m_head_id=m.m_head_id
			SCATTER MEMVAR MEMO
			=MakeRpt()
		ENDSCAN	
	ELSE
	   oApp.msg2user('INFORM', 'No MAI Detail Information found for MAI Title and Dates combination')	
	   RETURN .f.
	ENDIF		
ELSE
   oApp.msg2user('INFORM', 'No MAI Header Information found for MAI Title and Dates combination')	
	RETURN .f.	
ENDIF
RETURN
*****************
PROCEDURE MakeRpt
*****************
* first, let's determine which programs have this MAI fund_type
If Used('tProg')
   Use in tProg
EndIf
   
Select * From program Where fund_type=cMai_title Into Cursor tProg

* first, grab all services with ai_serv.mai_map=m.activity (and with parent encounter in program)
If Used('all_serv')
   Use in all_serv
EndIf
   
Select	ai_serv.tc_id, ;
   		ai_serv.act_id, ;
   		ai_serv.serv_cat, ;
   		ai_enc.enc_id, ;
   		ai_serv.date as act_dt, ;
   		lv_service.mai_map ;
From ai_serv, ai_enc, lv_service, tprog ;
Where ai_serv.act_id = ai_enc.act_id and ;
		ai_serv.serv_cat = lv_service.serv_cat and ;
		ai_enc.enc_id = lv_service.enc_id and ;
		!Empty(lv_service.mai_map) and ;
		lv_service.mai_map = m.activity and ;
		ai_enc.program=tprog.prog_id and ;
		between(ai_serv.date, m.date_from, m.date_to) ;
Into Cursor ;
		all_serv

* now grab any encounters without services having this mai_map
If Used('all_enc')
   Use in all_enc
EndIf
   
Select 	ai_enc.tc_id, ;
   		ai_enc.act_id, ;
   		ai_enc.serv_cat, ;
   		ai_enc.enc_id, ;
   		ai_enc.act_dt, ;
   		lv_enc_type.mai_map ;
From     ai_enc, lv_enc_type, tprog ;
Where ai_enc.serv_cat = lv_enc_type.serv_cat and ;
		ai_enc.enc_type = lv_enc_type.enc_id and ; 
		!Empty(lv_enc_type.mai_map) and ;
		lv_enc_type.mai_map = m.activity and ;
		ai_enc.program = tprog.prog_id and ;
		between(ai_enc.act_dt, m.date_from, m.date_to) ;
 AND ai_enc.act_id NOT IN (Select act_id FROM ai_serv) ;		
Into Cursor ;
		all_enc

If used('all_mai')	
   Use in all_mai
EndIf
   
Select * ;
From all_serv ;
Union All ;
Select * ;
From all_enc ;
Into Cursor	all_mai

* now, get age and gender info so we can count women, infants, children, youth
If Used('mai_demo1')
   Use in mai_demo1
EndIf

If Used('mai_demo2')
   Use in mai_demo2
EndIf
   
Select 	all_mai.tc_id, ;
			all_mai.act_id, ;
			gender.gender, ;
			client.dob, ; 
			client.hispanic, ;
			client.white, ;
			client.blafrican, ;
			client.asian, ;
			client.indialaska, ;
			client.hawaisland, ;
			client.someother, ;
			'  ' as ethnicrace, ;
			000 as age ; 
From 		all_mai, gender, ai_clien, client ;	
Where		all_mai.tc_id=ai_clien.tc_id ;
and		ai_clien.client_id=client.client_id ;
and		client.gender=gender.code ;
Into Cursor mai_demo1

oApp.ReopenCur("mai_demo1","mai_demo2")

IF RECC()>0
* if no dob entered, assume age 25 (adult)
	Replace All Age with IIF(!EMPTY(dob),Age(m.date_to, dob),25)

* determine the MAI ethnicity/race (hierarchy: hispanic, more than one race, individual race)
	SCAN
		DO CASE
			CASE hispanic=2
				replace ethnicrace with '04'
			CASE (white + blafrican + asian + indialaska + hawaisland + someother) > 1
				replace ethnicrace with '06'
			CASE asian=1
				replace ethnicrace with '01'
			CASE indialaska=1
				replace ethnicrace with '02'
			CASE blafrican=1
				replace ethnicrace with '03'
			CASE hawaisland=1
				replace ethnicrace with '05'
		ENDCASE
	ENDSCAN
ENDIF

If Used('mai_demo')
   Use in mai_demo
EndIf
   
Select * From mai_demo2 Where ethnicrace=m.ethnicrace Into cursor mai_demo

* now, count total clients
Select Count(DIST tc_id) From mai_demo Into Array aTotCli
m.totcli=aTotCli(1)
Release aTotcli

* now, count total services
Select Count(*) From mai_demo Into Array aTotServ
m.totservs=aTotServ(1)
Release aTotServ

* now, count women (female, 18 and older)
Select Count(dist tc_id) From mai_demo Where gender='F' and Age>=18 Into Array aTotWomen
m.totwomen=aTotWomen(1)
Release aTotWomen

* now, count infants (age less than 2)
Select Count(dist tc_id) From mai_demo Where Age<2 Into Array aTotInfant
m.totinfant=aTotInfant(1)
Release aTotInfant

* now, count children (age 2-12)
Select Count(dist tc_id) From mai_demo Where Age>=2 and Age<=12 Into Array aTotChild
m.totchild=aTotChild(1)
Release aTotChild

* now, count youth (age 13-17)
Select Count(dist tc_id) From mai_demo Where Age>=13 and Age<=17 Into Array aTotYouth
m.totyouth=aTotYouth(1)
Release aTotYouth

m.question='00'
m.detailline=''
m.headerline='Identifying Information for:  '+ m.m_titledsc
Insert Into mai_tmp From Memvar
m.headerline=Space(5) + 'Contractor Name:         '+m.m_name
Insert Into mai_tmp From Memvar
m.headerline=Space(5) + 'Report Start Date:            '
m.detailline=Space(35) + Dtoc(m.date_from)
Insert Into mai_tmp From Memvar
m.headerline=Space(5) + 'Report End Date: '
m.detailline=Space(35) + Dtoc(m.date_to)
Insert Into mai_tmp From Memvar
m.headerline=Space(5) + 'Report Prepared By: '
m.detailline=Space(35) + m.m_name
Insert Into mai_tmp From Memvar
m.headerline=Space(5) + 'Phone: '
phone_mask=left(m.m_phone,3)+'-'+substr(m.m_phone,4,3)+'-'+right(m.m_phone,4)
m.detailline=Space(35) + phone_mask
Insert Into mai_tmp From Memvar
m.headerline=Space(5) + 'E-mail Address: '
m.detailline=Space(35) + m.m_email
Insert Into mai_tmp From Memvar
 
*******************************************************************************************************
m.question='01'
m.headerline='1. Service or Activity:'
Select TRIM(descript), TRIM(servunit) From maiactiv Where code=m.activity Into Array aActivDsc
m.m_activdsc=aActivDsc(1)
Release aActivDsc
Select TRIM(servunit) From maiactiv Where code=m.activity Into Array aActivDsc
m.m_servunit=aActivDsc(1)
Release aActivDsc
m.detailline=Space(35) + m.m_activdsc
Insert Into mai_tmp From Memvar

*******************************************************************************************************
m.question='02'
m.detailline=''
m.headerline='2. Ethnic or Racial Community to receive this service:'
Insert Into mai_tmp From Memvar
m.headerline='     Asian'
IF m.ethnicrace='01'
	m.detailline='   x'
ELSE
	m.detailline=''	
ENDIF	
Insert Into mai_tmp From Memvar
m.headerline='     American Indian or Alaskan Native'
IF m.ethnicrace='02'
	m.detailline='   x'
ELSE
	m.detailline=''	
ENDIF	
Insert Into mai_tmp From Memvar
m.headerline='     Black or African American'
IF m.ethnicrace='03'
	m.detailline='   x'
ELSE
	m.detailline=''	
ENDIF	
Insert Into mai_tmp From Memvar
m.headerline='     Hispanic or Latino(a)'
IF m.ethnicrace='04'
	m.detailline='   x'
ELSE
	m.detailline=''	
ENDIF	
Insert Into mai_tmp From Memvar
m.headerline='     Native Hawaiian or Other Pacific Islander'
IF m.ethnicrace='05'
	m.detailline='   x'
ELSE
	m.detailline=''	
ENDIF	
Insert Into mai_tmp From Memvar
m.headerline='     More than one race'
IF m.ethnicrace='06'
	m.detailline='   x'
ELSE
	m.detailline=''	
ENDIF	
Insert Into mai_tmp From Memvar

*******************************************************************************************************
m.question='03'
m.detailline=''	
m.headerline='3. Planned Budget and Expenditures'+ Space(26) + 'Budgeted' + Space(10) + 'Spent'
Insert Into mai_tmp From Memvar
m.headerline=Space(60) + '--------' + Space(10) + '-----'
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='3a. Current FY MAI funds for this activity and client group:'+ Space(10) + TRAN(m.pl_funds,'$$$,$$9')
Insert Into mai_tmp From Memvar
m.detailline='3b. MAI Carryover for this activity and client group:'+ Space(17) + TRAN(m.carryfunds,'$$$,$$9')
Insert Into mai_tmp From Memvar
m.detailline='3c. Total MAI funds for this activity and client group:'+ Space(15) + TRAN(m.pl_funds+m.carryfunds,'$$$,$$9')+ Space(12) + TRAN(m.fundsspent,'$$$,$$9')
Insert Into mai_tmp From Memvar

*******************************************************************************************************
m.question='04'
m.headerline='4. Service Unit Name:'
m.detailline=SPACE(35)+m.m_servunit
Insert Into mai_tmp From Memvar
*******************************************************************************************************
m.question='05'
m.detailline=''
m.headerline='5. Record of Service Units Provided               Planned             Actual'
Insert Into mai_tmp From Memvar
m.headerline='                                                  -------             ------'
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline=Space(58)+ TRAN(m.plservunit,'999,999') + SPACE(14) + TRAN(m.totservs,'999,999')
Insert Into mai_tmp From Memvar

*******************************************************************************************************
m.question='06'
m.detailline=''
m.headerline='6. Record of Clients Served                       Planned             Actual'
Insert Into mai_tmp From Memvar
m.headerline='                                                  -------             ------'
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='6a. Total Unduplicated Number of Clients '+SPACE(17)+TRAN(m.plclients,'999,999')+SPACE(14)+TRAN(m.totcli,'999,999')
Insert Into mai_tmp From Memvar
m.detailline='6b. Total Unduplicated Number of Women   '+SPACE(17)+TRAN(m.plwomen,'999,999')+SPACE(14)+TRAN(m.totwomen,'999,999')
Insert Into mai_tmp From Memvar
m.detailline='6c. Total Unduplicated Number of Infants '+SPACE(17)+TRAN(m.plinfants,'999,999')+SPACE(14)+TRAN(m.totinfant,'999,999')
Insert Into mai_tmp From Memvar
m.detailline='6d. Total Unduplicated Number of Children'+SPACE(17)+TRAN(m.plchildren,'999,999')+SPACE(14)+TRAN(m.totchild,'999,999')
Insert Into mai_tmp From Memvar
m.detailline='6e. Total Unduplicated Number of Youth   '+SPACE(17)+TRAN(m.plyouth,'999,999')+SPACE(14)+TRAN(m.totyouth,'999,999')
Insert Into mai_tmp From Memvar

*******************************************************************************************************
m.question='07'
m.detailline=''
m.headerline='7. Planned Outcomes'
Insert Into mai_tmp From Memvar
m.headerline=REPLICATE('-',98)
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='Planned Outcome #1 and indicator(s):'
Insert Into mai_tmp From Memvar

If !Empty(m.ploutcom1)
   m.detailline=SPACE(5) + m.ploutcom1
   Insert Into mai_tmp From Memvar
Endif
m.detailline=''
m.headerline=REPLICATE('-',98)
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='Planned Outcome #2 and indicator(s):'
Insert Into mai_tmp From Memvar
If !Empty(m.ploutcom2)
   m.detailline=SPACE(5) + m.ploutcom2
   Insert Into mai_tmp From Memvar
Endif   
m.detailline=''
m.headerline=REPLICATE('-',98)
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='Planned Outcome #3 and indicator(s):'
Insert Into mai_tmp From Memvar
If !Empty(m.ploutcom3)
   m.detailline=SPACE(5) + m.ploutcom3
   Insert Into mai_tmp From Memvar
Endif  
 *******************************************************************************************************
m.question='08'
m.detailline=''
m.headerline='8. Documented Evidence of Outcomes Achieved in Current Fiscal Year'
Insert Into mai_tmp From Memvar
m.headerline=REPLICATE('-',98)
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='Narrative Description for Outcome #1:'
Insert Into mai_tmp From Memvar

If !Empty(m.actoutcom1)
   m.detailline=SPACE(5) + m.actoutcom1
   Insert Into mai_tmp From Memvar
   *m.detailline=''
   *Insert Into mai_tmp From Memvar
EndIf
   
m.pctoutcom1=IIF(m.totcli>0,(m.n_outcom1/m.totcli)*100,0)
m.detailline='-> Total Number and Percentage of Clients that Achieved Outcome #1:       '+TRAN(m.n_outcom1,'999,999')+SPACE(2)+TRAN(m.pctoutcom1,'99,999,999')+'%'  
Insert Into mai_tmp From Memvar
m.detailline=''
m.headerline=REPLICATE('-',98)
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='Narrative Description for Outcome #2:'
Insert Into mai_tmp From Memvar

If !Empty(m.actoutcom2)
   m.detailline=SPACE(5) + m.actoutcom2
   Insert Into mai_tmp From Memvar
  * m.detailline=''
  * Insert Into mai_tmp From Memvar
EndIf

m.pctoutcom2=IIF(m.totcli>0,(m.n_outcom2/m.totcli)*100,0)
m.detailline='-> Total Number and Percentage of Clients that Achieved Outcome #2:       '+TRAN(m.n_outcom2,'999,999')+SPACE(2)+TRAN(m.pctoutcom2,'99,999,999')+'%'
Insert Into mai_tmp From Memvar
m.detailline=''
m.headerline=REPLICATE('-',98)
Insert Into mai_tmp From Memvar
m.headerline=''
m.detailline='Narrative Description for Outcome #3:'
Insert Into mai_tmp From Memvar

If !Empty(m.actoutcom3)
   m.detailline=SPACE(5) + m.actoutcom3
   Insert Into mai_tmp From Memvar
  * m.detailline=''
  * Insert Into mai_tmp From Memvar
EndIf
   
m.pctoutcom3=IIF(m.totcli>0,(m.n_outcom3/m.totcli)*100,0)
m.detailline='-> Total Number and Percentage of Clients that Achieved Outcome #3:       '+TRAN(m.n_outcom3,'999,999')+SPACE(2)+TRAN(m.pctoutcom3,'99,999,999')+'%'
Insert Into mai_tmp From Memvar

RETURN

