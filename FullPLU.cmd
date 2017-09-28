IF EXIST %POLLING%\Data\PollSend\Full%1.plu DEL %POLLING%\Data\PollSend\Full%1.plu
IF EXIST %POLLING%\Data\PollSend\Mail%1.bak DEL %POLLING%\Data\PollSend\Mail%1.bak
IF EXIST %POLLING%\Data\PollSend\Mail%1 REN %POLLING%\Data\PollSend\Mail%1 Mail%1.bak
CALL %POLLING%\Poll\Bin\SplitMail.exe %POLLING%\Data\PollSend\FullPLU.tmp %POLLING%\Data\PollSend NOSITELIST %1
REN %POLLING%\Data\PollSend\Mail%1 Full%1.plu
IF EXIST %POLLING%\Data\PollSend\Mail%1.bak REN %POLLING%\Data\PollSend\Mail%1.bak Mail%1
DEL %POLLING%\Data\PollSend\FullPLU.tmp
