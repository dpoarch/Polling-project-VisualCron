::------------------------------------------------------------------------------
:: CreateInterfaceFiles.cmd
::
:: Created by: Christian Adams
:: Date: 7/22/2002
::
:: Description:
::     This program will create interface files from tlog data.
::
:: Usage: 
::     CreateInterfaceFiles
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
  @set PROG_FOLDER=E:\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\CreateInterfaceFiles.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CreateInterfaceFiles.err

  :: Set window title and color
  @Title Create Interface Files
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * CreateInterfaceFiles.cmd    *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Create interface files from tlog data.
  @echo.
  @pause

:IPLOGS
  :: Check for IPLOGS file.
  @call :MESS Begin check for IPLOGS file
  if not exist E:\Poll\Upload\IpLogs. @call :MESS Fatal error E:\Poll\Upload\IpLogs. does not exist & goto ERR

  @call :MESS End check for IPLOGS file

:PAYROLL
  :: Generate Payroll and Employee interface files.
  @call :MESS Begin generate Payroll and Employee interface files

  :: Extract Employee and Payroll data (excluding UK and stores on Exclude list).
  if exist E:\Poll\Interface\HR\emp.dat del E:\Poll\Interface\HR\emp.dat
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\emp.dat & set WARNING_FLAG=TRUE
  if exist E:\Poll\Interface\HR\pay.dat del E:\Poll\Interface\HR\pay.dat
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\pay.dat & set WARNING_FLAG=TRUE
  E:\Poll\Bin\pullhr.exe E:\Poll\Upload\IpLogs. E:\Poll\Interface\HR\emp.dat E:\Poll\Interface\HR\pay.dat E:\Poll\AuditWorks\Translate\exclude.dat
  @if errorlevel 1 @call :MESS Error executing PULLHR & set WARNING_FLAG=TRUE

  :: Copy the Payroll data to the AuditWorks server (except UK).
  if exist E:\Poll\Interface\HR\pay.dat copy E:\Poll\Interface\HR\pay.dat \\SGINTAW\Sybwork\Spencer\Data\pay.txt
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\HR\pay.dat to \\SGINTAW\Sybwork\Spencer\Data\pay.txt & set WARNING_FLAG=TRUE

  :: Send a copy of Employee data to Dave Bell for testing.
  if exist E:\Poll\Interface\HR\emp.dat E:\Poll\Bin\CopyFiles.exe E:\Poll\Interface\HR\emp.dat \\sgintmis\sys_share\poshr TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\HR\emp.dat to \\sgintmis\sys_share\poshr & set WARNING_FLAG=TRUE

  
  :: Extract Employee and Payroll data and SPLIT for USA and Canada (excluding stores on Exclude list).
  if exist E:\Poll\Interface\HR\ushr.txt del E:\Poll\Interface\HR\ushr.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\ushr.txt & set WARNING_FLAG=TRUE
  if exist E:\Poll\Interface\HR\sgushrs1.txt del E:\Poll\Interface\HR\sgushrs1.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\sgushrs1.txt & set WARNING_FLAG=TRUE
  if exist E:\Poll\Interface\HR\cahr.txt del E:\Poll\Interface\HR\cahr.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\cahr.txt & set WARNING_FLAG=TRUE
  if exist E:\Poll\Interface\HR\sgcanhrs1.txt del E:\Poll\Interface\HR\sgcanhrs1.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\sgcanhrs1.txt & set WARNING_FLAG=TRUE
  E:\Poll\Bin\splthr.exe E:\Poll\Upload\IpLogs. E:\Poll\Interface\HR\ushr.txt E:\Poll\Interface\HR\sgushrs1.txt E:\Poll\Interface\HR\cahr.txt E:\Poll\Interface\HR\sgcanhrs1.txt E:\Poll\AuditWorks\Translate\exclude.dat
  @if errorlevel 1 @call :MESS Error executing SPLTHR & set WARNING_FLAG=TRUE


  :: Extract all Payroll data (including UK).
  if exist E:\Poll\Interface\HR\allpay.dat del E:\Poll\Interface\HR\allpay.dat
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\allpay.dat & set WARNING_FLAG=TRUE
  E:\Poll\Bin\allhr.exe E:\Poll\Upload\Iplogs. E:\Poll\Interface\HR\allpay.dat
  @if errorlevel 1 @call :MESS Error executing ALLHR & set WARNING_FLAG=TRUE

  :: Copy all Payroll data to the AuditWorks server.
  if exist E:\Poll\Interface\HR\allpay.dat copy E:\Poll\Interface\HR\allpay.dat \\SGINTAW\Sybwork\Spencer\Data\Payroll\payhrs.txt
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\HR\allpay.dat to \\SGINTAW\Sybwork\Spencer\Data\Payroll\payhrs.txt & set WARNING_FLAG=TRUE

  :: Extract DAILY Payroll data.
  if exist E:\Poll\Interface\HR\dailypay.dat del E:\Poll\Interface\HR\dailypay.dat
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\HR\dailypay.dat & set WARNING_FLAG=TRUE
  E:\Poll\Bin\dailyhr.exe E:\Poll\Upload\Iplogs. E:\Poll\Interface\HR\dailypay.dat
  @if errorlevel 1 @call :MESS Error executing DAILYHR & set WARNING_FLAG=TRUE

  :: Copy DAILY Payroll data to the AuditWorks server.
  if exist E:\Poll\Interface\HR\dailypay.dat copy E:\Poll\Interface\HR\dailypay.dat \\SGINTAW\Sybwork\Spencer\Data\Payroll_Detail\paydtlhrs.txt
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\HR\dailypay.dat to \\SGINTAW\Sybwork\Spencer\Data\Payroll_Detail\paydtlhrs.txt & set WARNING_FLAG=TRUE

  @call :MESS End generate Payroll and Employee interface files

:ACK
@goto SHIPSEND
  :: Generate Acknowledgement interface file.
  @call :MESS Begin generate Acknowledgment interface file

  if exist E:\Poll\Interface\Ack\Ack.txt del E:\Poll\Interface\Ack\Ack.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\Ack\Ack.txt & set WARNING_FLAG=TRUE
  E:\Poll\Bin\PullAck.exe INPATH=E:\Poll\Upload INFILE=IpLogs. OUTFILE=E:\Poll\Interface\Ack\Ack.txt
  @if errorlevel 1 @call :MESS Error executing PULLACK & set WARNING_FLAG=TRUE

  :: Send a copy of Acknowledgement data to Accounting.
  if exist E:\Poll\Interface\Ack\Ack.txt E:\Poll\Bin\CopyFiles.exe E:\Poll\Interface\Ack\Ack.txt \\SGINTFINOP\OPS_SHARED\OPS\ACK TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\Ack\Ack.txt to \\SGINTFINOP\OPS_SHARED\OPS\ACK & set WARNING_FLAG=TRUE

  @call :MESS End generate Acknowledgment interface file

:SHIPSEND
  :: Generate ShipSend interface file.
  @call :MESS Begin generate ShipSend interface file

  if exist E:\Poll\Interface\ShipSend\ShipSend.txt del E:\Poll\Interface\ShipSend\ShipSend.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\ShipSend\ShipSend.txt & set WARNING_FLAG=TRUE
  E:\Poll\Bin\PullShip.exe INPATH=E:\Poll\Upload INFILE=IpLogs. OUTFILE=E:\Poll\Interface\ShipSend\ShipSend.txt
  @if errorlevel 1 @call :MESS Error executing PULLSHIP & set WARNING_FLAG=TRUE

  :: Send a copy of ShipSend data to Merchandise.
::  if exist E:\Poll\Interface\ShipSend\ShipSend.txt E:\Poll\Bin\CopyFiles.exe E:\Poll\Interface\ShipSend\ShipSend.txt \\SGINTFINOP\OPS_SHARED\SHIPSEND TIMESTAMP=TRUE
::  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\ShipSend\ShipSend.txt to \\SGINTFINOP\OPS_SHARED\SHIPSEND & set WARNING_FLAG=TRUE
  :: Send a copy of ShipSend data to the AuditWorks server.
  if exist E:\Poll\Interface\ShipSend\ShipSend.txt copy E:\Poll\Interface\ShipSend\ShipSend.txt \\Sgintaw\Sybwork\Spencer\Data\ShipSend.txt
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Interface\ShipSend\ShipSend.txt to \\Sgintaw\Sybwork\Spencer\Data & set WARNING_FLAG=TRUE

  @call :MESS End generate ShipSend interface file

:FLASH
  :: Generate Flash interface file.
  @call :MESS Begin generate Flash interface file

  if exist E:\Poll\Interface\Flash.txt del E:\Poll\Interface\Flash.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\Flash.txt & set WARNING_FLAG=TRUE
  if exist E:\Temp\FlshRpt.tmp del E:\Temp\FlshRpt.tmp
  @if errorlevel 1 @call :MESS Error deleting E:\Temp\FlshRpt.tmp & set WARNING_FLAG=TRUE
  if exist E:\Temp\FlshLogs.tmp del E:\Temp\FlshLogs.tmp
  @if errorlevel 1 @call :MESS Error deleting E:\Temp\FlshLogs.tmp & set WARNING_FLAG=TRUE
  copy E:\Poll\Upload\IpLogs E:\Temp\FlshLogs.tmp
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Upload\IpLogs to E:\Temp\FlshLogs.tmp & set WARNING_FLAG=TRUE
  E:\Poll\Bin\POB101 E:\Temp\FlshLogs.tmp E:\Poll\Interface\Flash\Flash.txt E:\Temp\FlshRpt.tmp
  @if errorlevel 1 @call :MESS Error executing POB101 & set WARNING_FLAG=TRUE

  @call :MESS End generate Flash interface file

:ENDS
  :: Generate Ends interface file.
  @call :MESS Begin generate Ends interface file

  :: Create list of stores with Ends files.
  if exist E:\Poll\Interface\Ends\Ends.txt del E:\Poll\Interface\Ends\Ends.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\Ends\Ends.txt & set WARNING_FLAG=TRUE
  E:\Poll\Bin\CheckPoll.exe E:\Poll\Tlog\Ends E:\Poll\Interface\Ends\Ends.txt
  @if errorlevel 1 @call :MESS Error executing CHECKPOLL (ARS) & set WARNING_FLAG=TRUE
  E:\Poll\Bin\CheckPoll.exe E:\Poll\TlogT\Ends E:\Poll\Interface\Ends\Ends.txt
  @if errorlevel 1 @call :MESS Error executing CHECKPOLL (Trovato) & set WARNING_FLAG=TRUE

  @call :MESS Ends generate Ends interface file

:POLLRPT
  :: Generate polling reports.
  @call :MESS Begin generate polling reports

  :: Create lists of stores that polled and failed according to RemoteWare.
::  if exist E:\Poll\Interface\PollRpt\Polled.txt del E:\Poll\Interface\PollRpt\Polled.txt
::  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\PollRpt\Polled.txt & set WARNING_FLAG=TRUE
  if exist E:\Poll\Interface\PollRpt\Failed.txt del E:\Poll\Interface\PollRpt\Failed.txt
  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\PollRpt\Failed.txt & set WARNING_FLAG=TRUE
::  if exist E:\Poll\Interface\PollRpt\PolledStores.txt del E:\Poll\Interface\PollRpt\PolledStores.txt
::  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\PollRpt\PolledStores.txt & set WARNING_FLAG=TRUE
::  if exist E:\Poll\Interface\PollRpt\FailedStores.txt del E:\Poll\Interface\PollRpt\FailedStores.txt
::  @if errorlevel 1 @call :MESS Error deleting E:\Poll\Interface\PollRpt\FailedStores.txt & set WARNING_FLAG=TRUE

::  E:\RWS\System\Rpt_hist -o E:\Poll\Interface\PollRpt\Polled.txt -f E:\Poll\Filters\Polled.flt -c
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter E:\Poll\Filters\Polled.flt & set WARNING_FLAG=TRUE
::  E:\RWS\System\Rpt_hist -o E:\Poll\Interface\PollRpt\Failed.txt -f E:\Poll\Filters\Failed.flt -c
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter E:\Poll\Filters\Failed.flt & set WARNING_FLAG=TRUE
::  E:\RWS\System\Rpt_hist -o E:\Poll\Interface\PollRpt\PolledStores.txt -f E:\Poll\Filters\Polled.flt
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter E:\Poll\Filters\Polled.flt & set WARNING_FLAG=TRUE
::  E:\RWS\System\Rpt_hist -o E:\Poll\Interface\PollRpt\FailedStores.txt -f E:\Poll\Filters\Failed.flt
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter E:\Poll\Filters\Failed.flt & set WARNING_FLAG=TRUE

  bcp "SELECT * FROM RWLog_Poll..Failed_vw" queryout E:\Poll\Interface\Pollrpt\failed.txt -S sgintsql\prod -U RWLogAdmin -P rebellion -c -t","
  @if errorlevel 1 @call :MESS Error generating Failed report & set WARNING_FLAG=TRUE


  @call :MESS End generate polling reports

:REI
  :: Copy IpLogs to NaviStor server.
  @call :MESS Begin copy IpLogs to NaviStor server

  copy E:\Poll\Upload\IpLogs. \\SGIW2KLP\Navinput\nav1\Upload\Uplogs.
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Upload\Iplogs. to \\SGIW2KLP\Navinput\nav1\Upload\Uplogs. & set WARNING_FLAG=TRUE
  copy E:\Poll\Bin\Go.txt \\SGIW2KLP\Navinput\nav1\Upload
  @if errorlevel 1 @call :MESS Error copying E:\Poll\Bin\Go.txt to \\SGIW2KLP\Navinput\nav1\Upload & set WARNING_FLAG=TRUE

  @call :MESS End copy IpLogs to NaviStor server

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
