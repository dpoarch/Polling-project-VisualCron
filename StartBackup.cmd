::------------------------------------------------------------------------------
:: StartBackup.cmd
::
:: Created by: Jeramie Shake
:: Date: 11/5/2013
::
:: Description:
::     Starts the Backup of the Polling Data Drive 
::
:: Usage: 
::     StartBackup
::
:: Dependent programs:
::
::     SGPOLLDATA01_FULL.bat - Provided by James from the NCS department
::     SGPOLLDATA01_FULL.bat_1377266757.xml - Ditto
::     SGPOLLDATA01_INCR.bat - Ditto
::     SGPOLLDATA01_INCR.bat_1377266437.xml - Ditto
::
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\StartBackup.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\StartBackup.err

  :: Set window title and color
  @Title Start Backup
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * StartBackup.cmd             *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Start Backup.
  @echo.
::  @pause

:DETERMINE_DAYOFWEEK
  ::Determine Day Of Week
  @call :MESS Begin determine day of week

  for /f %%a in ('wmic path win32_localtime get DAYOFWEEK /format:list ^| findstr "="') do (set %%a)
  @if errorlevel 1 @call :MESS Fatal error determining Day Of Week & goto ERR

  @call :MESS Day of week is %DAYOFWEEK%

  ::If it's sunday, call the full backup
  @if %DAYOFWEEK%==0 @goto FULLBACKUP

  ::otherwise, call the interim backup
  @goto INTERIMBACKUP

:FULLBACKUP
  ::Begin Full Backup
  @call :MESS Begin call for full backup
  
::@call :MESS COMMENTED OUT - WAITING FOR TEST
  @call %PROG_FOLDER%\SGPOLLDATA01_FULL.bat >> %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error running %PROG_FOLDER%\SGPOLLDATA01_FULL.bat & goto ERR

  @call :MESS End call for full backup
  @goto END

:INTERIMBACKUP
  ::Begin Interim Backup
  @call :MESS Begin call for interim backup
  
::@call :MESS COMMENTED OUT - WAITING FOR TEST
  @call %PROG_FOLDER%\SGPOLLDATA01_INCR.bat >> %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error running %PROG_FOLDER%\SGPOLLDATA01_INCR.bat & goto ERR

  @call :MESS End call for interim backup
  @goto END

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
  %PROG_FOLDER%\EnableRecoveredTlogProcessing

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
  @blat %LOG_FILE% -subject "ERROR: StartBackup" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _

