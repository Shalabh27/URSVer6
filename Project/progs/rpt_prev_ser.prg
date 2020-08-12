Parameters lPrev,  ;
            cContract, ;
            cCsite, ;
            date_from, ;
            date_to 

PRIVATE gcHelp
cDate = DATE()
cTime = TIME()
cAgency_id = " "
cAgc_Name = " "

IF !GetCliLst()
   oApp.msg2user('Off')
   oApp.msg2user('NOTFOUNDG')
   Return
EndIf

nyear= YEAR(date_from)
nmon = MONTH(date_from)

cMonthYear = Cmonth(date_from) + ", " + RIGHT(DTOC(date_from),4)

ddate_from = CTOD(STR(nmon)+ "/01/" + STR(nyear))
dDate_To = GOMONTH(ddate_from,1)-1

=clean_data()
   
Select start_dt AS ytd_from;
FROM  ;
      contract ;
WHERE ;
      contract.con_id = cContract ;
INTO CURSOR ;
      ytdfrom      
      
m.ytd_from=IIF(_TALLY=0,CTOD('01/01/' + STR(YEAR(dDate_from),4)),ytdfrom.ytd_from)

FOR i = 1 TO 2
   dDate_From = IIF(i = 1, dDate_from, m.ytd_from)
   
   SELECT   a.Contract, ;
            a.SerT, ;
            b.Descript, ;
            b.SerUnit, ;
            b.NofCl, ;
            STR(SUM(a.nc)) AS nc_proj, ;
            STR(SUM(a.ns)) AS ns_proj ;
   FROM     SerTag   A, ;
            SerType  B, ;
            Contract C  ;
    WHERE    a.Contract = cContract ;
     AND     a.Contract = c.Con_id ;
     AND     a.Sert = b.Code ;
     AND     b.Unit_type <> '4' ;
     AND     BETWEEN(CTOD(SUBSTR(a.cm,2,2) + "/01/" + IIF(VAL(RIGHT(a.cm,2)) < 90, '20', '19') + RIGHT(a.cm,2)), ;
                                dDate_from, dDate_to) ;
     AND     a.nc + a.ns > 0 ;           
     AND     c.Start_dt <= dDate_From ;
     AND     c.End_dt   >= dDate_To ;
     INTO CURSOR ;   
              tTemp1 ;
     GROUP BY 1,2, 3, 4, 5
  
   SELECT    a.Cid AS Contract, ;
              c.SerT, ;
              b.Descript, ;
              b.SerUnit, ;
              b.NofCl, ;
              STR(0) AS nc_proj, ;
              STR(0) AS ns_proj ;
   FROM       ContrInf A, ;
              SerType  B, ;
              ConSer   C, ;
              Contract D  ;
   WHERE     a.Cid = cContract ;
     AND     a.Cid = D.Con_id ;
     AND     a.ConType = c.ConT ;
     AND     b.Code = c.SerT ;
     AND     b.Unit_type <> '4' ;
     AND     BETWEEN(dDate_from, cnStart_Dt, cnEnd_Dt) ;
     AND     D.Start_dt <= dDate_From ;
     AND     D.End_dt   >= dDate_To ;
     INTO CURSOR ;
              tTemp2
     
     SELECT    a.*, ;
               b.Descript AS ContrDes ;
     FROM     tTemp1 A, ;
              ContrInf B ;
     WHERE    a.Contract = b.Cid ;
     UNION ;      
     SELECT    a.*, ;
               b.Descript AS ContrDes ;
     FROM     tTemp2 A, ;
              ContrInf B ;
     WHERE    a.Contract = b.Cid ;
     AND      Contract + SerT NOT IN ;
                 (SELECT Contract + SerT FROM tTemp1) ;
     INTO CURSOR ;
              tTemp3 ;
     ORDER BY 1, 2          

           
   SELECT    DISTINCT ;
            Contract.Con_id AS Contract, ;
            ConSD.Ser_Type, ;
            Ai_Enc.Tc_ID, ;
            Ai_Enc.Act_ID, ;
            Ai_Enc.Act_Dt, ;
            Ai_Enc.Serv_Cat, ;
            Ai_Enc.Enc_id, ;
            Ai_Serv.Service, ;
            ContrInf.Descript AS ContrDes, ;
            IIF(EMPTY(Ai_Enc.bill_to), .F., .T.) AS bill23par, ;
            Ai_Enc.Att_ID ;
   FROM    ConSd, ;
            Ai_Enc, ;
            Ai_Serv, ;
            Program, ;
            Contract, ;
            ContrInf, ;
            Ai_Site, ;
            Site ;
   WHERE     ContrInf.Cid = cContract ;
   AND       ConSD.Contract = Contract.Cid ;
   AND       Contract.Con_ID = ContrInf.Cid ;
   AND       Contract.Start_dt <= dDate_From ;
   AND       Contract.End_dt   >= dDate_To ;
   AND       ConSD.Enc_id = Ai_Enc.Enc_id ;
   AND       ConSD.Serv_Cat = Ai_Enc.Serv_Cat ;
   AND       ConSD.Service_id = Ai_Serv.Service_id ;
   AND       Ai_Enc.Act_ID = Ai_Serv.Act_ID ;
   AND       Ai_Enc.Program = Program.Prog_ID ;
   AND       Ai_Enc.Program = Contract.Program ;
   AND       Ai_Enc.Act_Dt BETWEEN dDate_From AND dDate_To ;
   AND       Ai_Enc.Tc_ID = Ai_Site.Tc_ID ;
   AND       Ai_Site.Tc_id + DTOS(Ai_Site.Effect_dt) + oApp.TIME24(Ai_Site.time,Ai_site.am_pm) ;
                  IN (SELECT ai_site2.tc_id + MAX(DTOS(ai_site2.effect_dt)+ oApp.TIME24(ai_site2.time, ai_site2.am_pm)) ;
                  FROM ai_site ai_site2 ;
                    WHERE ai_site2.effect_dt <= dDate_To ;
                  GROUP BY ai_site2.tc_id) ;
   AND       Site.Site_ID = Ai_Site.Site ;
   AND       Site.Site_ID = cCSite ;
   AND       Site.Agency_ID = cAgency_ID ;
   AND       ai_serv.act_id + ai_serv.serv_id IN ;
               (SELECT ais.act_id+MIN(ais.serv_id) ;
               FROM ai_serv ais ;
               GROUP BY ais.act_id) ;
     INTO CURSOR ;
              tTemp10   ;
     ORDER BY ;
              Ai_Enc.Act_ID

SELECT    Distinct ;
               a.Contract, ;
               a.Ser_Type, ;
               0000000000 AS ns, ;
               '0000000000' AS nc, ;
               a.ContrDes ;
   FROM        tTemp10 A ,;
               SerType B ;
   WHERE       a.Ser_Type = b.Code ;
        And EMPTY(b.nofcl) ;
   INTO CURSOR ;
              tTemp13a

   If i = 1
      * now, count the unduplicated clients when nofcl is filled and unit_type='1'
                          
         SELECT     a.Contract, ;
                    a.Ser_Type as Ser_Type, ;
                    0000000000          AS ns, ;
                    Padl(Str(COUNT(DIST tc_id),10,0), 10,'0') AS nc, ;
                    a.ContrDes ;
         FROM       tTemp10 A, ;
                    SerType B ;
           WHERE    a.Ser_Type = b.Code ;
           AND       NOT EMPTY(b.nofcl) ;
           AND      b.Unit_Type='1' ;
           GROUP BY 1, 2, 3, 5 ;
           INTO CURSOR ;
                    tTemp13b
     Else
     * now, count the unduplicated clients when nofcl is filled and unit_type='1'
           Select a.contract, ;
              a.ser_type, ;
              0000000000 as ns, ;
              a.tc_id, ;
              a.ContrDes, ;
              Left(Dtoc(a.act_dt),2) as t_dt ;
           From tTemp10 a, ;
              SerType b ;
           Where a.ser_type =b.code and ;
              !empty(b.nofcl) and ;
              b.unit_type = '1' ;
           Into Cursor t_tmp1
           
           Select   contract, ;
                    ser_type, ;
                    ns, ;
                    count(dist tc_id) as d_tc,;
                    ContrDes, ;
                    t_dt ;
           From t_tmp1 ;
           Group by 1, 2, 6, 3, 5 ;
           Into Cursor t_tmp2
           
                 
         Select     Contract, ;
                    Ser_Type, ;
                    ns, ;
                    Padl(Str(Sum(d_tc),10,0), 10,'0') AS nc, ;
                    ContrDes ;
         From t_tmp2 ;
         Group by 1, 2, 3, 5;
         Into Cursor tTemp13b
           
           Use in t_tmp1
           Use in t_tmp2   
     Endif            

* now, count the duplicated clients when nofcl is filled and unit_type='2'
      SELECT   a.Contract, ;
               a.Ser_Type as Ser_Type, ;
               0000000000          AS ns, ;
               Padl(Str(COUNT(tc_id),10,0), 10,'0') AS nc, ;
               a.ContrDes ;
     FROM      tTemp10 A, ;
               SerType B ;
     WHERE     a.Ser_Type = b.Code ;
     AND       NOT EMPTY(b.nofcl) ;
     AND       b.Unit_Type='2' ;
     GROUP BY 1, 2, 3, 5 ;
     INTO CURSOR ;
              tTemp13b1
      
* join the above two to give us a cursor with # of clients/attendees filled in for each contract + service type this month    

   SELECT    * ;
   FROM ;
            tTemp13a ;
   UNION ;
   SELECT    * ;
   FROM ;
            tTemp13b ;
   UNION ;
   SELECT    * ;
   FROM ;
            tTemp13b1 ;
   INTO CURSOR ;
            tTemp13c
            
* must now create an outer join to grab info for services projected in ttemp3 but not found this period in ttemp13c
   SELECT   a.Contract, ;
            a.SerT AS Ser_type, ;
            0000000000          AS ns, ;
            '0000000000'      AS nc, ;
            c.Descript          AS ContrDes ;
   FROM     tTemp3   A, ;
            ContrInf C  ;
     WHERE  a.Contract = c.Cid  ;
     AND    Contract + SerT NOT IN (SELECT Contract + Ser_Type FROM tTemp13c) ;
     INTO CURSOR ;
              tTemp13d
              
* now, complete the outer join
   SELECT    * ;
   FROM ;
            tTemp13c ;
   UNION ;
   SELECT    * ;
   FROM ;
            tTemp13d ;
   INTO CURSOR ;
            tTemp13e
      
* now, use next 3 selects to determine the number of encounters/sessions for each contract + service type      
* first, count encounters for unit_type=1 (individual encounters)
     SELECT   a.Contract, ;
              a.Ser_Type, ;
              COUNT(a.Act_ID)    AS ns, ;
              0000000000          AS nc, ;
              a.ContrDes ;
     FROM     tTemp10 A, ;
              SerType B;
     WHERE    a.Ser_Type = b.Code ;
     AND       b.Unit_type='1' ;
     GROUP BY 1, 2, 4, 5 ;
     INTO CURSOR tTemp13f
 
* now, count distinct attendance ids for unit_type=2 (group encounters) 
     SELECT   a.Contract, ;
              a.Ser_Type, ;
              COUNT(DIST a.att_id) AS ns, ;
              0000000000           AS nc, ;
              a.ContrDes ;
     FROM       tTemp10 A, ;
              SerType B;
     WHERE    a.Ser_Type = b.Code ;
     AND       b.Unit_type='2' ;
     AND       NOT EMPTY(a.att_id) ;
     GROUP BY 1, 2, 4, 5;
     INTO CURSOR ;
              tTemp13g
  
* here, count zeros for any other unit type OR group unit type and empty att_id
     SELECT  a.Contract, ;
             a.Ser_Type, ;
             0000000000 AS ns, ;
             0000000000 AS nc, ;
             a.ContrDes ;
     FROM       tTemp10 A, ;
              SerType B;
     WHERE    a.Ser_Type = b.Code ;
     AND    (NOT INLIST(b.unit_type,'1','2') OR (b.unit_type='2' AND EMPTY(a.att_id)));
     AND     a.Contract + a.Ser_Type NOT IN (SELECT Contract + Ser_type FROM tTemp13g) ; 
     INTO CURSOR ;
              tTemp13h
  
* join the above three to give us a cursor with # of encounters/sessions filled in for each contract + service type used this period

   SELECT    * ;
   FROM       tTemp13f ;
   UNION ;
   SELECT    * ;
   FROM       tTemp13g ;
   UNION ;
   SELECT    * ;
   FROM       tTemp13h ;
   INTO CURSOR ;
            tTemp13i

* must now create an outer join to grab info for services projected in tTemp3 but not found this period in tTemp13i
* jss, 2/29/00, fix typo problem: subselect mistakenly had ttemp13c, instead of ttemp13i (due to previous block copy from above)
   SELECT   a.Contract, ;
            a.SerT AS Ser_Type, ;
            0000000000          AS ns, ;
            0000000000        AS nc, ;
            c.Descript          AS ContrDes ;
   FROM     tTemp3   A, ;
            ContrInf C  ;
     WHERE  a.Contract = c.Cid ;
     AND    a.Contract + a.SerT NOT IN (SELECT Contract + Ser_Type FROM tTemp13i) ;
     INTO CURSOR ;
              tTemp13j
              
* now, complete the outer join
   SELECT    * ;
   FROM ;
            tTemp13i ;
   UNION ;
   SELECT    * ;
   FROM ;
            tTemp13j ;
   INTO CURSOR ;
            tTemp13k
      
* now, join the # clients/attendees cursor with the # of encounters/sessions cursor

   SELECT   a.Contract, ;
            a.Ser_Type, ;
            b.ns, ;
            Int(val(a.nc)) as nc, ;
            a.ContrDes;
  FROM      tTemp13e A, ;
            tTemp13k B;
     WHERE  a.Contract = b.Contract ;
     AND    a.Ser_Type = b.Ser_Type ;
     INTO CURSOR ;
              tTemp13

***jss, 6/10/99, comment extraneous "and" from above where clause:     "AND       a.Cm       = b.Cm ;"
     SELECT    a.Contract, ;
               a.Ser_Type, ;
               COUNT(a.Act_ID) AS ns23par, ;
               0000 AS nc23par ;
     FROM      tTemp10 A, ;
               SerType B;
     WHERE     a.Ser_Type = b.Code and;
               Bill23Par = .t. and ;
               !EMPTY(b.SerUnit) ;
     GROUP BY 1, 2, 4 ;         
     Union  ;
     SELECT    a.Contract, ;
               a.Ser_Type, ;
               0000 AS ns23par, ;
               COUNT(DIST a.Tc_ID) AS nc23par ;
     FROM      tTemp10 A, ;
               SerType B;
     WHERE     a.Ser_Type = b.Code and;
               Bill23Par = .t. and ;
               !EMPTY(b.NofCl) ; 
     GROUP BY 1, 2, 3 ;         
     Union ;    
     SELECT    a.Contract, ;
               a.Ser_Type, ;
               0000 AS ns23par, ;
               0000 AS nc23par ;
     FROM      tTemp10 A ;
     WHERE     Bill23Par = .f. ;
     INTO CURSOR ;
              tTemp14
   
   SELECT   a.Contract, ;
            a.SerT, ;
            a.Descript, ;
            a.SerUnit, ;
            a.NofCl, ;
            INT(VAL(a.ns_proj)) AS ns_proj, ;
            INT(VAL(a.nc_proj)) AS nc_proj, ;
            b.ns, ;
            b.nc, ;
            c.ns23par, ;
            c.nc23par, ;
            a.ContrDes ;
   FROM     tTemp3  A, ;
            tTemp13 B, ;
            tTemp14 C ;
   WHERE    a.Contract = b.Contract ;
   AND       b.Contract = c.Contract ;
   AND       b.Ser_Type = c.Ser_Type ;
   AND       a.SerT = b.Ser_Type ;
   INTO CURSOR ;
            tTemp4

   cCursName = "tTemp5" + STR(i,1) 
   
     SELECT    STR(i,1) AS Part, * ;
     FROM       tTemp4 ;
     UNION ;
     SELECT    STR(i,1)          AS Part, ;
              tTemp3.Contract, ;
              tTemp3.SerT, ;
              tTemp3.Descript, ;
              tTemp3.SerUnit, ;
              tTemp3.NofCl, ;
              INT(VAL(tTemp3.ns_proj)) AS ns_proj, ;
              INT(VAL(tTemp3.nc_proj)) AS nc_proj, ;
              0000                AS ns, ;
              0000                AS nc, ;
              0000                AS ns23par, ;
              0000                AS nc23par, ;
              tTemp3.ContrDes ;
     FROM     tTemp3 ;
     WHERE    Contract + SerT NOT IN ;
                 (SELECT Contract + SerT FROM tTemp4) ;
     UNION ;
     SELECT   STR(i,1)          AS Part, ;
              a.Contract, ;
              a.Ser_Type          AS SerT, ;
              c.Descript, ;
              c.SerUnit, ;
              c.NofCl, ;
              0000                AS ns_proj, ;
              0000                AS nc_proj, ;
              a.ns, ;
              a.nc, ;
              b.ns23par, ;
              b.nc23par, ;
              a.ContrDes ;
     FROM     tTemp13 A, ;
              tTemp14 B, ;
              SerType C ;
     WHERE    a.Ser_Type = c.Code ;
     AND      a.Contract = b.Contract ;
     AND      a.Ser_Type = b.Ser_Type ;
     AND      a.Contract + a.Ser_Type NOT IN ;
                 (SELECT Contract + SerT FROM tTemp4) ;
     INTO CURSOR ;
              &cCursName
***************************************************************************************************
* now we need to get the total numbers for Group Level Interven, i.e. Att_ID in Ai_Enc is not empty
* because of DIST, must create 2 cursors and then join
 
   SELECT   Contract, ;
            COUNT(DIST Att_ID)    AS NumbSess, ;
            COUNT(Act_id)          AS NumbEnc ;
   FROM     tTemp10 ;
   GROUP BY ;   
            Contract ;
   WHERE    NOT EMPTY(Att_ID) And ;
            Serv_cat = '00013' ;
   INTO CURSOR ;
            tGrpLI1

   SELECT   Contract, ;
            COUNT(DIST Tc_ID) AS NumbCli ;
            FROM tTemp10 ;
   GROUP BY ;
            Contract ;
   WHERE    NOT EMPTY(Att_ID) and ;
            Serv_cat = '00013' ;
   INTO CURSOR ;
            tGrpLI2

     cCursName = "tGrpLI0" + STR(i,1) 
   
   SELECT   STR(i,1) AS Part, ;
            a.Contract, ;
            a.NumbSess, ;
            a.NumbEnc, ;
            b.NumbCli ;
   FROM     tGrpLI1 A, ;
            tGrpLI2 B;
   WHERE    a.Contract = b.Contract ;
   INTO CURSOR ;
            &cCursName

*** Individual Level Interv

   Select   Contract, ;
            COUNT(DIST Att_ID)    AS NumbSess, ;
            COUNT(Act_id)          AS NumbEnc ;
   FROM     tTemp10 ;
   GROUP BY ;   
            Contract ;
   WHERE Serv_cat = '00014' ;
   INTO CURSOR ;
            tIndLI1

   SELECT   Contract, ;
            COUNT(DIST Tc_ID) AS NumbCli ;
   FROM tTemp10 ;
   GROUP BY ;
            Contract ;
   WHERE Serv_cat = '00014' ;
   INTO CURSOR ;
            tIndLI2

     cCursName = "tIndLI0" + STR(i,1) 
   
   SELECT   STR(i,1) AS Part, ;
            a.Contract, ;
            a.NumbSess, ;
            a.NumbEnc, ;
            b.NumbCli ;
   FROM     tIndLI1 A, ;
            tIndLI2 B;
   WHERE    a.Contract = b.Contract ;
   INTO CURSOR ;
            &cCursName

*** Prevention Case Management

   SELECT   Contract, ;
            COUNT(DIST Att_ID)    AS NumbSess, ;
            COUNT(Act_id)          AS NumbEnc ;
   FROM       tTemp10 ;
   GROUP BY ;   
            Contract ;
   WHERE Serv_cat = '00012' ;
   INTO CURSOR ;
            tPCM1

   SELECT   Contract, ;
            COUNT(DIST Tc_ID) AS NumbCli ;
            FROM tTemp10 ;
   GROUP BY ;
            Contract ;
   WHERE Serv_cat = '00012' ;
   INTO CURSOR ;
            tPCM2

     cCursName = "tPCM0" + STR(i,1) 
   
   SELECT   STR(i,1) AS Part, ;
            a.Contract, ;
            a.NumbSess, ;
            a.NumbEnc, ;
            b.NumbCli ;
   FROM     tPCM1 A, ;
            tPCM2 B;
   WHERE    a.Contract = b.Contract ;
   INTO CURSOR ;
            &cCursName
            
NEXT  

IF USED("tTemp6")
   USE IN tTemp6
ENDIF
   
IF USED("tPart")
   USE IN tPart
ENDIF
      
SELECT 0
USE (DBF("tTemp52")) AGAIN ALIAS tPart

APPEND FROM DBF("tTemp51")

SELECT tPart.* ,;
        b.unit_type, ; 
        cMonthYear as cMonthYear, ;
        cDate  as cDate, ;
        cTime  as cTime, ;
        cAgc_Name as cAgc_Name ;  
FROM tPart, ;
      SerType b;
where tPart.Sert = b.Code ;
INTO CURSOR Final ;
ORDER BY Contract, Part, SerT

IF USED("tGrpLI")
   USE IN tGrpLI
ENDIF

SELECT 0
USE (DBF("tGrpLI02")) AGAIN ALIAS tGrpLI

APPEND FROM DBF("tGrpLI01")
INDEX ON Contract+Part TAG Contract

IF USED("tIndLI")
   USE IN tIndLI
ENDIF

SELECT 0
USE (DBF("tIndLI02")) AGAIN ALIAS tIndLI

APPEND FROM DBF("tIndLI01")
INDEX ON Contract+Part TAG Contract

IF USED("tPCM")
   USE IN tPCM
ENDIF

SELECT 0
USE (DBF("tPCM02")) AGAIN ALIAS tPCM

APPEND FROM DBF("tPCM01")
INDEX ON Contract+Part TAG Contract

oApp.Msg2User('OFF')

SELECT Final
SET RELATION TO Contract+Part INTO tGrpLI
SET RELATION TO Contract+Part INTO tIndLI ADDITIVE
SET RELATION TO Contract+Part INTO tPCM ADDITIVE

GO TOP
IF EOF()
   oApp.Msg2user('NOTFOUNDG')
   If Used('final')
      Use in final
   Endif   
   
       Select ;
                 ContrInf.Descript   AS ContrDes   ,;
                 'Section III: Monthly Program Report' as nulrptname ,;
                 'III - A1: Summary of Services Provided During the Reporting Month' as nulrptnam1 ,;
                 'III - B1: Summary of Services Provided Year to Date' as nulrptnam2 ,;
                 '' as nulrptnam3 ,;
                 '' as nulrptnam4,  ;
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
          ENDCASE
Else
          gcRptName = 'rpt_prev_ser'
          DO CASE
             CASE lPrev = .f.
                  Report Form rpt_prev_ser  To Printer Prompt Noconsole NODIALOG 
             CASE lPrev = .t.    
                     oApp.rpt_print(5, .t., 1, 'rpt_prev_ser', 1, 2)
          ENDCASE
ENDIF

*********************************************
Function clean_data

IF USED("final")
   USE IN ("final")
EndIf

If Used('ytdfrom') 
   Use in ytdfrom 
EndIf

IF USED("tTemp1")
   USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
   USE IN ("tTemp2")
ENDIF

IF USED("tTemp3")
   USE IN ("tTemp3")
ENDIF

IF USED("tTemp4")
   USE IN ("tTemp4")
ENDIF

IF USED("tTemp10")
   USE IN ("tTemp10")
ENDIF

IF USED("tTemp13")
   USE IN ("tTemp13")
ENDIF

IF USED("tTemp13a")
   USE IN ("tTemp13a")
ENDIF

IF USED("tTemp13b")
   USE IN ("tTemp13b")
ENDIF

IF USED("tTemp13b1")
   USE IN ("tTemp13b1")
EndIf

IF USED("tTemp13c")
   USE IN ("tTemp13c")
ENDIF

IF USED("tTemp13d")
   USE IN ("tTemp13d")
ENDIF

IF USED("tTemp13e")
   USE IN ("tTemp13e")
ENDIF

IF USED("tTemp13f")
   USE IN ("tTemp13f")
ENDIF

IF USED("tTemp13g")
   USE IN ("tTemp13g")
ENDIF

IF USED("tTemp13h")
   USE IN ("tTemp13h")
ENDIF

IF USED("tTemp13i")
   USE IN ("tTemp13i")
ENDIF

IF USED("tTemp13j")
   USE IN ("tTemp13j")
ENDIF

IF USED("tTemp13k")
   USE IN ("tTemp13k")
ENDIF

IF USED("tTemp14")
   USE IN ("tTemp14")
ENDIF

IF USED("tTemp51")
   USE IN ("tTemp51")
ENDIF

IF USED("tTemp52")
   USE IN ("tTemp52")
ENDIF

IF USED("tTemp6")
   USE IN ("tTemp6")
ENDIF

IF USED("tGrpLI")
   USE IN ("tGrpLI")
ENDIF

IF USED("tGrpLI1")
   USE IN ("tGrpLI1")
ENDIF

IF USED("tGrpLI2")
   USE IN ("tGrpLI2")
ENDIF

IF USED("tGrpLI01")
   USE IN ("tGrpLI01")
ENDIF

IF USED("tGrpLI02")
   USE IN ("tGrpLI02")
ENDIF

IF USED("tIndLI")
   USE IN ("tIndLI")
ENDIF

IF USED("tIndLI1")
   USE IN ("tIndLI1")
ENDIF

IF USED("tIndLI2")
   USE IN ("tIndLI2")
ENDIF

IF USED("tIndLI01")
   USE IN ("tIndLI01")
ENDIF

IF USED("tIndLI02")
   USE IN ("tIndLI02")
ENDIF

IF USED("tPCM")
   USE IN ("tPCM")
ENDIF

IF USED("tPCM1")
   USE IN ("tPCM1")
ENDIF

IF USED("tPCM2")
   USE IN ("tPCM2")
ENDIF

IF USED("tPCM01")
   USE IN ("tPCM01")
ENDIF

IF USED("tPCM02")
   USE IN ("tPCM02")
ENDIF

RETURN   
**********************************************************************
PROCEDURE GetCliLst
**********************************************************************
*** Get the site and agency assignments, apply user selections if any
cOldArea = ALIAS()
=OPENFILE("Agency","Agency")
cAgency_ID = AllTrim(Agency.agency)
cAgc_Name = Agency.descript1

IF !EMPTY(cOldArea)
   SELECT (cOldArea)
ENDIF
RETURN .t.
