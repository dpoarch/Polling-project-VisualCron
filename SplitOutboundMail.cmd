::------------------------------------------------------------------------------
:: SplitOutboundMail.cmd
::
:: Created by: Christian Adams
:: Date: 7/18/2002
::
:: Modified By: Jeramie Shake
:: Date: 12/1/2005
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
::     DuplicateFile.exe (Jeramie Shake) - If provided a text file, will copy
::       every filename from ColumnA to the filename in ColumnB.
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
::  @pause

:DELETEFLAG
  ::Delete the SMTPMail.done flag
  if exist %POLLING%\Poll\StoreMailT_Append\smtpmail.done del %POLLING%\Poll\StoreMailT_Append\smtpmail.done
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMailT_Append\smtpmail.done & goto ERR

:BUSITELIST
  :: Backup site list.
  @call :MESS Begin backup site list

  if exist %POLLING%\Poll\StoreMail\SiteList.txt copy %POLLING%\Poll\StoreMail\SiteList.txt %POLLING%\Poll\StoreMail\SiteList.bak
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\StoreMail\SiteList.txt to %POLLING%\Poll\StoreMail\SiteList.bak & goto ERR
  if exist %POLLING%\Poll\StoreMail\SiteList.txt del %POLLING%\Poll\StoreMail\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMail\SiteList.txt & goto ERR

  if exist %POLLING%\Poll\StoreMailT\SiteList.txt copy %POLLING%\Poll\StoreMailT\SiteList.txt %POLLING%\Poll\StoreMailT\SiteList.bak
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\StoreMailT\SiteList.txt to %POLLING%\Poll\StoreMailT\SiteList.bak & goto ERR
  if exist %POLLING%\Poll\StoreMailT\SiteList.txt del %POLLING%\Poll\StoreMailT\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMailT\SiteList.txt & goto ERR
  if exist %POLLING%\Poll\StoreMailT\Temp\SiteList.txt del %POLLING%\Poll\StoreMailT\Temp\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMailT\Temp\SiteList.txt & goto ERR

  @call :MESS End backup site list

:ADDRESS
  :: Retrieve store address file.
  @call :MESS Begin retrive store address file

  if exist %POLLING%\Poll\OutboundT\usa.txt del %POLLING%\Poll\OutboundT\usa.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\usa.txt & goto ERR
  copy \\sgicorp\spencergifts\SIRIS\sirisftp\pos\address\usa.txt %POLLING%\Poll\OutboundT\usa.txt
  ::copy %PROG_FOLDER%\maildone.txt %POLLING%\Poll\OutboundT\usa.txt
  @if errorlevel 1 @call :MESS Error copying \\sgicorp\spencergifts\SIRIS\sirisftp\pos\address\usa.txt to %POLLING%\Poll\OutboundT\usa.txt & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\OutboundT\update.txt del %POLLING%\Poll\OutboundT\update.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\update.txt & goto ERR
  copy \\sgicorp\spencergifts\SIRIS\sirisftp\pos\address\update.txt %POLLING%\Poll\OutboundT\update.txt
  ::copy %PROG_FOLDER%\maildone.txt %POLLING%\Poll\OutboundT\update.txt
  @if errorlevel 1 @call :MESS Error copying \\sgicorp\spencergifts\SIRIS\sirisftp\pos\address\update.txt to %POLLING%\Poll\OutboundT\update.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrive store address file

:STORETRAN
  :: Retrieve interstore transfers file.
  @call :MESS Begin retrive interstore transfers file

  if not exist "\\sgicorp\spencergifts\SIRIS\SIRISFTP\POS\Store Transfer\StoreTransfer.txt" @call :MESS Fatal error \\sgicorp\spencergifts\SIRIS\SIRISFTP\POS\Store Transfer\StoreTransfer.txt does not exist & goto ERR

  copy "\\sgicorp\spencergifts\SIRIS\SIRISFTP\POS\Store Transfer\StoreTransfer.txt" %POLLING%\Poll\OutboundT\StoreTransfer.txt
  ::copy %PROG_FOLDER%\maildone.txt %POLLING%\Poll\OutboundT\StoreTransfer.txt
  @if errorlevel 1 @call :MESS Error copying \\sgicorp\spencergifts\SIRIS\SIRISFTP\POS\Store Transfer\StoreTransfer.txt to %POLLING%\Poll\OutboundT\StoreTransfer.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrive interstore transfers file

:SMTPMAIL
  :: Retrieve smtpmail file.
  @call :MESS Begin retrieve smtpmail file

  if not exist %POLLING%\Poll\StoreMailT_Append\SmtpMail.txt @call :MESS Fatal error %POLLING%\Poll\StoreMailT_Append\SmtpMail.txt does not exist & goto ERR

  copy %POLLING%\Poll\StoreMailT_Append\SmtpMail.txt %POLLING%\Poll\OutboundT\SmtpMail.txt
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\StoreMailT_Append\SmtpMail.txt to %POLLING%\Poll\OutboundT\SmtpMail.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrieve smtpmail file

:COPYSMTPMAIL
  ::Copies the smtpmail.txt to Programming for Reference
  @call :MESS Begin copy smtpmail.txt to programming
  
  %PROG_FOLDER%\CopyFiles.exe %POLLING%\Poll\OutboundT\SmtpMail.txt \\sgsql\FileSave\SmtpMailBackup TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying %POLLING%\Poll\OutboundT\SmtpMail.txt to \\sgsql\FileSave\SmtpMailBackup & set WARNING_FLAG=TRUE

  @call :MESS End copy smtpmail.txt to programming

:UNZIP
  ::Unzips the mail file ftp'd from the AS400
  @call :MESS Begin unzip mail.zip file

  ::If mail.txt file already exists, delete it
  if exist %POLLING%\Poll\OutboundT\Mail.txt del %POLLING%\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  ::Unzip mail.zip
  "C:\Program Files\7-zip\7z.exe" e %POLLING%\Poll\OutboundT\mail.zip -o%POLLING%\Poll\OutboundT
  @if errorlevel 1 @call :MESS Fatal error unzipping %POLLING%\Poll\OutboundT\mail.zip & goto ERR

  @call :MESS End unzip mail.zip file

:APPEND
  :: Append files to the Trovato Mail File

  @call :MESS begin Restore original mail file
  :: If modified mail files exist, delete them

  if exist %POLLING%\Poll\OutboundT\Mail_original.txt del %POLLING%\Poll\OutboundT\Mail_original.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail_original.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\Mail_modified1.txt del %POLLING%\Poll\OutboundT\Mail_modified1.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail_modified1.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\Mail_modified2.txt del %POLLING%\Poll\OutboundT\Mail_modified2.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail_modified2.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\Mail_modified3.txt del %POLLING%\Poll\OutboundT\Mail_modified3.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail_modified3.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\Mail_modified4.txt del %POLLING%\Poll\OutboundT\Mail_modified4.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail_modified4.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\Mail_modified5.txt del %POLLING%\Poll\OutboundT\Mail_modified5.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\OutboundT\Mail_modified5.txt & goto ERR

  @call :MESS end restore original mail file




  @call :MESS Begin appending StoreTransfer.txt

  rename %POLLING%\Poll\OutboundT\Mail.txt Mail_original.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming %POLLING%\Poll\OutboundT\Mail.txt to Mail_original.txt & goto ERR

  copy %POLLING%\Poll\OutboundT\Mail_original.txt /B + %POLLING%\Poll\OutboundT\StoreTransfer.txt /B %POLLING%\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending %POLLING%\Poll\OutboundT\Mail_original.txt and %POLLING%\Poll\OutboundT\StoreTransfer.txt to %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending StoreTransfer.txt




  @call :MESS Begin appending ShipSend.txt

  :: Force error if shipsend.txt doesn't exist
  :: !!!!The promotion is over so the following lines have been commented out!!!!

  ::if not exist %POLLING%\Poll\StoreMailT_Append\shipsend.txt copy %POLLING%\Poll\StoreMailT_Append\shipsend.txt %POLLING%\Poll\StoreMailT_Append\shipsend_force.txt
  ::@if errorlevel 1 @call :MESS Fatal Error - %POLLING%\Poll\StoreMailT_Append\shipsend.txt does not exist  & goto ERR  

  ::if exist %POLLING%\Poll\StoreMailT_Append\shipsend.txt rename %POLLING%\Poll\OutboundT\Mail.txt Mail_modified1.txt
  ::@if errorlevel 1 @call :MESS Fatal Error renaming %POLLING%\Poll\OutboundT\Mail.txt to Mail_modified1.txt & goto ERR

  ::if exist %POLLING%\Poll\StoreMailT_Append\shipsend.txt copy %POLLING%\Poll\OutboundT\Mail_modified1.txt /B + %POLLING%\Poll\StoreMailT_Append\shipsend.txt /B %POLLING%\Poll\OutboundT\Mail.txt
  ::@if errorlevel 1 @call :MESS Fatal Error appending %POLLING%\Poll\OutboundT\Mail_modified1.txt and %POLLING%\Poll\StoreMailT_Append\shipsend.txt to %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending ShipSend.txt




  @call :MESS Begin appending SonicWall.txt

  if exist %POLLING%\Poll\StoreMailT_Append\SonicWall.txt rename %POLLING%\Poll\OutboundT\Mail.txt Mail_modified2.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming %POLLING%\Poll\OutboundT\Mail.txt to Mail_modified2.txt & goto ERR

  if exist %POLLING%\Poll\StoreMailT_Append\SonicWall.txt copy %POLLING%\Poll\OutboundT\Mail_modified2.txt /B + %POLLING%\Poll\StoreMailT_Append\SonicWall.txt /B %POLLING%\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending %POLLING%\Poll\OutboundT\Mail_modified2.txt and %POLLING%\Poll\StoreMailT_Append\SonicWall.txt to %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending SonicWall.txt




  @call :MESS Begin appending StoreStatus.txt

  if exist %POLLING%\Poll\StoreMailT_Append\StoreStatus.txt rename %POLLING%\Poll\OutboundT\Mail.txt Mail_modified3.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming %POLLING%\Poll\OutboundT\Mail.txt to Mail_modified3.txt & goto ERR

  if exist %POLLING%\Poll\StoreMailT_Append\StoreStatus.txt copy %POLLING%\Poll\OutboundT\Mail_modified3.txt /B + %POLLING%\Poll\StoreMailT_Append\StoreStatus.txt /B %POLLING%\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending %POLLING%\Poll\OutboundT\Mail_modified3.txt and %POLLING%\Poll\StoreMailT_Append\StoreStatus.txt to %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending StoreStatus.txt




  @call :MESS Begin appending update.txt

  if exist %POLLING%\Poll\OutboundT\update.txt rename %POLLING%\Poll\OutboundT\Mail.txt Mail_modified4.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming %POLLING%\Poll\OutboundT\Mail.txt to Mail_modified4.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\update.txt copy %POLLING%\Poll\OutboundT\Mail_modified4.txt /B + %POLLING%\Poll\OutboundT\update.txt /B %POLLING%\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending %POLLING%\Poll\OutboundT\Mail_modified4.txt and %POLLING%\Poll\OutboundT\update.txt to %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending update.txt




  @call :MESS Begin copying mail.txt to WizConvert
  
  ::If file already exists, delete it
  if exist %POLLING%\Poll\WizConvert\FromAS400\Mail.txt del %POLLING%\Poll\WizConvert\FromAS400\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting %POLLING%\Poll\WizConvert\FromAS400\Mail.txt & goto ERR

  ::Copy file
  copy %POLLING%\Poll\OutboundT\Mail.txt %POLLING%\Poll\WizConvert\FromAS400\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error copying %POLLING%\Poll\OutboundT\Mail.txt to %POLLING%\Poll\WizConvert\FromAS400\Mail.txt & goto ERR

  @call :MESS End copying mail.txt to WizConvert




  @call :MESS Begin appending SmtpMail.txt

  if exist %POLLING%\Poll\OutboundT\SmtpMail.txt rename %POLLING%\Poll\OutboundT\Mail.txt Mail_modified5.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming %POLLING%\Poll\OutboundT\Mail.txt to Mail_modified5.txt & goto ERR

  if exist %POLLING%\Poll\OutboundT\SmtpMail.txt copy %POLLING%\Poll\OutboundT\Mail_modified5.txt + %POLLING%\Poll\OutboundT\SmtpMail.txt %POLLING%\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending %POLLING%\Poll\OutboundT\Mail_modified5.txt and %POLLING%\Poll\OutboundT\SmtpMail.txt to %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending SmtpMail.txt

:SPLITMAIL
  :: Split mail.
  @call :MESS Begin split mail

  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail1a %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail1a & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail1b %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail1b & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail1c %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail1c & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail1d %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail1d & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail1e %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail1e & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail2a %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail2a & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail2b %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail2b & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail2c %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail2c & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail2d %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail2d & goto ERR
  ::%PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\Outbound\Mail2e %POLLING%\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\Outbound\Mail2e & goto ERR

  ::if exist %POLLING%\Poll\OutboundT\usa.txt %PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\OutboundT\Mail.txt %POLLING%\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE APPENDFILE=%POLLING%\Poll\OutboundT\usa.txt
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\OutboundT\Mail.txt & goto ERR
  ::if not exist %POLLING%\Poll\OutboundT\usa.txt %PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\OutboundT\Mail.txt %POLLING%\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\OutboundT\Mail.txt & goto ERR
  
  %PROG_FOLDER%\SplitMail.exe %POLLING%\Poll\OutboundT\Mail.txt %POLLING%\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in %POLLING%\Poll\OutboundT\Mail.txt & goto ERR

  copy %POLLING%\Poll\StoreMailT\Temp\SiteList.txt %POLLING%\Poll\StoreMailT
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\StoreMailT\Temp\SiteList.txt to %POLLING%\Poll\StoreMailT & goto ERR

  @call :MESS End split mail

:COPY538
  :: Copy mail from #538 to Lab PCs
  @call :MESS Begin copy mail from #538 to Lab PCs

  if exist %POLLING%\Poll\StoreMailT\Temp\Mail00538 C:\PollingApps\ConvertMailT %POLLING%\Poll\StoreMailT\Temp\Mail00538 00997 %POLLING%\Poll\StoreMailT\Temp\Mail00997
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #997 & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\StoreMailT\Temp\Mail00538 C:\PollingApps\ConvertMailT %POLLING%\Poll\StoreMailT\Temp\Mail00538 00910 %POLLING%\Poll\StoreMailT\Temp\Mail00910
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #910 & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\StoreMailT\Temp\Mail00538 C:\PollingApps\ConvertMailT %POLLING%\Poll\StoreMailT\Temp\Mail00538 00911 %POLLING%\Poll\StoreMailT\Temp\Mail00911
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #911 & set WARNING_FLAG=TRUE

  if exist %POLLING%\Poll\StoreMailT\Temp\Mail06547 C:\PollingApps\ConvertMailT %POLLING%\Poll\StoreMailT\Temp\Mail06547 00999 %POLLING%\Poll\StoreMailT\Temp\Mail00999
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #6547 to #999 & set WARNING_FLAG=TRUE

  @call :MESS End copy mail from #538 to Lab PCs

:Duplicate Mail Files
  :: Open DuplicateMailList.txt and copy filenames in Column A to filenames in Column B.
  @call :MESS Begin Duplication of Mail Files

  if exist %PROG_FOLDER%\DuplicateMailList.txt C:\PollingApps\DuplicateFile %PROG_FOLDER%\DuplicateMailList.txt %POLLING%\Poll\StoremailT\Temp\ %POLLING%\Poll\StoremailT\Temp\ prefixS:Mail prefixT:Mail

  @call :MESS End Duplication of Mail Files

:COPYSITELIST
  :: Copy site list to AuditWorks server.
  @call :MESS Begin copy site list to AuditWorks server

  ::copy %POLLING%\Poll\StoreMail\SiteList.txt \\SGAW\Sybwork\Spencer\Data
  
  ::commented out 1/9/2012 to see whether or not anything breaks without this file
  ::copy %PROG_FOLDER%\SitelistT.txt \\SGAW\Sybwork\Spencer\Data
  ::@if errorlevel 1 @call :MESS Error copying site list to AuditWorks server & set WARNING_FLAG=TRUE

  @call :MESS End copy site list to AuditWorks server

:GETEXCLUDE
  :: Get Translate Exclude file.
  @call :MESS Begin get Translate Exclude file

  if exist \\sgicorp\spencergifts\SIRIS\sirisftp\consign\consign.dat copy \\sgicorp\spencergifts\SIRIS\sirisftp\consign\consign.dat %POLLING%\Poll\AuditWorks\Translate\exclude.dat
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
::  @pause

  @call :MESS End Program

  :: Continue with the next Batch File
  %PROG_FOLDER%\CompressStoreMail

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
  @blat %LOG_FILE% -subject "ERROR: SplitOutboundMail" -to AppDevPOSPollingAlerts@spencergifts.com
::  @pause

  :: Force an error code to be returned to the O/S.
  @ren _
