`timescale 1ns / 1ps
import systolic_array_pkg::*;

module pe_cell_tb;

    logic clk = 0;
    logic rst;
    logic [PE_INP_WIDTH-1:0] activation_i;
    logic [PE_INP_WIDTH-1:0] weight_i;
    logic enable_i;
    
    logic [PE_INP_WIDTH-1:0] activation_o;
    logic [PE_INP_WIDTH-1:0] weight_o;
    logic enable_o;
    logic [PE_ACCUM_WIDTH-1:0] accum_o;
    logic valid_o;
    
    always #5 clk = ~clk;
    
    pe_cell #(.row(0), .column(0), .K(512)) dut (.*);
    
    // Monitor/Assertions (optional but helpful)
    always @(posedge clk) 
    begin
        if (!rst) 
        begin
            $display("Time=%0t: enable_i=%b, accum_o=%0d, valid_o=%b, cntr=%0d", 
                     $time, enable_i, accum_o, valid_o, dut.cntr);
        end
    end
    
    initial
    begin
        // 1. Reset phase
        rst <=           1;
        enable_i <=      0;
        activation_i <=  0;
        weight_i <=      0;
        
        wait_cp(3, clk);
        
        rst <=            0;
        activation_i <= 100;        //Test 1: ACT: 100 | WEIGHT: 200 | ACCUM_EXPECTED: 20,000
        weight_i <=     200;
        enable_i <=       1;
        
        wait_cn(2, clk);
        
        assert (accum_o == 20000) else 
        $error("Assertion failed: accum_o is not equal to 20,000 at time %t | accum_o observed %0d", $time, accum_o); 
        
        enable_i <=       0;        // Also testing if enable carries on within enable_reg
        activation_i <=  10;        //Test 2: ACT: 10 | WEIGHT: 5 | ACCUM_EXPECTED: 20,000 + 5*10 = 20,050
        weight_i <=       5;
        
        wait_cn(1, clk);
        
        assert(accum_o == 20050) else 
        $error("Assertion failed: accum_o is not equal to 20,050 at time %t | accum_o observed %0d", $time, accum_o); 
        
        activation_i <=  20;        //Test 3: ACT: 20 | WEIGHT: 3 | ACCUM_EXPECTED: 20,000 + 5*10 + 3*20= 20,110
        weight_i <=       3;
        
        wait_cn(1, clk);
        
        assert(accum_o == 20110) else 
        $error("Assertion failed: accum_o is not equal to 20,110 at time %t | accum_o observed %0d", $time, accum_o); 
        
        activation_i <=  30;        //Test 4: ACT: 30 | WEIGHT: 2 | ACCUM_EXPECTED: 20,000 + 5*10 + 3*20 + 2*30 = 20,170
        weight_i <=       2;
        
        wait_cn(1, clk);
        
        assert(accum_o == 20170) else 
        $error("Assertion failed: accum_o is not equal to 20,170 at time %t | accum_o observed %0d", $time, accum_o);
        
        activation_i <=   1;
        weight_i <=       1;
        
        wait_cp(550, clk);
        
        $finish;
    end

endmodule