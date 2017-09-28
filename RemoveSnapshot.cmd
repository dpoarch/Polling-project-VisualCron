::------------------------------------------------------------------------------
:: RemoveSnapshot.cmd
::
:: Created by: Jeramie Shake
:: Date: 11/6/2013
::
:: Description:
::     Removes the CommVault snapshot that was created at the end of pre-polling
::
:: Usage: 
::     RemoveSnapshot
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\RemoveSnapshot.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\RemoveSnapshot.err

  :: Set window title and color
  @Title Remove Snapshot
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * RemoveSnapshot.cmd          *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Remove Snapshot.
  @echo.
::  @pause

:WRITEFLAG
  :: Copy BeginRemoveSnapshot Flag File
  @call :MESS Begin copy BeginRemoveSnapshot flag file.

  @if exist %PROG_FOLDER%\BeginRemoveSnapshot.flg @echo Flag file has been copied already!
  @if not exist %PROG_FOLDER%\BeginRemoveSnapshot.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\BeginRemoveSnapshot.flg
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\BeginRemoveSnapshot.flg & goto ERR

  @call :MESS End copy BeginRemoveSnapshot flag file.

:RUNPROGRAM
  :: Remove Snapshot.
  @call :MESS Begin Remove Snapshot

  E:
  cd\
  cd adTempusJobs\PowershellScripts\VMware_snapshots
  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe .\SnapshotManager.ps1 -remove -VMname "SGPOLLDATA01" -snapshotName "Polling"
  @if errorlevel 1 @call :MESS Fatal error removing snapshot & goto ERR

  P:
  cd\
  cd Poll\Bin

  @call :MESS End Remove Snapshot

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
  %PROG_FOLDER%\StartBackup

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
  @blat %LOG_FILE% -subject "ERROR: RemoveSnapshot" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _

