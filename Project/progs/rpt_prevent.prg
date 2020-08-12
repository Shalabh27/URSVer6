**********************************
*  Program...........: PREVSERV.PRG (Summary of Services Provided during the Reporting Month)
Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;             && report selection    
              lcTitle, ;            && report selection    
              D_from , ;            && from date
              D_to, ;               && to date   
              Crit , ;              && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

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

Do Case
   Case lnStat = 1 && 1. Summary of Services Provided    
         Do rpt_prev_ser With lPrev,  cContract, cCsite, d_from, d_to 
   Case lnStat = 2 && 2. Summary of Anonymous Services Provided   
        Do rpt_prev_an With lPrev,  cContract, cCsite, d_from, d_to 
   Case lnStat = 3 && 3. Summary of Client Enrollment and Caseload 
         Do rpt_prev_cl With lPrev,  cContract, cCsite, d_from, d_to 
Endcase   



