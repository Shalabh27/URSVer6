*  Program...........: SUMMCLST.PRG (Summary of Client Enrollment and Caseload, Summary of Client Insurance Status,
*  ..................:							 Summary of Client HIV Status, Summary of Client TB Status)
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

m.date_from = date_from
m.date_to = date_to

=clean_data()

m.ContrDes = ''
=OPENFILE("Contrinf")
SELECT Contrinf
Locate For Contrinf.Cid = cContract
m.ContrDes =Contrinf.Descript 

PRIVATE gcHelp
gcHelp = "" && it should be changed in a future to the Help Topic's Title

dDate_To = m.Date_To

* 1/99, jss, according to MHRA, should be using contract year for YTD totalling,
*            so better get that now:

* jss, 6/26/01, grab program here, too
SELECT ;
		start_dt AS ytd_from, ;
		program ;
FROM  ;
		contract ;
WHERE ;
		contract.con_id = cContract ;
INTO CURSOR ;
		ytdfrom		

m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(m.date_from),4)),ytdfrom.ytd_from)
cprog=ytdfrom.program

FOR i = 1 TO 2
* use contract start date for YTD numbers
	dDate_From = IIF(i = 1, m.date_from, m.ytd_from)

* jss, 6/26/01, add code to grab only the MHRA contract's program (cprog)
	SELECT ;
		a.*, ;
		.T. AS New, ;
		.F. AS Reopened, ;
		.F. AS Returned ;
 	FROM ;
 		Ai_Prog A, ;
 		Program B ;
	WHERE a.Program = cprog ;
	AND a.Program = b.Prog_ID ;
	AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
	AND !EXISTS (SELECT * FROM Ai_Prog ;
				WHERE Ai_Prog.Program = A.Program ;
				AND !EMPTY(Ai_Prog.End_Dt) ;
				AND AI_Prog.End_Dt <= a.Start_Dt ;
				AND AI_Prog.Tc_ID = a.TC_ID) ;
	INTO CURSOR tNew		 							
	
	SELECT ;
		a.*, ;
		.F. AS New, ;
		.T. AS Reopened, ;
		.F. AS Returned ;
 	FROM ;
 		Ai_Prog A, ;
 		Program B ;
	WHERE  a.Program = cprog ;
	AND a.Program = b.Prog_ID ;
	AND a.Start_Dt BETWEEN dDate_From AND dDate_To ;
	AND EXISTS (SELECT * FROM Ai_Prog ;
				WHERE Ai_PROG.Program = A.Program ;
				AND !EMPTY(Ai_Prog.End_Dt) ;		 						
				AND AI_PROG.End_Dt <= a.Start_Dt ;
				AND AI_PROG.Tc_ID = a.TC_ID) ;
    INTO CURSOR tReop
   		 							
	SELECT ;
		a.*, ;
		.F. AS New, ;
		.F. AS Reopened, ;
		.T. AS Returned ;
 	FROM ;
 		Ai_Prog A, ;
 		Program B ;
	WHERE  a.Program = cprog ;
	AND a.Program = b.Prog_ID ;
	AND a.Start_Dt < dDate_From ;
	AND (EMPTY(a.End_Dt) ;
			OR (!EMPTY(a.End_Dt) AND a.End_Dt >= dDate_From)) ;
	INTO CURSOR tRetu

* tAi_Prog will necessarily contain duplicate tc_ids, since reopens have a start date in the period
* and there exists a closed record for the tc_id prior to the reopened start date
* therefore, we may use tai_prog cursor only for gross counts, not unduplicated counts
	SELECT * ;
	FROM ;
		tNew ;
	UNION ;
	SELECT * ;
	FROM ;
		tReop ;
	UNION ;
	SELECT * ;
	FROM ;
		tRetu ;
	INTO CURSOR ;
		tAi_Prog
	
* jss, 6/26/01, add field "reason" to select	
* jss, 6/26/01, remove reference to contract.dbf (also, change code to "cprog = a.program")
	SELECT ;
		DIST a.Program, f.Client_ID, ;
		a.Tc_ID, a.Start_Dt, a.End_Dt, a.New, a.Reopened, a.Returned, a.reason ;
	FROM ;
		tAi_Prog A, ;
		Ai_Site D, ;
		Site E, ;
		Ai_Clien F, ;
		Client G ;
	WHERE ;
		a.Program = cprog ;
	AND a.Tc_ID = d.Tc_ID ;
	AND e.Site_ID = d.Site ;
	AND e.Site_ID = cCSite ;
	AND e.Agency_ID = cAgency_ID ;
	AND a.Tc_ID = f.Tc_ID ;
	AND f.Client_ID = g.Client_ID ;
	INTO CURSOR ;
		tTemp1 

* tai_prog1a cursor will contain distinct tc_ids only (ignores reopens, dealt with just below)
	SELECT * ;
	FROM ;
		tNew ;
	UNION ;
	SELECT * ;
	FROM ;
		tRetu ;
	INTO CURSOR ;
		tAi_Prog1a
	
* jss, 7/12/99, add next select to include reopens that were closed at period start (i.e., not a subset of returns)
  	SELECT * FROM tAi_Prog1a	;
  	UNION ;
  	SELECT * FROM tReop ;
  		WHERE tReop.tc_id+tReop.Program ;
  			NOT IN (SELECT tc_id+program FROM tAi_Prog1a) ;
   	INTO CURSOR tAi_Prog1b 			
	
* jss, 6/99, only distinct tc_ids should result below
* jss, 6/26/01, remove reference to contract.dbf (also, change code to "cprog = a.program")
	SELECT DIST a.Program, f.Client_ID, ;
			a.Tc_ID, a.New, a.Reopened  ;
	FROM tAi_Prog1b A, ;
			Ai_Site D, ;
			Site E, ;
			Ai_Clien F, ;
			Client G ;
	WHERE  a.Program = cprog ;
	AND a.Tc_ID = d.Tc_ID ;
	AND e.Site_ID = d.Site ;
	AND e.Site_ID = cCSite ;
	AND e.Agency_ID = cAgency_ID ;
	AND a.Tc_ID = f.Tc_ID ;
	AND f.Client_ID = g.Client_ID ;
	INTO CURSOR tTemp1a 

* jss, 6/99, add if statement below to handle UNDUPLICATED YTD client enrollment (defined as
*            all distinct clients who are active at some point in period)	
	IF i=2
		 SELECT ;
		 	COUNT(DIST tc_id) AS ytd_undup ;
		 FROM ;
		 	ttemp1a ;
		 INTO CURSOR ;
		 	ytdundup 
   ENDIF

* jss, 11/13/03, add code here for new line item on report "total enrollment contract ytd"
	IF i = 2
		SELECT ;
			COUNT(DIST tc_id) AS ytd_undup ;
		FROM ;
			ttemp1a ;
		WHERE ;
			new OR reopened ;
		INTO CURSOR ;
			conundup
	ENDIF

	* Statistics
* jss, 6/26/01, use program, not contract, in all following cursors
	cCursName = "tStatist" + STR(i,1) 			
	SELECT ;
		tTemp1.program, ;
		SUM(IIF(Returned, 1, 0)) AS BeginCnt, ;
		SUM(IIF(New, 1, 0)) 		 AS NewCnt, ;
		SUM(IIF(Reopened, 1, 0)) AS ReopCnt, ;
		SUM(IIF(Returned, 1, 0)) AS ReturCnt, ;		
		SUM(IIF(BETWEEN(End_Dt, dDate_From, dDate_To), 1, 0)) AS CloseInPer ;		
	FROM tTemp1 ;
	INTO CURSOR &cCursName ;
	GROUP BY 1

	IF i = 1
	* Clients Served this month
	 	SELECT ;
			DIST tTemp1.Program, tTemp1.Tc_ID, ;
			tTemp1.New, tTemp1.Reopened, tTemp1.Returned ;
	 	FROM ;
	 		tTemp1, ;
		 	Ai_Enc, ;
   			Ai_Serv ;
	 	WHERE ;
	 		tTemp1.Program = Ai_Enc.Program ;
	 		AND tTemp1.Tc_ID = Ai_Enc.Tc_ID ; 
	 		AND Ai_Enc.Act_ID = Ai_Serv.Act_ID ;
	    	AND Ai_Enc.Act_Dt BETWEEN dDate_From AND dDate_To ;
 		INTO CURSOR tServed	
 		
	 	SELECT ;
			Program, ;
			SUM(IIF(New, 1, 0))      AS NewCnt, ;
			SUM(IIF(Reopened, 1, 0)) AS ReopCnt, ;
			SUM(IIF(Returned, 1, 0)) AS ReturCnt ;		
	 	FROM tServed ;
	 	INTO CURSOR tServed1 ;
	 	GROUP BY 1

&&& new closure reasons code of 6/26/01 follow
* Reasons
* jss, 7/98, add numReason; requires new "group by" clause
* jss, 6/26/01, modify code below (determining reasons and their counts) as follows: look up 
*               program enrollment closed reasons first in prg_clos.dbf (can only do this if 
*               a reason is specified in ai_prog). then, go to agency closure reasons (closcode.dbf)
* first, grab all the closed records found in ttemp1

	 	SELECT ;
	    	program, ;
			tc_id, ;
			end_dt, ;
			reason  ;
		FROM ;
			ttemp1 ;
		WHERE ;
			BETWEEN(tTemp1.End_Dt, dDate_From, dDate_To) ;
		INTO CURSOR ;
			closinper	

* now, grab the description of the reason for the closure from prg_clos
	**VT 07/14/2009 Dev Tick 5698 Changed prg_clos to new look up table closcode
   
		SELECT ;
			closinper.program, ;
			PADR('Program: '+ prg_clos.descript,60) AS reason, ;
			SUM(1) as numReason ;
		FROM ;
			closinper, ;
			closcode prg_clos ;			
		WHERE ;
			closinper.reason = prg_clos.code ;
      into Cursor t_r1;
      Group by 1, 2
      		
		SELECT ;
			closinper.program, ;
			PADR('Program: '+ 'No Reason Provided', 60) AS reason, ;
			SUM(1) as numReason ;
		FROM ;
			closinper ;
		WHERE ;
			Empty(closinper.reason) ;
		INTO CURSOR ;
			t_r2 ;
		GROUP BY 1, 2

   Select *;
   from t_r1 ;
   Union all;
   select * ;
   From t_r2 ;
   Into cursor treasons 
   
   Use in t_r1
   Use in t_r2
* now, for any other clients closed but without a program closure reason, look at agency level
* closure reasons

		ReasTally=_tally

	 	CREATE CURSOR Reasons (cProgram C(5), Reason1 C(60), Reason2 C(60), Reason3 C(60), Reason4 C(60), Reason5 C(60), numReason1 N(4), numReason2 N(4), numReason3 N(4), numReason4 N(4), numReason5 N(4))
	
      * initialize variables to be loaded into cursor "reasons"
		STORE cProg TO m.cProgram
		STORE SPACE(60) TO m.reason1, m.reason2, m.reason3, m.reason4, m.reason5
		STORE 0 TO m.numReason1, m.numReason2, m.numReason3, m.numReason4, m.numReason5
     
	 	SELECT tReasons
	 	IF ReasTally>0
		    j = 0
		 	SCAN WHILE J < 5 AND NOT EOF()
				SCATTER MEMVAR
				j = j + 1
				jj = LTRIM(STR(j))
				m.Reason&jj = m.Reason
				m.numReason&jj=m.numReason		
			ENDSCAN	
		ENDIF && reastally>0			
		SELECT Reasons
		APPEND BLANK
		GATHER MEMVAR
	ENDIF && i=1
&&& end of 6/26 code change, jss

* Summary of Client Insurance Status
* first, create a cursor with zero counts for program in ttemp1
	SELECT DISTINCT tTemp1.Program, ;
		0000 AS SelfPay, ;
		0000 AS Medicaid, ;
		0000 AS Medicare, ;
		0000 AS Private, ;
		0000 AS Adap, ;
		0000 AS Other, ;
		0000 AS Unknown ;
	FROM ;
		tTemp1 ;
	INTO CURSOR ;
	   tempcont
* jss, 11/13/03, create tempcont1 to be used for new contract ytd totals for insurance status	
	   SELECT * ;
      FROM tempcont;
      INTO CURSOR tempcont1
      
* for now we're counting just primary insurances Prim_Sec = 1	
	cCursName = "tInsStat" + STR(i,1) 			

* gives us an updatable cursor, in effect
	oApp.ReopenCur("tempcont", cCursName)

  * this cursor yields info for all clients with insurance status info entered
	SELECT tTemp1a.Program, ;
		SUM(IIF(InsType.m_instype = 0, 1, 0)) AS SelfPay, ;
		SUM(IIF(InsType.m_instype = 1, 1, 0)) AS Medicaid, ;
		SUM(IIF(InsType.m_instype = 2, 1, 0)) AS Medicare, ;
		SUM(IIF(InsType.m_instype = 3, 1, 0)) AS Private, ;
		SUM(IIF(InsType.m_instype = 4, 1, 0)) AS Adap, ;
		SUM(IIF(InsType.m_instype = 5, 1, 0)) AS Other ;
	FROM ;
		tTemp1a, ;
		InsStat, ;
		InsType, ;
		Med_Prov ;
	WHERE ;
		tTemp1a.Client_ID = InsStat.Client_ID ;
		AND Insstat.Prov_ID = Med_Prov.Prov_ID ;
		AND Med_Prov.InsType = InsType.Code ;
		AND BETWEEN(dDate_To, InsStat.Effect_Dt, IIF(!EMPTY(InsStat.Exp_Dt), InsStat.Exp_Dt, {12/31/2100})) ;
		AND InsStat.Prim_Sec = 1 ;
		AND IIF(i=1,ttemp1a.new,.t.) ;
	GROUP BY 1 ;
	INTO CURSOR tInsSt
	
	INDEX ON program TAG program

  * this cursor yields info for all clients with insurance status info NOT entered
	SELECT tTemp1a.program, ;
		COUNT(tTemp1a.client_id) AS Unknown ;
	FROM ;
		tTemp1a ;
	WHERE ;
		tTemp1a.new ;
		AND tTemp1a.client_id NOT IN ;
		    (SELECT tTemp1a.client_id FROM ttemp1a,InsStat,InsType,Med_Prov ;
		       WHERE tTemp1a.client_id=InsStat.Client_id ;
					AND Insstat.Prov_ID = Med_Prov.Prov_ID ;
					AND Med_Prov.InsType = InsType.Code ;
					AND BETWEEN(dDate_To, InsStat.Effect_Dt, IIF(!EMPTY(InsStat.Exp_Dt), InsStat.Exp_Dt, {12/31/2100})) ;
					AND InsStat.Prim_Sec = 1 ;
					AND IIF(i=1,ttemp1a.new,.t.)) ;
	GROUP BY 1 ;
   	INTO CURSOR ;
   			tNotInsSt
   
	INDEX ON program TAG program

	SELE &cCursName
	SCAN
		if seek(cprogram,'tInsSt')
			REPLACE 	SelfPay  WITH tInsSt.SelfPay	,;
						Medicaid WITH tInsSt.Medicaid	,;
						Medicare WITH tInsSt.Medicare	,;
						Private  WITH tInsSt.Private	,;
						Adap     WITH tInsSt.Adap  	,;
						Other		WITH tInsSt.Other  	 
		ENDIF				
		if seek(cprogram,'tNotInsSt')
			REPLACE	Unknown  WITH tNotInsSt.Unknown 
		ENDIF	
	ENDSCAN
	
	USE IN tInsSt
	USE IN tNotInsSt
	
* jss, 11/13/03, add code here to count contract ytd totals for insurance status
  IF i = 2	
	oApp.ReopenCur("tempcont1", "conins")

	SELECT tTemp1a.Program, ;
		SUM(IIF(InsType.m_instype = 0, 1, 0)) AS SelfPay, ;
		SUM(IIF(InsType.m_instype = 1, 1, 0)) AS Medicaid, ;
		SUM(IIF(InsType.m_instype = 2, 1, 0)) AS Medicare, ;
		SUM(IIF(InsType.m_instype = 3, 1, 0)) AS Private, ;
		SUM(IIF(InsType.m_instype = 4, 1, 0)) AS Adap, ;
		SUM(IIF(InsType.m_instype = 5, 1, 0)) AS Other ;
	FROM ;
		tTemp1a, ;
		InsStat, ;
		InsType, ;
		Med_Prov ;
	WHERE ;
		tTemp1a.Client_ID = InsStat.Client_ID ;
		AND Insstat.Prov_ID = Med_Prov.Prov_ID ;
		AND Med_Prov.InsType = InsType.Code ;
		AND BETWEEN(dDate_To, InsStat.Effect_Dt, IIF(!EMPTY(InsStat.Exp_Dt), InsStat.Exp_Dt, {12/31/2100})) ;
		AND InsStat.Prim_Sec = 1 ;
		AND (ttemp1a.new OR ttemp1a.reopened) ;
	GROUP BY 1 ;
	INTO CURSOR tconins
	
	INDEX ON program TAG program

	SELECT tTemp1a.program, ;
		COUNT(tTemp1a.client_id) AS Unknown ;
	FROM ;
		tTemp1a ;
	WHERE ;
		(tTemp1a.new OR ttemp1a.reopened) ;
		AND tTemp1a.client_id NOT IN ;
		    (SELECT tTemp1a.client_id FROM ttemp1a,InsStat,InsType,Med_Prov ;
		       WHERE tTemp1a.client_id=InsStat.Client_id ;
					AND Insstat.Prov_ID = Med_Prov.Prov_ID ;
					AND Med_Prov.InsType = InsType.Code ;
					AND BETWEEN(dDate_To, InsStat.Effect_Dt, IIF(!EMPTY(InsStat.Exp_Dt), InsStat.Exp_Dt, {12/31/2100})) ;
					AND InsStat.Prim_Sec = 1 ;
					AND (ttemp1a.new OR ttemp1a.reopened)) ;
	GROUP BY 1 ;
   	INTO CURSOR ;
   			tNotconins
   
	INDEX ON program TAG program

	SELE conins
	SCAN
		if seek(cprogram,'tconins')
			REPLACE 	SelfPay  WITH tconins.SelfPay	,;
						Medicaid WITH tconins.Medicaid	,;
						Medicare WITH tconins.Medicare	,;
						Private  WITH tconins.Private	,;
						Adap     WITH tconins.Adap  	,;
						Other		WITH tconins.Other  	 
		ENDIF				
		if seek(cprogram,'tNotconins')
			REPLACE	Unknown  WITH tNotconins.Unknown 
		ENDIF	
	ENDSCAN
	
	USE IN tconins
	USE IN tNotconins
  ENDIF	
*** end of 11/13/03 addition for contract ytd insurance status	

* Summary of Client HIV Status

	cCursName = "tHivStat" + STR(i,1) 		
* jss, 2/11/02, comment out code above, modify below as per CADR requirements: add CDCAIDS logic (hivstat.code='10')
* jss, 11/13/03, add new codes 11 and 12
	SELECT tTemp1a.program, ;
		SUM(IIF(Hstat.Hiv_Pos AND Hstat.code <> '10', 1, 0)) 			AS HivPos, ; 
		SUM(IIF(Hstat.code = '10', 1, 0)) 									AS CDCAIDS, ; 
		SUM(IIF(INLIST(Hivstat.Hivstatus,'07','08','09'), 1, 0)) 	AS HivAff, ;
		SUM(IIF(INLIST(Hivstat.Hivstatus,'03','11'), 1, 0)) 			AS HivNeg,;
		SUM(IIF(INLIST(Hivstat.Hivstatus,'04','06', '12'), 1, 0)) 	AS Other ;
	FROM ;
		tTemp1a, ;
		Hivstat, ;
		Hstat ;
	WHERE ;
		tTemp1a.Tc_ID = Hivstat.Tc_ID ;
		AND Hivstat.Effect_Dt IN ;
			(SELECT MAX(Effect_Dt) FROM HivStat D ;
				WHERE d.Effect_Dt <= dDate_To ;
					AND HivStat.Tc_ID = d.Tc_ID) ;
		AND Hivstat.Hivstatus = Hstat.Code ;
		AND IIF(i=1,ttemp1a.new,.t.) ;
	INTO CURSOR &cCursName ;
	GROUP BY 1			

* jss, 11/13/03, add code here for contract ytd hiv statuses
  IF i = 2
	SELECT tTemp1a.program, ;
		SUM(IIF(Hstat.Hiv_Pos AND Hstat.code <> '10', 1, 0)) 			AS HivPos, ; 
		SUM(IIF(Hstat.code = '10', 1, 0)) 									AS CDCAIDS, ; 
		SUM(IIF(INLIST(Hivstat.Hivstatus,'07','08','09'), 1, 0)) 	AS HivAff, ;
		SUM(IIF(INLIST(Hivstat.Hivstatus,'03','11'), 1, 0)) 			AS HivNeg,;
		SUM(IIF(INLIST(Hivstat.Hivstatus,'04','06', '12'), 1, 0)) 	AS Other ;
	FROM ;
		tTemp1a, ;
		Hivstat, ;
		Hstat ;
	WHERE ;
		tTemp1a.Tc_ID = Hivstat.Tc_ID ;
		AND Hivstat.Effect_Dt IN ;
			(SELECT MAX(Effect_Dt) FROM HivStat D ;
				WHERE d.Effect_Dt <= dDate_To ;
					AND HivStat.Tc_ID = d.Tc_ID) ;
		AND Hivstat.Hivstatus = Hstat.Code ;
		AND (ttemp1a.new or ttemp1a.reopened) ;
	INTO CURSOR conhiv ;
	GROUP BY 1	
  ENDIF			
* jss, 11/13/03, end of code addition for contract ytd hiv statuses

* jss, 11/13/03, add new code '12' to go along with '04'	
	cCursName = "tHivStCh" + STR(i,1) 	
	IF i = 1		
		SELECT ;
			a.program, ;
			SUM(IIF(c.Hiv_Pos, 1, 0)) AS HivPos, ;
			SUM(IIF(!c.Hiv_Pos AND b.HivStatus <> '04' AND b.HivStatus <> '12', 1, 0)) AS HivNeg ;
		FROM ;
			 tTemp1a A, ;	
			 HivStat B, ;
			 Hstat C ;
		WHERE ;
			a.Tc_ID = b.Tc_ID ;
			AND b.HivStatus = c.Code ;
			AND b.Effect_Dt IN (SELECT MAX(Effect_Dt) FROM HivStat D ;
									WHERE d.Effect_Dt <= dDate_To ;
										AND b.Tc_ID = d.Tc_ID) ;
			AND EXISTS(SELECT * FROM HivStat E ;
							WHERE e.Tc_ID = b.Tc_ID ;
								AND (e.HivStatus = '04' OR e.HivStatus = '12')) ;			
		INTO CURSOR &cCursName ;
		GROUP BY 1
	ENDIF

	* Summary of Client TB Status
	
	cCursName = "tTbRes" + STR(i,1) 	
	SELECT tTemp1a.program, ;
		SUM(IIF(!EMPTY(Tbstatus.PpdRes) AND Test_Res.Ppd_Pos, 1, 0)) AS PpdPos ;
	FROM ;
		tTemp1a, ;
		Tbstatus, ;
		Test_Res ;
	WHERE ;
		tTemp1a.Tc_ID = Tbstatus.Tc_ID ;
		AND Tbstatus.effect_dt <= dDate_To ;
		AND Tbstatus.PpdRes = Test_Res.Code ;
		AND IIF(i=1,ttemp1a.new,.t.) ;
	INTO CURSOR &cCursName ;
	GROUP BY 1			
	
	cCursName = "tTBAnerg" + STR(i,1) 	
	SELECT tTemp1a.program, ;
		SUM(IIF(Tbstatus.Panergic = 1, 1, 0)) AS Anergic ;
	FROM ;
		tTemp1a, ;
		Tbstatus ;
	WHERE ;
		tTemp1a.Tc_ID = Tbstatus.Tc_ID ;
		AND Tbstatus.effect_dt <= dDate_To ;
		AND IIF(i=1,ttemp1a.new,.t.) ;
	INTO CURSOR &cCursName ;
	GROUP BY 1			

	cCursName = "tTbTreat" + STR(i,1) 	
	SELECT tTemp1a.program, ;
		SUM(IIF(INLIST(Tbstatus.Treatment,'01','02'), 1, 0)) AS DOPT, ;
		SUM(IIF(INLIST(Tbstatus.Treatment,'03','04'), 1, 0)) AS DOT ;
	FROM ;
		tTemp1a, ;
		Tbstatus, ;
		treatmen ;
	WHERE ;
		tTemp1a.Tc_ID = Tbstatus.Tc_ID ;
		AND Tbstatus.effect_dt <= dDate_To ;
		AND	Tbstatus.Treatment = Treatmen.code ;	
		AND IIF(i=1,ttemp1a.new,.t.) ;
	INTO CURSOR &cCursName ;
	GROUP BY 1			
	
* jss, 11/13/03, add code for "total clients enrolled contract ytd" for tb statuses
  IF i = 2	
	SELECT tTemp1a.program, ;
		SUM(IIF(!EMPTY(Tbstatus.PpdRes) AND Test_Res.Ppd_Pos, 1, 0)) AS PpdPos ;
	FROM ;
		tTemp1a, ;
		Tbstatus, ;
		Test_Res ;
	WHERE ;
		tTemp1a.Tc_ID = Tbstatus.Tc_ID ;
		AND Tbstatus.effect_dt <= dDate_To ;
		AND Tbstatus.PpdRes = Test_Res.Code ;
		AND (ttemp1a.new OR ttemp1a.reopened) ;
	INTO CURSOR conres2 ;
	GROUP BY 1			
	
	SELECT tTemp1a.program, ;
		SUM(IIF(INLIST(Tbstatus.Treatment,'01','02'), 1, 0)) AS DOPT, ;
		SUM(IIF(INLIST(Tbstatus.Treatment,'03','04'), 1, 0)) AS DOT ;
	FROM ;
		tTemp1a, ;
		Tbstatus, ;
		treatmen ;
	WHERE ;
		tTemp1a.Tc_ID = Tbstatus.Tc_ID ;
		AND Tbstatus.effect_dt <= dDate_To ;
		AND	Tbstatus.Treatment = Treatmen.code ;	
		AND (ttemp1a.new OR ttemp1a.reopened) ;
	INTO CURSOR contreat2 ;
	GROUP BY 1	
  ENDIF			
* end of 11/13/03 change for contract ytd for tb statuses

NEXT	
* should be selecting ytd version of ttemp1 here to ensure production of report to show ytd #'s 
* even if no current month numbers in system
SELECT ;
	cProg	 AS program, ;
	Descript AS ContrDes, ;
   cMonthYear as cMonthYear, ;
   cDate  as cDate, ;
   cTime  as cTime, ;
   cAgc_Name as cAgc_Name ; 
FROM ContrInf ;
WHERE ;
	cContract = ContrInf.Cid ;
INTO CURSOR Final

SELECT tServed1
INDEX ON Program TAG Program
SELECT tStatist1
INDEX ON Program TAG Program
SELECT tStatist2
INDEX ON Program TAG Program
SELECT tInsStat1
INDEX ON Program TAG Program
SELECT tInsStat2
INDEX ON Program TAG Program
SELECT tHivStat1
INDEX ON Program TAG Program
SELECT tHivStat2
INDEX ON Program TAG Program
SELECT tHivStCh1
INDEX ON Program TAG Program
SELECT tTBRes1
INDEX ON Program TAG Program
SELECT tTBRes2
INDEX ON Program TAG Program
SELECT tTBAnerg1
INDEX ON Program TAG Program
SELECT tTBAnerg2
INDEX ON Program TAG Program
SELECT tTBTreat1
INDEX ON Program TAG Program
SELECT tTBTreat2
INDEX ON Program TAG Program
SELECT Reasons
INDEX ON cProgram TAG Program
* jss, 11/13/03, index new cursors for contract ytd totals
SELECT conins
INDEX ON Program TAG Program
SELECT conhiv
INDEX ON Program TAG Program
SELECT conres2
INDEX ON Program TAG Program
SELECT contreat2
INDEX ON Program TAG Program

SELECT Final
SET RELATION TO Program INTO tServed1
SET RELATION TO Program INTO tStatist1 ADDITIVE
SET RELATION TO Program INTO tStatist2 ADDITIVE
SET RELATION TO Program INTO tInsStat1 ADDITIVE
SET RELATION TO Program INTO tInsStat2 ADDITIVE
SET RELATION TO Program INTO tHivStat1 ADDITIVE	
SET RELATION TO Program INTO tHivStat2 ADDITIVE
SET RELATION TO Program INTO tHivStCh1 ADDITIVE
SET RELATION TO Program INTO tTBRes1 ADDITIVE
SET RELATION TO Program INTO tTBRes2 ADDITIVE
SET RELATION TO Program INTO tTBAnerg1 ADDITIVE
SET RELATION TO Program INTO tTBAnerg2 ADDITIVE
SET RELATION TO Program INTO tTBTreat1 ADDITIVE
SET RELATION TO Program INTO tTBTreat2 ADDITIVE
SET RELATION TO Program INTO Reasons ADDITIVE
SET RELATION TO Program INTO conins   ADDITIVE
SET RELATION TO Program INTO conhiv   ADDITIVE
SET RELATION TO Program INTO conres2  ADDITIVE
SET RELATION TO Program INTO contreat2 ADDITIVE

* make sure there are clients to report on
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
                       'Section IV: Monthly Program Report' as nulrptname ,;
                       'Table IV - A: Summary of Client Enrollment and Caseload' as nulrptnam1 ,;
                       'Table IV - B: Summary of Client Insurance Status' as nulrptnam2 ,;
                       'Table IV - C: Summary of Client HIV Status' as nulrptnam3 ,;
                       'Table IV - D: Summary of Client TB Status' as nulrptnam4,  ;
                       'Multi-Module HIV Prev. Services Program' as cType, ;
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
         gcRptName = 'rpt_mhra_cls'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_mhra_cls  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_mhra_cls', 1, 2)
          Endcase
   Endif       
Endif
Return
****************************
Function clean_data

IF USED("tnew")
   USE IN ("tnew")
EndIf

IF USED("ytdfrom")
   USE IN ("ytdfrom")
EndIf

IF USED("tReop")
   USE IN ("tReop")
EndIf

IF USED("tRetu")
   USE IN ("tRetu")
EndIf

IF USED("tTemp1")
	USE IN ("tTemp1")
ENDIF

IF USED("tTemp1a")
   USE IN ("tTemp1a")
EndIf

IF USED("tTemp2")
	USE IN ("tTemp2")
ENDIF

IF USED("closinper")
   USE IN ("closinper")
EndIf

IF USED("tStatist1")
	USE IN ("tStatist1")
ENDIF

IF USED("tStatist2")
	USE IN ("tStatist2")
ENDIF

IF USED("tInsStat1")
	USE IN ("tInsStat1")
ENDIF

IF USED("tInsStat2")
	USE IN ("tInsStat2")
ENDIF

IF USED("tHivStat1")
	USE IN ("tHivStat1")
ENDIF

IF USED("tHivStat2")
	USE IN ("tHivStat2")
ENDIF

IF USED("tHivStCh1")
	USE IN ("tHivStCh1")
ENDIF

IF USED("tTBRes1")
	USE IN ("tTBRes1")
ENDIF

IF USED("tTBRes2")
	USE IN ("tTBRes2")
ENDIF

IF USED("tTBAnerg1")
	USE IN ("tTBAnerg1")
ENDIF

IF USED("tTBAnerg2")
	USE IN ("tTBAnerg2")
ENDIF

IF USED("tTBTreat1")
	USE IN ("tTBTreat1")
ENDIF

IF USED("tTBTreat2")
	USE IN ("tTBTreat2")
ENDIF

IF USED("tServed")
	USE IN ("tServed")
ENDIF

IF USED("tServed1")
	USE IN ("tServed1")
ENDIF

IF USED("tReasons")
	USE IN ("tReasons")
ENDIF

IF USED("tReasons1")
	USE IN ("tReasons1")
ENDIF

IF USED("Reasons")
	USE IN ("Reasons")
ENDIF

IF USED("ytdundup")
	USE IN ("ytdundup")
ENDIF

IF USED("conundup")
	USE IN ("conundup")
ENDIF

IF USED("conins")
	USE IN ("conins")
ENDIF

IF USED("conhiv")
	USE IN ("conhiv")
ENDIF

IF USED("conres2")
	USE IN ("conres2")
ENDIF

IF USED("contreat2")
	USE IN ("contreat2")
ENDIF

IF USED("tempcont")
	USE IN ("tempcont")
ENDIF

IF USED("tempcont1")
	USE IN ("tempcont1")
ENDIF

IF USED("tAi_Prog")
   USE IN ("tAi_Prog")
EndIf

IF USED("tAi_Prog1a")
   USE IN ("tAi_Prog1a")
EndIf

IF USED("tAi_Prog1b")
   USE IN ("tAi_Prog1b")
EndIf

IF USED("Final")
	USE IN ("Final")
ENDIF

RETURN

*******************
FUNCTION Electronic
*******************
* jss, 5/13/04, add code here to write to electronic mpr table (mprivad)

m.user_id = gcworker
m.dt = DATE()
m.tm = TIME()
m.agency=gcagency
m.contract=cContract

m.begincnt   = tstatist1.begincnt
m.newcnt     = tstatist1.newcnt
m.reopcnt    = tstatist1.reopcnt
m.totcnt     = tstatist1.begincnt + tstatist1.newcnt + tstatist1.reopcnt
m.closeinper = tstatist1.closeinper
m.reason1    = reasons.reason1
m.reason2    = reasons.reason2
m.reason3    = reasons.reason3
m.reason4    = reasons.reason4
m.reason5    = reasons.reason5
m.numreason1 = reasons.numreason1
m.numreason2 = reasons.numreason2
m.numreason3 = reasons.numreason3
m.numreason4 = reasons.numreason4
m.numreason5 = reasons.numreason5
m.actenrend  = tstatist1.begincnt + tstatist1.newcnt + tstatist1.reopcnt - tstatist1.closeinper
m.returcnt   = tserved1.returcnt
m.servcnt    = tserved1.newcnt +tserved1.reopcnt + returcnt
m.totenrytd  = ytdundup.ytd_undup
m.totclosytd = tstatist2.closeinper
m.totconytd  = conundup.ytd_undup
m.n_selfpay  = tinsstat1.selfpay
m.t_selfpay  = tinsstat2.selfpay
m.c_selfpay  = conins.selfpay
m.n_medicaid = tinsstat1.medicaid
m.t_medicaid = tinsstat2.medicaid
m.c_medicaid = conins.medicaid
m.n_medicare = tinsstat1.medicare
m.t_medicare = tinsstat2.medicare
m.c_medicare = conins.medicare
m.n_private  = tinsstat1.private
m.t_private  = tinsstat2.private
m.c_private  = conins.private
m.n_adap     = tinsstat1.adap
m.t_adap     = tinsstat2.adap
m.c_adap     = conins.adap
m.n_insother = tinsstat1.other
m.t_insother = tinsstat2.other
m.c_insother = conins.other
m.n_insunkn  = tinsstat1.unknown
m.t_insunkn  = tinsstat2.unknown
m.c_insunkn  = conins.unknown
m.n_instotal = tinsstat1.selfpay + tinsstat1.medicaid + tinsstat1.medicare + tinsstat1.private + tinsstat1.adap + tinsstat1.other + tinsstat1.unknown
m.t_instotal = tinsstat2.selfpay + tinsstat2.medicaid + tinsstat2.medicare + tinsstat2.private + tinsstat2.adap + tinsstat2.other + tinsstat2.unknown
m.c_instotal = conins.selfpay + conins.medicaid + conins.medicare + conins.private + conins.adap + conins.other + conins.unknown
m.n_hivpos   = thivstat1.hivpos
m.t_hivpos   = thivstat2.hivpos
m.c_hivpos   = conhiv.hivpos
m.n_cdcaids  = thivstat1.cdcaids
m.t_cdcaids  = thivstat2.cdcaids
m.c_cdcaids  = conhiv.cdcaids
m.n_hivaff   = thivstat1.hivaff
m.t_hivaff   = thivstat2.hivaff
m.c_hivaff   = conhiv.hivaff
m.n_hivother = thivstat1.other
m.t_hivother = thivstat2.other
m.c_hivother = conhiv.other
m.n_hivtotal = thivstat1.hivpos + thivstat1.cdcaids + thivstat1.hivaff + thivstat1.other
m.t_hivtotal = thivstat2.hivpos + thivstat2.cdcaids + thivstat2.hivaff + thivstat2.other
m.c_hivtotal = conhiv.hivpos + conhiv.cdcaids + conhiv.hivaff + conhiv.other
m.ch_hivpos  = thivstch1.hivpos
m.ch_hivneg  = thivstch1.hivneg
m.n_ppdpos   = ttbres1.ppdpos
m.t_ppdpos   = ttbres2.ppdpos
m.c_ppdpos   = conres2.ppdpos
m.n_dot      = ttbtreat1.dot
m.t_dot      = ttbtreat2.dot
m.c_dot      = contreat2.dot
m.n_dopt     = ttbtreat1.dopt
m.t_dopt     = ttbtreat2.dopt
m.c_dopt     = contreat2.dopt

SELECT 0
USE mprivad EXCL
ZAP
	
APPEND BLANK
GATHER MEMVAR

USE IN mprivad

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
USE mprivad EXCL
ZAP
APPEND BLANK
GATHER MEMVAR
USE IN mprivad
RETURN

