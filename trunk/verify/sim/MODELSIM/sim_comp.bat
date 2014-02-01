::
:: *** UNTESTED MODELSIM SCRIPTING ***
::
:: compile model
::   simulator file lists are now built from a common batch file
::
vlib yardsim
vcom -work yardsim -explicit  %YC_FILES% %YV_FILES%

if errorlevel 1 exit /b 1


