----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2023 09:43:45 AM
-- Design Name: 
-- Module Name: add_n_floats - Structural
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
use ieee.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.type_pkg.all;

entity add_n_floats is
    generic(
        g_num_terms : integer := 5 
    );
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_terms : in t_double_arr(g_num_terms-1 downto 0);
        i_term_valids : in std_logic_vector(g_num_terms-1 downto 0);
        o_result : out std_logic_vector(63 downto 0);
        o_result_valid : out std_logic
    );
end add_n_floats;

architecture Structural of add_n_floats is

    pure function get_num_adders(i_stage_num : integer) return integer is begin
        return 2**(i_stage_num-1);
    end function;

    -- why do i have to add 0.000000000000000000000001?
    -- in synthesis, you dont--since for example, log2(4.0) = 2.0, which will floor() to 2.
    -- in SIMULATION, for some godforsaken reason, operations like log2(4.0) evaluate to something like 1.99999999999, which then floor to 1.
    -- solution: make the argument slightly greater to avoid passing in a round number, but not by enough to make it graduate to the next integer of log2() values.
    constant c_num_stages : integer := integer(floor(log2(real(g_num_terms-1) + 0.0000000001))) + 1;
    
    -- see for yourself here
--    constant c_num_stages2 : integer := integer(floor(log2(real(2-1) + 0.0000000001))) + 1;
--    constant c_num_stages3 : integer := integer(floor(log2(real(3-1) + 0.0000000001))) + 1;
--    constant c_num_stages4 : integer := integer(floor(log2(real(4-1) + 0.0000000001))) + 1;
--    constant c_num_stages5 : integer := integer(floor(log2(real(5-1) + 0.0000000001))) + 1;
--    constant c_num_stages6 : integer := integer(floor(log2(real(6-1) + 0.0000000001))) + 1;
--    constant c_num_stages7 : integer := integer(floor(log2(real(7-1) + 0.0000000001))) + 1;
--    constant c_num_stages8 : integer := integer(floor(log2(real(8-1) + 0.0000000001))) + 1;
--    constant c_num_stages9 : integer := integer(floor(log2(real(9-1) + 0.0000000001))) + 1;
    
    signal s_results : t_double_2d_arr(c_num_stages downto 1, get_num_adders(c_num_stages) - 1 downto 0);
    signal s_result_valids : t_std_logic_2d_arr(s_results'range(1), s_results'range(2));

begin

    gen_stages: for stage_num in c_num_stages downto 1 generate
        
        constant c_num_adders : integer := get_num_adders(stage_num);
        
        signal s_inputs : t_double_arr( (c_num_adders*2) - 1 downto 0);
        signal s_input_valids : std_logic_vector(s_inputs'range);
        
    begin
        
        gen_first_stage: if (stage_num = c_num_stages) generate
            gen_first_inputs: for i in s_inputs'range generate
                gen_true_input: if (i < g_num_terms) generate
                    s_inputs(i) <= i_terms(i);
                    s_input_valids(i) <= i_term_valids(i);
                end generate gen_true_input;
                gen_zeroed_input: if (i >= g_num_terms) generate
                    s_inputs(i) <= (others => '0');
                    s_input_valids(i) <= '1';
                end generate gen_zeroed_input;
            end generate gen_first_inputs;
        end generate gen_first_stage;
        
        gen_n_stage: if (stage_num /= c_num_stages) generate
            gen_n_stage_inputs: for i in s_inputs'range generate
                gen_true_input: if (i < g_num_terms) generate
                    s_inputs(i) <= s_results(stage_num+1, i);
                    s_input_valids(i) <= s_result_valids(stage_num+1, i);
                end generate gen_true_input;
            end generate gen_n_stage_inputs;
        end generate gen_n_stage;
        
        gen_adders: for i in c_num_adders-1 downto 0 generate
            
            adder_inst: entity work.add_floats_wrapper
            port map(
                aclk_0 => i_clk,
                aresetn_0 => i_arstn,
                S_AXIS_A_tdata => s_inputs(2*i),
                S_AXIS_A_tvalid => s_input_valids(2*i),
                S_AXIS_B_tdata => s_inputs(2*i + 1),
                S_AXIS_B_tvalid => s_input_valids(2*i + 1),
                M_AXIS_RESULT_tdata => s_results(stage_num, i),
                M_AXIS_RESULT_tvalid => s_result_valids(stage_num, i)
            );
            
        end generate gen_adders;
        
    end generate gen_stages;
    
    o_result <= s_results(1, 0);
    o_result_valid <= s_result_valids(1, 0);

end Structural;
