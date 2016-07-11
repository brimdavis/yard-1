;
; <shift2.s>
;

;
; (C) COPYRIGHT 2016  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test the full barrel shifter
;
;

    org $0

    .mopt  barrel_shift, true

;
; enable interrupts
;
    ei

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; first test groups check each 2^N stage of barrel shifter, along with shifts of 0 and 31
;


;
; ROL
;
    imm     #$8421_F05A

    mov     r1,imm
    rol     r1,#0
    .verify r1,#$8421_F05A

    mov     r1,imm
    rol     r1,#1
    .verify r1,#$0843_E0B5

    mov     r1,imm
    rol     r1,#2
    .verify r1,#$1087_C16A

    mov     r1,imm
    rol     r1,#4
    .verify r1,#$421F_05A8

    mov     r1,imm
    rol     r1,#8
    .verify r1,#$21F0_5A84

    mov     r1,imm
    rol     r1,#31
    .verify r1,#$4210_F82D


;
; LSL
;
    imm     #$8421_F05A

    mov     r1,imm
    lsl     r1,#0
    .verify r1,#$8421_F05A

    mov     r1,imm
    lsl     r1,#1
    .verify r1,#$0843_E0B4

    mov     r1,imm
    lsl     r1,#2
    .verify r1,#$1087_C168

    mov     r1,imm
    lsl     r1,#4
    .verify r1,#$421F_05A0

    mov     r1,imm
    lsl     r1,#8
    .verify r1,#$21F0_5A00

    mov     r1,imm
    lsl     r1,#31
    .verify r1,#$0000_0000


;
; ROR
;
    imm     #$8421_F05A

    mov     r1,imm
    ror     r1,#0
    .verify r1,#$8421_F05A

    mov     r1,imm
    ror     r1,#1
    .verify r1,#$4210_F82D

    mov     r1,imm
    ror     r1,#2
    .verify r1,#$A108_7C16

    mov     r1,imm
    ror     r1,#4
    .verify r1,#$A842_1F05

    mov     r1,imm
    ror     r1,#8
    .verify r1,#$5A84_21F0

    mov     r1,imm
    ror     r1,#31
    .verify r1,#$0843_E0B5


;
; LSR
;
    imm     #$8421_F05A

    mov     r1,imm
    lsr     r1,#0
    .verify r1,#$8421_F05A

    mov     r1,imm
    lsr     r1,#1
    .verify r1,#$4210_F82D

    mov     r1,imm
    lsr     r1,#2
    .verify r1,#$2108_7C16

    mov     r1,imm
    lsr     r1,#4
    .verify r1,#$0842_1F05

    mov     r1,imm
    lsr     r1,#8
    .verify r1,#$0084_21F0

    mov     r1,imm
    lsr     r1,#31
    .verify r1,#$0000_0001


;
; ASR (msb set)
;
    imm     #$8421_F05A

    mov     r1,imm
    asr     r1,#0
    .verify r1,#$8421_F05A

    mov     r1,imm
    asr     r1,#1
    .verify r1,#$C210_F82D

    mov     r1,imm
    asr     r1,#2
    .verify r1,#$E108_7C16

    mov     r1,imm
    asr     r1,#4
    .verify r1,#$F842_1F05

    mov     r1,imm
    asr     r1,#8
    .verify r1,#$FF84_21F0

    mov     r1,imm
    asr     r1,#31
    .verify r1,#$FFFF_FFFF


;
; ASR (msb clear)
;
    imm     #$7421_F05A

    mov     r1,imm
    asr     r1,#0
    .verify r1,#$7421_F05A

    mov     r1,imm
    asr     r1,#1
    .verify r1,#$3A10_F82D

    mov     r1,imm
    asr     r1,#2
    .verify r1,#$1D08_7C16

    mov     r1,imm
    asr     r1,#4
    .verify r1,#$0742_1F05

    mov     r1,imm
    asr     r1,#8
    .verify r1,#$0074_21F0

    mov     r1,imm
    asr     r1,#31
    .verify r1,#$0000_0000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; assorted tests
;

;
; rotate single zero
;
    mov     r2,#$7FFF_FFFF
    ror     r2,#0
    .verify r2,#$7FFF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#1
    .verify r2,#$BFFF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#2
    .verify r2,#$DFFF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#3
    .verify r2,#$EFFF_FFFF


    mov     r2,#$7FFF_FFFF
    ror     r2,#4
    .verify r2,#$F7FF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#5
    .verify r2,#$FBFF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#6
    .verify r2,#$FDFF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#7
    .verify r2,#$FEFF_FFFF


    mov     r2,#$7FFF_FFFF
    ror     r2,#8
    .verify r2,#$FF7F_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#9
    .verify r2,#$FFBF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#10
    .verify r2,#$FFDF_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#11
    .verify r2,#$FFEF_FFFF


    mov     r2,#$7FFF_FFFF
    ror     r2,#12
    .verify r2,#$FFF7_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#13
    .verify r2,#$FFFB_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#14
    .verify r2,#$FFFD_FFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#15
    .verify r2,#$FFFE_FFFF


    mov     r2,#$7FFF_FFFF
    ror     r2,#16
    .verify r2,#$FFFF_7FFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#17
    .verify r2,#$FFFF_BFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#18
    .verify r2,#$FFFF_DFFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#19
    .verify r2,#$FFFF_EFFF


    mov     r2,#$7FFF_FFFF
    ror     r2,#20
    .verify r2,#$FFFF_F7FF

    mov     r2,#$7FFF_FFFF
    ror     r2,#21
    .verify r2,#$FFFF_FBFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#22
    .verify r2,#$FFFF_FDFF

    mov     r2,#$7FFF_FFFF
    ror     r2,#23
    .verify r2,#$FFFF_FEFF


    mov     r2,#$7FFF_FFFF
    ror     r2,#24
    .verify r2,#$FFFF_FF7F

    mov     r2,#$7FFF_FFFF
    ror     r2,#25
    .verify r2,#$FFFF_FFBF

    mov     r2,#$7FFF_FFFF
    ror     r2,#26
    .verify r2,#$FFFF_FFDF

    mov     r2,#$7FFF_FFFF
    ror     r2,#27
    .verify r2,#$FFFF_FFEF


    mov     r2,#$7FFF_FFFF
    ror     r2,#28
    .verify r2,#$FFFF_FFF7

    mov     r2,#$7FFF_FFFF
    ror     r2,#29
    .verify r2,#$FFFF_FFFB

    mov     r2,#$7FFF_FFFF
    ror     r2,#30
    .verify r2,#$FFFF_FFFD

    mov     r2,#$7FFF_FFFF
    ror     r2,#31
    .verify r2,#$FFFF_FFFE



done:
   bra  done

   .imm_table

;
; ISR entry point
;
   org   $200

irq:
   nop
   rti


  end




