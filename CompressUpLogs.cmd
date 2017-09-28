::------------------------------------------------------------------------------
:: CompressUpLogs.cmd
::
:: Created by: Christian Adams
:: Date: 5/19/2002
::
:: Description:
::     This program will compress the UpLogs file.
::
:: Usage: 
::     CompressUpLogs
::
:: Dependent programs:
::     cmprs.exe (Corky) - Compression utility.
::
::     FileSize.exe (Christian Adams) - Displays file size and record count.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\CompressUpLogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CompressUpLogs.err

  :: Set window title and color
  @Title Compress UpLogs
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * CompressUpLogs              *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Compress UpLogs.
  @echo.
  @pause

:COMPRESS

  @call :MESS Begin compress

  @if not exist %POLLING%\Poll\Upload\UpLogs. @call :MESS Fatal error %POLLING%\Poll\Upload\UpLogs. does not exist & goto ERR

  if exist %POLLING%\Poll\Upload\CpLogs. del %POLLING%\Poll\Upload\CpLogs.
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\Upload\CpLogs. & goto ERR

  %PROG_FOLDER%\cmprs.exe %POLLING%\Poll\Upload\UpLogs. %POLLING%\Poll\Upload\CpLogs.
  @if errorlevel 1 @call :MESS Fatal error compressing %POLLING%\Poll\Upload\UpLogs. & goto ERR

  @start %PROG_FOLDER%\FileSize %POLLING%\Poll\Upload\CpLogs. 256

  @call :MESS End compress

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
  @blat %LOG_FILE% -subject "ERROR: CompressUpLogs" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
