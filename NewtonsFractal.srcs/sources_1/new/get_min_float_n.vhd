----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 10:32:32 AM
-- Design Name: 
-- Module Name: get_min_float_n - Structural
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

entity get_min_float_n is
    generic(g_num_floats : integer := 5);
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_flts : in t_double_arr(g_num_floats-1 downto 0);
        i_flt_ids : in t_int_arr(g_num_floats-1 downto 0);
        i_flt_valids : in std_logic_vector(g_num_floats-1 downto 0);
        o_min : out std_logic_vector(63 downto 0);
        o_min_id : out integer;
        o_min_valid : out std_logic
    );
end get_min_float_n;

architecture Structural of get_min_float_n is

    pure function get_num_minners(i_stage_num : integer) return integer is begin
        return 2**(i_stage_num-1);
    end function;
    
    -- why do i have to add 0.000000000000000000000001?
    -- in synthesis, you dont--since for example, log2(4.0) = 2.0, which will floor() to 2.
    -- in SIMULATION, for some godforsaken reason, operations like log2(4.0) evaluate to something like 1.99999999999, which then floor to 1.
    -- solution: make the argument slightly greater to avoid passing in a round number, but not by enough to make it graduate to the next integer of log2() values.
    constant c_num_stages : integer := integer(floor(log2(real(g_num_floats-1) + 0.0000000001))) + 1;
    
    signal s_mins : t_double_2d_arr(c_num_stages downto 1, get_num_minners(c_num_stages) - 1 downto 0);
    signal s_min_ids : t_int_2d_arr(s_mins'range(1), s_mins'range(2));
    signal s_min_valids : t_std_logic_2d_arr(s_mins'range(1), s_mins'range(2));

begin

    gen_stages: for stage_num in c_num_stages downto 1 generate
        
        constant c_num_minners : integer := get_num_minners(stage_num);
        
        signal s_inputs : t_double_arr( (c_num_minners*2) - 1 downto 0);
        signal s_input_ids : t_int_arr(s_inputs'range);
        signal s_input_valids : std_logic_vector(s_inputs'range);
        
    begin
        
        gen_first_stage: if (stage_num = c_num_stages) generate
            gen_first_inputs: for i in s_inputs'range generate
                gen_true_input: if (i < g_num_floats) generate
                    s_inputs(i) <= i_flts(i);
                    s_input_ids(i) <= i_flt_ids(i);
                    s_input_valids(i) <= i_flt_valids(i);
                end generate gen_true_input;
                gen_zeroed_input: if (i >= g_num_floats) generate
                    s_inputs(i) <= c_double_max;
                    s_input_ids(i) <= -1;
                    s_input_valids(i) <= '1';
                end generate gen_zeroed_input;
            end generate gen_first_inputs;
        end generate gen_first_stage;
        
        gen_n_stage: if (stage_num /= c_num_stages) generate
            gen_n_stage_inputs: for i in s_inputs'range generate
                gen_true_input: if (i < g_num_floats) generate
                    s_inputs(i) <= s_mins(stage_num+1, i);
                    s_input_ids(i) <= s_min_ids(stage_num+1, i);
                    s_input_valids(i) <= s_min_valids(stage_num+1, i);
                end generate gen_true_input;
            end generate gen_n_stage_inputs;
        end generate gen_n_stage;
        
        gen_minners: for i in c_num_minners-1 downto 0 generate
            
            minner_inst: entity work.get_min_float_2
            port map(
                i_clk => i_clk,
                i_arstn => i_arstn,
                i_flt0 => s_inputs(2*i),
                i_flt0_id => s_input_ids(2*i),
                i_flt0_valid => s_input_valids(2*i),
                i_flt1 => s_inputs(2*i + 1),
                i_flt1_id => s_input_ids(2*i + 1),
                i_flt1_valid => s_input_valids(2*i + 1),
                o_min => s_mins(stage_num, i),
                o_min_id => s_min_ids(stage_num, i),
                o_min_valid => s_min_valids(stage_num, i)
            );
            
        end generate gen_minners;
        
    end generate gen_stages;
    
    o_min <= s_mins(1, 0);
    o_min_id <= s_min_ids(1, 0);
    o_min_valid <= s_min_valids(1, 0);

end Structural;
