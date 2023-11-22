`default_nettype none

module cpu_test();
    logic clk;
    logic rst;
    
    Top top(.clk(clk), .rst(rst));

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, top);
        for (int i = 0; i < 32; i++) begin
          $dumpvars(0, top.core.reg_file.regfile[i]);
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
