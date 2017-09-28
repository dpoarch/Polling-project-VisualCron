REM This program creates a payroll file for Del Ray.
REM Delete last week's data.
E:
CD \Data\Payroll
DEL paytlogs.
DEL Payroll.dat

REM Process recovered tlogs.
E:
CD \Poll\Bin
CALL E:\Poll\Bin\ProcessRecoveredTlogs.cmd

REM Merge recovered tlogs.
E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Good\Backup\Tlog*.* E:\Data\Payroll\paytlogs. FORMAT=ARS
E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Excludeu\Tlog*.* E:\Data\Payroll\paytlogs. FORMAT=ARS
E:\Poll\Bin\MergeTlogs.exe E:\Data\Recover\Excludep\Tlog*.* E:\Data\Payroll\paytlogs. FORMAT=ARS

REM Create payroll file. (excluding stores on Exclude.dat list)
E:\Poll\Bin\pullhr.exe E:\Data\Payroll\paytlogs. E:\Data\Payroll\junk.dat E:\Data\Payroll\Payroll.dat E:\Poll\AuditWorks\Translate\exclude.dat

REM Backup payroll file.
E:
CD \Data\Payroll\Backup
DEL Payroll_D07.dat
REN Payroll_D06.dat Payroll_D07.dat
REN Payroll_D05.dat Payroll_D06.dat
REN Payroll_D04.dat Payroll_D05.dat
REN Payroll_D03.dat Payroll_D04.dat
REN Payroll_D02.dat Payroll_D03.dat
REN Payroll_D01.dat Payroll_D02.dat
REN Payroll.dat Payroll_D01.dat
COPY E:\Data\Payroll\Payroll.dat


REM Create SPLIT payroll file (USA & Canada).
E:\Poll\Bin\splthr.exe E:\Data\Payroll\paytlogs. E:\Data\Payroll\junk1.dat E:\Data\Payroll\sgushrs2.txt E:\Data\Payroll\junk2.dat E:\Data\Payroll\sgcanhrs2.txt

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
COPY E:\Data\Payroll\sgushrs2.txt

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
COPY E:\Data\Payroll\sgcanhrs2.txt