--
-- <debounce_tick.vhd>
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
-- tick generator for switch/button debouncer
--
--   - generates internal clock enable, typically 100 Hz, used as debounce timing source
--   - creates closest power-of-two divider equal to or slower than the requested frequency
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
                                

entity debounce_tick is
  generic
    (
      CLK_FREQ  : real := 50_000_000.0;
      TICK_FREQ : real :=        100.0
    );

  port 
    (        
      clk       : in   std_logic;
      tick_en   : out  std_logic
    );

end debounce_tick;


architecture arch1 of debounce_tick is

  --
  -- compute counter length to get near desired tick frequency 
  -- ( closest power-of-two division having frequency <= TICK_FREQ )
  --
  constant CNT_BITS : natural := natural( ceil( log2( CLK_FREQ / TICK_FREQ ) ) );

  --
  -- sum field is one bit wider than the counter to allow extraction of the MSB carry out
  --
  constant CNT_MSB  : natural := CNT_BITS - 1;
  constant SUM_MSB  : natural := CNT_BITS;

  --
  -- tick register 
  --
  signal tick_reg   : unsigned(SUM_MSB downto 0) := ( others => 'L');


begin

  process
    begin
      wait until rising_edge(clk);

      --
      -- registered carry & counter
      --
      tick_reg <= ( '0' & tick_reg(CNT_MSB downto 0) ) + 1;

      --
      -- registered output signal
      --
      tick_en  <= tick_reg(tick_reg'left);

    end process;

end arch1;

