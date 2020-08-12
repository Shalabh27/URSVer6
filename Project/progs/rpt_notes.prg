Parameters lPrev, ;       && Preview     
           aSelvar1,;     && select parameters from selection list
           nOrder, ;      && order by
           nGroup, ;      && report selection    
           lcTitle, ;     && report selection    
           Date_from ,;   && from date
           Date_to, ;     && to date   
           Crit , ;       && name of param
           lnStat, ;      && selection(Output)  page 2
           cOrderBy       && order by description

Acopy(aSelvar1, aSelvar2)
lcserv  = ""
cEncType = 0
ccwork = ""
lcprog = ""
cTc_Id =""

&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcserv = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CCWORK"
      ccwork = aSelvar2(i, 2)
   EndIf

   If Rtrim(aSelvar2(i, 1)) = "CENCTYPE"
      cEncType = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "LCPROG"
      lcProg = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CTC_ID"
      cTc_Id = aSelvar2(i, 2)
   EndIf

EndFor

If !Empty(cEncType)
   SET DECIMALS TO 0
   cEncType = Val(cEncType)
   SET DECIMALS to
EndIf

=close_data()

PRIVATE gchelp
gchelp='Progress Notes Report Screen'
cTitle = "Progress Notes Report"
cDate = DATE()
cTime = TIME()

MyFilt='!Empty(ai_enc.act_dt)'
MyFilt=MyFilt+IIF(Empty(Date_from),""," And (ai_enc.act_dt >= Date_from)")
MyFilt=MyFilt+IIF(Empty(Date_to),""," And (ai_enc.act_dt <= Date_to)")
MyFilt=MyFilt+Iif(Empty(CTC_ID),"", +Iif(Empty(MyFilt),""," And")+" ai_enc.tc_id=cTC_ID")
MyFilt=MyFilt+Iif(Empty(CCWORK),"", +Iif(Empty(MyFilt),""," And")+" ai_enc.worker_id=cCWORK")
MyFilt=MyFilt+Iif(Empty(Date_from),"", +Iif(Empty(MyFilt),""," And")+" (ai_enc.act_dt >= Date_from)")
MyFilt=MyFilt+Iif(Empty(Date_to),"", +Iif(Empty(MyFilt),""," And")+" (ai_enc.act_dt <= Date_to)")
MyFilt=MyFilt+Iif(Empty(lcprog),"", +Iif(Empty(MyFilt),""," And")+" ai_enc.program = TRIM(lcprog)")
MyFilt=MyFilt+Iif(Empty(cEncType),"", +Iif(Empty(MyFilt),""," And")+" ai_enc.enc_id In (cEncType)")
MyFilt=MyFilt+Iif(Empty(lcserv),"", +Iif(Empty(MyFilt),""," And")+" ai_enc.serv_cat In (lcserv)")

Select  ;
	cli_cur.tc_id,;
   cli_cur.id_no,;
   cli_cur.last_name,;
   cli_cur.first_name,;
	cli_cur.placed_dt, ;
   ai_enc.act_id, ;
   ai_enc.program, ;
   ai_enc.serv_cat, ;
	ai_enc.enc_id, ;
   ai_enc.act_dt, ;
   ai_enc.beg_tm,;
	ai_enc.beg_am, ;
   ai_enc.end_tm, ;
   ai_enc.end_am, ;
   ai_enc.worker_id,;
	serv_cat.descript,;
	ai_enc.SITE,;
   ai_enc.enc_note,;
	Padr(site.descript1,30) As Sitename ,;
	enc_list.description As ENCNAME,;
	Padr(oApp.FormatName(staff.last,staff.first),25) As ENCWORK,;
   lcTitle As lcTitle, ;
   Crit As Crit, ;
   cDate As cDate, ;
   cTime As cTime, ;
   Date_from As Date_from, ;
   date_to As date_to;
From ;
	cli_cur, ;
   ai_enc, ;
   enc_list,;
   serv_cat,;
   userprof,;
   staff ,site;
Where ;
	cli_cur.tc_id=ai_enc.tc_id;
	And !Empty(ai_enc.act_dt);
	And ai_enc.serv_cat=serv_cat.code;
	And ai_enc.enc_id=enc_list.enc_id;
	And ai_enc.worker_id=userprof.worker_id ;
	And userprof.staff_id=staff.staff_id ;
	And ai_enc.site=site.site_id ;
   And &MyFilt ;
Into Cursor ;
	MyEnc ReadWrite

*!*   If Used('MyEnc') 
*!*      Use in MyEnc
*!*   EndIf
*!*   	
*!*   SELECT 0
*!*   USE (DBF('EncCli')) ALIAS MyEnc AGAIN EXCLUSIVE
*!*   Use in EncCli

SELE MyEnc
 **VT 08/27/2010 Dev Tick 4807 add Upper
 
Do Case   
   CASE nOrder = 1
        **cOrd = "MyEnc.last_name+MyEnc.first_name+STR(Myenc.act_dt-{01/01/1900})"
         cOrd = "Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))+STR(Myenc.act_dt-{01/01/1900})"
  
   CASE nOrder = 2
        cOrd = "Myenc.act_dt"
  
   CASE nOrder = 3
        **cOrd = "MyEnc.ENCNAME+MyEnc.last_name+MyEnc.first_name+STR(Myenc.act_dt-{01/01/1900})"
        cOrd = "MyEnc.ENCNAME+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))+STR(Myenc.act_dt-{01/01/1900})"
  
   CASE nOrder = 4
        **cOrd = "MyEnc.ENCWORK+MyEnc.last_name+MyEnc.first_name+STR(Myenc.act_dt-{01/01/1900})"
        cOrd = "MyEnc.ENCWORK+Upper(Alltrim(MyEnc.last_name)+Alltrim(MyEnc.first_name))+STR(Myenc.act_dt-{01/01/1900})"
EndCase 

oApp.Msg2User("OFF")   
SELECT MyEnc 
INDEX ON &cOrd TAG repord
GO TOP
=openfile("Serv_Cat","Code")

SELECT MyEnc
SET RELATION TO Serv_Cat INTO Serv_Cat
Go Top 
if EOF()
    oApp.msg2user('NOTFOUNDG')
Else
            gcRptName = 'rpt_notes'
            DO CASE
               CASE lPrev = .f.
                  Report Form rpt_notes To Printer Prompt Noconsole NODIALOG 
               CASE lPrev = .t.     
                  oApp.rpt_print(5, .t., 1, 'rpt_notes', 1, 2)
            ENDCASE
EndIf
 

SET CENT ON
*************************
Function close_data

If Used('MyEnc')
   use in MyEnc
EndIf
Return
***********************************************************************
FUNCTION ShowTime
PARAMETER cmtime
RETURN IIF(LEFT(cmtime,1)='0'," "+(SUBSTR(cmtime,2,1)+":"+SUBSTR(cmtime,3,2)+" "),(LEFT(cmtime,2)+":"+SUBSTR(cmtime,3,2)+" "))

