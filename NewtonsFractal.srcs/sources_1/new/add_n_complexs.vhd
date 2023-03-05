----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2023 10:47:16 PM
-- Design Name: 
-- Module Name: add_n_complexs - Structural
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

entity add_n_complexs is
    generic(
        g_num_terms : integer := 5 
    );
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_x, i_y : in t_double_arr(g_num_terms-1 downto 0);
        i_x_valids, i_y_valids : in std_logic_vector(g_num_terms-1 downto 0);
        o_x, o_y : out std_logic_vector(63 downto 0);
        o_x_valid, o_y_valid : out std_logic
    );
end add_n_complexs;

architecture Structural of add_n_complexs is

begin

    add_x: entity work.add_n_floats
    generic map(
        g_num_terms => g_num_terms
    )
    port map(
        i_clk => i_clk,
        i_arstn => i_arstn,
        i_terms => i_x,
        i_term_valids => i_x_valids,
        o_result => o_x,
        o_result_valid => o_x_valid
    );
    
    add_y: entity work.add_n_floats
    generic map(
        g_num_terms => g_num_terms
    )
    port map(
        i_clk => i_clk,
        i_arstn => i_arstn,
        i_terms => i_y,
        i_term_valids => i_y_valids,
        o_result => o_y,
        o_result_valid => o_y_valid
    );

end Structural;
