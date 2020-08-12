Parameters lPrev, ;    && Preview
           aSelvar1, ; && select parameters from selection list
           nOrder, ;   && order by
           nGroup, ;   && report selection
           lcTitle, ;  && report selection
           st_from , ; && from date
           st_to, ;    && to date   
           Crit , ;    && name of param
           lnStat, ;   && selection(Output)  page 2
           cOrderBy    && order by description

Acopy(aSelvar1, aSelvar2)

cGroup = "" 
cCWork = ""
cCSite = ""
&& Search For Parameters

For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "CGROUP"
      cGroup = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      cCWork = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCSITE"
      cCSite = aSelvar2(i, 2)
   Endif
EndFor

PRIVATE gchelp
gchelp = "Group Activities Report Screen"
cDate = DATE()
cTime = TIME()
cFiltExpr = ""
cFiltExpr = IIF(EMPTY(cGroup)	, "", "grpatt.grp_id = cGroup")
cFiltExpr = cFiltExpr + IIF(EMPTY(cCWork)	, "", IIF(!Empty(cFiltExpr),".and.","") + " grpatt.worker_id = cCWork")
cFiltExpr = cFiltExpr + IIF(EMPTY(cCSite)	, "", IIF(!Empty(cFiltExpr),".and.","") + " grpatt.site = cCSite")
cFiltExpr = cFiltExpr + IIF(EMPTY(st_from), "", IIF(!Empty(cFiltExpr),".and.","") + " grpatt.act_dt >= st_from")
cFiltExpr = cFiltExpr + IIF(EMPTY(st_to), "", IIF(!Empty(cFiltExpr),".and.","") + " grpatt.act_dt <= st_to")

cWhereExp = IIF(!Empty(cFiltExpr), " AND " + cFiltExpr, "")

************************  Opening Tables ************************************
=OPENFILE("staff"		, "staff_id")
=OPENFILE("userprof"	, "worker_id")
** SET RELATION TO staff_id INTO staff

=OPENFILE("SITE", "SITE_ID")
=OPENFILE("group", "grp_id2") &&tc+grp_id

SELECT cli_cur
SET ORDER TO tc_id

=OPENFILE("ai_enc","att_id")
SET RELATION TO tc_id INTO cli_cur

If Used('totals')
   Use in totals
EndIf

SELECT ;
	grp_id,  1 as RepGroup, ;
   COUNT(dist grpatt.att_id) as ses_count, ;
   COUNT(ai_enc.tc_id) as att_count ;
FROM ;
	grpatt, ai_enc ;
WHERE ;
	grpatt.att_id = ai_enc.att_id ;
	&cWhereExp ;
GROUP BY ;
	grp_id ;
INTO CURSOR ;
	totals
INDEX ON grp_id TAG grp_id

If Used('Rep_Totals')
   Use in Rep_Totals
EndIf

SELECT ;
	RepGroup, SUM(ses_count) AS ses_count, SUM(att_count) as att_count ;
FROM ;
	totals ;
GROUP BY ;
	RepGroup ;
INTO CURSOR ;
	Rep_Totals

If Used('mattemp')
   Use in mattemp
EndIf

Select PADR(material.descript,40) AS mat_desc, ;
       PADR(ALLTRIM(STR(grpattmt.quantity)),6, " ") AS mat_quant, ;
       grpattmt.att_id ;
FROM 	grpattmt, material ;
WHERE	grpattmt.material = material.code ;
INTO CURSOR mattemp ; 
order by 3, 1

If Used('mat_prov')
   Use in mat_prov
EndIf

Select 0
Create Cursor mat_prov (att_id C(10), data M)
Index on att_id tag att_id

Select mattemp
	Go Top
	cAtt_id = Space(10)
	jcString = ''

	Do While Not Eof()
			cAtt_id = mattemp.att_id
			jcString = jcString + " Quantity           Description" + chr(13)
		
		Scan While 	cAtt_id = mattemp.att_id
			jcString = jcString + '     ' + Padr(mat_quant, 6, " ") + Space(9) + mat_desc + chr(13)
		EndScan
	
		Insert Into mat_prov (att_id, ;
							 data) ;
					  Values (cAtt_id, ;
					     	 jcString)
		jcString = ''				     	 
	
	EndDo

If Used('top_temp')
   Use in top_temp
EndIf

* jss, 3/12/03, add following select to grab all topics associated with att_id's for this group
SELECT ;
	grpatt.grp_id, ;
	grpatt.att_id, ;
	topics.descript AS top_desc ;
FROM ;
	grpatt, ;
	ai_topic, ;
	topics ;
WHERE ;
	grpatt.att_id = ai_topic.att_id ;
AND ai_topic.serv_cat = topics.serv_cat ;
AND ai_topic.code     = topics.code ;		
   &cWhereExp ;
GROUP BY 1, 2, 3 ;   
INTO CURSOR ;
	top_temp

If used('tops')
   Use in tops
EndIf

* now, create cursor for loading topic info 
SELECT 0
CREATE CURSOR tops (att_id C(10), topdata M)
INDEX ON att_id TAG att_id

* load the topics cursor
SELECT top_temp
GO TOP
cAtt_id = SPACE(10)
jcString = ''

DO WHILE NOT EOF()
	cAtt_id = top_temp.att_id
	SCAN WHILE 	cAtt_id = top_temp.att_id
		jcString = jcString + top_desc + chr(13)
	ENDSCAN
	
	INSERT INTO tops	 	(att_id, ;
							 topdata) ;
					VALUES 	(cAtt_id, ;
					     	 jcString)
	jcString = ''				     	 
ENDDO

If Used('colltemp')
   Use in colltemp
EndIf

* now, create cursor of collaterals associated with clients in group
SELECT DISTINCT ;
	ai_enc.act_id, ;
	oApp.FormatName(Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(client.last_name)), client.last_name), ;
   Iif(oApp.gldataencrypted, osecurity.decipher(Alltrim(client.first_name)), client.first_name), client.mi) AS collname ;
FROM ;
	ai_enc, ;
	grpatt, ;
	ai_colen, ;
	client ;
WHERE ;
	grpatt.att_id = ai_enc.att_id ;
   AND ai_enc.act_id = ai_colen.act_id ;
   AND ai_colen.client_id = client.client_id ;
   &cWhereExp ;
INTO CURSOR ;
	colltemp

If Used('colls')    
   Use in colls 
EndIf
	
* create cursor for loading collateral info	
SELECT 0
CREATE CURSOR colls (act_id C(10), colldata M)
INDEX ON act_id TAG act_id

* load the collaterals cursor
SELECT colltemp
GO TOP
cAct_id = SPACE(10)
jcString = ''

DO WHILE NOT EOF()
	cAct_id = colltemp.act_id
	SCAN WHILE 	cAct_id = colltemp.act_id
		jcString = jcString + collname + chr(13)
	ENDSCAN
	
	INSERT INTO colls	(act_id, ;
							 colldata) ;
               VALUES (cAct_id, ;
					     	 jcString)
	jcString=''
ENDDO

=OPENFILE("settings","code")
=OPENFILE("grpatt","grp_id")


If Used('t_att')
   Use in t_att
Endif

**VT 03/01/2010 Dev Tick 6320 add  PEMS Related Information to the end of the select and unit_del table
Select ;
      grpatt.att_id, ;
      grpatt.grp_id, ;
      grpatt.act_dt, ;
      grpatt.on_site, ;
      grpatt.location, ;
      grpatt.beg_tm, ;
      grpatt.beg_am, ;
      grpatt.end_tm, ;
      grpatt.end_am, ;
      grpatt.zip, ;   
      grpatt.cdcsetting, ;
      grpatt.grp_note, ;
      group.descript, ;
      Crit as  Crit, ;   
      cDate as cDate, ;
      cTime as cTime, ;
      st_from as Date_from, ;
      st_to as date_to, ;
      serv_cat.descript as serv_cat, ;
      enc_list.description as enc_type, ;
      settings.descript as cdc_set, ;
      Staff.last as st_last_name, ;
      Staff.first as st_first_name, ;
      Site.descript1, ;
      IIF(grpatt.inc_provided=.t., 'Yes', 'No ') as inc_provided, ;
      grpatt.cycle_number, ;
      grpatt.session_number,;
      grpatt.unit_delivery as unit_del_code, ;
      unit_del.descript as unit_del;
from grpatt ;
     inner join group on ;
           grpatt.grp_id = group.grp_id and ;
           group.tc = gcTc ;    
     inner join userprof on ;
            userprof.worker_id = grpatt.worker_id ;
     inner join staff on ;
            userprof.staff_id = staff.staff_id ;
     inner join site on ;
            grpatt.site = site.site_id ; 
     inner join serv_cat on ;
            grpatt.serv_cat = serv_cat.code ;  
     inner join enc_list on ;
            grpatt.enc_id = enc_list.enc_id ;
     left outer join Settings on ;
            grpatt.cdcsetting = settings.code ;
     LEFT OUTER JOIN unit_del ON ;
     			unit_del.code=grpatt.unit_delivery ;
where &cFiltExpr ;               
into cursor t_att  Readwrite;
order by group.descript, grpatt.act_dt desc, grpatt.beg_tm, ;
               grpatt.beg_am, grpatt.end_tm, grpatt.end_am 

***VT 12/05/2007
If Used('t_s')
   Use in t_s
Endif


If Used('t_serv')
   Use in t_serv
Endif

Select 0
Create Cursor t_serv (att_id C(10), serv_pr M)
Index on att_id tag att_id

Select Distinct t_att.att_id, serv_list.description as serv_pr ;
from t_att ;
   inner join ai_serv on ;
      t_att.att_id = ai_serv.att_id ;
   inner join serv_list on ;
      ai_serv.service_id = serv_list.service_id ;
into cursor t_s

Select t_s
Go Top
  cAtt_id = Space(10)
  jcString = ''

Do While Not Eof()
    cAtt_id = t_s.att_id
    Scan While    cAtt_id = t_s.att_id
         jcString = jcString + serv_pr + chr(13)
    EndScan
   
    Insert Into t_serv (att_id, ;
                        serv_pr) ;
               Values (cAtt_id, ;
                       jcString)
    jcString = ''                     
   
EndDo

If Used('t_s')
   Use in t_s
Endif

      
***Index on grp_id tag grp_id 
SELECT ai_enc
SET RELATION TO act_id INTO colls ADDI

Select t_att

SET RELATION TO att_id INTO Ai_enc
SET RELATION TO grp_id INTO totals ADDITIVE
SET RELATION TO att_id INTO mat_prov ADDITIVE
SET RELATION TO att_id INTO tops ADDITIVE
**VT 12/05/2007
SET RELATION TO att_id INTO t_serv ADDITIVE
SET SKIP TO ai_enc
*
oApp.msg2user("OFF")
gcRptName = 'rpt_grp_att' 

Select t_att
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
ELSE
           DO CASE
               CASE lPrev = .f.
                     Report Form rpt_grp_att  To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     
                     oApp.rpt_print(5, .t., 1, 'rpt_grp_att', 1, 2)
            ENDCASE
EndIf