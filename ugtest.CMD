@set PROG_FOLDER=%POLLING%\Poll\Bin
%PROG_FOLDER%\pullug.exe %POLLING%\poll\upload\iplogst %POLLING%\poll\interface\undrgrnd\ugtest.txt
::copyfiles %POLLING%\poll\interface\undrgrnd\ugtest.txt \\sgintsql\tlog_data
PAUSE