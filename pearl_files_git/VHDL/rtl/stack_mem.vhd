----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SM is
	port (pil_reset   : in  std_logic;
	     pil_clk     : in  std_logic;
	     pil_en_SM_R : in  std_logic;
	     pil_en_SM_W : in  std_logic;
	     piv_SM      : in  std_logic_vector(15 downto 0);
	     pov_SM      : out std_logic_vector(15 downto 0)
	     );
end SM;


architecture rtl of SM is

	type tv_stack_memory is array (0 to 63) of std_logic_vector (15 downto 0);
	signal sv_stack : tv_stack_memory;
	
	signal si_SP : integer range 0 to 63 := 0;	

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			si_SP <= 0;
			pov_SM <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_SM_R = '1') then
				sv_stack (si_SP) <= piv_SM;
				si_SP <= si_SP + 1;
			end if;
			
			if (pil_en_SM_W = '1') then
				pov_SM <= sv_stack (si_SP - 1);
				si_SP <= si_SP - 1;
			end if;
		end if;
	end process;
end rtl;