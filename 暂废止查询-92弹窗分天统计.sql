##92分天统计数据
SELECT
  DATE( gmt_create ) AS '数据导入推送时间',
  count(*) AS '推送数量',
  count( DISTINCT id_card ) AS '推送的人数',
  count( CASE WHEN first_check_date IS NULL THEN id_card END ) AS '现在无核酸数量',
  count( DISTINCT CASE WHEN first_check_date IS NULL THEN id_card END ) AS '现在无核酸人数' 
FROM
  `health_code_popup_window_4` 
	where DATEDIFF( CURRENT_DATE, task_date ) <16
GROUP BY
  DATE(gmt_create)