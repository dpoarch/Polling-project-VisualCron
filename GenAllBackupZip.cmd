::------------------------------------------------------------------------------
:: GenAllBackupZip.cmd
::
:: Created by: Jeramie Shake
:: Date: 12/30/2010
::
:: Description:
::     This program will backup genall data.
::
:: Usage: 
::     GenAllBackupZip
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\GenAllBackupZip.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\GenAllBackupZip.err

  :: Set window title and color
  @Title Backup Server Data
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * GenAllBackupZip.cmd         *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Backup server data.
  @echo.
::  @pause


  :: Backup RemoteWare configuration data.
  @call :MESS Begin backup files in %POLLING%\Gennall

  if exist C:\Temp\Genall.zip del %POLLING%\Temp\Genall.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Genall.zip & goto ERR

  "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Genall.zip %POLLING%\Genall
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Genall\*.* & goto ERR

  if exist C:\Temp\Genall.zip %PROG_FOLDER%\MoveFiles.exe C:\Temp\Genall.zip %POLLING%\Backup\Genall TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Genall.zip & goto ERR

  if exist %PROG_FOLDER%\GenAllBackup.flg del %PROG_FOLDER%\GenAllBackup.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\GenAllBackup.flg & goto ERR

  if exist %PROG_FOLDER%\GenAllBackupComplete.flg del %PROG_FOLDER%\GenAllBackupComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\GenAllBackupComplete.flg & goto ERR

  @call :MESS End backup files in %POLLING%\Gennall

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
