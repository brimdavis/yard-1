::
:: verify script, needs path to subdirectory containing test
::
call yas    %1\%~n1.s     || exit /b 1

call ylink  %1\%~n1.obj   || exit /b 1

call ymovit %1\%~n1       || exit /b 1

cd sim

call ghdl_comp || exit /b 1
::call sym_comp || exit /b 1
::call isim_comp || exit /b 1

call ghdl_run || exit /b 1
::call sym_run || exit /b 1
::call isim_run || exit /b 1

cd ..
copy sim\ghdl_sim.out %1
::copy sim\sym_sim.out %1
::copy sim\isim_sim.out %1
if errorlevel 1 exit /b 1

call yver %1\%~n1.vfy %1\ghdl_sim.out %1\%~n1.vrf
::call yver %1\%~n1.vfy %1\sym_sim.out %1\%~n1.vrf
::call yver %1\%~n1.vfy %1\isim_sim.out %1\%~n1.vrf
type %1\%~n1.vrf





