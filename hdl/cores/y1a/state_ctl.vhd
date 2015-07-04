--
-- <state_ctl.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2015  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A processor state control
--
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_unsigned."+";
  use ieee.std_logic_unsigned."-";

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;


entity state_ctl is
  generic
    (
      CFG                : y1a_config_type
    );

  port
    (   
      clk                : in  std_logic;
      sync_rst           : in  std_logic;

      irq_sync_l         : in  std_logic;

      inst               : in  std_logic_vector(INST_MSB downto 0);
      d_stall            : in  std_logic; 

      skip_cond          : in  std_logic;
      arith_cout         : in  std_logic;

      ain                : in  std_logic_vector(ALU_MSB downto 0);
      imm_reg            : in  std_logic_vector(ALU_MSB downto 0);

      rsp_pc             : in  std_logic_vector(PC_MSB downto 0);

      dcd_stall          : out std_logic;
      irq_null           : out std_logic;

      st_reg_out         : out std_logic_vector(SR_MSB downto 0);

      pc_reg_out         : out std_logic_vector(PC_MSB downto 0);
      pc_reg_p1_out      : out std_logic_vector(PC_MSB downto 0)
    );

end state_ctl;


architecture arch1 of state_ctl is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  attribute syn_keep : boolean;


  signal stall                : std_logic;
  attribute syn_keep of stall : signal is TRUE;

  signal next_pc              : std_logic_vector(PC_MSB downto 0);

  signal pc_reg               : std_logic_vector(PC_MSB downto 0);
  signal pc_reg_p1            : std_logic_vector(PC_MSB downto 0);

  signal st_reg               : std_logic_vector(SR_MSB downto 0);
  alias  ex_null              : std_logic is st_reg(SR_MSB);

  signal next_null_sr         : std_logic_vector(7 downto 0);
  alias  null_sr              : std_logic_vector(7 downto 0) is st_reg(SR_MSB downto SR_MSB - 7 );

  signal ext_bra_offset       : std_logic_vector(ALU_MSB downto 0);

  signal spam_length_mask     : std_logic_vector(7 downto 0);

  --
  -- interrupt logic
  --
  signal irq_enable  : std_logic;

  signal irq_active  : std_logic;

  signal irq_req_z0  : std_logic;
  signal irq_req_z1  : std_logic;

  signal dcd_rti     : std_logic;

  signal dcd_rti_z0  : std_logic;
  signal dcd_rti_z1  : std_logic;

  signal irq_pc_A    : std_logic_vector(PC_MSB downto 0);
  signal irq_pc_B    : std_logic_vector(PC_MSB downto 0);

  signal irq_sr_A    : std_logic_vector(SR_MSB downto 0);

  --
  -- instruction register
  --
  signal ireg                 : std_logic_vector(INST_MSB downto 0);

  --
  -- local instruction decode aliases
  --
  alias inst_fld              : std_logic_vector(ID_MSB   downto 0)   is ireg(15 downto 12);

  alias arith_skip_nocarry    : std_logic is ireg(11);
  alias bra_long              : std_logic is ireg(11);
  alias ext_bit               : std_logic is ireg(11);
  alias ret_type              : std_logic is ireg(10);
  alias dslot_null            : std_logic is ireg(9);

  alias bra_offset            : std_logic_vector(8 downto 0) is ireg(8 downto 0);

  alias ext_grp               : std_logic_vector(3 downto 0) is ireg(7 downto 4);

  --
  -- coprocessor fields
  --
  alias cp_op                 : std_logic_vector(2 downto 0) is ireg(10 downto 8);
  alias cp_num                : std_logic_vector(3 downto 0) is ireg( 7 downto 4);

  --
  -- SPAM instruction fields
  --
  alias spam_mode             : std_logic_vector(2 downto 0) is ireg(10 downto 8);
  alias spam_mask             : std_logic_vector(7 downto 0) is ireg( 7 downto 0);


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
  -- decode for stall condition
  --
  stall  <=  '1'  when ( d_stall = '1' ) AND ( (inst_fld = OPM_LD ) OR (inst_fld = OPM_LDI ) ) 
        else '0';


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
  -- FIXME: re-write as block?  used to be a clocked process...  
  --
  pc1: process ( inst_fld, ext_grp, skip_cond, ex_null, ret_type, st_reg, pc_reg, pc_reg_p1, rsp_pc, ext_bra_offset, dslot_null, ain, stall, arith_skip_nocarry, arith_cout, imm_reg, spam_mode, spam_mask, spam_length_mask )

    begin

      --
      -- flow control logic
      --

      if ( inst_fld = OPC_EXT ) AND (ext_bit = '0' ) then
        --
        -- SPAM instruction
        --
        next_pc       <= pc_reg + PC_INC_I1;

        if spam_mode = B"111" then
          next_null_sr  <= ( 7 downto 0 => ex_null ) AND spam_mask;
        else
          next_null_sr  <= ( ( 7 downto 0 => ex_null ) XOR (NOT spam_mask) ) AND spam_length_mask;
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
            next_null_sr  <= dslot_null & B"000_0000";

          when OPC_EXT =>
            if (ext_grp = EXT_JUMP) AND (ext_bit = '1' ) then
              next_pc       <= ain(PC_MSB downto 0);
              next_null_sr  <= dslot_null & B"000_0000";

            --
            -- RTS; RTI handled below in PC & SR register code
            --
            elsif (ext_grp = EXT_RETURN) AND (ext_bit = '1' ) then
              next_pc       <= rsp_pc;
              next_null_sr  <= dslot_null & B"000_0000";

            --
            -- others in EXT group
            --
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
  -- interrupt control logic
  --

  --  
  -- CP0 OP7 sets/clears irq_enable flag
  --  
  P_irq_en : process
    begin
      wait until rising_edge(clk);

      if sync_rst = '1' then
        irq_enable <=  '0';

      elsif ( inst_fld = OPC_CP ) AND ( cp_op = CP_OP7 ) AND ( cp_num = X"0" )  then
        --
        -- ireg( 2) => ctl bit mask for interrupt enable
        -- ireg(11) => set/clear
        --
        if ireg(2) = '1' then
          irq_enable <= ireg(11);
        end if;

      end if;

    end process;


  dcd_rti <=   '1'   when ( inst_fld = OPC_EXT ) AND (ext_grp = EXT_RETURN) AND (ext_bit = '1' ) AND ( ret_type = '1' ) AND ( ex_null = '0' )
          else '0';


  P_irq_ctl : process
    begin

      wait until rising_edge(clk);
  
      if sync_rst = '1' then
        irq_req_z0  <= '0';
        irq_req_z1  <= '0';

        dcd_rti_z0  <= '0';
        dcd_rti_z1  <= '0';

        irq_active  <= '0';

      --
      -- FIXME: check whether interrupts work with stalls
      --
      elsif ( stall = '0' ) then
        irq_active  <= (irq_enable AND NOT irq_sync_l AND NOT irq_active) OR (irq_active AND NOT dcd_rti_z0);

        irq_req_z0  <= irq_enable AND NOT irq_sync_l AND NOT irq_active;
        irq_req_z1  <= irq_req_z0;

        dcd_rti_z0  <= dcd_rti;
        dcd_rti_z1  <= dcd_rti_z0;

      end if;

    end process;


  --
  -- interrupt state registers
  --
  P_isr: process 
    begin
      wait until rising_edge(clk);

      if sync_rst = '1' then
        irq_pc_A <= (others => '0');
        irq_pc_B <= (others => '0');
        irq_sr_A <= (others => '0');

      elsif ( irq_req_z0 = '1' ) then

        -- Plan A : null pre-fetched instruction & restart from there after interrupt
        irq_pc_A <= pc_reg;
        irq_sr_A <= next_null_sr & st_reg(SR_MSB-8 downto 0);
        irq_pc_B <= next_pc;
  
        -- Plan B : execute pre-fetched instruction
        --  irq_pc_A <= next_pc;
        --  irq_sr_A <= next_null_sr & st_reg(SR_MSB-8 downto 0);
  
      end if;


--      --
--      -- Plan B : execute pre-fetched instruction
--      -- problem: pc_reg has already been hijacked by interrupt, so next_pc here is bogus
--      --
--      if sync_rst = '1' then
--        irq_pc_B <= (others => '0');
--
--      elsif ( irq_req_z1 = '1' ) then
--
--        irq_pc_B <= next_pc;
--  
--      end if;

    end process;


  --
  -- PC & SR register & mux logic
  --
  P_pc_sr: process 
    begin
      wait until rising_edge(clk);

      if sync_rst = '1' then
        pc_reg   <= PC_RST_VEC;
        st_reg   <= B"1000_0000" & X"00_00_00";

      elsif ( stall = '1' ) then
        pc_reg   <= pc_reg; 
        st_reg   <= st_reg; 

      --
      --  irq sequencing
      --
      elsif ( irq_req_z0 = '1' ) then
        pc_reg   <= PC_IRQ_VEC;

        st_reg   <= B"1000_0000" & st_reg(SR_MSB-8 downto 0);     -- plan A, null the prefetched instruction
        --st_reg   <= next_null_sr & st_reg(SR_MSB-8 downto 0);   -- plan B

      --
      -- This next test handles the case of interrupting a SPAM instruction.
      -- The ex_null from the irq would otherwise set next_null in the ISR 
      -- as per the mask for the SPAM, because SPAM has priority over ex_null 
      -- in the flow control logic
      --
      elsif ( irq_req_z1 = '1' ) then
        pc_reg   <= next_pc;
        st_reg   <= B"0000_0000" & st_reg(SR_MSB-8 downto 0); 

      elsif ( dcd_rti = '1' ) then
        pc_reg   <= irq_pc_A;
        st_reg   <= next_null_sr & st_reg(SR_MSB-8 downto 0);

      elsif ( dcd_rti_z0 = '1' ) then
        pc_reg   <= irq_pc_B;
        st_reg   <= irq_sr_A;

      --
      -- normal instruction sequence
      --
      else
        pc_reg   <= next_pc;
        st_reg   <= next_null_sr & st_reg(SR_MSB-8 downto 0);

      end if;

    end process;


  --
  -- pipelined copy of PC for EX stage
  --
  P_pc_pipe: process
    begin
      wait until rising_edge(clk);
 
      if sync_rst = '1' then
        pc_reg_p1 <= PC_RST_VEC;

      elsif ( stall = '1' ) then
        pc_reg_p1 <= pc_reg_p1;
  
      else
        pc_reg_p1 <= pc_reg;

      end if;
 
   end process;


  --
  -- connect output ports to internal registers
  --
  dcd_stall     <= stall;
  irq_null      <= irq_req_z1;

  st_reg_out    <= st_reg;

  pc_reg_out    <= pc_reg;
  pc_reg_p1_out <= pc_reg_p1;
    
end arch1;












