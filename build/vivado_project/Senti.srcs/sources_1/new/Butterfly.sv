`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Butterfly(
    input logic [DATA-1:0] data_in, delay_out,
    input logic [DATA_W-1:0] twiddle,
    input logic bf_on,
    output logic [DATA-1:0] data_out, delay_in
    );
    
    always_comb 
        begin
        automatic complex_data data_out_s, delay_in_s;
        automatic complex_data data_in_s = '{data_in[DATA-1:(DATA/2)], data_in[(DATA/2)-1: 0]};
        automatic complex_data delay_out_s = '{delay_out[DATA-1:(DATA/2)], delay_out[(DATA/2)-1: 0]};
        automatic complex_data twiddle_s = '{twiddle[DATA_W-1:(DATA_W/2)], twiddle[(DATA_W/2)-1: 0]};
        
        if(bf_on)
            begin
            data_out_s.r_val = delay_out_s.r_val + data_in_s.r_val;
            data_out_s.c_val = delay_out_s.c_val + data_in_s.c_val;
            
            delay_in_s.r_val = (delay_out_s.r_val - data_in_s.r_val) * twiddle_s.r_val;
            delay_in_s.c_val = (delay_out_s.c_val - data_in_s.c_val) * twiddle_s.c_val;
            end
        else
            begin
            data_out_s.r_val = data_in_s.r_val;
            data_out_s.c_val = data_in_s.c_val;
            
            delay_in_s.r_val = data_in_s.r_val;
            delay_in_s.c_val = data_in_s.c_val;
            end
            
        data_out = data_out_s;
        delay_in = delay_in_s;
        end    
endmodule

