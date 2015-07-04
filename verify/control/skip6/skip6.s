;
; <skip6.s>
;

;
; (C) COPYRIGHT 2001-2011  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test miscellaneous skips
;   input flags
;

        org $0

;
; enable interrupts
;
         ei

;
; skip on flag 
;
;  input flags hardwired to $55AA in testbench
;


; flag 0 
        mov     r0,#1
        skip.fs #0
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #0
        mov     r0,#0
        nop
        .verify r0,#1

; flag 1
        mov     r0,#1
        skip.fs #1
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #1
        mov     r0,#0
        nop
        .verify r0,#0

; flag 2
        mov     r0,#1
        skip.fs #2
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #2
        mov     r0,#0
        nop
        .verify r0,#1

; flag 3
        mov     r0,#1
        skip.fs #3
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #3
        mov     r0,#0
        nop
        .verify r0,#0

; flag 4
        mov     r0,#1
        skip.fs #4
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #4
        mov     r0,#0
        nop
        .verify r0,#1

; flag 5
        mov     r0,#1
        skip.fs #5
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #5
        mov     r0,#0
        nop
        .verify r0,#0

; flag 6
        mov     r0,#1
        skip.fs #6
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #6
        mov     r0,#0
        nop
        .verify r0,#1

; flag 7
        mov     r0,#1
        skip.fs #7
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #7
        mov     r0,#0
        nop
        .verify r0,#0

; flag 8 
        mov     r0,#1
        skip.fs #8 
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #8 
        mov     r0,#0
        nop
        .verify r0,#0

; flag 9 
        mov     r0,#1
        skip.fs #9 
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #9 
        mov     r0,#0
        nop
        .verify r0,#1

; flag 10
        mov     r0,#1
        skip.fs #10
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #10
        mov     r0,#0
        nop
        .verify r0,#0

; flag 11
        mov     r0,#1
        skip.fs #11
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #11
        mov     r0,#0
        nop
        .verify r0,#1

; flag 12
        mov     r0,#1
        skip.fs #12
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #12
        mov     r0,#0
        nop
        .verify r0,#0

; flag 13
        mov     r0,#1
        skip.fs #13
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #13
        mov     r0,#0
        nop
        .verify r0,#1

; flag 14
        mov     r0,#1
        skip.fs #14
        mov     r0,#0
        nop
        .verify r0,#1

        mov     r0,#1
        skip.fc #14
        mov     r0,#0
        nop
        .verify r0,#0

; flag 15
        mov     r0,#1
        skip.fs #15
        mov     r0,#0
        nop
        .verify r0,#0

        mov     r0,#1
        skip.fc #15
        mov     r0,#0
        nop
        .verify r0,#1

;
;
;
done:
        bra  done


;
; ISR entry point
;
        org   $200

irq:
        nop
        rti


        end




