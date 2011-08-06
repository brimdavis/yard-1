;
; <jsr1.s>
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
; check out JSR/RTS
; also stacks return addresses 16 deep
;
; note: sundry extra nop's stop the verify program from checking 
;       results when opcode has been nulled


       org $0

; nop first, reset vector isn't working quite right
        nop


;
; r2 = base address
;
        mov     r2, #0

; r0 = test flags
        mov     r0, #0

; start stacking up subroutine calls
        imm12   #sub1
        lea     r1, .imm(r2)
        jsr     (r1)

        nop     ; verify hack
        nop     
        .verify r0,#$0000_FFFF

done:
        bra     done
        nop

sub1:
        imm12   #sub2
        lea     r1, .imm(r2)

        or      r0,#$0000_0001
        .verify r0,#$0000_0001

        jsr     (r1)
        rts

sub2:
        imm12   #sub3
        lea     r1, .imm(r2)

        or      r0,#$0000_0002
        .verify r0,#$0000_0003

        jsr     (r1)
        rts

sub3:
        imm12   #sub4
        lea     r1, .imm(r2)

        or      r0,#$0000_0004
        .verify r0,#$0000_0007

        jsr     (r1)
        rts

sub4:
        imm12   #sub5
        lea     r1, .imm(r2)

        or      r0,#$0000_0008
        .verify r0,#$0000_000f

        jsr     (r1)
        rts

sub5:
        imm12   #sub6
        lea     r1, .imm(r2)

        or      r0,#$0000_0010
        .verify r0,#$0000_001f

        jsr     (r1)
        rts

sub6:
        imm12   #sub7
        lea     r1, .imm(r2)

        or      r0,#$0000_0020
        .verify r0,#$0000_003f

        jsr     (r1)
        rts

sub7:
        imm12   #sub8
        lea     r1, .imm(r2)

        or      r0,#$0000_0040
        .verify r0,#$0000_007f

        jsr     (r1)
        rts

sub8:
        imm12   #sub9
        lea     r1, .imm(r2)

        or      r0,#$0000_0080
        .verify r0,#$0000_00ff

        jsr     (r1)
        rts

sub9:
        imm12   #sub10
        lea     r1, .imm(r2)

        or      r0,#$0000_0100
        .verify r0,#$0000_01FF

        jsr     (r1)
        rts

sub10:
        imm12   #sub11
        lea     r1, .imm(r2)

        or      r0,#$0000_0200
        .verify r0,#$0000_03FF

        jsr     (r1)
        rts

sub11:
        imm12   #sub12
        lea     r1, .imm(r2)

        or      r0,#$0000_0400
        .verify r0,#$0000_07FF

        jsr     (r1)
        rts

sub12:
        imm12   #sub13
        lea     r1, .imm(r2)

        or      r0,#$0000_0800
        .verify r0,#$0000_0FFF

        jsr     (r1)
        rts

sub13:
        imm12   #sub14
        lea     r1, .imm(r2)

        or      r0,#$0000_1000
        .verify r0,#$0000_1FFF

        jsr     (r1)
        rts

sub14:
        imm12   #sub15
        lea     r1, .imm(r2)

        or      r0,#$0000_2000
        .verify r0,#$0000_3FFF

        jsr     (r1)
        rts

sub15:
        imm12   #sub16
        lea     r1, .imm(r2)

        or      r0,#$0000_4000
        .verify r0,#$0000_7FFF

        jsr   (r1)
        rts

sub16:
        nop     ; verify hack
        or      r0,#$0000_8000
        .verify r0,#$0000_FFFF
        rts




  end




