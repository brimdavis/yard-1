;
; <jmp1.s>
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
; check out JMP
;

   org $0

; nop first, reset vector isn't working quite right
    nop

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
    mov     r0,#1
    .verify r0,#0

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


  end




