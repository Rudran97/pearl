----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DM_e is
	port (rb_i   : in std_logic;
			clk_i  : in std_logic;
			en_R_DM_i : in std_logic;
			en_W_DM_i : in std_logic;
			x16_DM_i  : in std_logic_vector (15 downto 0);
			x16_DM_o  : out std_logic_vector (15 downto 0));
end DM_e;


architecture DM_a of DM_e is

	signal s_storage : std_logic_vector (x16_DM_i'range);

begin
	process (rb_i, clk_i)
	begin
		if (rb_i = '1') then
			s_storage <= (others => '0');
			x16_DM_o <= (others => '0');
		elsif (clk_i'event and clk_i = '1') then
			if (en_R_DM_i = '1') then
				s_storage <= x16_DM_i;
			end if;
			
			if (en_W_DM_i = '1') then
				x16_DM_o <= s_storage;
			elsif (en_W_DM_i = '0') then
				x16_DM_o <= (others => '0');
			end if;
		end if;
	end process;
end DM_a;

