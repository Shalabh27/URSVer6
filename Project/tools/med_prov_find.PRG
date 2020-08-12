* Open Database ?

Close Tables All

=dbcOpenTable('insstat','prov_id')
=dbcOpenTable('med_prov','name')
=dbcOpenTable('system')

cAgencyPrefex=system.system_id

Select Count(name) As name_count, name From med_prov Group By name Order By 1 Desc Into Cursor _curMedProvGroups

Select _curMedProvGroups
Locate For name_count <> (2)

If Found()
  Wait WINDOW 'Non-duplicated Providers found'
  Return
EndIf

Select prov_id, name, Space(05) As prov_id2 From med_prov where Left(prov_id,2)=cAgencyPrefex Order by name Into Cursor _curMEDProvNew ReadWrite

Select med_prov
Set Filter To Left(prov_id,2) <> cAgencyPrefex

Select _curMEDProvNew
Go Top

Scan 
   cName=name
   If Seek(cname,'med_prov')
      cOldProvID=med_prov.prov_id
      Replace prov_id2 With cOldProvID
   EndIf 
EndScan 

Set Deleted Off

Go Top In insstat
Select _curMEDProvNew
Go Top

Update insstat ;
 Set user_id='_MERG',;
     dt=Date(),;
     tm='00:00',;
     insstat.prov_id=_curMEDProvNew.prov_id2;
FRom _curMEDProvNew ;
Where insstat.prov_id=_curMEDProvNew.prov_id

? _Tally