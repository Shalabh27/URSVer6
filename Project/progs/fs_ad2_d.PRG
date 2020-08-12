* Program....: Foxspell Checker for Visual FoxPro
* Version....: 3.0h
* Compiler...: Visual FoxPro 6.0, 5.0 and 3.0
* File name..: FS_AD2_D.PRG
* Updated....: Thu  09-09-1993
* Author.....: David Elliot Lewis, Ph.D., Tel: 415-563-375, Email: FS_VFP@StrategicEdge.com
* Notice.....: Copyright 2000 The Ostendorf Lewis Group.
*
* Purpose....: Uploads an ASCII file containing a list of words into the
*              Spell Checker dictionaries.
*
*              This ASCII file must be a simple list of words, with one word
*              per line, and each line ending with a hard carriage return
*              (ASCII 13) and a line feed (ASCII 10).  Only words that are 20
*              or fewer characters in length will be uploaded.
*
*              Lines that are empty, contain words longer than 20 characters,
*              contain more than one word, contain hyphens "-", or contain
*              a word that already exists in one of the three dictionaries will
*              be ignored.  Since the dictionaries are capitalization specific,
*              however, a duplicate word will be uploaded if its capitalization
*              differs from the word in the dictionary.
*
* Note.......: This is a completely stand alone program.  It is not called by
*              any other module in the Foxspell Checker program and it in turn
*              does not call any other module.
*
* Called by..: (none)
* Calls......: FS_AD2_D.SCX
*
* Uses.......: The following three dictionary files of WORDS1.DBF, WORDS2.DBF
*              and WORDS3.DBF are used.  If the index files do not exist, then
*              this module will create the following compound structural index
*              for each dictionary file.
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
* --------------------------------------------------------------------------- *

SET TALK OFF
SET SCOREBOARD OFF
*SET EXCLUSIVE ON
SET ESCAPE OFF
SET EXACT OFF
SET STATUS BAR ON

* --------------------------------------------------------------------------- *
PRIVATE nError_num, cErrorLine1, cErrorLine2, cFile_name, nFileHandle,;
        nRow_num, nTextLength, wordsTooLong, double_words, hyphen_words, word_multi,;
        cWord_text, nWord_size, nWords_added, cWord2Seek

cErrorLine1 = "" && Error message holder.
cErrorLine2 = "" && Error message holder.
cFile_name = SPACE(48)  && Name and path of the ASCII file containing the words to import.
nRow_num = 0     && Counter to enable screen updating of progress.
wordsTooLong = 0 && Number of import words not copied because they're too long.
double_words = 0 && Number of import words not copied because they're duplicates.
hyphen_words = 0 && Number of words not imported because they contain a hyphen.
word_multi = 0   && Number of lines not imported due to containing multiple words.
cWord_text = ""  && Current import word.
nWord_size = 0   && Length of the current import word (cWord_text).
nWords_added = 0 && Total number of words that were imported.
cWord2Seek = ""  && Padded version of the word to import.
* --------------------------------------------------------------------------- *

* Verify that all needed files are present----------------------------------- *
DO CASE
   CASE .NOT. FILE('WORDS1.DBF')
      cErrorLine1 = "Missing the dictionary file WORDS1.DBF"
   CASE .NOT. FILE('WORDS2.DBF')
      cErrorLine1 = "Missing the dictionary file WORDS2.DBF"
   CASE .NOT. FILE('WORDS3.DBF')
      cErrorLine1 = "Missing the dictionary file WORDS3.DBF"
   OTHERWISE
      cErrorLine1 = ""
ENDCASE
IF .NOT. EMPTY(cErrorLine1)
   CLEAR TYPEAHEAD
   = MESSAGEBOX(cErrorLine1, 16, "ERROR")
   RETURN
ENDIF
* --------------------------------------------------------------------------- *

* Verify that index files exist & build if necessary------------------------- *
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

* Get a file name from the user---------------------------------------------- *
nKey_typed = 0
DO FORM FS_AD2_D.SCX
IF nKey_typed = 27  && If user quit,
   RETURN
ENDIF
* --------------------------------------------------------------------------- *

* --------------------------------------------------------------------------- *
cFile_name = ALLTRIM(cFile_name)
nFileHandle = FOPEN(cFile_name, 2)   && Try to open the file to spell check.

* If file couldn't be opened, then display error dialog.
IF nFileHandle = -1
   nError_num = FERROR()
   cErrorLine1 = "Cannot open the file named "+ALLTRIM(cFile_name)+" because"
   DO CASE
      CASE nError_num = 2
         cErrorLine2 = "it was not found!"
      CASE nError_num = 4
         cErrorLine2 = "there are too many files open."
      CASE nError_num = 5
         cErrorLine2 = "access to this file was denied."
      CASE nError_num = 8
         cErrorLine2 = "FoxPro is out of memory."
      CASE nError_num = 29
         cErrorLine2 = "your disk is full."
      OTHERWISE
         cErrorLine2 = "of an undiagnosed error."
   ENDCASE
   = MESSAGEBOX(cErrorLine1 + CHR(13) + cErrorLine2, 16, "Cannot Open File!")
   RETURN
ENDIF
* --------------------------------------------------------------------------- *

* Verify that file isn't empty or blank and load into memory----------------- *
nTextLength = FSEEK(nFileHandle, 0, 2)       && Go to the file's end.

IF nTextLength < 2  && If file is too small.
   = FCLOSE(nFileHandle)                    && Close the file.
   = MESSAGEBOX("The file named " + ALLTRIM(cFile_name) + " is empty!", 48, "File is Empty")
   RETURN
ENDIF

= FSEEK(nFileHandle, 0, 0)                  && Go to the file's beginning.
* --------------------------------------------------------------------------- *

SET MESSAGE TO " Importing Words . . . "

* Upload the words----------------------------------------------------------- *
DO WHILE .NOT. FEOF(nFileHandle)
   nRow_num = nRow_num + 1

   IF (nRow_num % 25) = 0
      WAIT WINDOW "Processed record: " + LTRIM(STR(nRow_num, 8)) NOWAIT
   ENDIF

   cWord_text = RTRIM(FGETS(nFileHandle))
   nWord_size = LEN(cWord_text)

   * This next section determines which spelling dictionaries should be used
   * based on the length of the word to be found.
   * WORDS1.DBF: 1 - 8,  WORDS2.DBF: 9 - 12,  WORDS3: 13 - 20 characters.

   DO CASE
      CASE nWord_size = 0  && If line is empty, then ignore it.
         LOOP

      CASE "-" $ cWord_text  && Word contains a hyphen.
         hyphen_words = hyphen_words + 1
         LOOP

      CASE " " $ cWord_text  && More than one word exists on the line.
         word_multi = word_multi + 1
         LOOP

      CASE nWord_size <= 8
         SELECT WORDS1
         wordMaxLen = 8

      CASE nWord_size <= 12
         SELECT WORDS2
         wordMaxLen = 12

      CASE nWord_size <= 20
         SELECT WORDS3
         wordMaxLen = 20

      OTHERWISE   && If line is too long, then ignore it.
         wordsTooLong = wordsTooLong + 1
         LOOP
   ENDCASE

   cWord2Seek = PADR(cWord_text, wordMaxLen)

   SEEK cWord2Seek

   IF EOF()
      nWords_added = nWords_added + 1
      APPEND BLANK
      REPLACE WORD WITH cWord_text
   ELSE
      double_words = double_words + 1
   ENDIF

ENDDO
* --------------------------------------------------------------------------- *

= FCLOSE(nFileHandle)                    && Close the file.

* Display a status report---------------------------------------------------- *
CLEAR TYPEAHEAD
cString = STR(nWords_added, 6)+" Number of words added to the 3 dictionaries."+CHR(13)+CHR(13)+;
          STR(double_words ,6)+" Words not added because they were already in dictionaries."+CHR(13)+CHR(13)+;
          STR(wordsTooLong, 6)+" Words not added because they were longer than 20 chars."+CHR(13)+CHR(13)+;
          STR(hyphen_words, 6)+" Words not added because they contained a hyphen."+CHR(13)+CHR(13)+;
          STR(word_multi, 6)  +" Lines not added because they contained more than one word." 
= MESSAGEBOX(cString, 64, "Done!")
RETURN
* --------------------------------------------------------------------------- *
* EOF
