::
:: create an XSIM project file from the environment variables defining the sources
::
echo off

:: create file on disk
echo # > xsim_rtl.prj

:: append list of core files
for %%F in (%YC_FILES%) do echo vhdl work "%%F" >> xsim_rtl.prj

echo # >> xsim_rtl.prj

:: append list of testbench files
for %%F in (%YV_FILES%) do echo vhdl work "%%F" >> xsim_rtl.prj

echo on


::
:: run XSIM elaboration stage
::
call xelab  testbench  -prj xsim_rtl.prj   


