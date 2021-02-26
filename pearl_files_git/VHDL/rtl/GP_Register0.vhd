----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GPR_type1 is
	port (pil_reset    : in  std_logic;
	     pil_clk      : in  std_logic;
	     pil_en_R_R0  : in  std_logic;  -- store data in the whole R0
	     pil_en_R_R0A : in  std_logic;  -- store data in the lower nibble R0A
	     pil_en_R_R0B : in  std_logic;  -- store data in the upper nibble R0B
	     pil_en_W_R0  : in  std_logic;  -- write whole R0 in the bus
	     pil_en_W_R0A : in  std_logic;  -- write data from the lower nibble R0A
	     pil_en_W_R0B : in  std_logic;  -- write data from the upper nibble R0B
	     piv_R0       : in  std_logic_vector(15 downto 0);
	     pov_R0       : out std_logic_vector(15 downto 0)
	     );			
end GPR_type1;


architecture rtl of GPR_type1 is
	
	signal sv_storage : std_logic_vector (15 downto 0);
	
begin
	
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			sv_storage <= (others => '0');
			pov_R0 <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_R_R0 = '1') then
				sv_storage <= piv_R0;
			end if;
			
			if (pil_en_R_R0A = '1') then
				sv_storage (3 downto 0) <= piv_R0 (3 downto 0);
			end if;
			
			if (pil_en_R_R0B = '1') then
				sv_storage (7 downto 4) <= piv_R0 (3 downto 0);
			end if;
			
			if (pil_en_W_R0A = '1') then
				pov_R0 <= "000000000000" & sv_storage (3 downto 0);
			elsif (pil_en_W_R0B = '1') then
				pov_R0 <= "000000000000" & sv_storage (7 downto 4);
			elsif (pil_en_W_R0 = '1') then
				pov_R0 <= sv_storage;
			elsif (pil_en_W_R0 = '0') then
				pov_R0 <= (others => '0');
			end if;
		end if;
	end process;
end rtl;