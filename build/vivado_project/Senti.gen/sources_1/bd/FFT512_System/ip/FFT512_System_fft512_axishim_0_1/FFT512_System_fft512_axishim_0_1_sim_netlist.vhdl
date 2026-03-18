-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
-- Date        : Sun Mar  8 04:00:58 2026
-- Host        : archlinux running 64-bit Arch Linux
-- Command     : write_vhdl -force -mode funcsim
--               /home/Rati/Desktop/Personal_Projects/Sentinel/Senti/build/vivado_project/Senti.gen/sources_1/bd/FFT512_System/ip/FFT512_System_fft512_axishim_0_1/FFT512_System_fft512_axishim_0_1_sim_netlist.vhdl
-- Design      : FFT512_System_fft512_axishim_0_1
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xck26-sfvc784-2LV-c
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity FFT512_System_fft512_axishim_0_1_fft512_axishim is
  port (
    s_axis_tready : out STD_LOGIC;
    fft_valin : out STD_LOGIC;
    m_axis_tlast : out STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    rst : in STD_LOGIC;
    clk : in STD_LOGIC;
    fft_valout : in STD_LOGIC;
    m_axis_tready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of FFT512_System_fft512_axishim_0_1_fft512_axishim : entity is "fft512_axishim";
end FFT512_System_fft512_axishim_0_1_fft512_axishim;

architecture STRUCTURE of FFT512_System_fft512_axishim_0_1_fft512_axishim is
  signal \^fft_valin\ : STD_LOGIC;
  signal in_active_i_1_n_0 : STD_LOGIC;
  signal in_active_i_2_n_0 : STD_LOGIC;
  signal \in_cnt[9]_i_2_n_0\ : STD_LOGIC;
  signal in_cnt_reg : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal m_axis_tlast_INST_0_i_1_n_0 : STD_LOGIC;
  signal m_axis_tlast_INST_0_i_2_n_0 : STD_LOGIC;
  signal out_active_i_1_n_0 : STD_LOGIC;
  signal out_active_reg_n_0 : STD_LOGIC;
  signal \out_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[1]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[2]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[2]_i_2_n_0\ : STD_LOGIC;
  signal \out_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[4]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[5]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[6]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[6]_i_2_n_0\ : STD_LOGIC;
  signal \out_cnt[7]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[7]_i_2_n_0\ : STD_LOGIC;
  signal \out_cnt[8]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[9]_i_1_n_0\ : STD_LOGIC;
  signal \out_cnt[9]_i_2_n_0\ : STD_LOGIC;
  signal out_cnt_reg : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal p_0_in : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal \^s_axis_tready\ : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of in_active_i_2 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \in_cnt[1]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \in_cnt[2]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \in_cnt[3]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \in_cnt[4]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \in_cnt[7]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \in_cnt[8]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \in_cnt[9]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of m_axis_tlast_INST_0_i_1 : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of m_axis_tvalid_INST_0 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \out_cnt[0]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \out_cnt[2]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \out_cnt[2]_i_2\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \out_cnt[3]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \out_cnt[4]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \out_cnt[5]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \out_cnt[8]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \out_cnt[9]_i_1\ : label is "soft_lutpair6";
begin
  fft_valin <= \^fft_valin\;
  s_axis_tready <= \^s_axis_tready\;
fft_valin_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axis_tvalid,
      I1 => \^s_axis_tready\,
      O => \^fft_valin\
    );
in_active_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CC8C"
    )
        port map (
      I0 => in_active_i_2_n_0,
      I1 => \^s_axis_tready\,
      I2 => s_axis_tvalid,
      I3 => in_cnt_reg(9),
      O => in_active_i_1_n_0
    );
in_active_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DFFF"
    )
        port map (
      I0 => in_cnt_reg(7),
      I1 => \in_cnt[9]_i_2_n_0\,
      I2 => in_cnt_reg(6),
      I3 => in_cnt_reg(8),
      O => in_active_i_2_n_0
    );
in_active_reg: unisim.vcomponents.FDSE
     port map (
      C => clk,
      CE => '1',
      D => in_active_i_1_n_0,
      Q => \^s_axis_tready\,
      S => rst
    );
\in_cnt[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => in_cnt_reg(0),
      O => p_0_in(0)
    );
\in_cnt[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => in_cnt_reg(0),
      I1 => in_cnt_reg(1),
      O => p_0_in(1)
    );
\in_cnt[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => in_cnt_reg(1),
      I1 => in_cnt_reg(0),
      I2 => in_cnt_reg(2),
      O => p_0_in(2)
    );
\in_cnt[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => in_cnt_reg(2),
      I1 => in_cnt_reg(0),
      I2 => in_cnt_reg(1),
      I3 => in_cnt_reg(3),
      O => p_0_in(3)
    );
\in_cnt[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => in_cnt_reg(3),
      I1 => in_cnt_reg(1),
      I2 => in_cnt_reg(0),
      I3 => in_cnt_reg(2),
      I4 => in_cnt_reg(4),
      O => p_0_in(4)
    );
\in_cnt[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => in_cnt_reg(4),
      I1 => in_cnt_reg(2),
      I2 => in_cnt_reg(0),
      I3 => in_cnt_reg(1),
      I4 => in_cnt_reg(3),
      I5 => in_cnt_reg(5),
      O => p_0_in(5)
    );
\in_cnt[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => \in_cnt[9]_i_2_n_0\,
      I1 => in_cnt_reg(6),
      O => p_0_in(6)
    );
\in_cnt[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D2"
    )
        port map (
      I0 => in_cnt_reg(6),
      I1 => \in_cnt[9]_i_2_n_0\,
      I2 => in_cnt_reg(7),
      O => p_0_in(7)
    );
\in_cnt[8]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DF20"
    )
        port map (
      I0 => in_cnt_reg(7),
      I1 => \in_cnt[9]_i_2_n_0\,
      I2 => in_cnt_reg(6),
      I3 => in_cnt_reg(8),
      O => p_0_in(8)
    );
\in_cnt[9]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F7FF0800"
    )
        port map (
      I0 => in_cnt_reg(8),
      I1 => in_cnt_reg(6),
      I2 => \in_cnt[9]_i_2_n_0\,
      I3 => in_cnt_reg(7),
      I4 => in_cnt_reg(9),
      O => p_0_in(9)
    );
\in_cnt[9]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => in_cnt_reg(4),
      I1 => in_cnt_reg(2),
      I2 => in_cnt_reg(0),
      I3 => in_cnt_reg(1),
      I4 => in_cnt_reg(3),
      I5 => in_cnt_reg(5),
      O => \in_cnt[9]_i_2_n_0\
    );
\in_cnt_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(0),
      Q => in_cnt_reg(0),
      R => rst
    );
\in_cnt_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(1),
      Q => in_cnt_reg(1),
      R => rst
    );
\in_cnt_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(2),
      Q => in_cnt_reg(2),
      R => rst
    );
\in_cnt_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(3),
      Q => in_cnt_reg(3),
      R => rst
    );
\in_cnt_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(4),
      Q => in_cnt_reg(4),
      R => rst
    );
\in_cnt_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(5),
      Q => in_cnt_reg(5),
      R => rst
    );
\in_cnt_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(6),
      Q => in_cnt_reg(6),
      R => rst
    );
\in_cnt_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(7),
      Q => in_cnt_reg(7),
      R => rst
    );
\in_cnt_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(8),
      Q => in_cnt_reg(8),
      R => rst
    );
\in_cnt_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \^fft_valin\,
      D => p_0_in(9),
      Q => in_cnt_reg(9),
      R => rst
    );
m_axis_tlast_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4000000000000000"
    )
        port map (
      I0 => m_axis_tlast_INST_0_i_1_n_0,
      I1 => out_cnt_reg(1),
      I2 => out_cnt_reg(0),
      I3 => out_cnt_reg(3),
      I4 => out_cnt_reg(2),
      I5 => m_axis_tlast_INST_0_i_2_n_0,
      O => m_axis_tlast
    );
m_axis_tlast_INST_0_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => fft_valout,
      I1 => out_active_reg_n_0,
      O => m_axis_tlast_INST_0_i_1_n_0
    );
m_axis_tlast_INST_0_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000800000000000"
    )
        port map (
      I0 => out_cnt_reg(6),
      I1 => out_cnt_reg(7),
      I2 => out_cnt_reg(4),
      I3 => out_cnt_reg(5),
      I4 => out_cnt_reg(9),
      I5 => out_cnt_reg(8),
      O => m_axis_tlast_INST_0_i_2_n_0
    );
m_axis_tvalid_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => out_active_reg_n_0,
      I1 => fft_valout,
      O => m_axis_tvalid
    );
out_active_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A8AA"
    )
        port map (
      I0 => out_active_reg_n_0,
      I1 => out_cnt_reg(9),
      I2 => \out_cnt[9]_i_2_n_0\,
      I3 => out_cnt_reg(8),
      O => out_active_i_1_n_0
    );
out_active_reg: unisim.vcomponents.FDSE
     port map (
      C => clk,
      CE => '1',
      D => out_active_i_1_n_0,
      Q => out_active_reg_n_0,
      S => rst
    );
\out_cnt[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00007F80"
    )
        port map (
      I0 => out_active_reg_n_0,
      I1 => fft_valout,
      I2 => m_axis_tready,
      I3 => out_cnt_reg(0),
      I4 => rst,
      O => \out_cnt[0]_i_1_n_0\
    );
\out_cnt[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00007FFF00008000"
    )
        port map (
      I0 => m_axis_tready,
      I1 => fft_valout,
      I2 => out_active_reg_n_0,
      I3 => out_cnt_reg(0),
      I4 => rst,
      I5 => out_cnt_reg(1),
      O => \out_cnt[1]_i_1_n_0\
    );
\out_cnt[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"21"
    )
        port map (
      I0 => \out_cnt[2]_i_2_n_0\,
      I1 => rst,
      I2 => out_cnt_reg(2),
      O => \out_cnt[2]_i_1_n_0\
    );
\out_cnt[2]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
        port map (
      I0 => out_cnt_reg(0),
      I1 => out_active_reg_n_0,
      I2 => fft_valout,
      I3 => m_axis_tready,
      I4 => out_cnt_reg(1),
      O => \out_cnt[2]_i_2_n_0\
    );
\out_cnt[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"21"
    )
        port map (
      I0 => \out_cnt[6]_i_2_n_0\,
      I1 => rst,
      I2 => out_cnt_reg(3),
      O => \out_cnt[3]_i_1_n_0\
    );
\out_cnt[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0B04"
    )
        port map (
      I0 => \out_cnt[6]_i_2_n_0\,
      I1 => out_cnt_reg(3),
      I2 => rst,
      I3 => out_cnt_reg(4),
      O => \out_cnt[4]_i_1_n_0\
    );
\out_cnt[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00DF0020"
    )
        port map (
      I0 => out_cnt_reg(3),
      I1 => \out_cnt[6]_i_2_n_0\,
      I2 => out_cnt_reg(4),
      I3 => rst,
      I4 => out_cnt_reg(5),
      O => \out_cnt[5]_i_1_n_0\
    );
\out_cnt[6]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000DFFF00002000"
    )
        port map (
      I0 => out_cnt_reg(4),
      I1 => \out_cnt[6]_i_2_n_0\,
      I2 => out_cnt_reg(3),
      I3 => out_cnt_reg(5),
      I4 => rst,
      I5 => out_cnt_reg(6),
      O => \out_cnt[6]_i_1_n_0\
    );
\out_cnt[6]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => out_cnt_reg(1),
      I1 => m_axis_tready,
      I2 => fft_valout,
      I3 => out_active_reg_n_0,
      I4 => out_cnt_reg(0),
      I5 => out_cnt_reg(2),
      O => \out_cnt[6]_i_2_n_0\
    );
\out_cnt[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"21"
    )
        port map (
      I0 => \out_cnt[7]_i_2_n_0\,
      I1 => rst,
      I2 => out_cnt_reg(7),
      O => \out_cnt[7]_i_1_n_0\
    );
\out_cnt[7]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F7FFFFFF"
    )
        port map (
      I0 => out_cnt_reg(5),
      I1 => out_cnt_reg(3),
      I2 => \out_cnt[6]_i_2_n_0\,
      I3 => out_cnt_reg(4),
      I4 => out_cnt_reg(6),
      O => \out_cnt[7]_i_2_n_0\
    );
\out_cnt[8]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"21"
    )
        port map (
      I0 => \out_cnt[9]_i_2_n_0\,
      I1 => rst,
      I2 => out_cnt_reg(8),
      O => \out_cnt[8]_i_1_n_0\
    );
\out_cnt[9]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0B04"
    )
        port map (
      I0 => \out_cnt[9]_i_2_n_0\,
      I1 => out_cnt_reg(8),
      I2 => rst,
      I3 => out_cnt_reg(9),
      O => \out_cnt[9]_i_1_n_0\
    );
\out_cnt[9]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7FFFFFFFFFFFFFF"
    )
        port map (
      I0 => out_cnt_reg(6),
      I1 => out_cnt_reg(4),
      I2 => \out_cnt[6]_i_2_n_0\,
      I3 => out_cnt_reg(3),
      I4 => out_cnt_reg(5),
      I5 => out_cnt_reg(7),
      O => \out_cnt[9]_i_2_n_0\
    );
\out_cnt_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[0]_i_1_n_0\,
      Q => out_cnt_reg(0),
      R => '0'
    );
\out_cnt_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[1]_i_1_n_0\,
      Q => out_cnt_reg(1),
      R => '0'
    );
\out_cnt_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[2]_i_1_n_0\,
      Q => out_cnt_reg(2),
      R => '0'
    );
\out_cnt_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[3]_i_1_n_0\,
      Q => out_cnt_reg(3),
      R => '0'
    );
\out_cnt_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[4]_i_1_n_0\,
      Q => out_cnt_reg(4),
      R => '0'
    );
\out_cnt_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[5]_i_1_n_0\,
      Q => out_cnt_reg(5),
      R => '0'
    );
\out_cnt_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[6]_i_1_n_0\,
      Q => out_cnt_reg(6),
      R => '0'
    );
\out_cnt_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[7]_i_1_n_0\,
      Q => out_cnt_reg(7),
      R => '0'
    );
\out_cnt_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[8]_i_1_n_0\,
      Q => out_cnt_reg(8),
      R => '0'
    );
\out_cnt_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \out_cnt[9]_i_1_n_0\,
      Q => out_cnt_reg(9),
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity FFT512_System_fft512_axishim_0_1 is
  port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tlast : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    fft_valin : out STD_LOGIC;
    fft_datain : out STD_LOGIC_VECTOR ( 17 downto 0 );
    fft_valout : in STD_LOGIC;
    fft_dataout : in STD_LOGIC_VECTOR ( 53 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of FFT512_System_fft512_axishim_0_1 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of FFT512_System_fft512_axishim_0_1 : entity is "FFT512_System_fft512_axishim_0_1,fft512_axishim,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of FFT512_System_fft512_axishim_0_1 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of FFT512_System_fft512_axishim_0_1 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of FFT512_System_fft512_axishim_0_1 : entity is "fft512_axishim,Vivado 2025.2";
end FFT512_System_fft512_axishim_0_1;

architecture STRUCTURE of FFT512_System_fft512_axishim_0_1 is
  signal \<const0>\ : STD_LOGIC;
  signal \^fft_dataout\ : STD_LOGIC_VECTOR ( 53 downto 0 );
  signal \^s_axis_tdata\ : STD_LOGIC_VECTOR ( 63 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of clk : signal is "slave";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET rst, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN FFT512_System_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m_axis_tlast : signal is "xilinx.com:interface:axis:1.0 m_axis TLAST";
  attribute X_INTERFACE_INFO of m_axis_tready : signal is "xilinx.com:interface:axis:1.0 m_axis TREADY";
  attribute X_INTERFACE_INFO of m_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 m_axis TVALID";
  attribute X_INTERFACE_INFO of rst : signal is "xilinx.com:signal:reset:1.0 rst RST";
  attribute X_INTERFACE_MODE of rst : signal is "slave";
  attribute X_INTERFACE_PARAMETER of rst : signal is "XIL_INTERFACENAME rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axis_tready : signal is "xilinx.com:interface:axis:1.0 s_axis TREADY";
  attribute X_INTERFACE_INFO of s_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 s_axis TVALID";
  attribute X_INTERFACE_INFO of m_axis_tdata : signal is "xilinx.com:interface:axis:1.0 m_axis TDATA";
  attribute X_INTERFACE_MODE of m_axis_tdata : signal is "master";
  attribute X_INTERFACE_PARAMETER of m_axis_tdata : signal is "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 99999001, PHASE 0.0, CLK_DOMAIN FFT512_System_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axis_tdata : signal is "xilinx.com:interface:axis:1.0 s_axis TDATA";
  attribute X_INTERFACE_MODE of s_axis_tdata : signal is "slave";
  attribute X_INTERFACE_PARAMETER of s_axis_tdata : signal is "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 99999001, PHASE 0.0, CLK_DOMAIN FFT512_System_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0";
begin
  \^fft_dataout\(53 downto 0) <= fft_dataout(53 downto 0);
  \^s_axis_tdata\(17 downto 0) <= s_axis_tdata(17 downto 0);
  fft_datain(17 downto 0) <= \^s_axis_tdata\(17 downto 0);
  m_axis_tdata(63) <= \<const0>\;
  m_axis_tdata(62) <= \<const0>\;
  m_axis_tdata(61) <= \<const0>\;
  m_axis_tdata(60) <= \<const0>\;
  m_axis_tdata(59) <= \<const0>\;
  m_axis_tdata(58) <= \<const0>\;
  m_axis_tdata(57) <= \<const0>\;
  m_axis_tdata(56) <= \<const0>\;
  m_axis_tdata(55) <= \<const0>\;
  m_axis_tdata(54) <= \<const0>\;
  m_axis_tdata(53 downto 0) <= \^fft_dataout\(53 downto 0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.FFT512_System_fft512_axishim_0_1_fft512_axishim
     port map (
      clk => clk,
      fft_valin => fft_valin,
      fft_valout => fft_valout,
      m_axis_tlast => m_axis_tlast,
      m_axis_tready => m_axis_tready,
      m_axis_tvalid => m_axis_tvalid,
      rst => rst,
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid
    );
end STRUCTURE;
