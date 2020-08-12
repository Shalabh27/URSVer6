*  Program...........: SUMMSPOP.PRG (Summary of Special Populations)
Parameters lPrev,  ;
            cContract, ;
            cCsite, ;
            date_from, ;
            date_to, ;
            eMPR  
            
PRIVATE gcHelp
gcHelp = "" 

cDate = DATE()
cTime = Time()
cAgency_id = " "
cAgc_Name = " "
cMonthYear = Cmonth(date_from) + ", " + RIGHT(DTOC(date_from),4)

=OPENFILE("Agency","Agency")
cAgency_ID = AllTrim(Agency.agency)
cAgc_Name = Agency.descript1
m.agencydesc = Agency.descript1

=clean_data()

m.ContrDes = " "

=OPENFILE("Contrinf")

SELECT Contrinf
Locate For Contrinf.Cid = cContract
m.ContrDes =Contrinf.Descript

* MHRA decided that the agency would be responsible for establishing an MHRA program,
* that would be included only in one contract.
* select all clients enrolled in any MHRA Program in a given period of time.

* list of special population codes,descriptions from table SPECLPOP as of 7/24/98
*  CODE   DESCRIPT                         MAPS TO MHRA Report Description                           
*  01     Recent Immigrant                         Immigrants                         
*  02     Prison Releasee/Probationer   ---------> Prisoner/Recent Releasee from Correction Setting                         
*  03     Migrant/Seasonal Farm Worker  ---------> --                         
*  04     Mentally Ill Chemical Abuser  ---------> Mentally Ill and Chemically Addicted (MICA)                         
*  05     Women                         ---------> --                         
*  06     Adolescents                   ---------> --                         
*  07     Gay Man Of Color              ---------> Gay Men of Color                         
*  08     Other                         ---------> Other                         
*  09     Veteran                       ---------> --                         
*  10     Inmate of DFY Facility        ---------> --                         
*  11     Family of Inmate of DFY Facility  -----> --                         
*  12     Transgenders                  ---------> --                         
*  13     Commercial Sex Workers        ---------> --                         
*  14     Homeless                      ---------> Homeless                         
*  15     Minority Population           ---------> --                         
*  16     Substance Users               ---------> Active or Recovering Alcohol and Other Drug User                         
*  17     IDUS                          ---------> Active or Recovering Alcohol and Other Drug User                                                  
*  18     Unprotected Heterosexual Contacts -----> --                                
*  19     Same Sex Contacts             ---------> Men who have Sex with Men (MSM)                                    
*  20     Sex Contacts/IDU              ---------> --                                    
*  21     General/Community Volunteers  ---------> --                                    
*  22     Pediatrics                    ---------> --

dDate_To = Date_To
m.date_from = date_from
* 1/99, jss, according to MHRA, should be using contract year for YTD totalling,
*            so better get that now:
SELECT ;
		start_dt AS ytd_from;
FROM  ;
		contract ;
WHERE ;
		contract.con_id = cContract ;
INTO CURSOR ;
		ytdfrom		

m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(m.date_from),4)),ytdfrom.ytd_from)

FOR i = 1 TO 2
** use contract start date for YTD numbers
	dDate_From = IIF(i = 1, m.date_from, m.ytd_from)

* i=1,get new only for monthly (newly opened only)
* i=2,get enrolled total for ytd (note: ytd is a misnomer. actually, you really get all clients
*                                       enrolled in contract's associated program since inception,
*                                       so ytd total goes back to earlier contracts for this program
	IF i=1
		SELECT;
	      c.Con_ID   AS Contract, ;
	      f.Descript AS ContrDes, ;
	      a.Tc_ID ;
		FROM ;
		   Ai_Prog A , ;
			Program B , ;
			Contract C, ;
			Ai_Site D , ;
			Site E    , ;
			ContrInf F ;
		WHERE  c.Con_ID = cContract ;
		   AND a.Program = b.Prog_ID ;
			AND b.Prog_ID = c.Program ;
			AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND c.Con_ID = f.Cid ;
		 	AND !EXISTS (SELECT * FROM Ai_Prog ;
		 						WHERE Ai_Prog.Program = A.Program ;
		 							AND !EMPTY(Ai_Prog.End_Dt) ;
	 								AND AI_Prog.End_Dt <= a.Start_Dt ;
	 								AND AI_Prog.Tc_ID = a.TC_ID) ;
		INTO CURSOR ;
		   tTemp1 
	ELSE
		SELECT;
	      c.Con_ID   AS Contract, ;
	      f.Descript AS ContrDes, ;
	      a.Tc_ID ;
		FROM ;
		   Ai_Prog A , ;
			Program B , ;
			Contract C, ;
			Ai_Site D , ;
			Site E    , ;
			ContrInf F ;
		WHERE  c.Con_ID = cContract ;
		   AND a.Program = b.Prog_ID ;
			AND b.Prog_ID = c.Program ;
			AND a.Start_Dt <= dDate_To ;
			AND (EMPTY(a.End_dt) OR a.End_dt>=dDate_From) ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND c.Con_ID = f.Cid ;
		INTO CURSOR ;
		   tTemp1 

* jss, 11/14/03, add another select here to grab the distinct contract ytd clients (new or reopened)
		SELECT ;
	      c.Con_ID   AS Contract, ;
	      f.Descript AS ContrDes, ;
	      a.Tc_ID ;
		FROM ;
		   Ai_Prog A , ;
			Program B , ;
			Contract C, ;
			Ai_Site D , ;
			Site E    , ;
			ContrInf F ;
		WHERE  c.Con_ID = cContract ;
		   AND a.Program = b.Prog_ID ;
			AND b.Prog_ID = c.Program ;
			AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
			AND a.Tc_ID = d.Tc_ID ;
			AND e.Site_ID = d.Site ;
			AND e.Site_ID = cCSite ;
			AND e.Agency_ID = cAgency_ID ;
			AND c.Con_ID = f.Cid ;
		INTO CURSOR ;
		   tTemp2 
   ENDIF

** jss, 2/14/02, remove this line from above select: no longer used: 	"AND b.Aar_Report ; "

   cCursName = "tSpec" + STR(i,1) 
	SELECT;
	       a.Contract, ;
	       a.ContrDes, ;
	       d.code, ;
	       d.descript, ;
	       COUNT(DIST a.tc_id) AS numbcli ;
		FROM ;
		    tTemp1   a, ;
			 Ai_Spclp b, ;
			 speclpop c, ;
			 mhraspop d  ;
		WHERE ;
		    a.Tc_ID = b.Tc_ID ;
		AND b.code  = c.code ;
		AND d.code  = c.mhra_code ;  
		INTO CURSOR ;
		    &cCursName  ;
		GROUP BY ;
		    a.Contract, ;
		    d.code, ;
          a.ContrDes, ;
          d.descript

* jss, 11/13/03, add code here for contract ytd counts
  IF i = 2
	SELECT;
	       a.Contract, ;
	       a.ContrDes, ;
	       d.code, ;
	       d.descript, ;
	       COUNT(DIST a.tc_id) AS concli ;
		FROM ;
		    tTemp2   a, ;
			 Ai_Spclp b, ;
			 speclpop c, ;
			 mhraspop d  ;
		WHERE ;
		    a.Tc_ID = b.Tc_ID ;
		AND b.code  = c.code ;
		AND d.code  = c.mhra_code ;  
		INTO CURSOR ;
		    conspec  ;
		GROUP BY ;
		    a.Contract, ;
		    d.code, ;
          a.ContrDes, ;
          d.descript
  ENDIF
*********************************
* jss, 2/15/02, add code here for household income counts of new clients, ytd clients

	SELECT DIST a.contract, ;
				a.tc_id, ;
				b.hshld_incm ;
		FROM  	ttemp1 a, ;
				client b, ;
				ai_clien c ;
		WHERE   a.tc_id = c.tc_id ;
		AND		b.client_id = c.client_id ;
		INTO CURSOR tHousIncm

	cCursIncm = "tIncm" + STR(i,1) 

	SELECT 	contract, ;
		SUM(IIF(hshld_incm < 10000,1,0)) 						 		AS cliunder10, ;
		SUM(IIF(hshld_incm >= 10000 AND hshld_incm < 20000,1,0)) AS cli_10_19, ;
		SUM(IIF(hshld_incm >= 20000 AND hshld_incm < 30000,1,0)) AS cli_20_29, ;
		SUM(IIF(hshld_incm >= 30000 AND hshld_incm < 40000,1,0)) AS cli_30_39, ;
		SUM(IIF(hshld_incm >= 40000 AND hshld_incm < 50000,1,0)) AS cli_40_49, ;
		SUM(IIF(hshld_incm >= 50000,1,0)) 						 		AS cli_50plus ;
	FROM tHousIncm ;
	INTO CURSOR &cCursIncm ;
	GROUP BY 1
	
* jss, 2/15/02, end of new code for	household income counts	

* jss, 11/14/03, add code here for CONTRACT YTD household income counts

  IF i = 2
	SELECT DIST a.contract, ;
				a.tc_id, ;
				b.hshld_incm ;
		FROM  	ttemp2 a, ;
				client b, ;
				ai_clien c ;
		WHERE   a.tc_id = c.tc_id ;
		AND		b.client_id = c.client_id ;
		INTO CURSOR tconincm

	SELECT 	contract, ;
		SUM(IIF(hshld_incm < 10000,1,0)) 						 		AS cliunder10, ;
		SUM(IIF(hshld_incm >= 10000 AND hshld_incm < 20000,1,0)) AS cli_10_19, ;
		SUM(IIF(hshld_incm >= 20000 AND hshld_incm < 30000,1,0)) AS cli_20_29, ;
		SUM(IIF(hshld_incm >= 30000 AND hshld_incm < 40000,1,0)) AS cli_30_39, ;
		SUM(IIF(hshld_incm >= 40000 AND hshld_incm < 50000,1,0)) AS cli_40_49, ;
		SUM(IIF(hshld_incm >= 50000,1,0)) 						 		AS cli_50plus ;
	FROM tconIncm ;
	INTO CURSOR conIncm ;
	GROUP BY 1
  ENDIF	
	
* jss, 11/14/03, end of new code for CONTRACT YTD household income counts	
*********************************
* jss, 2/15/02, add new code here for housing counts
	SELECT DIST a.contract, ;
				a.tc_id, 	;
				b.housing 	;
		FROM  	ttemp1 a, 	;
				ai_clien b  ;
		WHERE   a.tc_id = b.tc_id ;
		INTO CURSOR tHousStat

	cCursHous = "tHous" + STR(i,1) 

	SELECT 	contract, ;
		SUM(IIF(housing = '01' OR housing = '02', 1, 0)) 							AS nHomeless, ;
		SUM(IIF(housing = '03', 1, 0)) 					 								AS nTransHous, ;
		SUM(IIF(housing = '04' OR housing = '05' OR housing = '06', 1, 0)) 	AS nResidFac, ;
		SUM(IIF(housing = '07' OR housing = '08' OR housing = '12', 1, 0)) 	AS nOtherHous, ;
		SUM(IIF(housing = '09', 1, 0)) 					 								AS nCorrFac, ;
		SUM(IIF(housing = '10' OR housing = '11', 1, 0)) 							AS nPermHous ;
	FROM tHousStat ;
	INTO CURSOR &cCursHous ;
	GROUP BY 1

* jss, end of 2/15/02 housing count code

* jss, 11/14/03, add new code here for CONTRACT YTD housing counts
  IF i = 2
	SELECT DIST a.contract, ;
				a.tc_id, 	;
				b.housing 	;
		FROM  	ttemp2 a, 	;
				ai_clien b  ;
		WHERE   a.tc_id = b.tc_id ;
		INTO CURSOR tconHous

	SELECT 	contract, ;
		SUM(IIF(housing = '01' OR housing = '02', 1, 0)) 							AS nHomeless, ;
		SUM(IIF(housing = '03', 1, 0)) 					 								AS nTransHous, ;
		SUM(IIF(housing = '04' OR housing = '05' OR housing = '06', 1, 0)) 	AS nResidFac, ;
		SUM(IIF(housing = '07' OR housing = '08' OR housing = '12', 1, 0)) 	AS nOtherHous, ;
		SUM(IIF(housing = '09', 1, 0)) 					 								AS nCorrFac, ;
		SUM(IIF(housing = '10' OR housing = '11', 1, 0)) 							AS nPermHous ;
	FROM tconHous ;
	INTO CURSOR conHous ;
	GROUP BY 1
  ENDIF	

* jss, end of 11/14/03 CONTRACT YTD housing count code
NEXT							

**************** end of 2/15/02 changes
* first run thru (tSpec1) has current month, second run thru (tSpec2) has YTD
* now, merge the current month and ytd data: first Select gets matches only current month to its 
*      ytd counterpart; second Select (with join) gets the rest of the ytd numbers

SELECT ;
      b.Contract, ;
      b.ContrDes, ;
      b.code,     ;
      b.Descript, ;
      a.NumbCli,  ;
      b.NumbCli AS NumbCliTot ; 
  FROM tSpec1 a, ;
	    tSpec2 b  ;
  WHERE ;
	   a.Contract = b.Contract ;
    AND ;
		a.code = b.code ;
	INTO CURSOR ;
	   tInterim

SELECT a.* ;
	FROM tInterim a ;
UNION ;
SELECT Contract, ;
       ContrDes, ;
       code,     ;
       descript, ;
       0         AS NumbCli,   ;
       NumbCli   AS NumbCliTot ; 
	FROM ;
	    tSpec2 ;
	WHERE ;
	    Contract + Code ;
	   NOT IN ;
		(SELECT Contract + Code FROM tInterim) ;
	INTO CURSOR preFinal ;
	ORDER BY 1, 3	

* now, create one zero count record per mhra code for each contract (so, if 12 mhra codes, we get
* 12 records per contract)

SELECT DISTINCT ;
      a.Contract, ;
      a.ContrDes, ;
      b.code,     ;
      b.Descript, ;
      0000000000 AS NumbCli,   ;
      0000000000 AS NumbCliTot ; 
  FROM ;          
      prefinal a, mhraspop b ;
  INTO CURSOR;
      zerofill

* now, merge prefinal and zerofill to get all codes represented for each contract
SELECT * ;
  FROM prefinal ;
UNION ;
SELECT * ;
  FROM ;
       zerofill ;
  WHERE ;
       Contract + Code ;
     NOT IN ;
     (SELECT Contract + Code FROM prefinal) ;
  INTO CURSOR;
      tfinal ;
  ORDER BY 1,3             

* jss, 11/13/03, add code here that will bring in the contract ytd totals
SELECT a.Contract, ;
       a.ContrDes, ;
       a.code,     ;
       a.descript, ;
       a.NumbCli,   ;
       a.NumbCliTot, ; 
		 b.concli,    ;
       cMonthYear as cMonthYear, ;
       cDate  as cDate, ;
       cTime  as cTime, ;
       cAgc_Name as cAgc_Name ;  
	FROM ;
		tfinal a, conspec b ;
	WHERE ;
	   a.Contract = b.Contract ;
  	AND a.code = b.code ;
	UNION ;
	SELECT Contract, ;
       ContrDes, ;
       code,     ;
       descript, ;
       NumbCli,   ;
       NumbCliTot, ; 
		 0000000000 AS concli, ;
       cMonthYear as cMonthYear, ;
       cDate  as cDate, ;
       cTime  as cTime, ;
       cAgc_Name as cAgc_Name ;  
	FROM ;
		tfinal ;
	WHERE ;
       Contract + Code ;
     NOT IN ;
     (SELECT Contract + Code FROM conspec) ;
	INTO CURSOR;
      final ;
  	ORDER BY 1,3   
               
oApp.Msg2User('OFF')
GO TOP
IF EOF()
   IF eMPR
      =NullElec()
   ELSE

       oApp.Msg2user('NOTFOUNDG')
       If Used('final')
           Use in final
       Endif   
       Select ;
                 ContrInf.Descript   AS ContrDes   ,;
                 'Section III: Monthly Program Report' as nulrptname ,;
                 'Table IV - E: Summary of Special Populations' as nulrptnam1 ,;
                 '' as nulrptnam2 ,;
                 '' as nulrptnam3 ,;
                 '' as nulrptnam4,  ;
                 'Ryan White Comprehensive AIDS Resource Emergency Act, Title I' as cType, ;
                 cMonthYear as cMonthYear, ;
                 cDate  as cDate, ;
                 cTime  as cTime, ;
                 cAgc_Name as cAgc_Name ;
       From ContrInf ;
       Where ContrInf.Cid = cContract ;       
       Into Cursor final     
       
          gcRptName = 'rpt_null'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_null  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_null', 1, 2)
          Endcase
   Endif       
Else
   IF eMPR
      =Electronic()
   ELSE

          gcRptName = 'rpt_mhra_spp'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_spp  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_spp', 1, 2)
          Endcase
   Endif       
EndIf
* close cursors and tables
*************************
Function clean_data
IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("tInterim")
	USE IN ("tInterim")
ENDIF

IF USED("Final")
	USE IN ("Final")
ENDIF

IF USED("tFinal")
   USE IN ("tFinal")
EndIf

IF USED("preFinal")
	USE IN ("preFinal")
ENDIF

IF USED("zerofill")
	USE IN ("zerofill")
ENDIF

IF USED("mhraspop")
	USE IN ("mhraspop")
ENDIF

IF USED("Ai_Spclp")
	USE IN ("Ai_Spclp")
ENDIF

IF USED("speclpop")
	USE IN ("speclpop")
ENDIF

IF USED("Ai_Prog")
	USE IN ("Ai_Prog")
ENDIF

IF USED("Program")
	USE IN ("Program")
ENDIF

IF USED("Contract")
	USE IN ("Contract")
ENDIF

IF USED("Ai_Site")
	USE IN ("Ai_Site")
ENDIF

IF USED("Site")
	USE IN ("Site")
ENDIF

IF USED("ContrInf")
	USE IN ("ContrInf")
ENDIF

IF USED("tSpec1")
	USE IN ("tSpec1")
ENDIF

IF USED("tSpec2")
	USE IN ("tSpec2")
ENDIF

IF USED("conspec")
	USE IN ("conspec")
ENDIF

RETURN

*******************
FUNCTION Electronic
*******************
* jss, 5/17/04, add code here to write to electronic mpr table (mprive.dbf)

SELECT 0
USE mprive EXCL
ZAP

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

STORE 0 TO tNumbCli, tNumbCliT, tConCli

* now, roll thru final, writing 1 Electronic MPR record per final record
SELECT Final
GO TOP

SCAN
	SCATTER MEMVAR	

* write a detail line to electronic mpr dbf
	SELECT mprive
	APPEND BLANK
	GATHER MEMVAR
	
	tNumbCli=tNumbCli + m.NumbCli
	tNumbCliT=tNumbCliT + m.NumbCliTot
	tConCli=tConCli + m.ConCli
	
	SELECT Final
ENDSCAN

* write report total line

m.descript='Report Totals'
m.NumbCli=tNumbCli
m.NumbCliTot=tNumbCliT
m.ConCli=tConCli

SELECT mprive
APPEND BLANK
GATHER MEMVAR

USE IN mprive

* now, write the summary portion of the report to 2nd Electronic MPR table (mprivfg.dbf)
* section ivf
m.n_under10 = tincm1.cliunder10	
m.n_10_19	= tincm1.cli_10_19
m.n_20_29	= tincm1.cli_20_29	
m.n_30_39	= tincm1.cli_30_39	
m.n_40_49	= tincm1.cli_40_49	
m.n_50plus	= tincm1.cli_50plus	

m.t_under10 = tincm2.cliunder10	
m.t_10_19	= tincm2.cli_10_19
m.t_20_29	= tincm2.cli_20_29	
m.t_30_39	= tincm2.cli_30_39	
m.t_40_49	= tincm2.cli_40_49	
m.t_50plus	= tincm2.cli_50plus	

m.c_under10 = conincm.cliunder10	
m.c_10_19	= conincm.cli_10_19
m.c_20_29	= conincm.cli_20_29	
m.c_30_39	= conincm.cli_30_39	
m.c_40_49	= conincm.cli_40_49	
m.c_50plus	= conincm.cli_50plus	

* section ivg
m.nHomeless	= thous1.nhomeless
m.ntranshous= thous1.ntranshous
m.npermhous	= thous1.npermhous
m.nresidfac	= thous1.nresidfac
m.ncorrfac	= thous1.ncorrfac
m.notherhous= thous1.notherhous

m.tHomeless	= thous2.nhomeless
m.ttranshous= thous2.ntranshous
m.tpermhous	= thous2.npermhous
m.tresidfac	= thous2.nresidfac
m.tcorrfac	= thous2.ncorrfac
m.totherhous= thous2.notherhous

m.cHomeless	= conhous.nhomeless
m.ctranshous= conhous.ntranshous
m.cpermhous	= conhous.npermhous
m.cresidfac	= conhous.nresidfac
m.ccorrfac	= conhous.ncorrfac
m.cotherhous= conhous.notherhous

SELECT 0
USE mprivfg EXCL
ZAP

APPEND BLANK
GATHER MEMVAR

USE IN mprivfg

SELECT Final
GO TOP
RETURN

*****************
FUNCTION NullElec
*****************
* jss, 8/6/04, no data found, still produce shell record
m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

SELECT 0
USE mprive EXCL
ZAP
APPEND BLANK
GATHER MEMVAR

USE IN mprive

SELECT 0
USE mprivfg EXCL
ZAP
APPEND BLANK
GATHER MEMVAR

USE IN mprivfg
RETURN