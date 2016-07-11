-- 
-- <barrel.vhd>
-- 

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2016  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A full barrel shifter 
--
--   -  LSR/ASR/LSL/ROR/ROL, 0 to 31 positions
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity barrel is

  port
    (   
      shift_grp    : in  std_logic;           -- 0: shift      1: rotate
      shift_signed : in  std_logic;           -- 0: unsigned   1: signed
      shift_dir    : in  std_logic;           -- 0: right      1: left   
      shift_const  : in  std_logic_vector;

      ain          : in  std_logic_vector;

      shift_dat    : out std_logic_vector
    );

end barrel;


architecture arch1 of barrel is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  --
  -- number of shifter stages needed to cover the input vector length
  --
  constant STAGES : natural := natural(ceil(log2(real(ain'length))));

  --
  -- note there are STAGES+1 entries in array type
  -- stage(0) is used for initial assigment
  --
  type t_shift_array is array(0 to STAGES) of std_logic_vector(ain'range);
  signal shifts   : t_shift_array;

  signal fill_bit : std_logic;

  --
  -- function for wraparound bit indexing modulo vector size
  --
  function wrap_index(sum : integer; modulus : natural) return natural is 
  begin

     if sum >= modulus then 
       return sum - modulus;

     elsif sum < 0  then 
       return sum + modulus; 

     else
       return sum;

     end if;

  end function;


begin

  --
  -- initialize index zero to the data input
  --
  shifts(0) <= ain;

  --
  -- fill bit for SR is either sign bit (ASR) or zero (LSR)
  --
  fill_bit <=  ain(ain'left) AND shift_signed;


  --
  -- stage generate loop
  --   shifts by 1, 2, 4, ... , 2^N bits in each succesive shift/rotate stage
  --   note that the loop index starts at 1
  --
  G_STAGES: for i in 1 to STAGES generate

      signal stride: natural;

    begin

      --
      -- stride: how far to shift in this stage
      --
      stride <= 2**(i-1); 

      --
      -- bit generate loop constructs mux logic for each bit of a shift stage
      --
      G_BITS: for b in ain'range generate
        begin

          process(shifts, stride, shift_grp, shift_signed, shift_dir, shift_const)
            begin
  
              if shift_const(i-1) = '0' then
                --
                -- no shift needed for this stage
                --
                shifts(i)(b) <= shifts(i-1)(b);
    
              elsif (shift_grp = '0') AND (shift_dir = '1') then
                --
                -- LSL
                --
                if b >= stride then
                  shifts(i)(b) <= shifts(i-1)(b-stride);
    
                else
                  shifts(i)(b) <= '0';
    
                end if;
    
              elsif (shift_grp = '0') AND (shift_dir = '0') then
                --
                -- LSR/ASR        
                --
                if b <= ain'left-stride then
                  shifts(i)(b) <= shifts(i-1)(b+stride);
    
                else
                  --
                  -- MS fill bit is either sign bit (ASR) or zero (LSR)
                  --
                  shifts(i)(b) <= fill_bit;
    
                end if;
     
              elsif (shift_grp = '1') AND (shift_dir = '1') then
                --
                -- ROL
                --
                shifts(i)(b) <= shifts(i-1)(wrap_index(b-stride,ain'length));
    
              elsif (shift_grp = '1') AND (shift_dir = '0') then
                --
                -- ROR
                --
                shifts(i)(b) <= shifts(i-1)(wrap_index(b+stride,ain'length));
    
              end if;

          end process;

        end generate;

  end generate;


  shift_dat <= shifts(STAGES);


end arch1;

