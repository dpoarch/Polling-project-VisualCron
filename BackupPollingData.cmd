::------------------------------------------------------------------------------
:: BackupPollingData.cmd
::
:: Created by: Christian Adams
:: Date: 7/19/2002
::
:: Description:
::     This program will backup polling data.
::
:: Usage: 
::     BackupPollingData
::
:: Dependent programs:
::     MoveFiles.exe (Christian Adams) - Moves one or more files.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\BackupPollingData.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\BackupPollingData.err

  :: Set window title and color
  @Title Backup Polling Data
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * BackupPollingData.cmd       *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Backup polling data.
  @echo.
::  @pause

:BACKUP
  :: Backup.
::  @call :MESS Begin backup %POLLING%\Poll\Tlog\*.*
::  if exist C:\Temp\Tlog.zip del %POLLING%\Temp\Tlog.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Tlog.zip & goto ERR
::  if exist %POLLING%\Poll\Tlog\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Tlog.zip %POLLING%\Poll\Tlog
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Tlog\*.* & goto ERR
::  if exist C:\Temp\Tlog.zip C:\PollingApps\MoveFiles.exe C:\Temp\Tlog.zip %POLLING%\Backup\Tlog TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Tlog.zip & goto ERR

  @call :MESS Begin backup %POLLING%\Poll\TlogT\*.*
  if exist C:\Temp\TlogT.zip del %POLLING%\Temp\TlogT.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\TlogT.zip & goto ERR
  if exist %POLLING%\Poll\TlogT\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\TlogT.zip %POLLING%\Poll\TlogT
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\TlogT\*.* & goto ERR
  if exist C:\Temp\TlogT.zip C:\PollingApps\MoveFiles.exe C:\Temp\TlogT.zip %POLLING%\Poll\TlogTBackup TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\TlogT.zip & goto ERR

::  @call :MESS Begin backup %POLLING%\Data\Recover\*.*
::  if exist C:\Temp\Recover.zip del %POLLING%\Temp\Recover.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Recover.zip & goto ERR
::  if exist %POLLING%\Data\Recover\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Recover.zip %POLLING%\Data\Recover
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Data\Recover\*.* & goto ERR
::  if exist C:\Temp\Recover.zip C:\PollingApps\MoveFiles.exe C:\Temp\Recover.zip %POLLING%\Backup\Recover TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Recover.zip & goto ERR

  @call :MESS Begin backup %POLLING%\Data\RecoverT\*.*
  if exist C:\Temp\RecoverT.zip del %POLLING%\Temp\RecoverT.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\RecoverT.zip & goto ERR
  if exist %POLLING%\Data\RecoverT\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\RecoverT.zip %POLLING%\Data\RecoverT
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Data\RecoverT\*.* & goto ERR
  if exist C:\Temp\RecoverT.zip C:\PollingApps\MoveFiles.exe C:\Temp\RecoverT.zip %POLLING%\Data\RecoverTBackup TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\RecoverT.zip & goto ERR

  @call :MESS Begin backup %POLLING%\Poll\Upload\Up*.*
  if exist C:\Temp\Upload.zip del %POLLING%\Temp\Upload.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Upload.zip & goto ERR
  if exist %POLLING%\Poll\Upload\Up*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Upload.zip %POLLING%\Poll\Upload
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Upload\*.* & goto ERR
  if exist C:\Temp\Upload.zip C:\PollingApps\MoveFiles.exe C:\Temp\Upload.zip %POLLING%\Backup\Upload TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Upload.zip & goto ERR

::  @call :MESS Begin backup %POLLING%\Poll\Outbound\Mail*.*
::  if exist C:\Temp\Outbound.zip del %POLLING%\Temp\Outbound.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Outbound.zip & goto ERR
::  if exist %POLLING%\Poll\Outbound\Mail*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Outbound.zip %POLLING%\Poll\Outbound
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Outbound\*.* & goto ERR
::  if exist C:\Temp\Outbound.zip C:\PollingApps\MoveFiles.exe C:\Temp\Outbound.zip %POLLING%\Backup\Outbound TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Outbound.zip & goto ERR

  @call :MESS Begin backup %POLLING%\Poll\OutboundT\Mail*.*
  if exist C:\Temp\OutboundT.zip del %POLLING%\Temp\OutboundT.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\OutboundT.zip & goto ERR
  if exist %POLLING%\Poll\OutboundT\Mail*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\OutboundT.zip %POLLING%\Poll\OutboundT
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\OutboundT\*.* & goto ERR
  if exist C:\Temp\OutboundT.zip C:\PollingApps\MoveFiles.exe C:\Temp\OutboundT.zip %POLLING%\Backup\OutboundT TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\OutboundT.zip & goto ERR

::  @call :MESS Begin backup %POLLING%\Poll\Interface\Ack\Ack*.*
::  if exist C:\Temp\Ack.zip del %POLLING%\Temp\Ack.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Ack.zip & goto ERR
::  if exist %POLLING%\Poll\Interface\Ack\Ack*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Ack.zip %POLLING%\Poll\Interface\Ack
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Interface\Ack\*.* & goto ERR
::  if exist C:\Temp\Ack.zip C:\PollingApps\MoveFiles.exe C:\Temp\Ack.zip %POLLING%\Backup\Ack TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Ack.zip & goto ERR

::  @call :MESS Begin backup %POLLING%\Poll\Interface\ShipSend\ShipSend*.*
::  if exist C:\Temp\ShipSend.zip del %POLLING%\Temp\ShipSend.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\ShipSend.zip & goto ERR
::  if exist %POLLING%\Poll\Interface\ShipSend\ShipSend*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\ShipSend.zip %POLLING%\Poll\Interface\ShipSend
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Interface\ShipSend\*.* & goto ERR
::  if exist C:\Temp\ShipSend.zip C:\PollingApps\MoveFiles.exe C:\Temp\ShipSend.zip %POLLING%\Backup\ShipSend TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\ShipSend.zip & goto ERR

  @call :MESS Begin backup %POLLING%\Poll\Interface\Ends\Ends*.*
  if exist C:\Temp\Ends.zip del %POLLING%\Temp\Ends.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Ends.zip & goto ERR
  if exist %POLLING%\Poll\Interface\Ends\Ends*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Ends.zip %POLLING%\Poll\Interface\Ends
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Interface\Ends\*.* & goto ERR
  if exist C:\Temp\Ends.zip C:\PollingApps\MoveFiles.exe C:\Temp\Ends.zip %POLLING%\Backup\Ends TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Ends.zip & goto ERR

::  @call :MESS Begin backup %POLLING%\Poll\Interface\SpiritCartonScanning\SCN*.*
::  if exist C:\Temp\SpiritCartonScanning.zip del %POLLING%\Temp\SpiritCartonScanning.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\SpiritCartonScanning.zip & goto ERR
::  if exist %POLLING%\Poll\Interface\SpiritCartonScanning\SCN*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\SpiritCartonScanning.zip %POLLING%\Poll\Interface\SpiritCartonScanning\SCN*.*
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Interface\SpiritCartonScanning\SCN*.* & goto ERR
::  if exist C:\Temp\SpiritCartonScanning.zip C:\PollingApps\MoveFiles.exe C:\Temp\SpiritCartonScanning.zip %POLLING%\Backup\SpiritCartonScanning TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\SpiritCartonScanning.zip & goto ERR

  @call :MESS Begin backup %STOREDATA%\DealPricing\*.*
  if exist C:\Temp\DealPricing.zip del %POLLING%\Temp\DealPricing.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\DealPricing.zip & goto ERR
  if exist %STOREDATA%\DealPricing\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\DealPricing.zip %STOREDATA%\DealPricing
  @if errorlevel 1 @call :MESS Fatal error zipping %STOREDATA%\DealPricing\*.* & goto ERR
  if exist C:\Temp\DealPricing.zip C:\PollingApps\MoveFiles.exe C:\Temp\DealPricing.zip %POLLING%\Backup\DealPricing TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\DealPricing.zip & goto ERR

::  if exist C:\Temp\PollRpt.zip del %POLLING%\Temp\PollRpt.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\PollRpt.zip & goto ERR
::  if exist %POLLING%\Poll\Interface\PollRpt\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\PollRpt.zip %POLLING%\Poll\Interface\PollRpt
::  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Interface\PollRpt\*.* & goto ERR
::  if exist C:\Temp\PollRpt.zip C:\PollingApps\MoveFiles.exe C:\Temp\PollRpt.zip %POLLING%\Backup\PollRpt TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\PollRpt.zip & goto ERR

  @call :MESS End backup

:BUCOPY
  :: Copy backups to backup polling server.
  ::@call :MESS Begin copy backups to backup polling server

  :: Copy backups to SGINTPOLLBACK.
  ::xcopy %POLLING%\Backup\*.* \\SGW2KPOLL2\Backup\*.* /d /s /e /f
  ::@if errorlevel 1 @call :MESS Error copying backups to backup polling server & set WARNING_FLAG=TRUE

  ::@call :MESS End copy backups to backup polling server

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
  @blat %LOG_FILE% -subject "ERROR: BackupPollingData" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
