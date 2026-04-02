`timescale 1ns/1ps
module feature_extractor_tb;
    logic clk=0, rst, fft_valout, arm_start;
    logic [53:0] fft_data_out;
    logic [17:0] sa_activation_data;
    logic sa_activation_valid, frame_done;
    
    feature_extractor dut (.*);
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("fe_full.vcd");
        $dumpvars(0, feature_extractor_tb);
        
        // Init
        rst = 1; fft_valout = 0; arm_start = 0; fft_data_out = 0;
        #20 rst = 0;
        #10;
        
        // Start FSM
        $display("Starting frame at time %0t", $time);
        arm_start = 1;
        #10 arm_start = 0;
        
        // Wait a cycle to enter COLLECTING
        #10;
        
        // Send all 512 FFT samples (one per 10ns clock)
        $display("Sending 512 samples...");
        fft_valout = 1;
        for (int i = 0; i < 512; i++) begin
            fft_data_out = {27'd0, 27'(i << 9)};
            #10;
        end
        fft_valout = 0;
        
        $display("All samples sent. Time=%0t, State=%b", $time, dut.current_state);
        $display("sample_cnt=%0d, wr_ptr=%0d", dut.sample_cnt, dut.wr_ptr);
        
        // Wait for BROADCASTING state (should happen after sample 511)
        #20; // Give it a cycle to transition
        $display("Checking for BROADCASTING...");
        
        // BROADCASTING takes 512 cycles to read out
        $display("Waiting for broadcast (512 cycles)...");
        #5200; // 512 * 10ns = 5120ns, plus margin
        
        $display("Time=%0t, State=%b (10=BROADCASTING, 11=DONE)", $time, dut.current_state);
        $display("rd_ptr=%0d", dut.rd_ptr);
        
        // Wait for transition to DONE
        #20;
        
        // Final check
        $display("\n=== FINAL RESULTS ===");
        $display("State: %b (00=IDLE, 01=COLLECT, 10=BROADCAST, 11=DONE)", dut.current_state);
        $display("frame_done: %b (expected: 1)", frame_done);
        $display("sample_buffer[0] = %0d (expected: 0)", dut.sample_buffer[0]);
        $display("sample_buffer[1] = %0d (expected: 1)", dut.sample_buffer[1]);
        $display("sample_buffer[10] = %0d (expected: 10)", dut.sample_buffer[10]);
        
        if (dut.current_state == 2'b11 && frame_done == 1)
            $display("PASS: Full frame processed successfully!");
        else
            $display("FAIL: Did not reach DONE state or frame_done not asserted");
            
        $finish;
    end
    
    // Timeout safety
    initial begin
        #20000; // 20us max
        $display("TIMEOUT");
        $finish;
    end
endmodule