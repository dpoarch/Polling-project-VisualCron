::------------------------------------------------------------------------------
:: BackupServerData.cmd
::
:: Created by: Christian Adams
:: Date: 7/19/2002
::
:: Description:
::     This program will backup server data.
::
:: Usage: 
::     BackupServerData
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\BackupServerData.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\BackupServerData.err

  :: Set window title and color
  @Title Backup Server Data
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * BackupServerData.cmd        *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Backup server data.
  @echo.
::  @pause

:PURGE
  :: Purge old backups.
::Turned off 6/6/2013 - we will have to manually do the purge from now on, until the new backup solution is implemented
::  @call :MESS Begin purge old backups

  :: Delete backups over 30 days old on production polling server.
  ::P: points to %POLLING%, but only in the AdTempus Job "Pre-Polling - Step 1"
::  forfiles /p P:\Backup /s /m *.zip /d -30 /c "cmd /c del @FILE"
::  @if errorlevel 1 @call :MESS Error purging 30 day old backups on production polling server & set WARNING_FLAG=TRUE

  :: Delete backups over 5 days old on production polling server.
::Added 3/7/2013
::  forfiles /p P:\Backup\Trovato /s /m *.zip /d -5 /c "cmd /c del @FILE"
::  @if errorlevel 1 @call :MESS Error purging 5 day old backups on production polling server & set WARNING_FLAG=TRUE

  :: Delete backups over 30 days old on backup polling server.
  ::net use x: \\SGw2KPOLL2\Backup
  ::forfiles -px:\ -s -m*.zip -d-30 -c"cmd /c del @FILE"
  ::@if errorlevel 1 @call :MESS Error purging backups on backup polling server & set WARNING_FLAG=TRUE
  ::net use x: /delete

::  @call :MESS End purge old backups

:BUPOLL
  :: Backup files in %POLLING%\Poll.
  @call :MESS Begin backup files in %POLLING%\Poll

  if exist C:\Temp\Poll.zip del %POLLING%\Temp\Poll.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Poll.zip & goto ERR
  "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Poll.zip %POLLING%\Poll -xr!"TlogTBackup\"
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\*.* & goto ERR
  if exist C:\Temp\Poll.zip %PROG_FOLDER%\MoveFiles.exe C:\Temp\Poll.zip %POLLING%\Backup\Poll TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Poll.zip & goto ERR

  @call :MESS End backup files in %POLLING%\Poll

:BUDATA
  :: Backup files in %POLLING%\Data.
  @call :MESS Begin backup files in %POLLING%\Data

  if exist C:\Temp\Data.zip del %POLLING%\Temp\Data.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\Data.zip & goto ERR
  "C:\Program Files\7-Zip\7z.exe" a C:\Temp\Data.zip %POLLING%\Data  -xr!"RecoverTBackup\"
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Data\*.* & goto ERR
  if exist C:\Temp\Data.zip %PROG_FOLDER%\MoveFiles.exe C:\Temp\Data.zip %POLLING%\Backup\Data TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\Data.zip & goto ERR

  @call :MESS End backup files in %POLLING%\Data

:BUAuthExcept_Pending
  :: Backup files in %STOREDATA%\AuthExcept_Pending\Backup.
  @call :MESS Begin backup files in %POLLING%\AuthExcept_Pending\Backup

  if exist C:\Temp\AuthExcept_Pending.zip del %POLLING%\Temp\AuthExcept_Pending.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\AuthExcept_Pending.zip & goto ERR
  if exist %STOREDATA%\AuthExcept_Pending\Backup\*.txt "C:\Program Files\7-Zip\7z.exe" a C:\Temp\AuthExcept_Pending.zip %STOREDATA%\AuthExcept_Pending\Backup
  @if errorlevel 1 @call :MESS Fatal error zipping %STOREDATA%\AuthExcept_Pending\Backup\*.* & goto ERR
  if exist C:\Temp\AuthExcept_Pending.zip %PROG_FOLDER%\MoveFiles.exe C:\Temp\AuthExcept_Pending.zip %STOREDATA%\AuthExcept_Pending\Zipped TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\AuthExcept_Pending.zip & goto ERR

  if exist %STOREDATA%\AuthExcept_Pending\Backup\*.txt del %STOREDATA%\AuthExcept_Pending\Backup\*.txt
  @if errorlevel 1 @call :MESS Fatal error deleting %STOREDATA%\AuthExcept_Pending\Backup\*.txt & goto ERR

  @call :MESS End backup files in %STOREDATA%\AuthExcept_Pending\Backup

:BUSpencers
:: Turned off 3/7/2013
  :: Backup files in %STOREDATA%\Spencers. - This WILL NOT Backup the Data\Docs_Menu Directory
::  @call :MESS Begin backup files in %STOREDATA%\Spencers
::
::  if exist E:\Temp\Spencers.zip del E:\Temp\Spencers.zip
::  @if errorlevel 1 @call :MESS Fatal error deleting E:\Temp\Spencers.zip & goto ERR
::  "C:\Program Files\7-zip\7z.exe" a E:\Temp\Spencers.zip %STOREDATA%\Spencers -xr!"Docs_Menu\" -we:\Temp
::  @if errorlevel 1 @call :MESS Fatal error zipping %STOREDATA%\Spencers\*.* & goto ERR
::  if exist E:\Temp\Spencers.zip %PROG_FOLDER%\MoveFiles.exe E:\Temp\Spencers.zip %POLLING%\Backup\Spencers TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Fatal error moving E:\Temp\Spencers.zip & goto ERR

::  @call :MESS End backup files in %STOREDATA%\Spencers

:BUTrovato
  :: Backup files in %STOREDATA%\Trovato.
  @call :MESS Begin backup files in %STOREDATA%\Trovato

  if exist E:\Temp\Trovato.zip del E:\Temp\Trovato.zip
  @if errorlevel 1 @call :MESS Fatal error deleting E:\Temp\Trovato.zip & goto ERR
  "C:\Program Files\7-Zip\7z.exe" a E:\Temp\Trovato.zip %STOREDATA%\Trovato -xr!"Sql\" -we:\Temp
  @if errorlevel 1 @call :MESS Fatal error zipping %STOREDATA%\Trovato\*.* & goto ERR
  if exist E:\Temp\Trovato.zip %PROG_FOLDER%\MoveFiles.exe E:\Temp\Trovato.zip %POLLING%\Backup\Trovato TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving E:\Temp\Trovato.zip & goto ERR

  @call :MESS End backup files in %STOREDATA%\Trovato

:GENALL
  :: Generate RemoteWare configuration data.
  @call :MESS Begin generate RemoteWare configuration data

  if exist %POLLING%\Genall\*.* del %POLLING%\Genall\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Genall\*.* & goto ERR

  if exist %PROG_FOLDER%\GenAllBackupComplete.flg del %PROG_FOLDER%\GenAllBackupComplete.flg /Q
  @if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\GenAllBackupComplete.flg & goto ERR

  ::Write flag so the ExecuteGenAll windows service on the polling server will run the genall program
  copy %PROG_FOLDER%\maildone.txt %PROG_FOLDER%\GenAllBackup.flg
  @if errorlevel 1 @call :MESS Fatal error creating %PROG_FOLDER%\GenAllBackup.flg & goto ERR

  @call :MESS End generate RemoteWare configuration data

:BUHR
  if exist C:\Temp\Hr.zip del %POLLING%\Temp\HR.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Temp\HR.zip & goto ERR
  if exist %POLLING%\Poll\Interface\HR\*.txt "C:\Program Files\7-Zip\7z.exe" a C:\Temp\HR.zip %POLLING%\Poll\Interface\HR
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\Interface\HR\*.* & goto ERR
  if exist C:\Temp\HR.zip %PROG_FOLDER%\MoveFiles.exe C:\Temp\HR.zip %POLLING%\Backup\HR TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Temp\HR.zip & goto ERR

  if exist %POLLING%\Poll\Interface\HR\*.txt del %POLLING%\Poll\Interface\HR\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Interface\HR & goto ERR

:BUCOPY
  :: Copy backups to backup polling server.
  ::@call :MESS Begin copy backups to backup polling server

  :: Copy backups to SGINTPOLLBACK.
  ::xcopy %POLLING%\Backup\*.* \\SGW2KPOLL2\Backup\*.* /d /s /e /f
  ::@if errorlevel 1 @call :MESS Error copying backups to backup polling server & set WARNING_FLAG=TRUE

  ::@call :MESS End copy backups to backup polling server

:TSM
  :: Set flag to perform TSM backup.
  @call :MESS Begin set flag to perform TSM backup

  :: Copy flag file.
  @if exist %PROG_FOLDER%\TSM_Backup.go @echo Flag file has been copied already!
  if not exist %PROG_FOLDER%\TSM_Backup.go copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\TSM_Backup.go
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\TSM_Backup.go & goto ERR

  @call :MESS End set flag to perform TSM backup

:WRITEFLAG
  :: Set flag to show that Pre-Polling Step 1 is complete.
  @call :MESS Begin set flag to show that Pre-Polling Step 1 is complete

  :: Copy flag file.
  @if exist %PROG_FOLDER%\PrePolling1.flg @echo Flag file has been copied already!
  if not exist %PROG_FOLDER%\PrePolling1.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\PrePolling1.flg
  @if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\PrePolling1.flg & goto ERR

  @call :MESS End set flag to show that Pre-Polling Step 1 is complete

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
  @blat %LOG_FILE% -subject "ERROR: BackupServerData" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
