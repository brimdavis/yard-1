:: vhdle -do list.cmd -list results.lst  -t 2000ns  testbench > sym_sim.out
:: vhdle -t 2000ns  testbench > sym_sim.out

vhdle -t 20000ns  -STDOUT sim.out testbench

if errorlevel 1 exit /b 1

