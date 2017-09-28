@echo off
pause
if not exist %POLLING%\poll\upload\uplogs_original rename %POLLING%\poll\upload\uplogs uplogs_original
if exist %POLLING%\poll\upload\uplogs del %POLLING%\poll\upload\uplogs
%POLLING%\Poll\Bin\mergetlogs %POLLING%\data\polldata\jerfiles\tlog\good\backup\*.* %POLLING%\poll\upload\uplogs format=ars
%POLLING%\Poll\Bin\mergetlogs %POLLING%\data\polldata\jerfiles\recover\good\backup\*.* %POLLING%\poll\upload\uplogs format=ars
echo.
echo Hitting enter will FTP the uplogs file to prod
echo.
pause
%POLLING%\Poll\Bin\ftpuplogs_andgo_toprod.cmd