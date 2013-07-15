-- 
-- <shift_one.vhd>
-- 
-- FIXME: change the name of this module, since it now supports some two-bit operations
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2013  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A simple shifter 
--   - one bit LSR/ASR/ROR
--   - two bit LSL/ROL
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity shift_one is

  port
    (   
      shift_grp    : in  std_logic;
      shift_signed : in  std_logic;
      shift_dir    : in  std_logic;
      shift_const  : in  std_logic_vector(4 downto 0);

      ain          : in  std_logic_vector(ALU_MSB downto 0);

      shift_dat    : out std_logic_vector(ALU_MSB downto 0)
    );

end shift_one;


architecture arch1 of shift_one is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal shift_msb  : std_logic;
  signal shift1_lsb : std_logic;
  signal shift2_lsb : std_logic;

begin

  shift_msb  <=  ( ain(ALU_MSB) AND shift_signed )        
            when (shift_grp = '0') AND (shift_dir = '0')              -- LSR and ASR

            else ain(0);                                              -- ROR as default


  shift1_lsb <=   '0'                                    
            when  (shift_grp = '0') AND (shift_dir = '1')             -- LSL

            else  ain(ALU_MSB);                                       -- ROL as default

  shift2_lsb <=   '0'                                    
            when  (shift_grp = '0') AND (shift_dir = '1')             -- LSL

            else  ain(ALU_MSB-1);                                     -- ROL as default

     
  shift_dat  <=   shift_msb & ain(ALU_MSB downto 1)      
            when  (shift_dir = '0')                                   -- LSR/ASR/ROR

            else  ain(ALU_MSB-2 downto 0) & shift1_lsb & shift2_lsb   -- LSL/ROL 
            when  (shift_dir = '1') AND ( shift_const = B"0_0010")    -- shift by two

            else  ain(ALU_MSB-1 downto 0) & shift1_lsb                -- LSL/ROL as default
--          when  (shift_dir = '1') AND ( shift_const = B"0_0001")    -- shift by one (default, 'when' commented out)
            ;

end arch1;
