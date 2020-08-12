Parameters    lPrev, ;              && Preview     
              lIns,  ;
              lPreg, ;   
              lDiag, ;
              lTest, ;
              lMed, ;
              lProbl, ;
              lPlace, ;
              lFam, ;
              lProg, ;
              lGroup, ;
              lRef, ;
              lServ, ;
              Enc_Date, ;  
              Enc_ToDt
              
PRIVATE gchelp
gchelp = "Client Profile Window"
cDate = DATE()
cTime = TIME()
PRIVATE mfor, mseek
m.aiopen = ""
=OPENFILE("AI_clien", "TC_ID")
IF SEEK(gcTc_Id, "Ai_clien")
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
   oApp.msg2user("NOTFOUNDG")
   RETURN
ENDIF

m.sexdesc = ""
=OPENFILE("gender", "code")

Select cli_cur
cOrd = Order()
Set Order to client_id

IF SEEK(m.client_id , "cli_cur")
   SCATTER FIELDS last_name, first_name,ssn,cinn, sex, gender, dob,;
   	phhome ,phwork,birth_lbs,birth_oz, hispanic, white, blafrican, asian, ;
   	hawaisland, indialaska, unknowrep, ethnic, insurance, someother  MEMVAR
   IF SEEK(m.gender , "gender")
      m.sexdesc = gender.descript
   ENDIF
ELSE
    oApp.msg2user("NOTFOUNDG")
    RETURN
EndIf

*Use in gender

SELECT ;
	relhist.*, ;
	rw_risk.descript  AS rwrisk, ;
	cdc_risk.descript AS cdcrisk ;
FROM ;
	relhist, rw_risk, cdc_risk ;
WHERE ;
	relhist.tc_id    = gcTc_Id ;
AND relhist.rw_code  = rw_risk.code ;	
AND relhist.cdc_code = cdc_risk.code ;	
INTO CURSOR ;
	getrisk ;	
ORDER BY date DESC

m.rwrisk=' '
m.cdcrisk=' '

IF _tally <> 0
	GO TOP
	m.rwrisk=getrisk.rwrisk
	m.cdcrisk=getrisk.cdcrisk	
EndIf

*USE IN relhist
USE IN getrisk
*Use in cdc_risk
*Use in rw_risk


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
m.race_des = m.race_des + Iif(!Empty(race_des), Iif(unknowrep = 1, ', Unknown/unreported', ''), Iif(unknowrep = 1, 'Unknown/unreported', ''))
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
**=OPENFILE("Cli_hous", "Client_id")
**SET FILTER TO lives_in
**SET RELATION TO hshld_id INTO ADDRESS

***IF SEEK(m.client_id, "cli_hous")
IF SEEK(m.client_id, "address")
   Select address
   SCATTER FIELDS street1, street2, city, st, zip MEMVAR
   If oApp.gldataencrypted  
      m.street1 = osecurity.decipher(Alltrim(address.street1))
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

Select address
**set rela to
*Use in address
*Use in cli_hous

=OPENFILE("Ethnic", "Code")
If Seek(m.ethnic, "Ethnic")
	m.ethnicdet = ethnic.descript
Else	
	m.ethnicdet = ''
EndIf

*Use in ethnic 	

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
   m.effect_dt = ""
   m.hivstatus = ""
ENDIF

Select hstat
Set Relation to

*Use in hstat
*Use in hivstat

m.cdcdate = {} 
m.cdc = IIF(CDC_AIDS(gctc_id, m.cdcdate), "Yes", "No")

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
 m.coll_inv = REPL("_", 15)
 m.serpmemo = SPACE(2) + REPL("_", 21)+ SPACE(16) + REPL("_", 20)+ SPACE(10) + REPL("_", 20);
             + SPACE(6) + REPL("_", 8)
* jss, 3/4/03, next line is for report underline of "Topics" header
 m.topic_ul = SPACE(15) + REPL("_", 20)            
* lall, lins, lprog, lfam, lmed, ldiag, ltest, lref, lserv

*Use in tbstatus
If Used('temp')
   Use in temp
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
 CREATE CURSOR temp01 FROM ARRAY aCliRef    && INSURANCE
 CREATE CURSOR temp2 FROM ARRAY aCliRef     && REFERRALS
 CREATE CURSOR temp3 FROM ARRAY aCliRef     && SERVICE CATEGORY
 CREATE CURSOR temp4 FROM ARRAY aCliRef     && collaterals
 CREATE CURSOR temp08 FROM ARRAY aCliRef 	&& PROGRAM
 CREATE CURSOR temp09 FROM ARRAY aCliRef    && FAMILY
 CREATE CURSOR temp11 FROM ARRAY aCliRef    && DIAGNOSIS
 CREATE CURSOR temp12 FROM ARRAY aCliRef    && LAB TEST
 CREATE CURSOR temp13 FROM ARRAY aCliRef    && PREGNANCY HISTORY
 CREATE CURSOR temp14 FROM ARRAY aCliRef    && PLACEMENT HISTORY
 CREATE CURSOR temp16 FROM ARRAY aCliRef    && GROUP ENROLLMENT

=openfile("serv_cat","code")
=openfile("program","prog_id")
=OPENFILE("AI_PROG"  ,"TC_ID2 DESC")
*********************************************************************************************************
m.cat_row = 0

* FAMILY **********************
IF lfam
* jss, 5/6/03, should be grabbing client info from client table, not cli_cur, as cli_cur does NOT include collaterals
 SELECT SPACE(10)                   as  col1,   ;
       PADR(oApp.FormatName(Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(client.last_name)), client.last_name),            ;
            Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(client.first_name)), client.first_name), client.mi), 80) as  col2,  ;
       PADR(IIF(Ai_famil.type=1,"Personal Contact " , ;
               IIF(Ai_famil.type=2,"Emergency Contact " ,"Other ")) ,30) as  col3,  ;
       PADR(relat.descript, 60)  as  col4,  ;
       space(10) as  col5,  ;
       space(10) as  col6,  ;
       space(130)  as  col7,  ;
       IIF((EMPTY(client.birth_lbs) AND EMPTY(client.birth_oz)) OR (VAL(client.birth_lbs)=0 and VAL(client.birth_oz)=0),SPACE(12),client.birth_lbs + ' lb  ' + client.birth_oz + ' oz')  as  col8,  ;
       PADR(DTOC(client.dob),30) as  col9,  ;
       "09"  as iswhat, ;
       space(18) as id   , ;
       space(1) as enc  ,;
       SPACE(5) as serv_cat, ;
        100000 AS cat_row  ;
 FROM  Ai_famil,  relat,  client            ;
 INTO  cursor fam                 ;
 WHERE Ai_famil.tc_id   = gcTc_Id            ;
   AND client.client_id	= ai_famil.client_id ;
   AND Ai_famil.relation   = relat.code ;
 ORDER BY 2
 
  
**jss, 5/6/03 **AND Ai_famil.client_id = cli_cur.client_id

 SELECT temp09
 IF _TALLY # 0
  USE
  select 0
  use (dbf('fam')) alias temp09 again exclusive
  sele temp09
  REPLACE ALL cat_row WITH RECNO()
  APPEND BLANK
* jss, 2/2000, add columns DOB, Birthweight  
  REPL col2 WITH "Name", col3 WITH "Type", col4 WITH "Relation", col9 WITH "DOB", col8 WITH "BirthWeight", iswhat WITH "09"
 ELSE
  APPEND BLANK
  REPLACE col2 WITH "No Family Information " , iswhat WITH "09"
 ENDIF

   *Use in Ai_famil
   *Use in relat
  Use in fam
   
ENDIF  && lfam
*****************

* MEDICATION*************************
IF lmed
* jss, 6/11/01, add col5, discontinue date
   SELECT DTOC(PRES_DATE)     AS col1, ;
          b.brd_desc        AS col2, ;
          LEFT(b.strength,20)        AS col4 , ;
          admin AS  col3 , ;
          DTOC(DIS_DATE)      AS col5, ;
          LEFT(b.route,8)       AS col9, ;
          dur  AS col8 ,         ;
          1 AS cat_row , ;
        PRESH_ID , PRES_DATE      ;
   FROM PRES_HIS , MEDICAT B     ;
   WHERE CLIENT_ID = m.Client_Id ;
   AND   DRUG = B.ndc_CODE				;
   INTO CURSOR Med               ;
   ORDER by 9 desc


  SELECT temp1
 IF _TALLY <> 0
     APPEND BLANK
     REPL  col1 WITH "Start Date", col2 WITH "Name", ;
         col4 WITH "Dosage", col3 WITH "Administration", ;
         col5 WITH "Stop Date", ;
         col9 WITH "Route" , ;
         col8 WITH "Duration"
     APPEND FROM (dbf('med'))
     REPLACE ALL cat_row WITH RECNO()
 ELSE
     APPEND BLANK
     REPLACE col2 WITH "No Medication History "
 EndIf
 
 REPLACE ALL iswhat WITH "10"
 
* Use in med
* Use in PRES_HIS
* Use in MEDICAT
 
ENDIF && lmed
****************

* Insurance data
IF lins
 SELECT ;
	insstat.*, ;
	med_prov.name as prov_name, ;
	instype.descript as instype ;
 FROM ;
	ai_clien, insstat, med_prov, instype ;
 WHERE ;
	ai_clien.tc_id = gcTc_Id AND ;
	ai_clien.client_id = insstat.client_id AND ;
	insstat.prov_id = med_prov.prov_id AND ;
	med_prov.instype = instype.code ;
 ORDER BY ;
	prim_sec, insstat.effect_dt desc ;
 INTO CURSOR ;
	ins_temp

 IF _TALLY # 0
  SELECT temp01
  APPEND BLANK
  REPL  col1 WITH "Insurance", ;
       col2 WITH "Insurance Type", ;
       col3 WITH "Insurer Name", ;
       col4 WITH "Policy Number", ;
       col8 WITH "Exp Date", ;
       col9 WITH "Effect Date", ;
       iswhat WITH "01"

       m.col5 = SPACE(10)
       m.col6 = SPACE(10)
       m.col7 = SPACE(130)
       m.id   = SPACE(18)
       m.enc  = SPACE(1)
       m.serv_cat = SPACE(5)
       m.iswhat = "01"
 SELECT ins_temp
 SCAN
	DO CASE
		CASE prim_sec = 1
			cInsType = 'Primary'
		CASE prim_sec = 2
			cInsType = 'Secondary'
		CASE prim_sec = 3
			cInsType = 'Tertiary'
		CASE prim_sec = 4
			cInsType = 'Funded/Other'
   Otherwise
         cInsType = 'None'
	ENDCASE
    m.col1 = PADR(cInsType, 10)
    m.col2 =  PADR(instype, 80)
    m.col3 =  PADR(prov_name, 30)
    m.col4 =  PADR(Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(pol_num)), pol_num), 60)
    m.col8 =  PADR(DTOC(exp_dt) , 12)
    m.col9 =  PADR(DTOC(effect_dt), 30)
    m.cat_row =RECNO()
    INSERT INTO temp01 FROM MEMVAR
  ENDSCAN
 ELSE
  SELE temp01
  APPEND BLANK
  REPLACE col2 with "No Insurance Information", iswhat WITH"01"
 EndIf
 
 Use in ins_temp
* Use in insstat
 *Use in med_prov
 *Use in instype 
ENDIF  && lins
********

* Program Information*
* jss, 9/12/2000, remove code looking at program start and end dates in order to get total history
IF lprog
**VT 08/25/2010 Dev Tick 5791 
*!*	SELECT DISTINCT ;
*!*			ai_prog.program,ai_prog.start_dt,ai_prog.end_dt,program.descript, ;
*!*			oApp.FormatName(staff.last,staff.first, '') as worker ;
*!*	 FROM ;
*!*		ai_prog,program,ai_work,staff,userprof ;
*!*	 WHERE ;
*!*		ai_prog.tc_id = gcTc_Id AND ;
*!*		ai_prog.program = program.prog_id AND;
*!*		ai_prog.program = ai_work.program AND ;
*!*		ai_work.tc_id = gcTc_Id AND ;
*!*		ai_work.worker_id = userprof.worker_id AND ;
*!*		userprof.staff_id = staff.staff_id AND ;
*!*		DTOS(ai_work.effect_dt)+ai_work.am_pm+ai_work.time = ;
*!*			    (SELECT MAX(DTOS(t1.effect_dt)+t1.am_pm+t1.time);
*!*			       FROM ai_work t1,ai_prog t2;
*!*			       WHERE t1.tc_id = gcTc_Id AND;
*!*			        t1.program = t2.program and;
*!*			        ai_work.program = t1.program );
*!*	 ORDER BY ;
*!*		2 DESC ;
*!*	 INTO CURSOR ;
*!*		tcli_prog

SELECT DISTINCT ;
		ai_prog.program,ai_prog.start_dt,ai_prog.end_dt,program.descript, ;
		oApp.FormatName(staff.last,staff.first, staff.mi) as worker ;
FROM ;
	ai_prog,program,ai_work,staff,userprof ;
 WHERE ;
 	ai_prog.ps_id = ai_work.ps_id and;
 	ai_prog.program = ai_work.program AND ;
 	ai_prog.tc_id = ai_work.tc_id AND ;
	ai_prog.tc_id =gcTc_Id AND ;
	ai_prog.program = program.prog_id AND;
	ai_work.worker_id = userprof.worker_id AND ;
	userprof.staff_id = staff.staff_id AND ;
	DTOS(ai_work.effect_dt)+ai_work.am_pm+ai_work.time = ;
		    (SELECT MAX(DTOS(t1.effect_dt)+t1.am_pm+t1.time);
		       FROM ai_work t1;
		       WHERE t1.tc_id = gcTc_Id AND;
		         ai_work.ps_id = t1.ps_id );
 ORDER BY ;
	2 DESC ;
 INTO CURSOR ;
	tcli_prog
	

	
* jss, 10/4/2000, add UNION to handle those program enrollments w/o an assigned worker
*!*   If Used('Cli_prog')
*!*      Use in Cli_prog
*!*   EndIf

*!*   If Used("ai_work")   
*!*      Use in ("ai_work")       
*!*   Endif 
   
 NameLength = LEN(tcli_prog.worker)	

 SELECT * FROM tcli_prog ;
 UNION ;
 SELECT DISTINCT ;			        
		ai_prog.program,ai_prog.start_dt,ai_prog.end_dt,program.descript, ;
		SPACE(NameLength) as worker ;
 FROM ai_prog, program ;	
 WHERE ;
	ai_prog.tc_id = gcTc_Id AND ;
	ai_prog.program = program.prog_id AND;
 	ai_prog.program NOT IN (SELECT program FROM tcli_prog) ;
 ORDER BY ;
	2 DESC ;
 INTO CURSOR ;
	cli_prog


 IF _TALLY # 0
  SELECT temp08
  APPEND BLANK
  REPL  col2 WITH "Programs Enrolled in", ;
        col3 WITH "Staff Assigned", ;
        col4 WITH "Start Date", ;
        col9 WITH "End Date" , ;
        iswhat WITH "22"
  SELECT cli_prog
  GO TOP
    m.col1 = SPACE(10)
    m.col5 = SPACE(10)
    m.col6 = SPACE(10)
    m.col7 = SPACE(130)
    m.col8 = SPACE(12)
    m.iswhat = "22"
    m.id   = SPACE(18)
    m.enc  = SPACE(1)
    m.serv_cat = SPACE(5)

  SCAN
      m.col2 = PADR(cli_prog.descript ,80)
      m.col4 = PADR(DTOC(cli_prog.start_dt),60)
      m.col3 = PADR(cli_prog.worker,30)
      m.col9 = PADR(DTOC(cli_prog.end_dt),30)
      m.cat_row = RECNO()
    INSERT INTO temp08 FROM MEMVAR
  ENDSCAN
 ELSE
  SELE temp08
  APPEND BLANK
  REPLACE col2 with "No Program Information", iswhat WITH "22"
 EndIf
 
 Use in tcli_prog
 
ENDIF  && lprog

If Used("ai_prog")   
   Use in ("ai_prog")      
Endif 
********
*Referral Information
IF lref
 SELECT Ai_ref.ref_dt         as  col1,  ;
       PADR(ref_cat.descript, 80)   as  col2,  ;
       Ai_ref.ref_to               as  col3,  ;
       Ai_ref.status               as  col4,  ;
       1 as cat_row,;
       dtoc(Ai_ref.verif_dt)             as  col5 ;
 FROM  Ai_ref, Ref_cat ;
 WHERE Ai_ref.tc_id  = gcTc_Id;
       AND Ai_ref.ref_cat = ref_cat.code ;
 INTO CURSOR NEW ;
 ORDER BY 1 desc

 =openfile("ref_srce", "code")
 =openfile("ref_stat", "code")

 sele temp2
  APPEND BLANK
  REPL  col1 WITH "Ref.Date", col2 WITH "Category", ;
      col3 WITH "Referred To", col4 WITH "Status", ;
      col5 WITH "Verified", iswhat WITH"20"
 sele new
 go top
 m.cat_row = 0
 IF !EOF()
  SCAN
    m.cat_row = m.cat_row +1
    m.col1 = DTOC(new.col1)
    m.col2 = new.col2
    m.col3 = SPACE(30)
    IF !EMPTY(new.col3)
       IF SEEK(new.col3, "ref_srce")
          m.col3 = ref_srce.name
       ENDIF
    ENDIF
    m.col4 = SPACE(60)
    IF !EMPTY(new.col4)
       IF SEEK(new.col4, "ref_stat")
          m.col4 = ref_stat.descript
       ENDIF
    ENDIF
    m.col5 = new.col5
    m.col6 = SPACE(10)
    m.col7 = SPACE(130)
    m.col8 = space(12)
    m.col9 = SPACE(30)
    m.iswhat = "20"
    m.id   = SPACE(18)
    m.enc  = SPACE(1)
    m.serv_cat = SPACE(5)
    INSERT INTO temp2 FROM MEMVAR
  ENDSCAN
 ELSE
  SELE temp2
  APPEND BLANK
  REPLACE col2 with "No Referrals Information", iswhat WITH"20"
 EndIf
 
 Use in NEW 
 
ENDIF && lref
************************
* SERVICE CATEGORY*******
IF lserv

* note: here are the values of m.enc and types of lines to be added to temp3 cursor:
*		m.enc				type of line
*		-----				------------
*     "A"   			encounter header
*		"C"				encounter detail
*		"D"				collateral header
*     "F"				collateral detail
* 		"G"				service header
*		"I"				service detail
*		"I" 				topic header
*		"I"				topic detail

 =openfile("staff", "staff_id")
 =openfile("userprof", "worker_id")
 =openfile("bill_to", "progcode")
* =openfile("Enc_type", "Procacod")
 =openfile("Enc_list")
 =openfile("ai_serv", "act_id")
 =openfile("ai_colen", "act_id")

* jss, 03/03/03, open new tables "ai_topic,""topics" so we can get topics associated with service
 =openfile("topics","catcode")
 =openfile("ai_topic") && Note: for group-level interventions (gli's, serv_cat = '00013'), index is "att_id", 
                       && Note: for individual-level interventions (ili's, serv_cat = '00014'), index is "serv_id"
 SET RELATION TO serv_cat + code INTO topics
 GO TOP
 
 Select ai_enc  
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
 ENDCASE
 
 SCAN FOR ai_enc.tc_id = gcTc_Id &cDateExpr
 
* encounter detail
 ******************COL1, COL6, iswhat, id, enc,serv_cat***********************************
   m.cat_row = m.cat_row +1
   m.col1   = dtoc(ai_enc.act_dt)
   m.col5   = PADR(SHowTime(Ai_enc.beg_tm) + Ai_enc.beg_am, 10)
   m.iswhat = "35"
   m.id     = DTOS(ai_enc.act_dt) + ai_enc.act_id
   m.enc    = "C"
   m.serv_cat = ai_enc.serv_cat
   ******************COL2***********************************
   **2/272006 VT changed enc_type -> enc_list
   **   IF SEEK((Ai_enc.serv_cat + Ai_enc.category + Ai_enc.enc_type), "Enc_type")

     Select enc_list
     Locate for Ai_enc.enc_id = enc_list.enc_id 
   If Found()
    **  m.col2 = PADR(enc_type.descript, 80)
      m.col2 = PADR(enc_list.description, 80)
   Else
      oApp.msg2user("INFORM", "Encounter Type is non-existent")
      m.col2 = SPACE(80)
   EndIf
   
  Select ai_enc
   
 ******************COL3***********************************
   m.col3 = SPACE(30)
   IF SEEK(ai_enc.worker_id, "userprof")
      m.staff = userprof.staff_id
      IF SEEK(m.staff, "staff")
         m.col3 = PADR(oApp.FormatName(Staff.last, Staff.first, staff.mi), 30)
      ENDIF
   ENDIF
 ******************COL4***********************************
   m.col4 = space(60)
   m.col8 = space(12)
   IF !EMPTY(ai_enc.bill_to)
      IF SEEK((ai_enc.serv_cat + ai_enc.bill_to), "bill_to")
         m.col8 = LEFT(ALLTRIM(bill_to.descript), 12)
      ENDIF
   EndIF
   IF !EMPTY(ai_enc.program)
      IF SEEK(ai_enc.program, "program")
         m.col4 = PADR(program.descript,60)
      ENDIF
   EndIF
   ******************COL5, col8***********************************
   m.col6 = space(10)
   m.col7 = SPACE(130)

   m.col9 = SPACE(30)

   INSERT INTO temp3 FROM MEMVAR

* encounter header (it's ok, ordering of temp cursor will put this prior to encounter detail from above)
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
   m.id   = DTOS(ai_enc.act_dt) + Ai_enc.act_id
   m.enc  = "A"
   m.serv_cat = ai_enc.serv_cat
   INSERT INTO temp3 FROM MEMVAR

* collateral header for this encounter
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
      m.id   = DTOS(ai_enc.act_dt) + Ai_enc.act_id
      m.enc  = "D"
      INSERT INTO temp3 FROM MEMVAR

   ENDIF

* service header for this encounter
   IF SEEK(RIGHT(m.id,10), "Ai_serv")
      m.cat_row = m.cat_row +1
      m.col1 = SPACE(10)
      m.col2 = PADR("Services Provided", 80)
      m.col3 = PADR( "How Provided", 30)
      m.col4 = PADR("Worker", 30)
      m.col8 = PADR("Total Hrs", 12)
 *      m.col5 = PADR(" Hrs", 10)
      m.col5 = SPACE(10)
      m.col6 = SPACE(10)
      m.col7 = SPACE(130)
   *   m.col8 = space(8)
      m.col9 = space(30)
      m.iswhat = "35"
      m.id    = DTOS(ai_enc.act_dt) + Ai_enc.act_id
      m.enc   = "G"
      INSERT INTO temp3 FROM MEMVAR

   ENDIF
 ENDSCAN

* collateral details for this encounter
 *-- AF Added temp3 and DIST
 SELECT DIST SPACE(10) as  col1,   ;
       PADR(oApp.FormatName(cli_cur.last_name,cli_cur.first_name, cli_cur.mi), 80) as col2,   ;
       SPACE(30) as col3,;
       space(60) as col4,;
       space(10) as col5,;
       space(10) as col6,;
       PADR(oApp.FormatName(cli_cur.last_name,cli_cur.first_name, cli_cur.mi), 130) as col7,   ;
       space(12) as col8,;
       space(30) as col9,;
       "35" as  iswhat,;
       temp3.id as id,;
       "F" as  enc,;
       Ai_enc.serv_cat as  serv_cat , ;
       temp3.cat_row AS cat_row ;
 FROM  Ai_enc,  Ai_colen,  cli_cur , temp3     ;
 WHERE Ai_enc.tc_id   = gcTc_Id ;
   and temp3.id = DTOS(ai_enc.act_dt) + Ai_enc.act_id AND temp3.enc = "D";
   and !EMPTY(Ai_enc.act_dt);
   AND Ai_enc.act_id = Ai_colen.act_id    ;
   AND Ai_colen.client_id = cli_cur.client_id;
   AND !EMPTY(Ai_colen.client_id) ;
   &cDateExpr ;
 INTO  cursor temp4
*   AND BETWEEN(ai_enc.act_dt, Enc_Date, Enc_ToDt) ;
*  Ai_colen.act_id as  id   , ;

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

Use in bill_to

* Progress Notes:****
SELECT ai_enc
  SCAN FOR (ai_enc.tc_id = gcTc_Id  AND !EMPTY(AI_enc.act_dt) &cDateExpr)
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

* service details
   SELECT ai_serv
   SCAN FOR (ai_serv.tc_id = gcTc_Id  AND !EMPTY(AI_enc.act_dt) &cDateExpr )
   
**              AND BETWEEN(ai_enc.act_dt, Enc_Date, Enc_ToDt))
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
           =openfile("serv_list")
 *          GO TOP
*!*              LOCATE FOR (serv_cat=m.serv_cat AND (enc_type = m.enc_type;
*!*                OR EMPTY(enc_type)) AND code = m.service)
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
                   m.col4 = PADR(oApp.FormatName(Staff.last, Staff.first, ''), 60)
                ENDIF
             ENDIF
          ENDIF
**********************COL5*****************************************
          IF (!EMPTY(Ai_serv.s_beg_tm) AND !EMPTY( Ai_serv.s_end_tm))
 
             m.col8 = FormHours(TimeSpent(Ai_serv.s_beg_tm, ;
                        Ai_serv.s_beg_am, Ai_serv.s_end_tm, ;
                        Ai_serv.s_end_am))
          ELSE
*             m.col5 = space(10)
             m.col8 = space(12)
          ENDIF
*-- AF
        *  m.col4 = LEFT(m.col4,25) +" " +ALLTRIM(m.col5)
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
*                 m.col6 = IIF(i = 1, "Remarks:", SPACE(10))
                  m.col1 = STR(i,10)
                  INSERT INTO temp3 FROM MEMVAR
             ENDFOR
          ENDIF

        * jss, 03/03/03, add code here for details of any topics associated with service
        * see if there are any associated topics; if so, print a topic header line and get the topic details

        * if this is a group level intervention, topics will only have an att_id, so seek that way, else use serv_id
   	  SELECT ai_topic
		  IF m.serv_cat = '00013' && GLI
		  	  SET ORDER TO att_id
		  	  mseek = ai_serv.att_id
		  	  mfor  = 'att_id'
		  ELSE
	        SET ORDER TO serv_id
	        mseek = ai_serv.serv_id
	        mfor  = 'serv_id'
		  ENDIF
		  
        IF SEEK(mseek)
		      m.cat_row = m.cat_row +1
		      m.col1 = SPACE(10)
		      m.col2 = SPACE(5) + PADR("Topics", 65)
		      m.col3 = SPACE(30)
		      m.col4 = SPACE(60)
		      m.col5 = SPACE(10)
		      m.col6 = SPACE(10)
		      m.col7 = SPACE(130)
		      m.col8 = space(12)
		      m.col9 = SPACE(30)
		      m.iswhat = "35"
		      m.id   = DTOS(ai_enc.act_dt) + Ai_enc.act_id
		      m.enc  = "I"
		      INSERT INTO temp3 FROM MEMVAR
	          SCAN FOR &mfor = mseek 		&& either att_id = ai_serv.att_id OR serv_id = ai_serv.serv_id
			      m.cat_row = m.cat_row +1
			      m.col1=SPACE(10)
			      m.col2=SPACE(5) + PADR(topics.descript, 65)
		         m.col3=SPACE(30)
			      m.col4=SPACE(60)
			      m.col5=SPACE(10)
			      m.col6=SPACE(10)
		    	   m.col7=SPACE(130)
			      m.col8=space(12)
			      m.col9=SPACE(30)
			      m.iswhat="35"
		    	   m.id=DTOS(ai_enc.act_dt) + Ai_enc.act_id
			      m.enc="I"
			      INSERT INTO temp3 FROM MEMVAR
    	      ENDSCAN && ai_topic
    	  ENDIF && seek either att_id or serv_id in ai_topic    
        SELECT ai_serv
   * jss, end 03/03/03 modification          
   ENDSCAN && ai_serv
 SET MEMOWIDTH TO (memw)
ENDIF && lserv

*******************************
* DIAGNOSIS*
* jss, 6/26/03, add line "AND ai_diag.diag_code = diagnos.code" to where clause to prevent duplication of AIDS with PEDIATRIC AIDS (both have a code of 042)
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
	   col5 WITH " ", ;	
	   col6 WITH " ", ;	
	   col7 WITH " ", ;	
       iswhat WITH "11"

          m.cat_row = 1
          m.iswhat = "11"
   * jss, 5/6/03, be sure to blank out unused columns so they don't reprint stuff from previous groups
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
  
ENDIF && ldiag
********************************************

* LAB TEST HISTORY***
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
		testres.result                                                 AS testresult, ;
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
		testres.result AS testresult, ;
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
		   * jss, 5/6/03, be sure to blank out unused columns so they don't reprint stuff from previous groups
		  REPL  col1 WITH "Test Type", ;
		        col2 WITH "Description", ;
		        col3 WITH "Test" , ;
		        col6 WITH "Result", ;
		        col9 WITH "     Date", ;
		        col4 WITH "%"+SPACE(10)+" Count", ;
		        col8 WITH "Res. Date", ;
				  col5 WITH " ", ;	
				  col7 WITH " ", ;
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
*!*		     **VT 04/06/2011 Dev Tick 7942 
*!*		     m.cat_row = cat_row +1
*!*		     m.col1 =space(10)
*!*		     m.col2 = 'Key: NMI - Not Medically Indicated'
*!*		     m.col3 = space(30)
*!*		     m.col6 = space(10)
*!*		     m.col9 = space(30)
*!*		     m.col8 = space(12)
*!*		     m.col4 = space(60)
*!*		     INSERT INTO temp12 FROM MEMVAR

 ELSE
  APPEND BLANK
  REPLACE col2 WITH "No Laboratory Test History " ,iswhat WITH "12"
 EndIf
 
 Use in test_tmp
 *Use in testres
 *Use in testtype
 *Use in labtest 
ENDIF && ltest
********************************************

IF lprobl
=openfile("staff", "staff_id")
=openfile("userprof", "worker_id")
  SELECT ;
	    ai_enc.act_dt , ;
	    ref_cat.descript AS category, ;
       problems.descript AS problem, ;
	    ai_enc.program, ;
	    ai_enc.worker_id, ;
	    ai_prenc.problem AS pr_code ;
  FROM ;
       ai_prenc, problems , ref_cat , ai_enc;
  WHERE  ai_enc.tc_id = gcTc_Id ;
         AND ai_enc.act_id = ai_prenc.act_id ;
       	AND ai_prenc.problem = problems.code  ;
      	AND ref_cat.code = problems.category ;
  ORDER BY 1 desc ,2,3  ;
  INTO CURSOR probl
 IF _tally # 0
  SELECT probl
     m.cat_row = 0
     m.iswhat = "15"
     m.col5 = SPACE(10)
     m.col6 = SPACE(10)
     m.col7 = SPACE(130)
     m.col9 = SPACE(30)
     m.id   = SPACE(18)
     m.enc  = SPACE(1)
     m.serv_cat = SPACE(5)
       col1 = "Date"
       col2 = "Category"
       col3 = "Problem"
       col4 = "Program"
       col8 = "Worker"
       INSERT INTO temp12 FROM MEMVAR
   SCAN
     m.cat_row = m.cat_row +1
     m.col1 = DTOC(act_dt)
     m.col2 = category
     m.col3 = problem
     m.col4 = space(60)
     IF !EMPTY(probl.program)
      IF SEEK(probl.program, "program")
         m.col4 = PADR(program.descript,60)
      ENDIF
     EndIF
     m.col8 = SPACE(12)
     IF SEEK(probl.worker_id, "userprof")
      m.staff = userprof.staff_id
      IF SEEK(m.staff, "staff")
         m.col8 = PADR(oApp.FormatName(Staff.last, LEFT(Staff.first,1), ''), 12)
      ENDIF
     ENDIF

    INSERT INTO temp12 FROM MEMVAR
  ENDSCAN
 ELSE
  SELECT temp12
  APPEND BLANK
  REPLACE col2 WITH "No Problem History " ,iswhat WITH "15"
 EndIf
 
 Use in probl
ENDIF  && lprobl

* PREGNANCY HISTORY***
IF lpreg
 SELECT conf_dt,del_dt,del_site,birth_type,delivery,neostat,nstat_wks,azt_preg,;
 azt_del,azt_counsl,preg_type ;
 FROM PREGNANT ;
 WHERE tc_id = gcTc_Id ;
 INTO CURSOR preg_tmp

 SELECT temp13

 IF _TALLY<>0
  APPEND BLANK
  REPL  col1 WITH "Del. Date", ;
        col2 WITH "Site" ,;
        col3 WITH "Birth Type", ;
        col6 WITH "Del. Type", ;
        col4 WITH "Neo. Stat",;
        col9 WITH "Outcome",;
        col8 WITH " ",;
        col7 WITH " ",;
        col5 WITH " ",;
        iswhat WITH "13",;
        cat_row with 0
        m.iswhat = "13"
     SELECT preg_tmp
     SCAN
   * jss, 5/6/03, be sure to blank out unused columns so they don't reprint stuff from previous groups
      	m.col3=SPACE(30)
      	m.col4=SPACE(60) 
      	m.col5=SPACE(10) 
      	m.col6=SPACE(10) 
      	m.col7=SPACE(130) 
      	m.col8=SPACE(12) 
      	m.col9=SPACE(30) 
      
        m.cat_row = cat_row +1
        m.col1 = PADR(DTOC( preg_tmp.del_dt),10)
        m.col2 = PADR(preg_tmp.del_site,30)
        DO CASE
           CASE preg_tmp.birth_type = 1
             m.col3 = "Single"
           CASE preg_tmp.birth_type = 2
             m.col3 = "Twin"
           CASE preg_tmp.birth_type = 3
             m.col3 = "> 2"
           CASE preg_tmp.birth_type = 4
             m.col3 = "Unknown"
        ENDCASE
        DO CASE
           CASE preg_tmp.delivery = 1
             m.col6 = "Vaginal"
           CASE preg_tmp.delivery = 2
             m.col6 = "Caesarian"
           CASE preg_tmp.delivery = 3
             m.col6 = "Unknown"
        ENDCASE
        DO CASE
           CASE preg_tmp.neostat = 1
             m.col4 = "Full Term"
           CASE preg_tmp.neostat = 2
             m.col4 = "Premature"+space(1)+str(nstat_wks)
        ENDCASE
        DO CASE
           CASE preg_type = 1
             m.col9 = "Spontaneous Fetal Death"
           CASE preg_type = 2
             m.col9 = "Induced Abortion"
           CASE preg_type = 3
             m.col9 = "Live Birth"
        ENDCASE
        INSERT INTO temp13 FROM MEMVAR
     ENDSCAN
 ELSE
  APPEND BLANK
  REPLACE col2 WITH "No Pregnancy History " ,iswhat WITH "13"
 EndIf
 Use in preg_tmp
ENDIF && lpreg
********************************************
* PLACEMENT HISTORY***
IF lplace
	SELECT ;
      placehis.place_id            , ;
		placehis.place_cat				, ;
		placehis.location 				, ;
		placehis.start_dt 				, ;
		placehis.end_dt   				, ;
		placecat.descript AS cat_desc , ;
		ref_srce.name     AS loc_desc   ;
	FROM ;
		placehis, placecat, ref_srce ;
	WHERE ;
		placehis.client_id = m.client_id ;
	  AND ;
		placehis.place_cat = placecat.code ;
	  AND ;
		!EMPTY(placehis.location)         ;
	  AND ;
	   placehis.location = ref_srce.code ;	
	UNION ;
	SELECT ;
       placehis.place_id            , ;
		placehis.place_cat					, ;
		placehis.location 					, ;
		placehis.start_dt 					, ;
		placehis.end_dt   					, ;
		placecat.descript 	AS cat_desc , ;
		SPACE(30)		     	AS loc_desc   ;
	FROM ;
		placehis, placecat ;
	WHERE												;
		placehis.client_id = m.client_id 	;
	  AND 											;
		placehis.place_cat = placecat.code  ;
	  AND												;
		EMPTY(placehis.location)				;
	INTO CURSOR ;
       p_t 
       
Select p_t.*, ;
      placehis.place_info ;
from p_t, placehis ;
where p_t.place_id = placehis.place_id ;
into cursor placetmp ;
order by p_t.start_dt  desc

Use in p_t


*      placehis.place_info           , ;

 SELECT temp14

 IF _TALLY<>0
  APPEND BLANK
  REPL  col1 WITH "Location" , ;
        col2 WITH "Location Desc / Detail Info" , ;
        col3 WITH "Start Date" , ;
        col6 WITH "End Date"  , ;
        col4 WITH "Category"  , ;
        col9 WITH "Category Desc"    , ;
        col8 WITH " ",;
        col7 WITH " ",;
        col5 WITH " ",;
        iswhat WITH "14",;
        cat_row with 0
        m.iswhat = "14"
        m.col8 = SPACE(12)
        m.col5 = SPACE(10)
     SELECT placetmp
     SCAN
          m.cat_row = cat_row +1
          m.col1 = PADR(placetmp.location,10)
          m.col2 = placetmp.loc_desc
          m.col3 = PADR(DTOC(placetmp.start_dt),10)
          m.col6 = PADR(DTOC(placetmp.end_dt),10)
          m.col4 = placetmp.place_cat
          m.col9 = placetmp.cat_desc
          m.col7 = placetmp.place_info
          INSERT INTO temp14 FROM MEMVAR
     ENDSCAN
 ELSE
  APPEND BLANK
  REPLACE col2 WITH "No Placement History " ,iswhat WITH "14"
 EndIf
 
 Use in placetmp
 
ENDIF && lplace
********************************************
* GROUP ENROLLMENT HISTORY***
IF lgroup
	SELECT ;
		ai_grp.group 				, ;
		group.descript 				, ;
		ai_grp.start_dt   			, ;
		ai_grp.end_dt		        , ;
		ai_grp.worker_id 			, ;
		SPACE(20) AS last			, ;
		SPACE(15) AS first   		  ;
	FROM ;
		ai_grp, group ;
	WHERE ;
		ai_grp.tc_id = gcTc_Id ;
	  AND ;
		ai_grp.group = group.grp_id ;
	INTO CURSOR ;
		grouptmp ;
	ORDER BY ;
		3 DESC

	grp_tally=_tally

	SELECT staffcur
	SET ORDER TO worker_id
	oApp.ReOpenCur("grouptmp", "grptmp")
	SET RELATION TO worker_id INTO staffcur
	GO TOP
	REPLACE ALL last WITH staffcur.last, first WITH staffcur.first 

	SELECT temp16

	IF grp_tally <> 0
		APPEND BLANK
		REPLACE	col1 WITH "Group ID" , ;
        		col2 WITH "Group Name" , ;
        		col3 WITH "Start Date" , ;
        		col6 WITH "End Date"  , ;
        		col4 WITH "Worker ID"  , ;
        		col9 WITH "Worker Name"    , ;
        		col8 WITH " ",;
        		col7 WITH " ",;
        		col5 WITH " ",;
        		iswhat WITH "24",;
        		cat_row with 0
        		m.iswhat = "24"
        		m.col8 = SPACE(12)
        		m.col5 = SPACE(10)
     	SELECT grptmp
     	SCAN
        	m.cat_row = cat_row +1
        	m.col1 = PADR(grptmp.group,10)
        	m.col2 = grptmp.descript
        	m.col3 = PADR(DTOC(grptmp.start_dt),10)
        	m.col6 = PADR(DTOC(grptmp.end_dt),10)
        	m.col4 = grptmp.worker_id
        	m.col7 = ' '
        	m.col9 = PADR(ALLTRIM(grptmp.last) + ', '+ ALLTRIM(grptmp.first),30)
        	INSERT INTO temp16 FROM MEMVAR
     	ENDSCAN
	ELSE
		APPEND BLANK
		REPLACE col2 WITH "No Group Enrollments " ,iswhat WITH "24"
	EndIf
   
   Use in grouptmp
  * Use in ai_grp
  * Use in group
   Use in grptmp
ENDIF && lgroup
********************************************
Use in ai_enc
********************************************
* 3/2000, jss, combine temp13 and temp14 here because too many unions below to do it there
* 4/2001, jss, add in temp16 for group enrollments
 SELECT *     ;
  FROM temp13 ;
 UNION ALL    ;
 SELECT *     ;
  FROM temp14 ;
 UNION ALL    ;
 SELECT *     ;
  FROM temp16 ;
 INTO CURSOR  ;
       temp13a

  Use in temp13
  Use in temp14
  Use in temp16
   
 SELECT *    ;
  FROM temp01;
 UNION ALL   ;
 SELECT *    ;
  FROM temp08;
 UNION ALL   ;
 SELECT *    ;
  FROM temp09;
 UNION ALL   ;
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
  FROM temp13a;
 UNION ALL   ;
 SELECT *    ;
  FROM temp2 ;
 UNION ALL   ;
 SELECT *    ;
  FROM temp3 ;
 UNION ALL   ;
 SELECT *    ;
  FROM temp4 ;
 INTO cursor temp25 

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
      m.rwrisk as rwrisk, ;
      m.cdcrisk as cdcrisk, ;
      m.hisp_des as hisp_des, ;
      m.ethnicdet as ethnicdet, ;
      m.ins_des as ins_des, ;
      m.race_des as race_des, ;
      m.serpmemo as serpmemo, ;
      m.coll_inv as coll_inv, ;
      m.topic_ul as topic_ul, ;
      GetHeader(iswhat) as header_descr,;
      Space(55) as serv_desc, ;
      cDate as cDate,;
      cTime as cTime ; 
from temp25; 
into cursor temp35;
ORDER BY 10 ASC, 13 ASC,11 DESC, 12 ASC, 14 ASC, 1 ASC

SELECT serv_cat
SET ORDER TO code
oApp.ReOpenCur("temp35", "temp")
SET RELATION TO serv_cat INTO serv_cat
GO TOP
REPLACE ALL serv_desc WITH serv_cat.descript
Set Relation to

oApp.msg2user("OFF")
Use in temp4
Use in temp3
Use in temp2
Use in temp13a
Use in temp12
Use in temp11
Use in temp1
Use in temp09
Use in temp08
Use in temp01
Use in temp25
Use in temp35

gcRptName = 'rpt_cli_prof'

Select temp

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
            DO CASE
               CASE lPrev = .f.
               
                   Report Form rpt_cli_prof To Printer Prompt Noconsole NODIALOG 
                   Select ai_clien
                   Replace client_profile_printed With Datetime() For ai_clien.tc_id = gcTc_Id
                   Select temp
                   
               CASE lPrev = .t.     
                    oApp.rpt_print(5, .t., 1, 'rpt_cli_prof', 1, 2)
           ENDCASE
Endif
set cent on
RETURN	
**************************************************************
FUNCTION SHowTime
PARAMETER ctime1
IF EMPTY(ctime1)
	RETURN ''
ELSE
	RETURN (SUBSTR(ctime1, 1, 2) + ":" + SUBSTR(ctime1, 3, 2) + " ")
ENDIF
**************************************************************
FUNCTION GetHeader
Parameters iswhat 
* jss, 7/10/01, modify header descriptions to match new screen headers
*               also, we are modifying the "iswhat" values to insure same order as screen
DO CASE
   CASE iswhat = "00"
        RETURN("HIV and TB Status                                                                                                               ")
   CASE iswhat = "01"
        RETURN("Insurance History                                                                                                               ")
   CASE iswhat = "09"
        RETURN("Family Information                                                                                                              ")
   CASE iswhat = "10"
        RETURN("Medication History                                                                                                              ")
   CASE iswhat = "11"
        RETURN("Diagnosis History                                                                                                               ")
   CASE iswhat = "12"
        RETURN("Laboratory/Psychological Test History                                                         Key: NMI - Not Medically Indicated")
   CASE iswhat = "13"
        RETURN("Pregnancy History                                                                                                               ")
   CASE iswhat = "14"
        RETURN("Placement/Visit History                                                                                                         ")
   CASE iswhat = "15"
        RETURN("Problem History                                                                                                                 ")
   CASE iswhat = "20"
        RETURN("Referral History                                                                                                                ")
   CASE iswhat = "22"
        RETURN("Program Enrollment History                                                                                                      ")
   CASE iswhat = "24"
        RETURN("Group Enrollment History                                                                                                        ")
   CASE iswhat = "35"
        RETURN("Encounters and Services History                                                                                                 ")
   OTHERWISE
        RETURN(SPACE(10))
   ENDCASE
**************************************************************
FUNCTION GetServCat
Parameters serv_cat
IF SEEK(serv_cat,"serv_cat")
	RETURN(serv_cat.descript)
Else
	RETURN("")
ENDIF

***********************************************************************
FUNCTION CDC_AIDS
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
**********************************************************
FUNCTION HIV_Pos
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

Use in hstat
Use in hivstat

RETURN lHIV_Pos
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


