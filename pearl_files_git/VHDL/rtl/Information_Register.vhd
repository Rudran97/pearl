----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IR is
	port (pil_reset   : in  std_logic;
	     pil_clk     : in  std_logic;
	     pil_en_R_IR : in  std_logic;
	     pil_en_W_IR : in  std_logic;
	     piv_IR      : in  std_logic_vector(15 downto 0);
	     pov_IR_Bus  : out std_logic_vector(15 downto 0);
	     pov_IR_CNU  : out std_logic_vector(7 downto 0)
	     );
end IR;


architecture rtl of IR is

	signal sv_storage : std_logic_vector (7 downto 0);

begin
	
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			pov_IR_CNU <= (others => '1');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_R_IR = '1') then
				pov_IR_CNU <= piv_IR (15 downto 8);
			end if;
		end if;
	end process;
	
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			sv_storage <= (others => '0');
			pov_IR_Bus <= (others => '1');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_R_IR = '1') then
				sv_storage <= piv_IR (7 downto 0);
			end if;
			
			if (pil_en_W_IR = '1') then
				pov_IR_Bus <= "00000000" & sv_storage;
			else
				pov_IR_Bus <= (others => '0');
			end if;
		end if;
	end process;
end rtl;