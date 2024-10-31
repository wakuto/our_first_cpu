`default_nettype none

module GPIO (
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  address,
    input  wire [31:0]  write_data,
    input  wire         write_enable,
    output reg [31:0]   read_data,

    output reg [31:0]   gpio_out,
    input  wire [31:0]  gpio_in 
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
            if (address == GPIO_ADDRESS_IN) begin
                gpio_in_reg <= gpio_in;
            end
        end
    end

    always_comb begin
        if (address == GPIO_ADDRESS_IN) begin
            read_data = gpio_in_reg;
        end else if (address == GPIO_ADDRESS_OUT) begin
            read_data = gpio_out_reg;
        end else begin
            read_data = 32'h0;
        end
    end
    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_out <= 32'h0;
        end else begin
            gpio_out <= gpio_out_reg;
        end
    end

endmodule

`default_nettype wire
