::------------------------------------------------------------------------------
:: EnableRecoveredTlogProcessing.cmd
::
:: Created by: Christian Adams
:: Date: 8/19/2002
::
:: Description:
::     This program will copy a flag file to allow Arcana Scheduler to execute
::     the job Process Recovered Tlogs (which executes the batch program 
::     ProcessRecoveredTlogs.cmd). It also creates a flag that confirms Post Polling is complete.
::
:: Usage: 
::     EnableRecoveredTlogProcessing
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\EnableRecoveredTlogProcessing.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\EnableRecoveredTlogProcessing.err

  :: Set window title and color
  @Title Enable Recovered Tlog Processing
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *************************************
  @echo * EnableRecoveredTlogProcessing.cmd *
  @echo *                                   *
  @echo * Created by: Christian Adams       *
  @echo *************************************

  @echo.
  @echo Copy flag file to enable processing of recovered tlogs.
  @echo.
::  @pause

:KICKOFFDOCS
  :: Kick off document sessions
  @call :MESS Begin kick off document sessions
  
  @if exist %PROG_FOLDER%\DocumentSessions.go @echo DocumentSessions.go has been copied already!
  @if not exist %PROG_FOLDER%\DocumentSessions.go copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\DocumentSessions.go
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\DocumentSessions.go & goto ERR

  @call :MESS End kick off document sessions

:ENABLE
  :: Copy flag file.
  @call :MESS Begin copy flag file

  @if exist %PROG_FOLDER%\ProcessRecoveredTlogs.go @echo Flag file has been copied already!
  @if not exist %PROG_FOLDER%\ProcessRecoveredTlogs.go copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\ProcessRecoveredTlogs.go
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\ProcessRecoveredTlogs.go & goto ERR

  :: Copy PostPollingComplete Flag File
  @if exist %PROG_FOLDER%\PostPollingComplete.flg @echo Flag file has been copied already!
  @if not exist %PROG_FOLDER%\PostPollingComplete.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\PostPollingComplete.flg
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\PostPollingComplete.flg & goto ERR

  @call :MESS End copy flag file

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
  @blat %LOG_FILE% -subject "ERROR: EnableRecoveredTlogProcessing" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

