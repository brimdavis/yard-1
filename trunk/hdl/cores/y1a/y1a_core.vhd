--
-- <y1a_core.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2014  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A processor core
--
--   - pre-alpha code
--
--   - code is still a mess, but passes basic verification test suite
--
--
--   - Feature Summary:
--
--       - 32 bit datapath
--       - compact 16 bit instruction format
--       - 16 registers
--
--       - two operand ALU instructions: register, register|immediate 
--
--       - encoded short immediates: 5 bit signed, 2^N, (2^N)-1
--       - immediate prefixes:
--            - IMM12 : 12 bit signed immediate 
--            - LDI   : PC relative load of 32 bit immediate
--
--       - load/store architecture
--       - memory operand sizes: signed/unsigned 8/16/32 bit 
--
--       - data operand addressing modes: 
--          - register indirect        : mem[Rn]
--          - register offset indirect : mem[Rn + IMM]
--          - stack offset             : mem[FP | SP + unsigned 4 bit quad offset]
--          - synthetic PC-relative and absolute modes
--
--       - SKIP based conditionals
--       - PC-relative branches, absolute jumps
--
--       - two stage pipeline
--          - single cycle instruction execution
--          - one branch delay slot, with selectable null
--
--
--   - Problem areas:
--
--      - original code grew very top-heavy
--
--          - started out as a simple ALU test case
--
--          - aliases used for instruction field variant decoding
--              - aliases need to be in same file with code that uses them ( or else be copied )
--
--          - have started to split functional units into separate source files
--
--      - result mux originally coded with tristates ( worked well in earlier TBUF laden FPGAs )
--
--
--   - short term TODO:
--
--      - changeover to internal sync reset
--
--      - figure out better replacement for aliases in instruction field decoding
--         - maybe a record type for each instruction format, with slv conversion functions 
--
--
--   - Things that are broken and/or unfinished:
--
--      - mov/ld/st to R15 should push/pop HW return stack
--
--      - fix interrupts
--         - finish code rework for status register restore on RTI
--         - stacked return address 
--
--      - implement TRAP instruction
--
--      - implement coprocessor interface
--
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;
  use work.y1a_comps.all;

--
-- simulation-only probes
--

-- >>>>>>>>>>>>>>>>>>>
-- pragma translate_off         
--
  use work.y1a_probe_pkg.all;
--
-- pragma translate_on
-- <<<<<<<<<<<<<<<<<<<


entity y1a_core is 
  generic
    ( CFG        : y1a_config_type := DEFAULT_Y1A_CONFIG );

  port
    (
      --
      -- clock and control
      --
      clk        : in  std_logic;
      sync_rst   : in  std_logic;
                      
      irq_l      : in  std_logic;
                
      in_flags   : in  std_logic_vector(15 downto 0);

      --
      -- instruction bus
      --
      i_en_l     : out std_logic;
      i_rd_l     : out std_logic;

      i_addr     : out std_logic_vector(PC_MSB downto 0);
      i_dat      : in  std_logic_vector(I_DAT_MSB downto 0);

      --
      -- data bus
      --
      d_en_l     : out std_logic;
      d_rd_l     : out std_logic;
      d_wr_l     : out std_logic;
      d_wr_en_l  : out std_logic_vector(3 downto 0);

      d_stall    : in  std_logic;

      d_addr     : out std_logic_vector(ADDR_MSB downto 0);

      d_rdat     : in  std_logic_vector(D_DAT_MSB downto 0);
      d_wdat     : out std_logic_vector(D_DAT_MSB downto 0)
    );

end y1a_core;


architecture arch1 of y1a_core is

  --
  -- declare synthesis attributes
  --
  attribute syn_keep : boolean;
  attribute syn_hier : string;

  -- 
  -- prevent optimizations across core interface
  --
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- global signals
  --

  --
  -- register file outputs
  --
  signal ar      : std_logic_vector(ALU_MSB downto 0);
  signal br      : std_logic_vector(ALU_MSB downto 0);
  
  --
  -- register file writeback bus and writeback enable 
  --
  signal wb_bus  : std_logic_vector(ALU_MSB downto 0);
  signal wb_en   : std_logic;


  --
  -- register file & memory writeback busses ( multiple tri-state drivers in original core )
  --
  signal mem_wb_bus : std_logic_vector(ALU_MSB downto 0);


  --
  -- alu/logic inputs
  --
  signal ain         : std_logic_vector(ALU_MSB downto 0);
  signal bin         : std_logic_vector(ALU_MSB downto 0);
  signal mux_bin     : std_logic_vector(ALU_MSB downto 0);
  signal mux_inv_bin : std_logic_vector(ALU_MSB downto 0);

  --
  -- signals for arithmetic/logic units
  --

  signal arith_dat  : std_logic_vector(ALU_MSB downto 0);
  signal arith_cout : std_logic;
  
  signal logic_dat  : std_logic_vector(ALU_MSB downto 0);

  signal shift_dat  : std_logic_vector(ALU_MSB downto 0);
  
  signal ffb_dat    : std_logic_vector(5 downto 0);
  signal bitcnt_dat : std_logic_vector(5 downto 0);
  signal flip_dat   : std_logic_vector(ALU_MSB downto 0);

  signal ext_dat    : std_logic_vector(ALU_MSB downto 0);
  
  --
  -- immediate constant generation
  --
  signal cg_out     : std_logic_vector(ALU_MSB downto 0);
  
  --
  -- effective address calculation
  --
  signal ea_dat     : std_logic_vector(ALU_MSB downto 0);
  signal pcr_addr   : std_logic_vector(ALU_MSB downto 0);

  --
  -- program counter
  --
  signal pc_reg    : std_logic_vector(PC_MSB downto 0);
  signal pc_reg_p1 : std_logic_vector(PC_MSB downto 0);

  --
  -- instruction data
  --
  signal i_sel    : std_logic;
  signal inst     : std_logic_vector(INST_MSB downto 0);

  signal dcd_stall    : std_logic;
  
  --
  -- instruction register & copies
  --
  signal ireg     : std_logic_vector(INST_MSB downto 0);
  
  attribute syn_keep of ireg    : signal is true;

  --
  -- stack signals
  --
  signal rsp_pc   : std_logic_vector(PC_MSB downto 0);
  signal rsp_sr   : std_logic_vector(SR_MSB downto 0);
  

  --
  -- interrupt stuff ( interrupts currently disabled, not working )
  --
  signal irq_p0,irq_p1,irq_p2 : std_logic;
  signal irq_edge   : std_logic;
  signal irq_enable : std_logic;

  signal irq_null   : std_logic;
  
  --
  -- skip logic
  --
  signal skip_cond  : std_logic;

  --
  -- Frame Pointer, Stack Pointer, IMMediate registers
  --
  signal imm_reg    : std_logic_vector(ALU_MSB downto 0);
  signal fp_reg     : std_logic_vector(ALU_MSB downto 0);
  signal sp_reg     : std_logic_vector(ALU_MSB downto 0);

  --
  -- early instruction decodes
  --
  signal force_sel_opa  : std_logic_vector(3 downto 0);
  signal force_sel_opb  : std_logic_vector(3 downto 0);

  signal dcd_mem_ld     : boolean;

  --
  -- status register
  --
  signal st_reg   : std_logic_vector(SR_MSB downto 0);

  alias ex_null   : std_logic is st_reg(SR_MSB);

  --
  -- remaining instruction decode aliases in use in top level
  --
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);


------------------------------------------------------------------------------


begin

  ------------------------------------------------------------------------------
  --
  -- register file
  --
  B_rf : block

    begin

      I_regfile: regfile
        port map
          (
            clk       => clk, 
            sync_rst  => sync_rst,

            we        => wb_en, 
            wa        => force_sel_opa, 
            wd        => wb_bus,

            ra1       => force_sel_opa, 
            ra2       => force_sel_opb, 

            rd1       => ar, 
            rd2       => br,

            fp_reg    => fp_reg,
            sp_reg    => sp_reg,
            imm_reg   => imm_reg
          );


      I_regfile_dcd : regfile_dcd
        generic map
          ( CFG       => CFG )
        
        port map
          (
            clk       => clk, 
            sync_rst  => sync_rst,
        
            inst      => inst,
            stall     => dcd_stall,      

            ex_null   => ex_null,

            dcd_wb_en => wb_en 
          );

    end block B_rf;


  ------------------------------------------------------------------------------
  --
  -- immediate constant generation
  --
  B_cg : block

    signal opb_ctl     : std_logic_vector(1 downto 0);
    signal opb_const   : std_logic_vector(4 downto 0);

    begin

      I_cgen: cgen
       port map
         (
           opb_ctl        => opb_ctl,    
           opb_const      => opb_const,   

           cg_out         => cg_out    
         );

      I_cgen_dcd : cgen_dcd
        generic map
          ( CFG           => CFG )
        
        port map
          (
            clk           => clk, 
            sync_rst      => sync_rst,
        
            inst          => inst,
            stall         => dcd_stall,      

            fld_opb_ctl   => opb_ctl,    
            fld_opb_const => opb_const   
          );

    end block B_cg;
 
  ------------------------------------------------------------------------------
  --
  -- operand selection
  --
  --  TODO: split into datapath/decode blocks
  --
  B_op_sel: block

      --
      -- local instruction register
      --
      signal ireg           : std_logic_vector(INST_MSB downto 0);

      --
      -- local decodes
      --
      alias ireg_msb   : std_logic                             is ireg(15);
      alias inst_type  : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
      alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
      alias logic_notb : std_logic                             is ireg(11);
      alias opb_ctl    : std_logic_vector(1 downto 0)          is ireg(10 downto 9);
      alias sel_opb    : std_logic_vector(3 downto 0)          is ireg( 7 downto 4);


    begin
  
      --
      -- ain  
      --
      ain <=   ar;

      --         
      -- bin with no constant mux used for flip/cnt/ffb/skip/ea
      --         
      bin <=   br;

      --
      -- BMD imm update:  R14 as imm_reg
      --   need to add TRS mux to use TRS as operand ( specify operation for MOV only?? )
      --
--      mux_bin <=   cg_out  when ( ireg_msb='0' ) AND ( opb_ctl(1 downto 0) /= "00" )
--             else imm_reg  when ( ireg_msb='0' ) AND ( sel_opb = REG_IMM )
--             else br;

      mux_bin <=   cg_out  when ( ireg_msb='0' ) AND ( opb_ctl(1 downto 0) /= "00" )
             else  bin;

      --
      -- new code, share B inverter for SUB & logicals
      --
      mux_inv_bin <=   NOT mux_bin when ( (inst_type = OPL ) AND (logic_notb = '1') ) OR ( inst_fld = OPA_SUB )
                 else      mux_bin;

      --
      -- local instruction register
      --
      P_ireg: process
      begin
        wait until rising_edge(clk);

        if sync_rst = '1' then
          ireg  <= ( others => '0');

        elsif dcd_stall = '0' then
          ireg  <= inst;

        end if;

      end process;

         
    end block B_op_sel;

  ------------------------------------------------------------------------------
  --
  -- arithmetic operations ( add, subtract, reverse subtract )
  --
  B_addsub: block

    signal dcd_sub  : std_logic;
    signal dcd_rsub : std_logic;

    begin

      I_addsub: addsub
        port map
          (
            dcd_sub    => dcd_sub,
            dcd_rsub   => dcd_rsub,

            ain        => ain,
            bin        => mux_inv_bin,
  
            arith_cout => arith_cout,
            arith_dat  => arith_dat
          );

      I_addsub_dcd: addsub_dcd
        generic map
          ( CFG       => CFG )
  
        port map
          (
            clk       => clk, 
            sync_rst  => sync_rst,
  
            inst      => inst,
            stall     => dcd_stall,      
  
            dcd_sub   => dcd_sub,
            dcd_rsub  => dcd_rsub
          );

    end block B_addsub;

  ------------------------------------------------------------------------------
  --
  -- logical operations  ( move, and, or, xor )
  --
  B_logicals: block

    signal logic_op  : std_logic_vector(OP_MSB downto 0);

    begin

      I_logicals: logicals
        port map
          (   
            logic_op     => logic_op,

            ain          => ain,        
            bin          => mux_inv_bin,        
  
            logic_dat    => logic_dat
          );

      I_logicals_dcd: logicals_dcd
        generic map
          ( CFG          => CFG )
  
        port map
          (
            clk          => clk, 
            sync_rst     => sync_rst,
  
            inst         => inst,
            stall        => dcd_stall,      
  
            fld_logic_op => logic_op
          );
  
    end block B_logicals;

  ------------------------------------------------------------------------------
  --
  -- shifts & rotates
  --
  --  TODO: implement barrel shifter
  --

  GT_barrel: if CFG.isa.barrel_shift generate
    begin

      assert FALSE
        report "Barrel Shifter is not implemented yet!"
        severity error;

    end generate GT_barrel;


  GF_barrel: if NOT CFG.isa.barrel_shift generate

    signal shift_grp    : std_logic;
    signal shift_signed : std_logic;
    signal shift_dir    : std_logic;
    signal shift_const  : std_logic_vector(4 downto 0);

    begin

      I_shift_one: shift_one
       port map
         (
           shift_grp         => shift_grp,    
           shift_signed      => shift_signed, 
           shift_dir         => shift_dir,    
           shift_const       => shift_const,  

           ain               => ain,          

           shift_dat         => shift_dat    
         );

      I_shift_dcd: shift_dcd
        generic map
          ( CFG              => CFG )
  
        port map
          (
            clk              => clk, 
            sync_rst         => sync_rst,
  
            inst             => inst,
            stall            => dcd_stall,      

            fld_shift_grp    => shift_grp,   
            fld_shift_signed => shift_signed,
            fld_shift_dir    => shift_dir,   
            fld_shift_const  => shift_const 
          );

    end generate GF_barrel;

  ------------------------------------------------------------------------------
  --
  -- TODO : move hijacked FF1/CNT1 opcodes to coprocessor space
  --

--  --
--  -- bit seek instructions ( find first bit, bit count )
--  --
--   GT_seek: if CFG.isa.bit_seek generate
--     begin
-- 
--       I_ffb: ffb
--         port map
--          (
--            din   => bin,
--            first => ffb_dat
--          );
-- 
--       I_bitcnt: bitcnt
--         port map
--          (
--            din  => bin,
--            cnt  => bitcnt_dat
--          );
--   
--     end generate GT_seek;
-- 
--   GF_seek: if NOT CFG.isa.bit_seek generate
--     begin
-- 
--       ffb_dat    <= ( others => '0' );
--       bitcnt_dat <= ( others => '0' );
-- 
--     end generate GF_seek;

  ------------------------------------------------------------------------------
  --
  -- reg-reg sign/zero extension
  --
  B_reg_extend: block

    signal dcd_wyde : std_logic;

    signal mem_sign : std_logic;
    signal mem_size : std_logic_vector(1 downto 0);

    begin

      I_reg_extend: reg_extend
        generic map
          ( CFG          => CFG )
        port map
          (   
            dcd_wyde     => dcd_wyde,    

            mem_sign     => mem_sign,
            mem_size     => mem_size,

            din          => bin,
                      
            ext_out      => ext_dat
          );

      I_reg_extend_dcd: reg_extend_dcd
        generic map
          ( CFG          => CFG )
        port map
          (   
            clk          => clk, 
            sync_rst     => sync_rst,
  
            inst         => inst,
            stall        => dcd_stall,

            dcd_wyde     => dcd_wyde,    

            fld_mem_sign => mem_sign,
            fld_mem_size => mem_size
          );

    end block B_reg_extend;

  ------------------------------------------------------------------------------
  --
  -- FLIP instruction  ( universal bit swapper )
  --
  GT_flip: if CFG.isa.bit_flip generate

    signal flip_const  : std_logic_vector(4 downto 0);

    begin

      I_flip: flip
        port map
         (
           bsel  => flip_const,

           din   => ain,

           dout  => flip_dat
         );

      I_flip_dcd: flip_dcd
        generic map
          ( CFG              => CFG )
  
        port map
          (
            clk              => clk, 
            sync_rst         => sync_rst,
  
            inst             => inst,
            stall            => dcd_stall,      

            fld_flip_const   => flip_const 
          );

    end generate GT_flip;


  GF_flip: if NOT CFG.isa.bit_flip generate

    begin

      flip_dat <= ( others => '0' );

    end generate GF_flip;

  
  ------------------------------------------------------------------------------
  --
  --   PC Relative address calculation
  --    - now used only for return address calculations
  --
  B_pcr : block

    signal dcd_call      : std_logic;
    signal dslot_null    : std_logic;

    begin

      I_pcr_calc: pcr_calc
        port map
          (
            dcd_call       => dcd_call,
            dslot_null     => dslot_null, 

            pc_reg_p1      => pc_reg_p1, 
                      
            pcr_addr       => pcr_addr
          );

      I_pcr_calc_dcd: pcr_calc_dcd
        generic map
          ( CFG            => CFG )

        port map
          (   
            clk            => clk, 
            sync_rst       => sync_rst,
  
            inst           => inst,
            stall          => dcd_stall,

            fld_dslot_null => dslot_null, 
            dcd_call       => dcd_call       
          );

    end block B_pcr;

  ------------------------------------------------------------------------------
  --
  --   Effective Address calculation
  --
  B_ea : block

    signal dcd_LDI      : boolean;
    signal dcd_mode_SP  : boolean;
    signal dcd_src_mux  : boolean;

    signal mem_mode     : std_logic;
    signal mem_size     : std_logic_vector( 1 downto 0);

    signal sel_opb      : std_logic_vector( 3 downto 0);
    signal sp_offset    : std_logic_vector( 3 downto 0);
    signal ldi_offset   : std_logic_vector(11 downto 0);

    begin

      I_ea_calc: ea_calc
        port map
          (
            dcd_LDI        => dcd_LDI,   
            dcd_mode_SP    => dcd_mode_SP,
            dcd_src_mux    => dcd_src_mux,
                             
            mem_mode       => mem_mode,  
                                    
            sp_offset      => sp_offset, 
            ldi_offset     => ldi_offset,

            bin            => bin,      

            fp_reg         => fp_reg,   
            sp_reg         => sp_reg,   
            imm_reg        => imm_reg,   
    
            pc_reg_p1      => pc_reg_p1, 
                       
            ea_dat         => ea_dat    
          );


      I_ea_dcd : ea_dcd
        generic map
          ( CFG            => CFG )

        port map
          (   
            clk            => clk, 
            sync_rst       => sync_rst,
  
            inst           => inst,
            stall          => dcd_stall,
  
            dcd_LDI        => dcd_LDI,    
            dcd_mode_SP    => dcd_mode_SP,
            dcd_src_mux    => dcd_src_mux,
  
            fld_mem_mode   => mem_mode,   
  
            fld_sp_offset  => sp_offset,  
            fld_ldi_offset => ldi_offset 
          );

    end block B_ea;


  ------------------------------------------------------------------------------
  --
  -- writeback mux
  --    replaces old TBUF writeback code with mux cascade
  --
  --  TODO: split into datapath/decode blocks
  --
  wb_mux : block

    signal wb_muxa : std_logic_vector(ALU_MSB downto 0);
    signal wb_muxb : std_logic_vector(ALU_MSB downto 0);

    attribute syn_keep of wb_muxa  : signal is true;
    attribute syn_keep of wb_muxb  : signal is true;

    --
    -- local instruction register
    --
    signal ireg           : std_logic_vector(INST_MSB downto 0);

    --
    -- local instruction decode
    --
    alias inst_type    : std_logic_vector(TYPE_MSB downto 0)   is ireg(15 downto 14);
    alias inst_fld     : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  
    alias arith_op     : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);

    alias shift_grp    : std_logic                             is ireg(11);
    alias shift_signed : std_logic                             is ireg(10);
    alias shift_dir    : std_logic                             is ireg( 9);

    alias lea_bit      : std_logic                             is ireg( 8);

    begin

--      wb_bus  <=   mem_wb_bus   when  ( inst_fld  = OPM_LD   ) OR  ( inst_fld  = OPM_LDI )
      wb_bus  <=   mem_wb_bus   when  dcd_mem_ld
             else  wb_muxa;

      wb_muxa <=   arith_dat    when  ( inst_type = OPA      ) AND ( arith_op /= T_MISC  )
             else  ea_dat       when  ( inst_fld  = OPM_ST   ) AND ( lea_bit = '1'       ) 
--             else  mem_wb_bus   when  ( inst_fld  = OPM_LD   ) OR  ( inst_fld  = OPM_LDI )
             else  wb_muxb;

      wb_muxb <=   logic_dat    when  ( inst_type = OPL      ) 
             else  flip_dat     when  ( inst_fld  = OPA_MISC ) AND ( shift_grp = '0' ) AND ( shift_signed='1' ) AND ( shift_dir = '1' )

             else  ( ALU_MSB downto 12 => ireg(11) ) & ireg(11 downto 0) when ( inst_fld = OPM_IMM )

--
-- TODO : move hijacked FF1/CNT1 opcodes to coprocessor space
--
--             -- BMD hardcoded 32 bit sign/zero extend
--             else ( ALU_MSB downto 6 => ffb_dat(5) ) & ffb_dat   when (inst_fld = OPA_MISC ) AND (shift_grp = '1') AND (shift_signed = '1') AND (misc_grp = MISC_FFB) 
--             else ( ALU_MSB downto 6 => '0' ) & bitcnt_dat       when (inst_fld = OPA_MISC ) AND (shift_grp = '1') AND (shift_signed = '1') AND (misc_grp = MISC_CNTB) 

             else ext_dat when (inst_fld = OPA_MISC ) AND (shift_grp = '1') AND (shift_signed = '1') 

             -- anything left in MISC should be a normal shift/rotate
             else  shift_dat    when  ( inst_fld  = OPA_MISC ) 
 
             else  ( others => '0' );

      --
      -- local instruction register
      --
      P_ireg: process
      begin
        wait until rising_edge(clk);

        if sync_rst = '1' then
          ireg  <= ( others => '0');

        elsif dcd_stall = '0' then
          ireg  <= inst;

        end if;

      end process;

    end block wb_mux;


  ------------------------------------------------------------------------------
  --
  -- skip condition logic
  --
  --  TODO: split into datapath/decode blocks ???
  --
  B_skip_ctl : block

    --
    -- input flag register stages
    --
    signal flag_reg_x0 : std_logic_vector(15 downto 0);
    signal flag_reg_x1 : std_logic_vector(15 downto 0);

    attribute syn_keep of flag_reg_x0 : signal is TRUE;
    attribute syn_keep of flag_reg_x1 : signal is TRUE;

    begin

      I_skip_dcd: skip_dcd
        generic map
          ( CFG          => CFG )

        port map
          (
            clk          => clk, 
            sync_rst     => sync_rst,

            inst         => inst,
            stall        => dcd_stall,      

            ain          => ain,         
            bin          => bin,        

            flag_reg     => flag_reg_x1,    

            skip_cond    => skip_cond   
          );

      --
      -- register input flags twice before use
      -- guards against metastables if async inputs are wired to core flag inputs
      --
      process(clk)
        begin
          if rising_edge(clk) then
            flag_reg_x0 <= in_flags;
            flag_reg_x1 <= flag_reg_x0;
          end if;
        end process;

    end block B_skip_ctl;


  ------------------------------------------------------------------------------
  --
  -- control and program sequencing
  --
  ------------------------------------------------------------------------------

  --
  -- irq edge detect logic
  --   need to add interrupt enable flag to SR 
  --   need another flag (in SR?) to gate off irq_edge when in ISR
  --
  irq_enable <=  '1' when CFG.hw.irq_support else '0';

  -- register inputs 
  process 
    begin
      wait until rising_edge(clk);

      if sync_rst = '1' then
        irq_p0   <= '1';
        irq_p1   <= '1';
        irq_p2   <= '1';
        irq_edge <= '0';

      else
        irq_p0   <= irq_l;
        irq_p1   <= irq_p0;
        irq_p2   <= irq_p1;
        irq_edge <= ( NOT irq_p1 AND irq_p2 ) AND irq_enable;

      end if;

    end process;


  --
  -- processor state control
  --
  --  TODO: split into datapath/decode blocks ???
  --
  B_state_ctl : block

    begin

      I_state_ctl : state_ctl
        generic map
          ( CFG                => CFG )

        port map
          (
            clk                => clk,
            sync_rst           => sync_rst,

            irq_edge           => irq_edge,

            inst               => inst,
            d_stall            => d_stall,      

            skip_cond          => skip_cond,   
            arith_cout         => arith_cout,

            ain                => ain,      
            imm_reg            => imm_reg,

            rsp_pc             => rsp_pc,
            rsp_sr             => rsp_sr,


            dcd_stall          => dcd_stall,
            irq_null           => irq_null,

            st_reg_out         => st_reg,

            pc_reg_out         => pc_reg,
            pc_reg_p1_out      => pc_reg_p1
          );

    end block B_state_ctl;


  --
  -- pipeline registers, hold on data stall
  --
  --   instruction register 
  --
  P_pipe_reg: process
    begin
      wait until rising_edge(clk);
 
      if sync_rst = '1' then
        ireg      <= ( others => '0');

      elsif ( dcd_stall = '1' ) then
        ireg      <= ireg;

      else
        ireg      <= inst;

      end if;
 
   end process;


  --    
  -- interim code
  --    
  -- workaround until top level aliases replaced with individual decodes in functional units   
  --    
  -- early decodes - moved ahead of instruction register to improve critical path timing
  --    
  P_early_dcd: process
    begin
      wait until rising_edge(clk);
 
      if  sync_rst = '1' then
        force_sel_opa  <= ( others => '0');
        force_sel_opb  <= ( others => '0');

        dcd_mem_ld     <= FALSE;

      else

        if ( d_stall = '1' ) AND ( (inst_fld = OPM_LD ) OR (inst_fld = OPM_LDI ) ) then
          force_sel_opa  <= force_sel_opa;
          force_sel_opb  <= force_sel_opb;

          dcd_mem_ld     <= dcd_mem_ld;

  
        else
          --
          -- force register file addressing for special case instruction modes
          --

          --
          --    force opa = IMM (r14) for LDI and IMM12
          --
          if  ( inst(15 downto 12) = OPM_IMM ) OR ( inst(15 downto 12) = OPM_LDI ) then
            force_sel_opa <= X"E" ;
          else 
            force_sel_opa <= inst(3 downto 0);
          end if;

          --
          --    force opb = FP/SP for memory accesses using stack mode
          --
          if  ( ( inst(15 downto 12) = OPM_LD ) OR ( inst(15 downto 12) = OPM_ST ) ) AND ( inst(10 downto 9) = MEM_32_SP ) then

            if  inst(11) = '0'  then
              force_sel_opb <= X"C" ;  -- fp
            else 
              force_sel_opb <= X"D" ;  -- sp
            end if;

          else 
            force_sel_opb <= inst(7 downto 4);

          end if;


          --
          -- instruction decode for writeback bus memory source
          --
          dcd_mem_ld  <= ( inst(15 downto 12) = OPM_LDI ) OR ( inst(15 downto 12) = OPM_LD  );

        end if;
 
      end if;
 
   end process;


  ------------------------------------------------------------------------------
  --
  -- return stack 
  --
  B_rstack: block

    signal dcd_push : std_logic;
    signal dcd_pop  : std_logic;


    begin

      I_stack: rstack
        port map
          (
            clk      => clk, 
            sync_rst => sync_rst,

            push     => dcd_push, 
            pop      => dcd_pop,

            --
            -- TODO: add test cases for new return address calculation for delayed calls (bsr.d, jsr.d)
            --
            pc_in    => pcr_addr(PC_MSB downto 0), 
            sr_in    => st_reg,

            pc_stk   => rsp_pc, 
            sr_stk   => rsp_sr
          );


      I_rstack_dcd: rstack_dcd
        generic map
          ( CFG          => CFG )
      
        port map
          (
            clk          => clk, 
            sync_rst     => sync_rst,
      
            inst         => inst,
            stall        => dcd_stall,      

            ex_null      => ex_null,   
            irq_edge     => irq_edge,

            dcd_push     => dcd_push, 
            dcd_pop      => dcd_pop
          );

    end block B_rstack;

  
  ------------------------------------------------------------------------------
  --
  -- instruction bus control signals and drivers 
  --
  B_ibus_ctl: block
    begin

      --
      -- instruction bus control ( read, enable permanently asserted active )
      --
      i_en_l <= '0';
      i_rd_l <= '0';
  
      i_addr   <= pc_reg;
      i_sel    <= pc_reg(1);

    end block B_ibus_ctl;


  ------------------------------------------------------------------------------
  --
  -- instruction bus datapath ( mux 32 to 16 bits )
  --
  B_ibus_dat: block
    signal i_sel_p1 : std_logic;

    begin

      --
      -- big-endian mux instruction bus output from 32 to 16 bits 
      -- inst. bus not tristated (for speed), currently can only have one driver
      --
      delay_lsb: process
        begin

          wait until falling_edge(clk);

          i_sel_p1 <= i_sel;

        end process;

        
      inst  <=   i_dat(15 downto  0) when ( i_sel_p1 = '1' )
            else i_dat(31 downto 16);


    end block B_ibus_dat;

 
  ------------------------------------------------------------------------------
  --
  -- data bus interface
  --
  B_dbus: block

    signal dcd_st       : boolean;
    signal dcd_st32     : boolean;
    signal dcd_st16     : boolean;
    signal dcd_st8      : boolean;

    signal dcd_quad_ld  : boolean;
    signal dcd_wyde_ld  : boolean;
    signal dcd_byte_ld  : boolean;

    signal dcd_mem_sign : std_logic;


    begin

      --
      -- data bus address sourced by ea adder
      --
      d_addr <= ea_dat;
    
    
      --
      -- data bus control signals
      --
        I_dbus_ctl: dbus_ctl
        generic map
          ( CFG       => CFG )
    
        port map
          (
            clk       => clk, 
            sync_rst  => sync_rst,
    
            inst      => inst,
            stall     => dcd_stall,      
                                   
            ex_null   => ex_null,   
    
            ea_lsbs   => ea_dat(1 downto 0),    
                                   
            d_en_l    => d_en_l,    
            d_rd_l    => d_rd_l,    
            d_wr_l    => d_wr_l,    
            d_wr_en_l => d_wr_en_l 
          );
    
      --
      -- byte/wyde lane mux for stores                                                                
      --                                                                                              
      I_st_mux: st_mux
        generic map
          ( CFG       => CFG )
    
        port map
          (
            dcd_st    => dcd_st,    
            dcd_st32  => dcd_st32,  
            dcd_st16  => dcd_st16,  
            dcd_st8   => dcd_st8,   

            ain       => ain,        
    
            d_wdat    => d_wdat
          );
    
      I_st_mux_dcd: st_mux_dcd
        generic map
          ( CFG       => CFG )
    
        port map
          (
            clk       => clk, 
            sync_rst  => sync_rst,
    
            inst      => inst,
            stall     => dcd_stall,      
    
            dcd_st    => dcd_st,    
            dcd_st32  => dcd_st32,  
            dcd_st16  => dcd_st16,  
            dcd_st8   => dcd_st8
          );
    
    
      --
      -- byte/wyde {sign extending} lane mux for loads
      --
      I_ld_mux: ld_mux
        generic map
          ( CFG          => CFG )
    
        port map
          (
            dcd_mem_sign => dcd_mem_sign, 
    
            dcd_quad_ld  => dcd_quad_ld, 
            dcd_wyde_ld  => dcd_wyde_ld, 
            dcd_byte_ld  => dcd_byte_ld, 
    
            ea_lsbs      => ea_dat(1 downto 0),     
    
            d_rdat       => d_rdat,     
    
            mem_wb_bus   => mem_wb_bus 
          );
    
    
      I_ld_mux_dcd: ld_mux_dcd
        generic map
          ( CFG          => CFG )
    
        port map
          (
            clk          => clk, 
            sync_rst     => sync_rst,
    
            inst         => inst,
            stall        => dcd_stall,      
    
            dcd_mem_sign => dcd_mem_sign, 
    
            dcd_quad_ld  => dcd_quad_ld, 
            dcd_wyde_ld  => dcd_wyde_ld, 
            dcd_byte_ld  => dcd_byte_ld
          );
    
    end block B_dbus;

  ------------------------------------------------------------------------------

  --
  -- drive simulation probe signals 
  --

  -- >>>>>>>>>>>>>>>>>>>
  -- pragma translate_off
  --
  B_probe : block
    begin
      y1a_probe_sigs.ain        <= ain;
      y1a_probe_sigs.bin        <= mux_inv_bin;

      y1a_probe_sigs.cg_out     <= cg_out;

      y1a_probe_sigs.imm_reg    <= imm_reg;

      y1a_probe_sigs.wb_bus     <= wb_bus;
      y1a_probe_sigs.wb_en      <= wb_en;
      y1a_probe_sigs.wb_ra      <= force_sel_opa;

      y1a_probe_sigs.st_reg     <= st_reg;

      y1a_probe_sigs.pc_reg_p1  <= ( ALU_MSB downto PC_MSB+1 => '0') & pc_reg_p1 ;
      y1a_probe_sigs.ireg       <= ireg;     
      y1a_probe_sigs.ex_null    <= ex_null;  
      y1a_probe_sigs.irq_null   <= irq_null;  
      y1a_probe_sigs.dcd_stall  <= dcd_stall;  

      y1a_probe_sigs.rsp_pc     <= ( ALU_MSB downto PC_MSB+1 => '0') & rsp_pc;

      y1a_probe_sigs.ea_dat     <= ea_dat;

    end block B_probe;
  --
  -- pragma translate_on
  -- <<<<<<<<<<<<<<<<<<<
  
end arch1;
 
 
 
