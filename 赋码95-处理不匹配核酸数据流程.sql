-- 处理不匹配核酸数据流程，直接弹窗
执行步骤：
1、清空数据库表temp_health_code_popup_window中的数据，
执行语句：

delete from  temp_health_code_popup_window;



2、整理excel数据，只要身份证号码(id_card)和任务下达时间(task_date)两个字段。
导入到数据库表 temp_health_code_popup_window 中。

！！！注意：检查一下导入的数据中任务下达时间(task_date)字段的时间格式是否和源excel表一致。


update  /*+ QUERY_TIMEOUT(1200000000) */ temp_health_code_popup_window  set id_card=
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
id_card,
char(9),''),char(10),''),char(13),''),char(conv( '20', 16, 10 )),''), 
' ',''),'，',''),'\'',''),',',''),'‘',''),'.',''),'’',''),' ',''),'、',''),'/',''),'×','X'),'',''),
'　',''),'+',''),'[',''),']',''),'-',''),'；',''),'Ｘ','X'),'`',''),'\\',''),'~',''),'*',''),'“',''),'！',''),'!',''),
'。',''),';',''),'\\r',''),'\\n','');


3、执行从中间表取数据到正式表语句
##从中间表取去重后的数据到正式表

INSERT INTO health_code_popup_window_3 ( id_card, task_date, type_code ) SELECT
id_card,
task_date,
'95' -- 根据弹窗类型需要赋的值
FROM
  temp_health_code_popup_window;

---查询总数量
select count(1)  from health_code_popup_window_3;