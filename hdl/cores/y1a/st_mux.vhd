-- 
-- <st_mux.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2014  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A byte/wyde/quad lane mux for data bus stores                                                                
--
--   replicates byte/wyde register fields across all lanes of the
--   memory data bus as needed, based upon store operand size:
--
--
--      bus     D31 ... D24  D23 ... D16  D15 ... D8  D7 ...  D0
--      ---------------------------------------------------------
--      quad    R31                    ...                    R0
--
--      wyde    R15       ...        R0   R15      ...        R0
--
--      byte    R7 ...  R0   R7 ...  R0   R7 ...  R0  R7 ...  R0
--                                                    
--                                                    
--   Where:
--     Rn = register data bit ain(n)
--     Dn = memory bus data bit d_wdat(n)
--
--   Note, byte lane write enables are asserted only for active lanes
--         see <dbus_ctl.vhd> 
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity st_mux is
  generic
    (
      CFG       : y1a_config_type
    );

  port
    (   
      dcd_sstk  : in  boolean;

      dcd_st    : in  boolean;
      dcd_st32  : in  boolean;
      dcd_st16  : in  boolean;
      dcd_st8   : in  boolean;

      ain       : in  std_logic_vector(ALU_MSB downto 0);
      rsp_pc    : in  std_logic_vector(PC_MSB downto 0);

      d_wdat    : out std_logic_vector(ALU_MSB downto 0)
    );

end st_mux;


architecture arch1 of st_mux is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

begin

  --
  -- check for illegal config/ALU width settings
  --
  assert ( CFG.isa.non_native_store AND ( ALU_WIDTH = 32 ) ) OR ( NOT CFG.isa.non_native_store )
    report "Unsupported store configuration flag and/or ALU_WIDTH settings."
    severity error;

  --
  -- non-native stores disabled: memory write bus driven directly from ain
  --
  GF_cnns: if NOT CFG.isa.non_native_store generate                                           
    begin                                                                                     
                                                                                              
      d_wdat
        <=   ain               
        when dcd_st

        else ( ALU_MSB downto PC_MSB+1 => '0') & rsp_pc(PC_MSB downto 0)
        when dcd_sstk

        else ( others => '0')
        ;                                                              
                                                                                              
    end generate GF_cnns;                                                                     

  --
  -- non-native stores enabled: fill all memory write bus lanes with the desired field
  --
  GT_cnns: if ( ALU_WIDTH = 32 ) and ( CFG.isa.non_native_store ) generate            
    begin                                                                                    
                                                                                              
      d_wdat  
        <=   ain                                                                                   
        when dcd_st32

        else ain(15 downto 0) & ain(15 downto 0)                                                    
        when dcd_st16

        else ain(7 downto 0) & ain(7 downto 0) & ain(7 downto 0) & ain(7 downto 0)
        when dcd_st8

        else ( ALU_MSB downto PC_MSB+1 => '0') & rsp_pc(PC_MSB downto 0)
        when dcd_sstk

        else ( others => '0')
        ;
                                                                                              
    end generate GT_cnns;

end arch1;
