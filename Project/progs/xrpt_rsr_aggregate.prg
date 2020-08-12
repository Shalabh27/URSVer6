Parameters ;
   lprev, ;        && Preview
   aselvar1, ;     && select parameters from selection list
   norder, ;       && order by
   nGroup, ;       && report selection  
   lctitle, ;      && report selection
   ddate_from , ;  && from date
   ddate_to, ;     && to date
   crit , ;        && name of param
   lnstat, ;       && selection(Output)  page 2
   corderby        && order by description

oApp.vGenprop=crit

If Used('_curClientDemog')
   Use In _curClientDemog
EndIf 

Acopy(aselvar1, aselvar2)
ctc_id = ""
cfundtypeselected = ""
For i = 1 To Alen(aselvar2, 1)
   If Rtrim(aselvar2(i, 1)) = "CTC_ID"
      ctc_id = aselvar2(i, 2)
   Endif
   If Rtrim(aselvar2(i, 1)) = "CFUNDTYPE"
      cfundtypeselected = aselvar2(i, 2)
   Endif
Endfor

oApp.vgenprop=''
oRSRMethods=Newobject('_rsr','rsr')
oRSRMethods.create_period_cursor(.F.,.F.,.F.)
If Reccount('curqh') = 1
   Select curqh
   Replace is_selected With .t.
Else
   onewrsrform=Newobject('rsr_starting','rsr',.Null.,.T.)
   onewrsrform.center_form_on_top()
   onewrsrform.Show()
EndIf

Select curqh
Go Top
Locate For is_selected =(.T.)
If Found()
   curqh_qh_id=curqh.qh_id
   curqh_q_begin=curqh.q_begin
   curqh_h_end=curqh.h_end
   m.curqh_note=curqh.Note
Else
   Use In curqh
   Return
Endif

With oRSRMethods
 .dstart=curqh_q_begin
 .dend=curqh_h_end
 .qh_id=curqh_qh_id
 .cfundingtype=''
 .lFromDetailReport=.t.
 .lFromAggregateReport=.t.
 .cDetailReportTC_ID=''

 If .test_service_definitions()=(-1)
    Return
 Endif
EndWith 

nReturnCD=oRSRMethods.doExtract()


If nReturnCD > 0
   oWait.lbl_message.caption='Creating Detail Report...'
   oWait.Show()
   oWait.Refresh()
   
   Set Seconds Off
   oApp.cltime=Ttoc(Datetime(),2)
   Set Seconds On

   =dbcOpenTable('rsr_description','q_number')
   =dbcOpenTable('racedet', 'rsr_subgrp')
   =dbcOpenTable('lv_rsr_services')

   Select curservpool
   Go Top

   Do create_work_table

   Select _curClientDemog
   Go Top

   Scan
      m.cRaceNote=''
      m.q68_subgroup=''
      m.q6White=0
      m.q6Black=0
      m.q6Asian=0
      m.q6Asian_subgroup=''
      m.q6AmIndian=0
      m.q6Hawaiian=0
      m.q6Hawaiian_subgroup=''
      m.q8_descript=''
      
      m.q2_descript=findanswer(2,_curClientDemog.q2)
      m.q5_subgroup=findanswer(5,_curClientDemog.q5)
      m.q7_descript=findanswer(7,_curClientDemog.q7)
      m.q71_descript=findanswer(71,_curClientDemog.q71)
      
      If _curClientDemog.q7=(6) Or _curClientDemog.q7=(7)
         m.q8_descript=findanswer(8,_curClientDemog.q8)
      EndIf 
      
      m.q9_descript=findanswer(9,_curClientDemog.q9)
      m.q10_descript=findanswer(10,_curClientDemog.q10)
      m.q12_descript=findanswer(12,_curClientDemog.q12)

      =findRace2(_curClientDemog.tc_id,_curClientDemog.q5,_curClientDemog.q68)
      i=0
      m.q14=''
      Dimension _aRisks(1)
      _aRisks[1]=0
      
      Select hivriskfct From hivriskfactor Where tc_id=_curClientDemog.TC_ID And IsNull(hivriskfct)=(.f.) Order by 1 Into Array _aRisks
      
      If _Tally > 0 And _aRisks[1] <> 0
         For i = 1 To Alen(_aRisks,1)
            If Seek(_aRisks[i],'rw_risk','rsr_risk')
               m.q14=m.q14+Alltrim(rw_risk.rsr_risk_description)+Chr(13)
            EndIf 
         EndFor 
      Else
         m.q14='No Information Found'
      EndIf 
      
*!*         Do Case
*!*            Case _Tally = 1
*!*               m.q14=findanswer(14,_aRisks[1])
*!*         
*!*            Case _Tally > 1
*!*               For i = 1 to Alen(_aRisks,1)
*!*                  m.q14=m.q14+findanswer(14,_aRisks[i])+Chr(13)
*!*                  
*!*               EndFor

*!*            Otherwise 
*!*               m.q14='No Information Found'

*!*         EndCase 

      m.q15=''
      Dimension _aInsurance(1)
      _aInsurance[1]=99
      
      Select medicalins From medicalinsurance Where tc_id=_curClientDemog.TC_ID And IsNull(medicalins)=(.f.) Order by 1 Into Array _aInsurance
      Do Case
         Case _Tally = 1
            m.q15=findanswer(15,_aInsurance[1])
      
         Case _Tally > 1
            For i = 1 to Alen(_aInsurance,1)
               m.q15=m.q15+findanswer(15,_aInsurance[i])+Chr(13)
               
            EndFor

         Otherwise 
            m.q15='No Information Found'

      EndCase 
      m.q16=0
      m.q17=0
      m.q18=0
      m.q19=0
      m.q20=0
      m.q21=0
      m.q22=0
      m.q23=0
      m.q24=0
      m.q25=0
      m.q26=0
      m.q27=0
      m.q28=0
      m.q29=0
      m.q30=0
      m.q31=0
      m.q32=0
      m.q33=0
      m.q34=0
      m.q35=0
      m.q36=0
      m.q37=0
      m.q38=0
      m.q39=0
      m.q40=0
      m.q41=0
      m.q42=0
      m.q43=0
      m.q44=0
      m.q45=0

      m.q48=''
      m.q49=''
      m.q50=''
      
      =PopulateServices(_curClientDemog.TC_ID)
      If _curClientDemog.is_medical=(.t.)
         m.q48=Populate48(_curClientDemog.TC_ID)
         m.q49=Populate49(_curClientDemog.TC_ID)
         m.q50=Populate50(_curClientDemog.TC_ID)
      EndIf 
      
      Select _curClientDemog
      Gather memvar 
   EndScan 

   Select _curClientDemog
   Go Top

   If Reccount() > 1
      Do Case 
         Case norder=(1)
            Index on Upper(last_name)+Upper(first_name) Tag lfname
            Set Order To lfname
            
         Case norder=(2)
            Index On Upper(id_no) Tag id_no
            Set Order To id_no
            
      EndCase 
   EndIf 
   
   If nGroup <> (1)
      oWait.lbl_message.caption='Copying Tables...'
      Go Top
      Replace All q15 With Strtran(q15,Chr(13),';  ',1,99)
      Copy To rsr_extracts\rsr_client_details.csv CSV 
      
      Go Top
      Replace All q15 With Strtran(q15,';  ',Chr(13),1,99)
      Go Top 
      
      oApp.msg2user("IMPORTANT",'The RSR Client Detail CSV export was copied to...'+Chr(13)+;
                                'rsr_extracts\rsr_client_details.csv'+Chr(13)+' ')
   EndIf 
   
   **! Print the report
   oWait.Hide()

   Do Case
      Case lprev=(.F.) And nGroup <> (3)
         Do Case 
            Case lnstat=(1)
               Report Form rpt_rsr_client_detail1_2014.frx To Printer Prompt Noconsole Nodialog
            Case lnstat=(2)
               Report Form rpt_rsr_client_detail2_2014.frx To Printer Prompt Noconsole Nodialog
            Case lnstat=(3)
               Report Form rpt_rsr_client_detail_2014.frx To Printer Prompt Noconsole Nodialog
         EndCase 

      Case lprev=(.T.) And nGroup <> (3)
         OldCanSaveReport=oApp.glcan_save_reports
*        oApp.glcan_save_reports=.f.

         Do Case 
            Case lnstat=(1)
               oapp.rpt_print(5, .T., 1, 'rpt_rsr_client_detail1_2014', 1, 2)
            Case lnstat=(2)
               oapp.rpt_print(5, .T., 1, 'rpt_rsr_client_detail2_2014', 1, 2)
            Case lnstat=(3)
               oapp.rpt_print(5, .T., 1, 'rpt_rsr_client_detail_2014', 1, 2)
         EndCase 

   EndCase
   
*   Use In _curClientDemog
Else
   If nReturnCD<>(-2)
      oapp.msg2user('NOTFOUNDG')
   EndIf
   
EndIf
oRSRMethods.cleanupFromDetailReport()
Return
*

Function findAnswer (nrsr_question, nrsr_code)
cReturnValue=''

Select rsr_description
Locate For Question_number=nrsr_question and rsr_code=nrsr_code
If Found()
   cReturnValue=Alltrim(rsr_description.description)
Else
   cReturnValue='No Information Found'
EndIf 

Select _curClientDemog
Return cReturnValue
*

Function findRace2
Parameters cltc_id, nEthnic, nEthnicSubGroup

 m.q68_subgroup=''
 m.cRaceNote=''
 m.q6White=0
 m.q6Black=0
 m.q6Asian=0
 m.q6Asian_subgroup=''        
 m.q6AmIndian=0
 m.q6Hawaiian=0
 m.q6Hawaiian_subgroup=''

 Select raceid, subgroup ;
 From race1 ;
 Where tc_id=cltc_id ;
 Order by 1 Into Array _aRace

 If _Tally > 0
   For i = 1 To Alen(_aRace,1)
      Do Case
        Case _aRace[i,1]=1
           m.q6White=1
           
        Case _aRace[i,1]=2
           m.q6Black=1
           
        Case _aRace[i,1]=3
           m.q6Asian=1
           m.q6Asian_subgroup='No Information Found'
           If IsNull(_aRace[i,2])=(.f.) And Vartype(_aRace[i,2])='N'
              If Seek(110+_aRace[i,2],'racedet','rsr_subgrp')
                 m.q6Asian_subgroup=Alltrim(racedet.descript)
              Else
                 m.q6Asian_subgroup='Other Asian'
              EndIf
           EndIf 

        Case _aRace[i,1]=5
           m.q6AmIndian=1
           
        Case _aRace[i,1]=4
           m.q6Hawaiian=1
           m.q6Hawaiian_subgroup='No Information Found'
           If IsNull(_aRace[i,2])=(.f.) And Vartype(_aRace[i,2])='N'
              If Seek(510+_aRace[i,2],'racedet','rsr_subgrp')
                 m.q6Hawaiian_subgroup=Alltrim(racedet.descript)
              Else
                 m.q6Hawaiian_subgroup='Other Pacific Islander'
              EndIf
           EndIf
     EndCase
   EndFor
 Else
   m.cRaceNote='No Information Found'
 EndIf 

 If IsNull(nEthnic)=(.f.) And (Vartype(nEthnic)='N' And nEthnic=(1))
   Do Case
      Case nEthnicSubGroup=(4)
         m.q68_subgroup='Another Hispanic, Latino/a or Spanish origin'
 
      Case nEthnicSubGroup=(0)
         m.q68_subgroup='No Information Found'
      Otherwise 
         If Seek(310+nEthnicSubGroup,'racedet','rsr_subgrp')
            m.q68_subgroup=Alltrim(racedet.descript)
         Else
            m.q68_subgroup='Another Hispanic, Latino/a or Spanish origin'
         EndIf
   EndCase 
 EndIf 
Return 0
EndFunc 
*

Function PopulateServices(clTc_id)
m.q16=0  && 8
m.q17=0  && 10
m.q18=0  && 11
m.q19=0  && 13
m.q20=0  && 14
m.q21=0  && 15
m.q22=0  && 16
m.q23=0  && 17
m.q24=0  && 18
m.q25=0  && 19
m.q26=0  && 9
m.q27=0  && 12
m.q28=0  && 20
m.q29=0  && 21
m.q30=0  && 22
m.q31=0  && 23
m.q32=0  && 24
m.q33=0  && 25
m.q34=0  && 26
m.q35=0  && 27
m.q36=0  && 28
m.q37=0  && 29
m.q38=0  && 30
m.q39=0  && 31
m.q40=0  && 32
m.q41=0  && 33
m.q42=0  && 34
m.q43=0  && 35
m.q44=0  && 36
m.q45=0  && 55

Select 'm.q'+Alltrim(rsr_service_definitions.question_id)+'='+Transform(servicevisits.visits,'@l 9999') as quest ;
From rsr_service_definitions ;
Join servicevisits ;
   On rsr_service_definitions.rsr_serviceid=servicevisits.serviceid ;
Where rsr_service_definitions.rsr_type='C' And;
      servicevisits.tc_id=clTc_id;
Order By 1;
Into Cursor _sv

If _Tally > 0
   Select _sv
   Go Top 
   Scan
      ExecScript(_sv.quest)
   
   EndScan 
Endif

Use in _sv

Select 'm.q'+Alltrim(rsr_service_definitions.question_id)+'=1' as quest ;
From rsr_service_definitions ;
Join servicedelivered ;
   On rsr_service_definitions.rsr_serviceid=servicedelivered.serviceid ;
Where rsr_service_definitions.rsr_type='S' And;
      servicedelivered.tc_id=clTc_id;
Order By 1;
Into Cursor _sd

If _Tally > 0
   Select _sd
   Go Top 
   Scan
      ExecScript(_sd.quest)
   
   EndScan 
Endif

Use in _sd

Return 
*

Function Populate48(clTc_id)
cVar2Change=''

Select Strtran(servicedt, ',','/')+', ' As servDate;
From ambulatoryservice;
Where tc_id=clTc_id;
Order by 1;
Into Cursor _sd

If _Tally > 0
   Select _sd
   Go Top
   Scan
      cVar2Change=cVar2Change+_sd.servDate   
   EndScan 
   cVar2Change=Substr(cVar2Change,1,Len(cVar2Change)-2)
Else
   cVar2Change='No Information Found'
EndIf

Use In _sd
Return cVar2Change
*

Function Populate49(cltc_id)
Select Transform(count,'@b 99999999') as cnt1,;
       Strtran(servicedt, ',','/')+', ' As servDate;
From cd4test;
Where tc_id=clTc_id;
Order by 2;
Into Cursor _sd

cVar2Change=''

If _Tally > 0
   Select _sd
   Go Top
   Scan
      cVar2Change=cVar2Change+Alltrim(_sd.cnt1)+' '+_sd.servDate   
   EndScan 
   cVar2Change=Substr(cVar2Change,1,Len(cVar2Change)-2)
Else
   cVar2Change='No Information Found'
EndIf

Use In _sd
Return cVar2Change
*

Function Populate50(cltc_id)
Select Transform(count,'@b 99999999') as cnt1,;
       Strtran(servicedt, ',','/')+', ' As servDate;
From viralloadtest;
Where tc_id=clTc_id;
Order by 2;
Into Cursor _sd

cVar2Change=''

If _Tally > 0
   Select _sd
   Go Top
   Scan
      cVar2Change=cVar2Change+Alltrim(_sd.cnt1)+' '+_sd.servDate   
   EndScan 
   cVar2Change=Substr(cVar2Change,1,Len(cVar2Change)-2)
Else
   cVar2Change='No Information Found'
EndIf

Use In _sd
Return cVar2Change
*

Procedure create_work_table


Select clientReport.tc_id,;
 cli_cur.last_name As last_name,;
 cli_cur.first_name As first_name,;
 cli_cur.id_no As id_no,;
 m.curQH_note As curQH_note,;
 curservpool.is_medical As is_medical,;
 Iif(IsNull(clientReport.enrlmtstid),7,clientReport.enrlmtstid) As q2,;
 Space(60) As q2_descript,;
 Iif(IsNull(clientReport.birthyear) Or Empty(clientReport.birthyear),'No Information Found',clientReport.birthyear) As q4,;
 Iif(IsNull(clientReport.ethncityid) Or Empty(clientReport.ethncityid),3,clientReport.ethncityid) As q5,;
 Space(25) As q5_subgroup,;
 Iif(IsNull(clientReport.hispsubid) Or Empty(clientReport.hispsubid),0,clientReport.hispsubid) As q68,;
 Space(50) As q68_subgroup,;
 Space(25) As cRaceNote,;
 0 As q6White,;
 0 As q6Black,;
 0 As q6Asian,;
 Space(60) As q6Asian_subgroup,;
 0 As q6AmIndian,;
 0 As q6Hawaiian,;
 Space(60) As q6Hawaiian_subgroup,;
 Iif(IsNull(clientReport.genderid) Or Empty(clientReport.genderid),4,clientReport.genderid) As q7,;
 Space(27) As q7_descript,;
 Iif(IsNull(clientReport.sexbirthid) Or Empty(clientReport.sexbirthid),3, clientReport.sexbirthid) As q71,;
 Space(25) As q71_descript,;
 Iif(IsNull(clientReport.trasgndrid) Or Empty(clientReport.trasgndrid),3, clientReport.trasgndrid) As q8,;
 Space(25) As q8_descript,;
 Iif(IsNull(clientReport.pvrtylvlid) Or Empty(clientReport.pvrtylvlid), 99, clientReport.pvrtylvlid) As q9,;
 Space(60) As q9_descript,;
 Iif(IsNull(clientReport.housstatid) Or Empty(clientReport.housstatid), 4, clientReport.housstatid) As q10,;
 Space(25) As q10_descript,;
 Iif(IsNull(clientReport.HIVSTATID) Or Empty(clientReport.HIVSTATID), 6, clientReport.HIVSTATID) As q12,;
 Space(60) As q12_descript,;
 Iif(IsNull(clientReport.hivdiagyr) Or Empty(clientReport.hivdiagyr),'No Information Found',Padr(clientReport.hivdiagyr,25)) As q72,;
 Iif(IsNull(clientReport.HIVPOSDT) Or Empty(clientReport.HIVPOSDT),'No Information Found',Padr(StrTran(clientReport.HIVPOSDT,',','/'),25,' ')) As q73,; 
 Iif(IsNull(clientReport.OAMCLINKDT) Or Empty(clientReport.OAMCLINKDT),'No Information Found',Padr(StrTran(clientReport.OAMCLINKDT,',','/'),25,' ')) As q74,; 
 Space(200) As q14,;
 Space(200) As q15,;
 0000 As q16,;
 0000 As q17,;
 0000 As q18,;
 0000 As q19,;
 0000 As q20,;
 0000 As q21,;
 0000 As q22,; 
 0000 As q23,; 
 0000 As q24,; 
 0000 As q25,; 
 0000 As q26,; 
 0000 As q27,; 
 0000 As q28,; 
 0000 As q29,; 
 0000 As q30,; 
 0000 As q31,; 
 0000 As q32,; 
 0000 As q33,; 
 0000 As q34,; 
 0000 As q35,; 
 0000 As q36,; 
 0000 As q37,; 
 0000 As q38,; 
 0000 As q39,; 
 0000 As q40,; 
 0000 As q41,; 
 0000 As q42,; 
 0000 As q43,; 
 0000 As q44,; 
 0000 As q45,; 
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5),;
     Icase(Isnull(clientReport.RSKSCRNGID),'No Information Found',;
           clientReport.RSKSCRNGID=(1),Padr('No',25,' '),;
           clientReport.RSKSCRNGID=(2),Padr('Yes',25,' '), Space(25)), ;
     Space(25)) As q46,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5),;
     Icase(Isnull(clientReport.FSTAMBCRDT),'No Information Found',;
           !Empty(clientReport.FSTAMBCRDT),Padr(StrTran(clientReport.FSTAMBCRDT,',','/'),25,' '), Space(25)),;
     Space(25)) As q47,;
 Space(200) AS q48,;
 Space(200) AS q49,;
 Space(200) AS q50,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.PRSCRBDPCP),Padr('No Information Found',23,' '),;
           clientReport.PRSCRBDPCP=1,Padr('No',23,' '),;
           clientReport.PRSCRBDPCP=2,Padr('Yes',23,' '),;
           clientReport.PRSCRBDPCP=3,'Not Medically Indicated',;
           clientReport.PRSCRBDPCP=4,Padr('No, client refused',23,' '), Space(23)),;
     Space(23)) As q51,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.PRSCRBDHRT),Padr('No Information Found',45,' '),; 
           clientReport.PRSCRBDHRT=1,Padr('Yes',45,' '),; 
           clientReport.PRSCRBDHRT=3,Padr('No, not ready (as determined by clinician)',45,' '),; 
           clientReport.PRSCRBDHRT=4,Padr('No, client refused',45,' '),; 
           clientReport.PRSCRBDHRT=5,Padr('No, intolerance, side-effect, toxicity',45,' '),; 
           clientReport.PRSCRBDHRT=6,Padr('No, ART payment assistance unavailable',45,' '),; 
           clientReport.PRSCRBDHRT=7,Padr('No, other reason',45,' '), Space(45)),;
     Space(45)) As q52,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.SCRNDTBSAD),Padr('No Information Found',23,' '),;
           clientReport.SCRNDTBSAD=1,Padr('No',23,' '),;
           clientReport.SCRNDTBSAD=2,Padr('Yes',23,' '),;
           clientReport.SCRNDTBSAD=3,'Not Medically Indicated',;
           clientReport.SCRNDTBSAD=4,Padr('Unknown',23,' '), Space(23)),;
     Space(23)) As q54,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.SCRNDSYPH),Padr('No Information Found',23,' '),;
           clientReport.SCRNDSYPH=1,Padr('No',23,' '),;
           clientReport.SCRNDSYPH=2,Padr('Yes',23,' '),;
           clientReport.SCRNDSYPH=3,'Not Medically Indicated', Space(23)),;
     Space(23)) As q55,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.SCRNDHEPBS),Padr('No Information Found',23,' '),;
           clientReport.SCRNDHEPBS=1,Padr('No',23,' '),;
           clientReport.SCRNDHEPBS=2,Padr('Yes',23,' '),;
           clientReport.SCRNDHEPBS=3,'Not Medically Indicated',;
           clientReport.SCRNDHEPBS=4,Padr('Unknown',23,' '), Space(23)),;
     Space(23)) As q57,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.VAXHEPBID),'No Information Found   ',;
           clientReport.VAXHEPBID=1,Padr('No',23,' '),;
           clientReport.VAXHEPBID=2,Padr('Yes',23,' '),;
           clientReport.VAXHEPBID=3,'Not Medically Indicated', Space(23)),;
     Space(23)) As q58,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.SCRNDHEPCS),Padr('No Information Found',23,' '),;
           clientReport.SCRNDHEPCS=1,Padr('No',23,' '),;
           clientReport.SCRNDHEPCS=2,Padr('Yes',23,' '),;
           clientReport.SCRNDHEPCS=3,'Not Medically Indicated',;
           clientReport.SCRNDHEPCS=4,Padr('Unknown',23,' '), Space(23)),;
     Space(23)) As q60,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.SCRNDSA),Padr('No Information Found',23,' '),;
           clientReport.SCRNDSA=1,Padr('No',23,' '),;
           clientReport.SCRNDSA=2,Padr('Yes',23,' '),;
           clientReport.SCRNDSA=3,'Not Medically Indicated', Space(23)),;
     Space(23)) As q61,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5), ;
     Icase(IsNull(clientReport.SCRNDMH),Padr('No Information Found',23,' '),;
           clientReport.SCRNDMH=1,Padr('No',23,' '),;
           clientReport.SCRNDMH=2,Padr('Yes',23,' '),;
           clientReport.SCRNDMH=3,'Not Medically Indicated', Space(23)),;
     Space(23)) As q62,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5) And curservpool.sex='F', ;
     Icase(IsNull(clientReport.RCVDPAPSM),Padr('No Information Found',23,' '),;
           clientReport.RCVDPAPSM=1,Padr('No',23,' '),;
           clientReport.RCVDPAPSM=2,Padr('Yes',23,' '),;
           clientReport.RCVDPAPSM=3,'Not Medically Indicated',;
           clientReport.RCVDPAPSM=4,Padr('Not Applicable',23,' '), Space(23)),;
     Space(23)) As q63,;
 Iif(curservpool.is_medical And InList(curservpool.hivstatid, 2,3,4,5) And curservpool.sex='F', ;
     Icase(IsNull(clientReport.PREGNANTID),Padr('No Information Found',23,' '),;
           clientReport.PREGNANTID=1,Padr('No',23,' '),;
           clientReport.PREGNANTID=2,Padr('Yes',23,' '),;
           clientReport.PREGNANTID=3,Padr('Not applicable',23,' '), Space(23)),;
     Space(23)) As q64;
From clientReport;
Join curservpool On curservpool.tc_id=clientReport.tc_id;
Join cli_cur On cli_cur.tc_id=curservpool.tc_id;
Into Cursor _curClientDemog ReadWrite;
Order By 1
Return
