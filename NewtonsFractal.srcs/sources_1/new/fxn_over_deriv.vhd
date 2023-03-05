----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2023 04:13:14 PM
-- Design Name: 
-- Module Name: fxn_over_deriv - Structural
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

entity fxn_over_deriv is
    generic (g_num_roots : integer := 5);
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_root_xs, i_root_ys : in t_double_arr(g_num_roots-1 downto 0);
        i_x, i_y : in std_logic_vector(63 downto 0);
        i_x_valid, i_y_valid : in std_logic;
        o_x, o_y : out std_logic_vector(63 downto 0);
        o_x_valid, o_y_valid : out std_logic
    );
end fxn_over_deriv;

architecture Structural of fxn_over_deriv is

    signal s_root_term_xs, s_root_term_ys : t_double_arr(g_num_roots-1 downto 0);
    signal s_root_term_x_valids, s_root_term_y_valids : std_logic_vector(g_num_roots-1 downto 0);
    
    signal s_inverse_result_x, s_inverse_result_y : std_logic_vector(63 downto 0);
    signal s_inverse_result_x_valid, s_inverse_result_y_valid : std_logic;
    
    signal s_neg_o_y : std_logic_vector(63 downto 0);

begin

    gen_root_terms: for root_idx in i_root_xs'range generate
        signal s_root_term_neg_ys : t_double_arr(s_root_term_ys'range);
    begin
        
        root_term_inst: entity work.root_term_wrapper
        port map(
            aclk_0 => i_clk,
            aresetn_0 => i_arstn,
            S_AXIS_COORD_X_tdata => i_x,
            S_AXIS_COORD_X_tvalid => i_x_valid,
            S_AXIS_COORD_Y_tdata => i_y,
            S_AXIS_COORD_Y_tvalid => i_y_valid,
            S_AXIS_ROOT_X_tdata => i_root_xs(root_idx),
            S_AXIS_ROOT_X_tvalid => '1',
            S_AXIS_ROOT_Y_tdata => i_root_ys(root_idx),
            S_AXIS_ROOT_Y_tvalid => '1',
            M_AXIS_X_tdata => s_root_term_xs(root_idx),
            M_AXIS_X_tvalid => s_root_term_x_valids(root_idx),
            M_AXIS_NEG_Y_tdata => s_root_term_neg_ys(root_idx),
            M_AXIS_NEG_Y_tvalid => s_root_term_y_valids(root_idx)
        );
        
        s_root_term_ys(root_idx) <= negate_double(s_root_term_neg_ys(root_idx));
        
    end generate;
    
    add_complexes_inst: entity work.add_n_complexs
    generic map(
        g_num_terms => g_num_roots
    )
    port map(
        i_clk => i_clk,
        i_arstn => i_arstn,
        i_x => s_root_term_xs,
        i_y => s_root_term_ys,
        i_x_valids => s_root_term_x_valids,
        i_y_valids => s_root_term_y_valids,
        o_x => s_inverse_result_x,
        o_y => s_inverse_result_y,
        o_x_valid => s_inverse_result_x_valid,
        o_y_valid => s_inverse_result_y_valid
    );
    
    invert_inst: entity work.invert_complex_wrapper
    port map(
        aclk_0 => i_clk,
        aresetn_0 => i_arstn,
        S_AXIS_X_TDATA => s_inverse_result_x,
        S_AXIS_X_TVALID => s_inverse_result_x_valid,
        S_AXIS_Y_TDATA => s_inverse_result_y,
        S_AXIS_Y_TVALID => s_inverse_result_y_valid,
        M_AXIS_X_tdata => o_x,
        M_AXIS_X_tvalid => o_x_valid,
        M_AXIS_NEG_Y_tdata => s_neg_o_y,
        M_AXIS_NEG_Y_tvalid => o_y_valid
    );
    
    o_y <= negate_double(s_neg_o_y);

end Structural;
