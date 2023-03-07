----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 20:51:08
-- Design Name: rootfind_iteration_tb
-- Module Name: rootfind_iteration_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Created with VHDL Test Bench Template Generator
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
use work.type_pkg.all;

entity rootfind_iteration_tb is
end rootfind_iteration_tb;

architecture Behavioral of rootfind_iteration_tb is
	
	--Generics
	constant g_num_roots : integer := 5;
	
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_arstn : std_logic := '0';
	
	--General inputs
	signal i_root_xs : t_double_arr(g_num_roots-1 downto 0);
	signal i_root_ys : t_double_arr(g_num_roots-1 downto 0);
	
	signal s_root_x_reals, s_root_y_reals : t_real_arr(i_root_xs'range) := (others => 0.0);
	
	signal i_x : std_logic_vector(63 downto 0);
	signal i_y : std_logic_vector(63 downto 0);
	
	signal s_x_real, s_y_real : real := 0.0;
	
	signal i_input_valid : std_logic := '0';
	
	--Outputs
	signal o_x : std_logic_vector(63 downto 0);
	signal o_y : std_logic_vector(63 downto 0);
	
	signal s_x_result_real, s_y_result_real : real := 0.0;
	
	signal o_output_valid : std_logic;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_x_inputs, s_y_inputs : t_real_arr(c_num_tests downto 1);
	
begin

    gen_root_doubles: for i in i_root_xs'range generate
	   i_root_xs(i) <= parse_double_from_real(s_root_x_reals(i));
	   i_root_ys(i) <= parse_double_from_real(s_root_y_reals(i));
	end generate gen_root_doubles;
	
	i_x <= parse_double_from_real(s_x_real);
	i_y <= parse_double_from_real(s_y_real);
	
	s_x_result_real <= parse_real_from_double(o_x);
	s_y_result_real <= parse_real_from_double(o_y);
	
	UUT: entity work.rootfind_iteration
	generic map(
		g_num_roots => g_num_roots
	)
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_root_xs => i_root_xs,
		i_root_ys => i_root_ys,
		i_x => i_x,
		i_y => i_y,
		i_input_valid => i_input_valid,
		o_x => o_x,
		o_y => o_y,
		o_output_valid => o_output_valid
	);
	
	--Clock Drivers
	i_clk <= not i_clk after i_clk_period/2;
	
	stim_proc: process is
        variable v_seed1, v_seed2 : positive;
        variable v_rnd : real;
	begin
		
		wait for i_clk_period*3;
		
		i_arstn <= '1';
		
		wait for i_clk_period*3;
		
		for i in i_root_xs'range loop
		    --move these out of the usual (0, 1] range so that no values will fall on a root
            uniform(v_seed1, v_seed2, v_rnd);
            s_root_x_reals(i) <= v_rnd + 1.0;
            uniform(v_seed1, v_seed2, v_rnd);
            s_root_y_reals(i) <= v_rnd + 1.0;
		end loop;
		
		i_input_valid <= '1';
		
		for i in 1 to c_num_tests loop
            
            uniform(v_seed1, v_seed2, v_rnd);
            s_x_real <= v_rnd;
            s_x_inputs(i) <= v_rnd;
            uniform(v_seed1, v_seed2, v_rnd);
            s_y_real <= v_rnd;
            s_y_inputs(i) <= v_rnd;
            
            wait for i_clk_period;
            
		end loop;
		
		i_input_valid <= '0';
		
        if (o_output_valid /= '1') then
            wait until o_output_valid = '1';
        end if;
        
        wait until o_output_valid = '0';

		wait for i_clk_period;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	check_result_proc: process is
	   
	   variable v_expected_result_x, v_expected_result_y : std_logic_vector(o_x'range);
	   variable v_expected_result_x_real, v_expected_result_y_real : real;
	   
	   variable v_fod_x_real, v_fod_y_real : real;
	   variable v_inverse_fod_x_real, v_inverse_fod_y_real : real;
	   
	   variable v_denominator_x, v_denominator_y : real;
       variable v_squaresum : real;
       variable v_term_x, v_term_y : real;
	   
	begin
	   
        for i in 1 to c_num_tests loop
        
            if (o_output_valid /= '1') then
                wait until o_output_valid = '1';
                wait for i_clk_period/2;
            end if;
            
            v_inverse_fod_x_real := 0.0;
            v_inverse_fod_y_real := 0.0;
            
            for j in s_root_x_reals'range loop
            
                v_denominator_x := s_x_inputs(i) - s_root_x_reals(j);
                v_denominator_y := s_y_inputs(i) - s_root_y_reals(j);
                v_squaresum := v_denominator_x*v_denominator_x + v_denominator_y*v_denominator_y;
                v_term_x := v_denominator_x / v_squaresum;
                v_term_y := -v_denominator_y / v_squaresum;
                v_inverse_fod_x_real := v_inverse_fod_x_real + v_term_x;
                v_inverse_fod_y_real := v_inverse_fod_y_real + v_term_y;

                report "v_denominator_x = " & to_string(v_denominator_x) severity note;
                report "v_denominator_y = " & to_string(v_denominator_y) severity note;
                report "v_squaresum = " & to_string(v_squaresum) severity note;
                report "v_term_x = " & to_string(v_term_x) severity note;
                report "v_term_y = " & to_string(v_term_y) severity note;
                report "v_inverse_fod_x_real = " & to_string(v_inverse_fod_x_real) severity note;
                report "v_inverse_fod_y_real = " & to_string(v_inverse_fod_y_real) severity note;
                
            end loop;
            
            v_squaresum := v_inverse_fod_x_real*v_inverse_fod_x_real + 
                v_inverse_fod_y_real*v_inverse_fod_y_real;
                
            v_fod_x_real := v_inverse_fod_x_real / v_squaresum;
            v_fod_y_real := -v_inverse_fod_y_real / v_squaresum;
            
            v_expected_result_x_real := s_x_inputs(i) - v_fod_x_real;
            v_expected_result_y_real := s_y_inputs(i) - v_fod_y_real;
            
            report "final calculation: v_squaresum = " & to_string(v_squaresum) severity note;
            report "final calculation: v_fod_x_real = " & to_string(v_fod_x_real) severity note;
            report "final calculation: v_fod_y_real = " & to_string(v_fod_y_real) severity note;
            report "final calculation: v_expected_result_x_real = " & to_string(v_expected_result_x_real) severity note;
            report "final calculation: v_expected_result_y_real = " & to_string(v_expected_result_y_real) severity note;
            
            v_expected_result_x := parse_double_from_real(v_expected_result_x_real);
            v_expected_result_y := parse_double_from_real(v_expected_result_y_real);
            
            assert abs(s_x_result_real - v_expected_result_x_real) < 0.0001
                report "Mismatched X result: expected 0x" & 
                to_hstring(v_expected_result_x) & 
                " (" & to_string(v_expected_result_x_real) & "), got 0x" & 
                to_hstring(o_x) & " (" & to_string(s_x_result_real) & ")"
                severity failure;
                
            assert abs(s_y_result_real - v_expected_result_y_real) < 0.0001
                report "Mismatched Y result: expected 0x" & 
                to_hstring(v_expected_result_y) & 
                " (" & to_string(v_expected_result_y_real) & "), got 0x" & 
                to_hstring(o_y) & " (" & to_string(s_y_result_real) & ")"
                severity failure;
            
            wait for i_clk_period;
        
        end loop;
	   	   
	end process;

end Behavioral;
