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

REM Create payroll file.
E:\Poll\Bin\pullhr.exe E:\Data\Payroll\paytlogs. E:\Data\Payroll\junk.dat E:\Data\Payroll\Payroll.dat

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