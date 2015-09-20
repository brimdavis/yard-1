
 Unlike earlier Lattice boards I've used, which had FTDI Port B configured 
and wired as a UART out-of-the-box, the XO3L Starter Kit I received required 
both hardware and FTDI setting changes to configure Port B for UART operation.

 ( I didn't see any mention of this in the user manual. )


1) install 0 ohm resistors at R14 and R15 to connect the UART RX/TX lines

2) Download the FTDI FT_Prog utility:
     http://www.ftdichip.com/Support/Utilities/FT_Prog_v3.0.60.276%20Installer.zip
     http://www.ftdichip.com/Support/Documents/AppNotes/AN_124_User_Guide_For_FT_PROG.pdf


*** CAUTION: if done improperly, the following could brick your FTDI chip. ***


3) Run FT_Prog, do DEVICES=>SCAN AND PARSE

4) If there are multiple FTDI chips, select the Device corresponding 
   to the XO3L board in the Device Tree window, and confirm by clicking 
   "FT EEPROM=>USB String Descriptors" - this string should read 
   'Lattice XO3L Starter Kit'


5) Select "Hardware Specific=>Port B=>Hardware" and set to 'RS232 UART'

6) Select "Hardware Specific=>Port B=>Driver" and set to 'Virtual COM Port'

7) Right click "Port B" and select 'Program Device' from the popup

8) exit FT_prog and unplug/replug the XO3L board to renumerate