----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 04:40:30 PM
-- Design Name: 
-- Module Name: pixel_gen - Structural
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.type_pkg.all;

entity pixel_genv1 is
    generic(g_num_roots : integer := 5);
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_root_xs, i_root_ys : in t_double_arr(g_num_roots-1 downto 0);
        i_pixel_x, i_pixel_y : in integer;
        i_img_width, i_img_height : in integer;
        i_scale : in std_logic_vector(63 downto 0);
        i_pixel_coord_valid : in std_logic;
        o_pixel : out std_logic_vector(11 downto 0);
        o_pixel_valid : out std_logic
    );
end pixel_genv1;

architecture Structural of pixel_genv1 is

    signal s_pixel_x_slv, s_pixel_y_slv, s_img_width_slv, s_img_height_slv : std_logic_vector(31 downto 0);
    
    signal s_coord_x, s_coord_y : std_logic_vector(63 downto 0);
    signal s_coord_valid : std_logic;
    
    signal s_root_guess_x, s_root_guess_y : std_logic_vector(63 downto 0);
    signal s_root_guess_valid : std_logic;
    
    signal s_root_id : integer;
    signal s_root_id_valid : std_logic;
    
    --TODO: commonize this so that the scheme has one soure of truth
    function get_root_ids(i_num_roots: integer) return t_int_arr is
        variable v_ans : t_int_arr(i_num_roots-1 downto 0);
    begin
        for i in v_ans'range loop
            v_ans(i) := i;
        end loop;
        return v_ans;
    end function;

    constant c_root_ids : t_int_arr := get_root_ids(g_num_roots);

begin

    s_pixel_x_slv <= std_logic_vector(to_unsigned(i_pixel_x, s_pixel_x_slv'length));
    s_pixel_y_slv <= std_logic_vector(to_unsigned(i_pixel_y, s_pixel_y_slv'length));
    s_img_width_slv <= std_logic_vector(to_unsigned(i_img_width, s_img_width_slv'length));
    s_img_height_slv <= std_logic_vector(to_unsigned(i_img_height, s_img_height_slv'length));

    ptc_inst: entity work.pixel_to_coord_wrapper
	port map(
		aclk_0 => i_clk,
		aresetn_0 => i_arstn,
		S_AXIS_IMG_HEIGHT_tdata => s_img_height_slv,
		S_AXIS_IMG_HEIGHT_tvalid => '1',
		S_AXIS_IMG_WIDTH_tdata => s_img_width_slv,
		S_AXIS_IMG_WIDTH_tvalid => '1',
		S_AXIS_SCALE_DPFLT_tdata => i_scale,
		S_AXIS_SCALE_DPFLT_tvalid => i_pixel_coord_valid,
		S_AXIS_X_tdata => s_pixel_x_slv,
		S_AXIS_X_tvalid => i_pixel_coord_valid,
		S_AXIS_Y_tdata => s_pixel_y_slv,
		S_AXIS_Y_tvalid => i_pixel_coord_valid,
		M_AXIS_RESULT_X_tdata => s_coord_x,
		M_AXIS_RESULT_X_tvalid => s_coord_valid,
		M_AXIS_RESULT_Y_tdata => s_coord_y,
		M_AXIS_RESULT_Y_tvalid => open
	);
	
	--TODO: generate N iterations in series, where N is the max number of iteratiosn desired. 
	--each iteration should be generated with an optional delay passthrough element that 
	--takes the previous iteration (or passthrough) and delays it by the same number of 
	--cycles that an iteration would take
	rf_iter_inst: entity work.rootfind_iteration
	generic map(
		g_num_roots => g_num_roots
	)
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_root_xs => i_root_xs,
		i_root_ys => i_root_ys,
		i_x => s_coord_x,
		i_y => s_coord_y,
		i_input_valid => s_coord_valid,
		o_x => s_root_guess_x,
		o_y => s_root_guess_y,
		o_output_valid => s_root_guess_valid
	);
	
	crid_inst: entity work.get_closest_root_id
	generic map(
		g_num_roots => g_num_roots
	)
	port map(
		i_clk => i_clk,
		i_arstn => i_arstn,
		i_root_xs => i_root_xs,
		i_root_ys => i_root_ys,
		i_x => s_root_guess_x,
		i_y => s_root_guess_y,
		i_x_valid => s_root_guess_valid,
		i_y_valid => s_root_guess_valid,
		o_id => s_root_id,
		o_id_valid => s_root_id_valid
	);
	
    getcol_inst: entity work.get_color
    generic map(
        g_num_colors => g_num_roots
    )
    port map(
        i_clk => i_clk,
		i_arstn => i_arstn,
        i_id_in => s_root_id,
        i_id_valid => s_root_id_valid,
        i_ids => c_root_ids,
        o_color => o_pixel,
        o_color_valid => o_pixel_valid
    );
	
end Structural;
