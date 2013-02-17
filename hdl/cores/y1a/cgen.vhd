-- 
-- <cgen.vhd>
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
-- Y1A constant generation
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


entity cgen is

  port
    (   
      ireg      : in  std_logic_vector(INST_MSB downto 0);

      cg_out    : out std_logic_vector(ALU_MSB downto 0)
    );

end cgen;


architecture arch1 of cgen is

  signal cg_ext  : std_logic_vector(ALU_MSB downto 0);

  signal cg_pow2 : std_logic_vector(ALU_MSB downto 0);
  signal cg_mpow : std_logic_vector(ALU_MSB downto 0);

  --
  --
  --
  alias opb_ctl     : std_logic_vector(1 downto 0) is ireg(10 downto 9);
  alias opb_const   : std_logic_vector(4 downto 0) is ireg( 8 downto 4);

begin

  --
  -- sign extended 5 bit immediate constant
  --
  cg_ext <= ( ALU_MSB downto 5 => opb_const(4) ) & opb_const(4 downto 0);

  --
  -- power-of-two ROM
  --
  pw2_rom1: pw2_rom
   port map
     (
       ra => opb_const,
       rd => cg_pow2
     );

  --
  -- opb_ctl encoding
  --
  --  00     register operand
  --  01     sign extended 5 bit immediate N
  --  10     2^N immediate
  --  11     2^N - 1 immediate
  --

  --
  -- conditional offset of 2^N constant
  --
  with opb_ctl(0) select
  cg_mpow <= 
    cg_pow2           when '0',
    cg_pow2 - 1       when '1',
    (others => 'X')   when others;
 
  --
  -- mux 2^N derived constant/ sign extended constant
  --
  with opb_ctl(1) select
  cg_out <= 
    cg_ext           when '0',
    cg_mpow          when '1',
    (others => 'X')  when others;
   
end arch1;
