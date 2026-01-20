`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Butterfly_FSM#(parameter int N = 1)
    (
    input logic val_in, clk, rst,
    output logic [35:0] twiddle,
    output logic bf_on, val_out, val_internal
    );
	
    typedef enum logic [1:0] {IDLE, SHIFT, FLOW} state_t;
    state_t current_state, next_state;
    
    int n = 0;  //number of cycles in SHIFT state until it must set val_out to high and validate next stage SDF module.
    
    logic n_max;    //logic value set to high when n reaches its max value.
    assign n_max = (n >= N ? 1 : 0);
    
    logic [2:0] inp_vals, out_vals;
    assign inp_vals = {val_in, n_max, rst};
    localparam VI = 2, NM = 1, RS = 0;
    
    assign {bf_on, val_internal, val_out} = out_vals;
    localparam BF = 2, VINT = 1, VO = 0;
    

    always_ff @(posedge clk or posedge rst) 
    begin
        if (rst)
            begin
            current_state <= IDLE;
            n <= 0;
            end
        else
            current_state <= next_state;
            
        if (current_state inside {SHIFT, FLOW})
            n <= (n >= N ? N : n+1);
    end


    always_comb begin
      next_state = current_state;
    
      priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
        next_state = IDLE;
      else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
        next_state = SHIFT;
      else if (inp_vals == 3'b110)                // val_in=1, n_max=1, rst=0
        next_state = FLOW;
    end


    always_comb begin
        out_vals = 3'b000;
        case (current_state)
            IDLE: out_vals = 3'b000;
            SHIFT: out_vals = 3'b110;
            FLOW: out_vals = 3'b111;
        endcase
    end
endmodule