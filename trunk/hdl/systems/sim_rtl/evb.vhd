--
-- <evb.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2011  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A top level FPGA design for RTL simulation
--
--  derived from target evb sources
--  simulation stubs used in place of XAPP UART
--
--   - Y1A processor core
--   - 8 KB program & data memory 
--   - I/O ports 
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
  
  
entity evb is

  port
    (
      clk     : in  std_logic;
      rst_l   : in  std_logic;   

      irq_l   : in  std_logic;   

      dip_sw  : in  std_logic_vector(3 downto 0); 
      led_bar : out std_logic_vector(3 downto 0);

      rx_bit  : in  std_logic;
      tx_bit  : out std_logic;

      tp      : out std_logic_vector(15 downto 0)
    );

  end evb;
  
  
architecture evb1 of evb is


  signal sync_rst    : std_logic; 

  signal i_en_l      : std_logic;
  signal i_rd_l      : std_logic;
  
  signal i_addr      : std_logic_vector(PC_MSB downto 0);
  signal i_dat       : std_logic_vector(I_DAT_MSB downto 0);
  
  signal d_stall     : std_logic;    
  signal d_stall_p1  : std_logic;    
  
  signal d_en_l      : std_logic;   
  signal d_rd_l      : std_logic;   
  signal d_wr_l      : std_logic;   
  signal d_wr_en_l   : std_logic_vector(3 downto 0);  
  
  signal d_addr      : std_logic_vector(ADDR_MSB downto 0);
  signal d_rdat      : std_logic_vector(D_DAT_MSB downto 0);
  signal d_wdat      : std_logic_vector(D_DAT_MSB downto 0);
  
  signal blkram_rdat : std_logic_vector(D_DAT_MSB downto 0);
  
  --
  -- uart support signals
  --
  signal tx_rdy      : std_logic;   
  signal rx_avail    : std_logic;   
  signal rx_dat      : std_logic_vector(7 downto 0);
  
  --
  -- local decodes
  --
  signal ram_cs_l    : std_logic;   

  signal dcd_uart    : std_logic;   
  signal dcd_uart_wr : std_logic;   
  signal dcd_uart_rd : std_logic;   
  
  --
  -- output port
  --
  signal out_reg1    : std_logic_vector(7 downto 0);
  signal in_reg1     : std_logic_vector(7 downto 0);
  
  
begin

  process
    begin
      wait until rising_edge(clk);

      sync_rst <= NOT rst_l;

    end process;


  evb_core: entity work.y1a_core
    generic map
      (
        CFG       =>  BIG_CONFIG
      )
    port map
      (
        clk       =>  clk,
        sync_rst  =>  sync_rst,
  
        irq_l     =>  irq_l,
  
        in_flags  =>  X"55AA",
  
        i_en_l    =>  i_en_l,
        i_rd_l    =>  i_rd_l,
  
        i_addr    =>  i_addr,
        i_dat     =>  i_dat,
  
        d_en_l    =>  d_en_l,
        d_rd_l    =>  d_rd_l,
        d_wr_l    =>  d_wr_l,
        d_wr_en_l =>  d_wr_en_l,
  
        d_stall   =>  d_stall,
        d_addr    =>  d_addr,
        d_rdat    =>  d_rdat,        
        d_wdat    =>  d_wdat        
      );         

  --
  -- data stall logic
  --

  -- no stalls
  d_stall <= '0';

  -- stall for all loads
  --d_stall <= (NOT d_en_l) AND (NOT d_rd_l) AND (NOT d_stall_p1);
  
  -- stall for RAM decode
  --d_stall <= (NOT ram_cs_l) AND (NOT d_rd_l) AND (NOT d_stall_p1);

  P_dstall_dly : process (clk, rst_l)
    begin
      if rst_l = '0' then
        d_stall_p1 <= '0';

      elsif rising_edge(clk) then
        d_stall_p1 <= d_stall;

      end if;

    end process P_dstall_dly;

  --
  -- shared memory spaces using dual port block RAM
  -- d_addr is currently hardcoded for 32 bit processor
  --
  ram_cs_l <= '0'  when (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"0" )
         else '1';

  I_blk_mem : entity work.rtl_mem
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

        i_addr    => i_addr(12 downto 2),
        i_dat     => i_dat
      );

  -- blockram data bus tristate
  d_rdat  <=   blkram_rdat when  ( ( d_rd_l = '0' ) AND ( ram_cs_l = '0' ) )
              else (others => 'Z');

  --
  -- note, UART decode signals are all active high
  --
  dcd_uart <=   '1'  when ( (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"C" ) )
           else '0';

  dcd_uart_wr <=   '1'  when (dcd_uart = '1') AND ( d_wr_l = '0' ) 
              else '0';

  dcd_uart_rd <=   '1'  when (dcd_uart = '1') AND ( d_wr_l = '1' )
              else '0';

  d_rdat <=   (ALU_MSB downto 8 => '0') & rx_dat  when ( dcd_uart_rd = '1' ) 
            else (others=>'Z');


  --
  -- simulation stand-in for UART
  --

  --
  -- dummy RX always returns a '?'
  --    ( help command when simulating YARDBUG ROM image )
  --
  rx_avail <= '1';
  rx_dat   <= X"3f";

  --
  -- dummy TX prints transmitted character for simulation
  --
  tx_bit  <= '1';
  tx_rdy  <= '1';

  P_uart_tx_mon: process
    variable L : line;

    begin

      wait until rising_edge(clk);

      if dcd_uart_wr = '1'  then
        write(L, ' ' );
        writeline(OUTPUT,L);

        write(L, now );

        write( L, string'(": UART_TX    byte=") );
        hwrite(L, d_wdat(7 downto 0) );

        write(L, ' ' );
        write(L, character'val(to_integer(unsigned(d_wdat(7 downto 0)))) );

        writeline( OUTPUT, L);

      end if;

    end process P_uart_tx_mon;


  --
  -- 8 bit output port
  --
  P_out_port: process (clk, rst_l)
    begin
      if rst_l = '0' then
        out_reg1 <= ( others => '1');
 
      elsif rising_edge(clk) then
 
        if (d_wr_l = '0') AND (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"8" ) then
          out_reg1 <= d_wdat(7 downto 0);
        end if;
 
      end if;
 
    end process P_out_port;
 
  --
  -- output port connections
  --
  --
  --  D7  
  --  D6
  --  D5
  --  D4
  --  D3  LED 3
  --  D2  LED 2 
  --  D1  LED 1
  --  D0  LED 0
  --
  
  --
  -- connect leds
  --
  led_bar <= out_reg1(3 downto 0);
 
  --
  -- 8 bit input port
  --
  P_in_port: process ( d_addr, d_rdat, d_en_l, d_rd_l, in_reg1 )
    begin
 
      if (d_en_l = '0') AND ( d_addr(ADDR_MSB downto ADDR_MSB-3) = X"8" ) then
 
        if d_rd_l = '0' then
          d_rdat <= (ALU_MSB downto 8 => '0') & in_reg1(7 downto 0);
 
        else
          d_rdat <= (others=>'Z');
 
        end if;
 
      else
        d_rdat <= (others=>'Z');
 
      end if;
 
    end process P_in_port;
 
  --
  -- input port connections
  --   input data clocked to hold data stable during processor read cycle
  --
  --  D7  UART TX buffer full status
  --  D6  UART RX data avail. status
  --  D5
  --  D4
  --  D3  SWITCH D3
  --  D2  SWITCH D2 
  --  D1  SWITCH D1
  --  D0  SWITCH D0
  --
  P_in_reg: process (clk)
    begin
      if rising_edge(clk) then
        in_reg1(7) <= tx_rdy;
        in_reg1(6) <= rx_avail;
        in_reg1(5) <= '0';
        in_reg1(4) <= '0';
        in_reg1(3 downto 0) <= dip_sw(3 downto 0);
 
      end if;
    end process P_in_reg;
 

  --
  -- register test point outputs
  --
  P_tp_reg : process
    begin
      wait until rising_edge(clk);

      -- tp <= X"00" & i_addr(7 downto 0);
      -- tp <= i_addr(15 downto 0);
      -- tp <= d_rdat(7 downto 0) & i_addr(7 downto 0);

      tp <= dcd_uart & dcd_uart_rd & dcd_uart_wr & '0' & d_addr(ADDR_MSB downto ADDR_MSB-3) & d_rdat(7 downto 0);

    end process P_tp_reg;

  --
  -- simulation probe signals
  --
  P_dbus_mon: process
    variable L : line;
 
    begin
  
      loop
  
        wait until rising_edge(clk);
  
        write(L, ' ' );
        writeline(OUTPUT,L);
  
        write(L, now );
  
        write( L, string'(": DBUS   d_addr="));
        hwrite(L,  d_addr );
  
        write( L, string'(" d_rdat="));
        hwrite(L,  d_rdat );
  
        write( L, string'(" d_wdat="));
        hwrite(L,  d_wdat );
  
        write( L, string'("  d_stall="));
        write(L, d_stall  );

        write( L, string'("  d_en*="));
        write(L, d_en_l  );
  
        write( L, string'(" d_rd*="));
        write(L, d_rd_l );
  
        write( L, string'(" d_wr*="));
        write(L, d_wr_l );
  
        write( L, string'(" d_wen*="));
        write(L,  d_wr_en_l  );
  
        writeline( OUTPUT, L);
  
      end loop;
  
    end process P_dbus_mon;
  
  
  
  P_ibus_mon: process
    variable L : line;
  
    begin
  
      loop
  
        wait until rising_edge(clk);
  
        write(L, ' ' );
        writeline(OUTPUT,L);
  
        write(L, now );
  
        write( L, string'(": IBUS   i_addr="));
        hwrite(L,  i_addr );
  
        write( L, string'(" i_dat="));
        hwrite(L,  i_dat );
  
        write( L, string'(" i_rd*="));
        write(L, i_rd_l  );
  
        writeline( OUTPUT, L);
  
      end loop;
  
    end process P_ibus_mon;


end evb1;

