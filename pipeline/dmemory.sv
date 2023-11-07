`default_nettype none

module DMemory (
    input  wire             clk,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable,
    input  wire  [2:0]      funct3,
    output logic [31: 0]    read_data
);

logic [31:0] dmemory [0:1023];

always_ff @(posedge clk) begin
    if(write_enable) begin
        case(funct3)
            3'b000: dmemory[address] <= write_data[7:0];
            3'b001: dmemory[address] <= write_data[15:0];
            3'b010: dmemory[address] <= write_data;
            default:dmemory[address] <= write_data;
        endcase
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
        read_data = dmemory[address];
    end
end

endmodule
`default_nettype wire
