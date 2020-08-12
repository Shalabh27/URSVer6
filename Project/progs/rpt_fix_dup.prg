Parameters gcTc_id, receiv_tc_id

Local cAlias
cAlias = Alias()

If Used('pr_list')
   Use In pr_list
Endif
   
Create Cursor pr_list (cRId_no C(20), cRname C(45), cSId_no C(20), cSName C(45), ;
                       cInfo M, cDate D, cTime C(10))

                     
***Receiver
Select cli_cur
Locate For cli_cur.tc_id = receiv_tc_id
If Found()
   m.cRId_no = cli_cur.id_no
   m.cRName = oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)
Else
   m.cRId_no = Space(20)
   m.cRName = Space(45)
Endif

***Sender
Locate For cli_cur.tc_id = gcTc_id   
If Found()
   m.cSId_no = cli_cur.id_no
   m.cSName = oApp.FormatName(cli_cur.last_name, cli_cur.first_name, cli_cur.mi)
Else
   m.cSId_no = Space(20)
   m.cSName = Space(45)
Endif

m.cTime = Time()
m.cDate = Date()

m.cInfo = ''

Select fix_dup_log
If Seek(gcTc_id, 'fix_dup_log','in_work')
   If !Empty(fix_dup_log.problems_found)
      m.cInfo = fix_dup_log.problems_found
      Insert Into pr_list From memvar
   Else
      oApp.msg2user('NOTFOUNDG')   
      Return
   Endif
Else
   oApp.msg2user('NOTFOUNDG')   
   Return    
Endif

   
Select pr_list
Go top
Report Form rpt_fix_dup To Printer Prompt Noconsole NODIALOG 

If !Empty(cAlias)
   Select &cAlias
Endif
   
Return   
