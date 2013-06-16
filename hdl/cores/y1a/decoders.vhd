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

      inst         : in  std_logic_vector(INST_MSB downto 0);
      d_stall      : in  std_logic;

      dcd_stall    : out std_logic
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

  signal stall       : std_logic;
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

    elsif stall = '0' then
      ireg  <= inst;

    end if;

  end process;

  --
  -- internal copy of stall
  --
  stall     <=   '1'  when ( d_stall = '1' ) AND ( (inst_fld = OPM_LD ) OR (inst_fld = OPM_LDI ) )
            else '0';

  --
  -- connect to output port
  --
  dcd_stall <= stall;

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

      inst         : in  std_logic_vector(INST_MSB downto 0);
      stall        : in  std_logic;

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

    elsif stall = '0' then
      ireg  <= inst;

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

      inst         : in  std_logic_vector(INST_MSB downto 0);
      stall        : in  std_logic;

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

    elsif stall = '0' then
      ireg  <= inst;

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


------------------------------
-- rstack_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity rstack_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk          : in  std_logic;
      sync_rst     : in  std_logic;

      inst         : in  std_logic_vector(INST_MSB downto 0);
      stall        : in  std_logic;

      ex_null      : in  std_logic;
      irq_edge     : in  std_logic;

      dcd_push     : out std_logic;
      dcd_pop      : out std_logic 

    );

end rstack_dcd;


architecture arch1 of rstack_dcd is

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
  alias ext_bit      : std_logic                             is ireg(11);
  alias ext_grp      : std_logic_vector(3 downto 0)          is ireg(7 downto 4);
  alias call_type    : std_logic                             is ireg(10);


begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif stall = '0' then
      ireg  <= inst;

    end if;

  end process;



  dcd_push <= '1'
    when (
           (
                 ( (inst_fld = OPC_EXT) AND (ext_bit = '1' ) AND ( ext_grp = EXT_JUMP ) )
             OR  ( inst_fld = OPC_BR )
           )
           AND ( call_type = '1' ) 
           AND ( ex_null = '0' )
         )

         OR  ( irq_edge = '1' )

    else '0';

  
  dcd_pop <=  '1'
    when (inst_fld  = OPC_EXT) AND (ext_bit = '1' ) AND (ext_grp = EXT_RETURN )  AND ( ex_null = '0')

    else '0';

end arch1;



------------------------------
-- ea_dcd
------------------------------


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity ea_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk            : in  std_logic;
      sync_rst       : in  std_logic;

      inst           : in  std_logic_vector(INST_MSB downto 0);
      stall          : in  std_logic;

      dcd_LDI        : out boolean;
      dcd_mode_SP    : out boolean;
      dcd_src_mux    : out boolean;

      fld_mem_mode   : out std_logic;

      fld_sp_offset  : out std_logic_vector( 3 downto 0);
      fld_ldi_offset : out std_logic_vector(11 downto 0)
    );

end ea_dcd;


architecture arch1 of ea_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- internal copies
  --
  signal i_dcd_LDI      : boolean;
  signal i_dcd_mode_SP  : boolean;


  --
  -- instruction fields
  --
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  alias mem_mode   : std_logic is ireg(11);
  alias mem_size   : std_logic_vector(1 downto 0) is ireg(10 downto 9);
  alias sel_opb    : std_logic_vector(3 downto 0) is ireg( 7 downto 4);
  alias sp_offset  : std_logic_vector(3 downto 0) is ireg( 7 downto 4);
  alias ldi_offset : std_logic_vector(11 downto 0) is ireg(11 downto 0);


begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif stall = '0' then
      ireg  <= inst;

    end if;

  end process;


  --
  -- instruction decodes
  --
  i_dcd_LDI      <= ( inst_fld = OPM_LDI   );

  i_dcd_mode_SP  <= ( mem_size = MEM_32_SP );

  dcd_src_mux    <=  i_dcd_LDI OR ( ( sel_opb = REG_PC ) AND ( NOT i_dcd_mode_SP ) );

  --
  -- copy internals to outputs
  --
  dcd_LDI      <= i_dcd_LDI;    
  dcd_mode_SP  <= i_dcd_mode_SP;

  fld_mem_mode   <= mem_mode;

  fld_sp_offset  <= sp_offset; 
  fld_ldi_offset <= ldi_offset;

end arch1;


------------------------------
-- regfile_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity regfile_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk        : in  std_logic;
      sync_rst   : in  std_logic;

      inst       : in  std_logic_vector(INST_MSB downto 0);
      stall      : in  std_logic;

      ex_null    : in  std_logic;

      dcd_wb_en  : out std_logic
    );

end regfile_dcd;


architecture arch1 of regfile_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  --
  --
  signal wb_op : std_logic;

  --
  -- instruction fields
  --
  alias inst_type  : std_logic_vector(TYPE_MSB downto 0) is ireg(15 downto 14);
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0) is ireg(15 downto 12);
  alias lea_bit    : std_logic                           is ireg(8);

begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif stall = '0' then
      ireg  <= inst;

    end if;

  end process;

  --
  -- register file writeback operation decode
  --   enable for arith & logic, load & move
  --
  wb_op <=   '1' when  (
                               ( inst_type = OPA     )   
                          OR   ( inst_type = OPL     ) 

                          OR   ( inst_fld  = OPM_IMM ) 
                          OR ( ( inst_fld  = OPM_LD  ) AND ( stall = '0'   ) )
                          OR ( ( inst_fld  = OPM_LDI ) AND ( stall = '0'   ) )
                          OR ( ( inst_fld  = OPM_ST  ) AND ( lea_bit = '1' ) ) 
                        ) 
        else  '0';

  --
  -- instruction decode output
  --   wb_op, disabled on reset or ex_null from branch/skip control
  --
  dcd_wb_en <= wb_op AND (NOT ex_null) AND (NOT sync_rst);


end arch1;





------------------------------
-- 
------------------------------
