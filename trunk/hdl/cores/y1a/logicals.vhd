-- 
-- <logicals.vhd>
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
-- Y1A Boolean logic operations
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity logicals is

  port
    (   
      logic_op   : in  std_logic_vector(OP_MSB downto 0);

      ain        : in  std_logic_vector(ALU_MSB downto 0);
      bin        : in  std_logic_vector(ALU_MSB downto 0);
  
      logic_dat  : out std_logic_vector(ALU_MSB downto 0)
    );

end logicals;


architecture arch1 of logicals is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

begin

  with logic_op select

    logic_dat <= 
      ain AND bin    when T_AND,
      ain OR  bin    when T_OR,
      ain XOR bin    when T_XOR,
              bin    when T_MOV,
 
    (others => 'X')  when others;
 
end arch1;
