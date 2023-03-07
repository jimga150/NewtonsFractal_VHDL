----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/05/2023 16:35:11
-- Design Name: pixel_to_coord_wrapper_tb
-- Module Name: pixel_to_coord_wrapper_tb - Behavioral
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

entity pixel_to_coord_wrapper_tb is
end pixel_to_coord_wrapper_tb;

architecture Behavioral of pixel_to_coord_wrapper_tb is
	
	--Clocks
	signal aclk_0 : STD_LOGIC := '0';
	
	--Resets
	signal aresetn_0 : STD_LOGIC := '0';
	
	--General inputs
	signal S_AXIS_IMG_HEIGHT_tdata : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal S_AXIS_IMG_HEIGHT_tvalid : STD_LOGIC := '0';
	signal S_AXIS_IMG_WIDTH_tdata : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal S_AXIS_IMG_WIDTH_tvalid : STD_LOGIC := '0';
	signal S_AXIS_SCALE_DPFLT_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal S_AXIS_SCALE_DPFLT_tvalid : STD_LOGIC := '1';
	signal s_scale_real : real := 1.0;
	signal S_AXIS_X_tdata : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal S_AXIS_X_tvalid : STD_LOGIC := '0';
	signal S_AXIS_Y_tdata : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal S_AXIS_Y_tvalid : STD_LOGIC := '0';
	
	--Outputs
	signal M_AXIS_RESULT_X_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal M_AXIS_RESULT_X_tvalid : STD_LOGIC;
	signal M_AXIS_RESULT_Y_tdata : STD_LOGIC_VECTOR(63 downto 0);
	signal M_AXIS_RESULT_Y_tvalid : STD_LOGIC;
	
	signal s_x_result_real, s_y_result_real : real;
	
	--Clock Periods
	constant aclk_0_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_x_inputs, s_y_inputs : t_int_arr(c_num_tests downto 1);
	
begin

    S_AXIS_SCALE_DPFLT_tdata <= parse_double_from_real(s_scale_real);
    
    s_x_result_real <= parse_real_from_double(M_AXIS_RESULT_X_tdata);
    s_y_result_real <= parse_real_from_double(M_AXIS_RESULT_Y_tdata);
	
	UUT: entity work.pixel_to_coord_wrapper
	port map(
		aclk_0 => aclk_0,
		aresetn_0 => aresetn_0,
		M_AXIS_RESULT_X_tdata => M_AXIS_RESULT_X_tdata,
		M_AXIS_RESULT_X_tvalid => M_AXIS_RESULT_X_tvalid,
		M_AXIS_RESULT_Y_tdata => M_AXIS_RESULT_Y_tdata,
		M_AXIS_RESULT_Y_tvalid => M_AXIS_RESULT_Y_tvalid,
		S_AXIS_IMG_HEIGHT_tdata => S_AXIS_IMG_HEIGHT_tdata,
		S_AXIS_IMG_HEIGHT_tvalid => S_AXIS_IMG_HEIGHT_tvalid,
		S_AXIS_IMG_WIDTH_tdata => S_AXIS_IMG_WIDTH_tdata,
		S_AXIS_IMG_WIDTH_tvalid => S_AXIS_IMG_WIDTH_tvalid,
		S_AXIS_SCALE_DPFLT_tdata => S_AXIS_SCALE_DPFLT_tdata,
		S_AXIS_SCALE_DPFLT_tvalid => S_AXIS_SCALE_DPFLT_tvalid,
		S_AXIS_X_tdata => S_AXIS_X_tdata,
		S_AXIS_X_tvalid => S_AXIS_X_tvalid,
		S_AXIS_Y_tdata => S_AXIS_Y_tdata,
		S_AXIS_Y_tvalid => S_AXIS_Y_tvalid
	);
	
	--Clock Drivers
	aclk_0 <= not aclk_0 after aclk_0_period/2;
	
	stim_proc: process is
	
        variable v_slv_input : std_logic_vector(S_AXIS_X_tdata'range);

	begin
		
		wait for aclk_0_period*3;
		
		aresetn_0 <= '1';
		
		wait for aclk_0_period*2;
		
		--Insert stimuli here
		S_AXIS_IMG_WIDTH_tdata <= std_logic_vector(to_unsigned(50, S_AXIS_IMG_WIDTH_tdata'length));
		S_AXIS_IMG_WIDTH_tvalid <= '1';
		S_AXIS_IMG_HEIGHT_tdata <= std_logic_vector(to_unsigned(60, S_AXIS_IMG_HEIGHT_tdata'length));
		S_AXIS_IMG_HEIGHT_tvalid <= '1';
		
		wait for aclk_0_period*20;
		
        for i in 1 to c_num_tests loop
            
            v_slv_input := gen_random_slv(v_slv_input'length);
            --set MSB to 0 to guarantee positive value
            v_slv_input(v_slv_input'high) := '0';
            S_AXIS_X_tdata <= v_slv_input;
            s_x_inputs(i) <= to_integer(unsigned(v_slv_input));
            
            S_AXIS_X_tvalid <= '1';
            
            v_slv_input := gen_random_slv(v_slv_input'length);
            --set MSB to 0 to guarantee positive value
            v_slv_input(v_slv_input'high) := '0';
            S_AXIS_Y_tdata <= v_slv_input;
            s_y_inputs(i) <= to_integer(unsigned(v_slv_input));
            S_AXIS_Y_tvalid <= '1';
            
            wait for aclk_0_period;
            
        end loop;
        
        S_AXIS_X_tvalid <= '0';
		S_AXIS_Y_tvalid <= '0';
		
        if (S_AXIS_X_tvalid = '1') then
            wait until S_AXIS_X_tvalid = '0';
        else
            wait until S_AXIS_X_tvalid = '1';
            wait until S_AXIS_X_tvalid = '0';
        end if;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	check_result_proc: process is
	   
	   variable v_expected_result_x, v_expected_result_y : std_logic_vector(M_AXIS_RESULT_X_tdata'range);
	   variable v_expected_result_x_real, v_expected_result_y_real : real;
	   
	begin
	   
        for i in 1 to c_num_tests loop
        
            if (M_AXIS_RESULT_X_tvalid /= '1') then
                wait until M_AXIS_RESULT_X_tvalid = '1';
                wait for aclk_0_period/2;
            end if;

            v_expected_result_x_real := real(s_x_inputs(i)) - real(to_integer(unsigned(S_AXIS_IMG_WIDTH_tdata)))*0.5;
            v_expected_result_y_real := real(s_y_inputs(i)) - real(to_integer(unsigned(S_AXIS_IMG_HEIGHT_tdata)))*0.5;
            
            report "v_expected_result_x_real = " & to_string(v_expected_result_x_real);
            report "v_expected_result_y_real = " & to_string(v_expected_result_y_real);
            
            v_expected_result_x_real := v_expected_result_x_real/(150.0*s_scale_real);
            v_expected_result_y_real := v_expected_result_y_real/(150.0*s_scale_real);
            
            report "v_expected_result_x_real = " & to_string(v_expected_result_x_real);
            report "v_expected_result_y_real = " & to_string(v_expected_result_y_real);
            
            v_expected_result_x := parse_double_from_real(v_expected_result_x_real);
            v_expected_result_y := parse_double_from_real(v_expected_result_y_real);
            
            --if youre getting an error on this line along the lines of: 
            -- "ERROR: [VRFC 10-1471] type error near <variable name> ; current type std_logic_vector; expected type bit_vector"
            -- set the file type to VHDL 2008 in Vivado under Source File Properties
            assert abs(s_x_result_real - v_expected_result_x_real) < 0.0001
                report "Mismatched X result: expected 0x" & 
                to_hstring(v_expected_result_x) & 
                " (" & to_string(v_expected_result_x_real) & "), got 0x" & 
                to_hstring(M_AXIS_RESULT_X_tdata) & " (" & to_string(s_x_result_real) & ")"
                severity failure;
                
            assert abs(s_y_result_real - v_expected_result_y_real) < 0.0001
                report "Mismatched Y result: expected 0x" & 
                to_hstring(v_expected_result_y) & 
                " (" & to_string(v_expected_result_y_real) & "), got 0x" & 
                to_hstring(M_AXIS_RESULT_Y_tdata) & " (" & to_string(s_y_result_real) & ")"
                severity failure;
            
            wait for aclk_0_period;
        
        end loop;
        
    end process;

end Behavioral;
