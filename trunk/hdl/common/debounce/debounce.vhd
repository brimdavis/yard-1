--
-- <debounce.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2011  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
-----------------------------------------------------------------

--
-- TODO: 
--   - clock frequency calculation to set length of debounce counter
--
--
-- switch/button debouncer
--    - ~100 Hz clock enable used as debounce timing source
--    - debounced using two tick voting
--    - debounced status/press/release outputs are synchronous to input clock
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
                                

entity debounce is
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

end debounce;



architecture arch1 of debounce is

  --
  -- registers for synchronization & debounce delay 
  --  initialized to inactive state based on SW_INVERT generic
  --
  signal sw_x0    : std_logic := SW_INVERT;
  signal sw_x1    : std_logic := SW_INVERT;
  signal sw_x2    : std_logic := SW_INVERT;

  signal sw_dat     : std_logic;
  signal sw_dat_z0  : std_logic;


begin

  process
    begin

      wait until rising_edge(clk);

      sw_x0 <= sw_in;

      --
      -- these register stages sample at tick rate to implement debounce delay
      --
      if tick_en = '1' then
        sw_x1 <= sw_x0;
        sw_x2 <= sw_x1;
      end if;

      --
      -- don't change state until both samples agree
      -- invert if needed
      --
      if sw_x1 = sw_x2 then
        sw_dat <= sw_x2 XOR SW_INVERT;
      end if;

      --
      -- delayed copy used for edge detect
      --
      sw_dat_z0 <= sw_dat;

      --
      -- switch state outputs
      -- note that press/release events are one clock wide pulses
      --
      sw_press   <=     sw_dat   AND NOT sw_dat_z0;
      sw_release <= NOT sw_dat   AND     sw_dat_z0;
      sw_state   <=     sw_dat;

    end process;

end arch1;

