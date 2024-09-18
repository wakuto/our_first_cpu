`default_nettype none

module GPIO (
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  address,
    input  wire [31:0]  write_data,
    input  wire         write_enable,
    output wire [31:0]  read_data,
    input  wire         read_enable,

    output reg  [31:0]  gpio_out,
    input  wire [31:0]  gpio_in
);

    parameter GPIO_BASE = 32'ha0000000;
    parameter GPIO_SIZE = 32'h00000100;

    reg [31:0] gpio_register;

    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_register <= 32'b0;
        end else if (write_enable && (address >= GPIO_BASE && address < GPIO_BASE + GPIO_SIZE)) begin
            gpio_register <= write_data;
        end
    end

    assign read_data = (read_enable && (address >= GPIO_BASE && address < GPIO_BASE + GPIO_SIZE)) ? gpio_in : 32'h00000000;

    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_out <= 32'b0;
        end else begin
            gpio_out <= gpio_register;
        end
    end
endmodule
`default_nettype wire
