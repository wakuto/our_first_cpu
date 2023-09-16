module DMemory (
    input  wire             clk,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable, 
    output logic [31: 0]     read_data
);

logic [31:0] dmemory [0:1023];

always_ff @(posedge clk) begin
    if(write_enable) begin
        dmemory[address] <= write_data;
    end
end

always_comb begin
    if (address == 32'h0) begin
        read_data = 32'hdeadbeef;
    end else begin
        read_data = dmemory[address];
    end
end

endmodule