;
; <skip3.s>
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
; test group B skips
;
;   skip.lt, skip.ge    signed reg >=< reg
;

    org $0

; nop first, reset vector isn't working quite right
    nop

;
; skip.lt  less than
;   signed,   RA < RB
;
; skip.ge  greater than or equal
;   signed,   RA >= RB
;
    mov     r1,#$8000_0000
    mov     r2,#$8000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$8000_0000
    inc     r1               ; $8000_0001
    mov     r2, #$8000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$8000_0000
    mov     r2, #$8000_0000
    inc     r2               ; $8000_0001

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$8000_0000
    inc     r1               ; $8000_0001
    mov     r2, #$8000_0000
    inc     r2               ; $8000_0001

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$8000_0000
    add     r1, #2           ; $8000_0002
    mov     r2, #$8000_0000
    inc     r2               ; $8000_0001

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$ffff_fffe
    mov     r2, #$ffff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$ffff_ffff
    mov     r2, #$ffff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$0000_0000
    mov     r2, #$ffff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$ffff_ffff
    mov     r2, #$0000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$0000_0000
    mov     r2, #$0000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$0000_0001
    mov     r2, #$0000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$0000_0000
    mov     r2, #$0000_0001

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$0000_0001
    mov     r2, #$0000_0001

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$0000_0002
    mov     r2, #$0000_0001

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$7fff_ffff
    sub     r1, #2           ; $7fff_fffd
    mov     r2, #$7fff_ffff
    sub     r2, #1           ; $7fff_fffe

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$7fff_ffff
    sub     r1, #1           ; $7fff_fffe
    mov     r2, #$7fff_ffff
    sub     r2, #1           ; $7fff_fffe

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$7fff_ffff
    mov     r2, #$7fff_ffff
    sub     r2, #1           ; $7fff_fffe

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$7fff_ffff
    sub     r1, #1           ; $7fff_fffe
    mov     r2, #$7fff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$7fff_ffff
    mov     r2, #$7fff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


    mov     r1, #$8000_0000
    mov     r2, #$ffff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$8000_0000
    mov     r2, #$0000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$8000_0000
    mov     r2, #$7fff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$ffff_ffff
    mov     r2, #$8000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$ffff_ffff
    mov     r2, #$ffff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r1, #$ffff_ffff
    mov     r2, #$0000_0000

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov     r1, #$ffff_ffff
    mov     r2, #$7fff_ffff

    mov     r0,#1
    skip.lt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov     r0,#1
    skip.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

;
;
;
done:
    bra  done
    nop

    end




