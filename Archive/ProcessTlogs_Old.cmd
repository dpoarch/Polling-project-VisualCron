::------------------------------------------------------------------------------
:: ProcessTlogs.cmd
::
:: Created by: Christian Adams
:: Date: 1/8/2003
::
:: Edited by: Jeramie Shake
:: Date: 8/23/2004
::
:: Description:
::     This program will process tlogs.
::
:: Usage: 
::     ProcessTlogs
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

  @call :EXCLUDEA
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :CHECK
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEI
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :TRANSLATE
  @if %ERROR_FLAG%==TRUE @goto ERR

::  @call :TESTMOVE
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :EXCLUDEU
  @if %ERROR_FLAG%==TRUE @goto ERR

  @goto CHECKWARN

:CARTSTORES
  :: Run ProcessCartTlogs.cmd
  @call :MESS Begin running ProcessCartTlogs.cmd

  call E:\Poll\Bin\ProcessCartTlogs.cmd

  @if errorlevel 1 @call :MESS Error running ProcessCartTlogs.cmd & set WARNING_FLAG=TRUE

  @call :MESS End running ProcessCartTlogs.cmd
  @goto :EOF

:MAKEBATCH
  :: Compose the subprogram that will decompress the Trovato tlogs.
  @call :MESS Begin compose subprogram to decompress Trovato tlogs

  :: Copy in header piece of subprogram.
  copy ProcessTlogs_run_piece1.txt ProcessTlogs_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ProcessTlogs_run_piece1.txt to ProcessTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for %%E in (E:\Poll\TlogT\Polled\Zip\Tlog*.zip) do @call :BUILDCMD %%~nE || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ProcessTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy ProcessTlogs_run.cmd /A + ProcessTlogs_run_piece2.txt /A ProcessTlogs_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ProcessTlogs_run.cmd and ProcessTlogs_run_piece2.txt to ProcessTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram to decompress Trovato tlogs
  @goto :EOF

:BUILDCMD
  :: Build and copy in dynamic piece of subprogram.
  @set TLOG_STORE=%1
  @echo @call :DECOMPRESS %TLOG_STORE% >> E:\Poll\Bin\ProcessTlogs_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> E:\Poll\Bin\ProcessTlogs_run.cmd
  @goto :EOF

:DECOMPRESS
  ::Decompress the Trovato tlogs.
  @call :MESS Begin decompress Trovato tlogs

  call E:\Poll\Bin\ProcessTlogs_run.cmd
  @if errorlevel 1 @call :MESS Error decompressing Trovato tlogs & set WARNING_FLAG=TRUE

  @call :MESS End decompress Trovato tlogs
  @goto :EOF

:CHECKT
  :: Check Trovato tlogs for problems.
  @call :MESS Begin check Trovato tlogs

::  E:\Poll\Bin\CheckTlogs.exe E:\Poll\TlogT\Polled\Tlog*.* GOODDIR=E:\Poll\TlogT\Good BADDIR=E:\Poll\TlogT\Bad FORMAT=TROVATO
  E:\Poll\Bin\ValidateTlogs.exe PARFILE=E:\Poll\Bin\ValidateTlogs.Poll.TlogT.par
  @if errorlevel 1 @call :MESS Fatal error checking Trovato tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check Trovato tlogs
  @goto :EOF

:CONVERT
  :: Convert Trovato tlogs to ARS format.
  @call :MESS Begin convert Trovato tlogs for ARS format

  :: Converted tlogs go to E:\Poll\Tlog\Polled .
  :: Original tlogs go to E:\Poll\TlogT\Good\Backup .
  cd \Poll\AuditWorks\Convert\Tlog
  E:\Poll\AuditWorks\Convert\Newtoold.exe
  @if errorlevel 1 @call :MESS Fatal error converting Trovato tlogs & set ERROR_FLAG=TRUE
  cd \Poll\Bin
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End convert Trovato tlogs for ARS format
  @goto :EOF

:EXCLUDEA
  :: Exclude tlogs from all processing.
  @call :MESS Begin exclude tlogs from all processing

  @call E:\Poll\Bin\ExcludeTlogsa_run.cmd E:\Poll\Tlog\Polled E:\Poll\Tlog\Excludea %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from all processing
  @goto :EOF

:CHECK
  :: Check ARS tlogs for problems.
  @call :MESS Begin check ARS tlogs

::  E:\Poll\Bin\CheckTlogs.exe E:\Poll\Tlog\Polled\Tlog*.* GOODDIR=E:\Poll\Tlog\Good BADDIR=E:\Poll\Tlog\Bad FORMAT=ARS
  E:\Poll\Bin\ValidateTlogs.exe PARFILE=E:\Poll\Bin\ValidateTlogs.Poll.Tlog.par
  @if errorlevel 1 @call :MESS Fatal error checking ARS tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End check ARS tlogs
  @goto :EOF

:EXCLUDEI
  :: Exclude tlogs from internal (local) processing.
  @call :MESS Begin exclude tlogs from internal (local) processing

  @call E:\Poll\Bin\ExcludeTlogsi_run.cmd E:\Poll\Tlog\Good E:\Poll\Tlog\Excludei %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error excluding tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End exclude tlogs from internal (local) processing
  @goto :EOF

:TRANSLATE
  :: Translate tlogs and send to AuditWorks.
  @call :MESS Begin translate tlogs and send to AuditWorks

  cd \Poll\AuditWorks\Translate\Tlog
  E:\Poll\AuditWorks\Translate\Awtrnslt.exe done
  @if errorlevel 1 @call :MESS Fatal error translating tlogs & set ERROR_FLAG=TRUE
  cd \Poll\Bin
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End translate tlogs and send to AuditWorks
  @goto :EOF

:TESTMOVE
  :: Simulate tlogs being processed by the Translate.
  @call :MESS Begin simulate translate

  if exist E:\Poll\Tlog\Good\Tlog*.* E:\Poll\Bin\MoveFiles.exe E:\Poll\Tlog\Good\Tlog*.* E:\Poll\Tlog\Good\Backup
  @if errorlevel 1 @call :MESS Fatal error translating tlogs & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End simulate translate
  @goto :EOF

:EXCLUDEU
  :: Exclude tlogs from mainframe upload.
  @call :MESS Begin exclude tlogs from mainframe upload

  @call E:\Poll\Bin\ExcludeTlogsu_run.cmd E:\Poll\Tlog\Good\Backup E:\Poll\Tlog\Excludeu %LOG_FILE%
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
  @blat %LOG_FILE% -subject "ERROR: ProcessTlogs" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

