`timescale 1ns / 1ps
import systolic_array_pkg::*; 
import FFT_pkg::*;

module feature_extractor (
    input logic clk, rst,
    
    // FFT Interface (direct)
    input logic fft_valout,
    input logic [DATA-1:0] fft_data_out,                    // Values are grabbed as Q10.17 as a pair set {real, complex}
    
    // Control from ARM
    input logic arm_start,
    output logic frame_done,
    
    // Systolic Array Interface (16 rows, broadcast)
    output logic [PE_INP_WIDTH-1:0] sa_activation_data,    // Broadcast to all rows
    output logic                    sa_activation_valid    // All rows see same valid
);

    // Counter and control
    logic [$clog2(K_POINTS):0] sample_cnt;
    logic collecting_active;
    logic broadcasting_active;
    
    typedef enum logic [1:0] { 
        IDLE = 2'b00, 
        COLLECTING = 2'b01, 
        BROADCASTING = 2'b10, 
        DONE = 2'b11 
    } state_type;
    state_type current_state = IDLE, next_state;
    
    // Buffer (512 x 18-bit)
    logic [PE_INP_WIDTH-1:0] sample_buffer [0:K_POINTS-1];
    logic [$clog2(K_POINTS)-1:0] wr_ptr;
    logic [$clog2(K_POINTS):0] rd_ptr;
    
    // Datapath signals
    logic signed [DATA/2-1:0] real_part;
    logic signed [DATA/2-1:0] imag_part;
    logic [DATA/2:0] abs_sum;
    logic [PE_INP_WIDTH-1:0] activation_val;

    //================================================================
    // CHANGING STATES AND OUTPUTTING VALUES (Sequential)
    //================================================================
    always_ff @(posedge clk)
    begin
        if (rst) 
        begin
            current_state <= IDLE;
            sample_cnt <= 0;
            collecting_active <= 1'b1;
            broadcasting_active <= 1'b1;
            wr_ptr <= 0;
            rd_ptr <= 0;
        end 
        
        else
        begin
            current_state <= next_state;
            
            //================================================================
            // UPDATING REGISTERS WITHIN WHICHEVER STATE IT IS CURRENTLY IN
            //================================================================
            
            // Counter for collecting phase
            if (collecting_active && sa_ready) 
            begin
                sample_cnt <= sample_cnt + 1;
                if (sample_cnt == 511) collecting_active <= 1'b0;
            end
            
            // Write to buffer during collect
            if (current_state == COLLECTING)
            begin
                sample_buffer[wr_ptr] <= activation_val;
                wr_ptr <= wr_ptr + 1;
            end
            
            // Read from buffer during broadcast
            if (current_state == BROADCASTING)
            begin
                rd_ptr <= rd_ptr + 1;
                if (rd_ptr == 512) broadcasting_active <= 1'b0;
            end
        end
    end

    //================================================================
    // CHOOSING NEXT STATE BLOCK (Combinational)
    //================================================================
    always_comb
    begin
        next_state = current_state; // All states hold their same state for the next state unless the specific input value(s) is acknowledged
        
        case (current_state)
            IDLE:
            begin
                if (arm_start)
                    next_state = COLLECTING;
            end
            
            COLLECTING:
            begin
                if (sample_cnt == 511)
                    next_state = BROADCASTING;
            end
            
            BROADCASTING:
            begin
                if (rd_ptr == 512)
                    next_state = DONE;
            end
            
            DONE:
            begin
                if (arm_start)
                    next_state = IDLE;
            end
        endcase
    end

    //================================================================
    // CHOOSING NEXT OUTPUTS BLOCK (Combinational)
    //================================================================
    always_comb
    begin
        // Extract real/imag from FFT output
        imag_part = fft_data_out[DATA/2-1:0];
        real_part = fft_data_out[DATA-1:DATA/2];
        
        // Absolute sum computation
        abs_sum = (real_part[DATA/2-1] ? -real_part : real_part) + 
                  (imag_part[DATA/2-1] ? -imag_part : imag_part);
        
        // Truncate to 18-bit (Q1.17)
        activation_val = abs_sum[DATA/2-1 -: PE_INP_WIDTH];
        
        // Output assignments
        frame_done = (current_state == DONE);
    end
    
    // External control signals
    assign sa_ready = (current_state == COLLECTING);  // Backpressure to FFT
    assign sa_activation_data = (rd_ptr == 0) ? '0 : sample_buffer[rd_ptr-1];
    assign sa_activation_valid = (current_state == BROADCASTING);

endmodule