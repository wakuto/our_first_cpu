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
    $readmemh("../test/test.hex", mem);
end

logic        is_first_clk;
logic [31:0] pc_fetching;
logic [31:0] pc_fetched;

always_ff @(posedge clk) begin
    // 現在のサイクルはリセット直後かどうか？
    if (rst) begin
        is_first_clk <= 1'b1;
    end else begin
        is_first_clk <= 1'b0;
    end

    pc_fetched <= pc_fetching;
    instr <= {mem[pc_fetching+3], mem[pc_fetching+2], mem[pc_fetching+1], mem[pc_fetching]};
end

always_comb begin
    valid = ~is_first_clk && (pc_fetched == pc);
    if (!valid) begin
        pc_fetching = pc;
    end else begin
        pc_fetching = pc + 4;
    end
end

endmodule
`default_nettype wire
