`timescale 1ns / 1ps
import systolic_array_pkg::*; 


module pe_cell #
(
    parameter row = 0,
    parameter column = 0,
    parameter K = 512
)

(
    input logic clk, rst,
    
    input logic [PE_INP_WIDTH-1:0]  weight_i, activation_i, // input weights and activation variables
    output logic [PE_INP_WIDTH-1:0] weight_o, activation_o, // output weights and activation variables
    
    input logic  enable_i,                      // enable input signal to start computation
    output logic enable_o,                      // enable output signal to enable next neighboring tiles
    
    output logic [PE_ACCUM_WIDTH-1:0] accum_o,                // accumulated variable from weight and activation variable multiplication
    output logic                      valid_o                 // valid signal to indicate when accumulation is finished (active-high)
);
    logic                               valid_reg = 0;
    logic                               enable_reg = 0;
    logic signed [PE_INP_WIDTH-1:0]     weight_reg = 0;
    logic signed [PE_INP_WIDTH-1:0]     activation_reg = 0;
    logic signed [PE_ACCUM_WIDTH-1:0]   accum_reg = 0;
    
    logic [$clog2(K)-1:0] cntr = 0;
    
    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            enable_reg <=       0;
            weight_reg <=       0;
            activation_reg <=   0;
            accum_reg <=        0;
            cntr <=             0;
            valid_reg <=        0;
        end
        
        else if (enable_i || enable_reg)
        begin
            if (enable_i) enable_reg <= 1;
            
            weight_reg <=       weight_i;
            activation_reg <=   activation_i;
            accum_reg <=        accum_reg + activation_i * weight_i;
            
            if (cntr >= K-1)
            begin
                valid_reg <=    1;
                enable_reg <=   0;
                cntr <=         0;
            end
            
            else
            begin
                cntr <= cntr + 1;
            end
        end
    end
    
    assign valid_o =        valid_reg;
    assign enable_o =       enable_reg;
    assign weight_o =       weight_reg;
    assign activation_o =   activation_reg;
    assign accum_o =        accum_reg;

endmodule