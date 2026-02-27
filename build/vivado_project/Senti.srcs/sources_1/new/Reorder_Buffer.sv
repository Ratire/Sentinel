`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Reorder_Buffer #(parameter int POINTS = 512)
    (
    input logic [DATA-1:0] fft_output,
    input logic clk, rst, val_in,
    output logic [DATA-1:0] fft_fixed_output
    );
    
    localparam COUNTER_BITS = $clog2(POINTS);
    typedef enum logic {FILLING, SENDING, IDLE} buffer_status;
    
    typedef struct {
        logic [DATA-1:0] buffer [0:POINTS-1];
        logic [COUNTER_BITS-1:0] counter;
        buffer_status status;
    } pp_buffer;
    
    pp_buffer buffer_array [0:1];
    
    function automatic logic [COUNTER_BITS-1:0] bit_reverse(input logic [COUNTER_BITS-1:0] counter);
        logic [COUNTER_BITS-1:0] bit_reversed_counter = '0;
        for(int i = 0; i < COUNTER_BITS; ++i)
        begin
            bit_reversed_counter[(COUNTER_BITS-1)-i] = counter[i];
        end
        return bit_reversed_counter;
    endfunction
    
    initial
    begin
        buffer_array[0].buffer = '{default: '0}; buffer_array[1].buffer = '{default: '0};
        buffer_array[0].counter = '0; buffer_array[1].counter = '0;
        buffer_array[0].status = IDLE; buffer_array[1].status = IDLE;
    end
    
    always_ff @(posedge clk or posedge rst)
    begin
        if (rst) 
        begin
            buffer_array[0].buffer = '{default: '0}; buffer_array[1].buffer = '{default: '0};
            buffer_array[0].counter = '0; buffer_array[1].counter = '0;
            buffer_array[0].status = IDLE; buffer_array[1].status = IDLE;
        end
        else if (val_in) 
        begin
            if (buffer_array[0].status == IDLE && buffer_array[1].status == IDLE)
            begin
                buffer1.status = FILLING;
                buffer2.status = FILLING;
            end
            
            foreach (buffer_array[i])
            begin
                if (buffer_array[i].status == FILLING)
                begin
                    if (buffer_array[i].counter < POINTS)
                    begin
                        buffer_array[i].buffer[bit_reverse(buffer_array[i].counter)] <= fft_output;
                        ++buffer_array[i].counter;
                        
                    end
                    else
                    begin
                        buffer_array[i].counter = 1;
                        buffer_array[i].status = SENDING;
                        fft_fixed_output <= buffer_array[i].buffer[0];
                    end
                end
                
                else if (buffer_array[i].status == SENDING)
                begin
                    if (buffer_array[i].counter < POINTS)
                    begin
                        fft_fixed_output <= buffer_array[i].buffer[buffer_array[i].counter];
                        ++buffer_array[i].counter;
                        
                    end
                    
                    else
                    begin
                        buffer_array[i].counter = 1;
                        buffer_array[i].status = FILLING;
                        buffer_array[i].buffer[bit_reverse(0)] <= fft_output; //I know that bit reverse of 0 is just 0 again, I am just writing it with the function for completion.
                    end
                end
            end
        end
    end
endmodule


module tb_Shift_Reg;
    logic clk = 0, rst = 1, val_in = 0;
    logic [DATA-1:0] delay_in_var = '0, delay_out_var;
    
    localparam int REG_SIZE_TB = 1;
    
    Shift_Reg #(.REG_SIZE(REG_SIZE_TB)) dut (.clk(clk), .val_in(val_in), .rst(rst), .delay_in(delay_in_var), .delay_out(delay_out_var));
    
    always #5 clk = ~clk;
    always @(posedge clk)
    begin
    #5;
    delay_in_var = delay_in_var + 1;
    end
        
    initial
    begin
        @(negedge clk);
        rst = 1;
        
        @(negedge clk);
        rst = 0;
        val_in = 1;
        
        for(int i = 0; i < REG_SIZE_TB + 2; ++i)
        begin
            @(negedge clk);
        end
        
        @(negedge clk);
        rst = 1;
        
       #20;
        $finish;
    end
endmodule