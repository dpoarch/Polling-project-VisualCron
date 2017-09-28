::This batch file skipped as of 7/22/2013
@set PROG_FOLDER=%POLLING%\Poll\Bin

@ECHO Set POLLING.DONE flag.
@ECHO.
::@PAUSE
COPY %PROG_FOLDER%\Maildone.txt \\SGAW\sybwork\spencer\data\POLLING.DONE
@ECHO.
@DIR \\SGAW\sybwork\spencer\data\POLLING.DONE

@ECHO.
@ECHO Confirm that POLLING.DONE flag was set before proceeding!
@ECHO.
::@PAUSE
%PROG_FOLDER%\MergeTlogs.cmd