--
-- <m_uart_pkg.vhd>
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
-- package for minimalist UART 
--   components, constants, and functions
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

package m_uart_pkg is

  --
  -- UART
  --
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


  --
  -- simple fixed baud rate generator (counter based) 
  -- generates output enable at 16x BAUD_RATE
  --
  component simple_baud_gen is
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

  end component;


  --
  -- function to calculate init value for programmable baud rate generator
  --
  function calc_baud_init( CLK_FREQ, BAUD_RATE : real) return std_logic_vector;


  --
  -- programmable baud rate generator ( prescaler + fractional divider )
  -- generates output enable at 16x BAUD_RATE
  --
  component programmable_baud_gen is
    generic
      (
        INIT_BAUD_REG : std_logic_vector(31 downto 0)
      );

    port 
      (        
        clk       : in  std_logic;
        s_rst     : in  std_logic;

        baud_dat  : in  std_logic_vector(31 downto 0);
        baud_wr   : in  std_logic;

        en_16x    : out std_logic
      );

  end component;


end package m_uart_pkg;


package body m_uart_pkg is
 
  function calc_baud_init (CLK_FREQ, BAUD_RATE : real) return std_logic_vector is
    variable freq_16x       : real;
    variable baud_prescaler : std_logic_vector( 2 downto 0);
    variable baud_fraction  : std_logic_vector(28 downto 0);

    begin

      freq_16x := 16.0 * BAUD_RATE;

      --
      -- FIXME : calculate correct prescaler based upon division ratio limit check
      --
      -- assume all ones for now ( using fractional divider )
      --
      baud_prescaler := B"111";

      --
      -- fractional baud = 2^28 * FREQ_16X / CLK_FREQ
      --
      baud_fraction  := std_logic_vector( to_unsigned( natural (round( (2.0**28.0) * ( freq_16x / CLK_FREQ ) ) ), 28));

      return baud_prescaler & baud_fraction;

    end function;


end package body;