  @set PROG_FOLDER=%POLLING%\Poll\Bin

  if exist C:\Temp\DealPricing.zip del %POLLING%\Temp\DealPricing.zip
  @if errorlevel 1 goto EOF
  if exist %STOREDATA%\DealPricing\*.* "C:\Program Files\7-Zip\7z.exe" a C:\Temp\DealPricing.zip %STOREDATA%\DealPricing
  @if errorlevel 1 goto EOF
  if exist C:\Temp\DealPricing.zip C:\PollingApps\MoveFiles.exe C:\Temp\DealPricing.zip %POLLING%\Backup\DealPricing TIMESTAMP=TRUE
  @if errorlevel 1 goto EOF

  if exist %PROG_FOLDER%\DealPricingFilesComplete.flg del %PROG_FOLDER%\DealPricingFilesComplete.flg /Q
  @if errorlevel 1 goto EOF

  if exist %STOREDATA%\DealPricing\Sent\*.* del %STOREDATA%\DealPricing\Sent\*.* /Q
  @if errorlevel 1 goto EOF

  if exist %STOREDATA%\DealPricing\BackupOriginals\*.* del %STOREDATA%\DealPricing\BackupOriginals\*.* /Q
  @if errorlevel 1 goto EOF