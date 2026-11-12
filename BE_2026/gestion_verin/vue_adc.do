configure wave -signalnamewidth 1
delete wave *
add wave sim:/tb_gestion_verin/uut/start_conv sim:/tb_gestion_verin/uut/ep sim:/tb_gestion_verin/cs_n sim:/tb_gestion_verin/clk_adc sim:/tb_gestion_verin/data_in
add wave -radix unsigned sim:/tb_gestion_verin/uut/nb_fronts
add wave -radix binary sim:/tb_gestion_verin/uut/registre
add wave -radix unsigned sim:/tb_gestion_verin/angle_barre
wave zoom range 99995us 100035us
