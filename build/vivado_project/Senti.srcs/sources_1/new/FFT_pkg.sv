package FFT_pkg;
    
    localparam int DATA = 54;
    localparam int DATA_W = 36;
    
    typedef struct packed {
        logic signed [DATA/2-1:0] r_val, c_val; //real and complex values
    } complex_data;
    
    typedef struct packed {
        logic signed [DATA_W/2-1:0] r_val, c_val; //real and complex values
    } complex_data_twiddle;

endpackage