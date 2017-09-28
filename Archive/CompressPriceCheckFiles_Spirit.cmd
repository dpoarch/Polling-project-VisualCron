::------------------------------------------------------------------------------
:: CompressPriceCheckFiles_Spirit.cmd
::
:: Created by: Jeramie Shake
:: Date: 2/27/2006
::
:: Description:
::     This program will compress the price check files for transmittal to the stores
::
:: Usage: 
::     CompressPriceCheckFiles_Spirit
::
:: Dependent programs:
::     Wzzip.exe (winZip) - Compresses files.
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
  @set PROG_FOLDER=\\sghpnas\pos\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\CompressPriceCheckFiles_Spirit.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CompressPriceCheckFiles_Spirit.err

  :: Set window title and color
  @Title Compress Price Check Files
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo **********************************
  @echo * CompressPriceCheckFiles_Spirit *
  @echo *                                *
  @echo * Created by: Jeramie Shake      *
  @echo **********************************

  @echo.
  @echo Compress Price Check Files Spirit.
  @echo.
::  @pause
  
:MAIN
  if not exist \\sghpnas\pos\Poll\Bin\GeneratePriceCheckFiles_Spirit_Complete.flg @call :MESS Fatal error \\sghpnas\pos\Poll\Bin\GeneratePriceCheckFiles_Spirit_Complete.flg does not exist & goto ERR

  if exist \\sghpnas\pos\RWS\ECF\PriceCheck_Spirit.ece @call :MESS Fatal error \\sghpnas\pos\RWS\ECF\PriceCheck_Spirit.ece exists & goto ERR

  if exist CompressPriceCheckFiles_Spirit.warn del CompressPriceCheckFiles_Spirit.warn
  @if errorlevel 1 @call :MESS Fatal error deleting CompressPriceCheckFiles_Spirit.warn & goto ERR

  copy CompressPriceCheckFiles_Spirit_run_piece1.txt CompressPriceCheckFiles_Spirit_run.cmd
  @if errorlevel 1 @call :MESS Fatal error copying CompressPriceCheckFiles_Spirit_run_piece1.txt to CompressPriceCheckFiles_Spirit_run.cmd & goto ERR

  for /F %%E in (\\sghpnas\pos\Poll\PriceCheck_Spirit\PriceCheckFileList.txt) do @call :BUILDCMD %%E || set ERROR_FLAG=TRUE
  @if errorlevel 1 set ERROR_FLAG=TRUE
  @if %ERROR_FLAG%==TRUE @call :MESS Fatal error building first piece of CompressPriceCheckFiles_Spirit_run.cmd & goto ERR

  copy CompressPriceCheckFiles_Spirit_run.cmd /A + CompressPriceCheckFiles_Spirit_run_piece2.txt /A CompressPriceCheckFiles_Spirit_run.cmd /A
  @if errorlevel 1 @call :MESS Fatal error copying CompressPriceCheckFiles_Spirit_run.cmd and CompressPriceCheckFiles_Spirit_run_piece2.txt to CompressPriceCheckFiles_Spirit_run.cmd & goto ERR

  call CompressPriceCheckFiles_Spirit_run.cmd
  @if errorlevel 1 @call :MESS Fatal error compressing price check files & goto ERR

  @if exist CompressPriceCheckFiles_Spirit.warn @call :MESS Error compressing price check files & set WARNING_FLAG=TRUE

  @goto CHECKWARN

:BUILDCMD
  @set FILE_NUM=%1
  @echo @call :COMPRESS %FILE_NUM% >> CompressPriceCheckFiles_Spirit_run.cmd
  @echo @if ERRORLEVEL 1 goto ERR >> CompressPriceCheckFiles_Spirit_run.cmd
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
::  @pause

  @call :MESS End Program

  :: Continue with the next Batch File
  \\sghpnas\pos\Poll\Bin\CompressDebitBinRangeFile

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
  @blat %LOG_FILE% -subject "ERROR: CompressPriceCheckFiles_Spirit" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
