*!*  Support Ticket #60907
*!*  Date Range: 05/24/2017 to 10/17/2017
*!*  Program ID: G5ABB (PrEP Services – BHACS)
*!*  Staff ID: G5AEQ (Ramos, Jennifer)
*!*  Service Category: 00054 (PrEP/PEP Services)
*!*   
*!*  Encounter ID: 139 (Peer Services)
*!*  Activity Code: 1260 (Appointment Reminder)
*!*  Activity Code: 616 (Peer Group Meeting)
*!*  Activity Code: 1321 (Peer Referral Support)
*!*  Activity Code: 1298 (Peer Adherence Support)
*!*  Activity Code: 1320 (Insurance Navigation Support)
*!*   
*!*  Encounter ID: 312 (PrEP Services)
*!*  Activity Code: 1387 (PrEP Continuation Support)

Set Deleted On 

Close Databases
Close Tables
Open Data ..\data\urs

Use ai_enc Order Tag act_id
Use ai_serv In 0 Order tag serv_id
Use ai_ref In 0 Order Tag act_id

Select ai_enc.tc_id, ;
  ai_enc.act_id As act_id, ;
  Dtoc(ai_enc.act_dt) As act_dt, ;
  ai_serv.serv_id, ;
  ai_serv.service_id, ;
  Nvl(ai_ref.ref_id,Space(10)) As ref_id,;
  Space(150) As comments;
From ai_enc;
Join ai_serv On ai_enc.act_id=ai_serv.act_id;
Left Outer Join ai_ref On ai_enc.act_id=ai_ref.act_id;
Where (!Empty(ai_enc.act_id) And ;
       Between(ai_enc.act_dt,{05/24/2017},{10/17/2017}) And ;
       ai_enc.worker_id='G5AEQ' And ;
       ai_enc.enc_id=139 And ;
       ai_enc.serv_cat='00054' And ;
       ai_enc.program='G5ABB' And ;
       InList(ai_serv.service_id,616,1260,1298,1320,1321)) Or;
      (!Empty(ai_enc.act_id) And ;
       Between(ai_enc.act_dt,{05/24/2017},{10/17/2017}) And ;
       ai_enc.worker_id='G5AEQ' And ;
       ai_enc.enc_id=312 And ;
       ai_enc.serv_cat='00054' And ;
       ai_enc.program='G5ABB' And ;
       ai_serv.service_id=1387);
Into Cursor _curAIEnc Readwrite;
Order By 1,2,3

Select _curAIEnc
Go Top
Scan
  cServ_id=_curAIEnc.serv_id
  Select ai_serv
  =Seek(cServ_id)

  Replace user_id With '_DSIx', dt With Date(), tm With Time()
  Delete  
  
  Select _curAIEnc
  Replace comments With 'Service Deleted'
EndScan 

Set Order To act_id In ai_serv

Select DISTINCT act_id from _curAIEnc Into cursor _curAIEncRows Order by 1
Select _curAIEncRows
Go Top

Scan
   cAct_id=_curAIEncRows.act_id
   Dimension _aRefID(1)
   _aRefID[1]=''
   cMessageLine=''
   
   Select ai_serv
   If Seek(cAct_id)=(.t.)
      cMessageLine='; Encounter Not removed.'
   Else
      Select ai_enc
      Seek(cAct_id)
      Replace user_id With '_DSIx', dt WIth Date(), tm With Time()
      Delete
      cMessageLine='; Encouter was Removed.'
      Select DISTINCT ref_id From _curAIEnc Where act_id=cAct_id And !Empty(ref_id) Into Array _aRefID
   EndIf
   If !Empty(_aRefID[1])
      Select ai_ref
      For ix = 1 to Alen(_aRefID,1)
        If Seek(_aRefID[ix],'ai_ref','ref_id')
           Replace user_id With '_DSIx', dt WIth Date(), tm With Time()
           Delete
           cMessageLine=cMessageLine+'; Referral was Removed.'
        EndIf
      EndFor 
   EndIf 
   Update _curAIEnc Set comments=Alltrim(comments)+cMessageLine Where act_id=cAct_id
   Select _curAIEncRows
EndScan

Select _curAIEnc
Go top

Copy To enc_services_removed.csv CSV