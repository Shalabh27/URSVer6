Select ;
   vn_header.tc_id, ;
   vn_header.table_category, ;
   vn_header.client_id, ;
   vn_header.table_id, ;
   vn_details.verified_datetime;
From vn_header ;
Join vn_details On ;
     vn_header.vn_header_id=vn_details.vn_header_id ;
Where Year(Ttod(vn_details.verified_datetime))=Year(Date());
Order by 1, 2, 5 Desc;
Into Cursor _curVN Readwrite

Index On client_id+table_category Tag client_id
Index On tc_id+table_category Tag tc_id



*Finance
Select ;
   ai_fin.fin_id, ;
   ai_fin.tc_id, ;
   ai_fin.ass_dt, ;
   ai_fin.is_refus,;
   ai_fin.hshld_incm,;
   ai_fin.hshld_size,;
   00000000 As pov_level, ;
   Iif(IsNull(pov_level),.t.,.f.) As pov_level_is_null,;
   0000 As pov_cat;
From ai_fin ;
Where ai_fin.hshld_size > (0) And Year(ai_fin.ass_dt)=Year(Date());
Union;
Select ;
   ai_fin.fin_id, ;
   ai_fin.tc_id, ;
   Ttod(_curVn.verified_datetime) As ass_dt,;
   ai_fin.is_refus,;
   ai_fin.hshld_incm,;
   ai_fin.hshld_size,;
   00000000 As pov_level, ;
   Iif(IsNull(pov_level),.t.,.f.) As pov_level_is_null,;
   0000 As pov_cat;
From ai_fin ;
Left Outer Join _curVn On ;
   ai_fin.fin_id=_curVN.table_id And ;
   ai_fin.tc_id =_curVN.tc_id ;
Where ai_fin.hshld_size > (0) And;
      _curVN.table_category=('G') And;
      Year(ai_fin.ass_dt) < Year(Date()) And;
      Year(Ttod(_curVn.verified_datetime))=Year(Date());
Order by 2, 3 Desc;
Into Cursor _curFinancial_vn ReadWrite
Index On tc_id+Dtos(ai_fin.ass_dt) DESCENDING Tag tc_id
Set Order To 

Set Step On 
 

Select _curFinancial_vn
Go Top
Scan 
   If Tc_Id='EV00011993'
      Suspend
   EndIf 
   vpov_level=Iif(pov_level_is_null=(.t.),.Null.,0)
   npov_cat=0
   npov_cat2=2
   =dbcCalculatePovertyLevels(_curFinancial_vn.is_refus, _curFinancial_vn.hshld_size, _curFinancial_vn.hshld_incm, _curFinancial_vn.ass_dt, 'NY', @vpov_level, @npov_cat, @npov_cat2)
   Replace pov_level With Nvl(vpov_level,0), pov_cat With Nvl(npov_cat2,0)
EndScan
