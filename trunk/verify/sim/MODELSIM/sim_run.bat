::
:: *** UNTESTED MODELSIM SCRIPTING ***
::
vsim  -c testbench  -lib yardsim  -do "run 20000 ns"  > sim.out 

if errorlevel 1 exit /b 1

