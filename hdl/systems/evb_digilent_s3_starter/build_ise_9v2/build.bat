::
::
::
cd temp

xst -intstyle xflow   -ifn ..\evb.xst -ofn evb.syr 
if errorlevel 1 exit /b 1

ngdbuild -intstyle xflow -dd _ngo -nt timestamp -insert_keep_hierarchy -uc ..\..\evb.ucf -p xc3s200-ft256-4 evb.ngc evb.ngd
if errorlevel 1 exit /b 1

map  -intstyle xflow     -p xc3s200-ft256-4 -timing -logic_opt on -ol high -xe n -t 1 -cm area -detail -l -pr b -k 4 -power off -o evb_map.ncd evb.ngd evb.pcf
if errorlevel 1 exit /b 1

par  -intstyle xflow     -w -ol high -xe n -t 1 evb_map.ncd evb.ncd evb.pcf
if errorlevel 1 exit /b 1

trce -intstyle xflow     -v 3 -s 4 -xml evb evb.ncd -o evb.twr evb.pcf -ucf ..\..\evb.ucf
if errorlevel 1 exit /b 1

bitgen   -f ..\evb.ut evb.ncd

cd ..
