`default_nettype none

module ALU (
    input  wire  [3:0]   alu_control,
    input  wire [31:0]   srca,
    input  wire [31:0]   srcb,

    output logic [31:0]   alu_result,
    output logic          zero
);

always_comb begin
    case (alu_control)
        4'b0000 : alu_result = srca + srcb;
        4'b0001 : alu_result = srca - srcb;
        4'b0010 : alu_result = srca & srcb;
        4'b0011 : alu_result = srca | srcb;
        4'b0100 : alu_result = srca ^ srcb;
        4'b0101 : alu_result = $signed(srca) < $signed(srcb);
        4'b0110 : alu_result = $unsigned(srca) < $unsigned(srcb);
        4'b0111 : alu_result = srca << srcb;
        4'b1000 : alu_result = srca >> srcb;
        4'b1001 : alu_result = srca >>> srcb;
        4'b1010 : alu_result = srca == srcb;
        4'b1011 : alu_result = srca != srcb;
        4'b1100 : alu_result = $signed(srca) >= $signed(srcb);
        4'b1101 : alu_result = $unsigned(srca) >= $unsigned(srcb);

        default: begin
            alu_result = 32'hDEADBEEF;
            $display("Unknown ALU command.");
        end
    endcase
    zero = alu_result == 0;
end

endmodule
`default_nettype wire
