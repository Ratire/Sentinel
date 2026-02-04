package FFT_pkg;
    //Signed formats of the fixed point values
    localparam int DATA_I = 12, DATA_F = 15; //12 integer bits and 15 fractional bits (MSB integer bit is the sign bit as well)
    localparam int DATA_W_I = 1, DATA_W_F = 17; //same format
    
    localparam int DATA = 2*(DATA_I + DATA_F); //must be an even number for both
    localparam int DATA_W = 2*(DATA_W_I + DATA_W_F);
    
    typedef enum logic [2:0] {IDLE, SHIFT, SHLOW, FLOW, FLIFT} state_t; //FSM states of butterfly FSM module
    
    typedef struct packed {
        logic signed [DATA/2-1:0] r_val, c_val; //real and complex values
    } complex_data;
    
    typedef struct packed {
        logic signed [DATA_W/2-1:0] r_val, c_val; //real and complex values
    } complex_data_twiddle;
    
    localparam SDF_EXTENDED_SIZE = DATA/2 + DATA_W/2 + 2;
    
    function automatic logic signed [DATA/2-1:0] saturate_mul (input logic signed [SDF_EXTENDED_SIZE-1:0] data);
        logic signed[DATA/2 + 2:0] q15_15 = data[$left(data) -: DATA/2 + 3];
        logic signed [DATA/2-1:0] q12_15 = q15_15[$left(q15_15)-3 -: DATA/2];
        
        //Saturate in the Q12.15 domain
        localparam logic signed [DATA/2-1:0] MAX = (2**(DATA/2-1))-1;
        localparam logic signed [DATA/2-1:0] MIN = -(2**(DATA/2-1));
        
        if (q12_15 > MAX)       return MAX;
        else if (q12_15 < MIN)  return MIN;
        else                    return q12_15;
    endfunction
    
    function automatic logic signed [DATA/2-1:0] saturate_add_27 (input logic signed [DATA/2:0] data);
        
        //Saturate in the Q12.15 domain
        localparam logic signed [DATA/2-1:0] MAX = (2**(DATA/2-1))-1;
        localparam logic signed [DATA/2-1:0] MIN = -(2**(DATA/2-1));
        
        if (data > MAX)       return MAX;
        else if (data < MIN)  return MIN;
        else                  return data[DATA/2-1:0];
    endfunction

endpackage