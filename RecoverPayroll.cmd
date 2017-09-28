@set PROG_FOLDER=%POLLING%\Poll\Bin

REM This program creates a payroll file for Del Ray.
REM Delete last week's data.
E:
CD \Data\Payroll
DEL paytlogs.
DEL sg*.txt
DEL Payroll.dat

REM Process recovered tlogs.
E:
CD \Poll\Bin
CALL %PROG_FOLDER%\ProcessRecoveredTlogs.cmd

REM Merge recovered tlogs.

REM ***Old ARS Merge
REM %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Good\Backup\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=ARS
REM %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Excludeu\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=ARS
REM %PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\Recover\Excludep\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=ARS

%PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Good\Backup\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=TROVATO
%PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludeu\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=TROVATO
%PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludet\Backup\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=TROVATO
%PROG_FOLDER%\MergeTlogs.exe %POLLING%\Data\RecoverT\Excludep\Tlog*.* %POLLING%\Data\Payroll\paytlogs. FORMAT=TROVATO

REM Create SPLIT payroll file (USA & Canada) (excluding stores on Exclude.dat list).
REM %PROG_FOLDER%\splthr.exe %POLLING%\Data\Payroll\paytlogs. %POLLING%\Data\Payroll\junk1.dat %POLLING%\Data\Payroll\sgushrs2_Corky.txt %POLLING%\Data\Payroll\junk2.dat %POLLING%\Data\Payroll\sgcanhrs2.txt %POLLING%\Poll\AuditWorks\Translate\exclude.dat
%PROG_FOLDER%\spltTRhr.exe %POLLING%\Data\Payroll\paytlogs. %POLLING%\Data\Payroll\junk1.dat %POLLING%\Data\Payroll\sgushrs2_Corky.txt %POLLING%\Data\Payroll\junk2.dat %POLLING%\Data\Payroll\sgcanhrs2.txt %POLLING%\Poll\AuditWorks\Translate\exclude.dat
%PROG_FOLDER%\ScrubPayrollHoursFile %POLLING%\Data\Payroll\sgushrs2_Corky.txt %POLLING%\Data\Payroll\sgushrs2.txt %POLLING%\Data\Payroll\sgushrs2_Bad.txt

REM Backup SPLIT payroll file (USA).
E:
CD \Data\Payroll\Backup
DEL sgushrs2_D07.txt
REN sgushrs2_D06.txt sgushrs2_D07.txt
REN sgushrs2_D05.txt sgushrs2_D06.txt
REN sgushrs2_D04.txt sgushrs2_D05.txt
REN sgushrs2_D03.txt sgushrs2_D04.txt
REN sgushrs2_D02.txt sgushrs2_D03.txt
REN sgushrs2_D01.txt sgushrs2_D02.txt
REN sgushrs2.txt sgushrs2_D01.txt
COPY %POLLING%\Data\Payroll\sgushrs2.txt

E:
CD \Data\Payroll\Backup
DEL sgushrs2_Corky_D07.txt
REN sgushrs2_Corky_D06.txt sgushrs2_Corky_D07.txt
REN sgushrs2_Corky_D05.txt sgushrs2_Corky_D06.txt
REN sgushrs2_Corky_D04.txt sgushrs2_Corky_D05.txt
REN sgushrs2_Corky_D03.txt sgushrs2_Corky_D04.txt
REN sgushrs2_Corky_D02.txt sgushrs2_Corky_D03.txt
REN sgushrs2_Corky_D01.txt sgushrs2_Corky_D02.txt
REN sgushrs2_Corky.txt sgushrs2_Corky_D01.txt
COPY %POLLING%\Data\Payroll\sgushrs2_Corky.txt

E:
CD \Data\Payroll\Backup
DEL sgushrs2_Bad_D07.txt
REN sgushrs2_Bad_D06.txt sgushrs2_Bad_D07.txt
REN sgushrs2_Bad_D05.txt sgushrs2_Bad_D06.txt
REN sgushrs2_Bad_D04.txt sgushrs2_Bad_D05.txt
REN sgushrs2_Bad_D03.txt sgushrs2_Bad_D04.txt
REN sgushrs2_Bad_D02.txt sgushrs2_Bad_D03.txt
REN sgushrs2_Bad_D01.txt sgushrs2_Bad_D02.txt
REN sgushrs2_Bad.txt sgushrs2_Bad_D01.txt
COPY %POLLING%\Data\Payroll\sgushrs2_Bad.txt

REM Backup SPLIT payroll file (Canada).
E:
CD \Data\Payroll\Backup
DEL sgcanhrs2_D07.txt
REN sgcanhrs2_D06.txt sgcanhrs2_D07.txt
REN sgcanhrs2_D05.txt sgcanhrs2_D06.txt
REN sgcanhrs2_D04.txt sgcanhrs2_D05.txt
REN sgcanhrs2_D03.txt sgcanhrs2_D04.txt
REN sgcanhrs2_D02.txt sgcanhrs2_D03.txt
REN sgcanhrs2_D01.txt sgcanhrs2_D02.txt
REN sgcanhrs2.txt sgcanhrs2_D01.txt
COPY %POLLING%\Data\Payroll\sgcanhrs2.txt

%PROG_FOLDER%\CopyFilesB.exe %POLLING%\Data\Payroll\sgushrs2.txt \\sgintmis\sys_share\pos\stores~1\hr sgushrs2.txt TRUE
%PROG_FOLDER%\CopyFilesB.exe %POLLING%\Data\Payroll\sgcanhrs2.txt \\sgintmis\sys_share\pos\stores~1\hr sgcanhrs2.txt TRUE

%PROG_FOLDER%\CopyFilesB.exe %POLLING%\Data\Payroll\sgushrs2.txt \\sgintfinop\ops_shared\payroll\dailypolling sgushrs2.txt TRUE
%PROG_FOLDER%\CopyFilesB.exe %POLLING%\Data\Payroll\sgcanhrs2.txt \\sgintfinop\ops_shared\payroll\dailypolling sgcanhrs2.txt TRUE