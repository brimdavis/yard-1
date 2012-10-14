ghdl -a -v --workdir=work.ghd  ..\debounce.vhd ..\debounce_tick.vhd bouncify.vhd debounce_tb.vhd 
ghdl -e    --workdir=work.ghd  testbench 
