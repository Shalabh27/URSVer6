***************************************************************
* General Purpose Functions
***************************************************************

***************************************************************
**** Function OpenFile.
**** This function is used to open a DBF with tag. If the file;
**** is currently OPEN it sets the TAG AND leaves you IN that;
**** WORK area.
****    PARAMETERS:
****       cFile - name of .dbf file to open
****       cTag  - tag to set order to (can be left empty or omited)
****       cAlias- alias to assign (can be left empty or omited)
****    RETURNS:
****      .T. if file WAS open before
****      .F. if file WAS NOT open before (opened by openfile)
***************************************************************
FUNCTION openfile
PARAMETER cFile, cTag, cAlias
PRIVATE lWasOpen

IF TYPE("cTag") <> "C"
	ctag = ""
ENDIF

IF TYPE("cAlias") <> "C" .OR. EMPTY(calias)
	calias = cfile
ENDIF

IF USED(calias)
	SELECT (calias)
	IF !EMPTY(ctag)
		SET ORDER TO TAG &ctag
	ENDIF
	lWasOpen = .t.
ELSE
	SELECT 0
	USE (LOCFILE(cfile+".dbf","DBF","Where is "+UPPER(cfile)+"?"));
		AGAIN ALIAS (calias)
	IF !EMPTY(ctag)
		SET ORDER TO TAG &ctag
	ENDIF
	lWasOpen = .f.
ENDIF

RETURN lWasOpen
*

***************************************************************
**** Function SetRelation
**** This function is used to set or clear relations.
**** PARAMETERS:
****	cParentFile	- file (alias) to set relations from
****	cChildFile	- file (alias) to set relations into
****	cChildOrder	- order in a child file
****	cRelatExpr	- relation expration
****	lAdditive   - .T. for ADDITIVE
**** If all parameters are passed - relation is set. 
**** If child order is missing - relation is cleared. If in this
**** situation child file is passed - only this relation is cleared,
**** otherwise - all relations are cleared
***************************************************************
FUNCTION SetRelation
PARAMETER cParentFile, cChildFile, cChildOrder, cRelatExpr, lAdditive
PRIVATE cAdditive

IF TYPE("cParentFile") <> "C" .OR. Empty(cParentFile)
	RETURN .f.
ENDIF

* If child order is not passed - clear relations
IF TYPE("cChildOrder") <> "C" .OR. Empty(cChildOrder)
	=OpenFile(cParentFile)
	
	* if child file is passed - clear just this relation, 
	* otherwise clear all relations
	IF TYPE("cChildFile") <> "C" .OR. Empty(cChildFile)
		SET RELATION TO 
	ELSE
		SET RELATION OFF INTO (cChildFile)
	ENDIF
ELSE
	IF TYPE("cChildFile") <> "C" .OR. Empty(cChildFile)
		RETURN .f.
	ENDIF
	
	IF TYPE("cRelatExpr") <> "C" .OR. Empty(cRelatExpr)
		RETURN .f.
	ENDIF
	
	cAdditive = IIF(lAdditive, "ADDITIVE", "")
	
	=OpenFile(cChildFile, cChildOrder)
	=OpenFile(cParentFile)
	SET RELATION TO &cRelatExpr INTO (cChildFile) &cAdditive
ENDIF

Return .t.

**********************************************************
FUNCTION ReopenCur
**********************************************************
*  Function.........: ReopenCur
*) Description......: Opens an SQL cursor in another area, modifyable
*  Parameters.......: cCursor, cAlias
**********************************************************
PARAMETERS cCursor, cAlias, lCloseCur

IF Type("cCursor") <> "C" .OR. ;
		Empty(cCursor) .OR. ;
		Type("cAlias") <> "C" .OR. ;
		Empty(cAlias) .OR. ;
		!USED(cCursor)
	RETURN .f.
ENDIF

IF USED(cAlias)
	USE IN (cAlias)
ENDIF

SELECT 0
USE (DBF(cCursor)) AGAIN EXCLUSIVE ALIAS &cAlias

IF lCloseCur
	USE IN (cCursor)
ENDIF

RETURN .t.
*-EOF ReopenCur

***************************************************************
**** Function CloseFile.
**** This function is used to close a DBF if it is open.
***************************************************************
FUNCTION closefile
PARAMETER cFile

IF USED(cFile)
	use in (cFile)
ENDIF
RETURN
*

**************************************************
FUNCTION Close_em
PARAMETERS cProgram

PRIVATE cOldArea
cOldArea=ALIAS()

=OPENFILE('CLOSE_EM','PROGRAM')

IF SEEK(cProgram,'CLOSE_EM')

	SCAN WHILE CLOSE_EM.PROGRAM = cProgram AND !EOF('CLOSE_EM')
			IF USED(TRIM(CLOSE_EM.FILE2CLOSE))
				USE  IN (TRIM(CLOSE_EM.FILE2CLOSE))
			ENDIF
	ENDSCAN

ENDIF

IF Used(cOldArea)
	SELECT (cOldArea)
ENDIF
RETURN
*

******************************************************
FUNCTION Save_Env
NOTE: Purpose: Save the table environment for the calling program ;
					so that it may be restored by the Rest_Env function. ;
					Use this function if you will be opening tables ;
					or changing tags, for currently open files, from the ;
					CALLED program. ;
		The array that holds your current environment must be declared	;
		by the CALLING program. ;
		Stru of FUNCTION is: ;
		1 - Array to build on. If initital array is to small this program;
			 will increase its size. ;
		2 - File that you want to use	;
		3 - Tag name ;
		4 - File Alias, if desired ;
		5 - If you enter cProgram. This function will open CLOSE_EM and ;
			 open the file contained there-in. ;
		ALL PARMS MUST BE CHARACTER TYPES ;
;
		Stru of array is: ;
		Col 1 - File names ;
			 2 - Tag names for files currently open ;
			 3 - Close file at end of run ;

PARAMETER cArray, cFile2Open, cTag2Open, cAlias, cProgram

nRows = ALEN((cArray),1)

* Find the first unused row

lBuild = .T.
FOR ix = 1 TO nRows
		IF EMPTY(&cArray[ix,1])
			lBuild = .F.
			EXIT
		ENDIF
ENDFOR

* Increase the array size if needed
IF lBuild
	DECLARE &cArray[nRows+1,3]
ENDIF

IF USED(cFile2Open)
	SELECT (cFile2Open)
	&cArray[ix,1] = cFile2Open
	&cArray[ix,2] = TAG()
	&cArray[ix,3] = .T.
	SET ORDER TO (cTag2Open)
ELSE
	=OpenFile(cFile2Open, cTag2Open, cAlias)
	&cArray[ix,1] = cFile2Open
	&cArray[ix,2] = ''
	&cArray[ix,3] = .F.
ENDIF

RETURN
*

********************************************************8
FUNCTION Rest_Env
NOTE: Restore the table environment saved by Save_Env

PARAMETER cArray

nRows = ALEN((cArray),1)

FOR ix = 1 TO nRows
		IF !EMPTY(&cArray[ix,1])
			IF !(&cArray[ix,3])
				USE IN (&cArray[ix,1])
			ELSE
				SELECT (&cArray[ix,1])
				SET ORDER TO (&cArray[ix,2])
			ENDIF
		ENDIF
ENDFOR
RETURN

********************************************************
FUNCTION Save_Env2
NOTE: makes an array of all open files(or cursor) with their tags and recnos
PARAMETER aFiles

PRIVATE nCount, nTotal, i
nCount = 0
nTotal = Select(1)

FOR i=1 TO nTotal
	IF !Empty(Alias(i))
		nCount = nCount + 1
		DIMENSION aFiles[nCount, 3]
		aFiles[nCount, 1] = Alias(i)
		aFiles[nCount, 2] = Order(i)
		aFiles[nCount, 3] = RecNo(i)
	ENDIF
ENDFOR

Return .T.

********************************************************8
FUNCTION Rest_Env2
NOTE: closes all files not in array, ; 
		those in array - sets the tags and recnos
		
PARAMETER aFiles
PRIVATE nPosition, cExactSave, i

cExactSave = Set("EXACT")
SET EXACT ON
FOR i=1 TO Select(1)
	IF !Empty(Alias(i))
		IF ASCAN(aFiles, Alias(i)) > 0
			nPosition = ASUBSCRIPT(aFiles,ASCAN(aFiles, Alias(i)),1)
		 	select (i)
			IF !Empty(aFiles[nPosition, 2]) AND !EMPTY(CDX(1))
				set order to aFiles[nPosition, 2]
			ENDIF
			IF Between(aFiles[nPosition, 3], 1, Reccount())
				go aFiles[nPosition, 3]
			ENDIF
		ELSE
			use in (i)
		ENDIF
	ENDIF
ENDFOR
SET EXACT &cExactSave
Return .T.

********************************************************************
**** Returns age of a client
********************************************************************
* modified 11/2/95 by jwhite correct calculations
FUNCTION age
PARAMETERS tdDate, tdDOB
PRIVATE ALL LIKE j*
m.jcOldDate=SET("date")
SET DATE AMERICAN
m.jnAge=YEAR(m.tdDate)-YEAR(m.tddob)-;
        IIF(CTOD(LEFT(DTOC(m.tdDOB),6)+STR(YEAR(m.tdDate)))>m.tdDate,1,0)
SET DATE &jcOldDate
return m.jnAge

*-*FUNCTION age
*-*PARAMETER todaydate,bdate
*-*
*-*RETURN YEAR(todaydate) - YEAR(bdate) + ;
*-*	IIF(MONTH(todaydate) < MONTH(bdate), -1, IIF(DAY(todaydate) < DAY(bdate), -1, 0))

********************************************************************
**** Returns age of a client for a Toolbar
********************************************************************
FUNCTION Tool_Age

RETURN Age(Date(),m.dob)

********************************************************************
**** Returns Time spent in minutes
********************************************************************
FUNCTION TimeSpent
PARAMETER cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
PRIVATE nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
				0, VAL(LEFT(cEnd_tm,2))) + ;
				IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
				0, VAL(LEFT(cBeg_tm,2))) + ;
				IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes = 	(nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
			(nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes)

********************************************************************
**** Returns Time spent in decimal hours
********************************************************************
FUNCTION TimeSpentD
PARAMETER cBeg_tm, cBeg_am, cEnd_tm, cEnd_am
cBeg_am = Upper(cBeg_am)
cEnd_am = Upper(cEnd_am)
PRIVATE nEndHours, nBegHours, nMinutes

nEndHours = IIF(cEnd_am == "AM" .and. LEFT(cEnd_tm,2) = '12', ;
				0, VAL(LEFT(cEnd_tm,2))) + ;
				IIF(cEnd_am == "PM" .AND. LEFT(cEnd_tm,2) != '12', 12, 0)
nBegHours = IIF(cBeg_am == "AM" .and. LEFT(cBeg_tm,2) = '12', ;
				0, VAL(LEFT(cBeg_tm,2))) + ;
				IIF(cBeg_am == "PM" .AND. LEFT(cBeg_tm,2) != '12', 12, 0)
nMinutes = 	(nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
			(nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return Round((IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes) / 60), 4)

********************************************************************
**** Display time (numeric) in HH:MM format
********************************************************************
FUNCTION FormHours
PARAMETER nTime
Return StrTran(Str(INT(nTime/60),2)+":"+Str(nTime%60,2),' ','0')

************************************************************************
**** Formats a name in a form "Last,First M." or "Last,First Middle",
**** and allows display length to be specified
************************************************************************
FUNCTION Name
PARAMETER cLast, cFirst, cMI, nDisplen
PRIVATE cName, cMiddle

IF Type("cMI") <> "C"
	cMiddle = ""
ELSE
	cMiddle = ALLTRIM(cMI)
ENDIF

cname = ALLTRIM(cLast) + ", " + ALLTRIM(cFirst) +     ;
	IIF(!EMPTY(cMiddle)," "+IIF(LEN(cMiddle) = 1, UPPER(cMiddle) + ".", cMiddle),"")

IF RIGHT(TRIM(cName),1) = ","
	cname = LEFT(cName,AT(",",cName)-1)
ENDIF

IF Type("nDisplen") = "N"
	cname = padr(alltrim(cname), nDisplen)
ENDIF

RETURN cName

************************************************************************
****  Returns time in 12 hr. format
************************************************************************
FUNCTION Time12
PARAMETER cTime

nHH = VAL(LEFT(cTime,2))
cMeridian = IIF(nHH >= 12,'pm','am')
DO CASE
	CASE nHH  > 12
		  nHH = nHH - 12
		  cMeridian = 'pm'
	CASE nHH = 0
		  nHH = 12
		  cMeridian = 'am'
ENDCASE

cMM=SUBSTR(cTime,3,3)

RETURN STR(nHH,2,0)+cMM+cMeridian
*

***************************************************************
****  FUNCTION TO GET THE NEXT ID FROM THE NEXT_ID FILE FOR THE
****  PASSED PARAMETER
****************************************************************
FUNCTION getnextid
PARAMETER mid
PRIVATE mnext_id, nArea, aTableStru, lUsePrefix, lAlphanum, nLength

nArea = SELECT()
=openfile("next_id","next_id1")

IF SEEK(mid)

	IF !RLOCK()
		=msg2user('NOLOCK')
		mnext_id = -1
	ELSE
		* temporally ***
		=AFields(aTableStru)
		lUsePrefix = (AScan(aTableStru, "USE_PREFIX")>0) .and. ;
						next_id.use_prefix
		lAlphanum = (AScan(aTableStru, "ALPHANUM")>0) .and. ;
						next_id.alphanum

		nLength = IIF(lUsePrefix, next_id.length - 2, next_id.length)

		mnext_id = PADL(IIF(lAlphanum, Num2Char(next_id.last_id), ;
					next_id.last_id), nLength, IIF(lAlphanum,"A","0"))

		IF lUsePrefix
			mnext_id = gcSys_Prefix + mnext_id
		ENDIF

		REPLACE next_id.last_id WITH next_id.last_id + 1
		UNLOCK
	ENDIF

ELSE
	=msg2user('NOCODE',mid,'')
	mnext_id = -1
ENDIF

SELECT (nArea)
RETURN mnext_id

************************************************************************
**** Standard record locking function.  If a lock can't be obtained;
**** it asks the USER FOR retries.
************************************************************************
FUNCTION reclock
PARAMETER cAlias
PRIVATE nOldArea
nOLdArea = Select()

IF Type('cAlias') = "C" .and. !Empty(cAlias) .and. Used(cAlias)
	Select (cAlias)
ENDIF

PRIVATE lntries, lret
lntries=1
DO WHILE !RLOCK()
	IF lntries <= gnmaxltry
		lntries=lntries+1
	ELSE
		lret=msg2user('NOLOCK')
		IF lret=1
			lntries=1
		ELSE
			RETURN .F.
		ENDIF
	ENDIF
ENDDO

Select (nOldArea)

RETURN .T.
*


*****************************************************************************
**** This function displays standard messages to the user, gets response;
**** OR displays A standard MESSAGE WINDOW
*****************************************************************************
FUNCTION msg2user
PARAMETER msgscheme, cparm1, cparm2
PRIVATE cOldArea, cFont

cFont = IIF(_MAC,"Geneva", "MS Sans Serif")

IF !USED('Msg2User')
	cOldArea=ALIAS()

	SELECT 0
	USE msg2user ORDER TAG SCHEME

	IF !EMPTY(cOldArea)
		SELECT(cOldArea)
	ENDIF

ENDIF

IF TRIM(msgscheme) = 'OFF'
	RELEASE WINDOW msg2user
	RETURN 0
ENDIF

IF EMPTY(msgscheme)
	WAIT WIND 'Please Wait  (1) ...' TIMEOUT 3
	RETURN -1
ENDIF

IF !SEEK(TRIM(msgscheme),'Msg2User')
	WAIT WIND 'Please Wait (2) ...' TIMEOUT 3
	RETURN -1
ENDIF

noldmemow = SET("MEMOWIDTH")
npressed = msg2user.ndefault
nwidth = 10

SET MEMOWIDTH TO 100

STORE msg2user.message TO m.message

IF msg2user.parms

	IF Type("cParm1") <> "C"
		cParm1 = ""
	ENDIF

	IF Type("cParm2") <> "C"
		cParm2 = ""
	ENDIF

	ntimes = OCCURS('<<cParm1>>',m.message)
	FOR i = 1 TO ntimes
		m.message = STUFF(m.message,ATC('<<cParm1>>',m.message),10,cparm1)
	ENDFOR

	ntimes = OCCURS('<<cParm2>>',m.message)
	FOR i = 1 TO ntimes
		m.message = STUFF(m.message,ATC('<<cParm2>>',m.message),10,cparm2)
	ENDFOR

ENDIF

nrows = MEMLINES(m.message)

FOR i = 1 TO nrows
	IF TXTWIDTH(MLINE(m.message,i),cFont,09,'B') > nwidth
		nwidth = TXTWIDTH(MLINE(m.message,i),cFont,09,'B')+2
	ENDIF
ENDFOR

SET MEMOWIDTH TO nwidth

DEFINE WINDOW msg2user AT 0.000, 0.000  ;
	SIZE nrows+IIF(msg2user.nbuttons > 0, 4.5, 2.0), nwidth+10 ;
	TITLE TRIM(msg2user.w_title);
	FONT cFont, 09 STYLE 'B';
	FLOAT NOCLOSE NOMINIMIZE SYSTEM

ACTIVATE WINDOW msg2user NOSHOW
@ 1, 01.80 SAY TRIM(msg2user.bmp_file) BITMAP STYLE 'T'
@ 1, 08.70 SAY m.message SIZE nrows+1, nwidth

IF msg2user.nbuttons > 0
	@ 2.0+nrows,(WCOLS()-((msg2user.nbuttons*10)+(1*(msg2user.nbuttons-1))))/2 GET npressed;
		PICTURE "@*HT "+TRIM(msg2user.buttons) SIZE 1.7, 10.000,1.0
ENDIF


MOVE WINDOW msg2user CENTER
SHOW WINDOW msg2user TOP

IF msg2user.nbuttons > 0
*	READ CYCLE MODAL
	Read Cycle Modal Timeout 120 Object npressed
ENDIF

IF !msg2user.stay
	RELEASE WINDOW msg2user
ENDIF

SET MEMOWIDTH TO noldmemow

RETURN npressed
*

************************************************************
FUNCTION OK2Close
PARAMETER  glSaveAvail

PRIVATE nChoice
nChoice = 1

IF glSaveAvail
	nChoice = Msg2user('NOTSAVED')
ELSE
	nChoice = 2
ENDIF

RETURN nChoice

****************************************************************************
FUNCTION sele_staff

select ;
	a.worker_id, a.site, a.prog_id, b.last, b.first, b.mi, b.date_fnsh, ;
	c.descript, c.caseload, upper(left(b.first,1)+left(b.last,1)) as initals, ;
	b.license, b.pr_type, b.c_t_id, a.superid, c.can_superv as superflag, ;
	b.tax_id, b.team,	b.system_sup, ;
	SPACE(2) AS ctsitetype ,;
	SPACE(3) AS ctsitenum ,;
	b.staff_id ;
from ;
	userprof a, staff b, jobtype c ;
where ;
	a.tc = gctc and ;
	a.staff_id = b.staff_id and ;
	a.jobtype = c.jobtype and ;
	!b.system_sup and ;
	c.caseload ;
into ;
	cursor tempstaff

*       empty(b.date_fnsh) and ;

index on worker_id tag worker_id

IF Used("staffcur")
	use in staffcur
ENDIF

select 0
use (dbf('tempstaff')) again alias staffcur
index on c_t_id tag c_t_id additive
index on site tag site additive
index on IIF(EMPTY(date_fnsh), "", "{") + upper(last+first) tag name additive
index on caseload tag caseload additive
index on staff_id tag staff_id additive
select staffcur
DO OpenFile WITH "site", "site_id"
SELE staffcur

IF TYPE("site.ctsitetype")#"U"
  SET RELA TO site INTO site
  REPL ALL ctsitetype WITH site.ctsitetype, ;
           ctsitenum  WITH site.ctsitenum
  SET RELA TO
ENDIF
use in tempstaff
USE IN site
USE IN userprof
USE IN staff
USE IN jobtype

****************************************************************************
FUNCTION all_staff

PRIVATE lSiteOpen, lUsPrOpen, lStafOpen, lJobTOpen

lSiteOpen = OpenFile("site", "site_id")
lUsPrOpen = OpenFile("userprof")
lStafOpen = OpenFile("staff")
lJobTOpen = OpenFile("jobtype")

select ;
	a.worker_id, a.site, a.prog_id, b.last, b.first, b.mi, b.date_fnsh,			;
	c.descript, c.caseload, upper(left(b.first,1)+left(b.last,1)) as initals,	;
	b.license, b.pr_type, b.c_t_id, a.superid, c.can_superv as superflag, 		;
	b.tax_id, b.team,	b.system_sup, 														;
	SPACE(2) AS ctsitetype ,													;
	SPACE(3) AS ctsitenum														,;
	b.staff_id ;
from										;
	userprof a, staff b, jobtype c			;
where										;
	a.tc = gctc and							;
	!b.system_sup and ;
	a.staff_id = b.staff_id and				;
	a.jobtype = c.jobtype					;
into										;
	cursor tempstaff

*       empty(b.date_fnsh) and ;

INDEX ON worker_id TAG worker_id

IF Used("staffcur")
	USE IN STAFFCUR    
ENDIF

select 0
use (dbf('tempstaff')) again alias staffcur
index on c_t_id tag c_t_id additive
index on site tag site additive
index on IIF(EMPTY(date_fnsh), "", "{") + upper(last+first) tag name additive
index on caseload tag caseload additive
index on staff_id tag staff_id additive

SELE staffcur
IF TYPE("site.ctsitetype")#"U"
  SET RELA TO site INTO site
  REPL ALL ctsitetype WITH site.ctsitetype, ;
         ctsitenum  WITH site.ctsitenum
  SET RELA TO
ENDIF

USE IN tempstaff

IF !lSiteOpen
	USE IN site
ENDIF
IF !lUsPrOpen
	USE IN userprof
ENDIF
IF !lStafOpen
	USE IN staff
ENDIF
IF !lJobTOpen
	USE IN jobtype
ENDIF

******************************************
* Displays worker in scrnval
******************************************
FUNCTION WorkerDisp
RETURN PADR(IIF(EMPTY(date_fnsh), "", "{") + UPPER(NAME(LAST,FIRST)) + IIF(EMPTY(date_fnsh), "", "}"),28)

******************************************
NOTE: CURRHIST will create a cursor containing a set of records that ;
	are called from a file that contains a history for Effective Date periods. ;
	ie., MEDICAID rates, Foster Parent Board rates etc. ;
	Parms: ;
	cTable2Use - Table information will be SELECTed from ;
	cTag - Index tag ;
	cLocator - Enter a date (in char format if you want to select records NOT from;
				the current period ;
	cTable2Make -  The name of the cursor file to be created ;
	cOrder -  The order of the resulting cursor;
;
	EXAMPLE:  CurrHist('BEHAVIOR','EFFECT_DT','01/01/95','BEHAV_C','CODE')

FUNCTION CURRHIST
PARAMETER cTable2Use, cTag, cLocator, cTable2Make, cOrder
cAlias = ALIAS()

dLocator = {}

IF !EMPTY(cLocator)
	dLocator = CTOD(clocator)
ENDIF

=OpenFile(cTable2Use,IIF(EMPTY(cTag),'',cTag),'TEMPHIST')
GO TOP

IF EMPTY(dLocator)
	d_effect_dt = EFFECT_DT
ELSE
	LOCATE FOR EFFECT_DT <= dLocator
	d_effect_dt = EFFECT_DT
ENDIF

SELECT * FROM TEMPHIST INTO CURSOR &cTable2Make;
		WHERE EFFECT_DT = d_effect_dt ;
		ORDER BY &cOrder

SELECT TEMPHIST
USE

IF !EMPTY(cAlias)
	SELECT (cAlias)
ENDIF

RETURN
*

*****************************************************************
* CIN_CHK : check digit routine for 8 DIGIT CIN
* DATE    : 9/18/88
* AUTHOR  : F.G.L.
**
FUNCTION CIN_CHK
parameters mcin
private mok, nOldArea

IF Len(Trim(mcin)) = 11
	Return .t.
ENDIF

nOldArea = Select()

mcin = upper(mcin)
mweight1 = 128
mweight2 = 64
mweight3 = 32
mweight4 = 16
mweight5 = 8
mweight6 = 4
mweight7 = 2

msum = 0

mpos1 = substr(mcin,1,1)
mpos2 = substr(mcin,2,1)
mpos3 = substr(mcin,3,1)
mpos4 = substr(mcin,4,1)
mpos5 = substr(mcin,5,1)
mpos6 = substr(mcin,6,1)
mpos7 = substr(mcin,7,1)
mpos8 = substr(mcin,8,1)

=openfile('cin_tbl')

locate for character = mpos1
mval1 = value

locate for character = mpos2
mval2 = value

mval3 = val(mpos3)
mval4 = val(mpos4)
mval5 = val(mpos5)
mval6 = val(mpos6)
mval7 = val(mpos7)

msum = (mval1 * mweight1) + (mval2 * mweight2) + (mval3 * mweight3) + ;
       (mval4 * mweight4) + (mval5 * mweight5) + (mval6 * mweight6) + ;
       (mval7 * mweight7)

mval8 = 23 - mod(msum, 23)

locate for value = mval8

mchk_digit = character

if mpos8 = mchk_digit
     select (nOldArea)
     return .t.
endif

if .not. 'L' $ left(mcin,7)
     select (nOldArea)
     return .f.
endif
**
** 8 character cin is always 2 characters followed by 5 digits followed
** by 1 character
** there are two possible values for the letter 'L'
** recalculate check digit with second value
**
if mpos1 = 'L'
    locate for character = mpos1
    skip
    mval1 = value
endif
if mpos2 = 'L'
    locate for character = mpos2
    skip
    mval2 = value
endif

msum = (mval1 * mweight1) + (mval2 * mweight2) + (mval3 * mweight3) + ;
       (mval4 * mweight4) + (mval5 * mweight5) + (mval6 * mweight6) + ;
       (mval7 * mweight7)

mval8 = 23 - mod(msum, 23)

locate for value = mval8

mchk_digit = character

if mpos8 = mchk_digit
     mok = .t.
else
     mok = .f.
endif

select (nOldArea)
return mok

*****************************************************************
* Check if Cin number is not duplicate
**
FUNCTION CIN_DUPL
parameters cCinn, cClient_ID
private lOk, aTemp

select ;
	cinn, client_id ;
from ;
	client ;
where ;
	cinn = cCinn and client_id <> cClient_ID ;
into ;
	array aTemp

lOk = (_TALLY = 0)

Return lOk


*****************************************************************
* Check if id number is not duplicate
**
* jss, 2/10/04, use "==" instead of "=" to ensure true duplicates
FUNCTION ID_NO_DUPL
parameters cID_NO, cClient_ID
private lOk, aTemp

select ;
	id_no, client_id ;
from ;
	&gcTc_Clien ;
where ;
	id_no == cID_NO and client_id <> cClient_ID ;
into ;
	array aTemp

lOk = (_TALLY = 0)

Return lOk

****************************************************************************
FUNCTION mylookup
PARAMETER clookupfile, creturnfld,clookupval,clookupfld,clookuptag
PRIVATE nsavearea, creturnval

nsavearea = SELECT()
SELECT (clookupfile)
creturnval = LOOKUP(&creturnfld,clookupval,&clookupfld,clookuptag)
SELECT (nsavearea)

RETURN creturnval

****************************************************************************
****  Document/Report Printing utility
****************************************************************************
PROCEDURE printdoc
PARAMETERS cdcatagory
PRIVATE cOldArea

cOldArea = ALIAS()

=openfile('DOCTITLE','DOC_CATGRY')
WTITLE =LOOKUP(cwintitle, cdcatagory, doc_catgry, 'DOC_CATGRY')
clisttitle =LOOKUP(clistitle, cdcatagory, doc_catgry, 'DOC_CATGRY')

=openfile('DOCUMENT','DOC_CATGRY')
SET FILTER TO doc_catgry = cdcatagory
GO TOP

IF !EMPTY(cOldArea)
	SELECT (cOldArea)
ENDIF

lprinted = .F.
DO printdoc.prg WITH WTITLE, clisttitle, lprinted

SELECT DOCUMENT
SET FILTER TO

IF !EMPTY(cOldArea)
	SELECT (cOldArea)
ENDIF

RETURN
*


****************************************************************************
**** Full screen validation program - Pass to it the screen name to validate
****************************************************************************
FUNCTION v_screen
PARAMETERS cScreen2Use
PRIVATE cOldArea

cOldArea = ALIAS()
lpassed = .T.

=openfile("V_FIELDS","SCR_NAME")

STORE 1 TO nErrorNum
DIMENSION aerrors[nErrorNum,2]
STORE .F. TO aerrors

SELECT v_fields
IF SEEK(TRIM(cScreen2Use))
	SCAN WHILE TRIM(scr_name)=TRIM(cScreen2Use) .AND.  !EOF()
		IF !EVAL(TRIM(validrules))
			lpassed = .F.
			DIMENSION aerrors[nErrorNum,2]
			aerrors[nErrorNum,1] = MESSAGE
			aerrors[nErrorNum,2] = TRIM(field_name)
			nErrorNum = nErrorNum+1
		ENDIF
	ENDSCAN
ENDIF

IF !lpassed
	cerrorfld = ''
	DO validscr.prg WITH cerrorfld
	_CUROBJ=OBJNUM(&cerrorfld)
ENDIF

IF !Empty(cOldArea)
	SELECT (cOldArea)
ENDIF

RELEASE aerrors

RETURN lpassed

*********************************************************************
* Checks for changes that were made to fields you pass to it
* you need to have the glSave Avail memvar in your program
* glSaveAvail will trigger the close and cancel messages

FUNCTION chk4change
PARAMETERS in, out, csavename

IF TYPE('glSaveAvail') = 'U'
	RETURN .t.
ENDIF

IF !glsaveavail
	IF lnew
		IF !EMPTY(EVAL(out))
			SHOW GET &csavename ENABLE
			glsaveavail = .T.
			RETURN .T.
		ELSE
			RETURN .T.
		ENDIF
	ENDIF

	IF !(EVAL(IN) == EVAL(out))
		SHOW GET &csavename ENABLE
		glsaveavail = .T.
		RETURN .T.
	ENDIF
ENDIF

RETURN .T.
*

***********************************************************************
* Check that the user has entered a proper time
* Pass on the time to check and the Object number

FUNCTION TimeChk
PARAMETERS cTime, nObjNum
PRIVATE lRv

lRv = .T.
IF EMPTY(cTime)
	RETURN .T.
ENDIF

IF !BETWEEN(LEFT(cTime,2),'01','12')
	lRv = .F.
ENDIF

IF !BETWEEN(RIGHT(cTime,2),'00','59')
	lRv = .F.
ENDIF

IF !lRv
	=Msg2User('WRONGTIME')
* jss, 11/18/03, add next if statement, uncomment "_curobj = nobjnum"
	IF TYPE('nObjNum') = 'N'
		_CUROBJ = nObjNum
	ENDIF	
ENDIF

RETURN lRv
*

***************************************************************
**** This function display nMove buttons appropriately
****
**** cCursor (C) - name of a file
**** nTopRec (N) - number of the first record
**** nBottRec (N) - number of the last record
****
***************************************************************
FUNCTION ShowMove
PARAMETER cCursor, nTopRec, nBottRec

DO CASE
	CASE (Bof(cCursor) .and. Eof(cCursor)) .or. (nTopRec = nBottRec)
		show get nMove   disable
		show get nList   disable
	CASE Bof(cCursor) or RecNo(cCursor) = nTopRec
		show get nMove,1 disable
		show get nMove,2 disable
		show get nMove,3 enable
		show get nMove,4 enable
		show get nList   enable
	CASE Eof(cCursor) or RecNo(cCursor) = nBottRec
		show get nMove,1 enable
		show get nMove,2 enable
		show get nMove,3 disable
		show get nMove,4 disable
		show get nList   enable
	OTHERWISE
		show get nMove   enable
		show get nList   enable
ENDCASE


********************************************************************
**** FUNCTION DispTitle
**** Displays a title of a window with mode, name and page number
**** Usage:
****    cWinName - window name to change title
****    cBaseTitle - base title
****    nMode - mode:
****                            0 - VIEW
****                            1 - ADD
****                            2 - EDIT
****                            3 - DELETE
****                            .F./nil - none
****    cName - name to be displayed - if not passed - ignored
****    nPage - page number (numeric) - if not passed - no page # dispalyed
********************************************************************
FUNCTION disptitle
PARAMETER cWinName, cBaseTitle, nMode, cName, nPage, cSuffix
PRIVATE lcPageNum, lcMode, lcName, lcSuffix

IF TYPE("cWinName") <> "C"
	RETURN
ENDIF

IF TYPE("cBaseTitle") <> "C"
	cBaseTitle = WTITLE(cWinName)
ENDIF

IF TYPE("cName") <> "C" .OR. EMPTY(cName)
	lcName = ""
ELSE
	lcName = " for " + ALLTRIM(cName)
ENDIF

IF TYPE("nPage") <> "N" OR nPage = 0
	lcPageNum = ""
ELSE
	lcPageNum = " - Page "+LTRIM(STR(nPage,2,0))
ENDIF

IF TYPE("cSuffix") <> "C" .OR. EMPTY(cSuffix)
	lcSuffix = ""
ELSE
	lcSuffix = " - " + ALLTRIM(cSuffix)
ENDIF

DO CASE
CASE TYPE("nMode") <> "N"
	lcMode = ""
CASE nMode = 0
	lcMode = "VIEW "
CASE nMode = 1
	lcMode = "ADD "
CASE nMode = 2
	lcMode = "EDIT "
CASE nMode = 3
	lcMode = "DELETE "
OTHERWISE
	lcMode = ""
ENDCASE

MODIFY WINDOW &cWinName TITLE lcMode + cBaseTitle + lcName + lcPageNum + lcSuffix

*****************************************************************************
**** FUNCTION rel_list
**** Creates a list of all people anyhow connected to a person
**** Picks up everybody in the person's household(s) and in all households
**** connected to people in prim. person househld(s) e.t.c.
**** Creates a few cursors:
****    own_hh    - list of all households (hshld_id) prim.person is connected
****    own_rel   - list of all people (client_id) connected to above households
****    case_rel  - list of all people (client_id) with the same CASE NUMBER
****    other_rel - list of people (client_id) connected to households above
****                mentioned people are connected besides "own" households
****    all_rel   - combined list of both categories, with "related" - L(1) -
****                to specify if directly related (or the same CASE_NO)
**** Returns .T. if there is anybody connected to a prim. person
*****************************************************************************

FUNCTION rel_list
PARAMETER cclient_id, cCase_No

IF TYPE('cClient_ID') <> 'C' .or. LEN(cclient_id) <> 10
	RETURN .F.
ENDIF

IF TYPE('cCase_No') <> 'C' .or. Empty(cCase_No)
	cCaseNo = ""
ENDIF

* initial cursor ********************************
* pick up all households for client
SELECT ;
	hshld_id ;
FROM ;
	cli_hous ;
WHERE ;
	cli_hous.client_id = cclient_id ;
INTO ;
	CURSOR temp1 ;
ORDER BY ;
	hshld_id

SELECT * FROM temp1 INTO CURSOR own_hh ORDER BY hshld_id
*index on hshld_id tag hshld_id

*************************************************
DO WHILE .T.

	* pick up all people connected to households in cursor 1
	SELECT DISTINCT ;
		a.client_id, a.hshld_id ;
	FROM ;
		cli_hous A, temp1 B ;
	WHERE ;
		a.hshld_id = b.hshld_id AND ;
		a.client_id <> cclient_id ;
	INTO ;
		CURSOR temp2

	* pick up all households for people in cursor 2
	SELECT DISTINCT;
		a.client_id, a.hshld_id ;
	FROM ;
		cli_hous A, temp2 B ;
	WHERE ;
		a.client_id = b.client_id ;
	INTO ;
		CURSOR temp1

	IF RECCOUNT('temp1') = RECCOUNT('temp2')
		EXIT
	ENDIF

ENDDO

USE IN temp2

* pick up all people with the same case number
IF !Empty(cCase_No)
	SELECT ;
		a.client_id, .T. AS related ;
	FROM ;
		client A;
	WHERE ;
		a.case_no = cCase_No and ;
		a.client_id <> cClient_ID ;
	INTO ;
		CURSOR case_rel
ENDIF

* people connected directly to a client
SELECT DISTINCT ;
	client_id, .T. AS related ;
FROM ;
	temp1 A, own_hh B ;
WHERE ;
	a.hshld_id = b.hshld_id ;
INTO ;
	CURSOR own_rel
index on client_id tag client_id

* people connected indirectly to a client
SELECT DISTINCT ;
	client_id, .F. AS related ;
FROM ;
	temp1 A ;
WHERE ;
	a.hshld_id  NOT IN (SELE hshld_id FROM own_hh) AND ;
	a.client_id NOT IN (SELE client_id FROM own_rel) ;
INTO ;
	CURSOR other_rel

IF Empty(cCase_No)
	SELECT * ;
		FROM own_rel ;
	UNION ;
		SELECT * ;
			FROM other_rel ;
	INTO CURSOR all_rel
ELSE
	SELECT * ;
		FROM own_rel ;
	UNION ;
		SELECT * ;
			FROM other_rel ;
	UNION ;
		SELECT * ;
			FROM case_rel ;
	INTO CURSOR all_rel
ENDIF

USE IN temp1

RETURN RECCOUNT('all_rel')>1

*************************************************************************
**** Function House_ID
**** Returns a hshld_id for a person where lives_in = .t.
*************************************************************************
FUNCTION house_id
PARAMETER cCl_ID
PRIVATE cHshld_ID, nSaveArea

nSaveArea = Select()

*SELECT hshld_id ;
*       FROM cli_hous ;
*       WHERE client_id = ccl_id AND lives_in ;
*       INTO ARRAY atemp

*IF _TALLY > 0
*       chshld_id = atemp[1]
*ELSE
*       chshld_id = SPACE(10)
*ENDIF
*RELEASE atemp

=OpenFile('cli_hous')
locate for client_id = cCl_ID AND lives_in
IF Found()
	chshld_id = hshld_id
ELSE
	chshld_id = SPACE(10)
ENDIF

Select (nSaveArea)
RETURN cHshld_ID

*************************************************************************
**** Function Address
**** Returns a character string formatted as address based on a current
**** record position in the table where address is stored and common names
**** for address fields
**** C/O John Smith, 1234 First Street Apt. 1A, Smithtown, NY 12345
*************************************************************************
FUNCTION address
PARAMETER cAlias
PRIVATE cAddress, cCRLF, nSaveArea, lAreaChanged
cCRLF = CHR(13)+CHR(10)
nSaveArea = Select()

IF Type("cAlias") = "C" .and. !Empty(cAlias) .and. Alias() <> Upper(cAlias)
	select (cAlias)
	lAreaChanged = .t.
ELSE
	lAreaChanged = .f.
ENDIF

cAddress = ;
	IIF(Type("co_name") = "C" .and. !EMPTY(co_name), ;
			"C/O "+TRIM(co_name) + cCRLF,"") + ;
	IIF(!EMPTY(street1), TRIM(street1) + cCRLF, "") + ;
	IIF(!EMPTY(street2), TRIM(street2) + cCRLF, "") + ;
	TRIM(city) + IIF(!Empty(st) And !Empty(city) ,", ","") + st + "  " + ;
	IIF(LEN(TRIM(zip))<=5, zip, TRANSFORM(zip, "@R 99999-9999"))

IF LEFT(cAddress ,1) == ','
   cAddress = ''
ENDIF   

IF lAreaChanged
	Select (nSaveArea)
ENDIF

RETURN IIF(Trim(cAddress)=cCRLF+",","",cAddress)
	
*************************************************************************
**** Function Address2
**** Returns a 1 line caracter string formatted as address based on 
**** specified ADDRESS1,ADDRESS2,CITY,STATE, AND ZIP FIELDS
*************************************************************************
FUNCTION address2
PARAMETER TCADDR1,TCADDR2,TCCITY,TCSTATE,TCZIP
PRIVATE cAddress

cAddress = IIF(!EMPTY(TCADDR1),IIF(TCADDR1 <> "NONE",;
	TRIM(TCADDR1) + ", " + ;
	IIF(!EMPTY(TCADDR2), TRIM(TCADDR2) + ", ", "") + ;
	TRIM(TCCITY) + IIF(!Empty(TCSTATE),", "+TCSTATE+" ","") + ;
	IIF(LEN(TRIM(TCZIP))<=5, TCZIP, ;
	TRANSFORM(TCZIP, "@R 99999-9999")),""),"")

RETURN IIF(Trim(cAddress)=",","",cAddress)


*************************************************************************
**** Function Address3
**** Returns a multi-line caracter string formatted as address based on 
**** specified ADDRESS1,ADDRESS2,CITY,STATE, AND ZIP FIELDS
*************************************************************************
FUNCTION address3
PARAMETER TCADDR1,TCADDR2,TCCITY,TCSTATE,TCZIP
PRIVATE cAddress, cCRLF 
cCRLF = CHR(13)+CHR(10)

cAddress = IIF(!EMPTY(TCADDR1),IIF(TCADDR1 <> "NONE",;
	TRIM(TCADDR1) + cCRLF + ;
	IIF(!EMPTY(TCADDR2), TRIM(TCADDR2) + cCRLF, "") + ;
	TRIM(TCCITY) + IIF(!Empty(TCSTATE),", "+TCSTATE+" ","") + ;
	IIF(LEN(TRIM(TCZIP))<=5, TCZIP, ;
	TRANSFORM(TCZIP, "@R 99999-9999")),""),"")

RETURN IIF(Trim(cAddress)=cCRLF+",","",cAddress)


************************************************************************
************************************************************************
**** Functions to work with FOSTER CARE family data
************************************************************************
************************************************************************

*************************************************************************
**** FUNCTION New_Family
**** Prepare an empty cursor for family
*************************************************************************
FUNCTION new_family

CREATE CURSOR fam_cur ;
	(tc_id     C(10), ;
	client_id  C(10), ;
	TYPE       N( 1), ;
	wherelives N( 1), ;
	RELATION   C( 2), ;
	hivpos	   l( 1), ;
	knclistat  l( 1), ;
	liveswith  l( 1), ;
	oktocont   l( 1), ;
	awarofaff  l( 1), ;
	last_name  C(20), ;
	first_name C(15), ;
	mi         C(15), ;
	dob        D( 8), ;
	sex        C( 1), ;
	phwork     C(10), ;
	phhome     C(10), ;
	ethnic     C( 2), ;
	ssn        C( 9))

CREATE CURSOR hh_cur ;
	(client_id C(10),;
	 hshld_id  C(10))
INDEX ON client_id TAG client_id
*************************************************************************
**** FUNCTION Fam_Data
**** Prepares a cursor of family members 
*************************************************************************
* jss, 1/25/02, include new fields client.hispanic,white,blafrican,asian,hawaisland,indialaska,unknowrep
FUNCTION fam_data
PARAMETER ctc_id

*=OpenFile("ai_famil", "", "fam_file")

SELECT ;
	tc_id, client_id, type, wherelives, relation, hivpos, knclistat, ;
	oktocont, awarofaff, remarks  ;
FROM ;
	ai_famil;
WHERE ;
	tc_id = ctc_id AND !ai_famil.self ;
INTO ;
	CURSOR temp1

SELECT ;
	temp1.*, ;
	client.last_name, client.first_name, client.mi, ;
	client.dob,client.age, client.sex, client.phwork, client.phhome, ;
	client.hispanic, client.white, client.blafrican, client.asian, client.hawaisland, client.indialaska, client.unknowrep ;
FROM ;
	temp1, client ;
WHERE ;
	client.client_id = temp1.client_id ;
INTO ;
	CURSOR temp2

INDEX ON STR(wherelives,1,0)+UPPER(last_name+first_name) TAG name

gnFamFirst = RecNo()

go bottom
gnFamLast=RecNo()

go top

IF Used('fam_cur')
	use in fam_cur
ENDIF

select 0
use (dbf('temp2')) alias fam_cur again exclusive
index on client_id tag client_id additive

set order to tag name

use in temp2

SELECT ;
	cli_hous.client_id, cli_hous.hshld_id ;
FROM ;
	cli_hous, fam_cur ;
WHERE ;
	cli_hous.client_id = fam_cur.client_id AND ;
	cli_hous.lives_in;
INTO ;
	CURSOR hh_cur

INDEX ON client_id TAG client_id

use in temp1
*use in fam_file

RETURN


**** Function DispType
**** Displays a type of a family member
*************************************************************************
FUNCTION disptype
PARAMETER ntype
DIMENSION atypes[4]
atypes[1] = "Personal Contact "
atypes[2] = "Emergency Contact"
atypes[3] = "Other            "
atypes[4] = "                 "
  
IF ntype = 0
	ntype = 4
ENDIF

RETURN atypes[nType]


************************************************************************
************************************************************************
**** Functions to work with table look-up
************************************************************************
************************************************************************

*********************************************************
**** Calls table.spr by current position in scrnval
****
FUNCTION scrtable
PRIVATE aTagArray
aTagArray = .F. && to fool table.spr if nothing is stored in scrnval

IF !EMPTY(scrnval.tag1)
	DIMENSION aTagArray[1,2]
	aTagArray[1,1] = scrnval.tagname1
	aTagArray[1,2] = scrnval.tag1
ENDIF
IF !EMPTY(scrnval.tag2)
	DIMENSION aTagArray[2,2]
	aTagArray[2,1] = scrnval.tagname2
	aTagArray[2,2] = scrnval.tag2
ENDIF

DO table.prg WITH TRIM(scrnval.filename), TRIM(scrnval.varname), ;
	TRIM(scrnval.wintitle), ;
	lChosen, ;
	TRIM(scrnval.codename), ;
	TRIM(scrnval.display), ;
	TRIM(scrnval.filter), ;
	aTagArray, ;
	scrnval.sql

RETURN lChosen

*********************************************************
PROCEDURE pop_up
PARAMETERS cWindow, tcVarName, lOFF
PRIVATE lChosen
lChosen = .F.

IF SEEK(PADR(cWindow,10)+tcVarName,'SCRNVAL')

	lChosen = scrtable()
	IF lChosen
		gcPicked = tcVarName
		glUpdated = .t.
		IF lOFF
			SHOW GETS OFF
		ELSE
			SHOW GETS WINDOW (WONTOP())
		ENDIF
	ENDIF
ENDIF
Return lChosen

*********************************************************
PROCEDURE check_val
PARAMETER tcVarName
PRIVATE lChosen, cVarDesc, mVarVal, cVariable

lChosen = .F.
IF Type('tcVarName') <> "C"
	tcVarName = VARREAD()
ENDIF

IF SEEK(PADR(WOUTPUT(),10)+tcVarName,'SCRNVAL')
	cVarDesc  = TRIM(scrnval.vardesc)
	cVariable = 'm.'+tcVarName
	mVarVal   = EVAL(cVariable)
	glUpdated = .t.

	* attempt to find something
	&cVarDesc = RTRIM(getdesc(TRIM(scrnval.filename), ;
		TRIM(cVariable), ;
		TRIM(scrnval.codename), ;
		TRIM(scrnval.descript), ;
		TRIM(scrnval.filter)))

	IF (!EMPTY(mVarVal) .AND. EMPTY(&cVarDesc)) .OR. ;
			(EMPTY(mVarVal) .AND. scrnval.required)
		IF !scrtable()
			&cVariable = Space(Len(&tcVarName))
		ENDIF
	ENDIF

	gcPicked = tcVarName

	IF wread(wontop())
		SHOW GETS OFF WINDOW (WONTOP())
	ENDIF
ENDIF

*********************************************************
FUNCTION getdesc
PARAMETER cfilename, tcVarName, cfieldname, cDescName, cfilter
PRIVATE nsavearea, cDesc, cSearchStr
nsavearea = SELECT()

IF TYPE("cFieldName") <> "C"
	cfieldname = "code"
ENDIF

IF TYPE("cDescName") <> "C"
	cDescName= "descript"
ENDIF

IF TYPE("cFilter") <> "C"
	cFilter= ""
ENDIF

=openfile(cfilename)
m.cSearchStr = '&cfieldname = "'+EVAL(m.tcVarName)+'"'
IF !Empty(cFilter)
	cSearchStr = "("+cSearchStr + ") .and. ("+cFilter + ")"
ENDIF

* the table is supposed to have matching indexes on all fields involved
LOCATE FOR &cSearchStr
IF FOUND()
	cDesc = EVAL(cDescName)
ELSE
	cDesc = SPACE(LEN(EVAL(cDescName)))
ENDIF

SELECT (nsavearea)
RETURN cDesc

*********************************************************
PROCEDURE readdescr
PARAMETER cWindow

IF EMPTY(gcPicked)
	=SEEK(cWindow,'SCRNVAL')
	DO WHILE !EOF('SCRNVAL') .AND. scrnval.window = cWindow
		cDescVar = scrnval.vardesc
		&cDescVar = RTRIM(getdesc(TRIM(scrnval.filename), ;
			TRIM('m.'+scrnval.varname), ;
			TRIM(scrnval.codename), ;
			TRIM(scrnval.descript),;
			TRIM(scrnval.filter)))
		SKIP IN scrnval
	ENDDO
ELSE
	IF SEEK(PADR(cWindow,10)+gcPicked,'SCRNVAL')
		cDescVar = scrnval.vardesc
		&cDescVar = RTRIM(getdesc(TRIM(scrnval.filename), ;
			TRIM('m.'+scrnval.varname), ;
			TRIM(scrnval.codename), ;
			TRIM(scrnval.descript),;
			TRIM(scrnval.filter)))
	ENDIF
	gcPicked = ""
ENDIF



*************************************************************
**** Calculates a sequential number for a code in the currently
**** selected table with whatever order the table is.
**** Used for table look-ups
*************************************************************
FUNCTION find_code
PARAMETER cVar, cCode
PRIVATE nList

GO TOP
nList = 1
SCAN WHILE !EOF() .AND. &cCode <> cVar
	nList = nList + 1
ENDSCAN

IF EOF()
	nList = 1
ENDIF
RETURN nList
*


************************************************************************
************************************************************************
**** Functions to work with security
************************************************************************
************************************************************************

****************************************************************************
* FUNCTION getassign - returns an array of assignments for a staff person
*   PARAMETER stafarr - the array of the staff ids.
*             array to return results
****************************************************************************
FUNCTION getassign
PARAMETER mstaffid,mgenarr
PRIVATE ALL LIKE l*
lcalias=ALIAS()
*
* Pick-up profiles for the person selected.
*
SELECT  distinct a.tc,a.agency,a.prog_id,a.site,a.jobtype,a.worker_id ;
    FROM userprof A;
	WHERE staff_id=mstaffid AND tc=m.gctc;
	INTO CURSOR temp1

*
* Compile array of assignments
*
SELECT a.*,b.descript AS progname ;
	FROM  temp1 A,PROGRAM B ;
	WHERE a.prog_id=b.prog_id ;
	INTO CURSOR temp2

SELECT a.worker_id,b.group_id;
	FROM temp1 A, stgroup B;
	WHERE a.worker_id = b.worker_id;
	INTO CURSOR temp18

SELECT a.*,b.groupname;
	FROM temp18 A, groups B;
	WHERE a.group_id = b.group_id;
	INTO CURSOR temp17

SELECT a.*,b.groupname AS progname;
	FROM temp1 A, temp17 B;
	WHERE a.worker_id=b.worker_id;
	INTO CURSOR temp4


SELECT a.*, PADR('None',30) AS progname FROM temp1 A;
	WHERE EMPTY(prog_id) AND ;
	worker_id NOT IN;
	(SELECT worker_id FROM temp17);
	INTO CURSOR temp3



SELECT * FROM temp2;
	UNION;
	SELECT * FROM temp3;
	UNION;
	SELECT * FROM temp4;
	INTO  CURSOR temp1

SELECT a.*,b.descript1 AS sitename FROM  temp1 A,site B ;
	WHERE a.site=b.site_id;
	INTO CURSOR temp2

SELECT a.*,PADR('None',30) AS sitename FROM temp1 A;
	WHERE EMPTY(site);
	INTO CURSOR temp3



SELECT * FROM temp2;
	UNION;
	SELECT * FROM temp3;
	INTO  CURSOR temp1

* Multiple types of care case

*   SELECT a.*,b.desc AS tcName FROM  temp1 A,tc B ;
*     WHERE a.tc=b.tc ;
*     INTO CURSOR temp2

*SELECT a.*, PADR('None',50) AS tcName FROM temp1 A;
* WHERE EMPTY(tc);
*INTO CURSOR temp3

*   SELECT * FROM temp2;
*    UNION;
*  SELECT * FROM temp3;
*INTO  CURSOR temp1

*


SELECT a.*,b.descript AS jname FROM  temp1 A,jobtype B ;
	WHERE a.jobtype=b.jobtype ;
	INTO CURSOR temp1

SELECT a.*,b.descript1 AS agname FROM  temp1 A,agency B ;
	WHERE a.agency=b.agency ;
	INTO CURSOR temp2

SELECT a.*, PADR('None',30) AS agname FROM temp1 A;
	WHERE EMPTY(agency);
	INTO CURSOR temp3

SELECT * FROM temp2;
	UNION;
	SELECT * FROM temp3;
	INTO  CURSOR temp1

SELECT  PADR(agname,15)+SPACE(1);
	+PADR(progname,25) +SPACE(1)+PADR(sitename,25)+PADR(jname,20),  ;
	tc,agency,prog_id,site,jobtype,worker_id ;
	FROM temp1 INTO ARRAY mgenarr

*
*
*

IF !EMPTY(lcalias)
	SELECT (lcalias)
ELSE
	SELECT 0
ENDIF
RETURN _TALLY


****************************************************************************
*
* FUNCTION det_access - returns a where clause incorporating the login
*                       information for the user logged in.
*
****************************************************************************

FUNCTION det_access
PRIVATE ALL LIKE l*
lcwhere=''
IF !EMPTY(gctc)
	lcwhere=lcwhere+ ' tc=gctc '
ENDIF

IF !EMPTY(gcsite)
	lcwhere=lcwhere+ IIF(EMPTY(lcwhere),'',' and ') + ' site=gcsite '
ENDIF

IF !EMPTY(gcprogram)
	lcwhere=lcwhere+ IIF(EMPTY(lcwhere),'',' and ') +  ' prog_id=gcprogram '
ENDIF

IF !EMPTY(gcagency)
	lcwhere=lcwhere+ IIF(EMPTY(lcwhere),'',' and ') +  ' agency=gcagency '
ENDIF

RETURN IIF (EMPTY(lcwhere),"", ' WHERE '+ lcwhere)

****************************************************************************
*   FUNCTION allowed - returns .T. if a client is in the security scope of
*                      the current user
*          PARAMETERs mclient - the tc id of the  client
*                         mrequery - logical, wrether to refresh the gaidlist array
*
****************************************************************************
FUNCTION allowed
PARAMETER mclient,mrequery
IF !mrequery
	RETURN ASCAN(idlist,mclient)>0
ELSE
	=fullist(idlist,gcworker,.F.,1)
	RETURN ASCAN(idlist,mclient)>0
ENDIF

****************************************************************************
*   FUNCTION cligroup - returns a cursor relating a client to a group
*            PARAMETERS groupfile : the file name of the group file ( e.g.
*                                                                       facility)
*                        grouparr : the array of the group ids (e.g.
*                                                                       {'00001','00002'} represent facilities
*                                                                       with the corresponding facility ids.
****************************************************************************
FUNCTION cligroup
PARAMETER groupfile,grouparr
PRIVATE ALL LIKE l*
lcalias=ALIAS()
*
* Uses Connect3 file describing the linkage between two databases through
* the linking table (connect3)
*

SELECT * FROM connect3 WHERE file2=groupfile INTO CURSOR temp1
SCATTER MEMVAR
lcwhere= ' ASCAN( GROUPARR, '+m.field_nam2+')>0'
lcid= m.field_nam1
lcgroup=m.field_nam2
lcorder=IIF(m.time_seq,' ORDER BY 1,3','')
SELECT &lcid AS id  ,&lcgroup AS grp, IIF(m.time_seq,effect_dt,{//}) AS effect_dt;
	FROM (m.con_file) WHERE  &lcwhere INTO CURSOR temp1 &lcorder
*
* Time sequence attribute - wrether the connection has a history
*
IF m.time_seq
	SELECT id ,grp FROM temp1 INTO CURSOR cligroup GROUP BY 1
ELSE
	SELECT id ,grp FROM temp1 INTO CURSOR cligroup
ENDIF

SELECT temp1
USE
IF !EMPTY(lcalias)
	SELECT (lcalias)
ELSE
	SELECT 0
ENDIF
RETURN _TALLY

****************************************************************************
*   FUNCTION getwhen - field when for the screens
****************************************************************************

FUNCTION getwhen
RETURN rladdmode OR rleditmode

****************************************************************************
*       FUNCTION fullist - returns number of ids in the idlist parameter,
*                                  idlist parameter modified to reflect
*                                  the security scope of the worker
*
*            PARAMETER idlist - the array of the client ids for the worker (output)
*                      mworker - the worker id
****************************************************************************

FUNCTION fullist
PARAMETER idlist,mworker,recurstop,iternum
PRIVATE ALL LIKE l*
lcalias=ALIAS()
lcwhere=''
lnclist=chlist(idlist,mworker)
IF lnclist=0
	IF glowncases
		RETURN 0
	ENDIF

	IF !EMPTY(gcsite)
		lcwhere='WHERE' + IIF(EMPTY(lcwhere),'',' and ') + ' site=alltrim(gcsite) '

	SELECT tc_id,effect_dt FROM fc_site;
		&lcwhere;
		ORDER BY 1,2;
		INTO CURSOR ('temp'+ALLTRIM(PADL(iternum,2,'0')))
	SELECT tc_id  FROM ('temp'+ALLTRIM(PADL(iternum,2,'0'))) GROUP BY 1 INTO CURSOR ('temp3'+ALLTRIM(PADL(iternum,2,'0')))
	ENDIF
	lcwhere=''
	IF !EMPTY(gcprogram)
		lcwhere='WHERE' + IIF(EMPTY(lcwhere),'',' and ') + ' program=alltrim(gcprogram) '

	SELECT tc_id,effect_dt FROM fc_prog;
		&lcwhere;
		ORDER BY 1,2;
		INTO CURSOR ('temp'+ALLTRIM(PADL(iternum,2,'0')))
	SELECT  tc_id FROM ('temp'+ALLTRIM(PADL(iternum,2,'0'))) GROUP BY 1 INTO CURSOR  ('temp4'+ALLTRIM(PADL(iternum,2,'0')))
    ENDIF
    ljoin=.t.
    DO CASE
     case !(EMPTY(gcprogram) or empty(gcsite))
      SELECT a.tc_id FROM ('temp3'+ALLTRIM(PADL(iternum,2,'0'))) A, ('temp4'+ALLTRIM(PADL(iternum,2,'0'))) B WHERE a.tc_id=b.tc_id INTO CURSOR ('temp5'+ALLTRIM(PADL(iternum,2,'0')))
     case !empty(gcprogram)
       SELECT a.tc_id FROM ('temp4'+ALLTRIM(PADL(iternum,2,'0'))) A INTO CURSOR ('temp5'+ALLTRIM(PADL(iternum,2,'0')))
     case !empty(gcsite)
	SELECT b.tc_id FROM  ('temp3'+ALLTRIM(PADL(iternum,2,'0'))) B  INTO CURSOR ('temp5'+ALLTRIM(PADL(iternum,2,'0')))
     otherwise
	ljoin=.f.
   endcase
	lcwhere=''
	IF !EMPTY(gctc)
		lcwhere=lcwhere+ ' tc=alltrim(gctc) '
	ENDIF
	IF !EMPTY(gcagency)
		lcwhere=lcwhere+ IIF(EMPTY(lcwhere),'',' and ') +  ' agency=alltrim(gcagency) '
	ENDIF
	lcwhere ='WHERE ' +lcwhere
	SELECT tc_id FROM STATUS &lcwhere INTO CURSOR ('temp6'+ALLTRIM(PADL(iternum,2,'0')))
	if ljoin
	 SELECT a.tc_id FROM ('temp5'+ALLTRIM(PADL(iternum,2,'0'))) A, ('temp6'+ALLTRIM(PADL(iternum,2,'0'))) B WHERE a.tc_id=b.tc_id INTO ARRAY idlist
	else
	 SELECT b.tc_id FROM ('temp6'+ALLTRIM(PADL(iternum,2,'0'))) B  INTO ARRAY idlist
	endif
    lnclist = _TALLY
	DIMENSION addlist(1)
	STORE ' ' TO addlist
	lnclist1=manageraccess(addlist,mworker) && Group access

	IF !empty(addlist)
		lnclist=intarray(idlist,addlist)
	ENDIF

ENDIF
* Second iteration for the supervised person
* Capable of fully traversing the tree of supervisees.
*
IF !recurstop
	SELECT worker_id FROM userprof WHERE superid=mworker INTO CURSOR ('temp'+ALLTRIM(PADL(iternum,2,'0')))
	SCAN
		SCATTER MEMVAR
		DIMENSION addemparr(1)
		STORE '' TO addemparr
		lnretsup=fullist(addemparr,m.worker_id,.T.,iternum+1)
		=addarray(idlist,addemparr)
		lnclist=ALEN(idlist,1)
	ENDSCAN
ENDIF
IF iternum=1
	=deltemps()
	IF !(EMPTY(lcalias) OR lcalias='TEMP')
		SELECT (lcalias)
	ELSE
		SELECT 0
	ENDIF
ENDIF
RETURN lnclist

****************************************************************************
*   CALLED FROM FUNCTION fullist
*       FUNCTION chlist - returns number of ids in the idlist parameter,
*                                  idlist parameter modified to reflect
*                                  the security scope of the worker with own
*                                                          cases or groups(e.g. facilities etc.) assigned
*
*            PARAMETER idlist - the array of the client ids for the worker (output)
*                      mworker - the worker id
****************************************************************************
FUNCTION chlist
PARAMETER idlist,mworker
PRIVATE ALL LIKE l*
lcalias=ALIAS()
SELECT * FROM connect WHERE worker_id=mworker AND tc=gctc INTO CURSOR ('tempz'+ALLTRIM(PADL(iternum,2,'0')))
* Own cases
IF _TALLY>0
	IF glowncases
		SELECT id FROM ('tempz'+ALLTRIM(PADL(iternum,2,'0'))) WHERE EMPTY(file_id) INTO ARRAY idlist
	ENDIF
ELSE
	SELECT ('tempz'+ALLTRIM(PADL(iternum,2,'0')))
	USE
	RETURN 0
ENDIF

* Facilities or other groups

SELECT a.*, b.file FROM ('tempz'+ALLTRIM(PADL(iternum,2,'0'))) A , FILES B WHERE a.file_id=b.id INTO CURSOR ('tempz2'+ALLTRIM(PADL(iternum,2,'0')))
SELECT DISTINCT FILE FROM ('tempz2'+ALLTRIM(PADL(iternum,2,'0'))) INTO CURSOR ('tempz6'+ALLTRIM(PADL(iternum,2,'0')))

DIMENSION addlist(1),endlist(1)
STORE ' ' TO addlist , endlist
SCAN
	SCATTER MEMVAR
	SELECT id FROM ('tempz2'+ALLTRIM(PADL(iternum,2,'0'))) WHERE FILE=m.file INTO ARRAY grouparr
	IF cligroup(m.file,grouparr)>0
		SELECT id FROM cligroup INTO CURSOR addlist
		=addarray(endlist,addlist,_TALLY)
	ENDIF

ENDSCAN
=addarray(idlist,endlist,ALEN(endlist))
if used('CLIGROUP')
 SELECT cligroup
 USE
ENDIF
IF !EMPTY(lcalias)
	SELECT (lcalias)
ELSE
	SELECT 0
ENDIF
RETURN 1

**************************************************************************
*
*       Appends elements from the source array to the target array.
*    Parameters Endlist      - Target array
*                      Addlist     - Source Array
*                      Elemnum - Number of Elements to Append
**************************************************************************

FUNCTION addarray
PARAMETER endlist,addlist,elemnum
PRIVATE ALL LIKE l*
IF EMPTY(addlist)
	RETURN
ENDIF
IF EMPTY(elemnum)
	elemnum=ALEN(addlist)
ENDIF
lnlen=ALEN(endlist)
IF !EMPTY(endlist)
	DIMENSION endlist(lnlen+elemnum)
ELSE
	DIMENSION endlist(elemnum)
	lnlen=lnlen-1
ENDIF
FOR lni=1 TO elemnum
	IF ASCAN(endlist,addlist(lni))=0
		endlist(lnlen+lni)=addlist(lni)
	ENDIF
ENDFOR
RETURN
*

**************************************************************************
* FUNCTION getrefs - returns an array of connect_no for
*                                              the allowed referrals
*   PARAMETER mreflist : the array of ids to return
*
**************************************************************************
FUNCTION getrefs
PARAMETER mreflist
PRIVATE ALL LIKE l*
lcwhere=IIF(glowncases,'WHERE ascan(gaidlist,tc_id)>0 ',det_access())
SELECT control_no;
	FROM referral;
	&lcwhere;
	INTO ARRAY  mreflist
RETURN _TALLY
*

*********************************************************************
FUNCTION secfunction
PARAMETER madd,medit,mdel,rightsread
PRIVATE ALL LIKE l*
lcalias=ALIAS()
IF !rightsread
	=readrights(madd,medit,mdel)
	rightsread=.T.
ENDIF
IF gldefscre AND !gltrymode
*       =sclright(WONTOP())
ELSE
	IF !madd
		SHOW GET (gcaddobjname) DISABLE
	ENDIF
	IF !medit
		SHOW GET (gcedobjname) DISABLE
	ENDIF
	IF !mdel
		SHOW GET (gcdelobjname) DISABLE
	ENDIF
ENDIF
IF !EMPTY(lcalias)
	SELECT (lcalias)
ELSE
	SELECT 0
ENDIF
RETURN
*

***********************************************************
FUNCTION ReadRights
PARAMETER lAdd,lEdit,lDel,cScreen_ID
*IF EMPTY(cScreen_ID)
*	cScreen_ID = PROGRAM(-1)
*ENDIF

IF Seek(gcScheme_id+Upper(cScreen_ID),"skipbar") .AND. !glSysAdmin
	lAdd  = skipbar.addenable
	lEdit = skipbar.editenable
	lDel  = skipbar.delenable
ELSE
*       lAdd  = .F.
*       lEdit = .F.
*       lDel  = .F.
	lAdd  = .T.
	lEdit = .T.
	lDel  = .T.
ENDIF

RETURN .t.

******************************************************************************
FUNCTION manageraccess
PARAMETER retarr,mworker
PRIVATE ALL LIKE l*
lcalias=ALIAS()
=openfile('stgroup','worker_id')
IF SEEK(mworker)
	SCATTER MEMVAR

	=openfile('GROUPS','GROUP_ID')
    IF SEEK(m.group_id)
     SCATTER MEMVAR
      =openfile('grtype','grouptype')
	  if seek(m.grouptype)
	   scatter memvar
	  endif
	  IF EMPTY(m.grfiltid)
	  * The group is defined through the stored list of
	  * of criteria e.g programs {00001,00002}

	   SELECT keyval FROM gritems WHERE group_id=m.group_id INTO ARRAY laprgs

	  else
	  * The group is defined through the criteria set generator
	  * e.g. program type equals '01' which is then resolved into
	  * list of programs corresponding to this condition in the given
	  * database instance.

	   lcwhere= ' WHERE ' + m.filtfield + '="'+alltrim(m.grfiltid) +'"'
	   select &gkey from (m.grouptable) &lcwhere INTO ARRAY laprgs
      ENDIF
	  IF _TALLY>0
			=cligroup(m.grouptable,laprgs)
			select id from cligroup into array retarr
	  ENDIF
	ENDIF
ENDIF
IF !EMPTY(lcalias)
		SELECT (lcalias)
ELSE
		SELECT 0
ENDIF
RETURN _TALLY

***********************************************************************
FUNCTION deltemps
PRIVATE ALL LIKE l*
FOR lk=1 TO 10
	IF USED('temp'+PADL(lk,1,'0'))
		SELECT ('temp'+PADL(lk,1,'0'))
		USE
	ENDIF
ENDFOR

FOR lj=1 TO 100
	IF USED('temp'+PADL(lj,2,'0'))
		SELECT ('temp'+PADL(lj,2,'0'))
		USE
	ENDIF
ENDFOR

FOR li=1 TO 1000
	IF USED('temp'+PADL(li,3,'0'))
		SELECT ('temp'+PADL(li,3,'0'))
		USE
	ENDIF
ENDFOR

****************************************************************************
*                   FUNCTION intarrs - takes two arrays as parameters
*                   RETURNS            their intersection as sets in the
*                                      first argument.
*                   PARAMETERS arr1  - first array
*                              arr2  - second array
*                              arr1      - return array
****************************************************************************


FUNCTION intarray
PARAMETERS arr1,arr2
EXTERNAL ARRAY arr2
PRIVATE ALL LIKE l*
lnlen1=ALEN(arr1)
lnlen2=ALEN(arr2)
lncycle=MIN(lnlen1,lnlen2)
lncounter=1
DIMENSION ares(lncycle)

IF lnlen1>lnlen2
	FOR li=1 TO lncycle
		IF ASCAN(arr1,arr2(li))>0
			ares(lncounter)=arr2(li)
			lncounter=lncounter+1
		ENDIF
	ENDFOR
ELSE
	FOR li=1 TO lncycle
		IF ASCAN(arr2,arr1(li))>0
			ares(lncounter)=arr1(li)
			lncounter=lncounter+1
		ENDIF
	ENDFOR
ENDIF

=ACOPY(ares,arr1)

IF lncounter>1
	DIMENSION arr1(lncounter-1)
	lnreturn=lncounter-1
ELSE
	IF EMPTY(arr1)
		lnreturn=0
	ENDIF
ENDIF

RETURN lnreturn


*********************************************************************************
FUNCTION DECIPHER
parameter String
PRIVATE i, cRet , ctemp
store '' TO i, ctemp ,cRet

FOR i=1 to len(String)
	ctemp = MOD(ASC(SUBSTR(String,i,1)) + MOD(i*179+11,255),255)
	cRet  = cRet + CHR(ctemp)
NEXT

RETU cRet


*********************************************************************************
FUNCTION ENCRYPT
parameter STRING
PRIVATE i, cRet
store '' TO i, ctemp, cRet

FOR i=1 to len(String)
	ctemp=ASC(SUBSTR(String,i,1))-MOD(i*179+11,255)
	ctemp=iif(ctemp>0,ctemp,ctemp+255)
	cRet = cret + CHR(ctemp)
ENDFOR

RETU cRet

*********************************************************************************
FUNCTION base_init
=OPENFILE('BASEINIT','BASENAME')
SCAN WHILE !EOF()
	=OPENFILE(ALLTRIM(baseinit.basename), ALLTRIM(baseinit.initkey))
	select baseinit
ENDSCAN

*********************************************************************************
FUNCTION base_clos
private i,lcalias
FOR i=1 to 225
	lcAlias=ALIAS(i)
	IF !empty(lcalias) .and. ;
			lcAlias != 'CLI_CUR' .and. ;
			lcAlias != 'STAFFCUR' .and. ;
			lcAlias != UPPER(gcTempObj) .and.;
			lcAlias != UPPER(gcTempSkip) .and. ;
			!seek(lcAlias,'baseinit')
		USE IN (i)
	ENDIF
ENDFOR

*********************************************************************************
FUNCTION defrights
PARAMETER mwindow
IF gldefscre AND !gltrymode
*       =sclright(mwindow)
endif
return .T.


FUNCTION aud_old
PARAMETER cDBF
***********************************************************************
*             Function Stores critical fields in a cursor             *
*             before making changes in database. Uses list of         *
*             critical fields from AUD_LIST.DBF. Takes a parameter    *
*             cDBF - name of database is going to be changed          *
*             Made by Joseph                                          *
***********************************************************************
PRIVATE nSaveArea, m.field, m.key
nSaveArea = Select()

SELECT *,;
  SPACE(10) AS KEYVAL    ,;
  SPACE(50) AS FIELDOLD  ,;
  SPACE(50) AS FIELDNEW   ;
 FROM  AUD_LIST           ;
 WHERE DBFNAME = cDBF  ;
 	AND inuse ;
 INTO CURSOR AUD_CUR

if _tally = 0
	select (nSaveArea)
   return .f.
endif
select 0
use (dbf('AUD_CUR')) alias AUDOLD again exclusive
select AUDOLD
scan
   m.field = cDBF+"."+fieldname
   m.key   = cDBF+"."+keyname
   repl fieldold with any2char(&field,fieldtype)
   repl keyval   with &key
endscan

select (nSaveArea)
return .t.

***********************************************************

FUNCTION aud_new
PARA cDBF
***********************************************************************
*             Function  saves critical fields were changed            *
*             after editing database. Uses cursor AUDOLD created      *
*             by AUD_OLD function                                     *
*             cDBF - name of database were changed                    *
*             Made by Joseph                                          *
***********************************************************************
PRIVATE nSaveArea
nSaveArea = Select()

select AUDOLD
scan 
   field = cDBF+"."+fieldname
   repl fieldnew with any2char(&field,fieldtype)
   if fieldnew != fieldold
      scatter memvar
      m.dt = date()
      m.time = time()
      m.user_id = IIF(TYPE("gcWorker")="U","WHO?",gcWorker)
      insert into AUDIT from memvar
   endif
endscan

use in audold

select (nSaveArea)

return .t.

***********************************************************
FUNCTION ANY2CHAR
PARA ANY,type
do case
   case upper(Type) = "C"
	return ANY
   case upper(Type) = "D"
	return dtoc(ANY)
   case upper(Type) = "N"
	return str(ANY)
   case upper(Type) = "L"
	return iif(ANY,"TRUE","FALSE")
endcase

***********************************************************
FUNCTION Conv2Char
* Converts a variable of a given type to char
PARAMETER mVar, cType, nLen, nDec
do case
case upper(cType) = "C"
		cResult = mVar
case upper(cType) = "M"
		cResult = mVar
case upper(cType) = "D"
		cResult = dtoc(mVar)
case upper(cType) = "N"
		cResult = str(mVar, nLen, nDec)
case upper(cType) = "L"
		cResult = iif(mVar,"Y","N")
	otherwise
		cResult = ""
endcase

RETURN PADR(cResult, nLen)

**********************************************************
FUNCTION IsDupSSNO
**********************************************************
*  Function.........: IsDupSSNO
*  Author...........: Jonathan White
*  Project..........:
*  Created..........: 09/12/95   11:34:08
*  Copyright........: (c) Defran Systems
*) Description......: Checks for duplicated Social Security Number
*  Calling samples..: IsDupSSNO( m.Client_DI, m.SSNo)
*  Parameters.......: tcClientID, tcSSNo
*  Returns..........: expL
*  Change History...:
*  Notes............:
**********************************************************
PARAMETERS tcClientID, tcSSNo
PRIVATE jaDupCheck
*- Find all records with ssno that
*- do not match the client's ID no.
SELECT client.Client_id                  ,;
       client.Ssn                         ;
  FROM client                             ;
 WHERE client.Ssn=m.tcSSNo                ;
   AND client.Client_id # m.tcClientID    ;
  INTO ARRAY jaDupCheck
*- Clean up
RELEASE jaDupCheck
*- If records found SSNO is Duplicate
RETURN (_TALLY > 0)
*-EOF IsDupSSNO

****************************************************
FUNCTION RefreshMenu
define window junk from -100,-100 to -99,-99
activate window junk
release window junk
Return .t.

**************************************************************
* Converts Numeric expression to character expr. based on capital
* letters of english alphabet and digits from "0" to "9"
* Example:
*    0  - A
*   35  - 9
*  1295 - 99
FUNCTION Num2Char
PARAMETER nNum
PRIVATE cRetVal, nFirstChar, nBase, aBaseChars, i

nFirstChar = ASC('A')
nBase = 36

DIMENSION aBaseChars[nBase]

* Get the letters from "A" to "Z"
FOR i = 1 TO 26
	aBaseChars[i] = CHR(i + nFirstChar - 1)
ENDFOR

* Add digits from "0" to "9"
FOR i = 27 TO 36
	aBaseChars[i] = STR(i-27,1,0)
ENDFOR

cRetVal = ''
DO WHILE .T.
	cRetVal = aBaseChars[1+nNum % nBase] + cRetVal
	nNum = Int(nNum / nBase)
	IF nNum = 0
		EXIT
	ENDIF
ENDDO

RETURN cRetVal

**************************************************************
* Converts Numeric expression to character expr. based on capital 
* letters of english alphabet
* Example: 
*    0 - A
*   25 - Z
*  675 - ZZ
FUNCTION Num2Char26
PARAMETER nNum
PRIVATE cRetVal, nFirstChar, nBase

cRetVal = ''
nFirstChar = ASC('A')
nBase = 26
DO WHILE .T.
	cRetVal = CHR(nFirstChar + nNum % nBase) + cRetVal
	nNum = Int(nNum / nBase)
	IF nNum = 0
		EXIT
	ENDIF
ENDDO

RETURN cRetVal
*

**************************************************************
* Converts base36 expr. back to numeric
FUNCTION Char2Num36
PARAMETER cCharNum
PRIVATE nRetVal, nFirstChar, nBase, aBaseChars, i

nFirstChar = ASC('A')
nBase = 36

DIMENSION aBaseChars[nBase]

* Get the letters from "A" to "Z"
FOR i = 1 TO 26
	aBaseChars[i] = CHR(i + nFirstChar - 1)
ENDFOR

* Add digits from "0" to "9"
FOR i = 27 TO 36
	aBaseChars[i] = STR(i-27,1,0)
ENDFOR

nRetVal = 0
FOR i = 1 TO Len(cCharNum)
	nRetVal = nRetVal + nBase ** (i-1) * (ASCAN(aBaseChars, ;
		Substr(cCharNum, Len(cCharNum)-i+1, 1))-1)
ENDFOR &&* i = Len(cCharNum)

RETURN nRetVal

**************************************************************
FUNCTION Char2Num26
* Converts base26 expr. back to numeric
PARAMETER cCharNum
PRIVATE nRetVal, nFirstChar, nBase, aBaseChars, i

nFirstChar = ASC('A')
nBase = 26

DIMENSION aBaseChars[nBase]

* Get the letters from "A" to "Z"
FOR i = 1 TO 26
	aBaseChars[i] = CHR(i + nFirstChar - 1)
ENDFOR

nRetVal = 0
FOR i = 1 TO Len(cCharNum)
	nRetVal = nRetVal + nBase ** (i-1) * (ASCAN(aBaseChars, ;
		Substr(cCharNum, Len(cCharNum)-i+1, 1))-1)
ENDFOR &&* i = Len(cCharNum)

RETURN nRetVal

************************************************************************
****  Returns time in 24 hr. format
************************************************************************
FUNCTION Time24
PARAM cTime, cAm_Pm
PRIVATE nVal2Add, cNewTime

IF TYPE('cTime') <> 'C' OR TYPE('cAm_Pm') <> 'C'
	RETURN '0000'
ENDIF

IF !BETWEEN(cTime,'0100','1259') .OR. !INLIST(cAm_Pm,'AM','PM')
	RETURN '0000'
ENDIF

nVal2Add = 0
cNewTime = ''

If cAm_Pm = 'AM'
	nVal2Add = 0
	
	IF Left(cTime,2) = '12'
		cTime = '00'+RIGHT(cTime,2)
	ENDIF

Else
	nVal2Add = IIF(LEFT(cTime,2) <> '12',1200,0)

ENDIf

cNewTime = TRANS(VAL(cTime) + nVal2Add, '@L 9999')

RETURN cNewTime


**********************************************************
FUNCTION Time24D
**********************************************************
*  Function.........: Time24D
*  Author...........: Jonathan White
*  Project..........:
*  Created..........: 10/24/95   10:10:16
*  Copyright........: (c) Defran Systems
*) Description......: Converts 12 hour time to 24 hour decimal time
*  Calling samples..: Time24D(m.beg_tm, m.beg_am)
*  Parameters.......: The time, AM or PM
*  Returns..........: expN
*  Change History...:
*  Notes............: 12 AM returned as 00.00 12 PM as 12.00
*                     An error returns -1
**********************************************************
PARAMETERS tcTime, tcAmPm
PRIVATE ALL LIKE j*
m.jcTime=ALLTRIM(m.tcTime)
*- check parameters passed
IF PARAMETERS() <2 OR !LEFT(UPPER(m.tcAmPm),1)$"A|P"
  RETURN -1
ENDIF
*- If a one or two digit time assume only hour passed
*- If 3 digits assume less than 10 hours plus minuets
*- If 5 digits it uses delimeter
DO CASE
CASE BETWEEN(LEN(m.jcTime),1,2)
  m.jcOldHour=m.jcTime
  m.jcOldMin='00'
CASE LEN(m.jcTime)=3
  m.jcOldHour=LEFT(m.jcTime,1)
  m.jcOldMin=RIGHT(m.jcTime,2)
CASE BETWEEN(LEN(m.jcTime),4,5)
  m.jcOldHour=LEFT(m.jcTime,2)
  m.jcOldMin=RIGHT(m.jcTime,2)
OTHERWISE
  RETURN -1
ENDCASE
*- trap for case where hour is 12 so when adding 12 noon becomes 12
* - and midnight becomes 00
m.jcOldHour=IIF(m.jcOldHour='12','00',m.jcOldHour)
*- strip off hour and convert to numeric 24 hour time
m.jnHour=VAL(IIF(UPPER(m.tcAmPm)="A",m.jcOldHour,STR(VAL(m.jcOldHour)+12,2,0)))
*- convert minuets to decimal (assumes no min over 59)
m.jnMin=ROUND(VAL(m.jcOldMin)/60,2)
RETURN m.jnHour+m.jnMin
*-EOF Time24


**********************************************************
PROCEDURE ScrnClose
**********************************************************
*  Procedure........: ScrnClose
*  Author...........: Jonathan White
*  Project..........:
*  Created..........: 11/08/1995   11:37:46
*  Copyright........: (c) Defran Systems
*) Description......: Closes Lookup tables opened for a screen
*  Calling samples..: ScrnClose
*  Parameters.......: expC (the
*  Change History...:
*  Notes............:
**********************************************************
PARAMETERS tcScreen2Close
DO openfile WITH "scrnval"
SCAN FOR UPPER(ALLTRIM(scrnval.window))=UPPER(m.tcScreen2Close)
   IF USED(ALLTRIM(scrnval.filename)) AND UPPER(ALLTRIM(scrnval.filename))#"STAFFCUR"
     USE IN (ALLTRIM(scrnval.filename))
   ENDIF
ENDSCAN
RETURN
*EOP ScrnClose

******************************************************************
** FUNCTION OPENEXCL                                            **
** Takes same parameters as OPENFILE but opens the file in      **
** exclusive mode. Gives the user a chance to retry opening.    **
** Returns .T. if file was opened , .F. if wasn't                **
******************************************************************
FUNCTION OPENEXCL
PARAMETER cFile, cTag, cAlias
PRIVATE lOpened,cOldError
cOldError = ON("ERROR")
cFile = AllTrim(cFile)

IF TYPE("cTag") <> "C"
	cTag = ""
ENDIF

IF TYPE("cAlias") <> "C" .OR. EMPTY(cAlias)
	cAlias = cFile
ENDIF

IF USED(cAlias)
   SELECT (cAlias)
ELSE
   SELECT 0
ENDIF
DO WHILE .T.
   nResult = 0
   lOpened = .T.
   ON ERROR STORE Error() TO nResult
   USE (LOCFILE(cFile+".dbf","DBF","Where is "+UPPER(cFile)+"?"));
	   AGAIN ALIAS (cAlias) EXCLUSIVE
   ON ERROR &cOldError
   IF nResult <> 0
      lOpened = .F.
      IF MSG2USER("FILEDENA",cFile) = 1
    	  LOOP
      ENDIF
   ENDIF
   EXIT
ENDDO
ON ERROR &cOldError
IF lOpened AND !EMPTY(cTag)
   SET ORDER TO TAG &cTag
ENDIF
RETURN lOpened



**********************************************************
FUNCTION SkipFor
**********************************************************
*  Function.........: SkipFor
*) Description......: Skip For function for menu ;
						Takes a screen id and whether a screen ;
						can be started in editing mode as parameters ;
						Returns .t. if disabled, .f. if enabled
*  Calling samples..: SkipFor()
*  Parameters.......: cScreen_ID, lAvail_Edit, lArchAvail
* Note: jss, 5/23/2000, rename 3rd parameter to from lIsReport to lArchAvail for better readability
*                       So, if in archive system, and function is available, lArchAvail=.t.
**********************************************************
PARAMETERS cScreen_ID, lAvail_Edit, lArchAvail
PRIVATE lResult

cOldExact=Set("Exact")
set exact on

IF (glArchive AND !lArchAvail) OR (!lAvail_Edit .AND. m.glEditing) 
	lResult = .t.
ELSE
	* if not available during edit mode (normal for all
	* screens but referral library) and menu is disabled - 
	* don't allow entry, otherwise - use security
	IF !lAvail_Edit AND !glMenuAvail 
		lResult = .t.
	ELSE
		IF !glSysAdmin
         * jss, 8/15/01, add set exact code to ensure proper lookup in following seek statement
			lResult = !Seek(gcScheme_id+Trim(cScreen_ID),"skipbar")
		ELSE
			lResult = .f.
		ENDIF
	ENDIF
ENDIF

Set Exact &cOldExact

RETURN lResult

*-EOF SkipFor

**********************************************************
FUNCTION Increment
**********************************************************
*  Function.........: Increment
*) Description......: Increment a variable if condition is met
*  Parameters.......: lCondition, nVar
**********************************************************
PARAMETERS lCondition, nVar
IF Type("nVar") <> "N"
	nVar = 0
ENDIF

IF lCondition
	nVar = nVar + 1
ENDIF

RETURN ""
*-EOF Increment

**********************************************************
FUNCTION UniqPassw
**********************************************************
*  Function.........: UniqPassw
*) Description......: Check if new password is unique
*  Parameters.......: cStaff_ID, cPassword
**********************************************************
PARAMETER cStaff_ID, cPassword
PRIVATE cTempPassw
cTempPassw = Encrypt(cPassword)
SELECT ;
	staff.staff_id ;
FROM ;
	staff ;
WHERE ;
	staff.password = cTempPassw .AND. ;
	staff.staff_id <> cStaff_ID ;
INTO ARRAY ;
	aTemp

Return _TALLY = 0
	
*-EOF UniqPassw

**********************************************************
FUNCTION UniqLogin
**********************************************************
*  Function.........: UniqLogin
*) Description......: Check if new Login Name is unique
*  Parameters.......: cStaff_ID, cLogin_Name
**********************************************************
PARAMETER cStaff_ID, cLogin_Name

SELECT ;
	staff.staff_id ;
FROM ;
	staff ;
WHERE ;
	staff.login_name = cLogin_Name .AND. ;
	staff.staff_id <> cStaff_ID  ;
INTO ARRAY ;
	aTemp

Return _TALLY = 0
	
*-EOF UniqLogin

************************************************************************************
FUNCTION BEG_MONTH
**********************************************************
*  Function.........: Beg_Month
*  Copyright........: (c) Defran Systems
*) Description......: Returns the date that is the first day of a 
*                     month of a date passed
*  Parameters.......: dDate
PARAMETER dDate
RETURN dDate - Day(dDate) + 1

**********************************************************
FUNCTION JulWeek
**********************************************************
*  Function.........: JulWeek
*  Copyright........: (c) Defran Systems
*) Description......: "Julian Week" - number of the week ;
*                      of a given date using julian date
*  Parameters.......: dDate
*  Returns..........: nWeek
**********************************************************
PARAMETERS dDate

nWeek = (VAL(SYS(1)) - (DATE() - dDate) - DOW(dDate) + 2) / 7

RETURN nWeek
*-EOF JulWeek

**********************************************************

* Check if blood sample number is not duplicate
**
FUNCTION BL_DUPL
parameters cBL_NO, cCtpn_ID
private lOk, aTemp

select ;
	bloodsmpno, ctform_id ;
from ;
	ai_ctest ;
where ;
	bloodsmpno = cBL_NO and ctform_id <> cCtpn_ID ;
into ;
	array aTemp

lOk = (_TALLY > 0)

Return lOk

****************************************************************************
* Splits the full name into last name and first name.
* PARAMETERS :
*      cFullName  - full name to split (like "John Smith" or "Smith, John"
*      cLastName  - resulting last name
*      cFirstName - resulting first name
****************************************************************************
FUNCTION SplitName
PARAMETER cFullName, cLastName, cFirstName

IF Type("cFullName") <> "C"
	cFullName=''
ENDIF

PRIVATE cWorkName
cWorkName = cFullname

DO CASE
	CASE "," $ cWorkName
		DO WHILE ", " $ cWorkName
			cWorkName = strtran(cWorkName,', ',',')   
		ENDDO 
		cLastName = Left(cWorkName,at(",",cWorkName)-1)
		cFirstName = SubStr(cWorkName,at(",",cWorkName)+1)
	CASE " " $ AllTrim(cWorkName)
		cWorkName = AllTrim(cWorkName)
		cFirstName = Left(cWorkName,at(" ",cWorkName)-1)
		cLastName = SubStr(cWorkName,at(" ",cWorkName)+1)
	OTHERWISE
		cFirstName = ""
		cLastName = AllTrim(cWorkName)
ENDCASE

cLastName  = AllTrim(cLastName)
cFirstName = AllTrim(cFirstName)

Return

**********************************************************
FUNCTION MkCli_Stat
**********************************************************
*  Function.........: MkCli_Stat
*) Description......: Create the cursor with client status types
**********************************************************

CREATE CURSOR cli_stat (code C(1), descript C(20))
INSERT INTO cli_stat VALUES ("A", "Active Only")
INSERT INTO cli_stat VALUES ("C", "Closed Only")
INDEX ON code TAG code
INDEX ON descript TAG descript ADDITIVE

RETURN
*-EOF MkCli_Stat

**********************************************************
PROCEDURE InsAutoFill
**********************************************************
PARAMETER cClient_ID, cMedNum, dEffect_dt
PRIVATE cRate_Grp, cProv_ID, cIns_ID

	IF !Empty(cMedNum)
		=OPENFILE("InsStat","Client_Id")
		IF !SEEK(cClient_ID,"InsStat")

			=OPENFILE("Rate_Grp")	
			LOCATE FOR Default
			cRate_Grp = IIF(FOUND(),Rate_grp.code,SPACE(5))

			=OPENFILE("MED_PROV")	
			LOCATE FOR IsMedicaid
			cProv_Id = IIF(FOUND(),Med_Prov.Prov_id,SPACE(5))
			
			cIns_ID = getnextid('INS_ID')
			IF Type("cIns_ID") <> "C"
				=Msg2User('NONEXTID')
				
				USE IN InsStat
				USE IN Rate_Grp
				USE IN Med_Prov
				
				Return
			ENDIF

			INSERT INTO InsStat						;
				(Client_ID,							;
				InsStat_id, 						;
				PROV_ID,							;
				Rate_grp,							;
				Prim_Sec,							;
				Pol_Num,  							;
				Effect_dt,							;
				Exp_dt,								;
				Group_num,							;
				Assignment,							;
				E_medicare,							;
				Sig_onfile,							;
				copay_type,							;
				Employer,							;
				USER_ID, DT,						;
				TM)				 					;
			VALUES 									;
				(cClient_id, 						;
				cIns_ID,							;
				cProv_ID,							;
				cRate_grp,							;
				1,									;
				cMedNum,							;
				dEffect_dt,							;
				{  /  /  },							;
				'',							        ;
				3,									;
				3,									;
				3,							 		;
				4,							 		;
				'',									;
				gcWorker, DATE(), 					;
				TIME())

			USE IN InsStat
			USE IN Rate_Grp
			USE IN Med_Prov
				
		ENDIF	
	ENDIF

RETURN
*- InsAutoFill

**********************************************************
FUNCTION HIV_Pos
**********************************************************
*  Function.........: HIV_Pos
*  Created..........: 02/19/98   10:24:58
*) Description......: Detects if client is HIV positive
**********************************************************
PARAMETERS cTC_ID
PRIVATE lHIV_Pos

SELECT ;
	hstat.hiv_pos;
FROM ;
	hivstat, ;
	hstat ;
WHERE ;
	hivstat.tc_id = cTc_id ;
	AND hivstat.hivstatus = hstat.code ;
	AND hivstat.effect_dt = (SELECT MAX(effect_dt) ;
										FROM ;
											hivstat f2 ;
										WHERE ;
											f2.tc_id = cTc_id ) ;
INTO ARRAY ;
	aHivPos

*-*	AND hivstat.hivstatus = hstat.code ;
*-*	AND tc_id + DTOS(effect_dt) IN ;
*-*			(SELECT tc_id + DTOS(MAX(effect_dt)) ;
*-*				FROM hivstat A2 ;
*-*				GROUP BY tc_id ;
*-*				WHERE effect_Dt <= DATE()) ;

IF _TALLY > 0		
	lHIV_Pos = aHivPos(1)
ELSE
	lHIV_Pos = .f.
ENDIF		

RETURN lHIV_Pos

*-EOF HIV_Pos

**********************************************************
FUNCTION CDC_AIDS
**********************************************************
*  Function.........: CDC_AIDS
*  Created..........: 04/24/1998   09:54:33
*) Description......: Checks if client has CDC defined AIDS
**********************************************************
PARAMETER cTC_ID, dCDCDate
PRIVATE lResult
lResult = .F.
dCDCDate = {}
DIMENSION aCDCDob(2)

* jss, 1/10/04, as per V. Behn/B. Blake, must only consider clients 13 and older when using cd4 count criteria
Select ;
	dob ;
From ;
	client, ai_clien ;
Where ;
	ai_clien.tc_id=ctc_id ;
  and ;
   ai_clien.client_id=client.client_id ;
Into Array ;
	aCDCDob

m.CDCDob=aCDCDob(1)
m.CDCAge=IIF(!EMPTY(m.CDCDob), Age(DATE(),m.CDCDob), 0)
	
* If the client is HIV positive,
* create a cursor AIDSCase of all records pointing that a client is an AIDS patient:
* select the last of CD4 tests and check that CD4 count < 200 or CD4 percent < 14, 
* and a list of diagnoses that are AIDS indicator deseases and combine.
* Use the earliest of dates as CDC date

IF HIV_Pos(cTC_ID)

	SELECT ;
		testres.tc_id , ;
		testres.testdate AS DATE ;
	FROM ;
		testres ;
	WHERE ;
		testtype = '06' ;
		AND testres.tc_id = cTC_ID ;
		AND ((!EMPTY(COUNT) AND COUNT < 200) OR (!EMPTY(percent) AND percent < 14)) ;
		AND (EMPTY(m.CDCAge) OR (m.CDCAge>12)) ;
	UNION ;
	SELECT ;
		ai_diag.tc_id , ;
		ai_diag.diagdate AS DATE ;
	FROM ;
		ai_diag ;
	WHERE ;
		!EMPTY(hiv_icd9) ;
		AND ai_diag.tc_id = cTC_ID ;
	INTO ARRAY ;
		aCDC_AIDS ;
	ORDER BY 2 

*-*		AND testres.tc_id + DTOS(testdate) IN (SELECT ;
*-*																tc_id + DTOS(MAX(testdate)) ;
*-*															FROM ;
*-*																testres A2 ;
*-*															WHERE ;
*-*																tc_id = cTC_ID ;
*-*																AND testtype = '06' ) ;

	IF _TALLY <> 0
		lResult = .T.
		dCDCDate = aCDC_AIDS[1, 2]
	ENDIF
ENDIF

RETURN lResult

*-EOF CDC_AIDS

**********************************************************
FUNCTION UpdConnect
**********************************************************
*  Function.........: UpdConnect
*  Author...........: Boris Kagan
*) Description......: Updates connect.dbf by latest changes in staff assignments
**********************************************************
PARAMETERS cTC_ID

select distinct;
	tc_id as id, worker_id, ;
	"00002" as tc, ;
	gcWorker as user_id, ;
	Date() as dt, ;
	Time() AS tm ;
from ;
	s_work ;
where ;
	tc_id = cTc_ID and ;
	effect_dt in ;
		(select max(effect_dt) ;
			from s_work aw ;
			where aw.tc_id = s_work.tc_id and ;
					aw.program = s_work.program) ;
into cursor ;
	sec_cur

INDEX ON id+worker_id TAG id

=OpenFile("connect", "file_id1")
* get rid of old staff connections if any
IF SEEK(SPACE(3) + cTC_ID)
	SCAN WHILE id = cTC_ID 
		IF !SEEK(id + worker_id, "sec_cur") 
			REPLACE user_id WITH gcWorker, dt WITH Date(), tm WITH Time()
			DELETE
		ENDIF
	ENDSCAN
ENDIF

* put in connect.dbf new staff connections if any
SELECT sec_cur
SCAN
	IF !SEEK(SPACE(3) + sec_cur.id + sec_cur.worker_id, "connect")
		SCATTER MEMVAR
		INSERT INTO CONNECT FROM MEMVAR
	ENDIF
ENDSCAN

RETURN
*-EOF UpdConnect


*******************************
*******************
FUNCTION RepMHRANul   
*******************
* Create a Null Report for MHRA Reports    
* jss, 3/19/03, add parameter "Prevention": this will alter title of null report to "Multi-Module HIV Prev. Services Program"
PARAMETERS NulRptName,NulRptNam1,NulRptNam2,NulRptNam3,NulRptNam4,PrintPrev,Prevention
SELECT ;
	ContrInf.Descript	AS ContrDes   ,;
  	nulrptname ,;
  	nulrptnam1 ,;
  	nulrptnam2 ,;
  	nulrptnam3 ,;
    nulrptnam4  ;
FROM 		ContrInf ;
WHERE ContrInf.Cid = cContract ;       
GROUP BY 1 ;
INTO CURSOR ;
	nulrpt          
          
IF PrintPrev=1
	REPORT FORM Mhranull TO PRINT PROMPT NOCONSOLE
ELSE
    REPORT FORM Mhranull PREVIEW
ENDIF	
RETURN
* jss, 2/21/01, add next function to print Null prevention reports
*******************
*FUNCTION RepPrevNul   
*******************
* Create a Null Report for MHRA Reports    
*PARAMETERS NulRptName,NulRptNam1,NulRptNam2,NulRptNam3,NulRptNam4,PrintPrev
*SELECT ;
*	ContrInf.Descript	AS ContrDes   ,;
*  	nulrptname ,;
*  	nulrptnam1 ,;
*  	nulrptnam2 ,;
*  	nulrptnam3 ,;
*    nulrptnam4  ;
*FROM 		ContrInf ;
*WHERE ContrInf.Cid = cContract ;       
*GROUP BY 1 ;
*INTO CURSOR ;
*	nulrpt          
          
*IF PrintPrev=1
*	REPORT FORM Prevnull TO PRINT PROMPT NOCONSOLE
*ELSE
*    REPORT FORM Prevnull PREVIEW
*ENDIF	
*RETURN
********************************************************************


**********************************************************
FUNCTION PrgEnrCur2
**********************************************************
*  FUNCTION.........: PrgEnrCur2
*) Description......: Creates a cursor of all program enrollments ;
* 					  active at a certain date and require enrollment
*  Parameters.......: cTC_ID, dDate, cServ_Cat
**********************************************************
PARAMETERS cTC_ID, dDate, cServ_Cat

* ALL program enrollments active at the time of encounter or currently
SELECT ;
	ai_prog.tc_id, ai_prog.program, ai_prog.start_dt, ai_prog.end_dt,program.enr_req ;
FROM ;
	ai_prog,program ;
WHERE ;
    program.prog_id = ai_prog.program AND ;
	ai_prog.tc_id = cTC_ID AND ;
	(ai_prog.end_dt >= dDate OR EMPTY(ai_prog.end_dt)) AND ;
	ai_prog.start_dt <= dDate ;
ORDER BY ;
	start_dt DESC ;
INTO CURSOR ;
	prog_enr1

* structure resulting cursor
SELECT ;
	PROGRAM, PADR(DTOC(start_dt)+" - "+DTOC(end_dt),25) AS descr1 ;
FROM ;
	prog_enr1;
WHERE enr_req = .T. ;
INTO CURSOR ;
	prog_enr2

* finally, shape up resulting cursor with program descriptions and
* filter out programs that don't operate current service category
SELECT ;
	prog_enr2.*, program.descript ;
FROM ;
	prog_enr2, PROGRAM, prog2sc ;
WHERE ;
	prog_enr2.program = program.prog_id AND ;
	prog2sc.tc = gcTc AND ;
	prog2sc.prog_id = program.prog_id AND ;
	prog2sc.serv_cat = cServ_Cat ;
INTO CURSOR ;
	prog_enr

INDEX ON PROGRAM TAG PROGRAM

IF USED("temp")
	USE IN temp
ENDIF

SELECT 0
USE (DBF("prog_enr")) AGAIN ALIAS temp EXCLUSIVE
INDEX ON descript TAG descript ADDITIVE

USE IN temp
USE IN prog_enr1
USE IN prog_enr2
USE IN prog2sc

RETURN
*-EOF Prog_Enrol


** THIS FUNCTION CORRECTS THE SPECIFIED ZIP CODE FIELD IN THE SPECIFIED FILE
** TO BE EITHER ZIP (5 CHAR) OR ZIP + 4 (9 CHAR) REMOVING ANY HYPHENS (-).
** ADDED 2/19/99 BY C.R.

FUNCTION FIXZIP
 PARAMETERS TCTABLE,TCFIELD
 PRIVATE HOLDSEL,TOTREC,LNPCT
 LNPCT = 0
 HOLDSEL = SELECT()
 TCTABLE = ALLTRIM(TCTABLE)
 TCFIELD = ALLTRIM(TCFIELD)
 do acttherm in thermo with ' ','Fixing zip codes'
 =OPENFILE(TCTABLE)
 SELECT &TCTABLE
 LOCATE
 TOTREC = RECCOUNT()
 SCAN

   IF AT('-',&TCFIELD) = 6
    REPLACE &TCFIELD WITH LEFT(&TCFIELD,5)
   ENDIF
   
   IF ALLTRIM(&TCFIELD) = '-'
    REPLACE &TCFIELD WITH SPACE(LEN(&TCFIELD))
   ENDIF

   IF LEN(ALLTRIM(&TCFIELD)) < 5
    REPLACE &TCFIELD WITH SPACE(LEN(&TCFIELD))
   ENDIF
      
   IF AT('-',&TCFIELD) = 0 AND LEN(ALLTRIM(&TCFIELD)) < 9
    REPLACE &TCFIELD WITH LEFT(&TCFIELD,5)
   ENDIF   

   LNPCT = INT((RECNO() / TOTREC) * 100)
   do updtherm with LNPCT, "Fixing zip codes in "+tctable in thermo
 ENDSCAN
 SELECT (HOLDSEL)
 RELEASE HOLDSEL
 do deactthermo in thermo
RETURN

*************************************************************************
* Builds a cursor with names of insurance providers for a client
*************************************************************************
FUNCTION GetInsProv
PARAMETER cClient_ID

SELECT ;
	med_prov.prov_id, ;
	med_prov.name, ;
	insstat.prim_sec, ;
	GetInsType(insstat.prim_sec) as ins_type, ;
	InsStat.effect_dt, ;
	InsStat.exp_dt ;
FROM ;
	med_prov, insstat ;
WHERE ;
	insstat.client_id = cClient_ID AND ;
	med_prov.prov_id = insstat.prov_id ;
INTO CURSOR ;
	prov_cur

INDEX ON STR(prim_sec, 1, 0) + STR({01/01/2100} - effect_dt) TAG ins_type

*************************************************************************
* Returns the description for insurance type
*************************************************************************
FUNCTION GetInsType
PARAMETER InsNum
PRIVATE cInsType

	DO CASE
	CASE InsNum = 1
		cInsType = "Primary     "
	CASE InsNum = 2
		cInsType = "Secondary   "
	CASE InsNum = 3
		cInsType = "Tertiary    "
	CASE InsNum = 4
		cInsType = "Funded/Other"
	OTHERWISE
		cInsType = "            "
	ENDCASE

RETURN cInsType

***************************************************************
****  FUNCTION TO check dates for Y2K in screens
****************************************************************
FUNCTION Y2KDt_Chk
PARAMETER dDate, cFieldName

IF Type("cFieldName") = "C" AND Type(cFieldName) = "D"
	REPLACE &cFieldName WITH Y2KRoll(dDate)
ELSE
	dDate = Y2KRoll(dDate)
ENDIF

Return .t.

***************************************************************
****  FUNCTION TO "Roll Over" dates for Y2K
****  Rolls over all dates within 5 years from today's date - 100
****************************************************************
FUNCTION Y2KRoll
PARAMETER dDate
IF BETWEEN(dDate, GOMONTH(Date(), -12*120), GOMONTH(Date(), -12*95))
	RETURN GOMONTH(dDate, 12*100)
ELSE
	RETURN dDate
ENDIF

*****************
FUNCTION ETO_Prog
*****************
* BK , 9/13/00, Create a cursor of programs to pick from that provide ETO
SELECT ;
	program.* ;
FROM ;
	program, prog2sc ;
WHERE ;
	prog2sc.tc = gcTc AND ;
	prog2sc.prog_id = program.prog_id AND ;
	prog2sc.serv_cat = '00006' ;
INTO CURSOR ;
	prog_cur

INDEX ON descript TAG name 

RETURN

*****************
FUNCTION GtHivAid
*****************
* jss, 2/2001
* this routine creates cursors of HARS-entered clients with HIV/AIDS

* HARS case: HIV positive clients with (CD4 count < 200 or CD4 percent < 14) or 
* HIV positive clients with AIDS indicator disease and AIDS diagnosis (adult and pediatric patients).
* we should also report all HIV positive pediatric patients without reporting their names.

* select a list of HIV positive clients whose information was entered in HARS
SELECT ;
	hivstat.tc_id ;
FROM ;
	hivstat, ;
	hstat, ;
	hars ;
WHERE ;
	hivstat.hivstatus = hstat.code ;
	AND hivstat.tc_id = hars.tc_id ;
	AND hivstat.tc_id + DTOS(hivstat.effect_dt) IN (;
								SELECT ;
									tc_id + DTOS(MAX(effect_dt)) ;
								FROM hivstat A2 ;
								GROUP BY tc_id ;
								WHERE effect_Dt <= dDateEnd ) ;
HAVING ;
	hstat.hiv_pos = .t.;
INTO CURSOR ;
	tHivPos

* from that list we should choose the clients with CD4 count < 200 or CD4 percent < 14 
* or with AIDS diagnosis and any of AIDS indicator desease.

*--> a list of clients with CD4 count < 200 or CD4 percent < 14
* we need to decide something about that CD4 test, but for now i'm going to use testtype='06'	
SELECT ;
	DIST tc_id ;
FROM ;
	testres ;
WHERE ;
	testtype = '06'	;
	AND (!EMPTY(count) AND count < 200 OR !EMPTY(percent) AND percent < 14) ;
	AND tc_id + DTOS(testdate) IN (SELECT tc_id + DTOS(MAX(testdate)) FROM testres A2 ;
		GROUP BY tc_id WHERE testtype = '06' AND testdate <= dDateEnd) ;
	AND tc_id IN (SELECT tc_id FROM tHivPos) ;
INTO CURSOR ;
	tCD4

*--> a list of clients with AIDS diagnosis and one of AIDS indicator diseases		
SELECT ;
	DIST tc_id ;
FROM ;
	ai_diag ;
WHERE ;
	!EMPTY(hiv_icd9) ;
	AND tc_id + icd9code + DTOS(diagdate) IN ;
	(SELECT tc_id + icd9code + DTOS(MAX(diagdate)) FROM ai_diag A2 ;
		GROUP BY tc_id, icd9code WHERE diagdate <= dDateEnd) ;
	AND tc_id IN (SELECT tc_id FROM tHivPos) ;	
INTO CURSOR ;
	tAidsInd

SELECT ;
	tc_id ;
FROM ;
	tCD4 ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	tAidsInd ;
INTO CURSOR ;
	tAidsCase					

** jss, 2/2001, one HIV+ criterion is a CD4 count between 200 and 499 AND a positive HIV test
SELECT ;
	DIST tc_id ;
FROM ;
	testres ;
WHERE ;
	testtype = '06'	;
	AND !EMPTY(count) AND BETWEEN(count, 200, 499)  ;
	AND tc_id + DTOS(testdate) IN (SELECT tc_id + DTOS(MAX(testdate)) FROM testres A2 ;
		GROUP BY tc_id WHERE testtype = '06' AND testdate <= dDateEnd) ;
	AND tc_id IN (SELECT tc_id FROM tHivPos) ;
INTO CURSOR ;
	tCD4HIV

** jss, 2/2001, one HIV+ criterion is Viral Load Count > 0
SELECT ;
	DIST tc_id ;
FROM ;
	testres ;
WHERE ;
	testtype = '05'	and testcode $ '11 12 13 18' ;
	AND (count > 0) ;
	AND tc_id + DTOS(testdate) IN (SELECT tc_id + DTOS(MAX(testdate)) FROM testres A2 ;
		GROUP BY tc_id WHERE testtype = '05' AND testdate <= dDateEnd) ;
INTO CURSOR ;
	tViralLoad

** jss, 2/2001, Western Blot test positive
SELECT ;
	DIST tc_id ;
FROM ;
	testres ;
WHERE ;
	testtype = '03'	;
	AND result = '1' ;
	AND tc_id + DTOS(testdate) IN (SELECT tc_id + DTOS(MAX(testdate)) FROM testres A2 ;
		GROUP BY tc_id WHERE testtype = '03' AND testdate <= dDateEnd) ;
INTO CURSOR ;
	tWesternBl

** jss, 2/2001, PCR test positive: testtype='05', testcode='03' Note: only given to children 
**																	18 months old or less
SELECT ;
	DIST tc_id ;
FROM ;
	testres ;
WHERE ;
	testtype = '05'	;
	AND testcode $ '03 04'	;
	AND result = '1' ;
	AND tc_id + DTOS(testdate) IN (SELECT tc_id + DTOS(MAX(testdate)) FROM testres A2 ;
		GROUP BY tc_id WHERE testtype = '05' AND testcode $ '03 04' AND testdate <= dDateEnd) ;
INTO CURSOR ;
	tPCR

* jss, 2/2001, CTS record exists with a positive test result
SELECT ;
	DIST tc_id ;
FROM ;
	ai_ctest ;
WHERE ;
	b1tstreslt = 2 ;
	AND tc_id + DTOS(enc_date) IN (SELECT tc_id + DTOS(MAX(enc_date)) FROM ai_ctest A2 ;
		GROUP BY tc_id WHERE enc_date <= dDateEnd) ;
INTO CURSOR ;
	tCTS

* jss, 2/2001, next cursor contains HIV+ cases
SELECT ;
	tc_id ;
FROM ;
	tCD4HIV ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	tViralLoad ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	tWesternBl ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	tPCR ;
UNION ;
SELECT ;
	tc_id ;
FROM ;
	tCTS ;
INTO CURSOR ;
	tHIVCase

* 2/2001, jss, now, include all HIV+ as well as AIDS patients, regardless of age
*              also, report ALL names, regardless of age
SELECT ;
	ai_clien.tc_id, ai_clien.client_id, .T. AS report_names ;
FROM ;
	ai_clien, ;
	client ;
WHERE ;
	ai_clien.client_id = client.client_id ;
	AND (EXISTS (SELECT tc_id FROM tHIVCase WHERE ai_clien.tc_id = tHIVCase.tc_id) ;
	    OR  EXISTS (SELECT tc_id FROM tAidsCase WHERE ai_clien.tc_id = tAidsCase.tc_id)) ;
INTO CURSOR ;
	cli2extr	

RETURN

*
******************
FUNCTION ChkEnrDt
******************
* jss, 2/15/02, check m.act_dt vs. earliest ai_prog date for client

PRIVATE nSelect, mReturn
nSelect=Select()
mReturn=.t.

* select will get any enrollment for this tc_id and program, ordering cursor from earliest forward
SELECT 	start_dt ;
FROM 	ai_prog ;
WHERE 	program=m.program ;
AND 	tc_id = m.tc_id ;
INTO CURSOR chkenrdt ;
ORDER BY 1

* act_dt cannot be earlier than earliest enrollment in this program for this client
IF _TALLY > 0
	GO TOP
	IF m.act_dt < chkenrdt.start_dt
		mReturn = .F.
	ENDIF
ENDIF

SELECT (nSelect)

RETURN mReturn

*

Function tmout_exit
If Readkey(1)=6
   gltimedout=.t.
   leavesys = .t.
	Clear Read All
 	
Endif
Return
*
* jss, 10/1/03, add new function ValTime, checks for imbedded spaces
****************
FUNCTION ValTime
****************
PARAMETER vTime

RETURN (LEN(TRIM(LEFT(vTime,2))) = 2 AND LEN(TRIM(RIGHT(vTime,2))) = 2)

* jss, 1/27/04, add the answer descriptionS for CT and NY here 
***             NOTE: stored values are 1 greater than screen values (e.g., screen=0, stored value=1)
*****************
FUNCTION GetAnsw1
*****************
m.AnswDesc1=SPACE(70)
DO CASE
CASE gcState='CT'
	DO CASE
	CASE FORMA.APTQUEST1=1
		m.AnswDesc1='No formal education'		
	CASE FORMA.APTQUEST1=2
		m.AnswDesc1='Elementary School (Grades K-6)'		
	CASE FORMA.APTQUEST1=3
		m.AnswDesc1='Middle School (Grades 7-8-9)'		
	CASE FORMA.APTQUEST1=4
		m.AnswDesc1='Some High School (Grades 10-11-12), but did not graduate'		
	CASE FORMA.APTQUEST1=5
		m.AnswDesc1='High School Graduate'		
	CASE FORMA.APTQUEST1=6
		m.AnswDesc1='Trade/Technical School'		
	CASE FORMA.APTQUEST1=7
		m.AnswDesc1='Some College, but did not graduate'		
	CASE FORMA.APTQUEST1=8
		m.AnswDesc1='College Graduate'		
	CASE FORMA.APTQUEST1=9
		m.AnswDesc1='Post Graduate Work'		
	CASE FORMA.APTQUEST1=10
		m.AnswDesc1='Masters/Doctoral Degree'
	ENDCASE	
CASE gcState='NY'
	DO CASE
	CASE FORMA.APTQUEST1=1
		m.AnswDesc1='No'		
	CASE FORMA.APTQUEST1=2
		m.AnswDesc1='Yes'		
	ENDCASE	
ENDCASE				
RETURN m.AnswDesc1

*****************
FUNCTION GetAnsw2
*****************
m.AnswDesc2=SPACE(70)
DO CASE
CASE gcState='CT'
	DO CASE
	CASE FORMA.APTQUEST2=2
		m.AnswDesc2='Continues to engage in unsafe sex'		
	CASE FORMA.APTQUEST2=3
		m.AnswDesc2='Continues to share needle/syringes'		
	CASE FORMA.APTQUEST2=4
		m.AnswDesc2='Re-tested because of window period'		
	CASE FORMA.APTQUEST2=5
		m.AnswDesc2='Tests about every 6 months as part of routine health care'		
	CASE FORMA.APTQUEST2=6
		m.AnswDesc2='Never received previous HIV test result'		
	CASE FORMA.APTQUEST2=7
		m.AnswDesc2='Court ordered'		
	CASE FORMA.APTQUEST2=8
		m.AnswDesc2='Wanted to confirm HIV+ test result'		
	CASE FORMA.APTQUEST2=9
		m.AnswDesc2='Low risk, concerned about HIV status'		
	CASE FORMA.APTQUEST2=10
		m.AnswDesc2='Other'
	ENDCASE	
CASE gcState='NY'
	DO CASE
	CASE FORMA.APTQUEST2=1
		m.AnswDesc2='No'		
	CASE FORMA.APTQUEST2=2
		m.AnswDesc2='Yes'		
	ENDCASE	
ENDCASE				
RETURN m.AnswDesc2

*****************
FUNCTION GetAnsw3
*****************
m.AnswDesc3=SPACE(70)
DO CASE
CASE gcState='CT'
	DO CASE
	CASE FORMA.APTQUEST3=1
		m.AnswDesc3='No'		
	CASE FORMA.APTQUEST3=2
		m.AnswDesc3='Yes'		
	ENDCASE	
CASE gcState='NY'
	DO CASE
	CASE FORMA.APTQUEST3=1
		m.AnswDesc3='No'		
	CASE FORMA.APTQUEST3=2
		m.AnswDesc3='Yes'		
	ENDCASE	
ENDCASE				
RETURN m.AnswDesc3

*****************
FUNCTION GetAnsw4
*****************
m.AnswDesc4=SPACE(70)
DO CASE
CASE gcState='CT'
	DO CASE
	CASE FORMA.APTQUEST4=1
		m.AnswDesc4='Not Tested'		
	CASE FORMA.APTQUEST4=2
		m.AnswDesc4='Venipuncture Test'		
	CASE FORMA.APTQUEST4=3
		m.AnswDesc4='Fingerstick Test'		
	CASE FORMA.APTQUEST4=4
		m.AnswDesc4='Fingerstick Test (In the field or at a community outreach site)'		
	CASE FORMA.APTQUEST4=5
		m.AnswDesc4='Oral Fluid Test (Orasure)'		
	CASE FORMA.APTQUEST4=6
		m.AnswDesc4='Negative HIV Test'		
	CASE FORMA.APTQUEST4=7
		m.AnswDesc4='Preliminary HIV Positive Test to be Confirmed by Venipuncture Test'		
	CASE FORMA.APTQUEST4=8
		m.AnswDesc4='Preliminary HIV Positive Test to be Confirmed by Orasure Test'		
	CASE FORMA.APTQUEST4=9
		m.AnswDesc4='Preliminary HIV Positive Test to be Confirmed by Fingerstick Test'
	ENDCASE	
CASE gcState='NY'
	DO CASE
	CASE FORMA.APTQUEST4=1
		m.AnswDesc4='Before age 12'		
	CASE FORMA.APTQUEST4=2
		m.AnswDesc4='12-14'		
	CASE FORMA.APTQUEST4=3
		m.AnswDesc4='15-16'		
	CASE FORMA.APTQUEST4=4
		m.AnswDesc4='17-18'		
	CASE FORMA.APTQUEST4=5
		m.AnswDesc4='19-20'		
	CASE FORMA.APTQUEST4=6
		m.AnswDesc4='21-25'		
	CASE FORMA.APTQUEST4=7
		m.AnswDesc4='26-35'		
	CASE FORMA.APTQUEST4=8
		m.AnswDesc4='36-55'		
	CASE FORMA.APTQUEST4=9
		m.AnswDesc4='56+'
	ENDCASE	
ENDCASE				
RETURN m.AnswDesc4

*****************
FUNCTION GetAnsw5
*****************
m.AnswDesc5=SPACE(70)
DO CASE
CASE gcState='NY'
	DO CASE
	CASE FORMA.APTQUEST5=1
		m.AnswDesc5='Before age 12'		
	CASE FORMA.APTQUEST5=2
		m.AnswDesc5='12-14'		
	CASE FORMA.APTQUEST5=3
		m.AnswDesc5='15-16'		
	CASE FORMA.APTQUEST5=4
		m.AnswDesc5='17-18'		
	CASE FORMA.APTQUEST5=5
		m.AnswDesc5='19-20'		
	CASE FORMA.APTQUEST5=6
		m.AnswDesc5='21-25'		
	CASE FORMA.APTQUEST5=7
		m.AnswDesc5='26-35'		
	CASE FORMA.APTQUEST5=8
		m.AnswDesc5='36-55'		
	CASE FORMA.APTQUEST5=9
		m.AnswDesc5='56+'
	ENDCASE	
CASE gcState='CT'

ENDCASE				
RETURN m.AnswDesc5

*****************
FUNCTION GetB1An1
*****************
m.AnsB1Desc1=SPACE(70)
DO CASE
CASE gcState='NY'
	DO CASE
	CASE B1PTQUEST1=1
		m.AnsB1Desc1='No'		
	CASE B1PTQUEST1=2
		m.AnsB1Desc1='Yes'		
	ENDCASE	
CASE gcState='CT'

ENDCASE				
RETURN m.AnsB1Desc1

*****************
FUNCTION GetB1An2
*****************
m.AnsB1Desc2=SPACE(70)
DO CASE
CASE gcState='NY'
	DO CASE
	CASE B1PTQUEST2=1
		m.AnsB1Desc2='No'		
	CASE B1PTQUEST2=2
		m.AnsB1Desc2='Yes'		
	ENDCASE	
CASE gcState='CT'

ENDCASE				
RETURN m.AnsB1Desc2

*****************
FUNCTION GetB2An1
*****************
m.AnsB2Desc1=SPACE(70)
DO CASE
CASE gcState='NY'
	DO CASE
	CASE B2PTQUEST1=1
		m.AnsB2Desc1='No'		
	CASE B2PTQUEST1=2
		m.AnsB2Desc1='Yes'		
	ENDCASE	
CASE gcState='CT'

ENDCASE				
RETURN m.AnsB2Desc1

*****************
FUNCTION GetB2An2
*****************
m.AnsB2Desc2=SPACE(70)
DO CASE
CASE gcState='NY'
	DO CASE
	CASE B2PTQUEST2=1
		m.AnsB2Desc2='No'		
	CASE B2PTQUEST2=2
		m.AnsB2Desc2='Yes'		
	ENDCASE	
CASE gcState='CT'

ENDCASE				
RETURN m.AnsB2Desc2

******************************************************
* Returns day of week as Monday = 1, Sunday = 7
* BK 03/17/2004
FUNCTION URS_DOW
******************************************************
parameter dDate

private nDOW

nDOW = DOW(dDate)

IF nDOW = 1
	nDOW = 7
ELSE
	nDOW = nDOW - 1
ENDIF

RETURN nDOW


