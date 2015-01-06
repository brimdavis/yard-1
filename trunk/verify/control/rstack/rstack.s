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
        mov     sp, #$200

; stack up several subroutine calls
        bsr   sub1
ret1:   nop

;
;
sub1:
        add    r0,#1
        nop

        bsr.d  sub2
        nop

ret2:   nop             ; delayed branch would return here

;
;
sub2:
        add    r0,#2
        nop

        bsr     sub3

ret3:   nop

;
;
sub3:
        add    r0,#4
        nop



; pop the return stack to memory and check for expected values

        st     r15, (sp)    ; r15 aka rs
        st     rs, 4(sp)
        st     rs, 8(sp)


        ld     r0,(sp)
        nop
        .verify r0,#ret3


        ld     r0,4(sp)
        nop
        .verify r0,#ret2


        ld     r0,8(sp)
        nop
        .verify r0,#ret1


done:
        bra     done
        nop

