::
:: Run Aldec simulator
::
vsim  -c testbench  -lib yardsim  -do "run 20000 ns"  > sim.out 

if errorlevel 1 exit /b 1


::
:: remove leading "KERNEL: " that Aldec adds to writeline outputs
:: use perl one-liner to do in-place edit of output file
::
perl -p -i.bak -e "s/^KERNEL: //g" sim.out