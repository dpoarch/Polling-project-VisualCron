::------------------------------------------------------------------------------
:: StartPCAHost.cmd
::
:: Created by: Christian Adams
:: Date: 8/25/2003
::
:: Description:
::     This program will start the pcAnywhere host.
::
:: Usage: 
::     StartPCAHost
::
:: Dependent programs:
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\StartPCAHost.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\StartPCAHost.err

  :: Set window title and color
  @Title Start pcAnywhere Host
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * StartPCAHost.cmd            *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Start pcAnywhere host.
  @echo.

:DELFLAG
  @if exist %PROG_FOLDER%\StartPCAHost.go del %PROG_FOLDER%\StartPCAHost.go
  @if errorlevel 1 @call :MESS Fatal error %PROG_FOLDER%\StartPCAHost.go & goto ERR

:CHECKHOST
  :: Check if the host is running.
  @call :MESS Begin check if host is running
  "C:\Program Files\Resource Kit\pulist.exe" | grep AWHOST32
  @if errorlevel 2 @call :MESS Fatal error checking host & goto ERR
  @if errorlevel 1 @call :MESS End check if host is running & goto STARTHOST
  @call :MESS End check if host is running
  @goto CHECKWARN

:STARTHOST
  :: Start host.
  @call :MESS Begin start host
  start %PROG_FOLDER%\Network.bhf
  @if errorlevel 1 @call :MESS Fatal error starting host & goto ERR

  @call :MESS End start host

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
  @Now %1 %2 %3 %4 %5 %6 %7 %8 %9 >> %LOG_FILE%
  @ver > nul
  @echo.
  @Now %1 %2 %3 %4 %5 %6 %7 %8 %9
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
  @blat %LOG_FILE% -subject "ERROR: StartPCAHost" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
