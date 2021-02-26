----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
	port(pil_clk          : in  std_logic;
	     pil_reset        : in  std_logic;
	     pil_en_TH        : in  std_logic;
	     pil_en_TL        : in  std_logic;
	     pil_CS           : in  std_logic;
	     pil_en_T         : in  std_logic;
	     pil_en_TR        : in  std_logic;
	     pil_en_TCR       : in  std_logic;
	     pil_TC_L         : in  std_logic;
	     pil_TC_H         : in  std_logic;
	     pil_load_counter : in  std_logic;
	     pov_T_BUS_input  : in  std_logic_vector(7 downto 0);
	     pov_Timer_out    : out std_logic_vector(15 downto 0);
	     pol_TF_Flag      : out std_logic;
	     pol_TOV_Flag     : out std_logic
		 );
end timer;


architecture rtl of timer is

	constant ci_timer_max : integer := 65535;
	constant ci_prescale_max : integer := 8192;
	
	signal sv_TH_storage : std_logic_vector (7 downto 0);
	signal sv_TL_storage : std_logic_vector (7 downto 0);
	signal sv_CS_storage : std_logic_vector (2 downto 0);
	
	signal si_OCR    : integer range 0 to ci_timer_max;
	signal si_prescale   : integer range 0 to ci_prescale_max;
	
	signal si_PSC : integer range 0 to ci_prescale_max := 0; -- prescale counter
	signal si_TC  : integer range 0 to ci_timer_max := 0; -- timer counter
	
	signal si_incremental_counter : integer range 0 to ci_timer_max;
	signal si_incremental_cnt_trim : integer range 0 to ci_timer_max;
	
	signal sv_TC_buffer : std_logic_vector (15 downto 0);

begin
	process (pil_reset, pil_clk)
		
		variable v_T_storage : std_logic_vector (15 downto 0);
		
	begin
		if (pil_reset = '1') then
			v_T_storage := (others => '0');
			pov_Timer_out <= (others => '1');
			si_prescale <= ci_prescale_max - 1;
			si_OCR <= 0;
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_TH = '1') then
				sv_TH_storage <= pov_T_BUS_input;
			end if;
			
			if (pil_en_TL = '1') then
				sv_TL_storage <= pov_T_BUS_input;
			end if;
			
			if (pil_CS = '1') then
				sv_CS_storage <= pov_T_BUS_input (2 downto 0);
			end if;
			
			if (pil_en_T = '1') then
				v_T_storage := sv_TH_storage & sv_TL_storage;
				si_OCR <= to_integer (unsigned (v_T_storage));
				case sv_CS_storage is
					when "000" =>
						si_prescale <= 1;
					when "001" =>
						si_prescale <= 64;
					when "010" =>
						si_prescale <= 128;
					when "011" =>
						si_prescale <= 512;
					when "100" =>
						si_prescale <= 1024;
					when "101" =>
						si_prescale <= 2048;
					when "110" =>
						si_prescale <= 4096;
					when "111" =>
						si_prescale <= 8192;
					when others =>
						si_prescale <= 0;
				end case;
			end if;
			
			if pil_TC_L = '1' then
				pov_Timer_out <= X"00" & sv_TC_buffer (7 downto 0);
			end if;
			
			if pil_TC_H = '1' then
				pov_Timer_out <= X"00" & sv_TC_buffer (15 downto 8);
			end if;
		end if;
	end process;
	
	proc_Timer_Counter : process (pil_clk, pil_reset) is
	begin
		if pil_reset = '1' then
			si_PSC <= 0;
			si_TC <= 0;
			pol_TF_Flag <= '0';
			pol_TOV_Flag <= '0';
			si_incremental_counter <= 0;
			si_incremental_cnt_trim <= 0;
			sv_TC_buffer <= (others => '0');
		elsif rising_edge(pil_clk) then
			if pil_load_counter = '1' then
				si_incremental_cnt_trim <= si_OCR;
				si_incremental_counter <= si_OCR;
			end if;
			
			if (pil_en_TR = '1') then
				if (si_PSC < si_prescale - 1) then
					si_PSC <= si_PSC + 1;
				else
					si_PSC <= 0;
					if (si_TC < si_OCR) then
						si_TC <= si_TC + 1;
						pol_TF_Flag <= '0';
					else
						si_TC <= 0;
						pol_TF_Flag <= '1';
					end if;
				end if;
			else
				si_TC <= 0;
				pol_TF_Flag <= '0';
			end if;
			
			if (pil_en_TCR = '1') then
				if (si_PSC < si_prescale - 1) then
					si_PSC <= si_PSC + 1;
				else
					si_PSC <= 0;
					if (si_incremental_counter < ci_timer_max) then
						si_incremental_counter <= si_incremental_counter + 1;
						pol_TOV_Flag <= '0';
					else
						si_incremental_counter <= si_incremental_cnt_trim;
						pol_TOV_Flag <= '1';
					end if;
				end if;
				sv_TC_buffer <= std_logic_vector (to_unsigned (si_incremental_counter , sv_TC_buffer'length));
			else
				pol_TOV_Flag <= '0';
			end if;
		end if;
	end process proc_Timer_Counter;
	
end rtl;