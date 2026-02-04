`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module SDF_mod #(parameter int S = 1, POINTS = 512) //S represents the stage this SDF module is at in the FFT
    (
    input logic [DATA-1:0] data_in,
    input logic val_in, clk, rst,
    output logic [DATA-1:0] data_out,
    output logic val_out
    );
    
    localparam DELAY_BUFFER_SIZE = 2**($clog2(POINTS) - S);
    localparam STRIDE = 2**(S-1);
    
    //Connecting signals between modules
    logic bf_on;
    logic [DATA_W-1:0] twiddle;
    logic [DATA-1:0] data_out_int, delay_in_int, delay_out;
    
    Butterfly_FSM #(.MTI(DELAY_BUFFER_SIZE), .STRIDE(STRIDE)) bf_fsm (.val_in(val_in), .clk(clk), .rst(rst), .twiddle(twiddle), .bf_on(bf_on), .val_out(val_out));
    Shift_Reg #(.REG_SIZE(DELAY_BUFFER_SIZE)) shift_reg (.delay_in(delay_in_int), .clk(clk), .val_internal(val_in), .rst(rst), .delay_out(delay_out));
    Butterfly bf (.data_in(data_in), .delay_out(delay_out), .twiddle(twiddle), .bf_on(bf_on), .data_out(data_out), .delay_in(delay_in_int));
    
endmodule
