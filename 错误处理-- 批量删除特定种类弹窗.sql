DELETE  from health_code_popup_window_rjfj where type_code = '92' and task_date = '2022-06-24' and second_check_date is null;

#测试正确性
SELECT COUNT(*)  from health_code_popup_window_rjfj where type_code = '92' and task_date = '2022-06-23' and second_check_date is null;