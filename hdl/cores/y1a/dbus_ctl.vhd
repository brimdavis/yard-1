-- 
-- <dbus_ctl.vhd>
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
-- Y1A data bus control lines
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity dbus_ctl is

  port
    (   
      inst_fld  : in  std_logic_vector(ID_MSB downto 0);
      ex_null   : in  std_logic;
      mem_size  : in  std_logic_vector(1 downto 0);
      lea_bit   : in  std_logic;

      ea_dat    : in  std_logic_vector(ALU_MSB downto 0);

      d_en_l    : out std_logic;	
      d_rd_l    : out std_logic;	
      d_wr_l    : out std_logic;
      d_wr_en_l : out std_logic_vector(3 downto 0)
    );

end dbus_ctl;


architecture arch1 of dbus_ctl is


begin

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

  d_en_l <=  '0'   when (
                              (   inst_fld = OPM_LD ) 
                          OR  (   inst_fld = OPM_LDI )
                          OR  ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) 
                        )
                        AND ( ex_null = '0' )
        else '1';


  d_wr_l <=  '0'   when     ( ( inst_fld = OPM_ST ) AND (lea_bit = '0') ) 
                        AND ( ex_null = '0' )
        else '1';

  
  d_rd_l <=  '0'   when (
                              ( inst_fld = OPM_LD ) 
                          OR  ( inst_fld = OPM_LDI )
                        )
                        AND ( ex_null = '0' )
        else '1';

  --
  -- byte enables
  --
  gen_wen32: if ALU_WIDTH = 32 generate
    begin

      -- first cut at byte write enables, should add enable gating

        d_wr_en_l 
            <=   B"0000"  when ( mem_size = MEM_32_SP ) AND ( ea_dat(1 downto 0) = "00" )
           else  B"0000"  when ( mem_size = MEM_32    ) AND ( ea_dat(1 downto 0) = "00" )

           else  B"0011"  when ( mem_size = MEM_16    ) AND ( ea_dat(1 downto 0) = "00" )    
           else  B"1100"  when ( mem_size = MEM_16    ) AND ( ea_dat(1 downto 0) = "10" )    

           else  B"0111"  when ( mem_size = MEM_8     ) AND ( ea_dat(1 downto 0) = "00" )    
           else  B"1011"  when ( mem_size = MEM_8     ) AND ( ea_dat(1 downto 0) = "01" )    
           else  B"1101"  when ( mem_size = MEM_8     ) AND ( ea_dat(1 downto 0) = "10" )    
           else  B"1110"  when ( mem_size = MEM_8     ) AND ( ea_dat(1 downto 0) = "11" )    
  
           else  B"1111" ;
  
    end generate gen_wen32;
 
end arch1;
