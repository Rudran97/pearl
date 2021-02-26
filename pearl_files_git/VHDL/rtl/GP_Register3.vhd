----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GPR_type2 is
	port(pil_reset   : in  std_logic;
	     pil_clk     : in  std_logic;
	     pil_en_R_G2 : in  std_logic;
	     pil_en_W_G2 : in  std_logic;
	     piv_G2      : in  std_logic_vector(15 downto 0);
	     pov_G2      : out std_logic_vector(15 downto 0)
	     );
end GPR_type2;


architecture rtl of GPR_type2 is

	signal sv_storage : std_logic_vector (piv_G2'range);

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			sv_storage <= (others => '0');
			pov_G2 <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_R_G2 = '1') then
				sv_storage <= piv_G2;
			end if;
			
			if (pil_en_W_G2 = '1') then
				pov_G2 <= sv_storage;
			elsif (pil_en_W_G2 = '0') then
				pov_G2 <= (others => '0');
			end if;
		end if;
	end process;
end rtl;

