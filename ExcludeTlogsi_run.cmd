:: ExcludeTlogsi_run.cmd
::
:: Dynamically built by BuildTlogExcludeCommands.cmd

  :: Set variables.
  @set ERROR_FLAG=FALSE
  @set WARNING_FLAG=FALSE
  @set PROG_FOLDER=%POLLING%\Poll\Bin
  @set LOG_FILE=%3
  @set INPUT_FOLDER=%1
  @set OUTPUT_FOLDER=%2

@call :EXCLUDE 00000 
@if ERRORLEVEL 1 goto ERR 

@goto END

:EXCLUDE
  :: Exclude tlog.
  @if ERROR_FLAG==TRUE goto :EOF
  :: Set variables.
  @set TLOG_STORE=%1
  @if exist %INPUT_FOLDER%\tlog%TLOG_STORE%*.* goto EXCLD
  @goto :EOF


:EXCLD
  @call :MESS Exclude store #%TLOG_STORE%

  :: Move the tlog(s).
  %PROG_FOLDER%\MoveFiles.exe %INPUT_FOLDER%\tlog%TLOG_STORE%*.* %OUTPUT_FOLDER%
  @if errorlevel 1 @call :MESS Fatal error moving %INPUT_FOLDER%\tlog%TLOG_STORE%*.* to %OUTPUT_FOLDER% & goto EXCLDERR
  @goto :EOF

:EXCLDERR
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