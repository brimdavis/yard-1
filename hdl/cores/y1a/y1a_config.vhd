--
-- <y1a_config.vhd>
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


  --
  --  reg_i_addr:
  --
  --    change this flag with care
  --      left over from conversion from unpipelined CLB RAM of the XC4000 family 
  --      to pipelined blockram of the Spartan-II
  --
  --    set to TRUE if instruction memory is async, or clocked on falling edge to hide latency
  --
  --    set to FALSE if instruction memory is registered with a one clock delay 
  --
  type y1a_hw_config_type is 
    record
      reg_i_addr       : boolean;
    end record;


  --
  -- composite configuration record:
  --
  type y1a_config_type is 
    record
      isa             : y1a_isa_config_type;
      hw              : y1a_hw_config_type;
    end record;
 
 
  constant DEFAULT_CONFIG : y1a_config_type :=
    (
      isa =>
        (
          non_native_load  => TRUE,
          non_native_store => TRUE,
    
          barrel_shift     => FALSE,
          bit_flip         => FALSE,
    
          skip_on_bit      => TRUE,
          skip_compare     => TRUE
        ),

      hw =>
        (
          reg_i_addr       => TRUE
        )

    );
 
 
  constant TINY_CONFIG : y1a_config_type :=
    (
      isa =>
        (
          non_native_load  => FALSE,
          non_native_store => FALSE,
  
          barrel_shift     => FALSE,
          bit_flip         => FALSE,
  
          skip_on_bit      => TRUE,
          skip_compare     => TRUE
        ),

      hw =>
        (
          reg_i_addr       => TRUE
        )
    );

 
  constant BIG_CONFIG : y1a_config_type :=
    (
      isa =>
        (
          non_native_load  => TRUE,
          non_native_store => TRUE,
     
     --   barrel_shift     => TRUE,  -- not implemented yet
          barrel_shift     => FALSE,
  
          bit_flip         => TRUE,
      
          skip_on_bit      => TRUE,
          skip_compare     => TRUE
        ),

      hw =>
        (
          reg_i_addr       => TRUE
        )
    );

 
end package y1a_config;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 