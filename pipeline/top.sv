`default_nettype none
`timescale 1ns/1ps
module Top(
    input  wire clk,
    input  wire rst,
    output wire tx,
    input wire rx,

    output wire CEN_dmem [0:3],
    output wire GWEN_dmem [0:3],
    output wire [7:0] WEN_dmem [0:3],
    output wire [8:0] A_dmem [0:3],
    output wire [7:0] D_dmem [0:3],
    input  wire  [7:0] Q_dmem [0:3],

    output wire CEN_imem [0:3],
    output wire GWEN_imem [0:3],
    output wire [7:0] WEN_imem [0:3],
    output wire [8:0] A_imem [0:3],
    output wire [7:0] D_imem [0:3],
    input  wire  [7:0] Q_imem [0:3]
);
    logic [31: 0] pc;
    wire  [31: 0] instruction;
    
    logic [31: 0] address;
    logic [31: 0] write_data;
    logic [ 3: 0] write_mask;
    logic         write_enable;
    wire          read_enable;
    wire          read_valid;

    logic [31: 0] read_data;
    logic [31: 0] dmemory_read_data;
    logic [ 7: 0] rx_data;
    logic         outValid;
    wire          valid;
    
    logic [15: 0] baud_max;
    logic [ 7: 0] tx_holding;
    logic [ 7: 0] rx_holding;
    logic [ 7: 0] line_status;

    parameter DMEMORY_BASE = 32'h00000000;
    parameter DMEMORY_SIZE = 32'h10000000;
    parameter UART_RW_ADDRESS = 32'h10010000;
    parameter UART_STATUS_ADDRESS = 32'h10010005;
    parameter BAUD_MAX_ADDRESS = 32'h10010100;
    
    logic busy;
    logic read_ready;
    logic uart_write_enable;
    logic dmemory_write_enable;

    always_comb begin
        uart_write_enable = address == UART_RW_ADDRESS && write_enable;
        if (DMEMORY_BASE <= address && address < DMEMORY_BASE + DMEMORY_SIZE) begin
            dmemory_write_enable = write_enable;
        end else begin
            dmemory_write_enable = 1'b0;
        end    
    end
    always_ff @(posedge clk) begin
        if (rst) begin
            tx_holding <= 8'b0;
            rx_holding <= 8'b0;
            line_status <= 8'b0;
            baud_max <= 16'h3;
        end
        else begin
            // baud_maxの設定(coreを通してソフトウェアから後で書き換えられるようにしている)
            if (write_enable && address == BAUD_MAX_ADDRESS) baud_max <= write_data[15:0];if(write_enable) tx_holding <= write_data[7:0];
            if(outValid) rx_holding <= rx_data;
            line_status <= {1'b0,busy, 5'b0, read_ready};
        end
    end

    // read_dataのマルチプレクサ
    always_comb begin
        case(address)
            UART_RW_ADDRESS: read_data = {24'b0,rx_holding}; //受信時ならば、rx_holdingを返す
            UART_STATUS_ADDRESS: read_data = {24'b0,line_status}; //uart[5]には、busyとread_readyが入っている
            default: read_data = dmemory_read_data; //それ以外の場合は、dmemoryから読み出したデータを返す
        endcase
    end

    Core core(
        .clk(clk),
        .rst(rst),

        .address(address),
        .write_data(write_data),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .write_mask(write_mask),

        .read_data(read_data),
        .read_valid(read_valid),

        .pc(pc),
        .instruction(instruction),
        .valid(valid)
    );
  
    DMemory data_memory_test(
        .clk(clk),
        .rst(rst),
        .address(address),
        .read_enable(read_enable),
        .read_valid(read_valid),
        .write_data(write_data),
        .write_enable(dmemory_write_enable),
        .write_mask(write_mask),
        .read_data(dmemory_read_data),
        .CEN(CEN_dmem),
        .GWEN(GWEN_dmem),
        .WEN(WEN_dmem),
        .A(A_dmem),
        .D(D_dmem),
        .Q(Q_dmem)
    );
    IMemory instruction_memory(
        .clk(clk),
        .pc(pc),
        .rst(rst),
        .instr(instruction),
        .valid(valid),
        .CEN(CEN_imem),
        .GWEN(GWEN_imem),
        .WEN(WEN_imem),
        .A(A_imem),
        .D(D_imem),
        .Q(Q_imem)
    );

    Uart uart(
        .clk(clk),
        .rst(rst),
        .data(tx_holding),
        .tx(tx),
        .busy(busy),
        .read_ready(read_ready),
        .write_enable(uart_write_enable),
        .rx(rx),
        .rx_data(rx_data),
        .outValid(outValid),
        .baud_max(baud_max),
        .negate_read_ready(read_enable && address == UART_RW_ADDRESS)
    );

endmodule
`default_nettype wire
