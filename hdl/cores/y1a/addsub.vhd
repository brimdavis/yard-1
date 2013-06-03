-- 
-- <addsub.vhd>
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
-- Y1A arithmetic ops
--
--
--   - uses 'native' addsub for ADD and RSUB
--   - external shared bin inversion logic, and internal +1, used to implement SUB
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity addsub is

  port
    (   
      ireg       : in  std_logic_vector(INST_MSB downto 0);

      ain        : in  std_logic_vector(ALU_MSB downto 0);
      bin        : in  std_logic_vector(ALU_MSB downto 0);
  
      arith_cout : out std_logic;
      arith_dat  : out std_logic_vector(ALU_MSB downto 0)
    );

end addsub;


architecture arch1 of addsub is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";


  --
  -- addsub signals are padded in width for carry-in, carry/borrow-out logic
  --
  signal wide_sum   : std_logic_vector(ALU_MSB+2 downto 0);

  signal pad_ain    : std_logic_vector(ALU_MSB+2 downto 0);
  signal pad_bin    : std_logic_vector(ALU_MSB+2 downto 0);

  signal dcd_sub    : std_logic;

  --
  -- declare synthesis attributes
  --
  attribute keep : boolean;

  attribute keep of pad_ain   : signal is true;
  attribute keep of pad_bin   : signal is true;
  attribute keep of dcd_sub   : signal is true;

  --
  -- instruction field aliases 
  --
  alias inst_type  : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  
  alias arith_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);

begin

  --
  -- decode of SUB used for special handling of borrow-out, force-carry-in
  --
  dcd_sub <= '1' when arith_op = T_SUB else '0';

  --
  -- BMD XST needs separate pad signal assignment here to recognize addsub below
  --  - extra bit at the LSB is used to code behavioral carry-in
  --  - extra bit at the MSB is used for carry/borrow detection
  --
  -- dcd_sub forces carry-in when set
  --
  -- dcd_sub is also used at the MSB to invert carry detect logic (fixes SUB borrow problem)
  --   ADD/RSUB use addsub     : native carry/borrow = 1 when active, no inversion required
  --   SUB uses invert-add-one : native borrow=0 when active, extra term inverts to make borrow=1 
  --
  pad_ain <= (     '0' & ain & dcd_sub );
  pad_bin <= ( dcd_sub & bin & dcd_sub );


  --
  -- addsub
  --
  wide_sum <=    pad_bin - pad_ain when arith_op = T_RSUB
           else  pad_ain + pad_bin 
           ;

  --
  -- break out result bits, plus carry out for skip on carry/borrow 
  --
  arith_cout <= wide_sum(ALU_MSB+2);
  arith_dat  <= wide_sum(ALU_MSB+1 downto 1);  
 
end arch1;

