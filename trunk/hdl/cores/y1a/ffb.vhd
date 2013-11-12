--
-- <ffb.vhd>
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
-- Y1A find first bit
--
--  first pass at bit detect code, just finds first'1'
--   - need to add support for ff0/ffd
--   - current code synthesizes to a big heap of logic
--
--

library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.y1_constants.all;
  use work.y1a_config.all;


entity ffb is
  port
    (   
      din   : in  std_logic_vector (ALU_MSB downto 0);
      first : out std_logic_vector (5 downto 0)
    );
end ffb;

architecture arch1 of ffb is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is CFG_EDA_SYN_HIER;

  signal temp: std_logic_vector(5 downto 0);
  
  --attribute priority_extract:string;
  --attribute priority_extract of temp:signal is "Force";

begin

  --
  -- check for supported ALU widths
  --
  assert ( ALU_WIDTH = 16 ) OR ( ALU_WIDTH = 32 ) 
    report "Unsupported ALU width for ffb"
    severity error;


  --
  -- return bit number of most significant bit set
  --
  gen_ffb16: if ( ALU_WIDTH = 16 ) generate
    begin

      temp  <=
        "001111" when din(15) = '1' else
        "001110" when din(14) = '1' else
        "001101" when din(13) = '1' else
        "001100" when din(12) = '1' else
        "001011" when din(11) = '1' else
        "001010" when din(10) = '1' else
        "001001" when din( 9) = '1' else
        "001000" when din( 8) = '1' else
        "000111" when din( 7) = '1' else
        "000110" when din( 6) = '1' else
        "000101" when din( 5) = '1' else
        "000100" when din( 4) = '1' else
        "000011" when din( 3) = '1' else
        "000010" when din( 2) = '1' else
        "000001" when din( 1) = '1' else
        "000000" when din( 0) = '1' else
        "111111";
    
    end generate gen_ffb16;

  gen_ffb32: if ( ALU_WIDTH = 32 ) generate
    begin

      temp  <=
        "011111" when din(31) = '1' else
        "011110" when din(30) = '1' else
        "011101" when din(29) = '1' else
        "011100" when din(28) = '1' else
        "011011" when din(27) = '1' else
        "011010" when din(26) = '1' else
        "011001" when din(25) = '1' else
        "011000" when din(24) = '1' else
        "010111" when din(23) = '1' else
        "010110" when din(22) = '1' else
        "010101" when din(21) = '1' else
        "010100" when din(20) = '1' else
        "010011" when din(19) = '1' else
        "010010" when din(18) = '1' else
        "010001" when din(17) = '1' else
        "010000" when din(16) = '1' else
        "001111" when din(15) = '1' else
        "001110" when din(14) = '1' else
        "001101" when din(13) = '1' else
        "001100" when din(12) = '1' else
        "001011" when din(11) = '1' else
        "001010" when din(10) = '1' else
        "001001" when din( 9) = '1' else
        "001000" when din( 8) = '1' else
        "000111" when din( 7) = '1' else
        "000110" when din( 6) = '1' else
        "000101" when din( 5) = '1' else
        "000100" when din( 4) = '1' else
        "000011" when din( 3) = '1' else
        "000010" when din( 2) = '1' else
        "000001" when din( 1) = '1' else
        "000000" when din( 0) = '1' else
        "111111";
    
    end generate gen_ffb32;

  first <= temp;

end arch1;












