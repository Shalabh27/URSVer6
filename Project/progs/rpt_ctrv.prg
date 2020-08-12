* print Part C of form (Local Variables) 
*************************************************************************
** This program prints the CTR Part C form Local Variables 
** It requires the tc_id of the client selected in the intake screen
*************************************************************************
Parameter cTC_ID, tcCTR_ID
m.cTime = Time()
m.cDate = Date()

Local cAlias
cAlias=Select()
                       
***Form ID # **********************
Select lv_ai_ctr_filtered
Locate For ctr_id = tcCTR_ID
If !Found()
   oApp.msg2user('NOTFOUNDG')   
   Return
Endif

If Used('ctrv')
   Use In ctrv
Endif
   
Create Cursor ctrv (section C(100), partv C(30), groupv N(2), cDate D, cTime C(10))
***Client Information
Select cli_cur
Locate For tc_id = cTC_ID
                                               
m.section = ' FORM ID #: '  + Rtrim(lv_ai_ctr_filtered.form_description) + ;
            Space(5) + 'Client ID: '  + cli_cur.id_no

m.partv = 'Question 1 :'   
m.groupv = Iif(lv_ai_ctr_filtered.aptquest1= 1 , 0, lv_ai_ctr_filtered.aptquest1 - 1) 
Insert Into ctrv From memvar  

m.partv = 'Question 2 :'   
m.groupv = Iif(lv_ai_ctr_filtered.aptquest2= 1 , 0, lv_ai_ctr_filtered.aptquest2 - 1) 
Insert Into ctrv From memvar 

m.partv = 'Question 3 :'   
m.groupv = Iif(lv_ai_ctr_filtered.aptquest3= 1 , 0, lv_ai_ctr_filtered.aptquest3 - 1) 
Insert Into ctrv From memvar 

m.partv = 'Question 4 :'   
m.groupv = Iif(lv_ai_ctr_filtered.aptquest4= 1 , 0, lv_ai_ctr_filtered.aptquest4 - 1) 
Insert Into ctrv From memvar 

m.partv = 'Question 5 :'   
m.groupv = Iif(lv_ai_ctr_filtered.aptquest5= 1 , 0, lv_ai_ctr_filtered.aptquest5 - 1) 
Insert Into ctrv From memvar 

Select ctrv
Go top
Report Form rpt_ctrv To Printer Prompt Noconsole NODIALOG 
Return



