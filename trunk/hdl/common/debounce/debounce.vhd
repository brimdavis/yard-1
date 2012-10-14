--
-- <debounce.vhd>
--

---------------------------------------------------------------
--
-- YARD-1 Design Files copyright (c) 2000-2012, Brian Davis
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--
--    * Redistributions in binary form must reproduce the above copyright 
--      notice, this list of conditions and the following disclaimer in the 
--      documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------

--
-- switch/button debouncer
--
--   - tick_en is a ~100 Hz clock enable used as the debounce timing source
--   - inputs are debounced using glitch detected sampling at tick rate
--   - debounced status/press/release outputs are synchronous to the input clock
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
                                

entity debounce is
  generic
    (
      --
      -- SW_ACTIVE_SENSE  indicates input state when switch is pressed 
      --
      --   '0' => low-when-pressed switch input
      --   '1' => high-when-pressed switch input
      --
      SW_ACTIVE_SENSE : std_logic := '0'
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
  -- registers for synchronization 
  -- initialized to inactive state based on SW_INVERTED generic
  --
  signal sw_x0        : std_logic := NOT SW_ACTIVE_SENSE;
  signal sw_x1        : std_logic := NOT SW_ACTIVE_SENSE;

  --
  -- debounce stuff, sampled data and stable flag
  --
  signal sw_dat       : std_logic := NOT SW_ACTIVE_SENSE;
  signal sw_stable    : std_logic := 'L';

  --
  -- delays for edge detect
  --
  signal sw_state_z0  : std_logic := 'L';
  signal sw_state_z1  : std_logic := 'L';


  --
  -- synthesis attribute to keep first stage of synchronizer 
  -- hopefully, this will prevent the synchronizer from being 'optimized' into an SRL
  --
  -- syn_keep should be recognized by both XST and Synplify ( unconfirmed )
  --
  attribute syn_keep : boolean;
  attribute syn_keep of sw_x0 : signal is TRUE;


begin

  process
    begin

      wait until rising_edge(clk);

      --
      -- two stage synchronizer
      --
      sw_x0 <= sw_in;
      sw_x1 <= sw_x0;

      --
      -- sw_dat grabs switch state once per tick
      -- sw_stable is a latching flag that detects any state changes during tick interval
      --
      if tick_en = '1' then
        sw_dat    <= sw_x1;
        sw_stable <= '1';

      else
        sw_stable <= sw_stable AND ( sw_dat XNOR sw_x1 );

      end if;

      --
      -- first stage of edge detect updates at tick rate
      -- doesn't change state unless data is stable
      -- inverts switch input if needed
      --
      if ( tick_en = '1' ) AND ( sw_stable = '1' ) then
        sw_state_z0 <= sw_dat XOR (NOT SW_ACTIVE_SENSE);

      end if;

      --
      -- delayed copy used for edge detect
      --
      sw_state_z1 <= sw_state_z0;

      --
      -- switch state outputs
      -- note that press/release events are one clock wide pulses
      --
      sw_press   <=     sw_state_z0   AND  NOT sw_state_z1;   -- now high, was low
      sw_release <= NOT sw_state_z0   AND      sw_state_z1;   -- now low,  was high
      sw_state   <=     sw_state_z0;

    end process;

end arch1;

