;
; movc1.asm
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
; try out the mov/lea's from special registers
;   pc,sp,fp,imm
;

    org $0

; nop first, reset vector isn't working quite right
    nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; lea tests using R15 as address operand should return current PC
;
    lea     r0,(pc)
    .verify r0,#$0000_0002

    lea     r0,(pc)
    .verify r0,#$0000_0004

    bra     L0FE

; org for non-contiguous code
    org     $fe

L0FE:
    lea     r0,(pc)
    .verify r0,#$0000_00fe
        
    lea     r0,(pc)
    .verify r0,#$0000_0100

; movc in shadow of a skip, shouldn't change r0
    skip
    lea     r0,(pc)
    .verify r0,#$0000_0100

    bra.d   L13E
    lea     r0,(pc)
    .verify r0,#$0000_0108

; org for non-contiguous code
    org     $13e

L13e:
    lea     r0,(pc)
    .verify r0,#$0000_013e
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; mov tests using pc register as data operand should read/write top of HW return stack

; RETURN STACK READ/WRITE NOT IMPLEMENTED YET!!!!

    nop
    .verify fail      ; fail as placeholder until tests are added

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; imm as source/dest
;

    imm12   #$F34
    mov     r0,imm
    .verify r0,#$ffff_ff34

; modify imm with mov to imm register
    not     r0
    mov     imm,r0
    .verify r14,#$0000_00cb

; check that it worked
    mov     r1,imm
    .verify r1,#$0000_00cb

done:
    bra     done

  end




