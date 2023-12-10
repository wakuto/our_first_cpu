`default_nettype none
`timescale 1ns / 1ps

module cpu_test();
    reg clk;
    logic rst;
    logic imem_rst;
    logic tx;

    wire CEN_dmem [0:3];
    wire GWEN_dmem [0:3];
    wire [7:0] WEN_dmem [0:3];
    wire [8:0] A_dmem [0:3];
    wire [7:0] D_dmem [0:3];
    wire [7:0] Q_dmem [0:3];

    logic CEN_imem [0:3];
    logic GWEN_imem [0:3];
    logic [7:0] WEN_imem [0:3];
    logic [8:0] A_imem [0:3];
    logic [7:0] D_imem [0:3];
    logic [7:0] Q_imem [0:3];

    wire CEN_imem_read [0:3];
    wire GWEN_imem_read [0:3];
    wire [7:0] WEN_imem_read [0:3];
    wire [8:0] A_imem_read [0:3];
    wire [7:0] D_imem_read [0:3];

    logic CEN_imem_write [0:3];
    logic GWEN_imem_write [0:3];
    logic [7:0] WEN_imem_write [0:3];
    logic [8:0] A_imem_write [0:3];
    logic [7:0] D_imem_write [0:3];
    
    Top top(
        .clk(clk),
        .rst(rst),
        .tx(tx), 
        .rx(tx), 
        .CEN_dmem(CEN_dmem), 
        .GWEN_dmem(GWEN_dmem), 
        .WEN_dmem(WEN_dmem), 
        .A_dmem(A_dmem), 
        .D_dmem(D_dmem), 
        .Q_dmem(Q_dmem),
        .CEN_imem(CEN_imem_read), 
        .GWEN_imem(GWEN_imem_read), 
        .WEN_imem(WEN_imem_read), 
        .A_imem(A_imem_read), 
        .D_imem(D_imem_read), 
        .Q_imem(Q_imem)
        );

    logic [7:0] mem [0:4095];
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0);
        for (int i = 0; i < 32; i++) begin
          $dumpvars(0, top.core.reg_file.regfile[i]);
        end
        for (int i = 0; i < 4; i++) begin
          $dumpvars(0, top.instruction_memory.CEN[i]);
          $dumpvars(0, CEN_imem_read[i]);
          $dumpvars(0, top.CEN_imem[i]);
        end
        // 命令読み込み
        $readmemh("../test/test.hex", mem);
        //　最初のサイクルではCENをhighにする
        clk = 0;
        rst = 1;
        for(int i=0; i<4; i++) CEN_imem_write[i] = 1;
        @(posedge clk)
        @(posedge clk)
        for(int pc=0; pc < 100; pc++) begin
            @(posedge clk)
            for(int i=0;i<4;i++) begin
                CEN_imem_write[i] = 0;
                GWEN_imem_write[i] = 0;
                WEN_imem_write[i]  = 8'b0;
                A_imem_write[i] = pc;
                D_imem_write[i] = mem[pc*4+i];
                $display("pc: %d, instr: %h", pc, mem[pc*4+i]);
            end
        end
        rst = 0;

        //リセット
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
    
    always_comb begin
        for(int i=0;i<4;i++) begin
            CEN_imem[i] = rst ? CEN_imem_write[i] : CEN_imem_read[i];
            GWEN_imem[i] = rst ? GWEN_imem_write[i] : GWEN_imem_read[i];
            WEN_imem[i]  = rst ? WEN_imem_write[i]  : WEN_imem_read[i];
            A_imem[i]    = rst ? A_imem_write[i]    : A_imem_read[i];
            D_imem[i]    = rst ? D_imem_write[i]    : D_imem_read[i];
        end
    end

    gf180mcu_fd_ip_sram__sram512x8m8wm1 dmem_0(
        .CLK(clk),
        .CEN(CEN_dmem[0]),
        .GWEN(GWEN_dmem[0]),
        .WEN(WEN_dmem[0]),
        .A(A_dmem[0]),
        .D(D_dmem[0]),
        .Q(Q_dmem[0])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 dmem_1(
        .CLK(clk),
        .CEN(CEN_dmem[1]),
        .GWEN(GWEN_dmem[1]),
        .WEN(WEN_dmem[1]),
        .A(A_dmem[1]),
        .D(D_dmem[1]),
        .Q(Q_dmem[1])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 dmem_2(
        .CLK(clk),
        .CEN(CEN_dmem[2]),
        .GWEN(GWEN_dmem[2]),
        .WEN(WEN_dmem[2]),
        .A(A_dmem[2]),
        .D(D_dmem[2]),
        .Q(Q_dmem[2])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 dmem_3(
        .CLK(clk),
        .CEN(CEN_dmem[3]),
        .GWEN(GWEN_dmem[3]),
        .WEN(WEN_dmem[3]),
        .A(A_dmem[3]),
        .D(D_dmem[3]),
        .Q(Q_dmem[3])
    );

    gf180mcu_fd_ip_sram__sram512x8m8wm1 imem_0(
        .CLK(clk),
        .CEN(CEN_imem[0]),
        .GWEN(GWEN_imem[0]),
        .WEN(WEN_imem[0]),
        .A(A_imem[0]),
        .D(D_imem[0]),
        .Q(Q_imem[0])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 imem_1(
        .CLK(clk),
        .CEN(CEN_imem[1]),
        .GWEN(GWEN_imem[1]),
        .WEN(WEN_imem[1]),
        .A(A_imem[1]),
        .D(D_imem[1]),
        .Q(Q_imem[1])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 imem_2(
        .CLK(clk),
        .CEN(CEN_imem[2]),
        .GWEN(GWEN_imem[2]),
        .WEN(WEN_imem[2]),
        .A(A_imem[2]),
        .D(D_imem[2]),
        .Q(Q_imem[2])
    );
    gf180mcu_fd_ip_sram__sram512x8m8wm1 imem_3(
        .CLK(clk),
        .CEN(CEN_imem[3]),
        .GWEN(GWEN_imem[3]),
        .WEN(WEN_imem[3]),
        .A(A_imem[3]),
        .D(D_imem[3]),
        .Q(Q_imem[3])
    );
endmodule
`default_nettype wire
