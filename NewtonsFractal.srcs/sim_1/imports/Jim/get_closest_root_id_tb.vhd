----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 15:45:46
-- Design Name: get_closest_root_id_tb
-- Module Name: get_closest_root_id_tb - Behavioral
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


entity get_closest_root_id_tb is
end get_closest_root_id_tb;

architecture Behavioral of get_closest_root_id_tb is
	
	--Generics
	constant g_num_roots : integer := 5;
	
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_arstn : std_logic := '0';
	
	--General inputs
	signal i_root_xs : t_double_arr(g_num_roots-1 downto 0);
	signal s_root_x_reals : t_real_arr(i_root_xs'range);
	signal i_root_ys : t_double_arr(g_num_roots-1 downto 0);
	signal s_root_y_reals : t_real_arr(i_root_ys'range);
	
	signal i_x : std_logic_vector(63 downto 0);
	signal s_x_real : real;
	signal i_y : std_logic_vector(63 downto 0);
	signal s_y_real : real;
	
	signal i_x_valid : std_logic := '0';
	signal i_y_valid : std_logic := '0';
	
	--Outputs
	signal o_id : integer;
	signal o_id_valid : std_logic;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
	constant c_num_tests : integer := 100;
	signal s_x_inputs, s_y_inputs : t_real_arr(c_num_tests downto 1);
	
begin

    gen_root_xs: for i in i_root_xs'range generate
        i_root_xs(i) <= parse_double_from_real(s_root_x_reals(i));
    end generate;
    
    gen_root_ys: for i in i_root_ys'range generate
        i_root_ys(i) <= parse_double_from_real(s_root_y_reals(i));
    end generate;
    
    i_x <= parse_double_from_real(s_x_real);
    i_y <= parse_double_from_real(s_y_real);
	
	UUT: entity work.get_closest_root_id
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
		i_x_valid => i_x_valid,
		i_y_valid => i_y_valid,
		o_id => o_id,
		o_id_valid => o_id_valid
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
		
		for i in i_root_xs'range loop
		    --move these out of the usual (0, 1] range so that no values will fall on a root
            uniform(v_seed1, v_seed2, v_rnd);
            s_root_x_reals(i) <= v_rnd + 1.0;
            uniform(v_seed1, v_seed2, v_rnd);
            s_root_y_reals(i) <= v_rnd + 1.0;
		end loop;
		
		i_x_valid <= '1';
		i_y_valid <= '1';
		
		for i in 1 to c_num_tests loop
            
            uniform(v_seed1, v_seed2, v_rnd);
            s_x_real <= v_rnd;
            s_x_inputs(i) <= v_rnd;
            uniform(v_seed1, v_seed2, v_rnd);
            s_y_real <= v_rnd;
            s_y_inputs(i) <= v_rnd;
            
            wait for i_clk_period;
            
		end loop;
		
		i_x_valid <= '0';
		i_y_valid <= '0';
		
        if (o_id_valid /= '1') then
            wait until o_id_valid = '1';
        end if;
        
        wait until o_id_valid = '0';
        
        wait for i_clk_period;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;
	
	
	check_result_proc: process is
	   
	   variable v_expected_id : integer;
	   
	   variable v_root_diff_x, v_root_diff_y : real;
	   variable v_squaresum, v_dist : real;
	   
	   variable v_min_dist : real;
	   variable v_min_dist_id : integer;
	   
	begin
	   
        for i in 1 to c_num_tests loop
        
            if (o_id_valid /= '1') then
                wait until o_id_valid = '1';
                wait for i_clk_period/2;
            end if;
            
            v_min_dist := parse_real_from_double(c_double_max);
            v_min_dist_id := -1;
            
            for j in s_root_x_reals'range loop
            
                v_root_diff_x := s_x_inputs(i) - s_root_x_reals(j);
                v_root_diff_y := s_y_inputs(i) - s_root_y_reals(j);
                v_squaresum := v_root_diff_x*v_root_diff_x + v_root_diff_y*v_root_diff_y;
                v_dist := sqrt(v_squaresum);
                if (v_dist < v_min_dist) then
                    v_min_dist := v_dist;
                    v_min_dist_id := j;
                end if;

                report "v_root_diff_x = " & to_string(v_root_diff_x) severity note;
                report "v_root_diff_y = " & to_string(v_root_diff_y) severity note;
                report "v_squaresum = " & to_string(v_squaresum) severity note;
                report "v_dist = " & to_string(v_dist) severity note;
                report "v_min_dist = " & to_string(v_min_dist) severity note;
                report "v_min_dist_id = " & integer'image(v_min_dist_id) severity note;
                
            end loop;
            
            v_expected_id := v_min_dist_id;
            
            assert o_id = v_expected_id
                report "Mismatched ID result: expected " & 
                integer'image(v_expected_id) & ", got " &  
                integer'image(o_id)
                severity failure;
            
            wait for i_clk_period;
        
        end loop;
	   	   
	end process;

end Behavioral;
