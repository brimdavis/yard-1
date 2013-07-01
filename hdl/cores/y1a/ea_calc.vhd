-- 
-- <ea_calc.vhd>
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
-- Y1A effective address calculation
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;

  -- pragma translate_off
  use work.y1a_probe_pkg.all;
  -- pragma translate_on


entity ea_calc is

  port
    (   
      dcd_LDI      : in boolean;
      dcd_mode_SP  : in boolean;
      dcd_src_mux  : in boolean;

      mem_mode     : in std_logic;
                     
      sp_offset    : in std_logic_vector( 3 downto 0);
      ldi_offset   : in std_logic_vector(11 downto 0);

      bin          : in  std_logic_vector(ALU_MSB downto 0);
      imm_reg      : in  std_logic_vector(ALU_MSB downto 0);

      pc_reg_p1    : in  std_logic_vector(PC_MSB downto 0);
    
      ea_dat       : out std_logic_vector(ALU_MSB downto 0)
    );

end ea_calc;


architecture arch1 of ea_calc is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal ea_off_mux   : std_logic_vector(ALU_MSB downto 0);

  signal pc_p1_masked : std_logic_vector(ALU_MSB downto 0);

begin

  --
  -- mux ea offset sources
  --
  ea_off_mux <=  

          ( ALU_MSB downto 14 => '0') & ldi_offset & B"00" 
    when  dcd_LDI  

    else  ( ALU_MSB downto  6 => '0') & sp_offset  & B"00" 
    when  dcd_mode_SP  -- AND ( NOT dcd_LDI )                              -- moved LDI ahead in priority to remove AND term

    else  imm_reg                                
    when  ( mem_mode  = '1' )  -- AND ( NOT ( dcd_mode_SP OR dcd_LDI ) )   -- moved LDI and dcd_mode_SP ahead in priority to remove AND term

    else  ALU_ZERO
    ;  
 
 
  --
  -- LSB's of PC zeroed for LDI quad aligned addressing
  --
  pc_p1_masked <= 
          ( ALU_MSB downto PC_MSB+1 => '0') & pc_reg_p1(PC_MSB downto 2)  & B"00" 
    when  dcd_LDI 

    else  ( ALU_MSB downto PC_MSB+1 => '0') & pc_reg_p1(PC_MSB downto 0)
    ;


  --
  -- merge bin mux with adder to shorten critical path
  --
  ea_dat  <=  ea_off_mux + pc_p1_masked  when dcd_src_mux
         else ea_off_mux + bin;         


  ------------------------------------------------------------------------------
  --
  -- drive simulation probe signals 
  --
  ------------------------------------------------------------------------------

  -- pragma translate_off

  ea_prb : block
    begin

      y1a_probe_sigs.ea_off_mux <= ea_off_mux;

    end block ea_prb;

  -- pragma translate_on
 
end arch1;

