* print Part D of form (HIV Test Survey and ARV/HIV Med Hx)
*************************************************************************
** This program prints the CTR Part D and ARV/HIV Meds form
** It requires the tc_id of the client selected in the intake screen
*************************************************************************
Parameter cTC_ID,tcCTR_ID
cTime = Time()
cDate = Date()
cCtrTest_id =''

gcTc_ID =cTC_ID
gcCTR_ID = tcCTR_ID
   

REQUERY('lv_ctr_test_filtered')


Select lv_ctr_test_filtered
Locate For lv_ctr_test_filtered.ctr_id = tcCTR_ID and lv_ctr_test_filtered.test_number=2

cCtrTest_id = lv_ctr_test_filtered.ctrtest_id

Select lv_ctr_partd
Locate For lv_ctr_partd.ctrtest_id = cCtrTest_id

If !Found()
   oApp.msg2user('NOTFOUNDG')   
   Return
Endif

***Client Information
Select cli_cur
Locate For tc_id = cTC_ID
cClientId = cli_cur.id_no 
dDob = cli_cur.dob
***Gender
Select gender
Locate For gender.code = cli_cur.gender 
If Found()
   cGender = Left(gender.descript, 50)
Else
   cGender = Space(50)
Endif

cRace=''
If (cli_cur.white + cli_cur.blafrican + cli_cur.asian + cli_cur.hawaisland + cli_cur.indialaska +cli_cur.someother) > 1
   cRace= "More than One Race"
Else
   Do Case
      Case cli_cur.white = 1
         cRace= "White"
         
      Case cli_cur.blafrican = 1
         cRace= "Black / African American"
         
      Case cli_cur.asian = 1
         cRace= "Asian"
         
      Case cli_cur.hawaisland = 1
         cRace="Native Hawaiian/Pacific Islander "   
         
      Case cli_cur.indialaska = 1
         cRace="American Indian or Alaska Native"      
         
      Case cli_cur.someother = 1
         cRace="Some Other Race"      
         
      Otherwise
         cRace="Unknown Race"
         
   EndCase

Endif 

cEthnic=''
Do Case
   Case cli_cur.hispanic = 2 
        cEthnic="Hispanic"
        
   Case cli_cur.hispanic = 1
        cEthnic="Non-Hispanic"
        
   Otherwise
        cEthnic="Unknown Ethnicity"
EndCase

***ZIP
Select address
Locate For address.client_id = cli_cur.client_id
If Found()
   cZip = address.zip
Else
   cZip = ''
Endif

If Used('ctrd')
   Use In ctrd
Endif

*!*   * get info from part A
Select    Alltrim(lv_ai_ctr_filtered.Form_Id) as form_id, ;
          lv_ai_ctr_filtered.ctr_id, ;
          cClientId as id_no, ; 
          dDob as dob, ;
          cGender as gender, ;
          cEthnic as ethnic, ;
          cRace as race, ;
          cZip as zip, ;
          lv_ai_ctr_filtered.session_dt, ;
          Rtrim(lv_ai_ctr_filtered.psite_id) + Space(1) + Rtrim(site.descript1) as pSiteDesc,; 
          Rtrim(lv_ai_ctr_filtered.pworker_id)+Space(1)+ Upper(oApp.FormatName(staffcur.last, staffcur.first, staffcur.mi)) as pworkerdesc, ;
          Iif(!Empty(lv_ai_ctr_filtered.aloccde), lv_ai_ctr_filtered.aloccde, 'N/A')  as aloccde, ;
          lv_ai_ctr_filtered.projwave ,;
          GetRH(rel.pregnant) as pregnant,;
          GetRH(rel.inprencare) as inprencare ;
from lv_ai_ctr_filtered ;
      Inner Join site on;
                 site.psite_id = lv_ai_ctr_filtered.psite_id ;    
             And lv_ai_ctr_filtered.ctr_id = tcCTR_ID ;
             And lv_ai_ctr_filtered.tc_id = cTc_ID ;  
      inner join staffcur on ;
                staffcur.pworker_id = lv_ai_ctr_filtered.pworker_id ; 
      left outer join relhist rel on ;
      		    lv_ai_ctr_filtered.risk_id = rel.risk_id;       
into cursor t_partd

 select   pd.*, ; 
 			 lvpd.survey_dt, ;
          Rtrim(lvpd.psite_idD) + Space(1) + Rtrim(site_t.descript1) as psite_idD,; 
          Rtrim(work_t.pworker_id)+Space(1)+ Upper(oApp.FormatName(work_t.last, work_t.first, work_t.mi)) as workerD, ;                                      
          GetFTest(lvpd.first_pos_test) as first_pos_test, ;
          Iif(Empty(lvpd.fposmmyyyy),'', Left(lvpd.fposmmyyyy, 2) + '/' + right(lvpd.fposmmyyyy, 4)) as fposmmyyyy,;
          GetUnkDt(lvpd.unkfposdt)  as unkfposdt, ;
          GetFTest(lvpd.evertstneg) as evertstneg, ;
          Iif(Empty(lvpd.lnegmmyyyy),'', Left(lvpd.lnegmmyyyy, 2) + '/' + right(lvpd.lnegmmyyyy, 4)) as lnegmmyyyy,;
          GetUnkDt(lvpd.unklnegdt)  as unklnegdt, ;
          Iif(Empty(lvpd.ftstmmyyyy),'', Left(lvpd.ftstmmyyyy, 2) + '/' + right(lvpd.ftstmmyyyy, 4)) as ftstmmyyyy,;
          GetUnkDt(lvpd.unkftstdt) as unkftstdt, ;
          lvpd.numtests, ;
          GetFTest(lvpd.takingarv) as takingarv, ;
          GetFTest(lvpd.arvsixmos) as arvsixmos, ;
          lvpd.fdayarvmed, ;
          lvpd.ldayarvmed, ;
          lvpd.first_pos_test_date,;
          GetMed(lvpd.med_code1) as med_code1, ;
          GetMed(lvpd.med_code2) as med_code2, ;
          GetMed(lvpd.med_code3) as med_code3, ;
          lvpd.othermed, ;
          cTime as cTime,   ;                                    
          cDate as cDate ;  
from t_partd as pd,  lv_ctr_partd lvpd ;
 Inner Join site site_t on;
                site_t.psite_id = lvpd.psite_idD ;  
   inner join staffcur work_t on ;
                work_t.pworker_id = lvpd.workerD ;               
where lvpd.ctrtest_id = cCtrTest_id   ;
Into cursor ctrd                  

If Used('t_partd')
   Use In t_partd
Endif

                
Select ctrd
Go top
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   Report Form rpt_ctrd To Printer Prompt Noconsole NODIALOG 
Endif
Return
****************  
Function GetUnkDt
*****************    
Parameter UnkDtParm
RetUnkDt=Space(20)

Do Case
Case UnkDtParm=1
	RetUnkDt=PADR("Don't know date",15)
Case UnkDtParm=2
	RetUnkDt=PADR("Refused date",15)
Case UnkDtParm=3
	RetUnkDt=PADR("Not asked date",15)
Otherwise
	RetUnkDt=PADR("N/A",15)
Endcase
Return RetUnkDt

*****************    
Function GetFTest
*****************    
Parameter FTest

RetFTest=Space(10)
Do Case
Case FTest=1
	RetFTest=PADR("Yes",10)
Case FTest=2
	RetFTest=PADR("No",10)	
Case FTest=3
	RetFTest=PADR("Don't know",10)	
Case FTest=4
	RetFTest=PADR("Refused",10)	
Otherwise
	RetFTest=PADR("N/A",10)
Endcase
Return RetFTest

*****************
Function GetRH
*****************
Parameter RHV

RHVDesc=Space(10)

Do Case
Case RHV=1
	RHVDesc=PADR("Yes",10)
Case RHV=2
	RHVDesc=PADR("No",10)	
Case RHV=3
	RHVDesc=PADR("Don't know",10)	
Case RHV=4
	RHVDesc=PADR("Refused",10)	
Case RHV=5
	RHVDesc=PADR("Not asked",10)	
Otherwise
	RHVDesc=PADR("N/A",10)
Endcase
Return RHVDesc

*******************
Function GetSiteT
*******************
Parameter SiteTyParm

RetSiteT=Space(30)
Select Descript as Site_Type ;
  From PEMSSite ;
 Where !Empty(SiteTyParm) and code=SiteTyParm ;
Into Array ;
	aGetSiteT 
	
If _tally>0
	RetSiteT=PADR(aGetSiteT(1),60)
Else
	RetSiteT=PADR("N/A",60)	
Endif
Release aGetSiteT
Return RetSiteT

***************
Function GetMed
***************
Parameter MedParm
RetMed=Space(30)
Select Descript as Med ;
  From CTRMeds ;
 Where !Empty(MedParm) and code=MedParm ;
Into Array ;
	aGetMed 
	
If _tally>0
	RetMed=PADR(aGetMed(1),30)
Else
	RetMed=PADR("N/A",30)	
Endif
Release aGetMed
Return RetMed

