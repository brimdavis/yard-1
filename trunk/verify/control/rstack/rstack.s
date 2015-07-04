;
; <rstack.s>
;

;
; (C) COPYRIGHT 2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; check out software pop of HW return stack 
;   - memory store of R15 aka RS should pop stack
;

       org $0

;
; enable interrupts
;
        ei


; initialize registers
        mov     r0, #$0

        mov     r10,#$80
        mov     fp,#$100

; stack up several subroutine calls
        bsr   sub1
ret1:   nop

        nop
        .verify PASS

        lbra   done
;
;
        org    $12E

sub1:
        add    r0,#1
        nop

        bsr.d  sub2
        nop

ret2:   nop             ; delayed branch would return here

        nop
        .verify PASS

        rts


;
;
        org    $1F2

sub2:
        add    r0,#2
        nop

        bsr     sub3

ret3:   nop

        nop
        .verify PASS

        rts



;
; ISR entry point
;
        org   $200

irq:
        nop
        rti


;
;
        org    $24C

sub3:
        add    r0,#4
        nop

        bsr     sub4

ret4:   nop

        nop
        .verify PASS

        rts

;
;
        org    $3B4

sub4:
        add    r0,#4
        nop


;
; pop the return stack to memory and check for expected values
;

; register indirect mode
        st     r15, (r10)    ; r15 aka rs


; stack offset mode
        st     rs,  4(fp)
        st     rs,  8(fp)
        st     rs, 12(fp)

; check values

        ld     r0,(r10)
        nop
        .verify r0,#ret4


        ld     r0,4(fp)
        nop
        .verify r0,#ret3


        ld     r0,8(fp)
        nop
        .verify r0,#ret2


        ld     r0,12(fp)
        nop
        .verify r0,#ret1

;
; push return addresses back onto HW stack using memory ld
;
        ld     rs, 12(fp)  ; ret1
        ld     rs,  8(fp)  ; ret2
        ld     rs,  4(fp)  ; ret3
        ld     rs,  (r10)  ; ret4

        rts


done:
        bra     done
        nop

