package systolic_array_pkg;
    
    localparam K_POINTS = 512;
    localparam PE_INP_WIDTH = 18;
    localparam PE_ACCUM_WIDTH = PE_INP_WIDTH*2 + $clog2(K_POINTS);
    
    task automatic wait_cp(input int j, ref logic clk); // j-1 cycles, stop at posedge
        for (int i = 0; i < j; ++i)
            @(posedge clk);
    endtask

    task automatic wait_cn(input int j, ref logic clk); // j-1 cycles, stop at negedge
        for (int i = 0; i < j; ++i)
            @(negedge clk);
    endtask

endpackage
