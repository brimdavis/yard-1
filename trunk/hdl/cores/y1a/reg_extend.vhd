-- 
-- <reg_extend.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2013  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A register-register byte/wyde moves with sign or zero extension
--
-- modified version of memory load mux, not shared with mem to avoid adding
-- another mux to the mem load critical path
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity reg_extend is
  generic
    (
      CFG       : y1a_config_type
    );

  port
    (   
      dcd_wyde  : in std_logic;

      mem_sign  : in std_logic;
      mem_size  : in std_logic_vector(1 downto 0);

      din       : in  std_logic_vector(ALU_MSB downto 0);
                  
      ext_out   : out std_logic_vector(ALU_MSB downto 0)
    );

end reg_extend;


architecture arch1 of reg_extend is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;


  --
  -- msb fill for sign/zero extension
  --
  signal msb_fill : std_logic;


begin


  --
  -- msb fill for sign/zero extension
  --
  msb_fill <=  '0'      when  mem_sign = '0'
          else din(15)  when  dcd_wyde = '1'
          else din( 7)  
           ;

  --
  -- byte lane 3 (MSB)
  --
  ext_out(31 downto 24) <= ( others => msb_fill );

  --
  -- byte lane 2 
  --
  ext_out(23 downto 16) <= ( others => msb_fill );

  --
  -- byte lane 1 mux
  --
  ext_out(15 downto 8)  <=  din(15 downto  8)      when  dcd_wyde = '1'
                       else ( others => msb_fill )     
                        ;

  --
  -- LS byte always populated with input data
  --
  ext_out(7 downto 0) <= din( 7 downto  0);


end arch1;
