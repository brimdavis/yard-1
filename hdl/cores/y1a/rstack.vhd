--
-- <rstack.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2015  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A stack module
--
--   push/pop PC
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

  use ieee.math_real.all;

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;


entity rstack is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk       : in  std_logic;
      sync_rst  : in  std_logic;

      push      : in  std_logic;
      pop       : in  std_logic;

      dcd_rs_ld : in  std_logic;
      ld_dat    : in std_logic_vector(PC_MSB downto 0);

      ret_addr  : in  std_logic_vector(PC_MSB downto 0);
      
      pc_stk    : out std_logic_vector(PC_MSB downto 0)
    );

end rstack;

architecture arch1 of rstack is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- return stack pointer width
  --

  -- FIXME: remove old code after checking that log2 synthesizes in Diamond 3.4
  constant RSP_WIDTH : integer := 4;
--  constant RSP_WIDTH : natural := natural( ceil( log2( real(CFG.hw.rstack_depth) ) ) );
  constant RSP_MSB   : natural := RSP_WIDTH-1;

  type rs_pc_type is array (CFG.hw.rstack_depth-1 downto 0) of std_logic_vector (PC_MSB downto 0);

  signal rs_pc      : rs_pc_type := (others => (others => '0') );

  -- BMD XST use sep. signals for RAM read data so XST finds RAM's
  signal rs_pc_dat  : std_logic_vector  (PC_MSB downto 0);

  signal rsp_adr    : std_logic_vector(RSP_MSB downto 0);
  signal rsp_last   : std_logic_vector(RSP_MSB downto 0);

  signal pc_reg     : std_logic_vector (PC_MSB downto 0);


  attribute syn_ramstyle : string;

--  attribute syn_ramstyle of rs_pc : signal is "no_rw_check";
--  attribute syn_ramstyle of rs_pc : signal is "distributed";

begin

  --
  --  starts at zero, grows up
  --  T.O.S is mirrored in registered outputs 
  --  bottom entry is never used with current control logic
  --

  --
  -- registered stack pointer 
  --
  rsp_ctl: process
    begin
      wait until rising_edge(clk);

      if  sync_rst = '1' then
        rsp_last <= ( others => '0');

      elsif push = '1' then
        rsp_last <= rsp_last+1;

      elsif pop = '1' then
        rsp_last <= rsp_last-1;

      else
        rsp_last <= rsp_last;

      end if;

    end process rsp_ctl;

  --
  -- async. memory index, points to T.O.S when reading, next free when writing
  -- coded this way to allow inference of N deep SP RAM with common read & write 
  -- address instead of N/2 deep D.P. with independent read/write address
  --
  rsp_adr <= rsp_last+1 when push='1' else rsp_last;

  --
  --  move last register values to stack on a push
  --  creates memory write port
  --
  process (clk)
  begin
    if rising_edge(clk) then
      if push = '1' then
        rs_pc( to_integer(unsigned(rsp_adr)) ) <= pc_reg;
      end if;
    end if;
  end process;

  -- BMD XST use sep. signals for RAM read data so XST finds RAM's
  rs_pc_dat <= rs_pc( to_integer(unsigned(rsp_adr)) );

  --
  --  load registers from inputs on a push
  --  load registers from stack on a pop 
  --  creates memory read port followed by registered data output mux
  --
  rsp_regs: process
    begin
      wait until rising_edge(clk);

      if  sync_rst = '1' then
        pc_reg <= ( others => '0');

      elsif push = '1' then

        if dcd_rs_ld = '1' then
          pc_reg <= ld_dat;
        else
          pc_reg <= ret_addr;
        end if;

      elsif pop = '1' then
       -- NOTE: XST use sep. signals for RAM read data so XST finds RAM's
       -- pc_reg <= rs_pc(to_integer(unsigned(rsp_adr));
        pc_reg <= rs_pc_dat;

      else
        pc_reg <= pc_reg;

      end if;

    end process rsp_regs;

  pc_stk <= pc_reg;

end arch1;