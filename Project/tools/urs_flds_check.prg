Clear 
Close Databases

Open Database i:\ursver6\data\urs
Use urs_flds

Select Dist dbf_file, extr_code From urs_flds Order by 2 Into Cursor ursfiles

*!* Check that the fields are not misspelled
?'------------------------------------'
?'URS_FLDS Level Check'

Select ursfiles
Go Top
Scan
   m.extr_code=extr_code
   m.urstable=Alltrim(dbf_file)
   If Indbc(m.urstable,"TABLE")=(.t.)
      Use (m.urstable) In 0
      Select field_name From urs_flds Where extr_code=m.extr_code Order by order Into cursor tblStru

      Select tblStru
      Scan 
         If Fsize(Alltrim(tblStru.field_name),m.urstable)=0
            ? m.urstable+': '+tblStru.field_name
         Endif
      EndScan
      Use In (m.urstable)
      Select ursfiles
   EndIf 
EndScan

?'------------------------------------'
?'Field Level Check'

*!* Look for missing fields 
Select ursfiles
Go Top
Scan
   m.extr_code=extr_code
   m.urstable=Alltrim(dbf_file)
   If Indbc(m.urstable,"TABLE")=(.t.)
      Select 0
      Use (m.urstable)
      ntimes=AFields(aStru)
      Use

      Select urs_flds
      Set Order To TABLEFIELD
      
      For i=1 to ntimes
         Locate for dbf_file=m.urstable And field_name = astru[1,1]
         If !Found()
            ? m.urstable+': '+ astru[1,1]
         Endif
      
      EndFor 
      Select ursfiles
   EndIf 
EndScan 