::------------------------------------------------------------------------------
:: PrePollingCleanup.cmd
::
:: Created by: Christian Adams
:: Date: 7/19/2002
::
:: Edited by: Jeramie Shake
:: Date: 8/23/2004
::
:: Description:
::     This program will perform pre-polling cleanup tasks.
::
:: Usage: 
::     PrePollingCleanup
::
:: Dependent programs:
::     MoveFiles.exe (Christian Adams) - Moves oneor more files.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\PrePollingCleanup.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\PrePollingCleanup.err

  :: Set window title and color
  @Title Pre-polling Cleanup
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * PrePollingCleanup.cmd       *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Cleanup folders used during nightly polling.
  @echo.
::  @pause

:SETARCHIVEFOLDERNAME
  @call :MESS Begin setting archive folder name

  For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
  For /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b%%c)
  For /f "tokens=1-2 delims=/." %%a in ("%mytime%") do (set mytime=%%a%%b)
  set ARCHIVEFOLDERNAME=%mydate%_%mytime%
  
  @call :MESS End setting archive folder name

:BULOGS
  @call :MESS Begin archive %POLLING%\Poll\Bin\Logs\*.*

  md %POLLINGARCHIVE%\Logs\%ARCHIVEFOLDERNAME%
  @if errorlevel 1 @call :MESS Fatal error creating directory %POLLINGARCHIVE%\Logs\%ARCHIVEFOLDERNAME% & goto ERR
  C:\PollingApps\MoveFiles.exe %POLLING%\Poll\Bin\Logs\*.* %POLLINGARCHIVE%\Logs\%ARCHIVEFOLDERNAME% TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Poll\Bin\Logs\*.* to %POLLINGARCHIVE%\Logs\%ARCHIVEFOLDERNAME% & goto ERR

  @call :MESS End archive %POLLING%\Poll\Bin\Logs\*.*

::Commented out 11/13/2013
::	:BULOGS
::	  :: Backup and purge files in %PROG_FOLDER%\Logs.
::	  @call :MESS Begin backup files in %PROG_FOLDER%\Logs
::	
::	  if exist %POLLING%\Temp\Logs.zip del %POLLING%\Temp\Logs.zip
::	  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Temp\Logs.zip & goto BULOGSERR
::	  "C:\Program Files\7-Zip\7z.exe" a %POLLING%\Temp\Logs.zip %PROG_FOLDER%\Logs\*.*
::	  @if errorlevel 1 @call :MESS Error zipping %PROG_FOLDER%\Logs\*.* & goto BULOGSERR
::	  if exist %POLLING%\Temp\Logs.zip %PROG_FOLDER%\MoveFiles.exe %POLLING%\Temp\Logs.zip %POLLING%\Backup\Logs TIMESTAMP=TRUE
::	  @if errorlevel 1 @call :MESS Error moving %POLLING%\Temp\Logs.zip & goto BULOGSERR
::	  del %PROG_FOLDER%\Logs\*.* /Q
::	  @if errorlevel 1 @call :MESS Error deleting files from %PROG_FOLDER%\Logs & goto BULOGSERR
::	
::	  @call :MESS End backup and purge files in %PROG_FOLDER%\Logs
::	  goto MOVETLOGS
::	
::	:BULOGSERR
::	  set WARNING_FLAG=TRUE

:MOVETLOGS
  :: Move tlogs from work folders.
  @call :MESS Begin move tlogs from work folders

  :: If there are tlogs in the work folders, move them to the Bad folder.
  if exist %POLLING%\Poll\Tlog\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\Tlog\*.* %POLLING%\Poll\Tlog\Bad
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\Tlog to %POLLING%\Poll\Tlog\Bad & goto ERR
  if exist %POLLING%\Poll\Tlog\Polled\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\Tlog\Polled\*.* %POLLING%\Poll\Tlog\Bad
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\Tlog\Polled to %POLLING%\Poll\Tlog\Bad & goto ERR

  if exist %POLLING%\Poll\TlogT\Zip\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Zip\*.* %POLLING%\Poll\TlogT\Bad\Zip
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\TlogT\Zip to %POLLING%\Poll\TlogT\Bad\Zip & goto ERR
  if exist %POLLING%\Poll\TlogT\Polled\Zip\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Polled\Zip\*.* %POLLING%\Poll\TlogT\Bad\Zip
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\TlogT\Polled\Zip to %POLLING%\Poll\TlogT\Bad\Zip & goto ERR
  if exist %POLLING%\Poll\TlogT\Polled\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Polled\*.* %POLLING%\Poll\TlogT\Bad
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\TlogT\Polled to %POLLING%\Poll\TlogT\Bad & goto ERR

  if exist %POLLING%\Poll\TlogT\CartStores\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\CartStores\*.* %POLLING%\Poll\TlogT\Bad\CartStores
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\TlogT\CartStores to %POLLING%\Poll\TlogT\Bad\CartStores & goto ERR
  if exist %POLLING%\Poll\TlogT\Polled\CartStores\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Polled\CartStores\*.* %POLLING%\Poll\TlogT\Bad\CartStores
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\TlogT\Polled\CartStores to %POLLING%\Poll\TlogT\Bad\CartStores & goto ERR
  if exist %POLLING%\Poll\TlogT\Polled\CartStores\Fixed\Tlog*.* %PROG_FOLDER%\MoveFiles.exe %POLLING%\Poll\TlogT\Polled\CartStores\Fixed\*.* %POLLING%\Poll\TlogT\Bad\CartStores\Fixed
  @if errorlevel 1 @call :MESS Fatal error moving tlogs from %POLLING%\Poll\TlogT\Polled\CartStores\Fixed to %POLLING%\Poll\TlogT\Bad\CartStores\Fixed & goto ERR

  @call :MESS End move tlogs from work folders

:CLEANFOLDERS
  :: Clean folders.
  @call :MESS Begin clean folders

  del %POLLING%\Poll\Tlog\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog & goto ERR
  del %POLLING%\Poll\Tlog\Polled\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Polled & goto ERR
  del %POLLING%\Poll\Tlog\Ends\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Ends & goto ERR

  del %POLLING%\Poll\TlogT\Zip\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Zip & goto ERR
  del %POLLING%\Poll\TlogT\Polled\Zip\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Polled\Zip & goto ERR
  del %POLLING%\Poll\TlogT\Polled\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Polled & goto ERR
  del %POLLING%\Poll\TlogT\Ends\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Ends & goto ERR

  del %POLLING%\Poll\TlogT\CartStores\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\CartStores & goto ERR
  del %POLLING%\Poll\TlogT\Polled\CartStores\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Polled\CartStores & goto ERR
  del %POLLING%\Poll\TlogT\Polled\CartStores\Fixed\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Polled\CartStores\Fixed & goto ERR

  del %POLLING%\Poll\Upload\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Upload & goto ERR
  del %POLLING%\Poll\Outbound\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Outbound & goto ERR
  ::del %POLLING%\Poll\OutboundT\*.* /Q
  ::@if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\OutboundT & goto ERR

  del %POLLING%\Poll\StoreMailT\Temp\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\StoreMailT\Temp & goto ERR
  del %POLLING%\Poll\StoreMailT\Polled\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\StoreMailT\Polled & goto ERR

  del %POLLING%\Poll\Interface\Ack\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Interface\Ack & goto ERR
  del %POLLING%\Poll\Interface\ShipSend\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Interface\Shipsend & goto ERR
  del %POLLING%\Poll\Interface\Ends\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Interface\Ends & goto ERR
  del %POLLING%\Poll\Interface\PollRpt\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Interface\PollRpt & goto ERR

  del %POLLING%\Data\PollData\NotWaitingForPoll\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\PollData\NotWaitingForPoll & goto ERR

  del \\Sgpoll02\TlogCache\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from \\Sgpoll02\TlogCache & goto ERR
  del \\Sgpoll02\TlogCache\Mail\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from \\Sgpoll02\TlogCache\Mail & goto ERR
  del \\Sgpoll02\TlogCache\Other\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from \\Sgpoll02\TlogCache\Other & goto ERR
  del \\Sgpoll03\TlogCache\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from \\Sgpoll03\TlogCache & goto ERR
  del \\Sgpoll03\TlogCache\Mail\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from \\Sgpoll03\TlogCache\Mail & goto ERR
  del \\Sgpoll03\TlogCache\Other\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from \\Sgpoll03\TlogCache\Other & goto ERR

  ::del %POLLING%\WorkingFiles\TranslateTest\Daily_Consignment_Input\*.* /Q
  ::@if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Daily_Consignment_Input & goto ERR
  del %POLLING%\WorkingFiles\TranslateTest\Daily_Consignment_Output\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Daily_Consignment_Output & goto ERR
  ::del %POLLING%\WorkingFiles\TranslateTest\Daily_Input\*.* /Q
  ::@if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Daily_Input & goto ERR
  del %POLLING%\WorkingFiles\TranslateTest\Daily_Output\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Daily_Output & goto ERR
  ::del %POLLING%\WorkingFiles\TranslateTest\Nightly_Consignment_Input\*.* /Q
  ::@if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Nightly_Consignment_Input & goto ERR
  del %POLLING%\WorkingFiles\TranslateTest\Nightly_Consignment_Output\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Nightly_Consignment_Output & goto ERR
  ::del %POLLING%\WorkingFiles\TranslateTest\Nightly_Input\*.* /Q
  ::@if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Nightly_Input & goto ERR
  del %POLLING%\WorkingFiles\TranslateTest\Nightly_Output\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\WorkingFiles\TranslateTest\Nightly_Output & goto ERR

  del %POLLING%\Data\PollData\PolledNetSales\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\PollData\PolledNetSales & goto ERR

  @if not exist %PROG_FOLDER%\Polling1.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\Polling1.flg del %PROG_FOLDER%\Polling1.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\Polling1.flg & goto ERR
  @if not exist %PROG_FOLDER%\Polling2.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\Polling2.flg del %PROG_FOLDER%\Polling2.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\Polling2.flg & goto ERR
  @if not exist %PROG_FOLDER%\Polling3.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\Polling3.flg del %PROG_FOLDER%\Polling3.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\Polling3.flg & goto ERR
  @if not exist %PROG_FOLDER%\Polling4.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\Polling4.flg del %PROG_FOLDER%\Polling4.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\Polling4.flg & goto ERR
  @if not exist %PROG_FOLDER%\Polling5.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\Polling5.flg del %PROG_FOLDER%\Polling5.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\Polling5.flg & goto ERR

  @if not exist %PROG_FOLDER%\PostPollingComplete.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\PostPollingComplete.flg del %PROG_FOLDER%\PostPollingComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\PostPollingComplete.flg & goto ERR
  @if not exist %PROG_FOLDER%\FlashReportsComplete.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\FlashReportsComplete.flg del %PROG_FOLDER%\FlashReportsComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\FlashReportsComplete.flg & goto ERR

  @if not exist %PROG_FOLDER%\PostPolling1.flg @echo %PROG_FOLDER%\PostPolling1.flg has been deleted already.
  @if exist %PROG_FOLDER%\PostPolling1.flg del %PROG_FOLDER%\PostPolling1.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\PostPolling1.flg & goto ERR

  @if not exist %PROG_FOLDER%\BeginRemoveSnapshot.flg @echo %PROG_FOLDER%\BeginRemoveSnapshot.flg has been deleted already.
  @if exist %PROG_FOLDER%\BeginRemoveSnapshot.flg del %PROG_FOLDER%\BeginRemoveSnapshot.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\BeginRemoveSnapshot.flg & goto ERR

  @if not exist %PROG_FOLDER%\DocumentSessions.go @echo %PROG_FOLDER%\DocumentSessions.go has been deleted already.
  @if exist %PROG_FOLDER%\DocumentSessions.go del %PROG_FOLDER%\DocumentSessions.go /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\DocumentSessions.go & goto ERR
  @if not exist %PROG_FOLDER%\DocumentSessionsStarted.flg @echo %PROG_FOLDER%\DocumentSessionsStarted.flg has been deleted already.
  @if exist %PROG_FOLDER%\DocumentSessionsStarted.flg del %PROG_FOLDER%\DocumentSessionsStarted.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\DocumentSessionsStarted.flg & goto ERR
  @if not exist %PROG_FOLDER%\DocumentSessionsComplete.flg @echo %PROG_FOLDER%\DocumentSessionsComplete.flg has been deleted already.
  @if exist %PROG_FOLDER%\DocumentSessionsComplete.flg del %PROG_FOLDER%\DocumentSessionsComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\DocumentSessionsComplete.flg & goto ERR

  @if not exist %PROG_FOLDER%\PostPollingBegun.flg @echo %PROG_FOLDER%\PostPollingBegun.flg has been deleted already.
  @if exist %PROG_FOLDER%\PostPollingBegun.flg del %PROG_FOLDER%\PostPollingBegun.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\PostPollingBegun.flg & goto ERR

  @call :MESS End clean folders

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
  %PROG_FOLDER%\ArchiveServerData

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
  @echo.
  @blat %LOG_FILE% -subject "ERROR: PrePollingCleanup" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
