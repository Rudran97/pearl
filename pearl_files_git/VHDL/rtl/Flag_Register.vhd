----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity general_flag is
	port (pil_reset      : in  std_logic;
	     pil_clk        : in  std_logic;
	     pil_en_Flag_CU : in  std_logic;
	     pil_en_TCOV    : in  std_logic;
	     pil_CF_ALU     : in  std_logic;
	     pil_ZF_ALU     : in  std_logic;
	     pil_TF0_T0     : in  std_logic;
	     pil_TOV        : in  std_logic;
	     pol_flag_CF    : out std_logic;
	     pol_flag_ZF    : out std_logic;
	     pol_flag_TF0   : out std_logic;
	     pol_TOV        : out std_logic
	     );
end general_flag;


architecture rtl of general_flag is

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			pol_flag_CF <= '0';
			pol_flag_ZF <= '0';
			pol_flag_TF0 <= '0';
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_Flag_CU = '1') then
				pol_flag_CF <= pil_CF_ALU;
				pol_flag_ZF <= pil_ZF_ALU;
				pol_flag_TF0 <= pil_TF0_T0;
			end if;
			
			if pil_en_TCOV = '1' then
				pol_TOV <= pil_TOV;
			end if;
		end if;
	end process;
end rtl;