--
-- <debounce_tb.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2011  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- simulation testbench for switch debouncer
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned."+";


entity testbench is

end testbench;


architecture bench1 of testbench is

  constant TB_CLK_PERIOD : time := 1000 ns;

  signal clk        : std_logic;

  signal tick_en    : std_logic;
  
  signal sw         : std_logic_vector(7 downto 0) := ( others => 'L' );

  signal sw_press   : std_logic_vector(7 downto 0);
  signal sw_release : std_logic_vector(7 downto 0);

  signal sw_state   : std_logic_vector(7 downto 0);
  
--
-- main testbench
--
begin

  --
  -- switch debouncers
  --

  --
  -- sw7 inverted
  --
  tb_sw7: entity work.debounce generic map ( SW_INVERT => '1' )
                               port map( clk => clk, tick_en => tick_en, sw_in => sw(7), sw_press => sw_press(7), sw_release => sw_release(7), sw_state => sw_state(7) );

  --
  -- others non-inverted
  --
  tb_sw6: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(6), sw_press => sw_press(6), sw_release => sw_release(6), sw_state => sw_state(6) );
  tb_sw5: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(5), sw_press => sw_press(5), sw_release => sw_release(5), sw_state => sw_state(5) );
  tb_sw4: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(4), sw_press => sw_press(4), sw_release => sw_release(4), sw_state => sw_state(4) );
  tb_sw3: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(3), sw_press => sw_press(3), sw_release => sw_release(3), sw_state => sw_state(3) );
  tb_sw2: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(2), sw_press => sw_press(2), sw_release => sw_release(2), sw_state => sw_state(2) );
  tb_sw1: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(1), sw_press => sw_press(1), sw_release => sw_release(1), sw_state => sw_state(1) );
  tb_sw0: entity work.debounce port map( clk => clk, tick_en => tick_en, sw_in => sw(0), sw_press => sw_press(0), sw_release => sw_release(0), sw_state => sw_state(0) );


  --
  -- debounce time tick
  --
  tb_tick : entity work.debounce_tick 
    port map 
      (        
        clk     => clk,
        tick_en => tick_en
      );

  
  --
  -- generate clock
  --
  tb_clk : process
    begin
      loop
  
        clk <= '1';
        wait for  TB_CLK_PERIOD/2;
  
        clk <= '0';
        wait for  TB_CLK_PERIOD/2;
  
      end loop;
    end process tb_clk;
  
  
  --
  -- create pulse pattern on switch inputs
  --
  --  low bits are shorter than debounce period
  --
  tb_sw : process
    begin

      sw <= X"80";

      wait for 15 ms;

      sw(0) <= '1', '0' after   1 ms;
      sw(1) <= '1', '0' after   2 ms;
      sw(2) <= '1', '0' after   5 ms;
      sw(3) <= '1', '0' after  10 ms;
      sw(4) <= '1', '0' after  20 ms;
      sw(5) <= '1', '0' after  50 ms;
      sw(6) <= '1', '0' after 100 ms;
      sw(7) <= '0', '1' after 100 ms;

      wait for 500 ms;

    end process tb_sw;
  
end bench1;
  
  
  
  
  
  
  
  