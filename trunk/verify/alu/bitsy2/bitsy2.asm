;
; bitsy2.asm
;

;
; (C) COPYRIGHT 2011  B. Davis
;
; Code released under the terms of the "new BSD" license
; see license/new_bsd.txt
;

;
; try out the "count bits" instructions
;

    org     $0

; nop first, reset vector isn't working quite right
    nop


;
; cnt1
;
    mov     r0,#$0000_0000
    cnt1    r1,r0
    .verify r1,#0

    mov     r0,#$0000_0001
    cnt1    r1,r0
    .verify r1,#1

    mov     r0,#$8000_0000
    cnt1    r1,r0
    .verify r1,#1

    mov     r0,#$0000_0003
    cnt1    r1,r0
    .verify r1,#2

    mov     r0,#$c000_0000
    cnt1    r1,r0
    .verify r1,#2

    mov     r0,#$0000_0007
    cnt1    r1,r0
    .verify r1,#3

    mov     r0,#$e000_0000
    cnt1    r1,r0
    .verify r1,#3

    mov     r0,#$0000_000f
    cnt1    r1,r0
    .verify r1,#4

    mov     r0,#$f000_0000
    cnt1    r1,r0
    .verify r1,#4

    mov     r0,#$0000_001f
    cnt1    r1,r0
    .verify r1,#5

    mov     r0,#$f800_0000
    cnt1    r1,r0
    .verify r1,#5

    mov     r0,#$0000_003f
    cnt1    r1,r0
    .verify r1,#6

    mov     r0,#$fc00_0000
    cnt1    r1,r0
    .verify r1,#6

    mov     r0,#$0000_007f
    cnt1    r1,r0
    .verify r1,#7

    mov     r0,#$fe00_0000
    cnt1    r1,r0
    .verify r1,#7

    mov     r0,#$0000_00ff
    cnt1    r1,r0
    .verify r1,#8
                     
    mov     r0,#$ff00_0000
    cnt1    r1,r0
    .verify r1,#8
                     
    mov     r0,#$0000_01ff
    cnt1    r1,r0
    .verify r1,#9

    mov     r0,#$ff80_0000
    cnt1    r1,r0
    .verify r1,#9

    mov     r0,#$0000_03ff
    cnt1    r1,r0
    .verify r1,#10

    mov     r0,#$ffc0_0000
    cnt1    r1,r0
    .verify r1,#10

    mov     r0,#$0000_07ff
    cnt1    r1,r0         
    .verify r1,#11

    mov     r0,#$ffe0_0000
    cnt1    r1,r0         
    .verify r1,#11

    mov     r0,#$0000_0fff
    cnt1    r1,r0
    .verify r1,#12

    mov     r0,#$fff0_0000
    cnt1    r1,r0
    .verify r1,#12

    mov     r0,#$0000_1fff
    cnt1    r1,r0
    .verify r1,#13

    mov     r0,#$fff8_0000
    cnt1    r1,r0
    .verify r1,#13

    mov     r0,#$0000_3fff
    cnt1    r1,r0
    .verify r1,#14

    mov     r0,#$fffc_0000
    cnt1    r1,r0
    .verify r1,#14

    mov     r0,#$0000_7fff
    cnt1    r1,r0
    .verify r1,#15

    mov     r0,#$fffe_0000
    cnt1    r1,r0
    .verify r1,#15

    mov     r0,#$0000_ffff
    cnt1    r1,r0
    .verify r1,#16

    mov     r0,#$ffff_0000
    cnt1    r1,r0
    .verify r1,#16

    mov     r0,#$0001_ffff
    cnt1    r1,r0
    .verify r1,#17

    mov     r0,#$ffff_8000
    cnt1    r1,r0
    .verify r1,#17

    mov     r0,#$0003_ffff
    cnt1    r1,r0
    .verify r1,#18

    mov     r0,#$ffff_c000
    cnt1    r1,r0
    .verify r1,#18

    mov     r0,#$0007_ffff
    cnt1    r1,r0
    .verify r1,#19

    mov     r0,#$ffff_e000
    cnt1    r1,r0
    .verify r1,#19

    mov     r0,#$000f_ffff
    cnt1    r1,r0
    .verify r1,#20

    mov     r0,#$ffff_f000
    cnt1    r1,r0
    .verify r1,#20

    mov     r0,#$001f_ffff
    cnt1    r1,r0
    .verify r1,#21

    mov     r0,#$ffff_f800
    cnt1    r1,r0
    .verify r1,#21

    mov     r0,#$003f_ffff
    cnt1    r1,r0
    .verify r1,#22

    mov     r0,#$ffff_fc00
    cnt1    r1,r0
    .verify r1,#22

    mov     r0,#$007f_ffff
    cnt1    r1,r0
    .verify r1,#23

    mov     r0,#$ffff_fe00
    cnt1    r1,r0
    .verify r1,#23

    mov     r0,#$00ff_ffff
    cnt1    r1,r0
    .verify r1,#24

    mov     r0,#$ffff_ff00
    cnt1    r1,r0
    .verify r1,#24

    mov     r0,#$01ff_ffff
    cnt1    r1,r0
    .verify r1,#25
                      
    mov     r0,#$ffff_ff80
    cnt1    r1,r0
    .verify r1,#25
                      
    mov     r0,#$03ff_ffff
    cnt1    r1,r0
    .verify r1,#26

    mov     r0,#$ffff_ffc0
    cnt1    r1,r0
    .verify r1,#26

    mov     r0,#$07ff_ffff
    cnt1    r1,r0
    .verify r1,#27

    mov     r0,#$ffff_ffe0
    cnt1    r1,r0
    .verify r1,#27

    mov     r0,#$0fff_ffff
    cnt1    r1,r0             
    .verify r1,#28

    mov     r0,#$ffff_fff0
    cnt1    r1,r0             
    .verify r1,#28

    mov     r0,#$1fff_ffff
    cnt1    r1,r0
    .verify r1,#29
                      
    mov     r0,#$ffff_fff8
    cnt1    r1,r0
    .verify r1,#29
                      
    mov     r0,#$3fff_ffff
    cnt1    r1,r0
    .verify r1,#30

    mov     r0,#$ffff_fffc
    cnt1    r1,r0
    .verify r1,#30

    mov     r0,#$7fff_ffff
    cnt1    r1,r0
    .verify r1,#31

    mov     r0,#$ffff_fffe
    cnt1    r1,r0
    .verify r1,#31

    mov     r0,#$ffff_ffff
    cnt1    r1,r0
    .verify r1,#32



done:
   bra  done

  end




