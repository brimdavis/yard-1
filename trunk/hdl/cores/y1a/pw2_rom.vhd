--
-- <pw2_rom.vhd>
--

---------------------------------------------------------------
--
-- (C) COPYRIGHT 2000-2011  Brian Davis
--
-- Code released under the terms of the BSD 2-clause license
-- see license/bsd_2-clause.txt
--
---------------------------------------------------------------

--
-- Y1A powers of 2 lookup table
--
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.y1a_config.all;
  use work.y1_constants.all;


entity pw2_rom is
port
  (   
    ra  : in std_logic_vector  (4 downto 0);
    rd  : out std_logic_vector (ALU_MSB downto 0)
  );
end pw2_rom;

architecture arch1 of pw2_rom is

  type rom_type is array (natural range <>) of std_logic_vector (31 downto 0);

  constant rom1 : rom_type (0 to 31) :=
    (
      X"0000_0001", X"0000_0002", X"0000_0004", X"0000_0008",
      X"0000_0010", X"0000_0020", X"0000_0040", X"0000_0080",
      X"0000_0100", X"0000_0200", X"0000_0400", X"0000_0800",
      X"0000_1000", X"0000_2000", X"0000_4000", X"0000_8000",
      X"0001_0000", X"0002_0000", X"0004_0000", X"0008_0000",
      X"0010_0000", X"0020_0000", X"0040_0000", X"0080_0000",
      X"0100_0000", X"0200_0000", X"0400_0000", X"0800_0000",
      X"1000_0000", X"2000_0000", X"4000_0000", X"8000_0000"
    );

begin

  rd <= rom1(to_integer(unsigned(ra)))(ALU_MSB downto 0);

end arch1;
