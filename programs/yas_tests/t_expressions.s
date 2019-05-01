;
; test operators of the new expression parser
;


   org $0

;
; test all operators individually
;

; +
TEST1 equ 1024+4 
   .expect TEST1,1028

; -
TEST2 equ 1024-4 
   .expect TEST2,1020

; |  OR
TEST3 equ 0xEF|0x10
   .expect TEST3,0xFF

; * 
TEST4 equ 0x5555_5555*2
   .expect TEST4,0xAAAA_AAAA

; /  
TEST5 equ 9999/3
   .expect TEST5,3333

; &  AND
TEST6 equ 0xFFFF_FFFF&0xAAAA_5555
   .expect TEST6,0xAAAA_5555

; ^  XOR
TEST7 equ 0xFFFF_5555^0xAAAA_FFFF
   .expect TEST7,0x5555_AAAA


;
; test chained operators
;
TEST8 equ 1+2-3+4-5+6-7
   .expect TEST8,-2

TEST9 equ 0x01|0x02|0x04|$C0
   .expect TEST9,$C7

;
; test precedence with more complicated expressions
;

TEST16 equ 64+4-3-1 
   .expect TEST16,64

TEST17 equ 64*10+8
   .expect TEST17,648

TEST18 equ TEST17/TEST16+1
   .expect TEST18,11

TEST19 equ -64*10+8
   .expect TEST19,-632



   end




