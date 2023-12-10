`default_nettype none

module IMemory(
    input  wire          clk,
    input  wire [31:0]   pc,
    input  wire          rst,

    output logic [31:0]  instr,
    output logic         valid,

    output logic CEN [0:3],
    output logic GWEN [0:3],
    output logic [7:0] WEN [0:3],
    output logic [8:0] A [0:3],
    output logic [7:0] D [0:3],
    input  wire  [7:0] Q [0:3]
);

always_comb begin
    for(int i=0;i<4;i++) begin
        CEN[i] = rst;
        GWEN[i] = 1;
        WEN[i]  = {8{1'b1}};
        A[i] = 9'((pc_fetching + i) >> 2);
        D[i] = 8'b0;
    end
    instr = {Q[3], Q[2], Q[1], Q[0]};
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
