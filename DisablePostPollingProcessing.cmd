::------------------------------------------------------------------------------
:: DisablePostPollingProcessing.cmd
::
:: Created by: Jeramie Shake
:: Date: 4/06/2005
::
:: Description:
::     This program will delete a flag file to prevent Arcana Scheduler from
::     executing this batch file again. 
::
:: Usage: 
::     DisablePostPollingProcessing
::
:: Dependent programs:
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\DisablePostPollingProcessing.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\DisablePostPollingProcessing.err

  :: Set window title and color
  @Title Disable Post Polling Processing
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo **************************************
  @echo * DisablePostPollingProcessing.cmd   *
  @echo *                                    *
  @echo * Created by: Jeramie Shake          *
  @echo **************************************

  @echo.
  @echo Delete flag file to disable processing of this batch file.
  @echo.
::  @pause

:DISABLE
  :: Delete flag file.
  @call :MESS Begin delete flag file
  
::  @if not exist %PROG_FOLDER%\Polling1.flg @call :MESS Polling1.flg not found exiting batch file & goto EOF
::  @if not exist %PROG_FOLDER%\Polling2.flg @call :MESS Polling2.flg not found exiting batch file & goto EOF
::  @if not exist %PROG_FOLDER%\Polling3.flg @call :MESS Polling3.flg not found exiting batch file & goto EOF
::  @if not exist %PROG_FOLDER%\Polling4.flg @call :MESS Polling4.flg not found exiting batch file & goto EOF
::  @if not exist %PROG_FOLDER%\Polling5.flg @call :MESS Polling5.flg not found exiting batch file & goto EOF
  
  ::If Tlogs are being processed right now, do not start post polling
  @if exist %PROG_FOLDER%\ProcessTlogs.flg @call :MESS ProcessTlogs.flg found exiting batch file & goto :EOF

  @if not exist %PROG_FOLDER%\PostPolling1.flg @echo Flag file has been deleted already!
  @if exist %PROG_FOLDER%\PostPolling1.flg del %PROG_FOLDER%\PostPolling1.flg
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\PostPolling1.flg & goto ERR

  @if exist %PROG_FOLDER%\PostPollingBegun.flg @echo PostPollingBegun.flg has been copied already!
  @if not exist %PROG_FOLDER%\PostPollingBegun.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\PostPollingBegun.flg
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\PostPollingBegun.flg & goto ERR

  @call :MESS End delete flag file

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
  %PROG_FOLDER%\DisableTlogProcessing

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
  @blat %LOG_FILE% -subject "FATAL ERROR: DisablePostPollingProcessing" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

