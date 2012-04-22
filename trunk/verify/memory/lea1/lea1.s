;
; <imm12.s>
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
; test LEA ( Load Effective Address )
;

    org $0

;
; r2 = base address
;
    mov     r2, #$8000_0000

;
; no offset
;
    lea     r0, (r2)
    .verify r0,#$8000_0000

;
; 12 bit offset
;

;
; test near 0, +max, -min
;
    imm12   #0
    lea     r0, .imm(r2)
    .verify r0,#$8000_0000


    imm12   #1
    lea     r0, .imm(r2)
    .verify r0,#$8000_0001


    imm12   #$7fe
    lea     r0, .imm(r2)
    .verify r0,#$8000_07fe


    imm12   #$7ff
    lea     r0, .imm(r2)
    .verify r0,#$8000_07ff


    imm12   #-1
    lea     r0, .imm(r2)
    .verify r0,#$7fff_ffff


    imm12   #-2047
    lea     r0, .imm(r2)
    .verify r0,#$7fff_f801


    imm12   #-2048
    lea     r0, .imm(r2)
    .verify r0,#$7fff_f800


    imm12   #$800
    lea     r0, .imm(r2)
    .verify r0,#$7fff_f800


;
; stack offset mode
;
    mov     R12,#$0000_1000
    mov     R13,#$0000_2000

; fp mode

    lea     r0, 0(r12)
    .verify r0,#$0000_1000

    lea     r0, 4(r12)
    .verify r0,#$0000_1004

    lea     r0, 8(fp)
    .verify r0,#$0000_1008

    lea     r0, 12(r12)
    .verify r0,#$0000_100c

    lea     r0, 16(fp)
    .verify r0,#$0000_1010

    lea     r0, 20(fp)
    .verify r0,#$0000_1014

    lea     r0, 24(fp)
    .verify r0,#$0000_1018

    lea     r0, 28(fp)
    .verify r0,#$0000_101c

    lea     r0, 32(fp)
    .verify r0,#$0000_1020

    lea     r0, 36(fp)
    .verify r0,#$0000_1024

    lea     r0, 40(fp)
    .verify r0,#$0000_1028

    lea     r0, 44(fp)
    .verify r0,#$0000_102c

    lea     r0, 48(fp)
    .verify r0,#$0000_1030

    lea     r0, 52(fp)
    .verify r0,#$0000_1034

    lea     r0, 56(fp)
    .verify r0,#$0000_1038

    lea     r0, 60(fp)
    .verify r0,#$0000_103c

; sp
    lea     r0, 0(r13)
    .verify r0,#$0000_2000

    lea     r0, 8(sp)
    .verify r0,#$0000_2008

;
; try other destination registers
;
    mov     r0,#$f000_0000

    lea     r1, (r0)
    .verify r1,#$f000_0000

    lea     r2, (r0)
    .verify r2,#$f000_0000

    lea     r3, (r0)
    .verify r3,#$f000_0000

    lea     r4, (r0)
    .verify r4,#$f000_0000

    lea     r5, (r0)
    .verify r5,#$f000_0000

    lea     r6, (r0)
    .verify r6,#$f000_0000

    lea     r7, (r0)
    .verify r7,#$f000_0000

    lea     r8, (r0)
    .verify r8,#$f000_0000

    lea     r9, (r0)
    .verify r9,#$f000_0000

    lea     r10, (r0)
    .verify r10,#$f000_0000

    lea     r11, (r0)
    .verify r11,#$f000_0000

    lea     r12, (r0)
    .verify r12,#$f000_0000

    lea     r13, (r0)
    .verify r13,#$f000_0000

    lea     r14, (r0)
    .verify r14,#$f000_0000



done:
    bra  done



    end




