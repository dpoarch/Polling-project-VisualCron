::------------------------------------------------------------------------------
:: PostPollingCleanup.cmd
::
:: Created by: Christian Adams
:: Date: 7/19/2002
::
:: Edited by: Jeramie Shake
:: Date: 8/23/2004
::
:: Description:
::     This program will perform post-polling cleanup tasks.
::
:: Usage: 
::     PostPollingCleanup
::
:: Dependent programs:
::     MoveFiles.exe (Christian Adams) - Moves oneor more files.
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
  @set LOG_FILE=%PROG_FOLDER%\Logs\PostPollingCleanup.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\PostPollingCleanup.err

  :: Set window title and color
  @Title Post-polling Cleanup
  @Color 0E

  :: Create new log file.
  @echo. >> %LOG_FILE%
  @call :MESS Begin Program

  @cls
  @echo *******************************
  @echo * PostPollingCleanup.cmd      *
  @echo *                             *
  @echo * Created by: Christian Adams *
  @echo *******************************

  @echo.
  @echo Cleanup folders used during nightly polling.
  @echo.
::  @pause

:CLEANFOLDERS
  :: Clean folders.
  @call :MESS Begin clean folders.

  del %POLLING%\Poll\Tlog\Good\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Good\Backup & goto ERR
  del %POLLING%\Poll\Tlog\Excludea\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Excludea & goto ERR
  del %POLLING%\Poll\Tlog\Excludei\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Excludei & goto ERR
  del %POLLING%\Poll\Tlog\Excludep\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Excludep & goto ERR
  del %POLLING%\Poll\Tlog\Excludeu\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Excludeu & goto ERR
  del %POLLING%\Poll\Tlog\Excludet\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\Tlog\Excludet & goto ERR

  del %POLLING%\Poll\TlogT\Polled\Zip\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Polled\Zip\Backup & goto ERR
  del %POLLING%\Poll\TlogT\Good\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Good\Backup & goto ERR
  del %POLLING%\Poll\TlogT\GoodExclude\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\GoodExclude\Backup & goto ERR
  del %POLLING%\Poll\TlogT\Polled\CartStores\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Polled\CartStores\Backup & goto ERR
  del %POLLING%\Poll\TlogT\Excludea\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Excludea & goto ERR
  del %POLLING%\Poll\TlogT\Excludei\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Excludei & goto ERR
  del %POLLING%\Poll\TlogT\Excludep\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Excludep & goto ERR
  del %POLLING%\Poll\TlogT\Excludeu\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Excludeu & goto ERR
  del %POLLING%\Poll\TlogT\Excludet\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Excludet & goto ERR
  del %POLLING%\Poll\TlogT\Excludet\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Excludet\Backup & goto ERR
  del %POLLING%\Poll\TlogT\Good\Converted\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Good\Converted & goto ERR
  del %POLLING%\Poll\TlogT\GoodExclude\Converted\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\GoodExclude\Converted & goto ERR
  del %POLLING%\Poll\TlogT\Good\ForTlogUpdater\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Good\ForTlogUpdater & goto ERR
  del %POLLING%\Poll\TlogT\GoodExclude\ForTlogUpdater\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\GoodExclude\ForTlogUpdater & goto ERR
  del %POLLING%\Poll\TlogT\Good\BackupForTlogUpdater\*.* /Q /S
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Good\BackupForTlogUpdater & goto ERR
  del %POLLING%\Poll\TlogT\GoodExclude\BackupForTlogUpdater\*.* /Q /S
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\GoodExclude\BackupForTlogUpdater & goto ERR
  del %POLLING%\Poll\TlogT\Good\Translated\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\Good\Translated & goto ERR
  del %POLLING%\Poll\TlogT\GoodExclude\Translated\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\GoodExclude\Translated & goto ERR 

  if exist %POLLING%\Poll\TlogT\TranslateTest\*.* del %POLLING%\Poll\TlogT\TranslateTest\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\TranslateTest & goto ERR
  if exist %POLLING%\Poll\TlogT\TranslateTest\Translated\*.* del %POLLING%\Poll\TlogT\TranslateTest\Translated\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\TranslateTest\Translated & goto ERR

  del %POLLING%\Data\Recover\Good\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Poll\TlogT\GoodExclude\Backup & goto ERR
  del %POLLING%\Data\Recover\Excludea\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\Recover\Excludea & goto ERR
  del %POLLING%\Data\Recover\Excludei\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\Recover\Excludei & goto ERR
  del %POLLING%\Data\Recover\Excludep\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\Recover\Excludep & goto ERR
  del %POLLING%\Data\Recover\Excludeu\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\Recover\Excludeu & goto ERR
  del %POLLING%\Data\Recover\Excludet\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\Recover\Excludet & goto ERR

  del %POLLING%\Data\RecoverT\Zip\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Zip\Backup & goto ERR
  del %POLLING%\Data\RecoverT\Good\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\Recover\Good\Backup & goto ERR
  del %POLLING%\Data\RecoverT\GoodExclude\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Goodexclude\Backup & goto ERR
  del %POLLING%\Data\RecoverT\CartStores\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\CartStores\Backup & goto ERR
  del %POLLING%\Data\RecoverT\CartStores\Fixed\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\CartStores\Fixed & goto ERR
  del %POLLING%\Data\RecoverT\Excludea\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Excludea & goto ERR
  del %POLLING%\Data\RecoverT\Excludei\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Excludei & goto ERR
  del %POLLING%\Data\RecoverT\Excludep\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Excludep & goto ERR
  del %POLLING%\Data\RecoverT\Excludeu\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Excludeu & goto ERR
  del %POLLING%\Data\RecoverT\Excludet\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Excludet & goto ERR
  del %POLLING%\Data\RecoverT\Excludet\Backup\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Excludet\Backup & goto ERR
  del %POLLING%\Data\RecoverT\Good\Converted\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Good\Converted & goto ERR
  del %POLLING%\Data\RecoverT\GoodExclude\Converted\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Goodexclude\Converted & goto ERR
  del %POLLING%\Data\RecoverT\Good\ForTlogUpdater\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Good\ForTlogUpdater & goto ERR
  del %POLLING%\Data\RecoverT\GoodExclude\ForTlogUpdater\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Goodexclude\ForTlogUpdater & goto ERR
  del %POLLING%\Data\RecoverT\Good\BackupForTlogUpdater\*.* /Q /S
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Good\BackupForTlogUpdater & goto ERR
  del %POLLING%\Data\RecoverT\GoodExclude\BackupForTlogUpdater\*.* /Q /S
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Goodexclude\BackupForTlogUpdater & goto ERR
  del %POLLING%\Data\RecoverT\Good\Translated\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Good\Translated & goto ERR
  del %POLLING%\Data\RecoverT\GoodExclude\Translated\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\Goodexclude\Translated & goto ERR

  if exist %POLLING%\Data\RecoverT\TranslateTest\*.* del %POLLING%\Data\RecoverT\TranslateTest\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\TranslateTest & goto ERR
  if exist %POLLING%\Data\RecoverT\TranslateTest\Translated\*.* del %POLLING%\Data\RecoverT\TranslateTest\Translated\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\TranslateTest\Translated & goto ERR

  if exist %POLLING%\Data\RecoverT\PayrollImport\Imported\*.* del %POLLING%\Data\RecoverT\PayrollImport\Imported\*.* /Q
  @if errorlevel 1 @call :MESS Fatal error deleting files from %POLLING%\Data\RecoverT\PayrollImport\Imported & goto ERR

  del %POLLING%\Poll\Outbound\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %POLLING%\Poll\Outbound & set WARNING_FLAG=TRUE
  del %POLLING%\Poll\OutboundT\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %POLLING%\Poll\OutboundT & set WARNING_FLAG=TRUE

  del %POLLING%\Poll\Tlog\Ends\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %POLLING%\Poll\Tlog\Ends & set WARNING_FLAG=TRUE
  del %POLLING%\Poll\TlogT\Ends\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %POLLING%\Poll\TlogT\Ends & set WARNING_FLAG=TRUE

  del %POLLING%\Poll\StoreMailT_Append\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %POLLING%\Poll\StoreMailT_Append & set WARNING_FLAG=TRUE

  if exist %POLLING%\RWS\ECF\PriceCheck.ecb del %POLLING%\RWS\ECF\PriceCheck.ecb /Q
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\RWS\ECF\PriceCheck.ecb & set WARNING_FLAG=TRUE

  if exist %POLLING%\RWS\ECF\PriceCheck_Spirit.ecb del %POLLING%\RWS\ECF\PriceCheck_Spirit.ecb /Q
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\RWS\ECF\PriceCheck_Spirit.ecb & set WARNING_FLAG=TRUE

  if exist %PROG_FOLDER%\GeneratePriceCheckFiles_Complete.flg del %PROG_FOLDER%\GeneratePriceCheckFiles_Complete.flg /Q
  @if errorlevel 1 @call :MESS Error deleting %PROG_FOLDER%\GeneratePriceCheckFiles_Complete.flg & set WARNING_FLAG=TRUE

  if exist %PROG_FOLDER%\GeneratePriceCheckFiles_Spirit_Complete.flg del %PROG_FOLDER%\GeneratePriceCheckFiles_Spirit_Complete.flg /Q
  @if errorlevel 1 @call :MESS Error deleting %PROG_FOLDER%\GeneratePriceCheckFiles_Spirit_Complete.flg & set WARNING_FLAG=TRUE

  if exist %PROG_FOLDER%\DealPricingFilesComplete.flg del %PROG_FOLDER%\DealPricingFilesComplete.flg /Q
  @if errorlevel 1 @call :MESS Error deleting %PROG_FOLDER%\DealPricingFilesComplete.flg & set WARNING_FLAG=TRUE

  if exist %STOREDATA%\DealPricing\Sent\*.* del %STOREDATA%\DealPricing\Sent\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %STOREDATA%\DealPricing\Sent & set WARNING_FLAG=TRUE

  if exist %STOREDATA%\DealPricing\BackupOriginals\*.* del %STOREDATA%\DealPricing\BackupOriginals\*.* /Q
  @if errorlevel 1 @call :MESS Error deleting files from %STOREDATA%\DealPricing\BackupOriginals & set WARNING_FLAG=TRUE

  @if not exist %PROG_FOLDER%\PrePolling1.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\PrePolling1.flg del %PROG_FOLDER%\PrePolling1.flg /Q

  @if not exist %PROG_FOLDER%\BeginPrePolling2.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\BeginPrePolling2.flg del %PROG_FOLDER%\BeginPrePolling2.flg /Q

  @if not exist %PROG_FOLDER%\PrePolling2.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\PrePolling2.flg del %PROG_FOLDER%\PrePolling2.flg /Q

  @if not exist %PROG_FOLDER%\UpcFilesCreated.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\UpcFilesCreated.flg del %PROG_FOLDER%\UpcFilesCreated.flg /Q

  @if not exist %PROG_FOLDER%\SWOAssignDone.flg @echo Flag File has been deleted already.
  @if exist %PROG_FOLDER%\SWOAssignDone.flg del %PROG_FOLDER%\SWOAssignDone.flg /Q

  @call :MESS End clean folders.

:DELSALES
  ::Delete sales reports.
  @call :MESS Begin delete sales reports.

  if exist %POLLING%\Data\Reports\Dept*.txt del %POLLING%\Data\Reports\Dept*.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Data\Reports\Dept*.txt & set WARNING_FLAG=TRUE
  if exist %POLLING%\Data\Reports\Journal*.txt del %POLLING%\Data\Reports\Journal*.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Data\Reports\Journal*.txt & set WARNING_FLAG=TRUE
  if exist %POLLING%\Data\Reports\Total*.txt del %POLLING%\Data\Reports\Total*.txt
  @if errorlevel 1 @call :MESS Error deleting %POLLING%\Data\Reports\Total*.txt & set WARNING_FLAG=TRUE

  @call :MESS End delete sales reports.


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
  %PROG_FOLDER%\RemoveSnapshot

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
  @echo.
  @blat %LOG_FILE% -subject "ERROR: PostPollingCleanup" -to AppDevPOSPollingAlerts@spencergifts.com

  :: Force an error code to be returned to the O/S.
  @ren _
