;
; <bra1.s>
;

;
; (C) COPYRIGHT 2001-2013, 2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; check out BRA
;

   org $0


;
; enable interrupts
;
    ei


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

; branch forward ~512 instructions
    bra     targ5

; extra nop prevents false hit count for targ6 ( need to make verify ignore nulled fetches )
    nop  

targ6:
    nop
    .verify pass

done:
    bra     done
    nop


error:
    nop
    .verify fail

    bra     done



;
; ISR entry point
;
   org   $200

irq:
   nop
   rti


;
;
;
   org   $218

targ5:
    nop
    .verify pass

; branch backwards ~512 instructions
    bra     targ6


   end

