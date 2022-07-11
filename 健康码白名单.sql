执行步骤：
1、清空数据库表temp_health_code_whitelist 临时白名单中的数据，
执行语句：

delete from temp_health_code_whitelist;

2、整理excel数据，card_no(证件号码)、
code_type(白名单码类型（红码/黄码/弹窗）)、end_time(白名单有效期止)字段。
导入到数据库表 temp_health_code_whitelist 中。

update temp_health_code_whitelist set card_no =
replace(replace(replace(replace(replace(replace(replace(replace(
replace(replace(replace(replace(replace(replace(replace(replace(
replace(replace(replace(replace(replace(replace(replace(replace(
replace(replace(replace(replace(replace(replace(replace(replace(
replace(replace(card_no,
char(9),''),char(10),''),char(13),''),char(conv( '20', 16, 10 )),''), 
' ',''),'，',''),'\'',''),',',''),'‘',''),'.',''),'’',''),' ',''),'、',''),'/',''),'×','X'),'',''),
'　',''),'+',''),'[',''),']',''),'-',''),'；',''),'Ｘ','X'),'`',''),'\\',''),'~',''),'*',''),'“',''),'！',''),'!',''),
'。',''),';',''),'\\r',''),'\\n','');


3、执行从中间表取数到正式白名单表语句

insert into health_code_whitelist
  (card_no,
  code_type,
  end_time
  )
SELECT
  card_no,
  code_type,
  end_time
FROM temp_health_code_whitelist;