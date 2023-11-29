`default_nettype none

module DMemory (
    input  wire             clk,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable,
    input  wire  [3:0]      write_mask,
    input  wire             read_enable,

    output logic [31: 0]    read_data,
    output logic            read_valid
);

logic [7:0] dmemory [0:4095];

always_ff @(posedge clk) begin
    if(write_enable) begin
        if(write_mask[0]) dmemory[address] <= write_data[7:0];
        if(write_mask[1]) dmemory[address+1] <= write_data[15:8];
        if(write_mask[2]) dmemory[address+2] <= write_data[23:16];
        if(write_mask[3]) dmemory[address+3] <= write_data[31:24];
    end

    // read_enableがTrueの時、次のクロックで読み出しを実行
    if (read_enable && !write_enable && !read_valid) begin
        read_valid <= 1'b1;
    end else begin
        read_valid <= 1'b0;
    end

    if (read_valid) begin
        read_data <= {dmemory[address+3],dmemory[address+2],dmemory[address+1],dmemory[address]};
    end else begin
        read_data <= read_data;
    end
end

endmodule
`default_nettype wire
