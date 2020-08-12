Close data all
Close tables

Open Database ..\data\urs

Set Deleted On

Use ai_enc
Use ai_serv In 0

Select Count(ai_serv.service_id) As cnt1;
From ai_serv;
Join ai_enc On ai_serv.act_id =ai_enc.act_id;
Where ;
   ai_serv.service_Id=(832) And ;
   ai_enc.serv_Cat=("00002") And ;
   ai_enc.program=("EVAAP") And ;
   InList(ai_enc.enc_id,35,243) And;
   Between(ai_enc.act_dt,{01/01/2015},{03/14/2015}) And;
   !Empty(ai_enc.act_id) And;
   !Empty(ai_serv.act_id) ;
Into Array _aCount

? _aCount

*!* Update the date and time so that we can find the row if needed,
Update ai_serv ;
   Set dt=Date(), ;
   tm=Time(), ;
   user_id='_DSIx' ;
From ai_enc;
Where ;
   ai_serv.act_id =ai_enc.act_id And;
   ai_serv.service_Id=(832) And ;
   ai_enc.serv_Cat=("00002") And ;
   ai_enc.program=("EVAAP") And ;
   InList(ai_enc.enc_Id,35,243) And;
   Between(ai_enc.act_dt,{01/01/2015},{03/14/2015}) And;
   !Empty(ai_enc.act_id) And;
   !Empty(ai_serv.act_id)

? _Tally
*!* Delete the rows using the same query.
Delete From ai_serv ;
Where user_id='_DSIx' And dt=Date()

? _Tally