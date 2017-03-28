-- 
-- <dbus_ctl.vhd>
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
-- Y1A data bus control lines
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity dbus_ctl is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      clk       : in  std_logic;
      sync_rst  : in  std_logic;

      inst      : in  std_logic_vector(INST_MSB downto 0);
      stall     : in  std_logic;

      ex_null   : in  std_logic;

      ea_lsbs   : in  std_logic_vector(1 downto 0);

      d_en      : out std_logic; 
      d_rd      : out std_logic; 
      d_wr      : out std_logic;
      d_bwe     : out std_logic_vector(3 downto 0)
    );

end dbus_ctl;


architecture arch1 of dbus_ctl is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  signal valid_wr    : std_logic;

  --
  -- instruction register
  --
  signal ireg        : std_logic_vector(INST_MSB downto 0);

  --
  --
  --
  alias inst_fld     : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  alias mem_size     : std_logic_vector(1 downto 0)          is ireg(10 downto 9);
  alias lea_bit      : std_logic                             is ireg(8);

begin

  --
  -- local instruction register
  --
  P_ireg: process
  begin
    wait until rising_edge(clk);

    if sync_rst = '1' then
      ireg  <= ( others => '0');

    elsif stall = '0' then
      ireg  <= inst;

    end if;

  end process;


  --
  -- common decode for writes
  --
  valid_wr <=  '1'   when     ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) 
                          AND ( ex_null = '0' )
          else '0';


  --
  --   original design:
  --      assumed async read RAM fast enough for single cycle reads
  --      needed sync. write port
  --      BMD DANGER: original WR & CS logic doesn't pulse for back to back cycles
  --
  --    for blockram design:
  --       quick hack to add load stall on a memory read to account for blockram pipeline delay
  --
  --


  d_en   <=  '1'   when (
                              (   inst_fld = OPM_LD ) 
                          OR  (   inst_fld = OPM_LDI )
                          OR  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) 
                        )
                        AND ( ex_null = '0' )
        else '0';


  d_wr   <=  valid_wr;

  
  d_rd   <=  '1'   when (
                              ( inst_fld = OPM_LD ) 
                          OR  ( inst_fld = OPM_LDI )
                        )
                        AND ( ex_null = '0' )
        else '0';

  --
  -- byte enables
  --
  gen_wen32: if ALU_WIDTH = 32 generate
    begin

      -- added byte write enable gating so memories can look at just byte write enables

        d_bwe     
            <=   B"1111"  when ( mem_size = MEM_32_SP ) AND ( ea_lsbs(1 downto 0) = "00" ) AND ( valid_wr = '1' )
           else  B"1111"  when ( mem_size = MEM_32    ) AND ( ea_lsbs(1 downto 0) = "00" ) AND ( valid_wr = '1' )

           else  B"1100"  when ( mem_size = MEM_16    ) AND ( ea_lsbs(1 downto 0) = "00" ) AND ( valid_wr = '1' )    
           else  B"0011"  when ( mem_size = MEM_16    ) AND ( ea_lsbs(1 downto 0) = "10" ) AND ( valid_wr = '1' )    

           else  B"1000"  when ( mem_size = MEM_8     ) AND ( ea_lsbs(1 downto 0) = "00" ) AND ( valid_wr = '1' )    
           else  B"0100"  when ( mem_size = MEM_8     ) AND ( ea_lsbs(1 downto 0) = "01" ) AND ( valid_wr = '1' )    
           else  B"0010"  when ( mem_size = MEM_8     ) AND ( ea_lsbs(1 downto 0) = "10" ) AND ( valid_wr = '1' )    
           else  B"0001"  when ( mem_size = MEM_8     ) AND ( ea_lsbs(1 downto 0) = "11" ) AND ( valid_wr = '1' )    
  
           else  B"0000" ;
  
    end generate gen_wen32;
 
end arch1;







