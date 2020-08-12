Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              PName , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

LCProg = "" 
&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      LCProg = aSelvar2(i, 2)
   EndIf
EndFor

=close_data()

PRIVATE gchelp
gchelp = "Collaterals Associated with Encounters/Services Report Screen"
ccsite = ""
lccat  = ""
lcserv  = ""
cDate = DATE()
cTime = TIME()
cTitle = "Collaterals Associated with Services Report"
lcprog   = TRIM(lcprog)

* Put date limitation in SQL
cWhere = IIF(EMPTY(Date_from),""," AND ai_enc.act_dt >= Date_from")
cWhere = cWhere + IIF(EMPTY(Date_to),""," AND ai_enc.act_dt <= Date_to")

* jss, 9/5/03, fix problem with collateral gender, had been defined as a 1-char field, which caused all gender description lookups later to be "FEMALE"
SELECT  ;
	cli_cur.*, ;
	ai_enc.act_id, ai_enc.program, ai_enc.serv_cat, ai_enc.category,;
	ai_enc.enc_id, ai_enc.bill_to, ai_enc.act_dt, ;
	ai_enc.beg_tm,ai_enc.beg_am, ai_enc.end_tm, ai_enc.end_am, ;
	ai_enc.enc_note, ai_enc.enc_with, SPACE(40) as enc_withds, ;
	ai_enc.worker_id, serv_cat.descript,;
	SPACE(50) AS sexdesc,;
	enc_list.description    AS ENCNAME,;
	ai_colen.client_id   as colclient, ;
	space(20) as col_lname, ;
	space(15) as col_fname, ;
	{} as col_dob, ;
   space(2)  as col_gender, ;
	space(50) as colsexdesc, ;
	SPACE(25) AS ENCWORK,;
   lcTitle as lcTitle, ;
   PName as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;
FROM ;
	cli_cur, ai_enc, enc_list, serv_cat, ai_colen ;
WHERE ;
	cli_cur.tc_id = ai_enc.tc_id;
	AND ai_enc.act_dt <> {};
	AND ai_enc.enc_id  = enc_list.enc_id;
	AND ai_enc.program   = lcprog;
	AND ai_enc.serv_cat  = serv_cat.code ;
	AND ai_enc.act_id    = ai_colen.act_id ;
	&cWhere ;
INTO CURSOR ;
	EncCli

INDEX ON tc_id TAG tc_id

If Used('MyEnc') 
   Use in MyEnc
EndIf

SELECT 0
USE (DBF('EncCli')) ALIAS MyEnc AGAIN EXCLUSIVE

If Used('enccli')
   Use in enccli
EndIf
   
=OPENFILE("Client","CLIENT_ID")
************************  Opening Tables ************************************
=OPENFILE("staff"		,"staff_id")
=OPENFILE("userprof"	,"worker_id")
SET RELATION TO staff_id INTO staff

=OPENFILE("GENDER","CODE")
=OPENFILE("ENC_WITH","CODE")
**=OPENFILE("ENC_TYPE"  ,"Procacod")

SELE MyEnc
GO TOP
SCAN
   * Client's gender
   IF !Empty(myenc.gender) .AND. Seek(myenc.gender, "gender")
      REPL myenc.sexdesc WITH gender.descript
   EndIf
   
	* load collateral name, dob, gender
	IF SEEK(MyEnc.ColClient,'client')
		REPLACE col_lname  WITH Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(client.last_name)), client.last_name), ;
				col_fname  WITH Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(client.first_name)), client.first_name), ;
				col_gender WITH client.gender, ;
				col_dob    WITH client.dob
	ENDIF
   
	* Collateral's gender
	IF !Empty(myenc.col_gender) .AND. Seek(myenc.col_gender, "gender")
		REPL myenc.colsexdesc WITH gender.descript
	ENDIF

	* ENC_WITH
	IF !Empty(myenc.enc_with)
		IF Seek(myenc.enc_with, "enc_with")
			REPL myenc.enc_withds WITH enc_with.descript
		ELSE
			REPL myenc.enc_withds WITH PADR('Not Specified',40)
		ENDIF	
	ELSE
		REPL myenc.enc_withds WITH PADR('Not Specified',40)
	ENDIF

	*****   WORKER  ******
	* Worker providing encounter/service
	IF SEEK(MyEnc.worker_id, "userprof")
		REPL encwork WITH oApp.FormatName(UPPER(staff.last),UPPER(staff.first))
	ENDIF


	SELECT MyEnc
ENDSCAN

=openfile("how_prov","progcode")
=openfile("ai_enc","Tc_id_act")

SELE MyEnc
INDEX ON act_id TAG ACT_ID ADDITIVE

If Used('Cli_ser')
   Use in Cli_ser
EndIf

SELECT ;
	ai_serv.act_id,ai_serv.service,ai_serv.how_prov,;
	ai_serv.worker_id,ai_serv.servnote AS servnote,;
	ai_serv.s_beg_tm,ai_serv.s_beg_am,ai_serv.s_end_tm,;
	ai_serv.s_end_am,;
	SPACE(55)  AS  serv, ;
	SPACE(30)  AS  prov, ;
	SPACE(10) AS start,;
	SPACE(10) AS END,;
	SPACE(10)  AS  tottime,;
	SPACE(40) AS colname,;
	SPACE(35)  AS  WORK ,;
	"02"      AS LIST,;
	ai_serv.numitems, ;
   ai_serv.service_id ;
FROM ;
	ai_serv, ai_enc ;
WHERE ;
	ai_enc.act_id = ai_serv.act_id ;
   &cWhere ;
INTO CURSOR MyServ Readwrite 

=openfile("serv_list")

*!*   ************************start*******************************
*!*   Select MyServ
*!*   Go top
*!*   REPL MyServ.start WITH Iif(!EMPTY(MyServ.s_beg_tm), oApp.SHowTime(MyServ.s_beg_tm)+;
*!*            MyServ.s_beg_am, '') all
*!*   ***********************end******************************
*!*   Select MyServ
*!*   Go top
*!*   REPL MyServ.end WITH Iif(!EMPTY(MyServ.s_end_tm), oApp.SHowTime(MyServ.s_end_tm)+;
*!*            MyServ.s_end_am, '') all
*!*            
*!*   *********************tottime*****************************************
*!*   Select MyServ
*!*   Go top
*!*   REPL MyServ.tottime WITH Iif((!EMPTY(MyServ.s_beg_tm) AND !EMPTY( MyServ.s_end_tm)), FormHours(TimeSpent(MyServ.s_beg_tm,;
*!*            MyServ.s_beg_am,MyServ.s_end_tm,;
*!*            MyServ.s_end_am)), '') all
*!*   ******************work***********************************
*!*   Select Myserv
*!*   Go top
*!*   Set Relation to worker_id into userprof
*!*   REPL MyServ.work WITH PADR(oApp.FormatName(Staff.last,Staff.first),35) all
*!*   Set Relation to
*!*            
                  
SELE MyServ
GO TOP
SCAN
	******************serv***********************************
	IF SEEK(MyServ.act_id,"MyEnc")
*!*         SELECT service
*!*   		LOCATE FOR (service.serv_cat = MyEnc.serv_cat AND;
*!*   		 (service.enc_type = MyEnc.enc_type OR EMPTY(service.enc_type));
*!*   			AND	service.code = MyServ.service)
         SELECT serv_list
         LOCATE FOR serv_list.service_id = MyServ.service_id
      
			IF FOUND()
				REPL MyServ.serv WITH serv_list.description
			ENDIF

	ENDIF
	******************prov***********************************

	IF !EMPTY(MyServ.how_prov)
		IF SEEK((MyEnc.serv_cat+MyServ.how_prov),"how_prov")
			REPL MyServ.prov WITH How_prov.descript
		ENDIF
	ENDIF
	
   ************************start*******************************
   IF !EMPTY(MyServ.s_beg_tm)
      REPL MyServ.start WITH oApp.SHowTime(MyServ.s_beg_tm)+ MyServ.s_beg_am
   ENDIF
   ***********************end******************************
   IF !EMPTY(MyServ.s_end_tm)
      REPL MyServ.end WITH oApp.SHowTime(MyServ.s_end_tm)+ MyServ.s_end_am
   ENDIF

   **********************tottime*****************************************
   IF (!EMPTY(MyServ.s_beg_tm) AND !EMPTY( MyServ.s_end_tm))
      REPL MyServ.tottime WITH FormHours(TimeSpent(MyServ.s_beg_tm,;
         MyServ.s_beg_am,MyServ.s_end_tm,;
         MyServ.s_end_am))
   ENDIF
   ******************work***********************************
   IF !EMPTY(MyServ.worker_id)
      IF SEEK(MyServ.worker_id,"userprof")
         IF SEEK(userprof.staff_id,"staff")
            REPL MyServ.work WITH oApp.FormatName(Staff.last,Staff.first)
         ENDIF
      ENDIF
   EndIf
   		
  SELE MyServ
ENDSCAN

Use in how_prov

SELECT *    ;
FROM MyServ;
INTO CURSOR COLLSERV Readwrite
Index on act_id Tag act_id addit

SELECT 	COUNT(DIST tc_id) AS clitot ;
FROM     MyEnc ;
INTO CURSOR repcli

SELECT 	COUNT(DIST colclient) AS colltot ;
FROM     MyEnc ;
INTO CURSOR repcoll

SELECT 	COUNT(DIST act_id) AS enctot ;
FROM     MyEnc ;
INTO CURSOR repenc

SELECT 	COUNT(*) AS servtot ;
FROM     MyEnc, MyServ ;
WHERE    MyEnc.act_id=MyServ.act_id ;
INTO CURSOR repserv

SELECT 	sum(numitems) as totitems ;
FROM     MyServ ;
INTO CURSOR repitm

* totals for program
SELECT 	program ,;
		COUNT(DIST tc_id) AS clitot ;
FROM     MyEnc ;
INTO CURSOR clitot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	program ,;
		COUNT(DIST colclient) AS colltot ;
FROM     MyEnc ;
INTO CURSOR colltot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	program ,;
		COUNT(DIST act_id) AS enctot ;
FROM     MyEnc ;
INTO CURSOR enctot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	MyEnc.program ,;
		COUNT(*) AS servtot ;
FROM     MyEnc, MyServ ;
WHERE    MyEnc.act_id=MyServ.act_id ;
INTO CURSOR servtot ;
GROUP BY 1

INDEX ON program TAG program

SELECT 	MyEnc.program,sum(MyServ.numitems) AS totitems ;
FROM    MyServ,MyEnc ;
Where   MyEnc.act_id = MyServ.act_id ;
INTO CURSOR itmtot ;
GROUP BY 1

INDEX ON program TAG program

=openfile("bill_to","progcode")
=openfile("program","prog_id")
SELE MyEnc
SET RELATION TO act_id INTO COLLSERV
SET SKIP TO COLLSERV
SET RELATION TO SERV_CAT+bill_to INTO BILL_TO ADDITIVE
SET RELATION TO program INTO program ADDITIVE
* jss, 10/98, add next 3 relationships to handle the new "totals cursors"
SET RELATION TO program INTO itmtot  ADDITIVE
SET RELATION TO program INTO servtot ADDITIVE
SET RELATION TO program INTO enctot  ADDITIVE
SET RELATION TO program INTO clitot  ADDITIVE
* jss, 2/1/02, fix problem when colltot was not be related to report cursor
SET RELATION TO program INTO colltot  ADDITIVE

SELE MyEnc
**VT 08/27/2010 Dev Tick 4807 add Upper
**INDEX ON program + col_lname + col_fname + serv_cat TAG PLNFNSC ADDI
INDEX ON program + Upper(Alltrim(col_lname)+Alltrim(col_fname)) + serv_cat TAG PLNFNSC ADDI

oApp.msg2user("OFF")
gcRptName = 'rpt_col_serv'
Select MyEnc
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
           DO CASE
               CASE lPrev = .f.
                     Report Form rpt_col_serv  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     
                     oApp.rpt_print(5, .t., 1, 'rpt_col_serv', 1, 2)
            ENDCASE
EndIf

SET CENT ON
*********************
Function close_data

If Used('MyEnc')
   Use in Myenc
EndIf

If Used('Myserv')
   Use in Myserv
EndIf

If Used('Collserv')
    Use in Collserv
EndIf

If Used('repitm')
   Use in repitm
EndIf

If Used('repserv')
   Use in repserv
EndIf

If Used('repenc')
   Use in repenc
EndIf

If Used('repcli')
   Use in repcli
EndIf

If Used('enctot')
   Use in enctot
EndIf

If Used('clitot')
   Use in clitot
Endif
return

******************************************************
FUNCTION GetHeader
DO CASE
CASE collserv.list = "02"
	RETURN ("Services Provided")
OTHERWISE
	RETURN("")
ENDCASE
*****
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
nMinutes =    (nEndHours * 60 + VAL(RIGHT(cEnd_tm,2))) - ;
         (nBegHours * 60 + VAL(RIGHT(cBeg_tm,2)))

Return IIF(nMinutes >= 0, nMinutes, 24*60 + nMinutes)

********************************************************************
**** Display time (numeric) in HH:MM format
********************************************************************
FUNCTION FormHours
PARAMETER nTime
Return StrTran(Str(INT(nTime/60),2)+":"+Str(nTime%60,2),' ','0')

