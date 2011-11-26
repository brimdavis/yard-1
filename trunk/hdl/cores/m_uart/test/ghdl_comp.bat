ghdl -a -v --workdir=work.ghd  --ieee=synopsys  ..\m_uart_pkg.vhd ..\m_uart.vhd m_uart_tb.vhd 
ghdl -e    --workdir=work.ghd  --ieee=synopsys  testbench 
