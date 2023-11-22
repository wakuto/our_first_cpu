`default_nettype none
module Top(   
    input  wire clk,
    input  wire rst,

    input [7:0] uart_in
);
    logic [31: 0] pc;
    logic [31: 0] instruction;

    logic [31: 0] address;
    logic [31: 0] write_data;
    logic [ 3: 0] write_mask;
    logic         write_enable;
    logic [31: 0] read_data;
    logic         tx;

    Core core(
        .clk(clk),
        .rst(rst),

        .address(address),
        .write_data(write_data),
        .write_enable(write_enable),
        .write_mask(write_mask),
        .read_data(read_data),

        .pc(pc),
        .instruction(instruction)
    );
    
    DMemory data_memory(
        .clk(clk),
        .address(address),
        .read_data(read_data),
        .write_enable(write_enable),
        .write_data(write_data),
        .write_mask(write_mask)
    );
    IMemory instruction_memory(
        .pc(pc),
        .instr(instruction)
    );

    Uart uart(
        .clk(clk),
        .rst(rst),
        .start(1'b1),
        .data(uart_in),
        .tx(tx)
    );
endmodule
`default_nettype wire
