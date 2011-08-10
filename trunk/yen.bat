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
:: BMD need to pick a PERL here ( check for perl install, bail to xilperl )
::
set YARD_PERL=perl

::
:: select the default simulation target here
::
set YARD_SIM_TARGET=%YARD_HOME%\hdl\systems\sim_rtl
