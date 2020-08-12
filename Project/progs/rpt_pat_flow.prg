Parameters    lPrev, ;              && Preview     
              lDiag, ;
              lTest, ;
              lMed, ;
              lServ, ;
              Enc_Date, ;  
              Enc_ToDt
              
PRIVATE gchelp
gchelp = "Patient Flow Sheet Window"
cDate = DATE()
cTime = TIME()

=OPENFILE("AI_clien", "TC_ID")
IF SEEK(gcTc_Id , "Ai_clien")
*-- AF Added discrete
   SCATTER FIELDS client_id, id_no, mail_cont, discrete , ;
                phone_cont, home_cont, placed_dt, case_no MEMVAR
                
      Select top 1 incare ;
      from lv_ai_activ;
      where tc_id =gcTc_id ;
      Into Cursor t_act ;
      Order by effective_dttm desc

      m.aiopen = Iif(t_act.incare, "Open  ", "Closed")
      Use in t_act  
ELSE
   oApp.msg2user("NOTFOUND")
   RETURN
ENDIF


m.sexdesc = ""
=OPENFILE("gender", "code")
Select cli_cur
cOrd = Order()
Set Order to client_id

* jss, 8/29/03, add "someother" to scatter
IF SEEK(m.client_id , "cli_cur")
   SCATTER FIELDS last_name, first_name,ssn,cinn, sex, gender, dob,;
   	phhome ,phwork,birth_lbs,birth_oz, hispanic, white, blafrican, asian, ;
   	hawaisland, indialaska, unknowrep, ethnic, insurance, someother MEMVAR
     
   IF SEEK(m.gender , "gender")
      m.sexdesc = gender.descript
   ENDIF
ELSE
    oApp.msg2user("NOTFOUNDG")
    RETURN
EndIf

Do Case
	Case cli_cur.hispanic = 2
		m.hisp_des = "Hispanic" 
	Case cli_cur.hispanic = 1
		m.hisp_des = "Non-Hispanic" 
	Otherwise
		m.hisp_des = "Unknown/Unreported" 
EndCase		

m.race_des = ''
m.race_des = m.race_des + Iif(white = 1, 'White', '')
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(blafrican = 1, ', Black or African-American', ''), Iif(blafrican = 1, 'Black or African-American', '')) 
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(asian = 1, ', Asian', ''), Iif(asian = 1, 'Asian', ''))
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(hawaisland= 1, ', Native Hawaiian/Pacific Islander', ''), Iif(hawaisland= 1, 'Native Hawaiian/Pacific Islander', '')) 
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(indialaska = 1, ', American Indian or Alaskan Native', ''), Iif(indialaska = 1, 'American Indian or Alaskan Native', ''))
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(unknowrep = 1, ', Unknown/unreported', ''), Iif(unknowrep = 1, 'Unknow/unreported', ''))
* jss, 8/29/03, add "Some Other Race"
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(someother = 1, ', Some Other Race', ''), Iif(someother = 1, 'Some Other Race', ''))

Do Case
	Case cli_cur.insurance = 0
		m.ins_des = '' 
	Case cli_cur.insurance = 1 
		m.ins_des = "Known, Specify" 
	Case cli_cur.insurance = 2 
		m.ins_des = "Unknown/Unreported" 
	Case cli_cur.insurance = 3
	 	m.ins_des = "No Insurance" 
EndCase		
				
Select cli_cur
Set Order to &cOrd

=OPENFILE("Address", "client_id")
*=OPENFILE("Cli_hous", "Client_id")
*SET FILTER TO lives_in
*SET RELATION TO hshld_id INTO ADDRESS

IF SEEK(m.client_id, "address")
   Select address
   SCATTER FIELDS street1, street2, city, st, zip MEMVAR
   If oApp.gldataencrypted  
      m.street1 = osecurity.decipher(Alltrim(m.street1))
   EndIf
ELSE
    m.street1 = ""
    m.street2 = ""
    m.city    = ""
    m.st      = ""
    m.zip     = ""
    m.home_ph = ""
    m.work_ph = ""
ENDIF



=OPENFILE("Ethnic", "Code")
If Seek(m.ethnic, "Ethnic")
	m.ethnicdet = ethnic.descript
Else	
	m.ethnicdet = ''
Endif

=OPENFILE("AI_ENC"   , "Tc_id_act")
SET FILTER TO !EMPTY(AI_enc.act_dt)

IF SEEK(gcTc_Id, "ai_enc")
   m.act_dt  = ai_enc.act_dt
ELSE
   m.act_dt  = ""
ENDIF

* HIV Status
=OPENFILE("hstat", "CODE")
=OPENFILE("HIVSTAT", "TC_ID")
SET RELATION TO hivstatus INTO HSTAT
IF SEEK(gcTc_Id, "HIVSTAT")
   m.effect_dt = hivstat.effect_dt
   m.hivstatus = hstat.descript
ELSE
   m.effect_dt = {}
   m.hivstatus = ""
ENDIF

m.cdcdate = {}
m.cdc = IIF(CDC_AIDS(gcTc_Id, m.cdcdate), "Yes", "No")

Select hstat
Set Relation to

* TB status
=OPENFILE("TBSTATUS"  , "TC_ID")
m.tbdate =CTOD("  /  /  ")
m.tbstat = ""
m.ppddate = ""
m.ppdres = ""
IF SEEK(gcTc_Id, "tbstatus")
   m.tbdate = tbstatus.effect_dt
   IF (tbstatus.tbunk)
      m.tbstat = "TB Status Unknown"
   ELSE
      IF !EMPTY(tbstatus.ppddate)
            m.ppddate = tbstatus.ppddate
      ENDIF
      IF tbstatus.ppddone = 1
         =OPENFILE("test_res"  , "CODE")
         IF SEEK(tbstatus.ppdres, "test_res")
            m.ppdres = test_res.descript
            IF !EMPTY(m.ppddate)
               m.tbstat = ("PPD Date:" + dtoc(m.ppddate) + SPACE(5) + m.ppdres)
            ELSE
               m.tbstat = ("PPD Date:" + m.ppddate + SPACE(5) + m.ppdres)
            ENDIF
         ELSE
            m.tbstat = "PPD Done"
         ENDIF
      ELSE
         IF tbstatus.ppddone = 2
            IF !EMPTY(m.ppddate)
               m.tbstat = ("PPD Date:" + dtoc(m.ppddate) + SPACE(5) + "PPD Not Done")
            ENDIF
         ELSE
            m.tbstat = ""
         ENDIF
      ENDIF
   ENDIF
ELSE
   m.tbstat = "No TB Status For This Client"
ENDIF

IF EMPTY(m.tbstat)
   m.tbstat = "Unknown"
ENDIF

m.coll_inv = REPL("_", 25)
m. serpmemo = SPACE(2) + REPL("_", 21)+ SPACE(16) + REPL("_", 20)+ SPACE(10) + REPL("_", 20);
             + SPACE(6) + REPL("_", 8)
m.topic_ul = SPACE(15) + REPL("_", 20)  
* lall, lmed, ldiag, ltest, lserv
If Used('temp')
   Use in temp
EndIf

If Used('temp3')
   Use in temp3
EndIf

If Used('temp4')
   Use in temp4
EndIf
   
CREATE CURSOR temp ;
             (col1 C(10),  ;
              col2 C(80),  ;
              col3 C(30),  ;
              col4 C(60),  ;
              col5 C(10),  ;
              col6 C(10),  ;
              col7 C(130), ;
              col8 C(12),  ;
              col9 C(30),  ;
              iswhat C(2), ;
              id   C(18),  ;
              enc  C(1),   ;
              serv_cat C(5), ;
              cat_row N(6) )

 SELECT temp
 =AFIELDS(aCliRef)

 CREATE CURSOR temp1 FROM ARRAY aCliRef     && MEDICATION
 CREATE CURSOR temp3 FROM ARRAY aCliRef     && SERVICE CATEGORY
 CREATE CURSOR temp4 FROM ARRAY aCliRef     && 
 CREATE CURSOR temp11 FROM ARRAY aCliRef    && DIAGNOSIS
 CREATE CURSOR temp12 FROM ARRAY aCliRef    && LAB TEST

=openfile("serv_cat","code")
=openfile("program","prog_id")

*********************************************************************************************************
* MEDICATION*************************

m.cat_row=0

IF lmed
	memw = SET("MEMOWIDTH")
	SET MEMOWIDTH TO 125
   
*!*      SELECT DTOC(pres_date)     		AS col1	 , ;
*!*             ALLTRIM(b.brd_desc)+ '/' + chr(13) + '[' + ALLTRIM(d.category) + ']' AS col2	 , ;
*!*             LEFT(b.strength,20)    	AS col4 	 , ;
*!*             admin 							AS col3   , ;
*!*             LEFT(b.route,8)       		AS col9	 , ;
*!*             dur  							AS col8	 , ;
*!*             1 								AS cat_row, ;
*!*           	 presh_id 						AS id     , ;
*!*           	 pres_date										;
*!*      FROM pres_his  , ;
*!*           medicat  B, ;
*!*           drugxref C, ;
*!*           drug_cat D  ;
*!*      WHERE client_id = m.Client_Id ;
*!*      AND   drug = B.ndc_CODE			;
*!*      AND   B.drug_id = c.drug_id   ;
*!*      AND   c.cat_id  = d.cat_id    ;
*!*      INTO CURSOR ;
*!*      	Med     ;
*!*      ORDER BY ;
*!*      	9 DESC

** jss, 2/15/07, fix problem with duplicates d/t multiple rows per drug_id in drugxref table
   SELECT DTOC(pres_date)           AS col1    , ;
          ALLTRIM(b.brd_desc)+ '/'  AS colx    , ;
          Space(62)                 as coly , ;
          LEFT(b.strength,20)       AS col4     , ;
          admin                     AS col3   , ;
          LEFT(b.route,8)           AS col9    , ;
          dur                       AS col8    , ;
          1                         AS cat_row, ;
          presh_id                  AS id     , ;
          pres_date                 as pres_date , ;
          b.drug_id                 as drug_id ;
   FROM pres_his  , ;
        medicat  B ;
   WHERE client_id = m.Client_Id ;
   AND   drug = B.ndc_CODE         ;
   INTO CURSOR ;
      Med1     ;
   ORDER BY ;
      9 DESC ;
   Readwrite
      
   Select * From DrugXref into cursor cur_DrugX readwrite nofilter
   Select cur_DrugX
   Index on drug_id tag drug_id

   =Openfile("drug_cat","cat_id")
      
   Select Med1
   Set Relation to drug_id into cur_DrugX
   Select cur_DrugX
   Set Relation to cat_id into drug_cat addi
   
   Select med1
   Replace all coly with '[' + ALLTRIM(drug_cat.category) + ']'
      
   Select   col1, ;
            alltrim(colx) + chr(13)+ alltrim(coly) as col2, ;
            col4, ;
            col3, ;
            col9, ;
            col8, ;
            cat_row, ;
            id, ;
            pres_date ;
   from med1 ;
   into cursor ;
         med ;
   order by 9 desc      
** end of 2/15/07 fix...   
   	
	SELECT temp1
	APPEND BLANK
	IF _TALLY <> 0
  		REPL  col1 WITH "Start Date", ;
  				col2 WITH "Drug Name/[Category]", ;
      		col4 WITH "Dosage", ;
      		col3 WITH "Administration", ;
      		col9 WITH "Route" , ;
      		col8 WITH "Duration" , ;
      		id   WITH REPLICATE('Z',18)
  		APPEND FROM (dbf('med'))
  		
  	* jss, 5/16/2000, add code here to print remarks	
  		SELE pres_his
  		SET ORDE TO presh_id
  		SELE med
  		SET RELA TO id INTO pres_his
   * jss, must place remarks immediately after their associated detail line, thus the hoops we jump thru below

      m.col8 = space(12)
      m.col5 = SPACE(10)
      m.col1 = space(10)
      m.col6 = SPACE(10)
      m.col9 = space(30)
      m.col7 = space(130)
      m.cat_row=1
  		SCAN 
         m.id=id
  			IF FOUND('pres_his') AND NOT EMPTY(pres_his.remarks)
	         m.col7 = PADR("Remarks:",130)
	         SELE temp1
	         LOCATE FOR id = pres_his.presh_id 
   	      INSERT BLANK
   	      GATHER MEMVAR
   	      SELE pres_his
      	   mml = MEMLINES(pres_his.remarks)
	         FOR i=1 to mml
	              SELE temp1
   	           m.col7 = "\\   " + MLINE(pres_his.remarks, i)
         		  INSERT BLANK
         		  GATHER MEMVAR
	         ENDFOR
  			ENDIF
  		ENDSCAN
      SELE temp1
		REPLACE ALL cat_row WITH RECNO() FOR NOT EMPTY(cat_row)
   * in order to preserve proper sort order, blank out ID (SORT ORDER: ISWHAT+SERV_CAT+ID+ENC+CAT_ROW+COL1)
		REPLACE ALL ID WITH REPLICATE(' ',18) 
	ELSE
		REPLACE col2 WITH "No Medication History "
	ENDIF
 	REPLACE ALL iswhat WITH "10"
 	SET MEMOWIDTH TO (memw)
   
 Use in med
* jss, 2/15/07, add next 2 lines 
 Use in med1
 Use in cur_drugx
ENDIF && lmed
****************
* SERVICE CATEGORY*******
IF lserv
	=openfile("staff", "staff_id")
	=openfile("userprof", "worker_id")
	=openfile("bill_to", "progcode")
	=openfile("ai_serv", "act_id")
	=openfile("ai_colen", "act_id")

	**=openfile("ai_enc", "Tc_id_act")
	**SET FILTER TO !EMPTY(AI_enc.act_dt)

	m.cat_row = 0
	go top
 
	DO CASE
 	* both dates entered
 	CASE !EMPTY(Enc_Date) AND !EMPTY(Enc_ToDt)
 		cDateExpr = " AND BETWEEN(ai_enc.act_dt, Enc_Date, Enc_ToDt)"
 	* only "date from" entered
 	CASE !EMPTY(Enc_Date) AND EMPTY(Enc_ToDt)
 		cDateExpr = " AND ai_enc.act_dt >= Enc_Date"
 	* only "date to" entered
 	CASE EMPTY(Enc_Date) AND !EMPTY(Enc_ToDt)
 		cDateExpr = " AND ai_enc.act_dt <= Enc_ToDt"
 	* no dates entered
 	OTHERWISE
 		cDateExpr = ""
	EndCase
   
   If Used('t_enc')
      Use in t_enc
   EndIf
      
   Select * ;
   from ai_enc ;
   where ai_enc.tc_id = gcTc_Id AND ai_enc.serv_cat='00002' &cDateExpr ;
   into cursor t_enc
   
**	SCAN FOR ai_enc.tc_id = gcTc_Id AND ai_enc.serv_cat='00002' &cDateExpr
    Scan 
 ******************COL1, COL6, iswhat, id, enc,serv_cat***********************************
   	m.cat_row = m.cat_row +1
   	m.col1   = dtoc(t_enc.act_dt)
   	m.col5   = PADR(SHowTime(t_enc.beg_tm) + t_enc.beg_am, 10)
   	m.iswhat = "35"
   	m.id     = DTOS(t_enc.act_dt) + t_enc.act_id
   	m.enc    = "C"
   	m.serv_cat = t_enc.serv_cat
   ******************COL2***********************************
      Select enc_list
      Locate for t_enc.enc_id = enc_list.enc_id 
      If Found()
         m.col2 = PADR(enc_list.description, 80)
    	ELSE
      	oApp.msg2user("INFORM", "Encounter Type is non-existent")
      	m.col2 = SPACE(80)
   	ENDIF
     Select t_enc
 ******************COL3***********************************
   	m.col3 = SPACE(30)
   	IF SEEK(t_enc.worker_id, "userprof")
      	m.staff = userprof.staff_id
      	IF SEEK(m.staff, "staff")
         	m.col3 = PADR(oApp.Formatname(Staff.last, Staff.first), 30)
      	ENDIF
   	ENDIF
 ******************COL4***********************************
   	m.col4 = space(60)
   	m.col8 = space(12)
   	IF !EMPTY(t_enc.bill_to)
      	IF SEEK((t_enc.serv_cat + t_enc.bill_to), "bill_to")
         	m.col8 = LEFT(ALLTRIM(bill_to.descript), 12)
      	ENDIF
   	EndIF
   	IF !EMPTY(t_enc.program)
      	IF SEEK(t_enc.program, "program")
         	m.col4 = PADR(program.descript,60)
      	ENDIF
   	EndIF
   ******************COL5, col8***********************************
   	m.col6 = space(10)
   	m.col7 = SPACE(130)
	   m.col9 = SPACE(30)

   	INSERT INTO temp3 FROM MEMVAR

   	m.cat_row = m.cat_row +1
   	m.col1 = PADR("Date", 10)
   	m.col2 = PADR("Encounter Type", 80)
   	m.col3 = PADR("Worker", 30)
   	m.col4 = PADR("Program", 60)
   	m.col5 = PADR("Time", 10)
   	m.col6 = SPACE(10)
   	m.col7 = SPACE(130)
   	m.col8 = PADR("Bill To ",12)
   	m.col9 = SPACE(30)
   	m.iswhat = "35"
   	m.id   = DTOS(t_enc.act_dt) + t_enc.act_id
   	m.enc  = "A"
   	m.serv_cat = t_enc.serv_cat
   	INSERT INTO temp3 FROM MEMVAR

   	IF SEEK( RIGHT(m.id, 10), "Ai_colen")
      	m.cat_row = m.cat_row +1
      	m.col1 = SPACE(10)
      	m.col2 = PADR("Collaterals Involved", 80)
      	m.col3 = SPACE(30)
      	m.col4 = SPACE(60)
      	m.col5 = SPACE(10)
      	m.col6 = SPACE(10)
      	m.col7 = SPACE(130)
      	m.col8 = space(12)
      	m.col9 = SPACE(30)
      	m.iswhat = "35"
      	m.id   = DTOS(t_enc.act_dt) + t_enc.act_id
      	m.enc  = "D"
      	INSERT INTO temp3 FROM MEMVAR
   	ENDIF

   	IF SEEK(RIGHT(m.id,10), "Ai_serv")
      	m.cat_row = m.cat_row +1
      	m.col1 = SPACE(10)
      	m.col2 = PADR("Services Provided", 80)
      	m.col3 = PADR( "How Provided", 30)
      	m.col4 = PADR("Worker", 30)
      	m.col8 = PADR("Total Hrs", 12)
      	m.col5 = SPACE(10)
      	m.col6 = SPACE(10)
      	m.col7 = SPACE(130)
      	m.col9 = space(30)
      	m.iswhat = "35"
      	m.id    = DTOS(t_enc.act_dt) + t_enc.act_id
      	m.enc   = "G"
      	INSERT INTO temp3 FROM MEMVAR

   	ENDIF
 	ENDSCAN
   Use in t_enc

 *-- AF Added temp3 and DIST
 	SELECT DIST SPACE(10)                   as  col1,   ;
   	    PADR(oApp.Formatname(cli_cur.last_name,             ;
      	      cli_cur.first_name), 80) as  col2,   ;
       	SPACE(30)                   as  col3,   ;
       	space(60)                   as  col4,   ;
       	space(10)                    as  col5,   ;
       	space(10)                   as  col6,   ;
       	PADR(oApp.Formatname(cli_cur.last_name,             ;
         	   cli_cur.first_name), 130)                  as  col7,   ;
       	space(12)                    as  col8,   ;
       	space(30)                   as  col9,   ;
       	"35"                        as  iswhat , ;
       	temp3.id as  id   , ;
       	"F"                         as  enc  ,;
       	Ai_enc.serv_cat  		   as  serv_cat , ;
       	temp3.cat_row AS cat_row ;
 	FROM  Ai_enc,  Ai_colen,  cli_cur , temp3     ;
 	WHERE Ai_enc.tc_id   = gcTc_Id ;
     and temp3.id = DTOS(ai_enc.act_dt) + Ai_enc.act_id AND temp3.enc = "D";
     and !EMPTY(Ai_enc.act_dt);
     AND Ai_enc.act_id = Ai_colen.act_id    ;
     AND Ai_colen.client_id = cli_cur.client_id;
     AND !EMPTY(Ai_colen.client_id);
      &cDateExpr ;
 	 INTO CURSOR temp4
     
*AND BETWEEN(ai_enc.act_dt, Enc_Date, Enc_ToDt) ;

	=openfile("staff", "staff_id")
	=openfile("userprof", "worker_id")
	=openfile("how_prov", "progcode")
	=openfile("ai_enc", "act_id")
	SET FILTER TO !EMPTY(AI_enc.act_dt)

	=openfile("ai_serv", "tc_id")
	SET RELATION TO act_id INTO ai_enc
	GO TOP
	memw = SET("MEMOWIDTH")
	SET MEMOWIDTH TO 125

* Notes:****
	SELECT ai_enc
 * jss, 5/15/2000, only grab primary care stuff (serv_cat='00002')
	SCAN FOR (ai_enc.tc_id = gcTc_Id  AND !EMPTY(AI_enc.act_dt) AND ai_enc.serv_cat='00002' ;
              &cDateExpr)
 *****************COL1, COL6, iswhat,serv_cat***********************************

   	m.cat_row = cat_row +1
      m.col1 = SPACE(10)
      m.iswhat = "35"
	   m.id     = DTOS(ai_enc.act_dt) + Ai_enc.act_id
   	m.enc    = "C"
      m.serv_cat = Ai_enc.serv_cat
      m.service = ai_serv.service
	   m.enc_id = ai_enc.enc_id
   	m.col1 = space(10)
      m.col2 = space(80)
      m.col3 = space(30)
	   m.col4 = space(60)
   	m.col5 = space(10)
      m.col6 = SPACE(10)
      m.col7 = space(130)
	   m.col8 = space(12)
   	m.col9 = space(30)
      IF !EMPTY(Ai_enc.enc_note)
      	m.col7 = PADR("Progress Note:",130)
         INSERT INTO temp3 FROM MEMVAR
	      mml = MEMLINES(Ai_enc.enc_note)

   	   FOR i=1 to mml
      		m.col7 = "<    " + MLINE(Ai_enc.enc_note, i)
            m.col1 = STR(i,10)
            INSERT INTO temp3 FROM MEMVAR
         ENDFOR
      ENDIF
   ENDSCAN

* Remarks*************
   =openfile("serv_list")
	SELECT ai_serv
 * jss, 5/15/2000, only grab primary care stuff (serv_cat='00002')
   SCAN FOR (ai_serv.tc_id = gcTc_Id  AND !EMPTY(AI_enc.act_dt) AND ai_enc.serv_cat='00002' ;
              &cDateExpr)
 *****************COL1, COL6, iswhat,serv_cat***********************************

   	m.cat_row = cat_row +1
      m.col1 = SPACE(10)
      m.iswhat = "35"
      m.id     = DTOS(ai_enc.act_dt) + Ai_enc.act_id
      m.enc    = "I"
      m.serv_cat = Ai_enc.serv_cat
    ******************COL2***********************************
      m.service = ai_serv.service
      m.serv_cat = ai_enc.serv_cat
      m.enc_id = ai_enc.enc_id
      m.col2 = space(80)
      Select serv_list
      LOCATE FOR serv_list.service_id =ai_serv.service_id
      IF FOUND()
         m.col2 = PADR(serv_list.description, 80)
      ENDIF
 ******************COL3***********************************
      m.col3 = space(30)
      IF !EMPTY(ai_serv.how_prov)
         IF SEEK((m.serv_cat + ai_serv.how_prov), "how_prov")
         	m.col3 = PADR(How_prov.descript, 30)
         ENDIF
      ENDIF
 ******************COL4***********************************
      m.col4 = space(60)
      IF !EMPTY(ai_serv.worker_id)
         IF SEEK(ai_serv.worker_id, "userprof")
            m.staff = userprof.staff_id
            IF SEEK(m.staff, "staff")
               m.col4 = PADR(oApp.Formatname(Staff.last, Staff.first), 60)
            ENDIF
         ENDIF
      ENDIF
**********************COL5*****************************************
      IF (!EMPTY(Ai_serv.s_beg_tm) AND !EMPTY( Ai_serv.s_end_tm))
         m.col8 = FormHours(TimeSpent(Ai_serv.s_beg_tm, ;
                  Ai_serv.s_beg_am, Ai_serv.s_end_tm, ;
                  Ai_serv.s_end_am))
      ELSE
         m.col8 = space(12)
      ENDIF
      m.col5 = SPACE(10)
 ******************col4, col8, col9***********************************
      m.col1 = space(10)
      m.col6 = SPACE(10)
      m.col9 = space(30)
      m.col7 = space(130)
      INSERT INTO temp3 FROM MEMVAR
      IF !EMPTY(Ai_serv.servnote)
         m.col7 = PADR("Remarks:",130)
         INSERT INTO temp3 FROM MEMVAR
         mml = MEMLINES(Ai_serv.servnote)
         m.col6 = SPACE(10)
         FOR i=1 to mml
              m.col7 = "\\   " + MLINE(Ai_serv.servnote, i)
              m.col6 = IIF(i = 1, "Remarks:", SPACE(10))
              m.col1 = STR(i,10)
         	  INSERT INTO temp3 FROM MEMVAR
         ENDFOR
      ENDIF
   ENDSCAN
 	SET MEMOWIDTH TO (memw)
ENDIF && lserv

*******************************
m.cat_row = 0
* DIAGNOSIS*
* jss, 6/26/03, add line "AND ai_diag.diag_code = diagnos.code" to prevent duplication as in AIDS and Pediatric AIDS dx's
IF ldiag
 	SELECT ;
		ai_diag.icd9code, ai_diag.hiv_icd9, ai_diag.diagnosed, ;
		ai_diag.diagdate, ai_diag.st, ;
		diagnos.descript, LEFT(county.descript,15) AS county ;
 	FROM ;
		ai_diag, diagnos, county ;
 	WHERE ;
		ai_diag.icd9code = diagnos.icd9code ;
	  AND ai_diag.hiv_icd9 = diagnos.hiv_icd9 ;
      AND ai_diag.diag_code = diagnos.code ;
	  AND ai_diag.tc_id = gcTc_Id  ;
	  AND !EMPTY(ai_diag.cnty_resid) ;
	  AND IIF(ai_diag.cnty_resid<>'999', ai_diag.cnty_resid = county.code ;
	  AND ai_diag.st = county.state,  ai_diag.cnty_resid = county.code);
 	UNION ;
 	SELECT ;
		ai_diag.icd9code, ai_diag.hiv_icd9, ai_diag.diagnosed, ;
		ai_diag.diagdate, ai_diag.st, ;
		diagnos.descript, space(15) AS county ;
 	FROM ;
		ai_diag, diagnos ;
 	WHERE ;
		ai_diag.icd9code = diagnos.icd9code ;
	  AND ai_diag.hiv_icd9 = diagnos.hiv_icd9 ;
	  AND ai_diag.diag_code = diagnos.code ;
	  AND ai_diag.tc_id = gcTc_Id  ;
	  AND EMPTY(ai_diag.cnty_resid) ;
 	INTO CURSOR ;
	  diag_tmp ;
 	ORDER BY ;
		4 DESC

 	IF _tally <> 0
  		SELECT temp11
  		APPEND BLANK
  		REPL  col1 WITH "ICD9 Code", ;
      		col2 WITH "Description", ;
       		col3 WITH "HIV ICD9 Code", ;
       		col9 WITH "Diagnosed", ;
       		col4 WITH "State  County",;
       		col8 WITH "Date",;
       		iswhat WITH "11"
            
             m.cat_row = 1
             m.iswhat = "11"
             m.col5 = space(10)
             m.col6 = SPACE(10)
             m.col7 = space(130) 

    	SELECT diag_tmp
     	SCAN
          m.cat_row = cat_row +1
          m.col1 = PADR( diag_tmp.icd9code,10)
          m.col2 = PADR( diag_tmp.descript,80)
          m.col3 = PADR( diag_tmp.hiv_icd9,30)
          m.col9 = PADR( diag_tmp.diagnosed,30)
          m.col8 = PADR(diag_tmp.diagdate,12)
          m.col4 = PADR( PADR(diag_tmp.st,8)+ ALLTRIM(diag_tmp.county), 60)
          INSERT INTO temp11 FROM MEMVAR
     	ENDSCAN
 	ELSE
   	SELE temp11
   	APPEND BLANK
   	REPLACE col2 WITH "No Diagnosis History " ,iswhat WITH "11"
 	EndIf
    
 Use in diag_tmp
 *Use in ai_diag
 *Use in diagnos
* Use in county     
 
ENDIF && ldiag
********************************************

m.cat_row = 0
* LAB TEST HISTORY***
*** jss, 12/6/00, comment and add new code to keep in line with client profile change of 7/7/00
IF ltest
* 1st part of union gets those tests with blank testcode (no subtest)
* 2nd select gets those tests with testcode filled

**VT 04/06/2011 Dev Tick 7942 add 'Not Medically Indicated'

	SELECT ;
		testres.testtype																AS testtype, ;
		SPACE(43)											 							AS testcode, ;
		IIF(EMPTY(testres.count), SPACE(8), STR(testres.count,8)) 		AS count,    ;
		IIF(EMPTY(testres.percent), SPACE(2), STR(testres.percent,2)) 	AS percent,  ;
		testres.testdate																AS testdate, ;
		testres.resdate																AS resdate,  ;
		testtype.descript																AS descript, ;
		testres.result																	AS testresult, ;
		testres.med_indic ;
	FROM ;
   	testres, ;
   	testtype ; 
 	WHERE ;  
		testres.testtype = testtype.code ;
	AND EMPTY(testres.testcode) 			;
	AND testres.tc_id = gcTc_Id ;
 	UNION ;
	SELECT ;
		testres.testtype																AS testtype,  ;
		testres.testcode + " " + labtest.descript 							AS testcode,  ;
		IIF(EMPTY(testres.count), SPACE(8), STR(testres.count,8)) 		AS count, 	  ;
		IIF(EMPTY(testres.percent), SPACE(2), STR(testres.percent,2)) 	AS percent,   ;
		testres.testdate																AS testdate,  ;
		testres.resdate																AS resdate,   ;
		testtype.descript																AS descript,  ;
		testres.result																	AS testresult, ;
		testres.med_indic ;
 	FROM ;
		testres,  ;
		testtype, ;
		labtest   ;
	WHERE ;
		testres.testtype = testtype.code ;
	AND !EMPTY(testres.testcode) 			;
	AND testres.tc_id = gcTc_Id 			;
	AND testres.testtype + testres.testcode = labtest.testtype + labtest.code ;
	INTO CURSOR ;
		testtmp1 
 
	* fill in test results
 **SPACE(10) 							AS result ;	 
 
	SELECT ;
		testtmp1.* , ;
		iif(testtmp1.med_indic=0,SPACE(10), 'NMI') AS result ;
	FROM ;
		testtmp1 ;
	WHERE ;
		EMPTY(testtmp1.testresult) ;
	UNION ;
	SELECT ;
		testtmp1.* , ;
		LEFT(tstreslu.descript,10)		AS result ; 
	FROM ;
		testtmp1, ;
		tstreslu  ;
	WHERE ;
		!EMPTY(testtmp1.testresult) ;
	AND tstreslu.cvarname = 'TEST' + testtmp1.testtype + testtmp1.testcode ;
	AND tstreslu.code     = testtmp1.testresult ;
 	INTO CURSOR ;
		test_tmp ;
	ORDER BY ;
		5 DESC
      
   Use in testtmp1
   
 	SELECT temp12

 	IF _TALLY<>0
  		APPEND BLANK
  		REPL  col1 WITH "Test Type", ;
      		col2 WITH "Description", ;
        		col3 WITH "Test" ,;
        		col6 WITH "Result", ;
        		col9 WITH "     Date", ;
        		col4 WITH "%"+SPACE(10)+" Count",;
        		col8 WITH "Res. Date",;
        		iswhat WITH "12"
           
        		m.cat_row = 1
        		m.iswhat = "12"
        		m.col5 = space(10)
        		m.col6 = SPACE(10)
        		m.col7 = space(130)
		     
     	SELECT test_tmp
     	SCAN
          m.cat_row = cat_row +1
          m.col1 = PADR( test_tmp.testtype,10)
          m.col2 = PADR( test_tmp.descript,80)
          m.col3 = PADR( PADR(test_tmp.testcode,21),30)
          m.col6 = PADR(test_tmp.result,10)
          m.col9 = PADR(DTOC( test_tmp.testdate),30)
          m.col8 = PADR(DTOC(test_tmp.resdate),12)
          m.col4 = PADR( IIF(!EMPTY(test_tmp.percent)," ","   ")+ ;
                         test_tmp.percent+SPACE(10)+;
                         PADR(ALLTRIM(test_tmp.count),15) , 60)

          INSERT INTO temp12 FROM MEMVAR
     	EndScan
*!*	     		 **VT 04/06/2011 Dev Tick 7942 
*!*			     m.cat_row = cat_row +1
*!*			     m.col1 =space(10)
*!*			     m.col2 = 'Key: NMI - Not Medically Indicated'
*!*			     m.col3 = space(30)
*!*			     m.col6 = space(10)
*!*			     m.col9 = space(30)
*!*			     m.col8 = space(12)
*!*			     m.col4 = space(60)
*!*			     INSERT INTO temp12 FROM MEMVAR
 	ELSE
  		APPEND BLANK
  		REPLACE col2 WITH "No Laboratory Test History " ,iswhat WITH "12", cat_row with 1
	EndIf
   
 Use in test_tmp

ENDIF && ltest
********************************************

 SELECT *    ;
  FROM temp1 ;
 UNION ALL   ;
 SELECT *    ;
  FROM temp11;
 UNION ALL   ;
 SELECT *    ;
  FROM temp12;
 UNION ALL   ;
 SELECT *    ;
  FROM temp3 ;
 UNION ALL   ;
 SELECT *    ;
  FROM temp4 ;
 INTO cursor temp25 ;
  ORDER BY 10 ASC, 13 ASC,12 ASC, 14 ASC, 1 ASC
  
 **ORDER BY 10 ASC, 13 ASC,11 DESC, 12 ASC, 14 ASC, 1 ASC

Use in temp4
Use in temp12
Use in temp11
Use in temp3

Select temp25.*, ;
      oApp.FormatName(m.last_name, m.first_name) as name, ;
      m.case_no as case_no,;
      m.id_no as id_no,;
      m.dob as dob, ;
      m.sexdesc as sexdesc, ;
      m.ssn as ssn, ;
      m.cinn as cinn, ;
      m.placed_dt as placed_dt, ;
      m.aiopen as aiopen, ;
      m.act_dt as act_dt , ;
      m.effect_dt as effect_dt, ;
      m.hivstatus as hivstatus, ;
      m.phone_cont as phone_cont, ;
      m.home_cont as home_cont, ;
      m.mail_cont as mail_cont, ;
      m.discrete as discrete, ;
      m.street1 as street1 , ;
      m.street2 as street2, ;
      m.city as city, ;
      m.st as st, ;
      m.zip as zip, ;
      m.phwork as phwork, ;
      m.phhome as phhome, ;
      m.cdcdate as cdcdate, ;
      m.cdc as cdc, ;
      m.tbdate as tbdate, ;
      m.tbstat as tbstat, ;
      m.hisp_des as hisp_des, ;
      m.ethnicdet as ethnicdet, ;
      m.ins_des as ins_des, ;
      m.race_des as race_des, ;
      m.serpmemo as serpmemo, ;
      m.coll_inv as coll_inv, ;
      m.topic_ul as topic_ul, ;
      GetHeader(iswhat) as header_descr,;
      Space(40) as serv_desc, ;
      cDate as cDate, ;
      cTime as cTime ;
from temp25; 
into cursor temp35;
ORDER BY 10 ASC, 13 ASC,11 DESC, 12 ASC, 14 ASC, 1 ASC

**ORDER BY 10 ASC, 13 ASC, 12 ASC, 14 ASC, 1 ASC

**

If Used('temp')
   Use in temp
EndIf
   
SELECT serv_cat
SET ORDER TO code
oApp.ReOpenCur("temp35", "temp")
SET RELATION TO serv_cat INTO serv_cat
GO TOP
REPLACE ALL serv_desc WITH serv_cat.descript
Set Relation to
oApp.Msg2User("OFF")

Select Temp
GO TOP

IF EOF()
*!*   Use in temp
*!*   USE (dbf('temp1')) alias temp00 again
*!*    APPEND BLANK
*!*    REPLACE iswhat WITH "00", col1 WITH DTOC(m.effect_dt), ;
*!*              col2 WITH "HIV:  " +m.hivstatus , ;
*!*              col3 WITH " CDC Defined AIDS:  " +IIF(m.cdc = "Yes", DTOC(m.cdcdate), m.cdc)
*!*    APPEND BLANK
*!*    REPLACE iswhat WITH "00", col1 WITH DTOC(tbdate), ;
*!*              col2 WITH " TB:   " + tbstat, ;
*!*              cat_row WITH 1
 
 m.name =  oApp.FormatName(m.last_name, m.first_name)
 m.header_descr = ' '
 m.iswhat = '1'
** m.enc='A'
 m.col2 = 'No Information Found'
 m.cat_row = 1
 m.cDate = DATE()
 m.cTime = TIME()
 Append Blank
 Gather Memvar

         *!*     Select temp00.*, ;
         *!*         oApp.FormatName(m.last_name, m.first_name) as name, ;
         *!*         m.case_no as case_no,;
         *!*         m.id_no as id_no,;
         *!*         m.dob as dob, ;
         *!*         m.sexdesc as sexdesc, ;
         *!*         m.ssn as ssn, ;
         *!*         m.cinn as cinn, ;
         *!*         m.placed_dt as placed_dt, ;
         *!*         m.aiopen as aiopen, ;
         *!*         m.act_dt as act_dt , ;
         *!*         m.effect_dt as effect_dt, ;
         *!*         m.hivstatus as hivstatus, ;
         *!*         m.phone_cont as phone_cont, ;
         *!*         m.home_cont as home_cont, ;
         *!*         m.mail_cont as mail_cont, ;
         *!*         m.discrete as discrete, ;
         *!*         m.street1 as street1 , ;
         *!*         m.street2 as street2, ;
         *!*         m.city as city, ;
         *!*         m.st as st, ;
         *!*         m.zip as zip, ;
         *!*         m.phwork as phwork, ;
         *!*         m.phhome as phhome, ;
         *!*         m.cdcdate as cdcdate, ;
         *!*         m.cdc as cdc, ;
         *!*         m.tbdate as tbdate, ;
         *!*         m.tbstat as tbstat, ;
         *!*         m.hisp_des as hisp_des, ;
         *!*         m.ethnicdet as ethnicdet, ;
         *!*         m.ins_des as ins_des, ;
         *!*         m.race_des as race_des, ;
         *!*         m.serpmemo as serpmemo, ;
         *!*         m.coll_inv as coll_inv, ;
         *!*         m.topic_ul as topic_ul, ;
         *!*         GetHeader(iswhat) as header_descr,;
         *!*         Space(40) as serv_desc, ;  
         *!*         cDate as cDate, ;
         *!*         cTime as cTime ;
         *!*    from temp00  ;  
         *!*    into cursor temp      
         *!*    
         *!*    Use in temp00
 
ENDIF
Select temp
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
          gcRptName = 'rpt_pat_flow' 
           DO CASE
              CASE lPrev = .f.
                  Report Form rpt_pat_flow To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.    
                    oApp.rpt_print(5, .t., 1, 'rpt_pat_flow', 1, 2)
           ENDCASE
EndIf
Select ai_enc
Set Filter To
set cent on
**************************************************************
FUNCTION SHowTime
PARAMETER ctime
IF EMPTY(ctime)
	RETURN ''
ELSE
	RETURN (SUBSTR(ctime, 1, 2) + ":" + SUBSTR(ctime, 3, 2) + " ")
ENDIF

**************************************************************
FUNCTION GetHeader
Parameters iswhat 

DO CASE
   CASE iswhat = "10"
        RETURN("Medication History                                                                                                              ")
   CASE iswhat = "11"
        RETURN("Diagnosis History                                                                                                               ")
   CASE iswhat = "12"
        RETURN("Laboratory Test History                                                                       Key: NMI - Not Medically Indicated")
   CASE iswhat = "35"
        RETURN("Encounters and Services Section                                                                                                 ")
   OTHERWISE
        RETURN(SPACE(10))
ENDCASE
**************************************************************
FUNCTION GetServCat
IF SEEK(temp.serv_cat,"serv_cat")
	RETURN(serv_cat.descript)
ELSE
	RETURN("")
ENDIF
*************************************************************
***********************************************************************
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
m.CDCAge=IIF(!EMPTY(m.CDCDob), oApp.Age(DATE(),m.CDCDob), 0)
   
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

   IF _TALLY <> 0
      lResult = .T.
      dCDCDate = aCDC_AIDS[1, 2]
   ENDIF
ENDIF

RETURN lResult
*-EOF CDC_AIDS

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

IF _TALLY > 0      
   lHIV_Pos = aHivPos(1)
ELSE
   lHIV_Pos = .f.
ENDIF      

*Use in hstat
*Use in hivstat

RETURN lHIV_Pos

*-EOF HIV_Pos
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
