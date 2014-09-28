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
--  - sets up stimulus for manual inspection
--
--  - simple check of rx data against tx data
--
--  - TODO: read and write procedures instead of in-line code
--
--  - TODO: use behavioral UART model for checking instead of loopback
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity testbench is

end testbench;


architecture bench1 of testbench is

  constant TB_CLK_PERIOD : time := 20 ns;
  constant T_HOLD        : time :=  2 ns;


  subtype byte    is std_logic_vector(7 downto 0);

  type byte_array is array ( natural range <> ) of byte;


  signal tb_run   : std_logic := 'L';

  signal clk      : std_logic := 'L';

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
  signal qdat     : byte_array( 0 to 1023 );
  signal qti      : integer := 0;
  signal qri      : integer := 0;

  signal rx_errs  : integer := 0;


--
-- main testbench
--
begin

  --
  -- generate clock; gated with tb_run to end simulation
  --
  clk    <= (NOT clk) AND tb_run after TB_CLK_PERIOD/2;

  --
  -- run testbench for 25 ms 
  --
  tb_run <= '1', '0' after 25 ms;

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
        CLK_FREQ  => 50_000_000.0,
        BAUD_RATE =>    115_200.0
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
  --
  --
  tb_uart_tx : process

    --
    -- local uart write procedure
    --
    procedure send_byte ( constant wdat : in byte ) is

      begin

        loop
          wait until rising_edge(clk);
          exit when tx_rdy = '1';
        end loop;

        wait until rising_edge(clk);
          tx_dat    <= wdat  after T_HOLD;
          uart_wr   <= '1'   after T_HOLD;

          qdat(qti) <= wdat;
          qti       <= qti + 1;

        wait until rising_edge(clk);
          uart_wr <= '0'   after T_HOLD;

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
        tx_dat  <= X"FF" after T_HOLD;
        uart_wr <= '1'   after T_HOLD;

      wait until rising_edge(clk);
        uart_wr <= '0'   after T_HOLD;

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
        -- wait for rx_rdy flag
        --
        if rx_rdy = '0' then
          wait until rx_rdy = '1';
        end if;

        --
        -- read data
        --
        wait until rising_edge(clk);
        uart_rd <=   '1' after T_HOLD;

        --
        -- deassert read
        --
        wait until rising_edge(clk);
        uart_rd <=   '0' after T_HOLD;

        --
        -- read data at next clock edge
        --
        wait until rising_edge(clk);

        --
        -- check that rx = tx
        --
        if rx_dat /= qdat(qri) then

          rx_errs <= rx_errs + 1;

          assert rx_dat = qdat(qri) 
            report "TX/RX data mismatch"
            severity ERROR;


        end if;

        qri <= qri + 1;

      end loop;

      wait;

    end process tb_uart_rx;


  --
  -- print summary info at end of simulation
  --
  P_tb_summary : process
    begin

      wait until tb_run = '1';

      wait until tb_run = '0';

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
  
  
  
  
  
  
  
  