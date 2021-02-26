----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_e is
	generic (
		gi_max_control_signal : integer := 74
	);
	port(
		pil_clk          : in    std_logic;
		pil_reset        : in    std_logic;
		pil_en_buffer    : in    std_logic;
		piv_address_in   : in    std_logic_vector(15 downto 0);
		piv_data_in      : in    std_logic_vector(15 downto 0);
		pil_sel          : in    std_logic;
		pil_run_prog     : in    std_logic;
		pov_out_register : out   std_logic_vector(7 downto 0);
		pbv_port0        : inout std_logic_vector(7 downto 0);
		pbv_port1        : inout std_logic_vector(7 downto 0)
	);
end entity core_e;

architecture core_a of core_e is
	
	--signals declared for Data Address Buffer Module--
	signal sl_write_data_buffer : std_logic;
	signal sv_x16_add_buff      : std_logic_vector(15 downto 0);
	signal sv_x16_data_buff     : std_logic_vector(15 downto 0);

	--signals declared for RAM Module--
	signal sl_R_RAM          : std_logic;
	signal sl_W_RAM          : std_logic;
	signal sl_write_data_RAM : std_logic;
	signal si_RAM_address    : integer range 0 to 255; --- address input
	signal sv_RAM_in         : std_logic_vector(15 downto 0);
	signal sv_RAM_out        : std_logic_vector(15 downto 0);

	--signals declared for MAR Module--
	signal sl_MAR     : std_logic;
	signal sv_MAR_in  : std_logic_vector(15 downto 0);
	signal si_MAR_out : integer range 0 to 255;

	--signals declared for Accumulator Register Module--
	signal sl_R_AR    : std_logic;
	signal sl_W_AR    : std_logic;
	signal sl_rotate  : std_logic;
	signal sl_AR_OP0  : std_logic;
	signal sl_AR_OP1  : std_logic;
	signal sl_R_carry : std_logic;
	signal sl_W_carry : std_logic;
	signal sv_AR_in   : std_logic_vector(15 downto 0);
	signal sv_AR_ALU  : std_logic_vector(7 downto 0);
	signal sv_AR_out  : std_logic_vector(15 downto 0);

	--signals declared for B Register Module--
	signal sl_R_BR   : std_logic;
	signal sv_BR_in  : std_logic_vector(15 downto 0);
	signal sv_BR_out : std_logic_vector(7 downto 0);

	--signals declared for General Purpose Register 0 Module--
	signal sl_R_R0   : std_logic;
	signal sl_R_R0A  : std_logic;
	signal sl_R_R0B  : std_logic;
	signal sl_W_R0   : std_logic;
	signal sl_W_R0A  : std_logic;
	signal sl_W_R0B  : std_logic;
	signal sv_R0_in  : std_logic_vector(15 downto 0);
	signal sv_R0_out : std_logic_vector(15 downto 0);

	--signals declared for General Purpose Register 1 Module--
	signal sl_R_R1   : std_logic;
	signal sl_R_R1A  : std_logic;
	signal sl_R_R1B  : std_logic;
	signal sl_W_R1   : std_logic;
	signal sl_W_R1A  : std_logic;
	signal sl_W_R1B  : std_logic;
	signal sv_R1_in  : std_logic_vector(15 downto 0);
	signal sv_R1_out : std_logic_vector(15 downto 0);

	--signals declared for General Purpose Register 2 Module--
	signal sl_R_R2   : std_logic;
	signal sl_R_R2A  : std_logic;
	signal sl_R_R2B  : std_logic;
	signal sl_W_R2   : std_logic;
	signal sl_W_R2A  : std_logic;
	signal sl_W_R2B  : std_logic;
	signal sv_R2_in  : std_logic_vector(15 downto 0);
	signal sv_R2_out : std_logic_vector(15 downto 0);

	--signals declared for Information Register Module--
	signal sl_R_IR       : std_logic;
	signal sl_W_IR       : std_logic;
	signal sv_IR_in      : std_logic_vector(15 downto 0);
	signal sv_IR_BUS_out : std_logic_vector(15 downto 0);
	signal sv_IR_CNU_out : std_logic_vector(7 downto 0);

	--signals declared for ALU Module--
	signal sv_ALU_AR    : std_logic_vector(7 downto 0);
	signal sv_ALU_BR    : std_logic_vector(7 downto 0);
	signal sl_bitO      : std_logic;
	signal sl_BIT_OP    : std_logic;
	signal sl_EO        : std_logic;
	signal sl_SU        : std_logic;
	signal sl_carry_bit : std_logic;
	signal sl_EO_carry  : std_logic;
	signal sv_ALU_out   : std_logic_vector(15 downto 0);
	signal sl_cbit      : std_logic;
	signal sl_zbit      : std_logic;

	--signals declared for Program Counter Module--
	signal sl_CO      : std_logic;      --- counter output enable
	signal sl_CE      : std_logic;      --- counter count enable
	signal sl_CI      : std_logic;      --- counter jump enable
	signal sv_bus_in  : std_logic_vector(15 downto 0);
	signal sv_bus_out : std_logic_vector(15 downto 0);

	--signals declared for Output Register Module--
	signal sl_OR    : std_logic;
	signal sv_OR_in : std_logic_vector(15 downto 0);
	--signal s_x8_OR_o : std_logic_vector (7 downto 0);

	--signals declared for PORT0 Register Module--
	signal sl_setdir_port0 : std_logic;
	signal sl_R_P0         : std_logic;
	signal sl_W_P0         : std_logic;
	signal sl_en_P0in      : std_logic; -- read pin if enable is '1'.
	signal sl_set_P0pin    : std_logic; -- save the PIN number that must be read.
	signal sv_P0_in        : std_logic_vector(15 downto 0);
	signal sv_P0_BUS_out   : std_logic_vector(15 downto 0);

	--signals declared for BUS Module--
	signal sv_BUS_RAM      : std_logic_vector(15 downto 0);
	signal sv_BUS_AR       : std_logic_vector(15 downto 0);
	signal sv_BUS_ALU      : std_logic_vector(15 downto 0);
	signal sv_BUS_IR       : std_logic_vector(15 downto 0);
	signal sv_BUS_PC       : std_logic_vector(15 downto 0);
	signal sv_BUS_GPR0     : std_logic_vector(15 downto 0);
	signal sv_BUS_GPR1     : std_logic_vector(15 downto 0);
	signal sv_BUS_GPR2     : std_logic_vector(15 downto 0);
	signal sv_BUS_P0       : std_logic_vector(15 downto 0);
	signal sv_BUS_CG       : std_logic_vector(15 downto 0);
	signal sv_BUS_SM       : std_logic_vector(15 downto 0);
	signal sv_BUS_DM       : std_logic_vector(15 downto 0);
	signal sv_BUS_GPR3     : std_logic_vector(15 downto 0);
	signal sv_BUS_P1       : std_logic_vector(15 downto 0);
	signal sv_BUS_Timer0   : std_logic_vector(15 downto 0);
	signal sv_LR_BUS       : std_logic_vector(15 downto 0);
	signal sv_BUS_data_out : std_logic_vector(15 downto 0);

	--signals declared for Flag Register--
	signal sl_en_flag_CU : std_logic;
	signal sl_en_TCOV    : std_logic;
	signal sl_CF_ALU     : std_logic;
	signal sl_ZF_ALU     : std_logic;
	signal sl_TF0_T0     : std_logic;
	signal sl_TOV        : std_logic;
	signal sl_flag_CF    : std_logic;
	signal sl_flag_ZF    : std_logic;
	signal sl_flag_TF0   : std_logic;
	signal sl_TOV_out    : std_logic;

	--singals declared for Timer0 Register--
	signal sl_TH0            : std_logic;
	signal sl_TL0            : std_logic;
	signal sl_CS0            : std_logic;
	signal sl_T0             : std_logic;
	signal sl_TR0            : std_logic;
	signal sv_T0_in          : std_logic_vector(7 downto 0);
	signal sl_TF0_out        : std_logic;
	signal sl_en_counter     : std_logic;
	signal sv_counter_L_out  : std_logic;
	signal sv_counter_H_out  : std_logic;
	signal sl_load_counter   : std_logic;
	signal sv_timer_out      : std_logic_vector(15 downto 0);
	signal sl_timer_overflow : std_logic;

	--signals declared for Constant Generator Module--
	signal sl_CG0    : std_logic;
	signal sl_CG1    : std_logic;
	signal sl_CGB2   : std_logic;
	signal sl_CGB1   : std_logic;
	signal sl_CGB0   : std_logic;
	signal sv_CG_out : std_logic_vector(15 downto 0);

	--signals declared for Stack Memory Module--
	signal sl_SM_R   : std_logic;
	signal sl_SM_W   : std_logic;
	signal sv_SM_in  : std_logic_vector(15 downto 0);
	signal sv_SM_out : std_logic_vector(15 downto 0);

	--signal declared for General Purpose Register 3 Module--
	signal sl_R_R3   : std_logic;
	signal sl_W_R3   : std_logic;
	signal sv_R3_in  : std_logic_vector(15 downto 0);
	signal sv_R3_out : std_logic_vector(15 downto 0);

	--signal declared for Division Multiplication Register Module--
	signal sl_R_DM   : std_logic;
	signal sl_W_DM   : std_logic;
	signal sv_DM_in  : std_logic_vector(15 downto 0);
	signal sv_DM_out : std_logic_vector(15 downto 0);

	--signals declared for Link Register Module--
	signal sl_en_R_LR : std_logic;
	signal sl_en_W_LR : std_logic;
	signal sv_LR_in   : std_logic_vector(15 downto 0);
	signal sv_LR_out  : std_logic_vector(15 downto 0);

	--signal declared for PORT1 Register Module--
	signal sl_setdir_P1  : std_logic;
	signal sl_R_P1       : std_logic;
	signal sl_W_P1       : std_logic;
	signal sl_en_P1in    : std_logic;   -- read pin if enable is '1'.
	signal sl_set_P1pin  : std_logic;   -- save the PIN number that must be read.
	signal sv_P1_in      : std_logic_vector(15 downto 0);
	signal sv_P1_BUS_out : std_logic_vector(15 downto 0);

	--signals declared for Control Unit Module--
	signal sl_halt_CU             : std_logic := '0';
	signal sv_CU_IR               : std_logic_vector(7 downto 0);
	signal sl_cf_CU_Flag          : std_logic;
	signal sl_zf_CU_Flag          : std_logic;
	signal sl_tf0_CU_Flag         : std_logic;
	
	signal sl_TOV_CU_Flag         : std_logic;
	
	signal sv_BUS_x16      : std_logic_vector(gi_max_control_signal downto 0);
	signal sv_control_signals_out : std_logic_vector(gi_max_control_signal downto 0);
	
begin
	
	--signals going from External Programmer Module to RAM and DAR module (priority)
	sv_MAR_in <= sv_x16_add_buff when (pil_run_prog = '0' and pil_sel = '1') else sv_BUS_data_out;

	sv_RAM_in <= sv_x16_data_buff when (pil_run_prog = '0' and pil_sel = '1') else sv_BUS_data_out;

	sv_OR_in <= sv_RAM_out when (pil_run_prog = '0' and pil_sel = '1') else sv_BUS_data_out;

	--

	--
	inst_Data_Address_Buffer : entity work.DA_Buffer
		port map(
			pil_clk           => pil_clk,             
			pil_reset         => pil_reset,           
			pil_en_buffer     => pil_en_buffer,       
			piv_address_buff  => piv_address_in,      
			piv_data_buff     => piv_data_in,         
			pol_en_write_data => sl_write_data_buffer,
			pov_add_buff      => sv_x16_add_buff,     
			pov_data_buff     => sv_x16_data_buff   
		);
	---

	--signals going out from DAB to RAM module (priority)
	sl_write_data_RAM <= sl_write_data_buffer;

	--
	inst_MAR : entity work.MAR
		port map(
			pil_reset  => pil_reset,  
			pil_clk    => pil_clk,    
			pil_en_MAR => sl_MAR,     
			pil_sel    => pil_sel,    
			piv_MAR    => sv_MAR_in,  
			poi_MAR    => si_MAR_out  
		);
	---

	--signals sent to RAM from MAR (priority)
	si_RAM_address <= si_MAR_out;
	
	--
	
	--
	inst_RAM : entity work.RAM
		port map(
			pil_reset        => pil_reset,        
			pil_clk          => pil_clk,          
			pil_sel          => pil_sel,          
			pil_manual_write => sl_write_data_RAM,
			pil_en_R_RAM     => sl_R_RAM,         
			pil_en_W_RAM     => sl_W_RAM,         
			pii_RAM_address  => si_RAM_address,   
			piv_RAM          => sv_RAM_in,        
			pov_RAM          => sv_RAM_out        
		);
	---

	--signals sent to BUS from RAM (priority)
	sv_BUS_RAM <= sv_RAM_out;

	--
	inst_Accumulator : entity work.AR
		port map(
			pil_reset      => pil_reset, 
			pil_clk        => pil_clk,   
			pil_en_R_AR    => sl_R_AR,   
			pil_en_W_AR    => sl_W_AR,   
			pil_en_Rotate  => sl_rotate, 
			pil_AR_OP0     => sl_AR_OP0, 
			pil_AR_OP1     => sl_AR_OP1, 
			pil_en_R_carry => sl_R_carry,
			pil_en_W_carry => sl_W_carry,
			piv_AR         => sv_AR_in,  
			pov_AR_ALU     => sv_AR_ALU, 
			pov_AR         => sv_AR_out  
		);
	---

	--signals sent to ALU from AR (priority)
	sv_ALU_AR <= sv_AR_ALU;
	--signals sent to BUS from AR (priority)
	sv_BUS_AR <= sv_AR_out;

	--

	--
	inst_BR : entity work.BR
		port map(
			pil_reset   => pil_reset, 
			pil_clk     => pil_clk,   
			pil_en_R_BR => sl_R_BR,   
			piv_BR      => sv_BR_in,  
			pov_BR      => sv_BR_out  
		);
	---
	
	--signals sent to ALU from BR (priority)
	sv_ALU_BR <= sv_BR_out;
	
	--

	--
	inst_GPR0 : entity work.GPR_type1
		port map(
			pil_reset    => pil_reset,
			pil_clk      => pil_clk,  
			pil_en_R_R0  => sl_R_R0,  
			pil_en_R_R0A => sl_R_R0A, 
			pil_en_R_R0B => sl_R_R0B, 
			pil_en_W_R0  => sl_W_R0,  
			pil_en_W_R0A => sl_W_R0A, 
			pil_en_W_R0B => sl_W_R0B, 
			piv_R0       => sv_R0_in, 
			pov_R0       => sv_R0_out 
		);	
	---
	
	--signals sent to BUS from GPR0 Module (priority)
	sv_BUS_GPR0 <= sv_R0_out;
	
	--
	inst_GPR1 : entity work.GPR_type1
		port map(
			pil_reset    => pil_reset,
			pil_clk      => pil_clk,  
			pil_en_R_R0  => sl_R_R1,  
			pil_en_R_R0A => sl_R_R1A, 
			pil_en_R_R0B => sl_R_R1B, 
			pil_en_W_R0  => sl_W_R1,  
			pil_en_W_R0A => sl_W_R1A, 
			pil_en_W_R0B => sl_W_R1B, 
			piv_R0       => sv_R1_in, 
			pov_R0       => sv_R1_out 
		);
	---
	
	--signals sent to BUS from GPR1 Module (priority)
	sv_BUS_GPR1 <= sv_R1_out;
	
	--
	inst_GPR2 : entity work.GPR_type1
		port map(
			pil_reset    => pil_reset,
			pil_clk      => pil_clk,  
			pil_en_R_R0  => sl_R_R2,  
			pil_en_R_R0A => sl_R_R2A, 
			pil_en_R_R0B => sl_R_R2B, 
			pil_en_W_R0  => sl_W_R2,  
			pil_en_W_R0A => sl_W_R2A, 
			pil_en_W_R0B => sl_W_R2B, 
			piv_R0       => sv_R2_in, 
			pov_R0       => sv_R2_out 
		);
	---
	
	--signals sent to BUS from GPR2 Module (priority)
	sv_BUS_GPR2 <= sv_R2_out;

	--
	inst_ALU : entity work.ALU
		port map(
			pil_reset       => pil_reset,   
			pil_clk         => pil_clk,     
			piv_AR          => sv_ALU_AR,   
			piv_BR          => sv_ALU_BR,   
			pil_en_bitO     => sl_bitO,     
			pil_en_BIT_OP   => sl_BIT_OP,   
			pil_en_EO       => sl_EO,       
			pil_en_SU       => sl_SU,       
			pil_cbit        => sl_carry_bit,
			pil_en_EO_carry => sl_EO_carry, 
			pov_ALU         => sv_ALU_out,  
			pol_cbit        => sl_cbit,     
			pol_zbit        => sl_zbit      
		);
	---
	
	--signals sent to BUS from ALU (priority)
	sv_BUS_ALU <= sv_ALU_out;
	
	--signals sent to Flag Register from ALU (priority)
	sl_CF_ALU <= sl_cbit;
	sl_ZF_ALU <= sl_zbit;
	
	--
	sv_IR_in <= sv_BUS_data_out;
	inst_IR : entity work.IR
		port map(
			pil_reset   => pil_reset,    
			pil_clk     => pil_clk,      
			pil_en_R_IR => sl_R_IR,      
			pil_en_W_IR => sl_W_IR,      
			piv_IR      => sv_IR_in,     
			pov_IR_Bus  => sv_IR_BUS_out,
			pov_IR_CNU  => sv_IR_CNU_out 
		);
	---

	--signals going to CNU from IR (priority)
	sv_CU_IR  <= sv_IR_CNU_out;
	--signals sent to BUS from IR (priority)
	sv_BUS_IR <= sv_IR_BUS_out;

	--

	--
	inst_PC : entity work.PC
		port map(
			pil_reset => pil_reset,
			pil_clk   => pil_clk,  
			pil_en_CO => sl_CO,    
			pil_en_CE => sl_CE,    
			pil_en_CI => sl_CI,    
			piv_bus   => sv_bus_in,
			pov_bus   => sv_bus_out
		);
	---

	--signals sent to BUS from PC2 (priority)
	sv_BUS_PC <= sv_bus_out;

	--

	--
	inst_OReg : entity work.user_o
		port map(
			pil_reset => pil_reset,      
			pil_clk   => pil_clk,        
			pil_sel   => pil_sel,        
			pil_en_OR => sl_OR,          
			piv_OR    => sv_OR_in,       
			pov_OR    => pov_out_register
		);		
	---

	--
	inst_PORT0 : entity work.user_io
		port map(
			pil_clk            => pil_clk,        
			pil_reset          => pil_reset,      
			pil_en_set_dir     => sl_setdir_port0,
			pil_en_R_port      => sl_R_P0,        
			pil_en_W_port      => sl_W_P0,        
			pil_en_portin      => sl_en_P0in,     
			pil_en_set_portpin => sl_set_P0pin,   
			pil_port           => sv_P0_in,       
			pov_port           => sv_P0_BUS_out,  
			pbv_PORT           => pbv_port0       
		);
	---
	 
	--signals sent to BUS from PORT0 Register (priority)
	sv_BUS_P0 <= sv_P0_BUS_out;
	
	--

	--
	inst_ADD_Data_Bus : entity work.BUS_module
		generic map(
			gi_max_control_signal => gi_max_control_signal
		)
		port map(
			piv_en_control => sv_BUS_x16,
			piv_BUS_RAM    => sv_BUS_RAM,
			piv_BUS_AR     => sv_BUS_AR,
			piv_BUS_ALU    => sv_BUS_ALU,
			piv_BUS_IR     => sv_BUS_IR,
			piv_BUS_PC     => sv_BUS_PC,
			piv_BUS_GPR0   => sv_BUS_GPR0,
			piv_BUS_GPR1   => sv_BUS_GPR1,
			piv_BUS_GPR2   => sv_BUS_GPR2,
			piv_BUS_P0     => sv_BUS_P0,
			piv_BUS_CG     => sv_BUS_CG,
			piv_BUS_SM     => sv_BUS_SM,
			piv_BUS_DM     => sv_BUS_DM,
			piv_BUS_GPR3   => sv_BUS_GPR3,
			piv_BUS_P1     => sv_BUS_P1,
			pil_BUS_Timer0 => sv_BUS_Timer0,
			pil_BUS_LR     => sv_LR_BUS,
			pov_BUS_data   => sv_BUS_data_out
		);
		
	---
	
	--signals going to other components through bus (priority)
	sv_AR_in <= sv_BUS_data_out;
	sv_BR_in <= sv_BUS_data_out;
	sv_R0_in <= sv_BUS_data_out;
	sv_R1_in <= sv_BUS_data_out;
	sv_R2_in <= sv_BUS_data_out;
	sv_P0_in <= sv_BUS_data_out;
	sv_T0_in <= sv_BUS_data_out(7 downto 0);
	sv_SM_in <= sv_BUS_data_out;
	sv_R3_in <= sv_BUS_data_out;
	sv_DM_in <= sv_BUS_data_out;
	sv_P1_in <= sv_BUS_data_out;
	sv_LR_in <= sv_BUS_data_out;

	sv_bus_in <= sv_BUS_data_out;
	
	--
	
	control_flag : entity work.general_flag
		port map(
			pil_reset      => pil_reset,
			pil_clk        => pil_clk,
			pil_en_Flag_CU => sl_en_flag_CU,
			pil_en_TCOV    => sl_en_TCOV,
			pil_CF_ALU     => sl_CF_ALU,
			pil_ZF_ALU     => sl_ZF_ALU,
			pil_TF0_T0     => sl_TF0_T0,
			pil_TOV        => sl_TOV,
			pol_flag_CF    => sl_flag_CF,
			pol_flag_ZF    => sl_flag_ZF,
			pol_flag_TF0   => sl_flag_TF0,
			pol_TOV        => sl_TOV_out
		);
	
	--signals going to CU from Flag_Register (priority)
	sl_carry_bit   <= sl_flag_CF;
	sl_cf_CU_Flag  <= sl_flag_CF;
	sl_zf_CU_Flag  <= sl_flag_ZF;
	sl_tf0_CU_Flag <= sl_flag_TF0;
	sl_TOV_CU_Flag <= sl_TOV_out;
	
	
	Timer_Counter0 : entity work.timer
		port map(
			pil_clk          => pil_clk,
			pil_reset        => pil_reset,
			pil_en_TH        => sl_TH0,
			pil_en_TL        => sl_TL0,
			pil_CS           => sl_CS0,
			pil_en_T         => sl_T0,
			pil_en_TR        => sl_TR0,
			pil_en_TCR       => sl_en_counter,
			pil_TC_L         => sv_counter_L_out,
			pil_TC_H         => sv_counter_H_out,
			pil_load_counter => sl_load_counter,
			pov_T_BUS_input  => sv_T0_in,
			pov_Timer_out    => sv_timer_out,
			pol_TF_Flag      => sl_TF0_out,
			pol_TOV_Flag     => sl_timer_overflow
		);
	
	--signals going to Flag Register from Timer0_Register (priority)
	sl_TF0_T0 <= sl_TF0_out;
	sl_TOV    <= sl_timer_overflow;
	sv_BUS_Timer0 <= sv_timer_out;

	--		
	inst_CG : entity work.CG
		port map(
			pil_reset   => pil_reset,
			pil_clk     => pil_clk,  
			pil_en_CG0  => sl_CG0,   
			pil_en_CG1  => sl_CG1,   
			pil_en_CGB2 => sl_CGB2,  
			pil_en_CGB1 => sl_CGB1,  
			pil_en_CGB0 => sl_CGB0,  
			pov_CG      => sv_CG_out 
		);		
	---
	
	--signals going to BUS from Constant Generator (priority)
	sv_BUS_CG <= sv_CG_out;

	--
	inst_Stack_Memory : entity work.SM
		port map(
			pil_reset   => pil_reset,
			pil_clk     => pil_clk,  
			pil_en_SM_R => sl_SM_R,  
			pil_en_SM_W => sl_SM_W,  
			piv_SM      => sv_SM_in, 
			pov_SM      => sv_SM_out 
		);
	---
	
	--signals going to the BUS from the Stack Memory (priority)
	sv_BUS_SM <= sv_SM_out;
	
	--
	inst_GPR3 : entity work.GPR_type2
		port map(
			pil_reset   => pil_reset,
			pil_clk     => pil_clk,  
			pil_en_R_G2 => sl_R_R3,  
			pil_en_W_G2 => sl_W_R3,  
			piv_G2      => sv_R3_in, 
			pov_G2      => sv_R3_out 
		);		
	---
	
	--signals going to BUS from GPR3 Module (priority)
	sv_BUS_GPR3 <= sv_R3_out;
	
	--
	inst_DM : entity work.GPR_type2
		port map(
			pil_reset   => pil_reset,
			pil_clk     => pil_clk,  
			pil_en_R_G2 => sl_R_DM,  
			pil_en_W_G2 => sl_W_DM,  
			piv_G2      => sv_DM_in, 
			pov_G2      => sv_DM_out 
		);
	---
	
	--signals going to BUS from DM Module (priority)
	sv_BUS_DM <= sv_DM_out;
	
	--
	inst_link_Register : entity work.GPR_type2
		port map(
			pil_reset   => pil_reset,
			pil_clk     => pil_clk,
			pil_en_R_G2 => sl_en_R_LR,
			pil_en_W_G2 => sl_en_W_LR,
			piv_G2      => sv_LR_in,
			pov_G2      => sv_LR_out
		);
	---
	
	--signals going to BUS from link Register (priority)
	sv_LR_BUS <= sv_LR_out;
	
	--
	inst_PORT1 : entity work.user_io
		port map(
			pil_clk            => pil_clk,      
			pil_reset          => pil_reset,    
			pil_en_set_dir     => sl_setdir_P1, 
			pil_en_R_port      => sl_R_P1,      
			pil_en_W_port      => sl_W_P1,      
			pil_en_portin      => sl_en_P1in,   
			pil_en_set_portpin => sl_set_P1pin, 
			pil_port           => sv_P1_in,     
			pov_port           => sv_P1_BUS_out,
			pbv_PORT           => pbv_port1     
		);
	---
	
	--signals going to BUS from PORT1 Register (priority)
	sv_BUS_P1 <= sv_P1_BUS_out;
	
	--

	inst_Core_fsm : entity work.control_fsm
		generic map(
			gi_max_control_signal => gi_max_control_signal
		)
		port map(
			pil_reset          => pil_reset,
			pil_clk            => pil_clk,
			pil_run_prog       => pil_run_prog,
			pil_halt_CU        => sl_halt_CU,
			pov_CU_IR          => sv_CU_IR,
			pil_CF_flag        => sl_cf_CU_Flag,
			pil_ZF_flag        => sl_zf_CU_Flag,
			pil_TF0_flag       => sl_tf0_CU_Flag,
			pil_TOV_flag       => sl_TOV_CU_Flag,
			pov_en_control_sig => sv_control_signals_out
		);
	
	--signals goint to other modules from CU (priority)
	
	sl_en_R_LR       <= sv_control_signals_out(74);
	sl_en_W_LR       <= sv_control_signals_out(73);
	sl_load_counter  <= sv_control_signals_out(72);
	sl_en_TCOV       <= sv_control_signals_out(71);
	sl_en_counter    <= sv_control_signals_out(70);
	sv_counter_H_out <= sv_control_signals_out(69);
	sv_counter_L_out <= sv_control_signals_out(68);
	sl_EO_carry      <= sv_control_signals_out(67);
	sl_set_P1pin     <= sv_control_signals_out(66);
	sl_en_P1in       <= sv_control_signals_out(65);
	sl_W_P1          <= sv_control_signals_out(64);
	sl_R_P1          <= sv_control_signals_out(63);
	sl_setdir_P1     <= sv_control_signals_out(62);
	sl_W_carry       <= sv_control_signals_out(61);
	sl_R_carry       <= sv_control_signals_out(60);
	sl_AR_OP1        <= sv_control_signals_out(59);
	sl_AR_OP0        <= sv_control_signals_out(58);
	sl_rotate        <= sv_control_signals_out(57);
	sl_W_R3          <= sv_control_signals_out(56);
	sl_R_R3          <= sv_control_signals_out(55);
	sl_W_DM          <= sv_control_signals_out(54);
	sl_R_DM          <= sv_control_signals_out(53);
	sl_set_P0pin     <= sv_control_signals_out(52);
	sl_en_P0in       <= sv_control_signals_out(51);
	sl_setdir_port0  <= sv_control_signals_out(50);
	sl_SM_W          <= sv_control_signals_out(49);
	sl_SM_R          <= sv_control_signals_out(48);
	sl_CGB2          <= sv_control_signals_out(47);
	sl_CGB1          <= sv_control_signals_out(46);
	sl_CGB0          <= sv_control_signals_out(45);
	sl_CG1           <= sv_control_signals_out(44);
	sl_CG0           <= sv_control_signals_out(43);
	sl_TR0           <= sv_control_signals_out(42);
	sl_T0            <= sv_control_signals_out(41);
	sl_CS0           <= sv_control_signals_out(40);
	sl_TH0           <= sv_control_signals_out(39);
	sl_TL0           <= sv_control_signals_out(38);
	sl_BIT_OP        <= sv_control_signals_out(37);
	sl_bitO          <= sv_control_signals_out(36);
	sl_R_P0          <= sv_control_signals_out(35);
	sl_W_P0          <= sv_control_signals_out(34);
	sl_R_R2          <= sv_control_signals_out(33);
	sl_R_R2A         <= sv_control_signals_out(32);
	sl_R_R2B         <= sv_control_signals_out(31);
	sl_W_R2          <= sv_control_signals_out(30);
	sl_W_R2A         <= sv_control_signals_out(29);
	sl_W_R2B         <= sv_control_signals_out(28);
	sl_R_R1          <= sv_control_signals_out(27);
	sl_R_R1A         <= sv_control_signals_out(26);
	sl_R_R1B         <= sv_control_signals_out(25);
	sl_W_R1          <= sv_control_signals_out(24);
	sl_W_R1A         <= sv_control_signals_out(23);
	sl_W_R1B         <= sv_control_signals_out(22);
	sl_halt_CU       <= sv_control_signals_out(21);
	sl_MAR           <= sv_control_signals_out(20);
	sl_R_RAM         <= sv_control_signals_out(19);
	sl_W_RAM         <= sv_control_signals_out(18);
	sl_W_IR          <= sv_control_signals_out(17);
	sl_R_IR          <= sv_control_signals_out(16);
	sl_R_AR          <= sv_control_signals_out(15);
	sl_W_AR          <= sv_control_signals_out(14);
	sl_EO            <= sv_control_signals_out(13);
	sl_SU            <= sv_control_signals_out(12);
	sl_R_BR          <= sv_control_signals_out(11);
	sl_OR            <= sv_control_signals_out(10);
	sl_CE            <= sv_control_signals_out(9);
	sl_CO            <= sv_control_signals_out(8);
	sl_CI            <= sv_control_signals_out(7);
	sl_en_flag_CU    <= sv_control_signals_out(6);
	sl_R_R0          <= sv_control_signals_out(5);
	sl_R_R0A         <= sv_control_signals_out(4);
	sl_R_R0B         <= sv_control_signals_out(3);
	sl_W_R0          <= sv_control_signals_out(2);
	sl_W_R0A         <= sv_control_signals_out(1);
	sl_W_R0B         <= sv_control_signals_out(0);

	--signals sent to BUS from CU (priority)
	sv_BUS_x16 <= sv_control_signals_out;

end core_a;