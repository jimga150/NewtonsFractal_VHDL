--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Tue Mar  7 20:01:09 2023
--Host        : DESKTOP-F1LS71S running 64-bit major release  (build 9200)
--Command     : generate_target vga_sync_buffer_wrapper.bd
--Design      : vga_sync_buffer_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity vga_sync_buffer_wrapper is
  port (
    clk_0 : in STD_LOGIC;
    i_v_sync, i_h_sync : in STD_LOGIC;
    o_v_sync, o_h_sync : out STD_LOGIC;
    rd_en_0 : in STD_LOGIC;
    srst_0 : in STD_LOGIC;
    wr_en_0 : in STD_LOGIC
  );
end vga_sync_buffer_wrapper;

architecture STRUCTURE of vga_sync_buffer_wrapper is
  component vga_sync_buffer is
  port (
    dout_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    rd_en_0 : in STD_LOGIC;
    din_0 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    wr_en_0 : in STD_LOGIC;
    clk_0 : in STD_LOGIC;
    srst_0 : in STD_LOGIC
  );
  end component vga_sync_buffer;
begin
vga_sync_buffer_i: component vga_sync_buffer
     port map (
      clk_0 => clk_0,
      din_0(1) => i_v_sync,
      din_0(0) => i_h_sync,
      dout_0(1) => o_v_sync,
      dout_0(0) => o_h_sync,
      rd_en_0 => rd_en_0,
      srst_0 => srst_0,
      wr_en_0 => wr_en_0
    );
end STRUCTURE;
