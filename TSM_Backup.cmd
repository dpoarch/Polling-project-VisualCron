::------------------------------------------------------------------------------
:: TSM_Backup.cmd
::
:: Created by: Christian Adams
:: Date: 4/30/2002
::
:: Description:
::     This program will perform a TSM backup.
::
:: Usage: 
::     TSM_Backup
::
:: Dependent programs:
::     Now.exe (NT Resource Kit) - Displays the current date and time.
::
::     Dsmc.exe (Tivoli) - Performs TSM backup.
::
:: Environment variables:
::     ERROR_FLAG - used for detecting errors.
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
@set PROG_FOLDER=%POLLING%\Poll\Bin
@set LOG_FILE=%PROG_FOLDER%\Logs\TSM_Backup.log
@set ERR_FILE=%PROG_FOLDER%\Logs\TSM_Backup.err

:: Set window title and color.
@Title TSM Backup
@Color 0E

:: Create new log file.
@Now Begin Program >> %LOG_FILE%
@ver > nul

@cls
@echo *******************************
@echo * TSM_Backup.cmd              *
@echo *                             *
@echo * Created by: Christian Adams *
@echo *******************************


:: Delete flag file.
call :DELFLAG

:: Perform TSM backup as follows:
::     call :BACKUP {backup parameters} >> %LOG_FILE%

call :BACKUP INCREMENTAL >> %LOG_FILE%

:: After running all the backups, check for errors.
@if %ERROR_FLAG%==TRUE goto ERR
@goto END

:DELFLAG
:: Delete flag file.
@Now Begin delete flag file
@ver > nul

if exist %PROG_FOLDER%\TSM_Backup.go del %PROG_FOLDER%\TSM_Backup.go
@if errorlevel 1 goto DELERR

@Now End delete flag file
@ver > nul
@goto DELEND

:DELERR
@echo.
@echo *** ERROR DETECTED ***
@Now Error detected level %errorlevel%
:: Set error flag.
@set ERROR_FLAG=TRUE

:DELEND
@goto :EOF

:BACKUP
:: This section of the program performs the TSM backup.

:: Begin TSM backup.
@Now Begin TSM backup %1
@ver > nul

:: DSMC must be called from the TSM client directory.
E:
CD \TSM\baclient
dsmc %1 %2 %3 %4 %5 %6 %7 %8 %9
@if errorlevel 1 goto BUERR

:: End TSM backup.
@Now End TSM backup %1
@ver > nul
@goto BUEND

:BUERR
@echo.
@echo *** ERROR DETECTED ***
@Now Error detected level %errorlevel%
:: Set error flag.
@set ERROR_FLAG=TRUE

:BUEND
@goto :EOF

:END
:: Program completed successfully.
@Now End Program >> %LOG_FILE%
@ver > nul
@goto :EOF

:ERR
:: An error was detected.
@Now Abend Program >> %LOG_FILE%
@ver > nul
:: Append the log to the error file.
@echo. >> %ERR_FILE%
@echo *********************************** ERROR ************************************ >> %ERR_FILE%
@copy %ERR_FILE% /A + %LOG_FILE% /A %ERR_FILE% /A

:: Force an error code to be returned to the O/S.
@ren _
