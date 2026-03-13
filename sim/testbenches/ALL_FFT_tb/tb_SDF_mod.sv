`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module tb_SDF_mod;
    localparam S = 1, POINTS = 8;
    logic [DATA-1:0] data_in = '0;
    logic val_in = 0, clk = 0, rst = 0;
    logic [DATA-1:0] data_out;
    logic val_out;
    
    always #5 clk = ~clk;
        
    SDF_mod #(.S(S), .POINTS(POINTS)) dut (.data_in(data_in), .val_in(val_in), .clk(clk), .rst(rst), .data_out(data_out), .val_out(val_out));
    
    task automatic wait_c(input int j); //lets j-1 cycles pass and stops simulation at posedge of clk
        for(int i = 0; i < j; ++i)
            @(posedge clk);
    endtask
    
    task automatic wait_incr(input int j); //lets j-1 cycles pass and stops simulation at posedge of clk
        for(int i = 0; i < j; ++i)
        begin
            @(posedge clk);
            data_in <= data_in + 1;
        end
    endtask
    
    initial
    begin
        wait_c(1);
        
        rst <= 1;
        
        wait_c(1);
        
        rst <= 0;
        
        wait_c(1);
        
        val_in <= 1;
        
        wait_incr(30);
        
        $finish;
    end

endmodule
