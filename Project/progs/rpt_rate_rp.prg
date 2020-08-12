* jss, 12/22/06, upgrade Foxpro 2.6 report to VFP 9.0

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
   If Rtrim(aSelvar2(i, 1)) = "CBILL_TYPE"
      cBill_Type = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CRATE_GRP"
      cRate_Grp = aSelvar2(i, 2)
   Endif
EndFor

******************************************
* Billing Rates Setup Report
******************************************
PRIVATE gchelp
gchelp='Billing Rates Setup Report'
*Crit = ""

oApp.Msg2User("WAITRUN", "Preparing Report Data.   ", "")

SELECT ;
	rate_hd.*, ;
	rate_history.rate_md_id, rate_history.rate_grp ;
FROM ;
	rate_hd, rate_history ;
WHERE ;
	rate_hd.rate_hd_id = rate_history.rate_hd_id AND ;
	rate_hd.bill_type = cBill_Type ;
UNION ;
SELECT ;
	rate_hd.*, ;
	SPACE(10) AS rate_md_id, SPACE(5) AS rate_grp ;
FROM rate_hd ;
WHERE ;
	rate_hd.bill_type = cBill_Type AND ;
	NOT exist (SELECT * FROM rate_history WHERE rate_hd.rate_hd_id = rate_history.rate_hd_id) ;
INTO CURSOR ;
	rates1


* jss, 1/10/06, add "and rates1.rate_grp = crate_grp" to where clause in first half of union below
*     also, removing HAVING clause and replace with "AND rates1.rates_grp=crate_grp" in second half of union
SELECT ;
	rates1.rate_hd_id, ;
	rates1.Rate_code, ;
	rates1.Descript, ;
	rates1.Bill_type, ;
	rates1.By_time, ;
	rates1.Ismedicaid, ;
	rates1.rate_md_id, ;
	rates1.rate_grp, ;
	rate_history.rate_dt_id, ;
	rate_history.rate, ;
	rate_history.eff_date ;
FROM ;
	rates1, rate_history ;
WHERE ;
	rates1.rate_md_id = rate_history.rate_md_id ;
  AND ;
   rates1.rate_grp = cRate_grp ;
UNION ;
SELECT ;
	rates1.rate_hd_id, ;
	rates1.Rate_code, ;
	rates1.Descript, ;
	rates1.Bill_type, ;
	rates1.By_time, ;
	rates1.Ismedicaid, ;
	rates1.rate_md_id, ;
	rates1.rate_grp, ;
	SPACE(10) AS rate_dt_id, ;
	0000.00 AS rate, ;
	{} as eff_date ;
FROM rates1 ;
WHERE ;
	NOT exist (SELECT * FROM rate_history WHERE rates1.rate_md_id = rate_history.rate_md_id) ;
 AND ;
   rates1.rate_grp = cRate_Grp ;
INTO CURSOR ;
	rt_cur1 ;
ORDER BY ;
	2, 8, 11 DESC

**HAVING 
**   rates1.rate_grp = cRate_Grp 


cTitle='Rates Setup Report'
 
If Used('rates_cur') 
   Use In rates_cur
Endif
  
Select rt_cur1.*, ;
   cTitle as cTitle, ;
   Crit as Crit, ;   
   cDate as cDate, ;
   cTime as cTime ;
From rt_cur1 ;
Into Cursor ;
   rates_cur   

oApp.Msg2User("OFF")

IF EOF("rates_cur")
	oApp.msg2user('NOTFOUNDG')
ELSE
   gcRptName = 'rpt_rate_rp'
   Do Case
   CASE lPrev = .f.
      Report Form rpt_rate_rp To Printer Prompt Noconsole NODIALOG 
   CASE lPrev = .t.     &&Preview
      oApp.rpt_print(5, .t., 1, 'rpt_rate_rp', 1, 2)
   EndCase
ENDIF

USE IN rt_cur1
USE IN rates1
