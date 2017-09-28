::------------------------------------------------------------------------------
:: GetDeptDescFiles.cmd
::
:: Created by: Jeramie Shake
:: Date: 12/29/2005
::
:: Description:
::     This program will copy new DeptDesc.dwn files from the sgsql server
::     to the pos-ws machine
::
:: Usage: 
::     GetDeptDescFiles
::
:: Dependent programs:
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     Blat.exe - Sends SMTP email.
::
:: Environment variables:
::     ERROR_FLAG - used for flagging fatal errors.
::
::     WARNING_FLAG - used for flagging non-fatal errors.
::
::     PROG_FOLDER - folder containing this program.
::
::     LOG_FILE - path and filename of the log file.
::
::     ERR_FILE - path and filename of the error file.
::
::------------------------------------------------------------------------------

  :: Set variables.
  @set ERROR_FLAG=FALSE
  @set WARNING_FLAG=FALSE
  @set PROG_FOLDER=%POLLING%\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\GetDeptDescFiles.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\GetDeptDescFiles.err

  :: Set window title and color
  @Title Get DeptDesc Files
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * GetDeptDescFiles            *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Get DeptDesc Files.
  @echo.
::  @pause
  
  @call :MESS Begin getting DeptDesc Files
  
  :: Copy deptdesc files if they exist
  if exist %POLLING%\Data\ReasonCodes\*.dwn copy %POLLING%\Data\ReasonCodes\*.dwn %STOREDATA%\trovato\poll\sql\reasons\
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Data\ReasonCodes\*.dwn to %STOREDATA%\trovato\poll\sql\reasons\ & goto ERR
::  if exist %POLLING%\Data\ReasonCodes\*.dwn copy %POLLING%\Data\ReasonCodes\*.dwn \\10.200.0.75\trovato\poll\sql\reasons\
::  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Data\ReasonCodes\*.dwn to \\10.200.0.75\trovato\poll\sql\reasons\ & goto ERR

  :: Delete files if they exist
  if exist %POLLING%\Data\ReasonCodes\*.dwn del %POLLING%\Data\ReasonCodes\*.dwn
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Data\ReasonCodes\*.dwn & goto ERR

  @call :MESS End getting DeptDesc Files


:CHECKWARN
  :: Check warning flag.
  @if %WARNING_FLAG%==TRUE @goto WARN

:END
  :: Program completed successfully.
  @echo.
  @echo.
  @echo Program completed successfully!
  @echo.
::  @pause

  @call :MESS End Program

  @goto :EOF

:MESS
  :: Write message to log file and screen.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9 >> %LOG_FILE%
  @ver > nul
  @echo.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9
  @ver > nul
  @goto :EOF

:WARN
  :: Program completed with one or more non-fatal errors.
  @echo.
  @echo.
  @echo Program completed with one or more non-fatal errors.
  @echo.
::  @pause

  @call :MESS End Program with non-fatal errors
  @goto ERREND

:ERR
  :: Program abended due to a fatal error.
  @color FC
  @echo.
  @echo.
  @echo FATAL ERROR! Program will be terminated.
  @echo.
::  @pause

  @call :MESS Abend Program

:ERREND
  :: Append the log to the error file.
  @echo. >> %ERR_FILE%
  @echo *********************************** ERROR ************************************ >> %ERR_FILE%
  @copy %ERR_FILE% /A + %LOG_FILE% /A %ERR_FILE% /A > nul

  :: Email log.
  @echo.
  @echo. Attempting to email log to polling administrator...
  @echo.
  @blat %LOG_FILE% -subject "ERROR: GetDeptDescFiles" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
