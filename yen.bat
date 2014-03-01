::
:: <yen.bat>
::
:: sets up project environment variables and path
::
:: run this script once in each new command shell before using the tools
::
:: note: avoid spaces in the installation path, some of the invoked project batch files might choke on spaces
::

::
:: working-directory-insensitive method of determining project home from the location of this batch file
::
::   %~dp0 means dRIVE pATH argument0
::
::   note that %~dp0 includes a trailing slash, which is then removed on the next line
::
set YARD_HOME=%~dp0
set YARD_HOME=%YARD_HOME:~0,-1%

::
:: add command line tools to PATH
::
set YARD_TOOLS=%YARD_HOME%\tools

set PATH=%PATH%;%YARD_TOOLS%\winxp;

::
:: TODO: need to pick a PERL here ( check for perl install, bail to xilperl )
::
set YARD_PERL=perl

::
:: select a VHDL simulator by name
::
::
::  YARD_SIM     Company/
::  Name         Organization      Product
:: ---------------------------------------------
::
:: Currently Supported:
::
::  GHDL         GHDL              GHDL
::  SIMILI       Symphony EDA      VHDL Simili
::
::
:: Planned:
::
::  MODELSIM     Model Technology  Modelsim
::  ALDEC        Aldec             Active-HDL or Riviera
::  ISIM         Xilinx            Isim
::
set YARD_SIM=GHDL

::
:: select the default simulation target here
::
set YARD_SIM_TARGET=%YARD_HOME%\hdl\systems\sim_rtl







