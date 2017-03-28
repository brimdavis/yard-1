--
-- <evb.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2013,2017  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- YARD-1 demo design for Lattice XO2 Pico Kit
--
--   - Y1A processor core
--   - 4 KB RAM
--   - UART
--   - I/O ports 
--  

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;
  use work.y1a_comps.all;

  use work.debounce_pkg.all;

-- pragma translate_off
  use work.y1a_probe_pkg.all;
-- pragma translate_on
  
  
entity evb is
  port
    (   
      clk_in    : in  std_logic;

      rx_bit    : in  std_logic;
      tx_bit    : out std_logic;

      reset_pb  : in  std_logic;

      out_portA : out std_logic_vector( 15 downto 0 );

      lcd_seg   : out std_logic_vector(  7 downto 0 );
      lcd_com   : out std_logic_vector(  3 downto 0 )
    );

end evb;
  
  
architecture evb1 of evb is

  constant EVB_CLK_FREQ : real := 12_000_000.0;
  constant EVB_BAUD     : real :=     19_200.0;

  --
  -- clock and control 
  --
  signal clk         : std_logic; 

  signal sync_rst    : std_logic; 
  signal rst_l       : std_logic; 

  signal irq_l       : std_logic; 
  
  --
  -- instruction bus
  --
  signal i_en        : std_logic;   
  signal i_rd        : std_logic;   
                   
  signal i_addr      : std_logic_vector(PC_MSB downto 0);
  signal i_dat       : std_logic_vector(I_DAT_MSB downto 0);
  
  --
  -- data bus
  --
  signal d_en        : std_logic;   
  signal d_rd        : std_logic;   
  signal d_wr        : std_logic;   
  signal d_bwe       : std_logic_vector(3 downto 0);  
  
  signal d_addr      : std_logic_vector(ADDR_MSB downto 0);
  signal d_rdat      : std_logic_vector(D_DAT_MSB downto 0);
  signal d_wdat      : std_logic_vector(D_DAT_MSB downto 0);
  
  signal d_stall     : std_logic;    
  
  --
  -- data bus mux structure
  --
  signal blkram_rdat : std_logic_vector(D_DAT_MSB downto 0);
  signal uart_rdat   : std_logic_vector(D_DAT_MSB downto 0);
  signal io_rdat     : std_logic_vector(D_DAT_MSB downto 0);
  signal spare_rdat  : std_logic_vector(D_DAT_MSB downto 0);

  --
  -- local decodes
  --
  signal ram_cs           : std_logic;   

  signal dcd_uart         : std_logic;   
  signal dcd_uart_wr      : std_logic;   
  signal dcd_uart_rd      : std_logic;   
  signal dcd_uart_rd_done : std_logic;  
  
  --
  -- uart support signals
  --
  signal baud_16x    : std_logic;  

  signal tx_rdy      : std_logic;  
  signal rx_avail    : std_logic;  

  signal rx_dat      : std_logic_vector(7 downto 0);

  signal lcd_toggle  : std_logic := 'L';
  
  --
  -- I/O ports
  --
  signal out_reg1    : std_logic_vector(15 downto 0);
  signal in_reg1     : std_logic_vector(15 downto 0);

  signal in_flags    : std_logic_vector(15 downto 0);


begin

  clk <= clk_in;

  --
  -- pushbutton debouncer for reset 
  --
  B_debounce : block
    signal reset_debounce : std_logic;

    signal tick_en        : std_logic;

  begin

    I_tick : debounce_tick 
      generic map ( CLK_FREQ => EVB_CLK_FREQ, TICK_FREQ => 100.0 )
      port map    ( clk => clk, tick_en => tick_en );

    I_rst_sw: debounce 
      generic map ( SW_ACTIVE_SENSE => '0' )
      port map ( clk => clk, tick_en => tick_en, sw_in => reset_pb, sw_press => open, sw_release => open, sw_state => reset_debounce);

    sync_rst   <=     reset_debounce;
    rst_l      <= NOT reset_debounce;

    lcd_toggle <= lcd_toggle XOR tick_en;

  end block;


  --
  -- FIXME: tied off IRQ after removing PB irq debouncer
  --
  irq_l <= '1';


  --
  -- processor core
  --
  I_evb_core: entity work.y1a_core
    generic map
      ( 
        CFG         => DEFAULT_Y1A_CONFIG
      )

    port map
      ( 
        clk        => clk,
        sync_rst   => sync_rst,

        irq_l      => irq_l,

        in_flags   => in_flags,

        i_en       => i_en,
        i_rd       => i_rd,

        i_addr     => i_addr,
        i_dat      => i_dat ,

        d_en       => d_en,
        d_rd       => d_rd,
        d_wr       => d_wr,
        d_bwe      => d_bwe,

        d_stall    => d_stall,

        d_addr     => d_addr,
        d_rdat     => d_rdat,        
        d_wdat     => d_wdat
      );

  --
  -- no data stalls
  --
  d_stall <= '0';


  --
  -- shared memory spaces using dual port block RAM
  -- d_addr is currently hardcoded for 32 bit processor
  --
  rtl_mem1 : entity work.rtl_mem
    port map 
      (
        clk       => clk,

        d_cs      => ram_cs,
        d_rd      => d_rd,
        d_wr      => d_wr,
        d_bwe     => d_bwe,

        d_addr    => d_addr(11 downto 2),
        d_rdat    => blkram_rdat,
        d_wdat    => d_wdat,

        i_addr    => i_addr(11 downto 2),
        i_dat     => i_dat
      );

  --
  -- chip select decode
  --
  ram_cs <= NOT d_addr(ADDR_MSB);


  --
  -- blockram data bus mux
  --
  d_rdat  <=   blkram_rdat when  ( ( d_rd = '1' ) AND ( ram_cs = '1' ) )
              else uart_rdat;

  ---------------------------------------------------------------
  --
  --   UART and support logic
  --
  ---------------------------------------------------------------

  I_m_uart: entity work.m_uart 
    port map
      (        
        clk     => clk,
        s_rst   => '0',
        en_16x  => baud_16x,

        rd_dat  => rx_dat,
        rd_en   => dcd_uart_rd_done,
        rx_rdy  => rx_avail,

        wr_dat  => d_wdat(7 downto 0),
        wr_en   => dcd_uart_wr,
        tx_rdy  => tx_rdy,

        rx_bit  => rx_bit,
        tx_bit  => tx_bit
      );


  --
  -- note, UART decode signals are all active high
  --
  dcd_uart     <=   '1'  when ( (d_en = '1') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"C" ) )
              else  '0';

  dcd_uart_wr  <=   '1'  when (dcd_uart = '1') AND ( d_wr = '1' ) 
              else  '0';

  dcd_uart_rd  <=   '1'  when (dcd_uart = '1') AND ( d_rd = '1' )
              else  '0';

  --
  -- bus mux for UART read data
  --
  uart_rdat <=   (ALU_MSB downto 8 => '0') & rx_dat  when ( dcd_uart_rd = '1' ) 
            else io_rdat;

  --
  -- read pulse advances UART read data to next byte 
  -- without data stalls, just a copy of the read decode
  --
  dcd_uart_rd_done <= dcd_uart_rd;

  --
  -- instantiate simple baud rate divider
  --
  E_baud_gen: entity work.simple_baud_gen
    generic map
      (
        CLK_FREQ  => EVB_CLK_FREQ,
        BAUD_RATE =>     EVB_BAUD
      )
    port map
      (        
        clk       => clk,
        en_16x    => baud_16x
      );


  --
  -- register input flags
  --
  P_in_flags : process
    begin
      wait until rising_edge(clk);

      in_flags(15) <= tx_rdy;
      in_flags(14) <= rx_avail;
      in_flags(13 downto 0) <= ( others => '0');

    end process;
 

  ---------------------------------------------------------------
  --
  -- I/O port
  --
  --  One 32 bit I/O register
  --    - upper 16 bits are outputs ( with readback )
  --    - lower 16 bits are inputs
  --
  ---------------------------------------------------------------

  --
  -- 16 bit output port
  --   bits 31:16 of I/O register are outputs
  --
  P_out_port : process(clk, rst_l)
    begin

      if rst_l = '0' then
        out_reg1 <= ( others => '0');

      elsif rising_edge(clk) then

        if (d_wr = '1') AND (d_en = '1') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"8" ) then

          if d_bwe(3) = '1' then
            out_reg1(15 downto 8) <= d_wdat(31 downto 24);
          end if;

          if d_bwe(2) = '1' then
            out_reg1( 7 downto 0) <= d_wdat(23 downto 16);
          end if;
  
        end if;

      end if;
 
    end process;

  --
  -- connect output register to port
  --
  out_portA <= out_reg1;


  --
  -- input register connections
  --   input data clocked to hold data stable during processor read cycle
  --
  --  D15:8  spare
  --
  --  D7  UART TX ready 
  --  D6  UART RX data available 
  --  D5  spare
  --  D4  spare
  --  D3  spare
  --  D2  spare 
  --  D1  spare
  --  D0  spare
  --
  P_in_reg1 : process
    begin
      wait until rising_edge(clk);

      in_reg1(15 downto 8) <= (others => '0');

      in_reg1(7) <= tx_rdy;
      in_reg1(6) <= rx_avail;

      in_reg1(5 downto 0) <= (others => '0');

    end process;
 

  --
  -- bus mux for 32 bit I/O register 
  --
  --  31:16 : output register readback
  --  15:00 : input register read
  --
  P_in_port : process( d_addr, d_en, d_rd, in_reg1, out_reg1, spare_rdat )
    begin
 
      if (d_en = '1') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"8" ) then

        if d_rd = '1' then
          io_rdat <= out_reg1 & in_reg1;

        else
          io_rdat <= spare_rdat;

        end if;

      else
        io_rdat <= spare_rdat;

      end if;
 
    end process;
 

  --
  -- LCD lines for pico board
  --   - tied off to GND
  --   - muxed LCD requires special PWM drive waveforms to generate varying 
  --     AC bias across external RC filters on the pico evaluation board
  --
  P_LCD : process

    begin
      wait until rising_edge(clk);

      lcd_seg <= ( others => '0' );
      lcd_com <= ( others => '0' );

    end process;


  --
  -- end-of-bus data mux source
  --
  spare_rdat <= ( others => '0' );

end evb1;