-- 
-- <st_mux.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2011  Brian Davis
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
--      quad    A31                     ..                    A0
--
--      wyde    A15        ..        A0   A15       ..        A0
--
--      byte    A7  ..  A0   A7  ..  A0   A7  ..  A0  A7  ..  A0
--                                                    
--                                                    
--   Where:
--     An = register data bit ain(n)
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
      inst_fld  : in  std_logic_vector(ID_MSB downto 0);
      mem_size  : in  std_logic_vector(1 downto 0);
      lea_bit   : in  std_logic;

      ain       : in  std_logic_vector(ALU_MSB downto 0);

      d_wdat    : out std_logic_vector(ALU_MSB downto 0)
    );

end st_mux;


architecture arch1 of st_mux is


begin

  --
  -- check for illegal config/ALU width settings
  --
  assert ( CFG.non_native_store AND ( ALU_WIDTH = 32 ) ) OR ( NOT CFG.non_native_store )
    report "Unsupported store configuration flag and/or ALU_WIDTH settings."
    severity error;


  --
  -- non-native stores disabled: memory write bus driven directly from ain
  --
  GF_cnns: if NOT CFG.non_native_store generate                                           
    begin                                                                                     
                                                                                              
      d_wdat  <= ain                                                                           
          when     ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') )                              
          else ( others => '0');                                                              
                                                                                              
    end generate GF_cnns;                                                                     

  --
  -- non-native stores enabled: fill all memory write bus lanes with the desired field
  --
  GT_cnns: if ( ALU_WIDTH = 32 ) and ( CFG.non_native_store ) generate            
    begin                                                                                    
                                                                                              
      d_wdat  <=                                                                             
        ain                                                                                   
          when ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( ( mem_size = MEM_32 ) OR ( mem_size = MEM_32_SP ) ) else  
                                                                                              
        ain(15 downto 0) & ain(15 downto 0)                                                    
          when ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( mem_size = MEM_16 ) else  
                                                                                              
        ain(7 downto 0) & ain(7 downto 0) & ain(7 downto 0) & ain(7 downto 0)                    
          when ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( mem_size = MEM_8 )  else  

        ( others => '0');                                                                    
                                                                                              
    end generate GT_cnns;

end arch1;
