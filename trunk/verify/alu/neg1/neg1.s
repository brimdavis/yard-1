;
; <neg1.s>
;

;
; (C) COPYRIGHT 2001-2011  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; YARD-1 test program
;
; test negate
;
; ( which is now just an alias for "rsub ra,#0" ; move test elsewhere ??? )
;

    org $0

; nop first, reset vector isn't working quite right
    nop


;
; try out negate
;
    mov     r0,#$0
    neg     r0
    .verify r0,#$0000_0000

    mov     r0,#$1
    neg     r0
    .verify r0,#$ffff_ffff

    mov     r0,#$2
    neg     r0
    .verify r0,#$ffff_fffe

    mov     r0,#$7FFF_FFFF
    dec     r0
    neg     r0
    .verify r0,#$8000_0002

    mov     r0,#$7FFF_FFFF
    neg     r0
    .verify r0,#$8000_0001

    mov     r0,#$FFFF_FFFF
    neg     r0
    .verify r0,#$0000_0001

    mov     r0,#$FFFF_FFFE
    neg     r0
    .verify r0,#$0000_0002

    mov     r0,#$8000_0000
    inc     r0
    neg     r0
    .verify r0,#$7fff_ffff

    mov     r0,#$8000_0000
    neg     r0
    .verify r0,#$8000_0000



done:
   bra  done

  end




