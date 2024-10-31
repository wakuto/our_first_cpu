`default_nettype none

module GPIO (
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  write_data,
    output reg [31:0]   read_data,

    output reg [31:0]   gpio_out,
    input  wire [31:0]  gpio_in 
);
    reg [31:0] gpio_out_reg;
    reg [31:0] gpio_read_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_out_reg <= 32'h0;
            gpio_read_reg  <= 32'h0;
        end else begin
            gpio_out_reg <= write_data;
            gpio_read_reg  <= gpio_in;
        end
    end

    always_comb begin
        gpio_out = gpio_out_reg;
        read_data = gpio_read_reg;
    end

endmodule

`default_nettype wire
