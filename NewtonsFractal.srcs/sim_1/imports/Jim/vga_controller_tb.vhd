----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2023 10:52:18
-- Design Name: vga_controller_tb
-- Module Name: vga_controller_tb - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;

entity vga_controller_tb is
end vga_controller_tb;

architecture Behavioral of vga_controller_tb is
	
	--Generics
	constant g_h_pixels : integer := 1680;
	constant g_h_fp : integer := 104;
	constant g_h_pulse : integer := 184;
	constant g_h_bp : integer := 288;
	constant g_h_pol : std_logic := '0';
	constant g_v_pixels : integer := 1050;
	constant g_v_fp : integer := 1;
	constant g_v_pulse : integer := 3;
	constant g_v_bp : integer := 33;
	constant g_v_pol : std_logic := '1';
	
	constant c_total_horiz_cycles : integer := g_h_pixels + g_h_fp + g_h_pulse + g_h_bp;
	constant c_total_frame_cycles : integer := (g_v_pixels + g_v_fp + g_v_pulse + g_v_bp)*c_total_horiz_cycles;
	
	--Clocks
	signal i_clk : std_logic := '0';
	
	--Resets
	signal i_rst_n : std_logic := '0';
	
	
	--Outputs
	signal o_h_sync : std_logic;
	signal o_v_sync : std_logic;
	signal o_disp_ena : std_logic;
	signal o_column : integer;
	signal o_row : integer;
	
	--Clock Periods
	constant i_clk_period : time := 10 ns;
	
begin
	
	UUT: entity work.vga_controller
	generic map(
		g_h_pixels => g_h_pixels,
		g_h_fp => g_h_fp,
		g_h_pulse => g_h_pulse,
		g_h_bp => g_h_bp,
		g_h_pol => g_h_pol,
		g_v_pixels => g_v_pixels,
		g_v_fp => g_v_fp,
		g_v_pulse => g_v_pulse,
		g_v_bp => g_v_bp,
		g_v_pol => g_v_pol
	)
	port map(
		i_clk => i_clk,
		i_rst_n => i_rst_n,
		o_h_sync => o_h_sync,
		o_v_sync => o_v_sync,
		o_disp_ena => o_disp_ena,
		o_column => o_column,
		o_row => o_row
	);
	
	--Clock Drivers
	i_clk <= not i_clk after i_clk_period/2;
	
	stim_proc: process is begin
		
		wait for i_clk_period;
		
		i_rst_n <= '1';
		
		wait for i_clk_period*c_total_frame_cycles*5;
		
		
		assert false report "End Simulation" severity failure;
		
		-- Not strictly necessary, but prevents process from looping 
		-- if the above assert statement is removed
		wait;
		
	end process;

end Behavioral;
