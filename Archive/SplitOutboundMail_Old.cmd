::------------------------------------------------------------------------------
:: SplitOutboundMail.cmd
::
:: Created by: Christian Adams
:: Date: 7/18/2002
::
:: Description:
::     This program will split mail files from the mainframe into store mail 
::     files.
::
:: Usage: 
::     SplitOutboundMail
::
:: Dependent programs:
::     SplitMail.exe (Christian Adams) - Splits a mail file from the mainframe
::       into store mail files.
::
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     ConvertMailT.exe (Jeramie Shake) - Converts a Trovato mail file for use
::       by another store.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\SplitOutboundMail.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\SplitOutboundMail.err

  :: Set window title and color
  @Title Split Outbound Mail
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * SplitOutboundMail.cmd       *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Split mail from the mainframe into store mail files.
  @echo.
  @pause

:BUSITELIST
  :: Backup site list.
  @call :MESS Begin backup site list

  if exist E:\Poll\StoreMail\SiteList.txt copy E:\Poll\StoreMail\SiteList.txt E:\Poll\StoreMail\SiteList.bak
  @if errorlevel 1 @call :MESS Fatal error copying E:\Poll\StoreMail\SiteList.txt to E:\Poll\StoreMail\SiteList.bak & goto ERR
  if exist E:\Poll\StoreMail\SiteList.txt del E:\Poll\StoreMail\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting E:\Poll\StoreMail\SiteList.txt & goto ERR

  if exist E:\Poll\StoreMailT\SiteList.txt copy E:\Poll\StoreMailT\SiteList.txt E:\Poll\StoreMailT\SiteList.bak
  @if errorlevel 1 @call :MESS Fatal error copying E:\Poll\StoreMailT\SiteList.txt to E:\Poll\StoreMailT\SiteList.bak & goto ERR
  if exist E:\Poll\StoreMailT\SiteList.txt del E:\Poll\StoreMailT\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting E:\Poll\StoreMailT\SiteList.txt & goto ERR
  if exist E:\Poll\StoreMailT\Temp\SiteList.txt del E:\Poll\StoreMailT\Temp\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting E:\Poll\StoreMailT\Temp\SiteList.txt & goto ERR

  @call :MESS End backup site list

:ADDRESS
  :: Retrieve store address file.
  @call :MESS Begin retrive store address file

  copy \\sgintfinop\ops_shared\sirisftp\pos\address\usa.txt E:\Poll\OutboundT\usa.txt
  @if errorlevel 1 @call :MESS Error copying \\sgintfinop\ops_shared\sirisftp\pos\address\usa.txt to E:\Poll\OutboundT\usa.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrive store address file

:SPLITMAIL
  :: Split mail.
  @call :MESS Begin split mail

  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail1a E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail1a & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail1b E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail1b & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail1c E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail1c & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail1d E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail1d & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail1e E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail1e & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail2a E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail2a & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail2b E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail2b & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail2c E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail2c & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail2d E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail2d & goto ERR
  E:\Poll\Bin\SplitMail.exe E:\Poll\Outbound\Mail2e E:\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\Outbound\Mail2e & goto ERR

  if exist E:\Poll\OutboundT\usa.txt E:\Poll\Bin\SplitMail.exe E:\Poll\OutboundT\Mail.txt E:\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE APPENDFILE=E:\Poll\OutboundT\usa.txt
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\OutboundT\Mail.txt & goto ERR
  if not exist E:\Poll\OutboundT\usa.txt E:\Poll\Bin\SplitMail.exe E:\Poll\OutboundT\Mail.txt E:\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in E:\Poll\OutboundT\Mail.txt & goto ERR

  copy E:\Poll\StoreMailT\Temp\SiteList.txt E:\Poll\StoreMailT
  @if errorlevel 1 @call :MESS Fatal error copying E:\Poll\StoreMailT\Temp\SiteList.txt to E:\Poll\StoreMailT & goto ERR

  @call :MESS End split mail

:COPY538
  :: Copy mail from #538 to #999 and #997.
  @call :MESS Begin copy mail from #538 to #999 and #997

  if exist E:\Poll\StoreMail\Mail00538 copy E:\Poll\StoreMail\Mail00538 E:\Poll\StoreMail\Mail00999
  @if errorlevel 1 @call :MESS Error copying mail from #538 to #999 & set WARNING_FLAG=TRUE

  if exist E:\Poll\StoreMailT\Temp\Mail00538 ConvertMailT E:\Poll\StoreMailT\Temp\Mail00538 00997 E:\Poll\StoreMailT\Temp\Mail00997
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #997 & set WARNING_FLAG=TRUE

  @call :MESS End copy mail from #538 to #999 and #997

:COPYSITELIST
  :: Copy site list to AuditWorks server.
  @call :MESS Begin copy site list to AuditWorks server

  copy E:\Poll\StoreMail\SiteList.txt \\SGINTAW\Sybwork\Spencer\Data
  @if errorlevel 1 @call :MESS Error copying site list to AuditWorks server & set WARNING_FLAG=TRUE

  @call :MESS End copy site list to AuditWorks server

:GETEXCLUDE
  :: Get Translate Exclude file.
  @call :MESS Begin get Translate Exclude file

  if exist \\sgintfinop\ops_shared\sirisftp\consign\consign.dat copy \\sgintfinop\ops_shared\sirisftp\consign\consign.dat E:\Poll\AuditWorks\Translate\exclude.dat
  @if errorlevel 1 @call :MESS Error getting Translate Exclude file & set WARNING_FLAG=TRUE

  @call :MESS End get Translate Exclude file

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
  @Now %1 %2 %3 %4 %5 %6 %7 %8 %9 >> %LOG_FILE%
  @ver > nul
  @echo.
  @Now %1 %2 %3 %4 %5 %6 %7 %8 %9
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
  @blat %LOG_FILE% -subject "ERROR: SplitOutboundMail" -to christian.adams@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
