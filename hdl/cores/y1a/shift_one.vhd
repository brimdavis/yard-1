-- 
-- <shift_one.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2012  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A simple shifter, one bit shifts only
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
      ireg       : in  std_logic_vector(INST_MSB downto 0);

      ain          : in  std_logic_vector(ALU_MSB downto 0);

      shift_dat    : out std_logic_vector(ALU_MSB downto 0)
    );

end shift_one;


architecture arch1 of shift_one is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal shift_msb : std_logic;
  signal shift_lsb : std_logic;

  --
  --
  --
  alias shift_grp    : std_logic is ireg(11);
  alias shift_signed : std_logic is ireg(10);
  alias shift_dir    : std_logic is ireg( 9);

begin

  shift_msb  <=  ( ain(ALU_MSB) AND shift_signed )        
            when (shift_grp = '0') AND (shift_dir = '0')  -- LSR and ASR

            else ain(0);                                  -- ROR as default


  shift_lsb  <=   '0'                                    
            when  (shift_grp = '0') AND (shift_dir = '1') -- LSL

            else  ain(ALU_MSB);                           -- ROL as default

     
  shift_dat  <=   shift_msb & ain(ALU_MSB downto 1)      
            when  (shift_dir = '0')                       -- LSR/ASR/ROR

            else  ain(ALU_MSB-1 downto 0) & shift_lsb;    -- LSL/ROL as default

end arch1;
