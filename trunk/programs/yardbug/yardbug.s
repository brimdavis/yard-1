;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YARDBUG serial debugger 0.2
;
; (C) COPYRIGHT 2001-2012  B. Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  RS232 data format: 19200,N,8,1
;  ( RS232 format is set in evb.vhd, not controlled by S/W yet )
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;commands:
;
;   D  ADDR COUNT        Dump memory
;
;   G  ADDR              Go
;
;   M  ADDR BYTE {BYTE}  Modify byte(s)
;
;   ?                    help
;
;  e.g.:
;    D 0 100        ; dump 256 bytes starting at zero
;    G 0            ; jump to address 0
;    M 600 00       ; byte at $600 = 0
;    M 601 ff ee    ; byte at $601 = $ff, $602 = $ee
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Quirks:
;
;   - parses input on the fly, no line editing:
;
;      - no way to escape out of command in progress
;
;      - no way to backspace 
;        ( uses last 8/2 hex chars. entered for quad/byte input, 
;         so you can type some zeroes followed by the proper
;         value to correct an error)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; I/O addresses
;
UART    equ $c000_0000      

;
; Input Flag bit assignments
;
FLAG_TX_RDY     equ 15
FLAG_RX_AVAIL   equ 14


;
; register usage:
;
;   r0 = local, parameter, return value
;   r1 = local, 2nd return value
;   r2 = unused
;   r3 = local
;   r4 = local
;   r5 = unused
;   r6 = unused
;   r7 = unused ( old command search local )
;   r8 = unused
;   r9 = global, UART port address
;   r10= local
;   r11= local 
;   r12= local (mem address)
;   r13= local (mem loop count)
;   r14= IMM, locals, address parameter
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
; program start
;
;   $0 for embedded boot "ROM"
;
;   after code squish for ROM space, debugger must live in the first 
;   256 bytes of memory for the compact command table dispatch to work
;
    org     $0

start:

; UART addresses
    mov     r9, #UART    


; print the help message
    bsr     cmd_help

;
; main loop
;
parse_loop:
    bsr     send_crlf

    mov     r0, #'@     ; @ or ? for prompt fits into short immediate encoding
    bsr     send_char

; get a character & echo it
    bsr     get_char_echo

;
; convert any alpha char. a-z to upper case A-Z
;  ( this code also clobbers some punctuation chars )
;
    skip.bc r0, #6           ; D6 is set for all ASCII letters
    and     r0, #$FFFF_FFDF  ; clear D5 : $60-7f -> $40-5f


;
; future - add backspace check here, bra back to get another command character
;

;
; check character in r0 against the command list
;   byte-wide pointer version of table search, 
;   target routine must be in low 256 bytes of memory
;

    imm12   #CMD_LNK    ; r13 = address of command entry point table
    mov     r13, r14

    imm12   #CMD_TAB    ; r14 = address of command character lookup table

match_loop:
    ld.ub   r11, (r14)  ; r11 = next table command byte

    inc     r14         ; bump r14 to next entry

    skip.nz r11         ; bail out if at end of table
    bra     parse_loop

    skip.ne r0,r11      ; check for match
    bra     got_it

    add     r13,#1      ; increment byte address pointer
    bra     match_loop

got_it:
    ld.ub    r11, (r13)     ; r11 = command subroutine address

    bsr     get_char_echo   ; get & echo one character after command letter

    jsr     (r11)           ; call selected command 

    bra parse_loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; dump memory
;
cmd_dump:

; get the start address into R12
    bsr     ghex
    mov     r12, r1

; if user entry was terminated with a space, read byte count; else dump 16 bytes
    mov     r1,#16      ; load default count

    skip.nz  r0         ; check return code of last ghex call ( r0=0 for a space )
    bsr     ghex        ; get user byte count  

    dec     r1          ; decrement byte count ( loop counter counts N-1..0 )

    mov     r13, r1             ; r13 = byte count
    and     r13, #$0000_1fff    ; limit loop iterations to 8K-1

next_line:
    mov     r0, r12     ; print address
    bsr     phex32

    mov     r11,#16     ; load line byte counter

dump_loop:
    bsr     space

    ld.ub   r0, (r12)   ; read next memory byte
    bsr     phex8

    inc     r12         ; increment memory pointer

    sub.snb r13,#1      ; decrement byte count, check for borrow
    bra     send_crlf   ; bail out if negative ( bra so send_crlf returns to main )

    dec     r11         ; decrement line byte counter

    skip.z  r11
    bra     dump_loop   

    bsr     send_crlf   ; end of line

    bra     next_line


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; help 
;
cmd_help:

;
; note, CRLF string and list of commands immediately follow 
; the banner string, so two calls to pstr will print all three
;
    imm12   #STR_BANNER
    bsr     pstr        ; print initial banner
    bra     pstr        ; print CRLF & commands, tail return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; modify memory
;
cmd_modify:

; get the address into R4
    bsr     ghex
    mov     r4, r1

next_byte:

; get the data byte
    bsr     ghex

; write it
    st.b    r1, (r4)
    inc     r4

; check returned ghex terminator value to see if we're done 
    skip.nz  r0
    bra     next_byte   ; zero -> space, so go get another byte

    rts                 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; go
;
cmd_go:
    bsr     ghex    ; r1 = target address 
    jmp     (r1)    ; jump to user program 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; utility routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; ghex:
;   read hex value from user, 
;   
;   reads as many chars as are entered, shifting result up 4 bits for each, 
;   until it sees a space or control character
;   
;   returns:
;     r0 = terminating char. - $20  (e.g., r0 = 0 if terminator was a space )
;     r1 = value of hex entry 
;   
ghex:

; initialize working value in r1
    mov r1,#0

gloop:
    bsr     get_char_echo

; bail out on a space or other ctl. char
    sub       r0, #$20
    skip.gtz  r0
    rts

;
; convert ASCII code  -> hex ( with liberties taken for illegal chars )
;
; before & after subtract of $20:
;   $30:$39 ( '0':'9' )  now is $10:19
;   $41:$46 ( 'A':'F' )  now is $21:26
;   $61:$66 ( 'a':'f' )  now is $41:46
;
    skip.bs r0, #4  ; if D4 is set, assume it's a numeral 0-9
    add     r0, #9  ; else convert 'a|A'-'f|F' -> $a-$f in LS nybble

    and     r0, #$0f ; keep only the 4 LSB's

; shift last value up 4 bits
    bsr     rol_r1_four
    and     r1, #$ffff_fff0   ; clear out the 4 LSB's from rotate

; or in new nybble
    or      r1, r0

    bra     gloop

;
; print 8/16/32 bit hex value in r0
;
phex8:
    imm12   #8          ; # bits       
    bra     phex

;
; phex16 not currently needed, commented out to save ROM space
;
;phex16:
;    imm12   #16         
;    bra     phex

phex32:
    imm12   #32         ; # bits

phex:
    mov     r1,r0       ; copy input value to R1

    mov     r3,r14      ; copy length to R3 = bit counter

    rsub    r14,#32     ; initial rotate of r0 by 32-N bits left to move desired field into MS nybble
    bsr     rol_r1_imm  

hloop:
    bsr     rol_r1_four ; rotate MS nybble into the LS nybble

    mov     r0, r1      ; copy to r0 and mask 
    and     r0, #$0f

; hex to ASCII conversion
    sub     r0, #9

    skip.gtz   r0
    sub     r0, #7

    add     r0, #$40

    bsr     send_char   ; print character

    sub     r3,#4       ; decrement bit count

    skip.lez  r3
    bra     hloop

    rts

;
; rol_r1_imm
;   rotate r1 imm positions left
;
; rol_r1_four
;   alternate entry point, rotate r1 four positions left
;
;
rol_r1_four
    imm12   #4

rol_r1_imm
    sub.snb r14,#1          ; decrement shift count
    rts                     ; bail out if done

    bra.d   rol_r1_imm      ; loop back (delayed)
    rol     r1              ; rotate one bit left 

;
; print null terminated string 
;
;   r14 = address of string
;
;   uses r0
;

; alternate entry point prints CRLF string
send_crlf:
    imm12   #STR_CRLF

pstr:
    ld.ub  r0,(r14)     ; get next byte of string
    inc    r14          ; bump pointer to next character

    skip.nz r0          ; bail out if zero terminator
    rts

    bsr  send_char      ; send character

    bra  pstr           ; loop


;       
; send a character using HW UART
;
;   input data in r0
;
;   expects
;     r9 = UART port address
;

; send a space, falls through to send_char
space:
    mov     r0, #$20        

send_char:

; loop until transmitter ready flag = 1
tx_wait:
    skip.fs #FLAG_TX_RDY
    bra     tx_wait

    st      r0, (r9)    ; write data to TX
    rts

;
; version of get_char with echo of input character
;
;  also handles CRLF expansion
;  note funky return value (0) for a CR
;
get_char_echo:
    bsr get_char

    mov     r10,#$0d    

    skip.ne r10,r0      ; if CR echo both CR & LF
    bra     send_crlf   ; note that send_crlf will return r0=0 to the caller in place of CR

                        ; else echo the original character
    bra     send_char   ; bra instead of bsr & rts saves an instruction (ROM space)


;       
; receive a character using HW UART
;
;   returns char in r0
;
;   expects
;     r9 = UART port address
;
get_char:

; loop until there's something in the buffer
rx_empty:
    skip.fs #FLAG_RX_AVAIL
    bra     rx_empty

    ld      r0, (r9)    ; read data from RX
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; constant tables
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; constant message strings
;
; note, cmd_help currently requires STR_BANNER, STR_CRLF, and CMD_TAB to 
; immediately follow one another so calls to pstr print each in turn
;
STR_BANNER: 
    dc.s    "YARDBUG 0.2"

STR_CRLF:
    dc.b    $0d,$0a,$00

;
; commmand table
;
; notes:
;
;   - entries in table should be uppercase letters (A-Z), or punctuation chars < ASCII code $60 
;
;   - one-byte table addresses limit calls to routines located in first 256 locations of memory
;
CMD_TAB:
    dc.s    "DGM?"
    dc.b    0               ; end of table marker


;     align   4             ; align not needed for byte-wide pointer table

CMD_LNK:
    dc.b    cmd_dump
    dc.b    cmd_go
    dc.b    cmd_modify
    dc.b    cmd_help

    dc.b    0              ; end of table marker




; ;
; ; shorter help message (save ROM space)
; ;
; STR_HELP: 
;     dc.s    "YARDBUG 0.02"
;     dc.b    $0d,$0a
; 
;     dc.s    "D a #|G a|M a b {b}|?"
; 
; STR_CRLF:
;     dc.b    $0d,$0a
;     dc.b    0
; 

; original (longer) help message
; 
; ;
; ;
; ;
; STR_HELP: 
;     dc.s "YARDBUG 0.02"
;     dc.b    $0d,$0a
;     dc.s    " D addr cnt"
;     dc.b    $0d,$0a
;     dc.s    " G addr"
;     dc.b    $0d,$0a
;     dc.s    " M addr byte {byte}"
;     dc.b    $0d,$0a
;     dc.s    " ?"
; STR_CRLF: 
;     dc.b    $0d,$0a
;     dc.b    0
; 


  end


;
; original command table replaced with byte-wide pointer version to save ROM space
;
;   - full 32 bit target addresses
;   - separate command and pointer tables
;
; ;
; ; commmand table
; ;
; ;   entries in table should be uppercase letters (A-Z), or punctuation chars < ASCII code $60 
; ;
; CMD_TAB:
;     dc.s    "DGM?"
;     dc.b    0               ; end of table marker
; 
;     align   4
; 
; CMD_LNK:
;     dc.l    cmd_dump
;     dc.l    cmd_go
;     dc.l    cmd_modify
;     dc.l    cmd_help
; 
