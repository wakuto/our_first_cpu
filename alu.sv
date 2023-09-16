module ALU (
    input  wire  [2:0]   alu_control,
    input  wire [31:0]   srca,
    input  wire [31:0]   srcb,

    output logic [31:0]   alu_result,
    output logic          zero
);

always_comb begin
    zero = alu_result == 0;
    case (alu_control)
        3'b000 : alu_result = srca + srcb;
        3'b001 : alu_result = srca - srcb;
        3'b010 : alu_result = srca & srcb;
        3'b011 : alu_result = srca | srcb;
        3'b101 : alu_result = srca < srcb;
        default: begin
            alu_result = 32'hDEADBEEF;
            $display("Unknown ALU command.");
        end
    endcase
end

endmodule