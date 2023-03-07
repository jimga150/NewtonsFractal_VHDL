--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Mon Mar  6 20:27:55 2023
--Host        : DESKTOP-F1LS71S running 64-bit major release  (build 9200)
--Command     : generate_target complex_fifo_wrapper.bd
--Design      : complex_fifo_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity complex_fifo_wrapper is
  port (
    i_clk : in STD_LOGIC;
    i_arstn : in STD_LOGIC;
    i_x, i_y : in STD_LOGIC_VECTOR ( 63 downto 0 );
--    o_input_ready : out STD_LOGIC;
    i_input_valid : in STD_LOGIC;
    o_x, o_y : out STD_LOGIC_VECTOR ( 63 downto 0 );
    i_downstream_ready : in STD_LOGIC;
    o_complex_valid : out STD_LOGIC
  );
end complex_fifo_wrapper;

architecture STRUCTURE of complex_fifo_wrapper is
  component complex_fifo is
  port (
    s_axis_aclk_0 : in STD_LOGIC;
    s_axis_aresetn_0 : in STD_LOGIC;
    M_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    M_AXIS_0_tready : in STD_LOGIC;
    M_AXIS_0_tvalid : out STD_LOGIC;
    S_AXIS_0_tdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    S_AXIS_0_tready : out STD_LOGIC;
    S_AXIS_0_tvalid : in STD_LOGIC
  );
  end component complex_fifo;
  
  signal s_output_data, s_input_data : std_logic_vector(127 downto 0);
  
begin
    complex_fifo_i: component complex_fifo
    port map (
        M_AXIS_0_tdata(127 downto 0) => s_output_data,
        M_AXIS_0_tready => i_downstream_ready,
        M_AXIS_0_tvalid => o_complex_valid,
        S_AXIS_0_tdata(127 downto 0) => s_input_data,
--        S_AXIS_0_tready => o_input_ready,
        S_AXIS_0_tvalid => i_input_valid,
        s_axis_aclk_0 => i_clk,
        s_axis_aresetn_0 => i_arstn
    );
    
    s_input_data <= i_x & i_y;
    o_x <= s_output_data(127 downto 64);
    o_y <= s_output_data(63 downto 0);
    
end STRUCTURE;
