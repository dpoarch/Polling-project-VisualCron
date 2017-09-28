::------------------------------------------------------------------------------
:: BuildTlogExcludeCommands.cmd
::
:: Created by: Christian Adams
:: Date: 5/20/2003
::
:: Edited by: Jeramie Shake
:: Date: 10/26/2004
::
:: Description:
::     This program will build batch programs used to exclude specific stores 
::     from certain tlog processing steps.
::
:: Usage: 
::     BuildTlogExcludeCommands
::
:: Dependent programs:
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     Blat.exe (open source) - Sends SMTP email.
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
  @set PROG_FOLDER=%POLLING%\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\BuildTlogExcludeCommands.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\BuildTlogExcludeCommands.err

  :: Set window title and color
  @Title Build Tlog Exclude Commmands
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo ********************************
  @echo * BuildTlogExcludeCommands.cmd *
  @echo *                              *
  @echo * Created by: Christian Adams  *
  @echo ********************************

  @echo.
  @echo Build tlog exclude commands.
  @echo.
  @pause

:MAIN

  @call :CHECK
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATA
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATU
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATI
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATP
  @if %ERROR_FLAG%==TRUE @goto ERR

  @call :MAKEBATT
  @if %ERROR_FLAG%==TRUE @goto ERR

  @goto CHECKWARN


:CHECK
  :: Check for Exclude file.
  @call :MESS Begin check for Exclude file
  if not exist %PROG_FOLDER%\Exclude.txt @call :MESS Fatal error %PROG_FOLDER%\Exclude.txt does not exist & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF
  @call :MESS End check for Exclude file


:MAKEBATA
  :: Compose the subprogram to exclude tlogs from all processing.
  @call :MESS Begin compose subprogram ExcludeTlogsa_run.cmd

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsa_run_piece1.txt %PROG_FOLDER%\ExcludeTlogsa_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsa_run_piece1.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for /f "eol=; tokens=1-2" %%E in (%PROG_FOLDER%\Exclude.txt) do @call :BUILDA %%E %%F || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ExcludeTlogsa_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsa_run.cmd /A + %PROG_FOLDER%\ExcludeTlogsa_run_piece2.txt /A %PROG_FOLDER%\ExcludeTlogsa_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsa_run.cmd and ExcludeTlogsa_run_piece2.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram ExcludeTlogsa_run.cmd
  @goto :EOF

:BUILDA
  :: Build and copy in dynamic piece of subprogram.
  @set EXCLUDE_TYPE=%1
  @set TLOG_STORE=%2
  if /i %EXCLUDE_TYPE%==A @echo @call :EXCLUDE %TLOG_STORE% >> %PROG_FOLDER%\ExcludeTlogsa_run.cmd
  if /i %EXCLUDE_TYPE%==A @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ExcludeTlogsa_run.cmd
  @goto :EOF


:MAKEBATU
  :: Compose the subprogram to exclude tlogs from the upload to the mainframe.
  @call :MESS Begin compose subprogram ExcludeTlogsu_run.cmd

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsu_run_piece1.txt %PROG_FOLDER%\ExcludeTlogsu_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsu_run_piece1.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for /f "eol=; tokens=1-2" %%E in (%PROG_FOLDER%\Exclude.txt) do @call :BUILDU %%E %%F || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ExcludeTlogsu_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsu_run.cmd /A + %PROG_FOLDER%\ExcludeTlogsu_run_piece2.txt /A %PROG_FOLDER%\ExcludeTlogsu_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsu_run.cmd and ExcludeTlogsu_run_piece2.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram ExcludeTlogsu_run.cmd
  @goto :EOF

:BUILDU
  :: Build and copy in dynamic piece of subprogram.
  @set EXCLUDE_TYPE=%1
  @set TLOG_STORE=%2
  if /i %EXCLUDE_TYPE%==U @echo @call :EXCLUDE %TLOG_STORE% >> %PROG_FOLDER%\ExcludeTlogsu_run.cmd
  if /i %EXCLUDE_TYPE%==U @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ExcludeTlogsu_run.cmd
  @goto :EOF


:MAKEBATI
  :: Compose the subprogram to exclude tlogs from internal (local) processing.
  @call :MESS Begin compose subprogram ExcludeTlogsi_run.cmd

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsi_run_piece1.txt %PROG_FOLDER%\ExcludeTlogsi_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsi_run_piece1.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for /f "eol=; tokens=1-2" %%E in (%PROG_FOLDER%\Exclude.txt) do @call :BUILDI %%E %%F || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ExcludeTlogsi_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsi_run.cmd /A + %PROG_FOLDER%\ExcludeTlogsi_run_piece2.txt /A %PROG_FOLDER%\ExcludeTlogsi_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsi_run.cmd and ExcludeTlogsi_run_piece2.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram ExcludeTlogsi_run.cmd
  @goto :EOF

:BUILDI
  :: Build and copy in dynamic piece of subprogram.
  @set EXCLUDE_TYPE=%1
  @set TLOG_STORE=%2
  if /i %EXCLUDE_TYPE%==I @echo @call :EXCLUDE %TLOG_STORE% >> %PROG_FOLDER%\ExcludeTlogsi_run.cmd
  if /i %EXCLUDE_TYPE%==I @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ExcludeTlogsi_run.cmd
  @goto :EOF


:MAKEBATP
  :: Compose the subprogram to exclude tlogs from all processing EXCEPT payroll processing.
  @call :MESS Begin compose subprogram ExcludeTlogsp_run.cmd

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsp_run_piece1.txt %PROG_FOLDER%\ExcludeTlogsp_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsp_run_piece1.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for /f "eol=; tokens=1-2" %%E in (%PROG_FOLDER%\Exclude.txt) do @call :BUILDP %%E %%F || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ExcludeTlogsp_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogsp_run.cmd /A + %PROG_FOLDER%\ExcludeTlogsp_run_piece2.txt /A %PROG_FOLDER%\ExcludeTlogsp_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogsp_run.cmd and ExcludeTlogsp_run_piece2.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram ExcludeTlogsp_run.cmd
  @goto :EOF

:BUILDP
  :: Build and copy in dynamic piece of subprogram.
  @set EXCLUDE_TYPE=%1
  @set TLOG_STORE=%2
  if /i %EXCLUDE_TYPE%==P @echo @call :EXCLUDE %TLOG_STORE% >> %PROG_FOLDER%\ExcludeTlogsp_run.cmd
  if /i %EXCLUDE_TYPE%==P @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ExcludeTlogsp_run.cmd
  @goto :EOF


:MAKEBATT
  :: Compose the subprogram to exclude tlogs from all processing so they can be processed by Dave's New Translate.
  @call :MESS Begin compose subprogram ExcludeTlogst_run.cmd

  :: Copy in header piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogst_run_piece1.txt %PROG_FOLDER%\ExcludeTlogst_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogst_run_piece1.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Build and copy in dynamic piece of subprogram.
  for /f "eol=; tokens=1-2" %%E in (%PROG_FOLDER%\Exclude.txt) do @call :BUILDT %%E %%F || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building ExcludeTlogst_run.cmd & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  :: Copy in tail piece of subprogram.
  copy %PROG_FOLDER%\ExcludeTlogst_run.cmd /A + %PROG_FOLDER%\ExcludeTlogst_run_piece2.txt /A %PROG_FOLDER%\ExcludeTlogst_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying ExcludeTlogst_run.cmd and ExcludeTlogst_run_piece2.txt & set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE goto :EOF

  @call :MESS End compose subprogram ExcludeTlogst_run.cmd
  @goto :EOF

:BUILDT
  :: Build and copy in dynamic piece of subprogram.
  @set EXCLUDE_TYPE=%1
  @set TLOG_STORE=%2
  if /i %EXCLUDE_TYPE%==T @echo @call :EXCLUDE %TLOG_STORE% >> %PROG_FOLDER%\ExcludeTlogst_run.cmd
  if /i %EXCLUDE_TYPE%==T @echo @if ERRORLEVEL 1 goto ERR >> %PROG_FOLDER%\ExcludeTlogst_run.cmd
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
  @pause

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
  @echo.
::  @blat %LOG_FILE% -subject "ERROR: ProcessRecoveredTlogs" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _

