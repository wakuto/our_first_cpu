`default_nettype none
`timescale 1ns/1ps

module cpu_test();
    logic clk;
    logic rst;
    
    CPU cpu(.clk(clk), .rst(rst));

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu, cpu.reg_file.regfile);
        clk = 0;

        rst = 1;
        @(posedge clk)
        @(posedge clk)
        rst = 0;
        #1000
        $finish;
    end
    always #(5) begin
        clk <= ~clk;
    end

endmodule
`default_nettype wire