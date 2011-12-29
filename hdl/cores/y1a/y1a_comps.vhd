--
-- <y1a_comps.vhd>
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
-- Y1A package of internal components 
--

library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


package y1a_comps is

  component regfile is
    port
      (   
        clk : in std_logic;
  
        we  : in  std_logic;
        wa  : in  std_logic_vector(RF_ADDR_MSB downto 0);
        wd  : in  std_logic_vector(RF_DAT_MSB downto 0);
  
        ra1 : in  std_logic_vector(RF_ADDR_MSB downto 0);
        ra2 : in  std_logic_vector(RF_ADDR_MSB downto 0);
  
        rd1 : out std_logic_vector(RF_DAT_MSB downto 0);
        rd2 : out std_logic_vector(RF_DAT_MSB downto 0)
      );
  end component;
  

  component pw2_rom is
    port 
      (   
        ra  : in  std_logic_vector(4 downto 0);
        rd  : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;
  
  
  component cgen is
    port 
      (   
        opb_ctl   : in std_logic_vector(1 downto 0);
        opb_const : in std_logic_vector(4 downto 0);

        cg_out    : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;
  
  
  component addsub is
    port
      (   
        inst_fld   : in  std_logic_vector(ID_MSB downto 0);
        arith_op   : in  std_logic_vector(OP_MSB downto 0);

        ain        : in  std_logic_vector(ALU_MSB downto 0);
        bin        : in  std_logic_vector(ALU_MSB downto 0);
  
        arith_cout : out std_logic;
        arith_dat  : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component logicals is
    port
      (   
        logic_op   : in  std_logic_vector(OP_MSB downto 0);

        ain        : in  std_logic_vector(ALU_MSB downto 0);
        bin        : in  std_logic_vector(ALU_MSB downto 0);
  
        logic_dat  : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component shift_one is
    port
      (   
        shift_grp    : in  std_logic;
        shift_signed : in  std_logic;    
        shift_dir    : in  std_logic;    

        ain          : in  std_logic_vector(ALU_MSB downto 0);

        shift_dat    : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;



  component ffb is
    port 
      (   
        din  : in  std_logic_vector(ALU_MSB downto 0);
        first: out std_logic_vector(5 downto 0)
      );
  end component;

  
  component bitcnt is
    port 
      (   
        din : in  std_logic_vector(ALU_MSB downto 0);
        cnt : out std_logic_vector(5 downto 0)
      );
  end component;

  
  component flip is
    port 
      (   
        bsel : in  std_logic_vector(4 downto 0);
        din  : in  std_logic_vector(ALU_MSB downto 0);
        dout : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;

  
  component ea_calc is
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
  end component;
  

  component skip_dcd is
    generic
      (
        CFG       : y1a_config_type
      );
    port
      (
        skip_sense   : in  std_logic;
        skip_type    : in  std_logic_vector(2 downto 0);
        skip_cp_sel  : in  std_logic;
        skip_ra_type : in  std_logic_vector(2 downto 0);

        sel_opa      : in  std_logic_vector(3 downto 0);
        opb_const    : in  std_logic_vector(4 downto 0);

        ain          : in  std_logic_vector(ALU_MSB downto 0);
        bin          : in  std_logic_vector(ALU_MSB downto 0);

        flag_reg     : in  std_logic_vector(15 downto 0);

        skip_cond    : out std_logic
      );
  end component;


  component rstack is
    port
      (
        clk    : in  std_logic;
        rst_l  : in  std_logic;
  
        push   : in  std_logic;
        pop    : in  std_logic;
  
        pc_in  : in  std_logic_vector(PC_MSB downto 0);
        sr_in  : in  std_logic_vector(SR_MSB downto 0);
  
        pc_stk : out std_logic_vector(PC_MSB downto 0);
        sr_stk : out std_logic_vector(SR_MSB downto 0)
      );
  end component;



  component dbus_ctl is
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
  end component;

  
  component st_mux is
    generic
      (
        CFG       : y1a_config_type
      );
    port
      (
        inst_fld  : in  std_logic_vector(ID_MSB downto 0);
        mem_size  : in  std_logic_vector(1 downto 0);
        lea_bit   : in  std_logic;

        ain       : in  std_logic_vector(ALU_MSB downto 0);

        d_wdat    : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component ld_mux is
    generic
      (
        CFG       : y1a_config_type
      );
    port
      (
        inst_fld   : in  std_logic_vector(ID_MSB downto 0);
        mem_size   : in  std_logic_vector(1 downto 0);
        mem_sign   : in  std_logic;

        ea_dat     : in  std_logic_vector(ALU_MSB downto 0);

        d_rdat     : in  std_logic_vector(ALU_MSB downto 0);

        mem_wb_bus : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


end package y1a_comps;
