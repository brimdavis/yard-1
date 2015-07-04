;
; <when.s>
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
;   quick test of WHEN aliases for SKIP
;
;   As skips are more thoroughly tested elsewhere, this just confirms 
;   that all of the WHEN conditions are present and accounted for
;
;

   org $0

;
; enable interrupts
;
    ei


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; always/never
;


;
; when 
;
    mov     r0,#1
    when 
    mov     r0,#0
    nop
    .verify r0,#0

;
; when always
;
    mov     r0,#1
    when.a
    mov     r0,#0
    nop
    .verify r0,#0


;
; when never 
;
    mov     r0,#1
    when.n
    mov     r0,#0
    nop
    .verify r0,#1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; equal, zero, sign, bit tests
;

; constants used for first block of tests
    mov r1,#$0000_0000
    mov r2,#$0000_ffff
    mov r3,#$ffff_0000
    mov r4,#$ffff_0000


;
; when zero
;
    mov     r0,#1
    when.z  r1
    mov     r0,#0
    nop
    .verify r0,#0


;
; when non-zero
;
    mov     r0,#1
    when.nz r1
    mov     r0,#0
    nop
    .verify r0,#1


;
; when equal 
;
    mov     r0,#1
    when.eq r3,r4
    mov     r0,#0
    nop
    .verify r0,#0


;
; when not equal
;
    mov     r0,#1
    when.ne r3,r4
    mov     r0,#0
    nop
    .verify r0,#1


;
; when plus 
;
    mov     r0,#1
    when.pl r2
    mov     r0,#0
    nop
    .verify r0,#0


;
; when minus
;
    mov     r0,#1
    when.mi r2
    mov     r0,#0
    nop
    .verify r0,#1


;
; when greater than zero
;
    mov      r0,#1
    when.gtz r2
    mov      r0,#0
    nop
    .verify  r0,#0


;
; when less than or equal to zero
;
    mov      r0,#1
    when.lez r2
    mov      r0,#0
    nop
    .verify  r0,#1


;
; when bit set
;
    mov     r0,#1
    when.bs r3,#18
    mov     r0,#0
    nop
    .verify r0,#0


;
; when bit clear
;

    mov     r0,#1
    when.bc r3,#18
    mov     r0,#0
    nop
    .verify r0,#1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; unsigned comparisons
;

;
; when.hs  higher or same
;   unsigned, RA >= RB
;
    mov r1, #$0000_0002
    mov r2, #$0000_0001

    mov     r0,#1
    when.hs r1,r2
    mov     r0,#0
    nop
    .verify r0,#0


;
; when.lo   lower
;   unsigned, RA <  RB
;
    mov r1, #$0000_0002
    mov r2, #$0000_0001

    mov     r0,#1
    when.lo r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


;
; when.hi  higher
;   unsigned, RA >  RB
;
    mov r1, #$0000_0001
    mov r2, #$0000_0000

    mov     r0,#1
    when.hi r1,r2
    mov     r0,#0
    nop
    .verify r0,#0


;
; when.ls  lower or same
;   unsigned, RA <= RB
;
    mov r1, #$ffff_fffe
    mov r2, #$ffff_fffc

    mov     r0,#1
    when.ls r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; signed comparisons
;

;
; when.lt  less than
;   signed,   RA < RB
;
    mov     r1,#$8000_0000
    mov     r2,#$8000_0000

    mov     r0,#1
    when.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#0


;
; when.ge  greater than or equal
;   signed,   RA >= RB
;
    mov     r1, #$ffff_fffe
    mov     r2, #$ffff_ffff

    mov     r0,#1
    when.ge r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


;
; when.le  less than or equal
;   signed,   RA <= RB
;
    mov     r1, #$8000_0000
    mov     r2, #$8000_0000

    mov     r0,#1
    when.le r1,r2
    mov     r0,#0
    nop
    .verify r0,#0



;
; when.gt  greater than
;   signed,   RA > RB
;
    mov     r1, #$8000_0000
    mov     r2, #$8000_0000

    mov     r0,#1
    when.gt r1,r2
    mov     r0,#0
    nop
    .verify r0,#1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   byte|wyde zero|minus     
;

:
;    'when.awz'  =>  "WHEN Any Wyde Zero" 
;
        mov         r1,#$0000_0000

        mov         r0,#1
        when.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#0


;
;    'when.nwz'  =>  "WHEN No Wyde Zero"  
;
        mov         r1,#$0000_ffff

        mov         r0,#1
        when.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#1


;
;    'when.nwm'  =>  "WHEN No Wyde Minus"
;
        mov         r1,#$0000_7fff

        mov         r0,#1
        when.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#0


;
;    'when.awm'  =>  "WHEN Any Wyde Minus"
;
        mov         r1,#$0000_0000
        mov         r0,#1
        when.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#1


;
;    'when.abz'  =>  "WHEN Any Byte Zero"
;
        mov         r1,#$0000_0000

        mov         r0,#1
        when.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
;    'when.nbz'  =>  "WHEN No Byte Zero" 
;
        mov         r1,#$0000_00ff

        mov         r0,#1
        when.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
;    'when.abm'  =>  "WHEN Any Byte Minus"
;
        mov         r1,#$0000_00ff

        mov         r0,#1
        when.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
;    'when.nbm'  =>  "WHEN No Byte Minus" 
;
        mov         r1,#$0000_00ff

        mov         r0,#1
        when.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; skip on flag 
;
;  input flags hardwired to $55AA in testbench
;

;
; when.fs  when flag set
;
        mov     r0,#1
        when.fs #0
        mov     r0,#0
        nop
        .verify r0,#1

;
; when.fc  when flag clear
;

        mov     r0,#1
        when.fc #0
        mov     r0,#0
        nop
        .verify r0,#0

;
;
;
done:
       bra  done
       nop


;
; ISR entry point
;
       org   $200

irq:
       nop
       rti


       end


