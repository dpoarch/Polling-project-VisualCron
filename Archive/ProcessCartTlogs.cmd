::------------------------------------------------------------------------------
:: ProcessCartTlogs.cmd
::
:: Created by: Jeramie Shake
:: Date: 8/23/2004
::
:: Description:
::     This program will process cart store tlogs.
::
:: Usage: 
::     ProcessCartTlogs
::
:: Dependent programs:
::
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     Blat.exe (open source) - Sends SMTP email.
::
::     MoveFile.exe (Christian Adams) - Moves a single file.
::
::     MoveFiles.exe (Christian Adams) - Moves multiple files.
::
::     FixTlogT.exe (Jeramie Shake) - Changes store number inside a tlog.
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
  @set PROG_FOLDER=\\sghpnas\pos\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\ProcessCartTlogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ProcessCartTlogs.err

  :: Set window title and color
  @Title Process Tlogs
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * ProcessCartTlogs.cmd        *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Process cart store tlogs.
  @echo.
::  @pause

:MAIN
  @call :MAKEBATCH
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :FIXTLOGT
  @if %ERROR_FLAG%==TRUE @goto ERR

  @goto CHECKWARN


:MAKEBATCH
  :: Compose the subprogram that will change store number inside Cart Store tlogs.
  @call :MESS Begin compose subprogram to change store number inside Cart Store tlogs

  :: Copy in header piece of subprogram.
  copy ProcessCartTlogs_run_piece1.txt ProcessCartTlogs_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ProcessCartTlogs_run_piece1.txt to ProcessCartTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for %%E in (\\sghpnas\pos\Poll\TlogT\Polled\Cartstores\Tlog*.*) do @call :BUILDCMD %%~nE || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ProcessCartTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy ProcessCartTlogs_run.cmd /A + ProcessCartTlogs_run_piece2.txt /A ProcessCartTlogs_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ProcessCartTlogs_run.cmd and ProcessCartTlogs_run_piece2.txt to ProcessCartTlogs_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram to change store number inside Cart Store tlogs
  @goto :EOF

:BUILDCMD
  :: Build and copy in dynamic piece of subprogram.
  @set TLOG_STORE=%1
  @echo @call :FIXTLOGT %TLOG_STORE% >> \\sghpnas\pos\Poll\Bin\ProcessCartTlogs_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> \\sghpnas\pos\Poll\Bin\ProcessCartTlogs_run.cmd
  @goto :EOF

:FIXTLOGT
  ::Fix store numbers in Cart store tlogs.
  @call :MESS Begin fix store numbers in Cart store tlogs

  call \\sghpnas\pos\Poll\Bin\ProcessCartTlogs_run.cmd
  @if errorlevel 1 @call :MESS Error fixing store numbers in Cart store tlogs & set WARNING_FLAG=TRUE

  @call :MESS End fix store numbers in Cart store tlogs
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
  @blat %LOG_FILE% -subject "ERROR: ProcessCartTlogs" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

