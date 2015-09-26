--
-- <programmable_baud_gen.vhd>
--

---------------------------------------------------------------
--
-- YARD-1 Design Files copyright (c) 2000-2015, Brian Davis
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
-- programmable baud rate generator (phase accumulator based) 
-- generates output enable at 16x BAUD_RATE
--
--



library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.m_uart_pkg.all;


entity programmable_baud_gen is
  generic
    (
      INIT_BAUD_REG : std_logic_vector(31 downto 0) := calc_baud_init( 50.0e6, 19_200.0 )
    );

  port 
    (        
      clk       : in  std_logic;
      s_rst     : in  std_logic;

      baud_dat  : in  std_logic_vector(31 downto 0);
      baud_wr   : in  std_logic;

      en_16x    : out std_logic
    );

end programmable_baud_gen;


architecture arch1 of programmable_baud_gen is

  signal   baud_reg : std_logic_vector(31 downto 0) := INIT_BAUD_REG;

  --
  -- one extra bit needed for carry detect
  --
  signal   ph_reg  : unsigned(baud_reg'left+1 downto 0) := ( others => 'L');


begin

  --
  --
  --
  P_baud_reg: process
    begin
      wait until rising_edge(clk);

      if s_rst = '1' then 
        baud_reg <= INIT_BAUD_REG;

      elsif baud_wr = '1' then 
        baud_reg <= baud_dat;

      end if;

    end process;


  P_ph_acc: process
    begin

      wait until rising_edge(clk);

      --
      -- phase accumulator, upper bit is registered carry detect
      --
      ph_reg <= ( '0' & ph_reg(baud_reg'range) ) + ( '0' & unsigned(baud_reg) );

      --
      -- re-register carry output
      --
      en_16x <= ph_reg(ph_reg'left);

    end process;

end arch1;

