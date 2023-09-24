`default_nettype none

module Regfile(
    input   wire          clk,
    input   wire          rst,

    // 読み込み
    input  wire   [4:0]   addr1,
    output logic [31:0]   rd1,
    input  wire   [4:0]   addr2,
    output logic [31:0]   rd2,

    // 書き込み
    input  wire  [4:0]    addr3,
    input  wire           we3,
    input  wire [31:0]    wd3
);

logic [31:0] regfile [0:31];

always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 32; i++) begin
            regfile[i] <= 32'h0;
        end
    end else begin
        if (we3) begin
            regfile[addr3] <= wd3;
        end
    end
end

always_comb begin
    // rd1にaddr1の中身を出力
    rd1 = regfile[addr1];

    // rd2にaddr2の中身を出力
    rd2 = regfile[addr2];
end

endmodule
`default_nettype wire