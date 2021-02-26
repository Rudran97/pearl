----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ISP is
	port(pil_clk           : in  std_logic;
	     pil_reset         : in  std_logic;
	     pil_sel           : in  std_logic;
	     pil_en_PI         : in  std_logic;
	     piv_data          : in  std_logic_vector(7 downto 0);
	     pol_en_write_data : out std_logic;
	     pov_MAR           : out std_logic_vector(15 downto 0);
	     pov_RAM           : out std_logic_vector(15 downto 0)
	    );
end ISP;

architecture rtl of ISP is

	type t_byte_mode is (byte_count_st,
	                     address_st,
	                     record_type_st,
	                     data_st
	                    );

	signal st_programmer_state : t_byte_mode := byte_count_st;
	signal sv_address          : std_logic_vector(7 downto 0);
	signal sv_bigendian_data   : std_logic_vector(7 downto 0);
	signal si_data_length      : integer range 0 to 16;
	signal sl_record_type      : std_logic;
	signal sl_nibble           : std_logic   := '0';

begin
	process(pil_reset, pil_clk)
		variable vi_datalength_counter_ct : integer range 1 to 17 := 1;
	begin
		if (pil_reset = '1') then
			st_programmer_state      <= byte_count_st;
			sv_address               <= (others => '0');
			vi_datalength_counter_ct := 1;
			si_data_length           <= 0;
			sl_record_type           <= '0';
			pov_MAR                 <= (others => '1');
			pov_RAM                 <= (others => '1');
			sl_nibble                <= '0';
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_sel = '1') then
				if (pil_en_PI = '1') then
					case st_programmer_state is
						when byte_count_st =>
							pol_en_write_data       <= '0';
							vi_datalength_counter_ct := 1;
							si_data_length           <= to_integer(unsigned(piv_data));
							st_programmer_state      <= address_st;
						when address_st =>
							sv_address          <= piv_data;
							st_programmer_state <= record_type_st;
						when record_type_st =>
							sl_record_type      <= piv_data(0);
							st_programmer_state <= data_st;
						when data_st =>
							if (sl_record_type = '0') then
								if (vi_datalength_counter_ct <= si_data_length) then
									vi_datalength_counter_ct := vi_datalength_counter_ct + 1;
									if (sl_nibble = '0') then
										sv_bigendian_data <= piv_data;
										sl_nibble         <= '1';
									else
										pov_MAR           <= "00000000" & sv_address;
										sv_address         <= std_logic_vector(unsigned(sv_address) + 1);
										pov_RAM           <= sv_bigendian_data & piv_data;
										pol_en_write_data <= '1';
										sl_nibble          <= '0';
									end if;
									st_programmer_state      <= data_st;
								end if;

								if (vi_datalength_counter_ct > si_data_length) then
									vi_datalength_counter_ct := 1;
									st_programmer_state      <= byte_count_st;
								end if;
							else
								st_programmer_state <= byte_count_st;
							end if;
						when others =>
							st_programmer_state <= byte_count_st;
					end case;
				else
					pol_en_write_data <= '0';
				end if;
			end if;
		end if;
	end process;
end rtl;
