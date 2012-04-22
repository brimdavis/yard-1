::
:: run all tests
::
call v control\reset_vector
call v control\bra1
call v control\bsr1
call v control\jmp1
call v control\jsr1
::call v control\lbra1
call v control\skip1
call v control\skip2
call v control\skip3
call v control\skip4
call v control\skip5
call v control\skip6
call v control\spam1
call v control\when

call v alu\addsub1
call v alu\bitsy1
call v alu\bitsy2
call v alu\flip
call v alu\logic1
call v alu\mov1
call v alu\movc1
call v alu\neg1
call v alu\reg1
call v alu\shift1

call v memory\imm12
call v memory\ldi
call v memory\lea1
call v memory\mem1
call v memory\mem2
