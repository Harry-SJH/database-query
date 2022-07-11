-- 处理重点涉疫地区入冀返冀临时91类型数据流程（匹配两次核酸）
执行步骤：
1、清空数据库表temp_health_code_popup_window中的数据，
执行语句：

delete from  temp_health_code_popup_window;

2、整理excel数据，只要身份证号码(id_card)和任务下达时间(task_date)两个字段。
导入到数据库表 temp_health_code_popup_window 中。
！！！注意：检查一下导入的数据中任务下达时间(task_date)字段的时间格式是否和源excel表一致。

-- 初步清洗身份证号码
update  /*+ QUERY_TIMEOUT(1200000000) */ temp_health_code_popup_window  set id_card=
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
id_card,
char(9),''),char(10),''),char(13),''),char(conv( '20', 16, 10 )),''), 
' ',''),'，',''),'\'',''),',',''),'‘',''),'.',''),'’',''),' ',''),'、',''),'/',''),'×','X'),'',''),
'　',''),'+',''),'[',''),']',''),'-',''),'；',''),'Ｘ','X'),'`',''),'\\',''),'~',''),'*',''),'“',''),'！',''),'!',''),
'。',''),';',''),'\\r',''),'\\n','');


3、执行从中间表取去重后的数据到正式表语句
##从中间表取去重以及和正式表去重后的数据到正式表

INSERT INTO health_code_popup_window_rjfj ( id_card, task_date, type_code ) SELECT
id_card,
task_date,
'91' -- 弹窗类型需要赋的值
FROM
	(
	SELECT /*+ QUERY_TIMEOUT(1200000000) */
		a.id_card,
		a.task_date 
	FROM
		temp_health_code_popup_window a
		LEFT JOIN health_code_popup_window_rjfj b ON a.id_card = b.id_card 
		AND a.task_date = b.task_date 
	WHERE
		b.id_card IS NULL 
	GROUP BY
		a.id_card,
		a.task_date 
	);
	
	
4、两次核酸初步打标

CALL update_health_code_popup_window_rjfj_rnacheck(REPLACE(CURRENT_DATE,'-',''),@result)
	
	