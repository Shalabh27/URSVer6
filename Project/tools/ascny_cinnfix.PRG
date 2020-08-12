Clear

Open Database ..\data\urs
Use claim_hd In 0
Use claimcinn In 0
Update claim_hd ;
   From claimcinn ;
   Set claim_hd.cinn=claimcinn.cinn ;
   Where claim_hd.invoice=claimcinn.invoice

? _Tally