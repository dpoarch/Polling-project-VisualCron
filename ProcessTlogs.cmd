::------------------------------------------------------------------------------
:: ProcessTlogs.cmd
::
:: Created by: Christian Adams
:: Date: 1/8/2003
::
:: Edited by: Jeramie Shake
:: Date: 4/5/2005
::
:: Description:
::     This program will process tlogs.
::
:: Usage: 
::     ProcessTlogs
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\ProcessTlogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ProcessTlogs.err

  :: Set window title and color
  @Title Process Tlogs
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * ProcessTlogs.cmd            *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

::  @echo.
::  @echo Process recovered tlogs.
::  @echo.
::  @pause

:MAIN
  @call :ADDFLAG
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :CARTSTORES
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATCH
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :DECOMPRESS
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :COPYTOTEST
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
::R-enabled 12/2/2013
::Disabled 11/26/2014 to prepare for thanksgiving Weekend
::  @call :TRANSLATE
::  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :TESTMOVE
::  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEU
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :DELETEFLAG
  @if %ERROR_FLAG%==TRUE @goto ERR

  @goto CHECKWARN

:ADDFLAG
  :: Add ProcessTlogs.flg file
  @call :MESS Begin adding ProcessTlogs.flg

  @if not exist %PROG_FOLDER%\ProcessTlogs.flg copy %PROG_FOLDER%\maildone.txt %PROG_FOLDER%\ProcessTlogs.flg
  @if errorlevel 1 @call :MESS Fatal error adding %PROG_FOLDER%\ProcessTlogs.flg & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End adding ProcessTlogs.flg
  @goto :EOF

:CARTSTORES
  :: Run ProcessCartTlogs.cmd
  @call :MESS Begin running ProcessCartTlogs.cmd

  call %PROG_FOLDER%\ProcessCartTlogs.cmd

  @if errorlevel 1 @call :MESS Error running ProcessCartTlogs.cmd & set WARNING_FLAG=TRUE

  @call :MESS End running ProcessCartTlogs.cmd
  @goto :EOF

:MAKEBATCH
  :: Compose the subprogram that will decompress the Trovato tlogs.
  @call :MESS Begin compose subprogram to decompress Trovato tlogs

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ProcessTlogs_run_piece1.txt %PROG_FOLDER%\ProcessTlogs_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ProcessTlogs_run_piece1.txt to ProcessTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for %%E in (%POLLING%\Poll\TlogT\Polled\Zip\Tlog*.zip) do @call :BUILDCMD %%~nE || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ProcessTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ProcessTlogs_run.cmd /A + %PROG_FOLDER%\ProcessTlogs_run_piece2.txt /A %PROG_FOLDER%\ProcessTlogs_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ProcessTlogs_run.cmd and ProcessTlogs_run_piece2.txt to ProcessTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram to decompress Trovato tlogs
  @goto :EOF

:BUILDCMD
  :: Build and copy in dynamic piece of subprogram.
  @set TLOG_STORE=%1
  @echo @call :DECOMPRESS %TLOG_STORE% >> %PROG_FOLDER%\ProcessTlogs_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ProcessTlogs_run.cmd
  @goto :EOF

:DECOMPRESS
  ::Decompress the Trovato tlogs.
  @call :MESS Begin decompress Trovato tlogs

  call %PROG_FOLDER%\ProcessTlogs_run.cmd
  @if errorlevel 1 @call :MESS Error decompressing Trovato tlogs & set WARNING_FLAG=TRUE

  @call :MESS End decompress Trovato tlogs
  @goto :EOF

:COPYTOTEST
  ::Copy the Trovato tlogs to test.
  @call :MESS Begin Copy the Trovato tlogs to test

  if exist %POLLING%\Poll\TlogT\Polled\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\TlogT\Polled\ %POLLING%\Poll\TestTlogT\Good\Translated TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\TlogT\Polled\ to %POLLING%\Poll\TestTlogT\Good\Translated & set WARNING_FLAG=TRUE

  @call :MESS End Copy the Trovato tlogs to test
  @goto :EOF

:CHECKT
  :: Check Trovato tlogs for problems.
  @call :MESS Begin check Trovato tlogs

::  %PROG_FOLDER%\CheckTlogs.exe %POLLING%\Poll\TlogT\Polled\Tlog*.* GOODDIR=%POLLING%\Poll\TlogT\Good BADDIR=%POLLING%\Poll\TlogT\Bad FORMAT=TROVATO

  %PROG_FOLDER%\ValidateTlogsT.exe %PROG_FOLDER%\ValidateTlogsT.TlogT.par >> %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error checking Trovato tlogs (T) & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

::  %PROG_FOLDER%\ValidateTlogs.exe PARFILE=%PROG_FOLDER%\ValidateTlogs.Poll.TlogT.par
::  @if errorlevel 1 @call :MESS Fatal error checking Trovato tlogs & set ERROR_FLAG=TRUE
::  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check Trovato tlogs
  @goto :EOF

:WIZCONVERT
  :: copy tlogs to WizConvert Folder
  @call :MESS Begin copy Trovato tlogs for Wizmail converting
  if exist %POLLING%\Poll\TlogT\Good\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\TlogT\Good\Tlog*.* %POLLING%\Poll\WizConvert\ToSMTP TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\TlogT\Good\Tlog*.* to %POLLING%\Poll\WizConvert\ToSMTP & set WARNING_FLAG=TRUE
  if exist %POLLING%\Poll\TlogT\GoodExclude\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\TlogT\GoodExclude\Tlog*.* %POLLING%\Poll\WizConvert\ToSMTP TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\TlogT\GoodExclude\Tlog*.* to %POLLING%\Poll\WizConvert\ToSMTP & set WARNING_FLAG=TRUE

  @call :MESS End copy for Wizmail converting
  @goto :EOF

:CONVERT
  :: Convert Trovato tlogs to ARS format.
  @call :MESS Begin convert Trovato tlogs for ARS format
  @call :MESS This has been turned off. The tlogs will simply be moved to the Converted folder
  ::change made on 11/09/2010

  :: See \Poll\AuditWorks\Convert\Tlog\newtoold.dat for outputpaths
  ::cd \Poll\AuditWorks\Convert\Tlog
  ::%POLLING%\Poll\AuditWorks\Convert\Newtoold.exe
  ::@if errorlevel 1 @call :MESS Fatal error converting Trovato tlogs & set ERROR_FLAG=TRUE
  :;cd \Poll\Bin
  ::@if %ERROR_FLAG%==TRUE goto :EOF

  :: See \Poll\AuditWorks\Convert\TlogExclude\newtoold.dat for outputpaths
  ::cd \Poll\AuditWorks\Convert\TlogExclude
  ::%POLLING%\Poll\AuditWorks\Convert\Newtoold.exe
  ::@if errorlevel 1 @call :MESS Fatal error converting Trovato tlogs & set ERROR_FLAG=TRUE
  ::cd \Poll\Bin
  ::@if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\Good\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Good\Tlog*.* %POLLING%\Poll\TlogT\Good\Converted
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Poll\TlogT\Good\Tlog*.* to %POLLING%\Poll\TlogT\Good\Converted & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\GoodExclude\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\GoodExclude\Tlog*.* %POLLING%\Poll\TlogT\GoodExclude\Converted
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Poll\TlogT\GoodExclude\Tlog*.* to %POLLING%\Poll\TlogT\GoodExclude\Converted & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End convert Trovato tlogs for ARS format
  @goto :EOF

:EXCLUDET
  :: Exclude tlogs to use Dave's Translate instead of Corky's - No processing by the mainframe.
  @call :MESS Begin exclude tlogs to use Dave's Translate instead of Corky's

  @call %PROG_FOLDER%\ExcludeTlogst_run.cmd %POLLING%\Poll\Tlog\Polled %POLLING%\Poll\Tlog\Excludet %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogst_run.cmd %POLLING%\Poll\TlogT\Good\Converted %POLLING%\Poll\TlogT\Excludet %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogst_run.cmd %POLLING%\Poll\TlogT\GoodExclude\Converted %POLLING%\Poll\TlogT\Excludet %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs to use Dave's Translate instead of Corky's
  @goto :EOF

:EXCLUDEA
  :: Exclude tlogs from all processing.
  @call :MESS Begin exclude tlogs from all processing

  @call %PROG_FOLDER%\ExcludeTlogsa_run.cmd %POLLING%\Poll\Tlog\Polled %POLLING%\Poll\Tlog\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsa_run.cmd %POLLING%\Poll\TlogT\Good\Converted %POLLING%\Poll\TlogT\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsa_run.cmd %POLLING%\Poll\TlogT\GoodExclude\Converted %POLLING%\Poll\TlogT\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing
  @goto :EOF

:CHECK
  :: Check ARS tlogs for problems.
  @call :MESS Begin check ARS tlogs

::  %PROG_FOLDER%\CheckTlogs.exe %POLLING%\Poll\Tlog\Polled\Tlog*.* GOODDIR=%POLLING%\Poll\Tlog\Good BADDIR=%POLLING%\Poll\Tlog\Bad FORMAT=ARS
  %PROG_FOLDER%\ValidateTlogs.exe PARFILE=%PROG_FOLDER%\ValidateTlogs.Poll.Tlog.par
  @if errorlevel 1 @call :MESS Fatal error checking ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check ARS tlogs
  @goto :EOF

:EXCLUDEI
  :: Exclude tlogs from internal (local) processing.
  @call :MESS Begin exclude tlogs from internal (local) processing

  @call %PROG_FOLDER%\ExcludeTlogsi_run.cmd %POLLING%\Poll\Tlog\Good %POLLING%\Poll\Tlog\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsi_run.cmd %POLLING%\Poll\TlogT\Good\Converted %POLLING%\Poll\TlogT\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsi_run.cmd %POLLING%\Poll\TlogT\GoodExclude\Converted %POLLING%\Poll\TlogT\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from internal (local) processing
  @goto :EOF

:EXCLUDEP
  :: Exclude tlogs from all processing EXCEPT payroll processing.
  @call :MESS Begin exclude tlogs from all processing EXCEPT payroll processing

  @call %PROG_FOLDER%\ExcludeTlogsp_run.cmd %POLLING%\Poll\Tlog\Good %POLLING%\Poll\Tlog\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsp_run.cmd %POLLING%\Poll\TlogT\Good\Converted %POLLING%\Poll\TlogT\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsp_run.cmd %POLLING%\Poll\TlogT\GoodExclude\Converted %POLLING%\Poll\TlogT\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing EXCEPT payroll processing
  @goto :EOF

:TLOGUPDATER
  :: Move tlogs to be picked up by the TlogUpdater
  @call :MESS Begin call TlogUpdater

  if exist %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %POLLING%\Poll\TlogT\Good\ForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs for the TlogUpdater & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\Good\ForTlogUpdater\Tlog*.* E:\adTempusJobs\TlogUpdater\CON_TlogUpdater.exe %POLLING%\Poll\TlogT\Good\ForTlogUpdater %POLLING%\Poll\TlogT\Good\Translated %POLLING%\Poll\TlogT\Good\BackupForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error in TlogUpdater & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %POLLING%\Poll\TlogT\GoodExclude\ForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs (consignment) for the TlogUpdater & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\GoodExclude\ForTlogUpdater\Tlog*.* E:\adTempusJobs\TlogUpdater\CON_TlogUpdater.exe %POLLING%\Poll\TlogT\GoodExclude\ForTlogUpdater %POLLING%\Poll\TlogT\GoodExclude\Translated %POLLING%\Poll\TlogT\GoodExclude\BackupForTlogUpdater
  @if errorlevel 1 @call :MESS Fatal error in TlogUpdater (consignment) & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF
  
  @call :MESS End call TlogUpdater

:NEWTRANSLATE
  ::Begin Dave's Translate
  ::@call :MESS Begin Dave's Translate
  ::
  ::if exist %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* copy %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %POLLING%\Poll\TlogT\TranslateTest /Y
  ::@if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* to %POLLING%\Poll\TlogT\TranslateTest & set ERROR_FLAG=TRUE
  ::@if %ERROR_FLAG%==TRUE goto :EOF
  ::
  ::if exist %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* copy %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %POLLING%\Poll\TlogT\TranslateTest /Y
  ::@if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* to %POLLING%\Poll\TlogT\TranslateTest & set ERROR_FLAG=TRUE
  ::@if %ERROR_FLAG%==TRUE goto :EOF
  ::
  ::C:\PollingApps\Translate\Translate.exe SpencerGifts.Translate.Plugin.TLog.Nightly
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
  ::    cd \Poll\AuditWorks\Translate\Tlog
  ::    %POLLING%\Poll\AuditWorks\Translate\Awtrnslt.exe done
  ::    @if errorlevel 1 @call :MESS Fatal error translating tlogs & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    if exist %POLLING%\Poll\Tlog\Good\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\Tlog\Good\Tlog*.* %POLLING%\Poll\Tlog\Good\Backup
  ::    @if errorlevel 1 @call :MESS Fatal error translating ARS tlogs & set ERROR_FLAG=TRUE
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    :: Trovato Tlogs (Translate to old AuditWorks - Skip the translate, just move the files manually)
  ::    cd \Poll\AuditWorks\Translate\Tlog
  ::    %POLLING%\Poll\AuditWorks\Translate\TrovtoAW.exe done
  ::    @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    ::Copy files to Parralel testing location
  ::    if exist %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %POLLING%\WorkingFiles\TranslateTest\Nightly_Input
  ::    @if errorlevel 1 @call :MESS Fatal error copying Trovato tlogs for translate (New Auditworks) & set ERROR_FLAG=TRUE
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    if exist %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %POLLING%\WorkingFiles\TranslateTest\Nightly_Consignment_Input
  ::    @if errorlevel 1 @call :MESS Fatal error copying Trovato tlogs (consignment) for translate (New Auditworks) & set ERROR_FLAG=TRUE
  ::    @if %ERROR_FLAG%==TRUE goto :EOF


  if exist %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %POLLING%\Poll\TlogT\Good\Translated
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs for translate (Old Auditworks) & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %POLLING%\Poll\TlogT\GoodExclude\Translated
  @if errorlevel 1 @call :MESS Fatal error moving Trovato tlogs (consignment) for translate (Old Auditworks) & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF


  :: OBSOLETE
  ::    :: Translate to the new Auditworks
  ::    cd \Poll\AuditWorks\Translate\Tlog_New
  ::    %POLLING%\Poll\AuditWorks\Translate\Trovto~2.exe done
  ::    @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF
  ::    
  ::    :: Translate Excluded Files to the new Auditworks
  ::    cd \Poll\AuditWorks\Translate\TlogExclude
  ::    %POLLING%\Poll\AuditWorks\Translate\Trovto~2.exe done
  ::    @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  ::    cd \Poll\Bin
  ::    @if %ERROR_FLAG%==TRUE goto :EOF


  @call :MESS End translate tlogs and send to AuditWorks
  @goto :EOF

:TESTMOVE
  :: Simulate tlogs being processed by the Translate.
  @call :MESS Begin simulate translate

  if exist %POLLING%\Poll\Tlog\Good\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\Tlog\Good\Tlog*.* %POLLING%\Poll\Tlog\Good\Backup
  @if errorlevel 1 @call :MESS Fatal error translating ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Good\Converted\Tlog*.* %POLLING%\Poll\TlogT\Good\Translated
  @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\Good\Translated\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Good\Translated\Tlog*.* %POLLING%\Poll\TlogT\Good\Backup
  @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  if exist %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\GoodExclude\Converted\Tlog*.* %POLLING%\Poll\TlogT\GoodExclude\Backup
  @if errorlevel 1 @call :MESS Fatal error translating Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End simulate translate
  @goto :EOF

:EXCLUDEU
  :: Exclude tlogs from mainframe upload.
  @call :MESS Begin exclude tlogs from mainframe upload

  @call %PROG_FOLDER%\ExcludeTlogsu_run.cmd %POLLING%\Poll\Tlog\Good\Backup %POLLING%\Poll\Tlog\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsu_run.cmd %POLLING%\Poll\TlogT\Good\Backup %POLLING%\Poll\TlogT\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call %PROG_FOLDER%\ExcludeTlogsu_run.cmd %POLLING%\Poll\TlogT\GoodExclude\Backup %POLLING%\Poll\TlogT\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from mainframe upload
  @goto :EOF

:DELETEFLAG
  :: Add ProcessTlogs.flg file
  @call :MESS Begin deleting ProcessTlogs.flg

  @if exist %PROG_FOLDER%\ProcessTlogs.flg del %PROG_FOLDER%\ProcessTlogs.flg
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\ProcessTlogs.flg & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End deleting ProcessTlogs.flg
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
  @blat %LOG_FILE% -subject "ERROR: ProcessTlogs" -to AppDevPOSPollingAlerts@spencergifts.com
  ::pause

  :: Force an error code to be returned to the O/S.
  @ren _

