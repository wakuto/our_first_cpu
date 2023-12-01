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
    output logic read_ready,
    output logic [7:0] rx_data,
    output logic outValid
); 
    // baud_clk生成
    logic [31:0] baud_counter = 32'b0;
    logic baud_clk = 1'b0;

    bit [4:0] tx_counter;  // 10からカウントダウン
    bit [9:0] tx_data;  // 送信データ

    bit [4:0] rx_counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            baud_counter <= 32'b0;
            baud_clk <= 1'b0;
            tx_counter <= 0;
            tx_data <= '1;
            busy <= 1'b0;
            tx <= 1'b1;

            read_ready <= 1'b1;
            outValid <= 1'b0;
            rx_counter <= '1;
            rx_data <= '1;
        end else begin
            if (baud_counter == (clk_frequency/baud_rate-1)) begin
                baud_counter <= 32'b0;
                baud_clk <= ~baud_clk;

                //送信
                // カウントダウン
                tx_counter <= (tx_counter == 0) ? 0 : tx_counter - 1;
                // 算術右シフトし、最下位位ビットをtxに代入
                tx_data <= $signed(tx_data) >>> 1;
                tx <= tx_data[0];

                //受信
                //受信のスタートビットを検出
                if(!rx && read_ready) begin
                    rx_counter <= 5'd8;
                    read_ready <= 1'b0;
                end else begin
                    //カウントダウン
                    rx_counter <= rx_counter - 1;
                    // 算術右シフトし、rx_dataの最上位ビットにrxを代入
                    rx_data <= $signed({rx,rx_data}) >>> 1;
                    // ストップビットが立つ直前で、outValidを1にする
                    if(rx_counter == 1 && !read_ready) begin
                        outValid <= 1'b1;
                        read_ready <= 1'b1;
                    end
                    // ストップビットが立ったら、read_readyを1にし、outValidを0にして出力を無効化する
                    if(rx_counter == 0) begin
                        read_ready <= 1'b1;
                        outValid <= 1'b0;
                    end
                end

            end else begin
                baud_counter <= baud_counter + 1;
            end
            // 送信が終わったら、busyを0にする
            if (tx_counter == 0 && busy) begin
                busy <= 1'b0;
            end
            // 送信データをdataに読み込む(この処理のみ、clkの立ち上がりで行う)
            if (write_enable && !busy) begin
                tx_data <= {1'b1,data,1'b0};
                tx_counter <= 5'd10;
                busy <= 1'b1;
            end
        end
    end

endmodule
`default_nettype wire
