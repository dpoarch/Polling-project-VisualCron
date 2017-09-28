::------------------------------------------------------------------------------
:: ArchivePollingData.cmd
::
:: Created by: Jeramie Shake
:: Date: 11/6/2013
::
:: Description:
::     This program will archive polling data.
::
:: Usage: 
::     ArchivePollingData
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\ArchivePollingData.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ArchivePollingData.err

  :: Set window title and color
  @Title Archive Polling Data
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * ArchivePollingData.cmd      *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Archive polling data.
  @echo.
::  @pause

:SETARCHIVEFOLDERNAME
  @call :MESS Begin setting archive folder name

  For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
  For /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b%%c)
  For /f "tokens=1-2 delims=/." %%a in ("%mytime%") do (set mytime=%%a%%b)

  SET mytime2=%mytime: =0%

  set ARCHIVEFOLDERNAME=%mydate%_%mytime2%

  set ARCHIVEFOLDERNAME_PENDING=%mydate%_%mytime2%_Pending

  @call :MESS End setting archive folder name

:RECOVERT
  @call :MESS Begin archive %POLLING%\Data\RecoverT\*.*

  md %POLLINGARCHIVE%\RecoverT\%ARCHIVEFOLDERNAME_PENDING%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\RecoverT\%ARCHIVEFOLDERNAME_PENDING% & goto ERR
  ::xcopy %POLLING%\Data\RecoverT\*.* %POLLINGARCHIVE%\RecoverT\%ARCHIVEFOLDERNAME_PENDING% /E

  robocopy %POLLING%\Data\RecoverT %POLLINGARCHIVE%\RecoverT\%ARCHIVEFOLDERNAME_PENDING% /E /MT /LOG:robocopy.log
  @if errorlevel 8 SET ERROR_FLAG=TRUE
  @if errorlevel 16 SET ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error copying %POLLING%\Data\RecoverT\*.* to %POLLINGARCHIVE%\RecoverT\%ARCHIVEFOLDERNAME_PENDING% & goto ERR
  @if %ERROR_FLAG%==FALSE CD>NUL  

  @call :MESS End archive %POLLING%\Data\RecoverT\*.*

:TLOGT
  @call :MESS Begin archive %POLLING%\Poll\TlogT\*.*

  md %POLLINGARCHIVE%\TlogT\%ARCHIVEFOLDERNAME_PENDING%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\TlogT\%ARCHIVEFOLDERNAME_PENDING% & goto ERR
  ::xcopy %POLLING%\Poll\TlogT\*.* %POLLINGARCHIVE%\TlogT\%ARCHIVEFOLDERNAME_PENDING% /E
  robocopy %POLLING%\Poll\TlogT %POLLINGARCHIVE%\TlogT\%ARCHIVEFOLDERNAME_PENDING% /E /MT /LOG:robocopy.log
  @if errorlevel 8 SET ERROR_FLAG=TRUE
  @if errorlevel 16 SET ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error copying %POLLING%\Poll\TlogT\*.* to %POLLINGARCHIVE%\TlogT\%ARCHIVEFOLDERNAME_PENDING% & goto ERR
  @if %ERROR_FLAG%==FALSE CD>NUL  

  @call :MESS End archive %POLLING%\Poll\TlogT\*.*

:UPLOAD
  @call :MESS Begin archive %POLLING%\Poll\Upload\*.*

  md %POLLINGARCHIVE%\Upload\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\Upload\%ARCHIVEFOLDERNAME% & goto ERR
  ::copy %POLLING%\Poll\Upload\*.* %POLLINGARCHIVE%\Upload\%ARCHIVEFOLDERNAME%
  robocopy %POLLING%\Poll\Upload %POLLINGARCHIVE%\Upload\%ARCHIVEFOLDERNAME% /MT /LOG:robocopy.log
  @if errorlevel 8 SET ERROR_FLAG=TRUE
  @if errorlevel 16 SET ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error copying %POLLING%\Poll\Upload\*.* to %POLLINGARCHIVE%\Upload\%ARCHIVEFOLDERNAME% & goto ERR
  @if %ERROR_FLAG%==FALSE CD>NUL  

  @call :MESS End archive %POLLING%\Poll\Upload\*.*

:OUTBOUNDT
  @call :MESS Begin archive %POLLING%\Poll\OutboundT\*.*

  md %POLLINGARCHIVE%\OutboundT\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\OutboundT\%ARCHIVEFOLDERNAME% & goto ERR
  ::copy %POLLING%\Poll\OutboundT\*.* %POLLINGARCHIVE%\OutboundT\%ARCHIVEFOLDERNAME%
  robocopy %POLLING%\Poll\OutboundT %POLLINGARCHIVE%\OutboundT\%ARCHIVEFOLDERNAME% /MT /LOG:robocopy.log
  @if errorlevel 8 SET ERROR_FLAG=TRUE
  @if errorlevel 16 SET ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error copying %POLLING%\Poll\OutboundT\*.* to %POLLINGARCHIVE%\OutboundT\%ARCHIVEFOLDERNAME% & goto ERR
  @if %ERROR_FLAG%==FALSE CD>NUL  

  @call :MESS End archive %POLLING%\Poll\OutboundT\*.*

:DEALPRICING
  @call :MESS Begin archive %STOREDATA%\DealPricing\*.*

  md %POLLINGARCHIVE%\DealPricing\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\DealPricing\%ARCHIVEFOLDERNAME% & goto ERR
  ::xcopy %STOREDATA%\DealPricing\*.* %POLLINGARCHIVE%\DealPricing\%ARCHIVEFOLDERNAME% /E
  robocopy %STOREDATA%\DealPricing %POLLINGARCHIVE%\DealPricing\%ARCHIVEFOLDERNAME% /E /MT /LOG:robocopy.log
  @if errorlevel 8 SET ERROR_FLAG=TRUE
  @if errorlevel 16 SET ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error copying %STOREDATA%\DealPricing to %POLLINGARCHIVE%\DealPricing\%ARCHIVEFOLDERNAME% & goto ERR
  @if %ERROR_FLAG%==FALSE CD>NUL  

  @call :MESS End archive %STOREDATA%\DealPricing\*.*

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
  %PROG_FOLDER%\PostPollingCleanup

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
  @blat %LOG_FILE% -subject "ERROR: ArchivePollingData" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
