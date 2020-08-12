************************************************************************
* This program will import PEMS2URS.XML file
* It will place it's contents into pems2usr and sessions tables
* It will wipe out those tables prior to import
************************************************************************
LOCAL nSessions, m.dt, m.tm, nDone, nPctHold, nPct

***********************************************************************************
* 1. Find and open file
***********************************************************************************
oXMLDoc = CreateObject('Microsoft.XMLDOM')

cFileName = GetFile("xml", '', '', 0, 'Find PEMS2URS File')

IF EMPTY(cFileName)
	RETURN
ENDIF

oThermo = createobject('thermobox', "Importing PEMS data ...", "")
oThermo.show
oThermo.refresh('Opening tables...', 0)
=OpenFile("pems2urs", "pems2urs_i")
=OpenFile("sessions")
=OpenFile("ai_contract", "ai_contrac")
=OpenFile("priority_pop", "cp_id")
=OpenFile("target_pop")
=OpenFile("intervention", "interventi")
=OpenFile("model", "model_id")

***********************************************************************************
* Prepare temp working environment - updateable cursors from original files
***********************************************************************************
SELECT * ;
FROM pems2urs ;
INTO CURSOR pems2urs_cur READWRITE ;
WHERE .f.

SELECT * ;
FROM sessions ;
INTO CURSOR sessions_cur READWRITE ;
WHERE .f. 

SELECT * ;
FROM ai_contract ;
INTO CURSOR ai_contract_cur READWRITE ;
WHERE .f.

SELECT * ;
FROM priority_pop ;
INTO CURSOR priority_pop_cur READWRITE ;
WHERE .f. 

SELECT * ;
FROM target_pop ;
INTO CURSOR target_pop_cur READWRITE ;
WHERE .f. 

SELECT * ;
FROM intervention ;
INTO CURSOR intervention_cur READWRITE ;
WHERE .f. 

SELECT * ;
FROM model ;
INTO CURSOR model_cur READWRITE ;
WHERE .f. 

m.dt = DATE()
m.tm = LEFT(TIME(), 5)

***********************************************************************************
* 2. Read XML into document
***********************************************************************************
oThermo.refresh('Reading XML', 0)
		
oXMLDoc.load(cFileName)
topElement = oXMLDoc.documentElement

************************************************************************
* PEMS2URS
aP2UNodes = topElement.selectNodes("PEMS2URS")
nDone = 0
nPctHold = 0
For Each xmlNode In aP2UNodes
	*--update thermometer bar
	nDone = nDone + 1
	nPct = Round((nDone/aP2UNodes.length) * 100, 0)

	If nPctHold <> nPct  && Update thermo every 1%
		oThermo.Refresh('PEMS2URS', nPct)
		nPctHold = nPct
	EndIf 

	INSERT INTO pems2urs_cur ( ;
		pems2urs_id, ;
		agency_id, ;
		contract_id, ;
		prog_id, ;
		model_id, ;
		intervention_id, ;
		dbdc, ;
		serv_cat, ;
		enc_id, ;
		service_id, ;
		user_id, ;
		dt, ;
		tm,;
      StartDate,;
      EndDate,;
      is_active;
	) ;
	VALUES (;
	    xmlNode.selectSingleNode("ID").text, ;
	    xmlNode.selectSingleNode("Agency_ID").text, ;
	    Val(xmlNode.selectSingleNode("Contract_id").text), ;
	    xmlNode.selectSingleNode("Prog_ID").text, ;
	    Val(xmlNode.selectSingleNode("Model_ID").text), ;
	    Val(xmlNode.selectSingleNode("Intervention_ID").text), ;
	    Lower(xmlNode.selectSingleNode("DBDC").text) == 'true', ;
	    xmlNode.selectSingleNode("Serv_Cat").text, ;
	    Val(xmlNode.selectSingleNode("Enc_id").text), ;
	    Val(xmlNode.selectSingleNode("Service_id").text), ;
	    gcWorker, ;
	    m.dt, ;
	    m.tm, ;       
       Ttod(Ctot(xmlNode.selectSingleNode("StartDate").text)), ;
       Ttod(Ctot(xmlNode.selectSingleNode("EndDate").text)), ;
       VAL(xmlNode.selectSingleNode("Active").text);
	)

EndFor 

************************************************************************
* Sessions 
aSessionNodes = topElement.selectNodes("Sessions")
nDone = 0
nPctHold = 0
FOR EACH xmlNode IN aSessionNodes

*!*--update thermometer bar
	nDone = nDone + 1
	nPct = ROUND((nDone/aSessionNodes.length) * 100, 0)

	IF nPctHold <> nPct  && Update thermo every 1%
		oThermo.refresh('Sessions', nPct)
		nPctHold = nPct
	ENDIF

	oSessionsXMLNode = xmlNode.selectSingleNode("Sessions")

*!* Replaced by below code PB:05/11/2007
*!*   	IF ISNULL(oSessionsXMLNode)
*!*   		nSessions = 0
*!*   	ELSE
*!*   		nSessions = VAL(oSessionsXMLNode.text)
*!*   	ENDIF

*!*   	INSERT INTO sessions_cur ( ;
*!*   		agency_id, ;
*!*   		contract_id, ;
*!*   		prog_id, ;
*!*   		model_id, ;
*!*   		intervention_id, ;
*!*   		sessions, ;
*!*   		user_id, ;
*!*   		dt, ;
*!*   		tm ;
*!*   	) ;
*!*   	VALUES (;
*!*   		xmlNode.selectSingleNode("Agency_ID").text, ;
*!*   		VAL(xmlNode.selectSingleNode("Contract_ID").text), ;
*!*   		xmlNode.selectSingleNode("Prog_ID").text, ;
*!*   		VAL(xmlNode.selectSingleNode("Model_ID").text), ;
*!*   		VAL(xmlNode.selectSingleNode("Intervention_id").text), ;
*!*   		nSessions , ;
*!*   		gcWorker, ;
*!*   		m.dt, ;
*!*   		m.tm ;
*!*   	)


* BK 5/10/2007 - changed capitalization of fields to match those in XML file
*!*  VAL(xmlNode.selectSingleNode("Contract_id").text), ;
*!*  VAL(xmlNode.selectSingleNode("Intervention_ID").text), ;

*!* PB: 05/10/2007 Remove previous code and uncomment once we get new XML file.
   Insert Into sessions_cur ;
   ( ;
      agency_id, ;
      contract_id, ;
      conno,;
      prog_id, ;
      model_id, ;
      intervention_id, ;
      sessions, ;
      user_id, ;
      dt, ;
      tm ;
   ) ;
   Values (;
      xmlNode.selectSingleNode("Agency_ID").text, ;
      VAL(xmlNode.selectSingleNode("Contract_ID").text), ;
      xmlNode.selectSingleNode("CONNO").text, ;
      xmlNode.selectSingleNode("Prog_ID").text, ;
      VAL(xmlNode.selectSingleNode("Model_ID").text), ;
      VAL(xmlNode.selectSingleNode("Intervention_id").text), ;
      VAL(xmlNode.selectSingleNode("Sessions").text), ;
      gcWorker, ;
      m.dt, ;
      m.tm ;
   )

EndFor

************************************************************************
* Contracts 
aContractNodes = topElement.selectNodes("Contract")
nDone = 0
nPctHold = 0
FOR EACH xmlNode IN aContractNodes
*!*	  <Contract>
*!*	    <Contract_ID>57</Contract_ID>
*!*	    <Agency_ID>NJAAB</Agency_ID>
*!*	    <CONNO>209503    </CONNO>
*!*	    <StartDate>2005-06-01T00:00:00.0000000-04:00</StartDate>
*!*	    <EndDate>2006-04-30T00:00:00.0000000-04:00</EndDate>
*!*	    <ContractAmt>193000.0000</ContractAmt>
*!*	  </Contract>


	*--update thermometer bar
	nDone = nDone + 1
	nPct = ROUND((nDone/aContractNodes.length) * 100, 0)

	IF nPctHold <> nPct  && Update thermo every 1%
		oThermo.refresh('Contracts', nPct)
		nPctHold = nPct
	ENDIF

   * PB: Changed Contract_ID to Contract_id 05/11/2007
	INSERT INTO ai_contract_cur ( ;
      ai_contract_id, ;
      agency_id, ;
      conno, ;
      start_date, ;
      end_date, ;
      contract_amt, ;
      user_id, ;
      dt, ;
      tm ;
	) ;
	VALUES (;
      Val(xmlNode.selectSingleNode("Contract_id").text), ;
      xmlNode.selectSingleNode("Agency_ID").text, ;
      xmlNode.selectSingleNode("CONNO").text, ;
      Ttod(Ctot(xmlNode.selectSingleNode("StartDate").text)),;
      Ttod(Ctot(xmlNode.selectSingleNode("EndDate").text)), ;
      Val(xmlNode.selectSingleNode("ContractAmt").text), ;
      gcWorker, ;
      m.dt, ;
      m.tm ;
	)
ENDFOR


************************************************************************
* Priority Populations
aPPNodes = topElement.selectNodes("PriorityPop")
nDone = 0
nPctHold = 0
FOR EACH xmlNode IN aPPNodes
*!*	<PriorityPop>
*!*	  <cp_id>4</cp_id> 
*!*	  <cpname>Heterosexuals</cpname> 
*!*	</PriorityPop>

	*--update thermometer bar
	nDone = nDone + 1
	nPct = ROUND((nDone/aPPNodes.length) * 100, 0)

	IF nPctHold <> nPct  && Update thermo every 1%
		oThermo.refresh('Priority Populations', nPct)
		nPctHold = nPct
	ENDIF
   
   * PB: 05/11/2007 changed caps on cp_ID
   INSERT INTO priority_pop_cur ( ;
		cp_id, ;
		cp_name, ;
		user_id, ;
		dt, ;
		tm ;
	) ;
	VALUES (;
		VAL(xmlNode.selectSingleNode("cp_ID").text), ;
		xmlNode.selectSingleNode("cpname").text, ;
	   gcWorker, ;
	   m.dt, ;
	   m.tm ;
	)
ENDFOR

************************************************************************
* Target Populations
aTPNodes = topElement.selectNodes("TargetPop")

nDone = 0
nPctHold = 0
FOR EACH xmlNode IN aTPNodes 
* CONNO- Contract_ID - ???
*!*	  <TargetPop>
*!*	    <Agency_ID>CCAA1</Agency_ID>
*!*	    <CONNO>172703    </CONNO>
*!*	    <Prog_ID>ABAAG</Prog_ID>
*!*	    <Model_ID>21</Model_ID>
*!*	    <Intervention_ID>6</Intervention_ID>
*!*	    <cp_id>2</cp_id>
*!*	    <clients>432</clients>
*!*	  </TargetPop>


*!*     05/24/2007 PB: New fields
*!*     <TargetPop>
*!*       <Agency_ID>KZAAB</Agency_ID>
*!*       <Contract_ID>35357</Contract_ID>
*!*       <CONNO>C016164G</CONNO>
*!*       <Prog_ID>KZAAC</Prog_ID>
*!*       <Model_ID>3576</Model_ID>
*!*       <Intervention_id>3530</Intervention_id>
*!*       <cp_id>3513</cp_id>
*!*       <clients>7</clients>
*!*     </TargetPop>


	*--update thermometer bar
	nDone = nDone + 1
	nPct = ROUND((nDone/aTPNodes.length) * 100, 0)

	IF nPctHold <> nPct  && Update thermo every 1%
		oThermo.refresh('Target Populations', nPct)
		nPctHold = nPct
	ENDIF

	INSERT INTO target_pop_cur ( ;
		agency_id, ;
		contract_id, ;
      conno,;
		prog_id, ;
		model_id, ;
		intervention_id, ;
		cp_id, ;
		clients, ;
		user_id, ;
		dt, ;
		tm ;
	) ;
	VALUES (;
	   xmlNode.selectSingleNode("Agency_ID").text, ;
		VAL(xmlNode.selectSingleNode("Contract_ID").text), ;
      xmlNode.selectSingleNode("CONNO").text, ;
	   xmlNode.selectSingleNode("Prog_ID").text, ;
	   VAL(xmlNode.selectSingleNode("Model_ID").text), ;
	   VAL(xmlNode.selectSingleNode("Intervention_id").text), ;
	   VAL(xmlNode.selectSingleNode("cp_id").text), ;
	   VAL(xmlNode.selectSingleNode("clients").text), ;
	   gcWorker, ;
	   m.dt, ;
	   m.tm ;
	)
ENDFOR

************************************************************************
* Model
aModelNodes = topElement.selectNodes("Model")

nDone = 0
nPctHold = 0
FOR EACH xmlNode IN aModelNodes 
*!*	  <Model>
*!*	    <Model_ID>21</Model_ID>
*!*	    <ModelName>HIV C&amp;T</ModelName>
*!*	  </Model>

	*--update thermometer bar
	nDone = nDone + 1
	nPct = ROUND((nDone/aModelNodes.length) * 100, 0)

	IF nPctHold <> nPct  && Update thermo every 1%
		oThermo.refresh('Model LUT values', nPct)
		nPctHold = nPct
	ENDIF

   *!* PB 05/11/2007 changed caps on Model_ID
	INSERT INTO model_cur ( ;
		model_id, ;
		modelname, ;
		user_id, ;
		dt, ;
		tm ;
	) ;
	VALUES (;
	    VAL(xmlNode.selectSingleNode("Model_id").text), ;
	    xmlNode.selectSingleNode("ModelName").text, ;
	    gcWorker, ;
	    m.dt, ;
	    m.tm ;
	)
ENDFOR

************************************************************************
* Intervention
aInterventionNodes = topElement.selectNodes("Intervention")

nDone = 0
nPctHold = 0
FOR EACH xmlNode IN aInterventionNodes 
*!*	  <Intervention>
*!*	    <Intervention_ID>25</Intervention_ID>
*!*	    <InterventionName>Outreach neg/unknown (CAPC)</InterventionName>
*!*	  </Intervention>

	*--update thermometer bar
	nDone = nDone + 1
	nPct = ROUND((nDone/aInterventionNodes.length) * 100, 0)

	IF nPctHold <> nPct  && Update thermo every 1%
		oThermo.refresh('Intervention LUT values', nPct)
		nPctHold = nPct
	ENDIF

	INSERT INTO intervention_cur ( ;
		intervention_id, ;
		name, ;
		user_id, ;
		dt, ;
		tm ;
	) ;
	VALUES (;
	    VAL(xmlNode.selectSingleNode("Intervention_ID").text), ;
	    xmlNode.selectSingleNode("InterventionName").text, ;
	    gcWorker, ;
	    m.dt, ;
	    m.tm ;
	)
ENDFOR

***********************************************************************************
* Update files from temp environment. Filter by only this agency
***********************************************************************************
oThermo.refresh('Updating Tables', 90)

* Model
SELECT model_cur
SCAN
	SCATTER memvar
	IF SEEK(m.model_id, 'model')
		SELECT model
		GATHER memvar
		SELECT model_cur
	ELSE
		INSERT INTO model FROM memvar
	ENDIF
ENDSCAN

* Intervention
SELECT intervention_cur
SCAN
	SCATTER MEMVAR
 
	IF SEEK(m.intervention_id, 'intervention')
		SELECT intervention
		GATHER MEMVAR FIELDS intervention_id, name, user_id, dt, tm
		SELECT intervention_cur
	ELSE
		INSERT INTO intervention FROM memvar
	ENDIF
ENDSCAN

* priority_pop
SELECT priority_pop_cur
SCAN
	SCATTER memvar
	IF SEEK(m.cp_id, 'priority_pop')
		SELECT priority_pop
		GATHER memvar
		SELECT priority_pop_cur
	ELSE
		INSERT INTO priority_pop FROM memvar
	ENDIF
ENDSCAN

* ai_contract
SELECT ai_contract_cur
SCAN FOR agency_id = gcAgency
	SCATTER MEMVAR 
	IF SEEK(m.ai_contract_id, 'ai_contract')
		SELECT ai_contract
		GATHER MEMVAR FIELDS EXCEPT ai_contract_id
		SELECT ai_contract_cur
	ELSE
		INSERT INTO ai_contract FROM MEMVAR 
	ENDIF
ENDSCAN

* sessions
SELECT sessions_cur
SCAN FOR agency_id = gcAgency
	SCATTER MEMVAR FIELDS EXCEPT sessions_id
	SELECT sessions
	LOCATE FOR 	;
		contract_id = m.contract_id AND  ;
		prog_id = m.prog_id AND ;
		model_id = m.model_id AND ;
		intervention_id = m.intervention_id

	IF FOUND()
		GATHER MEMVAR FIELDS EXCEPT sessions_id, aida_primary_key
	Else
      m.aida_primary_key=GetNextID('SESSIONSID')
		INSERT INTO sessions FROM memvar
	ENDIF
	
	SELECT sessions_cur
ENDSCAN

* target_pop
SELECT target_pop_cur
SCAN FOR agency_id = gcAgency
	SCATTER MEMVAR FIELDS EXCEPT target_pop_id
	SELECT target_pop
	LOCATE FOR 	;
		contract_id = m.contract_id AND  ;
		prog_id = m.prog_id AND ;
		model_id = m.model_id AND ;
		intervention_id = m.intervention_id AND ;
		cp_id = m.cp_id

	IF FOUND()
		GATHER MEMVAR FIELDS EXCEPT target_pop_id, m.aida_primary_key
	Else
      m.aida_primary_key=GetNextID('TARGETPID')
		Insert INTO target_pop FROM memvar
	ENDIF
	
	SELECT target_pop_cur
ENDSCAN


*!* Dev Ticket 5806: Add program lockdown
=OpenFile('program')
Select * From program Into Cursor curProgram Where .f. ReadWrite
* Sessions 
aContractProgramNodes = topElement.selectNodes("ContractProgram")
nDone = 0
nPctHold = 0
For Each xmlNode In aContractProgramNodes
   Insert Into sessions_cur ;
   ( ;
      agency_id, ;
      contract_id, ;
      conno,;
      prog_id, ;
      model_id, ;
      intervention_id, ;
      sessions, ;
      user_id, ;
      dt, ;
      tm ;
   ) ;
   Values (;
      xmlNode.selectSingleNode("Agency_ID").text, ;
      VAL(xmlNode.selectSingleNode("Contract_ID").text), ;
      xmlNode.selectSingleNode("CONNO").text, ;
      xmlNode.selectSingleNode("Prog_ID").text, ;
      VAL(xmlNode.selectSingleNode("Model_ID").text), ;
      VAL(xmlNode.selectSingleNode("Intervention_id").text), ;
      VAL(xmlNode.selectSingleNode("Sessions").text), ;
      gcWorker, ;
      m.dt, ;
      m.tm ;
   )

EndFor


EndFor


SELECT sessions_cur
SCAN FOR agency_id = gcAgency
   SCATTER MEMVAR FIELDS EXCEPT sessions_id
   SELECT sessions
   LOCATE FOR    ;
      contract_id = m.contract_id AND  ;
      prog_id = m.prog_id AND ;
      model_id = m.model_id AND ;
      intervention_id = m.intervention_id

   IF FOUND()
      GATHER MEMVAR FIELDS EXCEPT sessions_id, aida_primary_key
   Else
      m.aida_primary_key=GetNextID('SESSIONSID')
      INSERT INTO sessions FROM memvar
   ENDIF
   
   SELECT sessions_cur
ENDSCAN

* target_pop
SELECT target_pop_cur
SCAN FOR agency_id = gcAgency
   SCATTER MEMVAR FIELDS EXCEPT target_pop_id
   SELECT target_pop
   LOCATE FOR    ;
      contract_id = m.contract_id AND  ;
      prog_id = m.prog_id AND ;
      model_id = m.model_id AND ;
      intervention_id = m.intervention_id AND ;
      cp_id = m.cp_id

   IF FOUND()
      GATHER MEMVAR FIELDS EXCEPT target_pop_id, m.aida_primary_key
   Else
      m.aida_primary_key=GetNextID('TARGETPID')
      Insert INTO target_pop FROM memvar
   ENDIF
   
   SELECT target_pop_cur
ENDSCAN


* pems2urs
SELECT pems2urs_cur
SCAN FOR agency_id = gcAgency
	SCATTER memvar
	IF SEEK(m.pems2urs_id, 'pems2urs')
		SELECT pems2urs
		GATHER memvar
		SELECT pems2urs_cur
	ELSE
		INSERT INTO pems2urs FROM memvar
	ENDIF
ENDSCAN

***********************************************************************************
oThermo.refresh('Updating Encounter and Service IDs', 99)

=OpenFile('lv_enc_type')

=OpenFile('lv_service')

SELECT pems2urs

*!*	UPDATE pems2urs ;
*!*	SET enc_id = et.enc_id ;
*!*	FROM pems2urs ;
*!*		JOIN lv_enc_type et ON ;
*!*			pems2urs.serv_cat = et.serv_cat ;
*!*			AND pems2urs.enc_type = et.code 

*!*	UPDATE pems2urs ;
*!*	SET service_id = sv.service_id ;
*!*	FROM ;
*!*		pems2urs ;
*!*		JOIN lv_service sv ON ;
*!*			pems2urs.serv_cat = sv.serv_cat ;
*!*			AND pems2urs.enc_id = sv.enc_id ;
*!*			AND pems2urs.service = sv.code 

UPDATE pems2urs ;
SET conno = ai_contract.conno ;
FROM pems2urs ;
	JOIN ai_contract ON ;
		pems2urs.contract_id = ai_contract.ai_contract_id

*************************************************************
* Check prog2sc and add records if needed *******************
*************************************************************
SELECT DISTINCT prog_id, serv_cat ;
FROM pems2urs ;
INTO CURSOR p2sc_cur

Select Min(start_date) From ai_contract_cur Where !Empty(start_date) And agency_id = gcAgency Into Array ajstart_dt
If _Tally > 0
   dStartDt=ajstart_dt[1]
Else
   dStartDt={01/01/1981}
EndIf

SELECT * ;
FROM p2sc_cur ;
WHERE NOT exists (;
	SELECT * ;
	FROM prog2sc ;
	WHERE ;
		prog2sc.prog_id = p2sc_cur.prog_id AND ;
		prog2sc.serv_cat = p2sc_cur.serv_cat AND ;
		EMPTY(prog2sc.end_dt) ;
	) ;
INTO CURSOR p2sc_add_cur

IF RECCOUNT() > 0
	m.user_id = gcWorker
	m.dt = DATE()
	m.tm = TIME()
	m.tc = '00002'
   m.effective_dt=dStartDt
   
	SCAN
		SCATTER MEMVAR
		m.prog2sc_id = GetNextID('PROG2SC_ID')
		INSERT INTO prog2sc FROM MEMVAR 
	EndScan
ENDIF

oThermo.Release
Try
   If Used('system')
      Update system Set last_pems_import=Datetime()
   EndIf
EndTry 

oApp.msg2user('MESSAGE','PEMS Import Process was completed without error.')

***********************************************************************************
FUNCTION getXMLValue(xmlNode, cElement)

oXMLObj = xmlNode.selectSingleNode(cElement)

IF ISNULL(oXMLObj)
	RETURN null
ELSE
	RETURN oXMLObj.text
ENDIF
