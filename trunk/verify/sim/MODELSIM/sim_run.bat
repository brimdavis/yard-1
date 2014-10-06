::
:: run Modelsim simulator
::
vsim  -c testbench  -lib yardsim  -do "run 20000 ns;quit"  > sim.out 

if errorlevel 1 exit /b 1


::
:: remove leading "# " that modelsim adds to writeline outputs
:: use perl one-liner to do in-place edit of output file
::
perl -p -i.bak -e "s/^# //g" sim.out


