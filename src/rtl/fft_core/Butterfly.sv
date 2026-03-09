`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Butterfly
    #(parameter bit SHIFT_SUM_EN  = 1,
      parameter bit SHIFT_DIFF_EN = 1)
    (
    input logic [DATA-1:0] data_in, delay_out,
    input logic [DATA_W-1:0] twiddle,
    input logic bf_on,
    output logic [DATA-1:0] data_out, delay_in
    );
    
    function automatic logic signed [DATA/2:0] round_shift1 (input logic signed [DATA/2:0] x);
        logic signed [DATA/2:0] tmp;
        tmp = (x >= 0) ? (x + 1) : (x - 1);
        return tmp >>> 1;
    endfunction 
    
    always_comb 
    begin
        automatic complex_data data_out_s, delay_in_s;
        automatic complex_data data_in_s = '{data_in[DATA-1:(DATA/2)], data_in[(DATA/2)-1: 0]};
        automatic complex_data delay_out_s = '{delay_out[DATA-1:(DATA/2)], delay_out[(DATA/2)-1: 0]};
        automatic complex_data twiddle_s = '{twiddle[DATA_W-1:(DATA_W/2)], twiddle[(DATA_W/2)-1: 0]};
        
        automatic logic signed [DATA/2:0] diff_r, diff_i;
        automatic logic signed [(DATA/2 + DATA_W/2):0] twiddle_prod1, twiddle_prod2;
        automatic logic signed [(DATA/2 + DATA_W/2) + 1:0] delay_in_r, delay_in_c;
        
        automatic logic signed [DATA/2:0] sum_r_ext, sum_i_ext;
        
        if(bf_on)
        begin
            
            sum_r_ext = {delay_out_s.r_val[DATA/2-1], delay_out_s.r_val} + {data_in_s.r_val[DATA/2-1],  data_in_s.r_val};
            sum_i_ext = {delay_out_s.c_val[DATA/2-1], delay_out_s.c_val} + {data_in_s.c_val[DATA/2-1],  data_in_s.c_val};
            
            if (SHIFT_SUM_EN) //scaled by 1/2  before saturation
            begin
                sum_r_ext = round_shift1(sum_r_ext);
                sum_i_ext = round_shift1(sum_i_ext);
            end
            
            data_out_s.r_val = saturate_add_27(sum_r_ext);
            data_out_s.c_val = saturate_add_27(sum_i_ext);

            diff_r = delay_out_s.r_val - data_in_s.r_val;
            diff_i = delay_out_s.c_val - data_in_s.c_val;
            
            if (SHIFT_DIFF_EN) //scaled by 1/2 
            begin
                diff_r = round_shift1(diff_r);
                diff_i = round_shift1(diff_i);
            end

            twiddle_prod1 = diff_r * twiddle_s.r_val; 
            twiddle_prod2 = diff_i * twiddle_s.c_val;
            delay_in_r = twiddle_prod1 - twiddle_prod2;
            
            twiddle_prod1 = diff_r * twiddle_s.c_val; 
            twiddle_prod2 = diff_i * twiddle_s.r_val;
            delay_in_c = twiddle_prod1 + twiddle_prod2;
            
            delay_in_s.r_val = saturate_mul(delay_in_r);
            delay_in_s.c_val = saturate_mul(delay_in_c);
        end
        
        else
        begin
            data_out_s.r_val = delay_out_s.r_val;
            data_out_s.c_val = delay_out_s.c_val;
            
            delay_in_s.r_val = data_in_s.r_val;
            delay_in_s.c_val = data_in_s.c_val;
        end
            
        data_out = {data_out_s.r_val, data_out_s.c_val};
        delay_in = {delay_in_s.r_val, delay_in_s.c_val};
    end    
endmodule
