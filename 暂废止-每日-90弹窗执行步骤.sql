4月10日 10:5490弹窗执行步骤：
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

insert into health_code_popup_window
  (id_card,
  task_date
  )
SELECT
  t.id_card,
  t.task_date 
FROM
  (SELECT ROW_NUMBER() OVER( PARTITION BY id_card ORDER BY task_date ) AS rn,* 
    FROM temp_health_code_popup_window
  ) t
  LEFT JOIN 
    (select * from health_code_popup_window
    where second_check_date is null
    and DATEDIFF(CURRENT_DATE,task_date) < 14
    ) n 
  ON t.id_card = n.id_card 
WHERE t.rn = 1 
  AND n.id_card IS NULL;
  
  
-- 临时更新弹窗类型90的health_code_popup_window的核酸数据
-- 2022-04-08
#4、执行update 第一次核酸检测时间语句
##正式表update第一次核酸检测时间为空(更新过以后又上传了历史记录)

UPDATE /*+ QUERY_TIMEOUT(1200000000) */
health_code_popup_window a
JOIN (
  SELECT
/*+ QUERY_TIMEOUT(1200000000) */
    ROW_NUMBER() OVER ( PARTITION BY b.card_no ORDER BY b.check_date ) AS rn,
    b.card_no 
  FROM
    health_code_popup_window a
    JOIN datav_rnacheck_data_month b ON a.id_card = b.card_no 
    AND b.card_type = '身份证' 
    AND a.first_check_date > b.check_date 
    AND date( a.task_date ) <= date( b.check_date ) 
  WHERE
    a.first_check_date IS NOT NULL 
    AND a.second_check_date IS NULL 
  ) b ON a.id_card = b.card_no 
  AND b.rn = 1 
  SET a.first_check_date = NULL;
  

##正式表update第一次核酸检测时间

UPDATE /*+ QUERY_TIMEOUT(1200000000) */
health_code_popup_window n
JOIN (
  SELECT
/*+ QUERY_TIMEOUT(1200000000) */
    ROW_NUMBER() OVER ( PARTITION BY card_no ORDER BY check_date ) AS rn,
    card_no,
    check_date 
  FROM
    health_code_popup_window n
    JOIN datav_rnacheck_data_month hs ON n.id_card = hs.card_no 
    AND date( hs.check_date ) >= date( n.task_date ) 
  WHERE
    n.first_check_date IS NULL 
  ) hs ON n.id_card = hs.card_no 
  AND hs.rn = 1 
  SET n.first_check_date = hs.check_date;
  

#5、执行update第二次核酸检测时间语句
##正式表update第二次核酸检测时间

UPDATE /*+ QUERY_TIMEOUT(1200000000) */
health_code_popup_window n
JOIN (
  SELECT
/*+ QUERY_TIMEOUT(1200000000) */
    ROW_NUMBER() OVER ( PARTITION BY card_no ORDER BY check_date DESC ) AS rn,
    card_no,
    check_date 
  FROM
    health_code_popup_window n
    JOIN datav_rnacheck_data_month hs ON n.id_card = hs.card_no 
    AND DATEDIFF( hs.check_date, n.first_check_date ) >= 1 
  WHERE
    n.first_check_date IS NOT NULL 
    AND n.second_check_date IS NULL 
  ) hs ON n.id_card = hs.card_no 
  AND hs.rn = 1 
  SET n.second_check_date = hs.check_date;

6、导出需要弹窗的数据语句（把下边语句的执行结果导出）
##取出需要弹窗的数据


select /*+ QUERY_TIMEOUT(1200000000) */
  id_card  '身份证号',
  task_date '日期',
  '90'  as  '类型'
from health_code_popup_window
where second_check_date is null
  and DATEDIFF(CURRENT_DATE,task_date) < 14;

