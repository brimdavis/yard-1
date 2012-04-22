;
; <addsub1.s>
;

;
; (C) COPYRIGHT 2001-2011  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
;   test add & subtract
;

    org     $0


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
    mov     r0,#$0000_0003
    mov     r1,#$FFFF_FFFF

    add.snc r1,#1
    .verify r1,#$0000_0000

    add     r0,#1
    .verify r0,#$0000_0004



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
    mov     r0,#$0000_0003
    mov     r1,#$0000_0000

    sub.snb r1,#1
    .verify r1,#$ffff_ffff

    sub     r0,#1
    .verify r0,#$0000_0002

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
; test sub w/borrow skip   
;
    mov     r0,#$0000_0003
    mov     r1,#$0000_0001

    rsub.snb    r1,#0
    .verify r1,#$ffff_ffff

    sub     r0,#1
    .verify r0,#$0000_0002


done:
        bra     done

    end




