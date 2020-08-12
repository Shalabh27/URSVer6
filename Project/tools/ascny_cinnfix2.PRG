Clear All


Select 0
Use c:\4peter\claimcinn

Use claim_hd In 0
Use claim_dt In 0
Use insstat In 0

Select claim_hd.client_id, ;
   claim_hd.prov_id, ;
   claim_hd.invoice, ;
   claim_hd.cinn, ;
   claim_dt.date ;
From claim_hd ;
Join claim_dt On claim_hd.invoice=claim_dt.invoice ;
Where claim_hd.dt={04/07/2015} ;
Order By claim_hd.invoice ;
Into Cursor _cur0407 ReadWrite

Dimension _adate(1)
_adate[1]=''

Select _cur0407
Go TOp
Scan
    dlEffectDt=date
    m.client_id=client_id
    m.prov_id=prov_id
    _adate[1]='NotFound'
    
    Select Top 1 pol_num ;
    From insstat ;
    Where prim_sec=(1) And ;
          client_id=m.client_id And ;
          prov_id=m.prov_id And ;
          effect_dt <= dlEffectDt ;
    Order By effect_dt Desc ;
    Into array _adate
    
    If _Tally=0
       Select Top 1 pol_num ;
       From insstat ;
       Where prim_sec=(1) And ;
             client_id=m.client_id And ;
             effect_dt <= dlEffectDt ;
       Order By effect_dt Desc ;
       Into array _adate
   EndIf     
    
    Replace cinn With _adate[1]
EndScan

