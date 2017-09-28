:: CompressStoreMain_Live_run.cmd
::
:: Dynamically built and by CompressStoreMail_Live.cmd

  :: Set variables.
  @set ERROR_FLAG=FALSE
  @set WARNING_FLAG=FALSE
  @set PROG_FOLDER=%POLLING%\Poll\Bin
  @set LOG_FILE=%PROG_FOLDER%\Logs\CompressStoreMail_Live.log
  @set ERR_FILE=%PROG_FOLDER%\Logs\CompressStoreMail_Live.err

@call :COMPRESS 02913 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02920 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02925 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02928 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02929 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02930 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02931 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02932 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02937 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02938 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02941 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 02942 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03004 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03005 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03006 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03011 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03012 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03013 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03014 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03016 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03017 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03020 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03021 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03022 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03023 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03024 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03025 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03026 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03028 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03030 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03031 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03033 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03034 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03035 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03036 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03037 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03038 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03039 
@if ERRORLEVEL 1 goto ERR 
@call :COMPRESS 03961 
@if ERRORLEVEL 1 goto ERR 

@goto CHECKWARN

:COMPRESS
  :: Compress mail file.
  @if ERROR_FLAG==TRUE goto :EOF
  :: Set variables.
  @set STORE_NUM=%1

  @if exist %POLLING%\Poll\StoreMailT\Temp\Mail%STORE_NUM% goto CMPRS
  @goto :EOF

:CMPRS
  @call :MESS Begin compress store mail %STORE_NUM%

  if exist %POLLING%\Poll\StoreMailT\Temp\Mail.dwn del %POLLING%\Poll\StoreMailT\Temp\Mail.dwn
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMailT\Temp\Mail.dwn & goto CMPRSERR

  if exist %POLLING%\Poll\StoreMailT\Mail%STORE_NUM%.zip "C:\Program Files\7-zip\7z.exe" e %POLLING%\Poll\StoreMailT\Mail%1.zip -o%POLLING%\Poll\StoreMailT\Temp Mail.dwn
  @if errorlevel 1 @call :MESS Fatal error unzipping %POLLING%\Poll\StoreMailT\Mail%STORE_NUM%.zip & goto CMPRSERR

  if exist %POLLING%\Poll\StoreMailT\Temp\Mail.dwn copy %POLLING%\Poll\StoreMailT\Temp\Mail.dwn /A + %POLLING%\Poll\StoreMailT\Temp\Mail%STORE_NUM% /A %POLLING%\Poll\StoreMailT\Temp\Mail.dwn /A
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\StoreMailT\Temp\Mail.dwn and %POLLING%\Poll\StoreMailT\Temp\Mail%STORE_NUM% /A to %POLLING%\Poll\StoreMailT\Temp\Mail.dwn (%STORE_NUM%) & goto CMPRSERR

  if not exist %POLLING%\Poll\StoreMailT\Temp\Mail.dwn copy %POLLING%\Poll\StoreMailT\Temp\Mail%STORE_NUM% %POLLING%\Poll\StoreMailT\Temp\Mail.dwn
  @if errorlevel 1 @call :MESS Fatal error copying %POLLING%\Poll\StoreMailT\Mail%STORE_NUM% to %POLLING%\Poll\StoreMailT\Temp\Mail.dwn (%STORE_NUM%) & goto CMPRSERR

  "C:\Program Files\7-zip\7z.exe" a %POLLING%\Poll\StoreMailT\Mail%1.zip %POLLING%\Poll\StoreMailT\Temp\Mail.dwn
  @if errorlevel 1 @call :MESS Fatal error zipping %POLLING%\Poll\StoreMailT\Temp\Mail.dwn (%STORE_NUM%) & goto CMPRSERR

  del %POLLING%\Poll\StoreMailT\Temp\Mail%STORE_NUM%
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMailT\Temp\Mail%STORE_NUM% & goto CMPRSERR
  del %POLLING%\Poll\StoreMailT\Temp\Mail.dwn
  @if errorlevel 1 @call :MESS Fatal error deleting %POLLING%\Poll\StoreMailT\Temp\Mail.dwn (%STORE_NUM%) & goto CMPRSERR

  @call :MESS End compress store mail %STORE_NUM%
  @goto :EOF

:CMPRSERR
  @set ERROR_FLAG=TRUE
  @ren _
  @goto :EOF

:CHECKWARN
  :: Check warning flag.
  @if %WARNING_FLAG%==TRUE @echo Error(s) deleting ARS mail for Trovato stores >> CompressStoreMail_Live.warn

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