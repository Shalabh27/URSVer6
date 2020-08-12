Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              Crit , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)
cCSite    = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   EndIf
EndFor


PRIVATE gchelp
gchelp = "Staff Alpha Listing Screen"
cTitle = "Staff Alpha Listing"
cDate = DATE()
cTime = TIME()

If Used('roster')
   Use in roster
EndIf
   
=OPENFILE("teams"  ,"CODE")
=OPENFILE("JOBTYPE"  ,"CODE")
=OPENFILE("SITE"     ,"SITE_ID")
=OPENFILE("STAFF"    , "STAFF_ID")
=OPENFILE("USERPROF" , "Worker_id")
=OPENFILE("LANGUAGE" , "CODE","LANG1")
=OPENFILE("LANGUAGE" , "CODE","LANG2")
=OPENFILE("PROGRAM" , "PROG_id")

MyFilt = "STAFF.STAFF_ID = USERPROF.STAFF_ID" + ;
  IIF(!EMPTY(cCSite)," and USERPROF.SITE = cCSite","")

* jss, 8/2/01, remove this line from select so we can get all staff, including past...report will change to include end date
**	" AND EMPTY(STAFF.DATE_FNSH)" + ;

DO CASE
CASE nOrder = 1
	cOrder = "STAFF.LAST, STAFF.FIRST"
CASE nOrder = 2
	cOrder = "USERPROF.SITE, STAFF.LAST, STAFF.FIRST"
CASE nOrder = 3
	cOrder = "USERPROF.PROG_ID, STAFF.LAST, STAFF.FIRST"
ENDCASE

* jss, 8/2/01, add staff.date_fnsh to fields selected, will display on report
SELECT ;
	staff.last, staff.first, staff.mi, ;
	userprof.worker_id, userprof.prog_id, userprof.site, ;
	staff.prim_lang, staff.sec_lang, ;
	userprof.jobtype, userprof.paid, ;
	staff.date_start, staff.date_fnsh, userprof.superid,staff.staffnote, staff.team, ;
   Space(30) as site_des, ;
   Space(30) as Prim_des, ;
   Space(30) as sec_des, ;
   Space(35) as super_name, ;
   Space(30) as job_desc, ;
   Space(30) as prg_desc, ;
   Space(40) as team_desc, ;
   .f. as Own_Cases, ;
   000000 as nAllWork, ;
   000000 as nCurWork, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;   
FROM ;
	staff, userprof ;
WHERE ;
	&MyFilt ;
INTO CURSOR ;
	ros_cur ;
ORDER BY ;
	&cOrder
   

USE IN 0 (DBF('ROS_CUR')) AGAIN  ALIAS roster1 EXCLUSIVE

If Used("ROS_CUR")
   Use in ROS_CUR
EndIf


SELECT roster1
oldname = SPACE(35)
SCAN
	IF LAST+first=oldname
		REPL LAST  WITH SPACE(20)
		REPL first WITH SPACE(15)
	ELSE
		oldname = LAST+first
	ENDIF
ENDSCAN

SELECT USERPROF
SET RELA TO STAFF_ID INTO STAFF

Select roster1    
Go top
SET RELATION TO superid INTO Userprof ADDITIVE
Replace roster1.super_name with oApp.FormatName(Staff.last, Staff.first) all

Select roster1
SET RELATION TO Site           INTO Site   
Go top
Replace roster1.site_des with site.descript1 all
Set Relation to


Select roster1  
SET RELATION TO Roster1.jobtype INTO Jobtype
Go top
Replace roster1.job_desc with jobtype.descript all
Select roster1
Go top
Replace roster1.Own_Cases with jobtype.Own_Cases all   
Set Relation to 

Select roster1
SET RELATION TO Prim_lang      INTO LANG1 
Go top
Replace roster1.prim_des with lang1.descript all 
Set Relation to


Select roster1
SET RELATION TO Sec_lang       INTO LANG2 
Go top
Replace roster1.sec_des with lang2.descript all 
Set Relation to


Select roster1
SET RELATION TO PROG_ID        INTO PROGRAM 
Go top
Replace roster1.prg_desc with program.descript all 
Set Relation to

Select roster1
Set Rela To team Into teams 
Go top
Replace roster1.team_desc with teams.descript all
Set Relation to

**VT 08/27/2010 Dev Tick 4807  add readwrite
DO CASE
Case nGroup = 1 

	Select Count(worker_id) as nAllWork ; 
	 From roster1 ;
	Into Cursor grand_t 
   
   Select roster1
   replace roster1.nAllWork with grand_t.nAllWork all
   
	Select Count(worker_id) as nCurWork ; 
	From roster1 ;
	Where Empty(date_fnsh) ;
	Into Cursor curr_t
	
   Select roster1 
   Replace roster1.nCurWork with curr_t.nCurWork all
    
	Select roster1.* ,;
          "All Staff" as lcTitle ;
   from roster1 ;
   Into cursor roster readwrite
CASE nGroup=2

	Select Count(worker_id) as nAllWork  ; 
	From roster1, ;
		jobtype ;
	Where jobtype.Own_Cases And ;
		roster1.jobtype = jobtype.jobtype ;
	Into Cursor grand_t 
   
   Select roster1
   Replace roster1.nAllWork  with grand_t.nAllWork all
    
	Select Count(worker_id) as nCurWork ; 
	From roster1, ;
		jobtype ;
	Where jobtype.Own_Cases And ;
		roster1.jobtype = jobtype.jobtype And ;
		Empty(roster1.date_fnsh) ; 
	Into Cursor curr_t 
   
   Select roster1
	Replace roster1.nCurWork with curr_t.nCurWork all
   
	Select roster1.* ,;
          "Case Workers Only" as lcTitle ;
   from roster1 ;
   where Own_Cases = .t.;
   Into cursor roster readwrite
	
CASE nGroup=4

	Select Count(worker_id) as nAllWork ; 
	From roster1 ;
	Where paid = 2 ;
	Into Cursor grand_t 
   
   Select roster1
   Replace roster1.nAllWork with grand_t.nAllWork all
   
	Select Count(worker_id) as nCurWork ; 
	From roster1 ;
	Where paid = 2 And ;
		Empty(roster1.date_fnsh) ; 
	Into Cursor curr_t 
   
   Select roster1
	Replace roster1.nCurWork with curr_t.nCurWork all
   
	Select roster1.* ,;
          "Paid Staff Only" as lcTitle ;
   from roster1 ;
   where paid =2 ;
   into cursor roster readwrite
 	
Case nGroup = 3

	Select Count(worker_id) as nAllWork ; 
	From roster1 ;
	Where Empty(date_fnsh) ;
	Into Cursor grand_t 
   
   Select roster1
   Replace roster1.nAllWork with grand_t.nAllWork all
   
	Select Count(worker_id) as nCurWork ; 
	From roster1 ;
	Where Empty(date_fnsh) ;
	Into Cursor curr_t 
	
   Select roster1
   Replace roster1.nCurWork with curr_t.nCurWork all
   
	Select roster1.* ,;
          "Current Staff Only" as lcTitle ;
   from roster1 ;
   where Empty(date_fnsh) ;
   into cursor roster readwrite
EndCase


If Used('roster1')
   Use in roster1
EndIf

If Used('curr_t')
   Use in curr_t 
EndIf

If Used('grand_t')
   Use in grand_t
EndIf

**VT 08/27/2010 Dev Tick 4807 
Do Case
Case nOrder = 1
	Index On Upper(Alltrim(last)+Alltrim(first)) Tag fn
Case nOrder = 2
	Index On Alltrim(site) + Upper(Alltrim(last)+Alltrim(first)) Tag fn
CASE nOrder = 3
	Index On Alltrim(prog_id) + Upper(Alltrim(last)+Alltrim(first)) Tag fn
EndCase
         
************************ Print the Report ***********************************
oApp.Msg2User('OFF')
Select roster
**VT 08/27/2010 Dev Tick 4807
Set Order To fn

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
            gcRptName = 'rpt_staff'
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_staff  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     
                     oApp.rpt_print(5, .t., 1, 'rpt_staff', 1, 2)
            ENDCASE
EndIf

If Used('jobtype')
   Use in jobtype
EndIf

If Used('userprof')   
   Use in userprof
endif   

