-- 
-- <st_mux.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2011  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A byte/wyde/quad lane mux for databus stores                                                                
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

      ain        : in  std_logic_vector(ALU_MSB downto 0);

      d_wdat    : out std_logic_vector(ALU_MSB downto 0)
    );

end st_mux;


architecture arch1 of st_mux is


begin

  gen_dat: if CFG.native_store_only = TRUE generate                                           
    begin                                                                                     
                                                                                              
      d_wdat  <= ain                                                                           
          when     ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') )                              
          else ( others => '0');                                                              
                                                                                              
    end generate gen_dat;                                                                     
                                                                                              
  gen_dat32: if ( ALU_WIDTH = 32 ) and ( CFG.native_store_only = FALSE ) generate            
    begin                                                                                    
                                                                                              
      d_wdat  <=                                                                             
        ain                                                                                   
          when ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( ( mem_size = MEM_32 ) OR ( mem_size = MEM_32_SP ) ) else  
                                                                                              
        ain(15 downto 0) & ain(15 downto 0)                                                    
          when ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( mem_size = MEM_16 ) else  
                                                                                              
        ain(7 downto 0) & ain(7 downto 0) & ain(7 downto 0) & ain(7 downto 0)                    
          when ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( mem_size = MEM_8 )  else  

        ( others => '0');                                                                    
                                                                                              
    end generate gen_dat32;                                                                  

  --
  -- TODO: error on illegal config/ALU width generate settings
  --

end arch1;
