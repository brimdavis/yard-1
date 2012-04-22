;
; <bitsy1.s>
;

;
; (C) COPYRIGHT 2001-2011  Brian Davis
;
; Code released under the terms of the BSD 2-clause license
; see license/bsd_2-clause.txt
;

;
; test ff1 (find first 1)
;

    org     $0

;
; try out ff1 with single bit set
;
    mov     r0,#$8000_0000
    ff1     r1,r0
    .verify r1,#31

    lsr     r0
    ff1     r1,r0
    .verify r1,#30

    lsr     r0
    ff1     r1,r0
    .verify r1,#29

    lsr     r0
    ff1     r1,r0
    .verify r1,#28

    lsr     r0
    ff1     r1,r0
    .verify r1,#27

    lsr     r0
    ff1     r1,r0
    .verify r1,#26

    lsr     r0
    ff1     r1,r0
    .verify r1,#25

    lsr     r0
    ff1     r1,r0
    .verify r1,#24

    lsr     r0
    ff1     r1,r0
    .verify r1,#23
                     
    lsr     r0
    ff1     r1,r0
    .verify r1,#22

    lsr     r0
    ff1     r1,r0
    .verify r1,#21

    lsr     r0
    ff1     r1,r0
    .verify r1,#20

    lsr     r0
    ff1     r1,r0
    .verify r1,#19

    lsr     r0
    ff1     r1,r0
    .verify r1,#18

    lsr     r0
    ff1     r1,r0
    .verify r1,#17

    lsr     r0
    ff1     r1,r0
    .verify r1,#16

    lsr     r0
    ff1     r1,r0
    .verify r1,#15

    lsr     r0
    ff1     r1,r0
    .verify r1,#14

    lsr     r0
    ff1     r1,r0
    .verify r1,#13

    lsr     r0
    ff1     r1,r0
    .verify r1,#12

    lsr     r0
    ff1     r1,r0
    .verify r1,#11

    lsr     r0
    ff1     r1,r0
    .verify r1,#10

    lsr     r0
    ff1     r1,r0
    .verify r1,#9 

    lsr     r0
    ff1     r1,r0
    .verify r1,#8 

    lsr     r0
    ff1     r1,r0
    .verify r1,#7 

    lsr     r0
    ff1     r1,r0
    .verify r1,#6 
                      
    lsr     r0
    ff1     r1,r0
    .verify r1,#5 

    lsr     r0
    ff1     r1,r0
    .verify r1,#4 

    lsr     r0
    ff1     r1,r0
    .verify r1,#3 

    lsr     r0
    ff1     r1,r0
    .verify r1,#2 
                      
    lsr     r0
    ff1     r1,r0
    .verify r1,#1 

    lsr     r0
    ff1     r1,r0
    .verify r1,#0 

;
; try out ff1 with multiple bits set
;
    mov     r0,#$ffff_ffff
    ff1     r1,r0
    .verify r1,#31

    lsr     r0
    ff1     r1,r0
    .verify r1,#30

    lsr     r0
    ff1     r1,r0
    .verify r1,#29

    lsr     r0
    ff1     r1,r0
    .verify r1,#28

    lsr     r0
    ff1     r1,r0
    .verify r1,#27

    lsr     r0
    ff1     r1,r0
    .verify r1,#26

    lsr     r0
    ff1     r1,r0
    .verify r1,#25

    lsr     r0
    ff1     r1,r0
    .verify r1,#24

    lsr     r0
    ff1     r1,r0
    .verify r1,#23
                     
    lsr     r0
    ff1     r1,r0
    .verify r1,#22

    lsr     r0
    ff1     r1,r0
    .verify r1,#21

    lsr     r0
    ff1     r1,r0
    .verify r1,#20

    lsr     r0
    ff1     r1,r0
    .verify r1,#19

    lsr     r0
    ff1     r1,r0
    .verify r1,#18

    lsr     r0
    ff1     r1,r0
    .verify r1,#17

    lsr     r0
    ff1     r1,r0
    .verify r1,#16

    lsr     r0
    ff1     r1,r0
    .verify r1,#15

    lsr     r0
    ff1     r1,r0
    .verify r1,#14

    lsr     r0
    ff1     r1,r0
    .verify r1,#13

    lsr     r0
    ff1     r1,r0
    .verify r1,#12

    lsr     r0
    ff1     r1,r0
    .verify r1,#11

    lsr     r0
    ff1     r1,r0
    .verify r1,#10

    lsr     r0
    ff1     r1,r0
    .verify r1,#9 

    lsr     r0
    ff1     r1,r0
    .verify r1,#8 

    lsr     r0
    ff1     r1,r0
    .verify r1,#7 

    lsr     r0
    ff1     r1,r0
    .verify r1,#6 
                      
    lsr     r0
    ff1     r1,r0
    .verify r1,#5 

    lsr     r0
    ff1     r1,r0
    .verify r1,#4 

    lsr     r0
    ff1     r1,r0
    .verify r1,#3 

    lsr     r0
    ff1     r1,r0
    .verify r1,#2 
                      
    lsr     r0
    ff1     r1,r0
    .verify r1,#1 

    lsr     r0
    ff1     r1,r0
    .verify r1,#0 

;
; no bits set
;
    mov     r0,#0
    ff1     r1,r0
    .verify r1,#$ffff_ffff


done:
    bra     done

    end




