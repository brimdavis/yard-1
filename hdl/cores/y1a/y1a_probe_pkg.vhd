--
-- <y1a_probe_pkg.vhd>
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
-- Y1A probe support file
--
--    global record used for simulation probes
--


library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;


package y1a_probe_pkg is

  type y1a_probe_type is record

     --
     -- operands
     --
     ain         : std_logic_vector(ALU_MSB downto 0);
     bin         : std_logic_vector(ALU_MSB downto 0);

     --
     -- constant generator
     --
     cg_out      : std_logic_vector(ALU_MSB downto 0);    

     imm_reg     : std_logic_vector(SR_MSB downto 0);

     --
     -- writeback bus
     --
     wb_bus      : std_logic_vector(ALU_MSB downto 0);
     wb_en       : std_logic;
     wb_ra       : std_logic_vector(3 downto 0) ;

     --
     -- ea calc
     --
     ea_off_mux  : std_logic_vector(ALU_MSB downto 0);
     ea_reg_mux  : std_logic_vector(ALU_MSB downto 0);
     ea_dat      : std_logic_vector(ALU_MSB downto 0);

     fp_reg      : std_logic_vector(ALU_MSB downto 0);
     sp_reg      : std_logic_vector(ALU_MSB downto 0);

     --
     -- status & control
     --
     st_reg      : std_logic_vector(SR_MSB downto 0);

     skipc       : std_logic_vector(5 downto 0);

     pc_reg_p1   : std_logic_vector(ALU_MSB downto 0);
     ireg        : std_logic_vector(INST_MSB downto 0);
     ex_null     : std_logic;

     rsp_pc      : std_logic_vector(ALU_MSB downto 0);


  end record;

  --
  -- 
  --
  signal y1a_probe_sigs : y1a_probe_type;

end package y1a_probe_pkg;
