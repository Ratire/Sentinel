`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

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
