::
:: search logfiles for failed runs
::

:: usr\local\wbin\grep -irl --include=*.vrf failed .

findstr /S /I /M failed *.vrf
