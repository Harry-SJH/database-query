
SELECT
  id_card '身份证号',
  task_date '日期',
  type_code AS '类型' ,
	first_check_date '核酸检测时间',
	gmt_create '赋弹窗时间'
FROM
  health_code_popup_window_4 
WHERE DATEDIFF( CURRENT_DATE, task_date ) < 14 
	and id_card ='210502197008272117'
