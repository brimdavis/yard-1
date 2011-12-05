;
; <ldi.s>
;

;
; (C) COPYRIGHT 2001-2011  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test LDI ( LoaD Immediate )
;

    org $0

;   nop first, reset vector isn't working quite right
    nop

    ldi     L_1234_5678
    mov     r0,imm 
    .verify r0, #$1234_5678

    ldi     L_9abc_def0
    mov     r1,imm 
    .verify r1, #$9abc_def0

    ldi     L_5555_aaaa
    mov     r2,imm 
    .verify r2, #$5555_aaaa

    ldi     L_dead_beef
    mov     r3,imm 
    .verify r3, #$dead_beef

    ldi     L_4444_4444
    mov     r4,imm 
    .verify r4, #$4444_4444

    ldi     L_5555_5555
    mov     r5,imm 
    .verify r5, #$5555_5555

    ldi     L_6666_6666
    mov     r6,imm 
    .verify r6, #$6666_6666

    ldi     L_7777_7777
    mov     r7,imm 
    .verify r7, #$7777_7777

    ldi     L_8888_8888
    mov     r8,imm 
    .verify r8, #$8888_8888

    ldi     L_9999_9999
    mov     r9,imm 
    .verify r9, #$9999_9999

    ldi     L_aaaa_aaaa
    mov     r10,imm 
    .verify r10, #$aaaa_aaaa

    ldi     L_bbbb_bbbb
    mov     r11,imm 
    .verify r11, #$bbbb_bbbb

    ldi     L_cccc_cccc
    mov     r12,imm 
    .verify r12, #$cccc_cccc

    ldi     L_dddd_dddd
    mov     r13,imm 
    .verify r13, #$dddd_dddd


; note imm/r14 are the same register
    ldi     L_eeee_eeee
    mov     r14,imm 
    .verify r14, #$eeee_eeee
 

;
; BMD r15 now a dedicated register
;
;   ldi     L_ffff_ffff
;     mov     r15,imm 
;   .verify r15, #$ffff_ffff


done:
    bra  done

;
; immediates
;
    align  4

L_1234_5678:    dc.q    $1234_5678
L_9abc_def0:    dc.q    $9abc_def0
L_5555_aaaa:    dc.q    $5555_aaaa
L_dead_beef:    dc.q    $dead_beef
L_4444_4444:    dc.q    $4444_4444
L_5555_5555:    dc.q    $5555_5555
L_6666_6666:    dc.q    $6666_6666
L_7777_7777:    dc.q    $7777_7777
L_8888_8888:    dc.q    $8888_8888
L_9999_9999:    dc.q    $9999_9999
L_aaaa_aaaa:    dc.q    $aaaa_aaaa
L_bbbb_bbbb:    dc.q    $bbbb_bbbb
L_cccc_cccc:    dc.q    $cccc_cccc
L_dddd_dddd:    dc.q    $dddd_dddd
L_eeee_eeee:    dc.q    $eeee_eeee
L_ffff_ffff:    dc.q    $ffff_ffff


    end
