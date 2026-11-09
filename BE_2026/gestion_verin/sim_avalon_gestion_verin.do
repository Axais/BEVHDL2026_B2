vlib work
vcom -93 gestion_verin.vhd avalon_gestion_verin.vhd tb_avalon_gestion_verin.vht
vsim -voptargs="+acc" work.tb_avalon_gestion_verin
add wave -divider Bus
add wave /tb_avalon_gestion_verin/clk /tb_avalon_gestion_verin/reset_n /tb_avalon_gestion_verin/chipselect /tb_avalon_gestion_verin/write_n
add wave -radix unsigned /tb_avalon_gestion_verin/address /tb_avalon_gestion_verin/writedata /tb_avalon_gestion_verin/readdata
add wave -divider Registres
add wave -radix unsigned /tb_avalon_gestion_verin/uut/freq /tb_avalon_gestion_verin/uut/duty /tb_avalon_gestion_verin/uut/butee_g /tb_avalon_gestion_verin/uut/butee_d
add wave -radix binary /tb_avalon_gestion_verin/uut/config
add wave -divider Sorties
add wave /tb_avalon_gestion_verin/out_pwm /tb_avalon_gestion_verin/out_sens /tb_avalon_gestion_verin/cs_n /tb_avalon_gestion_verin/clk_adc /tb_avalon_gestion_verin/data_in
run 101 ms
wave zoom full
