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
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 16'b0;
            baud_clk <= 16'b0;
        end else begin
            if (baud_counter == (clk_frequency/baud_rate-1)) begin
                baud_counter <= 16'b0;
                baud_clk <= ~baud_clk;
            end else begin
                baud_counter <= baud_counter + 1;
            end
        end
    end

    bit [4:0] count;  // 0~10をカウント
    typedef enum bit [1:0] {
        IDLE, // 送信待機
        START_BIT, // スタートビット
        DATA_BITS, // 送信
        STOP_BIT // ストップビット
    } uart_state_t;
    // start信号
    bit start;
    always_ff @(posedge baud_clk or posedge rst or posedge write_enable) begin
        if (rst) begin
            start <= 1'b0;
        end
        else if(write_enable) begin
            start <= 1'b1;
        end
        else begin
            start <= write_enable;
        end
    end

    //送信データ
    logic [7:0] tx_data;
    always_ff @(posedge write_enable or posedge rst) begin
        if (rst) begin
            tx_data <= 8'b0;
        end
        else if (write_enable) begin
            tx_data <= data;
        end
    end

    uart_state_t state, next_state;
    always_ff @(posedge baud_clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // 状態遷移
    always_ff @(negedge baud_clk or posedge rst) begin
        if(rst) begin
            next_state <= IDLE;
        end
        else begin
            case (state)
                IDLE:  begin
                    if(start) begin
                        next_state <= START_BIT;
                    end
                    else next_state <= IDLE;   
                end
                START_BIT: next_state <= DATA_BITS;
                DATA_BITS: next_state <= (count == 4'd8) ? STOP_BIT : DATA_BITS;
                STOP_BIT: next_state <= IDLE;
                default: next_state <= IDLE;
            endcase
        end
    end
    // カウンタ
    always_ff @(posedge baud_clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end
        else if (state != IDLE) begin
            count <= (count == 4'd9) ? 0 : count + 1;
        end
    end
    // tx出力
    always_comb begin
        case (state)
            START_BIT: tx = 0;
            DATA_BITS: tx = tx_data[count-1];
            STOP_BIT: tx = 1;
            default: tx = 1;
        endcase
    end
    // busy出力
    always_comb begin
        busy = (state != IDLE);
    end
endmodule
`default_nettype wire
