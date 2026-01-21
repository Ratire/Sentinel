`timescale 1ns / 1ps

module SDF_mod #(parameter int S = 1, POINTS = 512) //S represents the stage this SDF module is at in the FFT
    (
    input [26:0] data_in,
    input val_in, clk, rst,
    output [26:0] data_out,
    output val_out
    );
    
    localparam DELAY_BUFFER_SIZE = 2**($clog2(POINTS) - S);
    Butterfly_FSM #(.N(DELAY_BUFFER_SIZE)) bf_fsm (.val_in(val_in), .clk(clk), .rst(rst), 
    
    
endmodule
