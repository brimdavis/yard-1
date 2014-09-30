--
-- <m_uart_tb.vhd>
--

---------------------------------------------------------------
--
-- YARD-1 Design Files copyright (c) 2000-2014 Brian Davis
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
-- simulation testbench for m_uart
--
--  - writes known data pattern to UART transmitter
--
--  - checks RX data against TX data
--
--  - checks baud rate within 0.5 %
--
--
--  - TODO: read procedure instead of in-line code
--
--  - TODO: use behavioral UART model for checking instead of loopback
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


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

  --
  -- make queue size large enough to accomodate all transmited bytes sent by testbench
  --
  constant MAX_QUEUE_SIZE : natural := 1024;

  -------------------------

  --
  -- compute clock frequency used for baud calculations from TB_CLK_PERIOD 
  --
  constant TB_CLK_FREQ   : real := 1.0 / ( real( TB_CLK_PERIOD / 1 ns ) * 1.0e-9 );

  --
  -- type defs
  --
  subtype byte    is std_logic_vector(7 downto 0);

  type byte_array is array ( natural range <> ) of byte;

  --
  -- tb control signals
  --
  signal tb_run   : std_logic := 'L';

  signal clk      : std_logic := 'L';

  --
  -- signals for DUT wiring
  --
  signal baud_16x : std_logic;   

  signal tx_rdy   : std_logic;   
  signal rx_rdy   : std_logic;   

  signal tx_dat   : byte;
  signal rx_dat   : byte;

  signal rx_bit   : std_logic := 'H';   
  signal tx_bit   : std_logic;   

  signal uart_wr  : std_logic;   
  signal uart_rd  : std_logic;   
  
  --
  -- array to record write data for comparison
  --
  signal qdat     : byte_array( 0 to MAX_QUEUE_SIZE-1 );   -- Queued DATa
  signal qti      : integer := 0;                          -- Queue Transmit Index
  signal qri      : integer := 0;                          -- Queue Receive Index


  signal rx_errs  : integer := 0;

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
  -- instantiate UART 
  --
  E_m_uart: entity work.m_uart 
    port map
      (        
        clk     => clk,
        s_rst   => '0',
        en_16x  => baud_16x,

        rd_dat  => rx_dat,
        rd_en   => uart_rd,
        rx_rdy  => rx_rdy,

        wr_dat  => tx_dat,
        wr_en   => uart_wr,
        tx_rdy  => tx_rdy,

        rx_bit  => rx_bit,
        tx_bit  => tx_bit
      );

  --
  -- instantiate simple baud rate divider
  --
  E_baud_gen: entity work.simple_baud_gen
    generic map
      (
        CLK_FREQ  => TB_CLK_FREQ,
        BAUD_RATE => TB_BAUD
      )
    port map
      (        
        clk       => clk,
        en_16x    => baud_16x
      );


  --
  -- delayed loopback, tx output to rx input 
  --
  rx_bit <= transport tx_bit after 1 ms;


  --
  -- transmit data
  --
  tb_uart_tx : process

    --
    -- local uart write procedure
    --
    procedure send_byte ( constant wdat : in byte ) is

      begin

        --
        -- loop until uart transmitter is ready
        --   note synchronous sampling of transmit ready line 
        --
        loop
          wait until rising_edge(clk);
          exit when tx_rdy = '1';
        end loop;

        --
        -- synchronously assert data & write strobe 
        --
        wait until rising_edge(clk);
          tx_dat  <= wdat  after TB_HOLD;
          uart_wr <= '1'   after TB_HOLD;

          --
          -- record transmit data in queue for later comparison
          --
          qdat(qti) <= wdat;
          qti       <= qti + 1;

        --
        -- synchronously deassert write strobe 
        --
        wait until rising_edge(clk);
          tx_dat  <= ( others => '0') after TB_HOLD;
          uart_wr <= '0'              after TB_HOLD;

      end;


    begin

      --
      -- initial signals
      --
      tx_dat  <= X"00";
      uart_wr <= '0';

      --
      -- wait before starting up Tx
      --
      wait for 1 ms;

      --
      -- send first byte
      --
      send_byte( X"55");

      --
      -- overwrite test - write while busy, byte should be ignored
      --
      wait until rising_edge(clk);
        tx_dat  <= X"FF" after TB_HOLD;
        uart_wr <= '1'   after TB_HOLD;

      wait until rising_edge(clk);
        uart_wr <= '0'   after TB_HOLD;

      --
      -- send another byte 
      --
      send_byte( X"D0");
    
      --
      -- send all characters
      --
      for i in 0 to 255 loop
        send_byte( std_logic_vector(to_unsigned(i,8)) );
      end loop;

      --
      -- done, wait forever
      --
      wait;

    end process tb_uart_tx;


  --
  -- verify rx data
  --
  tb_uart_rx : process
    begin

      --
      -- initial signals
      --
      uart_rd <= '0';

      wait for 100 ns;

      loop

        --
        -- loop until uart receiver has data
        --   note synchronous sampling of receiver ready line 
        --
        loop
          wait until rising_edge(clk);
          exit when rx_rdy = '1';
        end loop;

        --
        -- check that rx = tx
        --   note that receive data output is valid coincident with receive ready flag assertion
        --
        if rx_dat /= qdat(qri) then
  
          rx_errs <= rx_errs + 1;

          assert FALSE
            report "TX/RX data mismatch"
            severity ERROR;

        end if;

        qri <= qri + 1;

        --
        -- pulse the read signal for one clock cycle
        --
        wait until rising_edge(clk);
          uart_rd <=   '1' after TB_HOLD;

        wait until rising_edge(clk);
          uart_rd <=   '0' after TB_HOLD;

      end loop;

      --
      -- done, wait forever
      --
      wait;

    end process tb_uart_rx;

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

      assert FALSE
        report  "Data Comparison Errors: " & integer'image(rx_errs)
        severity NOTE;

      assert qti = qri
        report  "Tx/Rx byte count mismatch: " & integer'image(qti) & "/" & integer'image(qri)
        severity ERROR;

      assert qti > 0
        report  "Testbench error: no data sent!"
        severity ERROR;

      wait;

    end process;

  
end bench1;
  
  
  
  
  
  
  
  