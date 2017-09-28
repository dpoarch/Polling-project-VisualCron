::------------------------------------------------------------------------------
:: CreateInterfaceFiles.cmd
::
:: Created by: Christian Adams
:: Date: 7/22/2002
::
:: Edited by: Jeramie Shake
:: Date: 1/8/2007
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
::     CopyFilesB.exe (Jeramie Shake) - Copies one file.
::     ExtractPayrollFromTlogT.exe (Jeramie Shake) - Pulls Payroll data out of Trovato Tlogs
::     PullUG.exe (Jeramie Shake) - Pulls Underground data out of Trovato Tlogs
::     PullShipT.exe (Jeramie Shake) - Pulls Ship Send data out of trovato Tlogs
::     ScrubPayrollHoursFile.exe (Jeramie Shake) - Processes the ADP Formatted Payroll Hours File, and seperates dups and non-dups into seperate files
::
::     SpltTRhr.exe (Corky) - Pulls payroll data out of trovato tlogs
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
::  @pause

:DELETEFLAG
  :: Delete flag file.
  ::@call :MESS Begin delete flag file
  ::@call :MESS Waiting 10 seconds...
  ::%PROG_FOLDER%\sleep 10

  ::@if not exist %PROG_FOLDER%\PostPolling2.flg @echo Flag file has been deleted already!
  ::@if exist %PROG_FOLDER%\PostPolling2.flg del %PROG_FOLDER%\PostPolling2.flg
  ::@if errorlevel 1 @call :MESS Fatal error deleting %PROG_FOLDER%\PostPolling2.flg & goto ERR

  ::@call :MESS End delete flag file

:IPLOGS
  :: Check for IPLOGS file.
::  @call :MESS Begin check for IPLOGS file

::We don't care about iplogs as of 11/10/2010
::  if not exist %POLLING%\Poll\Upload\IpLogs. @call :MESS Fatal error %POLLING%\Poll\Upload\IpLogs. does not exist & goto ERR
::  if not exist %POLLING%\Poll\Upload\IpLogsP. @call :MESS Fatal error %POLLING%\Poll\Upload\IpLogsP. does not exist & goto ERR

::  @call :MESS End check for IPLOGS file

:PAYROLL
  :: Generate Payroll and Employee interface files.
  @call :MESS Begin generate Payroll and Employee interface files

  :: Extract Employee and Payroll data (excluding UK and stores on Exclude list, and including stores in Excludep).
  ::if exist %POLLING%\Poll\Interface\HR\emp.dat del %POLLING%\Poll\Interface\HR\emp.dat
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\emp.dat & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Poll\Interface\HR\pay.dat del %POLLING%\Poll\Interface\HR\pay.dat
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\pay.dat & set WARNING_FLAG=TRUE
  ::%PROG_FOLDER%\pullhr.exe %POLLING%\Poll\Upload\IpLogsP. %POLLING%\Poll\Interface\HR\emp.dat %POLLING%\Poll\Interface\HR\pay.dat %POLLING%\Poll\AuditWorks\Translate\exclude.dat
  ::@if errorlevel 1 @call :MESS Error executing PULLHR & set WARNING_FLAG=TRUE

  :: Extract Employee and Payroll data and SPLIT for USA and Canada (excluding stores on Exclude list, and including stores in Excludep).
  if exist %POLLING%\Poll\Interface\HR\ushr_old.txt del %POLLING%\Poll\Interface\HR\ushr_old.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\ushr_old.txt & set WARNING_FLAG=TRUE
  
  if exist %POLLING%\Poll\Interface\HR\sgushrs1_Old.txt del %POLLING%\Poll\Interface\HR\sgushrs1_Old.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\sgushrs1_Old.txt & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\Interface\HR\sgushrs1_Old_Corky.txt del %POLLING%\Poll\Interface\HR\sgushrs1_Old_Corky.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\sgushrs1_Old_Corky.txt & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\Interface\HR\sgushrs1_Old_Bad.txt del %POLLING%\Poll\Interface\HR\sgushrs1_Old_Bad.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\sgushrs1_Old_Bad.txt & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\Interface\HR\cahr_old.txt del %POLLING%\Poll\Interface\HR\cahr_old.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\cahr_old.txt & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\Interface\HR\sgcanhrs1_Old.txt del %POLLING%\Poll\Interface\HR\sgcanhrs1_Old.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\sgcanhrs1_Old.txt & set WARNING_FLAG=TRUE

  ::%PROG_FOLDER%\splthr.exe %POLLING%\Poll\Upload\IpLogsP. %POLLING%\Poll\Interface\HR\ushr_old.txt %POLLING%\Poll\Interface\HR\sgushrs1.txt %POLLING%\Poll\Interface\HR\cahr_old.txt %POLLING%\Poll\Interface\HR\sgcanhrs1.txt %POLLING%\Poll\AuditWorks\Translate\exclude.dat
  ::%PROG_FOLDER%\spltTRhr.exe %POLLING%\Poll\Upload\IpLogsP. %POLLING%\Poll\Interface\HR\ushr_old.txt %POLLING%\Poll\Interface\HR\sgushrs1_Old_Corky.txt %POLLING%\Poll\Interface\HR\cahr_old.txt %POLLING%\Poll\Interface\HR\sgcanhrs1_Old.txt %POLLING%\Poll\AuditWorks\Translate\exclude.dat
  ::@if errorlevel 1 @call :MESS Error executing SPLTTRHR & set WARNING_FLAG=TRUE

  ::Scrub The Corky file to find Dups. Dups go in Bad. Blat the Bad file to Terri Rogers.
  ::%PROG_FOLDER%\ScrubPayrollHoursFile.exe %POLLING%\Poll\Interface\HR\sgushrs1_Old_Corky.txt %POLLING%\Poll\Interface\HR\sgushrs1_Old.txt %POLLING%\Poll\Interface\HR\sgushrs1_Old_Bad.txt
  ::@if errorlevel 1 @call :MESS Error executing ScrubPayrollHoursFile & set WARNING_FLAG=TRUE

  :: Copy the Payroll data to the AuditWorks server.
  ::if exist %POLLING%\Poll\Interface\HR\sgushrs1.txt copy %POLLING%\Poll\Interface\HR\sgushrs1.txt \\SGAW\Sybwork\Spencer\Data\pay.txt
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\sgushrs1.txt to \\SGAW\Sybwork\Spencer\Data\pay.txt & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Poll\Interface\HR\sgcanhrs1.txt copy %POLLING%\Poll\Interface\HR\sgcanhrs1.txt \\SGAW\Sybwork\Spencer\Data\capay.txt
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\sgcanhrs1.txt to \\SGAW\Sybwork\Spencer\Data\capay.txt & set WARNING_FLAG=TRUE

  :: Copy the Payroll data to Sgintmis for processing by the SSDB.
  ::if exist %POLLING%\Poll\Interface\HR\sgushrs1.txt %PROG_FOLDER%\CopyFilesB.exe %POLLING%\Poll\Interface\HR\sgushrs1.txt \\sgintmis\sys_share\pos\stores~1\hr sgushrs1.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\sgushrs1.txt to \\sgintmis\sys_share\pos\store status\hr & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Poll\Interface\HR\sgcanhrs1.txt %PROG_FOLDER%\CopyFilesB.exe %POLLING%\Poll\Interface\HR\sgcanhrs1.txt \\sgintmis\sys_share\pos\stores~1\hr sgcanhrs1.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\sgcanhrs1.txt to \\sgintmis\sys_share\pos\store status\hr & set WARNING_FLAG=TRUE

  :: Copy the Payroll data to Payroll Dept for review
  ::if exist %POLLING%\Poll\Interface\HR\sgushrs1.txt %PROG_FOLDER%\CopyFilesB.exe %POLLING%\Poll\Interface\HR\sgushrs1.txt \\sgintfinop\ops_shared\payroll\dailypolling sgushrs1.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\sgushrs1.txt to \\sgintfinop\ops_shared\payroll\dailypolling & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Poll\Interface\HR\sgcanhrs1.txt %PROG_FOLDER%\CopyFilesB.exe %POLLING%\Poll\Interface\HR\sgcanhrs1.txt \\sgintfinop\ops_shared\payroll\dailypolling sgcanhrs1.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\sgcanhrs1.txt to \\sgintfinop\ops_shared\payroll\dailypolling & set WARNING_FLAG=TRUE

  :: Send a copy of Employee data to Dave Bell for testing.

  if exist %POLLING%\Poll\Interface\HR\ushr.txt %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\HR\ushr.txt \\sgintmis\sys_share\poshr TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\ushr.txt to \\sgintmis\sys_share\poshr & set WARNING_FLAG=TRUE
  if exist %POLLING%\Poll\Interface\HR\cahr.txt %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\HR\cahr.txt \\sgintmis\sys_share\poshr TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\cahr.txt to \\sgintmis\sys_share\poshr & set WARNING_FLAG=TRUE

  :: Extract all Payroll Data from Trovato IPlogsP
  ::if exist %POLLING%\Poll\Interface\HR\payrollUS.txt del %POLLING%\Poll\Interface\HR\payrollUS.txt
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\payrollUS.txt & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Poll\Interface\HR\payrollCA.txt del %POLLING%\Poll\Interface\HR\payrollCA.txt
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\payrollCA.txt & set WARNING_FLAG=TRUE
  ::%PROG_FOLDER%\ExtractPayrollFromTlogT.exe %POLLING%\Poll\Upload\IpLogsP %POLLING%\Poll\Interface\HR\payrollUS.txt %POLLING%\Poll\Interface\HR\payrollCA.txt
  ::@if errorlevel 1 @call :MESS Error executing ExtractPayrollFromTlogT & set WARNING_FLAG=TRUE

  :: Copy Canada Payroll Data to Import Location
  ::if exist %POLLING%\Poll\Interface\HR\payrollCA.txt %PROG_FOLDER%\CopyFilesB %POLLING%\Poll\Interface\HR\payrollCA.txt \\SGINTMIS\sys_share\pos\CanadaHR\Data cahrT.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\payrollCA.txt to \\SGINTMIS\sys_share\pos\CanadaHR\Data & set WARNING_FLAG=TRUE

  :: Copy Payroll Data to sgsql for processing.
  ::if exist %POLLING%\Poll\Interface\HR\payrollUS.txt %PROG_FOLDER%\CopyFilesB.exe %POLLING%\Poll\Interface\HR\payrollUS.txt \\sgsql\FileTransfer\PayrollData payrollUS.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\payrollUS.txt to \\sgsql\FileTransfer\PayrollData & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Poll\Interface\HR\payrollCA.txt %PROG_FOLDER%\CopyFilesB.exe %POLLING%\Poll\Interface\HR\payrollCA.txt \\sgsql\FileTransfer\PayrollData payrollCA.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\payrollCA.txt to \\sgsql\FileTransfer\PayrollData & set WARNING_FLAG=TRUE

  :: Extract all Payroll data (including UK and stores in Excludep).
  ::if exist %POLLING%\Poll\Interface\HR\allpay.dat del %POLLING%\Poll\Interface\HR\allpay.dat
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\allpay.dat & set WARNING_FLAG=TRUE
  ::%PROG_FOLDER%\allhr.exe %POLLING%\Poll\Upload\IplogsP. %POLLING%\Poll\Interface\HR\allpay.dat
  ::@if errorlevel 1 @call :MESS Error executing ALLHR & set WARNING_FLAG=TRUE

  :: Copy all Payroll data to the AuditWorks server.
  ::if exist %POLLING%\Poll\Interface\HR\allpay.dat copy %POLLING%\Poll\Interface\HR\allpay.dat \\SGAW\Sybwork\Spencer\Data\Payroll\payhrs.txt
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\allpay.dat to \\SGAW\Sybwork\Spencer\Data\Payroll\payhrs.txt & set WARNING_FLAG=TRUE

  :: Extract DAILY Payroll data.
  ::if exist %POLLING%\Poll\Interface\HR\dailypay.dat del %POLLING%\Poll\Interface\HR\dailypay.dat
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\HR\dailypay.dat & set WARNING_FLAG=TRUE
  ::%PROG_FOLDER%\dailyhr.exe %POLLING%\Poll\Upload\IplogsP. %POLLING%\Poll\Interface\HR\dailypay.dat
  ::@if errorlevel 1 @call :MESS Error executing DAILYHR & set WARNING_FLAG=TRUE

  :: Copy DAILY Payroll data to the AuditWorks server.
  ::if exist %POLLING%\Poll\Interface\HR\dailypay.dat copy %POLLING%\Poll\Interface\HR\dailypay.dat \\SGAW\Sybwork\Spencer\Data\Payroll_Detail\paydtlhrs.txt
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\HR\dailypay.dat to \\SGAW\Sybwork\Spencer\Data\Payroll_Detail\paydtlhrs.txt & set WARNING_FLAG=TRUE

  @call :MESS End generate Payroll and Employee interface files

:ACK
@goto SHIPSEND
  :: Generate Acknowledgement interface file.
  @call :MESS Begin generate Acknowledgment interface file

  if exist %POLLING%\Poll\Interface\Ack\Ack.txt del %POLLING%\Poll\Interface\Ack\Ack.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\Ack\Ack.txt & set WARNING_FLAG=TRUE
  %PROG_FOLDER%\PullAck.exe INPATH=%POLLING%\Poll\Upload INFILE=IpLogs. OUTFILE=%POLLING%\Poll\Interface\Ack\Ack.txt
  @if errorlevel 1 @call :MESS Error executing PULLACK & set WARNING_FLAG=TRUE

  :: Send a copy of Acknowledgement data to Accounting.
  if exist %POLLING%\Poll\Interface\Ack\Ack.txt %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\Ack\Ack.txt \\sgicorp\spencergifts\operations\ack TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\Ack\Ack.txt to \\sgicorp\spencergifts\operations\ack & set WARNING_FLAG=TRUE

  @call :MESS End generate Acknowledgment interface file

:SHIPSEND
  :: Generate ShipSend interface file.
  ::@call :MESS Begin generate ShipSend interface files

  ::if exist %POLLING%\Poll\Interface\ShipSend\ShipSend.txt del %POLLING%\Poll\Interface\ShipSend\ShipSend.txt
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\ShipSend\ShipSend.txt & set WARNING_FLAG=TRUE
  ::%PROG_FOLDER%\PullShip.exe INPATH=%POLLING%\Poll\Upload INFILE=IpLogs. OUTFILE=%POLLING%\Poll\Interface\ShipSend\ShipSend.txt
  ::@if errorlevel 1 @call :MESS Error executing PULLSHIP & set WARNING_FLAG=TRUE

  :: Send a copy of ShipSend data to Merchandise.
  ::if exist %POLLING%\Poll\Interface\ShipSend\ShipSend.txt %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Interface\ShipSend\ShipSend.txt \\SGINTFINOP\OPS_SHARED\SHIPSEND TIMESTAMP=TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\ShipSend\ShipSend.txt to \\SGINTFINOP\OPS_SHARED\SHIPSEND & set WARNING_FLAG=TRUE
  :: Send a copy of ShipSend data to the AuditWorks server.
  ::if exist %POLLING%\Poll\Interface\ShipSend\ShipSend.txt copy %POLLING%\Poll\Interface\ShipSend\ShipSend.txt \\SGAW\Sybwork\Spencer\Data\ShipSend.txt
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\ShipSend\ShipSend.txt to \\SGAW\Sybwork\Spencer\Data & set WARNING_FLAG=TRUE

  ::Jeramie commented this section out on 1/18/2010 per Gene Sias
  ::if exist %POLLING%\Poll\Interface\ShipSend\ShipSendT.txt del %POLLING%\Poll\Interface\ShipSend\ShipSendT.txt
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\ShipSend\ShipSendT.txt & set WARNING_FLAG=TRUE
  ::C:\PollingApps\PullShipT.exe %POLLING%\Poll\Upload\IpLogsT %POLLING%\Poll\Interface\ShipSend ShipSendT.txt
  ::@if errorlevel 1 @call :MESS Error executing PULLSHIP & set WARNING_FLAG=TRUE

  ::Jeramie commented this section out on 1/18/2010 per Gene Sias
  :: Copy ShipSendT Data to Import Location
  ::if exist %POLLING%\Poll\Interface\ShipSend\ShipSendT.txt C:\PollingApps\CopyFilesB.exe %POLLING%\Poll\Interface\ShipSend\ShipSendT.txt \\SGINTMIS\sys_share\pos\ShipSend\Data ShipSendT.txt TRUE
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\ShipSend\ShipSendT.txt to \\SGINTMIS\sys_share\pos\ShipSend\Data & set WARNING_FLAG=TRUE

  ::@call :MESS End generate ShipSend interface files

:FLASH
  :: Generate Flash interface file.
  ::this doesn't do anything. Turned off as of 11/11/2010
  ::@call :MESS Begin generate Flash interface file

  ::if exist %POLLING%\Poll\Interface\Flash.txt del %POLLING%\Poll\Interface\Flash.txt
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\Flash.txt & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Temp\FlshRpt.tmp del %POLLING%\Temp\FlshRpt.tmp
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Temp\FlshRpt.tmp & set WARNING_FLAG=TRUE
  ::if exist %POLLING%\Temp\FlshLogs.tmp del %POLLING%\Temp\FlshLogs.tmp
  ::@if errorlevel 1 @call :MESS Error deleting %POLLING%\Temp\FlshLogs.tmp & set WARNING_FLAG=TRUE
  ::copy %POLLING%\Poll\Upload\IpLogs %POLLING%\Temp\FlshLogs.tmp
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Upload\IpLogs to %POLLING%\Temp\FlshLogs.tmp & set WARNING_FLAG=TRUE
  ::%PROG_FOLDER%\POB101 %POLLING%\Temp\FlshLogs.tmp %POLLING%\Poll\Interface\Flash\Flash.txt %POLLING%\Temp\FlshRpt.tmp
  ::@if errorlevel 1 @call :MESS Error executing POB101 & set WARNING_FLAG=TRUE

  ::@call :MESS End generate Flash interface file

:ENDS
  :: Generate Ends interface file.
  @call :MESS Begin generate Ends interface file

  :: Create list of stores with Ends files.
  if exist %POLLING%\Poll\Interface\Ends\Ends.txt del %POLLING%\Poll\Interface\Ends\Ends.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\Ends\Ends.txt & set WARNING_FLAG=TRUE
  %PROG_FOLDER%\CheckPoll.exe %POLLING%\Poll\Tlog\Ends %POLLING%\Poll\Interface\Ends\Ends.txt
  @if errorlevel 1 @call :MESS Error executing CHECKPOLL (ARS) & set WARNING_FLAG=TRUE
  %PROG_FOLDER%\CheckPoll.exe %POLLING%\Poll\TlogT\Ends %POLLING%\Poll\Interface\Ends\Ends.txt
  @if errorlevel 1 @call :MESS Error executing CHECKPOLL (Trovato) & set WARNING_FLAG=TRUE

  @call :MESS Ends generate Ends interface file

:POLLRPT
  :: Generate polling reports.
  @call :MESS Begin generate polling reports

  :: Create lists of stores that polled and failed according to RemoteWare.
::  if exist %POLLING%\Poll\Interface\PollRpt\Polled.txt del %POLLING%\Poll\Interface\PollRpt\Polled.txt
::  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\PollRpt\Polled.txt & set WARNING_FLAG=TRUE
  if exist %POLLING%\Poll\Interface\PollRpt\Failed.txt del %POLLING%\Poll\Interface\PollRpt\Failed.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\PollRpt\Failed.txt & set WARNING_FLAG=TRUE
::  if exist %POLLING%\Poll\Interface\PollRpt\PolledStores.txt del %POLLING%\Poll\Interface\PollRpt\PolledStores.txt
::  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\PollRpt\PolledStores.txt & set WARNING_FLAG=TRUE
::  if exist %POLLING%\Poll\Interface\PollRpt\FailedStores.txt del %POLLING%\Poll\Interface\PollRpt\FailedStores.txt
::  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\PollRpt\FailedStores.txt & set WARNING_FLAG=TRUE

::  C:\RWS\System\Rpt_hist -o %POLLING%\Poll\Interface\PollRpt\Polled.txt -f %POLLING%\Poll\Filters\Polled.flt -c
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter %POLLING%\Poll\Filters\Polled.flt & set WARNING_FLAG=TRUE
::  C:\RWS\System\Rpt_hist -o %POLLING%\Poll\Interface\PollRpt\Failed.txt -f %POLLING%\Poll\Filters\Failed.flt -c
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter %POLLING%\Poll\Filters\Failed.flt & set WARNING_FLAG=TRUE
::  C:\RWS\System\Rpt_hist -o %POLLING%\Poll\Interface\PollRpt\PolledStores.txt -f %POLLING%\Poll\Filters\Polled.flt
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter %POLLING%\Poll\Filters\Polled.flt & set WARNING_FLAG=TRUE
::  C:\RWS\System\Rpt_hist -o %POLLING%\Poll\Interface\PollRpt\FailedStores.txt -f %POLLING%\Poll\Filters\Failed.flt
::  @if errorlevel 1 @call :MESS Error executing RPT_HIST with using filter %POLLING%\Poll\Filters\Failed.flt & set WARNING_FLAG=TRUE

::  bcp "SELECT * FROM RWLog_Poll..Failed_vw" queryout %POLLING%\Poll\Interface\Pollrpt\failed.txt -S sgintsql\prod -U RWLogAdmin -P rebellion -c -t","
::  @if errorlevel 1 @call :MESS Error generating Failed report & set WARNING_FLAG=TRUE


  @call :MESS End generate polling reports

:REI
  :: Copy IpLogs to NaviStor server.
  @call :MESS Begin copy IpLogs to NaviStor server

  copy %POLLING%\Poll\Upload\IpLogsT. \\sgapp\NavInput\nav1\Upload\IplogsT.
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Upload\IplogsT. to \\sgapp\NavInput\nav1\Upload\IplogsT. & set WARNING_FLAG=TRUE
  copy %PROG_FOLDER%\Go.txt \\sgapp\NavInput\nav1\Upload
  @if errorlevel 1 @call :MESS Error copying %PROG_FOLDER%\Go.txt to \\sgapp\NavInput\nav1\Upload & set WARNING_FLAG=TRUE

  %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\Upload\IpLogsT \\sgapp\tlogimport\tlogs TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Upload\IplogsT. to \\sgapp\tlogimport\tlogs  & set WARNING_FLAG=TRUE
  copy %PROG_FOLDER%\Go.txt \\sgapp\tlogimport\tlogs\go.flg
  @if errorlevel 1 @call :MESS Error copying %PROG_FOLDER%\Go.txt to \\sgapp\tlogimport\tlogs\go.flg & set WARNING_FLAG=TRUE

  @call :MESS End copy IpLogs to NaviStor server

:UG
  :: Extract Underground Data from Trovato IPlogsT
  @call :MESS Begin extract Underground Data

  if exist %POLLING%\Poll\Interface\Undrgrnd\ug.txt del %POLLING%\Poll\Interface\Undrgrnd\ug.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Poll\Interface\Undrgrnd\ug.txt & set WARNING_FLAG=TRUE

  ::@call :MESS Wait 15 seconds for processing
  ::%PROG_FOLDER%\Sleep 15  

  C:\PollingApps\PullUG.exe %POLLING%\Poll\Upload\IpLogsT %POLLING%\Poll\Interface\Undrgrnd\ug.txt
  @if errorlevel 1 @call :MESS Error executing PULLUG & set WARNING_FLAG=TRUE

  ::@call :MESS Wait 30 seconds for processing
  ::%PROG_FOLDER%\Sleep 30

  :: Copy Underground Data to Programming's Location
  ::if exist %POLLING%\Poll\Interface\Undrgrnd\ug.txt CopyFiles %POLLING%\Poll\Interface\Undrgrnd\ug.txt \\SGINTSQL\TLOG_DATA
  ::@if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\Interface\Undrgrnd\ug.txt to \\SGINTSQL\TLOG_DATA & goto EOF

  @call :MESS End extract Underground Data

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
  %PROG_FOLDER%\ArchivePollingData

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
  @blat %LOG_FILE% -subject "ERROR: CreateInterfaceFiles" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
