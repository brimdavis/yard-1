;
; <mov1.s>
;

;
; (C) COPYRIGHT 2001-2012,2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; try out the short immediate encodings
;
;  note: the assembler encodes any redundant constants in only one fashion.
;
;        e.g., "1" can be encoded using the N-bit, 2^N, or 2^N-1 constant modes,
;        but the assembler always encodes a "1" in the same way: namely, using the
;        last entry into the associative array used for encoded constant lookups
;
;        could hand code .dcw opcodes as a workaround to test all encodings
;

    org $0

    nop     ; pad to avoid verify psuedo-op @ address zero

;
; enable interrupts
;
    ei


;
; 5 bit sign extended & complement
;  (note, the ".not" encodings duplicate the set of un-complemented ones for 5 bit signed constants...)
;
    mov     r0, #$ffff_fff0
    .verify r0, #$ffff_fff0

    mov.not r1, #$ffff_fff0
    .verify r1, #$0000_000f

    mov     r2, #$ffff_fff1
    .verify r2, #$ffff_fff1

    mov.not r3, #$ffff_fff1
    .verify r3, #$0000_000e

    mov     r4, #$ffff_fff2
    .verify r4, #$ffff_fff2

    mov.not r5, #$ffff_fff2
    .verify r5, #$0000_000d

    mov     r6, #$ffff_fff3
    .verify r6, #$ffff_fff3

    mov.not r7, #$ffff_fff3
    .verify r7, #$0000_000c

    mov     r8, #$ffff_fff4
    .verify r8, #$ffff_fff4

    mov.not r9, #$ffff_fff4
    .verify r9, #$0000_000b

    mov     r10, #$ffff_fff5
    .verify r10, #$ffff_fff5

    mov.not r11, #$ffff_fff5
    .verify r11, #$0000_000a

    mov     r12, #$ffff_fff6
    .verify r12, #$ffff_fff6

    mov.not r13, #$ffff_fff6
    .verify r13, #$0000_0009

    mov     r14, #$ffff_fff7
    .verify r14, #$ffff_fff7

    mov.not r14, #$ffff_fff7
    .verify r14, #$0000_0008


    mov     r0, #$ffff_fff8
    .verify r0, #$ffff_fff8

    mov.not r1, #$ffff_fff8
    .verify r1, #$0000_0007

    mov     r2, #$ffff_fff9
    .verify r2, #$ffff_fff9

    mov.not r3, #$ffff_fff9
    .verify r3, #$0000_0006

    mov     r4, #$ffff_fffa
    .verify r4, #$ffff_fffa

    mov.not r5, #$ffff_fffa
    .verify r5, #$0000_0005

    mov     r6, #$ffff_fffb
    .verify r6, #$ffff_fffb

    mov.not r7, #$ffff_fffb
    .verify r7, #$0000_0004

    mov     r8, #$ffff_fffc
    .verify r8, #$ffff_fffc

    mov.not r9, #$ffff_fffc
    .verify r9, #$0000_0003

    mov     r10, #$ffff_fffd
    .verify r10, #$ffff_fffd

    mov.not r11, #$ffff_fffd
    .verify r11, #$0000_0002

    mov     r12, #$ffff_fffe
    .verify r12, #$ffff_fffe

    mov.not r13, #$ffff_fffe
    .verify r13, #$0000_0001

    mov     r14, #$ffff_ffff
    .verify r14, #$ffff_ffff

    mov.not r14, #$ffff_ffff
    .verify r14, #$0000_0000

    mov     r0, #$0000_0000
    .verify r0, #$0000_0000

    mov.not r1, #$0000_0000
    .verify r1, #$ffff_ffff

    mov     r2, #$0000_0001
    .verify r2, #$0000_0001

    mov.not r3, #$0000_0001
    .verify r3, #$ffff_fffe

    mov     r4, #$0000_0002
    .verify r4, #$0000_0002

    mov.not r5, #$0000_0002
    .verify r5, #$ffff_fffd

    mov     r6, #$0000_0003
    .verify r6, #$0000_0003

    mov.not r7, #$0000_0003
    .verify r7, #$ffff_fffc

    mov     r8, #$0000_0004
    .verify r8, #$0000_0004

    mov.not r9, #$0000_0004
    .verify r9, #$ffff_fffb

    mov     r10, #$0000_0005
    .verify r10, #$0000_0005

    mov.not r11, #$0000_0005
    .verify r11, #$ffff_fffa

    mov     r12, #$0000_0006
    .verify r12, #$0000_0006

    mov.not r13, #$0000_0006
    .verify r13, #$ffff_fff9

    mov     r14, #$0000_0007
    .verify r14, #$0000_0007

    mov.not r14, #$0000_0007
    .verify r14, #$ffff_fff8

    mov     r0, #$0000_0008
    .verify r0, #$0000_0008

    mov.not r1, #$0000_0008
    .verify r1, #$ffff_fff7

    mov     r2, #$0000_0009
    .verify r2, #$0000_0009

    mov.not r3, #$0000_0009
    .verify r3, #$ffff_fff6

    mov     r4, #$0000_000a
    .verify r4, #$0000_000a

    mov.not r5, #$0000_000a
    .verify r5, #$ffff_fff5

    mov     r6, #$0000_000b
    .verify r6, #$0000_000b

    mov.not r7, #$0000_000b
    .verify r7, #$ffff_fff4

    mov     r8, #$0000_000c
    .verify r8, #$0000_000c

    mov.not r9, #$0000_000c
    .verify r9, #$ffff_fff3

    mov     r10, #$0000_000d
    .verify r10, #$0000_000d

    mov.not r11, #$0000_000d
    .verify r11, #$ffff_fff2

    mov     r12, #$0000_000e
    .verify r12, #$0000_000e

    mov.not r13, #$0000_000e
    .verify r13, #$ffff_fff1

    mov     r14, #$0000_000f
    .verify r14, #$0000_000f

    mov.not r14, #$0000_000f
    .verify r14, #$ffff_fff0


;
; 2^N
;
    mov     r0, #$0000_0001
    .verify r0, #$0000_0001

    mov     r1, #$0000_0002
    .verify r1, #$0000_0002

    mov     r2, #$0000_0004
    .verify r2, #$0000_0004

    mov     r3, #$0000_0008
    .verify r3, #$0000_0008

    mov     r4, #$0000_0010
    .verify r4, #$0000_0010

    mov     r5, #$0000_0020
    .verify r5, #$0000_0020

    mov     r6, #$0000_0040
    .verify r6, #$0000_0040

    mov     r7, #$0000_0080
    .verify r7, #$0000_0080

    mov     r8, #$0000_0100
    .verify r8, #$0000_0100

    mov     r9, #$0000_0200
    .verify r9, #$0000_0200

    mov     r10, #$0000_0400
    .verify r10, #$0000_0400

    mov     r11, #$0000_0800
    .verify r11, #$0000_0800

    mov     r12, #$0000_1000
    .verify r12, #$0000_1000

    mov     r13, #$0000_2000
    .verify r13, #$0000_2000

    mov     r14, #$0000_4000
    .verify r14, #$0000_4000

    mov     r14, #$0000_8000
    .verify r14, #$0000_8000

    mov     r0, #$0001_0000
    .verify r0, #$0001_0000

    mov     r1, #$0002_0000
    .verify r1, #$0002_0000

    mov     r2, #$0004_0000
    .verify r2, #$0004_0000

    mov     r3, #$0008_0000
    .verify r3, #$0008_0000

    mov     r4, #$0010_0000
    .verify r4, #$0010_0000

    mov     r5, #$0020_0000
    .verify r5, #$0020_0000

    mov     r6, #$0040_0000
    .verify r6, #$0040_0000

    mov     r7, #$0080_0000
    .verify r7, #$0080_0000

    mov     r8, #$0100_0000
    .verify r8, #$0100_0000

    mov     r9, #$0200_0000
    .verify r9, #$0200_0000

    mov     r10, #$0400_0000
    .verify r10, #$0400_0000

    mov     r11, #$0800_0000
    .verify r11, #$0800_0000

    mov     r12, #$1000_0000
    .verify r12, #$1000_0000

    mov     r13, #$2000_0000
    .verify r13, #$2000_0000

    mov     r14, #$4000_0000
    .verify r14, #$4000_0000

    mov     r14, #$8000_0000
    .verify r14, #$8000_0000

;
; NOT 2^N
;

    mov.not r0, #$0000_0001
    .verify r0, #$ffff_fffe

    mov.not r1, #$0000_0002
    .verify r1, #$ffff_fffd

    mov.not r2, #$0000_0004
    .verify r2, #$ffff_fffb

    mov.not r3, #$0000_0008
    .verify r3, #$ffff_fff7

    mov.not r4, #$0000_0010
    .verify r4, #$ffff_ffef

    mov.not r5, #$0000_0020
    .verify r5, #$ffff_ffdf

    mov.not r6, #$0000_0040
    .verify r6, #$ffff_ffbf

    mov.not r7, #$0000_0080
    .verify r7, #$ffff_ff7f

    mov.not r8, #$0000_0100
    .verify r8, #$ffff_feff

    mov.not r9, #$0000_0200
    .verify r9, #$ffff_fdff

    mov.not r10, #$0000_0400
    .verify r10, #$ffff_fbff

    mov.not r11, #$0000_0800
    .verify r11, #$ffff_f7ff

    mov.not r12, #$0000_1000
    .verify r12, #$ffff_efff

    mov.not r13, #$0000_2000
    .verify r13, #$ffff_dfff

    mov.not r14, #$0000_4000
    .verify r14, #$ffff_bfff

    mov.not r14, #$0000_8000
    .verify r14, #$ffff_7fff

    mov.not r0, #$0001_0000
    .verify r0, #$fffe_ffff

    mov.not r1, #$0002_0000
    .verify r1, #$fffd_ffff

    mov.not r2, #$0004_0000
    .verify r2, #$fffb_ffff

    mov.not r3, #$0008_0000
    .verify r3, #$fff7_ffff

    mov.not r4, #$0010_0000
    .verify r4, #$ffef_ffff

    mov.not r5, #$0020_0000
    .verify r5, #$ffdf_ffff

    mov.not r6, #$0040_0000
    .verify r6, #$ffbf_ffff

    mov.not r7, #$0080_0000
    .verify r7, #$ff7f_ffff

    mov.not r8, #$0100_0000
    .verify r8, #$feff_ffff

    mov.not r9, #$0200_0000
    .verify r9, #$fdff_ffff

    mov.not r10, #$0400_0000
    .verify r10, #$fbff_ffff

    mov.not r11, #$0800_0000
    .verify r11, #$f7ff_ffff

    mov.not r12, #$1000_0000
    .verify r12, #$efff_ffff

    mov.not r13, #$2000_0000
    .verify r13, #$dfff_ffff

    mov.not r14, #$4000_0000
    .verify r14, #$bfff_ffff

    mov.not r14, #$8000_0000
    .verify r14, #$7fff_ffff

;
; 2^N - 1
;
    mov     r0, #$0000_0000
    .verify r0, #$0000_0000

    mov     r1, #$0000_0001
    .verify r1, #$0000_0001

    mov     r2, #$0000_0003
    .verify r2, #$0000_0003

    mov     r3, #$0000_0007
    .verify r3, #$0000_0007

    mov     r4, #$0000_000f
    .verify r4, #$0000_000f

    mov     r5, #$0000_001f
    .verify r5, #$0000_001f

    mov     r6, #$0000_003f
    .verify r6, #$0000_003f

    mov     r7, #$0000_007f
    .verify r7, #$0000_007f

    mov     r8, #$0000_00ff
    .verify r8, #$0000_00ff

    mov     r9, #$0000_01ff
    .verify r9, #$0000_01ff

    mov     r10, #$0000_03ff
    .verify r10, #$0000_03ff

    mov     r11, #$0000_07ff
    .verify r11, #$0000_07ff

    mov     r12, #$0000_0fff
    .verify r12, #$0000_0fff

    mov     r13, #$0000_1fff
    .verify r13, #$0000_1fff

    mov     r14, #$0000_3fff
    .verify r14, #$0000_3fff

    mov     r14, #$0000_7fff
    .verify r14, #$0000_7fff

    mov     r0, #$0000_ffff
    .verify r0, #$0000_ffff

    mov     r1, #$0001_ffff
    .verify r1, #$0001_ffff

    mov     r2, #$0003_ffff
    .verify r2, #$0003_ffff

    mov     r3, #$0007_ffff
    .verify r3, #$0007_ffff

    mov     r4, #$000f_ffff
    .verify r4, #$000f_ffff

    mov     r5, #$001f_ffff
    .verify r5, #$001f_ffff

    mov     r6, #$003f_ffff
    .verify r6, #$003f_ffff

    mov     r7, #$007f_ffff
    .verify r7, #$007f_ffff

    mov     r8, #$00ff_ffff
    .verify r8, #$00ff_ffff

    mov     r9, #$01ff_ffff
    .verify r9, #$01ff_ffff

    mov     r10, #$03ff_ffff
    .verify r10, #$03ff_ffff

    mov     r11, #$07ff_ffff
    .verify r11, #$07ff_ffff

    mov     r12, #$0fff_ffff
    .verify r12, #$0fff_ffff

    mov     r13, #$1fff_ffff
    .verify r13, #$1fff_ffff

    mov     r14, #$3fff_ffff
    .verify r14, #$3fff_ffff

    mov     r14, #$7fff_ffff
    .verify r14, #$7fff_ffff


;
; NOT (2^N - 1)
;
    mov.not r0, #$0000_0000
    .verify r0, #$ffff_ffff

    mov.not r1, #$0000_0001
    .verify r1, #$ffff_fffe

    mov.not r2, #$0000_0003
    .verify r2, #$ffff_fffc

    mov.not r3, #$0000_0007
    .verify r3, #$ffff_fff8

    mov.not r4, #$0000_000f
    .verify r4, #$ffff_fff0

    mov.not r5, #$0000_001f
    .verify r5, #$ffff_ffe0

    mov.not r6, #$0000_003f
    .verify r6, #$ffff_ffc0

    mov.not r7, #$0000_007f
    .verify r7, #$ffff_ff80

    mov.not r8, #$0000_00ff
    .verify r8, #$ffff_ff00

    mov.not r9, #$0000_01ff
    .verify r9, #$ffff_fe00

    mov.not r10, #$0000_03ff
    .verify r10, #$ffff_fc00

    mov.not r11, #$0000_07ff
    .verify r11, #$ffff_f800

    mov.not r12, #$0000_0fff
    .verify r12, #$ffff_f000

    mov.not r13, #$0000_1fff
    .verify r13, #$ffff_e000

    mov.not r14, #$0000_3fff
    .verify r14, #$ffff_c000

    mov.not r14, #$0000_7fff
    .verify r14, #$ffff_8000

    mov.not r0, #$0000_ffff
    .verify r0, #$ffff_0000

    mov.not r1, #$0001_ffff
    .verify r1, #$fffe_0000

    mov.not r2, #$0003_ffff
    .verify r2, #$fffc_0000

    mov.not r3, #$0007_ffff
    .verify r3, #$fff8_0000

    mov.not r4, #$000f_ffff
    .verify r4, #$fff0_0000

    mov.not r5, #$001f_ffff
    .verify r5, #$ffe0_0000

    mov.not r6, #$003f_ffff
    .verify r6, #$ffc0_0000

    mov.not r7, #$007f_ffff
    .verify r7, #$ff80_0000

    mov.not r8, #$00ff_ffff
    .verify r8, #$ff00_0000

    mov.not r9, #$01ff_ffff
    .verify r9, #$fe00_0000

    mov.not r10, #$03ff_ffff
    .verify r10, #$fc00_0000

    mov.not r11, #$07ff_ffff
    .verify r11, #$f800_0000

    mov.not r12, #$0fff_ffff
    .verify r12, #$f000_0000

    mov.not r13, #$1fff_ffff
    .verify r13, #$e000_0000

    mov.not r14, #$3fff_ffff
    .verify r14, #$c000_0000

    mov.not r14, #$7fff_ffff
    .verify r14, #$8000_0000

;
; test some non-hex assembler encoding formats
;
    mov     r0, #'@
    .verify r0, #$40

    mov     r0, #-7
    .verify r0, #$ffff_fff9

    mov     r0, #%1000_0000_0000_0000_0000_0000_0000_0000
    or      r0, #%0000_0000_0000_0000_0000_0000_0000_0001
    .verify r0, #$8000_0001


done:
   bra  done


;
; ISR entry point
;
   org   $200

irq:
   nop
   rti


  end




