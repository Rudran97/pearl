----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity user_io is
	port (pil_clk            : in    std_logic;
	     pil_reset          : in    std_logic;
	     pil_en_set_dir     : in    std_logic;
	     pil_en_R_port      : in    std_logic;
	     pil_en_W_port      : in    std_logic;
	     pil_en_portin      : in    std_logic; -- read pin if enable is '1'.
	     pil_en_set_portpin : in    std_logic; -- save the PIN number that must be read.
	     pil_port           : in    std_logic_vector(15 downto 0);
	     pov_port           : out   std_logic_vector(15 downto 0);
	     pbv_PORT           : inout std_logic_vector(7 downto 0)
	     );
end user_io;


architecture rtl of user_io is

	signal sv_port_dir : std_logic_vector (7 downto 0) := (others => '0'); -- default to output i.e. '0'. Initial pin values are also '0'
	signal sv_storage : std_logic_vector (15 downto 0);
	signal sv_PIN_number : std_logic_vector (7 downto 0);

begin
	
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			sv_port_dir <= (others => '0');
			sv_storage <= (others => '0');
			sv_PIN_number <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_set_dir = '1') then
				sv_port_dir <= pil_port (7 downto 0);
			end if;
			
			if (pil_en_set_portpin = '1') then
				sv_PIN_number <= pil_port (7 downto 0);
			end if;
			
			if (pil_en_portin = '1') then
				pov_port <= (others => '0');
				if (sv_port_dir (0) = '1' and sv_PIN_number (0) = '1') then
					pov_port (0) <= pbv_PORT (0);
				end if;
				
				if (sv_port_dir (1) = '1' and sv_PIN_number (1) = '1') then
					pov_port (1) <= pbv_PORT (1);
				end if;
				
				if (sv_port_dir (2) = '1' and sv_PIN_number (2) = '1') then
					pov_port (2) <= pbv_PORT (2);
				end if;
				
				if (sv_port_dir (3) = '1' and sv_PIN_number (3) = '1') then
					pov_port (3) <= pbv_PORT (3);
				end if;
				
				if (sv_port_dir (4) = '1' and sv_PIN_number (4) = '1') then
					pov_port (4) <= pbv_PORT (4);
				end if;
				
				if (sv_port_dir (5) = '1' and sv_PIN_number (5) = '1') then
					pov_port (5) <= pbv_PORT (5);
				end if;
				
				if (sv_port_dir (6) = '1' and sv_PIN_number (6) = '1') then
					pov_port (6) <= pbv_PORT (6);
				end if;
				
				if (sv_port_dir (7) = '1' and sv_PIN_number (7) = '1') then
					pov_port (7) <= pbv_PORT (7);
				end if;
			elsif (pil_en_portin = '0') then
				if (pil_en_R_port = '1') then
					sv_storage <= pil_port;
				end if;
				
				if (pil_en_W_port = '1') then
					pov_port <= sv_storage;
				end if;
			end if;
		end if;
	end process;
	pbv_PORT (7) <= sv_storage (7) when sv_port_dir (7) = '0' else 'Z';
	pbv_PORT (6) <= sv_storage (6) when sv_port_dir (6) = '0' else 'Z';
	pbv_PORT (5) <= sv_storage (5) when sv_port_dir (5) = '0' else 'Z';
	pbv_PORT (4) <= sv_storage (4) when sv_port_dir (4) = '0' else 'Z';
	pbv_PORT (3) <= sv_storage (3) when sv_port_dir (3) = '0' else 'Z';
	pbv_PORT (2) <= sv_storage (2) when sv_port_dir (2) = '0' else 'Z';
	pbv_PORT (1) <= sv_storage (1) when sv_port_dir (1) = '0' else 'Z';
	pbv_PORT (0) <= sv_storage (0) when sv_port_dir (0) = '0' else 'Z';
end rtl;

