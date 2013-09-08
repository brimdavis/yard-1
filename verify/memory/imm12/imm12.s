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
; test imm12 
;

    org $0

    nop   ; temporarily needed to keep verify count valid ( fix verify to ignore nulled instructions )

;
; check near 0, +max, -min, 
; note sign extension
;

    imm12   #$000
    .verify  r14,#$0000_0000

    imm12   #$001
    .verify  r14,#$0000_0001

    imm12   #$7ff
    .verify  r14,#$0000_07ff

    imm12   #$7fe
    .verify  r14,#$0000_07fe

    imm12   #$800
    .verify  r14,#$FFFF_F800

    imm12   #$801
    .verify  r14,#$FFFF_F801

    imm12   #$FFF
    .verify  r14,#$FFFF_FFFF

    imm12   #$FFE
    .verify  r14,#$FFFF_FFFE

;
; check each bit set
;

    imm12   #$001
    .verify  r14,#$0000_0001

    imm12   #$002
    .verify  r14,#$0000_0002

    imm12   #$004
    .verify  r14,#$0000_0004

    imm12   #$008
    .verify  r14,#$0000_0008

    imm12   #$010
    .verify  r14,#$0000_0010

    imm12   #$020
    .verify  r14,#$0000_0020

    imm12   #$040
    .verify  r14,#$0000_0040

    imm12   #$080
    .verify  r14,#$0000_0080

    imm12   #$100
    .verify  r14,#$0000_0100

    imm12   #$200
    .verify  r14,#$0000_0200

    imm12   #$400
    .verify  r14,#$0000_0400

    imm12   #$800
    .verify  r14,#$FFFF_F800

;
; check each bit clear
;

    imm12   #$FFE
    .verify  r14,#$FFFF_FFFE

    imm12   #$FFD
    .verify  r14,#$FFFF_FFFD

    imm12   #$FFB
    .verify  r14,#$FFFF_FFFB

    imm12   #$FF7
    .verify  r14,#$FFFF_FFF7


    imm12   #$FEF
    .verify  r14,#$FFFF_FFEF

    imm12   #$FDF
    .verify  r14,#$FFFF_FFDF

    imm12   #$FBF
    .verify  r14,#$FFFF_FFBF

    imm12   #$F7F
    .verify  r14,#$FFFF_FF7F


    imm12   #$EFF
    .verify  r14,#$FFFF_FEFF

    imm12   #$DFF
    .verify  r14,#$FFFF_FDFF

    imm12   #$BFF
    .verify  r14,#$FFFF_FBFF

    imm12   #$7FF
    .verify  r14,#$0000_07FF


;
; make sure skipped imm12 doesn't write to register
;
    mov     r14,#0

    skip
    imm12   #$001

    nop
    .verify  r14,#$0000_0000

;
; make sure load in nulled branch slot doesn't write to register
;
    mov     r14,#0

    bra     t1
    imm12   #$002

t1:
    nop
    .verify r14,#$0000_0000


;
; make sure load in enabled branch slot does write to register
;
    mov     r14,#0

    bra.d   t2
    imm12   #$004

t2:
    nop
    .verify r14,#$0000_0004


done:
    bra  done


    end




