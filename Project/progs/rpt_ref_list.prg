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

lcorg_id = ""
lcServCat  = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCORG_ID"
      lcorg_id = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCSERVCAT"
      lcServCat = aSelvar2(i, 2)
   EndIf
EndFor


PRIVATE gcHelp,SELHOLD
SELHOLD = SELECT()
gcHelp = "Referral Library List Screen"

cDate = DATE()
cTime = TIME()
cTitle = "Referral Library List"

PRIVATE cWhere
LCORG_ID = TRIM(LCORG_ID)
 DO CASE 
	CASE nGroup = 2
		cWhere = " AND A.ACTIVE = 1"
	CASE nGroup = 3
		cWhere = " AND A.ACTIVE = 2"
	OTHERWISE
		cWhere = ""
 ENDCASE
* jss, 9/12/00, add ref_srce.placement (logical) to cursor (and also to report detail line)
 SELECT ;
 	A.CODE, ;
 	A.NAME, ;
 	A.ADDR1, ;
 	A.ADDR2, ;
 	A.CITY, ;
 	A.STATE, ;
 	A.ZIPCODE, ;
 	A.COUNTY, ;
	TRANSFORM(A.TELEPHONE, "@R (999) 999-9999") AS TELEPHONE, ;
   IIF(!EMPTY(a.ADDR1),TRIM(a.addr1) +  IIF(!EMPTY(a.addr2), TRIM(a.addr2) , "") + "," + ;
   TRIM(a.city) + IIF(!Empty(a.state),", ","") + a.state + "  " + ;
   IIF(LEN(TRIM(a.zipcode))<=5, a.zipcode,TRANSFORM(a.zipcode, "@R 99999-9999")),' ') as address, ;
	A.REF_IN, ; 
	A.REF_OUT, ;
	A.ACTIVE, ;
	A.SERVICE, ;
	A.Placement, ;
	B.CODE AS CNTCCODE, ;
	B.LAST_NAME, ;
	B.FIRST_NAME, ;
	B.MI, ;
	B.TITLE_JOB, ;
	TRANSFORM(B.TELEPHONE, "@R (999) 999-9999") AS CONTPHONE, ;
	B.EXTN AS CONTEXTN, ;
	a.email, ;
	a.website ;
 FROM ;
	REF_SRCE A, REF_CNTC B;
 WHERE ;
	A.CODE = B.REFSOURCE ;
	AND A.CODE = TRIM(LCORG_ID);
	&cWhere ;
 Into Cursor RefDat1a

 SELECT ;
 	A.CODE, ;
 	A.NAME, ;
 	A.ADDR1, ;
 	A.ADDR2, ;
 	A.CITY, ;
 	A.STATE, ;
 	A.ZIPCODE, ;
 	A.COUNTY, ;
	TRANSFORM(A.TELEPHONE, "@R (999) 999-9999") AS TELEPHONE, ;
   IIF(!EMPTY(a.ADDR1),TRIM(a.addr1) +  IIF(!EMPTY(a.addr2), TRIM(a.addr2) , "") + "," + ;
   TRIM(a.city) + IIF(!Empty(a.state),", ","") + a.state + "  " + ;
   IIF(LEN(TRIM(a.zipcode))<=5, a.zipcode,TRANSFORM(a.zipcode, "@R 99999-9999")),' ') as address, ;
	A.REF_IN, ; 
	A.REF_OUT, ;
	A.ACTIVE, ;
	A.SERVICE, ;
	A.Placement, ;
	SPACE(5)  AS CNTCCODE, ;
	SPACE(20) AS LAST_NAME, ;
	SPACE(15) AS FIRST_NAME, ;
	SPACE(10) AS MI, ;
	SPACE(30) AS TITLE_JOB, ;
	SPACE(14) AS CONTPHONE, ;
	SPACE(4)  AS CONTEXTN, ;
	a.email, ;
	a.website ;
 FROM ;
	REF_SRCE A ;
 WHERE ;
	NOT EXIST (SELECT * FROM REF_CNTC WHERE REF_CNTC.REFSOURCE = A.CODE) ;
	AND A.CODE = TRIM(LCORG_ID) ;
	&cWhere ;
 INTO CURSOR ;
	REFDAT1b 
	
Select * from RefDat1a ;
Union ;
Select * from RefDat1b ;
Into Cursor ;
	RefDat1 ;	
 ORDER BY ;
	2

If Used('RefData')
   Use in RefData
EndIf

 SELECT refdat1.*, ;
        Padr(oApp.FormatName(last_name, first_name, mi), 45, ' ') as full_name, ;  
        ref_cat.descript as serv_type, ; 
        lcTitle as lcTitle, ;
        Crit as  Crit, ;   
        cDate as cDate, ;
        cTime as cTime ;
 FROM REFDAT1 ;
      left outer join ref_cat on ;
         refdat1.service = ref_cat.code ;
 WHERE SERVICE = TRIM(LCSERVCAT);
 INTO CURSOR REFDATA

oApp.msg2user('OFF')

SELECT REFDATA
Go Top
 
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
            gcRptName = 'rpt_ref_list'
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_ref_list  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.   
                     oApp.rpt_print(5, .t., 1, 'rpt_ref_list', 1, 2)
            ENDCASE
EndIf

SET CENT ON
If Used('RefDat1a')
   Use in RefDat1a
EndIf

If Used('RefDat1b')
   Use in RefDat1b
EndIf

If Used('RefDat1')
   Use in RefDat1
EndIf

RELEASE SELHOLD
RETURN
