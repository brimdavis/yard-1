;
; <flip.s>
;

;
; (C) COPYRIGHT 2001-2011  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; test the fantastic "flip" instruction
;

    org $0

;
; cnt1
;


    mov     r0, #$0000_0001
    flip    r0, #0               ; swap nothing
    .verify r0, #$0000_0001

    mov     r1, #$0000_0001
    flip    r1, #1               ; swap even/odd bits
    .verify r1, #$0000_0002

    mov     r2, #$0000_0003
    flip    r2, #2               ; swap even/odd bit pairs
    .verify r2, #$0000_000c

    mov     r3, #$0000_000F
    flip    r3, #4               ; swap even/odd nybbles
    .verify r3, #$0000_00F0

    mov     r4, #$0000_00FF
    flip    r4, #8               ; swap even/odd bytes
    .verify r4, #$0000_FF00

    mov     r5, #$0000_FFFF
    flip    r5, #16              ; swap even/odd wydes
    .verify r5, #$FFFF_0000

    mov     r6, #$0000_0001
    flip    r6, #31              ; swap everything ( reverse bit order )
    .verify r6, #$8000_0000

    mov     r7, #$FFFF_FFFE
    flip    r7, #31              ; swap everything ( reverse bit order )
    .verify r7, #$7FFF_FFFF



    ldi     Lx1111_1111
    flip    r14, #1              ; swap even/odd bits
    .verify r14, #$2222_2222

    ldi     Lx2222_2222
    flip    r14, #1              ; swap even/odd bits
    .verify r14, #$1111_1111

    ldi     Lx4444_4444
    flip    r14, #1              ; swap even/odd bits
    .verify r14, #$8888_8888

    ldi     Lx8888_8888
    flip    r14, #1              ; swap even/odd bits
    .verify r14, #$4444_4444



    ldi     Lx1428_3cf0
    flip    r14, #2              ; swap even/odd bit pairs
    .verify r14, #$4182_c3f0

    ldi     Lx1234_5678
    flip    r14, #4              ; swap even/odd nybbles
    .verify r14, #$2143_6587

    ldi     Lx1234_5678
    flip    r14, #8              ; swap even/odd bytes
    .verify r14, #$3412_7856

    ldi     Lx1234_5678
    flip    r14, #16             ; swap even/odd wydes
    .verify r14, #$5678_1234

    ldi     Lx1234_5678
    flip    r14, #31             ; swap everything ( reverse bit order )
    .verify r14, #$1E6A_2C48


done:
   bra  done


;
; ldi constants
;
    align  4

Lx1111_1111   dc.q   $1111_1111
Lx2222_2222   dc.q   $2222_2222
Lx4444_4444   dc.q   $4444_4444
Lx8888_8888   dc.q   $8888_8888
Lx1428_3cf0   dc.q   $1428_3cf0
Lx1234_5678   dc.q   $1234_5678


   end




