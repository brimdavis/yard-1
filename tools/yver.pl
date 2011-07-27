#! /usr/local/bin/perl5 

#-------------------------------------------------------------------------------
# YARD-1 verify 
#
#   parses .vfy file, checks that sim output matches
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# Copyright (c) 2000-2011, B. Davis
#
# released under the "new BSD" license, see license/new_bsd.txt
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# Limitations & Bugs:
#
#   - only one verify directive allowed per address
#
#   - confused by pipeline load stalls, need to monitor stall bit
#     workaround: stick NOP between load and verify in test code
#
#-------------------------------------------------------------------------------

my $VERSION = "0.0.2-alpha";


#
# should have three arguments: the verify file, the sim file, the output file
#
if ($#ARGV != 2) { die ("\nUsage: verify yourfile{.vfy} yourfile{.out} yourfile{.vrf}\n") };

#
# fixup any missing file extensions
#
$vfy = $ARGV[0];  
$vfy =~ s/\.vfy$//g;
$vfy_file = $vfy . '.vfy';

$sim = $ARGV[1];  
$sim =~ s/\.out$//g;
$sim_file = $sim . '.out';

$vrf = $ARGV[2];  
$vrf =~ s/\.vrf$//g;
$vrf_file = $vrf . '.vrf';

#
# open files
#
open (VFY_F,  "$vfy_file") or die ("Can't open $vfy_file: $!\n");
open (SIM_F,  "$sim_file") or die ("Can't open $sim_file: $!\n");
open (VRF_F, ">$vrf_file") or die ("Can't open $vrf_file: $!\n");

#
printf VRF_F ("\nYARD-1 Verify $VERSION\n\n");

# $D1 turns debug prints on/off
$D1 = 0;


# clear other flags
$errors = 0;

#
# Read .vfy file, build associative arrays for address matching
#
 while ($line = <VFY_F>)
   {
     chop $line; 

     @rec = split " ", $line;

     $address = oct ( "0x" . $rec[1] );

     $line_num{$address} = $rec[0];
     $type{$address}     = $rec[2];
     $reg{$address}      = $rec[3];
     $value{$address}    = $rec[4];
     $valid{$address}    = 1;

     if ($D1) { printf ("%08x %s %s %s \n", $address, $line_num{$address}, $reg{$address}, $value{$address}) };

   } # end while

#
# debug - print keys
#
if ($D1) {  foreach $address ( sort keys(%line_num) )  { printf ( "  %s  %08x %d\n",$line_num{$address}, $address, $valid{$address}); } }

#
# wade through the sim file, looking for address matches
#
 $matched = 0;
 %sim_regs = ( "r0" => 0, "r1" => 0, "r2" => 0, "r3" => 0, 
               "r4" => 0, "r5" => 0, "r6" => 0, "r7" => 0, 
               "r8" => 0, "r9" => 0, "r10"=> 0, "r11"=> 0, 
               "r12"=> 0, "r13"=> 0, "r14"=> 0, "r15"=> 0 );

 while ($line = <SIM_F>)
   {
     chop $line; 

     #
     # look for address match
     #
     if ( $line =~ /pc_reg_p1=([0-9a-fA-F]+)/ )
       {

         $address = oct("0x" . $1);

         if ($valid{$address})
           {
             $matched = 1;
             $v_addr  = $address;
             $v_type  = $type{$address};
             $v_reg   = $reg{$address};
             $v_line_num = $line_num{$address};
             $v_value = oct( "0x" . $value{$address} );

             if ($D1) { printf VRF_F ("Matched: %08x %s %s %08x \n", $address, $v_line_num, $v_reg, $v_value); }
           }
       }

     #
     # look for register file dump
     #
     elsif ( $line =~ /Register File/ )
       {

           $reg_line = <SIM_F>;
           chop $reg_line; 
           @words = split " ", $reg_line;

           $sim_regs{"r0"} = oct("0x" . $words[0]);
           $sim_regs{"r1"} = oct("0x" . $words[1]);
           $sim_regs{"r2"} = oct("0x" . $words[2]);
           $sim_regs{"r3"} = oct("0x" . $words[3]);
           $sim_regs{"r4"} = oct("0x" . $words[4]);
           $sim_regs{"r5"} = oct("0x" . $words[5]);
           $sim_regs{"r6"} = oct("0x" . $words[6]);
           $sim_regs{"r7"} = oct("0x" . $words[7]);

           $reg_line = <SIM_F>;
           chop $reg_line; 
           @words = split " ", $reg_line;

           $sim_regs{"r8"} = oct("0x" . $words[0]);
           $sim_regs{"r9"} = oct("0x" . $words[1]);
           $sim_regs{"r10"}= oct("0x" . $words[2]);
           $sim_regs{"r11"}= oct("0x" . $words[3]);
           $sim_regs{"r12"}= oct("0x" . $words[4]);
           $sim_regs{"r13"}= oct("0x" . $words[5]);
           $sim_regs{"r14"}= oct("0x" . $words[6]);
           $sim_regs{"r15"}= oct("0x" . $words[7]);

       }

     #
     # at the end of a clock cycle, see if we matched a verify address
     #
     elsif ( $line =~ /^----/ )
       {
         if ( $matched )
           {
             $matched = 0;

             if ( $v_type eq 'REG'  )
               {
                 if ( $sim_regs{$v_reg} == $v_value )
                   {
                     printf VRF_F (" Passed test @ %08x   %s\n", $address, $v_line_num );
                   }
                 else
                   {
                     $errors++;
                     printf VRF_F (" Failed test @ %08x   %s\n", $address, $v_line_num );
                     printf VRF_F ("   Expecting %s = %08x, was %08x\n", $v_reg,$v_value, $sim_regs{$v_reg} );
                   }
               }
 
             elsif ( $v_type eq 'FAIL' ) 
               {
                 $errors++;
                 printf VRF_F (" Failed test @ %08x   %s\n", $address, $v_line_num );
               }
 
             elsif ( $v_type eq 'PASS' ) 
               {
                 printf VRF_F (" Passed test @ %08x   %s\n", $address, $v_line_num );
               }
 
             else
               {
                 $errors++;
                 printf VRF_F (" Unrecognized verify directive @ %08x   %s\n", $address, $v_line_num );
               }
           
              
           }
       }

   } # end while



#
# tidy up
#
 close VFY_F;
 close SIM_F;

 printf VRF_F ("\nTotal Errors = %d\n", $errors);

 exit( $error_cnt > 0 );





