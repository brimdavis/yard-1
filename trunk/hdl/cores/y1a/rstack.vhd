--
-- <rstack.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2012  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A stack module
--
--   push/pop PC & SR
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;


entity rstack is
  port
    (   
      clk    : in std_logic;
      rst_l  : in std_logic;

      push   : in std_logic;
      pop    : in std_logic;

      pc_in  : in std_logic_vector  (PC_MSB downto 0);
      sr_in  : in std_logic_vector  (SR_MSB downto 0);

      pc_stk : out std_logic_vector (PC_MSB downto 0);
      sr_stk : out std_logic_vector (SR_MSB downto 0)
    );

end rstack;

architecture arch1 of rstack is

--  attribute syn_hier : string;
--  attribute syn_hier of arch1: architecture is "hard";

  type rs_pc_type is array (RSTACK_DEPTH-1 downto 0) of std_logic_vector (PC_MSB downto 0);
  type rs_sr_type is array (RSTACK_DEPTH-1 downto 0) of std_logic_vector (SR_MSB downto 0);

  signal rs_pc : rs_pc_type := (others => (others => '0') );
  signal rs_sr : rs_sr_type := (others => (others => '0') );

  -- BMD XST use sep. signals for RAM read data so XST finds RAM's
  signal rs_pc_dat  : std_logic_vector  (PC_MSB downto 0);
  signal rs_sr_dat  : std_logic_vector  (SR_MSB downto 0);

  signal rsp_adr  : std_logic_vector(RSP_MSB downto 0);
  signal rsp_last : std_logic_vector(RSP_MSB downto 0);

  signal pc_reg : std_logic_vector (PC_MSB downto 0);
  signal sr_reg : std_logic_vector (SR_MSB downto 0);

begin

  --
  --  starts at zero, grows up
  --  T.O.S is mirrored in registered outputs 
  --  bottom entry is never used with current control logic
  --

  --
  -- registered stack pointer 
  --
  rsp_ctl: process (clk,rst_l)
    begin

      if  rst_l = '0' then
        rsp_last <= ( others => '0');

      elsif rising_edge(clk) then

        if push = '1' then
          rsp_last <= rsp_last+1;

        elsif pop = '1' then
          rsp_last <= rsp_last-1;

        else
          rsp_last <= rsp_last;

        end if;

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
        rs_sr( to_integer(unsigned(rsp_adr)) ) <= sr_reg;
      end if;
    end if;
  end process;

  -- BMD XST use sep. signals for RAM read data so XST finds RAM's
  rs_pc_dat <= rs_pc( to_integer(unsigned(rsp_adr)) );
  rs_sr_dat <= rs_sr( to_integer(unsigned(rsp_adr)) );

  --
  --  load registers from inputs on a push
  --  load registers from stack on a pop 
  --  creates memory read port followed by registered data output mux
  --
  rsp_regs: process (clk,rst_l)
    begin

      if  rst_l = '0' then
        pc_reg <= ( others => '0');
        sr_reg <= ( others => '0');

      elsif rising_edge(clk) then

        if push = '1' then
          pc_reg <= pc_in;
          sr_reg <= sr_in;

        elsif pop = '1' then
         -- BMD XST use sep. signals for RAM read data so XST finds RAM's
         -- pc_reg <= rs_pc(to_integer(unsigned(rsp_adr));
         -- sr_reg <= rs_sr(to_integer(unsigned(rsp_adr));
          pc_reg <= rs_pc_dat;
          sr_reg <= rs_sr_dat;

        else
          pc_reg <= pc_reg;
          sr_reg <= sr_reg;

        end if;

      end if;

    end process rsp_regs;

  pc_stk <= pc_reg;
  sr_stk <= sr_reg;

end arch1;
