***********************************************************
* Class eReportsLib
* 
* This file should be compiled into your EXE so that eReports
* can locate FRX and Image files embedded in the application
*
* Copyright (c) 2003 Dbx-Tecnologies (www.dbxtech.com)
***********************************************************
DEFINE CLASS eReportsLib AS Custom

FUNCTION RepoFile (cFrxFile)
    RETURN FILE(cFrxFile)
ENDFUNC

FUNCTION OpenRepoFile (cFrxFile, cAlias)
    USE IN SELECT(cAlias)
    SELECT 0
    USE (cFrxFile) AGAIN SHARED ALIAS (cAlias)
    RETURN USED(cAlias)
ENDFUNC 

FUNCTION GetImage (cImage, cFile)
    LOCAL cFileStr, cSafety
    cSafety = SET("Safety")
    SET SAFETY OFF 
    IF FILE(cImage)
        cFileStr = FILETOSTR(cImage)
        STRTOFILE(cFileStr, cFile)
    ENDIF
    SET SAFETY &cSafety
    RETURN FILE(cFile)
ENDFUNC

FUNCTION Version
    RETURN 2.003008
ENDFUNC

ENDDEFINE
