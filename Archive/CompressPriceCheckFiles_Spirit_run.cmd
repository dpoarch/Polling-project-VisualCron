:: CompressPriceCheckFiles_Spirit_run.cmd
::
:: Dynamically built and by CompressPriceCheckFiles_Spirit.cmd

  :: Set variables.
  @set ERROR_FLAG=FALSE
  @set WARNING_FLAG=FALSE
  @set PROG_FOLDER=\\sghpnas\pos\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\CompressPriceCheckFiles_Spirit.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CompressPriceCheckFiles_Spirit.err


@goto CHECKWARN

:COMPRESS
  :: Compress price check file.
  @if ERROR_FLAG==TRUE goto :EOF
  :: Set variables.
  @set FILE_NUM=%1

  @if exist \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\PC_%FILE_NUM%.txt goto CMPRS
  @goto :EOF

:CMPRS
  @call :MESS Begin Compress Price Check File %FILE_NUM%

  if exist \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat del \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat & goto CMPRSERR

  if exist \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip del \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip & goto CMPRSERR

  if exist \\sghpnas\pos\Poll\PriceCheck_Spirit\Zipped\PC_%FILE_NUM%.zip del \\sghpnas\pos\Poll\PriceCheck_Spirit\Zipped\PC_%FILE_NUM%.zip
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\PriceCheck_Spirit\Zipped\PC_%FILE_NUM%.zip & goto CMPRSERR

  if exist \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\PC_%FILE_NUM%.txt copy \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\PC_%FILE_NUM%.txt \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat
  @if errorlevel 1 @call :MESS Fatal error copying \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\PC_%FILE_NUM%.txt to \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat & goto CMPRSERR

  "C:\Program Files\Winzip\wzzip.exe" \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat
  @if errorlevel 1 @call :MESS Fatal error zipping \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat (%FILE_NUM%) & goto CMPRSERR

  "C:\Program Files\Winzip\wzzip.exe" \\sghpnas\pos\Poll\PriceCheck_Spirit\Zipped\PC_%1.zip \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip
  @if errorlevel 1 @call :MESS Fatal error zipping \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip (%FILE_NUM%) & goto CMPRSERR

  del \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\sku.dat (%STORE_NUM%) & goto CMPRSERR
  del \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip
  @if errorlevel 1 @call :MESS Fatal error deleting \\sghpnas\pos\Poll\PriceCheck_Spirit\Text\Export.zip (%STORE_NUM%) & goto CMPRSERR

  @call :MESS End Compress Price Check File %FILE_NUM%
  @goto :EOF

:CMPRSERR
  @set ERROR_FLAG=TRUE
  @ren _
  @goto :EOF

:CHECKWARN
  :: Check warning flag.
  @if %WARNING_FLAG%==TRUE @echo Error(s) compressing price check files >> CompressPriceCheckFiles_Spirit.warn

:END
  @goto :EOF

:MESS
  :: Write message to log file and screen.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9 >> %LOG_FILE%
  @ver > nul
  @echo.
  @now %1 %2 %3 %4 %5 %6 %7 %8 %9
  @ver > nul
  @goto :EOF

:ERR
  :: Force an error code to be returned to the O/S.
  @ren _
