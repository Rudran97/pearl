----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pearl_top is
	generic	(gc_bd : integer := 9600;
			 gc_clk_fz : integer := 35_000_000;   --- Set the clock speed
			 gi_max_control_signal : integer := 74
	);
	port (pil_reset     : in    std_logic;
	     pil_clk_12MHz : in    std_logic;
	     pil_sel       : in    std_logic;
	     pil_run_prog  : in    std_logic;
	     pil_rx        : in    std_logic;
	     pov_OR        : out   std_logic_vector(7 downto 0);
	     pbv_P0        : inout std_logic_vector(7 downto 0);
	     pbv_P1        : inout std_logic_vector(7 downto 0)
	    );
end pearl_top;


architecture rtl of pearl_top is
	
--	--signals declared for function controller Module--
--	signal pol_run : std_logic;
	
	--signals declared for Programmer Interface Module--
	signal sl_PI_ISP : std_logic;
	signal sv_char_out : std_logic_vector(7 downto 0);

	--signals declared for External Programmer Module--
	signal sl_ISP_PI      : std_logic;
	signal sv_data_in        : std_logic_vector(7 downto 0);
	signal sl_write_data     : std_logic;
	signal sv_ISP_MAR : std_logic_vector(15 downto 0);
	signal sv_ISP_RAM : std_logic_vector(15 downto 0);

	--signals going declared in core_top--
	signal sl_buffer           : std_logic;
	signal sv_address_buffer : std_logic_vector(15 downto 0);
	signal sv_data_buffer    : std_logic_vector(15 downto 0);
	--signal sl_run			 : std_logic;
	
	signal sl_pll_co : std_logic;
	signal sl_nrst   : std_logic;
	
begin
	
--	inst_function_controller : entity work.function_controller
--		port map(
--			pil_clk   => pil_clk,
--			pil_reset => pil_reset,
--			pil_sel   => pil_sel,
--			pol_run   => pol_run
--		);

	sl_nrst <= not pil_reset;
	
	inst_pll : entity work.cyc1000_pll
		port map(
			areset => sl_nrst,
			inclk0 => pil_clk_12MHz,
			c0     => sl_pll_co
		);
	
	--
	inst_Programmer_inteface : entity work.PI
		generic map(
			gc_bd     => gc_bd,   
			gc_clk_fz => gc_clk_fz
		)
		port map(
			pil_clk         => sl_pll_co,   
			pil_reset       => sl_nrst, 
			pil_rx          => pil_rx,    
			pol_en_PI_ExtPg => sl_PI_ISP, 
			pov_char_out    => sv_char_out
		);
	---

	sl_ISP_PI  <= sl_PI_ISP;
	sv_data_in <= sv_char_out;

	--
	inst_ISP : entity work.ISP
		port map(
			pil_clk           => sl_pll_co,      
			pil_reset         => sl_nrst,    
			pil_sel           => pil_sel,      
			pil_en_PI         => sl_ISP_PI,    
			piv_data          => sv_data_in,   
			pol_en_write_data => sl_write_data,
			pov_MAR           => sv_ISP_MAR,   
			pov_RAM           => sv_ISP_RAM    
		);
	---
	
	sl_buffer         <= sl_write_data;
	sv_address_buffer <= sv_ISP_MAR;
	sv_data_buffer    <= sv_ISP_RAM;

	--sl_run <= pol_run;
	core_architecture_top : entity work.core_e
		generic map(
			gi_max_control_signal => gi_max_control_signal
		)
		port map(
			pil_clk          => sl_pll_co,
			pil_reset        => sl_nrst,
			pil_en_buffer    => sl_buffer,
			piv_address_in   => sv_address_buffer,
			piv_data_in      => sv_data_buffer,
			pil_sel          => pil_sel,
			pil_run_prog     => pil_run_prog,
			pov_out_register => pov_OR,
			pbv_port0        => pbv_P0,
			pbv_port1        => pbv_P1
		);

end rtl;
