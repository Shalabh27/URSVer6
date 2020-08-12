Procedure get_file
Parameters nType, cExt

***VT 04/02/2009 Dev Tick 4728
If Inlist(gcRptName ,'rpt_sum_survey', 'rpt_rsr_client_detail', 'rpt_client_prev','rpt_cli_prog','rpt_pems')  And (nType = 7 Or nType = 8)
   =Messagebox('PDF & Text print options are not available for this report.'+ Chr(13)+;
               'Please use other print options.',48,'Problem')
   Return
Endif

nOldArea=Select()
cOld_Default=Sys(05)+Sys(2003)

If nType = 9
   cFileName = ''
   oApp.rpt_print(5, .T., 9, gcRptName, 1, 2, cFileName, .T., 2)
Else
   If !Empty(oApp.gcrpt_save_folder)
      *** VT 08/22/2008 DEv Tick 4599
      lDir = Directory(oApp.gcrpt_save_folder)

      If lDir = .T.
         Set Default To Rtrim(oApp.gcrpt_save_folder)
      Else
         cDirectoty = Getdir()
         Set Default To Rtrim(cDirectoty)
      Endif
      **VT End
   Endif

   cFileName = Getfile(cExt, '', '', 0, 'Save As')

   If !Empty(cFileName)
      Set Default To (cOld_Default)
      Select (nOldArea)
      oApp.rpt_print(5, .T., nType, gcRptName, 1, 2, cFileName, .T., 2)

      ***VT 09/05/2007
      If !Used("rpt_save")
         =OpenFile("rpt_save")
      Endif

      Select rpt_save
      Append Blank
      Replace user_id With gcstaff_id, ;
         date_saved With  Datetime(), ;
         file_saved With cFileName, ;
         file_type  With Upper(cExt),;
         ws_network_id With Id()

      Select (nOldArea)
   Else
      Set Default To (cOld_Default)
      Select (nOldArea)
   Endif
Endif

Endproc
