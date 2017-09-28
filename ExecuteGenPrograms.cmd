@set PROG_FOLDER=%POLLING%\Poll\Bin

del %PROG_FOLDER%\ExecuteGenPrograms.flg

if exist %POLLING%\Temp\GenNode.ec_ del %POLLING%\Temp\GenNode.ec_
if exist %PROG_FOLDER%\ExecuteGenNode.flg C:\RWS\System\GenNode.exe %POLLING%\Temp\GenNode.ec_
if exist %PROG_FOLDER%\ExecuteGenNode.flg copy %POLLING%\Temp\GenNode.ec_ \\sgsql\FileTransfer\RWManager\GenNode.ec_
if exist %PROG_FOLDER%\ExecuteGenNode.flg del %PROG_FOLDER%\ExecuteGenNode.flg

if exist %POLLING%\Temp\GennGrp.ec_ del %POLLING%\Temp\GennGrp.ec_
if exist %PROG_FOLDER%\ExecuteGennGrp.flg C:\RWS\System\GennGrp.exe %POLLING%\Temp\GennGrp.ec_
if exist %PROG_FOLDER%\ExecuteGennGrp.flg copy %POLLING%\Temp\GennGrp.ec_ \\sgsql\FileTransfer\RWManager\GennGrp.ec_
if exist %PROG_FOLDER%\ExecuteGennGrp.flg del %PROG_FOLDER%\ExecuteGennGrp.flg

if exist %POLLING%\Temp\GenSwo.ec_ del %POLLING%\Temp\GenSwo.ec_
if exist %PROG_FOLDER%\ExecuteGenSwo.flg C:\RWS\System\GenSwo.exe %POLLING%\Temp\GenSwo.ec_
if exist %PROG_FOLDER%\ExecuteGenSwo.flg copy %POLLING%\Temp\GenSwo.ec_ \\sgsql\FileTransfer\RWManager\GenSwo.ec_
if exist %PROG_FOLDER%\ExecuteGenSwo.flg del %PROG_FOLDER%\ExecuteGenSwo.flg

if exist \\sgsql\FileTransfer\RWManager\swo*.* del \\sgsql\FileTransfer\RWManager\swo*.*