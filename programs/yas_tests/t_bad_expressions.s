;
; some bad expressions to test the expression parser
;


   org $0

;
; solitary operators
;
BAD_00 equ +

BAD_01 equ -

BAD_02 equ *

BAD_03 equ /
    
BAD_04 equ &

BAD_05 equ |

BAD_06 equ ^

;
; bad operand/operator alternation
;
BAD_07 equ -+-*/
    
BAD_08 equ *1***

BAD_09 equ 3*2+

BAD_10 equ 3*-2     ; unary - not supported with current parser except at beginning of expression

;
; spaces within expressions (and operand fields in general) are not currently allowed
;
BAD_11 equ 3 * 2 +

   end




