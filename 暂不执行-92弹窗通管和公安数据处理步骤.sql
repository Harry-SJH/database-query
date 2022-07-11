1、清理92的临时目标表
TRUNCATE temp_health_code_popup_window_4;

2、进行通管三家运营商的数据补全，根据手机号码匹配实名信息补全身份证
UPDATE /*+ QUERY_TIMEOUT(120000000000) */ temp_tongguan_yidong m
JOIN (
SELECT
qc.identity,
qc.NAME,
qc.phone,
row_number() over ( PARTITION BY qc.phone ORDER BY qc.aut_time DESC ) AS rn 
FROM
(
SELECT
b.identity,
b.NAME,
b.phone,
b.aut_time 
FROM
temp_tongguan_yidong a
JOIN realname_aut b ON a.phone = b.phone 
) qc 
) n ON m.phone = n.phone 
AND n.rn = 1 
SET m.NAME = n.NAME,
m.id_card = n.identity ;


UPDATE /*+ QUERY_TIMEOUT(120000000000) */ temp_tongguan_liantong m
JOIN (
SELECT
qc.identity,
qc.NAME,
qc.phone,
row_number() over ( PARTITION BY qc.phone ORDER BY qc.aut_time DESC ) AS rn 
FROM
(
SELECT
b.identity,
b.NAME,
b.phone,
b.aut_time 
FROM
temp_tongguan_liantong a
JOIN realname_aut b ON a.phone = b.phone 
) qc 
) n ON m.phone = n.phone 
AND n.rn = 1 
SET m.NAME = n.NAME,
m.id_card = n.identity ;


UPDATE /*+ QUERY_TIMEOUT(120000000000) */ temp_tongguan_dianxin m
JOIN (
SELECT
qc.identity,
qc.NAME,
qc.phone,
row_number() over ( PARTITION BY qc.phone ORDER BY qc.aut_time DESC ) AS rn 
FROM
(
SELECT
b.identity,
b.NAME,
b.phone,
b.aut_time 
FROM
temp_tongguan_dianxin a
JOIN realname_aut b ON a.phone = b.phone 
) qc 
) n ON m.phone = n.phone 
AND n.rn = 1 
SET m.NAME = n.NAME,
m.id_card = n.identity ;


3、通管数据和公安数据汇入归总临时表，用于数据比对去重统计等等
INSERT INTO temp_health_code_popup_window_4 ( id_card, task_date,type_code ) SELECT
id_card,
date( last_time ),
'中国移动' as type_code
FROM
temp_tongguan_yidong ;

INSERT INTO temp_health_code_popup_window_4 ( id_card, task_date ,type_code) SELECT
id_card,
date( last_time ),
'中国联通' as type_code 
FROM
temp_tongguan_liantong ;

INSERT INTO temp_health_code_popup_window_4 ( id_card, task_date,type_code ) SELECT
id_card,
date( last_time ),
'中国电信' as type_code
FROM
temp_tongguan_dianxin ;

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

CALL temp_update_temp_window_4_rnacheck(20220425,@result);



6、通管数据更标汇总
UPDATE temp_health_code_popup_window_4 SET type_code ='通管数据' where type_code!='公安买票';


7、统计

1)、通管提供2022-04-18落位河北手机号757180条,
SELECT task_date,count(*) FROM temp_health_code_popup_window_4 WHERE type_code='通管数据' GROUP BY task_date;


2)、用健康码匹配身份证267221条，自身去重5683条，与公安去重2802条，剩余258736条，匹配有核酸60259条，无核酸198477条,
SELECT
	'健康码匹配身份证',
	count(*) 
FROM
	temp_health_code_popup_window_4 
WHERE
	type_code = '通管数据' 
	AND id_card IS NOT NULL UNION ALL
SELECT
	'自身去重',
	count( CASE WHEN type_code = '通管数据' AND id_card IS NOT NULL THEN uid END )- count( DISTINCT CASE WHEN type_code = '通管数据' AND id_card IS NOT NULL THEN id_card END ) 
FROM
	temp_health_code_popup_window_4 UNION ALL
SELECT
	'与公安去重',
	count( DISTINCT id_card ) 
FROM
	temp_health_code_popup_window_4 
WHERE
	type_code = '通管数据' 
	AND id_card IS NOT NULL 
	AND id_card IN ( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '公安买票' ) UNION ALL
SELECT
	'剩余',
	count( 1 ) 
FROM
	( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '通管数据' AND id_card IS NOT NULL ) a
	LEFT JOIN ( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '公安买票' ) b ON a.id_card = b.id_card 
WHERE
	b.id_card IS NULL UNION ALL
SELECT
	'匹配有核酸',
	count( 1 ) 
FROM
	( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '通管数据' AND id_card IS NOT NULL AND first_check_date IS NOT NULL ) a
	LEFT JOIN ( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '公安买票' ) b ON a.id_card = b.id_card 
WHERE
	b.id_card IS NULL UNION ALL
SELECT
	'无核酸',
	count( 1 ) 
FROM
	( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '通管数据' AND id_card IS NOT NULL AND first_check_date IS NULL ) a
	LEFT JOIN ( SELECT DISTINCT id_card FROM temp_health_code_popup_window_4 WHERE type_code = '公安买票' ) b ON a.id_card = b.id_card 
WHERE
	b.id_card IS NULL;
	
	
	
	
	
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

CALL temp_update_temp_window_4_rnacheck(20220425,@result);

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
	
	
	