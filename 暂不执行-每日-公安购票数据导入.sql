公安购票记录文件导入执行步骤：
1、清空数据库表temp_gongan_skjl中的数据，
执行语句：

delete from  temp_gongan_skjl;


2、整理excel数据，id_card 身份证号码,last_time日期。
导入到数据库表 temp_gongan_skjl 中。