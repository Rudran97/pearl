----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MAR is
	port (pil_reset  : in  std_logic;
	      pil_clk    : in  std_logic;
	      pil_en_MAR : in  std_logic;
	      pil_sel    : in  std_logic;
	      piv_MAR    : in  std_logic_vector(15 downto 0);
	      poi_MAR    : out integer range 0 to 255
	     );
end MAR;


architecture rtl of MAR is

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			poi_MAR <= 0;
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_MAR = '1' or pil_sel = '1') then
				poi_MAR <= to_integer (unsigned (piv_MAR (7 downto 0)));
			end if;
		end if;
	end process;
end rtl;