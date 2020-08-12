Parameters lPrev, ;     && Preview     
           aSelvar1, ;  && select parameters from selection list
           nOrder, ;    && order by
           nGroup, ;    && report selection    
           lcTitle, ;   && report selection    
           Date_from, ; && from date
           Date_to, ;   && to date   
           Crit, ;      && name of param
           lnStat, ;    && selection(Output)  page 2
           cOrderBy     && order by description

Acopy(aSelvar1, aSelvar2)

lcserv  = ""
cEncType = 0

If nGroup = 1
   lcTitle = 'All'
EndIf

If nGroup = 2
   lcTitle = 'Active Only'
EndIf   

If nGroup = 3
   lcTitle = 'Not Active'
EndIf  


&& Search For Parameters
For i = 1 to Alen(aSelvar2, 1)
   If Rtrim(aSelvar2(i, 1)) = "LCSERV"
      lcServ = aSelvar2(i, 2)
   EndIf
   
   If Rtrim(aSelvar2(i, 1)) = "CENCTYPE"
      cEncType = aSelvar2(i, 2)
   EndIf
EndFor

If !Empty(cEncType)
   SET DECIMALS TO 0
   cEncType = Val(cEncType)
   SET DECIMALS to
EndIf

PRIVATE gchelp
gchelp='Encounters and Services Listing Screen'
cTitle = "Encounters And Services Listing"
cDate = DATE()
cTime = TIME()

=OpenView("lv_enc_type", "urs")
SELECT lv_enc_type

IF !Empty(cEncType) 
    If !EMPTY(lcserv)  
       Locate for lv_enc_type.enc_id = cEncType And lv_enc_type.serv_cat = lcserv
       If !Found()
            oApp.msg2user("INFORM","The picked Encounter "+CHR(13);
            +"does not belong to the Service Category"+CHR(13);
            +"Please pick the combination again")
            RETURN .f.
       Endif
    Else
       Locate for lv_enc_type.enc_id = cEncType
    Endif
ENDIF

* jss, 11/15/04, add category and category description
* jss, 12/22/04, add mai mapping
Local cWhere, cWhere1
cWhere = ''
cWhere1 = ''

cWhere = IIF(EMPTY(cEncType),""," AND lv_enc_type.enc_id = cEncType")

***VT newdevel ticket 2528 09/22/2006
cWhere = Iif(!Empty(cWhere), cWhere  +  ;
         Iif(nGroup = 2, " And lv_service.active = .t. ", Iif(nGroup = 3, " And lv_service.active = .f. ", ''))  , ;
         Iif(nGroup = 2, " And lv_service.active = .t. ", Iif(nGroup = 3, " And lv_service.active = .f. ", ''))) 

cWhere1 = Iif(!Empty(cWhere), cWhere  +  ;
         Iif(nGroup = 2, " And lv_enc_type.active = .t. ", Iif(nGroup = 3, " And lv_enc_type.active = .f. ", ''))  , ;
         Iif(nGroup = 2, " And lv_enc_type.active = .t. ", Iif(nGroup = 3, " And lv_enc_type.active = .f. ", ''))) 
**End                  
        
SELECT  ;
   lv_enc_type.serv_cat, ;
   serv_cat.descript as catdesc,;
   lv_enc_type.category, ;
   SPACE(50) as categdesc, ;
   lv_enc_type.enc_id, ;
   lv_enc_type.descript as enc, ;
   lv_enc_type.aar_info as encaar,;
   lv_service.service_id  as serv ,;
   lv_service.service  as servdesc, ;
   lv_service.aar_info  as servaar, ;
   lv_enc_type.cadr_map as enccadr, ;
   lv_service.cadr_map, ;
   lv_service.cadrmap2, ;
   lv_enc_type.mai_map as encmai, ;
   lv_service.mai_map, ;
   Iif(lv_service.active = .f., ' No', 'Yes') as active, ;
   Iif(lv_enc_type.active = .f., ' No', 'Yes') as active_enc, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;    
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;   
FROM ;
   serv_cat, lv_enc_type, lv_service ;
WHERE ;
   (serv_cat.code = lcserv OR EMPTY(lcserv));
   AND serv_cat.code = lv_enc_type.serv_cat;
   AND lv_enc_type.enc_id = lv_service.enc_id;
   AND lv_enc_type.serv_cat = lv_service.serv_cat;
   &cWhere ;
UNION  ;
SELECT  ;
   lv_enc_type.serv_cat, ;
   serv_cat.descript as catdesc,;
   lv_enc_type.category, ;
   SPACE(50) as categdesc, ;
   lv_enc_type.enc_id, ;
   lv_enc_type.descript as enc, ;
   lv_enc_type.aar_info as encaar,;
   0               as serv ,;
   "No Services for Encounter Type"   as servdesc, ;
   " "               as servaar, ;
   lv_enc_type.cadr_map as enccadr,;
   "    " as cadr_map, ;
   "    " as cadrmap2, ;
   lv_enc_type.mai_map as encmai, ;
   "  "   as mai_map, ;
   Iif(lv_enc_type.active = .f., ' No', 'Yes') as active, ;
   Iif(lv_enc_type.active = .f., ' No', 'Yes') as active_enc, ;
   lcTitle as lcTitle, ;
   Crit as  Crit, ;   
   cDate as cDate, ;
   cTime as cTime, ;
   Date_from as Date_from, ;
   date_to as date_to;       
FROM ;
   serv_cat, lv_enc_type ;
WHERE ;
   (serv_cat.code = lcserv OR EMPTY(lcserv)) ;
   AND serv_cat.code = lv_enc_type.serv_cat ;
   AND !EXIST (SELECT * FROM lv_service WHERE ;
                  lv_service.enc_id = lv_enc_type.enc_id ;
                  AND lv_service.serv_cat = lv_enc_type.serv_cat) ;
   AND !EXIST (SELECT * FROM lv_service WHERE ;
                  EMPTY(lv_service.enc_id) ;
                  AND lv_service.serv_cat = lv_enc_type.serv_cat) ;
   &cWhere1 ;               
ORDER BY ;
   1,3,5,8 ;
INTO CURSOR ;
   MyEnc1
   
* jss, 11/15/04, change myenc to myenc1 above, add category for legal services below

oApp.ReopenCur("MyEnc1", "MyEnc2")

If Used('MyEnc1')
   use in MyEnc1
EndIf
   

=OpenFile("category", "ProgCode")

Select MyEnc2
Set relation to serv_cat + category into Category
Go Top
Replace All Categdesc With Category.descript For !Empty(MyEnc2.category)

oApp.Msg2User("OFF")


If Used('MyEnc')
   Use in MyEnc
Endif   

Select * From MyEnc2 ;
Order by 1,3,5,9 ;
Into Cursor MyEnc

If Used('MyEnc2')
   Use in MyEnc2
Endif  

Select MyEnc
GO TOP
IF EOF()
   oApp.msg2user('NOTFOUNDG')
Else
           gcRptName = 'rpt_ser_list'
           DO CASE
              CASE lPrev = .f.
                  Report Form rpt_ser_list  To Printer Prompt Noconsole NODIALOG 
              CASE lPrev = .t.     &&Preview
                     oApp.rpt_print(5, .t., 1, 'rpt_ser_list', 1, 2)
           ENDCASE
EndIf

*!*   If Used('category')
*!*      USE IN Category
*!*   endif 

RETURN