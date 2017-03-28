--
-- <rtl_mem.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2008-2013,2017  Brian Davis
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
--   - changed RAM to use write-first modeling 
--      ( by registering address in clocked process and reading outside clocked process) 
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

      d_cs      : in  std_logic;    
      d_rd      : in  std_logic;    
      d_wr      : in  std_logic;
      d_bwe     : in  std_logic_vector(3 downto 0); 

      d_addr    : in  std_logic_vector;
      d_rdat    : out std_logic_vector(D_DAT_MSB downto 0);
      d_wdat    : in  std_logic_vector(D_DAT_MSB downto 0);

      i_addr    : in  std_logic_vector;
      i_dat     : out std_logic_vector(I_DAT_MSB downto 0)
    );

end rtl_mem;


architecture arch1 of rtl_mem is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal loc_rdat   : std_logic_vector (D_DAT_MSB downto 0);
  signal loc_wdat   : std_logic_vector (D_DAT_MSB downto 0);
  signal loc_i_dat  : std_logic_vector (I_DAT_MSB downto 0);

  signal d_en       : std_logic;

  signal din3       : std_logic_vector(7 downto 0);
  signal din2       : std_logic_vector(7 downto 0);
  signal din1       : std_logic_vector(7 downto 0);
  signal din0       : std_logic_vector(7 downto 0);

  signal dout3      : std_logic_vector(7 downto 0);
  signal dout2      : std_logic_vector(7 downto 0);
  signal dout1      : std_logic_vector(7 downto 0);
  signal dout0      : std_logic_vector(7 downto 0);

  signal iout3      : std_logic_vector(7 downto 0);
  signal iout2      : std_logic_vector(7 downto 0);
  signal iout1      : std_logic_vector(7 downto 0);
  signal iout0      : std_logic_vector(7 downto 0);

  signal ram_b3     : mem_type  := mem_dat_b3;
  signal ram_b2     : mem_type  := mem_dat_b2;
  signal ram_b1     : mem_type  := mem_dat_b1;
  signal ram_b0     : mem_type  := mem_dat_b0;


  --
  -- prevent Synplify from wrapping RAMs with write bypass logic
  --
  attribute syn_ramstyle : string;

  attribute syn_ramstyle of ram_b3 : signal is "no_rw_check";
  attribute syn_ramstyle of ram_b2 : signal is "no_rw_check";
  attribute syn_ramstyle of ram_b1 : signal is "no_rw_check";
  attribute syn_ramstyle of ram_b0 : signal is "no_rw_check";


begin

  --
  -- inst. bus out
  --
  i_dat    <=  loc_i_dat;

  --
  -- data bus 
  --
  d_rdat   <=  loc_rdat;

  --
  -- internal bus and control signals
  --

  loc_rdat  <= dout3 & dout2 & dout1 & dout0;

  loc_i_dat <= iout3 & iout2 & iout1 & iout0;

  loc_wdat  <= d_wdat;

  d_en  <= d_cs;

  --
  -- infer byte lane 3 dual port
  --
  process(clk)

    begin
      if falling_edge(clk) then

        iout3 <= ram_b3( to_integer( unsigned(i_addr) ) );

        if ( d_en = '1' ) then

          if d_bwe(3) = '1' then
            ram_b3(to_integer(unsigned(d_addr))) <= din3;
          end if;

          dout3 <= ram_b3( to_integer( unsigned(d_addr) ) );
 
        end if;

      end if;
    end process;


  din3 <= loc_wdat(31 downto 24);


  --
  -- infer byte lane 2 dual port
  --
  process(clk)

    begin
      if falling_edge(clk) then

        iout2 <= ram_b2( to_integer( unsigned(i_addr) ) );

        if ( d_en = '1' ) then

          if d_bwe(2) = '1' then
            ram_b2(to_integer(unsigned(d_addr))) <= din2;

          end if;

          dout2 <= ram_b2( to_integer( unsigned(d_addr) ) );

        end if;

      end if;
    end process;


  din2 <= loc_wdat(23 downto 16);


  --
  -- infer byte lane 1 dual port
  --
  process(clk)

    begin
      if falling_edge(clk) then

        iout1 <= ram_b1( to_integer( unsigned(i_addr) ) );

        if ( d_en = '1' ) then

          if d_bwe(1) = '1' then
            ram_b1(to_integer(unsigned(d_addr))) <= din1;
          end if;

          dout1 <= ram_b1( to_integer( unsigned(d_addr) ) );

        end if;

      end if;

    end process;

  din1 <= loc_wdat(15 downto 8);


  --
  -- infer byte lane 0 dual port
  --
  process(clk)

    begin
      if falling_edge(clk) then

        iout0 <= ram_b0( to_integer( unsigned(i_addr) ) );

        if ( d_en = '1' ) then

          if d_bwe(0) = '1' then
            ram_b0(to_integer(unsigned(d_addr))) <= din0;
          end if;

          dout0 <= ram_b0( to_integer( unsigned(d_addr) ) );

        end if;

      end if;
    end process;

  din0 <= loc_wdat(7 downto 0);


end arch1;




