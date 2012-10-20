ghdl -a -v --workdir=work.ghd  ..\m_uart_pkg.vhd ..\simple_baud_gen.vhd ..\m_uart.vhd m_uart_tb.vhd 
ghdl -e    --workdir=work.ghd  testbench 
