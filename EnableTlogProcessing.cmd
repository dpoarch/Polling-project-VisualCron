::------------------------------------------------------------------------------
:: EnableTlogProcessing.cmd
::
:: Created by: Christian Adams
:: Date: 8/19/2002
::
:: Description:
::     This program will copy a flag file to allow Arcana Scheduler to execute
::     the job Process Tlogs (which executes the batch program ProcessTlogs.cmd).
::
:: Usage: 
::     EnableTlogProcessing
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\EnableTlogProcessing.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\EnableTlogProcessing.err

  :: Set window title and color
  @Title Enable Tlog Processing
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * EnableTlogProcessing.cmd    *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Copy flag file to enable processing of tlogs.
  @echo.
::  @pause

:BACKUPCRITICAL
  :: Copy some critical files to the polling servers
  :: This is just until we get the snapshot solution in place
  @call :MESS Begin backing up critical files

  copy %POLLING%\Poll\OutboundT\*.* \\sgpoll02\TlogCache\Mail
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\OutboundT\*.* to \\sgpoll02\TlogCache\Mail & goto ERR
  copy %POLLING%\Poll\OutboundT\*.* \\sgpoll03\TlogCache\Mail
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\OutboundT\*.* to \\sgpoll03\TlogCache\Mail & goto ERR
  copy %POLLING%\Poll\AuditWorks\Translate\exclude.dat \\sgpoll02\TlogCache\Other
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\AuditWorks\Translate\exclude.dat to \\sgpoll02\TlogCache\Other & goto ERR
  copy %POLLING%\Poll\AuditWorks\Translate\exclude.dat \\sgpoll03\TlogCache\Other
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\AuditWorks\Translate\exclude.dat to \\sgpoll03\TlogCache\Other & goto ERR
  copy %POLLING%\Poll\Bin\exclude.txt \\sgpoll02\TlogCache\Other
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\Bin\exclude.txt to \\sgpoll02\TlogCache\Other & goto ERR
  copy %POLLING%\Poll\Bin\exclude.txt \\sgpoll03\TlogCache\Other
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\Bin\exclude.txt to \\sgpoll03\TlogCache\Other & goto ERR

:ENABLE
  :: Copy flag file.
  @call :MESS Begin copy flag file

  @if exist %PROG_FOLDER%\ProcessTlogs.go @echo Flag file has been copied already!
  @if not exist %PROG_FOLDER%\ProcessTlogs.go copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\ProcessTlogs.go
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\ProcessTlogs.go & goto ERR

  @call :MESS End copy flag file

:WRITEFLAG
  :: Set flag to show that Pre-Polling Step 2 is complete.
  @call :MESS Begin set flag to show that Pre-Polling Step 2 is complete

  :: Copy flag file.
  @if exist %PROG_FOLDER%\PrePolling2.flg @echo Flag file has been copied already!
  if not exist %PROG_FOLDER%\PrePolling2.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\PrePolling2.flg
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\PrePolling2.flg & goto ERR

  @call :MESS End set flag to show that Pre-Polling Step 2 is complete

:SENDEMAIL
  :: Send email to POS telling them that Pre-Polling is complete.
::This is now done by the SetUpPollingSessions program
::  @call :MESS Begin Send email to POS telling them that Pre-Polling is complete
 
::  blat %PROG_FOLDER%\PrePollingComplete.txt -subject "Pre Polling Completed Successfully" -to AppDevPOSPollingMessages@spencergifts.com
::  blat %PROG_FOLDER%\PrePollingComplete.txt -subject "Pre Polling Completed Successfully" -to AllSgiSupportCenter@spencergifts.com

::  @call :MESS End Send email to POS telling them that Pre-Polling is complete

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
  %PROG_FOLDER%\CreateSnapshot

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
  @blat %LOG_FILE% -subject "ERROR: EnableTlogProcessing" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _

