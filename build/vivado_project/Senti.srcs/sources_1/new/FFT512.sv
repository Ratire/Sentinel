`timescale 1ns / 1ps
import FFT_pkg::*; // Import all definitions

module FFT512
    (
    input logic [DATA_INP-1:0] data_in,
    input logic val_in, clk, rst,
    output logic [DATA-1:0] data_out,
    output logic val_out
    );
    
    logic [DATA-1:0] data_buffer12, data_buffer23, data_buffer34, 
    data_buffer45, data_buffer56, data_buffer67, data_buffer78, data_buffer89;
    
    logic val12, val23, val34, val45, val56, val67, val78, val89;
        
    logic [DATA-1:0] data_in_ext;
    assign data_in_ext = {
                            {{(DATA/2-DATA_INP){data_in[DATA_INP-1]}}, data_in}, // real: sign-extended
                            {DATA/2{1'b0}}                                     // imag: 0
                         };
    
    SDF_mod #(.S(1), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf1 (.data_in(data_in_ext), .val_in(val_in), .clk(clk), .rst(rst), .data_out(data_buffer12), .val_out(val12));
    SDF_mod #(.S(2), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf2 (.data_in(data_buffer12), .val_in(val12), .clk(clk), .rst(rst), .data_out(data_buffer23), .val_out(val23));
    SDF_mod #(.S(3), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf3 (.data_in(data_buffer23), .val_in(val23), .clk(clk), .rst(rst), .data_out(data_buffer34), .val_out(val34));
    SDF_mod #(.S(4), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf4 (.data_in(data_buffer34), .val_in(val34), .clk(clk), .rst(rst), .data_out(data_buffer45), .val_out(val45));
    SDF_mod #(.S(5), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf5 (.data_in(data_buffer45), .val_in(val45), .clk(clk), .rst(rst), .data_out(data_buffer56), .val_out(val56));
    SDF_mod #(.S(6), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf6 (.data_in(data_buffer56), .val_in(val56), .clk(clk), .rst(rst), .data_out(data_buffer67), .val_out(val67));
    SDF_mod #(.S(7), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf7 (.data_in(data_buffer67), .val_in(val67), .clk(clk), .rst(rst), .data_out(data_buffer78), .val_out(val78));
    SDF_mod #(.S(8), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf8 (.data_in(data_buffer78), .val_in(val78), .clk(clk), .rst(rst), .data_out(data_buffer89), .val_out(val89));
    SDF_mod #(.S(9), .SHIFT_SUM_EN(0), .SHIFT_DIFF_EN(0), .POINTS(512)) sdf9 (.data_in(data_buffer89), .val_in(val89), .clk(clk), .rst(rst), .data_out(data_out), .val_out(val_out));
    
endmodule


module tb_FFT512;
    localparam int POINTS = 512;
    localparam int NUM_CASES = 7;
    localparam TOL = 700;

    logic [DATA_INP-1:0] data_in = '0;
    logic val_in = 0, clk = 0, rst = 0;
    logic [DATA-1:0] data_out;
    logic val_out;
    
    logic signed [DATA/2-1:0] hw_re, hw_im;
    assign {hw_re, hw_im} = data_out;
    
    always #5 clk = ~clk;
    
    logic [DATA_INP-1:0] data_in_arr [0:POINTS-1][0:0]; //inputs
    logic [DATA/2-1:0] data_out_arr [0:POINTS-1][0:1];  //outputs
    logic signed [DATA/2-1:0] exp_re, exp_im;
    
    //bookeeping variables
    int max_abs_re [1:9];
    int max_abs_im [1:9];
    
    int max_err_re, max_err_im;
    longint sum_abs_err_re, sum_abs_err_im;
    
    FFT512 dut (data_in, val_in, clk, rst, data_out, val_out);
    
    logic [1:9][DATA-1:0] data_buffer_i_ip1;
    assign data_buffer_i_ip1 = {dut.data_buffer12, dut.data_buffer23,
                                dut.data_buffer34, dut.data_buffer45,
                                dut.data_buffer56, dut.data_buffer67,
                                dut.data_buffer78, dut.data_buffer89,
                                dut.data_out};
                                
    logic [1:9] val_i_ip1;
    assign val_i_ip1 = {dut.val12, dut.val23,
                        dut.val34, dut.val45,
                        dut.val56, dut.val67,
                        dut.val78, dut.val89,
                        dut.val_out};
                        
                        
   logic [1:9][DATA_W-1:0] twiddle_i_ip1;
   assign twiddle_i_ip1 = {dut.sdf1.bf_fsm.twiddle, dut.sdf2.bf_fsm.twiddle,
                           dut.sdf3.bf_fsm.twiddle, dut.sdf4.bf_fsm.twiddle,
                           dut.sdf5.bf_fsm.twiddle, dut.sdf6.bf_fsm.twiddle,
                           dut.sdf7.bf_fsm.twiddle, dut.sdf8.bf_fsm.twiddle,
                           dut.sdf9.bf_fsm.twiddle};
                           
    logic [1:9] bf_on_i_ip1;
    assign bf_on_i_ip1 = '{dut.sdf1.bf_on, dut.sdf2.bf_on,
                           dut.sdf3.bf_on, dut.sdf4.bf_on,
                           dut.sdf5.bf_on, dut.sdf6.bf_on,
                           dut.sdf7.bf_on, dut.sdf8.bf_on,
                           dut.sdf9.bf_on};

                        
   //-------------------------//
   // Checking Stages Outputs //
   //-------------------------//
    
    logic signed [DATA-1:0] s1;
    logic signed [DATA/2-1:0] s1_re, s1_im;
    assign s1 = data_buffer_i_ip1[1];
    assign {s1_re, s1_im} = s1;
    int fd_stage[1:9];
    int fd_dbg;

    
    class FileBlockLoader #(int WIDTH = 18, int POINTS = 512, int IS_OUTPUT = 1);               
        task automatic load_512_block (input int fd, output logic [WIDTH-1:0] vec[0:POINTS-1][0:IS_OUTPUT]);
            int code, i = 0;
            string line;
            
            while (i < POINTS && !$feof(fd)) 
            begin
                if (!$fgets(line, fd)) break;                    // read full line
                if (line.len() == 0 || line[0] == "#") continue; // skip blank/comment
        
                if (IS_OUTPUT == 0) 
                begin
                    code = $sscanf(line, "%b", vec[i][0]);      
                    if (code == 1) i++;                          // count only good lines
                end
                else 
                begin
                    code = $sscanf(line, "%b %b", vec[i][0], vec[i][1]);
                    if (code == 2) i++;
                end
            end
        endtask
    endclass
    
    typedef FileBlockLoader#(.WIDTH(DATA_INP), .POINTS(POINTS), .IS_OUTPUT(0)) InpLoader_t;
    typedef FileBlockLoader#(.WIDTH(DATA/2),   .POINTS(POINTS), .IS_OUTPUT(1)) OutLoader_t;
    
    task automatic load_input_output_arrays (input int f_inp, ref logic [DATA_INP-1:0] arr_inp [0:POINTS-1][0:0], 
                                             input int f_out, ref logic [DATA/2-1:0] arr_out [0:POINTS-1][0:1],
                                             input InpLoader_t inp_fbl, input OutLoader_t out_fbl);
        
        inp_fbl.load_512_block (f_inp, arr_inp);
        out_fbl.load_512_block (f_out, arr_out);
    endtask
    
    task automatic wait_cp(input int j); //lets j-1 cycles pass and stops simulation at posedge of clk
        for(int i = 0; i < j; ++i)
            @(posedge clk);
    endtask
    
    task automatic wait_cn(input int j); //lets j-1 cycles pass and stops simulation at negedge of clk
        for(int i = 0; i < j; ++i)
            @(negedge clk);
    endtask
        
    always_ff @(posedge clk) 
    begin
        for (int i = 1; i < 10; ++i)
        begin
            if (rst) 
            begin
                max_abs_re[i] <= 0;
                max_abs_im[i] <= 0;
            end 
            
            else if (val_i_ip1[i]) 
            begin
                automatic logic signed [DATA/2-1:0] re = data_buffer_i_ip1[i][DATA-1 : DATA/2];
                automatic logic signed [DATA/2-1:0] im = data_buffer_i_ip1[i][DATA/2-1 : 0];
                
                automatic int abs_re = (re < 0) ? -re : re;
                automatic int abs_im = (im < 0) ? -im : im;
                
                if (abs_re > max_abs_re[i]) max_abs_re[i] <= abs_re;
                if (abs_im > max_abs_im[i]) max_abs_im[i] <= abs_im;
            end
        end
    end

    
    initial
    begin
        automatic int watchdog = 0;
        automatic int fd_inp, fd_out;
        automatic int fd_stage1;
        automatic int in_idx  = 0, out_idx = 0;
        automatic int abs_e_re, abs_e_im;
        
        InpLoader_t inp_fbl;
        OutLoader_t out_fbl;
  
        fd_inp  = $fopen("fft_input_sv.mem",  "r");
        fd_out = $fopen("fft_output_sv.mem", "r");
        
        fd_dbg = $fopen("fft_dbg.txt", "w");
  
        
        fd_stage[1] = $fopen("stage1_hw.txt","w");
        fd_stage[2] = $fopen("stage2_hw.txt","w");
        fd_stage[3] = $fopen("stage3_hw.txt","w");
        fd_stage[4] = $fopen("stage4_hw.txt","w");
        fd_stage[5] = $fopen("stage5_hw.txt","w");
        fd_stage[6] = $fopen("stage6_hw.txt","w");
        fd_stage[7] = $fopen("stage7_hw.txt","w");
        fd_stage[8] = $fopen("stage8_hw.txt","w");
        fd_stage[9] = $fopen("stage9_hw.txt","w");
        
        if (!fd_dbg) $fatal(1, "Could not open fft_dbg.txt");
        
        foreach(fd_stage[i])
        begin
            if (fd_stage[i] == 0) $fatal(1, "Failed to open stage%01d_hw.txt", i);
        end
            
        if (!fd_inp || !fd_out) $fatal(1, "Cannot open mem files");
        
        inp_fbl  = new;
        out_fbl = new;
        
        wait_cp(1); //reach negedge
        
        rst <= 1; //reset
        wait_cp(1); //test it
        
        rst <= 0;
        val_in <= 1'b1;
        
        max_err_re = 0;
        max_err_im = 0;
        sum_abs_err_re = 0;
        sum_abs_err_im = 0;
        
        for (int z = 0; z < NUM_CASES; ++z)
        begin
            in_idx  = 0; out_idx = 0;
            load_input_output_arrays(fd_inp, data_in_arr, fd_out, data_out_arr, inp_fbl, out_fbl);
            
            // keep clocking until all inputs driven AND all outputs checked
            while (out_idx < POINTS && watchdog < 20000) 
            begin
                
                for (int i = 1; i < 10; ++i)
                begin
                    if (val_i_ip1[i]) 
                    begin
                        $fdisplay(fd_dbg, "bin=%0d s%0d_re=%0d s%0d_im=%0d tw=0x%h bf_on=%0b",
                                  out_idx, i, (i==1 ? dut.data_in_ext[DATA-1:DATA/2] : data_buffer_i_ip1[i-1][DATA-1:DATA/2]),
                                  i, (i==1 ? dut.data_in_ext[DATA/2-1:0] : data_buffer_i_ip1[i-1][DATA/2-1:0]),
                                  twiddle_i_ip1[i], bf_on_i_ip1[i]);
                    end
                end
                
                for (int s = 1; s <= 9; s++) 
                begin
                    if (val_i_ip1[s]) begin
                        automatic logic signed [DATA/2-1:0] re_s;
                        automatic logic signed [DATA/2-1:0] im_s;
                        re_s = data_buffer_i_ip1[s][DATA-1 : DATA/2];
                        im_s = data_buffer_i_ip1[s][DATA/2-1 : 0];
                        $fdisplay(fd_stage[s], "%0d %0d", re_s, im_s);
                    end
                end
            
                // drive next input sample if we still have any
                if (in_idx < POINTS) 
                begin
                    data_in <= data_in_arr[in_idx][0];
                    in_idx++;
                end 
                
                @(posedge clk);
                
                exp_re = data_out_arr[out_idx][0];
                exp_im = data_out_arr[out_idx][1];
                
                // check output whenever valid
                if (val_out) 
                begin
                    out_idx++;
                
                    $display("t=%0t idx %0d: hw_re=%0d, exp_re=%0d; hw_im=%0d, exp_im=%0d", $time, out_idx, hw_re, exp_re, hw_im, exp_im);

                    
                    abs_e_re = (hw_re > exp_re) ? (hw_re - exp_re) : (exp_re - hw_re);
                    abs_e_im = (hw_im > exp_im) ? (hw_im - exp_im) : (exp_im - hw_im);
                    
                    sum_abs_err_re += abs_e_re;
                    sum_abs_err_im += abs_e_im;
                    if (abs_e_re > max_err_re) max_err_re = abs_e_re;
                    if (abs_e_im > max_err_im) max_err_im = abs_e_im;
                
                    if ( 
                         (hw_re - exp_re > TOL) || (exp_re - hw_re > TOL) ||
                         (hw_im - exp_im > TOL) || (exp_im - hw_im > TOL) 
                       ) 
                    begin
                        $error("t=%0t idx=%0d re: exp=%0d got=%0d im: exp=%0d got=%0d",
                        $time, out_idx, exp_re, hw_re, exp_im, hw_im);
                    end
                end 
                
                $display("t=%0t; in_idx=%0d; out_idx=%0d\n", $time, in_idx, out_idx);
            end
        end

        $fclose(fd_inp);
        $fclose(fd_out);
        
        for (int s = 1; s <= 9; s++) 
        begin
            $fclose(fd_stage[s]);
        end
        
        $fclose(fd_dbg);
        
        
        #10000;
        foreach (max_abs_re[s]) 
        begin
            $display("Stage %0d: max_abs_re=%0d max_abs_im=%0d",
            s, max_abs_re[s], max_abs_im[s]);
        end
        
        $display("FFT summary: max_err_re=%0d max_err_im=%0d", max_err_re, max_err_im);
        $display("FFT summary: avg_err_re=%0f avg_err_im=%0f", real'(sum_abs_err_re)/POINTS, real'(sum_abs_err_im)/POINTS);
  
        $finish;
    end
    
endmodule