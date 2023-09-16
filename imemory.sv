module IMemory(
    input  wire [31:0]   pc,
    output logic [31:0]  instr
);

always_comb begin
    case (pc)
        32'h0000 : instr = 32'h0000a303; // lw x6, 0(x1)
        32'h0004 : instr = 32'h00612023; // sw x6, 0(x2)
        default: begin
            instr = 32'h0000;
            $display("die");
        end
    endcase
end

endmodule