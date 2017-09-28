::------------------------------------------------------------------------------
:: ProcessRecoveredTlogs.cmd
::
:: Created by: Christian Adams
:: Date: 1/9/2003
::
:: Edited by: Jeramie Shake
:: Date: 4/5/2005
::
:: Description:
::     This program will process recovered tlogs.
::
:: Usage: 
::     ProcessRecoveredTlogs
::
:: Dependent programs:
::     7z.exe (7-Zip) - Deompresses files.
::
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     Blat.exe (open source) - Sends SMTP email.
::
::     MoveFile.exe (Christian Adams) - Moves a single file.
::
::     MoveFiles.exe (Christian Adams) - Moves multiple files.
::
::     CheckTlogs.exe (Christian Adams) - Checks tlogs for problems.
::
::     Newtoold.exe (Corky) - Converts tlogs from Trovato format to ARS format.
::
::     Awtrnslt.exe (Corky) - Translates tlogs from ARS format to AuditWorks 
::     format.
::
::     TrovtoAW (Corky) - Translates tlogs from Trovato format to AuditWorks
::     format.
::
::     Trovto~2 (corky) - Translates tlogs from Trovato format to new
::     Auditworks format
::
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\ProcessRecoveredTlogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ProcessRecoveredTlogs.err

  :: Set window title and color
  @Title Process Recovered Tlogs
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * ProcessRecoveredTlogs.cmd   *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

::  @echo.
::  @echo Process recovered tlogs.
::  @echo.
::  @pause

:MAIN
::  @call :CARTSTORES
::  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :MAKEBATCH
::  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :DECOMPRESS
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :PROCESS-ZIPPEDTLOG
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :INTERNET
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :GIFTCARD
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :CHECKT
  @if %ERROR_FLAG%==TRUE @goto ERR
  
  @call :WIZCONVERT
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :CONVERT
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :EXCLUDET
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEA
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :CHECK
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEI
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :IMPORTPAYROLL
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEP
  @if %ERROR_FLAG%==TRUE @goto ERR

::Enabled 11/27/2013 to prepare for thanksgiving Weekend
::Disabled 12/2/2013
::Enabled 11/26/2014 to prepare for thanksgiving Weekend
  @call :TLOGUPDATER
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :NEWTRANSLATE
::  @if %ERROR_FLAG%==TRUE @goto ERR

::Disabled 11/27/2013 to prepare for thanksgiving Weekend
::Re-Enabled 12/2/2013
::Disabled 11/26/2014 to prepare for thanksgiving Weekend
::  @call :TRANSLATE
::  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :TESTMOVE
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEU
  @if %ERROR_FLAG%==TRUE @goto ERR

  @goto CHECKWARN

:CARTSTORES
  :: Run ProcessRecoveredCartTlogs.cmd
  @call :MESS Begin running ProcessRecoveredCartTlogs.cmd

  call %PROG_FOLDER%\ProcessRecoveredCartTlogs.cmd

  @if errorlevel 1 @call :MESS Error running ProcessRecoveredCartTlogs.cmd & set WARNING_FLAG=TRUE

  @call :MESS End running ProcessRecoveredCartTlogs.cmd
  @goto :EOF

:MAKEBATCH
  :: Compose the subprogram that will decompress the Trovato tlogs.
  @call :MESS Begin compose subprogram to decompress Trovato tlogs

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ProcessRecoveredTlogs_run_piece1.txt %PROG_FOLDER%\ProcessRecoveredTlogs_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ProcessRecoveredTlogs_run_piece1.txt to ProcessRecoveredTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for %%E in (%POLLING%\Data\RecoverT\Zip\Tlog*.zip) do @call :BUILDCMD %%~nE || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ProcessRecoveredTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ProcessRecoveredTlogs_run.cmd /A + %PROG_FOLDER%\ProcessRecoveredTlogs_run_piece2.txt /A %PROG_FOLDER%\ProcessRecoveredTlogs_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ProcessRecoveredTlogs_run.cmd and ProcessRecoveredTlogs_run_piece2.txt to ProcessRecoveredTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram to decompress Trovato tlogs
  @goto :EOF

:BUILDCMD
  :: Build and copy in dynamic piece of subprogram.
  @set TLOG_STORE=%1
  @echo @call :DECOMPRESS %TLOG_STORE% >> %PROG_FOLDER%\ProcessRecoveredTlogs_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ProcessRecoveredTlogs_run.cmd
  @goto :EOF

:DECOMPRESS
  ::Decompress the Trovato tlogs.
  @call :MESS Begin decompress Trovato tlogs

  call %PROG_FOLDER%\ProcessRecoveredTlogs_run.cmd
  @if errorlevel 1 @call :MESS Error decompressing Trovato tlogs & set WARNING_FLAG=TRUE

  @call :MESS End decompress Trovato tlogs
  @goto :EOF

:PROCESS-ZIPPEDTLOG
  ::Process zipped tlogs
  @call :MESS Begin process zipped tlogs

  E:
  cd\
  cd adTempusJobs\PowershellScripts\Polling
  call powershell.exe .\Process-ZippedTlog.ps1 -ParamFilename "\\sgicorp.spencergifts.com\spencergifts\POS\Polling\Poll\Bin\Process-ZippedTlog_RecoverT.par"
  @if errorlevel 1 @call :MESS Fatal error calling Process-ZippedTlog.ps1 & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF  
  P:
  cd\
  cd poll\bin

  @call :MESS End process zipped tlogs
  @goto :EOF

:CHECKT
  :: Check Trovato tlogs for problems.
  @call :MESS Begin check Trovato tlogs

::  %PROG_FOLDER%\CheckTlogs.exe %POLLING%\Data\RecoverT\Tlog*.* GOODDIR=%POLLING%\Data\RecoverT\Good BADDIR=%POLLING%\Data\RecoverT\Bad FORMAT=TROVATO

  %PROG_FOLDER%\ValidateTlogsT.exe %PROG_FOLDER%\ValidateTlogsT.RecoverT.par >> %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error checking Trovato tlogs (T) & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

::  %PROG_FOLDER%\ValidateTlogs.exe PARFILE=%PROG_FOLDER%\ValidateTlogs.Data.RecoverT.par
::  @if errorlevel 1 @call :MESS Fatal error checking Trovato tlogs & set ERROR_FLAG=TRUE
::  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check Trovato tlogs
  @goto :EOF

:WIZCONVERT
  :: copy tlogs to WizConvert Folder
  @call :MESS Begin copy Trovato tlogs for Wizmail converting
  if exist %POLLING%\Data\RecoverT\Good\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Data\RecoverT\Good\Tlog*.* %POLLING%\Poll\WizConvert\ToSMTP TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Data\RecoverT\Good\Tlog*.* to %POLLING%\Poll\WizConvert\ToSMTP & set WARNING_FLAG=TRUE
  if exist %POLLING%\Data\RecoverT\GoodExclude\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Data\RecoverT\GoodExclude\Tlog*.* %POLLING%\Poll\WizConvert\ToSMTP TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Data\RecoverT\GoodExclude\Tlog*.* to %POLLING%\Poll\WizConvert\ToSMTP & set WARNING_FLAG=TRUE

  @call :MESS End copy for Wizmail converting
  @goto :EOF

:CONVERT
  :: Convert Trovato tlogs to ARS format.
  @call :MESS Begin convert Trovato tlogs for ARS format
  @call :MESS This has been turned off. The tlogs will simply be moved to the Converted folder
  ::change made on 11/09/2010

  :: See \Poll\AuditWorks\Convert\Recover\newtoold.dat for outputpaths
  ::cd \Poll\AuditWorks\Convert\Recover
  ::%POLLING%\Poll\AuditWorks\Convert\Newtoold.exe
  ::@if errorlevel 1 @call :MESS Fatal error converting Trovato tlogs & set ERROR_FLAG=TRUE
  ::cd \Poll\Bin
  ::@if %ERROR_FLAG%==TRUE goto :EOF

  :: See \Poll\AuditWorks\Convert\RecoverExclude\newtoold.dat for outputpaths
  ::cd \Poll\AuditWorks\Convert\RecoverExclude
  ::%POLLING%\Poll\AuditWorks\Convert\Newtoold.exe
  ::@if errorlevel 1 @call :MESS Fatal error converting Trovato tlogs & set ERROR_FLAG=TRUE
  ::cd \Poll\Bin
  ::@if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\Good\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\Good\Tlog*.* %POLLING%\Data\RecoverT\Good\Converted
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\RecoverT\Good\Tlog*.* to %POLLING%\Data\RecoverT\Good\Converted & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\GoodExclude\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\GoodExclude\Tlog*.* %POLLING%\Data\RecoverT\GoodExclude\Converted
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\RecoverT\GoodExclude\Tlog*.* to %POLLING%\Data\RecoverT\GoodExclude\Converted & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  ::*************************************************************************
  ::UNCOMMENT THIS PAUSE TO STOP PROCESSING BEFORE TLOG IS SENT TO AUDITWORKS
  ::pause
  ::*************************************************************************

  @call :MESS End convert Trovato tlogs for ARS format
  @goto :EOF

:INTERNET
  :: Move Internet sales to Recover folder.
  @call :MESS Begin move Internet sales to Recover folder

  if exist \\sgicorp\spencergifts\SIRIS\SIRISFTP\InternetSales\TLOG?????.* move \\sgicorp\spencergifts\SIRIS\SIRISFTP\InternetSales\TLOG?????.* %POLLING%\Data\Recover
  @if errorlevel 1 @call :MESS Error moving Internet sales to Recover folder & set WARNING_FLAG=TRUE

  @call :MESS End move Internet sales to Recover folder
  @goto :EOF

:GIFTCARD
  :: Move Gift Card adjustments to Recover folder.
  ::@call :MESS Begin move Gift Card adjustments to Recover folder

  ::if exist \\SGAW\SYBWORK\GIFTCARD\TLOGS\TLOG?????.* move \\SGAW\SYBWORK\GIFTCARD\TLOGS\TLOG?????.* %POLLING%\Data\RecoverT
  ::@if errorlevel 1 @call :MESS Error moving Internet sales to RecoverT folder & set WARNING_FLAG=TRUE

  ::@call :MESS End move Gift Card adjustments to Recover folder
  ::@goto :EOF

:EXCLUDET
  :: Exclude tlogs to use Dave's Translate instead of Corky's - No processing by the mainframe.
  @call :MESS Begin exclude tlogs to use Dave's Translate instead of Corky's

  @call %PROG_FOLDER%\ExcludeTlogst_run.cmd %POLLING%\Data\Recover %POLLING%\Data\Recover\Excludet %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogst_run.cmd %POLLING%\Data\RecoverT\Good\Converted %POLLING%\Data\RecoverT\Excludet %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogst_run.cmd %POLLING%\Data\RecoverT\GoodExclude\Converted %POLLING%\Data\RecoverT\Excludet %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs to use Dave's Translate instead of Corky's
  @goto :EOF

:EXCLUDEA
  :: Exclude tlogs from all processing.
  @call :MESS Begin exclude tlogs from all processing

  @call %PROG_FOLDER%\ExcludeTlogsa_run.cmd %POLLING%\Data\Recover %POLLING%\Data\Recover\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsa_run.cmd %POLLING%\Data\RecoverT\Good\Converted %POLLING%\Data\RecoverT\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsa_run.cmd %POLLING%\Data\RecoverT\GoodExclude\Converted %POLLING%\Data\RecoverT\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing
  @goto :EOF

:CHECK
  :: Check ARS tlogs for problems.
  @call :MESS Begin check ARS tlogs

::  %PROG_FOLDER%\CheckTlogs.exe %POLLING%\Data\Recover\Tlog*.* GOODDIR=%POLLING%\Data\Recover\Good BADDIR=%POLLING%\Data\Recover\Bad FORMAT=ARS
  %PROG_FOLDER%\ValidateTlogs.exe PARFILE=%PROG_FOLDER%\ValidateTlogs.Data.Recover.par
  @if errorlevel 1 @call :MESS Fatal error checking ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check ARS tlogs
  @goto :EOF

:EXCLUDEI
  :: Exclude tlogs from internal (local) processing.
  @call :MESS Begin exclude tlogs from internal (local) processing

  @call %PROG_FOLDER%\ExcludeTlogsi_run.cmd %POLLING%\Data\Recover\Good %POLLING%\Data\Recover\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsi_run.cmd %POLLING%\Data\RecoverT\Good\Converted %POLLING%\Data\RecoverT\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsi_run.cmd %POLLING%\Data\RecoverT\GoodExclude\Converted %POLLING%\Data\RecoverT\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from internal (local) processing
  @goto :EOF

:IMPORTPAYROLL
  :: Import Payroll Records from tlogs
  @call :MESS Begin import payroll records from tlogs

  ::If a merged file already exists, move it to the errors folder
  if exist %POLLING%\Data\RecoverT\PayrollImport\merged. %PROG_FOLDER%\MoveFile.exe %POLLING%\Data\RecoverT\PayrollImport\merged %POLLING%\Data\RecoverT\PayrollImport\Errors TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\RecoverT\PayrollImport\merged. to %POLLING%\Data\RecoverT\PayrollImport\Errors & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  ::Created merged tlog file
  if exist %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %POLLING%\Data\RecoverT\PayrollImport\merged. FORMAT=TROVATO
  @if errorlevel 1 @call :MESS Fatal error merging %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* to %POLLING%\Data\RecoverT\PayrollImport\merged. & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  ::Call TlogImporter  
  if exist %POLLING%\Data\RecoverT\PayrollImport\merged. CALL C:\PollingApps\PayrollImporter\PayrollImporter.exe %POLLING%\Data\RecoverT\PayrollImport\merged
  @if errorlevel 1 @call :MESS Fatal error executing C:\PollingApps\PayrollImporter\PayrollImporter.exe for %POLLING%\Data\RecoverT\PayrollImport\merged & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  ::Backup the merged file
  if exist %POLLING%\Data\RecoverT\PayrollImport\merged. %PROG_FOLDER%\MoveFile.exe  %POLLING%\Data\RecoverT\PayrollImport\merged %POLLING%\Data\RecoverT\PayrollImport\Imported TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\RecoverT\PayrollImport\merged. to %POLLING%\Data\RecoverT\PayrollImport\Imported & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End import payroll records from tlogs
  @goto :EOF

:EXCLUDEP
  :: Exclude tlogs from all processing except payroll processing.
  @call :MESS Begin exclude tlogs from all processing except payroll processing.

  @call %PROG_FOLDER%\ExcludeTlogsp_run.cmd %POLLING%\Data\Recover\Good %POLLING%\Data\Recover\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsp_run.cmd %POLLING%\Data\RecoverT\Good\Converted %POLLING%\Data\RecoverT\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsp_run.cmd %POLLING%\Data\RecoverT\GoodExclude\Converted %POLLING%\Data\RecoverT\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing except payroll processing.
  @goto :EOF

:TLOGUPDATER
  :: Move tlogs to be picked up by the TlogUpdater
  @call :MESS Begin call TlogUpdater

  if exist %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %POLLING%\Data\RecoverT\Good\ForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs for the TlogUpdater & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\Good\ForTlogUpdater\Tlog*.* E:\adTempusJobs\TlogUpdater\CON_TlogUpdater.exe %POLLING%\Data\RecoverT\Good\ForTlogUpdater %POLLING%\Data\RecoverT\Good\Translated %POLLING%\Data\RecoverT\Good\BackupForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error in TlogUpdater & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %POLLING%\Data\RecoverT\GoodExclude\ForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs (consignment) for the TlogUpdater & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\GoodExclude\ForTlogUpdater\Tlog*.* E:\adTempusJobs\TlogUpdater\CON_TlogUpdater.exe %POLLING%\Data\RecoverT\GoodExclude\ForTlogUpdater %POLLING%\Data\RecoverT\GoodExclude\Translated %POLLING%\Data\RecoverT\GoodExclude\BackupForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error in TlogUpdater (consignment) & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF
  
  @call :MESS End call TlogUpdater

:NEWTRANSLATE
  ::Begin Dave's Translate
  ::@call :MESS Begin Dave's Translate
  ::
  ::if exist %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* copy %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %POLLING%\Data\RecoverT\TranslateTest /Y
  ::@if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* to %POLLING%\Data\RecoverT\TranslateTest & set ERROR_FLAG=TRUE
  ::@if %ERROR_FLAG%==TRUE goto :EOF
  ::
  ::if exist %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* copy %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %POLLING%\Data\RecoverT\TranslateTest /Y
  ::@if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* to %POLLING%\Data\RecoverT\TranslateTest & set ERROR_FLAG=TRUE
  ::@if %ERROR_FLAG%==TRUE goto :EOF
  ::
  ::C:\PollingApps\Translate\Translate.exe SpencerGifts.Translate.Plugin.TLog.Daily
  ::@if errorlevel 1 @call :MESS Fatal error in NEW translate & set ERROR_FLAG=TRUE
  ::@if %ERROR_FLAG%==TRUE goto :EOF
  ::
  ::@call :MESS End Dave's Translate
  ::@goto :EOF

:TRANSLATE
  :: Translate tlogs and send to AuditWorks.
  @call :MESS Begin translate tlogs and send to AuditWorks

  :: OBSOLETE
  ::    :: ARS Tlogs (Skip the translate, just move the files manually)
  ::    :: Old Translate Code
  ::    cd \Poll\AuditWorks\Translate\Recover
  ::    %POLLING%\Poll\AuditWorks\Translate\Awtrnslt.exe repoll
  ::    @if errorlevel 1 @call :MESS Fatal error translating ARS tlogs & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    if exist %POLLING%\Data\Recover\Good\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\Recover\Good\Tlog*.* %POLLING%\Data\Recover\Good\Backup
  ::    @if errorlevel 1 @call :MESS Fatal error translating ARS tlogs & set ERROR_FLAG=TRUE
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    ::Trovato Tlogs (Translate to old AuditWorks - Skip the translate, just move the files manually)
  ::    cd \Poll\AuditWorks\Translate\Recover
  ::    %POLLING%\Poll\AuditWorks\Translate\TrovtoAW.exe repoll
  ::    @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs (Old Auditworks) & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    if exist %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %POLLING%\WorkingFiles\TranslateTest\Daily_Input
  ::    @if errorlevel 1 @call :MESS Fatal error copying Trovato tlogs for translate (New Auditworks) & set ERROR_FLAG=TRUE
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    if exist %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %POLLING%\WorkingFiles\TranslateTest\Daily_Consignment_Input
  ::    @if errorlevel 1 @call :MESS Fatal error copying Trovato tlogs (consignment) for translate (New Auditworks) & set ERROR_FLAG=TRUE
  ::    @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %POLLING%\Data\RecoverT\Good\Translated
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs for translate & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %POLLING%\Data\RecoverT\GoodExclude\Translated
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs (consignment) for translate & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: OBSOLETE
  ::    :: Translate to the new AuditWorks
  ::    cd \Poll\AuditWorks\Translate\Recover_New
  ::    %POLLING%\Poll\AuditWorks\Translate\Trovto~2.exe repoll
  ::    @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs (New Auditworks) & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    :: Translate Excluded Files to the new Auditworks
  ::    cd \Poll\AuditWorks\Translate\RecoverExclude
  ::    %POLLING%\Poll\AuditWorks\Translate\Trovto~2.exe repoll
  ::    @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs (Excluded Files) & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End translate tlogs and send to AuditWorks
  @goto :EOF

:TESTMOVE
  :: Simulate tlogs being processed by the Translate.
  @call :MESS Begin simulate translate

  if exist %POLLING%\Data\Recover\Good\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\Recover\Good\Tlog*.* %POLLING%\Data\Recover\Good\Backup
  @if errorlevel 1 @call :MESS Fatal error translating ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\Good\Converted\Tlog*.* %POLLING%\Data\RecoverT\Good\Translated
  @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\Good\Translated\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\Good\Translated\Tlog*.* %POLLING%\Data\RecoverT\Good\Backup
  @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\RecoverT\GoodExclude\Converted\Tlog*.* %POLLING%\Data\RecoverT\GoodExclude\Backup
  @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End simulate translate
  @goto :EOF

:EXCLUDEU
  :: Exclude tlogs from mainframe upload.
  @call :MESS Begin exclude tlogs from mainframe upload

  @call %PROG_FOLDER%\ExcludeTlogsu_run.cmd %POLLING%\Data\Recover\Good\Backup %POLLING%\Data\Recover\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsu_run.cmd %POLLING%\Data\RecoverT\Good\Backup %POLLING%\Data\RecoverT\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsu_run.cmd %POLLING%\Data\RecoverT\GoodExclude\Backup %POLLING%\Data\RecoverT\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from mainframe upload
  @goto :EOF


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
  ::@pause

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
  @blat %LOG_FILE% -subject "ERROR: ProcessRecoveredTlogs" -to AppDevPOSPollingAlerts@spencergifts.com
  ::@pause

  :: Force an error code to be returned to the O/S.
  @ren _

