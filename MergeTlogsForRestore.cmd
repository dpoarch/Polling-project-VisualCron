::------------------------------------------------------------------------------
:: MergeTlogsForRestore.cmd
::
:: Created by: Christian Adams
:: Date: 5/19/2002
::
:: Edited by: Jeramie Shake
:: Date: 9/27/2005
::
:: Description:
::     This program will merge tlogs into merge files.
::
:: Usage: 
::     MergeTlogsForRestore
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
::     STORTRAN.exe (Corky) - Creates interstore transfer file.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\MergeTlogsForRestore.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\MergeTlogsForRestore.err

  :: Set window title and color
  @Title Merge Tlogs
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * MergeTlogsForRestore        *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Merge tlogs for restore.
  @echo.
::  @pause

:MERGE
  :: Merge tlogs for restore.


  @call :MESS Begin merge ARS tlogs for mainframe

  if exist %POLLING%\Poll\Upload\UpLogsForRestoreForRestore. del %POLLING%\Poll\Upload\UpLogsForRestore.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\UpLogsForRestore. & goto ERR

  if exist %POLLING%\Poll\TlogForRestore\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogForRestore\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogsForRestore. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogForRestore\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\TlogForRestore\Excludei\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogForRestore\Excludei\Tlog*.* %POLLING%\Poll\Upload\UpLogsForRestore. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogForRestore\Excludei\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverForRestore\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverForRestore\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogsForRestore. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverForRestore\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverForRestore\Excludei\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverForRestore\Excludei\Tlog*.* %POLLING%\Poll\Upload\UpLogsForRestore. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverForRestore\Excludei\Tlog*.* & goto ERR
  
  ::The following is used in special cases for appending tlogs to the very end of the uplogs file by request of the programming group
  ::if exist %POLLING%\Data\PollData\Jerfiles\Merge\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\PollData\Jerfiles\Merge\Tlog*.* %POLLING%\Poll\Upload\UpLogsForRestore. FORMAT=ARS
  ::@if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\PollData\Jerfiles\Merge\Tlog*.* & goto ERR

  @if not exist %POLLING%\Poll\Upload\UpLogsForRestore. @call :MESS Fatal error %POLLING%\Poll\Upload\UpLogsForRestore. does not exist & goto ERR



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
  @blat %LOG_FILE% -subject "ERROR: MergeTlogsForRestore" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
