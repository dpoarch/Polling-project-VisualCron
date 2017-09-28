::------------------------------------------------------------------------------
:: ProcessRecoveredTlogs.cmd
::
:: Created by: Christian Adams
:: Date: 1/9/2003
::
:: Edited by: Jeramie Shake
:: Date: 10/26/2004
::
:: Description:
::     This program will process recovered tlogs.
::
:: Usage: 
::     ProcessRecoveredTlogs
::
:: Dependent programs:
::     Wzunzip.exe (winZip) - Deompresses files.
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
  @call :CARTSTORES
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATCH
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :DECOMPRESS
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :CHECKT
  @if %ERROR_FLAG%==TRUE @goto ERR
  
  @call :CONVERT
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :INTERNET
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :GIFTCARD
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEA
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :CHECK
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEI
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEP
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :TRANSLATE
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :TESTMOVE
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEU
  @if %ERROR_FLAG%==TRUE @goto ERR

  @goto CHECKWARN

:CARTSTORES
  :: Run ProcessRecoveredCartTlogs.cmd
  @call :MESS Begin running ProcessRecoveredCartTlogs.cmd

  call E:\Poll\Bin\ProcessRecoveredCartTlogs.cmd

  @if errorlevel 1 @call :MESS Error running ProcessRecoveredCartTlogs.cmd & set WARNING_FLAG=TRUE

  @call :MESS End running ProcessRecoveredCartTlogs.cmd
  @goto :EOF

:MAKEBATCH
  :: Compose the subprogram that will decompress the Trovato tlogs.
  @call :MESS Begin compose subprogram to decompress Trovato tlogs

  :: Copy in header piece of subprogram.
  copy ProcessRecoveredTlogs_run_piece1.txt ProcessRecoveredTlogs_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ProcessRecoveredTlogs_run_piece1.txt to ProcessRecoveredTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for %%E in (E:\Data\RecoverT\Zip\Tlog*.zip) do @call :BUILDCMD %%~nE || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ProcessRecoveredTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy ProcessRecoveredTlogs_run.cmd /A + ProcessRecoveredTlogs_run_piece2.txt /A ProcessRecoveredTlogs_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ProcessRecoveredTlogs_run.cmd and ProcessRecoveredTlogs_run_piece2.txt to ProcessRecoveredTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram to decompress Trovato tlogs
  @goto :EOF

:BUILDCMD
  :: Build and copy in dynamic piece of subprogram.
  @set TLOG_STORE=%1
  @echo @call :DECOMPRESS %TLOG_STORE% >> E:\Poll\Bin\ProcessRecoveredTlogs_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> E:\Poll\Bin\ProcessRecoveredTlogs_run.cmd
  @goto :EOF

:DECOMPRESS
  ::Decompress the Trovato tlogs.
  @call :MESS Begin decompress Trovato tlogs

  call E:\Poll\Bin\ProcessRecoveredTlogs_run.cmd
  @if errorlevel 1 @call :MESS Error decompressing Trovato tlogs & set WARNING_FLAG=TRUE

  @call :MESS End decompress Trovato tlogs
  @goto :EOF

:CHECKT
  :: Check Trovato tlogs for problems.
  @call :MESS Begin check Trovato tlogs

::  E:\Poll\Bin\CheckTlogs.exe E:\Data\RecoverT\Tlog*.* GOODDIR=E:\Data\RecoverT\Good BADDIR=E:\Data\RecoverT\Bad FORMAT=TROVATO
  E:\Poll\Bin\ValidateTlogs.exe PARFILE=E:\Poll\Bin\ValidateTlogs.Data.RecoverT.par
  @if errorlevel 1 @call :MESS Fatal error checking Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check Trovato tlogs
  @goto :EOF

:CONVERT
  :: Convert Trovato tlogs to ARS format.
  @call :MESS Begin convert Trovato tlogs for ARS format

  :: Converted tlogs go to E:\Data\Recover .
  :: Original tlogs go to E:\Data\RecoverT\Good\Backup .
  cd \Poll\AuditWorks\Convert\Recover
  E:\Poll\AuditWorks\Convert\Newtoold.exe
  @if errorlevel 1 @call :MESS Fatal error converting Trovato tlogs & set ERROR_FLAG=TRUE
  cd \Poll\Bin
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End convert Trovato tlogs for ARS format
  @goto :EOF

:INTERNET
  :: Move Internet sales to Recover folder.
  @call :MESS Begin move Internet sales to Recover folder

  if exist \\SGINTFINOP\OPS_SHARED\SIRISFTP\InternetSales\TLOG?????.* move \\SGINTFINOP\OPS_SHARED\SIRISFTP\InternetSales\TLOG?????.* E:\Data\Recover
  @if errorlevel 1 @call :MESS Error moving Internet sales to Recover folder & set WARNING_FLAG=TRUE

  @call :MESS End move Internet sales to Recover folder
  @goto :EOF

:GIFTCARD
  :: Move Gift Card adjustments to Recover folder.
  @call :MESS Begin move Gift Card adjustments to Recover folder

  if exist \\SGINTAW\SYBWORK\GIFTCARD\TLOGS\TLOG?????.* move \\SGINTAW\SYBWORK\GIFTCARD\TLOGS\TLOG?????.* E:\Data\Recover
  @if errorlevel 1 @call :MESS Error moving Internet sales to Recover folder & set WARNING_FLAG=TRUE

  @call :MESS End move Gift Card adjustments to Recover folder
  @goto :EOF

:EXCLUDEA
  :: Exclude tlogs from all processing.
  @call :MESS Begin exclude tlogs from all processing

  @call E:\Poll\Bin\ExcludeTlogsa_run.cmd E:\Data\Recover E:\Data\Recover\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing
  @goto :EOF

:CHECK
  :: Check ARS tlogs for problems.
  @call :MESS Begin check ARS tlogs

::  E:\Poll\Bin\CheckTlogs.exe E:\Data\Recover\Tlog*.* GOODDIR=E:\Data\Recover\Good BADDIR=E:\Data\Recover\Bad FORMAT=ARS
  E:\Poll\Bin\ValidateTlogs.exe PARFILE=E:\Poll\Bin\ValidateTlogs.Data.Recover.par
  @if errorlevel 1 @call :MESS Fatal error checking ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check ARS tlogs
  @goto :EOF

:EXCLUDEI
  :: Exclude tlogs from internal (local) processing.
  @call :MESS Begin exclude tlogs from internal (local) processing

  @call E:\Poll\Bin\ExcludeTlogsi_run.cmd E:\Data\Recover\Good E:\Data\Recover\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from internal (local) processing
  @goto :EOF

:EXCLUDEP
  :: Exclude tlogs from all processing except payroll processing.
  @call :MESS Begin exclude tlogs from all processing except payroll processing.

  @call E:\Poll\Bin\ExcludeTlogsp_run.cmd E:\Data\Recover\Good E:\Data\Recover\Excludep %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing except payroll processing.
  @goto :EOF

:TRANSLATE
  :: Translate tlogs and send to AuditWorks.
  @call :MESS Begin translate tlogs and send to AuditWorks

  cd \Poll\AuditWorks\Translate\Recover
  E:\Poll\AuditWorks\Translate\Awtrnslt.exe repoll
  @if errorlevel 1 @call :MESS Fatal error translating tlogs & set ERROR_FLAG=TRUE
  cd \Poll\Bin
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End translate tlogs and send to AuditWorks
  @goto :EOF

:TESTMOVE
  :: Simulate tlogs being processed by the Translate.
  @call :MESS Begin simulate translate

  if exist E:\Data\Recover\Good\Tlog*.* E:\Poll\Bin\MoveFiles.exe E:\Data\Recover\Good\Tlog*.* E:\Data\Recover\Good\Backup
  @if errorlevel 1 @call :MESS Fatal error translating tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End simulate translate
  @goto :EOF

:EXCLUDEU
  :: Exclude tlogs from mainframe upload.
  @call :MESS Begin exclude tlogs from mainframe upload

  @call E:\Poll\Bin\ExcludeTlogsu_run.cmd E:\Data\Recover\Good\Backup E:\Data\Recover\Excludeu %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding tlogs & set ERROR_FLAG=TRUE
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
  @blat %LOG_FILE% -subject "ERROR: ProcessRecoveredTlogs" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

