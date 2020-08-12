*!*
*!* copied from rpt_mhra_pr2.prg
*!* 05/20/2009
*!* jim power
*!*

Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              D_from , ;            && from date
              D_to, ;               && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy ,;           && order by description
              wreport               && used to determined it detail/summary report 
              
Acopy(aSelvar1, aSelvar2)

cContract = ""
cCsite    = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCONTRACT"
      cContract = aSelvar2(i, 2)
   EndIf
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCsite = aSelvar2(i, 2)
   EndIf
EndFor

dTempDate = CTOD(Str(Month(d_from),2,0)+"/01/"+Str(Year(d_from),4,0))
Date_From = dTempDate
Date_To   = GoMonth(dTempDate, + 1) - 1
               
Do Case

   Case lnStat = 1 && 01. Summary of Services Provided     
         Do rpt_mhra_sr2_cr with lPrev,  cContract, cCsite, Date_From, Date_To, .f.
         
*!*      Case lnStat = 2 && 02. Follow-Up Activities Report     
*!*           Do rpt_mhra_act With lPrev,  cContract, cCsite, Date_from, Date_to, .f. 
*!*           
*!*      Case lnStat = 3 && 03 Summary of Referrals Into Program     
*!*           Do rpt_mhra_rpr With lPrev,  cContract, cCsite, date_from, date_to, .f. 
*!*      
*!*      Case lnStat = 4 && 04. Summary of Referrals by Agency         
*!*           Do rpt_mhra_rag With lPrev,  cContract, cCsite, date_from, date_to, .f.      
*!*           
*!*      Case lnStat = 5 && 05. Summary of Client Enrollment and Statuses    
*!*           Do rpt_mhra_cls With lPrev,  cContract, cCsite, date_from, date_to, .f.    

*!*      Case lnStat = 6 && 06. Summary of Special Populations    
*!*           Do rpt_mhra_spp With lPrev,  cContract, cCsite, date_from, date_to, .f.     
*!*           
*!*     Case lnStat = 7 && 07. Demographics of New Clients by Age/Race 
*!*           Do rpt_mhra_dem With lPrev,  cContract, cCsite, date_from, date_to, .f.     
*!*     
*!*     Case lnStat = 8 && 08. Summary of New/Total Clients by Zip Code 
*!*           Do rpt_mhra_zip With lPrev,  cContract, cCsite, date_from, date_to, .f.   
*!*     
*!*     Case lnStat = 9 && 09 Anonymous Services & Client Demographics  
*!*           Do rpt_mhra_ano With lPrev,  cContract, cCsite, date_from, date_to, .f.                        
*!*           
*!*    Case lnStat = 10 && 10. Summary of Education,Training, & Outreach
*!*           Do rpt_mhra_eto With lPrev,  cContract, cCsite, date_from, date_to, .f.     
             
Endcase  