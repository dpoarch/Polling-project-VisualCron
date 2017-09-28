::------------------------------------------------------------------------------
:: CreateSnapshot.cmd
::
:: Created by: Jeramie Shake
:: Date: 11/5/2013
::
:: Description:
::     Creates a CommVault snapshot that will preserve the pre-polling setup 
::     in case the file system gets corrupted during polling
::
:: Usage: 
::     CreateSnapshot
::
:: Dependent programs:
::
::     SnapshotManager.ps1 - Provided by James Chiu of the NCS department
::         Can be found at \\sgschedule\e$\adtempusjobs\powershellscripts\vmware_snapshots
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\CreateSnapshot.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CreateSnapshot.err

  :: Set window title and color
  @Title Create Snapshot
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * CreateSnapshot.cmd          *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Create Snapshot.
  @echo.
::  @pause

:RUNPROGRAM
  :: Create Snapshot.
  @call :MESS Begin Create Snapshot

::@call :MESS COMMENTED OUT - WAITING FOR TEST
  E:
  cd\
  cd adTempusJobs\PowershellScripts\VMware_snapshots
  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe .\SnapshotManager.ps1 -create -VMname "SGPOLLDATA01" -snapshotName "Polling"
  @if errorlevel 1 @call :MESS Fatal error creating snapshot & goto ERR

  P:
  cd\
  cd Poll\Bin

  @call :MESS End Create Snapshot

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
  %PROG_FOLDER%\SetUpPollingSessions

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
  @blat %LOG_FILE% -subject "ERROR: CreateSnapshot" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _

