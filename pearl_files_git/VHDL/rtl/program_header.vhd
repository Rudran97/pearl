----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
	port (pil_reset : in  std_logic;
	     pil_clk   : in  std_logic;
	     pil_en_CO : in  std_logic;     --- counter output enable
	     pil_en_CE : in  std_logic;     --- counter count enable
	     pil_en_CI : in  std_logic;     --- counter input enable
	     piv_bus   : in  std_logic_vector(15 downto 0);
	     pov_bus   : out std_logic_vector(15 downto 0)
	     );
end PC;


architecture rtl of PC is

begin
	
	process (pil_reset, pil_clk)	
		variable vi_Program_Counter : integer range 0 to 255 := 0;
	begin
		if (pil_reset = '1') then
			pov_bus <= (others => '1');
			vi_Program_Counter := 0;
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_CI = '1') then
				vi_Program_Counter := to_integer (unsigned (piv_bus (7 downto 0)));
			end if;
			
			if (pil_en_CE = '1') then
				vi_Program_Counter := vi_Program_Counter + 1;
			end if;
			
			if (pil_en_CO = '1') then
				pov_bus <= "00000000" & std_logic_vector (to_unsigned (vi_Program_Counter, pov_bus'length / 2));
			else
				pov_bus <= (others => '0');
			end if;
		end if;
	end process;
end rtl;

