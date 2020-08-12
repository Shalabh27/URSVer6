FUNCTION SPELLALL
PARAMETERS cTable2Check
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6.0, 5.0 and 3.0
* File name..: SPELLALL.PRG
* Updated....: Thu 03-19-1998
*
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
*
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
*
* Purpose...: This stand-alone function automatically spell checks every character
*             and memo field of every record in the currently open table.
*
* Assumes...: That either the name of the .DBF table to be spell checked has either been
*             passed in as a parameter or is already open and selected.

SET TALK OFF
CLEAR TYPEAHEAD

PRIVATE cErrorMsg, nFld_num, cFld_name, nField_sum, cValue2chk, lOK2SaveChanges, nRec_sum, cSay_sum, lQuit
cFld_name = ""
nFld_num = 1
lQuit = .F.
cValue2chk = ""
nRec_sum = 0

IF .NOT. EMPTY(cTable2Check)
   cTable2Check = UPPER(ALLTRIM(cTable2Check))
   IF USED(cTable2Check)  && If the table isn't selected, then select it.
      SELECT (cTable2Check)
   ELSE                 && If the table isn't open, then open it.
      SELECT 0
      USE (cTable2Check)
   ENDIF
ELSE
   cTable2Check = UPPER(DBF())
ENDIF

DO CASE
   CASE EMPTY(cTable2Check)
      cErrorMsg = "You must first open and select a .DBF table to spell check"
   CASE ("WORDS1.DBF" $ cTable2Check) .OR. ("WORDS2.DBF" $ cTable2Check) .OR. ("WORDS3.DBF" $ cTable2Check)
      cErrorMsg = "You must pick some other table than WORDS1.DBF, WORDS2.DBF or WORDS3.DBF to check!"
   CASE RECCOUNT() = 0
      cErrorMsg = "The table you selected to check named " + cTable2Check + " is empty!"      
   OTHERWISE
      cErrorMsg = ""   
ENDCASE
IF "" <> cErrorMsg
   = MESSAGEBOX(cErrorMsg, 16, "CANNOT SPELL CHECK")
   RETURN (.F.)
ENDIF

nField_sum = FCOUNT()
cSay_sum = LTRIM(STR(RECCOUNT()))
GOTO TOP

* Each pass through the next loop spell checks one record.
DO WHILE .NOT. EOF()
   * Each pass through the next loop checks one field in the current record.
   FOR nFld_num = 1 to nField_sum
      lOK2SaveChanges = .T.
      
      IF INKEY() = 27  && If the Esc key was pressed.
         IF MESSAGEBOX("Do you want to quit spell checking now?", 4+32, "Quit Now?") = 6  && If Yes.
            lQuit = .T.
            EXIT
         ELSE
            CLEAR TYPEAHEAD
         ENDIF
      ENDIF         
      
      IF TYPE(Field(nFld_num)) $ 'MC'  && If a memo or character field.
         cFld_name = FIELD(nFld_num)   && Extract the field's name.
         cValue2chk = &cFld_name       && Extract the field's value.
         IF .NOT. EMPTY(cValue2chk)      && If the field is not empty.
            IF FS_SPELL("", @cValue2chk, .F., @lOK2SaveChanges)
               * If user saved spelling changes, then update file.
               IF lOK2SaveChanges .AND. RLOCK()
                  REPLACE &cFld_name WITH cValue2chk
                  UNLOCK
               ENDIF
            ELSE
               lQuit = .T.
               EXIT
            ENDIF
         ENDIF
      ENDIF
   NEXT
   
   IF lQuit 
      WAIT WINDOW "Quit spell checking!"
      EXIT
   ENDIF
   
   SKIP
   
   nRec_sum = nRec_sum + 1  
   WAIT WINDOW "Checked record " + LTRIM(STR(nRec_sum)) + " of " + cSay_sum + ;
               "   (Press Esc several times to quit)" NOWAIT
ENDDO
RETURN (.T.)

