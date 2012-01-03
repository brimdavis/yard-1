;
; RS232 test program
;
;  prints hello message out EVB RS232 port
;
;  serial format set in HW, typically 19200,N,8,1
;

;
; I/O addresses
;
IO_PORT equ $8000_0000      
UART    equ $c000_0000      

;
; program start
;

    org $600

start:
    nop


; load port addresses
    mov  r8,#IO_PORT      
    mov  r9,#UART

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
; send a character using HW UART
;
;   input data in r0
;
;   expects
;     r8 = I/O port address
;     r9 = UART port address
;
;   uses r10
;
send_char:

tx_full:
    ld    r10, (r8)

    skip.bs r10, #7
    bra tx_full

    st.b    r0, (r9)

    rts


;       
; receive a character using HW UART
;
;   returns char in r0
;
;   expects
;     r8 = I/O port address
;     r9 = UART port address
;
;   uses r10
;
get_char:

rx_empty:
    ld  r10, (r8)

    skip.bs r10, #6
    bra rx_empty

    ld    r0, (r9)

    rts

;
; constants
;
HELLO_STR:
    dc.z "Hello, world!"

  end
