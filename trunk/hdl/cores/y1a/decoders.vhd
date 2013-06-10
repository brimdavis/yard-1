-- 
-- <decoders.vhd>
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
-- Y1A instruction decoders
--
--  various instruction decoder components, collected in one file
--


------------------------------
-- stall_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity stall_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk          : in  std_logic;
      sync_rst     : in  std_logic;

      i_dat        : in  std_logic_vector(INST_MSB downto 0);
      d_stall      : in  std_logic;

      dcd_stall    : out boolean
    );

end stall_dcd;


architecture arch1 of stall_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  attribute syn_keep : boolean;

  --
  -- instruction register
  --
  signal ireg        : std_logic_vector(INST_MSB downto 0);

  signal stall       : boolean;
  attribute syn_keep of stall : signal is TRUE;

  --
  -- instruction fields
  --
  alias inst_fld     : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);

begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif NOT stall then
      ireg  <= i_dat;

    end if;

  end process;


  dcd_stall <=  ( d_stall = '1' ) AND ( (inst_fld = OPM_LD ) OR (inst_fld = OPM_LDI ) );


end arch1;


------------------------------
-- ld_mux_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity ld_mux_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk          : in  std_logic;
      sync_rst     : in  std_logic;

      i_dat        : in  std_logic_vector(INST_MSB downto 0);
      stall        : in  boolean;

      dcd_mem_sign : out std_logic;

      dcd_quad_ld  : out boolean;
      dcd_wyde_ld  : out boolean;
      dcd_byte_ld  : out boolean
    );

end ld_mux_dcd;


architecture arch1 of ld_mux_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  --
  -- instruction register
  --
  signal ireg        : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction fields
  --
  alias inst_fld     : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  alias mem_size     : std_logic_vector(1 downto 0)          is ireg(10 downto 9);
  alias mem_sign     : std_logic                             is ireg(8);


begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif NOT stall then
      ireg  <= i_dat;

    end if;

  end process;


  --
  -- instruction decodes
  --
  dcd_quad_ld  <=       ( inst_fld = OPM_LDI ) 
                  OR  ( ( inst_fld = OPM_LD  ) AND ( ( mem_size = MEM_32 ) OR  ( mem_size = MEM_32_SP ) ) );

  dcd_wyde_ld  <= ( inst_fld = OPM_LD ) AND ( mem_size = MEM_16 );

  dcd_byte_ld  <= ( inst_fld = OPM_LD ) AND ( mem_size = MEM_8 );


  dcd_mem_sign <= mem_sign;

end arch1;

------------------------------
-- st_mux_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity st_mux_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk          : in  std_logic;
      sync_rst     : in  std_logic;

      i_dat        : in  std_logic_vector(INST_MSB downto 0);
      stall        : in  boolean;

      dcd_st       : out boolean;
      dcd_st32     : out boolean;
      dcd_st16     : out boolean;
      dcd_st8      : out boolean
    );

end st_mux_dcd;


architecture arch1 of st_mux_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  --
  -- instruction register
  --
  signal ireg        : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction fields
  --
  alias inst_fld     : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  alias mem_size     : std_logic_vector(1 downto 0)          is ireg(10 downto 9);
  alias lea_bit      : std_logic                             is ireg(8);


begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif NOT stall then
      ireg  <= i_dat;

    end if;

  end process;

  --
  -- instruction decodes
  --
  dcd_st   <=  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') );                                                                                                       
  dcd_st32 <=  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( ( mem_size = MEM_32 ) OR ( mem_size = MEM_32_SP ) );
  dcd_st16 <=  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( mem_size = MEM_16 );
  dcd_st8  <=  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND ( mem_size = MEM_8 );

end arch1;

