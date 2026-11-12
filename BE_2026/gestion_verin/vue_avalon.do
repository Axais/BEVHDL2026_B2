configure wave -signalnamewidth 1
delete wave *
add wave sim:/tb_avalon_gestion_verin/clk sim:/tb_avalon_gestion_verin/chipselect sim:/tb_avalon_gestion_verin/write_n
add wave -radix unsigned sim:/tb_avalon_gestion_verin/address sim:/tb_avalon_gestion_verin/writedata sim:/tb_avalon_gestion_verin/readdata
add wave -radix unsigned sim:/tb_avalon_gestion_verin/uut/freq sim:/tb_avalon_gestion_verin/uut/duty sim:/tb_avalon_gestion_verin/uut/butee_g sim:/tb_avalon_gestion_verin/uut/butee_d
add wave -radix binary sim:/tb_avalon_gestion_verin/uut/config
wave zoom range 0ns 700ns
