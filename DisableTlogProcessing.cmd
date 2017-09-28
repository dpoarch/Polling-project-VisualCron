::------------------------------------------------------------------------------
:: DisableTlogProcessing.cmd
::
:: Created by: Christian Adams
:: Date: 8/19/2002
::
:: Description:
::     This program will delete a flag file to prevent Arcana Scheduler from
::     executing the job Process Tlogs (which executes the batch program 
::     ProcessTlogs.cmd).
::
:: Usage: 
::     DisableTlogProcessing
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\DisableTlogProcessing.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\DisableTlogProcessing.err

  :: Set window title and color
  @Title Disable Tlog Processing
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * DisableTlogProcessing.cmd   *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Delete flag file to disable processing of tlogs.
  @echo.
::  @pause

:DISABLE
  :: Delete flag file.
  @call :MESS Begin delete flag file

  @if not exist %PROG_FOLDER%\ProcessTlogs.go @echo Flag file has been deleted already!
  @if exist %PROG_FOLDER%\ProcessTlogs.go del %PROG_FOLDER%\ProcessTlogs.go
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\ProcessTlogs.go & goto ERR

  ::Move held closing store tlogs to RecoverT for processing
  if exist %POLLING%\Data\ClosingStoreTlogs\Hold\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\ClosingStoreTlogs\Hold\Tlog*.* %POLLING%\Data\RecoverT
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\ClosingStoreTlogs\Hold\Tlog*.* to %POLLING%\Data\RecoverT & goto ERR

  call %PROG_FOLDER%\ProcessTlogs
::  call %PROG_FOLDER%\ProcessRecoveredTlogs

  @call :MESS End delete flag file

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

  :: Continue with the next Batch File
  %PROG_FOLDER%\ProcessTlogsFinal

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
  @blat %LOG_FILE% -subject "ERROR: DisableTlogProcessing" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

