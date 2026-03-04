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
            /*
            data_out_s.r_val = data_in_s.r_val;
            data_out_s.c_val = data_in_s.c_val;
            
            delay_in_s.r_val = data_in_s.r_val;
            delay_in_s.c_val = data_in_s.c_val;
            */
            
            data_out_s.r_val = delay_out_s.r_val;
            data_out_s.c_val = delay_out_s.c_val;
            
            delay_in_s.r_val = data_in_s.r_val;
            delay_in_s.c_val = data_in_s.c_val;
            end
            
        data_out = {data_out_s.r_val, data_out_s.c_val};
        delay_in = {delay_in_s.r_val, delay_in_s.c_val};

        end    
endmodule

module tb_Butterfly;
    localparam int N_C = 12; //number of cases
    localparam int N_OC = N_C*2; //number of output cases (since we are checking the output for bf_on and !bf_on
    
    int i = 0; //index to be used later
    
    logic [DATA/2-1:0] data_in_arr [0:N_C-1][0:1], delay_out_arr [0:N_C-1][0:1]; //inputs
    logic [DATA_W/2-1:0] twiddle_arr [0:N_C-1][0:1];
    
    logic [DATA/2-1:0] data_out_arr [0:N_OC-1][0:1], delay_in_arr [0:N_OC-1][0:1]; //outputs
    
    logic [DATA-1:0] data_in, delay_out;
    logic [DATA-1:0] data_out, delay_in, data_out_off, delay_in_off, data_out_on, delay_in_on; //the off and on versions are for testing from golden python model
    logic [DATA_W-1:0] twiddle; 
    logic bf_on = 0;
    
    assign data_in = {data_in_arr[i][0], data_in_arr[i][1]};
    assign delay_out = {delay_out_arr[i][0], delay_out_arr[i][1]};
    assign twiddle = {twiddle_arr[i][0], twiddle_arr[i][1]};
    assign data_out_off = {data_out_arr[i*2][0], data_out_arr[i*2][1]};
    assign delay_in_off = {delay_in_arr[i*2][0], delay_in_arr[i*2][1]};
    assign data_out_on = {data_out_arr[i*2+1][0], data_out_arr[i*2+1][1]};
    assign delay_in_on = {delay_in_arr[i*2+1][0], delay_in_arr[i*2+1][1]};
    
    Butterfly dut (.data_in(data_in), .delay_out(delay_out), .twiddle(twiddle), .bf_on(bf_on), .data_out(data_out), .delay_in(delay_in));
    
    task automatic test_bf_on_pair(input int j);
        i = j;
        #1;  // Let continuous assigns settle
        
        bf_on = 0;
        #10;
        assert #0 ((data_out == data_out_off) && (delay_in == delay_in_off))
            else $error("bf_on=0 @ t=%0t: Expected data_out=0x%0h delay_in=0x%0h, Got data_out=0x%0h delay_in=0x%0h", 
                        $time, data_out_off, delay_in_off, data_out, delay_in);
        
        bf_on = 1;
        #10;
        assert #0 ((data_out == data_out_on) && (delay_in == delay_in_on))
            else $error("bf_on=1 @ t=%0t: Expected data_out=0x%0h delay_in=0x%0h, Got data_out=0x%0h delay_in=0x%0h", 
                        $time, data_out_on, delay_in_on, data_out, delay_in);
    endtask 

    
    initial
    begin
        $readmemh("twiddles.txt", twiddle_arr); $readmemh("data_in.txt", data_in_arr); $readmemh("delay_out.txt", delay_out_arr);
        $readmemh("data_out.txt", data_out_arr); $readmemh("delay_in.txt", delay_in_arr);
        
        for(int k = 0; k < N_C; ++k)
        begin
            test_bf_on_pair(k);
        end
        $finish;
    end
endmodule

