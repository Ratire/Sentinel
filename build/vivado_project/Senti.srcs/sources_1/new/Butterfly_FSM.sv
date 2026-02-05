`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module Butterfly_FSM#(parameter int MTI, STRIDE) //MTI stands for MAX_TWIDDLE_INDEX
    (
    input logic val_in, clk, rst,
    output logic [DATA_W-1:0] twiddle,
    output logic bf_on, val_out
    );
    
    state_t current_state = IDLE, next_state;
    
    logic [$clog2(MTI):0] n = '0;  //number of cycles in SHIFT state until it must set val_out to high and validate next stage SDF module.
    
    logic n_max;    //logic value set to high when n reaches its max value.
    assign n_max = (n+1 == MTI ? 1 : 0);
    
    logic [2:0] inp_vals, out_vals;
    assign inp_vals = {val_in, n_max, rst}; //simplified input_vals
    localparam VI = 2, NM = 1, RS = 0;
    
    //out_vals = {bf_on, val_out}
    localparam BF = 2, VINT = 1, VO = 0;
   
    logic [35:0] twiddle_rom [0:255];
    initial $readmemh("twiddle_unified.mem", twiddle_rom);
    
    assign twiddle = twiddle_rom[n*STRIDE];

    always_ff @(posedge clk or posedge rst) //go to next state block
    begin
        if (rst)
            begin
            current_state <= IDLE;
            n <= 0;
            {bf_on, val_out} <= 3'b00;
            end
        else
            begin
            current_state <= next_state;
            {bf_on, val_out} <= out_vals;
            end
            
        if (current_state inside {SHIFT, FLOW,  SHIFT_AGAIN} || (current_state == IDLE && inp_vals == 3'b100))
            begin
            n <= (n+1) % MTI;
            end
    end


    always_comb                             //choose next state block
    begin
        next_state = current_state;
        case (current_state)
            IDLE:
            begin
                priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
                    next_state = SHIFT;
            end
            
            SHIFT:
            begin
                priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
                    next_state = SHIFT;
                else if (inp_vals == 3'b110)                // val_in=1, n_max=1, rst=0
                    next_state = FLOW;
            end
            
            FLOW:
            begin
                priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
                    next_state = FLOW;
                else if (inp_vals == 3'b110)                // val_in=1, n_max=1, rst=0
                    next_state = SHIFT_AGAIN;
            end
            
            SHIFT_AGAIN:
            begin
                priority if (!inp_vals[VI] || inp_vals[RS])          // !val_in || rst
                    next_state = IDLE;
                else if (inp_vals == 3'b100)                // val_in=1, n_max=0, rst=0
                    next_state = SHIFT_AGAIN;
                else if (inp_vals == 3'b110)                // val_in=1, n_max=1, rst=0
                    next_state = FLOW;
            end
        endcase
    end


    always_comb                             //choose outputs based on both current state and inputs
    begin
        out_vals = 3'b00;
        
        case (current_state)
            IDLE:
            begin
                out_vals = 2'b00;
            end
            
            SHIFT:
            begin
                out_vals = (!inp_vals[VI] || inp_vals[RS]) ? 2'b00 : (inp_vals == 3'b110) ? 2'b11 : 2'b00;
            end
            
            FLOW:
            begin
               out_vals = (!inp_vals[VI] || inp_vals[RS]) ? 2'b00 : (inp_vals == 3'b110) ? 2'b01 : 2'b11;
            end
            
            SHIFT_AGAIN:
            begin
                out_vals = (!inp_vals[VI] || inp_vals[RS]) ? 2'b00 : (inp_vals == 3'b110) ? 2'b11 : 2'b01;
            end
        endcase
    end
endmodule

module tb_Butterfly_FSM;
    //parameters of DUT
    localparam int MTI = 4, STRIDE = 1;
    
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