Parameters lPrev, ;      && Preview     
           aSelvar1, ;   && select parameters from selection list
           nOrder, ;     && order by
           nGroup, ;     && report selection    
           lcTitle, ;    && report selection    
           Date_fr , ;   && from date
           Date_t, ;     && to date   
           Crit , ;      && name of param
           lnStat, ;     && selection(Output)  page 2
           cOrderBy      && order by description

Acopy(aSelvar1, aSelvar2)
cTc_id2    = ""
cCSite = ""
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Alltrim(aSelvar2(i, 1)) = "CTC_ID3"
      cTc_id2 = aSelvar2(i, 2)
   EndIf
   If Alltrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   EndIf
EndFor

Set Step On

cDate = DATE()
cTime = TIME()

PRIVATE gchelp
gchelp = "Syringe Exchanges by Client ID"
************************  Opening Tables ************************************

cFiltExpr = IIF(EMPTY(cTC_ID2)   , "", "Needlx.tc_id = cTC_ID2")
cFiltExpr = cFiltExpr + IIF(EMPTY(cCSite)   ,   "", IIF(!Empty(cFiltExpr),".and.","") + " needlx.site = cCSite")
cFiltExpr = cFiltExpr + IIF(EMPTY(Date_fr), "", IIF(!Empty(cFiltExpr),".and.","") + " needlx.date >= Date_fr")         
cFiltExpr = cFiltExpr + IIF(EMPTY(Date_t),   "", IIF(!Empty(cFiltExpr),".and.","") + " needlx.date <= Date_t")

*!*   If !Empty(cFiltExpr)
*!*      cFiltExpr = " AND " + cFiltExpr
*!*   EndIf 

If Used('needl_cur')
   Use in needl_cur
EndIf

*!* PB: Ver 8.7 id_no is dropped from needlx; get the id_no from ai_clien
Select ;
   needlx.*, ;
   ai_clien.id_no As id_no,;
   program.descript As prog_descr, ;
   site.descript1  As site_descr,  ;
   Date_fr As Date_from, ;
   Date_t As Date_to, ;
   Crit As Crit, ;   
   cDate As cDate, ;
   cTime As cTime ;
From ;
   needlx ;
Join program On needlx.program=program.prog_id;
join site On needlx.site = site.site_id;
Join ai_clien On needlx.tc_id = ai_clien.tc_id;
Where ;
   &cFiltExpr ;
Order By ;
   ai_clien.id_no, needlx.Date Desc ;
INTO CURSOR ;
   needl_cur

oApp.msg2user('OFF')

Select Needl_cur
Go top 
If EOF()
   oApp.msg2user('NOTFOUNDG')
Else
   gcRptName = 'rpt_syr_cli'
   Do Case
       CASE lPrev = .f.
         Report Form rpt_syr_cli  To Printer Prompt Noconsole NODIALOG 
      CASE lPrev = .t.    
            oApp.rpt_print(5, .t., 1, 'rpt_syr_cli', 1, 2)
                     
   EndCase 
Endif
