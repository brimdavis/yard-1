--
-- <bouncify.vhd>
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
-- simulate switch bounce by XORing data with noise during bounce time
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
                                

entity bouncify is
  generic
    (
      BOUNCE_DURATION : time;
      NOISE_MIN_TIME  : time;
      NOISE_MAX_TIME  : time;
      SEED            : positive
    );

  port 
    ( 
      signal din      : in  std_logic; 
      signal dout     : out std_logic
    );

end bouncify;


architecture arch1 of bouncify is

signal noise      : std_logic := 'L'; 
signal noise_gate : std_logic := 'L'; 

begin

  dout <= din XOR ( noise_gate AND noise );

  P_gate : process (din)
    begin
      if rising_edge(din) OR falling_edge(din) then
        noise_gate  <= '1', '0' after BOUNCE_DURATION;
      end if;
    end process;

  --
  -- generate bounded random noise as a stand-in for switch bounce ( not a good physical model of bounce )
  --
  P_noise : process
    variable seed1        : positive := SEED;
    variable seed2        : positive;
    variable noise_scale  : real;

    begin

      loop

        uniform( seed1 => seed1, seed2 => seed2, x => noise_scale );

        wait for noise_scale * (NOISE_MAX_TIME - NOISE_MIN_TIME) + NOISE_MIN_TIME;        

        noise <= NOT noise;

      end loop;

    end process;

end arch1;

