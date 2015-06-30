;
; <ext1.s>
;

;
; (C) COPYRIGHT 2001-2012,2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test EXTend instructions
;

    org $0

;
; enable interrupts
;
    ei

;
; signed/unsigned byte
;
    mov     r0,#$7f

    ext.sb  r1,r0
    .verify r1,#$0000_007f

    ext.ub  r1,r0
    .verify r1,#$0000_007f


    mov     r0,#$80

    ext.sb  r1,r0
    .verify r1,#$ffff_ff80

    ext.ub  r1,r0
    .verify r1,#$0000_0080


;
; signed/unsigned wyde
;
    mov     r0,#$7fff

    ext.sw  r1,r0
    .verify r1,#$0000_7fff

    ext.uw  r1,r0
    .verify r1,#$0000_7fff


    mov     r0,#$8000

    ext.sw  r1,r0
    .verify r1,#$ffff_8000

    ext.uw  r1,r0
    .verify r1,#$0000_8000

done:
    bra     done


;
; ISR entry point
;
    org   $200

irq:
    nop
    rti


    end




