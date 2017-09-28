REM Convert downloaded purchase orders into readable format
PAUSE
E:
CD \Data\PollSend
IF EXIST Mail*.bak DEL Mail*.bak
IF EXIST Mail*. REN Mail*. Mail*.bak
\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Data\PollSend\PO.tmp \\sghpnas\pos\Data\PollSend FORMAT=ARS
COPY Mail*. PO*.
DEL Mail*.
IF EXIST Mail*.bak REN Mail*.bak Mail*.
DEL PO.tmp
PAUSE
CLS
DIR PO*.
PAUSE