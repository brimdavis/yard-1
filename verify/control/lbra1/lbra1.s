;
; <lbra1.s>
;

;
; (C) COPYRIGHT 2001-2012, 2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; check out LBRA
;
;

    org $0

;
; enable interrupts
;
    ei


; r0 = test flags
    mov     r0, #0

; try a plain bra
    lbra    targ1
    nop

; shouldn't be here, force a verify error
    nop
    .verify fail,#0
;
;
;
targ1:
    nop
    .verify r0,#0

; check that the delay slot is nulled
    lbra     targ2
    add     r0,#1

; shouldn't be here, force a verify error
    nop
    .verify fail,#0

.done
    bra .done


;
; ISR entry point
;
   org   $200

irq:
   nop
   rti



   org $800

;
;
;
error:
    nop
    .verify fail,#0

.done
    bra .done


;
;
;
targ3:
    nop
    .verify r0,#2

; try a bra with a flow change in the nullified delay slot
    lbra     targ4
    bra      error

; shouldn't be here, force a verify error
    nop
    .verify fail,#0

.done
    bra .done

;
; note, targ2 is out of sequence because it branches backwards
;
targ2:
    nop
    .verify r0,#0

; check that the delay slot is enabled
    lbra.d   targ3
    add     r0,#2

; shouldn't be here, force a verify error
    nop
    .verify fail,#0

.done
    bra .done



   org $1000

;
;
;
targ4:
    nop
    .verify r0,#2

    nop

.done:
    bra     .done
    nop


  end




