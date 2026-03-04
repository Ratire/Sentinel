`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module tb_Butterfly_FSM;
    //parameters of DUT
    //localparam int MTI = 4, STRIDE = 1;
    localparam int MTI = 1, STRIDE = 256;
    
    //inputs
    logic val_in = 0, clk = 0, rst = 0;
    
    always #5 clk = ~clk;
    //outputs
    logic [DATA_W-1:0] twiddle;
    logic bf_on, val_out;
    
    Butterfly_FSM #(.MTI(MTI), .STRIDE(STRIDE)) dut (.val_in(val_in), .clk(clk), .rst(rst), .twiddle(twiddle), .bf_on(bf_on), .val_out(val_out));
    
    task automatic test_fsm_current_state(input state_t current_state);
        //to later be defined for testing what happens from that state with any initial value
    endtask
    
    task automatic wait_c(input int j); //lets j-1 cycles pass and stops simulation at posedge of clk
        for(int i = 0; i < j; ++i)
            @(posedge clk);
    endtask
    
    task automatic test_normal_procedure();
    //Set it to initial state
        @(posedge clk);
        rst <= 1;
        val_in <= 0;
        
    //Test 1: Long test of IDLE state with !rst, !val_in
        @(posedge clk)
        rst <= 0;
        
        wait_c(MTI + 4); //nothing should occur during this timeframe, and it should be in IDLE state
        
    //Test 2: Reset back to IDLE state from SHIFT, and transitions b/w SHIFT and FLOW, vice versa
        @(posedge clk);
        rst <= 0;
        val_in <= 1;
        
        wait_c(MTI + 1); //should be in SHIFT state for entirety of interval
        
        wait_c(MTI + 1);//should be in FLOW state for entirety of interval
        
        wait_c(MTI + 1);//should be back in SHIFT state for entirety of interval
        rst <= 1; //test rst from SHIFT state
        
    //Test 3: Reset back to IDLE state from FLOW
        @(posedge clk);
        rst <= 0;
        val_in <= 1;
        
        wait_c(MTI + 1); //should be in SHIFT state for entirety of interval
        
        wait_c(MTI - 1);//should be in FLOW state for entirety of interval
        rst <= 1; //test rst from FLOW state
        
    //Test 4: Long test of IDLE state and traversal of FSM with !rst, val_in
        @(posedge clk);
        rst <= 0;
        val_in <= 1;
        
        wait_c(4*MTI);
        
    endtask
    
    initial
    begin
     test_normal_procedure();
    end
endmodule
