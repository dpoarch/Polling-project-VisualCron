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
  @set PROG_FOLDER=\\sghpnas\pos\Poll\Bin
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
  if exist \\sghpnas\pos\Poll\StoreMailT_Append\smtpmail.done del \\sghpnas\pos\Poll\StoreMailT_Append\smtpmail.done
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\StoreMailT_Append\smtpmail.done & goto ERR

:BUSITELIST
  :: Backup site list.
  @call :MESS Begin backup site list

  if exist \\sghpnas\pos\Poll\StoreMail\SiteList.txt copy \\sghpnas\pos\Poll\StoreMail\SiteList.txt \\sghpnas\pos\Poll\StoreMail\SiteList.bak
  @if errorlevel 1 @call :MESS Fatal error copying \\sghpnas\pos\Poll\StoreMail\SiteList.txt to \\sghpnas\pos\Poll\StoreMail\SiteList.bak & goto ERR
  if exist \\sghpnas\pos\Poll\StoreMail\SiteList.txt del \\sghpnas\pos\Poll\StoreMail\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\StoreMail\SiteList.txt & goto ERR

  if exist \\sghpnas\pos\Poll\StoreMailT\SiteList.txt copy \\sghpnas\pos\Poll\StoreMailT\SiteList.txt \\sghpnas\pos\Poll\StoreMailT\SiteList.bak
  @if errorlevel 1 @call :MESS Fatal error copying \\sghpnas\pos\Poll\StoreMailT\SiteList.txt to \\sghpnas\pos\Poll\StoreMailT\SiteList.bak & goto ERR
  if exist \\sghpnas\pos\Poll\StoreMailT\SiteList.txt del \\sghpnas\pos\Poll\StoreMailT\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\StoreMailT\SiteList.txt & goto ERR
  if exist \\sghpnas\pos\Poll\StoreMailT\Temp\SiteList.txt del \\sghpnas\pos\Poll\StoreMailT\Temp\SiteList.txt
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\StoreMailT\Temp\SiteList.txt & goto ERR

  @call :MESS End backup site list

:ADDRESS
  :: Retrieve store address file.
  @call :MESS Begin retrive store address file

  if exist \\sghpnas\pos\Poll\OutboundT\usa.txt del \\sghpnas\pos\Poll\OutboundT\usa.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\usa.txt & goto ERR
  copy \\sgintfinop\ops_shared\sirisftp\pos\address\usa.txt \\sghpnas\pos\Poll\OutboundT\usa.txt
  @if errorlevel 1 @call :MESS Error copying \\sgintfinop\ops_shared\sirisftp\pos\address\usa.txt to \\sghpnas\pos\Poll\OutboundT\usa.txt & set WARNING_FLAG=TRUE

  if exist \\sghpnas\pos\Poll\OutboundT\update.txt del \\sghpnas\pos\Poll\OutboundT\update.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\update.txt & goto ERR
  copy \\sgintfinop\ops_shared\sirisftp\pos\address\update.txt \\sghpnas\pos\Poll\OutboundT\update.txt
  @if errorlevel 1 @call :MESS Error copying \\sgintfinop\ops_shared\sirisftp\pos\address\update.txt to \\sghpnas\pos\Poll\OutboundT\update.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrive store address file

:STORETRAN
  :: Retrieve interstore transfers file.
  @call :MESS Begin retrive interstore transfers file

  if not exist "\\Sgintfinop\OPS_SHARED\SIRISFTP\POS\Store Transfer\StoreTransfer.txt" @call :MESS Fatal error \\Sgintfinop\OPS_SHARED\SIRISFTP\POS\Store Transfer\StoreTransfer.txt does not exist & goto ERR

  copy "\\Sgintfinop\OPS_SHARED\SIRISFTP\POS\Store Transfer\StoreTransfer.txt" \\sghpnas\pos\Poll\OutboundT\StoreTransfer.txt
  @if errorlevel 1 @call :MESS Error copying \\Sgintfinop\OPS_SHARED\SIRISFTP\POS\Store Transfer\StoreTransfer.txt to \\sghpnas\pos\Poll\OutboundT\StoreTransfer.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrive interstore transfers file

:SMTPMAIL
  :: Retrieve smtpmail file.
  @call :MESS Begin retrieve smtpmail file

  if not exist \\sghpnas\pos\Poll\StoreMailT_Append\SmtpMail.txt @call :MESS Fatal error \\sghpnas\pos\Poll\StoreMailT_Append\SmtpMail.txt does not exist & goto ERR

  copy \\sghpnas\pos\Poll\StoreMailT_Append\SmtpMail.txt \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt
  @if errorlevel 1 @call :MESS Error copying \\sghpnas\pos\Poll\StoreMailT_Append\SmtpMail.txt to \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt & set WARNING_FLAG=TRUE

  @call :MESS End retrieve smtpmail file

:COPYSMTPMAIL
  ::Copies the smtpmail.txt to Programming for Reference
  @call :MESS Begin copy smtpmail.txt to programming
  
  \\sghpnas\pos\Poll\Bin\CopyFiles.exe \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt \\sgsql\FileSave\SmtpMailBackup TIMESTAMP=TRUE
  @if errorlevel 1 @call :MESS Error copying \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt to \\sgsql\FileSave\SmtpMailBackup & set WARNING_FLAG=TRUE

  @call :MESS End copy smtpmail.txt to programming

:UNZIP
  ::Unzips the mail file ftp'd from the AS400
  @call :MESS Begin unzip mail.zip file

  ::If mail.txt file already exists, delete it
  if exist \\sghpnas\pos\Poll\OutboundT\Mail.txt del \\sghpnas\pos\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  ::Unzip mail.zip
  "C:\Program Files\7-zip\7z.exe" e \\sghpnas\pos\Poll\OutboundT\mail.zip -o\\sghpnas\pos\Poll\OutboundT
  @if errorlevel 1 @call :MESS Fatal error unzipping \\sghpnas\pos\Poll\OutboundT\mail.zip & goto ERR

  @call :MESS End unzip mail.zip file

:APPEND
  :: Append files to the Trovato Mail File

  @call :MESS begin Restore original mail file
  :: If modified mail files exist, delete them

  if exist \\sghpnas\pos\Poll\OutboundT\Mail_original.txt del \\sghpnas\pos\Poll\OutboundT\Mail_original.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail_original.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\Mail_modified1.txt del \\sghpnas\pos\Poll\OutboundT\Mail_modified1.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail_modified1.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\Mail_modified2.txt del \\sghpnas\pos\Poll\OutboundT\Mail_modified2.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail_modified2.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\Mail_modified3.txt del \\sghpnas\pos\Poll\OutboundT\Mail_modified3.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail_modified3.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\Mail_modified4.txt del \\sghpnas\pos\Poll\OutboundT\Mail_modified4.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail_modified4.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\Mail_modified5.txt del \\sghpnas\pos\Poll\OutboundT\Mail_modified5.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\OutboundT\Mail_modified5.txt & goto ERR

  @call :MESS end restore original mail file




  @call :MESS Begin appending StoreTransfer.txt

  rename \\sghpnas\pos\Poll\OutboundT\Mail.txt Mail_original.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming \\sghpnas\pos\Poll\OutboundT\Mail.txt to Mail_original.txt & goto ERR

  copy \\sghpnas\pos\Poll\OutboundT\Mail_original.txt /B + \\sghpnas\pos\Poll\OutboundT\StoreTransfer.txt /B \\sghpnas\pos\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending \\sghpnas\pos\Poll\OutboundT\Mail_original.txt and \\sghpnas\pos\Poll\OutboundT\StoreTransfer.txt to \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending StoreTransfer.txt




  @call :MESS Begin appending ShipSend.txt

  :: Force error if shipsend.txt doesn't exist
  :: !!!!The promotion is over so the following lines have been commented out!!!!

  ::if not exist \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt copy \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt \\sghpnas\pos\Poll\StoreMailT_Append\shipsend_force.txt
  ::@if errorlevel 1 @call :MESS Fatal Error - \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt does not exist  & goto ERR  

  ::if exist \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt rename \\sghpnas\pos\Poll\OutboundT\Mail.txt Mail_modified1.txt
  ::@if errorlevel 1 @call :MESS Fatal Error renaming \\sghpnas\pos\Poll\OutboundT\Mail.txt to Mail_modified1.txt & goto ERR

  ::if exist \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt copy \\sghpnas\pos\Poll\OutboundT\Mail_modified1.txt /B + \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt /B \\sghpnas\pos\Poll\OutboundT\Mail.txt
  ::@if errorlevel 1 @call :MESS Fatal Error appending \\sghpnas\pos\Poll\OutboundT\Mail_modified1.txt and \\sghpnas\pos\Poll\StoreMailT_Append\shipsend.txt to \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending ShipSend.txt




  @call :MESS Begin appending SonicWall.txt

  if exist \\sghpnas\pos\Poll\StoreMailT_Append\SonicWall.txt rename \\sghpnas\pos\Poll\OutboundT\Mail.txt Mail_modified2.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming \\sghpnas\pos\Poll\OutboundT\Mail.txt to Mail_modified2.txt & goto ERR

  if exist \\sghpnas\pos\Poll\StoreMailT_Append\SonicWall.txt copy \\sghpnas\pos\Poll\OutboundT\Mail_modified2.txt /B + \\sghpnas\pos\Poll\StoreMailT_Append\SonicWall.txt /B \\sghpnas\pos\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending \\sghpnas\pos\Poll\OutboundT\Mail_modified2.txt and \\sghpnas\pos\Poll\StoreMailT_Append\SonicWall.txt to \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending SonicWall.txt




  @call :MESS Begin appending StoreStatus.txt

  if exist \\sghpnas\pos\Poll\StoreMailT_Append\StoreStatus.txt rename \\sghpnas\pos\Poll\OutboundT\Mail.txt Mail_modified3.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming \\sghpnas\pos\Poll\OutboundT\Mail.txt to Mail_modified3.txt & goto ERR

  if exist \\sghpnas\pos\Poll\StoreMailT_Append\StoreStatus.txt copy \\sghpnas\pos\Poll\OutboundT\Mail_modified3.txt /B + \\sghpnas\pos\Poll\StoreMailT_Append\StoreStatus.txt /B \\sghpnas\pos\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending \\sghpnas\pos\Poll\OutboundT\Mail_modified3.txt and \\sghpnas\pos\Poll\StoreMailT_Append\StoreStatus.txt to \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending StoreStatus.txt




  @call :MESS Begin appending update.txt

  if exist \\sghpnas\pos\Poll\OutboundT\update.txt rename \\sghpnas\pos\Poll\OutboundT\Mail.txt Mail_modified4.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming \\sghpnas\pos\Poll\OutboundT\Mail.txt to Mail_modified4.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\update.txt copy \\sghpnas\pos\Poll\OutboundT\Mail_modified4.txt /B + \\sghpnas\pos\Poll\OutboundT\update.txt /B \\sghpnas\pos\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending \\sghpnas\pos\Poll\OutboundT\Mail_modified4.txt and \\sghpnas\pos\Poll\OutboundT\update.txt to \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending update.txt




  @call :MESS Begin copying mail.txt to WizConvert
  
  ::If file already exists, delete it
  if exist \\sghpnas\pos\Poll\WizConvert\FromAS400\Mail.txt del \\sghpnas\pos\Poll\WizConvert\FromAS400\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error deleting \\sghpnas\pos\Poll\WizConvert\FromAS400\Mail.txt & goto ERR

  ::Copy file
  copy \\sghpnas\pos\Poll\OutboundT\Mail.txt \\sghpnas\pos\Poll\WizConvert\FromAS400\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error copying \\sghpnas\pos\Poll\OutboundT\Mail.txt to \\sghpnas\pos\Poll\WizConvert\FromAS400\Mail.txt & goto ERR

  @call :MESS End appending update.txt




  @call :MESS Begin appending SmtpMail.txt

  if exist \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt rename \\sghpnas\pos\Poll\OutboundT\Mail.txt Mail_modified5.txt
  @if errorlevel 1 @call :MESS Fatal Error renaming \\sghpnas\pos\Poll\OutboundT\Mail.txt to Mail_modified5.txt & goto ERR

  if exist \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt copy \\sghpnas\pos\Poll\OutboundT\Mail_modified5.txt + \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt \\sghpnas\pos\Poll\OutboundT\Mail.txt
  @if errorlevel 1 @call :MESS Fatal Error appending \\sghpnas\pos\Poll\OutboundT\Mail_modified5.txt and \\sghpnas\pos\Poll\OutboundT\SmtpMail.txt to \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  @call :MESS End appending SmtpMail.txt

:SPLITMAIL
  :: Split mail.
  @call :MESS Begin split mail

  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail1a \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail1a & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail1b \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail1b & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail1c \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail1c & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail1d \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail1d & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail1e \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail1e & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail2a \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail2a & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail2b \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail2b & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail2c \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail2c & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail2d \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail2d & goto ERR
  ::\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\Outbound\Mail2e \\sghpnas\pos\Poll\StoreMail FORMAT=ARS SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\Outbound\Mail2e & goto ERR

  ::if exist \\sghpnas\pos\Poll\OutboundT\usa.txt \\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\OutboundT\Mail.txt \\sghpnas\pos\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE APPENDFILE=\\sghpnas\pos\Poll\OutboundT\usa.txt
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR
  ::if not exist \\sghpnas\pos\Poll\OutboundT\usa.txt \\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\OutboundT\Mail.txt \\sghpnas\pos\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE
  ::@if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR
  
  \\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Poll\OutboundT\Mail.txt \\sghpnas\pos\Poll\StoreMailT\Temp FORMAT=TROVATO SITELIST=TRUE
  @if errorlevel 1 @call :MESS Fatal error spliting mail in \\sghpnas\pos\Poll\OutboundT\Mail.txt & goto ERR

  copy \\sghpnas\pos\Poll\StoreMailT\Temp\SiteList.txt \\sghpnas\pos\Poll\StoreMailT
  @if errorlevel 1 @call :MESS Fatal error copying \\sghpnas\pos\Poll\StoreMailT\Temp\SiteList.txt to \\sghpnas\pos\Poll\StoreMailT & goto ERR

  @call :MESS End split mail

:COPY538
  :: Copy mail from #538 to Lab PCs
  @call :MESS Begin copy mail from #538 to Lab PCs

  if exist \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00538 ConvertMailT \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00538 00997 \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00997
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #997 & set WARNING_FLAG=TRUE

  if exist \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00538 ConvertMailT \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00538 00910 \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00910
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #910 & set WARNING_FLAG=TRUE

  if exist \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00538 ConvertMailT \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00538 00911 \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00911
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #538 to #911 & set WARNING_FLAG=TRUE

  if exist \\sghpnas\pos\Poll\StoreMailT\Temp\Mail06547 ConvertMailT \\sghpnas\pos\Poll\StoreMailT\Temp\Mail06547 00999 \\sghpnas\pos\Poll\StoreMailT\Temp\Mail00999
  @if errorlevel 1 @call :MESS Error converting Trovato store mail from #6547 to #999 & set WARNING_FLAG=TRUE

  @call :MESS End copy mail from #538 to Lab PCs

:Duplicate Mail Files
  :: Open DuplicateMailList.txt and copy filenames in Column A to filenames in Column B.
  @call :MESS Begin Duplication of Mail Files

  if exist \\sghpnas\pos\Poll\Bin\DuplicateMailList.txt DuplicateFile \\sghpnas\pos\Poll\Bin\DuplicateMailList.txt \\sghpnas\pos\Poll\StoremailT\Temp\ \\sghpnas\pos\Poll\StoremailT\Temp\ prefixS:Mail prefixT:Mail

  @call :MESS End Duplication of Mail Files

:COPYSITELIST
  :: Copy site list to AuditWorks server.
  @call :MESS Begin copy site list to AuditWorks server

  ::copy \\sghpnas\pos\Poll\StoreMail\SiteList.txt \\SGAW\Sybwork\Spencer\Data
  copy \\sghpnas\pos\Poll\Bin\SitelistT.txt \\SGAW\Sybwork\Spencer\Data
  @if errorlevel 1 @call :MESS Error copying site list to AuditWorks server & set WARNING_FLAG=TRUE

  @call :MESS End copy site list to AuditWorks server

:GETEXCLUDE
  :: Get Translate Exclude file.
  @call :MESS Begin get Translate Exclude file

  if exist \\sgintfinop\ops_shared\sirisftp\consign\consign.dat copy \\sgintfinop\ops_shared\sirisftp\consign\consign.dat \\sghpnas\pos\Poll\AuditWorks\Translate\exclude.dat
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
::  \\sghpnas\pos\Poll\Bin\CompressStoreMail

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
