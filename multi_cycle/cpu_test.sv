`default_nettype none
`timescale 1ns/1ps

module cpu_test();
    logic clk;
    logic rst;
    
    CPU cpu(.clk(clk), .rst(rst));

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu);
        for (int i = 0; i < 32; i++) begin
          $dumpvars(0, cpu.reg_file.regfile[i]);
        end
        clk = 0;

        rst = 1;
        @(posedge clk)
        @(posedge clk)
        rst = 0;
        #100000
        $finish;
    end
    always #(5) begin
        clk <= ~clk;
    end

endmodule
`default_nettype wire
