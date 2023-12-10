`default_nettype none
`timescale 1ns / 1ps

module cpu_test();
    reg clk;
    logic rst;
    logic tx;

    wire CEN [0:3];
    wire GWEN [0:3];
    wire [7:0] WEN [0:3];
    wire [8:0] A [0:3];
    wire [7:0] D [0:3];
    wire [7:0] Q [0:3];
    
    Top top(.clk(clk), .rst(rst), .tx(tx), .rx(tx), .CEN(CEN), .GWEN(GWEN), .WEN(WEN), .A(A), .D(D), .Q(Q));

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0);
        for (int i = 0; i < 32; i++) begin
          $dumpvars(0, top.core.reg_file.regfile[i]);
        end
        clk = 0;
        rst = 1;
        @(posedge clk)
        @(posedge clk)
        rst = 0;
        @(posedge clk)
        #1000000
        $finish;
    end
    always #(500) begin
        clk <= ~clk;
    end
    
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_0(
        .CLK(clk),
        .CEN(CEN[0]),
        .GWEN(GWEN[0]),
        .WEN(WEN[0]),
        .A(A[0]),
        .D(D[0]),
        .Q(Q[0])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_1(
        .CLK(clk),
        .CEN(CEN[1]),
        .GWEN(GWEN[1]),
        .WEN(WEN[1]),
        .A(A[1]),
        .D(D[1]),
        .Q(Q[1])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_2(
        .CLK(clk),
        .CEN(CEN[2]),
        .GWEN(GWEN[2]),
        .WEN(WEN[2]),
        .A(A[2]),
        .D(D[2]),
        .Q(Q[2])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_3(
        .CLK(clk),
        .CEN(CEN[3]),
        .GWEN(GWEN[3]),
        .WEN(WEN[3]),
        .A(A[3]),
        .D(D[3]),
        .Q(Q[3])
    );
endmodule
`default_nettype wire
