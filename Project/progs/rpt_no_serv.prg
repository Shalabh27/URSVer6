Parameters    lPrev, ;              && Preview     
              aSelvar1, ;           && select parameters from selection list
              nOrder, ;             && order by
              nGroup, ;            && report selection    
              lcTitle, ;             && report selection    
              Date_from , ;         && from date
              Date_to, ;            && to date   
              PrCr , ;           && name of param
              lnStat, ;             && selection(Output)  page 2
              cOrderBy              && order by description

Acopy(aSelvar1, aSelvar2)

CCSITE     = ''
LCSERV     = ''
LCPROG     = ''
cDate = DATE()
cTime = TIME()

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcServ = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCsite = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
EndFor

PRIVATE cDate, cTime, gchelp
gchelp='Active Clients w/o Encounters'
cDate      = DATE()
cTime      = TIME()
cTitle     = 'Active Clients Without Encounters'

* Pre-select all clients' addresses
*!*   SELECT ;
*!*   	cli_hous.client_id, ;
*!*   	address.* ;
*!*   FROM ;
*!*   	cli_hous, address ;
*!*   WHERE ;
*!*   	cli_hous.hshld_id = address.hshld_id AND ;
*!*   	cli_hous.lives_in ;
*!*   INTO CURSOR ;
*!*   	cli_addr

SELECT address.* ;
FROM address ;
INTO CURSOR cli_addr readwrite
   
INDEX ON client_id + DTOS(DATE) TAG clientdate

* client's status in agency
SELECT ;
	cli_cur.client_id, ;
	ai_clien.id_no, ;
	ai_clien.tc_id, ;
	Padr(oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi), 50) AS fullname, ;
	ai_activ.status, ;
	ai_activ.effect_dt, ;
	cli_cur.phwork, ;
	cli_cur.phhome, ;
	ai_clien.home_cont, ;
	ai_clien.mail_cont, ;
	ai_clien.phone_cont, ;
	ai_clien.discrete, ;
	statvalu.incare ;
FROM ;
	cli_cur, ;
	ai_clien, ;
	ai_activ, ;
	statvalu;
WHERE ai_clien.client_id = cli_cur.client_id ;
AND ai_activ.tc_id = ai_clien.tc_id ;
AND statvalu.tc = gctc ;
AND statvalu.type = 'ACTIV' ;
AND statvalu.code = ai_activ.status ;
INTO CURSOR ;
	cli_stat

* get clients active as of period end
SELECT ;
      	tc_id, ;
      	client_id, ;
      	fullname, ;
      	id_no, ;
      	phwork, ;
      	phhome, ;
      	home_cont, ;
      	mail_cont, ;
      	phone_cont, ;
      	discrete, ;
         CANCONT() as cont_desc, ;
         lcTitle as lcTitle, ;
         PrCr as  Crit, ;   
         cDate as cDate, ;
         cTime as cTime, ;
         Date_from as Date_from, ;
         date_to as date_to;   
FROM ;
	cli_stat ;
WHERE ;
	cli_stat.incare ;
AND	cli_stat.tc_id + DTOS(effect_dt) IN ;
			(SELECT ;
				MAX(cs.tc_id + DTOS(cs.effect_dt)) ;
			FROM ;
				cli_stat cs ;
			WHERE ;
				cs.effect_dt <= date_to ;
			GROUP BY ;
				tc_id ) ;
INTO CURSOR ;
	cli_activ 


DO CASE
   CASE EMPTY(lcprog)		&& no program specified, so check for any encounters in any program, including syringe exchange "encounters"
         
   
*!*      		SELECT 	*, ;
*!*      			space(10) as addr_id ;
*!*      		FROM ;
*!*      			cli_activ ;
*!*      		WHERE ;
*!*      			tc_id NOT IN ;
*!*          			(SELECT tc_id ;
*!*      	    		FROM 	ai_enc ;
*!*      			    WHERE 	BETWEEN(ai_enc.act_dt, date_from, date_to) 	;
*!*      				AND 	ai_enc.site = ccsite ;
*!*      				AND 	ai_enc.serv_cat = lcserv) ;
*!*      		AND tc_id NOT IN ;
*!*          			(SELECT tc_id ;
*!*      	    		FROM 	needlx ;
*!*      			    WHERE 	BETWEEN(needlx.date, date_from, date_to) 	;
*!*      				AND 	 needlx.site    = ccsite) ;
*!*      		ORDER BY ;
*!*      			fullname ;
*!*      		INTO CURSOR ;
*!*      			tmpcur
*!*                         
            Select distinct tc_id ;
            From ai_enc ;
            Where Between(ai_enc.act_dt, date_from, date_to)    ;
               AND ai_enc.site=ccsite ;
               AND ai_enc.serv_cat=lcserv;
            into cursor t_enc   
               
            Select Distinct tc_id ;
            From needlx ;
            Where Between(needlx.date, date_from, date_to)    ;
               AND needlx.site=ccsite ;
            into cursor t_needlx   
              
         **VT 08/27/2010 Dev Tick 4807 changed tmpcur -> noserv readwrite    
         SELECT    *, ;
            space(10) as addr_id ;
         FROM ;
            cli_activ ;
         WHERE ;
            tc_id NOT IN ;
                (SELECT tc_id ;
                FROM    t_enc)  ;
         AND tc_id NOT IN ;
                (SELECT tc_id ;
                FROM   t_needlx) ;
         ORDER BY ;
            fullname ;
         INTO CURSOR ;
            noserv readwrite
                      
         If Used('t_needlx')  
            Use in t_needlx
         EndIf
         
         If Used('t_enc')  
            Use in t_enc
         EndIf       
   OTHERWISE  && program specified
* determine here if the selected program requires enrollment
      If Used('tempprog')
         Use in tempprog
      EndIf
      
         Select distinct tc_id ;
         From ai_enc ;
         Where Between(ai_enc.act_dt, date_from, date_to) ;
            AND ai_enc.site = ccsite ;
            AND ai_enc.serv_cat = lcserv;
            And ai_enc.program  = lcprog ;
         into cursor t_enc
         
         Select Distinct tc_id ;
         From needlx ;
         Where Between(needlx.date, date_from, date_to)    ;
            AND needlx.site    = ccsite ;
            AND needlx.program   = lcprog  ;
         into cursor t_needlx   
               
		SELECT 	enr_req ;
		FROM 	program ;
		WHERE	program.prog_id = lcprog ;
		INTO CURSOR tempprog   
		
      IF tempprog.enr_req    && grab clients enrolled in program as of period end who have had no encounters or needle exchanges in this program during period
         * here, get clients enrolled in program
         * jss, 9/17/04, correct code below: should only care if client is enrolled at the end of the period, NOT whether client was enrolled during period
            *	AND 	BETWEEN(ai_prog.start_dt, date_from, date_to) 
         If Used('Cli_prog')
            Use in Cli_prog
         EndIf
                     
*!*   			SELECT ;
*!*   				cli_activ.*, ;
*!*   				space(10) AS addr_id ;
*!*   			FROM ;
*!*   				cli_activ ;
*!*   			WHERE ;
*!*   				cli_activ.tc_id IN ;
*!*   					(SELECT ai_prog.tc_id ;
*!*   					FROM 	ai_prog ;
*!*   					WHERE 	ai_prog.program = lcprog ; 
*!*   					AND 	   ai_prog.start_dt <= date_to ;
*!*   					AND		(EMPTY(ai_prog.end_dt) OR ai_prog.end_dt > date_to)) ;
*!*   			INTO CURSOR ;
*!*   				cli_prog
      
                 SELECT ;
                        cli_activ.*, ;
                        space(10) AS addr_id ;
                  FROM ;
                     cli_activ, ai_prog ;
                  WHERE ;
                     cli_activ.tc_id = ai_prog.tc_id ;
                     and ai_prog.program = lcprog ; 
                        AND       ai_prog.start_dt <= date_to ;
                        AND      (EMPTY(ai_prog.end_dt) OR ai_prog.end_dt > date_to) ;
                  INTO CURSOR ;
                     cli_prog
       

      * here, find enrolled clients who have no encounters or syringe exchanges this period in this program
         
         **VT 08/27/2010 Dev Tick 4807 changed tmpcur -> noserv readwrite  
            
			SELECT * ;
			FROM ;
				cli_prog ;
			WHERE ;
				cli_prog.tc_id NOT IN ;
	   				(SELECT tc_id ;
    				FROM 	t_enc) ;
			AND ;	
				cli_prog.tc_id NOT IN ;
	    			(SELECT tc_id ;
	    			FROM 	t_needlx) ;
			ORDER BY ;
					fullname ;
			INTO CURSOR ;
					noserv readwrite
					
			USE IN cli_prog
       

      ELSE
            * if no enrollment required, just grab everybody in agency with no encounters in this program (nor any syringe exchange encounters)
            **VT 08/27/2010 Dev Tick 4807 changed tmpcur -> noserv readwrite  
            
      			SELECT ;
      				cli_activ.*, ;
      				SPACE(10) AS addr_id ;
      			FROM ;
      				cli_activ ;
      			WHERE ;
      				cli_activ.tc_id NOT IN ;
      	   				(SELECT tc_id ;
          				FROM 	t_enc) ;
      			AND ;	
      				cli_activ.tc_id NOT IN ;
      	    			(SELECT tc_id ;
      	    			FROM 	t_needlx ) ;
      			ORDER BY ;
      					fullname ;
      			INTO CURSOR ;
      					noserv readwrite
      ENDIF
   		USE IN tempprog
   		USE IN cli_activ
         
         If Used('t_needlx')  
            Use in t_needlx
         EndIf
         
         If Used('t_enc')  
            Use in t_enc
         EndIf                
ENDCASE			
			
If Used("ai_prog")   
   Use in ("ai_prog")      
Endif 

**VT 08/27/2010 Dev Tick 4807 
**oApp.ReopenCur("tmpcur", "noserv")
SELECT NOSERV
Index On Upper(Alltrim(fullname)) Tag fn
Set Order To fn
     
SET RELATION TO client_id INTO cli_addr

oApp.Msg2User('OFF')

SELECT NOSERV
SCAN
    REPLACE addr_id   WITH cli_addr.addr_id 
ENDSCAN

GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
            gcRptName = 'rpt_no_serv'
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_no_serv  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.   
                  oApp.rpt_print(5, .t., 1, 'rpt_no_serv', 1, 2)
           ENDCASE
        
EndIf
****************
FUNCTION CANCONT
**************** 
RETURN IIF(HOME_CONT,'Home','') + ;
       IIF(MAIL_CONT,IIF(HOME_CONT,', ','')+'Mail','') + ;
       IIF(PHONE_CONT,IIF(MAIL_CONT,', ','')+'Phone','') + ;
       IIF(DISCRETE,IIF(PHONE_CONT,', ','')+'Descretion','')
