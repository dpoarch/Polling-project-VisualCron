SET ERRORFLAG=FALSE
rmdir /s /q c:\temp\robocopytest
@if errorlevel 1 SET ERRORFLAG=TRUE
@echo %ERRORFLAG%
echo %time% >> robocopytest.log
@if errorlevel 1 SET ERRORFLAG=TRUE
@echo %ERRORFLAG%
robocopy P:\poll\bin c:\temp\robocopytest /e /mt /LOG:robocopytest.log
@if errorlevel 8 SET ERRORFLAG=TRUE
@if errorlevel 16 SET ERRORFLAG=TRUE
@echo %ERRORFLAG%
@if %ERRORFLAG%==FALSE CD>NUL
::xcopy P:\poll\bin\*.* c:\temp\robocopytest\ /e >> robocopytest.log
echo %time% >> robocopytest.log
@if errorlevel 1 SET ERRORFLAG=TRUE
@echo %ERRORFLAG%