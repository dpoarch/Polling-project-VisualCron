::------------------------------------------------------------------------------
:: PurgeServerBackups.cmd
::
:: Created by: Jeramie Shake
:: Date: 6/4/2013
::
:: Description:
::     This program will purge server backups.
::
:: Usage: 
::     PurgeServerBackups
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\PurgeServerBackups.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\PurgeServerBackups.err

  :: Set window title and color
  @Title Purge Server Backups
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * PurgeServerBackups.cmd      *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Purge Server Backups.
  @echo.
::  @pause

:PURGE
  :: Purge old backups.
  @call :MESS Begin purge old backups

  :: Delete backups over 30 days old on production polling server.
  ::P: points to %POLLING%, but only in the AdTempus Job "Pre-Polling - Step 1"
  forfiles /p P:\Backup /s /m *.zip /d -30 /c "cmd /c del @FILE"
  @if errorlevel 1 @call :MESS Error purging 30 day old backups on production polling server & set WARNING_FLAG=TRUE

  :: Delete backups over 5 days old on production polling server.
::Added 3/7/2013
  forfiles /p P:\Backup\Trovato /s /m *.zip /d -5 /c "cmd /c del @FILE"
  @if errorlevel 1 @call :MESS Error purging 5 day old backups on production polling server & set WARNING_FLAG=TRUE

  :: Delete backups over 30 days old on backup polling server.
  ::net use x: \\SGw2KPOLL2\Backup
  ::forfiles -px:\ -s -m*.zip -d-30 -c"cmd /c del @FILE"
  ::@if errorlevel 1 @call :MESS Error purging backups on backup polling server & set WARNING_FLAG=TRUE
  ::net use x: /delete

  @call :MESS End purge old backups

:CHECKWARN
  :: Check warning flag.
  @if %WARNING_FLAG%==TRUE @goto WARN

:END
  :: Program completed successfully.
  @echo.
  @echo.
  @echo Program completed successfully!
  @echo.
  @pause

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
  @pause

  @call :MESS End Program with non-fatal errors
  @goto ERREND

:ERR
  :: Program abended due to a fatal error.
  @color FC
  @echo.
  @echo.
  @echo FATAL ERROR! Program will be terminated.
  @echo.
  @pause

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
  @blat %LOG_FILE% -subject "ERROR: PurgeServerBackups" -to AppDevPOSPollingAlerts@spencergifts.com
  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
