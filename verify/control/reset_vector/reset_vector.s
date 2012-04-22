;
; <reset_vector.s>
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
;  check that reset vector is working properly
;  ( first instruction not accidentally nulled when exiting reset state )
;
;

    org $0

    mov r2,#$0000_ffff

;
; need a nop before checking address 0 execution results
;   - execution address parks at zero in simulation during a reset 
;   - verify routine doesn't check reset signal state, treats each cycle as a failed test
;
    nop
    .verify r2,#$0000_ffff

done:
    bra  done


    end




