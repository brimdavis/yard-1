--
-- <y1a_config.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2001-2014  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A processor configuration record
--
--   - defines configuration record types
--
--   - creates default configurations
--
--
-- TODO: 
--
--   - add a function in package body to convert configuration record 
--     to slv for initialization of processor configuration register 
--

package y1a_config is

  --
  -- EDA tool config
  --
  -- using global string constant because record element didn't meet "locally static" requirement for architecture attributes
  --
  -- FIXME: fixed length of four syn_hier string hack works for "soft", "firm", "hard"
  --        write string pad/chomp functions instead
  --
  constant CFG_EDA_SYN_HIER : string(1 to 4) := "hard";


  --
  -- ISA Configuration flags:
  --
  --   non_native_load : 
  --   non_native_store:  
  --     TRUE  : memory operands smaller than ALU_WIDTH supported
  --     FALSE : only memory operands of native register width supported
  --
  --
  --   TODO: BARREL SHIFTER NOT IMPLEMENTED YET!
  --
  --   barrel_shift: 
  --     TRUE  : shift and rotate support all bit shift lengths  
  --     FALSE : shift and rotate only support bit shift lengths of 1
  --
  --
  --   bit_flip: enable FLIP instruction
  --
  --
  --   skip_on_bit: 
  --     TRUE  : bit test skip conditions enabled for selected bit N
  --     FALSE : bit test conditions hardwired to register MSB ( sign bit )
  --
  --
  --   skip_compare: enable signed/unsigned reg <=> reg skip conditions
  --
  type y1a_isa_config_type is 
    record
      non_native_load  : boolean;
      non_native_store : boolean;
 
      barrel_shift     : boolean;
      bit_flip         : boolean;
 
      skip_on_bit      : boolean;
      skip_compare     : boolean;
    end record;


  constant DEFAULT_ISA_CONFIG : y1a_isa_config_type :=
    (
      non_native_load  => TRUE,
      non_native_store => TRUE,
    
      barrel_shift     => FALSE,
      bit_flip         => FALSE,
    
      skip_on_bit      => TRUE,
      skip_compare     => TRUE
    );
 
  constant TINY_ISA_CONFIG : y1a_isa_config_type :=
    (
      non_native_load  => FALSE,
      non_native_store => FALSE,
  
      barrel_shift     => FALSE,
      bit_flip         => FALSE,
  
      skip_on_bit      => TRUE,
      skip_compare     => FALSE
    );

  constant SMALL_ISA_CONFIG : y1a_isa_config_type :=
    (
      non_native_load  => FALSE,
      non_native_store => FALSE,
  
      barrel_shift     => FALSE,
      bit_flip         => FALSE,
  
      skip_on_bit      => TRUE,
      skip_compare     => TRUE
    );

  constant BIG_ISA_CONFIG : y1a_isa_config_type :=
    (
      non_native_load  => TRUE,
      non_native_store => TRUE,
    
    --barrel_shift     => TRUE,  -- not implemented yet
      barrel_shift     => FALSE,
  
      bit_flip         => TRUE,
     
      skip_on_bit      => TRUE,
      skip_compare     => TRUE
    );


  --
  -- HW config
  --
  --
  type y1a_hw_config_type is 
    record
      rstack_depth  : integer;    -- return stack depth
      irq_support   : boolean;    -- include interrupt hardware in core
    end record;

  constant DEFAULT_HW_CONFIG : y1a_hw_config_type :=
    (
      rstack_depth => 16,
      irq_support  => FALSE   -- FIXME: temporarily set default as FALSE until interrupts are working
    );


  --
  -- composite configuration record
  --
  type y1a_config_type is 
    record
      isa             : y1a_isa_config_type;
      hw              : y1a_hw_config_type;
    end record;
 

  constant DEFAULT_Y1A_CONFIG : y1a_config_type :=
    (
      isa => DEFAULT_ISA_CONFIG,
      hw  => DEFAULT_HW_CONFIG
    );

  constant TINY_Y1A_CONFIG : y1a_config_type :=
    (
      isa => TINY_ISA_CONFIG,
      hw  => DEFAULT_HW_CONFIG
    );

  constant SMALL_Y1A_CONFIG : y1a_config_type :=
    (
      isa => SMALL_ISA_CONFIG,
      hw  => DEFAULT_HW_CONFIG
    );

  constant BIG_Y1A_CONFIG : y1a_config_type :=
    (
      isa => BIG_ISA_CONFIG,
      hw  => DEFAULT_HW_CONFIG
    );


end package y1a_config;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 