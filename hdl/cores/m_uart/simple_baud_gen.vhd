--
-- <simple_baud_gen.vhd>
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
-- simple fixed baud rate generator (counter based) 
-- generates output enable at 16x BAUD_RATE
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity simple_baud_gen is
  generic
    (
      CLK_FREQ  : real := 50_000_000.0;
      BAUD_RATE : real :=     19_200.0
    );

  port 
    (        
      clk       : in  std_logic;
      en_16x    : out std_logic
    );

end simple_baud_gen;


architecture arch1 of simple_baud_gen is

  --
  -- compute required counter length and init value
  --
  -- example calc:
  --
  --  50 MHz / ( 16 x 19,200 ) => 162.7 ~= 163 
  --  counter counts from N-1 .. 0, so init value is 162 => X"A2" 
  --
  constant CLK_DIVIDER  : real     := CLK_FREQ / ( 16.0 * BAUD_RATE ) ;

  constant CNT_BITS     : natural  := natural( ceil( log2(CLK_DIVIDER) ) );
  constant CNT_INIT     : unsigned := to_unsigned( integer(round(CLK_DIVIDER-1.0)), CNT_BITS);

  signal   baud_cnt     : unsigned(CNT_BITS-1 downto 0) := ( others => 'L');

begin

  assert false report "BAUD COUNTER INIT: " & integer'image(to_integer(CNT_INIT)) severity NOTE;

  P_bc: process
    begin
      wait until rising_edge(clk);

      --
      -- down counter with auto reload at zero
      --
      if ( baud_cnt = ( baud_cnt'range => '0') ) then
        baud_cnt  <= CNT_INIT;
        en_16x    <= '1';

      else
        baud_cnt  <= baud_cnt - 1;
        en_16x    <= '0';

      end if;

    end process;

end arch1;

