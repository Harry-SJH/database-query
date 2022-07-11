SELECT
card_no '身份证',
gmt_create '最后弹窗日期',* 
FROM
	health_code_popup_code 
WHERE
	card_no in (select temp_health_code_popup_window.id_card from temp_health_code_popup_window)
ORDER BY
	gmt_create DESC;