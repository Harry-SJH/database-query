-----根据导入临时表的数据删除对应任务日期的数据

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


3、检查待删除的身份证数量和任务日期是不是正确，如果不正确重新执行上面两部重新导入-health_code_popup_window_rjfj-91数据批量--health_code_popup_window_3  95数据删除

select  * from temp_health_code_popup_window;
 
4、如果想要删除某批人员,按照对应身份证号码还有任务日期一致才能删除

DELETE a 
FROM
 health_code_popup_window_rjfj a
 JOIN temp_health_code_popup_window b ON a.id_card = b.id_card 
 AND a.task_date = b.task_date;