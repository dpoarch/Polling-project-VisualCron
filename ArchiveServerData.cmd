::------------------------------------------------------------------------------
:: ArchiveServerData.cmd
::
:: Created by: Jeramie Shake
:: Date: 11/6/2013
::
:: Description:
::     This program will archive server data.
::
:: Usage: 
::     ArchiveServerData
::
:: Dependent programs:
::     MoveFiles.exe (Christian Adams) - Moves one or more files.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\ArchiveServerData.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ArchiveServerData.err

  :: Set window title and color
  @Title Archive Server Data
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * ArchiveServerData.cmd       *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Archive server data.
  @echo.
::  @pause

:SETARCHIVEFOLDERNAME
  @call :MESS Begin setting archive folder name

  For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
  For /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b%%c)
  For /f "tokens=1-2 delims=/." %%a in ("%mytime%") do (set mytime=%%a%%b)

  SET mytime2=%mytime: =0%

  set ARCHIVEFOLDERNAME=%mydate%_%mytime2%

  @call :MESS End setting archive folder name

:HR
  @call :MESS Begin archive %POLLING%\Poll\Interface\HR\*.*

  md %POLLINGARCHIVE%\HR\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\HR\%ARCHIVEFOLDERNAME% & goto ERR
  C:\PollingApps\MoveFiles.exe %POLLING%\Poll\Interface\HR\*.* %POLLINGARCHIVE%\HR\%ARCHIVEFOLDERNAME% TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Poll\Interface\HR\*.* to %POLLINGARCHIVE%\HR\%ARCHIVEFOLDERNAME% & goto ERR

  @call :MESS End archive %POLLING%\Poll\Interface\HR\*.*

:NORECYCLET
  @call :MESS Begin archive %POLLING%\Data\NoRecycleT\Zip\*.*

  if exist %POLLING%\Data\NoRecycleT\Zip\*.zip C:\PollingApps\MoveFiles.exe %POLLING%\Data\NoRecycleT\Zip\*.zip %POLLINGARCHIVE%\NoRecycleT TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\NoRecycleT\Zip\*.zip to %POLLINGARCHIVE%\NoRecycleT & goto ERR

  @call :MESS End archive %POLLING%\Data\NoRecycleT\Zip\*.*

:GENALL
  :: Generate RemoteWare configuration data.
  @call :MESS Begin generate RemoteWare configuration data

  if exist %POLLING%\Genall\*.* del %POLLING%\Genall\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Genall\*.* & goto ERR

  if exist %PROG_FOLDER%\GenAllBackupComplete.flg del %PROG_FOLDER%\GenAllBackupComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\GenAllBackupComplete.flg & goto ERR

  ::Write flag so the ExecuteGenAll windows service on the polling server will run the genall program
  copy %PROG_FOLDER%\maildone.txt %PROG_FOLDER%\GenAllBackup.flg
  @if errorlevel 1 @call :MESS Fatal error creating %PROG_FOLDER%\GenAllBackup.flg & goto ERR

  @call :MESS End generate RemoteWare configuration data

:WRITEFLAG
  :: Set flag to show that Pre-Polling Step 1 is complete.
  @call :MESS Begin set flag to show that Pre-Polling Step 1 is complete

  :: Copy flag file.
  @if exist %PROG_FOLDER%\PrePolling1.flg @echo Flag file has been copied already!
  if not exist %PROG_FOLDER%\PrePolling1.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\PrePolling1.flg
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\PrePolling1.flg & goto ERR

  @call :MESS End set flag to show that Pre-Polling Step 1 is complete

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
  @blat %LOG_FILE% -subject "ERROR: ArchiveServerData" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
