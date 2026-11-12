configure wave -signalnamewidth 1
delete wave *
add wave -radix unsigned sim:/tb_gestion_verin/freq sim:/tb_gestion_verin/duty
add wave sim:/tb_gestion_verin/enable_pwm
add wave -format Analog-Step -height 100 -min 0 -max 2000 -radix unsigned sim:/tb_gestion_verin/uut/compteur
add wave sim:/tb_gestion_verin/uut/pwm sim:/tb_gestion_verin/out_pwm
wave zoom range 150us 500us
