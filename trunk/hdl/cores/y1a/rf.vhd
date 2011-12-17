--
-- <rf.vhd>
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
-- Y1A register file 
--
--   one read port, one read/write port
--   async read, sync write
--
-- tied write & read address ports together internally so both
-- Synplify and XST always find dual port; ra1 not used
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;


entity regfile is

  port
    (   
      clk : in std_logic;

      we  : in std_logic;
      wa  : in std_logic_vector  (RF_ADDR_MSB downto 0);
      wd  : in std_logic_vector  (RF_DAT_MSB  downto 0);

      ra1 : in std_logic_vector  (RF_ADDR_MSB downto 0);
      ra2 : in std_logic_vector  (RF_ADDR_MSB downto 0);

      rd1 : out std_logic_vector (RF_DAT_MSB  downto 0);
      rd2 : out std_logic_vector (RF_DAT_MSB  downto 0)
    );

end regfile;


architecture arch1 of regfile is

    type rf_type is array (natural range <>) of std_logic_vector (RF_DAT_MSB downto 0);

    signal rf1 : rf_type (RF_DEPTH-1 downto 0) := (others => (others => '0') );

begin

  process (clk)
    begin
      if rising_edge(clk) then
        if we = '1' then
          rf1(to_integer(unsigned(wa))) <= wd;
        end if;
      end if;
    end process;

  rd1 <= rf1(to_integer(unsigned(wa)));
  rd2 <= rf1(to_integer(unsigned(ra2)));

end arch1;
