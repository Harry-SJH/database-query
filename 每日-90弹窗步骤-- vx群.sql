90类型健康码弹窗处理语句
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


3、执行从中间表取去重后的数据到正式表语句
##从中间表取去重后的数据到正式表

INSERT INTO health_code_popup_window ( id_card, task_date ) 
SELECT
id_card,
task_date
FROM
  (
  SELECT /*+ QUERY_TIMEOUT(1200000000) */
    a.id_card,
    a.task_date 
  FROM
    temp_health_code_popup_window a
    LEFT JOIN health_code_popup_window b ON a.id_card = b.id_card 
    AND a.task_date = b.task_date 
  WHERE
    b.id_card IS NULL 
  GROUP BY
    a.id_card,
    a.task_date 
  );
  
  
4、-- 临时更新弹窗类型90的health_code_popup_window的核酸数据
CALL update_health_code_popup_window_rnacheck(REPLACE(CURRENT_DATE,'-',''),@result);



5、导出需要弹窗的数据语句（把下边语句的执行结果导出）
##取出需要弹窗的数据

select /*+ QUERY_TIMEOUT(1200000000) */
  id_card  '身份证号',
  task_date '日期',
  '90'  as  '类型'
from health_code_popup_window
where second_check_date is null
  and DATEDIFF(CURRENT_DATE,task_date) < 14;
	
	
##计算数量
select /*+ QUERY_TIMEOUT(1200000000) */
COUNT(*) AS 数量
from health_code_popup_window
where second_check_date is null
  and DATEDIFF(CURRENT_DATE,task_date) < 14;
