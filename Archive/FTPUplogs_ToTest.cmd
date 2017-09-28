::------------------------------------------------------------------------------
:: FTPUplogs.cmd
::
:: Created by: Jeramie Shake
:: Date: 4/6/2005
::
:: Description:
::     This program will FTP the Uplogs file to the AS400 - TEST FOLDER
::
:: Usage: 
::     FTPUplogs_Test
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
  @set PROG_FOLDER=\\sghpnas\pos\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\FTPUplogs_Test.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\FTPUplogs_Test.err

  :: Set window title and color
  @Title FTP Uplogs - Test
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * FTPUplogs - To Test         *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo FTP Uplogs - to test.
  @echo.
  @pause

ftp.exe -vins:ftpuplogs_SGTESTDATA.txt

::@call :MESS Wait 60 seconds for the file to arrive...
::\\sghpnas\pos\Poll\Bin\Sleep 60

::ftp.exe -vins:ftpgofile_SGTESTDATA.txt
::@blat \\sghpnas\pos\Poll\Bin\FTPGoFile_Confirmation.txt -subject "AutoNotice - TLog Trigger File Was Uploaded" -tf \\sghpnas\pos\Poll\Bin\FTPGoFile_Confirmation_EmailAddresses.txt

:END
  :: Program completed successfully.
  @echo.
  @echo.
  @echo Program completed successfully!
  @echo.
  @pause

  @call :MESS End Program

  :: Continue with the next Batch File
  ::\\sghpnas\pos\Poll\Bin\CreateInterfaceFiles

  @goto :EOF

:MESS
  :: Write message to log file and screen.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9 >> %LOG_FILE%
  @ver > nul
  @echo.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9
  @ver > nul
  @goto :EOF