::
:: <yen.bat>
::
:: sets up project environment variables and path
::
:: run this script from the top level project directory
::

set YARD_HOME=%CD%

set YARD_TOOLS=%YARD_HOME%\tools

set path=%path%;%YARD_TOOLS%\winxp;

::
:: TODO: need to pick a PERL here ( check for perl install, bail to xilperl )
::
set YARD_PERL=perl

::
:: select a VHDL simulator 
::
::   GHDL       GHDL
::   MTI        Model Technology / Modelsim
::   SYMPHONY   Symphony EDA     / VHDL Simili
::   ALDEC      Aldec            / Active-HDL
::
set YARD_SIM=GHDL

::
:: select the default simulation target here
::
set YARD_SIM_TARGET=%YARD_HOME%\hdl\systems\sim_rtl
