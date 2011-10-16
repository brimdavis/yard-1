--
-- <debounce_pkg.vhd>
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
-- debounce components
--

library ieee;
  use ieee.std_logic_1164.all;

package debounce_pkg is

  component debounce is

    generic
      (
        SW_INVERT : std_logic := '0'    -- '1' = inverts sw_in signal for an active low switch input
      );

    port 
      (        
        clk        : in  std_logic;
        tick_en    : in  std_logic;

        sw_in      : in  std_logic;

        sw_press   : out std_logic;
        sw_release : out std_logic;
        sw_state   : out std_logic
      );

  end component;


  component debounce_tick is

    port 
      (        
        clk        : in   std_logic;
        tick_en    : out  std_logic
      );

  end component;
  

end package debounce_pkg;
