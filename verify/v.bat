::
:: verify script, call with path to subdirectory containing test
::

::
:: assemble, link, copy object file to simulation target directory
::
call yas     %1\%~n1.s    || exit /b 1
call ylink   %1\%~n1.obj  || exit /b 1
call ymovit  %1\%~n1      || exit /b 1

::
:: build file lists for simulation run
::
call sim\build_file_lists.bat

::
:: cd to the simulation directory defined by %YARD_SIM%
::
cd sim\%YARD_SIM%

::
:: compile and run model
::
call sim_comp || exit /b 1
call sim_run  || exit /b 1

::
:: check against expected results
::
cd ..\..

copy sim\%YARD_SIM%\sim.out %1\%YARD_SIM%_sim.out
if errorlevel 1 exit /b 1

call yver %1\%~n1.vfy %1\%YARD_SIM%_sim.out %1\%~n1.vrf
copy %1\%~n1.vrf %1\%YARD_SIM%_sim.results
type %1\%~n1.vrf





