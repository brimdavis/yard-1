;
; reg1.asm
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
; test writing to each register
;

    org $0

; nop first, reset vector isn't working quite right
    nop


;
; load 'em up    
;
    mov     r0,  #$0000_0000
    mov     r1,  #$0000_0001
    mov     r2,  #$0000_0002
    mov     r3,  #$0000_0003
    mov     r4,  #$0000_0004
    mov     r5,  #$0000_0005
    mov     r6,  #$0000_0006
    mov     r7,  #$0000_0007
    mov     r8,  #$0000_0008
    mov     r9,  #$0000_0009
    mov     r10, #$0000_000a
    mov     r11, #$0000_000b
    mov     r12, #$0000_000c
    mov     r13, #$0000_000d
    mov     r14, #$0000_000e

;
; r15 now special use
;
;   mov r15, #$0000_000f

;
; then read 'em back
;  ( need nops, currently only one verify psuedo-op allowed per address )
;

    nop
    .verify r0,  #$0000_0000

    nop
    .verify r1,  #$0000_0001

    nop
    .verify r2,  #$0000_0002

    nop
    .verify r3,  #$0000_0003

    nop
    .verify r4,  #$0000_0004

    nop
    .verify r5,  #$0000_0005

    nop
    .verify r6,  #$0000_0006

    nop
    .verify r7,  #$0000_0007

    nop
    .verify r8,  #$0000_0008

    nop
    .verify r9,  #$0000_0009

    nop
    .verify r10, #$0000_000a

    nop
    .verify r11, #$0000_000b

    nop
    .verify r12, #$0000_000c

    nop
    .verify r13, #$0000_000d

    nop
    .verify r14, #$0000_000e
 

;
; r15 now special use
;
;   nop
;   .verify r15, #$0000_000f



done:
   bra  done

  end




