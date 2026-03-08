package FFT_pkg;
    //Signed formats of the fixed point values
    localparam int DATA_I = 12, DATA_F = 15; //12 integer bits and 15 fractional bits (MSB integer bit is the sign bit as well)
    localparam int DATA_W_I = 1, DATA_W_F = 17; //same format
    
    localparam DATA = 2*(DATA_I + DATA_F); //must be an even number for both
    localparam int DATA_W = 2*(DATA_W_I + DATA_W_F);
    
    localparam DATA_INP = 18; //inputted data width
    
    typedef enum logic [1:0] {IDLE, SHIFT, FLOW, SHIFT_AGAIN} state_t; //FSM states of butterfly FSM module
    
    typedef struct packed {
        logic signed [DATA/2-1:0] r_val, c_val; //real and complex values
    } complex_data;
    
    typedef struct packed {
        logic signed [DATA_W/2-1:0] r_val, c_val; //real and complex values
    } complex_data_twiddle;
    
    localparam SDF_EXTENDED_SIZE = DATA/2 + DATA_W/2 + 2;
    
    function automatic logic signed [DATA/2-1:0] saturate_mul (input logic signed [SDF_EXTENDED_SIZE-1:0] data);
        localparam logic signed [DATA/2-1:0] MAX = (2**(DATA/2-1))-1;
        localparam logic signed [DATA/2-1:0] MIN = -(2**(DATA/2-1));
        
        automatic logic signed [SDF_EXTENDED_SIZE-1:0] tmp;
        automatic logic signed [(SDF_EXTENDED_SIZE-1) : 0] data_shifted;
        
        tmp = (data >= 0) ? (data + (1 <<< (DATA_W_F-1))) : (data - (1 <<< (DATA_W_F-1)));
        data_shifted = tmp >>> DATA_W_F; //get rid of twiddle extra fractional bits        
        
        //Saturate in the Q12.15 domain
        if (data_shifted > MAX)       return MAX;
        else if (data_shifted < MIN)  return MIN;
        else                          return data_shifted[DATA/2-1:0];
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