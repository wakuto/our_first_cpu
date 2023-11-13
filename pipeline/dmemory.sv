`default_nettype none

module DMemory (
    input  wire             clk,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable,
    input  wire  [3:0]      write_mask,
    output logic [31: 0]    read_data
);

logic [7:0] dmemory [0:1023];

always_ff @(posedge clk) begin
    if(write_enable) begin
        if(write_mask[0]) dmemory[address] <= write_data[7:0];
        if(write_mask[1]) dmemory[address+1] <= write_data[15:8];
        if(write_mask[2]) dmemory[address+2] <= write_data[23:16];
        if(write_mask[3]) dmemory[address+3] <= write_data[31:24];
    end
end

// 00000001
// 00000010
// 00000100
// ...
// 10000000
// dmemory
always_comb begin
    if (address < 32'd32) begin
        read_data = 32'h1 << address;
    end else begin
        read_data = {dmemory[address+3],dmemory[address+2],dmemory[address+1],dmemory[address]};
    end
end

endmodule
`default_nettype wire
