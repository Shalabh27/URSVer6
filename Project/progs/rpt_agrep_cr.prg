Parameters ;
      lPrev, ;      && Preview
      aSelvar1, ;   && select parameters from selection list
      nOrder, ;     && order by number
      nGroup, ;     && report selection number
      lcTitle1, ;   && report selection description
      Date_from , ; && from date
      Date_to, ;    && to date
      Crit , ;      && name of param
      lnStat, ;     && selection(Output)  page 2
      cOrderBy, ;   && order by description
      wreport
*!*
*!* program : rpt_agrep_cr.prg
*!* created : 04/22/2009
*!*
*!*  note   : this is a copy of program rpt_agrep.prg
*!*           added statements for crystal reports processing
*!*           see comments below
*!*           jim power
*!*

Acopy(aSelvar1, aSelvar2)

* set Data Engine Compatibility to handle Foxpro version 7.0 or earlier (lets old SQL work)
mDataEngine=Sys(3099,70)
lcTitle1 = Left(lcTitle1, Len(lcTitle1)-1)

***VT 07/18/2007
cCSite = ""
cContract = ""
LCProg = ""
cAgency_id = ""

&& Search For Parameters
For i = 1 To Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CCONTRACT"
      cContract = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   Endif

   If Rtrim(aSelvar2(i, 1)) = "CAGENCY_ID"
      cAgency_id = aSelvar2(i, 2)
   Endif
Endfor

Private gchelp
gchelp = "Generating Monthly Aggregate Reports"

**VT 01/02/2008
***Crit = ""
**End

cReportSelection = ""
nMon = 0
nDat  = 0

* jss, 5/7/03, add code to handle CT here
If gcState='NY'
   cTitle = "AIDS Institute Aggregate Reports"
Endif
If gcState='CT'
   cTitle = "Connecticut Aggregate Reports"
Endif

If Empty(m.Date_to)
   oApp.msg2user('INFORM', 'Please Enter "To" Date')
   Return
Endif

cDate = Date()
cTime = Time()

* if we have already created the "Hold1" cursor created by GetCliLst(), don't run it again

***VT 07/18/2007
**IF (Used("Hold1") and Reccount("Hold1")>0) or GetCliLst()=.t.
If GetCliLst()=.T.

   Do Case
      Case lnStat=1
         * Age by Sex by Ethnicity/Race - Active Clients
         Do AgeSxx_Rpt With .T.

      Case lnStat=2
         * Age by Sex by Ethnicity/Race - New Clients
         Do AgeSxx_Rpt With .F.

      Case lnStat=3
         * Encounters by Contr., Service Type - Total and Anon
         Do Rpt_CnEnc

      Case lnStat=4
         * Encounters by Service Type- Total + Anonymous
         Do Rpt_AiEnc

      Case lnStat=5
         * List Clients in Main Aggregate - DO NOT SEND
         Do MainAggDet

      Case lnStat=6
         * Main Aggregate Report - Active Clients

         If Used("aiaggrpt2")
            Use In aiaggrpt2
         Endif

         Do MainAggRpt With .T.

         wfield = Space(10)
         Select a.*, wfield As "cdc_risk", wfield As "rw_risk" , gcagencyname As agencyname ;
            from aiaggrpt2 As a;
            into Cursor temp Readwrite

         Select temp
         Set Filter To Group = 'Active Clients by Risk Category'
         Replace cdc_risk With 'N/A' For Label = 'Hemo'
         Replace cdc_risk With 'N/A' For Label = 'Other'
         Replace cdc_risk With 'N/A' For Label = 'Blood'
         Replace cdc_risk With 'N/A' For Label = 'Perinatal'
         Replace cdc_risk With 'N/A' For Label = 'Undet'
         Replace rw_risk With 'N/A' For Label = 'General'
         Replace rw_risk With 'N/A' For Label = 'Mother'

         Select temp
         Set Filter To Group = "Active Clients by Income, Household Size, and Poverty Status"
         Replace count2 With 0 All

         Set Filter To Label = 'HIV-Negative, Affected'
         Replace count2 With 0 All

         Set Filter To Label = 'No/Unknown Insurance'
         Replace count2 With 0 All

         Set Filter To Label = 'HIV-Negative, At Risk, Not Affected'
         Replace count2 With 0 All

         Set Filter To
         *!*   replace clinewtot WITH 20 all
         *!*   replace newacttot WITH 15 all
         *!*   replace reoptotot WITH 8 all
         *!*   replace clospetot WITH 4 all
         *!*   REPLACE endacttot WITH begacttot+clinewtot+newacttot+reoptotot+clospetot all
         
         Go Top
         
         Select progrdesc, Group, Sum(Count) As tot_cnt1, Sum(count2) As tot_cnt2 ;
            FROM temp ;
            GROUP By 1,2 Into Cursor tmp Readwrite

         Select temp.*, T.tot_cnt1, T.tot_cnt2, oApp.gcversion As Version, Dtoc(oApp.gdverdate) As verdate ;
            FROM temp Left Outer Join tmp As T On T.progrdesc+T.Group = temp.progrdesc+temp.Group;
            INTO Cursor Final

         *!*
         *!* following added 04/27/2009
         *!* for CR2008/Visual Advantage Processing
         *!* jim power
         *!*

         Copy To oapp.gcpath2temp+"active_clients_demographics.dbf"

*!*            Declare Integer ShellExecute In shell32.Dll ;
*!*               INTEGER hndWin, ;
*!*               STRING caction, ;
*!*               STRING cFilename, ;
*!*               STRING cParms, ;
*!*               STRING cDir, ;
*!*               INTEGER nShowWin

*!*            If wreport = 'D'
*!*               Lcparms = "active_clients_demographics.rpt"
*!*            Else
*!*               Lcparms = "active_clients_demographics_summary.rpt"
*!*            Endif
*!*            LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*            LcAction = "open"
*!*            Lcdir = "i:\ursver6\airs_crreports\"
*!*            ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

         oApp.display_crystal_reports(Iif(wreport = 'D',"active_clients_demographics.rpt","active_clients_demographics_summary_graph.rpt"))

         *!* following lines
         *!*8 no longet needed..
         *!*

         *!*         gcRptName = 'rpt_aggrpt'
         *!*         Do Case
         *!*         CASE lPrev = .f.
         *!*            Report Form rpt_aggrpt To Printer Prompt Noconsole NODIALOG
         *!*         CASE lPrev = .t.     &&Preview
         *!*            oApp.rpt_print(5, .t., 1, 'rpt_aggrpt', 1, 2)
         *!*         EndCase
         *****************************************************************************************
         *!*      Case lnStat=7
         *!*     * Main Aggregate Report - Active Clients  summary

         *!*         If Used("aiaggrpt2")
         *!*            Use In aiaggrpt2
         *!*         Endif

         *!*         Do MainAggRpt with .t.
         *!*
         *!*         wfield = SPACE(10)
         *!*         SELECT a.*, wfield as "cdc_risk", wfield as "rw_risk" , gcagencyname as agencyname ;
         *!*                from aiaggrpt2 as a;
         *!*                into cursor temp readwrite
         *!*
         *!*    SELECT temp
         *!*    SET FILTER TO group = 'Active Clients by Risk Category'
         *!*      REPLACE cdc_risk WITH 'N/A' FOR label = 'Hemo'
         *!*      REPLACE cdc_risk WITH 'N/A' FOR label = 'Other'
         *!*      REPLACE cdc_risk WITH 'N/A' FOR label = 'Blood'
         *!*      REPLACE cdc_risk WITH 'N/A' FOR label = 'Perinatal'
         *!*      REPLACE cdc_risk WITH 'N/A' FOR label = 'Undet'
         *!*      REPLACE rw_risk WITH 'N/A' FOR label = 'General'
         *!*      REPLACE rw_risk WITH 'N/A' FOR label = 'Mother'
         *!*
         *!*   SELECT temp
         *!*   SET FILTER TO group = "Active Clients by Income, Household Size, and Poverty Status"
         *!*   replace count2 WITH 0 all

         *!*   SET FILTER TO label = 'HIV-Negative, Affected'
         *!*   REPLACE count2 WITH 0 all

         *!*   SET FILTER TO label = 'No/Unknown Insurance'
         *!*   REPLACE count2 WITH 0 all

         *!*   SET FILTER TO label = 'HIV-Negative, At Risk, Not Affected'
         *!*   replace count2 WITH 0 all

         *!*   SET FILTER TO
         *!*   *!*   replace clinewtot WITH 20 all
         *!*   *!*   replace newacttot WITH 15 all
         *!*   *!*   replace reoptotot WITH 8 all
         *!*   *!*   replace clospetot WITH 4 all
         *!*   *!*   REPLACE endacttot WITH begacttot+clinewtot+newacttot+reoptotot+clospetot all
         *!*   GO top

         *!*   SELECT progrdesc, group, SUM(count) as tot_cnt1, SUM(count2) as tot_cnt2 ;
         *!*      FROM temp ;
         *!*      GROUP BY 1,2 INTO CURSOR tmp readwrite

         *!*   SELECT temp.*, t.tot_cnt1, t.tot_cnt2, oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate ;
         *!*      FROM temp LEFT OUTER JOIN tmp as t ON t.progrdesc+t.group = temp.progrdesc+temp.group;
         *!*      INTO CURSOR final

         *!*   *!*
         *!*   *!* following added 04/27/2009
         *!*   *!* for CR2008/Visual Advantage Processing
         *!*   *!* jim power
         *!*   *!*

         *!*   COPY to oapp.gcpath2temp+"active_clients_demographics.dbf"
         *!*
         *!*   DECLARE INTEGER ShellExecute IN shell32.dll ;
         *!*           INTEGER hndWin, ;
         *!*           STRING caction, ;
         *!*           STRING cFilename, ;
         *!*           STRING cParms, ;
         *!*           STRING cDir, ;
         *!*           INTEGER nShowWin

         *!*   Lcparms = "active_clients_demographics_summary.rpt"
         *!*
         *!*   LcFileName = "c:\ursver6\project\libs\display_reports.exe"
         *!*   LcAction = "open"
         *!*   Lcdir = "c:\airs_crreports\"
         *!*   ShellExecute(0,LcAction,Lcfilename,lcparms,lcdir,1)


         *********************************************************************************************


      Case lnStat=7
         * Main Aggregate Report - New Clients

         If Used("aiaggrpt2")
            Use In aiaggrpt2
         Endif

         Do MainAggRpt With .F.

         wfield = Space(10)
         Select a.*, gcagencyname As agencyname, wfield As "cdc_risk", wfield As "rw_risk"  ;
            from aiaggrpt2 As a;
            into Cursor temp Readwrite

         Select temp
         Set Filter To Group = 'Active Clients by Risk Category'
         Replace cdc_risk With 'N/A' For Label = 'Hemo'
         Replace cdc_risk With 'N/A' For Label = 'Other'
         Replace cdc_risk With 'N/A' For Label = 'Blood'
         Replace cdc_risk With 'N/A' For Label = 'Perinatal'
         Replace cdc_risk With 'N/A' For Label = 'Undet'
         Replace rw_risk With 'N/A' For Label = 'General'
         Replace rw_risk With 'N/A' For Label = 'Mother'

         Select temp
         Set Filter To Group = "Active Clients by Income, Household Size, and Poverty Status"
         Replace count2 With 0 All

         Set Filter To Label = 'HIV-Negative, Affected'
         Replace count2 With 0 All

         Set Filter To Label = 'No/Unknown Insurance'
         Replace count2 With 0 All

         Set Filter To
         Go Top
         *!*   replace clinewtot WITH 20 all
         *!*   replace newacttot WITH 15 all
         *!*   replace reoptotot WITH 8 all
         *!*   replace clospetot WITH 4 all
         *!*   REPLACE endacttot WITH begacttot+clinewtot+newacttot+reoptotot+clospetot all


         Select progrdesc, Group, Sum(Count) As tot_cnt1, Sum(count2) As tot_cnt2 ;
            FROM temp ;
            GROUP By 1,2 Into Cursor tmp Readwrite

         Select temp.*, T.tot_cnt1, T.tot_cnt2, oApp.gcversion As Version, Dtoc(oApp.gdverdate) As verdate ;
            FROM temp Left Outer Join tmp As T On T.progrdesc+T.Group = temp.progrdesc+temp.Group;
            INTO Cursor Final

         *!*
         *!* following added 05/13/2009
         *!* for CR2008/Visual Advantage Processing
         *!* jim power
         *!*
         Copy To oapp.gcpath2temp+"new_clients_demographics.dbf"

*!*            Declare Integer ShellExecute In shell32.Dll ;
*!*               INTEGER hndWin, ;
*!*               STRING caction, ;
*!*               STRING cFilename, ;
*!*               STRING cParms, ;
*!*               STRING cDir, ;
*!*               INTEGER nShowWin

*!*            If wreport = 'D'
*!*               Lcparms = "new_clients_demographics.rpt"
*!*            Else
*!*               Lcparms = "new_clients_demographics_summary.rpt"
*!*            Endif

*!*            LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*            LcAction = "open"
*!*            Lcdir = "i:\ursver6\airs_crreports\"
*!*            ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

         oApp.display_crystal_reports(Iif(wreport = 'D',"new_clients_demographics.rpt","new_clients_demographics_summary_graph.rpt"))

         *******
         *!*         SELECT aiaggrpt2

         *!*         gcRptName = 'rpt_aggrpt'
         *!*         Do Case
         *!*         CASE lPrev = .f.
         *!*            Report Form rpt_aggrpt To Printer Prompt Noconsole NODIALOG
         *!*         CASE lPrev = .t.     &&Preview
         *!*            oApp.rpt_print(5, .t., 1, 'rpt_aggrpt', 1, 2)
         *!*         EndCase

      Case lnStat=8
         * Revenue Detail Report
         Do Rpt_RevDet

      Case lnStat=9
         * Revenue Summary Report
         Do Rpt_RevSumm

      Case lnStat=10
         * Summary of Referrals
         Do Rpt_AiRef

   Endcase

Else
   If Used('hold')
      If Eof('hold')
         oApp.msg2user('NOTFOUNDG')
      Endif
   Endif
Endif

* reset Data Engine compatibility back to Visual 9.0
mDataEngine=Sys(3099,90)

*!*   If Used("allintak")
*!*      use in allintak
*!*   Endif
*!*   If Used("allprog")
*!*      use in allprog
*!*   Endif
*!*   If Used("allenrol")
*!*      use in allenrol
*!*   Endif
*!*   If Used("allactiv")
*!*      use in allactiv
*!*   Endif
*!*
*!*   If Used("baclose")
*!*      use in baclose
*!*   Endif
*!*   If Used("begactiv")
*!*      use in begactiv
*!*   Endif
*!*   If Used("begactto")
*!*      use in begactto
*!*   Endif
*!*   If Used("begenrol")
*!*      use in begenrol
*!*   Endif
*!*   If Used("begintto")
*!*      use in begintto
*!*   Endif
*!*   If Used("begintak")
*!*      use in begintak
*!*   Endif
*!*   If Used("begclose")
*!*      use in begclose
*!*   Endif
*!*   If Used("begenrto")
*!*      use in begenrto
*!*   Endif
*!*   If Used("baclosto")
*!*      use in baclosto
*!*   Endif

*!*   If Used("cnclose")
*!*      use in cnclose
*!*   Endif
*!*   If Used("cnclosto")
*!*      use in cnclosto
*!*   Endif
*!*   If Used("chkactiv")
*!*      use in chkactiv
*!*   Endif
*!*   If Used("clospeto")
*!*      use in clospeto
*!*   Endif
*!*   If Used("closper")
*!*      use in closper
*!*   Endif
*!*   If Used("clbegint")
*!*      use in clbegint
*!*   Endif
*!*   If Used("closento")
*!*      use in closento
*!*   Endif
*!*   If Used("closenr1")
*!*      use in closenr1
*!*   Endif
*!*   If Used("closenr2")
*!*      use in closenr2
*!*   Endif
*!*   If Used("closenro")
*!*      use in closenro
*!*   Endif
*!*   If Used("closint")
*!*      use in closint
*!*   Endif
*!*   If Used("closinto")
*!*      use in closinto
*!*   Endif

*!*   If Used("endactto")
*!*      use in endactto
*!*   Endif
*!*   If Used("endenrto")
*!*      use in endenrto
*!*   Endif
*!*   If Used("endclose")
*!*      use in endclose
*!*   Endif
*!*   If Used("endactiv")
*!*      use in endactiv
*!*   Endif
*!*   If Used("endenrol")
*!*      use in endenrol
*!*   Endif
*!*   If Used("endintto")
*!*      use in endintto
*!*   Endif
*!*   If Used("endintak")
*!*      use in endintak
*!*   Endif

*!*   If used('hold3hd')
*!*      Use in hold3hd
*!*   EndIf

*!*   If Used("hold3h")
*!*      Use in hold3h
*!*   Endif
*!*   If Used("newactiv")
*!*      use in newactiv
*!*   Endif
*!*   If Used("newactto")
*!*      use in newactto
*!*   Endif
*!*   If Used("newenrto")
*!*      use in newenrto
*!*   Endif
*!*   If Used("newenrol")
*!*      use in newenrol
*!*   Endif
*!*   If Used("newprog")
*!*      use in newprog
*!*   Endif
*!*   If Used("newintak")
*!*      use in newintak
*!*   Endif

*!*   If Used("temp2hdf")
*!*      Use in temp2hdf
*!*   Endif
*!*   If Used("temp1hdf")
*!*      Use in temp1hdf
*!*   Endif
*!*   If Used("temp2hdm")
*!*      Use in temp2hdm
*!*   Endif
*!*   If Used("temp1hdm")
*!*      Use in temp1hdm
*!*   Endif
*!*   If Used("tclosper")
*!*      use in tclosper
*!*   Endif
*!*   If Used("treopened")
*!*      use in treopened
*!*   Endif
*!*   If Used("tbegintak")
*!*      use in tbegintak
*!*   Endif
*!*   If Used("tnewenrol")
*!*      use in tnewenrol
*!*   Endif
*!*   If Used("tendintak")
*!*      use in tendintak
*!*   Endif
*!*   If Used("tcurs3")
*!*      use in tcurs3
*!*   Endif
*!*   If Used("tcurs1")
*!*      use in tcurs1
*!*   Endif
*!*   If Used("tcurs2")
*!*      use in tcurs2
*!*   Endif
*!*   If Used("tnewint")
*!*      use in tnewint
*!*   Endif
*!*   If Used("tbegactiv")
*!*      use in tbegactiv
*!*   Endif
*!*   If Used("tendactiv")
*!*      use in tendactiv
*!*   Endif
*!*   If Used("tnewenr2")
*!*      use in tnewenr2
*!*   Endif
*!*   If Used("tadjust")
*!*      use in tadjust
*!*   Endif
*!*   If Used("tadjust1")
*!*      use in tadjust1
*!*   Endif


*!*   If Used("raagehold0")
*!*      use in raagehold0
*!*   Endif
*!*   If Used("reclose")
*!*      use in reclose
*!*   Endif
*!*   If Used("reclosto")
*!*      use in reclosto
*!*   Endif
*!*   If Used("reoptota")
*!*      use in reoptota
*!*   Endif
*!*   If Used("reopento")
*!*      use in reopento
*!*   Endif
*!*   If Used("reopen")
*!*      use in reopen
*!*   Endif
*!*   If Used("reopinto")
*!*      use in reopinto
*!*   Endif
*!*   If Used("reopinta")
*!*      use in reopinta
*!*   Endif
*!*   If Used("reopened")
*!*      use in reopened
*!*   Endif


*!*   If Used("tvoid1")
*!*      use in tvoid1
*!*   Endif
*!*   If Used("tvoided")
*!*      use in tvoided
*!*   Endif

Return
**********************************************************************
Procedure GetCliLst
**********************************************************************
* this is the procedure that gathers the base list of clients to be
* reported on. It must allways be run
* the different aggregates for the clients are done and reported here
* The base list is held in a cursor "hold1"
**********************************************************************
* jss, 3/2000, create cursor aiaggdet for new client demographic detail report
Create Cursor aiaggdet (column0 C(2), column1 C(50), column2 C(60), column3 N(10), column4 C(75), column5 C(20), column6 D, column7 C(5), column8 D)

Index On column1 + column0 + column4 Tag col104

* DG 01/23/97
If Used('Hold1')
   Use In hold1
Endif


Select ;
   t1.tc_id,;
   t1.client_id, ;
   t1.urn_no, ;
   t3.last_name,;
   t3.first_name,;
   .F. As openincm,;
   t1.anonymous,;
   t1.id_no, ;
   t1.hhead,;
   t1.dchild,;
   t1.placed_dt,;
   t1.hiv_exp1,;
   t1.inaddhouse,;
   subs(address.zip,1,5) + '-' + Subs(address.zip,6,4) As zip, ;
   t3.dob,;
   t3.hispanic, ;
   t3.white,;
   t3.asian,;
   t3.hawaisland,;
   t3.indialaska ,;
   t3.blafrican,;
   t3.someother, ;
   t3.unknowrep,;
   IIF(!Empty(ethnic), Left(t3.ethnic,1)+"0", "  ") As ethnic, ;
   t1.housing ,;
   PADR(Alltrim(ref_in.Descript),55,' ')  As referalsrc ,;
   t1.nrefnote, ;
   t3.sex,;
   address.st As state      ,;
   address.fips_code As fips_code, ;
   SPACE(25) As county     ,;
   .F. As hiv_pos                  ,;
   SPACE(40) As hivstatus ,;
   .F. As ppd_pos ,;
   .F. As anergic ,;
   .F. As newprog ,;
   .F. As newagency,;
   .F. As ActivProg,;
   .F. As ActivAgen,;
   {} As end_dt,    ;
   t3.insurance, ;
   t3.is_refus, ;
   t3.hshld_incm, ;
   t3.hshld_size ;
FROM ;
   ai_clien t1,;
   cli_cur t3,;
   address,;
   ref_in;
WHERE ;
   t1.client_id = t3.client_id;
   AND t1.client_id = address.client_id;
   AND ref_in.Code = t1.ref_src2;
   AND t1.int_compl;
GROUP By ;
   t1.tc_id ;
INTO Cursor ;
   hold

* jss, 10/6/06, remove county code, use fips_code instead
*   address.county    AS code       ,;

* jss, 9/12/06, remove for VFP from "FROM" AND "WHERE", respectively, because of no more cli_hous
*   AND address.hshld_id   = cli_hous.hshld_id         ;
*   cli_hous       ,;


Dime cProbArray(1)
Store ' ' To cProbArray(1)

*** NOTE: must add next bit of code back after making sure reports are working

* let's check the data before continuing
*IF !CHKDATA("HOLD","Aggregate Reports",cProbArray)
*   ParmToPass=''
*   DO getprob WITH ParmtoPass
*   IF 2=oApp.msg2user('OK2PRINT1',ParmToPass)
*      DO deactthermo IN thermo
*       RETURN .f.
*   ELSE
*      oApp.msg2user("WAITRUN", "Continuing to Prepare Report Data.   ", "")
*   ENDIF
*ENDIF

*** Get the site and agency assignments, apply user selections if any
cCSite     = Alltrim(cCSite)
cAgency_id = Alltrim(cAgency_id)
LCProg     = Alltrim(LCProg)

* jss, 9/11/00, add time24 expression
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select Distinct hold.*,;
   ai_site.site, ;
   site.agency_id ;
FROM hold, ;
   ai_site, ;
   site ;
WHERE hold.tc_id = ai_site.tc_id ;
   AND site.site_id = ai_site.site  ;
   AND site.site_id = cCSite        ;
   AND site.agency_id = cAgency_id    ;
   AND ai_site.tc_id + Dtos(ai_site.effect_dt) + oApp.Time24(ai_site.Time,ai_site.am_pm) ;
   IN (Select ai_site2.tc_id + Max(Dtos(ai_site2.effect_dt)+ oApp.Time24(ai_site2.Time, ai_site2.am_pm)) ;
       FROM ai_site ai_site2 ;
       WHERE ai_site2.effect_dt <= m.Date_to ;
       GROUP By ;
         ai_site2.tc_id) ;
GROUP By ;
   hold.tc_id ;
INTO Cursor ;
   thold1


* jss, 7/13/2000, add code here to limit client list (when specific program is specified)
*                 to those clients enrolled or intaken in program prior to period end
* jss, 4/6/01, as per AIDS Institute: do not grab INTAKES for programs requiring enrollment
If Empty(LCProg)
   Select * From thold1 Into Cursor hold1
Else
   **VT 01/08/2008
   cWherePrg1 = Iif(Empty(LCProg),"", " And Inlist(ai_prog.program, "  + LCProg + ")" )
   cWherePrg2 = Iif(Empty(LCProg),"", " Inlist(ai_clien.Int_Prog, "  + LCProg + ") And Inlist(program.Prog_id, "  + LCProg + ") ")
   **Program       = lcprog ;
   **Int_Prog = lcprog ;
   **AND Program.prog_id = lcprog ;

   Select ;
      tc_id ;
   FROM ;
      ai_prog ;
   WHERE ;
      start_dt  <= m.Date_to ;
      AND (Empty(end_dt) Or end_dt >= m.Date_from) ;
      &cWherePrg1 ;
   UNION All;
   SELECT ;
      tc_id ;
   FROM ;
      ai_clien, Program ;
   WHERE ;
      &cWherePrg2 ;
      AND Not Program.Enr_Req ;
      AND placed_dt <= m.Date_to ;
      AND Not Exists ;
      (Select aip.* From ai_prog AIP ;
         WHERE ;
         aip.tc_id = ai_clien.tc_id And ;
         aip.Program = ai_clien.int_prog And ;
         AIP.start_dt <= m.Date_to) ;
   INTO Cursor tEnrInt

   **VT 01/08/2008
   cWherePrg1 = ''
   cWherePrg2 = ''

   Select * ;
   FROM ;
      thold1 ;
   WHERE ;
      tc_id In (Select tc_id From tEnrInt) ;
   INTO Cursor hold1
Endif

Use In hold

* make sure there are clients to report on
If _Tally = 0
   * jss, 6/28/01, change the msg2user from "OFF" to "NOTFOUNDG": this corrects problem of return with no message
   oApp.msg2user("NOTFOUNDG")
   Return .F.
Endif

* DG 01/23/97

Do Case
   Case nGroup = 1 && All Clients
      lcExpr = ".T."
   Case nGroup = 2 && Ryan White Eligible
      lcExpr = "Aar_Report"
   Case nGroup = 3 && HIV Counseling/Prevention Eligible
      lcExpr = "Ctp_Elig"
   Case nGroup = 4 && Ryan White and HIV Counseling/Prevention Eligible
      lcExpr = "(Aar_Report OR Ctp_Elig)"
Endcase


* in order for us to break the aggregate data down by program
* we need to get the program info (Aar_Report & Ctp_Elig)

************************************************************************
* Here get all clients from hold1 OPEN IN AGENCY AT START OF PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select ;
   hold1.tc_id,;
   ai_activ.effect_dt, ;
   hold1.anonymous As anonymous ;
FROM ;
   hold1, ai_activ, statvalu ;
WHERE ;
   hold1.tc_id = ai_activ.tc_id    And ;
   ai_activ.Status = statvalu.Code And ;
   statvalu.tc = gcTC              And ;
   statvalu.Type = 'ACTIV'         And ;
   statvalu.incare                 And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.Time, ai_activ.am_pm) ;
   IN   (Select t1.tc_id + Max(Dtos(t1.effect_dt)+oApp.Time24(t1.Time, t1.am_pm)) ;
         FROM ;
            ai_activ t1 ;
         WHERE ;
            t1.effect_dt < m.Date_from ;
         GROUP By ;
            t1.tc_id)  ;
INTO Cursor ;
   OpBegPer

* Here get all clients from hold1 CLOSED IN AGENCY DURING PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select ;
   hold1.tc_id,;
   ai_activ.effect_dt, ;
   hold1.anonymous As anonymous ;
FROM ;
   hold1, ai_activ, statvalu ;
WHERE ;
   hold1.tc_id = ai_activ.tc_id    And ;
   ai_activ.Status = statvalu.Code And ;
   statvalu.tc = gcTC              And ;
   statvalu.Type = 'ACTIV'         And ;
   !statvalu.incare                And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.Time, ai_activ.am_pm)  ;
   IN (Select t1.tc_id + Max(Dtos(t1.effect_dt)+oApp.Time24(t1.Time,t1.am_pm)) ;
       FROM ;
         ai_activ t1 ;
       WHERE ;
         t1.effect_dt >= m.Date_from And ;
         t1.effect_dt <= m.Date_to ;
       GROUP By ;
         t1.tc_id)      ;
   INTO Cursor ;
   ClDurPer

* Here get all clients from hold1 OPEN IN AGENCY AT END OF PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select ;
   hold1.tc_id,;
   ai_activ.effect_dt, ;
   hold1.anonymous As anonymous ;
FROM ;
   hold1, ai_activ, statvalu ;
WHERE ;
   hold1.tc_id = ai_activ.tc_id    And ;
   ai_activ.Status = statvalu.Code And ;
   statvalu.tc = gcTC              And ;
   statvalu.Type = 'ACTIV'         And ;
   statvalu.incare                 And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.Time,ai_activ.am_pm)  ;
   IN (Select t1.tc_id + Max(Dtos(t1.effect_dt)+oApp.Time24(t1.Time, t1.am_pm)) ;
       FROM ;
         ai_activ t1 ;
       WHERE ;
         t1.effect_dt <= m.Date_to    ;
       GROUP By ;
         t1.tc_id)      ;
   INTO Cursor ;
   OpEndPer

* Here get all clients from hold1 CLOSED IN AGENCY AT END OF PERIOD
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select ;
   hold1.tc_id,;
   ai_activ.effect_dt, ;
   hold1.anonymous As anonymous ;
FROM ;
   hold1, ai_activ, statvalu ;
WHERE ;
   hold1.tc_id = ai_activ.tc_id    And ;
   ai_activ.Status = statvalu.Code And ;
   statvalu.tc = gcTC              And ;
   statvalu.Type = 'ACTIV'         And ;
   !statvalu.incare                And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.Time, ai_activ.am_pm) ;
   IN (Select t1.tc_id + Max(Dtos(t1.effect_dt)+oApp.Time24(t1.Time, t1.am_pm)) ;
       FROM ;
         ai_activ t1 ;
       WHERE ;
         t1.effect_dt <= m.Date_to    ;
       GROUP By ;
         t1.tc_id)      ;
   INTO Cursor ;
   ClEndPer

* active enrollments before period start (total is BEGINNING ENROLLMENT count) (must be OPEN IN AGENCY AT START, too)

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig, b.reason ;
FROM ;
   hold1 a, ai_prog B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND b.start_dt < m.Date_from ;
   AND (b.end_dt >= m.Date_from Or Empty(b.end_dt)) ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Max(Dtos(Prog.start_dt)) ;
    FROM ai_prog Prog;
    WHERE ;
      prog.start_dt < m.Date_from ;
    GROUP By ;
      prog.tc_id, Prog.Program) ;
      AND b.tc_id  In (Select tc_id From OpBegPer) ;
GROUP By ;
   C.Prog_id, a.tc_id ;
INTO Cursor ;
   BegEnrol

**VT 01/08/2008
cWherePrg =''

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
FROM ;
   BegEnrol ;
INTO Cursor ;
   BegEnrTo   ;
GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor

If Recc()>0
   Select ;
      '02' As column0, ;
      PADR('Program: ' + Program.Descript,50) As column1, ;
      PADR('Total Active Clients at Period Start as Enrollments',60) As column2, ;
      BegEnrTo.tot As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75) As column4, ;
      ai_clien.id_no As column5, ;
      DTOC(cli_cur.dob) As column6, ;
      ai_clien.int_prog As column7, ;
      DTOC(ai_clien.placed_dt) As column8  ;
   FROM ;
      BegEnrol, BegEnrTo, ai_clien, cli_cur, Program ;
   WHERE ;
      BegEnrol.Prog_id = Program.Prog_id ;
      AND ;
      BegEnrol.Prog_id = BegEnrTo.Prog_id ;
      AND ;
      BegEnrol.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
   GROUP By ;
      column1, ;
      column0, ;
      column4  ;
   INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* now, active enrollments at period end (total is ENDING ENROLLMENT count)
**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And  Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;


Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
FROM ;
   hold1 a, ai_prog B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND b.start_dt <= m.Date_to ;
   AND (b.end_dt  > m.Date_to Or Empty(b.end_dt)) ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Max(Dtos(Prog.start_dt)) ;
    FROM ai_prog Prog;
    WHERE ;
      prog.start_dt <= m.Date_to ;
    GROUP By ;
      prog.tc_id, Prog.Program) ;
   AND ;
   b.tc_id  In (Select tc_id From OpEndPer) ;
GROUP By ;
   C.Prog_id, a.tc_id ;
INTO Cursor ;
   EndEnrol

**VT 01/08/2008
cWherePrg=''

Select ;
   Prog_id, ;
   COUNT(*) As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
FROM ;
   EndEnrol ;
INTO Cursor ;
   EndEnrTo   ;
GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '11' As column0, ;
      PADR('Program: ' + Program.Descript,50) As column1, ;
      PADR('Total Enrollments at Period End in this Program',60) As column2, ;
      EndEnrTo.tot As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75) As column4, ;
      ai_clien.id_no As column5, ;
      DTOC(cli_cur.dob) As column6, ;
      ai_clien.int_prog As column7, ;
      DTOC(ai_clien.placed_dt) As column8  ;
   FROM ;
      EndEnrol, EndEnrTo, ai_clien, cli_cur, Program ;
   WHERE ;
      EndEnrol.Prog_id = Program.Prog_id ;
      AND ;
      EndEnrol.Prog_id = EndEnrTo.Prog_id ;
      AND ;
      EndEnrol.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
   GROUP By ;
      column1, ;
      column0, ;
      column4  ;
   INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* who was CLOSED IN PROGRAM BEFORE PERIOD started? (need this to determine reopens and starts)
**VT 01/08/2007
cWhere = Iif(Empty(LCProg),"", " And  Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
FROM ;
   hold1 a, ai_prog B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND Not Empty(b.end_dt) And b.end_dt < m.Date_from ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Max(Dtos(Prog.start_dt)) ;
    FROM ai_prog Prog;
    WHERE ;
      prog.start_dt < m.Date_from ;
    GROUP By ;
      prog.tc_id, Prog.Program) ;
   INTO Cursor ;
   BegClose

* who was CLOSED IN PROGRAM AT PERIOD END?

**VT 01/08/2007
*AND c.Prog_ID = lcProg  changed to &cWherePrg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
FROM ;
   hold1 a, ai_prog B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND Not Empty(b.end_dt) And b.end_dt <= m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Max(Dtos(Prog.start_dt)) ;
    FROM ai_prog Prog;
    WHERE ;
      prog.start_dt <= m.Date_to ;
    GROUP By ;
      prog.tc_id, Prog.Program) ;
INTO Cursor ;
   EndClose

* clients closed in program who have opened during period are REOPENs

**VT 01/08/2007
*AND c.Prog_ID = lcProg  changed to &cWherePrg

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig , b.reason;
FROM ;
   hold1 a, ai_prog B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND b.start_dt Between m.Date_from And m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Min(Dtos(Prog.start_dt)) ;
    FROM ai_prog Prog;
    WHERE ;
      prog.start_dt Between m.Date_from And m.Date_to ;
    GROUP By ;
      prog.tc_id, Prog.Program) ;
   AND b.tc_id + b.Program In (Select tc_id + Prog_id From BegClose) ;
INTO Cursor ;
   ReOpen

Select ;
   Prog_id, ;
   COUNT(*) As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
FROM ;
   ReOpen ;
INTO Cursor ;
   ReopenTo ;
GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '06' As column0, ;
      PADR('Program: ' + Program.Descript,50) As column1, ;
      PADR('Total Reopened Cases this Period of Enrollments',60) As column2, ;
      ReopenTo.tot As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75) As column4, ;
      ai_clien.id_no As column5, ;
      DTOC(cli_cur.dob) As column6, ;
      ai_clien.int_prog As column7, ;
      DTOC(ai_clien.placed_dt) As column8  ;
   FROM ;
      ReOpen, ReopenTo, ai_clien, cli_cur, Program ;
   WHERE ;
      ReOpen.Prog_id = Program.Prog_id ;
      AND ;
      ReOpen.Prog_id = ReopenTo.Prog_id ;
      AND ;
      ReOpen.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
   GROUP By ;
      column1, ;
      column0, ;
      column4  ;
   INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* active intakes prior to period (not enrolled prior to period) this is the BEGINNING INTAKE count
* 4/6/01, jss, only count intakes for programs that do not require enrollment
*   AND NOT c.Enr_Req

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig, Space(2) As Reason ;
FROM ;
   hold1 a, ai_clien B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.int_prog = C.Prog_id ;
   AND Not C.Enr_Req ;
   AND a.placed_dt < m.Date_from ;
   AND &lcExpr ;
   &cWherePrg ;
   AND b.tc_id + b.int_prog Not In (Select tc_id + Prog_id From BegEnrol) ;
   AND b.tc_id + b.int_prog Not In (Select tc_id + Prog_id From BegClose) ;
INTO Cursor ;
   tBegIntak

**VT01/08/2008
cWherePrg =''

* make sure they are open in the agency
Select * ;
FROM ;
   tBegIntak ;
WHERE ;
   tc_id In ;
   (Select tc_id From OpBegPer) ;
GROUP By ;
   Prog_id, tc_id ;
INTO Cursor ;
   BegIntak

* what about those that are closed in agency at start? need this to determine REOPEN INTAKES
Select * ;
FROM ;
   tBegIntak ;
WHERE ;
   tc_id Not In ;
   (Select tc_id From OpBegPer) ;
INTO Cursor ;
   ClBegInt

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
FROM ;
   BegIntak ;
INTO Cursor ;
   BegIntTo ;
GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '01'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total Active Clients at Period Start as Intakes',60)                As column2, ;
      BegIntTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
   FROM ;
      BegIntak, BegIntTo, ai_clien, cli_cur, Program ;
   WHERE ;
      BegIntak.Prog_id = Program.Prog_id ;
      AND ;
      BegIntak.Prog_id = BegIntTo.Prog_id ;
      AND ;
      BegIntak.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
   GROUP By ;
      column1, ;
      column0, ;
      column4  ;
   INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* now, find out who has NEWly ENROLLed during period (total is new enrollments)
* too many subselects, so must do this in three select statements
**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig, b.reason ;
FROM ;
   hold1 a, ai_prog B, Program C ;
WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND b.start_dt Between m.Date_from And m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Min(Dtos(Prog.start_dt)) ;
    FROM ai_prog Prog;
    WHERE ;
      prog.start_dt Between m.Date_from And m.Date_to ;
    GROUP By ;
   prog.tc_id, Prog.Program) ;
INTO Cursor ;
   tNewEnrol

**VT 01/08/2008
cWherePrg = ''

* above, grab earliest start date within period
* next, exclude any that were already enrolled or previously enrolled at start of period

Select * ;
FROM tNewEnrol ;
WHERE;
   tNewEnrol.tc_id + tNewEnrol.Prog_id Not In (Select tc_id + Prog_id From BegEnrol) ;
   AND tNewEnrol.tc_id + tNewEnrol.Prog_id Not In (Select tc_id + Prog_id From BegClose) ;
INTO Cursor tNewEnr2

* now, exclude those that were previously intaken in program at start of period
Select * ;
   FROM    tNewEnr2 ;
   WHERE ;
   tNewEnr2.tc_id + tNewEnr2.Prog_id Not In (Select tc_id + Prog_id From BegIntak) ;
   GROUP By ;
   Prog_id, tc_id ;
   INTO Cursor NewEnrol

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   NewEnrol ;
   INTO Cursor ;
   NewEnrTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '04'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total New Clients this Period as Enrollments',60)                   As column2, ;
      NewEnrTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      NewEnrol, NewEnrTo, ai_clien, cli_cur, Program ;
      WHERE ;
      NewEnrol.Prog_id = Program.Prog_id ;
      AND ;
      NewEnrol.Prog_id = NewEnrTo.Prog_id ;
      AND ;
      NewEnrol.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* get intakes CONVERTed to program enrollment; (tNewEnr2) contains newly enrolled clients
Select * ;
   FROM ;
   BegIntak ;
   WHERE ;
   BegIntak.tc_id + BegIntak.Prog_id In (Select tc_id + Prog_id From tNewEnr2);
   INTO Cursor ;
   Convert

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   Convert ;
   INTO Cursor ;
   ConverTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '09'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total Intakes Converted to Enrollments this Period',60)             As column2, ;
      ConverTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      Convert, ConverTo, ai_clien, cli_cur, Program ;
      WHERE ;
      Convert.Prog_id = Program.Prog_id ;
      AND ;
      Convert.Prog_id = ConverTo.Prog_id ;
      AND ;
      Convert.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* if client closed in agency, also necessarily closed in each program they were enrolled in at start
Select * ;
   FROM ;
   BegEnrol ;
   UNION    ;
   SELECT    * ;
   FROM ;
   NewEnrol ;
   UNION ;
   SELECT * ;
   FROM ;
   Convert ;
   UNION ;
   SELECT    * ;
   FROM ;
   ReOpen ;
   INTO Cursor ;
   AllEnrol

Index On Prog_id+tc_id Tag progtcid

* now, find out which ENROLLed clients have CLOSED during period (total is closed of enrollments)
**VT 01/08/2007
cWherePrg =Iif(Empty(LCProg),"", " And  Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig, b.reason ;
   FROM ;
   hold1 a, ai_prog B, Program C ;
   WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND &lcExpr ;
   &cWherePrg ;
   AND ;
   b.end_dt Between m.Date_from And m.Date_to ;
   AND;
   b.tc_id + b.Program + Dtos(b.start_dt) In ;
   (Select Prog.tc_id + Prog.Program + Max(Dtos(Prog.start_dt)) ;
   FROM ai_prog Prog;
   WHERE ;
   prog.start_dt <= m.Date_to ;
   GROUP By ;
   prog.tc_id, Prog.Program) ;
   AND ;
   b.tc_id + b.Program In (Select tc_id + Prog_id From AllEnrol) ;
   INTO Cursor ;
   ClosEnr1

**VT 01/08/2007
cWherePrg = ''

* now, get those that have closed in agency
Select * ;
   FROM ;
   AllEnrol ;
   WHERE ;
   tc_id In (Select tc_id From ClEndPer) ;
   INTO Cursor ;
   ClosEnr2

* combine the two for all closed enrollments
Select * ;
   FROM ;
   ClosEnr1 ;
   UNION ;
   SELECT * ;
   FROM ;
   ClosEnr2 ;
   INTO Cursor ;
   ClosEnro

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   ClosEnro ;
   INTO Cursor ;
   ClosEnTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '08'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total Cases Closed of Program Enrollments',60)                       As column2, ;
      ClosEnTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      ClosEnro, ClosEnTo, ai_clien, cli_cur, Program ;
      WHERE ;
      ClosEnro.Prog_id = Program.Prog_id ;
      AND ;
      ClosEnro.Prog_id = ClosEnTo.Prog_id ;
      AND ;
      ClosEnro.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* get new intakes
* 4/6/01, jss, only count intakes for programs that do not require enrollment
*   AND NOT c.Enr_Req

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And  Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig, Space(2) As Reason ;
   FROM ;
   hold1 a, ai_clien B, Program C ;
   WHERE ;
   a.tc_id = b.tc_id ;
   AND b.int_prog = C.Prog_id ;
   AND Not C.Enr_Req ;
   AND a.placed_dt Between m.Date_from And m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   AND b.tc_id + b.int_prog Not In (Select tc_id + Prog_id From NewEnrol) ;
   INTO Cursor ;
   tNewInt

**VT 01/08/2007
cWherePrg = ''


* above, we exclude situation in which the client is intaken and enrolled in same period
* below, we make certain that the clients are in fact new (never existed in program before)
* jss, 9/1/00, add additional filter: no clients previously intaken (open and closed in agency)
*                                     before period start (clbegint)
Select * ;
   FROM tNewInt ;
   WHERE;
   tNewInt.tc_id + tNewInt.Prog_id Not In (Select tc_id + Prog_id From BegEnrol) ;
   AND    tNewInt.tc_id + tNewInt.Prog_id Not In (Select tc_id + Prog_id From BegClose) ;
   GROUP By ;
   Prog_id, tc_id ;
   INTO Cursor tNewInt01

Select * ;
   FROM tNewInt01 ;
   WHERE;
   tNewInt01.tc_id + tNewInt01.Prog_id Not In (Select tc_id + Prog_id From ClBegInt) ;
   GROUP By ;
   Prog_id, tc_id ;
   INTO Cursor NewIntak

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   NewIntak ;
   INTO Cursor ;
   NewIntTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '03'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total New Clients this Period as Intakes',60)                      As column2, ;
      NewIntTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      NewIntak, NewIntTo, ai_clien, cli_cur, Program ;
      WHERE ;
      NewIntak.Prog_id = Program.Prog_id ;
      AND ;
      NewIntak.Prog_id = NewIntTo.Prog_id ;
      AND ;
      NewIntak.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* create a cursor called newprog that has all new tc_id+prog_id for intakes AND enrollments
Select Distinct Prog_id, tc_id ;
   FROM      NewEnrol ;
   UNION ;
   SELECT Distinct Prog_id, tc_id ;
   FROM     NewIntak ;
   INTO Cursor ;
   newprog

Index On Prog_id+tc_id Tag progtcid

* active intakes at end of period (not enrolled prior to period end) this is the ENDING INTAKE count
* 4/6/01, jss, only count intakes for programs that do not require enrollment
*   AND NOT c.Enr_Req

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And  Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig, Space(2) As Reason  ;
   FROM ;
   hold1 a, ai_clien B, Program C ;
   WHERE ;
   a.tc_id = b.tc_id ;
   AND b.int_prog = C.Prog_id ;
   AND Not C.Enr_Req ;
   AND a.placed_dt <= m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   AND b.tc_id + b.int_prog Not In (Select tc_id + Prog_id From EndEnrol) ;
   AND b.tc_id + b.int_prog Not In (Select tc_id + Prog_id From EndClose) ;
   INTO Cursor ;
   tEndIntak

**VT 01/08/2008
cWherePrg= ''

Select * ;
   FROM ;
   tEndIntak ;
   WHERE ;
   tc_id In ;
   (Select tc_id From OpEndPer) ;
   GROUP By ;
   Prog_id, tc_id ;
   INTO Cursor ;
   EndIntak

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   EndIntak ;
   INTO Cursor ;
   EndIntTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '10'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total Intakes at Period End in this Program',60)                   As column2, ;
      EndIntTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      EndIntak, EndIntTo, ai_clien, cli_cur, Program ;
      WHERE ;
      EndIntak.Prog_id = Program.Prog_id ;
      AND ;
      EndIntak.Prog_id = EndIntTo.Prog_id ;
      AND ;
      EndIntak.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* grab REOPEN INTAKES (the ending intakes that were closed at period start)
Select * ;
   FROM ;
   EndIntak ;
   WHERE ;
   tc_id+Prog_id In (Select tc_id+Prog_id From ClBegInt) ;
   INTO Cursor ;
   ReopInta

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   ReopInta ;
   INTO Cursor ;
   ReopInTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '05'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total Reopened Cases this Period of Intakes',60)                   As column2, ;
      ReopInTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      ReopInta, ReopInTo, ai_clien, cli_cur, Program ;
      WHERE ;
      ReopInta.Prog_id = Program.Prog_id ;
      AND ;
      ReopInta.Prog_id = ReopInTo.Prog_id ;
      AND ;
      ReopInta.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* jss, 11/98, add new cursor to account for CLOSED INTAKES
* because of too many subselects, must do this in 2 steps:
* first, get all intakes
* then, make sure none of them were converted to enrollments during period,
*       and grab the ones that closed in agency
* jss, 8/31/2000, add select for reopen intakes to creation of allintak below
Select * ;
   FROM ;
   BegIntak ;
   UNION ;
   SELECT * ;
   FROM ;
   NewIntak ;
   UNION ;
   SELECT * ;
   FROM ;
   ReopInta ;
   INTO Cursor ;
   AllIntak

* 12/99, jss, create new cursor AllProg, which combines intakes/enrollments
Select * ;
   FROM ;
   AllIntak ;
   UNION ;
   SELECT * ;
   FROM ;
   AllEnrol ;
   INTO Cursor ;
   AllProg

Index On Prog_id+tc_id Tag progtcid

Select * ;
   FROM ;
   AllIntak ;
   WHERE ;
   tc_id + Prog_id Not In (Select tc_id + Prog_id From Convert)  ;
   AND tc_id               In (Select tc_id           From ClEndPer) ;
   INTO Cursor ;
   ClosInt

Select ;
   Prog_id, ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   ClosInt ;
   INTO Cursor ;
   ClosInTo ;
   GROUP By ;
   Prog_id

Index On Prog_id Tag Prog_id

* jss, 3/2000, for detail report, add following cursor
If Recc()>0
   Select ;
      '07'                                                                     As column0, ;
      PADR('Program: ' + Program.Descript,50)                                 As column1, ;
      PADR('Total Cases Closed of Program Intakes',60)                         As column2, ;
      ClosInTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      ClosInt, ClosInTo, ai_clien, cli_cur, Program ;
      WHERE ;
      ClosInt.Prog_id = Program.Prog_id ;
      AND ;
      ClosInt.Prog_id = ClosInTo.Prog_id ;
      AND ;
      ClosInt.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      column1, ;
      column0, ;
      column4  ;
      INTO Cursor  ;
      tempcols

   Select aiaggdet
   Appe From (Dbf("tempcols"))
   Use In tempcols

Endif

* the next select pre-dates 8/98 changes, and is used for counts within programs
**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And  Inlist(c.prog_id, "  + LCProg + ")" )
*AND c.Prog_ID = lcProg ;

Select ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
   FROM ;
   hold1 a, ai_prog B, Program C ;
   WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND b.start_dt <= m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   UNION ;
   SELECT ;
   a.*, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
   FROM ;
   hold1 a, ai_clien B, Program C ;
   WHERE ;
   a.tc_id = b.tc_id ;
   AND b.int_prog = C.Prog_id ;
   AND a.placed_dt <= m.Date_to ;
   AND &lcExpr ;
   &cWherePrg ;
   INTO Cursor ;
   hold2

* make sure there are clients to report on

If _Tally = 0
   oApp.msg2user('NOTFOUNDG')
   Return .T.
Endif

Use In hold1
Use Dbf("hold2") In 0 Again Alias hold1
Use In hold2

* jss, 8/98, use placed_dt as Start_dt instead of (ai_activ.effect_dt where ai_activ.initial)
Select *, ;
   placed_dt As start_dt;
   FROM ;
   hold1 ;
   INTO Cursor ;
   hold2

Use In hold1

* Here get all clients closed at the end of a period
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
Select ;
   hold2.tc_id,;
   ai_activ.effect_dt, ;
   hold2.anonymous As anonymous ;
   FROM ;
   hold2, ai_activ, statvalu ;
   WHERE ;
   hold2.tc_id = ai_activ.tc_id    And ;
   ai_activ.Status = statvalu.Code And ;
   statvalu.tc = gcTC              And ;
   statvalu.Type = 'ACTIV'         And ;
   !statvalu.incare                And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.Time, ai_activ.am_pm) ;
   IN (Select ;
   t1.tc_id + Max(Dtos(t1.effect_dt)+oApp.Time24(t1.Time, t1.am_pm)) ;
   FROM ;
   ai_activ t1 ;
   WHERE ;
   t1.effect_dt <= m.Date_to ;
   GROUP By ;
   t1.tc_id)      ;
   INTO Cursor ;
   cliclosed

Index On tc_id Tag tc_id
Set Order To Tag tc_id

* jss, 8/98, add new select here that will grab all tc_id's that have been reopened anytime during period

* first, get those tc_ids that exist prior to start of period (the active ones here are the beginning active count)
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select ;
   ai_activ.tc_id, ;
   statvalu.incare As Active, ;
   hold2.anonymous ;
   FROM ;
   ai_activ, ;
   statvalu,  ;
   hold2 ;
   WHERE ;
   ai_activ.Status    = statvalu.Code ;
   AND ;
   ai_activ.tc_id = hold2.tc_id ;
   AND ;
   ai_activ.effect_dt < m.Date_from     ;
   AND ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt) + oApp.Time24(ai_activ.Time, ai_activ.am_pm) ;
   IN (Select aia.tc_id + Max(Dtos(aia.effect_dt)+oApp.Time24(aia.Time, aia.am_pm)) ;
   FROM ai_activ aia ;
   WHERE ;
   aia.effect_dt < m.Date_from ;
   GROUP By ;
   tc_id) ;
   INTO Cursor ;
   tcurs1

* next, get all tc_ids that exist prior to end of period
Select ;
   ai_activ.tc_id, ;
   statvalu.incare As Active, ;
   hold2.anonymous ;
   FROM ;
   ai_activ, ;
   statvalu, ;
   hold2 ;
   WHERE ;
   ai_activ.Status    = statvalu.Code ;
   AND ;
   ai_activ.tc_id = hold2.tc_id ;
   AND ;
   ai_activ.effect_dt <= m.Date_to     ;
   AND ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt) + oApp.Time24(ai_activ.Time, ai_activ.am_pm) ;
   IN (Select aia.tc_id + Max(Dtos(aia.effect_dt)+oApp.Time24(aia.Time, aia.am_pm)) ;
   FROM ai_activ aia ;
   WHERE ;
   aia.effect_dt <= m.Date_to ;
   GROUP By ;
   aia.tc_id) ;
   INTO Cursor ;
   tcurs2

* find any client that became active during this period (need this for reopens)
Select ;
   ai_activ.tc_id, ;
   hold2.anonymous ;
   FROM ;
   ai_activ, ;
   statvalu, ;
   hold2     ;
   WHERE ;
   ai_activ.Status    = statvalu.Code ;
   AND ;
   ai_activ.tc_id = hold2.tc_id ;
   AND statvalu.incare ;
   AND ;
   ai_activ.effect_dt Between m.Date_from And m.Date_to     ;
   GROUP By ;
   ai_activ.tc_id ;
   INTO Cursor ;
   tcurs3

* now, let's get new clients for this period
Select * ;
   FROM ;
   hold2 ;
   WHERE ;
   start_dt Between m.Date_from And m.Date_to ;
   AND ;
   tc_id + Dtos(start_dt) In ;
   (Select tc_id + Min(Dtos(start_dt)) ;
   FROM hold2;
   WHERE start_dt Between m.Date_from And m.Date_to ;
   GROUP By ;
   tc_id) ;
   GROUP By tc_id ;
   INTO Cursor CliNew


Index On tc_id Tag tc_id
Set Order To Tag tc_id

* total new clients
Select ;
   COUNT(*)                             As tot, ;
   SUM(Iif(anonymous,1,0))            As totanon, ;
   SUM(Iif(Upper(hhead)='Y',1,0))     As TotHHead, ;
   SUM(Iif(Upper(dchild)='Y',1,0))    As TotDChild ;
   FROM ;
   CliNew ;
   INTO Cursor ;
   CliNewTo

* jss, 3/2000, for detail report, add following cursor
If _Tally=0
   Select ;
      '02'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total New Clients this Period',60)                                  As column2, ;
      0000                                                                     As column3, ;
      PADR('None',75)                                                         As column4, ;
      PADR('None',20)                                                         As column5, ;
      {}                                                                        As column6, ;
      SPACE(5)                                                                  As column7, ;
      {}                                                                        As column8  ;
      FROM ;
      ai_clien ;
      GROUP By column0 ;
      INTO Cursor  ;
      tempcols

Else
   Select ;
      '02'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total New Clients this Period',60)                                  As column2, ;
      CliNewTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      CliNew, CliNewTo, ai_clien, cli_cur ;
      WHERE ;
      CliNew.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      ai_clien.id_no ;
      INTO Cursor  ;
      tempcols

Endif

Select aiaggdet
Appe From (Dbf("tempcols"))
Use In tempcols

* those that were active at beginning of period
Select;
   tc_id ,;
   anonymous ;
   FROM ;
   tcurs1 ;
   WHERE ;
   active ;
   GROUP By ;
   tc_id ;
   INTO Cursor ;
   tBegActiv

* jss, 4/25/2000, if client is not found in either begintak or begenrol, exclude from agency level
*                 beginning active total
* jss, 7/13/2000, if running for all programs/clients, use tbegactiv as begactiv, else filter with begintak,begenrol

If Empty(LCProg)
   Select * From tBegActiv Into Cursor BegActiv
Else
   Select * ;
      FROM ;
      tBegActiv ;
      WHERE ;
      tc_id In (Select tc_id From BegIntak) Or ;
      tc_id In (Select tc_id From BegEnrol) ;
      INTO Cursor ;
      BegActiv
Endif

* total active beginners
Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   BegActiv ;
   INTO Cursor ;
   BegActTo

* jss, 3/2000, for detail report, add following cursor
If _Tally=0
   Select ;
      '01'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Active Clients at Period Start',60)                            As column2, ;
      0000                                                                     As column3, ;
      PADR('None',75)                                                         As column4, ;
      PADR('None',20)                                                         As column5, ;
      {}                                                                        As column6, ;
      SPACE(5)                                                                  As column7, ;
      {}                                                                        As column8  ;
      FROM ;
      ai_clien ;
      GROUP By column0 ;
      INTO Cursor  ;
      tempcols

Else
   Select ;
      '01'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Active Clients at Period Start',60)                         As column2, ;
      BegActTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      BegActiv, BegActTo, ai_clien, cli_cur ;
      WHERE ;
      BegActiv.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      ai_clien.id_no ;
      INTO Cursor  ;
      tempcols

Endif

Select aiaggdet
Appe From (Dbf("tempcols"))
Use In tempcols

* those that were active at end of period
Select ;
   tc_id ,;
   anonymous ;
   FROM ;
   tcurs2 ;
   WHERE ;
   active ;
   GROUP By ;
   tc_id ;
   INTO Cursor ;
   tEndActiv

* jss, 7/13/2000, if all, no further filter; if by program or report group, filter by begintak,begenrol
If Empty(LCProg)
   Select * From tEndActiv Into Cursor EndActiv
Else
   Select * ;
      FROM ;
      tEndActiv ;
      WHERE ;
      tc_id In (Select tc_id From EndIntak) Or ;
      tc_id In (Select tc_id From EndEnrol) ;
      INTO Cursor ;
      EndActiv
Endif

Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   EndActiv ;
   INTO Cursor ;
   EndActTo

* jss, 3/2000, for detail report, add following cursor
If _Tally=0
   Select ;
      '06'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Active Clients at Period End',60)                            As column2, ;
      0000                                                                     As column3, ;
      PADR('None',75)                                                         As column4, ;
      PADR('None',20)                                                         As column5, ;
      {}                                                                        As column6, ;
      SPACE(5)                                                                  As column7, ;
      {}                                                                        As column8  ;
      FROM ;
      ai_clien ;
      GROUP By column0 ;
      INTO Cursor  ;
      tempcols

Else
   Select ;
      '06'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Active Clients at Period End',60)                            As column2, ;
      EndActTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      EndActiv, EndActTo, ai_clien, cli_cur ;
      WHERE ;
      EndActiv.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      ai_clien.id_no ;
      INTO Cursor  ;
      tempcols

Endif

Select aiaggdet
Appe From (Dbf("tempcols"))
Use In tempcols

* those that were inactive, and became active during period are REOPENS
* jss, 10/11/00: add UNION code to catch this situation: client closed at period start, reopened, then
*               closed during period...

Select ;
   tcurs1.tc_id, ;
   hold2.anonymous As anonymous ;
   FROM ;
   tcurs1, ;
   tcurs3, ;
   hold2   ;
   WHERE ;
   !tcurs1.Active              And ;
   tcurs1.tc_id = tcurs3.tc_id And ;
   tcurs1.tc_id=hold2.tc_id ;
   UNION ;
   SELECT ;
   tcurs1.tc_id, ;
   hold2.anonymous As anonymous ;
   FROM ;
   tcurs1, ;
   hold2   ;
   WHERE ;
   tcurs1.tc_id=hold2.tc_id And ;
   !tcurs1.Active And ;
   tcurs1.tc_id In ;
   (Select tc_id From cldurper) ;
   INTO Cursor ;
   tReopened

* 7/13/2000, jss, if program selected, include program reopens in agency reopen count
If Empty(LCProg)
   Select * From tReopened Into Cursor Reopened
Else
   Select Distinct ;
      tc_id, anonymous ;
      FROM ;
      ReOpen ;
      WHERE ;
      tc_id In (Select tc_id From EndActiv) ;
      INTO Cursor ;
      Reopened
Endif

Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   Reopened ;
   INTO Cursor ;
   ReopTota

* jss, 3/2000, for detail report, add following cursor
If _Tally=0
   Select ;
      '04'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Reopened Cases this Period',60)                               As column2, ;
      0000                                                                     As column3, ;
      PADR('None',75)                                                         As column4, ;
      PADR('None',20)                                                         As column5, ;
      {}                                                                        As column6, ;
      SPACE(5)                                                                  As column7, ;
      {}                                                                        As column8  ;
      FROM ;
      ai_clien ;
      GROUP By column0 ;
      INTO Cursor  ;
      tempcols

Else
   Select ;
      '04'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Reopened Cases this Period',60)                               As column2, ;
      ReopTota.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      Reopened, ReopTota, ai_clien, cli_cur ;
      WHERE ;
      Reopened.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      ai_clien.id_no ;
      INTO Cursor  ;
      tempcols

Endif

Select aiaggdet
Appe From (Dbf("tempcols"))
Use In tempcols

* 12/99, jss, add new cursor, allactiv, that represents anybody activ at some point in period
* 4/00, jss, add another cursor into union: EndActiv, which will account for clients already in agency, newly enrolled in program
* 8/31/00, jss, add in reopened clients, as they could be closed before period end, effectively excluding them from group of active sometime in period
Select ;
   tc_id ;
   FROM ;
   CliNew ;
   UNION ;
   SELECT ;
   tc_id ;
   FROM ;
   BegActiv ;
   UNION ;
   SELECT ;
   tc_id ;
   FROM ;
   Reopened ;
   UNION ;
   SELECT ;
   tc_id ;
   FROM ;
   EndActiv ;
   INTO Cursor ;
   AllActiv

Index On tc_id Tag tc_id

* all tc_id's closed in period
Select ;
   tc_id, anonymous ;
   FROM ;
   cliclosed ;
   WHERE ;
   effect_dt Between m.Date_from And m.Date_to ;
   GROUP By ;
   tc_id ;
   INTO Cursor ;
   tClosPer

* jss, 7/13/2000, if all, no further filter; if by program, closed are those lost from begactiv to endactiv
If Empty(LCProg)
   Select * From  tClosPer Into Cursor ClosPer
Else
   Select * ;
      FROM ;
      BegActiv ;
      WHERE ;
      tc_id Not In (Select tc_id From EndActiv) ;
      INTO Cursor ;
      ClosPer
Endif

* total closed in period
Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   ClosPer ;
   INTO Cursor ;
   ClosPeTo

* jss, 3/2000, for detail report, add following cursor
If _Tally=0
   Select ;
      '05'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Cases Closed this Period',60)                                  As column2, ;
      0000                                                                     As column3, ;
      PADR('None',75)                                                         As column4, ;
      PADR('None',20)                                                         As column5, ;
      {}                                                                        As column6, ;
      SPACE(5)                                                                  As column7, ;
      {}                                                                        As column8  ;
      FROM ;
      ai_clien ;
      GROUP By column0 ;
      INTO Cursor  ;
      tempcols

Else
   Select ;
      '05'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Cases Closed this Period',60)                                As column2, ;
      ClosPeTo.tot                                                              As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      ClosPer, ClosPeTo, ai_clien, cli_cur ;
      WHERE ;
      ClosPer.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      ai_clien.id_no ;
      INTO Cursor  ;
      tempcols

Endif

Select aiaggdet
Appe From (Dbf("tempcols"))
Use In tempcols

* 4/25/2000, jss, now, grab anybody who is newly activ, but not in the other buckets because they
*            have become enrolled in the program this period, but were already activ in the agency
*            at period start (thus, they are not new in agency)
* 7/13/2000, jss, add reopened check

* create a union of begactiv,clinew,reopened for check below
Select tc_id From BegActiv ;
   UNION ;
   SELECT tc_id From CliNew ;
   UNION ;
   SELECT tc_id From Reopened ;
   INTO Cursor ;
   ChkActiv

Select Distinct;
   tc_id, anonymous ;
   FROM ;
   EndActiv ;
   WHERE ;
   tc_id Not In (Select tc_id From ChkActiv) ;
   INTO Cursor ;
   NewActiv

* total active beginners
Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   NewActiv ;
   INTO Cursor ;
   NewActTo

* jss, 3/2000, for detail report, add following cursor
If _Tally=0
   Select ;
      '03'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Newly Enrolled Active Clients this Period',60)               As column2, ;
      0000                                                                     As column3, ;
      PADR('None',75)                                                         As column4, ;
      PADR('None',20)                                                         As column5, ;
      {}                                                                        As column6, ;
      SPACE(5)                                                                  As column7, ;
      {}                                                                        As column8  ;
      FROM ;
      ai_clien ;
      GROUP By column0 ;
      INTO Cursor  ;
      tempcols

Else
   Select ;
      '03'                                                                     As column0, ;
      PADR('Agency Level Summary Information',50)                              As column1, ;
      PADR('Total Newly Enrolled Active Clients this Period',60)               As column2, ;
      NewActTo.tot                                                            As column3, ;
      PADR(Alltrim(cli_cur.last_name) + ', ' + Alltrim(cli_cur.first_name),75)   As column4, ;
      ai_clien.id_no                                                            As column5, ;
      DTOC(cli_cur.dob)                                                         As column6, ;
      ai_clien.int_prog                                                         As column7, ;
      DTOC(ai_clien.placed_dt)                                                As column8  ;
      FROM ;
      NewActiv, NewActTo, ai_clien, cli_cur ;
      WHERE ;
      NewActiv.tc_id = ai_clien.tc_id ;
      AND ;
      ai_clien.client_id = cli_cur.client_id ;
      GROUP By ;
      ai_clien.id_no ;
      INTO Cursor  ;
      tempcols

Endif

Select aiaggdet
Appe From (Dbf("tempcols"))
Use In tempcols


* break down closes (beginning active)
Select ;
   BegActiv.tc_id ,;
   BegActiv.anonymous ;
   FROM ;
   BegActiv, ClosPer ;
   WHERE ;
   BegActiv.tc_id=ClosPer.tc_id ;
   GROUP By ;
   BegActiv.tc_id ;
   INTO Cursor ;
   BaClose

* total of beginning active closes
Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   BaClose ;
   INTO Cursor ;
   BaClosTo

* break down closes (reopens)
Select ;
   Reopened.tc_id ,;
   Reopened.anonymous ;
   FROM ;
   Reopened, ClosPer ;
   WHERE ;
   Reopened.tc_id=ClosPer.tc_id ;
   GROUP By ;
   Reopened.tc_id ;
   INTO Cursor ;
   ReClose

* total of beginning active closes
Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   ReClose ;
   INTO Cursor ;
   ReClosTo

* break down closes (starts)
Select ;
   CliNew.tc_id ,;
   CliNew.anonymous ;
   FROM ;
   CliNew, ClosPer ;
   WHERE ;
   CliNew.tc_id=ClosPer.tc_id ;
   GROUP By ;
   CliNew.tc_id ;
   INTO Cursor ;
   CnClose

* total of beginning active closes
Select ;
   COUNT(*)                  As tot, ;
   SUM(Iif(anonymous,1,0)) As totanon ;
   FROM ;
   CnClose ;
   INTO Cursor ;
   CnClosTo

If Used("hold1")
   Use In hold1
Endif
Use Dbf("hold2") In 0 Again Alias hold1
Select hold1
Index On tc_id Tag tc_id
Index On anonymous Tag anonymous
Use In hold2

*- setup for adding tb status to hold1
=OpenFile("test_res", "code")
=OpenFile("tbstatus", "tc_id")
Set Filter To tbstatus.effect_dt <= m.Date_to
Set Relation To ppdres Into test_res

*- setup for adding hiv status to hold1
=OpenFile("hstat", "code")
=OpenFile("hivstat", "tc_id")
Set Filter To hivstat.effect_dt <= m.Date_to
Set Relation To hivstatus Into hstat

*=OpenFile("county", "statecode")
=OpenFile("zipcode", "countyfips")
*- set relations for hivstatus and tbstatus, et al.
Select hold1
Set Relation To tc_id         Into tbstatus           ,;
   tc_id         Into hivstat            ,;
   Prog_id+tc_id Into newprog            ,;
   Prog_id+tc_id Into AllProg            ,;
   tc_id         Into CliNew             ,;
   tc_id         Into AllActiv           ,;
   tc_id         Into cliclosed          ,;
   fips_code     Into zipcode Additive
*                state+code    INTO county    ADDITIVE


Repl All ppd_pos    With test_res.ppd_pos        ,;
   hiv_pos    With hstat.hiv_pos           ,;
   hivstatus  With hstat.Descript          ,;
   anergic    With (tbstatus.panergic=1)   ,;
   county     With Left(Proper(zipcode.countyname),25) ,;
   end_dt     With cliclosed.effect_dt     ,;
   ActivProg  With Found('AllProg')        ,;
   ActivAgen  With Found('AllActiv')       ,;
   newagency  With Found('CliNew')         ,;
   newprog    With Found('NewProg')

*         county     WITH PROPER(county.descript)

* jss, 1/15/02, add code to handle problem with county='999' (county table has '999' plus BLANK state, actual data has actual state code)
*REPL ALL county WITH Padr('Other',25) FOR code = '999'
Repl All county With Padr('Other',25) For fips_code = '99999'

*- cleanup
Use In hstat
Use In hivstat
Use In test_res
Use In tbstatus
Use In cliclosed
*USE IN county

**VT 04/08/2008 Dev Tick 4222
*Use IN Zipcode

=OpenFile("prog2sc", "prog_id")
=OpenFile("ai_prog", "tc_id")
Set Relation To Program Into prog2sc

Select hold1
Scan
   Select ai_prog
   Locate For ai_prog.tc_id = hold1.tc_id And;
      prog2sc.serv_cat = "00001" And ;
      ai_prog.start_dt <= m.Date_to  And;
      (Empty(ai_prog.end_dt) Or (ai_prog.end_dt > m.Date_to))

   Repl hold1.openincm With Found()
Endscan

*!*oApp.msg2user("OFF")

Use In ai_prog

* add for vfp version with all vars we need
**VT 08/12/2008 Dev Tick 4622 Add Upper
Select aiaggdet.*, ;
   Upper(aiaggdet.column4) As sort_name, ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   From aiaggdet ;
   Into Cursor aiaggdet2 ;
   order By 2,1, 10

*Order by aiaggdet.column1, aiaggdet.column0, aiaggdet.column4

Select hold1

Return .T.

**********************************************************************
Procedure MainAggDet
*PARAMETER nClick, nTimes
**********************************************************************
* this is the client detail of the Totals categories from the main AIDS Institute aggregate report
**********************************************************************
*DIMENSION aFiles_Open[1]
*DO Save_Env2 WITH aFiles_Open

Select aiaggdet2
Select a.*, gcagencyname As agencyname, oApp.gcversion As Version, Dtoc(oApp.gdverdate) As verdate ;
   FROM aiaggdet2 As a ;
   INTO Cursor tmp

*!*
*!* following added 05/04/2009
*!* for CR2008/Visual Advantage Processing
*!* jim power
*!*

Copy To oapp.gcpath2temp+"aggregate_client_listing.dbf"

*!*   Declare Integer ShellExecute In shell32.Dll ;
*!*      INTEGER hndWin, ;
*!*      STRING caction, ;
*!*      STRING cFilename, ;
*!*      STRING cParms, ;
*!*      STRING cDir, ;
*!*      INTEGER nShowWin

*!*   LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*   LcAction = "open"
*!*   Lcparms = "aggregate_client_list.rpt"
*!*   Lcdir = "i:\ursver6\airs_crreports\"
*!*   ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

oApp.display_crystal_reports("aggregate_client_list.rpt")

*!* Lines above replaces the following lines
*!* jim power  05/04/2009

*!*   gcRptName = 'rpt_aggdet'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*      Report Form rpt_aggdet To Printer Prompt Noconsole NODIALOG
*!*   CASE lPrev = .t.     &&Preview
*!*      oApp.rpt_print(5, .t., 1, 'rpt_aggdet', 1, 2)
*!*   EndCase

*DO Rest_Env2 WITH aFiles_Open
Return
**********************************************************************
Procedure MainAggRpt

Parameter cActivNew
**********************************************************************
* this is the main AIDS Institute aggregate report
* the different aggregates for the clients are done and reported here
**********************************************************************

cDemoTitle='Main Aggregate Report - '
If cActivNew
   cCumTitle='Active Clients Demographics'
   cWhereCli='Hold1.ActivProg'
   cWCDesc='Active'
Else
   cCumTitle='New Clients Demographics'
   cWhereCli='Hold1.NewProg'
   cWCDesc='New'
Endif

n1=Seconds()

* jss, 4/20/05, define m.label2 here
m.label2=Space(20)
* jss, 4/27/05, define m.label3 here
m.label3=Space(25)
* jss, 4/21/05, define counter m.rec_no
m.rec_no=0

* in order for us to get the unduplicated number of clients we should use
* the DISTINCT clause and get rid of Prog_ID and ProgrDesc columns.

Select ;
   DIST tc_id, openincm, anonymous, ;
   hhead, dchild, hiv_pos, ppd_pos, ;
   anergic, newprog, newagency, end_dt, start_dt ;
   FROM hold1 ;
   INTO Cursor Hold10

* get inital counts
* these are the counts that appear in the summary section of the report
* 8/98, jss, add CloseAnon, reopencnt, reopenanon
* 9/98, and reopInAnon

Select ;
   SUM(Iif(openincm,1,0))                                            As NewCMcnt  ,;
   SUM(Iif(hiv_pos And ppd_pos,1,0))                                 As TOTHIVPPD ,;
   SUM(Iif(newprog And hiv_pos And ppd_pos,1,0))                     As NewHIVPPD ,;
   SUM(Iif(anergic,1,0))                                             As ppdanergic,;
   SUM(Iif(newprog And Upper(hhead)="Y",1,0))                        As NewHHcnt  ,;
   SUM(Iif(newprog And Upper(dchild)="Y",1,0))                       As NewDccnt   ;
   FROM ;
   hold10 ;
   INTO Cursor ;
   hold2

*- create cursor for reporting
* jss, 4/20/05, add new column label2 to aiaggrpt cursor
* jss, 4/27/05, add new column label3 to aiaggrpt cursor
* jss, 4/21/05, add new column rec_no to aiaggrpt cursor
Create Cursor aiaggrpt (Prog_id C(5), progrdesc C(30), Group C(60), Label C(80), label2 C(20), label3 C(25), Count N(10,0), Header l(1), notcount l(1), rec_no N(6), count2 N(10,0))

* these are the counts that appear in the summary section of the report
Select   Prog_id, ;
   00000 As BegIntake , ;
   00000 As BegEnroll , ;
   00000 As BegCnt      , ;
   00000 As NewIntake , ;
   00000 As NewEnroll , ;
   00000 As NewCnt      , ;
   00000 As ReopenCnt , ;
   00000 As ReopInCnt , ;
   00000 As CloseEnrol, ;
   00000 As CloseIntak, ;
   00000 As CloseInPer, ;
   00000 As ConvIntake, ;
   00000 As EndIntake , ;
   00000 As EndEnroll , ;
   00000 As EndCnt    , ;
   00000 As BegIntAnon, ;
   00000 As BegEnrAnon, ;
   00000 As BegCntAnon, ;
   00000 As NewIntAnon, ;
   00000 As NewEnrAnon, ;
   00000 As NewCntAnon, ;
   00000 As ReopenAnon, ;
   00000 As ReopInAnon, ;
   00000 As ClosEnrAn , ;
   00000 As ClosIntAn , ;
   00000 As CloseAnon , ;
   00000 As ConvAnon  , ;
   00000 As EndIntAnon, ;
   00000 As EndEnrAnon, ;
   00000 As EndCntAnon, ;
   SUM(Iif(openincm,1,0))                              As NewCMcnt  ,;
   SUM(Iif(hiv_pos And ppd_pos,1,0))                   As TOTHIVPPD ,;
   SUM(Iif(newprog And hiv_pos And ppd_pos,1,0))       As NewHIVPPD ,;
   SUM(Iif(anergic,1,0))                               As ppdanergic,;
   SUM(Iif(newprog And Upper(hhead)="Y",1,0))          As NewHHcnt  ,;
   SUM(Iif(newprog And Upper(dchild)="Y",1,0))         As NewDccnt  ;
   FROM ;
   hold1 ;
   GROUP By Prog_id ;
   INTO Cursor ;
   hold3 Readwrite

*   holdprog

Index On Prog_id Tag Prog_id

*=ReOpenCur("holdprog", "hold3")
*SET ORDER TO Prog_ID

* total the counting cursors
Sele hold3
Set Rela To Prog_id Into BegEnrTo, ;
   Prog_id Into BegIntTo, ;
   Prog_id Into NewIntTo, ;
   Prog_id Into NewEnrTo, ;
   Prog_id Into ReopenTo, ;
   Prog_id Into ReopInTo, ;
   Prog_id Into ClosEnTo, ;
   Prog_id Into ClosInTo, ;
   Prog_id Into EndEnrTo, ;
   Prog_id Into EndIntTo, ;
   Prog_id Into ConverTo  ;

Replace All ;
   BegIntake    With BegIntTo.tot, ;
   BegEnroll    With BegEnrTo.tot, ;
   BegCnt      With (BegIntTo.tot + BegEnrTo.tot), ;
   NewIntake   With NewIntTo.tot, ;
   NewEnroll   With NewEnrTo.tot, ;
   NewCnt      With (NewIntTo.tot + NewEnrTo.tot), ;
   ReopenCnt   With ReopenTo.tot, ;
   ReopInCnt   With ReopInTo.tot, ;
   CloseEnrol  With ClosEnTo.tot, ;
   CloseIntak  With ClosInTo.tot, ;
   CloseInPer  With (ClosEnTo.tot + ClosInTo.tot), ;
   ConvIntake  With ConverTo.tot, ;
   EndIntake   With EndIntTo.tot, ;
   EndEnroll   With EndEnrTo.tot, ;
   EndCnt      With (EndIntTo.tot + EndEnrTo.tot), ;
   BegIntAnon  With BegIntTo.totanon, ;
   BegEnrAnon  With BegEnrTo.totanon, ;
   BegCntAnon  With (BegIntTo.totanon + BegEnrTo.totanon), ;
   NewIntAnon  With NewIntTo.totanon, ;
   NewEnrAnon  With NewEnrTo.totanon, ;
   NewCntAnon  With (NewIntTo.totanon + NewEnrTo.totanon), ;
   ReopenAnon  With ReopenTo.totanon, ;
   ReopInAnon  With ReopInTo.totanon, ;
   ClosEnrAn   With ClosEnTo.totanon, ;
   ClosIntAn   With ClosInTo.totanon, ;
   CloseAnon   With (ClosEnTo.totanon + ClosInTo.totanon), ;
   ConvAnon    With ConverTo.totanon, ;
   EndIntAnon  With EndIntTo.totanon, ;
   EndEnrAnon  With EndEnrTo.totanon, ;
   EndCntAnon  With (EndIntTo.totanon + EndEnrTo.totanon)

*********************************************
* Family-Centered/Collateral Case Management:

If Used("FamCollSum")
   Use In FamCollSum
Endif

Create Cursor FamCollSum (Prog_id C(5), progrdesc C(30), Descript C(60), Count N(5), notcount l(1))

* 12/98, make the counts go in this unduplicated order (each of the 5 categories included in GROUP total):
*         1) and 2) kids and adolescents 3) mates 4) other family members 5) other collaterals

* this cursor holds all collaterals receiving services of clients receiving services this period
Select Distinct;
   hold1.Prog_id, ;
   hold1.progrdesc, ;
   hold1.tc_id    , ;
   ClientFam.client_id ,;
   ClientFam.dob, ;
   ClientFam.Age, ;
   Ai_Famil.Relation ;
   FROM ;
   hold1, Ai_Enc, Ai_Colen, client ClientFam, Ai_Famil ;
   WHERE ;
   BETW(Ai_Enc.act_dt,m.Date_from,m.Date_to) ;
   AND   hold1.tc_id        = Ai_Enc.tc_id ;
   AND hold1.tc_id        = Ai_Famil.tc_id ;
   AND Ai_Enc.Act_id      = Ai_Colen.Act_id ;
   AND Ai_Colen.client_id = ClientFam.client_id ;
   AND Ai_Colen.client_id = Ai_Famil.client_id ;
   INTO Cursor ;
   tTemp1

***VT 10/25/2002 Collat can't works with cli_cur !!!!!!!!!!!!!!!!!!!
*cli_cur ClientFam

Use In Ai_Enc
Use In Ai_Colen

* next cursor sums by category for collaterals receiving services in period
Select ;
   tTemp1.Prog_id, ;
   tTemp1.progrdesc, ;
   SUM(Iif(!Empty(tTemp1.dob) And Between(tTemp1.Age,0,12),1,0))                             As Age0_12  ,;
   SUM(Iif(!Empty(tTemp1.dob) And Between(tTemp1.Age,13,19),1,0))                         As Age13_19 ,;
   SUM(Iif(Relat.Mate                      And (Empty(tTemp1.dob) Or tTemp1.Age>19),1,0)) As mates    ,;
   SUM(Iif(Relat.fam_memb  And !Relat.Mate And (Empty(tTemp1.dob) Or tTemp1.Age>19),1,0)) As FamMemb  ,;
   SUM(Iif(!Relat.fam_memb And !Relat.Mate And (Empty(tTemp1.dob) Or tTemp1.Age>19),1,0)) As Other     ;
   FROM ;
   tTemp1, Relat ;
   WHERE ;
   tTemp1.Relation = Relat.Code ;
   INTO Cursor ;
   tTemp ;
   GROUP By 1

* now, get all possible distinct collaterals by program
Select Distinct ;
   hold1.Prog_id       ,;
   hold1.tc_id         ,;
   Ai_Famil.client_id  ,;
   client.dob          ,;
   client.Age          ,;
   Ai_Famil.Relation    ;
   FROM ;
   hold1, Ai_Famil, client ;
   WHERE ;
   hold1.tc_id=Ai_Famil.tc_id ;
   AND ;
   Ai_Famil.client_id=client.client_id ;
   INTO Cursor ;
   CollTemp

Use In Ai_Famil

* count the different categories of all possible collaterals by program
Select ;
   CollTemp.Prog_id, ;
   SUM(Iif(!Empty(CollTemp.dob) And Between(CollTemp.Age,0,12),1,0))                                        As Age0_12 ,;
   SUM(Iif(!Empty(CollTemp.dob) And Between(CollTemp.Age,13,19),1,0))                                     As Age13_19,;
   SUM(Iif(Relat.Mate                      And (Empty(CollTemp.dob) Or CollTemp.Age>19),1,0)) As mates   ,;
   SUM(Iif(Relat.fam_memb  And !Relat.Mate And (Empty(CollTemp.dob) Or CollTemp.Age>19),1,0)) As FamMemb ,;
   SUM(Iif(!Relat.fam_memb And !Relat.Mate And (Empty(CollTemp.dob) Or CollTemp.Age>19),1,0)) As Other    ;
   FROM ;
   CollTemp, Relat ;
   WHERE ;
   CollTemp.Relation = Relat.Code ;
   INTO Cursor CollTem2 ;
   GROUP By 1

Inde On Prog_id Tag Prog_id

Select tTemp
* relate to the total collateral cursor on program
Set Rela To Prog_id Into CollTem2

Scan
   Scatter Memvar
   For i = 3 To Fcount()
      Do Case
         Case Field(i) = "AGE0_12"
            cDescript = Padr("Children (0-12)",35)          + "(of " + Transform(CollTem2.Age0_12,'99999') + ")"
            lNotCount = .F.
         Case Field(i) = "AGE13_19"
            cDescript = Padr("Adolescents (13-19)",35)      + "(of " + Transform(CollTem2.Age13_19,'99999') + ")"
            lNotCount = .F.
         Case Field(i) = "MATES"
            cDescript = Padr("Significant Others/Mates",35) + "(of " + Transform(CollTem2.mates,'99999') + ")"
            lNotCount = .F.
         Case Field(i) = "FAMMEMB"
            cDescript = Padr("Other Family Members",35)     + "(of " + Transform(CollTem2.FamMemb,'99999') + ")"
            lNotCount = .F.
         Case Field(i) = "OTHER"
            cDescript = Padr("Other Collaterals",35)        + "(of " + Transform(CollTem2.Other,'99999') + ")"
            lNotCount = .F.
      Endcase
      nCount = Eval(Field(i))
      Insert Into FamCollSum Values (m.Prog_id, m.progrdesc, cDescript, nCount, lNotCount)
   Next
Endscan
If Used('tTemp')
   Use In tTemp
Endif
If Used('CollTemp')
   Use In CollTemp
Endif

*************************************************************

** DG 01/23/97 Start of the Loop
Select Dist Prog_id, progrdesc ;
   FROM hold1 ;
   INTO Cursor tProgram ;
   ORDER By 1

&&&  jss, 10/8/2000, moved code from inside scan out here to save time

**VT 02/12/2009 Dev Tick 4829 Changed prg_clos to new look up table closcode
Select ;
   ClosEnro.Prog_id      As Prog_id, ;
   Prg_Clos.Descript     As Label,   ;
   COUNT(ClosEnro.tc_id) As Count    ;
   FROM ;
   closcode Prg_Clos, ClosEnro ;
   WHERE ;
   ClosEnro.reason  = Prg_Clos.Code     ;
   GROUP By ;
   ClosEnro.Prog_id, ;
   Prg_Clos.Code ;
   INTO Cursor ;
   tCodeEnro


* now, look in ai_activ for those tc_ids in this program with no reason code in ai_prog
* jss, 9/11/00, use TIME24() instead of just am_pm + time to handle problem with 12pm-12:59pm sorting later than 1:00 pm
* jss, 10/10/00, make "in" instead of "=" to subquery, add "group by" to subquery, remove part of "where"
Select ;
   ClosEnro.Prog_id      As Prog_id, ;
   ClosCode.Descript     As Label,   ;
   COUNT(ClosEnro.tc_id) As Count    ;
   FROM ;
   ClosCode, ClosEnro, Ai_Activ, StatValu ;
   WHERE ;
   EMPTY(ClosEnro.reason)                  And ;
   ClosEnro.tc_id  = ai_activ.tc_id       And ;
   ai_activ.Status = statvalu.Code          And ;
   statvalu.tc     = gcTC                 And ;
   statvalu.Type   = 'ACTIV'              And ;
   !statvalu.incare                       And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+oApp.Time24(ai_activ.Time, ai_activ.am_pm) ;
   IN (Select ;
   t1.tc_id + Max(Dtos(t1.effect_dt)+oApp.Time24(t1.Time, t1.am_pm)) ;
   FROM ;
   ai_activ t1 ;
   WHERE ;
   t1.effect_dt <= m.Date_to ;
   GROUP By ;
   t1.tc_id)      ;
   AND ;
   ClosCode.Code   = ai_activ.close_code           ;
   GROUP By ;
   ClosEnro.Prog_id, ;
   ClosCode.Code ;
   INTO Cursor ;
   tCodeEnro1

* now, get same info for closed intakes for this program
Select ;
   ClosInt.Prog_id, ;
   ClosCode.Descript     As Label,   ;
   COUNT(ClosInt.tc_id)  As Count    ;
   FROM ;
   ClosCode, ClosInt, Ai_Activ, StatValu ;
   WHERE ;
   ClosInt.tc_id   = ai_activ.tc_id       And ;
   ai_activ.Status = statvalu.Code          And ;
   statvalu.tc     = gcTC                 And ;
   statvalu.Type   = 'ACTIV'              And ;
   !statvalu.incare                       And ;
   ai_activ.tc_id + Dtos(ai_activ.effect_dt)+am_pm +Time ;
   IN (Select ;
   t1.tc_id + Max(Dtos(effect_dt)+am_pm+Time) ;
   FROM ;
   ai_activ t1 ;
   WHERE ;
   t1.effect_dt <= m.Date_to ;
   GROUP By ;
   t1.tc_id)      ;
   AND ;
   ClosCode.Code   = ai_activ.close_code           ;
   GROUP By ;
   ClosInt.Prog_id, ;
   ClosCode.Code ;
   INTO Cursor ;
   tCodeInt

Use In ai_activ
Use In statvalu

* combine them all
Select * From tCodeEnro    ;
   UNION All ;
   SELECT * From tCodeEnro1    ;
   UNION All ;
   SELECT * From tCodeInt       ;
   INTO Cursor tCodeAll


Select * ;
   FROM ;
   tCodeAll ;
   INTO Cursor ;
   tCodeAll1

*** jss, 10/26/00, new code added for CDC-defined AIDS

Select ;
   Prog_id, ;
   COUNT(tc_id) As cdcaidscnt;
   FROM ;
   hold1 ;
   WHERE ;
   &cWhereCli And CDC_AID1(tc_id) ;
   GROUP By ;
   Prog_id ;
   INTO Cursor ;
   cdc_aids

Index On Prog_id Tag cdc_aids

Store ' ' To m.label2,m.label3
Select tProgram
Scan All
   Scatter Memvar
   **************************************************
   *- Aggregate by Case closure reasons *************
   **************************************************

   * sum them
   Select ;
      label, ;
      SUM(Count) As Count ;
      FROM ;
      tCodeAll1 ;
      WHERE m.Prog_id = tCodeAll1.Prog_id ;
      GROUP By ;
      label ;
      INTO Cursor ;
      CodeAll

   m.group = 'Closed Clients by Reason*'
   m.header = .T.
   mclosreas=0
   Scan
      Scatter Memvar
      mclosreas=mclosreas+m.count
      Store ' ' To m.label2,m.label3
      m.count2=0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endscan

   * now, add in "Not Entered" when no reason is present
   mclenrtot=Iif(Seek(m.Prog_id,'closento'),ClosEnTo.tot,0)
   mclinttot=Iif(Seek(m.Prog_id,'closinto'),ClosInTo.tot,0)
   m.count = (mclenrtot + mclinttot) - mclosreas
   * jss, 4/20/05, only print this line if it is non-zero
   If m.count>0
      m.label = "Not Entered"
      Store ' ' To m.label2,m.label3
      m.count2=0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
   Endif

   ********************************************
   *- Aggregate by housing type ***************
   ********************************************

   * 12/98, jss, eliminate makesection routine
   m.group = cWCDesc + " Clients Housing Status*"
   m.header = .T.
   =OpenFile("Housing", "code")
   * scan gives us the counts for each code in the housing file for this program
   Store ' ' To m.label2,m.label3
   m.count2=0
   Scan
      m.label = Descript
      Select hold1
      Count To m.count For &cWhereCli And hold1.housing=housing.Code And hold1.Prog_id=m.Prog_id
      If m.count>0
         * jss, 4/20/05, only print this line if it is non-zero
         m.rec_no=m.rec_no+1
         Insert Into aiaggrpt From Memvar
         m.header = .F.
      Endif
      Select housing
   Endscan

   * this code handles "Not Entered" scenario (blank hold1.housing field)

   m.label = 'Not Entered'
   Select hold1
   Set Rela To housing Into housing Additive
   Count To m.count For hold1.Prog_id=m.Prog_id And &cWhereCli And Eof('housing')
   * jss, 4/20/05, only print this line if it is non-zero
   If m.count>0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
   Endif


   * jss, 4/21/05, combine CDC and RW Risk section into one section
   * jss, 5/17/05, add in new field "orderfield"
   Create Cursor combrisk (Descript C(40), rw_code C(2), rw_flag l, cdc_code C(2), cdc_flag l, orderfield C(2))
   Index On Alltrim(Descript) Tag Descript

   =OpenFile("rw_risk", "code")
   =OpenFile("cdc_risk", "code")

   * load in all the cdc_risks
   Scan
      Insert Into combrisk (Descript, rw_code, rw_flag, cdc_code, cdc_flag, orderfield) Values(cdc_risk.Descript, '  ', .F., cdc_risk.Code, .T., '  ')
   Endscan
   Use In cdc_risk

   * now, load in the rw_risks
   Select rw_risk
   Scan
      If Seek(Alltrim(rw_risk.Descript),'combrisk')
         Select combrisk
         Replace rw_code With rw_risk.Code, rw_flag With .T.
      Else
         Insert Into combrisk (Descript, rw_code, rw_flag, cdc_code, cdc_flag, orderfield) Values(rw_risk.Descript, rw_risk.Code, .T., '  ', .F., '  ')
      Endif
      Select rw_risk
   Endscan
   Use In rw_risk

   * jss, 5/17/05, now, load in the orderfield
   Select combrisk
   Scan
      Do Case
         Case Trim(Descript)='MSM and IDU'
            Replace orderfield With '01'
         Case Trim(Descript)='MSM'
            Replace orderfield With '02'
         Case Trim(Descript)='IDU'
            Replace orderfield With '03'
         Case Trim(Descript)='Heterosexual Contact'
            Replace orderfield With '04'
         Case Trim(Descript)='Hemophilia/Coagulation Disorder'
            Replace orderfield With '05'
         Case Trim(Descript)='Blood Product Recipient'
            Replace orderfield With '06'
         Case Trim(Descript)='Mother with or at risk for HIV Infection'
            Replace orderfield With '07'
         Case Trim(Descript)='Perinatal Transmission'
            Replace orderfield With '08'
         Case Trim(Descript)='General Population'
            Replace orderfield With '09'
         Case Trim(Descript)='Undetermined/Unknown'
            Replace orderfield With '10'
         Case Trim(Descript)='Other'
            Replace orderfield With '11'
      Endcase
   Endscan

   Index On orderfield Tag orderfield
   Go Top

   * now, use combrisk to drive report

   Select * ;
      From relhist ;
      Where Date <= m.Date_to ;
      Into Cursor t_relh Readwrite
   *   Into Cursor t_relh1

   Index On tc_id+Str({01/01/2100}-Date) Tag tc_id
   *   =ReOpenCur("t_relh1", "t_relh")
   *   Set Order to tc_id

   Select hold1
   Set Relation To tc_id Into t_relh

   m.group = cWCDesc + " Clients by Risk Category"
   m.header = .T.
   Store ' ' To m.label2,m.label3

   Select combrisk
   Scan
      m.label = combrisk.Descript
      Select hold1
      If combrisk.cdc_flag
         Count To m.count2 For ;
            &cWhereCli .And. ;
            hold1.Prog_id = m.Prog_id And ;
            t_relh.cdc_code = combrisk.cdc_code
      Else
         m.count2=0
      Endif
      If combrisk.rw_flag
         Count To m.count For ;
            &cWhereCli .And. ;
            hold1.Prog_id = m.Prog_id And ;
            t_relh.rw_code = combrisk.rw_code
      Else
         m.count=0
      Endif
      If m.count + m.count2 > 0
         m.rec_no=m.rec_no+1
         Insert Into aiaggrpt From Memvar
         m.header = .F.
      Endif
      Select combrisk
   Endscan

   Use In combrisk

   ******************************************************************
   *- Aggregate By Insurance Statuses From Intake
   ******************************************************************

   m.group = cWCDesc + " Clients by Insurance Status (From Intake)"
   m.header = .T.
   cCode = "  "
   ***
   m.count2=0
   m.label = "Known" + Space(31)
   Select hold1
   Count To m.count For ;
      &cWhereCli .And. ;
      hold1.Prog_id = m.Prog_id And ;
      hold1.insurance = 1

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif
   ***
   m.label = "No Insurance" + Space(23)
   Select hold1
   Count To m.count For ;
      &cWhereCli .And. ;
      hold1.Prog_id = m.Prog_id And ;
      hold1.insurance = 3

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif
   ***
   m.label = "Unknown/Unreported" + Space(18)
   Select hold1
   Count To m.count For ;
      &cWhereCli .And. ;
      hold1.Prog_id = m.Prog_id And ;
      hold1.insurance = 2

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif

   ***
   m.label = "Not Entered" + Space(18)
   Select hold1
   Count To m.count For ;
      &cWhereCli .And. ;
      hold1.Prog_id = m.Prog_id And ;
      (hold1.insurance <> 1 And hold1.insurance <> 2 And hold1.insurance <> 3)
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif

   ******************************************************************
   *- Aggregate by Primary insurance type ***************************
   ******************************************************************
   * get clients in hold1 with a primary insurance status entered in system

   Select ;
      instype.Descript As instype, ;
      COUNT(*) As ins_count ;
      FROM ;
      hold1, insstat, med_prov, instype ;
      WHERE ;
      hold1.Prog_id   = m.Prog_id         And ;
      hold1.client_id = insstat.client_id And ;
      &cWhereCli                         And ;
      Iif(!Empty(insstat.exp_dt), ;
      insstat.exp_dt >= m.Date_to And insstat.effect_dt <= m.Date_to, ;
      insstat.effect_dt <= m.Date_to) And ;
      insstat.prim_sec = 1                And ;
      insstat.prov_id = med_prov.prov_id    And ;
      instype.Code = med_prov.instype       And ;
      insstat.client_id + Dtos(insstat.effect_dt)  ;
      IN (Select Is.client_id + Max(Dtos(effect_dt)) ;
      FROM insstat Is ;
      WHERE ;
      is.prim_sec = 1 And ;
      Iif(!Empty(Is.exp_dt), ;
      is.exp_dt >= m.Date_to And Is.effect_dt <= m.Date_to, ;
      is.effect_dt <= m.Date_to) ;
      GROUP By ;
      is.client_id)      ;
      GROUP By ;
      1 ;
      INTO Cursor ;
      ins_temp

   Index On instype Tag instype

   =OpenFile("instype", "code")

   m.group  = cWCDesc + ' Clients by Primary Insurance Type'
   m.header = .T.
   Store ' ' To m.label2,m.label3
   m.count2=0
   m.countknown=0
   Scan
      m.label = instype.Descript
      If Seek(instype.Descript, 'ins_temp')
         m.count = ins_temp.ins_count
         m.countknown=m.countknown+m.count
         m.rec_no=m.rec_no+1
         Insert Into aiaggrpt From Memvar
         m.header = .F.
      Else
         m.count = 0
      Endif
      * jss, 4/20/05, only print non-zero lineitems, move insert up
      *      INSERT INTO aiaggrpt FROM MEMVAR
      *      m.header = .f.
   Endscan

   * jss, 4/17/05, add   a line for 'known insurance sub-total'
   m.header=.F.
   m.label=' '
   m.label3='Known Insurance Sub-Total'
   m.count=0
   m.count2=m.countknown
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar

   m.label3=' '
   * next select grabs all client_ids entered into insstat; we'll use this result in the next select
   Select ;
      client_id ;
      FROM ;
      insstat ;
      WHERE ;
      Iif(!Empty(insstat.exp_dt), ;
      insstat.exp_dt >= m.Date_to And insstat.effect_dt <= m.Date_to, ;
      insstat.effect_dt <= m.Date_to) And ;
      insstat.prim_sec  = 1             And ;
      insstat.client_id + Dtos(insstat.effect_dt) ;
      IN (Select Is.client_id + Max(Dtos(effect_dt)) ;
      FROM insstat Is ;
      WHERE Is.prim_sec = 1 And ;
      Iif(!Empty(Is.exp_dt), ;
      is.exp_dt >= m.Date_to And Is.effect_dt <= m.Date_to, ;
      is.effect_dt <= m.Date_to) ;
      GROUP By ;
      is.client_id) ;
      INTO Cursor newclien

   * now, create a select counting everything in hold1 that lacks current (active in this period) insurance status data
   * jss, 4/27/05, change 'Not Entered or Expired   ' to 'No or Unknown Insurance  '
   Select ;
      'No/Unknown Insurance     ' As instype,  ;
      COUNT(*)                As ins_count ;
      FROM ;
      hold1 ;
      WHERE ;
      hold1.Prog_id   = m.Prog_id         And ;
      &cWhereCli                       And ;
      hold1.client_id Not In (Select client_id From newclien) ;
      INTO Cursor ;
      ins_tem2 ;
      GROUP By    ;
      1

   * add next 3 lines to insert "Not Entered" record into report cursor
   If _Tally > 0
      m.label = ins_tem2.instype
      m.count = ins_tem2.ins_count
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
   Endif

   * close up cursors now
   Use In ins_temp
   Use In newclien
   Use In ins_tem2
   **************************************************************
   ******************************************************************
   *- Aggregate by Income, Household Size, and Poverty Status
   ******************************************************************

   Select    hold1.client_id, ;
      hold1.is_refus, ;
      hold1.hshld_incm, ;
      hold1.hshld_size ;
      FROM ;
      hold1;
      WHERE ;
      hold1.Prog_id  = m.Prog_id  And ;
      &cWhereCli ;
      INTO Cursor tmp_h1

   * jss, 12/24/03, remove this line from where clause below, replace with "AND" to correct logic
   ***         Iif((address.st <> "AK" or address.st <> "HI"), poverty.st = "US", address.st = poverty.st) and

   * jss, 3/21/05, pov_level field has been increased to 6 digits

   ***VT 04/08/2008 Dev Tick 4222

   *!*      Select Distinct tmp_h1.*, ;
   *!*            poverty.pov_level;
   *!*      From tmp_h1, poverty, cli_hous, address ;
   *!*      Where tmp_h1.client_id = cli_hous.client_id and ;
   *!*            cli_hous.hshld_id = address.hshld_id and ;
   *!*            Iif((address.st <> "AK" AND address.st <> "HI"), poverty.st = "US", address.st = poverty.st) and ;
   *!*            poverty.pov_year = Right(Dtoc(m.date_to),4) and ;
   *!*            poverty.hshld_size = tmp_h1.hshld_size and ;
   *!*            tmp_h1.is_refus = .f. ;
   *!*      Union ;
   *!*      Select Distinct tmp_h1.*, ;
   *!*            000000 as pov_level ;
   *!*      From tmp_h1 ;
   *!*      Where tmp_h1.hshld_size = 0 or tmp_h1.is_refus = .t. ;
   *!*      Into Cursor t_hous

   Select Distinct tmp_h1.*, ;
      poverty.pov_level;
      From tmp_h1, poverty, address ;
      Where tmp_h1.client_id = address.client_id And ;
      Iif((address.st <> "AK" And address.st <> "HI"), poverty.st = "US", address.st = poverty.st) And ;
      poverty.pov_year = Right(Dtoc(m.Date_to),4) And ;
      poverty.hshld_size = tmp_h1.hshld_size And ;
      tmp_h1.is_refus = .F. ;
      Union ;
      Select Distinct tmp_h1.*, ;
      000000 As pov_level ;
      From tmp_h1 ;
      Where tmp_h1.hshld_size = 0 Or tmp_h1.is_refus = .T. ;
      Into Cursor t_hous


   **USE IN poverty
   **Use in cli_hous
   **Use in address
   Use In tmp_h1


   * jss, 3/21/05, pov_level field has been increased to 6 digits
   Select Distinct * , ;
      Iif(pov_level = 0 , 000000, (hshld_incm * 100/pov_level)) As t_incm ;
      From t_hous ;
      Into Cursor all_hous

   Use In t_hous

   m.group  = cWCDesc + ' Clients by Income, Household Size, and Poverty Status'
   m.header = .T.
   ***

   * jss, 10/25/04, include clients with household size > 0 and household income=0 in this group
   m.label = "At or below 100% of Poverty Level"
   Select all_hous
   **      COUNT TO m.count FOR t_incm <= 100 and t_incm <> 0  and is_refus=.f. and hshld_size <> 0
   Count To m.count For t_incm <= 100 And t_incm >= 0  And is_refus=.F. And hshld_size <> 0

   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar
   m.header = .F.

   ***
   m.label = "At 101% to 200% of Poverty Level"
   Select all_hous
   Count To m.count For ;
      Between(t_incm, 101, 200)

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif
   ***
   m.label = "At 201% to 300% of Poverty Level"
   Select all_hous
   Count To m.count For ;
      Between(t_incm, 201, 300)

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif

   ***
   m.label = "Above 300% of Poverty Level"
   Select all_hous
   Count To m.count For ;
      t_incm > 300

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif

   ***
   m.label = "Refusing to report"
   Select all_hous
   Count To m.count For ;
      is_refus

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif

   ***
   m.label = "Household Size Not Entered"
   Select all_hous
   Count To m.count For ;
      hshld_size = 0 And is_refus =.F.

   * jss, 4/20/05, only print if non-zero number
   If m.count > 0
      m.rec_no=m.rec_no+1
      Insert Into aiaggrpt From Memvar
      m.header = .F.
   Endif

   Use In all_hous

   ******************************************************************
   *- Aggregate by HIV status
   * first, get clients hivstatus

   ******************************************************************
   *- Aggregate by HIV status
   =OpenFile("hivstat", "tc_id")
   Select * ;
      From hivstat ;
      Where hivstat.effect_dt <= m.Date_to ;
      Into Cursor t_hiv Readwrite
   *   Into Cursor t_hiv1

   Index On tc_id+Str({01/01/2100}-effect_dt) Tag tc_id
   *   =ReOpenCur("t_hiv1", "t_hiv")
   *   Set Order to tc_id

   Select hold1
   Set Relation To tc_id Into t_hiv

   * jss, 4/27/05, add code to count sub-total of HIV+ and subtotal of HIV-
   Store ' ' To m.label2,m.label3
   m.count2=0

   =OpenFile("hstat", "code")
   m.group = cWCDesc + ' Adult Clients by HIV Status*'
   m.header = .T.
   * jss, 4/20/05, in order to group adults first by HIV positive then by HIV negative, must scan hstat file 2x, once for HIV_Pos once for !HIV_Pos

   m.countpos=0
   Scan For hstat.adult And hiv_pos
      m.label = hstat.Descript
      Select hold1
      Count To m.count For ;
         &cWhereCli .And. ;
         hold1.Prog_id = m.Prog_id And ;
         t_hiv.hivstatus = hstat.Code
      * jss, 4/20/05, only print if non-zero number
      If m.count > 0
         m.countpos=m.countpos+m.count
         m.rec_no=m.rec_no+1
         Insert Into aiaggrpt From Memvar
         m.header = .F.
      Endif
      Select hstat
   Endscan

   * jss, 4/27/05, add line for HIV+ subtotal
   m.label=' '
   m.label3='HIV-Positive Sub-Total'
   m.count=0
   m.count2=m.countpos
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar
   m.header = .F.
   m.label3=' '

   m.countneg=0
   Select hstat
   Set Orde To Descript
   Scan For hstat.adult And !hiv_pos
      m.label = hstat.Descript
      Select hold1
      Count To m.count For ;
         &cWhereCli .And. ;
         hold1.Prog_id = m.Prog_id And ;
         t_hiv.hivstatus = hstat.Code
      * jss, 4/20/05, only print if non-zero number
      If m.count > 0
         m.rec_no=m.rec_no+1
         m.countneg=m.countneg+m.count
         Insert Into aiaggrpt From Memvar
         Select hstat
      Endif
   Endscan

   * jss, 4/27/05, add line for HIV- subtotal
   m.label=' '
   m.label3='HIV-Negative Sub-Total'
   m.count=0
   m.count2=m.countneg
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar
   m.label3=' '

   * jss, 5/2/05, add new section detailing HIV+ Adults by CD4 range (and AIDS-defining DX)
   ******************************************************************
   *- Aggregate by CD4 Range (and AIDS-Defining Diagnoses)
   ******************************************************************
   * first, get all adult positive clients
   Select ;
      hivstat.tc_id ;
      From ;
      hivstat, hstat ;
      Where ;
      hivstat.hivstatus=hstat.Code ;
      and hstat.hiv_pos And hstat.adult ;
      and hivstat.effect_dt <= m.Date_to ;
      and hivstat.tc_id + hivstat.status_id In ;
      (Select tc_id + Max(status_id)  ;
      From hivstat ;
      Where effect_dt<=m.Date_to ;
      Group By tc_id) ;
      Into Cursor ;
      adultpos

   * next, get adult positives from hold1
   Select ;
      tc_id ;
      from ;
      hold1 ;
      Where ;
      &cWhereCli ;
      and Prog_id = m.Prog_id ;
      and tc_id In ;
      (Select tc_id From adultpos) ;
      Into Cursor ;
      Hold1adpos

   Use In adultpos

   * now, grab all CD4 labtests
   Select    tc_id, ;
      count ;
      From testres ;
      Where tc_id + labt_id In ;
      (Select t2.tc_id + Max(t2.labt_id) From testres t2 ;
      Where t2.testtype = '06' ;
      and !Empty(t2.Count) ;
      and t2.testdate <= m.Date_to ;
      Group By t2.tc_id) ;
      Into Cursor ;
      Cd4Test

   * now, find adult positive clients with CD4 test results and those with none
   Select    tc_id, ;
      count, ;
      .F. As AidsDefDx ;
      From Cd4Test ;
      Where tc_id In ;
      (Select tc_id From Hold1adpos) ;
      Union ;
      Select   tc_id, ;
      000000 As Count, ;
      .F. As AidsDefDx ;
      From Hold1adpos ;
      Where tc_id Not In ;
      (Select tc_id From Cd4Test) ;
      Into Cursor ;
      Cd4Hold1 Readwrite
   *      Cd4Hold

   Use In Hold1adpos
   Use In Cd4Test

   *   =ReopenCur("Cd4Hold","Cd4Hold1")
   *   Use in Cd4Hold

   * now, get aids-defining diagnoses
   Select * ;
      From ai_diag ;
      Where diagdate <= m.Date_to And !Empty(hiv_icd9) ;
      Into Cursor t_diag Readwrite
   *   Into Cursor t_diag1

   Index On tc_id+Str({01/01/2100}-diagdate) Tag tc_id
   *!*      =ReOpenCur("t_diag1", "t_diag")
   *!*      Set Order to tc_id
   *!*      Use in t_diag1

   Select Cd4Hold1
   Set Relation To tc_id Into t_diag
   Go Top
   Replace All AidsDefDx With Found('t_diag')
   Use In t_diag

   * now, count the CD4 counts and aids-defining diagnoses within each
   Select * From Cd4Hold1 Where Count=0                Into Cursor Cd_None
   Select * From Cd4Hold1 Where Count>0 And Count<100       Into Cursor Cd_1_99
   Select * From Cd4Hold1 Where Count>=100 And Count<200    Into Cursor Cd_100_199
   Select * From Cd4Hold1 Where Count>=200                Into Cursor Cd_200plus
   Use In Cd4Hold1

   m.group = cWCDesc + ' Adult HIV+ Clients by CD4 Count and AIDS-Defining Dx*'
   m.label='No CD4 Test Results'
   m.label2=' '
   m.label3=' '
   m.header=.T.
   Store 0 To m.count, m.count2

   Select Cd_None
   Count To m.count
   Count To m.count2 For AidsDefDx
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar
   m.header = .F.

   m.label='CD4 Count 0-99'
   Store 0 To m.count, m.count2

   Select Cd_1_99
   Count To m.count
   Count To m.count2 For AidsDefDx
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar

   m.label='CD4 Count 100-199'
   Store 0 To m.count, m.count2

   Select Cd_100_199
   Count To m.count
   Count To m.count2 For AidsDefDx
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar

   m.label='CD4 Count 200 and above'
   Store 0 To m.count, m.count2

   Select Cd_200plus
   Count To m.count
   Count To m.count2 For AidsDefDx
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar

   Use In Cd_None
   Use In Cd_1_99
   Use In Cd_100_199
   Use In Cd_200plus
   Store 0 To m.count, m.count2

   * jss, 10/26/00, add new section detailing case of CDC-defined AIDS
   ******************************************************************
   *- Aggregate by CDC-Defined AIDS
   ******************************************************************

   Store cWCDesc + ' Clients with CDC-Defined AIDS' To m.group, m.label
   m.header = .T.

   If Seek(m.Prog_id,'CDC_AIDS')
      m.count = cdc_aids.cdcaidscnt
   Else
      m.count = 0
   Endif

   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt From Memvar
   m.header = .F.

   ******************************************************************
   *- Aggregate Pediatric Clients by HIV status/Symptoms
   ******************************************************************
   =OpenFile("hivstat", "tc_id")
   Select hold1
   Set Relation To tc_id Into t_hiv

   * Prepare a list of HIV status/symptom combinations
   * jss, 12/98, only should have symptoms for hiv infected '05', hiv vertical (perinatal) exposure '06'
   Select ;
      hstat.Code , symptom.Code As symptom, ;
      hstat.Descript As hivstat, ;
      symptom.Descript As symptoms ;
      FROM ;
      hstat, symptom ;
      WHERE ;
      !hstat.adult And Inlist(hstat.Code,'05','06') ;
      UNION All ;
      SELECT ;
      hstat.Code , "  " As symptom, ;
      hstat.Descript As hivstat, ;
      "Not entered" As symptoms ;
      FROM ;
      hstat;
      WHERE ;
      !hstat.adult And Inlist(hstat.Code,'05','06') ;
      ORDER By ;
      1, 2 ;
      INTO Cursor ;
      hiv_sympt1

   * here, add on the 2 symptomless codes (07,09)
   Select * ;
      FROM ;
      hiv_sympt1 ;
      UNION ;
      SELECT ;
      hstat.Code As Code, "  " As symptom, ;
      hstat.Descript As hivstat, ;
      SPACE(11) As symptoms ;
      FROM ;
      hstat ;
      WHERE ;
      Inlist(hstat.Code, '07', '09', '11', '12') ;
      INTO Cursor ;
      hiv_sympt


   m.group = cWCDesc + ' Pediatric Clients by HIV Status/Symptoms*'
   m.header = .T.
   m.code = ""
   m.symptom= ""
   Scan
      m.code = hiv_sympt.Code
      m.symptom = symptom
      If Inlist(hiv_sympt.Code,'05','06')
         m.label = Trim(hiv_sympt.hivstat) +  ", Symptoms: "+hiv_sympt.symptoms

         Select hold1
         Count To m.count For ;
            &cWhereCli ;
            AND ;
            hold1.Prog_id=m.Prog_id  ;
            AND ;
            t_hiv.hivstatus = m.code ;
            AND ;
            t_hiv.symptoms = m.symptom

         * jss, 4/20/05, only print if non-zero number
         If m.count > 0
            m.rec_no=m.rec_no+1
            Insert Into aiaggrpt From Memvar
            m.header = .F.
         Endif

      Else
         m.label = Trim(hiv_sympt.hivstat)
         Select hold1
         Count To m.count For ;
            &cWhereCli .And. ;
            hold1.Prog_id = m.Prog_id .And. ;
            t_hiv.hivstatus = m.code

         * jss, 4/20/05, only print if non-zero number
         If m.count > 0
            m.rec_no=m.rec_no+1
            Insert Into aiaggrpt From Memvar
            m.header = .F.
         Endif
      Endif
      Sele hiv_sympt
   Endscan

   Use In hiv_sympt
   Use In t_hiv

   ****************************
   * Clients HIV+ and PPD+
   ****************************
   =Seek(m.Prog_id, "hold3")

   Store ' ' To m.label2,m.label3
   m.count2=0

   If cActivNew
      tot_hiv = hold3.TOTHIVPPD
   Else
      tot_hiv = hold3.NewHIVPPD
   Endif

   * jss, 4/20, add blank fifth position (used for Referral Source Type: "Internal" or "External")
   * jss, 4/20, add blank sixth position (used for label3)
   m.rec_no=m.rec_no+1
   Insert Into aiaggrpt Values ;
      (m.Prog_id, ;
      m.progrdesc,;
      cWCDesc + " Clients HIV+ and PPD+ *", ;
      cWCDesc + " Clients HIV+ AND PPD+", ;
      " ", ;
      " ", ;
      tot_hiv, ;
      .T., ;
      .F., m.rec_no, m.count2)

   **************************************
   * TB therapy descriptions
   **************************************
   =OpenFile("tbstatus", "tc_id")

   Select * ;
      From tbstatus ;
      Where tbstatus.effect_dt <= m.Date_to ;
      Into Cursor t_tb1

   =OpenFile("treatmen", "code")
   m.group = cWCDesc + ' Clients by TB Treatment*'
   m.header = .T.
   Store ' ' To m.label2,m.label3
   m.count2=0
   Scan
      m.label = treatmen.Descript
      cCode = treatmen.Code

      Select Count(*) As tot ;
         From hold1, t_tb1 ;
         Where &cWhereCli And ;
         hold1.Prog_id = m.Prog_id .And. ;
         hold1.tc_id = t_tb1.tc_id And ;
         t_tb1.treatment = cCode ;
         Into Cursor t_tot1

      m.count = t_tot1.tot
      * jss, 4/20/05, only print if non-zero number
      If m.count > 0
         m.rec_no=m.rec_no+1
         Insert Into aiaggrpt From Memvar
         m.header = .F.
      Endif
      Use In t_tot1

      Select treatmen
   Endscan
   Use In t_tb1

   ******************************************************************
   Select hold1.Prog_id, hold1.progrdesc, ;
      cWCDesc + ' Clients In Special Populations*' As Group, ;
      Speclpop.Descript As Label, ;
      ' ' As label2, ;
      ' ' As label3, ;
      COUNT(*) As Count, ;
      .F. As Header ;
      FROM hold1, ;
      Ai_spclp, ;
      Speclpop;
      WHERE &cWhereCli ;
      AND Ai_spclp.tc_id = hold1.tc_id;
      AND Speclpop.Code = Ai_spclp.Code;
      AND hold1.Prog_id = m.Prog_id ;
      GROUP By 2,4 ;
      ORDER By 2,4 ;
      INTO Cursor tspcl1

   * jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt
   recsave=m.rec_no
   Scan
      m.rec_no=m.rec_no+1
      Scatter Memvar
      m.header=Iif(m.rec_no=recsave+1,.T.,.F.)
      Select aiaggrpt
      Append Blank
      Gather Memvar
      Select tspcl1
   Endscan
   Use In tspcl1

   ******************************************************************
   *- Aggregate By county
   Select hold1.Prog_id, hold1.progrdesc, ;
      cWCDesc + ' Clients by County' As Group    ,;
      IIF(Empty(county), Padr('Not Entered',25), county) As Label  ,;
      ' ' As label2, ;
      ' ' As label3, ;
      COUNT(*) As Count, ;
      .F. As Header ;
      FROM hold1 ;
      WHERE &cWhereCli ;
      AND hold1.Prog_id = m.Prog_id ;
      GROUP By 2,4 ;
      ORDER By 2,4 ;
      INTO Cursor tcounty

   * jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt
   recsave=m.rec_no
   Scan
      m.rec_no=m.rec_no+1
      Scatter Memvar
      m.header=Iif(m.rec_no=recsave+1,.T.,.F.)
      Select aiaggrpt
      Append Blank
      Gather Memvar
      Select tcounty
   Endscan
   Use In tcounty

   ******************************************************************
   *- Aggregate By zip code
   Select    Prog_id, ;
      progrdesc, ;
      cWCDesc + ' Clients by ZIP code' As Group   ,;
      IIF(zip='     -    ','Not Entered', zip+Space(10)) As Label   ,;
      ' ' As label2, ;
      ' ' As label3, ;
      COUNT(*)  As Count   ,;
      .F. As Header ;
      FROM hold1 ;
      WHERE &cWhereCli ;
      AND Prog_id = m.Prog_id ;
      GROUP By 2,4 ;
      ORDER By 2,4 ;
      INTO Cursor tZipcode

   * jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt
   recsave=m.rec_no
   Scan
      m.rec_no=m.rec_no+1
      Scatter Memvar
      m.header=Iif(m.rec_no=recsave+1,.T.,.F.)
      Select aiaggrpt
      Append Blank
      Gather Memvar
      Select tZipcode
   Endscan
   Use In tZipcode

   ******************************************************************
   * jss, 4/20/05, place 'Internal' and 'External' in their own column, label2
   *- Aggregate by referral source
   Select hold1.Prog_id, hold1.progrdesc, ;
      cWCDesc + ' Clients by Referral Source' As Group    ,;
      referalsrc As Label  ,;
      IIF(nrefnote=1, 'Internal', Iif(nrefnote=2, 'External',' ')) As label2 , ;
      ' ' As label3, ;
      COUNT(*) As Count ,;
      .F. As Header ;
      FROM hold1 ;
      WHERE &cWhereCli ;
      AND hold1.Prog_id = m.Prog_id ;
      GROUP By 2,4 ;
      ORDER By 2,4 ;
      INTO Cursor trefsrce

   * jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt
   recsave=m.rec_no
   Scan
      m.rec_no=m.rec_no+1
      Scatter Memvar
      m.header=Iif(m.rec_no=recsave+1,.T.,.F.)
      Select aiaggrpt
      Append Blank
      Gather Memvar
      Select trefsrce
   Endscan
   Use In trefsrce

   ******************************************************************
   *- Family-Centered/Collateral Case Management:
   Select Prog_id, progrdesc, ;
      'Family-Centered/Collateral Case Mgmt (of Total Possible)' As Group, ;
      Descript As Label, ' ' As label2, ' ' As label3, Count, .F. As Header, notcount ;
      FROM FamCollSum ;
      WHERE Prog_id = m.Prog_id ;
      INTO Cursor tfam

   * jss, 4/21/05, instead of array, select into cursor above, then scan cursor and write to aiaggrpt
   recsave=m.rec_no
   Scan
      m.rec_no=m.rec_no+1
      Scatter Memvar
      m.header=Iif(m.rec_no=recsave+1,.T.,.F.)
      Select aiaggrpt
      Append Blank
      Gather Memvar
      Select tfam
   Endscan
   Use In tfam

   ********************************************************************
   n2=Seconds()
   *WAIT WINDOW "Elapsed Time: " + Str(n2-n1,10,2)

   *!*   oApp.msg2user('OFF')

   ** DG 01/23/97 End of the Loop
   Select tProgram
Endscan

cReportSelection = .agroup(nGroup)
* jss, 4/20/05, add label2 to aiaggrptj
* jss, 4/27/05, add label2 to aiaggrptj
* jss, 9/13/2006: for VFP, add the Agency totals now
m.BegActTot=BegActTo.tot
m.CliNewTot=CliNewTo.tot
m.NewActTot=NewActTo.tot
m.ReopTotot=ReopTota.tot
m.ClosPeTot=ClosPeTo.tot
m.BaClosTot=BaClosTo.tot
m.CnClosTot=CnClosTo.tot
m.ReClosTot=ReClosTo.tot
m.EndActTot=EndActTo.tot
m.TotDChild=CliNewTo.TotDChild
m.TotHHead =CliNewTo.TotHHead


Select ;
   aiaggrpt.progrdesc, ;
   aiaggrpt.Group, ;
   aiaggrpt.Label, ;
   aiaggrpt.label2, ;
   aiaggrpt.label3, ;
   aiaggrpt.Count, ;
   aiaggrpt.Header, ;
   aiaggrpt.notcount, ;
   aiaggrpt.rec_no, ;
   aiaggrpt.count2, ;
   hold3.*,       ;
   m.BegActTot As BegActTot, ;
   m.CliNewTot As CliNewTot, ;
   m.NewActTot As NewActTot, ;
   m.ReopTotot As ReopTotot, ;
   m.ClosPeTot As ClosPeTot, ;
   m.BaClosTot As BaClosTot, ;
   m.CnClosTot As CnClosTot, ;
   m.ReClosTot As ReClosTot, ;
   m.EndActTot As EndActTot, ;
   m.TotDChild As TotDChild, ;
   m.TotHHead  As TotHHead,  ;
   LCProg      As LCProg ;
   FROM ;
   aiaggrpt,   ;
   hold3       ;
   WHERE ;
   aiaggrpt.Prog_id=hold3.Prog_id ;
   INTO Cursor ;
   aiaggrptj

* make sure there are clients to report on

If _Tally = 0
   oApp.msg2user('NOTFOUNDG')
   Return .T.
Endif

Use In aiaggrpt

* jss, 4/17/01, add flag enr_req to report cursor
Select ;
   aiaggrptj.*, ;
   aiaggrptj.rec_no, ;
   Program.Enr_Req, ;
   cTitle As cTitle, ;
   cDemoTitle As cDemoTitle, ;
   cCumTitle As cCumTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   FROM ;
   aiaggrptj, Program ;
   WHERE ;
   aiaggrptj.Prog_id = Program.Prog_id ;
   INTO Cursor;
   aiaggrpt2 ;
   ORDER By rec_no

Use In Program
Use In aiaggrptj
Use In hold10
Use In hold2
Use In hold3

*DO Rest_Env2 WITH aFiles_Open
Return

********************
Procedure AgeSxx_Rpt
********************
Parameter cActivNew
**********************************************************************
* jss, 4/19/05, age by sex by race crosstabs report, with modified age categories (Age 0-1, Age 2-12 replace Age 0-12,
*             age 70+ combined with Age 60_69 yielding Age 60+)
**********************************************************************

If cActivNew
   rep_title1='Age by Sex by Ethnicity/Race - Active Clients'
   cWhereAgen = 'ActivAgen'
   cWhereProg = 'ActivProg'
Else
   rep_title1='Age by Sex by Ethnicity/Race - New Clients'
   cWhereAgen = 'NewAgency'
   cWhereProg = 'NewProg'
Endif

*- cross tabs - age by race by gender

* "RaAgeHold1" cursor holds distinct clients + program
Select Dist ;
   h.tc_id, ;
   h.Prog_id, ;
   h.progrdesc, ;
   Space(18) As Race, ;
   h.white, ;
   h.blafrican, ;
   h.asian, ;
   h.hawaisland, ;
   h.indialaska, ;
   h.unknowrep, ;
   h.someother , ;
   h.hispanic, ;
   IIF(h.sex="M","Male    ", "Female  ") As Gender, ;
   h.dob, ;
   h.newagency, ;
   h.newprog, ;
   h.ActivAgen, ;
   h.ActivProg, ;
   CalcAge(m.Date_to, h.dob) As Client_Age, ;
   g.descript as sexdesc, ;
   g.code as gender_cde ;
   FROM hold1 as h ;
      LEFT OUTER JOIN cli_cur as c ON c.tc_id = h.tc_id ;
      LEFT OUTER JOIN gender as g ON g.code = c.gender ;
   INTO Cursor RaAgeHold1 Readwrite

*   INTO CURSOR RaAgeHold0

*!*
*!* added the following lines to make
*!* sure the data for Actiove Clients falls between
*!* the date ranges entered from the rpt_form..
*!* this date check was not in the original program
*!* added 09/21/2009
*!* jim power
*!*

If cActivNew   && for ACTIVE CLIENTS ONLY...
   Select * From hold1 ;
      WHERE placed_dt Between m.Date_from And m.Date_to ;
      INTO Cursor T

   If _Tally = 0
      oApp.msg2user('NOTFOUNDG')
      Return .T.
   Endif
Endif

*!*
*!* end of added statements...
*!*

*=ReopenCur("RaAgeHold0","RaAgeHold1")

Select RaAgeHold1
Replace All Race With GetRace()

*- Detail Information (program level)
*- cross tabs - age by race by sex
Select "Hispanic             " As hispanic, Prog_id, progrdesc, Race, Gender,sexdesc, gender_cde, ;
   SUM(Iif(!Empty(dob) And Between(Client_Age,0,1),1,0))    As Age0_1   ,;
   SUM(Iif(Between(Client_Age,2,12),1,0))   As Age2_12   ,;
   SUM(Iif(Between(Client_Age,13,19),1,0))  As Age13_19  ,;
   SUM(Iif(Between(Client_Age,20,29),1,0))  As Age20_29  ,;
   SUM(Iif(Between(Client_Age,30,39),1,0))  As Age30_39  ,;
   SUM(Iif(Between(Client_Age,40,49),1,0))  As Age40_49  ,;
   SUM(Iif(Between(Client_Age,50,59),1,0))  As Age50_59  ,;
   SUM(Iif(!Empty(dob) And Client_Age >= 60,1,0)) As Age60Plus ,;
   SUM(Iif(Empty(dob),1,0)) As AgeUnknown ,;
   COUNT(*) As Total ;
   FROM ;
   RaAgeHold1 ;
   WHERE ;
   &cWhereProg And hispanic = 2;
   GROUP By ;
   1,2,4,5 ;
   INTO Cursor ;
   t_hisp

Select "Non-Hispanic         " As hispanic, Prog_id, progrdesc, Race, Gender, sexdesc, gender_cde, ;
   SUM(Iif(!Empty(dob) And Between(Client_Age,0,1),1,0))    As Age0_1   ,;
   SUM(Iif(Between(Client_Age,2,12),1,0))   As Age2_12   ,;
   SUM(Iif(Between(Client_Age,13,19),1,0))  As Age13_19  ,;
   SUM(Iif(Between(Client_Age,20,29),1,0))  As Age20_29  ,;
   SUM(Iif(Between(Client_Age,30,39),1,0))  As Age30_39  ,;
   SUM(Iif(Between(Client_Age,40,49),1,0))  As Age40_49  ,;
   SUM(Iif(Between(Client_Age,50,59),1,0))  As Age50_59  ,;
   SUM(Iif(!Empty(dob) And Client_Age >= 60,1,0)) As Age60Plus ,;
   SUM(Iif(Empty(dob),1,0)) As AgeUnknown ,;
   COUNT(*) As Total ;
   FROM ;
   RaAgeHold1 ;
   WHERE ;
   &cWhereProg And hispanic = 1;
   GROUP By ;
   1,2,4,5 ;
   INTO Cursor ;
   t_nhisp

nUsed = 0

Select "Ethnicity Not Entered" As hispanic, Prog_id, progrdesc, Race, Gender, sexdesc, gender_cde, ;
   SUM(Iif(!Empty(dob) And Between(Client_Age,0,1),1,0))    As Age0_1   ,;
   SUM(Iif(Between(Client_Age,2,12),1,0))   As Age2_12   ,;
   SUM(Iif(Between(Client_Age,13,19),1,0))  As Age13_19  ,;
   SUM(Iif(Between(Client_Age,20,29),1,0))  As Age20_29  ,;
   SUM(Iif(Between(Client_Age,30,39),1,0))  As Age30_39  ,;
   SUM(Iif(Between(Client_Age,40,49),1,0))  As Age40_49  ,;
   SUM(Iif(Between(Client_Age,50,59),1,0))  As Age50_59  ,;
   SUM(Iif(!Empty(dob) And Client_Age >= 60,1,0)) As Age60Plus ,;
   SUM(Iif(Empty(dob),1,0)) As AgeUnknown ,;
   COUNT(*) As Total ;
   FROM ;
   RaAgeHold1 ;
   WHERE ;
   &cWhereProg And hispanic <> 1 And hispanic <> 2;
   GROUP By ;
   1,2,4,5 ;
   INTO Cursor ;
   t_det

If _Tally <> 0
   Select * ;
      FROM t_hisp ;
      UNION All ;
      Select * ;
      FROM t_nhisp ;
      UNION All ;
      Select * ;
      FROM t_det;
      INTO Cursor hold3
   nUsed =1
Else
   Select * ;
      FROM t_hisp ;
      UNION All ;
      Select * ;
      FROM t_nhisp ;
      INTO Cursor hold3
Endif

Use In t_hisp
Use In t_nhisp


det_tally=_Tally

* make sure there are clients to report on
If det_tally=0
   oApp.msg2user('NOTFOUNDG')
   Return .T.
Endif


*** jss, 4/27/05, no longer want zeros on report, so remove code filling out all unused gender/race combos with zeros

If Used('race')
   Use In Race
Endif

Select 0
Use (Dbf("hold3")) Again Alias Age_Race0 Exclusive
Index On Prog_id + hispanic+ Race + Gender Tag typeprog


*!*oApp.msg2user('OFF')

cReportSelection = "All Programs"


* jss, 9/14/06, add vars to select for VFP report
Select ;
   Age_Race0.*, ;
   .F. As Enr_Req, ;
   cTitle As cTitle, ;
   rep_title1 As rep_title1, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   FROM ;
   Age_Race0 ;
   INTO Cursor ;
   Age_Race Readwrite
*   Age_Race1

*=ReopenCur("Age_Race1","Age_Race")
=OpenFile("Program","Prog_Id")
Select Age_Race

Set Relation To Prog_id Into Program
Go Top
Replace All Enr_Req With Iif(!Eof("Program"),Program.Enr_Req, .F.)

Index On Prog_id + hispanic +Race + Gender Tag typeprog
Go Top

*!*
*!* added the following to get the race desciption field
*!* 04/23/2009

Select a.*, r.Descript,oApp.gcversion As Version, Dtoc(oApp.gdverdate) As verdate, gcagencyname As agencyname ;
   FROM Age_Race As a ;
   LEFT Outer Join Race As r On r.Code = a.Race ;
   INTO Cursor temp

Index On Prog_id + hispanic +Race + Gender Tag typeprog
Go Top
*!*
*!* added line  below to copy the cursor to a table for crystal processing
*!* 04/22/2009
*!* jim power
*!*

Copy To oapp.gcpath2temp+"age_race.dbf"
*!*COPY FILE airs_crreports\clients_ethnicity_report.rpt TO oapp.gcpath2temp+ "clients_ethnicity_report.rpt"

*!* COPY FILE c:\airs_crreports\clients_ethnicity_report.rpt TO ADDBS(oapp.gcpath2temp)+ "clients_ethnicity_report.rpt"
*!*COPY FILE c:\airs_crreports\clients_ethnicity_report.rpt TO ADDBS(crRptPath)+ "clients_ethnicity_report.rpt"

Select Prog_id,progrdesc, Gender, gcagencyname As agencyname, Sum(Age0_1) As LESS2, ;
   SUM(Age2_12) As AGE12, Sum(Age13_19) As AGE19,;
   SUM(Age20_29) As AGE29, Sum(Age30_39) As AGE39, ;
   SUM(Age40_49) As AGE49, Sum(Age50_59) As AGE59, ;
   SUM(Age60Plus) As AGE60, Sum(AgeUnknown) As UNK ;
   FROM Age_Race Group By 1,2,3,4 ;
   INTO Cursor tmp

*!* Copy To oapp.gcpath2temp+"age_race_summary.dbf"

*!* following line comment out 04/22/2009
*!* replace with the lines after
*!*   gcRptName = 'rpt_agesxx'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*      Report Form rpt_agesxx To Printer Prompt Noconsole NODIALOG
*!*   CASE lPrev = .t.     &&Preview
*!*      oApp.rpt_print(5, .t., 1, 'rpt_agesxx', 1, 2)
*!*   EndCase

*!*
*!* added the following for crystal rport processing
*!* 04/22/2009
*!*
*!*   Declare Integer ShellExecute In shell32.Dll ;
*!*      INTEGER hndWin, ;
*!*      STRING caction, ;
*!*      STRING cFilename, ;
*!*      STRING cParms, ;
*!*      STRING cDir, ;
*!*      INTEGER nShowWin

*!*   LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*   LcAction = "open"
*!*   Lcparms = "clients_ethnicity_report.rpt"
*!*   Lcdir = "i:\ursver6\airs_crreports\"
*!*   ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

*!*   oApp.display_crystal_reports("clients_ethnicity_report.rpt")

Use In RaAgeHold1
Use In hold3
*USE IN age_race
Use In Age_Race0
*USE IN age_race1

Return

****************
Function GetRace
****************
tRace=Space(2)
Do Case

      * jss, 4/22/03, add "someother" to logic for determining multiple race designation of "60"
      * jss, 6/5/03, account for situation where no race has been entered at all; count it as unknown/unreported
   Case white=1 And (blafrican=1 Or  asian=1 Or  hawaisland=1 Or  indialaska=1 Or someother=1)
      tRace='60'
   Case blafrican=1 And (asian=1 Or  hawaisland=1 Or  indialaska=1 Or someother=1)
      tRace='60'
   Case asian=1 And (hawaisland=1 Or  indialaska=1 Or someother=1)
      tRace='60'
   Case hawaisland=1 And (indialaska=1 Or someother=1)
      tRace='60'
   Case indialaska=1 And someother=1
      tRace='60'
   Case white=1
      tRace='10'
   Case blafrican=1
      tRace='20'
   Case asian=1
      tRace='30'
   Case hawaisland=1
      tRace='40'
   Case indialaska=1
      tRace='50'
   Case  someother=1
      tRace='70'
   Case unknowrep=1
      tRace='90'
   Otherwise
      tRace='90'
Endcase

Return tRace

**********************************************************************
Function CalcAge
****************
Parameters tdDt2Calc2, tdDOB
Private All Like j*
m.jcOldDate=Set("date")
Set Date AMERICAN
m.jnAge=Year(m.tdDt2Calc2)-Year(m.tdDOB)-;
   IIF(Ctod(Left(Dtoc(m.tdDOB),6)+Str(Year(m.tdDt2Calc2)))>m.tdDt2Calc2,1,0)
Set Date &jcOldDate
Return m.jnAge

**********************************************************
Function MakeSection
**********************************************************
*  Function.........: MakeSection
*) Description......: Creates a section in a file
**********************************************************
Parameters cGrpName, cTable, cField, lNewOnly, cAddCond

Private cSearchStr
cSearchStr = Iif(lNewOnly, "hold1.newprog .AND. ", "") + ;
   IIF(!Empty(cAddCond), cAddCond + " .AND. ", "") + ;
   "hold1." + cField + " = " + cTable + ".code"

=OpenFile(cTable, "code")
m.group = cGrpName
m.header = .T.
Scan
   m.label = &cTable..Descript
   Select newprog
   Count To m.count For &cSearchStr
   Insert Into aiaggrpt From Memvar
   m.header = .F.
Endscan

* jss, 11/98, add this code to handle "Not Entered" scenario

m.label = 'Not Entered'
Select hold1
Set Rela To &cField Into &cTable Additive
Count To m.count For newprog And Eof(cTable)
Insert Into aiaggrpt From Memvar

Return
*-EOF MakeSection

**********************************************************************
Procedure Rpt_RevSumm
*PARAMETER nClick,nTimes
*************************************************************************
* jss, 10/2000, completely re-written with new specs
* this is the report that gives the amount newly billed, rebilled, pended, denied, adjusted and paid

If Used('tBilled')
   Use In tBilled
Endif

If Used('tReBilled')
   Use In tReBilled
Endif

If Used('tPended')
   Use In tPended
Endif

If Used('tDenied')
   Use In tDenied
Endif

If Used('tDenyReb')
   Use In tDenyReb
Endif

If Used('tDenyNev')
   Use In tDenyNev
Endif

If Used('tDenyNA')
   Use In tDenyNA
Endif

If Used('tPaid')
   Use In tPaid
Endif

If Used('tVoided')
   Use In tVoided
Endif

If Used('tAdjusted')
   Use In tAdjusted
Endif

If Used('Billed')
   Use In Billed
Endif

If Used('ReBilled')
   Use In ReBilled
Endif

If Used('Pended')
   Use In Pended
Endif

If Used('Denied')
   Use In Denied
Endif

If Used('DenyReb')
   Use In DenyReb
Endif

If Used('DenyNev')
   Use In DenyNev
Endif

If Used('DenyNA')
   Use In DenyNA
Endif

If Used('Paid')
   Use In Paid
Endif

If Used('Voided')
   Use In Voided
Endif

If Used('Adjusted')
   Use In Adjusted
Endif

If Used('AllProgs')
   Use In AllProgs
Endif

If Used('tFinal')
   Use In tFinal
Endif

If Used('tSumm')
   Use In tSumm
Endif

If Used("RevenueSum")
   Use In RevenueSum
Endif

If Used("tHold")
   Use In tHold
Endif

Create Cursor RevenueSum (Prog_id C(5), progrdesc C(30), Descript C(25), Amount N(8,2))
Private cBlankInv
cBlankInv = Space(9)

* first, grab the newly billed
**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And  Inlist(claim_dt.program, "  + LCProg + ")" )
*AND claim_dt.program = lcProg ;


Select                                                 ;
   Claim_Dt.Program          As Prog_id,               ;
   Program.Descript         As progrdesc,             ;
   SUM(Claim_Dt.Amount)    As Billed                ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                      ;
   AND   Empty(Claim_Hd.adj_void)                      ;
   AND Claim_Dt.first_inv = cBlankInv                ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                                        ;
   AND Claim_Dt.Enc_site= cCSite                      ;
   INTO Cursor tBilled                                  ;
   GROUP By 1

**VT 01/08/2008
**AND Claim_Dt.Program = lcProg     changed to cWhereprg

* now, grab re-billed (most recent)

Select                                                                         ;
   Claim_Dt.Program         As Prog_id,                                       ;
   Program.Descript        As progrdesc,                                     ;
   SUM(Claim_Dt.Amount)     As ReBilled                                        ;
   FROM                                                                         ;
   Claim_Hd,                                                                ;
   Claim_Dt,                                                                ;
   Program                                                                  ;
   WHERE                                                                      ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to)                            ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice                                  ;
   AND Claim_Hd.Processed = "D"                                              ;
   AND   Empty(Claim_Hd.adj_void)                                              ;
   AND Claim_Dt.first_inv <> cBlankInv                                        ;
   AND Claim_Dt.r_line                                                       ;
   AND Claim_Dt.Program = Program.Prog_id                                    ;
   &cWherePrg                                                                ;
   AND Claim_Dt.Enc_site= cCSite                                              ;
   AND Claim_Dt.First_Inv + Dtos(Claim_Dt.Status_dt)                          ;
   IN (Select    ClDt.First_Inv + Max(Dtos(ClDt.Status_dt)) ;
   FROM    Claim_Dt ClDt                            ;
   WHERE ClDt.Status_dt <= m.Date_to             ;
   GROUP By ClDt.First_Inv)                     ;
   INTO Cursor tReBilled                                                       ;
   GROUP By 1

** VT 01/08/2008
**And claim_dt.program = lcprog changed to cWhere Prg

* now, grab the pended info (Status = 1)

Select ;
   Claim_Dt.Program       As Prog_id,               ;
   Program.Descript       As progrdesc,             ;
   SUM(Claim_Dt.Amount)   As Paid                   ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)   ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Status  = 1                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                                         ;
   AND Claim_dt.Enc_site=cCSite                      ;
   INTO Cursor tPended                                  ;
   GROUP By 1

**VT 01/08/2008
** And claim_dt.program=lcProg changed to cWherePrg

* now, grab the denied info (Status = 2)

Select                                                 ;
   Claim_Dt.Program       As Prog_id,               ;
   Program.Descript       As progrdesc,             ;
   SUM(Claim_Dt.Amount)   As Paid                   ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Status  = 2                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_dt.Enc_site=cCSite                      ;
   INTO Cursor tDenied                                  ;
   GROUP By 1

**VT 01/08/2008
**And claim_dt.program=lcprog changed to cwhereprg
* now, grab the denied info that's been rebilled (Status = 2, action = 1)

Select                                                 ;
   Claim_Dt.Program       As Prog_id,               ;
   Program.Descript       As progrdesc,             ;
   SUM(Claim_Dt.Amount)   As Paid                   ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Status  = 2                         ;
   AND Claim_Dt.Action  = 1                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                      ;
   AND Claim_dt.Enc_site=cCSite                      ;
   INTO Cursor tDenyReb                                  ;
   GROUP By 1

**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

* now, grab the denied info that's never to be rebilled (Status = 2, action = 2)

Select                                                 ;
   Claim_Dt.Program       As Prog_id,               ;
   Program.Descript       As progrdesc,             ;
   SUM(Claim_Dt.Amount)   As Paid                   ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Status  = 2                         ;
   AND Claim_Dt.Action  = 2                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                     ;
   AND Claim_dt.Enc_site=cCSite                      ;
   INTO Cursor tDenyNev                                  ;
   GROUP By 1

**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

* now, grab the denied info that has no action taken yet (Status = 2, action = 0)
Select                                                 ;
   Claim_Dt.Program       As Prog_id,               ;
   Program.Descript       As progrdesc,             ;
   SUM(Claim_Dt.Amount)   As Paid                   ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Status  = 2                         ;
   AND Claim_Dt.Action  = 0                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                     ;
   AND Claim_dt.Enc_site=cCSite                      ;
   INTO Cursor tDenyNA                                  ;
   GROUP By 1

* now, handle adjustments: first, just get raw adjustment amounts
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

Select                                                 ;
   Claim_Dt.Program             As Prog_id,           ;
   Program.Descript            As progrdesc,         ;
   Claim_Dt.Amount             As Adjust_Amt,       ;
   Claim_Hd.Orig_ref                                 ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                      ;
   AND   Claim_Hd.adj_void = 'A'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                     ;
   AND Claim_Dt.Enc_site= cCSite                      ;
   INTO Cursor tAdjAmt

* next, sum the difference between the adjustment amount and the original amount
Select                                                       ;
   tAdjAmt.Prog_id,                                        ;
   tAdjAmt.progrdesc,                                     ;
   SUM(tAdjAmt.Adjust_Amt - Claim_Dt.Amount) As Adjusted   ;
   FROM                                                       ;
   tAdjAmt,                                              ;
   Claim_Dt                                              ;
   WHERE                                                    ;
   tAdjAmt.Orig_Ref   = Claim_Dt.Claim_Ref                ;
   INTO Cursor tAdjusted                                    ;
   GROUP By 1

* now, grab the voids
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

Select                                                 ;
   Claim_Dt.Program             As Prog_id,           ;
   Program.Descript            As progrdesc,         ;
   SUM(Claim_Dt.Amount * -1)    As Voided             ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                      ;
   AND   Claim_Hd.adj_void = 'V'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                      ;
   AND Claim_Dt.Enc_site= cCSite                      ;
   INTO Cursor tVoided                                  ;
   GROUP By 1

* next, grab the Paid info (status = 3)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg changed to cWherePrg

Select                                                 ;
   Claim_Dt.Program       As Prog_id,               ;
   Program.Descript       As progrdesc,             ;
   SUM(Claim_Dt.Amt_Paid) As Paid                   ;
   FROM                                                 ;
   Claim_Hd,                                        ;
   Claim_Dt,                                        ;
   Program                                          ;
   WHERE                                              ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)    ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                      ;
   AND Claim_Dt.r_line                               ;
   AND Claim_Dt.Status  = 3                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                      ;
   AND Claim_dt.Enc_site=cCSite                      ;
   INTO Cursor tPaid                                     ;
   GROUP By 1

**VT 01/08/2008
cWherePrg = ''

* now, determine all programs represented in the above cursors

Select Prog_id, progrdesc From tBilled ;
   UNION ;
   SELECT Prog_id, progrdesc From tReBilled ;
   UNION ;
   SELECT Prog_id, progrdesc From tPended ;
   UNION ;
   SELECT Prog_id, progrdesc From tDenied ;
   UNION ;
   SELECT Prog_id, progrdesc From tDenyReb ;
   UNION ;
   SELECT Prog_id, progrdesc From tDenyNev ;
   UNION ;
   SELECT Prog_id, progrdesc From tDenyNA ;
   UNION ;
   SELECT Prog_id, progrdesc From tAdjusted ;
   UNION ;
   SELECT Prog_id, progrdesc From tVoided ;
   UNION ;
   SELECT Prog_id, progrdesc From tPaid ;
   INTO Cursor ;
   AllProgs

* now, fill in the gaps for each cursor

Select * From tBilled ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  Billed  ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tBilled) ;
   INTO Cursor ;
   Billed

Select * From tReBilled ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  ReBilled   ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tReBilled) ;
   INTO Cursor ;
   ReBilled

* now, combine billed and rebilled for total billed

Select ;
   Billed.Prog_id, ;
   Billed.progrdesc, ;
   (Billed.Billed + ReBilled.ReBilled) As TotBilled ;
   FROM ;
   Billed, ReBilled ;
   WHERE ;
   Billed.Prog_id = ReBilled.Prog_id ;
   INTO Cursor ;
   TotBilled

Select * From tPended ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  Pended     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tPended) ;
   INTO Cursor ;
   Pended

Select * From tDenied ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  Denied     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tDenied) ;
   INTO Cursor ;
   Denied

Select * From tDenyReb ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  DenyReb     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tDenyReb) ;
   INTO Cursor ;
   DenyReb

Select * From tDenyNev ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  DenyNev     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tDenyNev) ;
   INTO Cursor ;
   DenyNev

Select * From tDenyNA ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  DenyNA     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tDenyNA) ;
   INTO Cursor ;
   DenyNA

Select * From tAdjusted ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  Adjusted   ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tAdjusted) ;
   INTO Cursor ;
   Adjusted

Select * From tVoided ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  Voided     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tVoided) ;
   INTO Cursor ;
   Voided

Select * From tPaid ;
   UNION ;
   SELECT ;
   AllProgs.Prog_id,   ;
   AllProgs.progrdesc, ;
   0.00 As  Paid     ;
   FROM ;
   AllProgs ;
   WHERE ;
   Prog_id Not In ;
   (Select Prog_id From tPaid) ;
   INTO Cursor ;
   Paid

* now, combine the cursors
Select ;
   a.Prog_id,       ;
   a.progrdesc,    ;
   C.TotBilled,    ;
   a.Billed,       ;
   b.ReBilled,    ;
   D.Pended,       ;
   e.Denied,       ;
   i.DenyReb,     ;
   j.DenyNev,     ;
   k.DenyNA,      ;
   f.Adjusted,    ;
   g.Voided,      ;
   h.Paid          ;
   FROM                   ;
   Billed   a,      ;
   ReBilled b,    ;
   TotBilled C,    ;
   Pended   D,      ;
   Denied   e,      ;
   Adjusted   F,      ;
   Voided   g,      ;
   Paid      h,      ;
   DenyReb   i,      ;
   DenyNev   j,      ;
   DenyNA   k      ;
   WHERE ;
   a.Prog_id = b.Prog_id   And ;
   a.Prog_id = C.Prog_id   And ;
   a.Prog_id = D.Prog_id   And ;
   a.Prog_id = e.Prog_id   And ;
   a.Prog_id = F.Prog_id   And ;
   a.Prog_id = g.Prog_id   And ;
   a.Prog_id = h.Prog_id   And ;
   a.Prog_id = i.Prog_id   And ;
   a.Prog_id = j.Prog_id   And ;
   a.Prog_id = k.Prog_id       ;
   INTO Cursor ;
   tFinal

* create detail lines for report   in cursor revenuesum
Select tFinal
Scan
   Scatter Memvar
   For i = 3 To Fcount()
      Do Case
         Case Field(i) = "TOTBILLED"
            cDescript = "Total Billed Claims"
         Case Field(i) = "BILLED"
            cDescript = "     Newly Billed Claims"
         Case Field(i) = "REBILLED"
            cDescript = "     Re-Billed Claims"
         Case Field(i) = "PENDED"
            cDescript = "Claims Pended"
         Case Field(i) = "DENIED"
            cDescript = "Total Claims Denied"
         Case Field(i) = "DENYREB"
            cDescript = "     Denied-Rebill"
         Case Field(i) = "DENYNEV"
            cDescript = "     Denied-Never Rebill"
         Case Field(i) = "DENYNA"
            cDescript = "     Denied-No Action"
         Case Field(i) = "ADJUSTED"
            cDescript = "Revenues Adjusted"
         Case Field(i) = "VOIDED"
            cDescript = "Revenues Voided"
         Case Field(i) = "PAID"
            cDescript = "Revenues Received"
      Endcase
      nAmount = Eval(Field(i))
      Insert Into RevenueSum Values (m.Prog_id, m.progrdesc, cDescript, nAmount)
   Next
Endscan

* close some cursors
Use In tBilled
Use In tReBilled
Use In tPended
Use In tDenied
Use In tDenyReb
Use In tDenyNev
Use In tDenyNA
Use In tAdjusted
Use In tVoided
Use In tPaid

Use In Billed
Use In ReBilled
Use In TotBilled
Use In Pended
Use In Denied
Use In DenyReb
Use In DenyNev
Use In DenyNA
Use In Adjusted
Use In Voided
Use In Paid

* Summary Info, just sum the revenuesum cursor
Select ;
   SUM(Iif(Descript = "Total Billed Claims", Amount, 0.00))    As TotBilled, ;
   SUM(Iif(Descript = "     Newly Billed Claims",Amount, 0.00))       As Billed,   ;
   SUM(Iif(Descript = "     Re-Billed Claims", Amount, 0.00))       As ReBilled, ;
   SUM(Iif(Descript = "Claims Pended"    ,Amount, 0.00))       As Pended,   ;
   SUM(Iif(Descript = "Total Claims Denied"    ,Amount, 0.00))       As Denied,   ;
   SUM(Iif(Descript = "     Denied-Rebill"    ,Amount, 0.00))       As DenyReb,   ;
   SUM(Iif(Descript = "     Denied-Never Rebill"    ,Amount, 0.00))       As DenyNev,   ;
   SUM(Iif(Descript = "     Denied-No Action"    ,Amount, 0.00))       As DenyNA,   ;
   SUM(Iif(Descript = "Revenues Adjusted",Amount, 0.00))       As Adjusted, ;
   SUM(Iif(Descript = "Revenues Voided"  ,Amount, 0.00))       As Voided,   ;
   SUM(Iif(Descript = "Revenues Received",Amount, 0.00))       As Paid      ;
   FROM ;
   RevenueSum ;
   INTO Cursor ;
   tSumm

* now, add a record to revenuesum cursor for the summary info
cProg_ID = 'ZZZZZ'
cProgrDesc = 'Summary Information'
Select tSumm
For i = 1 To Fcount()
   Do Case
      Case Field(i) = "TOTBILLED"
         cDescript = "Total Billed Claims"
      Case Field(i) = "BILLED"
         cDescript = "     Newly Billed Claims"
      Case Field(i) = "REBILLED"
         cDescript = "     Re-Billed Claims"
      Case Field(i) = "PENDED"
         cDescript = "Claims Pended"
      Case Field(i) = "DENIED"
         cDescript = "Total Claims Denied"
      Case Field(i) = "DENYREB"
         cDescript = "     Denied-Rebill"
      Case Field(i) = "DENYNEV"
         cDescript = "     Denied-Never Rebill"
      Case Field(i) = "DENYNA"
         cDescript = "     Denied-No Action"
      Case Field(i) = "ADJUSTED"
         cDescript = "Revenues Adjusted"
      Case Field(i) = "VOIDED"
         cDescript = "Revenues Voided"
      Case Field(i) = "PAID"
         cDescript = "Revenues Received"
   Endcase
   nAmount = Eval(Field(i))
   Insert Into RevenueSum Values (cProg_ID, cProgrDesc, cDescript, nAmount)
Next

Use In tSumm

If _Tally = 0
   oApp.msg2user('NOTFOUNDG')
   Return .T.
Endif

*!*oApp.msg2user('OFF')

cReportSelection = .agroup(nGroup)

Select *, ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   FROM RevenueSum ;
   INTO Cursor tHold ;
   ORDER By 1

Select T.*, gcagencyname As agencyname, oApp.gcversion As Version, ;
   DTOC(oApp.gdverdate) As verdate ;
   FROM tHold As T ;
   INTO Cursor tmp

Select tmp
Copy To oapp.gcpath2temp+"revenue_summary.dbf"



*!*  gcagencyname as agencyname, oApp.gcversion as version, DTOC(oApp.gdverdate) as verdate, ;
*!* added the following 05/26/2009
*!* from Crystal report
*!* jim power
*!*

*!*   Declare Integer ShellExecute In shell32.Dll ;
*!*      INTEGER hndWin, ;
*!*      STRING caction, ;
*!*      STRING cFilename, ;
*!*      STRING cParms, ;
*!*      STRING cDir, ;
*!*      INTEGER nShowWin

*!*   LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*   LcAction = "open"
*!*   Lcparms = "revenue_summary_report.rpt"
*!*   Lcdir = "i:\ursver6\airs_crreports\"
*!*   ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

oApp.display_crystal_reports("revenue_summary_report.rpt")

*!*   gcRptName = 'rpt_revsumm'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*      Report Form rpt_revsumm To Printer Prompt Noconsole NODIALOG
*!*   CASE lPrev = .t.     &&Preview
*!*      oApp.rpt_print(5, .t., 1, 'rpt_revsumm', 1, 2)
*!*   EndCase

Use In RevenueSum
*USE IN tHold
Return

**********************************************************************
Procedure Rpt_RevDet
*PARAMETER nClick,nTimes
*************************************************************************
* jss, 2/2001, give a detail of revsummrpt
* this is the report that gives the details of amount newly billed, rebilled, pended, denied, adjusted and paid

If Used('tBilled')
   Use In tBilled
Endif

If Used('tReBilled')
   Use In tReBilled
Endif

If Used('tPended')
   Use In tPended
Endif

If Used('tDenyReb')
   Use In tDenyReb
Endif

If Used('tDenyNev')
   Use In tDenyNev
Endif

If Used('tDenyNA')
   Use In tDenyNA
Endif

If Used('tPaid')
   Use In tPaid
Endif

If Used('tVoided')
   Use In tVoided
Endif

If Used('tAdjust')
   Use In tAdjust
Endif

If Used('tFinal')
   Use In tFinal
Endif

If Used('tFinal2')
   Use In tFinal2
Endif

* first, grab the newly billed
**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And  Inlist(claim_dt.program, "  + LCProg + ")" )
*AND claim_dt.program = lcProg ;


Select                                     ;
   Claim_Dt.Program          As Prog_id,         ;
   Program.Descript         As progrdesc,       ;
   '01'                  As ClaimType,       ;
   PADR('Newly Billed Claims',30) As ClaimDesc,    ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amount)      As ClaimAmt       ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                   ;
   AND   Empty(Claim_Hd.adj_void)                   ;
   AND Claim_Dt.first_inv = Space(9)                ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                    ;
   AND Claim_Dt.Enc_site= cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tBilled

* these tables needed because of inconsistencies in numeric field length for cursors produced in select
*COPY STRU TO tAdjust
*COPY STRU TO tVoided
*USE tAdjust IN 0
*USE tVoided IN 0

* now, grab re-billed (most recent)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                                                         ;
   Claim_Dt.Program            As Prog_id,         ;
   Program.Descript           As progrdesc,       ;
   '02'                  As ClaimType,       ;
   PADR('Re-Billed Claims',30) As ClaimDesc,       ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amount)      As ClaimAmt       ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to)   ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                   ;
   AND   Empty(Claim_Hd.adj_void)                   ;
   AND Claim_Dt.first_inv <> Space(9)              ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_Dt.Enc_site= cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   AND Claim_Dt.First_Inv + Dtos(Claim_Dt.Status_dt)     ;
   IN (Select    ClDt.First_Inv + Max(Dtos(ClDt.Status_dt)) ;
   FROM    Claim_Dt ClDt                   ;
   WHERE ClDt.Status_dt <= m.Date_to         ;
   GROUP By ClDt.First_Inv)               ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tReBilled

* now, grab the pended info (Status = 1)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select ;
   Claim_Dt.Program             As Prog_id,         ;
   Program.Descript             As progrdesc,       ;
   '03'                  As ClaimType,       ;
   PADR('Claims Pended',30)    As ClaimDesc,       ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amount)      As ClaimAmt          ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to)   ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Status  = 1                      ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_dt.Enc_site=cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tPended

* now, grab the denied info that's been rebilled (Status = 2, action = 1)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                     ;
   Claim_Dt.Program             As Prog_id,         ;
   Program.Descript             As progrdesc,       ;
   '04'                  As ClaimType,       ;
   PADR('Claims Denied-Rebill',30)    As ClaimDesc,       ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amount)      As ClaimAmt          ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Status  = 2                      ;
   AND Claim_Dt.Action  = 1                      ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_dt.Enc_site=cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tDenyReb

* now, grab the denied info that's never to be rebilled (Status = 2, action = 2)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                     ;
   Claim_Dt.Program             As Prog_id,        ;
   Program.Descript             As progrdesc,      ;
   '05'                  As ClaimType,       ;
   PADR('Claims Denied-Never Rebill',30)    As ClaimDesc,    ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amount)         As ClaimAmt        ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Status  = 2                      ;
   AND Claim_Dt.Action  = 2                      ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_dt.Enc_site=cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tDenyNev

* now, grab the denied info that has no action taken yet (Status = 2, action = 0)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                     ;
   Claim_Dt.Program             As Prog_id,         ;
   Program.Descript             As progrdesc,       ;
   '06'                  As ClaimType,       ;
   PADR('Claims Denied-No Action',30)    As ClaimDesc,       ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amount)      As ClaimAmt          ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Status  = 2                      ;
   AND Claim_Dt.Action  = 0                      ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_dt.Enc_site=cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tDenyNA

* now, handle adjustments: first, just get raw adjustment amounts
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                     ;
   Claim_Dt.Program          As Prog_id,        ;
   Program.Descript         As progrdesc,      ;
   '07'                  As ClaimType,       ;
   PADR('Revenues Adjusted',30) As ClaimDesc,       ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   Claim_Dt.Amount            As ClaimAmt,          ;
   Claim_Hd.Orig_ref                        ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                   ;
   AND   Claim_Hd.adj_void = 'A'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                   ;
   AND Claim_Dt.Enc_site= cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   INTO Cursor tAdjAmt

* now, find the difference between the adjustment amount and the original amount: report this amount
Select                                     ;
   tAdjAmt.Prog_id,                         ;
   tAdjAmt.progrdesc,                         ;
   tAdjAmt.ClaimType,                         ;
   tAdjAmt.ClaimDesc,                         ;
   tAdjAmt.InvoiceNum,                      ;
   tAdjAmt.ClaimDate,                         ;
   (tAdjAmt.ClaimAmt - Claim_Dt.Amount) As ClaimAmt   ;
   FROM                                     ;
   tAdjAmt,                               ;
   Claim_Dt                               ;
   WHERE                                     ;
   tAdjAmt.Orig_Ref = Claim_Dt.Claim_Ref          ;
   Into Cursor tAdjust
*INTO TABLE tAdjust1

* note: we did this because tAdjust1 creation above produced field ClaimAmt with length 8
*      (including 2 decimals), while the amount field is length 7 with 2 dec
*IF _Tally > 0
*   SELECT tAdjust
*   APPEND FROM tAdjust1
*ENDIF

* now, grab the voids
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                     ;
   Claim_Dt.Program          As Prog_id,        ;
   Program.Descript         As progrdesc,      ;
   '08'                  As ClaimType,       ;
   PADR('Revenues Voided',30)    As ClaimDesc,       ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   (Claim_Dt.Amount * -1)       As ClaimAmt         ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Hd.bill_date, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = "D"                   ;
   AND Claim_Hd.adj_void = 'V'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_Dt.Enc_site= cCSite                   ;
   AND Claim_dt.Amount <> 0                     ;
   Into Cursor tVoided
*INTO TABLE tVoid1

*IF _Tally > 0
*   SELECT tVoided
*   APPEND FROM tVoid1
*ENDIF

* next, grab the Paid info (status = 3)
**VT 01/08/2008
**AND Claim_Dt.Program = lcProg    changed to cWherePrg

Select                                     ;
   Claim_Dt.Program             As Prog_id,         ;
   Program.Descript             As progrdesc,       ;
   '09'                  As ClaimType,       ;
   PADR('Revenues Received',30)    As ClaimDesc,    ;
   Claim_Hd.Invoice         As InvoiceNum,       ;
   Claim_Hd.bill_date          As ClaimDate,       ;
   SUM(Claim_Dt.Amt_Paid)      As ClaimAmt          ;
   FROM                                     ;
   Claim_Hd,                               ;
   Claim_Dt,                               ;
   Program                                 ;
   WHERE                                     ;
   BETWEEN(Claim_Dt.Status_Dt, Date_from, Date_to) ;
   AND Claim_Hd.Invoice   = Claim_Dt.Invoice          ;
   AND Claim_Hd.Processed = 'D'                   ;
   AND Claim_Dt.r_line                         ;
   AND Claim_Dt.Status  = 3                      ;
   AND Claim_Dt.Program = Program.Prog_id            ;
   &cWherePrg                  ;
   AND Claim_dt.Enc_site=cCSite                   ;
   AND Claim_dt.Amt_Paid <> 0                     ;
   GROUP By ;
   3, 5, 6 ;
   INTO Cursor tPaid

If Used('Program')
   Use In Program
Endif

* now, combine all selects into one detail cursor, order by program description and claim type
Select * From tBilled ;
   UNION All ;
   SELECT * From tReBilled ;
   UNION All ;
   SELECT * From tPended ;
   UNION All ;
   SELECT * From tDenyReb ;
   UNION All ;
   SELECT * From tDenyNev ;
   UNION All ;
   SELECT * From tDenyNA ;
   UNION All ;
   SELECT * From tAdjust ;
   UNION All ;
   SELECT * From tVoided ;
   UNION All ;
   SELECT * From tPaid  ;
   INTO Cursor ;
   tFinal ;
   ORDER By ;
   2, 3, 6 Desc      && Program Description, Claim Type (defined herein), claim date

Select ;
   tFinal.*, ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   From tFinal ;
   Into Cursor ;
   tFinal2 ;
   ORDER By ;
   2, 3, 6 Desc      && Program Description, Claim Type (defined herein), claim date

* close some cursors
If Used('tBilled')
   Use In tBilled
Endif

If Used('tReBilled')
   Use In tReBilled
Endif

If Used('tPended')
   Use In tPended
Endif

If Used('tDenyReb')
   Use In tDenyReb
Endif

If Used('tDenyNev')
   Use In tDenyNev
Endif

If Used('tDenyNA')
   Use In tDenyNA
Endif

If Used('tPaid')
   Use In tPaid
Endif

If Used('tVoided')
   Use In tVoided
Endif

If Used('tAdjust')
   Use In tAdjust
Endif

If _Tally = 0
   oApp.msg2user('NOTFOUNDG')
   Return .T.
Endif

*!*oApp.msg2user('OFF')

cReportSelection = .agroup(nGroup)
*!*
*!* added the following 05/26/2009
*!* for crystal report format..
*!* jim power
*!*


Select T.*, cReportSelection  As creportsel,gcagencyname As agencyname, ;
   oApp.gcversion As Version, Dtoc(oApp.gdverdate) As verdate ;
   FROM tFinal2 As T;
   INTO Cursor tmp

Copy To oapp.gcpath2temp+"revenue_detail.dbf"

*!*   Declare Integer ShellExecute In shell32.Dll ;
*!*      INTEGER hndWin, ;
*!*      STRING caction, ;
*!*      STRING cFilename, ;
*!*      STRING cParms, ;
*!*      STRING cDir, ;
*!*      INTEGER nShowWin

*!*   LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*   LcAction = "open"
*!*   Lcparms = "revenue_details_report.rpt"
*!*   Lcdir = "i:\ursver6\airs_crreports\"
*!*   ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

oApp.display_crystal_reports("revenue_details_report.rpt")

*!*   gcRptName = 'rpt_revdet'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*      Report Form rpt_revdet To Printer Prompt Noconsole NODIALOG
*!*   CASE lPrev = .t.     &&Preview
*!*      oApp.rpt_print(5, .t., 1, 'rpt_revdet', 1, 2)
*!*   EndCase

Use In tFinal
Return

*****************
Procedure getprob
*****************
Parameter parmtopass
If Ascan(cProbArray,'HOLDSITE') <> 0 Or ;
      ASCAN(cProbArray,'HOLDACTI') <> 0 Or ;
      ASCAN(cProbArray,'HOLDPROG') <> 0 Or ;
      ASCAN(cProbArray,'AI_ACTDT') <> 0 Or ;
      ASCAN(cProbArray,'AI_SITED') <> 0 Or ;
      ASCAN(cProbArray,'HIVDATE')  <> 0 Or ;
      ASCAN(cProbArray,'TBDATE')   <> 0
   parmtopass= parmtopass + Chr(13) + ' - Main AI Aggregate' + Chr(13) + ' - Age by Sex by Ethnicity'
Else
   * to avoid duplicating "Age by Sex...", only check this if above stuff OK
   If Ascan(cProbArray,'DOBDATE') <> 0
      parmtopass= parmtopass + Chr(13) + ' - Age by Sex by Ethnicity'
   Endif
Endif
If Ascan(cProbArray,'REFDATE') <> 0 Or ;
      ASCAN(cProbArray,'REFSRC3') <> 0 Or ;
      ASCAN(cProbArray,'REFSRC4') <> 0
   parmtopass= parmtopass + Chr(13) + ' - Summary of Referrals'
Endif
If Ascan(cProbArray,'ENCDATE') <> 0 Or ;
      ASCAN(cProbArray,'SRVDATE') <> 0
   parmtopass= parmtopass + Chr(13) + ' - Encounters by Service Type-Total/Anonymous' + Chr(13) + ' - Encounters by Contract, Service Type-Total/Anonymous'
Else
   * to avoid duplicating "Encounters by Contract...", only check this if above stuff OK
   If Ascan(cProbArray,'ENCWORK1') <> 0 Or ;
         ASCAN(cProbArray,'ENCWORK2') <> 0 Or ;
         ASCAN(cProbArray,'SRVWORK1') <> 0 Or ;
         ASCAN(cProbArray,'SRVWORK2') <> 0
      parmtopass= parmtopass + Chr(13) + ' - Encounters by Contract, Service Type-Total/Anonymous'
   Endif
Endif

Return
***
**********************************************************
Function CDC_AID1
**********************************************************
Parameter cTC_ID, dCDCDate
Private lResult
lResult = .F.
dCDCDate = {}

If hiv_pos(cTC_ID)

   Select ;
      testres.tc_id , ;
      testres.testdate As Date ;
      FROM ;
      testres ;
      WHERE ;
      testtype = '06' ;
      AND testres.tc_id = cTC_ID ;
      AND ((!Empty(Count) And Count < 200) Or (!Empty(percent) And percent < 14)) And ;
      testres.testdate <= m.Date_to ;
      UNION ;
      SELECT ;
      ai_diag.tc_id , ;
      ai_diag.diagdate As Date ;
      FROM ;
      ai_diag ;
      WHERE ;
      !Empty(hiv_icd9) ;
      AND ai_diag.tc_id = cTC_ID  And ;
      ai_diag.diagdate <= m.Date_to ;
      INTO Array ;
      aCDC_AIDS ;
      ORDER By 2

   If _Tally <> 0
      lResult = .T.
      dCDCDate = aCDC_AIDS[1, 2]
   Endif
Endif

Return lResult

**********************************************************
Function hiv_pos
**********************************************************
*  Function.........: HIV_Pos
*  Created..........: 02/19/98   10:24:58
*) Description......: Detects if client is HIV positive
**********************************************************
Parameters cTC_ID
Private lHIV_Pos

Select ;
   hstat.hiv_pos;
   FROM ;
   hivstat, ;
   hstat ;
   WHERE ;
   hivstat.tc_id = cTC_ID ;
   AND hivstat.hivstatus = hstat.Code  And ;
   hivstat.effect_dt <= m.Date_to ;
   AND Dtos(hivstat.effect_dt) + hivstat.status_id + hivstat.hivstatus  = (Select Max(Dtos(effect_dt) + status_id + hivstatus) ;
   FROM ;
   hivstat f2 ;
   WHERE ;
   f2.tc_id = cTC_ID And ;
   f2.effect_dt <= m.Date_to) ;
   INTO Array ;
   aHivPos



If _Tally > 0
   lHIV_Pos = aHivPos(1)
Else
   lHIV_Pos = .F.
Endif

Return lHIV_Pos


*******************
Procedure Rpt_AiRef
*******************
If gcState='CT'
   Do rpt_refct
   Return
Endif

**VT 03/05/2007
*!*   IF USED('ref_cur')
*!*      USE IN ref_cur
*!*   ENDIF

If Used('tHold1')
   Use In thold1
Endif

Select Dist ;
   tc_id, anonymous ;
   FROM ;
   hold1 ;
   INTO Cursor ;
   thold1

***VT 03/05/2007
If _Tally = 0
   oApp.msg2user("NOTFOUNDG")
   Use In thold1
   Return .F.
Endif
****************************************************

* jss, 10/13/00, add code to filter on lcprog

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(ai_enc.program, "  + LCProg + ")" )
*ai_enc.program = lcprog ;

Select ;
   program.Descript  As Program    ,;
   SPACE(50)        As Category   ,;
   SPACE(45)        As Service    ,;
   SPACE(30)        As refstatus  ,;
   0000           As SrvStatCnt ,;
   0000           As CliCount   ,;
   Ai_Enc.Program    As Prog_id    ,;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,;
   ai_ref.Status                ,;
   ai_ref.ref_for                ;
   FROM ;
   thold1, ai_ref, Ai_Enc, Program ;
   WHERE ;
   thold1.tc_id   = ai_ref.tc_id And ;
   ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
   Ai_Enc.Act_id = ai_ref.Act_id And ;
   Ai_Enc.Program = Program.Prog_id ;
   &cWherePrg ;
   INTO Cursor tAllRef1a

* jss, 7/8/04, add next select to handle referrals made from syringe exchange screen [no encounter (ai_enc) recs here]
* jss, 7/9/04, use need_id to get unique recs from ai_ref for syringe exchange referrals

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(needlx.program, "  + LCProg + ")" )
* needlx.program = lcprog ;

Select ;
   program.Descript  As Program    ,;
   SPACE(50)        As Category   ,;
   SPACE(45)        As Service    ,;
   SPACE(30)        As refstatus  ,;
   0000           As SrvStatCnt ,;
   0000           As CliCount   ,;
   needlx.Program    As Prog_id    ,;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,;
   ai_ref.Status                ,;
   ai_ref.ref_for                ;
   FROM ;
   thold1, ai_ref, needlx, Program ;
   WHERE ;
   thold1.tc_id   = ai_ref.tc_id And ;
   ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
   EMPTY(ai_ref.Act_id) And ;
   needlx.need_id = ai_ref.need_id And ;
   needlx.tc_id = ai_ref.tc_id And ;
   needlx.Program = Program.Prog_id  ;
   &cWherePrg ;
   INTO Cursor tAllRef1b

**VT 03/21/2008  Dev Tick 4096 Program from CTR Part B when  no act _id
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(ai_ctr.program, "  + LCProg + ")" )

Select ;
   program.Descript  As Program    ,;
   SPACE(50)        As Category   ,;
   SPACE(45)        As Service    ,;
   SPACE(30)        As refstatus  ,;
   0000           As SrvStatCnt ,;
   0000           As CliCount   ,;
   ai_ctr.Program   As Prog_id    ,;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,;
   ai_ref.Status                ,;
   ai_ref.ref_for                ;
   FROM ;
   thold1, ai_ref, ctr_test, ai_ctr, Program ;
   WHERE ;
   thold1.tc_id   = ai_ref.tc_id And ;
   ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
   EMPTY(ai_ref.Act_id) And ;
   EMPTY(ctr_test.Act_id) And ;
   EMPTY(ctr_test.program_id) And ;
   ctr_test.ctr_id = ai_ctr.ctr_id And ;
   ctr_test.ctrtest_id = ai_ref.ctrtest_id And ;
   ai_ctr.tc_id = ai_ref.tc_id And ;
   ai_ctr.Program = Program.Prog_id  ;
   &cWherePrg ;
   INTO Cursor tAllRefCTR




**VT 01/08/2008
cWherePrg=''

* jss, 7/8/04, combine them
**VT 03/21/2008  Dev Tick 4096 add tAllRefCTR

Select * From tAllRef1a ;
   UNION All ;
   SELECT * From tAllRef1b ;
   Union All ;
   Select * From tAllRefCTR ;
   INTO Cursor ;
   tAllRef1

**VT 03/21/2008
Use In tAllRef1a
Use In tAllRef1b
Use In tAllRefCTR
* jss, 7/8/04, add 'AND Empty(ai_ref.need_id)' into query below to handle referrals from syringe exchange screen

**VT 03/21/2008 add  And  Empty(ctr_id) And Empty(ctrtest_id)  Dev Tick 4096

If Empty(LCProg)
   Select * From tAllRef1   ;
      UNION All  ;
      SELECT ;
      "†Program Unknown"    As Program    ,;
      SPACE(50)           As Category   ,;
      SPACE(45)           As Service    ,;
      SPACE(30)           As refstatus  ,;
      0000              As SrvStatCnt ,;
      0000              As CliCount   ,;
      SPACE(5)            As Prog_id    ,;
      ai_ref.tc_id                      ,;
      ai_ref.ref_cat                    ,;
      ai_ref.Status                  ,;
      ai_ref.ref_for                  ;
      FROM ;
      thold1, ai_ref ;
      WHERE ;
      thold1.tc_id   = ai_ref.tc_id And ;
      ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
      Empty(ai_ref.Act_id) ;
      AND Empty(ai_ref.need_id) ;
      And Empty(ctr_id) ;
      And Empty(ctrtest_id) ;
      INTO Cursor ;
      tRef Readwrite
Else
   Select * From tAllRef1 Into Cursor tRef Readwrite
Endif

***VT 03/05/2007
*!*   IF _tally = 0
*!*      oApp.msg2user("NOTFOUNDG")
*!*      USE IN tHold1
*!*      return .f.
*!*   ENDIF

* open lookup tables and set appropriate relationships
Sele 0
=OpenFile('ref_cat','code')
Sele 0
=OpenFile('ref_stat','code')
Sele 0
=OpenFile('ref_for','catcode')
*=ReOpenCur("tAllRef", "tRef")
Select tRef
Set Relat To ref_cat          Into ref_cat
Set Relat To Status           Into ref_stat AddI
Set Relat To ref_cat+ref_for     Into ref_for  AddI
Replace All Category    With Iif(Found('ref_cat'),  ref_cat.Descript,  '~Category Not Reported'), ;
   refstatus   With Iif(Found('ref_stat'), ref_stat.Descript, '~Status Not Reported'), ;
   Service     With Iif(Found('ref_for'),  ref_for.Descript,  '~Service Not Reported')


* count referrals by program+category+service+refstatus: this yields detail info of report
If Used('ref_cur')
   Use In Ref_Cur
Endif

Select ;
   program    ,;
   Category   ,;
   Service    ,;
   refstatus  ,;
   Prog_id    ,;
   COUNT(*)          As SrvStatCnt ,;
   COUNT(Dist tc_id) As CliCount,    ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   FROM ;
   tRef ;
   GROUP By ;
   1, 2, 3, 4 ;
   INTO Cursor ;
   Ref_Cur

****************************************************

* count distinct tc_ids by program+category
Select ;
   Prog_id ,;
   Category ,;
   COUNT(Distinct tc_id) As CliCount;
   FROM ;
   tRef ;
   GROUP By ;
   1, 2 ;
   INTO Cursor ;
   cattotal

Index On Prog_id+Category Tag progcat

Select Ref_Cur
Set Relation To Prog_id + Category Into cattotal

Select ;
   Prog_id ,;
   COUNT(Distinct tc_id) As CliCount;
   FROM ;
   tRef ;
   GROUP By ;
   1;
   INTO Cursor ;
   prgtotal

Index On Prog_id Tag Prog

Select Ref_Cur
Set Relation To Prog_id Into prgtotal AddI

*!*oApp.Msg2User('OFF')

cReportSelection = .agroup(nGroup)

gcRptName = 'rpt_airef'
*!*oApp.msg2user("OFF")

**VT 03/05/2007
Select Ref_Cur
Go Top
If Eof()
   oApp.msg2user('NOTFOUNDG')
Else
   *!*
   *!* added the following 05/27/2009
   *!* for crystal reports..
   *!* jim Power
   *!*


   Select r.*, C.CliCount As cat_total, p.CliCount As prg_total, ;
      gcagencyname As agencyname, oApp.gcversion As Version, ;
      DTOC(oApp.gdverdate) As verdate ;
      from Ref_Cur As r ;
      LEFT Outer Join cattotal As C On C.Prog_id+C.Category = r.Prog_id+r.Category;
      LEFT Outer Join prgtotal As p On p.Prog_id = r.Prog_id;
      into Cursor tmp

   Select tmp
   Copy To oapp.gcpath2temp+"summary_of_referrals.dbf"


*!*      Declare Integer ShellExecute In shell32.Dll ;
*!*         INTEGER hndWin, ;
*!*         STRING caction, ;
*!*         STRING cFilename, ;
*!*         STRING cParms, ;
*!*         STRING cDir, ;
*!*         INTEGER nShowWin

*!*      LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*      LcAction = "open"
*!*      Lcparms = "referrals_summary.rpt"
*!*      Lcdir = "i:\ursver6\airs_crreports\"
*!*      ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

   oApp.display_crystal_reports("referrals_summary.rpt")

   *!*         Do Case
   *!*         CASE lPrev = .f.
   *!*            Report Form rpt_airef To Printer Prompt Noconsole NODIALOG
   *!*         CASE lPrev = .t.     &&Preview
   *!*            oApp.rpt_print(5, .t., 1, 'rpt_airef', 1, 2)
   *!*         EndCase
Endif

* close cursors
*USE IN ref_cur
*USE IN cattotal
*USE IN prgtotal
If Used('tAllRef1a')
   Use In tAllRef1a
Endif
If Used('tAllRef1b')
   Use In tAllRef1b
Endif
If Used('tAllRef1')
   Use In tAllRef1
Endif
If Used('tAllRef')
   Use In tAllRef
Endif
If Used('tRef')
   Use In tRef
Endif

* close dbfs
Use In ai_ref
Use In ref_cat
Use In ref_for
Use In ref_stat
Use In Ai_Enc
Use In Program
If Used('needlx')
   Use In needlx
Endif

*******************
Procedure Rpt_AiEnc
*******************
*** VT 06/05 2007

*!*   DO CASE
*!*    CASE nGroup = 1 && Ryan White Eligible
*!*       lcExpr = " AND Aar_Report"
*!*    CASE nGroup = 2 && HIV Counseling/Prevention Eligible
*!*       lcExpr = " AND Ctp_Elig"
*!*    CASE nGroup = 3 && Ryan White and HIV Counseling/Prevention Eligible
*!*       lcExpr = " AND (Aar_Report OR Ctp_Elig)"
*!*    CASE nGroup = 4 && All Clients
*!*       lcExpr = ""
*!*   ENDCASE

Do Case
   Case nGroup = 1 && All Clients
      lcExpr = ""
   Case nGroup = 2 && Ryan White Eligible
      lcExpr = " AND Aar_Report"
   Case nGroup = 3 && HIV Counseling/Prevention Eligible
      lcExpr = " AND Ctp_Elig"
   Case nGroup = 4 && Ryan White and HIV Counseling/Prevention Eligible
      lcExpr = " AND (Aar_Report OR Ctp_Elig)"
Endcase

***VT End

* jss, add next line so we can relate into program file to get field enr_req
Select Descript As Program, Enr_Req From Program Into Cursor progdesc
Index On Program Tag Program

* create a list of clients that correspond to report selection
*!*   SELECT ;
*!*      a.*, ;
*!*      c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
*!*   FROM ;
*!*      ai_clien A, Ai_Prog B, Program C ;
*!*   WHERE ;
*!*      a.Tc_ID = b.Tc_ID ;
*!*      AND b.Program = c.Prog_ID ;
*!*      AND b.Start_Dt <= m.Date_To ;
*!*      &lcExpr ;
*!*   UNION ;
*!*   SELECT ;
*!*      a.*, ;
*!*      c.Prog_ID, c.Descript AS ProgrDesc, c.Aar_Report, c.Ctp_Elig ;
*!*   FROM ;
*!*      ai_clien A, Program C ;
*!*   WHERE ;
*!*      a.Int_Prog = c.Prog_ID ;
*!*      AND a.Placed_Dt <= m.Date_To ;
*!*      &lcExpr ;
*!*   INTO CURSOR ;
*!*      enc_client

* jss, 12/5/06, only grab tc_id and anonymous columns from ai_clien (can't union memo fields)
Select ;
   a.tc_id, a.anonymous, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
   FROM ;
   ai_clien a, ai_prog B, Program C ;
   WHERE ;
   a.tc_id = b.tc_id ;
   AND b.Program = C.Prog_id ;
   AND b.start_dt <= m.Date_to ;
   &lcExpr ;
   UNION ;
   SELECT ;
   a.tc_id, a.anonymous, ;
   C.Prog_id, C.Descript As progrdesc, C.Aar_Report, C.Ctp_Elig ;
   FROM ;
   ai_clien a, Program C ;
   WHERE ;
   a.int_prog = C.Prog_id ;
   AND a.placed_dt <= m.Date_to ;
   &lcExpr ;
   INTO Cursor ;
   enc_client

* select all encounter data within date range
*!*   SELECT DISTINCT Ai_Enc.Tc_ID, ;
*!*          Ai_Enc.Act_ID, ;
*!*         Ai_Enc.Enc_type   AS Enc_Code, ;
*!*         Ai_Enc.Serv_Cat   AS Serv_CCode, ;
*!*          Ai_Enc.Program    AS Prog_Id, ;
*!*          Program.Descript  AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          enc_client.Anonymous , ;
*!*          Ai_Enc.Act_dt     AS Act_dt ;
*!*     FROM enc_client, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_Type ;
*!*    WHERE Ai_Enc.Tc_ID    = enc_client.Tc_ID ;
*!*      AND Ai_Enc.Program  = lcProg ;
*!*      AND Ai_Enc.site     = cCSite ;
*!*      AND Ai_Enc.Program  = Program.Prog_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    INTO CURSOR tEncCur1

***VT 06/04/2007 change ai_enc.enc_type to enc_id

* 12/5/06, lookup encounter description in enc_list using ai_enc.enc_id
*!*   SELECT DISTINCT Ai_Enc.Tc_ID, ;
*!*          Ai_Enc.Act_ID, ;
*!*         Ai_Enc.Enc_type   AS Enc_Code, ;
*!*         Ai_Enc.Serv_Cat   AS Serv_CCode, ;
*!*          Ai_Enc.Program    AS Prog_Id, ;
*!*          Program.Descript  AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*          Enc_list.Description AS Enc_type, ;
*!*          enc_client.Anonymous , ;
*!*          Ai_Enc.Act_dt     AS Act_dt ;
*!*     FROM enc_client, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_list ;
*!*    WHERE Ai_Enc.Tc_ID    = enc_client.Tc_ID ;
*!*      AND Ai_Enc.Program  = lcProg ;
*!*      AND Ai_Enc.site     = cCSite ;
*!*      AND Ai_Enc.Program  = Program.Prog_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.enc_id = enc_list.enc_id ;
*!*      AND Ai_Enc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    INTO CURSOR tEncCur1

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " and Inlist(ai_enc.program, "  + LCProg + ")" )
* And ai_enc.program = lcprog ;

Select Distinct Ai_Enc.tc_id, ;
   Ai_Enc.Act_id, ;
   Ai_Enc.Enc_id   As Enc_Code, ;
   Ai_Enc.serv_cat As Serv_CCode, ;
   Ai_Enc.Program  As Prog_id, ;
   Program.Descript As Program, ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   enc_client.anonymous , ;
   Ai_Enc.act_dt As act_dt ;
FROM enc_client, ;
   Ai_Enc, ;
   Program, ;
   serv_cat, ;
   Enc_list ;
WHERE Ai_Enc.tc_id = enc_client.tc_id ;
   &cWherePrg ;
   AND Ai_Enc.site = cCSite ;
   AND Ai_Enc.Program = Program.Prog_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Ai_Enc.act_dt Between m.Date_from And m.Date_to ;
   INTO Cursor tEncCur1

cWherePrg =''

***VT End
******************************************************************
* jss, 9/98, must count enrolled vs. not enrolled in program, too
******************************************************************
* first, get those that were enrolled at time of service
Select    tEncCur1.*, ;
   .T. As Enrolled ;
   FROM   tEncCur1, ai_prog ;
   WHERE   tEncCur1.tc_id = ai_prog.tc_id ;
   AND   tEncCur1.Prog_id = ai_prog.Program ;
   AND   tEncCur1.act_dt  >= ai_prog.start_dt ;
   AND   (tEncCur1.act_dt <= ai_prog.end_dt Or Empty(ai_prog.end_dt));
   INTO Cursor tEncCur2

* jss, 9/6/2000, next cursor grabs any encounter where client was not enrolled at time of
*                service, but this client already had at least one enrolled encounter this period,
*                so we also count these encounters as enrolled

Select  tEncCur1.* ,;
   .T. As Enrolled ;
   FROM    tEncCur1 ;
   WHERE   Act_id          Not In    (Select Act_id From tEncCur2) ;
   AND   tc_id + Prog_id    In    (Select tc_id + Prog_id  From tEncCur2) ;
   INTO Cursor;
   tEncCur3

* everything else is considered not enrolled
Select    tEncCur1.*, ;
   .F. As Enrolled ;
   FROM    tEncCur1 ;
   WHERE   tc_id + Act_id Not In (Select tc_id + Act_id From tEncCur2) ;
   AND   tc_id + Act_id Not In (Select tc_id + Act_id From tEncCur3) ;
   INTO Cursor ;
   tEncCur4

* now combine those that    1) are currently enrolled (tEncCur2)
*                     2) were enrolled at some time in period (tEncCur3)
*                     3) were never enrolled in program during this period (tEncCur4)

Select    * ;
   FROM    tEncCur2 ;
   UNION ;
   SELECT    * ;
   FROM    tEncCur3 ;
   UNION ;
   SELECT    * ;
   FROM    tEncCur4 ;
   INTO Cursor ;
   EncSer_Cur

* jss, 9/98 create next cursor to count distinct enrolled and unenrolled clients at low level (Program+Serv_cat+enc_type)
Select Distinct ;
   Program  ,;
   serv_cat ,;
   Enc_type ,;
   tc_id    ,;
   Enrolled ,;
   anonymous ;
   FROM   EncSer_Cur ;
   INTO Cursor tProSerEnc
* now count the enrolled/not enrolled for program+serv_cat+enc_type
Select    Program  ,;
   serv_cat ,;
   Enc_type ,;
   SUM(Iif(Enrolled,1,0))                   As PSE_Enr   ,;
   SUM(Iif(Enrolled,0,1))                   As PSE_NEnr  ,;
   SUM(Iif(anonymous And Enrolled,1,0))     As PSE_AnEnr ,;
   SUM(Iif(anonymous And Not Enrolled,1,0)) As PSE_AnNEnr ;
   FROM   tProSerEnc ;
   INTO Cursor ProSerEnc ;
   GROUP By 1, 2, 3

Index On Program + serv_cat + Enc_type Tag ProSerEnc
Set Order To ProSerEnc

* jss, 9/98 create next cursor to count distinct enrolled and unenrolled clients at next higher level (Program+Serv_cat)
Select Distinct    ;
   Program   ,;
   serv_cat  ,;
   tc_id     ,;
   Enrolled  ,;
   anonymous  ;
   FROM   EncSer_Cur ;
   INTO Cursor tProgServ
* now count the enrolled/not enrolled for program+serv_cat
Select ;
   Program  ,;
   serv_cat ,;
   SUM(Iif(Enrolled,1,0))                   As ps_enr   ,;
   SUM(Iif(Enrolled,0,1))                   As ps_nenr  ,;
   SUM(Iif(anonymous And Enrolled,1,0))     As ps_anenr ,;
   SUM(Iif(anonymous And Not Enrolled,1,0)) As ps_annenr ;
   FROM   tProgServ     ;
   INTO Cursor ProgServ ;
   GROUP By 1, 2

Index On Program + serv_cat Tag ProgServ
Set Order To ProgServ

* jss, 9/98 create next cursor to count distinct enrolled and unenrolled clients at highest level (Program)
Select Distinct    ;
   Program   ,;
   tc_id     ,;
   Enrolled  ,;
   anonymous  ;
   FROM   EncSer_Cur ;
   INTO Cursor tProg
* now count the enrolled/not enrolled for program
Select ;
   Program,;
   SUM(Iif(Enrolled,1,0))                   As p_enr  , ;
   SUM(Iif(Enrolled,0,1))                   As p_nenr , ;
   SUM(Iif(anonymous And Enrolled,1,0))     As p_anenr, ;
   SUM(Iif(anonymous And Not Enrolled,1,0)) As P_AnNEnr ;
   FROM   tProg     ;
   INTO Cursor Prog ;
   GROUP By 1

Index On Program Tag Prog
Set Order To Prog

***************************************************************

* calculate number of services and clients within a service
* for anonymous clients
* jss, 9/1/2000: for "No Services Recorded", do not count the record as a service; make it zero
* jss, 4/10/03: sum ai_serv value for report
* jss, 9/15/06, ai_serv.value is now ai_serv.s_value

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*         Service.Code AS ServCode, ;
*!*          COUNT(*) AS NumbServAn, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
*!*         SUM(Ai_Serv.s_value) AS NumValueAn, ;
*!*         SUM(Ai_Serv.NumItems) AS NumbItemAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*   UNION ALL ;
*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*          "No Services Recorded" AS Service, ;
*!*         "ZZZZ" AS ServCode, ;
*!*          0 AS NumbServAn, ;
*!*          COUNT(DISTINCT EncSer_Cur.Tc_ID) AS NumCliAn, ;
*!*          0.00 AS NumValueAn, ;
*!*          0 AS NumbItemAn ;
*!*     FROM EncSer_Cur ;
*!*    WHERE EncSer_Cur.Anonymous=.T. ;
*!*      AND EncSer_Cur.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR EncServAn

* jss, 12/5/06, use ai_serv.service_id to lookup service description in serv_list
*               also, remove servcode line from top of union:       Service.Code AS ServCode
*               also, remove servcode line from bottom of union:       "ZZZZ" AS ServCode

Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description  As Service, ;
   COUNT(*) As NumbServAn, ;
   COUNT(Distinct EncSer_Cur.tc_id) As NumCliAn, ;
   SUM(Ai_Serv.s_value) As NumValueAn, ;
   SUM(Ai_Serv.NumItems) As NumbItemAn ;
   FROM EncSer_Cur, ;
   Ai_Serv, ;
   Serv_list ;
   WHERE EncSer_Cur.Act_id    = Ai_Serv.Act_id ;
   and Ai_Serv.service_id = Serv_list.service_id ;
   AND EncSer_Cur.anonymous = .T. ;
   GROUP By 1, 2, 3, 4 ;
   UNION All ;
   SELECT EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Padr("Z - No Services Recorded",80) As Service, ;
   0 As NumbServAn, ;
   COUNT(Distinct EncSer_Cur.tc_id) As NumCliAn, ;
   0.00 As NumValueAn, ;
   0 As NumbItemAn ;
   FROM EncSer_Cur ;
   WHERE EncSer_Cur.anonymous=.T. ;
   AND EncSer_Cur.Act_id Not In ;
   (Select Act_id From Ai_Serv) ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor EncServAn

* adding the alias changes what doesn't match
*INDEX ON Program + Serv_Cat + Enc_Type + ServCode TAG ProgEnc
* jss, 12/5/06, use service instead of servcode for index
Index On Program + serv_cat + Enc_type + Service Tag ProgEnc
Set Order To ProgEnc

***************************************************************
* 12/99, jss, calculate number of items within a service
* for all clients
* jss, 9/1/2000: for "No Services Recorded", do not count the record as a service; make it zero
* jss, 4/10/03: sum ai_serv value for report

**VT 11/01/2006
**Cast(SUM(Ai_Serv.s_Value) as N(10.2)) AS NumValue, ;
***Cast(0 As N(10.2)) AS NumValue, ;

Set Decimals To 2

** jss, 12/5/06, remove servcode lines below:      Service.Code AS ServCode....      "ZZZZ" AS ServCode

Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description As Service, ;
   COUNT(*) As NumbServ, ;
   COUNT(Distinct EncSer_Cur.tc_id) As NumClients, ;
   SUM(Ai_Serv.s_value)  As NumValue, ;
   SUM(Ai_Serv.NumItems) As NumbItem ;
   FROM EncSer_Cur, ;
   Ai_Serv, ;
   Serv_list ;
   WHERE EncSer_Cur.Act_id    = Ai_Serv.Act_id ;
   and Ai_Serv.service_id = Serv_list.service_id ;
   GROUP By 1, 2, 3, 4 ;
   UNION All ;
   SELECT EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Padr("Z - No Services Recorded",80) As Service, ;
   0 As NumbServ, ;
   COUNT(Distinct EncSer_Cur.tc_id) As NumClients, ;
   0.00 As NumValue, ;
   0 As NumbItem ;
   FROM EncSer_Cur ;
   WHERE EncSer_Cur.Act_id Not In ;
   (Select Act_id From Ai_Serv) ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor EncServ

*INDEX ON Program + Serv_Cat + Enc_Type + ServCode TAG ProgEnc
* jss, 12/5/06, use service instead of servcode for index
Index On Program + serv_cat + Enc_type + Service Tag ProgEnc
Set Order To ProgEnc
Set Relation To Program + serv_cat + Enc_type + Service Into EncServAn

**VT 11/01/2006
Set Decimals To

*************************
* jss, 3/10/03, add selects below to calculate counts for topics associated with services
*************************
* this select grabs topic count for anonymous for Program+Serv_Cat+Enc_type+Service where serv_id OR att_id is link to topic
* jss, 12/5/06, remove servcode lines below:      Service.Code AS ServCode

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          COUNT(*) AS NumbTopAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          Ai_topic, ;
*!*          Topics ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*      AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
*!*      AND Ai_Topic.code     = Topics.Code ;
*!*      AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
*!*            OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ;
*!*       tTopAn1

* jss, 12/5/06, use serv_list.description
Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description  As Service, ;
   COUNT(*) As NumbTopAn ;
   FROM EncSer_Cur, ;
   Ai_Serv, ;
   Serv_list, ;
   Ai_topic, ;
   Topics ;
   WHERE EncSer_Cur.Act_id    = Ai_Serv.Act_id ;
   AND Ai_Serv.service_id = Serv_list.service_id ;
   AND EncSer_Cur.anonymous = .T. ;
   AND Ai_topic.serv_cat = Topics.serv_cat ;
   AND Ai_topic.Code     = Topics.Code ;
   AND ((Ai_Serv.serv_id = Ai_topic.serv_id And Empty(Ai_topic.Att_id));
   OR (Ai_Serv.Att_id = Ai_topic.Att_id And !Empty(Ai_topic.Att_id))) ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor ;
   tTopAn1

* next 2 selects will create a zero count record for anonymous for all Program+Serv_Cat+Enc_type+Service combos with no associated topics
* jss, 12/5/06, remove servcode lines below:      Service.Code AS ServCode

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          0000000000 AS NumbTopAn ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND EncSer_Cur.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR tTopAn1a

Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description  As Service, ;
   0000000000 As NumbTopAn ;
   FROM EncSer_Cur, ;
   Ai_Serv, ;
   Serv_list ;
   WHERE EncSer_Cur.Act_id    = Ai_Serv.Act_id ;
   AND Ai_Serv.service_id = Serv_list.service_id ;
   AND EncSer_Cur.anonymous = .T. ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor tTopAn1a

Select * ;
   FROM tTopAn1a ;
   WHERE Program+serv_cat+Enc_type+Service ;
   NOT In (Select Program+serv_cat+Enc_type+Service From tTopAn1) ;
   INTO Cursor tTopAn2

* next cursor sets topic count to zero for anonymous for Program+Serv_Cat+Enc_type+Service combos for "no services recorded"
* jss, 12/5/06, remove servcode lines below:      "ZZZZ" AS ServCode

Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   PADR("Z - No Services Recorded",80) As Service, ;
   0000000000 As NumbTopAn ;
   FROM EncSer_Cur ;
   WHERE EncSer_Cur.anonymous=.T. ;
   AND EncSer_Cur.Act_id Not In ;
   (Select Act_id From Ai_Serv) ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor tTopAn3

* next cursor is merge of the three topic count cursors above (for anonymous)
Select    * ;
   FROM   tTopAn1 ;
   UNION All ;
   SELECT    * ;
   FROM   tTopAn2 ;
   UNION All ;
   SELECT    * ;
   FROM   tTopAn3 ;
   INTO Cursor ;
   ServTopAn

* relate EncServAn into ServTopAn
*INDEX ON Program + Serv_Cat + Enc_Type + ServCode TAG ProgEnc
Index On Program + serv_cat + Enc_type + Service Tag ProgEnc
Set Order To ProgEnc
Select EncServAn
*SET RELATION TO Program + Serv_Cat + Enc_Type + ServCode INTO ServTopAn ADDI
Set Relation To Program + serv_cat + Enc_type + Service Into ServTopAn AddI

* this select grabs topic count for Program+Serv_Cat+Enc_type+Service where serv_id OR att_id is link to topic
*       Service.Code AS ServCode

*!*   SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          COUNT(*) AS NumbTop ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          Ai_topic, ;
*!*          Topics ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND Ai_Topic.serv_cat = Topics.Serv_Cat ;
*!*      AND Ai_Topic.code     = Topics.Code ;
*!*      AND ((Ai_Serv.serv_id = Ai_Topic.Serv_id AND EMPTY(Ai_Topic.Att_id));
*!*            OR (Ai_Serv.att_id = Ai_Topic.att_id AND !EMPTY(Ai_topic.att_id))) ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ;
*!*       tTop1

Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description  As Service, ;
   COUNT(*) As NumbTop ;
   FROM EncSer_Cur, ;
   Ai_Serv, ;
   Serv_list, ;
   Ai_topic, ;
   Topics ;
   WHERE EncSer_Cur.Act_id    = Ai_Serv.Act_id ;
   AND Ai_Serv.service_id = Serv_list.service_id ;
   AND Ai_topic.serv_cat = Topics.serv_cat ;
   AND Ai_topic.Code     = Topics.Code ;
   AND ((Ai_Serv.serv_id = Ai_topic.serv_id And Empty(Ai_topic.Att_id));
   OR (Ai_Serv.Att_id = Ai_topic.Att_id And !Empty(Ai_topic.Att_id))) ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor ;
   tTop1

* next 2 selects set topic count to zero for Program+Serv_Cat+Enc_type+Service combos with no associated topics
*       Service.Code AS ServCode

*!*    SELECT EncSer_Cur.Program, ;
*!*         EncSer_Cur.Serv_Cat, ;
*!*         EncSer_Cur.Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          0000000000 AS NumbTop ;
*!*     FROM EncSer_Cur, ;
*!*          Ai_Serv, ;
*!*          Service ;
*!*    WHERE EncSer_Cur.Act_ID    = Ai_Serv.Act_ID ;
*!*      AND EncSer_Cur.Serv_CCode  = Service.Serv_Cat ;
*!*      AND (EncSer_Cur.Enc_Code = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    INTO CURSOR tTop1a

Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   Serv_list.Description  As Service, ;
   0000000000 As NumbTop ;
   FROM EncSer_Cur, ;
   Ai_Serv, ;
   Serv_list ;
   WHERE EncSer_Cur.Act_id    = Ai_Serv.Act_id ;
   AND Ai_Serv.service_id = Serv_list.service_id ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor tTop1a

Select * ;
   FROM tTop1a ;
   WHERE Program+serv_cat+Enc_type+Service ;
   NOT In (Select Program+serv_cat+Enc_type+Service From tTop1) ;
   INTO Cursor tTop2

* next cursor sets topic count to zero for Program+Serv_Cat+Enc_type+Service combos for "no services recorded"
*       "ZZZZ" AS ServCode
Select EncSer_Cur.Program, ;
   EncSer_Cur.serv_cat, ;
   EncSer_Cur.Enc_type, ;
   PADR("Z - No Services Recorded",80) As Service, ;
   0000000000 As NumbTop ;
   FROM EncSer_Cur ;
   WHERE EncSer_Cur.Act_id Not In ;
   (Select Act_id From Ai_Serv) ;
   GROUP By 1, 2, 3, 4 ;
   INTO Cursor tTop3

* next cursor is merge of the three topic count cursors above (for all clients)
Select    * ;
   FROM   tTop1 ;
   UNION All ;
   SELECT    * ;
   FROM   tTop2 ;
   UNION All ;
   SELECT    * ;
   FROM   tTop3 ;
   INTO Cursor ;
   ServTop

* relate EncServ into ServTop
*INDEX ON Program + Serv_Cat + Enc_Type + ServCode TAG ProgEnc
Index On Program + serv_cat + Enc_type + Service Tag ProgEnc
Set Order To ProgEnc
Select EncServ
*SET RELATION TO Program + Serv_Cat + Enc_Type + ServCode INTO ServTop ADDI
Set Relation To Program + serv_cat + Enc_type + Service Into ServTop AddI
***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for anonymous clients

Select Program, ;
   serv_cat, ;
   Enc_type, ;
   COUNT(Act_id) As AnonEnctrs, ;
   COUNT(Distinct tc_id) As AnonCliSvd ;
   FROM EncSer_Cur ;
   WHERE anonymous = .T. ;
   GROUP By 1, 2, 3 ;
   INTO Cursor ProgEncAn

Index On Program + serv_cat + Enc_type Tag ProgEnc
Set Order To ProgEnc

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for all clients

Select Program, ;
   serv_cat, ;
   Enc_type, ;
   COUNT(Act_id)         As NumbEnctrs, ;
   COUNT(Distinct tc_id) As EncCliSvd ;
   FROM EncSer_Cur ;
   GROUP By 1, 2, 3 ;
   ORDER By 1, 2, 3 ;
   INTO Cursor ProgEnc1

cReportSelection = .agroup(nGroup)

Select ProgEnc1.* , ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   From ProgEnc1 ;
   Into Cursor ;
   ProgEnc

***************************************************************
* calculate number of encounters and
* number of clients served within service category for all clients

Select Program, ;
   serv_cat, ;
   COUNT(Act_id) As Sum_SrvEnc, ;
   COUNT(Distinct tc_id) As Sum_SrvCli ;
   FROM EncSer_Cur ;
   GROUP By 1, 2 ;
   INTO Cursor ServCTot

Index On Program + serv_cat Tag serv_cat

***************************************************************
* calculate number of encounters and
* number of clients served within service category for anonymous clients

Select Program, ;
   serv_cat, ;
   COUNT(Act_id) As SumSrvEncA, ;
   COUNT(Distinct tc_id) As SumSrvCliA ;
   FROM EncSer_Cur ;
   WHERE anonymous = .T. ;
   GROUP By 1, 2 ;
   ORDER By 1, 2 ;
   INTO Cursor ServCTotAn

Index On Program + serv_cat Tag serv_cat

***************************************************************
* calculate number of encounters and
* number of clients served within program for all clients

Select Program, ;
   COUNT(Act_id)         As Sum_Enc, ;
   COUNT(Distinct tc_id) As Sum_Cli ;
   FROM EncSer_Cur ;
   GROUP By 1 ;
   INTO Cursor Prog_Tot

Index On Program Tag Program

***************************************************************
* calculate number of encounters and
* number of clients served within program for anonymous clients

Select Program, ;
   COUNT(Act_id) As Sum_Enc, ;
   COUNT(Distinct tc_id) As Sum_Cli ;
   FROM EncSer_Cur ;
   WHERE anonymous = .T. ;
   GROUP By 1 ;
   INTO Cursor Prog_TotAn

Index On Program Tag Program

*!*
*!* following added 05/27/2009
*!* for crystal reports
*!* jim power
*!*

Select p.*, e.Service,e.NumbServ, e.NumClients, e.NumValue, e.NumbItem, pe.AnonEnctrs, pe.AnonCliSvd, ;
   pse.PSE_Enr, pse.PSE_NEnr, pse.PSE_AnEnr, pse.PSE_AnNEnr, st.Sum_SrvEnc, st.Sum_SrvCli,;
   se.SumSrvEncA, se.SumSrvCliA, ps.ps_enr, ps.ps_nenr, ps.ps_anenr, ps.ps_annenr, ;
   pt.Sum_Enc, pt.Sum_Cli, pgt.Sum_Enc, pgt.Sum_Cli, pg.p_enr, pg.p_nenr, pg.p_anenr,;
   pd.Enr_Req, sv.NumbTop, gcagencyname As agencyname,oApp.gcversion As Version, ;
   DTOC(oApp.gdverdate) As verdate  ;
   FROM ProgEnc As p;
   LEFT Outer Join EncServ As e On e.Program+e.serv_cat+e.Enc_type = p.Program + p.serv_cat + p.Enc_type ;
   LEFT Outer Join ProgEncAn As pe On pe.Program+pe.serv_cat+pe.Enc_type = p.Program+p.serv_cat+p.Enc_type ;
   LEFT Outer Join ProSerEnc As pse On pse.Program+pse.serv_cat+pse.Enc_type = p.Program+p.serv_cat+p.Enc_type ;
   LEFT Outer Join ServCTot As st On st.Program+st.serv_cat = p.Program+p.serv_cat ;
   LEFT Outer Join ServCTotAn As se On se.Program+se.serv_cat = p.Program+p.serv_cat ;
   LEFT Outer Join ProgServ As ps On ps.Program+ps.serv_cat = p.Program+p.serv_cat ;
   LEFT Outer Join Prog_Tot As pt On pt.Program = p.Program;
   LEFT Outer Join Prog_TotAn As pgt On pgt.Program = p.Program;
   LEFT Outer Join Prog As pg On pg.Program = p.Program;
   LEFT Outer Join progdesc As pd On pd.Program = p.Program;
   LEFT Outer Join ServTop As sv On sv.Program + sv.serv_cat + sv.Enc_type + sv.Service = e.Program + e.serv_cat + e.Enc_type + e.Service ;
   into Cursor temp



* jss, 7/12/01, add cursor progdesc to set relation below
*****
*!*   SELECT Progenc
*!*   SET RELATION TO Program + Serv_Cat + Enc_Type INTO EncServ, ;
*!*                   Program + Serv_Cat + Enc_Type INTO ProgEncAn, ;
*!*                   Program + Serv_Cat + Enc_Type INTO ProSerEnc, ;
*!*                   Program + Serv_Cat INTO ServCTot, ;
*!*                   Program + Serv_Cat INTO ServCTotAn, ;
*!*                   Program + Serv_Cat INTO ProgServ, ;
*!*                   Program INTO Prog_Tot, ;
*!*                   Program INTO Prog_TotAn, ;
*!*                   Program INTO Prog, ;
*!*                   Program INTO ProgDesc

*!*
*!*   SET SKIP TO EncServ
*!*oApp.Msg2User('OFF')

* jss, 4/28/2000, add 'Info Not Found' message
If Eof('PROGENC')
   oApp.msg2user('NOTFOUNDG')
   Return .F.
Else
   Select * From temp Group By Program, serv_cat, Enc_type,Service  ;
      INTO Cursor tmp
   Copy To oapp.gcpath2temp+"summary_of_services.dbf"

*!*      Declare Integer ShellExecute In shell32.Dll ;
*!*         INTEGER hndWin, ;
*!*         STRING caction, ;
*!*         STRING cFilename, ;
*!*         STRING cParms, ;
*!*         STRING cDir, ;
*!*         INTEGER nShowWin

*!*      LcFileName = "i:\ursver6\project\libs\display_reports.exe"
*!*      LcAction = "open"
*!*      Lcparms = "encounters_by_service.rpt"
*!*      Lcdir = "i:\ursver6\airs_crreports\"
*!*      ShellExecute(0,LcAction,LcFileName,Lcparms,Lcdir,1)

   oApp.display_crystal_reports("encounters_by_service.rpt")

Endif

*!*   gcRptName = 'rpt_aienc'
*!*   Do Case
*!*   CASE lPrev = .f.
*!*      Report Form rpt_aienc To Printer Prompt Noconsole NODIALOG
*!*   CASE lPrev = .t.     &&Preview
*!*      oApp.rpt_print(5, .t., 1, 'rpt_aienc', 1, 2)
*!*   EndCase

Return

*******************
Procedure Rpt_CnEnc
*******************

* jss, 12/5/06, as in Rpt_AiEnc above, we will now use enc_list.description for enc_type and serv_list.description for service
If Used('tHold1')
   Use In thold1
Endif

Select Dist tc_id, anonymous ;
   FROM hold1 ;
   INTO Cursor thold1

***************************************************************
* calculate number of services and clients within a service
* for anonymous clients

*!*   SELECT Conenc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*         Service.Descript  AS Service, ;
*!*          COUNT(*) AS NumbServAn, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumCliAn ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_Type, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          ConEnc ;
*!*      WHERE ConEnc.Tc_ID = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND ConEnc.Act_ID   = Ai_Serv.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Serv_Cat = Service.Serv_Cat ;
*!*      AND (Ai_Enc.Enc_Type = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND tHold1.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*   UNION ALL ;
*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program , ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*          Enc_Type.Descript AS Enc_Type, ;
*!*          "Z - No Services Recorded" AS Service, ;
*!*          0 AS NumbServAn, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumCliAn ;
*!*     FROM tHold1, ;
*!*          Ai_enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_type, ;
*!*          ConEnc ;
*!*      WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND ConEnc.Act_Dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND tHold1.Anonymous=.T. ;
*!*      AND ConEnc.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR EncServAn

* jss, to prevent the key from being 240 characters (too long), only use first 75 of service description (longest in table currently is only 55)
Select Conenc.AllCont, ;
   Program.Descript As Program, ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   Left(Serv_list.Description,75)  As Service, ;
   COUNT(*) As NumbServAn, ;
   COUNT(Distinct Ai_Enc.tc_id) As NumCliAn ;
   FROM thold1, ;
   Ai_Enc, ;
   Program, ;
   serv_cat, ;
   Enc_list, ;
   Ai_Serv, ;
   Serv_list, ;
   Conenc ;
   WHERE Conenc.tc_id = thold1.tc_id ;
   AND Conenc.Program  = Program.Prog_id ;
   AND Conenc.Act_id = Ai_Enc.Act_id ;
   AND Conenc.Act_id   = Ai_Serv.Act_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Ai_Serv.service_id = Serv_list.service_id ;
   AND Conenc.act_dt Between m.Date_from And m.Date_to ;
   AND thold1.anonymous = .T. ;
   GROUP By 1, 2, 3, 4, 5 ;
   UNION All ;
   SELECT Conenc.AllCont, ;
   Program.Descript As Program , ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   Padr("Z - No Services Recorded",75) As Service, ;
   0 As NumbServAn, ;
   COUNT(Distinct Ai_Enc.tc_id) As NumCliAn ;
   FROM thold1, ;
   Ai_Enc, ;
   Program, ;
   serv_cat, ;
   Enc_list, ;
   Conenc ;
   WHERE Conenc.tc_id    = thold1.tc_id ;
   AND Conenc.Program  = Program.Prog_id ;
   AND Conenc.Act_id = Ai_Enc.Act_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Conenc.act_dt Between m.Date_from And m.Date_to ;
   AND thold1.anonymous=.T. ;
   AND Conenc.Act_id Not In ;
   (Select Act_id From Ai_Serv) ;
   GROUP By 1, 2, 3, 4, 5 ;
   ORDER By 1, 2, 3, 4 ;
   INTO Cursor EncServAn

* adding the alias changes what doesn't match
Index On AllCont + Program + serv_cat + Enc_type + Service Tag ProgEnc
Set Order To ProgEnc

***************************************************************
* calculate number of services and clients within a service
* for all clients
*!*   SELECT Conenc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          Service.Descript  AS Service, ;
*!*          COUNT(*) AS NumbServ, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumClients ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_Type, ;
*!*          Ai_Serv, ;
*!*          Service, ;
*!*          ConEnc ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND ConEnc.Act_ID   = Ai_Serv.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Ai_Enc.Serv_Cat = Service.Serv_Cat ;
*!*      AND (Ai_Enc.Enc_Type = Service.Enc_Type  OR  EMPTY(Service.Enc_Type)) ;
*!*      AND Ai_Serv.Service = Service.code ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*   UNION ALL ;
*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program , ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*          Enc_Type.Descript AS Enc_Type, ;
*!*          Padr("Z - No Services Recorded",80) AS Service, ;
*!*          0 AS Numbserv, ;
*!*          COUNT(DISTINCT Ai_Enc.Tc_ID) AS NumClients ;
*!*     FROM tHold1, ;
*!*          Ai_enc, ;
*!*          Program, ;
*!*          Serv_Cat, ;
*!*          Enc_type, ;
*!*          ConEnc ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND ConEnc.Act_ID NOT IN ;
*!*          (SELECT Act_ID FROM Ai_Serv) ;
*!*    GROUP BY 1, 2, 3, 4, 5 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR EncServ
*!*

* jss, to prevent the key from being 240 characters (too long), only use first 75 of service description (longest in table currently is only 55)

Select Conenc.AllCont, ;
   Program.Descript As Program, ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   Left(Serv_list.Description,75)  As Service, ;
   COUNT(*) As NumbServ, ;
   COUNT(Distinct Ai_Enc.tc_id) As NumClients ;
   FROM thold1, ;
   Ai_Enc, ;
   Program, ;
   serv_cat, ;
   Enc_list, ;
   Ai_Serv, ;
   Serv_list, ;
   Conenc ;
   WHERE Conenc.tc_id    = thold1.tc_id ;
   AND Conenc.Program  = Program.Prog_id ;
   AND Conenc.Act_id = Ai_Enc.Act_id ;
   AND Conenc.Act_id   = Ai_Serv.Act_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Ai_Serv.service_id = Serv_list.service_id ;
   AND Conenc.act_dt Between m.Date_from And m.Date_to ;
   GROUP By 1, 2, 3, 4, 5 ;
   UNION All ;
   SELECT Conenc.AllCont, ;
   Program.Descript As Program , ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   Padr("Z - No Services Recorded",75) As Service, ;
   0 As NumbServ, ;
   COUNT(Distinct Ai_Enc.tc_id) As NumClients ;
   FROM thold1, ;
   Ai_Enc, ;
   Program, ;
   serv_cat, ;
   Enc_list, ;
   Conenc ;
   WHERE Conenc.tc_id    = thold1.tc_id ;
   AND Conenc.Program  = Program.Prog_id ;
   AND Conenc.Act_id = Ai_Enc.Act_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Conenc.act_dt Between m.Date_from And m.Date_to ;
   AND Conenc.Act_id Not In ;
   (Select Act_id From Ai_Serv) ;
   GROUP By 1, 2, 3, 4, 5 ;
   ORDER By 1, 2, 3, 4 ;
   INTO Cursor EncServ

* adding the alias changes what doesn't match
Index On AllCont + Program + serv_cat + Enc_type + Service Tag ProgEnc
Set Order To ProgEnc
Set Relation To AllCont + Program + serv_cat + Enc_type + Service Into EncServAn

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for anonymous clients

*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          COUNT(Conenc.Act_ID) AS AnonEnctrs, ;
*!*         COUNT(DIST tHold1.tc_id) AS AnonCliSvd, ;
*!*         ContrInf.Descript, ;
*!*         PADR(ALLTRIM(a.Descript),40) AS Program1, ;
*!*         Contract.Start_Dt, Contract.End_Dt, ConType.Descript AS ConType ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Program A, ;
*!*          Serv_Cat, ;
*!*          Enc_Type, ;
*!*          ConEnc, ;
*!*          Contract, ;
*!*          ContrInf, ;
*!*          ConType ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Contract.Cid = ConEnc.AllCont ;
*!*      AND Contract.Con_ID = ContrInf.Cid ;
*!*      AND ContrInf.ConType = ConType.Code ;
*!*      AND ConEnc.AllProg = a.Prog_ID ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*      AND tHold1.Anonymous = .T. ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ProgEncAn

Select Conenc.AllCont, ;
   Program.Descript As Program, ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   COUNT(Conenc.Act_id) As AnonEnctrs, ;
   COUNT(Dist thold1.tc_id) As AnonCliSvd, ;
   ContrInf.Descript, ;
   PADR(Alltrim(a.Descript),40) As Program1, ;
   Contract.start_dt, Contract.end_dt, ConType.Descript As ConType ;
   FROM thold1, ;
   Ai_Enc, ;
   Program, ;
   Program a, ;
   serv_cat, ;
   Enc_list, ;
   Conenc, ;
   Contract, ;
   ContrInf, ;
   ConType ;
   WHERE Conenc.tc_id    = thold1.tc_id ;
   AND Conenc.Program  = Program.Prog_id ;
   AND Conenc.Act_id = Ai_Enc.Act_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Contract.Cid = Conenc.AllCont ;
   AND Contract.Con_ID = ContrInf.Cid ;
   AND ContrInf.ConType = ConType.Code ;
   AND Conenc.AllProg = a.Prog_id ;
   AND Conenc.act_dt Between m.Date_from And m.Date_to ;
   AND thold1.anonymous = .T. ;
   GROUP By 1, 2, 3, 4 ;
   ORDER By 1, 2, 3, 4 ;
   INTO Cursor ProgEncAn

Index On AllCont + Program + serv_cat + Enc_type Tag ProgEnc
Set Order To ProgEnc

***************************************************************
* calculate number of encounters and
* number of clients served within an encounter type for all clients

*!*   SELECT ConEnc.AllCont, ;
*!*         Program.Descript AS Program, ;
*!*         Serv_Cat.Descript AS Serv_Cat, ;
*!*         Enc_type.Descript AS Enc_type, ;
*!*          COUNT(Conenc.Act_ID) AS NumbEnctrs, ;
*!*         COUNT(DIST tHold1.tc_id) AS EncCliSvd, ;
*!*         ContrInf.Descript, ;
*!*         PADR(ALLTRIM(a.Descript),40) AS Program1, ;
*!*         Contract.Start_Dt, Contract.End_Dt, ConType.Descript AS ConType ;
*!*     FROM tHold1, ;
*!*          Ai_Enc, ;
*!*          Program, ;
*!*          Program A, ;
*!*          Serv_Cat, ;
*!*          Enc_Type, ;
*!*          ConEnc, ;
*!*          Contract, ;
*!*          ContrInf, ;
*!*          ConType ;
*!*    WHERE ConEnc.Tc_ID    = tHold1.Tc_ID ;
*!*      AND ConEnc.Program  = Program.Prog_ID ;
*!*      AND ConEnc.Act_ID = Ai_Enc.Act_ID ;
*!*      AND Ai_Enc.Serv_Cat = Serv_Cat.Code ;
*!*      AND Ai_Enc.Serv_Cat = Enc_Type.Serv_Cat ;
*!*      AND Ai_Enc.Enc_Type = Enc_Type.Code ;
*!*      AND Contract.Cid = ConEnc.AllCont ;
*!*      AND Contract.Con_ID = ContrInf.Cid ;
*!*      AND ContrInf.ConType = ConType.Code ;
*!*      AND ConEnc.AllProg = a.Prog_ID ;
*!*      AND ConEnc.Act_dt BETWEEN m.Date_From AND m.Date_To ;
*!*    GROUP BY 1, 2, 3, 4 ;
*!*    ORDER BY 1, 2, 3, 4 ;
*!*    INTO CURSOR ProgEnc1

Select Conenc.AllCont, ;
   Program.Descript As Program, ;
   serv_cat.Descript As serv_cat, ;
   Enc_list.Description As Enc_type, ;
   COUNT(Conenc.Act_id) As NumbEnctrs, ;
   COUNT(Dist thold1.tc_id) As EncCliSvd, ;
   ContrInf.Descript, ;
   PADR(Alltrim(a.Descript),40) As Program1, ;
   Contract.start_dt, Contract.end_dt, ConType.Descript As ConType ;
   FROM thold1, ;
   Ai_Enc, ;
   Program, ;
   Program a, ;
   serv_cat, ;
   Enc_list, ;
   Conenc, ;
   Contract, ;
   ContrInf, ;
   ConType ;
   WHERE Conenc.tc_id    = thold1.tc_id ;
   AND Conenc.Program  = Program.Prog_id ;
   AND Conenc.Act_id = Ai_Enc.Act_id ;
   AND Ai_Enc.serv_cat = serv_cat.Code ;
   AND Ai_Enc.Enc_id = Enc_list.Enc_id ;
   AND Contract.Cid = Conenc.AllCont ;
   AND Contract.Con_ID = ContrInf.Cid ;
   AND ContrInf.ConType = ConType.Code ;
   AND Conenc.AllProg = a.Prog_id ;
   AND Conenc.act_dt Between m.Date_from And m.Date_to ;
   GROUP By 1, 2, 3, 4 ;
   ORDER By 1, 2, 3, 4 ;
   INTO Cursor ProgEnc1

Select ProgEnc1.* , ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   From ProgEnc1 ;
   Into Cursor ;
   ProgEnc

************AllCont*****************
Select AllCont, ;
   SUM(NumbEnctrs) As Sum_Enc, ;
   SUM(EncCliSvd) As Sum_Cli ;
   FROM ProgEnc ;
   GROUP By 1 ;
   INTO Cursor Con_Tot

Index On AllCont Tag AllCont

Select AllCont, ;
   SUM(AnonEnctrs) As Sum_Enc, ;
   SUM(AnonCliSvd) As Sum_Cli ;
   FROM ProgEncAn ;
   GROUP By 1 ;
   INTO Cursor Con_TotAn

Index On AllCont Tag AllCont

************Program*****************

Select AllCont, Program, ;
   SUM(NumbEnctrs) As Sum_Enc, ;
   SUM(EncCliSvd)  As Sum_Cli ;
   FROM ProgEnc ;
   GROUP By 1, 2 ;
   INTO Cursor Prog_Tot

Index On AllCont + Program Tag Program

Select AllCont, Program, ;
   SUM(AnonEnctrs) As Sum_Enc, ;
   SUM(AnonCliSvd) As Sum_Cli ;
   FROM ProgEncAn ;
   GROUP By 1, 2 ;
   INTO Cursor Prog_TotAn

Index On AllCont + Program Tag Program

************Serv_Cat*****************


Select AllCont, Program, serv_cat, ;
   SUM(NumbEnctrs) As Sum_Enc, ;
   SUM(EncCliSvd)  As Sum_Cli ;
   FROM ProgEnc ;
   GROUP By 1, 2, 3 ;
   INTO Cursor Sc_Tot

Index On AllCont + Program + serv_cat Tag serv_cat

Select AllCont, Program, serv_cat, ;
   SUM(AnonEnctrs) As Sum_Enc, ;
   SUM(AnonCliSvd) As Sum_Cli ;
   FROM ProgEncAn ;
   GROUP By 1, 2, 3 ;
   INTO Cursor Sc_TotAn

Index On AllCont + Program + serv_cat Tag serv_cat

Select ProgEnc
Set Relation To AllCont + Program + serv_cat + Enc_type Into EncServ, ;
   AllCont + Program + serv_cat + Enc_type Into ProgEncAn, ;
   AllCont Into Con_Tot, ;
   AllCont Into Con_TotAn, ;
   AllCont + Program Into Prog_Tot, ;
   AllCont + Program Into Prog_TotAn, ;
   AllCont + Program + serv_cat Into Sc_Tot, ;
   AllCont + Program + serv_cat Into Sc_TotAn
Set Skip To EncServ

*!*oApp.Msg2User('OFF')

cReportSelection = .agroup(nGroup)

If Recc() = 0
   oApp.msg2user('NOTFOUNDG')
   Return .T.
Endif

gcRptName = 'rpt_cnenc'
Do Case
   Case lPrev = .F.
      Report Form Rpt_CnEnc To Printer Prompt Noconsole Nodialog
   Case lPrev = .T.     &&Preview
      oApp.rpt_print(5, .T., 1, 'rpt_cnenc', 1, 2)
Endcase

Use In thold1

Return

*******************
Procedure rpt_refct
*******************
If Used('tHold1')
   Use In thold1
Endif

Select Dist ;
   tc_id, anonymous ;
   FROM ;
   hold1 ;
   INTO Cursor ;
   thold1

If _Tally = 0
   oApp.msg2user("NOTFOUNDG")
   Use In thold1
   Return .F.
Endif
****************************************************

**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(ai_enc.program, "  + LCProg + ")" )
*ai_enc.program = lcprog ;


Select ;
   program.Descript  As Program    ,;
   serv_cat.Descript As servcatdes ,;
   Enc_type.Descript As enctypedes ,;
   SPACE(50)           As Category   ,;
   SPACE(45)           As Service    ,;
   SPACE(30)           As refstatus  ,;
   0000                 As SrvStatCnt ,;
   0000                 As CliCount   ,;
   Ai_Enc.Program    As Prog_id    ,;
   Ai_Enc.serv_cat, ;
   Ai_Enc.Enc_type, ;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,;
   ai_ref.Status                ,;
   ai_ref.ref_for                ;
   FROM ;
   thold1, ai_ref, Ai_Enc, Program, serv_cat, Enc_type ;
   WHERE ;
   thold1.tc_id   = ai_ref.tc_id And ;
   ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
   Ai_Enc.Act_id = ai_ref.Act_id And ;
   Ai_Enc.serv_cat = serv_cat.Code And ;
   Ai_Enc.serv_cat = Enc_type.serv_cat And ;
   Ai_Enc.Enc_type = Enc_type.Code And ;
   Ai_Enc.Program = Program.Prog_id ;
   &cWherePrg ;
   INTO Cursor tAllRef1a

* jss, 7/9/04, use need_id to get unique recs from ai_ref for syringe exchange referrals
**VT 01/08/2007
cWherePrg = Iif(Empty(LCProg),"", " And Inlist(needlx.program, "  + LCProg + ")" )
*needlx.program = lcprog ;

Select ;
   program.Descript  As Program    ,;
   PADR('Needle Exchange',30) As servcatdes ,;
   PADR('Exhange',50)           As enctypedes ,;
   SPACE(50)           As Category   ,;
   SPACE(45)           As Service    ,;
   SPACE(30)           As refstatus  ,;
   0000                 As SrvStatCnt ,;
   0000                 As CliCount   ,;
   needlx.Program    As Prog_id    ,;
   'ZZZZZ'            As serv_cat , ;
   'ZZZ'               As Enc_type ,;
   ai_ref.tc_id                    ,;
   ai_ref.ref_cat                  ,;
   ai_ref.Status                ,;
   ai_ref.ref_for                ;
   FROM ;
   thold1, ai_ref, needlx, Program ;
   WHERE ;
   thold1.tc_id   = ai_ref.tc_id And ;
   ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
   EMPTY(ai_ref.Act_id) And ;
   needlx.need_id = ai_ref.need_id And ;
   needlx.tc_id = ai_ref.tc_id And ;
   needlx.Program = Program.Prog_id ;
   &cWherePrg ;
   INTO Cursor tAllRef1b

* jss, 7/8/04, combine them
Select * From tAllRef1a ;
   UNION All ;
   SELECT * From tAllRef1b ;
   INTO Cursor ;
   tAllRef1

**VT 01/08/2008
cWherePrg = ''

* jss, 7/8/04, add 'AND Empty(ai_ref.need_id)' into query below to handle referrals from syringe exchange screen
* jss, 7/28/04, add serv_cat and enc_type to select below for CT
If Empty(LCProg)
   Select * From tAllRef1   ;
      UNION All  ;
      SELECT ;
      "†Program Unknown"    As Program    ,;
      SPACE(30)         As servcatdes,;
      SPACE(50)         As enctypedes,;
      SPACE(50)           As Category   ,;
      SPACE(45)           As Service    ,;
      SPACE(30)           As refstatus  ,;
      0000              As SrvStatCnt ,;
      0000              As CliCount   ,;
      SPACE(5)            As Prog_id    ,;
      SPACE(5)            As serv_cat   ,;
      SPACE(3)            As Enc_type   ,;
      ai_ref.tc_id                      ,;
      ai_ref.ref_cat                    ,;
      ai_ref.Status                  ,;
      ai_ref.ref_for                  ;
      FROM ;
      thold1, ai_ref ;
      WHERE ;
      thold1.tc_id   = ai_ref.tc_id And ;
      ai_ref.ref_dt Between m.Date_from And m.Date_to And ;
      Empty(ai_ref.Act_id) ;
      AND Empty(ai_ref.need_id) ;
      INTO Cursor ;
      tRef Readwrite
Else
   Select * From tAllRef1 Into Cursor tRef Readwrite
Endif

If _Tally = 0
   oApp.msg2user("NOTFOUNDG")
   Use In thold1
   Return .F.
Endif
* open lookup tables and set appropriate relationships
Sele 0
=OpenFile('ref_cat','code')
Sele 0
=OpenFile('ref_stat','code')
Sele 0
=OpenFile('ref_for','catcode')
*=ReOpenCur("tAllRef", "tRef")
Select tRef
Set Relat To ref_cat          Into ref_cat
Set Relat To Status           Into ref_stat AddI
Set Relat To ref_cat+ref_for     Into ref_for  AddI
Replace All Category With Iif(Found('ref_cat'),  ref_cat.Descript,  '~Category Not Reported'), ;
   refstatus   With Iif(Found('ref_stat'), ref_stat.Descript, '~Status Not Reported'), ;
   Service     With Iif(Found('ref_for'),  ref_for.Descript,  '~Service Not Reported')


* count referrals by program+servcatdes+enctypedes+category+service+refstatus: this yields detail info of report
Select ;
   program    ,;
   servcatdes ,;
   enctypedes ,;
   Category   ,;
   Service    ,;
   refstatus  ,;
   Prog_id    ,;
   serv_cat   ,;
   Enc_type   ,;
   COUNT(*)          As SrvStatCnt ,;
   COUNT(Dist tc_id) As CliCount,   ;
   cTitle As cTitle, ;
   cReportSelection As cReportSelection, ;
   lcTitle1 As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   m.Date_from As Date_from, ;
   m.Date_to As Date_to, ;
   cOrderBy As sort_order ;
   FROM ;
   tRef ;
   GROUP By ;
   1, 2, 3, 4, 5, 6 ;
   INTO Cursor ;
   Ref_Cur

****************************************************

* count distinct tc_ids by program+serv_cat+enc_type+category
Select ;
   Prog_id ,;
   serv_cat,;
   Enc_type,;
   Category ,;
   COUNT(Distinct tc_id) As CliCount;
   FROM ;
   tRef ;
   GROUP By ;
   1, 2, 3, 4 ;
   INTO Cursor ;
   cattotal

Index On Prog_id+serv_cat+Enc_type+Category Tag prgscetcat

Select Ref_Cur
Set Relation To Prog_id + serv_cat+Enc_type+Category Into cattotal

* count distinct tc_ids by program+serv_cat+enc_type
Select ;
   Prog_id ,;
   serv_cat,;
   Enc_type,;
   COUNT(Distinct tc_id) As CliCount;
   FROM ;
   tRef ;
   GROUP By ;
   1, 2, 3 ;
   INTO Cursor ;
   ettotal

Index On Prog_id+serv_cat+Enc_type Tag prgscet

Select Ref_Cur
Set Relation To Prog_id + serv_cat Into ettotal AddI

* count distinct tc_ids by program+serv_cat
Select ;
   Prog_id ,;
   serv_cat,;
   COUNT(Distinct tc_id) As CliCount;
   FROM ;
   tRef ;
   GROUP By ;
   1, 2 ;
   INTO Cursor ;
   sctotal

Index On Prog_id+serv_cat Tag prgsc

Select Ref_Cur
Set Relation To Prog_id + serv_cat Into sctotal AddI

* count distinct tc_ids by program
Select ;
   Prog_id ,;
   COUNT(Distinct tc_id) As CliCount;
   FROM ;
   tRef ;
   GROUP By ;
   1;
   INTO Cursor ;
   prgtotal

Index On Prog_id Tag Prog

Select Ref_Cur
Set Relation To Prog_id Into prgtotal AddI

*!*oApp.Msg2User('OFF')


cReportSelection = .agroup(nGroup)

gcRptName = 'rpt_refct'
Do Case
   Case lPrev = .F.
      Report Form rpt_refct To Printer Prompt Noconsole Nodialog
   Case lPrev = .T.     &&Preview
      oApp.rpt_print(5, .T., 1, 'rpt_refct', 1, 2)
Endcase

* close cursors
*USE IN ref_cur
*USE IN cattotal
*USE IN ettotal
*USE IN sctotal
*USE IN prgtotal
If Used('tAllRef1a')
   Use In tAllRef1a
Endif
If Used('tAllRef1b')
   Use In tAllRef1b
Endif
If Used('tAllRef1')
   Use In tAllRef1
Endif
*IF USED('tAllRef')
*   USE IN tAllRef
*ENDIF
If Used('tRef')
   Use In tRef
Endif

* close dbfs
Use In ai_ref
Use In ref_cat
Use In ref_for
Use In ref_stat
Use In Ai_Enc
Use In Program
If Used('needlx')
   Use In needlx
Endif

Return
