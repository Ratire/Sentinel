`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Shift_Reg #(parameter int REG_SIZE, POINTS)
    (
    input logic [DATA-1:0] delay_in,
    input logic clk, rst, val_in,
    input logic [$clog2(POINTS)-1:0] counter,
    output logic [DATA-1:0] delay_out
    );
    
    logic frame_done = 1;
    
    logic [REG_SIZE-1:0][DATA-1:0] reg_array = '{default: '0};
    assign delay_out = reg_array[REG_SIZE-1];
    
    always_ff @(posedge clk)
    begin
        if (rst) 
        begin
            reg_array <= '{default: '0};
            frame_done <= 1;
        end
        
        else if (val_in || !frame_done) 
        begin
            frame_done <= (counter == (POINTS-2) ? 1 : 0);
            
            reg_array[0] <= delay_in;
            if (REG_SIZE > 1)
            begin
                for (int k = 1; k < REG_SIZE; k++) 
                begin
                    reg_array[k] <= reg_array[k-1];
                end
            end
        end
    end
endmodule
