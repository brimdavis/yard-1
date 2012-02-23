--
-- <y1a_core.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2012  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A processor core
--
--   - alpha release
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

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;
  use work.y1a_comps.all;

  use work.y1a_probe_pkg.all;


entity y1a_core is 
  generic
    (
      CFG        : y1a_config_type := DEFAULT_CONFIG
    );

  port
    (
      --
      -- clock and control
      --
      clk        : in  std_logic;
      rst_l      : in  std_logic;
                      
      irq_l      : in  std_logic;
                
      in_flags   : in  std_logic_vector(15 downto 0);

      --
      -- instruction bus
      --
      i_en_l     : out std_logic;
      i_rd_l     : out std_logic;

      i_addr     : out std_logic_vector(PC_MSB downto 0);
      i_dat      : in  std_logic_vector(INST_MSB downto 0);

      --
      -- data bus
      --
      d_en_l     : out std_logic;
      d_rd_l     : out std_logic;
      d_wr_l     : out std_logic;
      d_wr_en_l  : out std_logic_vector(3 downto 0);

      d_stall    : in  std_logic;

      d_addr     : out std_logic_vector(ADDR_MSB downto 0);

      d_rdat     : in  std_logic_vector(ALU_MSB downto 0);
      d_wdat     : out std_logic_vector(ALU_MSB downto 0);

      --
      -- probe record for testing
      --
      y1a_probes : out y1a_probe_type
    );

end y1a_core;


architecture arch1 of y1a_core is

  --
  -- declare synthesis attributes
  --
  attribute keep : boolean;


  -- 
  -- prevent optimizations across core interface
  --
  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";


  --
  -- signals
  --
  
  --
  -- register file outputs
  --
  signal ar      : std_logic_vector(ALU_MSB downto 0);
  signal br      : std_logic_vector(ALU_MSB downto 0);
  
  --
  -- register file writeback bus ( multiple tri-state drivers in original core )
  --
  signal wb_bus     : std_logic_vector(ALU_MSB downto 0);
  signal mem_wb_bus : std_logic_vector(ALU_MSB downto 0);

  signal force_sel_opa : std_logic_vector(3 downto 0);

  --
  -- writeback enable 
  --
  signal wb_en : std_logic;

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
  -- frame & stack pointer snooping registers for address generation
  --
  signal sp_reg     : std_logic_vector(ALU_MSB downto 0);
  signal fp_reg     : std_logic_vector(ALU_MSB downto 0);
  
  --
  -- program counter
  --
  signal pc_reg    : std_logic_vector(PC_MSB downto 0);
  signal pc_reg_p1 : std_logic_vector(PC_MSB downto 0);

  signal next_pc   : std_logic_vector(PC_MSB downto 0);

  signal ext_bra_offset : std_logic_vector(ALU_MSB downto 0);
  
  --
  -- instruction register
  --
  signal ireg     : std_logic_vector(INST_MSB downto 0);
  
  --
  -- stack signals
  --
  signal rsp_pc   : std_logic_vector(PC_MSB downto 0);
  signal rsp_sr   : std_logic_vector(SR_MSB downto 0);
  
  signal dcd_push : std_logic;
  signal dcd_pop : std_logic;
  
  
  --
  -- interrupt stuff ( interrupts currently disabled, not working )
  --
  signal irq_p0,irq_p1,irq_p2 : std_logic;
  signal irq_edge   : std_logic;
  signal irq_enable : std_logic;
  
  --
  -- input flag register
  --
  signal flag_reg : std_logic_vector(15 downto 0);
  
  --
  -- skip logic
  --
  signal skip_cond : std_logic;

  --
  -- IMMediate register
  --
  signal imm_reg   : std_logic_vector(ALU_MSB downto 0);


  ----------------------
  -- 
  -- GHDL bug- placing attributes after aliases causes cascade of errors like this:
  --     ' alias "ex_null" does not denote the entire object '

  --
  -- synthesis directives
  --  used to break up combinatorial ALU cascade into CLB sized chunks
  --
  
--   attribute keep of ain   : signal is true;
--   attribute keep of bin   : signal is true;
--   
--   attribute keep of ar   : signal is true;
--   attribute keep of br   : signal is true;
-- 
--   attribute keep of arith_dat  : signal is true;
--   attribute keep of logic_dat  : signal is true;
--   
--   attribute keep of cg_out   : signal is true;
--   
--   attribute keep of skip_cond   : signal is true;
-- 
--   attribute keep of ffb_dat     : signal is true;
--   attribute keep of bitcnt_dat  : signal is true;
--   attribute keep of flip_dat    : signal is true;
-- 
--   attribute keep of mem_wb_bus    : signal is true;
  
  ----------------------


  --
  -- status register
  --
  signal st_reg   : std_logic_vector(SR_MSB downto 0);

  alias null_sr   : std_logic_vector(7 downto 0) is st_reg(SR_MSB downto SR_MSB - 7 );
  alias ex_null   : std_logic is st_reg(SR_MSB);
  
  signal next_null_sr : std_logic_vector(7 downto 0);

  signal spam_length_mask : std_logic_vector(7 downto 0);
  
  --alias st_flag   : std_logic is st_reg(SR_MSB-4);


  ----------------------
  --
  -- instruction register aliases for opcode fields ( see constant.vhd )
  --    defined here using aliases until I figure out how best to define them 
  --    in a constant package; maybe define as sub-records of sundry ir types
  --
  --  15:14   opcode (type)
  --  13:12   opcode (op)
  --     11   opcode extension field
  --   11:9   skip control field
  --   10:9   opb control field
  --    8:4   opb constant field
  --    7:4   opb register field
  --    7:4   shift control field
  --    3:0   opa register field
  --
  alias inst_type  : std_logic_vector(TYPE_MSB downto 0) is ireg(15 downto 14);
  alias inst_fld   : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);
  
  alias arith_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
  alias logic_op   : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
  alias ctl_op     : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
  alias mem_op     : std_logic_vector(OP_MSB   downto 0)   is ireg(13 downto 12);
  
  alias arith_skip_nocarry  : std_logic is ireg(11);
  alias logic_notb : std_logic is ireg(11);
  alias lea_bit    : std_logic is ireg(11);
 
  alias ext_bit    : std_logic is ireg(11);
  
  --
  -- branch & extension group fields
  --
  alias bra_long   : std_logic is ireg(11);
  alias ret_type   : std_logic is ireg(10);
  alias call_type  : std_logic is ireg(10);
  alias dslot      : std_logic is ireg(9);
  alias bra_offset : std_logic_vector(8 downto 0) is ireg(8 downto 0);

  alias ext_grp    : std_logic_vector(3 downto 0) is ireg(7 downto 4);
  

  --
  -- LDI offset
  --
  alias ldi_offset : std_logic_vector(11 downto 0) is ireg(11 downto 0);
  
  --
  -- skip control bits
  --
  --alias skip_ctl    : std_logic_vector(2 downto 0) is ireg(11 downto 9);
  alias skip_sense : std_logic is ireg(11);
  alias skip_type  : std_logic_vector(2 downto 0) is ireg(10 downto 8);
 
  alias skip_cp_sel   : std_logic is ireg(7);
  alias skip_ra_type  : std_logic_vector(2 downto 0) is ireg(6 downto 4);
  
  --
  -- load/store/lea address mode & operand size/sign extension
  --
  alias mem_sign   : std_logic is ireg(11);
  alias mem_size   : std_logic_vector(1 downto 0) is ireg(10 downto 9);
  alias mem_mode   : std_logic is ireg(8);
  alias sp_offset  : std_logic_vector(3 downto 0) is ireg( 7 downto 4);

  
  --
  -- opb control fields
  --
  alias opb_ctl     : std_logic_vector(1 downto 0) is ireg(10 downto 9);

  alias opb_const   : std_logic_vector(4 downto 0) is ireg( 8 downto 4);
  alias sel_opb     : std_logic_vector(3 downto 0) is ireg( 7 downto 4);
  alias sel_opa     : std_logic_vector(3 downto 0) is ireg( 3 downto 0);
  
  --
  -- shift control
  --
  alias shift_grp    : std_logic                    is ireg(11);
  alias shift_signed : std_logic                    is ireg(10);
  alias shift_dir    : std_logic                    is ireg( 9);
  alias shift_const  : std_logic_vector(4 downto 0) is ireg( 8 downto 4);
 
  alias misc_grp : std_logic_vector(1 downto 0) is ireg(9 downto 8);

  --
  -- SPAM instruction fields
  --
  alias spam_mode : std_logic_vector(2 downto 0) is ireg(10 downto 8);
  alias spam_mask : std_logic_vector(7 downto 0) is ireg( 7 downto 0);
 

------------------------------------------------------------------------------
--
--  change this next flag with care
--    left over from conversion from unpipelined CLB RAM of the XC4000 family 
--    to pipelined blockram of the Spartan-II
--
--  set to TRUE if instruction memory is async, or clocked on falling edge to hide latency
--
--  set to FALSE if instruction memory is registered with a one clock delay 
--

--
-- CFG_REG_I_ADDR :
--   TRUE  : register i_addr from next pc logic to drive memory address
--   FALSE : remove address register, (puts ifetch into end of previous EX cycle)
--
constant CFG_REG_I_ADDR : boolean := TRUE;

--
--
------------------------------------------------------------------------------


begin

  ------------------------------------------------------------------------------
  --
  -- register file
  --
  ------------------------------------------------------------------------------

  regfile1: regfile
    port map
      (
        clk  => clk, 

        we   => wb_en, 
        wa   => force_sel_opa, 
        wd   => wb_bus,

        ra1  => force_sel_opa, 
        ra2  => sel_opb, 

        rd1  => ar, 
        rd2  => br
      );

--  --
--  -- force register file address to IMM (r14) for LDI and IMM12
--  --
--  force_sel_opa <= X"E" when ( inst_fld = OPM_IMM ) OR ( inst_fld = OPM_LDI )
--               else sel_opa;


  --
  -- register file writeback enable
  --   enable for arith & logic, load & move
  --   disable on reset or ex_null from branch/skip control
  --
  wb_ctl1: block

      signal wb_dcd : std_logic;

    begin
   
      wb_dcd <=   '1' when  (
                                   ( inst_type = OPA     )   
                              OR   ( inst_type = OPL     ) 

                              OR   ( inst_fld  = OPM_IMM ) 
                              OR ( ( inst_fld  = OPM_LD  ) AND ( d_stall = '0' ) )
                              OR ( ( inst_fld  = OPM_LDI ) AND ( d_stall = '0' ) )
                              OR ( ( inst_fld  = OPM_ST  ) AND ( lea_bit = '1' ) ) 
                            ) 
            else  '0';

      wb_en <= wb_dcd AND (NOT ex_null) AND rst_l;

    end block wb_ctl1;

  --
  -- stack, frame, and IMM register snooping
  --   these registers all live outside of register file RAM
  --   to allow reads & updates independent of normal two port 
  --   register file accesses
  --

  sp_fp_reg1: process (clk,rst_l)
    begin

      if  rst_l = '0' then
        fp_reg  <= ( others => '0');
        sp_reg  <= ( others => '0');
        imm_reg <= ( others => '0');

      elsif rising_edge(clk) then

        if ( wb_en = '1' ) AND ( force_sel_opa = REG_FP ) then
          fp_reg <= wb_bus;
        end if;

        if ( wb_en = '1' ) AND ( force_sel_opa = REG_SP ) then
          sp_reg <= wb_bus;
        end if;

        if ( wb_en = '1' ) AND ( force_sel_opa = REG_IMM ) then
          imm_reg <= wb_bus;
        end if;

      end if;

    end process;


  ------------------------------------------------------------------------------
  --
  -- immediate constant generation
  --
  ------------------------------------------------------------------------------
  I_cgen: cgen
   port map
     (
       opb_ctl   => opb_ctl,   
       opb_const => opb_const, 

       cg_out    => cg_out    
     );

 
  ------------------------------------------------------------------------------
  --
  -- operand selection
  --
  ------------------------------------------------------------------------------

  op_sel1: block

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
--      mux_bin <=   cg_out  when ( ireg(15)='0' ) AND ( opb_ctl(1 downto 0) /= "00" )
--             else imm_reg  when ( ireg(15)='0' ) AND ( sel_opb = REG_IMM )
--             else br;

      mux_bin <=   cg_out  when ( ireg(15)='0' ) AND ( opb_ctl(1 downto 0) /= "00" )
             else  bin;

      --
      -- new code, share B inverter for SUB & logicals
      --
      mux_inv_bin <=   NOT mux_bin when ( (inst_type = OPL ) AND (logic_notb = '1') ) OR ( inst_fld = OPA_SUB )
                 else      mux_bin;

         
    end block op_sel1;

  ------------------------------------------------------------------------------
  --
  -- arithmetic operations ( add, subtract, reverse subtract )
  --
  ------------------------------------------------------------------------------
  I_addsub: addsub
    port map
      (
        inst_fld   => inst_fld,
        arith_op   => arith_op,

        ain        => ain,
        bin        => mux_inv_bin,
  
        arith_cout => arith_cout,
        arith_dat  => arith_dat
      );


  ------------------------------------------------------------------------------
  --
  -- logical operations  ( move, and, or, xor )
  --
  ------------------------------------------------------------------------------
  I_logicals: logicals
    port map
      (   
        logic_op  => logic_op,   

        ain       => ain,        
        bin       => mux_inv_bin,        
  
        logic_dat => logic_dat
      );
  

  ------------------------------------------------------------------------------
  --
  -- shifts & rotates
  --
  ------------------------------------------------------------------------------

  --
  --  only 1 bit shift/rotate lengths are currently implemented
  --
  GT_barrel: if CFG.barrel_shift generate
    begin

      assert FALSE
        report "Barrel Shifter is not implemented yet!"
        severity error;

    end generate GT_barrel;


  GF_barrel: if NOT CFG.barrel_shift generate
    begin

      I_shift_one: shift_one
       port map
         (
           shift_grp    =>  shift_grp,    
           shift_signed =>  shift_signed, 
           shift_dir    =>  shift_dir,    

           ain          =>  ain,          

           shift_dat    =>  shift_dat    
         );

    end generate GF_barrel;

  ------------------------------------------------------------------------------
  --
  -- bit seek instructions ( find first bit, bit count )
  --
  ------------------------------------------------------------------------------

  GT_seek: if CFG.bit_seek generate
    begin

      I_ffb: ffb
        port map
         (
           din   => bin,
           first => ffb_dat
         );

      I_bitcnt: bitcnt
        port map
         (
           din  => bin,
           cnt  => bitcnt_dat
         );
  
    end generate GT_seek;

  GF_seek: if NOT CFG.bit_seek generate
    begin

      ffb_dat    <= ( others => '0' );
      bitcnt_dat <= ( others => '0' );

    end generate GF_seek;

  ------------------------------------------------------------------------------
  --
  -- FLIP instruction  ( universal bit swapper )
  --
  ------------------------------------------------------------------------------

  GT_flip: if CFG.bit_flip generate
    begin

      flip1: flip
        port map
         (
           bsel  => shift_const,
           din   => ain,
           dout  => flip_dat
         );

    end generate GT_flip;

  GF_flip: if NOT CFG.bit_flip generate
    begin

      flip_dat <= ( others => '0' );

    end generate GF_flip;

  
  ------------------------------------------------------------------------------
  --
  --   PC Relative address calculation
  --     calculates pc_reg_p1 instruction relative offsets
  --     LDI; EA; call return addresses 
  --
  ------------------------------------------------------------------------------
  I_pcr_calc: pcr_calc
    port map
      (
        inst_fld   => inst_fld,  
        sel_opb    => sel_opb,

        dslot      => dslot,
        call_type  => call_type,
        ext_bit    => ext_bit,  
        ext_grp    => ext_grp,  

        ldi_offset => ldi_offset,

        pc_reg_p1  => pc_reg_p1, 
                   
        pcr_addr   => pcr_addr
      );


  ------------------------------------------------------------------------------
  --
  --   Effective Address calculation
  --
  ------------------------------------------------------------------------------
  I_ea_calc: ea_calc
    port map
      (
        inst_fld       => inst_fld,  
        mem_size       => mem_size,  
        mem_mode       => mem_mode,  
        sel_opb        => sel_opb,

        bin            => bin,      
        imm_reg        => imm_reg,   

        sp_offset      => sp_offset, 
        ldi_offset     => ldi_offset,

        sp_reg         => sp_reg,    
        fp_reg         => fp_reg,    

        pcr_addr       => pcr_addr, 
                   
        ea_dat         => ea_dat    
      );


  ------------------------------------------------------------------------------
  --
  -- writeback mux
  --    replaces old TBUF writeback code with mux cascade
  --
  ------------------------------------------------------------------------------
  wb_mux : block

    signal wb_muxb : std_logic_vector(ALU_MSB downto 0);

--    attribute keep of wb_muxb  : signal is true;

    begin

      wb_bus  <=   arith_dat    when  ( inst_type = OPA      ) AND ( arith_op /= T_MISC  )
             else  ea_dat       when  ( inst_fld  = OPM_ST   ) AND ( lea_bit = '1'       ) 
             else  mem_wb_bus   when  ( inst_fld  = OPM_LD   ) OR  ( inst_fld  = OPM_LDI )
             else  wb_muxb;

      wb_muxb <=   logic_dat    when  ( inst_type = OPL      ) 
             else  flip_dat     when  ( inst_fld  = OPA_MISC ) AND ( shift_grp = '0' ) AND ( shift_signed='1' ) AND ( shift_dir = '1' )

             else  ( ALU_MSB downto 12 => ireg(11) ) & ireg(11 downto 0) when ( inst_fld = OPM_IMM )

             -- BMD hardcoded 32 bit sign/zero extend
             else ( ALU_MSB downto 6 => ffb_dat(5) ) & ffb_dat   when (inst_fld = OPA_MISC ) AND (shift_grp = '1') AND (shift_signed = '1') AND (misc_grp = MISC_FFB) 
             else ( ALU_MSB downto 6 => '0' ) & bitcnt_dat       when (inst_fld = OPA_MISC ) AND (shift_grp = '1') AND (shift_signed = '1') AND (misc_grp = MISC_CNTB) 

             -- anything left in MISC should be a normal shift/rotate
             else  shift_dat    when  ( inst_fld  = OPA_MISC ) 
 
             else  ( others => '0' );

    end block wb_mux;

  ------------------------------------------------------------------------------
  --
  -- skip condition logic
  --
  ------------------------------------------------------------------------------

  I_skip_dcd: skip_dcd
    generic map
      ( CFG          => CFG )

    port map
      (
        skip_sense   => skip_sense,  
        skip_type    => skip_type,   
        skip_cp_sel  => skip_cp_sel, 
        skip_ra_type => skip_ra_type,

        sel_opa      => sel_opa,     
        opb_const    => opb_const,   

        ain          => ain,         
        bin          => bin,        

        flag_reg     => flag_reg,    

        skip_cond    => skip_cond   
      );

  --
  -- register input flags before use
  --
  process(clk)
    begin
      if rising_edge(clk) then
        flag_reg <= in_flags;
      end if;
    end process;


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
  irq_enable <= '0';

  -- register inputs 
  process (clk,rst_l)
    begin
      if  rst_l = '0' then
        irq_p0   <= '1';
        irq_p1   <= '1';
        irq_p2   <= '1';
        irq_edge <= '0';

      elsif rising_edge(clk) then
        irq_p0   <= irq_l;
        irq_p1   <= irq_p0;
        irq_p2   <= irq_p1;
        irq_edge <= ( NOT irq_p1 AND irq_p2 ) AND irq_enable;

      end if;
    end process;

  --
  -- status register
  --
  --   top 8 bits (the null_sr bits) are coded along with the instruction flow logic
  --
  --   missing :
  --
  --     - push/pop for interrupts & RTI ( started coding )
  --
  --     - define currently unused bits ( interrupt masks, levels, etc. )
  --        - especially the interrupt enables for single level interrupt code
  --          ( disable interrupts on irq after pushing old SR to stack )
  --
  sr1:  process (clk,rst_l)
    begin
  
      if  rst_l = '0' then
        st_reg(SR_MSB-8 downto 0) <= ( others => '0');
  
      elsif rising_edge(clk) then
  
        -- FIXME: this is one cycle too early for SR restore
        if ( ex_null = '0' ) AND ( inst_fld = OPC_EXT ) AND (ext_bit = '1' ) AND (ext_grp = EXT_RETURN ) AND ( ret_type = '1' )  then 
          st_reg(SR_MSB-8 downto 0) <= rsp_sr(SR_MSB-8 downto 0); 
        end if;
   
      end if;
  
    end process sr1;

  --
  -- generate masks for SPAM instruction
  --
  with spam_mode select
  spam_length_mask  <=
    X"FF" when B"000",
    X"FE" when B"001",
    X"FC" when B"010",
    X"F8" when B"011",
    X"F0" when B"100",
    X"E0" when B"101",
    X"C0" when B"110",
    X"FF" when others;           

  --
  -- compute extended branch offset
  -- BMD compiles for 32 bit core only as currently coded
  --
  ext_bra_offset <=

         imm_reg(21 downto 0) & bra_offset & '0'  
    when ( bra_long = '1' )

    else ( ALU_MSB downto 10 => bra_offset(8) ) & bra_offset & '0'
    ;


  -- 
  -- instruction flow 
  --   creates PC, flow control logic
  --
  -- re-write as block?  used to be a clocked process...  
  --
  pc1: process ( inst_fld, ext_grp, skip_cond, ex_null, ret_type, pc_reg, pc_reg_p1, rsp_pc, rsp_sr, bra_offset, bra_long, dslot, ain, d_stall, arith_skip_nocarry, arith_cout, imm_reg, spam_mode, spam_mask, spam_length_mask )

    begin

      --
      -- flow control logic
      --

      if ( d_stall = '1' ) AND ( (inst_fld = OPM_LD ) OR (inst_fld = OPM_LDI ) ) then
        --
        -- data stall
        --
        next_pc       <= pc_reg;
        next_null_sr  <= null_sr;
  
      elsif ( inst_fld = OPC_EXT ) AND (ext_bit = '0' ) then
        --
        -- SPAM instruction
        --
        next_pc       <= pc_reg + PC_INC_I1;

        if spam_mode = B"111" then
          next_null_sr  <= ( 7 downto 0 => ex_null ) AND spam_mask;
        else
          next_null_sr  <= ( ( 7 downto 0 => ex_null ) XOR spam_mask ) AND spam_length_mask;
        end if;

      elsif ( ex_null = '1' ) then
        --
        -- nullified instruction
        --
        next_pc       <= pc_reg + PC_INC_I1;
        next_null_sr  <= null_sr(6 downto 0) & '0';

      else
        --
        -- instruction execution
        --

        case inst_fld is

          when OPC_BR =>
            next_pc       <= pc_reg_p1 + ext_bra_offset(PC_MSB downto 0);
            next_null_sr  <= NOT dslot & B"000_0000";

          when OPC_EXT =>
            if (ext_grp = EXT_JUMP) AND (ext_bit = '1' ) then
              next_pc       <= ain(PC_MSB downto 0);
              next_null_sr  <= NOT dslot & B"000_0000";

            elsif (ext_grp = EXT_RETURN) AND (ext_bit = '1' ) then
              next_pc       <= rsp_pc;

              --
              -- existing code won't work for skip, bra.d, etc. 
              -- that would have changed next state
              --
              -- TODO: revised approach
              --
              -- enter interrupt:
              --   - null current EX stage
              --   - push EX stage inst. address & status register
              --   - next_pc = instruction vector
              --   - set interrupt status flag
              --
              -- exit interrupt:
              --   - #1 pop PC
              --   - #1 execute or null delay slot as indicated by rti
              --   - #2 pop SR during delay slot execution
              --
              --

              -- ??  load next_null sr with dslot & stacked bits of saved null 
              -- state for an rti ( was top bit was already used when stacked ) ??
              if ( ret_type = '1' ) then 
                next_null_sr  <= NOT dslot & rsp_sr(SR_MSB-1 downto SR_MSB-7);
              else
                next_null_sr  <= NOT dslot & B"000_0000";
              end if;

--            -- this pops ex_null too early: pops old SR while executing RTI branch slot,
--            -- which clobbers ex_null bit of current SR that's nulling RTI branch slot,
--            -- plus improperly restoring null bit for interrupted instruction
--            if ( ret_type = '1' ) then 
--                next_null <= rsp_sr(SR_MSB); 
--              else
--                next_null <= '1';
--              end if;

            -- others in EXT group
            else
              next_pc       <= pc_reg + PC_INC_I1;
              next_null_sr  <= null_sr(6 downto 0) & '0';
    
          end if;
    
          when OPC_SKIP =>
            next_pc       <= pc_reg + PC_INC_I1;
            next_null_sr  <= ( skip_cond OR null_sr(6) ) & null_sr(5 downto 0) & '0';
    
          when OPA_ADD =>
            next_pc       <= pc_reg + PC_INC_I1;
            next_null_sr  <= ( ( arith_skip_nocarry AND NOT arith_cout) OR null_sr(6) ) & null_sr(5 downto 0) & '0';
  
          when OPA_SUB =>
            next_pc       <= pc_reg + PC_INC_I1;
            next_null_sr  <= ( ( arith_skip_nocarry AND NOT arith_cout) OR null_sr(6) ) & null_sr(5 downto 0) & '0';
    
          when OPA_RSUB  =>
            next_pc       <= pc_reg + PC_INC_I1;
            next_null_sr  <= ( ( arith_skip_nocarry AND NOT arith_cout) OR null_sr(6) ) & null_sr(5 downto 0) & '0';
                                                                                                            
          when others  =>
            next_pc       <= pc_reg + PC_INC_I1;
            next_null_sr  <= null_sr(6 downto 0) & '0';
    
        end case;
    
      end if; 
    
    end process pc1;

    
  --
  --   register next_pc
  --
  pcr1: process (clk,rst_l)
    begin
  
      if rst_l = '0' then
        pc_reg   <= PC_RST_VEC;
        null_sr  <= B"1000_0000";
  
      elsif rising_edge(clk) then
        pc_reg   <= next_pc;
        null_sr  <= next_null_sr;

      end if;
  
    end process pcr1;


  --
  -- pipeline registers, hold on data stall
  --
  --   instruction register
  --   pipelined copy of PC for EX stage
  --
  --   moved opa select field force logic before ireg to reduce critical path
  --
  pipe_reg1: process (clk,rst_l)
    begin
 
      if  rst_l = '0' then
        pc_reg_p1 <= PC_RST_VEC;
        ireg <= ( others => '0');
 
      elsif rising_edge(clk) then

        if ( d_stall = '1' ) AND ( (inst_fld = OPM_LD ) OR (inst_fld = OPM_LDI ) ) then
          pc_reg_p1     <= pc_reg_p1;
          ireg          <= ireg;
          force_sel_opa <= force_sel_opa;
  
        else
          pc_reg_p1 <= pc_reg;
          ireg      <= i_dat;

          if  ( i_dat(15 downto 12) = OPM_IMM ) OR ( i_dat(15 downto 12) = OPM_LDI ) then
            force_sel_opa <= X"E" ;
          else 
            force_sel_opa <= i_dat(3 downto 0);
          end if;
  
        end if;
 
      end if;
 
   end process pipe_reg1;




  ------------------------------------------------------------------------------
  --
  -- return stack
  --
  ------------------------------------------------------------------------------
  I_stack: rstack
    port map
      (
        clk    => clk, 
        rst_l  => rst_l,

        push   => dcd_push, 
        pop    => dcd_pop,

        --
        -- TODO: add test cases for new return address calculation for delayed calls (bsr.d, jsr.d)
        --
        pc_in  => pcr_addr(PC_MSB downto 0), 
        sr_in  => st_reg,

        pc_stk => rsp_pc, 
        sr_stk => rsp_sr
      );


  --
  -- stack control lines
  --
  B_stk_ctl: block
    begin

      dcd_push <= '1'
        when (
               (
                     ( (inst_fld = OPC_EXT) AND (ext_bit = '1' ) AND ( ext_grp = EXT_JUMP ) )
                 OR  ( inst_fld = OPC_BR )
               )
               AND ( call_type = '1' ) 
               AND ( ex_null = '0' )
             )
--             OR  ( irq_edge = '1' )
        else '0';
  
      dcd_pop <= '1'
        when (inst_fld  = OPC_EXT) AND (ext_bit = '1' ) AND (ext_grp = EXT_RETURN )  AND ( ex_null = '0')
        else '0';

    end block B_stk_ctl;
  
  ------------------------------------------------------------------------------
  --
  -- instruction bus control signals and drivers 
  --
  ------------------------------------------------------------------------------

  --
  -- instruction bus control ( read, enable permanently asserted active )
  --
  i_en_l <= '0';
  i_rd_l <= '0';
  
  --
  -- generate registered or non-registered inst. address bus
  --   see comments near CFG_REG_I_ADDR flag declaration
  --
  GT_iaddr: if CFG_REG_I_ADDR = TRUE generate
     begin
       i_addr <= pc_reg;
     end generate GT_iaddr;

  GF_iaddr: if CFG_REG_I_ADDR = FALSE generate
     begin
       i_addr <= next_pc;
     end generate GF_iaddr;
  

  ------------------------------------------------------------------------------
  --
  -- data bus interface
  --
  ------------------------------------------------------------------------------

  --
  -- data bus address sourced by ea adder
  --
  d_addr <= ea_dat;

  --
  -- data bus control signals
  --
  I_dbus_ctl: dbus_ctl
    port map
      (
        inst_fld  => inst_fld,  
        ex_null   => ex_null,   
        mem_size  => mem_size,  
        lea_bit   => lea_bit,   
                               
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
        inst_fld  => inst_fld,  
        mem_size  => mem_size,  
        lea_bit   => lea_bit,   
  
        ain       => ain,        

        d_wdat    => d_wdat
      );


  --
  -- byte/wyde {sign extending} lane mux for loads
  --
  I_ld_mux: ld_mux
    generic map
      ( CFG        => CFG )

    port map
      (
        inst_fld   => inst_fld,   
        mem_size   => mem_size,   
        mem_sign   => mem_sign,   

        ea_lsbs    => ea_dat(1 downto 0),     

        d_rdat     => d_rdat,     

        mem_wb_bus => mem_wb_bus 
      );


  ------------------------------------------------------------------------------
  --
  -- drive simulation probe signals 
  --
  ------------------------------------------------------------------------------

  -- pragma translate_off

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

      y1a_probe_sigs.rsp_pc     <= ( ALU_MSB downto PC_MSB+1 => '0') & rsp_pc;

      y1a_probe_sigs.fp_reg     <= fp_reg;
      y1a_probe_sigs.sp_reg     <= sp_reg;

      y1a_probe_sigs.ea_dat     <= ea_dat;

      y1a_probes <= y1a_probe_sigs;

    end block B_probe;

  -- pragma translate_on
  
end arch1;
 
 
 
