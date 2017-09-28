::------------------------------------------------------------------------------
:: GenAllBackupArchive.cmd
::
:: Created by: Jeramie Shake
:: Date: 11/13/2013
::
:: Description:
::     This program will archive genall data.
::
:: Usage: 
::     GenAllBackupArchive
::
:: Dependent programs:
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\GenAllBackupArchive.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\GenAllBackupArchive.err

  :: Set window title and color
  @Title Genall Backup Archive
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * GenAllBackupArchive.cmd     *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Genall Backup Archive.
  @echo.
::  @pause

:SETARCHIVEFOLDERNAME
  @call :MESS Begin setting archive folder name

  For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
  For /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b%%c)
  For /f "tokens=1-2 delims=/." %%a in ("%mytime%") do (set mytime=%%a%%b)
  set ARCHIVEFOLDERNAME=%mydate%_%mytime%

  @call :MESS End setting archive folder name

:Archive
  @call :MESS Begin archive %POLLING%\Genall\*.*

  md %POLLINGARCHIVE%\Genall\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\Genall\%ARCHIVEFOLDERNAME% & goto ERR
  copy %POLLING%\Genall\*.* %POLLINGARCHIVE%\Genall\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Genall\*.* to %POLLINGARCHIVE%\Genall\%ARCHIVEFOLDERNAME% & goto ERR

  @call :MESS End archive %POLLING%\Genall\*.*

:DelFlags
  @call :MESS Begin delete flags

  if exist %PROG_FOLDER%\GenAllBackup.flg del %PROG_FOLDER%\GenAllBackup.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\GenAllBackup.flg & goto ERR

  if exist %PROG_FOLDER%\GenAllBackupComplete.flg del %PROG_FOLDER%\GenAllBackupComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\GenAllBackupComplete.flg & goto ERR

  @call :MESS End delete flags

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
  @blat %LOG_FILE% -subject "ERROR: GenAllBackupZip" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
