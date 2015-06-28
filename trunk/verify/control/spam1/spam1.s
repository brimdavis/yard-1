;
; <spam1.s>
;
;
; (C) COPYRIGHT 2001-2012  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; try out spam instruction
;

   org $0

;
; test AND mode
;

;
; AND, none skipped
;
    mov         r0,#0

    skip.a
    spam.and    #%0000_0000 

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$1248_1248

;
;  AND, some skipped
;
    mov         r1,#0

    skip.a
    spam.and    #%1010_1011 

    or          r1,#$1000_0000
    or          r1,#$0200_0000
    or          r1,#$0040_0000
    or          r1,#$0008_0000

    or          r1,#$0000_1000
    or          r1,#$0000_0200
    or          r1,#$0000_0040
    or          r1,#$0000_0008

    .verify     r1,#$0208_0200

;
;  AND, all skipped
;
    mov         r2,#0

    skip.a
    spam.and    #%1111_1111 

    or          r2,#$1000_0000
    or          r2,#$0200_0000
    or          r2,#$0040_0000
    or          r2,#$0008_0000

    or          r2,#$0000_1000
    or          r2,#$0000_0200
    or          r2,#$0000_0040
    or          r2,#$0000_0008

    .verify     r2,#$0000_0000


;
; test XORN mode
;

;
; XORN, skip always
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_0000,#8

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0000_1248

;
; XORN, skip always, alternating mask, spam length 5
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1010_1010,#5

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0208_0248


;
; XORN, skip never 
;
    mov         r0,#0

    skip.n
    spam.xorn   #%1111_0000,#8

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$1248_0000



;
; XORN, spam length 7
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_1111,#7

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0000_0008


;
; XORN, spam length 6
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_1111,#6

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0000_0048


;
; XORN, spam length 5
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_1111,#5

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0000_0248


;
; XORN, spam length 4
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_1111,#4

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0000_1248


;
; XORN, spam length 3
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_1111,#3

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0008_1248


;
; XORN, spam length 2
;
    mov         r0,#0

    skip.a
    spam.xorn   #%1111_1111,#2

    or          r0,#$1000_0000
    or          r0,#$0200_0000
    or          r0,#$0040_0000
    or          r0,#$0008_0000

    or          r0,#$0000_1000
    or          r0,#$0000_0200
    or          r0,#$0000_0040
    or          r0,#$0000_0008

    .verify     r0,#$0048_1248

    nop

;
done:
    bra  done
    nop

;
; force a verify error
;
error:
    nop
    .verify fail
    bra     done


  end




