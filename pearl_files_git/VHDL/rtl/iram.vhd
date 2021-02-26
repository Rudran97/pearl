----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAM is
	port (pil_reset        : in  std_logic;
	      pil_clk          : in  std_logic;
	      pil_sel          : in  std_logic;
	      pil_manual_write : in  std_logic;
	      pil_en_R_RAM     : in  std_logic;
	      pil_en_W_RAM     : in  std_logic;
	      pii_RAM_address  : in  integer range 0 to 255; --- address input
	      piv_RAM          : in  std_logic_vector(15 downto 0);
	      pov_RAM          : out std_logic_vector(15 downto 0)
	      );
end RAM;


architecture rtl of RAM is

	type tv_ram_memory is array (0 to 255) of std_logic_vector (15 downto 0);
	signal sv_ram : tv_ram_memory;

begin
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			pov_RAM <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_sel = '1') then
				if (pil_manual_write = '1') then
					sv_ram (pii_RAM_address) <= piv_RAM;
				end if;
				pov_RAM <= sv_ram (pii_RAM_address);
			elsif (pil_sel = '0') then
				if (pil_en_R_RAM = '1') then
					sv_ram (pii_RAM_address) <= piv_RAM;
				end if;
				
				if (pil_en_W_RAM = '1') then
					pov_RAM <= sv_ram (pii_RAM_address);
				elsif (pil_en_W_RAM = '0') then
					pov_RAM <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end rtl;