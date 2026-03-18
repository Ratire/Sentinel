// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
// Date        : Sun Mar  8 04:00:58 2026
// Host        : archlinux running 64-bit Arch Linux
// Command     : write_verilog -force -mode funcsim
//               /home/Rati/Desktop/Personal_Projects/Sentinel/Senti/build/vivado_project/Senti.gen/sources_1/bd/FFT512_System/ip/FFT512_System_fft512_axishim_0_1/FFT512_System_fft512_axishim_0_1_sim_netlist.v
// Design      : FFT512_System_fft512_axishim_0_1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "FFT512_System_fft512_axishim_0_1,fft512_axishim,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "fft512_axishim,Vivado 2025.2" *) 
(* NotValidForBitStream *)
module FFT512_System_fft512_axishim_0_1
   (clk,
    rst,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tready,
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tlast,
    m_axis_tready,
    fft_valin,
    fft_datain,
    fft_valout,
    fft_dataout);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET rst, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN FFT512_System_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input rst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 99999001, PHASE 0.0, CLK_DOMAIN FFT512_System_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [63:0]s_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) output s_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 99999001, PHASE 0.0, CLK_DOMAIN FFT512_System_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [63:0]m_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) output m_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *) output m_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *) input m_axis_tready;
  output fft_valin;
  output [17:0]fft_datain;
  input fft_valout;
  input [53:0]fft_dataout;

  wire \<const0> ;
  wire clk;
  wire [53:0]fft_dataout;
  wire fft_valin;
  wire fft_valout;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire rst;
  wire [63:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;

  assign fft_datain[17:0] = s_axis_tdata[17:0];
  assign m_axis_tdata[63] = \<const0> ;
  assign m_axis_tdata[62] = \<const0> ;
  assign m_axis_tdata[61] = \<const0> ;
  assign m_axis_tdata[60] = \<const0> ;
  assign m_axis_tdata[59] = \<const0> ;
  assign m_axis_tdata[58] = \<const0> ;
  assign m_axis_tdata[57] = \<const0> ;
  assign m_axis_tdata[56] = \<const0> ;
  assign m_axis_tdata[55] = \<const0> ;
  assign m_axis_tdata[54] = \<const0> ;
  assign m_axis_tdata[53:0] = fft_dataout;
  GND GND
       (.G(\<const0> ));
  FFT512_System_fft512_axishim_0_1_fft512_axishim inst
       (.clk(clk),
        .fft_valin(fft_valin),
        .fft_valout(fft_valout),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .rst(rst),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "fft512_axishim" *) 
module FFT512_System_fft512_axishim_0_1_fft512_axishim
   (s_axis_tready,
    fft_valin,
    m_axis_tlast,
    m_axis_tvalid,
    s_axis_tvalid,
    rst,
    clk,
    fft_valout,
    m_axis_tready);
  output s_axis_tready;
  output fft_valin;
  output m_axis_tlast;
  output m_axis_tvalid;
  input s_axis_tvalid;
  input rst;
  input clk;
  input fft_valout;
  input m_axis_tready;

  wire clk;
  wire fft_valin;
  wire fft_valout;
  wire in_active_i_1_n_0;
  wire in_active_i_2_n_0;
  wire \in_cnt[9]_i_2_n_0 ;
  wire [9:0]in_cnt_reg;
  wire m_axis_tlast;
  wire m_axis_tlast_INST_0_i_1_n_0;
  wire m_axis_tlast_INST_0_i_2_n_0;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire out_active_i_1_n_0;
  wire out_active_reg_n_0;
  wire \out_cnt[0]_i_1_n_0 ;
  wire \out_cnt[1]_i_1_n_0 ;
  wire \out_cnt[2]_i_1_n_0 ;
  wire \out_cnt[2]_i_2_n_0 ;
  wire \out_cnt[3]_i_1_n_0 ;
  wire \out_cnt[4]_i_1_n_0 ;
  wire \out_cnt[5]_i_1_n_0 ;
  wire \out_cnt[6]_i_1_n_0 ;
  wire \out_cnt[6]_i_2_n_0 ;
  wire \out_cnt[7]_i_1_n_0 ;
  wire \out_cnt[7]_i_2_n_0 ;
  wire \out_cnt[8]_i_1_n_0 ;
  wire \out_cnt[9]_i_1_n_0 ;
  wire \out_cnt[9]_i_2_n_0 ;
  wire [9:0]out_cnt_reg;
  wire [9:0]p_0_in;
  wire rst;
  wire s_axis_tready;
  wire s_axis_tvalid;

  LUT2 #(
    .INIT(4'h8)) 
    fft_valin_INST_0
       (.I0(s_axis_tvalid),
        .I1(s_axis_tready),
        .O(fft_valin));
  LUT4 #(
    .INIT(16'hCC8C)) 
    in_active_i_1
       (.I0(in_active_i_2_n_0),
        .I1(s_axis_tready),
        .I2(s_axis_tvalid),
        .I3(in_cnt_reg[9]),
        .O(in_active_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hDFFF)) 
    in_active_i_2
       (.I0(in_cnt_reg[7]),
        .I1(\in_cnt[9]_i_2_n_0 ),
        .I2(in_cnt_reg[6]),
        .I3(in_cnt_reg[8]),
        .O(in_active_i_2_n_0));
  FDSE in_active_reg
       (.C(clk),
        .CE(1'b1),
        .D(in_active_i_1_n_0),
        .Q(s_axis_tready),
        .S(rst));
  LUT1 #(
    .INIT(2'h1)) 
    \in_cnt[0]_i_1 
       (.I0(in_cnt_reg[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \in_cnt[1]_i_1 
       (.I0(in_cnt_reg[0]),
        .I1(in_cnt_reg[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \in_cnt[2]_i_1 
       (.I0(in_cnt_reg[1]),
        .I1(in_cnt_reg[0]),
        .I2(in_cnt_reg[2]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \in_cnt[3]_i_1 
       (.I0(in_cnt_reg[2]),
        .I1(in_cnt_reg[0]),
        .I2(in_cnt_reg[1]),
        .I3(in_cnt_reg[3]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \in_cnt[4]_i_1 
       (.I0(in_cnt_reg[3]),
        .I1(in_cnt_reg[1]),
        .I2(in_cnt_reg[0]),
        .I3(in_cnt_reg[2]),
        .I4(in_cnt_reg[4]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \in_cnt[5]_i_1 
       (.I0(in_cnt_reg[4]),
        .I1(in_cnt_reg[2]),
        .I2(in_cnt_reg[0]),
        .I3(in_cnt_reg[1]),
        .I4(in_cnt_reg[3]),
        .I5(in_cnt_reg[5]),
        .O(p_0_in[5]));
  LUT2 #(
    .INIT(4'h9)) 
    \in_cnt[6]_i_1 
       (.I0(\in_cnt[9]_i_2_n_0 ),
        .I1(in_cnt_reg[6]),
        .O(p_0_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hD2)) 
    \in_cnt[7]_i_1 
       (.I0(in_cnt_reg[6]),
        .I1(\in_cnt[9]_i_2_n_0 ),
        .I2(in_cnt_reg[7]),
        .O(p_0_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'hDF20)) 
    \in_cnt[8]_i_1 
       (.I0(in_cnt_reg[7]),
        .I1(\in_cnt[9]_i_2_n_0 ),
        .I2(in_cnt_reg[6]),
        .I3(in_cnt_reg[8]),
        .O(p_0_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hF7FF0800)) 
    \in_cnt[9]_i_1 
       (.I0(in_cnt_reg[8]),
        .I1(in_cnt_reg[6]),
        .I2(\in_cnt[9]_i_2_n_0 ),
        .I3(in_cnt_reg[7]),
        .I4(in_cnt_reg[9]),
        .O(p_0_in[9]));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \in_cnt[9]_i_2 
       (.I0(in_cnt_reg[4]),
        .I1(in_cnt_reg[2]),
        .I2(in_cnt_reg[0]),
        .I3(in_cnt_reg[1]),
        .I4(in_cnt_reg[3]),
        .I5(in_cnt_reg[5]),
        .O(\in_cnt[9]_i_2_n_0 ));
  FDRE \in_cnt_reg[0] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[0]),
        .Q(in_cnt_reg[0]),
        .R(rst));
  FDRE \in_cnt_reg[1] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[1]),
        .Q(in_cnt_reg[1]),
        .R(rst));
  FDRE \in_cnt_reg[2] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[2]),
        .Q(in_cnt_reg[2]),
        .R(rst));
  FDRE \in_cnt_reg[3] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[3]),
        .Q(in_cnt_reg[3]),
        .R(rst));
  FDRE \in_cnt_reg[4] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[4]),
        .Q(in_cnt_reg[4]),
        .R(rst));
  FDRE \in_cnt_reg[5] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[5]),
        .Q(in_cnt_reg[5]),
        .R(rst));
  FDRE \in_cnt_reg[6] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[6]),
        .Q(in_cnt_reg[6]),
        .R(rst));
  FDRE \in_cnt_reg[7] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[7]),
        .Q(in_cnt_reg[7]),
        .R(rst));
  FDRE \in_cnt_reg[8] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[8]),
        .Q(in_cnt_reg[8]),
        .R(rst));
  FDRE \in_cnt_reg[9] 
       (.C(clk),
        .CE(fft_valin),
        .D(p_0_in[9]),
        .Q(in_cnt_reg[9]),
        .R(rst));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    m_axis_tlast_INST_0
       (.I0(m_axis_tlast_INST_0_i_1_n_0),
        .I1(out_cnt_reg[1]),
        .I2(out_cnt_reg[0]),
        .I3(out_cnt_reg[3]),
        .I4(out_cnt_reg[2]),
        .I5(m_axis_tlast_INST_0_i_2_n_0),
        .O(m_axis_tlast));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h7)) 
    m_axis_tlast_INST_0_i_1
       (.I0(fft_valout),
        .I1(out_active_reg_n_0),
        .O(m_axis_tlast_INST_0_i_1_n_0));
  LUT6 #(
    .INIT(64'h0000800000000000)) 
    m_axis_tlast_INST_0_i_2
       (.I0(out_cnt_reg[6]),
        .I1(out_cnt_reg[7]),
        .I2(out_cnt_reg[4]),
        .I3(out_cnt_reg[5]),
        .I4(out_cnt_reg[9]),
        .I5(out_cnt_reg[8]),
        .O(m_axis_tlast_INST_0_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    m_axis_tvalid_INST_0
       (.I0(out_active_reg_n_0),
        .I1(fft_valout),
        .O(m_axis_tvalid));
  LUT4 #(
    .INIT(16'hA8AA)) 
    out_active_i_1
       (.I0(out_active_reg_n_0),
        .I1(out_cnt_reg[9]),
        .I2(\out_cnt[9]_i_2_n_0 ),
        .I3(out_cnt_reg[8]),
        .O(out_active_i_1_n_0));
  FDSE out_active_reg
       (.C(clk),
        .CE(1'b1),
        .D(out_active_i_1_n_0),
        .Q(out_active_reg_n_0),
        .S(rst));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h00007F80)) 
    \out_cnt[0]_i_1 
       (.I0(out_active_reg_n_0),
        .I1(fft_valout),
        .I2(m_axis_tready),
        .I3(out_cnt_reg[0]),
        .I4(rst),
        .O(\out_cnt[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00007FFF00008000)) 
    \out_cnt[1]_i_1 
       (.I0(m_axis_tready),
        .I1(fft_valout),
        .I2(out_active_reg_n_0),
        .I3(out_cnt_reg[0]),
        .I4(rst),
        .I5(out_cnt_reg[1]),
        .O(\out_cnt[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h21)) 
    \out_cnt[2]_i_1 
       (.I0(\out_cnt[2]_i_2_n_0 ),
        .I1(rst),
        .I2(out_cnt_reg[2]),
        .O(\out_cnt[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \out_cnt[2]_i_2 
       (.I0(out_cnt_reg[0]),
        .I1(out_active_reg_n_0),
        .I2(fft_valout),
        .I3(m_axis_tready),
        .I4(out_cnt_reg[1]),
        .O(\out_cnt[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h21)) 
    \out_cnt[3]_i_1 
       (.I0(\out_cnt[6]_i_2_n_0 ),
        .I1(rst),
        .I2(out_cnt_reg[3]),
        .O(\out_cnt[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h0B04)) 
    \out_cnt[4]_i_1 
       (.I0(\out_cnt[6]_i_2_n_0 ),
        .I1(out_cnt_reg[3]),
        .I2(rst),
        .I3(out_cnt_reg[4]),
        .O(\out_cnt[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h00DF0020)) 
    \out_cnt[5]_i_1 
       (.I0(out_cnt_reg[3]),
        .I1(\out_cnt[6]_i_2_n_0 ),
        .I2(out_cnt_reg[4]),
        .I3(rst),
        .I4(out_cnt_reg[5]),
        .O(\out_cnt[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000DFFF00002000)) 
    \out_cnt[6]_i_1 
       (.I0(out_cnt_reg[4]),
        .I1(\out_cnt[6]_i_2_n_0 ),
        .I2(out_cnt_reg[3]),
        .I3(out_cnt_reg[5]),
        .I4(rst),
        .I5(out_cnt_reg[6]),
        .O(\out_cnt[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \out_cnt[6]_i_2 
       (.I0(out_cnt_reg[1]),
        .I1(m_axis_tready),
        .I2(fft_valout),
        .I3(out_active_reg_n_0),
        .I4(out_cnt_reg[0]),
        .I5(out_cnt_reg[2]),
        .O(\out_cnt[6]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h21)) 
    \out_cnt[7]_i_1 
       (.I0(\out_cnt[7]_i_2_n_0 ),
        .I1(rst),
        .I2(out_cnt_reg[7]),
        .O(\out_cnt[7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hF7FFFFFF)) 
    \out_cnt[7]_i_2 
       (.I0(out_cnt_reg[5]),
        .I1(out_cnt_reg[3]),
        .I2(\out_cnt[6]_i_2_n_0 ),
        .I3(out_cnt_reg[4]),
        .I4(out_cnt_reg[6]),
        .O(\out_cnt[7]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h21)) 
    \out_cnt[8]_i_1 
       (.I0(\out_cnt[9]_i_2_n_0 ),
        .I1(rst),
        .I2(out_cnt_reg[8]),
        .O(\out_cnt[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h0B04)) 
    \out_cnt[9]_i_1 
       (.I0(\out_cnt[9]_i_2_n_0 ),
        .I1(out_cnt_reg[8]),
        .I2(rst),
        .I3(out_cnt_reg[9]),
        .O(\out_cnt[9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF7FFFFFFFFFFFFFF)) 
    \out_cnt[9]_i_2 
       (.I0(out_cnt_reg[6]),
        .I1(out_cnt_reg[4]),
        .I2(\out_cnt[6]_i_2_n_0 ),
        .I3(out_cnt_reg[3]),
        .I4(out_cnt_reg[5]),
        .I5(out_cnt_reg[7]),
        .O(\out_cnt[9]_i_2_n_0 ));
  FDRE \out_cnt_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[0]_i_1_n_0 ),
        .Q(out_cnt_reg[0]),
        .R(1'b0));
  FDRE \out_cnt_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[1]_i_1_n_0 ),
        .Q(out_cnt_reg[1]),
        .R(1'b0));
  FDRE \out_cnt_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[2]_i_1_n_0 ),
        .Q(out_cnt_reg[2]),
        .R(1'b0));
  FDRE \out_cnt_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[3]_i_1_n_0 ),
        .Q(out_cnt_reg[3]),
        .R(1'b0));
  FDRE \out_cnt_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[4]_i_1_n_0 ),
        .Q(out_cnt_reg[4]),
        .R(1'b0));
  FDRE \out_cnt_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[5]_i_1_n_0 ),
        .Q(out_cnt_reg[5]),
        .R(1'b0));
  FDRE \out_cnt_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[6]_i_1_n_0 ),
        .Q(out_cnt_reg[6]),
        .R(1'b0));
  FDRE \out_cnt_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[7]_i_1_n_0 ),
        .Q(out_cnt_reg[7]),
        .R(1'b0));
  FDRE \out_cnt_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[8]_i_1_n_0 ),
        .Q(out_cnt_reg[8]),
        .R(1'b0));
  FDRE \out_cnt_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\out_cnt[9]_i_1_n_0 ),
        .Q(out_cnt_reg[9]),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
