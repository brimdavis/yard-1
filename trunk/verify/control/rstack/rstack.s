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

; initialize registers
        mov     r0, #$0

        mov     r10,#$80
        mov     fp,#$100

; stack up several subroutine calls
        bsr   sub1
ret1:   nop


;
;
        org    $12E

sub1:
        add    r0,#1
        nop

        bsr.d  sub2
        nop

ret2:   nop             ; delayed branch would return here


;
;
        org    $1F6

sub2:
        add    r0,#2
        nop

        bsr     sub3

ret3:   nop


;
;
        org    $24C

sub3:
        add    r0,#4
        nop

        bsr     sub4

ret4:   nop

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

        ld     r0,(r10)
        nop
        .verify r0,#ret4


; stack offset mode
        st     rs,  4(fp)
        st     rs,  8(fp)
        st     rs, 12(fp)



        ld     r0,4(fp)
        nop
        .verify r0,#ret3


        ld     r0,8(fp)
        nop
        .verify r0,#ret2


        ld     r0,12(fp)
        nop
        .verify r0,#ret1

done:
        bra     done
        nop

