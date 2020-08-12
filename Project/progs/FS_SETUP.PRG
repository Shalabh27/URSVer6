FUNCTION FS_SETUP
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6.0, 5.0 and 3.0
* Updated....: Wed  10-18-1995
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
*
* Purpose....: This mini program installs a 'Check Spelling' pad on the Edit
*              pull-down of your program's main menu or system menu.  This
*              pad will located right after the Select All (Ctrl+A) pad.
*              This program also installs the hot key combination of Alt+S
*              for calling Foxspell Checker.
*
*              You may need to call this routine more than once in your
*              application as the menu pad it installs occassionally gets
*              disabled when other forms are called.  To be safe, you can
*              call this routine in the Load event snippet of any form that
*              requires spell checking by inserting this line of code:
*
*                          DO FS_SETUP
*
*              This menu pad will only be accessible if the form containing
*              the fields to spell check is non-modal.  If the form is modal,
*              FoxPro will disable (gray out) the 'Check spelling' pad.  The
*              solution is to install the Alt+C letter combination as a hot
*              key for the form by inserting the following code into the
*              form's KeyPress event code snippet:
*
*                          If nKeyCode = 31  && If Alt+S pressed.
*                             DO FS_CALL
*                          ENDIF
*
*               Insert the above code right after the snippet's first line
*               reading:
*
*                          LPARAMETERS nKeyCode, nShiftAltCtrl
*
*                Additionally, for this event to occur, you must also set
*                the form's KeyPreview property to true.
*
* Note #1....: If your application contains a browse in its own separate window
*              and if you want to let your user spell check its fields, then
*              before you issue the browse statement, you must install an
*              on key label command to involve the checker.  For example:
*
*                          ON KEY LABEL ALT+S DO FS_SPELL
*                          BROWSE
*                          ON KEY LABEL ALT+S
*
*              Note that is important to remove the ON KEY LABEL condition as
*              soon as you exit the browse otherwise you will not be able to
*              access the spell checker from within a form.
*
* Note #2....: If you are editing a memo in its own separate window as
*              opposed to an EditBox control in a form, you will need to take
*              additional steps.  Typically, a memo is accessed in its own
*              separate window when you issue a MODIFY MEMO statement within
*              the Click event of a button or when you issue a BROWSE
*              statement and the user presses Ctrl+Home to access the memo.
*
*              In such cases you must assign the name of the memo field to
*              a variable named cMemoFieldName.  For example, if the memo
*              field's name is CUSTOMER.NOTES, in the form's Click event
*              snippet, you would include:
*
*                 cMemoFieldName = "NOTES"
*                 SELECT CUSTOMER
*                 MODIFY MEMO NOTES
*
*              Without this code, Foxspell Checker would not be able to know
*              the name of the memo field to spell check.  This is because
*              FoxPro's VARREAD() function does not return a value when the
*              user is editing a memo in its own window.
*
*              Note that this approach will only work if your application
*              contains a system menu (drop-down menu) and if this menu also
*              contains an Edit pull-down holding these three menu pads:
*
*                    Select All  Ctrl+A
*                    Paste       Ctrl+V
*                    Copy        Ctrl+C
*
*              These pads are used by Foxspell Checker to refresh the memo
*              window's text when done spell checking.  Without these pads,
*              there is no way to update the screen, short of closing and
*              reopening the memo window.
*
* Assumes....: The Foxspell Checker calling program FS_CALL.PRG assumes that
*              your application is using the standard TextBox, EditBox and
*              Grid controls that come with Visual FoxPro.  If you have
*              subclassed these control to create your own customized
*              versions, you will need to edit the source code of FS_CALL
*              and replace the class name of "Textbox", "Editbox" or "Grid"
*              with whatever class names you used.
*
* --------------------------------------------------------------------------- *

PUBLIC nFoxspell_Checker_bar_num

IF TYPE('nFoxspell_Checker_bar_num') <> "N"  && If variable not assigned yet, assign it.
   nFoxspell_Checker_bar_num = CNTBAR("_MEDIT") + 1  && Find location for menu pad.
ENDIF   

* Install the menu pad.
DEFINE BAR nFoxspell_Checker_bar_num OF _MEDIT AFTER _MED_SLCTA PROMPT 'C\<heck Spelling' KEY ALT+S, "ALT+S"

* Link an action to the pad.
ON SELECTION BAR nFoxspell_Checker_bar_num OF _MEDIT DO FS_CALL

RETURN
