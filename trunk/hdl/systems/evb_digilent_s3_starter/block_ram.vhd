--
-- <block_ram.vhd>
--
-- Y1A EVB blockram - BRAM16's
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
-- NOTE: use for synthesis only, delta delay on CLK from port inversions into
--       BRAM primitive could cause functional hold problems for RTL sims
--       
--       
-- initialized dual port block RAM for data & instruction RAM
--
-- BRAM16 version
--
-- falling edge clocks used to hide BRAM clk latency:
--   I_DAT  : falling edge clock
--   D_xDAT : falling edge clock
--
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim; 
  use unisim.vcomponents.all; 

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;
  use work.mem_init_pkg.all;


entity blk_mem is
  port
    (   
      clk       : in std_logic;

      d_cs_l    : in  std_logic;    
      d_rd_l    : in  std_logic;    
      d_wr_l    : in  std_logic;
      d_wr_en_l : in  std_logic_vector(3 downto 0); 

      d_addr    : in  std_logic_vector (10 downto 0);
      d_rdat    : out std_logic_vector(ALU_MSB downto 0);
      d_wdat    : in  std_logic_vector(ALU_MSB downto 0);

      i_addr    : in  std_logic_vector  (11 downto 0);
      i_dat     : out std_logic_vector (INST_MSB downto 0)
    );


end blk_mem;


architecture arch1 of blk_mem is

  signal loc_rdat, loc_wdat       : std_logic_vector (ALU_MSB downto 0);
  signal loc_i_dat                : std_logic_vector (31 downto 0);

  signal d_we3,d_we2,d_we1,d_we0  : std_logic;
  signal d_en                     : std_logic;

  signal lsb_p1                   : std_logic;

begin

  --
  -- delay LSB of address for i_dat mux
  --
  delay_lsb: process
    begin
      wait until falling_edge(clk);
      lsb_p1 <= i_addr(0);
    end process;

  --
  -- big-endian mux instruction bus output from 32 to 16 bits 
  -- inst. bus not tristated (for speed), currently can only have one driver
  --
  i_dat <=   loc_i_dat(15 downto  0) when ( lsb_p1 = '1' )
        else loc_i_dat(31 downto 16);

    

  --
  -- connect local data bus signals to ports
  --
  d_rdat  <= loc_rdat;

  loc_wdat <= d_wdat;

  --
  -- data and byte enables
  --
  d_en  <= NOT d_cs_l;

  d_we3 <= ( NOT d_wr_l ) AND ( NOT d_wr_en_l(3));
  d_we2 <= ( NOT d_wr_l ) AND ( NOT d_wr_en_l(2));
  d_we1 <= ( NOT d_wr_l ) AND ( NOT d_wr_en_l(1));
  d_we0 <= ( NOT d_wr_l ) AND ( NOT d_wr_en_l(0));

  RAM3 : RAMB16_S9_S9 
    generic map
      (
        INIT_00 => RAM3_BV_INIT_00, INIT_01 => RAM3_BV_INIT_01, INIT_02 => RAM3_BV_INIT_02, INIT_03 => RAM3_BV_INIT_03, 
        INIT_04 => RAM3_BV_INIT_04, INIT_05 => RAM3_BV_INIT_05, INIT_06 => RAM3_BV_INIT_06, INIT_07 => RAM3_BV_INIT_07,
        INIT_08 => RAM3_BV_INIT_08, INIT_09 => RAM3_BV_INIT_09, INIT_0A => RAM3_BV_INIT_0A, INIT_0B => RAM3_BV_INIT_0B, 
        INIT_0C => RAM3_BV_INIT_0C, INIT_0D => RAM3_BV_INIT_0D, INIT_0E => RAM3_BV_INIT_0E, INIT_0F => RAM3_BV_INIT_0F,

        INIT_10 => RAM3_BV_INIT_10, INIT_11 => RAM3_BV_INIT_11, INIT_12 => RAM3_BV_INIT_12, INIT_13 => RAM3_BV_INIT_13, 
        INIT_14 => RAM3_BV_INIT_14, INIT_15 => RAM3_BV_INIT_15, INIT_16 => RAM3_BV_INIT_16, INIT_17 => RAM3_BV_INIT_17,
        INIT_18 => RAM3_BV_INIT_18, INIT_19 => RAM3_BV_INIT_19, INIT_1A => RAM3_BV_INIT_1A, INIT_1B => RAM3_BV_INIT_1B, 
        INIT_1C => RAM3_BV_INIT_1C, INIT_1D => RAM3_BV_INIT_1D, INIT_1E => RAM3_BV_INIT_1E, INIT_1F => RAM3_BV_INIT_1F,

        INIT_20 => RAM3_BV_INIT_20, INIT_21 => RAM3_BV_INIT_21, INIT_22 => RAM3_BV_INIT_22, INIT_23 => RAM3_BV_INIT_23, 
        INIT_24 => RAM3_BV_INIT_24, INIT_25 => RAM3_BV_INIT_25, INIT_26 => RAM3_BV_INIT_26, INIT_27 => RAM3_BV_INIT_27,
        INIT_28 => RAM3_BV_INIT_28, INIT_29 => RAM3_BV_INIT_29, INIT_2A => RAM3_BV_INIT_2A, INIT_2B => RAM3_BV_INIT_2B, 
        INIT_2C => RAM3_BV_INIT_2C, INIT_2D => RAM3_BV_INIT_2D, INIT_2E => RAM3_BV_INIT_2E, INIT_2F => RAM3_BV_INIT_2F,

        INIT_30 => RAM3_BV_INIT_30, INIT_31 => RAM3_BV_INIT_31, INIT_32 => RAM3_BV_INIT_32, INIT_33 => RAM3_BV_INIT_33, 
        INIT_34 => RAM3_BV_INIT_34, INIT_35 => RAM3_BV_INIT_35, INIT_36 => RAM3_BV_INIT_36, INIT_37 => RAM3_BV_INIT_37,
        INIT_38 => RAM3_BV_INIT_38, INIT_39 => RAM3_BV_INIT_39, INIT_3A => RAM3_BV_INIT_3A, INIT_3B => RAM3_BV_INIT_3B, 
        INIT_3C => RAM3_BV_INIT_3C, INIT_3D => RAM3_BV_INIT_3D, INIT_3E => RAM3_BV_INIT_3E, INIT_3F => RAM3_BV_INIT_3F
      )

    port map
     (
      ADDRA => i_addr (11 downto 1),

      DIPA  => ( others => '0' ),
      DIPB  => ( others => '0' ),

      DIA   => ( X"00" ),
      DOA   => loc_i_dat(31 downto 24),

      CLKA  => NOT clk,
      ENA   => '1', 
      WEA   => '0',
      SSRA  => '0', 

      ADDRB => d_addr(10 downto 0),

      DIB   => loc_wdat(31 downto 24),
      DOB   => loc_rdat(31 downto 24),

      CLKB  => NOT clk,
      ENB   => d_en, 
      WEB   => d_we3,
      SSRB  => '0'
     );


  RAM2 : RAMB16_S9_S9
    generic map
      (
        INIT_00 => RAM2_BV_INIT_00, INIT_01 => RAM2_BV_INIT_01, INIT_02 => RAM2_BV_INIT_02, INIT_03 => RAM2_BV_INIT_03, 
        INIT_04 => RAM2_BV_INIT_04, INIT_05 => RAM2_BV_INIT_05, INIT_06 => RAM2_BV_INIT_06, INIT_07 => RAM2_BV_INIT_07,
        INIT_08 => RAM2_BV_INIT_08, INIT_09 => RAM2_BV_INIT_09, INIT_0A => RAM2_BV_INIT_0A, INIT_0B => RAM2_BV_INIT_0B, 
        INIT_0C => RAM2_BV_INIT_0C, INIT_0D => RAM2_BV_INIT_0D, INIT_0E => RAM2_BV_INIT_0E, INIT_0F => RAM2_BV_INIT_0F,

        INIT_10 => RAM2_BV_INIT_10, INIT_11 => RAM2_BV_INIT_11, INIT_12 => RAM2_BV_INIT_12, INIT_13 => RAM2_BV_INIT_13, 
        INIT_14 => RAM2_BV_INIT_14, INIT_15 => RAM2_BV_INIT_15, INIT_16 => RAM2_BV_INIT_16, INIT_17 => RAM2_BV_INIT_17,
        INIT_18 => RAM2_BV_INIT_18, INIT_19 => RAM2_BV_INIT_19, INIT_1A => RAM2_BV_INIT_1A, INIT_1B => RAM2_BV_INIT_1B, 
        INIT_1C => RAM2_BV_INIT_1C, INIT_1D => RAM2_BV_INIT_1D, INIT_1E => RAM2_BV_INIT_1E, INIT_1F => RAM2_BV_INIT_1F,

        INIT_20 => RAM2_BV_INIT_20, INIT_21 => RAM2_BV_INIT_21, INIT_22 => RAM2_BV_INIT_22, INIT_23 => RAM2_BV_INIT_23, 
        INIT_24 => RAM2_BV_INIT_24, INIT_25 => RAM2_BV_INIT_25, INIT_26 => RAM2_BV_INIT_26, INIT_27 => RAM2_BV_INIT_27,
        INIT_28 => RAM2_BV_INIT_28, INIT_29 => RAM2_BV_INIT_29, INIT_2A => RAM2_BV_INIT_2A, INIT_2B => RAM2_BV_INIT_2B, 
        INIT_2C => RAM2_BV_INIT_2C, INIT_2D => RAM2_BV_INIT_2D, INIT_2E => RAM2_BV_INIT_2E, INIT_2F => RAM2_BV_INIT_2F,

        INIT_30 => RAM2_BV_INIT_30, INIT_31 => RAM2_BV_INIT_31, INIT_32 => RAM2_BV_INIT_32, INIT_33 => RAM2_BV_INIT_33, 
        INIT_34 => RAM2_BV_INIT_34, INIT_35 => RAM2_BV_INIT_35, INIT_36 => RAM2_BV_INIT_36, INIT_37 => RAM2_BV_INIT_37,
        INIT_38 => RAM2_BV_INIT_38, INIT_39 => RAM2_BV_INIT_39, INIT_3A => RAM2_BV_INIT_3A, INIT_3B => RAM2_BV_INIT_3B, 
        INIT_3C => RAM2_BV_INIT_3C, INIT_3D => RAM2_BV_INIT_3D, INIT_3E => RAM2_BV_INIT_3E, INIT_3F => RAM2_BV_INIT_3F
      )

    port map
    (
      ADDRA => i_addr (11 downto 1),

      DIPA  => ( others => '0' ),
      DIPB  => ( others => '0' ),

      DIA   => ( X"00" ),
      DOA   => loc_i_dat(23 downto 16),

      CLKA  => NOT clk,
      ENA   => '1', 
      WEA   => '0',
      SSRA  => '0', 

      ADDRB => d_addr( 10 downto 0),

      DIB   => loc_wdat(23 downto 16),
      DOB   => loc_rdat(23 downto 16),

      CLKB  => NOT clk,
      ENB   => d_en, 
      WEB   => d_we2,
      SSRB  => '0' 
    );


  RAM1 : RAMB16_S9_S9
    generic map
      (
        INIT_00 => RAM1_BV_INIT_00, INIT_01 => RAM1_BV_INIT_01, INIT_02 => RAM1_BV_INIT_02, INIT_03 => RAM1_BV_INIT_03, 
        INIT_04 => RAM1_BV_INIT_04, INIT_05 => RAM1_BV_INIT_05, INIT_06 => RAM1_BV_INIT_06, INIT_07 => RAM1_BV_INIT_07,
        INIT_08 => RAM1_BV_INIT_08, INIT_09 => RAM1_BV_INIT_09, INIT_0A => RAM1_BV_INIT_0A, INIT_0B => RAM1_BV_INIT_0B, 
        INIT_0C => RAM1_BV_INIT_0C, INIT_0D => RAM1_BV_INIT_0D, INIT_0E => RAM1_BV_INIT_0E, INIT_0F => RAM1_BV_INIT_0F,

        INIT_10 => RAM1_BV_INIT_10, INIT_11 => RAM1_BV_INIT_11, INIT_12 => RAM1_BV_INIT_12, INIT_13 => RAM1_BV_INIT_13, 
        INIT_14 => RAM1_BV_INIT_14, INIT_15 => RAM1_BV_INIT_15, INIT_16 => RAM1_BV_INIT_16, INIT_17 => RAM1_BV_INIT_17,
        INIT_18 => RAM1_BV_INIT_18, INIT_19 => RAM1_BV_INIT_19, INIT_1A => RAM1_BV_INIT_1A, INIT_1B => RAM1_BV_INIT_1B, 
        INIT_1C => RAM1_BV_INIT_1C, INIT_1D => RAM1_BV_INIT_1D, INIT_1E => RAM1_BV_INIT_1E, INIT_1F => RAM1_BV_INIT_1F,

        INIT_20 => RAM1_BV_INIT_20, INIT_21 => RAM1_BV_INIT_21, INIT_22 => RAM1_BV_INIT_22, INIT_23 => RAM1_BV_INIT_23, 
        INIT_24 => RAM1_BV_INIT_24, INIT_25 => RAM1_BV_INIT_25, INIT_26 => RAM1_BV_INIT_26, INIT_27 => RAM1_BV_INIT_27,
        INIT_28 => RAM1_BV_INIT_28, INIT_29 => RAM1_BV_INIT_29, INIT_2A => RAM1_BV_INIT_2A, INIT_2B => RAM1_BV_INIT_2B, 
        INIT_2C => RAM1_BV_INIT_2C, INIT_2D => RAM1_BV_INIT_2D, INIT_2E => RAM1_BV_INIT_2E, INIT_2F => RAM1_BV_INIT_2F,

        INIT_30 => RAM1_BV_INIT_30, INIT_31 => RAM1_BV_INIT_31, INIT_32 => RAM1_BV_INIT_32, INIT_33 => RAM1_BV_INIT_33, 
        INIT_34 => RAM1_BV_INIT_34, INIT_35 => RAM1_BV_INIT_35, INIT_36 => RAM1_BV_INIT_36, INIT_37 => RAM1_BV_INIT_37,
        INIT_38 => RAM1_BV_INIT_38, INIT_39 => RAM1_BV_INIT_39, INIT_3A => RAM1_BV_INIT_3A, INIT_3B => RAM1_BV_INIT_3B, 
        INIT_3C => RAM1_BV_INIT_3C, INIT_3D => RAM1_BV_INIT_3D, INIT_3E => RAM1_BV_INIT_3E, INIT_3F => RAM1_BV_INIT_3F
      )

    port map
    (
      ADDRA => i_addr (11 downto 1),

      DIPA  => ( others => '0' ),
      DIPB  => ( others => '0' ),

      DIA   => ( X"00" ),
      DOA   => loc_i_dat( 15 downto  8),

      CLKA  => NOT clk,
      ENA   => '1', 
      WEA   => '0',
      SSRA  => '0', 

      ADDRB => d_addr( 10 downto 0),
      DIB   => loc_wdat(15 downto  8),
      DOB   => loc_rdat(15 downto  8),

      CLKB  => NOT clk,
      ENB   => d_en, 
      WEB   => d_we1,
      SSRB  => '0' 
    );


  RAM0 : RAMB16_S9_S9
    generic map
      (
        INIT_00 => RAM0_BV_INIT_00, INIT_01 => RAM0_BV_INIT_01, INIT_02 => RAM0_BV_INIT_02, INIT_03 => RAM0_BV_INIT_03, 
        INIT_04 => RAM0_BV_INIT_04, INIT_05 => RAM0_BV_INIT_05, INIT_06 => RAM0_BV_INIT_06, INIT_07 => RAM0_BV_INIT_07,
        INIT_08 => RAM0_BV_INIT_08, INIT_09 => RAM0_BV_INIT_09, INIT_0A => RAM0_BV_INIT_0A, INIT_0B => RAM0_BV_INIT_0B, 
        INIT_0C => RAM0_BV_INIT_0C, INIT_0D => RAM0_BV_INIT_0D, INIT_0E => RAM0_BV_INIT_0E, INIT_0F => RAM0_BV_INIT_0F,

        INIT_10 => RAM0_BV_INIT_10, INIT_11 => RAM0_BV_INIT_11, INIT_12 => RAM0_BV_INIT_12, INIT_13 => RAM0_BV_INIT_13, 
        INIT_14 => RAM0_BV_INIT_14, INIT_15 => RAM0_BV_INIT_15, INIT_16 => RAM0_BV_INIT_16, INIT_17 => RAM0_BV_INIT_17,
        INIT_18 => RAM0_BV_INIT_18, INIT_19 => RAM0_BV_INIT_19, INIT_1A => RAM0_BV_INIT_1A, INIT_1B => RAM0_BV_INIT_1B, 
        INIT_1C => RAM0_BV_INIT_1C, INIT_1D => RAM0_BV_INIT_1D, INIT_1E => RAM0_BV_INIT_1E, INIT_1F => RAM0_BV_INIT_1F,

        INIT_20 => RAM0_BV_INIT_20, INIT_21 => RAM0_BV_INIT_21, INIT_22 => RAM0_BV_INIT_22, INIT_23 => RAM0_BV_INIT_23, 
        INIT_24 => RAM0_BV_INIT_24, INIT_25 => RAM0_BV_INIT_25, INIT_26 => RAM0_BV_INIT_26, INIT_27 => RAM0_BV_INIT_27,
        INIT_28 => RAM0_BV_INIT_28, INIT_29 => RAM0_BV_INIT_29, INIT_2A => RAM0_BV_INIT_2A, INIT_2B => RAM0_BV_INIT_2B, 
        INIT_2C => RAM0_BV_INIT_2C, INIT_2D => RAM0_BV_INIT_2D, INIT_2E => RAM0_BV_INIT_2E, INIT_2F => RAM0_BV_INIT_2F,

        INIT_30 => RAM0_BV_INIT_30, INIT_31 => RAM0_BV_INIT_31, INIT_32 => RAM0_BV_INIT_32, INIT_33 => RAM0_BV_INIT_33, 
        INIT_34 => RAM0_BV_INIT_34, INIT_35 => RAM0_BV_INIT_35, INIT_36 => RAM0_BV_INIT_36, INIT_37 => RAM0_BV_INIT_37,
        INIT_38 => RAM0_BV_INIT_38, INIT_39 => RAM0_BV_INIT_39, INIT_3A => RAM0_BV_INIT_3A, INIT_3B => RAM0_BV_INIT_3B, 
        INIT_3C => RAM0_BV_INIT_3C, INIT_3D => RAM0_BV_INIT_3D, INIT_3E => RAM0_BV_INIT_3E, INIT_3F => RAM0_BV_INIT_3F
      )

    port map
    (
      ADDRA => i_addr (11 downto 1),

      DIPA  => ( others => '0' ),
      DIPB  => ( others => '0' ),

      DIA   => ( X"00" ),
      DOA   => loc_i_dat( 7 downto  0),

      CLKA  => NOT clk,
      ENA   => '1', 
      WEA   => '0',
      SSRA  => '0', 

      ADDRB => d_addr( 10 downto 0),
      DIB   => loc_wdat( 7 downto  0),
      DOB   => loc_rdat( 7 downto  0),

      CLKB  => NOT clk,
      ENB   => d_en, 
      WEB   => d_we0,
      SSRB  => '0' 
    );


end arch1;




