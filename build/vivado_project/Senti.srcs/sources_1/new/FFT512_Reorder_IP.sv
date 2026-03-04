// Contract: val_in must be 1 for exactly 512 consecutive cycles per frame.
// After pipeline latency, val_out will be 1 for 512 cycles with natural-order FFT bins.

`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module FFT512_Reorder_IP
    (
    input logic clk, rst, val_in,
    input logic [DATA_INP-1:0] data_in,
    
    output logic [DATA-1:0] data_out,
    output logic val_out
    );

    logic [DATA-1:0] fft_data;
    logic fft_val;

    FFT512 fft512 
    (
        .data_in (data_in),
        .val_in  (val_in),
        .clk     (clk),
        .rst     (rst),
        .data_out(fft_data),
        .val_out (fft_val)
    );

    Reorder_Buffer #(.POINTS(512)) reorder_buffer
    (
        .clk             (clk),
        .rst             (rst),
        .val_fft         (fft_val),
        .fft_output      (fft_data),
        .fft_fixed_output(data_out),
        .val_out_rb      (val_out)
    );

endmodule