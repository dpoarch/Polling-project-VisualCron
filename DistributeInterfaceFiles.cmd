::------------------------------------------------------------------------------
:: DistributeInterfaceFiles.cmd
::
:: Created by: Christian Adams
:: Date: 7/22/2002
::
:: Description:
::     This program will distribute interface files to other servers.
::
:: Usage: 
::     DistributeInterfaceFiles
::
:: Dependent programs:
::     CopyFiles.exe (Christian Adams) - Copies one or more files.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\DistributeInterfaceFiles.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\DistributeInterfaceFiles.err

  :: Set window title and color
  @Title Distribute Interface Files
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo ********************************
  @echo * DistributeInterfaceFiles.cmd *
  @echo *                              *
  @echo * Created by: Christian Adams  *
  @echo ********************************

  @echo.
  @echo Distribute interface files to other servers.
  @echo.
  @pause

:PAYROLL
  :: Distribute Payroll and Employee interface files.
  @call :MESS Begin distribute Payroll and Employee interface files

  :: Copy the Payroll data to the AuditWorks server (except UK).
  if exist %POLLING%\Poll\Interface\HR\pay.dat copy %POLLING%\Poll\Interface\HR\pay.dat \\SGINTAW\Sybwork\Spencer\Data\pay.txt
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\pay.dat to \\SGINTAW\Sybwork\Spencer\Data\pay.txt & set WARNING_FLAG=TRUE

  :: Send a copy of Employee data to Dave Bell for testing.
  if exist %POLLING%\Poll\Interface\HR\emp.dat %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\HR\emp.dat \\sgintmis\sys_share\poshr TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\emp.dat to \\sgintmis\sys_share\poshr & set WARNING_FLAG=TRUE

  :: Copy all Payroll data to the AuditWorks server.
  if exist %POLLING%\Poll\Interface\HR\allpay.dat copy %POLLING%\Poll\Interface\HR\allpay.dat \\SGINTAW\Sybwork\Spencer\Data\Payroll\payhrs.txt
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\allpay.dat to \\SGINTAW\Sybwork\Spencer\Data\Payroll\payhrs.txt & set WARNING_FLAG=TRUE

  :: Copy DAILY Payroll data to the AuditWorks server.
  if exist %POLLING%\Poll\Interface\HR\dailypay.dat copy %POLLING%\Poll\Interface\HR\dailypay.dat \\SGINTAW\Sybwork\Spencer\Data\Payroll_Detail\paydtlhrs.txt
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\dailypay.dat to \\SGINTAW\Sybwork\Spencer\Data\Payroll_Detail\paydtlhrs.txt & set WARNING_FLAG=TRUE

  @call :MESS End distribute Payroll and Employee interface files

:ACK
@goto SHIPSEND
  :: Distribute Acknowledgement interface file.
  @call :MESS Begin distribute Acknowledgment interface file

  :: Send a copy of Acknowledgement data to Accounting.
  if exist %POLLING%\Poll\Interface\Ack\Ack.txt %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\Ack\Ack.txt \\SGINTFINOP\OPS_SHARED\OPS\ACK TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\Ack\Ack.txt to \\SGINTFINOP\OPS_SHARED\OPS\ACK & set WARNING_FLAG=TRUE

  @call :MESS End distribute Acknowledgment interface file

:SHIPSEND
  :: Distribute ShipSend interface file.
  @call :MESS Begin distribute ShipSend interface file

  :: Send a copy of ShipSend data to Merchandise.
  if exist %POLLING%\Poll\Interface\ShipSend\ShipSend.txt %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\ShipSend\ShipSend.txt \\SGINTFINOP\OPS_SHARED\SHIPSEND TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\Ack\Ack.txt to \\SGINTFINOP\OPS_SHARED\SHIPSEND & set WARNING_FLAG=TRUE

  @call :MESS End distribute ShipSend interface file

:REI
  :: Copy UpLogs to NaviStor server.
  @call :MESS Begin copy UpLogs to NaviStor server

  copy %POLLING%\Poll\Upload\Uplogs \\SGIW2KLP\Navinput\nav1\Upload
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Upload\Uplogs to \\SGIW2KLP\Navinput\nav1\Upload & set WARNING_FLAG=TRUE
  copy %PROG_FOLDER%\Go.txt \\SGIW2KLP\Navinput\nav1\Upload
  @if errorlevel 1 @call :MESS Error copying %PROG_FOLDER%\Go.txt to \\SGIW2KLP\Navinput\nav1\Upload & set WARNING_FLAG=TRUE

  @call :MESS End copy UpLogs to NaviStor server

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
  @blat %LOG_FILE% -subject "ERROR: CreateInterfaceFiles" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
