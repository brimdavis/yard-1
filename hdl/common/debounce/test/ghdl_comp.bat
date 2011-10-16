ghdl -a -v --workdir=work.ghd  --ieee=synopsys  ..\debounce.vhd ..\debounce_tick.vhd debounce_tb.vhd 
ghdl -e    --workdir=work.ghd  --ieee=synopsys  testbench 
