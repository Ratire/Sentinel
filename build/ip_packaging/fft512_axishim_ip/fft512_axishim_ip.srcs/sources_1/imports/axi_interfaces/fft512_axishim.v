module fft512_axishim (
    input  wire        clk,
    input  wire        rst,
    
    // AXI-Stream from DMA (MM2S)
    input  wire [63:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output reg         s_axis_tready,
    
    // AXI-Stream to DMA (S2MM)
    output reg  [63:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    output reg         m_axis_tlast,
    input  wire        m_axis_tready,
    
    // FFT interface
    output reg         fft_valin,
    output wire [17:0] fft_datain,
    input  wire        fft_valout,
    input  wire [53:0] fft_dataout
);

    // input side: 512 samples DMA -> FFT
    reg [9:0] in_cnt;
    reg       in_active;
    
    always @(posedge clk) begin
        if (rst) begin
            in_cnt <= 0;
            in_active <= 1'b1;
        end else if (in_active && s_axis_tvalid && s_axis_tready) begin
            in_cnt <= in_cnt + 1;
            if (in_cnt == 511) in_active <= 1'b0;
        end
    end
    
    always @(*) s_axis_tready = in_active;
    always @(*) fft_valin = s_axis_tvalid && s_axis_tready;
    assign fft_datain = s_axis_tdata[17:0];

    // output side: 512 samples FFT -> DMA
    reg [9:0] out_cnt;
    reg       out_active;
    
    always @(posedge clk) begin
        if (rst) begin
            out_cnt <= 0;
            out_active <= 1'b1;
        end else if (out_active && fft_valout && m_axis_tready) begin
            out_cnt <= out_cnt + 1;
            if (out_cnt == 511) out_active <= 1'b0;
        end
    end
    
    always @(*) m_axis_tvalid = fft_valout && out_active;
    always @(*) m_axis_tdata = {10'b0, fft_dataout};
    always @(*) m_axis_tlast = (out_cnt == 511) && fft_valout && out_active;

endmodule