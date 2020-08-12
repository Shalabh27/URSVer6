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

cTc_id = ""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)

   If Rtrim(aSelvar2(i, 1)) = "CTC_ID"
      cTc_id = aSelvar2(i, 2)
   Endif
EndFor

PRIVATE gcHelp,SELHOLD
SELHOLD = SELECT()
gcHelp = "AIDS Confidential Report (ADULT) Screen"

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
              cat_row N(6), ;
              tc_id c(10),;
              linetyp C(1))  

SELECT temp                              
=AFIELDS(aCliRef)

CREATE CURSOR temp11 FROM ARRAY aCliRef    && DIAGNOSIS
CREATE CURSOR temp12 FROM ARRAY aCliRef    && LAB TEST 

cDate = DATE()
cTime = TIME()
DATE_FROM = {01/01/1901}
DATE_TO   = DATE()

PRIVATE cWhere,AFILES

 CREATE CURSOR temp11 FROM ARRAY aCliRef    && CLEAR DIAGNOSIS
 CREATE CURSOR temp12 FROM ARRAY aCliRef    && CLEAR LAB TEST 


 DIMENSION AFILES(1)
 DO CASE 
	CASE nGroup = 2
		cWhere = " AND clistat = 'A'"
     * lcTitle = Iif(Left(crit, 8)='HIV/AIDS', '- Active Clients Only', '')
	CASE nGroup = 3
		cWhere = " AND clistat <> 'A'"
      *lcTitle = Iif(Left(crit, 8)='HIV/AIDS','- Closed Clients Only', '')
	OTHERWISE
		cWhere = ""
     *lcTitle = "" 
 ENDCASE
 
 SELECT ;  
  A.TC_ID,;
  A.SEX_MALE,;       
  A.SEX_FMLE,;       
  A.IV,;              
  A.BLDPRD,;          
  A.S_IV,;            
  A.S_BI,;             
  A.S_HEMO,;          
  A.S_TX,;            
  A.S_TRNPLT,;        
  A.S_HIV,;           
  A.TRANSFUS,;          
  A.TRANDTE1,;          
  A.TRANDTE2,;        
  A.TRANPLNT,;        
  A.HCW,;           
  A.ANTIRETV,;      
  A.PCPPROPH,;        
  A.OCCUP,;          
  A.INFORMED,;        
  A.NOTIFIED,;      
  A.REF_MS,;                
  A.REF_SATS,;         
  A.TRIAL,;           
  A.CLINIC,;           
  A.INSURNCE,;         
  A.PRENATAL,;      
  A.PREGNANT,;         
  A.LIVE_INF,;      
  A.CBDATE,;        
  A.CHOSP,;           
  A.CHOSP_ST,;        
  A.CHCITY,;          
  A.HISTORY,;         
  A.MHIVSTAT,;      
  A.MHIVMOYR,;         
  A.MCOUNSEL,;     
  A.M_IVDA,;           
  A.M_SEXIV,;         
  A.M_SEXHBI,;         
  A.M_SEXHEM,;         
  A.M_SEXTRN,;         
  A.M_SEXTPL,;         
  A.M_SEXHIV,;        
  A.M_TRANS,;        
  A.M_TRNPLT,;         
  A.MEDRECNO,;       
  A.PERS_COM,;      
  A.COMPHONE,;       
  A.USER_ID,;        
  A.DT,;              
  A.TM,;
  A.PHYSNAME,;
  A.PPHONE,;
  B.CLIENT_ID,;
  B.LAST_NAME,;
  B.FIRST_NAME,;
  B.MI,;
  B.SEX,;
  B.ETHNIC,;
  B.DOB,;
  B.SSN,;
  C.STREET1,;
  C.STREET2,;
  C.CITY,;
  C.ST,;
  C.ZIP,;
  C.HOME_PH,;
  C.WORK_PH,;
  D.HSHLD_ID,;
  D.LIVES_IN,;
  D.PRIMARY,;
  E.Death_Dt AS Death, ;
  E.Death_St, ;
  E.status  AS clistat, ;
  IIF(E.Status <> 'C', '1', IIF(!EMPTY(E.Death_Dt) OR !EMPTY(E.Death_St), '2', '9')) AS Stat, ;
  IIF(E.Status <> 'C', PADR('Alive',7), ;
  IIF(!EMPTY(E.Death_Dt) OR !EMPTY(E.Death_St), PADR('Dead',7), PADR('Unknown',7))) AS StatDesc ;
 FROM ;
 	HARS A, CLI_CUR B, ADDRESS C, CLI_HOUS D, Ai_Activ E ; 
 WHERE ;
    A.TC_ID = CTC_ID ;
 	AND A.TC_ID = B.TC_ID ;
	AND B.CLIENT_ID = D.CLIENT_ID ;
	AND D.HSHLD_ID = C.HSHLD_ID ;
	AND D.LIVES_IN = .T. ;
	AND e.tc_id = a.tc_id ;
 	AND e.Effect_Dt IN ;
	        (SELECT MAX(Effect_Dt) FROM Ai_Activ ;
						WHERE e.Tc_ID = Ai_Activ.Tc_ID )  ;
 INTO CURSOR OUT1
 
* jss, 2/15/01, add code here to define list of HIV/AIDS patients
 PRIVATE dDateEnd
 dDateEnd=DATE()
 oApp.GtHivAid 
 

* jss, 2/15/01, add code here to use the "GtHivAid" results to determine our list of HIV/AIDS clients
 SELECT ;
	Out1.* ;
 FROM ;
	Out1, Cli2Extr ;
 WHERE ;
	Out1.tc_id = Cli2Extr.tc_id ;
   AND ;
   	((DATE() - Out1.DOB) / 365) >= 13 ;
        &cwhere ;          
 INTO CURSOR ;
	Outr			

IF USED('OUT1')
   USE IN OUT1
EndIf

 IF ! USED('AI_DIAG')
  USE AI_DIAG IN 0
 ENDIF
 SELECT AI_DIAG
 SET ORDER TO TAG TC_ID

 cDate = DATE()
 cTime = TIME()
 GCNAME = ' '

 SELECT OUTR
 LOCATE

 SCAN
  =GET_TESTS(OUTR.TC_ID)
 ENDSCAN

 SELECT *    ;
  FROM temp11;
 UNION ALL   ;
 SELECT *    ;
  FROM temp12;  
 INTO cursor temp 

 IF USED("temp11")
      USE IN temp11
 ENDIF
 IF USED("temp12")
      USE IN temp12
 ENDIF

If Used('outrec')
   Use in outrec
EndIf
   
 SELECT OUTR.*,TEMP.COL1,TEMP.COL2,TEMP.COL3,TEMP.COL4,TEMP.COL5,TEMP.COL6,TEMP.COL7,;
        TEMP.COL8,TEMP.COL9,TEMP.ISWHAT,TEMP.ID,TEMP.ENC,TEMP.SERV_CAT,TEMP.CAT_ROW,;
        TEMP.LINETYP,SPACE(7) AS ICD9CODE, ;
        crit as crit;
 FROM OUTR,TEMP ;
 ORDER BY OUTR.TC_ID ;
 WHERE OUTR.TC_ID = TEMP.TC_ID ;
 INTO CURSOR OUTREC       

 If Used("outr")
      Use in ("outr")
 EndIf

 If Used("temp")
      Use in ("temp")
 EndIf


oApp.msg2user("OFF")
gcRptName = 'rpt_hiv_adu'
SELECT OUTREC
Go top 
if EOF()
    oApp.msg2user('NOTFOUNDG')
 else
            DO CASE
                CASE lPrev = .f.
                  Report Form rpt_hiv_adu  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_hiv_adu', 1, 2)
                              
           ENDCASE
endif
 SET CENT ON
Return

SELECT (SELHOLD)
RELEASE GCNAME,SELHOLD,AFILES
RETURN

FUNCTION GET_TESTS
  PARAMETER TCTC_ID
  * LAB TEST HISTORY *
  SELECT ;
	testres.testtype, ;
	testres.testcode + " " + labtest.descript AS testcode, ;
	LEFT(tstreslu.descript,10) AS result, ;
	IIF(EMPTY(testres.count), SPACE(8), STR(testres.count,8)) AS count, ;
	IIF(EMPTY(testres.percent), SPACE(2), STR(testres.percent,2)) AS percent, ;
	testres.testdate, testres.resdate, testtype.descript ;
  FROM ;
	testres, testtype, tstreslu, labtest;
  WHERE ;
	testres.testtype = testtype.code ;
	AND testres.testtype + testres.testcode = labtest.testtype +labtest.code ;
	AND testres.tc_id = tctc_id ;
	AND !EMPTY(testres.result) ;
	AND tstreslu.cvarname = 'TEST' + testres.testtype + testres.testcode ;
	AND testres.result = tstreslu.code ;
	AND testtype.tb ;
  UNION ;
  SELECT ;
	testres.testtype, ;
	testres.testcode + " " + labtest.descript AS testcode, ;
   SPACE(10) AS result, ;
	IIF(EMPTY(testres.count), SPACE(8), STR(testres.count,8)) AS count, ;
	IIF(EMPTY(testres.percent), SPACE(2), STR(testres.percent,2)) AS percent, ;
	testres.testdate, testres.resdate, testtype.descript ;
  FROM ;
	testres, testtype ,labtest;
  WHERE ;
	testres.testtype = testtype.code ;
	AND testres.testtype + testres.testcode = labtest.testtype +labtest.code ;
	AND testres.tc_id = tctc_id ;
	AND EMPTY(testres.result) ;
	AND testtype.tb ;
  UNION ;
  SELECT ;
	testres.testtype, ;
	testres.testcode + SPACE(40) AS testcode, ;
   SPACE(10) AS result, ;
	IIF(EMPTY(testres.count), SPACE(8), STR(testres.count,8)) AS count, ;
	IIF(EMPTY(testres.percent), SPACE(2), ;
	  IIF(testres.percent > 9 , STR(testres.percent,2),;
	                         "0" +STR(testres.percent,1))) AS percent, ;
	testres.testdate, testres.resdate, testtype.descript ;
  FROM ;
	testres, testtype ;
  WHERE ;
	testres.testtype = testtype.code ;
	AND testres.tc_id = tctc_id ;
	AND EMPTY(testres.result) ;
	AND testtype.tb ;	
  INTO CURSOR ;
	test_tmp ;
  ORDER BY ;
	6 DESC

  SELECT temp12

  IF _TALLY > 0
   APPEND BLANK
   REPL  col1 WITH "Test Type", ;
         col2 WITH "Description", ;
         col3 WITH "Test" ,;
         col6 WITH "Result", ;
         col9 WITH "Test Date", ;
         col4 WITH "%"+SPACE(10)+" Count",;
         col8 WITH "Res. Date",;
         iswhat WITH "12",;
         tc_id   WITH tctc_id,;   
         linetyp WITH 'D'   
         m.cat_row = 1
         m.iswhat = "12"
         m.col5 = space(10) 
         m.col6 = SPACE(10)
         m.col7 = space(130)
      SELECT test_tmp
      LOCATE
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
           m.tc_id   = tctc_id
           m.linetyp = 'D'
           INSERT INTO temp12 FROM MEMVAR
           SELECT TEST_TMP
      ENDSCAN
  ELSE
   APPEND BLANK
   REPLACE col2 WITH "No Laboratory Test History " ,iswhat WITH "12"  
  ENDIF 
  ******************************************** 

  * DIAGNOSIS*
  SELECT ;
	ai_diag.icd9code, ai_diag.hiv_icd9, ai_diag.diagnosed, ;
	ai_diag.diagdate, ai_diag.st, ;
	diagnos.descript, LEFT(county.descript,15) AS county ;
  FROM ;
	ai_diag, diagnos, county ;
  WHERE ;
	ai_diag.icd9code = diagnos.icd9code ;
	AND ai_diag.hiv_icd9 = diagnos.hiv_icd9 ;	
	AND ai_diag.tc_id = tctc_id  ;
	AND !EMPTY(ai_diag.cnty_resid) ;
	AND IIF(ai_diag.cnty_resid<>'999', ai_diag.cnty_resid = county.code ;
	AND ai_diag.st = county.state,  ai_diag.cnty_resid = county.code);
    AND !EMPTY(ai_diag.hiv_icd9) ;
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
	AND ai_diag.tc_id = tctc_id  ;
	AND EMPTY(ai_diag.cnty_resid) ;
    AND !EMPTY(ai_diag.hiv_icd9) ;
  INTO CURSOR ;
	diag_tmp ;
  ORDER BY ;
	4 DESC	

  SELECT DIAG_TMP
	
  IF _tally > 0   
   SELECT temp11
   APPEND BLANK
   REPL  col1 WITH "ICD9 Code", ;
        col2 WITH "Description", ;
        col3 WITH "HIV ICD9 Code", ;
        col9 WITH "Diagnosed", ;
        col4 WITH "State  County",;
        col8 WITH "Date",;
        iswhat WITH "11",;
        tc_id  WITH tctc_id,;  
        linetyp WITH 'H'   
          m.cat_row = 1
          m.iswhat = "11"
          m.col5 = space(10) 
          m.col6 = SPACE(10)
          m.col7 = space(130)
      SELECT diag_tmp
      LOCATE
      SCAN     
          m.cat_row = cat_row +1 
          m.col1 = PADR( diag_tmp.icd9code,10)
          m.col2 = PADR( diag_tmp.descript,80)
          m.col3 = PADR( diag_tmp.hiv_icd9,30)
          m.col9 = PADR( diag_tmp.diagnosed,30)
          m.col8 = PADR(diag_tmp.diagdate,12)      
          m.col4 = PADR( PADR(diag_tmp.st,8)+ ALLTRIM(diag_tmp.county), 60)
          m.tc_id   = tctc_id
          m.linetyp = 'D'
          INSERT INTO temp11 FROM MEMVAR          
          SELECT DIAG_TMP
      ENDSCAN
  ELSE
    SELE temp11
    APPEND BLANK
    REPLACE col2 WITH "No Diagnosis History " ,iswhat WITH "11"  
  ENDIF 
  ******************************************** 


RETURN


