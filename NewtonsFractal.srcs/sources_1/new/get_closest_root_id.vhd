----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 03:09:18 PM
-- Design Name: 
-- Module Name: get_closest_root_id - Structural
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

entity get_closest_root_id is
    generic (g_num_roots : integer := 5);
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_root_xs, i_root_ys : in t_double_arr(g_num_roots-1 downto 0);
        i_x, i_y : in std_logic_vector(63 downto 0);
        i_x_valid, i_y_valid : in std_logic;
        o_id : out integer;
        o_id_valid : out std_logic
    );
end get_closest_root_id;

architecture Structural of get_closest_root_id is

    function get_root_ids(i_num_roots: integer) return t_int_arr is
        variable v_ans : t_int_arr(i_num_roots-1 downto 0);
    begin
        for i in v_ans'range loop
            v_ans(i) := i;
        end loop;
        return v_ans;
    end function;

    constant c_root_ids : t_int_arr := get_root_ids(g_num_roots);

    signal s_root_dists : t_double_arr(g_num_roots-1 downto 0);
    signal s_root_dist_valids : std_logic_vector(s_root_dists'range);

begin

    gen_root_dist_finders: for i in s_root_dists'range generate
        
        root_dist_inst: entity work.get_root_dist_wrapper
        port map(
            aclk_0 => i_clk,
            aresetn_0 => i_arstn,
            S_AXIS_ROOT_X_tdata => i_root_xs(i),
            S_AXIS_ROOT_X_tvalid => '1',
            S_AXIS_ROOT_Y_tdata => i_root_ys(i),
            S_AXIS_ROOT_Y_tvalid => '1',
            S_AXIS_X_tdata => i_x,
            S_AXIS_X_tvalid => i_x_valid,
            S_AXIS_Y_tdata => i_y,
            S_AXIS_Y_tvalid => i_y_valid,
            M_AXIS_RESULT_tdata => s_root_dists(i),
            M_AXIS_RESULT_tvalid => s_root_dist_valids(i)
        );
        
    end generate gen_root_dist_finders;
    
    get_min_inst: entity work.get_min_float_n
    generic map(
        g_num_floats => g_num_roots
    )
    port map(
        i_clk => i_clk,
        i_arstn => i_arstn,
        i_flts => s_root_dists,
        i_flt_ids => c_root_ids,
        i_flt_valids => s_root_dist_valids,
        o_min => open,
        o_min_id => o_id,
        o_min_valid => o_id_valid
    );

end Structural;
