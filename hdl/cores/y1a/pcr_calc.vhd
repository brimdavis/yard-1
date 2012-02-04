-- 
-- <pcr_calc.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2012  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A PC Relative address calculations
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;

  use work.y1a_probe_pkg.all;


entity pcr_calc is

  port
    (   
      inst_fld       : in  std_logic_vector(ID_MSB downto 0);
      sel_opb        : in  std_logic_vector(3 downto 0);

      dslot          : in  std_logic;

      call_type      : in  std_logic;
      ext_bit        : in  std_logic;
      ext_grp        : in  std_logic_vector(3 downto 0);

      ldi_offset     : in  std_logic_vector(11 downto 0);

      pc_reg_p1      : in  std_logic_vector(PC_MSB downto 0);
    
      pcr_addr       : out std_logic_vector(ALU_MSB downto 0)
    );

end pcr_calc;


architecture arch1 of pcr_calc is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal pc_p1_masked   : std_logic_vector(ALU_MSB downto 0);
  signal pcr_off_mux    : std_logic_vector(ALU_MSB downto 0);
  signal ea_pc_lsbs     : std_logic_vector(1 downto 0);

  signal dcd_LDI     : boolean;
  signal dcd_CALL    : boolean;

begin

  --
  -- instruction decodes
  --
  dcd_LDI  <= ( inst_fld = OPM_LDI );

  dcd_CALL <= (
                    ( (inst_fld = OPC_EXT) AND (ext_bit = '1' ) AND ( ext_grp = EXT_JUMP ) )
                OR  ( inst_fld = OPC_BR )
              )
              AND ( call_type = '1' );


  --
  -- mux pcr offset sources
  --
  pcr_off_mux <=  
 
          ( ( ALU_MSB downto 14 => '0') & ldi_offset & B"00" )  
    when  dcd_LDI

    --
    -- return address calculation:
    --   add 2 when dslot = 0
    --   add 4 when dslot = 1
    --
    else  ( ALU_MSB downto 3 => '0' ) & dslot & (NOT dslot) & '0'
    when  dcd_CALL

    else  ( others => '0')
    ;


  --
  -- LSB's of PC zeroed for LDI quad aligned addressing
  --
  ea_pc_lsbs   <= B"00" when dcd_LDI else pc_reg_p1(1 downto 0);

  pc_p1_masked <= ( ALU_MSB downto PC_MSB+1 => '0') & pc_reg_p1(PC_MSB downto 2)  & ea_pc_lsbs;
--    when  dcd_LDI OR ( ( sel_opb = REG_PC ) AND ( NOT dcd_SP ) )


  --
  -- PC Relative adder
  --
  pcr_addr  <=  pcr_off_mux + pc_p1_masked;


end arch1;
