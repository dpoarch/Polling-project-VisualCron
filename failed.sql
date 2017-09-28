select session_name, client_name, status, convert(varchar,start_time,1) as start_date, left(convert(varchar,start_time,14),8) as start_time, left(convert(varchar,dateadd(s,duration,'2003-01-01'),14),8), netmgr_name, resource from rwlog_sessionhistory
where start_time >= dateadd(hh,-16,getdate())
  and status_code = 10
  and session_name in ('Polling 1', 'Polling 2', 'Polling 3', 'Polling 4', 'Polling 5', 'Inventory Early Polling')
order by event_file
