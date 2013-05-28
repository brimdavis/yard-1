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

  signal wide_sum   : std_logic_vector(ALU_MSB+2 downto 0);

  -- BMD XST workaround
  signal pad_ain    : std_logic_vector(ALU_MSB+2 downto 0);
  signal pad_bin    : std_logic_vector(ALU_MSB+2 downto 0);
  signal cin        : std_logic;

  signal pad_bin_msb  : std_logic;

  --
  -- declare synthesis attributes
  --
  attribute keep : boolean;

  attribute keep of pad_ain   : signal is true;
  attribute keep of pad_bin   : signal is true;
  attribute keep of cin       : signal is true;

  --
  -- instruction field aliases 
  --
  alias inst_type  : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  
  alias arith_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);

begin

  --
  --   now using 'native' addsub subtract for RSUB
  --   external bin inversion & carry used for SUB
  --
  cin <= '1' when arith_op = T_SUB else '0';

  --
  -- propagate any MSB inversions into padded bin so SUB borrow detect works correctly
  --
  pad_bin_msb <=  bin(ALU_MSB) when ( inst_fld = OPA_SUB )
         else '0';

  --
  -- BMD XST needs separate pad assignment to recognize addsub below
  --
  pad_ain <= (         '0' & ain & cin );
  pad_bin <= ( pad_bin_msb & bin & cin );


  wide_sum <=    pad_bin - pad_ain when arith_op = T_RSUB
           else  pad_ain + pad_bin 
           ;

  --
  -- break out result bits, plus carry for skip on carry/borrow 
  --
  arith_cout <= wide_sum(ALU_MSB+2);
  arith_dat  <= wide_sum(ALU_MSB+1 downto 1);  
 
end arch1;
