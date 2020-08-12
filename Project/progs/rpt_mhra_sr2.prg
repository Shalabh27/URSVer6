* Program...........: SUMMSERV.PRG (Summary of Services Provided during the Reporting Month)
* Rpt_mhra_sr2.prg
* jss, 9/27/07, new version of program rpt_mhra_ser, new counting methodology for services
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
m.date_from = date_from
dDate_to = date_to

Select agency, descript1 From Agency where .t. into array aAgency
If _tally=0
   =oApp.Msg2user("INFORM","Agency table empty problem...exiting")
   Return
EndIf

cAgency_ID   = AllTrim(aAgency(1))
cAgc_Name    = AllTrim(aAgency(2))
m.agencydesc = AllTrim(aAgency(2))

=clean_data()

Select descript from contrinf where cid=cContract into array aContrinf
If _tally=0
   =oApp.Msg2user("INFORM","Contract " + cid + " not found in Contrinf Table...exiting")
   Return
EndIf
m.ContrDes=aContrinf(1)

Select start_dt as ytd_from from contract where contract.con_id=cContract into array aYtdfrom
If _tally=0
   =oApp.Msg2user("INFORM","Contract " + cContract + " not found in Contract Table...exiting")
   Return
EndIf
m.ytd_from=aYtdfrom(1)
		
FOR i = 1 TO 2
	dDate_From = IIF(i = 1, m.date_from, m.ytd_from)

* Part I
* we're selecting the projected info
 

* grab projected numbers for period
   Select   a.Contract, ;
            a.SerT, ;
            b.Descript, ;
            b.SerUnit, ;
            b.NofCl, ;
            STR(SUM(a.nc)) AS nc_proj, ;
            STR(SUM(a.ns)) AS ns_proj ;
   From     SerTag   a ;
      Join  SerType  b on a.SerT     = b.code ;
      Join  Contract c on a.contract = c.con_id ;
   Where    a.Contract = cContract ;
     and    b.Unit_type <> '4' ;
     and    BETWEEN(CTOD(SUBSTR(a.cm,2,2) + "/01/" + IIF(VAL(RIGHT(a.cm,2))<90, '20', '19') + RIGHT(a.cm,2)), ;
                                     dDate_from, dDate_to) ;
     and    a.nc + a.ns > 0 ;           
     and    c.Start_dt <= dDate_From ;
     and    c.End_dt   >= dDate_To ;
   Into Cursor ;   
            tTemp1 ;
   Group by 1, 2, 3, 4, 5
  
* create cursor with zero counts for each SerT to be used in union with ttemp1
   Select   a.Cid AS Contract, ;
            c.SerT, ;
            b.Descript, ;
            b.SerUnit, ;
            b.NofCl, ;
            STR(0) AS nc_proj, ;
            STR(0) AS ns_proj ;
     From   ContrInf a ;
       Join ConSer   c on a.Contype = c.ConT ;
       Join Contract d on a.Cid     = d.Con_id ;
       Join SerType  b on b.Code    = c.SerT ;
   Where    a.Cid = cContract ;
     and    b.Unit_type <> '4' ;
     and    BETWEEN(dDate_from, cnStart_Dt, cnEnd_Dt) ;
     and    D.Start_dt <= dDate_From ;
     and    D.End_dt   >= dDate_To ;
     Into Cursor ;
              tTemp2
     
     Select   a.*, ;
              b.Descript AS ContrDes ;
     From     tTemp1 a ;
       Join   ContrInf b on a.Contract = b.Cid ;
     Union ;      
     Select   a.*, ;
              b.Descript AS ContrDes ;
     From     tTemp2 a ;
       Join   ContrInf b on a.Contract = b.Cid ;
     Where    (a.Contract + a.SerT) NOT IN ;
                 (SELECT Contract + SerT FROM tTemp1) ;
     Into Cursor ;
              tTemp3 ;
     Order by 1, 2          


  * Part II
  * we're selecting services provided during the reporting month.
  * MHRA decided that the agency would be responsible for establishing an MHRA program,
  * that would be included only in one contract.

   Select   Contract.Con_id AS Contract, ;
            ContrInf.Descript AS ContrDes, ;
            ConSD.Ser_Type AS SerT, ;
            Ai_Serv.Tc_ID, ;
            Ai_Serv.Act_ID, ;
            Ai_Serv.date, ;
            Ai_Serv.Serv_Cat, ;
            Ai_Enc.Enc_id, ;
            Ai_Serv.Serv_id, ;
            Ai_Serv.Service_id, ;
            Ai_Enc.Att_ID ;
   From     ConSd, ;
            Ai_Enc, ;
            Ai_Serv, ;
            Program, ;
            Contract, ;
            ContrInf, ;
            Ai_Site, ;
            Site ;
   Where    ContrInf.Cid = cContract ;
     and    ConSD.Contract = Contract.Cid ;
     and    Contract.Con_ID = ContrInf.Cid ;
     and    Contract.Start_dt <= dDate_From ;
     and    Contract.End_dt   >= dDate_To ;
     and    ConSD.Enc_id = Ai_Enc.Enc_id ;
     and    ConSD.Serv_Cat = Ai_Enc.Serv_Cat ;
     and    ConSD.Service_id = Ai_Serv.Service_id;
     and    Ai_Enc.Act_ID = Ai_Serv.Act_ID ;
     and    Ai_Enc.Program = Program.Prog_ID ;
     and    Ai_Enc.Program = Contract.Program ;
     and    Ai_Enc.act_dt Between dDate_From AND dDate_To ;
     and    Ai_Enc.Tc_ID = Ai_Site.Tc_ID ;
     and    Ai_Site.Tc_id + Dtos(Ai_Site.Effect_dt) + oApp.TIME24(Ai_Site.time,Ai_site.am_pm) ;
                  In (Select   ai_site2.tc_id + Max(Dtos(ai_site2.effect_dt)+ oApp.TIME24(ai_site2.time, ai_site2.am_pm)) ;
                      From     ai_site ai_site2 ;
                      Where    ai_site2.effect_dt <= dDate_To ;
                      Group by ai_site2.tc_id) ;
     and    Site.Site_ID = Ai_Site.Site ;
     and    Site.Site_ID = cCSite ;
     and    Site.Agency_ID = cAgency_ID ;
   Into Cursor ;
           tTemp10 

* jss, 9/28/07: count unduplicated clients by ser_type
   Select    a.Contract, ;
             a.ContrDes, ;
             a.SerT, ;
             Padl(Str(Count(Dist tc_id),10,0), 10,'0') AS nc_undup ;
   From      tTemp10 a ;
       Join ;
             SerType b ON a.SerT = b.Code ;          
   Group by  1, 2, 3 ;
   Into Cursor ;
             temp_undup1
             
* fill in zeroes for all other sertypes in contract and union with sertypes with unduplicated client counts
   Select * from temp_undup1 ;
   Union ;
   Select    cContract as Contract, ;
             m.Contrdes as Contrdes, ;
             a.code as SerT, ;
             '0000000000' as nc_undup ;
   From      SerType a ;
   Where     a.code Not In (Select SerT from temp_undup1) ;
     and     a.code In (Select SerT from ttemp3) ;
   Into Cursor ;
             temp_undup          

* count services provided: for groups, just count distinct att_ids (sessions), for individuals, all services

* count group services first
   Select   a.Contract, ;
            a.ContrDes, ;
            a.SerT, ;
            Count(Dist a.Att_id) AS ns ;
   From     tTemp10 a ;
       Join ;
            SerType b  ON a.SerT = b.Code ;
   Where !Empty(a.att_id) ;        
   Group by 1, 2, 3;
   Into Cursor ;
            temp_servg
            
* now count individual services
   Select   a.Contract, ;
            a.ContrDes, ;
            a.SerT, ;
            Count(a.serv_id) AS ns ;
   From     tTemp10 a ;
       Join ;
            SerType b ON a.SerT = b.Code ;
   Where Empty(a.att_id) ;        
   Group by 1, 2, 3;
   Into Cursor ;
            temp_servi
            
* now, combine the two cursors on any ser_types found in both
   Select   a.Contract, ;
            a.ContrDes, ;
            a.SerT, ;
            Padl(Str(a.ns + b.ns), 10,'0') as ns ;
   From     temp_servg a ;
       Join ;
            temp_servi b ON a.SerT = b.SerT ;
   Order by 1, 2, 3;
   Into Cursor ;
            temp_serv1
            
* combine the rest of the services found only in temp_servi or only in temp_servg
   Select * from  temp_serv1 ;
   Union ;
   Select   Contract, ;
            ContrDes, ;
            SerT, ;
            Padl(Str(ns), 10,'0') as ns ;
   From     temp_servg ;
    Where SerT Not in (Select SerT from temp_serv1) ;
   Union ;
   Select   Contract, ;
            ContrDes, ;
            SerT, ;
            Padl(Str(ns), 10,'0') as ns ;
   From     temp_servi ;
    Where SerT Not in (Select SerT from temp_serv1) ;
   Into Cursor ;
            temp_serv2

* fill in zeroes for all other sertypes in contract and union with sertypes with service counts
   Select * from temp_serv2 ;
   Union ;
   Select    cContract as Contract, ;
             m.Contrdes as Contrdes, ;
             a.code as SerT, ;
             '0000000000' as ns ;
   From      SerType a ;
   Where     a.code Not In (Select SerT from temp_serv2) ;
     and     a.code In (Select SerT from ttemp3) ;
   Into Cursor ;
             temp_serv          
                                    
* count total client encounters (count all serv_ids)            
   Select   a.Contract, ;
            a.ContrDes, ;
            a.SerT, ;
            Padl(Str(Count(a.serv_id)), 10,'0') AS nc ;
   From     tTemp10 a ;
       Join ;
            SerType b ON a.SerT = b.Code ;
   Group by 1, 2, 3;
   Into Cursor ;
            temp_cli1

* fill in zeroes for all other sertypes in contract and union with sertypes with client encounter counts
   Select * from temp_cli1 ;
   Union ;
   Select    cContract as Contract, ;
             m.Contrdes as Contrdes, ;
             a.code as SerT, ;
             '0000000000' as nc ;
   From      SerType a ;
   Where     a.code Not In (Select SerT from temp_cli1) ;
     and     a.code In (Select SerT from ttemp3) ;
   Into Cursor ;
             temp_cli          
            
* now, create cursor with all counts
   Select   a.Contract, ;
            a.ContrDes, ;
            a.SerT, ;
            c.ns, ;
            b.nc, ;
            a.nc_undup ;
   From     temp_undup a;
       Join temp_cli   b on a.SerT=b.SerT ;       
       Join temp_serv  c on a.SerT=c.SerT ;       
   Into Cursor ;
            temp_cur 
            				
* now, join cursor to projected numbers cursor
   cCursName = "tTemp5" + STR(i,1) 
   Select   a.Contract, ;
            a.ContrDes, ;
            STR(i,1) AS Part, ;
            a.SerT, ;
            c.Descript, ;
            c.SerUnit, ;
            c.Unit_type, ;
            c.NofCl, ;
            Int(Val(a.ns)) as ns, ;
            Int(Val(a.nc)) as nc, ;
            Int(Val(a.nc_undup)) as nc_undup, ;
            Int(Val(b.ns_proj)) as ns_proj, ;
            Int(Val(b.nc_proj)) as nc_proj ;
   From     temp_cur a;
       Join ttemp3   b on  a.SerT = b.SerT ;
       Join SerType c  on  a.SerT = c.Code ;
   Into Cursor ;    
      &cCursName

Endfor  

Select 0
Use (Dbf("tTemp52")) Again Alias tPart

Append From Dbf("tTemp51")

Select tPart.*, ;
      cMonthYear as cMonthYear, ;
      cDate  as cDate, ;
      cTime  as cTime, ;
      cAgc_Name as cAgc_Name ;  
From tPart ;
Into Cursor Final ;
Order by Contract, Part, SerT

Select Final

oApp.Msg2User('OFF')
Go Top

IF EOF()
    oApp.Msg2user('NOTFOUNDG')
Else
    gcRptName = 'rpt_mhra_sr2' 
    DO CASE
       CASE lPrev = .f.
            Report Form rpt_mhra_sr2  To Printer Prompt Noconsole NODIALOG 
       CASE lPrev = .t.    
            oApp.rpt_print(5, .t., 1, 'rpt_mhra_sr2', 1, 2)
    Endcase       
EndIf

********************
Function clean_data

IF USED("tTemp1")
   USE IN ("tTemp1")
ENDIF

IF USED("tTemp2")
   USE IN ("tTemp2")
ENDIF

IF USED("tTemp3")
   USE IN ("tTemp3")
ENDIF

IF USED("tTemp10")
   USE IN ("tTemp10")
ENDIF

IF USED("temp_undup1")
   USE IN ("temp_undup1")
ENDIF

IF USED("temp_undup")
   USE IN ("temp_undup")
ENDIF

IF USED("temp_servg")
   USE IN ("temp_servg")
ENDIF

IF USED("temp_servi")
   USE IN ("temp_servi")
ENDIF

IF USED("temp_serv1")
   USE IN ("temp_serv1")
ENDIF

IF USED("temp_serv")
   USE IN ("temp_serv")
ENDIF

IF USED("temp_cli1")
   USE IN ("temp_cli1")
ENDIF

IF USED("temp_cli")
   USE IN ("temp_cli")
ENDIF

IF USED("temp_cur")
   USE IN ("temp_cur")
ENDIF

IF USED("ttemp51")
   USE IN ("ttemp51")
ENDIF

IF USED("ttemp52")
   USE IN ("ttemp52")
ENDIF

IF USED("tPart")
   USE IN ("tPart")
ENDIF

RETURN	

