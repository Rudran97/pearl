----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BUS_module is
	generic(
		gi_max_control_signal : integer := 74
	);
	port(piv_en_control : in  std_logic_vector(gi_max_control_signal downto 0);
	     piv_BUS_RAM    : in  std_logic_vector(15 downto 0);
	     piv_BUS_AR     : in  std_logic_vector(15 downto 0);
	     piv_BUS_ALU    : in  std_logic_vector(15 downto 0);
	     piv_BUS_IR     : in  std_logic_vector(15 downto 0);
	     piv_BUS_PC     : in  std_logic_vector(15 downto 0);
	     piv_BUS_GPR0   : in  std_logic_vector(15 downto 0);
	     piv_BUS_GPR1   : in  std_logic_vector(15 downto 0);
	     piv_BUS_GPR2   : in  std_logic_vector(15 downto 0);
	     piv_BUS_P0     : in  std_logic_vector(15 downto 0);
	     piv_BUS_CG     : in  std_logic_vector(15 downto 0);
	     piv_BUS_SM     : in  std_logic_vector(15 downto 0);
	     piv_BUS_DM     : in  std_logic_vector(15 downto 0);
	     piv_BUS_GPR3   : in  std_logic_vector(15 downto 0);
	     piv_BUS_P1     : in  std_logic_vector(15 downto 0);
	     pil_BUS_Timer0 : in  std_logic_vector(15 downto 0);
	     pil_BUS_LR     : in  std_logic_vector(15 downto 0);
	     pov_BUS_data   : out std_logic_vector(15 downto 0)
	    );
end BUS_module;


architecture rtl of BUS_module is

--signal s_store_bus_data : std_logic_vector (7 downto 0);

begin
	process    (piv_en_control (73),
				piv_en_control (69),
				piv_en_control (68), 
				piv_en_control (65),
				piv_en_control (64),
				piv_en_control (61),
				piv_en_control (56),
				piv_en_control (54),
				piv_en_control (51),
				piv_en_control (49),
				piv_en_control (47),
				piv_en_control (46),
				piv_en_control (45),
				piv_en_control (44),
				piv_en_control (43),
				piv_en_control (36),
				piv_en_control (34),
				piv_en_control (30),
				piv_en_control (29),
				piv_en_control (28),
				piv_en_control (24),
				piv_en_control (23),
				piv_en_control (22),
				piv_en_control (18),
				piv_en_control (17),
				piv_en_control (14),
				piv_en_control (13),
				piv_en_control (8),
				piv_en_control (2),
				piv_en_control (1),
				piv_en_control (0),
				piv_BUS_RAM,
				piv_BUS_IR,
				piv_BUS_AR,
				piv_BUS_ALU,
				piv_BUS_PC,
				piv_BUS_GPR0,
				piv_BUS_GPR1,
				piv_BUS_GPR2,
				piv_BUS_P0,
				piv_BUS_CG,
				piv_BUS_SM,
				piv_BUS_GPR3,
				piv_BUS_DM,
				piv_BUS_P1,
				pil_BUS_Timer0,
				pil_BUS_LR
				)
	begin
		if  piv_en_control (73) = '1' then
			pov_BUS_data <= pil_BUS_LR;
		elsif piv_en_control (69) = '1' or piv_en_control (68) = '1' then
			pov_BUS_data <= pil_BUS_Timer0;
		elsif (piv_en_control (65) = '1') then
			pov_BUS_data <= piv_BUS_P1;
		elsif (piv_en_control (64) = '1') then
			pov_BUS_data <= piv_BUS_P1;
		elsif (piv_en_control (61) = '1') then
			pov_BUS_data <= piv_BUS_AR;
		elsif (piv_en_control (56) = '1') then
			pov_BUS_data <= piv_BUS_GPR3;
		elsif (piv_en_control (54) = '1') then
			pov_BUS_data <= piv_BUS_DM;
		elsif (piv_en_control (51) = '1') then
			pov_BUS_data <= piv_BUS_P0;
		elsif (piv_en_control (49) = '1') then
			pov_BUS_data <= piv_BUS_SM;
		elsif (piv_en_control (47) = '1') then
			pov_BUS_data <= piv_BUS_CG;
		elsif (piv_en_control (46) = '1') then
			pov_BUS_data <= piv_BUS_CG;
		elsif (piv_en_control (45) = '1') then
			pov_BUS_data <= piv_BUS_CG;
		elsif (piv_en_control (44) = '1') then
			pov_BUS_data <= piv_BUS_CG;
		elsif (piv_en_control (43) = '1') then
			pov_BUS_data <= piv_BUS_CG;
		elsif (piv_en_control (36) = '1') then
			pov_BUS_data <= piv_BUS_ALU;
		elsif (piv_en_control (34) = '1') then
			pov_BUS_data <= piv_BUS_P0;
		elsif (piv_en_control (30) = '1') then
			pov_BUS_data <= piv_BUS_GPR2;
		elsif (piv_en_control (29) = '1') then
			pov_BUS_data <= piv_BUS_GPR2;
		elsif (piv_en_control (28) = '1') then
			pov_BUS_data <= piv_BUS_GPR2;
		elsif (piv_en_control (24) = '1') then
			pov_BUS_data <= piv_BUS_GPR1;
		elsif (piv_en_control (23) = '1') then
			pov_BUS_data <= piv_BUS_GPR1;
		elsif (piv_en_control (22) = '1') then
			pov_BUS_data <= piv_BUS_GPR1;
		elsif (piv_en_control (18) = '1') then
			pov_BUS_data <= piv_BUS_RAM;
		elsif (piv_en_control (17) = '1') then
			pov_BUS_data <= piv_BUS_IR;
		elsif (piv_en_control (14) = '1') then
			pov_BUS_data <= piv_BUS_AR;
		elsif (piv_en_control (13) = '1') then
			pov_BUS_data <= piv_BUS_ALU;
		elsif (piv_en_control (8) = '1') then
			pov_BUS_data <= piv_BUS_PC;
		elsif (piv_en_control (2) = '1') then
			pov_BUS_data <= piv_BUS_GPR0;
		elsif (piv_en_control (1) = '1') then
			pov_BUS_data <= piv_BUS_GPR0;
		elsif (piv_en_control (0) = '1') then
			pov_BUS_data <= piv_BUS_GPR0;
		else
			pov_BUS_data <= (others => '0');
		end if;
	end process;
end rtl;