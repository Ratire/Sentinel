`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Shift_Reg #(parameter int REG_SIZE)
    (
    input logic [DATA-1:0] delay_in,
    input logic clk, rst, val_in,
    output logic [DATA-1:0] delay_out
    );
    
    logic [REG_SIZE-1:0][DATA-1:0] reg_array = '{default: '0};
    
    assign delay_out = reg_array[REG_SIZE-1];
    
    always_ff @(posedge clk or posedge rst)
        begin
        priority if (rst)
            begin
            reg_array <= '{default: '0};
            end
        else if (val_in)
            begin
            reg_array <= {reg_array[REG_SIZE-2:0], delay_in};
            end
        end
endmodule



module tb_Shift_Reg;
    logic clk = 0, rst = 1, val_in = 0;
    logic [DATA-1:0] delay_in_var = '0, delay_out_var;
    
    localparam int REG_SIZE_TB = 5;
    
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