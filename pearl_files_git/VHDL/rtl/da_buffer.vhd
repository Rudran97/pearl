----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DA_Buffer is
	port (pil_clk           : in  std_logic;
	      pil_reset         : in  std_logic;
	      pil_en_buffer     : in  std_logic;
	      piv_address_buff  : in  std_logic_vector(15 downto 0);
	      piv_data_buff     : in  std_logic_vector(15 downto 0);
	      pol_en_write_data : out std_logic;
	      pov_add_buff      : out std_logic_vector(15 downto 0);
	      pov_data_buff     : out std_logic_vector(15 downto 0)
	      );
end DA_Buffer;


architecture rtl of DA_Buffer is

	signal sl_write_switch_delay : std_logic;
	signal si_write_switch_delay_ct : integer range 0 to 2 := 0;
	
begin
	process (pil_reset, pil_clk)
		--variable s_write_switch_delay_ct : integer range 0 to 2;
	begin
		if (pil_reset = '1') then
			pol_en_write_data <= '0';
			si_write_switch_delay_ct <= 0;
			sl_write_switch_delay <= '0';
			pov_add_buff <= (others => '1');
			pov_data_buff <= (others => '1');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_buffer = '1') then
				pov_add_buff <= piv_address_buff;
				pov_data_buff <= piv_data_buff;
				sl_write_switch_delay <= '1';
			end if;
			
			if (sl_write_switch_delay = '1') then
				si_write_switch_delay_ct <= si_write_switch_delay_ct + 1;
				if (si_write_switch_delay_ct = 1) then
					pol_en_write_data <= '1';
				elsif (si_write_switch_delay_ct = 2) then
					pol_en_write_data <= '0';
					si_write_switch_delay_ct <= 0;
					sl_write_switch_delay <= '0';
				end if;
			end if;
		end if;
	end process;
end rtl;