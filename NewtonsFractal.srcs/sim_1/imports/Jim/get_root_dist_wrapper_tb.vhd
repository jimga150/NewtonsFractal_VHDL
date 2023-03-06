----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/05/2023 22:14:24
-- Design Name: get_root_dist_wrapper_tb
-- Module Name: get_root_dist_wrapper_tb - Behavioral
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
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity get_root_dist_wrapper_tb is
end get_root_dist_wrapper_tb;

architecture Behavioral of get_root_dist_wrapper_tb is
	
	--Clocks
	signal aclk_0 : STD_LOGIC := '0';
	
	--Resets
	signal aresetn_0 : STD_LOGIC := '0';
	
	--General inputs
	signal S_AXIS_ROOT_X_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal s_root_x_real : real := 0.0;
	signal S_AXIS_ROOT_X_tvalid : STD_LOGIC := '0';
	signal S_AXIS_ROOT_Y_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal s_root_y_real : real := 0.0;
	signal S_AXIS_ROOT_Y_tvalid : STD_LOGIC := '0';
	signal S_AXIS_X_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal s_x_real : real := 0.0;
	signal S_AXIS_X_tvalid : STD_LOGIC := '0';
	signal S_AXIS_Y_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal s_y_real : real := 0.0;
	signal S_AXIS_Y_tvalid : STD_LOGIC := '0';
	
	--Outputs
	signal M_AXIS_RESULT_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal s_result_real : real;
	signal M_AXIS_RESULT_tvalid : STD_LOGIC;
	
	--Clock Periods
	constant aclk_0_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_x_inputs, s_y_inputs : t_real_arr(c_num_tests downto 1);
	
begin

    S_AXIS_ROOT_X_tdata <= parse_double_from_real(s_root_x_real);
    S_AXIS_ROOT_Y_tdata <= parse_double_from_real(s_root_y_real);
    S_AXIS_X_tdata <= parse_double_from_real(s_x_real);
    S_AXIS_Y_tdata <= parse_double_from_real(s_y_real);
    
    s_result_real <= parse_real_from_double(M_AXIS_RESULT_tdata);
	
	UUT: entity work.get_root_dist_wrapper
	port map(
		aclk_0 => aclk_0,
		aresetn_0 => aresetn_0,
		M_AXIS_RESULT_tdata => M_AXIS_RESULT_tdata,
		M_AXIS_RESULT_tvalid => M_AXIS_RESULT_tvalid,
		S_AXIS_ROOT_X_tdata => S_AXIS_ROOT_X_tdata,
		S_AXIS_ROOT_X_tvalid => S_AXIS_ROOT_X_tvalid,
		S_AXIS_ROOT_Y_tdata => S_AXIS_ROOT_Y_tdata,
		S_AXIS_ROOT_Y_tvalid => S_AXIS_ROOT_Y_tvalid,
		S_AXIS_X_tdata => S_AXIS_X_tdata,
		S_AXIS_X_tvalid => S_AXIS_X_tvalid,
		S_AXIS_Y_tdata => S_AXIS_Y_tdata,
		S_AXIS_Y_tvalid => S_AXIS_Y_tvalid
	);
	
	--Clock Drivers
	aclk_0 <= not aclk_0 after aclk_0_period/2;
	
	stim_proc: process is
        variable v_seed1, v_seed2 : positive;
        variable v_rnd : real;
	begin
		
		wait for aclk_0_period*3;
		
		aresetn_0 <= '1';
		
		wait for aclk_0_period*2;
		
		--Insert stimuli here
		
		uniform(v_seed1, v_seed2, v_rnd);
        s_root_x_real <= v_rnd + 1.0;
        S_AXIS_ROOT_X_tvalid <= '1';
        uniform(v_seed1, v_seed2, v_rnd);
        s_root_y_real <= v_rnd + 1.0;
        S_AXIS_ROOT_Y_tvalid <= '1';
        
        S_AXIS_X_tvalid <= '1';
		S_AXIS_Y_tvalid <= '1';
		
		for i in 1 to c_num_tests loop
            
            uniform(v_seed1, v_seed2, v_rnd);
            s_x_real <= v_rnd;
            s_x_inputs(i) <= v_rnd;
            uniform(v_seed1, v_seed2, v_rnd);
            s_y_real <= v_rnd;
            s_y_inputs(i) <= v_rnd;
            
            wait for aclk_0_period;
            
		end loop;
		
		S_AXIS_X_tvalid <= '0';
		S_AXIS_Y_tvalid <= '0';
		
        if (M_AXIS_RESULT_tvalid = '1') then
            wait until M_AXIS_RESULT_tvalid = '0';
        else
            wait until M_AXIS_RESULT_tvalid = '1';
            wait until M_AXIS_RESULT_tvalid = '0';
        end if;
		
		wait for aclk_0_period;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	
	check_result_proc: process is
	   
	   variable v_expected_result : std_logic_vector(M_AXIS_RESULT_tdata'range);
	   variable v_expected_result_real : real;
	   
	   variable v_root_diff_x, v_root_diff_y : real;
	   variable v_diff2_x, v_diff2_y : real;
	   variable v_square_sum : real;
	   
	begin
	   
        for i in 1 to c_num_tests loop
        
            if (M_AXIS_RESULT_tvalid /= '1') then
                wait until M_AXIS_RESULT_tvalid = '1';
                wait for aclk_0_period/2;
            end if;
            
            v_root_diff_x := s_x_inputs(i) - s_root_x_real;
            v_root_diff_y := s_y_inputs(i) - s_root_y_real;
            
            v_diff2_x := v_root_diff_x*v_root_diff_x;
            v_diff2_y := v_root_diff_y*v_root_diff_y;
            
            v_square_sum := v_diff2_x + v_diff2_y;
            
            v_expected_result_real := sqrt(v_square_sum);
            
            report "v_root_diff_x = " & to_string(v_root_diff_x) severity note;
            report "v_root_diff_y = " & to_string(v_root_diff_y) severity note;
            report "v_diff2_x = " & to_string(v_diff2_x) severity note;
            report "v_diff2_y = " & to_string(v_diff2_y) severity note;
            report "v_square_sum = " & to_string(v_square_sum) severity note;
            report "v_expected_result_real = " & to_string(v_expected_result_real) severity note;
            
            v_expected_result := parse_double_from_real(v_expected_result_real);
            
            assert abs(s_result_real - v_expected_result_real) < 0.0001
                report "Mismatched result: expected 0x" & 
                to_hstring(v_expected_result) & 
                " (" & to_string(v_expected_result_real) & "), got 0x" & 
                to_hstring(M_AXIS_RESULT_tdata) & " (" & to_string(s_result_real) & ")"
                severity failure;
            
            wait for aclk_0_period;
        
        end loop;
	   	   
	end process;

end Behavioral;
