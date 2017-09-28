REM Convert downloaded PLU into readable format
PAUSE
E:
CD \Data\PollSend
IF EXIST Mail*.bak DEL Mail*.bak
IF EXIST Mail*. REN Mail*. Mail*.bak
\\sghpnas\pos\Poll\Bin\SplitMail.exe \\sghpnas\pos\Data\PollSend\FullPLU.tmp \\sghpnas\pos\Data\PollSend FORMAT=ARS
COPY Mail*. Full*.plu
DEL Mail*.
IF EXIST Mail*.bak REN Mail*.bak Mail*.
DEL FullPLU.tmp
PAUSE
CLS
DIR Full*.plu
PAUSE