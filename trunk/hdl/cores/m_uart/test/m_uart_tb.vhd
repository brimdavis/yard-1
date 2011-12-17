--
-- <m_uart_tb.vhd>
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
-- simulation testbench for m_uart
--
--
--  - not self checking, just sets up stimulus for manual inspection
--
--  - TODO: read and write procedures instead of in-line code
--
--  - TODO: use behavioral UART model for checking instead of loopback
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";


entity testbench is

end testbench;


architecture bench1 of testbench is

  constant TB_CLK_PERIOD : time := 20 ns;
  constant T_HOLD        : time :=  2 ns;

  signal clk        : std_logic;


  signal baud_div   : std_logic_vector(7 downto 0) := ( others => 'L');
  signal baud_16x   : std_logic;   

  signal tx_rdy     : std_logic;   
  signal rx_rdy     : std_logic;   

  signal tx_dat     : std_logic_vector(7 downto 0);
  signal rx_dat     : std_logic_vector(7 downto 0);

  signal rx_bit     : std_logic := 'H';   
  signal tx_bit     : std_logic;   

  signal uart_wr : std_logic;   
  signal uart_rd : std_logic;   
  
  
--
-- main testbench
--
begin

  
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
  --   instantiate UART 
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
  -- baud rate divider
  --
  E_bc1: process
    begin
      wait until rising_edge(clk);

      if ( baud_div = X"00" ) then
--        baud_div  <= X"a2";
        baud_div  <= X"19";
        baud_16x  <= '1';
      else
        baud_div  <= baud_div - 1;
        baud_16x  <= '0';
      end if;

    end process;


  --
  -- delayed loopback, tx output to rx input 
  --
  rx_bit <= transport tx_bit after 1 ms;

  
  --
  --
  --
  tb_uart_tx : process
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
      -- send a byte
      --
      wait until rising_edge(clk);
        tx_dat  <= X"55" after T_HOLD;
        uart_wr <= '1'   after T_HOLD;

      wait until rising_edge(clk);
        uart_wr <= '0'   after T_HOLD;


      --
      -- overwrite test - write while busy, byte should be ignored
      --
      wait until rising_edge(clk);
        tx_dat  <= X"FF" after T_HOLD;
        uart_wr <= '1'   after T_HOLD;

      wait until rising_edge(clk);
        uart_wr <= '0'   after T_HOLD;


      --
      -- wait for tx_rdy assertion
      --
      wait until rising_edge(tx_rdy);

      --
      -- send another byte immediately after tx_rdy asserts
      --
      wait until rising_edge(clk);
        tx_dat  <= X"D0" after T_HOLD;
        uart_wr <= '1'   after T_HOLD;

      wait until rising_edge(clk);
        uart_wr <= '0'   after T_HOLD;


      --
      -- send all characters
      --
      for i in 0 to 255 loop

        --
        -- wait for tx_rdy
        --
        wait until rising_edge(tx_rdy);

        --
        -- send another byte immediately after tx_rdy asserts
        --
        wait until rising_edge(clk);
          tx_dat <= std_logic_vector(to_unsigned(i,8)) after T_HOLD;
          uart_wr <= '1'   after T_HOLD;

        wait until rising_edge(clk);
          uart_wr <= '0'   after T_HOLD;


      end loop;


      wait;

    end process tb_uart_tx;

  --
  -- TODO: verify rx data
  --
  tb_uart_rx : process
    begin

      ---------------------------------------
      ---------------------------------------
      --
      -- initial signals
      --
      uart_rd <= '0';

      wait for 100 ns;

      loop
        ---------------------------------------
        ---------------------------------------
        -- wait for rx_rdy flag
        wait until rx_rdy = '1';


        ---------------------------------------
        --
        -- read data
        --
        wait until rising_edge(clk);
        uart_rd <=   '1' after T_HOLD;

        ---------------------------------------
        --
        wait until rising_edge(clk);
        uart_rd <=   '0' after T_HOLD;

        -- TODO check that rx = tx

      end loop;

      wait;

    end process tb_uart_rx;

  
end bench1;
  
  
  
  
  
  
  
  