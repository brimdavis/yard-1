--
-- <flip.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2003-2013  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A flip instruction
--
--  universal bit swap 
--     see "Hackers Delight", 2003, Hank Warren, page 102;
--     FLIP instruction credited to Guy Steele
--
--
--  bsel =  bit swap control field
--
--     bsel(4) : swap even/odd wydes
--     bsel(3) : swap even/odd bytes
--     bsel(2) : swap even/odd nybbles
--     bsel(1) : swap even/odd bit pairs
--     bsel(0) : swap even/odd bits
--
--  e.g.
--     11000 : byte reverse register ( swap wydes & bytes )
--     11111 : bit reverse register  ( swap everything )
--     00111 : bit reverse all bytes in register
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;


entity flip is

  port
    (   
      bsel  : in  std_logic_vector (4 downto 0);

      din   : in  std_logic_vector (ALU_MSB downto 0);
      dout  : out std_logic_vector (ALU_MSB downto 0)
    );

end flip;


architecture arch1 of flip is

  attribute syn_hier : string;
  attribute syn_hier of arch1: architecture is "hard";



begin

  --
  -- check for supported ALU widths
  --
  assert ( ALU_WIDTH = 16 ) OR ( ALU_WIDTH = 32 ) 
    report "Unsupported ALU width for flip"
    severity error;

  --
  -- uses shifts & masks like SW version instead of coding explicit bit exchanges
  --   XST builds 4 or 5 stage bit swapper from this code
  --
  gen_flip16: if ( ALU_WIDTH = 16 ) generate                                              
    begin

      process(din,bsel)

        variable temp  : unsigned (ALU_MSB downto 0);
        variable temp1 : unsigned (ALU_MSB downto 0);
        variable temp2 : unsigned (ALU_MSB downto 0);
        variable temp3 : unsigned (ALU_MSB downto 0);
        variable temp4 : unsigned (ALU_MSB downto 0);

        begin

          temp  := unsigned(din);
   
          if ( bsel(0) = '1') then temp1 := ( (temp  AND X"5555") sll  1) OR ( (temp  AND X"AAAA") srl  1); else temp1 := temp;  end if;
          if ( bsel(1) = '1') then temp2 := ( (temp1 AND X"3333") sll  2) OR ( (temp1 AND X"CCCC") srl  2); else temp2 := temp1; end if;
          if ( bsel(2) = '1') then temp3 := ( (temp2 AND X"0F0F") sll  4) OR ( (temp2 AND X"F0F0") srl  4); else temp3 := temp2; end if;
          if ( bsel(3) = '1') then temp4 := ( (temp3 AND X"00FF") sll  8) OR ( (temp3 AND X"FF00") srl  8); else temp4 := temp3; end if;

          dout <= std_logic_vector(temp4);

        end process;

    end generate gen_flip16;



  gen_flip32: if ( ALU_WIDTH = 32 ) generate
    begin

      process(din,bsel)

        variable temp  : unsigned (ALU_MSB downto 0);
        variable temp1 : unsigned (ALU_MSB downto 0);
        variable temp2 : unsigned (ALU_MSB downto 0);
        variable temp3 : unsigned (ALU_MSB downto 0);
        variable temp4 : unsigned (ALU_MSB downto 0);
        variable temp5 : unsigned (ALU_MSB downto 0);

        begin

          temp  := unsigned(din);
   
          if ( bsel(0) = '1') then temp1 := ( (temp  AND X"5555_5555") sll  1) OR ( (temp  AND X"AAAA_AAAA") srl  1); else temp1 := temp; end if;
          if ( bsel(1) = '1') then temp2 := ( (temp1 AND X"3333_3333") sll  2) OR ( (temp1 AND X"CCCC_CCCC") srl  2); else temp2 := temp1; end if;
          if ( bsel(2) = '1') then temp3 := ( (temp2 AND X"0F0F_0F0F") sll  4) OR ( (temp2 AND X"F0F0_F0F0") srl  4); else temp3 := temp2; end if;
          if ( bsel(3) = '1') then temp4 := ( (temp3 AND X"00FF_00FF") sll  8) OR ( (temp3 AND X"FF00_FF00") srl  8); else temp4 := temp3; end if;
          if ( bsel(4) = '1') then temp5 := (  temp4                   sll 16) OR (  temp4                   srl 16); else temp5 := temp4; end if;

          dout <= std_logic_vector(temp5);

        end process;

    end generate gen_flip32;

end arch1;


