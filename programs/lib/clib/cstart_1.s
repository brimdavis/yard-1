;
; simple absolute cstart code for tiny embedded startup
;
 org $100

cstart_1:
 mov sp,#$1000
 lbsr main

;; rts

; jump to reset vector
 mov r0,#0
 jmp (r0)

