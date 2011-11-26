--
-- <m_uart.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2011  B. Davis
--
-- Code released under the terms of the "new" BSD license
-- see license/new_bsd.txt
--
-----------------------------------------------------------------

--
--  Minimalist UART
--
--    - fixed data format:
--       8 bits
--       1 stop
--       no parity
--
--    - two status flags:
--       tx_rdy : 1 = ok to write data into tx
--       rx_rdy : 1 = data available for read
--
--    - no other flow control or status/error flags
--
--    - data interface is synchronous to clock
--
--    - no fifos
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned."+";
                                

entity m_uart is
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

end m_uart;


architecture arch1 of m_uart is

  --
  -- tx shift registers & control
  --
  signal tx_sr         : std_logic_vector( 8 downto 0) := ( others => '1');
  signal tx_bit_local  : std_logic := '1'; 

  signal tx_done        : std_logic;

  signal wr_flag_srl    : std_logic_vector(9 downto 0) := ( others => '0');
  signal wr_toggle      : std_logic := '0';


  --
  -- rx shift registers & control
  --
  signal rx_sr         : std_logic_vector(10 downto 0) := ( others => '1');
  alias  rx_done       : std_logic is rx_sr(0);

  signal rx_rdy_local  : std_logic := '0'; 


  --
  -- input sync & edge detect
  --
  signal rx_x0, rx_x1  : std_logic; 
  signal rx_z0, rx_z1  : std_logic; 

  signal rx_dat_z0     : std_logic; 
  signal rx_dat_z1     : std_logic; 
  
  --
  -- baud phase 
  --
  signal baud_phase     : std_logic_vector(3 downto 0) := ( others => '0');
  signal rx_mid_phase   : std_logic_vector(3 downto 0);

  signal en_1x         : std_logic;	


begin


  ---------------------------------
  --
  --  /16 baud phase counter 
  --
  ---------------------------------
  bc1: process
    begin
      wait until rising_edge(clk);

      if s_rst = '1' then
        baud_phase <= (others => '0');

      elsif en_16x = '1' then
        baud_phase <= baud_phase + 1;

      end if;

    end process;


  --
  -- en_1x logic asserts for a single clock cycle
  --
  en_1x  <=  '1'  when ( en_16x = '1' ) AND ( baud_phase = X"F" ) 
        else '0';


  ---------------------------------
  --
  -- TX shift control
  --
  ---------------------------------
  P_tx_shift: process
    begin

      wait until rising_edge(clk);

      --
      -- shift delay line used to generate done flag
      --
      if en_1x = '1' then
        wr_flag_srl <= wr_toggle & wr_flag_srl(wr_flag_srl'left downto 1);
      end if;

      --
      -- shift reg & bit count logic
      --
      if s_rst = '1' then

        tx_sr        <= ( others => '1' );
        tx_bit_local <= '1';
        wr_toggle    <= '0';

      elsif ( wr_en = '1') AND ( tx_done = '1' ) then
        --
        -- write : 
        --    load shift data 
        --    toggle write flag
        --
        tx_sr     <= wr_dat & '0';
        wr_toggle <= NOT wr_toggle;

      elsif en_1x = '1' then
        --
        -- enable: shift out next bit (LSB first)
        --
        tx_sr        <= '1' & tx_sr(8 downto 1);
        tx_bit_local <= tx_sr(0);

      end if;

    end process;

  --
  -- done if begining and end of flag shift reg. are at same state
  --
  tx_done <= NOT (wr_toggle XOR wr_flag_srl(0) );


  --
  -- copy local signal to output port
  --
  tx_bit <= tx_bit_local;

  --
  -- TX status flag = TX done
  --
  tx_rdy <= tx_done;


  ---------------------------------
  --
  -- RX input bit synchronizer & deglitcher
  --
  ---------------------------------
  P_rx_sync: process
    begin

      wait until rising_edge(clk);

      --
      -- two stage synchronizer
      --  reset to avoid srl inference
      --
      if (s_rst = '1')  then
        rx_x0 <= '1';
        rx_x1 <= '1';
      else
        rx_x0 <= rx_bit;
        rx_x1 <= rx_x0;
      end if;

      --
      -- ignore glitches < 1/16 bit period
      --
      if (en_16x = '1')  then
        rx_z0 <= rx_x1;
        rx_z1 <= rx_z0;

        if    (rx_z0 = '0') AND (rx_z1 = '0') then  
          rx_dat_z0 <= '0';

        elsif (rx_z0 = '1') AND (rx_z1 = '1') then
          rx_dat_z0 <= '1';

        end if;

        rx_dat_z1 <= rx_dat_z0;

      end if;

    end process;


  ---------------------------------
  --
  -- RX shift control
  --
  ---------------------------------
  P_rx_shift: process
    begin

      wait until rising_edge(clk);

      --
      -- shift reg & flag logic
      --
      if s_rst = '1' then
        rx_rdy_local <= '0';
        rd_dat <= ( others => '0' );
        rx_sr  <= ( others => '1' );

      elsif (rd_en = '1') AND ( rx_rdy_local = '1' ) then
        --
        -- read : clear flag
        --
        rx_rdy_local <= '0';

      elsif (en_16x = '1') AND (rx_done = '1') then
        --
        -- falling edge:
        --   set sample phase to current baud phase + 8 
        --   set MSB of shift register (used as done flag when shifted to LSB)
        --
        if ( ( rx_dat_z1 = '1' ) AND ( rx_dat_z0 = '0' ) ) then
          rx_mid_phase <= baud_phase XOR X"8";
          rx_sr  <= ( rx_sr'left => '1',  others => '0' );
        end if;

      elsif (en_16x = '1') AND (baud_phase = rx_mid_phase) AND (rx_done = '0') then
        --
        -- matching enable: 
        --   shift rx_sr right, next input bit into MSB (data sent LSB first)
        --
        rx_sr  <=  rx_dat_z1 & rx_sr(10 downto 1);

      elsif (rx_rdy_local = '0') AND (rx_done = '1') AND (rx_sr(10) = '1') AND (rx_sr(1) = '0') then
        --
        -- if rdy flag not already set AND finished shifting AND have valid start/stop framing bits :
        --    set rx flag 
        --    copy rx shift register to read data register
        --
        rx_rdy_local <= '1';
        rd_dat <= rx_sr( 9 downto 2);

        -- workaround to prevent re-executing this state after a rd_en until a new byte arrives
        rx_sr  <= ( others => '1' );

      end if;

    end process;

 --
 -- connect local version of rx_rdy to output port
 --
 rx_rdy <= rx_rdy_local;

end arch1;