`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module SDF_mod 
    #(parameter int S = 1, //S represents the stage this SDF module is at in the FFT
      parameter bit SHIFT_SUM_EN  = 1,
      parameter bit SHIFT_DIFF_EN = 1,
      parameter int POINTS = 512) 
    (
    input logic [DATA-1:0] data_in,
    input logic val_in, clk, rst,
    output logic [DATA-1:0] data_out,
    output logic val_out
    );
    
    localparam DELAY_BUFFER_SIZE = 2**($clog2(POINTS) - S);
    localparam STRIDE = 2**(S-1);
    
    //Connecting signals between modules
    logic bf_on;
    logic [DATA_W-1:0] twiddle;
    logic [DATA-1:0] data_out_int, delay_in_int, delay_out;
    
    Butterfly_FSM #(.MTI(DELAY_BUFFER_SIZE), .STRIDE(STRIDE)) bf_fsm (.val_in(val_in), .clk(clk), .rst(rst), .twiddle(twiddle), .bf_on(bf_on), .val_out(val_out));
    Shift_Reg #(.REG_SIZE(DELAY_BUFFER_SIZE)) shift_reg (.delay_in(delay_in_int), .clk(clk), .rst(rst), .val_in(val_in), .delay_out(delay_out));
    Butterfly #(.SHIFT_SUM_EN(SHIFT_SUM_EN), .SHIFT_DIFF_EN(SHIFT_DIFF_EN)) bf (.data_in(data_in), .delay_out(delay_out), .twiddle(twiddle), .bf_on(bf_on), .data_out(data_out), .delay_in(delay_in_int));
    
endmodule

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
