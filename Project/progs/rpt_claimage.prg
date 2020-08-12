**********************************
* Medicaid Billing Aging report
* Parms: From Date
*			Thru Date
*			Sort order
*
**********************************
PARAMETER dFrom, dThru, cPrimOrder, cPayer, cPaydesc, cProvider, cProvdesc, cTitle, lPrev

* jss, 1/24/07, convert URS version of program to AIRS: now uses cursor Cur_claim_age_grid as driver (selected clients)
Select Cur_claim_age_grid
Go Top
If Eof('Cur_claim_age_grid')
   oApp.Msg2User("INFORM","Client List is not defined...Please Create List on Selection Screen")
   Return
EndIf

SET ENGINEBEHAVIOR 70 
oApp.Msg2User("WAITGEN")

=OpenFile('CLAIM_HD')
=OpenFile('CLAIM_DT','INV_LINE')
			
nPrimOrder=Val(cPrimOrder)
**VT 08/31/2010 Dev Tick 4807 add c_sort_name
DO CASE
	CASE nPrimOrder = 1
		**cSortOrder = 'C.CLIENT_NAME'
		cSortOrder = 'c.c_sort_name'
      cOrd_dsc = 'Client Name'
   CASE nPrimOrder = 2
      cSortOrder = 'C.ID_NO'
      cOrd_dsc = 'Client ID Number'
	CASE nPrimOrder = 3
		cSortOrder = 'C.CINN'	
      cOrd_dsc = 'Medicaid Number'
	OTHERWISE
      **cSortOrder = 'C.CLIENT_NAME'  
      cSortOrder = 'c.c_sort_name' 
      cOrd_dsc = 'Client Name'
ENDCASE

* blank invoice var for selects
PRIVATE cBlankInv
cBlankInv = SPACE(LEN(claim_dt.invoice))

* select only those claims that were sent to Medicaid, 
* are not rebills and whose original
* billing date is between dFrom & dThru
*!*   SELECT ;
*!*      a.tc_id, ;
*!*      a.bill_date, ;
*!*      a.loc_code, ;
*!*      b.invoice, ;
*!*      b.line_no, ;
*!*      b.amount, ;
*!*      b.date, ;
*!*      b.first_inv, ;
*!*      b.first_line, ;
*!*      b.action, ;
*!*      b.status, ;
*!*      b.status_dt, ;
*!*      c.client_name, ;
*!*      c.id_no, ;
*!*      c.cinn ;
*!*   FROM ;
*!*      claim_hd a , ;
*!*      claim_dt b , ;
*!*      cur_claim_age_grid c ;
*!*   WHERE ;
*!*      a.invoice = b.invoice and ;
*!*      a.tc_id = c.tc_id and ;
*!*      a.prov_id =  cPayer and ;
*!*      a.prov_num = cProvider and ;
*!*      a.adj_void <> "V" and ;
*!*      b.first_inv = cBlankInv and ;
*!*      BETWEEN(a.bill_date, dFrom, dThru) and ;
*!*      a.processed = "D" and ;
*!*      c.isselect and ;
*!*      b.amount > 0 ;
*!*   ORDER BY ;
*!*      &cSortOrder, ;
*!*      a.bill_date DESC, ;
*!*      b.invoice ;
*!*   INTO CURSOR ;
*!*      agetemp1
* jss, 1/25/07, use joins
SELECT ;
   a.tc_id, ;
   a.bill_date, ;
   a.loc_code, ;
   b.invoice, ;
   b.line_no, ;
   b.amount, ;
   b.date, ;
   b.first_inv, ;
   b.first_line, ;
   b.action, ;
   b.status, ;
   b.status_dt, ;
   c.client_name, ;
   c.id_no, ;
   c.cinn ;
FROM ;
   cur_claim_age_grid c ;
 JOIN ;
   claim_hd a  ON c.tc_id = a.tc_id ;
 JOIN ;     
   claim_dt b  ON a.invoice = b.invoice ;
WHERE ;
   c.isselect                         and ;
   a.prov_id   = cPayer               and ;
   a.prov_num  = cProvider            and ;
   a.adj_void  <> "V"                 and ;
   b.first_inv = cBlankInv            and ;
   BETWEEN(a.bill_date, dFrom, dThru) and ;
   a.processed = "D"                  and ;
   b.amount    > 0 ;
ORDER BY ;
   &cSortOrder, ;
   a.bill_date DESC, ;
   b.invoice ;
INTO CURSOR ;
   agetemp1

IF _TALLY = 0
	oApp.Msg2User('NOTFOUNDG')
	RETURN
ENDIF

* Select any rebilled claims 
SELECT ;
   first_inv AS invoice, ;
   first_line AS line_no, ;
   status, ;
   action, ;
   status_dt, ;
   invoice AS sorter ;
FROM ;
   claim_dt ;
WHERE ;
   first_inv <> cBlankInv ;
INTO CURSOR ;
   rebills

INDEX ON INVOICE + LINE_NO + SORTER TAG LineNo DESC

* Create a cursor for reporting. Use the Break field to control
* Control breaks.
SELECT 0
CREATE CURSOR claimAge1 (Break C(10), Name C(40), ID_NO C(08), CINN C(11), BillDate D, ;
								Col1 N(9,2), Col2 N(9,2), Col3 N(9,2), Col4 N(9,2), ;
								Col5 N(9,2), Col6 N(9,2), Col7 N(9,2), FirstInv C(9), ;
								Inv C(9), First_line C(2), Line_no C(2))

SELECT agetemp1
SET RELATION TO INVOICE+LINE_NO INTO Rebills

GO TOP
cTC_ID = ' '
SCAN

	nAgeGrp = -1
	IF FOUND('Rebills')
		IF STATUS_DT > dFrom
			IF Ok2Age(Rebills.Status, Rebills.Action, Rebills.Status_Dt, dthru)
				nAgeGrp = GetClAge(BILL_DATE, dthru)
			ENDIF
		ENDIF
	ELSE
		IF Ok2Age(agetemp1.Status, agetemp1.Action, agetemp1.Status_Dt, dthru)
			nAgeGrp = GetClAge(BILL_DATE, dthru)
		ENDIF
	ENDIF

	IF nAgeGrp > -1
		DO WriteRec WITH TC_ID, nAgeGrp
	ENDIF	

ENDSCAN

oApp.Msg2User("OFF")

SELECT claimAge1
GO TOP

IF !EOF()
	cTime = TIME()
   cDate = DATE()
   cTitle = 'Claim Aging Report'
   Select ;
      Claimage1.*, ;
      cTime as cTime, ;
      cDate as cDate, ;
      cTitle as cTitle, ;
      cPayer as cPayer, ;
      cPayDesc as cPayDesc, ;
      cProvider as cProvider, ;
      cProvDesc as cProvDesc, ;
      dFrom as dFrom, ;
      dThru as dThru, ;
      cOrd_dsc as cOrd_dsc ;
   From ;
      ClaimAge1 ;
   Into Cursor ;
      ClaimAge     

    gcRptAlias = 'claimage'
    SELECT claimage 
    IF EOF()
       oApp.msg2user('NOTFOUNDG')
    Else
       DO CASE
          CASE lPrev = .f.
             Report Form rpt_claimage To Printer Prompt Noconsole NODIALOG 
          CASE lPrev = .t.   
             oApp.rpt_print(5, .t., 1, 'rpt_claimage', 1, 2)
       EndCase
            
    EndIf
ELSE
	oApp.Msg2User("NOTFOUNDG")
ENDIF

SET ENGINEBEHAVIOR 90 
RETURN

***************
FUNCTION Ok2Age
PARAMETER nStatus, nAction, dStatus, dthru
PRIVATE lRv
lRv = .F.

NOTE: ;
	STATUS CODES ARE: ;
	   0 = "Unknown"  ;
	   1 = "Pending"  ;
		2 = "Denied"   ;
		3 = "Paid"     ;
;
   Action CODES ARE: ;
		0 = "None"     ;
		1 = "Rebill"   ;
		2 = "Never Rebill" ;
		3 = "Adjust"   ;
		4 = "Void"

DO CASE
	CASE nStatus = 0		&& Unknown
		  lRv = .T.
	CASE nStatus = 1		&& Pending
		  lRv = .T.
	CASE nStatus = 2 .AND. (nAction = 0 or nAction = 1)		 && Denied & Rebill
			lRv = .T.
	CASE nStatus = 3 .AND. dStatus > dThru  && Paid after thru date
			lRv = .T.
ENDCASE

RETURN lRv
*
*****************
FUNCTION GetClAge
PARAMETER dBillDate, dthru
nGroup = -1
nDays = dThru - dBillDate
DO CASE
	CASE BETWEEN(nDays,00,30)
			nGroup = 1
	CASE BETWEEN(nDays,31,60)
			nGroup = 2
	CASE BETWEEN(nDays,61,90)
			nGroup = 3
	CASE BETWEEN(nDays,91,120)
			nGroup = 4
	CASE BETWEEN(nDays,121,365)
			nGroup = 5
	CASE BETWEEN(nDays,366,730)
			nGroup = 6
	OTHERWISE
			nGroup = 7
ENDCASE
RETURN nGroup
*
******************
PROCEDURE WriteRec
PARAMETER TcID, nGroup

m.Break      = agetemp1.Tc_ID
m.name       = agetemp1.client_name
m.id_no      = agetemp1.ID_NO
m.cinn       = agetemp1.CINN
m.billdate   = agetemp1.BILL_DATE
m.date       = agetemp1.DATE
m.Col1       = IIF(nGroup = 1, agetemp1.AMOUNT, 0)
m.Col2       = IIF(nGroup = 2, agetemp1.AMOUNT, 0)
m.Col3       = IIF(nGroup = 3, agetemp1.AMOUNT, 0)
m.Col4       = IIF(nGroup = 4, agetemp1.AMOUNT, 0)
m.Col5       = IIF(nGroup = 5, agetemp1.AMOUNT, 0)
m.Col6       = IIF(nGroup = 6, agetemp1.AMOUNT, 0)
m.Col7       = IIF(nGroup = 7, agetemp1.AMOUNT, 0)
m.Inv        = agetemp1.Invoice
m.Line_no    = agetemp1.LINE_NO 
IF FOUND('Rebills')
	m.FirstInv   = Rebills.INVOICE
	m.First_line = Rebills.LINE_NO
ENDIF
INSERT INTO claimAge1 FROM MEMVAR
RETURN

