`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module SDF_mod #(parameter int S = 1, POINTS = 512) //S represents the stage this SDF module is at in the FFT
    (
    input logic [DATA-1:0] data_in,
    input logic val_in, clk, rst,
    output logic [DATA-1:0] data_out,
    output logic val_out
    );
    
    localparam DELAY_BUFFER_SIZE = 2**($clog2(POINTS) - S);
    localparam STRIDE = 2**(S-1);
    
    //Connecting signals between modules
    logic bf_on, rst_reg;
    logic [DATA_W-1:0] twiddle;
    logic [DATA-1:0] data_out_int, delay_in_int, delay_out;
    
    assign rst_reg = (!val_in || rst);
    
    Butterfly_FSM #(.MTI(DELAY_BUFFER_SIZE), .STRIDE(STRIDE)) bf_fsm (.val_in(val_in), .clk(clk), .rst(rst), .twiddle(twiddle), .bf_on(bf_on), .val_out(val_out));
    Shift_Reg #(.REG_SIZE(DELAY_BUFFER_SIZE)) shift_reg (.delay_in(delay_in_int), .clk(clk), .rst(rst_reg), .delay_out(delay_out));
    Butterfly bf (.data_in(data_in), .delay_out(delay_out), .twiddle(twiddle), .bf_on(bf_on), .data_out(data_out), .delay_in(delay_in_int));
    
endmodule

module tb_SDF_mod;
    localparam S = 1, POINTS = 8;
    logic [DATA-1:0] data_in = '0;
    logic val_in = 0, clk = 0, rst = 0;
    logic [DATA-1:0] data_out;
    logic val_out;
    
    always #5 clk = ~clk;
        
    SDF_mod #(.S(S), .POINTS(POINTS)) dut (.data_in(data_in), .val_in(val_in), .clk(clk), .rst(rst), .data_out(data_out), .val_out(val_out));
    
    task automatic wait_c(input int j); //lets j-1 cycles pass and stops simulation at negedge of clk
        for(int i = 0; i < j; ++i)
            @(negedge clk);
    endtask
    
    task automatic wait_incr(input int j); //lets j-1 cycles pass and stops simulation at negedge of clk
        for(int i = 0; i < j; ++i)
        begin
            @(negedge clk);
            data_in <= data_in + 1;
        end
    endtask
    
    initial
    begin
        wait_c(2);
        
        rst <= 1;
        
        wait_c(2);
        
        val_in <= 1;
        
        wait_c(2);
        
        rst <= 0;
        
        wait_incr(30);
        
        $finish;
    end

endmodule
