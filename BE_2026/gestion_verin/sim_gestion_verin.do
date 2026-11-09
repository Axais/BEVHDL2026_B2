vlib work
vcom -93 gestion_verin.vhd tb_gestion_verin.vht
vsim -voptargs="+acc" work.tb_gestion_verin
add wave -divider Entrees
add wave /tb_gestion_verin/clk /tb_gestion_verin/raz_n
add wave -radix unsigned /tb_gestion_verin/freq /tb_gestion_verin/duty
add wave /tb_gestion_verin/enable_pwm /tb_gestion_verin/sens
add wave -radix unsigned /tb_gestion_verin/butee_g /tb_gestion_verin/butee_d
add wave /tb_gestion_verin/data_in
add wave -divider Internes
add wave -radix unsigned /tb_gestion_verin/uut/compteur
add wave /tb_gestion_verin/uut/pwm /tb_gestion_verin/uut/top_1M /tb_gestion_verin/uut/start_conv /tb_gestion_verin/uut/ep
add wave -radix unsigned /tb_gestion_verin/uut/nb_fronts
add wave -radix binary /tb_gestion_verin/uut/registre
add wave -divider Sorties
add wave /tb_gestion_verin/out_pwm /tb_gestion_verin/out_sens /tb_gestion_verin/cs_n /tb_gestion_verin/clk_adc
add wave -radix unsigned /tb_gestion_verin/angle_barre
add wave /tb_gestion_verin/fin_course_g /tb_gestion_verin/fin_course_d
run 305 ms
wave zoom full
