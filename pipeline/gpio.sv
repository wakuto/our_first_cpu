`default_nettype none

module GPIO (
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  address,
    input  wire [31:0]  write_data,
    input  wire         write_enable,
    output reg [31:0]   read_data,
    input  wire         read_enable,

    output reg [31:0]   gpio_out, // GPIOの出力
    input  wire [31:0]  gpio_in    // GPIOの入力
);

    parameter GPIO_ADDRESS_IN  = 32'hA0000000;
    parameter GPIO_ADDRESS_OUT = 32'hA0000100;

    reg [31:0] gpio_out_reg;
    reg [31:0] gpio_in_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_out_reg <= 32'h0;
            gpio_in_reg  <= 32'h0;
        end else begin
            if (write_enable) begin
                if (address == GPIO_ADDRESS_OUT) begin
                    gpio_out_reg <= write_data;
                end
            end
            if (read_enable) begin
                if (address == GPIO_ADDRESS_IN) begin
                    gpio_in_reg <= gpio_in;
                end 
            end
        end
    end

    always_comb begin
        if (read_enable) begin
            if (address == GPIO_ADDRESS_IN) begin
                read_data = gpio_in_reg; // GPIO入力を返す
            end else if (address == GPIO_ADDRESS_OUT) begin
                read_data = gpio_out_reg; // GPIO出力を返す
            end else begin
                read_data = 32'h0; // その他の場合は0
            end
        end else begin
            read_data = 32'h0; // 読み込みが無効な場合は0
        end
    end

    // GPIOの出力を外部に接続
    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_out <= 32'h0;
        end else begin
            gpio_out <= gpio_out_reg;
        end
    end

endmodule

`default_nettype wire
