::------------------------------------------------------------------------------
:: CompressStoreMail.cmd
::
:: Created by: Christian Adams
:: Date: 9/25/2003
::
:: Description:
::     This program will compress store mail.
::
:: Usage: 
::     CompressStoreMail
::
:: Dependent programs:
::     7z.exe (7-Zip) - Compresses files.
::
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     Blat.exe - Sends SMTP email.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\CompressStoreMail.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CompressStoreMail.err

  :: Set window title and color
  @Title Compress Store Mail
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * CompressStoreMail.cmd       *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Compress Trovato store mail files.
  @echo.
::  @pause


:MAIN
  if exist %PROG_FOLDER%\CompressStoreMail.warn del %PROG_FOLDER%\CompressStoreMail.warn
  @if errorlevel 1 @call :MESS Fatal error deleting CompressStoreMail.warn & goto ERR

  copy %PROG_FOLDER%\CompressStoreMail_run_piece1.txt %PROG_FOLDER%\CompressStoreMail_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying CompressStoreMail_run_piece1.txt to CompressStoreMail_run.cmd & goto ERR

::  for /F %%E in (%POLLING%\Poll\StoreMailT\Sitelist.txt) do @call :BUILDCMD %%E || set ERROR_FLAG=TRUE
::  for /F %%E in (%PROG_FOLDER%\SitelistT.txt) do @call :BUILDCMD %%E || set ERROR_FLAG=TRUE
  for %%E in (%POLLING%\Poll\StoreMailT\Temp\Mail*.) do @call :BUILDCMD %%~nE || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if ERROR_FLAG==TRUE @call :MESS Fatal error building first piece of CompressStoreMail_run.cmd & goto ERR

::  for /F %%E in (%PROG_FOLDER%\SitelistT2.txt) do @call :BUILDCMD2 %%E || set ERROR_FLAG=TRUE
::  @if errorlevel 1 set ERROR_FLAG=TRUE
::  @if ERROR_FLAG==TRUE @call :MESS Fatal error building second piece of CompressStoreMail_run.cmd & goto ERR

  copy %PROG_FOLDER%\CompressStoreMail_run.cmd /A + %PROG_FOLDER%\CompressStoreMail_run_piece2.txt /A %PROG_FOLDER%\CompressStoreMail_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying CompressStoreMail_run.cmd and CompressStoreMail_run_piece2.txt to CompressStoreMail_run.cmd & goto ERR

  call %PROG_FOLDER%\CompressStoreMail_run.cmd
  @if errorlevel 1 @call :MESS Fatal error compressing store mail & goto ERR

  @if exist %PROG_FOLDER%\CompressStoreMail.warn @call :MESS Error deleting ARS mail for Trovato store & set WARNING_FLAG=TRUE

  @goto CHECKWARN

:BUILDCMD
  @set STORE_NUM=%1
  @echo @call :COMPRESS %STORE_NUM% >> %PROG_FOLDER%\CompressStoreMail_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\CompressStoreMail_run.cmd
  @goto :EOF

:BUILDCMD2
  @set STORE_NUM=%1
  @echo @call :DELARS %STORE_NUM% >> %PROG_FOLDER%\CompressStoreMail_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\CompressStoreMail_run.cmd
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

  :: Continue with the next Batch File

  ::PriceCheck file jobs are disabled (7/1/2010)
  ::%PROG_FOLDER%\CompressPriceCheckFiles
  %PROG_FOLDER%\CompressDebitBinRangeFile

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
  @blat %LOG_FILE% -subject "ERROR: CompressStoreMail" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _

