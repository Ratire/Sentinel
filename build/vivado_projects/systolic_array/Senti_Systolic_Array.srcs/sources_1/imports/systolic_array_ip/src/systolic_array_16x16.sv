`timescale 1ns / 1ps
import systolic_array_pkg::*; 

module systolic_array_16x16 #(
    parameter K = 512,
    parameter PE_INP_WIDTH = 18,
    parameter PE_ACCUM_WIDTH = 45
)(
    input logic clk,
    input logic rst,
    
    // Left edge inputs (16 rows)
    input logic signed [15:0] [PE_INP_WIDTH-1:0] left_activation_i,
    input logic [15:0] left_enable_i,                                               // Enabling each part should happen in staggered order
    
    // Weight loading interface (linear serial loading to save routing resources - one PE at a time)
    input logic signed [PE_INP_WIDTH-1:0] weight_load_data,                         // Single 18-bit weight value broadcast to all
    input logic [3:0] weight_load_row,                                              // Target row address (0-15)
    input logic [3:0] weight_load_col,                                              // Target col address (0-15)
    input logic weight_load_en,                                                     // Global strobe (decoded per PE inside)
    input logic load_mode,                                                          // Global 1=load, 0=compute
    
    // Result read interface
    input logic [7:0] result_addr_i,                                                // 0-255
    output logic signed [PE_ACCUM_WIDTH-1:0] result_o,
    output logic done_o                                                             // Literally just equal to PE[15][15].valid_o, since when its done so is everything else
);
    localparam SIDE_LENGTH = 16;

    // Mesh wires
    logic signed [PE_INP_WIDTH-1:0] act_mesh [SIDE_LENGTH-1:0] [SIDE_LENGTH:0];     // 16 rows going from left-to-right and N+1 input/output signals for N pe_tiles
    logic [SIDE_LENGTH-1:0] [SIDE_LENGTH:0] enable_mesh;                            // Same but enable signal instead
    
    // Result storage (256 registers)
    logic signed [PE_ACCUM_WIDTH-1:0] results [0:15][0:15];                         // 1 result per pe_tile
    
    // Valid signals from all PEs (for capture logic)
    logic [15:0] [15:0] pe_valid;
    logic signed [PE_ACCUM_WIDTH-1:0] pe_accum [0:15] [0:15];
    
    
    // Left edge is going to drive the leftmost signals of each tile in the leftmost column of tiles
    genvar i;
    generate
        for (i = 0; i < SIDE_LENGTH; i++)
        begin : initial_assign_left
            // LEFT
            assign act_mesh[i][0] =     left_activation_i[i];
            assign enable_mesh[i][0] =  left_enable_i[i];
        end
    endgenerate
    
    // Instantiation of each pe_cell within our systolic array (all 256 AKA 16x16)
    genvar row, col;
    generate
        for (row = 0; row < SIDE_LENGTH; row++) 
        begin : gen_row
            for (col = 0; col < SIDE_LENGTH; col++) 
            begin : gen_col

                pe_cell #(
                .row(row),
                .column(col),
                .K(K)
                ) pe_inst (
                .clk(clk),
                .rst(rst),
                .activation_i(act_mesh[row][col]),
                .activation_o(act_mesh[row][col+1]),
                .weight_load_data(weight_load_data),
                .weight_load_en(weight_load_en && (row == weight_load_row) && (col == weight_load_col)),
                .load_mode(load_mode),
                .enable_i(enable_mesh[row][col]),
                .enable_o(enable_mesh[row][col+1]),
                .accum_o(pe_accum[row][col]),
                .valid_o(pe_valid[row][col])
                );
                
            end
        end
        
    endgenerate
    
    genvar r, c;
    generate
        for (r = 0; r < SIDE_LENGTH; r++) 
        begin : gen_r
            for (c = 0; c < SIDE_LENGTH; c++) 
            begin : gen_c
                
                always_ff @(posedge clk)
                begin
                    if (pe_valid[r][c])
                        results[r][c] <= pe_accum[r][c];
                end
                
            end
        end
        
    endgenerate
    
    // Result mux logic (flatten 2D array to 1D for addressing)
    logic signed [PE_ACCUM_WIDTH-1:0] results_flat [0:255];
    
    generate
        for (r = 0; r < 16; r++) 
        begin : flatten_r
            for (c = 0; c < 16; c++) 
            begin : flatten_c
                always_comb results_flat[r*16 + c] = results[r][c];
            end
        end
    endgenerate
    
    assign result_o = results_flat[result_addr_i];
    assign done_o = pe_valid[SIDE_LENGTH-1][SIDE_LENGTH-1]; // Bottom rightmost tile's valid output signal (once it's done, so should everything else be)

endmodule