`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

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
