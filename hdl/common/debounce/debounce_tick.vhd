--
-- <debounce_tick.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2011  B. Davis
--
-- Code released under the terms of the "new" BSD license
-- see license/new_bsd.txt
--
-----------------------------------------------------------------

--
-- tick generator for switch/button debouncer
--    - ~100 Hz internal clock enable used as debounce timing source
--
-- TODO: calculate counter length based on clock frequency generic
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
                                

entity debounce_tick is
  port 
    (        
      clk        : in   std_logic;
      tick_en    : out  std_logic
    );

end debounce_tick;



architecture arch1 of debounce_tick is

  --
  -- tick counter signals used to generate ~100 Hz clock enable for debouncing
  --
--  signal tick_cnt : unsigned(19 downto 0) := ( others => 'L');
--  signal tick_sum : unsigned(20 downto 0);

  signal tick_cnt : unsigned(12 downto 0) := ( others => 'L');
  signal tick_sum : unsigned(13 downto 0);


begin


  --
  -- tick counter and clock enable
  --
  process
    begin

      wait until rising_edge(clk);

      tick_cnt <= tick_sum(tick_cnt'left downto 0);
      tick_en  <= tick_sum(tick_sum'left);

    end process;

  --
  -- sum coded separately from register in order to pull out MSB carry
  --
  tick_sum <= ( '0' & tick_cnt ) + 1;

end arch1;

