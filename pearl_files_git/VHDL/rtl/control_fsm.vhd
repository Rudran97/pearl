----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:27:21 04/07/2020 
-- Design Name: 
-- Module Name:    CU2_e - CU2_a 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.control_fsm_p.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_fsm is
	generic(
		gi_max_control_signal : integer := 74
	);
	port(pil_reset          : in  std_logic;
	     pil_clk            : in  std_logic;
	     pil_run_prog       : in  std_logic;
	     pil_halt_CU        : in  std_logic;
	     pov_CU_IR          : in  std_logic_vector(7 downto 0);
	     pil_CF_flag        : in  std_logic;
	     pil_ZF_flag        : in  std_logic;
	     pil_TF0_flag       : in  std_logic;
	     pil_TOV_flag       : in  std_logic;
	     pov_en_control_sig : out std_logic_vector(gi_max_control_signal downto 0)
	     );
end control_fsm;


architecture rtl of control_fsm is
	
	signal st_pr_step : CU_step_t := CU_fetch0a_st;

begin
	
	process (pil_reset, pil_clk)
	begin
		if (pil_reset = '1') then
			st_pr_step <= CU_fetch0a_st;
			pov_en_control_sig <= (others => '0');
		elsif (pil_clk'event and pil_clk = '0') then
			if (pil_run_prog = '1') then
				if (pil_halt_CU = '0') then
					case st_pr_step is
						when CU_fetch0a_st =>
							pov_en_control_sig (41 downto 0) <= c_fetch (0);
							pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
							pov_en_control_sig (gi_max_control_signal downto 72) <= (others => '0');
							st_pr_step <= CU_fetch0b_st;
						
						when CU_fetch0b_st =>
							st_pr_step <= CU_fetch1a_st;
						
						when CU_fetch1a_st =>
							pov_en_control_sig (41 downto 0) <= c_fetch (1);
							pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
							st_pr_step <= CU_fetch1b_st;
							
						when CU_fetch1b_st =>
							st_pr_step <= CU_fetch2_st;
							
						when CU_fetch2_st =>
							pov_en_control_sig (41 downto 0) <= c_fetch (2);
							pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
							st_pr_step <= CU_0a_st;
							
						when CU_0a_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_LDA) then
								pov_en_control_sig (41 downto 0) <= c_LDA (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD) then
								pov_en_control_sig (41 downto 0) <= c_ADD (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_STA) then
								pov_en_control_sig (41 downto 0) <= c_STA (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_LDI) then
								pov_en_control_sig (41 downto 0) <= c_LDI (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JMP) then
								pov_en_control_sig (41 downto 0) <= c_JMP (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JMC) then    --Instruction for JMP when Carry 
								if (pil_CF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_JMP (0);			--JMP when carry set
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_0b_st;
								else
									pov_en_control_sig (41 downto 0) <= c_JMP (1);			--No action when carry cleared
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_0b_st;
								end if;
							elsif (pov_CU_IR = cv_IC_JMZ) then    --Instruction for JMP when Zero
								if (pil_ZF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_JMP (0);			--JMP when Zero set
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_0b_st;
								else
									pov_en_control_sig (41 downto 0) <= c_JMP (1);			--No action when Zero cleared
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_0b_st;
								end if;
							elsif (pov_CU_IR = cv_IC_MOV_R0A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0B) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R0A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R0B) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_OUT) then
								pov_en_control_sig (41 downto 0) <= c_OUT (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_HLT) then
								pov_en_control_sig (41 downto 0) <= c_HLT (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R0_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1B) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R1A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R1B) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R1) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R1_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2B) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R2A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R2B) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R2) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R2_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0A) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0B) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0A) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0B) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1A) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1B) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1A) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1B) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2A) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2B) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2A) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2B) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P0x (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P0x (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_P0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_P0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JB_TF0) then		-- Instruction for JMP when TF0 bit is SET (JB TF0)
								if (pil_TF0_flag = '1') then
--									pov_en_control_sig (41 downto 0) <= c_J_TF0 (0);		-- JMP when TF0 bit is set
--									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (6) <= '1';
									st_pr_step <= CU_0a_st;
								else
									pov_en_control_sig (41 downto 0) <= c_J_TF0 (1);		-- No action when cleared
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_0b_st;
								end if;
								--st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JNB_TF0) then		-- Instruction for JMP when TF0 bit is cleared (JNB TF0)
								if (pil_TF0_flag = '0') then
									--pov_en_control_sig (41 downto 0) <= c_J_TF0 (0);		-- JMP when TF0 bit is cleared
									--pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (6) <= '1';
									st_pr_step <= CU_0a_st;
								else
									pov_en_control_sig (41 downto 0) <= c_J_TF0 (1);      -- JMP when TF0 bit is set
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_0b_st;
								end if;
								--st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SET_T0E) then
								pov_en_control_sig (41 downto 0) <= c_S_C_T0E (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CLR_T0) then
								pov_en_control_sig (41 downto 0) <= c_S_C_T0E (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (42) <= '0';
								pov_en_control_sig (70) <= '0';
								pov_en_control_sig (71) <= '0';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SET_TR0) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (42) <= '1';
								pov_en_control_sig (6) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_TH0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_TH0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_TL0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_TL0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_CS0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_CS0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CALL) then
								pov_en_control_sig (41 downto 0) <= c_CALL (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_RET) then
								pov_en_control_sig (41 downto 0) <= c_RET (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R0) then
								pov_en_control_sig (41 downto 0) <= c_PUSH_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_POP_R0) then
								pov_en_control_sig (41 downto 0) <= c_POP_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R1) then
								pov_en_control_sig (41 downto 0) <= c_PUSH_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_POP_R1) then
								pov_en_control_sig (41 downto 0) <= c_POP_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R2) then
								pov_en_control_sig (41 downto 0) <= c_PUSH_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_POP_R2) then
								pov_en_control_sig (41 downto 0) <= c_POP_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DDRP0) then
								pov_en_control_sig (41 downto 0) <= c_DIR_P0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (50) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (0); -- JB P0.X
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (0); -- JNB P0.X
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (0); -- JB P1.X
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (0); -- JNB P1.X
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R3) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (55) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R3) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_R3_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_R3_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (55) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_DM) then
								pov_en_control_sig (41 downto 0) <= c_MOV_DM (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_DM) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_DM (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_DM_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_DM_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								pov_en_control_sig (48) <= '1';
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								pov_en_control_sig (48) <= '1';
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								pov_en_control_sig (48) <= '1';
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_PUSH_DM) then				--- PUSH DM
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_POP_DM) then				--- POP DM
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R3) then				--- PUSH R3
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_POP_R3) then				--- POP R3
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (55) <= '1';
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_AND_R0) then
								pov_en_control_sig (41 downto 0) <= c_AND_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_AND_R1) then
								pov_en_control_sig (41 downto 0) <= c_AND_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_AND_R2) then
								pov_en_control_sig (41 downto 0) <= c_AND_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_AND_R3) then
								pov_en_control_sig (41 downto 0) <= c_AND_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_OR_R0) then
								pov_en_control_sig (41 downto 0) <= c_OR_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_OR_R1) then
								pov_en_control_sig (41 downto 0) <= c_OR_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_OR_R2) then
								pov_en_control_sig (41 downto 0) <= c_OR_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_OR_R3) then
								pov_en_control_sig (41 downto 0) <= c_OR_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CPL_A) then
								pov_en_control_sig (41 downto 0) <= c_CPL_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR1) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR2) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR3) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR0_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR0_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR1_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR1_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR2_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR2_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR3_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR3_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								pov_en_control_sig (41 downto 0) <= c_INC_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R3) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P0x (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_RDA_P0) then
								pov_en_control_sig (41 downto 0) <= c_RDA_P0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (52) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_C) then 				-- MOV A C
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (15) <= '1';
								pov_en_control_sig (61) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_A) then				-- MOV C A
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (14) <= '1';
								pov_en_control_sig (60) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C) then				-- MOV C ...
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (17) <= '1';
								pov_en_control_sig (60) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_RRC) then				-- RRC
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (57) <= '1';
								pov_en_control_sig (58) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_RLC) then				-- RLC
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (57) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_PUSH_A) then				-- PUSH A
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								pov_en_control_sig (14) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_POP_A) then				-- POP A
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								pov_en_control_sig (15) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDI) then
								pov_en_control_sig (41 downto 0) <= c_ADDI (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUBI) then
								pov_en_control_sig (41 downto 0) <= c_SUBI (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_DDRP1) then
								pov_en_control_sig (41 downto 0) <= c_DIR_P1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (62) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (63) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (63) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_P1) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_P1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (64) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P1x (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P1x (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P1x (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_RDA_P1) then
								pov_en_control_sig (41 downto 0) <= c_RDA_P1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (66) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CMPI) then
								pov_en_control_sig (41 downto 0) <= c_CMPI (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_CMP) then
								pov_en_control_sig (41 downto 0) <= c_CMP (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TH0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_TH0_A(0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TL0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_TL0_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_CS0_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_CS0_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R0) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R1) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R2) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R3) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDIC) then
								pov_en_control_sig (41 downto 0) <= c_ADDI (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_ADDC) then
								pov_en_control_sig (41 downto 0) <= c_ADD (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TC0L) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_TC0L (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (68) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TC0H) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_TC0H (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (69) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SET_TCR0E) then
								pov_en_control_sig (41 downto 0) <= c_SET_TCR0E (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (70) <= '1';
								pov_en_control_sig (71) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JB_T0V) then
								if (pil_TOV_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_JB_NB_T0V (0);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (71) <= '1';
								else
									pov_en_control_sig (41 downto 0) <= c_JB_NB_T0V (1);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (71) <= '1';
								end if;
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_JNB_T0V) then
								if (pil_TOV_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_JB_NB_T0V (0);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (71) <= '1';
								else
									pov_en_control_sig (41 downto 0) <= c_JB_NB_T0V (1);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (71) <= '1';
								end if;
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SET_TC0L) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (72) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_PC_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_PC_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_PC) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_PC (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_LR) then
								pov_en_control_sig (41 downto 0) <= c_MOV_LR (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (74) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_LR_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_LR_A (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (74) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_LR) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_LR (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (73) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_PC_LR) then
								pov_en_control_sig (41 downto 0) <= c_MOV_PC_LR (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (73) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_MOV_LR_PC) then
								pov_en_control_sig (41 downto 0) <= c_MOV_LR_PC (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (74) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R0 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R1 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R2 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R3 (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								pov_en_control_sig (41 downto 0) <= c_SUBIB (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								pov_en_control_sig (41 downto 0) <= c_SUBB (0);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_0b_st;
							end if;
							
							
						when CU_0b_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_LDA) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_STA) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_LDI) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JMP) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JMC) then    --Instruction for JMP when Carry 
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JMZ) then    --Instruction for JMP when Zero
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_OUT) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_HLT) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R0_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R1_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R2_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_P0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JB_TF0) then		-- Instruction for JMP when TF0 bit is SET (JB TF0)
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JNB_TF0) then		-- Instruction for JMP when TF0 bit is cleared (JNB TF0)
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_T0E) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CLR_T0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_TR0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_TH0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_TL0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_CS0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_CALL) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_RET) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_POP_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_POP_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_POP_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DDRP0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then -- JB P0.x
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then -- JNB P0.x
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then -- JB P1.x
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then -- JNB P1.x
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_R3_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_DM) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_DM) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_DM_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_PUSH_DM) then				--- PUSH DM
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_POP_DM) then				--- POP DM
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_PUSH_R3) then				--- PUSH R3
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_POP_R3) then				--- POP R3
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_AND_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_AND_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_AND_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_AND_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_OR_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_OR_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_OR_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_OR_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_CPL_A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR0_A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR1_A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR2_A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR3_A) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_RDA_P0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_C) then 				-- MOV A C
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_A) then				-- MOV C A
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C) then				-- MOV C ...
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_RRC) then				-- RRC
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_RLC) then				-- RLC
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_PUSH_A) then				-- PUSH A
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_POP_A) then				-- POP A
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDI) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUBI) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_DDRP1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_P1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_RDA_P1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_CMPI) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_CMP) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TH0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TL0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_CS0_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R0) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADDIC) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_ADDC) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TC0L) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_TC0H) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_TCR0E) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JB_T0V) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JNB_T0V) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_TC0L) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_PC_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_PC) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_LR) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_LR_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_LR) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_PC_LR) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_LR_PC) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								st_pr_step <= CU_1a_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								st_pr_step <= CU_1a_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								st_pr_step <= CU_1a_st;
							end if;
							
							
						when CU_1a_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_LDA) then
								pov_en_control_sig (41 downto 0) <= c_LDA (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD) then
								pov_en_control_sig (41 downto 0) <= c_ADD (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_STA) then
								pov_en_control_sig (41 downto 0) <= c_STA (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0A) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0B) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0A) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R0A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0B) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R0B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1A) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1B) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1A) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R1A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1B) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R1B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2A) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2B) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2A) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R2A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2B) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R2B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P0x (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P0x (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2B (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (1);
								pov_en_control_sig (43) <= '1';
								pov_en_control_sig (ci_max_control_L downto 44) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_CALL) then
								pov_en_control_sig (41 downto 0) <= c_CALL (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (1); -- JB P0.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (52) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (1); -- JNB P0.0
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (52) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (1); -- JB P1.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (66) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (1); -- JNB P1.0
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (66) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_AND_R0) then
								pov_en_control_sig (41 downto 0) <= c_AND_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_AND_R1) then
								pov_en_control_sig (41 downto 0) <= c_AND_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_AND_R2) then
								pov_en_control_sig (41 downto 0) <= c_AND_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_AND_R3) then
								pov_en_control_sig (41 downto 0) <= c_AND_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_OR_R0) then
								pov_en_control_sig (41 downto 0) <= c_OR_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_OR_R1) then
								pov_en_control_sig (41 downto 0) <= c_OR_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_OR_R2) then
								pov_en_control_sig (41 downto 0) <= c_OR_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_OR_R3) then
								pov_en_control_sig (41 downto 0) <= c_OR_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_CPL_A) then
								pov_en_control_sig (41 downto 0) <= c_CPL_A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR0) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR1) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR2) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR3) then
								pov_en_control_sig (41 downto 0) <= c_MOV_A_XR3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR0_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR0_A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR1_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR1_A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR2_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR2_A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR3_A) then
								pov_en_control_sig (41 downto 0) <= c_MOV_XR3_A (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								pov_en_control_sig (41 downto 0) <= c_INC_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADD_R3) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUB_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P0x (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (52) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_RDA_P0) then
								pov_en_control_sig (41 downto 0) <= c_RDA_P0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (51) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDI) then
								pov_en_control_sig (41 downto 0) <= c_ADDI (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUBI) then
								pov_en_control_sig (41 downto 0) <= c_SUBI (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P1x (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (64) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P1x (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (64) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P1x (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (66) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_RDA_P1) then
								pov_en_control_sig (41 downto 0) <= c_RDA_P1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (65) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_CMPI) then
								pov_en_control_sig (41 downto 0) <= c_CMPI (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_CMP) then
								pov_en_control_sig (41 downto 0) <= c_CMP (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R0) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R1) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R2) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R3) then
								pov_en_control_sig (41 downto 0) <= c_ADD_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDIC) then
								pov_en_control_sig (41 downto 0) <= c_ADDI (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_ADDC) then
								pov_en_control_sig (41 downto 0) <= c_ADD (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R0 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R1 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R2 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R3 (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								pov_en_control_sig (56) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								pov_en_control_sig (41 downto 0) <= c_SUBIB (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_1b_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								pov_en_control_sig (41 downto 0) <= c_SUBB (1);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_1b_st;
							end if;
							
							
						when CU_1b_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_LDA) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_SUB) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_STA) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_CALL) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then  -- JB P0.x
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then  -- JNB P0.x
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then  -- JB P1.x
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then  -- JNB P1.x
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_AND_R0) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_AND_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_AND_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_AND_R3) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_OR_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_OR_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_OR_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_OR_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CPL_A) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_A_atR3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR0_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR1_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR2_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_atR3_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_ADD_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_RDA_P0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDI) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBI) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_RDA_P1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CMPI) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CMP) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDC_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDIC) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDC) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								st_pr_step <= CU_2a_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								st_pr_step <= CU_2a_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								st_pr_step <= CU_2a_st;
							end if;

							
						when CU_2a_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_ADD) then
								pov_en_control_sig (41 downto 0) <= c_ADD (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SUB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P0x (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P0x (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (2); -- JB P0.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (51) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (2); -- JNB P0.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (51) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (2); -- JB P1.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (65) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (2); -- JNB P1.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (65) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								if (pil_CF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_DIV_R0 (2);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (48) <= '1';
									st_pr_step <= CU_2b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_7a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								if (pil_CF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_DIV_R1 (2);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (48) <= '1';
									st_pr_step <= CU_2b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_7a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								if (pil_CF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_DIV_R2 (2);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (48) <= '1';
									st_pr_step <= CU_2b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_7a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_AND_R0) then
								pov_en_control_sig (41 downto 0) <= c_AND_R0 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_AND_R1) then
								pov_en_control_sig (41 downto 0) <= c_AND_R1 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_AND_R2) then
								pov_en_control_sig (41 downto 0) <= c_AND_R2 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_AND_R3) then
								pov_en_control_sig (41 downto 0) <= c_AND_R3 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_CPL_A) then
								pov_en_control_sig (41 downto 0) <= c_CPL_A (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								pov_en_control_sig (41 downto 0) <= c_INC_R3 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R3 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (57) <= '1';
								pov_en_control_sig (59) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P0x (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (51) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P1x (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P1x (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (59) <= '1';
								pov_en_control_sig (57) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P1x (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (65) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_CMP) then
								pov_en_control_sig (41 downto 0) <= c_CMP (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_ADDC) then
								pov_en_control_sig (41 downto 0) <= c_ADD (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R0 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_2b_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R1 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R2 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R3 (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								pov_en_control_sig (41 downto 0) <= c_SUBIB (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_2b_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (2);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								st_pr_step <= CU_2b_st;
							end if;
							
							
						when CU_2b_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_ADD) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUB) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then -- JB P0.x
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then -- JNB P0.x
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then -- JB P1.x
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then -- JNB P1.x
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_AND_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_AND_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_AND_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_AND_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CPL_A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_CMP) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_ADDC) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								st_pr_step <= CU_3a_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								st_pr_step <= CU_3a_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								st_pr_step <= CU_3a_st;
							end if;
							
							
						when CU_3a_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P0x (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P0x (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0A (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0B (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								pov_en_control_sig (41 downto 0) <= c_INC_R0 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1A (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1B (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								pov_en_control_sig (41 downto 0) <= c_INC_R1 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2A (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2B (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								pov_en_control_sig (41 downto 0) <= c_INC_R2 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0A (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0B (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R0 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1A (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1B (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R1 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2A (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2B (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R2 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
							   if (pil_ZF_flag = '0') then
								   pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (3);   --JMP when zero flag is cleared
								   pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (3); -- JB P0.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (3); -- JNB P0.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (3); -- JB P1.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (3); -- JNB P1.x
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								pov_en_control_sig (41 downto 0) <= c_INC_R3 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (55) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								pov_en_control_sig (41 downto 0) <= c_DEC_R3 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (55) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (3);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								end if;
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P0x (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (57) <= '1';
								pov_en_control_sig (58) <= '1';
								pov_en_control_sig (59) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								pov_en_control_sig (41 downto 0) <= c_SET_P1x (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (63) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								pov_en_control_sig (41 downto 0) <= c_CLR_P1x (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (63) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P1x (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (59) <= '1';
								pov_en_control_sig (58) <= '1';
								pov_en_control_sig (57) <= '1';
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R0 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R1 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R2 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R3 (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								pov_en_control_sig (41 downto 0) <= c_SUBIB (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_3b_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (3);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_3b_st;
							end if;
							
							
						when CU_3b_st =>
							if (pov_CU_IR = cv_IC_NOP) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SET_P0X) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P0X) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_INC_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then  -- JB P0.x
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then  -- JNB P0.x
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then  -- JB P1.x
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then  -- JNB P1.x
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_INC_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DEC_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_SET_P1X) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_CLR_P1X) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= (others => '0');
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								st_pr_step <= CU_4a_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								st_pr_step <= CU_4a_st;
							end if;
							
						
						when CU_4a_st =>
							if (pov_CU_IR = cv_IC_DJNZ_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (4);
								pov_en_control_sig (44) <= '1';
								pov_en_control_sig (43) <= '0';
								pov_en_control_sig (ci_max_control_L downto 45) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then				-- JB P0.X
								if (pil_ZF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_4b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (9) <= '1';
									st_pr_step <= CU_6a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then				-- JNB P0.X
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_4b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (9) <= '1';
									st_pr_step <= CU_6a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then				-- JB P1.X
								if (pil_ZF_flag = '1') then
									pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_4b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (9) <= '1';
									st_pr_step <= CU_6a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then				-- JNB P1.X
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									st_pr_step <= CU_4b_st;
								else
									pov_en_control_sig (41 downto 0) <= (others => '0');
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (9) <= '1';
									st_pr_step <= CU_6a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_MUL_R0 (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (56) <= '1';
									st_pr_step <= CU_4b_st;
								else
									st_pr_step <= CU_13a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_MUL_R1 (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (56) <= '1';
									st_pr_step <= CU_4b_st;
								else
									st_pr_step <= CU_13a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								if (pil_ZF_flag = '0') then
									pov_en_control_sig (41 downto 0) <= c_MUL_R2 (4);
									pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
									pov_en_control_sig (56) <= '1';
									st_pr_step <= CU_4b_st;
								else
									st_pr_step <= CU_13a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P0x (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (60) <= '1';
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P1x (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (60) <= '1';
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R0 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R1 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R2 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								pov_en_control_sig (41 downto 0) <= c_SUBB_R3 (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								pov_en_control_sig (41 downto 0) <= c_SUBIB (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (4);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_4b_st;
							end if;
							
						
						when CU_4b_st =>
							if (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then  -- JB P0.x
								pov_en_control_sig (9) <= '0';
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then  -- JNB P0.x
								pov_en_control_sig (9) <= '0';
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then  -- JB P1.x
								pov_en_control_sig (9) <= '0';
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then  -- JNB P1.x
								pov_en_control_sig (9) <= '0';
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								st_pr_step <= CU_5a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R0) then
								st_pr_step <= CU_fetch0a_st;	
							elsif (pov_CU_IR = cv_IC_SUBB_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBB_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBIB) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								st_pr_step <= CU_5a_st;
							end if;
							
							
						when CU_5a_st =>
							if (pov_CU_IR = cv_IC_DJNZ_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then				-- JB P0.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then				-- JNB P0.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then				-- JB P0.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then				-- JNB P0.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (54) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P0x (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (64) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								pov_en_control_sig (41 downto 0) <= c_MOV_C_P1x (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_5b_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								pov_en_control_sig (41 downto 0) <= c_SUB (5);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_5b_st;
							end if;
							
						
						when CU_5b_st =>
							if (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then  -- JB P0.x
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then  -- JNB P0.x
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then  -- JB P1.x
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then  -- JNB P1.x
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P0X) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_6a_st;
							elsif (pov_CU_IR = cv_IC_MOV_C_P1X) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_SUBB) then
								st_pr_step <= CU_fetch0a_st;
							end if;
							
						
						when CU_6a_st =>
							if (pov_CU_IR = cv_IC_DJNZ_R0A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0A (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0B (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R0 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1A (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1B (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R1 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2A (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2B (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R2 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then				-- JB P0.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then				-- JNB P0.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then				-- JB P1.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then				-- JNB P1.X
								pov_en_control_sig (41 downto 0) <= c_JB_NB_P0_X (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_idle1_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_idle1_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (53) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_idle1_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								pov_en_control_sig (41 downto 0) <= c_DJNZ_R3 (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (55) <= '1';
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (6);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_6b_st;
							end if;
							
							
						when CU_6b_st =>
							if (pov_CU_IR = cv_IC_DJNZ_R0A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2A) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2B) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R2) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_7a_st;
							elsif (pov_CU_IR = cv_IC_JB_P0x) then  -- JB P0.x
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P0x) then  -- JNB P0.x
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JB_P1x) then  -- JB P1.x
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_JNB_P1x) then  -- JNB P1.x
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_7a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_7a_st;
							elsif (pov_CU_IR = cv_IC_DJNZ_R3) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								if (pil_ZF_flag = '0') then
									st_pr_step <= CU_7a_st;
								else
									st_pr_step <= CU_8a_st;
								end if;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								if (pil_ZF_flag = '0') then
									st_pr_step <= CU_7a_st;
								else
									st_pr_step <= CU_8a_st;
								end if;
							end if;
							
						
						when CU_7a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_7b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R0) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R0 (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <=  CU_idle2_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_7b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R1) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R1 (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <=  CU_idle2_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_7b_st;
							elsif (pov_CU_IR = cv_IC_DIV_R2) then
								pov_en_control_sig (41 downto 0) <= c_DIV_R2 (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <=  CU_idle2_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_7b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (7);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (63) <= '1';
								st_pr_step <= CU_7b_st;
							end if;
							
						
						when CU_7b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_8a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_8a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_8a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_9a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_9a_st;
							end if;
							
							
						when CU_8a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (8);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_8b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (8);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_8b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (8);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (43) <= '1';
								st_pr_step <= CU_8b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (8);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_8b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (8);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (63) <= '1';
								st_pr_step <= CU_8b_st;
							end if;
							

						when CU_8b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_9a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_9a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_9a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								st_pr_step <= CU_9a_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								st_pr_step <= CU_9a_st;
							end if;
							
							
						when CU_9a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (9);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_9b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (9);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_9b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (9);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (67) <= '1';
								pov_en_control_sig (48) <= '1';
								st_pr_step <= CU_9b_st;
							elsif (pov_CU_IR = cv_IC_MOV_P0X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P0x_C (9);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_idle1_st;
							elsif (pov_CU_IR = cv_IC_MOV_P1X_C) then
								pov_en_control_sig (41 downto 0) <= c_MOV_P1x_C (9);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_idle1_st;
							end if;
						
						when CU_9b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_10a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_10a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_10a_st;
							end if;
								
						when CU_10a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (10);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_10b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (10);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_10b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (10);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_10b_st;
							end if;
							
						when CU_10b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_11a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_11a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_11a_st;
							end if;
							
						when CU_11a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (11);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_11b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (11);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_11b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (11);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (44) <= '1';
								st_pr_step <= CU_11b_st;
							end if;
							
						when CU_11b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_12a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_12a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_12a_st;
							end if;
						
						when CU_12a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (12);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_12b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (12);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_12b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (12);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								st_pr_step <= CU_12b_st;
							end if;
							
						when CU_12b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_4a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_4a_st;
							end if;
							
						when CU_13a_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R0 (13);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_13b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R1 (13);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_13b_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								pov_en_control_sig (41 downto 0) <= c_MUL_R2 (13);
								pov_en_control_sig (ci_max_control_L downto 43) <= (others => '0');
								pov_en_control_sig (49) <= '1';
								st_pr_step <= CU_13b_st;
							end if;
							
						when CU_13b_st =>
							if (pov_CU_IR = cv_IC_MUL_R0) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R1) then
								st_pr_step <= CU_fetch0a_st;
							elsif (pov_CU_IR = cv_IC_MUL_R2) then
								st_pr_step <= CU_fetch0a_st;
							end if;
							
						when CU_idle1_st =>
							if (pov_CU_IR = cv_IC_DIV_R0 or pov_CU_IR = cv_IC_DIV_R1 or pov_CU_IR = cv_IC_DIV_R2) then
								st_pr_step <= CU_0a_st;
							else
								st_pr_step <= CU_fetch0a_st;
							end if;
							
						when CU_idle2_st =>
							st_pr_step <= CU_fetch0a_st;
							
						when others =>
							st_pr_step <= CU_fetch0a_st;
							--en_x16_o <= (others => '1');
					end case;
					
				elsif (pil_halt_CU = '1') then
					pov_en_control_sig (41 downto 0) <= c_HLT (0);
					pov_en_control_sig (gi_max_control_signal downto 42) <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end rtl;