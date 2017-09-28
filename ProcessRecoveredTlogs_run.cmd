:: ProcessRecoveredTlogs_run.cmd
::
:: Dynamically built and executed by ProcessRecoveredTlogs.cmd

  :: Set variables.
  @set ERROR_FLAG=FALSE
  @set WARNING_FLAG=FALSE
  @set PROG_FOLDER=%POLLING%\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\ProcessRecoveredTlogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ProcessRecoveredTlogs.err

@call :DECOMPRESS Tlog00428 
@if ERRORLEVEL 1 goto ERR 

@goto END

:DECOMPRESS
  :: Decompress tlog.
  @if ERROR_FLAG==TRUE goto :EOF
  :: Set variables.
  @set TLOG_STORE=%1
  @if exist %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.zip goto DCMPRS
  @goto :EOF


:DCMPRS
  ::@call :MESS Begin decompress %TLOG_STORE%.zip

  :: Clean up before decompress.
  if exist %POLLING%\Data\RecoverT\Zip\%TLOG_STORE% del %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%
  @if errorlevel 1 @call :MESS Non-Fatal error deleting %POLLING%\Data\RecoverT\Zip\%TLOG_STORE% & goto DCMPRSERR
  if exist %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.up del %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.up
  @if errorlevel 1 @call :MESS Non-Fatal error deleting %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.up & goto DCMPRSERR

  :: Unzip tlog into the Zip folder.
  "C:\Program Files\7-zip\7z.exe" e %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.zip -o%POLLING%\Data\RecoverT\Zip %TLOG_STORE%.up
  @if errorlevel 1 @call :MESS Non-Fatal error unzipping %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.zip & goto DCMPRSERR

  :: Rename TlogXXXXX.up to TlogXXXXX
  ren %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.up %TLOG_STORE%

  :: Move the tlog to the Polled folder for further processing.
  %PROG_FOLDER%\MoveFile.exe %POLLING%\Data\RecoverT\Zip\%TLOG_STORE% %POLLING%\Data\RecoverT
  @if errorlevel 1 @call :MESS Non-Fatal error moving %POLLING%\Data\RecoverT\Zip\%TLOG_STORE% to %POLLING%\Data\RecoverT & goto DCMPRSERR

  :: Move the zip file to the Backup folder.
  %PROG_FOLDER%\MoveFile.exe %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.zip %POLLING%\Data\RecoverT\Zip\Backup
  @if errorlevel 1 @call :MESS Non-Fatal error moving %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.zip to %POLLING%\Data\RecoverT\Zip\Backup & goto DCMPRSERR

  ::@call :MESS End decompress %TLOG_STORE%.zip
  @goto :EOF

:DCMPRSERR
  %PROG_FOLDER%\Movefile.exe %POLLING%\Data\RecoverT\Zip\%TLOG_STORE%.zip %POLLING%\Data\RecoverT\Bad\Zip

  :: Email log.
  @echo.
  @echo. Attempting to email log to polling administrator...
  @echo.
  @blat %LOG_FILE% -subject "Non-Fatal ERROR: ProcessRecoveredTlogs" -to jeramie.shake@spencergifts.com

  ::@set ERROR_FLAG=TRUE
  ::@ren _
  @goto :EOF

:END
  @goto :EOF

:MESS
  :: Write message to log file and screen.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9 >> %LOG_FILE%
  @ver > nul
  @echo.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9
  @ver > nul
  @goto :EOF

:ERR
  :: Force an error code to be returned to the O/S.
  :: Email log.
  @echo.
  @echo. Attempting to email log to polling administrator...
  @echo.
  @blat %LOG_FILE% -subject "ERROR: ProcessRecoveredTlogs" -to AppDevPOSPollingAlerts@spencergifts.com

  @ren _
