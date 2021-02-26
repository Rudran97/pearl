library IEEE;
use IEEE.STD_LOGIC_1164.all;

package alu_p is

	-- Adder function
	function fv_carry_ripple_adder (A, B : std_logic_vector (7 downto 0);
									carry_in : std_logic
									)
	return std_logic_vector;
	
	-- to set/clear carry bit
	function fl_check_carry (A, B : std_logic_vector (7 downto 0);
							 carry_in : std_logic
							 )
	return std_logic;
	
	-- to set/clear zero bit
	function fl_check_zero (A, B : std_logic_vector (7 downto 0);
							carry_in : std_logic
							)
	return std_logic;
	
end alu_p;

package body alu_p is

	-- Adder function
	function fv_carry_ripple_adder (A, B : std_logic_vector (7 downto 0);
									carry_in : std_logic
									)
	return std_logic_vector is

		variable vv_carry : std_logic_vector (8 downto 0) := "00000000" & carry_in;
		variable vv_sum   : std_logic_vector (7 downto 0);

	begin
		for i in 0 to 7 loop
			vv_sum (i) := A (i) xor B (i) xor vv_carry (i);
			vv_carry (i+1) := (A (i) and B (i)) or (B (i) and vv_carry (i)) or (vv_carry (i) and A (i));
		end loop;
		vv_carry := (others => '0');
		return vv_sum;
	end function;

	-- to set/clear carry bit
	function fl_check_carry (A, B : std_logic_vector (7 downto 0);
							 carry_in : std_logic
							 )
	return std_logic is

		variable vv_carry_f2 : std_logic_vector (8 downto 0) := "00000000" & carry_in;
		variable vv_sum_f2   : std_logic_vector (7 downto 0);

	begin
		for i in 0 to 7 loop
			vv_sum_f2 (i) := A (i) xor B (i) xor vv_carry_f2 (i);
			vv_carry_f2 (i+1) := (A (i) and B (i)) or (B (i) and vv_carry_f2 (i)) or (vv_carry_f2 (i) and A (i));
		end loop;
		return vv_carry_f2 (8);
	end function;

	-- to set/clear zero bit
	function fl_check_zero (A, B : std_logic_vector (7 downto 0);
							carry_in : std_logic
							)
	return std_logic is

		variable vv_carry_f3 : std_logic_vector (8 downto 0) := "00000000" & carry_in;
		variable vv_sum_f3   : std_logic_vector (7 downto 0);
		variable vl_zero_bit : std_logic;

	begin
		for i in 0 to 7 loop
			vv_sum_f3 (i) := A (i) xor B (i) xor vv_carry_f3 (i);
			vv_carry_f3 (i+1) := (A (i) and B (i)) or (B (i) and vv_carry_f3 (i)) or (vv_carry_f3 (i) and A (i));
		end loop;
		
		vl_zero_bit := not (vv_sum_f3 (7) or vv_sum_f3 (6) or vv_sum_f3 (5) or vv_sum_f3 (4) or vv_sum_f3 (3) or vv_sum_f3 (2) or vv_sum_f3 (1) or vv_sum_f3 (0));
		return vl_zero_bit;
	end function;

end alu_p;
