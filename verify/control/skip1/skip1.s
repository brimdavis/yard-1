;
; <skip1.s>
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
; try out skips : 
;    always/never
;    reg >=< zero 
;    reg = reg 
;    bit set/clear
;    combos
;

   org $0

; nop first, reset vector isn't working quite right
    nop

    mov r1,#$0000_0000
    mov r2,#$0000_ffff
    mov r3,#$ffff_0000
    mov r4,#$ffff_0000


;
; skip always
;
    mov     r0,#1
    skip
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.a
    mov     r0,#0
    nop
    .verify r0,#1

;
; skip never
;
    mov     r0,#1
    skip.n
    mov     r0,#0
    nop
    .verify r0,#0

;
; skip zero
;
    mov     r0,#1
    skip.z  r1
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r0,#1
    skip.z  r2
    mov     r0,#0
    nop
    .verify r0,#0

;
; skip non-zero
;
    mov     r0,#1
    skip.nz r2
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r0,#1
    skip.nz r1
    mov     r0,#0
    nop
    .verify r0,#0


;
; skip equal
;
    mov     r0,#1
    skip.eq r3,r4
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r0,#1
    skip.eq r2,r3
    mov     r0,#0
    nop
    .verify r0,#0

;
; skip not equal
;
    mov     r0,#1
    skip.ne r3,r4
    mov     r0,#0
    nop
    .verify r0,#0


    mov     r0,#1
    skip.ne r2,r3
    mov     r0,#0
    nop
    .verify r0,#1

;
; skip plus
;
    mov     r0,#1
    skip.pl r2
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r0,#1
    skip.pl r3
    mov     r0,#0
    nop
    .verify r0,#0


;
; skip minus
;
    mov     r0,#1
    skip.mi r2
    mov     r0,#0
    nop
    .verify r0,#0


    mov     r0,#1
    skip.mi r3
    mov     r0,#0
    nop
    .verify r0,#1


;
; skip greater than zero
;
    mov      r0,#1
    skip.gtz r2
    mov      r0,#0
    nop
    .verify  r0,#1

    mov      r0,#1
    skip.gtz r1
    mov      r0,#0
    nop
    .verify  r0,#0

    mov      r0,#1
    skip.gtz r3
    mov      r0,#0
    nop
    .verify  r0,#0


;
; skip less than or equal to zero
;
    mov      r0,#1
    skip.lez r1
    mov      r0,#0
    nop
    .verify  r0,#1

    mov      r0,#1
    skip.lez r3
    mov      r0,#0
    nop
    .verify  r0,#1

    mov      r0,#1
    skip.lez r2
    mov      r0,#0
    nop
    .verify r0,#0


;
; skip bit set
;
    mov     r0,#1
    skip.bs r2,#14
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r0,#1
    skip.bs r2,#18
    mov     r0,#0
    nop
    .verify r0,#0

;
; skip bit clear
;
    mov     r0,#1
    skip.bc r2,#18
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r0,#1
    skip.bc r2,#14
    mov     r0,#0
    nop
    .verify r0,#0



;
; try out some weird skip combos
;


;
; skip a skip
;
    mov     r0,#1
    skip.nz r2
    skip     
    mov     r0,#0
    nop
    .verify r0,#0

;
; skip a branch
;
    mov     r0,#1
    skip.nz r2
    bra     error
    mov     r0,#0
    nop
    .verify r0,#0


;
; branch over a skip
;
    mov     r0,#1
    bra     no_skip_now
    skip
no_skip_now:
    mov     r0,#0
    nop
    .verify r0,#0


;
; test for yardbug parser loop hangup condition
;
    skip.nz r3
    bra     error

    skip.ne r3,r4
    bra     got_it

    bra     error

got_it:
    nop
    .verify r1,#0

;
;
;
done:
    bra  done
    nop

;
; force a verify error
;
error:
    nop
    .verify fail
    bra     done


    end




