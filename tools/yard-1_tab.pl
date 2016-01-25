#-------------------------------------------------------------------------------
#
# yard-1_tab.pl
#
# define YARD-1 opcode & constant tables 
#
#  this file is incorporated into yas.pl with a "require" 
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# Copyright (c) 2000-2014, B. Davis
#
# released under the BSD 2-clause license, see license/bsd_2-clause.txt
#
#-------------------------------------------------------------------------------



#use strict;

#---------------------------------------
# Hash for register name encodings
#----------------------------------------

#
# note special case for pc/rs, reads rs when used as data field
#
%data_reg_map = 
  (
    "r0"  => "0000",
    "r1"  => "0001", 
    "r2"  => "0010", 
    "r3"  => "0011", 
    "r4"  => "0100", 
    "r5"  => "0101", 
    "r6"  => "0110", 
    "r7"  => "0111",
    "r8"  => "1000",
    "r9"  => "1001",
    "r10" => "1010",
    "r11" => "1011",

    "r12" => "1100",
    "fp"  => "1100",

    "r13" => "1101",
    "sp"  => "1101",

    "r14" => "1110",
    "imm" => "1110",

    "r15" => "1111",
    "rs"  => "1111"
  );

#
# note special case for pc/rs, reads pc when used as address base register
#
%addr_reg_map = 
  (
    "r0"  => "0000",
    "r1"  => "0001",
    "r2"  => "0010", 
    "r3"  => "0011", 
    "r4"  => "0100",
    "r5"  => "0101",
    "r6"  => "0110",
    "r7"  => "0111",
    "r8"  => "1000",
    "r9"  => "1001",
    "r10" => "1010",
    "r11" => "1011",

    "r12" => "1100",
    "fp"  => "1100",

    "r13" => "1101",
    "sp"  => "1101",

    "r14" => "1110",
    "imm" => "1110",

    "r15" => "1111",
    "pc"  => "1111"
  );

#
# registers that allow short offset stack addressing modes
#
%stack_reg_map = 
  (
    "r12" => "1100", 
    "fp"  => "1100", 

    "r13" => "1101", 
    "sp"  => "1101"
  );


#
# control registers 
#
%ctl_reg_map = ();


#-------------------------------------------------------------------------------
# Immediate constant encodings
#   "NOT" variants are handled in opcode switch routine
# 
# switched to hex string keys to avoid 2^32 weirdness of
# perl hex program literals vs. hex/oct function return values
#
# e.g. 
#   original code :  $imm5 = $imm5_encode{$off};
#   stringy code  :  $imm5 = $imm5_encode{sprintf("%08lx",$off)};
#
# constant fields are of the form "ttbbbbb", where:
#
#   tt is constant type : 
#      00  register (not used here)
#      01  5 bit signed 
#      10  2^B
#      11  (2^B) - 1
#
#   bbbbb is constant field
#
#-------------------------------------------------------------------------------

my %imm5_encode = (

  # 2^B
  "00000001" => "1000000",    #           1
  "00000002" => "1000001",    #           2
  "00000004" => "1000010",    #           4
  "00000008" => "1000011",    #           8
  "00000010" => "1000100",    #          16
  "00000020" => "1000101",    #          32
  "00000040" => "1000110",    #          64
  "00000080" => "1000111",    #         128
  "00000100" => "1001000",    #         256
  "00000200" => "1001001",    #         512
  "00000400" => "1001010",    #        1024
  "00000800" => "1001011",    #        2048
  "00001000" => "1001100",    #        4096
  "00002000" => "1001101",    #        8192
  "00004000" => "1001110",    #       16384
  "00008000" => "1001111",    #       32768
  "00010000" => "1010000",    #       65536
  "00020000" => "1010001",    #      131072
  "00040000" => "1010010",    #      262144
  "00080000" => "1010011",    #      524288 
  "00100000" => "1010100",    #     1048576
  "00200000" => "1010101",    #     2097152
  "00400000" => "1010110",    #     4194304
  "00800000" => "1010111",    #     8388608
  "01000000" => "1011000",    #    16777216
  "02000000" => "1011001",    #    33554432
  "04000000" => "1011010",    #    67108864
  "08000000" => "1011011",    #   134217728
  "10000000" => "1011100",    #   268435456
  "20000000" => "1011101",    #   536870912
  "40000000" => "1011110",    #  1073741824
  "80000000" => "1011111",    #  2147483648

  # 2^B - 1
  "00000000" => "1100000",
  "00000001" => "1100001",
  "00000003" => "1100010",
  "00000007" => "1100011",
  "0000000f" => "1100100",
  "0000001f" => "1100101",
  "0000003f" => "1100110",
  "0000007f" => "1100111",
  "000000ff" => "1101000",
  "000001ff" => "1101001",
  "000003ff" => "1101010",
  "000007ff" => "1101011",
  "00000fff" => "1101100",
  "00001fff" => "1101101",
  "00003fff" => "1101110",
  "00007fff" => "1101111",
  "0000ffff" => "1110000",
  "0001ffff" => "1110001",
  "0003ffff" => "1110010",
  "0007ffff" => "1110011",
  "000fffff" => "1110100",
  "001fffff" => "1110101",
  "003fffff" => "1110110",
  "007fffff" => "1110111",
  "00ffffff" => "1111000",
  "01ffffff" => "1111001",
  "03ffffff" => "1111010",
  "07ffffff" => "1111011",
  "0fffffff" => "1111100",
  "1fffffff" => "1111101",
  "3fffffff" => "1111110",
  "7fffffff" => "1111111",

  # 5 bit sign extended
  "fffffff0" => "0110000",    # -16   0xfffffff0 
  "fffffff1" => "0110001",    # -15   0xfffffff1 
  "fffffff2" => "0110010",    # -14   0xfffffff2 
  "fffffff3" => "0110011",    # -13   0xfffffff3 
  "fffffff4" => "0110100",    # -12   0xfffffff4 
  "fffffff5" => "0110101",    # -11   0xfffffff5 
  "fffffff6" => "0110110",    # -10   0xfffffff6 
  "fffffff7" => "0110111",    #  -9   0xfffffff7 
  "fffffff8" => "0111000",    #  -8   0xfffffff8 
  "fffffff9" => "0111001",    #  -7   0xfffffff9 
  "fffffffa" => "0111010",    #  -6   0xfffffffa 
  "fffffffb" => "0111011",    #  -5   0xfffffffb 
  "fffffffc" => "0111100",    #  -4   0xfffffffc 
  "fffffffd" => "0111101",    #  -3   0xfffffffd 
  "fffffffe" => "0111110",    #  -2   0xfffffffe 
  "ffffffff" => "0111111",    #  -1   0xffffffff 
  "00000000" => "0100000",    #   0
  "00000001" => "0100001",    #   1
  "00000002" => "0100010",    #   2
  "00000003" => "0100011",    #   3
  "00000004" => "0100100",    #   4
  "00000005" => "0100101",    #   5
  "00000006" => "0100110",    #   6
  "00000007" => "0100111",    #   7
  "00000008" => "0101000",    #   8
  "00000009" => "0101001",    #   9
  "0000000a" => "0101010",    #  10
  "0000000b" => "0101011",    #  11
  "0000000c" => "0101100",    #  12
  "0000000d" => "0101101",    #  13
  "0000000e" => "0101110",    #  14
  "0000000f" => "0101111"     #  15

  );

#
# field stuffing subroutine
#
#   given opcode string of "1101011bbbbbaaaa", the following call 
#   replaces opcode 'b' field with the bit string in $bitnum :
#
#     $opcode = stuff_op_field( $opcode, 'b', $bit_num);
#
#   note that field letters in opcode string need to be contiguous
#
sub stuff_op_field
  {
    my ( $opcode ) = shift;
    my ( $field  ) = shift;
    my ( $value  ) = shift;

    my $left;
    my $right;
    my $field_length;

    $left  =  index( $opcode, $field);
    $right = rindex( $opcode, $field);

    $field_length = $right - $left + 1;

    if (D1) { printf $JNK_F ("stuff_op_field : opcode %s  field %s  value %s\n",  $opcode, $field, $value  ); }
    if (D1) { printf $JNK_F ("stuff_op_field : left %d   right %d   length %d\n",  $left, $right, $field_length  ); }

    if ( length($value) > $field_length  ) 
     {
       do_error("Internal error - opcode field overflow in stuff_op_field");
     }

    substr( $opcode, $left, $field_length ) = $value;

    if (D1) { printf $JNK_F ("stuff_op_field : result %s\n",  $opcode ); }

    return $opcode;
  }


#
# start with empty opcode HOH
#
%ops = ();


#--------------------------------
# L_R_RI: OP  Ra , Rb | CONST
#
#   logical ops: mov, and, or, xor
#   (checks for NOT opb constant match)
#
#--------------------------------
%ops_lrri = 
  (
    'mov'     =>  { type =>  'L_R_RI', opc => '00000ttbbbbbaaaa' , ps => \&ps_lrri, name => "MOVe"             },
    'mov.not' =>  { type =>  'L_R_RI', opc => '00001ttbbbbbaaaa' , ps => \&ps_lrri, name => "MOVe NOT"         }, 

    'and'     =>  { type =>  'L_R_RI', opc => '00010ttbbbbbaaaa' , ps => \&ps_lrri, name => "AND"              },
    'and.not' =>  { type =>  'L_R_RI', opc => '00011ttbbbbbaaaa' , ps => \&ps_lrri, name => "AND NOT"          }, 

    'or'      =>  { type =>  'L_R_RI', opc => '00100ttbbbbbaaaa' , ps => \&ps_lrri, name => "OR"               },
    'or.not'  =>  { type =>  'L_R_RI', opc => '00101ttbbbbbaaaa' , ps => \&ps_lrri, name => "OR NOT"           },  

    'xor'     =>  { type =>  'L_R_RI', opc => '00110ttbbbbbaaaa' , ps => \&ps_lrri, name => "eXclusive OR"     },
    'xor.not' =>  { type =>  'L_R_RI', opc => '00111ttbbbbbaaaa' , ps => \&ps_lrri, name => "eXclusive OR NOT" }  
  );

# add to HOH opcode table
@ops{keys %ops_lrri} = values %ops_lrri;

# LRRI parser
sub ps_lrri
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $imm;

    my $invert_opb;

    my $opcode = $ops{$operation}{opc};
    my $ra,$rb;

    check_argument_count( $#operands, 2 );
    $ra = check_data_register( $operands[0] );

    if (D1) { print $JNK_F ("ps_lrri label, operation, operands : $label, $operation, @operands\n"); }

    if ($pass == 2)
      {
        # check if opb is an immediate constant
        if ( $operands[1] =~ /^#(.+)$/ )
          { 
            ($status, $offset) = parse_expression($1);
   
            #
            # look up offset in imm5 encoding hash
            #
            $invert_opb = 0;
            $imm = $imm5_encode{sprintf("%08lx",$offset)};

            #
            # if that failed, look up NOT offset
            #
            if ( !$imm  ) 
              {
                $imm = $imm5_encode{sprintf("%08lx",~$offset)};
                $invert_opb = 1;
              }
   
            if (D1) { printf $JNK_F ("operands[1]  offset  inv  imm_field=%s  %d  %d %s\n", $operands[1], $offset, $invert_opb, $imm); }

            if ( !$imm  )
              {
                do_error ("Illegal IMM5 value (" . $offset . ") ");
                $imm = $imm5_encode{"00000000"};
              }
   
            #
            # flip the NOT bit in opcode as needed
            #   this should be another opcode field if parser is 
            #   changed to split mnemonic into op & sub-op ( e.g. "mov", ".not" )
            #
            if ( $invert_opb )
              {
                if ( substr( $opcode, 4, 1 ) eq '0' )
                  { substr( $opcode, 4, 1 ) = '1'; }
                else
                  { substr( $opcode, 4, 1 ) = '0'; }                 
              }
   
            $opcode = stuff_op_field( $opcode, 't', substr( $imm, 0, 2 )  );
            $opcode = stuff_op_field( $opcode, 'b', substr( $imm, 2, 5 )  );
            $opcode = stuff_op_field( $opcode, 'a', $ra                   );

            if (D1) { printf $JNK_F ("imm_field=%s  %s\n", $imm, $offset); }
          }

        else
          {
            $rb = check_data_register($operands[1]);

            $opcode = stuff_op_field( $opcode, 't', "00"      );
            $opcode = stuff_op_field( $opcode, 'b', "0" . $rb );
            $opcode = stuff_op_field( $opcode, 'a', $ra       );

          }
      }

    emit_op($opcode);
  }



#--------------------------------
# A_R_RI: OP Ra , Rb | CONST
#
#   arithmetic ops: add, sub, rsub
#
#--------------------------------
%ops_arri = 
  (
    'add'       =>  { type =>  'A_R_RI'   , opc => '01000ttbbbbbaaaa' , ps => \&ps_arri, name => "ADD"                              },
    'add.snc'   =>  { type =>  'A_R_RI_C' , opc => '01001ttbbbbbaaaa' , ps => \&ps_arri, name => "ADD, Skip No Carry"               }, 

    'sub'       =>  { type =>  'A_R_RI'   , opc => '01010ttbbbbbaaaa' , ps => \&ps_arri, name => "SUBtract"                         },
    'sub.snb'   =>  { type =>  'A_R_RI_C' , opc => '01011ttbbbbbaaaa' , ps => \&ps_arri, name => "SUBtract, Skip No Borrow"         }, 

    'rsub'      =>  { type =>  'A_R_RI'   , opc => '01100ttbbbbbaaaa' , ps => \&ps_arri, name => "Reverse SUBtract"                 },
    'rsub.snb'  =>  { type =>  'A_R_RI_C' , opc => '01101ttbbbbbaaaa' , ps => \&ps_arri, name => "Reverse SUBtract, Skip No Borrow" } 
  );

# add to HOH opcode table
@ops{keys %ops_arri} = values %ops_arri;


# ARRI parser
sub ps_arri
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $imm;

    my $opcode = $ops{$operation}{opc};
    my $type   = $ops{$operation}{type};
    my $ra,$rb;

    check_argument_count( $#operands, 2 );
    $ra = check_data_register( $operands[0] );

    if ( $type eq "A_R_RI_C" ) 
      {
        set_skip_flag();
      }

    if ($pass == 2)
      {
        # check if opb is an immediate constant
        if ( $operands[1] =~ /^#(.+)$/ )
          { 
            ($status, $offset) = parse_expression($1);
    
            $imm = $imm5_encode{sprintf("%08lx",$offset)};

            if ( !$imm  )
              {
                do_error ("Illegal IMM5 value (" . $offset . ") ");
                $imm = $imm5_encode{"00000000"};
              }
    
            $opcode = stuff_op_field( $opcode, 't', substr( $imm, 0, 2 )  );
            $opcode = stuff_op_field( $opcode, 'b', substr( $imm, 2, 5 )  );
            $opcode = stuff_op_field( $opcode, 'a', $ra                   );

            if (D1) { printf $JNK_F ("imm_field=%s  %s\n", $imm, $offset); }
          }

        else
          {
            $rb = check_data_register($operands[1]);

            $opcode = stuff_op_field( $opcode, 'a', $ra        );
            $opcode = stuff_op_field( $opcode, 't', "00"       );
            $opcode = stuff_op_field( $opcode, 'b', "0" . $rb  );
          }
      }
    
    emit_op($opcode);
  }



#----------------------
# SHIFT_R: OP Ra {,#imm}
#   handles shifts
#
#----------------------
%ops_sr = 
  (
                                           
    'lsr'  =>  { type =>  'SHIFT'  , opc => '0111000bbbbbaaaa' , ps => \&ps_sr, name => "Logical Shift Right"       },
    'asr'  =>  { type =>  'SHIFT'  , opc => '0111010bbbbbaaaa' , ps => \&ps_sr, name => "Arithmetical Shift Right"  },

    'lsl'  =>  { type =>  'SHIFT'  , opc => '0111001bbbbbaaaa' , ps => \&ps_sr, name => "Logical Shift Left"        },
                                                     
    'ror'  =>  { type =>  'ROTATE' , opc => '0111100bbbbbaaaa' , ps => \&ps_sr, name => "ROtate Right"              },
    'rol'  =>  { type =>  'ROTATE' , opc => '0111101bbbbbaaaa' , ps => \&ps_sr, name => "ROtate Left"               }

  );

# add to HOH opcode table
@ops{keys %ops_sr} = values %ops_sr;


# ORS parser
sub ps_sr
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $imm;

    my $opcode = $ops{$operation}{opc};
    my $ra,$rb;

#    check_argument_count( $#operands, 1 );
    $ra = check_data_register( $operands[0] );

    if ($pass == 2)
      {

        if ( $operands[1] )
          {
            # look for  an immediate constant
            if ( $operands[1] =~ /^#(.+)$/ )
              { 
                ($status, $offset) = parse_expression($1);

                # shifts of one allowed for all
                # shifts of two allowed only for ROL/LSL
                if ( 
                          ( $offset == 0 )
                     || ( ( $offset  > 1 ) && ( ($operation eq 'lsr') || ($operation eq 'asr') || ($operation eq 'ror') ) )
                     || ( ( $offset  > 2 ) && ( ($operation eq 'lsl') || ($operation eq 'rol') ) )
                   )
                  {
                    do_error("Unsupported shift/rotate length for the current Y1A core");
                  }

                # FIXME: need mask or field overflow test
                $imm = sprintf("%05b", $offset);
              }

            else
              {
                do_error("Expecting immediate constant");
                $imm = "00001";
              }
          }
        else
          {
            $imm = "00001";
          }

        if (D1) { printf $JNK_F ("shift constant=%d   %s\n",  $offset, $imm  ); }

        $opcode = stuff_op_field( $opcode, 'a', $ra  );
        $opcode = stuff_op_field( $opcode, 'b', $imm );
      }

    emit_op($opcode);
  }


#----------------------
# O0R: OP
#    Opcodes with no operands
#----------------------
%ops_o0r = 
  (
    'rts.d' =>  { type =>  'O0R' , opc => '1111100000100000' , ps => \&ps_o0r, name => "ReTurn from Subroutine, Delayed" },
    'rts'   =>  { type =>  'O0R' , opc => '1111101000100000' , ps => \&ps_o0r, name => "ReTurn from Subroutine"          },

    'rti.d' =>  { type =>  'O0R' , opc => '1111110000100000' , ps => \&ps_o0r, name => "ReTurn from Interrupt, Delayed"  },
    'rti'   =>  { type =>  'O0R' , opc => '1111111000100000' , ps => \&ps_o0r, name => "ReTurn from Interrupt"           }
  );

# add to HOH opcode table
@ops{keys %ops_o0r} = values %ops_o0r;


# o0r parser
sub ps_o0r
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $opcode = $ops{$operation}{opc};

    check_argument_count( $#operands, 0 );

    emit_op($opcode);
  }


#----------------------
#
# A0R: OP Ra
#   Opcode aliases, no registers
#
#----------------------
%ops_a0r = 
  (
    'nop'   =>  { type =>  'ALIAS_0R' , opc => '0000000000000000' , ps => \&ps_a0r, name => "No OPeration"       },  # mov r0,r0
    'ei'    =>  { type =>  'ALIAS_0R' , opc => '1100111100000100' , ps => \&ps_a0r, name => "Enable Interrupts"  },  # CP0 OP7,1,#4
    'di'    =>  { type =>  'ALIAS_0R' , opc => '1100011100000100' , ps => \&ps_a0r, name => "Disable Interrupts" },  # CP0 OP7,0,#4
  );

# add to HOH opcode table
@ops{keys %ops_a0r} = values %ops_a0r;


# A0R parser
sub ps_a0r
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $opcode = $ops{$operation}{opc};

    check_argument_count( $#operands, 0 );

    emit_op($opcode);
  }

#----------------------
#
# A1R: OP Ra
#   Opcode aliases, one register
#
#----------------------
%ops_a1r = 
  (
    'clr'  =>  { type =>  'ALIAS_1R' , opc => '000000100000aaaa' , ps => \&ps_a1r, name => "CLeaR"     }, # mov Ra,#0
    'not'  =>  { type =>  'ALIAS_1R' , opc => '001100111111aaaa' , ps => \&ps_a1r, name => "NOT"       }, # xor Ra,#$FFFF_FFFF
    'neg'  =>  { type =>  'ALIAS_1R' , opc => '011000100000aaaa' , ps => \&ps_a1r, name => "NEGate"    }, # rsub Ra,#0
    'inc'  =>  { type =>  'ALIAS_1R' , opc => '010000100001aaaa' , ps => \&ps_a1r, name => "INCrement" }, # add Ra,#1
    'dec'  =>  { type =>  'ALIAS_1R' , opc => '010100100001aaaa' , ps => \&ps_a1r, name => "DECrement" }  # sub Ra,#1
  );

# add to HOH opcode table
@ops{keys %ops_a1r} = values %ops_a1r;


# A1R parser
sub ps_a1r
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $opcode = $ops{$operation}{opc};
    my $ra;

    check_argument_count( $#operands, 1 );
    $ra = check_data_register( $operands[0] );

    if ($pass == 2)
      {
        $opcode = stuff_op_field( $opcode, 'a', $ra );
      }

    emit_op($opcode);
  }


#----------------------
#
# ORR: OP Ra,Rb
#
#----------------------
%ops_orr = 
  (
#
# FIXME: bit counting temporarily displaced, will move elsewhere in ISA
#
#    'ff1'   =>  { type =>  'ORR' , opc => '01111110bbbbaaaa' , ps => \&ps_orr, name => "Find First 1" },
#    'cnt1'  =>  { type =>  'ORR' , opc => '01111111bbbbaaaa' , ps => \&ps_orr, name => "CouNT 1's"    } 

    'ext.uw' =>  { type =>  'ORR' , opc => '01111100bbbbaaaa' , ps => \&ps_orr, name => "EXTend, Unsigned Wyde" },
    'ext.sw' =>  { type =>  'ORR' , opc => '01111101bbbbaaaa' , ps => \&ps_orr, name => "EXTend, Signed Wyde" },

    'ext.ub' =>  { type =>  'ORR' , opc => '01111110bbbbaaaa' , ps => \&ps_orr, name => "EXTend, Unsigned Byte" },
    'ext.sb' =>  { type =>  'ORR' , opc => '01111111bbbbaaaa' , ps => \&ps_orr, name => "EXTend, Signed Byte" },

  );


# add to HOH opcode table
@ops{keys %ops_orr} = values %ops_orr;

# ORR parser
sub ps_orr
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $opcode = $ops{$operation}{opc};
    my $ra,$rb;

    check_argument_count( $#operands, 2 );

    $ra = check_data_register( $operands[0] );
    $rb = check_data_register( $operands[1] );

    if ($pass == 2)
      {
        $opcode = stuff_op_field( $opcode, 'a', $ra );
        $opcode = stuff_op_field( $opcode, 'b', $rb );
      }

    emit_op($opcode);
  }


#----------------------
# ORI: OP Ra, IMM5
#   handles flip instruction
#----------------------
%ops_ori = 
  (
    'flip'   =>  { type =>  'ORI' , opc => '0111011bbbbbaaaa' , ps => \&ps_ori, name => "FLIP" }
  );

# add to HOH opcode table
@ops{keys %ops_ori} = values %ops_ori;

# ORI parser
sub ps_ori
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $imm;

    my $opcode = $ops{$operation}{opc};
    my $ra;

    check_argument_count( $#operands, 2 );
    $ra = check_data_register( $operands[0] );

    if ($pass == 2)
      {
        # check if opb is an immediate constant
        if ( $operands[1] =~ /^#(.+)$/ )
          { 
            ($status, $offset) = parse_expression($1);

            # FIXME: need mask or field overflow test
            $imm = sprintf("%05b", $offset);
          }

        else
          {
            do_error("Expecting immediate constant");
            $imm = "00000";
          }

        if (D1) { printf $JNK_F ("flip constant=%d   %s\n",  $offset, $imm  ); }

        $opcode = stuff_op_field( $opcode, 'a', $ra );
        $opcode = stuff_op_field( $opcode, 'b', $imm );

      }

    emit_op($opcode);
    
  }


#----------------------
# MEM: OP Ra {.imm}(Rb)
#----------------------
%ops_mem = 
  (

    'ld'     =>  { type =>  'MEM32' , opc => '1000mss0bbbbaaaa' , size => '01' ,  ps => \&ps_mem, name => "LoaD"                   },
    'ld.q'   =>  { type =>  'MEM32' , opc => '1000mss0bbbbaaaa' , size => '01' ,  ps => \&ps_mem, name => "LoaD, Quad"             },

    'ld.w'   =>  { type =>  'MEM16' , opc => '1000mss1bbbbaaaa' , size => '10' ,  ps => \&ps_mem, name => "LoaD, Wyde"             },
    'ld.sw'  =>  { type =>  'MEM16' , opc => '1000mss1bbbbaaaa' , size => '10' ,  ps => \&ps_mem, name => "LoaD, Signed Wyde"      },
    'ld.uw'  =>  { type =>  'MEM16' , opc => '1000mss0bbbbaaaa' , size => '10' ,  ps => \&ps_mem, name => "LoaD, Unsigned Wyde"    },

    'ld.b'   =>  { type =>  'MEM8'  , opc => '1000mss1bbbbaaaa' , size => '11' ,  ps => \&ps_mem, name => "LoaD, Byte"             },
    'ld.sb'  =>  { type =>  'MEM8'  , opc => '1000mss1bbbbaaaa' , size => '11' ,  ps => \&ps_mem, name => "LoaD, Signed Byte"      },
    'ld.ub'  =>  { type =>  'MEM8'  , opc => '1000mss0bbbbaaaa' , size => '11' ,  ps => \&ps_mem, name => "LoaD, Unsigned Byte"    },

    'st'     =>  { type =>  'MEM32' , opc => '1001mss0bbbbaaaa' , size => '01' ,  ps => \&ps_mem, name => "STore"                  },
    'st.q'   =>  { type =>  'MEM32' , opc => '1001mss0bbbbaaaa' , size => '01' ,  ps => \&ps_mem, name => "STore, Quad"            },

    'st.w'   =>  { type =>  'MEM16' , opc => '1001mss0bbbbaaaa' , size => '10' ,  ps => \&ps_mem, name => "STore, Wyde"            },
    'st.b'   =>  { type =>  'MEM8'  , opc => '1001mss0bbbbaaaa' , size => '11' ,  ps => \&ps_mem, name => "STore, Byte"            },

    'lea'    =>  { type =>  'LEA'   , opc => '1001mss1bbbbaaaa' , size => '11' ,  ps => \&ps_mem, name => "Load Effective Address" }

  );


# add to HOH opcode table
@ops{keys %ops_mem} = values %ops_mem;

# MEM parser
sub ps_mem
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $offset_str;

    my $imm_mode;

    my $prefix = '0000000000000000';

    my $opcode = $ops{$operation}{opc};
    my $type   = $ops{$operation}{type};
    my $size   = $ops{$operation}{size};
    my $ra,$rb;


    check_argument_count( $#operands, 2 );

    $ra = check_data_register( $operands[0] );

    #
    # parse address field : $1 = offset field  $2 = address register field
    #  {offset | .imm}(Rb)  
    #
    $operands[1] =~ /^(.*)\((.+)\)$/;

    if (D1) { printf $JNK_F ("MEM fields=%s %s\n",  $1,  $2 ); }

    #
    # TODO: compact this if, too many redundant paths
    #
    if ( $1 eq '' )
    { 
      #
      # no offset
      #
      $imm_mode = "0"; 
      $rb = check_addr_register($2);

      $opcode = stuff_op_field( $opcode, 's', $size     );
      $opcode = stuff_op_field( $opcode, 'm', $imm_mode );
      $opcode = stuff_op_field( $opcode, 'b', $rb       );
      $opcode = stuff_op_field( $opcode, 'a', $ra       );
    }

    else 
    {
      if ( $1 eq "\.imm" )   
      { 
        # .imm offset mode

        $imm_mode = "1"; 

        $rb = check_addr_register($2);

        $opcode = stuff_op_field( $opcode, 's', $size     );
        $opcode = stuff_op_field( $opcode, 'm', $imm_mode );
        $opcode = stuff_op_field( $opcode, 'b', $rb       );
        $opcode = stuff_op_field( $opcode, 'a', $ra       );
      }

      elsif ( exists $stack_reg_map{$2} )
      {
        # sp/fp offset mode

        #
        # mode bit selects FP or SP
        #
        if ( ($2 eq 'fp') || ($2 eq 'r12') )
        {
          $imm_mode = '0';
        }
        else
        {
          $imm_mode = '1';
        }

        #
        # check for valid stack offset 
        #
        ($status, $offset) = parse_expression($1);

        if ( $status != 0 ) 
        {
          do_error("Stack offset must be known on pass one");
          $offset = 0;
        }

        # FIXME: make sure .imm path allows .imm(sp|fp) syntax, with opcode for normal load

        #
        # check offset alignment
        #
        if ( ( $offset % 4 ) > 0 ) 
        {
          do_error("Offset must be quad aligned for stack offset addressing modes");
        }

        #
        # check stack offset range 
        #
        if ( ($offset > 60) || ($offset < 0) ) 
        {
          # FIXME: should also handle long imm prefixes here, instead of assuming imm12

          #
          # out of range stack offset, so generate IMM12 prefix instead
          #
          $offset_str = sprintf("%032b", $offset);
          $offset_str = substr( $offset_str, length($offset_str)-12, 12);

          $prefix = $ops{'imm12'}{opc};
          $prefix = stuff_op_field( $prefix, 'i', $offset_str );

          emit_prefix($prefix);

          #
          # and then switch over to regular .imm offset addressing
          #
          $imm_mode = '1'; 

          $rb = check_addr_register($2);

          $opcode = stuff_op_field( $opcode, 's', $size     );
          $opcode = stuff_op_field( $opcode, 'm', $imm_mode );
          $opcode = stuff_op_field( $opcode, 'b', $rb       );
          $opcode = stuff_op_field( $opcode, 'a', $ra       );

        }

        else
        {
          #
          # normal stack offset mode
          #
          $offset_str = sprintf("%04b", $offset >> 2 );

          #
          # size field = 00 for stack offset addressing modes
          # no byte or word accesses allowed
          #
          if ( ( $type eq 'MEM32' ) || ( $type eq 'LEA' ) )
          { 
            $size = '00';
          }
          else
          { 
            do_error("Only 32 bit LD/ST, or LEA, allowed for stack offset addressing modes");
            $size = '00';
          }

          $opcode = stuff_op_field( $opcode, 's', $size       );
          $opcode = stuff_op_field( $opcode, 'm', $imm_mode   );
          $opcode = stuff_op_field( $opcode, 'b', $offset_str );
          $opcode = stuff_op_field( $opcode, 'a', $ra         );

        }
      }

      #
      # TODO: add automatic offset prefix
      #
      else
      {
        do_error("Only .imm(rn) offset syntax currently supported by assembler\n");

        $imm_mode = '0';
        $rb = check_addr_register($2);

        $opcode = stuff_op_field( $opcode, 's', $size     );
        $opcode = stuff_op_field( $opcode, 'm', $imm_mode );
        $opcode = stuff_op_field( $opcode, 'b', $rb       );
        $opcode = stuff_op_field( $opcode, 'a', $ra       );
      }
    }

    emit_op($opcode);
    
  }



#--------------------------
# IMM12: IMM12 #imm12
#--------------------------
%ops_imm12 = 
  (
    'imm12'   =>  { type =>  'IMM12' , opc => '1011iiiiiiiiiiii' , ps => \&ps_imm12, name => "IMMediate, 12 bit" }
  );


# add to HOH opcode table
@ops{keys %ops_imm12} = values %ops_imm12;

# ORI parser
sub ps_imm12
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $imm;

    my $opcode = $ops{$operation}{opc};

    check_argument_count( $#operands, 1 );

    if ($pass == 2)
      {
        # check if opb is an immediate constant
        if ( $operands[0] =~ /^#(.+)$/ )
          { 
            ($status, $offset) = parse_expression($1);
          }
    
        else
          {
            do_error("Expecting immediate constant");
            $status = -1;
          }
    
        if ( ($pass == 2) & ($status != 0 ) )
          {
            do_error("Undefined immediate constant");

            $opcode = stuff_op_field( $opcode, 'i', '000000000000' );
          }

        else
          {
            $imm = sprintf "%012b", $offset;

            #
            # %012b format overflows format field for negative integers, truncate string to 12 bits
            # FIXME: should check for overflow here
            #
            $imm = substr( $imm, length($imm)-12, 12);

            $opcode = stuff_op_field( $opcode, 'i', $imm );
    
            if (D1) { printf $JNK_F ("imm12_field=%s    %s\n", $offset, $imm ); }
     
          }
      }

    emit_op($opcode);
    
   }



#----------------------
# LDI: LDI EA
#----------------------
%ops_ldi = 
  (
    'ldi'    =>  { type =>  'LDI' , opc => '1010rrrrrrrrrrrr' , ps => \&ps_ldi, name => "LoaD Immediate" }
  );


# add to HOH opcode table
@ops{keys %ops_ldi} = values %ops_ldi;

# LDI parser
sub ps_ldi
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $offset_str;

    my $opcode = $ops{$operation}{opc};


    check_argument_count( $#operands, 1 );

    #
    #BMD needs rework for +/- word alignment once offset logic shared with BRA
    #

    # calculate offset from current PC (quad aligned) to address
    ($status, $offset) = parse_expression($operands[0]);
    $offset = $offset - ( (get_address() >> 2 ) << 2);

    if ($pass == 2)
      {
        # check for defined address
        if ($status != 0 )
          {
            do_error("Undefined LDI source address");
            $offset = 0;
          }

        # check for quad aligned target address before truncating offset
        if ( ( $offset % 4 ) > 0 )
          {
            do_error("Unaligned LDI source address");
            if (D1) { printf $JNK_F ("offset, offset mod 4=%x  %x\n",  $offset,  $offset % 4); }
          }

        $offset = $offset >> 2;
    
        # check for out of range 
        if ( ( $offset > 4095 ) || ( $offset < 0 ) )
          {
            do_error("LDI offset out of range");
            $offset = 0;
          }

        $offset_str = sprintf("%012b", $offset);
        $opcode = stuff_op_field( $opcode, 'r', $offset_str );

        if (D1) { printf $JNK_F ("ea12_field=%d   %s    %s\n",  $offset,  $offset_str, substr($opcode,4,12) ); }
      }

    emit_op($opcode);
    
  }


#--------------------------
# IMM: IMM #immediate
#
#  macro-like mnemonic picks best constant encoding
#
#  TODO: LDI variant ( needs to record pass one size decision, also requires auto LDI tables )
#
#--------------------------
%ops_imm = 
  (
    'imm'   =>  { type =>  'IMM' , opc => 'xxxxxxxxxxxxxxxx' , ps => \&ps_imm, name => "IMMediate, choose best encoding" }
  );


# add to HOH opcode table
@ops{keys %ops_imm} = values %ops_imm;

# ORI parser
sub ps_imm
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $raw_str;
    my $offset;
    my $imm;

    my $label;
    my $pcr_offset;
    my $pcr_offset_str;

    my $opcode = $ops{$operation}{opc};

    check_argument_count( $#operands, 1 );

    # always grab the next imm label number, even if not used, to avoid phasing issues
    $label = next_imm_label();

    # check if opb is an immediate constant
    if ( $operands[0] =~ /^#(.+)$/ )
      { 
        $raw_str = $1;
        ($status, $offset) = parse_expression($1);
      }
    else
      {
        do_error("Expecting immediate constant");
        $status = -1;
      }

    #
    # pass1 values
    #
    if ( $pass == 1 )
      {

        if ( $status != 0 )
          {

           # unknown pass 1 constant, assume LDI 
           $imms[$imm_table_num]{ $label } = { pass1_known => 0, value => 0, pass1_value => 0 };

           ###  #
           ###  # TESTME: experiment to allow pass 1 merging based upon raw field string 
           ###  #
           ###  # *** this doesn't work, sort uses <=> operator which needs numerical field, not string value ***
           ###  #
           ###  $imms{ $label } = { can_merge => 1, table_num => $imm_table_num, value => 0, pass1_value => $raw_str };
           ###  

            $imm_entries_used[$imm_table_num]++;

            if (D1) { print $JNK_F (" imm table (unknown) : $label, $raw_str, $imm_table_num\n"); }
          }
        else
          {

            # don't create imm entry if pass 1 value is a known IMM5/IMM12 constant
            if (
                    ( $imm5_encode{sprintf("%08lx",  $offset)} )
                 || ( $imm5_encode{sprintf("%08lx", ~$offset)} )
                 || ( ($offset <= 2047) && ($offset >= -2048) )
               )

              { 
                if (D1) { print $JNK_F (" imm table ( known imm5|imm12 ) : $label, $offset, $imm_table_num\n"); }
              }
            else
              { 
                if (D1) { print $JNK_F (" imm table (known) : $label, $offset, $imm_table_num\n"); }

                # add to imm hash
                $imms[$imm_table_num]{ $label } = { pass1_known => 1, value => $offset, pass1_value => $offset };

                $imm_entries_used[$imm_table_num]++;
              }
          }
      }

    #
    # pass 2 values
    #
    if ( ($pass == 2) & ($status != 0 ) )
      {
        do_error("Undefined immediate constant");
      }
    else
      {
        # if entry exists, {re}populate value on pass 2 
        if ($imms[$imm_table_num]{ $label }) 
         { $imms[$imm_table_num]{ $label }{ value } = $offset; }
      }

    #
    # pass2 code generation
    #
    if ( ($pass == 2) & ($status == 0 ) ) 
      {

        ###########
        #
        # five bit constant check, should make this a function
        #

        #
        # look up offset in imm5 encoding hash
        #
        $invert_opb = 0;
        $imm = $imm5_encode{sprintf("%08lx",$offset)};

        #
        # if that failed, look up NOT offset
        #
        if ( !$imm  ) 
          {
            $imm = $imm5_encode{sprintf("%08lx",~$offset)};
            $invert_opb = 1;
          }
     
        if (D1) { printf $JNK_F ("operands[1]  offset  inv  imm_field=%s  %d  %d %s\n", $operands[1], $offset, $invert_opb, $imm); }

        #
        ###########

        if ( $imm  )
          #
          # encoded 5 bit immediate
          #
          {
            $opcode = $ops{'mov'}{opc};

            #
            # flip the NOT bit in opcode as needed
            #   this should be another opcode field if parser is 
            #   changed to split mnemonic into op & sub-op ( e.g. "mov", ".not" )
            #
            if ( $invert_opb )
              {
                if ( substr( $opcode, 4, 1 ) eq '0' )
                  { substr( $opcode, 4, 1 ) = '1'; }
                else
                  { substr( $opcode, 4, 1 ) = '0'; }                 
              }
       
            $opcode = stuff_op_field( $opcode, 't', substr( $imm, 0, 2 )  );
            $opcode = stuff_op_field( $opcode, 'b', substr( $imm, 2, 5 )  );
            $opcode = stuff_op_field( $opcode, 'a', $data_reg_map{'imm'}   );

            if (D1) { printf $JNK_F ("imm_field=%s  %s\n", $imm, $offset); }
          }

        #
        # imm12
        #
        elsif ( ($offset <= 2047) && ($offset >= -2048) )
          {
            $opcode = $ops{'imm12'}{opc};

            $imm = sprintf "%012b", $offset;

            #
            # %012b format overflows format field for negative integers, truncate string to 12 bits
            # FIXME: should check for overflow here
            #
            $imm = substr( $imm, length($imm)-12, 12);

            $opcode = stuff_op_field( $opcode, 'i', $imm );
     
            if (D1) { printf $JNK_F ("imm12_field=%s    %s\n", $offset, $imm ); }
     
          }

        #
        # auto LDI entry
        #
        else
          {
            #
            # prototype of imm hash code
            #


            # calculate offset from current PC (quad aligned) to automatic imm label
            $pcr_offset = label_value( $label ) - ( (get_address() >> 2 ) << 2);


            if (D1) { printf $JNK_F (" auto imm label, offset(bytes), dest addr: %s %d %08x\n", $label, $pcr_offset, label_value($label) ); }

            # check for quad aligned target address before truncating pcr_offset
            if ( ( $pcr_offset % 4 ) > 0 )
              {
                do_error("Unaligned automatic IMM LDI target address");
              }

            #
            # check if offset is within range 
            #  - unsigned 12 bit offset instruction field is in quads
            #  - pcr_offset is in bytes before shift
            #
            if ( ( $pcr_offset > (4095 * 4)  ) || ( $pcr_offset < 0 ) )
              {
                do_error("automatic IMM offset to LDI constant is out of range");
                $pcr_offset = 0;
              }

            # convert to quad offset
            $pcr_offset = $pcr_offset >> 2;


            # %012b format overflows format field for negative integers, truncate string to 12 bits after sprintf
            $pcr_offset_str = sprintf("%012b", $pcr_offset);
            $pcr_offset_str = substr( $pcr_offset_str, length($pcr_offset_str)-12, 12);


            #
            $opcode = $ops{'ldi'}{opc};
            $opcode = stuff_op_field( $opcode, 'r', $pcr_offset_str );

          }

     }

    emit_op($opcode);
  }

     

#------------------------------------------------------------------------------
# BRI: OP  ea9 | ea21
#   {l}bra, {l}bsr
#
# FIXME: 
#    bsr.d : stacked return address HW needs fixup to work properly with interrupts
#    lbsr  : code needs work to handle full 32 bit branch prefix with LDI
#------------------------------------------------------------------------------
     

%ops_bri = 
  (
    'bra.d'  =>  { type =>  'BRI'  , opc => '1110000rrrrrrrrr' , ps => \&ps_bri, name => "BRAnch, Delayed"                 },
    'bra'    =>  { type =>  'BRI'  , opc => '1110001rrrrrrrrr' , ps => \&ps_bri, name => "BRAnch"                          },
    'bsr.d'  =>  { type =>  'BRI'  , opc => '1110010rrrrrrrrr' , ps => \&ps_bri, name => "Branch SubRoutine, Delayed"      },
    'bsr'    =>  { type =>  'BRI'  , opc => '1110011rrrrrrrrr' , ps => \&ps_bri, name => "Branch SubRoutine"               },

    'lbra.d' =>  { type =>  'LBRI' , opc => '1110100rrrrrrrrr' , ps => \&ps_bri, name => "Long BRAnch, Delayed"            }, 
    'lbra'   =>  { type =>  'LBRI' , opc => '1110101rrrrrrrrr' , ps => \&ps_bri, name => "Long BRAnch"                     }, 
    'lbsr.d' =>  { type =>  'LBRI' , opc => '1110110rrrrrrrrr' , ps => \&ps_bri, name => "Long Branch SubRoutine, Delayed" },
    'lbsr'   =>  { type =>  'LBRI' , opc => '1110111rrrrrrrrr' , ps => \&ps_bri, name => "Long Branch SubRoutine"          } 
  );


# add to HOH opcode table
@ops{keys %ops_bri} = values %ops_bri;

# ORI parser
sub ps_bri
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;

    my $pcr_offset;
    my $pcr_offset_str;

    my $pcr_offset_str_lo;
    my $pcr_offset_str_mid;
    my $pcr_offset_str_hi;

    my $opcode = $ops{$operation}{opc};
    my $prefix = '0000000000000000';

    check_argument_count( $#operands, 1 );


    #
    # account for any LBRI prefix on pass 1 to avoid phasing errors
    #
    if ($pass == 1)
    {
      if ( $ops{$operation}{type} eq 'LBRI' )
      {
        emit_prefix($prefix);
      }
    }

    #
    # offset calculations only done during pass 2
    #
    if ($pass == 2)
      {

        # calculate offset from current PC to address

        ($status, $offset) = parse_expression($operands[0]);
        $pcr_offset = $offset - get_address();

        if ( $ops{$operation}{type} eq 'LBRI' )
        {
          $pcr_offset = $pcr_offset - 2;   # account for LBRI prefix instruction
        }

        if (D1) { printf $JNK_F ("offset, pcr_offset = %d   %d\n",  $offset,  $pcr_offset ); }


        if ($status != 0 )
          {
            do_error("Undefined branch target");
            $pcr_offset = 0;
          }

        else
          {
            #
            # range checks
            #
            if ( $ops{$operation}{type} eq 'LBRI' )
            {

              # range of signed 21 bit instruction pcr_offset field, in bytes
              if ( ( $pcr_offset > 2097150 ) || ( $pcr_offset < -2097152 ) )
              {
                do_error("32-bit long branch prefix support not yet implemented in the assembler");
                $pcr_offset = 0;
              }

            }

            # range of signed 9 bit instruction pcr_offset field, in bytes
            elsif ( ( $pcr_offset > 510 ) || ( $pcr_offset < -512 ) )
              {
                do_error("Branch offset out of range");
                $pcr_offset = 0;
              }


            # check for word aligned target address before truncating pcr_offset
            if ( ( $pcr_offset % 2 ) > 0 )
              {
                do_error("Unaligned branch target");
              }

            # convert to instruction (16 bit) offset
            $pcr_offset = $pcr_offset >> 1;


            # narrow format specifier overflows format field for negative integers, truncate strings bits after sprintf
            $pcr_offset_str    = sprintf("%032b", $pcr_offset);

            $pcr_offset_str_lo  = substr( $pcr_offset_str, length($pcr_offset_str)-9 , 9);
            $pcr_offset_str_mid = substr( $pcr_offset_str, length($pcr_offset_str)-21, 12);
            $pcr_offset_str_hi  = substr( $pcr_offset_str, length($pcr_offset_str)-32, 23);


            if ( $ops{$operation}{type} eq 'LBRI' )
            {
              $prefix = $ops{'imm12'}{opc};

              $prefix = stuff_op_field( $prefix, 'i', $pcr_offset_str_mid );

              emit_prefix($prefix);
            }

            $opcode = stuff_op_field( $opcode, 'r', $pcr_offset_str_lo );

            if (D1) { printf $JNK_F ("imm9_field=%d   %s    %s\n",  $pcr_offset,  $pcr_offset_str_lo, substr($opcode,7,9) ); }
          }
      }

    emit_op($opcode);
    
  }


#----------------
# JIR: OP (Ra) 
#----------------
%ops_jir = 
  (
    'jmp.d' =>  { type =>  'JIRD' , opc => '111110000000aaaa' , ps => \&ps_jir , name => "JuMP, Delayed"            },
    'jmp'   =>  { type =>  'JIR'  , opc => '111110100000aaaa' , ps => \&ps_jir , name => "JuMP"                     },

    'jsr.d' =>  { type =>  'JIRD' , opc => '111111000000aaaa' , ps => \&ps_jir , name => "Jump SubRoutine, Delayed" },
    'jsr'   =>  { type =>  'JIR'  , opc => '111111100000aaaa' , ps => \&ps_jir , name => "Jump SubRoutine"          }
  );


# add to HOH opcode table
@ops{keys %ops_jir} = values %ops_jir;

# JIR parser
sub ps_jir
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $opcode = $ops{$operation}{opc};
    my $ra ;

    check_argument_count( $#operands, 1 );

    $operands[0] =~ /^\((.+)\)$/;

    $ra = check_addr_register($1);

    if ($pass == 2)
      {
        $opcode = stuff_op_field( $opcode, 'a', $ra );
      }

    emit_op($opcode);
  }


#---------------------------------------------
# SKIP: skip.cc Ra {IMM5}
#
#   WHEN's are alternate mnemonics for the skip of the opposite condition
#
#   FIXME: add check of valid modes for each skip type  
#
#---------------------------------------------
   
%ops_skip = 
  (
    #
    # SKIP
    #
    'skip'      =>  { type =>  'SKIP_0'    , opc => '1101010000000000' , ps => \&ps_skip , name => "SKIP"                         },  #skip.eq r0,r0
    'skip.a'    =>  { type =>  'SKIP_0'    , opc => '1101010000000000' , ps => \&ps_skip , name => "SKIP Always"                  },  #skip.eq r0,r0
    'when.n'    =>  { type =>  'SKIP_0'    , opc => '1101010000000000' , ps => \&ps_skip , name => "WHEN Never"                   },  #skip.eq r0,r0

    #
    'skip.n'    =>  { type =>  'SKIP_0'    , opc => '1101110000000000' , ps => \&ps_skip , name => "SKIP Never"                   },  #skip.ne r0,r0
    'when.a'    =>  { type =>  'SKIP_0'    , opc => '1101110000000000' , ps => \&ps_skip , name => "WHEN Always"                  },  #skip.ne r0,r0
    'when'      =>  { type =>  'SKIP_0'    , opc => '1101110000000000' , ps => \&ps_skip , name => "WHEN"                         },  #skip.ne r0,r0

    #
    #  SKIP Ra   
    #
    'skip.z'    =>  { type =>  'SKIP_R'    , opc => '110101010000aaaa' , ps => \&ps_skip , name => "SKIP Zero"                    },
    'when.nz'   =>  { type =>  'SKIP_R'    , opc => '110101010000aaaa' , ps => \&ps_skip , name => "WHEN NonZero"                 },

    'skip.nz'   =>  { type =>  'SKIP_R'    , opc => '110111010000aaaa' , ps => \&ps_skip , name => "SKIP NonZero"                 },
    'when.z'    =>  { type =>  'SKIP_R'    , opc => '110111010000aaaa' , ps => \&ps_skip , name => "WHEN Zero"                    },

    #
    'skip.awz'  =>  { type =>  'SKIP_R'    , opc => '110101010001aaaa' , ps => \&ps_skip , name => "SKIP Any Wyde Zero"           },
    'when.nwz'  =>  { type =>  'SKIP_R'    , opc => '110101010001aaaa' , ps => \&ps_skip , name => "WHEN No Wyde Zero"            },

    'skip.nwz'  =>  { type =>  'SKIP_R'    , opc => '110111010001aaaa' , ps => \&ps_skip , name => "SKIP No Wyde Zero"            },
    'when.awz'  =>  { type =>  'SKIP_R'    , opc => '110111010001aaaa' , ps => \&ps_skip , name => "WHEN Any Wyde Zero"           },

    #
    'skip.abz'  =>  { type =>  'SKIP_R'    , opc => '110101010010aaaa' , ps => \&ps_skip , name => "SKIP Any Byte Zero"           },
    'when.nbz'  =>  { type =>  'SKIP_R'    , opc => '110101010010aaaa' , ps => \&ps_skip , name => "WHEN No Byte Zero"            },

    'skip.nbz'  =>  { type =>  'SKIP_R'    , opc => '110111010010aaaa' , ps => \&ps_skip , name => "SKIP No Byte Zero"            },
    'when.abz'  =>  { type =>  'SKIP_R'    , opc => '110111010010aaaa' , ps => \&ps_skip , name => "WHEN Any Byte Zero"           },

    #                                                                                                                             
#   'skip.xx'   =>  { type =>  'SKIP_R'    , opc => '110101010011aaaa' , ps => \&ps_skip , name => "SKIP  xx"                     },
#   'when.nxx'  =>  { type =>  'SKIP_R'    , opc => '110101010011aaaa' , ps => \&ps_skip , name => "WHEN nxx"                     },

#   'skip.nxx'  =>  { type =>  'SKIP_R'    , opc => '110111010011aaaa' , ps => \&ps_skip , name => "SKIP nxx"                     },
#   'when.xx'   =>  { type =>  'SKIP_R'    , opc => '110111010011aaaa' , ps => \&ps_skip , name => "WHEN  xx"                     },

    #
    'skip.lez'  =>  { type =>  'SKIP_R'    , opc => '110101010100aaaa' , ps => \&ps_skip , name => "SKIP Less than or Equal Zero" },
    'when.gtz'  =>  { type =>  'SKIP_R'    , opc => '110101010100aaaa' , ps => \&ps_skip , name => "WHEN Greater than Zero"       },

    'skip.gtz'  =>  { type =>  'SKIP_R'    , opc => '110111010100aaaa' , ps => \&ps_skip , name => "SKIP Greater than Zero"       },
    'when.lez'  =>  { type =>  'SKIP_R'    , opc => '110111010100aaaa' , ps => \&ps_skip , name => "WHEN Less than or Equal Zero" },

    #
    'skip.awm'  =>  { type =>  'SKIP_R'    , opc => '110101010101aaaa' , ps => \&ps_skip , name => "SKIP Any Wyde Minus"          },
    'when.nwm'  =>  { type =>  'SKIP_R'    , opc => '110101010101aaaa' , ps => \&ps_skip , name => "WHEN No Wyde Minus"           },

    'skip.nwm'  =>  { type =>  'SKIP_R'    , opc => '110111010101aaaa' , ps => \&ps_skip , name => "SKIP No Wyde Minus"           },
    'when.awm'  =>  { type =>  'SKIP_R'    , opc => '110111010101aaaa' , ps => \&ps_skip , name => "WHEN Any Wyde Minus"          },

    #
    'skip.abm'  =>  { type =>  'SKIP_R'    , opc => '110101010110aaaa' , ps => \&ps_skip , name => "SKIP Any Byte Minus"          },
    'when.nbm'  =>  { type =>  'SKIP_R'    , opc => '110101010110aaaa' , ps => \&ps_skip , name => "WHEN No Byte Minus"           },

    'skip.nbm'  =>  { type =>  'SKIP_R'    , opc => '110111010110aaaa' , ps => \&ps_skip , name => "SKIP No Byte Minus"           },
    'when.abm'  =>  { type =>  'SKIP_R'    , opc => '110111010110aaaa' , ps => \&ps_skip , name => "WHEN Any Byte Minus"          },

    #
    'skip.fs'   =>  { type =>  'SKIP_FLAG' , opc => '110101010111aaaa' , ps => \&ps_skip , name => "SKIP Flag Set"                },
    'when.fc'   =>  { type =>  'SKIP_FLAG' , opc => '110101010111aaaa' , ps => \&ps_skip , name => "WHEN Flag Clear"              },

    'skip.fc'   =>  { type =>  'SKIP_FLAG' , opc => '110111010111aaaa' , ps => \&ps_skip , name => "SKIP Flag Clear"              },
    'when.fs'   =>  { type =>  'SKIP_FLAG' , opc => '110111010111aaaa' , ps => \&ps_skip , name => "WHEN Flag Set"                },

    #
    'skip.mi'   =>  { type =>  'SKIP_R'    , opc => '110101111111aaaa' , ps => \&ps_skip , name => "SKIP Minus"                   },  # skip.bs Ra, #31
    'when.pl'   =>  { type =>  'SKIP_R'    , opc => '110101111111aaaa' , ps => \&ps_skip , name => "WHEN Plus"                    },  # skip.bs Ra, #31

    'skip.pl'   =>  { type =>  'SKIP_R'    , opc => '110111111111aaaa' , ps => \&ps_skip , name => "SKIP Plus"                    },  # skip.bc Ra, #31
    'when.mi'   =>  { type =>  'SKIP_R'    , opc => '110111111111aaaa' , ps => \&ps_skip , name => "WHEN Minus"                   },  # skip.bc Ra, #31

    #
    # SKIP Ra Rb
    #
    'skip.lo'   =>  { type =>  'SKIP_R_R'  , opc => '11010000bbbbaaaa' , ps => \&ps_skip , name => "SKIP Lower"                   },
    'when.hs'   =>  { type =>  'SKIP_R_R'  , opc => '11010000bbbbaaaa' , ps => \&ps_skip , name => "WHEN Higher or Same"          },

    'skip.hs'   =>  { type =>  'SKIP_R_R'  , opc => '11011000bbbbaaaa' , ps => \&ps_skip , name => "SKIP Higher or Same"          },
    'when.lo'   =>  { type =>  'SKIP_R_R'  , opc => '11011000bbbbaaaa' , ps => \&ps_skip , name => "WHEN Lower"                   },

    #
    'skip.ls'   =>  { type =>  'SKIP_R_R'  , opc => '11010001bbbbaaaa' , ps => \&ps_skip , name => "SKIP Lower or Same"           },
    'when.hi'   =>  { type =>  'SKIP_R_R'  , opc => '11010001bbbbaaaa' , ps => \&ps_skip , name => "WHEN Higher"                  },

    'skip.hi'   =>  { type =>  'SKIP_R_R'  , opc => '11011001bbbbaaaa' , ps => \&ps_skip , name => "SKIP Higher"                  },
    'when.ls'   =>  { type =>  'SKIP_R_R'  , opc => '11011001bbbbaaaa' , ps => \&ps_skip , name => "WHEN Lower or Same"           },

    #
    'skip.lt'   =>  { type =>  'SKIP_R_R'  , opc => '11010010bbbbaaaa' , ps => \&ps_skip , name => "SKIP Less Than"               },
    'when.ge'   =>  { type =>  'SKIP_R_R'  , opc => '11010010bbbbaaaa' , ps => \&ps_skip , name => "WHEN Greater than or Equal"   },

    'skip.ge'   =>  { type =>  'SKIP_R_R'  , opc => '11011010bbbbaaaa' , ps => \&ps_skip , name => "SKIP Greater than or Equal"   },
    'when.lt'   =>  { type =>  'SKIP_R_R'  , opc => '11011010bbbbaaaa' , ps => \&ps_skip , name => "WHEN Less Than"               },

    #
    'skip.le'   =>  { type =>  'SKIP_R_R'  , opc => '11010011bbbbaaaa' , ps => \&ps_skip , name => "SKIP Less than or Equal"      },
    'when.gt'   =>  { type =>  'SKIP_R_R'  , opc => '11010011bbbbaaaa' , ps => \&ps_skip , name => "WHEN Greater Than"            },

    'skip.gt'   =>  { type =>  'SKIP_R_R'  , opc => '11011011bbbbaaaa' , ps => \&ps_skip , name => "SKIP Greater Than"            },
    'when.le'   =>  { type =>  'SKIP_R_R'  , opc => '11011011bbbbaaaa' , ps => \&ps_skip , name => "WHEN Less than or Equal"      },

    #
    'skip.eq'   =>  { type =>  'SKIP_R_R'  , opc => '11010100bbbbaaaa' , ps => \&ps_skip , name => "SKIP Equal"                   },
    'when.ne'   =>  { type =>  'SKIP_R_R'  , opc => '11010100bbbbaaaa' , ps => \&ps_skip , name => "WHEN Not Equal"               },

    'skip.ne'   =>  { type =>  'SKIP_R_R'  , opc => '11011100bbbbaaaa' , ps => \&ps_skip , name => "SKIP Not Equal"               },
    'when.eq'   =>  { type =>  'SKIP_R_R'  , opc => '11011100bbbbaaaa' , ps => \&ps_skip , name => "WHEN Equal"                   },

    #
    #  SKIP Ra IMM5
    #
    'skip.bs'   =>  { type =>  'SKIP_R_I'  , opc => '1101011bbbbbaaaa' , ps => \&ps_skip , name => "SKIP Bit Set"                 },
    'when.bc'   =>  { type =>  'SKIP_R_I'  , opc => '1101011bbbbbaaaa' , ps => \&ps_skip , name => "WHEN Bit Clear"               },

    'skip.bc'   =>  { type =>  'SKIP_R_I'  , opc => '1101111bbbbbaaaa' , ps => \&ps_skip , name => "SKIP Bit Clear"               },
    'when.bs'   =>  { type =>  'SKIP_R_I'  , opc => '1101111bbbbbaaaa' , ps => \&ps_skip , name => "WHEN Bit Set"                 }

  );

# add to HOH opcode table
@ops{keys %ops_skip} = values %ops_skip;


# SKIP parser
sub ps_skip
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $status;
    my $offset;
    my $bit_num;

    my $opcode = $ops{$operation}{opc};
    my $type   = $ops{$operation}{type};
    my $ra,$rb;

    #
    # update history flag
    #
    set_skip_flag();

    #
    # SKIP
    #
    if ( $type eq 'SKIP_0' )
      {
        # full opcode already defined, do nothing
        # FIXME: add error check that there are no operands
      }
    
    #
    # SKIP Ra   
    #
    elsif ( $type eq 'SKIP_R' )
      {
        $ra = check_data_register( $operands[0] );
        $opcode = stuff_op_field( $opcode, 'a', $ra );
      }

    #
    # SKIP #FLAG   
    #
    elsif ( $type eq 'SKIP_FLAG' )
      {

        # check if first operand is an immediate constant
        if($operands[0] =~ /^#(.+)$/) 
          { 
            ($status, $offset) = parse_expression($1);

            # check for valid flag index 
            if ( ( $offset > 15 ) || ( $offset < 0 ) )
              {
                do_error("Flag number out of range (0..15)");
                $offset = 0;
              }

            $bit_num = sprintf("%04b", $offset);

            if (D1) { printf $JNK_F ("flag number=%d   %s\n",  $offset, $bit_num  ); }
 
            $opcode = stuff_op_field( $opcode, 'a', $bit_num);
          }
        else 
          {
            do_error("Expecting Immediate Value");
          }

      }


    #
    # SKIP Ra, Rb
    #
    elsif  ( $type eq 'SKIP_R_R' )
      {
        $ra = check_data_register( $operands[0] );
        $rb = check_data_register( $operands[1] );

        $opcode = stuff_op_field( $opcode, 'a', $ra );
        $opcode = stuff_op_field( $opcode, 'b', $rb );
      }


    #
    # SKIP Ra, IMM5   
    #
    elsif  ( $type eq 'SKIP_R_I' )
      {
        $ra = check_data_register( $operands[0] );

        # check if second operand is an immediate constant
        if($operands[1] =~ /^#(.+)$/) 
          { 
            ($status, $offset) = parse_expression($1);

            # check for bit number out of range 
            if ( ( $offset > 31 ) || ( $offset < 0 ) )
              {
                do_error("Bit number out of range (0..31)");
                $offset = 0;
              }

            $bit_num = sprintf("%05b", $offset);

            if (D1) { printf $JNK_F ("skip bit number=%d   %s\n",  $offset, $bit_num  ); }
 
            $opcode = stuff_op_field( $opcode, 'a', $ra      );
            $opcode = stuff_op_field( $opcode, 'b', $bit_num );

          }
        else 
          {
            do_error("Expecting Immediate Value");
          }

      }

    else 
      {
       do_error("Internal Error - unknown type field in opcode table");
      }

    emit_op($opcode);
  }


#---------------------------------------------
# SPAM: spam.[and|xorn] IMM8{,LEN}
#
#
#---------------------------------------------
   
%ops_spam = 
  (
    'spam.and'  =>  { type => 'SPAM_AND'  , opc => '11110nnnmmmmmmmm' , ps => \&ps_spam , name => "Skip Propagate Against Mask, AND mode"  },
    'spam.xorn' =>  { type => 'SPAM_XORN' , opc => '11110nnnmmmmmmmm' , ps => \&ps_spam , name => "Skip Propagate Against Mask, XOR-Not mode"  }
  );


# add to HOH opcode table
@ops{keys %ops_spam} = values %ops_spam;

# ORR parser
sub ps_spam
  {
    my ( $pass      ) = shift;
    my ( $label     ) = shift;
    my ( $operation ) = shift;
    my ( @operands  ) = @_;

    my $opcode = $ops{$operation}{opc};
    my $type   = $ops{$operation}{type};

    my $length;
    my $length_bits;

    my $mask;
    my $mask_bits;

    my $status;


    # SPAM should follow a skip
    if ( !get_last_skip() )
      {
        do_error("SPAM instruction not preceded by a SKIP" );
      }

    if ( $type eq 'SPAM_AND' )
      {
        check_argument_count( $#operands, 1 );

        $operands[0] =~ /^#(.+)$/ or do_error("Expecting immediate skip mask");
        ($status, $mask) = parse_expression($1);

        $length = 7;
      }


    if ( $type eq 'SPAM_XORN' )
      {
        check_argument_count( $#operands, 2 );
                                                                        
        $operands[0] =~ /^#(.+)$/ or do_error("Expecting immediate skip mask");
        ($status, $mask)   = parse_expression($1);

        $operands[1] =~ /^#(.+)$/ or do_error("Expecting immediate skip mask length");
        ($status, $length) = parse_expression($1);

        # check for valid flag index 
        if ( ( $length > 8 ) || ( $length < 2 ) )
          {
            do_error("spam.xorn mask length out of range (2..8)");
            $length = 8;
          }

        $length = 8 - $length;
      }

    # check for mask out of range 
    if ( ( $mask > 255 ) || ( $mask < 0 ) )
      {
        do_error("Skip mask out of range (0..255)");
        $mask = $mask & 0xFF;
      }

    if ($pass == 2)
      {
        $mask_bits   = sprintf("%08b", $mask);
        $length_bits = sprintf("%03b", $length);

        $opcode = stuff_op_field( $opcode, 'm', $mask_bits );
        $opcode = stuff_op_field( $opcode, 'n', $length_bits );
      }

    emit_op($opcode);
  }


#
# return value for "require"
#
1;
