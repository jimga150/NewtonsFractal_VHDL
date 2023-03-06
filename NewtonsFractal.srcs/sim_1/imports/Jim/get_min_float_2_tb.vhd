----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 09:59:53
-- Design Name: get_min_float_2_tb
-- Module Name: get_min_float_2_tb - Behavioral
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

entity get_min_float_2_tb is
end get_min_float_2_tb;

architecture Behavioral of get_min_float_2_tb is
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_arstn : std_logic := '0';
	
	--General inputs
	signal i_flt0 : std_logic_vector(63 downto 0);
	signal s_flt0_real : real := 0.0;
	signal i_flt1 : std_logic_vector(63 downto 0);
	signal s_flt1_real : real := 0.0;
	signal i_flt0_id : integer := 42;
	signal i_flt1_id : integer := 68;
	signal i_flt0_valid : std_logic := '0';
	signal i_flt1_valid : std_logic := '0';
	
	--Outputs
	signal o_min : std_logic_vector(63 downto 0);
	signal s_min_real : real;
	signal o_min_id : integer;
	signal o_min_valid : std_logic;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_flt0_inputs, s_flt1_inputs : t_real_arr(c_num_tests downto 1);
	
begin

    i_flt0 <= parse_double_from_real(s_flt0_real);
    i_flt1 <= parse_double_from_real(s_flt1_real);
    
    s_min_real <= parse_real_from_double(o_min);
	
	UUT: entity work.get_min_float_2
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_flt0 => i_flt0,
		i_flt1 => i_flt1,
		i_flt0_id => i_flt0_id,
		i_flt1_id => i_flt1_id,
		i_flt0_valid => i_flt0_valid,
		i_flt1_valid => i_flt1_valid,
		o_min => o_min,
		o_min_id => o_min_id,
		o_min_valid => o_min_valid
	);
	
	--Clock Drivers
	i_clk <= not i_clk after i_clk_period/2;
	
	stim_proc: process is
        variable v_seed1, v_seed2 : positive;
        variable v_rnd : real;
	begin
		
		wait for i_clk_period*3;
		
		i_arstn <= '1';
		
		wait for i_clk_period*2;
		
		--Insert stimuli here
		i_flt0_valid <= '1';
		i_flt1_valid <= '1';
		
		for i in 1 to c_num_tests loop
            
            uniform(v_seed1, v_seed2, v_rnd);
            v_rnd := v_rnd*10.0 - 5.0; --get some negative vals in here
            s_flt0_real <= v_rnd;
            s_flt0_inputs(i) <= v_rnd;
            uniform(v_seed1, v_seed2, v_rnd);
            v_rnd := v_rnd*10.0 - 5.0;
            s_flt1_real <= v_rnd;
            s_flt1_inputs(i) <= v_rnd;
            
            wait for i_clk_period;
            
		end loop;
		
		i_flt0_valid <= '0';
		i_flt1_valid <= '0';
		
        if (o_min_valid = '1') then
            wait until o_min_valid = '0';
        else
            wait until o_min_valid = '1';
            wait until o_min_valid = '0';
        end if;
		
		wait for i_clk_period;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	
	check_result_proc: process is
	   
	   variable v_expected_min : std_logic_vector(o_min'range);
	   variable v_expected_min_real : real;
	   
	   variable v_expected_min_id : integer;
	   
	begin
	   
        for i in 1 to c_num_tests loop
        
            if (o_min_valid /= '1') then
                wait until o_min_valid = '1';
                wait for i_clk_period/2;
            end if;
            
            v_expected_min_real := realmin(s_flt0_inputs(i), s_flt1_inputs(i));
            
            if (v_expected_min_real = s_flt0_inputs(i)) then
                v_expected_min_id := i_flt0_id;
            else
                v_expected_min_id := i_flt1_id;
            end if;
            
            v_expected_min := parse_double_from_real(v_expected_min_real);
            
            assert abs(s_min_real - v_expected_min_real) < 0.0001
                report "Mismatched result: expected 0x" & 
                to_hstring(v_expected_min) & 
                " (" & to_string(v_expected_min_real) & "), got 0x" & 
                to_hstring(o_min) & " (" & to_string(s_min_real) & ")"
                severity failure;
                
            assert v_expected_min_id = o_min_id
                report "Mismatched ID: expected " & 
                integer'image(v_expected_min_id) & 
                ", got " & integer'image(o_min_id)
                severity failure;
            
            wait for i_clk_period;
        
        end loop;
	   	   
	end process;

end Behavioral;
