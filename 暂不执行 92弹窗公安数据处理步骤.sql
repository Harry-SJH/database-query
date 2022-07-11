1、清理92的临时目标表
TRUNCATE temp_health_code_popup_window_4;


3、公安数据汇入归总临时表，用于数据比对去重统计等等

INSERT INTO `temp_health_code_popup_window_4` ( id_card, task_date, type_code ) SELECT
id_card,
last_time,
'公安买票' AS type_code 
FROM
	temp_gongan_skjl;

4、核对导入的数据量是否正确,
SELECT type_code,count(*) FROM temp_health_code_popup_window_4 GROUP BY type_code;
若正确执行下一步流程，不正确则重第1步重新开始。


5、执行更新核酸检测时间

CALL temp_update_temp_window_4_rnacheck(20220504,@result);


7、统计
3)、公安买票数据统计
公安买票28403条，公安买票数据去重后21899人，公安买票数据去重后人数有核酸16836人，公安买票数据去重后人数无核酸5063人。

SELECT '买票条数',count(*) FROM temp_health_code_popup_window_4 WHERE type_code='公安买票'
union all
SELECT '买票数据去重后人数',count(DISTINCT Id_Card) FROM temp_health_code_popup_window_4 WHERE type_code='公安买票' AND id_card IS NOT NULL
union all
SELECT '买票数据去重后人数有核酸人数',count(DISTINCT Id_Card) FROM temp_health_code_popup_window_4 WHERE type_code='公安买票' AND id_card IS NOT NULL AND first_check_date IS NOT NULL
union all
SELECT '买票数据去重后人数无核酸人数',count(DISTINCT Id_Card) FROM temp_health_code_popup_window_4 WHERE type_code='公安买票' AND id_card IS NOT NULL AND first_check_date IS NULL;


8、第9步执行前再次执行更新核酸检测时间

CALL temp_update_temp_window_4_rnacheck(20220504,@result);

9、仅仅把公安数据导入正式表正式推送政府服务办！！执行一次即可！！！
INSERT INTO health_code_popup_window_4 ( id_card, task_date, first_check_date, type_code ) SELECT
id_card,
task_date,
first_check_date,
'92' 
FROM
	temp_health_code_popup_window_4 
WHERE
	type_code = '公安买票';
	
	
	