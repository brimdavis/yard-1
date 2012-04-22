;
; <logic1.s>
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
; try out logicals
;

    org $0

    mov     r0,#$0000_0000
    mov     r1,#$0000_ffff

; reg/reg

    mov     r2,r1
    .verify r2,#$0000_ffff

    mov.not r2,r1
    .verify r2,#$ffff_0000

    or      r0,r1
    .verify r0,#$0000_ffff

    or.not  r0,r1
    .verify r0,#$ffff_ffff

    and     r0,r1
    .verify r0,#$0000_ffff

    and.not r0,r1
    .verify r0,#$0000_0000

    xor     r0,r1
    .verify r0,#$0000_ffff

    xor.not r0,r1
    .verify r0,#$ffff_ffff

    xor     r0,r1
    .verify r0,#$ffff_0000

    xor.not r0,r1
    .verify r0,#$0000_0000

; reg/const

        or  r0,#$7fff_ffff
    .verify r0,#$7fff_ffff

        xor r0,#$ffff_0000
    .verify r0,#$8000_ffff


    and.not r0,#$8000_0000
    .verify r0,#$0000_ffff

    or      r0,#$0001_0000
    .verify r0,#$0001_ffff

    and.not r0,#$0000_00ff
    .verify r0,#$0001_ff00


done:
    bra     done

  end




