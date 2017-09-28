::------------------------------------------------------------------------------
:: CompressDebitBinRangeFile.cmd
::
:: Created by: Jeramie Shake
:: Date: 12/04/2006
::
:: Description:
::     This program will compress the Debit Bin Range file for transmittal to the stores. 
::     This file is provided by PaymenTech. Murali receives it and places it in %POLLING%\Data\DebitBinRange.
::
:: Usage: 
::     CompressDebitBinRangeFile
::
:: Dependent programs:
::     7z.exe (7-Zip) - Compresses files.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\CompressDebitBinRangeFile.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CompressDebitBinRangeFile.err

  :: Set window title and color
  @Title Compress Price Check Files
  @Color 0E

  :: Create new log file.
  @echo. > %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * CompressDebitBinRangeFile   *
  @echo *                             *
  @echo * Created by: Jeramie Shake   *
  @echo *******************************

  @echo.
  @echo Compress Debit Bin Range File.
  @echo.
::  @pause
  
:MAIN
  :: Begin Compress Debit Bin Range File.
  @call :MESS Begin Compress Debit Bin Range File

  if not exist %POLLING%\Data\DebitBinRange\debitbinrange.asc @call :MESS %POLLING%\Data\DebitBinRange\debitbinrange.asc does not exist & goto END

  if exist %POLLING%\Data\DebitBinRange\debitbin.dwn del %POLLING%\Data\DebitBinRange\debitbin.dwn
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Data\DebitBinRange\debitbin.dwn & goto ERR

  if exist %POLLING%\Data\DebitBinRange\Poll.zip del %POLLING%\Data\DebitBinRange\Poll.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Data\DebitBinRange\Poll.zip & goto ERR

  if exist %POLLING%\Data\DebitBinRange\U06010205.zip del %POLLING%\Data\DebitBinRange\U06010205.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Data\DebitBinRange\U06010205.zip & goto ERR

  copy %POLLING%\Data\DebitBinRange\debitbinrange.asc %POLLING%\Data\DebitBinRange\debitbin.dwn 
  @if errorlevel 1 @call :MESS Fatal error copying debitbinrange.asc to debitbin.dwn & goto ERR

  "C:\Program Files\7-zip\7z.exe" a %POLLING%\Data\DebitBinRange\Poll.zip %POLLING%\Data\DebitBinRange\debitbin.dwn
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Data\DebitBinRange\debitbin.dwn & goto ERR

  "C:\Program Files\7-Zip\7z.exe" a %POLLING%\Data\DebitBinRange\U06010205.zip %POLLING%\Data\DebitBinRange\Poll.zip
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Data\DebitBinRange\Poll.zip & goto ERR

  %PROG_FOLDER%\Sleep 60

  "%PROG_FOLDER%\fciv.exe" %POLLING%\Data\DebitBinRange\U06010205.zip -wp -sha1 -xml %POLLING%\Data\DebitBinRange\U06010205.zip.xml >> %LOG_FILE%
  @if errorlevel 1 @call :MESS Fatal error hashing %POLLING%\Data\DebitBinRange\U06010205.zip & goto ERR

::Switched to the new archive location on 11/13/2013
::  if exist %POLLING%\Data\DebitBinRange\Zip\U06010205.zip %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\Zip\U06010205.zip %POLLING%\Data\DebitBinRange\Archive TIMESTAMP=TRUE
  if exist %POLLING%\Data\DebitBinRange\Zip\U06010205.zip %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\Zip\U06010205.zip %POLLINGARCHIVE%\DebitBinRange TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error archiving %POLLING%\Data\DebitBinRange\Zip\U06010205.zip & goto ERR

::Switched to the new archive location on 11/13/2013
::  if exist %POLLING%\Data\DebitBinRange\Zip\U06010205.zip.xml %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\Zip\U06010205.zip.xml %POLLING%\Data\DebitBinRange\Archive TIMESTAMP=TRUE
  if exist %POLLING%\Data\DebitBinRange\Zip\U06010205.zip.xml %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\Zip\U06010205.zip.xml %POLLINGARCHIVE%\DebitBinRange TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error archiving %POLLING%\Data\DebitBinRange\Zip\U06010205.zip.xml & goto ERR

  %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\U06010205.zip %POLLING%\Data\DebitBinRange\Zip TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\DebitBinRange\U06010205.zip to %POLLING%\Data\DebitBinRange\Zip & goto ERR

  %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\U06010205.zip.xml %POLLING%\Data\DebitBinRange\Zip TIMESTAMP=FALSE
  @if errorlevel 1 @call :MESS Fatal error moving %POLLING%\Data\DebitBinRange\U06010205.zip.xml to %POLLING%\Data\DebitBinRange\Zip & goto ERR

::Switched to the new archive location on 11/13/2013
::  %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\debitbinrange.asc %POLLING%\Data\DebitBinRange\Archive TIMESTAMP=TRUE
  %PROG_FOLDER%\MoveFiles.exe %POLLING%\Data\DebitBinRange\debitbinrange.asc %POLLINGARCHIVE%\DebitBinRange TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Fatal error archiving %POLLING%\Data\DebitBinRange\debitbinrange.asc & goto ERR

  del %POLLING%\Data\DebitBinRange\debitbin.dwn
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Data\DebitBinRange\debitbin.dwn & goto ERR

  del %POLLING%\Data\DebitBinRange\Poll.zip
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Data\DebitBinRange\Poll.zip & goto ERR

  @call :MESS End Compress Debit Bin Range File

  @goto CHECKWARN

:CHECKWARN
  :: Check warning flag.
  @if %WARNING_FLAG%==TRUE @goto WARN

:END
  :: Program completed successfully.
  @echo.
  @echo.
  @echo Program completed successfully!
  @echo.
  ::@pause

  @call :MESS End Program

  :: Continue with the next Batch File
  %PROG_FOLDER%\EnableTlogProcessing

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
  @blat %LOG_FILE% -subject "ERROR: CompressDebitBinRangeFile" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
