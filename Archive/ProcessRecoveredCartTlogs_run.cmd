:: ProcessRecoveredCartTlogs_run.cmd
::
:: Dynamically built and executed by ProcessRecoveredCartTlogs.cmd

  :: Set variables.
  @set ERROR_FLAG=FALSE
  @set WARNING_FLAG=FALSE
  @set PROG_FOLDER=\\sghpnas\pos\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\ProcessRecoveredCartTlogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\ProcessRecoveredCartTlogs.err


@goto END

:FIXTLOGT
  :: Fix store numbers in Cart store tlog.
  @if ERROR_FLAG==TRUE goto :EOF
  :: Set variables.
  @set TLOG_STORE=%1
  @if exist \\sghpnas\pos\Data\RecoverT\CartStores\%TLOG_STORE% goto FIX
  @goto :EOF


:FIX
  ::@call :MESS Begin fix %TLOG_STORE%

  :: Clean up before fix.
  if exist \\sghpnas\pos\Data\RecoverT\CartStores\TempTlog del \\sghpnas\pos\Data\RecoverT\CartStores\TempTlog
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Data\RecoverT\CartStores\TempTlog & goto FIXERR
  if exist \\sghpnas\pos\Data\RecoverT\CartStores\Fixed\%TLOG_STORE% del \\sghpnas\pos\Data\RecoverT\CartStores\Fixed\%TLOG_STORE%
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Data\RecoverT\CartStores\Fixed\%TLOG_STORE% & goto FIXERR

  :: Fix tlog and place fixed copy in \Fixed.
  \\sghpnas\pos\Poll\Bin\FixTlogT.exe \\sghpnas\pos\Data\RecoverT\CartStores\%TLOG_STORE% FileName \\sghpnas\pos\Data\RecoverT\CartStores\Fixed\
  @if errorlevel 1 @call :MESS Fatal error fixing \\sghpnas\pos\Data\RecoverT\CartStores\%TLOG_STORE% & goto FIXERR

  :: Move the tlog to the Recover folder for further processing.
  \\sghpnas\pos\Poll\Bin\MoveFile.exe \\sghpnas\pos\Data\RecoverT\CartStores\Fixed\%TLOG_STORE% \\sghpnas\pos\Data\RecoverT
  @if errorlevel 1 @call :MESS Fatal error moving \\sghpnas\pos\Data\RecoverT\CartStores\Fixed\%TLOG_STORE% to \\sghpnas\pos\Data\RecoverT & goto FIXERR

  :: Move the original file to the Backup folder.
  \\sghpnas\pos\Poll\Bin\MoveFile.exe \\sghpnas\pos\Data\RecoverT\CartStores\%TLOG_STORE% \\sghpnas\pos\Data\RecoverT\CartStores\Backup
  @if errorlevel 1 @call :MESS Fatal error moving \\sghpnas\pos\Data\RecoverT\CartStores\%TLOG_STORE% to \\sghpnas\pos\Data\RecoverT\CartStores\Backup & goto FIXERR

  ::@call :MESS End fix %TLOG_STORE%
  @goto :EOF

:FIXERR
  \\sghpnas\pos\Poll\Bin\Movefile.exe \\sghpnas\pos\Data\RecoverT\CartStores\%TLOG_STORE% \\sghpnas\pos\Data\RecoverT\Bad\CartStores

  @set ERROR_FLAG=TRUE
  @ren _
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
  @ren _
