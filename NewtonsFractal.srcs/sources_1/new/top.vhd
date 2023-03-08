----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2023 08:08:58 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port ( 
        i_clk, i_rst_btn : in STD_LOGIC;
        o_h_sync, o_v_sync : out std_logic;
        o_pixel : out STD_LOGIC_VECTOR (11 downto 0)
    );
end top;

architecture Behavioral of top is

    signal s_rst, s_rstn : std_logic;
    
    signal s_v_sync_inital, s_h_sync_inital : std_logic;
    signal s_v_sync_polarity : std_logic;
    
    signal s_frame_begun : std_logic;
    signal s_v_sync_initial_active : std_logic;
    signal s_sync_sigs_valid : std_logic;
    
    signal s_row, s_col : integer;
    signal s_img_width, s_img_height : integer;
    
    --1.0 in double precision floating point format
    constant c_dbl_flt_1 : std_logic_vector(63 downto 0) := x"3FF0000000000000";
    constant c_dbl_flt_0 : std_logic_vector(63 downto 0) := (others => '0');
    constant c_dbl_flt_0p309 : std_logic_vector(63 downto 0) := x"3FD3C6EF3D3A1D32";
    constant c_dbl_flt_n0p809 : std_logic_vector(63 downto 0) := x"BFE9E3779E9D0E99";
    constant c_dbl_flt_n0p951 : std_logic_vector(63 downto 0) := x"BFEE6F0F16F4384C";
    constant c_dbl_flt_n0p588 : std_logic_vector(63 downto 0) := x"BFE2CF227D028A1E";
    constant c_dbl_flt_0p951 : std_logic_vector(63 downto 0) := x"3FEE6F0F16F4384C";
    constant c_dbl_flt_0p588 : std_logic_vector(63 downto 0) := x"3FE2CF227D028A1E";
    
    signal s_pixel_valid : std_logic;
    
    constant c_num_roots : integer := 5;
    signal s_roots_x, s_roots_y : t_double_arr(c_num_roots-1 downto 0);
    
begin

    s_rstn <= not s_rst;
    
    s_v_sync_initial_active <= '1' when s_v_sync_inital = s_v_sync_polarity else '0';
    
    s_roots_x(0) <= c_dbl_flt_1;
    s_roots_y(0) <= c_dbl_flt_0;
    s_roots_x(1) <= c_dbl_flt_0p309;
    s_roots_y(1) <= c_dbl_flt_n0p951;
    s_roots_x(2) <= c_dbl_flt_n0p809;
    s_roots_y(2) <= c_dbl_flt_n0p588;
    s_roots_x(3) <= c_dbl_flt_n0p809;
    s_roots_y(3) <= c_dbl_flt_0p588;
    s_roots_x(4) <= c_dbl_flt_0p309;
    s_roots_y(4) <= c_dbl_flt_0p951;
    
    process(i_clk) is begin
        if rising_edge(i_clk) then
            
            if (s_v_sync_initial_active = '1') then
                s_frame_begun <= '1';
            end if;
            
            if (s_rst = '1') then
                s_frame_begun <= '0';
            end if;
            
        end if;
    end process;
    
    s_sync_sigs_valid <= s_v_sync_initial_active or s_frame_begun;
    
    rst_debounce_inst: entity work.button_conditioner
    generic map(
        g_metastability_stages => 4,
        g_stable_cycles => 100_000
    )
    port map(
        i_clk => i_clk,
        i_rst => '0',
        i_btn => i_rst_btn,
        o_stablized => open,
        o_debounced => s_rst,
        o_pos_pulse => open,
        o_neg_pulse => open
    );

    vga_cont_inst: entity work.vga_controller
    port map(
        i_clk => i_clk,
        i_rst_n => s_rstn,
        o_h_sync => s_h_sync_inital,
        o_v_sync => s_v_sync_inital,
        o_v_sync_polarity => s_v_sync_polarity,
        o_disp_ena => open,
        o_column => s_col,
        o_row => s_row,
        o_h_pixels => s_img_width,
        o_v_pixels => s_img_height
    );
    
    vga_sync_buf_inst: entity work.vga_sync_buffer_wrapper
    port map(
        clk_0 => i_clk,
        srst_0 => s_rst,
        i_v_sync => s_v_sync_inital,
        i_h_sync => s_h_sync_inital,
        o_v_sync => o_v_sync,
        o_h_sync => o_h_sync,
        rd_en_0 => s_pixel_valid,
        wr_en_0 => s_sync_sigs_valid
    );
    
    pg_inst: entity work.pixel_gen
    generic map(
        g_num_roots => c_num_roots
    )
    port map(
        i_clk => i_clk,
        i_arstn => s_rstn,
        i_root_xs => s_roots_x, --TODO: make root controls
        i_root_ys => s_roots_y,
        i_pixel_x => s_col,
        i_pixel_y => s_row,
        i_img_width => s_img_width,
        i_img_height => s_img_height,
        i_scale => c_dbl_flt_1, --TODO: make scale controls
        i_pixel_coord_valid => s_sync_sigs_valid,
        o_pixel => o_pixel,
        o_pixel_valid => s_pixel_valid
    );

end Behavioral;
