select /*+ QUERY_TIMEOUT(1200000000) */
  task_date '日期',
  '90'  as  '类型',
	count(DISTINCT id_card)  as '弹窗人数'
from health_code_popup_window
where second_check_date is null
  and DATEDIFF(CURRENT_DATE,task_date) < 14     /* 参数1-参数2 返回天数 */
	group by task_date;
