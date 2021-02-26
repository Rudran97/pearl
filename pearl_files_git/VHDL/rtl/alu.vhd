----------------------------------------------------------------------------------
-- Hochschule Ravensburg-Weingarten 
-- Author: Rudran Chakraborty 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.alu_p.all;

entity ALU is
	port (pil_reset       : in  std_logic;
	     pil_clk         : in  std_logiC;
	     piv_AR          : in  std_logic_vector(7 downto 0);
	     piv_BR          : in  std_logic_vector(7 downto 0);
	     pil_en_bitO     : in  std_logic;
	     pil_en_BIT_OP   : in  std_logic; -- '0' -> SET, '1' -> CLR
	     pil_en_EO       : in  std_logic;
	     pil_en_SU       : in  std_logic;
	     pil_cbit        : in  std_logic;
	     pil_en_EO_carry : in  std_logic; -- arithmetic operation with carry
	     pov_ALU         : out std_logic_vector(15 downto 0);
	     pol_cbit        : out std_logic;
	     pol_zbit        : out std_logic
	     );
end ALU;


architecture rtl of ALU is
	
	signal sv_sum : std_logic_vector (7 downto 0);
	
begin
	
	process (pil_reset, pil_clk)
	
		variable vv_2BR : std_logic_vector (7 downto 0); --- 2's complement of BR
		variable vv_AR  : std_logic_vector (7 downto 0);
    	variable vv_BR  : std_logic_vector (7 downto 0);
    	variable vv_2nC : std_logic_vector (7 downto 0); --- 2's complement of inverted Carry for SUBB calculation
    	variable vv_2C  : std_logic_vector (7 downto 0); --- 2's complement of carry
    	
    	variable vv_subb_intermediate : std_logic_vector (7 downto 0); --- holds A - B
    	variable vv_arith_operation : std_logic_vector (1 downto 0);
	
	begin
		if (pil_reset = '1') then
			sv_sum               <= (others => '0');
			pol_cbit             <= '0';
			pol_zbit             <= '0';
			vv_2nC                := (others => '0');
			vv_subb_intermediate := (others => '0');
			vv_arith_operation   := "00";
		elsif (pil_clk'event and pil_clk = '1') then
			if (pil_en_EO = '1') then
				vv_AR := piv_AR;
				vv_BR := piv_BR;
				vv_arith_operation := pil_en_EO_carry & pil_en_SU;
				case vv_arith_operation is
					when "00" =>
						sv_sum   <= fv_carry_ripple_adder(vv_AR, vv_BR, '0');
						pol_cbit <= fl_check_carry(vv_AR, vv_BR, '0');
						vv_2BR   := fv_carry_ripple_adder((not vv_BR), "00000000", '1');
						pol_zbit <= fl_check_zero(vv_AR, vv_2BR, '0');
					when "01" =>
						vv_2BR   := fv_carry_ripple_adder((not vv_BR), "00000000", '1');
						sv_sum   <= fv_carry_ripple_adder(vv_AR, vv_2BR, '0');
						pol_cbit <= fl_check_carry(vv_AR, vv_2BR, '0');
						pol_zbit <= fl_check_zero(vv_AR, vv_2BR, '0');
					when "10" =>
						sv_sum   <= fv_carry_ripple_adder(A => vv_AR, B => vv_BR, carry_in => pil_cbit);
						pol_cbit <= fl_check_carry(A => vv_AR, B => vv_BR, carry_in => pil_cbit);
						vv_2BR   := fv_carry_ripple_adder((not vv_BR), "00000000", '1');
						pol_zbit <= fl_check_zero(vv_AR, vv_2BR, pil_cbit);
					when "11" =>
						vv_2BR               := fv_carry_ripple_adder(A => not vv_BR, B => "00000000", carry_in => '1');
						vv_2nC               := fv_carry_ripple_adder(A => "1111111" & pil_cbit, B => "00000000", carry_in => '1'); --- if the cbit of previous instruction
																																    --- is '0' i.e when last subtraction yield a negative
																																    --- result then the cbit is sent as '1' to perfrom the subb instruction.
						vv_2C				 := fv_carry_ripple_adder(A => not ("0000000" & pil_cbit), B => "00000000", carry_in => '1');
						vv_subb_intermediate := fv_carry_ripple_adder(A => vv_AR, B => vv_2BR, carry_in => '0');
						sv_sum               <= fv_carry_ripple_adder(A => vv_subb_intermediate, B => vv_2nC, carry_in => '0');
						pol_cbit             <= fl_check_carry(vv_subb_intermediate, vv_2C, '0');
						pol_zbit             <= fl_check_zero(vv_subb_intermediate, vv_2C, '0');
					when others =>
						sv_sum <= (others => '0');
						pol_cbit <= '0';
						pol_zbit <= '0';
				end case;
			else
				sv_sum <= (others => '0');
				pol_cbit <= '0';
				pol_zbit <= '0';
			end if;
			
			if (pil_en_bitO = '1') then
				vv_AR := piv_AR;
				vv_BR := piv_BR;
				case pil_en_BIT_OP is
					when '0' =>
						sv_sum <= vv_AR or vv_BR;
					when '1' =>
						sv_sum <= vv_AR and (not vv_BR);
					when others =>
						sv_sum <= (others => '0');
						pol_cbit <= '0';
						pol_zbit <= '0';
				end case;
			end if;
		end if;
	end process;
	pov_ALU <= "00000000" & sv_sum;
			
end rtl;