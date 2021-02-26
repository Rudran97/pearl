----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity function_controller is
	port (pil_clk   : in  std_logic;
	     pil_reset : in  std_logic;
	     pil_sel   : in  std_logic;
	     pol_run   : out std_logic
	    );
end function_controller;


architecture rtl of function_controller is

	constant ci_max_latency : integer := 100_000 - 1;
	
	signal si_run_latency : integer range 0 to ci_max_latency;

begin
	
	proc_run_sync : process (pil_clk, pil_reset) is
	begin
		if pil_reset = '1' then
			pol_run <= '0';
		elsif rising_edge(pil_clk) then
			if pil_sel = '0' then
				if si_run_latency < ci_max_latency - 1 then
					si_run_latency <= si_run_latency + 1;
				else
					si_run_latency <= 0;
					pol_run <= '1';
				end if;
			else
				si_run_latency <= 0;
				pol_run <= '0';
			end if;
		end if;
	end process proc_run_sync;
	
end rtl;

