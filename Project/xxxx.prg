clProg_id='FWAEI'
llSetRequired=.f.
ldEncounterDate={09/01/2018}

Select prog2sc_id, prog_id From prog2sc ;
Where prog_id=(clProg_id) And;
      serv_cat=('00058') And;
Between(ldEncounterDate,prog2sc.effective_dt, Iif(Empty(prog2sc.end_dt),{12/31/2100}, prog2sc.end_dt));
Into cursor _curProg2sc

Select;
   0 As is_selected,;
   ai_contract.conno,;
   ai_contract.ai_contract_id,;
   _curProg2sc.prog2sc_id,;
   pems2urs.model_id,;
   pems2urs.intervention_id,;
   pems2urs.enc_id,;
   pems2urs.service_id,;
   serv_list.description,;
   Space(10) As serv_id,;
   Iif(llSetRequired=(.f.),0,hub_service_mask.required) As is_required,;
   0 As was_selected,;
   hub_service_mask.display_order;
From ai_contract;
Join pems2urs On pems2urs.contract_id=ai_contract.ai_contract_id ;
Join hub_service_mask On pems2urs.enc_id=hub_service_mask.enc_id ;
Join serv_list On serv_list.service_id= hub_service_mask.service_id ;
Join _curProg2sc On _curProg2sc.prog_id=pems2urs.prog_id;
Where Between(ldEncounterDate,ai_contract.start_date,ai_contract.end_date) And;
      pems2urs.is_active=(1) And;
      pems2urs.service_id=hub_service_mask.service_id And;
      pems2urs.serv_cat=('00058') And ;
      hub_service_mask.display_order <> (0) ;
Order By 13
Use In _curProg2sc

*!*   clProg_id='FWAEI'
*!*   llSetRequired=.f.
*!*   ldEncounterDate={09/01/2018}

*!*   Select Dist;
*!*      0 As is_selected,;
*!*      ai_contract.conno,;
*!*      ai_contract.ai_contract_id,;
*!*      prog2sc.prog2sc_id,;
*!*      pems2urs.model_id,;
*!*      pems2urs.intervention_id,;
*!*      pems2urs.enc_id,;
*!*      pems2urs.service_id,;
*!*      serv_list.description,;
*!*      Space(10) As serv_id,;
*!*      Iif(llSetRequired=(.f.),0,hub_service_mask.required) As is_required,;
*!*      0 As was_selected;
*!*   From ai_contract;
*!*   Join pems2urs On pems2urs.contract_id=ai_contract.ai_contract_id ;
*!*   Join prog2sc On prog2sc.prog_id+prog2sc.serv_cat=pems2urs.prog_id+'00058';
*!*   Join serv_list On serv_list.service_id=pems2urs.service_id ;
*!*   Join hub_service_mask On pems2urs.enc_id=hub_service_mask.enc_id ;
*!*   Where Between(ldEncounterDate,ai_contract.start_date, ai_contract.end_date) And;
*!*         pems2urs.is_active=(1) And;
*!*         pems2urs.service_id=hub_service_mask.service_id And;
*!*         hub_service_mask.display_order <> (0);
*!*   Order By hub_service_mask.display_order

*!*   *      pems2urs.serv_cat==('00058') And ;
*!*   *!*         Between(ldEncounterDate,ai_contract.start_date,ai_contract.end_date) And;
*!*   *!*         Between(ldEncounterDate,prog2sc.effective_dt, Iif(Empty(prog2sc.end_dt),{12/31/2100}, prog2sc.end_dt)) And;
