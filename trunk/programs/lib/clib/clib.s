;
; beginnings of a C support library for lcc port
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
; unsigned divide
;
; entry: 
;   r0 : dividend 
;   r1 : divisor    
;
; exit: 
;   r0 = quotient 
;
; uses:
;   r0 : shifting dividend & quotient
;   r1 : divisor ( unchanged )
;   r4 : remainder
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
    clr     r4      ; clear remainder

;
; divide loop [ note 33 iterations ]
;
    mov     r5,#32  ; initialize loop counter ( counts 32 .. 0 )

.loop
    sub.snb r5,#1    
    rts

    lsl     r4      ; shift remainder left

    when.bs r0,#31  ; or in next bit of dividend 
    or      r4,#1

    lsl     r0      ; shift dividend & quotient up to make room for next bit of quotient

    sub.snb r4,r1   ; remainder = remainder - divisor
    bra     .too_big

    bra.d   .loop
    or      r0,#1   ; set quotient LSB

.too_big
    bra.d   .loop
    add     r4,r1   ; restore divisor, quotient LSB is left as a zero


.zero_exit

    rts.d
    clr     r0

    end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 