::------------------------------------------------------------------------------
:: MergeTlogs.cmd
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
  ::@pause

:MERGE
  :: Merge tlogs.

  @call :MESS Begin merge tlogs for internal (local) processing

  if exist %POLLING%\Poll\Upload\IpLogs. del %POLLING%\Poll\Upload\IpLogs.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\IpLogs. & goto ERR

  if exist %POLLING%\Poll\Tlog\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Tlog\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Tlog\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\Tlog\Excludeu\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Tlog\Excludeu\Tlog*.* %POLLING%\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Tlog\Excludeu\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\Tlog\Excludet\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Tlog\Excludet\Tlog*.* %POLLING%\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Tlog\Excludet\Tlog*.* & goto ERR
  if exist %POLLING%\Data\Recover\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\Recover\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\Recover\Excludeu\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Excludeu\Tlog*.* %POLLING%\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\Recover\Excludeu\Tlog*.* & goto ERR
  if exist %POLLING%\Data\Recover\Excludet\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Excludet\Tlog*.* %POLLING%\Poll\Upload\IpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\Recover\Excludet\Tlog*.* & goto ERR

::We don't care about IpLogs as of 11/10/2010
::  @if not exist %POLLING%\Poll\Upload\IpLogs. @call :MESS Fatal error %POLLING%\Poll\Upload\IpLogs. does not exist & goto ERR

  ::Make IpLogsT for use in Trovato Tlog Processing
  if exist %POLLING%\Poll\Upload\IpLogsT. del %POLLING%\Poll\Upload\IpLogsT.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\IpLogsT. & goto ERR

  if exist %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\TlogT\GoodExclude\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\GoodExclude\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\GoodExclude\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\TlogT\Excludeu\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Excludeu\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Excludeu\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\TlogT\Excludet\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Excludet\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Excludet\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\GoodExclude\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\GoodExclude\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\GoodExclude\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\Excludeu\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludeu\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Excludeu\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* & goto ERR

  @if not exist %POLLING%\Poll\Upload\IpLogsT. @call :MESS Fatal error %POLLING%\Poll\Upload\IpLogsT. does not exist & goto ERR

  @if exist %POLLING%\Poll\Upload\IpLogsT. copy %PROG_FOLDER%\Go.txt \\sgschedule\adTempusJobs\Agilence\tlog.done
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to \\sgschedule\adTempusJobs\Agilence\tlog.done & goto ERR

  ::Make IplogsP for use in payroll processing
  if exist %POLLING%\Poll\Upload\IpLogsP. del %POLLING%\Poll\Upload\IpLogsP.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\IpLogsP. & goto ERR
  
  :: Old ARS IplogsP
  ::if exist %POLLING%\Poll\Upload\IpLogs %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Upload\IpLogs %POLLING%\Poll\Upload\IpLogsP. FORMAT=ARS
  ::@if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Upload\IpLogs & goto ERR
  ::if exist %POLLING%\Poll\Tlog\Excludep\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Tlog\Excludep\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=ARS
  ::@if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Tlog\Excludep\Tlog*.* & goto ERR
  ::if exist %POLLING%\Data\Recover\Excludep\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Excludep\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=ARS
  ::@if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\Recover\Excludep\Tlog*.* & goto ERR

  if exist %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Poll\TlogT\Excludeu\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Excludeu\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Excludeu\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Poll\TlogT\Excludet\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Excludet\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Excludet\Backup\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Data\RecoverT\Excludeu\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludeu\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Excludeu\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Poll\TlogT\Excludep\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Excludep\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Excludep\Tlog*.* into IpLogsP & goto ERR
  if exist %POLLING%\Data\RecoverT\Excludep\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludep\Tlog*.* %POLLING%\Poll\Upload\IpLogsP. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Excludep\Tlog*.* into IpLogsP & goto ERR

  @if not exist %POLLING%\Poll\Upload\IpLogsP. @call :MESS Fatal error %POLLING%\Poll\Upload\IpLogsP. does not exist & goto ERR

  @call :MESS End merge tlogs for internal (local) processing


  @call :MESS Begin merge ARS tlogs for mainframe

  if exist %POLLING%\Poll\Upload\UpLogs. del %POLLING%\Poll\Upload\UpLogs.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\UpLogs. & goto ERR

  if exist %POLLING%\Poll\Tlog\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Tlog\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Tlog\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\Tlog\Excludei\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\Tlog\Excludei\Tlog*.* %POLLING%\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\Tlog\Excludei\Tlog*.* & goto ERR
  if exist %POLLING%\Data\Recover\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\Recover\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\Recover\Excludei\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Excludei\Tlog*.* %POLLING%\Poll\Upload\UpLogs. FORMAT=ARS
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\Recover\Excludei\Tlog*.* & goto ERR
  
  ::The following is used in special cases for appending tlogs to the very end of the uplogs file by request of the programming group
  ::if exist %POLLING%\Data\PollData\Jerfiles\Merge\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\PollData\Jerfiles\Merge\Tlog*.* %POLLING%\Poll\Upload\UpLogs. FORMAT=ARS
  ::@if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\PollData\Jerfiles\Merge\Tlog*.* & goto ERR

:: We don't care about uplogs as of 11/10/2010
::  @if not exist %POLLING%\Poll\Upload\UpLogs. @call :MESS Fatal error %POLLING%\Poll\Upload\UpLogs. does not exist & goto ERR

  @call :MESS Begin merge Trovato tlogs for mainframe

  if exist %POLLING%\Poll\Upload\UpLogsT. del %POLLING%\Poll\Upload\UpLogsT.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\UpLogsT. & goto ERR

  if exist %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\TlogT\GoodExclude\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\GoodExclude\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\GoodExclude\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Poll\TlogT\Excludei\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Poll\TlogT\Excludei\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Poll\TlogT\Excludei\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\GoodExclude\Backup\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\GoodExclude\Backup\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\GoodExclude\Backup\Tlog*.* & goto ERR
  if exist %POLLING%\Data\RecoverT\Excludei\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludei\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Excludei\Tlog*.* & goto ERR
  
  ::The following is used in special cases for appending tlogs to the very end of the uplogs file by request of the programming group
  ::if exist %POLLING%\Data\PollData\Jerfiles\MergeT\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\PollData\Jerfiles\MergeT\Tlog*.* %POLLING%\Poll\Upload\UpLogsT. FORMAT=TROVATO
  ::@if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\PollData\Jerfiles\MergeT\Tlog*.* & goto ERR

  @if not exist %POLLING%\Poll\Upload\UpLogsT. @call :MESS Fatal error %POLLING%\Poll\Upload\UpLogsT. does not exist & goto ERR

:UPLOGSTMASK

  @call :MESS Begin create masked Trovato tlogs for mainframe

  if exist %POLLING%\Poll\Upload\UpLogsTMask. del %POLLING%\Poll\Upload\UpLogsTMask.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\UpLogsTMask. & goto ERR
  c:
  cd\
  cd pollingapps\translate
  C:\PollingApps\Translate\Translate.exe SpencerGifts.Translate.Plugin.TLog.AS400 bypassrunningcheck
  @if errorlevel 1 @call :MESS Fatal error translating %POLLING%\Poll\Upload\UplogsT to %POLLING%\Poll\Upload\UplogsTMask & goto ERR


  :: Wait 10 seconds
  @call :MESS Wait 10 seconds for the file to arrive...
  %PROG_FOLDER%\Sleep 10

  @if not exist %POLLING%\Poll\Upload\UpLogsTMask. @call :MESS Fatal error %POLLING%\Poll\Upload\UpLogsTMask. does not exist & goto ERR
  @call :MESS End create masked Trovato tlogs for mainframe

:INTERSTORE
  ::Create Interstore Transfer File
  if exist %POLLING%\Poll\Upload\interstore.txt del %POLLING%\Poll\Upload\interstore.txt
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\interstore.txt & goto ERR

  %POLLING%\Poll\Interstore\STORTRAN.exe %POLLING%\Poll\Upload\IpLogsT %POLLING%\Poll\Upload\interstore.txt
  @if not exist %POLLING%\Poll\Upload\interstore.txt @call :MESS Fatal error %POLLING%\Poll\Upload\interstore.txt does not exist & goto ERR

  ::Temporarily copy interstore.txt file
  ::copyfiles %POLLING%\poll\upload\interstore.txt %POLLING%\data\polldata\interstore timestamp=true
  ::@if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\Upload\interstore.txt to %POLLING%\data\polldata\interstore\ & goto ERR

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
::  @pause

  @call :MESS End Program

  :: Continue with the next Batch File
  %PROG_FOLDER%\FTPUplogs

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
  @blat %LOG_FILE% -subject "ERROR: MergeTlogs" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
