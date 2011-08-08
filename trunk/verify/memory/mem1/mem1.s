;
; <mem1.s>
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
; test load/store
;

    org $0

; nop first, reset vector isn't working quite right
    nop

; use zero for base address
    mov     r2, #0

;
; Note:
;  need nop's before verify's so load has completed when testbench checks for
;  an address match;  otherwise, it checks register file both on the first cycle
;  of the load, before  the load writeback has completed (and fails), then again
;  on the second cycle (and passes)
;
;  Need to update verify routine to ignore load stalls
;

;
; load long
;
    imm12   #K_LB0
    ld.q    r0, .imm(r2)
    nop
    .verify r0,#$8765_4321
;
; load word
;   even/odd word addresses, signed/unsigned loads
;
    imm12   #K_LB0
    ld.w    r0, .imm(r2)
    nop
    .verify r0,#$ffff_8765

    imm12   #K_LB0
    ld.uw   r0, .imm(r2)
    nop
    .verify r0,#$0000_8765

    imm12   #K_LB2
    ld.w    r0, .imm(r2)
    nop
    .verify r0,#$0000_4321

    imm12   #K_LB2
    ld.uw   r0, .imm(r2)
    nop
    .verify r0,#$0000_4321

;
; load byte
;  byte address offsets of 0,1,2,3, signed/unsigned loads
;
    imm12   #K_LB0
    ld.b    r0, .imm(r2)
    nop
    .verify r0,#$ffff_ff87

    imm12   #K_LB0
    ld.ub   r0, .imm(r2)
    nop
    .verify r0,#$0000_0087

    imm12   #K_LB1
    ld.b    r0, .imm(r2)
    nop
    .verify r0,#$0000_0065

    imm12   #K_LB1
    ld.ub   r0, .imm(r2)
    nop
    .verify r0,#$0000_0065

    imm12   #K_LB2
    ld.b    r0, .imm(r2)
    nop
    .verify r0,#$0000_0043

    imm12   #K_LB2
    ld.ub   r0, .imm(r2)
    nop
    .verify r0,#$0000_0043

    imm12   #K_LB3
    ld.b    r0, .imm(r2)
    nop
    .verify r0,#$0000_0021

    imm12   #K_LB3
    ld.ub   r0, .imm(r2)
    nop
    .verify r0,#$0000_0021

;
; check out loads for skip & branch delay slots
;

; make sure skipped load doesn't write to register
    mov     r0,#0
    imm12   #K_LB0

    skip
    ld.q    r0, .imm(r2)

    nop
    .verify r0,#0

; make sure load in nulled branch slot doesn't write to register
    mov     r0,#0
    imm12   #K_LB0
    bra     t1
    ld.q    r0, .imm(r2)
    nop
t1:
    nop
    .verify r0,#0


; make sure load in enabled branch slot does write to register
    mov     r0,#0
    imm12   #K_LB0
    bra.d   t2
    ld.q    r0, .imm(r2)
    nop
t2:
    nop
    .verify r0,#$8765_4321

;
; now try some stores
;

;
; store long 
;

; read the load test long
    imm12   #K_LB0
    ld.q    r0, .imm(r2)    

; complement & write it to the store test long
    not     r0
    imm12   #K_SB0
    st.q    r0, .imm(r2)

; then read it back 
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$789A_BCDE


;
; store word
;

; load, complement, write back high order word
    imm12   #K_SB0
    ld.w    r0, .imm(r2)
    not     r0
    st.w    r0, .imm(r2)

; then read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$8765_BCDE

; load, complement, write back low order word
    imm12   #K_SB2
    ld.w    r0, .imm(r2)
    not     r0
    st.w    r0, .imm(r2)

; then read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$8765_4321

;
; store byte
;

; load, complement, write back byte 0
    imm12   #K_SB0
    ld.b    r0, .imm(r2)
    not     r0
    st.b    r0, .imm(r2)

; then read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$7865_4321


; load, complement, write back byte 1
    imm12   #K_SB1
    ld.b    r0, .imm(r2)
    not     r0
    st.b    r0, .imm(r2)

; then read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$789a_4321


; load, complement, write back byte 2
    imm12   #K_SB2
    ld.b    r0, .imm(r2)
    not     r0
    st.b    r0, .imm(r2)

; then read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$789a_bc21


; load, complement, write back byte 3
    imm12   #K_SB3
    ld.b    r0, .imm(r2)
    not     r0
    st.b    r0, .imm(r2)

; then read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$789a_bcde

;
; check out stores for skip & branch delay slots
;

; make sure skipped store doesn't write to memory
    mov     r0,#0
    imm12   #K_SB0

    skip
    st.q    r0, .imm(r2)

; read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$789a_bcde


; make sure store in nulled branch slot doesn't write to memory  
    mov     r0,#0
    imm12   #K_SB2
    bra     t3
    st.w    r0, .imm(r2)
    nop
t3:

; read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$789a_bcde


; make sure store in enabled branch slot does write to memory
    mov     r0,#0
    imm12   #K_SB1
    bra.d       t4
    st.b    r0, .imm(r2)
    nop
t4:

; read back entire long
    imm12   #K_SB0
    ld.q    r0, .imm(r2)    
    nop
    .verify r0,#$7800_bcde


done:
    bra  done


;
; constant table 
;
;
    align   4

K_TABLE:

K_LB0:   dc.b    $87
K_LB1:   dc.b    $65
K_LB2:   dc.b    $43
K_LB3:   dc.b    $21

K_SB0:   dc.b    $00
K_SB1:   dc.b    $00
K_SB2:   dc.b    $00
K_SB3:   dc.b    $00


    end




