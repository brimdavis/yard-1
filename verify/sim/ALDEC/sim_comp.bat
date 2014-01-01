::
:: compile model
::   simulator file lists are now built from a common batch file
::
vlib -lib yardsim
vcom -work yardsim -dbg -relax  %YC_FILES% %YV_FILES%

if errorlevel 1 exit /b 1
