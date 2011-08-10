--
-- <y1_constants.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2011  B. Davis
--
-- Code released under the terms of the "new BSD" license
-- see license/new_bsd.txt
--
---------------------------------------------------------------

--
--
-- YARD-1 constants file
--
--   defines opcode and datapath related constants
--


library ieee;
  use ieee.std_logic_1164.all;

package y1_constants is

  -------------------------------------------------------------------------
  --
  -- the following constants may be changed as noted
  --  these may move into config package at some point
  --

  --
  -- datapath width, 16 bit is no longer supported  ( see also ADDR_WORD_LSB )
  --
  constant ALU_WIDTH : integer := 32;
  --constant ALU_WIDTH : integer := 16;

  --
  -- program counter width
  --   PC is now a byte pointer, always on an even address
  --
  -- note:
  --   setting PC_WIDTH < ALU_WIDTH allows eliminating unused MSB's from PC adder and return stack 
  --   this will trim the core size when using only small internal instruction memories
  --   ( unused PC upper bits are zero-extended when used as an address register )
  -- 
  --constant PC_WIDTH : integer := ALU_WIDTH;
  constant PC_WIDTH   : integer := 16;

  -- return stack depth
  constant RSTACK_DEPTH : integer := 16;

  -- return stack pointer width, needs to be log2(RSTACK_DEPTH)
  constant RSP_WIDTH : integer := 4;

  --
  --  end of safely editable constants
  --
  -------------------------------------------------------------------------


  --
  -- changing any of the following constants will require associated code changes
  --

  --
  -- ALU_WIDTH defined above
  --
  constant ALU_MSB   : integer := ALU_WIDTH-1;

  constant ALU_ZERO: std_logic_vector(ALU_MSB downto 0) := ( others => '0');

  --
  -- number of registers
  --
  constant RF_DEPTH    : integer := 16;
  constant RF_ADDR_MSB : integer := 3;
  constant RF_DAT_MSB  : integer := ALU_MSB;

  --
  -- special registers
  --
  constant REG_FP      : std_logic_vector(RF_ADDR_MSB downto 0) := X"C";
  constant REG_SP      : std_logic_vector(RF_ADDR_MSB downto 0) := X"D";
  constant REG_IMM     : std_logic_vector(RF_ADDR_MSB downto 0) := X"E";
  constant REG_PC      : std_logic_vector(RF_ADDR_MSB downto 0) := X"F";

  --
  -- data address width, must equal datapath width for now
  --
  constant ADDR_WIDTH  : integer := ALU_WIDTH;
  constant ADDR_MSB    : integer := ADDR_WIDTH-1;

  -- LSB used for native word size addressing of memory
  --   changes when processor width changes ( 16 bit -> 1   32 bit -> 2)
  -- this kludge works only for 16/32, should change to log lookup 
  --
  constant ADDR_WORD_LSB   : integer := (ALU_WIDTH/16);

  --
  -- PC_WIDTH defined above
  --
  constant PC_MSB      : integer := PC_WIDTH-1;
                        
  constant PC_INC_I1   : std_logic_vector(PC_MSB downto 0) := ( PC_MSB downto 2 => '0', 1 => '1', 0 => '0');
  constant PC_RST_VEC  : std_logic_vector(PC_MSB downto 0) := ( others => '0' );

  --
  -- temporarily hardcode interrupt vector
  --
  constant PC_IRQ_VEC  : std_logic_vector(PC_MSB downto 0) := ( PC_MSB downto 8 => '0' ) & X"02";

  --
  -- return stack 
  --
  -- RSP_DEPTH, RSP_WIDTH defined above
  constant RSP_MSB     : integer := RSP_WIDTH-1;

  --
  ---- status register width
  --
  constant SR_WIDTH    : integer := ALU_WIDTH;
  constant SR_MSB      : integer := SR_WIDTH-1;

  --
  -- instruction field width
  --
  constant INST_WIDTH  : integer := 16;
  constant INST_MSB    : integer := INST_WIDTH-1;

  --
  -- four bit wide instruction decode field
  --   two bits for type
  --   two bits for op
  --
  constant ID_WIDTH    : integer := 4;
  constant ID_MSB      : integer := ID_WIDTH-1;

  constant TYPE_WIDTH  : integer := 2;
  constant TYPE_MSB    : integer := TYPE_WIDTH-1;

  constant OP_WIDTH    : integer := 2;
  constant OP_MSB      : integer := OP_WIDTH-1;

  --
  -- instructions grouped by type
  --   logical, arithmetic, memory, control
  --
  constant OPL     : std_logic_vector( TYPE_MSB downto 0) := B"00";
  constant OPA     : std_logic_vector( TYPE_MSB downto 0) := B"01";
  constant OPM     : std_logic_vector( TYPE_MSB downto 0) := B"10";
  constant OPC     : std_logic_vector( TYPE_MSB downto 0) := B"11";

  --
  -- constants "OP?_xxx" include type and op
  -- constants "T_xxx" include op field only
  --

  --
  -- logical, move
  --
  constant T_MOV    : std_logic_vector( OP_MSB downto 0) :=  B"00";
  constant T_AND    : std_logic_vector( OP_MSB downto 0) :=  B"01";
  constant T_OR     : std_logic_vector( OP_MSB downto 0) :=  B"10";
  constant T_XOR    : std_logic_vector( OP_MSB downto 0) :=  B"11";

  constant OPL_MOV  : std_logic_vector( ID_MSB downto 0) := OPL & T_MOV;
  constant OPL_AND  : std_logic_vector( ID_MSB downto 0) := OPL & T_AND;
  constant OPL_OR   : std_logic_vector( ID_MSB downto 0) := OPL & T_OR ;
  constant OPL_XOR  : std_logic_vector( ID_MSB downto 0) := OPL & T_XOR;

  --
  -- arithmetic
  --
  constant T_ADD    : std_logic_vector( OP_MSB downto 0 ) :=  B"00";
  constant T_SUB    : std_logic_vector( OP_MSB downto 0 ) :=  B"01";
  constant T_RSUB   : std_logic_vector( OP_MSB downto 0 ) :=  B"10";
  constant T_MISC   : std_logic_vector( OP_MSB downto 0 ) :=  B"11";

  --constant T_SHIFT : std_logic_vector( OP_MSB downto 0) :=  B"11";

  constant OPA_ADD  : std_logic_vector( ID_MSB downto 0 ) := OPA & T_ADD;
  constant OPA_SUB  : std_logic_vector( ID_MSB downto 0 ) := OPA & T_SUB;
  constant OPA_RSUB : std_logic_vector( ID_MSB downto 0 ) := OPA & T_RSUB;
  constant OPA_MISC : std_logic_vector( ID_MSB downto 0 ) := OPA & T_MISC;

  --constant OPA_SHIFT : std_logic_vector( ID_MSB downto 0) := OPA & T_SHIFT;

  --
  -- memory 
  --
  constant T_LD     : std_logic_vector( OP_MSB downto 0 ) :=  B"00";
  constant T_ST     : std_logic_vector( OP_MSB downto 0 ) :=  B"01";
  constant T_LDI    : std_logic_vector( OP_MSB downto 0 ) :=  B"10";
  constant T_IMM    : std_logic_vector( OP_MSB downto 0 ) :=  B"11";

  constant OPM_LD   : std_logic_vector( ID_MSB downto 0 ) := OPM & T_LD;
  constant OPM_ST   : std_logic_vector( ID_MSB downto 0 ) := OPM & T_ST;
  constant OPM_LDI  : std_logic_vector( ID_MSB downto 0 ) := OPM & T_LDI;
  constant OPM_IMM  : std_logic_vector( ID_MSB downto 0 ) := OPM & T_IMM;


  --
  -- control
  --
  constant T_CP     : std_logic_vector( OP_MSB downto 0 ) :=  B"00";
  constant T_SKIP   : std_logic_vector( OP_MSB downto 0 ) :=  B"01";
  constant T_BR     : std_logic_vector( OP_MSB downto 0 ) :=  B"10";
  constant T_EXT    : std_logic_vector( OP_MSB downto 0 ) :=  B"11";


  constant OPC_CP   : std_logic_vector( ID_MSB downto 0 ) := OPC & T_CP;
  constant OPC_SKIP : std_logic_vector( ID_MSB downto 0 ) := OPC & T_SKIP;
  constant OPC_BR   : std_logic_vector( ID_MSB downto 0 ) := OPC & T_BR;
  constant OPC_EXT  : std_logic_vector( ID_MSB downto 0 ) := OPC & T_EXT;


  ------------------------------------------------------------------------
  --
  -- define subfield encoding constants
  --
  ------------------------------------------------------------------------

  --
  -- MISC subfield
  --
  constant MISC_SPARE1 : std_logic_vector(1 downto 0) := B"00";
  constant MISC_SPARE2 : std_logic_vector(1 downto 0) := B"01";
  constant MISC_FFB    : std_logic_vector(1 downto 0) := B"10";
  constant MISC_CNTB   : std_logic_vector(1 downto 0) := B"11";


  --
  -- T_SKIP conditional subfield
  --
  --
  -- define condition fields first
  --

  --
  -- reg-reg skips
  --
  constant CND_LO   : std_logic_vector(2 downto 0) := B"000";
  constant CND_LS   : std_logic_vector(2 downto 0) := B"001";
  constant CND_LT   : std_logic_vector(2 downto 0) := B"010";
  constant CND_LE   : std_logic_vector(2 downto 0) := B"011";
  constant CND_EQ   : std_logic_vector(2 downto 0) := B"100";

  -- reg skips
  constant CND_RA   : std_logic_vector(2 downto 0) := B"101";

  -- bit skips
  constant CND_B0   : std_logic_vector(2 downto 0) := B"110";
  constant CND_B1   : std_logic_vector(2 downto 0) := B"111";

  --
  -- RA skip codes
  --
  constant CRA_Z     : std_logic_vector(2 downto 0) := B"000";
  constant CRA_AWZ   : std_logic_vector(2 downto 0) := B"001";
  constant CRA_ABZ   : std_logic_vector(2 downto 0) := B"010";
  constant CRA_SPARE : std_logic_vector(2 downto 0) := B"011";
  constant CRA_MIZ   : std_logic_vector(2 downto 0) := B"100";
  constant CRA_AWM   : std_logic_vector(2 downto 0) := B"101";
  constant CRA_ABM   : std_logic_vector(2 downto 0) := B"110";
  constant CRA_FLAG  : std_logic_vector(2 downto 0) := B"111";



  --
  -- T_LD  load type subfield
  --
  --  0 xx  load unsigned
  --  1 xx  load signed 
  --
  --  x 00  ?? future expansion  ??
  --  x 01  long (32 bit)
  --  x 10  word (16 bit)
  --  x 11  byte (8 bit)
  --

  constant MEM_SIGNED   : std_logic := '1';
  constant MEM_UNSIGNED : std_logic := '0';

  --
  -- define two-bit size memory access field 
  --
  constant MEM_32_SP : std_logic_vector(1 downto 0) := B"00";  -- now used for stack/frame pointer relative addressing modes
  constant MEM_32    : std_logic_vector(1 downto 0) := B"01";
  constant MEM_16    : std_logic_vector(1 downto 0) := B"10";
  constant MEM_8     : std_logic_vector(1 downto 0) := B"11";

  --
  -- define full 3 bit memory access field
  --
  constant LD_U32    : std_logic_vector(2 downto 0) := MEM_UNSIGNED & MEM_32;
  constant LD_S32    : std_logic_vector(2 downto 0) := MEM_SIGNED   & MEM_32;  -- dummy definition on 32 bit machine

  constant LD_U16    : std_logic_vector(2 downto 0) := MEM_UNSIGNED & MEM_16;
  constant LD_S16    : std_logic_vector(2 downto 0) := MEM_SIGNED   & MEM_16;    -- dummy definition on 16 bit machine

  constant LD_U8     : std_logic_vector(2 downto 0) := MEM_UNSIGNED & MEM_8;
  constant LD_S8     : std_logic_vector(2 downto 0) := MEM_SIGNED   & MEM_8;


  --
  -- T_EXT subfields
  --
  --
  constant EXT_JUMP   : std_logic_vector(3 downto 0) := B"0000";
  constant EXT_RBRA   : std_logic_vector(3 downto 0) := B"0001";
  constant EXT_RETURN : std_logic_vector(3 downto 0) := B"0010";
  constant EXT_0011   : std_logic_vector(3 downto 0) := B"0011";

  constant EXT_0100   : std_logic_vector(3 downto 0) := B"0100";
  constant EXT_0101   : std_logic_vector(3 downto 0) := B"0101";
  constant EXT_0110   : std_logic_vector(3 downto 0) := B"0110";
  constant EXT_0111   : std_logic_vector(3 downto 0) := B"0111";

  constant EXT_1000   : std_logic_vector(3 downto 0) := B"1000";
  constant EXT_1001   : std_logic_vector(3 downto 0) := B"1001";
  constant EXT_1010   : std_logic_vector(3 downto 0) := B"1010";
  constant EXT_1011   : std_logic_vector(3 downto 0) := B"1011";

  constant EXT_1100   : std_logic_vector(3 downto 0) := B"1100";
  constant EXT_1101   : std_logic_vector(3 downto 0) := B"1101";
  constant EXT_1110   : std_logic_vector(3 downto 0) := B"1110";
  constant EXT_1111   : std_logic_vector(3 downto 0) := B"1111";


end package y1_constants;


