--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:24:12 10/15/2020
-- Design Name:   
-- Module Name:   C:/Users/chakr/OneDrive/Documents/VHDL Programming/Computer_Architecture_v3.12/tb_top_level_v5_1.vhd
-- Project Name:  Computer_Architecture_v3.12
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Top_Leve_e
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_top_level_v5_1 IS
END tb_top_level_v5_1;
 
ARCHITECTURE behavior OF tb_top_level_v5_1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component pearl_top
    	generic(
    		gc_bd                 : integer;
    		gc_clk_fz             : integer;
    		gi_max_control_signal : integer
    	);
    	port(
    		pil_reset    : in    std_logic;
    		pil_clk      : in    std_logic;
    		pil_sel      : in    std_logic;
    		pil_run_prog : in    std_logic;
    		pil_rx       : in    std_logic;
    		pov_OR       : out   std_logic_vector(7 downto 0);
    		pbv_P0       : inout std_logic_vector(7 downto 0);
    		pbv_P1       : inout std_logic_vector(7 downto 0)
    	);
    end component pearl_top;
    

   --Inputs
   signal rb_i : std_logic := '1';
   signal clk_i : std_logic := '0';
   signal sel_i : std_logic := '0';
   signal run_prog_i : std_logic := '0';
   signal rx_i : std_logic := '1';

	--BiDirs
   signal P0_o : std_logic_vector(7 downto 0);
   signal P1_o : std_logic_vector(7 downto 0);

 	--Outputs
   signal x8_OR_o : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 20 ns;
	constant c_bd_pulse  : integer := 5208;
	constant c_bd_period  : time := 104166 ns;
	
	procedure Input_Serial_char (
		char_data_i       : in  std_logic_vector(7 downto 0);
		signal make_serial_o : out std_logic) is
		begin

		-- Send Start Bit
		make_serial_o <= '0';
		wait for c_bd_period ;

		-- Send Data Byte
		for ii in 0 to 7 loop
			make_serial_o <= char_data_i(ii);
			wait for c_bd_period ;
		end loop;  -- ii

		-- Send Stop Bit
		make_serial_o <= '1';
		wait for c_bd_period ;
	end Input_Serial_char;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pearl_top
   	generic map(
   		gc_bd => 9600,
   		gc_clk_fz => 50_000_000,
   		gi_max_control_signal => 74
   	)
   PORT MAP (
          pil_reset => rb_i,
          pil_clk => clk_i,
          pil_sel => sel_i,
          pil_run_prog => run_prog_i,
          pil_rx => rx_i,
          pov_OR => x8_OR_o,
          pbv_P0 => P0_o,
          pbv_P1 => P1_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		wait for clk_i_period / 2;
		rb_i <= '0';
		
		wait for clk_i_period;
		sel_i <= '1';
		
		wait for 2 * clk_i_period;

---------------------------------------------------------------------------
--
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"10" , rx_i);
--		wait until rising_edge(clk_i);
--
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"05" , rx_i);
--		wait until rising_edge(clk_i);
--
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"ff" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"a3" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"11" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"05" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"c7" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"08" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"08" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"05" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"06" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"0e" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"0f" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		--------
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"06" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"08" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"05" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"0a" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"0e" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"0f" , rx_i);
--		wait until rising_edge(clk_i);
--		
--		wait until rising_edge(clk_i);
--		Input_Serial_char(X"00" , rx_i);
--		wait until rising_edge(clk_i);
--		---


---------------------------------------------------------------------------

		wait until rising_edge(clk_i);
		Input_Serial_char(X"10" , rx_i);
		wait until rising_edge(clk_i);

		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"05" , rx_i);
		wait until rising_edge(clk_i);

		wait until rising_edge(clk_i);
		Input_Serial_char(X"fc" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"a4" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"d7" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"11" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"05" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"b8" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"da" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"18" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"07" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0a" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"05" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"06" , rx_i);
		wait until rising_edge(clk_i);
		
		--------
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0a" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"08" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0e" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0f" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"05" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0a" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0e" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"0f" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		---
		

		---			
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"00" , rx_i);
		wait until rising_edge(clk_i);
		
		wait until rising_edge(clk_i);
		Input_Serial_char(X"01" , rx_i);
		wait until rising_edge(clk_i);
		
		wait for 10 * clk_i_period;
		sel_i <= '0';
		
		wait for clk_i_period;
		rb_i <= '1';
		
		wait for clk_i_period;
		rb_i <= '0';
		
		wait for clk_i_period;
		run_prog_i <= '1';
		
		wait for clk_i_period;
		--P0_o (1) <= '1';
		
		wait for 1 ms;
		
		wait for clk_i_period;
		run_prog_i <= '0';
		
		wait for clk_i_period;
		
		assert (false) report "END OF SIMULATION!!" severity failure;
   end process;

END;
