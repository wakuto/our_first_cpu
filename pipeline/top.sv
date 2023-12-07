`default_nettype none
module Top(
    input  wire clk,
    input  wire rst
);
    logic [31: 0] pc;
    wire  [31: 0] instruction;

    logic [31: 0] address;
    logic [31: 0] write_data;
    logic [ 3: 0] write_mask;
    logic         write_enable;
    logic [31: 0] read_data;
    logic [31: 0] dmemory_read_data;
    logic         tx;
    logic [ 7: 0] rx_data;
    logic         outValid;
    logic         rx; 
    wire          valid;


    logic [15: 0] baud_max;
    logic [ 7: 0] tx_holding;
    logic [ 7: 0] rx_holding;
    logic [ 7: 0] line_status;

    parameter uart_rw_address = 32'h10010000;
    parameter uart_status_address = 32'h10010005;
    parameter baud_max_address = 32'h10010100;

    logic busy;
    logic read_ready;
    logic uart_write_enable;
    logic read_enable;
    always_comb begin
        uart_write_enable = address == uart_rw_address && write_enable;
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
            if (write_enable && address == baud_max_address) baud_max <= write_data[15:0];
            if(write_enable) tx_holding <= write_data[7:0];
            if(outValid) rx_holding <= rx_data;
            line_status <= {1'b0,busy, 5'b0, read_ready};
        end
    end    

    // read_dataのマルチプレクサ
    always_comb begin
        case(address)
            uart_rw_address: read_data = {24'b0,rx_holding}; //受信時ならば、rx_holdingを返す
            uart_status_address: read_data = {24'b0,line_status}; //uart[5]には、busyとread_readyが入っている
            default: read_data = dmemory_read_data; //それ以外の場合は、dmemoryから読み出したデータを返す
        endcase
    end

    Core core(
        .clk(clk),
        .rst(rst),

        .address(address),
        .write_data(write_data),
        .write_enable(write_enable),
        .write_mask(write_mask),

        .read_data(read_data),

        .pc(pc),
        .instruction(instruction),
        .read_enable(read_enable),
        .valid(valid)
    );
    DMemory data_memory(
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .write_enable(write_enable && address != uart_rw_address),
        .write_mask(write_mask),
        .read_data(dmemory_read_data)
    );
    IMemory instruction_memory(
        .clk(clk),
        .pc(pc),
        .rst(rst),

        .instr(instruction),
        .valid(valid)
    );

    Uart uart(
        .clk(clk),
        .rst(rst),
        .data(tx_holding),
        .tx(tx),
        .busy(busy),
        .read_ready(read_ready),
        .write_enable(uart_write_enable),
        // 動作確認では、rxをtxに接続している
        .rx(tx),
        .rx_data(rx_data),
        .outValid(outValid),
        .baud_max(baud_max),
        .negate_read_ready(read_enable && address == uart_rw_address)
    );

endmodule
`default_nettype wire
