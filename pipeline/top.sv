`default_nettype none
module Top(   
    input  wire clk,
    input  wire rst
);
    logic [31: 0] pc;
    logic [31: 0] instruction;

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


    logic [31: 0] clk_frequency;
    logic [ 7: 0] tx_holding;
    logic [ 7: 0] rx_holding;
    logic [ 7: 0] line_status;

    parameter uart_rw = 32'h10010000;
    parameter uart_status = 32'h10010005;
    parameter clk_frequency_address = 32'h10010100;

    logic busy;
    logic read_ready;
    logic uart_write_enable;
    always_comb begin
        uart_write_enable = address == uart_rw && write_enable;
        //uartの各パラメータを設定
        if(uart_write_enable) tx_holding = write_data[7:0];
        if(outValid) rx_holding = rx_data;
        line_status = {1'b0,busy, 4'b0, read_ready};
    end
     always_ff @(posedge clk) begin
         if (rst) begin
            clk_frequency <= 32'hffc0;
            uart_write_enable <= 1'b0;
            tx_holding <= '1;
            rx_holding <= '1;
            line_status <= 8'b0;
        end
        else begin
            // clk_frequencyの設定(coreを通してソフトウェアから後で書き換えられるようにしている)
            if (write_enable && address == clk_frequency_address) clk_frequency <= write_data;
        end
    end    

    // read_dataのマルチプレクサ
    always_comb begin
        case(address)
            uart_rw: read_data = rx_holding; //受信時ならば、rx_holdingを返す
            uart_status: read_data = line_status; //uart[5]には、busyとread_readyが入っている
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
        .instruction(instruction)
    );
    DMemory data_memory(
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .write_enable(write_enable),
        .write_mask(write_mask),
        .read_data(dmemory_read_data)
    );
    IMemory instruction_memory(
        .pc(pc),
        .instr(instruction)
    );

    Uart uart(
        .clk(clk),
        .rst(rst),
        .data(tx_holding),
        .tx(tx),
        .busy(busy),
        .read_ready(read_ready),
        .baud_rate(11520),
        .clk_frequency(clk_frequency),
        .write_enable(uart_write_enable),
        // 動作確認では、rxをtxに接続している
        .rx(rx),
        .rx_data(rx_data),
        .outValid(outValid)
    );

endmodule
`default_nettype wire
