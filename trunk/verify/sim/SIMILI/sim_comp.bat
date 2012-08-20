::
:: compile model
::   simulator file lists are now built from a common batch file
::
vhdlp %YC_FILES% %YV_FILES%

if errorlevel 1 exit /b 1
