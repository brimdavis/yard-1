--
-- <y1a_probe.vhd>
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
-- Y1A simulation probe monitor
--
--   writes probed internal core signals to STD_OUTPUT
--   for simulation only
--


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use ieee.std_logic_textio.all;
  use std.textio.all;
  
library work;
  use work.y1a_config.all;
  use work.y1_constants.all;

  use work.y1a_probe_pkg.all;
  
  
  
entity y1a_probe is
  port
    (   
      clk     : in std_logic;

      rst_l   : in std_logic
    );

end y1a_probe;


architecture sim1 of y1a_probe is

  -- maintain a local copy of register file 
  type rf_type is array (natural range <>) of std_logic_vector (RF_DAT_MSB downto 0);

  signal reg_file : rf_type (RF_DEPTH-1 downto 0) := (others => (others => '0') );


  begin

    --
    -- ea debug
    --
    ea_mon: process(clk)
      variable L : line;

      begin

          if rising_edge(clk) then
            write(L, ' ' );
            writeline(OUTPUT,L);
  
            write(L, now );
            write( L, string'(": EA"));
  
            write( L, string'("   ea_off_mux="));
            hwrite(L,  y1a_probe_sigs.ea_off_mux );

--x            write( L, string'("  ea_reg_mux   ="));
--x            hwrite(L,  y1a_probe_sigs.ea_reg_mux );

            write( L, string'("  ea_dat   ="));
            hwrite(L,  y1a_probe_sigs.ea_dat );

            writeline( OUTPUT, L);


          end if;

      end process ea_mon;


    --
    -- alu
    --
    alu_mon: process(clk)
      variable L : line;
  
      begin
  
        if rising_edge(clk) then
            write(L, ' ' );

            writeline(OUTPUT,L);
  
            write(L, now );
            write( L, string'(": ALU"));

            writeline( OUTPUT, L);
  
            write( L, string'("        ain ="));
            hwrite(L,  y1a_probe_sigs.ain );

            write( L, string'("  bin ="));
            hwrite(L,  y1a_probe_sigs.bin );

            write( L, string'("  wb_bus ="));
            hwrite(L,  y1a_probe_sigs.wb_bus );

            write( L, string'("  sr ="));
            hwrite(L,  y1a_probe_sigs.st_reg );

            writeline( OUTPUT, L);

            write( L, string'("        cg_out ="));
            hwrite(L,  y1a_probe_sigs.cg_out );

            writeline( OUTPUT, L);

            write( L, string'("        imm ="));
            hwrite(L,  y1a_probe_sigs.imm_reg );

            writeline( OUTPUT, L);

            write( L, string'("        skip_cond: a,bit,n,c,v,z,b = "));
            write(L,  y1a_probe_sigs.skipc );
--            write(L,  slv_5b'(skip_cond_a & c_bit & cb_n & cb_c & cb_v & cb_z )  );

            writeline( OUTPUT, L);

--x            write( L, string'("        fp ="));
--x            hwrite(L,  y1a_probe_sigs.fp_reg );
--x
--x            write( L, string'("  sp ="));
--x            hwrite(L,  y1a_probe_sigs.sp_reg );

            writeline( OUTPUT, L);

        end if;

      end process alu_mon;


    ex_mon: process(clk)
      variable L : line;
  
      begin

        if rising_edge(clk) then
  
          write(L, ' ' );
          writeline(OUTPUT,L);
  
          write(L, now );
          write( L, string'(": EX   pc_reg_p1="));
          hwrite(L,  y1a_probe_sigs.pc_reg_p1 );
          write( L, string'(" ireg="));
          hwrite(L,  y1a_probe_sigs.ireg );
          write( L, string'("  ex_null="));
          write(L,  y1a_probe_sigs.ex_null );
          writeline( OUTPUT, L);
  
        end if;
  
  
      end process ex_mon;



    --
    -- register file
    --
    wb_mon: process(clk)
      variable L : line;

      begin

        if rising_edge(clk) then
          if y1a_probe_sigs.wb_en = '1' then

            -- snoop writeback bus to maintain a copy of internal register file
            reg_file(to_integer(unsigned(y1a_probe_sigs.wb_ra))) <= y1a_probe_sigs.wb_bus;

            write(L, ' ' );
            writeline(OUTPUT,L);

            write(L, now );
            write( L, ':');

            write( L, string'(" RF Writeback R" ) );
            write(L,  to_integer(unsigned(y1a_probe_sigs.wb_ra)) );

            write( L, '=');

            hwrite(L,  y1a_probe_sigs.wb_bus );
            writeline( OUTPUT, L);

          end if;

        end if;

      end process wb_mon;


    reg_mon: process(clk)
      variable L : line;
      variable i,j : natural;
 
      begin

        -- wait till falling edge then dump register file
        if falling_edge(clk) then
 
         write(L, ' ' );
         writeline(OUTPUT,L);
 
         write(L, now );
         write( L, string'(": Register File"));
 
         writeline( OUTPUT, L);

         --
         -- first line displays r0..r7
         --
         for j in 0 to 7 loop
           hwrite(L,  reg_file(j) );
           write( L, ' ');
         end loop;

         writeline( OUTPUT, L);

         --
         -- second line displays r8..r15
         --   loop stops at r14, r15 handled below
         --
         for j in 8 to 14 loop
           hwrite(L,  reg_file(j) );
           write( L, ' ');
         end loop;
 
--x         hwrite(L,  y1a_probe_sigs.imm_reg );
--x         write( L, ' ');

         --
         -- R15/PC/RS doesn't live in normal register file
         --   print top of return stack for R15 value
         --
         hwrite(L,  y1a_probe_sigs.rsp_pc );
         write( L, ' ');

         writeline( OUTPUT, L);

         writeline( OUTPUT, L);

         write( L, string'("------------------------------------------------------------------------"));
         writeline( OUTPUT, L);
 
        end if;
 
      end process reg_mon;

 

  end sim1;

