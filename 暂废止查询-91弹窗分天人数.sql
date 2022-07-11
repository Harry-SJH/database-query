select /*+ QUERY_TIMEOUT(1200000000) */
  task_date '日期',
  '91'  as  '类型',
	count(DISTINCT id_card)  as '弹窗人数'
from health_code_popup_window_rjfj
where type_code='91'
and second_check_date is null
 and DATEDIFF(CURRENT_DATE,task_date) < 14
	group by task_date;
	
