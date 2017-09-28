@ECHO Merge tlogs into IpLogs and UpLogs files.
@ECHO.
@PAUSE

CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Poll\Tlog\Good\Backup E:\Poll\Upload\IpLogs.
CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Poll\Tlog\Good\Backup\NoUpload E:\Poll\Upload\IpLogs. APPEND
CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Data\Recover\Good\Backup E:\Poll\Upload\IpLogs. APPEND
CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Data\Recover\Good\Backup\NoUpload E:\Poll\Upload\IpLogs. APPEND

CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Poll\Tlog\Good\Backup E:\Poll\Upload\UpLogs.
CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Poll\Tlog\Good\UploadOnly E:\Poll\Upload\UpLogs. APPEND
CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Data\Recover\Good\Backup E:\Poll\Upload\UpLogs. APPEND
CALL E:\Poll\Bin\MergeTlogs.exe DIR E:\Data\Recover\Good\UploadOnly E:\Poll\Upload\UpLogs. APPEND

@ECHO.
@DIR E:\Poll\Upload\UpLogs

@ECHO.
@ECHO Program Complete!
@ECHO.
@PAUSE

:END
