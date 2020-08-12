******************************************
* Billing Rates Setup Report
******************************************
* jss, 12/19/06, upgrade Foxpro 2.6 report to VFP 9.0

Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by number
              nGroup, ;             && report selection number   
              lcTitle1, ;           && report selection description   
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description
              
Acopy(aSelvar1, aSelvar2)

* set Data Engine Compatibility to handle Foxpro version 7.0 or earlier (lets old SQL work)
mDataEngine=Sys(3099,70)
lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)
cTitle=lcTitle1
cDate=Dtoc(Date())
cTime=Time()

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CPROV_ID"
      cProv_id = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CRATE_GRP"
      cRate_Grp = aSelvar2(i, 2)
   Endif
EndFor

PRIVATE gchelp
gchelp='Payer/Provider Setup Screen'

PRIVATE nSaveArea
nSaveArea = Select()
*Crit = ""

* jss, 1/10/07, remove variable cInsProvId, use cProv_id in selects below to filter by prov_id

Select (nSaveArea)

oApp.Msg2User("WAITRUN", "Preparing Report Data.   ", "")

=OpenFile("procpara", "code")

SELECT ;
	med_prov.Prov_id, ;
	med_prov.Name, ;
	med_prov.Ismedicaid, ;
	med_prov.Instype, ;
	med_prov.Def_period, ;
	med_prov.Signature, ;
	med_prov.Auth_by, ;
	Med_Pro2.Prov2_id, ;
	Med_Pro2.Prov_num, ;
	Med_Pro2.Descript, ;
	Med_Pro2.Mag_input, ;
	Med_Pro2.claimtype, ;
	Med_Pro2.Def_phys, ;
	Med_Pro2.Tax_ID, ;
	Med_Pro2.Street1, ;
	Med_Pro2.Street2, ;
	Med_Pro2.City, ;
	Med_Pro2.St, ;
	Med_Pro2.Zip, ;
	Med_Pro2.Phone, ;
	Med_Pro2.Phase2 ;
FROM ;
	med_prov, Med_Pro2 ;
WHERE ;
	med_prov.Prov_Id = cProv_ID AND ;
	med_prov.Prov_Id = Med_Pro2.Prov_Id ;
UNION ;
SELECT ;
	med_prov.Prov_id, ;
	med_prov.Name, ;
	med_prov.Ismedicaid, ;
	med_prov.Instype, ;
	med_prov.Def_period, ;
	med_prov.Signature, ;
	med_prov.Auth_by, ;
	SPACE(5)  AS Prov2_id, ;
	SPACE(12) AS Prov_num, ;
	SPACE(30) AS Descript, ;
	SPACE(3)  AS Mag_input, ;
	SPACE(2)  AS claimtype, ;
	SPACE(5)  AS Def_phys, ;
	SPACE(11) AS Tax_ID, ;
	SPACE(30) AS Street1, ;
	SPACE(30) AS Street2, ;
	SPACE(20) AS City, ;
	SPACE(2)  AS St, ;
	SPACE(9)  AS Zip, ;
	SPACE(10) AS Phone, ;
	.f.		 As phase2 ;
FROM ;
	med_prov ;
WHERE ;
	med_prov.Prov_Id = cProv_ID AND ;
	med_prov.Prov_Id NOT IN (SELECT Prov_id FROM Med_pro2) ;
INTO CURSOR ;
	TempCur

* jss, 1/10/07, incorporate cRate_grp filter in next select
SELECT ;
	TempCur.*, ;
	Med_Pro3.Prog, ;
	Med_Pro3.Site, ;
	Med_Pro3.Prov3_id, ;
	Med_Pro3.Rate_grp, ;
	Med_Pro3.Def_loc, ;
	Med_Pro3.Cat_serv, ;
	Med_Pro3.Clin_spec, ;
	Med_Pro3.Plan_code, ;
	Med_Pro3.Hosp_code ;
FROM ;
	TempCur, Med_Pro3 ;
WHERE ;
	TempCur.Prov2_ID = Med_Pro3.Prov2_ID ;
and ;
   Med_Pro3.Rate_grp = cRate_grp ;
INTO CURSOR ;
	ProvSetup1

cTitle='Payers/Providers Setup Report'
   
Select ProvSetUp1.*, ;
   cTitle as cTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime ;
From ProvSetUp1 ;
Into Cursor ;
   ProvSetUp   
  
INDEX ON Prov_ID + Prov2_id + Prog + Site TAG RepOrder

* 1/10/07, jss, comment next
*IF !EMPTY(cRate_Grp)
*	SET FILTER TO Rate_grp = cRate_Grp 
*ENDIF

oApp.Msg2User("OFF")

IF EOF("ProvSetup")
	oApp.Msg2user('NOTFOUNDG')
ELSE
   gcRptName = 'rpt_prov_rp'
   Do Case
   CASE lPrev = .f.
      Report Form rpt_prov_rp To Printer Prompt Noconsole NODIALOG 
   CASE lPrev = .t.     &&Preview
      oApp.rpt_print(5, .t., 1, 'rpt_prov_rp', 1, 2)
   EndCase
ENDIF

*USE IN provsetup
USE IN tempcur

Select (nSaveArea)

RETURN