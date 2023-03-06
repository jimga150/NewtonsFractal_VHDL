----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 10:55:56
-- Design Name: get_min_float_n_tb
-- Module Name: get_min_float_n_tb - Behavioral
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
use ieee.math_real.all;
use work.type_pkg.all;

entity get_min_float_n_tb is
end get_min_float_n_tb;

architecture Behavioral of get_min_float_n_tb is
	
	--Generics
	constant g_num_floats : integer := 5;
	
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_arstn : std_logic := '0';
	
	--General inputs
	signal i_flts : t_double_arr(g_num_floats-1 downto 0);
	signal s_flts_real : t_real_arr(i_flts'range) := (others => 0.0);
	signal i_flt_ids : t_int_arr(g_num_floats-1 downto 0) := (others => 0);
	signal i_flt_valids : std_logic_vector(g_num_floats-1 downto 0) := (others => '0');
	
	--Outputs
	signal o_min : std_logic_vector(63 downto 0);
	signal s_min_real : real;
	signal o_min_id : integer;
	signal o_min_valid : std_logic;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_inputs : t_real_2d_arr(c_num_tests downto 1, i_flts'range);
	
begin

    gen_flt_ins: for i in i_flts'range generate
        i_flts(i) <= parse_double_from_real(s_flts_real(i));
    end generate gen_flt_ins;
    
    s_min_real <= parse_real_from_double(o_min);
	
	UUT: entity work.get_min_float_n
	generic map(
		g_num_floats => g_num_floats
	)
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_flts => i_flts,
		i_flt_ids => i_flt_ids,
		i_flt_valids => i_flt_valids,
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
		
		for j in i_flts'range loop
		  i_flt_ids(j) <= j;
		end loop;
		
		i_flt_valids <= (others => '1');
		
		for i in 1 to c_num_tests loop
            
            for j in i_flts'range loop
                uniform(v_seed1, v_seed2, v_rnd);
                s_flts_real(j) <= v_rnd;
                s_inputs(i, j) <= v_rnd;
            end loop;
            
            wait for i_clk_period;
            
		end loop;
		
		i_flt_valids <= (others => '0');
		
        if (o_min_valid = '0') then
            wait until o_min_valid = '1';
        end if;
        
        wait until o_min_valid = '0';
		
		wait for i_clk_period;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	check_result_proc: process is
	   
	   variable v_expected_min : std_logic_vector(o_min'range);
	   variable v_expected_min_real : real;
	   
	   variable v_expected_id : integer;
	   
	begin
	   
	   for i in 1 to c_num_tests loop
	       
            if (o_min_valid /= '1') then
                wait until o_min_valid = '1';
                wait for i_clk_period/2;
            end if;
            
            v_expected_min_real := parse_real_from_double(c_double_max);
            for j in s_inputs'range(2) loop
                v_expected_min_real := realmin(v_expected_min_real, s_inputs(i, j));
            end loop;
            
            v_expected_id := -1;
            for j in s_inputs'range(2) loop
                if (v_expected_min_real = s_inputs(i, j)) then
                    v_expected_id := i_flt_ids(j);
                end if;
            end loop;
            
            assert (v_expected_id /= -1)
                report "No match found for v_expected_min_real in s_inputs(i, *)"
                severity failure; 
            
            v_expected_min := parse_double_from_real(v_expected_min_real);
            
            assert abs(s_min_real - v_expected_min_real) < 0.0001
                report "Mismatched result: expected 0x" & 
                to_hstring(v_expected_min) & " (" & 
                to_string(v_expected_min_real) & "), got 0x" & 
                to_hstring(o_min) & " (" & 
                to_string(s_min_real) & ")"
                severity failure;
                
            assert o_min_id = v_expected_id
                report "Mismatched result: expected " & 
                integer'image(v_expected_id) & ", got " & 
                integer'image(o_min_id)
                severity failure;
            
            wait for i_clk_period;
           
	   end loop;
	   	   
	end process;

end Behavioral;
