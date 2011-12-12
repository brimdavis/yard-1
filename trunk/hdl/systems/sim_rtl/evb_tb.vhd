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

  signal clk     : std_logic;
  signal rst_l   : std_logic;
  
  signal irq_l   : std_logic;
  
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
        clk   => clk,
        rst_l => rst_l
      );
  
  --
  -- clock generation
  --
  P_clk_gen : process
    begin
      loop
  
        clk <= '1';
        wait for  TB_CLK_PERIOD/2;
  
        clk <= '0';
        wait for  TB_CLK_PERIOD/2;
  
      end loop;
    end process P_clk_gen;
  
  --
  -- startup reset signal
  --
  rst_l <= '0', '1' after 10 * TB_CLK_PERIOD + TB_HOLD;

  --
  -- one interrupt pulse @ 200 clock ticks in, 10 clocks wide
  --
  irq_l <= '1', '0' after 200 * TB_CLK_PERIOD + TB_HOLD, '1' after 210 * TB_CLK_PERIOD + TB_HOLD;

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
        write(L,  std_logic'image(rst_l) );

        write( L, string'(" IRQ="));
        write(L,  std_logic'image(irq_l) );

        write( L, string'(" dip_sw="));
        write(L,  dip_sw );

        write( L, string'(" led_bar="));
        write(L,  led_bar );

        writeline( OUTPUT, L);

        wait for TB_CLK_PERIOD;

      end loop;

    end process P_io_mon;
  
end bench1;
  
  
  
  
  
  
  
  