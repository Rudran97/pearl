----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity CG is
	port (pil_reset   : in  std_logic;
	     pil_clk     : in  std_logic;
	     pil_en_CG0  : in  std_logic;
	     pil_en_CG1  : in  std_logic;
	     pil_en_CGB2 : in  std_logic;
	     pil_en_CGB1 : in  std_logic;
	     pil_en_CGB0 : in  std_logic;
	     pov_CG      : out std_logic_vector(15 downto 0)
	     );
end CG;


architecture rtl of CG is

begin
	process (pil_reset, pil_clk)
		variable vv_bit_combinations : std_logic_vector (2 downto 0);
	begin
		if (pil_reset = '1') then
			pov_CG <= (others => '1');
		elsif (pil_clk'event and pil_clk = '1') then
			vv_bit_combinations := pil_en_CGB2 & pil_en_CGB1 & pil_en_CGB0;
			if (pil_en_CG0 = '1') then
				pov_CG <= (others => '0');
			elsif (pil_en_CG1 = '1') then
				pov_CG <= "0000000000000001";
			elsif ((pil_en_CGB2 or pil_en_CGB1 or pil_en_CGB0) = '1') then
				case vv_bit_combinations is
					when "001" =>
						pov_CG <= "0000000000000010";
					when "010" =>
						pov_CG <= "0000000000000100";
					when "011" =>
						pov_CG <= "0000000000001000";
					when "100" =>
						pov_CG <= "0000000000010000";
					when "101" =>
						pov_CG <= "0000000000100000";
					when "110" =>
						pov_CG <= "0000000001000000";
					when "111" =>
						pov_CG <= "0000000010000000";
					when others =>
						pov_CG <= (others => '1');
				end case;
			end if;
		end if;
	end process;
end rtl;

