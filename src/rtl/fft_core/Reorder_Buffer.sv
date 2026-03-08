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
    
    (* ram_style = "block" *)
    logic [DATA-1:0] buffer_mem [0:1][0:POINTS-1];
    
    logic [COUNTER_BITS-1:0] wr_count [0:1];
    logic [COUNTER_BITS-1:0] rd_count [0:1];
    buffer_status            status   [0:1];

    
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
        for (int i = 0; i < 2; ++i)
        begin
            status[i]   = (i == 0) ? FILLING : IDLE;
            wr_count[i] = '0;
            rd_count[i] = '0;
        end
        send_sel = 0; 
    end
    
    always @(posedge clk or posedge rst)
    begin        
        if (rst) 
        begin
            for (int i = 0; i < 2; ++i)
            begin
                status[i]   <= (i == 0) ? FILLING : IDLE;
                wr_count[i] <= '0;
                rd_count[i] <= '0;
            end
            send_sel  <= 0;
            val_out_rb <= 0;
        end
        else
        begin   
            val_out_rb <= 1'b0; // default: no output if nobody is sending 
                     
            for (int i = 0; i < 2; ++i)
            begin
                if (status[i] == FILLING)
                begin
                    if (wr_count[i] < POINTS && val_fft)
                    begin
                        if (wr_count[i] == POINTS-1)
                        begin
                            status[i]   <= SENDING; // if at the end of the loop, make the status of this buffer sending before filling one last time
                            rd_count[i] <= '0;
                            
                            if (status[1-i] == IDLE) 
                            begin
                                status[1-i]   <= FILLING;
                                wr_count[1-i] <= '0;
                                send_sel                   <= i; // I understand that we would want to let the SENDING block have complete ownership of the send_sel variable to make assignment to it come from one source, but this should work well without conflict
                            end
                        end
                        
                        buffer_mem[i][bit_reverse(wr_count[i])] <= fft_output;
                        wr_count[i] <= wr_count[i] + 1;
                    end
                end
                
                else if (i == send_sel && status[i] == SENDING) 
                begin
                    // drive current output sample
                    fft_fixed_output <= buffer_mem[i][rd_count[i]];
                    val_out_rb <= 1'b1;
                    
                    if (rd_count[i] == POINTS-1) 
                    begin
                        if ((wr_count[1-i] == POINTS-1) && (status[1-i] == FILLING))
                        begin
                            // Other buffer already has a full frame.
                            // Hand off sending to it next cycle.
                            send_sel               <= 1-i;
                    
                            if (val_fft) 
                            begin
                                // FFT still streaming: immediately reuse this buffer to FILL.
                                status[i]   <= FILLING;
                                wr_count[i] <= '0;
                            end 
                            
                            else 
                            begin
                                // FFT idle: we can safely park this buffer.
                                status[i]   <= IDLE;
                            end
                        end 
                        
                        else 
                        begin
                            // Other buffer is NOT ready to send yet.
                            // We must not toggle send_sel, or we'd send garbage.
                            if (val_fft) 
                            begin
                                // Nobody else is FILLING; reuse this buffer for the next frame.
                                status[i]   <= FILLING;
                                wr_count[i] <= '0;
                                // send_sel stays i.
                            end 
                            
                            else 
                            begin
                                // FFT idle and no other frame ready.
                                status[i]   <= IDLE;
                                // send_sel stays i; doesn't really matter until someone is SENDING.
                            end
                        end
                    end
                    rd_count[i] <= rd_count[i] + 1;
                end
            end
        end
    end
endmodule
