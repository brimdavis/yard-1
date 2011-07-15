;
; RS232 test program
;
;  prints hello message out EVB RS232 port
;
;  serial format: 19200,N,8,1

;
; program start
;
    org $600

start:
    nop


; r8 = I/O port address
    mov r8,#$8000_0000      

;
; print test string
;
    imm12   #HELLO_STR
    mov     r1,imm

    bsr pstr
    bsr crlf


echo:
    bsr get_char
    bsr send_char
    bra echo

stop:
    bra stop



;
; print string pointed at by r1
;
;   uses r0

pstr:
    ld.ub   r0,(r1)

    skip.nz r0
    rts

    bsr send_char

    bra.d   pstr
    add r1,#1

;
;
;
crlf:
    mov r0, #$0d     ;CR
    bsr send_char

    mov r0, #$0a     ;LF
    bsr send_char

    rts

;       
; send a character in R0 using HW UART
; clobbers r0
; expects port address in r8
; uses r9,r10
;
send_char:
    mov  r9, #$4000_0000  ; uart decode address

tx_full:
    ld.l    r10, (r8)

    skip.bc r10, #7
    bra tx_full

    st.b    r0, (r9)

    rts

;       
; receive a character in R0 using HW UART
; returns char in r0
; expects I/O port address in r8
; uses r9,r10
;
get_char:
    mov   r9, #$4000_0000  ; uart decode address

rx_empty:
    ld.l  r10, (r8)

    skip.bs r10, #6
    bra rx_empty

    ld.l    r0, (r9)

    rts

;
; constants
;
HELLO_STR:
    dc.z "Hello, world!"

  end
