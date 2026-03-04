`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Butterfly_FSM#(parameter int MTI, STRIDE, POINTS) //MTI stands for MAX_TWIDDLE_INDEX
    (
    input logic val_in, clk, rst,
    output logic [DATA_W-1:0] twiddle,
    output logic [$clog2(POINTS)-1:0] counter,
    output logic bf_on, val_out
    );
    
    state_t current_state = IDLE, next_state;
    
    logic [$clog2(MTI):0] n = '0;  //number of cycles in SHIFT state until it must set val_out to high and validate next stage SDF module.
    
    logic n_max;    //logic value set to high when n reaches its max value.
    assign n_max = (n+1 == MTI ? 1 : 0);
    
    logic [$clog2(POINTS)-1:0] counter_temp = 0; //used to check if the frame is done
    logic frame_done = 1;
    
    logic [2:0] inp_vals; 
    logic [1:0] out_vals;
    
    assign inp_vals = {val_in, n_max, rst}; //simplified input_vals
    localparam VI = 2, NM = 1, RS = 0;
    
    //out_vals = {bf_on, val_out}
    localparam BF = 2, VINT = 1, VO = 0;
    
    logic [35:0] twiddle_rom [0:255];
    initial $readmemh("twiddle_unified.mem", twiddle_rom);
    
    assign twiddle = twiddle_rom[n*STRIDE];

    always_ff @(posedge clk) //go to next state block
    begin
        if (rst)
            begin
            current_state <= IDLE;
            n <= 0;
            {bf_on, val_out} <= 3'b00;
            counter_temp <= 0;
            end
        else
            begin
            current_state <= next_state;
            {bf_on, val_out} <= out_vals;
            end
            
        if (current_state inside {SHIFT, FLOW,  SHIFT_AGAIN} || (current_state == IDLE && inp_vals == 3'b100))
            n <= (n+1) % MTI;
            
        if(current_state inside {FLOW, SHIFT_AGAIN})
        begin
            counter_temp <= (counter_temp+1) % POINTS;
            counter <= (counter_temp+1) % POINTS;
            
            frame_done <= (counter_temp == (POINTS-2) ? 1 : 0);
        end
    end


    always_comb                             //choose next state block
    begin
        next_state = current_state;
        case (current_state)
            IDLE:
            begin
                if (!inp_vals[VI] || inp_vals[RS])                      // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals[VI] && MTI == 1)                      // if last SDF stage and input val_in is high
                    next_state = FLOW;
                else if (inp_vals[VI])                                  // val_in=1
                    next_state = SHIFT;
            end
            
            SHIFT:
            begin
                if (inp_vals[RS] || (frame_done && !inp_vals[VI]))      // rst || frame finishes when val_in is low
                    next_state = IDLE;
                else if (inp_vals[NM] || (inp_vals[VI] && MTI == 1))    // n_max=1 || if last SDF stage and input val_in is high (the second case would never happen, to be honest, but its here)
                    next_state = FLOW;
                else                                                    // default case
                    next_state = SHIFT;
            end
            
            FLOW:
            begin
                if (inp_vals[RS] || (frame_done && !inp_vals[VI]))      // rst || frame finishes when val_in is low
                    next_state = IDLE;
                else if (inp_vals[NM] || (inp_vals[VI] && MTI == 1))    // n_max=1 || if last SDF stage and input val_in is high (it has to literally toggle between FLOW and SHIFT_AGAIN no matter what)
                    next_state = SHIFT_AGAIN;
                else                                                    // default case
                    next_state = FLOW;
            end
            
            SHIFT_AGAIN:
            begin
                if (inp_vals[RS] || (frame_done && !inp_vals[VI]))      // rst || frame finishes when val_in is low
                    next_state = IDLE;
                else if (inp_vals[NM] || (inp_vals[VI] && MTI == 1))    // n_max=1 || if last SDF stage and input val_in is high
                    next_state = FLOW;
                else                                                    // default case
                    next_state = SHIFT_AGAIN;
            end
        endcase
    end


    always_comb                             //choose outputs based on both current state and inputs
    begin
        out_vals = 2'b00;
        
        case (current_state)
            IDLE:
            begin
                out_vals = ((inp_vals[VI] && MTI == 1) ? 2'b11 : 2'b00);
            end
            
            SHIFT:
            begin
                out_vals = (inp_vals[RS] || (frame_done && !inp_vals[VI])) ? 2'b00 : (inp_vals[NM] || (inp_vals[VI] && MTI == 1)) ? 2'b11 : 2'b00;
            end
            
            FLOW:
            begin
               out_vals = (inp_vals[RS] || (frame_done && !inp_vals[VI])) ? 2'b00 : (inp_vals[NM] || (inp_vals[VI] && MTI == 1)) ? 2'b01 : 2'b11;
            end
            
            SHIFT_AGAIN:
            begin
                out_vals = (inp_vals[RS] || (frame_done && !inp_vals[VI])) ? 2'b00 : (inp_vals[NM] || (inp_vals[VI] && MTI == 1)) ? 2'b11 : 2'b01;
            end
        endcase
    end
endmodule

