`default_nettype none

module GPIO (
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  address,
    input  wire [31:0]  write_data,
    input  wire         write_enable,
    output reg [31:0]  read_data,
    input  wire         read_enable,

    output reg  [31:0]  gpio_out,
    input  wire [31:0]  gpio_in
);

    parameter GPIO_ADDRESS = 32'ha0000000;

    reg [31:0] gpio_register;

    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_register <= 32'b0;
        end else if (write_enable && address == GPIO_ADDRESS) begin
            gpio_register <= write_data;
        end
    end
    always_ff @(posedge clk) begin
        if(rst) begin
            read_data <= 32'b0;
        end else if (read_enable && address == GPIO_ADDRESS) begin
            read_data <= gpio_out;
        end
    end
    assign gpio_out = gpio_register;
endmodule
`default_nettype wire
