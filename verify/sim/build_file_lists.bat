::
:: build lists of files for simulator calls
::
:: needs work to automatically compile using local file list for each target
:: manually select files for now
::

::
:: GHDL bug workaround: change prefixes to relative paths when YARD_SIM_TARGET=GHDL 
::

IF "%YARD_SIM%"=="GHDL" (
set YC=..\..\..\hdl\cores\y1a\
set YV=..\..\..\hdl\systems\sim_rtl\
) ELSE (
set YC=%YARD_HOME%\HDL\cores\y1a\
set YV=%YARD_SIM_TARGET%\
)


::
:: YC_FILES : core file list
:: YV_FILES : verification model file list ( currently hardcoded for sim_rtl directory )
::
set YC_FILES=%YC%y1a_config.vhd %YC%y1_constants.vhd %YC%y1a_comps.vhd %YC%y1a_probe_pkg.vhd %YC%pw2_rom.vhd %YC%addsub.vhd %YC%logicals.vhd %YC%shift_one.vhd %YC%barrel.vhd %YC%flip.vhd %YC%ffb.vhd %YC%reg_extend.vhd %YC%bitcnt.vhd %YC%rstack.vhd %YC%rf.vhd %YC%cgen.vhd %YC%ea_calc.vhd %YC%pcr_calc.vhd %YC%dbus_ctl.vhd %YC%st_mux.vhd %YC%ld_mux.vhd %YC%skip_dcd.vhd %YC%state_ctl.vhd %YC%decoders.vhd %YC%y1a_probe.vhd %YC%y1a_core.vhd 
set YV_FILES=%YV%rom_dat.vhd %YV%..\evb_common\block_ram\rtl\rtl_mem.vhd %YV%evb.vhd %YV%evb_tb.vhd

if errorlevel 1 exit /b 1




