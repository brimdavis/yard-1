#
# timing constraints
#
create_clock -period 10.000 -waveform {0.000 5.000} [get_ports clk_in]

# Config bank
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#
# I/O constraints
#

#
# clk & control
#
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_in]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports reset_pb]
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports irq_pb]


#
# UART
#
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports tx_bit]
set_property -dict {PACKAGE_PIN A9  IOSTANDARD LVCMOS33} [get_ports rx_bit]


#
# LEDs
#
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33}  [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33}  [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33}  [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33}  [get_ports {led[0]}]

set_property -dict {PACKAGE_PIN K1  IOSTANDARD LVCMOS33}  [get_ports {led_r[3]}]
set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33}  [get_ports {led_r[2]}]
set_property -dict {PACKAGE_PIN G3  IOSTANDARD LVCMOS33}  [get_ports {led_r[1]}]
set_property -dict {PACKAGE_PIN G6  IOSTANDARD LVCMOS33}  [get_ports {led_r[0]}]

set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVCMOS33}  [get_ports {led_g[3]}]
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33}  [get_ports {led_g[2]}]
set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS33}  [get_ports {led_g[1]}]
set_property -dict {PACKAGE_PIN F6  IOSTANDARD LVCMOS33}  [get_ports {led_g[0]}]

set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33}  [get_ports {led_b[3]}]
set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVCMOS33}  [get_ports {led_b[2]}]
set_property -dict {PACKAGE_PIN G4  IOSTANDARD LVCMOS33}  [get_ports {led_b[1]}]
set_property -dict {PACKAGE_PIN E1  IOSTANDARD LVCMOS33}  [get_ports {led_b[0]}]


#
# Switches
#
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33}  [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33}  [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33}  [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33}  [get_ports {sw[0]}]

