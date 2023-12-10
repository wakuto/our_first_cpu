`default_nettype none

module DMemory (
    input  wire             clk,
    input  wire             rst,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable,
    input  wire  [3:0]      write_mask,
    input  wire             read_enable,
    output logic [31: 0]    read_data,
    output logic            read_valid,

    output logic CEN [0:3],
    output logic GWEN [0:3],
    output logic [7:0] WEN [0:3],
    output logic [8:0] A [0:3],
    output logic [7:0] D [0:3],
    input  wire  [7:0] Q [0:3]
);

always_comb begin
    for(int i=0;i<4;i++) begin
        CEN[i]  = rst;
        GWEN[i] = !write_enable;
        WEN[2'(address+i)]  = {8{!write_mask[i]}};
        A[i] = 9'((address + i) >> 2);
        D[i] = write_data[8*i +: 8];
    end
    read_data = {Q[3], Q[2], Q[1], Q[0]};
end
always_ff @(posedge clk) begin
    if (read_enable && !write_enable && !read_valid) begin
        read_valid <= 1'b1;
    end else begin
        read_valid <= 1'b0;
    end
end
endmodule
`default_nettype wire
