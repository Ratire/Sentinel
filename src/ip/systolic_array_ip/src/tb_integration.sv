`timescale 1ns/1ps
import systolic_array_pkg::*;
import FFT_pkg::*;

module tb_integration;
    logic clk = 0, rst;
    always #5 clk = ~clk;
    
    // Feature Extractor inputs
    logic fft_valout;
    logic [DATA-1:0] fft_data_out;
    logic arm_start;
    logic frame_done;
    
    // Feature Extractor outputs
    logic [PE_INP_WIDTH-1:0] sa_activation_data;  // Single 18-bit value from FE
    logic sa_activation_valid;
    
    // Broadcast to Systolic Array (16 rows)
    logic [15:0][PE_INP_WIDTH-1:0] sa_broadcast_data;  // 2D array for SA
    logic [15:0] sa_broadcast_enable;
    
    // Weight loading
    logic [PE_INP_WIDTH-1:0] weight_load_data;
    logic [3:0] weight_load_row;
    logic [3:0] weight_load_col;
    logic weight_load_en;
    logic load_mode;
    
    // Result read interface
    logic [7:0] result_addr;
    logic [PE_ACCUM_WIDTH-1:0] result_o;
    logic done_o;
    
    // Broadcast logic - replicate single value to all 16 rows
    assign sa_broadcast_data = {16{sa_activation_data}};
    assign sa_broadcast_enable = {16{sa_activation_valid}};
    
    // Instantiate Feature Extractor
    feature_extractor fe (.*);
    
    // Instantiate Systolic Array
    systolic_array_16x16 sa (
        .clk(clk),
        .rst(rst),
        .left_activation_i(sa_broadcast_data),      // 2D broadcast
        .left_enable_i(sa_broadcast_enable),        // All rows enabled together
        .weight_load_data(weight_load_data),
        .weight_load_row(weight_load_row),
        .weight_load_col(weight_load_col),
        .weight_load_en(weight_load_en),
        .load_mode(load_mode),
        .result_addr_i(result_addr),
        .result_o(result_o),
        .done_o(done_o)
    );
    
    // Weight loading task
    task load_all_weights();
        begin
            $display("Loading weights...");
            load_mode = 1;
            
            for (int row = 0; row < 16; row++) 
            begin
                for (int col = 0; col < 16; col++) 
                begin
                    for (int w = 0; w < 512; w++) 
                    begin
                        @(posedge clk);
                        weight_load_row = row[3:0];
                        weight_load_col = col[3:0];
                        weight_load_data = 18'd1;
                        weight_load_en = 1;
                    end
                    // Extra cycle to ensure write to weight_mem[511] completes
                    // before changing row/col addresses
                    @(posedge clk);
                    weight_load_en = 0;
                end
                $display("  Row %0d done", row);
            end
            
            // Final settle cycles before compute phase
            @(posedge clk);
            weight_load_en = 0;
            @(posedge clk);  // Ensure last PE's final write settles
            load_mode = 0;
            $display("Weights loaded!");
        end
    endtask
    
    // Read results task
    task read_results();
        begin
            $display("Reading results immediately:");
            
            // Read 256 PEs back-to-back with no wasted cycles
            for (int addr = 0; addr < 256; addr++) begin
                result_addr = addr[7:0];
                @(posedge clk);  // One cycle for read latency
                $display("  PE[%0d] result = %0d (valid=%b)", addr, result_o, done_o);
            end
        end
    endtask
    
    initial begin
        $dumpfile("integration.vcd");
        $dumpvars(0, tb_integration);
        
        rst = 1; fft_valout = 0; arm_start = 0;
        weight_load_en = 0; load_mode = 0;
        
        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);
        
        load_all_weights();
        
        $display("Starting feature extraction...");
        arm_start = 1;
        @(posedge clk);
        arm_start = 0;
        
        fft_valout = 1;
        for (int i = 0; i < 512; i++) begin
            fft_data_out = {27'(i << 9), 27'd0};
            @(posedge clk);
        end
        fft_valout = 0;
        
        wait(fe.current_state == fe.DONE);
        $display("Feature extraction done!");
        
        wait(done_o);
        $display("Systolic array done!");
        
        read_results();
        
        $display("Integration test complete!");
        $finish;
    end
endmodule