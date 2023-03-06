----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 12:22:15 PM
-- Design Name: 
-- Module Name: get_color - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
use work.type_pkg.all;

entity get_color is
    generic(g_num_colors : integer := 5);
    port(
        i_clk : in std_logic;
        i_arstn : in std_logic;
        i_id_in : in integer;
        i_id_valid : in std_logic;
        i_ids : in t_int_arr(g_num_colors-1 downto 0);
        o_color : out std_logic_vector(11 downto 0); --4 bits per channel, RGB
        o_color_valid : out std_logic
    );
end get_color;

architecture Behavioral of get_color is

    constant c_h_step : integer := integer(360.0/real(g_num_colors));
    
    constant c_saturation : unsigned(7 downto 0) := to_unsigned(150, 8);
    constant c_value : unsigned(7 downto 0) := to_unsigned(200, 8);
    
    type r_rgb_type is record -- all in range [0, 255]
        e_r : unsigned(7 downto 0);
        e_g : unsigned(7 downto 0);
        e_b : unsigned(7 downto 0);
    end record;
    
    type t_rgb_array is array(natural range<>) of r_rgb_type;
    
    pure function hsv_to_rgb(
        i_hue : unsigned(8 downto 0); -- [0, 360)
        i_sat : unsigned(7 downto 0); -- [0, 255]
        i_val : unsigned(7 downto 0)  -- [0, 255]
    ) return r_rgb_type is
        variable v_hue : integer := to_integer(i_hue);
        variable v_c : integer := (to_integer(i_val)*to_integer(i_sat))/255;
        variable v_x : integer;
        variable v_m : integer := to_integer(i_val) - v_c;
        variable v_r_prime, v_g_prime, v_b_prime : integer;
        variable v_ans : r_rgb_type;
    begin
        
        --correct for being exactly 360, doesnt need to be an error
        if (v_hue >= 360) then
            v_hue := v_hue - 360;
        end if;
                
        v_x := (v_c*(60 - abs(((v_hue) mod 120) - 60)))/60;
    
        if (v_hue < 60) then
            v_r_prime := v_c;
            v_g_prime := v_x;
            v_b_prime := 0;
        elsif (60 <= v_hue and v_hue < 120) then
            v_r_prime := v_x;
            v_g_prime := v_c;
            v_b_prime := 0;
        elsif (120 <= v_hue and v_hue < 180) then
            v_r_prime := 0;
            v_g_prime := v_c;
            v_b_prime := v_x;
        elsif (180 <= v_hue and v_hue < 240) then
            v_r_prime := 0;
            v_g_prime := v_x;
            v_b_prime := v_c;
        elsif (240 <= v_hue and v_hue < 300) then
            v_r_prime := v_x;
            v_g_prime := 0;
            v_b_prime := v_c;
        elsif (300 <= v_hue) then
            v_r_prime := v_c;
            v_g_prime := 0;
            v_b_prime := v_x;
        else
            report "Error: v_hue = " & to_string(v_hue) severity failure;
        end if;
    
        v_ans.e_r := to_unsigned(v_r_prime + v_m, v_ans.e_r'length);
        v_ans.e_g := to_unsigned(v_g_prime + v_m, v_ans.e_g'length);
        v_ans.e_b := to_unsigned(v_b_prime + v_m, v_ans.e_b'length);
        
        return v_ans;
        
    end function;
    
    pure function rgb_to_color_vect(i_rgb : r_rgb_type; i_bits_per_channel : integer) return std_logic_vector is
        constant c_max_channel_val : integer := (2**i_bits_per_channel) - 1;
        variable v_r, v_g, v_b : std_logic_vector(i_bits_per_channel-1 downto 0);
        variable v_ans : std_logic_vector(3*i_bits_per_channel-1 downto 0);
    begin
        v_r := std_logic_vector(to_unsigned((to_integer(i_rgb.e_r)*c_max_channel_val)/255, v_r'length));
        v_g := std_logic_vector(to_unsigned((to_integer(i_rgb.e_g)*c_max_channel_val)/255, v_g'length));
        v_b := std_logic_vector(to_unsigned((to_integer(i_rgb.e_b)*c_max_channel_val)/255, v_b'length));
        v_ans := v_r & v_g & v_b;
        return v_ans;
    end function;
    
    type t_color_vect_arr is array(natural range<>) of std_logic_vector(o_color'range);
    
    function assign_colors return t_color_vect_arr is
        variable v_ans : t_color_vect_arr(i_ids'range);
    begin
        for i in v_ans'range loop
            v_ans(i) := rgb_to_color_vect(hsv_to_rgb(to_unsigned(i*c_h_step, 9), c_saturation, c_value), 4);
        end loop;
        return v_ans;
    end function;
    
    constant c_colors : t_color_vect_arr(i_ids'range) := assign_colors;
    
begin
    
    process(i_clk, i_arstn) is
        variable v_id_idx : integer;    
    begin
        if rising_edge(i_clk) then
        
            v_id_idx := i_ids'low;
            for i in i_ids'range loop
                if (i_id_in = i_ids(i)) then
                    v_id_idx := i; --TODO: do this better
                end if;
            end loop;
                    
            o_color <= c_colors(v_id_idx);
            o_color_valid <= i_id_valid;
            
        end if;
        if (i_arstn = '0') then
            o_color_valid <= '0';
        end if;
    end process;

end Behavioral;
