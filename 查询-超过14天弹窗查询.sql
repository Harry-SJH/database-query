SELECT
card_no '身份证',
gmt_create '最后弹窗日期',
	* 
FROM
	health_code_popup_code 
WHERE
	card_no = '130429198911104637' 
ORDER BY
	gmt_create DESC;