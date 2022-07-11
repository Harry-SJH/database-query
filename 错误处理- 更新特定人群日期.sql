-- update health_code_popup_window_rjfj set task_date=date_add(task_date,INTERVAL 1 DAY) where id_card in (select id_card from temp_health_code_popup_window);

-- select * from temp_health_code_popup_window

UPDATE health_code_popup_window_rjfj
SET task_date = date_add( task_date, INTERVAL 1 DAY ) 
WHERE
	id IN ( SELECT w.id FROM temp_health_code_popup_window wt LEFT JOIN health_code_popup_window_rjfj w ON w.id_card = wt.id_card WHERE w.task_date = '2022-06-04' AND w.task_date = '2022-06-04');

