--
-- <rtl_mem.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2008-2013  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A inferred blockram
--
--   - dual port BRAM for data & instruction memory 
--
--   - memories are inferred from initialized arrays
--
--   - falling edge clk used to hide BRAM register latency
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.mem_dat_pkg.all;


entity rtl_mem is
  port
    (   
      clk       : in std_logic;

      d_cs_l    : in  std_logic;    
      d_rd_l    : in  std_logic;    
      d_wr_l    : in  std_logic;
      d_wr_en_l : in  std_logic_vector(3 downto 0); 

      d_addr    : in  std_logic_vector(10 downto 0);
      d_rdat    : out std_logic_vector(D_DAT_MSB downto 0);
      d_wdat    : in  std_logic_vector(D_DAT_MSB downto 0);

      i_addr    : in  std_logic_vector(11 downto 0);
      i_dat     : out std_logic_vector(I_DAT_MSB downto 0)
    );


end rtl_mem;


architecture arch1 of rtl_mem is

  signal loc_rdat, loc_wdat : std_logic_vector (ALU_MSB downto 0);
  signal loc_i_dat          : std_logic_vector (31 downto 0);

  signal d_we3,d_we2,d_we1,d_we0 : std_logic;
  signal d_en   : std_logic;

  signal  din3,  din2,  din1,  din0 : std_logic_vector(7 downto 0);
  signal dout3, dout2, dout1, dout0 : std_logic_vector(7 downto 0);
  signal iout3, iout2, iout1, iout0 : std_logic_vector(7 downto 0);

  signal ram_b3 : mem_type  := mem_dat_b3;
  signal ram_b2 : mem_type  := mem_dat_b2;
  signal ram_b1 : mem_type  := mem_dat_b1;
  signal ram_b0 : mem_type  := mem_dat_b0;


begin

  --
  -- inst. bus out
  --
  i_dat  <=   loc_i_dat;

  --
  -- data bus out
  --
  d_rdat <= loc_rdat;

  --
  -- internal bus and control signals
  --
  loc_wdat <= d_wdat;

  d_en     <= NOT d_cs_l;

  d_we3    <= d_en AND ( NOT d_wr_l ) AND ( NOT d_wr_en_l(3));
  d_we2    <= d_en AND ( NOT d_wr_l ) AND ( NOT d_wr_en_l(2));
  d_we1    <= d_en AND ( NOT d_wr_l ) AND ( NOT d_wr_en_l(1));
  d_we0    <= d_en AND ( NOT d_wr_l ) AND ( NOT d_wr_en_l(0));

  --
  -- infer byte lane 3 dual port
  --
  process(clk)
    begin
      if falling_edge(clk) then

        if d_we3 = '1' then
          ram_b3(to_integer(unsigned(d_addr))) <= din3;
        end if;

        dout3 <= ram_b3( to_integer( unsigned(d_addr) ) );

      end if;

      if falling_edge(clk) then
        iout3 <= ram_b3( to_integer( unsigned(i_addr(i_addr'left downto 1)) ) );
      end if;

    end process;

  din3 <= loc_wdat(31 downto 24);
  loc_rdat (31 downto 24) <= dout3;
  loc_i_dat(31 downto 24) <= iout3;


  --
  -- infer byte lane 2 dual port
  --
  process(clk)
    begin
      if falling_edge(clk) then

        if d_we2 = '1' then
          ram_b2(to_integer(unsigned(d_addr))) <= din2;
        end if;

        dout2 <= ram_b2( to_integer( unsigned(d_addr) ) );

      end if;

      if falling_edge(clk) then
        iout2 <= ram_b2( to_integer( unsigned(i_addr(i_addr'left downto 1)) ) );
      end if;

    end process;

  din2 <= loc_wdat(23 downto 16);
  loc_rdat (23 downto 16) <= dout2;
  loc_i_dat(23 downto 16) <= iout2;


  --
  -- infer byte lane 1 dual port
  --
  process(clk)
    begin
      if falling_edge(clk) then

        if d_we1 = '1' then
          ram_b1(to_integer(unsigned(d_addr))) <= din1;
        end if;

        dout1 <= ram_b1( to_integer( unsigned(d_addr) ) );

      end if;

      if falling_edge(clk) then
        iout1 <= ram_b1( to_integer( unsigned(i_addr(i_addr'left downto 1)) ) );
      end if;

    end process;

  din1 <= loc_wdat(15 downto 8);
  loc_rdat (15 downto 8) <= dout1;
  loc_i_dat(15 downto 8) <= iout1;


  --
  -- infer byte lane 0 dual port
  --
  process(clk)
    begin
      if falling_edge(clk) then

        if d_we0 = '1' then
          ram_b0(to_integer(unsigned(d_addr))) <= din0;
        end if;

        dout0 <= ram_b0( to_integer( unsigned(d_addr) ) );

      end if;

      if falling_edge(clk) then
        iout0 <= ram_b0( to_integer( unsigned(i_addr(i_addr'left downto 1)) ) );
      end if;

    end process;

  din0 <= loc_wdat(7 downto 0);
  loc_rdat (7 downto 0) <= dout0;
  loc_i_dat(7 downto 0) <= iout0;

end arch1;






