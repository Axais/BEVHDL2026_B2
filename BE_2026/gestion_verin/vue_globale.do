configure wave -signalnamewidth 1
delete wave *
add wave sim:/tb_gestion_verin/enable_pwm sim:/tb_gestion_verin/sens
add wave -radix unsigned sim:/tb_gestion_verin/butee_g sim:/tb_gestion_verin/butee_d
add wave sim:/tb_gestion_verin/cs_n
add wave -radix unsigned sim:/tb_gestion_verin/angle_barre
add wave sim:/tb_gestion_verin/fin_course_g sim:/tb_gestion_verin/fin_course_d sim:/tb_gestion_verin/out_pwm
wave zoom range 0ms 305ms
