Local lProceed 
lProceed = .t.

If Used('system')
   Select system
   Use

   Try
      Use system Exclusive
   Catch
      Use system Shared
      lProceed = .f.
      If oApp.msg2user('MSG_YESNO',;
                       'This operation requires exclusive use of the system.'+Chr(13)+;
                       'Please inform all users to exit the system.'+Chr(13)+;
                       'Would you like view the connection log?') = 1
         Select 0
         Use lv_loghist
         Set Filter to Ttod(login_date)=Date() And Empty(Nvl(logout_date,''))
         Go Top

         Do Form view_connections
         Use In lv_loghist
      EndIf
   EndTry
EndIf

If lProceed =(.f.)
   Return
EndIf

Use lv_incomplete_intakes In 0
If Reccount('lv_incomplete_intakes') = 0
   oApp.msg2user('MESSAGE','There are no incomplete intakes to be removed.')
   Use In lv_incomplete_intakes
   Return
   
EndIf

Create Cursor ;
   cur_inactive(is_selected l, ;
   cli_name C(55), ;
   id_no C(20), ;
   client_id C(10), ;
   date_entered D, ;
   dt D,;
   anonymous L, ;
   tc_id C(10))

Index On Iif(is_selected=(.t.),'0','1')+Upper(cli_name) Tag chosen
Index On Upper(cli_name) Tag cli_name Addit
Index On id_no Tag id_no Addit
Index On Dtos(date_entered) Tag dt_entered Addit
Index On Dtos(dt) Tag dt_last Addit

Select lv_incomplete_intakes

If oapp.gldataencrypted=(.f.)
   Insert Into cur_inactive ;
   Select .f., ;
         Padr(Alltrim(last_name)+', '+Alltrim(first_name), 55),;
         id_no,;
         client_id, ;
         entered,;
         dt, ;
         anonymous, ;
         tc_id ;
   From lv_incomplete_intakes
   
Else
   Set Message to 'Building List of Clients: 4) Decrypting client information...'    
   Select lv_incomplete_intakes
   Go Top
 
   Scan
      Scatter Name oIncomplets
      lcLastName=''
      lcFirstName=''
      
      Insert Into cur_inactive (is_selected, id_no, client_id, date_entered, dt, anonymous, tc_id) ;
         Values (.f., oIncomplets.id_no, oIncomplets.client_id, oIncomplets.entered, oIncomplets.dt, oIncomplets.anonymous, oIncomplets.tc_id)
      
      If !Empty(oIncomplets.last_name) And !IsNull(oIncomplets.last_name)
         lcEncryptedStream=oIncomplets.last_name
         lcLastName=osecurity.decipher(lcEncryptedStream)
         
      EndIf
      
      If !Empty(first_name) And !IsNull(first_name)
         lcEncryptedStream=oIncomplets.first_name
         lcFirstName=osecurity.decipher(lcEncryptedStream)
         
      EndIf
      Select cur_inactive
      Replace cli_name With Padr(Alltrim(lcLastName)+', '+Alltrim(lcFirstName), 55)
      
      Select lv_incomplete_intakes
   EndScan
EndIf

Select cur_inactive
Set Order To cli_name
Go Top

lnProcessed=.f.

Do Form remove_people_form To lnProcessed

Use In lv_incomplete_intakes
Use In system
Use In cur_inactive

Select 0
Use system Shared