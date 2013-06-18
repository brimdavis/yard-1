-- 
-- <pcr_calc.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2012-2013  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A PC Relative address calculations
--
--   - now used only for return address calculations
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity pcr_calc is

  port
    (   
      dcd_call       : in  std_logic;

      dslot_null     : in  std_logic;
      pc_reg_p1      : in  std_logic_vector(PC_MSB downto 0);
    
      pcr_addr       : out std_logic_vector(ALU_MSB downto 0)
    );

end pcr_calc;


architecture arch1 of pcr_calc is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal pc_p1_ext   : std_logic_vector(ALU_MSB downto 0);
  signal pcr_offset  : std_logic_vector(ALU_MSB downto 0);

begin

  --
  -- return address calculation:
  --   add 2 ( one instruction  ) when dslot_null = 1  ( return to instruction in delay slot )
  --   add 4 ( two instructions ) when dslot_null = 0  ( return to instruction after delay slot )
  --
  pcr_offset <= ( ALU_MSB downto 3 => '0' ) & (NOT dslot_null) & dslot_null  & '0'
    when  dcd_call = '1'

    else  ( others => '0')
    ;


  pc_p1_ext <= ( ALU_MSB downto PC_MSB+1 => '0') & pc_reg_p1(PC_MSB downto 0);


  --
  -- PC Relative adder
  --
  pcr_addr  <=  pcr_offset + pc_p1_ext;

end arch1;




