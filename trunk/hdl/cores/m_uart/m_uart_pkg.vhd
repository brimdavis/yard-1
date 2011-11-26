--
-- <m_uart_pkg.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2011  B. Davis
--
-- Code released under the terms of the "new" BSD license
-- see license/new_bsd.txt
--
---------------------------------------------------------------

--
-- component package for minimalist UART 
--

library ieee;
  use ieee.std_logic_1164.all;

package m_uart_pkg is


  component m_uart is

    port 
      (        
        clk     : in  std_logic;
        s_rst   : in  std_logic;

        en_16x  : in  std_logic;

        --
        -- RX interface
        --
        rd_dat  : out std_logic_vector(7 downto 0);
        rd_en   : in  std_logic;

        rx_rdy  : out std_logic;

        --
        -- TX interface
        --
        wr_dat  : in  std_logic_vector(7 downto 0);
        wr_en   : in  std_logic;

        tx_rdy  : out std_logic;

        --
        -- serial data bits
        --
        rx_bit  : in  std_logic;
        tx_bit  : out std_logic
      );

  end component;


  component baud_gen is
    generic
      (
        CLK_FREQUENCY_MHZ : real :=    50.0;
        DEFAULT_BAUD_RATE : real := 19200.0
      );

    port 
      (        
        clk       : in  std_logic;
        s_rst     : in  std_logic;

        frac_baud : in  std_logic_vector(23 downto 0);

        en_16x    : out std_logic

      );

  end component;


end package m_uart_pkg;

