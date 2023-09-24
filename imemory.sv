`default_nettype none

module IMemory(
    input  wire [31:0]   pc,
    output logic [31:0]  instr
);

logic [7:0] mem [0:4095];

initial begin
    int fd = $fopen("./program.bin", "rb");
    int i = 0;
    int res = 1;
    res = $fread(mem, fd, 0, 4096);
    $fclose(fd);
end

always_comb begin
    instr = {mem[pc+3], mem[pc+2], mem[pc+1], mem[pc]};
    /*
    case (pc)
        32'h0000 : instr = 32'h00002303; // lw x6, 0(x0)
        32'h0004 : instr = 32'h00102383; // lw x7, 1(x0)
        32'h0008 : instr = 32'h00736433; // or x8, x6, x7
        32'h000c : instr = 32'h02802023; // sw x8, 32(x0)
        32'h0010 : instr = 32'hfe0008e3; // beq x0, x0, -16
        default: begin
            instr = 32'h0000;
            $display("die");
        end
    endcase
    */
end

endmodule
`default_nettype wire