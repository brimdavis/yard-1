-- 
-- <decoders.vhd>
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
-- Y1A instruction decoders
--
--  various instruction decoder components, collected in one file
--

--  ----------------------------------------------------------------------------
--  ----------------------------------------------------------------------------
--
-- master copy of aliases ( TODO: replace aliases with something better )
--
  
--  --
--  -- instruction register aliases for opcode fields ( see constant.vhd )
--  --    defined here using aliases until I figure out how best to define them 
--  --    in a constant package; maybe define as sub-records of sundry ir types
--  --
--  --  15:14   opcode (type)
--  --  13:12   opcode (op)
--  --     11   opcode extension field
--  --   11:9   skip control field
--  --   10:9   opb control field
--  --    8:4   opb constant field
--  --    7:4   opb register field
--  --    7:4   shift control field
--  --    3:0   opa register field
--  --
--  alias inst_type  : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
--  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
--  
--  alias arith_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
--  alias logic_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
--  alias ctl_op     : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
--  alias mem_op     : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
--  
--  alias arith_skip_nocarry  : std_logic is ireg(11);
--  alias logic_notb : std_logic is ireg(11);
-- 
--  alias ext_bit    : std_logic is ireg(11);
--
--  --
--  -- branch & extension group fields
--  --
--  alias bra_long   : std_logic is ireg(11);
--  alias ret_type   : std_logic is ireg(10);
--  alias call_type  : std_logic is ireg(10);
--  alias dslot_null : std_logic is ireg(9);
--  alias bra_offset : std_logic_vector(8 downto 0) is ireg(8 downto 0);
--
--  alias ext_grp    : std_logic_vector(3 downto 0) is ireg(7 downto 4);
--  
--
--  --
--  -- LDI offset
--  --
--  alias ldi_offset : std_logic_vector(11 downto 0) is ireg(11 downto 0);
--  
--  --
--  -- skip control bits
--  --
--  --alias skip_ctl    : std_logic_vector(2 downto 0) is ireg(11 downto 9);
--  alias skip_sense : std_logic is ireg(11);
--  alias skip_type  : std_logic_vector(2 downto 0) is ireg(10 downto 8);
-- 
--  alias skip_cp_sel   : std_logic is ireg(7);
--  alias skip_ra_type  : std_logic_vector(2 downto 0) is ireg(6 downto 4);
--  
--  --
--  -- load/store/lea address mode & operand size/sign extension
--  --
--  -- August 2012 : mode and sign bits were swapped to enable shared
--  --               decode bits for reg-reg sign extension instructions
--  --
--  alias mem_mode   : std_logic is ireg(11);
--  alias mem_size   : std_logic_vector(1 downto 0) is ireg(10 downto 9);
--  alias mem_sign   : std_logic is ireg(8);
--  alias sp_offset  : std_logic_vector(3 downto 0) is ireg( 7 downto 4);
--
--  alias lea_bit    : std_logic is ireg(8);
--  
--  --
--  -- opb control fields
--  --
--  alias opb_ctl     : std_logic_vector(1 downto 0) is ireg(10 downto 9);
--
--  alias opb_const   : std_logic_vector(4 downto 0) is ireg( 8 downto 4);
--  alias sel_opb     : std_logic_vector(3 downto 0) is ireg( 7 downto 4);
--  alias sel_opa     : std_logic_vector(3 downto 0) is ireg( 3 downto 0);
--  
--  --
--  -- shift control
--  --
--  alias shift_grp    : std_logic                    is ireg(11);
--  alias shift_signed : std_logic                    is ireg(10);
--  alias shift_dir    : std_logic                    is ireg( 9);
--  alias shift_const  : std_logic_vector(4 downto 0) is ireg( 8 downto 4);
-- 
--  alias misc_grp : std_logic_vector(1 downto 0) is ireg(9 downto 8);
--
--  --
--  -- SPAM instruction fields
--  --
--  alias spam_mode : std_logic_vector(2 downto 0) is ireg(10 downto 8);
--  alias spam_mask : std_logic_vector(7 downto 0) is ireg( 7 downto 0);
--
--  ----------------------------------------------------------------------------
--  ----------------------------------------------------------------------------


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
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

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

      dcd_sstk     : out boolean;

      dcd_st       : out boolean;
      dcd_st32     : out boolean;
      dcd_st16     : out boolean;
      dcd_st8      : out boolean
    );

end st_mux_dcd;


architecture arch1 of st_mux_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

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
  alias sel_opa      : std_logic_vector(3 downto 0)          is ireg(3 downto 0);


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
  dcd_sstk <=  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) AND (sel_opa = REG_RS);

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
      clk            : in  std_logic;
      sync_rst       : in  std_logic;

      inst           : in  std_logic_vector(INST_MSB downto 0);
      stall          : in  std_logic;

      ex_null        : in  std_logic;

      fld_dslot_null : out std_logic;
      dcd_rs_ld      : out std_logic;
      dcd_call       : out std_logic;
      dcd_push       : out std_logic;
      dcd_pop        : out std_logic 

    );

end rstack_dcd;


architecture arch1 of rstack_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg        : std_logic_vector(INST_MSB downto 0);

  signal dcd_call_i  : std_logic;
  signal dcd_rs_ld_i : std_logic;

  --
  -- instruction fields
  --
  alias inst_fld     : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  alias ext_bit      : std_logic                             is ireg(11);
  alias call_type    : std_logic                             is ireg(10);
  alias dslot_null   : std_logic                             is ireg(9);
  alias lea_bit      : std_logic                             is ireg(8);
  alias ext_grp      : std_logic_vector(3 downto 0)          is ireg(7 downto 4);
  alias sel_opa      : std_logic_vector(3 downto 0)          is ireg(3 downto 0);


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

  fld_dslot_null <= dslot_null;

  dcd_call_i <= '1' 
             when  (
                         ( (inst_fld = OPC_EXT) AND (ext_bit = '1' ) AND ( ext_grp = EXT_JUMP ) )
                     OR  ( inst_fld = OPC_BR )
                   )
                   AND ( call_type = '1' )

             else '0';

  dcd_call <= dcd_call_i;


  dcd_rs_ld_i <=   '1'  when (inst_fld = OPM_LD) AND (sel_opa = REG_RS) 
             else '0';

  dcd_rs_ld <= dcd_rs_ld_i;


  dcd_push <=   '1' when ( (dcd_call_i = '1') OR (dcd_rs_ld_i = '1') ) AND ( ex_null = '0' )
           else '0';

  dcd_pop <=  '1'
    when (
              ( (inst_fld = OPC_EXT) AND (ext_bit = '1') AND (ext_grp = EXT_RETURN) )
           OR ( (inst_fld = OPM_ST)  AND (lea_bit = '0') AND (sel_opa = REG_RS)     )
         )
         AND (ex_null = '0') 
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
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- internal signals
  --
  signal i_dcd_LDI          : boolean;
  signal i_dcd_mode_SP      : boolean;

  signal early_dcd_LDI      : boolean;
  signal early_dcd_mode_SP  : boolean;
  signal early_dcd_src_mux  : boolean;
  signal early_ldi_offset   : std_logic_vector(11 downto 0);
  signal early_sp_offset    : std_logic_vector( 3 downto 0);


  --
  -- instruction fields
  --
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  alias mem_mode   : std_logic is ireg(11);
  alias mem_size   : std_logic_vector( 1 downto 0) is ireg(10 downto 9);
  alias sel_opb    : std_logic_vector( 3 downto 0) is ireg( 7 downto 4);
  alias sp_offset  : std_logic_vector( 3 downto 0) is ireg( 7 downto 4);

  alias ldi_offset : std_logic_vector(11 downto 0) is ireg(11 downto 0);


begin

  --
  -- local instruction register
  -- early decode of addressing control fields
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg               <= ( others => '0');

      early_dcd_LDI      <= FALSE;
      early_dcd_mode_SP  <= FALSE;
      early_dcd_src_mux  <= FALSE;  

      early_ldi_offset   <= ( others => '0');
      early_sp_offset    <= ( others => '0');

    elsif stall = '0' then
      ireg               <= inst;

      early_dcd_LDI      <= ( inst(15 downto 12) = OPM_LDI   );
      early_dcd_mode_SP  <= ( inst(10 downto  9) = MEM_32_SP );

      early_dcd_src_mux  <= ( inst(15 downto 12) = OPM_LDI  ) OR ( ( inst(7 downto 4) = REG_PC ) AND ( NOT ( inst(10 downto 9) = MEM_32_SP ) ) );

      early_ldi_offset   <= inst(11 downto 0);
      early_sp_offset    <= inst( 7 downto 4);

    end if;

  end process;


  --
  -- instruction decodes
  --

--
-- commented out, using early decodes
--
--  i_dcd_LDI      <= ( inst_fld = OPM_LDI   );
--
--  i_dcd_mode_SP  <= ( mem_size = MEM_32_SP );
--
--  dcd_src_mux    <=  i_dcd_LDI OR ( ( sel_opb = REG_PC ) AND ( NOT i_dcd_mode_SP ) );
--

  --
  -- copy internals to outputs
  --
  dcd_src_mux    <= early_dcd_src_mux;

  dcd_LDI        <= early_dcd_LDI;    

  dcd_mode_SP    <= early_dcd_mode_SP;

  fld_mem_mode   <= mem_mode;

  fld_sp_offset  <= early_sp_offset; 
  fld_ldi_offset <= early_ldi_offset;

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
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

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
-- cgen_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity cgen_dcd is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk           : in  std_logic;
      sync_rst      : in  std_logic;

      inst          : in  std_logic_vector(INST_MSB downto 0);
      stall         : in  std_logic;

      fld_opb_ctl   : out std_logic_vector(1 downto 0);
      fld_opb_const : out std_logic_vector(4 downto 0)
    );

end cgen_dcd;


architecture arch1 of cgen_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  --
  --
  alias opb_ctl     : std_logic_vector(1 downto 0) is ireg(10 downto 9);
  alias opb_const   : std_logic_vector(4 downto 0) is ireg( 8 downto 4);

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
  --
  --
  --
  fld_opb_ctl   <= opb_ctl;
  fld_opb_const <= opb_const;

end arch1;


------------------------------
-- addsub_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity addsub_dcd is
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

      dcd_sub    : out std_logic;
      dcd_rsub   : out std_logic 
    );

end addsub_dcd;


architecture arch1 of addsub_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction field aliases 
  --
  alias inst_type  : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  
  alias arith_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);

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
  --
  --
  dcd_sub  <= '1' when arith_op = T_SUB  else '0';
  dcd_rsub <= '1' when arith_op = T_RSUB else '0';

end arch1;


------------------------------
-- logicals_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity logicals_dcd is
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

      fld_logic_op : out std_logic_vector(OP_MSB   downto 0)
    );

end logicals_dcd;


architecture arch1 of logicals_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction field aliases 
  --
  alias inst_type  : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);

  alias logic_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);

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
  --
  --
  fld_logic_op <= logic_op;

end arch1;


------------------------------
-- shift_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity shift_dcd is
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

      fld_shift_grp    : out std_logic;
      fld_shift_signed : out std_logic;
      fld_shift_dir    : out std_logic;
      fld_shift_const  : out std_logic_vector(4 downto 0) 
    );

end shift_dcd;


architecture arch1 of shift_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction field aliases 
  --
  alias shift_grp    : std_logic is ireg(11);
  alias shift_signed : std_logic is ireg(10);
  alias shift_dir    : std_logic is ireg( 9);
  alias shift_const  : std_logic_vector(4 downto 0) is ireg( 8 downto 4);

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


  fld_shift_grp    <= shift_grp;  
  fld_shift_signed <= shift_signed;
  fld_shift_dir    <= shift_dir;  
  fld_shift_const  <= shift_const;

end arch1;


------------------------------
-- flip_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity flip_dcd is
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

      fld_flip_const : out std_logic_vector(4 downto 0) 
    );

end flip_dcd;


architecture arch1 of flip_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction field aliases 
  --
  alias flip_const  : std_logic_vector(4 downto 0) is ireg( 8 downto 4);

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


  fld_flip_const  <= flip_const;

end arch1;


------------------------------
-- reg_extend_dcd
------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity reg_extend_dcd is
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

      dcd_wyde       : out std_logic;

      fld_mem_sign   : out std_logic;
      fld_mem_size   : out std_logic_vector(1 downto 0) 
    );

end reg_extend_dcd;


architecture arch1 of reg_extend_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  -- instruction field aliases 
  --
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);

  alias mem_size   : std_logic_vector(1 downto 0) is ireg(10 downto 9);
  alias mem_sign   : std_logic is ireg(8);

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
  dcd_wyde <=   '1' when mem_size = MEM_16
           else '0';


  fld_mem_size <= mem_size; 
  fld_mem_sign <= mem_sign;

end arch1;


------------------------------
-- 
------------------------------

