::
:: create an isim project file from the environment variables defining the sources
::
echo off

:: create file on disk
echo # > isim_rtl.prj

:: append list of core files
for %%F in (%YC_FILES%) do echo vhdl work "%%F" >> isim_rtl.prj

echo # >> xsim_rtl.prj

:: append list of testbench files
for %%F in (%YV_FILES%) do echo vhdl work "%%F" >> isim_rtl.prj

echo on


::
:: this needs work to automatically compile using local file list for each target
:: just uses ISIM prj file for now
::
:: ISIM splatters temp files everywhere!!!
::
fuse  -prj isim_rtl.prj   -work work=work.isim    -o tb.exe    -top testbench 


