--
-- <debounce_tb.vhd>
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
-- simulation testbench for switch debouncer
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity testbench is

end testbench;


architecture bench1 of testbench is

  constant TB_CLK_PERIOD   : time := 1000.0 ns;  -- run testbench at 1 MHz to reduce # points of sim wave data 

  constant BOUNCE_DURATION : time :=   13.0 ms;

  constant NOISE_MIN_TIME  : time :=    0.1 us;  
  constant NOISE_MAX_TIME  : time :=    0.8 ms;  


  signal clk        : std_logic := 'L';

  signal tick_en    : std_logic;

  --
  -- sws : SWitch Stimulus
  -- swd : SWitch Delayed
  -- swb : SWitch Bouncified
  --
  signal sws        : std_logic_vector(7 downto 0);
  signal swb        : std_logic_vector(7 downto 0);
  signal swd        : std_logic_vector(7 downto 0);


  --
  -- debounced state & events
  --
  signal sw_press   : std_logic_vector(7 downto 0);
  signal sw_release : std_logic_vector(7 downto 0);

  signal sw_state   : std_logic_vector(7 downto 0);


--
-- main testbench
--
begin

  --
  -- clock generation
  --
  clk <= NOT clk after TB_CLK_PERIOD/2;
  
  --
  -- debounce time tick
  --
  tb_tick : entity work.debounce_tick 
    generic map 
      ( 
        CLK_FREQ  => 1_000_000.0,
        TICK_FREQ =>       100.0 
      )
    port map 
      (        
        clk     => clk,
        tick_en => tick_en
      );

  --
  -- switch debouncers
  --

  --
  -- sw7 high-when-pressed
  --
  tb_sw7: entity work.debounce generic map ( SW_ACTIVE_SENSE => '1' )
                               port map( clk => clk, tick_en => tick_en, sw_in => swb(7), sw_press => sw_press(7), sw_release => sw_release(7), sw_state => sw_state(7) );

  --
  -- others low-when-pressed (default generic)
  --
  tb_sw6: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(6), sw_press => sw_press(6), sw_release => sw_release(6), sw_state => sw_state(6) );
  tb_sw5: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(5), sw_press => sw_press(5), sw_release => sw_release(5), sw_state => sw_state(5) );
  tb_sw4: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(4), sw_press => sw_press(4), sw_release => sw_release(4), sw_state => sw_state(4) );
  tb_sw3: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(3), sw_press => sw_press(3), sw_release => sw_release(3), sw_state => sw_state(3) );
  tb_sw2: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(2), sw_press => sw_press(2), sw_release => sw_release(2), sw_state => sw_state(2) );
  tb_sw1: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(1), sw_press => sw_press(1), sw_release => sw_release(1), sw_state => sw_state(1) );
  tb_sw0: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => swb(0), sw_press => sw_press(0), sw_release => sw_release(0), sw_state => sw_state(0) );


  --
  -- create pulse stimulus pattern for switch inputs
  --
  --  low bits are shorter than debounce period
  --
  tb_sw : process
    begin

      sws <= X"7f";

      wait for 50 ms;

      --
      -- sw7 high when pressed
      --
      sws(7) <= '1', '0' after 200 ms;  

      --
      -- others low when pressed
      --
      sws(6) <= '0', '1' after 200 ms;  
      sws(5) <= '0', '1' after 100 ms;
      sws(4) <= '0', '1' after  50 ms;
      sws(3) <= '0', '1' after  20 ms;
      sws(2) <= '0', '1' after  15 ms;
      sws(1) <= '0', '1' after  10 ms;
      sws(0) <= '0', '1' after   5 ms;  

      wait for 500 ms;

    end process tb_sw;

  --
  -- add switch bounce to the original stimulus
  --
  U1: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 1 )
    port map ( din => sws(7), dout => swb(7) );
  
  U2: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 2 )
    port map ( din => sws(6), dout => swb(6) );
  
  U3: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 3 )
    port map ( din => sws(5), dout => swb(5) );
  
  U4: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 4 )
    port map ( din => sws(4), dout => swb(4) );
  
  U5: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 5 )
    port map ( din => sws(3), dout => swb(3) );
  
  U6: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 6 )
    port map ( din => sws(2), dout => swb(2) );
  
  U7: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 7 )
    port map ( din => sws(1), dout => swb(1) );
  
  U8: entity work.bouncify  
    generic map( BOUNCE_DURATION => BOUNCE_DURATION, NOISE_MIN_TIME => NOISE_MIN_TIME, NOISE_MAX_TIME => NOISE_MAX_TIME, SEED => 8 )
    port map ( din => sws(0), dout => swb(0) );
  
end bench1;
  
  
  
  
  
  
  
  