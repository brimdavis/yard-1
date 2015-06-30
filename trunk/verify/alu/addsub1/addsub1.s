;
; <addsub1.s>
;

;
; (C) COPYRIGHT 2001-2013, 2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
;   test add & subtract
;

    org     $0


;
; enable interrupts
;
    ei

;
; try some adds
;
    mov     r0,#$0

    add     r0,#1
    .verify r0,#$0000_0001

    add     r0,#$7fff_ffff
    .verify r0,#$8000_0000

    add     r0,#1
    .verify r0,#$8000_0001

    add     r0,#$7fff_ffff
    .verify r0,#$0000_0000

;
; try out add w/carry skip
;

; carry
    mov     r0,#$0000_0003
    mov     r1,#$FFFF_FFFF

    add.snc r1,#1
    .verify r1,#$0000_0000

    add     r0,#1
    .verify r0,#$0000_0004

; carry
    mov     r0,#$0000_0003
    mov     r1,#$8000_0000

    add.snc r1,#$8000_0000
    .verify r1,#$0000_0000

    add     r0,#1
    .verify r0,#$0000_0004


; no carry
    mov     r0,#$0000_0003
    mov     r1,#$FFFF_FFFE

    add.snc r1,#1
    .verify r1,#$FFFF_FFFF

    add     r0,#1
    .verify r0,#$0000_0003


;
; try some subtracts
;
    mov     r0,#$0

    sub     r0,#1
    .verify r0,#$ffff_ffff

    sub     r0,#$7fff_ffff
    .verify r0,#$8000_0000

    sub     r0,#1
    .verify r0,#$7fff_ffff

    sub     r0,#$7fff_ffff
    .verify r0,#$0000_0000


;
; test sub w/borrow skip   
;

; borrow
    mov     r0,#1
    mov     r1,#0

    sub.snb r1,#1
    .verify r1,#$ffff_ffff

    mov     r0,#0       
    .verify r0,#0       

; borrow
    mov     r0,#1
    mov     r1,#$ffff_fffe

    sub.snb r1,#$ffff_ffff
    .verify r1,#$ffff_ffff

    mov     r0,#0       
    .verify r0,#0       

; borrow
    mov     r0,#1
    mov     r1,#$3fff_ffff

    sub.snb r1,#$4000_0000
    .verify r1,#$ffff_ffff

    mov     r0,#0       
    .verify r0,#0       

; no borrow
    mov     r0,#1
    mov     r1,#$4000_0000

    sub.snb r1,#$4000_0000
    .verify r1,#$0000_0000

    mov     r0,#0       
    .verify r0,#1

; no borrow
    mov     r0,#1
    mov     r1,#$8000_0000

    sub.snb r1,#$8000_0000
    .verify r1,#$0000_0000

    mov     r0,#0       
    .verify r0,#1

; no borrow
    mov     r0,#1
    mov     r1,#$ffff_ffff

    sub.snb r1,#$ffff_ffff
    .verify r1,#$0000_0000

    mov     r0,#0       
    .verify r0,#1

;
; try some reverse subtracts
;
    mov     r0,#$1

    rsub    r0,#0
    .verify r0,#$ffff_ffff

;
    mov     r0,#$7fff_ffff
    rsub    r0,#$ffff_ffff
    .verify r0,#$8000_0000

;
    mov     r0,#$1
    rsub    r0,#$8000_0000
    .verify r0,#$7fff_ffff

    rsub    r0,#$7fff_ffff
    .verify r0,#$0000_0000


;
; test rsub w/borrow skip   
;

;
    mov     r0,#1
    mov     r1,#$0000_0001

    rsub.snb    r1,#$0000_0000
    .verify r1,#$ffff_ffff

    mov     r0,#0       
    .verify r0,#0       

;
    mov     r0,#1
    mov     r1,#$ffff_ffff

    rsub.snb    r1,#$0000_0000
    .verify r1,#$0000_0001

    mov     r0,#0       
    .verify r0,#0       

; 
    mov     r0,#1
    mov     r1,#$ffff_fffc

    rsub.snb    r1,#$ffff_fff8
    .verify r1,#$ffff_fffc

    mov     r0,#0       
    .verify r0,#0       

; 
    mov     r0,#1
    mov     r1,#-7

    rsub.snb    r1,#-7
    .verify r1,#$0000_0000

    mov     r0,#0       
    .verify r0,#1       


done:
        bra     done


;
; ISR entry point
;
   org   $200

irq:
   nop
   rti



    end




