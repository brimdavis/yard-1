;
; <jmp1.s>
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
; check out JMP
;

   org $0

;
; enable interrupts
;
    ei


; r1 = base address
    mov     r2,#0

; r0 = test flags
    mov     r0, #0

; try a jmp
    imm12   #targ1
    lea     r1, .imm(r2)
    jmp     (r1)
    nop

; shouldn't be here, force a verify error
    nop
    .verify fail

targ1:
    nop
    .verify r0,#0

; check that the delay slot is nulled
    imm12   #targ2
    lea     r1, .imm(r2)
    jmp     (r1)
    add     r0,#1


targ2:
    nop
    .verify r0,#0

; try a jump with a flow change in the delay slot
    imm12   #targ3
    lea     r1, .imm(r2)
    jmp     (r1)
    bra     error


targ3:
    nop
    .verify r0,#0

    nop

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


  end




