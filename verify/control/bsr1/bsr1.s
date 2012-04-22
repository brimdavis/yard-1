;
; <bsr1.s>
;

;
; (C) COPYRIGHT 2001-2012  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; check out BSR
;
; note: sundry extra nop's stop the verify program from checking 
;       results when opcode has been nulled
;

       org $0

; r0 = test flags
        mov     r0, #0

; start stacking up subroutine calls
        bsr.d   sub1
        xor     r0,#$8000_0000

        nop     
        .verify r0,#$8000_FFFF

done:
        bra     done
        nop

sub1:
        nop

        xor     r0,#$0000_0001
        .verify r0,#$8000_0001

        bsr     sub2

        rts

sub2:
        nop

        or      r0,#$0000_0002
        .verify r0,#$8000_0003

        bsr     sub3

        rts

sub3:
        nop

        or      r0,#$0000_0004
        .verify r0,#$8000_0007

        bsr     sub4

        rts

sub4:
        nop

        or      r0,#$0000_0008
        .verify r0,#$8000_000f

        bsr     sub5

        rts

sub5:
        nop

        or      r0,#$0000_0010
        .verify r0,#$8000_001f

        bsr     sub6

        rts

sub6:
        nop

        or      r0,#$0000_0020
        .verify r0,#$8000_003f

        bsr     sub7

        rts

sub7:
        nop

        or      r0,#$0000_0040
        .verify r0,#$8000_007f

        bsr     sub8

        rts

sub8:
        nop

        or      r0,#$0000_0080
        .verify r0,#$8000_00ff

        bsr     sub9

        rts

sub9:
        nop

        or      r0,#$0000_0100
        .verify r0,#$8000_01FF

        bsr     sub10

        rts

sub10:
        nop

        or      r0,#$0000_0200
        .verify r0,#$8000_03FF

        bsr     sub11

        rts

sub11:
        nop

        or      r0,#$0000_0400
        .verify r0,#$8000_07FF

        bsr     sub12

        rts

sub12:
        nop

        or      r0,#$0000_0800
        .verify r0,#$8000_0FFF

        bsr     sub13

        rts

sub13:
        nop

        or      r0,#$0000_1000
        .verify r0,#$8000_1FFF

        bsr     sub14

        rts

sub14:
        nop

        or      r0,#$0000_2000
        .verify r0,#$8000_3FFF

        bsr     sub15

        rts

sub15:
        nop

        or      r0,#$0000_4000
        .verify r0,#$8000_7FFF

        bsr     sub16

        rts

sub16:
        nop     ; verify hack

        or      r0,#$0000_8000
        .verify r0,#$8000_FFFF

        rts




  end




