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
    
    // Data flow between pe_cells
    input logic signed [PE_INP_WIDTH-1:0]  activation_i,        // input activation variable
    output logic signed [PE_INP_WIDTH-1:0] activation_o,        // output activation variable
    
    // Weight loading variables
    input logic signed [PE_INP_WIDTH-1:0]  weight_load_data,
    input logic                            weight_load_en,
    input logic                            load_mode,
    
    // Control variables
    input logic  enable_i,                                      // enable input signal to start computation
    output logic enable_o,                                      // enable output signal to enable next neighboring tiles
    
    // Outputting results
    output logic signed [PE_ACCUM_WIDTH-1:0] accum_o,           // accumulated variable from weight and activation variable multiplication
    output logic                             valid_o            // valid signal to indicate when accumulation is finished (active-high)
);
    // General variables for clocking new values (while outputs receive these combinationally)
    logic                               valid_reg;
    logic                               enable_reg;
    logic signed [PE_INP_WIDTH-1:0]     activation_reg;
    logic signed [PE_ACCUM_WIDTH-1:0]   accum_reg;
    
    // BRAM for holding weights locally (this will be updated/loaded by the arm core at the start of the FPGA's work)
    (* ram_style = "block" *)
    logic signed [PE_INP_WIDTH-1:0] weight_mem [0:K-1];
    logic [$clog2(K)-1:0]           weight_addr;                // serves as a counter for loading new weights
    
    logic [$clog2(K)-1:0]           compute_addr;               // global counter for checking what stage we are at with the systolic array for this specific pe_tile
    
    initial
    begin
        valid_reg = 0;
        enable_reg = 0;
        activation_reg = 0;
        accum_reg = 0;
    end
    
    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            enable_reg <=       0;
            activation_reg <=   0;
            accum_reg <=        0;
            compute_addr <=     0;
            weight_addr <=      0;
            valid_reg <=        0;
        end
        
        else if (load_mode)
        begin
            // LOAD PHASE: where the weights of this specific pe_tile are being loaded into the tile's BRAM
            if(weight_load_en)
            begin
                weight_mem[weight_addr] <=  weight_load_data;
                weight_addr <= (weight_addr >= K-1) ? 0 : weight_addr + 1; //wraparound
            end
            
            enable_reg <= 0; //make sure enable_reg isn't on when loading (otherwise, obviously problems)
        end
        
        else
        begin
            // COMPUTE PHASE: where the actual function of the pe_tile is completed
            if (enable_i || enable_reg)
            begin
                if (enable_i) enable_reg <= 1;
                
                activation_reg <=   activation_i;
                accum_reg <=        accum_reg + (activation_i * weight_mem[compute_addr]);
                
                if (compute_addr >= K-1)
                begin
                    valid_reg <=    1;
                    enable_reg <=   0;
                    compute_addr <=  0;
                end
                
                else
                begin
                    compute_addr <= compute_addr + 1;
                end
            end
        end
    end
    
    assign valid_o =        valid_reg;
    assign enable_o =       enable_reg;
    assign activation_o =   activation_reg;
    assign accum_o =        accum_reg;

endmodule