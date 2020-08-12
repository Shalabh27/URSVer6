* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6.0, 5.0 and 3.0
* Updated....: Mon  06-22-1998
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
*
* Edited by..: Updated on 03-30-98 by Reg Brehaut who revised the code below
*              to enable this procedure to work with memos embedded in
*              PageFrames.
*
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
*
* Purpose....: Extracts text from the current form's active Textbox, Editbox or Grid
*              control, passes this text into the main Foxspell Checker
*              program FS_SPELL.PRG, and then updates the control with the
*              spell checked text when done.
*
* Called by..: => On key label installed by the FS_SETUP.PRG program.
*
*           or => KeyPress event of a form via this code snippet:
*                    If nKeyCode = 31  && If Alt+S pressed.
*                       DO FS_CALL
*                    ENDIF
*
* Assumption.: If this program is being called by your form's key press event,
*              your form's KeyReview property must be set to true.

LOCAL lcBaseClass, lcText

* Get object reference to active control
loThisControl = _SCREEN.ActiveForm.ActiveControl

* Extract and examine baseclass of active control
lcClass = loThisControl.BaseClass

IF lcClass == "Editbox" .OR. lcClass == "Textbox" .OR. lcClass == "Grid"
   *
   * This is a control we should be able to spell check extract
   * the text and ensure it is something we can spell check.
   *
   lcText = loThisControl.Value
   DO CASE
      CASE EMPTY(lcText)
         = MESSAGEBOX("Cannot spell check an empty field", 48, "Empty Field")
         RETURN
      CASE .NOT. TYPE('lcText') $ "MC"
         = MESSAGEBOX("You can only spell check character and memo fields", 48, "No Text Found")
         RETURN
   ENDCASE
      
   IF lcClass == "Grid"  && If object being edited is a grid.
      lnColumn = loThisControl.ActiveColumn
      lcFld_name = loThisControl.Columns(lnColumn).ControlSource
      IF loThisControl.Columns(lnColumn).ReadOnly
         = MESSAGEBOX("You cannot spell check this field because it is read only!", 16, "Cannot Change Field")
         RETURN
      ENDIF
   ENDIF
        
   * Now call the spell checker.
   IF FS_SPELL("", @lcText, .T.)
      IF lcClass == "Grid"
         DO WHILE .T.
            IF RLOCK()
               REPLACE (lcFld_name) WITH lcText
               UNLOCK
               EXIT
            ELSE
               IF MESSAGEBOX("Cannot save spelling changes because another user has locked your record. " + ;
                  CHR(13)+ "Do you want to try again?",52,"Record in Use") = 7
                  EXIT
               ELSE
                  LOOP
               ENDIF
            ENDIF
         ENDDO
      ELSE
         IF !loThisControl.Value == lcText
            *
            * Update control with corrected text
            * only if it has changed
            *
            loThisControl.Value = lcText
         ENDIF
      ENDIF
   ENDIF
ELSE
   * Don't know what this is, but it is not a control we can spell check.
   = MESSAGEBOX("You can only spell check character and memo fields (UNKNOWN CLASS NAME)", 48, "No Text Found")
   RETURN
ENDIF
RETURN
* End of FS_CALL.PRG--------------------------------------------------------- *
