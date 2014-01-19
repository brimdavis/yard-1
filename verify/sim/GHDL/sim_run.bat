::
:: run simulation using GHDL
::

:: ieee-asserts option not present in GHDL 0.25
ghdl -r   --workdir=work.ghd  --ieee=synopsys  testbench --ieee-asserts=disable-at-0  --stop-time=20000ns > sim.out

::ghdl -r   --workdir=work.ghd  --ieee=synopsys  testbench  --stop-time=20000ns > sim.out


