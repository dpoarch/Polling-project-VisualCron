@echo off

setlocal

if not defined GALAXY_BASE set GALAXY_BASE=C:\Program Files\CommVault\Simpana\Base

set PATH=%PATH%;%GALAXY_BASE%
set response="SGPOLLDATA01_INCR.bat_13772664.tmp"

qlogin -u "SGICORP\PollingBackup" -ps "397292dbccbabfd4127639f2e13207574d6585036adeb4a9ea3c3fb74c8be6d78" -cs "sgcommvault.sgicorp.spencergifts.com" 
if %errorlevel% NEQ 0 (
	echo Login failed.
	goto endOfScript )


:loopx
if "%1"=="" ( goto loopz )
set input=%input% %1
shift
goto loopx
:loopz
qoperation execute -af "SGPOLLDATA01_INCR.bat_1377266437.xml"  %input% > %response%
	if %errorlevel% NEQ 0 (
		echo Failed to get job details.
		goto end_1377266437 )
	for /F "tokens=1* usebackq" %%i in (%response%) do echo %%i %%j

:end_1377266437
	set OrigErrLevel=%errorlevel%
	qlogout
	if %errorlevel% NEQ 0 (
		echo Logout failed. )
	del %response%
	if %OrigErrLevel% NEQ 0 exit /b %OrigErrLevel%
:endOfScript 

