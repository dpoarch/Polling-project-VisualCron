::------------------------------------------------------------------------------
:: FTPUplogs.cmd
::
:: Created by: Jeramie Shake
:: Date: 4/6/2005
::
:: Description:
::     This program will FTP the Uplogs file to the AS400
::     It will also FTP the interstore file to the AS400
::     It will also FTP the Go File to the AS400
::
:: Usage: 
::     FTPUplogs
::
:: Dependent programs:
::     FTP (Windows Utility)
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\FTPUplogs.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\FTPUplogs.err

  :: Set window title and color
  @Title FTP Uplogs
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * FTPUplogs                   *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo FTP Uplogs.
  @echo.
::  @pause

::  @call :MESS FTP the Uplogs File to SGPRODDATA
::  ftp.exe -vins:%PROG_FOLDER%\ftpuplogs_SGPRODDATA.txt >> %LOG_FILE%

::  @call :MESS FTP the interstore File to SGPRODDATA
::  ftp.exe -vins:%PROG_FOLDER%\ftpInterstore.txt >> %LOG_FILE%

  @call :MESS FTP the UplogsTMask File to SGPRODDATA
  ftp.exe -vins:%PROG_FOLDER%\FTPUplogsTMask_SGPRODDATA.txt >> %LOG_FILE%

  :: Wait 60 seconds
  @call :MESS Wait 60 seconds for the file to arrive...
  %PROG_FOLDER%\Sleep 60

  @call :MESS FTP the Go File to SGPRODDATA
  ftp.exe -vins:%PROG_FOLDER%\ftpgofile_SGPRODDATA.txt >> %LOG_FILE%

::  @call :MESS FTP the UplogsTMask File to SGDEVDATA
::  ftp.exe -vins:%PROG_FOLDER%\FTPUplogsTMask_SGDEVDATA.txt >> %LOG_FILE%

  @call :MESS Send Go-File notification email
  @blat %PROG_FOLDER%\FTPGoFile_Confirmation.txt -subject "AutoNotice - TLog Trigger File Was Uploaded" -tf %PROG_FOLDER%\FTPGoFile_Confirmation_EmailAddresses.txt

:: SEND TLOG TO TEST FOR GEORGE T. 
:: ftp.exe -vins:%PROG_FOLDER%\FTPUplogs_SGTESTDATA.txt

  :: Copy flag file.
  ::@call :MESS Begin copy flag file

  ::@if exist %PROG_FOLDER%\PostPolling2.flg @echo Flag file has been copied already!
  ::@if not exist %PROG_FOLDER%\PostPolling2.flg copy %PROG_FOLDER%\Go.txt %PROG_FOLDER%\PostPolling2.flg
  ::@if errorlevel 1 @call :MESS Fatal error copying %PROG_FOLDER%\Go.txt to %PROG_FOLDER%\PostPolling2.flg & goto ERR

  ::@call :MESS End copy flag file

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
  %PROG_FOLDER%\CreateInterfaceFiles

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
  @blat %LOG_FILE% -subject "ERROR: FTPUplogs" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
