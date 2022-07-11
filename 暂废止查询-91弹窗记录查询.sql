select /*+ QUERY_TIMEOUT(1200000000) */
  task_date '日期',
  '91'  as  '类型',
	*
from health_code_popup_window_rjfj
where type_code='91'
and id_card ='231181199208130241'

