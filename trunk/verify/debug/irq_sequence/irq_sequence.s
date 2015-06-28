;
; <irq_sequence.s>
;

;
; (C) COPYRIGHT 2014,2015 Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; regular add pattern to test interrupt handling
;

    org     $0

    nop

;
; enable interrupts
;
    ei

;
; sucessive adds
;
    mov     r0,#$0
    mov     r1,#$0

    add     r0,#1
    nop
    .verify r0,#$0000_0001

    add     r0,#1
    nop
    .verify r0,#$0000_0002

    add     r0,#1
    nop
    .verify r0,#$0000_0003

    add     r0,#1
    nop
    .verify r0,#$0000_0004

;
; call subroutines to check proper stack operation during interrupts
;
    bsr  sub1
    bsr  sub2
    nop

;
; check that ISR incremented r1 as expected
;
    nop
    .verify r1,#$0000_0002


done:
        bra     done

;
;
;
sub1:


    add     r0,#1
    nop
    .verify r0,#$0000_0005

    add     r0,#1
    nop
    .verify r0,#$0000_0006

    add     r0,#1
    nop
    .verify r0,#$0000_0007

    add     r0,#1
    nop
    .verify r0,#$0000_0008

    add     r0,#1
    nop
    .verify r0,#$0000_0009

    add     r0,#1
    nop
    .verify r0,#$0000_000a

    add     r0,#1         
    nop
    .verify r0,#$0000_000b

    add     r0,#1
    nop
    .verify r0,#$0000_000c

    add     r0,#1
    nop
    .verify r0,#$0000_000d

    add     r0,#1
    nop
    .verify r0,#$0000_000e

    add     r0,#1
    nop
    .verify r0,#$0000_000f


    add     r0,#1
    nop
    .verify r0,#$0000_0010

    add     r0,#1
    nop
    .verify r0,#$0000_0011

    add     r0,#1
    nop
    .verify r0,#$0000_0012

    add     r0,#1
    nop
    .verify r0,#$0000_0013

    add     r0,#1
    nop
    .verify r0,#$0000_0014

    add     r0,#1
    nop
    .verify r0,#$0000_0015

    add     r0,#1
    nop
    .verify r0,#$0000_0016

    add     r0,#1
    nop
    .verify r0,#$0000_0017

    add     r0,#1
    nop
    .verify r0,#$0000_0018

    add     r0,#1
    nop
    .verify r0,#$0000_0019

    add     r0,#1
    nop
    .verify r0,#$0000_001a

    add     r0,#1         
    nop
    .verify r0,#$0000_001b

    add     r0,#1
    nop
    .verify r0,#$0000_001c

    add     r0,#1
    nop
    .verify r0,#$0000_001d

    add     r0,#1
    nop
    .verify r0,#$0000_001e

    add     r0,#1
    nop
    .verify r0,#$0000_001f


    add     r0,#1
    nop
    .verify r0,#$0000_0020

    add     r0,#1
    nop
    .verify r0,#$0000_0021

    add     r0,#1
    nop
    .verify r0,#$0000_0022

    add     r0,#1
    nop
    .verify r0,#$0000_0023

    add     r0,#1
    nop
    .verify r0,#$0000_0024

    add     r0,#1
    nop
    .verify r0,#$0000_0025

    add     r0,#1
    nop
    .verify r0,#$0000_0026

    add     r0,#1
    nop
    .verify r0,#$0000_0027

    add     r0,#1
    nop
    .verify r0,#$0000_0028

    add     r0,#1
    nop
    .verify r0,#$0000_0029

    add     r0,#1
    nop
    .verify r0,#$0000_002a

    add     r0,#1         
    nop
    .verify r0,#$0000_002b

    add     r0,#1
    nop
    .verify r0,#$0000_002c

    add     r0,#1
    nop
    .verify r0,#$0000_002d

    add     r0,#1
    nop
    .verify r0,#$0000_002e

    add     r0,#1
    nop
    .verify r0,#$0000_002f

    rts

;
;
;
sub2:
    add     r0,#1
    nop
    .verify r0,#$0000_0030

    add     r0,#1
    nop
    .verify r0,#$0000_0031

    add     r0,#1
    nop
    .verify r0,#$0000_0032

    add     r0,#1
    nop
    .verify r0,#$0000_0033

    add     r0,#1
    nop
    .verify r0,#$0000_0034

    add     r0,#1
    nop
    .verify r0,#$0000_0035

    add     r0,#1
    nop
    .verify r0,#$0000_0036

    add     r0,#1
    nop
    .verify r0,#$0000_0037

    add     r0,#1
    nop
    .verify r0,#$0000_0038

    add     r0,#1
    nop
    .verify r0,#$0000_0039

    add     r0,#1
    nop
    .verify r0,#$0000_003a

    add     r0,#1         
    nop
    .verify r0,#$0000_003b

    add     r0,#1
    nop
    .verify r0,#$0000_003c

    add     r0,#1
    nop
    .verify r0,#$0000_003d

    add     r0,#1
    nop
    .verify r0,#$0000_003e

    add     r0,#1
    nop
    .verify r0,#$0000_003f

    rts

;
; ISR entry point
;
   org   $200

irq:
   add   r1,#1
   rti


   end




