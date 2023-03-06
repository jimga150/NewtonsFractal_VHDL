----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/05/2023 11:20:30 PM
-- Design Name: 
-- Module Name: get_min_float_2 - Structural
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

entity get_min_float_2 is
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_flt0, i_flt1 : in std_logic_vector(63 downto 0);
        i_flt0_id, i_flt1_id : in integer;
        i_flt0_valid, i_flt1_valid : in std_logic;
        o_min : out std_logic_vector(63 downto 0);
        o_min_id : out integer;
        o_min_valid : out std_logic
    );
end get_min_float_2;

architecture Structural of get_min_float_2 is

    constant c_float_min_wrapper_latency : integer := 2;
    
    signal s_flt1_pline, s_flt0_pline : t_double_arr(c_float_min_wrapper_latency downto 1);
    signal s_flt1_id_pline, s_flt0_id_pline : t_int_arr(c_float_min_wrapper_latency downto 1);

    signal s_min_valid : std_logic;
    
    signal s_wrapper_output : std_logic_vector(7 downto 0);
    signal s_result : std_logic;

begin
    
    float_min_inst: entity work.float_min_wrapper
    port map(
        aclk_0 => i_clk,
        aresetn_0 => i_arstn,
        S_AXIS_LH_tdata => i_flt1,
        S_AXIS_LH_tvalid => i_flt1_valid,
        S_AXIS_RH_tdata => i_flt0,
        S_AXIS_RH_tvalid => i_flt0_valid,
        M_AXIS_LH_LT_RH_tdata => s_wrapper_output,
        M_AXIS_LH_LT_RH_tvalid => s_min_valid
    );
    
    s_result <= s_wrapper_output(0);
    
    process(i_clk, i_arstn) is begin
        if (rising_edge(i_clk)) then
        
            s_flt0_pline <= s_flt0_pline(s_flt0_pline'high-1 downto s_flt0_pline'low) & i_flt0;
            s_flt1_pline <= s_flt1_pline(s_flt1_pline'high-1 downto s_flt1_pline'low) & i_flt1;
            
            s_flt0_id_pline <= s_flt0_id_pline(s_flt0_id_pline'high-1 downto s_flt0_id_pline'low) & i_flt0_id;
            s_flt1_id_pline <= s_flt1_id_pline(s_flt1_id_pline'high-1 downto s_flt1_id_pline'low) & i_flt1_id;
            
            if (s_result = '1') then
                o_min <= s_flt1_pline(s_flt1_pline'high);
                --TODO: i didnt do a pipeline for the IDs since i assumed that they are going to change very infrequenctly--only when the number of roots changes.
                o_min_id <= s_flt1_id_pline(s_flt1_id_pline'high); 
            else
                o_min <= s_flt0_pline(s_flt0_pline'high);
                o_min_id <= s_flt0_id_pline(s_flt0_id_pline'high);
            end if;
            
            o_min_valid <= s_min_valid;
            
        end if;
        if (i_arstn = '0') then
            o_min_valid <= '0';
        end if;
    end process;
    

end Structural;
