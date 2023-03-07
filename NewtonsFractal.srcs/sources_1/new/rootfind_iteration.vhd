----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 07:56:04 PM
-- Design Name: 
-- Module Name: rootfind_iteration - Structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.type_pkg.all;

entity rootfind_iteration is
    generic (g_num_roots : integer := 5);
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_root_xs, i_root_ys : in t_double_arr(g_num_roots-1 downto 0);
        i_x, i_y : in std_logic_vector(63 downto 0);
        i_input_valid : in std_logic;
        o_x, o_y : out std_logic_vector(63 downto 0);
        o_output_valid : out std_logic
    );
end rootfind_iteration;

architecture Structural of rootfind_iteration is

    signal s_fod_x, s_fod_y : std_logic_vector(63 downto 0);
    signal s_orig_x, s_orig_y : std_logic_vector(63 downto 0);
    signal s_fod_valid : std_logic;

begin

    fod_inst: entity work.fxn_over_deriv
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
		i_x_valid => i_input_valid,
		i_y_valid => i_input_valid,
		o_x => s_fod_x,
		o_y => s_fod_y,
		o_x_valid => s_fod_valid,
		o_y_valid => open
	);
	
	coord_buffer_inst: entity work.complex_fifo_wrapper
	port map(
        i_clk => i_clk,
		i_arstn => i_arstn,
        i_x => i_x,
        i_y => i_y,
        i_input_valid => i_input_valid,
        o_x => s_orig_x,
        o_y => s_orig_y,
        i_downstream_ready => s_fod_valid,
        o_complex_valid => open --assuming this will be valid by the time we need it, which in any latency greater than 2, is true
	);
	
    sub_from_guess_inst: entity work.sub_complexs_wrapper
    port map(
        aclk_0 => i_clk,
        aresetn_0 => i_arstn,
        S_AXIS_A_X_tdata => s_orig_x,
        S_AXIS_A_X_tvalid => s_fod_valid,
        S_AXIS_A_Y_tdata => s_orig_y,
        S_AXIS_A_Y_tvalid => s_fod_valid,
        S_AXIS_B_X_tdata => s_fod_x,
        S_AXIS_B_X_tvalid => s_fod_valid,
        S_AXIS_B_Y_tdata => s_fod_y,
        S_AXIS_B_Y_tvalid => s_fod_valid,
        M_AXIS_RESULT_X_tdata => o_x,
        M_AXIS_RESULT_X_tvalid => o_output_valid,
        M_AXIS_RESULT_Y_tdata => o_y,
        M_AXIS_RESULT_Y_tvalid => open
    );

end Structural;
