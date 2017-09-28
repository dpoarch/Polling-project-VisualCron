::------------------------------------------------------------------------------
:: MergeTlogs.cmd
::
:: Created by: Christian Adams
:: Date: 5/19/2002
::
:: Description:
::     This program will merge tlogs into merge files.
::
:: Usage: 
::     MergeTlogs
::
:: Dependent programs:
::     MergeTlogs.exe (Christian Adams) - Merges tlogs into single file.
::
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
  @set PROG_FOLDER=E:\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\MergeTlogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\MergeTlogs.err

  :: Set window title and color
  @Title Merge Tlogs
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * MergeTlogs                  *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Merge tlogs.
  @echo.
  @pause

:MERGE
  :: Merge tlogs.

  @call :MESS Begin merge tlogs for internal (local) processing

  if exist E:\Poll\Upload\IpLogs. del E:\Poll\Upload\IpLogs.
  @if errorlevel 1 @call :MESS Fatal error deleting E:\Poll\Upload\IpLogs. & goto ERR

  if exist E:\Poll\Tlog\Good\Backup\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Poll\Tlog\Good\Backup\Tlog*.* E:\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Poll\Tlog\Good\Backup\Tlog*.* & goto ERR
  if exist E:\Poll\Tlog\Excludeu\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Poll\Tlog\Excludeu\Tlog*.* E:\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Poll\Tlog\Excludeu\Tlog*.* & goto ERR
  if exist E:\Data\Recover\Good\Backup\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Good\Backup\Tlog*.* E:\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Data\Recover\Good\Backup\Tlog*.* & goto ERR
  if exist E:\Data\Recover\Excludeu\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Excludeu\Tlog*.* E:\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Data\Recover\Excludeu\Tlog*.* & goto ERR

  @if not exist E:\Poll\Upload\IpLogs. @call :MESS Fatal error E:\Poll\Upload\IpLogs. does not exist & goto ERR

  if exist E:\Poll\TlogT\Good\Backup\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Poll\TlogT\Good\Backup\Tlog*.* E:\Poll\Upload\IpLogsT. FORMAT=TROVATO
::  @if errorlevel 1 @call :MESS Fatal error merging E:\Poll\TlogT\Good\Backup\Tlog*.* & goto ERR
  if exist E:\Data\RecoverT\Good\Backup\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Data\RecoverT\Good\Backup\Tlog*.* E:\Poll\Upload\IpLogsT. FORMAT=TROVATO
::  @if errorlevel 1 @call :MESS Fatal error merging E:\Data\RecoverT\Good\Backup\Tlog*.* & goto ERR

  @call :MESS End merge tlogs for internal (local) processing


  @call :MESS Begin merge tlogs for mainframe

  if exist E:\Poll\Upload\UpLogs. del E:\Poll\Upload\UpLogs.
  @if errorlevel 1 @call :MESS Fatal error deleting E:\Poll\Upload\UpLogs. & goto ERR

  if exist E:\Poll\Tlog\Good\Backup\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Poll\Tlog\Good\Backup\Tlog*.* E:\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Poll\Tlog\Good\Backup\Tlog*.* & goto ERR
  if exist E:\Poll\Tlog\Excludei\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Poll\Tlog\Excludei\Tlog*.* E:\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Poll\Tlog\Excludei\Tlog*.* & goto ERR
  if exist E:\Data\Recover\Good\Backup\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Good\Backup\Tlog*.* E:\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Data\Recover\Good\Backup\Tlog*.* & goto ERR
  if exist E:\Data\Recover\Excludei\Tlog*.* E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Excludei\Tlog*.* E:\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging E:\Data\Recover\Excludei\Tlog*.* & goto ERR

  @if not exist E:\Poll\Upload\UpLogs. @call :MESS Fatal error E:\Poll\Upload\UpLogs. does not exist & goto ERR

  @call :MESS End merge tlogs for mainframe

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
  @blat %LOG_FILE% -subject "ERROR: MergeTlogs" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
