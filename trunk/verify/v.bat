::
:: verify script, needs path to subdirectory containing test
::
call yas    %1\%~n1.s     || exit /b 1

call ylink  %1\%~n1.obj   || exit /b 1

call ymovit %1\%~n1       || exit /b 1

::
:: cd to the proper directory to run the simulator defined by %YARD_SIM%
::
cd sim\%YARD_SIM%

call sim_comp || exit /b 1

call sim_run  || exit /b 1

cd ..\..

copy sim\%YARD_SIM%\sim.out %1\%YARD_SIM%_sim.out
if errorlevel 1 exit /b 1

call yver %1\%~n1.vfy %1\%YARD_SIM%_sim.out %1\%~n1.vrf
copy %1\%~n1.vrf %1\%YARD_SIM%_sim.results
type %1\%~n1.vrf





