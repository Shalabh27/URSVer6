Close Databases all
Close Tables All

Open Database ..\data\urs
Use ai_enc
Use ai_serv In 0

cTime=Time()

cLog='Encounter & Service Deletion Support Ticket #61200'+Chr(13)+;
     'Run Date:'+Ttoc(Datetime())+Chr(13)
     
nClientCount=0
nEncountersFound=0
nServicesFound=0

Select act_id, tc_id;
From ai_enc; 
Where serv_cat='00001' And;
      program='KRAAX' And;
      Between(act_dt, {01/01/2017},{02/06/2018});
Into Cursor _curEnc ReadWrite
nEncountersFound=Alltrim(Transform(_Tally, '@r 9,999,999'))

Select DISTINCT tc_id From _curEnc Into Cursor _CurTcid
nClientCount=Alltrim(Transform(_Tally, '@r 9,999,999'))

Update ai_enc ;
   Set dt=Date(), ;
   tm=Time(), ;
   user_id='_NTST' ;
From _curEnc;
Where _curEnc.act_id=ai_enc.act_id

Delete From ai_enc Where dt=Date() And tm=cTime and user_id='_NTST'

Update ai_serv;
   Set dt=Date(), ;
   tm=Time(), ;
   user_id='_NTST' ;
From _curEnc;
Where _curEnc.act_id=ai_serv.act_id
nServicesFound=_Tally
  
Delete From ai_serv Where dt=Date() And tm=cTime and user_id='_NTST'
cLog=cLog+;
     'Clients Found:'+Alltrim(Transform(nClientCount, '@r 9,999,999'))+Chr(13)+;
     'Encounters removed:'+Alltrim(Transform(nEncountersFound, '@r 9,999,999'))+Chr(13)+;
     'Services removed:'+Alltrim(Transform(nServicesFound, '@r 9,999,999'))
     
Use in ai_enc
Use In ai_serv
Select _curEnc
Copy To EncServDeletedTicket61200.csv CSV
Use In _CurTcid
Use In _curEnc
=StrToFile(cLog,'EncServDeletedTicket61200.txt',0)













     