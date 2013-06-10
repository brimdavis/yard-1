-- 
-- <ld_mux.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2013  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A byte/wyde/quad sign extending lane mux for loads
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity ld_mux is
  generic
    (
      CFG        : y1a_config_type
    );

  port
    (   
      dcd_mem_sign : in  std_logic;

      dcd_quad_ld  : in  boolean;
      dcd_wyde_ld  : in  boolean;
      dcd_byte_ld  : in  boolean;
                  
      ea_lsbs      : in  std_logic_vector(1 downto 0);

      d_rdat       : in  std_logic_vector(ALU_MSB downto 0);
                  
      mem_wb_bus   : out std_logic_vector(ALU_MSB downto 0)
    );

end ld_mux;


architecture arch1 of ld_mux is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  --
  -- msb fill for sign/zero extension
  --
  signal msb_fill : std_logic;


begin

  --
  -- check for illegal config/ALU width settings
  --
  assert ( CFG.non_native_load AND ( ALU_WIDTH = 32 ) ) OR ( NOT CFG.non_native_load )
    report "Unsupported load configuration flag and/or ALU_WIDTH settings."
    severity error;

  --
  --
  --
  GF_cnnl: if CFG.non_native_load = FALSE generate
    begin

      mem_wb_bus <=  d_rdat             when  dcd_quad_ld
                else ( others => '0' );

    end generate GF_cnnl;

 
  --
  -- mux rewritten per byte lane to reduce synthesis logic levels
  --
  GT_cnnl: if ( ALU_WIDTH = 32 ) and ( CFG.non_native_load = TRUE ) generate
    begin

      --
      -- msb fill for sign/zero extension
      --
      msb_fill <=  '0'         when  dcd_mem_sign = '0'
              else d_rdat(31)  when  ea_lsbs = B"00"
              else d_rdat(23)  when  ea_lsbs = B"01"
              else d_rdat(15)  when  ea_lsbs = B"10"
              else d_rdat( 7)  when  ea_lsbs = B"11"
              else 'X'
              ;
  
      --
      -- byte lane 3 mux (MSB)
      --
      mem_wb_bus(31 downto 24)
         <=   d_rdat(31 downto 24)      when  dcd_quad_ld

        else  ( others => msb_fill )
        ;

      --
      -- byte lane 2 mux
      --
      mem_wb_bus(23 downto 16) 
         <=   d_rdat(23 downto 16)      when  dcd_quad_ld

        else  ( others => msb_fill )
        ;

      --
      -- byte lane 1 mux
      --
      mem_wb_bus(15 downto 8)
         <=   d_rdat(31 downto 24)      when  ( dcd_wyde_ld AND ea_lsbs(1) = '0' )
        else  d_rdat(15 downto  8)      when  ( dcd_wyde_ld AND ea_lsbs(1) = '1' ) OR dcd_quad_ld

        else  ( others => msb_fill )
        ;

      --
      -- byte lane 0 mux (LSB)
      --
      mem_wb_bus(7 downto 0)
         <=   d_rdat(31 downto 24)  when ( dcd_byte_ld AND ea_lsbs = B"00" )
        else  d_rdat(23 downto 16)  when ( dcd_byte_ld AND ea_lsbs = B"01" ) OR ( dcd_wyde_ld AND ea_lsbs(1) = '0' )
        else  d_rdat(15 downto  8)  when ( dcd_byte_ld AND ea_lsbs = B"10" )
        else  d_rdat( 7 downto  0)  when ( dcd_byte_ld AND ea_lsbs = B"11" ) OR ( dcd_wyde_ld AND ea_lsbs(1) = '1' ) OR dcd_quad_ld
        else ( others => 'X' )
        ;


    end generate GT_cnnl;

end arch1;
