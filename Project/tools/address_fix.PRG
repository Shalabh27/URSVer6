*!*   We're going to drop cli_hous and the livesin flag.
*!*   The lives_with indicator (N,3) will be reatined and used for information
*!*   about the primary residence of the collateral
Clear All

Use ai_clien In 0 Order tc_id

Use address In 0
Use cli_hous In 0
Use ai_famil In 0

Select address
Replace all client_id With ''

* These are 'clients' with intakes and their own addresses
Select a.tc_id, ;
       a.client_id, ;
       c.addr_id, ;
       b.hshld_id ;
From ai_clien a ;
Join cli_hous b On a.client_id=b.client_id ;
Join address c On b.hshld_id=c.hshld_id ;
Where b.lives_in=(.t.) ;
Order by 2 Into Cursor xxx

Update address ;
Set client_id = xxx.client_id ;
From xxx  ;
Where xxx.hshld_id=address.hshld_id

* Get the addresses of collaterals who live on their own
Select client_id, ;
       hshld_id ;
From cli_hous;
Where lives_in=(.t.) And;
      client_id Not In (Select client_id from address) ;
Into Cursor yyy

Update address ;
Set client_id = yyy.client_id ;
From yyy  ;
Where yyy.hshld_id=address.hshld_id And Empty(address.client_id)

Select ai_famil
Update ai_famil Set liveswith=Iif(wherelives=1,.t.,.f.)

* Everyone else are people who live with the client
