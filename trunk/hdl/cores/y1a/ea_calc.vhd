-- 
-- <ea_calc.vhd>
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
-- Y1A effective address calculation
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;

  use work.y1a_probe_pkg.all;


entity ea_calc is

  port
    (   
      inst_fld   : in  std_logic_vector(ID_MSB downto 0);
      mem_size   : in  std_logic_vector(1 downto 0);
      mem_mode   : in  std_logic;
      sel_opb    : in  std_logic_vector(3 downto 0);

      bin        : in  std_logic_vector(ALU_MSB downto 0);
      imm_reg    : in  std_logic_vector(ALU_MSB downto 0);

      sp_offset  : in  std_logic_vector(3 downto 0);
      ldi_offset : in  std_logic_vector(11 downto 0);

      sp_reg     : in  std_logic_vector(ALU_MSB downto 0);
      fp_reg     : in  std_logic_vector(ALU_MSB downto 0);

      pc_reg_p1  : in  std_logic_vector(PC_MSB downto 0);
    
      ea_dat     : out std_logic_vector(ALU_MSB downto 0)
    );

end ea_calc;


architecture arch1 of ea_calc is

  signal ea_off_mux : std_logic_vector(ALU_MSB downto 0);
  signal ea_reg_mux : std_logic_vector(ALU_MSB downto 0);

  signal ea_pc_lsbs : std_logic_vector(1 downto 0);

  signal dcd_LDI  : boolean;
  signal dcd_SP   : boolean;


  --
  -- declare synthesis attributes
  --
  attribute keep : boolean;


begin

-- 
-- BMD rewrite? : 
--    reg_mux as one 4:1 with imm, move last br | reg_mux stage into adder
-- 
-- 

     dcd_LDI <= ( inst_fld = OPM_LDI   );
     dcd_SP  <= ( mem_size = MEM_32_SP );

     --
     -- LSB's of PC zeroed for LDI quad aligned addressing
     --
     ea_pc_lsbs  <= B"00" when dcd_LDI else pc_reg_p1(1 downto 0);

     --
     -- mux ea offset sources
     --
     ea_off_mux <=  
 
             ( ( ALU_MSB downto 14 => '0') & ldi_offset & B"00" )  
       when  dcd_LDI

       else  imm_reg                                
       when  ( mem_mode  = '1' ) AND ( NOT dcd_SP )
 
       else  X"0000_00" & B"00" & sp_offset & B"00" 
       when  dcd_SP
 
       else  ALU_ZERO;  
 

     --
     -- mux EA register sources
     --
     ea_reg_mux  <=  

             ( ALU_MSB downto PC_MSB+1 => '0') & pc_reg_p1(PC_MSB downto 2)  & ea_pc_lsbs
       when  dcd_LDI OR ( ( sel_opb = REG_PC ) AND ( NOT dcd_SP ) )

       else  fp_reg   
       when  ( mem_mode  = '0' ) AND ( dcd_SP )
 
       else  sp_reg   
       when  ( mem_mode  = '1' ) AND ( dcd_SP )
 
       else bin;
       

     ea_dat <=  ea_off_mux + ea_reg_mux;


   --
   -- add CONFIG_STACK_ADDRESSING flag to simplify?
   --
   -- OR: make a dedicated pc_reg_p1 adder, used for LDI / branch / delayed vs. nondelayed return address
   --


  ------------------------------------------------------------------------------
  --
  -- drive simulation probe signals 
  --
  ------------------------------------------------------------------------------
  ea_prb : block
    begin

      y1a_probe_sigs.ea_off_mux <= ea_off_mux;
      y1a_probe_sigs.ea_reg_mux <= ea_reg_mux;

    end block ea_prb;

 
end arch1;
