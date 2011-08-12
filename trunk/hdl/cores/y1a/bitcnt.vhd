--
-- <bitcnt.vhd>
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
-- Y1A bit counting
--
--   release 0.0.2
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1_constants.all;


entity bitcnt is

  port
    (   
      din  : in  std_logic_vector (ALU_MSB downto 0);
      cnt  : out std_logic_vector (5 downto 0)
    );

end bitcnt;


architecture arch1 of bitcnt is

  begin

    --
    -- check for supported ALU widths
    --
    assert ( ALU_WIDTH = 16 ) OR ( ALU_WIDTH = 32 ) 
        report "Unsupported ALU width for bitcnt"
        severity error;

    --
    -- adder tree, done using carry chains & masks
    --

    gen_bcnt16: if ( ALU_WIDTH = 16 ) generate
        begin

        process(din)
  
            variable temp  : unsigned (ALU_MSB downto 0);
            variable temp1 : unsigned (ALU_MSB downto 0);
            variable temp2 : unsigned (ALU_MSB downto 0);
            variable temp3 : unsigned (ALU_MSB downto 0);
            variable temp4 : unsigned (ALU_MSB downto 0);
 
            begin

            temp  := unsigned(din);
  
            temp1 := (temp  AND X"5555") + ( ( temp  srl 1)  AND X"5555");  -- 0..2 out  x8

            temp2 := (temp1 AND X"3333") + ( ( temp1 srl 2)  AND X"3333");  -- 0..4 out  x4

            temp3 := (temp2 AND X"0707") + ( ( temp2 srl 4)  AND X"0707");  -- 0..8 out  x2

            temp4 := (temp3 AND X"001f") + ( ( temp3 srl 8)  AND X"001f");  -- 0..16 out

            cnt <= std_logic_vector(temp4(5 downto 0));
 
            end process;
  
        end generate gen_bcnt16;


    gen_bcnt32: if ( ALU_WIDTH = 32 ) generate
    begin

        process(din)

        variable temp  : unsigned (ALU_MSB downto 0);
        variable temp1 : unsigned (ALU_MSB downto 0);
        variable temp2 : unsigned (ALU_MSB downto 0);
        variable temp3 : unsigned (ALU_MSB downto 0);
        variable temp4 : unsigned (ALU_MSB downto 0);
        variable temp5 : unsigned (ALU_MSB downto 0);

        begin
            temp  := unsigned(din);
  
            temp1 := (temp  AND X"5555_5555") + ( ( temp  srl 1)  AND X"5555_5555");  -- 0..2 out  x16

            temp2 := (temp1 AND X"3333_3333") + ( ( temp1 srl 2)  AND X"3333_3333");  -- 0..4 out  x8

            temp3 := (temp2 AND X"0707_0707") + ( ( temp2 srl 4)  AND X"0707_0707");  -- 0..8 out  x4

            temp4 := (temp3 AND X"001f_001f") + ( ( temp3 srl 8)  AND X"001f_001f");  -- 0..16 out x2

            temp5 := (temp4 AND X"0000_003f") + ( ( temp4 srl 16) AND X"0000_003f");  -- 0..32 out

            cnt <= std_logic_vector(temp5(5 downto 0));

        end process;

    end generate gen_bcnt32;

  end arch1;
