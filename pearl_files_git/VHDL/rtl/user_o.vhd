----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity user_o is
	port (pil_reset : in  std_logic;
	     pil_clk   : in  std_logic;
	     pil_sel   : in  std_logic;
	     pil_en_OR : in  std_logic;
	     piv_OR    : in  std_logic_vector(15 downto 0);
	     pov_OR    : out std_logic_vector(7 downto 0)
	     );
end user_o;


architecture rtl of user_o is

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			pov_OR <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_OR = '1' or pil_sel = '1') then
				pov_OR <= piv_OR (7 downto 0);
			end if;
		end if;
	end process;
end rtl;