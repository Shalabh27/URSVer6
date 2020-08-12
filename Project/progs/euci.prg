Set Default To ..

Local lnHandle As Integer, loUCI As Object, lcError As String, lnSize As Integer
lcError=''
lnSize=0

*!* ClrHost.dll is a .Net wrapper 
Declare Integer ClrCreateInstanceFrom In ClrHost.dll string, string, string@, integer@

*!* Using the .Net eUCI Generator with the ClrHost.dll as a host.
lnHandle=ClrCreateInstanceFrom("UCI_Generator.dll","UCI_Generator.GenerateUCI",@lcError,@lnSize)

*!* One or more of the several dll's cannot be instantiated.
If lnHandle <= 0
   Return -1

EndIf

*!* Create an object of the reference
loUCI = Sys(3096,lnHandle)

*!* Get the eUCI number
? loUCI.GetUCI('CRBI1118743A')


*!*   Using the DSI interface
*!*   Declare Integer ClrCreateInstanceFrom In ClrHost.dll string, string, string@, integer@
*!*   lnHandle = ClrCreateInstanceFrom("eUCI.dll","eUCI.cURN",@lcError,@lnSize)
*!*   *!* The One of the several dll hosts cannt be instanciated
*!*   If lnHandle <= 0
*!*      Return -1
*!*   EndIf
*!*   *!* Create an object of the reference
*!*   loUCI = Sys(3096,lnHandle)
*!*   *!* Get the eUCI number
*!*   ? loUCI.EncriptURN('CRBI1118743A')



