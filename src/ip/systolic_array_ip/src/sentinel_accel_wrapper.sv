`timescale 1ns / 1ps
import systolic_array_pkg::*;

module sentinel_accel_wrapper #(
    parameter K = 512,
    parameter N = 16,
    parameter PE_INP_WIDTH = 18,
    parameter PE_ACCUM_WIDTH = 45
)(
    input  logic clk,
    input  logic rst_n,                    // Active-low reset for AXI compatibility
    
    // Control interface (AXI-Lite style, simplified)
    input  logic        arm_start,         // Trigger computation
    input  logic        load_mode,         // 1=load weights, 0=compute
    output logic        done_o,            // Computation complete
    
    // Weight loading interface (serial)
    input  logic [PE_INP_WIDTH-1:0] weight_load_data,
    input  logic [3:0]              weight_load_row,
    input  logic [3:0]              weight_load_col,
    input  logic                    weight_load_en,
    
    // FFT Data input (streaming)
    input  logic [53:0]             fft_data_in,     // {imag[26:0], real[26:0]}
    input  logic                    fft_valid_in,
    output logic                    fft_ready_out,   // Always ready in this design
    
    // Result output (memory-mapped style)
    input  logic [7:0]              result_addr,     // 0-255
    output logic [PE_ACCUM_WIDTH-1:0] result_data,
    output logic                    result_valid
);

    // Internal signals
    logic rst;
    assign rst = ~rst_n;  // Convert to active-high for internal modules
    
    // Feature Extractor signals
    logic [PE_INP_WIDTH-1:0] fe_activation_out;
    logic                    fe_valid_out;
    logic                    fe_frame_done;
    
    // Broadcast to all 16 rows
    logic [15:0][PE_INP_WIDTH-1:0] broadcast_data;
    logic [15:0]                   broadcast_enable;
    
    assign broadcast_data = {16{fe_activation_out}};
    assign broadcast_enable = {16{fe_valid_out}};
    assign fft_ready_out = 1'b1;  // Always ready to accept FFT data
    
    // Feature Extractor instantiation
    feature_extractor fe_inst (
        .clk(clk),
        .rst(rst),
        .fft_valout(fft_valid_in),
        .fft_data_out(fft_data_in),
        .arm_start(arm_start),
        .sa_activation_data(fe_activation_out),
        .sa_activation_valid(fe_valid_out),
        .frame_done(fe_frame_done)
    );
    
    // Systolic Array instantiation
    systolic_array_16x16 sa_inst (
        .clk(clk),
        .rst(rst),
        .left_activation_i(broadcast_data),
        .left_enable_i(broadcast_enable),
        .weight_load_data(weight_load_data),
        .weight_load_row(weight_load_row),
        .weight_load_col(weight_load_col),
        .weight_load_en(weight_load_en),
        .load_mode(load_mode),
        .result_addr_i(result_addr),
        .result_o(result_data),
        .done_o(done_o)
    );
    
    assign result_valid = done_o;  // Results valid when array completes

endmodule