--
-- <evb_tb.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2011  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
--
---------------------------------------------------------------

--
-- YARD-1 top level simulation 
--
-- testbench for RTL evb target ( processor core, RAM, I/O )
--

library std;
  use std.textio.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_textio.all;

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;

  use work.y1a_probe_pkg.all;


entity testbench is
end testbench;


architecture bench1 of testbench is

  constant TB_CLK_PERIOD : time := 10 ns;
  constant TB_HOLD       : time :=  2 ns;

  signal clk     : std_logic := 'H';  -- initialize for clk gen
  signal rst_l   : std_logic;
  
  signal irq_l   : std_logic := 'H';  -- initialize for continous irq_gen
  
  signal dip_sw  : std_logic_vector(3 downto 0);
  
  signal led_bar : std_logic_vector(3 downto 0);
  
  signal tp      : std_logic_vector(15 downto 0);
  
  signal rx_bit  : std_logic;
  signal tx_bit  : std_logic;
  

begin
  
  I_evb: entity work.evb
    port map
      (
        clk     => clk,
  
        rst_l   => rst_l,
  
        irq_l   => irq_l,
  
        rx_bit  => rx_bit,
        tx_bit  => tx_bit,
  
        dip_sw  => dip_sw,
  
        led_bar => led_bar,
  
        tp      => tp
      );

  I_prb: entity work.y1a_probe
    port map
      (
        clk   => clk
      );
  
  --
  -- clock generation
  --
  clk <= NOT clk after TB_CLK_PERIOD/2;
  
  --
  -- assert startup reset signal for 10 clocks
  --
  rst_l <= '0', '1' after 10 * TB_CLK_PERIOD + TB_HOLD;


---  --
---  -- interrupt pulses @ 50 & 100 clock ticks in, 4 clocks wide
---  --
---  irq_l <= '1', 
---           '0' after  50 * TB_CLK_PERIOD + TB_HOLD, 
---           '1' after  54 * TB_CLK_PERIOD + TB_HOLD,
---           '0' after 100 * TB_CLK_PERIOD + TB_HOLD, 
---           '1' after 104 * TB_CLK_PERIOD + TB_HOLD;

---  --
---  --  interrupts every 20 cycles- run verification tests with interrupts active
---  --  3 clocks wide to trigger just one level sensitive interrupt per pulse with minimal ISR stub
---  --
---  irq_l <= NOT irq_l after 17 * TB_CLK_PERIOD + TB_HOLD, '1' after 20 * TB_CLK_PERIOD + TB_HOLD ;
---

  --
  --  continous interrupts after reset- run verification tests with interrupts active
  --
  irq_l <= '1', '0' after 10 * TB_CLK_PERIOD + TB_HOLD;


  --
  -- drive switch inputs
  --
  dip_sw <= ( others => '0');
  
  --
  -- monitor I/O ports
  --
  P_io_mon: process
    variable L : line;

    begin

      wait until rising_edge(clk);

      loop

        write(L, ' ' );
        writeline(OUTPUT,L);

        write(L, now );

        write( L, string'(": EVB    tp="));
        hwrite(L,  tp );

        write( L, string'(" RST="));
        write(L,  rst_l );

        write( L, string'(" IRQ="));
        write(L,  irq_l );

        write( L, string'(" dip_sw="));
        write(L,  dip_sw );

        write( L, string'(" led_bar="));
        write(L,  led_bar );

        writeline( OUTPUT, L);

        wait for TB_CLK_PERIOD;

      end loop;

    end process P_io_mon;
  
end bench1;
  
  
  
  
  
  
  
  