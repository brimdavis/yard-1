;
; beginnings of a C support library for lcc port
;

;
; multiply, divide, modulus
;
; TODO: 
;   - check sign handling
;   - check negation overflow handling for input of -2^N 
;   - testcases
;

;
; signed multiply
;
; entry: 
;   r0 : operand a
;   r1 : operand b
;
; exit: 
;   r0 = a * b  ( returns 32 least significant bits of 64-bit product in r0 )
;
; uses:
;   r0,r1,r4
;
__muls:

    mov     r4,r0   ; move operand a to r4
    clr     r0      ; clear result

    when.z  r1      ; early exit when b = 0
    rts

;
; FIXME: is any sign adjustment needed when returning only LSW of 64 bit product ?
;

    bra     __mulu.check_for_zero       ; tail call


;
; unsigned multiply
;
; entry: 
;   r0 : operand a
;   r1 : operand b
;
; exit: 
;   r0 = a * b  ( returns 32 least significant bits of 64-bit product in r0 )
;
; uses:
;   r0,r1,r4
;
__mulu:

    mov     r4,r0   ; move operand a to r4
    clr     r0      ; clear result

    when.z  r1      ; early exit when b = 0
    rts

    bra     .check_for_zero

;
; unrolled, two bits per loop
;

.loop

; d0
    when.bs r4,#0
    add     r0,r1

    lsl     r1

; d1
    when.bs r4,#1
    add     r0,r1

    lsl     r1

; shift r4 down two bits
    lsr     r4
    lsr     r4

.check_for_zero
    skip.z  r4      ; loop until remaining bits = 0
    bra     .loop

    rts


;
; signed modulus
;
; entry: 
;   r0 : dividend 
;   r1 : divisor    
;
; exit: 
;   r0 = modulus
;
; uses:
;   r6 : sign houskeeping 
;
__mods:

; copy dividend to R6 for later sign adjustments
    mov     r6,r0  

; convert operands to unsigned
    when.mi r0
    neg     r0 

    when.mi r1
    neg     r1 

; call unsigned divide
    bsr     __divu    


; copy remainder from divide routine into r0
    mov     r0,r1

; fix up result sign as needed
    when.mi r6
    neg     r0 

    rts


;
; unsigned modulus
;
; entry: 
;   r0 : dividend 
;   r1 : divisor    
;
; exit: 
;   r0 = modulus
;
__modu:

; call unsigned divide
    bsr     __divu    

; copy remainder from divide routine into r0
    mov     r0,r1

    rts


;
; signed divide
;
; entry: 
;   r0 : dividend 
;   r1 : divisor    
;
; exit: 
;   r0 = quotient 
;
; uses:
;   r6 : sign houskeeping
;
__divs:

; set MSB of R6 if operand signs are different
    mov     r6,r0  
    xor     r6,r1

; convert operands to unsigned
    when.mi r0
    neg     r0 

    when.mi r1
    neg     r1 

; call unsigned divide
    bsr     __divu    

; fix up result sign as needed
    when.mi r6
    neg     r0 

    rts


;
; unsigned divide ( routine is also called by signed divide and signed/unsigned modulo )
;
; entry: 
;   r0 : dividend 
;   r1 : divisor    
;
; exit: 
;   r0 = quotient 
;   r1 = remainder 
;
; uses:
;   r0 : shifting dividend & quotient
;   r1 : remainder
;   r4 : divisor ( unchanged copy )
;   r5 : loop count
;
__divu:

; test for early exit conditions

    when.z  r0      ; early exit on zero dividend 
    bra     .zero_exit

    when.z  r1      ; early exit on zero divisor 
    bra     .zero_exit

    when.hi r1,r0   ; early exit on divisor > dividend [ note unsigned comparison ]
    bra     .zero_exit

.setup
    mov     r4,r1   ; copy divisor to r4
    clr     r1      ; clear remainder

;
; divide loop [ note 33 iterations ]
;
    mov     r5,#32  ; initialize loop counter ( counts 32 .. 0 )

.loop
    sub.snb r5,#1    
    rts

    lsl     r1      ; shift remainder left

    when.bs r0,#31  ; or in next bit of dividend 
    or      r1,#1

    lsl     r0      ; shift dividend & quotient up to make room for next bit of quotient

    sub.snb r1,r4   ; remainder = remainder - divisor
    bra     .too_big

    bra.d   .loop
    or      r0,#1   ; set quotient LSB

.too_big
    bra.d   .loop
    add     r1,r4   ; restore divisor, quotient LSB is left as a zero


.zero_exit

    mov     r1,r0   ; return original dividend as remainder on early exit

    rts.d
    clr     r0

    end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 