;
; <skip2.s>
;

;
; (C) COPYRIGHT 2001-2012, 2015  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test group B skips 
;    
;   skip.lo, skip.hs, skip.ls, skip.hi    unsigned reg >=< reg
;

    org $0

;
; enable interrupts
;
    ei


;
; skip.lo   lower
;   unsigned, RA <  RB
;
    mov r1, #$0000_0000
    mov r2, #$0000_0000

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0001
    mov r2, #$0000_0000

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0000
    mov r2, #$0000_0001

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0001
    mov r2, #$0000_0001

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0002
    mov r2, #$0000_0001

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_fffc
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_fffe
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_ffff
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_fffe
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_ffff
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#0


;
; skip.hs  higher or same
;   unsigned, RA >= RB
;
    mov r1, #$0000_0000
    mov r2, #$0000_0000

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0001
    mov r2, #$0000_0000

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0000
    mov r2, #$0000_0001

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0001
    mov r2, #$0000_0001

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0002
    mov r2, #$0000_0001

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_fffc
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_fffe
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_ffff
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_fffe
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_ffff
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


;
; skip.ls  lower or same
;   unsigned, RA <= RB
;
    mov r1, #$0000_0000
    mov r2, #$0000_0000

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0001
    mov r2, #$0000_0000

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0000
    mov r2, #$0000_0001

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0001
    mov r2, #$0000_0001

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0002
    mov r2, #$0000_0001

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_fffc
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_fffe
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_ffff
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_fffe
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_ffff
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


;
; skip.hi  higher
;   unsigned, RA >  RB
;
    mov r1, #$0000_0000
    mov r2, #$0000_0000

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0001
    mov r2, #$0000_0000

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$0000_0000
    mov r2, #$0000_0001

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0001
    mov r2, #$0000_0001

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$0000_0002
    mov r2, #$0000_0001

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_fffc
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_fffe
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_ffff
    mov r2, #$ffff_fffe

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#1

    mov r1, #$ffff_fffe
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0

    mov r1, #$ffff_ffff
    mov r2, #$ffff_ffff

    mov     r0,#1
    skip.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0


;
;
;
done:
    bra  done



;
; ISR entry point
;
    org   $200

irq:
    nop
    rti


    end




