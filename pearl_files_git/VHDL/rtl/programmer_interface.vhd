----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PI is
	generic(gc_bd     : integer := 9600;
	        gc_clk_fz : integer := 50_000_000);
	port (pil_clk         : in  std_logic;
	     pil_reset       : in  std_logic;
	     pil_rx          : in  std_logic;
	     pol_en_PI_ExtPg : out std_logic;
	     pov_char_out    : out std_logic_vector(7 downto 0)
	     );
end PI;


architecture rtl of PI is
	
	type t_UR_state is (UR_idle_st, UR_start_Bit_st, UR_x9Data_Bit_st, send_byte_st, UR_stop_Bit_st);

	signal st_pr_state  : t_UR_state                                 := UR_idle_st;
	signal si_clk_pulse : integer range 0 to (gc_clk_fz / gc_bd) - 1 := 0;
	signal si_bit_count : integer range 0 to 7                       := 0;
	signal sv_data      : std_logic_vector(7 downto 0)               := (others => '0');

	constant ci_bd_pulse : integer := gc_clk_fz / gc_bd;
	
begin
	
	process(pil_clk, pil_reset)
	begin
		if (pil_reset = '1') then
			pol_en_PI_ExtPg <= '0';
			pov_char_out    <= (others => '0');
			st_pr_state     <= UR_idle_st;
			sv_data         <= (others => '0');
			si_bit_count    <= 0;
			si_clk_pulse    <= 0;
		elsif (pil_clk'event and pil_clk = '1') then
			case st_pr_state is
				when UR_idle_st =>
					si_clk_pulse <= 0;
					if (pil_rx = '0') then
						st_pr_state <= UR_start_Bit_st;
					else
						st_pr_state <= UR_idle_st;
					end if;
				when UR_start_Bit_st =>
					if (si_clk_pulse = (ci_bd_pulse - 1) / 2) then
						if (pil_rx = '0') then
							si_clk_pulse <= 0;
							st_pr_state  <= UR_x9Data_Bit_st;
						else
							st_pr_state <= UR_idle_st;
						end if;
					else
						si_clk_pulse <= si_clk_pulse + 1;
						st_pr_state  <= UR_start_Bit_st;
					end if;
				when UR_x9Data_Bit_st =>
					pol_en_PI_ExtPg <= '0';
					if (si_clk_pulse < ci_bd_pulse - 1) then
						si_clk_pulse <= si_clk_pulse + 1;
						st_pr_state  <= UR_x9Data_Bit_st;
					else
						--en_PI_ExtPg_o <= '1';
						si_clk_pulse          <= 0;
						sv_data(si_bit_count) <= pil_rx;
						if (si_bit_count < 7) then
							si_bit_count <= si_bit_count + 1;
							st_pr_state  <= UR_x9Data_Bit_st;
						else
							si_bit_count <= 0;
							st_pr_state  <= send_byte_st;
						end if;
					end if;

				when send_byte_st =>
					pol_en_PI_ExtPg <= '1';
					pov_char_out    <= sv_data;
					st_pr_state     <= UR_stop_Bit_st;

				when UR_stop_Bit_st =>
					pol_en_PI_ExtPg <= '0';
					if (si_clk_pulse < ci_bd_pulse - 1) then
						si_clk_pulse <= si_clk_pulse + 1;
						st_pr_state  <= UR_stop_Bit_st;
					else
						si_clk_pulse <= 0;
						st_pr_state  <= UR_idle_st;
					end if;
				when others =>
					st_pr_state <= UR_idle_st;
			end case;
		end if;
	end process;
end rtl;