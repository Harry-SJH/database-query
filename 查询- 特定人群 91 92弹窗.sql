-- select /*+ QUERY_TIMEOUT(1200000000) */
--   task_date '日期',
--   type_code as  '类型',
-- 	*
-- from health_code_popup_window_rjfj
-- where  id_card ='229002196912240197'  and DATEDIFF(CURRENT_DATE,task_date) < 14

select /*+ QUERY_TIMEOUT(1200000000) */
  task_date '日期',
  type_code as  '类型',
	*
from health_code_popup_window_rjfj
where  id_card ='130521199210136264'