;
; <imm_auto.s>
;

;
; (C) COPYRIGHT 2001-2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test automatic imm constants
;

    org $0

;
; enable interrupts
;
    ei

;
; check near 0, +max, -min, 
; these should fit in short constant mode
; note sign extension
;

    imm   #$0000_0000
    .verify  r14,#$0000_0000

    imm   #$0000_0001
    .verify  r14,#$0000_0001

    imm   #$7fff_ffff
    .verify  r14,#$7fff_ffff

    imm   #$7fff_fffe
    .verify  r14,#$7fff_fffe

    imm   #$8000_0000
    .verify  r14,#$8000_0000

    imm   #$8000_0001
    .verify  r14,#$8000_0001

    imm   #$FFFF_FFFF
    .verify  r14,#$FFFF_FFFF

    imm   #$FFFF_FFFE
    .verify  r14,#$FFFF_FFFE

;
; check some values that should fit in IMM12
;

    imm   #100
    .verify  r14,#100

    imm   #-500
    .verify  r14,#-500

    imm   #1000
    .verify  r14,#1000

    imm   #2046
    .verify  r14,#2046

    imm   #-2046
    .verify  r14,#-2046


;
; check some arbitrary values that should go into automatic imm table
;

    imm   #$1234_5678
    .verify  r14,#$1234_5678

    imm   #$DEAD_BEEF
    .verify  r14,#$DEAD_BEEF

    imm   #$CAFE_F00D
    .verify  r14,#$CAFE_F00D

    imm   #$FF00_FF00
    .verify  r14,#$FF00_FF00

    imm   #$F0F0_0F0F
    .verify  r14,#$F0F0_0F0F

    imm   #4_000_000_000
    .verify  r14,#4_000_000_000

    imm   #-2_000_000_000
    .verify  r14,#-2_000_000_000

; branch over table
    bra check_merge
;
; dump the current imm table
;
    .imm_table

;
; test table entry merge code using known/unknown on pass 1 with same values
;
test1  equ -2_000_000_000


check_merge:
;
; matching constants should merge, as they are known on pass 1
;
    imm   #-2000000000
    .verify  r14,#-2000000000

    imm   #1_234_567_890
    .verify  r14,#1234567890

    imm   #test1
    .verify  r14,#-2000000000

    imm   #-2000000000
    .verify  r14,#-2000000000

; both test2 forward references below should share an entry (expression string match for unknown pass1 values)
    imm   #test2
    .verify  r14,#-2000000000

    imm   #test2
    .verify  r14,#-2000000000

; this should merge with previous #-2000000000's
    imm   #-2000000000
    .verify  r14,#-2000000000

; both test3 forward references below should share an entry (expression string match for unknown pass1 values)
    imm   #test3
    .verify  r14,#-2000000000

    imm   #test3
    .verify  r14,#-2000000000

; branch over table
    bra check_skips

;
; forward definitions
;
test2  equ test1
test3  equ test2

;
; dump the current imm table
;
    .imm_table


check_skips:
;
; make sure skipped imm doesn't write to register
;
    mov     r14,#0

    skip
    imm   #$BADD_D00D

    nop
    .verify  r14,#$0000_0000

;
; make sure load in nulled branch slot doesn't write to register
;
    mov     r14,#0

    bra     t1
    imm   #$BADD_D00D

t1:
    nop
    .verify r14,#$0000_0000


;
; make sure load in enabled branch slot does write to register
;
    mov     r14,#0

    bra.d   t2
    imm   #$AAAA_5555

t2:
    nop
    .verify r14,#$AAAA_5555

    nop

; branch over table
    bra check_C_ref

 .imm_table


;
; test C forward reference issues seen
;
check_C_ref:

 imm #stdout_putf
 nop
 .verify  r14,#stdout_putf

 imm #stdout_putp
 nop
 .verify  r14,#stdout_putp

 bra next_test

 .imm_table

;
;
;
next_test:
    nop

done:
    bra  done



;
; ISR entry point
;
   org   $200

irq:
   nop
   rti



;
; start above $800 to see autoimm issues with generated LDI table
;
  org $c00

 .section bss

stdout_putp: .common 4,4
 .local stdout_putp
  .type stdout_putp,object
 .size stdout_putp,4

stdout_putf: .common 4,4
 .local stdout_putf
  .type stdout_putf,object
 .size stdout_putf,4



    end




