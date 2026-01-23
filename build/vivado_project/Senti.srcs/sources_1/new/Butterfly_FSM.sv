`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Butterfly_FSM#(parameter int MTI, STRIDE) //MTI stands for MAX_TWIDDLE_INDEX
    (
    input logic val_in, clk, rst,
    output logic [DATA_W-1:0] twiddle,
    output logic bf_on, val_internal, val_out
    );
	
    typedef enum logic [1:0] {IDLE, SHIFT, FLOW} state_t;
    state_t current_state = IDLE, next_state;
    
    int n = 0;  //number of cycles in SHIFT state until it must set val_out to high and validate next stage SDF module.
    
    logic n_max;    //logic value set to high when n reaches its max value.
    assign n_max = (n+1 == MTI ? 1 : 0);
    
    logic [2:0] inp_vals, out_vals;
    assign inp_vals = {val_in, n_max, rst}; //simplified input_vals
    localparam VI = 2, NM = 1, RS = 0;
    
    assign {bf_on, val_internal, val_out} = out_vals; //simplified output_vals
    localparam BF = 2, VINT = 1, VO = 0;
   
    logic [35:0] twiddle_rom [0:255];
    initial $readmemh("twiddle_unified.mem", twiddle_rom);
    
    logic [DATA_W-1:0] twiddle_curr;
    assign twiddle_curr = twiddle_rom[n*STRIDE];

    always_ff @(posedge clk or posedge rst) //go to next state block
    begin
        if (rst)
            begin
            current_state <= IDLE;
            n <= 0;
            end
        else
            begin
            current_state <= next_state;
            twiddle <= twiddle_curr;
            end
            
        if (current_state inside {SHIFT, FLOW} || (current_state == IDLE && inp_vals == 3'b100))
            begin
            n <= (n+1) % MTI;
            end
            
    end


    always_comb                             //choose next state block
    begin
        next_state = current_state;
        case (current_state)
            IDLE, SHIFT:
            begin
                priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
                    next_state = SHIFT;
                else if (inp_vals == 3'b110)                // val_in=1, n_max=1, rst=0
                    next_state = FLOW;
            end
            FLOW:
            begin
                priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
                    next_state = FLOW;
                else if (inp_vals == 3'b110)                // val_in=1, n_max=1, rst=0
                    next_state = SHIFT;
            end
        endcase
    end


    always_comb                             //choose outputs based on both current state and inputs
    begin
        out_vals = 3'b000;
        
        case (current_state)
            IDLE:
            begin
                out_vals = (inp_vals == 3'b100) ? 3'b010 : (inp_vals == 3'b110) ? 3'b111 : 3'b000;
            end
            SHIFT:
            begin
                out_vals = (!inp_vals[VI] || inp_vals[RS]) ? 3'b000 : (inp_vals == 3'b110) ? 3'b111 : 3'b010;
            end
            FLOW:
            begin
               out_vals = (!inp_vals[VI] || inp_vals[RS]) ? 3'b000 : (inp_vals == 3'b110) ? 3'b010 : 3'b111;
            end
        endcase
    end
endmodule