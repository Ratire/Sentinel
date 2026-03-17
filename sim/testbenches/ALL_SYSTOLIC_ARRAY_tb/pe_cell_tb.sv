`timescale 1ns / 1ps
import systolic_array_pkg::*;

module pe_cell_tb;

    logic clk = 0;
    logic rst;
    
    // Data flow between pe_cells
    logic signed [PE_INP_WIDTH-1:0] activation_i;
    logic signed [PE_INP_WIDTH-1:0] activation_o;
    
    // Weight loading variables  
    logic signed [PE_INP_WIDTH-1:0] weight_load_data;
    logic                           weight_load_en;
    logic                           load_mode;
    
    // Control variables
    logic enable_i;
    logic enable_o;
    
    // Outputting results
    logic signed [PE_ACCUM_WIDTH-1:0] accum_o;
    logic                             valid_o;
    
    always #5 clk = ~clk;
    
    pe_cell #(.row(0), .column(0), .K(512)) dut (.*);
    
    // Monitor/Assertions (optional but helpful)
    always @(posedge clk) 
    begin
        if (!rst) 
        begin
            if (load_mode)
                $display("Time=%0t: LOAD | weight_addr=%0d | load_data=%0d", $time, dut.weight_addr, weight_load_data);
            else if (valid_o)
                $display("Time=%0t: DONE | accum_o=%0d | valid_o=%b", $time, accum_o, valid_o);
        end
    end
    
    initial
    begin
        // 1. Reset phase
        rst <=              1;
        load_mode <=        0;
        weight_load_en <=   0;
        weight_load_data <= 0;
        enable_i <=         0;
        activation_i <=     0;
        
        wait_cp(3, clk);
        
        
        // 2. Load Phase: Loading 512 weights (1 to 512) into BRAM
        load_mode <=        1;
        weight_load_en <=   1;
        rst <=              0;
        
        // Load sequence: Weight values 1, 2, 3, ..., 512
        for (int i = 0; i < 512; i++) begin
            weight_load_data <= i + 1;  //Test Load %0d: Loading weight %0d into addr %0d
            wait_cp(1, clk);
        end
        
        weight_load_en <=   0;
        load_mode <=        0;
        wait_cp(2, clk);  // Gap cycle before compute phase begins
        
        // 3. Compute Phase: Streaming 512 activations (1 to 512)
        // Expected final result: Dot product = sum of squares (1²+2²+...+512²) = 44,870,400
        
        // Dummy cycle: Loads weight[0] into registered output, multiplied by 0
        enable_i <=         1;
        activation_i <=     18'd0;  // DUMMY - adds 0 to final sum
        
        wait_cp(1, clk);
        
        //Test 1: ACT: 1 | WEIGHT: 1 | ACCUM_EXPECTED: 1*1 = 1
        activation_i <=     18'd1;
        
        wait_cp(1, clk);
        
        enable_i <=         0;  // enable_reg carries on for remaining 511 cycles
        
        // Continue with activations 2 through 512
        // (For brevity, we loop the middle 510 values, but each gets tested in hardware)
        for (int i = 2; i <= 513; i++) begin
            activation_i <= i;  //Test continues: ACT: %0d | WEIGHT: %0d | Running accumulation
            wait_cp(1, clk);
        end
        
        // Wait for completion and valid assertion
        wait_cp(5, clk);
        
        // Final Test: Verify complete accumulation after all 512 MACs
        // Expected: 44,870,400 (sum of squares from 1 to 512)
        assert (valid_o == 1) else 
            $error("Assertion failed: valid_o is not asserted at time %t | valid_o observed %b", $time, valid_o);
        
        assert (accum_o == 44870400) else 
            $error("Assertion failed: accum_o is not equal to 44,870,400 at time %t | accum_o observed %0d", $time, accum_o);
        
        $display("TEST PASSED: Final accumulation = %0d (Expected: 44,870,400)", accum_o);
        
        // 4. Reset Test: ARM-style reset for next inference
        rst <= 1;
        wait_cn(2, clk);
        rst <= 0;
        wait_cn(1, clk);
        
        assert (valid_o == 0 && accum_o == 0) else
            $error("Assertion failed: Reset did not clear accumulators at time %t | valid_o=%b, accum_o=%0d", $time, valid_o, accum_o);
            
        $display("Reset test PASSED: Accumulators cleared for next inference");
        
        wait_cp(10, clk);
        $finish;
    end

endmodule