1、清空数据库表temp_tongguan_dianxin中的数据，
执行语句：

delete from  temp_tongguan_dianxin;

2、清空数据库表temp_tongguan_yidong中的数据，
执行语句：

delete from  temp_tongguan_yidong;

3、公安提供的数据TICKET_STATUS 是Z的放一张表，T和F的放一张表，G的删除不用；
整理数据：phone不重复的序号，id_card 身份证号，last_time 日期，name 车次

##TICKET_STATUS 是Z的导入 temp_tongguan_dianxin；
##TICKET_STATUS 是T和F的导入 temp_tongguan_yidong;

4、执行下面语句导出比对后的铁路购票信息：
SELECT id_card,last_time as task_date  from temp_tongguan_dianxin where phone not in(
select b.phone from temp_tongguan_yidong a,temp_tongguan_dianxin b
where b.id_card=a.id_card
and b.`name`=a.`name`)