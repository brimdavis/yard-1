--
-- <y1a_comps.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2013  Brian Davis
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
        ireg       : in  std_logic_vector(INST_MSB downto 0);

        cg_out    : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;
  
  
  component addsub is
    port
      (   
        ireg       : in  std_logic_vector(INST_MSB downto 0);

        ain        : in  std_logic_vector(ALU_MSB downto 0);
        bin        : in  std_logic_vector(ALU_MSB downto 0);
  
        arith_cout : out std_logic;
        arith_dat  : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component logicals is
    port
      (   
        ireg       : in  std_logic_vector(INST_MSB downto 0);

        ain        : in  std_logic_vector(ALU_MSB downto 0);
        bin        : in  std_logic_vector(ALU_MSB downto 0);
  
        logic_dat  : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component shift_one is
    port
      (   
        ireg       : in  std_logic_vector(INST_MSB downto 0);

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


  component reg_extend  is
    generic
      (
        CFG        : y1a_config_type
      );
    port 
      (   
        ireg       : in  std_logic_vector(INST_MSB downto 0);
                  
        din        : in  std_logic_vector(ALU_MSB downto 0);
                  
        ext_out    : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component flip is
    port 
      (   
        ireg       : in  std_logic_vector(INST_MSB downto 0);

        din  : in  std_logic_vector(ALU_MSB downto 0);
        dout : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;

  
  component ea_calc is
    port
      (
        ireg       : in  std_logic_vector(INST_MSB downto 0);

        bin        : in  std_logic_vector(ALU_MSB downto 0);
        imm_reg    : in  std_logic_vector(ALU_MSB downto 0);

        pc_reg_p1  : in  std_logic_vector(PC_MSB downto 0);
    
        ea_dat     : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component pcr_calc is
     port
       (   
         ireg       : in  std_logic_vector(INST_MSB downto 0);

         pc_reg_p1  : in  std_logic_vector(PC_MSB downto 0);
       
         pcr_addr   : out std_logic_vector(ALU_MSB downto 0)
       );

  end component;
  

  component skip_dcd is
    generic
      (
        CFG          : y1a_config_type
      );
    port
      (
        ireg       : in  std_logic_vector(INST_MSB downto 0);

        ain          : in  std_logic_vector(ALU_MSB downto 0);
        bin          : in  std_logic_vector(ALU_MSB downto 0);

        flag_reg     : in  std_logic_vector(15 downto 0);

        skip_cond    : out std_logic
      );
  end component;


  component rstack is
    port
      (
        clk      : in  std_logic;
        sync_rst : in  std_logic;
  
        push     : in  std_logic;
        pop      : in  std_logic;
  
        pc_in    : in  std_logic_vector(PC_MSB downto 0);
        sr_in    : in  std_logic_vector(SR_MSB downto 0);
  
        pc_stk   : out std_logic_vector(PC_MSB downto 0);
        sr_stk   : out std_logic_vector(SR_MSB downto 0)
      );
  end component;


  component stall_dcd is
    generic
      (
        CFG        : y1a_config_type
      );
  
    port
      (   
        clk          : in  std_logic;
        sync_rst     : in  std_logic;
  
        i_dat        : in  std_logic_vector(INST_MSB downto 0);
        d_stall      : in  std_logic;

        dcd_stall    : out boolean
      );
  
  end component;



  component dbus_ctl is
    port
      (
        ireg      : in  std_logic_vector(INST_MSB downto 0);

        ex_null   : in  std_logic;

        ea_lsbs   : in  std_logic_vector(1 downto 0);

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
        dcd_st    : in  boolean;
        dcd_st32  : in  boolean;
        dcd_st16  : in  boolean;
        dcd_st8   : in  boolean;

        ain       : in  std_logic_vector(ALU_MSB downto 0);

        d_wdat    : out std_logic_vector(ALU_MSB downto 0)
      );
  end component;


  component st_mux_dcd is
    generic
      (
        CFG        : y1a_config_type
      );
  
    port
      (   
        clk          : in  std_logic;
        sync_rst     : in  std_logic;
  
        i_dat        : in  std_logic_vector(INST_MSB downto 0);
        stall        : in  boolean;

        dcd_st       : out boolean;
        dcd_st32     : out boolean;
        dcd_st16     : out boolean;
        dcd_st8      : out boolean
      );
  
  end component;


  component ld_mux is
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
  end component;


  component ld_mux_dcd is
    generic
      (
        CFG        : y1a_config_type
      );
  
    port
      (   
        clk          : in  std_logic;
        sync_rst     : in  std_logic;
  
        i_dat        : in  std_logic_vector(INST_MSB downto 0);
        stall        : in  boolean;

        dcd_mem_sign : out std_logic;

        dcd_quad_ld  : out boolean;
        dcd_wyde_ld  : out boolean;
        dcd_byte_ld  : out boolean
      );
  
  end component;


  component state_ctl is
    generic
      (
        CFG          : y1a_config_type
      );
    port
      (
        clk                : in  std_logic;
        sync_rst           : in  std_logic;


        d_stall            : in  std_logic; 

        skip_cond          : in  std_logic;
        arith_skip_nocarry : in  std_logic;
        arith_cout         : in  std_logic;


        ireg               : in  std_logic_vector(INST_MSB downto 0);

        ain                : in  std_logic_vector(ALU_MSB downto 0);
        imm_reg            : in  std_logic_vector(ALU_MSB downto 0);

        rsp_pc             : in  std_logic_vector(PC_MSB downto 0);
        rsp_sr             : in  std_logic_vector(SR_MSB downto 0);


        st_reg_out         : out std_logic_vector(SR_MSB downto 0);

        pc_reg_out         : out std_logic_vector(PC_MSB downto 0);
        next_pc_out        : out std_logic_vector(PC_MSB downto 0);

        pc_reg_p1_out      : out std_logic_vector(PC_MSB downto 0)
      );
  end component;




end package y1a_comps;
