**** Created by Shalabh to check default email application
FUNCTION check_outlook
PUBLIC goApp
goApp = CREATEOBJECT('capp')

*!*	*!*	ABC = at("OUTLOOK",UPPER(goApp.ReadReg('HLM','SOFTWARE\Clients\Mail')))
*!*	*!*	?goApp.ReadReg('HLM','SOFTWARE\Clients\Mail')
*!*	*!*	?abc

*!*	?goApp.ReadReg('HLM','SOFTWARE\Clients\Mail')

*!*	?goApp.ReadReg('HCR','mailto\shell\open\command')

Outlook =0

Outlook = AT("OUTLOOK",goApp.ReadReg('HCR','mailto\shell\open\command'))

IF Outlook<1
*MESSAGEBOX("Outlook is not installed")
	RELEASE capp
	RELEASE goApp
	RETURN 1		&& Outlook is not installed
ENDI

** More details
Outlook= AT("OUTLOOK",UPPER(goApp.ReadReg('HCU','SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\Mailto\UserChoice','ProgId')))
IF Outlook<1
*MESSAGEBOX("Default eMail Application is not Outlook")
	RELEASE capp
	RELEASE goApp
	RETURN 2		&& Outlook is not default email application
*ELSE
*	MESSAGEBOX("Default eMail Application is Outlook")

ENDI
RELEASE capp
RELEASE goApp
RETURN 0
ENDFUNC


** Function to return the additional information of Error to be display in email body.
FUNCTION err_mail_body
LPARAMETERS App_name
mErrorString=''
DIMENSION _aErrorInfo(1)
IF TYPE("App_name") = "L"
	nRows=ALINES(_aErrorInfo,lv_errors.MEMORY,1)
ELSE
	nRows=ALINES(_aErrorInfo,lv_errors_formatted.XXX,1)
ENDIF
nErrorLine=0

FOR nErrorLine = 1 TO nRows
	DO CASE
** Original code provided by Client-- Start

*!*		     Case Left(_aErrorInfo[nErrorLine],9)=='GCVERSION'
*!*	        mErrorString=mErrorString+Mline(memory,nErrorLine)+Chr(13)

*!*	     Case Left(_aErrorInfo[nErrorLine],9)=='GCTC_ID  '
*!*	        mErrorString=mErrorString+Mline(memory,nErrorLine)+Chr(13)

*!*	     Case Left(_aErrorInfo[nErrorLine],9)=='CPROGRAM '
*!*	        mErrorString=mErrorString+Mline(memory,nErrorLine)+Chr(13)

*!*	     Case Left(_aErrorInfo[nErrorLine],9)=='CMESSAGE '
*!*	        mErrorString=mErrorString+Mline(memory,nErrorLine)+Chr(13)

*!*	     Case Left(_aErrorInfo[nErrorLine],9)=='nErrorLine_NO '
*!*	        mErrorString=mErrorString+Mline(memory,nErrorLine)+Chr(13)

*!*	     Case Left(_aErrorInfo[nErrorLine],9)=='NERROR   '
*!*	        mErrorString=mErrorString+Mline(memory,nErrorLine)+Chr(13)
*!*		
** Original code provided by Client-- End
	CASE LEFT(_aErrorInfo[nErrorLine],9)=='GCVERSION'
		
		a=AT('"',_aErrorInfo[nErrorLine ],2)-AT('"',_aErrorInfo[nErrorLine ],1)-1
		mErrorString=mErrorString+"GCVERSION: "+SUBSTR(_aErrorInfo[nErrorLine ],AT('"',_aErrorInfo[nErrorLine ],1)+1,a)+CHR(13)

	CASE LEFT(_aErrorInfo[nErrorLine],9)=='GCTC_ID  '
		
		a=AT('"',_aErrorInfo[nErrorLine ],2)-AT('"',_aErrorInfo[nErrorLine ],1)-1
		mErrorString=mErrorString+"GCTC_ID: "+SUBSTR(_aErrorInfo[nErrorLine ],AT('"',_aErrorInfo[nErrorLine ],1)+1,a)+CHR(13)

	CASE LEFT(_aErrorInfo[nErrorLine],9)=='CPROGRAM '
		a=AT('"',_aErrorInfo[nErrorLine ],2)-AT('"',_aErrorInfo[nErrorLine ],1)-1
		mErrorString=mErrorString+"CPROGRAM: "+SUBSTR(_aErrorInfo[nErrorLine ],AT('"',_aErrorInfo[nErrorLine ],1)+1,a)+CHR(13)

	CASE LEFT(_aErrorInfo[nErrorLine],9)=='CMESSAGE '

		a=AT('"',_aErrorInfo[nErrorLine ],2)-AT('"',_aErrorInfo[nErrorLine ],1)-1
		mErrorString=mErrorString+"CMESSAGE: "+SUBSTR(_aErrorInfo[nErrorLine ],AT('"',_aErrorInfo[nErrorLine ],1)+1,a)+CHR(13)

	CASE LEFT(_aErrorInfo[nErrorLine],9)=='NLINE_NO '
*		mErrorString=mErrorString+"NLINE_NO: "+RTRIM(STR(lv_errors.Line_num))+CHR(13)

					a=AT('(',_aErrorInfo[nErrorLine ],1)-AT('N ',_aErrorInfo[nErrorLine ],1)-1
					mErrorString=mErrorString+"NLINE_NO: "+RTRIM(SUBSTR(_aErrorInfo[nErrorLine ],AT('N ',_aErrorInfo[nErrorLine ],1)+1,a))+CHR(13)


	CASE LEFT(_aErrorInfo[nErrorLine],9)=='NERROR   '

			*mErrorString=mErrorString+"NERROR: "+RTRIM(STR(lv_errors.ERROR_num))+CHR(13)
			
					a=AT('(',_aErrorInfo[nErrorLine ],1)-AT('N ',_aErrorInfo[nErrorLine ],1)-1
					mErrorString=mErrorString+"NERROR: "+RTRIM(SUBSTR(_aErrorInfo[nErrorLine ],AT('N ',_aErrorInfo[nErrorLine ],1)+1,a))+CHR(13)
	ENDCASE
ENDFOR

RETURN mErrorString
ENDFUNC


*"HKEY_LOCAL_MACHINE\SOFTWARE\Clients\Mail"
**************************************************
*
DEFINE CLASS capp AS CONTAINER

*-- Reads the windows Registry.
	PROCEDURE ReadReg
* Start of Code
	LPARAMETERS tcKey,tcSubKey,tcValue
	IF PCOUNT() = 2
		tcValue = ""
	ENDIF

* setup environment

	LOCAL nKey, cSubKey, cValue,  cValueRead

	#DEFINE HKEY_USERS                  -2147483645
	#DEFINE HKEY_LOCAL_MACHINE          -2147483646
	#DEFINE HKEY_CURRENT_USER           -2147483647
	#DEFINE HKEY_CLASSES_ROOT            -2147483648

	DO CASE
		CASE m.tcKey == "HCR"
			nKey = HKEY_CLASSES_ROOT
		CASE m.tcKey == "HLM"
			nKey = HKEY_LOCAL_MACHINE
		CASE m.tcKey = "HCU"
			nKey = HKEY_CURRENT_USER
		CASE m.tcKey = "HCR"
			nKey = HKEY_CLASSES_ROOT
		OTHERWISE
			nKey = m.tcKey
	ENDCASE

	cSubKey = m.tcSubKey
	cValue  = m.tcValue

* example 1
* nKey = HKEY_LOCAL_MACHINE
* cSubKey = "Software\VfpRegTest"
* cValue = "TestREG_SZ"

* example 2
* nKey = HKEY_CLASSES_ROOT
* cSubKey = "Spin.SpinButton\CLSID"
* cValue = ""


* here is where we will actually read the registry
	cValueRead = THIS.ReadREG_SZ(nKey, cSubKey, cValue)

	IF (EMPTY(cValueRead)) THEN
		cValueRead = "REGISTRY KEY NOT FOUND"
* MESSAGEBOX("Function Not Successful.")  && testing only
	ELSE
* MESSAGEBOX("Function Successful.    " + cValueRead)  && testing only
	ENDIF

	RETURN cValueRead
	ENDPROC


*-- API's used by the ReadReg method.
	PROCEDURE ReadREG_SZ
* This function reads a REG_SZ value from the registry. If successful,
* it will return the value read. If not successful, it will return an empty string.

	PARAMETERS  nKey, cSubKey, cValue
* nKey The root key to open. It can be any of the constants defined below.
*  #DEFINE HKEY_CLASSES_ROOT           -2147483648
*  #DEFINE HKEY_CURRENT_USER           -2147483647
*  #DEFINE HKEY_LOCAL_MACHINE          -2147483646
*  #DEFINE HKEY_USERS                  -2147483645
* cSubKey The SubKey to open.
* cValue The value that is going to be read.

* Constants that are needed for Registry functions
	#DEFINE REG_SZ   1

* WIN 32 API functions that are used
	DECLARE INTEGER RegOpenKey IN Win32API ;
		INTEGER nHKey, STRING @cSubKey, INTEGER @nResult
	DECLARE INTEGER RegQueryValueEx IN Win32API ;
		INTEGER nHKey, STRING lpszValueName, INTEGER dwReserved,;
		INTEGER @lpdwType, STRING @lpbData, INTEGER @lpcbData
	DECLARE INTEGER RegCloseKey IN Win32API INTEGER nHKey

* Local variables used
	LOCAL nErrCode      && Error Code returned from Registry functions
	LOCAL nKeyHandle    && Handle to Key that is opened in the Registry
	LOCAL lpdwValueType && Type of Value that we are looking for
	LOCAL lpbValue      && The data stored in the value
	LOCAL lpcbValueSize && Size of the variable
	LOCAL lpdwReserved  && Reserved Must be 0

* Initialize the variables
	nKeyHandle = 0
	lpdwReserved = 0
	lpdwValueType = REG_SZ
	lpbValue = ""

	nErrCode = RegOpenKey(nKey, cSubKey, @nKeyHandle)
* If the error code isn't 0, then the key doesn't exist or can't be opened.
	IF (nErrCode # 0) THEN
		RETURN ""
	ENDIF

	lpcbValueSize = 1
* Get the size of the data in the value
	nErrCode=RegQueryValueEx(nKeyHandle, cValue, lpdwReserved, @lpdwValueType, @lpbValue, @lpcbValueSize)

* Make the buffer big enough
	lpbValue = SPACE(lpcbValueSize)
	nErrCode=RegQueryValueEx(nKeyHandle, cValue, lpdwReserved, @lpdwValueType, @lpbValue, @lpcbValueSize)

	=RegCloseKey(nKeyHandle)
	IF (nErrCode # 0) THEN
		RETURN ""
	ENDIF

	lpbValue = LEFT(lpbValue, lpcbValueSize - 1)
	RETURN lpbValue
	ENDPROC

ENDDEFINE
