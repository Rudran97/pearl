----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BR is
	port (pil_reset   : in  std_logic;
	     pil_clk     : in  std_logic;
	     pil_en_R_BR : in  std_logic;
	     piv_BR      : in  std_logic_vector(15 downto 0);
	     pov_BR      : out std_logic_vector(7 downto 0)
	     );
end BR;


architecture rtl of BR is

	signal sv_storage : std_logic_vector (7 downto 0);

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			sv_storage <= (others => '0');
			--x8_BR_o <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_R_BR = '1') then
				sv_storage <= piv_BR (7 downto 0);
			end if;
		end if;
	end process;
	pov_BR <= sv_storage;
end rtl;

