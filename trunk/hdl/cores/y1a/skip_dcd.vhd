-- 
-- <skip_dcd.vhd>
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
-- Y1A skip logic
--
-- TODO: rewrite old processes as concurrent
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;

  -- >>>>>>>>>>>>>>>>>>>
  -- pragma translate_off
  --
  use work.y1a_probe_pkg.all;
  --
  -- pragma translate_on
  -- <<<<<<<<<<<<<<<<<<<

entity skip_dcd is
  generic
    (
      CFG       : y1a_config_type
    );

  port
    (   
      clk       : in  std_logic;
      sync_rst  : in  std_logic;

      inst      : in  std_logic_vector(INST_MSB downto 0);
      stall     : in  std_logic;

      ain       : in  std_logic_vector(ALU_MSB downto 0);
      bin       : in  std_logic_vector(ALU_MSB downto 0);

      flag_reg  : in  std_logic_vector(15 downto 0);

      skip_cond : out std_logic
    );

end skip_dcd;


architecture arch1 of skip_dcd is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";

  signal skip_cond_a : std_logic;

  --
  -- bit mux
  --
  signal c_bit       : std_logic;

  --
  -- byte zero flags
  --
  signal c_z3  : std_logic;
  signal c_z2  : std_logic;
  signal c_z1  : std_logic;
  signal c_z0  : std_logic;

  --
  -- coprocessor skips (not currently used)
  --
  signal skip_cp : std_logic;

  --
  -- flags for signed/unsigned skips
  --
  signal cb_n   : std_logic;
  signal cb_z   : std_logic;
  signal cb_c   : std_logic;
  signal cb_v   : std_logic;

  --
  -- local instruction register
  --
  signal ireg           : std_logic_vector(INST_MSB downto 0);

  --
  --
  --
  alias skip_sense    : std_logic                    is ireg(11);
  alias skip_type     : std_logic_vector(2 downto 0) is ireg(10 downto 8);
 
  alias skip_cp_sel   : std_logic                    is ireg( 7);
  alias skip_ra_type  : std_logic_vector(2 downto 0) is ireg( 6 downto 4);

  alias sel_opa       : std_logic_vector(3 downto 0) is ireg( 3 downto 0);
  alias opb_const     : std_logic_vector(4 downto 0) is ireg( 8 downto 4);


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
  -- mux for skip-on-bit
  --
  GT_csob: if CFG.isa.skip_on_bit generate
    begin
      c_bit  <= ain(to_integer(unsigned(opb_const)));
    end generate GT_csob;

  --
  --   if bit test is disabled, uses sign bit instead
  --
  GF_csob: if NOT CFG.isa.skip_on_bit generate
    begin
      c_bit  <= ain(ALU_MSB);
    end generate GF_csob;
  
  --
  -- TODO: implement coprocessor skips
  --       condition tied to false for now
  --
  skip_cp <= '0';

  --
  -- base skip decoding
  --

  --
  -- sign and zero code is hardcoded for 32 bit
  --
  c_z3 <= '1' when ( ain(31 downto 24) = X"00" ) else '0';
  c_z2 <= '1' when ( ain(23 downto 16) = X"00" ) else '0';
  c_z1 <= '1' when ( ain(15 downto  8) = X"00" ) else '0';
  c_z0 <= '1' when ( ain( 7 downto  0) = X"00" ) else '0';


  skip_decode_a: process(skip_ra_type, skip_cp_sel, skip_cp, c_z3, c_z2, c_z1, c_z0, ain, flag_reg, sel_opa)
    variable skip_mux_a : std_logic;

    begin
  
      -- mux condition sources
      case skip_ra_type is
        when CRA_Z    => skip_mux_a :=  c_z3 AND  c_z2  AND c_z1 AND c_z0;
        when CRA_AWZ  => skip_mux_a := (c_z3 AND  c_z2) OR (c_z1 AND  c_z0);
        when CRA_ABZ  => skip_mux_a :=  c_z3 OR   c_z2  OR  c_z1 OR  c_z0;

        when CRA_AWM  => skip_mux_a :=  ain(31) OR ain(15);
        when CRA_ABM  => skip_mux_a :=  ain(31) OR ain(23) OR ain(15) OR ain(7);

        when CRA_MIZ  => skip_mux_a := ain(ALU_MSB) OR (c_z3 AND  c_z2  AND c_z1 AND c_z0);

        when CRA_FLAG => skip_mux_a := flag_reg(to_integer(unsigned(sel_opa)));

        when others   => skip_mux_a := '0';

      end case;
  
      if skip_cp_sel = '0' then 
        skip_cond_a <= skip_mux_a;

      else
        skip_cond_a <= skip_cp;

      end if;

    end process skip_decode_a;


  --
  -- reg/reg skips
  --
  -- should look into merging this subtractor with original ALU at some point
  --

  GF_csc: if NOT CFG.isa.skip_compare generate
    cb_n <= '0';
    cb_c <= '0';
    cb_v <= '0';
    cb_z <= '0';
  end generate GF_csc;
  

  GT_csc: if CFG.isa.skip_compare generate

    skip_b: block
       signal wide_diff : std_logic_vector(ALU_MSB+2 downto 0);
       signal pad_ar    : std_logic_vector(ALU_MSB+2 downto 0);
       signal pad_br    : std_logic_vector(ALU_MSB+2 downto 0);
  
       begin
         pad_ar <= ( '0' & ain(ALU_MSB) & ain );
         pad_br <= ( '0' & bin(ALU_MSB) & bin );
  
         wide_diff <= pad_ar - pad_br;
    
         -- sign, carry, overflow, zero bits
         cb_n <= wide_diff(ALU_MSB);
         cb_c <= wide_diff(ALU_MSB+2);
         cb_v <= wide_diff(ALU_MSB+1) XOR wide_diff(ALU_MSB);
         cb_z <= '1' when ( wide_diff(ALU_MSB downto 0) = ALU_ZERO ) else '0';
  		 
       end block skip_b;

  end generate GT_csc;
    

  --
  -- final skip condition mux 
  --
  skip_decode: process(skip_sense, skip_type, skip_cond_a, cb_z, cb_n, cb_c, cb_v, c_bit)
   variable skip_mux : std_logic;
   begin
 
     -- mux condition sources
     case skip_type is

       when CND_LO => skip_mux :=  cb_c;
       when CND_LS => skip_mux :=  cb_z OR  cb_c;   
       when CND_LT => skip_mux :=  cb_n XOR cb_v;
       when CND_LE => skip_mux := (cb_n XOR cb_v) OR cb_z;

       when CND_EQ => skip_mux :=  cb_z;   

       when CND_RA => skip_mux := skip_cond_a;

       when CND_B0 => skip_mux := c_bit;
       when CND_B1 => skip_mux := c_bit;

       when others => skip_mux := '0';
     end case;

     if skip_sense = '0' then 
       skip_cond <= skip_mux;

     else
       skip_cond <= NOT skip_mux;

     end if;
 
   end process skip_decode;


  ------------------------------------------------------------------------------
  --
  -- drive simulation probe signals 
  --
  ------------------------------------------------------------------------------

  -- >>>>>>>>>>>>>>>>>>>
  -- pragma translate_off
  --
  B_sc_prb : block
    begin
      y1a_probe_sigs.skipc <= skip_cond_a & c_bit & cb_n & cb_c & cb_v & cb_z;
    end block B_sc_prb;
  --
  -- pragma translate_on
  -- <<<<<<<<<<<<<<<<<<<

end arch1;