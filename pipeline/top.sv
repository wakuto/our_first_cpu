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


    logic [7:0] uart_memory[0:7];
    logic [31:0] clk_frequency;

    parameter uart_rw = 32'h10010000;
    parameter uart_status = 32'h10010005;
    parameter clk_frequency_address = 32'h10010100;

    logic busy;
    logic read_ready;
    logic uart_write_enable;

    // uartの各パラメータを設定
    always_comb begin
        uart_write_enable = address == uart_rw && write_enable;
        if(uart_write_enable) uart_memory[0] = write_data[7:0];
        else if(outValid) uart_memory[0] = rx_data;

        uart_memory[5] = {1'b0,busy, 4'b0, read_ready};
    end

    // clk_frequencyの設定(coreを通してソフトウェアから後で書き換えられるようにしている)
    always_ff @(posedge clk) begin
         if (rst) begin
            clk_frequency <= 32'hffc0;
        end
        else begin
            if (write_enable && address == clk_frequency_address) clk_frequency <= write_data;
        end
    end    

    // read_dataのマルチプレクサ
    always_comb begin
        case(address)
            uart_rw: read_data = uart_memory[0]; //受信時ならば、uart[0]には受信データが入っている
            uart_status: read_data = uart_memory[5]; //uart[5]には、busyとread_readyが入っている
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
        .data(uart_memory[0]),
        .tx(tx),
        .busy(busy),
        .read_ready(read_ready),
        .baud_rate(11520),
        .clk_frequency(clk_frequency),
        .write_enable(uart_write_enable),
        .rx(rx),
        .rx_data(rx_data),
        .outValid(outValid)
    );

    // UARTのoutput信号を全てdummyに接続する
    logic       dummy_tx;
    logic       dummy_busy;
    logic dummy_read_ready;
    logic [7:0] dummy_rx_data;
    logic dummy_outValid;
    // 受信したデータを保持するレジスタ
    logic [7:0] dummy_uart;
    always_comb begin
      if(dummy_outValid) dummy_uart = dummy_rx_data;
    end
    Uart uart_rx(
        .clk(clk),
        .rst(rst),
        .data(uart_memory[0]),
        .tx(dummy_tx),
        .busy(dummy_busy),
        .read_ready(dummy_read_ready),
        .baud_rate(11520),
        .clk_frequency(clk_frequency),
        //txを行わないようにする
        .write_enable(0),
        .rx(tx),
        .rx_data(dummy_rx_data),
        .outValid(dummy_outValid)
    );

endmodule
`default_nettype wire
