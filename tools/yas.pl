#! /usr/local/bin/perl5 

#-------------------------------------------------------------------------------
#
# YARD-1 Assembler
#
# Modifications for YARD-1 COPYRIGHT (C) 2000-2016  B. Davis
#
#   under the same license terms as the original risc8_asm (see below)
#
#
# Credits (see original headers below):
#
#  - initial version derived from S. Aravindhan's risc8_asm.pl v1.0
#
#  - label and dispatch code derived from Michael Martin's P65 assembler
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# Derived from S. Aravindhan's risc8_asm
#
#    The original website is gone, but archive is at:
#      http://web.archive.org/web/20020108154129/www.geocities.com/microprocessors/
#
# Original risc8_asm copyright notice:
#
#-------------------------------------------------------------------------------
#
#          (C) COPYRIGHT 2000 S.Aravindhan 
#
# This program is free software; you can redistribute it and/or
# modify it provided this header is preserved on all copies.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# 
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#
# Portions based on Michael Martin's P65 assembler
# Original P65 copyright notice:
#
#-------------------------------------------------------------------------------
#
# The P65 Assembler, v 1.1
# Copyright (c) 2001,2 Michael Martin
# All rights reserved.
#
# Redistribution and use, with or without modification, are permitted
# provided that the following conditions are met:
#
# - Redistributions of the code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# - The name of Michael Martin may not be used to endorse or promote
#   products derived from this software without specific prior written
#   permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------

my $help_notes = <<END_NOTES;

  General Notes:

  - simple two-pass absolute assembler

  - current implementation is missing many features
     - no constant expression parser
     - no macros

  - not much error checking yet
     - legal input lines assemble OK, illegal input lines may quietly fail

  - presently sufficient to support initial processor debug and verification, 
    and small assembly projects

  - assembler output files:
      - <file>.lst = listing file
      - <file>.obj = object file
      - <file>.vfy = verification file with address/reg/data info. from ".verify" pseudo-op
      - <file>.jnk = file with output of debug printfs (if debug flag is enabled)

END_NOTES

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

my $help_syntax=<<END_SYNTAX;

 Assembler Syntax:

  label:  operation  operand1, operand2   ; comment

  - comments are preceded by a semicolon; the rest of the line is ignored

  - labels must start in the first column, with an optional trailing colon
       label:  bra label

  - local labels start with '.' 
       local labels are internally prefixed with the last non-local label 
       to create a unique name in the symbol table

  - leading whitespace required before opcode mnemonic

  - multiple operands are comma separated 
       skip.bs  r0, #30

  - whitespace is NOT currently allowed _within_ each operand field
    whitespace is OK _between_ operand fields 

       mov r0, # 100  ; not allowed
       mov r0, #100   ; OK

       bra.d @ + 1024  ; not allowed
       bra.d @+1024    ; OK

  - immediate constants are prefixed with "#" 
    (uses # to identify immediate mode instead of mnemonic variants like add/addi)
       mov r0, #15
       skip.bs r1, #TX_FLAG_BIT

  - underscores are allowed in constants 

  - numerical constant radix: leading "\$" for hex ,"%" for binary, otherwise  decimal
       mov r0, #$8000_0000
       mov r0, #%1000_0000_0000_0000_0000_0000_0000_0000
       mov r0, #-2_147_483_648

  - character/string constants:  

      leading ' for immediate character byte
       mov r0, #'?

      enclose dc.s strings within " " 
       dc.s "hello"

  - simple constant expression parser supports only + and - 

    FIXME: verify previous limitations are gone:
       - kludge for bra targets allows @+offset or @-offset (for bra/bsr only)
       - unary minus works only for decimal constants

END_SYNTAX
#"

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------

my $help_bugs=<<END_BUGS;

 assembler known bug list:

  - error checking for illegal immediates:
      - error if shift/flip immediate field is out of range
      - error if imm12 out of range ( now silently masked )

  - character constant field doesn't accept spaces
        dc.b '    ; produces assembler error
END_BUGS
#'

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#
# assembler 'to do' list:
#
#  - implement all opcodes
#
#  - inline constant tables for LDI
#
#  - IMM built-in macro for constants
#
#  - automatic constants 
#      - generate two word prefixed sequences when needed:
#
#        OP  ra, #big_const  =>  LDI table.big_const    
#                                OP  ra,imm 
#                                ; add table entry
#
#        MEM ra, offset(rb)  =>  IMM12 off 
#                                MEM   ra, .imm(rb) 
#
#        LBRA label          =>  IMM12 label_offset>>9
#                                lbra  label_offset_LSbits
#
#     - prefix bubble for skip of an automatically prefixed instruction
#
#
#  - synthetic address modes ( PCR, ABSOLUTE ) using IMM/PC as base register
#
#  - label syntax (make colon optional, :: for globals?)
#
#  - clean up unneeded parsing on pass 1 
#
#  - other immediate constant improvements
#     - add unary "-" for hex, binary 
#         ( that "-" works for decimal is a fluke, extract_word thinks it's a label)
#      - add a constant expression parser { +, -, *, /, %, &, |, ^, ~, <<, >> }
#
#  - add simple preprocessor support (include, define, ifdef)
#
#  - macro support
#
#-------------------------------------------------------------------------------


#-------------------------------------------------------------
# directives and flags
#-------------------------------------------------------------
use strict;
#use integer;

# turn debug prints on or off here
use constant D1 => 1;

#-------------------------------------------------------------
# globals
#-------------------------------------------------------------

my $VERSION = "0.2-alpha";

#
# location counter
#
my $address;          
my $next_address;          
my $last_address;          

# skip/prefix flags
my $skip_flag;          
my $last_skip;          

#
# file related
#
my @source_filenames;

my $asm_filename;
my $obj_filename;
my $lst_filename;
my $vfy_filename;
my $jnk_filename;

my $ASM_F;
my $OBJ_F;
my $LST_F;
my $VFY_F;

our $JNK_F;   # debug prints in yas_tab need to see $JNK_F 

#
# status & counts
#
my $line_num;          

my $error_cnt;          
my $warn_cnt;          

my $pass;

#
# symbol table
#
my %labels = ();

#
# automatic imm label numbers
#
#  FIXME : add imms value handling routines to eliminate 'our'
#
our $imm_table_num;          
my  $imm_seq;          
our @imm_entries_used;          
our @imms;

#
# line parsing
#
my @words;

my $line;          
my $raw_line;          

my $label_prefix;
my $label_field;
my $operation_field;
my @operand_fields;

#
# need to define hashes to be initialized later within opcode table file 
#
our %addr_reg_map  = ();
our %data_reg_map  = ();
our %stack_reg_map = ();
our %ctl_reg_map   = ();
our %ops           = ();



#-------------------------------------------------------------
# return next imm label
#-------------------------------------------------------------
sub next_imm_label
{
  my $imm_label = 'I$' . $imm_seq;

  if (D1) { print $JNK_F ("next_imm_label() : $imm_label, $imm_seq\n"); }

  $imm_seq++;

  return( $imm_label );
}

#-------------------------------------------------------------
# dump immediate constant pool
#-------------------------------------------------------------
sub flush_imms
{
  my $label;
  my $duplicate;
  my $cstr;
  my $cdat;
  my @sorted_labels;

  #
  #  return here if there are no imms to dump in the current imm table 
  #  ( to prevent unnecessary aligns )
  #
  if ( $imm_entries_used[$imm_table_num] == 0 )
  {
    $imm_table_num++;          

    if ($pass == 1) 
    { 
      $imm_entries_used[$imm_table_num] = 0;
      $imms[$imm_table_num] = {};
    }

    if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

    return;
  }

  if (D1) { printf $JNK_F ("imm_seq: %d , table: %d, imm_entries_used[table]: %d\n", $imm_seq, $imm_table_num, $imm_entries_used[$imm_table_num] ); }

  #
  # align to quad word boundary
  #
  do_align(4);

  #
  # key sort
  #
  #   - primary sort by pass1_value 
  #     have to use pass1_value to avoid phasing errors due to sorted value list order changing on pass2
  #
  #   - secondary sort by pass1_known flag to avoid gaps in duplicated values
  #
  #   - tertiary sort by label name (case-insensitive)
  #
  @sorted_labels = sort {     $imms[$imm_table_num]{$a}{pass1_value} <=> $imms[$imm_table_num]{$b}{pass1_value}  
                          or  $imms[$imm_table_num]{$a}{pass1_known} <=> $imms[$imm_table_num]{$b}{pass1_known} 
                          or  lc($a) cmp lc($b) 
                        } keys($imms[$imm_table_num]) ;
 
  if (D1) { print $JNK_F ("flush_imms:\n"); }

  #
  # using an index for the loop so merge code can look ahead to the next entry
  #
  for my $i (0 .. $#sorted_labels ) 
    { 
      $label = $sorted_labels[$i];

      #
      # TESTME: set flag to merge identical values
      #   - merge by value if pass1 value is known
      #   - merge by expression string match if pass1 value is unknown 
      #
      if (    ( $i < $#sorted_labels ) 
           && (
                   ( 
                        ( $imms[$imm_table_num]{$label}{pass1_known} == 1 )
                     && ( $imms[$imm_table_num]{$label}{pass1_value} == $imms[$imm_table_num]{$sorted_labels[$i+1]}{pass1_value} ) 
                   )

                || (
                        ( $imms[$imm_table_num]{$label}{pass1_known} == 0 )
                     && ( $imms[$imm_table_num]{$label}{exp_str} eq $imms[$imm_table_num]{$sorted_labels[$i+1]}{exp_str} ) 
                   )
              )
         )

      {
        $duplicate = 1;
      }
      else
      {
        $duplicate = 0;
      }

      if (D1) { print $JNK_F ("  $label :   $imms[$imm_table_num]{$label}{value}   $duplicate   $imms[$imm_table_num]{$label}{pass1_known}\n"); }

      # generate label
      if ( $pass == 1 ) { init_label($label) };
      set_label($label, $address);

      if ($pass == 2) { printf $LST_F ("  %08X           %s:\n", $address, $label); }

      if ( !$duplicate )
      {
        if ($pass == 2)
          {
           # force constant to 32 bits 
           $cdat = $imms[$imm_table_num]{$label}{value} & 0xffffffff;

           $cstr = sprintf "%08X", $cdat;
           printf $OBJ_F ("quad=%s\n", $cstr);

           printf $LST_F ("  %08X  %s       \n", $address  , substr($cstr,0,4) );
           printf $LST_F ("  %08X  %s       \n", $address+2, substr($cstr,4,4) );
          }

        $address = $address + 4;
      }
      
    }

  $next_address = $address;

  $imm_table_num++;          

  if ($pass == 1) 
  { 
    $imm_entries_used[$imm_table_num] = 0;
    $imms[$imm_table_num] = {};
  }

}


#-------------------------------------------------------------
# return current address
#  ( needed by relative branch parser in target specific code)
#-------------------------------------------------------------
sub get_address
{
  return($address);
}

#-------------------------------------------------------------
# return skip flag
#  ( needed by SPAM parser in target specific code)
#-------------------------------------------------------------
sub get_last_skip
{
  return($last_skip);
}

#-------------------------------------------------------------
# set skip flag
#  ( called by opcode parsers in target specific code)
#-------------------------------------------------------------
sub set_skip_flag
{
  $skip_flag = 1;
}

#-------------------------------------------------------------
# error message
#-------------------------------------------------------------
sub do_error
{
  my ( $msg ) = @_;

  printf        ("Error: %s [%s:%d] : %s\n", $msg, $asm_filename, $line_num, $raw_line);
  printf $LST_F ("Error: %s [%s:%d] : %s\n", $msg, $asm_filename, $line_num, $raw_line) if ($pass == 2); 

  $error_cnt++;
}


#-------------------------------------------------------------
# warning message
#-------------------------------------------------------------
sub do_warn
{
  my ( $msg ) = @_;

  printf        ("Warning: %s [%s:%d] : %s\n", $msg, $asm_filename, $line_num, $raw_line);
  printf $LST_F ("Warning: %s [%s:%d] : %s\n", $msg, $asm_filename, $line_num, $raw_line) if ($pass == 2); 

  $warn_cnt++;
}

#-------------------------------------------------------------
# Check for valid number of arguments for an instruction  
#-------------------------------------------------------------
sub check_argument_count 
{
  my ($tmp1, $tmp2) = @_;

  if ( ( $tmp1 + 1 )  != $tmp2) 
    {
      do_error("Invalid number of arguments");
    }
}

#-------------------------------------------------------------
# Check for valid data register 
#-------------------------------------------------------------
sub check_data_register 
{
  my ($reg) = lc shift;

  my $rbits = $data_reg_map{$reg};

  if ( $rbits )
    {
      return $rbits;
    }
  else
    {
      do_error("Invalid data register \"" . $reg . "\"");
      return '0000';
    }
}

#-------------------------------------------------------------
# Check for valid address register 
#-------------------------------------------------------------
sub check_addr_register 
{
  my ($reg) = lc shift;

  my $rbits = $addr_reg_map{$reg};

  if ( $rbits )
    {
      return $rbits;
    }
  else
    {
      do_error("Invalid address register \"" . $reg . "\"");
      return '0000';
    }
}

#-------------------------------------------------------------
# Check for valid control register 
#-------------------------------------------------------------
sub check_ctl_register 
{
  my ($reg) = lc shift;

  my $rbits = $ctl_reg_map{$reg};

  if ( $rbits )
    {
      return $rbits;
    }
  else
    {
      do_error("Invalid control register \"" . $reg . "\"");
      return '0000';
    }
}

#-------------------------------------------------------------
# Label code (adopted from P65)
#-------------------------------------------------------------
sub label_exists 
{
  my $label = shift;

  # fixup prefix if a local label
  if ($label  =~ /^\./) {$label = $label_prefix . $label;} 

#  $label = lc $label;
  return ((exists $labels{$label}) || ($label eq "@"));
}

#
#
#
sub label_value 
{
  my $label = shift;

  # fixup prefix if a local label
  if ($label  =~ /^\./) 
    {
      $label = $label_prefix . $label; 
      if (D1) { print  $JNK_F ("prefixed local label: $label\n" ); }  
    } 

  if ($label eq "@") 
    { 
      return $address;  
    } 

  else 
    {
#        $label = lc $label;
      return $labels{$label};
    }
}

#
# set_label is used by "equ" directive to overwrite the original label value
#
sub set_label 
{
  my ($label, $value) = @_;

#    $label = lc $label;
  $labels{$label} = $value;
}

#
#
#
sub init_label 
{
  my $label = shift;

#    $label = lc $label;

  if (label_exists($label)) 
    {
      do_error("Duplicate label definition: '$label'");

      #
      # special case, print label error to list file here because init_label 
      # is only called on pass 1, but do_error prints to LST_F only during pass 2
      #
      printf $LST_F ("Error: Duplicate label definition: '$label' at line %d: %s\n", $line_num, $raw_line); 

    }
  set_label($label, 0);
}


#
# process_label called by line parser for label fields
#
# global variable usage:
#
#   use:
#      $address 
#
#   use/modify: ( used elsewhere in parsing )
#      $label_field 
#      $label_prefix
#
#
sub process_label
{

  # remove any trailing ':'
  if ($label_field  =~ /:$/) 
    {
      chop $label_field;
    }

  # TODO: remove/substitute illegal characters in label name
  if ( $label_field =~ tr/_.0-9A-Za-z//cd ) 
    {
      do_error("Illegal characters in label name");
    }

  # local label : add prefix to label
  if ($label_field  =~ /^\./) 
    {
      $label_field = $label_prefix . $label_field; 
    } 

  # normal label : set prefix
  else
    {
      $label_prefix = $label_field;
    }

  if ( $pass == 1 ) { init_label($label_field) };
  set_label($label_field, $address);
}


#
# needed for 64 bit perl : force value to 32 bits before %08x sprintf to prevent string field overflow
#
sub mask_val_str
{
  my ( $val ) = shift;

  my $val_mask;
  my $val_str;

  $val_mask = $val & 0xffffffff;
  $val_str  = sprintf "%08X", $val_mask;

  return $val_str;

}

#-------------------------------------------------------------
#
# Extract value of constant/label 
#   returns 
#     ( 0, integer )        for constant or defined label
#     ( 2, name_string )    for undefined label
#
#-------------------------------------------------------------
sub extract_word
{
  my ($tmp) = @_; 

  if (D1) { print $JNK_F ("extract_word input = $tmp\n");  }

  #
  # leading $ for hex
  #
  if ($tmp =~ /^\$(.+)$/)   
    {
      $tmp = $1;
      $tmp =~ s/_//g; # strip underscores
      $tmp = oct ("0x" . $tmp);  
      if (D1) { printf $JNK_F ("extract_word hex = 0x%lx\n", $tmp); }
      if (D1) { print  $JNK_F ("extract_word hex, native = $tmp\n" ); } 
      return (0, $tmp);
    }

  #
  # alternate leading 0x for hex
  #
  elsif ($tmp =~ /^0x(.+)$/)   
    {
      $tmp = $1;
      $tmp =~ s/_//g; # strip underscores
      $tmp = oct ("0x" . $tmp);  
      if (D1) { printf $JNK_F ("extract_word hex = 0x%lx\n", $tmp); }
      if (D1) { print  $JNK_F ("extract_word hex, native = $tmp\n" ); } 
      return (0, $tmp);
    }

  #
  # leading % for binary
  #
  elsif ($tmp =~ /^%(.+)$/)  
    {
      $tmp = $1;
      $tmp =~ s/_//g;  # strip underscores
      $tmp = "0" x (32 - length($tmp))  . $tmp; # pad bit string to 32 characters
      if (D1) { printf $JNK_F ("extract_word padded string (bin)=%s\n", $tmp ); }
      $tmp =  vec( pack("B*", $tmp), 0, 32);  # convert 32 bit binary string to integer
      if (D1) { printf $JNK_F ("extract_word bin = 0x%lx\n", $tmp ); }
      if (D1) { print  $JNK_F ("extract_word bin, native= $tmp\n" ); }
      return (0, $tmp);
    }

  #
  # leading ' for ASCII character
  #
  #  FIXME: doesn't work for space /' / due to parser split-on-spaces- use raw line?
  #
  elsif($tmp =~ /^\'(.+)$/)  
    {
      $tmp = ord($1);
      if (D1) { printf $JNK_F ("extract_word character = 0x%lx\n", $tmp ); }
      return (0, $tmp);
    }

  #
  # no prefix, check for decimal 
  #
  elsif ($tmp =~ /^([0-9_\-]+)$/)  
    {
      # check for leading '-' here, set sign flag
      $tmp = $1;
      $tmp =~ s/_//g;  # strip underscores
      if (D1) { printf $JNK_F ("extract_word dec = 0x%lx\n", $tmp);  }
      if (D1) { print  $JNK_F ("extract_word dec, native= $tmp\n" ); }  
      return (0, $tmp);
    }

  #
  # look for a label
  #
  elsif ( label_exists($tmp) ) 
    { 
      $tmp = label_value($tmp);
      if (D1) { printf $JNK_F ("extract_word label=%d\n", $tmp); }
      return (0, $tmp);
    }

  else 
    {
      if (D1) { printf $JNK_F ("extract_word illegal constant or undefined label=%s\n", $tmp); }
      if ($pass == 2) { do_error("Illegal constant or undefined label"); }
      return (2,$tmp);
    }

}

#
# rudimentary expression parser:  a {+/- b} {+/- c} ...
#
# splits input string on +/-, calling extract_word for each argument
#
# returns 
#   ( 0, integer )      for fully defined expression
#   ( 2, name_string )  if undefined label encountered
#
sub parse_expression
{
  my ($exp) = @_; 
  my $code;
  my $value;

  my $op  = '+';
  my $sum = 0;

  my @args;

  if (D1) { printf $JNK_F ("exp: $exp\n"); }

  #
  # split pattern returns alternating array of ( {match}, value, match, value )
  # if leading operator, then match will be first
  #
  @args   = split(/(\+|-)/, $exp); 

  foreach my $arg (@args)
    {
      if ( ($arg eq '-') || ( $arg eq '+' ) )
        {
          $op = $arg;
          if (D1) { printf $JNK_F ("exp.op: $arg\n"); }
        }

      elsif ( $arg ne '' )
        {
          ($code, $value) = extract_word($arg);

          if (D1) { printf $JNK_F ("exp.dat  :$arg :$code :$value\n"); }

          if ( $code == 0 )
            {
              if ( $op eq '+' )
                {
                  $sum = $sum + $value;
                }
              elsif ( $op eq '-' )
                {
                  $sum = $sum - $value;
                }
            }
          else
            {
              return($code,$value);  # return unknown label
            }
        }
    }

  if (D1) { printf $JNK_F ("exp.sum  :$sum :$code\n"); }
  return($code,$sum);
}

# 
# output prefix to both listing and object files
#
#  - assumes 16 bit opcodes
#
sub emit_prefix
{
  my ($prefix) = @_; 

  my $op16;

  if ( $last_skip )
    {
      do_error("Attempt to skip a prefixed opcode (prefix bubble not implemented yet)");
    }

  if ($pass == 2)  
    {
      if ( ( $address % 2 ) > 0 )
        {
          do_error("Unaligned prefix address");
        }

      if (length($prefix) != 16) 
        {
          do_error("Internal error - illegal prefix width");
        }

      $op16 = vec(pack("B16", $prefix),0,16);

      printf $OBJ_F ("op16=%04X\n", $op16);
      printf $LST_F ("  %08X  %04X  +  \n", $address, $op16);
    }

  $next_address = $address + 2;

  #
  # history updates for prefix also bump current address
  #
  $last_address = $address;
  $address      = $next_address;

}


# 
# output opcode to both listing and object files
#
#  - assumes 16 bit opcodes
#
sub emit_op 
{
  my ($op) = @_; 

  my $op16;

  if ($pass == 2)  
    {
      if ( ( $address % 2 ) > 0 )
        {
          do_error("Unaligned opcode address");
        }

      if (length($op) != 16) 
        {
          do_error("Internal error - illegal opcode width");
        }

      $op16 = vec(pack("B16", $op),0,16);

      printf $OBJ_F ("op16=%04X\n", $op16);
      printf $LST_F ("  %08X  %04X     %s\n", $address, $op16, $raw_line);
    }

  $next_address = $address + 2;

  #
  # history updates moved here to emit_op() so they reflect the last emitted opcode
  # done to avoid problems caused by blank lines/directives/etc
  #
  $last_address = $address;
  $last_skip = $skip_flag;

}



#
# directive hash
#  for use with new directive dispatch code 
#
my %directive_defs =
(
  'org'        =>  { type => 'DIRECTIVE' , ps => \&ps_org,       name => "ORiGin",     blab => "location counter set to address N"  },
  '.org'       =>  { type => 'DIRECTIVE' , ps => \&ps_org,       name => ".ORiGin",    blab => "location counter set to address N"  },

  'align'      =>  { type => 'DIRECTIVE' , ps => \&ps_align,     name => "ALIGN",      blab => "location counter forced to next modulo N byte boundary"  },
  '.align'     =>  { type => 'DIRECTIVE' , ps => \&ps_align,     name => ".ALIGN",     blab => "location counter forced to next modulo N byte boundary"  },

  '.common'    =>  { type => 'DIRECTIVE' , ps => \&ps_common,    name => ".COMMON",    blab => "common block:  label .common size, alignment"  },

  'end'        =>  { type => 'DIRECTIVE' , ps => \&ps_end,       name => "END",        blab => "end assembly"  },
  '.end'       =>  { type => 'DIRECTIVE' , ps => \&ps_end,       name => ".END",       blab => "end assembly"  },

  'equ'        =>  { type => 'DIRECTIVE' , ps => \&ps_equ,       name => "EQUate",     blab => "equate symbol = value"  },
  '.equ'       =>  { type => 'DIRECTIVE' , ps => \&ps_equ,       name => ".EQUate",    blab => "equate symbol = value"  },

  '.imm_table' =>  { type => 'DIRECTIVE' , ps => \&ps_imm_table, name => ".IMM_TABLE", blab => "generate immediate table"  },

  '.global'    =>  { type => 'DIRECTIVE' , ps => \&ps_global,    name => ".GLOBAL",    blab => "stub: .global directive"  },
  '.local'     =>  { type => 'DIRECTIVE' , ps => \&ps_local,     name => ".LOCAL",     blab => "stub: .local directive"  },
                                                                                     
  '.section'   =>  { type => 'DIRECTIVE' , ps => \&ps_section,   name => ".SECTION",   blab => "stub: .section control directive"  },
                                                                                     
  '.set'       =>  { type => 'DIRECTIVE' , ps => \&ps_set,       name => ".SET",       blab => "stub: assembler settings"  },

  '.type'      =>  { type => 'DIRECTIVE' , ps => \&ps_type,      name => ".TYPE",      blab => "stub: object type"  },
  '.size'      =>  { type => 'DIRECTIVE' , ps => \&ps_size,      name => ".SIZE",      blab => "stub: object size"  },
                                                                                    
  '.verify'    =>  { type => 'DIRECTIVE' , ps => \&ps_verify,    name => ".VERIFY",    blab => "{ reg,value | pass | fail } : writes condition to .vfy file for simulation"  },

  '.error'     =>  { type => 'DIRECTIVE' , ps => \&ps_error,     name => ".ERROR",     blab => "user error message"  },
  '.warn'      =>  { type => 'DIRECTIVE' , ps => \&ps_warn,      name => ".WARN",      blab => "user warning message"  },


   'ds.b'      =>  { type => 'DIRECTIVE' , ps => \&ps_ds_b,      name => "DS.B",       blab => "Define Storage, Byte : location counter advanced by size argument"  },

);

sub ps_org
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  check_argument_count($#operands, 1);

  ($status, $arg ) = extract_word($operands[0]);

  if ( $arg < 0 )
    {
      do_error("negative values not allowed for org directive");
      $arg = 0;
    }

  $address      = $arg;
  $next_address = $arg;

  if ($pass == 2)
    {
      printf $OBJ_F ("@%X\n", $address);
      printf $LST_F ("  %08X           %s\n", $address, $raw_line );
    }

}

sub do_align
{
  my ( $align ) = shift;

  $address = int ( ( $address + $align - 1) / $align ) * $align;
  $next_address = $address;

  if ($pass == 2)
    {
      printf $OBJ_F ("@%X\n", $address);
      printf $LST_F ("  %08X           %s\n", $address, $raw_line );
    }
}

sub ps_align
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $align;
  my $status;

  check_argument_count($#operands, 1);
  ($status, $align ) = extract_word($operands[0]);

  if ( $align <= 0 )
    {
      do_error("align directive requires a positive, non-zero argument");
      $align = 1;
    }

  do_align($align);

}

sub ps_common
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $align;
  my $size;
  my $status;

  check_argument_count($#operands, 2);
  ($status, $size )  = extract_word($operands[0]);
  ($status, $align ) = extract_word($operands[1]);

  if ( $size <= 0 )
    {
      do_error(".common alignment,size  requires a positive, non-zero size");
      $size = 1;
    }

  if ( $align <= 0 )
    {
      do_error(".common alignment,size  requires a positive, non-zero alignment");
      $align = 1;
    }

  #
  # adjust address, next_address for alignment and size
  #
  $address = int ( ( $address + $align - 1) / $align ) * $align;
  $next_address = $address + $size;

  #
  # TODO: add to symbol info hash (once it exists)
  #

  #
  # update label value
  #
  if ( $label_field )
    {
      set_label($label_field, $address); 
    }
  else 
    {
      do_error(".common directive requires a label on the same line");
    }


  if ($pass == 2)
    {
      printf $LST_F ("  %08X           %s\n", $address, $raw_line );

      # new object file address starts *after* common block
      printf $OBJ_F ("@%X\n", $next_address);   
    }
}

sub ps_end
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  # flush any remaining imms
  flush_imms();

  # removed, directive line is printed in flush_imms()
  #  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

  last;
}

sub ps_equ
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $val;
  my $status;

  check_argument_count($#operands, 1);

  ($status, $val ) = extract_word($operands[0]);

  if (D1) { printf $JNK_F ("equate  %s = %x\n", $label, $val ); } 

  set_label($label, $val); 

  if ( $pass == 2 )
    {
      printf $LST_F ("  %s           %s\n", mask_val_str(label_value($label)), $raw_line );
    }
}

sub ps_imm_table
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  flush_imms();
}

sub ps_global
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: stub for .global directive
  #
  do_warn("directive stub: .global not implemented yet");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}

sub ps_local
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: stub for .local directive
  #
  do_warn("directive stub: .local not implemented yet");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}

sub ps_section
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: stub for .section directive
  #
  do_warn("directive stub: .section not implemented yet");

  if ($pass==2) { printf $LST_F ("  %08X           %s\n", $address, $raw_line ); }

}

sub ps_set
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: stub for .set directive
  #
  do_warn("directive stub: .set not implemented yet");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}

sub ps_type
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: stub for .type directive
  #
  do_warn("directive stub: .type not implemented yet");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}

sub ps_size
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: stub for .size directive
  #
  do_warn("directive stub: .size not implemented yet");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}


sub ps_ds_b
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $status;
  my $size;

  check_argument_count($#operands, 1);
  ($status, $size) = extract_word($operands[0]);

  if ( ($status != 0 ) || ( $size < 0 ) )
  {
    do_error("ds.b directive requires a non-negative size");
    $size = 0;
  }

  $next_address = $address + $size;

  if ($pass == 2)
    {
      printf $LST_F ("  %08X           %s\n", $address, $raw_line );

      # new object file address starts *after* common block
      printf $OBJ_F ("@%X\n", $next_address);   
    }

}


sub ps_verify
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $reg;
  my $val;

  my $status;
  my $count;

#
# TODO: factor out count checking into common subroutine
#
# added parsing of optional verify count field
#
# defaults:
#     FAIL -1
#     PASS  1
#     REG   1
#

  if( lc($operands[0]) eq "pass")
    {
      if ($pass == 2)
        {
          # check for optional count
          if( ! $operands[1] )
            {
              $count = 1;
            }

          elsif($operands[1] =~ /^#(.+)$/) 
            { 
              ($status, $count) = extract_word($1);
  
              if ($status != 0 )
                {
                  do_error("Undefined immediate constant");
                  $count = 1;
                }
            }

          else
            {
              do_error("Expecting immediate constant");
              $count = 1;
            } 

          printf $LST_F ("                     %s\n", $raw_line);

          printf $VFY_F ("[%s:%d] %08x PASS %d\n", $asm_filename, $line_num, $last_address, 1 );
          if (D1) { printf JNK_F (".vpass: addr = %08x\n", $last_address ); }
        } 

    } 

  elsif(lc($operands[0]) eq "fail")
    {
      if ($pass == 2)
        {
          # check for optional count
          if( ! $operands[1] )
            {
              $count = -1;
            }

          elsif($operands[1] =~ /^#(.+)$/) 
            { 
              ($status, $count) = extract_word($1);
  
              if ($status != 0 )
                {
                  do_error("Undefined immediate constant");
                  $count = 0;
                }

            }

          else
            {
              do_error("Expecting immediate constant");
              $count = -1;
            } 

          printf $LST_F ("                     %s\n", $raw_line);

          printf $VFY_F ("[%s:%d] %08x FAIL %d\n", $asm_filename, $line_num, $last_address, $count );
          if (D1) { printf JNK_F (".vfail: addr = %08x\n", $last_address ); }
        } 
    } 

  else
    {
      #check_argument_count($#operands, 2);
      check_data_register($operands[0]);

      if ($pass == 2)
        {
          # check if opb is an immediate constant
          if($operands[1] =~ /^#(.+)$/) 
            { 
              ($status, $val) = extract_word($1);
  
              if ($status != 0 )
                {
                  do_error("Undefined immediate constant");
                  $val = 0;
                }

            }

          else
            {
              do_error("Expecting immediate constant");
              $val = 0;
            } 

          # check for optional count
          if( ! $operands[2] )
            {
              $count = 1;
            }
          elsif($operands[2] =~ /^#(.+)$/) 
            { 
              ($status, $count) = extract_word($1);
  
              if ($status != 0 )
                {
                  do_error("Undefined immediate constant");
                  $count = 1;
                }

            }

          else
            {
              do_error("Expecting immediate constant");
              $count = 1;
            } 

          printf $LST_F ("                     %s\n", $raw_line);

          printf $VFY_F   ("[%s:%d] %08x REG %d %s %s\n", $asm_filename, $line_num, $last_address, $count,  $operands[0], mask_val_str($val) );

          if (D1) { printf $JNK_F (".verify: addr, count, reg, value = %08x, %d, %s, %08x, %s\n", $last_address, $count, $operands[0], $val, mask_val_str($val) ); }

        } 
    } 
}


sub ps_error
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: parse user error string from raw line and include it in the error message
  #
  do_error("User error");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}

sub ps_warn
{
  my ( $pass      ) = shift;
  my ( $label     ) = shift;
  my ( $operation ) = shift;
  my ( @operands  ) = @_;

  my $arg;
  my $status;

  #
  # TODO: parse user warning string from raw line and include it in the warning message
  #
  do_warn("User warning");

  if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line ); }

}


#                 
# old-style directives using original parser fields
#                 
my %old_directive_defs = 
(
  "dc.s"    => { type => 'DIRECTIVE' },
  "dc.z"    => { type => 'DIRECTIVE' },
  "dc.b"    => { type => 'DIRECTIVE' },
  "dc.w"    => { type => 'DIRECTIVE' },
  "dc.q"    => { type => 'DIRECTIVE' },
);

#                 
# old directives parser
#
# TODO: rewrite like opcode hash using a few 
# parsing subroutines instead of big if-elsif
#
sub parse_directive
{
  my $status;
  my $off;

  my $i;
  my $b1;

  my @stringy;
  my @bytes;
  my $bcount;

  my $lstr;


  #----------------------------------------
  # temp code, stuff old word/start fields until old if-else code completely gone

  my @word;
  my $start;

  @word  = split(/\s+/, $line); 
  shift @word;
  $start = 0;

  if (D1)
   {
     printf $JNK_F ("\$\#word, (word) : %d %s %s %s\n",$#word,$word[0],$word[1],$word[2]);
   }


  #----------------------------------------


  # dc.s, dc.z
  if( ($word[$start] eq "dc.s") || ($word[$start] eq "dc.z") )

    {
      if($word[$start+1] =~ /^\"/) 
        {
          @stringy = split "\"", $raw_line;
          @bytes = unpack ("C*", $stringy[1]);

          if ($word[$start] eq "dc.z")
            {
              @bytes = (@bytes, 0);
            }

          if (D1) { printf $JNK_F ("dc.s loop bounds=%d  %d\n", 0, $#bytes ); }

          for($i=0; $i <= $#bytes; $i++ ) 
            {
              if ($pass == 2)
                {
                  printf $OBJ_F ("byte=%02X\n", $bytes[$i]);
                  printf $LST_F ("  %08X  %02X       %s\n", $address, $bytes[$i], $i==0 ? $raw_line : "");
                }
              $address = $address + 1;
            } 

          $next_address = $address;
        }

      else 
        { 
          do_error("Expecting \" ");
        } 
    }

  # dc.b
  elsif($word[$start] eq "dc.b")
    {
      $bcount = $#word - ($start+1) + 1;

      if (D1) { printf $JNK_F ("dc.b loop bounds=%d  %d\n", 0, $bcount-1 ); }

      for($i=0; $i <= $bcount-1 ; $i++ ) 
        {
          ($status, $b1) = extract_word($word[$start+1+$i]);

          # check for field overflow
          if ( ($b1 > 255) || ( $b1 < -128 ) ) { do_warn("dc.b constant out of range, masked to 8 bits"); }

          # force to 8 bits 
          $b1 = $b1 & 0xff;

          if ($pass == 2)
            {
              printf $OBJ_F ("byte=%02X\n", $b1);
              printf $LST_F ("  %08X  %02X       %s\n", $address, $b1, $i==0 ? $raw_line : "");
            }
          $address = $address + 1;
        } 

      $next_address = $address;
    }

  # dc.w
  elsif($word[$start] eq "dc.w")
    {
      if (D1) { printf $JNK_F ("dc.w loop bounds=%d  %d\n", $start+1, $#word); }

      if ( ( $address % 2 ) > 0 )
        {
          do_warn("Unaligned dc.w");
        }

      for($i=$start+1; $i <= $#word; $i = $i+1) 
        {
          ($status, $off) = extract_word($word[$i]);

          # check for field overflow
          if ( ($off > 65535) || ( $off < -32768 ) ) { do_warn("dc.w constant out of range, masked to 16 bits"); }

          # force to 16 bits 
          $off = $off & 0xffff;

          if ($pass == 2)
            {
              printf $OBJ_F ("wyde=%04X\n", $off);
              printf $LST_F ("  %08X  %04X     %s\n", $address, $off, $i==$start+1 ? $raw_line : "");
            }
          $address = $address + 2;
        } 

      $next_address = $address;
    }
  
  # dc.q
  elsif($word[$start] eq "dc.q")
    {
      if (D1) { printf $JNK_F ("dc.q loop bounds=%d  %d\n", $start+1, $#word); }

      if ( ( $address % 4 ) > 0 )
        {
          do_warn("Unaligned dc.q");
        }

      for($i=$start+1; $i <= $#word; $i = $i+1) 
        {
          ($status, $off) = extract_word($word[$i]);

          # check for field overflow
          if ( ($off > 4294967295 ) || ( $off < -2_147_483_648) ) { do_warn("dc.q constant out of range, masked to 32 bits"); }

          # force to 32 bits 
          $off = $off & 0xffffffff;

          if ($pass == 2)
            {
              $lstr = mask_val_str($off);
              printf $OBJ_F ("quad=%s\n", $lstr );

              printf $LST_F ("  %08X  %s     %s\n", $address  , substr($lstr,0,4), $i==$start+1 ? $raw_line : "");
              printf $LST_F ("  %08X  %s       \n", $address+2, substr($lstr,4,4), );
            }
          $address = $address + 4;
        } 
      $next_address = $address;
    }

}


# 
# parse command line args
#
sub parse_args 
{
  my $asm_arg;

  my $output_base_filename  = "";

  my $found_output_name = 0;
  my $found_asm         = 0;
  my $k                 = 0;


  my $usage = "\nUsage: yas.pl {-h|--help} {-o|--output output_base_filename} asm_file_name[.s|.asm] {another_asm_file[.s|.asm]}\n";
  
  my $help2 = "
  Additional help options : 
    --help_notes     general notes
    --help_syntax    assembler syntax
    --help_bugs      list known bugs 

  ";
  
  my $examples = "Examples:
    yas.pl -h 
    yas.pl math.asm
    yas.pl -o math math_equates.s math.s math_subs.s \n";

  my $error1 = "
  Usage: Missing assembly file \n";

  my $error2 = "
  Usage: Missing output base filename\n";


  if ( ($ARGV[0] eq "-h") || ($ARGV[0] eq "--help") || ($#ARGV < 0) )
    { die $usage.$help2.$examples; }


  if ( $ARGV[0] eq "--help_notes"  )   { die $help_notes;   }
  if ( $ARGV[0] eq "--help_syntax" )   { die $help_syntax; } 
  if ( $ARGV[0] eq "--help_bugs"   )   { die $help_bugs;   }

  while($k <= $#ARGV) 
    {

      if ( ( $ARGV[$k] eq "-o" ) || ( $ARGV[$k] eq "--output" ) )
        {
          if($#ARGV < ($k +1)) { die $error2.$usage.$examples;}
          $output_base_filename = $ARGV[$k+1]; 
          $k=$k+2; 
          $found_output_name = 1;
        }

      else
        {
          $asm_arg = $ARGV[$k];
          $k++;
          $found_asm++;

          push @source_filenames, $asm_arg;
        }

    }

  if($found_asm == 0) {die $error1.$usage.$examples;}

  # use output base name if specified, otherwise use last asm file as base name
  if (!$found_output_name)
    {
      $output_base_filename = $asm_arg;   
      $output_base_filename =~ s/\.asm$//gi;   # strip .asm, if specified
      $output_base_filename =~ s/\.s$//gi;     # strip .s, if specified
    }

  $obj_filename = $output_base_filename . '.obj';
  $lst_filename = $output_base_filename . '.lst';
  $vfy_filename = $output_base_filename . '.vfy';
  $jnk_filename = $output_base_filename . '.jnk';


  # open files
  #
  # input files now opened in main loop
  # output files :
  #
  open($OBJ_F, ">$obj_filename") or die "Can't open $obj_filename: $!\n";
  open($LST_F, ">$lst_filename") or die "Can't open $lst_filename: $!\n";
  open($VFY_F, ">$vfy_filename") or die "Can't open $vfy_filename: $!\n";
  open($JNK_F, ">$jnk_filename") or die "Can't open $jnk_filename: $!\n";

}

# 
# dump opcode/directive parsing hashes to junk file
#
#  called by main routine when D1 debug flag is set
#
sub dump_op_hashes
{

   # opcode hash
   printf $JNK_F ( "\nHOH opcode keys:\n\n");

   foreach my $op ( sort keys(%ops) )  
     { 
       printf $JNK_F ( "%16s   %12s   %s\n", $ops{$op}{opc}, $op, $ops{$op}{name} ); 
     }
   printf $JNK_F ( "\n\n");

   # directive hash
   printf $JNK_F ( "\nHOH directive keys:\n\n");

   foreach my $op ( sort keys(%directive_defs) )  
     { 
       printf $JNK_F ( "%16s   %12s   %s\n", $directive_defs{$op}{type}, $op, $directive_defs{$op}{name} ); 
     }
   printf $JNK_F ( "\n\n");

   # old-style-parser directive hash
   printf $JNK_F ( "\nold directive keys:\n");

   foreach my $op ( sort keys(%old_directive_defs) )  
     { 
       printf $JNK_F ( "%s   %s\n", $old_directive_defs{$op}{type}, $op); 
     }
   printf $JNK_F ( "\n");

}


#-------------------------------------------------------------
# main
#-------------------------------------------------------------

print "\nYARD-1 Assembler Version $VERSION\n";


# initialize opcode parse tables
require("yard-1_tab.pl");

parse_args();

if (D1) { dump_op_hashes(); }

# write version header to object file
printf $OBJ_F ("# generated by yas.pl version $VERSION\n");

#--------------------------
# Parse the assembly file 
#--------------------------

$error_cnt = 0;
$warn_cnt  = 0;
$pass = 1;


while( $pass <= 2 )
  {
    printf("\nPass %d\n\n",$pass);  

    #
    # start of pass initialization
    #
    $address      = 0;
    $next_address = 0;

    $skip_flag = 0;
    $last_skip = 0;

    $label_prefix = '';

    $imm_seq       = 0;          
    $imm_table_num = 0;          

    if ($pass == 1) 
    { 
      $imm_entries_used[$imm_table_num] = 0;
      $imms[$imm_table_num] = {};
    }


    if (D1) { print $JNK_F ("\n\nPass = $pass, IMM Table Number, entries used = $imm_table_num , $imm_entries_used[$imm_table_num] \n\n"); }

    #
    # file loop 
    #
    foreach my $filename (@source_filenames)
      {
        my $ext;

           $ext = ''     , open($ASM_F, "$filename$ext" ) 
        or $ext = '.s'   , open($ASM_F, "$filename$ext" ) 
        or $ext = '.asm' , open($ASM_F, "$filename$ext" ) 

        or die "Can't open $filename: $!\n" ;

        $asm_filename = $filename . $ext;

        #
        #rewind input file
        #
        seek($ASM_F, 0, 0);  
        $line_num = 0;

        #
        # process all lines
        #
        while ($line = <$ASM_F>)
          {
            $line_num++;

            #
            # update state variables
            # last_xxx history updates moved to emit_op()
            #
            $address   = $next_address;
            $skip_flag = 0;

            #
            # process next line
            #
            chomp $line;
            $raw_line = $line;      # save the original line 

            $line =~ s/;.*//;       # strip the comments 
            $line =~ s/,/ /g;       # convert commas to spaces ( for operand field separators )    

            if ($line =~ /^\s*$/ ) # empty line
              {
                if ($pass==2) { printf $LST_F ("                     %s\n", $raw_line); }
                next;
              } 

            if (D1) 
              {
                printf $JNK_F ("\nlast address, address, next_address = %08x, %08x, %08x\n", $last_address,$address,$next_address); 
                printf $JNK_F ("Stripped line: %s\n",$line);
              }

            #
            # this split pattern creates an empty match (label placeholder) 
            # when there's leading whitespace on the line
            #
            @words   = split(/\s+/, $line); 

            $label_field     = shift @words;
            $operation_field = lc shift @words;
            @operand_fields  = @words;

            if (D1) { print $JNK_F ("new parse- label_field, operation_field, operand_fields : $label_field, $operation_field, @operand_fields\n"); }

            # handle any label 
            if ($label_field) { process_label(); }


            #
            # new HOH dispatch
            #
            if ( $operation_field )
              {
                if ( exists $ops{$operation_field}{ps}  )
                  {
                    if (D1) { printf $JNK_F ("HOH op dispatch : %s \n",$ops{$operation_field}{type} ) };
                    if (D1) { printf $JNK_F ("HOH parse: opcode %s is type %s  op %s\n", $operation_field, $ops{$operation_field}{type}, $ops{$operation_field}{opc}, $ops{$operation_field}{ps}  ); }
                    &{ $ops{$operation_field}{ps} }($pass, $label_field, $operation_field, @operand_fields);
                  }

                elsif ( exists $directive_defs{$operation_field}{ps}  )
                  {
                    if (D1) { printf $JNK_F ("HOH directive dispatch : %s \n",$directive_defs{$operation_field}{type} ) };
                    &{ $directive_defs{$operation_field}{ps} }($pass, $label_field, $operation_field, @operand_fields);
                  }

                elsif ( exists $old_directive_defs{$operation_field} )
                  {
                    if (D1) { printf $JNK_F ("old directive dispatch : %s \n",$old_directive_defs{$operation_field}{type} ) };
                    parse_directive();
                  }

                else
                  {
                    if (D1) { printf $JNK_F ("HOH dispatch : no match\n" ) };
                    do_error("Unrecognized instruction or directive \"" . $operation_field . "\"" );
                    printf LST_F ("                     %s\n", $raw_line);
                  }
              }

            else  # there was only a label on the line, dump it to the listing
              {
                if ($pass == 2) { printf $LST_F ("  %08X           %s\n", label_value($label_field), $raw_line ); }
                next; 
              }

          } # end while ( line )

        close $ASM_F;

      } # end for ( file )

    $pass++;

  } # end while( pass )

#
##
## FIXME: temporary code
##        dump automatic imm table
#
#printf $LST_F ( "\n\nIMM table (by value):\n\n"); 
# FIXME: now also need to loop over $imm_table_num
#foreach my $label ( sort { $imms[$i]{$a}{value} <=> $imms[$i]{$b}{value}  or  lc($a) cmp lc($b) } keys(%imms[$i]) )
#  { printf $LST_F ( "  %s: %08X\n", $label, $imms[$i]{$label}{value} ) }; 
#

#
# dump symbol table by name
#
printf $LST_F ( "\n\nSymbols (by name):\n\n"); 

foreach my $label ( sort { lc($a) cmp lc($b) } keys(%labels) )  
  { printf $LST_F ( "  %s  %s\n",mask_val_str(label_value($label)), $label); }

#
# dump symbol table by value
#
printf $LST_F ( "\n\nSymbols (by value):\n\n"); 

foreach my $label ( sort { $labels{$a} <=> $labels{$b}  or  lc($a) cmp lc($b) } keys(%labels) )
  { printf $LST_F ( "  %s  %s\n",mask_val_str(label_value($label)), $label); }

#
# report status
#
printf("\nTotal Warnings = %d\n", $warn_cnt);
printf(  "Total Errors   = %d\n", $error_cnt);

printf $LST_F ("\nTotal Warnings = %d\n", $warn_cnt);
printf $LST_F (  "Total Errors   = %d\n", $error_cnt);

#
# tidy up
#
close $OBJ_F;
close $LST_F;
close $VFY_F;
close $JNK_F;


exit( $error_cnt > 0 );
