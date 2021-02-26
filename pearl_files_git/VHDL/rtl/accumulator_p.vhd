library IEEE;
use IEEE.STD_LOGIC_1164.all;

package accumulator_p is
	
	function fv_rotate_Accumulator(Accumulator       : std_logic_vector (7 downto 0);
	                               rotate_by         : integer range 0 to 7;
	                               carry, rotate_dir : std_logic)
	return std_logic_vector;
	
end accumulator_p;

package body accumulator_p is

	-- Rotate Accumulator
	function fv_rotate_Accumulator(Accumulator       : std_logic_vector (7 downto 0);
	                               rotate_by         : integer range 0 to 7;
	                               carry, rotate_dir : std_logic)
	return std_logic_vector is

		variable vv_rotate : std_logic_vector(7 downto 0);

	begin
		vv_rotate := Accumulator;
		for i in 0 to 7 loop
			exit when i = rotate_by;
			if (rotate_dir = '0') then
				vv_rotate(7 downto 1) := vv_rotate(6 downto 0);
				vv_rotate(0)          := carry;
			else
				vv_rotate(6 downto 0) := vv_rotate(7 downto 1);
				vv_rotate(7)          := carry;
			end if;
		end loop;
		return vv_rotate;
	end function;

end accumulator_p;
