--
-- <evb.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2012  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- YARD-1 demo design for Lattice XP2 Brevia Kit
--
--   - Y1A processor core
--   - 4 KB RAM
--   - UART
--   - I/O ports for switches and LEDs on eval board
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

  use work.y1a_probe_pkg.all;
  use work.debounce_pkg.all;
  
  
entity evb is
  port
    (   
      clk50_in  : in  std_logic;

      rx_bit    : in  std_logic;
      tx_bit    : out std_logic;

      pb        : in  std_logic_vector(3 downto 0); 
      sw        : in  std_logic_vector(7 downto 0); 

      led       : out std_logic_vector(7 downto 0)
    );

end evb;
  
  
architecture evb1 of evb is
  
  --
  --
  --
  signal clk   : std_logic; 
  signal rst_l : std_logic; 
  signal irq_l : std_logic; 
  
  --
  --
  --
  signal i_en_l  : std_logic;   
  signal i_rd_l  : std_logic;   
  
  signal i_addr  : std_logic_vector(PC_MSB downto 0);
  signal i_dat   : std_logic_vector(INST_MSB downto 0);
  
  --
  --
  --
  signal d_en_l  : std_logic;   
  signal d_rd_l  : std_logic;   
  signal d_wr_l  : std_logic;   
  signal d_wr_en_l : std_logic_vector(3 downto 0);  
  
  signal d_addr  : std_logic_vector(ADDR_MSB downto 0);
  signal d_rdat  : std_logic_vector(ALU_MSB downto 0);
  signal d_wdat  : std_logic_vector(ALU_MSB downto 0);
  
  signal blkram_rdat  : std_logic_vector(ALU_MSB downto 0);
  signal uart_rdat    : std_logic_vector(ALU_MSB downto 0);
  signal io_rdat      : std_logic_vector(ALU_MSB downto 0);
  signal spare_rdat   : std_logic_vector(ALU_MSB downto 0);

  signal d_stall    : std_logic;    
  signal d_stall_p1 : std_logic;    
  
  --
  -- local decodes
  --
  signal ram_cs_l    : std_logic;   

  signal dcd_uart    : std_logic;   
  signal dcd_uart_wr : std_logic;   
  signal dcd_uart_rd : std_logic;   
  signal dcd_uart_rd_done : std_logic;  
  
  --
  -- uart support signals
  --
  signal baud_div : std_logic_vector(7 downto 0) := ( others => '0');
  signal baud_16x : std_logic;  

  signal tx_rdy   : std_logic;  
  signal rx_avail : std_logic;  

  signal rx_dat   : std_logic_vector(7 downto 0);
  
  --
  -- I/O ports
  --
  signal out_reg1 : std_logic_vector(7 downto 0);
  signal in_reg1  : std_logic_vector(7 downto 0);

  --
  --
  --
  signal evb_probes : y1a_probe_type;
  

begin

  clk <= clk50_in;

  --
  -- pushbutton debouncers for reset & IRQ signals
  --
  B_debounce : block
    signal pb3_debounce : std_logic;
    signal pb2_pulse    : std_logic;

    signal tick_en      : std_logic;

  begin

    I_tick : debounce_tick 
      port map ( clk => clk, tick_en => tick_en );

    I_rst_sw: debounce 
      generic map ( SW_INVERT => '1' )
      port map ( clk => clk, tick_en => tick_en, sw_in => pb(3), sw_press => open, sw_release => open, sw_state => pb3_debounce);

    I_irq_sw: debounce 
      generic map ( SW_INVERT => '0' )
      port map ( clk => clk, tick_en => tick_en, sw_in => pb(2), sw_press => pb2_pulse, sw_release => open, sw_state => open );


    rst_l <= NOT pb3_debounce;
    irq_l <= NOT pb2_pulse;

  end block B_debounce;


  --
  -- processor core
  --
  evb_core: entity work.y1a_core
    generic map
      ( 
        CFG         => DEFAULT_CONFIG
      )

    port map
      ( 
        clk        => clk,
        rst_l      => rst_l,

        irq_l      => irq_l,

        in_flags   => X"55AA",

        i_en_l     => i_en_l,
        i_rd_l     => i_rd_l,

        i_addr     => i_addr,
        i_dat      => i_dat ,

        d_en_l     => d_en_l,
        d_rd_l     => d_rd_l,
        d_wr_l     => d_wr_l,
        d_wr_en_l  => d_wr_en_l,

        d_stall    => d_stall,

        d_addr     => d_addr,
        d_rdat     => d_rdat,        
        d_wdat     => d_wdat,

        y1a_probes => evb_probes        
      );

  --
  -- data stall logic
  --

  -- no stalls
  d_stall <= '0';


  -- disabled: decode of RAM address puts this on critical path!
  --  d_stall <= (NOT ram_cs_l) AND (NOT d_rd_l) AND (NOT d_stall_p1);

  --
  -- disabled: stall for all loads
  --
  --  d_stall <= (NOT d_en_l) AND (NOT d_rd_l) AND (NOT d_stall_p1);

  reg_cs1 : process (clk, rst_l)
    begin
      if rst_l = '0' then
        d_stall_p1 <= '0';

      elsif rising_edge(clk) then
        d_stall_p1 <= d_stall;

      end if;

    end process reg_cs1;


  --
  -- shared memory spaces using dual port block RAM
  -- d_addr is currently hardcoded for 32 bit processor
  --
  rtl_mem1 : entity work.rtl_mem
    port map 
      (
        clk       => clk,

        d_cs_l    => ram_cs_l,
        d_rd_l    => d_rd_l,
        d_wr_l    => d_wr_l,
        d_wr_en_l => d_wr_en_l,

        d_addr    => d_addr(12 downto 2),
        d_rdat    => blkram_rdat,
        d_wdat    => d_wdat,

        i_addr    => i_addr(12 downto 1),
        i_dat     => i_dat
      );

  --
  -- chip select decode
  --
  ram_cs_l <= d_addr(ADDR_MSB);

--  ram_cs_l <= '0'  when (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"0" )
--         else '1';

  --
  -- blockram data bus mux
  --
  d_rdat  <=   blkram_rdat when  ( ( d_rd_l = '0' ) AND ( ram_cs_l = '0' ) )
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
  dcd_uart     <=   '1'  when ( (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"C" ) )
              else  '0';

  dcd_uart_wr  <=   '1'  when (dcd_uart = '1') AND ( d_wr_l = '0' ) 
              else  '0';

  dcd_uart_rd  <=   '1'  when (dcd_uart = '1') AND ( d_wr_l = '1' )
              else  '0';

  --
  -- bus mux for UART read data
  --
  uart_rdat <=   (ALU_MSB downto 8 => '0') & rx_dat  when ( dcd_uart_rd = '1' ) 
            else io_rdat;

  --
  -- BMD no stall
  --
  dcd_uart_rd_done <=   '1'  when (dcd_uart = '1') AND ( d_wr_l = '1' ) 
              else '0';
--
--  dcd_uart_rd_done <=   '1'  when (dcd_uart = '1') AND ( d_wr_l = '1' ) AND (d_stall_p1 = '1')
--              else '0';


   --
   -- TODO: add programmable baud rate generator w/automated clock-to-baud counter calculation
   --
   -- fixed rate clock divider for UART baud rate
   -- runs at 16x desired 19200 baud 
   --
   --  50 MHz / ( 19,200 x 16 ) => 162.7 ~= 163 
   --  counter counts from N-1 .. 0, so load value is 162 => X"A2" 
   --
   bc1: process
     begin
       wait until rising_edge(clk);
 
       if ( baud_div = X"00" ) then
         baud_div  <= X"a2";
         baud_16x  <= '1';
       else
         baud_div  <= baud_div - 1;
         baud_16x  <= '0';
       end if;
 
     end process;


  ---------------------------------------------------------------
  --
  -- I/O ports
  --
  ---------------------------------------------------------------

  --
  -- 8 bit output port
  --
  out_port1 : process(clk, rst_l)
    begin

      if rst_l = '0' then
        out_reg1 <= ( others => '0');

      elsif rising_edge(clk) then

        if (d_wr_l = '0') AND (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"8" ) then
          out_reg1 <= d_wdat(7 downto 0);
        end if;

      end if;
 
    end process out_port1;
 
  --
  -- 8 bit input port
  --
  P_in_port1 : process( d_addr, d_en_l, d_rd_l, in_reg1 )
    begin
 
      if (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"8" ) then

        if d_rd_l = '0' then
          io_rdat <= (ALU_MSB downto 8 => '0') & in_reg1(7 downto 0);
        else
          io_rdat <= spare_rdat;
        end if;

      else
        io_rdat <= spare_rdat;

      end if;
 
    end process p_in_port1;
 
  --
  -- input port connections
  --   input data clocked to hold data stable during processor read cycle
  --
  --  D7  UART TX ready 
  --  D6  UART RX data available 
  --  D5  SWITCH D5
  --  D4  SWITCH D4
  --  D3  SWITCH D3
  --  D2  SWITCH D2 
  --  D1  SWITCH D1
  --  D0  SWITCH D0
  --
  P_in_reg1 : process
    begin
      wait until rising_edge(clk);

      in_reg1(7) <= tx_rdy;
      in_reg1(6) <= rx_avail;

      in_reg1(5 downto 0) <= sw(5 downto 0);

    end process p_in_reg1;
 

  --
  -- LED's active low on Brevia board
  --
  P_LED : process
     begin
      wait until rising_edge(clk);

      -- LSB's of PC
      -- led <= NOT evb_probes.pc_reg_p1(7 downto 0);

      -- UART receive data
      led <= NOT rx_dat;

    end process P_LED;


  --
  -- end-of-bus data mux source
  --
  spare_rdat <= ( others => '0' );

end evb1;