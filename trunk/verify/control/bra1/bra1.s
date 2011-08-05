;
; <bra1.s>
;

;
; (C) COPYRIGHT 2011  B. Davis
;
; Code released under the terms of the "new BSD" license
; see license/new_bsd.txt
;

;
; YARD-1 test program
;
; check out BRA
;
;  add tests for negative offsets
;  add tests for long branch
;

   org $0

; nop first, reset vector isn't working quite right
    nop

; r0 = test flags
    mov     r0, #0

; try a plain bra
    bra     targ1
    nop

; shouldn't be here
    nop
    .verify fail

targ1:
    nop
    .verify r0,#0

; check that the delay slot is nulled
    bra     targ2
    add     r0,#1


targ2:
    nop
    .verify r0,#0

; check that the delay slot is enabled
    bra.d   targ3
    add     r0,#2


targ3:
    nop
    .verify r0,#2

; try a bra with a flow change in the delay slot
    bra     targ4
    bra     error


targ4:
    nop
    .verify r0,#2

    nop

done:
    bra     done
    nop



error:
    nop
    .verify fail

    bra     done




  end




