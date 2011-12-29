-- 
-- <ld_mux.vhd>
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
-- Y1A byte/wyde/quad sign extending lane mux for loads
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity ld_mux is
  generic
    (
      CFG       : y1a_config_type
    );

  port
    (   
      inst_fld   : in  std_logic_vector(ID_MSB downto 0);
      mem_size   : in  std_logic_vector(1 downto 0);
      mem_sign   : in  std_logic;

      ea_dat     : in  std_logic_vector(ALU_MSB downto 0);

      d_rdat     : in  std_logic_vector(ALU_MSB downto 0);

      mem_wb_bus : out std_logic_vector(ALU_MSB downto 0)
    );

end ld_mux;


architecture arch1 of ld_mux is

  -- byte/wyde lane shifters
  signal byte_dat : std_logic_vector( 7 downto 0);
  signal wyde_dat : std_logic_vector(15 downto 0);

  -- sign/zero extension
  signal byte_ext : std_logic;
  signal wyde_ext : std_logic;



begin

  --
  -- check for illegal config/ALU width settings
  --
  assert ( CFG.non_native_load AND ( ALU_WIDTH = 32 ) ) OR ( NOT CFG.non_native_load )
    report "Unsupported load configuration flag and/or ALU_WIDTH settings."
    severity error;


  --
  --
  --
  GF_cnnl: if cfg.non_native_load = FALSE generate
    begin

      mem_wb_bus <=  d_rdat when ( inst_fld = OPM_LD ) OR ( inst_fld = OPM_LDI ) 
                else ( others => '0' );

    end generate GF_cnnl;

 
  --
  --
  --
  GT_cnnl: if ( alu_width = 32 ) and ( cfg.non_native_load = TRUE ) generate
    begin
  
      --
      -- byte lane mux
      --
      with ea_dat(0) select
        byte_dat <= 
          wyde_dat(15 downto  8)  when '0',
          wyde_dat( 7 downto  0)  when '1',
          ( others => 'X')        when others;

      --
      -- byte sign or zero extension
      --
      byte_ext <=  byte_dat(7) when mem_sign = '1' 
              else '0';

      --
      -- wyde (16 bit) lane mux
      --
      wyde_dat <=  d_rdat(31 downto 16)  when ( ea_dat(1) = '0' ) 
              else d_rdat(15 downto 0);

      --
      -- wyde (16 bit) sign or zero extension
      --
      wyde_ext <=  wyde_dat(15) when mem_sign = '1' 
              else '0';

      mem_wb_bus 
        --
        -- quad (32 bit) load
        --
        <=    d_rdat              
        when   ( ( inst_fld = OPM_LD  ) AND ( ( mem_size = MEM_32 ) OR  ( mem_size = MEM_32_SP ) ) )  
             OR  ( inst_fld = OPM_LDI )
        --
        -- wyde (16 bit) load
        --
        else  ( ALU_MSB downto 16 => wyde_ext ) & wyde_dat(15 downto 0)   
        when  ( inst_fld = OPM_LD ) AND (mem_size = MEM_16 ) 

        --
        -- byte load
        --
        else  ( ALU_MSB downto 8 => byte_ext ) & byte_dat(7 downto 0)
        when  ( inst_fld = OPM_LD ) AND (mem_size = MEM_8 ) 

        else  ( others => 'X' );

    end generate GT_cnnl;
  

end arch1;
