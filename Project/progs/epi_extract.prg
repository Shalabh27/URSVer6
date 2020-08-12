Parameters lcLog_id, lcMode

cDummy =' '

Select epi_crosswalk
Set Filter To !Empty(airs_name)
Go Top

*!* - Get the Agency Information
Select agency
Go Top
Scatter Name oAgencyInfo Addit

Set Message To 'EPI Extract'

Select ;
  ai_ctr.tc_id,;
  ai_ctr.risk_id,;
  ctr_test.ctrtest_id,;
  ctr_test.ctr_id,;
  ctr_test.act_id,;
  ctr_test.test_number, ;
  Padl(Strtran(Dtoc(ctr_test.sample_dt),'/',''),8,'0') As sample_dt,;
  ctr_test.sample_dt As dsample_dt, ;
  ctr_test.result,;
  ctr_test.resltprov,;
  Padl(Strtran(Dtoc(ctr_test.result_dt),'/',''),8,'0') As result_dt,;
  ctr_test.result_dt As dresult_dt,;
  0 As prev_d_diag,;
  Space(08) As prev_d_diag_dt,;
  ctr_test.dt;
From ctr_test;
Join ai_ctr On ctr_test.ctr_id=ai_ctr.ctr_id;
Where ctr_test.test_number=2;
  And ctr_test.result=1;
Into Cursor _curCTRClients ReadWrite;
Order by 1,6 Desc

*!* - Populate a cursors of rows we want to use.
Select ;
  ai_clien.tc_id,;
  ai_clien.urn_no,;
  client.client_id,;
  client.first_name,;
  client.last_name,;
  client.mi,;
  Padl(Strtran(Dtoc(client.dob),'/',''),8,'0') As dob,;
  client.dob As ddob,;
  client.phhome,;
  ai_clien.id_no,;
  client.ssn,;
  ICase(client.hispanic=0,'09',client.hispanic=1,'01','02') As hispanic,;
  ICase(client.gender='10','F',client.gender='11','M',client.gender='12','X',client.gender='13','Y','U') As gender,;
  Transform(client.indialaska,'9') As indialaska,;
  Transform(client.blafrican,'9') As blafrican,;
  Transform(client.asian,'9') As asian,;
  Transform(client.hawaisland,'9') As hawaisland,;
  Transform(client.white,'9') As white,;
  Iif(client.indialaska+client.blafrican+client.asian+client.hawaisland+client.white+client.someother > 1, 1,0) As race_multiple,;
  Transform(client.someother,'9') As someother,;
  '0' As race_unknown,;
  ai_clien.citizen,;
  ai_clien.other_cit;
From client;
Join ai_clien on client.client_id=ai_clien.client_id;
Left Outer Join gender On client.gender=gender.code;
Where ai_clien.tc_id In (Select Dist tc_id From _curCTRClients);
Order By tc_id;
Into Cursor _curClientList ReadWrite

*!* Decrypt the PHI fields
Select _curClientList
Go Top

If oapp.gldataencrypted=(.t.)
   Set Message to 'Building List of Clients: Decrypting client information...'
   Scan

      If !Empty(last_name) And !IsNull(last_name)
         lcDecryptedStream=''
*         lcEncryptedStream=Alltrim(last_name)
         lcEncryptedStream=last_name
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace last_name With lcDecryptedStream
      EndIf
      
      If !Empty(first_name) And !IsNull(first_name)
         lcDecryptedStream=''
*         lcEncryptedStream=Alltrim(first_name)
         lcEncryptedStream=first_name
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace first_name With lcDecryptedStream
      EndIf

      If !Empty(ssn) And !IsNull(ssn)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(ssn)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace ssn With lcDecryptedStream
      EndIf

      If !Empty(phhome) And !IsNull(phhome)
         lcDecryptedStream=''
         lcEncryptedStream=Alltrim(phhome)
         lcDecryptedStream=osecurity.decipher(lcEncryptedStream)

         Replace phhome With lcDecryptedStream
      EndIf

   EndScan
   Go Top
Endif

Set Message To 'EPI Extract'

Select epi_data
Scatter Name oEPIData Blank Addit

Select _curClientList
Index On tc_id Tag tc_id
Scatter Name oClientList Blank Addit

Select _curCTRClients
Scatter Name oCTRClients Blank Addit
Go Top

Scan
  Select _curCTRClients
  Scatter Name oCTRClients Addit
  
  Select epi_data
  Scatter Name oEPIData Blank Addit
  
  Select address
  Scatter Name oAddressInfo Blank Addit
  
  Select relhist
  Scatter Name oRelhist Blank Addit
  
  Select ctr_partd
  Scatter Name oCTRPartD Blank Addit
  
  Scatter Name oCTRClients Addit
  cTC_IDHold=oCTRClients.tc_id
  If Seek(oCTRClients.tc_id,'_curClientList','tc_id')
     Select _curClientList
     Scatter Name oClientList Addit
     
     Select address
     If Seek(oClientList.client_id,'address','client_id')
        Scatter Name oAddressInfo Addit
        If oapp.gldataencrypted=(.t.)
           If !Empty(oAddressInfo.street1) And !IsNull(oAddressInfo.street1)
              lcDecryptedStream=''
              lcEncryptedStream=Alltrim(oAddressInfo.street1)
              lcDecryptedStream=osecurity.decipher(lcEncryptedStream)
              oAddressInfo.street1=lcDecryptedStream

           EndIf
        EndIf 
     EndIf 
     
     Select relhist
     If Seek(oCTRClients.risk_id,'relhist','risk_id')
        Scatter Name oRelhist Addit

     Endif
     
     Select ctr_partd
     If Seek(oCTRClients.ctrtest_id,'ctr_partd','ctrtest_id')
        Scatter Name oCTRPartD

     EndIf
     
     cString2write=''
     Select epi_crosswalk
     Go Top
     Scan
        If custom=(.f.)
           Store Evaluate(Alltrim(airs_name)) To (epi_name)
        EndIf
        
        If custom=(.t.) And !Empty(custom_method)
           cCustomProc = '='+Alltrim(custom_method)+Alltrim(method_parms)+')'
           ExecScript(cCustomProc)
        EndIf 
        
     EndScan 
     Insert Into epi_data From Name oEPIData
  EndIf 

  
EndScan 

Use In _curClientList
Use In _curCTRClients

Release oEPIData, oClientList, oCTRClients, oEPIData, oAddressInfo, oRelhist, oCTRPartD, oAgencyInfo

Return
*-

Function determineotherrisk (clMethod_parms)
cReturnVal='UN'
Do Case
   Case oRelhist.mrefusedet=1 Or oRelhist.frefusedet=1 Or oRelhist.trefusedet=1
      cReturnVal='UN'
      
   Case oRelhist.Idunew=1 Or oRelhist.Sharedequipt=1 Or oRelhist.hemocoag=1 Or ;
        oRelhist.rectrans=1 Or oRelhist.otherrisk=1 Or oRelhist.recentstd=1 Or ;
        oRelhist.incarcerat=1 Or oRelhist.sexworker=1 Or oRelhist.mexsexdrug=1 Or ;
        oRelhist.fexsexdrug=1 Or oRelhist.texsexdrug=1 Or oRelhist.mwhilehigh=1 Or ;
        oRelhist.fwhilehigh=1 Or oRelhist.twhilehigh=1 Or oRelhist.mwithhivu=1 Or ;
        oRelhist.fwithhivu=1 Or oRelhist.twithhivu=1 Or oRelhist.mwithexsex=1 Or ;
        oRelhist.fwithexsex=1 Or oRelhist.twithexsex=1 Or oRelhist.mwithanon=1 Or ;
        oRelhist.fwithanon=1 Or oRelhist.twithanon=1 Or oRelhist.withmsm=1
      cReturnVal='Y'
      
   Otherwise
      cReturnVal='N'
      
EndCase 

Store cReturnVal to &clMethod_parms

Return cReturnVal
EndFunc 
*

Function determineprevill (clPrev_i_ill, clprev_i_diag_dt)
cReturnVal1='0'
cReturnVal2=Space(08)

*!* i_ll='No' (0)
If oEPIData.i_ill='0'
   Select Top 1 effect_dt From hivstat where tc_id=oEPIData.tc_id And hivstatus In ('01','02','05') Order By effect_dt Into Array _aHIVStat
   If _Tally > 0
      cReturnVal1='1'
      cReturnVal2=Padl(Strtran(Dtoc(_aHIVStat[1]),'/',''),8,'0')
   EndIf 
EndIf 

Store cReturnVal1 To &clPrev_i_ill
Store cReturnVal2 To &clprev_i_diag_dt

Return cReturnVal1
EndFunc 
*

Function determineprevdiag (clPrev_i_ill, clprev_i_diag_dt)
cReturnVal1='0'
cReturnVal2=Space(08)

*!* i_ll='No' (0)
If oEPIData.i_ill='0'
   Select Top 1 effect_dt From hivstat where tc_id=oEPIData.tc_id And hivstatus='10' Order By effect_dt Into Array _aHIVStat
   If _Tally > 0
      cReturnVal1='1'
      cReturnVal2=Padl(Strtran(Dtoc(_aHIVStat[1]),'/',''),8,'0')
   EndIf 
EndIf 

Store cReturnVal1 To &clPrev_i_ill
Store cReturnVal2 To &clprev_i_diag_dt

Return cReturnVal1
EndFunc
*

Function determinenumberpartners (clNum_partners, clact_id)
cReturnVal=0
If !Empty(clact_id)
   If Seek(clact_id,'ai_enc','act_id')

   EndIf 
EndIf 

Store cReturnVal To &clnum_partners
Return cReturnVal

*

Function determine1st_hiv_ever (dlfposmmyyyy, dllnegmmyyyy, dt_fst_hiv_ever, ctc_id)
cReturnVal=0
Dimension aHIVDate(1)
aHIVDate[1]={}

Select Min(hiv_date) From hivstat where tc_id=ctc_id And hivstatus='01' Into Array aHIVDate

If Empty(aHIVDate[1])
   aHIVDate[1]={12/31/2100}
EndIf 

If Empty(dlfposmmyyyy)
   dlfposmmyyyy={12/31/2100}
Else
   dlfposmmyyyy=Ctod(Left(dlfposmmyyyy,2)+'/01/'+Right(dlfposmmyyyy,4))   
EndIf 

If Empty(aHIVDate[1])
   dllnegmmyyyy={12/31/2100}
Else
   dllnegmmyyyy=Ctod(Left(dllnegmmyyyy,2)+'/01/'+Right(dllnegmmyyyy,4))   
EndIf 

dDateTemp=Min(dlfposmmyyyy, dllnegmmyyyy,aHIVDate[1])

If dDateTemp<>{12/31/2100}
   cReturnVal=Padl(Strtran(Dtoc(dDateTemp),'/',''),8,'0')
Else
   cReturnVal=Space(08)
EndIf 

Store cReturnVal To &dt_fst_hiv_ever
Return cReturnVal