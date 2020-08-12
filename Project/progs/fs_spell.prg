* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6.0, 5.0 and 3.0
* File name..: FS_SPELL.PRG
* Updated....: 08-07-98
*
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
*
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
*
* Overview...: Foxspell Checker can spell check memo fields, character fields,
*              ASCII text files or string variables.
*
*              Once called, Foxspell Checker immediately starts spell checking.
*              A word counter is shown in the status bar to inform the user
*              that text is being processed.
*
*              As soon as a word is not found in the dictionary, checking stops
*              and the user is presented with a dialog box.  This dialog shows
*              the word in context and provides the following options:
*
*              [Suggest    ]  Suggest alternate spellings.
*
*              [Add word   ]  Add the word that was not found to the dictionary.
*
*              [Undo add   ]  Remove from the dictionary a word that was
*                             previously added to it.
*
*              [Replace    ]  Type in a replacement word.
*
*              [ignore Word]  Ignore just this occurrence of this word.
*
*              [Ignore all ]  Ignore this word and all future occurrences of it.
*
*              [Cancel     ]  Abandon spell checking without saving any changes
*                             that were made.
*
*              [eXit & save]  Exit spell checking and save all changes.
*
*              There is also a check box for indicating whether or not the user
*              wants to be warned about consecutively repeated words.
*
*              If the user chooses to ignore all, then the user will not be
*              asked again about other occurrences of the suspect word during
*              the current spell check task.  Additionally, if the user
*              replaces a suspect word with a different spelling, then every
*              time the same suspect word is seen, the user is given the option
*              to replace it with the user's prior correction.
*
*
* Called by..: FS_CALL.PRG
*
* Text files.: If you want to spell check an ASCII text file, then all you have
*              to do is call the FS_SPELL() routine with the file name passed
*              in as a parameter.  For example, to spell check a text file
*              named EXAMPLE.TXT, you might issue the statement:
*
*                        found_file = FS_SPELL("EXAMPLE.TXT")
*
*              If Foxspell Checker cannot find the file, cannot open the file
*              or the file is empty, then the user will be given an alert
*              message explaining the problem and the FS_SPELL() function will
*              return a logical false. Otherwise, FS_SPELL() will return a
*              logical true when done spell checking.  The reasons why
*              FS_SPELL() cannot check a text file include:
*
*              1. File name is not valid (file could not be found).
*
*              2. File is empty or contains less than 2 characters.
*
*              3. There are too many files open.
*
*              4. Access to file denied because another user has opened it
*                 exclusively.
*
*              5. Foxpro is out of memory.
*
*              Foxspell Checker is only designed to check text files in which
*              each line ends with a hard carriage return and with no single
*              line being longer than 255 characters.  A hard carriage return
*              is either an ASCII 13 by itself or the combination of an ASCII 13
*              and an ASCII 10.  Any text file created within Foxpro with a
*              COPY TO command or created by MODIFY COMMAND will be of this
*              type.  So will files created by any programming editor.
*
*
* Strings....: You can also spell check a memo or character field that has been
*              copied to a string variable.  To spell check the contents of a
*              string variable, all you have to do is to call the FS_SPELL()
*              function with the string variable passed in by reference as its
*              second parameter.
*
*              For example, to spell check a string variable named user_text
*              you would call Foxspell Checker as follows:
*
*                        = FS_SPELL("", @user_text)
*
*              Note the use of the "@" symbol in front of the variable name.
*              This causes the variable to be passed by reference instead of
*              just a copy of it.  If you leave off this symbol, then the
*              changes made to the string during spell checking will not be
*              saved back to the string.
*
*              Using Foxspell Checker to check strings is useful when you want
*              to check user entered text at some other time than when the
*              user is in a form and is sitting in the field to be checked.
*              Fox example, you might use it in code like this:
*
*                        SELECT CUSTOMER
*                        cUser_text = CUSTOMER.COMMENT  && Copy data from field.
*
*                        IF FS_SPELL("", @cUser_text)
*                           REPLACE COMMENT WITH cUser_text
*                        ENDIF
*
* Thanks to..: Michael Jarvis of Pace/Butler Corporation for providing the
*              algorithms used in FS_FLIP2(), FS_FLIPX(), FS_DROPC() functions.
*              These improved the ability to generate suggestions when the
*              misspelling was due to an extra or transposed character.
*
* --------------------------------------------------------------------------- *


* --------------------------------------------------------------------------- *
* Overview of the functions contained in this program file:
*
*  FS_SPELL()  The highest level module in the Foxspell Checker program.  This
*              function assigns the checker's global variables, sets up the
*              needed FoxPro environment, opens the dictionaries and extracts
*              the text to be checked.  When the user finishes checking, this
*              function then saves the changes and restores the FoxPro
*              environment before exiting.
*
*  FS_CHECK()  Parses the text string to be checked into individual words and
*              then looks up each word against either a memory resident
*              dictionary or .DBF based dictionary.
*
*  FS_SUGST()  Finds alternate spelling suggestions for a suspect word.
*
*  FS_W_INS()  Insert the non-found or replaced word into aWord_list[].
*
*  FS_FLIP2()  If a word is two characters long, then this function transposes
*              these two characters and looks up the word.  If the transposed
*              version of this word is found in the dictionary, then this
*              function adds the word to the suggestion list.  It also appends
*              a character CHR(127) to the suggestion list to tell the
*              suggestion sorting routine to move this word to the top.
*
*  FS_FLIPX()  This function transposes each adjacent two character pair in
*              the suspect word and then looks it up.  If the transposed
*              version of the word is found in the dictionary, then this
*              function adds the word to the suggestion list.
*
*  FS_DROPC()  This next function sequentially removes each character of the
*              the suspect word and then looks it up.  If the truncated
*              version of the word is found in the dictionary, then this
*              function adds the word to the suggestion list.
* --------------------------------------------------------------------------- *



FUNCTION FS_SPELL
PARAMETERS cFile_name, cStr2check, lStop_at_end, lOK2Save
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6,0, 5.0 and 3.0
* Function...: FS_SPELL()
* Updated....: Thu 03-19-1998
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
*
* Purpose....: The highest level module in the Foxspell Checker program.  This
*              function assigns the checker's global variables, sets up the
*              needed FoxPro environment, opens the dictionaries and extracts
*              the text to be checked.  When the user finishes checking, this
*              function then saves the changes and restores the FoxPro
*              environment before exiting.
*
* Calls......: FS_CHECK()  Parses text into words and checks each word.
*              FS_MAIN.SCX The main spell checker dialog box.
*              FS_FLIP2()  Finds a suggestion by transposing a 2 character word.
*              FS_FLIPX()  Finds suggestions by transposing each two character pair.
*              FS_DROPC()  Finds suggestions by dropping each letter in a word.
*              FS_DEL.SCX  Dialogs with user to delete a word from the dictionary.
*
* Parameters.:
*
*  Name        Type        Description
*  ----------  ----------  ----------------------------------------------------
*  cFile_name   Character  is an optional name of an ASCII text file to spell
*                          check.
*
*  cStr2check   Character  is an optional string, that if passed in, will be
*                          spell checked.  This string can range in length from
*                          2 characters to 65536 characters long. In order to
*                          save the changes made to the string during spell
*                          checking, you must pass in the string by reference.
*                          That is, you must append a "@" symbol to its front.
*                          For example:  = FS_SPELL("", @user_text)
*
*  lStop_at_end  Logical   If true, then when spell checking is finished, stop
*                          and show a finished message. If false, immediately
*                          exit.
*
*  lOK2Save      Logical   If true, then the field being checked contains 
*                          data, changes were made and no error occurred.
*                          during spell checking. 
*
*                          If an error is detected, then an error message will
*                          be displayed in a wait window before this function
*                          exits.  The types of errors that can occur include:
*
*                      ->  Text file was not found.
*                      ->  Too many files are open.
*                      ->  Text file is being exclusively used by another.
*                      ->  Disk is full.
*                      ->  Foxpro is out of memory.
*                      ->  Field or file is less than 2 bytes long.
*                      ->  Field is of a logical, numeric or date type.
*
* Returns....: The return value of FS_SPELL() is of a logical type.  If the user
*              terminated spell checking by clicking on the [Cancel] button, then
*              this value will be set to false.  Otherwise, it will bet set to 
*              true.

* Uses.......: The following three dictionary files of WORDS1.DBF, WORDS2.DBF
*              and WORDS3.DBF are used.  The first time this module is run, it
*              will create the following compound structural index for each
*              dictionary file.
*
*  1st dictionary: WORDS1.DBF    Words with a length of 1 to 8 characters.
*  Index name:     WORDS1.CDX    TAG WORD -> INDEX ON WORD TAG TEXT
*                                TAG SOUND-> INDEX ON SOUNDEX(WORD) TAG SOUND
*
*  2nd dictionary: WORDS2.DBF    Words with a length of 9 to 12 characters.
*  Index name:     WORDS2.CDX    TAG WORD -> INDEX ON WORD TAG TEXT
*                                TAG SOUND-> INDEX ON SOUNDEX(WORD) TAG SOUND
*
*  3rd dictionary: WORDS3.DBF    Words with a length of 13 to 20 characters.
*  Index name:     WORDS3.CDX    TAG WORD -> INDEX ON WORD TAG TEXT
*                                TAG SOUND-> INDEX ON SOUNDEX(WORD) TAG SOUND
*
*  The use of these 3 files reduces disk space by almost 50% of what would be
*  consumed if only one 20 character field file were used.  Word length
*  analyses were performed to determine the optimum length cutoffs.
*
* Note 1....: This module is configured to ignore the plural ending suffix of
*             [ 's ] when checking a word's spelling.  If you want  's  to be
*             included, then set the variable called lPlural_OK to false both
*             in this function and in the CHK_WORD() function.
*
* Note 2....: This function issues the multi-user command:
*
*                        SET REPROCESS TO 30 SECONDS
*
*             If your application has its own ON ERROR function for handling
*             failed RLOCK() and FLOCK() attempts, then you should comment out
*             this line and the reprocess restoration line that reads:
*             SET REPROCESS TO (cReprocessN)
*
* --------------------------------------------------------------------------- *

SET TALK OFF
SET MESSAGE TO            && Turn off any previous SET MESSAGE setting.

EXTERNAL PROCEDURE FS_CHECK

* Declare and define local variables----------------------------------------- *
PRIVATE lAll_loaded, lAutoSuggest, cChars2skip, cCharsAtEnd, lCheck_file, lCheck_str,; 
        nCol_end, nCol_max, nCol_offset, nCol_pos, nCol_start, cCr_char,;
        cDeleted_on, cDict_last, cDict_use, lDiff_CAPs, lDoneSaving, lDetect_rept,;
        cEnd_of_par, lExact_on, nExit_save, cErrorLine1, cErrorLine2, nError_num, cEsc_on,;
        cExtra_opts, nFileHandle, lFirst_pass, cFlag_repl
PRIVATE lFound_any, lFound_mis, nFound_num, lFoundPrior, lFoundTwice,;
        lGo2newLine, clast_added, nLen_replace, cLf_char,;
        nLine_end, nLine_load, nLine_NOW, nLine_num, nLine_strt, nLine_SUM,;
        nLine_width, lLoad_next, lMadeChange, nMaxWordLen, nMemoWidthN,;
        lNo_suggest, cNear_on, off_list, nOff_max, nParam_sum, lPlural_end,;
        lPlural_OK, nPrior_wa, lQuit_loop, aRec_list, lRepl_shown
PRIVATE lReplaced, cReprocessN, nRow_hold, nRow_num, cSeparators, nSkip_max,;
        nSkip_sum, nSkip_warn, lShow_del_btn, lSpell_OK, lStatus_bar_on,;
        cString, cSuggest_def, nSuggest_max, lSuggest_pick, nSuggest_row, nSuggest_sum, cSuspect,;
        cTab_char, cTab_charH, cText2check, cText2_repl, nTextLength,;
        textshow, aText_say, nScr_col, cSuspectMsg, cWeight_high,;
        cWeight_low, lWord_is1st, cWord_last, aWord_list, nWord_lRow, cWord_LC,;
        cWord_repl, nWord_size, nWord_sum, cWord_text, nWordMaxLen,;
        cWord2seek, cWord2seekL


lAll_loaded = .F. && If true, then the memo's last line was found and loaded into memory.
lAutoSuggest = .T.&& If true, then when a suspect word is found, suggestions are automatically displayed.
cChars2skip = ""  && Characters between words to treat as word separators.
cCharsAtEnd = ""  && Characters that indicate the end of a sentence.
lCheck_file = .F. && If true, then a ASCII text file is being spell checked.
lCheck_str = .F.  && If true, then a string passed in the 2nd parameter position is being checked.
nCol_end = 0      && 1 column past the ending column of the currently selected word.
nCol_max = 65     && Maximum width of a line to be displayed on the screen.
nCol_offset = 0   && Amount of horizontal scroll in screen columns during display.
nCol_pos = 1      && Current column position in the textshow[] array.
nCol_start = 0    && Starting column of a word.
cCr_char =CHR(13) && Carriage return character used for reconstructing memo lines.
cCursor_on = SET("CURSOR")    && Save SET CURSOR setting.
cDeleted_on = SET("DELETED")  && Save SET DELETED setting.
lDetect_rept =.T.  && If true, then look for consecutive repeated occurrences of words.
cDict_last = "X"  && Name of previously used .DBF dictionary file.
cDict_use = "WORDS1"  && Name of currently needed .DBF dictionary file.
lDiff_CAPs = .F.  && If true, then found word has capitalization difference.
lDoneSaving = .F. && If true, then the entire memo/file was copied to memory.
cEnd_of_par = CHR(13)    && The end of paragraph marker.
cEsc_on = SET("ESCAPE")  && Save SET ESCAPE setting.
lExact_on = SET("EXACT") && Save SET EXACT setting.
nExit_save = 0    && If 1, then user pressed the [eXit & save] button.
cErrorLine1 = ""  && First line of error message text.
cErrorLine2 = ""  && Second line of error message text.
nError_num = 0    && Foxpro file opening error number.
cExtra_opts = ""  && Extra options that the user can select.
nFileHandle = 0   && DOS file handle assigned to the text file.
lFirst_pass =.T.  && If true, then the 1st word has already been found.
cFlag_repl=CHR(127) && Code indicating that user has replaced word's prior instance.
lFound_any = .F.  && If true, then at least one word was found.
lFound_mis = .F.  && If true, then found at least one misspelling.
nFound_num = 0    && The aWord_list[] element containing the previously found word.
lFoundPrior =.F.  && If true, then misspelled word was previously found and edited.
lFoundTwice =.F.  && If true, then word is a repeat of prior word in sentence.
lGo2newLine = .T. && If true, then go to the next line.
cLast_added = ""  && Saved copy of last word added to enable its display in dictionary delete dialog.
nLen_replace = 0  && Length of a replacement word.
cLf_char =CHR(10) && Line feed character used for reconstructing memos that were directly extracted from the record.
nLine_end = 0     && Ending line of found text.
nLine_load = 0    && Number of the last line copied into memory.
nLine_NOW = 0     && Current line within the memo being processed.
nLine_num = 0     && Current row in textshow[].
nLine_strt = 0    && Starting line of found text.
nLine_SUM = 0     && Total number of memo lines.
nLine_width = 0   && Width of the current line.
lLoad_next =.F.   && If true, then load the memo's next line into memory.
lMadeChange = .F. && If true, then user made at least one replacement. Used to enable an exit without saving confirmation dialog.
nMaxWordLen = 20  && Maximum word length.
cMemo_name = ""   && Name of memo field. Assigned if user is sitting outside a memo field on the "Memo" key word.
lMemoWasNamed = .F.  && If true, then the external variable cMemoFieldName was used to indicate the memo field's name.
nMemoWidthN = SET("MEMOWIDTH")  && Save memowidth setting to enable restoration.
lNo_suggest =.F.  && If true, then no suggestions were found for a word.
cNear_on = SET("NEAR")  && Save SET NEAR setting to enable restoration.
nOff_max = 100    && Current size of off_list[] array.  Will be increased if needed during execution of this function.
lOK2Save = .T.    && If true, no errors were found and it is OK to save changes.
DECLARE aOff_list[nOff_max]= 100  && Holds absolute offset of each line's start in the memo being checked.
nParam_sum = PARAMETERS()
lPlural_end =.T.  && If true, then a plural ending of ['s] was found on the word.
lPlural_OK = .T.  && If true, then the ending suffix of [ 's ] is ignored when checking.
nPrior_wa = SELECT() && Save previously selected work area, if any.
lQuit_loop = .F.  && If true, then exit main spell loop & return to prior program.
nSuggest_max = 110 && Maximum number of suggestions to gather before scoring & sorting.
DECLARE aRec_list[nSuggest_max]  && List of suggested words.
aRec_list = ""    && Initialize array of suggested words to all nulls.
lRepl_shown =.F.  && If true, then user has been shown suggested replacements.
lReplaced = .F.   && If true, then a word was previously replaced.
cReprocessN = SET("REPROCESS")  && Save the reprocess setting to enable restoration.
nRow_hold = 0     && Temporary row position holder.
nRow_num = 0      && Temporary row position holder.
nScr_col = 0      && Screen column to display the suspect word.
cSeparators = ""  && Complete list of characters that serve as words cSeparators.
lShow_del_btn = .F. && If true, then [Replace] button was changed to [Delete] because repeated word was found.
nSkip_max = 150   && Maximum number of words allowed in the aWord_list[] array.
nSkip_sum = 0     && Number of words that the user choose to replace or ignore.
nSkip_warn = .F.  && If true, then user warned the that aWord_list[] array is full.
lSpell_OK = .T.   && If true, then user choose to save spell checking changes that were made.
lStatus_bar_on = (SET("STATUS BAR") = "ON")  && Save the status bar setting.
cString = ""      && Temporary string value.
cSuggest_def = "" && Frame title to be shown over the suggestion list.
lSuggest_pick=.F. && If true, then a suggestion was picked from the picklist.
nSuggest_row = 0  && Number of suggestion picked by the user.
nSuggest_sum = 0  && Number of words in the array of suggested words.
cSuspect = ""     && Screen displayable version of the suspect word.
cTab_char =CHR(9) && Tab character. Used to prevent their display when showing word in context.
cTab_charH = CHR(255) && Character used to temporarily take the tab character's place.
cText2check = ""  && Holds the memo or file to be spell checked.
cText2_repl = ""  && Holds the memo or file to be replaced back if changes saved.
nTextLength = 0   && Length of cText2check which is used if lCheck_file is false.
DECLARE aTextshow[7] && Serves as a text display buffer holding up to 7 lines of text to show in window.
aTextshow = ""    && Initialize the text display buffer aTextshow[] elements to ASCII nulls.
DECLARE aText_say[7] && Array that holds formatted text to paint to the screen.
aText_say = ""    && Initialize the 7 say_line[] elements to ASCII nulls.
cWeight_low = CHR(127)  && Indicates if suggestion is to be moderately weighted.
cWeight_high = CHR(154)  && Indicates if suggestion is to be heavily weighted.
lWord_is1st =.T.  && If true, then word is the first in its sentence.
cWord_last = ""   && The previous word that was processed (looked up).
DECLARE aWord_list[nSkip_max]   && List of ignored & replaced words.
aWord_list = ""   && Initialize array of ignored or replaced words to all nulls.
nWord_lrow = 0    && Row in aWord_list[] array of last found word.
cWord_LC = ""     && Assign a lower case version of the word to find.
cWord_repl = SPACE(nMaxWordLen) && User supplied replacement for a unfound word.
nWord_size = 0    && The length of the current word.
nWord_sum = 0     && Holds count of number of words processed.
cWord_text = ""   && Trimmed version of the word currently being checked.
nWordMaxLen = 0   && Maximum word length (depends on which dictionary is selected).
cWord2seek = ""   && Right-hand space-padded word to SEEK.
cWord2seekL = ""  && Right-hand space-padded word to SEEK in lower case form.
* --------------------------------------------------------------------------- *

cChars2skip = '0123456789 ~@#$%^&*-_+=(){}[]<>/\|:;,"' + cTab_char + CHR(12)  && Characters to skip over.
cCharsAtEnd = cEnd_of_par + ".!?" && Characters that define an end of sentence.
cSeparators = cChars2skip + cCharsAtEnd  && Any character that can separate a word.

IF cCursor_on = "OFF"
   SET CURSOR ON
ENDIF

* Created dictionary indexes, if missing------------------------------------- *
IF .NOT. FILE("WORDS1.CDX")  && If the indexes haven't been built yet, then build them.
   SELECT 0
   USE WORDS1 EXCLUSIVE
   SELECT 0
   USE WORDS2 EXCLUSIVE
   SELECT 0
   USE WORDS3 EXCLUSIVE

   SET TALK ON
   CLEAR TYPEAHEAD

   SELECT WORDS1
   WAIT WINDOW "Creating the spell checker's index files: STEP 1 OF 6 ." NOWAIT
   DELETE TAG ALL
   INDEX ON WORD TAG TEXT

   WAIT WINDOW "Creating the spell checker's index files: STEP 2 OF 6 .." NOWAIT
   INDEX ON SOUNDEX(WORD) TAG SOUND
   USE

   SELECT WORDS2
   WAIT WINDOW "Creating the spell checker's index files: STEP 3 OF 6 ..." NOWAIT
   DELETE TAG ALL   
   INDEX ON WORD TAG TEXT

   WAIT WINDOW "Creating the spell checker's index files: STEP 4 OF 6 ...." NOWAIT
   INDEX ON SOUNDEX(WORD) TAG SOUND
   USE

   SELECT WORDS3
   WAIT WINDOW "Creating the spell checker's index files: STEP 5 OF 6 ....." NOWAIT
   DELETE TAG ALL   
   INDEX ON WORD TAG TEXT

   INDEX ON SOUNDEX(WORD) TAG SOUND
   WAIT WINDOW "Creating the spell checker's index files: STEP 6 OF 6 ......" NOWAIT
   USE

   WAIT WINDOW "Finished creating the index files" NOWAIT

   SET TALK OFF
   CLEAR TYPEAHEAD
ENDIF
* --------------------------------------------------------------------------- *

* Open/select the dictionaries----------------------------------------------- *
IF USED("WORDS1")  && If spelling dictionary #1 isn't open, then open it.
   SELECT WORDS1
ELSE
   SELECT 0
   USE WORDS1
ENDIF
SET ORDER TO TAG TEXT

IF USED("WORDS2")  && If spelling dictionary #2 isn't open, then open it.
   SELECT WORDS2
ELSE
   SELECT 0
   USE WORDS2
ENDIF
SET ORDER TO TAG TEXT

IF USED("WORDS3")  && If spelling dictionary #3 isn't open, then open it.
   SELECT WORDS3
ELSE
   SELECT 0
   USE WORDS3
ENDIF
SET ORDER TO TAG TEXT
* --------------------------------------------------------------------------- *

* If checking a file, then open it------------------------------------------- *
IF nParam_sum = 0  && If no file name parameter was passed in.
   cFile_name = ""
ENDIF
IF nParam_sum <= 2  && If the 3rd parameter wasn't passed in.
   lStop_at_end = .T. && If true, when checking is done, show message. If false, exit.
ENDIF

lCheck_file = .NOT. EMPTY(cFile_name)

IF lCheck_file  && If file named supplied, then spell check the file.
   cCharsAtEnd = cCharsAtEnd + cLf_char  && Add line feed to end of line character set.
   cSeparators = cSeparators + cLf_char  && Add line feed to word separator character set.

   nFileHandle = FOPEN(cFile_name, 2)   && Try to open the file to spell check.

   * If file couldn't be opened, then display error dialog.
   IF nFileHandle = -1
      lOK2Save = .F.
      nError_num = FERROR()
      cErrorLine1 = "Cannot open the file named "+ALLTRIM(cFile_name)+" because"
      DO CASE
         CASE nError_num = 2
            cErrorLine2 = " it was not found!"
         CASE nError_num = 4
            cErrorLine2 = " there are too many files open."
         CASE nError_num = 5
            cErrorLine2 = " access to this file was denied."
         CASE nError_num = 8
            cErrorLine2 = " FoxPro is out of memory."
         CASE nError_num = 29
            cErrorLine2 = " your disk is full."
         OTHERWISE
            cErrorLine2 = " of an undiagnosed error."
      ENDCASE
      = MESSAGEBOX(cErrorLine1 + cErrorLine2, 16, "CANNOT OPEN FILE")
      IF nPrior_wa > 0
         SELECT (nPrior_wa)
      ENDIF
      RETURN (.F.)
   ENDIF

   * Verify that file isn't empty or blank and load into memory.
   nTextLength = FSEEK(nFileHandle, 0, 2)       && Go to the file's end.
   IF nTextLength < 2  && If file is too small.
      lOK2Save = .F.
      = FCLOSE(nFileHandle)                    && Close the file.
      CLEAR TYPEAHEAD
      = MESSAGEBOX("The file named " +ALLTRIM(cFile_name)+ " only contains one character!",48,"")
      IF nPrior_wa > 0
         SELECT (nPrior_wa)
      ENDIF
      RETURN (.T.)
   ENDIF
   = FSEEK(nFileHandle, 0, 0)                  && Go to the file's beginning.

ELSE

   SET MEMOWIDTH TO nCol_max
   _MLINE = 0  && Assign FoxPro system variable that holds memo offset.

   IF nParam_sum > 1 .AND. .NOT. EMPTY(cStr2check)
      * If a non-empty string variable was passed in on the second parameter
      * position, then spell check it.
      lCheck_str = .T.
      cText2check = RTRIM(cStr2check)
      nTextLength = LEN(cText2check)
   ELSE
      lCheck_str = .F.
      cText2check = ""
      nTextLength = 0
   ENDIF
   cErrorLine1 = ""

   * Verify that the text to be checked is ok.
   DO CASE
      CASE nTextLength = 0 .AND. .NOT. lCheck_str
         * If user is on a memo field, but hasn't entered it yet.
         * If memo field that user is on but hasn't entered contains text,
         * then extract the text to spell check it.
         IF nPrior_wa > 0
            SELECT (nPrior_wa)

            cMemo_name = VARREAD()  && Extract name of memo field.
            IF EMPTY(cMemo_name) .AND. TYPE("cMemoFieldName") = "C" 
               IF .NOT. EMPTY(cMemoFieldName)
                  * If the variable cMemoFieldName is already declared as a
                  * character data type and if it is not empty, then assume it
                  * holds the name of the memo field to check.
                  cMemo_name = cMemoFieldName
                  lMemoWasNamed = .T.              
               Else
                  
                  WAIT WINDOW "The variable cMemoFieldName is defined, but does not contain a field name!"
               ENDIF
            ENDIF

            IF .NOT. EMPTY(cMemo_name)
               IF TYPE('&cMemo_name') $ "CM"  && If user is on a memo/character field.
                  cText2check = RTRIM(&cMemo_name)
                  nTextLength = LEN(cText2check)
                  DO CASE
                     CASE nTextLength = 0
                        cErrorLine1 = "Field is empty!"
                     CASE nTextLength = 1
                        cErrorLine1 = "Field must contain more than one character"
                  ENDCASE
               ELSE
                  cErrorLine1 = "Can only check memo and character fields"
               ENDIF
            ELSE
               cErrorLine1 = "Cannot locate any text to check"
            ENDIF
         ELSE
            cErrorLine1 = "Cannot find any text to check"
         ENDIF
      CASE nTextLength = 0
         cErrorLine1 = "You cannot check this field because it is empty."
      CASE nTextLength = 1
         cErrorLine1 = "Field must contain more than one character!"
   ENDCASE

   IF .NOT. EMPTY(cErrorLine1)
      lOK2Save = .F.
      = MESSAGEBOX(cErrorLine1, 48, "Cannot Spell Check")
      IF nPrior_wa > 0
         SELECT (nPrior_wa)
      ENDIF
      RETURN (.T.)
   ENDIF
   SELECT WORDS1
   cDict_last = "WORDS1"  
ENDIF
* --------------------------------------------------------------------------- *

* Fill up aTextshow[] array--------------------------------------------------- *
nLine_load = 0
DO WHILE nLine_load < 7
   nLine_load = nLine_load + 1
   IF lCheck_file
      aTextshow[nLine_load] = FGETS(nFileHandle)
      DO CASE
         CASE FEOF(nFileHandle) && If end of file reached.
            lAll_loaded = .T.      && Tells rest of this function that all text has been uploaded to the text display buffer.
            nLine_SUM = nLine_load  && Assign number of lines in the file.
            EXIT
         CASE LEN(aTextshow[nLine_load]) > 255
            oApp.msg2user("INFORM","Text file can't be check since it has lines longer than 255 characters!")
            
*           WAIT WINDOW "Text file can't be check since it has lines longer than 255 characters!"
            = FCLOSE(nFileHandle)  && Close the file.
            IF nPrior_wa > 0
               SELECT (nPrior_wa)
            ENDIF
            RETURN (.F.)
      ENDCASE
   ELSE
      aTextshow[nLine_load] = MLINE(cText2check, 1, _MLINE)
      ************BEGIN <NEW CODE FOR VERSION 3.0H************
      * Replace any and all ASCII null characters with blank spaces.
      * If they are not replaced, there presence will crash this checker.
      nCol_pos = AT(CHR(0), aTextshow[nLine_load])  && Search current line for a null.
      DO WHILE nCol_pos > 0  && For as long as nulls exist, replace them with spaces.
         aTextshow[nLine_load] = STUFF(aTextshow[nLine_load], nCol_pos, 1, CHR(32))
         nCol_pos = AT(CHR(0), aTextshow[nLine_load])  && Search for next null, if any.
      ENDDO
      ************END   <NEW CODE FOR VERSION 3.0H************
      aOff_list[nLine_load] = _MLINE  && Save memo offset to enable memo updating if changes saved.
      IF "" = aTextshow[nLine_load] .AND. _MLINE >= nTextLength && If end of file reached.
         lAll_loaded = .T.
         nLine_SUM = nLine_load - 1  && Assign number of lines in the memo.
         EXIT
      ENDIF
   ENDIF
ENDDO
* --------------------------------------------------------------------------- *

* Setup the required FoxPro environment-------------------------------------- *
SET EXACT OFF                && Needed for suggestion system to work.
SET NEAR OFF                 && Needed for word lookup to work.
SET DELETED ON               && Needed for word lookup to work.
SET REPROCESS TO 30 SECONDS  && Attempt to lock records for 30 seconds.
PUSH KEY CLEAR               && Save all ON KEY LABEL commands.
SET ESCAPE OFF
SET STATUS BAR ON
SET READBORDER ON
* --------------------------------------------------------------------------- *

* Open window to display status messages------------------------------------- *
SET MESSAGE TO "Spell Checking . . ." LEFT
* --------------------------------------------------------------------------- *

* Begin spell checking------------------------------------------------------- *
IF .NOT. FS_CHECK()
   DO FORM FS_MAIN.SCX  && Call the main spell checker function.
ENDIF
* --------------------------------------------------------------------------- *

* Save changes--------------------------------------------------------------- *
IF lCheck_file  && If a text file is being spell checked.
   IF lSpell_OK .AND. lMadeChange && If user wants to save changes & changes were made.
      * If the user exited before the last character of the last line
      * was scanned and copied to cText2_repl, then append the rest of
      * it to the cText2_repl string to be written back.
         
      * Write out remaining text display buffer, if any.
      FOR nRow_num = nLine_NOW TO nLine_load
         cText2_repl = cText2_repl + aTextshow[nLine_num] + cCr_char + cLf_char
         nLine_num = nLine_num + 1
      NEXT

      IF .NOT. FEOF(nFileHandle)  && Store remaining file text, if any.
         cText2_repl = cText2_repl + FREAD(nFileHandle, nTextLength)
      ENDIF

      nCol_pos = LEN(cText2_repl)

      IF nCol_pos < nTextLength   && If file has been shortened.
         IF FCHSIZE(nFileHandle, nCol_pos) = -1 && Then shorten the file.
            * If unable to shorten the file, then fill deleted space with blanks.
            cText2_repl = PADR(cText2_repl, nTextLength)
         ENDIF
      ENDIF
      = FSEEK(nFileHandle, 0, 0)         && Go to the file's beginning.
      = FWRITE(nFileHandle, cText2_repl)  && Write the changed text back to disk.
   ENDIF

   = FCLOSE(nFileHandle)                 && Close the file.

ELSE           && If a character field or a memo text is being spell checked.

   IF lSpell_OK .AND. lMadeChange && If user wants to save changes & changes were made.
      IF .NOT. lDoneSaving
         * If the user exited before the last character of the last line
         * was scanned and copied to cText2_repl, then append the rest of
         * it to the string to be written back.

         * Write out remaining text display buffer, if any.
         *
         * Note that that if the [eXit and save] button is pressed, then an
         * adjustment is made to how much text is extracted.
         IF nLine_NOW >= nLine_SUM .AND. lAll_loaded
            nExit_save = 1
         ELSE
            nExit_save = 0
         ENDIF
         cText2_repl = cText2_repl + aTextshow[nLine_num] + SUBSTR(cText2check, aOff_list[nLine_NOW] + nExit_save)
      ENDIF

      DO CASE
         CASE lCheck_str && If a string passed as the 2nd parameter is being checked.
            cStr2check = cText2_repl

         CASE .NOT. EMPTY(cMemo_name) .AND. .NOT. lMemoWasNamed    
            * If user was sitting outside a memo field in a READ or BROWSE.
            SELECT (nPrior_wa)              && Select file that memo field came from.
            IF RLOCK()
               REPLACE &cMemo_name WITH cText2_repl
               UNLOCK
               GO RECNO()                  && Flush record buffer.
            ENDIF

          OTHERWISE         && If user sitting inside a memo/character field.
            _CLIPTEXT = cText2_repl
            KEYBOARD "{CTRL+A}{CTRL+V}"    && Paste clipboard text back into field.
      ENDCASE
   ELSE
      IF "" = cMemo_name .AND. .NOT. lCheck_str && If user was sitting outside a memo field in a READ or BROWSE.
         KEYBOARD "{RIGHTARROW}{LEFTARROW}"         && Unselect all text.
      ENDIF
   ENDIF
ENDIF
* --------------------------------------------------------------------------- *

* Restore prior environment-------------------------------------------------- *
SET MESSAGE TO                 && Erase prior status line message.

SET REPROCESS TO (cReprocessN)  && Restore prior reprocess setting.
IF nPrior_wa > 0                && Select prior work area, if any.
   SELECT (nPrior_wa)
ENDIF
IF .NOT. lCheck_file            && Restore prior MEMOWIDTH setting.
   SET MEMOWIDTH TO (nMemoWidthN)
ENDIF
IF .NOT. lStatus_bar_on            && Restore the status bar setting.
   SET STATUS BAR OFF
ENDIF
IF cCursor_on = "OFF"           && Restore prior cursor setting.
   SET CURSOR OFF
ENDIF
IF cDeleted_on = "OFF"          && Restore prior deleted setting.
   SET DELETED OFF
ENDIF
IF lExact_on = "ON"             && Restore prior exact setting.
   SET EXACT ON
ENDIF
IF cEsc_on = "ON"               && Restore prior escape setting.
   SET ESCAPE ON
ENDIF
IF cNear_on = "ON"              && Restore prior exact setting.
   SET NEAR ON
ENDIF
POP KEY                        && Restore all prior ON KEY LABEL commands.
* --------------------------------------------------------------------------- *

IF .NOT. lMadeChange  
   * If no changes were made, then set flag to prevent save changes if this 
   * function is being called within a loop to check multple fields.
   lOK2Save = .F.
ENDIF

RETURN (lSpell_OK) && Return true if user commanded to save changes.
* End of FS_SPELL()---------------------------------------------------------- *



FUNCTION FS_CHECK
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6,0, 5.0 and 3.0
* Function...: FS_CHECK()
* Updated....: Thu 03-19-1998
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
*
* Purpose....: Parses the text string to be checked into individual words and
*              then looks up each word against either a memory resident
*              dictionary or .DBF based dictionary.
*
*              This function contains a processing loop that makes one pass
*              through for each word spell checked.  The pass begins by first
*              extracting the next word to be checked.  This word is then
*              checked in memory against a common word list.  If it was
*              not found, then it is checked against the dictionary files.
*
*              If the word is found, then program control jumps back to the
*              top of this loop to extract the next word and repeat this
*              checking process.  If the word was not found, however, then
*              a RETURN is issued and control returns to the calling function.
*
*              The calling function displays a dialog that shows the word in
*              context and provides a set of buttons for such actions as
*              ignoring, replacing or getting suggestions.  Once this dialog
*              is displayed, it will remain on the screen until all words
*              have been checked or until the user cancels.  If all words to
*              be checked are found in the common word list or dictionary,
*              then this dialog is never shown.
*
* Called by..: FS_SPELL() Highest level spell checker function.
*              FS_VALID() READ level VALID clause for FS_MAIN.SCX dialog.
* Calls......: (none)
*
* Variables assumed to have been already defined:
*
*  Name         Type        Description
*  ----------   ----------  --------------------------------------------------------------------
*  lAll_loaded  Logical     If true, then the memo's last line was found and loaded into memory.
*
*  cChars2skip  Character   Characters between words to treat as word separators.
*
*  cCharsAtEnd  Character   Characters that indicate the end of a sentence.
*
*  lCheck_file  Logical     If true, then a ASCII text file is being spell checked.
*
*  nCol_end     Integer     1 column past the ending column of the currently selected word.
*
*  nCol_max     Integer     Maximum width of a line to be displayed on the screen.
*
*  nCol_offset  Integer     Amount of horizontal scroll in screen columns during display.
*
*  nCol_pos     Integer     Current column position in the aTextshow[] array.
*
*  nCol_start   Integer     Starting column of a word.
*
*  lDetect_rept  Logical    If true, then look for consecutive repeated occurrences of words.
*
*  cDict_last   Character   Name of previously used .DBF dictionary file.
*
*  cDict_use    Character   Name of currently needed .DBF dictionary file.
*
*  lDiff_CAPs   Logical     If true, then found word has capitalization difference.
*
*  lDoneSaving  Logical     If true, then the entire memo/file was copied to memory.
*
*  nFileHandle  Integer     DOS file handle assigned to the text file.
*
*  lFirst_pass  Logical     If true, then the 1st word has already been found.
*
*  cFlag_repl   Character   Code indicating that user has replaced word's prior instance.
*
*  lFound_any   Logical     If true, then at least one word was found.
*
*  lFoundPrior  Logical     If true, then misspelled word was previously found and edited.
*
*  lFoundTwice  Logical     If true, then word is a repeat of prior word in sentence.
*
*  lFound_mis   Logical     If true, then found at least one misspelling.
*
*  nFound_num   Integer     The aWord_list[] element containing the previously found word.
*
*  lgo2newLine  Logical     If true, then go to the next line.
*
*  nLine_NOW    Integer     Current line within the memo being processed.
*
*  nLine_end    Integer     Ending line of found text.
*
*  nLine_load   Integer     Number of the last line copied into memory.
*
*  nLine_num    Integer     Current row in aTextshow[].
*
*  nLine_strt   Integer     Starting line of found text.
*
*  nLine_sum    Integer     Total number of memo lines.
*
*  nLine_width  Integer     Width of the current line.
*
*  lLoad_next   Logical     If true, then load the memo's next line into memory.
*
*  nMaxWordLen  Integer     Maximum word length.
*
*  cMemo_name   Character   Name of memo field. Assigned if user is sitting outside a memo field on the "Memo" key word.
*
*  lNo_suggest  Logical     If true, then no suggestions were found for a word.
*
*  aOff_list    Int Array   Holds absolute offset of each line's start in the memo being checked.
*
*  nOff_max     Integer     Current size of aOff_list[] array.  Will be increased if needed during execution of this function.
*
*  lPlural_end  Logical     If true, then a plural ending of ['s] was found on the word.
*
*  lRepl_shown  Integer     Set to true when user shown suggested replacements.
*
*  nScr_col     Integer     Screen column to display the suspect word.
*
*  cSeparators  Character   Complete list of characters that serve as words separators.
*
*  nSkip_sum    Integer     Maximum number of words allowed in the aWord_list[] array.
*
*  lShow_del_btn Logical    If true, then [Replace] button was changed to [Delete] because repeated word was found.
*
*  nSuggest_row  Integer    Number of the suggestion picked by the user.
*
*  cSuspect     Character   Screen displayable version of the suspect word.
*
*  cTab_char    Character   Tab character. Used to prevent their display when showing word in context.
*
*  cTab_charH   Character   Character used to temporarily take the tab character's place.
*
*  aText_say    Char Array  Array that holds formatted text to paint to the screen.
*
*  cText2_repl  Character   Holds the memo or file to be replaced back if changes saved.
*
*  cText2check  Character   Holds the memo or file to be spell checked.
*
*  nTextLength  Integer     Length of cText2check which is used if lCheck_file is false.
*
*  aTextshow    Char array  Serves as a text display buffer holding up to 7 lines of text to show in window.
*
*  cWord2seek   Character   Right-hand space-padded word to SEEK.
*
*  cWord2seekL  Character   Right-hand space-padded word to SEEK in lower case form.
*
*  nWordMaxLen  Integer     Maximum word length (depends on which dictionary is selected).
*
*  lWord_is1st  Logical     If true, then word is the first in its sentence.
*
*  nWord_lrow   Character   Previous word that was processed (looked up).
*
*  cWord_last   Character   Previous word that was processed (looked up).
*
*  cWord_LC     Character   Lower case version of the word to find.
*
*  aWord_list   Char Array  Array of ignored or replaced words to all nulls.
*
*  cWord_repl   Character   User supplied replacement for a unfound word.
*
*  nWord_size   Integer     The length of the current word.
*
*  nWord_sum    Integer     Holds count of number of words processed.
*
*  cWord_text   Character   Trimmed version of the word currently being checked.
*
* NOTE: The above variables were not passed into this function as arguments
*       due to the Foxpro limit of 24 parameters.
* --------------------------------------------------------------------------- *

EXTERNAL ARRAY aOff_list, aText_say, aTextshow, aWord_list

PRIVATE nBar_num, nCol_num, cCr_char, cEol_char, lFound_it, cLf_char, lPlural_OK,;
        lQuit_loop, nRow_first, nRow_num, cString, cWord2find

nBar_num = 0      && Counter for a rotating bar to visually show processing during spell checking.
nCol_num = 0      && Starting column of a word in its sentence.
cCr_char =CHR(13) && Carriage return character used for reconstructing memo lines.
cEol_char = ""    && End of line character (either a ASCII 13 or 32).
lFound_it = .F.   && If true, then the word was found in the dictionary.
cLf_char =CHR(10) && Line feed character used for reconstructing memos that were directly extracted from the record.
lPlural_OK = .T.  && If true, then the ending suffix of [ 's ] is ignored when checking.
lQuit_loop = .F.  && If true, then exit main spell loop & return to prior program.
nRow_first = 1    && First aTextshow[] row that text can appear on.
nRow_num = 0      && Temporary row position holder.
lSuggest_pick=.F. && If true, then a suggestion was picked from the picklist.
cString = ""      && Temporary string holding variable.
cWord2find = ""   && Bounded version of the word to enable within memory lookup.

SELECT WORDS1
STORE "WORDS1" TO cDict_use, cDict_last

DO WHILE .T.
   * Display and spin the spinning wheel to show the user that progress is being made.
   nBar_num = IIF(nBar_num = 4, 1, nBar_num + 1)

   IF nWord_sum % 10 = 0
      IF nWord_sum > 1
         SET MESSAGE TO "Spell Checking  (word " + LTRIM(STR(nWord_sum, 8)) + ")" LEFT
      ENDIF
   ENDIF

   lDiff_CAPs = .F.  && If true, then found word has capitalization difference.
   IF lFound_it      && If a word has been found in the dictionary.
      lFound_any = .T.
   ENDIF
   lFound_it = .F.   && If true, then the word was found.
   lFoundPrior = .F. && If true, then misspelled word was previously found & edited.
   lFoundTwice = .F. && If true, then word is a repeat of prior word in sentence.
   lPlural_end = .F. && If true, then the current word has a plural ending.
   nWord_lrow = 0    && Row in aWord_list[] array of last found word.

   IF lFirst_pass  && If this is the 1st time that this loop has been passed thru.
      lFirst_pass = .F.
      lWord_is1st = .T.  && Flag the 1st word found as the 1st in its sentence.
   ELSE
      lWord_is1st = .F.
   ENDIF

   * Extract the next word to be spell checked------------------------------- *
   DO WHILE .T.
      * Go to the next line-------------------------------------------------- *
      IF lgo2newLine
         lgo2newLine = .F.
         nCol_pos = 1

         IF nLine_num > 0 .AND. nLine_NOW > 0
            IF lCheck_file   && If spell checking a file.
               cEol_char = cCr_char + cLf_char
            ELSE            && If spell checking a memo/character field.
               * Extract saved end-of-line character (either an ASCII 13 or 32)
               cEol_char = SUBSTR(cText2check, aOff_list[nLine_NOW], 1)

               * If end-of-line character is not a carriage return or blank, then don't save.
               cEol_char = IIF(cEol_char $ cCr_char + " ", cEol_char, "")

               IF ("" <> cMemo_name .OR. lCheck_str) .AND. cEol_char = cCr_char
                  * If user is checking a string variable or is outside a memo
                  * field in a READ or BROWSE, then append a line feed character.
                  cEol_char = cCr_char + cLf_char
               ENDIF
            ENDIF

            * Accumulate the previously checked line to a cEol_char to be
            * written back to the memo.
            cText2_repl = cText2_repl + aTextshow[nLine_num] + cEol_char
         ENDIF

         * Find next line within aTextshow[] to tokenize---------------------- *
         IF (nLine_num < 4 .AND. .NOT. lAll_loaded) .OR. (nLine_NOW < nLine_SUM .AND. lAll_loaded)
            * Keep incrementing until either the current line is in the middle of the
            * 7 line window or the memo's last line is visible in the window.
            nLine_num = nLine_num + 1
         ELSE
            lLoad_next = .T.  && Causes the memo's next line to be loaded into memory.
         ENDIF
         nLine_NOW = nLine_NOW + 1
         * ------------------------------------------------------------------ *

         * Insert a new line into aTextshow[]--------------------------------- *
         IF lLoad_next .AND. .NOT. lAll_loaded  && If the last line has not been found yet.
            lLoad_next = .F.
            nLine_load = nLine_load + 1
            IF lCheck_file
               cString = FGETS(nFileHandle)
               IF FEOF(nFileHandle)  && If past end of file.
                  nLine_SUM = nLine_load
                  lAll_loaded = .T.
               ENDIF
            ELSE
               IF nLine_load > nOff_max
                  * If aOff_list[] array size exceeded, then redimension array.
                  nOff_max = nOff_max + 100
                  DECLARE aOff_list[nOff_max]
               ENDIF

               cString = MLINE(cText2check, 1, _MLINE)
               aOff_list[nLine_load] = _MLINE  && Save memo offset to enable memo updating if changes saved.

               IF "" = cString .AND. _MLINE >= nTextLength
                  nLine_SUM = nLine_load - 1
                  nLine_num = MIN(nLine_num + 1, 7)
                  lAll_loaded = .T.
                  lDoneSaving = .T.
               ENDIF
            ENDIF
            IF (.NOT. lAll_loaded) .OR. lCheck_file  && One past memo's last line.
               = ADEL(aTextshow, 1)
               aTextshow[7] = cString
            ENDIF
         ELSE
            IF lAll_loaded .AND. nLine_now > nLine_sum
               lDoneSaving = .T.
               lQuit_loop = .T.
               EXIT
            ENDIF
         ENDIF
         * ------------------------------------------------------------------ *

         nLine_width = LEN(aTextshow[nLine_num])

         IF nLine_width <= 1
            IF lAll_loaded .AND. nLine_num = MIN(nLine_SUM, 7)  && End memo's end.
               lDoneSaving = .T.
               lQuit_loop = .T.
               EXIT
            ELSE
               lWord_is1st = .T.  && Next word will be first in its sentence.
               lgo2newLine = .T.
               LOOP
            ENDIF
         ENDIF
      ENDIF
      * --------------------------------------------------------------------- *

      * Go to the next word in the current line------------------------------ *
      * Look for the start of the next word.
      DO WHILE .T.
         DO WHILE SUBSTR(aTextshow[nLine_num], nCol_pos, 1) $ cChars2skip .AND. nCol_pos < nLine_width
            nCol_pos = nCol_pos + 1
         ENDDO
         IF SUBSTR(aTextshow[nLine_num], nCol_pos, 1) $ cCharsAtEnd .AND. nCol_pos < nLine_width
            nCol_pos = nCol_pos + 1
            lWord_is1st = .T.
            LOOP
         ENDIF
         EXIT
      ENDDO

      * If at end of line, then go to the next line.
      IF nCol_pos >= nLine_width
         IF lAll_loaded .AND. nLine_num = MIN(nLine_SUM, 7)  && End memo's end.
            lQuit_loop = .T.
            lDoneSaving = .T.
            IF .NOT. lCheck_file && If spell checking a memo/character field.
               cEol_char = SUBSTR(cText2check, aOff_list[nLine_NOW], 1)
               cEol_char = IIF(cEol_char $ cCr_char + " ", cEol_char, "")
               IF ("" <> cMemo_name .OR. lCheck_str) .AND. cEol_char = cCr_char
                  cEol_char = cCr_char + cLf_char
               ENDIF
               cText2_repl = cText2_repl + aTextshow[nLine_num] + cEol_char
            ENDIF
            EXIT
         ELSE
            lgo2newLine = .T.
            LOOP
         ENDIF
      ENDIF

      * Look for the end of the current word.
      nCol_start = nCol_pos
      DO WHILE .NOT. SUBSTR(aTextshow[nLine_num], nCol_pos, 1) $ cSeparators .AND. nCol_pos < nLine_width
         nCol_pos = nCol_pos + 1
      ENDDO
      nCol_end = nCol_pos

      nWord_size = (nCol_end - nCol_start) + IIF(nCol_end = nLine_width .AND. .NOT. SUBSTR(aTextshow[nLine_num], nCol_end, 1) $ cSeparators, 1, 0)

      IF nWord_size < 2 .OR. nWord_size > nMaxWordLen
         cWord_last = ""
         IF nCol_end = nLine_width
            lgo2newLine = .T.
         ENDIF
         IF SUBSTR(aTextshow[nLine_num], nCol_pos, 1) $ cCharsAtEnd
            lWord_is1st = .T.
         ENDIF
         LOOP
      ENDIF
      * --------------------------------------------------------------------- *

      cWord_text = SUBSTR(aTextshow[nLine_num], nCol_start, nWord_size)
      cWord_LC = LOWER(cWord_text)
      EXIT
   ENDDO

   nWord_sum = nWord_sum + 1

   IF lQuit_loop  && If no more words were found.
      SET MESSAGE TO "Finished spell checking" LEFT && Erase the status line message
      IF lStop_at_end  && If end message should be shown.
         DO CASE
            CASE .NOT. lSpell_OK
               cString = "Quit spell checking!"
            CASE lFound_any .AND. .NOT. lFound_mis
               cString = "No suspect words were found."
            CASE .NOT. lFound_mis
               cString = "No words were found that could be checked."
            OTHERWISE
               cString = "No more suspect words have been found."
         ENDCASE
         SET MESSAGE TO cString
         IF lMadeChange .AND. lSpell_OK
            cString = cString + CHR(13) + CHR(13) + "Do you want to save the spelling changes you made?"
            IF MESSAGEBOX(cString, 4+32, "Save Changes?") <> 6  && If No pressed.
               lOK2Save = .F.
               lSpell_OK = .F.
            ENDIF
         Else
            oApp.Msg2user('INFORM',cString)
*           WAIT WINDOW cString
         ENDIF
      ENDIF
      EXIT
   ENDIF
   * ------------------------------------------------------------------------ *

   * ------------------------------------------------------------------------ *
   IF lPlural_OK  && If the trailing ['s] should be ignored then eliminate it.
      IF nWord_size > 3
         IF RIGHT(cWord_LC, 2) = "'s"
            nWord_size = nWord_size - 2
            cWord_text = LEFT(cWord_text, nWord_size)
            cWord_LC =   LEFT(cWord_LC, nWord_size)
            lPlural_end = .T.
         ENDIF
      ENDIF
   ENDIF
   * ------------------------------------------------------------------------ *

   cWord2find = "." + IIF(lWord_is1st, cWord_LC, cWord_text) + "."

   * ------------------------------------------------------------------------ *
   IF lDetect_rept  && If user asked to detect repeated words.
      IF .NOT. lWord_is1st  && If word is not first in its sentence.
         IF cWord_last = cWord2find  && If word matches the prior word.
            IF cWord2find <> ".that." .AND. nWord_size <= nMaxWordLen
                lFoundTwice = .T.
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   * ------------------------------------------------------------------------ *

   * ------------------------------------------------------------------------ *
   * Do a quick lookup on common parts of speech to reduce the amount of
   * database activity for common words.
   DO CASE
      CASE lFoundTwice
         * Word is a repeat of the prior word in the same sentence.
      CASE nWord_size = 2
         lFound_it = cWord2find $ ".ad.an.as.at.be.by.do.ex.go.he.if.in.is.it.me.my.no.of.on.or.so.to.up.us.we."
      CASE nWord_size = 3
         lFound_it = cWord2find $ ".ago.all.and.any.are.ask.bad.but.can.did.etc.for.get.got.had.has.her.him.his.how.its.let.lot.may"+;
         ".non.nor.not.one.our.put.say.see.she.the.too.top.try.two.use.via.was.way.who.why.win.yes.yet.you."
      CASE nWord_size = 4
         lFound_it = cWord2find $ ".able.also.away.been.best.both.come.does.each.else.ever.from.gets.good.have.here.hers.into.i've.just"+;
         ".lets.lots.make.many.most.must.need.none.once.ones.only.past.said.same.says.seem.self.some.such.sure."
         IF .NOT. lFound_it
            lFound_it = cWord2find $ ".take.than.that.them.then.they.this.took.upon.vary.very.want.went.were.what.when.will.with.your."
         ENDIF
      CASE nWord_size = 5
         lFound_it = cWord2find $ ".about.again.among.asked.based.bases.basis.being.can't.comes.could.doing.don't.every.going"+;
         ".hence.isn't.later.makes.maybe.might.never.other.quite.seems.shall.since.taken.their.there."
         IF .NOT. lFound_it
            lFound_it = cWord2find $ ".these.thing.those.three.types.using.until.wants.where.which.while.whose.won't.would.yours."
         ENDIF
      CASE nWord_size = 6
         lFound_it = cWord2find $ ".always.anyhow.anyone.anyway.aren't.asking.aspect.awhile.become.better.called.cannot.device.didn't.during"+;
         ".either.enable.happen.indeed.having.itself.making.myself.nearly.others.person.placed.rather.really.seemed.should.surely."
         IF .NOT. lFound_it
             lFound_it = cWord2find $ ".theirs.things.though.versus.wasn't.within.you're.you've."
         ENDIF
      CASE nWord_size = 7              
         lFound_it = cWord2find $ ".against.another.anymore.because.besides.devices.doesn't.enabled.enables.existed.getting.happens.herself.himself."
         IF .NOT. lFound_it         
            lFound_it = cWord2find $ ".however.instead.neither.nominal.overall.perhaps.several.somehow.someone.whether.whoever.without."
         ENDIF                     
      CASE nWord_size = 8
         lFound_it = cWord2find $ ".actually.although.anything.anywhere.couldn't.everyone.existing.happened.likewise.moreover.probable"+;
         ".probably.question.somebody.somewhat.suddenly.together.upcoming.whatever.whenever.wherever.wouldn't.yourself."
      CASE nWord_size = 9
         lFound_it = cWord2find $ ".elsewhere.everybody.extremely.generally.happening.otherwise.ourselves.something.sometimes.somewhere.therefore.shouldn't.withstand."
      CASE nWord_size = 10
         lFound_it = cWord2find $ ".especially.everything.everywhere.heretofore.themselves.thereafter."
   ENDCASE
   IF lFound_it  && If word was found then go back and look for the next word.
      IF lDetect_rept
         cWord_last = cWord2find  && Save to enable repeat occurrence detection.
      ENDIF
      LOOP
   ENDIF
   * ------------------------------------------------------------------------ *

   * ------------------------------------------------------------------------ *
   IF .NOT. lFoundTwice  && If the word is not a repeat.
      IF lDetect_rept
         cWord_last = cWord2find  && Save to enable repeat occurrence detection.
      ENDIF

      IF nSkip_sum > 0  && If any words have already been ignored or replaced.
         cWord2seek =  PADR(cWord_text, nMaxWordLen)

         * If any words exist in the array of words that are to be skipped
         * or words that have already been replaced, then search this array,
         * using a B-Tree (binary) searching method.
         *
         nLine_end = nSkip_sum
         nLine_strt = nRow_first
         nRow_num = nLine_strt + INT((nLine_end - nLine_strt)/2)
         DO WHILE aWord_list[nRow_num] <> cWord2seek
            DO CASE
               CASE nLine_end - nLine_strt < 3  && If search is narrowed to 2 rows.
                   DO CASE
                      CASE aWord_list[nLine_strt] = cWord2seek
                         nRow_num = nLine_strt
                      CASE aWord_list[nLine_end] = cWord2seek
                         nRow_num = nLine_end
                      OTHERWISE
                         nRow_num = 0
                   ENDCASE
                   EXIT
               CASE aWord_list[nRow_num] > cWord2seek  && Item is before current row.
                   nLine_end = nRow_num - 1
               CASE aWord_list[nRow_num] < cWord2seek  && Item is after current row.
                   nLine_strt = nRow_num + 1
            ENDCASE
            nRow_num = nLine_strt + INT((nLine_end - nLine_strt)/2)
         ENDDO
         *
         lFound_it = (nRow_num > 0)
         IF lFound_it  && If word was found, then see if it was replaced.
            nWord_lrow = nRow_num
            nCol_num = AT(cFlag_repl, aWord_list[nRow_num])
            IF nCol_num > 0
               cWord_repl = LEFT(SUBSTR(aWord_list[nRow_num], nCol_num + 1) + SPACE(nMaxWordLen), nMaxWordLen)
               lFoundPrior = .T.
               nFound_num = nRow_num
            ELSE
               LOOP
            ENDIF
         ENDIF
      ENDIF

      IF .NOT. lFound_it .AND. .NOT. lFoundPrior
         * Since the quick lookups failed and the word isn't a duplicate, do a
         * database lookup.
         nWordMaxLen = IIF(nWord_size < 9, 8, IIF(nWord_size < 13, 12, nMaxWordLen))
         cWord2seek =  LEFT(cWord_text + SPACE(nWordMaxLen), nWordMaxLen)
         cWord2seekL = LOWER(cWord2seek)

         * If word is 1 to 8 characters, use WORDS1.DBF, if 9 to 12 characters,
         * use WORDS2.DBF otherwise if 13 to 20 then use WORDS3.DBF.
         cDict_use = IIF(nWord_size < 9, "WORDS1", IIF(nWord_size < 13, "WORDS2", "WORDS3"))

         IF cDict_last <> cDict_use  && If another dictionary is needed.
            SELECT (cDict_use)
            cDict_last = cDict_use
         ENDIF

         IF lWord_is1st   && If word is 1st in sentence, then 1st seek its lower case version.
            SEEK cWord2seekL
            IF EOF()
               SEEK cWord2seek
            ENDIF
            lFound_it = .NOT. EOF()
         ELSE            && If word is not 1st word, then seek its original capitalization.
            SEEK cWord2seek
            IF EOF()
               SEEK cWord2seekL
               lFound_it = .NOT. EOF()
               IF lFound_it .AND. nWord_size > 1
                  * If capitalization different, then check for unusual
                  * capitalization.
                  DO CASE
                     CASE ISLOWER(cWord_text)  && If first character is lower case.
                        lDiff_CAPs = .T.
                     CASE ISUPPER(SUBSTR(cWord_text, 2, 2))
                        * If the first 2 characters are upper case, then make
                        * sure that the whole word is upper case.
                        nCol_num = 2
                        DO WHILE ISUPPER(SUBSTR(cWord_text, nCol_num, 1)) .AND. nCol_num < nWord_size
                           nCol_num = nCol_num + 1
                        ENDDO
                        IF nCol_num < nWord_size .OR. .NOT. ISUPPER(SUBSTR(cWord_text, nWord_size, 1))
                           lDiff_CAPs = .T.
                        ENDIF
                     OTHERWISE
                        * If the 1st character is upper case and the 2nd is
                        * is lower, then verify that the rest of word is lower.
                        nCol_num = 2
                        DO WHILE ISLOWER(SUBSTR(cWord_text, nCol_num, 1)) .AND. nCol_num < nWord_size
                           nCol_num = nCol_num + 1
                        ENDDO
                        IF nCol_num < nWord_size .OR. .NOT. ISLOWER(SUBSTR(cWord_text, nWord_size, 1))
                           lDiff_CAPs = .T.
                        ENDIF
                  ENDCASE
               ENDIF
            ELSE
               lFound_it = .T.
            ENDIF
         ENDIF
         IF lFound_it .AND. .NOT. lDiff_CAPs  && If word was found then go back and look for the next word.
            LOOP
         ENDIF
      ENDIF
   ENDIF

   * ------------------------------------------------------------------------ *
   IF nCol_end > nCol_max  && If text is wider than the display area.
      nCol_offset = 1 + (nCol_end - nCol_max)
      nScr_col = 3 + (nCol_start - nCol_offset)  && Assign highlighted word screen display column.
   ELSE
      nCol_offset = 0
      nScr_col = 2 + nCol_start
   ENDIF
   * ------------------------------------------------------------------------ *

   * Copy screen formatted lines to a screen display array------------------- *
   FOR nRow_num = 1 TO 7
      IF nCol_offset > 0  && If display is horizontally scrolled.
         aText_say[nRow_num] = PADR(SUBSTR(aTextshow[nRow_num], nCol_offset, nCol_max), nCol_max)
      ELSE
         aText_say[nRow_num] = PADR(aTextshow[nRow_num], nCol_max)
      ENDIF
      IF .NOT. lCheck_file
         IF cTab_char $ aText_say[nRow_num]
            * If line contains Tab character, then replace with a non-visible character.
            aText_say[nRow_num] = STRTRAN(aText_say[nRow_num], cTab_char, cTab_charH)
         ENDIF
      ENDIF
   NEXT
   * ------------------------------------------------------------------------ *   

   IF lPlural_end .AND. nWord_size < 19
      cSuspect = PADR(SUBSTR(aTextshow[nLine_num], nCol_start, nCol_end - nCol_start), nMaxWordLen)
   ELSE
      cSuspect = PADR(cWord_text, nMaxWordLen)
   ENDIF
   
   lFound_mis = .T.  && Tells routine that at least 1 misspelled word was found.
   EXIT
ENDDO

lRepl_shown = .F.  && Set to true when user shown suggested replacements.
nSuggest_row = 0    && Number of the suggestion picked by the user.

RETURN (lQuit_loop)
* End of FS_CHECK()---------------------------------------------------------- *



FUNCTION FS_SUGST
PARAMETERS cDict_last, cDict_use, aRec_list, nSuggest_max, lWord_is1st,;
           cWord_LC, nWord_size, cWord_text
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6,0, 5.0 and 3.0
* Function...: FS_SUGST()
* Updated....: Mon  07-08-1996
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
* Notice.....: Copyright 2000 The Ostendorf Lewis Group
* Purpose....: Finds alternate spelling suggestions for a suspect word.
*
* Called by..: FS_VALID()
* Calls......: (none)
*
* Parameters.:
*
*  Name         Type        Description
*  ----------   ----------  ----------------------------------------------------
*  cDict_last   Character   Name of previously used .DBF dictionary file.
*
*  cDict_use    Character   Name of currently needed .DBF dictionary file.
*
*  aRec_list    Array       List of suggested words.
*
*  nSuggest_max Integer     Maximum number of suggestions to gather before scoring & sorting.
*
*  lWord_is1st  Logical     If true, then word is the first in its sentence.
*
*  cWord_LC     Character   Assign a lower case version of the word to find.
*
*  nWord_size   Integer     The length of the current word.
*
*  cWord_text   Character   Trimmed version of the word currently being checked.

EXTERNAL ARRAY aRec_list

PRIVATE nCol_hold, aFile_list, nLen_diff, nMatchScore, nRow_hold, nRow_pos, nRowHighest,;
        nRow_num, cShort_str, nShort_size, lShort_test, cSuggest_UC, nSuggest_lim,;
        nSuggest_sho, nSuggest_sum, cSoundexCode, cString, cValue, cValue_hold, cWord_UC,;
        cWord2find, cWord_mid, cWord_L1, cWord_L2, cWord_L3, cWord_L4, cWord_M3,;
        cWord_M4, cWord_M5, cWord_R1, cWord_R2, cWord_R3, cWord_R4, cWord_RTRIM

nCol_hold = 0     && Temporary column position holder.
DECLARE aFile_list[3]  && List of dictionaries to search through.
aFile_list = ""   && Initialize array of dictionary work areas to all nulls.
nLen_diff = 0     && Absolute difference in size of typed word and suggested word.
nMatchScore = 0   && Score indicating word's closeness of match to suggested word.
nSuggest_sum = 0   && Number of words in the array of suggested words.
aRec_list = ""    && Clear out prior suggestions.
nRow_hold = 0     && Temporary row position holder.
nRow_num = 0      && Temporary row position holder.
nRow_pos = 0      && Temporary row number.
cSoundexCode = SOUNDEX(cWord_text)  && Calculate the soundex code.
nShort_size = 0   && Length of a subsection of the target word.
cShort_str = "."  && List of words that whose left side matches target word.
lShort_test = .F. && True if 1 or more suggestions found by substring matching.
cSuggest_UC = ""  && Upper case version of a suggested word.
nSuggest_sho = 40  && Maximum number of suggestions to show on the screen.
cValue = ""       && Holds a aRec_list[] value.
cValue_hold = ""  && Saves a copy of cValue.
cWord_UC = UPPER(cWord_text)  && Upper case version of the target word.
cWord2find = IIF(lWord_is1st, cWord_LC, cWord_text)
cWord_mid = ""    && All characters after the first 2 of the suggested word.
cWord_L1 = ""     && Left character of the target word.
cWord_L2 = ""     && Left 2 characters of target word.
cWord_L3 = ""     && Left 3 characters of target word.
cWord_L4 = ""     && Left 4 characters of target word.
cWord_M3 = ""     && Middle 4 characters, offset by 3 of the target word.
cWord_M4 = ""     && Middle 4 characters, offset by 4 of the target word.
cWord_M5 = ""     && Middle 4 characters, offset by 5 of the target word.
cWord_R1 = ""     && Right character of the target word.
cWord_R2 = ""     && Right 2 characters of target word.
cWord_R3 = ""     && Right 3 characters of target word.
cWord_R4 = ""     && Right 4 characters of target word.
cWord_RTRIM = ""  && RTRIM() version of dictionary word.

* This next section determines which spelling dictionaries should be used
* based on the length of the word to be found.  Only dictionaries that
* contain words whose size is within 4 characters of the sought after word
* will be used.
* WORDS1.DBF: 1 - 8,  WORDS2.DBF: 9 - 12,  WORDS3: 13 - 20 characters.
DO CASE
   CASE nWord_size < 4                          && Use lower file only.
      nRow_hold = 1
      aFile_list[1] = "WORDS1"  && Use WORDS1.DBF
   CASE nWord_size >= 4  .AND. nWord_size <= 8   && Use lower file and middle files.
      nRow_hold = 2
      aFile_list[1] = "WORDS1"  && Use WORDS1.DBF
      aFile_list[2] = "WORDS2"  && Use WORDS2.DBF
   CASE nWord_size >= 9  .AND. nWord_size <= 12  && Use lower, middle and upper files.
      nRow_hold = 3
      aFile_list[1] = "WORDS1"  && Use WORDS1.DBF
      aFile_list[2] = "WORDS2"  && Use WORDS2.DBF
      aFile_list[3] = "WORDS3"  && Use WORDS3.DBF
   CASE nWord_size >= 13 .AND. nWord_size <= 16  && Use middle and upper files.
      nRow_hold = 2
      aFile_list[1] = "WORDS2"  && Use WORDS2.DBF
      aFile_list[2] = "WORDS3"  && Use WORDS3.DBF
   OTHERWISE                                   && Use upper file only.
      nRow_hold = 1
      aFile_list[1] = "WORDS3"  && Use WORDS3.DBF
ENDCASE

cDict_last = cDict_use  
SELECT (cDict_use)

* Gather all of the lexically similar words into aRec_list[].
DO WHILE nRow_pos < nRow_hold
   nRow_pos = nRow_pos + 1

   cDict_use = aFile_list[nRow_pos]
   IF cDict_last <> cDict_use  && If another dictionary is needed.
      SELECT (cDict_use)
      cDict_last = cDict_use
   ENDIF

   * --------------------------------------------------------------------- *
   * Load up to 6 words that match the target word's left-hand section.
   nShort_size = nWord_size
   nCol_hold = nWord_size - 4
   nRow_num = 0
   DO WHILE nShort_size > 0 .AND. nShort_size > nCol_hold .AND. nRow_num = 0 .AND. nSuggest_sum < nSuggest_max
      cString = LEFT(cWord2find, nShort_size)
      SEEK cString
      DO WHILE nRow_num < 6 .AND. WORD = cString .AND. .NOT. EOF()
         nRow_num = nRow_num + 1
         nSuggest_sum = nSuggest_sum + 1
         aRec_list[nSuggest_sum] = RTRIM(WORD)
         cShort_str = cShort_str + aRec_list[nSuggest_sum] + "."
         SKIP
      ENDDO
      nShort_size = nShort_size - 1
   ENDDO
   IF nRow_num > 0
      lShort_test = .T.
   ENDIF
   * --------------------------------------------------------------------- *

   * --------------------------------------------------------------------- *
   * Load up to 5 words that match the target word's right-hand section.
   nShort_size = nWord_size - 1
   nCol_hold = nWord_size - 3
   nRow_num = 0
   DO WHILE nShort_size > 0 .AND. nShort_size > nCol_hold .AND. nRow_num = 0 .AND. nSuggest_sum < nSuggest_max
      cString = RIGHT(cWord2find, nShort_size)
      SEEK cString
      DO WHILE nRow_num < 5 .AND. WORD = cString .AND. .NOT. EOF()
         cWord_RTRIM = RTRIM(WORD)
         IF lShort_test
            IF ("." + cWord_RTRIM + ".") $ cShort_str  && If suggestion already loaded.
               SKIP
               LOOP
            ENDIF
         ENDIF
         nRow_num = nRow_num + 1
         nSuggest_sum = nSuggest_sum + 1
         aRec_list[nSuggest_sum] = cWord_RTRIM
         cShort_str = cShort_str + cWord_RTRIM + "."
         SKIP
      ENDDO
      nShort_size = nShort_size - 1
   ENDDO
   IF nRow_num > 0
      lShort_test = .T.
   ENDIF
   * --------------------------------------------------------------------- *
ENDDO

* Check dictionaries for transposed and truncated version of word------------ *
IF nWord_size = 2
   * If a word is two characters long, then this function transposes
   * these two characters and looks up the word.  If the transposed
   * version of this word is found in the dictionary, then this
   * function adds the word to the suggestion list.  It also appends
   * a character CHR(127) to the suggestion list to tell the
   * suggestion sorting routine to move this word to the top.
   = FS_FLIP2(cWord2find, nWord_size, @aRec_list, @cShort_str, @lShort_test, @nSuggest_sum,;
              @cDict_use, @cDict_last, cWeight_high)
ELSE
   * This function transposes each adjacent two character pair in
   * the suspect word and then looks it up.  If the transposed
   * version of the word is found in the dictionary, then this
   * function adds the word to the suggestion list.
   = FS_FLIPX(cWord2find, nWord_size, @aRec_list, @cShort_str, @lShort_test, @nSuggest_sum,;
              @cDict_use, @cDict_last, cWeight_low)

   * This next function sequentially removes each character of the
   * the suspect word and then looks it up.  If the truncated
   * version of the word is found in the dictionary, then this
   * function adds the word to the suggestion list.
   = FS_DROPC(cWord2find, nWord_size, @aRec_list, @cShort_str, @lShort_test, @nSuggest_sum,;
              @cDict_use, @cDict_last, cWeight_low)
ENDIF
* --------------------------------------------------------------------------- *

nRow_pos = 0
DO WHILE nRow_pos < nRow_hold
   nRow_pos = nRow_pos + 1

   cDict_use = aFile_list[nRow_pos]
   IF cDict_last <> cDict_use  && If another dictionary is needed.
      SELECT (cDict_use)
      cDict_last = cDict_use
   ENDIF
   SET ORDER TO TAG SOUND  && Select the soundex index.

   DO CASE
      CASE nRow_hold = 3 .AND. nRow_pos = 1
         nSuggest_lim = INT((nSuggest_max - nSuggest_sum)/3)
      CASE (nRow_hold = 2 .AND. nRow_pos = 1) .OR. (nRow_hold = 3 .AND. nRow_pos = 2)
         nSuggest_lim = INT((nSuggest_max - nSuggest_sum)/2)
      OTHERWISE
         nSuggest_lim = nSuggest_max
   ENDCASE

   SEEK cSoundexCode
   DO WHILE SOUNDEX(WORD) = cSoundexCode .AND. nSuggest_sum < nSuggest_lim .AND. .NOT. EOF()
      cString = RTRIM(WORD)
      IF lShort_test
         IF ("." + cString + ".") $ cShort_str  && If suggestion already loaded.
            SKIP
            LOOP
         ENDIF
      ENDIF
      nSuggest_sum = nSuggest_sum + 1
      aRec_list[nSuggest_sum] = cString
      SKIP
   ENDDO
   SET ORDER TO TAG TEXT  && Select the WORD field index.
ENDDO

* Weight the suggested words by their closeness of match.
cWord_L1 = LEFT(cWord_UC, 1)
cWord_R1 = RIGHT(cWord_UC, 1)
IF nWord_size > 1
   cWord_L2 = LEFT(cWord_UC, 2)
   cWord_R2 = RIGHT(cWord_UC, 2)
ENDIF
IF nWord_size > 2
   cWord_L3 = LEFT(cWord_UC, 3)
   cWord_R3 = RIGHT(cWord_UC, 3)
ENDIF
IF nWord_size > 3
   cWord_L4 = LEFT(cWord_UC, 4)
   cWord_R4 = RIGHT(cWord_UC, 4)
ENDIF
IF nWord_size > 9
   cWord_M3 = SUBSTR(cWord_UC, 4, 4)
   cWord_M4 = SUBSTR(cWord_UC, 5, 4)
   cWord_M5 = SUBSTR(cWord_UC, 6, 4)
ENDIF

nRow_num = 0
DO WHILE nRow_num < nSuggest_sum
   nRow_num = nRow_num + 1
   nMatchScore = 0
   cSuggest_UC = UPPER(aRec_list[nRow_num])
   nLen_diff = ABS(nWord_size - LEN(aRec_list[nRow_num]))

   DO CASE
      CASE nWord_size = 2 .AND. RIGHT(aRec_list[nRow_num], 1) = cWeight_high
         * If the suggestion was found by the character transposing
         * FS_FLIP2() function, then weight it more heavily and remove
         * the weight marker character.
         aRec_list[nRow_num] = LEFT(aRec_list[nRow_num], LEN(aRec_list[nRow_num]) - 1)
         nMatchScore = 50

      CASE nWord_size > 2 .AND. RIGHT(aRec_list[nRow_num], 1) = cWeight_low
         * If the suggestion was found by the character transposing
         * FS_FLIPX() function or the character elimination FS_DROPC()
         * function, then weight it more heavily and remove the weight.
         aRec_list[nRow_num] = LEFT(aRec_list[nRow_num], LEN(aRec_list[nRow_num]) - 1)
         nMatchScore = 15
   ENDCASE

   DO CASE
      CASE nLen_diff = 0
         nMatchScore = nMatchScore + 8
      CASE nLen_diff = 1
         nMatchScore = nMatchScore + 6
      CASE nLen_diff = 2
         nMatchScore = nMatchScore + 4
      CASE nLen_diff = 3
         nMatchScore = nMatchScore + 2
      CASE nLen_diff = 4
         nMatchScore = nMatchScore + 1
   ENDCASE

   IF (nWord_size <= 10 .AND. nLen_diff <= 4) .OR. (nWord_size > 10 .AND. nLen_diff <= 5)
      DO CASE
         CASE cSuggest_UC = cWord_L4
            nMatchScore = nMatchScore + 9
         CASE cSuggest_UC = cWord_L3
            nMatchScore = nMatchScore + 5
         CASE cSuggest_UC = cWord_L2
            nMatchScore = nMatchScore + 3
         CASE cSuggest_UC = cWord_L1
            nMatchScore = nMatchScore + 1
      ENDCASE
      DO CASE
         CASE RIGHT(cSuggest_UC, 4) = cWord_R4
            nMatchScore = nMatchScore + 5
         CASE RIGHT(cSuggest_UC, 3) = cWord_R3
            nMatchScore = nMatchScore + 4
         CASE RIGHT(cSuggest_UC, 2) = cWord_R2
            nMatchScore = nMatchScore + 3
         CASE RIGHT(cSuggest_UC, 1) = cWord_R1
            nMatchScore = nMatchScore + 2
      ENDCASE
      IF nWord_size > 9
         cWord_mid = SUBSTR(cSuggest_UC, 3)
         IF cWord_M3 $ cWord_mid .OR. cWord_M4 $ cWord_mid .OR. cWord_M5 $ cWord_mid
            nMatchScore = nMatchScore + 4
         ENDIF
      ENDIF

      IF nLen_diff > 3 .AND. nMatchScore > 0
         * If length different is 4 or more, then reduce score by 25%
         nMatchScore = INT(nMatchScore/.75)
      ENDIF
   ENDIF
   aRec_list[nRow_num] = STR(nMatchScore, 2) + aRec_list[nRow_num]
ENDDO

* Sort the suggestion list for the 20 highest ranking suggestions and
* remove the leading nMatchScore string at the same time.
nRow_num = 1
nRowHighest = nSuggest_sum
nRow_pos = 1

DO WHILE nSuggest_sum > nRow_pos .AND. nRow_pos <= nSuggest_sho
   nRow_num = nSuggest_sum
   cValue = aRec_list[nRow_num]
   DO WHILE nRow_num >= nRow_pos
      IF aRec_list[nRow_num] > cValue
         cValue = aRec_list[nRow_num]
         nRowHighest = nRow_num
      ENDIF
      nRow_num = nRow_num - 1
   ENDDO
   cValue_hold = aRec_list[nRow_pos]    && Save array element to be displaced.
   aRec_list[nRow_pos] = cValue         && Store highest element in new location.
   aRec_list[nRowHighest] = cValue_hold && Replace old position with displaced element.
   nRowHighest = nSuggest_sum
   nRow_pos = nRow_pos + 1
ENDDO

* Eliminate any suggestions with a weight of less than 1
nSuggest_sum = MIN(nSuggest_sum, nSuggest_sho)
nRow_pos = 1
DO WHILE nRow_pos <= nSuggest_sum .AND. aRec_list[nRow_pos] <> " 0"  
   aRec_list[nRow_pos] = SUBSTR(aRec_list[nRow_pos], 3)
   nRow_pos = nRow_pos + 1
ENDDO
nSuggest_sum = nRow_pos - 1

RETURN (nSuggest_sum)
* End of FS_SUGST()---------------------------------------------------------- *



* --------------------------------------------------------------------------- *
FUNCTION FS_W_INS
PARAMETERS cWord2seek, nMaxWordLen, aWord_list, cWord_repl, nSkip_sum
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Updated....: Wed  01-24-1996
* Purpose....: Insert the non-found or replaced word into aWord_list[].
* Called by..: FS_MAIN.SCX
* Calls......: (none)

* Add the new cValue to the list in sorted order.
cWord2seek = LEFT(cWord2seek + SPACE(nMaxWordLen), nMaxWordLen)
* Calculate the exact position for the new element.
nSkip_sum = nSkip_sum + 1
nRow_num = 1
DO WHILE nRow_num < nSkip_sum .AND. cWord2seek > aWord_list[nRow_num]
   nRow_num = nRow_num + 1
ENDDO
nRow_num =  IIF(nRow_num < nSkip_sum .OR. cWord2seek <= aWord_list[nRow_num], nRow_num, nRow_num + 1)
nRow_hold = nSkip_sum
DO WHILE nRow_hold > nRow_num  && Open up a space to move the new element to.
   aWord_list[nRow_hold] = aWord_list[nRow_hold - 1]
   nRow_hold = nRow_hold - 1
ENDDO
aWord_list[nRow_num] = cWord_repl
RETURN (.T.)
* End of FS_W_INS()---------------------------------------------------------- *



FUNCTION FS_FLIP2
PARAMETERS cWord2find, nWord_size, aRec_list, cShort_str, lShort_test, nSuggest_sum,;
           cDict_use, cDict_last, cWeight_high
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6,0, 5.0 and 3.0
* Function...: FS_SPELL()
* Updated....: Wed  01-24-1996
* Author.....: David Elliot Lewis, Ph.D. based on an algorithm provided by
*              Michael Jarvis.
*
* Purpose....: If a word is two characters long, then this function transposes
*              these two characters and looks up the word.  If the transposed
*              version of this word is found in the dictionary, then this
*              function adds the word to the suggestion list.  It also appends
*              a character CHR(127) to the suggestion list to tell the
*              suggestion sorting routine to move this word to the top.
*
* Called by..: FS_SPELL()
*
* Parameters.:
*
*  Name         Type        Description
*  ----------   ----------  ----------------------------------------------------
*  cWord2find   Character   Current suspect word to be looked up.
*
*  nWord_size   Integer     Length of the suspect word held by cWord2find.
*
*  aRec_list    Array       List of suggested words.
*
*  cShort_str   Character   Delimited suspect word list for duplicate checking.
*
*  lShort_test  Logical     If true, then one or more suggestions have been found.
*
*  nSuggest_sum Integer     Number of words in the aRec_list[] suggestions array.
*
*  cDict_use    Character   Name of currently needed .DBF dictionary file.
*
*  cDict_last   Character   Name of previously used .DBF dictionary file.
*
*  cWeight_high Character   Character that is assigned to indicate if a
*                           suggestion is to be heavily weighted.

PRIVATE cWord_twist

IF cDict_last <> "WORDS1"  && If short words file isn't selected.
   SELECT WORDS1
   cDict_last = "WORDS1"
ENDIF

*  Swap the position of the left and right characters
cWord_twist = RIGHT(cWord2find, 1) + LEFT(cWord2find, 1)

IF SEEK(cWord_twist) .AND. cWord_twist == RTRIM(WORD) && If the transposed word exists in the dictionary.
   IF .NOT. ("." + cWord_twist + "." $ cShort_str)
      * If the word hasn't been added to the suggestion list, then add it now.
      nSuggest_sum = nSuggest_sum + 1
      aRec_list[nSuggest_sum] = cWord_twist + cWeight_high
      cShort_str = cShort_str + cWord_twist + "."
      lShort_test = .T.
   ENDIF
ENDIF
RETURN (.T.)
* End of FS_FLIP2------------------------------------------------------------ *



FUNCTION FS_FLIPX
PARAMETERS cWord2find, nWord_size, aRec_list, cShort_str, lShort_test, nSuggest_sum,;
           cDict_use, cDict_last, cWeight_low
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6,0, 5.0 and 3.0
* Function...: FS_SPELL()
* Updated....: Wed  01-24-1996
* Author.....: David Elliot Lewis, Ph.D. based on an algorithm provided by
*              Michael Jarvis.
*
* Purpose....: This function transposes each adjacent two character pair in
*              the suspect word and then looks it up.  If the transposed
*              version of the word is found in the dictionary, then this
*              function adds the word to the suggestion list.
*
* Called by..: FS_SPELL()
*
* Parameters.:
*
*  Name         Type        Description
*  ----------   ----------  ----------------------------------------------------
*  cWord2find   Character   Current suspect word to be looked up.
*
*  nWord_size   Integer     Length of the suspect word held by cWord2find.
*
*  aRec_list    Array       List of suggested words.
*
*  cShort_str   Character   Delimited suspect word list for duplicate checking.
*
*  lShort_test  Logical     If true, then one or more suggestions have been found.
*
*  nSuggest_sum Integer     Number of words in the aRec_list[] suggestions array.
*
*  cDict_use    Character   Name of currently needed .DBF dictionary file.
*
*  cDict_last   Character   Name of previously used .DBF dictionary file.
*
*  cWeight_low  Character   Character that is assigned to indicate if a
*                           suggestion is to be moderately weighted.

PRIVATE cWord_twist, nCol_num, nWord_width

nWord_width = nWord_size - 1

* If word is 1 to 8 characters, use WORDS1.DBF, if 9 to 12 characters,
* use WORDS2.DBF otherwise if 13 to 20 then use WORDS3.DBF.
cDict_use = IIF(nWord_size < 9, "WORDS1", IIF(nWord_size < 13, "WORDS2", "WORDS3"))
IF cDict_last <> cDict_use  && If another dictionary is needed.
   SELECT (cDict_use)
   cDict_last = cDict_use
ENDIF

FOR nCol_num = 1 TO nWord_width
   * The following case statement swaps the position of the suspect word's
   * current character with its immediately following character.
   DO CASE
      CASE nCol_num = 1  && If on first character.
         cWord_twist = SUBSTR(cWord2find, 2, 1) + LEFT(cWord2find, 1) + ;
                      RIGHT(cWord2find, nWord_size - 2)
                     
      CASE nCol_num = nWord_size  && If on the second to the last character.
         cWord_twist = LEFT(cWord2find, nWord_size - 1) + ;
                      RIGHT(cWord2find, 1) + SUBSTR(cWord2find, nCol_num, 1)

      OTHERWISE  && If past first character, but before 2nd to last character.
         cWord_twist = LEFT(cWord2find, nCol_num - 1) + ;
                     SUBSTR(cWord2find, nCol_num + 1, 1) + ;
                     SUBSTR(cWord2find, nCol_num, 1) + ;
                     SUBSTR(cWord2find, nCol_num + 2)
   ENDCASE

   IF SEEK(cWord_twist) .AND. cWord_twist == RTRIM(WORD)  && If the transposed word exists in the dictionary.
      IF .NOT. ("." + cWord_twist + "." $ cShort_str)
         * If the word hasn't been added to the suggestion list, then add it now.
         nSuggest_sum = nSuggest_sum + 1
         aRec_list[nSuggest_sum] = cWord_twist + cWeight_low
         cShort_str = cShort_str + cWord_twist + "."
         lShort_test = .T.
      ENDIF
   ENDIF
NEXT
RETURN (.T.)
* End of FS_FLIPX()---------------------------------------------------------- *



FUNCTION FS_DROPC
PARAMETERS cWord2find, nWord_size, aRec_list, cShort_str, lShort_test, nSuggest_sum,;
           cDict_use, cDict_last, cWeight_low
* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6,0, 5.0 and 3.0
* Function...: FS_SPELL()
* Updated....: Wed  01-24-1996
* Author.....: David Elliot Lewis, Ph.D. based on an algorithm provided by
*              Michael Jarvis.
*
* Purpose....: This function sequentially removes each character of the
*              the suspect word and then looks it up.  If the truncated
*              version of the word is found in the dictionary, then this
*              function adds the word to the suggestion list.
*
* Called by..: FS_SPELL()
*
* Parameters.:
*
*  Name         Type        Description
*  ----------   ----------  ----------------------------------------------------
*  cWord2find   Character   Current suspect word to be looked up.
*
*  nWord_size   Integer     Length of the suspect word held by cWord2find.
*
*  aRec_list    Array       List of suggested words.
*
*  cShort_str   Character   Delimited suspect word list for duplicate checking.
*
*  lShort_test  Logical     If true, then one or more suggestions have been found.
*
*  nSuggest_sum Integer     Number of words in the aRec_list[] suggestions array.
*
*  cDict_use    Character   Name of currently needed .DBF dictionary file.
*
*  cDict_last   Character   Name of previously used .DBF dictionary file.
*
*  cWeight_low  Character   Character that is assigned to indicate if a
*                           suggestion is to be moderately weighted.

PRIVATE cWord_twist, nCol_num, nWord_width

nWord_width = nWord_size - 1

* If the truncated word is 1 to 8 characters, use WORDS1.DBF, if 9 to 12
* characters, use WORDS2.DBF otherwise if 13 to 20 then use WORDS3.DBF.
cDict_use = IIF(nWord_width < 9, "WORDS1", IIF(nWord_width < 13, "WORDS2", "WORDS3"))
IF cDict_last <> cDict_use  && If another dictionary is needed.
   SELECT (cDict_use)
   cDict_last = cDict_use
ENDIF

* The next loop sequentially drops each character of the suspect word and then
* searches the dictionary for this truncated form.  If it is found, then it
* adds the truncated version of the suspect word to the suggestion list.
FOR nCol_num = 1 to nWord_size
   DO CASE
      CASE nCol_num = 1          && Eliminate the left most character.
         cWord_twist = RIGHT(cWord2find, nWord_width)
         
      CASE nCol_num = nWord_size  && Eliminate the right most character.
         cWord_twist = LEFT(cWord2find, nWord_width)
         
      OTHERWISE                 && Eliminate the current character.
         cWord_twist = LEFT(cWord2find, nCol_num - 1) + RIGHT(cWord2find, nWord_size - nCol_num)
   ENDCASE
           
   IF SEEK(cWord_twist) .AND. cWord_twist == RTRIM(WORD)  && If the truncated word exists in the dictionary.
      IF .NOT. ("." + cWord_twist + "." $ cShort_str)
         * If the word hasn't been added to the suggestion list, then add it now.
         nSuggest_sum = nSuggest_sum + 1
         aRec_list[nSuggest_sum] = cWord_twist + cWeight_low
         cShort_str = cShort_str + cWord_twist + "."
         lShort_test = .T.
      ENDIF
   ENDIF
NEXT
RETURN (.T.)
* End of FS_DROPC()---------------------------------------------------------- *
* EOF (Foxspell Checker)
