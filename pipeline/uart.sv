`default_nettype none

module Uart(
    input logic clk,
    input logic rst,
    input logic write_enable,
    input logic [7:0] data,
    input logic [31:0] baud_rate,
    input logic [31:0] clk_frequency,
    input logic rx,

    output logic tx,
    output logic busy,
    output logic read_ready
); 
    // baud_clk生成
    logic [15:0] baud_counter = 16'b0;
    logic baud_clk = 1'b0;

    bit [4:0] count;  // 10からカウントダウン
    bit [9:0] tx_data;  // 送信データ

    always_ff @(posedge clk) begin
        if (rst) begin
            baud_counter <= 16'b0;
            baud_clk <= 16'b0;
            count <= 0;
            tx_data <= 8'b11111111;
            busy <= 1'b0;
            tx <= 1'b1;
        end else begin
            if (baud_counter == (clk_frequency/baud_rate-1)) begin
                baud_counter <= 16'b0;
                baud_clk <= ~baud_clk;

                // カウントダウン
                count <= (count == 0) ? 0 : count - 1;
                // 算術右シフトし、最下位位ビットをtxに代入
                tx_data <= $signed(tx_data) >>> 1;
                tx = tx_data[0];
            end else begin
                baud_counter <= baud_counter + 1;
            end
            // 送信が終わったら、busyを0にする
            if (count == 0) begin
                busy <= 1'b0;
            end
        end
        // 送信データをdataに読み込む(この処理のみ、clkの立ち上がりで行う)
        if (write_enable && busy == 0) begin
            tx_data <= {1'b1,data,1'b0};
            count <= 4'd10;
            busy <= 1'b1;
        end
    end

endmodule
`default_nettype wire
