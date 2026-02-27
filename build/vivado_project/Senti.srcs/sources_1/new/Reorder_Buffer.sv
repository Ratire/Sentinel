`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Reorder_Buffer #(parameter int POINTS = 512)
    (
    input logic clk, rst, val_fft,
    input logic [DATA-1:0] fft_output,
    
    output logic [DATA-1:0] fft_fixed_output,
    output logic val_out_rb
    );
    
    localparam COUNTER_BITS = $clog2(POINTS);
    typedef enum logic [1:0] {FILLING, SENDING, IDLE} buffer_status;
    
    logic send_sel = 0;
    
    typedef struct {
        logic [DATA-1:0] buffer [0:POINTS-1];
        logic [COUNTER_BITS-1:0] wr_count;
        logic [COUNTER_BITS-1:0] rd_count;
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
        foreach (buffer_array[i]) 
        begin
            buffer_array[i].status   = (i == 0) ? FILLING : IDLE;
            buffer_array[i].wr_count = '0;
            buffer_array[i].rd_count = '0;
        end
        send_sel = 0; 
    end
    
    always_ff @(posedge clk or posedge rst)
    begin        
        if (rst) 
        begin
            foreach (buffer_array[i]) 
            begin
                buffer_array[i].status   <= (i == 0) ? FILLING : IDLE;
                buffer_array[i].wr_count <= '0;
                buffer_array[i].rd_count <= '0;
            end
            send_sel  <= 0;
            val_out_rb <= 0;
        end
        else
        begin   
            val_out_rb <= 1'b0; // default: no output if nobody is sending 
                     
            foreach (buffer_array[i])
            begin
                if (buffer_array[i].status == FILLING)
                begin
                    if (buffer_array[i].wr_count < POINTS && val_fft)
                    begin
                        if (buffer_array[i].wr_count == POINTS-1)
                        begin
                            buffer_array[i].status   <= SENDING; // if at the end of the loop, make the status of this buffer sending before filling one last time
                            buffer_array[i].rd_count <= '0;
                            
                            if (buffer_array[1-i].status == IDLE) 
                            begin
                                buffer_array[1-i].status   <= FILLING;
                                buffer_array[1-i].wr_count <= '0;
                                send_sel                   <= i; // I understand that we would want to let the SENDING block have complete ownership of the send_sel variable to make assignment to it come from one source, but this should work well without conflict
                            end
                        end
                        
                        buffer_array[i].buffer[bit_reverse(buffer_array[i].wr_count)] <= fft_output;
                        buffer_array[i].wr_count <= buffer_array[i].wr_count + 1;
                    end
                end
                
                else if (i == send_sel && buffer_array[i].status == SENDING) 
                begin
                    // drive current output sample
                    fft_fixed_output <= buffer_array[i].buffer[ buffer_array[i].rd_count ];
                    val_out_rb <= 1'b1;
                    
                    if (buffer_array[i].rd_count == POINTS-1) 
                    begin
                        if ((buffer_array[1-i].wr_count == POINTS-1) && (buffer_array[1-i].status == FILLING))
                        begin
                            // Other buffer already has a full frame.
                            // Hand off sending to it next cycle.
                            send_sel               <= 1-i;
                    
                            if (val_fft) 
                            begin
                                // FFT still streaming: immediately reuse this buffer to FILL.
                                buffer_array[i].status   <= FILLING;
                                buffer_array[i].wr_count <= '0;
                            end 
                            
                            else 
                            begin
                                // FFT idle: we can safely park this buffer.
                                buffer_array[i].status   <= IDLE;
                            end
                        end 
                        
                        else 
                        begin
                            // Other buffer is NOT ready to send yet.
                            // We must not toggle send_sel, or we'd send garbage.
                            if (val_fft) 
                            begin
                                // Nobody else is FILLING; reuse this buffer for the next frame.
                                buffer_array[i].status   <= FILLING;
                                buffer_array[i].wr_count <= '0;
                                // send_sel stays i.
                            end 
                            
                            else 
                            begin
                                // FFT idle and no other frame ready.
                                buffer_array[i].status   <= IDLE;
                                // send_sel stays i; doesn't really matter until someone is SENDING.
                            end
                        end
                    end
                    buffer_array[i].rd_count <= buffer_array[i].rd_count + 1;
                end
            end
        end
    end
endmodule


module tb_Reorder_Buffer;
    logic clk = 0, rst = 1, val_fft = 0, val_out_rb;
    logic [DATA-1:0] fft_fixed_output, fft_output = 0;
    
    localparam int TEST_POINTS = 16;
    localparam int TEST_COUNTER_BITS = $clog2(TEST_POINTS);
    
    Reorder_Buffer #(.POINTS(TEST_POINTS)) dut (.clk(clk), .val_fft(val_fft), .rst(rst), .fft_output(fft_output), .fft_fixed_output(fft_fixed_output), .val_out_rb(val_out_rb));
    
    always #5 clk = ~clk;
    
    task automatic wait_incr(input int j); //lets j-1 cycles pass and stops simulation at posedge of clk
        for(int i = 0; i < j; ++i)
        begin
            @(posedge clk);
            fft_output <= fft_output + 1;
            
        end
    endtask
        
    initial begin
        // reset
        rst      = 1;
        val_fft  = 0;
        fft_output = '0;
    
        @(posedge clk);
        rst <= 0;
    
        // one frame of TB_POINTS samples
        val_fft <= 1;
        wait_incr(TEST_POINTS);
        val_fft <= 0;   // stop FFT outputs
    
        // let reorder buffer drain
        repeat (TEST_POINTS + 10) @(posedge clk);
        
        val_fft <= 1;
        fft_output = '0;
        wait_incr(3*TEST_POINTS);
        
        repeat (TEST_POINTS + 10) @(posedge clk);
    
        $finish;
    end

    
    always_ff @(posedge clk) 
    begin
        if (val_out_rb)
            //$display("%0t: val_out_rb=1 out=%04b", $time, fft_fixed_output[TEST_COUNTER_BITS:0]);
            $display("%0t: val_out_rb=1 out=%054b", $time, fft_fixed_output);
    end
endmodule