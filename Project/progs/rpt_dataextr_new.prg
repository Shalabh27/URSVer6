Parameters;
   lPrev,;     && Preview     
   aSelvar1,;  && select parameters from selection list
   nOrder,;    && order by number
   nGroup,;    && report selection number   
   lcTitle1,;  && report selection description   
   Date_from,; && from date
   Date_to,;   && to date   
   Crit,;      && name of param
   lnStat,;    && selection(Output)  page 2
   cOrderBy    && order by description

ldtDateTimeStart=Datetime()
lcDate=Ttod(ldtDateTimeStart)
lcTime=Time(ldtDateTimeStart)
cTotalRunTime=''
cSavePrefs=''
m.cPath2DBF=''
m.cPath2XML=''
m.cPath2CSV=''

Set EngineBehavior 90

Set Delete On
Set Safe Off
gctc='00002'
              
Acopy(aSelvar1, aSelvar2)

Private gchelp
gchelp = "AIRS Data Extract Screen"

lcTitle1=Left(lcTitle1, Len(lcTitle1)-1)

lcSite_ID=''
lcStatType=''
lcProg_ID=''
m.Crit=Crit
m.lcTitle1=lcTitle1

For i=1 To Alen(aSelvar2,1)
   If Rtrim(aSelvar2[i,1])="LCSITE_ID"
      lcSite_ID=aSelvar2[i,2]
   Endif
   If Rtrim(aSelvar2[i,1])="CSTATTYPE"
      lcStatType=aSelvar2[i,2]
   Endif
    
   If Rtrim(aSelvar2[i,1])="LCPROG_ID"
      lcProg_ID=aSelvar2[i,2]
   EndIf
EndFor

* Data Extract Structure Report
If lnStat=(1)
   mDataEngine=Sys(3099,70)
   Do Rpt_Extr_Str
   mDataEngine=Sys(3099,90)
   Return

EndIf 

lcSite_ID=''
lcProg_ID=''

Dimension aMinDate(1)
aMinDate[1]={01/01/1980}
Select Min(act_dt) From ai_enc Into Array aMinDate

=dbcOpenTable('airs_data_extract_files','STEP_ORDER')
Select ;
   airs_data_extract_files.row_id,;
   airs_data_extract_files.step_order, ;
   data_extract_stats.selected, ;
   airs_data_extract_files.table_name, ;
   airs_data_extract_files.table_description, ;
   Iif(data_extract_stats.selected=(1),'In Queue  ','          ') As process_status, ;
   data_extract_stats.last_run_duration, ;
   data_extract_stats.last_run_start, ;
   data_extract_stats.last_run_end, ;
   airs_data_extract_files.extract_order, ;
   data_extract_stats.output_dbf, ;
   data_extract_stats.output_xml, ;
   data_extract_stats.output_csv, ;
   airs_data_extract_files.allow_manual_selection, ;
   .f. As isLocked ;
From airs_data_extract_files ;
Join data_extract_stats On data_extract_stats.row_id = airs_data_extract_files.row_id;
Order By step_order ;
Into Cursor _curXfiles ReadWrite

Go Top
noutput_dbf=_curXfiles.output_dbf
noutput_xml=_curXfiles.output_xml
noutput_csv=_curXfiles.output_csv
Locate for selected=(1)
If Found()
   nSavePref=1
Else
   nSavePref=0
EndIf

Go Top

Index On selected Tag selected
Index On table_name tag table_name Addit
Index On Upper(table_description) Tag table_desc Addit
Index On step_order Tag step_order Addit
Set Order To step_order
Go Top 

oSelectionForm=NewObject('airs_data_extract_form2','extracts')
With oSelectionForm
 .grid_2_use_with_sort1.setall('ToolTipText','Extracts')
 .grid_2_use_with_sort1.setall('StatusBarText','Extracts')
 .dEncStartDate.ddate_value.Value=Gomonth(Date(),-12)
 .dEncEndDate.ddate_value.Value=Date()
 .cStatType=lcStatType    
 .cDataObjectName='lBegin'
 .btn_selectFolder.Btn_getfolder1.cselectedfolder=Iif(Directory('extracts'),FullPath('extracts'),'')
 If lnStat=(2)
    .lMustCreateUrsData=.t.
    .setURSDataMode()
 EndIf 
 .chk_dbf.Value=noutput_dbf
 .chk_xml.Value=noutput_xml
 .chk_csv.Value=noutput_csv
 .chkSaveSelections.Value=nSavePref
EndWith 
Release noutput_dbf, noutput_xml, noutput_csv, nSavePref

lBegin=.t.
oSelectionForm.Show()
ldtDateTimeEnded=Datetime()

If lBegin=.f.
   oApp.msg2user("MESSAGE",'AIRS Data Extract Process was Cancelled!' )
   Return
EndIf 

Release aMinDate
Select _curxfiles
Go Top

Do Case
   Case lnStat=1
     * Data Extract and Client Listing Report
      Do Rpt_Extr_Str
      
   Case lnStat=2
     * Data Extract Structure Report
      Do rpt_client_list

      
   Case lnStat=3
      * Display Complete Message Only
      Do rpt_dataExCompleted With ldtDateTimeStart, ldtDateTimeEnded
      
EndCase
mDataEngine=Sys(3099,90)

Return
*


Procedure rpt_dataExCompleted
Parameters dtlStarted,  dtlEnded

Select _curXFinal
Go Top 
m.cPath2DBF=path2dbf
m.cPath2XML=path2xml
m.cPath2CSV=path2csv

cTitle = "URS Data Extracts"
cReportSelection='Report'

Create Cursor curDummy ;
   (dtStarted T, ;
    dtEnded T, ;
    cDate Date, ;
    cTime C(8), ;
    as_of_d Date,;
    Crit memo, ;
    cReportSelection memo,;
    cReportDuration C(15),;
    cPrefSaved C(03),;
    cPath2DBF C(110),;
    cPath2XML C(110),;
    cPath2CSV C(110),;
    cDBFList M,;
    cXMLList M,;
    cCSVList M)

Scatter Fields cDBFList, cXMLList, cCSVList Memvar Memo Blank

Select _curXFinal
Go Top
Scan
    m.cDBFList=m.cDBFList+_curXFinal.dbfcol+Chr(13)
    m.cXMLList=m.cXMLList+_curXFinal.xmlcol+Chr(13)
    m.cCSVList=m.cCSVList+_curXFinal.csvcol+Chr(13)
EndScan 

Insert Into curDummy ;
   (dtStarted,;
    dtEnded,;
    cDate,;
    cTime,;
    as_of_d,;
    Crit,;
    cReportSelection,;
    cReportDuration,;
    cPrefSaved,;
    cPath2DBF,;
    cPath2XML,;
    cPath2CSV,;
    cDBFList,;
    cXMLList,;
    cCSVList);
Values ;
   (dtlStarted, ;
    dtlEnded, ;
    Date(), ;
    Time(), ;
    Date_from, ;
    m.Crit, ;
    m.lcTitle1,;
    cTotalRunTime,;
    cSavePrefs,;
    m.cPath2DBF,;
    m.cPath2XML,;
    m.cPath2CSV,;
    m.cDBFList,;
    m.cXMLList,;
    m.cCSVList)

Select curDummy
Go Top
*!*   Go Top In _curXFinal
*!*   Select _curXFinal

If lPrev=(.f.)
   Report Form rpt_dataxcompleted2 To Printer Prompt Noconsole NODIALOG
   
Else
   oApp.rpt_print(5, .t., 1, 'rpt_dataxcompleted2', 1, 2)
EndIf

Go Top in curDummy
Go Top In _curXFinal
Select _curXFinal

Return 

* 
Procedure rpt_client_list
cTitle = "URS Data Extracts"
cReportSelection='Report'

cDate=Date()
cTime=Time()

Select _curURSDATA.tc_id, ;
       _curURSDATA.client_id, ;
       _curURSDATA.last_name, ;
       _curURSDATA.first_name, ;
       _curURSDATA.mi, ;
       _curURSDATA.id_no, ;
       _curURSDATA.dob, ;
       _curURSDATA.casestat,;
       _curPrograms.program_ds,;
       _curPrograms.cur_worker, ;
       cTitle as cTitle, ;
       cReportSelection as cReportSelection, ;
       m.lcTitle1 as lcTitle, ;
       m.crit as Crit, ;   
       cDate as cDate, ;
       cTime as cTime, ;
       Date_from as as_of_d ;
From _curURSData;
Left Outer Join _curPrograms On _curURSData.tc_id=_curPrograms.tc_id;
Order by 1 ,2 , 5 ;
Into Cursor ursdcurs Readwrite 

Index on Upper(Last_name+First_name) Tag Name
Go Top 

If lPrev=(.f.)
   Report Form rpt_dataextr2 To Printer Prompt Noconsole NODIALOG 
   
Else
   oApp.rpt_print(5, .t., 1, 'rpt_dataextr2', 1, 2)
   
EndIf

Return 


* Data Extract Structure Report
Procedure Rpt_Extr_Str

Private nSaveArea, lCloseTable1
nSaveArea=Select()

lCloseTable1=.t.
=dbcOpenTable('UrsDstr','',@lCloseTable1)

Select UrsDstr.*, ;
   Str(UrsDstr.Order) as StrOrder, ;
   Date() as cDate, ;
   Time() as cTime  ;
From UrsDstr ;
Into Cursor DstrCurs ;
Order by UrsDstr.File, StrOrder

Select DstrCurs
Go top

gcRptName = 'rpt_extr_str'
If lPrev=(.f.)
   Report Form rpt_extr_str To Printer Prompt Noconsole NODIALOG
Else      
   oApp.rpt_print(5, .t., 1, 'rpt_extr_str', 1, 2)
EndIf 

Return 

