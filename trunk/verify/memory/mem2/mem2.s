;
; <mem2.s>
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
; test stack load/store
;

    org $0

; nop first, reset vector isn't working quite right
    nop


;
; initialize stack & frame pointer
;
    imm12   #K_STACK
    mov     r13,r14

    imm12   #K_S8
    mov     r12,r14

;
; Note:
;  need nop's before verify's so load has completed when testbench checks for
;  an address match;  otherwise, it checks register file both on the first cycle
;  of the load, before  the load writeback has completed (and fails), then again
;  on the second cycle (and passes)
;
;  Need to update verify routine to ignore load stalls
;


; assembler equivalent syntax, assembles as normal indirect mode without offset 

    ld      r0, (sp)
    ld.q    r0, (r13)

    ld.q    r0, 0(sp)
    ld.q    r0, 0(r13)

    ld      r0, (fp)
    ld.q    r0, (r12)

    ld.q    r0, 0(fp)
    ld.q    r0, 0(r12)

; unaligned addresses illegal for stack offset address modes
;   ld.b    r0, 0(sp)
;   ld.ub   r0, 4(r13)
;
;   ld.w    r0, 8(fp)
;   ld.uw   r0, 12(r12)

;
; test loads
;
    ld.q    r0, 0(r13)
    nop
    .verify r0,#$5555_0000

    ld      r0, 4(sp)
    nop
    .verify r0,#$aaaa_0001

    ld      r0, 8(sp)
    nop
    .verify r0,#$5555_0002

    ld      r0, 12(sp)
    nop
    .verify r0,#$aaaa_0003

    ld      r0, 16(sp)
    nop
    .verify r0,#$5555_0004

    ld      r0, 20(sp)
    nop
    .verify r0,#$aaaa_0005

    ld      r0, 24(sp)
    nop
    .verify r0,#$5555_0006

    ld      r0, 28(sp)
    nop
    .verify r0,#$aaaa_0007

    ld      r0, 32(sp)
    nop
    .verify r0,#$5555_0008

    ld      r0, 36(sp)
    nop
    .verify r0,#$aaaa_0009

    ld      r0, 40(sp)
    nop
    .verify r0,#$5555_000a

    ld      r0, 44(sp)
    nop
    .verify r0,#$aaaa_000b

    ld      r0, 48(sp)
    nop
    .verify r0,#$5555_000c

    ld      r0, 52(sp)
    nop
    .verify r0,#$aaaa_000d

    ld      r0, 56(sp)
    nop
    .verify r0,#$5555_000e

    ld      r0, 60(sp)
    nop
    .verify r0,#$aaaa_000f

;
; now try some stores
;

;
; store long 
;

; read the first test word
    ld      r0, 0(sp)   

; complement & write it back
    not     r0
    st      r0, 0(sp)

; then read it back 
    ld      r0, 0(sp)   
    nop
    .verify r0,#$aaaa_ffff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; try subset of ops with frame pointer
;

    ld      r0, 0(fp)
    nop
    .verify r0,#$5555_0008


    ld      r0, 28(r12)
    nop
    .verify r0,#$aaaa_000f


; complement & write it back
    not     r0
    st      r0, 28(fp)


    ld      r0, 28(r12)
    nop
    .verify r0,#$5555_fff0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; try LEA with stack & frame pointer
;

    lea     r0, 0(r13)
    .verify r0,#$200

    lea     r0, 60(sp)
    .verify r0,#$23C

    lea     r0, 0(fp)
    .verify r0,#$220

    lea     r0, 32(r12)
    .verify r0,#$240


done:
    bra  done


;
; constant table 
;
;
        org $200

K_STACK:

K_S0:   dc.q    $5555_0000
K_S1:   dc.q    $aaaa_0001
K_S2:   dc.q    $5555_0002
K_S3:   dc.q    $aaaa_0003

K_S4:   dc.q    $5555_0004
K_S5:   dc.q    $aaaa_0005
K_S6:   dc.q    $5555_0006
K_S7:   dc.q    $aaaa_0007

K_S8:   dc.q    $5555_0008
K_S9:   dc.q    $aaaa_0009
K_Sa:   dc.q    $5555_000a
K_Sb:   dc.q    $aaaa_000b

K_Sc:   dc.q    $5555_000c
K_Sd:   dc.q    $aaaa_000d
K_Se:   dc.q    $5555_000e 
K_Sf:   dc.q    $aaaa_000f


        end




