::
:: this needs work to automatically compile using local file list for each target
:: just uses ISIM prj file for now
::
:: ISIM splatters temp files everywhere!!!
::
fuse  -prj isim_rtl.prj   -work work=work.isim    -o tb.exe    -top testbench 


