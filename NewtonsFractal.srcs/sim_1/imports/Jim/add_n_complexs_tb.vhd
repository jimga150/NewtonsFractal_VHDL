----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2023 15:51:39
-- Design Name: add_n_complexs_tb
-- Module Name: add_n_complexs_tb - Behavioral
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

entity add_n_complexs_tb is
end add_n_complexs_tb;

architecture Behavioral of add_n_complexs_tb is
	
	--Generics
	constant g_num_terms : integer := 5;
	
	constant c_num_stages : integer := integer(floor(log2(real(g_num_terms-1) + 0.0000000001))) + 1;
	constant c_latency : integer := c_num_stages*14; --TODO: magic number
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_arstn : std_logic := '0';
	
	--General inputs
	signal i_x : t_double_arr(g_num_terms-1 downto 0) := (others => (others => '0'));
	signal i_y : t_double_arr(g_num_terms-1 downto 0) := (others => (others => '0'));
	signal i_x_valids : std_logic_vector(g_num_terms-1 downto 0) := (others => '0');
	signal i_y_valids : std_logic_vector(g_num_terms-1 downto 0) := (others => '0');
	
	signal s_x_real, s_y_real : t_real_arr(i_x'range) := (others => 0.0);
	
	--Outputs
	signal o_x : std_logic_vector(63 downto 0);
	signal o_y : std_logic_vector(63 downto 0);
	signal o_x_valid : std_logic;
	signal o_y_valid : std_logic;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_x_inputs, s_y_inputs : t_double_2d_arr(c_num_tests downto 1, i_x'range);
	
begin
	
	UUT: entity work.add_n_complexs
	generic map(
		g_num_terms => g_num_terms
	)
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_x => i_x,
		i_y => i_y,
		i_x_valids => i_x_valids,
		i_y_valids => i_y_valids,
		o_x => o_x,
		o_y => o_y,
		o_x_valid => o_x_valid,
		o_y_valid => o_y_valid
	);
	
	--Clock Drivers
	i_clk <= not i_clk after i_clk_period/2;
	
	stim_proc: process is 
	
        variable v_seed1, v_seed2 : positive;
        variable v_rnd : real;
--        constant c_rng_max_width : integer := 16;
        
--        variable v_idx_low, v_idx_high, v_data_width, v_max_data_val : natural;

	begin
		
		wait for i_clk_period*3;
		
		i_arstn <= '1';
		
		wait for i_clk_period;
		
		for i in 1 to c_num_tests loop
		
            for term_idx in i_x'range loop
            
--                -- generate random values for signal i_terms(term_idx)
--                -- needs variables declared in process header
--                -- needs the following libraries:
--                -- use IEEE.NUMERIC_STD.ALL;
--                -- use ieee.math_real.all;
--                -- use work.type_pkg.all;
--                for j in 0 to integer(floor(real(i_terms(term_idx)'length)/real(c_rng_max_width))) loop
--                    uniform(v_seed1, v_seed2, v_rnd);
--                    v_idx_low := j*c_rng_max_width;
--                    v_idx_high := int_min((j+1)*c_rng_max_width - 1, i_terms(term_idx)'high);
--                    v_data_width := v_idx_high + 1 - v_idx_low;
--                    v_max_data_val := 2**v_data_width;
--                    i_terms(term_idx)(v_idx_high downto v_idx_low) <= std_logic_vector(to_unsigned(integer(v_rnd*real(v_max_data_val)), v_data_width));
--                end loop;

                uniform(v_seed1, v_seed2, v_rnd);
                s_x_real(term_idx) <= v_rnd;
                i_x(term_idx) <= parse_double_from_real(v_rnd);
                i_x_valids(term_idx) <= '1';
                
                uniform(v_seed1, v_seed2, v_rnd);
                s_y_real(term_idx) <= v_rnd;
                i_y(term_idx) <= parse_double_from_real(v_rnd);
                i_y_valids(term_idx) <= '1';
                
            end loop;
            
            wait for i_clk_period;
            
            for term_idx in i_x'range loop
                s_x_inputs(i, term_idx) <= i_x(term_idx);
            end loop;
            
            for term_idx in i_y'range loop
                s_y_inputs(i, term_idx) <= i_y(term_idx);
            end loop;
            
		end loop;
		
		wait for i_clk_period*c_latency;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	check_x_result_proc: process is
	   
	   variable v_expected_result : std_logic_vector(o_x'range);
	   variable v_expected_result_real : real;
	   
	   variable v_result_real : real;
	   
	begin
	   
	   for i in 1 to c_num_tests loop
	       
           if (o_x_valid /= '1') then
               wait until o_x_valid = '1';
               wait for i_clk_period/2;
           end if;
           
           v_expected_result_real := 0.0;
	       for j in s_x_inputs'range(2) loop
	           v_expected_result_real := v_expected_result_real + parse_real_from_double(s_x_inputs(i, j));
	       end loop;
	       
	       v_expected_result := parse_double_from_real(v_expected_result_real);
	       v_result_real := parse_real_from_double(o_x);
           
            assert abs(v_result_real - v_expected_result_real) < 0.0001
                report "Mismatched X result: expected 0x" & to_hstring(v_expected_result) & " (" & to_string(v_expected_result_real) & "), got 0x" & to_hstring(o_x) & " (" & to_string(v_result_real) & ")"
                severity failure;
                
            wait for i_clk_period;
           
	   end loop;
	   	   
	end process;
	
	check_y_result_proc: process is
	   
	   variable v_expected_result : std_logic_vector(o_y'range);
	   variable v_expected_result_real : real;
	   
	   variable v_result_real : real;
	   
	begin
	   
	   for i in 1 to c_num_tests loop
	       
           if (o_y_valid /= '1') then
               wait until o_y_valid = '1';
               wait for i_clk_period/2;
           end if;
           
           v_expected_result_real := 0.0;
	       for j in s_y_inputs'range(2) loop
	           v_expected_result_real := v_expected_result_real + parse_real_from_double(s_y_inputs(i, j));
	       end loop;
	       
	       v_expected_result := parse_double_from_real(v_expected_result_real);
	       v_result_real := parse_real_from_double(o_y);
           
            assert abs(v_result_real - v_expected_result_real) < 0.0001
                report "Mismatched Y result: expected 0x" & to_hstring(v_expected_result) & " (" & to_string(v_expected_result_real) & "), got 0x" & to_hstring(o_y) & " (" & to_string(v_result_real) & ")"
                severity failure;
                
            wait for i_clk_period;
           
	   end loop;
	   	   
	end process;

end Behavioral;
