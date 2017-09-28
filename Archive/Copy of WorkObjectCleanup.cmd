::------------------------------------------------------------------------------
:: WorkObjectCleanup.cmd
::
:: Created by: Christian Adams
:: Date: 9/16/2003
::
:: Description:
::     This program will perform RemoteWare work object cleanup tasks.
::
:: Usage: 
::     WorkObjectCleanup
::
:: Dependent programs:
::     Genswo.exe (RemoteWare) - Generates work object info.
::
::     SWOCleanup.exe (Christian Adams) - Generates RemoteWare ECF script to 
::     cleanup work objects.
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
  @set PROG_FOLDER=E:\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\WorkObjectCleanup.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\WorkObjectCleanup.err

  :: Set window title and color
  @Title Work Object Cleanup
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * WorkObjectCleanup.cmd       *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Clean RWS work objects by removing client assignments.
  @echo.
  @echo *** NOTE ******** NOTE ******** NOTE ******** NOTE ***
  @echo.
  @echo This program does not remove client GROUP assignments!
  @echo.
  @pause

:GENSWO
  :: Generate list of work objects.
  @call :MESS Begin generate list of work obejcts

  E:\RWS\System\Genswo E:\Temp\genswo.ec_
  @if errorlevel 1 @call :MESS Fatal error executing GENSWO & goto ERR

  @call :MESS End generate list of work obejcts

:CLEANSWO
  :: Clean work objects.
  @call :MESS Begin clean work objects
  E:\Poll\Bin\SWOCleanup.exe
  @if errorlevel 1 @call :MESS Fatal error executing SWOCleanup & goto ERR

  @call :MESS End clean work objects

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
::  @start E:\RWS\ECF

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
  @blat %LOG_FILE% -subject "ERROR: BackupServerData" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
