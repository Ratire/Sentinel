`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Shift_Reg #(parameter int REG_SIZE)
    (
    input logic [DATA-1:0] delay_in,
    input logic clk, val_in,
    output logic [DATA-1:0] delay_out
    );
    
    logic [REG_SIZE-1:0][DATA-1:0] reg_array;
    
    always_ff @(posedge clk)
        begin
        if(val_in)
            begin
            delay_out <= reg_array[REG_SIZE-1];
            reg_array <= {reg_array[REG_SIZE-2:0], delay_in};
            end
        end
endmodule
