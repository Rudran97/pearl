----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.accumulator_p.all;

entity AR is
	port (pil_reset      : in  std_logic;
	     pil_clk        : in  std_logic;
	     pil_en_R_AR    : in  std_logic;
	     pil_en_W_AR    : in  std_logic;
	     pil_en_Rotate  : in  std_logic; -- enable rotate functionality
	     pil_AR_OP0     : in  std_logic; -- rotation selection bit 0
	     pil_AR_OP1     : in  std_logic; -- rotation selection bit 1
	     pil_en_R_carry : in  std_logic;
	     pil_en_W_carry : in  std_logic;
	     piv_AR         : in  std_logic_vector(15 downto 0);
	     pov_AR_ALU     : out std_logic_vector(7 downto 0);
	     pov_AR         : out std_logic_vector(15 downto 0));
end AR;


architecture rtl of AR is
	
	signal sv_storage : std_logic_vector (15 downto 0);
	signal sl_store_cbit : std_logic := '0';
	
begin
	
	process (pil_reset, pil_clk)
		variable vv_OP_mode : std_logic_vector (1 downto 0);
		variable vi_rotate_by : integer range 0 to 7;
	begin
		if (pil_reset = '1') then
			sv_storage <= (others => '1');
			pov_AR_ALU <= (others => '0');
			pov_AR <= (others => '0');
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_R_AR = '1') then
				sv_storage <= piv_AR;
				pov_AR_ALU <= piv_AR (7 downto 0);
			end if;
			
			if (pil_en_W_AR = '1') then
				pov_AR <= sv_storage;
			elsif (pil_en_W_AR = '0') then
				pov_AR <= (others => '0');
			end if;
			
			if (pil_en_R_carry = '1') then
				sl_store_cbit <= piv_AR (0);
			end if;
			
			if (pil_en_W_carry = '1') then
				pov_AR <= "000000000000000" & sl_store_cbit;
			end if;
			
			if (pil_en_Rotate = '1') then
				vv_OP_mode := pil_AR_OP1 & pil_AR_OP0;
				
				case sv_storage (7 downto 0) is
					when "00000001" =>
						vi_rotate_by := 0;
					when "00000010" =>
						vi_rotate_by := 1;
					when "00000100" =>
						vi_rotate_by := 2;
					when "00001000" =>
						vi_rotate_by := 3;
					when "00010000" =>
						vi_rotate_by := 4;
					when "00100000" =>
						vi_rotate_by := 5;
					when "01000000" =>
						vi_rotate_by := 6;
					when "10000000" =>
						vi_rotate_by := 7;
					when others =>
						vi_rotate_by := 1;
				end case;
				
				case vv_OP_mode is
					when "00" =>  --  'RL'
						sv_storage <= "00000000" & fv_rotate_Accumulator (sv_storage (7 downto 0), 1, sl_store_cbit, '0');
						pov_AR_ALU <= fv_rotate_Accumulator (sv_storage (7 downto 0), 1, sl_store_cbit, '0');
						sl_store_cbit <= sv_storage (7);
					when "01" => -- 'RR'
						sv_storage <= "00000000" & fv_rotate_Accumulator (sv_storage (7 downto 0), 1, sl_store_cbit, '1');
						pov_AR_ALU <= fv_rotate_Accumulator (sv_storage (7 downto 0), 1, sl_store_cbit, '1');
						sl_store_cbit <= sv_storage (0);
					when "10" => -- to shift only the carry bit by v_rotate_by and masking the rest with zeros (RL)
						sv_storage <= "00000000" & fv_rotate_Accumulator ("0000000" & sl_store_cbit, vi_rotate_by, '0', '0');
						pov_AR_ALU <= fv_rotate_Accumulator ("0000000" & sl_store_cbit, vi_rotate_by, '0', '0');
					when "11" => -- to shift only the carry bit by v_rotate_by and masking the rest with zeros (RR)
						sv_storage <= "00000000" & fv_rotate_Accumulator (sv_storage (7 downto 0), vi_rotate_by, '0', '1');
						pov_AR_ALU <= fv_rotate_Accumulator (sv_storage (7 downto 0), vi_rotate_by, '0', '1');
					when others =>
						sv_storage <= "00000000" & fv_rotate_Accumulator (sv_storage (7 downto 0), vi_rotate_by, '0', '1');
						pov_AR_ALU <= fv_rotate_Accumulator (sv_storage (7 downto 0), vi_rotate_by, '0', '1');
				end case;
			end if;
		end if;
	end process;
end rtl;