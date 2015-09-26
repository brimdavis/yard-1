--
-- <m_baudgen_tb.vhd>
--

---------------------------------------------------------------
--
-- YARD-1 Design Files copyright (c) 2000-2015 Brian Davis
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
-- simulation testbench for programmable baud rate generator
--
--  - checks baud rate within 0.5 %
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library work;
  use work.m_uart_pkg.all;

entity testbench is

end testbench;


architecture bench1 of testbench is

  -------------------------
  --
  -- TB control constants
  --
  constant TB_CLK_PERIOD : time := 20 ns;
  constant TB_HOLD       : time :=  2 ns;      -- testbench hold time for DUT stimulus

  constant TB_RUN_TIME   : time := 25 ms;

  constant TB_BAUD       : real := 115_200.0;


  -------------------------

  --
  -- compute clock frequency used for baud calculations from TB_CLK_PERIOD 
  --
  constant TB_CLK_FREQ   : real := 1.0 / ( real( TB_CLK_PERIOD / 1 ns ) * 1.0e-9 );

  --
  -- tb control signals
  --
  signal tb_run   : std_logic := 'L';

  signal clk      : std_logic := 'L';

  --
  -- signals for DUT wiring
  --
  signal baud_16x : std_logic;   


  signal baud_wr  : std_logic;   


  signal last_baud_freq  : real := 0.0;


--
-- main testbench
--
begin

  --
  -- generate clock
  --   gated with tb_run to end simulation by stopping the clock
  --
  clk <= (NOT clk) AND tb_run after TB_CLK_PERIOD/2;

  --
  -- run testbench for desired interval 
  --
  tb_run <= '1', '0' after TB_RUN_TIME;

  --
  -- instantiate simple baud rate divider
  --
  E_baud_gen: entity work.programmable_baud_gen
    generic map
      (
        INIT_BAUD_REG => calc_baud_init( CLK_FREQ => TB_CLK_FREQ, BAUD_RATE => TB_BAUD )
      )
    port map
      (        
        clk       => clk,

        s_rst     => '0',

        baud_dat  => ( others => '0' ),
        baud_wr   => '0',

        en_16x    => baud_16x
      );

  --
  -- monitor baud rate generator
  --
  tb_baud_mon : process

    variable first_edge, last_edge : time;

    variable baud_freq    : real := 0.0;

    constant NAVG         : natural := 100;

    begin

      --
      -- measure elapsed time for NAVG baud ticks
      --
      wait until rising_edge(baud_16x);
      wait until rising_edge(clk);
      first_edge := now;

      for i in 1 to NAVG loop
        wait until rising_edge(baud_16x);
        wait until rising_edge(clk);
      end loop;

      last_edge := now;

      --
      -- convert to real baud rate, accounting for NAVG samples at 16x baud rate
      --  note, using time scale < 1ns might overflow integer time conversion
      --
      baud_freq := real(NAVG) / ( real( (last_edge - first_edge) / 1 ns ) * 1.0e-9 * 16.0 );

      --
      -- check frequency accuracy within 0.5 %
      --
      assert ( baud_freq/TB_BAUD <= 1.005 ) AND ( baud_freq/TB_BAUD >= 0.995 )
        report  "Baud rate error > 0.5 %  (" & real'image(baud_freq) & ")"
        severity ERROR;

      --
      -- copy latest measurement to global testbench signal
      --
      last_baud_freq <= baud_freq;

    end process;


  --
  -- print summary info at end of simulation
  --
  P_tb_summary : process
    begin

      wait until falling_edge(tb_run);

      assert FALSE
        report "Measured baud rate = " & real'image(last_baud_freq)
        severity NOTE;

      wait;

    end process;

  
end bench1;
  
  
  
  
  
  
  
  