select /*+ QUERY_TIMEOUT(1200000000) */
  id_card  '身份证号',
  task_date '日期',
  '90'  as  '类型',
	first_check_date '第一次核酸检测日期',
	second_check_date '第二次核酸检测日期',
	gmt_create '创建日期'
from health_code_popup_window
where  DATEDIFF(CURRENT_DATE,task_date) < 14
	and  id_card in (select temp_health_code_popup_window.id_card from temp_health_code_popup_window)