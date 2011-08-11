::
:: absolute paths confuse GHDL, use relative paths instead
::
set YC=..\..\hdl\cores\y1a\
set YV=..\..\hdl\systems\sim_rtl\

ghdl -a -v --workdir=work.ghd  --ieee=synopsys  %YC%y1a_config.vhd %YC%y1_constants.vhd %YC%y1a_comps.vhd %YC%y1a_probe_pkg.vhd %YC%pw2_rom.vhd %YC%flip.vhd %YC%ffb.vhd %YC%bitcnt.vhd %YC%rstack.vhd %YC%rf.vhd %YC%y1a_probe.vhd %YC%y1a_core.vhd %YV%rom_dat.vhd %YV%rtl_mem.vhd %YV%stub_uart_rx.vhd %YV%stub_uart_tx.vhd %YV%evb.vhd %YV%evb_tb.vhd 
ghdl -e    --workdir=work.ghd  --ieee=synopsys  testbench 
