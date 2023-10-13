`default_nettype none

module Memory (
    input  wire             clk,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable,
    output logic [31: 0]     read_data
);

logic [7:0] memory [0:4095];

int fd = $fopen("../program/program.bin", "rb");
int i = 0;
int res = 1;
initial begin
    res = $fread(memory, fd, 0, 4096);
    $fclose(fd);
end

always_ff @(posedge clk) begin
    if(write_enable) begin
        for (int i = 0; i < 4; i++) begin
            memory[address + i] <= write_data[i*8 +: 8];
        end
    end
end

always_comb begin
    for(int i = 0; i < 4; i++) begin
        read_data[i*8 +: 8] = memory[address + i];
    end
end

endmodule
`default_nettype wire