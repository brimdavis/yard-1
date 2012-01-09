;
; <skip5.s>
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
; test miscellaneous skips
;
;   byte|wyde zero|minus     
;

        org $0

; nop first, reset vector isn't working quite right
        nop


:
;    'skip.awz'  =>  "SKIP Any Wyde Zero" 
;    'skip.nwz'  =>  "SKIP No Wyde Zero"  
;

        mov         r1,#$0000_0000

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_ffff

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_0001

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_0000

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0001_0000

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_ffff

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0001_0000
        or          r1,#$0000_0001  ; => $0001_0001

        mov         r0,#1
        skip.awz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nwz    r1
        mov         r0,#0
        nop
        .verify     r0,#1


;
;    'skip.awm'  =>  "SKIP Any Wyde Minus"
;    'skip.nwm'  =>  "SKIP No Wyde Minus"
;

        mov         r1,#$0000_0000

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r1,#$0000_7fff

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$ffff_0000
        and         r1,#$7fff_ffff      ; => 7fff_0000

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0000_ffff

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_0000

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_ffff

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_8000

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$8000_0000

        mov         r0,#1
        skip.awm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nwm    r1
        mov         r0,#0
        nop
        .verify     r0,#0


;
;    'skip.abz'  =>  "SKIP Any Byte Zero"
;    'skip.nbz'  =>  "SKIP No Byte Zero" 
;

        mov         r1,#$0000_0000

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_00ff

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_ffff

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$00ff_ffff

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ff00_0000

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_0000

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_ff00

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_ffff

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0100_0000
        or          r1,#$0001_0000
        or          r1,#$0000_0100
        or          r1,#$0000_0001  ; => $0101_0101

        mov         r0,#1
        skip.abz    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbz    r1
        mov         r0,#0
        nop
        .verify     r0,#1


;
;    'skip.abm'  =>  "SKIP Any Byte Minus"
;    'skip.nbm'  =>  "SKIP No Byte Minus" 
;
        mov         r1,#$0000_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0000_0001

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0000_0100

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0001_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0100_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0000_007f

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$ffff_ff00
        and         r1,#$0000_7fff      ; => 0000_7f00

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$ffff_0000
        and         r1,#$007f_ffff      ; => 007f_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$ff00_0000
        and         r1,#$7fff_ffff      ; => 7f00_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

;
        mov         r1,#$0000_00ff

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0
;
        mov         r1,#$0000_ffff

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$00ff_ffff

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$ffff_ffff

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_0080

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0000_8000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$0080_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0

;
        mov         r1,#$8000_0000

        mov         r0,#1
        skip.abm    r1
        mov         r0,#0
        nop
        .verify     r0,#1

        mov         r0,#1
        skip.nbm    r1
        mov         r0,#0
        nop
        .verify     r0,#0



;
done:
        bra  done

  end




