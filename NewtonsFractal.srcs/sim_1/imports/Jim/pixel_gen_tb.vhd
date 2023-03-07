----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 17:19:07
-- Design Name: pixel_gen_tb
-- Module Name: pixel_gen_tb - Behavioral
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

entity pixel_gen_tb is
end pixel_gen_tb;

architecture Behavioral of pixel_gen_tb is
	
	--Generics
	constant g_num_roots : integer := 5;
	
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_arstn : std_logic := '0';
	
	--General inputs
	signal i_root_xs : t_double_arr(g_num_roots-1 downto 0);
	signal s_root_x_reals : t_real_arr(i_root_xs'range) := (others => 0.0);
	signal i_root_ys : t_double_arr(g_num_roots-1 downto 0);
	signal s_root_y_reals : t_real_arr(i_root_ys'range) := (others => 0.0);
	
	signal i_pixel_x : integer := 0;
	signal i_pixel_y : integer := 0;
	
	signal i_img_width : integer := 0;
	signal i_img_height : integer := 0;
	
	signal i_scale : std_logic_vector(63 downto 0);
	signal s_scale_real : real := 0.0;
	
	signal i_pixel_coord_valid : std_logic := '0';
	
	--Outputs
	signal o_pixel : std_logic_vector(11 downto 0);
	signal o_pixel_valid : std_logic;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
	constant c_width : integer := 640;
	constant c_height : integer := 480;
	constant c_num_pixels : integer := c_width*c_height;
	signal s_x_inputs, s_y_inputs : t_int_arr(c_num_pixels-1 downto 0);
	
begin

    gen_root_xs: for i in i_root_xs'range generate
        i_root_xs(i) <= parse_double_from_real(s_root_x_reals(i));
    end generate;
    
    gen_root_ys: for i in i_root_ys'range generate
        i_root_ys(i) <= parse_double_from_real(s_root_y_reals(i));
    end generate;
    
    i_scale <= parse_double_from_real(s_scale_real);
	
	UUT: entity work.pixel_gen
	generic map(
		g_num_roots => g_num_roots
	)
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_root_xs => i_root_xs,
		i_root_ys => i_root_ys,
		i_pixel_x => i_pixel_x,
		i_pixel_y => i_pixel_y,
		i_img_width => i_img_width,
		i_img_height => i_img_height,
		i_scale => i_scale,
		i_pixel_coord_valid => i_pixel_coord_valid,
		o_pixel => o_pixel,
		o_pixel_valid => o_pixel_valid
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
		
--		for i in i_root_xs'range loop
--		    --move these out of the usual (0, 1] range so that no values will fall on a root
--            uniform(v_seed1, v_seed2, v_rnd);
--            s_root_x_reals(i) <= v_rnd + 1.0;
--            uniform(v_seed1, v_seed2, v_rnd);
--            s_root_y_reals(i) <= v_rnd + 1.0;
--		end loop;

        s_root_x_reals(0) <= 1.0;
        s_root_y_reals(0) <= 0.0;
        s_root_x_reals(1) <= 0.309;
        s_root_y_reals(1) <= -0.951;
        s_root_x_reals(2) <= -0.809;
        s_root_y_reals(2) <= -0.587785;
        s_root_x_reals(3) <= -0.809;
        s_root_y_reals(3) <= 0.587785;
        s_root_x_reals(4) <= 0.309;
        s_root_y_reals(4) <= 0.951;
		
		s_scale_real <= 1.0;
		i_img_width <= 640;
		i_img_height <= 480;
		
		wait for i_clk_period;
		
		i_pixel_coord_valid <= '1';
		
        for y in 0 to 0 loop
        
            i_pixel_y <= y;
        
            for x in 0 to c_width-1 loop
                
                i_pixel_x <= x;
                
                s_x_inputs(y*c_width + x) <= x;
                s_y_inputs(y*c_width + x) <= y;
                
                wait for i_clk_period;
                
            end loop;
            
--            uniform(v_seed1, v_seed2, v_rnd);
--            v_rnd := v_rnd*real(i_img_width);
--            i_pixel_x <= integer(v_rnd);
--            s_x_inputs(i) <= integer(v_rnd);
            
--            uniform(v_seed1, v_seed2, v_rnd);
--            v_rnd := v_rnd*real(i_img_height);
--            i_pixel_y <= integer(v_rnd);
--            s_y_inputs(i) <= integer(v_rnd);
            
--            wait for i_clk_period;
        
        end loop;
        
		i_pixel_coord_valid <= '0';
		
		if (o_pixel_valid /= '1') then
            wait until o_pixel_valid = '1';
        end if;
        
        wait until o_pixel_valid = '0'; 
        
        wait for i_clk_period;
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;

end Behavioral;
