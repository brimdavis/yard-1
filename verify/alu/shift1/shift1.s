;
; <shift1.s>
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
; try out the implemented shifts
;
; only 1 bit shift lengths implemented in the core at the moment
;

    org $0

    mov     r1,#$8000_0000
    add     r1,#$f

    asr     r1
    .verify r1,#$c000_0007

    asr     r1
    .verify r1,#$e000_0003

    ror     r1
    .verify r1,#$f000_0001

    rol     r1
    .verify r1,#$e000_0003

    lsr     r1
    .verify r1,#$7000_0001

    lsl     r1
    .verify r1,#$e000_0002

    lsr     r1
    .verify r1,#$7000_0001

    asr     r1, #1
    .verify r1,#$3800_0000

    lsl     r1, #1
    .verify r1,#$7000_0000

    rol     r1
    .verify r1,#$e000_0000

    ror     r1
    .verify r1,#$7000_0000

done:
   bra  done

  end




