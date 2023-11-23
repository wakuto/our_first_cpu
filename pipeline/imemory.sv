`default_nettype none

module IMemory(
    input  wire          clk,
    input  wire [31:0]   pc,
    input  wire          rst,

    output logic [31:0]  instr,
    output logic         valid
);

logic [7:0] mem [0:4095];

initial begin
    int fd = $fopen("../test/test.bin", "rb");
    int i = 0;
    int res = 1;
    res = $fread(mem, fd, 0, 4096);
    $fclose(fd);
end

logic        is_first_clk;
logic [31:0] pc_fetched;

always_ff @(posedge clk) begin
    // 現在のサイクルはリセット直後かどうか？
    if (rst) begin
        is_first_clk <= 1'b1;
    end else begin
        is_first_clk <= 1'b0;
    end

    pc_fetched <= pc;
    instr <= {mem[pc+3], mem[pc+2], mem[pc+1], mem[pc]};
end

always_comb begin
    valid = ~is_first_clk && (pc_fetched == pc);
end

endmodule
`default_nettype wire
