`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module FFT512
    (
    input logic [DATA_INP-1:0] data_in,
    input logic val_in, clk, rst,
    output logic [DATA-1:0] data_out,
    output logic val_out
    );
    
    logic [DATA-1:0] data_buffer12, data_buffer23, data_buffer34, 
    data_buffer45, data_buffer56, data_buffer67, data_buffer78, data_buffer89;
    
    logic val12, val23, val34, val45, val56, val67, val78, val89;
        
    logic [DATA-1:0] data_in_ext;
    assign data_in_ext = {
                            {{(DATA/2-DATA_INP){data_in[DATA_INP-1]}}, data_in}, // real: sign-extended
                            {DATA/2{1'b0}}                                     // imag: 0
                         };
    
    SDF_mod #(.S(1), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf1 (.data_in(data_in_ext), .val_in(val_in), .clk(clk), .rst(rst), .data_out(data_buffer12), .val_out(val12));
    SDF_mod #(.S(2), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf2 (.data_in(data_buffer12), .val_in(val12), .clk(clk), .rst(rst), .data_out(data_buffer23), .val_out(val23));
    SDF_mod #(.S(3), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf3 (.data_in(data_buffer23), .val_in(val23), .clk(clk), .rst(rst), .data_out(data_buffer34), .val_out(val34));
    SDF_mod #(.S(4), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf4 (.data_in(data_buffer34), .val_in(val34), .clk(clk), .rst(rst), .data_out(data_buffer45), .val_out(val45));
    SDF_mod #(.S(5), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf5 (.data_in(data_buffer45), .val_in(val45), .clk(clk), .rst(rst), .data_out(data_buffer56), .val_out(val56));
    SDF_mod #(.S(6), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf6 (.data_in(data_buffer56), .val_in(val56), .clk(clk), .rst(rst), .data_out(data_buffer67), .val_out(val67));
    SDF_mod #(.S(7), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf7 (.data_in(data_buffer67), .val_in(val67), .clk(clk), .rst(rst), .data_out(data_buffer78), .val_out(val78));
    SDF_mod #(.S(8), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf8 (.data_in(data_buffer78), .val_in(val78), .clk(clk), .rst(rst), .data_out(data_buffer89), .val_out(val89));
    SDF_mod #(.S(9), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf9 (.data_in(data_buffer89), .val_in(val89), .clk(clk), .rst(rst), .data_out(data_out), .val_out(val_out));
    
endmodule
